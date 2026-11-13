# SemiSelect

非 Material 选择器（Select）。单选：点项选中并收起面板，触发框回填 `renderSelectedItem(option) ?? label`；value 不在选项列表时显示 `{value, label: value.toString()}` 占位项（不入列表、可被清除）。多选：toggle 加/减、面板不超关、tags 为可关 SemiTag（disabled 不可关），`maxTagCount` 折叠为前 N 个 + 灰 "+M" tag。搜索：`filter: true` 对 label 与组 label 双双小写 includes（组命中 → 组内全显）、`filter: fn` 自定义谓词、`remote` 只发 onSearch 不本地滤；选项文本用 SemiHighlight 高亮关键词（keyword 色/600 字重）。`allowCreate` 在无精确 label 匹配时于列表末追加"创建 + 输入"行。触发框三档高 24/32/40、圆角 3，bg/border 按 default/hover/active/focus + warning/danger 八态 + disabled + borderless 状态矩阵渲染；面板为 Popover 面（bg-3 + 1px 边框 + radius-medium + shadow-elevated），`dropdownMatchSelectWidth` 时 minWidth = 触发框实测宽，列表 maxHeight 默认 270。

## API

`SemiSelect({key, value, defaultValue, multiple, max, allowCreate, options, groups, filter, remote, autoClearSearchValue, searchPosition, searchPlaceholder, placeholder, size, disabled, showClear, showArrow, clearIcon, arrowIcon, borderless, validateStatus, prefix, insetLabel, suffix, renderSelectedItem, renderOptionItem, renderCreateItem, maxTagCount, showRestTagsPopover, restTagsPopoverPosition, expandRestTagsOnClick, loading, emptyContent, maxHeight, dropdownMatchSelectWidth, position, defaultOpen, clickToHide, defaultActiveFirstOption, outerTopSlot, innerTopSlot, outerBottomSlot, innerBottomSlot, onChanged, onSelect, onDeselect, onSearch, onDropdownVisibleChange, onClear, onExceed, onCreate, onFocusChange, onBlur, autofocus, controller})`。

value/defaultValue 承载选择本身：单选 `Object?`、多选 `List<Object>`（`multiple: true`），**非空即受控**（SemiInput 惯例）：渲染跟随 value，交互只发回调；释放控制保留最后值。onChanged: `ValueChanged<Object?>?`——单选发选中值（清空 null）、多选发 `List<Object>`，**diff 门控**（同值不触发；单选比对 value+label，多选比对值列表）。onSelect/onDeselect: `void Function(Object value, SemiSelectOption option)?`（onChanged 之前派发）。onSearch: `ValueChanged<String>?`（每次输入与搜索词清空时发 `''`）。onExceed/onCreate: `ValueChanged<SemiSelectOption>?`。onClear: `VoidCallback?`（清除按钮清空后）。

`SemiSelectOption{value, label, disabled, showTick}`：value 是选中键（差异：上游以 label 为键，见差异清单）；label 为 `String? | Widget?`，null 回落 `value.toString()`；showTick 控制选中对勾槽（默认 true）。`SemiSelectGroup{label, options}`：label 为 `String? | Widget?`，String 时参与默认过滤。

`SemiSelectController{open, close, focus, clearInput, selectAll, deselectAll, search(String)}`：attach 先例同 SemiPinCodeController；focus 只聚焦不改面板可见性（差异：上游 ref.focus() 会开面板）；selectAll 仅多选生效（含 disabled 项，上游同）；deselectAll 清空全部选择。

`renderSelectedItem` 双签名（`Object?`）：单选 `Widget Function(SemiSelectOption)`；多选 `Widget Function(SemiSelectOption, {int index, bool disabled, VoidCallback onClose})`。`renderOptionItem`：`Widget Function(SemiSelectOption, {bool selected, bool focused, String inputValue, VoidCallback onHover, VoidCallback onTap})`。`renderCreateItem`：`Widget Function(String inputValue)?`。filter: `bool | bool Function(String, SemiSelectOption)`。searchPosition: trigger（默认）/dropdown。size: small/normal/large（24/32/40）。validateStatus: normal/error/warning（SemiInputStatus）。

## 行为

### 单选

点项 → `onSelect(value, option)` → diff 门控 `onChanged(value)` → **关面板**（收起搜索框、回填选中 label、搜索词清空）。value 不在 options 时显示占位项 `{value, label: value.toString()}`——不入列表、showClear 可清。显示文本 = `renderSelectedItem(option) ?? label`。清除按钮：diff 门控 `onChanged(null)` + `onClear` + 清搜索词。

### 多选

toggle：已选 → `onDeselect` 移除；未选 → `onSelect` 加入。**面板不关**。超 `max` → `onExceed` 拒绝（不加入、不发 onSelect/onChanged）。`autoClearSearchValue`（默认 true）选中后清搜索词恢复全量并聚焦搜索输入。tags = closable SemiTag（SemiTagSize.large、白字透明底；disabled tag 与整体 disabled 不可关）；点 tag 关闭 → `onDeselect` + diff 门控 `onChanged`。Backspace（搜索词为空）删**最后一个** tag（跳过 disabled tag，全 disabled 则不动）。`maxTagCount` 且面板关（或未开 `expandRestTagsOnClick`）→ 一行前 N 个 + 灰 "+M" tag（padding 4/font 12/text-0）；`showRestTagsPopover` → +M hover 用 SemiTooltip（restTagsPopoverPosition）展示余量 tags；`expandRestTagsOnClick` 开面板时展开全部。

### 搜索

`filter: true` → label 与**组 label** 双双小写 includes（组 label 命中 → 组内全显）；`filter: fn` → 自定义谓词 `(inputValue, option)`；`filter: false`（默认）/`remote: true` → 不本地过滤（remote 仍发 onSearch，外部更新 options）。选项文本用 SemiHighlight 高亮关键词（`colorSelectOptionKeywordText` + `fontSelectKeywordFontWeight`，无底色）。`searchPosition: dropdown` → 面板顶部 SemiInput 搜索框（border-bottom 1px、四向 padding、placeholder=searchPlaceholder）；trigger 模式下 filter 开启时点击展开即聚焦搜索输入、单选显示搜索框并把选中文本降为 0.4 透明度叠底（输入非空后隐藏）。单选选中后收起搜索框、回填选中 label；多选 autoClearSearchValue 清词。搜索词变化时若面板未开会开面板（差异，见差异清单）。

### allowCreate

输入非空且**可见项**无精确 label 匹配时在列表末追加"创建"行（默认渲染 `创建` tips + 输入文本；renderCreateItem 自定义），键盘可聚焦、Enter/点击选中 → `onCreate` + `onSelect`/`onChanged`（value=label=输入文本）。开启后**不再响应 options/groups 外部更新**（上游 allowCreate 受控分支不重收集 options 的语义）。

### 分组

options 平铺在前、groups 在后（差异注明）。组头按该组**首个可见项**位置插入（过滤后组头仍跟随可见项）；组头样式 text-2、12px、padding 12/16/4/32（上/右/下/左）、margin-top 4、**非首组** border-top 1px（`colorSelectOptionBorderDefault`）。默认过滤组 label 命中 → 组内全显。

### 键盘

Focus(onKeyEvent:)（loading/disabled 全忽略）。UP/DOWN 在**可见启用**项间环绕 + `Scrollable.ensureVisible(alignment: .5)`（未开则开面板）；hover 即更新焦点项。ENTER：未开→开 / 有焦点项→选中（多选不关；焦点在 disabled 项上不动）/ 无焦点→关；搜索输入聚焦时走 SemiInput onEnterPress 通道（autocomplete 先例，不双发）。ESC 关（保持 trigger 焦点）。BACKSPACE 多选删末 tag（跳过 disabled）。Tab 关面板但不消费（常规遍历；上游 slot 焦点循环链简化）。无 Home/End/typeahead。

### 面板开合

点 trigger（disabled 忽略；clickToHide=true 时已开点击关；否则聚焦搜索输入/trigger）；点外部关（Tooltip barrier，不回焦）；open 时 focusIndex = defaultActiveFirstOption ? 0 : -1 并滚动到首个选中项居中；onDropdownVisibleChange 通知。clear 按钮、tag 关闭、搜索输入等交互子件赢得手势竞技场，不触发开合（上游 stopPropagation 对应物）。

### 受控

value 非空即受控只回调不落地；onChanged 有 **diff 门控**（同值不触发）；didUpdateWidget 释放控制保留最后值（惯例）；受控 value 变化同步 selections（含占位项）。options/groups 更新（allowCreate 关闭时）重收集并按值重解析选择（新匹配项顶替占位项）。

### 几何

trigger 高 24/32/40（多选 min-height、随 tags 增高）、圆角 3；bg/border 状态色（bg-default fill-0 → hover fill-1 → active fill-2 → focus fill-0；focus 边框 focus-border；warning/danger 八态；disabled disabled-fill + 透明描边；borderless 静息无边框无底）。arrow 槽 32 宽（showArrow=false 时 12 空位）、clear 槽 32；prefix/suffix 文本 margin 12/0 + 600 字重、图标 margin 8/0；selection 左边距 12（有 prefix/insetLabel 时 0）、多选 selection 左边距 4、空回填 8；option padding 12/12/8/8、radius 0、hover fill-0、active fill-1、选中 bold + tick（text-2、12px、marginRight 8，未选中 tick 透明）、disabled 文本 disabled-text。列表 padding 4/0/4/0，maxHeight 默认 270。RTL 全程 EdgeInsetsDirectional/AlignmentDirectional。

## 主题（115 对账）

来源 packages/semi-foundation/select/variables.scss（104 声明）与 animation.scss（11 声明），0 同名重复。对账 **115 = 104 FIELDS + 9 MOTION + 2 INTERNAL**（`$transform_scale-select`、`$transform_rotate-select-arrow` 见 `_SelectMetrics`）。104 FIELDS 含 2 条死变量（标注「（上游未消费）」）：`$width-select_icon_right`、`$color-select_input_disabled-border`。全局与语义 token 引用在 resolve 时读取当前主题；解析列即 `SemiSelectThemeData.resolve` 的默认表达式。字号走 typography mixin（fontSizeRegular 14 / fontSizeSmall 12 / header-6 16，另列 `_SelectMetrics`）。

### A. Sass 声明映射（104 FIELDS + 9 MOTION + 2 INTERNAL = 115）

| Sass 声明（默认值） | 去向 | 解析 / 说明 |
|---|---|---|
| `$color-select-bg-default: var(--semi-color-fill-0)` | `colorSelectBgDefault` | `theme.colors.colorFill0` |
| `$color-select-bg-hover: var(--semi-color-fill-1)` | `colorSelectBgHover` | `theme.colors.colorFill1` |
| `$color-select-bg-active: var(--semi-color-fill-2)` | `colorSelectBgActive` | `theme.colors.colorFill2` |
| `$color-select-bg-focus: var(--semi-color-fill-0)` | `colorSelectBgFocus` | `theme.colors.colorFill0` |
| `$color-select-border-default: transparent` | `colorSelectBorderDefault` | `const Color(0x00000000)` |
| `$color-select-border-hover: $color-select-border-default` | `colorSelectBorderHover` | `const Color(0x00000000)` |
| `$color-select-border-active: var(--semi-color-focus-border)` | `colorSelectBorderActive` | `theme.colors.colorFocusBorder` |
| `$color-select-border-focus: $color-select-border-active` | `colorSelectBorderFocus` | `theme.colors.colorFocusBorder` |
| `$color-select_dropdown_input-border: $color-select-border-default` | `colorSelectDropdownInputBorder` | `const Color(0x00000000)` |
| `$color-select_warning-bg-default: var(--semi-color-warning-light-default)` | `colorSelectWarningBgDefault` | `theme.colors.colorWarningLightDefault` |
| `$color-select_warning-border-default: var(--semi-color-warning-light-default)` | `colorSelectWarningBorderDefault` | `theme.colors.colorWarningLightDefault` |
| `$color-select_warning-bg-hover: var(--semi-color-warning-light-hover)` | `colorSelectWarningBgHover` | `theme.colors.colorWarningLightHover` |
| `$color-select_warning-border-hover: var(--semi-color-warning-light-hover)` | `colorSelectWarningBorderHover` | `theme.colors.colorWarningLightHover` |
| `$color-select_warning-bg-focus: var(--semi-color-warning-light-default)` | `colorSelectWarningBgFocus` | `theme.colors.colorWarningLightDefault` |
| `$color-select_warning-border-focus: var(--semi-color-warning)` | `colorSelectWarningBorderFocus` | `theme.colors.colorWarning` |
| `$color-select_warning-bg-active: var(--semi-color-warning-light-active)` | `colorSelectWarningBgActive` | `theme.colors.colorWarningLightActive` |
| `$color-select_warning-border-active: var(--semi-color-warning-light-active)` | `colorSelectWarningBorderActive` | `theme.colors.colorWarningLightActive` |
| `$color-select_danger-bg-default: var(--semi-color-danger-light-default)` | `colorSelectDangerBgDefault` | `theme.colors.colorDangerLightDefault` |
| `$color-select_danger-border-default: var(--semi-color-danger-light-default)` | `colorSelectDangerBorderDefault` | `theme.colors.colorDangerLightDefault` |
| `$color-select_danger-bg-hover: var(--semi-color-danger-light-hover)` | `colorSelectDangerBgHover` | `theme.colors.colorDangerLightHover` |
| `$color-select_danger-border-hover: var(--semi-color-danger-light-hover)` | `colorSelectDangerBorderHover` | `theme.colors.colorDangerLightHover` |
| `$color-select_danger-bg-focus: var(--semi-color-danger-light-default)` | `colorSelectDangerBgFocus` | `theme.colors.colorDangerLightDefault` |
| `$color-select_danger-border-focus: var(--semi-color-danger)` | `colorSelectDangerBorderFocus` | `theme.colors.colorDanger` |
| `$color-select_danger-bg-active: var(--semi-color-danger-light-active)` | `colorSelectDangerBgActive` | `theme.colors.colorDangerLightActive` |
| `$color-select_danger-border-active: var(--semi-color-danger-light-active)` | `colorSelectDangerBorderActive` | `theme.colors.colorDangerLightActive` |
| `$color-select_default-border-focus: var(--semi-color-focus-border)` | `colorSelectDefaultBorderFocus` | `theme.colors.colorFocusBorder` |
| `$color-select_main-text-default: var(--semi-color-text-0)` | `colorSelectMainTextDefault` | `theme.colors.colorText0` |
| `$color-select-icon-default: var(--semi-color-text-2)` | `colorSelectIconDefault` | `theme.colors.colorText2` |
| `$color-select_clearBtn-text-default: var(--semi-color-text-2)` | `colorSelectClearBtnTextDefault` | `theme.colors.colorText2` |
| `$color-select_clearBtn-text-hover: var(--semi-color-primary)` | `colorSelectClearBtnTextHover` | `theme.colors.colorPrimary` |
| `$color-select_input_disabled-bg: var(--semi-color-disabled-fill)` | `colorSelectInputDisabledBg` | `theme.colors.colorDisabledFill` |
| `$color-select_input_disabled-border: var(--semi-color-border)` | `colorSelectInputDisabledBorder` | `theme.colors.colorBorder（上游未消费）` |
| `$color-select_input_disabled-border-focus: transparent` | `colorSelectInputDisabledBorderFocus` | `const Color(0x00000000)` |
| `$color-select_input_disabled-text: var(--semi-color-disabled-text)` | `colorSelectInputDisabledText` | `theme.colors.colorDisabledText` |
| `$color-select_input_disabled-bg-hover: var(--semi-color-disabled-fill)` | `colorSelectInputDisabledBgHover` | `theme.colors.colorDisabledFill` |
| `$color-select_input_disabled-bg-focus: var(--semi-color-disabled-fill)` | `colorSelectInputDisabledBgFocus` | `theme.colors.colorDisabledFill` |
| `$color-select_input_placeholder-text: var(--semi-color-text-2)` | `colorSelectInputPlaceholderText` | `theme.colors.colorText2` |
| `$color-select_option_main-text: var(--semi-color-text-0)` | `colorSelectOptionMainText` | `theme.colors.colorText0` |
| `$color-select_option_keyword-text: var(--semi-color-primary)` | `colorSelectOptionKeywordText` | `theme.colors.colorPrimary` |
| `$color-select_option-icon-default: transparent` | `colorSelectOptionIconDefault` | `const Color(0x00000000)` |
| `$color-select_option-bg-hover: var(--semi-color-fill-0)` | `colorSelectOptionBgHover` | `theme.colors.colorFill0` |
| `$color-select_option-bg-active: var(--semi-color-fill-1)` | `colorSelectOptionBgActive` | `theme.colors.colorFill1` |
| `$color-select_option_disabled-text: var(--semi-color-disabled-text)` | `colorSelectOptionDisabledText` | `theme.colors.colorDisabledText` |
| `$color-select_option-icon-active: var(--semi-color-text-2)` | `colorSelectOptionIconActive` | `theme.colors.colorText2` |
| `$color-select_option-border-default: var(--semi-color-border)` | `colorSelectOptionBorderDefault` | `theme.colors.colorBorder` |
| `$color-select-option-bg-selected: transparent` | `colorSelectOptionBgSelected` | `const Color(0x00000000)` |
| `$color-select_create_tips-text: var(--semi-color-text-2)` | `colorSelectCreateTipsText` | `theme.colors.colorText2` |
| `$color-select_group-text: var(--semi-color-text-2)` | `colorSelectGroupText` | `theme.colors.colorText2` |
| `$color-select_prefix_suffix_text-default: var(--semi-color-text-2)` | `colorSelectPrefixSuffixTextDefault` | `theme.colors.colorText2` |
| `$width-select_icon_right: ($width-icon-medium + $spacing-tight * 2)` | `widthSelectIconRight` | `32（上游未消费）` |
| `$height-select_large: $height-control-large` | `heightSelectLarge` | `40` |
| `$height-select_small: $height-control-small` | `heightSelectSmall` | `24` |
| `$height-select_default: $height-control-default` | `heightSelectDefault` | `32` |
| `$width-select_option_tick: $width-icon-small` | `widthSelectOptionTick` | `12` |
| `$width-select-border: 1px` | `widthSelectBorder` | `1` |
| `$width-select_arrow: 32px` | `widthSelectArrow` | `32` |
| `$width-select_arrow_empty: 12px` | `widthSelectArrowEmpty` | `12` |
| `$width-select_clear-icon: 32px` | `widthSelectClearIcon` | `32` |
| `$width-select_group_top-border: $border-thickness-control` | `widthSelectGroupTopBorder` | `1` |
| `$height-select_multiple_input_small: 20px` | `heightSelectMultipleInputSmall` | `20` |
| `$height-select_multiple_input_default: 24px` | `heightSelectMultipleInputDefault` | `24` |
| `$height-select_multiple_input_large: 24px` | `heightSelectMultipleInputLarge` | `24` |
| `$width-select-border-hover: $width-select-border` | `widthSelectBorderHover` | `1` |
| `$width-select-border-focus: $width-select-border-hover` | `widthSelectBorderFocus` | `1` |
| `$width-select-border-active: $width-select-border-focus` | `widthSelectBorderActive` | `1` |
| `$spacing-select_option_tick-marginRight: $spacing-tight` | `spacingSelectOptionTickMarginRight` | `8` |
| `$spacing-select_prefix_suffix_text-marginX: $spacing-base-tight` | `spacingSelectPrefixSuffixTextMarginX` | `12` |
| `$spacing-select_prefix_suffix_text-marginY: 0px` | `spacingSelectPrefixSuffixTextMarginY` | `0` |
| `$spacing-select_prefix_suffix_icon-marginX: $spacing-tight` | `spacingSelectPrefixSuffixIconMarginX` | `8` |
| `$spacing-select_prefix_suffix_icon-marginY: 0px` | `spacingSelectPrefixSuffixIconMarginY` | `0` |
| `$spacing-select_create_tips-marginRight: $spacing-extra-tight` | `spacingSelectCreateTipsMarginRight` | `4` |
| `$spacing-select_group-marginTop: $spacing-extra-tight` | `spacingSelectGroupMarginTop` | `4` |
| `$spacing-select_group-paddingTop: $spacing-base-tight` | `spacingSelectGroupPaddingTop` | `12` |
| `$spacing-select_group-paddingBottom: $spacing-extra-tight` | `spacingSelectGroupPaddingBottom` | `4` |
| `$spacing-select_group-paddingLeft: $spacing-base-tight + $width-select_option_tick + $spacing-select_option_tick-marginRight` | `spacingSelectGroupPaddingLeft` | `32` |
| `$spacing-select_group-paddingRight: $spacing-base` | `spacingSelectGroupPaddingRight` | `16` |
| `$spacing-select_loading_wrapper-paddingLeft: $spacing-base` | `spacingSelectLoadingWrapperPaddingLeft` | `16` |
| `$spacing-select_loading_wrapper-paddingRight: $spacing-base` | `spacingSelectLoadingWrapperPaddingRight` | `16` |
| `$spacing-select_loading_wrapper-paddingTop: $spacing-tight` | `spacingSelectLoadingWrapperPaddingTop` | `8` |
| `$spacing-select_loading_wrapper-paddingBottom: $spacing-tight` | `spacingSelectLoadingWrapperPaddingBottom` | `8` |
| `$spacing-select_multiple_content_wrapper_empty-marginLeft: $spacing-tight` | `spacingSelectMultipleContentWrapperEmptyMarginLeft` | `8` |
| `$spacing-select_multiple_selection-marginLeft: $spacing-extra-tight` | `spacingSelectMultipleSelectionMarginLeft` | `4` |
| `$spacing-select_option-paddingLeft: $spacing-base-tight` | `spacingSelectOptionPaddingLeft` | `12` |
| `$spacing-select_option-paddingRight: $spacing-base-tight` | `spacingSelectOptionPaddingRight` | `12` |
| `$spacing-select_option-paddingTop: $spacing-tight` | `spacingSelectOptionPaddingTop` | `8` |
| `$spacing-select_option-paddingBottom: $spacing-tight` | `spacingSelectOptionPaddingBottom` | `8` |
| `$spacing-select_tag-marginTop: $spacing-super-tight - 1px` | `spacingSelectTagMarginTop` | `1` |
| `$spacing-select_tag-marginRight: $spacing-extra-tight` | `spacingSelectTagMarginRight` | `4` |
| `$spacing-select_tag-marginBottom: $spacing-super-tight - 1px` | `spacingSelectTagMarginBottom` | `1` |
| `$spacing-select_selection-marginLeft: $spacing-base-tight` | `spacingSelectSelectionMarginLeft` | `12` |
| `$spacing-select_option_list-paddingTop: $spacing-extra-tight` | `spacingSelectOptionListPaddingTop` | `4` |
| `$spacing-select_option_list-paddingRight: 0px` | `spacingSelectOptionListPaddingRight` | `0` |
| `$spacing-select_option_list-paddingBottom: $spacing-extra-tight` | `spacingSelectOptionListPaddingBottom` | `4` |
| `$spacing-select_option_list-paddingLeft: 0px` | `spacingSelectOptionListPaddingLeft` | `0` |
| `$spacing-select_dropdown_input_paddingTop: 8px` | `spacingSelectDropdownInputPaddingTop` | `8` |
| `$spacing-select_dropdown_input_paddingBottom: 8px` | `spacingSelectDropdownInputPaddingBottom` | `8` |
| `$spacing-select_dropdown_input_paddingRight: 12px` | `spacingSelectDropdownInputPaddingRight` | `12` |
| `$spacing-select_dropdown_input_paddingLeft: 12px` | `spacingSelectDropdownInputPaddingLeft` | `12` |
| `$radius-select: var(--semi-border-radius-small)` | `radiusSelect` | `theme.radius.borderRadiusSmall.value` |
| `$radius-select_option: 0px` | `radiusSelectOption` | `0` |
| `$font-select-fontWeight: $font-weight-regular` | `fontSelectFontWeight` | `theme.typography.fontWeightRegular` |
| `$font-select_keyword-fontWeight: 600` | `fontSelectKeywordFontWeight` | `FontWeight.w600` |
| `$font-select_prefix_suffix-fontWeight: $font-weight-bold` | `fontSelectPrefixSuffixFontWeight` | `theme.typography.fontWeightBold` |
| `$opacity-select_selection_text_inactive: 0.4` | `opacitySelectSelectionTextInactive` | `0.4` |
| `$transition_duration-select-bg: var(--semi-transition_duration-none)` | `transitionDurationSelectBg` | `Duration.zero` |
| `$transition_function-select-bg: var(--semi-transition_function-easeIn)` | `transitionFunctionSelectBg` | `Curves.easeIn` |
| `$transition_delay-select-bg: var(--semi-transition_delay-none)` | `transitionDelaySelectBg` | `Duration.zero` |
| `$transition_duration-select-border: var(--semi-transition_duration-none)` | `transitionDurationSelectBorder` | `Duration.zero` |
| `$transition_function-select-border: var(--semi-transition_function-easeIn)` | `transitionFunctionSelectBorder` | `Curves.easeIn` |
| `$transition_delay-select-border: var(--semi-transition_delay-none)` | `transitionDelaySelectBorder` | `Duration.zero` |
| `$transition_duration-select_option-bg: var(--semi-transition_duration-none)` | `transitionDurationSelectOptionBg` | `Duration.zero` |
| `$transition_function-select_option-bg: var(--semi-transition_function-easeIn)` | `transitionFunctionSelectOptionBg` | `Curves.easeIn` |
| `$transition_delay-select_option-bg: var(--semi-transition_delay-none)` | `transitionDelaySelectOptionBg` | `Duration.zero` |
| `$transform_scale-select: var(--semi-transform_scale-none)` | `_SelectMetrics.transformScaleSelect`（INTERNAL） | `1`（scale(1,1) 恒等，不加变换） |
| `$transform_rotate-select-arrow: var(--semi-transform-rotate-none)` | `_SelectMetrics.transformRotateSelectArrow`（INTERNAL） | `0`（rotate(0) 恒等，箭头不旋转） |

### B. widget 内部常量（INTERNAL/HARDCODES）

| 常量（`_SelectMetrics`） | 上游出处 / 结构 | 值或处理 |
|---|---|---|
| `transformScaleSelect`（INTERNAL） | animation.scss `$transform_scale-select: var(--semi-transform_scale-none)` | `1`（scale(1,1) 恒等，不加变换） |
| `transformRotateSelectArrow`（INTERNAL） | animation.scss `$transform_rotate-select-arrow: var(--semi-transform-rotate-none)` | `0`（rotate(0) 恒等，箭头不旋转） |
| `triggerMaxHeight` | select.scss `&` `max-height: 300px`（触发框滚动区） | 300（触发框内容超高滚动；多选增高时不设上限的差异见差异清单） |
| `loadingWrapperHeight` | select.scss `&-loading-wrapper` `height: 20px`（注释明示不建 token） | 20 |
| `nTagPadding` | select.scss `&-N` `padding: 4px` | 4 |
| `nTagFontSize` | select.scss `&-N` `font-size: 12px` | 12 |
| `overflowMinWidth` | select.scss `.overflowList-overflow` `min-width: 50px` | 50（宽度溢出列表未移植——只做计数折叠） |
| `dropdownSearchBorderWidth` | select.scss `&-dropdown-search-wrapper` `border-bottom: 1px solid` | 1（颜色走 `colorSelectDropdownInputBorder`） |
| `listHeight` | constants.ts `numbers.LIST_HEIGHT: 270` | 270（`maxHeight` 默认） |
| `selectionTextInactiveOpacity` | select.scss `&-selection-text-inactive` `opacity: $opacity-select_selection_text_inactive` | 0.4（字段值同 `opacitySelectSelectionTextInactive`；结构注释 `selectionTextInactiveRule`） |
| `clearIconSize` | select.scss `&-clear` 图标 glyph（icon font 12） | 12 |
| 箭头图标尺寸 | `&-arrow` 内 `<IconChevronDown>` 为 `1em`（= trigger 字号：14 regular/small、16 large） | 跟随 fontSize，不建常量 |
| `groupFontSize` | select.scss `&-group` `@include font-size-small` | 12（resolve 到 typography.fontSizeSmall） |
| `selectionLargeFontSize` | select.scss `&-large .&-selection` `@include font-size-header-6` | 16（`$font-size-header-6`） |
| `nTagTextColor` | select.scss `&-N` `color: var(--semi-color-text-0)` | resolve 到 `theme.colors.colorText0`（非 select token） |
| `popoverSurfaceBg/Border/Radius` | popover/variables.scss（面板自绘 Popover 面，autocomplete 同款） | colorBg3 / colorBorder / borderRadiusMedium |
| `popoverZIndex` | popover.scss `$z-popover: 1030` | 1030（overlay 插入序定层叠） |
| `shadowElevatedBlur/Drop` | global.scss `@include shadow-elevated` 两层 | `0 0 1px rgba(0,0,0,.3)` + `0 4px 14px rgba(0,0,0,.1)`（浅色字面量） |
| `multipleInputMinWidth` | 上游 JS 按内容实测 input 宽（`width: auto`） | 8（改用小下限，见差异清单） |

## 差异清单

- **选中键 label → value**：上游 `selections` Map 以 `option.label` 为键（同 label 异 value 会互相顶替）；本移植以 `value` 为键（toggle/去重/Backspace 均按 value）。placeholder 项 `{value, label: value.toString()}` 语义同上游 `_notExist`。
- **onChanged 联合承载**：上游 `onChange`（值）+ `onChangeWithObject`（对象）双通道；本移植 `onChanged` 只发值（单选 `Object?`、多选 `List<Object>`），对象经 onSelect/onDeselect 携带，`onChangeWithObject` 不移植。diff 门控在多选同样生效（上游 `_diffSelections` 多选恒真、每次 toggle 都发）。
- **options/groups 数据形态**：上游 JSX children（`<Option>`/`<OptionGroup>`）或 `optionList`；本移植为 `List<SemiSelectOption>` + `List<SemiSelectGroup>`，**options 平铺在前、groups 在后**（上游按 children 顺序交织）。JSX children、`optionList` prop 不移植。
- **单选选中回调顺序**：onSelect → onChanged → 关面板（任务契约序）；上游受控分支在关闭动画回调里才发 onChange。
- **triggerRender/virtualize/ellipsisTrigger/inputProps/onChangeWithObject 不移植**：triggerRender（自定义触发框内容）、虚拟滚动（virtualize）、宽度溢出折叠（ellipsisTrigger/OverflowList，只保留计数折叠 maxTagCount）、inputProps（内嵌 Input 透传）、onChangeWithObject。
- **slot Tab 链简化**：上游 Tab 在 slot/trigger/容器间循环（`getFocusableElements` 链）；本移植 Tab 只关面板并放行常规焦点遍历。
- **aria-\* 不移植**：Semantics 暴露 button/expanded/selected/enabled；上游 aria-labelledby/aria-activedescendant 等不移植。
- **renderSelectedItem isRenderInTag 摊平**：多选自定义 `renderSelectedItem` 的返回值**直接排版**（不包 SemiTag，SemiTag 仅接受 String 文本），onClose 交由自定义内容自行接线；默认（null）走 closable SemiTag。
- **+M 余量弹层**：`showRestTagsPopover` 用 SemiTooltip（hover）列出余量 tags；上游用 Popover + isFullTags 展开态（hover +M 后 TagGroup 转全量），本移植仅弹层展示。
- **内嵌搜索输入宽**：上游按内容实测（JS width auto）；本移植取 `Flexible + minWidth 8`。
- **搜索词驱动开面板**：trigger 模式多选内嵌输入点击时手势竞技场被输入吃掉（上游 click 冒泡开面板），本移植改为输入变化时面板未开则开（autocomplete 同款）。
- **onBlur 语义**：只在真实焦点丢失时触发（focus 节点监听）；上游 clickOutside/Tab 路径的 notifyBlur 摊平到此处，Select 容器内 tag 关闭不触发 blur。
- **controller.focus()** 只聚焦（可聚焦 trigger 或展示搜索框）；上游 ref.focus() 还会开面板。controller.search() 直接改搜索词并过滤。
- **allowCreate 创建行匹配范围**：精确 label 匹配只看**可见**项（上游 `_createOptionByInput` 跳过 `_show: false` 项，同语义）；创建行 value=label=输入文本（上游一致）。
- **无 Home/End/typeahead**（上游同样没有）；键盘不支持 Space 选中（上游 ENTER-only）。
- **动效 none**：bg/border/option-bg 三组 transition 均 none/easeIn/none；6 Duration + 3 Curve 仅作主题字段，无隐式动画（option 行 AnimatedContainer 时长为 Duration.zero）。
- **占位项可清除**：单选占位项参与 showClear/清除回调（上游同）；其 renderSelectedItem 收到的 option 是合成项（label=null → 文本回落 value.toString()）。

```dart
SemiSelect(
  value: selected, // Object? 非空即受控；多选传 List<Object>
  options: const [
    SemiSelectOption(value: 'a', label: 'A'),
    SemiSelectOption(value: 'b', label: 'B', disabled: true),
    SemiSelectOption(value: 'c', label: 'C', showTick: false),
  ],
  groups: const [
    SemiSelectGroup(label: 'G', options: [SemiSelectOption(value: 'g1', label: 'G1')]),
  ],
  filter: true, // 或 (input, option) => option.plainText.contains(input)
  multiple: true,
  max: 5,
  maxTagCount: 2,
  showClear: true,
  onChanged: (v) => setState(() => selected = v), // 单选值 / 多选 List<Object>
  onSelect: (value, option) => print('select $value'),
  onDeselect: (value, option) => print('deselect $value'),
  onSearch: (text) => print('search $text'),
);
// 搜索 + 创建 + 下拉内搜索框
SemiSelect(
  filter: true,
  allowCreate: true,
  searchPosition: SemiSelectSearchPosition.dropdown,
  searchPlaceholder: '搜索',
  onCreate: (option) => print('created ${option.value}'),
  options: const [SemiSelectOption(value: 'x', label: 'X')],
);
// 控制器
final controller = SemiSelectController();
SemiSelect(controller: controller, options: const [...]);
controller.open();
controller.search('x');
controller.deselectAll();
```
