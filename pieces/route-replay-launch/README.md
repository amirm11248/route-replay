# Route Replay launch trailer

Latest version: [revision 2](../route-replay-launch-v2/README.md) adds more varied compositions and portrait recording slots. This directory preserves the first render for comparison.

30 seconds, 1920 × 1080, 30 fps. Pure white, navy and slate; Clean Launch motion with restrained sketchbook route drawings. The user approved the story and full storyboard before animation.

- `renders/share.mp4` — smaller sharing encode, with original synthesized music.
- `renders/final.mp4` — 1080p master.
- `index.html` — self-contained browser preview with play, pause, sound and seeking.
- `storyboard.png` — the approved ten-panel board.
- `RECORDING-GUIDE.md` — the three short recordings to supply later.
- `recording-slots.json` — exact slot timing and insert bounds.
- `src/` — editable deterministic scene, motion, score and preview code.
- `review-report.txt` and `LOG.md` — measured checks and visual review.

The clip windows are library 6–8s, details 11–13s, and 3D replay 17–20s. No recordings, product screenshots or real workout data are embedded. Future footage will replace the clearly marked inserts.

Open `index.html` in a browser to preview. Click **Play trailer** to hear the score; use the scene buttons or slider to seek. The complete generated page contains no external media, web fonts or network dependencies.

The installed animate tools build and export this piece. Run from the project root:

```sh
node /Users/malik/.codex/skills/animate/tools/build.mjs pieces/route-replay-launch
node /Users/malik/.codex/skills/animate/tools/export.mjs pieces/route-replay-launch --share --blur 4
node pieces/route-replay-launch/tools/review.mjs pieces/route-replay-launch
```

The local review tool is a compatibility copy of animate's review tool because the installed FFmpeg lacks text overlays. All measurements are unchanged; `tools/label-review.py` adds timestamps afterward using Pillow. Generated frames, audio, renders and review images are locally retained and ignored by Git.
