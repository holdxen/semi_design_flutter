// ---------------------------------------------------------------------------
// Port of vscode/src/vs/editor/common/languages/languageConfiguration.ts
// @bfbf12b35b9978b92b2d341e81ade49f2b18c68c (430 lines)
// Translated 1:1 from TypeScript.
//
// Adaptations:
//   - TypeScript interfaces become plain classes with nullable fields (the port
//     convention); `wordPattern`/`beforeText`/... keep `RegExp` objects.
//   - `CharacterPair = [string, string]` -> `List<String>` typedef.
//   - `OrUndefined<Required<LanguageConfiguration>>` mapped type ->
//     `ExplicitLanguageConfiguration` carrier with the same nullable fields.
//   - `IndentAction` enum (numeric) -> int constants, matching the repo's enum
//     convention (`StandardTokenType`, `PartFingerprint`, ...).
//   - `String.fromCharCode` -> `String.fromCharCode`; `String.includes` ->
//     `String.contains`.
// ---------------------------------------------------------------------------

import '../../../base/common/charCode.dart' show CharCode;
import '../encodedTokenAttributes.dart' show StandardTokenType;
import 'supports.dart' show ScopedLineTokens;

/// 1:1: `export type CharacterPair = [string, string]`
typedef CharacterPair = List<String>;

/// 1:1: `export interface LineCommentConfig`
class LineCommentConfig {
  LineCommentConfig(this.comment, {this.noIndent});

  final String comment;
  final bool? noIndent;
}

/// 1:1: `export interface CommentRule`
class CommentRule {
  CommentRule({this.lineComment, this.blockComment});

  /// `string | LineCommentConfig | null`
  final Object? lineComment;
  final List<String>? blockComment;
}

/// 1:1: `export interface LanguageConfiguration`
class LanguageConfiguration {
  LanguageConfiguration({
    this.comments,
    this.brackets,
    this.wordPattern,
    this.indentationRules,
    this.onEnterRules,
    this.autoClosingPairs,
    this.surroundingPairs,
    this.colorizedBracketPairs,
    this.autoCloseBefore,
    this.folding,
    this.electricCharacterSupport,
  });

  final CommentRule? comments;
  final List<List<String>>? brackets;
  final RegExp? wordPattern;
  final IndentationRule? indentationRules;
  final List<OnEnterRule>? onEnterRules;
  final List<IAutoClosingPairConditional>? autoClosingPairs;
  final List<IAutoClosingPair>? surroundingPairs;
  final List<List<String>>? colorizedBracketPairs;
  final String? autoCloseBefore;
  final FoldingRules? folding;

  /// 1:1: `__electricCharacterSupport` (leading underscores are not legal for
  /// Dart named parameters).
  final IElectricCharacterSupport? electricCharacterSupport;
}

/// 1:1: `{ docComment?: IDocComment }` (inline shape of the deprecated field).
class IElectricCharacterSupport {
  IElectricCharacterSupport({this.docComment});

  final IDocComment? docComment;
}

/// 1:1: `export type ExplicitLanguageConfiguration = OrUndefined<...>`
/// Carrier with the same optional surface as [LanguageConfiguration].
class ExplicitLanguageConfiguration {
  ExplicitLanguageConfiguration({
    this.comments,
    this.brackets,
    this.wordPattern,
    this.indentationRules,
    this.onEnterRules,
    this.autoClosingPairs,
    this.surroundingPairs,
    this.colorizedBracketPairs,
    this.autoCloseBefore,
    this.folding,
    this.electricCharacterSupport,
  });

  final CommentRule? comments;
  final List<List<String>>? brackets;
  final RegExp? wordPattern;
  final IndentationRule? indentationRules;
  final List<OnEnterRule>? onEnterRules;
  final List<IAutoClosingPairConditional>? autoClosingPairs;
  final List<IAutoClosingPair>? surroundingPairs;
  final List<List<String>>? colorizedBracketPairs;
  final String? autoCloseBefore;
  final FoldingRules? folding;

  /// 1:1: `__electricCharacterSupport` (leading underscores are not legal for
  /// Dart named parameters).
  final IElectricCharacterSupport? electricCharacterSupport;
}

/// 1:1: `export interface IndentationRule`
class IndentationRule {
  IndentationRule({
    required this.decreaseIndentPattern,
    required this.increaseIndentPattern,
    this.indentNextLinePattern,
    this.unIndentedLinePattern,
  });

  final RegExp decreaseIndentPattern;
  final RegExp increaseIndentPattern;
  final RegExp? indentNextLinePattern;
  final RegExp? unIndentedLinePattern;
}

/// 1:1: `export interface FoldingMarkers`
class FoldingMarkers {
  FoldingMarkers({required this.start, required this.end});

  final RegExp start;
  final RegExp end;
}

/// 1:1: `export interface FoldingRules`
class FoldingRules {
  FoldingRules({this.offSide, this.markers});

  final bool? offSide;
  final FoldingMarkers? markers;
}

/// 1:1: `export interface OnEnterRule`
class OnEnterRule {
  OnEnterRule({
    required this.beforeText,
    this.afterText,
    this.previousLineText,
    required this.action,
  });

  final RegExp beforeText;
  final RegExp? afterText;
  final RegExp? previousLineText;
  final EnterAction action;
}

/// 1:1: `export interface IDocComment`
class IDocComment {
  IDocComment({required this.open, this.close});

  final String open;
  final String? close;
}

/// 1:1: `export interface IAutoClosingPair`
class IAutoClosingPair {
  IAutoClosingPair({required this.open, required this.close});

  final String open;
  final String close;
}

/// 1:1: `export interface IAutoClosingPairConditional extends IAutoClosingPair`
class IAutoClosingPairConditional extends IAutoClosingPair {
  IAutoClosingPairConditional({
    required super.open,
    required super.close,
    this.notIn,
    this.beforeText,
  });

  final List<String>? notIn;
  final RegExp? beforeText;
}

/// 1:1: `export enum IndentAction`
class IndentAction {
  static const int None = 0;
  static const int Indent = 1;
  static const int IndentOutdent = 2;
  static const int Outdent = 3;

  const IndentAction._();
}

/// 1:1: `export interface EnterAction`
class EnterAction {
  EnterAction({required this.indentAction, this.appendText, this.removeText});

  final int indentAction;
  final String? appendText;
  final int? removeText;
}

/// 1:1: `export interface CompleteEnterAction`
class CompleteEnterAction {
  CompleteEnterAction({
    required this.indentAction,
    required this.appendText,
    required this.removeText,
    required this.indentation,
  });

  final int indentAction;
  final String appendText;
  final int removeText;
  final String indentation;
}

/// 1:1: `export class StandardAutoClosingPairConditional`
class StandardAutoClosingPairConditional {
  StandardAutoClosingPairConditional(IAutoClosingPairConditional source)
    : open = source.open,
      close = source.close,
      beforeText = source.beforeText {
    final List<String>? notIn = source.notIn;
    if (notIn is List<String>) {
      for (int i = 0, len = notIn.length; i < len; i++) {
        final String notInValue = notIn[i];
        switch (notInValue) {
          case 'string':
            _inString = false;
            break;
          case 'comment':
            _inComment = false;
            break;
          case 'regex':
            _inRegEx = false;
            break;
        }
      }
    }
  }

  final String open;
  final String close;
  final RegExp? beforeText;

  // initially allowed in all tokens
  bool _inString = true;
  bool _inComment = true;
  bool _inRegEx = true;

  String? _neutralCharacter;
  bool _neutralCharacterSearched = false;

  /// 1:1: `public shouldAutoCloseBefore(text: string): boolean`
  bool shouldAutoCloseBefore(String text) {
    if (beforeText == null) {
      return true;
    }
    // JS resets `lastIndex = 0` for global regexes; Dart `hasMatch` does not
    // carry state, so no reset is required.
    return beforeText!.hasMatch(text);
  }

  /// 1:1: `public isOK(standardToken: StandardTokenType): boolean`
  bool isOK(int standardToken) {
    switch (standardToken) {
      case StandardTokenType.other:
        return true;
      case StandardTokenType.comment:
        return _inComment;
      case StandardTokenType.string:
        return _inString;
      case StandardTokenType.regEx:
        return _inRegEx;
    }
    // Unreachable for the four known token types (JS would fall through).
    return false;
  }

  /// 1:1: `public shouldAutoClose(context: ScopedLineTokens, column: number)`
  bool shouldAutoClose(ScopedLineTokens context, int column) {
    // Always complete on empty line
    if (context.getTokenCount() == 0) {
      return true;
    }

    final int tokenIndex = context.findTokenIndexAtOffset(column - 2);
    final int standardTokenType = context.getStandardTokenType(tokenIndex);
    return isOK(standardTokenType);
  }

  String? _findNeutralCharacterInRange(int fromCharCode, int toCharCode) {
    for (int charCode = fromCharCode; charCode <= toCharCode; charCode++) {
      final String character = String.fromCharCode(charCode);
      if (!open.contains(character) && !close.contains(character)) {
        return character;
      }
    }
    return null;
  }

  /// 1:1: `public findNeutralCharacter(): string | null`
  String? findNeutralCharacter() {
    if (!_neutralCharacterSearched) {
      _neutralCharacterSearched = true;
      if (_neutralCharacter == null) {
        _neutralCharacter = _findNeutralCharacterInRange(
          CharCode.Digit0,
          CharCode.Digit9,
        );
      }
      if (_neutralCharacter == null) {
        _neutralCharacter = _findNeutralCharacterInRange(
          CharCode.a,
          CharCode.z,
        );
      }
      if (_neutralCharacter == null) {
        _neutralCharacter = _findNeutralCharacterInRange(
          CharCode.A,
          CharCode.Z,
        );
      }
    }
    return _neutralCharacter;
  }
}

/// 1:1: `export class AutoClosingPairs`
class AutoClosingPairs {
  AutoClosingPairs(List<StandardAutoClosingPairConditional> autoClosingPairs)
    : autoClosingPairsOpenByStart =
          <String, List<StandardAutoClosingPairConditional>>{},
      autoClosingPairsOpenByEnd =
          <String, List<StandardAutoClosingPairConditional>>{},
      autoClosingPairsCloseByStart =
          <String, List<StandardAutoClosingPairConditional>>{},
      autoClosingPairsCloseByEnd =
          <String, List<StandardAutoClosingPairConditional>>{},
      autoClosingPairsCloseSingleChar =
          <String, List<StandardAutoClosingPairConditional>>{} {
    for (final StandardAutoClosingPairConditional pair in autoClosingPairs) {
      // JS `charAt` returns one UTF-16 code unit -> `substring(0, 1)`.
      appendEntry(autoClosingPairsOpenByStart, pair.open.substring(0, 1), pair);
      appendEntry(
        autoClosingPairsOpenByEnd,
        pair.open.substring(pair.open.length - 1),
        pair,
      );
      appendEntry(
        autoClosingPairsCloseByStart,
        pair.close.substring(0, 1),
        pair,
      );
      appendEntry(
        autoClosingPairsCloseByEnd,
        pair.close.substring(pair.close.length - 1),
        pair,
      );
      if (pair.close.length == 1 && pair.open.length == 1) {
        appendEntry(autoClosingPairsCloseSingleChar, pair.close, pair);
      }
    }
  }

  /// Key is first character of open
  final Map<String, List<StandardAutoClosingPairConditional>>
  autoClosingPairsOpenByStart;

  /// Key is last character of open
  final Map<String, List<StandardAutoClosingPairConditional>>
  autoClosingPairsOpenByEnd;

  /// Key is first character of close
  final Map<String, List<StandardAutoClosingPairConditional>>
  autoClosingPairsCloseByStart;

  /// Key is last character of close
  final Map<String, List<StandardAutoClosingPairConditional>>
  autoClosingPairsCloseByEnd;

  /// Key is close. Only has pairs that are a single character
  final Map<String, List<StandardAutoClosingPairConditional>>
  autoClosingPairsCloseSingleChar;
}

/// 1:1: `function appendEntry<K, V>(target, key, value): void`
void appendEntry<K, V>(Map<K, List<V>> target, K key, V value) {
  final List<V>? existing = target[key];
  if (existing != null) {
    existing.add(value);
  } else {
    target[key] = <V>[value];
  }
}
