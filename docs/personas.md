# Personas and Response Languages

Buddy Switch treats a profile as a complete boundary: model, SOUL, tools,
memory, sessions, and workspace. A persona is primarily written in that
profile's `SOUL.md`; routing only decides which profile receives the turn.

This repository does not ship five finished personalities. Its route names,
characters, and persona labels are examples.

## Start with the Setup Wizard

Run:

```bash
buddy-switch-init
```

The wizard asks for friend and work profile names plus a response language. It
creates safe drafts under:

```text
~/.config/buddy-switch/personas/<profile-name>/SOUL.md
```

It never overwrites a live Hermes `SOUL.md`. Review the drafts before placing
them in `~/.hermes/profiles/<profile-name>/SOUL.md`.

## Minimal Persona Shape

```markdown
# SOUL

## Role

You are a focused research assistant.

## Interaction Style

- Lead with the answer.
- Separate facts from uncertainty.
- Ask before destructive or externally visible actions.

## Language Policy

- Respond in natural, idiomatic <LANGUAGE> by default.
- Do not mix unrelated languages unless the user asks.
- Keep code, commands, names, and quotations in their original form when useful.
- Follow the user's latest clear language request.
```

Replace `<LANGUAGE>` with a language such as English, Korean, Japanese, or
Spanish. Keep the policy short and unambiguous.

## Korean Language Policy Example

```markdown
## Language Policy

- 기본 응답은 자연스럽고 관용적인 한국어로 작성한다.
- 사용자가 요청하지 않으면 중국어를 비롯한 다른 언어를 섞지 않는다.
- 코드, 명령어, 고유명사, 인용문은 필요할 때 원문을 유지한다.
- 사용자가 다른 언어를 명확히 요청하면 가장 최근 요청을 따른다.
```

## Model Choice Still Matters

A SOUL rule cannot create language ability the model does not have. Test the
selected model with casual dialogue, long answers, tool summaries, and proper
nouns in the target language. A smaller model with strong language coverage can
be more stable than a larger model with weaker coverage.

If a model keeps mixing languages, first strengthen the SOUL rule and try a
better-suited model. Only then test provider-specific sampling controls such as
a slightly lower `top_p`. Sampling changes can reduce variation, but they are
not a substitute for language capability and can make prose repetitive.

## When Changes Take Effect

Hermes reads SOUL content while building the agent's system prompt and may
cache that prompt for the agent or session. If an edit does not appear in the
next reply, start a new session or restart the relevant gateway. Do not promise
that every Hermes version reloads `SOUL.md` on every message.

## Safe Sharing

Share reusable structure, not private identity history. Remove personal names,
private relationship details, chat transcripts, memories, tokens, IDs, local
paths, logs, and state databases before publishing a persona example.
