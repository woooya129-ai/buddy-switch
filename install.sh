#!/usr/bin/env bash
set -euo pipefail

RAW_BASE="${BUDDY_SWITCH_RAW_BASE:-https://raw.githubusercontent.com/woooya129-ai/buddy-switch/main}"
BIN_DIR="${BIN_DIR:-$HOME/.local/bin}"
CONFIG_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/buddy-switch"
CONFIG_FILE="${BUDDY_SWITCH_CONFIG:-$CONFIG_DIR/config.env}"
INSTALL_NOTHINK_PROXY="${INSTALL_NOTHINK_PROXY:-1}"
RUN_FIRST_SETUP="${BUDDY_SWITCH_RUN_SETUP:-1}"

SCRIPT_SOURCE="${BASH_SOURCE:-}"
if [[ -n "$SCRIPT_SOURCE" && -f "$SCRIPT_SOURCE" ]]; then
  SCRIPT_DIR="$(cd "$(dirname "$SCRIPT_SOURCE")" >/dev/null 2>&1 && pwd)"
else
  SCRIPT_DIR="$(pwd)"
fi

show_progress() {
  local current="$1"
  local total="$2"
  local label="$3"
  local width=24
  local filled=$((current * width / total))
  local empty=$((width - filled))
  local left right

  printf -v left '%*s' "$filled" ''
  printf -v right '%*s' "$empty" ''
  left="${left// /#}"
  right="${right// /-}"
  printf '[%s%s] %3d%%  %s\n' "$left" "$right" "$((current * 100 / total))" "$label"
}

draw_face() {
  local eyes="$1"
  local mouth="$2"

  printf '%s\n' \
    '          .----------.' \
    '         /  /\/\/\/\  \' \
    "        |    $eyes    |" \
    '        |      .       |' \
    "         \\    $mouth    /" \
    "          '----------'"
}

show_awake_animation() {
  if [[ "${BUDDY_SWITCH_NO_ANIMATION:-0}" == "1" || ! -t 1 || "${TERM:-}" == "dumb" ]]; then
    printf '\n%s\n' 'Buddy Switch is awake:  o  o'
    return
  fi

  printf '\n'
  draw_face '-  -' '---'
  sleep 0.18
  printf '\033[6A\033[J'
  draw_face '.  .' '---'
  sleep 0.18
  printf '\033[6A\033[J'
  draw_face 'o  o' '\_/'
  printf '%s\n\n' 'Buddy Switch is awake.'
}

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
chmod 700 "$CONFIG_DIR"
show_progress 1 7 "Prepared local folders"

install_local_or_remote "examples/scripts/buddy-switch-friend" "buddy-switch-friend"
show_progress 2 7 "Installed the friend switch"
install_local_or_remote "examples/scripts/buddy-switch-work" "buddy-switch-work"
show_progress 3 7 "Installed the work switch"
install_local_or_remote "examples/scripts/buddy-switch-routes" "buddy-switch-routes"
show_progress 4 7 "Installed the route catalog"
install_local_or_remote "examples/scripts/buddy-switch-init" "buddy-switch-init"
show_progress 5 7 "Installed the first-run setup"

if [[ "$INSTALL_NOTHINK_PROXY" != "0" ]]; then
  install_local_or_remote "examples/ollama/nothink_proxy.py" "nothink_proxy.py"
  show_progress 6 7 "Installed the optional no-think proxy"
else
  show_progress 6 7 "Skipped the optional no-think proxy"
fi

if [[ ! -f "$CONFIG_FILE" ]]; then
  cat >"$CONFIG_FILE" <<EOF
# Buddy Switch local config.
# Edit these values to match your Hermes profiles and local model names.

FRIEND_PROFILE="${FRIEND_PROFILE:-buddy-friend}"
WORK_PROFILE="${WORK_PROFILE:-buddy-work}"
FRIEND_NAME="${FRIEND_NAME:-Friend}"
WORK_NAME="${WORK_NAME:-Work}"

HERMES_BIN="${HERMES_BIN:-hermes}"
OLLAMA_BIN="${OLLAMA_BIN:-ollama}"

# Optional. When set, the switch scripts try to unload the opposite model.
FRIEND_MODEL="${FRIEND_MODEL:-}"
WORK_MODEL="${WORK_MODEL:-}"

# Human-readable labels shown by /friends and switch confirmations.
FRIEND_PERSONA_NAME="${FRIEND_PERSONA_NAME:-friend SOUL}"
WORK_PERSONA_NAME="${WORK_PERSONA_NAME:-work SOUL}"

# Optional. macOS only: set to 1 if you want scripts to open Ollama.app.
BUDDY_SWITCH_START_OLLAMA_APP="${BUDDY_SWITCH_START_OLLAMA_APP:-0}"

# Optional no-think proxy settings.
BUDDY_NOTHINK_PROXY_PORT="${BUDDY_NOTHINK_PROXY_PORT:-11435}"
BUDDY_NOTHINK_PROXY_BIN="${BUDDY_NOTHINK_PROXY_BIN:-$BIN_DIR/nothink_proxy.py}"
EOF
  chmod 600 "$CONFIG_FILE"
  created_config=1
else
  chmod 600 "$CONFIG_FILE" 2>/dev/null || true
  created_config=0
fi

show_progress 7 7 "Finished installing Buddy Switch"
show_awake_animation

setup_ran=0
if [[ "$created_config" == "1" && "$RUN_FIRST_SETUP" != "0" && -t 1 && -r /dev/tty && -w /dev/tty ]]; then
  "$BIN_DIR/buddy-switch-init" --first-run </dev/tty >/dev/tty
  setup_ran=1
fi

if [[ "$setup_ran" == "1" ]]; then
  setup_next="Review the generated SOUL drafts under $CONFIG_DIR/personas/."
else
  setup_next="Run $BIN_DIR/buddy-switch-init to generate your SOUL drafts."
fi

cat <<EOF
Buddy Switch installed.

Connection status:
  Helpers and SOUL drafts are local. No live Hermes or OpenClaw config was changed.

Commands:
  $BIN_DIR/buddy-switch-friend
  $BIN_DIR/buddy-switch-work
  $BIN_DIR/buddy-switch-routes
  $BIN_DIR/buddy-switch-init

Config:
  $CONFIG_FILE

Next:
  1. $setup_next
  2. Configure the real model in each Hermes profile, then add the README quick_commands block.
  3. After that one-time connection, run buddy-switch-routes or send /friends in Telegram.
EOF

if [[ "$created_config" == "0" ]]; then
  printf '%s\n' ""
  printf '%s\n' "Existing config was kept unchanged."
fi
