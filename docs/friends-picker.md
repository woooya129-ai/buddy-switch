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

## OpenClaw: An @Name Opens Another Bot Chat

OpenClaw binds each Telegram account to an isolated agent. With this example:

```text
@mika_qwen_bot  -> Mika agent using Qwen
@mika_gemma_bot -> Mika agent using Gemma
```

pressing `@mika_gemma_bot` does not mutate the Qwen bot's current chat. It opens
the Gemma bot's separate Telegram conversation. The original Qwen chat remains
Qwen.

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
