# Current Workaround

Buddy Switch currently works by using Hermes quick commands to run small shell
scripts from Telegram.

## Flow

```text
Telegram command
  /friend
    -> Hermes quick command
    -> buddy-switch-friend
    -> ensure Ollama and optional no-think proxy
    -> stop work profile gateway
    -> start friend profile gateway

  /work
    -> Hermes quick command
    -> buddy-switch-work
    -> ensure Ollama
    -> stop friend profile gateway
    -> start work profile gateway
```

## Why It Works

Each Hermes profile has its own:

- config
- model endpoint
- SOUL/persona
- memory
- session database
- enabled tools and skills

Switching the active gateway moves Telegram traffic to the selected profile, so
friend chat and work tasks do not share the same model, memory, or tool surface.

## Example Quick Commands

Put this in both profile configs, adjusting paths if needed:

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
  work:
    type: exec
    command: "$HOME/.local/bin/buddy-switch-work"
    category: route
    label: "Work"
```

`/friends` is read-only on the standalone workaround. It reports the current
route and gives users the exact switch commands, so route names do not need to
be memorized. The Hermes fork recognizes the metadata and renders native
Telegram selection buttons.

## Tradeoffs

This approach is a good local fallback, but it has limits:

- It restarts gateway processes, so the next reply may need 10-20 seconds.
- It is tied to local service management.
- It cannot serve multiple chats with different profiles at the same time.
- It is not the right shape for an upstream Hermes PR.

The upstream version should route messages to a selected profile inside one
gateway process.

## Workaround-to-Upstream Mapping

Each workaround step has a cleaner upstream replacement:

| Workaround step | Problem | Upstream replacement |
| --- | --- | --- |
| Quick command runs a shell script | Shell and local-path dependent | Router resolves the command inside the gateway |
| Stop one gateway, start another | 10-20 second gap, pid/service races | In-process profile context switch, no restart |
| One service (launchd/systemd) per profile | Two services to manage, state can drift | One gateway process serving all profiles |
| `/friend` and `/work` as local names | Reads like a built-in, but is not | User-defined `profile_aliases` |
