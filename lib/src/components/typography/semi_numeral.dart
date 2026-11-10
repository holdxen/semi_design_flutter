import 'package:flutter/widgets.dart';

import 'format_numeral.dart';
import 'semi_text.dart';

/// String-only numeral typography composed with [SemiText].
class SemiNumeral extends StatelessWidget {
  const SemiNumeral(
    this.data, {
    super.key,
    this.rule = SemiNumeralRule.text,
    this.precision = 0,
    this.truncate = SemiNumeralTruncate.round,
    this.parser,
    this.type = SemiTextType.primary,
    this.size = SemiTextSize.normal,
    this.weight,
    this.strong = false,
    this.disabled = false,
    this.mark = false,
    this.code = false,
    this.underline = false,
    this.delete = false,
    this.style,
    this.icon,
    this.link,
    this.textAlign,
    this.textDirection,
    this.softWrap,
    this.maxLines,
    this.overflow,
    this.semanticsLabel,
  }) : assert(maxLines == null || maxLines > 0);

  final String data;
  final SemiTextType type;
  final SemiTextSize size;
  final FontWeight? weight;
  final bool strong, disabled, mark, code, underline, delete;
  final TextStyle? style;
  final Widget? icon;
  final SemiTextLink? link;
  final TextAlign? textAlign;
  final TextDirection? textDirection;
  final bool? softWrap;
  final int? maxLines;
  final TextOverflow? overflow;
  final String? semanticsLabel;

  final SemiNumeralRule rule;
  final int precision;
  final SemiNumeralTruncate truncate;
  final String Function(String)? parser;

  @override
  Widget build(BuildContext context) => SemiText(
    formatNumeral(
      data,
      rule: rule,
      precision: precision,
      truncate: truncate,
      parser: parser,
    ),
    type: type,
    size: size,
    weight: weight,
    strong: strong,
    disabled: disabled,
    mark: mark,
    code: code,
    underline: underline,
    delete: delete,
    style: style,
    icon: icon,
    link: link,
    textAlign: textAlign,
    textDirection: textDirection,
    softWrap: softWrap,
    maxLines: maxLines,
    overflow: overflow,
    semanticsLabel: semanticsLabel,
  );
}
