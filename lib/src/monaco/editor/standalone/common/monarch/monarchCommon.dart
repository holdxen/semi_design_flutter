// 1:1 port of vs/editor/standalone/common/monarch/monarchCommon.ts

import '../../../../base/common/strings.dart' show escapeRegExpCharacters;

/// 1:1: `export const enum MonarchBracket`
class MonarchBracket {
  static const int None = 0;
  static const int Open = 1;
  static const int Close = -1;
}

/// 1:1: `export interface ILexerMin`
/// The source's index signature `[attr: string]: any` is carried by [attrs].
abstract class ILexerMin {
  String get languageId;
  bool get includeLF;
  bool get noThrow;
  bool get ignoreCase;
  bool get unicode;
  bool get usesEmbedded;
  String get defaultToken;
  Map<String, Object?> get stateNames;
  Map<String, Object?> get attrs;
}

/// 1:1: `export interface ILexer`
abstract class ILexer implements ILexerMin {
  int get maxStack;
  String? get start;
  String get tokenPostfix;
  Map<String, List<IRule>> get tokenizer;
  List<IBracket> get brackets;
}

/// 1:1: `export interface IBracket`
abstract class IBracket {
  String get token;
  String get open;
  String get close;
}

/// 1:1: `export type FuzzyAction = IAction | String`
typedef FuzzyAction = Object?; // IAction or String

/// 1:1: `export function isFuzzyActionArr(what): what is FuzzyAction[]`
bool isFuzzyActionArr(Object? what) => what is List;

/// 1:1: `export function isFuzzyAction(what): what is FuzzyAction`
bool isFuzzyAction(Object? what) => !isFuzzyActionArr(what);

/// 1:1: `export function isString(what): what is string`
bool isFuzzyActionString(Object? what) => what is String;

/// 1:1: `export function isIAction(what): what is IAction`
bool isIAction(Object? what) => !isFuzzyActionString(what);

/// 1:1: `export interface IRule`
abstract class IRule {
  FuzzyAction get action;
  bool get matchOnlyAtLineStart;
  String get name;
  Object resolveRegex(String state);
}

/// 1:1: `export interface IAction`
abstract class IAction {
  List<FuzzyAction>? get group;
  bool get hasEmbeddedEndInCases;
  Object? Function(String id, List<String> matches, String state, bool eos)?
      get test;
  String? get token;
  bool get tokenSubst;
  String? get next;
  String? get nextEmbedded;
  int? get bracket;
  String? get log;
  String? get switchTo;
  int? get goBack;
  List<String>? Function(List<String> states)? get transform;
}

/// 1:1: `export interface IBranch`
abstract class IBranch {
  String get name;
  FuzzyAction get value;
  bool Function(String id, List<String> matches, String state, bool eos)?
      get test;
}

/// 1:1: `export function empty(s): boolean` — JS truthiness of a string.
bool empty(String s) => s.isEmpty ? true : false;

/// 1:1: `export function fixCase(lexer, str): string`
String fixCase(ILexerMin lexer, String str) =>
    (lexer.ignoreCase && str.isNotEmpty) ? str.toLowerCase() : str;

/// 1:1: `export function sanitize(s)`
String sanitize(String s) => s.replaceAll(RegExp("[&<>'\"_]"), '-');

/// 1:1: `export function log(lexer, msg)` — console.log bridge.
void monarchLog(ILexerMin lexer, String msg) {
  // The source logs to console; the embedder observes diagnostics here.
  // ignore: avoid_print
  print('${lexer.languageId}: $msg');
}

/// 1:1: `export function createError(lexer, msg): Error`
StateError createMonarchError(ILexerMin lexer, String msg) =>
    StateError('${lexer.languageId}: $msg');

/// 1:1: `export function substituteMatches(lexer, str, id, matches, state): string`
///
/// JS `/\$((\$)|(#)|(\d\d?)|[sS](\d\d?)|@(\w+))/g` with callback groups:
/// full=0, sub=1, dollar=2, hash=3, n=4, s=5, attr=6.
String substituteMatches(
  ILexerMin lexer,
  String str,
  String id,
  List<String> matches,
  String state,
) {
  final RegExp re = RegExp(r'\$((\$)|(#)|(\d\d?)|[sS](\d\d?)|@(\w+))');
  List<String>? stateMatches;
  return str.replaceAllMapped(re, (Match m) {
    final String? dollar = m.group(2);
    final String? hash = m.group(3);
    final String? n = m.group(4);
    final String? s = m.group(5);
    final String? attr = m.group(6);
    if (!empty(dollar ?? '')) {
      return '\$'; // $$
    }
    if (!empty(hash ?? '')) {
      return fixCase(lexer, id); // $#
    }
    if (!empty(n ?? '') && int.parse(n!) < matches.length) {
      return fixCase(lexer, matches[int.parse(n)]); // $n
    }
    if (!empty(attr ?? '') &&
        lexer.attrs[attr] is String) {
      return lexer.attrs[attr] as String; // @attribute
    }
    if (stateMatches == null) {
      stateMatches = state.split('.');
      stateMatches!.insert(0, state);
    }
    if (!empty(s ?? '') && int.parse(s!) < stateMatches!.length) {
      return fixCase(lexer, stateMatches![int.parse(s)]); // $Sn
    }
    return '';
  });
}

/// 1:1: `export function substituteMatchesRe(lexer, str, state): string`
String substituteMatchesRe(ILexerMin lexer, String str, String state) {
  final RegExp re = RegExp(r'\$[sS](\d\d?)');
  List<String>? stateMatches;
  return str.replaceAllMapped(re, (Match m) {
    final String s = m.group(1)!;
    if (stateMatches == null) {
      stateMatches = state.split('.');
      stateMatches!.insert(0, state);
    }
    if (!empty(s) && int.parse(s) < stateMatches!.length) {
      return escapeRegExpCharacters(fixCase(lexer, stateMatches![int.parse(s)]));
    }
    return '';
  });
}

/// 1:1: `export function findRules(lexer, inState): IRule[] | null`
List<IRule>? findRules(ILexer lexer, String inState) {
  String? state = inState;
  while (state != null && state.isNotEmpty) {
    final List<IRule>? rules = lexer.tokenizer[state];
    if (rules != null) {
      return rules;
    }
    final int idx = state.lastIndexOf('.');
    state = idx < 0 ? null : state.substring(0, idx);
  }
  return null;
}

/// 1:1: `export function stateExists(lexer, inState): boolean`
bool stateExists(ILexerMin lexer, String inState) {
  String? state = inState;
  while (state != null && state.isNotEmpty) {
    final Object? exist = lexer.stateNames[state];
    if (exist != null) {
      return true;
    }
    final int idx = state.lastIndexOf('.');
    state = idx < 0 ? null : state.substring(0, idx);
  }
  return false;
}
