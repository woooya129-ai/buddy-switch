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
~/.local/bin/buddy-switch-routes
~/.local/bin/buddy-switch-init
~/.local/bin/nothink_proxy.py
~/.config/buddy-switch/config.env
~/.config/buddy-switch/personas/
```

During an interactive first install, a progress bar tracks the completed
steps. When the install finishes, an ASCII face opens its eyes and the setup
wizard asks for two profile names and a default response language. The wizard
creates editable SOUL drafts; it does not overwrite Hermes files.

## Where Everything Goes

| Path | Created by installer? | Purpose |
| --- | --- | --- |
| `~/.local/bin/buddy-switch-friend` | yes | Runs the friend-profile switch |
| `~/.local/bin/buddy-switch-work` | yes | Runs the work-profile switch |
| `~/.local/bin/buddy-switch-routes` | yes | Shows the current route and available choices |
| `~/.local/bin/buddy-switch-init` | yes | Generates local settings and SOUL drafts |
| `~/.local/bin/nothink_proxy.py` | yes, optional | OpenAI-compatible Ollama proxy with `think:false` |
| `~/.config/buddy-switch/config.env` | yes | Local Buddy Switch settings |
| `~/.config/buddy-switch/personas/` | on first setup | Editable SOUL drafts |
| `~/.local/state/buddy-switch/` | on first run | Switch logs |
| `~/.hermes/profiles/<profile>/config.yaml` | no | Add Hermes quick commands manually |

Buddy Switch does not create Hermes profiles and does not write credentials.

For a non-interactive install, skip the wizard and run it later:

```bash
BUDDY_SWITCH_RUN_SETUP=0 ./install.sh
buddy-switch-init
```

For scripts or CI:

```bash
buddy-switch-init --yes \
  --friend-profile buddy-friend \
  --work-profile buddy-work \
  --language en
```

## Create Hermes Profiles

Current Hermes versions provide a profile command. A representative setup is:

```bash
hermes profile create buddy-friend --no-skills
hermes profile create buddy-work
```

`--no-skills` is only an example for a lightweight chat profile. Choose the
tools and model that fit your own use. Buddy Switch does not install Hermes;
use the [official Hermes installer](https://github.com/NousResearch/hermes-agent#quick-install)
first if needed.

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

The installer creates `config.env` with `600` permissions and the config
directory with `700`. Keep it that way: the switch scripts source this file as
shell and will refuse to load it if it is group/world-writable. See
[`../SECURITY.md`](../SECURITY.md) for the full runtime security model.

## Review the SOUL Drafts

The setup wizard writes two drafts under:

```text
~/.config/buddy-switch/personas/<profile-name>/SOUL.md
```

Read and edit them before copying their contents into the matching Hermes
profile. If a Hermes `SOUL.md` already exists, back it up and merge carefully.
The response language is controlled by the SOUL language policy plus the
language ability of the selected model, not by the routing command.

## Add Hermes Quick Commands

Add this block to both Hermes profile configs:

```yaml
quick_commands:
  friends:
    type: exec
    command: "$HOME/.local/bin/buddy-switch-routes"
    category: catalog
    label: "Choose a friend"
  friend:
    type: exec
    command: "$HOME/.local/bin/buddy-switch-friend"
    category: route
    label: "Friend"
  work:
    type: exec
    command: "$HOME/.local/bin/buddy-switch-work"
    category: route
    label: "Work"
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
/friends
/friend
/work
```

`/friends` shows the current profile, model hint, personality path, and exact
route commands. The Buddy Switch Hermes fork turns that screen into buttons.
After switching, wait 10-20 seconds and send the next message.

## Terminal Usage

```bash
buddy-switch-routes
buddy-switch-friend
buddy-switch-work
```

The first command is read-only. It is the easiest way to rediscover route names
without opening config files.

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
rm -f ~/.local/bin/buddy-switch-routes
rm -f ~/.local/bin/buddy-switch-init
rm -f ~/.local/bin/nothink_proxy.py
rm -rf ~/.config/buddy-switch
```

This does not remove Hermes profiles, models, logs, sessions, or credentials.
