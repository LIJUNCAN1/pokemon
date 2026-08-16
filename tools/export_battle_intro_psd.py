import json
from pathlib import Path

from PIL import Image
from psd_tools import PSDImage


SOURCE = Path(r"D:\pokemon\素材\战斗进场\战斗进场.psd")
OUTPUT = Path(r"D:\pokemon\assets\ui\battle_intro")
LAYERS = {
    0: "background",
    1: "blue_background",
    2: "purple_background",
    3: "blue_center_border",
    4: "purple_center_border",
    5: "blue_light",
    6: "purple_light",
    7: "vs",
    10: "bottom_bar",
    11: "top_bar",
}
PORTRAITS = {
    "researcher": Path(r"D:\pokemon\素材\战斗进场\10054302-36c0-4984-b77e-12d7dfb685dc.png"),
    "vanguard": Path(r"D:\pokemon\素材\战斗进场\e25b9f17-bf21-4b61-9bcf-aceae6dcb35a.png"),
    "scout": Path(r"D:\pokemon\素材\战斗进场\ef5d91d1-8f3d-4ef6-8871-ae3724b3b559.png"),
}


def main() -> None:
    psd = PSDImage.open(SOURCE)
    OUTPUT.mkdir(parents=True, exist_ok=True)
    manifest = {
        "source": str(SOURCE),
        "canvas": [psd.width, psd.height],
        "color_mode": psd.color_mode.name,
        "depth": psd.depth,
        "layers": [],
    }
    for index, layer in enumerate(psd):
        if index not in LAYERS:
            continue
        image = layer.composite()
        if image is None:
            raise RuntimeError(f"Layer {index} ({layer.name}) has no rendered pixels")
        if index in (3, 4):
            # The authored edge layers contain an opaque white work canvas.
            # Recover only the actual dark/colored edge pixels so the moving
            # halves do not expose white rectangles before they converge.
            image = image.convert("RGBA")
            pixels = []
            for red, green, blue, alpha in image.getdata():
                edge_alpha = max(255 - red, 255 - green, 255 - blue)
                pixels.append((red, green, blue, round(alpha * edge_alpha / 255)))
            image.putdata(pixels)
        left, top, right, bottom = layer.bbox
        output_name = f"{LAYERS[index]}.png"
        image.save(OUTPUT / output_name)
        manifest["layers"].append(
            {
                "index": index,
                "source_name": layer.name,
                "file": output_name,
                "position": [left, top],
                "size": [right - left, bottom - top],
                "opacity": layer.opacity,
                "blend_mode": layer.blend_mode.name,
            }
        )
    manifest["portraits"] = []
    for trainer_id, portrait_path in PORTRAITS.items():
        portrait = Image.open(portrait_path).convert("RGBA")
        alpha = portrait.getchannel("A")
        clean_alpha = alpha.point(lambda value: value if value >= 128 else 0)
        portrait.putalpha(clean_alpha)
        alpha_bounds = clean_alpha.getbbox()
        if alpha_bounds is None:
            raise RuntimeError(f"Portrait {portrait_path} has no visible pixels")
        trimmed = portrait.crop(alpha_bounds)
        output_name = f"portrait_{trainer_id}.png"
        trimmed.save(OUTPUT / output_name)
        manifest["portraits"].append(
            {
                "trainer_id": trainer_id,
                "source": str(portrait_path),
                "source_size": list(portrait.size),
                "alpha_bounds": list(alpha_bounds),
                "file": output_name,
                "size": list(trimmed.size),
            }
        )
    with (OUTPUT / "manifest.json").open("w", encoding="utf-8") as handle:
        json.dump(manifest, handle, ensure_ascii=False, indent=2)


if __name__ == "__main__":
    main()
