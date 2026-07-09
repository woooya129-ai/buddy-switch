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

## Adjacent Reference

- [OpenClaw agents docs](https://docs.openclaw.ai/cli/agents)
  - OpenClaw already documents isolated agents and routing bindings. Buddy
    Switch keeps that as a useful comparison while focusing on Hermes profiles.

