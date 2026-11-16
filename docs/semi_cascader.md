# SemiCascader

级联选择（上游 Semi Cascader 移植）：触发器（cascader.scss）+ 弹层多列菜单（item.tsx；搜索时扁平结果列表）。`treeData` 拍平（`convertDataToEntities`——key = 值路径 `_SEMI_CASCADER_SPLIT_` 拼接、pos = `"0-1-2"` 树位）→ 实体表；单选（`changeOnSelect` 非叶可选、`enableLeafClick`/`clickToSelect` 多选行点击勾选、`separator` 值路径回填、`displayRender`）、多选（`checkRelation: related` 级联 + 半选 / `unRelated` 独立；`autoMergeValue`/`leafOnly` 决定 onChange 载荷；`max` 超限 onExceed）、搜索（`filterTreeNode` bool/函数 + `filterLeafOnly` + `filterSorter` + `filterRender` + `searchPosition: trigger|custom` + `remote`）、异步加载（`loadData` Spin + `onLoad` + `loadedKeys`）、空态、标签关闭、清空、"+N" 折叠（`maxTagCount` + `showRestTagsPopover`）、`borderless` 静默态、`validateStatus` warning/error、尺寸三档、prefix/suffix/insetLabel、`triggerRender` 自定义触发器、`topSlot`/`bottomSlot`、locale zh。主题对账 **115 = 112 FIELDS + 3 MOTION + 0 INTERNAL**（variables.scss 112 声明行 / 112 唯一名——color 51、spacing 35、height 10、width 9、font 5、radius 2；animation.scss 3 transition 声明 = 3 MOTION；`$module: #{$prefix}-cascader` 类名胶水不计）；★**2 死变量**（上游未消费）：`$color-cascader_label-text-default`、`$font-cascader_label-fontWeight` 仅在 variables.scss 自身声明处出现（cascader.scss/rtl.scss 均未消费）——照 select `$color-select_input_disabled-border` 先例保留字段、widget 不消费。

## API

`SemiCascader({treeData: const [], value, defaultValue, multiple: false, checkRelation: SemiCascaderCheckRelation.related, autoMergeValue: true, leafOnly: false, changeOnSelect: false, enableLeafClick: false, clickToSelect: false, max, maxTagCount, showRestTagsPopover: false, restTagsPopoverPosition: SemiTooltipPosition.top, disabled: false, filterTreeNode, filterLeafOnly: true, filterSorter, filterRender, treeNodeFilterProp: 'label', displayProp: 'label', displayRender, separator: ' / ', searchPosition: SemiCascaderSearchPosition.trigger, remote: false, showNext: SemiCascaderShowNext.click, expandIcon, loadData, loadedKeys, onLoad, placeholder, searchPlaceholder, size: SemiInputSize.normal, showClear: false, arrowIcon: <IconChevronDown />, clearIcon, borderless: false, validateStatus: SemiInputStatus.normal, prefix, insetLabel, suffix, triggerRender, topSlot, bottomSlot, emptyContent, dropdownStyle, dropdownMargin, position: SemiTooltipPosition.bottomLeft, autoAdjustOverflow: true, motion: true, mouseEnterDelay, mouseLeaveDelay, zIndex: 1030, defaultOpen: false, onChangeWithObject: false, onChange, onSelect, onSearch, onClear, onExceed, onFocus, onBlur, onVisibleChange, onListScroll, semanticsLabel})`。

treeData `List<SemiCascaderData>`（引用变化触发实体重建——建议 const/稳定引用）。value/defaultValue `Object?`（单选值路径 `List<String>` 或 String 简写；多选 `List<List<String>>`；value 非 null 即受控——交互只回调）。multiple `false`（Checkbox 模式）。checkRelation `related`（| `unRelated`）。autoMergeValue `true`。leafOnly `false`。changeOnSelect `false`（非叶可选中）。enableLeafClick `false`（多选点叶行勾选）。clickToSelect `false`（多选点任意行勾选，优先于 enableLeafClick）。max `int?`（多选数量上限——超限只许减不许增 + onExceed）。maxTagCount `int?`（+N 折叠）。showRestTagsPopover `false`。restTagsPopoverPosition `top`。disabled `false`。filterTreeNode `Object?`（bool 或 `SemiCascaderFilter(input, treeNodeString, data)`；null/false 不渲染搜索框）。filterLeafOnly `true`（搜索只命中叶子）。filterSorter `int Function(List<SemiCascaderData> first, List<SemiCascaderData> second, String inputValue)?`。filterRender `SemiCascaderFilterRender?`（搜索结果行自定义）。treeNodeFilterProp `'label'`（| value）。displayProp `'label'`（| value）。displayRender `String Function(List<SemiCascaderData> path, {int index})?`（★上游返回 ReactNode 的单/多选联合口径拍平为路径数据返回 String，见差异清单）。separator `' / '`。searchPosition `trigger`（| custom——custom 时触发器不渲染搜索框，由 triggerRender 自置）。remote `false`。showNext `click`（| hover）。expandIcon `Widget?`。loadData `Future<void> Function(List<SemiCascaderData> selectOptions)?`。loadedKeys `List<String>?`（非 null 即受控）。onLoad `void Function(Set<String> loadedKeys, SemiCascaderData data)?`。placeholder `String?`。searchPlaceholder `String?`（缺省 placeholder）。size `SemiInputSize`（small/normal/large = 上游 small/default/large——constants.ts:9 `SIZE_SET`）。showClear `false`（hover/展开时清空按钮替换箭头）。arrowIcon `Widget?`（缺省 `<IconChevronDown />`；★显式传 null 不渲染箭头 quirk）。clearIcon `Widget?`（缺省 `<IconClear />`）。borderless `false`。validateStatus `SemiInputStatus.normal`（warning/error = 上游 `VALIDATE_STATUS`）。prefix/insetLabel/suffix `Object?`（String | Widget）。triggerRender `SemiCascaderTriggerRender?`。topSlot/bottomSlot `Widget?`。emptyContent `String|Widget?`（缺省「暂无数据」；★上游 `emptyContent: null` 隐藏空态——传 `const SizedBox.shrink()` 近似）。dropdownStyle `BoxDecoration?`（上游 CSSProperties 拍平）。dropdownMargin `double?`。position `bottomLeft`（上游 `… 'bottomRight' : 'bottomLeft'`）。autoAdjustOverflow `true`。motion `true`。mouseEnterDelay/mouseLeaveDelay `Duration?`。zIndex `1030`（`zIndex: popoverNumbers.DEFAULT_Z_INDEX`）。defaultOpen `false`。onChangeWithObject `false`（载荷为数据对象而非值路径）。onChange `ValueChanged<Object?>?`（单选值路径 `List<String>`；多选 `List<List<String>>`；清空回传 `[]`）。onSelect `ValueChanged<Object?>?`（单选节点 value；多选 value 列表）。onSearch `ValueChanged<String>?`。onClear `VoidCallback?`。onExceed `ValueChanged<List<SemiCascaderData>>?`（★上游回传 Entity[]——拍平为数据列表）。onFocus/onBlur `VoidCallback?`。onVisibleChange `ValueChanged<bool>?`。onListScroll `void Function(int panelIndex, SemiCascaderData? activeNode)?`（★上游首参 DOM 事件不回传）。semanticsLabel `String?`（缺省 `'aria-label': 'Cascader'`）。

## 行为

### 触发器（cascader.scss 状态矩阵）

选择盒：圆角 `radiusCascader`、描边 `widthCascaderBorder`（1px）+ 默认透明色、min-width 80、min-height 32/24/40（small/normal/large）、`font-cascader-fontWeight` 字重。状态：rest fill-0 / hover fill-1（描边 `widthCascaderHoverBorder`）/ pressed fill-2 / focus（`isFocus || open`）fill-0 + `colorFocusBorder` 描边（`-focus:hover` 保持 focus 底色 quirk）。validateStatus warning/error 时底/描边按 default/hover/focus/active 四态换 `$color-cascader_warning-*`/`$color-cascader_danger-*`。disabled：disabled-fill 底（hover 换 disabled-fill hover）、文本/图标/Tag 换 disabled-text、Tag 底 `colorCascaderTagDisabledBgDefault`、`cursor: not-allowed` + `user-select: none`。borderless：非 hover 非 focus → 透明底/描边 + 箭头隐藏（`opacity: 0`）；error/warning 描边恒 `_border-focus` 色。

结构（index.tsx:1050-1060）：`prefix/insetLabel → selection → suffix → clearBtn | arrow`（互斥 32 槽 `widthCascaderIcon`；清空按钮 hover primary-hover / pressed primary-active）。单选回填：displayRender 或值路径 join separator，文本字重 `fontCascaderFontWeight` + 行盒（= 触发器高 / fontSize——CSS line-height 映射）；占位 placeholder 色。多选：白色 Tag（`tag-margin` 简写 Y/Right/Y/Left，small 尺寸 small tag 其余 large），`maxTagCount` 折叠 "+N"（`fontCascaderSelectionNFontSize` + `selection_n` 色/padding/margin；`showRestTagsPopover` 悬停展开）；空时占位。触发器内搜索（`searchPosition: trigger`）：单选 = bare 输入 + 回填浮层（span 三态 hide/inactive；点击聚焦输入）+ 搜索容器（padding 8/12 + border-bottom——★上游 `.popover .search-wrapper` 误嵌套按意图消费）；多选 = 标签 + 内联 bare 输入（`tagInput` min-height 22/30/38、`tagInput-wrapper` marginLeft -4 负值拉回）。触发器内输入剥边框/底色（`colorCascaderInputBorderDefault: none` + `colorCascaderInputBgDefault: transparent` → bare 等效）。

### 打开 / 收起

点击触发器：disabled 拦截；开 → `onVisibleChange(true)` + `onFocus`；已开时可过滤（触发器搜索）不收起，否则收起。单选选中叶子（或 `!filterLeafOnly` 且搜索中）→ 收起 + blur；同键再点直接收起。ESC 收起（不 blur quirk 照抄）。点击外部（tooltip barrier）→ blur + 收起。收起时可过滤单选把选中文案写回输入（`inputValue` 口径照抄）。`defaultOpen` 初始展开。treeData/value 变化 bump `rePosKey` 重定位；空态面板 min-width = 触发器宽（`_setEmptyContentMinWidth`）。

### 选择与标签

单选（foundation.ts:817-875）：非叶且非 changeOnSelect 且非搜索中 → 只激活路径 + `notifyIfLoadData`；否则 `onSelect(value)` + `onChange(值路径)`（已选中再点不发 onChange 只收起）；受控 value 只回调不改态。多选（foundation.ts:877-991）：checkbox / 行点击（clickToSelect、enableLeafClick）→ related 级联勾选（祖先半选，`calcCheckedKeysForChecked/Unchecked` 与 [SemiTree] 同源）/ unRelated 独立；`onChange` 载荷经 `autoMergeValue`（去祖先）/`leafOnly`（只留叶子）规整（none 原样）；`max` 超限只许减不许增（`onExceed`）；勾选后清空搜索输入（★保留 isSearching quirk 照抄）。标签关闭（`handleTagRemoveByKey`，foundation.ts:1170-1180）：disabled 标签不可关；反勾选级联。清空（`handleClear`，foundation.ts:1063-1106）：单选/多选回 `[]` + `onClear`；触发器内搜索有输入时先复位输入（不发 onChange）。

### 过滤与加载

`filterTreeNode` 非空可搜索（`searchPosition: trigger` 触发器内输入 / `custom` triggerRender 自置；面板渲染扁平结果列表）。输入变化（foundation.ts:1051-1061）：本地按 `treeNodeFilterProp` 命中（bool → join('') 包含匹配——★英文逗号不误伤 quirk；函数 → 用户判定 join()）+ `filterLeafOnly` 只留叶子；`remote` 当前 treeData 即结果；`onSearch(input)`。结果行（item.tsx:233-295）：勾选框/占位 + 路径分段高亮（大小写不敏感逐段命中——`-label-highlight` bold + `colorCascaderSelectHighlight`，段间 separator）+ `filterSorter` 排序 + `filterRender` 自定义行。异步加载：展开未加载节点（无 children 且非 isLeaf）触发 `loadData(路径数据)`，行尾 Spin（`widthCascaderOptionIcon`），完成后 `onLoad` 先于内部状态更新（上游 setTimeout 顺序口径）；`loadedKeys` 受控。

### 弹层与行渲染

弹层面板：bg-3 + 1px border + radius-medium + shadow-elevated（select 先例同款；`dropdownStyle` 可整体替换装饰）、选项区高 `heightCascaderOptionList`（180）、列 min-width `widthCascaderOption`（150）+ 分割线（`widthCascaderOptionListBorder` + `colorCascaderOptionListBorderDefault`，首列无线）、列 padding（★`spacing-cacader_option_list-*` 上游拼写 quirk）、`topSlot`/`bottomSlot`（IntrinsicWidth 阻断）。行渲染（item.tsx:324-387）：单选 tick/空占位（`widthCascaderOptionIcon` + `spacingCascaderEmptyIconMarginRight`）或 多选 Checkbox（`spacingCascaderLabelCheckboxMarginRight`）+ label + 右侧展开 `IconChevronRight`/Spin（`spacingCascaderOptionIconMarginLeft`）；行 padding 四向 `option-padding*`；底色 AnimatedContainer（`transition_*-cascader_option-bg`——delay 并入 duration 近似）：hover/pressed/激活路径（`-active` 背景 `colorCascaderOptionBgSelected`）；`-select` 命中文字 bold + `colorCascaderSelectHighlight`；禁用行文字 `colorCascaderOptionDisabledTextDefault` + hover/active 透明底。`showNext: hover` 悬停即展开下级（`handleShowNextByHover`）。空态（item.tsx:389-405）：locale `emptyText: '暂无数据'`（`radiusCascaderOptionEmpty` + `colorCascaderOptionEmptyTextDefault` + padding）。


## 主题（115 对账）

来源 packages/semi-foundation/cascader/variables.scss（112 声明行 / 112 唯一名——color 51、spacing 35、height 10、width 9、font 5、radius 2）+ animation.scss（3 transition 声明 = 3 MOTION，cascader.scss `@import "./animation.scss"`）。对账 **115 = 112 FIELDS + 3 MOTION + 0 INTERNAL**（HARDCODES 另列见 B 表；`$module: #{$prefix}-cascader` 类名胶水不计）。★**2 死变量**（上游未消费，保留字段标注）；其余 110 条被 cascader.scss 消费。全局 token 解析：`var(--semi-color-fill-0/1/2)` → `theme.colors.colorFill0/1/2`、`var(--semi-color-text-0/2)` → `theme.colors.colorText0/2`、`var(--semi-color-primary)` → `theme.colors.colorPrimary`、`var(--semi-color-primary-light-default)` → `theme.colors.colorPrimaryLightDefault`、`var(--semi-color-primary-hover/active)` → `theme.colors.colorPrimaryHover/Active`、`var(--semi-color-focus-border)` → `theme.colors.colorFocusBorder`、`var(--semi-color-disabled-fill/text)` → `theme.colors.colorDisabledFill/Text`、`var(--semi-color-warning(-light-default/hover/active))` → `theme.colors.colorWarning(…)`、`var(--semi-color-danger(-light-default/hover/active))` → `theme.colors.colorDanger(…)`；`transparent`/`none` → `const Color(0x00000000)`（select 先例；`none` 是 CSS border 简写关键字——「不描边」占位）；引用 token：`$border-thickness-control-focus` → 1、`$height-control-small/default/large` → 24/32/40、`$spacing-none/super-tight/extra-tight/tight/base-tight` → 0/2/4/8/12、`$font-size-small` → 12、`$font-weight-regular` → `theme.typography.fontWeightRegular`（= w400）、`$font-weight-bold` → `theme.typography.fontWeightBold`（= w600，生成域 fontWeight resolve 先例 tool/generate_tag.py:31）、`var(--semi-border-radius-small/medium)` → `theme.radius.borderRadiusSmall/Medium.value`（= 3/4）。类型覆盖：**51 Color + 57 double + 4 FontWeight + 2 Duration + 1 Curve**。解析列即 `SemiCascaderThemeData.resolve` 默认表达式。

### A. Sass 声明映射（112 FIELDS + 3 MOTION）

| Sass 声明（默认值） | 去向 | 解析 / 说明 |
|---|---|---|
| `$radius-cascader: var(--semi-border-radius-small)` | `radiusCascader` | `theme.radius.borderRadiusSmall.value`（触发器圆角） |
| `$radius-cascader_option_empty: var(--semi-border-radius-medium)` | `radiusCascaderOptionEmpty` | `theme.radius.borderRadiusMedium.value`（空态圆角） |
| `$color-cascader_default-border-default: transparent` | `colorCascaderDefaultBorderDefault` | `const Color(0x00000000)`（触发器 rest 描边） |
| `$color-cascader_default-border-hover: transparent` | `colorCascaderDefaultBorderHover` | `const Color(0x00000000)`（触发器 hover 描边） |
| `$color-cascader_default-border-focus: var(--semi-color-focus-border)` | `colorCascaderDefaultBorderFocus` | `theme.colors.colorFocusBorder`（触发器 focus 描边） |
| `$color-cascader_default-bg-default: var(--semi-color-fill-0)` | `colorCascaderDefaultBgDefault` | `theme.colors.colorFill0`（触发器 rest/ focus 底色） |
| `$color-cascader_default-bg-hover: var(--semi-color-fill-1)` | `colorCascaderDefaultBgHover` | `theme.colors.colorFill1`（触发器 hover 底色） |
| `$color-cascader_default-bg-active: var(--semi-color-fill-2)` | `colorCascaderDefaultBgActive` | `theme.colors.colorFill2`（触发器按下底色） |
| `$color-cascader_option_list-border-default: var(--semi-color-fill-0)` | `colorCascaderOptionListBorderDefault` | `theme.colors.colorFill0`（选项列分割线色） |
| `$color-cascader_option_main-text-default: var(--semi-color-text-0)` | `colorCascaderOptionMainTextDefault` | `theme.colors.colorText0`（选项文字色） |
| `$color-cascader_option-bg-hover: var(--semi-color-fill-0)` | `colorCascaderOptionBgHover` | `theme.colors.colorFill0`（选项 hover 底色） |
| `$color-cascader_option-bg-active: var(--semi-color-fill-1)` | `colorCascaderOptionBgActive` | `theme.colors.colorFill1`（选项按下底色） |
| `$color-cascader_option-bg-selected: var(--semi-color-primary-light-default)` | `colorCascaderOptionBgSelected` | `theme.colors.colorPrimaryLightDefault`（选项激活路径底色） |
| `$color-cascader_option_disabled-text-default: var(--semi-color-disabled-text)` | `colorCascaderOptionDisabledTextDefault` | `theme.colors.colorDisabledText`（禁用选项文字色） |
| `$color-cascader_option_disabled-bg-hover: transparent` | `colorCascaderOptionDisabledBgHover` | `const Color(0x00000000)`（禁用选项 hover 底色） |
| `$color-cascader_option_disabled-bg-active: transparent` | `colorCascaderOptionDisabledBgActive` | `const Color(0x00000000)`（禁用选项按下底色） |
| `$color-cascader_tag_disabled-bg-default: transparent` | `colorCascaderTagDisabledBgDefault` | `const Color(0x00000000)`（禁用 Tag 底色） |
| `$color-cascader_warning-bg-default: var(--semi-color-warning-light-default)` | `colorCascaderWarningBgDefault` | `theme.colors.colorWarningLightDefault`（warning 底色 rest） |
| `$color-cascader_warning-border-default: var(--semi-color-warning-light-default)` | `colorCascaderWarningBorderDefault` | `theme.colors.colorWarningLightDefault`（warning 描边 rest） |
| `$color-cascader_warning-bg-hover: var(--semi-color-warning-light-hover)` | `colorCascaderWarningBgHover` | `theme.colors.colorWarningLightHover`（warning 底色 hover） |
| `$color-cascader_warning-border-hover: var(--semi-color-warning-light-hover)` | `colorCascaderWarningBorderHover` | `theme.colors.colorWarningLightHover`（warning 描边 hover） |
| `$color-cascader_warning-bg-focus: var(--semi-color-warning-light-default)` | `colorCascaderWarningBgFocus` | `theme.colors.colorWarningLightDefault`（warning 底色 focus） |
| `$color-cascader_warning-border-focus: var(--semi-color-warning)` | `colorCascaderWarningBorderFocus` | `theme.colors.colorWarning`（warning 描边 focus（borderless 恒用）） |
| `$color-cascader_warning-bg-active: var(--semi-color-warning-light-active)` | `colorCascaderWarningBgActive` | `theme.colors.colorWarningLightActive`（warning 底色按下） |
| `$color-cascader_warning-border-active: var(--semi-color-warning-light-active)` | `colorCascaderWarningBorderActive` | `theme.colors.colorWarningLightActive`（warning 描边按下） |
| `$color-cascader_danger-bg-default: var(--semi-color-danger-light-default)` | `colorCascaderDangerBgDefault` | `theme.colors.colorDangerLightDefault`（error 底色 rest） |
| `$color-cascader_danger-border-default: var(--semi-color-danger-light-default)` | `colorCascaderDangerBorderDefault` | `theme.colors.colorDangerLightDefault`（error 描边 rest） |
| `$color-cascader_danger-bg-hover: var(--semi-color-danger-light-hover)` | `colorCascaderDangerBgHover` | `theme.colors.colorDangerLightHover`（error 底色 hover） |
| `$color-cascader_danger-border-hover: var(--semi-color-danger-light-hover)` | `colorCascaderDangerBorderHover` | `theme.colors.colorDangerLightHover`（error 描边 hover） |
| `$color-cascader_danger-bg-focus: var(--semi-color-danger-light-default)` | `colorCascaderDangerBgFocus` | `theme.colors.colorDangerLightDefault`（error 底色 focus） |
| `$color-cascader_danger-border-focus: var(--semi-color-danger)` | `colorCascaderDangerBorderFocus` | `theme.colors.colorDanger`（error 描边 focus（borderless 恒用）） |
| `$color-cascader_danger-bg-active: var(--semi-color-danger-light-active)` | `colorCascaderDangerBgActive` | `theme.colors.colorDangerLightActive`（error 底色按下） |
| `$color-cascader_danger-border-active: var(--semi-color-danger-light-active)` | `colorCascaderDangerBorderActive` | `theme.colors.colorDangerLightActive`（error 描边按下） |
| `$color-cascader_prefix_suffix_text-default: var(--semi-color-text-2)` | `colorCascaderPrefixSuffixTextDefault` | `theme.colors.colorText2`（prefix/suffix/insetLabel 文本色） |
| `$spacing-cascader_selection-paddingLeft: 12px` | `spacingCascaderSelectionPaddingLeft` | `12`（回填区左 padding（default）） |
| `$spacing-cascader_selection-paddingRight: 12px` | `spacingCascaderSelectionPaddingRight` | `12`（回填区右 padding（default）） |
| `$spacing-cascader_small_selection-paddingLeft: 12px` | `spacingCascaderSmallSelectionPaddingLeft` | `12`（回填区左 padding（small）） |
| `$spacing-cascader_small_selection-paddingRight: 12px` | `spacingCascaderSmallSelectionPaddingRight` | `12`（回填区右 padding（small）） |
| `$spacing-cascader_large_selection-paddingLeft: 12px` | `spacingCascaderLargeSelectionPaddingLeft` | `12`（回填区左 padding（large）） |
| `$spacing-cascader_large_selection-paddingRight: 12px` | `spacingCascaderLargeSelectionPaddingRight` | `12`（回填区右 padding（large）） |
| `$spacing-cascader_selection_multiple-paddingLeft: $spacing-extra-tight` | `spacingCascaderSelectionMultiplePaddingLeft` | `4`（多选回填区左 padding（default）） |
| `$spacing-cascader_selection_multiple-paddingRight: $spacing-extra-tight` | `spacingCascaderSelectionMultiplePaddingRight` | `4`（多选回填区右 padding（default）） |
| `$spacing-cascader_small_selection_multiple-paddingLeft: $spacing-extra-tight` | `spacingCascaderSmallSelectionMultiplePaddingLeft` | `4`（多选回填区左 padding（small）） |
| `$spacing-cascader_small_selection_multiple-paddingRight: $spacing-extra-tight` | `spacingCascaderSmallSelectionMultiplePaddingRight` | `4`（多选回填区右 padding（small）） |
| `$spacing-cascader_large_selection_multiple-paddingLeft: $spacing-extra-tight` | `spacingCascaderLargeSelectionMultiplePaddingLeft` | `4`（多选回填区左 padding（large）） |
| `$spacing-cascader_large_selection_multiple-paddingRight: $spacing-extra-tight` | `spacingCascaderLargeSelectionMultiplePaddingRight` | `4`（多选回填区右 padding（large）） |
| `$spacing-cascader_selection_tag-marginLeft: $spacing-none` | `spacingCascaderSelectionTagMarginLeft` | `0`（Tag 左外边距（margin 简写）） |
| `$spacing-cascader_selection_tag-marginRight: $spacing-super-tight` | `spacingCascaderSelectionTagMarginRight` | `2`（Tag 右外边距（margin 简写）） |
| `$spacing-cascader_selection_tag-marginY: 1px` | `spacingCascaderSelectionTagMarginY` | `1`（Tag 垂直外边距 + 输入上下 margin） |
| `$spacing-cascader_selection_tagInput-marginLeft: - $spacing-extra-tight` | `spacingCascaderSelectionTagInputMarginLeft` | `-4`（tagInput-wrapper 左外边距（负值拉回）） |
| `$spacing-cascader_selection_input-marginLeft: $spacing-extra-tight` | `spacingCascaderSelectionInputMarginLeft` | `4`（内联搜索输入左外边距） |
| `$spacing-cascader_selection_n-marginRight: $spacing-extra-tight` | `spacingCascaderSelectionNMarginRight` | `4`（"+N" 右外边距） |
| `$spacing-cascader_option-icon-marginLeft: 8px` | `spacingCascaderOptionIconMarginLeft` | `8`（选项右图标左外边距） |
| `$color-cascader_selection_n-text-default: var(--semi-color-text-0)` | `colorCascaderSelectionNTextDefault` | `theme.colors.colorText0`（"+N" 文字色） |
| `$color-cascader_selection_n-text-disabled: var(--semi-color-disabled-text)` | `colorCascaderSelectionNTextDisabled` | `theme.colors.colorDisabledText`（"+N" 文字色 disabled） |
| `$color-cascader_selection_text_inactive: var(--semi-color-text-2)` | `colorCascaderSelectionTextInactive` | `theme.colors.colorText2`（单选搜索回填 inactive 文字色） |
| `$color-cascader_selection-text-default: var(--semi-color-text-0)` | `colorCascaderSelectionTextDefault` | `theme.colors.colorText0`（回填文本色） |
| `$color-cascader_placeholder-text-default: var(--semi-color-text-2)` | `colorCascaderPlaceholderTextDefault` | `theme.colors.colorText2`（占位文本色） |
| `$color-cascader-icon-default: var(--semi-color-text-2)` | `colorCascaderIconDefault` | `theme.colors.colorText2`（箭头/清空图标色） |
| `$color-cascader-icon-hover: var(--semi-color-primary-hover)` | `colorCascaderIconHover` | `theme.colors.colorPrimaryHover`（清空按钮 hover 色） |
| `$color-cascader-icon-active: var(--semi-color-primary-active)` | `colorCascaderIconActive` | `theme.colors.colorPrimaryActive`（清空按钮按下色） |
| `$color-cascader_label-text-default: var(--semi-color-text-2)` | `colorCascaderLabelTextDefault` | `theme.colors.colorText2`（**（上游未消费）**——仅自身声明处出现；widget 不消费） |
| `$color-cascader_option-icon-default: $color-cascader-icon-default` | `colorCascaderOptionIconDefault` | `theme.colors.colorText2`（选项图标色（自引用链）） |
| `$color-cascader_input_disabled-bg-default: var(--semi-color-disabled-fill)` | `colorCascaderInputDisabledBgDefault` | `theme.colors.colorDisabledFill`（禁用底色） |
| `$color-cascader_input_disabled-bg-hover: var(--semi-color-disabled-fill)` | `colorCascaderInputDisabledBgHover` | `theme.colors.colorDisabledFill`（禁用底色 hover） |
| `$color-cascader_input_disabled-text-default: var(--semi-color-disabled-text)` | `colorCascaderInputDisabledTextDefault` | `theme.colors.colorDisabledText`（禁用文字/Tag 色） |
| `$color-cascader_input_disabled-icon-default: var(--semi-color-disabled-text)` | `colorCascaderInputDisabledIconDefault` | `theme.colors.colorDisabledText`（禁用图标色） |
| `$color-cascader_search-border-default: var(--semi-color-fill-0)` | `colorCascaderSearchBorderDefault` | `theme.colors.colorFill0`（搜索容器 border-bottom 色） |
| `$color-cascader_option_empty-text-default: var(--semi-color-disabled-text)` | `colorCascaderOptionEmptyTextDefault` | `theme.colors.colorDisabledText`（空态文字色） |
| `$color-cascader_input-bg-default: transparent` | `colorCascaderInputBgDefault` | `const Color(0x00000000)`（搜索输入透明底） |
| `$color-cascader_input-border-default: none` | `colorCascaderInputBorderDefault` | `const Color(0x00000000)`（（★`none` border 简写——「不描边」占位）） |
| `$color-cascader_select_highlight: var(--semi-color-primary)` | `colorCascaderSelectHighlight` | `theme.colors.colorPrimary`（命中高亮/选中文字色） |
| `$font-cascader_select-fontWeight: $font-weight-bold` | `fontCascaderSelectFontWeight` | `theme.typography.fontWeightBold`（选中/高亮字重） |
| `$font-cascader-fontWeight: $font-weight-regular` | `fontCascaderFontWeight` | `theme.typography.fontWeightRegular`（触发器/选项默认字重） |
| `$font-cascader_label-fontWeight: 600` | `fontCascaderLabelFontWeight` | `FontWeight.w600`（**（上游未消费）**——仅自身声明处出现；widget 不消费） |
| `$font-cascader_selection_n-fontSize: $font-size-small` | `fontCascaderSelectionNFontSize` | `12`（"+N" 字号） |
| `$font-cascader_prefix_suffix_fontWeight: $font-weight-bold` | `fontCascaderPrefixSuffixFontWeight` | `theme.typography.fontWeightBold`（prefix/suffix/insetLabel 字重） |
| `$width-cascader-border: 1px` | `widthCascaderBorder` | `1`（触发器描边宽 rest） |
| `$width-cascader_option_list-border: 1px` | `widthCascaderOptionListBorder` | `1`（选项列分割线宽） |
| `$width-cascader:  80px` | `widthCascader` | `80`（触发器 min-width） |
| `$height-cascader_default:  $height-control-default` | `heightCascaderDefault` | `32`（触发器 min-height（default）） |
| `$height-cascader_small: $height-control-small` | `heightCascaderSmall` | `24`（触发器 min-height（small）） |
| `$height-cascader_large: $height-control-large` | `heightCascaderLarge` | `40`（触发器 min-height（large）） |
| `$width-cascader_hover-border: $width-cascader-border` | `widthCascaderHoverBorder` | `1`（触发器描边宽 hover（自引用链）） |
| `$width-cascader_focus-border: $border-thickness-control-focus` | `widthCascaderFocusBorder` | `1`（触发器描边宽 focus） |
| `$width-cascader_search-border: 1px` | `widthCascaderSearchBorder` | `1`（搜索容器 border-bottom 宽） |
| `$width-cascader-icon: 32px` | `widthCascaderIcon` | `32`（箭头/清空槽宽） |
| `$width-cascader-option-icon: 16px` | `widthCascaderOptionIcon` | `16`（选项图标尺寸） |
| `$width-cascader_option:  150px` | `widthCascaderOption` | `150`（选项列 min-width） |
| `$height-cascader_option_list: 180px` | `heightCascaderOptionList` | `180`（选项区高度） |
| `$height-cascader_selection_tagInput_wrapper_small: 22px` | `heightCascaderSelectionTagInputWrapperSmall` | `22`（内联输入 min-height（small）） |
| `$height-cascader_selection_tagInput_wrapper_default: 30px` | `heightCascaderSelectionTagInputWrapperDefault` | `30`（内联输入 min-height（default）） |
| `$height-cascader_selection_tagInput_wrapper_large: 38px` | `heightCascaderSelectionTagInputWrapperLarge` | `38`（内联输入 min-height（large）） |
| `$height-cascader_selection_wrapper_small: 22px` | `heightCascaderSelectionWrapperSmall` | `22`（单选搜索容器高（small）） |
| `$height-cascader_selection_wrapper: 30px` | `heightCascaderSelectionWrapper` | `30`（单选搜索容器高（default）） |
| `$height-cascader_selection_wrapper_large: 38px` | `heightCascaderSelectionWrapperLarge` | `38`（单选搜索容器高（large）） |
| `$spacing-cascader_text-marginX: $spacing-base-tight` | `spacingCascaderTextMarginX` | `12`（prefix/suffix/insetLabel 文本 marginX） |
| `$spacing-cascader_icon-marginX: $spacing-tight` | `spacingCascaderIconMarginX` | `8`（prefix/suffix 图标 marginX） |
| `$spacing-cascader_label_checkbox-marginRight: $spacing-tight` | `spacingCascaderLabelCheckboxMarginRight` | `8`（选项 Checkbox 右间距） |
| `$spacing-cascader_selection_n-paddingX: $spacing-tight` | `spacingCascaderSelectionNPaddingX` | `8`（"+N" 水平 padding） |
| `$spacing-cascader_flatten_list-paddingRight: 64px` | `spacingCascaderFlattenListPaddingRight` | `64`（搜索扁平行右 padding） |
| `$spacing-cascader_empty_icon-marginRight: 8px` | `spacingCascaderEmptyIconMarginRight` | `8`（选项左图标（tick/占位）右间距） |
| `$spacing-cacader_option_list-paddingY: 4px` | `spacingCacaderOptionListPaddingY` | `4`（选项列 paddingY（★上游拼写 cacader）） |
| `$spacing-cacader_option_list-paddingX: 0px` | `spacingCacaderOptionListPaddingX` | `0`（选项列 paddingX（★上游拼写 cacader）） |
| `$spacing-cascader_search-paddingX: 12px` | `spacingCascaderSearchPaddingX` | `12`（搜索容器 paddingX（misnesting 意图消费）） |
| `$spacing-cascader_search-paddingY: 8px` | `spacingCascaderSearchPaddingY` | `8`（搜索容器 paddingY（misnesting 同上）） |
| `$spacing-cascader_option_empty-paddingY: 8px` | `spacingCascaderOptionEmptyPaddingY` | `8`（空态 paddingY） |
| `$spacing-cascader_option_empty-paddingX: 12px` | `spacingCascaderOptionEmptyPaddingX` | `12`（空态 paddingX） |
| `$spacing-cascader_option-paddingTop: 8px` | `spacingCascaderOptionPaddingTop` | `8`（选项行 padding-top） |
| `$spacing-cascader_option-paddingBottom: 8px` | `spacingCascaderOptionPaddingBottom` | `8`（选项行 padding-bottom） |
| `$spacing-cascader_option-paddingLeft: 12px` | `spacingCascaderOptionPaddingLeft` | `12`（选项行 padding-left） |
| `$spacing-cascader_option-paddingRight: 16px` | `spacingCascaderOptionPaddingRight` | `16`（选项行 padding-right） |
| `$transition_duration-cascader_option-bg: var(--semi-transition_duration-none)` | `transitionDurationCascaderOptionBg` | `Duration.zero`（选项底色过渡时长（AnimatedContainer）） |
| `$transition_function-cascader_option-bg: var(--semi-transition_function-easeIn)` | `transitionFunctionCascaderOptionBg` | `Curves.easeIn`（选项底色过渡曲线） |
| `$transition_delay-cascader_option-bg: var(--semi-transition_delay-none)` | `transitionDelayCascaderOptionBg` | `Duration.zero`（选项底色延迟（并入 duration 的 Flutter 近似）） |

### B. HARDCODES 另列（`_CascaderMetrics` / 调用点，widget 源内含原始片段）

| 上游片段 | 落点 |
|---|---|
| `SIZE_SET: ['small', 'large', 'default']` | 尺寸集合（constants.ts:9；normal = 上游 default） |
| `VALIDATE_STATUS: ['success', 'default', 'error', 'warning']` | validateStatus 集合（constants.ts:10） |
| `SHOW_NEXT_BY_CLICK: 'click'` / `SHOW_NEXT_BY_HOVER: 'hover'` | 展开方式集合（constants.ts:13-14） |
| `SEARCH_POSITION_TRIGGER: 'trigger'` / `SEARCH_POSITION_CUSTOM: 'custom'` | 搜索位置集合（constants.ts:19-20） |
| `RELATED: 'related'` / `UN_RELATED: 'unRelated'` | 勾选联动口径（constants.ts:21-22） |
| `LEAF_ONLY_MERGE_TYPE: 'leafOnly'` / `AUTO_MERGE_VALUE_MERGE_TYPE: 'autoMergeValue'` / `NONE_MERGE_TYPE: 'none'` | 载荷规整口径（constants.ts:16-18；calcMergeType） |
| `'_SEMI_CASCADER_SPLIT_'` | 值路径 key 分隔（constants.ts:33 `VALUE_SPLIT`） |
| `arrowIcon: <IconChevronDown />` | 箭头缺省（index.tsx:198 → SemiIcons.chevronDown） |
| `clearIcon ? clearIcon : <IconClear />` | 清空图标（index.tsx:985 → SemiIcons.clear） |
| `<IconChevronRight` / `<IconTick` | 选项展开/命中图标（item.tsx:173/175） |
| `separator: ' / '` | 值路径连接符缺省（index.tsx:213） |
| `'aria-label': 'Cascader'` | 触发器缺省语义标签（index.tsx:225） |
| `role="combobox"` | 触发器语义（index.tsx:1082——Semantics 近似） |
| `'bottomRight' : 'bottomLeft'` | 弹层缺省位置（index.tsx:1107） |
| `zIndex: popoverNumbers.DEFAULT_Z_INDEX` | 弹层 z-index 1030（index.tsx:202；popover/constants.ts:44） |
| `e.key === ESC_KEY` | Esc 收起（foundation.ts:286） |
| `isEnterPress` | 触发器 Enter 切换（foundation.ts:26/754） |
| `emptyText: '暂无数据'` | 空态 locale（zh_CN.ts:122） |
| `cursor: pointer` | 触发器指针（cascader.scss:21） |
| `cursor: not-allowed` | disabled 选项指针（cascader.scss:521） |
| `user-select: none` | disabled 文本不可选（cascader.scss:307；Flutter 默认——note-only） |
| `@include font-size-regular` | 选项/前缀后缀文本号 14（cascader.scss:125/450；读 live typography.fontSizeRegular） |
| `@include font-size-header-6` | large 触发器文本号 16（cascader.scss:58；`$font-size-header-6: 16px`） |
| `opacity: 0` | borderless 静默态箭头隐藏（cascader.scss:548） |

★cascader.scss misnesting quirk 留档：`.popover .search-wrapper`（cascader.scss:333-336）padding + border-bottom 的意图消费落在单选触发器搜索容器（搜索框不在弹层内——上游弹层只有 topSlot/Item/bottomSlot），见 A 表 `spacingCascaderSearch*`/`colorCascaderSearchBorderDefault` 说明。

## 差异清单

★照搬留档（quirk 原样）：

1. **勾选后清空搜索输入但保留 isSearching**（foundation.ts:884）：面板继续显示旧过滤结果，再次输入才重算。
2. **arrowIcon 显式 null 不渲染**：React defaultProps 只替换 undefined（index.tsx:198/993）——Flutter 以非空缺省值 + 可空字段等效表达。
3. **`-focus:hover` 不回退 hover 底色**（cascader.scss:72-82）。
4. **focus 样式是 `isFocus || open` 状态而非真实焦点**（index.tsx:1030）。
5. **同键再点单选不发 onChange 只收起**（foundation.ts:871-873）。
6. **清空按钮需 `showClear: true`**：`showClearBtn` 含 `showClear &&`（index.tsx:963-969）。
7. **`- $spacing-extra-tight` 负号空格**、**`$width-cascader:  80px`/`$height-cascader_default:  $height-control-default`/`$width-cascader_option:  150px` 双空格**、**`none` border 简写**、**`$spacing-cacader_option_list-*` 上游拼写 cacader** 原文照抄（A 表）。
8. **misnesting 死选择器按意图消费**（B 表末注）。

偏差/裁剪：

9. **disableStrictly 未移植**（照 TreeSelect 先例）：`calcCheckedStatus`/`calcNonDisabledCheckedKeys` 缺席，级联勾选会勾上禁用后代。
10. **keyMaps 未移植**：固定 `value`/`label`/`children`/`disabled`/`isLeaf` 域（[SemiCascaderData] 强类型）；`value` 上游 string|number——本移植统一 String。
11. **virtualizeInSearch 未移植**（react-window 虚拟化）：搜索结果直接滚动列。
12. **getPopupContainer / preventScroll / stopPropagation / aria-*（insetLabelId 等）未移植**：弹层走 SemiTooltip 壳（select 先例）。
13. **`emptyContent: null` 隐藏空态无三态**：null 走「暂无数据」；隐藏空态传 `const SizedBox.shrink()` 近似（item.tsx:390-392）。
14. **displayRender 拍平**：上游单选传 `string[]`、多选 Tag 传 `Entity` 的联合口径 → 统一 `String Function(List<SemiCascaderData> path, {int? index})`（返回 String 供占位/回填消费）。
15. **onExceed 拍平**：上游回传 `Entity[]` → `List<SemiCascaderData>`。
16. **onListScroll 无 DOM 事件**：只回传 `(panelIndex, activeNode)`。
17. **triggerRender value 拍平**：上游 pos 串/Set → `List<String>`；onSearch/onChange 双名只留 onSearch 语义（`SemiCascaderTriggerRenderProps`）。
18. **dropdownStyle → BoxDecoration**（CSSProperties 拍平）；dropdownClassName/dropdownMargin 对象型未移植（dropdownMargin 以 double 间距近似）。
19. **line-height 消费口径**：`height-cascader_*` → 触发器高 / fontSize 行盒（CSS line-height 的 Flutter 映射）。
20. **受控 value 口径**：`value` 非 null 即受控（TreeSelect 约定；上游 `'value' in props` 的显式 null 受控无对应）。
21. **not-exist 值合成实体照抄**（foundation.ts:579-601）：值不在 treeData 中时 `not-exist-<val>` 前缀口径原样；多选未知值丢弃（上游 getRealKeys 口径）。
22. **动画 delay 并入 duration**：`transition_delay-cascader_option-bg` 在 AnimatedContainer 无对应——并入时长近似（缺省 0 不影响）。
23. **Tag margin 简写消费**：`$spacing-cascader_selection_tag-margin*` 的 CSS `margin: Y Right Y Left`（Left=0/Right=2）以 horizontal=Right、vertical=Y 近似（Left=0 不影响布局）。
24. **选项 hover/pressed 逐行状态**：React CSS `:hover/:active` → Flutter 逐行 MouseRegion/Listener 状态跟踪（视觉等效）。
