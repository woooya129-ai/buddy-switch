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

## 모델과 성격 조합

Buddy Switch는 모델과 성격을 따로 생각합니다. 그래서 아래 조합을 모두 표현할
수 있습니다.

| 조합 | 의미 |
| --- | --- |
| 모델 + 성격 | 완성된 프리셋을 한 번에 선택 |
| 모델 고정 + 성격 변경 | 같은 모델로 말투와 성격만 변경 |
| 모델 변경 + 성격 고정 | 같은 캐릭터 성격으로 더 강한 모델 사용 |
| 모델 고정 + 성격 고정 | 안정적인 기본값 유지 |
| 모델 변경 + 성격 변경 | 모드 전체를 변경 |

그림에서는 따뜻한 붉은 계열은 모에 캐릭터 성격 바리에이션, 푸른 계열은 작업용
AI 모델 바리에이션으로 표현했습니다. 핵심은 두 축을 섞어 쓸 수 있다는 점입니다.

## Telegram `@이름` 호출 아이디어

나중에 Hermes upstream 기능으로 넣고 싶은 방식은 실제 사람을 부르는 느낌의
로컬 핸들입니다. 별도 Telegram 계정을 만드는 것이 아니라 gateway가 설정된
이름만 인식합니다.

```text
@mika        -> 성격 route
@forge       -> 모델 route
@mika-forge  -> 모델 + 성격 route
```

예시:

```text
@mika 이거 부드럽게 설명해줘
@forge 로그 확인해줘
@mika-forge 사람에게 공유할 요약으로 바꿔줘
```

권장 동작은 다음과 같습니다.

1. 메시지 앞의 `@이름`은 한 번만 그 route로 보냅니다.
2. `/profile @이름`은 현재 채팅방을 그 route에 묶습니다.
3. `/profile default`는 기본 gateway 설정으로 되돌립니다.

현재 공개 v1에서는 이 기능이 아직 Hermes에 들어간 것이 아니므로 `/friend`,
`/work` 우회 방식을 사용합니다.

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
