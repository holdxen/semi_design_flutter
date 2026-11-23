/*---------------------------------------------------------------------------------------------
 *  Copyright (c) Microsoft Corporation. All rights reserved.
 *  Licensed under the MIT License. See License.txt in the project root for license information.
 *--------------------------------------------------------------------------------------------*/

// 1:1 翻译自 vscode/src/vs/editor/contrib/find/browser/replacePattern.ts

import '../../../../base/common/charCode.dart';
import '../../../../base/common/search.dart'
    show buildReplaceStringWithCasePreserved;

/// 1:1: `const enum ReplacePatternKind`
class ReplacePatternKind {
  static const int StaticValue = 0;
  static const int DynamicPieces = 1;
}

/// 1:1: `class StaticValueReplacePattern`
class StaticValueReplacePattern {
  final int kind = ReplacePatternKind.StaticValue;
  final String staticValue;
  StaticValueReplacePattern(this.staticValue);
}

/// 1:1: `class DynamicPiecesReplacePattern`
class DynamicPiecesReplacePattern {
  final int kind = ReplacePatternKind.DynamicPieces;
  final List<ReplacePiece> pieces;
  DynamicPiecesReplacePattern(this.pieces);
}

/// 1:1: `export class ReplacePattern`
class ReplacePattern {
  /// 1:1: `static fromStaticValue`
  static ReplacePattern fromStaticValue(String value) =>
      ReplacePattern([ReplacePiece.staticValue(value)]);

  late final Object _state;

  bool get hasReplacementPatterns {
    final Object state = _state;
    return state is DynamicPiecesReplacePattern &&
        state.kind == ReplacePatternKind.DynamicPieces;
  }

  ReplacePattern(List<ReplacePiece>? pieces) {
    if (pieces == null || pieces.isEmpty) {
      _state = StaticValueReplacePattern('');
    } else if (pieces.length == 1 && pieces[0].staticValue != null) {
      _state = StaticValueReplacePattern(pieces[0].staticValue!);
    } else {
      _state = DynamicPiecesReplacePattern(pieces);
    }
  }

  /// 1:1: `buildReplaceString(matches, preserveCase?)`
  String buildReplaceString(List<String>? matches, [bool? preserveCase]) {
    final Object state = _state;
    if (state is StaticValueReplacePattern &&
        state.kind == ReplacePatternKind.StaticValue) {
      if (preserveCase == true) {
        return buildReplaceStringWithCasePreserved(matches, state.staticValue);
      } else {
        return state.staticValue;
      }
    }

    final DynamicPiecesReplacePattern dyn = state as DynamicPiecesReplacePattern;
    String result = '';
    for (int i = 0, len = dyn.pieces.length; i < len; i++) {
      final ReplacePiece piece = dyn.pieces[i];
      if (piece.staticValue != null) {
        // static value ReplacePiece
        result += piece.staticValue!;
        continue;
      }

      // match index ReplacePiece
      String match = ReplacePattern._substitute(piece.matchIndex, matches);
      final List<String>? caseOps = piece.caseOps;
      if (caseOps != null && caseOps.isNotEmpty) {
        final List<String> repl = <String>[];
        final int lenOps = caseOps.length;
        int opIdx = 0;
        for (int idx = 0, len = match.length; idx < len; idx++) {
          if (opIdx >= lenOps) {
            repl.add(match.substring(idx));
            break;
          }
          // 1:1: JS `match[idx]` is a single UTF-16 code unit
          final String ch = match[idx];
          switch (caseOps[opIdx]) {
            case 'U':
              repl.add(ch.toUpperCase());
              break;
            case 'u':
              repl.add(ch.toUpperCase());
              opIdx++;
              break;
            case 'L':
              repl.add(ch.toLowerCase());
              break;
            case 'l':
              repl.add(ch.toLowerCase());
              opIdx++;
              break;
            default:
              repl.add(ch);
          }
        }
        match = repl.join('');
      }
      result += match;
    }

    return result;
  }

  /// 1:1: `_substitute(matchIndex, matches)`
  static String _substitute(int matchIndex, List<String>? matches) {
    if (matches == null) {
      return '';
    }
    if (matchIndex == 0) {
      return matches[0];
    }

    String remainder = '';
    int idx = matchIndex;
    while (idx > 0) {
      if (idx < matches.length) {
        // A match can be undefined (JS `|| ''`)
        final String match = (matches[idx].isNotEmpty ? matches[idx] : '');
        return match + remainder;
      }
      remainder = (idx % 10).toString() + remainder;
      idx = (idx / 10).floor();
    }
    return r'$' + remainder;
  }
}

/// 1:1: `export class ReplacePiece`
class ReplacePiece {
  /// 1:1: `static staticValue(value)` — factory (Dart 不允许 static 方法与实例 getter 同名)
  factory ReplacePiece.staticValue(String value) => ReplacePiece._(value, -1, null);
  factory ReplacePiece.matchIndex(int index) => ReplacePiece._(null, index, null);
  factory ReplacePiece.caseOps(int index, List<String> caseOps) =>
      ReplacePiece._(null, index, caseOps);

  final String? staticValue;
  final int matchIndex;
  final List<String>? caseOps;

  ReplacePiece._(String? staticValue, int matchIndex, List<String>? caseOps)
      : staticValue = staticValue,
        matchIndex = matchIndex,
        caseOps = (caseOps == null || caseOps.isEmpty)
            ? null
            : List<String>.from(caseOps);
}

/// 1:1: `class ReplacePieceBuilder`
class ReplacePieceBuilder {
  final String _source;
  int _lastCharIndex = 0;
  final List<ReplacePiece> _result = <ReplacePiece>[];
  String _currentStaticPiece = '';

  ReplacePieceBuilder(this._source);

  void emitUnchanged(int toCharIndex) {
    _emitStatic(_source.substring(_lastCharIndex, toCharIndex));
    _lastCharIndex = toCharIndex;
  }

  void emitStatic(String value, int toCharIndex) {
    _emitStatic(value);
    _lastCharIndex = toCharIndex;
  }

  void _emitStatic(String value) {
    if (value.isEmpty) {
      return;
    }
    _currentStaticPiece += value;
  }

  void emitMatchIndex(int index, int toCharIndex, List<String> caseOps) {
    if (_currentStaticPiece.isNotEmpty) {
      _result.add(ReplacePiece.staticValue(_currentStaticPiece));
      _currentStaticPiece = '';
    }
    _result.add(ReplacePiece.caseOps(index, caseOps));
    _lastCharIndex = toCharIndex;
  }

  ReplacePattern finalize() {
    emitUnchanged(_source.length);
    if (_currentStaticPiece.isNotEmpty) {
      _result.add(ReplacePiece.staticValue(_currentStaticPiece));
      _currentStaticPiece = '';
    }
    return ReplacePattern(_result);
  }
}

/// 1:1: `export function parseReplaceString(replaceString)`
ReplacePattern parseReplaceString(String replaceString) {
  if (replaceString.isEmpty) {
    return ReplacePattern(null);
  }

  final List<String> caseOps = <String>[];
  final ReplacePieceBuilder result = ReplacePieceBuilder(replaceString);

  for (int i = 0, len = replaceString.length; i < len; i++) {
    final int chCode = replaceString.codeUnitAt(i);

    if (chCode == CharCode.Backslash) {
      // move to next char
      i++;
      if (i >= len) {
        // string ends with a \
        break;
      }
      final int nextChCode = replaceString.codeUnitAt(i);
      switch (nextChCode) {
        case CharCode.Backslash:
          // \\ => inserts a "\"
          result.emitUnchanged(i - 1);
          result.emitStatic('\\', i + 1);
          break;
        case CharCode.n:
          // \n => inserts a LF
          result.emitUnchanged(i - 1);
          result.emitStatic('\n', i + 1);
          break;
        case CharCode.t:
          // \t => inserts a TAB
          result.emitUnchanged(i - 1);
          result.emitStatic('\t', i + 1);
          break;
        case CharCode.u:
        // \u => upper-cases one character
        case CharCode.U:
        // \U => upper-cases ALL following characters
        case CharCode.l:
        // \l => lower-cases one character
        case CharCode.L:
          // \L => lower-cases ALL following characters
          result.emitUnchanged(i - 1);
          result.emitStatic('', i + 1);
          caseOps.add(String.fromCharCode(nextChCode));
          break;
      }
      continue;
    }

    if (chCode == CharCode.DollarSign) {
      // move to next char
      i++;
      if (i >= len) {
        // string ends with a $
        break;
      }
      final int nextChCode = replaceString.codeUnitAt(i);

      if (nextChCode == CharCode.DollarSign) {
        // $$ => inserts a "$"
        result.emitUnchanged(i - 1);
        result.emitStatic(r'$', i + 1);
        continue;
      }

      if (nextChCode == CharCode.Digit0 || nextChCode == CharCode.Ampersand) {
        // $& and $0 => inserts the matched substring
        result.emitUnchanged(i - 1);
        result.emitMatchIndex(0, i + 1, caseOps);
        caseOps.clear();
        continue;
      }

      if (CharCode.Digit1 <= nextChCode && nextChCode <= CharCode.Digit9) {
        // $n
        int matchIndex = nextChCode - CharCode.Digit0;

        // peek next char to probe for $nn
        if (i + 1 < len) {
          final int nextNextChCode = replaceString.codeUnitAt(i + 1);
          if (CharCode.Digit0 <= nextNextChCode &&
              nextNextChCode <= CharCode.Digit9) {
            // $nn
            i++;
            matchIndex = matchIndex * 10 + (nextNextChCode - CharCode.Digit0);

            result.emitUnchanged(i - 2);
            result.emitMatchIndex(matchIndex, i + 1, caseOps);
            caseOps.clear();
            continue;
          }
        }

        result.emitUnchanged(i - 1);
        result.emitMatchIndex(matchIndex, i + 1, caseOps);
        caseOps.clear();
        continue;
      }
    }
  }

  return result.finalize();
}
