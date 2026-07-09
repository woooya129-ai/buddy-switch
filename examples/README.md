# Examples

These examples are templates. Replace profile names, model names, paths, ports,
and platform IDs before use.

For normal use, start with the installer in the root README or
`docs/install.md`; copy these examples manually only when you want to customize
the setup.

_한국어: 일반 설치는 루트 README의 installer를 먼저 쓰세요. 이 폴더는 직접
수정해서 쓰고 싶은 사람을 위한 템플릿 모음입니다._

## Files

- `hermes/config.example.yaml`: quick commands, aliases, and future routing
  examples.
- `hermes/friend-profile.config.yaml`: minimal friend-profile shape.
- `hermes/work-profile.config.yaml`: minimal work-profile shape.
- `scripts/buddy-switch-friend`: local fallback script for `/friend`.
- `scripts/buddy-switch-work`: local fallback script for `/work`.
- `launchd/hermes-gateway-profile.plist.template`: macOS launchd profile
  gateway template.
- `ollama/nothink_proxy.py`: optional OpenAI-compatible proxy that forwards to
  Ollama `/api/chat` with `think:false`.

Do not commit live `.env` files, logs, state databases, or session directories.
