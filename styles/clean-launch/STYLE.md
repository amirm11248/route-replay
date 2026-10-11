# Clean Launch

Reusable procedural style, approved with the darker palette and demonstrated in an eight-second animated film. Set `"style": "clean-launch"` in a piece's `piece.json`. Start from `demo/` for the continuous shape relay, or use the kit with another composition.

## Look

White space, sentence-case sans typography, one deep ink-blue action color, precisely rounded surfaces and restrained slate/cyan/violet light. The user requested darker versions of the colors to give the style a more premium feel. Use depth and muted saturation, with narrow highlights and quieter shadows. Start with a clear sentence, then scale into a detail, reveal the result, and return to quiet white space.

## Current palette — user-directed revision

| Role | Color |
|---|---|
| Pearl surface | #f9f9f7 |
| Charcoal type | #17191c |
| Ink-blue accent | #243e58 |
| Muted cyan / slate | #657f8d |
| Smoked violet | #665f76 |
| Object highlight → midtone → shade | #648091 → #385870 → #1b3248 |
| Artboard surround | #202c3a → #35495b → #536977 → #3e384d |

The richer palette deliberately departs from the brighter reference colors. Large title frames remain visually sparse; the reveal uses a deep surround behind a pearl surface. Avoid vivid electric blue, pale rainbow glow or glossy neon highlights.

## Measured references and chosen values

- Both reference files: 854 × 480, 30 fps, aspect 1.779. Atlas duration 97.70 s; Sites duration 28.57 s.
- Main white bucket: #fdfdfd in both films; title ink #000000. The revised demo uses pearl #f9f9f7 and charcoal #17191c.
- Sites title blue bucket means: #016dd4 and #0171d5. The first draft used #0075df; the user-directed revision uses deep ink blue #243e58.
- Atlas close UI: #fbfbfb neutral surface with #a8e7fc cyan edges and #e5effc cool light. The revised demo substitutes dark slate and smoked violet for the bright ambient light.
- Headline glyph heights: about 33 px (Atlas title) and 52 px (Sites title) at 480 px frame height, approximately 7–11% of height. The preview sets primary text at 122 px in a 1080 px frame; visible glyph height is smaller than the font's em.
- Atlas title width: 264/854 ≈ 31%; Sites title width: 620/854 ≈ 73%. Our primary line intentionally sits between those scales. Center each colored text run using measured width.
- Thin neutral panel edges: visually about 1 px at 854 wide; use 2 px at 1920. Panel corners 24–58 px at 1920, selected according to scale.
- Sites had no detected stepping on twos, and only two detected hard cuts (8.87 s, 10.73 s). Treat it as predominantly continuous moves; cut detection is an estimate, not ground truth.
- Atlas has more cuts and occasional UI frame holds. Do not interpret the shot detector's short alternating runs as a hand-drawn animation requirement.
- Text runs and major actions should settle for 0.5–1.5 s; proposed moves last 0.35–0.8 s and operate on every frame. Those durations are design choices from visual inspection, not fitted easing curves.
- References are sparse in many title holds. Match the whitespace before adding decorative details.

## Motion

1. Opening sentence starts at 62 px, grows to 154 px with spring overshoot, holds briefly, then lifts and disappears. Animate the whole sentence as one object.
2. Blue full stop -> close-up sphere: retain color and position through a 0.95 s spring move; allow a modest scale overshoot and brief squash/stretch.
3. Sphere -> rounded square: a 1.05 s spring transition. Open the pearl aperture slightly later; a small damped tilt makes the object settle visibly.
4. Pull back to the artboard as the deep surround emerges. Interpolate the same surface's bounds rather than cutting between two boards.
5. Contract the artwork into the small final mark in 1.02 s, add a brief landing bounce, return to the opening headline framing and hold.

The demo draws every frame at 30 fps with four subframes of motion blur. Major beat boundaries are 2, 4 and 6 s at 120 BPM. Its renderer seeks directly to any time; no frame depends on a previous frame. Closed-form springs supply motion with mass; bounded cubic easing supplies opacity. Keep surface growth within the frame and clamp dimensions before applying a spring overshoot. Type moves as complete sentences.

Typography changes as a coherent sentence. Recenter to measured width at every scale; avoid independently bouncing every letter. Bounces have one main overshoot and a short damped settle. Small object drifts and rotations belong to the material, with no wobble, print grain or character faces.

## Frame checklist

- One primary sentence or one visual action per frame.
- Pearl stage, charcoal type; deep ink blue always identifies the carried idea.
- Headline feels centered by its complete measured text run.
- Use sentence case and a local system sans font, tracking roughly −2 to −3.5% of the em.
- The scale change must be obvious: title -> macro -> wide result -> quiet callback.
- Hairlines and shadows remain restrained at full size.
- Gradient light stays around a surface rather than replacing its content; use deep desaturated shades and restrained highlights.
- Any claimed product UI comes from the user's actual screenshots; this demo's panel contains original abstract art.
- Essential text and mark stay inside the 16:9 margins. Recompose extra formats; do not crop them.
- No source logos, footage, music or reference pixels in the generated HTML.

## Kit API

- `clText(text, x, y, size, options)` — clean local-font text with tracking.
- `clRun(parts, centerX, baseline, size, options)` — measured, centered multicolor sentence.
- `clPanel(x, y, width, height, options)` — thin-bordered rounded surface with a soft shadow.
- `clHalo(centerX, centerY, width, height, strength)` — cool ambient light behind a surface.
- `clToken(x, y, radius, { square, aperture })` — the original idea-to-mark motif. Both options accept a boolean or a continuous 0–1 amount.
- `clCaption(text, options)` — caption after the camera transform.
- `STYLE` implements every required hook; `ones: true`.

## Limits

The exact reference font is not bundled; Helvetica Neue and Arial are local fallbacks. The demo uses original abstract artwork. Exact source easing, sound timbre and tempo have not been matched. Palette measurements are derived from compressed reference frames and are not official brand tokens. The soundtrack is synthesized locally and checked numerically; a human listening review remains useful.

## Proven on

`pieces/clean-launch-study`: eight seconds, 1920 × 1080, 30 fps. Deterministic frame checks, text placement, blank-frame scan, pacing and all three story-arc rules pass. The full report and per-shot review are saved with that piece. `sample.png` is the reveal frame; `demo/` contains editable source and the rendered film.
