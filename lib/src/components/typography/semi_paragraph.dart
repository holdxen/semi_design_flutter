import 'package:flutter/widgets.dart';

import '../../theme/semi_typography_theme.dart';
import 'paragraph_defaults.dart';
import 'semi_text.dart';

enum SemiParagraphSpacing { normal, extended }

/// String-only block paragraph, sharing text decorations and link interactions.
/// Bounded width fills the parent; unbounded width shrinks to the text.
class SemiParagraph extends StatelessWidget {
  const SemiParagraph(
    this.data, {
    super.key,
    this.type = SemiTextType.primary,
    this.size = SemiTextSize.normal,
    this.spacing = SemiParagraphSpacing.normal,
    this.disabled = false,
    this.strong = false,
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
  }) : assert(maxLines == null || maxLines > 0);

  final String data;
  final SemiTextType type;
  final SemiTextSize size;
  final SemiParagraphSpacing spacing;
  final bool disabled, strong, mark, underline, delete;
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
    final t = SemiTypographyTheme.resolve(context);
    return MergeSemantics(
      child: Padding(
        padding: t.titleParagraphMargin,
        child: LayoutBuilder(
          builder: (context, constraints) => SizedBox(
            width: constraints.hasBoundedWidth ? constraints.maxWidth : null,
            child: SemiParagraphDefaults(
              regularWeight: size == SemiTextSize.small
                  ? t.smallParagraphRegularFontWeight
                  : t.normalParagraphRegularFontWeight,
              extendedLineHeight: spacing == SemiParagraphSpacing.extended
                  ? t.paragraphExtendedLineHeight
                  : null,
              child: SemiText(
                data,
                type: type,
                size: size,
                disabled: disabled,
                strong: strong,
                mark: mark,
                underline: underline,
                delete: delete,
                style: style,
                link: link,
                textAlign: textAlign,
                textDirection: textDirection,
                softWrap: softWrap,
                maxLines: maxLines,
                overflow: overflow,
                semanticsLabel: semanticsLabel,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
