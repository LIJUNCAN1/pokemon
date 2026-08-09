from __future__ import annotations

import json
from pathlib import Path

from PIL import Image, ImageDraw


ROOT = Path(__file__).resolve().parents[1]
OUTPUT = ROOT / "assets" / "ui" / "pixel_menu"

SOURCES = {
    "button-normal": Path(r"C:\Users\lijc\AppData\Local\Temp\codex-clipboard-7ce56be2-4cc0-4f15-a508-5f44f1656985.png"),
    "button-pressed": Path(r"C:\Users\lijc\AppData\Local\Temp\codex-clipboard-11f400ac-32a2-4282-a9c0-3115e1254340.png"),
    "menu-panel": Path(r"C:\Users\lijc\AppData\Local\Temp\codex-clipboard-65ff4dec-7ebc-4e1f-8175-76e4d76efaf5.png"),
}


def checkerboard(size: tuple[int, int], cell: int = 8) -> Image.Image:
    image = Image.new("RGBA", size, (224, 224, 224, 255))
    draw = ImageDraw.Draw(image)
    for y in range(0, size[1], cell):
        for x in range(0, size[0], cell):
            if (x // cell + y // cell) % 2:
                draw.rectangle((x, y, x + cell - 1, y + cell - 1), fill=(176, 176, 176, 255))
    return image


def export_asset(asset_id: str, source_path: Path) -> dict[str, object]:
    source = Image.open(source_path).convert("RGBA")
    bbox = source.getbbox()
    if bbox is None:
        raise RuntimeError(f"{asset_id}: source has no visible pixels")

    x0, y0, x1, y1 = bbox
    crop = source.crop(bbox)
    role = "button-state" if asset_id.startswith("button") else "menu-panel"
    folder = "controls" if asset_id.startswith("button") else "panels"

    reference_dir = OUTPUT / "reference"
    asset_dir = OUTPUT / folder
    manifest_dir = OUTPUT / "manifests"
    preview_dir = OUTPUT / "preview"
    for directory in (reference_dir, asset_dir, manifest_dir, preview_dir):
        directory.mkdir(parents=True, exist_ok=True)

    reference_name = f"{asset_id}-source.png"
    output_name = f"{asset_id}.png"
    source.save(reference_dir / reference_name)
    crop.save(asset_dir / output_name)

    rect = [x0, y0, x1 - x0, y1 - y0]
    layer = {
        "id": asset_id,
        "output": f"../{folder}/{output_name}",
        "rect": rect,
        "z_index": 0,
        "role": role,
        "mask": "source-derived",
    }
    if asset_id.startswith("button"):
        layer["hitbox"] = rect

    manifest = {
        "canvas": {"width": source.width, "height": source.height},
        "source": f"../reference/{reference_name}",
        "layers": [layer],
        "accuracy": {"visible_pixels": "source-derived", "inferred_hidden_regions": []},
    }
    manifest_path = manifest_dir / f"{asset_id}.json"
    manifest_path.write_text(json.dumps(manifest, ensure_ascii=False, indent=2), encoding="utf-8")

    for background_name, background in (
        ("light", Image.new("RGBA", crop.size, (245, 245, 245, 255))),
        ("dark", Image.new("RGBA", crop.size, (28, 28, 32, 255))),
        ("checker", checkerboard(crop.size)),
    ):
        background.alpha_composite(crop)
        background.save(preview_dir / f"{asset_id}-{background_name}.png")

    return {"id": asset_id, "source": str(source_path), "bbox": rect, "output": f"{folder}/{output_name}"}


def main() -> None:
    exported = [export_asset(asset_id, source) for asset_id, source in SOURCES.items()]
    (OUTPUT / "asset-index.json").write_text(
        json.dumps({"canvas": [640, 360], "assets": exported}, ensure_ascii=False, indent=2),
        encoding="utf-8",
    )


if __name__ == "__main__":
    main()
