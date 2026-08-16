from __future__ import annotations

import sys
import time
from pathlib import Path

from PIL import Image, ImageChops, ImageDraw


def main() -> None:
    if len(sys.argv) not in (3, 4):
        raise SystemExit("usage: clean_character_info_frame.py INPUT OUTPUT [FOREGROUND]")

    source = Path(sys.argv[1])
    destination = Path(sys.argv[2])
    foreground_destination = Path(sys.argv[3]) if len(sys.argv) == 4 else None
    image = None
    last_error: Exception | None = None
    for _ in range(30):
        try:
            with Image.open(source) as opened:
                opened.load()
                image = opened.convert("RGBA")
            break
        except (OSError, ValueError) as error:
            last_error = error
            time.sleep(0.1)
    if image is None:
        raise RuntimeError(f"Aseprite export was not ready: {source}") from last_error
    width, height = image.size

    # The current Aseprite source already authors the complete transparent
    # silhouette.  Preserve that alpha byte-for-byte: applying the old rounded
    # clip here removed parts of the newly redrawn black outer border.
    alpha = image.getchannel("A")
    destination.parent.mkdir(parents=True, exist_ok=True)
    image.save(destination)

    if foreground_destination is not None:
        # Preserve the exact authored outer stroke, bottom stroke, central
        # divider, and raised star tab as a foreground layer.  The broad white
        # fills stay in the background export so dynamic labels are never
        # covered, while all original outline pixels remain untouched.
        foreground_mask = Image.new("L", image.size, 0)
        foreground_draw = ImageDraw.Draw(foreground_mask)
        edge_band = max(1, round(min(width, height) * 0.038))
        divider_y = round(height * 0.727)
        divider_band = max(2, round(height * 0.010))
        foreground_draw.rectangle((0, 0, width - 1, edge_band), fill=255)
        foreground_draw.rectangle((0, height - edge_band, width - 1, height - 1), fill=255)
        foreground_draw.rectangle((0, 0, edge_band, height - 1), fill=255)
        foreground_draw.rectangle((width - edge_band, 0, width - 1, height - 1), fill=255)
        foreground_draw.rectangle((0, divider_y - divider_band, width - 1, divider_y + divider_band), fill=255)
        tab_left = round(width * 0.430)
        tab_right = round(width * 0.570)
        tab_bottom = round(height * 0.104)
        foreground_draw.rectangle((tab_left - 8, 0, tab_right + 8, tab_bottom), fill=255)
        foreground_alpha = ImageChops.multiply(alpha, foreground_mask)
        foreground = image.copy()
        foreground.putalpha(foreground_alpha)
        foreground_destination.parent.mkdir(parents=True, exist_ok=True)
        foreground.save(foreground_destination)


if __name__ == "__main__":
    main()
