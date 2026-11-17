# SemiForm

表单（上游 Semi Form 移植）：`SemiForm`（数据面 + 布局容器）+ `SemiFormField`（字段注册/校验/Label/ErrorMessage chrome——上游 `withField` HOC 的 Flutter 拍平）+ `SemiFormController`（FormApi）+ `SemiArrayField`（动态行）+ `SemiFormGroup`（共享 Label + fieldSet 聚合错误）+ `SemiFormSlot`/`SemiFormSection` + 便捷包装（`SemiFormInput/TextArea/Select/Checkbox/Switch/RadioGroup/InputNumber/Slider/Rating`——上游 `Form.Input` 系列）。校验：`rules`（async-validator `RuleItem` 常用子集——required/type/pattern/min/max/len/enum/whitespace/transform）+ 自定义 `validator`（`FutureOr<String>` 空串通过）+ 表单级 `validator`；触发 `change/blur/custom/mount`（field > form > `DEFAULT_TRIGGER: 'change'`）；**异步竞态防护**（validatePromise 序号 token——过期结果丢弃，M4 验收点）；提交/重置/错误展示/`autoScrollToError`。主题对账 **40 = 40 FIELDS + 0 MOTION + 0 INTERNAL**（variables.scss 40 声明行 / 40 唯一名——spacing 27、color 10、font 2、width 1；无 animation.scss 导入；rtl.scss 不计）；★**0 死变量**（40 条均被 form.scss/rtl.scss 消费）。

## API

`SemiForm({controller, initValues: const {}, onSubmit, onSubmitFail, onReset, onValueChange, onErrorChange, onChange, allowEmpty: false, validator, layout: SemiFormLayout.vertical, labelPosition: SemiFormLabelPosition.top, labelWidth, labelAlign: TextAlign.left, extraTextPosition: 'bottom', disabled: false, showValidateIcon: true, stopValidateWithError: false, autoScrollToError: false, trigger: SemiFormTrigger.change, builder, child})`——builder `(context, SemiFormState, SemiFormController)` 优先于 child。

`SemiFormField({field（必填路径 'a.b[2]'）, builder（(context, SemiFormFieldControl) => Widget）, label, labelPosition/labelWidth/labelAlign, noLabel: false, noErrorMessage: false, initValue, rules: List<SemiFormFieldRule>, validator, trigger, transform, convert, allowEmpty, allowEmptyString: false, emptyValue: '', stopValidateWithError, helpText, extraText, extraTextPosition, pure: false, keepState: false, validateStatus, onBlur, labelOptional: false, labelExtra})`。`SemiFormFieldControl`：`field/value/error/touched/validateStatus/disabled/required/onChanged/onBlur/setValue/setTouched/setError/validate/reset/insetLabel`。

`SemiFormController`（FormApi）：`getValue/getValues/setValue/setValues({isOverride})/getError/setError/getTouched/setTouched/getFieldExist/getFormState/submitForm/reset(fields?)/validate(fields?, silent)/getInitValue/getInitValues/scrollToField/scrollToError({field, index})`。

`SemiArrayField({field?, initValue, builder})`——builder 收 `SemiArrayFieldApi{items[{key, field, remove}], add(index?), addWithInitValue(obj, index?)}`。`SemiFormGroup({fieldSet, label, labelPosition/Width/Align, extraText, child})`。`SemiFormSlot({label, noLabel, labelPosition, error, child})`。`SemiFormSection({title, child})`。规则 `SemiFormFieldRule({type, required, pattern, min, max, len, values, whitespace, message, transform})`。包装 9 件均收 `field/label/rules/validator/trigger/onChanged/onBlur/helpText/extraText/initValue/labelOptional/labelExtra/labelPosition/Width/Align/disabled` + 各控件参数。

## 行为

### 数据面与注册（foundation.ts）

Form 挂载即以 `initValues` 深拷贝起步（foundation.ts:36-45）。字段注册（withField.tsx:547-577）：`initValue` 优先、其次 Form.initValues 路径值；空串在 `allowEmpty`/`allowEmptyString` 缺省时不入 values（foundation.ts:144-162）。`keepState` 重挂载从 formState 恢复 value/error/touched（foundation.ts:98-143；★ArrayField 内 keepState 失效 quirk 照抄）；非 keepState 注销即清三表（foundation.ts:166-188）。字段路径 dot/bracket（`'b.name[2]'`）。

### 校验引擎（withField.tsx:274-409 + async-validator 子集）

触发：field.trigger > form.trigger > `change`（utils.ts:100 transformTrigger）。自定义 `validator`（同步/`Future`；空串 = 通过；抛错按错误处理）；否则 rules 按序检查（required/whitespace/type(string/number/integer/boolean/array/enum/url/email/regexp)/len/min/max/pattern；非必填空值跳过其余检查）；`stopValidateWithError` = async-validator `first`（首错即止）。★`message: ''` 空文案仍算错误（withField.tsx:311-330 quirk——错误行整行不渲染，helpText 不回退）。**竞态防护**：`validatePromise` 序号 token——新一轮校验使旧结果过期作废（不写 state）。status：error/success/default（props.validateStatus 优先）。表单级 `validator` 返回错误表并注入字段（foundation.ts:243-305 injectErrorToField）。`validate(fields?, silent)` 逐字段并行后统一回写（foundation.ts:308-350）。

### 提交/重置/滚动

`submitForm()`：validate().then → `onSubmit(values)` / catch → `onSubmitFail(errors, values)`（foundation.ts:352-366）。`reset(fields?)`：字段回 initValue、清 error/touched/status；ArrayField 按注册 initValue 还原 + updateKey 重挂载（foundation.ts:434-447）。`scrollToField/scrollToError/autoScrollToError`：`Scrollable.ensureVisible` 近似 `'smooth'`/`'start'`（foundation.ts:798-857）。

### 变更处理（withField.tsx:416-508）

`control.onChanged`：convert（UI 前转换）→ `emptyValue`（缺省 `''`）归一 null（allowEmpty/allowEmptyString 保留）→ 提交 value + touched → change 触发校验。`control.onBlur`：置 touched + blur 触发校验。★上游两阶段提交（silent 写 → 用户 onChange → commit；用户抛错回滚）简化为顺序提交——用户 onChange 先于提交执行（便捷包装口径），见差异清单。

### Label / ErrorMessage / 布局（label.tsx / errorMessage.tsx / form.scss）

Label：文本（缺省字段路径）+ 必填 `*`（form.scss:122 `content: "*"`——requiredMark 色/字重；disabled 换 disabled 色）+ `labelOptional`「（可选）」+ `labelExtra`；`labelWidth`/`labelAlign`。布局：`labelPosition` top/left/inset（inset 注入控件 `insetLabel`——SemiFormInput/TextArea 支持）；`layout` vertical/horizontal 字段间距（form_field_*）。ErrorMessage：error（String | List 逗号连接）/helpText（无错误时常显）+ 状态图标（warning→`IconAlertTriangle`（warning 色）/ error→`IconAlertCircle`（错误色继承）；`showValidateIcon`）；extraText middle/bottom。Section：标题（18 号）+ 底边线；Slot：无绑定 label/error 槽。


## 主题（40 对账）

来源 packages/semi-foundation/form/variables.scss（40 声明行 / 40 唯一名——spacing 27、color 10、font 2、width 1）；模块无 animation.scss（0 MOTION）。对账 **40 = 40 FIELDS + 0 MOTION + 0 INTERNAL**（HARDCODES 另列见 B 表；`$module` 类名胶水与 rtl.scss 不计）。★**0 死变量**。全局 token 解析：`var(--semi-color-danger)` → `theme.colors.colorDanger`、`var(--semi-color-disabled-text)` → `theme.colors.colorDisabledText`、`var(--semi-color-text-0)` → `theme.colors.colorText0`、`var(--semi-color-tertiary)` → `theme.colors.colorTertiary`、`var(--semi-color-border)` → `theme.colors.colorBorder`、`var(--semi-color-warning)` → `theme.colors.colorWarning`；引用 token：`$spacing-base/base-tight/extra-tight/tight/super-loose` → 16/12/4/8/40、`$height-control-default` → 32、`$border-thickness-control` → 1、`$font-weight-bold` → `theme.typography.fontWeightBold`（= w600）。类型覆盖：**10 Color + 28 double + 2 FontWeight**。解析列即 `SemiFormThemeData.resolve` 默认表达式。

### A. Sass 声明映射（40 FIELDS）

| Sass 声明（默认值） | 去向 | 解析 / 说明 |
|---|---|---|
| `$spacing-form_field_horizontal-paddingRight: $spacing-base` | `spacingFormFieldHorizontalPaddingRight` | `16`（水平布局字段右 padding（layout: horizontal）） |
| `$spacing-form_field_group_horizontal-paddingRight: $spacing-base` | `spacingFormFieldGroupHorizontalPaddingRight` | `16`（水平布局组右 padding（SemiFormGroup）） |
| `$spacing-form_field_vertical-paddingTop: $spacing-base-tight` | `spacingFormFieldVerticalPaddingTop` | `12`（垂直布局字段上 padding（layout: vertical）） |
| `$spacing-form_field_vertical-paddingBottom: $spacing-base-tight` | `spacingFormFieldVerticalPaddingBottom` | `12`（垂直布局字段下 padding（同上）） |
| `$spacing-form_field_group_vertical-paddingTop: $spacing-base-tight` | `spacingFormFieldGroupVerticalPaddingTop` | `12`（垂直布局组上 padding（SemiFormGroup）） |
| `$spacing-form_field_group_vertical-paddingBottom: $spacing-base-tight` | `spacingFormFieldGroupVerticalPaddingBottom` | `12`（垂直布局组下 padding（同上）） |
| `$spacing-form_label-paddingRight: $spacing-base` | `spacingFormLabelPaddingRight` | `16`（标签右 padding（left 布局）） |
| `$spacing-form_label-paddingTop: ($height-control-default - 20px) * 0.5` | `spacingFormLabelPaddingTop` | `6`（标签上 padding（控件行高对齐）） |
| `$spacing-form_label-marginBottom: $spacing-extra-tight` | `spacingFormLabelMarginBottom` | `4`（标签下外边距） |
| `$spacing-form_label-marginTop: 0px` | `spacingFormLabelMarginTop` | `0`（标签上外边距） |
| `$spacing-form_label_extra-marginLeft: $spacing-extra-tight` | `spacingFormLabelExtraMarginLeft` | `4`（标签 extra/「（可选）」左间距） |
| `$spacing-form_label_required-marginLeft: $spacing-extra-tight` | `spacingFormLabelRequiredMarginLeft` | `4`（必填 * 左间距） |
| `$spacing-form_label_posLeft-marginRight: 0` | `spacingFormLabelPosLeftMarginRight` | `0`（left 标签右外边距（★`0` 裸数字照抄）） |
| `$spacing-form_label_posLeft-marginBottom: 0` | `spacingFormLabelPosLeftMarginBottom` | `0`（left 标签下外边距（★`0` 裸数字照抄）） |
| `$spacing-form_label_posTop-paddingTop: $spacing-extra-tight` | `spacingFormLabelPosTopPaddingTop` | `4`（top 标签上 padding） |
| `$spacing-form_label_posTop-paddingBottom: $spacing-extra-tight` | `spacingFormLabelPosTopPaddingBottom` | `4`（top 标签下 padding） |
| `$spacing-form_extra_posMid-marginTop: $spacing-extra-tight` | `spacingFormExtraPosMidMarginTop` | `4`（extraText middle 上外边距） |
| `$spacing-form_extra_posMid-marginBottom: $spacing-extra-tight` | `spacingFormExtraPosMidMarginBottom` | `4`（extraText middle 下外边距） |
| `$spacing-form_extra_posBottom-marginTop: $spacing-extra-tight` | `spacingFormExtraPosBottomMarginTop` | `4`（extraText bottom 上外边距） |
| `$spacing-form_switch_rating_marginY: ($height-control-default - 24px) * 0.5` | `spacingFormSwitchRatingMarginY` | `4`（Switch/Rating 高度对齐 marginY（SemiFormSwitch 包装）） |
| `$color-form_requiredMark_disabled-text-default: var(--semi-color-danger)` | `colorFormRequiredMarkDisabledTextDefault` | `theme.colors.colorDanger`（禁用必填 * 色） |
| `$color-form_label_disabled-text-default: var(--semi-color-disabled-text)` | `colorFormLabelDisabledTextDefault` | `theme.colors.colorDisabledText`（禁用标签文字色） |
| `$font-form_label-fontWeight: $font-weight-bold` | `fontFormLabelFontWeight` | `theme.typography.fontWeightBold`（标签字重） |
| `$color-form_label-text-default: var(--semi-color-text-0)` | `colorFormLabelTextDefault` | `theme.colors.colorText0`（标签文字色） |
| `$color-form_label_optional-text-default: var(--semi-color-tertiary)` | `colorFormLabelOptionalTextDefault` | `theme.colors.colorTertiary`（「（可选）」文字色） |
| `$color-form_label_extra-text-default: var(--semi-color-tertiary)` | `colorFormLabelExtraTextDefault` | `theme.colors.colorTertiary`（标签 extra 文字色） |
| `$color-form_requiredMark-text-default: var(--semi-color-danger)` | `colorFormRequiredMarkTextDefault` | `theme.colors.colorDanger`（必填 * 色） |
| `$font-form_requiredMark-fontWeight: $font-weight-bold` | `fontFormRequiredMarkFontWeight` | `theme.typography.fontWeightBold`（必填 * 字重） |
| `$color-form_message_error-text-default: var(--semi-color-danger)` | `colorFormMessageErrorTextDefault` | `theme.colors.colorDanger`（错误文字色（error 图标继承）） |
| `$color-form_alertIcon-icon-default: var(--semi-color-warning)` | `colorFormAlertIconIconDefault` | `theme.colors.colorWarning`（warning 图标色（alert_triangle）） |
| `$spacing-form_statusIcon-marginRight: $spacing-extra-tight` | `spacingFormStatusIconMarginRight` | `4`（状态图标右间距） |
| `$spacing-form_message-marginTop: $spacing-extra-tight` | `spacingFormMessageMarginTop` | `4`（错误/帮助行上外边距） |
| `$color-form_section-text-default: var(--semi-color-text-0)` | `colorFormSectionTextDefault` | `theme.colors.colorText0`（Section 标题文字色） |
| `$color-form_section-border-default: var(--semi-color-border)` | `colorFormSectionBorderDefault` | `theme.colors.colorBorder`（Section 标题底边色） |
| `$width-form_section-border: $border-thickness-control` | `widthFormSectionBorder` | `1`（Section 标题底边宽） |
| `$spacing-form_section-marginTop: $spacing-super-loose - $spacing-base-tight` | `spacingFormSectionMarginTop` | `28`（Section 上外边距） |
| `$spacing-form_section_text-paddingBottom: $spacing-tight` | `spacingFormSectionTextPaddingBottom` | `8`（Section 标题下 padding） |
| `$spacing-form_section_text-marginBottom: $spacing-extra-tight` | `spacingFormSectionTextMarginBottom` | `4`（Section 标题下外边距） |
| `$spacing-form_section_text-paddingTop: 0px` | `spacingFormSectionTextPaddingTop` | `0`（Section 标题上 padding） |
| `$spacing-form_section_text-marginTop: 0px` | `spacingFormSectionTextMarginTop` | `0`（Section 标题上外边距） |

### B. HARDCODES 另列（`_FormMetrics` / 调用点，widget 源内含原始片段）

| 上游片段 | 落点 |
|---|---|
| `DEFAULT_TRIGGER: 'change'` | 校验触发缺省（constants.ts:15） |
| `optional: '（可选）'` | 标签可选后缀 locale（zh_CN.ts:173） |
| `content: "*"` | 必填 `*` 标记（form.scss:122） |
| `warning: <IconAlertTriangle />` | warning 状态图标（errorMessage.tsx:78 → SemiIcons.alertTriangle） |
| `error: <IconAlertCircle />` | error 状态图标（errorMessage.tsx:79 → SemiIcons.alertCircle） |
| `behavior: 'smooth'` / `block: 'start'` | scrollToError 滚动参数（foundation.ts:803——ensureVisible 近似） |
| `@include font-size-regular` | 标签/错误行文本号 14（form.scss:101/148/258） |
| `@include font-size-header-5` | Section 标题号 18（form.scss:303） |
| `getUuidv4` | ArrayField updateKey 重挂载（foundation.ts:193/445） |
| `first: mergeStopValidateWithError` | stopValidateWithError 首错即止（withField.tsx:286） |
| `message: ''` | 空 message 仍算错误 quirk（withField.tsx:314） |
| `labelPosition: 'top'` | 标签位置缺省（baseForm.tsx:103） |

## 差异清单

★照搬留档（quirk 原样）：

1. **`message: ''` 空文案错误**：错误行整行不渲染、helpText 不回退（errorMessage.tsx:74-76）。
2. **keepState 在 ArrayField 内失效**（withField.tsx:204-210——行路径位移会串态）。
3. **空串语义**：`emptyValue`（缺省 `''`）归一 null；`allowEmpty`/`allowEmptyString` 保留（withField.tsx:437-447）。
4. **非必填空值跳过其余规则**（async-validator 语义）。
5. **arrowIcon 类 defaultProps quirk 不适用**（Form 无图标缺省）。

偏差/裁剪：

6. **async-validator 瘦身**：`RuleItem.fields/defaultField`（嵌套对象规则）、回调式 `asyncValidator` 不移植——自定义 `validator`（`FutureOr<String>`）覆盖异步；缺省文案用同款英文模板（`%s is required` 式）。
7. **两阶段提交简化**：上游 silent 写 → 用户 onChange → commit（抛错回滚）→ 顺序提交（便捷包装先调用户 onChanged 再 control.onChanged）；「onChange 内读最新值」读 `control.value`。
8. **labelCol/wrapperCol 栅格不移植**（无 Grid——labelWidth/labelPosition 覆盖布局）。
9. **hooks/HOC 出口拍平**：`Form.useForm/useFormState/useFieldState/useFieldApi/withField/withFormState/withFormApi` → `SemiFormController` + `SemiFormFieldControl` builder。
10. **`component`/`render` props** → builder 单口径。
11. **id/aria 族 → Semantics**；`name`（表单原生 name）、`fieldClassName/fieldStyle`、`stopPropagation` 不移植。
12. **validateStatus 仅 normal/error/warning/success**（上游 `'error' | 'success' | 'default'` + props 覆盖——Flutter SemiInputStatus 口径）。
13. **滚动**：`scroll-into-view-if-needed` → `Scrollable.ensureVisible`（300ms easeInOut 近似 `'smooth'`）。
14. **便捷包装 9 件**（Input/TextArea/Select/Checkbox/Switch/RadioGroup/InputNumber/Slider/Rating）值形态适配：Checkbox/Switch 用 `checked` 口径、InputNumber 用 `onNumberChange(num)`、Slider 取单值 double；其余输入经通用 `SemiFormField` builder 接入。insetLabel（labelPosition: inset）仅 SemiFormInput 支持（TextArea 无 insetLabel）。
15. **ArrayField updateKey**：uuid 重挂载 → 计数器 + 稳定行 Key；`add(index?)` 插入空值行、`addWithInitValue` 带值行。
16. **SemiFormGroup** 为 group.tsx 轻量版：共享 Label + fieldSet 首错聚合；上游 Grid 卡片 RadioGroup margin 等细节不移植。
17. **`onChange(formState)`** 语义保留（每次状态变更回调 `SemiFormState`）。
