# SemiChromeTab

`SemiChromeTab` 是 qn-chrome-tabs 1.1.0 Web Component 的 Flutter 移植：Chrome 风格的工作区标签栏，带活动页签缺口几何、宽度收缩、拖拽排序、右键批量关闭、分组菜单、溢出滚动与隐藏标签浮层、截断 tooltip。

组件是**受控**的：只渲染传入的 `tabs` / `groups` / `activeTabId` / `activeGroupId`，用户操作全部通过回调上报。组件不会自行删除、排序或修改输入列表。

```dart
SemiChromeTab(
  tabs: const <SemiChromeTabItem>[
    SemiChromeTabItem(id: 'home', title: '首页'),
    SemiChromeTabItem(id: 'docs', title: '文档'),
  ],
  activeTabId: activeTabId,
  onTabActivate: (id) => setState(() => activeTabId = id),
  onTabClose: (id) => setState(() => tabs.removeWhere((t) => t.id == id)),
  onTabAdd: addTab,
)
```

需要 `Overlay` 祖先（`SemiApp` / `Navigator` 已提供）用于分组菜单、右键菜单、tooltip 和溢出列表。

## 数据模型

```dart
class SemiChromeTabItem {
  final String id;
  final String title;
  final Color? backgroundColor; // 仅活动态生效
  final Widget? icon;           // SemiIcon / Image / 任意 Widget
}

class SemiChromeTabGroup {
  final String id;
  final String name;
}

class SemiChromeTabReorderInfo {
  final String tabId;
  final String targetTabId;
  final SemiChromeTabReorderPosition position; // before / after
}
```

`renderTabIcon` 返回非空时覆盖 `item.icon`；`renderTabTooltip` 返回 `null` 时对该标签禁用 tooltip。

## API

| 属性 | 类型 | 默认 | 说明 |
| --- | --- | --- | --- |
| `tabs` | `List<SemiChromeTabItem>` | `[]` | 当前分组内的标签 |
| `activeTabId` | `String?` | `null` | 活动标签；无匹配时不绘制活动态 |
| `groups` | `List<SemiChromeTabGroup>` | `[]` | 分组菜单数据 |
| `activeGroupId` | `String?` | `null` | 当前分组 |
| `locale` | `SemiChromeTabLocale?` | 跟随 `Localizations` | `zh` / `en` / `ko` |
| `hideAddButton` | `bool` | `false` | 隐藏 `+` |
| `hideGroupButton` | `bool` | `false` | 隐藏分组菜单触发器 |
| `hideScrollbar` | `bool` | `true` | 隐藏横向滚动条；设为 `false` 时使用当前平台的滚动条样式 |
| `layoutAnimation` | `SemiChromeTabLayoutAnimation` | `chromium` | `chromium` 使用 200ms ease-out bounds 过渡；`immediate` 立即重排 |
| `tooltipMode` | `SemiChromeTabTooltipMode` | `truncated` | `truncated` / `always` / `never` |
| `renderTabIcon` | `Widget? Function(item)` | `null` | 自定义图标 |
| `renderTabTooltip` | `Widget? Function(item)` | `null` | 自定义 tooltip 内容 |

| 回调 | 触发 |
| --- | --- |
| `onTabActivate` | 单击标签 |
| `onTabEditAddress` | 300ms 内第二次单击（浏览器 dblclick 语义） |
| `onTabClose` | 关闭按钮，**动画结束后**触发（140ms） |
| `onTabAdd` | `+` |
| `onTabReorder` | 拖放，`before` / `after` |
| `onTabCloseLeft` / `onTabCloseRight` / `onTabCloseOthers` | 右键菜单 |
| `onGroupSwitch` / `onGroupAdd` / `onGroupRename` / `onGroupDelete` | 分组菜单 |

## 行为细节

- **宽度收缩**：标签宽度 = `clamp((视口宽 - 加号槽 - 分隔线) / 标签数, minWidth, maxWidth)`，等价于 CSS `flex: 0 1 120px; min-width: 52px`；放不下时整排横向滚动。
- `immediate`：直接使用目标布局；`chromium`：tab bounds 按 ID 同步插值 left/width/height，默认 200ms `easeOut`。这是 Flutter 对 Chromium TabContainer bounds 动画的实现，不是 qn Web Component 自带的 CSS transition。
- **活动页签几何**：顶部圆角 `radius + 2`，底部两侧用二次曲线绘制外扩的凹圆角（Chrome 缺口）。
- **关闭动画**：标签内容 `scaleX 1→0.88`、透明度 `1→0`；默认 `layoutAnimation: chromium` 时，关闭标签后剩余标签的宽度和位置同时以 200ms `easeOut` bounds 动画重排。设置为 `immediate` 可恢复立即重排。`onTabClose` 仍在关闭动画结束后触发（140ms）。
- **进入动画**：新标签的 bounds 在默认 Chromium 模式下从旧位置过渡到目标位置（200ms `easeOut`），内容另以 `scaleX 0.88→1`、透明度 `0→1` 进入（160ms）。
- **拖拽**：拖起时源标签 45% 透明；目标标签按指针位于其左/右半区显示 2px accent 指示线，松手发 `onTabReorder`。
- **右键菜单**：close / closeRight / closeOthers / closeLeft，点击后关闭菜单并回调。第一次点击菜单外只关闭菜单。
- **分组菜单**：触发器 30×30；下拉 210px、右对齐、顶部偏移 34px；行悬停时右侧出现重命名/删除按钮；当前分组 accent + 600。
- **溢出**：滚动按钮 overlay 在左右两端（36px）；悬停列出该侧被裁掉的标签，点击即激活；滚轮在标签栏上转为横向滚动。
- **活动标签可见**：`activeTabId` 变化或标签集变化后，按“最近边缘”滚动到可见区，并预留圆角和控制按钮宽度。
- **加号锚定**：标签数 ≥ 5 时，点击 `+` 前记录位置，新增标签后调整滚动偏移，让 `+` 停留在原屏位置（上游用 `transform` 实现）。
- **Tooltip**：`truncated` 用 `TextPainter` 判断标题是否超出可用宽度；`always` 始终显示；`never` 关闭。hover 离开 120ms 后关闭。
- **减少动效**：`MediaQuery.disableAnimations` 为真时进入/关闭动画缩到 1ms（对应上游 `prefers-reduced-motion`）。

## 主题

CSS 变量一一对应 `SemiChromeTabThemeData`。默认值是 qn-chrome-tabs 的 Chrome 亮色，不派生自 `SemiThemeData` 色板。

| CSS 变量 | 字段 | 默认 |
| --- | --- | --- |
| `--chrome-tabs-height` | `chromeTabsHeight` | `38` |
| `--chrome-tabs-background` | `chromeTabsBackground` | `#dee1e6` |
| `--chrome-tabs-font` | `chromeTabsFontSize` | `12`（仅字号；Arial 未随包提供） |
| `--chrome-tab-min-width` | `chromeTabMinWidth` | `52` |
| `--chrome-tab-max-width` | `chromeTabMaxWidth` | `120` |
| `--chrome-tab-radius` | `chromeTabRadius` | `8` |
| `--chrome-tab-text-color` | `chromeTabTextColor` | `#5f6368` |
| `--chrome-tab-active-text-color` | `chromeTabActiveTextColor` | `#202124` |
| `--chrome-tab-hover-background` | `chromeTabHoverBackground` | `#f4f5f6` |
| `--chrome-tab-active-background` | `chromeTabActiveBackground` | `#ffffff` |
| `--chrome-tab-divider-color` | `chromeTabDividerColor` | `#aeb5c64f` |
| `--chrome-tab-close-hover-background` | `chromeTabCloseHoverBackground` | `#dadce0` |
| `--chrome-tabs-accent-color` | `chromeTabsAccentColor` | `#1a73e8` |
| `--chrome-tabs-menu-background` | `chromeTabsMenuBackground` | `#ffffff` |
| `--chrome-tabs-menu-border-color` | `chromeTabsMenuBorderColor` | `#dadce0` |
| `--chrome-tabs-menu-hover-background` | `chromeTabsMenuHoverBackground` | `#f1f3f4` |
| `--chrome-tabs-menu-text-color` | `chromeTabsMenuTextColor` | 回退 `chromeTabTextColor` |
| `--chrome-tabs-menu-icon-color` | `chromeTabsMenuIconColor` | 回退 `chromeTabTextColor` |
| `--chrome-tabs-menu-icon-background` | `chromeTabsMenuIconBackground` | `rgb(255 255 255 / 62%)` |
| `--chrome-tabs-menu-shadow` | `chromeTabsMenuShadow` | `0 6px 18px rgb(60 64 67 / 24%)` |
| `--chrome-tabs-tooltip-background` | `chromeTabsTooltipBackground` | `#ffffff` |
| `--chrome-tabs-tooltip-border-color` | `chromeTabsTooltipBorderColor` | `#dadce0` |
| `--chrome-tabs-tooltip-text-color` | `chromeTabsTooltipTextColor` | 回退 `chromeTabTextColor` |
| `--chrome-tabs-tooltip-shadow` | `chromeTabsTooltipShadow` | `0 2px 4px rgba(60,64,67,.067)` |
| `@keyframes chrome-tab-enter` | `chromeTabEnterDuration` | `160ms` |
| `@keyframes chrome-tab-close` | `chromeTabCloseDuration` | `140ms` |
| Chromium tab bounds transition | `chromeTabLayoutDuration` | `200ms easeOut`（Flutter bounds 动画增强，并非上游 Web CSS 变量） |
| tooltip `transition: left` | `chromeTabTooltipMoveDuration` | `140ms`（字段保留，移动过渡未移植） |

`chromeTabHeight` 不单独暴露：按上游 `max(--chrome-tabs-height, 28px)` 由 `resolve` 派生。

局部主题：

```dart
SemiChromeTabTheme(
  data: const SemiChromeTabThemeData(
    chromeTabsHeight: 44,
    chromeTabsBackground: Color(0xff182230),
    chromeTabTextColor: Color(0xff98a2b3),
    chromeTabActiveTextColor: Color(0xff101828),
    chromeTabHoverBackground: Color(0xff344054),
    chromeTabActiveBackground: Color(0xfff9fafb),
    chromeTabsAccentColor: Color(0xff7f56d9),
  ),
  child: SemiChromeTab(tabs: tabs, activeTabId: activeTabId),
)
```

## HARDCODES（上游 CSS 中的非变量常量）

| 值 | 来源 | 用途 |
| --- | --- | --- |
| `tab-height = max(strip-height, 28px)` | `styles.css` `--chrome-tab-height` | 标签最小高度 |
| `36px` | `.tab-scroll-button { width }` | 滚动按钮 |
| `30px / margin 0 4px` | `.new-tab-button` | 加号按钮与槽宽 38 |
| `30px / radius 9` | `.group-menu summary` | 分组触发器 |
| `34px / 210px` | `.group-dropdown { top; width }` | 分组下拉位置与宽度 |
| `6px / 8px` | `.group-dropdown`, `.tab-context-menu` | 菜单内边距、圆角 |
| `172px` | `.tab-context-menu { width }` | 右键菜单宽度 |
| `2 × 18px` | 分隔线 | tab divider / new-tab divider |
| `16px + 6px` | 图标 | 图标尺寸与间距 |
| `18px` | `.chrome-tab-close` | 关闭按钮 |
| `#e8eaed` | 菜单第一条/新建分组分隔线 | 菜单内部分隔线 |
| `120ms` | `schedulePopoverClose` | tooltip / 溢出列表关闭延迟 |
| `300ms` | 浏览器双击间隔 | 本移植用于识别 `edit-address` |

## 与 Web 版本的差异

- 原生 Widget，无 DOM / Shadow DOM / Web Component。
- `icon` 是 `Widget`；不解析 `favicon.url`、不请求 `/favicon.ico`（包内无网络层）。图片可用 `Image.network`，失败时由调用方处理。
- 拖拽反馈是 Flutter 叠层里绘制的标签幽灵，不是浏览器的拖拽快照。
- 右键菜单使用 Flutter Overlay，并加了一层点击外部关闭的屏障；第一次点击外部只关闭菜单。
- 触控端没有 hover，长按标签等同右键（打开批量关闭菜单）；这是移动端降级，上游 Web Component 只有 `contextmenu`。
- tooltip 在标签间移动时的 `left 140ms` 过渡未移植（字段仍保留）；位置会直接跳转。
- 分组菜单与右键菜单使用组件外层 `DefaultTextStyle`，上游这两处继承页面字体而非 `--chrome-tabs-font`。
- Arial 未随包提供，`chromeTabsFontSize` 只控制字号。
- `+` 按钮的 `title`（“添加标签页后，可再次打开同一个模块”）暴露为
  `Semantics.tooltip`，没有额外绘制一个视觉气泡。
- 加号锚定用滚动偏移实现，且仅在标签数 ≥ 5 时启用；上游用 `transform`，可越过滚动边界。
- 无键盘导航（上游 Web Component 也没有方向键/焦点管理）；`Semantics` 提供 role/label/selected。
- zh / en / ko 三套内置文案；默认跟随 `Localizations`，显式 `locale` 优先。
- 活动标签自动可见、滚轮横向滚动、溢出按钮和隐藏列表均已移植。
- 上游的 `prefers-reduced-motion` 已映射为 `MediaQuery.disableAnimations`。

## 使用要点

- 关闭事件在动画结束后才发出，业务删除列表后组件会立即重建；在动画期间不要并发修改同一标签。
- `activeTabId` 变化会触发“最近边缘”滚动；如果业务不希望自动滚动，保持 `activeTabId` 不变即可。
- 拖拽排序回调里的 `targetTabId` 指向拖放发生时的目标；应用需要先移除源项、再按 `before`/`after` 插入。
```