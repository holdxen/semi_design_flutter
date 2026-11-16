# SemiModal

对话框（上游 Semi Modal 全件移植）：声明式（`visible` 驱动显隐，onOk/onCancel 只通知）+ 命令式（`confirm`/`info`/`success`/`warning`/`error` 一族，内部管理显隐 + `destroy`/`update` 句柄）。标题/内容/图标/自定义 header/footer、四档 `size`（small 448 / medium 684 / large 920 / full-width = 视口-64）、`centered`、`fullScreen`、`mask`/`maskClosable`/`maskFixed`（+ `SemiModalRegion` 区域遮罩——`getPopupContainer` 的 Flutter 形态，见差异）、`closable`/`closeIcon`、`closeOnEsc`、`hasCancel`/`okText`/`okType`/`cancelText`、`confirmLoading`/`cancelLoading`、`motion`（120ms scale 0.7→1 + fade）、`footerFill`、`modalRender`。弹层底座为 vendored 引擎（`lib/src/overlay/dialog_engine`，PROVENANCE.md）：tag/队列/遮罩/动画入库 `SmartDialog.show`，蒙层点击与 Esc 走 `onCancel`。主题对账 **81 = 63 FIELDS + 18 MOTION + 0 INTERNAL**（variables.scss 63 + animation.scss 18；`$module` 胶水不计，steps `104 = 94 + 10 + 0`、tabs `144 = 121 + 23 + 0` 先例）。★**0 死变量**（modal.scss/rtl.scss 逐条消费）。

## API

`SemiModal({visible, title, content, icon, header, footer, width, height, size: small, centered: false, mask: true, maskClosable: true, maskFixed: false, closable: true, closeIcon, closeOnEsc: true, hasCancel: true, okText, okType: primary, cancelText, confirmLoading, cancelLoading, onOk, onCancel, afterClose, motion: true, fullScreen: false, footerFill: false, modalRender})`。

`SemiModalRegion({child})`——区域遮罩容器（上游 `getPopupContainer` 容器的 Flutter 形态）：区域内的 Modal 只遮本区域，`maskFixed: true` 强制全窗。

title/content `Object?`（String | Widget）。okType `SemiButtonType`（上游 Button `type` 字符串 → 强类型）。onOk/onCancel `FutureOr<void> Function()?`（返回 `Future` 时按钮 loading 至完成——声明式不自关、命令式完成后关闭；error 变体 `okType` 缺省 `danger`）。size `SemiModalSize`（`strings.SIZE`）。confirm 族：`SemiModal.confirm/info/success/warning/error({...})` → `SemiModalHandle { destroy(), update(...) }`（同名参数 + 可选 `BuildContext? context` 主题锚点，缺省亮色 token）。locale zh 硬编码：「确定」/「取消」/「关闭」（zh_CN.ts Modal）。

## 行为

### 显隐与回调

声明式 `visible` 驱动（引擎 tag 一一对应）；onOk/onCancel/关闭按钮/蒙层点击（`maskClosable`）/Esc（`closeOnEsc`）只通知 `onCancel`（上游 handleCancel→notifyCancel 语义），是否关闭由使用方改 `visible`。命令式内部显隐：ok/cancel 完成即关（上游 ConfirmModal handleOk：promise 则 loading→关，同步即关）；`destroy` 关、`update` 就地重渲染（引擎 controller.refresh）。`afterClose` 在关闭动画完成后回调（上游卸载期 Promise.then）。

### 结构（modal.scss `.semi-modal-content` 族）

内容盒：bg bg2、1px border border 色、圆角 large（fullScreen → 0 无描边）、padding 0/24、shadow-elevated、overflow hidden。header 行（`margin: 24px 0`；confirm 仅覆写 margin-bottom 为 8、顶 24 保持）：icon-wrapper（宽 24 `width-icon-extra-large` + margin-right 12）+ 标题（Typography.Title heading 5）+ 关闭钮（tertiary borderless small icon）。有 icon 时 body `margin-left: 36`（`content_withicon-marginLeft`）；无 header 时 body-wrapper 行（icon + body + closer，margin 24/0）。body `flex: 1 1 auto`（定高容器里吃满余量、footer 推到底部）；footer 行（margin 24/0、`text-align: right`，RTL 翻左）：取消（tertiary）+ 确定（okType），按钮间距 12（RTL 翻右）；`footerFill` 通栏（按钮 block）。非 centered 距顶 80（`margin: 80px auto`）；centered 居中。

### 动画（animation.scss keyframes）

内容：scale 0.7→1 + opacity 0→1，120ms `cubic-bezier(0.215, 0.61, 0.355, 1)`（show 正放 / hide 反放，同曲线）；蒙层 opacity 0→1、90ms 独立时长（见差异清单）。延迟槽全 0ms。

## 主题（81 对账）

来源 packages/semi-foundation/modal/variables.scss（63 声明）+ animation.scss（18 声明）。**81 = 63 FIELDS + 18 MOTION + 0 INTERNAL**；类型覆盖：**13 Color + 46 double + 1 FontWeight + 1 BorderRadius + 1 SemiShadows + 5 String + 8 Duration + 4 Curve + 2 SemiTransform = 81**。★quirk 照抄：`$spacing-modal_footer-paddingY:0`、`$color-modal_header-border:transparent`、`$width-modal_header-border:0`、`$color-modal_footer-border:transparent`、`$width-modal_footer-border:0`（冒号后无空格五条）、`$animation_opacity-modal_content-open : 0`（冒号前空格）、`$radius-modal_footer: 0 0 5px 5px;;`（双分号）。非数值默认值留档（nav String 先例）：`auto`/`max-content`/`calc(100vw - 64px)`/`none`×2 五条 String 字段（消费走布局语义）。全局 token 解析：`bg-2`→`colorBg2`、`overlay-bg`→`colorOverlayBg`、`text-0`→`colorText0`、`info/primary/success/danger/warning`→对应 `color*`、`border`→`colorBorder`、`transparent`→`const Color(0x00000000)`；引用 token：`$spacing-base-tight`→12、`$font-size-regular`→`theme.typography.fontSizeRegular`、`$font-weight-bold`→`theme.typography.fontWeightBold`、`var(--semi-border-radius-large)`→`theme.radius.borderRadiusLarge.value`、`var(--semi-shadow-elevated)`→`theme.shadows.shadowElevated`（SemiShadows，generate_card 先例）；`100%`→100（digits stand-in）；四值圆角→`BorderRadius.vertical(bottom: 5)`；motion：120ms/90ms→Duration、`0ms`→`Duration.zero`、cubic→`Cubic(0.215, 0.61, 0.355, 1)`、0.7→`SemiTransform.scale(0.7, 0.7)`、opacity 0→0。

### A. Sass 声明映射（63 FIELDS + 18 MOTION）

| Sass 声明（默认值） | 去向 | 解析 / 说明 |
|---|---|---|
| `$color-modal-bg: var(--semi-color-bg-2)` | `colorModalBg` | `theme.colors.colorBg2` |
| `$color-modal_mask-bg: var(--semi-color-overlay-bg)` | `colorModalMaskBg` | `theme.colors.colorOverlayBg` |
| `$color-modal_main-text: var(--semi-color-text-0)` | `colorModalMainText` | `theme.colors.colorText0` |
| `$color-modal_info-icon: var(--semi-color-info)` | `colorModalInfoIcon` | `theme.colors.colorInfo` |
| `$color-modal_primary-icon: var(--semi-color-primary)` | `colorModalPrimaryIcon` | `theme.colors.colorPrimary` |
| `$color-modal_success-icon: var(--semi-color-success)` | `colorModalSuccessIcon` | `theme.colors.colorSuccess` |
| `$color-modal_danger-icon: var(--semi-color-danger)` | `colorModalDangerIcon` | `theme.colors.colorDanger` |
| `$color-modal_warning-icon: var(--semi-color-warning)` | `colorModalWarningIcon` | `theme.colors.colorWarning` |
| `$color-modal_content-border: var(--semi-color-border)` | `colorModalContentBorder` | `theme.colors.colorBorder` |
| `$color-modal_header-bg: transparent` | `colorModalHeaderBg` | `const Color(0x00000000)` |
| `$color-modal_footer-bg: transparent` | `colorModalFooterBg` | `const Color(0x00000000)` |
| `$color-modal_header-border:transparent` | `colorModalHeaderBorder` | `const Color(0x00000000)`（★冒号后无空格） |
| `$color-modal_footer-border:transparent` | `colorModalFooterBorder` | `const Color(0x00000000)`（★冒号后无空格） |
| `$spacing-modal-marginY: 80px` | `spacingModalMarginY` | `80` |
| `$spacing-modal-marginX: auto` | `spacingModalMarginX` | `'auto'`（★非数值留档） |
| `$spacing-modal_mask-top: 0` | `spacingModalMaskTop` | `0` |
| `$spacing-modal_mask-right: 0` | `spacingModalMaskRight` | `0` |
| `$spacing-modal_mask-bottom: 0` | `spacingModalMaskBottom` | `0` |
| `$spacing-modal_mask-left: 0` | `spacingModalMaskLeft` | `0` |
| `$spacing-modal_content_withicon-marginLeft: 36px` | `spacingModalContentWithiconMarginLeft` | `36` |
| `$spacing-modal_icon_wrapper-marginRight: $spacing-base-tight` | `spacingModalIconWrapperMarginRight` | `12` |
| `$spacing-modal_wrap-top: 0` | `spacingModalWrapTop` | `0` |
| `$spacing-modal_wrap-right: 0` | `spacingModalWrapRight` | `0` |
| `$spacing-modal_wrap-bottom: 0` | `spacingModalWrapBottom` | `0` |
| `$spacing-modal_wrap-left: 0` | `spacingModalWrapLeft` | `0` |
| `$spacing-modal_title-margin: 0` | `spacingModalTitleMargin` | `0` |
| `$spacing-modal_content-paddingY: 0` | `spacingModalContentPaddingY` | `0` |
| `$spacing-modal_content-paddingX: 24px` | `spacingModalContentPaddingX` | `24` |
| `$spacing-modal_header-marginY: 24px` | `spacingModalHeaderMarginY` | `24` |
| `$spacing-modal_header-marginX: 0` | `spacingModalHeaderMarginX` | `0` |
| `$spacing-modal_header-paddingY: 0` | `spacingModalHeaderPaddingY` | `0` |
| `$spacing-modal_header-paddingX: 0` | `spacingModalHeaderPaddingX` | `0` |
| `$spacing-modal_body_wrapper-marginY: 24px` | `spacingModalBodyWrapperMarginY` | `24` |
| `$spacing-modal_body_wrapper-marginX: 0` | `spacingModalBodyWrapperMarginX` | `0` |
| `$spacing-modal_body-margin: 0` | `spacingModalBodyMargin` | `0` |
| `$spacing-modal_body-padding: 0` | `spacingModalBodyPadding` | `0` |
| `$spacing-modal_footer-marginY: 24px` | `spacingModalFooterMarginY` | `24` |
| `$spacing-modal_footer-marginX: 0` | `spacingModalFooterMarginX` | `0` |
| `$spacing-modal_footer-paddingY:0` | `spacingModalFooterPaddingY` | `0`（★冒号后无空格） |
| `$spacing-modal_footer-paddingX: 0` | `spacingModalFooterPaddingX` | `0` |
| `$spacing-modal_footer_button-marginLeft: $spacing-base-tight` | `spacingModalFooterButtonMarginLeft` | `12` |
| `$spacing-modal_footer_button-marginRight: 0` | `spacingModalFooterButtonMarginRight` | `0`（rtl.scss 消费） |
| `$spacing-modal_confirm_header-marginBottom: 8px` | `spacingModalConfirmHeaderMarginBottom` | `8` |
| `$spacing-modal_confirm_icon_wrapper-marginRight: $spacing-base-tight` | `spacingModalConfirmIconWrapperMarginRight` | `12` |
| `$spacing-modal_content_fullscreen-top: 0px` | `spacingModalContentFullscreenTop` | `0` |
| `$width-modal_title: 100%` | `widthModalTitle` | `100`（digits stand-in） |
| `$width-modal_content: 100%` | `widthModalContent` | `100`（digits stand-in） |
| `$height-modal_content: max-content` | `heightModalContent` | `'max-content'`（★非数值留档） |
| `$width-modal_content-border: 1px` | `widthModalContentBorder` | `1` |
| `$width-modal_small: 448px` | `widthModalSmall` | `448` |
| `$width-modal_medium: 684px` | `widthModalMedium` | `684` |
| `$width-modal_large: 920px` | `widthModalLarge` | `920` |
| `$width-modal_full_width: calc(100vw - 64px)` | `widthModalFullWidth` | `'calc(100vw - 64px)'`（★非数值留档） |
| `$radius-modal_content: var(--semi-border-radius-large)` | `radiusModalContent` | `theme.radius.borderRadiusLarge.value` |
| `$radius-modal_content_fullscreen: 0` | `radiusModalContentFullscreen` | `0` |
| `$radius-modal_footer: 0 0 5px 5px` | `radiusModalFooter` | `BorderRadius.vertical(bottom: Radius.circular(5))`（★双分号 quirk） |
| `$font-modal_header-fontSize: $font-size-regular` | `fontModalHeaderFontSize` | `theme.typography.fontSizeRegular` |
| `$font-modal_header-fontWeight: $font-weight-bold` | `fontModalHeaderFontWeight` | `theme.typography.fontWeightBold` |
| `$width-modal_header-border:0` | `widthModalHeaderBorder` | `0`（★冒号后无空格） |
| `$width-modal_footer-border:0` | `widthModalFooterBorder` | `0`（★冒号后无空格） |
| `$shadow-modal_content: var(--semi-shadow-elevated)` | `shadowModalContent` | `theme.shadows.shadowElevated`（SemiShadows） |
| `$filter-modal_mask-bg: none` | `filterModalMaskBg` | `'none'`（★非数值留档） |
| `$filter-modal_content-bg: none` | `filterModalContentBg` | `'none'`（★非数值留档） |
| `$animation_duration-modal-show: 120ms` | `animationDurationModalShow` | `const Duration(milliseconds: 120)` |
| `$animation_function-modal-show: cubic-bezier(0.215, 0.61, 0.355, 1)` | `animationFunctionModalShow` | `const Cubic(0.215, 0.61, 0.355, 1)` |
| `$animation_delay-modal-show: 0ms` | `animationDelayModalShow` | `Duration.zero` |
| `$animation_duration-modal-hide: 120ms` | `animationDurationModalHide` | `const Duration(milliseconds: 120)` |
| `$animation_function-modal-hide: cubic-bezier(0.215, 0.61, 0.355, 1)` | `animationFunctionModalHide` | `const Cubic(0.215, 0.61, 0.355, 1)` |
| `$animation_delay-modal-hide: 0ms` | `animationDelayModalHide` | `Duration.zero` |
| `$animation_duration-modal_mask-show: 90ms` | `animationDurationModalMaskShow` | `const Duration(milliseconds: 90)` |
| `$animation_function-modal_mask-show: cubic-bezier(0.215, 0.61, 0.355, 1)` | `animationFunctionModalMaskShow` | `const Cubic(0.215, 0.61, 0.355, 1)` |
| `$animation_delay-modal_mask-show: 0ms` | `animationDelayModalMaskShow` | `Duration.zero` |
| `$animation_duration-modal_mask-hide: 90ms` | `animationDurationModalMaskHide` | `const Duration(milliseconds: 90)` |
| `$animation_function-modal_mask-hide: cubic-bezier(0.215, 0.61, 0.355, 1)` | `animationFunctionModalMaskHide` | `const Cubic(0.215, 0.61, 0.355, 1)` |
| `$animation_delay-modal_mask-hide: 0ms` | `animationDelayModalMaskHide` | `Duration.zero` |
| `$animation_transform_scale-modal_content-open: 0.7` | `animationTransformScaleModalContentOpen` | `const SemiTransform.scale(0.7, 0.7)` |
| `$animation_opacity-modal_content-open : 0` | `animationOpacityModalContentOpen` | `0`（★冒号前空格 quirk） |
| `$animation_transform_scale-modal_content-close: 0.7` | `animationTransformScaleModalContentClose` | `const SemiTransform.scale(0.7, 0.7)` |
| `$animation_opacity-modal_content-close: 0` | `animationOpacityModalContentClose` | `0` |
| `$animation_opacity-modal_mask-open: 0` | `animationOpacityModalMaskOpen` | `0` |
| `$animation_opacity-modal_mask-close: 0` | `animationOpacityModalMaskClose` | `0` |

### B. HARDCODES 另列（widget 源内含原始片段）

| 上游片段 | 去向 |
|---|---|
| `@include font-size-regular` | 根字号 14（标题实际走 Title heading-5——见差异） |
| `margin: auto` | centered 居中覆写（alignment 表达） |
| `align-items: flex-start` | 上游居中技巧（auto margin）注释引用 |
| `overflow: auto` | wrap 滚动语义（引擎弹层自持，注释引用） |
| `calc(100vw - 64px)` | fullWidth 尺寸消费（视口 - 64） |
| `$width-icon-extra-large` | 图标槽宽 24 |
| `text-align: right` | footer 对齐（RTL 翻左） |
| `$z-modal-mask` | 蒙层层级（引擎插入序表达） |

## 差异清单

- **弹层底座**：上游 Portal + `document.body` overflow 锁 → vendored 引擎 ambient Overlay 入库（PROVENANCE.md）；`getContainerContext`/`zIndex`/`keepDOM`/`lazyRender`/`direction`（RTL 走 `Directionality`）/`style`/`maskStyle`/`bodyStyle`/`className` 未移植（层级/定位由引擎与布局层表达）。
- **区域遮罩（getPopupContainer/maskFixed）**：上游 `getPopupContainer: () => el` DOM 回调 + 容器 `position: relative` → Flutter 形态为 `SemiModalRegion` scope 包裹器（就近挂载判据，不取回调——DOM 容器选择的 Flutter 对应物是 scope + 就近渲染）；区域内的 Modal（命令式族传区域内 `context`）只遮区域——modal.scss:210-216 `.semi-modal-popup` mask/wrap `position: absolute` + `overflow: hidden` 语义（ClipRect + 层 Stack 表达），区域层消费同款 120ms scale/fade 动画 token。`maskFixed` 照名移植（区域内仍走全窗引擎路——modal.scss:218-222 `.semi-modal-fixed`）。body 滚动锁只在挂 body 时生效（Modal.tsx:141-151）→ 区域模式不锁滚动；区域为专用 scope，不劫持区域内 tooltip 等弹层的 ambient Overlay 路由（同上游逐组件 `getPopupContainer` 粒度）。
- **居中语义**：`align-items: flex-start` + auto margin 的「内容超高时退化为顶部+滚动」技巧 → 弹层为绝对定位居中（超高内容由弹层自滚），居中简化为 `Alignment.center`。
- **标题字号**：`font-modal_header-*`（14/bold）被 `Typography.Title heading 5`（18）覆盖的 CSS specificity quirk → 渲染 SemiTitle heading 5，两 token 注释引用。
- **蒙层动画**：蒙层独立 90ms 简写时长随引擎主动画（120ms）渐显，`modal_mask-*` 时长/曲线/延迟/opacity 槽注释引用（内容 scale/opacity/曲线/时长精确消费）。
- **async 按钮 loading**：上游 `onCancelReturnPromiseStatus` 自动 loading → `FutureOr` 回调返回 `Future` 时按钮 loading（语义等价）。
- **useModal hook**：React hooks 形态无 Flutter 对应（声明式 + 静态族覆盖其能力）。
