# Hermes Issue References

Buddy Switch is based on existing Hermes profile-routing discussions.

## Core

- [#24913 - one gateway serves multiple agents](https://github.com/NousResearch/hermes-agent/issues/24913)
  - Proposes `/profile <name>` and per-chat agent/profile binding.
  - Important because it treats profiles as isolated agents, not only prompt
    presets.
- [#40173 - Telegram channel_profiles](https://github.com/NousResearch/hermes-agent/issues/40173)
  - Proposes one Telegram bot/gateway routing chats to different profiles.
  - Good first upstream target for Buddy Switch.
- [#19809 - Discord per-channel profile routing](https://github.com/NousResearch/hermes-agent/issues/19809)
  - Shows the same problem outside Telegram.
  - Useful evidence that this should become gateway-level routing, not a
    Telegram-only workaround.
- [#29535 - route chat/thread messages to profiles in a single gateway](https://github.com/NousResearch/hermes-agent/issues/29535)
  - Proposes a `profile_routes` block and lists what must be profile-scoped:
    config, `.env`, model, memory, session store, workspace, SOUL, tools, logs.
  - The closest existing sketch of the full routing layer.

## Related

- [#10143 - topic-to-profile routing](https://github.com/NousResearch/hermes-agent/issues/10143)
  - Telegram forum topic to profile routing.
- [#4321 - map Telegram forum topics to profiles](https://github.com/NousResearch/hermes-agent/issues/4321)
  - Similar topic-profile mapping shape.
- [#32943 - Telegram bots do not see each other's messages](https://github.com/NousResearch/hermes-agent/issues/32943)
  - Explains why "one bot token per profile" is not enough for multi-agent group
    coordination.
- [#33548 - per-user profile routing](https://github.com/NousResearch/hermes-agent/issues/33548)
  - Extends the same idea to user-to-profile mappings.
- [#29092](https://github.com/NousResearch/hermes-agent/issues/29092) and
  [#4707](https://github.com/NousResearch/hermes-agent/issues/4707)
  - Profile-scoped gateway/service pitfalls.
- [#52635 - work-profile gateway silently drops forum-topic messages](https://github.com/NousResearch/hermes-agent/issues/52635)
  - Adapter-level message loss to watch for when implementing topic routing;
    covered by a regression case in `../docs/testing.md`.

## Adjacent Reference

- [OpenClaw agents docs](https://docs.openclaw.ai/cli/agents)
  - OpenClaw documents `openclaw agents` for isolated agents, workspaces, and
    routing bindings.
  - Representative commands include `openclaw agents add work --workspace
    ~/.openclaw/workspace-work --bind telegram:*` and `openclaw agents bind
    --agent work --bind telegram:ops`.
  - Buddy Switch keeps that as a useful comparison while focusing on Hermes
    profiles.
