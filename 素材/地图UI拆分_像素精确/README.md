# 地图 UI 像素精确拆分

源图尺寸：`1672x941`。所有 PNG 都在源图原始坐标导出，透明通道由源图边缘遮罩生成，RGB 保留源图像素。

## 目录

- `background/`：画布外背景、顶部背景、地图纹理
- `frames/`：外部阴影、金属外框、标题分隔线、地图视口框、底部图例框
- `header/`：Run、货币、Map/Team/Bag/Relics、关闭按钮
- `panels/`：路线标题、进度、图例内容底
- `map/route-connectors.png`：路线连接线
- `nodes/`：起点、终点和 21 个路线节点
- `labels/`：START、BOSS 文字
- `icons/`、`shared/`：可复用节点图标与节点边框

`layers.json` 是 Godot 导入清单，包含源图坐标、层级、点击区域和隐藏像素说明。

`preview/verification.txt`：当前重组结果覆盖率 100%，RGB 差异为 0。

注意：PNG 是扁平图，按钮覆盖区域下的原始背景没有可恢复信息；这部分地图底图在清单中标记为 `inferred_hidden_pixels`。
