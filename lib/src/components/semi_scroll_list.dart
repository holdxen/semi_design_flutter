// SemiScrollList / SemiScrollItem — 上游 packages/semi-ui/scrollList/
// {index.tsx,scrollItem.tsx} 与 packages/semi-foundation/scrollList/
// {scrollList.scss,rtl.scss,variables.scss,animation.scss,constants.ts,
// itemFoundation.ts,scrollTo.ts} 的移植。
//
// 主题对账 **42 = 39 FIELDS + 3 MOTION + 0 INTERNAL**（variables.scss 39 声明：
// color 13、width 5、height 3、spacing 14、radius 1、font 2、shadow 1；
// animation.scss 3 声明：选中背景过渡三元组；`$module` 胶水与 rtl.scss 不计；
// datePicker `223 = 220 + 3 + 0`、badge `37 = 37 FIELDS + 0 MOTION + 0
// INTERNAL` 先例）。0 死 FIELDS；`li > svg` 三件
// （`$color-scrollList_selected_item-icon`、`$width-scrollList_item_sel_svg`、
// `$spacing-scrollList_item_sel_svg-marginRight`）上游仅 `-item-sel > svg`
// 规则消费（组件 `{text}` 渲染路径恒 string，SVG 子仅 `value` 为节点的野路子
// 可达）——字段留档不消费；`$width-scrollList_item_wheel-border` quirk（scss
// 直接写 `$border-thickness-control`，仅 rtl 消费本变量）。
//
// HARDCODES（另列，生成器锚点逐字留档）：
// - constants.ts `strings`：MODE: ['normal', 'wheel']
// - constants.ts `numbers`：DEFAULT_ITEM_HEIGHT: 36、
//   DEFAULT_SCROLL_DURATION: 120
// - scrollItem.tsx defaultProps：selectedIndex: 0、motion: true、list: []、
//   cycled: false、mode: wheelMode
// - scrollItem.tsx 构造：msPerFrame = 1000 / 60（throttle/debounce 帧时）、
//   this.throttledAdjustList = throttle(（cycled 列表均衡）、
//   this.debouncedSelect = debounce(（停滚 2 帧后定选）
// - scrollItem.tsx componentDidMount：this.foundation.initWheelList(this.list, this.wrapper, () => {
//   （cycled 预铺首尾副本）——本移植以虚拟循环列表等价
// - scrollItem.tsx scrollToSelectItem：this.foundation.adjustInfiniteList(this.list, this.wrapper, nearestNode)
//   （滚中搬移 DOM 节点）——本移植以静默 re-wrap 等价
// - itemFoundation.ts adjustInfiniteList：const ratio = 1;（调平比例；
//   initWheelList 的 shouldPrepend/shouldAppend 默认 ratio = 2）
// - itemFoundation.ts selectNode：indexInList % data.length（轮回数据下标）、
//   if (this._cachedSelectedNode !== node) {（同节点去重）、index: indexInData,
//   （onSelect 载荷下标）
// - itemFoundation.ts：isDisabledData = (data: T) => data && typeof data === 'object' && data.disabled
// - itemFoundation.ts getNearestNodeInfo：Math.abs(rectTop - selectorTop)
//   （距选择带顶最近者胜，同距 DOM 序优先）
// - itemFoundation.ts getTargetNode / zeroGuard：if (listHeight <= 0) {
//   （jsdom 零矩形守护）
// - scrollItem.tsx renderItemList：item.text == null ? item.value : item.text
//   （文案兜底）、typeof itemTrans === 'function' ? itemTrans : commonTrans
//   （item 级 transform 优先）
// - scrollItem.tsx _cacheSelectedNode：node.setAttribute('aria-selected', String(node === selectedNode))
// - scrollItem.tsx renderItemList onClick：this.foundation.selectIndex(index, this.list)
//   （normal 点选即通知、无去重）
// - scrollItem.tsx renderItemList 类名：-item-sel（normal 选中底色类）
// - constants.ts cssClasses / scrollItem.tsx addClassToNode：
//   semi-scrolllist-item-selected（wheel 定选节点类）
// - scrollItem.tsx scrollToNode：targetTop = (node.offsetTop || this.list.children.length * itemHeight / 2) - (wrapperHeight - itemHeight) / 2
//   （选中项滚中公式）
// - scrollItem.tsx scrollToCenter：scrollRect.top + scrollRect.height / 2 - selectedRect.height / 2
//   （居中目标公式）
// - scrollList.scss 根：user-select: none、flex-direction: column、
//   overflow: hidden、@include font-size-regular（14px/20px）
// - scrollList.scss `-header`：text-align: center
// - scrollList.scss body `ul:before`：content: '';（顶留白块）、
//   `:before` height 公式 `($height-scrollList - $height-scrollList_item) * 0.5`
//   （= 132，与 `$spacing-scrollList_item_ul-paddingBottom` 同值复用）
// - scrollList.scss `ul`：list-style: none；`li`：box-sizing: border-box、
//   align-items: center（flex 居中）、cursor: pointer、
//   &-item-disabled：cursor: not-allowed
// - scrollList.scss 分隔：&:not(:last-child)（非末列描边）
// - scrollList.scss `-selector`：transform: translateY(-50%)（垂直居中带）
// - scrollList.scss `-shade`：opacity: 0.5、pointer-events: none
// - scrollList.scss wheel 选中：color: var(--semi-color-primary) !important
//   （★变量外内联色——消费走 theme.colors.colorPrimary）
// - rtl.scss：direction: rtl（Directionality 自然覆盖）、border-right: 0 /
//   margin-right: 0 / padding-right: 0（镜像翻侧）
import 'dart:async';

import 'package:flutter/widgets.dart';

import '../theme/semi_scroll_list_theme.dart';
import '../theme/semi_scroll_list_theme_data.dart';
import '../theme/semi_theme.dart';
import '../theme/semi_theme_data.dart';

/// 列模式（上游 `strings.MODE` / `mode`，缺省 wheel）。
enum SemiScrollItemMode { normal, wheel }

/// 选项数据（上游 `Item`）。
class SemiScrollItemData {
  const SemiScrollItemData({
    this.value,
    this.text,
    this.disabled = false,
    this.transform,
  });

  /// 选项值（上游 `value: any`）；`text` 缺省时按 JS String() 语义出文案。
  final Object? value;

  /// 选项文案（上游 `text?: string`）；null 时回落 `value`。
  final String? text;

  /// 禁止选中（上游 `disabled`）；禁用项不可点选、滚轮定选跳过。
  final bool disabled;

  /// 该项选中时的文案变换（上游 `Item.transform`，优先于列级 `transform`）。
  final String Function(Object? value, String? text)? transform;
}

/// 选中回调载荷（上游 `notifySelectItem({...item, value, type, index})`）。
class SemiScrollItemSelection {
  const SemiScrollItemSelection({
    required this.item,
    required this.index,
    this.type,
  });

  /// 选中的选项数据（上游载荷 `{...item, value: item.value}`）。
  final SemiScrollItemData item;

  /// 数据下标（上游 `index: indexInData`——cycled 轮回后的下标）。
  final int index;

  /// 列标识（上游 `type`；上游自述 internal——闭包可辨列，留作载荷字段）。
  final Object? type;
}

/// 滚动列表容器（上游 `ScrollList`）：header/body/footer 三段，body 内子项
/// 横排 flex: 1 均分（上游 body `display: flex`）。bodyHeight 缺省
/// `$height-scrollList`（300）。
class SemiScrollList extends StatelessWidget {
  const SemiScrollList({
    super.key,
    this.header,
    this.footer,
    this.bodyHeight,
    this.children = const [],
  });

  /// 头部内容（上游 `header`）；null 不出 header 区与 `-line` 分隔线。
  final Widget? header;

  /// 底部内容（上游 `footer`）；null 不出 footer 区。
  final Widget? footer;

  /// body 高度（上游 `bodyHeight`）；null 取 `$height-scrollList`（300）。
  final double? bodyHeight;

  /// body 子项（上游 `children`）——通常为 [SemiScrollItem] 列。
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final t = SemiScrollListTheme.resolve(context);
    final rows = <Widget>[];
    if (header != null) {
      rows.add(
        Container(
          color: t.colorScrollListHeaderBg,
          padding: EdgeInsets.symmetric(
            vertical: t.spacingScrollListHeaderPaddingY,
            horizontal: t.spacingScrollListHeaderPaddingX,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: EdgeInsets.symmetric(
                  vertical: t.spacingScrollListHeaderTitlePaddingY,
                  horizontal: t.spacingScrollListHeaderTitlePaddingX,
                ),
                // `-header`：text-align: center + `-title` 字重/字色
                // （@include font-size-regular 由 DefaultTextStyle 统一）。
                child: DefaultTextStyle(
                  textAlign: TextAlign.center,
                  style: DefaultTextStyle.of(context).style.copyWith(
                    fontSize: 14,
                    fontWeight: t.fontScrollListHeaderTitleFontWeight,
                    color: t.colorScrollListHeaderTitle,
                  ),
                  child: header!,
                ),
              ),
              // `-line`：`$height-scrollList_line` 分隔线。
              SizedBox(
                height: t.heightScrollListLine,
                width: double.infinity,
                child: ColoredBox(color: t.colorScrollListBorder),
              ),
            ],
          ),
        ),
      );
    }
    rows.add(
      Padding(
        padding: EdgeInsets.symmetric(
          vertical: t.spacingScrollListBodyPaddingY,
          horizontal: t.spacingScrollListBodyPaddingX,
        ),
        child: SizedBox(
          height: bodyHeight ?? t.heightScrollList,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              for (var i = 0; i < children.length; i++)
                Expanded(
                  child: _ScrollItemSlot(
                    index: i,
                    count: children.length,
                    child: children[i],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
    if (footer != null) {
      rows.add(
        Container(
          padding: EdgeInsets.all(t.spacingScrollListFooterPadding),
          decoration: BoxDecoration(
            border: Border(
              top: BorderSide(
                width: t.widthScrollListFooterBorder,
                color: t.colorScrollListFooterBorder,
              ),
            ),
          ),
          child: footer,
        ),
      );
    }
    // 根：`background: $color-scrollList-bg`、`box-shadow: $shadow-scrollList`
    // （String 字段的同值 BoxShadow twin 见 `_ScrollListMetrics.shadow`）、
    // `border-radius: $radius-scrollList`、overflow: hidden（Clip.antiAlias）、
    // @include font-size-regular（14px/20px）、user-select: none、
    // flex-direction: column、width: 100% / height: 100%（根宽随父约束满宽；
    // 高度随内容 = body 300 + header/footer——差异清单）。
    return SizedBox(
      width: double.infinity,
      child: Semantics(
        container: true,
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: t.colorScrollListBg,
            borderRadius: BorderRadius.circular(t.radiusScrollList),
            boxShadow: _ScrollListMetrics.shadow,
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(t.radiusScrollList),
            child: DefaultTextStyle(
              style: DefaultTextStyle.of(context).style
                  // No fixed line-height: inherit from DefaultTextStyle.
                  .copyWith(fontSize: 14),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: rows,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// body 槽位（`-body` flex 行的第 [index]/[count] 位）——[SemiScrollItem]
/// 据此判定 `&:not(:last-child)` 分隔描边。
class _ScrollItemSlot extends InheritedWidget {
  const _ScrollItemSlot({
    required this.index,
    required this.count,
    required super.child,
  });

  final int index;
  final int count;

  static _ScrollItemSlot? maybeOf(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<_ScrollItemSlot>();

  @override
  bool updateShouldNotify(_ScrollItemSlot oldWidget) =>
      index != oldWidget.index || count != oldWidget.count;
}

/// 滚动列表列（上游 `ScrollItem`）。normal = 普通点选列表；wheel = 滚轮
/// （缺省；cycled 时无限循环、非 cycled 时首尾留白）。wheel 停滚后吸附最近
/// 非禁用项居中并通知 onSelect（同数据下标去重）；normal 点选即通知（不去重）。
class SemiScrollItem extends StatefulWidget {
  const SemiScrollItem({
    super.key,
    this.mode = SemiScrollItemMode.wheel,
    this.cycled = false,
    this.list = const [],
    this.selectedIndex = 0,
    this.onSelect,
    this.transform,
    this.type,
    this.motion = true,
    this.semanticsLabel,
  });

  /// 列模式（上游 `mode`，缺省 wheel）。
  final SemiScrollItemMode mode;

  /// 无限循环（上游 `cycled`，缺省 false；仅 wheel 生效）。
  final bool cycled;

  /// 选项列表（上游 `list`，缺省 `[]`）。
  final List<SemiScrollItemData> list;

  /// 选中下标（上游 `selectedIndex`，缺省 0）：定位滚动、normal 高亮与
  /// transform 文案均以此为准。
  final int selectedIndex;

  /// 选中回调（上游 `onSelect`）。
  final ValueChanged<SemiScrollItemSelection>? onSelect;

  /// 选中项文案变换（上游 `transform`；item 级 `transform` 优先）。
  final String Function(Object? value, String? text)? transform;

  /// 列标识（上游 `type`）——透传进 [SemiScrollItemSelection.type]。
  final Object? type;

  /// 滚动动画（上游 `motion`，缺省 true；function 形态收敛为 bool）。
  final bool motion;

  /// 列标签（上游 `aria-label`）。
  final String? semanticsLabel;

  @override
  State<SemiScrollItem> createState() => _SemiScrollItemState();
}

class _SemiScrollItemState extends State<SemiScrollItem> {
  static const double _itemExtentFallback = 36; // DEFAULT_ITEM_HEIGHT: 36
  // 停滚定选 debounce ≈ 2 帧（scrollItem.tsx `msPerFrame * 2`）。
  static const Duration _settleDelay = Duration(milliseconds: 33);
  // 上游 120ms `animatedScrollTo`（DEFAULT_SCROLL_DURATION: 120）→ animateTo。
  static const Duration _scrollDuration = Duration(milliseconds: 120);
  // cycled 虚拟循环块数（替代 initWheelList 的首尾副本铺排）。
  static const int _loopBlocks = 1001;

  final ScrollController _controller = ScrollController();
  Timer? _settleTimer;

  /// 最近一次 build 的解析主题（timer 回调里不能 dependOnInherited——只读快照）。
  SemiResolvedScrollListThemeData? _resolved;

  /// wheel 定选节点（上游 `selectedNode` / `semi-scrolllist-item-selected`
  /// 类落点）——记录虚拟下标，同节点去重（`if (this._cachedSelectedNode !==
  /// node) {` + `cachedIndexData !== indexInData` 双门）。
  int? _settledVirtual;

  bool get _isWheel => widget.mode == SemiScrollItemMode.wheel;

  /// cycled 走虚拟循环列表（无限滚动等价）；非 cycled 首尾留白。
  bool get _cycled => _isWheel && widget.cycled;

  int get _dataCount => widget.list.length;

  int get _virtualCount => _cycled ? _dataCount * _loopBlocks : _dataCount;

  int get _middleStart => _cycled ? _dataCount * (_loopBlocks ~/ 2) : 0;

  /// `ul:before` 顶留白（公式 `($height-scrollList - $height-scrollList_item)
  /// * 0.5` = 132，同值复用 `$spacing-scrollList_item_ul-paddingBottom`）与
  /// `padding-bottom` ——仅非 cycled 出现（`list-outer-nocycle > ul:before`）。
  bool get _spacers => !_cycled;

  double get _itemExtent =>
      _resolved?.heightScrollListItem ?? _itemExtentFallback;

  double get _spacer => _resolved?.spacingScrollListItemUlPaddingBottom ?? 132;

  double get _padTop => _resolved?.spacingScrollListItemUlPadding ?? 0;

  int _dataOf(int virtual) =>
      _cycled ? ((virtual % _dataCount) + _dataCount) % _dataCount : virtual;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _jumpToInitial();
      if (_isWheel) {
        // 上游 mount 链：`wrapper.scrollTop = targetTop` 触发 scroll 事件 →
        // debouncedSelect（`this.debouncedSelect = debounce(`）落选 + 初值
        // 通知（foundation `_cachedSelectedNode` 初值 null，去重门放行）。
        _settleTimer?.cancel();
        _settleTimer = Timer(_settleDelay, _settle);
      }
    });
  }

  @override
  void didUpdateWidget(SemiScrollItem oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selectedIndex != widget.selectedIndex ||
        oldWidget.list.length != widget.list.length ||
        oldWidget.mode != widget.mode ||
        oldWidget.cycled != widget.cycled) {
      // 上游 componentDidUpdate 只滚动定位（`this.scrollToIndex(selectedIndex)`）；
      // 落选与通知走 scroll → debouncedSelect → selectNode 链（不预置定选缓存）。
      _scheduleCenterSelected();
    }
  }

  @override
  void dispose() {
    _settleTimer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  /// 上游 `selectedIndex > -1 ? selectedIndex : 0` + 越界收敛（差异清单）。
  int _clampedSelected() {
    if (_dataCount == 0) return 0;
    final index = widget.selectedIndex > -1 ? widget.selectedIndex : 0;
    return index.clamp(0, _dataCount - 1);
  }

  /// 初始定位节点：cycled 取中段副本（替代 `initWheelList` 铺排 + 回调里
  /// `scrollToNode(selectedNode, 0)`），非 cycled 取数据下标。
  int _initialVirtual() => _middleStart + _clampedSelected();

  /// cycled 副本定位：取距 [from] 最近的该数据项副本（componentDidUpdate 的
  /// `getNodeByOffset(selectedNode, selectedIndex - prevProps.selectedIndex, …)`
  /// 相对位移的等价）。
  int _virtualForData(int dataIndex) {
    if (!_cycled) return dataIndex;
    final from = _settledVirtual ?? _middleStart + dataIndex;
    final current = _dataOf(from);
    var target = from + (dataIndex - current);
    if (target < 0 || target >= _virtualCount) {
      target = _middleStart + dataIndex;
    }
    return target;
  }

  /// 行内容偏移（含 `ul` padding 与首尾留白）。
  double _rowOffset(int virtual) {
    final spacer = _spacers ? _spacer : 0.0;
    return _padTop + spacer + virtual * _itemExtent;
  }

  /// scrollToNode 公式：`targetTop = node.offsetTop - (wrapperHeight -
  /// itemHeight) / 2`。
  double _targetOffset(int virtual) {
    final viewport = _controller.hasClients
        ? _controller.position.viewportDimension
        : 0.0;
    final target = _rowOffset(virtual) - (viewport - _itemExtent) / 2;
    return _clampOffset(target);
  }

  double _clampOffset(double offset) {
    if (!_controller.hasClients) return offset;
    final max = _controller.position.maxScrollExtent;
    return offset.clamp(0.0, max);
  }

  void _jumpToInitial() {
    if (!mounted || !_controller.hasClients) return;
    _controller.jumpTo(_targetOffset(_initialVirtual()));
  }

  /// componentDidUpdate 定位（`this.scrollToIndex(selectedIndex)`——上游 120ms
  /// `animatedScrollTo`，motion 关闭时 jumpTo）。
  void _scheduleCenterSelected() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !_controller.hasClients || _dataCount == 0) return;
      _animateTo(_virtualForData(_clampedSelected()));
    });
  }

  void _animateTo(int virtual) {
    final target = _targetOffset(virtual);
    if (widget.motion) {
      _controller.animateTo(
        target,
        duration: _scrollDuration,
        curve: Curves.easeOut,
      );
    } else {
      _controller.jumpTo(target);
    }
  }

  // ── wheel 定选（scrollToSelectItem / debouncedSelect / selectNode） ──

  void _onScroll(ScrollNotification notification) {
    if (!_isWheel) return;
    if (notification is ScrollUpdateNotification ||
        notification is ScrollEndNotification) {
      _settleTimer?.cancel();
      _settleTimer = Timer(_settleDelay, _settle);
    }
  }

  /// 停滚 2 帧后：吸附加 `semi-scrolllist-item-selected` 类的最近节点
  /// （getNearestNodeInfo：`Math.abs(rectTop - selectorTop)` 最小者胜，
  /// 禁用跳过），滚动居中（scrollToCenter）并按数据下标去重通知。
  void _settle() {
    if (!mounted || !_controller.hasClients || _dataCount == 0) return;
    final nearest = _nearestEnabled();
    if (nearest < 0) return;
    _selectVirtual(nearest);
  }

  /// 选择带顶（内容坐标）= 滚动偏移 + 视口半高 - 半行高（selector
  /// `top: 50%` + `transform: translateY(-50%)`）。
  double get _selectorTopContent {
    final viewport = _controller.position.viewportDimension;
    return _controller.offset + viewport / 2 - _itemExtent / 2;
  }

  int _nearestEnabled() {
    final target = _selectorTopContent;
    final spacer = _spacers ? _spacer : 0.0;
    final anchor = ((target - _padTop - spacer) / _itemExtent).round();
    var best = -1;
    var bestDistance = double.infinity;
    // 升序扫描、严格小于——同距 DOM 序优先（getNearestNodeInfo 语义）。
    final lo = _cycled ? anchor - _dataCount : 0;
    final hi = _cycled ? anchor + _dataCount : _virtualCount - 1;
    for (var v = lo; v <= hi; v++) {
      if (v < 0 || v >= _virtualCount) continue;
      final data = widget.list[_dataOf(v)];
      if (data.disabled) {
        continue; // isDisabledIndex 跳过
      }
      final distance = (_rowOffset(v) - target).abs();
      if (distance < bestDistance) {
        bestDistance = distance;
        best = v;
      }
    }
    return best;
  }

  /// selectNode：吸附居中 + 同节点/同数据下标去重通知（`if
  /// (this._cachedSelectedNode !== node) {`）。
  void _selectVirtual(int virtual) {
    final dataIndex = _dataOf(virtual);
    final changed =
        _settledVirtual == null || _dataOf(_settledVirtual!) != dataIndex;
    setState(() => _settledVirtual = virtual);
    // scrollToCenter 公式 `scrollRect.top + scrollRect.height / 2 -
    // selectedRect.height / 2` → 目标 = 行中线对齐视口中线（_targetOffset）。
    final target = _targetOffset(virtual);
    if ((_controller.offset - target).abs() > 0.5) {
      _animateTo(virtual);
    }
    if (changed) {
      _notify(dataIndex);
    }
  }

  void _notify(int dataIndex) {
    widget.onSelect?.call(
      SemiScrollItemSelection(
        item: widget.list[dataIndex],
        index: dataIndex,
        type: widget.type,
      ),
    );
  }

  // ── 点选 ──

  /// normal：`this.foundation.selectIndex(index, this.list)`——即点即通知、
  /// 无去重、不滚动。
  void _tapNormal(int dataIndex) {
    _notify(dataIndex);
  }

  /// wheel：clickToSelectItem → debouncedSelect(node) → selectNode（吸附居中 +
  /// 去重通知）。
  void _tapWheel(int virtual) {
    _settleTimer?.cancel();
    _settleTimer = Timer(_settleDelay, () {
      if (mounted) _selectVirtual(virtual);
    });
  }

  // ── 渲染 ──

  /// renderItemList 文案：`item.text == null ? item.value : item.text`；
  /// 选中行（`selectedIndex === index`，上游严格相等不收敛）过 transform
  /// （`typeof itemTrans === 'function' ? itemTrans : commonTrans`）。
  String _label(int dataIndex) {
    final item = widget.list[dataIndex];
    // JS String() 语义：整数值不带 `.0`（badge `_formatNum` 先例）。
    var text =
        item.text ??
        (item.value == null
            ? ''
            : item.value is num &&
                  (item.value as num) == (item.value as num).roundToDouble()
            ? '${(item.value as num).round()}'
            : '${item.value}');
    if (dataIndex == widget.selectedIndex) {
      final transform = item.transform ?? widget.transform;
      if (transform != null) {
        text = transform(item.value, item.text);
      }
    }
    return text;
  }

  @override
  Widget build(BuildContext context) {
    final t = SemiScrollListTheme.resolve(context);
    _resolved = t;
    final global = SemiTheme.of(context);
    final slot = _ScrollItemSlot.maybeOf(context);
    final isLast = slot == null || slot.index == slot.count - 1;

    final content = _isWheel
        ? _buildWheel(context, t, global)
        : _buildNormal(context, t, global);

    if (isLast) return content;
    // 分隔描边（`&:not(:last-child)`）：normal `border-right:
    // $width-scrollList_item-border`；wheel 滚轮分隔（quirk：scrollList.scss:125
    // 直接写 `$border-thickness-control` 同值 1，本处消费
    // `$width-scrollList_item_wheel-border`）；rtl.scss `border-right: 0` +
    // 翻 `border-left`（BorderDirectional.end 随方向）。
    final width = _isWheel
        ? t.widthScrollListItemWheelBorder
        : t.widthScrollListItemBorder;
    return DecoratedBox(
      decoration: BoxDecoration(
        border: BorderDirectional(
          end: BorderSide(width: width, color: t.colorScrollListBorder),
        ),
      ),
      child: content,
    );
  }

  Widget _buildNormal(
    BuildContext context,
    SemiResolvedScrollListThemeData t,
    SemiThemeData global,
  ) {
    final children = <Widget>[];
    if (_spacers) {
      // `ul:before` 顶留白：`content: '';` + 高度公式
      // `($height-scrollList - $height-scrollList_item) * 0.5`（= 132，同值
      // 复用 `$spacing-scrollList_item_ul-paddingBottom`）。
      children.add(SizedBox(height: t.spacingScrollListItemUlPaddingBottom));
    }
    for (var i = 0; i < _dataCount; i++) {
      children.add(_buildRow(context, t, global, i, i));
    }
    if (_spacers) {
      children.add(SizedBox(height: t.spacingScrollListItemUlPaddingBottom));
    }
    return NotificationListener<ScrollNotification>(
      onNotification: (notification) {
        _onScroll(notification);
        return false;
      },
      child: SingleChildScrollView(
        controller: _controller,
        // `ul`：margin/padding 照 `$spacing-scrollList_item_ul-margin`/
        // `$spacing-scrollList_item_ul-padding`（0 值字段照用即消费）；
        // `padding-bottom` 由首尾留白块承接（见上）。
        padding: EdgeInsets.all(t.spacingScrollListItemUlPadding),
        child: Column(mainAxisSize: MainAxisSize.min, children: children),
      ),
    );
  }

  Widget _buildWheel(
    BuildContext context,
    SemiResolvedScrollListThemeData t,
    SemiThemeData global,
  ) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final height = constraints.maxHeight;
        final list = NotificationListener<ScrollNotification>(
          onNotification: (notification) {
            _onScroll(notification);
            return false;
          },
          child: ListView.builder(
            controller: _controller,
            padding: EdgeInsets.all(t.spacingScrollListItemUlPadding),
            itemCount: _virtualCount + (_spacers ? 2 : 0),
            itemBuilder: (context, index) {
              if (_spacers && index == 0) {
                return SizedBox(height: t.spacingScrollListItemUlPaddingBottom);
              }
              if (_spacers && index == _virtualCount + 1) {
                return SizedBox(height: t.spacingScrollListItemUlPaddingBottom);
              }
              final virtual = _spacers ? index - 1 : index;
              return _buildRow(context, t, global, virtual, _dataOf(virtual));
            },
          ),
        );
        // `list-outer`：padding-right: $spacing-scrollList_item_wheel_list_outer
        // -paddingRight（rtl.scss `padding-right: 0` + 翻 `padding-left` →
        // EdgeInsetsDirectional.end）。
        final padded = Padding(
          padding: EdgeInsetsDirectional.only(
            end: t.spacingScrollListItemWheelListOuterPaddingRight,
          ),
          child: list,
        );
        // 静态 list-outer 在下、absolute 覆盖层在上（renderInfiniteList 的
        // paint 序：preShade → selector → postShade 叠于滚动层之上）。
        return Stack(
          children: [
            padded,
            // `-shade-pre`：`top: 0` + margin-top
            // `$spacing-scrollList_item_wheel_list_shade_pre-marginTop`、
            // height: 50%、opacity: 0.5、pointer-events: none（遮罩不拦截）。
            Positioned(
              top: t.spacingScrollListItemWheelListShadePreMarginTop,
              left: 0,
              right: 0,
              height: height * 0.5,
              child: IgnorePointer(
                child: Opacity(
                  opacity: 0.5,
                  child: ColoredBox(color: t.colorScrollListBg),
                ),
              ),
            ),
            // `-selector`：`top: 50%` + `transform: translateY(-50%)`、height
            // `$height-scrollList_item`、上下描边
            // `$width-scrollList_item_wheel_selector-border`。
            IgnorePointer(
              child: Align(
                alignment: Alignment.center,
                child: SizedBox(
                  height: t.heightScrollListItem,
                  width: double.infinity,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      border: Border(
                        top: BorderSide(
                          width: t.widthScrollListItemWheelSelectorBorder,
                          color: t.colorScrollListBorder,
                        ),
                        bottom: BorderSide(
                          width: t.widthScrollListItemWheelSelectorBorder,
                          color: t.colorScrollListBorder,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            // `-shade-post`：`top: 50%` + margin-top
            // `$spacing-scrollList_item_wheel_list_shade_post-marginTop`、
            // height: 50%、opacity: 0.5。
            Positioned(
              top:
                  height * 0.5 +
                  t.spacingScrollListItemWheelListShadePostMarginTop,
              left: 0,
              right: 0,
              height: height * 0.5,
              child: IgnorePointer(
                child: Opacity(
                  opacity: 0.5,
                  child: ColoredBox(color: t.colorScrollListBg),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildRow(
    BuildContext context,
    SemiResolvedScrollListThemeData t,
    SemiThemeData global,
    int virtual,
    int dataIndex,
  ) {
    final item = widget.list[dataIndex];
    // `-item-sel`（normal 选中底——`selectedIndex === index` 严格相等）/
    // `semi-scrolllist-item-selected`（wheel 定选节点——font-weight +
    // `color: var(--semi-color-primary) !important`）。
    final normalSelected = !_isWheel && dataIndex == widget.selectedIndex;
    final wheelSettled = _isWheel && virtual == _settledVirtual;
    return Semantics(
      selected: normalSelected || wheelSettled,
      enabled: !item.disabled,
      child: _ScrollRow(
        height: t.heightScrollListItem,
        // `li`：height `$height-scrollList_item`、box-sizing: border-box、
        // align-items: center（flex 居中）、cursor: pointer /
        // cursor: not-allowed、transition: background-color
        // （MOTION 三元组：transitionDurationScrollListSelectedItemBg /
        // transitionFunctionScrollListSelectedItemBg 槽消费；
        // transitionDelayScrollListSelectedItemBg 0ms 无 delay 槽 → 注释引用，
        // anchor 先例）。
        disabled: item.disabled,
        hoverEnabled: !item.disabled && !normalSelected && !wheelSettled,
        hoverColor: t.colorScrollListItemTextHover,
        activeColor: t.colorScrollListItemBgActive,
        baseColor: t.colorScrollListItemBg,
        selectedColor: normalSelected ? t.colorScrollListSelectedItemBg : null,
        transitionDuration: t.transitionDurationScrollListSelectedItemBg,
        transitionCurve: t.transitionFunctionScrollListSelectedItemBg,
        cursor: item.disabled
            ? SystemMouseCursors.forbidden
            : SystemMouseCursors.click,
        onTap: item.disabled
            ? null
            : _isWheel
            ? () => _tapWheel(virtual)
            : () => _tapNormal(dataIndex),
        child: Text(
          _label(dataIndex),
          style: TextStyle(
            fontSize: 14, // @include font-size-regular
            // No fixed line-height: inherit from DefaultTextStyle.
            color: wheelSettled
                // `color: var(--semi-color-primary) !important`（★变量外内联色）。
                ? global.colors.colorPrimary
                : item.disabled
                ? t.colorScrollListDisabledItemText
                : normalSelected
                ? t.colorScrollListSelectedItemText
                : t.colorScrollListItemText,
            fontWeight: wheelSettled
                ? t.fontScrollListItemWheelItemSelectedFontWeight
                : null,
          ),
        ),
      ),
    );
  }
}

/// `li` 行盒：hover/active 底色（`:not(.disabled):not(.-item-disabled):not
/// (.-item-sel):not(.-item-selected)` 门内）+ 背景过渡（MOTION 三元组）。
class _ScrollRow extends StatefulWidget {
  const _ScrollRow({
    required this.height,
    required this.disabled,
    required this.hoverEnabled,
    required this.hoverColor,
    required this.activeColor,
    required this.baseColor,
    required this.selectedColor,
    required this.transitionDuration,
    required this.transitionCurve,
    required this.cursor,
    required this.onTap,
    required this.child,
  });

  final double height;
  final bool disabled;
  final bool hoverEnabled;
  final Color hoverColor;
  final Color activeColor;
  final Color baseColor;
  final Color? selectedColor;
  final Duration transitionDuration;
  final Curve transitionCurve;
  final MouseCursor cursor;
  final VoidCallback? onTap;
  final Widget child;

  @override
  State<_ScrollRow> createState() => _ScrollRowState();
}

class _ScrollRowState extends State<_ScrollRow> {
  bool _hovered = false;
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    // hover/active 仅未选中、未禁用行（CSS `:not(.disabled):not(.-item-disabled)
    // :not(.-item-sel):not(.-item-selected)` 门）。
    var color = widget.selectedColor ?? widget.baseColor;
    if (widget.hoverEnabled && _pressed) {
      color = widget.activeColor;
    } else if (widget.hoverEnabled && _hovered) {
      color = widget.hoverColor;
    }
    return MouseRegion(
      cursor: widget.cursor,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: widget.onTap,
        onTapDown: widget.onTap == null
            ? null
            : (_) => setState(() => _pressed = true),
        onTapUp: widget.onTap == null
            ? null
            : (_) => setState(() => _pressed = false),
        onTapCancel: widget.onTap == null
            ? null
            : () => setState(() => _pressed = false),
        child: AnimatedContainer(
          duration: widget.transitionDuration,
          curve: widget.transitionCurve,
          height: widget.height,
          width: double.infinity,
          alignment: Alignment.center,
          color: color,
          child: widget.child,
        ),
      ),
    );
  }
}

/// Widget-internal metrics and provenance anchors (upstream values kept out of
/// the theme). See tool/generate_scroll_list.py for the
/// 42 = 39 FIELDS + 3 MOTION + 0 INTERNAL accounting; the constants below are
/// the 另列 HARDCODES entries (their snippets are checked to appear in this
/// file).
class _ScrollListMetrics {
  /// `$shadow-scrollList: 0 0 1px rgba(0, 0, 0, .3), 0 4px 14px rgba(0, 0, 0, .1)`
  /// ——String 字段 `shadowScrollList` 的同值 BoxShadow twin（time_picker
  /// `shadowRangePanel` 先例，注释互指）。
  static const shadow = <BoxShadow>[
    BoxShadow(color: Color.fromRGBO(0, 0, 0, 0.3), blurRadius: 1),
    BoxShadow(
      color: Color.fromRGBO(0, 0, 0, 0.1),
      blurRadius: 14,
      offset: Offset(0, 4),
    ),
  ];
}
