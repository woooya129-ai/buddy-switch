# Install Buddy Switch

Buddy Switch is designed to be installed as a small set of local helper scripts.
It does not install Hermes, create profiles for you, or touch live credentials.

_한국어: Buddy Switch는 Hermes 자체를 설치하거나 비밀값을 만지지 않습니다.
로컬 전환 스크립트와 설정 파일만 설치합니다._

## One-Line Install

```bash
curl -fsSL https://raw.githubusercontent.com/woooya129-ai/buddy-switch/main/install.sh | bash
```

Installed files:

```text
~/.local/bin/buddy-switch-friend
~/.local/bin/buddy-switch-work
~/.local/bin/nothink_proxy.py
~/.config/buddy-switch/config.env
```

_한국어: 설치 후 실제로 자주 만질 파일은
`~/.config/buddy-switch/config.env` 하나입니다._

## Configure Profiles

Edit the config file:

```bash
nano ~/.config/buddy-switch/config.env
```

Default profile names:

```bash
FRIEND_PROFILE="buddy-friend"
WORK_PROFILE="buddy-work"
```

If your Hermes profiles use different names, change only these values first.

_한국어: Hermes 프로필 이름이 다르면 여기서 `FRIEND_PROFILE`,
`WORK_PROFILE`만 바꾸면 됩니다._

Optional model names:

```bash
FRIEND_MODEL=""
WORK_MODEL=""
```

When set, Buddy Switch tries to unload the opposite Ollama model while
switching modes.

## Add Hermes Quick Commands

Add this block to both Hermes profile configs:

```yaml
quick_commands:
  friend:
    type: exec
    command: "$HOME/.local/bin/buddy-switch-friend"
  work:
    type: exec
    command: "$HOME/.local/bin/buddy-switch-work"
```

Then restart the active Hermes gateway so it reloads the config.

_한국어: 두 프로필 config에 같은 quick command를 넣어야 어느 모드에서든
`/friend`, `/work`가 동작합니다._

## Telegram Usage

```text
/friend
/work
```

After switching, wait 10-20 seconds and send the next message.

_한국어: 전환 명령을 보낸 뒤 바로 대답을 기대하기보다, gateway가 바뀔 시간을
조금 주고 다음 메시지를 보내는 흐름입니다._

## Install From a Clone

```bash
git clone https://github.com/woooya129-ai/buddy-switch.git
cd buddy-switch
./install.sh
```

Skip the optional no-think proxy:

```bash
INSTALL_NOTHINK_PROXY=0 ./install.sh
```

Install into a different bin directory:

```bash
BIN_DIR="$HOME/bin" ./install.sh
```

## Update

Run the installer again:

```bash
curl -fsSL https://raw.githubusercontent.com/woooya129-ai/buddy-switch/main/install.sh | bash
```

Existing `config.env` is kept unchanged.

_한국어: 업데이트할 때 installer를 다시 실행해도 기존 설정 파일은 덮어쓰지
않습니다._

## Uninstall

```bash
rm -f ~/.local/bin/buddy-switch-friend
rm -f ~/.local/bin/buddy-switch-work
rm -f ~/.local/bin/nothink_proxy.py
rm -rf ~/.config/buddy-switch
```

This does not remove Hermes profiles, models, logs, sessions, or credentials.

_한국어: 위 삭제는 Buddy Switch 파일만 지웁니다. Hermes 프로필이나 모델,
대화 기록, 비밀값은 건드리지 않습니다._

