import 'package:flutter/widgets.dart';

import 'semi_text.dart';

/// String-only Semi Typography.Title, composed with [SemiText].
///
/// Source: packages/semi-ui/typography/title.tsx and
/// packages/semi-foundation/typography/{typography,variables}.scss.
/// Explicit [weight] wins over [strong]; [style] is merged last.
class SemiTitle extends StatelessWidget {
  const SemiTitle(
    this.data, {
    super.key,
    this.heading = 1,
    this.type = SemiTextType.primary,
    this.weight,
    this.strong = false,
    this.disabled = false,
    this.mark = false,
    this.underline = false,
    this.delete = false,
    this.style,
    this.link,
    this.textAlign,
    this.textDirection,
    this.softWrap,
    this.maxLines,
    this.overflow,
    this.semanticsLabel,
  }) : assert(heading >= 1 && heading <= 6),
       assert(maxLines == null || maxLines > 0);

  final String data;
  final int heading;
  final SemiTextType type;
  final FontWeight? weight;
  final bool strong, disabled, mark, underline, delete;
  final TextStyle? style;
  final SemiTextLink? link;
  final TextAlign? textAlign;
  final TextDirection? textDirection;
  final bool? softWrap;
  final int? maxLines;
  final TextOverflow? overflow;
  final String? semanticsLabel;

  // typography.scss uses font-size-header-1..6 from
  // packages/semi-theme-default/scss/{_font,variables}.scss; local Sass metrics.
  static const _sizes = [32.0, 28.0, 24.0, 20.0, 18.0, 16.0];
  static const _lineHeights = [44.0, 40.0, 32.0, 28.0, 24.0, 22.0];

  @override
  Widget build(BuildContext context) {
    final size = _sizes[heading - 1];
    return Semantics(
      header: true,
      child: SemiText(
        data,
        type: type,
        weight: weight ?? FontWeight.w600,
        strong: strong,
        disabled: disabled,
        mark: mark,
        underline: underline,
        delete: delete,
        style: TextStyle(
          fontSize: size,
          height: _lineHeights[heading - 1] / size,
        ).merge(style),
        link: link,
        textAlign: textAlign,
        textDirection: textDirection,
        softWrap: softWrap,
        maxLines: maxLines,
        overflow: overflow,
        semanticsLabel: semanticsLabel,
      ),
    );
  }
}
