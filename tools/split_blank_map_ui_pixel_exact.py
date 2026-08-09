from __future__ import annotations

import argparse
import json
from pathlib import Path

import numpy as np
from PIL import Image, ImageDraw


DEFAULT_SOURCE = Path(
    r"C:\Users\lijc\AppData\Local\Temp\codex-clipboard-9a2234bb-5a29-45da-9f7f-791760b84c49.png"
)
DEFAULT_OUTPUT = Path(r"D:\pokemon\素材\地图空白UI拆分_像素精确")


def rect_mask(width: int, height: int, rect: tuple[int, int, int, int]) -> np.ndarray:
    x, y, w, h = rect
    mask = np.zeros((height, width), dtype=bool)
    mask[max(0, y) : min(height, y + h), max(0, x) : min(width, x + w)] = True
    return mask


def polygon_mask(width: int, height: int, points: list[tuple[int, int]]) -> np.ndarray:
    image = Image.new("1", (width, height), 0)
    ImageDraw.Draw(image).polygon(points, fill=1)
    return np.asarray(image, dtype=bool)


def bbox(mask: np.ndarray) -> tuple[int, int, int, int]:
    ys, xs = np.nonzero(mask)
    if len(xs) == 0:
        raise ValueError("Cannot export an empty layer")
    x0, x1 = int(xs.min()), int(xs.max()) + 1
    y0, y1 = int(ys.min()), int(ys.max()) + 1
    return x0, y0, x1 - x0, y1 - y0


def save_layer(source: np.ndarray, mask: np.ndarray, path: Path) -> tuple[int, int, int, int]:
    x, y, w, h = bbox(mask)
    rgba = np.zeros((h, w, 4), dtype=np.uint8)
    rgba[..., :3] = source[y : y + h, x : x + w, :3]
    rgba[..., 3] = mask[y : y + h, x : x + w].astype(np.uint8) * 255
    path.parent.mkdir(parents=True, exist_ok=True)
    Image.fromarray(rgba, "RGBA").save(path)
    return x, y, w, h


def color_label_mask(
    rgb: np.ndarray,
    rect: tuple[int, int, int, int],
    predicate,
) -> np.ndarray:
    height, width = rgb.shape[:2]
    x, y, w, h = rect
    crop = rgb[y : y + h, x : x + w].astype(np.int16)
    local = predicate(crop[..., 0], crop[..., 1], crop[..., 2])
    mask = np.zeros((height, width), dtype=bool)
    mask[y : y + h, x : x + w] = local
    return mask


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("--source", type=Path, default=DEFAULT_SOURCE)
    parser.add_argument("--out", type=Path, default=DEFAULT_OUTPUT)
    args = parser.parse_args()

    source_image = Image.open(args.source).convert("RGBA")
    source = np.asarray(source_image)
    rgb = source[..., :3]
    width, height = source_image.size
    if (width, height) != (1672, 941):
        raise ValueError(f"Expected the inspected 1672x941 source, got {width}x{height}")

    out = args.out
    out.mkdir(parents=True, exist_ok=True)
    source_image.save(out / "reference-source.png")

    full = np.ones((height, width), dtype=bool)
    assigned = np.zeros((height, width), dtype=bool)
    layer_specs: list[dict] = []

    def reserve(
        layer_id: str,
        group: str,
        requested: np.ndarray,
        z_index: int,
        role: str,
        hitbox: tuple[int, int, int, int] | None = None,
        state: str | None = None,
    ) -> None:
        nonlocal assigned
        owned = requested & ~assigned
        if not owned.any():
            return
        assigned |= owned
        relative = Path(group) / f"{layer_id}.png"
        layer_rect = save_layer(source, owned, out / relative)
        entry = {
            "id": layer_id,
            "role": role,
            "group": group,
            "rect": list(layer_rect),
            "z_index": z_index,
            "output": relative.as_posix(),
            "pixel_mask": "source-derived",
        }
        if hitbox is not None:
            entry["hitbox"] = list(hitbox)
        if state is not None:
            entry["state"] = state
        layer_specs.append(entry)

    # Controls are reserved first so their outline/shadow pixels never leak into the header.
    tab_1 = polygon_mask(width, height, [(669, 14), (754, 14), (773, 31), (773, 102), (759, 119), (670, 119), (652, 104), (652, 31)])
    tab_2 = polygon_mask(width, height, [(799, 13), (892, 13), (908, 30), (908, 104), (887, 120), (840, 144), (817, 121), (797, 116), (779, 103), (779, 31)])
    tab_3 = polygon_mask(width, height, [(938, 14), (1017, 14), (1035, 31), (1035, 102), (1021, 119), (932, 119), (914, 104), (914, 31)])
    tab_4 = polygon_mask(width, height, [(1053, 14), (1137, 14), (1155, 31), (1155, 103), (1140, 119), (1051, 119), (1033, 104), (1033, 31)])
    reserve("top-tab-1", "controls", tab_1, 40, "button", (652, 14, 122, 106), "normal")
    reserve("top-tab-selected", "controls", tab_2, 41, "button", (779, 13, 130, 131), "selected")
    reserve("top-tab-3", "controls", tab_3, 40, "button", (914, 14, 122, 106), "normal")
    reserve("top-tab-4", "controls", tab_4, 40, "button", (1033, 14, 123, 106), "normal")

    # A flattened image cannot reveal the green bar hidden beneath opaque tabs. Build a
    # conservative inferred fallback from same-row pixels outside the controls. It is kept
    # separate from source-derived layers and is deliberately excluded from recomposition.
    inferred_mask = (tab_1 | tab_2 | tab_3 | tab_4) & rect_mask(width, height, (20, 20, 1633, 95))
    if inferred_mask.any():
        inferred_rgba = np.zeros((height, width, 4), dtype=np.uint8)
        for row in range(height):
            available = (~(tab_1 | tab_2 | tab_3 | tab_4)[row]) & (np.arange(width) >= 20) & (np.arange(width) < 1653)
            if available.any():
                inferred_rgba[row, :, :3] = np.median(rgb[row, available], axis=0).astype(np.uint8)
        inferred_rgba[..., 3] = inferred_mask.astype(np.uint8) * 255
        inferred_path = out / "inferred" / "header-under-tabs.png"
        inferred_path.parent.mkdir(parents=True, exist_ok=True)
        ix, iy, iw, ih = bbox(inferred_mask)
        Image.fromarray(inferred_rgba[iy : iy + ih, ix : ix + iw], "RGBA").save(inferred_path)
        layer_specs.append({
            "id": "header-under-tabs-inferred",
            "role": "inferred-background",
            "group": "inferred",
            "rect": [ix, iy, iw, ih],
            "z_index": 2,
            "output": "inferred/header-under-tabs.png",
            "pixel_mask": "generated",
            "inferred_hidden_pixels": True,
            "notes": "Median same-row fill from visible top-bar pixels; not included in exact source recomposition.",
        })

    map_title = color_label_mask(
        rgb,
        (43, 39, 135, 59),
        lambda r, g, b: (
            ((r.astype(np.int16) + g.astype(np.int16) + b.astype(np.int16)) / 3 < 72)
            | (((r.astype(np.int16) + g.astype(np.int16) + b.astype(np.int16)) / 3 > 178)
               & ((np.maximum.reduce([r, g, b]) - np.minimum.reduce([r, g, b])) < 72))
        ),
    )
    reserve("map-title", "labels", map_title, 35, "label")

    start_label = color_label_mask(
        rgb,
        (66, 484, 96, 47),
        lambda r, g, b: (r > 135) & (g > 55) & (g < 165) & (b < 75) & (r > g * 1.18),
    )
    boss_label = color_label_mask(
        rgb,
        (1525, 480, 83, 45),
        lambda r, g, b: (r > 145) & (g < 105) & (b < 105) & (r > g * 1.45),
    )
    reserve("start-label", "labels", start_label, 30, "label")
    reserve("boss-label", "labels", boss_label, 30, "label")

    # Keep the pale upper viewport and the lower mountain/forest artwork separately reusable.
    viewport = rect_mask(width, height, (30, 145, 1612, 325))
    reserve("map-viewport-background", "background", viewport, 10, "background")
    mountain_forest = rect_mask(width, height, (30, 470, 1612, 273))
    reserve("mountain-forest-background", "background", mountain_forest, 11, "background")

    bottom_fill = rect_mask(width, height, (59, 766, 1554, 111))
    reserve("bottom-panel-background", "background", bottom_fill, 13, "panel-background")

    # Frame ownership follows measured full-resolution transitions around each nested panel.
    bottom_outer = polygon_mask(width, height, [(52, 744), (1616, 744), (1630, 758), (1630, 882), (1615, 898), (54, 898), (40, 884), (40, 758)])
    reserve("bottom-panel-frame", "frames", bottom_outer, 14, "panel-frame")

    top_bar = rect_mask(width, height, (20, 20, 1633, 95))
    reserve("top-green-bar", "background", top_bar, 8, "header-background")

    header_divider = rect_mask(width, height, (16, 114, 1641, 31))
    reserve("header-divider", "frames", header_divider, 9, "divider")

    # The remaining pixels are nested chrome, shadows, one-pixel highlights and corner mattes.
    outer_shadow = full & ~rect_mask(width, height, (7, 7, 1658, 926))
    reserve("outside-dark-background", "background", outer_shadow, 0, "canvas-background")

    inner_frame_band = rect_mask(width, height, (7, 7, 1658, 926)) & ~rect_mask(width, height, (16, 127, 1641, 789))
    reserve("outer-metal-window-frame", "frames", inner_frame_band, 4, "window-frame")

    main_inner_frame = rect_mask(width, height, (16, 127, 1641, 789))
    reserve("inner-window-frame", "frames", main_inner_frame, 5, "inner-frame")

    # Assign every residual antialiased pixel to a dedicated matte layer, preserving exact RGB.
    reserve("edge-matte", "frames", full, 50, "edge-matte")

    manifest = {
        "schema_version": 1,
        "source": {
            "path": str(args.source),
            "format": "PNG",
            "width": width,
            "height": height,
            "mode": "RGB",
            "native_scale": 1,
        },
        "coordinate_system": "top-left-pixels",
        "pixel_art": {"filter": "nearest", "mipmaps": False},
        "layers": layer_specs,
        "missing_states": ["hover", "pressed", "disabled"],
        "notes": [
            "All exported visible RGB values come directly from the flattened source.",
            "Pixels hidden behind opaque controls cannot be recovered from the source image.",
            "The selected tab includes its visible downward pointer.",
        ],
    }
    (out / "layers.json").write_text(json.dumps(manifest, ensure_ascii=False, indent=2), encoding="utf-8")

    recomposed = np.zeros_like(source)
    coverage = np.zeros((height, width), dtype=bool)
    for layer in sorted(layer_specs, key=lambda item: item["z_index"]):
        if layer["pixel_mask"] != "source-derived":
            continue
        x, y, w, h = layer["rect"]
        asset = np.asarray(Image.open(out / layer["output"]).convert("RGBA"))
        alpha = asset[..., 3] > 0
        target = recomposed[y : y + h, x : x + w]
        target[alpha] = asset[alpha]
        coverage[y : y + h, x : x + w] |= alpha

    recomposed[..., 3] = np.where(coverage, 255, 0).astype(np.uint8)
    preview = out / "preview"
    preview.mkdir(exist_ok=True)
    Image.fromarray(recomposed, "RGBA").save(preview / "recomposed.png")

    delta = np.abs(recomposed[..., :3].astype(np.int16) - source[..., :3].astype(np.int16))
    changed = np.any(delta != 0, axis=2) | ~coverage
    difference = np.zeros_like(source)
    difference[..., :3] = np.where(changed[..., None], [255, 0, 255], [0, 0, 0])
    difference[..., 3] = 255
    Image.fromarray(difference, "RGBA").save(preview / "difference.png")

    overlay = source.copy()
    overlay_image = Image.fromarray(overlay, "RGBA")
    draw = ImageDraw.Draw(overlay_image)
    for layer in layer_specs:
        x, y, w, h = layer["rect"]
        draw.rectangle((x, y, x + w - 1, y + h - 1), outline=(255, 0, 255, 255), width=1)
    overlay_image.save(preview / "mask-bounds-overlay.png")

    metrics = {
        "canvas": [width, height],
        "layer_count": len(layer_specs),
        "covered_pixels": int(coverage.sum()),
        "total_pixels": width * height,
        "changed_pixels": int(changed.sum()),
        "mean_absolute_channel_error": float(delta.mean()),
        "max_channel_error": int(delta.max()),
        "exact_recomposition": bool(not changed.any()),
    }
    (preview / "verification.json").write_text(json.dumps(metrics, indent=2), encoding="utf-8")
    print(json.dumps(metrics, indent=2))


if __name__ == "__main__":
    main()
