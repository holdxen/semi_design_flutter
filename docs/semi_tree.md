# SemiTree

树形控件（上游 Semi Tree 全件移植，核心交互完整；draggable 等列差异清单）：`treeData` 拍平（`convertDataToEntities` + `flattenTreeData`）→ 可见行列表；展开（受控/默认/`expandAll`/`defaultExpandAll`/`autoExpandParent` 首帧口径）、单选/多选（`checkRelation: related` 级联 + 半选 / `unRelated` 独立；`leafOnly`/`autoMergeValue` 决定 onChange 载荷）、过滤（`filterTreeNode` + `treeNodeFilterProp`；命中节点 + 祖先展开 + 命中/祖先/后代可见集，`showFilteredOnly` 裁剪；String 标题走 Highlight：bold + primary）、异步加载（`loadData` 未加载节点展开时 Spin，完成后 `loadedKeys` + `onLoad`）、空态、运动（展开/收起块 200ms 高度+fade；虚拟化不播）、`showLine` 缩进引导线、目录图标、自定义 icon/renderLabel、RTL、locale zh。主题对账 **33 = 29 FIELDS + 4 MOTION + 0 INTERNAL**（variables.scss 29 + animation.scss 4 亲验——tree.scss:1 `@import "./animation.scss"` + :57-59 消费，0ms/ease-in/0ms/scale(1,1) 恒等；`$module: #{$prefix}-tree` 类名胶水不计，datePicker `223 = 220 + 3 + 0`、timePicker `20 = 14 + 6 + 0`、transfer `50 = 47 + 3 + 0`、anchor `30 = 26 + 4 + 0`、breadcrumb `20 = 16 + 4 + 0`、pagination `48 = 41 + 7 + 0` 先例）；★**0 死变量**（29+4 条声明全被 tree.scss 消费；draggable 专属 5 条因**draggable 未移植**在 widget 侧不消费，不属死变量）。

## API

`SemiTree({treeData: const [], value, defaultValue, expandedKeys, defaultExpandedKeys, expandAll: false, defaultExpandAll: false, autoExpandParent: false, multiple: false, checkRelation: SemiTreeCheckRelation.related, leafOnly: false, autoMergeValue: true, onChangeWithObject: false, disabled: false, directory: false, icon, blockNode: true, expandAction: SemiTreeExpandAction.none, expandIcon, motion: true, showLine: false, labelEllipsis, filterTreeNode, treeNodeFilterProp: 'label', showFilteredOnly: false, searchPlaceholder, showClear: true, searchRender, renderLabel, loadData, loadedKeys, onLoad, virtualize, emptyContent, onChange, onSelect, onExpand, onSearch, onDoubleClick, onContextMenu, semanticsLabel})`。

treeData `List<SemiTreeNodeData>`（引用变化触发实体重建——建议 const/稳定引用）。value/defaultValue `Object?`（单选 value 优先、key 兜底；多选 List；value 非 null 即受控——交互只回调）。expandedKeys `List<String>?`（非 null 即受控；变更按 autoExpandParent 重算）。defaultExpandedKeys `List<String>?`（★首帧强制 autoExpandParent——上游 `!prevProps` 口径）。expandAll `false`（数据变化时全展开）。defaultExpandAll `false`。autoExpandParent `false`。multiple `false`（Checkbox 模式；★行点击与 checkbox 都切换勾选）。checkRelation `related`（| `unRelated`）。leafOnly `false`（onChange 只留叶子键）。autoMergeValue `true`（related 合并父键去祖先）。onChangeWithObject `false`（载荷为数据对象而非 value ?? key）。disabled `false`（整树禁用；★箭头展开仍可用 quirk）。directory `false`（folder/folder-open/file 兜底）。icon `Object?`（Widget 或 `Widget Function(SemiTreeNodeData)`；节点 icon 优先）。blockNode `true`（整行 hover/选中底色；false 只染标题文字区）。expandAction `SemiTreeExpandAction.none`（| click | doubleClick）。expandIcon `Object?`（Widget 或 `(expanded, onExpand) => Widget`）。motion `true`。showLine `false`。labelEllipsis `bool?`（缺省跟随 virtualize——上游 `labelEllipsis ?? virtualize` quirk）。filterTreeNode `Object?`（bool 或 `SemiTreeFilter(input, nodeString, data)`；null/false 不渲染搜索框）。treeNodeFilterProp `'label'`（支持 label/value/key/icon）。showFilteredOnly `false`。searchPlaceholder `String?`（缺省 locale「搜索」）。showClear `true`。searchRender `Widget Function(SemiTreeSearchProps)?`。renderLabel `Widget Function(label, data, searchWord)?`。loadData `Future<void> Function(data)?`。loadedKeys `List<String>?`（非 null 即受控）。onLoad `void Function(Set<String> loadedKeys, data)?`。virtualize `SemiTreeVirtualize?`（`{itemSize, height, width}` → `ListView.builder`）。emptyContent `String|Widget?`（缺省「暂无数据」）。onChange `ValueChanged<Object?>?`。onSelect `void Function(String selectedKey, bool selected, data)?`（★单选恒 true quirk）。onExpand `void Function(List<String> expandedKeys, bool expanded, data)?`。onSearch `void Function(String input, List<String> filteredExpandedKeys)?`。onDoubleClick / onContextMenu `ValueChanged<SemiTreeNodeData>?`（去 DOM 事件）。semanticsLabel `String?`（aria-label）。

`SemiTreeNodeData({required key, label, icon, value, disabled = false, isLeaf, children})`：key `String`（固定 `key` 域——keyMaps 未移植）、label `Object?`（String | Widget）、icon `Widget?`、value `Object?`、disabled `bool`、isLeaf `bool?`（false 强制非叶；null 按 children/loadData 推断）、children `List<SemiTreeNodeData>?`。

## 行为

### 拍平与展开

`treeData` → `keyEntities`（level/pos/parent；pos 形如 `0-1-2`）+ 拍平列表（只含展开节点的子级）。展开（foundation.ts:696-752）：受控 `expandedKeys` 非 null 时内部不改态、**props 变更时重算拍平列表且不播运动**（上游把 motionKeys/flatten 更新都放在 `!isExpandControlled` 分支）；未受控 toggle；`loadData` 且未加载的节点展开时显示 Spin（12×12 primary）；★无 `loadData` 且无子节点的节点不响应展开；★disabled 节点**仍可展开**（上游 onExpand 无 disabled 检查 quirk）。运动（nodeList.tsx/nodeCollapsible.tsx）：展开/收起时把该节点的已展开后代行包进一个 200ms 高度+fade 块（`duration={200}`）；收起时缓存旧拍平列表让被移除的行播完离场；虚拟化模式不播（上游同）。

### 选择与勾选

单选（foundation.ts:589-607）：点击 → `onSelect(key, true, node)`（★恒 true quirk）+ `onChange(value ?? key)`；已选中再点不重复 onChange。多选（foundation.ts:662-694）：related → 勾选级联后代、祖先逐级判满/半选（`calcCheckedKeysForChecked/Unchecked`），载荷经 `autoMergeValue`（去祖先）/`leafOnly`（只留叶子）规整；unRelated → 独立切换。受控 `value` 下只回调不改态（父级改 props 才更新）。行点击与 checkbox 都走同一多选逻辑（checkbox 点击不额外触发行选择）。expandAction：click → 行点击同时展开；doubleClick → 300ms 内二次点击识别为双击（补发 onDoubleClick；展开）；none → 单击只选择。

### 过滤

`filterTreeNode` 非空渲染搜索框（`SemiInput` + 搜索图标前缀 + 清除；locale「搜索」）。输入变化（foundation.ts:526-567）：命中集合 + 祖先展开（`filteredExpandedKeys`）+ 命中/祖先/后代可见集（`filteredShownKeys`）；`showFilteredOnly` 才裁剪列表；`onSearch(input, filteredExpandedKeys)`。String 标题命中节点走 [SemiHighlight]（bold `fontTreeOptionHightlightFontWeight` + `colorTreeOptionHightlightText` + 背景继承——覆盖 Highlight 默认底色）。清空搜索时把选中项祖先补进展开集（未受控）。

### 异步加载

展开 `loadData` 且未加载节点 → 该行显示 Spin（`colorTreeOptionLoadingIconDefault`，`widthTreeSpinIcon` 12）；Promise 完成 → `onLoad(loadedKeys, node)` 先于内部状态更新（避免重复 loadData）→ 记入 `loadedKeys`（受控时只回调）。叶子判定：`loadData` 存在时未加载节点按非叶子（可展开）。

### 视觉与 RTL

行盒：上下 4、level1 左 8 + 每级 20 缩进；expand/empty/switcher 槽 12 + 右距 8；图标/checkbox 右距 8；字号 14；行过渡 bg 三元组 + `transform: scale(...)`（0ms 恒等）。block 模式：整行 hover fill-0 / 按 fill-1 / 选中 primary-light（选中覆盖 hover/按）；箭头 hover icon-hover / 按 icon-active（仅 block）。非 block：标题文字区 hover/active/选中底色 + `radiusTreeCheckboxAddon` 圆角。禁用：标题文字/无数据行 disabled-text；★禁用行仍 pointer 光标且 hover 底色照旧（上游 quirk）。showLine：每级缩进单元一条竖线（末位单元不画）+ 叶子 switcher 折线（竖线 + 8px 枝线；末叶竖线只到中线；线色 text-3）。空态：居中 + disabled 色（「暂无数据」/emptyContent）。RTL：paddings/margins 走 EdgeInsetsDirectional；收起三角 rotate 90（LTR 270）；引导线/折线镜像；多选 aria 近似 Semantics。

## 主题（33 对账）

来源 packages/semi-foundation/tree/variables.scss（29 声明行 / 29 唯一名——color 11、fontWeight 1、radius 1、spacing 12、width 4）+ packages/semi-foundation/tree/animation.scss（4 声明行——tree.scss:1 `@import "./animation.scss"` + :57-59 消费）。对账 **33 = 29 FIELDS + 4 MOTION + 0 INTERNAL**（HARDCODES 另列见 B 表；`$module: #{$prefix}-tree` 类名胶水不计）。★**0 死变量**；draggable 未移植 → 5 条拖拽专用字段（insert-border 色、draggable paddingY/X、draggable border 宽）本移植不消费。全局 token 解析：`var(--semi-color-text-0/2)` → `theme.colors.colorText0/2`、`var(--semi-color-fill-0/1)` → `theme.colors.colorFill0/1`、`var(--semi-color-primary)` → `theme.colors.colorPrimary`、`var(--semi-color-primary-light-default)` → `theme.colors.colorPrimaryLightDefault`、`var(--semi-color-disabled-text)` → `theme.colors.colorDisabledText`、`var(--semi-color-black)` → `theme.colors.colorBlack`；引用 token：`$width-icon-small` → 12、`$font-weight-bold` → `theme.typography.fontWeightBold`（生成域 fontWeight resolve 先例 tool/generate_tag.py:31）、`var(--semi-border-radius-small)` → `theme.radius.borderRadiusSmall.value`（= 3）；motion 四元组照 breadcrumb 先例：`Duration.zero` / `Curves.easeIn` / `const SemiTransform.scale(1, 1)`。类型覆盖：**11 Color + 17 double + 1 FontWeight + 2 Duration + 1 Curve + 1 SemiTransform**。解析列即 `SemiTreeThemeData.resolve` 默认表达式。

### A. Sass 声明映射（29 FIELDS + 4 MOTION）

| Sass 声明（默认值） | 去向 | 解析 / 说明 |
|---|---|---|
| `$color-tree_option-text-default: var(--semi-color-text-0)` | `colorTreeOptionTextDefault` | `theme.colors.colorText0`（行文字色） |
| `$color-tree_option-icon-default: var(--semi-color-text-2)` | `colorTreeOptionIconDefault` | `theme.colors.colorText2`（箭头/节点图标色） |
| `$color-tree_option-bg-hover: var(--semi-color-fill-0)` | `colorTreeOptionBgHover` | `theme.colors.colorFill0`（行/标题 hover 底色） |
| `$color-tree_option_selected-bg-default: var(--semi-color-fill-1)` | `colorTreeOptionSelectedBgDefault` | `theme.colors.colorFill1`（行/标题按下底色） |
| `$color-tree_option-bg-active: var(--semi-color-primary-light-default)` | `colorTreeOptionBgActive` | `theme.colors.colorPrimaryLightDefault`（选中底色） |
| `$color-tree_option_disabled-text-default: var(--semi-color-disabled-text)` | `colorTreeOptionDisabledTextDefault` | `theme.colors.colorDisabledText`（禁用文字/空态） |
| `$color-tree_option-icon-hover: var(--semi-color-text-0)` | `colorTreeOptionIconHover` | `theme.colors.colorText0`（箭头 hover，block） |
| `$color-tree_option-icon-active: var(--semi-color-black)` | `colorTreeOptionIconActive` | `theme.colors.colorBlack`（箭头按下，block） |
| `$color-tree_option_loading-icon-default: var(--semi-color-primary)` | `colorTreeOptionLoadingIconDefault` | `theme.colors.colorPrimary`（加载 Spin 色） |
| `$color-tree_option_draggable_insert-border-default: var(--semi-color-primary)` | `colorTreeOptionDraggableInsertBorderDefault` | `theme.colors.colorPrimary`（**draggable 未移植——本移植不消费**） |
| `$font-tree_option_hightlight-fontWeight: $font-weight-bold` | `fontTreeOptionHightlightFontWeight` | `theme.typography.fontWeightBold`（高亮字重；★`hightlight` 错拼照抄） |
| `$color-tree_option_hightlight-text: var(--semi-color-primary)` | `colorTreeOptionHightlightText` | `theme.colors.colorPrimary`（高亮字色；★错拼照抄） |
| `$radius-tree_checkbox_addon: var(--semi-border-radius-small)` | `radiusTreeCheckboxAddon` | `3`（标题区/checkbox addon 圆角） |
| `$spacing-tree_search_wrapper-paddingX: 12px` | `spacingTreeSearchWrapperPaddingX` | `12`（搜索框水平 padding） |
| `$spacing-tree_search_wrapper-paddingY: 8px` | `spacingTreeSearchWrapperPaddingY` | `8`（搜索框垂直 padding） |
| `$spacing-tree_option_level-paddingLeft: 20px` | `spacingTreeOptionLevelPaddingLeft` | `20`（每级缩进） |
| `$spacing-tree_option_level1-paddingLeft: 8px` | `spacingTreeOptionLevel1PaddingLeft` | `8`（首级左 padding） |
| `$spacing-tree_optionList-paddingX: 0` | `spacingTreeOptionListPaddingX` | `0`（列表水平 padding） |
| `$spacing-tree_optionList-paddingY: 8px` | `spacingTreeOptionListPaddingY` | `8`（列表垂直 padding） |
| `$spacing-tree_option-paddingTop: 4px` | `spacingTreeOptionPaddingTop` | `4`（行上 padding） |
| `$spacing-tree_option-paddingBottom: 4px` | `spacingTreeOptionPaddingBottom` | `4`（行下 padding） |
| `$spacing-tree_icon-marginRight: 8px` | `spacingTreeIconMarginRight` | `8`（箭头右距） |
| `$spacing-tree_label_withIcon-marginRight: 8px` | `spacingTreeLabelWithIconMarginRight` | `8`（图标/checkbox 右距） |
| `$spacing-tree_option_draggable-paddingY: 2px` | `spacingTreeOptionDraggablePaddingY` | `2`（**draggable 未移植——本移植不消费**） |
| `$spacing-tree_option_draggable-paddingX: 0` | `spacingTreeOptionDraggablePaddingX` | `0`（**draggable 未移植——本移植不消费**） |
| `$width-tree_emptyIcon: $width-icon-small` | `widthTreeEmptyIcon` | `12`（expand/empty/switcher 槽宽） |
| `$width-tree_spinIcon: $width-icon-small` | `widthTreeSpinIcon` | `12`（Spin 尺寸） |
| `$width-tree_option_draggable-border: 2px` | `widthTreeOptionDraggableBorder` | `2`（**draggable 未移植——本移植不消费**） |
| `$width-tree_option_line: 1px` | `widthTreeOptionLine` | `1`（showLine 引导线宽） |
| `$transition_duration-tree_option-bg: var(--semi-transition_duration-none)` | `transitionDurationTreeOptionBg` | `Duration.zero`（活字段——:57 消费；AnimatedContainer duration） |
| `$transition_function-tree_option-bg: var(--semi-transition_function-easeIn)` | `transitionFunctionTreeOptionBg` | `Curves.easeIn`（活字段；AnimatedContainer curve） |
| `$transition_delay-tree_option-bg: var(--semi-transition_delay-none)` | `transitionDelayTreeOptionBg` | `Duration.zero`（活字段；delay 槽无对应——注释引用） |
| `$transform_scale-tree-option: var(--semi-transform_scale-none)` | `transformScaleTreeOption` | `const SemiTransform.scale(1, 1)`（活字段——:59 消费；★编译产物 `transform: scale(scale(1,1))` 无效 bug 留档） |

### B. HARDCODES 另列（`_TreeMetrics` / 调用点，widget 源内含原始片段）

| 上游片段 | 落点 |
|---|---|
| `EXPAND_ACTION: [false, 'click', 'doubleClick']` | 展开动作集合（constants.ts:6） |
| `JSON_KEY_SPLIT:` | note-only——treeDataSimpleJson 未移植 |
| `'暂无数据'` / `'搜索'` | locale emptyText / searchPlaceholder（zh_CN.ts:125-126） |
| `aria-label='Filter Tree'` | 搜索框语义（index.tsx:648） |
| `aria-multiselectable` / `role="treeitem"` | aria 近似（index.tsx:861-862 / treeNode.tsx:456） |
| `duration={200}` | 展开/收起运动时长（nodeList.tsx:50） |
| `DRAG_OFFSET = 0.45` | note-only——draggable 未移植（treeUtil.ts:34） |
| `transform: rotate(270deg)` | 收起三角旋转（tree.scss:131-135；RTL 90） |
| `transform: scale(scale(1,1))` | note-only——无效编译 bug（tree.scss:59） |
| `debounce(this.onSelect, 500` | note-only——双击模式选择防抖（treeNode.tsx:55；本移植单击即选） |
| `isEnterPress` | note-only——li/checkbox 无 tabindex，Enter 实际不可达（treeNode.tsx:86/:112） |
| `IconSearch` | 搜索框前缀（index.tsx:34 → SemiIcons.search） |
| `auto-wrapper` | note-only——AutoSizer 未移植（autoSizer.tsx:84；virtualize.height 定高） |
| `calc(($spacing-tree_option_level-paddingLeft / 2) * 0.8)` | 叶子折线枝线宽 = 8（tree.scss:299） |
| `var(--semi-color-text-3)` | 引导线/折线颜色（tree.scss:258/:292 → theme.colors.colorText3） |
| `user-select: none` | 文本不可选（treeUtil 注释；Flutter 默认——note-only） |

## 差异清单

★照搬留档（quirk 原样）：

1. **单选 onSelect 恒 true**：已选中再点仍发 `onSelect(key, true, node)`（foundation.ts:594），但不再发 onChange。
2. **disabled 节点仍可展开**：onExpand 无 disabled 检查（foundation.ts:741-752）——只有选择/勾选被拦截。
3. **禁用行仍 pointer 光标 + hover 底色**：tree.scss 未给 `-option-disabled` 加 cursor/hover 例外（只有箭头颜色在 block 下有专属）。
4. **labelEllipsis 缺省跟随 virtualize**：`labelEllipsis ?? virtualize`（index.tsx:898）——开了虚拟化默认单行省略。
5. **首帧强制 autoExpandParent**：初值/首帧 `expandedKeys` 计算带祖先（`props.autoExpandParent || !prevProps`）。
6. **`hightlight` 错拼**、**`reset/rest` 类拼写族**照抄上游原文。
7. **无效 transform 编译 bug**：`transform: scale(scale(1,1))`（tree.scss:59）——视觉无影响留档。

偏差/裁剪：

8. **draggable 未移植**：`draggable`/`autoExpandWhenDragEnter`/`hideDraggingNode`/`renderDraggingNode`/`onDragStart/Enter/Over/Leave/End/Drop` 不移植——5 条拖拽专用主题字段因此不消费（docs 已标注；不是死变量）。Flutter 拖拽需另设 Draggable/DragTarget 方案，留待后续。
9. **renderFullLabel 未移植**：整行自定义（含渲染契约 labelProps）不移植——用 `renderLabel`/`icon` 定制标题与图标。
10. **treeDataSimpleJson / keyMaps 未移植**：Flutter 侧用强类型 `SemiTreeNodeData`（固定 `key` 域）；JSON 树可在应用层转换。
11. **disableStrictly 未移植**：严格禁用（禁用后代参与的勾选判定）不移植；普通禁用照旧（级联勾选会勾上禁用后代，视觉与上游非严格模式一致）。
12. **scrollTo / preventScroll 未移植**：虚拟列表滚动定位需应用自持 ScrollController。
13. **react-window → ListView.builder**：虚拟化用 `ListView.builder(itemExtent: virtualize.itemSize)`；AutoSizer 未移植——`virtualize.height` 定高，否则需父级有界高度。虚拟化下运动不播（上游同）。
14. **搜索结果高亮细节**：上游 Highlight 组件按 searchWords 分词；本移植用 `SemiHighlight`（bold/primary/背景透明）等价；`renderLabel` 自定义时不注入高亮（上游同）。
15. **双击识别**：上游原生 dblclick；本移植行点击即时选择（onTap），当存在双击动作（`expandAction: doubleClick` 或 `onDoubleClick`）时以 300ms 窗口识别双击并补发；★双击模式下第二次点击不重复选择（上游 debounce leading 口径的近似）。
16. **非 block 模式底色**：上游分别染 `-label-text` 与 `checkbox-addon`；本移植统一染标题文字区（视觉近似，注明）。
17. **Enter 键盘**：li/checkbox 无 tabindex，Enter 事件上游实际不可达（note-only）；本移植不加 tab 陷阱。
18. **onContextMenu/onDoubleClick 事件对象裁剪**：回调只回传节点（无 DOM event）。
19. **className/style/searchClassName/searchStyle/aria 细节裁剪**：Flutter 无 CSS 类；aria 以 Semantics 近似。

## 用法

```dart
SemiTree(
  treeData: const [
    SemiTreeNodeData(
      key: '1',
      label: '父节点',
      children: [
        SemiTreeNodeData(key: '1-1', label: '子节点 A'),
        SemiTreeNodeData(key: '1-2', label: '子节点 B', disabled: true),
      ],
    ),
    SemiTreeNodeData(key: '2', label: '叶子', isLeaf: true),
  ],
  defaultExpandedKeys: const ['1'],
  onChange: (value) {},
)

// 多选 + 过滤 + 引导线
SemiTree(
  treeData: data,
  multiple: true,
  showLine: true,
  filterTreeNode: true,
  onSearch: (input, expandedKeys) {},
)

// 虚拟化（父级给高/用 height 定高）
SizedBox(
  height: 320,
  child: SemiTree(
    treeData: bigData,
    virtualize: const SemiTreeVirtualize(itemSize: 34),
    labelEllipsis: true,
  ),
)
```
