#!/usr/bin/env bash
# Drive the live Pi TUI. Target: tmux pane already running pi.
# Never send Escape twice — settings.doubleEscapeAction is "tree".
# Never type bare /signal — that toggles Wishcraft off.
set -euo pipefail
SESSION="${1:-pi-ext-rec:rec}"

sleep_ms() { sleep "$(awk "BEGIN { print $1/1000 }")"; }

pane() { tmux capture-pane -t "$SESSION" -p || true; }

wait_for() {
  local pat="$1"
  local i
  for ((i = 0; i < 50; i++)); do
    if pane | grep -qE "$pat"; then
      return 0
    fi
    sleep_ms 250
  done
  return 0
}

prompt_idle() {
  local i text
  for ((i = 0; i < 30; i++)); do
    text="$(pane)"
    if printf '%s\n' "$text" | grep -qE 'Type to search|WISHCRAFT DECK|Session Tree'; then
      sleep_ms 200
      continue
    fi
    if printf '%s\n' "$text" | grep -qE '^>'; then
      return 0
    fi
    sleep_ms 200
  done
}

type_cmd() {
  local cmd="$1"
  local i
  prompt_idle
  for ((i = 0; i < ${#cmd}; i++)); do
    tmux send-keys -t "$SESSION" -l "${cmd:i:1}"
    sleep_ms 80
  done
  sleep_ms 450
  tmux send-keys -t "$SESSION" Enter
}

close_overlay() {
  tmux send-keys -t "$SESSION" Escape
  sleep_ms 800
  prompt_idle
}

wait_for "ready|ponytail|Quick Launch"
sleep_ms 2500

# Wishcraft welcome / Quick Launch is the product. Hold it, then one Escape.
if pane | grep -qE 'Quick Launch|WISHCRAFT|Recent Crafts'; then
  sleep 4
  tmux send-keys -t "$SESSION" Escape
  sleep_ms 800
fi

# Wishcraft Deck (do not use bare /signal — that toggles Signal off)
type_cmd "/wishcraft"
wait_for "WISHCRAFT|DECK|NAVIGATION|Signal"
sleep 5
close_overlay

# Wishcraft skills overlay
type_cmd "/skills"
wait_for "Skills|SKILL|skill"
sleep 5
close_overlay

# Orchestrator dashboard
type_cmd "/agents"
wait_for "Agent|Dashboard|Swarm|Create"
sleep 6
close_overlay

# Missions — one command, then stop. Do not type another slash onto this line.
type_cmd "/mission status"
wait_for "mission|Mission|feature|No active"
sleep 5
close_overlay

sleep 2
