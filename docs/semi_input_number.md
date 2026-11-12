# SemiInputNumber 数字输入框

无需 Material，使用 `package:semi_design_flutter/semi_design_flutter.dart` 和 Flutter widgets。以 `SemiInput` 为编辑框壳（`value: null` + 本组件自己的 controller，AutoComplete 同款组合方式），显示文本与数值由本组件的状态机管理（上游 `value`/`number` 双轨，`packages/semi-foundation/inputNumber/foundation.ts`）。

```dart
SemiInputNumber(
  initialValue: 1000,
  step: 1,
  shiftStep: 10,
  min: 0,
  max: 9999,
  precision: 2,
  formatter: (v) => '¥$v',
  parser: (v) => v.replaceAll('¥', '').trim(),
  showClear: true,
  onNumberChange: (n) => debugPrint('number: $n'),
)
```

## API

`SemiInputNumber` 参数（`lib/src/components/semi_input_number.dart`，上游 `packages/semi-ui/inputNumber/index.tsx` + `foundation.ts`）：

| 字段 | 说明 | 默认 |
| --- | --- | --- |
| `value` | `num?` **非空即受控**（项目惯例）：显示随 value 格式化（非 focusing），编辑/步进只回调不落地 | null |
| `initialValue` | `num?` 非受控种子（上游 `defaultValue`）；外部 `controller` 与之互斥（assert），带文本时以 controller 为准 | null |
| `onChanged` | `ValueChanged<String>` 每次编辑/步进/清除后的**显示文本**（上游 `onChange` 的 string 侧，见差异清单） | - |
| `onNumberChange` | `ValueChanged<num>` 仅合法（范围+精度）数字变化时（上游 `onNumberChange`） | - |
| `onUpClick` / `onDownClick` | `ValueChanged<String>` 点击加/减后的显示文本（仅按钮触发，键盘步进不触发——上游同） | - |
| `onClear` | `VoidCallback` 清除点击后回调（在 `onChanged('')` 之后） | - |
| `step` / `shiftStep` | `num` 单步与 Shift 单步（`DEFAULT_STEP: 1` / `DEFAULT_SHIFT_STEP: 10`） | 1 / 10 |
| `min` / `max` | `num?` 边界，**null = 无界**（上游 `±Infinity`） | null |
| `precision` | `int?` toFixed 四舍五入（半数远离零，见差异清单） | null |
| `formatter` | `String Function(String)?` 展示格式化（精度调整/科学计数之后、显示之前） | - |
| `parser` | `String Function(String)?` 输入解析（数值解析之前） | - |
| `scientificNotation` | `bool` 长数字科学计数显示（阈值固定 15 位有效数字） | `false` |
| `disabled` / `readonly` / `borderless` | 禁用 / 只读 / 无边框（borderless 且非 hover 非 focus 时步进器透明） | `false` |
| `hideButtons` | 隐藏外置步进器（`innerButtons` 的后缀步进器不受此影响——上游 `renderSuffix` 同） | `false` |
| `innerButtons` | 步进器作为 `SemiInput.suffix`，hover 或 focus 时替换用户 `suffix` 显示 | `false` |
| `keepFocus` | 点击步进器后保持输入框焦点 | `false` |
| `pressTimeout` / `pressInterval` | `Duration` 长按起始延迟 / 连发间隔（上游毫秒数） | 250ms / 250ms |
| `size` | `SemiInputSize`（small/normal/large） | `normal` |
| `showClear` / `clearIcon` | 清除按钮（hover/聚焦且非空时）与自定义图标 | `false` / - |
| `placeholder` / `prefix` / `suffix` / `insetLabel` | `Object?` String 或 Widget，透传 `SemiInput` | - |
| `validateStatus` | `SemiInputStatus` 透传 | `normal` |
| `autofocus` | 初始聚焦 | `false` |
| `controller` / `focusNode` | 外部传入，不自释放 | - |
| `semanticsLabel` | 透传 `SemiInput` | - |

## 行为

**双轨状态**（上游 `value` + `number`）：显示串（controller.text）+ 数值（内部 `number`）+ focusing/hovering。`SemiInput` 只是编辑壳（`value: null`，显示文本全部由本状态机写入）。

**初始化**：`value`/`initialValue`（或外部 controller 文本）→ formatter 格式化 → 解析（clamp + precision）→ 展示格式化结果；非法（NaN）显示空。格式化结果与种子不同时回调 `onChanged`（上游 `_setInitValue` 通知）。例：`value: 0, min: 1` 首帧显示并回调 `'1'`。

**受控**（`value` 非空）：编辑/步进只回调（`onChanged`/`onNumberChange`/`onUpClick`...）不落地；非 focusing 时显示随 `value` 格式化更新，focusing 时保输入中间态（上游 `componentDidUpdate` focusing 分支）；blur 不回写 value 时显示回 value 的格式化结果。

**输入中间态保活**（上游 `handleInputChange`）：`""` → 数值置空显示空；`"-"`、`"1."`、`"1.0"`、`"1.10"` 等残段原样保留（点后残段回填、精度不足补 0，上游 L213-230）；完全非法显示 parser 后文本（经 formatter）；中间态不 clamp 不清空。受控显示 `formattedNum`（含残段修复），非受控显示 parser/formatter 往返后的原文。

**blur 规整**（上游 `handleInputBlur`）：解析合法 → clamp + toFixed 写回并格式化显示；非法 → 尝试抽数（`"1000CNY"` → 1000，parseFloat 语义）再 clamp；完全非法 → 显示回旧值格式化结果/空串。显示或数值变化时回调一次。

**precision**：toFixed **四舍五入（半数远离零）**，在十进制表示上舍入（`2.25 → 2.3`、`-2.25 → -2.3`、`1.005 → 1.01`）。与 JS `toFixed`（二进制值 + 比较取整，`(1.005).toFixed(2) === "1.00"`）不同，见差异清单。

**步进**（上游 `add`/`minus` + `utils/number.ts`）：Shift 用 `shiftStep`；浮点误差消解 = `10^max(操作数小数位)` 放大取整（`0.1 + 0.2 = 0.3`）；越界先判 `|bound - cur| >= |step|` 才累加，最后 clamp 到 `[min, max]`；步进结果经 toFixed 格式化显示（不施加科学计数）。

**连发**：按下立即步进一次，`pressTimeout` 后按 `pressInterval` 连发；释放 / 移出按钮 / dispose 停止（Timer 实现）。

**边界**（上游 `renderButtons`）：`number == max` 禁 up、`number == min` 禁 down——**严格相等**（非 `>=`）；not-allowed 时不步进、`cursor` 禁止（`SystemMouseCursors.forbidden`）、**保持默认外观**（底色/文字不变，仅抑制 hover/active 填充——`&-button-up/down:not(.-not-allowed)` 选择器语义）。

**点击语义**：仅左键（mouse secondary 忽略；触屏恒为左键）；disabled/readonly 直接 return；keepFocus 或 innerButtons 点击后重新 `requestFocus` 防失焦；`onUpClick`/`onDownClick` 回调步进后显示文本。

**清除链路**（`showClear`）：值置空（number=null）+ `onChanged('')` + `onNumberChange` 不触发（'' 非法数字）+ `onClear()`。

**键盘**（外层 `Focus(canRequestFocus: false, skipTraversal: true)` 包住整体）：

- **ArrowUp/ArrowDown**（含 `KeyRepeatEvent` 连发）：按 `step`/`shiftStep`（Shift）步进，步进后保持光标位置；事件消费。
- **Enter** 走 `SemiInput.onEnterPress` 通道（不在键处理中拦截）；左右方向键/Tab 不拦截。无滚轮（上游同）。

**形态**：外置（默认）= Input 右侧独立小盒（宽 `widthInputNumberButton` 14、高按 size 24/32/40、1px 边框、上下按钮各 50% 高、与输入框间距 4）；内嵌（`innerButtons`）= 按钮组作为 `SemiInput.suffix`（hover||focus 显示按钮否则显示用户 suffix，盒高 22/30/38，间距 8；clearbtn 可见时 -4 拉回）；`hideButtons` = 无外置按钮。按钮视觉：盒底色 `colorInputNumberButtonBgDefault` + 边框 `colorInputNumberButtonBorderDefault` + 圆角；按钮默认透明、hover `colorInputNumberButtonBgHover`、按下 `colorInputNumberButtonBgActive`、禁用/边界 `colorInputNumberButtonBgDisabled` + `colorInputNumberButtonTextDisabled`；图标 `SemiIcons.chevronUp/chevronDown`（extra-small 8px）、色 `colorInputNumberButtonTextDefault`。内嵌未聚焦 hover 时容器边框换 `colorInputNumberButtonBorderHover`（`-suffix-btns-inner-hover`）。**borderless 且非 hover 且非 focus 时外置步进器 opacity 0**（inputNumber.scss L114-120）。

**语义**：`Semantics(container: true)` 对齐 spinbutton（`aria-valuenow/min/max/step` → `value` + `increasedValue`/`decreasedValue` + `onIncrease`/`onDecrease`）。RTL 用 `EdgeInsetsDirectional`/方向感知布局；文字缩放不溢出（步进器固定几何，图标 8px）。

## 主题

主题优先级：局部非空补丁（外到内 merge）> 当前 `SemiThemeData.components.inputNumber` > live global 默认值。`SemiInputNumberTheme` 局部补丁跨 `SemiTheme`/Overlay 边界继承（捕获只携带局部补丁快照）。`copyWith`/`merge` 的 null 表示保留原值。

来源 `packages/semi-foundation/inputNumber/variables.scss`（21 声明）+ `packages/semi-foundation/inputNumber/animation.scss`（7 声明），共 **28** 条声明 = **28** 个唯一名（无重复声明、无死变量）= **21** 个主题字段 + **6** 个 MOTION 字段（两组过渡三元组，`tool/generate_input_number.py` 生成到 `semi_input_number_theme_data.dart`）+ **1** 个 widget 内部声明（`$transform_scale-inputNumber`，`_InputNumberMetrics`）；步进器结构性硬编码 10 条另列进 B 组（`_InputNumberMetrics`）。独立于 383 项 CSS manifest。

### A. 主题字段（28 = 21 FIELDS + 6 MOTION + 1 INTERNAL）

| Sass 声明（默认值） | 去向 | 解析 / 说明 |
|---|---|---|
| `$height-inputNumber_button_default: $height-control-default` | heightInputNumberButtonDefault | 32（外置步进器盒高 - normal） |
| `$height-inputNumber_button_large: $height-control-large` | heightInputNumberButtonLarge | 40（外置 - large） |
| `$height-inputNumber_button_small: $height-control-small` | heightInputNumberButtonSmall | 24（外置 - small） |
| `$height-inputNumber_button_inner_default: $height-control-default - 2px` | heightInputNumberButtonInnerDefault | 30（内嵌盒高 - normal） |
| `$height-inputNumber_button_inner_large: $height-control-large - 2px` | heightInputNumberButtonInnerLarge | 38（内嵌 - large） |
| `$height-inputNumber_button_inner_small: $height-control-small - 2px` | heightInputNumberButtonInnerSmall | 22（内嵌 - small） |
| `$width-inputNumber_button: 14px` | widthInputNumberButton | 14（步进器盒宽 = 按钮宽） |
| `$width-inputNumber_button-border: 1px` | widthInputNumberButtonBorder | 1（步进器盒描边） |
| `$radius-inputNumber: var(--semi-border-radius-small)` | radiusInputNumber | theme.radius.borderRadiusSmall.value（外置盒圆角） |
| `$radius-inputNumber_inner: var(--semi-border-radius-small)` | radiusInputNumberInner | theme.radius.borderRadiusSmall.value（内嵌盒圆角） |
| `$spacing-inputNumber_button-marginLeft: 4px` | spacingInputNumberButtonMarginLeft | 4（外置盒与输入框间距） |
| `$spacing-inputNumber_button_inner-marginLeft: $spacing-tight` | spacingInputNumberButtonInnerMarginLeft | 8（内嵌盒左间距） |
| `$spacing-inputNumber_clearbtn_suffix-marginLeft: -$spacing-extra-tight` | spacingInputNumberClearbtnSuffixMarginLeft | -4（clearbtn 可见时后缀拉回） |
| `$color-inputNumber_button-text-default: var(--semi-color-text-2)` | colorInputNumberButtonTextDefault | theme.colors.colorText2（图标色） |
| `$color-inputNumber_button-text-disabled: var(--semi-color-disabled-text)` | colorInputNumberButtonTextDisabled | theme.colors.colorDisabledText |
| `$color-inputNumber_button-bg-default: var(--semi-color-bg-2)` | colorInputNumberButtonBgDefault | theme.colors.colorBg2（盒底色） |
| `$color-inputNumber_button-bg-disabled: var(--semi-color-disabled-fill)` | colorInputNumberButtonBgDisabled | theme.colors.colorDisabledFill |
| `$color-inputNumber_button-bg-hover: var(--semi-color-fill-0)` | colorInputNumberButtonBgHover | theme.colors.colorFill0（按钮 hover） |
| `$color-inputNumber_button-bg-active: var(--semi-color-fill-1)` | colorInputNumberButtonBgActive | theme.colors.colorFill1（按钮按下） |
| `$color-inputNumber_button-border-default: var(--semi-color-border)` | colorInputNumberButtonBorderDefault | theme.colors.colorBorder（盒描边） |
| `$color-inputNumber_button-border-hover: var(--semi-color-fill-2)` | colorInputNumberButtonBorderHover | theme.colors.colorFill2（`-suffix-btns-inner-hover` 换色） |
| `$transition_duration-inputNumber-bg: var(--semi-transition_duration-none)` | transitionDurationInputNumberBg | Duration.zero（token 实测 0ms；容器无过渡，仅留档可配） |
| `$transition_function-inputNumber-bg: var(--semi-transition_function-easeIn)` | transitionFunctionInputNumberBg | Curves.easeIn |
| `$transition_delay-inputNumber-bg: var(--semi-transition_delay-none)` | transitionDelayInputNumberBg | Duration.zero（无 delay 对应物，仅留档） |
| `$transition_duration-inputNumber-border: var(--semi-transition_duration-none)` | transitionDurationInputNumberBorder | Duration.zero |
| `$transition_function-inputNumber-border: var(--semi-transition_function-easeIn)` | transitionFunctionInputNumberBorder | Curves.easeIn |
| `$transition_delay-inputNumber-border: var(--semi-transition_delay-none)` | transitionDelayInputNumberBorder | Duration.zero |
| `$transform_scale-inputNumber: var(--semi-transform_scale-none)` | `_InputNumberMetrics.transformScaleInputNumber` | 恒等 scale(1)（同 input 的 transform_scale 先例），不施加 transform |

### B. widget 内部常量（HARDCODES + INTERNAL，不进主题，`_InputNumberMetrics`）

| 常量 | Sass / 硬编码 | 值 | 用途 |
| --- | --- | --- | --- |
| `transformScaleInputNumber` | `$transform_scale-inputNumber: var(--semi-transform_scale-none)` | 1 | INTERNAL 声明；恒等 scale（见 A 表末行） |
| `stepperIconSize` | `size="extra-small"` | SemiIconSize.extraSmall（8px） | semi-ui/inputNumber/index.tsx `renderButtons` 的 `IconChevronUp/IconChevronDown size="extra-small"` |
| `pressTimeoutDefault` | `DEFAULT_PRESS_TIMEOUT: 250` | 250 | constants.ts；`pressTimeout`/`pressInterval` 默认值（upstream defaultProps 两者都取它） |
| `stepDefault` | `DEFAULT_STEP: 1` | 1 | constants.ts；`step` 默认值 |
| `shiftStepDefault` | `DEFAULT_SHIFT_STEP: 10` | 10 | constants.ts；`shiftStep` 默认值 |
| `mouseButtonLeft` | `MOUSE_BUTTON_LEFT: 0` | 0 | constants.ts 的 DOM 左键序号；移植以 `kPrimaryMouseButton` 位判定 |
| `scientificNotationThreshold` | `Default threshold: 15 digits` | 15 | foundation.ts `_getScientificNotationThreshold`；科学计数阈值（有效数字位数） |
| `buttonSplitHeight` | `height: 50%` | 50% | inputNumber.scss `&-suffix-btns > .button`；上下按钮各占盒高一半（`Expanded`） |
| `innerButtonsOverflow` | `overflow: hidden` | hidden | inputNumber.scss `&-suffix-btns-inner`；内嵌盒圆角裁切（`Clip.antiAlias`） |
| `notAllowedCursor` | `cursor: not-allowed` | forbidden | inputNumber.scss `&-button-up-not-allowed`；边界按钮 `SystemMouseCursors.forbidden` |
| `borderlessHiddenOpacity` | `opacity: 0` | 0 | inputNumber.scss L114-120 `:not(:focus-within):not(:hover) .semi-input-borderless + .-suffix-btns`；borderless 闲置透明 |

## 差异清单

- **currency 集团延后**：上游 `currency`/`localeCode`/`currencyDisplay`/`minimumFractionDigits`/`maximumFractionDigits`/`showCurrencySymbol` 依赖 Intl/locale，未移植；请用 `formatter`/`parser`（解析侧上游 `parseInternationalCurrency` 同义）。
- **onChanged/onNumberChange 拆分上游 onChange**：上游 `onChange(value: number | string)` 双型回调拆为 `onChanged(String 显示文本)` + `onNumberChange(num)`；`onChanged` 的载荷是显示文本（编辑/步进后的可见串），上游载荷是解析后的 number 或 parser 后串。
- **min/max 可空替代 ±Infinity**：null = 无界（上游默认 `min: -Infinity, max: Infinity`）。
- **press 参数 Duration 化**：`pressTimeout`/`pressInterval` 用 `Duration`（上游毫秒数；upstream `DEFAULT_PRESS_INTERVAL: 0` 被 defaultProps 覆盖为 250，两者默认 250ms）。
- **onKeyDown 不移植**（无事件对象）；**无滚轮**（上游同）。
- **toFixed 舍入实现**：四舍五入、半数远离零、按十进制表示舍入（`2.25 → 2.3`、`1.005 → 1.01`）；JS `toFixed` 对二进制值舍入（`(1.005).toFixed(2) === "1.00"`），临界值结果不同。
- **value 仅 num**：上游 `value: number | string`；string 侧由显示串状态承担（外部 controller 文本可作种子）。
- **受控清空即清空本地 number**：`""` 输入/清除在受控下也置空本地 number（契约）；上游受控保留旧 number 等 value 回流。
- **readonly 阻断键盘步进**：上游 `handleInputKeyDown` 不检查 readonly（readonly 输入仍可箭头步进）；移植按只读语义一并阻断。
- **mouseLeave 停止连发**：上游 mouseleave 只注册全局 mouseup（移开后仍连发至松开）；移植移出按钮即停（契约 "mouseup/leave 停止"）。
- **keepFocus 防失焦用 requestFocus 实现**：Flutter 无 DOM blur/preventDefault；点击后重新请求焦点。
- **scientificNotation 仅 bool**：阈值固定 15（上游支持 `{ threshold }` 对象）；focus 展开走 parser 解析显示串，科学计数显示本身有 14 位小数的舍入（上游同）。
- **formatter 无 parser 时种子解析为空**（上游同：`_getInitState` 用 parser 解析 formatter 产物，无 parser 则非法显示空）；typing 显示仍生效。
- **未移植**：`onKeyDown`、`aria-*` 透传、`insetLabelId`、`forwardedRef`（用 `controller`/`focusNode`）、`className`/`style`（Dart 侧外层包裹）、`preventScroll`、滚轮步进。
