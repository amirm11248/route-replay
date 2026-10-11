# Clean Launch study log

- User chose a reusable style demo, using two specified launch-film references.
- Local reference clips acquired at 854 × 480, 30 fps; reference files and derived images are ignored by Git.
- Contact sheets and full reference key frames inspected before drawing.
- Reference measurement helper's optional accent report failed on one hue family; repeated the palette pass without that option. No installed skill files changed.
- Four original static key frames drafted. Motion, score and reusable style registration are pending look/storyboard approval.
- Playwright 1.64.0 and matching Chromium are available through the global install.
- Reference-to-preview comparisons made for the title and reveal. Adjusted the reveal to a larger white panel and stronger cool edge light after inspecting the first comparison.
- Final static frame checks: deterministic pixel output at frames 22, 82, 142 and 202. Text scan of 20 sampled frames passed with 0 cropped or overlapping strings and 0 safe-zone issues.
- Four-panel preview rendered and visually inspected. The measured checks apply to these static drafts, not to a finished animated demo.
- User rejected the first bright palette and requested darker, more premium colors. Replaced electric blue and pastel light with ink blue, muted slate/cyan and smoked violet; narrowed the object's highlight and softened bloom. The initial previews are preserved in `previews/bright-palette/`.
- Revised four-panel preview rendered and visually inspected. The darker palette retains deterministic output at all four checked key frames. Geometry and text placement are unchanged from the passing text scan.


## Render approval and completed demo — 2026-10-09

The user asked to render the demo after requesting the deeper premium palette. Built the approved four beats as a continuous shape relay, with a persistent full stop/sphere/tile/mark and an interpolated surface. Export: 8.000 s, 1920 × 1080, 30 fps, 240 frames; four motion-blur subframes. Original synthesized score and effects, no narration or imported media.

### Review and fixes

- The normal review tool stopped because the installed FFmpeg lacks `drawtext`. A project-local compatibility copy omits only FFmpeg's contact-sheet labels; measurement code is unchanged. Added timestamps to the sheets with Pillow. The installed skill was left intact.
- Initial mix measured −16.8 LUFS. Adjusted the local score loudness stage, then remuxed audio and regenerated the sharing encode: final −15.6 LUFS, true peak −1.1 dBFS. Largest 100 ms window at 4.0 s; 0.9 s of measured quiet precedes it.
- Text check: 44 sampled frames, zero crop/overlap findings. Morph windows are skipped by the tool; those transitions were also visually inspected in the motion contact sheet.
- All three story-arc rules pass. All three declared beat boundaries on the eighth-note grid. No blank frames, no still stretches over 3 s.
- Deterministic seek check across 18 opening/transition/hold/ending frames: PASS. Every selected frame is identical when rendered again in reverse order.

### Per-shot inspection

| Shot | Result | Evidence |
|---|---|---|
| 1 · Idea | PASS | Whole sentence centered; measured full stop carries into the sphere. Opening stays spare. |
| 2 · Focus | PASS | Card expands smoothly; dark object retains identity. Subtitle remains readable but is the smallest text. |
| 3 · Reveal | PASS | Deep surround frames the pearl artboard; aperture and thin arcs resolve; loudest cue lands here. |
| 4 · Callback | PASS | Artboard contracts into the original mark; sentence settles and holds; score decays. |

Inspected all four per-shot contact sheets, the 12-frame motion contact sheet, and the phone-size sheet. Weakest shot: focus has the smallest secondary line; enlarge or omit it for an especially mobile-focused adaptation. The closing move is intentionally restrained and could gain a stronger camera gesture in a more dramatic version.

Not verified: human listening to the synthesized score. Numerical loudness and clipping checks pass. This is an original abstract demo, not a representation of a real product interface. Reusable kit and editable demo promoted to `styles/clean-launch/`.


## Revision 2 — more dynamic motion and a growing opening title

User requested more dynamic, bouncy movement and opening text that starts smaller, gets bigger, then goes away. Applied that instruction directly to the approved composition. Preserved the prior render and source in `versions/v1-restraint/`.

- Opening headline: 62 px at frame 0, spring growth toward 154 px with a brief overshoot, then a 100 px upward exit and disappearance. Its blue dot remains and grows into the sphere.
- Surface and object changes use seek-safe closed-form springs. Sphere briefly squashes and stretches; the tile tilts and settles; the closing mark bounces on landing. Focus, reveal and closing text enter as coherent spring-driven phrases.
- Raised the focus subtitle from 64 to 70 px. Added a light rising five-note motif under the growing opener.
- Rendering remains 8.000 s, 1920 × 1080, 30 fps, 240 frames with four motion-blur subframes. Text checks: 44 sampled frames, zero crop or overlap findings. Deterministic seek check: PASS across 19 frames. All three story-arc rules pass; no blank frames or still stretches over 3 s.
- Sound: −15.6 LUFS integrated, true peak −1.1 dBFS; largest 100 ms window at 4.0 s, preceded by 0.9 s of quiet. Human listening remains unverified.

| Shot | Result | Inspection |
|---|---|---|
| 1 · Idea grows | PASS | Small opening is fully visible; scaling stays centered, overshoots then settles, and exits before the focus copy enters. |
| 2 · Focus | PASS | Surface growth and object bounce are bounded; title enters without text overlap; larger secondary line improves readability. |
| 3 · Reveal | PASS | Tile morph, tilt, aperture and orbit resolve cleanly; the deep surround keeps the pearl artboard legible. |
| 4 · Callback | PASS | Mark has a clear landing bounce; closing sentence scales and settles; ending holds long enough to read. |

Inspected the 16-frame motion contact sheet, all four per-shot contact sheets and the phone sheet. Weakest detail remains the secondary focus line at small display sizes. The title now deliberately begins small, so its full sentence is easiest to read after it grows. No text-ignore exemptions were added. Updated the reusable style instructions and demo source with the spring variant.
