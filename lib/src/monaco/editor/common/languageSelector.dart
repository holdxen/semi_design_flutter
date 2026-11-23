// 1:1 port of vs/editor/common/languageSelector.ts

import '../../base/common/glob.dart' as glob show RelativePattern, match;
import '../../base/common/path.dart' show normalize;
import '../../base/common/uri.dart' show URI;

/// 1:1: `export interface LanguageFilter`
///
/// Source fields are `readonly`; Dart exposes them as final fields. The source
/// also allows plain object literals to be passed as filters, so [score] and
/// friends accept either a [LanguageFilter] or a `Map<String, Object?>`.
class LanguageFilter {
  final String? language;
  final String? scheme;
  final Object? pattern; // String | RelativePattern
  final String? notebookType;
  final bool? hasAccessToAllModels;
  final bool? exclusive;
  final bool? isBuiltin;

  const LanguageFilter({
    this.language,
    this.scheme,
    this.pattern,
    this.notebookType,
    this.hasAccessToAllModels,
    this.exclusive,
    this.isBuiltin,
  });
}

/// 1:1: `export type LanguageSelector = string | LanguageFilter | ReadonlyArray<string | LanguageFilter>`
///
/// Represented as `Object?`: [String], [LanguageFilter], [Map] (object literal
/// filter) or [List] thereof.
typedef LanguageSelector = Object?;

String? _filterLanguage(Object? filter) {
  if (filter is LanguageFilter) {
    return filter.language;
  }
  if (filter is Map) {
    return filter['language'] as String?;
  }
  return null;
}

String? _filterScheme(Object? filter) {
  if (filter is LanguageFilter) {
    return filter.scheme;
  }
  if (filter is Map) {
    return filter['scheme'] as String?;
  }
  return null;
}

Object? _filterPattern(Object? filter) {
  if (filter is LanguageFilter) {
    return filter.pattern;
  }
  if (filter is Map) {
    return filter['pattern'];
  }
  return null;
}

String? _filterNotebookType(Object? filter) {
  if (filter is LanguageFilter) {
    return filter.notebookType;
  }
  if (filter is Map) {
    return filter['notebookType'] as String?;
  }
  return null;
}

bool? _filterHasAccessToAllModels(Object? filter) {
  if (filter is LanguageFilter) {
    return filter.hasAccessToAllModels;
  }
  if (filter is Map) {
    return filter['hasAccessToAllModels'] as bool?;
  }
  return null;
}

/// 1:1: `export function score`
int score(
  Object? selector,
  URI candidateUri,
  String candidateLanguage,
  bool candidateIsSynchronized,
  URI? candidateNotebookUri,
  String? candidateNotebookType,
) {
  if (selector is List) {
    // array -> take max individual value
    int ret = 0;
    for (final Object? filter in selector) {
      final int value = score(filter, candidateUri, candidateLanguage,
          candidateIsSynchronized, candidateNotebookUri, candidateNotebookType);
      if (value == 10) {
        return value; // already at the highest
      }
      if (value > ret) {
        ret = value;
      }
    }
    return ret;
  } else if (selector is String) {
    if (!candidateIsSynchronized) {
      return 0;
    }

    // short-hand notion, desugars to
    // 'fooLang' -> { language: 'fooLang'}
    // '*' -> { language: '*' }
    if (selector == '*') {
      return 5;
    } else if (selector == candidateLanguage) {
      return 10;
    } else {
      return 0;
    }
  } else if (selector != null) {
    // filter -> select accordingly, use defaults for scheme
    final Object? language = _filterLanguage(selector);
    final Object? pattern = _filterPattern(selector);
    final Object? scheme = _filterScheme(selector);
    final bool? hasAccessToAllModels = _filterHasAccessToAllModels(selector);
    final Object? notebookType = _filterNotebookType(selector);

    if (!candidateIsSynchronized && hasAccessToAllModels != true) {
      return 0;
    }

    // selector targets a notebook -> use the notebook uri instead
    // of the "normal" document uri.
    URI effectiveUri = candidateUri;
    if (notebookType != null &&
        notebookType is String &&
        notebookType.isNotEmpty &&
        candidateNotebookUri != null) {
      effectiveUri = candidateNotebookUri;
    }

    int ret = 0;

    if (scheme is String && scheme.isNotEmpty) {
      if (scheme == effectiveUri.scheme) {
        ret = 10;
      } else if (scheme == '*') {
        ret = 5;
      } else {
        return 0;
      }
    }

    if (language is String && language.isNotEmpty) {
      if (language == candidateLanguage) {
        ret = 10;
      } else if (language == '*') {
        ret = ret > 5 ? ret : 5;
      } else {
        return 0;
      }
    }

    if (notebookType is String && notebookType.isNotEmpty) {
      if (notebookType == candidateNotebookType) {
        ret = 10;
      } else if (notebookType == '*' && candidateNotebookType != null) {
        ret = ret > 5 ? ret : 5;
      } else {
        return 0;
      }
    }

    // Source: `if (pattern)` — an empty string is falsy in JS.
    if (pattern != null && (pattern is! String || pattern.isNotEmpty)) {
      Object? normalizedPattern;
      if (pattern is String) {
        normalizedPattern = pattern;
      } else if (pattern is glob.RelativePattern) {
        // Since this pattern has a `base` property, we need to normalize this
        // path first before passing it on because we will compare it against
        // `Uri.fsPath` which uses platform specific separators.
        normalizedPattern = glob.RelativePattern(
          base: normalize(pattern.base),
          pattern: pattern.pattern,
        );
      } else if (pattern is Map &&
          pattern['base'] is String &&
          pattern['pattern'] is String) {
        normalizedPattern = glob.RelativePattern(
          base: normalize(pattern['base'] as String),
          pattern: pattern['pattern'] as String,
        );
      } else {
        normalizedPattern = pattern;
      }

      if ((normalizedPattern is String &&
              normalizedPattern == effectiveUri.fsPath) ||
          glob.match(normalizedPattern, effectiveUri.fsPath)) {
        ret = 10;
      } else {
        return 0;
      }
    }

    return ret;
  } else {
    return 0;
  }
}

/// 1:1: `export function targetsNotebooks`
bool targetsNotebooks(Object? selector) {
  if (selector is String) {
    return false;
  } else if (selector is List) {
    return selector.any(targetsNotebooks);
  } else {
    final String? notebookType = _filterNotebookType(selector);
    return notebookType != null && notebookType.isNotEmpty;
  }
}

/// 1:1: `export function selectLanguageIds`
void selectLanguageIds(Object? selector, Set<String> into) {
  if (selector is String) {
    into.add(selector);
  } else if (selector is List) {
    for (final Object? item in selector) {
      selectLanguageIds(item, into);
    }
  } else {
    final String? language = _filterLanguage(selector);
    if (language != null && language.isNotEmpty) {
      into.add(language);
    }
  }
}
