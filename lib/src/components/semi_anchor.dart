// SemiAnchor — 锚点（Semi Design 组件移植）。
//
// 上游：packages/semi-foundation/anchor/{variables.scss, animation.scss,
// anchor.scss, rtl.scss, foundation.ts, linkFoundation.ts, constants.ts}、
// packages/semi-ui/anchor/{index.tsx, link.tsx}。主题对账
// 30 = 26 FIELDS + 4 MOTION + 0 INTERNAL（tool/generate_anchor.py）——2 条死
// FIELDS（上游未消费）本文件不得出现其字段名（test_generate_anchor.py 断言）：
// `$color-anchor_slide_muted-bg-active`（全仓零消费）、
// `$spacing-anchor_link-paddingLeft`（scss 零消费，JS 硬编码 `8 * level` 顶替，
// link.tsx:150——本文件按 HARDCODE `8 * level` 实消费缩进但不得引用该字段名）。
// 4 条 MOTION 是活字段（anchor.scss:1 `@import "./animation.scss"` + :76-77
// 消费，0ms/ease-in/0ms/scale(1,1) 恒等）。
//
// HARDCODES（另列）上游片段以注释逐字留档在 `_AnchorMetrics` / 调用点，
// 生成器 HARDCODES 锚点断言这些片段出现在本文件。
import 'dart:async';

import 'package:flutter/rendering.dart' show OverflowBoxFit;
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import '../localization/semi_localizations.dart';
import '../overlay/tooltip_positioning.dart';
import '../theme/semi_anchor_theme.dart';
import '../theme/semi_anchor_theme_data.dart';
import 'semi_tooltip.dart';

/// 滑轨着色（上游 `strings.SLIDE_COLOR: ['primary', 'tertiary', 'muted']`）。
///
/// ★muted quirk：轨道 `display: none`（anchor.scss:22-24）且 bar 无背景规则
/// → 透明（anchor.scss:45-51 只给 -primary/-tertiary 背景）。
enum SemiAnchorRailTheme { primary, tertiary, muted }

/// 尺寸（上游 `strings.SIZE: ['small', 'default']`；`default` 是 Dart 保留字
/// → `defaultSize`）。
enum SemiAnchorSize { defaultSize, small }

/// 锚点链接（上游 `Link`，link.tsx）。
///
/// 以树形挂在 [SemiAnchor.children] 上（层级无限）；[SemiAnchor] 把这棵树当
/// 数据解释（上游 `renderChildren` 的 React 元素遍历），本体不独立挂载渲染。
class SemiAnchorLink extends StatelessWidget {
  const SemiAnchorLink({
    super.key,
    required this.href,
    this.title,
    this.children = const <Widget>[],
    this.disabled = false,
  });

  /// 目标锚（上游 CSS selector `'#id'`）。
  ///
  /// ★`'#'`/非法 id → scroll-spy 恒 `-Infinity` 永不激活（index.tsx:172-176
  /// try/catch quirk）；`'#'` 点击因上游 `document.querySelector('#')` 抛出而
  /// 惰性（foundation.ts:117 先抛后 setActiveLink）——本移植同为点击不激活。
  final String href;

  /// String 或 Widget。
  final Object? title;

  /// 子链接树。
  final List<Widget> children;

  /// 禁用：不可点/Enter 无效，但滚动到时照高亮（linkFoundation.ts:21-24 注册
  /// 不受 disabled 影响）。
  final bool disabled;

  @override
  Widget build(BuildContext context) => const SizedBox.shrink();
}

/// 滚动目标注册（上游 `document.querySelector(link)` 的 DOM id 查找——Flutter
/// 无 DOM，内容区块显式注册；见差异清单）。
///
/// [id] 与 [SemiAnchorLink.href] 对齐（`'#sec1'` 或 `'sec1'` 均可）。
class SemiAnchorTarget extends StatefulWidget {
  const SemiAnchorTarget({super.key, required this.id, required this.child});

  /// 目标 id（可带 `'#'` 前缀；内部归一化）。
  final String id;

  final Widget child;

  @override
  State<SemiAnchorTarget> createState() => _SemiAnchorTargetState();
}

class _SemiAnchorTargetState extends State<SemiAnchorTarget> {
  /// 上游 `document.querySelector(link)` 是 document 全局查找——目标注册表
  /// 全局同口径（目标通常与锚点平级、不在其子树内；重复 id 取首个注册 =
  /// DOM 顺序首匹配）。
  static final Map<String, List<_SemiAnchorTargetState>> registry = {};

  static String normalize(String id) =>
      id.startsWith('#') ? id.substring(1) : id;

  @override
  void initState() {
    super.initState();
    registry.putIfAbsent(normalize(widget.id), () => []).add(this);
  }

  @override
  void didUpdateWidget(covariant SemiAnchorTarget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.id != widget.id) {
      _unregister(normalize(oldWidget.id));
      registry.putIfAbsent(normalize(widget.id), () => []).add(this);
    }
  }

  @override
  void dispose() {
    _unregister(normalize(widget.id));
    super.dispose();
  }

  void _unregister(String id) {
    final targets = registry[id];
    if (targets == null) return;
    targets.remove(this);
    if (targets.isEmpty) registry.remove(id);
  }

  @override
  Widget build(BuildContext context) => widget.child;
}

/// 锚点。
///
/// scroll-spy（foundation.ts:97-114）：监听 [scrollController]，每 link 目标的
/// Globalized top 对容器顶减 [offsetTop]，取最大负值项为 active；★全 ≥0 →
/// active = null quirk（滑杆隐藏、`onChanged(null, prev)` 照发）。点击 title
/// （foundation.ts:116-126）：立即高亮 + 自算
/// `targetScroll = pixels + linkTop - containerTop - targetOffset`（★上游
/// `scroll-into-view-if-needed` 第三方——见差异清单），[scrollMotion] 时
/// animateTo 否则 jumpTo；点击置抑制旗标、滚动静止后复位。[defaultAnchor]
/// mount 时高亮+滚动但不发 [onChanged]/[onClick]（shouldNotify=false）。
class SemiAnchor extends StatefulWidget {
  const SemiAnchor({
    super.key,
    this.children = const <Widget>[],
    this.scrollController,
    this.defaultAnchor,
    this.targetOffset = 0,
    this.offsetTop = 0,
    this.scrollMotion = false,
    this.railTheme = SemiAnchorRailTheme.primary,
    this.size = SemiAnchorSize.defaultSize,
    this.autoCollapse = false,
    this.showTooltip = false,
    this.position,
    this.maxWidth = _AnchorMetrics.maxWidthDefault,
    this.maxHeight = _AnchorMetrics.maxHeightDefault,
    this.onChanged,
    this.onClick,
    this.semanticsLabel,
  });

  /// `SemiAnchorLink` 树（层级无限）。
  final List<Widget> children;

  /// 页面滚动容器（上游 `getContainer` —— window 无对应，见差异清单）。
  final ScrollController? scrollController;

  /// 初始高亮并滚动（不发 [onChanged]/[onClick]）。
  final String? defaultAnchor;

  /// 滚动落点补偿（点击落点 = 目标顶 - [targetOffset]）。
  final double targetOffset;

  /// spy 阈值补偿（目标 top 再减 [offsetTop]）。
  final double offsetTop;

  /// 点击滚动用动画（否则 jumpTo）。
  final bool scrollMotion;

  /// 滑轨着色。
  final SemiAnchorRailTheme railTheme;

  /// 字号/滑杆高两档。
  final SemiAnchorSize size;

  /// 仅展开 active 所在分支（link.tsx:126-135）。
  final bool autoCollapse;

  /// title 悬停出 tooltip（link.tsx renderTitle）。
  final bool showTooltip;

  /// tooltip 位置（SemiTooltip 缺省 top）。
  final SemiTooltipPosition? position;

  /// 根最大宽（constants.ts:10 `MAX_WIDTH: '200px'`）。
  final double maxWidth;

  /// 根最大高（constants.ts:11 `MAX_HEIGHT: '750px'`）。
  final double maxHeight;

  /// active 迁移回传（★current 可为 null——首项以上 quirk）。
  final void Function(String? current, String? previous)? onChanged;

  /// 点击 title 回传。
  final ValueChanged<String>? onClick;

  /// 根语义名（缺省 `'Side navigation'`，index.tsx:368）。
  final String? semanticsLabel;

  /// 滑杆（测试度量锚点）。
  static const Key slideBarKey = ValueKey('SemiAnchorSlideBar');

  /// 滑轨（测试度量锚点）。
  static const Key slideTrackKey = ValueKey('SemiAnchorSlideTrack');

  /// 根（测试度量锚点）。
  static const Key rootKey = ValueKey('SemiAnchorRoot');

  @override
  State<SemiAnchor> createState() => _SemiAnchorState();
}

class _SemiAnchorState extends State<SemiAnchor> {
  /// 上游 state.activeLink 初值 `''`（falsy → 滑杆隐藏）；spy 全 ≥0 时变
  /// `undefined` → Dart `null`（★首项以上 quirk）。
  String? _activeLink = '';

  /// 点击抑制旗标（foundation.ts:122 `setClickLinkWithCallBack`）。
  bool _clickLink = false;
  Timer? _clickResetTimer;

  /// 滑杆顶（激活 title 行的 offsetTop，foundation.ts:210-217）。
  double? _barTop;

  /// childMap：parent href → 后代 href 集合（foundation.ts:133-155）。
  final Map<String, Set<String>> _childMap = {};

  /// title 行注册（href → 行 state；同 href 多行取首注册行 = DOM querySelector
  /// 首匹配语义）。
  final Map<String, List<_AnchorRowState>> _rows = {};

  /// 可见 href 表（DFS 序 = 上游 links 注册序；autoCollapse 隐藏分支不注册
  /// ——上游 unmount 即 removeLink 同口径）。
  List<String> _visibleLinks = const [];

  final GlobalKey _contentKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    widget.scrollController?.addListener(_handleScroll);
    // componentDidMount：Boolean(defaultAnchor) && handleClick(null,
    // defaultAnchor, false)（index.tsx:279）。
    final defaultAnchor = widget.defaultAnchor;
    if (defaultAnchor != null && defaultAnchor.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _activate(defaultAnchor, shouldNotify: false);
      });
    }
  }

  @override
  void didUpdateWidget(covariant SemiAnchor oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.scrollController != widget.scrollController) {
      oldWidget.scrollController?.removeListener(_handleScroll);
      widget.scrollController?.addListener(_handleScroll);
    }
  }

  @override
  void dispose() {
    widget.scrollController?.removeListener(_handleScroll);
    _clickResetTimer?.cancel();
    super.dispose();
  }

  // -- row registry ----------------------------------------------------------

  void _registerRow(String href, _AnchorRowState row) {
    _rows.putIfAbsent(href, () => []).add(row);
  }

  void _unregisterRow(String href, _AnchorRowState row) {
    final rows = _rows[href];
    if (rows == null) return;
    rows.remove(row);
    if (rows.isEmpty) _rows.remove(href);
  }

  double _effectiveFontSize() => widget.size == SemiAnchorSize.small
      ? _AnchorMetrics.fontSizeSmall
      : _AnchorMetrics.fontSizeRegular;

  RenderBox? _targetBox(String href) {
    if (href.isEmpty || href == '#') return null;
    final targets =
        _SemiAnchorTargetState.registry[_SemiAnchorTargetState.normalize(href)];
    final box = (targets == null || targets.isEmpty)
        ? null
        : targets.first.context.findRenderObject();
    return box is RenderBox && box.hasSize ? box : null;
  }

  RenderBox? _viewportBox() {
    final controller = widget.scrollController;
    if (controller == null || !controller.hasClients) return null;
    final position = controller.position;
    final context =
        position.context.notificationContext ?? position.context.storageContext;
    final box = context.findRenderObject();
    return box is RenderBox && box.hasSize ? box : null;
  }

  // -- scroll-spy ------------------------------------------------------------

  /// foundation.ts:97-114 `handleScroll`。
  void _handleScroll() {
    if (_clickLink) {
      // 点击抑制旗标期间跳过高亮（foundation.ts:100-102），滚动事件续期静止
      // 复位计时（上游 debounce 100ms——差异清单）。
      _armClickReset();
      return;
    }
    final viewport = _viewportBox();
    if (viewport == null) return;
    final containerTop = viewport.localToGlobal(Offset.zero).dy;
    double lastNegative = double.negativeInfinity;
    int lastNegativeIndex = -1;
    for (var i = 0; i < _visibleLinks.length; i++) {
      final box = _targetBox(_visibleLinks[i]);
      // ★`'#'`/非法 id/缺目标 → -Infinity 永不激活（index.tsx:172-176
      // try/catch quirk：`document.querySelector(link)` 抛出/空 →
      // `|| -Infinity`）。
      final top = box == null
          ? double.negativeInfinity
          : box.localToGlobal(Offset.zero).dy - containerTop - widget.offsetTop;
      if (top < 0 && top > lastNegative) {
        lastNegative = top;
        lastNegativeIndex = i;
      }
    }
    // ★全 ≥0 → links[-1] = undefined → active = null quirk（滑杆隐藏、
    // onChanged(null, prev) 照发）。
    final active = lastNegativeIndex < 0
        ? null
        : _visibleLinks[lastNegativeIndex];
    _setActiveLink(active, _activeLink);
  }

  /// foundation.ts:45-54 `setActiveLink`。
  void _setActiveLink(
    String? link,
    String? previous, {
    bool shouldNotify = true,
  }) {
    if (_activeLink == link) return;
    setState(() => _activeLink = link);
    _scheduleBarUpdate();
    if (shouldNotify) widget.onChanged?.call(link, previous);
  }

  // -- click -----------------------------------------------------------------

  /// link.tsx:168-172 Enter / 点击进入（disabled 行无 onTap 不达）。★`'#'` 点击
  /// 惰性——上游 `document.querySelector('#')` 在 foundation.ts:117 先抛出，
  /// setActiveLink 不达 → 永不激活。
  void _activate(String href, {required bool shouldNotify}) {
    if (href.isEmpty || href == '#') return;
    final previous = _activeLink;
    _setActiveLink(href, previous, shouldNotify: shouldNotify);
    if (_targetBox(href) != null) {
      // foundation.ts:122 `setClickLinkWithCallBack(true, ...)`。
      _clickLink = true;
      _armClickReset();
      _scrollIntoView(href);
    }
    // ★缺目标的合法 id 点击仍高亮 + 发 onClick（current-location.test.js 口径）。
    if (shouldNotify) widget.onClick?.call(href);
  }

  /// foundation.ts:157-208 `_scrollIntoView`（★上游 scroll-into-view-if-needed
  /// 第三方 + smooth/auto 条件——自算 offset，见差异清单）。
  void _scrollIntoView(String href) {
    final controller = widget.scrollController;
    if (controller == null || !controller.hasClients) return;
    final box = _targetBox(href);
    final viewport = _viewportBox();
    if (box == null || viewport == null) return;
    final position = controller.position;
    final linkTop =
        box.localToGlobal(Offset.zero).dy -
        viewport.localToGlobal(Offset.zero).dy;
    // targetScroll = pixels + linkTop - containerTop - targetOffset。
    final target = (position.pixels + linkTop - widget.targetOffset).clamp(
      position.minScrollExtent,
      position.maxScrollExtent,
    );
    if (widget.scrollMotion) {
      position.animateTo(
        target,
        duration: _AnchorMetrics.scrollMotionDuration,
        curve: _AnchorMetrics.scrollMotionCurve,
      );
    } else {
      position.jumpTo(target);
    }
  }

  /// 上游 `debounce(handleClickLink, 100)`（index.tsx:275）→ 滚动静止 100ms 后
  /// 复位抑制旗标；★点击即起计时（上游仅滚动事件触发 debounce——差异清单）。
  void _armClickReset() {
    _clickResetTimer?.cancel();
    _clickResetTimer = Timer(_AnchorMetrics.clickResetDelay, () {
      _clickLink = false;
    });
  }

  // -- slide bar -------------------------------------------------------------

  /// foundation.ts:210-217 `_setActiveSlide`：bar top = 激活 title 的
  /// offsetTop（内容坐标）。
  void _scheduleBarUpdate() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      double? top;
      final href = _activeLink;
      if (href != null && href.isNotEmpty) {
        final row = _rows[href]?.first;
        final rowBox = row?.context.findRenderObject();
        final stackBox = _contentKey.currentContext?.findRenderObject();
        if (rowBox is RenderBox &&
            rowBox.hasSize &&
            stackBox is RenderBox &&
            stackBox.hasSize) {
          top =
              rowBox.localToGlobal(Offset.zero).dy -
              stackBox.localToGlobal(Offset.zero).dy;
        }
      }
      if (top != _barTop) setState(() => _barTop = top);
    });
  }

  // -- tree walk -------------------------------------------------------------

  /// foundation.ts:74-93 `setChildMap` / :133-155 `_getLinkToMap`。
  void _buildChildMap() {
    _childMap.clear();
    void walk(List<Widget> links, List<String> parents) {
      for (final item in links) {
        if (item is! SemiAnchorLink) continue;
        final href = item.href;
        if (href.isNotEmpty) {
          _childMap.putIfAbsent(href, () => <String>{});
          for (final parent in parents) {
            _childMap.putIfAbsent(parent, () => <String>{}).add(href);
          }
        }
        walk(
          item.children,
          href.isNotEmpty ? <String>[...parents, href] : parents,
        );
      }
    }

    walk(widget.children, const []);
  }

  /// index.tsx:246-269 `renderChildren`（level 从 1 起；React Fragment 同级 →
  /// children 列表天然）+ link.tsx:126-135 autoCollapse 展开条件。
  List<Widget> _renderLinks(List<Widget> links, double level) {
    final out = <Widget>[];
    for (final item in links) {
      if (item is! SemiAnchorLink) continue;
      final href = item.href;
      _visibleLinks.add(href);
      final active = _activeLink == href;
      out.add(
        _AnchorRow(
          href: href,
          title: item.title,
          level: level,
          active: active,
          disabled: item.disabled,
          showTooltip: widget.showTooltip,
          position: widget.position,
          fontSize: _effectiveFontSize(),
          onTap: item.disabled
              ? null
              : () => _activate(href, shouldNotify: true),
        ),
      );
      final expanded =
          !widget.autoCollapse ||
          active ||
          (_childMap[href]?.contains(_activeLink) ?? false);
      if (expanded && item.children.isNotEmpty) {
        out.addAll(_renderLinks(item.children, level + 1));
      }
    }
    return out;
  }

  @override
  Widget build(BuildContext context) {
    final SemiResolvedAnchorThemeData t = SemiAnchorTheme.resolve(context);
    _buildChildMap();
    _visibleLinks = <String>[];
    // level 从 1 起（index.tsx:247 `loop = (children, level = 1)`）。
    final rows = _renderLinks(widget.children, 1);
    // 滑杆高 = 选项高 + 2 × 选项间距（anchor.scss:38/:42 计算式；28/24）。
    final barHeight = widget.size == SemiAnchorSize.small
        ? t.heightAnchorSlideSmall + 2 * t.spacingAnchorSlideSmallY
        : t.heightAnchorSlideDefault + 2 * t.spacingAnchorSlideDefaultY;
    final slideColor = widget.railTheme == SemiAnchorRailTheme.primary
        ? t.colorAnchorSlidePrimaryBgActive
        : t.colorAnchorSlideTertiaryBgActive;
    final barVisible = _activeLink != null && _activeLink!.isNotEmpty;
    return Semantics(
      label:
          widget.semanticsLabel ?? SemiLocalizations.of(context).sideNavigation,
      container: true,
      child: ConstrainedBox(
        key: SemiAnchor.rootKey,
        constraints: BoxConstraints(
          maxWidth: widget.maxWidth,
          maxHeight: widget.maxHeight,
        ),
        child: _AnchorScope(
          state: this,
          child: SingleChildScrollView(
            // overflow-y: auto（anchor.scss:8）+ position: relative（:10）。
            child: Stack(
              key: _contentKey,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: rows,
                ),
                // ★muted：轨道 `display: none`（anchor.scss:22-24）+ bar 无背景
                // 规则 → 透明 quirk（:45-51 只给 -primary/-tertiary 背景）——
                // 整棵滑轨子树不渲染。
                if (widget.railTheme != SemiAnchorRailTheme.muted) ...[
                  PositionedDirectional(
                    start: t.spacingAnchorSlideLeft,
                    top: t.spacingAnchorSlideTop,
                    bottom: 0,
                    width: t.widthAnchorSlideDefault,
                    child: DecoratedBox(
                      key: SemiAnchor.slideTrackKey,
                      // ★零尺寸 DecoratedBox 陷阱（semi_color_picker.dart:955-968
                      // 先例）。
                      decoration: BoxDecoration(
                        color: t.colorAnchorSlideDefaultBgDefault,
                        borderRadius: BorderRadius.circular(
                          t.radiusAnchorSlide,
                        ),
                      ),
                      child: const SizedBox.expand(),
                    ),
                  ),
                  if (barVisible)
                    PositionedDirectional(
                      start: t.spacingAnchorSlideLeft,
                      top: t.spacingAnchorSlideTop + (_barTop ?? 0),
                      width: t.widthAnchorSlideDefault,
                      height: barHeight,
                      child: DecoratedBox(
                        key: SemiAnchor.slideBarKey,
                        decoration: BoxDecoration(
                          color: slideColor,
                          borderRadius: BorderRadius.circular(
                            t.radiusAnchorSlide,
                          ),
                        ),
                        child: const SizedBox.expand(),
                      ),
                    ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _AnchorScope extends InheritedWidget {
  const _AnchorScope({required this.state, required super.child});

  final _SemiAnchorState state;

  static _SemiAnchorState? maybeOf(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<_AnchorScope>()?.state;

  @override
  bool updateShouldNotify(_AnchorScope oldWidget) => state != oldWidget.state;
}

/// title 行（link.tsx:137-179）。hover/focus 态行内自治。
class _AnchorRow extends StatefulWidget {
  const _AnchorRow({
    required this.href,
    required this.title,
    required this.level,
    required this.active,
    required this.disabled,
    required this.showTooltip,
    required this.position,
    required this.fontSize,
    required this.onTap,
  });

  final String href;
  final Object? title;
  final double level;
  final bool active;
  final bool disabled;
  final bool showTooltip;
  final SemiTooltipPosition? position;
  final double fontSize;
  final VoidCallback? onTap;

  @override
  State<_AnchorRow> createState() => _AnchorRowState();
}

class _AnchorRowState extends State<_AnchorRow> {
  bool _hover = false;
  bool _focused = false;
  late final FocusNode _focusNode;
  _SemiAnchorState? _anchor;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode(debugLabel: 'SemiAnchorTitle ${widget.href}');
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final anchor = _AnchorScope.maybeOf(context);
    if (!identical(anchor, _anchor)) {
      _anchor?._unregisterRow(widget.href, this);
      _anchor = anchor;
      _anchor?._registerRow(widget.href, this);
    }
  }

  @override
  void didUpdateWidget(covariant _AnchorRow oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.href != widget.href) {
      _anchor?._unregisterRow(oldWidget.href, this);
      _anchor?._registerRow(widget.href, this);
    }
  }

  @override
  void dispose() {
    _anchor?._unregisterRow(widget.href, this);
    _focusNode.dispose();
    super.dispose();
  }

  /// link.tsx:168-172：Enter 激活，Space/可打印键忽略（keyboardActivation 测试）。
  KeyEventResult _onKey(FocusNode node, KeyEvent event) {
    if (event is KeyDownEvent &&
        event.logicalKey == LogicalKeyboardKey.enter &&
        widget.onTap != null) {
      widget.onTap!();
      return KeyEventResult.handled;
    }
    return KeyEventResult.ignored;
  }

  @override
  Widget build(BuildContext context) {
    final SemiResolvedAnchorThemeData t = SemiAnchorTheme.resolve(context);
    final level = widget.level;
    // ★anchor.scss:98-101 -disabled 后声明覆盖 -active 色 quirk：disabled 色
    // 压过 active/hover。
    final Color color = widget.disabled
        ? t.colorAnchorTitleTextDisabled
        : widget.active
        ? (_hover
              ? t.colorAnchorTitleActiveTextHover
              : t.colorAnchorTitleTextActive)
        : (_hover
              ? t.colorAnchorTitleTextHover
              : t.colorAnchorTitleTextDefault);
    Widget content;
    final title = widget.title;
    if (title is Widget) {
      content = title;
    } else {
      content = OverflowBox(
        // deferToChild keeps the box hugging the text (semi_tag.dart:350-363
        // 先例)；width 约束保留（ellipsis 生效）。
        fit: OverflowBoxFit.deferToChild,
        minHeight: 0,
        maxHeight: double.infinity,
        child: Text(
          title?.toString() ?? '',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          // ★禁设 TextStyle.height（仓库硬规则 1）——自然度量盒 + padding。
          style: TextStyle(fontSize: widget.fontSize, color: color),
        ),
      );
    }
    if (widget.showTooltip) {
      // link.tsx renderTitle 的 Typography.Text ellipsis tooltip 语义；tooltip
      // 内容色直接用主题字段（anchor.scss:108-126 `!important` 覆色片段留档于
      // `_AnchorMetrics`）。
      content = SemiTooltip(
        trigger: SemiTooltipTrigger.hover,
        position: widget.position ?? SemiTooltipPosition.top,
        content: Text(
          title is String ? title : '',
          style: TextStyle(fontSize: widget.fontSize, color: color),
        ),
        child: content,
      );
    }
    return Semantics(
      link: true,
      enabled: !widget.disabled,
      selected: widget.active,
      label: title is String ? title : null,
      child: MouseRegion(
        // link.tsx:68 `cursor: pointer` / :99 `cursor: not-allowed`。
        cursor: widget.disabled
            ? SystemMouseCursors.forbidden
            : SystemMouseCursors.click,
        onEnter: (_) => setState(() => _hover = true),
        onExit: (_) => setState(() => _hover = false),
        child: Focus(
          focusNode: _focusNode,
          onKeyEvent: _onKey,
          onFocusChange: (focused) => setState(() => _focused = focused),
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: widget.onTap,
            child: Transform.scale(
              // anchor.scss:77 `transform: scale($transform_scale-anchor_title-text)`（恒等 scale(1,1)——生成域首例 SemiTransform 消费）。
              scaleX: t.transformScaleAnchorTitleText.scaleX,
              scaleY: t.transformScaleAnchorTitleText.scaleY,
              child: AnimatedContainer(
                // anchor.scss:76 `transition: color $transition_duration-anchor_title-text $transition_function-anchor_title-text $transition_delay-anchor_title-text`——duration/curve 槽消费；`transitionDelayAnchorTitleText` 无 delay 槽 → 注释引用（docs 注明）。
                duration: t.transitionDurationAnchorTitleText,
                curve: t.transitionFunctionAnchorTitleText,
                decoration: BoxDecoration(
                  color: widget.active
                      ? t.colorAnchorTitleBgActive
                      : t.colorAnchorTitleBgDefault,
                  borderRadius: BorderRadius.circular(
                    t.widthAnchorOutlineBorderRadius,
                  ),
                  border: _focused
                      ? Border.all(
                          // anchor.scss:92-95 `outline: $width-anchor-outline solid $color-anchor_title-outline-focus`（style 固定 `solid`）+ `outline-offset: $width-anchor-outlineOffset`——-2px 内偏移以 Border 内描边近似。
                          width: t.widthAnchorOutline,
                          color: t.colorAnchorTitleOutlineFocus,
                        )
                      : null,
                ),
                child: ClipRect(
                  // anchor.scss:72-74 `overflow: hidden; text-overflow: ellipsis; white-space: nowrap;`。
                  child: Padding(
                    padding: EdgeInsetsDirectional.only(
                      top: t.spacingAnchorLinkTitlePaddingTop,
                      bottom: t.spacingAnchorLinkTitlePaddingBottom,
                      // link.tsx:150 `8 * level`（缩进硬编码顶替死变量；RTL 翻 paddingRight —— rtl.scss:13-15，其中 `padding-left: auto` 为无效 CSS 死声明 note-only）。
                      start: 8 * level,
                    ),
                    child: content,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// HARDCODES（另列）上游片段逐字留档（生成器 assertIn 锚点）。
abstract final class _AnchorMetrics {
  /// `@include font-size-small` → `$font-size-small: 12px`
  /// （packages/semi-theme-default/scss/mixin.scss；anchor.scss:13/:111）。
  static const double fontSizeSmall = 12;

  /// `@include font-size-regular`（anchor.scss:7 根字号）→
  /// `$font-size-regular: 14px`（mixin.scss）。
  static const double fontSizeRegular = 14;

  /// constants.ts:10-11 —— `MAX_WIDTH: '200px'` / `MAX_HEIGHT: '750px'`。
  static const double maxWidthDefault = 200;
  static const double maxHeightDefault = 750;

  /// 上游 `debounce(handleClickLink, 100)`（index.tsx:275）。
  static const Duration clickResetDelay = Duration(milliseconds: 100);

  /// ★自决点：上游 `el.scroll({ top, behavior: 'smooth' })` 为浏览器原生平滑
  /// （无时长参数）——本移植取 300ms/easeOutCubic（差异清单）。
  static const Duration scrollMotionDuration = Duration(milliseconds: 300);
  static const Curve scrollMotionCurve = Curves.easeOutCubic;

  // -- HARDCODES（另列）上游片段逐字留档（生成器 assertIn 锚点）--------------
  //
  // link.tsx:150 `8 * level`（title 缩进——JS 硬编码顶替
  // `$spacing-anchor_link-paddingLeft` 死变量；调用点 `_AnchorRow.build`）。
  //
  // anchor.scss:72-74
  //     overflow: hidden; text-overflow: ellipsis; white-space: nowrap;
  // （title 单行省略——Text overflow/maxLines + ClipRect）。
  //
  // anchor.scss:68 `cursor: pointer`（title 可点光标）→
  // MouseRegion(SystemMouseCursors.click)。
  //
  // anchor.scss:99/:124 `cursor: not-allowed`（disabled 光标）→
  // MouseRegion(SystemMouseCursors.forbidden)。
  //
  // anchor.scss:92-95 focus-visible
  //     outline: $width-anchor-outline solid $color-anchor_title-outline-focus
  //     outline-offset: $width-anchor-outlineOffset
  // （style 固定 `solid`；-2px 内偏移以 Border 内描边近似）。
  //
  // anchor.scss:54-61 轨道伪元素 `content: ' ';`（::before 轨道 → 真实
  // DecoratedBox）。
  //
  // anchor.scss:22-24 muted 轨道 / :27 bar 默认 `display: none`（muted 整棵
  // 滑轨不渲染；bar 无 active 不渲染）。
  //
  // anchor.scss:38 滑杆高计算式 `height: $height-anchor_slide_default + 2 * $spacing-anchor_slide_default-Y`
  // anchor.scss:42 滑杆高计算式 `height: $height-anchor_slide_small + 2 * $spacing-anchor_slide_small-Y`
  // （28/24 = 选项高 + 2 × 选项间距）。
  //
  // anchor.scss:77 `transform: scale($transform_scale-anchor_title-text)`（恒等
  // scale(1,1) → Transform.scale 消费 SemiTransform 字段）。
  //
  // anchor.scss:76 `transition: color $transition_duration-anchor_title-text $transition_function-anchor_title-text $transition_delay-anchor_title-text`
  // （MOTION 三元组消费点——AnimatedContainer duration/curve；delay 无槽注释
  // 引用）。
  //
  // anchor.scss:108/:115/:119/:123/:126 tooltip 覆色（!important 压过
  // Typography.Text 的 type 色——Flutter 侧 tooltip 内容色直接用同名主题字段）：
  //     color: $color-anchor_title-text-default !important
  //     color: $color-anchor_title-text-hover !important
  //     color: $color-anchor_title-text-active !important
  //     color: $color-anchor_title-text-disabled !important
  //
  // index.tsx:368 缺省语义名 `'Side navigation'`（aria-label 缺省；调用点
  // `SemiAnchor.build` Semantics）。
  //
  // rtl.scss:13-15 RTL 下 `&-link { padding-left: auto; }` —— `padding-left: auto`
  // 为无效 CSS 死声明（note-only；方向互换由 EdgeInsetsDirectional 承担）。
}
