from pathlib import Path

import numpy as np
from PIL import Image


source_path = Path(r"D:\pokemon\素材\场景\底图.png")
out_dir = source_path.parent
source = np.asarray(Image.open(source_path).convert("RGBA"))
height, width = source.shape[:2]

# Visible content windows measured on the native 246x129 source.
content = np.zeros((height, width), dtype=bool)
content[4:17, 4:242] = True
content[21:100, 5:241] = True
content[104:119, 10:236] = True


def export(mask: np.ndarray, name: str) -> None:
    rgba = source.copy()
    rgba[..., 3] = mask.astype(np.uint8) * 255
    Image.fromarray(rgba, "RGBA").save(out_dir / name)


export(content, "底图-地图内容.png")
export(~content, "底图-边框覆盖.png")

recomposed = np.zeros_like(source)
recomposed[content] = source[content]
recomposed[~content] = source[~content]
Image.fromarray(recomposed, "RGBA").save(out_dir / "底图-拆分重组校验.png")
delta = np.abs(recomposed[..., :3].astype(np.int16) - source[..., :3].astype(np.int16))
print({"size": [width, height], "changed_pixels": int(np.any(delta != 0, axis=2).sum()), "max_error": int(delta.max())})
