# SemiDropdown 下拉菜单

无需 Material，使用 `package:semi_design_flutter/semi_design_flutter.dart` 和 Flutter widgets。以 `SemiTooltip` 为底座（`showArrow: false`、`popupBare: true`，弹层自绘菜单表面）。

```dart
SemiDropdown(
  trigger: SemiTooltipTrigger.click,
  showTick: true,
  menu: const [
    SemiDropdownTitleData('分组1'),
    SemiDropdownItemData(name: 'primary1', type: SemiDropdownItemType.primary),
    SemiDropdownItemData(name: 'secondary', type: SemiDropdownItemType.secondary),
    SemiDropdownDividerData(),
    SemiDropdownItemData(name: 'warning', type: SemiDropdownItemType.warning, active: true),
    SemiDropdownItemData(name: 'danger', type: SemiDropdownItemType.danger, disabled: true),
  ],
  child: const Text('hover me'),
)
```

## API 与边界

`SemiDropdown` 参数（`lib/src/components/semi_dropdown.dart`，上游 `packages/semi-ui/dropdown/index.tsx` + `foundation.ts`）：

| 字段 | 说明 | 默认 |
| --- | --- | --- |
| `child` | 触发器子树 | 必填 |
| `menu` | `List<SemiDropdownNode>?`，声明式菜单；空列表渲染空菜单（上游 `menu`） | null |
| `content` | 自定义弹层内容 `Widget?`（上游 `render`）。**与 `menu` 二选一**（assert 不同时给，见差异清单） | null |
| `showTick` | `bool?` 组级对勾列；非 null 时优先于 item 的 `showTick`（上游 `contextShowTick ?? showTick`） | null |
| `trigger` | `SemiTooltipTrigger` 同枚举 5 种（hover/click/focus/custom/contextMenu） | `hover` |
| `position` | `SemiTooltipPosition`，12 方位 | `bottom` |
| `spacing` | 触发器与弹层间距；null 时顶层 4、嵌套层 2（上游 `numbers.SPACING`/`NESTED_SPACING`） | null |
| `mouseEnterDelay` | hover/focus 展开延时 | 50ms |
| `mouseLeaveDelay` | hover/focus（含 blur）收起延时 | 100ms（上游 `DEFAULT_LEAVE_DELAY`） |
| `closeOnEsc` | 可见时消费 Escape 并关闭 | `true`（上游 `closeOnEsc`） |
| `clickToHide` | 点击弹层自身关闭 | `false` |
| `motion` | 显隐动画（zoom+fade，沿用底座） | `true` |
| `visible` | `bool?` **非 null 即完全受控**：交互只回调、内部不改态 | null |
| `onVisibleChange` | `ValueChanged<bool>`，显隐回调 | - |
| `onClickOutSide` | 点击触发器/弹层之外前回调 | - |
| `onEscKeyDown` | Escape 被消费时回调 | - |
| `repositionKey` | 变化强制重定位（上游 `rePosKey`） | - |
| `zIndex` | 对齐底座参数（未使用，插入顺序决定层叠）；默认取 `$z-dropdown` 1050 | 1050 |

菜单节点（sealed `SemiDropdownNode`，上游 `DropDownMenuItem`）：

| 类型 | 字段 | 说明 |
| --- | --- | --- |
| `SemiDropdownItemData` | `name` | `Object?`：`String`（渲染 `SemiText`）或 `Widget` 原样放置 |
| | `icon` | `Widget?` 前置图标，12×12（`sizeDropdownIconWidth/Height`）+ 右距 9（`spacingDropdownIconMarginRight`） |
| | `active` | 字重 600（`fontDropdownItemActiveFontWeight`）、渲染对勾、跳过 hover/按下填充（上游 `:not(.item-active)` 规则） |
| | `disabled` | 禁色 + 透明底、不响应点击/键盘（上游 `disabled`） |
| | `type` | `SemiDropdownItemType?`：primary/secondary/tertiary/warning/danger；**无默认档**：null 用 `colorDropdownItemTextDefault` |
| | `onTap` | 激活回调（上游 `onClick`） |
| | `showTick` | `bool?` 行级对勾覆盖；组级非 null 时被组级覆盖（context 优先） |
| `SemiDropdownTitleData` | `name` | `Object?` 分组标题（String→`SemiText` 或 Widget）；withTick 左距 31 仅看**组级** `showTick` |
| `SemiDropdownDividerData` | - | 1px 分隔线（`heightDropdownSeperator` × `colorDropdownSeperatorBgDefault`，上下 margin 4） |

节点模型与 `SemiContextMenu` 共享（`lib/src/components/semi_menu_nodes.dart`）：`SemiDropdownCheckboxItemData`（勾选/半选行）、`SemiDropdownRadioGroupData`+`SemiDropdownRadioItemData`（单选组）、`SemiDropdownSubmenuItemData`（子菜单行，嵌套 `SemiDropdown` 承载）在 dropdown 中同样渲染并回调，但**不进 dropdown 的键盘导航**（上游 Semi 单层键盘语义不变；完整键盘流见 docs/semi_context_menu.md）。

## 菜单渲染

弹层表面（上游 `-wrapper`，弹层自绘，不套 Tooltip 气泡）：

```
DecoratedBox(bg3 / 圆角 medium / shadow-elevated 两行)   ← 容器
  ClipRRect > SingleChildScrollView                    ← overflow-y: auto
    Padding(menuPaddingY 4 / menuPaddingX 0) > IntrinsicWidth > Column(stretch)
      title   padding 上 8 下 4 左 16（withTick 31）右 16，12px text-2
      item    max-width 280、padding 上下 8、左 16（withTick 12）右 16
      divider 1px border 色、上下 margin 4
```

★`menu` 与 `content` 两条路径同住上游 `-wrapper`：`content` 形态同样套这层表面
（bg3 / 圆角 / 两道阴影，`_DropdownWrapperSurface`）；此前 content 裸内容漂浮
无卡片——SemiNavigation 的 Sub 列表与 SemiBreadcrumb 的溢出面板同步修正。

- item 行 `Row(center)`：对勾列（12×12 + 右距 9）→ icon（12×12 + 右距 9）→ label（`Flexible`，280 换行）。非 `active` 行的对勾位是同尺寸透明占位（上游 `IconTick color: transparent`）。
- 背景：hover/键盘高亮 `fill-0`、按下 `fill-1`；`active` 行跳过 hover/按下填充；`disabled` 透明底 + 禁色。`animationDuration/animationCurve`（item 背景过渡，实际 0ms/easeOut）驱动 `AnimatedContainer`。
- RTL（rtl.scss）：全部 `EdgeInsetsDirectional`——withTick 左 padding 与 icon/对勾右距自动翻转到右侧。
- 语义：菜单 `Semantics(role: menu)`（空菜单不打 role）、行 `Semantics(role: menuItem, enabled)`、触发器 `Semantics(button, expanded)`（aria-haspopup/expanded 等价）。

## 嵌套与指针豁免

`content` 里可再嵌 `SemiDropdown`（组合式），嵌套层 `spacing` 默认 2。底座 `SemiOverlayPointerExempt` 注册表（`semi_tooltip.dart`）：

- 每个弹层内容包一层 scope；嵌套 Dropdown 弹层把自身 RenderBox 全局矩形注册到最近祖先 scope，并沿 scope 链向上注册（多层嵌套时各层祖先都豁免）。
- `_handleOutsidePointer` 判定时命中注册矩形的指针视为"内部"：**点子菜单弹层/子菜单项不关父层**；**点兄弟弹层关父层**（兄弟弹层不在父层 scope 链上，不互相豁免）。
- 上游没有豁免机制：父层靠 document 外点判定会关闭，item 靠 `onMouseDown` 抢跑回调兜底（`dropdownItem.tsx`）；移植不需要该兜底。

## 键盘（单层）

菜单整体 `Focus`；click 触发器打开时把键盘光标放在首个可用行（上游 `setFocusToFirstMenuItem` 仅 click 触发），但**不显示高亮背景**——对齐浏览器 `:focus-visible` 语义：鼠标打开不绘制焦点高亮，仅在键盘导航（方向键/typeahead）后才显示，避免常驻填充掩盖 hover 反馈；Enter/Space 激活光标所在行（打开后直接按即首行）：

- **Enter/Space** 激活高亮行（高亮只在可用行间移动，disabled 跳过）。
- **ArrowUp/ArrowDown** 循环移动高亮（等价上游 `setFocusToPrevious/NextMenuItem`，disabled 行不入导航表），移动时 `Scrollable.ensureVisible`。
- **首字母 typeahead**：`findIndexByCharacter` 等价——从当前行之后搜索、环绕回开头；首字符取 `name` 的 String/`Text`/`SemiText` 文本。
- **Escape** 由底座 `closeOnEsc` 关闭（默认 true）；菜单不消费、事件上浮到弹层侧处理器。
- 嵌套键盘缺口与上游一致：无跨层键盘流（无左右键开合子菜单、Esc 只关持有焦点层、父层高亮不联动）；触发器侧 ArrowUp/Down 直接聚焦菜单项（上游 `data-popupid` DOM 桥）未复刻。

## 主题

主题优先级：局部非空补丁（外到内 merge）> 当前 `SemiThemeData.components.dropdown` > live global 默认值。`SemiDropdownTheme` 局部补丁跨 `SemiTheme`/Overlay 边界继承（捕获只携带局部补丁快照）。`copyWith`/`merge` 的 null 表示保留原值。

来源 `packages/semi-foundation/dropdown/variables.scss`（34 声明）+ `packages/semi-foundation/dropdown/animation.scss`（3 声明），共 **37** 个声明 = **36** 个主题字段（下表 A 组，`tool/generate_dropdown.py` 生成到 `semi_dropdown_theme_data.dart`，全量）+ **1** 个 widget 内部声明（`$filter-dropdown-bg`，B 组）；dropdown.scss 的 9 个硬编码同入 B 组。**46 = 36 + 10** 为来源注释计数防漂移校验（`tool/test_generate_dropdown.py`）。独立于 383 项 CSS manifest。

### A. 主题字段（36）

颜色 13（resolve 实时读取当前 global）：

| Sass | 默认 | Theme 字段 → resolve |
|---|---|---|
| `$color-dropdown-bg-default` | var(--semi-color-bg-3) | colorDropdownBgDefault → theme.colors.colorBg3 |
| `$color-dropdown_title-text-default` | var(--semi-color-text-2) | colorDropdownTitleTextDefault → theme.colors.colorText2 |
| `$color-dropdown_item-text-default` | var(--semi-color-text-0) | colorDropdownItemTextDefault → theme.colors.colorText0 |
| `$color-dropdown_item-bg-hover` | var(--semi-color-fill-0) | colorDropdownItemBgHover → theme.colors.colorFill0 |
| `$color-dropdown_item-bg-active` | var(--semi-color-fill-1) | colorDropdownItemBgActive → theme.colors.colorFill1 |
| `$color-dropdown_item_danger-text-default` | var(--semi-color-danger) | colorDropdownItemDangerTextDefault → theme.colors.colorDanger |
| `$color-dropdown_item_secondary-text-default` | var(--semi-color-secondary) | colorDropdownItemSecondaryTextDefault → theme.colors.colorSecondary |
| `$color-dropdown_item_warning-text-default` | var(--semi-color-warning) | colorDropdownItemWarningTextDefault → theme.colors.colorWarning |
| `$color-dropdown_item_tertiary-text-default` | var(--semi-color-tertiary) | colorDropdownItemTertiaryTextDefault → theme.colors.colorTertiary |
| `$color-dropdown_item_primary-text-default` | var(--semi-color-primary) | colorDropdownItemPrimaryTextDefault → theme.colors.colorPrimary |
| `$color-dropdown_item_disabled-text-default` | var(--semi-color-disabled-text) | colorDropdownItemDisabledTextDefault → theme.colors.colorDisabledText |
| `$color-dropdown_item_disabled-bg-default` | transparent | colorDropdownItemDisabledBgDefault → Color(0x00000000) |
| `$color-dropdown_seperator-bg-default` | var(--semi-color-border) | colorDropdownSeperatorBgDefault → theme.colors.colorBorder（上游拼写 seperator 原样保留） |

spacing 13（展开值：$spacing-tight 8、$spacing-extra-tight 4、$spacing-base 16、$spacing-base-tight 12）：

| Sass | 默认 | Theme 字段 → resolve |
|---|---|---|
| `$spacing-dropdown_menu-paddingY` | $spacing-extra-tight | spacingDropdownMenuPaddingY → 4 |
| `$spacing-dropdown_menu-paddingX` | 0 | spacingDropdownMenuPaddingX → 0 |
| `$spacing-dropdown_title-paddingTop` | $spacing-tight | spacingDropdownTitlePaddingTop → 8 |
| `$spacing-dropdown_title-paddingBottom` | $spacing-extra-tight | spacingDropdownTitlePaddingBottom → 4 |
| `$spacing-dropdown_title-paddingLeft` | $spacing-base | spacingDropdownTitlePaddingLeft → 16 |
| `$spacing-dropdown_title-paddingRight` | $spacing-base | spacingDropdownTitlePaddingRight → 16 |
| `$spacing-dropdown_title_withTick-paddingLeft` | 31px | spacingDropdownTitleWithTickPaddingLeft → 31 |
| `$spacing-dropdown_item_withTick-paddingLeft` | $spacing-base-tight | spacingDropdownItemWithTickPaddingLeft → 12 |
| `$spacing-dropdown_item-paddingY` | $spacing-tight | spacingDropdownItemPaddingY → 8 |
| `$spacing-dropdown_item-paddingX` | $spacing-base | spacingDropdownItemPaddingX → 16 |
| `$spacing-dropdown_icon-marginRight` | 9px | spacingDropdownIconMarginRight → 9 |
| `$spacing-dropdown_seperator-marginY` | $spacing-extra-tight | spacingDropdownSeperatorMarginY → 4 |
| `$spacing-dropdown_seperator-marginX` | 0 | spacingDropdownSeperatorMarginX → 0 |

圆角/宽度/尺寸/高度/字体 7：

| Sass | 默认 | Theme 字段 → resolve |
|---|---|---|
| `$radius-dropdown` | var(--semi-border-radius-medium) | radiusDropdown → theme.radius.borderRadiusMedium.value (6) |
| `$radius-dropdown_item` | 0px | radiusDropdownItem → 0 |
| `$width-dropdown` | 280px | widthDropdown → 280 |
| `$size-dropdown-icon-width` | 12px | sizeDropdownIconWidth → 12 |
| `$size-dropdown-icon-height` | 12px | sizeDropdownIconHeight → 12 |
| `$height-dropdown_seperator` | 1px | heightDropdownSeperator → 1 |
| `$font-dropdown_item_active-fontWeight` | 600 | fontDropdownItemActiveFontWeight → theme.typography.fontWeightBold (w600) |

动画 3（item 背景过渡三元组）：

| Sass | 默认 | Theme 字段 → resolve |
|---|---|---|
| `$transition_duration-dropdown_item-bg` | var(--semi-transition_duration-none) | animationDuration → Duration.zero（token 实测 0ms） |
| `$transition_function-dropdown_item-bg` | var(--semi-transition_function-easeOut) | animationCurve → Curves.easeOut（token 实测为标准 easeOut，非组件内字面 Cubic） |
| `$transition_delay-dropdown_item-bg` | 0ms | animationDelay → Duration.zero（`AnimatedContainer` 无 delay 对应物，仅留档） |

### B. widget 内部常量（10，不进主题，`_DropdownMetrics`）

| 常量 | Sass / 硬编码 | 值 | 用途 |
| --- | --- | --- | --- |
| `filterBg` | `$filter-dropdown-bg: none` | none | 上游 `backdrop-filter: none`，无滤镜 |
| `wrapperOpacityHidden` | `opacity: 0` | 0 | wrapper 隐藏态；移植由底座 FadeTransition 承担 |
| `wrapperOpacityShown` | `opacity: 1` | 1 | wrapper 显示态（`-wrapper-show`） |
| `shadowElevatedBlur` | `0 0 1px rgba(0, 0, 0, .3)` | BoxShadow(blur 1) | `@include shadow-elevated` 第一层（global.scss） |
| `shadowElevatedDrop` | `0 4px 14px rgba(0, 0, 0, .1)` | BoxShadow(0,4,blur 14) | `@include shadow-elevated` 第二层 |
| `zIndex` | `z-index: $z-dropdown` | 1050 | `$z-dropdown: 1050`（semi-theme-default/variables.scss）；`SemiDropdown.zIndex` 默认值 |
| `menuBaseFontSize` | `@include font-size-regular` | 14 | 内容字号实际实时引用 `typography.fontSizeRegular`，留档 mixin 出处 |
| `titleBaseFontSize` | `@include font-size-small` | 12 | 标题字号实际实时引用 `typography.fontSizeSmall`，留档 mixin 出处 |
| `iconWrapperMarginRight` | `margin-right: $spacing-tight` | 8 | 上游 icon 容器硬编码 8px；移植统一改用 `spacingDropdownIconMarginRight`（9，改良） |
| `overflowY` | `overflow-y: auto` | auto | wrapper 滚动（防溢出圆角），渲染为 `SingleChildScrollView` |

## 差异清单

- **全受控**：`visible` 非 null 即完全受控（交互只回调 `onVisibleChange`、内部不改态），不复刻上游半受控（web 事件会直接改内部 `popVisible`）。
- **closeOnEsc 默认 true / mouseLeaveDelay 默认 100ms**：与上游 `defaultProps` 一致（底座 `SemiTooltip` 自身默认是 `false`/50ms，Dropdown 显式覆盖）。
- **type 无默认档**：上游 `ITEM_TYPE` 只有 primary/secondary/tertiary/warning/danger 五档，`type` 为 null 时用 `colorDropdownItemTextDefault`（无 "default" 枚举档）。
- **render/menu 二选一映射**：上游 `render`（有效 React 元素）优先于 `menu`；移植改为 `content`/`menu` assert 不同时给，二者都空时渲染空弹层（与上游一致）。
- **showTick 默认可空**：上游 `Dropdown.defaultProps.showTick: false` 使 item 级 `showTick` 永远不可达；移植组级默认 null，恢复 `contextShowTick ?? showTick` 的行级覆盖语义（组级非 null 仍 context 优先）。
- **selected 不移植**：上游 `Dropdown.Item` 的 `selected` prop 无任何视觉/行为（`semi-dropdown-item-selected` 只有常量定义），不移植。
- **嵌套指针豁免**：点子菜单弹层/子菜单项不关父层（上游 document 外点判定会关闭父层，靠 item `onMouseDown` 抢跑回调兜底，移植无需兜底）；点兄弟弹层关对应父层。Flutter 命中测试下兄弟弹层的可交互区域会吸收指针（不送达父层 barrier），豁免判定覆盖穿透区域。
- **嵌套键盘缺口**：与上游一致——无跨层键盘流（无左右键开合子菜单、Esc 只关持有焦点层、父层高亮不联动）；触发器侧 ArrowUp/Down 直接聚焦菜单项未复刻。
- **filter/shadow/z 硬编码**：`$filter-dropdown-bg`（none）、shadow-elevated 两行（仅取 light 值，dark 模式不随 `--semi-shadow-elevated` 变化）、`$z-dropdown` 1050 均为 `_DropdownMetrics` 内部常量，不进主题（阴影如需动态可改读 `theme.shadows.shadowElevated`）。
- **未移植**：`className`/`style`/`contentClassName`（Dart 侧外层包裹）、`getPopupContainer`（Flutter 无 portal 容器选择）、`onEscKeyDown` 之外的事件对象参数（回调无 DOM 事件）、`forwardRef`/`onContextMenu`/`onMouseEnter`/`onMouseLeave`（hover 视觉由行自身状态驱动）、motion 传函数/对象（仅 bool）。
