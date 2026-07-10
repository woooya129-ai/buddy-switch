# Choosing an Exact Model ID

Buddy Switch route names, profile names, and model IDs are different things.
Do not guess a model ID from a friendly label.

| Example | Meaning | Where it belongs |
| --- | --- | --- |
| `friend` | Buddy Switch route command | `/friend` and `quick_commands` |
| `buddy-friend` | Hermes profile ID | `FRIEND_PROFILE` |
| `gemma4` | Ollama family/default tag; convenient but may change | Quick experiments |
| `gemma4:e4b` | Exact Ollama model tag | Hermes model setup and `FRIEND_MODEL` hint |
| `ollama/gemma4:e4b` | Provider-prefixed OpenClaw model reference | OpenClaw agent config |

`FRIEND_MODEL` and `WORK_MODEL` in Buddy Switch are display and Ollama-unload
hints. They do **not** configure the model used by Hermes. The model actually
used by a route is saved in the target Hermes profile or OpenClaw agent.

## Never Guess: Discover, Copy, Then Configure

For a local Ollama installation:

```bash
# What is already installed? Copy the exact NAME, including its :tag.
ollama list

# Download one exact variant if it is missing.
ollama pull gemma4:e4b

# Inspect its metadata and capabilities.
ollama show gemma4:e4b

# Make sure it can answer before connecting an agent.
ollama run gemma4:e4b "Reply with exactly: model ready"
```

The official [Ollama Gemma 4 tags](https://ollama.com/library/gemma4/tags)
page is the source of truth for downloadable variants. `ollama list` is the
source of truth for what this computer can use without another download.

For Hermes, configure the model in each profile:

```bash
hermes -p buddy-friend model
hermes -p buddy-work model
```

When using local Ollama, select a custom endpoint, use
`http://127.0.0.1:11434/v1`, and enter the exact Ollama name copied from
`ollama list`, such as `gemma4:e4b`. Hermes's
[local Ollama guide](https://hermes-agent.nousresearch.com/docs/guides/local-ollama-setup)
contains the current provider steps.

For OpenClaw, copy the provider-prefixed reference shown by its catalog:

```bash
openclaw models list --provider ollama
openclaw models status
```

OpenClaw uses `provider/model`, so the same Ollama tag becomes
`ollama/gemma4:e4b`. See the official
[OpenClaw Ollama guide](https://docs.openclaw.ai/providers/ollama).

## Which Gemma 4 Variant?

These are example base tags listed by Ollama when this guide was checked. The
catalog can change, so confirm the current values before downloading.

| Exact Ollama ID | Published download size | Context | Practical starting point |
| --- | ---: | ---: | --- |
| `gemma4:e2b` | 7.2 GB | 128K | Lowest resource use of these base tags |
| `gemma4:e4b` | 9.6 GB | 128K | General local chat starting point |
| `gemma4:12b` | 7.6 GB | 256K | Longer context in a compact published build |
| `gemma4:26b` | 18 GB | 256K | Larger MoE option when more memory is available |
| `gemma4:31b` | 20 GB | 256K | Highest-capacity base option in this list |

Download size is not a RAM guarantee. Runtime memory also depends on context,
quantization, the Ollama build, and other applications. Start smaller when in
doubt and watch for swapping, out-of-memory errors, and unacceptable latency.

Tags such as `-q4_K_M`, `-q8_0`, `-bf16`, and `-mlx` are specific builds. They
change memory, speed, precision, or runtime packaging. Beginners should start
with a base tag above and choose a specialized tag only after comparing its
entry on the Ollama tags page.

## A Beginner Decision Rule

1. **Availability:** use a name that appears in `ollama list` or the provider's
   model catalog. Copy it exactly.
2. **Tools:** a work agent needs reliable tool calling, not just good chat.
   Test one real file, terminal, or search task inside the agent.
3. **Memory and speed:** choose the smallest variant that completes that test
   comfortably on the machine.
4. **Context and media:** choose longer context or image/audio support only
   when the workflow needs it; those features have a runtime cost.
5. **Language and persona:** test the target response language with the actual
   SOUL file. A larger model is not automatically better for every language.
6. **Reproducibility:** save an explicit tag such as `gemma4:e4b`, not only
   `gemma4` or `latest`, when stable behavior matters.

## Put the Same ID in the Right Places

Example using `gemma4:e4b` for the friend route and `gemma4:31b` for work:

```bash
# Buddy Switch display/unload hints only
nano ~/.config/buddy-switch/config.env
```

```bash
FRIEND_MODEL="gemma4:e4b"
WORK_MODEL="gemma4:31b"
```

Then configure those same exact IDs in the matching Hermes profiles with
`hermes -p <profile> model`. For OpenClaw, use the provider prefix:

```bash
openclaw agents add friend \
  --workspace ~/.openclaw/workspace-friend \
  --model ollama/gemma4:e4b
```

The route selects the profile or agent. The profile or agent selects the real
model. Keeping those responsibilities separate makes `/friends` easy to read
and prevents a friendly route name from silently becoming a guessed model ID.
