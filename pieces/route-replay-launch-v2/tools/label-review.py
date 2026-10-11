"""Add timestamps to review sheets after numeric checks; never modify render frames."""
import json
import math
import sys
from pathlib import Path
from PIL import Image, ImageDraw, ImageFont

root = Path(sys.argv[1]).resolve()
review = root / "review"
timeline = json.loads((review / "timeline.json").read_text())
cell_w = 270 if timeline["height"] > timeline["width"] else 360
cell_h = math.floor((cell_w * timeline["height"] / timeline["width"]) / 2 + .5) * 2
fps = timeline["fps"]
try:
    font = ImageFont.truetype("/System/Library/Fonts/Menlo.ttc", 15)
except OSError:
    font = ImageFont.load_default()

def label(image, strings, cols, width, height):
    draw = ImageDraw.Draw(image)
    for i, text in enumerate(strings):
        x = (i % cols) * width + 7
        y = (i // cols) * height + 5
        box = draw.textbbox((x + 4, y + 2), text, font=font)
        draw.rectangle((x, y, box[2] + 5, box[3] + 4), fill="#202c3a")
        draw.text((x + 4, y + 2), text, font=font, fill="#ffffff")

for shot in timeline["shots"]:
    sheet = review / f"shot{shot['id']:02d}-sheet.jpg"
    frames = []
    k = 0
    while shot["t0"] + k * .25 < shot["t1"] - 1e-6:
        f = math.floor((shot["t0"] + k * .25) * fps + .5)
        if f not in frames:
            frames.append(f)
        k += 1
    image = Image.open(sheet).convert("RGB")
    label(image, [f"{f / fps:.2f}s  f{f}" for f in frames], 4, cell_w, cell_h)
    image.save(sheet, quality=94)

phone = review / "phone.jpg"
image = Image.open(phone).convert("RGB")
phone_h = image.height // math.ceil(timeline["duration"] / 6)
label(image, [f"{i}–{i + 1}s" for i in range(math.ceil(timeline["duration"]))],
      6, 360, phone_h)
image.save(phone, quality=94)
print(f"Timestamped {len(timeline['shots'])} shot sheets and the phone overview.")
