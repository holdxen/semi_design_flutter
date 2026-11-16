# SemiTreeSelect

树形选择器（上游 Semi TreeSelect 移植）：触发器（treeSelect.scss）+ 弹层树（复用 tree.scss 行语义，树行与 `semi_tree.dart` 同源、文件独立维护）。`treeData` 拍平（`convertDataToEntities` + `flattenTreeData`）→ 可见行；展开（受控/默认/`expandAll`/`defaultExpandAll`/`autoExpandParent` 首帧口径）、单选/多选（`checkRelation: related` 级联 + 半选 / `unRelated` 独立；`leafOnly`/`autoMergeValue` 决定 onChange 载荷）、过滤（`filterTreeNode` + `treeNodeFilterProp`；命中 + 祖先展开 + 命中/祖先/后代可见集，`showFilteredOnly` 裁剪；String 标题命中走 SemiHighlight）、远程（`remote` 只回调）、异步加载（`loadData` Spin + `onLoad`）、空态、展开/收起运动（200ms 高度+fade；`motionExpand`；虚拟化不播）、`showLine` 缩进引导线、自定义 `expandIcon`/`renderLabel`、回填 `renderSelectedItem`、触发器内搜索（`searchPosition: trigger` 单选回填浮层 / 多选标签内联输入）、标签关闭 `removeTag`、清空、"+N" 折叠（`maxTagCount` + `showRestTagsPopover`）、`borderless` 静默态、`validateStatus` warning/error、尺寸三档、RTL、locale zh。主题对账 **74 = 74 FIELDS + 0 MOTION + 0 INTERNAL**（variables.scss 74 声明行 / 74 唯一名——color 38、font 6、height 7、radius 1、spacing 15、width 7；treeSelect.scss 无 animation.scss 导入，`$module: #{$prefix}-tree-select` 类名胶水不计）；★**1 死变量**（上游未消费）：`$color-treeSelect_input_disabled-border-default` 仅被 treeSelect.scss:99 注释行引用（`// border: 1px solid ...`）——照 select `$color-select_input_disabled-border` 先例保留字段、widget 不消费。

## API

`SemiTreeSelect({treeData: const [], value, defaultValue, multiple: false, checkRelation: SemiTreeCheckRelation.related, leafOnly: false, autoMergeValue: true, onChangeWithObject: false, disabled: false, expandAction: SemiTreeExpandAction.none, expandedKeys, defaultExpandedKeys, expandAll: false, defaultExpandAll: false, autoExpandParent: false, expandIcon, motionExpand: true, showLine: false, labelEllipsis, filterTreeNode, treeNodeFilterProp: 'label', showFilteredOnly: false, searchPosition: SemiTreeSelectSearchPosition.dropdown, searchPlaceholder, searchAutoFocus: false, showSearchClear: true, searchRender, remote: false, renderLabel, renderSelectedItem, emptyContent, virtualize, loadData, loadedKeys, onLoad, placeholder, size: SemiInputSize.normal, showClear: false, arrowIcon: <IconChevronDown />, clearIcon, borderless: false, validateStatus: SemiInputStatus.normal, prefix, insetLabel, suffix, maxTagCount, showRestTagsPopover: false, restTagsPopoverPosition: SemiTooltipPosition.top, triggerTagWrap: false, position: SemiTooltipPosition.bottomLeft, dropdownMatchSelectWidth: true, autoAdjustOverflow: true, motion: true, mouseEnterDelay, mouseLeaveDelay, zIndex: 1030, defaultOpen: false, clickToHide: true, clickTriggerToHide: true, outerTopSlot, outerBottomSlot, onChange, onSelect, onExpand, onSearch, onClear, onFocus, onBlur, onVisibleChange, semanticsLabel})`。

treeData `List<SemiTreeNodeData>`（引用变化触发实体重建——建议 const/稳定引用；类型与 [SemiTree] 共用）。value/defaultValue `Object?`（单选 value 优先、key 兜底，也接受 `SemiTreeNodeData`；多选 List；value 非 null 即受控——上游 `'value' in props` 口径的 Flutter 约定变体，交互只回调）。expandedKeys `List<String>?`（非 null 即受控）。defaultExpandedKeys `List<String>?`（calcExpandedKeys autoExpandParent 缺省 true——treeUtil.ts:387）。expandAll `false`（数据变化时全展开）。defaultExpandAll `false`。autoExpandParent `false`（受控展开变更计算用；首帧恒带祖先——上游 `!prevProps` 口径）。multiple `false`（Checkbox 模式；行点击与 checkbox 都切换勾选）。checkRelation `related`（| `unRelated`）。leafOnly `false`。autoMergeValue `true`。onChangeWithObject `false`（载荷为数据对象而非 value ?? key）。disabled `false`（触发器 + 树交互关闭；★树侧箭头展开仍可用 quirk）。expandAction `none`（| click | doubleClick）。expandIcon `Object?`（Widget 或 `(expanded, onExpand) => Widget`）。motionExpand `true`（展开/收起 200ms 运动）。showLine `false`。labelEllipsis `bool?`（缺省跟随 virtualize quirk）。filterTreeNode `Object?`（bool 或 `SemiTreeFilter(input, nodeString, data)`；null/false 不渲染搜索框）。treeNodeFilterProp `'label'`。showFilteredOnly `false`。searchPosition `dropdown`（| trigger）。searchPlaceholder `String?`（缺省 locale「搜索」）。searchAutoFocus `false`。showSearchClear `true`。searchRender `Object?`（false 隐藏搜索框；`Widget Function(SemiTreeSearchProps)` 自定义；null 走默认——★多选 + 触发器搜索时内联输入是 TagInput 自带输入，searchRender 不作用于此 quirk）。remote `false`（跳过本地过滤，onSearch 后两参为空）。renderLabel `SemiTreeLabelBuilder?`。renderSelectedItem `Object?`（单选 `Widget Function(SemiTreeNodeData)`；多选 `Widget Function(SemiTreeNodeData, {int index, bool disabled, VoidCallback onClose})`；★上游多选返回 `{isRenderInTag, content}`——照 select 先例拍平，结果原样渲染）。emptyContent `String|Widget?`（缺省「暂无数据」；★上游 `emptyContent: null` 隐藏空态——本移植无三态，传 `const SizedBox.shrink()` 近似）。virtualize `SemiTreeVirtualize?`。loadData `Future<void> Function(data)?`。loadedKeys `List<String>?`（非 null 即受控）。onLoad `void Function(Set<String> loadedKeys, data)?`。placeholder `String?`。size `SemiInputSize`（small/normal/large = 上游 small/default/large——constants.ts:13 `SIZE_SET`）。showClear `false`（hover/展开时清空按钮替换箭头）。arrowIcon `Widget?`（缺省 `<IconChevronDown />`；★显式传 null 不渲染箭头——上游 defaultProps 只替换 undefined quirk）。clearIcon `Widget?`（缺省 `<IconClear />`）。borderless `false`（静默态透明底 + 隐藏箭头）。validateStatus `SemiInputStatus.normal`（warning/error = 上游 `'error' | 'warning' | 'default'`）。prefix/insetLabel/suffix `Object?`（String | Widget）。maxTagCount `int?`（+N 折叠）。showRestTagsPopover `false`。restTagsPopoverPosition `SemiTooltipPosition.top`。triggerTagWrap `false`（多选 + 触发器搜索标签换行）。position `bottomLeft`（上游 `position ? position : 'bottomLeft'`）。dropdownMatchSelectWidth `true`。autoAdjustOverflow `true`。motion `true`（弹层动画）。mouseEnterDelay/mouseLeaveDelay `Duration?`。zIndex `1030`（`zIndex: popoverNumbers.DEFAULT_Z_INDEX`）。defaultOpen `false`。clickToHide `true`（单选后收起）。clickTriggerToHide `true`（点击触发器收起）。outerTopSlot/outerBottomSlot `Widget?`。onChange `ValueChanged<Object?>?`（单选 value/key；多选 `List<value/key>`）。onSelect `void Function(String selectedKey, bool selected, data)?`（★单选恒 true quirk）。onExpand `void Function(List<String> expandedKeys, bool expanded, data)?`。onSearch `void Function(String input, List<String> filteredExpandedKeys, List<SemiTreeNodeData> filteredNodes)?`。onClear `VoidCallback?`。onFocus/onBlur `VoidCallback?`。onVisibleChange `ValueChanged<bool>?`。semanticsLabel `String?`（缺省 `'aria-label': 'TreeSelect'`）。

## 行为

### 触发器（treeSelect.scss 状态矩阵）

选择盒：圆角 `radiusTreeSelect`、描边 `widthTreeSelectBorder`（1px）+ 默认透明色、min-width 80、min-height 32/24/40（small/normal/large）。状态：rest fill-0 / hover fill-1（描边 `widthTreeSelect_hover-border`）/ pressed fill-2 / focus（`isFocus` 状态——点击置位、点击外部或单选收起复位）fill-0 + `colorFocusBorder` 描边（`-focus:hover` 保持 focus 底色 quirk）。validateStatus warning/error 时底/描边按 default/hover/focus/active 四态换 `$color-treeSelect_warning-*`/`$color-treeSelect_danger-*`。disabled：disabled-fill 底（hover 换 disabled-fill hover）、文本/图标/tag 换 disabled-text、tag 底 `colorTreeSelectTagDisabledBgDefault`、`cursor: not-allowed` + `user-select: none`；★描边走注释掉的 disabled border 行（死变量）。borderless：非 hover 非 focus → 透明底/描边 + 箭头隐藏；error/warning 描边恒 `_border-focus` 色。

结构（index.tsx:1148-1162）：`prefix/insetLabel → selection → suffix → clearBtn | arrow`（互斥32 槽 `width-treeSelect_arrow`；清空按钮 hover primary-hover / pressed primary-active）。单选回填：`renderSelectedItem` 或 label，文本 `font-treeSelect_default-fontWeight` + line-height 行盒（= `font-treeSelect_*-lineHeight` / fontSize——CSS line-height 映射）；占位文本 placeholder 色。多选：白色 Tag（`tag-marginY/X` 1/2，small 尺寸 small tag 其余 large），`maxTagCount` 折叠 "+N"（`font-treeSelect_default-fontSize` + placeholder 色；`showRestTagsPopover` 悬停展开）；空时占位再缩进 `placeholder_multiple-paddingLeft`。触发器内搜索（`searchPosition: trigger`）：单选 = bare 输入 + 回填浮层（`TriggerSearchItem`；★占位/聚焦 `opacity: .6` quirk；点击聚焦输入并复位过滤——`handleInputTriggerFocus`）；多选 = 标签 + 内联 bare 输入（`tagInput` min-height 22/30/38、wrapper paddingX 4、notEmpty/empty marginLeft -4/4；`triggerTagWrap` 时行数增高）。触发器内输入剥掉边框/底色（`colorTreeSelect_inputTrigger-border-default: none` + `bg-default: transparent` → bare 等效）。

### 打开 / 收起

点击触发器：disabled 拦截；置 `isFocus`；开 → `onVisibleChange(true)`；已开时触发器内搜索有输入不收起，否则 `clickTriggerToHide` 收起。单选选中（`clickToHide` 且（无展开动作或无子节点））→ 收起 + blur。ESC 收起（不 blur——quirk 照抄）。点击外部（tooltip barrier）→ blur + 收起。收起后 `handleAfterClose` → `clearInput` 复位过滤并把选中项祖先补进展开集。`defaultOpen` 初始展开；`searchAutoFocus` + 触发器搜索初始聚焦。`dropdownMatchSelectWidth` 记录触发器宽度作弹层 min-width；treeData/value 变化 bump `rePosKey` 重定位。

### 选择与标签

单选（foundation.ts:690-707）：点击 → `onSelect(key, true, node)`（★恒 true quirk）+ `onChange(value ?? key)`（已选中再点不重复 onChange）。多选（foundation.ts:720-758）：related 级联勾选（祖先半选）；unRelated 独立；`onChange` 载荷经 `autoMergeValue`（去祖先）/`leafOnly`（只留叶子）规整；触发器内搜索选中后清空输入。受控 value 只回调不改态。标签关闭（`removeTag`，foundation.ts:574-605）：disabled 标签不可关；related 反勾选级联 / unRelated 独立移除；`onSelect(key, false, node)` + onChange。清空（`handleClear`，foundation.ts:534-562）：单选回 null / 多选回 [] + `onClear`；触发器内搜索有输入时先复位输入。★`triggerRenderKeys` quirk 照抄：unRelated 且 autoMergeValue=false 时上游取 `[...checkedKeys]`（恒空）→ 触发器不显示标签（docs 留档）。"+N" 折叠与 TagGroup 口径一致（前 maxTagCount 个 + 灰色 +N）。

### 过滤与加载

`filterTreeNode` 非空渲染搜索框（弹层内带搜索图标前缀 + 清除（`showSearchClear`）；触发器内 bare 输入）。输入变化（foundation.ts:628-676）：命中集合 + 祖先展开（`filteredExpandedKeys`）+ 命中/祖先/后代可见集（`showFilteredOnly` 才裁剪）；`onSearch(input, filteredExpandedKeys, filteredNodes)`；清空搜索把选中项祖先补进展开集（未受控）。`remote` 跳过本地过滤（`onSearch(input, [], [])`）。String 标题命中节点走 SemiHighlight（`font-tree_option_hightlight-fontWeight` + `color-tree_option_hightlight-text` + 背景继承——tree 语义）。异步加载同 Tree：展开未加载节点显示 Spin（12×12 primary），完成后 `onLoad` 先于内部状态更新。

### 弹层与行渲染

弹层面板：bg-3 + 1px border + radius-medium + shadow-elevated（select 先例同款），max-height `height-treeSelect_popover`（300），树列表 min-width `width-treeSelect_option`（230）；顶部外挂槽（`outerTopSlot` 存在时替换搜索框）/搜索框（padding 8/12 + border-bottom `width-treeSelect_search_wrapper-border` + `color-treeSelect_search-border-default`）/滚动树列/底部外挂槽。行渲染消费 `SemiTreeThemeData`（tree.scss 语义——上游 treeSelect 直接 import tree.scss）：恒 block 模式（`option-list-block`）、勾选 Checkbox、缩进/箭头/高亮/引导线/目录图标（TreeSelect 无 directory 模式）/RTL 与 [SemiTree] 同源。行交互：点击 = 选择（expandAction click 同时展开；doubleClick 300ms 窗口识别双击展开）；箭头/checkbox 点击不触发行选择；★disabled 节点仍可展开 quirk。

## 主题（74 对账）

来源 packages/semi-foundation/treeSelect/variables.scss（74 声明行 / 74 唯一名——color 38、font 6、height 7、radius 1、spacing 15、width 7）；treeSelect.scss 无 animation.scss 导入（0 MOTION）。对账 **74 = 74 FIELDS + 0 MOTION + 0 INTERNAL**（HARDCODES 另列见 B 表；`$module: #{$prefix}-tree-select` 类名胶水不计）。★**1 死变量**（上游未消费，保留字段标注）；其余 73 条被 treeSelect.scss 消费。全局 token 解析：`var(--semi-color-fill-0/1/2)` → `theme.colors.colorFill0/1/2`、`var(--semi-color-text-0/2)` → `theme.colors.colorText0/2`、`var(--semi-color-primary-hover/active)` → `theme.colors.colorPrimaryHover/Active`、`var(--semi-color-focus-border)` → `theme.colors.colorFocusBorder`、`var(--semi-color-disabled-fill/border/text)` → `theme.colors.colorDisabledFill/Border/Text`、`var(--semi-color-warning(-light-default/hover/active))` → `theme.colors.colorWarning(…)`、`var(--semi-color-danger(-light-default/hover/active))` → `theme.colors.colorDanger(…)`；`transparent`/`none` → `const Color(0x00000000)`（select 先例；`none` 是 CSS border 简写关键字——「不描边」占位）；引用 token：`$border-thickness-control-focus` → 1、`$height-control-small/default/large` → 24/32/40、`$spacing-super-tight/extra-tight/tight/base-tight` → 2/4/8/12、`$font-weight-regular` → `theme.typography.fontWeightRegular`（= w400）、`$font-weight-bold` → `theme.typography.fontWeightBold`（= w600，生成域 fontWeight resolve 先例 tool/generate_tag.py:31）、`var(--semi-border-radius-small)` → `theme.radius.borderRadiusSmall.value`（= 3）。类型覆盖：**38 Color + 34 double + 2 FontWeight**。解析列即 `SemiTreeSelectThemeData.resolve` 默认表达式。

### A. Sass 声明映射（74 FIELDS）

| Sass 声明（默认值） | 去向 | 解析 / 说明 |
|---|---|---|
| `$color-treeSelect_default-bg-default: var(--semi-color-fill-0)` | `colorTreeSelectDefaultBgDefault` | `theme.colors.colorFill0`（触发器 rest 底色） |
| `$color-treeSelect_default-bg-hover: var(--semi-color-fill-1)` | `colorTreeSelectDefaultBgHover` | `theme.colors.colorFill1`（hover 底色） |
| `$color-treeSelect_default-bg-active: var(--semi-color-fill-2)` | `colorTreeSelectDefaultBgActive` | `theme.colors.colorFill2`（按下底色） |
| `$color-treeSelect_default-bg-focus: var(--semi-color-fill-0)` | `colorTreeSelectDefaultBgFocus` | `theme.colors.colorFill0`（focus 底色） |
| `$color-treeSelect_default-border-default: transparent` | `colorTreeSelectDefaultBorderDefault` | `const Color(0x00000000)`（rest 描边） |
| `$color-treeSelect_selection-text-default: var(--semi-color-text-0)` | `colorTreeSelectSelectionTextDefault` | `theme.colors.colorText0`（回填文本色） |
| `$color-treeSelect_default-icon-default: var(--semi-color-text-2)` | `colorTreeSelectDefaultIconDefault` | `theme.colors.colorText2`（箭头/图标色） |
| `$color-treeSelect_default-icon-hover: var(--semi-color-primary-hover)` | `colorTreeSelectDefaultIconHover` | `theme.colors.colorPrimaryHover`（清空按钮 hover） |
| `$color-treeSelect_default-icon-active: var(--semi-color-primary-active)` | `colorTreeSelectDefaultIconActive` | `theme.colors.colorPrimaryActive`（清空按钮按下） |
| `$color-treeSelect_default-border-hover: transparent` | `colorTreeSelectDefaultBorderHover` | `const Color(0x00000000)`（hover 描边） |
| `$color-treeSelect_default-border-focus: var(--semi-color-focus-border)` | `colorTreeSelectDefaultBorderFocus` | `theme.colors.colorFocusBorder`（focus 描边） |
| `$color-treeSelect_search-border-default: var(--semi-color-fill-0)` | `colorTreeSelectSearchBorderDefault` | `theme.colors.colorFill0`（搜索框 border-bottom 色） |
| `$color-treeSelect_tag_disabled-bg-default: transparent` | `colorTreeSelectTagDisabledBgDefault` | `const Color(0x00000000)`（禁用 tag 底色） |
| `$color-treeSelect_input_disabled-bg-default: var(--semi-color-disabled-fill)` | `colorTreeSelectInputDisabledBgDefault` | `theme.colors.colorDisabledFill`（禁用底色） |
| `$color-treeSelect_input_disabled-border-default: var(--semi-color-disabled-border)` | `colorTreeSelectInputDisabledBorderDefault` | `theme.colors.colorDisabledBorder`（**（上游未消费）**——仅 treeSelect.scss:99 注释行引用；widget 不消费） |
| `$color-treeSelect_input_disabled-text-default: var(--semi-color-disabled-text)` | `colorTreeSelectInputDisabledTextDefault` | `theme.colors.colorDisabledText`（禁用文本/图标） |
| `$color-treeSelect_input_disabled-bg-hover: var(--semi-color-disabled-fill)` | `colorTreeSelectInputDisabledBgHover` | `theme.colors.colorDisabledFill`（禁用 hover 底色） |
| `$color-treeSelect_input_placeholder-text-default: var(--semi-color-text-2)` | `colorTreeSelectInputPlaceholderTextDefault` | `theme.colors.colorText2`（占位文本 + "+N" 色） |
| `$color-treeSelect_warning-bg-default: var(--semi-color-warning-light-default)` | `colorTreeSelectWarningBgDefault` | `theme.colors.colorWarningLightDefault` |
| `$color-treeSelect_warning-border-default: var(--semi-color-warning-light-default)` | `colorTreeSelectWarningBorderDefault` | `theme.colors.colorWarningLightDefault` |
| `$color-treeSelect_warning-bg-hover: var(--semi-color-warning-light-hover)` | `colorTreeSelectWarningBgHover` | `theme.colors.colorWarningLightHover` |
| `$color-treeSelect_warning-border-hover: var(--semi-color-warning-light-hover)` | `colorTreeSelectWarningBorderHover` | `theme.colors.colorWarningLightHover` |
| `$color-treeSelect_warning-bg-focus: var(--semi-color-warning-light-default)` | `colorTreeSelectWarningBgFocus` | `theme.colors.colorWarningLightDefault` |
| `$color-treeSelect_warning-border-focus: var(--semi-color-warning)` | `colorTreeSelectWarningBorderFocus` | `theme.colors.colorWarning` |
| `$color-treeSelect_warning-bg-active: var(--semi-color-warning-light-active)` | `colorTreeSelectWarningBgActive` | `theme.colors.colorWarningLightActive` |
| `$color-treeSelect_warning-border-active: var(--semi-color-warning-light-active)` | `colorTreeSelectWarningBorderActive` | `theme.colors.colorWarningLightActive` |
| `$color-treeSelect_danger-bg-default: var(--semi-color-danger-light-default)` | `colorTreeSelectDangerBgDefault` | `theme.colors.colorDangerLightDefault` |
| `$color-treeSelect_danger-border-default: var(--semi-color-danger-light-default)` | `colorTreeSelectDangerBorderDefault` | `theme.colors.colorDangerLightDefault` |
| `$color-treeSelect_danger-bg-hover: var(--semi-color-danger-light-hover)` | `colorTreeSelectDangerBgHover` | `theme.colors.colorDangerLightHover` |
| `$color-treeSelect_danger-border-hover: var(--semi-color-danger-light-hover)` | `colorTreeSelectDangerBorderHover` | `theme.colors.colorDangerLightHover` |
| `$color-treeSelect_danger-bg-focus: var(--semi-color-danger-light-default)` | `colorTreeSelectDangerBgFocus` | `theme.colors.colorDangerLightDefault` |
| `$color-treeSelect_danger-border-focus: var(--semi-color-danger)` | `colorTreeSelectDangerBorderFocus` | `theme.colors.colorDanger` |
| `$color-treeSelect_danger-bg-active: var(--semi-color-danger-light-active)` | `colorTreeSelectDangerBgActive` | `theme.colors.colorDangerLightActive` |
| `$color-treeSelect_danger-border-active: var(--semi-color-danger-light-active)` | `colorTreeSelectDangerBorderActive` | `theme.colors.colorDangerLightActive` |
| `$radius-treeSelect: var(--semi-border-radius-small)` | `radiusTreeSelect` | `3`（触发器圆角） |
| `$width-treeSelect-border: 1px` | `widthTreeSelectBorder` | `1`（触发器描边宽） |
| `$width-treeSelect_search_wrapper-border: 1px` | `widthTreeSelectSearchWrapperBorder` | `1`（搜索框 border-bottom 宽） |
| `$width-treeSelect_hover-border: $border-thickness-control-focus` | `widthTreeSelectHoverBorder` | `1`（hover 描边宽） |
| `$width-treeSelect_focus-border: $width-treeSelect_hover-border` | `widthTreeSelectFocusBorder` | `1`（focus 描边宽；自引用链照抄） |
| `$width-treeSelect_default: 80px` | `widthTreeSelectDefault` | `80`（触发器 min-width） |
| `$height-treeSelect_default: $height-control-default` | `heightTreeSelectDefault` | `32`（触发器 min-height——default 档） |
| `$font-treeSelect_default-lineHeight: $height-treeSelect_default` | `fontTreeSelectDefaultLineHeight` | `32`（回填文本行盒高；自引用链照抄） |
| `$font-treeSelect_default-fontWeight: $font-weight-regular` | `fontTreeSelectDefaultFontWeight` | `theme.typography.fontWeightRegular`（回填文本字重） |
| `$font-treeSelect_default-fontSize: 14px` | `fontTreeSelectDefaultFontSize` | `14`（"+N" 字号） |
| `$height-treeSelect_small: $height-control-small` | `heightTreeSelectSmall` | `24`（small 档 min-height） |
| `$font-treeSelect_small-lineHeight: $height-treeSelect_small` | `fontTreeSelectSmallLineHeight` | `24`（small 行盒高） |
| `$height-treeSelect_large: $height-control-large` | `heightTreeSelectLarge` | `40`（large 档 min-height） |
| `$font-treeSelect_large-lineHeight: $height-treeSelect_large` | `fontTreeSelectLargeLineHeight` | `40`（large 行盒高） |
| `$font-treeSelect_prefix_suffix_fontWeight: $font-weight-bold` | `fontTreeSelectPrefixSuffixFontWeight` | `theme.typography.fontWeightBold`（prefix/suffix 字重） |
| `$spacing-treeSelect_selection_tagInput_wrapper-paddingX: $spacing-extra-tight` | `spacingTreeSelectSelectionTagInputWrapperPaddingX` | `4`（内联标签容器 paddingX） |
| `$spacing-treeSelect_selection_tagInput_empty-marginLeft: $spacing-extra-tight` | `spacingTreeSelectSelectionTagInputEmptyMarginLeft` | `4`（空标签容器 marginLeft） |
| `$spacing-treeSelect_selection_tagInput_notEmpty-marginLeft: - $spacing-extra-tight` | `spacingTreeSelectSelectionTagInputNotEmptyMarginLeft` | `-4`（非空 marginLeft——★上游 `- ` 负号空格原文照抄） |
| `$spacing-treeSelect_selection-paddingLeft: $spacing-base-tight` | `spacingTreeSelectSelectionPaddingLeft` | `12`（单选回填区左缩进） |
| `$spacing-treeSelect_tag-marginX: $spacing-super-tight` | `spacingTreeSelectTagMarginX` | `2`（tag 水平外边距） |
| `$spacing-treeSelect_tag-marginY: 1px` | `spacingTreeSelectTagMarginY` | `1`（tag 垂直外边距） |
| `$spacing-treeSelect_selection_multiple-paddingLeft: 4px` | `spacingTreeSelectSelectionMultiplePaddingLeft` | `4`（多选回填区左缩进） |
| `$spacing-treeSelect_placeholder_multiple-paddingLeft: 8px` | `spacingTreeSelectPlaceholderMultiplePaddingLeft` | `8`（多选占位缩进） |
| `$spacing-treeSelect_prefix_text-marginY: 0px` | `spacingTreeSelectPrefixTextMarginY` | `0`（prefix 文本 marginY） |
| `$spacing-treeSelect_prefix_text-marginX: $spacing-base-tight` | `spacingTreeSelectPrefixTextMarginX` | `12`（prefix 文本 marginX） |
| `$spacing-treeSelect_prefix_icon-marginY: 0px` | `spacingTreeSelectPrefixIconMarginY` | `0`（prefix 图标 marginY） |
| `$spacing-treeSelect_prefix_icon-marginX: $spacing-tight` | `spacingTreeSelectPrefixIconMarginX` | `8`（prefix 图标 marginX） |
| `$spacing-treeSelect_selection_withSuffix-paddingRight: 0px` | `spacingTreeSelectSelectionWithSuffixPaddingRight` | `0`（有后缀时回填区右 padding） |
| `$spacing-treeSelect_search_wrapper-paddingX: 12px` | `spacingTreeSelectSearchWrapperPaddingX` | `12`（搜索容器 paddingX；★misnesting 意图消费——与 tree.scss 同值） |
| `$spacing-treeSelect_search_wrapper-paddingY: 8px` | `spacingTreeSelectSearchWrapperPaddingY` | `8`（搜索容器 paddingY；misnesting 同上） |
| `$color-treeSelect_selection_TriggerSearchItem_disabled-text-default: var(--semi-color-disabled-text)` | `colorTreeSelectSelectionTriggerSearchItemDisabledTextDefault` | `theme.colors.colorDisabledText`（触发器搜索回填禁用色） |
| `$color-treeSelect_inputTrigger-border-default: none` | `colorTreeSelectInputTriggerBorderDefault` | `const Color(0x00000000)`（★`none` 是 CSS border 简写关键字——「不描边」占位；bare 输入等效消费） |
| `$color-treeSelect_inputTrigger-bg-default: transparent` | `colorTreeSelectInputTriggerBgDefault` | `const Color(0x00000000)`（触发器内输入透明底） |
| `$color-treeSelect_prefix_suffix_text-default: var(--semi-color-text-2)` | `colorTreeSelectPrefixSuffixTextDefault` | `theme.colors.colorText2`（prefix/suffix 文本色） |
| `$width-treeSelect_arrow: 32px` | `widthTreeSelectArrow` | `32`（箭头/清空槽宽） |
| `$width-treeSelect_option:  230px` | `widthTreeSelectOption` | `230`（树列 min-width；★冒号后双空格原文照抄） |
| `$height-treeSelect_popover: 300px` | `heightTreeSelectPopover` | `300`（弹层 max-height；★misnesting 意图消费） |
| `$height-treeSelect_selection_tagInput_wrapper_small: 22px` | `heightTreeSelectSelectionTagInputWrapperSmall` | `22`（内联输入 min-height——small） |
| `$height-treeSelect_selection_tagInput_wrapper_default: 30px` | `heightTreeSelectSelectionTagInputWrapperDefault` | `30`（内联输入 min-height——default） |
| `$height-treeSelect_selection_tagInput_wrapper_large: 38px` | `heightTreeSelectSelectionTagInputWrapperLarge` | `38`（内联输入 min-height——large） |

### B. HARDCODES 另列（`_TreeSelectMetrics` / 调用点，widget 源内含原始片段）

| 上游片段 | 落点 |
|---|---|
| `SIZE_SET: ['small', 'large', 'default']` | 尺寸集合（constants.ts:13；normal = 上游 default） |
| `SEARCH_POSITION_DROPDOWN: 'dropdown'` / `SEARCH_POSITION_TRIGGER: 'trigger'` | 搜索位置集合（constants.ts:14-15） |
| `'error' \| 'warning' \| 'default'` | validateStatus 集合（foundation.ts:30） |
| `arrowIcon: <IconChevronDown />` | 箭头缺省（index.tsx:294 → SemiIcons.chevronDown） |
| `clearIcon ? clearIcon : <IconClear />` | 清空图标（index.tsx:1054 → SemiIcons.clear） |
| `aria-label='Filter TreeSelect item'` | 弹层搜索框语义（index.tsx:1355） |
| `aria-label="Clear TreeSelect value"` | 清空按钮语义（index.tsx:1049） |
| `role='combobox'` / `aria-haspopup="tree"` | 触发器语义（index.tsx:1172/:1174——Semantics 近似） |
| `'aria-label': 'TreeSelect'` | 触发器缺省语义标签（index.tsx:319） |
| `position ? position : 'bottomLeft'` | 弹层缺省位置（index.tsx:1598） |
| `zIndex: popoverNumbers.DEFAULT_Z_INDEX` | 弹层 z-index 1030（index.tsx:301；popover/constants.ts:44） |
| `e.key === ESC_KEY` | Esc 收起（foundation.ts:314） |
| `isEnterPress` | 触发器 Enter 切换（foundation.ts:528） |
| `opacity: .6` | 触发器搜索回填占位透明度（treeSelect.scss:167-168） |
| `@include font-size-regular` | 回填/prefix/suffix 文本号 14（treeSelect.scss:124/350；读 live typography.fontSizeRegular） |
| `@include font-size-header-6` | large 回填文本号 16（treeSelect.scss:329-330；`$font-size-header-6: 16px`） |
| `cursor: pointer` | 触发器指针（treeSelect.scss:17） |
| `cursor: not-allowed` | disabled 指针（treeSelect.scss:95） |
| `user-select: none` | disabled 文本不可选（treeSelect.scss:96；Flutter 默认——note-only） |
| `searchPlaceholder: '搜索'` | 搜索占位 locale（zh_CN.ts:153） |
| `duration={200}` | 展开/收起运动时长（nodeList.tsx:50；树行同源 semi_tree.dart） |
| `transform: rotate(270deg)` | 收起三角旋转（tree.scss:131-135；树行同源） |

★treeSelect.scss misnesting quirk 留档：`&-search-wrapper` / `&-maxTagCount` / `&-popover` 嵌在 `&-prefix, &-suffix` 块下（treeSelect.scss:405-419），编译成 `-prefix-search-wrapper` 等死选择器——本移植按意图消费（搜索容器 padding 8/12 与 tree.scss 活规则同值、popover max-height 300 用于面板、+N 字号/色），见 A 表说明。

## 差异清单

★照搬留档（quirk 原样）：

1. **单选 onSelect 恒 true**：已选中再点仍发 `onSelect(key, true, node)`（foundation.ts:694），但不发 onChange。
2. **`triggerRenderKeys` unRelated quirk**：`checkRelation: unRelated` 且 `autoMergeValue: false` 时上游取 `[...checkedKeys]`（unRelated 下恒空）→ 触发器不显示标签（index.tsx:1124-1125）。
3. **arrowIcon 显式 null 不渲染**：React defaultProps 只替换 undefined（index.tsx:294/1033）——Flutter 以非空缺省值 + 可空字段等效表达。
4. **focus 样式是 `isFocus` 状态而非真实焦点**：点击置位、点击外部/单选收起复位；ESC 收起不复位（-focus 类残留 quirk）。
5. **`-focus:hover` 不回退 hover 底色**（treeSelect.scss:41-45）。
6. **禁用行仍 pointer 光标 + hover 底色**、**disabled 节点仍可展开**（树行与 semi_tree.dart 同源 quirk）。
7. **触发器搜索回填 `opacity: .6`**（占位/聚焦；treeSelect.scss:167-168）。
8. **清空按钮需 `showClear: true`**：`showClearBtn` 含 `showClear &&`（index.tsx:871）——触发器内搜索也一样。
9. **misnesting 死选择器按意图消费**（B 表末注）。
10. **`- $spacing-extra-tight` 负号空格**、**`$width-treeSelect_option:  230px` 双空格**、**`none` border 简写** 原文照抄（A 表）。

偏差/裁剪：

11. **disableStrictly 未移植**（与 Tree 一致）：严格禁用不移植；级联勾选会勾上禁用后代。
12. **keyMaps / treeNodeLabelProp 未移植**：固定 `key`/`label` 域（[SemiTreeNodeData] 强类型）；树数据结构转换在应用层。
13. **renderFullLabel / triggerRender 未移植**：整行/整触发器自定义不移植——用 `renderLabel`/`renderSelectedItem`/`prefix`/`suffix` 定制。
14. **`emptyContent: null` 隐藏空态无三态**：null 走「暂无数据」；隐藏空态传 `const SizedBox.shrink()` 近似（index.tsx:1369-1371）。
15. **`renderSelectedItem` isRenderInTag 拍平**（select 先例）：多选结果按原样渲染（SemiTag 外），onClose 自接。
16. **多选 + 触发器搜索的内联输入不走 searchRender**（上游 TagInput 自带输入 quirk 照抄）；searchRender 只作用于弹层搜索与单选触发器搜索。
17. **多选触发器随标签行数增高**（Flutter Wrap 布局）：上游默认 `overflow: hidden` 裁剪、`triggerTagWrap` 才增高——本移植两种模式都允许换行增高（视觉近似），`triggerTagWrap` 保留 min-height `height - 2*border` 口径。
18. **dropdownStyle / dropdownClassName / optionListStyle / dropdownMargin / stopPropagation / getPopupContainer / preventScroll / insetLabelId 未移植**：弹层样式走面板固定装饰（select 先例）。
19. **line-height 消费口径**：`font-treeSelect_*-lineHeight` → 回填文本 `TextStyle.height`（= lineHeight / fontSize——CSS line-height 的 Flutter 映射）；行内文本垂直居中由布局承担。
20. **react-window → ListView.builder**（virtualize）与 **AutoSizer 未移植** 同 Tree；`searchTargetIsDeep` 运动细节未移植（与 Tree 移植一致）。
21. **受控 value 口径**：`value` 非 null 即受控（SemiInput 约定；上游 `'value' in props` 的显式 null 受控无对应）。
22. **弹层搜索框 border-bottom 以 treeSelect 字段消费**：上游弹层内 `tree-search-wrapper` 的 border 来自 treeSelect.scss:436-438（width/color 同源）；padding 以 `spacingTreeSelectSearchWrapper*` 消费（与 tree.scss 12/8 同值——misnesting 意图）。
23. **多选 wrap CheckboxGroup 未移植**（index.tsx:1571）：勾选状态由行内 Checkbox 直接承载（无 form 集成需求）。
24. **树行独立实现**：行渲染/运动/折线与 semi_tree.dart 同源（上游复用 TreeNode/NodeList）；两文件独立维护，行侧 quirk（rotate 270、duration 200 等）按 tree 留档。
