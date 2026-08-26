#!/usr/bin/env bash
# Drive a real working Pi session: live model, live tools, live subagents.
# Never send Escape twice. Never type bare /signal (it toggles Wishcraft off).
set -euo pipefail
SESSION="${1:-pi-ext-rec:rec}"
TMUX_SOCKET="${TMUX_SOCKET:-pi-ext-showcase}"

sleep_ms() { sleep "$(awk "BEGIN { print $1/1000 }")"; }
tx() { tmux -L "$TMUX_SOCKET" "$@"; }

pane() { tx capture-pane -t "$SESSION" -p 2>/dev/null || true; }

alive() {
  if ! tx has-session -t "${SESSION%%:*}" 2>/dev/null; then
    echo "tmux session died (pi or asciinema exited)" >&2
    exit 1
  fi
}

wait_for() {
  local pat="$1"
  local tries="${2:-50}"
  local i
  for ((i = 0; i < tries; i++)); do
    alive
    if pane | grep -qE "$pat"; then
      return 0
    fi
    sleep_ms 250
  done
  echo "Timed out waiting for: $pat" >&2
  return 1
}

prompt_idle() {
  local tries="${1:-60}"
  local i text
  for ((i = 0; i < tries; i++)); do
    alive
    text="$(pane)"
    if printf '%s\n' "$text" | grep -qiE 'Type to search|Session Tree|esc to interrupt|esc to cancel|working|thinking\.'; then
      sleep_ms 400
      continue
    fi
    if printf '%s\n' "$text" | grep -qE '^[[:space:]]*>'; then
      return 0
    fi
    sleep_ms 500
  done
  echo "Timed out waiting for Pi prompt; pane was:" >&2
  pane >&2
  return 1
}

type_cmd() {
  local cmd="$1"
  local i
  prompt_idle
  tx send-keys -t "$SESSION" C-u
  sleep_ms 250
  for ((i = 0; i < ${#cmd}; i++)); do
    tx send-keys -t "$SESSION" -l "${cmd:i:1}"
    sleep_ms 65
  done
  sleep_ms 450
  if [[ "$cmd" == *" "* ]]; then
    tx send-keys -t "$SESSION" Escape
    sleep_ms 300
  fi
  tx send-keys -t "$SESSION" Enter
}

type_prompt() {
  local text="$1"
  local i
  prompt_idle
  tx send-keys -t "$SESSION" C-u
  sleep_ms 250
  for ((i = 0; i < ${#text}; i++)); do
    tx send-keys -t "$SESSION" -l "${text:i:1}"
    sleep_ms 40
  done
  sleep_ms 400
  tx send-keys -t "$SESSION" Enter
}

close_overlay() {
  tx send-keys -t "$SESSION" Escape
  sleep_ms 800
  prompt_idle
}

wait_for "MiMo-V2\.5-Pro" 120
sleep_ms 3500

# Opening: real Pi, MiMo identity, Wishcraft welcome.
if pane | grep -qE 'Quick Launch|WISHCRAFT|Recent Crafts'; then
  sleep 7
  tx send-keys -t "$SESSION" Escape
  sleep_ms 1000
fi

# 01 — Wishcraft cockpit, briefly. The rest of the film is real work.
type_cmd "/wishcraft"
wait_for "NAVIGATION|ACTIVE ROUTE|Signal"
sleep 7
close_overlay

# 02 — Real model turn using the FFF-backed pi-tools search live.
type_prompt "Use fffind to locate every scene composition in this repo, then name them in one short line."
wait_for "fffind" 120
sleep 4
prompt_idle 180
sleep 4

# 03 — Real subagent spawn through the orchestrator Agent tool.
type_prompt "Spawn one explore subagent that reads src/LiveTerminal.tsx and reports its chapter titles in one line. Use the agent tool."
wait_for "agent|Agent" 120
sleep 3

# The subagent finishes on screen: AGENT TOP flips to DONE, report lands.
prompt_idle 240
sleep 4

# 04 — Orchestrator hub after the real run.
type_cmd "/agents"
wait_for "Agent types|Agent templates" 80
sleep 9
close_overlay

# 05 — Missions: real scaffold, then the live Mission Control end shot.
type_cmd "/mission templates scaffold docs Xiaomi MiMo partnership showcase"
wait_for "Mission created|Xiaomi MiMo partnership showcase"
sleep 5
close_overlay

type_cmd "/mission dashboard"
wait_for "Mission Control|Xiaomi MiMo partnership showcase|F001"
sleep 12
