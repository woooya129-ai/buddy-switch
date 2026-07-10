# Upstream Design

Buddy Switch should become a Hermes feature only when the local workaround is
translated into generic profile routing.

## Current Upstream Baseline

Verified against Hermes `main` on 2026-07-10:

- Hermes already manages isolated profiles with `hermes profile create`,
  `list`, `use`, and related commands.
- Messaging `/profile` currently reports the active profile; it does not accept
  a target profile and route the current chat there.
- `/personality <name>` can change a configured prompt inside the current
  profile. It is not a profile switch because model, tools, memory, sessions,
  credentials, and workspace stay in the same profile.
- `gateway.multiplex_profiles` now provides an opt-in base for one gateway to
  host multiple profiles. The remaining Buddy Switch work should build on that
  substrate instead of creating a second profile loader.
- The Telegram `channel_profiles`, one-gateway multi-agent, and Discord routing
  issues are still open.

The first fork experiment should therefore be narrow: resolve a Telegram event
to a permitted profile in multiplex mode, preserve profile-scoped sessions and
credentials, and leave the default single-profile path unchanged.

## Goal

One gateway process should receive platform messages and run each turn under
the correct Hermes profile.

Examples:

```text
Telegram DM A      -> profile: buddy-friend
Telegram group B   -> profile: buddy-work
Discord channel C  -> profile: research
/profile coder     -> bind this chat to coder
@writer            -> persistently switch this chat to writer
```

## Proposed Surfaces

### Model and Persona Are Separate Axes

Profile routing should be allowed to select a complete profile, but the user
experience should also make it clear that model and persona can be controlled
independently.

The rows below are routing examples. They are not a bundled set of persona
prompt files.

| Route type | Meaning |
| --- | --- |
| Model + Persona | Select a complete preset. |
| Fixed Model + New Persona | Keep the model, change the personality. |
| New Model + Fixed Persona | Change the model, keep the personality. |
| Fixed Model + Fixed Persona | Keep the current stable default. |
| New Model + New Persona | Switch both axes at once. |

This keeps `/model` from becoming a hidden profile switch, while still allowing
advanced users to build named routes. Names such as `@mika`, `@forge`, and
`@mika-forge` are examples, not required defaults.

### Static Telegram Routing

```yaml
telegram:
  channel_profiles:
    "__TELEGRAM_CHAT_ID_FRIEND__": "buddy-friend"
    "__TELEGRAM_CHAT_ID_WORK__": "buddy-work"
```

This is the smallest upstream PR because it matches the existing Telegram issue
shape and avoids runtime binding state at first.

### Runtime Profile Command

```text
/profile
/profile ls
/profile buddy-work
/profile default
```

Expected behavior:

- `/profile` shows the active profile for the current chat.
- `/profile ls` lists available Hermes profiles.
- `/profile <name>` binds the current chat to that profile.
- `default` resets to the gateway launch profile.

### Profile Aliases

```yaml
profile_aliases:
  friend: buddy-friend
  work: buddy-work
```

Aliases let users create `/friend` and `/work` behavior from config without
hard-coding those names in Hermes.

### Later Route Extensions

`channel_profiles` covers chats. The same shape extends naturally, and each
extension already has an upstream issue:

```yaml
telegram:
  topic_profiles:
    "__CHAT_ID__:__THREAD_ID__": "buddy-work"
  user_profiles:
    "__USER_ID__": "buddy-friend"
```

- Forum topic to profile: #10143, #4321
- Per-user routing: #33548

These should reuse one shared route-matching layer instead of adding
platform-specific code paths per extension.

### Profile Creation Onboarding

Switching assumes profiles already exist. A small creation flow makes the
feature usable for first-time setups:

- `hermes profile create <name>`: a wizard asking for an existing profile to
  copy (`--from`), a provider/model picked from configured providers, a tools
  preset (minimal / full / custom), a persona starting template, and an
  optional alias.
- Non-interactive flags for scripting: `--from`, `--model`, `--tools`,
  `--alias`.
- Optional chat surface: `/profile new <name>` (admin only).
- First-run onboarding: when a gateway starts with zero profiles, suggest the
  wizard.
- Templates stay role-based ("light chat", "full tools"). No specific model is
  ever a default; the user always picks.

### Telegram Handle Routing

Handle routes are configured names that feel like talking to a person in
Telegram, without requiring one Telegram bot account per route.

The handles below are examples.

```yaml
route_presets:
  mika:
    handle: "@mika"
    profile: buddy-friend
    model: fixed
    persona: personas/moe-rose.md
  forge:
    handle: "@forge"
    profile: buddy-work
    model: "__WORK_MODEL_NAME__"
    persona: fixed
  mika_forge:
    handle: "@mika-forge"
    profile: buddy-work
    model: "__WORK_MODEL_NAME__"
    persona: personas/moe-rose.md
```

Suggested behavior:

- A message that is exactly `@handle` persistently re-routes the current chat
  to that route. The chat itself never changes and no new bot chat opens.
- `/profile @handle` is an equivalent explicit form of the same binding.
- `/profile default` clears the binding.
- `/friends` must reflect the new binding immediately: after `@handle`, the
  status block shows the new name, personality, and model for this chat.
- A configured route that fails to apply reports `FAILED` visibly.
- Routing precedence is runtime chat binding, static platform route, then
  gateway default.

Hermes should only resolve handles listed in config; handles inside longer
messages, handles ending in `bot`, and unlisted handles stay normal messages.
That avoids accidentally capturing real Telegram usernames or bot mentions.

## Isolation Rules

Routing must switch the profile boundary, not just the model. A routed turn
should use the target profile's:

- config and `.env`
- model/provider
- SOUL and user memory
- state database and transcript
- tools and skills
- workspace/cwd

Session keys should include the profile for non-default routed profiles, while
keeping the legacy default session key shape for backward compatibility.

## Non-goals

- Do not hard-code `friend` or `work` into Hermes.
- Do not upstream shell scripts that kill and restart gateways.
- Do not treat `/model` as profile routing.
- Do not require one Telegram bot token per profile.

## PR Plan

1. Implement `telegram.channel_profiles` for static chat-to-profile routing on
   the existing multiplex gateway path.
2. Add `/profile ls` and `/profile <name>` for runtime chat binding.
3. Add `profile_aliases` so `/friend` and `/work` are user-defined aliases.
4. Add configured `route_presets` or handle routes for example local `@name`
   calls.

Per-stage test cases, fixtures, and the naming guard live in
[`testing.md`](testing.md).

Relevant issues:

- https://github.com/NousResearch/hermes-agent/issues/24913
- https://github.com/NousResearch/hermes-agent/issues/40173
- https://github.com/NousResearch/hermes-agent/issues/19809
