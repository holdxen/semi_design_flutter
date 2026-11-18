# SemiTransfer

穿梭框（上游 Semi Transfer 全件移植）：左右双面板 + 勾选即穿梭（无箭头钮）——左栏 Checkbox 勾选→进右栏，右栏 close/取消勾选→出（foundation.ts:174-192 `handleSelectOrRemove`）。值模型 **key/value 双轨 quirk**（transferUtils.ts:61-64 `_generateSelectedItems`）：内部选中集按 `key` 建 Map、按 `option.value === val` 匹配 `value`（★list 不回退 key），对外 `onChanged(values, items)` 的 values 走 **value 轨**（foundation.ts:246 `values.push(obj.value)`）；★缺 `value` 的条目匹配不到 `value`/`defaultValue`、且以 `null` 条目出现在 values（JS `undefined` → Dart `null`，照搬）；`defaultValue`/`value` 未匹配到的值静默忽略（transferUtils.ts:62 `if (index !== -1)` quirk）。**非空即受控**（`value != null` 即受控；★上游 `'value' in props` 连 `undefined` 都算受控——见差异清单），受控时渲染恒随 `value`、点击只发事件不落状态（transfer.test.js:351-370），释放控制保留最后值；`defaultValue` 仅初值语义（引用变化不重置）。面板行为摘要：全选按钮动态文案（过滤结果存在未选非 disabled 项→「全选」否则「取消全选」，搜索态只作用 searchResult，disabled 跳过保留，全部 disabled 隐藏按钮——foundation.ts:111-153 + index.tsx:490-513）；清空删所有**非 disabled** 选中项（disabled 保留；showButton = 有选中 && 含非 disabled——foundation.ts:155-172 + index.tsx:835-841）；搜索默认 `label 包含 input`、`filterFn` 自定义、onSearch 随输入（★`controller.search()` 不触发——index.tsx:375-379）、★数据变化且搜索词非空时重算搜索结果（gDSFP :310-319 quirk）；close 图标 hover 显（disabled 永隐）；loading Spin 覆盖左栏；空态三槽（左/右/搜索）缺省 zh 硬编码。主题对账 **50 = 47 FIELDS + 3 MOTION + 0 INTERNAL**（47 = variables.scss 全部声明、3 = animation.scss 全部声明——**活文件**（★与 timePicker 死 animation.scss 相反：transfer.scss:1 `@import "./animation.scss"` + :81 消费，0ms/ease-in/0ms 视觉无动画）；`$module: #{$prefix}-transfer` 类名胶水不计，datePicker `223 = 220 + 3 + 0`、timePicker `20 = 14 + 6 + 0` 先例）。

## API

`SemiTransfer({key, dataSource, type, treeProps, showPath, value, defaultValue, filter, filterFn, onSearch, onSelect, onDeselect, onChanged, disabled, loading, emptyLeft, emptyRight, emptySearch, renderSourceItem, renderSelectedItem, renderSourceHeader, renderSelectedHeader, renderSourcePanel, renderSelectedPanel, controller})`。

`dataSource` 缺省 `const []`：`list/groupList` 与既有契约相同；`treeList` 时为 `List<SemiTransferItem>` 树（`children` 可嵌套，`isLeaf` 可用于异步节点）。`treeProps` 可配置树数据覆盖、展开、父子级联、过滤和 lazy loading；lazy 节点由 `loadData(item)` 触发，父级在 Future 完成时更新树数据，`onLoad(loadedKeys, item)` 接收原始 key。`showPath: true` 时右栏显示 `祖先 > 当前节点`，自定义 `renderSelectedItem` 收到 `fullPath` 路径副本；原始树节点不被修改。treeList 的缺失 value 回退到 key（list 仍保持缺 value 输出 null 的既有行为）。若 `treeProps.treeData` 覆盖 `dataSource`，左树使用覆盖数据，默认/受控 value 仍可匹配原始数据源中的条目，隐藏的已选项保留在右栏。
dataSource `List<Object>` 缺省 `const []`（[SemiTransferType.list] 时 `List<SemiTransferItem>`、[SemiTransferType.groupList] 时 `List<SemiTransferGroup>`、[SemiTransferType.treeList] 时 `List<SemiTransferItem>` 树）。type `SemiTransferType.list`（`groupList`/`treeList`）；treeList `treeProps` 支持 treeData 覆盖、展开、级联、过滤、lazy load；`showPath` 控制路径显示。value/defaultValue `List<Object?>?`（value 非空即受控）。filter `true`（显隐搜索框；★上游 `filter` union 拆分为 bool + filterFn，见差异清单）。filterFn `bool Function(String input, SemiTransferItem item)?` 缺省 `label 包含 input`。onSearch `ValueChanged<String>?`（随输入触发；★`controller.search` 不触发）。onSelect/onDeselect `ValueChanged<SemiTransferItem>?`（勾选/取消单条目，含右栏 close）。onChanged `SemiTransferChanged?` = `void Function(List<Object?> values, List<SemiTransferItem> items)`。disabled `false`；loading `false`（Spin 覆盖左栏）。emptyLeft/emptyRight/emptySearch `Widget?` 缺省 zh 硬编码。renderSourceItem `Widget Function(BuildContext, SemiTransferItem item, bool checked, VoidCallback onToggle)?`（整行替换）；renderSelectedItem `Widget Function(BuildContext, SemiTransferItem item, VoidCallback onRemove)?`（整行替换）；renderSourceHeader `Widget Function(BuildContext, SemiTransferHeaderProps)?`（`{num, showButton, allChecked, onAllClick}`）；renderSelectedHeader `Widget Function(BuildContext, SemiTransferSelectedHeaderProps)?`（`{num, showButton, onClear}`）；renderSourcePanel `Widget Function(BuildContext, SemiTransferSourcePanelProps)?`（`{value, loading, noMatch, filterData, sourceData, allChecked, showNumber, inputValue, onSearch, onAllClick, onSelectOrRemove, selectedItems, propsDataSource?, onSelect?}`）；renderSelectedPanel `Widget Function(BuildContext, SemiTransferSelectedPanelProps)?`（`{length, selectedData, onClear, onRemove}`——`onSortEnd` 随 draggable 延期）。controller `SemiTransferController?`（`search(value)`，attach/detach 后 no-op——semi_date_picker.dart:84-117 先例）。SemiTransferItem `{key（String|int 唯一）, value（Object? 对外值轨）, label（String|Widget）, disabled, children?, isLeaf?, fullPath?}`；`treeList` 缺省 value 回退 key；SemiTransferGroup `{title: String?, children: List<SemiTransferItem>}`。静态 key：`rootKey`/`leftPanelKey`/`rightPanelKey`/`searchKey`/`leftListKey`/`rightListKey`/`selectAllKey`/`clearKey` + `itemKey(Object key)`。

## 行为

### 值轨与勾选

内部 `Map<key, SemiTransferItem>`（插入序 = 选中序；重新勾选的条目排到末尾——JS Map 语义同）。勾选即穿梭：左栏 Checkbox 勾选→进右栏（无箭头钮），右栏 close/取消勾选→出（foundation.ts:174-192）。匹配按 `option.value === val`（★缺 value 的条目匹配不到 `value`/`defaultValue`，onChanged 出 `null` 条目——照搬）；`defaultValue` 未匹配值静默忽略。onChanged(values, items) 的 values = `[item.value...]`（value 轨）、items = 选中条目（groupList 时无内部 `_parent` 字段——本移植模型天然不含）；onSelect/onDeselect 仅单条目勾选路径触发（全选/清空只发 onChanged——foundation.ts 口径）。

### 全选与清空

全选按钮（foundation.ts:111-153 `handleAll` + index.tsx:490-513）：动态文案——过滤结果中存在未选非 disabled 项→「全选」，否则「取消全选」；搜索态只操作 searchResult（`inSearchMode ? data.filter(searchResult) : data`）；disabled 项跳过保留（全选时 disabled 已选保留、未选不加；取消全选时 disabled 保留）；**全部过滤项 disabled（或过滤结果为空）时不显示按钮**（filterDataAllDisabled）。清空（foundation.ts:155-172 + index.tsx:835-841）：删所有**非 disabled** 选中项、disabled 保留；按钮显示条件 = 有选中 && 含非 disabled。

### 搜索

搜索框（`filter: true` 显隐；foundation.ts:89-108）：默认 `typeof item.label === 'string' && item.label.includes(input)`（Widget label 不匹配），`filterFn` 自定义；onSearch 随输入触发；搜索词非空且无命中→空态 `emptySearch`（noMatch）；★**数据变化且搜索词非空时重算搜索结果**（gDSFP :310-319 quirk——`!isEqual(state.data, newData)` 时 filterFunc 重跑）。`controller.search(value)`：设置搜索词并重算过滤但**不触发 onSearch**（index.tsx:375-379 `handleInputChange(value, false)` quirk），输入框文本同步。

### treeList

`type: SemiTransferType.treeList`：左栏由 `SemiTree` 渲染，树 checkbox 使用关联级联、半选和 `leafOnly`/`autoMergeValue` 归一；不显示普通列表的全选按钮。`treeProps.treeData` 可覆盖左树数据，隐藏的原始选中项仍保留在右栏。Transfer 搜索输入会驱动树过滤，树负责祖先展开与 `showFilteredOnly`。异步节点需标记 `isLeaf: false`，展开时触发 `treeProps.loadData(item)` 并显示节点 Spin；异步完成后由调用方更新 `treeData` children，`loadedKeys` 可受控。`showPath` 在右栏拼接祖先 label，`fullPath` 是回调用的路径副本。

`type: SemiTransferType.groupList`：dataSource 为 `List<SemiTransferGroup>`，条目扁平化后进同一列表（transferUtils.ts:5-14 `_generateGroupedData`）；分组标题行渲染在组内首条**可见**条目前（index.tsx:647-667 renderLeftList 的 groupStatus 索引），搜索过滤后同组剩余条目仍带标题；空标题组也渲染标题行（空文本，上游 `group.title` 原样）。

### 禁用与空态

整机 disabled：根/header/条目 `cursor: not-allowed`（MouseRegion forbidden）、勾选与 close 全部不可用、close 永隐（transfer.scss:22/26/29-31）、header/条目文字 `color-transfer_disabled-text`。条目 disabled：不可勾选、close 永隐（hover 也隐，:170-171）、hover/active 底色 `inherit` 不吃（:28-29/:96-98）。空态三槽：左栏无数据（`height-transfer_left_empty` 36 高）、搜索无结果、右栏空（`height-transfer_right_empty`/`width-transfer_empty` 100% 语义 + absolute 锚点，transfer.scss:198-201）——缺省文案 zh 硬编码「暂无数据/无搜索结果/暂无内容，可从左侧勾选」。

### render 槽

6 槽：renderSourceItem/renderSelectedItem 整行替换（hover/press/勾选框架不包）、renderSourceHeader/renderSelectedHeader 替换默认 header（默认 = 「总个数：${total}」/「已选个数：${total}」replace 模式 + 全选/清空按钮）、renderSourcePanel/renderSelectedPanel 替换整个面板（两者同用时根走 `&-custom-panel`：`border: none`、`min-width: inherit`、`height: inherit`——transfer.scss:41-45）。

### 受控

`value != null` 即受控（项目惯例）：渲染恒随 `value` 重derive（含数据变化时未匹配项静默丢弃——getDerivedStateFromProps 口径）、点击只发 onSelect/onDeselect/onChanged 不落状态；释放控制（value → null）保留最后选中值。★上游 `'value' in props` 连 `undefined` 都算受控（差异清单）。`defaultValue` 仅初值语义——内部状态重建不随 defaultValue 引用变化（SemiTransferItem 列表字面量 churn 回归覆盖）。

### controller

`SemiTransferController.search(value)`：设置搜索词 + 重算过滤 + 同步输入框，**不触发 onSearch**（index.tsx:375-379）；attach/detach 生命周期照 semi_date_picker.dart:84-117（脱离后 no-op）。

## 主题（50 对账）

来源 packages/semi-foundation/transfer/variables.scss（47 声明行 / 47 唯一名——color 13、width/height 14、spacing 17（margin 12/padding 5）、radius 1、font 1、z-index 1）+ packages/semi-foundation/transfer/animation.scss（3 声明行——**活文件**：transfer.scss:1 `@import "./animation.scss"` + :81 消费，token 解析 0ms/ease-in/0ms 视觉无动画）。对账 **50 = 47 FIELDS + 3 MOTION + 0 INTERNAL**（HARDCODES 另列见 B 表；`$module: #{$prefix}-transfer` 类名胶水不计）。其中 **2 条死 FIELDS**（死变量留档不消费：落 theme + `# dead variable (上游未消费)` + 本表「（上游未消费）」+ widget assertNotIn）：`$color-transfer_disabled-bg`（唯一消费是 transfer.scss:19 的**注释行** `// background-color: ...` = 事实死）、`$color-transfer_item-bg-default`（全仓零消费）；**2 条拖拽 FIELDS** 标注「本移植未消费（draggable 延期）」（上游消费、本移植延期；非死变量）。全局 token 解析：`var(--semi-color-bg-1)` → `theme.colors.colorBg1`、`var(--semi-color-border)` → `theme.colors.colorBorder`、`var(--semi-color-text-2)` → `theme.colors.colorText2`、`var(--semi-color-text-1)` → `theme.colors.colorText1`、`var(--semi-color-text-0)` → `theme.colors.colorText0`、`var(--semi-color-disabled-text)` → `theme.colors.colorDisabledText`、`var(--semi-color-disabled-fill)` → `theme.colors.colorDisabledFill`、`var(--semi-color-fill-0)` → `theme.colors.colorFill0`、`var(--semi-color-fill-1)` → `theme.colors.colorFill1`、`var(--semi-color-white)` → `theme.colors.colorWhite`、`var(--semi-border-radius-medium)` → `theme.radius.borderRadiusMedium.value`（6）；引用 token：`$width-icon-small` → 12、`$border-thickness-control` → 1、`$spacing-base` → 16、`$spacing-tight` → 8、`$spacing-base-tight` → 12；百分比默认值存数值部分（`50%` → 50 → 消费侧 `Expanded(flex: 1)` 语义、`100%` → 100 → 消费侧填充语义）；motion 三元组照 generate_time_picker.py/generate_tag_input.py 先例：`var(--semi-transition_duration-none)`/`var(--semi-transition_delay-none)` → `Duration.zero`、`var(--semi-transition_function-easeIn)` → `Curves.easeIn`。解析列即 `SemiTransferThemeData.resolve` 默认表达式。

### A. Sass 声明映射（47 FIELDS + 3 MOTION）

| Sass 声明（默认值） | 去向 | 解析 / 说明 |
|---|---|---|
| `$color-transfer-bg: var(--semi-color-bg-1)` | `colorTransferBg` | `theme.colors.colorBg1`（根底色） |
| `$color-transfer_disabled-bg: var(--semi-color-disabled-fill)` | `colorTransferDisabledBg` | `theme.colors.colorDisabledFill`（上游未消费）——死变量留档：唯一消费是 transfer.scss:19 注释行 `// background-color: ...` |
| `$color-transfer-border: var(--semi-color-border)` | `colorTransferBorder` | `theme.colors.colorBorder`（根描边 + 中缝） |
| `$color-transfer_header-text: var(--semi-color-text-2)` | `colorTransferHeaderText` | `theme.colors.colorText2`（header 文字） |
| `$color-transfer_empty-text: var(--semi-color-text-2)` | `colorTransferEmptyText` | `theme.colors.colorText2`（空态文字） |
| `$color-transfer_group_title-text: var(--semi-color-text-2)` | `colorTransferGroupTitleText` | `theme.colors.colorText2`（分组标题） |
| `$color-transfer_disabled-text: var(--semi-color-disabled-text)` | `colorTransferDisabledText` | `theme.colors.colorDisabledText`（禁用文字） |
| `$color-transfer_close_icon-icon: var(--semi-color-text-2)` | `colorTransferCloseIconIcon` | `theme.colors.colorText2`（close 图标） |
| `$color-transfer_item-text: var(--semi-color-text-1)` | `colorTransferItemText` | `theme.colors.colorText1`（左栏条目文字） |
| `$color-transfer_selected_item-text: var(--semi-color-text-0)` | `colorTransferSelectedItemText` | `theme.colors.colorText0`（右栏条目文字） |
| `$color-transfer_item-bg-default: var(--semi-color-white)` | `colorTransferItemBgDefault` | `theme.colors.colorWhite`（上游未消费）——死变量留档：全仓零消费 |
| `$color-transfer_item-bg-hover: var(--semi-color-fill-0)` | `colorTransferItemBgHover` | `theme.colors.colorFill0`（条目 hover 底） |
| `$color-transfer_item-bg-active: var(--semi-color-fill-1)` | `colorTransferItemBgActive` | `theme.colors.colorFill1`（条目 active 底） |
| `$width-transfer-border: 1px` | `widthTransferBorder` | `1`（根描边宽） |
| `$width-transfer-minWidth: 402px` | `widthTransferMinWidth` | `402`（根最小宽） |
| `$height-transfer: 400px` | `heightTransfer` | `400`（根高） |
| `$height-transfer_header: 24px` | `heightTransferHeader` | `24`（左 header 高） |
| `$height-transfer_item-minHeight: 36px` | `heightTransferItemMinHeight` | `36`（条目最小高） |
| `$width-transfer_item_close-icon: $width-icon-small` | `widthTransferItemCloseIcon` | `12`（★用作 font-size——transfer.scss:102 quirk 留档） |
| `$width-transfer_left: 50%` | `widthTransferLeft` | `50`（50% → 消费侧 `Expanded(flex: 1)` 语义） |
| `$width-transfer_right: 50%` | `widthTransferRight` | `50`（50% → `Expanded(flex: 1)` 语义；★上游注释错写「穿梭框左侧面板宽度」照抄留档） |
| `$height-transfer_left_empty: 36px` | `heightTransferLeftEmpty` | `36`（左空态高） |
| `$width-transfer_left-border: $border-thickness-control` | `widthTransferLeftBorder` | `1`（中缝宽） |
| `$height-transfer_right_header: 32px` | `heightTransferRightHeader` | `32`（右 header 高） |
| `$height-transfer_right_empty: 100%` | `heightTransferRightEmpty` | `100`（100% → 填充语义） |
| `$width-transfer_empty: 100%` | `widthTransferEmpty` | `100`（100% → 填充语义） |
| `$height-transfer_group_title: 28px` | `heightTransferGroupTitle` | `28`（分组标题高） |
| `$spacing-transfer_header-marginTop: 12px` | `spacingTransferHeaderMarginTop` | `12` |
| `$spacing-transfer_header-marginRight: 12px` | `spacingTransferHeaderMarginRight` | `12` |
| `$spacing-transfer_header-marginBottom: 8px` | `spacingTransferHeaderMarginBottom` | `8` |
| `$spacing-transfer_header-marginLeft: 12px` | `spacingTransferHeaderMarginLeft` | `12` |
| `$spacing-transfer_header_all-marginLeft: $spacing-base` | `spacingTransferHeaderAllMarginLeft` | `16`（全选钮 margin-left，RTL 翻 margin-right） |
| `$spacing-transfer_item-paddingTop: $spacing-tight` | `spacingTransferItemPaddingTop` | `8` |
| `$spacing-transfer_item-paddingRight: 9px` | `spacingTransferItemPaddingRight` | `9`（RTL 左右值互换） |
| `$spacing-transfer_item-paddingBottom: $spacing-tight` | `spacingTransferItemPaddingBottom` | `8` |
| `$spacing-transfer_item-paddingLeft: $spacing-base-tight` | `spacingTransferItemPaddingLeft` | `12`（RTL 左右值互换） |
| `$spacing-transfer_right_header-marginTop: $spacing-base-tight` | `spacingTransferRightHeaderMarginTop` | `12` |
| `$spacing-transfer_right_header-marginBottom: 0` | `spacingTransferRightHeaderMarginBottom` | `0`（0 值字段照用即消费） |
| `$spacing-transfer_right_item_drag_handler-marginRight: 4px` | `spacingTransferRightItemDragHandlerMarginRight` | `4`——本移植未消费（draggable 延期）（上游 transfer.scss:181 拖拽 handler 消费） |
| `$spacing-transfer_filter-marginTop: 12px` | `spacingTransferFilterMarginTop` | `12` |
| `$spacing-transfer_filter-marginRight: 12px` | `spacingTransferFilterMarginRight` | `12` |
| `$spacing-transfer_filter-marginBottom: 0` | `spacingTransferFilterMarginBottom` | `0`（0 值字段照用即消费） |
| `$spacing-transfer_filter-marginLeft: 12px` | `spacingTransferFilterMarginLeft` | `12` |
| `$spacing-transfer_group_title-paddingLeft: $spacing-base-tight` | `spacingTransferGroupTitlePaddingLeft` | `12`（RTL 翻 padding-right） |
| `$radius-transfer: var(--semi-border-radius-medium)` | `radiusTransfer` | `theme.radius.borderRadiusMedium.value`（6，根圆角） |
| `$font-transfer_header_all-fontWeight: 600` | `fontTransferHeaderAllFontWeight` | `600`（double；经 SemiButtonTheme 槽映射 FontWeight.w600 到全选/清空按钮字重） |
| `$z-transfer_right_item_drag_item_move: 2000 !default` | `zTransferRightItemDragItemMove` | `2000`——本移植未消费（draggable 延期）（上游 transfer.scss:187 拖拽层消费；provenance 保留 `!default` 原文） |
| `$transition_duration_transfer_item-bg: var(--semi-transition_duration-none)` | `transitionDurationTransferItemBg` | `Duration.zero`（活字段——transfer.scss:1 `@import` + :81 消费；AnimatedContainer duration） |
| `$transition_function_transfer_item-bg: var(--semi-transition_function-easeIn)` | `transitionFunctionTransferItemBg` | `Curves.easeIn`（活字段；★命名 quirk：声明 `_transfer` 下划线、使用 `-transfer` 连字符（transfer.scss:81 `$transition_function-transfer_item-bg`）——Sass `-`/`_` 等价同一变量；AnimatedContainer curve） |
| `$transition_delay_transfer_item-bg: var(--semi-transition_delay-none)` | `transitionDelayTransferItemBg` | `Duration.zero`（活字段；★命名 quirk：声明 `_transfer`、使用 `-transfer`（transfer.scss:81 `$transition_delay-transfer_item-bg`）；delay 槽 AnimatedContainer 无对应——注释引用 + 本表注明） |

### B. HARDCODES 另列（`_TransferMetrics` / 调用点，widget 源内含原始片段）

| 上游片段 | 落点 |
|---|---|
| `cursor: not-allowed` | 整机/header/item disabled 光标（transfer.scss:22/26 → MouseRegion forbidden） |
| `visibility: hidden` + hover `visibility: visible` | close 图标默认隐、hover 显（transfer.scss:103-104/166-172 → Visibility(maintainSize)；disabled 永隐 :170-171） |
| `user-select: none` | 条目文本不可选（transfer.scss:74；行手势即语义） |
| `word-break: break-all` | 右栏文字断词（transfer.scss:176） |
| `cursor: auto` | 右栏行不给 click 光标（transfer.scss:162） |
| `transition: background-color` | 条目底色过渡（transfer.scss:81 三 MOTION 字段消费点） |
| `cursor: move` / `opacity: 0` / `// max-height: 412px` | note-only——拖拽延期（transfer.scss:182-183 handler、:193 sortable-item-active、:8 根注释）；本移植未消费（draggable 延期） |
| `DEFAULT_PAGE_SIZE: 10` | note-only——分页延期（transfer/constants.ts:14）；本移植未消费 |
| `replace('${total}',` | 「总个数：${total}」/「已选个数：${total}」replace 模式（index.tsx:506/834） |
| `emptyLeft: '暂无数据',` `emptySearch: '无搜索结果',` `emptyRight: '暂无内容，可从左侧勾选',` `placeholder: '搜索',` `clear: '清空',` `selectAll: '全选',` `clearSelectAll: '取消全选',` `total: '总个数：${total}',` `selected: '已选个数：${total}',` | zh 文案硬编码（locale/source/zh_CN.ts:161-171） |
| `$font-size-small: 12px` | header/空态/分组标题字号（mixin.scss `font-size-small`） |
| `@include font-size-regular` | 条目文字字号 14（transfer.scss:75） |
| `@include ver-center` / `@include all-center` | 垂直居中（transfer.scss:49/76/223）/ 全居中（:206） |
| `>.#{$prefix}-spin {` | loading Spin 覆盖左栏覆写（transfer.scss:134-137 `width: 100%; flex-grow: 1`） |

## 差异清单

★照搬留档（quirk 原样）：
1. **无箭头钮勾选即穿梭**：左栏 Checkbox 勾选→进右栏、右栏 close/取消勾选→出（foundation.ts:174-192）——不移植「选中→点击箭头」交互变体。
2. **key/value 双轨**：内部选中集按 key 建 Map、匹配按 `option.value === val`（transferUtils.ts:61-64）；对外 values 走 value 轨（foundation.ts:246）；★list 不回退 key。
3. **缺 value → null 条目**：缺 `value` 的条目匹配不到 `value`/`defaultValue`、onChanged 的 values 出 `null` 条目（JS `undefined` → Dart `null`）。
4. **defaultValue 忽略未匹配值**：`if (index !== -1)` quirk——value 轨未命中的值静默丢弃。
5. **搜索重算 quirk**：数据变化且搜索词非空时重算 searchResult（gDSFP :310-319）。
6. **`controller.search()` 不触发 onSearch**（index.tsx:375-379 `handleInputChange(value, false)`）。
7. **清空跳 disabled**：只删非 disabled 选中项（foundation.ts:155-172）。
8. **全 disabled 隐藏全选钮**（filterDataAllDisabled，index.tsx:513）；按钮无半选态（上游即按钮式全选）。
9. **close-icon hover 显 / 禁用永隐**（transfer.scss:103-104/166-172/170-171）。
10. **`$width-transfer_item_close-icon` 当字号用**（transfer.scss:102 `font-size: ...` quirk）。
11. **`$width-transfer_right` 注释错写**「穿梭框左侧面板宽度」（variables.scss:24）照抄留档。
12. **MOTION `_`/`-` 命名 quirk**：声明 `$transition_function_transfer_item-bg`/`$transition_delay_transfer_item-bg`（下划线）、使用 `$transition_function-transfer_item-bg`/`$transition_delay-transfer_item-bg`（连字符，transfer.scss:81）——Sass `-`/`_` 等价同一变量。

偏差/裁剪：
13. **treeList 支持**：以 [SemiTree] 处理树形展开/级联、搜索和 lazy loading；`showPath` 使用不可变路径副本。当前仍未移植 `keyMaps`、Tree 内部 `disableStrictly` 配置。
14. **pagination 延期**（Pagination 未移植）：`pagination`/`leftCurrentPage`/`handlePageChange` 不移植（`DEFAULT_PAGE_SIZE: 10` note-only 留档）。
15. **virtualize 裁剪**：`virtualize` 不移植（Flutter ListView 列表天然惰性）。
16. **draggable 延期**（用户确认）：`draggable`/Sortable/`onSortEnd`/拖拽 handler 不移植；2 条拖拽字段（`$spacing-transfer_right_item_drag_handler-marginRight`、`$z-transfer_right_item_drag_item_move`）落 theme 标注「本移植未消费（draggable 延期）」。
17. **inputProps 裁剪**：`inputProps` 透传不移植（SemiInput 直参）。
18. **item style/className 声明未消费 quirk 留档**：`BasicDataItem.style/className/fullPath`（foundation.ts:15-17）上游声明、样式未消费——本移植不建字段。
19. **`filter` union 拆分**：上游 `filter: boolean | ((input, item) => boolean)` 拆为 `filter: bool`（显隐）+ `filterFn`（谓词）。
20. **受控判定**：`'value' in props`（连 `undefined` 都算受控）→ `value != null`（项目惯例）。
21. **Form/键盘上游即无**：无 Form 联动、无键盘导航（照搬不加戏）。
22. **defaultValue 仅初值语义**（★照搬，上游 constructor 只跑一次）：内部状态重建仅由受控 value 或数据变化触发，`defaultValue`/dataSource 引用变化（列表字面量 churn）不重置已选值。
23. **清空的 stale 选中项**：上游 handleClear 按 `data` 迭代删除（不在 data 的 stale 选中项幸存）；本移植按 brief 语义直接删选中集内所有非 disabled 项（数据全在场时行为一致）。
24. **locale zh 硬编码**：zh_CN.ts:161-171 九条文案直接内置（LocaleConsumer 无对应）。
25. **CSS `direction: rtl` flex 镜像**：Flutter Row 走 Directionality 自然镜像（左右面板互换位置），中缝/margin/padding 方向互换照 rtl.scss:3-30（EdgeInsetsDirectional + 翻边先例 semi_time_picker.dart:903-915）。
26. **右栏空态 absolute 静态位**：CSS abspos 在 flex 静态位 = 容器起点（sole flex item 语义）+ `height: 100%`——本移植 `Positioned(top: 0)` + 面板高填充（全中于右面板）。

## 用法

```dart
SemiTransfer(
  type: SemiTransferType.treeList,
  dataSource: [
    SemiTransferItem(
      key: 'region',
      label: '地区',
      children: const [
        SemiTransferItem(key: 'city', value: 'city', label: '城市'),
      ],
    ),
  ],
  showPath: true,
  treeProps: const SemiTransferTreeProps(defaultExpandAll: true),
  onChanged: (values, items) {},
)

SemiTransfer(
  dataSource: [
    SemiTransferItem(key: 'a', value: 1, label: '选项 A'),
    SemiTransferItem(key: 'b', value: 2, label: '选项 B', disabled: true),
    SemiTransferItem(key: 'c', value: 3, label: '选项 C'),
  ],
  defaultValue: [2],
  onChanged: (values, items) {
    // values: [item.value...]（缺 value 的条目出 null）；items: 选中条目
  },
)

SemiTransfer(
  type: SemiTransferType.groupList,
  dataSource: [
    SemiTransferGroup(title: '分组一', children: [
      SemiTransferItem(key: 1, value: 'x', label: 'X'),
    ]),
    SemiTransferGroup(title: '分组二', children: [
      SemiTransferItem(key: 2, value: 'y', label: 'Y'),
    ]),
  ],
  value: ['x'], // 非空即受控
  filterFn: (input, item) =>
      item.label is String && (item.label! as String).startsWith(input),
  onChanged: (values, items) {},
)
```
