# Pi extensions showcase

Hero is a **live Pi TUI recording**, not title cards.

Composition `LiveTerminal` — 1920×1080, 30 fps, H.264 `yuv420p`, about 63 seconds. Source: `public/live-terminal.mp4`, captured with asciinema inside tmux, rendered with `agg` + ffmpeg.

| Beat | Package | Command |
| --- | --- | --- |
| Signal / Deck | `@groeponline/pi-wishcraft` | `/wishcraft` (bare `/signal` toggles the UI off) |
| Skills | `@groeponline/pi-wishcraft` | `/skills` |
| Agents | `@groeponline/pi-agent-orchestrator` | `/agents` |
| Missions | `@groeponline/pi-missions` | `/mission status` |

`fffind` / `ffgrep` (`@groeponline/pi-tools`) are agent tools, not slash commands, so they stay off this tape.

## Record again

```bash
tmux attach -t pi-ext-rec   # optional: watch the take
npm run record:live
```

That script starts Pi inside tmux, drives the beats, and writes `public/live-terminal.mp4`. Then update `liveDurationFrames` in `src/LiveTerminal.tsx` from `ffprobe` duration × 30.

## Studio

```bash
tmux attach -t pi-ext-film
npx remotion studio --no-open --port=3000
```

Open `/LiveTerminal`. Title-card scenes stay in the `title-cards` folder.

## Notes

Do not sell synthetic cards as the hero. Keep Pi chrome in frame (prompt, model, powerline). Isolated recordings use `--no-session --offline --approve`.
