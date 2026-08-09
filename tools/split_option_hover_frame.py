from __future__ import annotations

import json
import os
from pathlib import Path

from PIL import Image, ImageDraw


ROOT = Path(__file__).resolve().parents[1]
SOURCE = ROOT / "素材" / "场景" / "选项选中框.png"
OUTPUT = ROOT / "assets" / "ui" / "pixel_menu" / "hover_corners"

COMPONENTS = {
    "top-left": (2, 1, 9, 9),
    "top-right": (72, 1, 80, 9),
    "bottom-left": (2, 50, 9, 58),
    "bottom-right": (72, 50, 80, 58),
}


def main() -> None:
    source = Image.open(SOURCE).convert("RGBA")
    OUTPUT.mkdir(parents=True, exist_ok=True)
    (OUTPUT / "preview").mkdir(parents=True, exist_ok=True)
    source.save(OUTPUT / "reference-source.png")

    layers: list[dict[str, object]] = []
    recomposed = Image.new("RGBA", source.size, (0, 0, 0, 0))
    overlay = source.copy()
    draw = ImageDraw.Draw(overlay)

    for z_index, (name, bbox) in enumerate(COMPONENTS.items()):
        crop = source.crop(bbox)
        output_name = f"corner-{name}.png"
        crop.save(OUTPUT / output_name)
        recomposed.alpha_composite(crop, (bbox[0], bbox[1]))
        draw.rectangle((bbox[0], bbox[1], bbox[2] - 1, bbox[3] - 1), outline=(0, 255, 255, 255))
        layers.append(
            {
                "id": f"hover-corner-{name}",
                "output": output_name,
                "rect": [bbox[0], bbox[1], bbox[2] - bbox[0], bbox[3] - bbox[1]],
                "z_index": z_index,
                "role": "hover-frame-corner",
                "mask": "source-derived",
            }
        )

    manifest = {
        "canvas": {"width": source.width, "height": source.height},
        "source": "reference-source.png",
        "layers": layers,
        "accuracy": {"visible_pixels": "source-derived", "inferred_hidden_regions": []},
    }
    (OUTPUT / "layers.json").write_text(json.dumps(manifest, ensure_ascii=False, indent=2), encoding="utf-8")
    recomposed.save(OUTPUT / "preview" / "recomposed.png")
    overlay.save(OUTPUT / "preview" / "mask-bounds-overlay.png")


if __name__ == "__main__":
    main()
