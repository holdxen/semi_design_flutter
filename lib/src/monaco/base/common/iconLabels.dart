// 1:1 port of vs/base/common/iconLabels.ts
//
// Icon-related string utilities. All regex sources are built from the exact
// `ThemeIcon` expression constants so the port stays byte-for-byte aligned with
// the TypeScript `new RegExp(...source...)` construction.
import 'filters.dart' as filters;
import 'strings.dart' as strings;
import 'themables.dart' as themables;

/// 1:1: `const iconStartMarker = '$('`
const String iconStartMarker = r'$(';

/// 1:1: `iconsRegex` — no capturing groups.
final RegExp iconsRegex = RegExp(r'\$\(' +
    themables.ThemeIcon.iconNameExpression +
    r'(?:' +
    themables.ThemeIcon.iconModifierExpression +
    r')?\)');

/// 1:1: `escapeIconsRegex`
final RegExp escapeIconsRegex =
    RegExp(r'(\\)?' + iconsRegex.pattern);

/// 1:1: `escapeIcons`
String escapeIcons(String text) => text.replaceAllMapped(
      escapeIconsRegex,
      (Match match) =>
          match.group(1) != null ? match.group(0)! : '\\${match.group(0)}',
    );

/// 1:1: `markdownEscapedIconsRegex`
final RegExp markdownEscapedIconsRegex = RegExp(r'\\' + iconsRegex.pattern);

/// 1:1: `markdownEscapeEscapedIcons`
String markdownEscapeEscapedIcons(String text) => text.replaceAllMapped(
      markdownEscapedIconsRegex,
      (Match match) => '\\${match.group(0)}',
    );

/// 1:1: `stripIconsRegex`
final RegExp stripIconsRegex =
    RegExp(r'(\s)?(\\)?' + iconsRegex.pattern + r'(\s)?');

/// 1:1: `stripIcons`
String stripIcons(String text) {
  if (!text.contains(iconStartMarker)) {
    return text;
  }

  return text.replaceAllMapped(
    stripIconsRegex,
    (Match match) => match.group(2) != null
        ? match.group(0)!
        : match.group(1) ?? match.group(3) ?? '',
  );
}

/// 1:1: `getCodiconAriaLabel`
String getCodiconAriaLabel(String? text) {
  if (text == null || text.isEmpty) {
    return '';
  }

  return text
      .replaceAllMapped(
        RegExp(r'\$\((.*?)\)'),
        (Match match) => ' ${match.group(1)} ',
      )
      .trim();
}

/// 1:1: `IParsedLabelWithIcons`
class IParsedLabelWithIcons {
  IParsedLabelWithIcons({required this.text, this.iconOffsets});

  final String text;
  final List<int>? iconOffsets;
}

/// 1:1: `_parseIconsRegex`
final RegExp _parseIconsRegex = RegExp(
    r'\$\(' + themables.ThemeIcon.iconNameCharacter + r'+\)');

/// 1:1: `parseLabelWithIcons`
///
/// JS uses a global regex with `lastIndex`; Dart's `RegExp` exposes each match
/// with absolute `start`/`end`, so we iterate `allMatches` and keep a running
/// `pos` (the previous `lastIndex`) to reproduce the exact substring chunks.
IParsedLabelWithIcons parseLabelWithIcons(String input) {
  String text = '';
  final List<int> iconOffsets = <int>[];
  int iconsOffset = 0;
  int pos = 0;

  final Iterable<RegExpMatch> matches = _parseIconsRegex.allMatches(input);
  for (final RegExpMatch match in matches) {
    final String chars = input.substring(pos, match.start);
    if (chars.isNotEmpty) {
      text += chars;
      for (int i = 0; i < chars.length; i++) {
        iconOffsets.add(iconsOffset);
      }
    }
    iconsOffset += match.group(0)!.length;
    pos = match.end;
  }

  // JS: final exec() returns null; chars = input.substring(pos, undefined)
  final String tail = input.substring(pos);
  if (tail.isNotEmpty) {
    text += tail;
    for (int i = 0; i < tail.length; i++) {
      iconOffsets.add(iconsOffset);
    }
  }

  return IParsedLabelWithIcons(text: text, iconOffsets: iconOffsets);
}

/// 1:1: `matchesFuzzyIconAware`
List<filters.IMatch>? matchesFuzzyIconAware(
  String query,
  IParsedLabelWithIcons target, [
  bool enableSeparateSubstringMatching = false,
]) {
  final String text = target.text;
  final List<int>? iconOffsets = target.iconOffsets;

  // Return early if there are no icon markers in the word to match against
  if (iconOffsets == null || iconOffsets.isEmpty) {
    return filters.matchesFuzzy(query, text, enableSeparateSubstringMatching);
  }

  // Trim the word to match against because it could have leading whitespace
  // now if the word started with an icon
  final String wordToMatchAgainstWithoutIconsTrimmed = strings.ltrim(text, ' ');
  final int leadingWhitespaceOffset =
      text.length - wordToMatchAgainstWithoutIconsTrimmed.length;

  // match on value without icon
  final List<filters.IMatch>? matches = filters.matchesFuzzy(
      query, wordToMatchAgainstWithoutIconsTrimmed,
      enableSeparateSubstringMatching);

  if (identical(matches, filters.emptyMatches)) {
    return matches;
  }

  // Map matches back to offsets with icon and trimming
  if (matches != null) {
    for (final filters.IMatch match in matches) {
      final int iconOffset = iconOffsets[match.start + leadingWhitespaceOffset] +
          leadingWhitespaceOffset;
      match.start += iconOffset;
      match.end += iconOffset;
    }
  }

  return matches;
}
