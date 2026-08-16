from __future__ import annotations

import json
import os
from pathlib import Path
import subprocess
import tempfile

from PIL import Image, ImageChops


ROOT = Path(__file__).resolve().parents[1]
OUTPUT = ROOT / "assets" / "ui" / "shop_card"
ASEPRITE_SOURCE = ROOT / "素材" / "主菜单" / "商店卡片.aseprite"

# Native Aseprite coordinates. The fourth frame intentionally starts at 366;
# a single stray alpha pixel at x=358 is not part of the authored card.
CARD_RECTS = [
    (12, 10, 115, 94),
    (129, 10, 115, 94),
    (247, 10, 115, 94),
    (366, 10, 115, 94),
    (483, 10, 115, 94),
]


def crop(image: Image.Image, rect: tuple[int, int, int, int]) -> Image.Image:
    x, y, width, height = rect
    return image.crop((x, y, x + width, y + height))


def main() -> None:
    OUTPUT.mkdir(parents=True, exist_ok=True)
    aseprite = Path(os.environ.get("ASEPRITE_EXE", r"D:\asseprite\aseprite.exe"))
    if not aseprite.exists():
        raise FileNotFoundError("Set ASEPRITE_EXE to the Aseprite executable")

    with tempfile.TemporaryDirectory(prefix="pokemon-shop-card-") as temporary:
        source = Path(temporary)
        layers = source / "layers"
        layers.mkdir()
        subprocess.run(
            [str(aseprite), "-b", str(ASEPRITE_SOURCE), "--save-as", str(source / "composite.png")],
            check=True,
        )
        subprocess.run(
            [
                str(aseprite),
                "-b",
                "--script-param",
                f"source={ASEPRITE_SOURCE}",
                "--script-param",
                f"output={layers}",
                "--script",
                str(ROOT / "tools" / "export_aseprite_layers.lua"),
            ],
            check=True,
        )
        composite = Image.open(source / "composite.png").convert("RGBA")
        frame_layers = [
            Image.open(layers / f"{index:02d}-图层 3.png").convert("RGBA")
            for index in range(1, 6)
        ]
        fill_layers = [
            Image.open(layers / f"{index:02d}-图层 {layer}.png").convert("RGBA")
            for index, layer in zip(range(6, 11), range(4, 9))
        ]

        manifest: dict[str, object] = {
            "source": "res://素材/主菜单/商店卡片.aseprite",
            "canvas_size": [607, 111],
            "card_size": [115, 94],
            "inner_image_rect": [5, 5, 105, 66],
            "bottom_text_rect": [5, 72, 105, 17],
            "filter": "nearest",
            "cards": [],
        }
        rarity_names = ["common", "uncommon", "rare", "epic", "legendary"]
        for index, (rarity, rect) in enumerate(zip(rarity_names, CARD_RECTS)):
            card = crop(composite, rect)
            frame = crop(frame_layers[index], rect)
            fill = crop(fill_layers[index], rect)
            recomposed = Image.alpha_composite(fill, frame)
            if ImageChops.difference(card, recomposed).getbbox() is not None:
                raise RuntimeError(f"Layer recomposition differs for {rarity}")
            card.save(OUTPUT / f"card_{rarity}.png")
            frame.save(OUTPUT / f"frame_{rarity}.png")
            fill.save(OUTPUT / f"fill_{rarity}.png")
            manifest["cards"].append(
                {
                    "rarity": rarity,
                    "source_rect": list(rect),
                    "composite": f"res://assets/ui/shop_card/card_{rarity}.png",
                    "frame": f"res://assets/ui/shop_card/frame_{rarity}.png",
                    "fill": f"res://assets/ui/shop_card/fill_{rarity}.png",
                }
            )

        (OUTPUT / "manifest.json").write_text(
            json.dumps(manifest, ensure_ascii=False, indent=2) + "\n", encoding="utf-8"
        )


if __name__ == "__main__":
    main()
