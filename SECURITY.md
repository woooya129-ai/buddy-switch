# Security

## Runtime Security Model

Read this before wiring `/friend` and `/work` into a live bot.

**Quick commands with `type: exec` are remote command execution.** The Hermes
gateway runs on your machine with your user account. A `type: exec` quick
command lets anyone who can trigger it run a local program. Your protections,
in order of importance:

1. **Telegram allowlist is the security boundary.** Set
   `TELEGRAM_ALLOWED_USERS` in every profile `.env`, and keep
   `GATEWAY_ALLOW_ALL_USERS=false` (the default). Never expose an exec quick
   command on a bot that unknown users can message.
2. **Point exec commands at fixed script paths you own.** No user input should
   ever be interpolated into the command line. The switch scripts take no
   arguments from chat.
3. **Protect the files the bridge trusts.** If someone can edit the switch
   scripts or `config.env`, they own the bridge:
   - switch scripts: owned by you, not group/world-writable (`755` or `700`)
   - `~/.config/buddy-switch/config.env`: `600` (the installer sets this; the
     scripts refuse to load a group/world-writable config)
4. **One bot token, one poller.** Never let two gateways poll the same token;
   apart from breaking Telegram delivery, it makes it unclear which profile
   answered — and which toolset was live.
5. **The work profile is the sharp edge.** It typically has terminal, file,
   and web tools enabled, so treat prompt injection as a real path: content the
   model reads (web pages, files, forwarded messages) can try to steer it into
   running commands. Keep the allowlist tight, prefer sandboxed terminal
   backends (docker/ssh) if Hermes offers them, and leave tools off in the
   friend profile.
6. **Keep local model endpoints on loopback.** Ollama and the optional
   no-think proxy should listen on `127.0.0.1` only (both default to that).
   Do not port-forward them off the machine.
7. **Lock down runtime state.** Conversation history lives in `state.db`,
   `sessions/`, and logs. Keep `~/.hermes` at `700` and the databases at
   `600`; treat gateway logs as sensitive.

**Installer trust.** `curl | bash` runs whatever the network gives you. If
that bothers you (it should, sometimes), clone the repo, read `install.sh` and
the two scripts (they are short), then run `./install.sh` locally.

## Publishing Hygiene

Buddy Switch is meant to be a shareable pattern, not a dump of a live Hermes
home directory. Before publishing your own fork or examples, check for:

- Bot tokens, API keys, passwords, OAuth secrets, cookies, and GitHub tokens.
- Telegram user IDs, group IDs, channel IDs, thread IDs, phone numbers, and
  private chat names.
- `state.db`, `sessions/`, memories, logs, process snapshots, PID files, and
  lock files.
- Absolute local paths that identify a person or machine.
- Full persona files that contain private history or character material.

Recommended practice:

1. Keep live `.env` files out of git.
2. Use placeholders such as `__HOME__`, `__PROFILE_NAME__`, and
   `__TELEGRAM_CHAT_ID__` in examples.
3. Publish raw runtime logs only after manual review.
4. Push privately first, run a secret scan, then make the repository public.

If you find a sensitive value in this repository, rotate that credential before
opening an issue or pull request.

