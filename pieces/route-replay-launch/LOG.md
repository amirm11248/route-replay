# Route Replay launch work log

## 2026-10-10 — intake and story

- Read the explicitly requested animate skill and its intake, story, format and frame grammar. The HyperFrames entry point was checked; the user explicitly chose animate's procedural canvas framework, so the deliverable follows animate.
- Inspected the local clean-launch and clean-sketch style cards, source and sample images, plus the installed Sketchbook sample and card. Reuse the existing clean-sketch kit without changing the user's parent styles.
- Confirmed Node v22.23.1, FFmpeg 8.1.2, Playwright and Chromium 156 are present.
- User chose a 30-second widescreen trailer with music only, then approved the ten-beat story and three recording slots (2s, 2s, 3s).
- Read the app's SwiftUI screens, map implementation, example data, and existing UI tests. Source confirms 0.5×–10× speed plus timeline, zoom and depth controls; the older README's discrete speed list is not used for trailer claims.
- Attempted a runtime inspection with the iOS debugger skill. Build products exist, but the combined build/run call timed out after 300s; Simulator accessibility timed out; the native UI bridge failed to start. Runtime visual proof remains unavailable.
- Checked platform facts against Apple documentation via web search. The proposed trailer uses no numerical, license, export, availability or comparative claims.

## Look check

Draw three static key frames only: opening, recording placeholder, dimensional route. No animation, animated preview or soundtrack is authored before the full storyboard is approved. Store the approved story, recording manifest and capture guide now so the later footage step is concrete.

Pending: render and inspect look frames; run deterministic and text placement checks; user look approval; complete all ten static storyboard panels; user storyboard approval; animate, score, export, measured review.

First look: build and syntax passed, no external assets; text placement passed on 14 samples (zero cropping, overlap or unsafe text); all three sampled frames rendered deterministically. Inspected the three-frame look sheet. User requested a cleaner, more minimal direction rather than approving the first look.

Look revision 2 removes page binding, handwriting in major copy, repeated contours and hatched placeholder backgrounds. Retains the blue route, light graphite construction and dimensional landform; switches to pearl white and precise frame edges. Initial sheet is retained as `previews/look-v1.png`.

Inspected revised look sheet: the opening and placeholder are mostly clean typography and pearl space; graphite is limited to the route and landform. Revision 2 repeats syntax, text and deterministic checks before the look approval.

The user then explicitly requested white instead of light yellow and premium colors. Applied pure white and cool slate throughout, including start markers, placeholder insert, panel fill and landform. Continuing the user's specified correction into all ten static storyboard panels; final board approval will confirm the corrected palette and full scene sequence. No animation is authored yet.

Full static board: built all ten real scene functions and a board renderer with a navy surround and cool notes, avoiding the default template's beige styling. Visually inspected all panels. Corrected the macro play icon's overly rounded outline to preserve a recognizable triangular play symbol. Text placement passed on 27 sampled frames with no unsafe or overlapping text; all ten selected frames were deterministic. The weakest current panels are necessarily the recording placeholders: real product proof is intentionally deferred until the user supplies clips.

The user explicitly approved the ten-panel storyboard and white/navy/slate palette. Animation and score are now authorized. Preserve the approved static `storyboard.png` as the review record. Animate the same drawing functions, with closed-form springs, the persistent endpoint-to-play bridge, route write-ons, the flat-to-dimensional landform and the opening-route callback. The three recording windows keep exact stationary geometry and full visibility for their declared durations.

Pre-export checks passed: 160 text samples, zero cut-off/overlap/unsafe strings; 29 frames rendered twice in reverse order, all deterministic. Inspected the intro transition at 2.65, 2.85, 3.10 and 3.35s. The endpoint remains continuous while the words hand off without overlapping. Added explicit frame-to-shot lookup for the canonical review pipeline. The browser transport plays the synthesized score and seeks the same frame renderer.

First complete review: all eight cuts and the intro morph passed their grid checks; zero flat frames; text passed all 160 samples; all five story-arc rules passed. Score measured −14.6 LUFS, true peak −1.1 dBFS, largest 100ms window at 17.0s, with 1.4s at or below −40 dBFS before it. A 3.1s still stretch in the closing title was flagged. Lengthened the title's coherent spring settle, including a small upward movement, so the final hold lands later without changing the approved closing composition. Score and other scenes are unchanged.

## Final render and measured review

Re-rendered the corrected ending (frames 780–899) with four subframes of motion blur and encoded the full 900-frame sequence with the procedural score. Master and share files are H.264/AAC at 1920 × 1080, 30 fps. The master is 30.000s; the sharing encode has a tiny AAC container tail while retaining the same 900 video frames.

Final results:

- Determinism: PASS on 29 sampled frames, rendered again in reverse order.
- Cut grid: PASS on all 8 hard cuts, zero frame error. Intro morph centered at 3s: PASS.
- Story arc: PASS on 5/5 rules.
- Text: PASS on 160 sampled frames, zero clipping, overlap or unsafe strings; no ignore exemptions.
- Flat/blank frames: none. Dead beats: PASS, no stretches over 3s.
- Score: −14.6 LUFS integrated, 12.1 LU loudness range, −1.1 dBFS true peak. Largest 100ms window at 17.0s; 1.4s at or below −40 dBFS before it.

Used the existing project-local compatibility version of animate's review tool because installed FFmpeg lacks `drawtext`. Imports point to the installed skill; timestamp decoration is added separately with the bundled Python/Pillow runtime. Cut, text, pacing, story and sound measurements are unchanged. Saved complete results in `review-report.txt`. The custom transition sheets are made from actual exported PNG frames, preserving their aspect ratio.

| Shot | Result | Visual inspection |
|---|---|---|
| 1 · Your workout | PASS | Entire text block settles coherently; the route writes on, with a visible carried endpoint. White stage and navy remain clear. |
| 2 · Replayed | PASS | Endpoint becomes an outlined play mark; old/new copy does not overlap. Whole word and app name settle; the mark grows before the next step. |
| 3 · Library placeholder | PASS | Stationary insert at the exact declared bounds; title reads at phone scale. The 2s clip is intentionally absent. |
| 4 · See the effort | PASS | One abstract route-to-pulse gesture, with no invented metrics or fake product UI. No clipped text or line endpoints. |
| 5 · Details placeholder | PASS | Same fixed geometry and clear 2s label; ready for the real detail recording. |
| 6 · Press play | PASS | A recognizable white play triangle on navy; restrained heavy spring; a stable picture during the score's silence. |
| 7 · Replay placeholder | PASS | Exact 17–20s fixed slot, with the loudest hit at its entry. The real flyover footage is intentionally deferred. |
| 8 · Perspective | PASS | Pure white surface in the deep slate surround; the pencil grid rises from flat into depth; route remains legible and inside the board. |
| 9 · Relive | PASS | Opening route and framing return, with the replay marker traversing the same path and changed copy. |
| 10 · GitHub | PASS | Corrected slower settle removes the still-stretch warning; the full CTA stays readable while the route closes below it. |

Viewed all ten per-shot contact sheets, actual-frame cut and morph sheets, and the one-frame-per-second phone overview. Weakest scene: shot 7, whose visual payoff depends on the user's forthcoming real recording; shot 3 and 5 also lack their intended product proof by request. Human listening and live app UI inspection remain unverified.

Proposed learning, not applied to the shared style kit without approval: when the user requests pure white, replace warm fills in every drawn material and marker as well as the background; retain sketchbook character through graphite geometry rather than a cream wash.
