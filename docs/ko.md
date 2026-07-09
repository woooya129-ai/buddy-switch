# Buddy Switch 한국어 안내

Buddy Switch는 Hermes에서 두 개의 로컬 프로필을 쉽게 오가는 공개용 예시입니다.

- `/friend`: 가벼운 대화용 프로필
- `/work`: 파일, 검색, 터미널, 도구 작업용 프로필

현재는 Hermes quick command와 작은 전환 스크립트로 gateway를 바꾸는 우회
방식입니다. 장기 목표는 Hermes 안에서 하나의 gateway가 메시지를 알맞은
profile로 직접 routing하는 것입니다.

## 설치

가장 쉬운 설치:

```bash
curl -fsSL https://raw.githubusercontent.com/woooya129-ai/buddy-switch/main/install.sh | bash
```

설치 후 주로 만질 파일은 하나입니다:

```text
~/.config/buddy-switch/config.env
```

여기서 Hermes 프로필 이름을 본인 환경에 맞게 바꿉니다:

```bash
FRIEND_PROFILE="buddy-friend"
WORK_PROFILE="buddy-work"
```

## 어디에 설치되나요?

| 경로 | 설명 |
| --- | --- |
| `~/.local/bin/buddy-switch-friend` | `/friend`가 실행할 명령 |
| `~/.local/bin/buddy-switch-work` | `/work`가 실행할 명령 |
| `~/.local/bin/nothink_proxy.py` | 선택 설치되는 Ollama `think:false` 프록시 |
| `~/.config/buddy-switch/config.env` | 프로필 이름 등 로컬 설정 |
| `~/.local/state/buddy-switch/` | 전환 후 생기는 로그 |
| `~/.hermes/profiles/<profile>/config.yaml` | 사용자가 직접 수정할 Hermes 설정 |

Buddy Switch는 Hermes 자체, 모델, 토큰, 비밀값, 세션 DB를 설치하거나 수정하지
않습니다.

## Hermes 설정에 추가할 것

두 Hermes 프로필의 `config.yaml`에 같은 quick command를 넣습니다.

예시 경로:

```text
~/.hermes/profiles/buddy-friend/config.yaml
~/.hermes/profiles/buddy-work/config.yaml
```

추가할 내용:

```yaml
quick_commands:
  friend:
    type: exec
    command: "$HOME/.local/bin/buddy-switch-friend"
  work:
    type: exec
    command: "$HOME/.local/bin/buddy-switch-work"
```

그 다음 Hermes gateway를 재시작해 설정을 다시 읽게 합니다.

## Telegram에서 쓰는 법

```text
/friend
/work
```

전환 명령을 보낸 뒤 10-20초 정도 기다리고 다음 메시지를 보내는 흐름입니다.

## Hermes 대표 예시

Hermes에서는 `/friend`, `/work`를 내장 기능으로 박아넣지 않습니다. 로컬 quick
command로 연결합니다.

```text
/friend
  -> Hermes quick command
  -> ~/.local/bin/buddy-switch-friend
  -> hermes -p buddy-friend gateway start

/work
  -> Hermes quick command
  -> ~/.local/bin/buddy-switch-work
  -> hermes -p buddy-work gateway start
```

## OpenClaw 대표 예시

OpenClaw는 isolated agent와 routing binding을 CLI에서 직접 다루는 구조를
문서화하고 있습니다.

```bash
openclaw agents add work --workspace ~/.openclaw/workspace-work --bind telegram:*
openclaw agents bind --agent work --bind telegram:ops
openclaw agents bindings --agent work
```

Buddy Switch는 Hermes에서 비슷한 사용감을 먼저 로컬 우회로 구현한 예시입니다.
즉, 성격, 도구, 메모리, 작업 공간을 profile별로 나누고 메시지를 알맞은 쪽으로
보내자는 아이디어입니다.

## 배너 이미지가 말하는 것

대화할 때는 모에 캐릭터 탈을 쓰고, 일할 때는 로봇 본체로 돌아옵니다.

쉽게 말하면:

- 친구 모드: 귀엽고 가벼운 대화용 탈
- 작업 모드: 도구를 쓰는 컴퓨터 AI 로봇 본체
- Buddy Switch: 두 모습을 오가는 스위치

장난스러운 그림이지만 핵심은 단순합니다. 모델만 바꾸는 것이 아니라, profile
전체를 바꿔야 대화 맥락, 도구, 메모리, 작업 방식이 섞이지 않습니다.

