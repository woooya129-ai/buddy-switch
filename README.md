# Buddy Switch

Buddy Switch is a small, practical pattern for running two local Hermes
profiles from the same messaging surface:

- a light "friend" profile for relaxed chat
- a stronger "work" profile for tools, files, search, and terminal tasks

_한국어: Buddy Switch는 Hermes에서 가벼운 대화용 프로필과 강한 작업용
프로필을 `/friend`, `/work`로 쉽게 오가게 만드는 공개용 패턴입니다._

The current workaround switches the active Telegram gateway with `/friend` and
`/work`. The long-term goal is upstream Hermes profile routing, where one
gateway can dispatch a chat, thread, user, or command to the right isolated
profile without restarting the gateway.

This repo is deliberately curated. It is not a copy of a live Hermes home, and
it does not include secrets, state databases, logs, process snapshots, or full
private persona files.

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

_한국어: 가장 쉬운 설치는 위 한 줄입니다. 설치 후
`~/.config/buddy-switch/config.env`에서 Hermes 프로필 이름만 본인 환경에
맞게 바꾸면 됩니다._

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

_한국어: `buddy-friend`, `buddy-work`라는 이름으로 프로필을 만들면 거의 바로
쓸 수 있습니다. 다른 이름을 쓰면 config 파일에서 `FRIEND_PROFILE`,
`WORK_PROFILE`만 바꿔주세요._

See `examples/hermes/config.example.yaml` for a fuller example.

## Current Workaround

The workaround is intentionally simple:

```text
/friend -> quick command -> stop work gateway -> start friend gateway
/work   -> quick command -> stop friend gateway -> start work gateway
```

It works today, but it is not the ideal upstream shape. Restarting the gateway
is a local fallback. A proper Hermes feature should route a message to a named
profile inside a single gateway process.

_한국어: 지금 방식은 실사용 가능한 우회입니다. 다만 장기적으로는 gateway를
재시작하지 않고 Hermes 내부에서 profile routing을 하는 게 목표입니다._

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

_한국어: upstream에 올릴 때는 `/friend`, `/work`를 고정 기능으로 넣기보다
사용자가 alias로 정의할 수 있는 범용 profile routing 기능으로 가는 것이
맞습니다._

## Related Work

OpenClaw already exposes isolated agents and routing bindings in its CLI. Buddy
Switch keeps that idea as a reference point while focusing on Hermes profiles:
[OpenClaw agents docs](https://docs.openclaw.ai/cli/agents).

## License

MIT
