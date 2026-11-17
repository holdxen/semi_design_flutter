# SemiImage

上游 Semi Image（图片 + 全屏预览层）全件移植：加载状态机（loading/success/error）、占位与失败回退、点击开预览、图库分组（`SemiImagePreview`，递归扫描 children 派发索引、共享 lightbox）、缩放（滚轮定桩 / ± / slider）、旋转、拖拽平移、适应窗口 ↔ 原始尺寸、上一张/下一张（取模换页）、下载回调、预加载（crossMerge 交叉序）、操作栏自动隐藏、Esc/遮罩关闭。★Flutter 差异：`src` 由 string URL 化为 `ImageProvider`；lazyLoad 仅保留 API（无 IntersectionObserver 等价）；下载由 `onDownload`/`onDownloadError` 回调驱动（web `fetch(src)`→anchor 不可移植）；crossOrigin/getPopupContainer/imgStyle/imgCls 等 web 专有项裁剪；body 滚动锁不适用。

主题对账 **52 = 44 FIELDS + 8 MOTION + 0 INTERNAL**（variables.scss 44 声明 + animation.scss 8 声明；`$module` 类名胶水与 rtl.scss `direction: rtl` 不计；datePicker `223 = 220 + 3 + 0`、avatar `99 = 89 FIELDS + 10 MOTION + 0 INTERNAL`、upload `85 = 85 + 0 + 0` 先例）。★8 死变量（`$spacing-image_mask_info_text-marginTop`、`$color-image_mask-bg`、`$color-image_mask_info_text`、`$color-image_preview-bg`、`$transition_duration-image_preview_image_img`、`$transition_function-image_preview_image_img`、`$transition_delay-image_preview_image_img`、`$transform_rotate-image_preview_spinner`，见下），全部落 theme 标（上游未消费）、widget 不消费。

## API

`SemiImage({required ImageProvider image, double? width, double? height, String? alt, Widget? placeholder, Widget? fallback, bool preview = true, SemiImagePreviewProps? previewProps, VoidCallback? onLoad, VoidCallback? onError, VoidCallback? onClick, int? imageID})` —— [image] 主图源（上游 `src`）；[width]/[height] 外层盒与图尺寸；[alt] 语义描述；[placeholder] 加载占位（缺省 `Skeleton.Image` → SemiSkeletonImage）；[fallback] 失败回退（上游 `string | ReactNode` 统一 Widget，缺省 `IconUploadError` → SemiIcons.uploadError）；[preview] 上游 `preview: true`；[previewProps] 对象形式（高清源 `src`、`defaultVisible`/受控 `visible`、缩放档位、回调群）；[onLoad]/[onError]/[onClick]；[imageID] 组内索引（上游 `imageID: index++` 注入，缺省组内扫描解析）。加载状态机 `loading → success | error`（换源重置）；成功且 preview 显示 `cursor: zoom-in`；失败图 `opacity: 0`。

`SemiImagePreview({required List<Widget> children, SemiImagePreviewProps props = const SemiImagePreviewProps(), List<ImageProvider> src = const [], bool lazyLoad = true, String lazyLoadMargin = '0px 100px 100px 0px', String Function(ImageProvider)? setDownloadName, TextStyle? style, String? className})` —— 图库容器（上游 `Preview`，根导出名 `ImagePreview`）。递归扫描 children 中 SemiImage 合并 src/title；[src] 显式源在前（★quirk：`finalSrcList = [...srcArr, ...children]` 与 `imageID` 前缀错位照搬）；[props] 受控/非受控 `visible`/`currentIndex` 与 lightbox 配置；[lazyLoad]/[lazyLoadMargin] 仅保留 API。

`SemiImagePreviewInner({required SemiImagePreviewProps props})` —— lightbox 本体（上游 `PreviewInner`），ambient Overlay 插入序表达 `$z-image_preview`。`SemiImagePreviewProps`：`visible/defaultVisible`、`currentIndex/defaultCurrentIndex`、`src`、`previewTitle`、`maskClosable=true`、`closable=true`、`zoomStep=0.1`、`infinite=false`、`showTooltip=false`、`closeOnEsc=true`、`lazyLoad=false`、`preLoad=true`、`preLoadGap=2`、`disableDownload=false`、`viewerVisibleDelay=10000`、`zIndex=1070`（`DEFAULT_Z_INDEX: 1070`，仅 API 对齐）、`maxZoom=5`、`minZoom=0.1`、`initialZoom`、八条 tip 文案、`renderLeftIcon/renderRightIcon/renderCloseIcon/renderHeader/renderPreviewMenu`、回调 `onVisibleChange/onChange/onClose/onZoomIn/onZoomOut/onPrev/onNext/onRatioChange/onRotateLeft/onDownload/onDownloadError`、`setDownloadName`。`SemiImageRatioType { adaptation, realSize }`。

## 行为

### 加载状态与回退
loading 期 overlay 显示 placeholder（包 `.semi-image-status`：`$color-image_status-bg` 底、`$radius-image` 圆角）或缺省 Skeleton.Image；error 显示 fallback 或缺省 uploadError 图标（`$color-image_status` 色）；error 图本体 `opacity: 0`。换 src 重置 `loadStatus: "loading"`。

### 预览开关
`canPreview = loadStatus === "success" && preview && !isInGroup()`；点击（preview falsy 不响应）：组内 `setCurrentIndex(imageID)` + `handleVisibleChange(true)`，组外开私有 PreviewInner。对象形式 `preview.visible` 受控（`handlePreviewVisibleChange` 只回调不写 state），`defaultVisible` 初始可见。

### 缩放/旋转/拖拽
滚轮 ±`zoomStep`（`toFixed(2)` 两位小数、`Math.min(max, Math.max(min, zoom))` 钳制）且指针定桩（0/90/180/270 分象限 `(e.offsetX - 0.5 * width) * (1 - newZoom / currZoom) + translate.x`）；±/slider 同钳制；`initialZoom` 每 src 只应用一次（`_initialZoomAppliedSrc`）；`adaptation` zoom = `Math.min((containerWidth-80)/bound, ...)` 旋转感知包围盒（`width * cosTheta + height * sinTheta`）；`realSize` zoom=1；切换图片/打开时 `ratio` 重置 `willUpdateStates.ratio = 'adaptation'`、`rotation: 0`；旋转 `ROTATE_STEP = 90` 双向，`onRotateLeft` 透出绝对角度；拖拽仅左键（`e.buttons === 1`）且平移 `Math.min(translateX, extremeX)` 钳制、按可拖方向分轴生效。

### 换页与关闭
`showPrev = total !== 1 && (infinite || currentIndex !== 0)`（next 对称）；切换 `(currentIndexInState + step + srcLength) % srcLength`（恒取模，回调 `onPrev/onNext` 带方向）；Esc（`e.keyCode === KeyCode.ESC`，closeOnEsc）关；遮罩点击关闭需 mouseup 目标非 icon/footer（`composedPath()`）且 5px 内（`Math.abs(clientX - x) > 5 || Math.abs(y - clientY) > 5` 不关）；打开后 `viewerVisibleDelay`（10s）无操作自动隐藏操作栏（mousemove 节流 50ms 复位，chrome 区不清不显）。

### Footer/Slider
菜单序 `getIconChevronLeft | n/m | chevronRight | ⫶ | − | slider | + | 比例 | ⫶ | 旋转 | 下载`（`menuItems.splice(3, 0` 与 `menuItems.splice(8, 0` 在首插后列表定位：分隔线落 chevronRight 后与 比例/旋转 之间，下载仅带 -gap）；slider 调缩放（百分比档缺省 `min: 10`/`max: 500`/`step: 10`、tip `` `${v}%` ``、onChange 节流 50ms）；± 极值禁用（`preview-footer-disabled` = `$color-image_preview_disabled`）；比例钮显示目标模式（`ratio === "adaptation" ? "realSize" : "adaptation"`）；旋转钮 `handleRotateLeft` 恒左旋；下载钮 `disableDownload` 禁用；`showTooltip` 包 Tooltip（`zIndex={zIndex + 1}`）。

### 图库与预加载
组扫描（`imageID: index++`）：源 `preview.src ?? src`、标题 `preview.previewTitle`（header `titles[currentIndex]` 覆盖）；预加载：首载完成后 `crossMerge` 交叉序整段预载（±gap 外扩），此后按方向预载 `currentIndex ± preLoadGap`（infinite 取模否则止步）。

## 主题（52 对账）

对账 **52 = 44 FIELDS + 8 MOTION + 0 INTERNAL**（HARDCODES 另列见 B 表）。全局 token 解析：`var(--semi-color-overlay-bg)` → `theme.colors.colorOverlayBg`、`var(--semi-color-white)` → `theme.colors.colorWhite`、`var(--semi-color-fill-0)` → `theme.colors.colorFill0`、`var(--semi-color-disabled-text)` → `theme.colors.colorDisabledText`、`var(--semi-border-radius-small/medium)` → `theme.radius.borderRadiusSmall/Medium.value`、`var(--semi-transform_rotate-clockwise360deg/clockwise180deg)` → `theme.motion.transformRotateClockwise360deg/Clockwise180deg`、`var(--semi-transform-rotate-none)` → `theme.motion.transformRotateNone`、ms → `Duration`、`cubic-bezier(...)` → `Cubic(...)`、裸 rgba/#ccc → `const Color.fromRGBO/Color(0x…)` 字面量。类型覆盖 **29 double + 15 Color + 4 SemiTransform + 3 Duration + 1 Curve**。解析列即 `SemiImageThemeData.resolve` 默认表达式。

### A. Sass 声明映射（44 FIELDS + 8 MOTION）

| Sass 声明（默认值） | 去向 | 解析 / 说明 |
|---|---|---|
| `$spacing-image_mask_info_text-marginTop: 8px` | FIELDS（上游未消费） | ★事实死：renderMask 死代码 + 无 `.semi-image-mask` 规则 |
| `$spacing-image_preview_icon-x: 24px` | FIELDS `spacingImagePreviewIconX` | 24，prev/next 侧距 |
| `$spacing-image_preview_header-paddingY: 0` | FIELDS `spacingImagePreviewHeaderPaddingY` | 0 |
| `$spacing-image_preview_header-paddingX: 24px` | FIELDS `spacingImagePreviewHeaderPaddingX` | 24 |
| `$spacing-image_preview_footer-paddingY: 0` | FIELDS `spacingImagePreviewFooterPaddingY` | 0 |
| `$spacing-image_preview_footer-paddingX: 16px` | FIELDS `spacingImagePreviewFooterPaddingX` | 16 |
| `$spacing-image_preview_footer_page-marginY: 0` | FIELDS `spacingImagePreviewFooterPageMarginY` | 0 |
| `$spacing-image_preview_footer_page-marginX: 12px` | FIELDS `spacingImagePreviewFooterPageMarginX` | 12 |
| `$spacing-image_preview_footer_slider-paddingY: 0` | FIELDS `spacingImagePreviewFooterSliderPaddingY` | 0 |
| `$spacing-image_preview_footer_slider-paddingX: 16px` | FIELDS `spacingImagePreviewFooterSliderPaddingX` | 16 |
| `$spacing-image_preview_footer_slider_handle-marginTop: 8px` | FIELDS `spacingImagePreviewFooterSliderHandleMarginTop` | 8 |
| `$spacing-image_preview_footer_divider-marginY: 0` | FIELDS `spacingImagePreviewFooterDividerMarginY` | 0 |
| `$spacing-image_preview_footer_divider-marginX: 16px` | FIELDS `spacingImagePreviewFooterDividerMarginX` | 16 |
| `$spacing-image_preview_footer_gap-marginLeft: 16px` | FIELDS `spacingImagePreviewFooterGapMarginLeft` | 16，图标组间距 |
| `$spacing-image_preview_footer_gap_rtl-marginLeft: 0` | FIELDS `spacingImagePreviewFooterGapRtlMarginLeft` | 0，rtl gap 翻转 |
| `$width-image_preview_footer_slider: 132px` | FIELDS `widthImagePreviewFooterSlider` | 132 |
| `$width-image_preview_footer_slider_handle: 16px` | FIELDS `widthImagePreviewFooterSliderHandle` | 16 |
| `$width-image_preview_icon: 40px` | FIELDS `widthImagePreviewIcon` | 40 |
| `$width-image_preview_header_close: 30px` | FIELDS `widthImagePreviewHeaderClose` | 30 |
| `$height-image_preview_header: 60px` | FIELDS `heightImagePreviewHeader` | 60 |
| `$height-image_preview_footer: 48px` | FIELDS `heightImagePreviewFooter` | 48 |
| `$height-image_preview_footer_slider: 2px` | FIELDS `heightImagePreviewFooterSlider` | 2 |
| `$height-image_preview_footer_slider_handle: 16px` | FIELDS `heightImagePreviewFooterSliderHandle` | 16 |
| `$height-image_preview_icon: 40px` | FIELDS `heightImagePreviewIcon` | 40 |
| `$height-image_preview_header_close: 30px` | FIELDS `heightImagePreviewHeaderClose` | 30 |
| `$radius-image: var(--semi-border-radius-small)` | FIELDS `radiusImage` | `theme.radius.borderRadiusSmall.value` |
| `$radius-image_preview_footer: var(--semi-border-radius-medium)` | FIELDS `radiusImagePreviewFooter` | `theme.radius.borderRadiusMedium.value` |
| `$color-image_mask-bg: var(--semi-color-overlay-bg)` | FIELDS（上游未消费） | ★事实死，同 mask 三兄弟 |
| `$color-image_mask_info_text: var(--semi-color-white)` | FIELDS（上游未消费） | ★事实死，同 mask 三兄弟 |
| `$color-image_status-bg: var(--semi-color-fill-0)` | FIELDS `colorImageStatusBg` | `theme.colors.colorFill0` |
| `$color-image_status: var(--semi-color-disabled-text)` | FIELDS `colorImageStatus` | `theme.colors.colorDisabledText` |
| `$color-image_preview-bg: var(--semi-color-overlay-bg)` | FIELDS（上游未消费） | ★事实死：image.scss:70 硬编码覆盖 |
| `$color-image_preview_icon: var(--semi-color-white)` | FIELDS `colorImagePreviewIcon` | `theme.colors.colorWhite` |
| `$color-image_preview_header: var(--semi-color-white)` | FIELDS `colorImagePreviewHeader` | `theme.colors.colorWhite` |
| `$color-image_preview_footer_icon: var(--semi-color-white)` | FIELDS `colorImagePreviewFooterIcon` | `theme.colors.colorWhite` |
| `$color-image_preview_footer_slider_rail: var(--semi-color-white)` | FIELDS `colorImagePreviewFooterSliderRail` | `theme.colors.colorWhite` |
| `$color-image_preview_disabled: rgba(249, 249, 249, 0.35)` | FIELDS `colorImagePreviewDisabled` | `const Color.fromRGBO(249, 249, 249, 0.35)` ★明暗一致字面量 |
| `$color-image_preview_icon-bg: rgba(0, 0, 0, 0.75)` | FIELDS `colorImagePreviewIconBg` | `const Color.fromRGBO(0, 0, 0, 0.75)` ★明暗一致字面量 |
| `$color-image_header_close-bg: rgba(0, 0, 0, 0.75)` | FIELDS `colorImageHeaderCloseBg` | `const Color.fromRGBO(0, 0, 0, 0.75)` ★明暗一致字面量 |
| `$color-image_preview_footer-bg: rgba(0, 0, 0, 0.75)` | FIELDS `colorImagePreviewFooterBg` | `const Color.fromRGBO(0, 0, 0, 0.75)` ★明暗一致字面量 |
| `$color-image-preview_divider-bg: rgba(255, 255, 255, .5)` | FIELDS `colorImagePreviewDividerBg` | `const Color.fromRGBO(255, 255, 255, 0.5)` ★命名 `image-preview` 连字符不一致照抄 |
| `$color-image_preview_image_spin: #ccc` | FIELDS `colorImagePreviewImageSpin` | `const Color(0xFFCCCCCC)` ★明暗一致字面量 |
| `$z-image_preview: 1070 !default` | FIELDS `zImagePreview` | 1070（★`!default`；footer tooltip 取 +1） |
| `$z-image_preview_header: 1 !default` | FIELDS `zImagePreviewHeader` | 1（★`!default`；header Stack 绘制序） |
| `$transform_rotate-image_preview_spinner: var(--semi-transform_rotate-clockwise360deg)` | MOTION（上游未消费） | ★事实死：只被 image.scss:237 死 `@keyframes spinner` 引用 |
| `$transform_scale3d-image_preview_image_img: 1, 1, 1` | MOTION `transformScale3dImagePreviewImageImg` | `const SemiTransform.scale(1, 1)` ★scale3d z 维丢弃 |
| `$transform_rotate-image_preview_image_img: var(--semi-transform-rotate-none)` | MOTION `transformRotateImagePreviewImageImg` | `theme.motion.transformRotateNone` ★token 连字符拼写照抄 |
| `$transition_duration-image_preview_image_img: 300ms` | MOTION（上游未消费） | ★事实死：image.scss:220 注释行 |
| `$transition_function-image_preview_image_img: cubic-bezier(0.215, 0.61, 0.355, 1)` | MOTION（上游未消费） | ★事实死：零引用 |
| `$transition_delay-image_preview_image_img: 0s` | MOTION（上游未消费） | ★事实死：image.scss:220 注释行 |
| `$transition_duration-image_preview: 500ms` | MOTION `transitionDurationImagePreview` | `const Duration(milliseconds: 500)`，chrome 淡入淡出 |
| `$transform_rotate-image_preview_icon_rtl: var(--semi-transform_rotate-clockwise180deg)` | MOTION `transformRotateImagePreviewIconRtl` | `theme.motion.transformRotateClockwise180deg`，rtl 箭头 180° |

### B. HARDCODES 另列（widget 文件头注释 / 调用点，源内含原始片段）

| 上游片段 | 落点 |
|---|---|
| `preview: true` | SemiImage 缺省可预览 |
| `renderMask` + `IconEyeOpened` + `getLocalTextByKey("preview")` | 死代码留档，不复现 |
| `Skeleton.Image` / `IconUploadError` | 加载/失败缺省 |
| `preview.src ?? src` | 高清源回落 |
| `max-width: none`（`the max-width of img/video is set to 100%`） | tailwind 兼容留档 |
| `cursor: zoom-in` / `&-error`（opacity 0） | 成功可预览光标 / 失败隐藏 |
| `background-color: var(--semi-color-overlay-bg)` | 预览层背景硬编码（`$color-image_preview-bg` 死因） |
| `.#{$module}-preview-hide` + `z-index: 0` + `border-radius: 50%` + `bottom: 16px` + `transform: translate(-50%, -50%)` + `pointer-events: none` | 预览层布局硬编码 |
| `font-size-regular` / `font-size-header-6` | header / 页码字型 |
| `@keyframes spinner` + `// transition: transform $transition_duration-image_preview_image_img` + `img[src=""], img:not([src])` | 死 CSS / 空 src 规则留档 |
| `direction: rtl` + `margin-right: $spacing-image_preview_footer_gap-marginLeft` + `$transform_rotate-image_preview_icon-rtl` | rtl 换侧 / gap 翻转 / 箭头旋转 |
| `DEFAULT_Z_INDEX: 1070` + `zoomStep: 0.1`…`minZoom: 0.1` | previewInner.tsx defaultProps 群 |
| `lazyLoadMargin: '0px 100px 100px 0px'` | 组缺省 |
| `imageID: index++` | 组索引派发 |
| `ROTATE_STEP = 90` + `Math.abs(clientX - x) > 5 \|\| Math.abs(y - clientY) > 5` + `e.keyCode === KeyCode.ESC` | 旋转步进 / 关闭容差 / Esc |
| `(currentIndexInState + step + srcLength) % srcLength` | 取模换页 |
| `lastIndexOf("/") + 1).split('?')[0]` + `fetch(src)` | 下载文件名 / web 落盘机制 |
| `(currZoom + zoomStep).toFixed(2)` + `Math.min(max, Math.max(min, zoom))` | 缩放步进与钳制 |
| `containerWidth - 80` + `reservedWidth / imageWidth, reservedHeight / imageHeight).toFixed(2)` | 自适应缩放 |
| `_initialZoomAppliedSrc` + `width * cosTheta + height * sinTheta` | initialZoom 一次 / 包围盒 |
| `(e.offsetX - 0.5 * width) * (1 - newZoom / currZoom) + translate.x` + `e.buttons === 1` + `Math.min(translateX, extremeX)` | 定桩 / 拖拽 / 平移钳制 |
| `min: 10` + `max: 500` + `step: 10` + `` `${v}%` `` + `}, 50)` | footer slider 档位 / tip / 节流 |
| `getIconChevronLeft` + `menuItems.splice(3, 0` + `menuItems.splice(8, 0` | 菜单序与分隔线位 |
| `ratio === "adaptation" ? "realSize" : "adaptation"` + `handleRotateLeft` | 比例切换 / 仅左旋 |
| `zIndex={zIndex + 1}` + `preview-footer-disabled` | tooltip 层级 / 禁用态 |
| `titles[currentIndex]` | 组标题覆盖 |
| `crossMerge` + `composedPath()` + `total !== 1 && (infinite \|\| currentIndex !== 0)` | 预加载序 / 关闭目标 / prev 显隐 |
| `document.body.style.overflow` + `willUpdateStates.ratio = 'adaptation'` | body 锁（不适用）/ 重置 |

## 差异清单

1. ★照搬留档：`$color-image-preview_divider-bg` 命名连字符不一致；`--semi-transform-rotate-none` 连字符拼写 token；scale3d `1, 1, 1` z 维丢弃为 `SemiTransform.scale(1, 1)`；组 `src[]` 与 children 同用时 `imageID` 前缀错位（上游即错）；previewImage `clickZoom` 死 prop 不复现；maskClosable 判 mouseup 目标（icon/footer 免关、header 不免）。
2. 偏差：`src` string → `ImageProvider`（NetworkImage 的文件名推导走 `url`）；下载回调驱动（`onDownload(src, index)`/`onDownloadError`，`setDownloadName` 保留）；lazyLoad/lazyLoadMargin 无 IntersectionObserver 等价（不延迟加载）；crossOrigin/getPopupContainer/imgStyle/imgCls/contextmenu 禁存、body 滚动锁、`renderMask` 遮罩（死代码）裁剪；footer slider 以自绘几何直吃主题字段（上游全量覆盖 slider 样式）；操作栏淡入淡出用 `transitionDurationImagePreview`（500ms）；rtl 实现换侧/翻转/箭头旋转三项。
3. 裁剪：`ImageStates`/`PreviewInnerStates` 等 React 状态类、Portal/getPopupContainer 容器定制、`onLoad/onError` 事件对象（改 VoidCallback）。

## 用法

```dart
// 基础 + 失败回退
SemiImage(
  image: NetworkImage('https://example.com/a.png'),
  width: 160,
  height: 120,
  fallback: const SemiIcon(SemiIcons.uploadError),
)

// 单图预览（缩放/旋转/下载回调）
SemiImage(
  image: NetworkImage('https://example.com/hi-res.png'),
  previewProps: SemiImagePreviewProps(
    zoomStep: 0.2,
    infinite: true,
    showTooltip: true,
    onDownload: (src, index) => saveImage(src),
    onVisibleChange: (v) => debugPrint('preview $v'),
  ),
)

// 图库分组
SemiImagePreview(
  props: const SemiImagePreviewProps(defaultCurrentIndex: 0),
  children: [
    SemiImage(image: a, previewProps: SemiImagePreviewProps(previewTitle: Text('图一'))),
    SemiImage(image: b),
  ],
)

// 主题覆盖
SemiTheme(
  data: SemiThemeData.light().copyWith(
    components: const SemiComponentThemes(
      image: SemiImageThemeData(heightImagePreviewHeader: 72, widthImagePreviewFooterSlider: 160),
    ),
  ),
  child: const MyApp(),
)
```
