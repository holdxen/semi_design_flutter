import 'package:flutter/widgets.dart';

import '../theme/semi_highlight_theme.dart';
import 'highlight_algorithm.dart';

/// Highlights occurrences of [searchWords] inside [sourceString].
///
/// Renders as a single [Text.rich]: each algorithm chunk becomes one
/// [TextSpan], highlighted spans carrying the merged style chain
/// `base.merge(themeDefaults).merge(highlightStyle).merge(word.style)` sealed with
/// `copyWith(inherit: false)`, plain spans carrying `base` (ambient
/// [DefaultTextStyle] merged with [style]).
///
/// Unlike the upstream React component there is no `highlightClassName` or
/// `component` override: styling is theme- and style-based only, and the
/// highlighted background is a plain [TextSpan] `backgroundColor` (no rounded
/// corners or padding).
class SemiHighlight extends StatelessWidget {
  const SemiHighlight(
    this.sourceString, {
    super.key,
    this.searchWords = const [],
    this.caseSensitive = false,
    this.autoEscape = true,
    this.style,
    this.highlightStyle,
    this.textAlign,
    this.textDirection,
    this.softWrap,
    this.maxLines,
    this.overflow,
    this.semanticsLabel,
  }) : assert(maxLines == null || maxLines > 0);

  /// The text to search in; every chunk boundary slices this string by UTF-16
  /// code unit offsets.
  final String sourceString;

  /// Words to highlight; empty texts are ignored. Overlapping or nested
  /// matches merge into one span whose style combines the words' styles as
  /// `{...prev.style, ...next.style}` (later words override shared keys).
  final List<SemiHighlightWord<TextStyle>> searchWords;

  /// When true, matching is case sensitive; defaults to case-insensitive.
  final bool caseSensitive;

  /// When true (default), words match literally; when false each word is a
  /// regular expression pattern.
  final bool autoEscape;

  /// Base style for the whole text, merged over the ambient [DefaultTextStyle].
  final TextStyle? style;

  /// Style overlay for highlighted spans only, above the resolved theme
  /// defaults and below each word's own style.
  final TextStyle? highlightStyle;

  final TextAlign? textAlign;
  final TextDirection? textDirection;
  final bool? softWrap;
  final int? maxLines;
  final TextOverflow? overflow;
  final String? semanticsLabel;

  @override
  Widget build(BuildContext context) {
    final theme = SemiHighlightTheme.resolve(context);
    final base = DefaultTextStyle.of(context).style.merge(style);
    final themeDefaults = TextStyle(
      color: theme.colorHighlightTextDefault,
      backgroundColor: theme.colorHighlightTextBgDefault,
      fontWeight: theme.fontHighlightTextFontWeight,
    );
    final chunks = findAll<TextStyle>(
      sourceString: sourceString,
      searchWords: searchWords,
      autoEscape: autoEscape,
      caseSensitive: caseSensitive,
    );
    return Text.rich(
      TextSpan(
        children: [
          for (final chunk in chunks)
            TextSpan(
              text: sourceString.substring(chunk.start, chunk.end),
              style: chunk.highlight
                  ? base
                        .merge(themeDefaults)
                        .merge(highlightStyle)
                        .merge(chunk.style)
                        .copyWith(inherit: false)
                  : base,
            ),
        ],
      ),
      textAlign: textAlign,
      textDirection: textDirection,
      softWrap: softWrap,
      maxLines: maxLines,
      overflow: overflow,
      semanticsLabel: semanticsLabel,
    );
  }
}
