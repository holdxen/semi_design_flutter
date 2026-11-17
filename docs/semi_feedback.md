# SemiFeedback

反馈收集弹层（上游 Semi Feedback 全件移植）：两种展示容器（`mode: 'modal'` / `popup`，缺省 popup）× 五种内容 `type`（text / emoji / radio / checkbox / custom，缺省 emoji）。emoji 三档表情（`bad: '😞'` / `normal: '😐'` / `good: '😃'`，灰度显示、hover/选中还原）+ bad 追问 TextArea；值模型（`string | string[] | EmojiResult`）经 `onValueChange` 报告，提交成功复位；提交钮门槛 `!Boolean(value) || (Array.isArray(value) && value.length === 0)`（null / 空串 / 空列表禁用，`okDisabled` 可覆写）；`onOk`/`onCancel` 返回 `Future` 时按钮 loading，resolve 后复位值、reject 保持打开。popup 模式为底部浮动弹层（上游 SideSheet 组合 + feedback.scss 几何覆写：宽 400/600、右下 20/50 偏移、圆角 12、上滑动效、无蒙层点击穿透）——等价内建弹层（同 vendored 引擎，chrome 消费 SemiSideSheetTheme）。主题对账 **16 = 16 FIELDS + 0 MOTION + 0 INTERNAL**（variables.scss 16 声明：color 1、width 2、spacing 8、font 4、radius 1；无 animation.scss，`$module` 胶水与空 rtl.scss 不计，banner `22 = 22 FIELDS + 0 MOTION + 0 INTERNAL` 先例）；★**0 死变量**（feedback.scss 逐条消费），其中 6 条 `thank_text` 仅被 `&-thank-text` 公共样式钩子消费（上游 JSX 从不渲染）——**「字段留档不消费」**（badge `$z-badge` 先例）。

## API

`SemiFeedback({visible: false, mode: popup, type: emoji, title, content, renderContent, onValueChange, textAreaProps, radioGroupProps, checkboxGroupProps, footer, okText, cancelText, okDisabled, okLoading, cancelLoading, onOk, onCancel, afterClose, afterVisibleChange, mask, maskClosable, closable: true, closeIcon, closeOnEsc, motion: true, width})`。

- mode `SemiFeedbackMode`（modal/popup，缺省 `mode: 'popup'`）；type `SemiFeedbackType`（text/emoji/radio/checkbox/custom，缺省 `type: 'emoji'`）。
- title `Object?`（String | Widget：popup SideSheet 头部 / modal Modal 标题）；content `Widget?`（`type: 'custom'`，上游 `children`）；renderContent `Widget Function(Widget)?`（内容包装，仅包装非空内容）。
- onValueChange `ValueChanged<Object?>?`：text → String、emoji → `SemiFeedbackEmojiResult {emoji, text}`、radio → 选项值、checkbox → `List<Object>`。
- textAreaProps `SemiFeedbackTextAreaProps?`（placeholder/rows/autosize/maxCount/showCounter/showClear/maxLength/disabled/readonly/onChange——text 与 emoji 追问共用，placeholder 两处同覆）；radioGroupProps `SemiFeedbackRadioGroupProps?`（options/defaultValue/disabled/type/buttonSize/mode/onChanged，direction 固定 vertical）；checkboxGroupProps `SemiFeedbackCheckboxGroupProps?`（options/defaultValue/disabled/type/onChanged，direction 固定 vertical）。
- footer `Widget?`（整体替换按钮行，两模式皆生效）。okText/cancelText 缺省「提交」/「取消」（上游 locale `submit`/`cancel`）。okDisabled `bool?`（null 走门槛自动）；okLoading/cancelLoading `bool?`（null 跟随 onOk/onCancel 返回的 `Future`——上游 `okButtonProps`/`cancelButtonProps` 的 disabled/loading 槽）。
- onOk/onCancel `FutureOr<void> Function()?`；afterClose `VoidCallback?`（modal 交 SemiModal；popup 出场动画完成后补发）；afterVisibleChange `void Function(bool)?`（popup 入场 `true` / 出场 `false`）。
- mask `bool?`（缺省 modal: true、popup: false——`mask={false}` fixed 模式投影 + 点击穿透）；maskClosable `bool?`（缺省 true）；closable（缺省 true）/closeIcon；closeOnEsc `bool?`（缺省 modal: true、popup: false）；motion（缺省 true）；width `double?`（缺省 modal 400、popup text 600 / 其余 400）。

## 行为

### 显隐与回调

声明式 `visible` 驱动；关闭权在使用方（onOk/onCancel/关闭钮/蒙层点击/Esc 只通知）。提交/取消经 foundation 状态机：返回 `Future` → 对应按钮 loading（`onOKReturnPromiseStatus` / `onCancelReturnPromiseStatus`），resolve 后复位 `value: null`，reject 仅去 loading 并保持打开；非 Future 立即 `setValue(null)`（复位不回调 onValueChange）。`afterVisibleChange` 在入场/出场动画完成后分别回调 `(true)`/`(false)`（上游 onAnimationEnd → notifyVisibleChange），出场完成后补发 `afterClose`（上游 wrapper `if (!visible) { this.props.afterClose(); }`）。

### 内容类型（getRealChildren）

- **text**：TextArea（locale `placeholder`「请提供更多反馈」，textAreaProps 透传）；输入值即 value。
- **emoji**：`-emoji-container`（居中、column-gap 24、上下 24）三档表情，条目 `role="button"` `tabIndex={0}` `aria-pressed`，Enter/Space 键盘选中；`filter: grayscale(100%)`，`&:hover, &-selected` `filter: none;`（灰度矩阵 + MouseRegion）；`emoji === Emoji.bad` 追问 TextArea（`optionalPlaceholder`「请提供更多反馈（选填）」），输入合并 `{ ...oldValue, text }`；点选表情整体替换 value 为 `{emoji}`。
- **radio / checkbox**：`direction='vertical'` 组（radioGroupProps / checkboxGroupProps 透传，onChange 转发后更新 value）；checkbox 组行距覆写 16（`.#{$prefix}-checkboxGroup-vertical` row-gap → 本地 SemiCheckboxTheme patch）。
- **custom**：content 原样；★value 恒空 → 提交钮默认禁用（上游同——custom 无内部值来源），`okDisabled: false` 覆写。

### 按钮行（renderFooter）

- **popup**：`&-footer`（`justify-content: flex-end` + `column-gap: 12`）：取消 `type='primary'`（light）、提交 `type='primary' theme='solid'` + `disabled={this.disableSubmitButton()}`。
- **modal**：照抄 Modal 缺省 footer（自建按钮行——SemiModal 无 ok 禁用槽）：取消 `type="tertiary"` + 提交 `theme="solid"`，按钮间距 12（Modal footer `margin-left` token）。
- `footer` 参数非空时整体替换两模式按钮行。

### 视觉（popup 弹层）

结构：浮动卡片（宽 400 / text 600，`height="auto"` 内容 hugging + 溢出封顶滚动）锚定 `right: 20`（物理右，rtl.scss 空文件不镜像）+ 底距 50（inner-wrap `bottom`），圆角 12（`.#{$prefix}-sidesheet-inner`），fixed 模式（`mask={false}`）投影 `var(--semi-shadow-elevated)` + 点击穿透；chrome 消费 SemiSideSheetTheme（header 24/20 + 0px 占位边 + 标题 18/bold、body 0/24、footer 24、bg-2）。动效 `@keyframes #{$prefix}-sidesheet-slideShow_bottom`（`-Hide` 反放）：起点 `translateY(calc(100% + 50px))` → 0，180ms `cubic-bezier(0.25, 0.46, 0.45, 0.94)`（SideSheet motion 同值）。modal 模式壳体走 SemiModal，`.semi-modal` 宽度覆写 400（`&.#{$module}-text` 文本模式仍取 `$width-feedback`——注释矛盾 quirk）。

## 主题（16 对账）

来源 packages/semi-foundation/feedback/variables.scss（16 声明，无 animation.scss）。对账 **16 = 16 FIELDS + 0 MOTION + 0 INTERNAL**（HARDCODES 另列见 B 表）；★**0 死变量**。全局 token 解析：`var(--semi-color-text-2)` → `theme.colors.colorText2`；引用 token：`$font-size-regular` → `theme.typography.fontSizeRegular`（generate_button 先例）、`$font-weight-regular` → `theme.typography.fontWeightRegular`（generate_autocomplete 先例）。类型覆盖：**1 Color + 14 double + 1 FontWeight = 16 FIELDS**。解析列即 `SemiFeedbackThemeData.resolve` 默认表达式。

### A. Sass 声明映射（16 FIELDS）

| Sass 声明（默认值） | 去向 | 解析 / 说明 |
|---|---|---|
| `$color-feedback_thank_text: var(--semi-color-text-2)` | `colorFeedbackThankText` | `theme.colors.colorText2`（字段留档不消费） |
| `$width-feedback: 400px` | `widthFeedback` | `400`（★注释照抄「除去文本类型外其他类型的宽度」——文本模式 modal 覆写仍取同值） |
| `$width-feedback_text: 600px` | `widthFeedbackText` | `600`（仅 `.-text` 的 sidesheet 宽消费） |
| `$spacing-feedback_emoji_container-columnGap: 24px` | `spacingFeedbackEmojiContainerColumnGap` | `24` |
| `$spacing-feedback_emoji_container-marginY: 24px` | `spacingFeedbackEmojiContainerMarginY` | `24` |
| `$spacing-feedback_thank_text-marginTop: 24px` | `spacingFeedbackThankTextMarginTop` | `24`（字段留档不消费） |
| `$spacing-feedback_thank_text-marginBottom: 0px` | `spacingFeedbackThankTextMarginBottom` | `0`（字段留档不消费） |
| `$spacing-feedback_checkbox_group_vertical-rowGap: 16px` | `spacingFeedbackCheckboxGroupVerticalRowGap` | `16`（checkbox 组行距本地 patch） |
| `$spacing-feedback_footer-columnGap: 12px` | `spacingFeedbackFooterColumnGap` | `12` |
| `$spacing-feedback_sidesheet_bottom-right: 20px` | `spacingFeedbackSidesheetBottomRight` | `20`（物理 `right`，rtl.scss 不镜像） |
| `$spacing-feedback_sidesheet_bottom_inner_wrap-bottom: 50px` | `spacingFeedbackSidesheetBottomInnerWrapBottom` | `50` |
| `$font-feedback_emoji-fontSize: 36px` | `fontFeedbackEmojiFontSize` | `36` |
| `$font-feedback_thank_text-fontSize: $font-size-regular` | `fontFeedbackThankTextFontSize` | `theme.typography.fontSizeRegular`（字段留档不消费） |
| `$font-feedback_thank_text-lineHeight: 20px` | `fontFeedbackThankTextLineHeight` | `20`（字段留档不消费） |
| `$font-feedback_thank_text-fontWeight: $font-weight-regular` | `fontFeedbackThankTextFontWeight` | `theme.typography.fontWeightRegular`（字段留档不消费） |
| `$radius-feedback_sidesheet_inner: 12px` | `radiusFeedbackSidesheetInner` | `12`（仅 popup `.#{$prefix}-sidesheet-inner` 消费） |

★quirk 照抄：`$width-feedback` 行尾注释「除去文本类型外其他类型的宽度」与使用处矛盾（feedback.scss:57-61 `&.#{$module}-text .#{$prefix}-modal` 覆写仍取 `$width-feedback`，文本模式 modal 同 400）；`&-bottom` 选择器在 feedback.scss:76-85 重复声明两块（right/left 锚定与 inner-wrap 底距分写）；feedback.scss 重定义 SideSheet `@keyframes`（起点 `calc(100% + 50px)`）；rtl.scss 为空文件。

### B. HARDCODES 另列（widget 文件头注释 / 调用点，源内含原始片段，60 锚点）

| 上游片段 | 说明 |
|---|---|
| `MODE: ['modal', 'popup']` / `TYPE: ['text', 'emoji', 'radio', 'checkbox', 'custom']` | 对外枚举 |
| `bad: '😞'` / `normal: '😐'` / `good: '😃'` | emoji 三档（constants.ts `strings.Emoji`） |
| `mode: 'popup'` / `type: 'emoji'` | 缺省容器/类型 |
| `role="button"` `tabIndex={0}` `aria-pressed={item === emoji}` | emoji 条目语义 |
| `e.key === 'Enter' || e.key === ' '` | emoji 键盘选中 |
| `filter: grayscale(100%)` + `&:hover, &-selected` `filter: none;` | emoji 灰度/还原（灰度矩阵） |
| `font-family: Inter` / `user-select: none` | emoji 条目字体/不可选中 |
| `emoji === Emoji.bad && <TextArea` + `placeholder={locale.optionalPlaceholder}` / `placeholder={locale.placeholder}` | bad 追问与占位文案 |
| `direction='vertical'` | radio/checkbox 组方向 |
| `type='primary'` `theme='solid'` `disabled={this.disableSubmitButton()}` | renderFooter 按钮形态 |
| `okText={locale.submit}` `cancelText={locale.cancel}` `okButtonProps={{ disabled: disabledOkButton, ...this.props.okButtonProps }}` | modal 分支按钮槽 |
| `mask={false}` `disableScroll={false}` `canVerticalSetWidth={true}` `placement="bottom"` `height="auto"` | popup SideSheet 参数 |
| `this.props.afterClose()` | afterVisibleChange wrapper 补发 |
| `'textAreaProps', 'radioGroupProps', 'checkboxGroupProps', 'renderContent', 'onCancel', 'onOk'` + `['okButtonProps', 'cancelButtonProps']` | getRestProps 省略表 |
| `!Boolean(value) \|\| (Array.isArray(value) && value.length === 0)` | 提交钮门槛 |
| `onOKReturnPromiseStatus` / `onCancelReturnPromiseStatus` / `value: null` / `setValue(null)` / `handleModalOk` / `handleModalCancel` | promise 状态机 |
| `请提供更多反馈` / `请提供更多反馈（选填）` / `提交` / `取消` | locale zh_CN |
| `&-thank-text` | 感谢文字钩子（字段留档不消费） |
| `justify-content: flex-end` | `&-footer` 布局 |
| `.#{$prefix}-modal` + `&.#{$module}-text` | modal 宽度覆写族（注释矛盾 quirk） |
| `.#{$prefix}-sidesheet-inner` / `.#{$prefix}-checkboxGroup-vertical` | 圆角覆写 / row-gap 覆写 |
| `right: $spacing-feedback_sidesheet_bottom-right` / `left: auto` / `.#{$prefix}-sidesheet-inner-wrap` | `&-bottom` 锚定（重复声明 quirk） |
| `@keyframes #{$prefix}-sidesheet-slideShow_bottom` / `@keyframes #{$prefix}-sidesheet-slideHide_bottom` / `translateY(calc(100% + $spacing-feedback_sidesheet_bottom_inner_wrap-bottom))` | 上滑动效（起点 calc） |
| `.#{$prefix}-sidesheet-fixed` / `top: auto` | fixed 模式（maskless） |

重新生成独立主题：`python3 tool/generate_feedback.py`（包含 dart format）；对账校验 `python3 tool/test_generate_feedback.py`。

## 差异清单

- **值模型**：上游 `FeedbackValue = string | string[] | EmojiResult` 联合 → `Object?`（String / `SemiFeedbackEmojiResult` / 选项值 / `List<Object>`）；`EmojiResult` → `SemiFeedbackEmojiResult {emoji, text}`。
- **textAreaProps / radioGroupProps / checkboxGroupProps**：上游 `omit(...)` 透传对象 → 强类型配置类（`onChange` → `onChanged`；radio/checkbox `options` 上游字符串数组 → `SemiRadioOption` / `SemiCheckboxOption`）。
- **okButtonProps / cancelButtonProps**：裁剪为 `okDisabled` / `okLoading` / `cancelLoading`（popconfirm 同款 loading 语义）；`onClick` / `style` 覆写不移植（onOk/onCancel 语义并入）。
- **modal 按钮行**：上游 Modal 内建按钮 + `okButtonProps.disabled` → 两模式均自建 footer 按钮行（SemiModal 无 ok 禁用槽），modal 形态照抄 Modal 缺省 footer（cancel tertiary + ok primary solid）。
- **popup 弹层**：上游 SideSheet + feedback.scss 几何覆写（`canVerticalSetWidth` 未移植于 SemiSideSheet、bottom 全宽 + 定高）→ 等价内建弹层（同 vendored 引擎；chrome 消费 SemiSideSheetTheme，几何消费 SemiFeedbackTheme）；`height="auto"` 内容 hugging，超长内容封顶滚动（上游纯 hugging 的溢出保护）。
- **afterClose**：modal 模式交 SemiModal `afterClose`；popup 模式于出场动画完成后补发（上游 wrapper 语义）。
- **restProps 透传**：`getRestProps` 全量透传 → title/visible/mask/maskClosable/closable/closeIcon/closeOnEsc/motion/width 显式参数化；`className`/`style`/`getPopupContainer`/`zIndex`/`keepDOM` 未移植。
- **事件对象**：onChange 系回调去掉 React event 参数（`ValueChanged` 语义）。
- **locale**：上游 LocaleConsumer → zh_CN 硬编码缺省 + 参数覆写（okText/cancelText/textAreaProps.placeholder）。
- **数字 0 / 空串 falsy 约定**：`!Boolean(value)` 照抄——空串禁用、`SemiFeedbackEmojiResult` 对象恒可提交（JS truthy）；custom 类型 value 恒空 → 提交钮默认禁用（上游同），`okDisabled: false` 覆写。
- **感谢文字**：`&-thank-text` 钩子上游 JSX 从不渲染 → 不提供渲染路径，6 字段留档 theme 供主题定制（消费方自建内容自行取用）。
- **inset 阴影层由专用画师渲染**：Flutter 无 CSS inset box-shadow 对应物——drop 层进 BoxDecoration（`toDropBoxShadows()`）、inset 层（dark `--semi-shadow-elevated` 首层 `inset 0 0 0 1px`）由 `SemiInsetShadow` 画师精确绘制（贴 padding-box 的内环、零布局影响）；`toBoxShadows()` 对 inset 抛错的显式合同保留，带 blur/offset 的 inset 层构造即抛。

## 用法

```dart
SemiFeedback(
  visible: visible,
  title: '为什么给出这个评分？',
  mode: SemiFeedbackMode.modal,
  type: SemiFeedbackType.emoji,
  onValueChange: (value) => print(value),
  onOk: () async => submit(),   // Future → 提交钮 loading
  onCancel: () => setState(() => visible = false),
)
```

```dart
SemiFeedback(
  visible: visible,
  type: SemiFeedbackType.checkbox,
  checkboxGroupProps: SemiFeedbackCheckboxGroupProps(
    options: [
      SemiCheckboxOption(label: '加载慢', value: 'slow'),
      SemiCheckboxOption(label: '功能缺失', value: 'missing'),
    ],
  ),
  okDisabled: false, // 自定义值来源时放开提交门槛
  onOk: () => setState(() => visible = false),
)
```
