# Finding Friends and Routes

People should not need to memorize profile ids, model ids, or router names.
Buddy Switch uses one discovery command everywhere:

```text
/friends
```

The names and personalities shown below are examples. This repository does not
ship five completed personas.

## Telegram

The Buddy Switch Hermes fork presents a mobile-first picker:

1. The first screen shows the current profile, personality, provider, and model.
2. **Personality** opens configured `/personality` choices.
3. **Model** opens Hermes's existing provider/model picker.
4. **Routes** shows only quick commands marked `category: route`.
5. Tapping a choice applies it and returns a visible confirmation.

The picker does not ask users to type model ids into a terminal-like form. When
buttons are unavailable, it degrades to a short list with exact slash commands.

Recommended route metadata:

```yaml
quick_commands:
  friend:
    type: exec
    command: "$HOME/.local/bin/buddy-switch-friend"
    category: route
    label: "Friend"
    description: "Light chat profile"
```

The `label` is shown on the button. The command key remains the typed fallback,
so this example is still available as `/friend`.

## Terminal

The standalone installation provides a no-network catalog:

```bash
buddy-switch-routes
```

It reads the protected Buddy Switch config and reports the last successful
route, profile, model hint, SOUL draft path, and exact switch commands.

The Hermes fork also accepts:

```text
/friends
/friends personality <name>
/friends model <provider/model>
/friends route <name>
```

## OpenClaw

OpenClaw routes Telegram accounts to isolated agents. Each agent already owns
the pieces Buddy Switch calls a friend: workspace/SOUL, model, tools, memory,
and identity.

The OpenClaw fork's `/friends` command shows the current agent and model, then
lists configured Telegram account bindings. For an account to become a direct
Telegram button, set its display `name` to the bot's real `@username`:

```json5
channels: {
  telegram: {
    accounts: {
      friend: { name: "@mika_chat_bot" },
      work: { name: "@mika_work_bot" },
    },
  },
}
```

Use `Persona - Role` as the human-facing label. Real Telegram bot usernames do
not allow hyphens, so the equivalent callable name is
`@<persona>_<role>_bot`, subject to Telegram's availability and naming rules.

## Five Supported Variations

These are configuration patterns, not bundled personalities:

| Variation | How to configure it |
| --- | --- |
| Model + personality | Route to a complete profile/agent preset |
| Fixed model + changed personality | Two personas share the same model |
| Changed model + fixed personality | Keep the SOUL, select another model |
| Fixed model + fixed personality | Stay on the current route |
| Changed model + changed personality | Route to another complete preset |

The picker exposes the axes separately so users can choose only what they mean
to change.
