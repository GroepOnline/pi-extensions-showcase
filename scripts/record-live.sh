#!/usr/bin/env bash
# Record a real Pi TUI session inside tmux, then render a 1080p 30fps master.
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
OUT="$ROOT/out/live"
CAST="$OUT/pi-extensions.cast"
GIF="$OUT/pi-extensions.gif"
MP4="$ROOT/public/live-terminal.mp4"
SESSION_NAME="${SESSION_NAME:-pi-ext-rec}"
TARGET="${SESSION_NAME}:rec"
COLS="${COLS:-120}"
ROWS="${ROWS:-36}"

mkdir -p "$OUT" "$ROOT/public"

command -v asciinema >/dev/null
command -v agg >/dev/null
command -v ffmpeg >/dev/null
command -v tmux >/dev/null
command -v pi >/dev/null

export PATH="$HOME/.local/bin:$PATH"
export TERM=xterm-256color
export COLORTERM=truecolor
export TMPDIR="${TMPDIR:-$HOME/tmp}"

tmux kill-session -t "$SESSION_NAME" 2>/dev/null || true
tmux new-session -d -s "$SESSION_NAME" -n rec -c "$ROOT" -x "$COLS" -y "$ROWS"
tmux set-window-option -t "$SESSION_NAME:rec" aggressive-resize off
tmux resize-window -t "$SESSION_NAME:rec" -x "$COLS" -y "$ROWS" 2>/dev/null || true
tmux send-keys -t "$TARGET" "export TERM=xterm-256color COLORTERM=truecolor PATH=\"\$HOME/.local/bin:\$PATH\" TMPDIR=\"\$HOME/tmp\"" Enter
sleep 0.4

# asciinema must wrap pi inside a real TTY. Do not attach from a dumb terminal.
tmux send-keys -t "$TARGET" \
  "asciinema rec --overwrite --cols $COLS --rows $ROWS --command 'pi --no-session --offline --approve --tui-mode fullscreen' '$CAST'" \
  Enter

bash "$ROOT/scripts/choreography.sh" "$TARGET"

# Stop Pi so asciinema's --command exits.
tmux send-keys -t "$TARGET" C-c
sleep 2
tmux send-keys -t "$TARGET" C-d
sleep 2

if [[ ! -s "$CAST" ]]; then
  echo "cast missing or empty: $CAST" >&2
  exit 1
fi

agg --speed 1.0 \
  --renderer fontdue \
  --font-size 16 \
  --cols "$COLS" \
  --rows "$ROWS" \
  --fps-cap 30 \
  --idle-time-limit 5 \
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

echo "CAST $CAST"
echo "MP4  $MP4"
