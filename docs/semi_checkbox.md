# SemiCheckbox

非 Material Checkbox（含 SemiCheckboxGroup）。普通型内框 16x20 行高对齐（16x16 描边盒，inset 1px），checked 填主色加白勾，indeterminate 白横杠；card/pureCard 带 3px 圆角外框、padding 12/16，checked 为浅主色底加主色边框，pureCard 隐藏勾选框（opacity 0 保语义、宽度 0、gap 0）。文字随系统缩放换行，不溢出。

## API

`SemiCheckbox({key, label, extra, checked, defaultChecked, indeterminate, disabled, value, type, onChanged, onHover, onFocusChange, autofocus, semanticsLabel})`。

label/extra 为 Object? 双态（String 或 Widget），extra 是 label 下方第二行（间距 4）。type: normal（默认）/card/pureCard。value 是 Group 归属键。indeterminate 仅样式加 Semantics(mixed)，checked 优先。

`SemiCheckboxChangeEvent{checked, preventDefault(), stopPropagation(), defaultPrevented}`：同步可取消，派发完成后封印（事后调用无效，SemiTagCloseEvent 惯例）。checked 是待应用的新值。

`SemiCheckboxGroup({key, value, defaultValue, options, children, direction, disabled, type, onChanged})`。value List<Object>? 非空即受控，defaultValue 为非受控初值，onChanged: ValueChanged<List<Object>>。direction: vertical（默认）/horizontal。options: List<SemiCheckboxOption>（优先于 children，上游 render 顺序）；children 模式直接渲染后代，经 scope 注入。`SemiCheckboxOption{label, value, extra, disabled}`。

## 受控与归属

checked 非空即受控（SemiTag.visible 惯例）：渲染以 checked 为准，点击仅发事件；checked 回到 null 时保留最近受控值（上游会重置 false）。非受控内部值初值 defaultChecked，onChanged 后落地，除非 preventDefault。

组员判定：子项 value 非空且最近 Group scope 存在。组内 checked/defaultChecked 失效，disabled 为组||子，type 以组为准；value 为空的子项独立（不注入、不通知组）。嵌套 Group 取最近 scope。组受控 value 变化同步（列表相等），释放受控值重置为空列表（上游 handlePropValueChange）。

```dart
SemiCheckboxGroup(
  value: const ['a'],
  onChanged: (values) => setState(() => selected = values),
  options: const [
    SemiCheckboxOption(label: 'A', value: 'a'),
    SemiCheckboxOption(label: 'B', value: 'b', extra: 'bee', disabled: true),
  ],
);
// children 模式：子回调先于组回调；stopPropagation 取消组通知
SemiCheckboxGroup(
  onChanged: (values) => print(values),
  children: [
    SemiCheckbox(
      label: 'A',
      value: 'a',
      onChanged: (e) {
        if (someVeto) e.preventDefault(); // 取消非受控落地
        e.stopPropagation();              // 不再通知 Group
      },
    ),
    SemiCheckbox(label: 'solo'),          // 无 value：独立，不入组
  ],
);
```

## indeterminate 与全选半选

Group 不计算全选/半选，由使用方基于 value 推导；indeterminate 只影响外观与 Semantics(mixed)。

```dart
final all = const ['a', 'b', 'c'];
SemiCheckbox(
  label: '全选',
  checked: selected.length == all.length,
  indeterminate: selected.isNotEmpty && selected.length < all.length,
  onChanged: (e) => setState(() => selected = e.checked ? all : const []),
);
```

## 键盘与可访问性

Space/Enter 切换；focus-visible 由 `_keyboardUsed` 门控（任何 KeyDown 置位、点按清位），normal 的焦点环在内框（focus-border 描边加 primary-light-active 2px outline），card 在外框。disabled 不可聚焦、不响应点击；点击区为整行（含 label/extra）。Semantics 暴露 checked/mixed（三态）、enabled、label（semanticsLabel 优先）。RTL 自动镜像（Row 翻转 + EdgeInsetsDirectional）。

## 完整 Sass 映射（66 = 60 FIELDS + 6 motion）

来源 packages/semi-foundation/checkbox/variables.scss（61 声明）与 animation.scss（7 声明）；对账 68 = 66 themed + 2 INTERNAL（$spacing-checkbox_extra-paddingLeft、$transform_scale-checkbox，见 `_CheckboxMetrics`）。全局与语义 token 引用在 resolve 时读取当前主题；type/resolve 列即 `SemiCheckboxThemeData.resolve` 的默认表达式。

| Sass 精确名 | Dart 字段 | 类型 | 源默认 | resolve |
|---|---|---|---|---|
| `$color-checkbox_label-text-default` | `colorCheckboxLabelTextDefault` | `Color` | `var(--semi-color-text-0)` | `theme.colors.colorText0` |
| `$color-checkbox_default-bg-hover` | `colorCheckboxDefaultBgHover` | `Color` | `var(--semi-color-fill-0)` | `theme.colors.colorFill0` |
| `$color-checkbox_default-bg-default` | `colorCheckboxDefaultBgDefault` | `Color` | `transparent` | `const Color(0x00000000)` |
| `$color-checkbox_default-border-hover` | `colorCheckboxDefaultBorderHover` | `Color` | `var(--semi-color-focus-border)` | `theme.colors.colorFocusBorder` |
| `$color-checkbox_default-border-default` | `colorCheckboxDefaultBorderDefault` | `Color` | `var(--semi-color-text-3)` | `theme.colors.colorText3` |
| `$color-checkbox_default-bg-active` | `colorCheckboxDefaultBgActive` | `Color` | `var(--semi-color-fill-1)` | `theme.colors.colorFill1` |
| `$color-checkbox_label-text-disabled` | `colorCheckboxLabelTextDisabled` | `Color` | `var(--semi-color-disabled-text)` | `theme.colors.colorDisabledText` |
| `$color-checkbox_checked-bg-default` | `colorCheckboxCheckedBgDefault` | `Color` | `var(--semi-color-primary)` | `theme.colors.colorPrimary` |
| `$color-checkbox_checked-bg-hover` | `colorCheckboxCheckedBgHover` | `Color` | `var(--semi-color-primary-hover)` | `theme.colors.colorPrimaryHover` |
| `$color-checkbox_checked-bg-active` | `colorCheckboxCheckedBgActive` | `Color` | `var(--semi-color-primary-active)` | `theme.colors.colorPrimaryActive` |
| `$color-checkbox_checked-icon-default` | `colorCheckboxCheckedIconDefault` | `Color` | `var(--semi-color-white)` | `theme.colors.colorWhite` |
| `$color-checkbox_checked-icon-hover` | `colorCheckboxCheckedIconHover` | `Color` | `var(--semi-color-white)` | `theme.colors.colorWhite` |
| `$color-checkbox_checked-icon-active` | `colorCheckboxCheckedIconActive` | `Color` | `var(--semi-color-white)` | `theme.colors.colorWhite` |
| `$color-checkbox_checked-border-default` | `colorCheckboxCheckedBorderDefault` | `Color` | `var(--semi-color-primary)` | `theme.colors.colorPrimary` |
| `$color-checkbox_checked-border-hover` | `colorCheckboxCheckedBorderHover` | `Color` | `var(--semi-color-primary-hover)` | `theme.colors.colorPrimaryHover` |
| `$color-checkbox_checked-border-active` | `colorCheckboxCheckedBorderActive` | `Color` | `var(--semi-color-primary-active)` | `theme.colors.colorPrimaryActive` |
| `$color-checkbox_cardType_checked-bg` | `colorCheckboxCardTypeCheckedBg` | `Color` | `var(--semi-color-primary-light-default)` | `theme.colors.colorPrimaryLightDefault` |
| `$color-checkbox_cardType_checked_disabled-bg` | `colorCheckboxCardTypeCheckedDisabledBg` | `Color` | `var(--semi-color-primary-light-default)` | `theme.colors.colorPrimaryLightDefault` |
| `$color-checkbox_cardType-bg-hover` | `colorCheckboxCardTypeBgHover` | `Color` | `var(--semi-color-fill-0)` | `theme.colors.colorFill0` |
| `$color-checkbox_cardType-bg-active` | `colorCheckboxCardTypeBgActive` | `Color` | `var(--semi-color-fill-1)` | `theme.colors.colorFill1` |
| `$color-checkbox_cardType_checked_border-default` | `colorCheckboxCardTypeCheckedBorderDefault` | `Color` | `var(--semi-color-primary)` | `theme.colors.colorPrimary` |
| `$color-checkbox_cardType_checked_border-hover` | `colorCheckboxCardTypeCheckedBorderHover` | `Color` | `var(--semi-color-primary-hover)` | `theme.colors.colorPrimaryHover` |
| `$color-checkbox_cardType_checked_border-active` | `colorCheckboxCardTypeCheckedBorderActive` | `Color` | `var(--semi-color-primary-active)` | `theme.colors.colorPrimaryActive` |
| `$color-checkbox_cardType_checked_disabled_border-default` | `colorCheckboxCardTypeCheckedDisabledBorderDefault` | `Color` | `var(--semi-color-primary-disabled)` | `theme.colors.colorPrimaryDisabled` |
| `$color-checkbox_cardType_addon-text-default` | `colorCheckboxCardTypeAddonTextDefault` | `Color` | `var(--semi-color-text-0)` | `theme.colors.colorText0` |
| `$color-checkbox_cardType_extra-text-default` | `colorCheckboxCardTypeExtraTextDefault` | `Color` | `var(--semi-color-text-2)` | `theme.colors.colorText2` |
| `$color-checkbox_cardType_inner-bg-hover` | `colorCheckboxCardTypeInnerBgHover` | `Color` | `var(--semi-color-white)` | `theme.colors.colorWhite` |
| `$color-checkbox_cardType_inner-bg-active` | `colorCheckboxCardTypeInnerBgActive` | `Color` | `var(--semi-color-white)` | `theme.colors.colorWhite` |
| `$color-checkbox_cardType_inner-bg-default` | `colorCheckboxCardTypeInnerBgDefault` | `Color` | `var(--semi-color-white)` | `theme.colors.colorWhite` |
| `$color-checkbox_disabled-bg-default` | `colorCheckboxDisabledBgDefault` | `Color` | `var(--semi-color-disabled-fill)` | `theme.colors.colorDisabledFill` |
| `$color-checkbox_disabled-border-default` | `colorCheckboxDisabledBorderDefault` | `Color` | `var(--semi-color-border)` | `theme.colors.colorBorder` |
| `$color-checkbox_checked-bg-disabled` | `colorCheckboxCheckedBgDisabled` | `Color` | `var(--semi-color-primary-disabled)` | `theme.colors.colorPrimaryDisabled` |
| `$color-checkbox_checked-icon-disabled` | `colorCheckboxCheckedIconDisabled` | `Color` | `var(--semi-color-white)` | `theme.colors.colorWhite` |
| `$color-checkbox_primary-outline-focus` | `colorCheckboxPrimaryOutlineFocus` | `Color` | `var(--semi-color-primary-light-active)` | `theme.colors.colorPrimaryLightActive` |
| `$color-checkbox_cardType-border-default` | `colorCheckboxCardTypeBorderDefault` | `Color` | `transparent` | `const Color(0x00000000)` |
| `$color-checkbox_extra-text-default` | `colorCheckboxExtraTextDefault` | `Color` | `var(--semi-color-text-2)` | `theme.colors.colorText2` |
| `$font-checkbox_label-lineHeight` | `fontCheckboxLabelLineHeight` | `double` | `20px` | `20` |
| `$font-checkbox_cardType_addon-size` | `fontCheckboxCardTypeAddonSize` | `double` | `$font-size-regular` | `theme.typography.fontSizeRegular` |
| `$font-checkbox_cardType_addon-fontWeight` | `fontCheckboxCardTypeAddonFontWeight` | `FontWeight` | `$font-weight-bold` | `theme.typography.fontWeightBold` |
| `$font-checkbox_cardType_addon-lineHeight` | `fontCheckboxCardTypeAddonLineHeight` | `double` | `20px` | `20` |
| `$font-checkbox_cardType_extra-size` | `fontCheckboxCardTypeExtraSize` | `double` | `$font-size-regular` | `theme.typography.fontSizeRegular` |
| `$font-checkbox_cardType_extra-fontWeight` | `fontCheckboxCardTypeExtraFontWeight` | `FontWeight` | `normal` | `theme.typography.fontWeightRegular` |
| `$font-checkbox_cardType_extra-lineHeight` | `fontCheckboxCardTypeExtraLineHeight` | `double` | `20px` | `20` |
| `$spacing-checkbox_label-paddingLeft` | `spacingCheckboxLabelPaddingLeft` | `double` | `$spacing-tight` | `8` |
| `$spacing-checkbox_extra-marginTop` | `spacingCheckboxExtraMarginTop` | `double` | `$spacing-extra-tight` | `4` |
| `$spacing-checkbox_cardType-paddingX` | `spacingCheckboxCardTypePaddingX` | `double` | `$spacing-base` | `16` |
| `$spacing-checkbox_cardType-paddingY` | `spacingCheckboxCardTypePaddingY` | `double` | `$spacing-base-tight` | `12` |
| `$spacing-checkbox_cardType_inner-marginRight` | `spacingCheckboxCardTypeInnerMarginRight` | `double` | `$spacing-tight` | `8` |
| `$spacing-checkbox_card_group_vertical-marginBottom` | `spacingCheckboxCardGroupVerticalMarginBottom` | `double` | `$spacing-base` | `16` |
| `$spacing-checkbox_group_vertical-marginBottom` | `spacingCheckboxGroupVerticalMarginBottom` | `double` | `$spacing-base` | `16` |
| `$spacing-checkbox_group_vertical_item-marginBottom` | `spacingCheckboxGroupVerticalItemMarginBottom` | `double` | `$spacing-base-tight` | `12` |
| `$spacing-checkbox_group_horizontal-marginRight` | `spacingCheckboxGroupHorizontalMarginRight` | `double` | `$spacing-base` | `16` |
| `$size-checkbox_inner-shadow` | `sizeCheckboxInnerShadow` | `double` | `$border-thickness-control` | `1` |
| `$width-checkbox_inner` | `widthCheckboxInner` | `double` | `$width-icon-medium` | `16` |
| `$height-checkbox_inner` | `heightCheckboxInner` | `double` | `20px` | `20` |
| `$width-checkbox_cardType_checked-border` | `widthCheckboxCardTypeCheckedBorder` | `double` | `1px` | `1` |
| `$width-checkbox_cardType_checked_disabled-border` | `widthCheckboxCardTypeCheckedDisabledBorder` | `double` | `1px` | `1` |
| `$width-checkbox-outline` | `widthCheckboxOutline` | `double` | `2px` | `2` |
| `$radius-checkbox_cardType` | `radiusCheckboxCardType` | `double` | `3px` | `3` |
| `$radius-checkbox_inner` | `radiusCheckboxInner` | `double` | `var(--semi-border-radius-extra-small)` | `theme.radius.borderRadiusExtraSmall.value` |
| `$transition_duration-checkbox-bg` | `transitionDurationCheckboxBg` | `Duration` | `var(--semi-transition_duration-none)` | `Duration.zero` |
| `$transition_function-checkbox-bg` | `transitionFunctionCheckboxBg` | `Curve` | `var(--semi-transition_function-easeIn)` | `Curves.easeIn` |
| `$transition_delay-checkbox-bg` | `transitionDelayCheckboxBg` | `Duration` | `var(--semi-transition_delay-none)` | `Duration.zero` |
| `$transition_duration-checkbox-border` | `transitionDurationCheckboxBorder` | `Duration` | `var(--semi-transition_duration-none)` | `Duration.zero` |
| `$transition_function-checkbox-border` | `transitionFunctionCheckboxBorder` | `Curve` | `var(--semi-transition_function-easeIn)` | `Curves.easeIn` |
| `$transition_delay-checkbox-border` | `transitionDelayCheckboxBorder` | `Duration` | `var(--semi-transition_delay-none)` | `Duration.zero` |

（另 INTERNAL / 硬编码逐个 `///` 于 `_CheckboxMetrics`：勾选图标 `font-size: 16px`、pureCard 隐藏几何 `opacity: 0;` / `width: 0;` / `column-gap: 0`、focus ring 结构 `outline: $width-checkbox-outline solid $color-checkbox_primary-outline-focus`、inset 描边结构 `box-shadow: inset 0 0 0 $size-checkbox_inner-shadow`、禁用选中 `opacity: 0.75;`。）

## 差异清单

- **checked 非空即受控**（SemiTag.visible 惯例）；受控转非受控保留最近受控值，与上游 `componentDidUpdate` 重置 false 不同。受控只发事件，不受 preventDefault 影响。
- **事件对象裁剪为 preventDefault/stopPropagation**（加 checked/defaultPrevented）；上游 target/nativeEvent.stopImmediatePropagation/name/id/prefixCls/aria-* 不移植。preventDefault() 取消非受控状态落地（standalone 切换或 Group value 变更+通知）；stopPropagation() 取消 Group 通知（上游 child/group 双回调无条件触发，此处按计划语义）。事件先于状态落地，与上游先 setChecked 后 notify 相反（换取可取消）。
- **归属判定 value 非空**：上游 `'value' in props`，此处 value 非空才入组；name/id/prefixCls 不移植（Group 无 name）。
- **动效 none**：transition_duration/delay 均 none、勾选瞬时不加动画（无隐式动画），6 个 motion 字段仅作为主题字段存在；transform_scale 归 INTERNAL（scale(1,1) 无变换）。
- **card 内框白底**指未选中态（cardType_inner-bg-default/hover/active 三个白色字段覆盖透明/fill）；选中/半选时内框走 checked 系列（主色填充+白勾），与上游 CSS 级联（`.semi-checkbox-checked .inner-display` 后置覆盖 `-cardType`）一致。
- **pureCard gap 0 全部生效**（上游仅 vertical pureCard 组清零 column-gap，standalone/水平组仍留 8；此处统一 0）。card/pureCard 外框 padding 12/16 保留（上游 cardType 通用）。
- **Group 释放受控值重置为空**（上游 handlePropValueChange），与 checkbox 的保留惯例不同（计划指定）。
- **options 仅对象形态** SemiCheckboxOption（上游还接受字符串数组）；选项无单项 onChange。
- **indeterminate checked 优先**（图标与 Semantics 均以 checked 为准）；上游测试注释称 indeterminate 视觉优先，但 checkboxInner 图标实现为 checked 优先，按计划取 checked 优先。
- **文字大小**取自 `@include font-size-regular`（hardcode，resolve 到 typography.fontSizeRegular），仅行高/卡片字号入主题字段。
- isEqual 比较为列表相等（listEquals），值元素为 `==` 比较（上游 includes 同为 ==）。
