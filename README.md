# Pi extensions showcase

Hero is a **live working Pi session** — real model turns, real tool calls, a real subagent — not title cards and not a menu tour.

Composition `LiveTerminal` — 1920×1080, 30 fps, H.264 `yuv420p`, about 2:17. Source: `public/live-terminal.mp4`, captured with asciinema inside an isolated tmux server, rendered with `agg` + ffmpeg. The visible model is `MiMo-V2.5-Pro`; the underlying model id remains `kilo/stealth/ox-alpha` (zero-cost stealth model, so the on-tape inference is real).

Delivery master: `public/pi-extensions-mimo-showcase.mp4`.

| Beat | Package | What actually happens |
| --- | --- | --- |
| Wishcraft cockpit | `@groeponline/pi-wishcraft` | `/wishcraft` Deck (bare `/signal` toggles the UI off) |
| Live run: fffind | `@groeponline/pi-tools` | real model turn calls the `fffind` tool and reports the scene files |
| Subagent spawn | `@groeponline/pi-agent-orchestrator` | real Explore subagent spawned via the Agent tool |
| Agent Top — live | `@groeponline/pi-agent-orchestrator` | live AGENT TOP table: RUN → DONE, tokens, runtime |
| Orchestrator hub | `@groeponline/pi-agent-orchestrator` | `/agents` |
| Missions | `@groeponline/pi-missions` | scaffold + `/mission dashboard` (Xiaomi MiMo partnership showcase, F001–F003) |

## Record again

```bash
tmux attach -t pi-ext-rec   # optional: watch the take
npm run record:live
```

That script creates a disposable capture profile under gitignored `out/`, starts Pi inside tmux, drives the full tour, rejects errors/secrets/missing beats, and only then replaces `public/live-terminal.mp4`.

## Studio

```bash
tmux attach -t pi-ext-film
npx remotion studio --no-open --port=3000
```

Open `/LiveTerminal`. Title-card scenes stay in the `title-cards` folder.

## Notes

Do not sell synthetic cards as the hero. Keep Pi chrome in frame (prompt, model, powerline). Recordings use `--no-session --approve` with the isolated capture profile; inference runs live on the zero-cost stealth model. Kill stray `asciinema rec` orphans before a retake — they hold the cast path open.
