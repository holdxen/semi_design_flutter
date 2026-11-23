// ---------------------------------------------------------------------------
// Port of vscode/src/vs/base/common/search.ts
// Translated 1:1 from TypeScript.
// ---------------------------------------------------------------------------

import 'strings.dart' as strings;

/// 1:1: `buildReplaceStringWithCasePreserved`
String buildReplaceStringWithCasePreserved(
    List<String>? matches, String pattern) {
  if (matches != null && matches[0] != '') {
    final bool containsHyphens =
        _validateSpecificSpecialCharacter(matches, pattern, '-');
    final bool containsUnderscores =
        _validateSpecificSpecialCharacter(matches, pattern, '_');
    if (containsHyphens && !containsUnderscores) {
      return _buildReplaceStringForSpecificSpecialCharacter(
          matches, pattern, '-');
    } else if (!containsHyphens && containsUnderscores) {
      return _buildReplaceStringForSpecificSpecialCharacter(
          matches, pattern, '_');
    }
    if (matches[0].toUpperCase() == matches[0]) {
      return pattern.toUpperCase();
    } else if (matches[0].toLowerCase() == matches[0]) {
      return pattern.toLowerCase();
    } else if (strings.containsUppercaseCharacter(matches[0][0]) &&
        pattern.isNotEmpty) {
      return pattern[0].toUpperCase() + pattern.substring(1);
    } else if (matches[0][0].toUpperCase() != matches[0][0] &&
        pattern.isNotEmpty) {
      return pattern[0].toLowerCase() + pattern.substring(1);
    } else {
      // we don't understand its pattern yet.
      return pattern;
    }
  } else {
    return pattern;
  }
}

/// 1:1: `validateSpecificSpecialCharacter`
bool _validateSpecificSpecialCharacter(
    List<String> matches, String pattern, String specialCharacter) {
  final bool doesContainSpecialCharacter = matches[0].contains(specialCharacter) &&
      pattern.contains(specialCharacter);
  return doesContainSpecialCharacter &&
      matches[0].split(specialCharacter).length ==
          pattern.split(specialCharacter).length;
}

/// 1:1: `buildReplaceStringForSpecificSpecialCharacter`
String _buildReplaceStringForSpecificSpecialCharacter(
    List<String> matches, String pattern, String specialCharacter) {
  final List<String> splitPatternAtSpecialCharacter =
      pattern.split(specialCharacter);
  final List<String> splitMatchAtSpecialCharacter =
      matches[0].split(specialCharacter);
  final StringBuffer replaceString = StringBuffer();
  for (int index = 0; index < splitPatternAtSpecialCharacter.length; index++) {
    replaceString.write(buildReplaceStringWithCasePreserved(
            <String>[splitMatchAtSpecialCharacter[index]],
            splitPatternAtSpecialCharacter[index]) +
        specialCharacter);
  }
  return replaceString.toString().substring(
      0, replaceString.length - 1); // slice(0, -1)
}
