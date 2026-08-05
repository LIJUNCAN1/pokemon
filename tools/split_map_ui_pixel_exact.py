from __future__ import annotations

import json
import argparse
from collections import deque
from pathlib import Path

import numpy as np
from PIL import Image, ImageDraw


SOURCE = Path(r"C:\Users\lijc\Downloads\ChatGPT Image 2026年8月5日 00_22_45.png")
OUT = Path(r"D:\pokemon\素材\地图UI拆分_像素精确")


def rect_mask(size: tuple[int, int], rect: tuple[int, int, int, int]) -> np.ndarray:
    width, height = size
    x, y, w, h = rect
    mask = np.zeros((height, width), dtype=bool)
    mask[max(y, 0):min(y + h, height), max(x, 0):min(x + w, width)] = True
    return mask


def ring_mask(size: tuple[int, int], outer: tuple[int, int, int, int], inner: tuple[int, int, int, int]) -> np.ndarray:
    return rect_mask(size, outer) & ~rect_mask(size, inner)


def scanline_octagon_mask(rgb: np.ndarray, rect: tuple[int, int, int, int], inset: int = 9) -> np.ndarray:
    """Trace the visible octagonal edge from source pixels, one scanline at a time."""
    x, y, w, h = rect
    crop = rgb[y:y + h, x:x + w].astype(np.int16)
    gray = crop.mean(axis=2)
    sat = crop.max(axis=2) - crop.min(axis=2)
    neutral_dark = (gray < 226) & (sat < 34)
    mask = np.zeros((h, w), dtype=bool)

    lefts: list[int] = []
    rights: list[int] = []
    for row in range(h):
        slope = min(row, h - 1 - row, inset)
        expected_left = inset - slope
        expected_right = w - 1 - expected_left

        left_band = range(max(0, expected_left - 4), min(w, expected_left + 6))
        right_band = range(max(0, expected_right - 5), min(w, expected_right + 5))

        left_candidates = [col for col in left_band if neutral_dark[row, col]]
        right_candidates = [col for col in right_band if neutral_dark[row, col]]
        left = min(left_candidates, key=lambda col: abs(col - expected_left)) if left_candidates else expected_left
        right = min(right_candidates, key=lambda col: abs(col - expected_right)) if right_candidates else expected_right

        # Include the antialiased transition pixel immediately outside the detected dark edge.
        left = max(0, left - 1)
        right = min(w - 1, right + 1)
        lefts.append(left)
        rights.append(right)

    # Suppress isolated one-pixel scan errors caused by connector lines touching a node.
    for values in (lefts, rights):
        for row in range(1, h - 1):
            lo, hi = sorted((values[row - 1], values[row + 1]))
            values[row] = min(max(values[row], lo - 1), hi + 1)

    for row, (left, right) in enumerate(zip(lefts, rights)):
        mask[row, left:right + 1] = True

    full = np.zeros(rgb.shape[:2], dtype=bool)
    full[y:y + h, x:x + w] = mask
    return full


def color_text_mask(rgb: np.ndarray, region: tuple[int, int, int, int], kind: str) -> np.ndarray:
    x, y, w, h = region
    crop = rgb[y:y + h, x:x + w].astype(np.int16)
    r, g, b = crop[..., 0], crop[..., 1], crop[..., 2]
    if kind == "orange":
        local = (r > 135) & (r > g * 1.25) & (g > b * 1.15)
    else:
        local = (r > 155) & (r > g * 1.35) & (r > b * 1.25)
    full = np.zeros(rgb.shape[:2], dtype=bool)
    full[y:y + h, x:x + w] = local
    return full


def corridor_mask(size: tuple[int, int], points: list[tuple[int, int]], radius: int = 13) -> np.ndarray:
    canvas = Image.new("1", size, 0)
    draw = ImageDraw.Draw(canvas)
    draw.line(points, fill=1, width=radius * 2 + 1, joint="curve")
    return np.asarray(canvas, dtype=bool)


def content_bbox(mask: np.ndarray) -> tuple[int, int, int, int]:
    ys, xs = np.nonzero(mask)
    if len(xs) == 0:
        return 0, 0, 1, 1
    x0, x1 = int(xs.min()), int(xs.max()) + 1
    y0, y1 = int(ys.min()), int(ys.max()) + 1
    return x0, y0, x1 - x0, y1 - y0


def save_layer(source: np.ndarray, mask: np.ndarray, path: Path) -> tuple[int, int, int, int]:
    bbox = content_bbox(mask)
    x, y, w, h = bbox
    rgba = np.zeros((h, w, 4), dtype=np.uint8)
    rgba[..., :3] = source[y:y + h, x:x + w, :3]
    rgba[..., 3] = mask[y:y + h, x:x + w].astype(np.uint8) * 255
    path.parent.mkdir(parents=True, exist_ok=True)
    Image.fromarray(rgba, "RGBA").save(path)
    return bbox


def main() -> None:
    global SOURCE, OUT
    parser = argparse.ArgumentParser()
    parser.add_argument("--source", type=Path, default=SOURCE)
    parser.add_argument("--out", type=Path, default=OUT)
    args = parser.parse_args()
    SOURCE, OUT = args.source, args.out
    source_image = Image.open(SOURCE).convert("RGBA")
    source = np.asarray(source_image)
    rgb = source[..., :3]
    width, height = source_image.size
    size = (width, height)
    OUT.mkdir(parents=True, exist_ok=True)
    source_image.save(OUT / "reference-source.png")

    node_specs = [
        ("r1-c1-normal", (292, 264, 78, 87)), ("r1-c2-treasure", (478, 264, 78, 87)),
        ("r1-c3-elite", (659, 264, 79, 87)), ("r1-c4-shop", (869, 264, 78, 87)),
        ("r1-c5-normal", (1058, 264, 79, 87)), ("r1-c6-rest", (1241, 264, 79, 87)),
        ("r1-c7-normal", (1407, 264, 78, 87)), ("r2-c1-event", (294, 407, 78, 87)),
        ("r2-c2-rest", (478, 407, 78, 87)), ("r2-c3-normal", (662, 407, 79, 87)),
        ("r2-c4-treasure", (871, 407, 78, 87)), ("r2-c5-treasure", (1059, 407, 78, 87)),
        ("r2-c6-normal", (1243, 407, 78, 87)), ("r2-c7-normal", (1408, 407, 78, 87)),
        ("r3-c1-normal", (296, 552, 78, 87)), ("r3-c2-rest", (479, 552, 78, 87)),
        ("r3-c3-event", (664, 552, 79, 87)), ("r3-c4-shop", (870, 552, 79, 87)),
        ("r3-c5-elite", (1057, 552, 79, 87)), ("r3-c6-shop", (1243, 552, 78, 87)),
        ("r3-c7-normal", (1407, 552, 79, 87)),
    ]
    header_specs = [
        ("run-counter", (39, 61, 182, 64), 5), ("currency-counter", (230, 63, 150, 62), 5),
        ("tab-map-selected", (498, 59, 255, 67), 7), ("tab-team", (763, 59, 248, 67), 7),
        ("tab-bag", (1019, 59, 248, 67), 7), ("tab-relics", (1275, 59, 249, 67), 7),
        ("close-button", (1565, 59, 73, 67), 8),
    ]

    layers: list[dict] = []
    masks: dict[str, np.ndarray] = {}

    def add(layer_id: str, group: str, mask: np.ndarray, z: int, inferred: bool = False, hitbox=None) -> None:
        masks[layer_id] = mask
        rel = Path(group) / f"{layer_id}.png"
        bbox = save_layer(source, mask, OUT / rel)
        entry = {"id": layer_id, "group": group, "rect": list(bbox), "z_index": z,
                 "output": rel.as_posix(), "pixel_mask": "source-derived"}
        if hitbox is not None:
            entry["hitbox"] = list(hitbox)
        if inferred:
            entry["inferred_hidden_pixels"] = True
        layers.append(entry)

    # Nested rectangular boundaries are measured on the original 1672x941 image.
    add("outside-dark-background", "background", ~rect_mask(size, (11, 36, 1651, 873)), 0)
    add("outer-window-shadow", "frames", ring_mask(size, (11, 36, 1651, 873), (16, 41, 1641, 863)), 1)
    add("outer-metal-window-frame", "frames", ring_mask(size, (16, 41, 1641, 863), (29, 54, 1615, 837)), 2)
    add("header-background", "background", rect_mask(size, (29, 54, 1615, 80)), 3)
    add("header-divider", "frames", rect_mask(size, (29, 128, 1615, 14)), 4)
    add("map-viewport-frame", "frames", ring_mask(size, (29, 136, 1615, 617), (40, 220, 1594, 522)), 5)
    add("map-mountain-background", "background", rect_mask(size, (40, 220, 1594, 522)), 6, inferred=True)
    add("trail-title-panel", "panels", scanline_octagon_mask(rgb, (39, 149, 395, 64), 5), 15)
    add("progress-panel", "panels", scanline_octagon_mask(rgb, (1330, 151, 305, 66), 5), 15)
    add("legend-outer-frame", "frames", ring_mask(size, (29, 751, 1615, 141), (56, 765, 1562, 107)), 7)
    add("legend-background-content", "panels", rect_mask(size, (56, 765, 1562, 107)), 8)

    for name, rect, inset in header_specs:
        add(name, "header", scanline_octagon_mask(rgb, rect, inset), 30, hitbox=rect)

    node_masks = []
    for name, rect in node_specs:
        mask = scanline_octagon_mask(rgb, rect, 9)
        node_masks.append(mask)
        add(name, "nodes", mask, 40, hitbox=rect)

    start_rect = (84, 390, 111, 119)
    start_mask = scanline_octagon_mask(rgb, (91, 397, 99, 106), 6)
    # Preserve the four decorative corner brackets without pulling in the map behind them.
    sx, sy, sw, sh = start_rect
    start_crop = rgb[sy:sy + sh, sx:sx + sw].astype(np.int16)
    start_gray = start_crop.mean(axis=2)
    start_sat = start_crop.max(axis=2) - start_crop.min(axis=2)
    bracket_pixels = ((start_sat > 48) | (start_gray < 92))
    bracket_region = np.zeros((sh, sw), dtype=bool)
    bracket_region[:23, :23] = True
    bracket_region[:23, -23:] = True
    bracket_region[-24:, :23] = True
    bracket_region[-24:, -23:] = True
    bracket_full = np.zeros((height, width), dtype=bool)
    bracket_full[sy:sy + sh, sx:sx + sw] = bracket_pixels & bracket_region
    start_mask |= bracket_full
    # START is exported separately and removed from the node crop.
    start_label = color_text_mask(rgb, (104, 505, 75, 38), "orange")
    start_mask &= ~start_label
    add("start-node", "nodes", start_mask, 40, hitbox=start_rect)
    add("start-label", "labels", start_label, 41)

    boss_rect = (1525, 406, 96, 96)
    boss_mask = scanline_octagon_mask(rgb, boss_rect, 9)
    add("boss-node", "nodes", boss_mask, 40, hitbox=boss_rect)
    boss_label = color_text_mask(rgb, (1535, 499, 75, 42), "red")
    add("boss-label", "labels", boss_label, 41)

    # Route pixels are selected only inside narrow corridors joining actual node centers.
    rows = [304, 450, 595]
    cols = [[139, 331, 517, 698, 908, 1097, 1280, 1446, 1573],
            [139, 333, 517, 701, 910, 1098, 1282, 1447, 1573],
            [139, 335, 518, 703, 909, 1096, 1282, 1446, 1573]]
    corridor = np.zeros((height, width), dtype=bool)
    route_core = np.zeros((height, width), dtype=bool)
    for row, xs in zip(rows, cols):
        corridor |= corridor_mask(size, list(zip(xs, [row] * len(xs))), 12)
        route_core |= corridor_mask(size, list(zip(xs, [row] * len(xs))), 4)
    diagonal_routes = [
        [(139, 450), (331, 304)], [(139, 450), (335, 595)],
        [(517, 450), (698, 304)], [(517, 450), (703, 595)],
        [(908, 450), (1097, 304)], [(1098, 304), (1190, 405), (1282, 450)],
        [(1096, 595), (1282, 450)], [(1446, 304), (1573, 450)], [(1446, 595), (1573, 450)],
    ]
    for points in diagonal_routes:
        corridor |= corridor_mask(size, points, 12)
        route_core |= corridor_mask(size, points, 5)
    gray = rgb.astype(np.int16).mean(axis=2)
    saturation = rgb.max(axis=2).astype(np.int16) - rgb.min(axis=2).astype(np.int16)
    candidate = corridor & (gray < 225) & (gray > 105) & (saturation < 30)

    # Retain only color components that actually touch a known route centerline. This removes
    # mountain edges and decorative plus signs that happen to share the route color.
    route = np.zeros((height, width), dtype=bool)
    visited = np.zeros((height, width), dtype=bool)
    ys, xs = np.nonzero(candidate)
    for seed_y, seed_x in zip(ys, xs):
        if visited[seed_y, seed_x]:
            continue
        queue = deque([(int(seed_y), int(seed_x))])
        visited[seed_y, seed_x] = True
        component = []
        touches_core = False
        while queue:
            cy, cx = queue.popleft()
            component.append((cy, cx))
            touches_core |= bool(route_core[cy, cx])
            for ny in range(max(0, cy - 1), min(height, cy + 2)):
                for nx in range(max(0, cx - 1), min(width, cx + 2)):
                    if candidate[ny, nx] and not visited[ny, nx]:
                        visited[ny, nx] = True
                        queue.append((ny, nx))
        if touches_core and len(component) >= 4:
            cy, cx = zip(*component)
            route[np.asarray(cy), np.asarray(cx)] = True
    for _, rect in node_specs:
        route &= ~rect_mask(size, rect)
    route &= ~rect_mask(size, start_rect)
    route &= ~rect_mask(size, boss_rect)
    add("route-connectors", "map", route, 20)

    def refresh(layer_id: str, mask: np.ndarray) -> None:
        masks[layer_id] = mask
        entry = next(item for item in layers if item["id"] == layer_id)
        entry["rect"] = list(save_layer(source, mask, OUT / entry["output"]))

    # Remove foreground ownership from structural backgrounds. This prevents a zero-diff
    # verification from succeeding merely because controls remain baked into a base crop.
    header_foreground = np.zeros((height, width), dtype=bool)
    for name, _, _ in header_specs:
        header_foreground |= masks[name]
    refresh("header-background", masks["header-background"] & ~header_foreground)
    refresh(
        "map-viewport-frame",
        masks["map-viewport-frame"] & ~masks["trail-title-panel"] & ~masks["progress-panel"],
    )
    map_foreground = route | start_mask | boss_mask | start_label | boss_label
    for mask in node_masks:
        map_foreground |= mask
    refresh("map-mountain-background", masks["map-mountain-background"] & ~map_foreground)

    # Reusable sprites from the previous pass were already clean and are copied losslessly.
    previous = Path(r"D:\pokemon\素材\地图UI拆分")
    for rel in ["shared/node-frame.png", "icons/node-normal.png", "icons/node-elite.png",
                "icons/node-treasure.png", "icons/node-shop.png", "icons/node-rest.png", "icons/node-event.png"]:
        target = OUT / rel
        target.parent.mkdir(parents=True, exist_ok=True)
        Image.open(previous / rel).save(target)

    manifest = {
        "canvas": {"width": width, "height": height},
        "coordinate_system": "top-left origin; integer pixel coordinates; rect=[x,y,width,height]",
        "accuracy": {
            "visible_pixels": "Masks and RGB values are derived from the flattened source at native resolution.",
            "hidden_pixels": "Cannot be recovered from a flattened PNG; map background under controls is marked inferred.",
            "overlap_policy": "Each delivered component stores unmodified source RGB inside its source-derived alpha mask."
        },
        "layers": layers,
        "reusable_assets": ["shared/node-frame.png", "icons/node-normal.png", "icons/node-elite.png",
                            "icons/node-treasure.png", "icons/node-shop.png", "icons/node-rest.png", "icons/node-event.png"]
    }
    (OUT / "layers.json").write_text(json.dumps(manifest, ensure_ascii=False, indent=2), encoding="utf-8")

    # Recompose only from exported layers; uncovered pixels remain transparent and count as errors.
    (OUT / "preview").mkdir(parents=True, exist_ok=True)
    recomposed = Image.new("RGBA", size, (0, 0, 0, 0))
    coverage = np.zeros((height, width), dtype=bool)
    for entry in sorted(layers, key=lambda item: item["z_index"]):
        layer = Image.open(OUT / entry["output"]).convert("RGBA")
        x, y, _, _ = entry["rect"]
        recomposed.alpha_composite(layer, (x, y))
        coverage |= masks[entry["id"]]
    recomposed.save(OUT / "preview" / "recomposed-visible-pixels.png")
    recomposed_array = np.asarray(recomposed)
    delta = np.abs(recomposed_array[..., :3].astype(np.int16) - source[..., :3].astype(np.int16))
    changed = np.any(delta > 0, axis=2) | ~coverage
    difference = np.zeros_like(source)
    difference[..., 0] = np.where(changed, 255, 0)
    difference[..., 3] = np.where(changed, 255, 0)
    Image.fromarray(difference, "RGBA").save(OUT / "preview" / "difference-visible-pixels.png")

    overlay = source_image.copy()
    draw = ImageDraw.Draw(overlay)
    for entry in layers:
        x, y, w, h = entry["rect"]
        draw.rectangle((x, y, x + w - 1, y + h - 1), outline=(255, 0, 255, 220), width=1)
    overlay.save(OUT / "preview" / "mask-bounds-overlay.png")

    # Alpha-aware QA previews. Some image viewers display transparent RGB as if opaque.
    def checker_preview(layer_path: Path, output_path: Path, cell: int = 16) -> None:
        layer = Image.open(layer_path).convert("RGBA")
        w, h = layer.size
        yy, xx = np.indices((h, w))
        checks = ((xx // cell + yy // cell) % 2).astype(np.uint8)
        checker = np.zeros((h, w, 4), dtype=np.uint8)
        checker[..., :3] = np.where(checks[..., None] == 0, 44, 96)
        checker[..., 3] = 255
        base = Image.fromarray(checker, "RGBA")
        base.alpha_composite(layer)
        base.save(output_path)

    checker_preview(OUT / "nodes" / "r2-c4-treasure.png", OUT / "preview" / "qa-node-checker.png", 8)
    checker_preview(OUT / "map" / "route-connectors.png", OUT / "preview" / "qa-route-checker.png", 16)
    checker_preview(OUT / "frames" / "outer-metal-window-frame.png", OUT / "preview" / "qa-frame-checker.png", 24)
    (OUT / "preview" / "verification.txt").write_text(
        f"canvas={width}x{height}\n"
        f"covered_pixels={int(coverage.sum())}/{width * height} ({coverage.mean() * 100:.6f}%)\n"
        f"changed_pixels={int(changed.sum())}/{width * height} ({changed.mean() * 100:.6f}%)\n"
        f"mean_absolute_channel_error={float(delta.mean()):.6f}\n"
        "note=hidden pixels behind flattened controls are not recoverable and are marked inferred\n",
        encoding="utf-8",
    )


if __name__ == "__main__":
    main()
