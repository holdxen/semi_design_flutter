# SemiCropper

图片裁切（上游 Semi Cropper 全件移植）：`src` 图片适配容器居中、遮罩拖动平移图片、滚轮/触控板指针定点缩放（`zoomStep` 步进取两位小数、`minZoom`/`maxZoom` 钳制）、拖动裁切框（容器内钳制）、8 角柄自由缩放裁切框（定比 [aspectRatio] 时按方向范围钳制、拖过零点 `changeDir` 翻柄）、`rotate` 旋转（受控）、`preview` 实时预览、`getCropperCanvas` 原图分辨率裁切输出。`shape`：`rect`（8 柄）/ `round`（4 边中点柄，外框与视口同形）/ `roundRect`（8 柄，视口 `border-radius: 50%` 椭圆裁切）。主题对账 **5 = 5 FIELDS + 0 MOTION + 0 INTERNAL**（variables.scss 5 声明：color 3、width 2；无 animation.scss；`$module` 胶水与 cropper.scss 局部 `$half_corner_width: calc($width-cropper_box_corner / 2)` 不计，banner `22 = 22 + 0 + 0`、carousel `40 = 34 + 6 + 0` 先例）；★**0 死变量**（cropper.scss 逐条消费）。

## API

`SemiCropper({image, shape: rect, aspectRatio, defaultAspectRatio: 1, zoom, onZoomChange, rotate, showResizeBox: true, fill: Color(0x00000000), maxZoom: 3, minZoom: 0.1, zoomStep: 0.1, previewBuilder, controller})`。

image `ImageProvider`（上游 `src`）。shape `SemiCropperShape`（rect/round/roundRect，缺省 rect）。aspectRatio `double?`（非空定比拖动）；defaultAspectRatio `double`（缺省 1，仅初始裁切框生效，拖动后随拖动变化）。zoom `double?`（非 null 即受控，同上游 `getDerivedStateFromProps`）+ onZoomChange `ValueChanged<double>?`。rotate `double?`（受控角度，度）。showResizeBox `bool`（缺省 true）。fill `Color`（裁切结果非图片部分填充，缺省透明）。maxZoom/minZoom/zoomStep（缺省 3 / 0.1 / 0.1）。previewBuilder `(context, cropper, cropView) => Widget`（实时预览布局；cropView 在给定约束内按上游 `updatePreview` 适配数学自缩放）。controller `SemiCropperController`：`getCropperImage(): Future<ui.Image>`（上游 ref 方法 `getCropperCanvas`）、`isAttached`。

尺寸：上游容器 `style` 定宽高，Flutter 需父级给出有界宽高（如 SizedBox）。

## 行为

### 初始适配

图片加载后按容器内适配（长边贴边、居中），显示尺寸 = 原图 × `scale` × `zoom`；裁切框按 `aspectRatio || defaultAspectRatio` 取容器内最大内接框、居中（foundation.ts handleImageLoad）。容器宽向变化按宽比缩放图片与裁切框并钳回新容器（handleResize / getCropperBoxWhenResize，仅宽向触发——上游 ResizeObserver ObserverProperty.Width）。

### 缩放与旋转

滚轮缩放以指针为定点（中心点绕指针缩放），步进 `(currZoom + zoomStep).toFixed(2)`、`minZoom`/`maxZoom` 钳制，回调 onZoomChange（foundation.ts handleWheel）。受控 zoom/rotate 变化时按 `getDerivedStateFromProps` 公式重算图片中心（以裁切框中心为锚点；y 翻转见 foundation 注释 `centerPoint 的 y 坐标与实际的坐标系方向相反`）。

### 裁切框

拖框移动：中心钳制在 `[宽/2, 容器宽-宽/2]`（handleCropperBoxMouseDown/Move）；角柄命中（`target.dataset.dir`）不触发移动。角柄缩放：自由模式各向独立（越零翻柄）；定比模式按 `getRangeForAspectChange` 方向范围 + `getAspectHW` 内收（handleCornerAspectMouseMove），尺寸归零 `changeDir` 翻柄重算范围。角柄光标按方向（nwse/nesw/ns/ew-resize → `resizeUpLeftDownRight`/`resizeUpRightDownLeft`/`resizeUpDown`/`resizeLeftRight`；macOS 对角线退化见差异清单）。角柄钳回容器整只可命中（见差异清单）。`round` 形状仅显示 `tm`/`ml`/`mr`/`bm` 四柄。

### 图片拖动与预览

遮罩按下拖动平移图片（无边界钳制，可拖出视野，handleMaskMouseDown/handleImgMove；`-mask` `cursor: move;;` 双分号 quirk）。预览（updatePreview）：cropView 按裁切框适配缩放入自己的约束框，图片按相对裁切框的位移/尺寸/旋转渲染。

### 裁切输出

`getCropperImage()`（getCropperCanvas）：以原图分辨率构造旋转外接矩形，fill 底色 + 旋转贴图，裁切框区域换算到外接矩形坐标（`realZoom = zoom * scale`），越界部分补 fill（clamp 后修正贴图偏移 `relativeCropLeft < 0 ? - relativeCropLeft : 0`），输出 `ui.Image`（PNG 编码由应用 `toByteData` 处理）。无交集时返回纯 fill 图。

## 主题（5 对账）

来源 packages/semi-foundation/cropper/variables.scss（5 声明，无 animation.scss）。对账 **5 = 5 FIELDS + 0 MOTION + 0 INTERNAL**（HARDCODES 另列见 B 表）。★**0 死变量**。全局 token 解析：`var(--semi-color-overlay-bg)` → `theme.colors.colorOverlayBg`、`var(--semi-color-primary)` → `theme.colors.colorPrimary`（generate_banner 先例）。类型覆盖：**3 Color + 2 double = 5 FIELDS**。解析列即 `SemiCropperThemeData.resolve` 默认表达式。

### A. Sass 声明映射（5 FIELDS）

| Sass 声明（默认值） | 去向 | 解析 / 说明 |
|---|---|---|
| `$color-cropper_mask-bg: var(--semi-color-overlay-bg)` | `colorCropperMaskBg` | `theme.colors.colorOverlayBg`（★注释照抄 `// 裁切框遮罩背景颜色`） |
| `$color-cropper_box-outline: var(--semi-color-primary)` | `colorCropperBoxOutline` | `theme.colors.colorPrimary`（★注释照抄 `// 裁切框边框颜色`——实为 outline 外描边） |
| `$color-cropper_box_corner-bg: var(--semi-color-primary)` | `colorCropperBoxCornerBg` | `theme.colors.colorPrimary`（★注释照抄 `// 裁切框调整块背景色`） |
| `$width-cropper_box-outline: 1px` | `widthCropperBoxOutline` | `1`（★注释照抄 `// 裁切框边框宽度`；outline 外描边宽） |
| `$width-cropper_box_corner: 10px` | `widthCropperBoxCorner` | `10`（★注释照抄 `// 裁切框调整块宽高`；正方形边长，经 `$half_corner_width: calc($width-cropper_box_corner / 2)` 半宽偏移消费） |

★quirk 照抄：variables.scss 五条行尾注释逐字留档；cropper.scss `-mask` 规则 `cursor: move;;` 双分号、`-br` 行 `cursor: nwse-resize` 缺分号、`-bm` 行 `margin-left: -$half_corner_width;` 行尾空格、`-view-img` 注释残留 `// position: absolute;`（均在 widget 文件头注释照抄）。

### B. HARDCODES 另列（widget 文件头注释 / 调用点，源内含原始片段）

| 上游片段 | 说明 |
|---|---|
| `${BASE_CLASS_PREFIX}-cropper` | constants.ts moduleName 类名胶水 |
| `shape: ['rect', 'round', 'roundRect']` | 对外枚举 |
| `'tl', 'tm', 'tr', 'ml', 'mr', 'bl', 'bm', 'br'` | 8 角柄方向 |
| `'tm', 'ml', 'mr', 'bm'` | round 仅四边中点柄 |
| defaultProps `shape: 'rect'` / `defaultAspectRatio: 1` / `showResizeBox: true` | 缺省形态 |
| defaultProps `fill: 'rgba(0, 0, 0, 0)'` / `maxZoom: 3` / `minZoom: 0.1` / `zoomStep: 0.1` | 缺省填色与缩放域 |
| `crossOrigin='anonymous'` / `transformOrigin: 'center'` | img 节点属性（前者不适用，留档） |
| `max-width: none` / `user-select: none` | cropper.scss tailwindCSS 防污 / 禁选 |
| `cursor: move;;` / `cursor: nwse-resize` | 遮罩 move 双分号 quirk / 角柄光标（br 缺分号） |
| `$half_corner_width: calc($width-cropper_box_corner / 2)` / `-$half_corner_width` | 角柄半宽外偏（bm 行尾空格 quirk） |
| `// position: absolute;` | `-view-img` 注释残留 |
| `border-radius: 50%` | `-view-box-round` 椭圆裁切 |
| `{ passive: false }` + `e.preventDefault()` | wheel 注册防页面缩放（Flutter 无页面缩放语义） |
| `(currZoom + zoomStep).toFixed(2)` | 缩放步进两位小数 |
| `centerPoint 的 y 坐标与实际的坐标系方向相反` | 受控同步 y 翻转公式注释 |
| `viewIMGDragStart` | 视口图片拖影抑制 |
| `target.dataset.dir` | 角柄命中不移动裁切框 |
| `ObserverProperty.Width` | ResizeObserver 仅宽向 |
| `getAspectHW` / `getMiddle` / `changeDir` | utils.ts 等比内收 / 钳值 / 越界翻柄 |
| `fillRect(0, 0, relativeWidth, relativeHeight)` / `getImageData(realLeft, realTop, realWidth, realHeight)` / `relativeCropLeft < 0 ? - relativeCropLeft : 0` | 裁切输出补 fill / 区域钳制 / 偏移修正 |

重新生成独立主题：`python3 tool/generate_cropper.py`（包含 dart format）；对账校验 `python3 tool/test_generate_cropper.py`。

## 差异清单

- **src**：`string` URL → `ImageProvider`（应用选 NetworkImage/AssetImage/MemoryImage）。
- **getCropperCanvas**：ref 方法 → `SemiCropperController.getCropperImage()` 返回 `Future<ui.Image>`（原图分辨率；`canvas.toDataURL()` 由应用 `toByteData(png)` 等价）。
- **preview**：`preview: () => HTMLElement`（容器制，foundation 改写容器尺寸）→ `previewBuilder(context, cropper, cropView)` 返回同时布局两者的子树；cropView 自适应给定约束（适配数学照抄 updatePreview），不改写宿主容器尺寸。
- **cropperBoxStyle/cropperBoxCls**：→ 走 `SemiCropperTheme` 局部覆盖（颜色/描边宽/角柄尺寸）；类名机制不移植。
- **imgProps**：透传 img 属性不移植（`crossOrigin='anonymous'`、`alt=""`、onLoad 透传均不适用）；样式裁切定位由内部状态承担（上游亦然）。
- **className/style**：外层布局承担（SizedBox/ConstrainedBox）。
- **wheel preventDefault**：`{ passive: false }`/`e.preventDefault()` 防页面缩放不适用（Flutter 指针信号无页面滚动）；触控板滚动等价走 PointerScrollEvent。
- **裁切输出像素替换**：`putImageData`（整像素替换）→ `BlendMode.src` 贴图（语义一致）；旋转贴图重采样 FilterQuality.none（上游 canvas 平滑由浏览器决定）。
- **ResizeObserver**：仅观察 Width → LayoutBuilder 宽向触发（高度单独变化不重算缩放数学，行为照抄；但容器尺寸记录会更新，定比拖动范围按新高度计算——上游完全不感知高度变化，此处更符合直觉）。
- **viewIMGDragStart**：HTML 拖影抑制不适用（Flutter 图片不可拖拽），留档。
- **未移植 API**：`aspectRatio` 受控语义保留（变化仅影响后续拖动，照抄 componentDidUpdate）。
- **角柄钳回容器**：上游角柄以 `$half_corner_width` 半格外悬裁切框角（DOM 命中不受父盒边界限制，外悬部分可点可悬停）；Flutter `RenderBox.hitTest` 不收自身边界外的点，裁切框贴住容器边（初始态即顶满容器高）时外悬半格落在容器外成死区——拖不动、光标不切换，故柄位钳回 `[0, 容器-柄]` 整只可命中（不贴边时与上游同形）。
- **角柄光标 kind**：上游 CSS 全双向（`nwse`/`nesw`/`ns`/`ew-resize`）→ `resizeUpLeftDownRight`/`resizeUpRightDownLeft`/`resizeUpDown`/`resizeLeftRight`；macOS 桌面引擎 cursor 表无对角线光标（NSCursor 公共 API 缺失，flutter/flutter#138887 → #89351 跟踪，未映射 → 箭头），`nwse` 组退化 `resizeUpDown`、`nesw` 组退化 `resizeLeftRight`（Web 无此缺口不退化）。
- **平移光标 kind**：上游 `-mask`/`-view-box` 的 `cursor: move` → `SystemMouseCursors.move`；macOS 引擎 cursor 表无 `move`（WebKit 走私有 CoreCursor `kCoreCursorWindowMove`，Flutter 的 NSCursor 表未映射 → 箭头），改为 `SystemMouseCursors.none` 隐藏系统光标 + 组件内自绘四向箭头跟随指针（`SemiCropper.moveCursorKey`），Web/Windows/Linux 走系统 move。

## 用法

```dart
SemiCropper(
  image: NetworkImage('https://example.com/image.png'),
  shape: SemiCropperShape.rect,
  controller: controller,
)
```

```dart
// 受控旋转/缩放 + 实时预览 + 裁切输出
SemiCropper(
  image: image,
  rotate: rotate,
  zoom: zoom,
  onZoomChange: (z) => setState(() => zoom = z),
  previewBuilder: (context, cropper, cropView) => Row(children: [
    SizedBox(width: 550, height: 300, child: cropper),
    SizedBox(width: 300, height: 300, child: cropView),
  ]),
  controller: controller,
)

// 裁切结果
final ui.Image result = await controller.getCropperImage();
```
