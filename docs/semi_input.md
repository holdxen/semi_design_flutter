# SemiInput / SemiTextArea

非 Material 输入组件（基于 EditableText），移植自上游 Semi Input / TextArea。单行 `SemiInput` 与多行 `SemiTextArea` 共享一套取值约定、校验态视觉与主题（`SemiInputThemeData`，97 对账见下文）。wrapper 固定三档高度 24/32/40（`$height-input_wrapper_*`），1px 边框（focus 仍 1px 不加粗、无位移），圆角解析 `--semi-border-radius-small`（默认 3px）。背景状态 fill-0 → hover fill-1 → focus fill-0 → disabled disabledFill；error/warning 走 danger/warning light 色系，focus 换 danger/warning 描边；borderless 非 focus 透明但 error/warning 保持描边。文本字号/行高 14/22、14/22、16/22（小/默认/大），编辑槽几何按上游精确（内槽 22/30/38 = wrapper − 2×1px）。

## API

`SemiInput({key, value, initialValue, mode, size, validateStatus, disabled, readonly, borderless, placeholder, prefix, suffix, insetLabel, addonBefore, addonAfter, showClear, hideSuffix, clearIcon, maxLength, onChanged, onEnterPress, onFocusChange, onBlur, onClear, controller, focusNode, inputStyle, semanticsLabel})`。

- `value: String?` 非空即受控（SemiTag.visible / SemiCheckbox 惯例）；`initialValue` 为非受控初值；`controller`/`focusNode` 外传不自释放（与 `initialValue` 互斥）。
- `mode`: normal（默认）/password；`size`: small/normal/large（wrapper 24/32/40，字号 14/14/16）；`validateStatus`: normal/error/warning/success。
- `prefix`/`suffix`/`insetLabel`/`addonBefore`/`addonAfter` 为 Object? 双态（String 或 Widget）。String 槽渲染 w600 粗体（`$font-input_prefix_suffix-fontWeight`）、颜色 prefix-text、水平外边距 12；`SemiIcon` 槽边距 8×`$spacing-input_prefix_icon-marginX`；其他 Widget 原样。insetLabel 与 prefix 同槽（prefix 优先）。addon 为独立 1px 描边块：addonBefore 右描边、addonAfter 左描边（颜色 default-border，透明），外侧圆角 3，内容 padding 0/12。
- 事件均为裁剪签名（无 DOM 事件对象）：`onChanged: ValueChanged<String>`、`onEnterPress/onBlur/onClear: VoidCallback`、`onFocusChange: ValueChanged<bool>`。
- `inputStyle` 合并覆盖内置编辑文本样式；`semanticsLabel` 进 Semantics。Semantics 携带 `textField: true` 与 `validationResult`（error → invalid，success → valid，其余 none）。

`SemiTextArea({key, value, initialValue, rows = 4, autosize, maxCount, showCounter, showClear, disabledEnterStartNewLine, validateStatus, disabled, readonly, borderless, placeholder, maxLength, onChanged, onEnterPress, onFocusChange, onBlur, onClear, controller, focusNode, inputStyle, semanticsLabel})`。

- `autosize`: `bool` 或 `SemiTextAreaAutosize(minRows, maxRows)`。`true` 等价 minRows = rows、maxRows 无上限；对象形态 `minRows ?? rows`，`maxRows: null` 同样无上限。rows 回退高度 = rows×22 + 5/5 内边距（宽 0 的 textarea 自身描边 `$width-textarea-border` = 0）。
- `maxCount`/`showCounter`：`maxCount || showCounter` 才显示计数器，格式 `current/total`（无 maxCount 仅 `current`），超限（current > maxCount）danger 色。计量与 maxLength 一致为 UTF-16 code unit。
- 无 size（上游 textarea 无尺寸档）、无 prefix/suffix/addon。

## 受控与 IME

- 受控同步仅在 `widget.value != controller.text` 且 `controller.composing` 为空时执行（防中文拼音上屏中被覆盖）；同步保留/夹紧光标。释放受控（value → null）保留最近显示值；进入受控立即按 value 同步。
- `onChanged` 逐次触发（包括 IME composition 过程中）。上游 `composition` 延时开关与 onCompositionStart/End/Update 三回调不移植，语义文档化（计划允许简化或文档化）。
- blur 复核截断：maxLength 生效时，blur 处二次截断拼音残留（上游 textarea issue #2005 行为保留并推广到 Input）；非受控落地并 `onChanged(truncated)`，受控只通知。

## 密码

`mode: password` 默认遮蔽（obscureText），显隐按钮常显（disabled 才隐藏）。图标 `SemiIcons.eyeClosedSolid`（遮蔽）/`SemiIcons.eyeOpened`（可见）。按钮可聚焦，Enter/Space 激活（`Focus.onKeyEvent`），激活后与上游一致把焦点交还输入框；pointer 点击不夺焦（onPointerDown 防失焦）。切换 obscureText 保存/恢复 selection。键盘聚焦时绘制 `:focus-visible` 描边环（icon-outline 2px、offset −1px 以净 1px 外环近似）。

## 清除

`showClear` 且文本非空且（hover | focus）且非 readonly/非 disabled 时显示（上游 `showClearIgnoreDisabled` 简化为 disabled 一律不显示）。`onTapDown` 触发防 blur，之后焦点保留在输入框。受控只发 `onChanged('') + onClear`，非受控落地清空。`hideSuffix` 在清除按钮可见时隐藏 suffix（简化：无 `__with-suffix-hidden` 变体）。clear+suffix 共存时清除槽宽叠加 `$spacing-input_clearBtn_withSuffix-marginLeft: -$spacing-base-tight`（−12，CSS `margin-left` 语义以槽宽收缩落地）；suffix 为 icon 时清除槽 24（end 对齐），有密码按钮时 16（居中），否则 32。clearIcon 可替换默认 `SemiIcons.clear`。

## maxLength

UTF-16 code-unit 截断 formatter + blur 复核；`maxLength: 0` 强制空值；省略则不限长。`getValueLength` 自定义计量不移植（差异清单）。

## TextArea 行为

- autosize 用 TextPainter 测高（含 placeholder：`value || placeholder || 'x'`，上游 `node.value || node.placeholder || 'x'`），含内边距与 textarea 自身描边；minRows 行为下限，maxRows 行为上限（超出滚动）。
- `disabledEnterStartNewLine`：keydown 通道拦截普通 Enter（换行被消费、`onEnterPress` 仍触发），Shift+Enter 放行换行。IME 软键盘换行属文本输入通道，平台层无法统一拦截/触发（见差异清单）。
- 计数器点击（点击 wrapper/counter）聚焦输入框；clear 按钮锚定右上（`position: absolute; top: 0`，右边距 4，高 32、槽宽 24）。
- `onEnterPress`：SemiInput 经引擎 done 动作（`EditableText.onSubmitted`，硬件 Enter/键盘完成键等价）；SemiTextArea 经 keydown（上游 keydown 13 等价）。两通道在各自组件内单次触发。

## 主题（97 对账）

`tool/generate_input.py` 生成 `lib/src/theme/semi_input_theme_data.dart` + `semi_input_theme.dart`（`SemiComponentThemes.input` 可全局/局部覆盖，局部 patch 捕获语义同 SemiCheckboxTheme）。**97 = variables 87 + animation 10 = 94 themed（85 FIELDS + 9 motion）+ 3 INTERNAL**；另有 5 条 HARDCODES（另列）结构常量在组件 `_InputMetrics`。分类：color 44（default 9 + icon-outline/bg-focus-hover 2 + danger 8 + warning 8 + disabled 3 + placeholder/prefix 2 + icon 3 + counter 2 + group-border 1 + only-border 2 + textarea 4）、height 8、width 12、spacing 19、font 1、radius 1、motion 2、animation 10（transition 9 + transform_scale 1）。`tool/test_generate_input.py` 断言计数、溯源、再生成字节一致、383 manifest 不动。

97 行映射表（Sass → 默认 → 去向）：

| Sass 声明（默认值） | 去向 | 解析 / 说明 |
| --- | --- | --- |
| `$color-input_default-border-default: transparent` | `colorInputDefaultBorderDefault` (Color) | `const Color(0x00000000)` |
| `$color-input_default-bg-default: var(--semi-color-fill-0)` | `colorInputDefaultBgDefault` (Color) | `theme.colors.colorFill0` |
| `$color-input_default-text-default: var(--semi-color-text-0)` | `colorInputDefaultTextDefault` (Color) | `theme.colors.colorText0` |
| `$color-input_default-bg-hover: var(--semi-color-fill-1)` | `colorInputDefaultBgHover` (Color) | `theme.colors.colorFill1` |
| `$color-input_default-border-hover: transparent` | `colorInputDefaultBorderHover` (Color) | `const Color(0x00000000)` |
| `$color-input_default-bg-active: var(--semi-color-fill-2)` | `colorInputDefaultBgActive` (Color) | `theme.colors.colorFill2` |
| `$color-input_default-border-active: $color-input_default-bg-active` | `colorInputDefaultBorderActive` (Color) | `theme.colors.colorFill2` |
| `$color-input_default-bg-focus: var(--semi-color-fill-0)` | `colorInputDefaultBgFocus` (Color) | `theme.colors.colorFill0` |
| `$color-input_default-border-focus: var(--semi-color-focus-border)` | `colorInputDefaultBorderFocus` (Color) | `theme.colors.colorFocusBorder` |
| `$color-input_icon-outline: var(--semi-color-primary-light-active)` | `colorInputIconOutline` (Color) | `theme.colors.colorPrimaryLightActive` |
| `$color-input_default-bg-focus-hover: $color-input_default-bg-focus` | `colorInputDefaultBgFocusHover` (Color) | `theme.colors.colorFill0` |
| `$color-input_danger-bg-default: var(--semi-color-danger-light-default)` | `colorInputDangerBgDefault` (Color) | `theme.colors.colorDangerLightDefault` |
| `$color-input_danger-border-default: var(--semi-color-danger-light-default)` | `colorInputDangerBorderDefault` (Color) | `theme.colors.colorDangerLightDefault` |
| `$color-input_danger-bg-hover: var(--semi-color-danger-light-hover)` | `colorInputDangerBgHover` (Color) | `theme.colors.colorDangerLightHover` |
| `$color-input_danger-border-hover: var(--semi-color-danger-light-hover)` | `colorInputDangerBorderHover` (Color) | `theme.colors.colorDangerLightHover` |
| `$color-input_danger-bg-focus: var(--semi-color-danger-light-default)` | `colorInputDangerBgFocus` (Color) | `theme.colors.colorDangerLightDefault` |
| `$color-input_danger-border-focus: var(--semi-color-danger)` | `colorInputDangerBorderFocus` (Color) | `theme.colors.colorDanger` |
| `$color-input_danger-bg-active: var(--semi-color-danger-light-active)` | `colorInputDangerBgActive` (Color) | `theme.colors.colorDangerLightActive` |
| `$color-input_danger-border-active: var(--semi-color-danger-light-active)` | `colorInputDangerBorderActive` (Color) | `theme.colors.colorDangerLightActive` |
| `$color-input_warning-bg-default: var(--semi-color-warning-light-default)` | `colorInputWarningBgDefault` (Color) | `theme.colors.colorWarningLightDefault` |
| `$color-input_warning-border-default: var(--semi-color-warning-light-default)` | `colorInputWarningBorderDefault` (Color) | `theme.colors.colorWarningLightDefault` |
| `$color-input_warning-bg-hover: var(--semi-color-warning-light-hover)` | `colorInputWarningBgHover` (Color) | `theme.colors.colorWarningLightHover` |
| `$color-input_warning-border-hover: var(--semi-color-warning-light-hover)` | `colorInputWarningBorderHover` (Color) | `theme.colors.colorWarningLightHover` |
| `$color-input_warning-bg-focus: var(--semi-color-warning-light-default)` | `colorInputWarningBgFocus` (Color) | `theme.colors.colorWarningLightDefault` |
| `$color-input_warning-border-focus: var(--semi-color-warning)` | `colorInputWarningBorderFocus` (Color) | `theme.colors.colorWarning` |
| `$color-input_warning-bg-active: var(--semi-color-warning-light-active)` | `colorInputWarningBgActive` (Color) | `theme.colors.colorWarningLightActive` |
| `$color-input_warning-border-active: var(--semi-color-warning-light-active)` | `colorInputWarningBorderActive` (Color) | `theme.colors.colorWarningLightActive` |
| `$color-input_disabled-border-default: var(--semi-color-disabled-border)` | `colorInputDisabledBorderDefault` (Color) | `theme.colors.colorDisabledBorder` |
| `$color-input_disabled-bg-default: var(--semi-color-disabled-fill)` | `colorInputDisabledBgDefault` (Color) | `theme.colors.colorDisabledFill` |
| `$color-input_disabled-text-default: var(--semi-color-disabled-text)` | `colorInputDisabledTextDefault` (Color) | `theme.colors.colorDisabledText` |
| `$color-input_placeholder-text-default: var(--semi-color-text-2)` | `colorInputPlaceholderTextDefault` (Color) | `theme.colors.colorText2` |
| `$color-input_prefix-text-default: var(--semi-color-text-2)` | `colorInputPrefixTextDefault` (Color) | `theme.colors.colorText2` |
| `$color-input-icon-default: var(--semi-color-text-2)` | `colorInputIconDefault` (Color) | `theme.colors.colorText2` |
| `$color-input-icon-hover: var(--semi-color-primary-hover)` | `colorInputIconHover` (Color) | `theme.colors.colorPrimaryHover` |
| `$color-input-icon-active: var(--semi-color-primary-active)` | `colorInputIconActive` (Color) | `theme.colors.colorPrimaryActive` |
| `$color-input_counter-text-default: var(--semi-color-text-2)` | `colorInputCounterTextDefault` (Color) | `theme.colors.colorText2` |
| `$color-input_counter_danger-text-default: var(--semi-color-danger)` | `colorInputCounterDangerTextDefault` (Color) | `theme.colors.colorDanger` |
| `$color-input_group-border-default: var(--semi-color-border)` | `colorInputGroupBorderDefault` (Color) | `theme.colors.colorBorder` |
| `$color_input-default-border-only_border-default: var(--semi-color-border)` | `colorInputDefaultBorderOnlyBorderDefault` (Color) | `theme.colors.colorBorder` |
| `$color_input-default-border-only_border-hover: var(--semi-color-border)` | `colorInputDefaultBorderOnlyBorderHover` (Color) | `theme.colors.colorBorder` |
| `$color-textarea-border-default: transparent` | `colorTextareaBorderDefault` (Color) | `const Color(0x00000000)` |
| `$color-textarea-border-hover: $color-textarea-border-default` | `colorTextareaBorderHover` (Color) | `const Color(0x00000000)` |
| `$color-textarea-icon-default: var(--semi-color-text-2)` | `colorTextareaIconDefault` (Color) | `theme.colors.colorText2` |
| `$color-textarea-icon-hover: var(--semi-color-primary-hover)` | `colorTextareaIconHover` (Color) | `theme.colors.colorPrimaryHover` |
| `$height-input_large: $height-control-large - 2px` | `heightInputLarge` (double) | `38` |
| `$height-input_small: $height-control-small - 2px` | `heightInputSmall` (double) | `22` |
| `$height-input_default: $height-control-default - 2px` | `heightInputDefault` (double) | `30` |
| `$height-input_wrapper_large: $height-control-large` | `heightInputWrapperLarge` (double) | `40` |
| `$height-input_wrapper_small: $height-control-small` | `heightInputWrapperSmall` (double) | `24` |
| `$height-input_wrapper_default: $height-control-default` | `heightInputWrapperDefault` (double) | `32` |
| `$height-textarea_counter: 24px` | `heightTextareaCounter` (double) | `24` |
| `$height-textarea-default: 32px` | `heightTextareaDefault` (double) | `32` |
| `$width-input-icon: $width-icon-medium + $spacing-tight * 2` | `widthInputIcon` (double) | `32` |
| `$width-input-icon_clear_before_suffix: $width-icon-medium + $spacing-tight` | `widthInputIconClearBeforeSuffix` (double) | `24` |
| `$width-input-icon_clear_before_modebtn: $width-icon-medium` | `widthInputIconClearBeforeModebtn` (double) | `16` |
| `$width-input_append-border: $border-thickness-control` | `widthInputAppendBorder` (double) | `1` |
| `$width-input_prepend-border: $border-thickness-control` | `widthInputPrependBorder` (double) | `1` |
| `$width-input_group_pseudo-border: $border-thickness-control` | `widthInputGroupPseudoBorder` (double) | `1` |
| `$width-input_wrapper-border: $border-thickness-control-focus` | `widthInputWrapperBorder` (double) | `1` |
| `$width-input_wrapper_focus-border: $border-thickness-control-focus` | `widthInputWrapperFocusBorder` (double) | `1` |
| `$width-input_icon-outline: 2px` | `widthInputIconOutline` (double) | `2` |
| `$width-input_icon-outlineOffset: -1px` | `widthInputIconOutlineOffset` (double) | `-1` |
| `$width-textarea-border: $border-thickness` | `widthTextareaBorder` (double) | `0` |
| `$width-textarea-icon: $width-icon-medium + $spacing-tight` | `widthTextareaIcon` (double) | `24` |
| `$spacing-input_icon-marginLeft: -$spacing-base-tight` | `spacingInputIconMarginLeft` (EdgeInsetsDirectional) | `EdgeInsetsDirectional.only(start: -12)` |
| `$spacing-input-paddingLeft: $spacing-base-tight` | `spacingInputPaddingLeft` (double) | `12` |
| `$spacing-input-paddingRight: $spacing-base-tight` | `spacingInputPaddingRight` (double) | `12` |
| `$spacing-input_prefix_suffix-marginX: $spacing-base-tight` | `spacingInputPrefixSuffixMarginX` (double) | `12` |
| `$spacing-input_prefix_icon-marginY: 0` | `spacingInputPrefixIconMarginY` (double) | `0` |
| `$spacing-input_prefix_icon-marginX: $spacing-tight` | `spacingInputPrefixIconMarginX` (double) | `8` |
| `$spacing-input_clearBtn_withSuffix-marginLeft: -$spacing-base-tight` | `spacingInputClearBtnWithSuffixMarginLeft` (EdgeInsetsDirectional) | `EdgeInsetsDirectional.only(start: -12)` |
| `$spacing-input_prepend-paddingY: 0` | `spacingInputPrependPaddingY` (double) | `0` |
| `$spacing-input_prepend-paddingX: $spacing-base-tight` | `spacingInputPrependPaddingX` (double) | `12` |
| `$spacing-textarea-paddingY: 5px` | `spacingTextareaPaddingY` (double) | `5` |
| `$spacing-textarea-paddingX: $spacing-base-tight` | `spacingTextareaPaddingX` (double) | `12` |
| `$spacing-textarea_counter-paddingTop: 3px` | `spacingTextareaCounterPaddingTop` (double) | `3` |
| `$spacing-textarea_counter-paddingRight: 12px` | `spacingTextareaCounterPaddingRight` (double) | `12` |
| `$spacing-textarea_counter-paddingBottom: 5px` | `spacingTextareaCounterPaddingBottom` (double) | `5` |
| `$spacing-textarea_counter-paddingLeft: 12px` | `spacingTextareaCounterPaddingLeft` (double) | `12` |
| `$spacing-textarea_withShowClear-paddingRight: 36px` | `spacingTextareaWithShowClearPaddingRight` (double) | `36` |
| `$spacing-textarea-icon-right: $spacing-extra-tight` | `spacingTextareaIconRight` (double) | `4` |
| `$font-input_prefix_suffix-fontWeight: $font-weight-bold` | `fontInputPrefixSuffixFontWeight` (FontWeight) | `theme.typography.fontWeightBold` |
| `$radius-input_wrapper: var(--semi-border-radius-small)` | `radiusInputWrapper` (double) | `theme.radius.borderRadiusSmall.value` |
| `$motion-scale_size-active: .97` | `motionScaleSizeActive` (double) | `0.97` |
| `$motion-scale_size-inactive: 1` | `motionScaleSizeInactive` (double) | `1` |
| `$transition_duration-input-bg: var(--semi-transition_duration-none)` | `transitionDurationInputBg` (Duration) | `Duration.zero` |
| `$transition_function-input-bg: var(--semi-transition_function-easeIn)` | `transitionFunctionInputBg` (Curve) | `Curves.easeIn` |
| `$transition_delay-input-bg: var(--semi-transition_delay-none)` | `transitionDelayInputBg` (Duration) | `Duration.zero` |
| `$transition_duration-input-border: var(--semi-transition_duration-none)` | `transitionDurationInputBorder` (Duration) | `Duration.zero` |
| `$transition_function-input-border: var(--semi-transition_function-easeIn)` | `transitionFunctionInputBorder` (Curve) | `Curves.easeIn` |
| `$transition_delay-input-border: var(--semi-transition_delay-none)` | `transitionDelayInputBorder` (Duration) | `Duration.zero` |
| `$transition_duration-input-text: var(--semi-transition_duration-none)` | `transitionDurationInputText` (Duration) | `Duration.zero` |
| `$transition_function-input-text: var(--semi-transition_function-easeIn)` | `transitionFunctionInputText` (Curve) | `Curves.easeIn` |
| `$transition_delay-input-text: var(--semi-transition_delay-none)` | `transitionDelayInputText` (Duration) | `Duration.zero` |
| `$transform_scale-input: var(--semi-transform_scale-none)` | `_InputMetrics.transformScaleInput` | INTERNAL（widget 常量，未消费/延后） |
| `$spacing-input_group_withTopLabel-marginTop: $spacing-base` | `_InputMetrics.spacingInputGroupWithTopLabelMarginTop` | INTERNAL（widget 常量，未消费/延后） |
| `$spacing-input_group_withTopLabel-marginBottom: $spacing-base` | `_InputMetrics.spacingInputGroupWithTopLabelMarginBottom` | INTERNAL（widget 常量，未消费/延后） |

HARDCODES（另列，`_InputMetrics` 常量 + 溯源注释）：

| 常量 | 溯源 |
| --- | --- |
| `placeholderMeasureFallback` | textareaFoundation.ts `node.value || node.placeholder || 'x'` |
| `focusRingOutline` | input.scss `outline: $width-input_icon-outline solid $color-input_icon-outline` |
| `focusRingOutlineOffset` | input.scss `outline-offset: $width-input_icon-outlineOffset` |
| `counterTextAlignRight` | textarea.scss `text-align: right`（RTL 翻转，AlignmentDirectional.centerEnd） |
| `textareaClearAnchor` | textarea.scss `position: absolute; top: 0;` |

## 差异清单

- `getValueLength` 自定义计量不移植：maxLength/计数器统一按 UTF-16 code-unit 计量。
- InputGroup 延后：`$spacing-input_group_withTopLabel-marginTop/-Bottom` 归 INTERNAL（`_InputMetrics`，未消费）；`colorInputGroupBorderDefault`、`widthInputGroupPseudoBorder` 字段预留（仅 InputGroup 消费，当前未接线）。
- TextArea `resize` / `showLineNumber` 延后不移植。
- `success` 无专属视觉（上游如此），仅 Semantics `validationResult: valid`。
- 事件对象裁剪：无 `onKeyDown/onKeyUp/onKeyPress/onInput/onComposition*`，回调不携带 DOM 事件。
- `hideSuffix` 简化：无 `__with-suffix-hidden` 包装变体；`showClearIgnoreDisabled` 不移植（disabled/readonly 不显示清除）。
- textarea blur 拼音残留截断保留（并推广到 Input 的 blur 复核）。
- 输入文本行高统一 22（计划 14/22、14/22、16/22）；上游 CSS `line-height: $height-input_*`（22/30/38）是浏览器行盒撑满居中手段，本移植以固定 22px 行盒在上游精确槽位（22/30/38）内垂直居中。textarea rows 同用 22 行高（rows=4 总高 100，上游按浏览器 20px 行高为 92）。
- 圆角解析 `theme.radius.borderRadiusSmall`（默认 3px，上游 `--semi-border-radius-small: 3px`）；移植计划文案"圆角 4"与上游 token 不符，按上游。
- IME 软键盘换行不经按键事件：不触发 onEnterPress、`disabledEnterStartNewLine` 不拦截（与上游 DOM keypress/keydown 覆盖面一致的平台差异）。
- 上游 `:active` 按下态（fill-2 等）未单独建模（按下即聚焦）；`colorInputIconActive`、`spacingInputIconMarginLeft` 上游 CSS 声明未引用，保留为可配置字段、当前布局未消费。
- `mimeType`/`type=hidden` 等原生 input type、`preventScroll`、`minLength`、aria-* 透传、`onKeyDown/Up/Press` 未移植。

```dart
SemiInput(
  value: text,                         // 非空即受控
  onChanged: (v) => setState(() => text = v),
  placeholder: '请输入',
  prefix: '搜索',
  showClear: true,
  maxLength: 20,
  validateStatus: isError ? SemiInputStatus.error : SemiInputStatus.normal,
);
SemiTextArea(
  rows: 4,
  autosize: const SemiTextAreaAutosize(minRows: 2, maxRows: 8),
  maxCount: 140,
  showClear: true,
);
```
