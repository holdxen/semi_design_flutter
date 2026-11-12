# SemiRadio / SemiRadioGroup

非 Material 单选框（含 SemiRadioGroup）。互斥单选：组内恰有一项 `value == 组 value` 渲染选中。普通型圆圈 16x16（`border-radius: $width-radio_inner` 正圆）位于 20px 行高槽内、边框 1px、选中主色填充加白点（`radio` 图标资产）；button 型隐藏圆圈、标签即按钮（三档 padding/字号/行高、字重 600、选中 bg-3 底 + primary 字）；card/pureCard 带 3px 圆角外框（paddingX 16 / paddingY 12），checked 浅主色底 + primary 边框，圆圈白底（card-bg-* 三态），pureCard 不渲染圆圈。文字随系统缩放换行，不溢出。

## API

`SemiRadio([child,] {key, value, checked, defaultChecked, disabled, extra, type, mode, onChanged, onHover, onFocusChange, autofocus, semanticsLabel})`。

child/extra 为 Object? 双态（String 或 Widget），child 是标签（位置参数，同 SemiCheckbox 的 label 语义；Dart 不允许可选位置参数与命名参数混用，故 child 为必选位置参数，无标签传 null）。type: normal（默认，上游 `default`）/button/card/pureCard。mode: normal（默认）/advanced（组内可取消选中）。value 是 Group 归属比较键（严格 `==`）。

`SemiRadioChangeEvent{checked, value, preventDefault(), stopPropagation(), defaultPrevented}`：同步可取消，派发完成后封印（事后调用无效，SemiCheckboxChangeEvent 惯例）。checked/value 是摊平上游 `RadioChangeEvent.target{}` 的待应用值：选中时 value 为该成员 value，advanced 取消时 `checked=false, value=null`。

`SemiRadioGroup({key, value, defaultValue, onChanged, disabled, direction, type, buttonSize, mode, options, children})`。value Object? 非空即受控（单值），defaultValue 为非受控初值，onChanged: ValueChanged<SemiRadioChangeEvent>（e.value 即新组值）。direction: horizontal（默认，上游 DEFAULT_DIRECTION）/vertical。type/mode/buttonSize 覆盖全体成员（buttonSize: small/middle/large，上游命名照抄）。options: List<SemiRadioOption>（优先于 children，上游 render 顺序）；children 模式直接渲染后代，经 scope 注入。`SemiRadioOption{label, value, extra, disabled}`。

## 行为

### 互斥与归属

组员判定：子项 value 非空且最近 Group scope 存在。组内 `realChecked = (scope.value == radio.value)`（严格 ==）；组内 checked/defaultChecked 失效，disabled 为组||子，type/mode/buttonSize 以组为准；value 为空的子项独立（不注入、不通知组）。嵌套 Group 取最近 scope。组受控 value 变化同步；释放受控值保留最后值（checkbox :141 同款）。

### onChange 链

点击 → 先 `scope.notifyChange(event)`（→ 组 onChanged，上游 radio.tsx :176-184 组先于个体）→ 除非 `event.stopPropagation()` 则断 → 再个体 `onChanged(event)`。**组内点已选中项（组 value == 成员 value）且非 advanced → 完全静默**（不通知组、不通知个体——上游原生 radio 点击已选中项无 change 事件，radioGroupFoundation.handleChange :58 `lastValue !== value` 门在此预检）。独立 Radio：checkbox 同款切换（Space/Enter/点击翻转）；非受控落地、受控只回调；preventDefault 否决非受控落地（受控不受影响）。

### advanced

advanced 点已选项 → 取消：组值置 null、`event.checked=false`、`event.value=null`（上游 radioGroupFoundation.handleChange :46）；非受控组落地 null，受控只回调。advanced 点未选项与 normal 相同（选中）。

### roving 键盘

组内整组一个 Tab 停靠点（WAI-ARIA radiogroup；上游依赖原生 radio 语义，此处自实现，semi_dropdown._handleKey 的 enabledIndices 环绕为先例）：roving tabindex 以 skipTraversal 实现，仅"当前项"参与 Tab 遍历；初始当前项 = 已选中项或第一个启用项（注册序即树序）。→/↓ 移到下一启用项**并选中**（环绕、跳过 disabled），←/↑ 上一项并选中，选中走完整 onChange 链（受控只回调）。Space 选中当前焦点项（无选中时 Space 选中初始焦点项）。Enter 不拦截（上游原生 radio 不响应 Enter）。独立项 Space/Enter 切换（checkbox `_handleKey` 同款）。

### 焦点环

`_keyboardUsed` 门控（任意 KeyDown 置位、点按清位，checkbox 同款）：普通形态环在圆圈上（BoxShadow spreadRadius = widthRadioOutline、色彩 colorRadioPrimaryOutlineFocus），button/card/pureCard 形态在容器上；未选中聚焦时圆圈描边走 `focus-border`（hover 边框色）。disabled 不可聚焦、不响应点击；点击区为整行（含 label/extra）并聚焦该成员（上游 label 点击聚焦 input）。Semantics 暴露 checked/enabled/label（semanticsLabel 优先）。RTL 自动镜像（Row 翻转 + EdgeInsetsDirectional）。

## 主题（103 对账）

来源 packages/semi-foundation/radio/variables.scss（96 声明；L30 整行注释不计入）与 animation.scss（7 声明），0 同名重复。对账 **103 = 96 FIELDS + 6 MOTION + 1 INTERNAL**（`$transform_scale-radio` 见 `_RadioMetrics`）。96 FIELDS 含 5 条死变量（标注「（上游未消费）」）：`$spacing-radio_addon-marginLeft`、`$spacing-radio_addon_buttonRadio_marginLeft`、`$spacing-radio_extra-paddingLeft`、`$spacing-radio_card_group_vertical-marginBottom`、`$spacing-radio_cardRadioGroup_inner-marginRight`。全局与语义 token 引用在 resolve 时读取当前主题；解析列即 `SemiRadioThemeData.resolve` 的默认表达式（`white`/`rgba(var(--semi-white),1)` 取白字面量，与 `theme.palette.white` 等值）。

### A. Sass 声明映射（96 FIELDS + 6 MOTION + 1 INTERNAL = 103）

| Sass 声明（默认值） | 去向 | 解析 / 说明 |
|---|---|---|
| `$color-radio_default-border-default: var(--semi-color-text-3)` | `colorRadioDefaultBorderDefault` | `theme.colors.colorText3` |
| `$color-radio_default-bg-default: transparent` | `colorRadioDefaultBgDefault` | `const Color(0x00000000)` |
| `$color-radio_default-bg-hover: var(--semi-color-fill-0)` | `colorRadioDefaultBgHover` | `theme.colors.colorFill0` |
| `$color-radio_default-bg-active: var(--semi-color-fill-1)` | `colorRadioDefaultBgActive` | `theme.colors.colorFill1` |
| `$color-radio_default-border-hover: var(--semi-color-focus-border)` | `colorRadioDefaultBorderHover` | `theme.colors.colorFocusBorder` |
| `$color-radio_checked-border-hover: var(--semi-color-primary-hover)` | `colorRadioCheckedBorderHover` | `theme.colors.colorPrimaryHover` |
| `$color-radio_checked-border-active: var(--semi-color-primary-active)` | `colorRadioCheckedBorderActive` | `theme.colors.colorPrimaryActive` |
| `$color-radio_default-text-default: var(--semi-color-text-0)` | `colorRadioDefaultTextDefault` | `theme.colors.colorText0` |
| `$color-radio_extra-text-default: var(--semi-color-text-2)` | `colorRadioExtraTextDefault` | `theme.colors.colorText2` |
| `$color-radio_primary-bg-hover: var(--semi-color-primary-hover)` | `colorRadioPrimaryBgHover` | `theme.colors.colorPrimaryHover` |
| `$color-radio_primary-bg-active: var(--semi-color-primary-active)` | `colorRadioPrimaryBgActive` | `theme.colors.colorPrimaryActive` |
| `$color-radio_primary-border-default: var(--semi-color-primary)` | `colorRadioPrimaryBorderDefault` | `theme.colors.colorPrimary` |
| `$color-radio_primary-bg-default: var(--semi-color-primary)` | `colorRadioPrimaryBgDefault` | `theme.colors.colorPrimary` |
| `$color-radio_primary-text-default: rgba(var(--semi-white), 1)` | `colorRadioPrimaryTextDefault` | `const Color(0xffffffff)` |
| `$color-radio_checked-bg-disabled: var(--semi-color-primary-disabled)` | `colorRadioCheckedBgDisabled` | `theme.colors.colorPrimaryDisabled` |
| `$color-radio_default-border-disabled: var(--semi-color-border)` | `colorRadioDefaultBorderDisabled` | `theme.colors.colorBorder` |
| `$color-radio_checked-border-disabled: var(--semi-color-primary-disabled)` | `colorRadioCheckedBorderDisabled` | `theme.colors.colorPrimaryDisabled` |
| `$color-radio_disabled-bg-default: var(--semi-color-disabled-fill)` | `colorRadioDisabledBgDefault` | `theme.colors.colorDisabledFill` |
| `$color-radio_disabled-bg-hover: transparent` | `colorRadioDisabledBgHover` | `const Color(0x00000000)` |
| `$color-radio_disabled-text-default: var(--semi-color-disabled-text)` | `colorRadioDisabledTextDefault` | `theme.colors.colorDisabledText` |
| `$color-radio_disabled-border-default: var(--semi-color-border)` | `colorRadioDisabledBorderDefault` | `theme.colors.colorBorder` |
| `$color-radio_checked-icon-disabled: rgba(var(--semi-white), 1)` | `colorRadioCheckedIconDisabled` | `const Color(0xffffffff)` |
| `$color-radio_buttonRadio-text-default: var(--semi-color-text-1)` | `colorRadioButtonRadioTextDefault` | `theme.colors.colorText1` |
| `$color-radio_buttonRadio-bg-default: var(--semi-color-fill-0)` | `colorRadioButtonRadioBgDefault` | `theme.colors.colorFill0` |
| `$color-radio_buttonRadio-text-disabled: var(--semi-color-disabled-text)` | `colorRadioButtonRadioTextDisabled` | `theme.colors.colorDisabledText` |
| `$color-radio_addon_buttonRadio-bg-hover: var(--semi-color-fill-1)` | `colorRadioAddonButtonRadioBgHover` | `theme.colors.colorFill1` |
| `$color-radio_addon_buttonRadio-text-checked: var(--semi-color-primary)` | `colorRadioAddonButtonRadioTextChecked` | `theme.colors.colorPrimary` |
| `$color-radio_addon_buttonRadio-bg-checked: var(--semi-color-bg-3)` | `colorRadioAddonButtonRadioBgChecked` | `theme.colors.colorBg3` |
| `$color-radio_cardRadioGroup-bg-default: transparent` | `colorRadioCardRadioGroupBgDefault` | `const Color(0x00000000)` |
| `$color-radio_cardRadioGroup-bg-checked: var(--semi-color-primary-light-default)` | `colorRadioCardRadioGroupBgChecked` | `theme.colors.colorPrimaryLightDefault` |
| `$color-radio_cardRadioGroup_disabled-bg-checked: var(--semi-color-primary-light-default)` | `colorRadioCardRadioGroupDisabledBgChecked` | `theme.colors.colorPrimaryLightDefault` |
| `$color-radio_cardRadioGroup_disabled-bg-active: transparent` | `colorRadioCardRadioGroupDisabledBgActive` | `const Color(0x00000000)` |
| `$color-radio_cardRadioGroup-bg-hover: var(--semi-color-fill-0)` | `colorRadioCardRadioGroupBgHover` | `theme.colors.colorFill0` |
| `$color-radio_cardRadioGroup-bg-active: var(--semi-color-fill-1)` | `colorRadioCardRadioGroupBgActive` | `theme.colors.colorFill1` |
| `$color-radio_cardRadioGroup_border-default: transparent` | `colorRadioCardRadioGroupBorderDefault` | `const Color(0x00000000)` |
| `$color-radio_cardRadioGroup_border-active: var(--semi-color-primary)` | `colorRadioCardRadioGroupBorderActive` | `theme.colors.colorPrimary` |
| `$color-radio_cardRadioGroup_checked_border-active: var(--semi-color-primary-active)` | `colorRadioCardRadioGroupCheckedBorderActive` | `theme.colors.colorPrimaryActive` |
| `$color-radio_cardRadioGroup_checked_border-hover: var(--semi-color-primary-hover)` | `colorRadioCardRadioGroupCheckedBorderHover` | `theme.colors.colorPrimaryHover` |
| `$color-radio_cardRadioGroup_border_disabled-active: var(--semi-color-primary-disabled)` | `colorRadioCardRadioGroupBorderDisabledActive` | `theme.colors.colorPrimaryDisabled` |
| `$color-radio_cardRadioGroup_addon-text-default: var(--semi-color-text-0)` | `colorRadioCardRadioGroupAddonTextDefault` | `theme.colors.colorText0` |
| `$color-radio_cardRadioGroup_extra-text-default: var(--semi-color-text-2)` | `colorRadioCardRadioGroupExtraTextDefault` | `theme.colors.colorText2` |
| `$color-radio_cardRadioGroup_checked_disabled-border-default: var(--semi-color-primary-disabled)` | `colorRadioCardRadioGroupCheckedDisabledBorderDefault` | `theme.colors.colorPrimaryDisabled` |
| `$color-radio_cardRadioGroup_checked_disabled-border-hover: var(--semi-color-primary-disabled)` | `colorRadioCardRadioGroupCheckedDisabledBorderHover` | `theme.colors.colorPrimaryDisabled` |
| `$color-radio_card-bg-hover: var(--semi-color-white)` | `colorRadioCardBgHover` | `const Color(0xffffffff)` |
| `$color-radio_card-bg-active: var(--semi-color-white)` | `colorRadioCardBgActive` | `const Color(0xffffffff)` |
| `$color-radio_card-bg-default: var(--semi-color-white)` | `colorRadioCardBgDefault` | `const Color(0xffffffff)` |
| `$color-radio_primary-outline-focus: var(--semi-color-primary-light-active)` | `colorRadioPrimaryOutlineFocus` | `theme.colors.colorPrimaryLightActive` |
| `$radius-radio_cardRadioGroup: var(--semi-border-radius-small)` | `radiusRadioCardRadioGroup` | `theme.radius.borderRadiusSmall.value` |
| `$radius-radio_addon_buttonRadio: var(--semi-border-radius-small)` | `radiusRadioAddonButtonRadio` | `theme.radius.borderRadiusSmall.value` |
| `$radius-radio_buttonRadio: var(--semi-border-radius-small)` | `radiusRadioButtonRadio` | `theme.radius.borderRadiusSmall.value` |
| `$width-radio_cardRadioGroup_checked-border: 1px` | `widthRadioCardRadioGroupCheckedBorder` | `1` |
| `$width-radio_cardRadioGroup_checked_disabled-border: 1px` | `widthRadioCardRadioGroupCheckedDisabledBorder` | `1` |
| `$width-radio_hover-border: $border-thickness-control` | `widthRadioHoverBorder` | `1` |
| `$width-radio_disabled-border: $border-thickness-control` | `widthRadioDisabledBorder` | `1` |
| `$width-radio_innder-border: $border-thickness-control` | `widthRadioInnderBorder` | `1` |
| `$width-radio-outline: 2px` | `widthRadioOutline` | `2` |
| `$height-radio_inner_min: 20px` | `heightRadioInnerMin` | `20` |
| `$width-radio_inner: $width-icon-medium` | `widthRadioInner` | `16` |
| `$spacing-radio_addon-paddingLeft: $spacing-tight` | `spacingRadioAddonPaddingLeft` | `8` |
| `$spacing-radio_addon-marginLeft: $width-radio_inner` | `spacingRadioAddonMarginLeft` | `16（上游未消费）` |
| `$spacing-radio_addon_buttonRadio_large-paddingX: $spacing-loose` | `spacingRadioAddonButtonRadioLargePaddingX` | `24` |
| `$spacing-radio_addon_buttonRadio_large-paddingY: $spacing-base-tight * 0.5` | `spacingRadioAddonButtonRadioLargePaddingY` | `6` |
| `$spacing-radio_addon_buttonRadio_small-paddingX: $spacing-base` | `spacingRadioAddonButtonRadioSmallPaddingX` | `16` |
| `$spacing-radio_addon_buttonRadio_small-paddingY: $spacing-super-tight` | `spacingRadioAddonButtonRadioSmallPaddingY` | `2` |
| `$spacing-radio_addon_buttonRadio_middle-paddingX: $spacing-base` | `spacingRadioAddonButtonRadioMiddlePaddingX` | `16` |
| `$spacing-radio_addon_buttonRadio_middle-paddingY: $spacing-extra-tight` | `spacingRadioAddonButtonRadioMiddlePaddingY` | `4` |
| `$spacing-radio_addon_buttonRadio_marginLeft: $spacing-none` | `spacingRadioAddonButtonRadioMarginLeft` | `0（上游未消费）` |
| `$spacing-radio_extra-paddingLeft: $width-radio_inner + $spacing-tight` | `spacingRadioExtraPaddingLeft` | `24（上游未消费）` |
| `$spacing-radio_content-rowGap: 4px` | `spacingRadioContentRowGap` | `4` |
| `$spacing-radio_group_vertical-marginBottom: $spacing-base-tight` | `spacingRadioGroupVerticalMarginBottom` | `12` |
| `$spacing-radio_card_group_vertical-marginBottom: $spacing-base` | `spacingRadioCardGroupVerticalMarginBottom` | `16（上游未消费）` |
| `$spacing-radio_group_horizontal-marginRight: $spacing-base` | `spacingRadioGroupHorizontalMarginRight` | `16` |
| `$spacing-radio_buttonRadio-padding: $spacing-extra-tight` | `spacingRadioButtonRadioPadding` | `4` |
| `$spacing-radio_buttonRadioGroup_small-paddingX: $spacing-super-tight` | `spacingRadioButtonRadioGroupSmallPaddingX` | `2` |
| `$spacing-radio_buttonRadioGroup_small-paddingY: $spacing-extra-tight` | `spacingRadioButtonRadioGroupSmallPaddingY` | `4` |
| `$spacing-radio_buttonRadioGroup_middle-padding: $spacing-extra-tight` | `spacingRadioButtonRadioGroupMiddlePadding` | `4` |
| `$spacing-radio_buttonRadioGroup_large-padding: $spacing-extra-tight` | `spacingRadioButtonRadioGroupLargePadding` | `4` |
| `$spacing-radio_buttonRadioGroup-paddingRight: $spacing-none` | `spacingRadioButtonRadioGroupPaddingRight` | `0` |
| `$spacing-radio_cardRadioGroup-paddingX: $spacing-base` | `spacingRadioCardRadioGroupPaddingX` | `16` |
| `$spacing-radio_cardRadioGroup-paddingY: $spacing-base-tight` | `spacingRadioCardRadioGroupPaddingY` | `12` |
| `$spacing-radio_cardRadioGroup_inner-marginRight: $spacing-tight` | `spacingRadioCardRadioGroupInnerMarginRight` | `8（上游未消费）` |
| `$font-radio_buttonRadio_large-default-size: $font-size-regular` | `fontRadioButtonRadioLargeDefaultSize` | `theme.typography.fontSizeRegular` |
| `$font-radio_buttonRadio_small-default-size: $font-size-small` | `fontRadioButtonRadioSmallDefaultSize` | `theme.typography.fontSizeSmall` |
| `$font-radio_buttonRadio_middle-default-size: $font-size-small` | `fontRadioButtonRadioMiddleDefaultSize` | `theme.typography.fontSizeSmall` |
| `$font-radio_buttonRadio-default-fontWeight: $font-weight-bold` | `fontRadioButtonRadioDefaultFontWeight` | `theme.typography.fontWeightBold` |
| `$font-radio_buttonRadio-hover-fontWeight: $font-weight-bold` | `fontRadioButtonRadioHoverFontWeight` | `theme.typography.fontWeightBold` |
| `$font-radio_buttonRadio-checked-fontWeight: $font-weight-bold` | `fontRadioButtonRadioCheckedFontWeight` | `theme.typography.fontWeightBold` |
| `$font-radio_buttonRadioGroup_small-lineHeight: 16px` | `fontRadioButtonRadioGroupSmallLineHeight` | `16` |
| `$font-radio_buttonRadioGroup_middle-lineHeight: 16px` | `fontRadioButtonRadioGroupMiddleLineHeight` | `16` |
| `$font-radio_buttonRadioGroup_large-lineHeight: 20px` | `fontRadioButtonRadioGroupLargeLineHeight` | `20` |
| `$font-radio_cardRadioGroup_addon-size: $font-size-regular` | `fontRadioCardRadioGroupAddonSize` | `theme.typography.fontSizeRegular` |
| `$font-radio_cardRadioGroup_addon-fontWeight: $font-weight-bold` | `fontRadioCardRadioGroupAddonFontWeight` | `theme.typography.fontWeightBold` |
| `$font-radio_cardRadioGroup_addon-lineHeight: 20px` | `fontRadioCardRadioGroupAddonLineHeight` | `20` |
| `$font-radio_cardRadioGroup_extra-size: $font-size-regular` | `fontRadioCardRadioGroupExtraSize` | `theme.typography.fontSizeRegular` |
| `$font-radio_cardRadioGroup_extra-fontWeight: normal` | `fontRadioCardRadioGroupExtraFontWeight` | `theme.typography.fontWeightRegular` |
| `$font-radio_cardRadioGroup_extra-lineHeight: 20px` | `fontRadioCardRadioGroupExtraLineHeight` | `20` |
| `$transition_duration-radio-bg: var(--semi-transition_duration-none)` | `transitionDurationRadioBg` | `Duration.zero` |
| `$transition_function-radio-bg: var(--semi-transition_function-easeIn)` | `transitionFunctionRadioBg` | `Curves.easeIn` |
| `$transition_delay-radio-bg: var(--semi-transition_delay-none)` | `transitionDelayRadioBg` | `Duration.zero` |
| `$transition_duration-radio-border: var(--semi-transition_duration-none)` | `transitionDurationRadioBorder` | `Duration.zero` |
| `$transition_function-radio-border: var(--semi-transition_function-easeIn)` | `transitionFunctionRadioBorder` | `Curves.easeIn` |
| `$transition_delay-radio-border: var(--semi-transition_delay-none)` | `transitionDelayRadioBorder` | `Duration.zero` |
| `$transform_scale-radio: var(--semi-transform_scale-none)` | `_RadioMetrics.transformScaleRadio`（INTERNAL） | `1`（scale(1,1) 恒等；上游未消费） |

### B. widget 内部常量（INTERNAL/HARDCODES）

| 常量（`_RadioMetrics`） | 上游出处 / 结构 | 值或处理 |
|---|---|---|
| `transformScaleRadio`（INTERNAL） | animation.scss `$transform_scale-radio: var(--semi-transform_scale-none)` | `1`（scale(1,1) 恒等，不加变换） |
| `innerMarginTop` | radio.scss `.semi-radio-inner` `margin-top: 2px;` | 2（由 20px 槽内居中 16px 圆圈等效复刻） |
| `disabledInnerOpacity` | radio.scss `&-disabled .inner-display` `opacity: 0.75;` | 0.75 |
| `focusRingOutline` | radio.scss `.semi-radio-focus` `outline: $width-radio-outline solid $color-radio_primary-outline-focus` | 结构注释，环由 BoxShadow spreadRadius=widthRadioOutline 复刻 |
| `focusRingBorder` | radio.scss `.semi-radio-focus-border` `border: solid $width-radio_hover-border $color-radio_default-border-hover` | 结构注释，聚焦未选中描边 |
| `innerDotIconFill` | radio.scss `.inner-display .semi-icon` `font-size: 14px`（svg 100% 填满） | 14（点图标 customSize=widthRadioInner 填满圆圈盒） |
| `hiddenInner` | radio.scss `.inner-buttonRadio, .inner-pureCardRadio` `opacity: 0;` | button/pureCard 直接不渲染圆圈 |
| `circleRadius` | radio.scss `.inner-display` `border-radius: $width-radio_inner` | 直径/2 正圆（非 radius token） |
| `buttonAddonTextAlign` | radio.scss `.addon-buttonRadio` `text-align: center` | 按钮标签居中 |

## 差异清单

- **enum normal=上游 `default`**（default 是 Dart 保留字）；**SemiRadioButtonSize.middle 命名照抄**上游 `BUTTON_SIZE: ['middle','small','large']`（非 normal）。
- **checked/组 value 非空即受控**（SemiTag.visible 惯例）；释放控制保留最后受控值（checkbox :141 同款），与上游 `componentDidUpdate` 重置 false / 组 undefined 不同。受控只发事件，不受 preventDefault 影响。
- **事件对象摊平 target{checked, value}**；上游 target 其余键/nativeEvent/name/id/prefixCls/aria-* 不移植。preventDefault() 取消非受控落地（standalone 切换或 Group value 变更；组通知先于个体回调发生，无法取消）；stopPropagation() 断开后续链（组回调可阻止个体回调——上游组先于个体，与 checkbox 的个体先于组、可阻止组通知相反）。
- **归属判定 value 非空**：上游 `'value' in props`，此处 value 非空才入组；name/addonId/extraId/uuid、ref focus()/blur()、preventScroll 不移植（与 SemiCheckbox 同取舍）。aria-*、displayMode 不移植。
- **组内重复点已选中项完全静默**（不通知组与个体）：上游原生 radio 点击已选中项无 change 事件；独立 Radio 无此限制（checkbox 同款切换，可再次点击取消选中——上游原生 radio 语义不可取消，取消语义请用 mode: advanced）。
- **组内键盘 roving 自实现**（上游依赖原生 radio 的箭头/单 Tab 语义）：skipTraversal 实现单一 Tab 停靠点，canRequestFocus 保持 `!disabled` 以支持鼠标/程序化聚焦；箭头移动并选中、Space 选中、Enter 不拦截。
- **NaN 特判不移植**（radioGroupComponentDidUpdate 的 NaN 防环）：严格 `==` 天然 `NaN != NaN`，每次重建视为变化，无死循环。
- **动效 none**：transition_duration/delay 均 none、选中瞬时不加动画（无隐式动画/缩放/淡入），6 个 motion 字段仅作为主题字段存在；transform_scale 归 INTERNAL（scale(1,1) 无变换）。
- **白字面量**：`rgba(var(--semi-white), 1)` 与 `var(--semi-color-white)` 按计划解析为 `const Color(0xffffffff)`（checkbox 的 `var(--semi-color-white)` 走 `theme.colors.colorWhite`，dark 主题下二者不同）。
- **button 组项间距**照抄 radio.scss 消费位置：项 padding 取 `spacing-radio_buttonRadioGroup_*`（small 的 paddingX 字段在 CSS 中位于垂直位、paddingY 字段位于水平位——上游命名与位置互换，按消费位置取值），`:not(:last-child)` 的 `padding-right: $spacing-radio_buttonRadioGroup-paddingRight`(0) 逐项复刻；标签 padding 取 `spacing-radio_addon_buttonRadio_*`（small X=16/Y=2、middle X=16/Y=4、large X=24/Y=6，CSS 简写为 Y X 顺序）。组容器 bg buttonRadioBgDefault + 圆角 radiusRadioButtonRadio。
- **card 圆圈选中描边**在 card 形态走 cardRadioGroup_checked_border-* / checked_disabled-border-* 系列字段（与通用 checked-border-* 同值），纯普通形态走通用系列；禁用态 hover 字段（disabled-bg-hover、checked_disabled-border-hover 等）在 hover 被 disabled 门控后不可达，仅入主题。
- **文字大小**取自 `@include font-size-regular`（hardcode，resolve 到 typography.fontSizeRegular）；普通型行高按 heightRadioInnerMin(20) 槽复刻。
- isEqual 比较为严格 `==`（单值；上游 `lastValue !== value` 同为严格比较）。

```dart
SemiRadioGroup(
  value: selected, // Object? 非空即受控
  onChanged: (e) => setState(() => selected = e.value), // advanced 取消时为 null
  options: const [
    SemiRadioOption(label: 'A', value: 'a'),
    SemiRadioOption(label: 'B', value: 'b', extra: 'bee', disabled: true),
  ],
);
// children 模式：组回调先于个体回调；stopPropagation 断开个体回调
SemiRadioGroup(
  type: SemiRadioType.card,
  direction: SemiRadioDirection.vertical,
  onChanged: (e) => print(e.value),
  children: [
    SemiRadio('A', value: 'a', onChanged: (e) {
      if (someVeto) e.preventDefault(); // 取消非受控落地
    }),
    SemiRadio('solo'), // 无 value：独立，checkbox 同款切换
  ],
);
```
