#!/usr/bin/env bash
set -euo pipefail

RAW_BASE="${BUDDY_SWITCH_RAW_BASE:-https://raw.githubusercontent.com/woooya129-ai/buddy-switch/main}"
BIN_DIR="${BIN_DIR:-$HOME/.local/bin}"
CONFIG_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/buddy-switch"
CONFIG_FILE="${BUDDY_SWITCH_CONFIG:-$CONFIG_DIR/config.env}"
INSTALL_NOTHINK_PROXY="${INSTALL_NOTHINK_PROXY:-1}"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd || pwd)"

install_local_or_remote() {
  local source_path="$1"
  local target_name="$2"
  local local_path="$SCRIPT_DIR/$source_path"
  local target_path="$BIN_DIR/$target_name"

  if [[ -f "$local_path" ]]; then
    install -m 755 "$local_path" "$target_path"
    return
  fi

  if ! command -v curl >/dev/null 2>&1; then
    printf '%s\n' "curl is required when install.sh is not run from a cloned repo." >&2
    exit 1
  fi

  curl -fsSL "$RAW_BASE/$source_path" -o "$target_path"
  chmod 755 "$target_path"
}

mkdir -p "$BIN_DIR" "$CONFIG_DIR"

install_local_or_remote "examples/scripts/buddy-switch-friend" "buddy-switch-friend"
install_local_or_remote "examples/scripts/buddy-switch-work" "buddy-switch-work"

if [[ "$INSTALL_NOTHINK_PROXY" != "0" ]]; then
  install_local_or_remote "examples/ollama/nothink_proxy.py" "nothink_proxy.py"
fi

if [[ ! -f "$CONFIG_FILE" ]]; then
  cat >"$CONFIG_FILE" <<EOF
# Buddy Switch local config.
# Edit these values to match your Hermes profiles and local model names.

FRIEND_PROFILE="${FRIEND_PROFILE:-buddy-friend}"
WORK_PROFILE="${WORK_PROFILE:-buddy-work}"

HERMES_BIN="${HERMES_BIN:-hermes}"
OLLAMA_BIN="${OLLAMA_BIN:-ollama}"

# Optional. When set, the switch scripts try to unload the opposite model.
FRIEND_MODEL="${FRIEND_MODEL:-}"
WORK_MODEL="${WORK_MODEL:-}"

# Optional. macOS only: set to 1 if you want scripts to open Ollama.app.
BUDDY_SWITCH_START_OLLAMA_APP="${BUDDY_SWITCH_START_OLLAMA_APP:-0}"

# Optional no-think proxy settings.
BUDDY_NOTHINK_PROXY_PORT="${BUDDY_NOTHINK_PROXY_PORT:-11435}"
BUDDY_NOTHINK_PROXY_BIN="${BUDDY_NOTHINK_PROXY_BIN:-$BIN_DIR/nothink_proxy.py}"
EOF
  created_config=1
else
  created_config=0
fi

cat <<EOF
Buddy Switch installed.

Commands:
  $BIN_DIR/buddy-switch-friend
  $BIN_DIR/buddy-switch-work

Config:
  $CONFIG_FILE

Next:
  1. Edit the config file if your Hermes profiles are not buddy-friend and buddy-work.
  2. Add the quick_commands block from the README to both Hermes profile configs.
  3. Send /friend or /work in Telegram.
EOF

if [[ "$created_config" == "0" ]]; then
  printf '%s\n' ""
  printf '%s\n' "Existing config was kept unchanged."
fi

