// ---------------------------------------------------------------------------
// Port of vscode/src/vs/base/common/glob.ts
// Translated 1:1 from TypeScript.
//
// TS callable functions with attached metadata properties are expressed as
// carrier classes implementing `call()`.  The `string | Promise<string>` return
// union is expressed with `FutureOr<String?>`.
// ---------------------------------------------------------------------------

import 'dart:async' show FutureOr;

import 'arrays.dart' show equals;
import 'charCode.dart' show CharCode;
import 'extpath.dart' as extpath show isEqualOrParent;
import 'map.dart' show LRUCache;
import 'path.dart' show basename, extname, isAbsolute, posix, sep;
import 'platform.dart' show isLinux;
import 'strings.dart'
    show
        endsWithIgnoreCase,
        equalsIgnoreCase,
        escapeRegExpCharacters,
        ltrim,
        rtrim;

/// 1:1: `export interface IRelativePattern`
class RelativePattern {
  final String base;
  final String pattern;
  RelativePattern({required this.base, required this.pattern});
}

/// 1:1: `interface SiblingClause { when: string }`
class SiblingClause {
  final String when;
  SiblingClause({required this.when});
}

/// 1:1: `export interface IExpression { [pattern: string]: boolean | SiblingClause }`
typedef IExpression = Map<String, Object?>;

IExpression getEmptyExpression() => <String, Object?>{};

const String GLOBSTAR = '**';
const String GLOB_SPLIT = '/';

const String _pathRegex = r'[/\\]';
const String _noPathRegex = r'[^/\\]';
final RegExp _allForwardSlashes = RegExp(r'/');

/// 1:1: `starsToRegExp`
String starsToRegExp(int starCount, [bool? isLastPattern]) {
  switch (starCount) {
    case 0:
      return '';
    case 1:
      return '$_noPathRegex*?';
    default:
      return '(?:$_pathRegex|$_noPathRegex+$_pathRegex'
          '${isLastPattern == true ? '|$_pathRegex$_noPathRegex+' : ''})*?';
  }
}

/// 1:1: `export function splitGlobAware`
List<String> splitGlobAware(String pattern, String splitChar) {
  if (pattern.isEmpty) {
    return <String>[];
  }

  final List<String> segments = <String>[];
  bool inBraces = false;
  bool inBrackets = false;
  String curVal = '';
  for (final int rune in pattern.runes) {
    final String char = String.fromCharCode(rune);
    if (char == splitChar) {
      if (!inBraces && !inBrackets) {
        segments.add(curVal);
        curVal = '';
        continue;
      }
    } else if (char == '{') {
      inBraces = true;
    } else if (char == '}') {
      inBraces = false;
    } else if (char == '[') {
      inBrackets = true;
    } else if (char == ']') {
      inBrackets = false;
    }
    curVal += char;
  }

  if (curVal.isNotEmpty) {
    segments.add(curVal);
  }
  return segments;
}

/// 1:1: `parseRegExp`
String parseRegExp(String pattern) {
  if (pattern.isEmpty) {
    return '';
  }

  String regEx = '';
  final List<String> segments = splitGlobAware(pattern, GLOB_SPLIT);

  if (segments.every((String segment) => segment == GLOBSTAR)) {
    regEx = '.*';
  } else {
    bool previousSegmentWasGlobStar = false;
    for (int index = 0; index < segments.length; index++) {
      final String segment = segments[index];
      if (segment == GLOBSTAR) {
        if (previousSegmentWasGlobStar) {
          previousSegmentWasGlobStar = true;
          continue;
        }
        regEx += starsToRegExp(2, index == segments.length - 1);
      } else {
        bool inBraces = false;
        String braceVal = '';
        bool inBrackets = false;
        String bracketVal = '';

        for (final int rune in segment.runes) {
          final String char = String.fromCharCode(rune);

          if (char != '}' && inBraces) {
            braceVal += char;
            continue;
          }

          if (inBrackets && (char != ']' || bracketVal.isEmpty)) {
            final String res;
            if (char == '-') {
              res = char;
            } else if ((char == '^' || char == '!') && bracketVal.isEmpty) {
              res = '^';
            } else if (char == GLOB_SPLIT) {
              res = '';
            } else {
              res = escapeRegExpCharacters(char);
            }
            bracketVal += res;
            continue;
          }

          if (char == '{') {
            inBraces = true;
          } else if (char == '[') {
            inBrackets = true;
          } else if (char == '}') {
            final List<String> choices = splitGlobAware(braceVal, ',');
            final String braceRegExp =
                '(?:${choices.map((String c) => parseRegExp(c)).join('|')})';
            regEx += braceRegExp;
            inBraces = false;
            braceVal = '';
          } else if (char == ']') {
            regEx += '[$bracketVal]';
            inBrackets = false;
            bracketVal = '';
          } else if (char == '?') {
            regEx += _noPathRegex;
          } else if (char == '*') {
            regEx += starsToRegExp(1);
          } else {
            regEx += escapeRegExpCharacters(char);
          }
        }

        if (index < segments.length - 1 &&
            (segments[index + 1] != GLOBSTAR || index + 2 < segments.length)) {
          regEx += _pathRegex;
        }
      }
      previousSegmentWasGlobStar = (segment == GLOBSTAR);
    }
  }
  return regEx;
}

// regexes to check for trivial glob patterns that just check for String#endsWith
final RegExp _t1 = RegExp(r'^\*\*/\*\.[\w.-]+$');
final RegExp _t2 = RegExp(r'^\*\*/([\w.-]+)/?$');
final RegExp _t3 = RegExp(r'^{\*\*/\*?[\w.-]+/?(,\*\*/\*?[\w.-]+/?)*}$');
final RegExp _t3_2 =
    RegExp(r'^{\*\*/\*?[\w.-]+(/(\*\*)?)?(,\*\*/\*?[\w.-]+(/(\*\*)?)?)*}$');
final RegExp _t4 = RegExp(r'^\*\*((/[\w.-]+)+)/?$');
final RegExp _t5 = RegExp(r'^([\w.-]+(/[\w.-]+)*)/?$');

/// 1:1: `export interface IGlobOptions`
class GlobOptions {
  bool trimForExclusions;
  bool? ignoreCase;
  GlobOptions({this.trimForExclusions = false, this.ignoreCase});
}

/// 1:1: `interface IGlobOptionsInternal`
class GlobOptionsInternal extends GlobOptions {
  final bool Function(String a, String b) equalsFn;
  final bool Function(String str, String candidate) endsWithFn;
  final bool Function(String base, String candidate) isEqualOrParentFn;
  GlobOptionsInternal({
    required bool trimForExclusions,
    required bool? ignoreCase,
    required this.equalsFn,
    required this.endsWithFn,
    required this.isEqualOrParentFn,
  }) : super(trimForExclusions: trimForExclusions, ignoreCase: ignoreCase);
}

/// Internal callable, TS `ParsedStringPattern | ParsedExpressionPattern`.
/// Returns the matching pattern string or null, possibly async. Metadata
/// fields mirror the properties attached to the TS function object.
class PatternMatcher {
  final FutureOr<String?> Function(
      String path, String? basename, String? name, HasSiblingFn? hasSibling) _fn;

  PatternMatcher(this._fn);

  List<String>? basenames;
  List<String>? patterns;
  List<String>? allBasenames;
  List<String>? allPaths;
  bool requiresSiblings = false;

  FutureOr<String?> call(String path,
          [String? basename, String? name, HasSiblingFn? hasSibling]) =>
      _fn(path, basename, name, hasSibling);
}

/// 1:1: hasSibling callback returning `boolean | Promise<boolean>`.
typedef HasSiblingFn = FutureOr<bool> Function(String name);

/// Public callable, TS `ParsedPattern | ParsedExpression`.
/// String patterns yield bool; expressions yield String?/null (or Future).
class ParsedGlobFn {
  final FutureOr<Object?> Function(
      String path, String? basename, HasSiblingFn? hasSibling) _fn;
  ParsedGlobFn(this._fn);

  List<String>? allBasenames;
  List<String>? allPaths;

  FutureOr<Object?> call(String path,
          [String? basename, HasSiblingFn? hasSibling]) =>
      _fn(path, basename, hasSibling);
}

const int _cacheLimit = 10000;
final LRUCache<String, PatternMatcher> _cache =
    LRUCache<String, PatternMatcher>(_cacheLimit);

final PatternMatcher _nullMatcher =
    PatternMatcher((path, basename, name, hasSibling) => null);

final ParsedGlobFn FALSE_FN = ParsedGlobFn((path, basename, hasSibling) => false);
final ParsedGlobFn NULL_FN = ParsedGlobFn((path, basename, hasSibling) => null);

/// 1:1: `export function isEmptyPattern`
bool isEmptyPattern(ParsedGlobFn pattern) =>
    identical(pattern, FALSE_FN) || identical(pattern, NULL_FN);

bool _isRelative(Object? obj) {
  if (obj == null) {
    return false;
  }
  if (obj is RelativePattern) {
    return true;
  }
  if (obj is IExpression) {
    return obj['base'] is String && obj['pattern'] is String;
  }
  return false;
}

String _patternOf(Object arg1) {
  if (arg1 is String) {
    return arg1;
  }
  if (arg1 is RelativePattern) {
    return arg1.pattern;
  }
  return (arg1 as IExpression)['pattern'] as String;
}

String _baseOf(Object arg2) {
  if (arg2 is RelativePattern) {
    return arg2.base;
  }
  return (arg2 as IExpression)['base'] as String;
}

/// 1:1: `parsePattern`
PatternMatcher parsePattern(Object arg1, GlobOptions options, [String? cacheKey]) {
  if (_isFalsyPatternArg(arg1)) {
    return _nullMatcher;
  }
  String pattern = _patternOf(arg1).trim();

  final bool ignoreCase = options.ignoreCase ?? false;
  final GlobOptionsInternal internalOptions = GlobOptionsInternal(
    trimForExclusions: options.trimForExclusions,
    ignoreCase: options.ignoreCase,
    equalsFn: ignoreCase ? equalsIgnoreCase : (String a, String b) => a == b,
    endsWithFn: ignoreCase
        ? endsWithIgnoreCase
        : (String str, String candidate) => str.endsWith(candidate),
    isEqualOrParentFn: (String base, String candidate) =>
        extpath.isEqualOrParent(base, candidate,
            options.ignoreCase ?? !isLinux),
  );

  final String patternKey =
      '${cacheKey == null ? 'default:${ignoreCase ? pattern.toLowerCase() : pattern}' : 'custom:$cacheKey'}'
      '_${options.trimForExclusions}_$ignoreCase';
  final PatternMatcher? cached = _cache.get(patternKey);
  if (cached != null) {
    return wrapRelativePattern(cached, arg1, internalOptions);
  }

  late final PatternMatcher parsedPattern;
  RegExpMatch? match;
  if (_t1.hasMatch(pattern)) {
    parsedPattern = _trivia1(pattern.substring(4), pattern, internalOptions);
  } else if ((match = _t2.firstMatch(_trimForExclusions(pattern, internalOptions))) !=
      null) {
    parsedPattern = _trivia2(match!.group(1)!, pattern, internalOptions);
  } else if ((options.trimForExclusions ? _t3_2 : _t3).hasMatch(pattern)) {
    parsedPattern = _trivia3(pattern, internalOptions);
  } else if ((match = _t4.firstMatch(
          _trimForExclusions(pattern, internalOptions))) !=
      null) {
    parsedPattern = _trivia4and5(
        match!.group(1)!.substring(1), pattern, true, internalOptions);
  } else if ((match = _t5.firstMatch(
          _trimForExclusions(pattern, internalOptions))) !=
      null) {
    parsedPattern =
        _trivia4and5(match!.group(1)!, pattern, false, internalOptions);
  } else {
    parsedPattern = _toRegExp(pattern, internalOptions);
  }

  _cache.set(patternKey, parsedPattern);
  return wrapRelativePattern(parsedPattern, arg1, internalOptions);
}

bool _isFalsyPatternArg(Object? arg1) =>
    arg1 == null || (arg1 is String && arg1.isEmpty);

/// 1:1: `wrapRelativePattern`
PatternMatcher wrapRelativePattern(
    PatternMatcher parsedPattern, Object arg2, GlobOptionsInternal options) {
  if (arg2 is String) {
    return parsedPattern;
  }
  final String base = _baseOf(arg2);
  final PatternMatcher wrapped = PatternMatcher((path, basename, name, hasSibling) {
    if (!options.isEqualOrParentFn(path, base)) {
      return null;
    }
    return parsedPattern(ltrim(path.substring(base.length), sep), basename);
  });
  wrapped.allBasenames = parsedPattern.allBasenames;
  wrapped.allPaths = parsedPattern.allPaths;
  wrapped.basenames = parsedPattern.basenames;
  wrapped.patterns = parsedPattern.patterns;
  return wrapped;
}

/// 1:1: `trimForExclusions`
String _trimForExclusions(String pattern, GlobOptions options) =>
    options.trimForExclusions && pattern.endsWith('/**')
        ? pattern.substring(0, pattern.length - 2)
        : pattern;

/// 1:1: `trivia1`
PatternMatcher _trivia1(
        String base, String pattern, GlobOptionsInternal options) =>
    PatternMatcher((path, basename, name, hasSibling) =>
        options.endsWithFn(path, base) ? pattern : null);

/// 1:1: `trivia2`
PatternMatcher _trivia2(
    String base, String pattern, GlobOptionsInternal options) {
  final String slashBase = '/$base';
  final String backslashBase = '\\$base';
  final PatternMatcher parsed = PatternMatcher((path, basename, name, hasSibling) {
    if (basename != null) {
      return options.equalsFn(basename, base) ? pattern : null;
    }
    return options.equalsFn(path, base) ||
            options.endsWithFn(path, slashBase) ||
            options.endsWithFn(path, backslashBase)
        ? pattern
        : null;
  });
  final List<String> basenames = <String>[base];
  parsed.basenames = basenames;
  parsed.patterns = <String>[pattern];
  parsed.allBasenames = basenames;
  return parsed;
}

/// 1:1: `trivia3`
PatternMatcher _trivia3(String pattern, GlobOptionsInternal options) {
  final List<PatternMatcher> parsedPatterns = aggregateBasenameMatches(
    splitGlobAware(pattern.substring(1, pattern.length - 1), ',')
        .map((String p) => parsePattern(p, options))
        .where((PatternMatcher p) => !identical(p, _nullMatcher))
        .toList(),
    pattern,
    options.ignoreCase,
  );
  final int patternsLength = parsedPatterns.length;
  if (patternsLength == 0) {
    return _nullMatcher;
  }
  if (patternsLength == 1) {
    return parsedPatterns[0];
  }

  final PatternMatcher parsed = PatternMatcher((path, basename, name, hasSibling) {
    for (final PatternMatcher p in parsedPatterns) {
      if (p(path, basename) != null) {
        return pattern;
      }
    }
    return null;
  });
  for (final PatternMatcher p in parsedPatterns) {
    if (p.allBasenames != null) {
      parsed.allBasenames = p.allBasenames;
      break;
    }
  }
  final List<String> allPaths = <String>[];
  for (final PatternMatcher p in parsedPatterns) {
    if (p.allPaths != null) {
      allPaths.addAll(p.allPaths!);
    }
  }
  if (allPaths.isNotEmpty) {
    parsed.allPaths = allPaths;
  }
  return parsed;
}

/// 1:1: `trivia4and5`
PatternMatcher _trivia4and5(String targetPath, String pattern,
    bool matchPathEnds, GlobOptionsInternal options) {
  final bool usingPosixSep = sep == posix.sep;
  final String nativePath = usingPosixSep
      ? targetPath
      : targetPath.replaceAll(_allForwardSlashes, sep);
  final String nativePathEnd = sep + nativePath;
  final String targetPathEnd = posix.sep + targetPath;

  late final PatternMatcher parsed;
  if (matchPathEnds) {
    parsed = PatternMatcher((path, basename, name, hasSibling) =>
        (options.equalsFn(path, nativePath) ||
                options.endsWithFn(path, nativePathEnd)) ||
            (!usingPosixSep &&
                (options.equalsFn(path, targetPath) ||
                    options.endsWithFn(path, targetPathEnd)))
            ? pattern
            : null);
  } else {
    parsed = PatternMatcher((path, basename, name, hasSibling) =>
        options.equalsFn(path, nativePath) ||
                (!usingPosixSep && options.equalsFn(path, targetPath))
            ? pattern
            : null);
  }
  parsed.allPaths = <String>[(matchPathEnds ? '*/' : './') + targetPath];
  return parsed;
}

/// 1:1: `toRegExp`
PatternMatcher _toRegExp(String pattern, GlobOptions options) {
  try {
    final RegExp regExp = RegExp('^${parseRegExp(pattern)}\$',
        caseSensitive: !(options.ignoreCase ?? false));
    return PatternMatcher((path, basename, name, hasSibling) =>
        regExp.hasMatch(path) ? pattern : null);
  } catch (_) {
    return _nullMatcher;
  }
}

/// 1:1: `export function match`
bool match(Object? arg1, String path, [GlobOptions? options]) {
  if (_isFalsyPatternArg(arg1) &&
      arg1 is! IExpression) {
    return false;
  }
  final Object? result = parse(arg1, options)(path);
  if (result is Future) {
    throw StateError('match() is synchronous; use parse() for async expressions');
  }
  return _truthy(result);
}

bool _truthy(Object? value) {
  if (value == null) {
    return false;
  }
  if (value is bool) {
    return value;
  }
  if (value is String) {
    return value.isNotEmpty;
  }
  return true;
}

/// 1:1: `export function parse`
ParsedGlobFn parse(Object? arg1, [GlobOptions? options]) {
  options ??= GlobOptions();
  if (arg1 == null || (arg1 is String && arg1.isEmpty)) {
    return FALSE_FN;
  }

  // Glob with String
  if (arg1 is String || _isRelative(arg1)) {
    final PatternMatcher parsedPattern = parsePattern(arg1, options);
    if (identical(parsedPattern, _nullMatcher)) {
      return FALSE_FN;
    }
    final ParsedGlobFn resultPattern = ParsedGlobFn((path, basename, hasSibling) {
      final Object? r = parsedPattern(path, basename);
      if (r is Future<String?>) {
        return r.then((String? v) => v != null);
      }
      return r != null;
    });
    resultPattern.allBasenames = parsedPattern.allBasenames;
    resultPattern.allPaths = parsedPattern.allPaths;
    return resultPattern;
  }

  // Glob with Expression
  return parsedExpression(arg1 as IExpression, options);
}

/// 1:1: `export function isRelativePattern`
bool isRelativePattern(Object? obj) => _isRelative(obj);

/// 1:1: `export function getBasenameTerms`
List<String> getBasenameTerms(ParsedGlobFn patternOrExpression) =>
    patternOrExpression.allBasenames ?? <String>[];

/// 1:1: `export function getPathTerms`
List<String> getPathTerms(ParsedGlobFn patternOrExpression) =>
    patternOrExpression.allPaths ?? <String>[];

/// 1:1: `export function patternsEquals`
bool patternsEquals(List<Object?>? patternsA, List<Object?>? patternsB) =>
    equals<Object?>(patternsA, patternsB, (Object? a, Object? b) {
      if (a is String && b is String) {
        return a == b;
      }
      if (a is! String && b is! String) {
        return _baseOf(a!) == _baseOf(b!) &&
            _patternOf(a) == _patternOf(b);
      }
      return false;
    });

// ---------------------------------------------------------------------------
// Expressions
// ---------------------------------------------------------------------------

/// 1:1: `parsedExpression`
ParsedGlobFn parsedExpression(IExpression expression, GlobOptions options) {
  final List<PatternMatcher> parsedPatterns = aggregateBasenameMatches(
    expression.keys
        .map((String pattern) =>
            parseExpressionPattern(pattern, expression[pattern], options))
        .where((PatternMatcher p) => !identical(p, _nullMatcher))
        .toList(),
    null,
    options.ignoreCase,
  );

  final int patternsLength = parsedPatterns.length;
  if (patternsLength == 0) {
    return NULL_FN;
  }

  if (!parsedPatterns.any((PatternMatcher p) => p.requiresSiblings)) {
    if (patternsLength == 1) {
      final PatternMatcher single = parsedPatterns[0];
      final ParsedGlobFn result =
          ParsedGlobFn((path, basename, hasSibling) => single(path, basename));
      result.allBasenames = single.allBasenames;
      result.allPaths = single.allPaths;
      return result;
    }

    final ParsedGlobFn resultExpression =
        ParsedGlobFn((path, basename, hasSibling) {
      List<Future<String?>>? resultPromises;
      for (final PatternMatcher p in parsedPatterns) {
        final Object? result = p(path, basename);
        if (result is String) {
          return result;
        }
        if (result is Future<String?>) {
          resultPromises ??= <Future<String?>>[];
          resultPromises.add(result);
        }
      }
      if (resultPromises != null) {
        return _resolveFirstString(resultPromises);
      }
      return null;
    });
    _copyAggregateMetadata(parsedPatterns, resultExpression);
    return resultExpression;
  }

  final ParsedGlobFn resultExpression =
      ParsedGlobFn((path, base, hasSibling) {
    String? name;
    String? baseArg = base;
    List<Future<String?>>? resultPromises;
    for (final PatternMatcher p in parsedPatterns) {
      if (p.requiresSiblings && hasSibling != null) {
        baseArg ??= basename(path);
        name ??= baseArg.substring(0, baseArg.length - extname(path).length);
      }
      final Object? result = p(path, baseArg, name, hasSibling);
      if (result is String) {
        return result;
      }
      if (result is Future<String?>) {
        resultPromises ??= <Future<String?>>[];
        resultPromises.add(result);
      }
    }
    if (resultPromises != null) {
      return _resolveFirstString(resultPromises);
    }
    return null;
  });
  _copyAggregateMetadata(parsedPatterns, resultExpression);
  return resultExpression;
}

Future<String?> _resolveFirstString(List<Future<String?>> promises) async {
  for (final Future<String?> promise in promises) {
    final String? result = await promise;
    if (result != null) {
      return result;
    }
  }
  return null;
}

void _copyAggregateMetadata(
    List<PatternMatcher> parsedPatterns, ParsedGlobFn target) {
  for (final PatternMatcher p in parsedPatterns) {
    if (p.allBasenames != null) {
      target.allBasenames = p.allBasenames;
      break;
    }
  }
  final List<String> allPaths = <String>[];
  for (final PatternMatcher p in parsedPatterns) {
    if (p.allPaths != null) {
      allPaths.addAll(p.allPaths!);
    }
  }
  if (allPaths.isNotEmpty) {
    target.allPaths = allPaths;
  }
}

/// 1:1: `parseExpressionPattern`
PatternMatcher parseExpressionPattern(
    String pattern, Object? value, GlobOptions options) {
  if (identical(value, false)) {
    return _nullMatcher;
  }
  final PatternMatcher parsedPattern = parsePattern(pattern, options, pattern);
  if (identical(parsedPattern, _nullMatcher)) {
    return _nullMatcher;
  }

  if (value is bool) {
    return parsedPattern;
  }

  final String? when = value is SiblingClause
      ? value.when
      : value is IExpression
          ? value['when'] as String?
          : null;
  if (when != null) {
    final PatternMatcher result =
        PatternMatcher((path, basename, name, hasSibling) {
      if (hasSibling == null || parsedPattern(path, basename) == null) {
        return null;
      }
      final String clausePattern = when.replaceFirst('\$(basename)', name!);
      final Object? matched = hasSibling(clausePattern);
      if (matched is Future<bool>) {
        return matched.then<String?>((bool m) => m ? pattern : null);
      }
      return matched == true ? pattern : null;
    });
    result.requiresSiblings = true;
    return result;
  }

  return parsedPattern;
}

/// 1:1: `aggregateBasenameMatches`
List<PatternMatcher> aggregateBasenameMatches(
    List<PatternMatcher> parsedPatterns,
    [String? result, bool? ignoreCase]) {
  final List<PatternMatcher> basenamePatterns = parsedPatterns
      .where((PatternMatcher p) => p.basenames != null)
      .toList();
  if (basenamePatterns.length < 2) {
    return parsedPatterns;
  }

  final List<String> basenames = <String>[];
  for (final PatternMatcher p in basenamePatterns) {
    if (p.basenames != null) {
      basenames.addAll(p.basenames!);
    }
  }

  late final List<String> patterns;
  if (result != null) {
    patterns = List<String>.filled(basenames.length, result);
  } else {
    patterns = <String>[];
    for (final PatternMatcher p in basenamePatterns) {
      if (p.patterns != null) {
        patterns.addAll(p.patterns!);
      }
    }
  }

  final PatternMatcher aggregate =
      PatternMatcher((path, basename, name, hasSibling) {
    String base = basename ?? '';
    if (base.isEmpty) {
      int i;
      for (i = path.length; i > 0; i--) {
        final int ch = path.codeUnitAt(i - 1);
        if (ch == CharCode.Slash || ch == CharCode.Backslash) {
          break;
        }
      }
      base = path.substring(i);
    }
    final int index = ignoreCase == true
        ? basenames.indexWhere((String c) => equalsIgnoreCase(c, base))
        : basenames.indexOf(base);
    return index != -1 ? patterns[index] : null;
  });
  aggregate.basenames = basenames;
  aggregate.patterns = patterns;
  aggregate.allBasenames = basenames;

  final List<PatternMatcher> aggregated = parsedPatterns
      .where((PatternMatcher p) => p.basenames == null)
      .toList();
  aggregated.add(aggregate);
  return aggregated;
}

// ---------------------------------------------------------------------------
// Exclude exceptions
// ---------------------------------------------------------------------------

const String _excludeExceptionPrefix = '!';
const List<String> _versionControlFolders = <String>['.git', '.svn', '.hg', '.jj'];

/// 1:1: `export const EXCLUDE_EXCEPTION_KEY_PATTERN`
const String EXCLUDE_EXCEPTION_KEY_PATTERN = r'^\s*!';

/// 1:1: `export function isExcludeException`
bool isExcludeException(String pattern) =>
    pattern.trimLeft().startsWith(_excludeExceptionPrefix);

/// 1:1: `export function escapeExcludeException`
String escapeExcludeException(String pattern) {
  final String trimmed = pattern.trimLeft();
  return trimmed.startsWith(_excludeExceptionPrefix)
      ? '{!}${trimmed.substring(_excludeExceptionPrefix.length)}'
      : pattern;
}

/// 1:1: `export function getExcludeExceptions`
List<String> getExcludeExceptions(IExpression? expression) {
  final List<String> exceptions = <String>[];
  if (expression == null) {
    return exceptions;
  }
  for (final String key in expression.keys) {
    if (expression[key] != true || !isExcludeException(key)) {
      continue;
    }
    final String pattern = rtrim(
        key.trimLeft().substring(_excludeExceptionPrefix.length).trim(),
        GLOB_SPLIT);
    if (pattern.isNotEmpty && !isAbsolute(pattern)) {
      exceptions.add(pattern);
    }
  }
  return exceptions;
}

/// 1:1: `export function getFoldersSkippedByExcludeExceptions`
List<String> getFoldersSkippedByExcludeExceptions(List<String> exceptions) {
  final Set<String> namedSegments = <String>{};
  for (final String exception in exceptions) {
    for (final String pattern in expandBraces(exception)) {
      namedSegments.addAll(splitGlobAware(pattern, GLOB_SPLIT));
    }
  }
  return _versionControlFolders
      .where((String folder) => !namedSegments.contains(folder))
      .toList();
}

/// 1:1: `expandBraces`
List<String> expandBraces(String pattern) {
  final int start = pattern.indexOf('{');
  final int end = start == -1 ? -1 : pattern.indexOf('}', start);
  if (end == -1) {
    return <String>[pattern];
  }
  final String prefix = pattern.substring(0, start);
  final List<String> alternatives =
      splitGlobAware(pattern.substring(start + 1, end), ',');
  final List<String> suffixes = expandBraces(pattern.substring(end + 1));
  final List<String> alts = alternatives.isEmpty ? <String>[''] : alternatives;
  return alts
      .expand((String alternative) =>
          suffixes.map((String suffix) => '$prefix$alternative$suffix'))
      .toList();
}

/// 1:1: `export function withoutExcludeExceptions`
IExpression withoutExcludeExceptions(IExpression expression) {
  final IExpression result = <String, Object?>{};
  for (final String key in expression.keys) {
    if (!isExcludeException(key)) {
      result[key] = expression[key];
    }
  }
  return result;
}

/// 1:1: `export interface IParsedExcludeExpression` / `IExcludeTreeEvaluator`
abstract class IExcludeTreeEvaluator {
  Object? matchesExcludeFn(String path,
      [String? basename, HasSiblingFn? hasSibling]);
  bool isExcepted(String path, [String? basename]);
  bool couldExceptionMatchBeneath(String folderPath);
}

class ParsedExcludeExpression implements IExcludeTreeEvaluator {
  final ParsedGlobFn matches;
  final ParsedGlobFn excludeMatcher;
  final List<String> exceptions;
  final bool Function(String path, [String? basename]) _isExceptedFn;
  final bool Function(String folderPath) _couldBeneathFn;

  ParsedExcludeExpression({
    required this.matches,
    required ParsedGlobFn matchesExclude,
    required this.exceptions,
    required bool Function(String path, [String? basename]) isExcepted,
    required bool Function(String folderPath) couldExceptionMatchBeneath,
  })  : excludeMatcher = matchesExclude,
        _isExceptedFn = isExcepted,
        _couldBeneathFn = couldExceptionMatchBeneath;

  /// 1:1 field: `matchesExclude`
  ParsedGlobFn get matchesExclude => excludeMatcher;

  @override
  Object? matchesExcludeFn(String path,
          [String? basename, HasSiblingFn? hasSibling]) =>
      excludeMatcher(path, basename, hasSibling);

  @override
  bool isExcepted(String path, [String? basename]) =>
      _isExceptedFn(path, basename);

  @override
  bool couldExceptionMatchBeneath(String folderPath) =>
      _couldBeneathFn(folderPath);
}

/// 1:1: `export function parseExcludeExpression`
ParsedExcludeExpression parseExcludeExpression(IExpression expression,
    [GlobOptions? options]) {
  options ??= GlobOptions();
  final List<String> exceptions = getExcludeExceptions(expression);
  final bool hasExceptionKeys = expression.keys.any(isExcludeException);
  final ParsedGlobFn matchesExclude =
      parse(hasExceptionKeys ? withoutExcludeExceptions(expression) : expression,
          options);
  if (exceptions.isEmpty) {
    return ParsedExcludeExpression(
      matches: matchesExclude,
      matchesExclude: matchesExclude,
      exceptions: exceptions,
      isExcepted: (path, [basename]) => false,
      couldExceptionMatchBeneath: (folderPath) => false,
    );
  }

  final IExpression exceptionExpression = <String, Object?>{};
  for (final String exception in exceptions) {
    exceptionExpression[exception] = true;
    exceptionExpression['$exception$GLOB_SPLIT$GLOBSTAR'] = true;
  }

  final ParsedGlobFn matchesException = parse(exceptionExpression,
      GlobOptions(trimForExclusions: false, ignoreCase: options.ignoreCase));
  final List<List<SegmentMatcher>> exceptionSegments = exceptions
      .map((String e) =>
          parseSegmentMatchers(e, options!.ignoreCase ?? false))
      .toList();
  final Set<String> skippedFolders =
      getFoldersSkippedByExcludeExceptions(exceptions).toSet();

  List<String> toSegments(String path) {
    final String trimmed = rtrim(rtrim(path, GLOB_SPLIT), '\\');
    return trimmed.isEmpty ? <String>[] : trimmed.split(RegExp(r'[/\\]'));
  }

  bool isInSkippedFolder(List<String> segments) =>
      segments.any((String s) => skippedFolders.contains(s));

  bool isExcepted(String path, [String? basename]) =>
      _truthy(matchesException(path, basename)) &&
      !isInSkippedFolder(toSegments(path));

  final ParsedGlobFn matches = ParsedGlobFn((path, basename, hasSibling) {
    final Object? result = matchesExclude(path, basename, hasSibling);
    if (result is Future<String?>) {
      return result.then<String?>((String? pattern) =>
          pattern != null && !isExcepted(path, basename) ? pattern : null);
    }
    return result != null && !isExcepted(path, basename) ? result : null;
  });

  return ParsedExcludeExpression(
    matches: matches,
    matchesExclude: matchesExclude,
    exceptions: exceptions,
    isExcepted: isExcepted,
    couldExceptionMatchBeneath: (String folderPath) {
      final List<String> segments = toSegments(folderPath);
      return !isInSkippedFolder(segments) &&
          exceptionSegments.any(
              (List<SegmentMatcher> matchers) =>
                  couldMatchBeneath(matchers, segments));
    },
  );
}

/// 1:1: `export interface IExcludeTreeEntry`
class IExcludeTreeEntry {
  final String path;
  final String? basename;
  final bool isDirectory;
  final bool isParentExcluded;
  final bool Function()? isHidden;
  final HasSiblingFn? hasSibling;
  IExcludeTreeEntry({
    required this.path,
    this.basename,
    required this.isDirectory,
    required this.isParentExcluded,
    this.isHidden,
    this.hasSibling,
  });
}

/// 1:1: result of `evaluateExcludeTreeEntry`
class ExcludeTreeEntryResult {
  final bool isExcluded;
  final bool isVisited;
  ExcludeTreeEntryResult({required this.isExcluded, required this.isVisited});
}

/// 1:1: `export function evaluateExcludeTreeEntry`
ExcludeTreeEntryResult evaluateExcludeTreeEntry(
    IExcludeTreeEvaluator evaluator, IExcludeTreeEntry entry) {
  final bool isMatched = entry.isParentExcluded ||
      _truthy(evaluator.matchesExcludeFn(
          entry.path, entry.basename, entry.hasSibling)) ||
      (entry.isHidden?.call() ?? false);
  final bool isExcluded =
      isMatched && !evaluator.isExcepted(entry.path, entry.basename);
  return ExcludeTreeEntryResult(
    isExcluded: isExcluded,
    isVisited: !isExcluded ||
        (entry.isDirectory &&
            evaluator.couldExceptionMatchBeneath(entry.path)),
  );
}

/// 1:1: `type SegmentMatcher = typeof GLOBSTAR | ((segment: string) => boolean)`
typedef SegmentMatcher = Object;

/// 1:1: `parseSegmentMatchers`
List<SegmentMatcher> parseSegmentMatchers(String pattern, bool ignoreCase) {
  return splitGlobAware(pattern, GLOB_SPLIT).map((String segment) {
    if (segment == GLOBSTAR) {
      return GLOBSTAR;
    }
    if (segment.contains(GLOB_SPLIT) || hasGlobstarAlternative(segment)) {
      return GLOBSTAR;
    }
    try {
      final RegExp regExp = RegExp('^${parseRegExp(segment)}\$',
          caseSensitive: !ignoreCase);
      return (String value) => regExp.hasMatch(value);
    } catch (_) {
      return (String value) => false;
    }
  }).toList();
}

/// 1:1: `hasGlobstarAlternative`
bool hasGlobstarAlternative(String segment) {
  for (final RegExpMatch match
      in RegExp(r'\{(?<alternatives>[^}]*)\}').allMatches(segment)) {
    if (splitGlobAware(match.namedGroup('alternatives') ?? '', ',')
        .contains(GLOBSTAR)) {
      return true;
    }
  }
  return false;
}

/// 1:1: `couldMatchBeneath`
bool couldMatchBeneath(
    List<SegmentMatcher> matchers, List<String> folderSegments) {
  final Set<int> visited = <int>{};
  bool visit(int matcherIndex, int folderIndex) {
    if (folderIndex == folderSegments.length) {
      return true;
    }
    if (matcherIndex == matchers.length) {
      return false;
    }
    final int key = matcherIndex * (folderSegments.length + 1) + folderIndex;
    if (visited.contains(key)) {
      return false;
    }
    visited.add(key);
    final SegmentMatcher matcher = matchers[matcherIndex];
    if (matcher is String && matcher == GLOBSTAR) {
      return visit(matcherIndex + 1, folderIndex) ||
          visit(matcherIndex, folderIndex + 1);
    }
    return (matcher as bool Function(String))(folderSegments[folderIndex]) &&
        visit(matcherIndex + 1, folderIndex + 1);
  }
  return visit(0, 0);
}
