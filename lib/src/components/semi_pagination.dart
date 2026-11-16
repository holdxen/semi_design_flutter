// SemiPagination — 翻页器（Semi Design 组件移植）。
//
// 上游：packages/semi-foundation/pagination/{variables.scss, animation.scss,
// pagination.scss, rtl.scss, constants.ts, foundation.ts}、
// packages/semi-ui/pagination/index.tsx + zh_CN.ts locale。主题对账
// 48 = 41 FIELDS + 7 MOTION + 0 INTERNAL（tool/generate_pagination.py）——
// ★1 死变量（`$color-pagination_item-bg-default` 声明后零消费），留档不消费
// （落 theme + docs「（上游未消费）」；本文件不得出现该字段名，生成器
// assertNotIn 断言）。
// 7 条 MOTION 是活字段（pagination.scss:2 `@import "./animation.scss"` + :48-50
// 消费，0ms/ease-in/0ms/scale(1,1) 恒等）。
//
// HARDCODES（另列）上游片段以注释逐字留档在 `_PaginationMetrics` / 调用点，
// 生成器 HARDCODES 锚点断言这些片段出现在本文件。
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import '../overlay/tooltip_positioning.dart';
import '../theme/semi_pagination_theme.dart';
import '../theme/semi_pagination_theme_data.dart';
import 'icon/semi_icon.dart';
import 'icon/semi_icon_data.dart';
import 'icon/semi_icons.dart';
import 'semi_dropdown.dart';
import 'semi_input_number.dart';
import 'semi_select.dart';
import 'semi_tooltip.dart';

/// 翻页器尺寸（上游 `size: 'small' | 'default'`；`default` 是 Dart 保留字，
/// 照 `defaultSize` 先例命名）。
enum SemiPaginationSize { defaultSize, small }

/// 翻页器。
///
/// 容量与截断（foundation.ts:151-214）：每页条数 `pageSize ?? pageSizeOpts[0]
/// ?? 10`；总页数 `ceil(total / pageSize)`；总页数 ≤ 7 全量展示，> 7 按当前页
/// 截断为「1 + ... + 5 个尾页 / 中部三连 + 双省略 / 5 个尾页」共 7 个格子
/// （`PAGE_SHOW_MAX: 7`）。省略号 hover 出 rest 列表弹层（Popover trigger hover
/// → SemiDropdown content 自绘列表；react-window 虚拟化 → ListView.builder）。
/// 页码变更（foundation.ts:73-92 `goPage`）：受控 `currentPage != null` 只回调
/// 不改内部态；未受控直接改态；两种都发 onPageChange + onChange（顺序照
/// goPage）。pageSize 切换（foundation.ts:216-237 `changePageSize`）：改内部
/// pageSize → onPageSizeChange → 重算当前页（默认保留首条所在页；`preventPage
/// ChangeOnPageSizeChange` 关掉重算）→ onPageChange（变了才发）→ onChange。
/// 快速跳转（foundation.ts:255-293）：blur/Enter 提交，`Number()` 解析、夹在
/// `[1, 总页数]`、清空输入后 goPage。small 尺寸：`current/total` 摘要盒 +
/// `hoverShowPageSelect` 时 hover 出全页码弹层（index.tsx:461-501）。
class SemiPagination extends StatefulWidget {
  const SemiPagination({
    super.key,
    this.total = 1,
    this.showTotal = false,
    this.pageSize,
    this.pageSizeOpts = _PaginationMetrics.pageSizeOptions,
    this.size = SemiPaginationSize.defaultSize,
    this.currentPage,
    this.defaultCurrentPage = 1,
    this.onPageChange,
    this.onPageSizeChange,
    this.onChange,
    this.prevText,
    this.nextText,
    this.showSizeChanger = false,
    this.showQuickJumper = false,
    this.popoverZIndex = _PaginationMetrics.popoverZIndex,
    this.popoverPosition,
    this.hideOnSinglePage = false,
    this.hoverShowPageSelect = false,
    this.disabled = false,
    this.preventPageChangeOnPageSizeChange = false,
  });

  /// Key of the root row.
  static const Key rootKey = Key('SemiPagination.root');

  /// Key of the previous-page item.
  static const Key prevKey = Key('SemiPagination.prev');

  /// Key of the next-page item.
  static const Key nextKey = Key('SemiPagination.next');

  /// Key of the page-size [SemiSelect] trigger wrapper.
  static const Key sizeChangerKey = Key('SemiPagination.sizeChanger');

  /// Key of the quick-jump [SemiInputNumber].
  static const Key quickJumpInputKey = Key('SemiPagination.quickJumpInput');

  /// Key of a rest-list popup body (省略号弹层 / small 全页码弹层).
  static const Key restListKey = Key('SemiPagination.restList');

  /// 数据总量（该库语义：`total/pageSize` 向上取整得总页数，index.tsx:136）。
  final int total;

  /// 是否展示总页数文本（`total` locale 串，仅 default 尺寸；index.tsx:517-522）。
  final bool showTotal;

  /// 每页条数（半受控：非 null 时作为初值/变更源，切换器交互只改内部态并回调
  /// ——上游 state.pageSize + componentDidUpdate 同步，index.tsx:206-241）。
  final int? pageSize;

  /// 每页条数候选（`PAGE_SIZE_OPTION: [10, 20, 40, 100]`）；当前 pageSize 不在其中
  /// 时按序插入（foundation.ts:243-253 `pageSizeInOpts`）。
  final List<int> pageSizeOpts;

  /// 尺寸档（small 走摘要盒形态）。
  final SemiPaginationSize size;

  /// 当前页（非 null 即受控：交互只发 onPageChange/onChange，展示跟随 props
  /// ——照本库受控口径；`0` 按 JS falsy 回退 defaultCurrentPage，index.tsx:135）。
  final int? currentPage;

  /// 未受控初值（`currentPage || defaultCurrentPage` 的 falsy 回退照抄）。
  final int defaultCurrentPage;

  /// 页码变更（goPage 先发它、后发 onChange）。
  final ValueChanged<int>? onPageChange;

  /// 每页条数变更（pageSize 切换先发它）。
  final ValueChanged<int>? onPageSizeChange;

  /// 单次翻页/容量变更的合并回调 `(currentPage, pageSize)`（最后发）。
  final void Function(int currentPage, int pageSize)? onChange;

  /// 上一页内容（String | Widget；缺省 `IconChevronLeft size="large"`）。
  final Object? prevText;

  /// 下一页内容（String | Widget；缺省 `IconChevronRight size="large"`）。
  final Object? nextText;

  /// 展示每页条数切换器（挂在 `li.-switch` 下的 [SemiSelect]；index.tsx:289-328）。
  final bool showSizeChanger;

  /// 展示快速跳转（`跳至 [n] 页`；index.tsx:330-359）。
  final bool showQuickJumper;

  /// Popover z-index（照 SemiTooltip 口径仅 API 对齐，叠放由 Overlay 插入序决定）。
  final int popoverZIndex;

  /// 省略号/small 摘要弹层位置（缺省 bottom——Popover `defaultProps.position`）。
  final SemiTooltipPosition? popoverPosition;

  /// 单页时隐藏（★与 showSizeChanger 同开时上游 warning 且该开关失效——
  /// index.tsx:155-158，照抄不 assert）。隐藏判定不含 small 形态差异。
  final bool hideOnSinglePage;

  /// small 尺寸下摘要盒 hover 出全页码弹层（`hoverShowPageSelect`）。
  final bool hoverShowPageSelect;

  /// 整体禁用（页码全 disabled 色、prev/next/切换器/跳转全禁用）。
  final bool disabled;

  /// 容量变更时不自动重算当前页（由使用方在 onPageSizeChange 自行处理）。
  final bool preventPageChangeOnPageSizeChange;

  @override
  State<SemiPagination> createState() => _SemiPaginationState();
}

class _SemiPaginationState extends State<SemiPagination> {
  late int _pageSize;
  late int _currentPage;
  final TextEditingController _quickJumpController = TextEditingController();
  final FocusNode _quickJumpFocus = FocusNode(debugLabel: 'SemiPagination');

  bool get _controlled => widget.currentPage != null;

  int get _totalPages => (widget.total / _pageSize).ceil();

  @override
  void initState() {
    super.initState();
    // `props.pageSize || props.pageSizeOpts[0] || DEFAULT_PAGE_SIZE`（JS truthy
    // 回退：0/空候选均落到下一档，index.tsx:132）。
    final initialSize = widget.pageSize;
    _pageSize = initialSize != null && initialSize != 0
        ? initialSize
        : (widget.pageSizeOpts.isNotEmpty
              ? widget.pageSizeOpts.first
              : _PaginationMetrics.defaultPageSize);
    // `props.currentPage || props.defaultCurrentPage`（★0 falsy 回退，
    // index.tsx:135）。
    final initialPage = widget.currentPage;
    _currentPage = initialPage != null && initialPage != 0
        ? initialPage
        : widget.defaultCurrentPage;
    _quickJumpFocus.addListener(_handleQuickJumpFocusChange);
  }

  @override
  void didUpdateWidget(SemiPagination oldWidget) {
    super.didUpdateWidget(oldWidget);
    // 半受控同步（componentDidUpdate → foundation.updatePage，index.tsx:206-241）。
    if (widget.currentPage != null &&
        widget.currentPage != oldWidget.currentPage) {
      _currentPage = widget.currentPage!;
    }
    if (widget.pageSize != null && widget.pageSize != oldWidget.pageSize) {
      _pageSize = widget.pageSize!;
    }
  }

  @override
  void dispose() {
    _quickJumpFocus.removeListener(_handleQuickJumpFocusChange);
    _quickJumpFocus.dispose();
    _quickJumpController.dispose();
    super.dispose();
  }

  // -- navigation ------------------------------------------------------------

  /// foundation.ts:73-92 `goPage`：`'...'`/同页/禁用均由调用方守卫，受控只回调。
  void _goPage(Object? target) {
    if (target is! int) {
      return;
    }
    if (widget.disabled || target == _currentPage) {
      return;
    }
    if (!_controlled) {
      setState(() => _currentPage = target);
    }
    widget.onPageChange?.call(target);
    widget.onChange?.call(target, _pageSize);
  }

  /// foundation.ts:132-145 `goPrev` / `goNext`。
  void _goPrev() {
    if (_currentPage > 1) {
      _goPage(_currentPage - 1);
    }
  }

  void _goNext() {
    if (_currentPage <= _totalPages - 1) {
      _goPage(_currentPage + 1);
    }
  }

  /// foundation.ts:216-237 `changePageSize`（通知顺序照抄：size → page → change）。
  void _handlePageSizeChange(Object? value) {
    if (value is! int) {
      return;
    }
    final oldSize = _pageSize;
    final oldPage = _currentPage;
    setState(() => _pageSize = value);
    widget.onPageSizeChange?.call(value);
    var newPage = oldPage;
    if (!widget.preventPageChangeOnPageSizeChange) {
      // 保留当前页首条所在页（foundation.ts:226-231）。
      final firstItemIndex = (oldPage - 1) * oldSize + 1;
      newPage = (firstItemIndex / value).ceil();
    }
    if (newPage != oldPage) {
      if (!_controlled) {
        setState(() => _currentPage = newPage);
      }
      widget.onPageChange?.call(newPage);
    }
    widget.onChange?.call(newPage, value);
  }

  // -- quick jump ------------------------------------------------------------

  /// foundation.ts:255-293 `_handleQuickJump`：空串/NaN 忽略；超界夹到
  /// `[1, 总页数]`；先把输入清空再 goPage（:277-279）。★上游 `Number()` 允许
  /// 小数（页码语义下收敛 int，见差异清单）。
  void _handleQuickJump(String text) {
    if (text.isEmpty) {
      return;
    }
    final page = int.tryParse(text.trim());
    if (page == null) {
      return;
    }
    var target = page;
    final totalPages = _totalPages;
    if (target > totalPages) {
      target = totalPages;
    }
    if (target <= 0) {
      target = 1;
    }
    _quickJumpController.clear();
    _goPage(target);
  }

  void _handleQuickJumpBlur() {
    // foundation.ts:282-289：输入非空才提交（空串 no-op）。
    if (_quickJumpController.text.isNotEmpty) {
      _handleQuickJump(_quickJumpController.text);
    }
  }

  void _handleQuickJumpFocusChange() {
    if (!_quickJumpFocus.hasFocus) {
      _handleQuickJumpBlur();
    }
  }

  // -- page list -------------------------------------------------------------

  /// foundation.ts:151-214 `getPageList`（截断矩阵照抄；rest 列表按左右拆分，
  /// `REST_PAGE_MAX_SIZE` 上限）。
  (List<Object>, List<int>, List<int>) _pageListFor(
    int currentPage,
    int totalPages,
  ) {
    const restMax = _PaginationMetrics.restPageMaxSize;
    if (totalPages <= _PaginationMetrics.pageShowMax) {
      return (
        [for (var i = 1; i <= totalPages; i++) i],
        const <int>[],
        const <int>[],
      );
    }
    if (currentPage < 4) {
      return (
        [1, 2, 3, 4, '...', totalPages - 1, totalPages],
        const <int>[],
        [for (var i = 5; i <= 4 + (totalPages - 6).clamp(0, restMax); i++) i],
      );
    }
    if (currentPage == 4) {
      return (
        [1, 2, 3, 4, 5, '...', totalPages],
        const <int>[],
        [for (var i = 6; i <= 5 + (totalPages - 6).clamp(0, restMax); i++) i],
      );
    }
    if (currentPage > 4 && currentPage < totalPages - 3) {
      return (
        [
          1,
          '...',
          currentPage - 1,
          currentPage,
          currentPage + 1,
          '...',
          totalPages,
        ],
        [for (var i = 2; i <= 1 + (currentPage - 3).clamp(0, restMax); i++) i],
        [
          for (
            var i = currentPage + 2;
            i <=
                currentPage +
                    1 +
                    (totalPages - currentPage - 2).clamp(0, restMax);
            i++
          )
            i,
        ],
      );
    }
    // fallback（`:203` 条件恒真）：倒数 5 页 + 左侧省略号。
    final right = [for (var i = 0; i < 5; i++) totalPages - (4 - i)];
    return (
      [1, '...', ...right],
      [for (var i = 2; i <= 1 + (right[0] - 2).clamp(0, restMax); i++) i],
      const <int>[],
    );
  }

  // -- build -----------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final t = SemiPaginationTheme.resolve(context);
    final totalPages = _totalPages;
    // index.tsx:479/:509：单页隐藏；★showSizeChanger 同开时上游 warning
    // “You should not use showSizeChanger and hideOnSinglePage in ths same
    // time. At this time, hideOnSinglePage no longer takes effect”——照抄失效口径。
    if (totalPages < 2 && widget.hideOnSinglePage && !widget.showSizeChanger) {
      return const SizedBox.shrink();
    }
    // pagination.scss:36/:167/:171-173 `user-select: none`（Flutter 文本默认
    // 不可选——note-only）。
    final rtl = Directionality.of(context) == TextDirection.rtl;
    final body = widget.size == SemiPaginationSize.small
        ? _buildSmall(t, totalPages, rtl)
        : _buildDefault(t, totalPages, rtl);
    return Semantics(
      container: true,
      enabled: !widget.disabled,
      child: MouseRegion(
        // pagination.scss:23-25 `&-disabled { cursor: not-allowed }`（根级默认
        // 光标由各条目自身承担）。
        cursor: widget.disabled
            ? SystemMouseCursors.forbidden
            : MouseCursor.defer,
        child: Padding(
          padding: EdgeInsets.all(t.spacingPaginationPadding),
          child: body,
        ),
      ),
    );
  }

  /// default 形态（index.tsx:503-530）：`[total, prev, pages..., next, switch, jump]`。
  Widget _buildDefault(
    SemiResolvedPaginationThemeData t,
    int totalPages,
    bool rtl,
  ) {
    final (pageList, restLeft, restRight) = _pageListFor(
      _currentPage,
      totalPages,
    );
    final totalPagesText = '总页数：$totalPages';
    return KeyedSubtree(
      key: SemiPagination.rootKey,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          if (widget.showTotal)
            DefaultTextStyle.merge(
              // pagination.scss:120-123 `&-total`：regular 字号 + text-2；
              // `&-disabled .semi-page-total` 走 disabled 文本色（:26-28）。
              // zh_CN.ts:10 `total: '总页数：${total}'`（★键值是总页数——非
              // 条目总数 quirk）。
              style: TextStyle(
                fontSize: _PaginationMetrics.fontSizeRegular,
                color: widget.disabled
                    ? t.colorPaginationItemTextDisabled
                    : t.colorPaginationTextDefault,
              ),
              child: Text(totalPagesText),
            ),
          _buildPrev(t, rtl),
          for (var i = 0; i < pageList.length; i++)
            _buildPage(t, pageList[i], i, restLeft, restRight),
          _buildNext(t, rtl),
          if (widget.showSizeChanger) _buildSizeChanger(t, rtl),
          if (widget.showQuickJumper) _buildQuickJump(t, totalPages),
        ],
      ),
    );
  }

  /// small 形态（index.tsx:474-501）：`[prev, 摘要盒(hover 弹层), next, jump]`。
  Widget _buildSmall(
    SemiResolvedPaginationThemeData t,
    int totalPages,
    bool rtl,
  ) {
    final allDisabled = widget.disabled;
    Widget summary = _PageItem(
      t: t,
      small: true,
      selected: false,
      itemDisabled: false,
      allDisabled: allDisabled,
      prevOrNext: false,
      onTap: null,
      child: Text('$_currentPage/$totalPages'),
    );
    if (widget.hoverShowPageSelect && !widget.disabled) {
      // index.tsx:461-472：Popover 缺省 trigger hover，内容为全部页码 rest 列表。
      summary = _buildHoverPopup(
        t: t,
        pages: [for (var i = 1; i <= totalPages; i++) i],
        disabled: false,
        child: summary,
      );
    }
    return KeyedSubtree(
      key: SemiPagination.rootKey,
      child: DefaultTextStyle.merge(
        // pagination.scss:16-21 `&-small`：regular 字号 + small 字重 + text-2 +
        // small padding。
        style: TextStyle(
          fontSize: _PaginationMetrics.fontSizeRegular,
          fontWeight: t.fontPaginationSmallFontWeight,
          color: t.colorPaginationTextDefault,
        ),
        child: Padding(
          padding: EdgeInsets.symmetric(
            vertical: t.spacingPaginationSmallPaddingY,
            horizontal: t.spacingPaginationSmallPaddingX,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // index.tsx:254/:277
              // role={this.props.size === 'small' ? 'none' : undefined}
              //（small 的 prev/next 不再承担分页语义——note-only）。
              _buildPrev(t, rtl),
              summary,
              _buildNext(t, rtl),
              if (widget.showQuickJumper) _buildQuickJump(t, totalPages),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPrev(SemiResolvedPaginationThemeData t, bool rtl) {
    // foundation.ts:55-71 `_updateDisabled`：currentPage===1 → prev 禁用。
    final disabled = _currentPage == 1 || widget.disabled;
    final content = _prevNextContent(
      widget.prevText,
      SemiIcons.chevronLeft,
      rtl,
    );
    return _PageItem(
      key: SemiPagination.prevKey,
      t: t,
      small: widget.size == SemiPaginationSize.small,
      selected: false,
      itemDisabled: disabled,
      allDisabled: widget.disabled,
      prevOrNext: true,
      // index.tsx:259 `aria-label="Previous"`（Semantics 近似）。
      semanticsLabel: 'Previous',
      onTap: disabled ? null : _goPrev,
      child: content,
    );
  }

  Widget _buildNext(SemiResolvedPaginationThemeData t, bool rtl) {
    final disabled = (widget.disabled
        ? true
        : _nextDisabledFor(_currentPage, _totalPages));
    final content = _prevNextContent(
      widget.nextText,
      SemiIcons.chevronRight,
      rtl,
    );
    return _PageItem(
      key: SemiPagination.nextKey,
      t: t,
      small: widget.size == SemiPaginationSize.small,
      selected: false,
      itemDisabled: disabled,
      allDisabled: widget.disabled,
      prevOrNext: true,
      // index.tsx:282 `aria-label="Next"`。
      semanticsLabel: 'Next',
      onTap: disabled ? null : _goNext,
      child: content,
    );
  }

  /// foundation.ts:59-66：`currentPage === 1 ? totalPageNum < 2 : currentPage
  /// === totalPageNum`（★currentPage 越界时 next 反而启用 quirk 照抄）。
  bool _nextDisabledFor(int currentPage, int totalPages) =>
      currentPage == 1 ? totalPages < 2 : currentPage == totalPages;

  /// prev/next 内容：自定义 String/Widget 原样；缺省 `IconChevron{Left,Right}`
  /// `size="large"`（20px）。RTL 照 rtl.scss:13-16 `transform: scaleX(-1)`
  /// 镜像（★自定义文本一并翻转 quirk 照抄）。
  Widget _prevNextContent(Object? custom, SemiIconData fallback, bool rtl) {
    final Widget base = custom == null
        ? SemiIcon(fallback, size: SemiIconSize.large)
        : custom is Widget
        ? custom
        : Text(custom.toString());
    if (!rtl) {
      return base;
    }
    return Transform.scale(scaleX: -1, child: base);
  }

  Widget _buildPage(
    SemiResolvedPaginationThemeData t,
    Object page,
    int index,
    List<int> restLeft,
    List<int> restRight,
  ) {
    final isRest = page == '...';
    final selected = !isRest && page == _currentPage;
    final item = _PageItem(
      t: t,
      small: false,
      selected: selected,
      itemDisabled: false,
      allDisabled: widget.disabled,
      prevOrNext: false,
      // `aria-label={page === '...' ? 'More' : undefined}` + `Page ${page}`
      // （index.tsx:384/:390；button 语义近似）。
      semanticsLabel: isRest ? 'More' : 'Page $page',
      onTap: widget.disabled || isRest ? null : () => _goPage(page),
      child: Text('$page'),
    );
    if (!isRest || widget.disabled) {
      return item;
    }
    // index.tsx:399-415：省略号挂 Popover（hover；左右 rest 列表按 i<3 选择），
    // rePosKey 随 current/total/pageSize/showTotal 变化重定位。
    return _buildHoverPopup(
      t: t,
      pages: index < 3 ? restLeft : restRight,
      disabled: false,
      child: item,
    );
  }

  /// 省略号/small 摘要的 hover 弹层（Popover trigger hover → SemiDropdown
  /// content 形态；`rePosKey` → [SemiDropdown.repositionKey]）。
  Widget _buildHoverPopup({
    required SemiResolvedPaginationThemeData t,
    required List<int> pages,
    required bool disabled,
    required Widget child,
  }) {
    return SemiDropdown(
      trigger: SemiTooltipTrigger.hover,
      // Popover `defaultProps.position: 'bottom'` + `numbers.SPACING: 4`。
      position:
          widget.popoverPosition ?? _PaginationMetrics.popoverDefaultPosition,
      spacing: _PaginationMetrics.popoverSpacing,
      zIndex: widget.popoverZIndex,
      // index.tsx:404 rePosKey={`${currentPage}-${total}-${pageSize}-${showTotal}`}。
      repositionKey:
          '$_currentPage-${widget.total}-$_pageSize-${widget.showTotal}',
      content: _buildRestList(t, pages),
      child: child,
    );
  }

  /// rest 列表（index.tsx:420-458 `renderRestPageList`）：宽 78、行高 32、
  /// 最多 5 行；react-window 虚拟化 → `ListView.builder`（同视口语义）。
  Widget _buildRestList(SemiResolvedPaginationThemeData t, List<int> pages) {
    final rows = pages.length >= _PaginationMetrics.restListMaxRows
        ? _PaginationMetrics.restListMaxRows
        : pages.length;
    // ★pagination.scss:189 `// padding-left: $spacing-base;` 是被注释掉的上游
    // 规则（rest-item 无左内边距，留档不消费）。
    // index.tsx:452 `style={{ direction }}`：列表随文档方向（Flutter 由祖先
    // Directionality 继承）。
    return Container(
      key: SemiPagination.restListKey,
      width: _PaginationMetrics.restListWidth,
      // pagination.scss:175-184 `&-rest-list` padding（★`reset` 错拼照抄）。
      padding: EdgeInsets.symmetric(vertical: 0, horizontal: 0).copyWith(
        top: t.spacingPaginationResetListPaddingTop,
        bottom: t.spacingPaginationResetListPaddingBottom,
      ),
      child: SizedBox(
        height: rows * _PaginationMetrics.restItemHeight,
        child: ListView.builder(
          padding: EdgeInsets.zero,
          itemExtent: _PaginationMetrics.restItemHeight,
          itemCount: pages.length,
          itemBuilder: (context, index) {
            final page = pages[index];
            return _RestItem(page: page, t: t, onTap: () => _goPage(page));
          },
        ),
      ),
    );
  }

  /// 每页条数切换器（index.tsx:289-328）：`li.-switch` 下 [SemiSelect]，选项标签
  /// 走 locale `pageSize` 模板。
  Widget _buildSizeChanger(SemiResolvedPaginationThemeData t, bool rtl) {
    final options = _pageSizeInOpts()
        .map(
          (size) => SemiSelectOption(
            value: size,
            label: _PaginationMetrics.pageSizeLabel(size),
          ),
        )
        .toList(growable: false);
    // 上游 Select 是 auto 宽内联块（CSS inline-block）；本库 SemiSelect 在
    // 无界主轴里按内容宽收起（触发器 bounded/unbounded 分流，见 semi_select
    // 差异清单）——容量切换器不再额外约束宽度。
    return KeyedSubtree(
      key: SemiPagination.sizeChangerKey,
      child: SemiSelect(
        value: _pageSize,
        options: options,
        disabled: widget.disabled,
        // index.tsx:291-292 RTL 缺省 bottomRight、其余 bottomLeft；
        // popoverPosition 显式优先。
        position:
            widget.popoverPosition ??
            (rtl
                ? SemiTooltipPosition.bottomRight
                : SemiTooltipPosition.bottomLeft),
        clickToHide: true,
        // index.tsx:322 dropdownClassName={`${prefixCls}-select-dropdown`}
        //（= semi-page-select-dropdown；Flutter 面板无 className——note-only）。
        onChanged: _handlePageSizeChange,
      ),
    );
  }

  /// foundation.ts:243-253 `pageSizeInOpts`：把当前 pageSize 按序插入候选。
  List<int> _pageSizeInOpts() {
    final opts = List<int>.of(widget.pageSizeOpts);
    if (!opts.contains(_pageSize)) {
      final firstLarger = opts.indexWhere((el) => el > _pageSize);
      opts.insert(firstLarger == -1 ? opts.length : firstLarger, _pageSize);
    }
    return opts;
  }

  /// 快速跳转（index.tsx:330-359）：`跳至 [n] 页`；总页数 1 或整体禁用时全禁用。
  Widget _buildQuickJump(SemiResolvedPaginationThemeData t, int totalPages) {
    final isDisabled = totalPages == 1 || widget.disabled;
    return Padding(
      // pagination.scss:150-153 `&-quickjump`：左距 24 + regular 字号 + 居中。
      padding: EdgeInsetsDirectional.only(
        start: t.spacingPaginationQuickjumpMarginLeft,
      ),
      child: DefaultTextStyle.merge(
        style: TextStyle(
          fontSize: _PaginationMetrics.fontSizeRegular,
          fontWeight: t.fontPaginationQuickjumpFontWeight,
          color: isDisabled
              ? t.colorPaginationQuickjumpTextDisabled
              : t.colorPaginationItemTextDefault,
        ),
        child: Focus(
          // Enter 提交（上游 InputNumber onEnterPress → handleQuickJumpEnterPress，
          // index.tsx:352-353；InputNumber 自身对 Enter 返回 ignored，冒泡到此）。
          canRequestFocus: false,
          onKeyEvent: (node, event) {
            if (event is KeyDownEvent &&
                event.logicalKey == LogicalKeyboardKey.enter) {
              _handleQuickJump(_quickJumpController.text);
              return KeyEventResult.handled;
            }
            return KeyEventResult.ignored;
          },
          child: Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // zh_CN.ts:11-12 `jumpTo: '跳至'` / `page: '页'`。
              const Text(_PaginationMetrics.localeJumpTo),
              Padding(
                padding: EdgeInsetsDirectional.only(
                  start: t.spacingPaginationQuickjumpInputMarginLeft,
                  end: t.spacingPaginationQuickjumpInputMarginRight,
                ),
                child: ConstrainedBox(
                  // pagination.scss:156-160 `&-input-number { max-width: 50px }`。
                  constraints: BoxConstraints(
                    maxWidth: t.widthPaginationQuickjumpInputWidth,
                  ),
                  child: SemiInputNumber(
                    key: SemiPagination.quickJumpInputKey,
                    controller: _quickJumpController,
                    focusNode: _quickJumpFocus,
                    hideButtons: true,
                    disabled: isDisabled,
                    // foundation.ts:255-258 `handleQuickJumpNumberChange`：只
                    // 记录输入，blur/Enter 才提交。
                    onChanged: (value) => setState(() {}),
                  ),
                ),
              ),
              const Text(_PaginationMetrics.localePage),
            ],
          ),
        ),
      ),
    );
  }
}

/// 页码/省略号/摘要盒（pagination.scss:31-118 `&-item` 状态矩阵）。
class _PageItem extends StatefulWidget {
  const _PageItem({
    super.key,
    required this.t,
    required this.small,
    required this.selected,
    required this.itemDisabled,
    required this.allDisabled,
    required this.prevOrNext,
    required this.child,
    this.onTap,
    this.semanticsLabel,
  });

  final SemiResolvedPaginationThemeData t;
  final bool small;
  final bool selected;

  /// 条目级禁用（prev/next 的 `-item-disabled`）。
  final bool itemDisabled;

  /// 整体禁用（`-item-all-disabled` + `-item-all-disabled-active`）。
  final bool allDisabled;

  /// prev/next（`&-prev/&-next`：图标色系覆盖文本色系）。
  final bool prevOrNext;

  final Widget child;
  final VoidCallback? onTap;
  final String? semanticsLabel;

  @override
  State<_PageItem> createState() => _PageItemState();
}

class _PageItemState extends State<_PageItem> {
  bool _hover = false;
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final t = widget.t;
    // 状态矩阵（pagination.scss 源序：:hover → :active → -active → -disabled →
    // -all-disabled[-active]；禁用态吞掉 hover/press 反馈）。
    final Color bg;
    final Color textColor;
    final Color borderColor;
    final FontWeight weight;
    if (widget.allDisabled) {
      // `-all-disabled` 覆盖 border/text/bg；`-all-disabled-active` 只在选中项
      // 把 bg 换成 selected-disabled（:98-117）。
      bg = widget.selected
          ? t.colorPaginationItemBgSelectedDisabled
          : t.colorPaginationItemBgDisabled;
      textColor = t.colorPaginationItemTextDisabled;
      borderColor = t.colorPaginationItemBorderDisabled;
      weight = widget.selected
          ? t.fontPaginationItemActiveFontWeight
          : t.fontPaginationItemFontWeight;
    } else if (widget.itemDisabled) {
      // `-item-disabled`（:82-91）：bg/border/text 禁用色；prev/next 的图标色
      // 覆盖（:139-148）。
      bg = t.colorPaginationItemBgDisabled;
      textColor = widget.prevOrNext
          ? t.colorPaginationItemIconDisabled
          : t.colorPaginationItemTextDisabled;
      borderColor = t.colorPaginationItemBorderDisabled;
      weight = t.fontPaginationItemFontWeight;
    } else if (widget.selected) {
      // `-active`（:69-80）：选中色 + active 字重；`:hover` 重设同色。
      bg = t.colorPaginationItemBgSelected;
      textColor = t.colorPaginationItemTextSelected;
      borderColor = t.colorPaginationItemBorderSelected;
      weight = t.fontPaginationItemActiveFontWeight;
    } else if (_pressed) {
      bg = t.colorPaginationItemBgActive;
      textColor = t.colorPaginationItemTextActive;
      borderColor = t.colorPaginationItemBorderActive;
      weight = t.fontPaginationItemFontWeight;
    } else if (_hover) {
      bg = t.colorPaginationItemBgHover;
      textColor = t.colorPaginationItemTextHover;
      borderColor = t.colorPaginationItemBorderHover;
      weight = t.fontPaginationItemFontWeight;
    } else {
      // `-item` 基准：★背景 token 死变量（上游零消费）——按 CSS 缺省透明作画。
      bg = const Color(0x00000000);
      textColor = widget.prevOrNext
          ? t.colorPaginationItemIconDefault
          : t.colorPaginationItemTextDefault;
      borderColor = t.colorPaginationItemBorderDefault;
      weight = t.fontPaginationItemFontWeight;
    }
    final disabled = widget.allDisabled || widget.itemDisabled;
    Widget content = AnimatedDefaultTextStyle(
      // pagination.scss:48-49 `transition: background-color ..., color ...` 的
      // 文本三元组（0ms/ease-in/0ms 恒等；delay 槽 transitionDelayPaginationItemText
      // 在 AnimatedDefaultTextStyle 无对应——注释引用）。
      duration: t.transitionDurationPaginationItemText,
      curve: t.transitionFunctionPaginationItemText,
      style: TextStyle(
        fontSize: _PaginationMetrics.fontSizeRegular,
        fontWeight: weight,
        color: textColor,
      ),
      child: Center(child: widget.child),
    );
    content = AnimatedContainer(
      // pagination.scss:48 背景三元组（0ms/ease-in/0ms 恒等；delay 槽
      // transitionDelayPaginationItemBg 在 AnimatedContainer 无对应——注释引用）。
      duration: t.transitionDurationPaginationItemBg,
      curve: t.transitionFunctionPaginationItemBg,
      height: t.heightPaginationItem,
      constraints: BoxConstraints(
        minWidth: widget.small
            ? t.widthPaginationItemSmallMinWidth
            : t.widthPaginationItemMinWidth,
      ),
      decoration: BoxDecoration(
        color: bg,
        border: Border.all(
          width: t.widthPaginationItemBorder,
          color: borderColor,
        ),
        borderRadius: BorderRadius.circular(t.radiusPaginationItem),
      ),
      child: content,
    );
    // pagination.scss:50 `transform:scale(...)`（token = scale(1,1) 恒等；
    // ★上游编译产物 transform:scale(scale(1,1)) 无效 CSS bug 留档）。
    content = Transform.scale(
      scaleX: t.transformScalePaginationItem.scaleX,
      scaleY: t.transformScalePaginationItem.scaleY,
      child: content,
    );
    // pagination.scss:38-39 / rtl.scss:8-11：margin 4 两侧（small 档 margin 归零）；
    // EdgeInsetsDirectional 天然完成 RTL 镜像。
    content = Padding(
      padding: EdgeInsetsDirectional.only(
        start: widget.small
            ? t.spacingPaginationItemSmallMargin
            : t.spacingPaginationItemMarginLeft,
        end: widget.small
            ? t.spacingPaginationItemSmallMargin
            : t.spacingPaginationItemMarginRight,
      ),
      child: content,
    );
    content = MouseRegion(
      // pagination.scss:35/:86 `cursor: pointer` / `not-allowed`。
      cursor: disabled
          ? SystemMouseCursors.forbidden
          : widget.onTap != null
          ? SystemMouseCursors.click
          : MouseCursor.defer,
      onEnter: disabled ? null : (_) => setState(() => _hover = true),
      onExit: disabled ? null : (_) => setState(() => _hover = false),
      child: content,
    );
    content = Listener(
      behavior: HitTestBehavior.opaque,
      onPointerDown: disabled || widget.onTap == null
          ? null
          : (_) => setState(() => _pressed = true),
      onPointerUp: disabled || widget.onTap == null
          ? null
          : (_) => setState(() => _pressed = false),
      onPointerCancel: disabled || widget.onTap == null
          ? null
          : (_) => setState(() => _pressed = false),
      child: content,
    );
    content = Focus(
      canRequestFocus: false,
      onKeyEvent: (node, event) {
        // 原生 `<button>` 的 Enter 语义（上游条目渲染 button，index.tsx:387-395）。
        if (event is KeyDownEvent &&
            event.logicalKey == LogicalKeyboardKey.enter &&
            !disabled &&
            widget.onTap != null) {
          widget.onTap!();
          return KeyEventResult.handled;
        }
        return KeyEventResult.ignored;
      },
      child: content,
    );
    content = GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: disabled ? null : widget.onTap,
      child: content,
    );
    return Semantics(
      button: widget.onTap != null,
      selected: widget.selected,
      enabled: !disabled,
      label: widget.semanticsLabel,
      child: content,
    );
  }
}

/// 省略号/摘要弹层里的一行（pagination.scss:175-202 `&-rest-item`）。
class _RestItem extends StatefulWidget {
  const _RestItem({required this.page, required this.t, required this.onTap});

  final int page;
  final SemiResolvedPaginationThemeData t;
  final VoidCallback onTap;

  @override
  State<_RestItem> createState() => _RestItemState();
}

class _RestItemState extends State<_RestItem> {
  bool _hover = false;
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final t = widget.t;
    // `&-rest-item`：行高 32、flex 居中、hover fill-0、active fill-1、
    // cursor: pointer（无文字色规则——沿用 text-0）。
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: widget.onTap,
        onTapDown: (_) => setState(() => _pressed = true),
        onTapUp: (_) => setState(() => _pressed = false),
        onTapCancel: () => setState(() => _pressed = false),
        child: AnimatedContainer(
          duration: t.transitionDurationPaginationItemBg,
          curve: t.transitionFunctionPaginationItemBg,
          height: _PaginationMetrics.restItemHeight,
          color: _pressed
              ? t.colorPaginationItemBgActive
              : _hover
              ? t.colorPaginationItemBgHover
              : null,
          alignment: Alignment.center,
          child: Text(
            '${widget.page}',
            style: TextStyle(
              fontSize: _PaginationMetrics.fontSizeRegular,
              color: t.colorPaginationItemTextDefault,
            ),
          ),
        ),
      ),
    );
  }
}

/// HARDCODES（另列）上游片段逐字留档（生成器 assertIn 锚点）+ motion 解析。
abstract final class _PaginationMetrics {
  /// pagination.scss:32 `@include font-size-regular`（mixin 来源 global
  /// `$font-size-regular` = 14——条目/总页数/跳转字号）。
  static const double fontSizeRegular = 14;

  /// constants.ts:10 `PAGE_SHOW_MAX: 7`（截断阈值）。
  static const int pageShowMax = 7;

  /// constants.ts:11 `REST_PAGE_SHOW_MAX: 5`（★声明未消费死常量留档）。
  // ignore: unused_field
  static const int restPageShowMaxUnused = 5;

  /// constants.ts:12 `DEFAULT_PAGE_SIZE: 10`。
  static const int defaultPageSize = 10;

  /// constants.ts:13 `PAGE_SIZE_OPTION: [10, 20, 40, 100]`。
  static const List<int> pageSizeOptions = [10, 20, 40, 100];

  /// constants.ts:14 `REST_PAGE_MAX_SIZE: 1000000`（rest 列表上限）。
  static const int restPageMaxSize = 1000000;

  /// index.tsx:441 `const itemHeight = 32`（react-window 行高）。
  static const double restItemHeight = 32;

  /// index.tsx:450 `width={78}`（react-window 列表宽）。
  static const double restListWidth = 78;

  /// index.tsx:442 `const listHeight = count >= 5 ? itemHeight * 5 : itemHeight
  /// * count`（最多 5 行可视）。
  static const int restListMaxRows = 5;

  /// popover/index.tsx:113 `position: 'bottom'`（Popover defaultProps 缺省位置）。
  static const SemiTooltipPosition popoverDefaultPosition =
      SemiTooltipPosition.bottom;

  /// popover/constants.ts `DEFAULT_Z_INDEX: 1030`（popoverZIndex 缺省）。
  static const int popoverZIndex = 1030;

  /// popover/constants.ts `SPACING: 4`（Popover 与触发器的间距）。
  static const double popoverSpacing = 4;

  /// zh_CN.ts:9 `pageSize: '每页条数：${pageSize}'`（locale 模板逐字留档；
  /// `pageSizeLabel` 按键替换 `${pageSize}`）。
  static String pageSizeLabel(int size) => '每页条数：$size';

  /// zh_CN.ts:11 `jumpTo: '跳至'`。
  static const String localeJumpTo = '跳至';

  /// zh_CN.ts:12 `page: '页'`。
  static const String localePage = '页';
}
