# Install Buddy Switch

Buddy Switch is designed to be installed as a small set of local helper scripts.
It does not install Hermes, create profiles for you, or touch live credentials.

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

## Where Everything Goes

| Path | Created by installer? | Purpose |
| --- | --- | --- |
| `~/.local/bin/buddy-switch-friend` | yes | Runs the friend-profile switch |
| `~/.local/bin/buddy-switch-work` | yes | Runs the work-profile switch |
| `~/.local/bin/nothink_proxy.py` | yes, optional | OpenAI-compatible Ollama proxy with `think:false` |
| `~/.config/buddy-switch/config.env` | yes | Local Buddy Switch settings |
| `~/.local/state/buddy-switch/` | on first run | Switch logs |
| `~/.hermes/profiles/<profile>/config.yaml` | no | Add Hermes quick commands manually |

Buddy Switch does not create Hermes profiles and does not write credentials.

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

Typical Hermes paths:

```text
~/.hermes/profiles/buddy-friend/config.yaml
~/.hermes/profiles/buddy-work/config.yaml
```

If your profiles are named differently, use those directories instead.

## Telegram Usage

```text
/friend
/work
```

After switching, wait 10-20 seconds and send the next message.

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

## Uninstall

```bash
rm -f ~/.local/bin/buddy-switch-friend
rm -f ~/.local/bin/buddy-switch-work
rm -f ~/.local/bin/nothink_proxy.py
rm -rf ~/.config/buddy-switch
```

This does not remove Hermes profiles, models, logs, sessions, or credentials.
