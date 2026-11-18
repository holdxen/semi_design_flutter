# ChromeTab

`ChromeTab` 是一个 Chrome 风格的工作区标签栏，适合桌面应用、Web 应用和 IDE 类界面。

## 基本用法

```dart
ChromeTab(
  tabs: const [
    ChromeTabItem(id: 'home', title: '首页', closable: false),
    ChromeTabItem(id: 'docs', title: '文档'),
  ],
  activeTabId: activeTabId,
  onTabActivate: (id) => setState(() => activeTabId = id),
  onTabClose: removeTab,
  onTabAdd: addTab,
)
```

组件是受控的：`tabs`、`activeTabId`、分组和排序结果由应用保存。回调只报告用户操作，不会自动删除、排序或修改外部列表。也可以省略 `activeTabId`，此时组件会使用 `defaultActiveTabId` 并在内部维护当前选中项。

## 数据模型

- `ChromeTabItem`：`id`、`title`、`backgroundColor`、`icon`、`disabled`、`closable`。
- `ChromeTabGroup`：`id`、`name`。
- `ChromeTabReorderInfo`：拖放源标签、目标标签以及 `before`/`after` 位置。

图标使用 Flutter `Widget`，不自动解析网页 favicon。应用可以使用 `Image.asset`、`Image.network` 或 `SemiIcon` 自己提供图标。

## 回调

| 回调 | 用途 |
| --- | --- |
| `onTabActivate` | 点击或键盘激活标签 |
| `onTabEditAddress` | 双击标签 |
| `onTabClose` | 关闭按钮、Delete/Backspace |
| `onTabAdd` | 点击新增按钮 |
| `onTabReorder` | 拖放排序 |
| `onTabCloseLeft` / `onTabCloseRight` | 关闭目标左侧/右侧标签 |
| `onTabCloseOthers` | 关闭除目标外的标签 |
| `onGroupSwitch` | 切换分组 |
| `onGroupAdd` | 新建分组 |
| `onGroupRename` | 请求重命名当前分组 |
| `onGroupDelete` | 请求删除当前分组 |

## 交互

- 标签超出可用宽度时支持横向滚动和左右滚动按钮。
- 活动标签切换后会自动滚动到可见区域。
- 双击触发编辑回调；长按打开关闭操作菜单，作为触控端的右键菜单降级。
- 支持 `Draggable`/`DragTarget` 排序。
- 支持 Enter/Space 激活、箭头/Home/End 导航、Delete/Backspace 关闭。
- 标签和按钮提供 `Semantics` 标签；`Directionality` 会影响布局和键盘方向。
- `ChromeTabLocale` 支持 `zh`、`en`、`ko`；不传时根据当前 `Localizations` 的语言代码选择。

## Tooltip 与主题

`tooltipMode` 可设置为 `truncated`、`always` 或 `never`。`renderTabIcon` 和 `renderTabTooltip` 可以为单个标签返回自定义 Widget。

全局主题通过 `SemiThemeData.components.chromeTab` 配置；局部范围使用 `ChromeTabTheme`：

```dart
ChromeTabTheme(
  data: const ChromeTabThemeData(
    stripBackgroundColor: Color(0xff182230),
    tabActiveBackgroundColor: Color(0xfff9fafb),
    tabTextColor: Color(0xff98a2b3),
  ),
  child: ChromeTab(tabs: tabs, activeTabId: activeTabId),
)
```

主题数据提供标签栏尺寸、状态颜色、圆角、菜单/tooltip 表面、间距和动效时长的覆盖。它替代 Web 版本的 CSS variables 和 `::part()`。

## 与 Web 版本的差异

- Flutter 版本是原生 Widget，不依赖 DOM、Shadow DOM、Web Component 或平台插件。
- favicon、URL 和页面地址由业务层提供，不在组件内请求 `/favicon.ico`。
- 桌面右键菜单使用 Flutter 的长按/菜单路径；移动端以长按作为等价入口。
- 拖放、hover、鼠标滚轮只在平台支持时具备浏览器式体验；移动端仍可通过点击、长按和滚动使用核心功能。
- 组件不承诺浏览器 Web 版本的 CSS 像素级一致性，但保留 Chrome 标签的核心层级、状态和交互语义。
