#!/usr/bin/env python3
"""OpenAI-compatible Ollama chat proxy that forces think:false.

This is optional. It is useful for models that expose hidden thinking through
Ollama's native `/api/chat` option but are consumed by clients through an
OpenAI-compatible `/v1/chat/completions` endpoint.
"""

import json
import os
import sys
import time
import urllib.error
import urllib.request
from http.server import BaseHTTPRequestHandler, ThreadingHTTPServer


HOST = os.environ.get("OLLAMA_NOTHINK_PROXY_HOST", "127.0.0.1")
PORT = int(os.environ.get("OLLAMA_NOTHINK_PROXY_PORT", "11435"))
UPSTREAM = os.environ.get("OLLAMA_NOTHINK_UPSTREAM", "http://127.0.0.1:11434").rstrip("/")
DEFAULT_MODEL = os.environ.get("OLLAMA_NOTHINK_MODEL", "__MODEL_NAME__")


def json_response(handler, status, payload):
    body = json.dumps(payload, ensure_ascii=False).encode("utf-8")
    handler.send_response(status)
    handler.send_header("Content-Type", "application/json; charset=utf-8")
    handler.send_header("Content-Length", str(len(body)))
    handler.end_headers()
    handler.wfile.write(body)


def read_json(handler):
    length = int(handler.headers.get("Content-Length", "0") or "0")
    raw = handler.rfile.read(length) if length else b"{}"
    return json.loads(raw.decode("utf-8") or "{}")


def request_json(method, path, payload=None, timeout=600):
    data = None
    headers = {"Content-Type": "application/json"}
    if payload is not None:
        data = json.dumps(payload, ensure_ascii=False).encode("utf-8")
    req = urllib.request.Request(
        f"{UPSTREAM}{path}",
        data=data,
        headers=headers,
        method=method,
    )
    with urllib.request.urlopen(req, timeout=timeout) as resp:
        raw = resp.read()
    return json.loads(raw.decode("utf-8") or "{}")


def message_content(content):
    if isinstance(content, str):
        return content
    if isinstance(content, list):
        parts = []
        for item in content:
            if isinstance(item, dict) and item.get("type") == "text":
                parts.append(str(item.get("text") or ""))
            elif isinstance(item, str):
                parts.append(item)
        return "\n".join(part for part in parts if part)
    return "" if content is None else str(content)


def convert_messages(messages):
    converted = []
    for msg in messages or []:
        if not isinstance(msg, dict):
            continue
        converted.append(
            {
                "role": msg.get("role") or "user",
                "content": message_content(msg.get("content")),
            }
        )
    return converted


def ollama_payload(openai_payload, stream):
    options = {}
    for key in ("temperature", "top_p", "top_k", "repeat_penalty", "presence_penalty", "frequency_penalty"):
        if openai_payload.get(key) is not None:
            options[key] = openai_payload[key]

    max_tokens = (
        openai_payload.get("max_tokens")
        or openai_payload.get("max_completion_tokens")
        or openai_payload.get("max_output_tokens")
    )
    if max_tokens:
        options["num_predict"] = int(max_tokens)

    num_ctx = openai_payload.get("num_ctx") or os.environ.get("OLLAMA_NOTHINK_NUM_CTX")
    if num_ctx:
        options["num_ctx"] = int(num_ctx)

    return {
        "model": openai_payload.get("model") or DEFAULT_MODEL,
        "messages": convert_messages(openai_payload.get("messages") or []),
        "think": False,
        "stream": stream,
        "options": options,
    }


def openai_completion(payload, upstream):
    model = payload.get("model") or upstream.get("model") or DEFAULT_MODEL
    content = ((upstream.get("message") or {}).get("content") or "")
    done_reason = upstream.get("done_reason") or "stop"
    prompt_count = int(upstream.get("prompt_eval_count") or 0)
    eval_count = int(upstream.get("eval_count") or 0)
    now = int(time.time())
    return {
        "id": f"chatcmpl-nothink-{now}",
        "object": "chat.completion",
        "created": now,
        "model": model,
        "choices": [
            {
                "index": 0,
                "message": {"role": "assistant", "content": content},
                "finish_reason": "stop" if done_reason == "stop" else done_reason,
            }
        ],
        "usage": {
            "prompt_tokens": prompt_count,
            "completion_tokens": eval_count,
            "total_tokens": prompt_count + eval_count,
        },
    }


class Handler(BaseHTTPRequestHandler):
    server_version = "OllamaNoThinkProxy/1.0"

    def log_message(self, fmt, *args):
        return

    def do_HEAD(self):
        self.send_response(200)
        self.end_headers()

    def do_GET(self):
        if self.path in ("/", "/v1", "/v1/"):
            json_response(self, 200, {"status": "ok"})
            return
        if self.path in ("/v1/models", "/api/v1/models"):
            try:
                tags = request_json("GET", "/api/tags")
                data = [
                    {
                        "id": item.get("name"),
                        "object": "model",
                        "created": 0,
                        "owned_by": "ollama",
                    }
                    for item in tags.get("models", [])
                    if item.get("name")
                ]
                json_response(self, 200, {"object": "list", "data": data})
            except Exception as exc:
                json_response(self, 502, {"error": str(exc)})
            return
        json_response(self, 404, {"error": "not found"})

    def do_POST(self):
        if self.path in ("/v1/chat/completions", "/api/v1/chat/completions"):
            try:
                payload = read_json(self)
                stream = bool(payload.get("stream"))
                upstream_payload = ollama_payload(payload, stream)
                if stream:
                    self.stream_chat(payload, upstream_payload)
                else:
                    upstream = request_json("POST", "/api/chat", upstream_payload)
                    json_response(self, 200, openai_completion(payload, upstream))
            except Exception as exc:
                json_response(self, 502, {"error": str(exc)})
            return
        json_response(self, 404, {"error": "not found"})

    def stream_chat(self, payload, upstream_payload):
        req = urllib.request.Request(
            f"{UPSTREAM}/api/chat",
            data=json.dumps(upstream_payload, ensure_ascii=False).encode("utf-8"),
            headers={"Content-Type": "application/json"},
            method="POST",
        )
        self.send_response(200)
        self.send_header("Content-Type", "text/event-stream; charset=utf-8")
        self.send_header("Cache-Control", "no-cache")
        self.send_header("Connection", "keep-alive")
        self.end_headers()

        model = payload.get("model") or DEFAULT_MODEL
        chunk_id = f"chatcmpl-nothink-{int(time.time())}"
        created = int(time.time())
        role_sent = False

        with urllib.request.urlopen(req, timeout=600) as resp:
            for raw_line in resp:
                line = raw_line.decode("utf-8").strip()
                if not line:
                    continue
                item = json.loads(line)
                content = ((item.get("message") or {}).get("content") or "")
                delta = {}
                if not role_sent:
                    delta["role"] = "assistant"
                    role_sent = True
                if content:
                    delta["content"] = content
                if delta:
                    chunk = {
                        "id": chunk_id,
                        "object": "chat.completion.chunk",
                        "created": created,
                        "model": model,
                        "choices": [{"index": 0, "delta": delta, "finish_reason": None}],
                    }
                    self.wfile.write(f"data: {json.dumps(chunk, ensure_ascii=False)}\n\n".encode("utf-8"))
                    self.wfile.flush()
                if item.get("done"):
                    break

        done = {
            "id": chunk_id,
            "object": "chat.completion.chunk",
            "created": created,
            "model": model,
            "choices": [{"index": 0, "delta": {}, "finish_reason": "stop"}],
        }
        self.wfile.write(f"data: {json.dumps(done, ensure_ascii=False)}\n\n".encode("utf-8"))
        self.wfile.write(b"data: [DONE]\n\n")
        self.wfile.flush()


def main():
    if HOST not in ("127.0.0.1", "localhost", "::1"):
        print(
            f"WARNING: binding to {HOST} exposes this proxy beyond localhost. "
            "It has no authentication; anyone who can reach it can use your "
            "local models. Keep OLLAMA_NOTHINK_PROXY_HOST on 127.0.0.1 unless "
            "you know what you are doing.",
            file=sys.stderr,
        )
    server = ThreadingHTTPServer((HOST, PORT), Handler)
    print(f"Ollama no-think proxy listening on http://{HOST}:{PORT}")
    server.serve_forever()


if __name__ == "__main__":
    main()

