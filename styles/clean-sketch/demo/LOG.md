# Clean Sketch work log

## Request — 2026-10-09

User requested a rendered experiment combining the custom launch style with Sketchbook. Used the existing four-beat bouncy demo as the shared composition and kept this variation in a separate piece.

Inspected Sketchbook's sample, style card and drawing helpers. Created one merged kit. Clean typography and spring geometry remain; handwritten keywords, notebook material, hand-drawn outlines, hatching, a construction arrow and a short pencil underline supply the second style.

Four key frames were rendered and visually inspected before the full export. The opening and closing mixed-font runs are measured with their actual fonts. The tiny pencil prop uses the darker palette.


## Completed render and review

Exported 8.000 s at 1920 × 1080, 30 fps, 240 frames, four motion-blur subframes. Smaller sharing encode is in `renders/share.mp4`. Saved the new recipe and editable demo in `styles/clean-sketch/`; the custom parent was not edited.

Corrected mixed-font width measurement during construction so handwriting is measured in its actual font rather than the clean headline font. Reviewed those sentence runs after the change. No text-ignore exemptions were needed.

- Deterministic seek check: PASS, 18 sampled frames drawn twice in reverse order.
- Text: PASS, 44 sampled frames, zero cropped/overlapping strings. Transition intervals skipped by the automated checker were visually inspected in the 16-frame motion sheet.
- Beat grid: all three declared bridges at 2, 4 and 6 s pass.
- Story arc: PASS, all three rules. No blank frames or still stretches over three seconds.
- Sound: −15.6 LUFS integrated, true peak −1.1 dBFS; loudest 100 ms at 4.0 s, preceded by 0.9 s of quiet. Human listening is unverified.
- Used the existing project-local review compatibility copy because the installed FFmpeg lacks `drawtext`. Added timestamps to contact sheets with Pillow; measurement logic is unchanged.

| Shot | Result | Inspection |
|---|---|---|
| 1 · Idea grows | PASS | Clean/handwritten sentence is centered through its scale change; underline and pencil draw on; exit carries the blue dot forward. |
| 2 · Focus | PASS | Handwritten headline, construction loop and arrow make the idea provisional; hatched navy sphere stays the main subject. |
| 3 · Reveal | PASS | Deep surround preserves the custom launch look; paper stays visible within the artboard; handwritten word and sketch orbits resolve clearly. |
| 4 · Callback | PASS | Small mark retains the hatching and hand outline; sentence returns with handwritten `real.` and a quiet hold. |

Viewed all four per-shot contact sheets, the motion contact sheet and the phone sheet. The weakest detail is the small focus subtitle at phone scale. The notebook binding is deliberately faint; if the user wants more Sketchbook, make the whole page more tactile before adding more decorative doodles. The current treatment uses handwriting selectively and keeps the main launch composition clean.

This is a rendered experiment, not a user-approved replacement for Clean Launch. Static side-by-side comparison is saved in `previews/comparison.png`.
