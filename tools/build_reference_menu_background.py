from __future__ import annotations

from pathlib import Path

from PIL import Image


ROOT = Path(__file__).resolve().parents[1]
SOURCE = Path(r"C:\Users\lijc\AppData\Local\Temp\codex-clipboard-d15be14a-3bb1-404f-82cc-4bd8d8d8eb6c.png")
OUTPUT_DIR = ROOT / "assets" / "ui" / "pixel_menu"


def main() -> None:
    OUTPUT_DIR.mkdir(parents=True, exist_ok=True)
    source = Image.open(SOURCE).convert("RGBA")
    source.save(OUTPUT_DIR / "reference-full-source.png")
    # The project viewport is 640×360; nearest-neighbor keeps the source pixel edges hard.
    source.resize((640, 360), Image.Resampling.NEAREST).save(OUTPUT_DIR / "reference-background.png")


if __name__ == "__main__":
    main()
