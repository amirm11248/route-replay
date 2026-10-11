# Revision 2 work log — 2026-10-10

User feedback: all scenes felt alike; recordings will be vertical. Preserve the agreed story, timing, palette and music-only format while changing visual composition throughout.

Inspected the first piece's source, the local parent launch reference contact sheet, the real app icon and the metric fields in `WorkoutStatsCard.swift`. Checked new metric labels against Apple primary sources. Revision 1 stays available in its original piece.

Build a new static storyboard with meaningful differences in stage, framing and scale. Three tall recording envelopes have distinct right / left / center layouts and native-ratio containment. No new motion or soundtrack is authored before revised storyboard approval.

Built and visually inspected all ten static panels. Text checks pass on 27 sampled frames with zero clipping, overlap or unsafe text. All ten key frames are deterministic when drawn again in reverse order. The real app icon is embedded as the single user-owned bitmap; its original colors are retained in the brand close. The recording envelopes are 432 × 936 at right, left and center. Updated both recording guides to specify vertical captures and native-aspect containment.

The user explicitly approved and requested rendering this revision. Preserve the approved `storyboard.png`; animate the same scene functions. The motion now includes a circle expanding from the route endpoint into the dark title stage, sequential metric write-ons, a much larger macro push, pencil contours around the central replay phone, and a flat-to-raised terrain reveal. Maintain exact stationary portrait insert bounds for later footage compositing. Reuse the approved original score and 17s payoff timing.

Pre-export checks: 160 text samples pass with zero issues; 35 chosen frames are deterministic when rendered again in reverse order. Visual inspection of the iris contact sheet caught a brief dark/blank gap before the white play mark arrived. Brought the mark forward in that transition so it stays visible as the expanding circle becomes the navy stage. Re-rendered only the affected frames 80–100, then rebuilt the complete master and share encodes from all 900 frames. No change to the approved final scene compositions, score or portrait envelopes.

## Completed export and review

- Master: H.264/AAC, 1920 × 1080, 30 fps, 900 video frames, 30.000s. Sharing encode is at the same resolution.
- Cut timing: PASS on all 8 hard cuts, zero frame error. Iris at 3s on grid: PASS.
- Text: PASS across 160 samples, no clipping, overlap, unsafe text or ignore exemptions.
- Story arc: PASS on 5/5 rules.
- Flat/blank frames: none. Dead beats: PASS, no still stretches over 3s.
- Determinism: PASS on the 35 whole-piece samples; the five corrected iris frames also pass in reverse order.
- Sound: −14.6 LUFS integrated, 12.1 LU range, −1.1 dBFS true peak. Largest 100ms window at 17.0s; 1.4s of near silence before it.

| Shot | Result | Inspection |
|---|---|---|
| 1 · Wide route | PASS | A broad route landscape beneath a single large sentence; the marker writes the route and the image has a distinct panoramic silhouette. |
| 2 · Dark title | PASS | The carried endpoint expands into a navy stage; white play mark stays visible after the corrected handoff; type and ring settle with separate scales. |
| 3 · Right portrait | PASS | Full-height fixed portrait slot at right; left copy and a small route gesture remain clear throughout the 2s window. |
| 4 · Metrics | PASS | Three clearly different illustrations write on in sequence. Labels are source-backed; no invented health values or simulated app UI. |
| 5 · Left portrait | PASS | Left slot stays fixed; dark right panel and pulse make this composition distinct from the library view. |
| 6 · Macro | PASS | Large cropped navy disc gives a true close-up; the complete white play glyph and opposing text stay legible; the picture holds during silence. |
| 7 · Center portrait | PASS | Centered phone envelope, large 3D type, opposing copy and drawn contours; native vertical footage can replace the complete marked area. |
| 8 · Terrain | PASS | Large landform rises from flat into depth; primary caption and route remain visible. The small upper cue is verified by text tracing and the unobstructed cut sheet. |
| 9 · Return | PASS | Same panoramic route geometry returns in a different navy/cool-blue framing; marker traverses it and the copy resolves the story. |
| 10 · App close | PASS | Actual app icon keeps its original colors; icon and coherent wordmark settle; CTA stays readable and the route completes below it. |

Viewed all ten per-shot contact sheets, the phone overview, and actual-frame cut/iris sheets. The visual proof in shot 7 remains weakest until the user supplies their replay clip; the placeholders are intentional. Human listening was not performed. The local review compatibility copy only changes labeling/import paths, not numeric measurements. All real recordings remain absent as requested.

Proposed learning, not applied to the shared kit without approval: assess variation by silhouettes and spatial layouts on the board, then vary the motion mechanism; palette consistency alone should not make every scene share the same composition.
