# SemiSideSheet

侧边栏（上游 Semi SideSheet 全件移植）：声明式（`visible` 驱动显隐，onCancel 只通知，是否关闭由使用方改 `visible`）。标题/内容/自定义 footer、四向 `placement`（top/right/bottom/left，缺省 right）、三档 `size`（small 448 / medium 684 / large 920，仅 left/right 生效）、`width`（仅 left/right）、`height`（仅 top/bottom，缺省 `HEIGHT: 448`）、`mask`/`maskClosable`（false → fixed 模式：投影 + 点击穿透）、`closable`/`closeIcon`、`closeOnEsc`（缺省 false）、`motion`（180ms 四向滑入滑出 + 蒙层渐显）、`afterVisibleChange`（动画完成回调）。弹层底座为 vendored 引擎（`lib/src/overlay/dialog_engine`，PROVENANCE.md）：tag/遮罩/动画入库 `SmartDialog.show`，蒙层点击走 `onCancel`。主题对账 **31 = 19 FIELDS + 12 MOTION + 0 INTERNAL**（variables.scss 19 + animation.scss 12；`$module` 胶水不计，modal `81 = 63 FIELDS + 18 MOTION + 0 INTERNAL` 先例）。★**0 死变量**（sideSheet.scss/rtl.scss 逐条消费）。

## API

`SemiSideSheet({visible, title, content, footer, placement: right, size: small, width, height, mask: true, maskClosable: true, closable: true, closeIcon, closeOnEsc: false, motion: true, onCancel, afterVisibleChange})`。

title/content `Object?`（String | Widget）。footer `Widget?`（null 不渲染 footer 行）。placement `SemiSideSheetPlacement`（`strings.PLACEMENT`）、size `SemiSideSheetSize`（`strings.SIZE`）。onCancel `VoidCallback?`（关闭按钮/蒙层点击（`maskClosable`）/Esc（`closeOnEsc`）只通知，声明式不自关）。afterVisibleChange `void Function(bool)`（上游 `(isVisible: boolean) => void`：入场动画完成后 `true`、出场完成后 `false`）。locale zh 硬编码：「关闭」。

## 行为

### 显隐与回调

声明式 `visible` 驱动（引擎 tag 一一对应）；关闭按钮（`closable`）/蒙层点击（`maskClosable`）/Esc（`closeOnEsc`，上游缺省 false）只通知 `onCancel`（上游 handleCancel→notifyCancel 语义），是否关闭由使用方改 `visible`。`afterVisibleChange` 在入场/出场动画完成后分别回调 `(true)`/`(false)`（上游 CSSAnimation onAnimationEnd → notifyVisibleChange；dispose 强关不通知——上游 componentWillUnmount 语义）。

### 结构（sideSheet.scss `.semi-sidesheet-inner` 族）

内容盒：bg bg2、overflow 由 body 滚动表达、fixed 模式（`mask: false`）inner 加 `box-shadow: var(--semi-shadow-elevated)`（mask 模式无投影）。header 行（`padding: 24`、`padding-bottom: 20`、`border-bottom: 0px solid` border 色——0px 占位边）：标题（`margin: 0`、`font-size: 18`（`$font-size-header-5`）、`font-weight: bold`、`text-0` 色、`text-align: left`，RTL 翻右）+ 关闭钮（tertiary borderless small icon）。body（`padding: 0 24`、`flex: 1`、`overflow: auto`）；footer 行（`padding: 24`，footer 非空时渲染）。left/right：宽 = `width` ?? size 档、高 100%；top/bottom：宽 100%、高 = `height` ?? 448（constants.ts `HEIGHT`）。

### 动画（animation.scss keyframes）

内容：四向滑入滑出——`translateY(-100%)`（top）/ `translateY(100%)`（bottom）/ `translateX(-100%)`（left）/ `translateX(100%)`（right）→ 0（show 正放 / hide 反放），180ms `cubic-bezier(0.25, 0.46, 0.45, 0.94)`；蒙层 `opacity: 0` → 1 渐显（同 180ms 同曲线——引擎主动画统一驱动，modal 蒙层独立简写先例的同值特例）。延迟槽全 0ms。

## 主题（31 对账）

来源 packages/semi-foundation/sideSheet/variables.scss（19 声明）+ animation.scss（12 声明）。**31 = 19 FIELDS + 12 MOTION + 0 INTERNAL**；类型覆盖：**4 Color + 12 double + 1 FontWeight + 2 String = 19** + **8 Duration + 4 Curve = 12**。★quirk 无（variables.scss / animation.scss 冒号空格规整——modal「冒号后无空格/冒号前空格/双分号」怪癖反例）。非数值默认值留档（nav String 先例）：`none`×2 两条 String 字段（backdrop-filter 无 Flutter 对应，消费走布局语义）。全局 token 解析：`overlay-bg`→`colorOverlayBg`、`bg-2`→`colorBg2`、`text-0`→`colorText0`、`border`→`colorBorder`；引用 token：`$spacing-loose`→24、`$spacing-base-loose`→20、`$font-size-header-5`→`theme.typography.fontSizeHeading5`、`$font-weight-bold`→`theme.typography.fontWeightBold`；motion：180ms→Duration、`0ms`→`Duration.zero`、cubic→`Cubic(0.25, 0.46, 0.45, 0.94)`。

### A. Sass 声明映射（19 FIELDS + 12 MOTION）

| Sass 声明（默认值） | 去向 | 解析 / 说明 |
|---|---|---|
| `$color-sideSheet_mask-bg: var(--semi-color-overlay-bg)` | `colorSideSheetMaskBg` | `theme.colors.colorOverlayBg` |
| `$color-sideSheet-bg: var(--semi-color-bg-2)` | `colorSideSheetBg` | `theme.colors.colorBg2` |
| `$color-sideSheet_main-text: var(--semi-color-text-0)` | `colorSideSheetMainText` | `theme.colors.colorText0` |
| `$color-sideSheet_header-borderBottom: var(--semi-color-border)` | `colorSideSheetHeaderBorderBottom` | `theme.colors.colorBorder` |
| `$spacing-sideSheet-margin: 0` | `spacingSideSheetMargin` | `0` |
| `$spacing-sideSheet_title-margin: 0` | `spacingSideSheetTitleMargin` | `0` |
| `$spacing-sideSheet_header-padding: $spacing-loose` | `spacingSideSheetHeaderPadding` | `24` |
| `$spacing-sideSheet_header-paddingBottom: $spacing-base-loose` | `spacingSideSheetHeaderPaddingBottom` | `20` |
| `$spacing-sideSheet_body-paddingY: 0` | `spacingSideSheetBodyPaddingY` | `0` |
| `$spacing-sideSheet_body-paddingX: $spacing-loose` | `spacingSideSheetBodyPaddingX` | `24` |
| `$spacing-sideSheet_footer-padding: $spacing-loose` | `spacingSideSheetFooterPadding` | `24` |
| `$width-sideSheet_header-borderBottom: 0px` | `widthSideSheetHeaderBorderBottom` | `0`（0px 占位边） |
| `$width-sideSheet_size-small: 448px` | `widthSideSheetSizeSmall` | `448` |
| `$width-sideSheet_size-medium: 684px` | `widthSideSheetSizeMedium` | `684` |
| `$width-sideSheet_size-large: 920px` | `widthSideSheetSizeLarge` | `920` |
| `$font-sideSheet_title-fontWeight: $font-weight-bold` | `fontSideSheetTitleFontWeight` | `theme.typography.fontWeightBold` |
| `$font-sideSheet_title-fontSize: $font-size-header-5` | `fontSideSheetTitleFontSize` | `theme.typography.fontSizeHeading5` |
| `$filter-sideSheet_mask-bg: none` | `filterSideSheetMaskBg` | `'none'`（★非数值留档） |
| `$filter-sideSheet-bg: none` | `filterSideSheetBg` | `'none'`（★非数值留档） |
| `$animation_duration-sideSheet_mask-show: 180ms` | `animationDurationSideSheetMaskShow` | `const Duration(milliseconds: 180)` |
| `$animation_function-sideSheet_mask-show: cubic-bezier(0.25, 0.46, 0.45, 0.94)` | `animationFunctionSideSheetMaskShow` | `const Cubic(0.25, 0.46, 0.45, 0.94)` |
| `$animation_delay-sideSheet_mask-show: 0ms` | `animationDelaySideSheetMaskShow` | `Duration.zero` |
| `$animation_duration-sideSheet_mask-hide: 180ms` | `animationDurationSideSheetMaskHide` | `const Duration(milliseconds: 180)` |
| `$animation_function-sideSheet_mask-hide: cubic-bezier(0.25, 0.46, 0.45, 0.94)` | `animationFunctionSideSheetMaskHide` | `const Cubic(0.25, 0.46, 0.45, 0.94)` |
| `$animation_delay-sideSheet_mask-hide: 0ms` | `animationDelaySideSheetMaskHide` | `Duration.zero` |
| `$animation_duration-sideSheet_inner-show: 180ms` | `animationDurationSideSheetInnerShow` | `const Duration(milliseconds: 180)` |
| `$animation_function-sideSheet_inner-show: cubic-bezier(0.25, 0.46, 0.45, 0.94)` | `animationFunctionSideSheetInnerShow` | `const Cubic(0.25, 0.46, 0.45, 0.94)` |
| `$animation_delay-sideSheet_inner-show: 0ms` | `animationDelaySideSheetInnerShow` | `Duration.zero` |
| `$animation_duration-sideSheet_inner-hide: 180ms` | `animationDurationSideSheetInnerHide` | `const Duration(milliseconds: 180)` |
| `$animation_function-sideSheet_inner-hide: cubic-bezier(0.25, 0.46, 0.45, 0.94)` | `animationFunctionSideSheetInnerHide` | `const Cubic(0.25, 0.46, 0.45, 0.94)` |
| `$animation_delay-sideSheet_inner-hide: 0ms` | `animationDelaySideSheetInnerHide` | `Duration.zero` |

### B. HARDCODES 另列（widget 源内含原始片段）

| 上游片段 | 去向 |
|---|---|
| `@include font-size-regular` | 根字号 14 |
| `@include font-size-header-5` | 标题 mixin 18（被显式 `font-size: $font-sideSheet_title-fontSize` 同值覆盖——token 直接消费） |
| `text-align: left` | 标题对齐（rtl.scss 翻 right——Directionality 镜像） |
| `box-shadow: var(--semi-shadow-elevated)` | fixed 模式 inner 投影（`theme.shadows.shadowElevated`） |
| `translateY(-100%)` | top 滑入滑出 keyframe 起点（SlideTransition 表达） |
| `translateY(100%)` | bottom 滑入滑出 keyframe 起点 |
| `translateX(-100%)` | left 滑入滑出 keyframe 起点 |
| `translateX(100%)` | right 滑入滑出 keyframe 起点 |
| `opacity: 0` | 蒙层渐显 keyframes 起点（引擎主动画驱动） |
| `HEIGHT: 448` | top/bottom 缺省高（constants.ts `strings.HEIGHT`） |

## 差异清单

- **弹层底座**：上游 Portal + `document.body` overflow 锁（`disableScroll`）→ vendored 引擎 ambient Overlay 入库（PROVENANCE.md）；蒙层吸收手势即滚动隔离（`disableScroll` 无单独开关，行为隐含）。`getPopupContainer`/`zIndex`/`keepDOM`/`direction`（RTL 走 `Directionality`）/`style`/`maskStyle`/`headerStyle`/`bodyStyle`/`className`/`canVerticalSetWidth` 未移植（层级/定位由引擎与布局层表达）。
- **蒙层动画**：蒙层 `opacity: 0`→1 与内容滑入同 180ms 同曲线，引擎主动画统一驱动（内容四向滑移 + 时长/曲线精确消费，`animation_*-mask-*` 时长/曲线/延迟槽注释引用——同值特例）。
- **宽度/高度字符串**：上游 `width`/`height` 支持 `'50%'` 等字符串 → 只支持数值（`double`）。
- **afterVisibleChange**：上游 onAnimationEnd 通知 → 入场完成后 `Future.delayed(180ms)` 通知 `(true)`、show Future 完成（出场动画结束）通知 `(false)`；dispose 强关不通知（上游 componentWillUnmount 语义）。
- **fixed 模式点击**：`mask: false` 上游无 mask 节点（点击直达页面）→ 引擎 `usePenetrate: true` 点击穿透（蒙层不占位命中）。
