# Fork Readiness

This note freezes the upstream facts used to start Buddy Switch fork work. It
prevents the forks from rebuilding features that already exist.

Checked on 2026-07-10:

| Upstream | Main commit checked | License | Buddy Switch role |
| --- | --- | --- | --- |
| Hermes Agent | `d2e64fcb89cd180c6657bbe60723980fc5498778` | MIT | Primary implementation target |
| OpenClaw | `8dd45e864e045d6c54ecd57a064d80378900b5e3` | MIT | Behavior reference and optional handle-UX experiment |

Always rebase a feature branch before coding because both upstream repositories
move quickly.

## Hermes: What Already Exists

- Named profile creation and management in `hermes profile`.
- Profile-scoped config, SOUL, skills, state, and gateway service handling.
- Messaging `/profile` status output.
- Configured `/personality <name>` changes inside the active profile.
- An opt-in `gateway.multiplex_profiles` foundation on current `main`.

Do not rebuild these surfaces in the fork.

## Hermes: First Missing Slice

The first branch should implement static Telegram chat-to-profile routing on
the existing multiplex gateway foundation:

```yaml
gateway:
  multiplex_profiles: true

platforms:
  telegram:
    channel_profiles:
      "<TELEGRAM_CHAT_ID>": "<PROFILE_NAME>"
```

Exact nesting must follow the upstream config loader when implementation
starts. The block above communicates intent, not a committed schema.

Acceptance criteria:

1. Multiplex mode remains opt-in and single-profile behavior does not change.
2. An allowlisted Telegram chat resolves only to an existing profile.
3. Unknown profile names fail closed with a useful configuration error.
4. Session, SOUL, credentials, tools, memory, and workspace remain scoped to
   the routed profile.
5. One Telegram bot token is polled by one gateway process.
6. Tests cover at least three profiles and two model/provider configurations.

Suggested branch: `feature/buddy-switch-telegram-routing`.

## Hermes: Later Slices

1. `/profile ls`, `/profile <name>`, and `/profile default` per chat.
2. User-configured aliases; no hard-coded `/friend` or `/work`.
3. Explicit route precedence for inline handle, runtime binding, static route,
   and gateway default.
4. Generic configured `@handle` routes after static routing is stable.

Relevant open issues:

- [#24913: one gateway serves multiple agents](https://github.com/NousResearch/hermes-agent/issues/24913)
- [#40173: Telegram channel_profiles](https://github.com/NousResearch/hermes-agent/issues/40173)
- [#19809: Discord profile routing](https://github.com/NousResearch/hermes-agent/issues/19809)

## OpenClaw Track

OpenClaw already supports isolated agents and channel/account bindings:

```bash
openclaw agents add work --workspace ~/.openclaw/workspace-work --bind telegram:*
openclaw agents bind --agent work --bind telegram:ops
openclaw agents bindings --agent work
```

The OpenClaw fork should not recreate agent routing. Its useful Buddy Switch
experiment is a configured, local `@handle` that routes one message or binds a
conversation while preserving OpenClaw's existing agent isolation and security
rules. Start with a design and tests before changing runtime code.

Suggested branch: `research/buddy-switch-handle-routing`.

Reference: [OpenClaw agents documentation](https://docs.openclaw.ai/cli/agents).

## Fork Hygiene

- Keep `upstream` pointed to the original project and `origin` to the personal
  fork.
- Never copy live `.env`, auth stores, Telegram IDs, state databases, sessions,
  logs, personal SOUL files, or local absolute paths into either fork.
- Use neutral fixtures such as `alpha`, `beta`, and `gamma`.
- Keep Buddy Switch artwork and standalone installer changes in this repository,
  not in upstream PRs unless maintainers explicitly request them.
