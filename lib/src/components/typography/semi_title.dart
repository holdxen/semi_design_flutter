import 'package:flutter/widgets.dart';

import 'semi_text.dart';
import '../../theme/semi_theme.dart';

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

  @override
  Widget build(BuildContext context) {
    final t = SemiTheme.of(context).typography;
    final size = [
      t.fontSizeHeading1,
      t.fontSizeHeading2,
      t.fontSizeHeading3,
      t.fontSizeHeading4,
      t.fontSizeHeading5,
      t.fontSizeHeading6,
    ][heading - 1];
    final lineHeight = [
      t.lineHeightHeading1,
      t.lineHeightHeading2,
      t.lineHeightHeading3,
      t.lineHeightHeading4,
      t.lineHeightHeading5,
      t.lineHeightHeading6,
    ][heading - 1];
    return Semantics(
      header: true,
      child: SemiText(
        data,
        type: type,
        weight: weight ?? t.fontWeightBold,
        strong: strong,
        disabled: disabled,
        mark: mark,
        underline: underline,
        delete: delete,
        style: TextStyle(
          fontSize: size,
          height: lineHeight / size,
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
