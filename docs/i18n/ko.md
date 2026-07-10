# Buddy Switch 한국어 안내

[English canonical README](../../README.md) ·
[상세 설치 문서](../install.md) ·
[모델 ID 선택법](../model-selection.md) ·
[성격 및 언어 설정](../personas.md)

Buddy Switch는 같은 컴퓨터에서 친구용 AI와 업무용 AI를 쉽게 바꾸는 공개
예시입니다. Hermes에서는 `/friend`와 `/work`로 프로필 전체를 바꾸고,
OpenClaw에서는 Telegram 계정에 연결된 agent를 골라 같은 구조를 만듭니다.

## 먼저 답: 설치만 하면 자동으로 적용되나요?

**아니요. 최초 1회 연결 설정이 필요합니다.** Buddy Switch 설치기는 아래
도우미와 SOUL 초안만 안전하게 설치합니다. 실제 Hermes/OpenClaw 설정에는 모델,
봇 토큰, 사용자 ID, 개인 성격이 들어 있으므로 자동으로 수정하지 않습니다.

| 항목 | 자동 설치 | 처음 한 번 직접 할 일 |
| --- | --- | --- |
| Buddy Switch 명령어 | 예 | 없음 |
| 로컬 설정 파일 | 예 | 프로필 이름과 모델 힌트 확인 |
| SOUL 성격 초안 | 예 | 읽고 실제 프로필/작업공간에 반영 |
| Ollama 모델 | 아니요 | 정확한 모델 태그 설치 및 테스트 |
| Hermes 프로필·모델·Telegram | 아니요 | 프로필별로 설정하고 quick command 추가 |
| OpenClaw agent·Telegram binding | 아니요 | agent와 Telegram account를 연결 |

이 1회 연결을 마치면 그다음부터는 자동입니다. Hermes 프로필을 시작하면 그
프로필의 모델·SOUL·도구·Telegram 설정을 읽고, OpenClaw gateway를 시작하면
저장된 agent와 binding을 읽습니다. Buddy Switch는 이미 설정된 대상을 고를 뿐,
전환 순간에 모델 이름을 추측하거나 새로 정하지 않습니다.

## 설치

```bash
curl -fsSL https://raw.githubusercontent.com/woooya129-ai/buddy-switch/main/install.sh | bash
```

![터미널에서 실행 중인 Buddy Switch 설치기](../../assets/buddy-switch-screenshot.png)

진행 막대가 끝나면 터미널 캐릭터의 눈이 열리고 첫 설정이 시작됩니다. 프로필
이름과 기본 응답 언어를 고르면 아래 위치에 수정 가능한 SOUL 초안이 생깁니다.

```text
~/.config/buddy-switch/personas/<프로필 이름>/SOUL.md
```

기존 Hermes `SOUL.md`는 절대로 자동 덮어쓰기하지 않습니다.

## 이름 세 종류를 구분하세요

라우터 이름과 모델 이름은 서로 다릅니다.

| 종류 | 예시 | 뜻 |
| --- | --- | --- |
| 라우터 명령 | `friend` | `/friend`가 실행할 전환 이름 |
| Hermes 프로필 | `buddy-friend` | 모델·성격·도구·메모리를 가진 실제 단위 |
| Ollama 모델군 | `gemma4` | 기억하기 쉬운 기본 별칭; 대상이 바뀔 수 있음 |
| 정확한 Ollama ID | `gemma4:e4b` | `ollama list`에서 그대로 복사할 이름 |
| OpenClaw 모델 ID | `ollama/gemma4:e4b` | provider까지 포함한 정확한 이름 |

`~/.config/buddy-switch/config.env`의 `FRIEND_MODEL`과 `WORK_MODEL`은
`/friends`에 표시하고 반대편 Ollama 모델을 내릴 때 쓰는 **힌트**입니다. 이
값만 적는다고 Hermes의 실제 모델이 바뀌지는 않습니다.

## Gemma 4가 여러 개인데 무엇을 고르나요?

먼저 이 컴퓨터에 설치된 정확한 이름을 확인합니다.

```bash
ollama list
```

`NAME` 열의 값을 `:태그`까지 그대로 복사하세요. 설치된 것이 없다면 예를 들어:

```bash
ollama pull gemma4:e4b
ollama show gemma4:e4b
ollama run gemma4:e4b "정확히 '모델 준비 완료'라고 답해"
```

Ollama 공식 목록을 기준으로 한 대표 예시는 다음과 같습니다. 목록은 바뀔 수
있으므로 실제 설치 전에는 [Gemma 4 tags](https://ollama.com/library/gemma4/tags)를
다시 확인하세요.

| 정확한 모델 ID | 공개 용량 | 문맥 | 초보자용 해석 |
| --- | ---: | ---: | --- |
| `gemma4:e2b` | 7.2 GB | 128K | 이 표에서 가장 가벼운 시작점 |
| `gemma4:e4b` | 9.6 GB | 128K | 일반 로컬 대화용 시작점 |
| `gemma4:12b` | 7.6 GB | 256K | 공개 빌드가 비교적 작고 문맥이 김 |
| `gemma4:26b` | 18 GB | 256K | 메모리가 더 있을 때 쓰는 큰 MoE 모델 |
| `gemma4:31b` | 20 GB | 256K | 이 표의 기본 모델 중 가장 큰 선택지 |

파일 용량과 필요한 RAM은 같지 않습니다. 긴 문맥, 양자화, 다른 앱 사용량에 따라
메모리가 더 필요합니다. 아래 순서로 고르면 됩니다.

1. `ollama list` 또는 provider 목록에 실제로 있는 정확한 이름인가?
2. 업무용이면 파일·터미널 같은 **실제 도구 호출**이 성공하는가?
3. 내 컴퓨터에서 메모리 부족이나 과도한 지연 없이 도는가?
4. 필요한 문맥 길이, 이미지 입력, 응답 언어를 지원하는가?
5. 안정적으로 재현하려면 `gemma4` 대신 `gemma4:e4b`처럼 태그를 고정했는가?

## Hermes 처음 한 번 연결하기

### 1. 프로필 만들기

Hermes를 먼저 설치한 뒤 실행합니다.

```bash
hermes profile create buddy-friend
hermes profile create buddy-work
hermes profile list
```

### 2. 실제 모델 설정하기

```bash
hermes -p buddy-friend model
hermes -p buddy-work model
```

로컬 Ollama라면 custom endpoint에 `http://127.0.0.1:11434/v1`을 넣고,
`ollama list`에서 복사한 `gemma4:e4b` 같은 정확한 이름을 고릅니다. 친구와
업무 프로필은 같은 모델을 써도 되고 서로 다른 태그를 써도 됩니다.

### 3. Buddy Switch 설정 확인하기

```bash
nano ~/.config/buddy-switch/config.env
```

예시:

```bash
FRIEND_PROFILE="buddy-friend"
WORK_PROFILE="buddy-work"
FRIEND_NAME="미카 대화"
WORK_NAME="미카 업무"
FRIEND_MODEL="gemma4:e4b"
WORK_MODEL="gemma4:31b"
FRIEND_PERSONA_NAME="따뜻함"
WORK_PERSONA_NAME="집중형"
```

마지막 두 줄은 표시/메모리 정리용 힌트이며, 실제 모델은 바로 앞 단계에서 Hermes
프로필에 저장한 값입니다.

### 4. SOUL과 quick command 연결하기

SOUL 초안을 검토해 각 프로필의 `SOUL.md`에 합친 뒤, 두 프로필의
`config.yaml`에 같은 블록을 넣습니다.

```yaml
quick_commands:
  friends:
    type: exec
    command: "$HOME/.local/bin/buddy-switch-routes"
    category: catalog
    label: "친구 선택"
  friend:
    type: exec
    command: "$HOME/.local/bin/buddy-switch-friend"
    category: route
    label: "친구"
    profile: buddy-friend
    model: "gemma4:e4b"
    personality: "따뜻함"
  work:
    type: exec
    command: "$HOME/.local/bin/buddy-switch-work"
    category: route
    label: "업무"
    profile: buddy-work
    model: "gemma4:31b"
    personality: "집중형"
```

Telegram 토큰과 허용 목록도 각 프로필에 1회 설정합니다. 같은 봇 토큰을 두
프로필이 공유한다면 gateway 두 개를 동시에 실행하지 마세요. Buddy Switch가
전환할 때 반대편 gateway를 먼저 멈춥니다.

설정을 바꾼 뒤 활성 gateway를 다시 읽힙니다.

```bash
hermes -p buddy-friend gateway restart
```

관리형 gateway가 아직 없다면 Hermes 공식 gateway 설정에서 서비스를 먼저
설치해야 `buddy-switch-friend`와 `buddy-switch-work`가 시작할 수 있습니다.

## OpenClaw 처음 한 번 연결하기

Buddy Switch 설치기가 OpenClaw를 자동 수정하지는 않습니다. OpenClaw에서는
기본 기능인 agent와 Telegram account binding으로 같은 구조를 만듭니다.

```bash
openclaw onboard
openclaw models list --provider ollama
openclaw models status
```

Telegram account ID `friend`, `work`를 먼저 만든 다음 agent를 연결하는 예시:

```bash
openclaw agents add friend \
  --workspace ~/.openclaw/workspace-friend \
  --model ollama/gemma4:e4b \
  --bind telegram:friend

openclaw agents add work \
  --workspace ~/.openclaw/workspace-work \
  --model ollama/gemma4:31b \
  --bind telegram:work

openclaw agents list --bindings
openclaw gateway install
openclaw gateway start
```

실제 `@이름` 두 개로 부르고 싶다면 Telegram 봇 계정도 두 개 만들고 각 account를
서로 다른 agent에 연결합니다. 설정을 저장한 뒤부터는 OpenClaw gateway를 켤 때
agent와 binding이 자동으로 로드됩니다.

여기서 `@이름_qwen_bot`과 `@이름_gemma_bot`은 같은 대화방의 모델 전환 버튼이
아닙니다. 각각 별도의 Telegram 봇 대화방입니다. Gemma 버튼을 누르면 기존 Qwen
대화가 바뀌는 것이 아니라 Gemma agent 대화방이 열립니다. 이동한 봇에서
`/friends`를 다시 실행해 `THIS CHAT` 이름·agent·모델을 확인해야 합니다.

## 터미널 명령어 표

터미널은 설치, 모델 찾기, 1회 설정, 직접 전환에 사용합니다.

| 하고 싶은 일 | 명령어 | 결과 |
| --- | --- | --- |
| 설치된 Ollama 모델 보기 | `ollama list` | 읽기 전용; 정확한 `NAME` 확인 |
| 모델 상세 확인 | `ollama show gemma4:e4b` | 읽기 전용 |
| 모델 직접 시험 | `ollama run gemma4:e4b` | 로컬 모델 대화 시작 |
| Hermes 프로필 보기 | `hermes profile list` | 읽기 전용 |
| 친구 프로필 모델 설정 | `hermes -p buddy-friend model` | 해당 프로필에 저장 |
| 업무 프로필 모델 설정 | `hermes -p buddy-work model` | 해당 프로필에 저장 |
| 라우터·성격·모델 힌트 보기 | `buddy-switch-routes` | 읽기 전용 |
| 친구 모드로 전환 | `buddy-switch-friend` | friend gateway 시작 |
| 업무 모드로 전환 | `buddy-switch-work` | work gateway 시작 |
| OpenClaw 모델 보기 | `openclaw models list --provider ollama` | 읽기 전용 |
| OpenClaw binding 보기 | `openclaw agents list --bindings` | 읽기 전용 |
| OpenClaw 상태 보기 | `openclaw gateway status` | 읽기 전용 |

## Telegram 명령어 표

Telegram은 1회 터미널 연결을 마친 뒤 일상적으로 선택할 때 사용합니다.
`ollama list` 같은 터미널 명령을 Telegram에 보내는 방식이 아닙니다.

| 하고 싶은 일 | Hermes + Buddy Switch | 기본 OpenClaw |
| --- | --- | --- |
| 지금 누구·성격·모델인지 확인 | `/friends`; 반드시 `ACTIVE` 확인 | 기본은 `/model status`; Buddy 포크는 현재 봇에서 `/friends` |
| 성격+모델+도구를 친구용으로 전환 | `/friend` 후 `/friends` 재확인 | friend agent 봇 열기; 별도 대화방임 |
| 성격+모델+도구를 업무용으로 전환 | `/work` 후 `/friends` 재확인 | work agent 봇 열기; 별도 대화방임 |
| 설정된 모델 목록 열기 | `/model` | `/model` 또는 `/model list` |
| 번호로 모델 선택 | Hermes에 표시된 picker 사용 | `/model <번호>` |
| 임시 모델 선택 해제 | 원하는 프로필을 다시 시작 | `/model default` |
| 현재 모델 확인 | Hermes 포크는 실시간, standalone은 확정 route+모델 힌트 | 해당 봇의 `/friends` 또는 `/model status` |

중요한 차이: `/friend`와 `/work`는 프로필 전체를 바꾸므로 모델·SOUL·도구·메모리가
함께 바뀝니다. `/model`은 모델만 바꾸며 성격과 작업공간은 바꾸지 않습니다.

## 완료 확인

Hermes:

```bash
ollama list
hermes profile list
buddy-switch-routes
```

그다음 Telegram에서 `/friends` → `/friend` → 10~20초 대기 → `/friends`
순서로 시험합니다. 처음 받은 `SWITCHING`은 요청 접수일 뿐 성공이 아닙니다.
두 번째 화면이 `ACTIVE`이고 이름·프로필·모델·성격이 목표와 같을 때만 전환이
완료된 것입니다. `/work`도 같은 순서로 확인합니다.

OpenClaw:

```bash
openclaw models status
openclaw agents list --bindings
openclaw gateway status
```

각 Telegram 봇에 메시지를 보내 둘 다 답하면 account·agent·model·gateway가
정상 연결된 것입니다.

## 성격·언어·보안

응답 언어는 Buddy Switch 설정이 아니라 각 프로필의 `SOUL.md` 언어 정책으로
정합니다. 해당 언어를 잘하는 모델을 함께 선택해야 안정적입니다. SOUL을 고친 뒤
반영되지 않으면 새 세션을 시작하거나 gateway를 재시작하세요.

그림과 이름, Gemma 4 조합은 모두 **예시**입니다. 완성된 성격 5개를 배포하는
것이 아닙니다. 토큰, chat/user ID, 개인 경로, 로그, state DB, 대화 기록, 개인
SOUL 원본을 GitHub에 올리지 마세요.
