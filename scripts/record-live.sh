#!/usr/bin/env bash
# Record a real Pi TUI session inside tmux, then render a 1080p 30fps master.
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
OUT="$ROOT/out/live"
CAST="$OUT/pi-extensions.next.cast"
GIF="$OUT/pi-extensions.next.gif"
MP4="$ROOT/public/live-terminal.next.mp4"
FINAL_CAST="$OUT/pi-extensions.cast"
FINAL_GIF="$OUT/pi-extensions.gif"
FINAL_MP4="$ROOT/public/live-terminal.mp4"
SESSION_NAME="${SESSION_NAME:-pi-ext-rec}"
TARGET="${SESSION_NAME}:rec"
TMUX_SOCKET="${TMUX_SOCKET:-pi-ext-showcase}"
COLS="${COLS:-120}"
ROWS="${ROWS:-36}"
PROFILE="$ROOT/out/capture-profile"
MISSIONS_ROOT="$ROOT/out/capture-missions"

WISHCRAFT="$HOME/.pi/agent/npm/node_modules/@groeponline/pi-wishcraft/index.ts"
ORCHESTRATOR="$HOME/.pi/agent/npm/node_modules/@groeponline/pi-agent-orchestrator/dist/index.js"
TOOLS="$HOME/pi-tools/packages/pi-tools/src/index.ts"
MISSIONS="$HOME/.pi/agent/npm/node_modules/@groeponline/pi-missions/dist/index.js"
CONTROL="$HOME/.pi/agent/git/github.com/GroepOnline/pi-agent-control-extension/packages/extension/index.ts"

mkdir -p "$OUT" "$ROOT/public"
rm -f "$CAST" "$GIF" "$MP4"

command -v asciinema >/dev/null
command -v agg >/dev/null
command -v ffmpeg >/dev/null
command -v tmux >/dev/null
command -v pi >/dev/null

export PATH="$HOME/.local/bin:$PATH"
export TERM=xterm-256color
export COLORTERM=truecolor
export TMPDIR="${TMPDIR:-$HOME/tmp}"

node "$ROOT/scripts/prepare-capture-profile.mjs"
rm -rf "$MISSIONS_ROOT"
mkdir -p "$MISSIONS_ROOT"

cleanup() {
  tmux -L "$TMUX_SOCKET" kill-server 2>/dev/null || true
}
trap cleanup EXIT

tmux -L "$TMUX_SOCKET" kill-server 2>/dev/null || true
tmux -L "$TMUX_SOCKET" new-session -d -s "$SESSION_NAME" -n rec -c "$ROOT" -x "$COLS" -y "$ROWS"
tmux -L "$TMUX_SOCKET" set-option -g extended-keys on
tmux -L "$TMUX_SOCKET" set-option -g extended-keys-format csi-u
tmux -L "$TMUX_SOCKET" set-window-option -t "$SESSION_NAME:rec" aggressive-resize off
tmux -L "$TMUX_SOCKET" resize-window -t "$SESSION_NAME:rec" -x "$COLS" -y "$ROWS" 2>/dev/null || true
tmux -L "$TMUX_SOCKET" send-keys -t "$TARGET" "export TERM=xterm-256color COLORTERM=truecolor PATH=\"\$HOME/.local/bin:\$PATH\" TMPDIR=\"\$HOME/tmp\" PI_CODING_AGENT_DIR=\"$PROFILE\"" Enter
sleep 0.4

# asciinema must wrap pi inside a real TTY. Do not attach from a dumb terminal.
PI_COMMAND="env -u TMUX PI_CODING_AGENT_DIR='$PROFILE' MISSIONS_ROOT='$MISSIONS_ROOT' FFF_ENABLE_HOME_SCAN=0 pi --no-session --approve --tui-mode fullscreen --model kilo/stealth/ox-alpha --thinking medium --no-extensions --no-skills --no-prompt-templates --no-context-files -e '$WISHCRAFT' -e '$ORCHESTRATOR' -e '$TOOLS' -e '$MISSIONS' -e '$CONTROL'"
tmux -L "$TMUX_SOCKET" send-keys -t "$TARGET" \
  "asciinema rec --overwrite --cols $COLS --rows $ROWS --command \"$PI_COMMAND\" '$CAST'" \
  Enter

TMUX_SOCKET="$TMUX_SOCKET" bash "$ROOT/scripts/choreography.sh" "$TARGET"

# Stop Pi so asciinema's --command exits.
tmux -L "$TMUX_SOCKET" send-keys -t "$TARGET" C-c
sleep 2
tmux -L "$TMUX_SOCKET" send-keys -t "$TARGET" C-d
sleep 2

if [[ ! -s "$CAST" ]]; then
  echo "cast missing or empty: $CAST" >&2
  exit 1
fi
node "$ROOT/scripts/verify-cast.mjs" "$CAST"

agg --speed 1.0 \
  --renderer fontdue \
  --font-size 16 \
  --cols "$COLS" \
  --rows "$ROWS" \
  --fps-cap 30 \
  --idle-time-limit 10 \
  --no-loop \
  "$CAST" \
  "$GIF"

ffmpeg -y -i "$GIF" -r 30 -fps_mode cfr \
  -movflags +faststart -pix_fmt yuv420p -preset medium -crf 18 \
  -vf "scale=1920:1080:flags=lanczos:force_original_aspect_ratio=decrease,pad=1920:1080:(ow-iw)/2:(oh-ih)/2:color=0x111111" \
  "$MP4"

ffprobe -v error -select_streams v:0 \
  -show_entries stream=codec_name,width,height,r_frame_rate,pix_fmt \
  -show_entries format=duration \
  -of default=nw=1 "$MP4"

mv "$CAST" "$FINAL_CAST"
mv "$GIF" "$FINAL_GIF"
mv "$MP4" "$FINAL_MP4"

echo "CAST $FINAL_CAST"
echo "MP4  $FINAL_MP4"
