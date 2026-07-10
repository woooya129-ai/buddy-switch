# Test Plan and Implementation Guardrails

This checklist turns `upstream-design.md` into code without leaking
maintainer-specific values into Hermes.

## Naming Guard

Hermes source, config defaults, error messages, and help text must not
contain:

- maintainer profile names (`buddy-*`)
- specific model names
- `/friend` or `/work` as built-in literals

Docs and help output use neutral placeholders (`<profile-name>`,
`profile-a`). Test fixtures use neutral names (`alpha`, `beta`, `gamma`).

CI guard, fails the build on violation:

```bash
git grep -nE 'buddy-|"/friend"|"/work"' -- 'hermes_cli/' 'gateway/' \
  && { echo "FAIL: maintainer-specific name in source"; exit 1; } \
  || echo "OK: naming guard passed"
```

## Common Fixtures

- Three profiles: `alpha` (minimal tools), `beta` (full tools), `gamma`
  (custom toolset). Three, not two: two-profile setups hide "if not A then B"
  logic that breaks on the third profile.
- At least two providers mixed across profiles (an OpenAI-compatible local
  mock plus a second API mock), so provider dispatch can be asserted per
  profile.
- A platform event generator producing `chat_id` / `thread_id` / `user_id`.

## Test Matrix

Stages follow the PR plan in `upstream-design.md`.

### Stage 1: `channel_profiles` (static routing)

| # | Case | Expected |
| --- | --- | --- |
| 1 | Mapped chat | Message in a mapped chat runs under that profile |
| 2 | Unmapped chat | Falls back to the gateway launch profile |
| 3 | Route to missing profile | Config load fails with a clear message |
| 4 | Session isolation | Session key includes profile; `alpha` history never leaks into `beta` in the same chat |
| 5 | Single polling | One bot token, one poller, regardless of profile count |

### Stage 2: `/profile` (runtime binding)

| # | Case | Expected |
| --- | --- | --- |
| 6 | `/profile` | Shows the active profile for the current chat |
| 7 | `/profile ls` | Lists all three fixture profiles |
| 8 | `/profile beta` | Next turn runs under `beta` |
| 9 | `/profile default` | Clears the binding back to the launch profile |
| 10 | Unknown name | Visible error, binding unchanged |
| 11 | No restart | Gateway pid identical before and after a switch |

### Stage 3: `profile_aliases`

| # | Case | Expected |
| --- | --- | --- |
| 12 | Defined alias | Resolves to its target profile |
| 13 | Alias to missing profile | Config load fails with a clear message |
| 14 | Duplicate alias | Config load fails |

### Stage 4: handle routes (`route_presets`)

| # | Case | Expected |
| --- | --- | --- |
| 15 | Bare `@handle` message | Persistently re-routes the current chat; next `/friends` shows the new name and model |
| 16 | `/profile @handle` | Equivalent explicit form of the same chat binding |
| 17 | Unknown or embedded handle, or `@...bot` | Stays a normal message; never captured as a route |
| 18 | Precedence | Runtime chat binding > static route > gateway default |
| 18b | `/friends` after `@handle` and gateway restart | Still shows the switched model (persisted override is rehydrated) |

### Cross-cutting

| # | Case | Expected |
| --- | --- | --- |
| 19 | Multi-provider dispatch | `alpha` and `beta` requests hit their own provider mock endpoints |
| 20 | Switch loop stability | Repeated switching never enters a restart/SIGTERM loop ([#29092](https://github.com/NousResearch/hermes-agent/issues/29092)) |
| 21 | Forum-topic delivery | Inbound topic messages are not silently dropped while routing is active ([#52635](https://github.com/NousResearch/hermes-agent/issues/52635)) |
| 22 | Profile home isolation | Scheduled/cron work never falls back to the default Hermes home ([#4707](https://github.com/NousResearch/hermes-agent/issues/4707)) |

### Status and picker UX

| # | Case | Expected |
| --- | --- | --- |
| 23 | Standalone route requested | Immediate output says `SWITCHING`, never `ACTIVE` |
| 24 | Gateway start succeeds | `/friends` shows the target as the last confirmed route with `ACTIVE` |
| 25 | Gateway start fails | `/friends` shows `FAILED` and keeps the prior confirmed route |
| 26 | Duplicate route press | A second press is rejected while a switch lock exists |
| 27 | Hermes picker current state | Header shows live profile, personality, provider, model, and `ACTIVE IN THIS CHAT` |
| 28 | OpenClaw account link | Source chat stays unchanged; destination bot marks only its own account as `THIS CHAT` |
| 29 | Route button label | A configured target is visible as `Name | Model` before selection |

## Config Validation

When loading `channel_profiles`, `profile_aliases`, or `route_presets`:

- Unknown keys produce a warning, not a failure, for forward compatibility.
- Duplicate aliases or routes pointing at missing profiles fail the load with
  a clear message.
- Routing precedence is fixed and documented: runtime chat binding (including
  a bare `@handle` switch), then static platform route, then gateway default.

## Definition of Done

| Stage | Complete when |
| --- | --- |
| 1. `channel_profiles` | Cases 1-5 pass and the naming guard is in CI |
| 2. `/profile` | Cases 6-11 pass |
| 3. `profile_aliases` | Cases 12-14 pass |
| 4. Handle routes | Cases 15-18 pass |
| Release | Cross-cutting cases 19-22 pass |
