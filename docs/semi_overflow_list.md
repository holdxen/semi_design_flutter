# SemiOverflowList

折叠列表（上游 Semi OverflowList 全件移植）：行为组件——按可用宽度自适应展示尽可能多的项，放不下的项折叠为溢出元素，尺寸变化时重算。双形态：`collapse` 折叠（测量分界）/ `scroll` 滚动（横向滚动容器 + 视口相交判定）；`collapseFrom` start/end、`minVisibleItems`、`onOverflow`、`onIntersect`、`onVisibleStateChange`、`threshold`、`overflowRenderDirection`。主题对账 **0 = 0 FIELDS + 0 MOTION + 0 INTERNAL**（overflowList **没有** variables.scss/animation.scss——overflowList.scss 仅 `$module: #{$prefix}-overflow-list` 类名胶水 + 布局规则、rtl.scss 仅 `direction: rtl`，均不计；datePicker `223 = 220 + 3 + 0`、timePicker `20 = 14 + 6 + 0`、transfer `50 = 47 + 3 + 0`、anchor `30 = 26 + 4 + 0`、breadcrumb `20 = 16 + 4 + 0`、pagination `48 = 41 + 7 + 0`、tree `33 = 29 + 4 + 0`、steps `104 = 94 + 10 + 0`、upload `85 = 85 + 0 + 0`、tabs `144 = 121 + 23 + 0`、modal `81 = 63 + 18 + 0`、skeleton `17 = 15 + 2 + 0` 先例）；**0 死变量**（无声明可死；死 CSS `-spacer` 规则与死状态留档见 B 表，**上游未消费**）。上游实现参考 Blueprint `overflow-list`（index.tsx:70 出处注释 `reference to https://github.com/palantir/blueprint/blob/1aa71605/packages/core/src/components/overflow-list/overflowList.tsx#L34`）。

## API

`SemiOverflowList<T>({items: const [], itemKey, renderMode: collapse, collapseFrom: end, minVisibleItems: 0, threshold: 0.75, overflowRenderDirection: both, visibleItemRenderer, overflowRenderer, scrollOverflowRenderer, onOverflow, onIntersect, onVisibleStateChange})`。

items `List<T>`（上游 `Record<string, any>[]`，泛型化）。itemKey `String Function(T)?`——项的稳定键；缺省按下标字符串取键（上游 `get(item, itemKey || 'key', defaultKey)` 先读 `item.key` 回落下标，强类型下无属性反射，含语义键的数据请传本参数；scroll 模式要求键稳定，上游「要求必含 key 项」）。renderMode `SemiOverflowListRenderMode`（collapse/scroll）。collapseFrom `SemiOverflowListCollapseFrom`（start/end，仅 collapse）。minVisibleItems `int`（仅 collapse）。threshold `double`（仅 scroll，见「行为/滚动」触发规则）。overflowRenderDirection `SemiOverflowListOverflowRenderDirection`（both/start/end，仅 scroll；上游注释 "used in tabs, not exposed to user"，移植端照常暴露）。

visibleItemRenderer `Widget? Function(T item, int index)?`（缺省渲染空盒子）；`index` 为**可见数组内**下标（上游 `visible.map((item, idx) => ...)`——`collapseFrom: start` 时不是 items 下标）。overflowRenderer `Widget? Function(List<T> overflowItems)?`——collapse 形态（缺省不渲染）。scrollOverflowRenderer `List<Widget>? Function(List<T> startOverflow, List<T> endOverflow)?`——scroll 形态，返回 `[起点节点, 终点节点]`（上游收 `[[起点溢出项], [终点溢出项]]` 二元数组、返回二元节点数组，移植端展开成两个参数与定长返回；缺省不渲染）。onOverflow `void Function(List<T>)?`（仅 collapse）。onIntersect `void Function(Map<String, SemiOverflowListIntersectEntry>)?`（仅 scroll，只含变化条目）。onVisibleStateChange `void Function(Map<String, bool>)?`（仅 scroll，全量 Map）。

`SemiOverflowListIntersectEntry({key, isIntersecting, intersectionRatio, boundingClientRect, intersectionRect, rootBounds})`——上游 `IntersectionObserverEntry` 的 Flutter 对应；矩形为全局逻辑像素（上游 `getBoundingClientRect` 视口坐标）；`isIntersecting` 含贴边零面积相交（W3C edge-adjacent），零面积项相交时 `intersectionRatio` 记 1。

## 行为

### 折叠（collapse）

测量驱动两段式（foundation.handleCollapseOverflow:129-176）：把可见项与溢出节点各包一层测量 wrapper（对应上游 ResizeObserver + `div.-item`/`div.-overflow`，wrapper 无样式，仅取宽与元素身份），从**折叠侧**累计宽度——起点为溢出节点宽 `overflowWidth`，逐项加宽，累计超过 `containerWidth` 即折（`if (itemWidths > containerWidth)`，严格大于）；`pivot = Math.max(minVisibleItems, 放得下的项数)`，可见 = 折叠侧留 pivot 项、其余进溢出。全部放下（遍历到末项仍未超）→ 全量可见、溢出清空，`lastOverflowCount ≠ 0` 时补 `onOverflow([])`；溢出分支仅在 pivot 或溢出数量变化时 `onOverflow(overflow)`。items 变化把 `lastOverflowCount` 重置为 -1（`newState.lastOverflowCount = props.renderMode === RenderMode.SCROLL ? 0 : -1`）——数量不变也强制补发一次。

重算前按上界猜测渲染：`min(items.length, floor(containerWidth / 4))` 项（`MINIMUM_HTML_ELEMENT_WIDTH: 4`，HTML 元素最小宽度假设），首帧 containerWidth 未知时全量测量。猜测期 `visibility: overflowStatus === "calculating" && this.state.pivot < 0`（首帧隐藏防闪）；`maxWidth: 100%`。溢出节点宽度参与公式（"+N" 自身占位），宽度变化即重算；子项被收缩后按收缩宽重测（同上游 clientWidth 反馈）。★边界 quirk（照抄）：测量项累计恰好等于容器宽且仍有未渲染项时（严格大于判定）不触发折叠也不触发全量——停在 calculating（隐藏），依赖后续尺寸事件打破。

### 滚动（scroll）

全部项进 `-scroll-wrapper`（`flex: 1` 横向滚动容器，`overflow-x: scroll`——滚动条不隐藏，tabs.scss 的隐藏规则只管 Tabs 场景）。可见性 = 项与滚动视口相交（含贴边零面积，闭区间判定）：首/末可见项之外的项组成 `[起点溢出, 终点溢出]`（`items.slice(0, visibleStart)` / `items.slice(visibleEnd + 1, items.length)`），经 `scrollOverflowRenderer(startItems, endItems)` 渲染成两个节点，按 `overflowRenderDirection` 摆放：both `[起点, 滚动容器, 终点]`、start `[起点, 终点, 滚动容器]`、end `[滚动容器, 起点, 终点]`（上游 `arrowPosition` 语义——箭头对聚在哪侧）。

触发规则对应 IntersectionObserver `threshold`（缺省 0.75）：**阈值索引（ratio ≥ threshold）跨越或 isIntersecting 翻转**才产生条目，条目批量回调——`onIntersect` 只收变化项，`onVisibleStateChange` 收合并后的全量 Map（上游 updateVisibleState → 同步缓存 → notifyIntersect 顺序）。threshold 变化重建观察器（重新 observe，全部条目补发一次）。visibleState 为空或全不可见时回退 `scrollOverflow` 缓存（items 变化按键对齐缓存、剔除移除项，避免菜单闪烁）；无可见项不作数（同上游）。滚动/布局变化重算。

### 键与回调

键统一按 `itemKey`/下标解析（差异清单第 4 条）。onOverflow 仅 collapse；onIntersect/onVisibleStateChange 仅 scroll。受控/非受控等状态管理不适用（纯计算组件）。

## 主题（0 对账）

来源 packages/semi-foundation/overflowList/：**无 variables.scss、无 animation.scss**。overflowList.scss 20 行 = `$module` 胶水 1 行 + 布局规则 + 死 `-spacer` 规则；rtl.scss 仅 `direction: rtl`。对账 **0 = 0 FIELDS + 0 MOTION + 0 INTERNAL**（0 声明进主题；`$module` 类名胶水、布局规则与 rtl 规则不计——tabs `$module`/`$ignoreIcon` 胶水不计先例）。`SemiOverflowList` 不消费任何主题 token，无 `SemiOverflowListThemeData`（tool/generate_overflow_list.py 记录空清单并断言不生成主题文件，tool/test_generate_overflow_list.py 逐项核对）。

### A. Sass 声明映射（0 FIELDS + 0 MOTION）

无映射条目——上游零 token 声明。非 token 声明（不计）：

| Sass 声明 / 规则 | 去向 | 说明 |
|---|---|---|
| `$module: #{$prefix}-overflow-list` | 不计 | 类名胶水（overflowList.scss:1、rtl.scss:1） |
| `display: flex` / `flex-wrap: nowrap` / `min-width: 0` | 布局 | 根容器（overflowList.scss:3-6）→ Row |
| `&-spacer { flex-shrink: 1; width: 1px; }` | 不计 | ★死 CSS（上游未消费，index.tsx:213 仅存 `spacer` 成员） |
| `&-scroll-wrapper { display: flex; flex: 1; flex-wrap: nowrap; overflow-x: scroll; }` | 布局 | scroll 容器（overflowList.scss:12-17）→ SingleChildScrollView |
| `direction: rtl` | 不计 | rtl.scss → Flutter Directionality |

### B. HARDCODES 另列（widget 文件头注释 / 调用点，源内含原始片段）

| 上游片段 | 说明 |
|---|---|
| overflowList.scss:3-6 `display: flex`、`flex-wrap: nowrap`、`min-width: 0` | 根布局 |
| overflowList.scss:7-10 `flex-shrink: 1`、`width: 1px` | `-spacer` 死规则（上游未消费） |
| overflowList.scss:14/16 `flex: 1`、`overflow-x: scroll` | scroll wrapper |
| rtl.scss `direction: rtl` | RTL |
| constants.ts:35 `MINIMUM_HTML_ELEMENT_WIDTH: 4` | 测量上界除数 |
| index.tsx:74-84 `threshold: 0.75`、`minVisibleItems: 0`、`collapseFrom: 'end'`、`renderMode: 'collapse'`、`overflowRenderDirection: "both"` | defaultProps |
| index.tsx:376-378 `maxWidth: '100%'`、`visibility: overflowStatus === "calculating" && this.state.pivot < 0` | collapse 根样式 |
| index.tsx:141 `newState.lastOverflowCount = props.renderMode === RenderMode.SCROLL ? 0 : -1` | items 变化强制补发 |
| foundation.ts:137 `if (itemWidths > containerWidth)` | 折叠触发（严格大于） |
| foundation.ts:143 `if (_pivot === items.length - 1)` | 全量放下判定 |
| foundation.ts:159 `Math.max(minVisibleItems, _pivot)` | 最小可见钳制 |
| foundation.ts:39-57 `scrollOverflow` 缓存回退 | 无可视项保留旧结果 |
| foundation.ts:60-61 `items.slice(0, visibleStart)`、`items.slice(visibleEnd + 1, items.length)` | 滚动溢出切片 |
| foundation.ts:114 `previousY` | 垂直滚出跳过 quirk（DOM 视口裁剪专属，不适用） |
| index.tsx:285 `get(item, itemKey || 'key', defaultKey)` | 缺省键解析 |
| index.tsx:333 `'data-scrollkey'` | 按渲染元素 React key 查表 quirk |
| `isScrollOverflowCalculating`、`direction` / `OverflowDirection.GROW`、`direction: PropTypes.oneOf(strings.POSITION_SET)`、`strings.OVERFLOW_DIR` | ★死状态 / 死声明（只写不读或接口缺失，留档不消费） |
| index.tsx:70 blueprint 出处注释 `reference to https://github.com/palantir/blueprint/blob/1aa71605/packages/core/src/components/overflow-list/overflowList.tsx#L34` | 组件出处 |

## 差异清单

- **零 sass 变量**：上游 overflowList 无任何 token 声明，纯 CSS flex 布局（对账 `0 = 0 FIELDS + 0 MOTION + 0 INTERNAL`）；移植端以 Row / SingleChildScrollView 复现布局规则。
- 上游 `className`/`style`/`wrapperClassName`/`wrapperStyle` 直通属性未移植（Flutter 由外层控制）；`needUpdate('style')` 触发重置的语义随之下线。
- React ref 机制（`mergeRef`/`itemRefs`/refCleanup 行为）未移植（React-ism）；测量走 Flutter RenderObject（每布局上报）。
- **键解析统一**：上游 scroll 模式按渲染元素 React key（`data-scrollkey`）与 `item.key` 字面量查表（foundation.ts:46 解构），与 `itemKey` 不一致时可见性查不到（只写缓存回退）；移植端统一按 `itemKey`/下标解析（等价于上游 itemKey 一致用法）。
- visibleState 判定 = 几何相交或贴边（W3C `isIntersecting`）；`threshold` 只影响条目触发时机（阈值索引跨越或 isIntersecting 翻转），不改变判定——同上游 IntersectionObserver 语义。
- `previousY` 垂直滚出跳过 quirk 不适用：DOM 的 root 被文档视口裁剪才产生「整列表滚出 → 全 false」假象，Flutter 滚动容器不做视口级裁剪。
- 测量遍历序：上游按 `itemSizeMap` 插入序（collapseFrom=start 首帧反序渲染形成反序插入）；移植端按折叠侧 items 序遍历（全量测量时等价；未测量项瞬态跳过行为不同）。items 变更后上游可能以旧测量宽出一帧中间态再修正（React 批内提交不绘制），移植端测量到位后一次收敛。
- `minVisibleItems` 强保超宽时：上游 flex 子项 `min-width: auto`（min-content 下限）典型不收缩、整行画出容器外（`overflow: visible`）；移植端以 OverflowBox 放行有界轴子项约束复现（子项保持固有宽、整行画出容器外、无 debug 溢出条/断言）。
- `onIntersect` 条目为 `SemiOverflowListIntersectEntry`（全局逻辑像素矩形），非 DOM `IntersectionObserverEntry`；`onIntersect`/`onVisibleStateChange` 在状态提交后同步回调（上游 setState 回调）。
- scroll 模式 `visibleItemRenderer` 缺省时上游 `React.cloneElement(null)` 直接抛错（实际要求必传）；移植端渲染空盒子，不崩。
- 死状态/死声明未移植：`isScrollOverflowCalculating`、`direction`/`strings.OVERFLOW_DIR`/`POSITION_SET`、propTypes `direction`、`-spacer` 死 CSS（上游未消费）。

## 用法

间隔约定（上游示例同）：间隔统一由可见项的 `right: 8` 提供（renderItem `marginRight: 8`），溢出节点**不自带朝内边距**——尾部折叠时溢出节点跟在末项的 right 8 之后即 8px 间隔；头部折叠（`collapseFrom: start`）时溢出节点在行首，需自带 `right: 8` 与后随项隔开。不要给溢出节点再加朝内 padding，否则该处间隔翻倍。

```dart
// 折叠（默认）：放不下的项折叠成 "+N"
SemiOverflowList<String>(
  items: const ['alarm', 'bookmark', 'camera', 'duration', 'edit', 'folder'],
  overflowRenderer: (items) => items.isEmpty
      ? null
      : Text('+${items.length}'),
  visibleItemRenderer: (item, index) => Padding(
    padding: const EdgeInsets.only(right: 8),
    child: Text(item),
  ),
)
```

```dart
// collapseFrom: start —— 头部折叠，保留尾部项
SemiOverflowList<String>(
  items: names,
  collapseFrom: SemiOverflowListCollapseFrom.start,
  overflowRenderer: (items) => Padding(
    padding: const EdgeInsets.only(right: 8),
    child: Text('+${items.length}'),
  ),
  visibleItemRenderer: (item, index) => Padding(
    padding: const EdgeInsets.only(right: 8),
    child: Text(item),
  ),
)
```

```dart
// 滚动模式：横向滚动，视口外的项进两端菜单（箭头对聚在 both/start/end）
SemiOverflowList<String>(
  items: names,
  renderMode: SemiOverflowListRenderMode.scroll,
  overflowRenderDirection: SemiOverflowListOverflowRenderDirection.both,
  scrollOverflowRenderer: (start, end) => [
    Padding(
      padding: const EdgeInsets.only(right: 8),
      child: Text('← ${start.length}'),
    ),
    Padding(
      padding: const EdgeInsets.only(left: 8),
      child: Text('${end.length} →'),
    ),
  ],
  visibleItemRenderer: (item, index) => Padding(
    padding: const EdgeInsets.only(right: 8),
    child: Text(item),
  ),
  onVisibleStateChange: (state) => debugPrint('$state'),
)
```

需要稳定键时传 `itemKey`（scroll 模式必传语义键）：`itemKey: (item) => item.id`。
