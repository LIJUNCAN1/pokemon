from pathlib import Path

import numpy as np
from PIL import Image, ImageDraw


SOURCE = Path(r"C:\Users\lijc\Downloads\ChatGPT Image 2026年8月5日 00_22_45.png")
OUTPUT = Path(r"D:\pokemon\assets\ui\map\map\route-connectors-runtime.png")


def main() -> None:
    source = np.asarray(Image.open(SOURCE).convert("RGB"))
    height, width = source.shape[:2]
    mask_image = Image.new("L", (width, height), 0)
    draw = ImageDraw.Draw(mask_image)
    paths = [
        [(139, 304), (1573, 304)], [(139, 450), (1573, 450)], [(139, 595), (1573, 595)],
        [(139, 450), (331, 304)], [(139, 450), (335, 595)],
        [(517, 450), (698, 304)], [(517, 450), (703, 595)],
        [(908, 450), (1097, 304)], [(1098, 304), (1140, 365), (1195, 420), (1282, 450)],
        [(1096, 595), (1145, 535), (1210, 475), (1282, 450)],
        [(1446, 304), (1573, 450)], [(1446, 595), (1573, 450)],
    ]
    for points in paths:
        draw.line(points, fill=255, width=44, joint="curve")

    node_rects = [
        (84, 390, 195, 509), (1525, 406, 1621, 502),
        (292, 264, 370, 351), (478, 264, 556, 351), (659, 264, 738, 351),
        (869, 264, 947, 351), (1058, 264, 1137, 351), (1241, 264, 1320, 351), (1407, 264, 1485, 351),
        (294, 407, 372, 494), (478, 407, 556, 494), (662, 407, 741, 494),
        (871, 407, 949, 494), (1059, 407, 1137, 494), (1243, 407, 1321, 494), (1408, 407, 1486, 494),
        (296, 552, 374, 639), (479, 552, 557, 639), (664, 552, 743, 639),
        (870, 552, 949, 639), (1057, 552, 1136, 639), (1243, 552, 1321, 639), (1407, 552, 1486, 639),
    ]
    for x0, y0, x1, y1 in node_rects:
        draw.rectangle((x0 - 2, y0 - 2, x1 + 2, y1 + 2), fill=0)

    alpha = np.asarray(mask_image)
    rgba = np.zeros((height, width, 4), dtype=np.uint8)
    rgba[..., :3] = source
    rgba[..., 3] = alpha
    OUTPUT.parent.mkdir(parents=True, exist_ok=True)
    Image.fromarray(rgba, "RGBA").save(OUTPUT)


if __name__ == "__main__":
    main()
