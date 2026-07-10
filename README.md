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

Languages (English is canonical):
[中文](docs/i18n/zh.md) ·
[हिन्दी](docs/i18n/hi.md) ·
[Español](docs/i18n/es.md) ·
[Français](docs/i18n/fr.md) ·
[العربية](docs/i18n/ar.md) ·
[Português](docs/i18n/pt.md) ·
[Русский](docs/i18n/ru.md) ·
[日本語](docs/i18n/ja.md) ·
[한국어](docs/i18n/ko.md) ·
[Deutsch](docs/i18n/de.md)

Translations are ordered roughly by total speaker reach. They may lag behind
the English README; corrections and additional language PRs are welcome.

## What Is Included

- `docs/current-workaround.md`: the working fallback using Hermes quick
  commands and gateway restart scripts.
- `docs/upstream-design.md`: a small upstream-friendly direction for Hermes.
- `docs/testing.md`: the test matrix and naming guard for implementing the
  upstream design without hard-coding maintainer-specific names.
- `docs/fork-readiness.md`: the verified Hermes and OpenClaw fork baseline.
- `docs/personas.md`: how SOUL files, language policy, and model choice fit
  together.
- `docs/model-selection.md`: how to discover, compare, and copy an exact model
  ID instead of guessing from a family name.
- `docs/friends-picker.md`: the shared `/friends` discovery flow for Telegram
  and terminals.
- `examples/`: generic config, scripts, launchd template, and an optional
  Ollama no-think proxy.
- `references/hermes-issues.md`: relevant upstream issues and adjacent
  projects.

## Install

Fastest path:

```bash
curl -fsSL https://raw.githubusercontent.com/woooya129-ai/buddy-switch/main/install.sh | bash
```

![Buddy Switch installer running in a terminal](assets/buddy-switch-screenshot.png)

This installs:

- `~/.local/bin/buddy-switch-friend`
- `~/.local/bin/buddy-switch-work`
- `~/.local/bin/buddy-switch-routes`
- `~/.local/bin/buddy-switch-init`
- `~/.local/bin/nothink_proxy.py`
- `~/.config/buddy-switch/config.env`
- starter SOUL drafts under `~/.config/buddy-switch/personas/`
- later, runtime logs go under `~/.local/state/buddy-switch/`

The installer shows real step progress, then a short ASCII eye-opening scene.
On a first interactive install it continues into a small setup wizard for
profile names, response language, and editable SOUL drafts. It never overwrites
an existing Hermes `SOUL.md`.

### Does It Apply Automatically After Installation?

**Not yet.** The installer does not edit a live Hermes or OpenClaw
configuration. This is deliberate because those files contain provider
settings, bot tokens, user IDs, and private SOUL content.

| Part | Installed automatically? | One-time action still required |
| --- | --- | --- |
| Buddy Switch commands and local config | Yes | Review `~/.config/buddy-switch/config.env` |
| Starter SOUL drafts | Yes | Review and place them in the matching profile/workspace |
| Hermes profiles, models, Telegram, quick commands | No | Create and configure both profiles, then add the quick-command block |
| OpenClaw agents, models, Telegram accounts, bindings | No | Create agents and bind each configured Telegram account |

After that one-time connection is complete, the saved setup is automatic:
starting a Hermes profile loads its own model, `SOUL.md`, tools, and Telegram
settings; starting OpenClaw loads its saved agents and bindings. Buddy Switch
then chooses an already-configured route. It does not invent or replace the
route's model at switch time.

## Where Does It Go?

Buddy Switch installs helper files next to your user tools. It does not install
Hermes, OpenClaw, models, bot tokens, or credentials.

| Path | What it is |
| --- | --- |
| `~/.local/bin/buddy-switch-friend` | Command run by `/friend` |
| `~/.local/bin/buddy-switch-work` | Command run by `/work` |
| `~/.local/bin/buddy-switch-routes` | Shows the current route, model, personality, and choices |
| `~/.local/bin/buddy-switch-init` | First-run profile and SOUL draft generator |
| `~/.local/bin/nothink_proxy.py` | Optional Ollama `think:false` proxy |
| `~/.config/buddy-switch/config.env` | The one file you usually edit |
| `~/.config/buddy-switch/personas/` | Generated SOUL drafts to review |
| `~/.config/buddy-switch/aliases.list` | Your `@name_model` alias definitions (edit via `buddy-switch-init aliases`) |
| `~/.config/buddy-switch/quick-commands.aliases.yaml` | Generated block to merge into profile configs |
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

1. Install Hermes and create two profiles, for example:

   ```bash
   hermes profile create buddy-friend
   hermes profile create buddy-work
   ```

2. If using local Ollama, install one exact model variant rather than guessing
   its name:

   ```bash
   ollama pull gemma4:e4b
   ollama list
   ollama show gemma4:e4b
   ```

3. Configure the real model inside each Hermes profile. For this example,
   choose the Ollama custom endpoint and copy `gemma4:e4b` exactly:

   ```bash
   hermes -p buddy-friend model
   hermes -p buddy-work model
   ```

4. Install Buddy Switch with the one-line installer above.
5. Follow the first-run prompts, or run `buddy-switch-init` later.
6. Review the generated SOUL drafts and place the final versions in the
   matching Hermes profile directories. Back up an existing `SOUL.md` first.
7. Add quick commands like this to both Hermes profile configs:

   ```yaml
   quick_commands:
     friends:
       type: exec
       command: "$HOME/.local/bin/buddy-switch-routes"
       category: catalog
       label: "Choose a friend"
     friend:
       type: exec
       command: "$HOME/.local/bin/buddy-switch-friend"
       category: route
       label: "Friend"
       profile: buddy-friend
       model: "gemma4:e4b"
       personality: "warm"
     work:
       type: exec
       command: "$HOME/.local/bin/buddy-switch-work"
       category: route
       label: "Work"
       profile: buddy-work
       model: "gemma4:31b"
       personality: "focused"
   ```

8. Run `buddy-switch-routes` in a terminal or send `/friends` in Telegram to
   see the current profile, personality, model, and available routes. On stock
   Hermes this is a readable text menu; the Buddy Switch Hermes fork adds
   native Telegram buttons.
9. Choose `/friend` or `/work`. The first reply says `SWITCHING`, which is only
   a request. Wait 10-20 seconds and run `/friends` again. Continue only when it
   shows `ACTIVE` with the intended name, profile, model, and personality.

See [`docs/install.md`](docs/install.md) for the full beginner flow and
[`docs/model-selection.md`](docs/model-selection.md) for Gemma 4 variants and
exact model-ID rules.

## Command Cheat Sheet

### Terminal

| Goal | Command | What it changes |
| --- | --- | --- |
| List installed Ollama models | `ollama list` | Nothing; copy an exact `NAME` from here |
| Inspect the example model | `ollama show gemma4:e4b` | Nothing |
| List Hermes profiles | `hermes profile list` | Nothing |
| Configure a profile's real model | `hermes -p buddy-friend model` | That Hermes profile |
| Show Buddy Switch routes | `buddy-switch-routes` | Nothing |
| Switch to friend mode | `buddy-switch-friend` | Starts the configured friend gateway |
| Switch to work mode | `buddy-switch-work` | Starts the configured work gateway |
| Discover OpenClaw Ollama IDs | `openclaw models list --provider ollama` | Nothing |
| Verify OpenClaw agent routes | `openclaw agents list --bindings` | Nothing |

### Telegram

These commands work only after the corresponding Telegram gateway/account is
configured once in Hermes or OpenClaw.

| Goal | Hermes with Buddy Switch | Stock OpenClaw |
| --- | --- | --- |
| Show who/model/personality now | `/friends`; require `ACTIVE` | Run `/friends` in the bot chat you are currently viewing |
| Switch model + persona + tools together | `/friend` or `/work`, then recheck `/friends` | Open the bot bound to that agent; this opens a separate chat |
| Switch this chat to a name+model combination | `@name_model` (for example `@mika_gemma`), then recheck `/friends`; same chat, persistent | `/model` changes only the current bot chat's model |
| Pick among configured models | `/model` | `/model` or `/model list`, then `/model <number>` |
| Return to the saved model | Start the intended profile again | `/model default` |
| Show model details | Hermes fork: `/friends` is live; standalone: confirmed route plus configured model hint | `/friends` in the current bot, or `/model status` |

The standalone repo does not add `/friends` to stock OpenClaw. Its OpenClaw
example uses native agents and Telegram account bindings; fork-only buttons are
optional and are not required by this guide.

## Route Name vs Model Name

Never type a friendly router name where a provider expects a model ID:

| Value | Example | Meaning |
| --- | --- | --- |
| Route command | `friend` | Runs `/friend` |
| Hermes profile | `buddy-friend` | Owns model, SOUL, tools, memory, and Telegram config |
| Ollama family alias | `gemma4` | Convenient default tag; may move over time |
| Exact Ollama ID | `gemma4:e4b` | Copy from `ollama list` |
| OpenClaw model reference | `ollama/gemma4:e4b` | Exact provider plus model |

`FRIEND_MODEL` and `WORK_MODEL` in Buddy Switch are only display and
Ollama-unload hints. The actual Hermes model is the one saved by
`hermes -p <profile> model`; the actual OpenClaw model is the one saved on its
agent. Route switching selects that profile or agent.

## Persona and Response Language

The response language belongs in each profile's `SOUL.md`, not in Buddy Switch
routing config. A reliable language setup combines:

1. a clear SOUL language-policy block
2. a model that performs well in that language
3. optional provider sampling adjustments only when testing shows language
   mixing

Hermes may cache the built system prompt for an agent or session. After editing
`SOUL.md`, start a new session or restart the relevant gateway if the change is
not visible. See [`docs/personas.md`](docs/personas.md) for starter templates
and model-selection notes.

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

## Find Routes Without Memorizing Them

`/friends` is a status screen first and a picker second. Its first block answers
the questions people usually forget:

```text
Who am I talking to?  -> active profile or agent
How will it answer?   -> personality / SOUL
What is running it?   -> provider and model
Did the change work?  -> ACTIVE, SWITCHING, or FAILED
```

On Telegram, the Hermes fork renders **Personality**, **Model**, and **Routes**
as buttons. A model choice reuses Hermes's existing model picker; a personality
choice reuses `/personality`; a route choice runs only a quick command marked
`category: route`. If buttons are unavailable, the same screen includes exact
text commands.

The route buttons can show their target model when quick-command metadata
contains `profile`, `model`, and `personality`. After `/friend` or `/work`, the
initial `SWITCHING` result is not success. Run `/friends` again and trust the
new route only when the screen says `ACTIVE` or `ACTIVE IN THIS CHAT`.

In a terminal:

```bash
buddy-switch-routes
# Hermes fork CLI also supports:
/friends
/friends personality <name>
/friends model <provider/model>
/friends route <name>
```

See [`docs/friends-picker.md`](docs/friends-picker.md) for the complete behavior.

## Telegram Handles

`@name_model` handles such as `@mika_qwen` and `@mika_gemma` are **local
routing aliases inside the current chat**. They are not Telegram bot accounts,
and they never open another conversation:

```text
@mika_qwen  -> switch THIS chat to the Mika + Qwen combination (persistent)
@mika_gemma -> switch THIS chat to the Mika + Gemma combination (persistent)
```

The baseline semantics are:

- `@name_model`: persistent router change for the current chat.
- `/friends`: shows the name, personality, and model bound to the current chat.
- `/friend`, `/work`: full profile change in the same chat.
- No extra Telegram bot chats are created.

In the Buddy Switch Hermes fork, a message that is exactly `@<route>` runs the
matching `category: route` quick command. A model alias uses a session-scoped
model switch so only this chat changes:

```yaml
quick_commands:
  mika_gemma:
    type: alias
    category: route
    label: "Mika + Gemma"
    target: "model ollama/gemma4:e4b --session"
```

You do not have to write that YAML by hand. `buddy-switch-init aliases`
manages the aliases interactively or via `--add name=model[=label]` /
`--remove name`, and regenerates
`~/.config/buddy-switch/quick-commands.aliases.yaml` for you. It can be rerun
at any time — first-run setup also offers it, but aliases are never
first-run-only.

After sending `@mika_gemma`, run `/friends` again: it must show the new model
for this chat. Handles that end in `bot`, appear inside a longer message, or
are not configured as routes are never captured; they stay normal messages.

Opening a **separate** bot conversation happens only in the OpenClaw multi-bot
approach, where each real `@botusername` link is its own bot account, chat,
agent, model, and session. Do not mix the two mechanisms: `@mika_gemma` is a
local same-chat alias, while `@mika_gemma_bot` is a real bot account whose
link opens a different chat and changes nothing in the current one.

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

For Telegram, bind each agent to a named bot account and set the account's
display `name` to its real bot username. Then `/friends` in the OpenClaw fork
can show a direct button to that bot:

```text
@mika_chat_bot   -> friend agent + its SOUL + its model
@mika_work_bot   -> work agent + its SOUL + its model
```

See [`examples/openclaw/config.example.json5`](examples/openclaw/config.example.json5).
Telegram usernames do not allow hyphens, so use underscores in the real
`@username`; keep a friendlier `Mika - Work` label in prose or UI.

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

## Security

`/friend`, `/work`, and the text fallback for `/friends` are `type: exec` quick
commands: anyone who can trigger them runs a local program on your machine. The Telegram allowlist
(`TELEGRAM_ALLOWED_USERS`) is the security boundary — set it in every profile
`.env` before wiring the commands up, and read [SECURITY.md](SECURITY.md) for
the full runtime security model (file permissions, prompt-injection notes for
the work profile, and loopback-only model endpoints).

## License

MIT
