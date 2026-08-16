from __future__ import annotations

import colorsys
import json
from pathlib import Path

from PIL import Image, ImageDraw


ROOT = Path(__file__).resolve().parents[1]
OUTPUT = ROOT / "assets" / "ui" / "rarity_tags"
SOURCE_DIR = OUTPUT / "source"
RARE_REFERENCE = SOURCE_DIR / "rare-reference.png"

# The blue reference is the in-game baseline. The other screenshots are enlarged
# previews, so only their authored palettes are transferred onto this geometry.
RARE_BOUNDS = (10, 7, 114, 60)
SOURCE_BACKGROUND = (35, 68, 94)
SOURCE_BODY_VALUE = 134.0 / 255.0
PALETTES = {
    "common": {"name": "普通", "body": "#f8fafc", "text": "#607c9e"},
    "uncommon": {"name": "优秀", "body": "#64a460", "text": "#c7f8c9"},
    "rare": {"name": "稀有", "body": "#3b6586", "text": "#5da6de"},
    "epic": {"name": "史诗", "body": "#8061bf", "text": "#d0b5ff"},
    "legendary": {"name": "传说", "body": "#ef8125", "text": "#ffd0a6"},
}


def _rgb(hex_color: str) -> tuple[int, int, int]:
    value = hex_color.removeprefix("#")
    return tuple(int(value[index : index + 2], 16) for index in (0, 2, 4))


def _is_tag_pixel(pixel: tuple[int, int, int]) -> bool:
    return sum((pixel[index] - SOURCE_BACKGROUND[index]) ** 2 for index in range(3)) > 8**2


def _remove_baked_text(image: Image.Image) -> Image.Image:
    pixels = image.load()
    width, height = image.size
    text_mask: set[tuple[int, int]] = set()
    for y in range(height):
        for x in range(width):
            red, green, blue, alpha = pixels[x, y]
            if alpha and 16 <= x <= 88 and 10 <= y <= 42 and red >= 72 and green >= 126 and blue >= 168:
                text_mask.add((x, y))

    # Include the one-pixel blended fringe so no old glyph survives recoloring.
    expanded = set(text_mask)
    for x, y in text_mask:
        for offset_y in (-1, 0, 1):
            for offset_x in (-1, 0, 1):
                candidate = (x + offset_x, y + offset_y)
                if 0 <= candidate[0] < width and 0 <= candidate[1] < height:
                    expanded.add(candidate)

    for y in range(height):
        row_samples = []
        for x in list(range(12, 21)) + list(range(84, 93)):
            red, green, blue, alpha = pixels[x, y]
            if alpha:
                row_samples.append((red, green, blue))
        if not row_samples:
            continue
        replacement = tuple(round(sum(pixel[channel] for pixel in row_samples) / len(row_samples)) for channel in range(3))
        for x in range(width):
            # The label interior contains no authored ornament. Rebuilding the
            # complete glyph band removes dark antialias remnants as well as
            # the bright core of the baked text.
            in_glyph_band = 16 <= x <= 88 and 10 <= y <= 42
            if ((x, y) in expanded or in_glyph_band) and pixels[x, y][3]:
                pixels[x, y] = (*replacement, 255)
    return image


def _recolor(template: Image.Image, body_hex: str) -> Image.Image:
    target_rgb = _rgb(body_hex)
    target_h, target_s, target_v = colorsys.rgb_to_hsv(*(channel / 255.0 for channel in target_rgb))
    output = Image.new("RGBA", template.size)
    source = template.load()
    destination = output.load()
    for y in range(template.height):
        for x in range(template.width):
            red, green, blue, alpha = source[x, y]
            if not alpha:
                continue
            _, _, source_v = colorsys.rgb_to_hsv(red / 255.0, green / 255.0, blue / 255.0)
            value_ratio = source_v / SOURCE_BODY_VALUE
            mapped_v = max(0.0, min(1.0, target_v * value_ratio))
            mapped_s = min(1.0, target_s * (0.86 + 0.14 * min(value_ratio, 1.25)))
            mapped = colorsys.hsv_to_rgb(target_h, mapped_s, mapped_v)
            destination[x, y] = (*(round(channel * 255) for channel in mapped), 255)
    return output


def _checker_preview(images: dict[str, Image.Image], background: tuple[int, int, int], path: Path) -> None:
    scale = 4
    cell_width = 128 * scale
    cell_height = 72 * scale
    preview = Image.new("RGB", (cell_width * len(images), cell_height), background)
    draw = ImageDraw.Draw(preview)
    for index, image in enumerate(images.values()):
        enlarged = image.resize((image.width * scale, image.height * scale), Image.Resampling.NEAREST)
        x = index * cell_width + (cell_width - enlarged.width) // 2
        y = (cell_height - enlarged.height) // 2
        preview.paste(enlarged, (x, y), enlarged)
        draw.rectangle((index * cell_width, 0, (index + 1) * cell_width - 1, cell_height - 1), outline=(100, 100, 100))
    preview.save(path)


def main() -> None:
    OUTPUT.mkdir(parents=True, exist_ok=True)
    preview_dir = OUTPUT / "preview"
    preview_dir.mkdir(exist_ok=True)

    source = Image.open(RARE_REFERENCE).convert("RGB").crop(RARE_BOUNDS)
    template = Image.new("RGBA", source.size)
    template_pixels = template.load()
    source_pixels = source.load()
    for y in range(source.height):
        for x in range(source.width):
            pixel = source_pixels[x, y]
            if _is_tag_pixel(pixel):
                template_pixels[x, y] = (*pixel, 255)
    template = _remove_baked_text(template)

    generated: dict[str, Image.Image] = {}
    native_layers = {
        "common": SOURCE_DIR / "common-layer.png",
        "uncommon": SOURCE_DIR / "uncommon-layer.png",
        "epic": SOURCE_DIR / "epic-layer.png",
        "legendary": SOURCE_DIR / "legendary-layer.png",
    }
    manifest = {
        "sources": {
            rarity: (f"source/{rarity}-layer.png" if rarity in native_layers else f"source/{rarity}-reference.png")
            for rarity in PALETTES
        },
        "source_bounds": list(RARE_BOUNDS),
        "native_size": list(template.size),
        "native_sizes": {"rare": list(template.size)},
        "geometry_baseline": "rare remains the existing in-game asset; native Aseprite layers are preserved",
        "text_removed": True,
        "reconstruction": "inferred from adjacent authored background rows",
        "tags": {},
    }
    for rarity, palette in PALETTES.items():
        # The four non-blue backgrounds are authored in 品质框.aseprite. Keep
        # those native pixels exactly; only the legacy blue rare tag is rebuilt
        # from the in-game baseline when no native layer is supplied.
        if rarity in native_layers and native_layers[rarity].exists():
            image = Image.open(native_layers[rarity]).convert("RGBA")
        elif rarity == "rare" and (OUTPUT / "rare.png").exists():
            image = Image.open(OUTPUT / "rare.png").convert("RGBA")
        else:
            image = _recolor(template, palette["body"])
        image.save(OUTPUT / f"{rarity}.png")
        generated[rarity] = image
        manifest["native_sizes"][rarity] = list(image.size)
        manifest["tags"][rarity] = {
            "asset": f"{rarity}.png",
            "source_layer": "品质框.aseprite native layer" if rarity in native_layers else "existing in-game blue tag",
            "display_name": palette["name"],
            "text_color": palette["text"],
            "body_color": palette["body"],
        }

    (OUTPUT / "layers.json").write_text(json.dumps(manifest, ensure_ascii=False, indent=2), encoding="utf-8")
    _checker_preview(generated, (238, 238, 238), preview_dir / "checker-light.png")
    _checker_preview(generated, (28, 31, 38), preview_dir / "checker-dark.png")


if __name__ == "__main__":
    main()
