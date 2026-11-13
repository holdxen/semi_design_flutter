# SemiPinCode 验证码输入框

无需 Material，使用 `package:semi_design_flutter/semi_design_flutter.dart` 和 Flutter widgets。一排单字符格子组成（上游每格就是一个 `Input`，隐式依赖 input.scss），值模型为内部 `List<String>` 每格一字符（上游 `valueList`），对外收发完整字符串（`packages/semi-foundation/pincode/foundation.ts` + `packages/semi-ui/pincode/index.tsx`）。

```dart
SemiPinCode(
  count: 6,
  format: SemiPinCodeFormat.number,
  onChanged: (value) => debugPrint('value: $value'),
  onComplete: (value) => debugPrint('done: $value'),
  onBlur: () => debugPrint('left'),
)
```

## API

`SemiPinCode` 参数（`lib/src/components/semi_pincode.dart`，上游 `packages/semi-ui/pincode/index.tsx` + `foundation.ts`）：

| 字段 | 说明 | 默认 |
| --- | --- | --- |
| `value` | `String?` **非空即受控**（项目惯例）：显示随 value 逐字符更新，编辑/删除只回调不落地 | null |
| `initialValue` | `String?` 非受控种子（上游 `defaultValue`），逐字符分格 | null |
| `count` | 格数（上游 `count`，`count: 6`） | `6` |
| `format` | `Object` 三种形态（见差异清单）：`SemiPinCodeFormat.number/mixed`、`RegExp`、`bool Function(String)`（逐字符调用） | `SemiPinCodeFormat.number` |
| `onChanged` | `ValueChanged<String>` 每次单格写入/删除后的**完整值**（`valueList.join('')`，空位抹去；上游 `onChange`） | - |
| `onComplete` | `ValueChanged<String>` 写入最后一格时一次（参数 join；删后再填满再触发，无防重入） | - |
| `disabled` | 全部格禁用（ExcludeFocus + IgnorePointer + disabled 视觉，键鼠均不响应） | `false` |
| `autoFocus` | 挂载后聚焦第 0 格（上游 `defaultProps` 默认 `true`） | `true` |
| `size` | `SemiInputSize`（small/normal/large） | `normal` |
| `validateStatus` | `SemiInputStatus`（normal/error/warning）逐格视觉 | `normal` |
| `onBlur` | `VoidCallback` 焦点**离开整个组件**才触发（格间移动不触发；上游 wrapper `onBlur`） | - |
| `controller` | `SemiPinCodeController`（上游 ref `focus`/`blur`），detach 后方法 no-op，不自释放 | - |

`SemiPinCodeController.focus(index)` 聚焦第 index 格并把光标置尾（上游 `inputDOM.focus(); setSelectionRange(1, 1)`）；`blur(index)` 失焦该格。

## 行为

**值模型**：内部 `List<String>` 每格一字符（上游 `valueList`）；`onChanged`/`onComplete` 收发 `valueList.join('')`（空位抹去：`['1','','3','4']` → `'134'`）。

**单格输入**（每格文本变化）：IME 组合期（`controller.composing` 非空）忽略；插入 delta 为单字符时取**输入文本最后一个字符**（上游 `v[v.length-1]`，'19' → '9' 覆盖式写入）；`validateValue` 不过**静默忽略**（恢复格内原值）；空文本 delta 一律忽略（删除走 Backspace/Delete 键）。写入走 `completeSingleInput`：写 valueList[i] → `onChanged(join)` → 受控不落内部态 → 非末格聚焦第 i+1 格，末格 blur 全部格 + `onComplete(join)`。

**键盘**（外层 `Focus(canRequestFocus: false, skipTraversal: true)`，经焦点节点映射格号；仅 KeyDown，repeat 无动作）：

- **Backspace**：清空当前格 → `onChanged(join)` → 焦点 `max(0, i-1)`（当前格为空也回退，首格钳制）→ 消费。
- **Delete**：清空当前格 → `onChanged(join)` → 焦点 `min(count-1, i+1)`（末格钳制）→ 消费。
- **ArrowLeft / ArrowRight**：仅移动焦点（两端钳制），不改值 → 消费。**无 Home/End**（上游同）。
- **Enter / Tab / Escape / 字符键**：不拦截（继续冒泡）。

**粘贴 / 多字符 delta**：每格文本变化检测**插入 delta 长度 > 1**（即上游 `onPaste` 的 Flutter 等价通道）：从当前格 i 起逐格分发字符，**逐字符 validateValue，非法立即 break（已写入保留）**；每个成功写入走 `completeSingleInput`（照常 `onChanged`/`onComplete`/跳格）；处理完按 valueList 重写所有涉及格的显示（防原始 delta 残留）。

**format**（上游 `validateValue`，foundation.ts:64-79 逐条）：`number` → `value.isEmpty || /^\d*$/.test(value)`；`mixed` → `value.isEmpty || /^[0-9a-zA-Z]$/.test(value)`（单字符）；`RegExp` → `format.hasMatch(value)`（**空串不放行**，上游无 `value.isEmpty` 放行短路）；函数 → `format(value)` 逐字符调用。

**受控**（`value` 非空）：单格写入/Backspace/Delete/粘贴只回调不落内部 valueList；显示随 `value` 逐字符更新，**父不改值则显示不变**（上游测试验证的语义）；非受控内部态直接更新显示。

**onBlur**（组件级）：每格失焦后延迟一帧检查"是否所有格都失焦"再回调（上游 `relatedTarget` 语义的 Flutter 等价）——格间移动不触发，整体离开/完成末格（blur 全部格）触发。

**语义/视觉**：每格 `EditableText` 单字符、文字居中、padding 0（pincode.scss:35-38）；整盒点击聚焦（SemiInput 先例）；RTL 用 `EdgeInsetsDirectional`。

## 主题

主题优先级：局部非空补丁（外到内 merge）> 当前 `SemiThemeData.components.pinCode` > live global 默认值。`SemiPinCodeTheme` 局部补丁跨 `SemiTheme`/Overlay 边界继承（捕获只携带局部补丁快照）。`copyWith`/`merge` 的 null 表示保留原值。

来源 `packages/semi-foundation/pincode/variables.scss`（6 声明；pincode **无 animation.scss**），共 **6** 条声明 = **6** 个唯一名（无重复声明、无死变量）= **6** 个主题字段 + **0** 个 MOTION 字段 + **0** 个 widget 内部声明（`tool/generate_pincode.py` 生成到 `semi_pincode_theme_data.dart`）；HARDCODES 4 条另列进 B 组（`_PinCodeMetrics`）。独立于 383 项 CSS manifest。

### A. 主题字段（6 = 6 FIELDS + 0 MOTION + 0 INTERNAL）

| Sass 声明（默认值） | 去向 | 解析 / 说明 |
|---|---|---|
| `$spacing-pinCode_small-marginRight: 6px` | spacingPinCodeSmallMarginRight | 6（small 格间距，末格 0） |
| `$spacing-pinCode_default-marginRight: 8px` | spacingPinCodeDefaultMarginRight | 8（default 格间距，末格 0） |
| `$spacing-pinCode_large-marginRight: 12px` | spacingPinCodeLargeMarginRight | 12（large 格间距，末格 0） |
| `$width-pinCode_input_small: 24px` | widthPinCodeInputSmall | 24（small 格宽） |
| `$width-pinCode_input_default: 32px` | widthPinCodeInputDefault | 32（default 格宽） |
| `$width-pinCode_input_large: 42px` | widthPinCodeInputLarge | 42（large 格宽，宽 > 高） |

### 格视觉复用 SemiInput 主题（每格 = 上游一个 Input）

每格盒模型运行时取 `SemiInputTheme.resolve(context)`（上游每格就是 Input，隐式依赖 input.scss）；未凭空新增主题字段：

| 视觉属性 | 字段（SemiInput 主题 / 本主题） | 上游 input.scss / pincode.scss 规则 |
|---|---|---|
| 盒高 small/default/large | heightInputWrapperSmall/Default/Large（24/32/40） | `&-small/-default/-large { height: $height-input_wrapper_* }`（input.scss:46-55） |
| 盒宽 small/default/large | widthPinCodeInputSmall/Default/Large（24/32/42，本主题） | `&-small/-default/-large { width: $width-pinCode_input_* }`（pincode.scss:13/21/29） |
| 格间距（末格 0） | spacingPinCodeSmall/Default/LargeMarginRight（6/8/12，本主题） | `margin-right: $spacing-pinCode_*-marginRight` + `&:last-child { margin-right: 0 }`（pincode.scss:14-17 等） |
| 底色 default | colorInputDefaultBgDefault（fill-0） | `background-color: $color-input_default-bg-default`（input.scss:34） |
| 底色 hover | colorInputDefaultBgHover（fill-1） | `&:hover`（input.scss:52） |
| 底色 focus | colorInputDefaultBgFocus（fill-0） | `&-focus`（input.scss:60） |
| 边框 default | colorInputDefaultBorderDefault（透明）+ widthInputWrapperBorder（1px） | `border: $width-input_wrapper-border $color-input_default-border-default solid`（input.scss:35） |
| 边框 hover | colorInputDefaultBorderHover（透明） | `&:hover { border-color: ... }`（input.scss:53） |
| 边框 focus | colorInputDefaultBorderFocus（focus-border）+ widthInputWrapperFocusBorder（1px） | `&-focus { border: $color-input_default-border-focus solid $width-input_wrapper_focus-border }`（input.scss:61-62） |
| error 底色/边框 | colorInputDangerBgDefault/Hover/Focus + colorInputDangerBorderDefault/Hover/Focus | `&-error` 及其 `:hover`/`-focus`（input.scss:85-101） |
| warning 底色/边框 | colorInputWarningBgDefault/Hover/Focus + colorInputWarningBorderDefault/Hover/Focus | `&-warning` 及其 `:hover`/`-focus`（input.scss:103-111） |
| disabled 底色/边框/文字 | colorInputDisabledBgDefault + colorInputDefaultBorderDefault + colorInputDisabledTextDefault | disabled 变体（input.scss:85-111 同组规则，同 `SemiInput` 的 disabled 映射） |
| 圆角 | radiusInputWrapper（border-radius-small 语义） | `border-radius: $radius-input_wrapper`（input.scss:36） |
| 文字色 | colorInputDefaultTextDefault（disabled 用 colorInputDisabledTextDefault） | `color: $color-input_default-text-default`（input.scss:41） |
| 字号 | typography.fontSizeRegular（14）/ fontSizeHeading6（16） | `font-size-regular`（input.scss:45/47/51）/ `font-size-header-6`（input.scss:55）→ 14/14/16 |
| 光标色 | 格 style.color（缺省 colorInputDefaultTextDefault）+ backgroundCursorColor: colorInputDisabledTextDefault | `cursor: text`（input.scss:42）；semi_input 的 cursorColor 先例 |
| 格内文字 | textAlign center + padding 0（EditableText） | `input { padding: 0; text-align: center; }`（pincode.scss:35-38） |

### B. widget 内部常量（HARDCODES，不进主题，`_PinCodeMetrics`）

| 常量 | 硬编码 | 值 | 用途 |
| --- | --- | --- | --- |
| `countDefault` | `count: 6` | 6 | semi-ui/pincode/index.tsx `defaultProps`；`SemiPinCode.count` 默认值 |
| `numberReg` | `numberReg = /^\d*$/` | `^\d*$` | foundation.ts（PinCodeFoundation）；`SemiPinCodeFormat.number` 校验 |
| `mixedReg` | `mixedReg = /^[0-9a-zA-Z]$/` | `^[0-9a-zA-Z]$` | foundation.ts（PinCodeFoundation）；`SemiPinCodeFormat.mixed` 校验 |
| `cellInputPaddingTextAlign` | `input { padding: 0; text-align: center; }` | padding 0 / 居中 | pincode.scss:35-38；格内文字居中、无 padding |

## 差异清单

- **format 联合类型以 Object 承载**：上游 `"number" | "mixed" | RegExp | ((value: string) => boolean)`；移植为 `Object`（`SemiPinCodeFormat` 枚举 + `RegExp` + `bool Function(String)`），构造 assert 校验三种形态。
- **controller 对应上游 ref 方法**：`SemiPinCodeController.focus(index)/blur(index)` 对应 ref `focus`/`blur`（`setSelectionRange(1, 1)` → 光标置尾）；attach/detach 由 `SemiPinCode` 状态维护，detach 后 no-op。
- **粘贴识别**：上游用 `onPaste` 剪贴板事件（`handlePaste` 从当前格分发剪贴板文本）；Flutter 无粘贴事件通道，移植按每格文本变化的**插入 delta 长度 > 1** 识别并从当前格分发（逐字符 validate、非法 break、每个写入走 `completeSingleInput`），处理完按 valueList 重写涉及格显示。
- **单格输入取末字符**：同上游 `v[v.length-1]` 覆盖式语义（'19' → '9'），按插入 delta 长度 == 1 判定单格路径。
- **空文本 delta 一律忽略**：删除走 Backspace/Delete 键。上游 number/mixed 的 `value.isEmpty ||` 放行空串、RegExp 空串不放行；且上游 `onChange` 收到空串时 number 会以 `undefined` 走 `completeSingleInput`（上游怪癖），移植均不落。
- **IME 组合期识别**：以 `controller.composing` 非空判定（上游 `nativeEvent.isComposing`）；组合提交文本与组合文本相同（文本无变化）时不触发 onChanged（EditableText 语义），该字符不落地。
- **currentActiveIndex 仅在格获得焦点时更新**（上游 `completeSingleInput` 还会直接写 `i+1`）。
- **受控且 value 为空串时显示空**：上游构造 `(value || defaultValue).split('')` 空串回退 defaultValue；移植按项目惯例 `value` 非空即受控。
- **完成末格 blur 全部格**（上游仅 blur 末格；等价）；`onBlur` 为 `VoidCallback`（上游携带 `FocusEvent`）。
- **KeyRepeat 无动作**：上游 keydown 天然连发（按住 Backspace 连续清格）；移植仅 KeyDown 处理，repeat 忽略。
- **单格选区高亮**：同 SemiInput 取 `colorPrimary @ 40%`（`selectionColor` 不设则 RenderEditable 不绘制选区、选中不可见）；单格为单字符 EditableText，未套选区手势包装（拖选/双击选词不适用），右键菜单/选区手柄未移植。
- **未移植**（上游亦无）：密码模式、placeholder、readonly。未移植（有上游对应但不适用）：`id`/`tabIndex`/`aria-*`、`className`/`style`（Dart 侧外层包裹）、`onChange` 事件对象（参数即 join 字符串，同上游载荷）。
