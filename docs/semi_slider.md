# SemiSlider

非 Material 滑动条。值模型单值 `double` / range `List<double>`（长度 2），轨道几何完全按 slider.scss：wrapper 32 高（horizontal，`height-slider_wrapper`）+ 13px X 内边距；rail/track 4 高、top 14；handle 24×24 圆 + `margin-top: 4`（垂直时 `margin-left: -10` 对齐 4px 轨）；刻度点 4×4 top 14（`calc(... - 2px)` 居中）；刻度标签 top 23；boundary top 30。拖拽以指针-手柄中心偏移为准并全程保留（手柄不跳向光标）。★输出恒过 `outPutValue`（按 step 小数位取整）且 onChange 报升序副本。Tooltip 用 `SemiTooltip(trigger: custom)` + 可见性状态机；标记点/标签可点（跳最近手柄）。光标照上游逐选择器映射（slider.scss）：手型只覆盖 `-rail`(37)/`-track`(90)/`-handle`(58)/`-dot`(113)/`-mark`(134)/`-mark-reverse`(151)，按下 handle 为 `grabbing`(82)，wrapper/边界文字无 cursor 覆盖、禁用组 `not-allowed`(218-241)——手型不铺满组件外接矩形。

## API

`SemiSlider({key, value, defaultValue, range, min, max, step, disabled, vertical, verticalReverse, included, marks, showMarkLabel, tooltipOnMark, showTooltip, tipFormatter, tooltipVisible, showArrow, showBoundary, handleDot, onChanged, onAfterChange, onMouseUp, onBlur, getAriaValueText})`。

value/defaultValue `Object?`（double | List<double> 长度 2，range 时必须为后者；assert 形态校验，SemiPinCode.format 先例），非空即受控（项目惯例）：渲染 value、只发事件；**拖拽例外**：drag 期间手柄跟手（foundation.ts:552 "allow drag for controlled component"），松手回到 value 渲染，value 流回即对齐。释放控制保留最后受控值（semi_rating.dart:122-129 同款），进入控制保留内部态。range false、min 0、max 100、step 1、disabled false、vertical false、verticalReverse false、included true。marks `Map<double, String>?`（键越界隐藏）。showMarkLabel true、tooltipOnMark false。

showTooltip true（上游 `tipFormatter: null` 哨兵的拆分，差异清单）；tipFormatter `Object? Function(double value)?`（String | Widget，null → 值字符串）；tooltipVisible `bool?`（true 恒显 / false 恒隐 / null 走悬停-拖拽-键盘聚焦状态机）；showArrow true；showBoundary false（wrapper 悬停且开启时显示 min/max 标签）。handleDot `Object?`（SemiSliderHandleDot | List 长度 2，range；`{size, color}` 覆盖 `$width-slider_handle_dot`/`$color-slider_handle_dot`，仅提供时渲染内点）。

onChanged `ValueChanged<Object?>?`（double | 升序 List<double>）。onAfterChange 同型：拖拽结束、点击跳转完成、识别键 KeyUp、★以及外部受控 value 变化（index.tsx:315）。onMouseUp `VoidCallback?`（拖拽/按键结束时先于 onAfterChange）。onBlur `VoidCallback?`（焦点离开整个 slider 才报，双手柄互切不算）。getAriaValueText `String Function(double value, int index)?`。静态 `SemiSlider.handleKey(int index)` / `SemiSlider.railKey` 供测试定位。

## 行为

### 值模型与输出取整

★`outPutValue`（foundation.ts:420-447）：乘数 = `10^decimals(step)`，onChange/onAfterChange/tooltip 内容恒为取整后的值（step=1 → 整数，step=0.1 → 1 位小数）。★range 输出按升序排序（`notifyChange` 复制后排序，绝不改写入参）。受控 value 仅参与渲染；内部态在非受控时落地。

### 步进吸附（★相对 0）

拖拽/点击换算值先 `value = (v / step).round() * step`（仅 `step != 1`，foundation.ts:349-351）再 clamp 到 `[min, max]`——网格以 0 为原点：min=5 step=10 时落点是 0/10/20…（点击 5.95 → 10 而非 15），越界后 clamp（5 → 5）。键盘不做吸附（±step 后 clamp）。

### 拖拽

按下手柄即开会话（upstream mousedown 无 slop，本移植用 Listener 原始指针事件复刻）：捕获指针-手柄中心偏移并全程保留（手柄不跳向光标）。move 时按偏移换算值、过 `outPutValue` 后 onChanged；受控也实时跟手。★双手柄允许交叉，越过即双双塌陷：拖 'min' 过 max → `[max, max]`，拖 'max' 过 min → `[min, min]`（foundation.ts:441 以 focusPos 为键，本移植以被动手柄为键；塌陷后拖回可恢复成对值）。松开：onMouseUp 先报，onAfterChange 带 `outPutValue(currentValue)`。

### 点击（rail / track / 刻度点 / 刻度标签）

`handleWrapClick`（foundation.ts:788-813）：换算点击值、跳**最近**手柄（按距离，`checkWhichHandle`；range 取近者、单值唯一）。受控只回调不跳；非受控落地并在跳转完成后报 onAfterChange。拖拽中/点在手柄上不触发。

### 键盘

每手柄 `Focus(onKeyEvent:)`（disabled 不可聚焦）。→/↑ +step、←/↓ −step；PageUp +10×step、PageDown −10×step——★RTL（仅 horizontal）全部反转；★Home/End 不反转：单值 → min/max；range 'min'：Home → `[min, v1]`、End → `[v1, v1]`（塌陷）；'max'：Home → `[v0, v0]`、End → `[v0, max]`。range 碰撞：可相遇不可穿越（'max' 减到 v0 即停、'min' 增到 v1 即停），diff gate 使继续按键无事件。★识别键（8 个）的 KeyUp 先报 onMouseUp 再报 onAfterChange；无关键完全不响应。KeyDown/KeyRepeat → onChanged（diff-gated，受控不落地）。

### 焦点环与按下态

键盘聚焦画 2px 轮廓（`width-slider_handle-focus` + `color-slider_handle-focus`，rating `_keyboardUsed` 门控先例：任意 KeyDown 置位、按压清位）；鼠标按下画 1px 描边（`width-slider_handle_clicked` + `color-slider_handle-border-focus`，`-handle-clicked` 态）——上游两个独立状态。

### Marks 与刻度点

`marks` 键在 `[min, max]` 内才渲染（`isMarkActive` 返回 false 隐藏）。刻度点 `width-slider_dot` 见方、top `spacing-slider_dot-top`、`calc(${markPercent * 100}% - 2px)` 居中；标签（showMarkLabel）top `spacing-slider_marks-top`、`translate(-50%, 0)` 水平居中、`color-slider_mark-text-default` 着色。★included 不对称（foundation.ts:401-413）：单值 + `included: false` → 点恒不高亮；range + `included: false` → 点恒高亮（两端 quirk 都照搬）；`included: false` 隐藏填充 track。高亮色 `-dot-active` → `color-slider_dot-border-active`。点/标签可点（跳最近手柄）；tooltipOnMark 把每个点包进带标签的 SemiTooltip。

### Tooltip

每手柄 `SemiTooltip(trigger: custom, visible: 状态机, showArrow, repositionKey: 值百分比)`。状态机（foundation `computeHandleVisibleVal` + `:focus-visible`）：`tooltipVisible == true` 恒显、`== false` 恒隐（含 hover/focus）；否则悬停/拖拽该手柄、或键盘聚焦（focus-visible 门控）时显示。内容 = `tipFormatter != null ? tipFormatter(取整值) : '$value'`（String|Widget 走 `_asWidget` 先例）。★松手即收（foundation.ts:616 `onHandleUp` 无条件 `adapter.onHandleLeave()`）：拖拽中移出手柄的 exit 被吞（`onHandleLeave` 跳过 isDrag），release 时统一清 hover——拖到手柄外松手 tooltip 必收（否则会卡住常显）；仍停在手柄上松开也收（上游语义，重新移入再显）。键盘路径不受影响（focus-visible 门控）。

### Boundary

`showBoundary` 且 wrapper 悬停时显示 min/max 标签（`visibility` 切换语义）：12px（`font-size: $font-size-small` == theme.typography.fontSizeSmall）、`color-slider-text-default` 着色、top `spacing-slider_boundary-top`、min 靠左 max 靠右（RTL 互换，rtl.scss）。显示的是当前 widget.min/max（min/max 不冻结，差异清单）。

### disabled

拖拽/点击/键盘全禁用、手柄不可聚焦、光标 forbidden。视觉：track 填 `color-slider_track_disabled-bg`；handle 填 `color-slider_handle-bg-default` + 1px（`width-slider_handle_border_disabled`）描边 `color-slider_handle_disabled-border` + 无阴影（`shadow-0`）；hover 填 `color-slider_handle_disabled-border-hover`。★`color-slider_disabled-text-default` 不消费（上游死语句）。

### vertical / verticalReverse

轴翻转：值沿纵向映射（`top%` 语义，本移植按物理坐标换算）；手柄 `margin-left: -10` 居中 4px 轨、`translateY(-50%)`；刻度标签 `margin-top: $spacing-slider_vertical_marks-marginTop`（净 -7 ≈ -fontSize/2，标签垂直居中于点）、`margin-left: 29`。verticalReverse 值轴翻转（min 在视觉底），标签移到左侧（`margin-left: -26`）且保持正立（上游 `-mark-reverse` 转 180° 回正的净效果）。RTL 仅作用于 horizontal。vertical 根容器无 `.semi-slider` padding（上游同）。

### 语义

每手柄 `Semantics(container: true, slider: true, value: …, enabled: !disabled)`，value 走 `getAriaValueText(value, index)`（缺省用值字符串）。

## 主题（61 对账）

来源 packages/semi-foundation/slider/variables.scss（57 声明：color 17、spacing 25、radius 2、width/height 10、font 3）与 animation.scss（4 声明），0 同名重复。对账 **61 = 57 FIELDS + 3 MOTION + 1 INTERNAL**（`$transform_scale-slider_handle` 见 `_SliderMetrics`）。57 FIELDS 含 2 条事实死变量（标注「（上游未消费）」）：`$color-slider_disabled-text-default`、`$spacing-slider_tooltip-top`——保留为 theme 字段但 widget 不消费（净效果一致）。解析列即 `SemiSliderThemeData.resolve` 的默认表达式；`rgba(0, 0, 0, 0.65)` 走字面量 `const Color(0xa6000000)`。quirk：slider.scss:59 引用动画 token 时连/下划线写法不同（`$transition_duration_slider_handle-bg` 等，Sass `-`/`_` 同字符）——计声明不计引用。

### A. Sass 声明映射（57 FIELDS + 3 MOTION + 1 INTERNAL = 61）

| Sass 声明（默认值） | 去向 | 解析 / 说明 |
|---|---|---|
| `$color-slider-text-default: var(--semi-color-text-0)` | `colorSliderTextDefault` | `theme.colors.colorText0` |
| `$color-slider_disabled-text-default: var(--semi-color-disabled-text)` | `colorSliderDisabledTextDefault` | `theme.colors.colorDisabledText`（（上游未消费）slider.scss:219 `$color: $color-slider_disabled-text-default !important;` 赋给局部 `$color` 后从未使用——disabled 文本色上游不变；widget 不消费本字段） |
| `$color-slider_dot-bg-default: var(--semi-color-white)` | `colorSliderDotBgDefault` | `const Color(0xffffffff)` |
| `$color-slider_dot-border-active: var(--semi-color-white)` | `colorSliderDotBorderActive` | `const Color(0xffffffff)` |
| `$color-slider_dot-border: var(--semi-color-white)` | `colorSliderDotBorder` | `const Color(0xffffffff)` |
| `$color-slider_handle-bg-default: var(--semi-color-white)` | `colorSliderHandleBgDefault` | `const Color(0xffffffff)` |
| `$color-slider_handle-bg-hover: var(--semi-color-white)` | `colorSliderHandleBgHover` | `const Color(0xffffffff)` |
| `$color-slider_handle-border-focus: var(--semi-color-focus-border)` | `colorSliderHandleBorderFocus` | `theme.colors.colorFocusBorder` |
| `$color-slider_handle_disabled-border-hover: var(--semi-color-white)` | `colorSliderHandleDisabledBorderHover` | `const Color(0xffffffff)` |
| `$color-slider_handle_disabled-border: var(--semi-color-border)` | `colorSliderHandleDisabledBorder` | `theme.colors.colorBorder` |
| `$color-slider_mark-text-default: var(--semi-color-text-2)` | `colorSliderMarkTextDefault` | `theme.colors.colorText2` |
| `$color-slider_rail-bg-default: var(--semi-color-fill-0)` | `colorSliderRailBgDefault` | `theme.colors.colorFill0` |
| `$color-slider_rail: rgba(0, 0, 0, 0.65)` | `colorSliderRail` | `const Color(0xa6000000)` |
| `$color-slider_track-bg-default: var(--semi-color-primary)` | `colorSliderTrackBgDefault` | `theme.colors.colorPrimary` |
| `$color-slider_track_disabled-bg: var(--semi-color-primary-disabled)` | `colorSliderTrackDisabledBg` | `theme.colors.colorPrimaryDisabled` |
| `$color-slider_handle-focus: var(--semi-color-primary-light-active)` | `colorSliderHandleFocus` | `theme.colors.colorPrimaryLightActive` |
| `$color-slider_handle_dot: var(--semi-color-primary)` | `colorSliderHandleDot` | `theme.colors.colorPrimary` |
| `$spacing-slider-paddingX: 13px` | `spacingSliderPaddingX` | `13` |
| `$spacing-slider-paddingY: 0px` | `spacingSliderPaddingY` | `0` |
| `$spacing-slider-margin: 0px` | `spacingSliderMargin` | `0` |
| `$spacing-slider_rail-margin: 0px` | `spacingSliderRailMargin` | `0` |
| `$spacing-slider_rail-padding: 0px` | `spacingSliderRailPadding` | `0` |
| `$spacing-slider_rail-top: 14px` | `spacingSliderRailTop` | `14` |
| `$spacing-slider_handle-marginTop: 4px` | `spacingSliderHandleMarginTop` | `4` |
| `$spacing-slider_track-top: 14px` | `spacingSliderTrackTop` | `14` |
| `$spacing-slider_tooltip-top: -40px` | `spacingSliderTooltipTop` | `-40（（上游未消费）仅被 slider.scss:94-98 `.semi-slider-tooltip` CSS 块消费，该选择器 TSX 从不输出（真实 tooltip 定位由 Tooltip 组件负责）；widget 不消费本字段）` |
| `$spacing-slider_dot-top: 14px` | `spacingSliderDotTop` | `14` |
| `$spacing-slider_marks-top: 23px` | `spacingSliderMarksTop` | `23` |
| `$spacing-slider_marks-left: 0px` | `spacingSliderMarksLeft` | `0` |
| `$spacing-slider_boundary-top: 30px` | `spacingSliderBoundaryTop` | `30` |
| `$spacing-slider_boundary_min-left: 0px` | `spacingSliderBoundaryMinLeft` | `0` |
| `$spacing-slider_boundary_max-right: 0px` | `spacingSliderBoundaryMaxRight` | `0` |
| `$spacing-slider_vertical_marks-marginTop: -30px` | `spacingSliderVerticalMarksMarginTop` | `-30` |
| `$spacing-slider_vertical_marks-marginLeft: 29px` | `spacingSliderVerticalMarksMarginLeft` | `29` |
| `$spacing-slider_vertical_marks-reverse-marginLeft: -26px` | `spacingSliderVerticalMarksReverseMarginLeft` | `-26` |
| `$spacing-slider_vertical_rail-top: 0px` | `spacingSliderVerticalRailTop` | `0` |
| `$spacing-slider_vertical_handle-marginTop: 0px` | `spacingSliderVerticalHandleMarginTop` | `0` |
| `$spacing-slider_vertical_handle-marginLeft: -10px` | `spacingSliderVerticalHandleMarginLeft` | `-10` |
| `$spacing-slider_handle-translateY: 0px` | `spacingSliderHandleTranslateY` | `0` |
| `$spacing-slider_vertical_handle-translateX: 0px` | `spacingSliderVerticalHandleTranslateX` | `0` |
| `$spacing-slider_dot-translateX: 0px` | `spacingSliderDotTranslateX` | `0` |
| `$spacing-slider_vertical_dot-translateY: 0px` | `spacingSliderVerticalDotTranslateY` | `0` |
| `$radius-slider_rail: var(--semi-border-radius-small)` | `radiusSliderRail` | `theme.radius.borderRadiusSmall.value` |
| `$radius-slider_track: var(--semi-border-radius-small)` | `radiusSliderTrack` | `theme.radius.borderRadiusSmall.value` |
| `$height-slider_wrapper: 32px` | `heightSliderWrapper` | `32` |
| `$height-slider_vertical_wrapper: 4px` | `heightSliderVerticalWrapper` | `4` |
| `$height-slider_rail: 4px` | `heightSliderRail` | `4` |
| `$width-slider_handle: 24px` | `widthSliderHandle` | `24` |
| `$width-slider_handle_clicked: 1px` | `widthSliderHandleClicked` | `1` |
| `$height-slider_track: 4px` | `heightSliderTrack` | `4` |
| `$width-slider_dot: 4px` | `widthSliderDot` | `4` |
| `$width-slider_handle_border_disabled: 1px` | `widthSliderHandleBorderDisabled` | `1` |
| `$width-slider_handle-focus: 2px` | `widthSliderHandleFocus` | `2` |
| `$width-slider_handle_dot: 4px` | `widthSliderHandleDot` | `4` |
| `$font-slider_rail-fontSize: 14px` | `fontSliderRailFontSize` | `theme.typography.fontSizeRegular` |
| `$font-slider_marks-fontSize: 14px` | `fontSliderMarksFontSize` | `theme.typography.fontSizeRegular` |
| `$font-slider_rail-lineHeight: 1.5` | `fontSliderRailLineHeight` | `1.5` |
| `$transition_duration-slider_handle-bg: var(--semi-transition_duration-none)` | `transitionDurationSliderHandleBg` | `Duration.zero` |
| `$transition_function-slider_handle-bg: var(--semi-transition_function-easeIn)` | `transitionFunctionSliderHandleBg` | `Curves.easeIn` |
| `$transition_delay-slider_handle-bg: var(--semi-transition_delay-none)` | `transitionDelaySliderHandleBg` | `Duration.zero` |
| `$transform_scale-slider_handle: var(--semi-transform_scale-small)` | `_SliderMetrics.transformScaleSliderHandle`（INTERNAL） | `1`（`scale(1,1)` 恒等，semi-theme-default/scss/animation.scss:29；slider.scss `$transform_scale-slider_handle translateX(-50%)` 消费，Sass `-`/`_` 同字符） |

### B. widget 内部常量（INTERNAL/HARDCODES）

| 常量（`_SliderMetrics`） | 上游出处 / 结构 | 值或处理 |
|---|---|---|
| `transformScaleSliderHandle`（INTERNAL） | animation.scss `$transform_scale-slider_handle: var(--semi-transform_scale-small)` | `1`（`scale(1,1)` 恒等，不加变换） |
| `shadowKnob` | mixin.scss:14 `@include shadow-knob` — `box-shadow: 0 4px 6px rgba(0, 0, 0, 0.1), 0 0 1px rgba(0, 0, 0, 0.3);` | 两个 BoxShadow（0,4,blur6 @0x1a000000 + blur1 @0x4d000000）落在 `.semi-slider-handle` |
| `shadowZero` | mixin.scss:8 `@include shadow-0` — `box-shadow: none;` | 空列表：disabled handle 无阴影 |
| `dotCenterNudge` | index.tsx:594 `calc(${markPercent * 100}% - 2px)` | 2（= 4px 刻度点半宽，居中修正） |
| `handleZIndex` | index.tsx:374 `zIndex: chooseMovePos === 'min' && isDrag ? 2 : 1` | 2（被拖动手柄后绘、压在另一手柄上） |
| （调用点）boundary 字号 | slider.scss:157 `-boundary` `font-size: $font-size-small` | 12 == `theme.typography.fontSizeSmall` |

## 差异清单

照搬留档（★，刻意与上游一致的行为）：

- **★onChange 输出升序排序**：range 回调一律 `[min, max]` 排序副本，绝不改写入参（index.tsx:202 `[...cbValue].sort(...)`）。
- **★outPutValue 取整**：所有输出按 step 小数位取整（10^decimals(step)），step=1 时落到整数（foundation.ts:420-447）。
- **★步进吸附相对 0**：`(v/step).round()*step` 后 clamp——min=5 step=10 的网格是 0/10/20…（foundation.ts:349-351）。
- **★交叉塌陷**：双手柄拖拽允许交叉，越过即双双塌陷到被动端值（`[max,max]`/`[min,min]`；foundation.ts:441 按 focusPos 判键，本移植按被动手柄，点击场景不可达交叉）。
- **★RTL 箭头/Page 反转、Home/End 不反转**（foundation.ts:698-728）。
- **★KeyUp 触发链**：识别键 KeyUp 先 onMouseUp 再 onAfterChange，无关键完全不响应（foundation.ts:599-602）。
- **★included 不对称**：单值 included:false 点恒不亮、range included:false 点恒亮（foundation.ts:401-413）。
- **★受控 value 外部变化触发 onAfterChange**（index.tsx:315 `trigger onAfterChange when value is controlled and changed`），值按原样透传。
- **★Blur 抑制**：两个 range 手柄间焦点移动不报 onBlur，离开整个 slider 才报（index.tsx:204-209 `notifyBlur`）。

偏差（不移植/调整）：

- **min/max 不冻结**：上游 constructor 把 min/max 冻进 state 且此后不随 props 更新（index.tsx:116-117），本移植直接消费 widget.min/max（boundary 标签、换算同）。
- **valueFormatIsCorrect bug 不移植**：上游 `typeof value[0] === 'number' && typeof value[0] === 'number'` 重复检查 value[0]（foundation.ts:220-226）；本移植以形态 assert 取代。
- **showTooltip / tipFormatter 拆分**：上游 `tipFormatter: null` 哨兵兼任「不显示 tooltip」与格式化（`_noTooltip`，foundation.ts:749-752）；拆成 showTooltip（显隐）+ tipFormatter（纯格式化，null → `'$value'`）。
- **受控拖拽跟手为契约覆盖**：foundation.ts:552 允许受控拖拽回调，但上游 adapter 在受控时跳过状态更新（index.tsx:250-253）导致手柄不动；本契约要求跟手、松手回渲染 value、value 流回即对齐（见 API）。
- **tooltip/边界文本 `'$value'`**：JS 渲染数字 `30`，Dart `'$value'` 得 `30.0`（tipFormatter 可自定义抹平）。
- **style / railStyle / className 不移植**（样式走私有 theme patch / 外层 Widget）。
- **Form.Slider 延后**：受控/重置走 value 惯例，无表单集成本体。controlled-zero（props.value 显式置 undefined → 重置 min，index.tsx:310-311）不可移植——Dart `null` 即非受控，释放控制保留最后值。
- **aria 透传简化**：`aria-label`/`aria-labelledby`/`aria-valuetext` prop 不移植；语义以 `Semantics(slider: true, value: …)` + `getAriaValueText` 表达。
- **checkWhichHandle verticalReverse 翻转不移植**：上游在最近手柄判定后再 `isMin = !isMin`（foundation.ts:840-842，reverse 下会跳较远手柄，疑为上游 bug）；本移植恒跳最近手柄。
- **2 条事实死**：`$color-slider_disabled-text-default`（死赋值）与 `$spacing-slider_tooltip-top`（死 CSS 块）保留 theme 字段但 widget 不消费，见主题表。

```dart
SemiSlider(
  value: v,                        // Object? 非空即受控（double 或 [a, b]）
  range: true,
  min: 0,
  max: 100,
  step: 1,
  marks: const {0: '0', 50: '50', 100: '100'}, // Map<double, String>
  showBoundary: true,
  handleDot: const [
    SemiSliderHandleDot(size: 6, color: Color(0xff333333)),
    SemiSliderHandleDot(size: 6, color: Color(0xff333333)),
  ],
  onChanged: (v) => print(v),      // 升序 [a, b] 或 double
  onAfterChange: (v) => print(v),  // 拖拽结束/点击跳转/KeyUp/受控 value 变化
);
// 局部主题：SemiSliderTheme(data: const SemiSliderThemeData(widthSliderHandle: 28), child: ...)
```
