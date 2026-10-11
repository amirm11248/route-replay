"""Contact sheets from actual exported frames, with their original aspect ratio."""
import json
import math
import sys
from pathlib import Path
from PIL import Image, ImageDraw, ImageFont

root = Path(sys.argv[1]).resolve()
t = json.loads((root / "review/timeline.json").read_text())
try:
    font = ImageFont.truetype("/System/Library/Fonts/Menlo.ttc", 18)
except OSError:
    font = ImageFont.load_default()

def sheet(items, cols, name, width=384):
    height = round(width * t["height"] / t["width"])
    row_h = height + 32
    canvas = Image.new("RGB", (cols * width, math.ceil(len(items) / cols) * row_h), "#202c3a")
    draw = ImageDraw.Draw(canvas)
    for i, (f, label) in enumerate(items):
        x, y = (i % cols) * width, (i // cols) * row_h
        frame = Image.open(root / f"frames/f{f:04d}.png").convert("RGB")
        frame = frame.resize((width, height), Image.Resampling.LANCZOS)
        canvas.paste(frame, (x, y + 32))
        draw.text((x + 10, y + 6), label, font=font, fill="#ffffff")
    canvas.save(root / "review" / name)

cuts = []
for i, sec in enumerate(t["cuts"], 1):
    f = math.floor(sec * t["fps"] + .5)
    cuts.extend([(f - 1, f"Cut {i} · before"), (f, f"Cut {i} · {sec:.0f}s"), (f + 1, f"Cut {i} · after")])
sheet(cuts, 6, "cuts.png")
sheet([(f, f"Intro · {f / t['fps']:.2f}s") for f in [78, 84, 90, 96, 102]], 5, "morph.png", 420)
print("Wrote actual-frame cut and morph sheets.")
