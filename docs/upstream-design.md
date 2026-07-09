# Upstream Design

Buddy Switch should become a Hermes feature only when the local workaround is
translated into generic profile routing.

## Goal

One gateway process should receive platform messages and run each turn under
the correct Hermes profile.

Examples:

```text
Telegram DM A      -> profile: buddy-friend
Telegram group B   -> profile: buddy-work
Discord channel C  -> profile: research
/profile coder     -> bind this chat to coder
@writer draft this -> route one turn to writer
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

- Inline `@handle` routes one turn.
- `/profile @handle` binds the current chat to that route.
- `/profile default` clears the binding.
- Unknown handles fail visibly instead of falling back silently.
- Routing precedence is explicit inline handle, runtime profile binding, static
  platform route, then gateway default.

Hermes should only resolve handles listed in config. That avoids accidentally
capturing real Telegram usernames or bot mentions.

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

1. Implement `telegram.channel_profiles` for static chat-to-profile routing.
2. Add `/profile ls` and `/profile <name>` for runtime chat binding.
3. Add `profile_aliases` so `/friend` and `/work` are user-defined aliases.
4. Add configured `route_presets` or handle routes for example local `@name`
   calls.

Relevant issues:

- https://github.com/NousResearch/hermes-agent/issues/24913
- https://github.com/NousResearch/hermes-agent/issues/40173
- https://github.com/NousResearch/hermes-agent/issues/19809
