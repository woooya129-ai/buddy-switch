# Finding Friends and Confirming Routes

People should not need to memorize profile IDs, model IDs, or router names.
Buddy Switch uses one status command everywhere:

```text
/friends
```

The names, models, and personalities below are examples. This repository does
not ship finished private personas.

## Read the First Block Before Pressing Anything

`/friends` starts with a `YOU ARE TALKING TO` block:

```text
Status: ACTIVE IN THIS CHAT
Name: Mika
Profile or agent: buddy-work
Personality: focused
Model: ollama/gemma4:31b
```

That block is the answer to "who am I talking to now?" The route list below it
only shows possible destinations.

## Hermes: A Route Switch Has Two Phases

`/friend` and `/work` restart the selected Hermes profile gateway. The first
reply is a request, not proof:

```text
Status: SWITCHING (not confirmed yet)
```

Wait 10-20 seconds, then run `/friends` again:

- `ACTIVE`: the gateway start command succeeded and the shown route is the last
  confirmed route.
- `SWITCHING`: the change is still pending.
- `FAILED`: the requested target did not start; the screen keeps showing the
  last confirmed route.
- `UNKNOWN`: no verified standalone switch has been recorded yet.

The Hermes picker reads the live profile, personality, provider, and
session-scoped model. The standalone `buddy-switch-routes` command reads the
last confirmed gateway route plus configured Buddy model/personality labels.

Recommended route metadata lets the button show what it will select:

```yaml
quick_commands:
  work:
    type: exec
    command: "$HOME/.local/bin/buddy-switch-work"
    category: route
    label: "Work"
    description: "Tool-enabled work profile"
    profile: buddy-work
    model: "gemma4:31b"
    personality: "focused"
```

The Telegram route button becomes `Work | gemma4:31b`. The command remains
available as `/work` and `/friends route work`.

## Hermes: `@name_model` Switches This Chat

`@name_model` handles such as `@mika_qwen` and `@mika_gemma` are local routing
aliases, not Telegram bot accounts. Sending one as the entire message
persistently re-routes the **current** chat; no other conversation opens:

```text
@mika_qwen  -> this chat becomes Mika + Qwen (persistent)
@mika_gemma -> this chat becomes Mika + Gemma (persistent)
```

Each handle is a `category: route` quick command. A model alias targets a
session-scoped model switch so only this chat changes:

```yaml
quick_commands:
  mika_gemma:
    type: alias
    category: route
    label: "Mika + Gemma"
    target: "model ollama/gemma4:e4b --session"
```

After sending `@mika_gemma`, run `/friends` again. The `YOU ARE TALKING TO`
block must show the new model for this chat — if it still shows the previous
model, that is a bug, not the expected behavior. (The fork once showed the
previous model after a gateway restart because `/friends` read only the
in-memory override; it now rehydrates the persisted per-chat override first.)

Handles that end in `bot`, sit inside a longer message, or are not configured
as routes are never captured; they remain normal messages.

## OpenClaw Multi-Bot: A Real `@botusername` Opens Another Bot Chat

This separate-chat behavior belongs **only** to the OpenClaw multi-bot
approach, where each real Telegram `@botusername` is its own bot account.
OpenClaw binds each Telegram account to an isolated agent. With this example:

```text
@mika_qwen_bot  -> Mika agent using Qwen
@mika_gemma_bot -> Mika agent using Gemma
```

pressing `@mika_gemma_bot` does not mutate the Qwen bot's current chat. It opens
the Gemma bot's separate Telegram conversation. The original Qwen chat remains
Qwen. Do not confuse these real `_bot` usernames with the same-chat
`@name_model` aliases above.

The OpenClaw picker therefore:

1. marks only the current bot/account as `THIS CHAT`;
2. shows that bot's live agent, personality description, and model;
3. labels destination buttons as `Name | Model`;
4. tells the user to run `/friends` in the destination bot after opening it.

`/models` changes only the model in the current OpenClaw chat. Opening another
bot changes the whole agent boundary: identity/SOUL, model, tools, memory, and
workspace.

## Terminal

```bash
buddy-switch-routes
```

The standalone output shows:

- the last confirmed route;
- friendly name, profile, model hint, and personality label;
- `ACTIVE`, `SWITCHING`, `FAILED`, or `UNKNOWN`;
- the last state-change time;
- exact `/friend` and `/work` choices.

The Hermes fork CLI also accepts:

```text
/friends
/friends personality <name>
/friends model <provider/model>
/friends route <name>
```

Always run `/friends` again after changing anything. The new status block is
the confirmation; the button press by itself is not.

## Five Supported Variations

These are configuration patterns, not bundled personalities:

| Variation | How to configure it |
| --- | --- |
| Model + personality | Route to a complete profile/agent preset |
| Fixed model + changed personality | Two personas share the same model |
| Changed model + fixed personality | Keep the SOUL, select another model |
| Fixed model + fixed personality | Stay on the current route |
| Changed model + changed personality | Route to another complete preset |
