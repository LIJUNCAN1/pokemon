from __future__ import annotations

import argparse
import json
from pathlib import Path

import cv2
import numpy as np
from PIL import Image


def place_alpha(layer_path: Path, rect: list[int], canvas_size: tuple[int, int]) -> np.ndarray:
    width, height = canvas_size
    alpha = np.zeros((height, width), dtype=np.uint8)
    layer = np.asarray(Image.open(layer_path).convert("RGBA"))
    x, y, w, h = rect
    alpha[y:y + h, x:x + w] = layer[..., 3]
    return alpha


def rectangle_mask(size: tuple[int, int], rect: tuple[int, int, int, int]) -> np.ndarray:
    width, height = size
    x, y, w, h = rect
    result = np.zeros((height, width), dtype=bool)
    result[y:y + h, x:x + w] = True
    return result


def ring_mask(size: tuple[int, int], outer: tuple[int, int, int, int], inner: tuple[int, int, int, int]) -> np.ndarray:
    return rectangle_mask(size, outer) & ~rectangle_mask(size, inner)


def tight_bbox(mask: np.ndarray) -> tuple[int, int, int, int]:
    ys, xs = np.nonzero(mask)
    return int(xs.min()), int(ys.min()), int(xs.max() + 1), int(ys.max() + 1)


def inpaint_layer(
    source_rgb: np.ndarray,
    target: np.ndarray,
    hidden: np.ndarray,
    output: Path,
    mask_output: Path,
    radius: float,
    mode: str = "telea",
) -> dict:
    hidden = hidden & target
    if mode == "row-median":
        completed = source_rgb.copy()
        for row in range(source_rgb.shape[0]):
            samples = source_rgb[row, target[row] & ~hidden[row]]
            if len(samples):
                completed[row, hidden[row]] = np.median(samples, axis=0).astype(np.uint8)
        method = "source-derived row median reconstruction"
    else:
        bgr = cv2.cvtColor(source_rgb, cv2.COLOR_RGB2BGR)
        completed = cv2.inpaint(bgr, hidden.astype(np.uint8) * 255, radius, cv2.INPAINT_TELEA)
        completed = cv2.cvtColor(completed, cv2.COLOR_BGR2RGB)
        method = f"OpenCV Telea content-aware inpainting, radius={radius}"
        if mode == "telea-top-row-median":
            for row in range(220, min(235, source_rgb.shape[0])):
                samples = source_rgb[row, target[row] & ~hidden[row]]
                if len(samples):
                    completed[row, hidden[row]] = np.median(samples, axis=0).astype(np.uint8)
            method += "; source-derived row median for top boundary"
    completed[~hidden] = source_rgb[~hidden]

    x0, y0, x1, y1 = tight_bbox(target)
    rgba = np.zeros((y1 - y0, x1 - x0, 4), dtype=np.uint8)
    rgba[..., :3] = completed[y0:y1, x0:x1]
    rgba[..., 3] = target[y0:y1, x0:x1].astype(np.uint8) * 255
    output.parent.mkdir(parents=True, exist_ok=True)
    Image.fromarray(rgba, "RGBA").save(output)

    mask_rgba = np.zeros_like(rgba)
    local_hidden = hidden[y0:y1, x0:x1]
    mask_rgba[..., 0] = local_hidden.astype(np.uint8) * 255
    mask_rgba[..., 3] = local_hidden.astype(np.uint8) * 210
    mask_output.parent.mkdir(parents=True, exist_ok=True)
    Image.fromarray(mask_rgba, "RGBA").save(mask_output)

    return {
        "output": output.as_posix(),
        "inference_mask": mask_output.as_posix(),
        "rect": [x0, y0, x1 - x0, y1 - y0],
        "inferred_pixels": int(hidden.sum()),
        "visible_pixels_preserved": int((target & ~hidden).sum()),
        "method": method,
    }


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("--source", type=Path, required=True)
    parser.add_argument("--layers", type=Path, required=True)
    parser.add_argument("--out", type=Path, required=True)
    args = parser.parse_args()

    source = Image.open(args.source).convert("RGB")
    source_rgb = np.asarray(source)
    size = source.size
    manifest = json.loads(args.layers.read_text(encoding="utf-8"))
    entries = {item["id"]: item for item in manifest["layers"]}
    root = args.layers.parent
    args.out.mkdir(parents=True, exist_ok=True)

    def alpha_for(layer_id: str) -> np.ndarray:
        item = entries[layer_id]
        return place_alpha(root / item["output"], item["rect"], size)

    rgb = source_rgb.astype(np.int16)
    gray = rgb.mean(axis=2)
    saturation = rgb.max(axis=2) - rgb.min(axis=2)

    header_target = rectangle_mask(size, (29, 54, 1615, 80))
    header_hidden = header_target & (alpha_for("header-background") == 0)

    map_target = rectangle_mask(size, (40, 220, 1594, 522))
    map_hidden = map_target & (alpha_for("map-mountain-background") == 0)

    frame_target = ring_mask(size, (29, 136, 1615, 617), (40, 220, 1594, 522))
    frame_hidden = frame_target & (alpha_for("map-viewport-frame") == 0)

    # Expand foreground ownership through antialiasing and shadows so inpainting samples only
    # clean background. Expanded pixels are explicitly counted as inferred.
    soft_kernel = np.ones((9, 9), dtype=np.uint8)
    header_hidden = cv2.dilate(header_hidden.astype(np.uint8), soft_kernel, iterations=1).astype(bool) & header_target
    map_foreground = np.zeros_like(map_hidden)
    for item in manifest["layers"]:
        if item.get("group") in {"nodes", "labels", "map"}:
            map_foreground |= alpha_for(item["id"]) > 0
    map_hidden |= cv2.dilate(map_foreground.astype(np.uint8), soft_kernel, iterations=1).astype(bool) & map_target
    top_panels = (alpha_for("trail-title-panel") > 0) | (alpha_for("progress-panel") > 0)
    map_hidden |= cv2.dilate(
        top_panels.astype(np.uint8), np.ones((31, 31), dtype=np.uint8), iterations=1
    ).astype(bool) & map_target

    route_corridors = np.zeros_like(map_hidden, dtype=np.uint8)
    route_paths = [
        [(139, 304), (1573, 304)], [(139, 450), (1573, 450)], [(139, 595), (1573, 595)],
        [(139, 450), (331, 304)], [(139, 450), (335, 595)],
        [(517, 450), (698, 304)], [(517, 450), (703, 595)],
        [(908, 450), (1097, 304)], [(1098, 304), (1140, 365), (1195, 420), (1282, 450)],
        [(1096, 595), (1145, 535), (1210, 475), (1282, 450)],
        [(1446, 304), (1573, 450)], [(1446, 595), (1573, 450)],
    ]
    for points in route_paths:
        cv2.polylines(route_corridors, [np.asarray(points, dtype=np.int32)], False, 255, thickness=24, lineType=cv2.LINE_AA)
    map_hidden |= (route_corridors > 0) & map_target
    neutral_route_residue = map_target & (gray < 220) & (gray > 105) & (saturation < 24)
    map_hidden |= cv2.dilate(neutral_route_residue.astype(np.uint8), np.ones((5, 5), dtype=np.uint8), iterations=1).astype(bool)
    frame_hidden = cv2.dilate(
        frame_hidden.astype(np.uint8), np.ones((25, 25), dtype=np.uint8), iterations=1
    ).astype(bool) & frame_target

    legend_target = rectangle_mask(size, (56, 765, 1562, 107))
    legend_content = legend_target & ((gray < 205) | (saturation > 32))
    kernel = np.ones((3, 3), dtype=np.uint8)
    legend_hidden = cv2.dilate(legend_content.astype(np.uint8), kernel, iterations=2).astype(bool) & legend_target

    jobs = [
        ("header-background-completed", header_target, header_hidden, 7.0, "row-median"),
        ("map-background-completed", map_target, map_hidden, 9.0, "telea-top-row-median"),
        ("map-viewport-frame-completed", frame_target, frame_hidden, 7.0, "row-median"),
        ("legend-background-completed", legend_target, legend_hidden, 7.0, "telea"),
    ]
    results = {}
    for name, target, hidden, radius, mode in jobs:
        layer_path = args.out / "layers" / f"{name}.png"
        mask_path = args.out / "masks" / f"{name}-inferred-mask.png"
        result = inpaint_layer(source_rgb, target, hidden, layer_path, mask_path, radius, mode)
        result["output"] = layer_path.relative_to(args.out).as_posix()
        result["inference_mask"] = mask_path.relative_to(args.out).as_posix()
        result["preserved_visible_max_channel_error"] = 0
        results[name] = result

        layer = Image.open(layer_path).convert("RGBA")
        lw, lh = layer.size
        yy, xx = np.indices((lh, lw))
        checks = ((xx // 16 + yy // 16) % 2).astype(np.uint8)
        checker_rgba = np.zeros((lh, lw, 4), dtype=np.uint8)
        checker_rgba[..., :3] = np.where(checks[..., None] == 0, 42, 88)
        checker_rgba[..., 3] = 255
        checker = Image.fromarray(checker_rgba, "RGBA")
        checker.alpha_composite(layer)
        preview_path = args.out / "preview" / f"{name}-checker.png"
        preview_path.parent.mkdir(parents=True, exist_ok=True)
        checker.save(preview_path)

    combined_hidden = header_hidden | map_hidden | frame_hidden | legend_hidden
    full_background = Image.new("RGBA", size, (0, 0, 0, 0))

    def composite_existing(layer_id: str) -> None:
        item = entries[layer_id]
        layer = Image.open(root / item["output"]).convert("RGBA")
        full_background.alpha_composite(layer, (item["rect"][0], item["rect"][1]))

    def composite_completed(name: str) -> None:
        item = results[name]
        layer = Image.open(args.out / item["output"]).convert("RGBA")
        full_background.alpha_composite(layer, (item["rect"][0], item["rect"][1]))

    for layer_id in ("outside-dark-background", "outer-window-shadow", "outer-metal-window-frame"):
        composite_existing(layer_id)
    composite_completed("header-background-completed")
    composite_existing("header-divider")
    composite_completed("map-viewport-frame-completed")
    composite_completed("map-background-completed")
    composite_existing("legend-outer-frame")
    composite_completed("legend-background-completed")
    full_background.save(args.out / "layers" / "full-background-completed.png")

    preview = source_rgb.copy()
    preview[combined_hidden] = np.array([255, 45, 45], dtype=np.uint8)
    (args.out / "preview").mkdir(parents=True, exist_ok=True)
    Image.fromarray(preview, "RGB").save(args.out / "preview" / "all-inferred-pixels-overlay.png")

    completed_map = Image.open(args.out / "layers" / "map-background-completed.png").convert("RGBA")
    checker = Image.new("RGBA", completed_map.size, (37, 42, 48, 255))
    checker.alpha_composite(completed_map)
    checker.save(args.out / "preview" / "map-background-completed-preview.png")

    report = {
        "source": str(args.source),
        "canvas": {"width": size[0], "height": size[1]},
        "policy": "Source-visible pixels are byte-identical. Only pixels inside inference masks are generated.",
        "warning": "Occluded pixels are inferred, not recovered from the flattened source.",
        "layers": results,
        "total_inferred_pixels": int(combined_hidden.sum()),
    }
    (args.out / "inferred-layers.json").write_text(json.dumps(report, ensure_ascii=False, indent=2), encoding="utf-8")


if __name__ == "__main__":
    main()
