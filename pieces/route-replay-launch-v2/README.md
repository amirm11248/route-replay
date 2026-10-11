# Route Replay — revision 2

The revised trailer addresses the repeated compositions in the first version and uses vertical recording slots. It preserves the agreed 30-second widescreen format, music-only treatment, story and white/navy/slate palette. The revised storyboard was approved before animation.

- `storyboard.png` — all ten revised compositions.
- `renders/share.mp4` — smaller sharing encode at 1080p.
- `renders/final.mp4` — 30-second, 900-frame 1080p master.
- `index.html` — self-contained animated preview with play, pause, sound and seeking.
- `RECORDING-GUIDE.md` — vertical capture instructions.
- `recording-slots.json` — native-ratio containment and separate right / left / center positions.
- `assets/app-icon.png` — the user's actual app icon, used in the closing frame.
- `src/` — editable scene, motion, score and preview code.
- `review-report.txt` and `LOG.md` — measured and visual review.

Final review passes: zero text issues across 160 samples, all eight cuts on the beat grid, all five story-arc rules, no blank frames and no still stretches over three seconds. The original rendered trailer remains in `../route-replay-launch/` for comparison.

The three portrait inserts remain fixed at right, left and center for 6–8s, 11–13s and 17–20s. Preserve native footage proportions with containment; no stretching or cropping. All real footage is deferred as requested.

```sh
node /Users/malik/.codex/skills/animate/tools/build.mjs pieces/route-replay-launch-v2
node /Users/malik/.codex/skills/animate/tools/export.mjs pieces/route-replay-launch-v2 --share --blur 4
node pieces/route-replay-launch-v2/tools/review.mjs pieces/route-replay-launch-v2
```

The local review tool is the existing FFmpeg `drawtext` compatibility version; measurements are unchanged. Timestamp decoration uses the bundled Python/Pillow runtime. Generated frames, audio and review images remain local and are ignored by Git.
