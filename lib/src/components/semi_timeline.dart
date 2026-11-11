import 'package:flutter/widgets.dart';

import '../theme/semi_timeline_theme.dart';
import '../theme/semi_timeline_theme_data.dart';
import 'typography/semi_text.dart';

/// Upstream `mode` (`packages/semi-ui/timeline/index.tsx`): which side the axis
/// and the content slots take.
enum SemiTimelineMode { left, right, center, alternate }

/// Upstream `type` (`packages/semi-ui/timeline/item.tsx`); `normal` is upstream
/// `'default'` (renamed so the enum does not shadow Dart's `default`).
enum SemiTimelineItemType { normal, ongoing, success, warning, error }

/// Upstream `position` (`packages/semi-ui/timeline/item.tsx`): selects the
/// `semi-timeline-item-left` / `-item-right` class of `getPosCls`. The class
/// names the axis/time side relative to the content, so `left` puts the content
/// on the physical end side (right in LTR) and `right` on the start side.
enum SemiTimelinePosition { left, right }

/// One `Timeline.Item` (`dataSource` row or `children` item upstream).
@immutable
class SemiTimelineItemData {
  const SemiTimelineItemData({
    required this.content,
    this.time,
    this.extra,
    this.type = SemiTimelineItemType.normal,
    this.dot,
    this.color,
    this.position,
    this.onTap,
  }) : assert(
         content is String || content is Widget,
         'content must be a String or a Widget',
       ),
       assert(
         time == null ||
             time == false ||
             time is String ||
             time is Widget ||
             time is num,
         'time must be a String, a Widget, a num, false or null',
       ),
       assert(
         extra == null ||
             extra == false ||
             extra is String ||
             extra is Widget ||
             extra is num,
         'extra must be a String, a Widget, a num, false or null',
       );

  /// Required item body: a [String] (rendered as `SemiText` 14/20) or a
  /// [Widget] placed as-is. Upstream `children`/`content`.
  final Object? content;

  /// Timestamp slot. [String] renders as `SemiText` 12/16, [num] renders its
  /// `toString()` (0 renders `'0'`), [Widget] is placed as-is. `false`, null,
  /// the empty string and `num.nan` render no container at all (upstream
  /// `time || time === 0` zero-metadata semantics).
  final Object? time;

  /// Auxiliary description above [time]; same value and visibility rules.
  final Object? extra;

  /// Dot color preset. `normal` is upstream `default`.
  final SemiTimelineItemType type;

  /// Custom dot, centered on the head anchor with `FractionalTranslation`.
  /// Replaces the 9x9 circle; the head background becomes
  /// `colorTimelineItemHeadBg` (transparent) unless [color] is set.
  final Widget? dot;

  /// Inline dot background, overriding [type] — and, as upstream's inline
  /// `style`, also overriding the transparent custom-dot background.
  final Color? color;

  /// Explicit side override, honored in `alternate` and `center` modes only
  /// (replicates upstream `getPosCls`; `left`/`right` modes keep every item on
  /// the mode's side).
  final SemiTimelinePosition? position;

  /// Row tap callback; renders the row as one semantics button.
  final VoidCallback? onTap;
}

/// The 14 formula-valued Sass variables that stay out of the theme: they are
/// layout formulas (`calc()`, `auto`, percentages, transforms) rather than
/// overridable scalars. See docs/semi_timeline.md for the full mapping.
abstract final class _TimelineMetrics {
  /// `$spacing-timeline_item_content_time-marginLeft: calc(-40px - 100%)` in packages/semi-foundation/timeline/variables.scss.
  /// Constant term of the center-mode time shift: its end edge sits 40px plus
  /// one content width left of the content edge.
  static const double itemContentTimeMarginLeft = -40;

  /// `$spacing-timeline_item_right_item-left: calc(100% - 9px)` in packages/semi-foundation/timeline/variables.scss.
  /// Right-mode axis inset from the item's end edge.
  static const double itemRightItemLeftInset = 9;

  /// `$spacing-timeline_item_left_item_content-left: calc(50% - 4px)` in packages/semi-foundation/timeline/variables.scss.
  /// Nominal start of the end-side content slot. Upstream stacks the 25px
  /// content margin and a `position: relative` shift on top of this, rendering
  /// at 50% + 21 with a ~7px overflow; the port starts the slot 6px past the
  /// axis instead (see `_axisContentGap` and docs/semi_timeline.md). The
  /// nominal edge still anchors the center-mode time formula.
  static const double itemLeftItemContentLeft = -4;

  /// `$spacing-timeline_item_head_custom-left: 50%` in packages/semi-foundation/timeline/variables.scss.
  /// Center/alternate axis position as a width fraction.
  static const double itemHeadCustomLeftFraction = 0.5;

  /// `$width-timeline: 100%` in packages/semi-foundation/timeline/variables.scss.
  static const double widthTimeline = 1;

  /// `$width-timeline_head_custom: auto` in packages/semi-foundation/timeline/variables.scss.
  /// `auto`: the custom dot sizes to its child (null width).
  static const double? widthTimelineHeadCustom = null;

  /// `$width-timeline_item_content_time: 100%` in packages/semi-foundation/timeline/variables.scss.
  /// Center-mode time width as a factor of the content width.
  static const double itemContentTimeWidthFactor = 1;

  /// `$width-timeline_item_right_content: calc(100% - 28px)` in packages/semi-foundation/timeline/variables.scss.
  /// Right-mode content inset from the end edge.
  static const double itemRightContentInset = 28;

  /// `$width-timeline_item_left_item_content: calc(50% - 14px)` in packages/semi-foundation/timeline/variables.scss.
  /// End-side content slot: half the width minus this inset.
  static const double itemLeftItemContentWidthInset = 14;

  /// `$width-timeline_item_right_item_content: calc(50% - 20px)` in packages/semi-foundation/timeline/variables.scss.
  /// Start-side content slot: half the width minus this inset.
  static const double itemRightItemContentWidthInset = 20;

  /// `$height-timline_tail: calc(100% - 20px)` in packages/semi-foundation/timeline/variables.scss.
  /// Tail length is the item height minus this inset (upstream spells it
  /// `timline`, kept verbatim).
  static const double timlineTailHeightInset = 20;

  /// `$height-timeline_head_custom: auto` in packages/semi-foundation/timeline/variables.scss.
  /// `auto`: the custom dot sizes to its child (null height).
  static const double? heightTimelineHeadCustom = null;

  /// `$motion-timeline_head_custom-transform: translate(-50%, -50%)` in packages/semi-foundation/timeline/variables.scss.
  /// Centers the custom dot on its start-edge anchor (LTR).
  static const Offset headCustomTranslation = Offset(-0.5, -0.5);

  /// `$motion-timeline_head_custom-transform-rtl: translate(50%, -50%)` in packages/semi-foundation/timeline/variables.scss.
  /// Centers the custom dot when the anchor is its end edge (RTL or end
  /// positions); picked with `rtl == startAnchored` below.
  static const Offset headCustomTranslationRtl = Offset(0.5, -0.5);
}

/// End-side content slot gap past the axis. Upstream nominally starts the slot
/// at `calc(50% - 4px)` but its relative-offset + margin stacking renders it at
/// 50% + 21 and overflows the item by ~7px. The port implements the intended
/// "starts 4~6px right of the axis" geometry and takes 6 — the top of that
/// range — to clear the 9px dot (right edge 50% + 5).
const double _axisContentGap = 6;

/// Vertical list of [SemiTimelineItemData] rows connected by a tail line.
///
/// Mirrors upstream `packages/semi-ui/timeline/{index,item}.tsx` and
/// `packages/semi-foundation/timeline/{timeline,rtl}.scss` without Material.
/// Upstream `children`/`dataSource` both map to [items]; `className`/`style`
/// are not ported. Rows render content, then `extra`, then `time`
/// (zero-metadata semantics: `0`/`'0'` render, `false`/null/empty hide the
/// container). `pending` and interactive folding are not part of the upstream
/// component and are not ported.
class SemiTimeline extends StatelessWidget {
  const SemiTimeline({
    super.key,
    this.mode = SemiTimelineMode.left,
    this.items = const [],
    this.semanticsLabel,
  });

  /// Axis/content arrangement; upstream `mode`, default `left`.
  final SemiTimelineMode mode;

  /// Rows, rendered block-level one per line like upstream `li` elements.
  final List<SemiTimelineItemData> items;

  /// Region label for the whole timeline (upstream `aria-label`).
  final String? semanticsLabel;

  /// Replicates upstream `getPosCls`: `alternate` alternates by index parity
  /// (even `left`, odd `right`), `center` defaults to `left`, `left`/`right`
  /// modes pin every row to the mode's side and ignore [SemiTimelineItemData.position].
  SemiTimelinePosition _positionFor(int index) {
    final explicit = items[index].position;
    switch (mode) {
      case SemiTimelineMode.alternate:
        return explicit ??
            (index.isEven
                ? SemiTimelinePosition.left
                : SemiTimelinePosition.right);
      case SemiTimelineMode.center:
        return explicit ?? SemiTimelinePosition.left;
      case SemiTimelineMode.left:
      case SemiTimelineMode.right:
        return mode == SemiTimelineMode.left
            ? SemiTimelinePosition.left
            : SemiTimelinePosition.right;
    }
  }

  static bool _slotVisible(Object? value) =>
      value != null &&
      value != false &&
      !(value is String && value.isEmpty) &&
      !(value is num && value.isNaN);

  static Color _typeColor(
    SemiResolvedTimelineThemeData theme,
    SemiTimelineItemType type,
  ) => switch (type) {
    // Reversed upstream names: `ongoing` uses `$color-timeline_dot_default-*`,
    // `normal` (upstream `default`) uses `$color-timeline_dot_info-*`.
    SemiTimelineItemType.ongoing => theme.colorTimelineDotDefaultBgDefault,
    SemiTimelineItemType.normal => theme.colorTimelineDotInfoBgDefault,
    SemiTimelineItemType.success => theme.colorTimelineDotSuccessBgDefault,
    SemiTimelineItemType.warning => theme.colorTimelineDotWarningBgDefault,
    SemiTimelineItemType.error => theme.colorTimelineDotErrorBgDefault,
  };

  Widget _slotNode(
    SemiResolvedTimelineThemeData theme,
    Object? value, {
    required bool meta,
    TextAlign? textAlign,
  }) {
    if (value is String || value is num) {
      return SemiText(
        value.toString(),
        size: meta ? SemiTextSize.small : SemiTextSize.normal,
        style: TextStyle(
          color: meta
              ? theme.colorTimelineTimeDefaultTextDefault
              : theme.colorTimelineItemContentTextDefault,
        ),
        textAlign: textAlign,
      );
    }
    return value! as Widget;
  }

  /// content -> extra -> time, matching upstream render order.
  List<Widget> _contentNodes(
    SemiResolvedTimelineThemeData theme,
    SemiTimelineItemData item, {
    required TextAlign? textAlign,
    required bool timeInFlow,
  }) => [
    _slotNode(theme, item.content, meta: false, textAlign: textAlign),
    if (_slotVisible(item.extra))
      Padding(
        padding: EdgeInsetsDirectional.only(
          top: theme.spacingTimelineTimeMarginTop,
        ),
        child: _slotNode(theme, item.extra, meta: true, textAlign: textAlign),
      ),
    if (timeInFlow && _slotVisible(item.time))
      Padding(
        padding: EdgeInsetsDirectional.only(
          top: theme.spacingTimelineTimeMarginTop,
        ),
        child: _slotNode(theme, item.time, meta: true, textAlign: textAlign),
      ),
  ];

  Widget _buildItem(
    BuildContext context,
    SemiResolvedTimelineThemeData theme,
    int index,
  ) {
    final item = items[index];
    final position = _positionFor(index);
    final last = index == items.length - 1;
    final splitMode =
        mode == SemiTimelineMode.center || mode == SemiTimelineMode.alternate;
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final bounded = width.isFinite;
        // Percentage slots need a finite width; unbounded center/alternate
        // fall back to the single start-side gutter without guessing widths.
        final split = splitMode && bounded;
        final rtl = Directionality.of(context) == TextDirection.rtl;

        // Axis offsets as directional insets so RTL mirrors naturally.
        final double? axisStart;
        final double? axisEnd;
        if (mode == SemiTimelineMode.right && !split) {
          axisStart = null;
          axisEnd =
              _TimelineMetrics.itemRightItemLeftInset -
              theme.widthTimelineTailBorder;
        } else {
          axisStart = split
              ? width * _TimelineMetrics.itemHeadCustomLeftFraction
              : theme.spacingTimelineTailLeft;
          axisEnd = null;
        }

        final column = Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: bounded
              ? CrossAxisAlignment.stretch
              : CrossAxisAlignment.start,
          children: _contentNodes(
            theme,
            item,
            textAlign: split
                ? (position == SemiTimelinePosition.left
                      ? TextAlign.start
                      : TextAlign.end)
                : (mode == SemiTimelineMode.right
                      ? TextAlign.end
                      : TextAlign.start),
            timeInFlow: !(mode == SemiTimelineMode.center && split),
          ),
        );

        // Content slot insets (EdgeInsetsDirectional mirrors in RTL).
        final double contentStart;
        final double contentEnd;
        if (split && position == SemiTimelinePosition.left) {
          contentStart =
              width * _TimelineMetrics.itemHeadCustomLeftFraction +
              _axisContentGap;
          contentEnd =
              _TimelineMetrics.itemLeftItemContentWidthInset - _axisContentGap;
        } else if (split) {
          contentStart = 0;
          contentEnd =
              width * _TimelineMetrics.itemHeadCustomLeftFraction +
              _TimelineMetrics.itemRightItemContentWidthInset;
        } else if (mode == SemiTimelineMode.right) {
          contentStart = 0;
          contentEnd = _TimelineMetrics.itemRightContentInset;
        } else {
          contentStart = theme.spacingTimelineContentMarginLeft;
          contentEnd = 0;
        }

        final sizer = SizedBox(
          width: bounded ? width : null,
          child: Padding(
            padding: EdgeInsetsDirectional.only(
              top: 0,
              start: contentStart,
              end: contentEnd,
              bottom: theme.spacingTimelineItemPaddingBottom,
            ),
            child: column,
          ),
        );

        final tail = PositionedDirectional(
          // Spans the theme tail top (default 20) to the item bottom, so the
          // tail reaches through the row's 24px padding-bottom like upstream.
          top: theme.spacingTimelineTailTop,
          bottom: 0,
          start: axisStart,
          end: axisEnd,
          width: theme.widthTimelineTailBorder,
          child: ExcludeSemantics(
            // Upstream `aria-hidden` on the tail.
            child: CustomPaint(
              painter: _TimelineTailPainter(
                theme.colorTimelineTailBorder,
                theme.spacingTimelineTailTop,
              ),
            ),
          ),
        );

        final headStartAnchored = !(mode == SemiTimelineMode.right);
        final Widget head;
        if (item.dot != null) {
          head = PositionedDirectional(
            top: theme.spacingTimelineHeadCustomTop,
            start: headStartAnchored
                ? (split
                      ? width * _TimelineMetrics.itemHeadCustomLeftFraction
                      : (mode == SemiTimelineMode.right
                            ? null
                            : theme.spacingTimelineHeadCustomLeft))
                : null,
            end: headStartAnchored
                ? null
                : _TimelineMetrics.itemRightItemLeftInset,
            width: _TimelineMetrics.widthTimelineHeadCustom,
            height: _TimelineMetrics.heightTimelineHeadCustom,
            child: ExcludeSemantics(
              // Upstream `aria-hidden` on the head.
              child: FractionalTranslation(
                translation: rtl == headStartAnchored
                    ? _TimelineMetrics.headCustomTranslationRtl
                    : _TimelineMetrics.headCustomTranslation,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    // Upstream quirk: the inline `color` background wins even
                    // over the transparent custom-dot background.
                    color: item.color ?? theme.colorTimelineItemHeadBg,
                    border: Border.all(
                      color: const Color(0x00000000),
                      width: theme.widthTimelineHeadCustomBorder,
                    ),
                    borderRadius: BorderRadius.circular(
                      theme.radiusTimelineHeadCustom,
                    ),
                  ),
                  child: item.dot,
                ),
              ),
            ),
          );
        } else {
          head = PositionedDirectional(
            top: theme.spacingTimelineHeadTop,
            start: headStartAnchored
                ? (split
                      ? width * _TimelineMetrics.itemHeadCustomLeftFraction +
                            theme.spacingTimelineItemHeadMarginLeft
                      : (mode == SemiTimelineMode.right ? null : 0))
                : null,
            end: headStartAnchored
                ? null
                : -theme.spacingTimelineItemHeadMarginLeft,
            width: theme.widthTimelineDot,
            height: theme.widthTimelineDot,
            child: ExcludeSemantics(
              // Upstream `aria-hidden` on the head.
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: item.color ?? _typeColor(theme, item.type),
                  borderRadius: BorderRadius.circular(theme.radiusTimelineHead),
                ),
              ),
            ),
          );
        }

        Widget row = Padding(
          padding: EdgeInsets.all(theme.spacingTimelineItemMargin),
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              sizer,
              if (!last) tail,
              head,
              if (mode == SemiTimelineMode.center &&
                  split &&
                  _slotVisible(item.time))
                PositionedDirectional(
                  // `calc(-40px - 100%)` intent: the time's end edge sits 40px
                  // plus one content width left of the nominal content edge,
                  // i.e. right-aligned in the axis-start slot at top -2px.
                  top: theme.spacingTimelineTimeTop,
                  start:
                      width * _TimelineMetrics.itemHeadCustomLeftFraction +
                      _TimelineMetrics.itemLeftItemContentLeft +
                      theme.spacingTimelineContentMarginLeft +
                      _TimelineMetrics.itemContentTimeMarginLeft -
                      (width * _TimelineMetrics.itemHeadCustomLeftFraction -
                              _TimelineMetrics.itemLeftItemContentWidthInset) *
                          _TimelineMetrics.itemContentTimeWidthFactor,
                  width:
                      (width * _TimelineMetrics.itemHeadCustomLeftFraction -
                          _TimelineMetrics.itemLeftItemContentWidthInset) *
                      _TimelineMetrics.itemContentTimeWidthFactor,
                  child: _slotNode(
                    theme,
                    item.time,
                    meta: true,
                    textAlign: TextAlign.end,
                  ),
                ),
            ],
          ),
        );

        final onTap = item.onTap;
        if (onTap != null) {
          row = Semantics(
            // One button node per row; children merge in, so nothing is
            // announced twice (upstream li onClick + aria-hidden decoration).
            container: true,
            button: true,
            onTap: onTap,
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              excludeFromSemantics: true,
              onTap: onTap,
              child: row,
            ),
          );
        }
        return row;
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = SemiTimelineTheme.resolve(context);
    final body = Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (var i = 0; i < items.length; i++) _buildItem(context, theme, i),
      ],
    );
    final root = Container(
      margin: EdgeInsets.all(theme.spacingTimelineMargin),
      padding: EdgeInsets.all(theme.spacingTimelinePadding),
      child: body,
    );
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth.isFinite
            ? constraints.maxWidth * _TimelineMetrics.widthTimeline
            : null;
        return Semantics(
          container: semanticsLabel != null,
          label: semanticsLabel,
          child: SizedBox(width: width, child: root),
        );
      },
    );
  }
}

/// Tail line of one row. The box already spans the theme tail top to the item
/// bottom (padding-bottom included); the painter reproduces upstream
/// `$height-timline_tail: calc(100% - 20px)`, so the painted length tracks the
/// constraints under text scaling and a themed tail top overflows the item
/// bottom exactly like the CSS.
class _TimelineTailPainter extends CustomPainter {
  const _TimelineTailPainter(this.color, this.top);

  final Color color;
  final double top;

  @override
  void paint(Canvas canvas, Size size) {
    final length = size.height + top - _TimelineMetrics.timlineTailHeightInset;
    final paint = Paint()
      ..color = color
      ..strokeWidth = size.width;
    final x = size.width / 2;
    canvas.drawLine(Offset(x, 0), Offset(x, length), paint);
  }

  @override
  bool shouldRepaint(_TimelineTailPainter oldDelegate) =>
      oldDelegate.color != color || oldDelegate.top != top;
}
