import 'dart:math' as math;

import 'package:flutter/widgets.dart';

import '../theme/semi_descriptions_theme.dart';
import '../theme/semi_descriptions_theme_data.dart';
import '../theme/semi_theme.dart';
import '../tokens/typography_tokens.dart';
import 'typography/semi_text.dart';

/// Upstream `align` (`packages/semi-ui/descriptions/descriptions-context.ts`):
/// label/value slot alignment, or `plain` for the inline `label: value` form.
/// Only meaningful when `row` is false and `layout` is vertical (horizontal
/// uses the same slot alignments inside its fixed cells).
enum SemiDescriptionsAlign {
  /// Label at the slot end, value at the slot start (upstream `th` right).
  center,

  /// Label at the slot start, value at the slot end (upstream `td` right).
  justify,

  /// Label and value both at the slot start.
  left,

  /// Inline `label:` + 8px gap + value on one run (colon is visual only).
  plain,
}

/// Upstream `layout` (`packages/semi-ui/descriptions/index.tsx`): vertical is
/// one item per row (upstream `tr` blocks); horizontal groups items into rows
/// of `column` span columns (upstream `table-layout: fixed`).
enum SemiDescriptionsLayout { vertical, horizontal }

/// Upstream `size` (`packages/semi-ui/descriptions/index.tsx`): the double-row
/// (`row: true`) key/value size tier. Ignored outside double-row mode.
enum SemiDescriptionsSize { small, medium, large }

/// One descriptions row (upstream `Data` row or `Descriptions.Item` child).
@immutable
class SemiDescriptionsItemData {
  const SemiDescriptionsItemData({
    required this.label,
    this.value,
    this.valueBuilder,
    this.hidden = false,
    this.span,
    this.keyStyle,
    this.keyWidth,
  }) : assert(
         label is String || label is Widget,
         'label must be a String or a Widget',
       ),
       assert(
         value == null || value is String || value is Widget,
         'value must be a String, a Widget or null',
       ),
       assert(
         value == null || valueBuilder == null,
         'value and valueBuilder are mutually exclusive',
       ),
       assert(span == null || span >= 1, 'span must be >= 1'),
       assert(keyWidth == null || keyWidth >= 0, 'keyWidth must be >= 0');

  /// Key slot: a [String] (rendered as `SemiText`, single line with ellipsis)
  /// or a [Widget] placed as-is. Upstream `key`/`itemKey`.
  final Object label;

  /// Value slot: a [String] (rendered as `SemiText`), a [Widget] placed as-is,
  /// or null for an empty value. Mutually exclusive with [valueBuilder].
  final Object? value;

  /// Lazy value slot: called only while rendering this item (never for hidden
  /// items or unmounted trees). Mutually exclusive with [value].
  final Widget Function()? valueBuilder;

  /// Upstream `hidden`: filtered out before grouping, rendering and semantics.
  final bool hidden;

  /// Span columns in `horizontal` layout. null means "not given": renders as
  /// one column and the last row's trailing item may be widened to fill the
  /// row (upstream `isNaN(span)` semantics). An explicit value — including 1 —
  /// is never widened. Ignored in vertical and double-row layouts.
  final int? span;

  /// Extra text style for [String] labels (merged over the themed key style).
  /// Upstream `keyStyle`; only text style is ported, see docs for width
  /// (use [keyWidth]) and alignment (use `align`).
  final TextStyle? keyStyle;

  /// Fixed key slot width (upstream `keyStyle.width`). When set, longer keys
  /// ellipsize inside it.
  final double? keyWidth;
}

/// The 9 hardcoded Sass/JSX values that stay out of the theme: they are fixed
/// literals of `packages/semi-foundation/descriptions/descriptions.scss` and
/// `packages/semi-ui/descriptions/item.tsx` rather than overridable variables.
/// See docs/semi_descriptions.md for the full mapping.
abstract final class _DescriptionsMetrics {
  /// `min-height: $font-size-regular` in packages/semi-foundation/descriptions/descriptions.scss.
  /// Key block min height (14px, the font-size-regular token).
  static const double keyMinHeight = 14;

  /// `white-space: nowrap` in packages/semi-foundation/descriptions/descriptions.scss.
  /// Keys stay on one line; the port adds ellipsis truncation when a key is
  /// constrained (keyWidth or the horizontal fixed label cell).
  static const int keyMaxLines = 1;

  /// `font-weight: normal` in packages/semi-foundation/descriptions/descriptions.scss (`.semi-descriptions-key`).
  static const FontWeight keyBaseFontWeight = FontWeight.w400;

  /// `font-weight: normal` in packages/semi-foundation/descriptions/descriptions.scss (`.semi-descriptions-value`).
  /// Double-row values override this with `fontDescriptionsValueFontWeight`.
  static const FontWeight valueBaseFontWeight = FontWeight.w400;

  /// `@include font-size-regular` (14px) in packages/semi-foundation/descriptions/descriptions.scss (`.semi-descriptions-key`).
  /// Base (non-double-row) key font size; the double-row tiers are themed.
  static const double keyBaseFontSize = 14;

  /// `@include font-size-regular` (14px) in packages/semi-foundation/descriptions/descriptions.scss (`.semi-descriptions-value`).
  /// Base (non-double-row) value font size.
  static const double valueBaseFontSize = 14;

  /// `padding-bottom: 0` in packages/semi-foundation/descriptions/descriptions.scss (`-double-small` key).
  /// Small double-row key bottom padding; medium/large are themed (4px).
  static const double keyPaddingBottomSmall = 0;

  /// `{itemKey}:` in packages/semi-ui/descriptions/item.tsx.
  /// The plain-mode colon is visual only and is excluded from semantics.
  static const String plainColon = ':';

  /// `colSpan={span ? ((span * 2) - 1) : 1}` in packages/semi-ui/descriptions/item.tsx.
  /// Horizontal split: one span column = 1 label unit + 1 value unit, so a
  /// span-N item is N label units wide and its value takes 2N-1 units.
  static const int valueColSpanFactor = 2;
}

/// Copies [item] with an explicit [span] for the last-row fill of
/// [semiDescriptionsHorizontalList]; the input instance is never mutated
/// (upstream spreads `{ ...lastSpan, span }`).
SemiDescriptionsItemData _withSpan(SemiDescriptionsItemData item, int span) =>
    SemiDescriptionsItemData(
      label: item.label,
      value: item.value,
      valueBuilder: item.valueBuilder,
      hidden: item.hidden,
      span: span,
      keyStyle: item.keyStyle,
      keyWidth: item.keyWidth,
    );

/// Replicates upstream `DescriptionsFoundation.getHorizontalList`
/// (`packages/semi-foundation/descriptions/foundation.ts`): drops hidden
/// items, then packs visible items into rows whose spans sum to `column`
/// (flushing as soon as the running total reaches `column`, so an oversized
/// span closes its row and shares it with what preceded it). The leftover
/// row's trailing item is widened to `column - other spans` only when its
/// `span` was never given; inputs are not mutated — widened items are copies.
List<List<SemiDescriptionsItemData>> semiDescriptionsHorizontalList(
  List<SemiDescriptionsItemData> items,
  int column,
) {
  assert(column >= 1, 'column must be >= 1');
  final rows = <List<SemiDescriptionsItemData>>[];
  var current = <SemiDescriptionsItemData>[];
  var totalSpan = 0;
  for (final item in items) {
    if (item.hidden) continue;
    totalSpan += item.span ?? 1;
    current.add(item);
    if (totalSpan >= column) {
      rows.add(current);
      current = <SemiDescriptionsItemData>[];
      totalSpan = 0;
    }
  }
  if (current.isNotEmpty) {
    final last = current[current.length - 1];
    if (last.span == null) {
      var total = 0;
      for (final item in current) {
        total += item.span ?? 1;
      }
      if (total < column) {
        // column - total + 1 with the trailing item counted as 1.
        current[current.length - 1] = _withSpan(last, column - total + 1);
      }
    }
    rows.add(current);
  }
  return rows;
}

/// Vertical/horizontal/double-row key-value list.
///
/// Mirrors upstream `packages/semi-ui/descriptions/{index,item}.tsx` and
/// `packages/semi-foundation/descriptions/{descriptions,rtl}.scss` without
/// Material. Upstream `data`/`children` both map to [items]; `className`/
/// `style` are not ported. `row: true` (upstream `double`) takes precedence
/// over [layout] and [align]; [size] only applies there.
class SemiDescriptions extends StatelessWidget {
  const SemiDescriptions({
    super.key,
    this.items = const [],
    this.layout = SemiDescriptionsLayout.vertical,
    this.align = SemiDescriptionsAlign.center,
    this.row = false,
    this.size = SemiDescriptionsSize.medium,
    this.column = 3,
    this.semanticsLabel,
  }) : assert(column >= 1, 'column must be >= 1');

  /// Rows to render; hidden items are filtered out entirely.
  final List<SemiDescriptionsItemData> items;

  /// Vertical (one item per row) or horizontal (span-column grid). Ignored
  /// when [row] is true (upstream leaves that combination undefined).
  final SemiDescriptionsLayout layout;

  /// Label/value slot alignment; ignored when [row] is true.
  final SemiDescriptionsAlign align;

  /// Double-row mode (upstream `row`): key above value per item, items laid
  /// out in a wrapping flow.
  final bool row;

  /// Double-row size tier; ignored when [row] is false.
  final SemiDescriptionsSize size;

  /// Span columns per horizontal row (upstream `column`).
  final int column;

  /// Region label for the whole list (upstream `aria-label`).
  final String? semanticsLabel;

  @override
  Widget build(BuildContext context) {
    final global = SemiTheme.of(context);
    final theme = SemiDescriptionsTheme.of(context).resolve(global);
    final typography = global.typography;
    final visible = [
      for (final item in items)
        if (!item.hidden) item,
    ];
    final Widget body;
    if (row) {
      body = _buildDouble(theme, typography, visible);
    } else if (layout == SemiDescriptionsLayout.horizontal) {
      body = _buildHorizontal(context, theme, typography);
    } else {
      body = _buildVertical(context, theme, typography, visible);
    }
    return Semantics(
      container: semanticsLabel != null,
      label: semanticsLabel,
      child: body,
    );
  }

  TextAlign get _labelAlign => switch (align) {
    SemiDescriptionsAlign.center => TextAlign.end,
    SemiDescriptionsAlign.justify => TextAlign.start,
    SemiDescriptionsAlign.left => TextAlign.start,
    SemiDescriptionsAlign.plain => TextAlign.start,
  };
  TextAlign get _valueAlign => switch (align) {
    SemiDescriptionsAlign.center => TextAlign.start,
    SemiDescriptionsAlign.justify => TextAlign.end,
    SemiDescriptionsAlign.left => TextAlign.start,
    SemiDescriptionsAlign.plain => TextAlign.start,
  };
  AlignmentDirectional get _labelAlignment => switch (align) {
    SemiDescriptionsAlign.center => AlignmentDirectional.centerEnd,
    SemiDescriptionsAlign.justify => AlignmentDirectional.centerStart,
    SemiDescriptionsAlign.left => AlignmentDirectional.centerStart,
    SemiDescriptionsAlign.plain => AlignmentDirectional.centerStart,
  };
  AlignmentDirectional get _valueAlignment => switch (align) {
    SemiDescriptionsAlign.center => AlignmentDirectional.centerStart,
    SemiDescriptionsAlign.justify => AlignmentDirectional.centerEnd,
    SemiDescriptionsAlign.left => AlignmentDirectional.centerStart,
    SemiDescriptionsAlign.plain => AlignmentDirectional.centerStart,
  };

  TextStyle _keyStyle(
    SemiResolvedDescriptionsThemeData theme,
    SemiTypographyTokens typography, {
    required double fontSize,
    required double lineHeight,
  }) => TextStyle(
    fontFamily: typography.fontFamily,
    color: theme.colorDescriptionsKeyTextDefault,
    fontSize: fontSize,
    fontWeight: _DescriptionsMetrics.keyBaseFontWeight,
    height: lineHeight / fontSize,
  );

  TextStyle _valueStyle(
    SemiResolvedDescriptionsThemeData theme,
    SemiTypographyTokens typography, {
    required double fontSize,
    required double lineHeight,
    required FontWeight fontWeight,
  }) => TextStyle(
    fontFamily: typography.fontFamily,
    color: theme.colorDescriptionsValueTextDefault,
    fontSize: fontSize,
    fontWeight: fontWeight,
    height: lineHeight / fontSize,
  );

  /// `font-size-small` mixin line height for the small double-row key; the
  /// regular tiers keep `fontDescriptionsLineHeight` (20px, both the root
  /// `line-height` and the `font-size-regular` mixin value upstream).
  double _keyLineHeight(
    SemiResolvedDescriptionsThemeData theme,
    SemiTypographyTokens typography,
  ) =>
      !row ||
          size == SemiDescriptionsSize.medium ||
          size == SemiDescriptionsSize.large
      ? theme.fontDescriptionsLineHeight
      : typography.lineHeightSmall;

  /// Double-row value line heights are the font-size mixin heights
  /// (header-6/-4/-2); the base tier keeps `fontDescriptionsLineHeight`.
  double _valueLineHeight(
    SemiResolvedDescriptionsThemeData theme,
    SemiTypographyTokens typography,
  ) {
    if (!row) return theme.fontDescriptionsLineHeight;
    return switch (size) {
      SemiDescriptionsSize.small => typography.lineHeightHeading6,
      SemiDescriptionsSize.medium => typography.lineHeightHeading4,
      SemiDescriptionsSize.large => typography.lineHeightHeading2,
    };
  }

  double _keyFontSize(SemiResolvedDescriptionsThemeData theme) {
    if (!row) return _DescriptionsMetrics.keyBaseFontSize;
    return switch (size) {
      SemiDescriptionsSize.small => theme.fontDescriptionsKeySmallFontSize,
      SemiDescriptionsSize.medium => theme.fontDescriptionsKeyMediumFontSize,
      SemiDescriptionsSize.large => theme.fontDescriptionsKeyLargeFontSize,
    };
  }

  double _valueFontSize(SemiResolvedDescriptionsThemeData theme) {
    if (!row) return _DescriptionsMetrics.valueBaseFontSize;
    return switch (size) {
      SemiDescriptionsSize.small => theme.fontDescriptionsValueSmallFontSize,
      SemiDescriptionsSize.medium => theme.fontDescriptionsValueMediumFontSize,
      SemiDescriptionsSize.large => theme.fontDescriptionsValueLargeFontSize,
    };
  }

  Widget _keyNode(
    SemiDescriptionsItemData item, {
    required TextStyle style,
    required TextAlign textAlign,
    required bool plainColon,
  }) {
    final label = item.label;
    Widget node;
    if (label is String) {
      node = plainColon
          ? SemiText(
              '$label${_DescriptionsMetrics.plainColon}',
              style: item.keyStyle == null ? style : style.merge(item.keyStyle),
              textAlign: textAlign,
              maxLines: _DescriptionsMetrics.keyMaxLines,
              overflow: TextOverflow.ellipsis,
              semanticsLabel: label,
            )
          : SemiText(
              label,
              style: item.keyStyle == null ? style : style.merge(item.keyStyle),
              textAlign: textAlign,
              maxLines: _DescriptionsMetrics.keyMaxLines,
              overflow: TextOverflow.ellipsis,
            );
    } else if (label is Widget) {
      node = plainColon
          ? Row(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                label,
                ExcludeSemantics(
                  child: SemiText(
                    _DescriptionsMetrics.plainColon,
                    style: item.keyStyle == null
                        ? style
                        : style.merge(item.keyStyle),
                  ),
                ),
              ],
            )
          : label;
    } else {
      node = const SizedBox.shrink();
    }
    node = ConstrainedBox(
      constraints: const BoxConstraints(
        minHeight: _DescriptionsMetrics.keyMinHeight,
      ),
      child: node,
    );
    final keyWidth = item.keyWidth;
    if (keyWidth != null) {
      node = SizedBox(width: keyWidth, child: node);
    }
    return node;
  }

  Widget _valueNode(
    SemiDescriptionsItemData item, {
    required TextStyle style,
    required TextAlign textAlign,
  }) {
    final builder = item.valueBuilder;
    if (builder != null) {
      return builder();
    }
    final value = item.value;
    if (value is String) {
      return SemiText(value, style: style, textAlign: textAlign);
    }
    if (value is Widget) {
      return value;
    }
    return const SizedBox.shrink();
  }

  /// Natural width of a String label under [style]; widget labels (and thus
  /// their contribution to the shared label column) need `keyWidth`.
  double? _measuredKeyWidth(
    BuildContext context,
    SemiDescriptionsItemData item,
    TextStyle style,
  ) {
    if (item.keyWidth != null) return item.keyWidth;
    final label = item.label;
    if (label is! String) return null;
    final painter = TextPainter(
      text: TextSpan(
        text: label,
        style: item.keyStyle == null ? style : style.merge(item.keyStyle),
      ),
      textDirection: Directionality.of(context),
      textScaler:
          MediaQuery.maybeOf(context)?.textScaler ?? TextScaler.noScaling,
    )..layout();
    final width = painter.width;
    painter.dispose();
    return width;
  }

  Widget _plainRow({
    required Widget key,
    required Widget value,
    required double gap,
  }) => Wrap(
    crossAxisAlignment: WrapCrossAlignment.start,
    spacing: gap,
    children: [key, value],
  );

  Widget _buildVertical(
    BuildContext context,
    SemiResolvedDescriptionsThemeData theme,
    SemiTypographyTokens typography,
    List<SemiDescriptionsItemData> visible,
  ) {
    final keyStyle = _keyStyle(
      theme,
      typography,
      fontSize: _keyFontSize(theme),
      lineHeight: _keyLineHeight(theme, typography),
    );
    final valueStyle = _valueStyle(
      theme,
      typography,
      fontSize: _valueFontSize(theme),
      lineHeight: _valueLineHeight(theme, typography),
      fontWeight: _DescriptionsMetrics.valueBaseFontWeight,
    );
    return LayoutBuilder(
      builder: (context, constraints) {
        final bounded = constraints.hasBoundedWidth;
        final maxWidth = constraints.maxWidth;
        // Shared label column: the widest key (upstream auto table layout).
        var shared = 0.0;
        final measured = <double?>[
          for (final item in visible)
            _measuredKeyWidth(context, item, keyStyle),
        ];
        for (final width in measured) {
          if (width != null) shared = math.max(shared, width);
        }
        if (bounded) {
          // Flutter improvement: a key wider than the row would overflow the
          // container upstream; the port caps the column and ellipsizes.
          shared = math.min(
            shared,
            math.max(0, maxWidth - theme.spacingDescriptionsThPaddingRight),
          );
        }
        return Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (var i = 0; i < visible.length; i++)
              MergeSemantics(
                child: Padding(
                  padding: EdgeInsetsDirectional.only(
                    bottom: theme.spacingDescriptionsItemPaddingBottom,
                  ),
                  child: align == SemiDescriptionsAlign.plain
                      ? _plainRow(
                          key: _keyNode(
                            visible[i],
                            style: keyStyle,
                            textAlign: _labelAlign,
                            plainColon: true,
                          ),
                          value: _valueNode(
                            visible[i],
                            style: valueStyle,
                            textAlign: _valueAlign,
                          ),
                          gap: theme.spacingDescriptionsValuePlainPaddingLeft,
                        )
                      : _verticalPair(
                          context,
                          theme,
                          visible[i],
                          keyStyle,
                          valueStyle,
                          measured[i],
                          shared,
                          bounded,
                        ),
                ),
              ),
          ],
        );
      },
    );
  }

  Widget _verticalPair(
    BuildContext context,
    SemiResolvedDescriptionsThemeData theme,
    SemiDescriptionsItemData item,
    TextStyle keyStyle,
    TextStyle valueStyle,
    double? measured,
    double shared,
    bool bounded,
  ) {
    final key = _keyNode(
      item,
      style: keyStyle,
      textAlign: _labelAlign,
      plainColon: false,
    );
    final value = _valueNode(item, style: valueStyle, textAlign: _valueAlign);
    // Label slot: shared intrinsic column width when measurable, otherwise
    // the widget key's natural width (see docs). The th end padding sits
    // outside the shared column (upstream auto table: column width = content
    // + padding), so the widest key fits exactly.
    final Widget keySlot;
    if (measured != null) {
      keySlot = Padding(
        padding: EdgeInsetsDirectional.only(
          end: theme.spacingDescriptionsThPaddingRight,
        ),
        child: SizedBox(
          width: shared,
          child: Align(alignment: _labelAlignment, child: key),
        ),
      );
    } else {
      keySlot = Padding(
        padding: EdgeInsetsDirectional.only(
          end: theme.spacingDescriptionsThPaddingRight,
        ),
        child: Align(alignment: _labelAlignment, child: key),
      );
    }
    if (!bounded) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [keySlot, value],
      );
    }
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        keySlot,
        Expanded(
          child: Align(alignment: _valueAlignment, child: value),
        ),
      ],
    );
  }

  Widget _buildHorizontal(
    BuildContext context,
    SemiResolvedDescriptionsThemeData theme,
    SemiTypographyTokens typography,
  ) {
    final rows = semiDescriptionsHorizontalList(items, column);
    final keyStyle = _keyStyle(
      theme,
      typography,
      fontSize: _keyFontSize(theme),
      lineHeight: _keyLineHeight(theme, typography),
    );
    final valueStyle = _valueStyle(
      theme,
      typography,
      fontSize: _valueFontSize(theme),
      lineHeight: _valueLineHeight(theme, typography),
      fontWeight: _DescriptionsMetrics.valueBaseFontWeight,
    );
    Widget cell(SemiDescriptionsItemData item, {double? unit}) {
      final span = item.span ?? 1;
      final key = _keyNode(
        item,
        style: keyStyle,
        textAlign: _labelAlign,
        plainColon: align == SemiDescriptionsAlign.plain,
      );
      final value = _valueNode(item, style: valueStyle, textAlign: _valueAlign);
      final Widget content;
      if (align == SemiDescriptionsAlign.plain) {
        content = _plainRow(
          key: key,
          value: value,
          gap: theme.spacingDescriptionsValuePlainPaddingLeft,
        );
      } else if (unit == null) {
        content = Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsetsDirectional.only(
                end: theme.spacingDescriptionsThPaddingRight,
              ),
              child: key,
            ),
            value,
          ],
        );
      } else {
        content = Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: unit,
              child: Padding(
                padding: EdgeInsetsDirectional.only(
                  end: theme.spacingDescriptionsThPaddingRight,
                ),
                child: Align(alignment: _labelAlignment, child: key),
              ),
            ),
            SizedBox(
              // Upstream colSpan: label 1 unit, value 2*span-1 units.
              width:
                  (span * _DescriptionsMetrics.valueColSpanFactor - 1) * unit,
              child: Align(alignment: _valueAlignment, child: value),
            ),
          ],
        );
      }
      return MergeSemantics(
        child: Padding(
          padding: EdgeInsetsDirectional.only(
            bottom: theme.spacingDescriptionsItemPaddingBottom,
          ),
          child: content,
        ),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        if (!width.isFinite) {
          // Unbounded: no percentage widths to guess; items flow at their
          // natural width (see docs).
          return Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (final row in rows)
                Wrap(
                  crossAxisAlignment: WrapCrossAlignment.start,
                  children: [for (final item in row) cell(item)],
                ),
            ],
          );
        }
        // Upstream fixed table: 2 sub-columns per span column; a row wider
        // than `column` widens the table for every row (see docs).
        var spanColumns = column;
        for (final row in rows) {
          var total = 0;
          for (final item in row) {
            total += item.span ?? 1;
          }
          spanColumns = math.max(spanColumns, total);
        }
        final unit =
            width / (spanColumns * _DescriptionsMetrics.valueColSpanFactor);
        return Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (final row in rows)
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  for (final item in row)
                    SizedBox(
                      width: (item.span ?? 1) / spanColumns * width,
                      child: cell(item, unit: unit),
                    ),
                ],
              ),
          ],
        );
      },
    );
  }

  Widget _buildDouble(
    SemiResolvedDescriptionsThemeData theme,
    SemiTypographyTokens typography,
    List<SemiDescriptionsItemData> visible,
  ) {
    final keyStyle = _keyStyle(
      theme,
      typography,
      fontSize: _keyFontSize(theme),
      lineHeight: _keyLineHeight(theme, typography),
    );
    final valueStyle = _valueStyle(
      theme,
      typography,
      fontSize: _valueFontSize(theme),
      lineHeight: _valueLineHeight(theme, typography),
      fontWeight: theme.fontDescriptionsValueFontWeight,
    );
    final itemEnd = switch (size) {
      SemiDescriptionsSize.small =>
        theme.spacingDescriptionsItemSmallPaddingRight,
      SemiDescriptionsSize.medium =>
        theme.spacingDescriptionsItemMediumPaddingRight,
      SemiDescriptionsSize.large =>
        theme.spacingDescriptionsItemLargePaddingRight,
    };
    final keyBottom = switch (size) {
      SemiDescriptionsSize.small => _DescriptionsMetrics.keyPaddingBottomSmall,
      SemiDescriptionsSize.medium =>
        theme.spacingDescriptionsKeyMediumPaddingBottom,
      SemiDescriptionsSize.large =>
        theme.spacingDescriptionsKeyLargePaddingBottom,
    };
    return Wrap(
      crossAxisAlignment: WrapCrossAlignment.start,
      children: [
        for (final item in visible)
          MergeSemantics(
            child: Padding(
              padding: EdgeInsetsDirectional.only(
                end: itemEnd,
                bottom: theme.spacingDescriptionsItemDoublePadding,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: EdgeInsetsDirectional.only(bottom: keyBottom),
                    child: _keyNode(
                      item,
                      style: keyStyle,
                      textAlign: TextAlign.start,
                      plainColon: false,
                    ),
                  ),
                  _valueNode(
                    item,
                    style: valueStyle,
                    textAlign: TextAlign.start,
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}
