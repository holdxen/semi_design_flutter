# SemiContextMenu 右键菜单

无需 Material，使用 `package:semi_design_flutter/semi_design_flutter.dart` 和 Flutter widgets。行为移植自 Radix primitives `@radix-ui/react-context-menu`（context-menu.tsx + menu.tsx），视觉与 `SemiDropdown` 菜单同款（复用 SemiDropdown 菜单 token）；Semi 上游没有 ContextMenu 组件，本组件为新增（无上游 SCSS 变量）。

```dart
SemiContextMenu(
  nodes: [
    SemiDropdownItemData(name: '复制', onTap: () {}),
    SemiDropdownItemData(name: '粘贴', onTap: () {}),
    const SemiDropdownDividerData(),
    SemiDropdownSubmenuItemData(
      name: '导出为',
      children: [
        SemiDropdownItemData(name: 'PNG', onTap: () {}),
        SemiDropdownItemData(name: 'SVG', onTap: () {}),
      ],
    ),
    SemiDropdownCheckboxItemData(
      name: '显示网格',
      checked: showGrid,
      onCheckedChange: (v) => setState(() => showGrid = v),
    ),
    const SemiDropdownDividerData(),
    SemiDropdownItemData(
      name: '删除',
      type: SemiDropdownItemType.danger,
      onTap: () {},
    ),
  ],
  child: const SizedBox(width: 400, height: 300, child: Text('右键/长按我')),
)
```

## API 与边界

`SemiContextMenu` 参数（`lib/src/components/semi_context_menu.dart`，上游 `packages/react/context-menu/src/context-menu.tsx` + `menu.tsx`）：

| 字段 | 说明 | 默认 |
| --- | --- | --- |
| `nodes` | `List<SemiDropdownNode>` 菜单节点（SemiDropdown 同一数据模型，含勾选/单选/子菜单节点） | 必填 |
| `child` | 触发区子树；整个区域响应右键/长按 | 必填 |
| `enabled` | false 时不打开菜单（上游 `ContextMenuTrigger.disabled`，原生右键行为透传） | `true` |
| `showTick` | `bool?` 组级对勾列；非 null 时优先于行级 `showTick`。含勾选/单选行的菜单恒定预留对勾列 | null |
| `closeOnEsc` | 可见时消费 Escape 并关闭整棵菜单树 | `true` |
| `motion` | 显隐动画（fade+scale，沿用 SemiTooltip 动画 token） | `true` |
| `longPressEnabled` | 触摸/手写笔长按 700ms 打开（上游 `LONG_PRESS`） | `true` |
| `visible` | `bool?` **非 null 即完全受控**：交互只回调、内部不改态（同 SemiDropdown） | null |
| `onVisibleChange` | `ValueChanged<bool>`，显隐回调 | - |
| `onClickOutSide` | 菜单树之外按下关闭前回调 | - |
| `onEscKeyDown` | Escape 被消费时回调 | - |

菜单节点沿用 `SemiDropdownNode` sealed 家族（`lib/src/components/semi_menu_nodes.dart`；`semi_dropdown.dart` 再导出，公共 API 不变），除 SemiDropdown 的 `SemiDropdownItemData`/`SemiDropdownTitleData`/`SemiDropdownDividerData` 外新增：

| 类型 | 字段 | 说明 |
| --- | --- | --- |
| `SemiDropdownCheckboxItemData` | `name`/`icon`/`disabled`/`type` | 同 item；激活切换勾选（Radix `ContextMenuCheckboxItem`） |
| | `checked` / `indeterminate` | 勾选态 / 半选态（半选行渲染 minus 图标，激活恒上报 `true`，Radix `onCheckedChange` 不收 `indeterminate`） |
| | `onCheckedChange` | `ValueChanged<bool>`，激活回调 |
| `SemiDropdownRadioGroupData` | `children` | `List<SemiDropdownRadioItemData>` 组内单选行 |
| | `value` / `onValueChange` | 选中值 / 新值回调（Radix `ContextMenuRadioGroup`） |
| `SemiDropdownRadioItemData` | `value` | 必填；与组 `value` 相等时渲染对勾（Radix `ContextMenuRadioItem`） |
| | `name`/`icon`/`disabled`/`type` | 同 item |
| `SemiDropdownSubmenuItemData` | `children` | `List<SemiDropdownNode>` 子菜单节点（可嵌套） |
| | `name`/`icon`/`disabled`/`type`/`showTick` | 同 item；行尾 chevron 图标（RTL 翻转） |

## 打开与定位（Radix 行为映射）

- **右键**（`Listener` + `kSecondaryMouseButton`，避开手势竞技场）在**指针位置**打开；菜单打开时再次右键**重新锚定**并收起子菜单（上游 issue #2611 行为）。
- **触摸/手写笔长按 700ms** 打开（上游 `LONG_PRESS`）；指针移动/抬起取消。
- 根菜单定位：左上角 ≈ 指针 +2px（上游 `side: right, sideOffset: 2`），越界先翻转到指针对侧、再钳制到视口内 8px 边距（`semiPositionAtPoint`，`lib/src/overlay/semi_anchor_popup.dart`）。
- 子菜单锚定父行矩形：LTR 贴行右缘、RTL 贴左缘、顶对齐（上游 `SubContent align: start`），越界翻边/钳制（`semiPositionAtRect`）。
- 关闭：外部按下（菜单树矩形之外）、Escape、选中菜单项。`onClickOutSide` 只对"外部按下"触发。
- 打开期间指针按下与触发器右键的竞争用 (pointer, timeStamp) claim 解耦（Radix `claimedLongPressEvents` 等价），与命中测试顺序无关。

## 子菜单（Radix MenuSub 行为映射）

- 悬停子菜单行 **100ms** 打开（上游 `openTimerRef`）；悬停其他行立即收起；离开所有菜单行后 **300ms** 宽限收起（上游 grace-area 多边形的等效实现，见差异清单）。
- 点击子菜单行切换开合；键盘 **Enter/Space/→（LTR）** 打开并聚焦首个可用行，**←（LTR）** 关闭并回焦父行（RTL 左右互换）。

## 键盘

菜单层级各自持焦（打开时根层请求焦点，子菜单打开后焦点移入最深层）：

- **↑/↓** 循环移动高亮（disabled 行跳过）；**Home/End** 首/末可用行。
- **Enter/Space** 激活高亮行：普通行回调并关闭；勾选行 `onCheckedChange` 切换并关闭；单选行 `onValueChange` 并关闭；子菜单行开合。
- **Escape** 关闭整棵菜单树（含子菜单，上游 Escape 关 root）；**Tab** 忽略（菜单不进 Tab 流）。
- **首字母 typeahead**：累积输入前缀匹配（1000ms 缓冲，上游 `searchRef`），当前行仍匹配则保留（`getNextMatch` 语义），单字符重复循环；首字符取 `name` 的 String/`Text`/`SemiText` 文本。
- 高亮仅在键盘实际使用后绘制（`:focus-visible` 语义，同 SemiDropdown）；指针悬停推动高亮但不绘制。

## 菜单渲染

与 SemiDropdown 共享行渲染（`lib/src/components/semi_menu_surface.dart`，`SemiMenuSurface`/`SemiMenuRow`）：bg3 表面、medium 圆角、shadow-elevated 两行、行 hover/按下/高亮填充、12×12 图标列与对勾列、`SemiDropdownItemType` 五档文字色。勾选/单选行的指示器位于左侧对勾列（勾选 tick / 半选 minus / 未选透明占位）。

## 主题

`SemiContextMenuThemeData` 即 `SemiDropdownThemeData`（typedef）：Semi 上游无 ContextMenu，无独立 SCSS 变量，全部 token 复用 dropdown 菜单 token。字段回落链：局部 `SemiContextMenuTheme` 补丁（外到内 merge）> `components.contextMenu` 非空覆盖 > `components.dropdown` > live global 默认值。`SemiContextMenuTheme` 通道与 `SemiDropdownTheme` 相互独立（互不透传局部补丁）。

## 与 SemiDropdown 的关系

- 节点模型共享（sealed `SemiDropdownNode` 家族）；`SemiDropdown` 同步获得勾选/单选/子菜单节点的渲染能力：勾选/单选行点击回调且不自动关闭（dropdown 行为同 item），子菜单行由嵌套 `SemiDropdown`（hover、rightTop/leftTop）承载。
- `SemiDropdown` 的键盘模型保持上游 Semi 单层语义不变：仅普通 item 行进导航/typeahead；完整键盘流（Home/End、子菜单开合、Escape 关树）属于 `SemiContextMenu`。

## 差异清单

- **非模态**：Radix 默认 `modal: true`（focus trap、禁外部指针、滚动锁、`hideOthers`）；本移植为非模态 + 外部按下即关（Flutter 桌面惯例），无焦点陷阱/滚动锁/aria-hidden 遮蔽。
- **子菜单宽限区等效**：上游离开 SubTrigger 后以 grace 多边形（±5px bleed、300ms 有效）判断斜向滑入；本移植等效为「指针处于任一菜单行上、或离开全部行 300ms 内」不收起子菜单——斜向滑入不关闭，但无方向多边形判定。
- **typeahead 匹配**：上游 `getNextMatch` 全串正则匹配 + 单字符重复排除当前项循环；本移植为前缀匹配 + 当前项仍匹配则保留 + 重复单字符循环，非字母键无修饰符均入缓冲。
- **hover 焦点**：上游 pointermove 即聚焦行（hover 与键盘同一高亮）；本移植悬停更新高亮位置但仅键盘使用后绘制填充（同 SemiDropdown 的 `:focus-visible` 裁剪）。
- **Space 语义**：缓冲非空时 Space 作为 typeahead 字符；空缓冲时 Space 激活高亮行（上游同语义，简化实现）。
- **语义 indeterminate**：Flutter `Semantics` 无 `aria-checked="mixed"` 直通，半选行以 `Semantics(mixed: true)` 表达（上游 `aria-checked="indeterminate"`）。
- **受控锚点**：`visible: true` 且无指针交互记录时锚定触发区中心（上游 dev 警告并锚定视口原点）。
- **快捷键列未移植**：Radix 无 `ContextMenuShortcut`（消费方自组合）；`name` 可传 Widget 自行排布快捷键文本。
- **position/zIndex 参数未移植**：Radix Content 的 `side/align` 由指针锚定语义取代；层叠由 Overlay 插入顺序决定（同 SemiDropdown 口径）。
- **`className`/`style`/`getPopupContainer`/事件对象参数**：Flutter 无对应物，不移植。
- **长按重开**：触摸长按期间菜单已打开时不重新锚定（外部按下先关闭，再次长按重开）；上游「新触摸先关闭」语义保留。
