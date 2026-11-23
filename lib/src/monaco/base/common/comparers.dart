// ---------------------------------------------------------------------------
// Port of vscode/src/vs/base/common/comparers.ts @bfbf12b35b9978b92b2d341e81ade49f2b18c68c
// Translated 1:1 from TypeScript. TS tuple `[string, string]` -> Dart record
// `(String, String)`; `string | null` -> `String?`; `Intl.Collator` from the
// date.dart carrier (compare/resolvedOptions preserved). Control flow identical.
// ---------------------------------------------------------------------------

import './date.dart';
import './lazy.dart';
import './path.dart' as pth;

// When comparing large numbers of strings it's better for performance to create an
// Intl.Collator object and use the function provided by its compare property
// than it is to use String.prototype.localeCompare()

// A collator with numeric sorting enabled, and no sensitivity to case, accents or diacritics.
final Lazy<(IntlCollator, bool)> intlFileNameCollatorBaseNumeric = Lazy<(IntlCollator, bool)>(() {
  final IntlCollator collator = safeIntl.Collator(null, <String, Object>{'numeric': true, 'sensitivity': 'base'}).value;
  return (collator, collator.resolvedOptions().numeric);
});

// A collator with numeric sorting enabled.
final Lazy<IntlCollator> intlFileNameCollatorNumeric = Lazy<IntlCollator>(() {
  final IntlCollator collator = safeIntl.Collator(null, <String, Object>{'numeric': true}).value;
  return collator;
});

// A collator with numeric sorting enabled, and sensitivity to accents and diacritics but not case.
final Lazy<IntlCollator> intlFileNameCollatorNumericCaseInsensitive = Lazy<IntlCollator>(() {
  final IntlCollator collator = safeIntl.Collator(null, <String, Object>{'numeric': true, 'sensitivity': 'accent'}).value;
  return collator;
});

/// Compares filenames without distinguishing the name from the extension. Disambiguates by unicode comparison.
int compareFileNames(String? one, String? other, [bool caseSensitive = false]) {
  final String a = one ?? '';
  final String b = other ?? '';
  final int result = intlFileNameCollatorBaseNumeric.value.$1.compare(a, b);

  // Using the numeric option will make compare(`foo1`, `foo01`) === 0. Disambiguate.
  if (intlFileNameCollatorBaseNumeric.value.$2 && result == 0 && a != b) {
    return a.compareTo(b) < 0 ? -1 : 1;
  }

  return result;
}

/// Compares full filenames without grouping by case.
int compareFileNamesDefault(String? one, String? other) {
  final IntlCollator collatorNumeric = intlFileNameCollatorNumeric.value;
  final String a = one ?? '';
  final String b = other ?? '';

  return _compareAndDisambiguateByLength(collatorNumeric, a, b);
}

/// Compares full filenames grouping uppercase names before lowercase.
int compareFileNamesUpper(String? one, String? other) {
  final IntlCollator collatorNumeric = intlFileNameCollatorNumeric.value;
  final String a = one ?? '';
  final String b = other ?? '';

  return _or(_compareCaseUpperFirst(a, b), _compareAndDisambiguateByLength(collatorNumeric, a, b));
}

/// Compares full filenames grouping lowercase names before uppercase.
int compareFileNamesLower(String? one, String? other) {
  final IntlCollator collatorNumeric = intlFileNameCollatorNumeric.value;
  final String a = one ?? '';
  final String b = other ?? '';

  return _or(_compareCaseLowerFirst(a, b), _compareAndDisambiguateByLength(collatorNumeric, a, b));
}

/// Compares full filenames by unicode value.
int compareFileNamesUnicode(String? one, String? other) {
  final String a = one ?? '';
  final String b = other ?? '';

  if (a == b) {
    return 0;
  }

  return a.compareTo(b) < 0 ? -1 : 1;
}

/// Compares filenames by extension, then by name. Disambiguates by unicode comparison.
int compareFileExtensions(String? one, String? other) {
  final (String, String) onePair = _extractNameAndExtension(one);
  final String oneName = onePair.$1;
  final String oneExtension = onePair.$2;
  final (String, String) otherPair = _extractNameAndExtension(other);
  final String otherName = otherPair.$1;
  final String otherExtension = otherPair.$2;

  int result = intlFileNameCollatorBaseNumeric.value.$1.compare(oneExtension, otherExtension);

  if (result == 0) {
    // Using the numeric option will  make compare(`foo1`, `foo01`) === 0. Disambiguate.
    if (intlFileNameCollatorBaseNumeric.value.$2 && oneExtension != otherExtension) {
      return oneExtension.compareTo(otherExtension) < 0 ? -1 : 1;
    }

    // Extensions are equal, compare filenames
    result = intlFileNameCollatorBaseNumeric.value.$1.compare(oneName, otherName);

    if (intlFileNameCollatorBaseNumeric.value.$2 && result == 0 && oneName != otherName) {
      return oneName.compareTo(otherName) < 0 ? -1 : 1;
    }
  }

  return result;
}

/// Compares filenames by extension, then by full filename. Mixes uppercase and lowercase names together.
int compareFileExtensionsDefault(String? one, String? other) {
  final String a = one ?? '';
  final String b = other ?? '';
  final String oneExtension = _extractExtension(a);
  final String otherExtension = _extractExtension(b);
  final IntlCollator collatorNumeric = intlFileNameCollatorNumeric.value;
  final IntlCollator collatorNumericCaseInsensitive = intlFileNameCollatorNumericCaseInsensitive.value;

  return _or(_compareAndDisambiguateByLength(collatorNumericCaseInsensitive, oneExtension, otherExtension),
      _compareAndDisambiguateByLength(collatorNumeric, a, b));
}

/// Compares filenames by extension, then case, then full filename. Groups uppercase names before lowercase.
int compareFileExtensionsUpper(String? one, String? other) {
  final String a = one ?? '';
  final String b = other ?? '';
  final String oneExtension = _extractExtension(a);
  final String otherExtension = _extractExtension(b);
  final IntlCollator collatorNumeric = intlFileNameCollatorNumeric.value;
  final IntlCollator collatorNumericCaseInsensitive = intlFileNameCollatorNumericCaseInsensitive.value;

  return _or(_or(_compareAndDisambiguateByLength(collatorNumericCaseInsensitive, oneExtension, otherExtension),
      _compareCaseUpperFirst(a, b)),
      _compareAndDisambiguateByLength(collatorNumeric, a, b));
}

/// Compares filenames by extension, then case, then full filename. Groups lowercase names before uppercase.
int compareFileExtensionsLower(String? one, String? other) {
  final String a = one ?? '';
  final String b = other ?? '';
  final String oneExtension = _extractExtension(a);
  final String otherExtension = _extractExtension(b);
  final IntlCollator collatorNumeric = intlFileNameCollatorNumeric.value;
  final IntlCollator collatorNumericCaseInsensitive = intlFileNameCollatorNumericCaseInsensitive.value;

  return _or(_or(_compareAndDisambiguateByLength(collatorNumericCaseInsensitive, oneExtension, otherExtension),
      _compareCaseLowerFirst(a, b)),
      _compareAndDisambiguateByLength(collatorNumeric, a, b));
}

/// Compares filenames by case-insensitive extension unicode value, then by full filename unicode value.
int compareFileExtensionsUnicode(String? one, String? other) {
  final String a = one ?? '';
  final String b = other ?? '';
  final String oneExtension = _extractExtension(a).toLowerCase();
  final String otherExtension = _extractExtension(b).toLowerCase();

  // Check for extension differences
  if (oneExtension != otherExtension) {
    return oneExtension.compareTo(otherExtension) < 0 ? -1 : 1;
  }

  // Check for full filename differences.
  if (a != b) {
    return a.compareTo(b) < 0 ? -1 : 1;
  }

  return 0;
}

final RegExp FileNameMatch = RegExp(r'^(.*?)(\.([^.]*))?$');

/// Extracts the name and extension from a full filename, with optional special handling for dotfiles
(String, String) _extractNameAndExtension([String? str, bool dotfilesAsNames = false]) {
  final RegExpMatch? match = (str != null && str.isNotEmpty) ? FileNameMatch.firstMatch(str) : null;

  (String, String) result = ((match?.group(1)) ?? '', (match?.group(3)) ?? '');

  // if the dotfilesAsNames option is selected, treat an empty filename with an extension
  // or a filename that starts with a dot, as a dotfile name
  if (dotfilesAsNames && ((result.$1.isEmpty && result.$2.isNotEmpty) || (result.$1.isNotEmpty && result.$1[0] == '.'))) {
    result = (result.$1 + '.' + result.$2, '');
  }

  return result;
}

/// Extracts the extension from a full filename. Treats dotfiles as names, not extensions.
String _extractExtension([String? str]) {
  final RegExpMatch? match = (str != null && str.isNotEmpty) ? FileNameMatch.firstMatch(str) : null;

  return (match != null && (match.group(1) ?? '').isNotEmpty && match.group(1)![0] != '.' && match.group(3) != null)
      ? match.group(3)!
      : '';
}

/// JS `a || b` for numeric comparison results: first non-zero, else zero.
int _or(int a, int b) => a != 0 ? a : b;

int _compareAndDisambiguateByLength(IntlCollator collator, String one, String other) {
  // Check for differences
  final int result = collator.compare(one, other);
  if (result != 0) {
    return result;
  }

  // In a numeric comparison, `foo1` and `foo01` will compare as equivalent.
  // Disambiguate by sorting the shorter string first.
  if (one.length != other.length) {
    return one.length < other.length ? -1 : 1;
  }

  return 0;
}

/// @returns `true` if the string is starts with a lowercase letter. Otherwise, `false`.
bool _startsWithLower(String string) {
  final String character = string.isEmpty ? '' : string[0];

  return (character.toUpperCase() != character);
}

/// @returns `true` if the string starts with an uppercase letter. Otherwise, `false`.
bool _startsWithUpper(String string) {
  final String character = string.isEmpty ? '' : string[0];

  return (character.toLowerCase() != character);
}

/// Compares the case of the provided strings - lowercase before uppercase
int _compareCaseLowerFirst(String one, String other) {
  if (_startsWithLower(one) && _startsWithUpper(other)) {
    return -1;
  }
  return (_startsWithUpper(one) && _startsWithLower(other)) ? 1 : 0;
}

/// Compares the case of the provided strings - uppercase before lowercase
int _compareCaseUpperFirst(String one, String other) {
  if (_startsWithUpper(one) && _startsWithLower(other)) {
    return -1;
  }
  return (_startsWithLower(one) && _startsWithUpper(other)) ? 1 : 0;
}

int _comparePathComponents(String one, String other, [bool caseSensitive = false]) {
  if (!caseSensitive) {
    one = one.toLowerCase();
    other = other.toLowerCase();
  }

  if (one == other) {
    return 0;
  }

  return one.compareTo(other) < 0 ? -1 : 1;
}

int comparePaths(String one, String other, [bool caseSensitive = false]) {
  final List<String> oneParts = one.split(pth.sep);
  final List<String> otherParts = other.split(pth.sep);

  final int lastOne = oneParts.length - 1;
  final int lastOther = otherParts.length - 1;

  for (int i = 0; ; i++) {
    final bool endOne = lastOne == i;
    final bool endOther = lastOther == i;

    if (endOne && endOther) {
      return compareFileNames(oneParts[i], otherParts[i], caseSensitive);
    } else if (endOne) {
      return -1;
    } else if (endOther) {
      return 1;
    }

    final int result = _comparePathComponents(oneParts[i], otherParts[i], caseSensitive);

    if (result != 0) {
      return result;
    }
  }
}

int compareAnything(String one, String other, String lookFor) {
  final String elementAName = one.toLowerCase();
  final String elementBName = other.toLowerCase();

  // Sort prefix matches over non prefix matches
  final int prefixCompare = compareByPrefix(one, other, lookFor);
  if (prefixCompare != 0) {
    return prefixCompare;
  }

  // Sort suffix matches over non suffix matches
  final bool elementASuffixMatch = elementAName.endsWith(lookFor);
  final bool elementBSuffixMatch = elementBName.endsWith(lookFor);
  if (elementASuffixMatch != elementBSuffixMatch) {
    return elementASuffixMatch ? -1 : 1;
  }

  // Understand file names
  final int r = compareFileNames(elementAName, elementBName);
  if (r != 0) {
    return r;
  }

  // Compare by name
  return elementAName.compareTo(elementBName);
}

int compareByPrefix(String one, String other, String lookFor) {
  final String elementAName = one.toLowerCase();
  final String elementBName = other.toLowerCase();

  // Sort prefix matches over non prefix matches
  final bool elementAPrefixMatch = elementAName.startsWith(lookFor);
  final bool elementBPrefixMatch = elementBName.startsWith(lookFor);
  if (elementAPrefixMatch != elementBPrefixMatch) {
    return elementAPrefixMatch ? -1 : 1;
  }
  // Same prefix: Sort shorter matches to the top to have those on top that match more precisely
  else if (elementAPrefixMatch && elementBPrefixMatch) {
    if (elementAName.length < elementBName.length) {
      return -1;
    }

    if (elementAName.length > elementBName.length) {
      return 1;
    }
  }

  return 0;
}
