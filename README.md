# Buddy Switch

![Buddy Switch: mascot on for chat, robot mode for work](assets/buddy-switch-hero.png)

![Buddy Switch model and persona routing variations](assets/buddy-switch-variants.png)

Buddy Switch is a small, practical pattern for running two local Hermes
profiles from the same messaging surface:

- a light "friend" profile for relaxed chat
- a stronger "work" profile for tools, files, search, and terminal tasks

The current workaround switches the active Telegram gateway with `/friend` and
`/work`. The long-term goal is upstream Hermes profile routing, where one
gateway can dispatch a chat, thread, user, or command to the right isolated
profile without restarting the gateway.

This repo is deliberately curated. It is not a copy of a live Hermes home, and
it does not include secrets, state databases, logs, process snapshots, or full
private persona files.

Korean guide: [`docs/ko.md`](docs/ko.md)

## What Is Included

- `docs/current-workaround.md`: the working fallback using Hermes quick
  commands and gateway restart scripts.
- `docs/upstream-design.md`: a small upstream-friendly direction for Hermes.
- `examples/`: generic config, scripts, launchd template, and an optional
  Ollama no-think proxy.
- `references/hermes-issues.md`: relevant upstream issues and adjacent
  projects.

## Install

Fastest path:

```bash
curl -fsSL https://raw.githubusercontent.com/woooya129-ai/buddy-switch/main/install.sh | bash
```

This installs:

- `~/.local/bin/buddy-switch-friend`
- `~/.local/bin/buddy-switch-work`
- `~/.local/bin/nothink_proxy.py`
- `~/.config/buddy-switch/config.env`
- later, runtime logs go under `~/.local/state/buddy-switch/`

## Where Does It Go?

Buddy Switch installs helper files next to your user tools. It does not install
Hermes, OpenClaw, models, bot tokens, or credentials.

| Path | What it is |
| --- | --- |
| `~/.local/bin/buddy-switch-friend` | Command run by `/friend` |
| `~/.local/bin/buddy-switch-work` | Command run by `/work` |
| `~/.local/bin/nothink_proxy.py` | Optional Ollama `think:false` proxy |
| `~/.config/buddy-switch/config.env` | The one file you usually edit |
| `~/.local/state/buddy-switch/` | Logs created after the first switch |
| `~/.hermes/profiles/<profile>/config.yaml` | Hermes config you edit manually |

If you prefer cloning first:

```bash
git clone https://github.com/woooya129-ai/buddy-switch.git
cd buddy-switch
./install.sh
```

To skip the optional no-think proxy:

```bash
INSTALL_NOTHINK_PROXY=0 ./install.sh
```

See `docs/install.md` for the full setup flow.

## Quick Start

1. Create two Hermes profiles, for example `buddy-friend` and `buddy-work`.
2. Install Buddy Switch with the one-line installer above.
3. Edit `~/.config/buddy-switch/config.env` if your profile names differ.
4. Add quick commands like this to both Hermes profile configs:

```yaml
quick_commands:
  friend:
    type: exec
    command: "$HOME/.local/bin/buddy-switch-friend"
  work:
    type: exec
    command: "$HOME/.local/bin/buddy-switch-work"
```

5. In Telegram, send `/friend` or `/work`, wait for the gateway to switch, then
   send the next message.

See `examples/hermes/config.example.yaml` for a fuller example.

## Model and Persona Variations

![Buddy Switch character sheets: warm persona variants and cool AI model variants](assets/buddy-switch-character-sheet.png)

Buddy Switch treats the model and the persona as two independent routing axes.
That lets a Telegram command or future handle choose exactly what should
change:

The table below is an example routing matrix. Buddy Switch does not bundle real
persona prompt files or five finished personalities.

| Route type | Meaning | Example |
| --- | --- | --- |
| Model + Persona | Pick a complete preset. | `work-large` + `analyst` |
| Fixed Model + New Persona | Keep the same engine, change the voice. | `fixed` + `warm-coach` |
| New Model + Fixed Persona | Keep the same character, use a stronger engine. | `qwen-work` + `fixed` |
| Fixed Model + Fixed Persona | Keep the stable default identity. | `fixed` + `fixed` |
| New Model + New Persona | Switch the whole mode. | `gemma-chat` + `moe-friend` |

Today, Buddy Switch exposes this as profile switching through `/friend` and
`/work`. A future Hermes feature can expose the same idea as profile, model,
and persona routing inside one gateway.

## Telegram Handles

For a friendlier Telegram UX, Buddy Switch proposes configured handle-style
routes. These are not real Telegram accounts; they are local names that the
gateway recognizes. The names below are examples; replace them with names that
fit your own setup.

```text
@mika        -> persona route
@forge       -> model route
@mika-forge  -> combined model + persona route
```

Example messages:

```text
@mika explain this gently
@forge check the logs
@mika-forge summarize this for a human
```

The suggested upstream behavior is:

1. An inline `@handle` can route one message.
2. `/profile @handle` can bind the current chat to that route.
3. `/profile default` can reset the chat to the gateway default.

Until Hermes supports this natively, use `/friend` and `/work` as the simple
fallback.

## Representative Examples

### Hermes Today: Buddy Switch Fallback

Hermes does not need to know about `friend` or `work` as built-in concepts.
Those names are local quick commands:

```text
/friend
  -> Hermes quick command
  -> ~/.local/bin/buddy-switch-friend
  -> hermes -p buddy-friend gateway start

/work
  -> Hermes quick command
  -> ~/.local/bin/buddy-switch-work
  -> hermes -p buddy-work gateway start
```

### OpenClaw Reference: Native Agent Routing

OpenClaw already has a first-class CLI surface for isolated agents and routing
bindings. Representative examples from its agent docs look like this:

```bash
openclaw agents add work --workspace ~/.openclaw/workspace-work --bind telegram:*
openclaw agents bind --agent work --bind telegram:ops
openclaw agents bindings --agent work
```

Buddy Switch is the Hermes-side local fallback for the same idea: keep separate
personalities, tools, memory, and workspaces, then route the message to the
right one.

## Current Workaround

The workaround is intentionally simple:

```text
/friend -> quick command -> stop work gateway -> start friend gateway
/work   -> quick command -> stop friend gateway -> start work gateway
```

It works today, but it is not the ideal upstream shape. Restarting the gateway
is a local fallback. A proper Hermes feature should route a message to a named
profile inside a single gateway process.

## Upstream Direction

Buddy Switch is aligned with the profile-routing direction already discussed in
Hermes:

- [#24913: one gateway serves multiple agents](https://github.com/NousResearch/hermes-agent/issues/24913)
- [#40173: Telegram channel_profiles](https://github.com/NousResearch/hermes-agent/issues/40173)
- [#19809: per-channel profile routing for Discord](https://github.com/NousResearch/hermes-agent/issues/19809)

The proposed upstream path is:

1. `telegram.channel_profiles` for static Telegram chat-to-profile routing.
2. `/profile ls` and `/profile <name>` for runtime chat binding.
3. `profile_aliases` so `/friend` and `/work` can be user config, not hard-coded
   Hermes commands.
4. `route_presets` or handle routes so messages can call example names like
   `@mika`, `@forge`, or another configured local name.

## Related Work

OpenClaw already exposes isolated agents and routing bindings in its CLI. Buddy
Switch keeps that idea as a reference point while focusing on Hermes profiles:
[OpenClaw agents docs](https://docs.openclaw.ai/cli/agents).

## License

MIT
