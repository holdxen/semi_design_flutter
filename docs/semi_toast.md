# SemiToast

轻提示（上游 Semi Toast 核心交互移植）：命令式 `SemiToast.show/info/warning/error/success` 返回 toastId（上游 `toast-{timestamp}-{random}`），多条纵向堆叠（旧上新下、12px 外边距、水平居中、默认顶部 `top` 缺省 0）、`duration` 秒制自动关闭（缺省 3，`0` 不自动关）、悬停暂停/离开全量重启、同 id 重复调用原地更新并重启计时、`close(id)`/`destroyAll()`、normal/light 双主题（light = 浅色底 + 1px 描边 + light-icon 色，仅四类型）、`showClose`/`onClose`/`textMaxWidth: 450`/自定义 `icon`、进出场动画（300ms 过冲 `cubic-bezier(.22,.57,.02,1.2)`，show 自顶跌入 / hide 向上滑出）、stack 卡组模式（`stack: true`，透视叠牌 + 悬停展开）、RTL。主题对账 **47 = 35 FIELDS + 12 MOTION + 0 INTERNAL**（variables.scss 35 声明：color 18、spacing 13、width 2、radius 1、font 1；animation.scss 12 声明：show/hide/stack 三组 duration/function/delay + opacity/translateY 各二；`$module` 胶水与 rtl.scss 不计，sideSheet `31 = 19 + 12 + 0`、modal `81 = 63 + 18 + 0` 先例）；★**0 死变量**（toast.scss/rtl.scss 逐条消费，四 stack 字段全部消费；constants.ts `cssClasses.LIST` 是死常量但非 Sass 变量）。`useToast` / `ToastFactory.create` 未移植，见差异清单。

## API

`SemiToast.show/info/warning/error/success({content, id, duration, showClose, icon, textMaxWidth, theme, stack, direction, onClose, context}) -> String`；`SemiToast.config({top, left, duration, theme, stack, context})`；`SemiToast.close(id)`；`SemiToast.destroyAll()`。

show 为 `type: 'default'`（无图标；上游 `Toast.create`/`useToast().open`；'default' 是 Dart 关键字，枚举名 `SemiToastType.defaultType`）。content `Object?`（String/num → Text，Widget 原样；缺省空串同上游 `content: ''`）。id `String?`（缺省自动生成；同 id 原地更新并重启计时）。duration `double?` 秒制（缺省 config.duration ?? 3；`0` 不自动关——上游 `if (duration && isNumber(duration))`）。showClose 缺省 true。icon `Widget?`（替换类型默认图标，原样渲染——上游对 SemiIcon 克隆 `size: 'large'`，此处不强制）。textMaxWidth `double?` 缺省 450（仅数值，上游 string|number）。theme `SemiToastThemeMode?`（normal/light，缺省 config.theme ?? normal）。direction `TextDirection?`（缺省环境 Directionality，上游 `props.direction || context.direction`）。onClose `VoidCallback?`（自动/手动关闭都回调，同上游）。context `BuildContext?`（上游 `getPopupContainer` 等价：目标 Overlay + 调用处主题快照；缺省环境 Overlay + 环境主题）。

config 为全局缺省（上游 `Toast.config` + semiGlobal 覆盖语义）：null 项保持现值。`stack`（`bool?`）上游不经 `Toast.config` 而经 semiGlobal `overrideDefaultProps.Toast` 全局生效——本移植并入 config（调用级参数优先）；★卡组开关为**列表级**，每次调用覆写（上游 `Boolean(mergedOpts.stack)`，未传视为 false——last-call-wins quirk）。`zIndex`（上游缺省 1010）与 `bottom`/`right` 未移植——层级由 Overlay 插入序表达；`bottom`/`right` 上游即因过约束不生效（见行为）。

## 行为

### 堆叠与定位

- 单个全宽 OverlayEntry（上游 wrapper 一次创建；容器首个展示时确定，`getPopupContainer() ?? document.body` → `context` 指定 Overlay ?? 环境 Overlay）。多条按调用序纵向排列（DOM 序 = 列表序，旧上新下），内容盒 `margin: 12`（相邻净距 24）。
- wrapper `position: fixed; height: 0; top: 0; width: 100%` + `justify-content: center`：默认贴顶（`top` 可配偏移）、水平居中；`left: N` 平移 +N（上游 width 过伸效果）。★上游 `bottom`/`right` 因 wrapper `height: 0`/`width: 100%` 过约束被 CSS 忽略（over-constrained ignore bottom/right），不提供参数。
- `translate3d(0,0,-10px*i)` 纵深由 stack 卡组消费（见下）。

### stack 卡组（`stack: true`，v2.42）

- **列表级开关**（上游 `ToastList.ref.stack`）：每次调用按该次参数覆写（未传 = false，★last-call-wins quirk），对全部条目生效；`destroyAll` 后复位。
- **非悬停（叠牌）**：各条目重叠于卡组原点（`&-zero-height-wrapper` `height: 0` + `overflow: visible;` 语义，宿主高度取透视包络），按 `translate3d(0,0,${reservedIndex * -10}px)` 每条后退 10px，经 `perspective: 280px` + `perspective-origin: center 280px`（★`perspective-origin: center $spacing-toast-perspective-originY; ;` 双分号 quirk）投影成后退叠牌——旧条目向下收缩退远、新条目在最前。
- **悬停展开**：`stackExpanded: this.state.mouseInSide`（`handleMouseInSideChange`）展开为常规列表（条目按量高插值排开、间距同普通堆叠 24+内容高）；`.semi-toast-innerWrapper-hover` 的 `perspective: unset` 扁平化卡组。悬停区贴内容宽/高（innerWrapper `width: fit-content`，独立命中层 `opaque: false` + translucent，不挡卡片点击与条目悬停计时）——鼠标水平移开即收起。离开悬停收起。展开/收起按 `transition: all $animation_duration-toast-stack $animation_function-toast-stack;`（300ms 过冲）过渡。
- 条目高度 post-frame 量高（ResizeObserver 语义迁移）。

### 计时与更新

- 每条独立计时（toastFoundation）：`duration*1000` ms 后关闭并回调 `onClose`；`duration: 0` 仅手动关。悬停（`onMouseEnter={this.clearCloseTimer}`/`onMouseLeave={this.startCloseTimer}`）暂停计时、离开**全量重启**（非续时，同上游 `startCloseTimer_()`）。
- 同 id 重复调用：原地替换配置并 `restartCloseTimer()`（toastListFoundation `Reused instances need new timers, including same-id replacements before the next render.`）；离场中复出按新实例处理（新进场动画）。
- `close(id)` 标记离场 → 离场动画结束裁剪（上游仅 leave onAnimationEnd 清理）；`onClose` 在关闭发起时回调（上游 `notifyWrapperToRemove` + `notifyClose`）。`destroyAll()` 清列表与宿主、不回调 `onClose`。
- `static pendingToasts`（挂载前 pending 队列）无对应——show 即入库。

### 视觉

- 结构：content 盒（`display: inline-flex` + `align-items: flex-start`，bg-3 底、圆角 medium、`@include shadow-elevated`、`@include font-size-regular` 14 + 字重 bold、padding 12/8）> [icon 20x20, text（左右外边距 12、maxWidth 450、`text-align: left`、break-word）, close 钮（`type="tertiary"` borderless small `IconClose`，`height: $width-icon-large` 20 + margin-top -2px 负值上提）]。
- normal：`color-toast-bg-default` 底、类型图标语义色；light（仅 warning/success/info/error）：`*_light-bg` 底 + `width-toast_light-border` 1px `*_light-border` 描边 + `*_light-icon` 图标色。`type: 'default'` 无图标、无 light 样式。
- 语义：`role="alert"` → `Semantics(liveRegion: true)` + `aria-label={`${type ? type : 'default'} type`}`；关闭钮语义标签 '关闭'。

### 动画

show keyframes（`animation-fill-mode: forwards`）：`opacity: 0` + `transform: translateY(-100%)`（元素自身高）→ 1/0；hide 反向。300ms `cubic-bezier(.22,.57,.02,1.2)`（★小数点裸写 `.22`；过冲可越界，opacity 依 CSS 钳制）；delay `0s`（★`0s` 写法）。正放 show 曲线、反放 hide 曲线。

### RTL

rtl.scss `text-align: right` + text 边距互换（两侧同值 12，no-op）→ `TextAlign.right` + EdgeInsetsDirectional 自动翻转；内容行序随 Directionality 镜像。

## 主题（47 对账）

来源 packages/semi-foundation/toast/variables.scss（35 声明）+ animation.scss（12 声明）。对账 **47 = 35 FIELDS + 12 MOTION + 0 INTERNAL**（HARDCODES 另列见 B 表）。★**0 死变量**。全局 token 解析：`var(--semi-color-bg-3)` → `theme.colors.colorBg3`、`var(--semi-color-text-0)` → `theme.colors.colorText0`、`var(--semi-color-{warning,success,info,danger})` → `theme.colors.color*`、`var(--semi-color-*-light-default)` → `theme.colors.color*LightDefault`（generate_banner.py 先例）；`var(--semi-border-radius-medium)` → `theme.radius.borderRadiusMedium.value`（generate_button.py 先例）；引用 token：`$spacing-base-tight` → 12、`$spacing-tight` → 8（generate_modal.py 先例）、`$font-weight-bold` → `theme.typography.fontWeightBold`（FontWeight 类型 generate_side_sheet.py 先例）。非数值默认值：`100%` → 100、`-100%` → -100（digits stand-in，modal `100%` 先例）。Motion：`300ms` → `const Duration(milliseconds: 300)`、`0s` → `Duration.zero`、`cubic-bezier(.22,.57,.02,1.2)` → `const Cubic(0.22, 0.57, 0.02, 1.2)`。类型覆盖：**18 Color + 20 double + 1 FontWeight + 5 Duration + 3 Curve = 47**。解析列即 `SemiToastThemeData.resolve` 默认表达式。

### A. Sass 声明映射（35 FIELDS + 12 MOTION）

| Sass 声明（默认值） | 去向 | 解析 / 说明 |
|---|---|---|
| `$color-toast-bg-default: var(--semi-color-bg-3)` | `colorToastBgDefault` | `theme.colors.colorBg3` |
| `$color-toast-text-default: var(--semi-color-text-0)` | `colorToastTextDefault` | `theme.colors.colorText0` |
| `$color-toast_warning-icon: var(--semi-color-warning)` | `colorToastWarningIcon` | `theme.colors.colorWarning` |
| `$color-toast_success-icon: var(--semi-color-success)` | `colorToastSuccessIcon` | `theme.colors.colorSuccess` |
| `$color-toast_info-icon: var(--semi-color-info)` | `colorToastInfoIcon` | `theme.colors.colorInfo` |
| `$color-toast_danger-icon: var(--semi-color-danger)` | `colorToastDangerIcon` | `theme.colors.colorDanger` |
| `$color-toast_warning_light-bg: var(--semi-color-warning-light-default)` | `colorToastWarningLightBg` | `theme.colors.colorWarningLightDefault` |
| `$color-toast_warning_light-icon: $color-toast_warning-icon` | `colorToastWarningLightIcon` | `theme.colors.colorWarning`（组内引用同 `colorToastWarningIcon`） |
| `$color-toast_warning_light-border: var(--semi-color-warning)` | `colorToastWarningLightBorder` | `theme.colors.colorWarning` |
| `$color-toast_success_light-bg: var(--semi-color-success-light-default)` | `colorToastSuccessLightBg` | `theme.colors.colorSuccessLightDefault` |
| `$color-toast_success_light-icon: $color-toast_success-icon` | `colorToastSuccessLightIcon` | `theme.colors.colorSuccess`（组内引用同 `colorToastSuccessIcon`） |
| `$color-toast_success_light-border: var(--semi-color-success)` | `colorToastSuccessLightBorder` | `theme.colors.colorSuccess` |
| `$color-toast_info_light-bg: var(--semi-color-info-light-default)` | `colorToastInfoLightBg` | `theme.colors.colorInfoLightDefault` |
| `$color-toast_info_light-icon: $color-toast_info-icon` | `colorToastInfoLightIcon` | `theme.colors.colorInfo`（组内引用同 `colorToastInfoIcon`） |
| `$color-toast_info_light-border: var(--semi-color-info)` | `colorToastInfoLightBorder` | `theme.colors.colorInfo` |
| `$color-toast_danger_light-bg: var(--semi-color-danger-light-default)` | `colorToastDangerLightBg` | `theme.colors.colorDangerLightDefault` |
| `$color-toast_danger_light-icon: $color-toast_danger-icon` | `colorToastDangerLightIcon` | `theme.colors.colorDanger`（组内引用同 `colorToastDangerIcon`） |
| `$color-toast_danger_light-border: var(--semi-color-danger)` | `colorToastDangerLightBorder` | `theme.colors.colorDanger` |
| `$spacing-toast_wrapper-top: 0` | `spacingToastWrapperTop` | `0`（wrapper 顶偏移缺省） |
| `$spacing-toast_content-paddingY: $spacing-base-tight` | `spacingToastContentPaddingY` | `12`（padding 上下的 Sass 中间引用） |
| `$spacing-toast_content-paddingX: $spacing-tight` | `spacingToastContentPaddingX` | `8`（padding 左右的 Sass 中间引用） |
| `$spacing-toast_content-paddingTop: $spacing-toast_content-paddingY` | `spacingToastContentPaddingTop` | `12` |
| `$spacing-toast_content-paddingBottom: $spacing-toast_content-paddingY` | `spacingToastContentPaddingBottom` | `12` |
| `$spacing-toast_content-paddingLeft: $spacing-toast_content-paddingX` | `spacingToastContentPaddingLeft` | `8` |
| `$spacing-toast_content-paddingRight: $spacing-toast_content-paddingX` | `spacingToastContentPaddingRight` | `8` |
| `$spacing-toast_content-margin: $spacing-base-tight` | `spacingToastContentMargin` | `12` |
| `$spacing-toast_content_close_btn-marginTop: -2px` | `spacingToastContentCloseBtnMarginTop` | `-2`（★负值，关闭钮上提） |
| `$spacing-toast_content_text-marginLeft: $spacing-base-tight` | `spacingToastContentTextMarginLeft` | `12` |
| `$spacing-toast_content_text-marginRight: $spacing-base-tight` | `spacingToastContentTextMarginRight` | `12`（rtl 互换 no-op 两侧同值） |
| `$spacing-toast-perspective-originY: 280px` | `spacingToastPerspectiveOriginY` | `280`（★分类照抄：Spacing 组内实为 3D 透视原点 Y；stack 卡组透视叠牌消费） |
| `$spacing-toast-perspective: 280px` | `spacingToastPerspective` | `280`（★分类照抄：实为透视距离；stack 卡组透视叠牌消费） |
| `$width-toast_wrapper: 100%` | `widthToastWrapper` | `100`（★digits stand-in；全宽 Align 居中表达） |
| `$width-toast_light-border: 1px` | `widthToastLightBorder` | `1`（★分类照抄：Width/Height 组内实为描边宽度） |
| `$radius-toast_content: var(--semi-border-radius-medium)` | `radiusToastContent` | `theme.radius.borderRadiusMedium.value` |
| `$font-toast_content-fontWeight: $font-weight-bold` | `fontToastContentFontWeight` | `theme.typography.fontWeightBold`（FontWeight） |
| `$animation_duration-toast-show: 300ms` | `animationDurationToastShow` | `const Duration(milliseconds: 300)` |
| `$animation_duration-toast-hide: 300ms` | `animationDurationToastHide` | `const Duration(milliseconds: 300)` |
| `$animation_function-toast-show: cubic-bezier(.22,.57,.02,1.2)` | `animationFunctionToastShow` | `const Cubic(0.22, 0.57, 0.02, 1.2)`（★小数点裸写 normalize） |
| `$animation_function-toast-hide: cubic-bezier(.22,.57,.02,1.2)` | `animationFunctionToastHide` | `const Cubic(0.22, 0.57, 0.02, 1.2)` |
| `$animation_delay-toast-show: 0s` | `animationDelayToastShow` | `Duration.zero`（★`0s` 写法） |
| `$animation_delay-toast-hide: 0s` | `animationDelayToastHide` | `Duration.zero` |
| `$animation_opacity-toast-show: 0` | `animationOpacityToastShow` | `0`（keyframe show 起点） |
| `$animation_opacity-toast-hide: 0` | `animationOpacityToastHide` | `0`（keyframe hide 终点） |
| `$animation_transform_translateY-toast-show: -100%` | `animationTransformTranslateYToastShow` | `-100`（★digits stand-in，元素自身高 -100%：自顶跌入） |
| `$animation_transform_translateY-toast-hide: -100%` | `animationTransformTranslateYToastHide` | `-100`（向上滑出） |
| `$animation_duration-toast-stack: 300ms` | `animationDurationToastStack` | `const Duration(milliseconds: 300)`（stack 展开/收起过渡消费） |
| `$animation_function-toast-stack: cubic-bezier(.22,.57,.02,1.2)` | `animationFunctionToastStack` | `const Cubic(0.22, 0.57, 0.02, 1.2)`（★末行无分号 quirk 照抄；stack 展开/收起过渡消费） |

★quirk 照抄：`animation.scss` 末行 `$animation_function-toast-stack: …` **行尾无分号**；`cubic-bezier(.22,.57,.02,1.2)` 小数点裸写（`.22` 等）；`$spacing-toast-perspective-originY`/`$spacing-toast-perspective` 归在 // Spacing 注释组实为 3D 透视参数、`$width-toast_light-border` 归在 // Width/Height 实为描边宽度、`$width-toast_wrapper: 100%` 百分比——分类与注释字面照抄。

### B. HARDCODES 另列（widget 文件头注释 / 调用点，源内含原始片段）

| 上游片段 | 说明 |
|---|---|
| constants.ts `types: ['warning', 'success', 'info', 'error', 'default']` | 对外类型枚举 |
| constants.ts `themes: ['normal', 'light']` / `directions: ['ltr', 'rtl']` | 主题/方向枚举 |
| constants.ts `duration: 3 // default close time, unit: s` | 秒制缺省；`duration: 0` 不自动关 |
| defaultProps `textMaxWidth: 450` / `showClose: true` / `theme: 'normal'` | 缺省参数 |
| `IconAlertTriangle` / `IconTickCircle` / `IconInfoCircle` / `IconAlertCircle` | 类型图标（warning/success/info/error） |
| `iconSize = 'large'` | 类型图标 20x20 |
| `type="tertiary"` / `const btnTheme = 'borderless';` / `const btnSize = 'small';` | 关闭钮形态 |
| `IconClose` | 默认关闭图标 |
| `height: $width-icon-large` | close-button 高 20（width 变量作 height）+ margin-top -2px |
| `role="alert"` + `aria-label={`${type ? type : 'default'} type`}` | live region 语义 |
| wrapper `position: fixed;` / `height: 0;` / `top: $spacing-toast_wrapper-top;` / `width: $width-toast_wrapper;` / `justify-content: center;` / `z-index: $z-toast` | 容器几何（zIndex 由 Overlay 插入序表达） |
| `pointer-events: none;` / `pointer-events: all;` | 命中穿透（Overlay 空白区自然表达） |
| `@include shadow-elevated;` / `@include font-size-regular;` | 投影/根字号 mixin |
| `display: inline-flex;` / `align-items: flex-start;` | content 布局 |
| `textStyle.maxWidth = textMaxWidth;` / `text-align: left;` / `word-wrap: break-word;` / `overflow-wrap: break-word;` | 文本盒 |
| `translate3d(0,0,${reservedIndex * -10}px)` | stack 卡组纵深（未移植留档） |
| `transform: translateY($animation_transform_translateY-toast-show);` + `animation-fill-mode: forwards;` | show keyframe |
| `onMouseEnter={this.clearCloseTimer}` / `onMouseLeave={this.startCloseTimer}` | 悬停暂停/重启（`clearCloseTimer_()`/`startCloseTimer_()`/`restartCloseTimer()`） |
| `Reused instances need new timers, including same-id replacements before the next render.` | 同 id 更新重启计时语义 |
| `getUuid('toast')` / `getUuidShort({ prefix: 'toast-wrapper' })` / `static pendingToasts` | id/wrapper 命名 + 挂载前队列（无对应） |
| `e.stopPropagation();` + `notifyWrapperToRemove(this._id);` | foundation close |
| `getPopupContainer() ?? document.body` | 容器缺省 |
| constants.ts `LIST: `${PREFIX}-list`` | 死常量（上游未消费，非 Sass 变量） |
| `perspective-origin: center $spacing-toast-perspective-originY; ;` | ★双分号 quirk（stack 卡组透视原点） |
| `&-zero-height-wrapper` + `height: 0;` + `overflow: visible;` | 卡组折叠槽（重叠叠牌，宿主高度取透视包络） |
| `transition: all $animation_duration-toast-stack $animation_function-toast-stack;` | 展开/收起过渡（300ms 过冲） |
| `stackExpanded: this.state.mouseInSide`（`handleMouseInSideChange`） | 悬停展开/收起（ResizeObserver 量高迁移 post-frame） |
| `.semi-toast-innerWrapper-hover` | 展开态 `perspective: unset` 扁平化卡组 |
| rtl.scss `text-align: right;` / `margin-left: $spacing-toast_content_text-marginRight;` | RTL 镜像（互换 no-op） |

重新生成独立主题：`python3 tool/generate_toast.py`（包含 dart format）；对账校验 `python3 tool/test_generate_toast.py`。

## 差异清单

- **stack 卡组实现近似**：`perspective: unset` 上游不可插值（CSS 过渡 50% 离散翻转）→ 本实现同为离散切换（展开过半时透视消失/收起过半恢复）；ResizeObserver 量高 → post-frame 量高（首帧量高前条目位置有单帧滞后）；卡组开关按上游 `Boolean(mergedOpts.stack)` 列表级 last-call-wins。
- **`useToast` hook / `ToastFactory.create` 未移植**：React hooks/工厂形态无 Flutter 对应；独立实例需求后续按需评估 `SemiToast` 实例化方案。
- **定位**：上游 `bottom`/`right` 因 wrapper `height: 0`/`width: 100%` 过约束被 CSS 忽略（over-constrained ignore bottom/right）——仅提供 `top`/`left`（上游实际生效项）；`zIndex`（缺省 1010）由 Overlay 插入序表达，无参数。
- **content**：上游 ReactNode → `Object?`（String/num → Text，Widget 原样）。`textMaxWidth` 仅数值（上游 string|number）。
- **icon**：上游对 SemiIcon 克隆 `size: 'large'`/className → `Widget?` 原样渲染（不强制尺寸）。
- **onClose**：上游 `() => void` 相同；`close(e)` 的 `e.stopPropagation()` 不适用（Flutter 无冒泡）。
- **pendingToasts**：上游挂载前 pending 队列 → show 即入库（宿主惰性创建）。
- **离场中同 id 复出**：上游 Set 去重渲染语义含混 → 按新实例处理（新进场动画）。
- **离场动画位置**：上游把 removedItems 渲染在列表末尾（离场条目瞬移到列表底部淡出、存活条目立刻补位）→ 本实现离场条目原位淡出、动画结束裁剪后存活条目补位（补位语义一致，无空位残留）。
- **break-word**：CSS `word-wrap`/`overflow-wrap` → Flutter 软换行 + ConstrainedBox 尺寸约束（超长单词断行细节依平台文本布局）。
- **`className`/`style` 未移植**（外层布局承担）。
- **主题解析**：带 `context` 调用时快照（含本地 `SemiToastTheme` patch）；缺省宿主构建时随环境主题（SemiModal `_resolveTheme` 先例）。
- **RTL**：rtl.scss 镜像 → EdgeInsetsDirectional + Directionality 自动翻转（物理等价）。
- **inset 阴影层由专用画师渲染**：Flutter 无 CSS inset box-shadow 对应物——drop 层进 BoxDecoration（`toDropBoxShadows()`）、inset 层（dark `--semi-shadow-elevated` 首层 `inset 0 0 0 1px`）由 `SemiInsetShadow` 画师精确绘制（贴 padding-box 的内环、零布局影响）；`toBoxShadows()` 对 inset 抛错的显式合同保留，带 blur/offset 的 inset 层构造即抛。

## 用法

```dart
SemiToast.success('保存成功');
SemiToast.error(
  content: '上传失败，请重试',
  duration: 0, // 不自动关闭
  onClose: () => print('closed'),
);
```

```dart
SemiToast.config(top: 80, theme: SemiToastThemeMode.light, duration: 5);
final id = SemiToast.info('正在导出…', id: 'export');
SemiToast.info('导出完成', id: 'export'); // 同 id 原地更新并重启计时
SemiToast.close(id);
SemiToast.destroyAll();
```

```dart
// stack 卡组：透视叠牌，悬停展开为常规列表。
SemiToast.config(stack: true, duration: 0);
SemiToast.info('第一条');
SemiToast.info('第二条');
SemiToast.info('第三条'); // 叠牌最前
```
