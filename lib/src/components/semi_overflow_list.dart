// SemiOverflowList — 上游 packages/semi-ui/overflowList/{index.tsx,intersectionObserver.tsx}
// 与 packages/semi-foundation/overflowList/{foundation.ts,overflowList.scss,rtl.scss} 的移植。
//
// 主题对账 **0 = 0 FIELDS + 0 MOTION + 0 INTERNAL**（overflowList 没有
// variables.scss/animation.scss —— overflowList.scss 仅 `$module: #{$prefix}-overflow-list`
// 类名胶水与布局规则、rtl.scss 仅 `direction: rtl`，均不计；tabs `144 = 121 + 23 + 0`、
// modal `81 = 63 + 18 + 0`、skeleton `17 = 15 + 2 + 0` 先例）。0 死变量（无声明可死）。
//
// HARDCODES（另列，生成器锚点逐字留档）：
// - overflowList.scss:3-6 根布局 `display: flex`、`flex-wrap: nowrap`、`min-width: 0`
// - overflowList.scss:7-10 `-spacer` 规则 `flex-shrink: 1`、`width: 1px`
//   （★上游未消费 —— index.tsx:213 仅存 `spacer` 成员，渲染端无引用）
// - overflowList.scss:12-17 `-scroll-wrapper` `flex: 1`、`overflow-x: scroll`
// - rtl.scss `direction: rtl`
// - constants.ts:35 `MINIMUM_HTML_ELEMENT_WIDTH: 4`
// - index.tsx:74-84 defaultProps `threshold: 0.75`、`minVisibleItems: 0`、
//   `collapseFrom: 'end'`、`renderMode: 'collapse'`、`overflowRenderDirection: "both"`
// - index.tsx:376-378 collapse 根样式 `maxWidth: '100%'` 与
//   `visibility: overflowStatus === "calculating" && this.state.pivot < 0`
// - index.tsx:141 `newState.lastOverflowCount = props.renderMode === RenderMode.SCROLL ? 0 : -1`
// - foundation.ts:137 `if (itemWidths > containerWidth)`
// - foundation.ts:143 `if (_pivot === items.length - 1)`
// - foundation.ts:159 `Math.max(minVisibleItems, _pivot)`
// - foundation.ts:39-57 visibleState 为空 / 无可见项时回退 `scrollOverflow` 缓存
// - foundation.ts:60-61 `items.slice(0, visibleStart)` / `items.slice(visibleEnd + 1, items.length)`
// - foundation.ts:114 `previousY` 垂直滚出跳过 quirk（DOM 视口裁剪专属，见 docs 差异清单）
// - index.tsx:285 `get(item, itemKey || 'key', defaultKey)` 缺省键解析
// - index.tsx:333 `'data-scrollkey'` 按渲染元素 React key 查表 quirk（见 docs 差异清单）
// - ★死状态 / 死声明（留档不消费）：`isScrollOverflowCalculating`（只写不读）、
//   `direction` / `OverflowDirection.GROW`（只写不读）、propTypes
//   `direction: PropTypes.oneOf(strings.POSITION_SET)`（props 接口无此 prop）、
//   `strings.OVERFLOW_DIR` / `strings.POSITION_SET`
// - index.tsx:70 blueprint 出处注释
//   `reference to https://github.com/palantir/blueprint/blob/1aa71605/packages/core/src/components/overflow-list/overflowList.tsx#L34`
import 'dart:math' as math;

import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

/// 渲染模式（上游 `renderMode`，缺省 `collapse`）。
enum SemiOverflowListRenderMode {
  /// 测量后把放不下的项折叠给 `overflowRenderer`（上游 `'collapse'`）。
  collapse,

  /// 全部渲染进横向滚动容器，视口外的项折叠给 `scrollOverflowRenderer`
  ///（上游 `'scroll'`）。
  scroll,
}

/// 折叠方向（上游 `collapseFrom`，缺省 `end`）。
enum SemiOverflowListCollapseFrom {
  /// 头部开始折叠：保留尾部可见项（上游 `'start'`）。
  start,

  /// 尾部开始折叠：保留头部可见项（上游 `'end'`）。
  end,
}

/// scroll 模式两个溢出节点的摆放位置（上游 `overflowRenderDirection`，缺省
/// `both`；上游注释标注 "used in tabs, not exposed to user"，移植端照常暴露）。
enum SemiOverflowListOverflowRenderDirection {
  /// `[起点溢出, 滚动容器, 终点溢出]`（上游 `"both"`）。
  both,

  /// `[起点溢出, 终点溢出, 滚动容器]`（上游 `"start"`，箭头对聚在起点侧）。
  start,

  /// `[滚动容器, 起点溢出, 终点溢出]`（上游 `"end"`，箭头对聚在终点侧）。
  end,
}

/// scroll 模式相交条目（上游 `IntersectionObserverEntry` 的 Flutter 对应）。
///
/// 矩形均为 Flutter 全局逻辑像素（上游 `getBoundingClientRect` 为视口坐标）。
class SemiOverflowListIntersectEntry {
  const SemiOverflowListIntersectEntry({
    required this.key,
    required this.isIntersecting,
    required this.intersectionRatio,
    required this.boundingClientRect,
    required this.intersectionRect,
    required this.rootBounds,
  });

  /// 项的解析键（上游 `data-scrollkey`）。
  final String key;

  /// 是否与滚动视口相交（含贴边零面积相交，上游 `entry.isIntersecting`）。
  final bool isIntersecting;

  /// 相交面积 / 项面积（零面积项相交时记 1，上游 `entry.intersectionRatio`）。
  final double intersectionRatio;

  /// 项矩形（上游 `entry.boundingClientRect`）。
  final Rect boundingClientRect;

  /// 相交矩形（可能零面积，上游 `entry.intersectionRect`）。
  final Rect intersectionRect;

  /// 滚动视口矩形（上游 `entry.rootBounds`，root = scroll wrapper）。
  final Rect rootBounds;
}

/// 折叠列表（行为组件）：按可用宽度自适应展示尽可能多的项，放不下的项折叠为
/// 一个溢出元素；尺寸变化时重新计算可见项。
///
/// 上游实现参考 Blueprint `overflow-list`（index.tsx:70 出处注释
/// `reference to https://github.com/palantir/blueprint/blob/1aa71605/packages/core/src/components/overflow-list/overflowList.tsx#L34`）。
class SemiOverflowList<T> extends StatefulWidget {
  const SemiOverflowList({
    super.key,
    this.items = const [],
    this.itemKey,
    this.renderMode = SemiOverflowListRenderMode.collapse,
    this.collapseFrom = SemiOverflowListCollapseFrom.end,
    this.minVisibleItems = 0,
    this.threshold = 0.75,
    this.overflowRenderDirection = SemiOverflowListOverflowRenderDirection.both,
    this.visibleItemRenderer,
    this.overflowRenderer,
    this.scrollOverflowRenderer,
    this.onOverflow,
    this.onIntersect,
    this.onVisibleStateChange,
  });

  /// 渲染项目（上游 `items`，缺省 `[]`）。
  final List<T> items;

  /// 项的稳定键解析（上游 `itemKey`）。
  ///
  /// 缺省按下标字符串取键（上游 `get(item, itemKey || 'key', defaultKey)`
  /// 先读 `item.key` 回落下标；强类型下无属性反射，含语义键的数据请传本参数）。
  /// scroll 模式要求键稳定（上游 "要求必含 key 项"）。
  final String Function(T item)? itemKey;

  /// 渲染模式（缺省 `collapse`）。
  final SemiOverflowListRenderMode renderMode;

  /// 折叠方向（仅 `collapse` 模式，缺省 `end`）。
  final SemiOverflowListCollapseFrom collapseFrom;

  /// 最少保留的可见项数（仅 `collapse` 模式，缺省 0；超宽时子项等比收缩）。
  final int minVisibleItems;

  /// 相交阈值（仅 `scroll` 模式，缺省 0.75）。
  ///
  /// 上游为 IntersectionObserver `threshold`，只影响回调触发时机（阈值索引
  /// 跨越或 isIntersecting 翻转才通知），不改变可见性判定；移植端按同一
  /// 触发规则产生 [SemiOverflowListIntersectEntry]。
  final double threshold;

  /// scroll 模式溢出节点摆放位置（缺省 `both`）。
  final SemiOverflowListOverflowRenderDirection overflowRenderDirection;

  /// 可见项渲染（上游 `visibleItemRenderer`，缺省渲染空盒子）。
  ///
  /// `index` 为可见数组内下标（上游 `visible.map((item, idx) => ...)` ——
  /// `collapseFrom: start` 时不是 items 下标）。
  final Widget? Function(T item, int index)? visibleItemRenderer;

  /// collapse 模式溢出渲染（上游 `overflowRenderer` 的 collapse 形态，缺省
  /// 不渲染）。
  final Widget? Function(List<T> overflowItems)? overflowRenderer;

  /// scroll 模式溢出渲染（上游 `overflowRenderer` 的 scroll 形态，返回
  /// `[起点节点, 终点节点]`，缺省不渲染）。
  ///
  /// 上游签名收 `[[起点溢出项], [终点溢出项]]` 二元数组、返回二元节点数组；
  /// 移植端展开成两个参数与定长返回。
  final List<Widget>? Function(List<T> startOverflow, List<T> endOverflow)?
  scrollOverflowRenderer;

  /// 溢出回调（仅 `collapse` 模式，上游 `onOverflow`）。
  ///
  /// 溢出数量或 pivot 变化时触发；items 变化后强制补发一次（上游
  /// `lastOverflowCount` 重置为 -1）。
  final void Function(List<T> overflowItems)? onOverflow;

  /// 相交回调（仅 `scroll` 模式，上游 `onIntersect`）。
  ///
  /// 仅携带本次发生变化的条目（上游 IntersectionObserver 批量回调）。
  final void Function(Map<String, SemiOverflowListIntersectEntry> entries)?
  onIntersect;

  /// 可见状态变化回调（仅 `scroll` 模式，上游 `onVisibleStateChange`）。
  final void Function(Map<String, bool> visibleState)? onVisibleStateChange;

  @override
  State<SemiOverflowList<T>> createState() => _SemiOverflowListState<T>();
}

/// 上游 `overflowStatus`（index.tsx:58）。
enum _OverflowStatus {
  /// 重算中（index.tsx:378 `overflowStatus === "calculating"`）。
  calculating,
  overflowed,
  normal,
}

class _SemiOverflowListState<T> extends State<SemiOverflowList<T>> {
  // —— collapse 状态（index.tsx:46-68 / foundation.handleCollapseOverflow）——
  _OverflowStatus _overflowStatus = _OverflowStatus.calculating;
  List<int> _visibleIndices = const [];
  final Map<String, double> _itemSizeMap = <String, double>{};
  double _containerWidth = 0;
  double _overflowWidth = 0;
  int _pivot = -1;
  int _lastOverflowCount = 0;
  int _maxCount = 0;

  // —— scroll 状态（foundation.getOverflowItem / _syncScrollOverflowCache）——
  Map<String, bool> _visibleState = const {};
  List<List<T>> _scrollOverflow = const [[], []];
  final Map<String, _SemiOverflowMeasureBox> _boxes =
      <String, _SemiOverflowMeasureBox>{};
  final Map<String, _PrevIntersect> _prevIntersect = <String, _PrevIntersect>{};

  bool _computePending = false;
  bool _visibilityPending = false;
  bool _settleScheduled = false;

  /// 上游 `MINIMUM_HTML_ELEMENT_WIDTH: 4`（constants.ts:35）—— HTML 元素最小
  /// 宽度假设，把重算时的测量上界压到 `containerWidth / 4`。
  static const double _minimumHtmlElementWidth = 4;

  bool get _isScrollMode =>
      widget.renderMode == SemiOverflowListRenderMode.scroll;

  List<T> get _overflowItems {
    final visible = _visibleIndices.toSet();
    return [
      for (var i = 0; i < widget.items.length; i++)
        if (!visible.contains(i)) widget.items[i],
    ];
  }

  @override
  void initState() {
    super.initState();
    _resetForChangedInputs();
  }

  @override
  void didUpdateWidget(SemiOverflowList<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    final itemsChanged = !_listEquals(oldWidget.items, widget.items);
    final modeChanged = oldWidget.renderMode != widget.renderMode;
    if (itemsChanged || modeChanged) {
      _resetForChangedInputs(
        oldItems: oldWidget.items,
        itemsChanged: itemsChanged,
        keysChanged: itemsChanged && !_keysEqual(oldWidget.items, widget.items),
      );
    }
    if (oldWidget.threshold != widget.threshold && _isScrollMode) {
      // 上游 threshold 变化会重建 IntersectionObserver 并重新 observe ——
      // 初始回调覆盖全部条目（intersectionObserver.tsx:52-58）。
      _prevIntersect.clear();
      _scheduleVisibility();
    }
    if (itemsChanged || modeChanged) {
      if (_isScrollMode) {
        _scheduleVisibility();
      } else {
        _scheduleCompute();
      }
    }
  }

  /// 上游 getDerivedStateFromProps（index.tsx:128-190）的重置逻辑 +
  /// componentDidUpdate（index.tsx:224-246）的键变更清理。
  void _resetForChangedInputs({
    List<T>? oldItems,
    bool itemsChanged = true,
    bool keysChanged = false,
  }) {
    _lastOverflowCount = _isScrollMode ? 0 : -1;
    _maxCount = 0;
    _pivot = -1;
    _overflowStatus = _OverflowStatus.calculating;
    if (_isScrollMode) {
      if (itemsChanged && oldItems != null) {
        _scrollOverflow = _remapScrollCache(oldItems);
      }
      if (keysChanged) {
        // 上游 componentDidUpdate:233-238 —— 键变更清空可见状态与尺寸缓存，
        // 保留 scrollOverflow 缓存避免闪烁。
        _visibleState = const {};
        _itemSizeMap.clear();
        _prevIntersect.clear();
      }
      return;
    }
    // collapse：先按上界猜测可见集（index.tsx:171-186，猜测序取折叠侧）。
    var maxCount = widget.items.length;
    if ((_containerWidth / _minimumHtmlElementWidth).floor() != 0) {
      maxCount = math.min(
        maxCount,
        (_containerWidth / _minimumHtmlElementWidth).floor(),
      );
    }
    _maxCount = maxCount;
    final n = widget.items.length;
    final isStart = widget.collapseFrom == SemiOverflowListCollapseFrom.start;
    _visibleIndices = isStart
        ? [for (var i = math.max(0, n - maxCount); i < n; i++) i]
        : [for (var i = 0; i < math.min(maxCount, n); i++) i];
    if (keysChanged) _itemSizeMap.clear();
  }

  /// 上游 getDerivedStateFromProps:149-170 —— items 变化时按键对齐
  /// scrollOverflow 缓存（剔除已移除项）。
  List<List<T>> _remapScrollCache(List<T> oldItems) {
    final cache = _scrollOverflow;
    if (cache.length != 2) return const [[], []];
    List<T> align(List<T> list) {
      final out = <T>[];
      for (var i = 0; i < list.length; i++) {
        final item = list[i];
        final oldIndex = oldItems.indexOf(item);
        final key = _keyOf(oldIndex < 0 ? i : oldIndex, item);
        for (var j = 0; j < widget.items.length; j++) {
          if (_keyOf(j, widget.items[j]) == key) {
            out.add(widget.items[j]);
            break;
          }
        }
      }
      return out;
    }

    return [align(cache[0]), align(cache[1])];
  }

  String _keyOf(int index, T item) => widget.itemKey?.call(item) ?? '$index';

  bool _keysEqual(List<T> a, List<T> b) {
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (_keyOf(i, a[i]) != _keyOf(i, b[i])) return false;
    }
    return true;
  }

  // -- 测量与调度 ------------------------------------------------------------

  void _scheduleCompute() {
    _computePending = true;
    _scheduleSettle();
  }

  void _scheduleVisibility() {
    _visibilityPending = true;
    _scheduleSettle();
  }

  void _scheduleSettle() {
    if (_settleScheduled) return;
    _settleScheduled = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _settleScheduled = false;
      if (!mounted) return;
      if (_computePending) {
        _computePending = false;
        if (!_isScrollMode && _overflowStatus == _OverflowStatus.calculating) {
          // 上游 componentDidUpdate:242-245 —— 仅 calculating 时计算。
          _handleCollapseOverflow();
        }
      }
      if (_visibilityPending) {
        _visibilityPending = false;
        if (_isScrollMode) _updateScrollVisibility();
      }
    });
  }

  /// 上游 index.tsx:387-407 `onItemResize` —— 首测登记；宽度变化或
  /// `itemSizeMap.size === maxCount`（"已经按照最大值maxCount渲染完毕，触发
  /// 真正的渲染"）时置 calculating 重算。
  void _onItemLayout(String key, Size size) {
    final width = size.width;
    final stored = _itemSizeMap[key];
    if (stored == null || stored == 0) {
      _itemSizeMap[key] = width;
      if (_itemSizeMap.length == _maxCount) _scheduleCompute();
    } else if (stored != width) {
      // 某个 item 发生 resize 后，重新计算。
      _itemSizeMap[key] = width;
      _scheduleCompute();
    }
    if (_isScrollMode) _scheduleVisibility();
  }

  /// 上游 index.tsx:304-310 —— 溢出节点宽度进 `overflowWidth` 并置
  /// calculating 重算。
  void _onOverflowLayout(Size size) {
    if (_overflowWidth != size.width) {
      _overflowWidth = size.width;
      _scheduleCompute();
    }
  }

  /// 上游 index.tsx:248-254 `resize`（容器 ResizeObserver）。
  void _syncContainerWidth(double width) {
    if (_containerWidth != width) {
      _containerWidth = width;
      _scheduleCompute();
    }
  }

  // -- collapse 算法（foundation.handleCollapseOverflow:129-176）------------

  void _handleCollapseOverflow() {
    final items = widget.items;
    final n = items.length;
    final isStart = widget.collapseFrom == SemiOverflowListCollapseFrom.start;
    var itemWidths = _overflowWidth;
    var fitted = 0;
    var overflowed = false;
    // 上游按 itemSizeMap 插入序遍历测量宽度；按折叠侧 items 序遍历等价
    // （差异清单）。未测量项跳过（等价上游 map 无此项）。
    for (var step = 0; step < n; step++) {
      final index = isStart ? n - 1 - step : step;
      final size = _itemSizeMap[_keyOf(index, items[index])];
      if (size == null) continue;
      itemWidths += size;
      // 触发 overflow。
      if (itemWidths > _containerWidth) {
        overflowed = true;
        break;
      }
      // 顺利遍历完整个列表，说明不存在 overflow，直接渲染全部。
      if (fitted == n - 1) {
        final notify = _lastOverflowCount != 0;
        setState(() {
          _overflowStatus = _OverflowStatus.normal;
          _pivot = n - 1;
          _visibleIndices = [for (var i = 0; i < n; i++) i];
          _lastOverflowCount = 0;
        });
        if (notify) widget.onOverflow?.call(const []);
        return;
      }
      fitted++;
    }
    if (!overflowed) return;
    final pivot = math.max(widget.minVisibleItems, fitted);
    final visibleFrom = isStart ? math.max(0, n - pivot) : 0;
    final visibleTo = isStart ? n : math.min(pivot, n);
    final overflow = [
      for (var i = 0; i < n; i++)
        if (i < visibleFrom || i >= visibleTo) items[i],
    ];
    final notify = _pivot != pivot || _lastOverflowCount != overflow.length;
    setState(() {
      _overflowStatus = _OverflowStatus.overflowed;
      _pivot = pivot;
      _visibleIndices = [for (var i = visibleFrom; i < visibleTo; i++) i];
      _lastOverflowCount = overflow.length;
    });
    if (notify) widget.onOverflow?.call(overflow);
  }

  // -- scroll 可见性（intersectionObserver + foundation.handleIntersect）----

  /// 上游 `isIntersecting`（W3C：相交或贴边零面积）+ `intersectionRatio`
  /// （零面积相交记 1）+ 阈值索引（thresholds = [threshold]）。
  void _updateScrollVisibility() {
    final scroller = _boxes['__scroller'];
    if (scroller == null || !scroller.attached) return;
    final rootBounds = scroller.globalRect;
    final entries = <String, SemiOverflowListIntersectEntry>{};
    final nextVisibleState = Map<String, bool>.of(_visibleState);
    for (var i = 0; i < widget.items.length; i++) {
      final item = widget.items[i];
      final key = _keyOf(i, item);
      final box = _boxes[key];
      if (box == null || !box.attached) continue;
      final rect = box.globalRect;
      final intersectRect = rect.intersect(rootBounds);
      // 贴边（零面积）也算相交 —— 闭区间判定（W3C edge-adjacent quirk）。
      final isIntersecting =
          rect.right >= rootBounds.left &&
          rect.left <= rootBounds.right &&
          rect.bottom >= rootBounds.top &&
          rect.top <= rootBounds.bottom;
      final ratio = rect.width * rect.height == 0
          ? (isIntersecting ? 1.0 : 0.0)
          : (intersectRect.width * intersectRect.height) /
                (rect.width * rect.height);
      final thresholdIndex = ratio >= widget.threshold ? 1 : 0;
      final prev = _prevIntersect[key];
      final changed =
          prev == null ||
          prev.thresholdIndex != thresholdIndex ||
          prev.isIntersecting != isIntersecting;
      if (changed) {
        _prevIntersect[key] = _PrevIntersect(thresholdIndex, isIntersecting);
        nextVisibleState[key] = isIntersecting;
        entries[key] = SemiOverflowListIntersectEntry(
          key: key,
          isIntersecting: isIntersecting,
          intersectionRatio: ratio,
          boundingClientRect: rect,
          intersectionRect: intersectRect,
          rootBounds: rootBounds,
        );
      }
    }
    if (entries.isEmpty) return;
    // 上游 handleIntersect:91-123 —— updateVisibleState → 同步缓存 →
    // notifyIntersect。
    setState(() {
      _visibleState = nextVisibleState;
      _scrollOverflow = _syncScrollOverflowCache(nextVisibleState);
    });
    widget.onVisibleStateChange?.call(Map<String, bool>.of(nextVisibleState));
    widget.onIntersect?.call(entries);
  }

  /// 上游 foundation._syncScrollOverflowCache:65-89 —— 无可视项时保留缓存。
  List<List<T>> _syncScrollOverflowCache(Map<String, bool> visibleState) {
    final items = widget.items;
    final flags = [
      for (var i = 0; i < items.length; i++)
        visibleState[_keyOf(i, items[i])] == true,
    ];
    final visibleStart = flags.indexOf(true);
    final visibleEnd = flags.lastIndexOf(true);
    if (visibleStart < 0 || visibleEnd < 0) return _scrollOverflow;
    return [items.sublist(0, visibleStart), items.sublist(visibleEnd + 1)];
  }

  /// 上游 foundation.getOverflowItem:29-63 —— visibleState 为空或无可见项时
  /// 回退 scrollOverflow 缓存。
  List<List<T>> _scrollOverflowGroups() {
    final items = widget.items;
    if (_visibleState.isEmpty) {
      return _scrollOverflow.length == 2 ? _scrollOverflow : const [[], []];
    }
    final flags = [
      for (var i = 0; i < items.length; i++)
        _visibleState[_keyOf(i, items[i])] == true,
    ];
    final visibleStart = flags.indexOf(true);
    final visibleEnd = flags.lastIndexOf(true);
    if (visibleStart < 0 || visibleEnd < 0) {
      return _scrollOverflow.length == 2 ? _scrollOverflow : const [[], []];
    }
    return [items.sublist(0, visibleStart), items.sublist(visibleEnd + 1)];
  }

  // -- 构建 -----------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    return _isScrollMode ? _buildScroll() : _buildCollapse();
  }

  Widget _buildCollapse() {
    return LayoutBuilder(
      builder: (context, constraints) {
        // 上游 containerWidth = 根 div clientWidth（index.tsx:249）。
        _syncContainerWidth(constraints.maxWidth);
        final overflowItems = _overflowItems;
        final overflowNode = widget.overflowRenderer?.call(overflowItems);
        final isStart =
            widget.collapseFrom == SemiOverflowListCollapseFrom.start;
        final children = <Widget>[
          if (isStart && overflowNode != null) _overflowWrapper(overflowNode),
          for (var i = 0; i < _visibleIndices.length; i++) ...[
            _itemWrapper(_visibleIndices[i], i),
          ],
          if (!isStart && overflowNode != null) _overflowWrapper(overflowNode),
        ];
        // 上游根样式：`maxWidth: '100%'` + `visibility: overflowStatus ===
        // "calculating" && this.state.pivot < 0 ? "hidden" : "visible"`。
        final measuring =
            _overflowStatus == _OverflowStatus.calculating && _pivot < 0;
        return Visibility(
          visible: !measuring,
          maintainSize: true,
          maintainAnimation: true,
          maintainState: true,
          // `display: flex; flex-wrap: nowrap`（overflowList.scss:3-5）。
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: children,
          ),
        );
      },
    );
  }

  Widget _itemWrapper(int itemIndex, int visibleIndex) {
    final item = widget.items[itemIndex];
    final key = _keyOf(itemIndex, item);
    final child =
        widget.visibleItemRenderer?.call(item, visibleIndex) ??
        const SizedBox.shrink();
    // 上游 `<ResizeObserver key={key ?? idx}><div className={`${prefixCls}-item`}>`
    // 包裹（index.tsx:356-366，wrapper 无样式，仅取测量宽度与元素身份）。
    return _SemiOverflowMeasure(
      key: ValueKey<String>(key),
      tag: key,
      registry: _boxes,
      onLayout: _onItemLayout,
      child: child,
    );
  }

  Widget _overflowWrapper(Widget node) {
    // 上游 `<ResizeObserver><div className={`${prefixCls}-overflow`}>`
    // （index.tsx:304-315，wrapper 无样式，仅取测量宽度）。
    return _SemiOverflowMeasure(
      tag: '__overflow',
      registry: _boxes,
      onOverflowLayout: _onOverflowLayout,
      child: node,
    );
  }

  Widget _buildScroll() {
    final groups = _scrollOverflowGroups();
    final rendered = widget.scrollOverflowRenderer?.call(
      List<T>.of(groups[0]),
      List<T>.of(groups[1]),
    );
    final startNode = (rendered != null && rendered.isNotEmpty)
        ? rendered[0]
        : null;
    final endNode = (rendered != null && rendered.length > 1)
        ? rendered[1]
        : null;
    // 上游 `-scroll-wrapper` `flex: 1`（overflowList.scss:14）。
    final scroller = Flexible(
      child: _SemiOverflowMeasure(
        tag: '__scroller',
        registry: _boxes,
        child: NotificationListener<ScrollNotification>(
          onNotification: (_) {
            _scheduleVisibility();
            return false;
          },
          // `overflow-x: scroll`（overflowList.scss:16）—— 未隐藏滚动条
          //（tabs.scss 的隐藏规则不适用于独立实例）。
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            // `display: flex; flex-wrap: nowrap`（overflowList.scss:13-15）。
            child: Row(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (var i = 0; i < widget.items.length; i++)
                  _itemWrapper(i, i),
              ],
            ),
          ),
        ),
      ),
    );
    final parts = switch (widget.overflowRenderDirection) {
      SemiOverflowListOverflowRenderDirection.both => [
        ?startNode,
        scroller,
        ?endNode,
      ],
      SemiOverflowListOverflowRenderDirection.start => [
        ?startNode,
        ?endNode,
        scroller,
      ],
      SemiOverflowListOverflowRenderDirection.end => [
        scroller,
        ?startNode,
        ?endNode,
      ],
    };
    // 上游根 `display: flex`（overflowList.scss:3）；rtl.scss `direction: rtl`
    // 由 Directionality 承担。
    return Row(crossAxisAlignment: CrossAxisAlignment.start, children: parts);
  }
}

class _PrevIntersect {
  const _PrevIntersect(this.thresholdIndex, this.isIntersecting);
  final int thresholdIndex;
  final bool isIntersecting;
}

bool _listEquals<T>(List<T> a, List<T> b) {
  if (identical(a, b)) return true;
  if (a.length != b.length) return false;
  for (var i = 0; i < a.length; i++) {
    if (a[i] != b[i]) return false;
  }
  return true;
}

/// 测量包装（上游 ResizeObserver 测宽的 Flutter 对应）：每次布局上报尺寸，
/// 并注册自身供 scroll 模式取全局矩形做可见性判定。
class _SemiOverflowMeasure extends SingleChildRenderObjectWidget {
  const _SemiOverflowMeasure({
    super.key,
    required this.tag,
    required this.registry,
    this.onLayout,
    this.onOverflowLayout,
    required Widget child,
  }) : super(child: child);

  final String tag;
  final Map<String, _SemiOverflowMeasureBox> registry;
  final void Function(String tag, Size size)? onLayout;
  final void Function(Size size)? onOverflowLayout;

  @override
  RenderObject createRenderObject(BuildContext context) =>
      _SemiOverflowMeasureBox(tag, registry, onLayout, onOverflowLayout);

  @override
  void updateRenderObject(
    BuildContext context,
    covariant _SemiOverflowMeasureBox renderObject,
  ) {
    renderObject
      ..tag = tag
      ..registry = registry
      ..onLayout = onLayout
      ..onOverflowLayout = onOverflowLayout;
  }
}

class _SemiOverflowMeasureBox extends RenderProxyBox {
  _SemiOverflowMeasureBox(
    this.tag,
    this.registry,
    this.onLayout,
    this.onOverflowLayout,
  );

  String tag;
  Map<String, _SemiOverflowMeasureBox> registry;
  void Function(String tag, Size size)? onLayout;
  void Function(Size size)? onOverflowLayout;

  Rect get globalRect => localToGlobal(Offset.zero) & size;

  @override
  void attach(PipelineOwner owner) {
    super.attach(owner);
    registry[tag] = this;
  }

  @override
  void detach() {
    if (registry[tag] == this) registry.remove(tag);
    super.detach();
  }

  @override
  void performLayout() {
    super.performLayout();
    onLayout?.call(tag, size);
    onOverflowLayout?.call(size);
  }
}
