# Buddy Switch 한국어 안내

[English canonical README](../../README.md) · [성격 및 언어 설정](../personas.md)

Buddy Switch는 같은 Telegram 화면에서 Hermes 프로필을 바꾸는 공개 예시입니다.
`/friend`는 가벼운 대화용, `/work`는 파일·검색·도구 작업용 프로필로 전환합니다.

## 설치

먼저 Hermes를 설치하고 프로필을 만듭니다.

```bash
hermes profile create buddy-friend --no-skills
hermes profile create buddy-work
```

그다음 Buddy Switch를 설치합니다.

```bash
curl -fsSL https://raw.githubusercontent.com/woooya129-ai/buddy-switch/main/install.sh | bash
```

![터미널에서 실행 중인 Buddy Switch 설치기](../../assets/buddy-switch-screenshot.png)

진행 막대가 끝나면 터미널 캐릭터의 눈이 열리고 첫 설정이 시작됩니다. 프로필
이름과 기본 응답 언어를 고르면 아래 위치에 수정 가능한 SOUL 초안이 생깁니다.

```text
~/.config/buddy-switch/personas/<프로필 이름>/SOUL.md
```

기존 Hermes `SOUL.md`는 자동으로 덮어쓰지 않습니다. 초안을 검토한 뒤 직접
합치거나 옮기세요.

## Hermes 설정

두 프로필의 `config.yaml`에 같은 quick command를 넣습니다.

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
  work:
    type: exec
    command: "$HOME/.local/bin/buddy-switch-work"
    category: route
    label: "업무"
```

gateway를 재시작한 뒤 Telegram에서 `/friends`를 보내면 현재 프로필, 성격,
모델과 선택 가능한 라우터를 확인할 수 있습니다. 기본 Hermes에서는 짧은 텍스트
목록으로 보이고 Buddy Switch Hermes 포크에서는 버튼으로 보입니다. `/friend`
또는 `/work`를 고른 뒤 10~20초 후 다음 메시지를 보냅니다.

터미널에서는 아래 명령 하나로 외우기 어려운 라우터를 다시 찾습니다.

```bash
buddy-switch-routes
```

OpenClaw에서는 agent 하나가 SOUL·모델·작업공간을 묶은 친구 역할을 합니다.
Telegram account의 표시 이름을 실제 봇 사용자명인 `@이름_역할_bot` 형태로 두고
agent에 binding하면, OpenClaw 포크의 `/friends`가 해당 봇으로 바로 가는 버튼을
표시합니다. Telegram 사용자명에는 하이픈을 쓸 수 없으므로 실제 호출명은
언더스코어를 쓰고, 화면의 설명은 `이름 - 역할`처럼 읽기 좋게 적습니다. 이는
예시 작명 규칙이며 완성된 성격을 배포한다는 뜻은 아닙니다.

## 성격과 언어

응답 언어는 Buddy Switch 설정이 아니라 각 프로필의 `SOUL.md` 언어 정책으로
정합니다. 해당 언어를 잘하는 모델을 함께 선택해야 안정적입니다. 언어 혼입이
계속될 때만 모델을 바꾸거나 provider의 `top_p` 등을 조금 조정해 시험하세요.

Hermes는 에이전트나 세션 동안 시스템 프롬프트를 보관할 수 있습니다. SOUL을
고친 뒤 반영되지 않으면 새 세션을 시작하거나 해당 gateway를 재시작하세요.

## 예시와 보안

그림과 `@mika`, `@forge` 같은 이름은 라우팅 예시일 뿐 완성된 성격 5개가
포함된 것이 아닙니다. 공개할 때 토큰, chat/user ID, 개인 경로, 로그, state DB,
대화 기록, 개인 SOUL 원본을 절대 커밋하지 마세요. Telegram 허용 목록도 실제
ID가 없는 placeholder로 공유하세요.
