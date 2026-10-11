# Clean Sketch

An experimental blend of the user's Clean Launch style and the animate Sketchbook style. This is a separate eight-second variation for comparison. The original Clean Launch style and its bouncy demo stay available.

## Design

Clean composition and physical spring motion provide the structure. Paper, graphite, handwritten emphasis and hatching provide the material. Preserve the darker navy/slate/smoked-violet palette. Use the same four beats and original copy so differences between the two demos are easy to see.

| Role | Color / treatment |
|---|---|
| Paper | Warm pearl `#f3f1e9`, procedural tooth, fibres and a faint dot grid |
| Main typography | Charcoal `#20252b`, Helvetica Neue / Arial |
| Emphasis | Navy `#243e58`, Bradley Hand / Chalkboard SE / Segoe Print |
| Object | Navy gradient `#648091` → `#385870` → `#1b3248`, diagonal pencil hatch |
| Graphite | Slate `#69747b` and `#a0a8aa` |
| Reveal surround | The original deep slate and smoked violet lighting |
| Pencil prop | Navy body, muted wood, charcoal lead |

## What comes from each parent

- **Clean Launch:** sparse sentence-case composition, growing opening title, persistent dot/sphere/tile/mark, floating surfaces, deep reveal surround, spring overshoot, squash/stretch, camera-like changes of scale, original synthesized score.
- **Sketchbook:** seeded two-pass pencil/ink edges, slight line tremor on every second frame, dot-grid paper, notebook binding, construction loop and arrow, hatching, handwritten blue words, an underline drawn by a small pencil.
- **Hybrid choice:** movement runs smoothly on every frame at 30 fps, while linework trembles on twos. The smooth object gradient and deep surround intentionally remain from Clean Launch. Main sentences keep clean typography; only selected words and the thought headline use handwriting.

## Frame rules

1. Keep one main action or sentence at a time.
2. Navy still represents the idea being carried through the film.
3. Keep handwriting selective: `idea`, `What if?`, `tangible.`, `real.`. Measure each run in its actual font before centering.
4. Keep line tremor small enough to preserve the object's silhouette and text legibility.
5. Draw constructions and underlines on; use clean springs for the underlying geometry.
6. Keep the paper visible, including inside the reveal surface. Bindings and the grid should stay quieter than the sentence.
7. Hatching shades the navy object; avoid adding unrelated doodles to the corners.
8. Other aspect ratios need their own layouts, rather than crops.

## Files and API

- `graphite.js`: sketchbook's reusable line, hatch, lettering and underline helpers, with the hybrid palette.
- `drawing.js`: the hybrid's typography, surface, paper, binding, pencil and token helpers, and its single `STYLE` object.
- `kit.js`: concatenation of those two sources. This is the file the animate builder uses; only one `STYLE` is declared.
- `clMeasure` measures clean or handwritten runs; `clText` chooses the matching font.
- `clSketchPage`, `clPanel`, `clIdeaUnderline`, `clToken` draw the combined medium.
- Copy `demo/` into a new piece to reuse the complete four-beat animation.

To regenerate the kit after editing either source, concatenate `graphite.js` then `drawing.js` into `kit.js`. There are no imported images, web fonts, music files or source-film pixels in the composition.

## Review and limits

The trial reuses the established eight-second abstract shape relay. It is an experiment in this merged look, not a claim that the hybrid matches a particular published launch film. Local hand fonts can vary by machine. Line tremor, paper texture and the score are deterministic. Human listening is still needed for the soundtrack; numeric checks and visual review are recorded with the piece.

## Proven on

`pieces/clean-sketch-study`: 1920 × 1080, 30 fps, eight seconds. Review results are saved in that piece's `review-report.txt` and `LOG.md`. `sample.png` is its reveal frame; `demo/` provides source and the rendered video.
