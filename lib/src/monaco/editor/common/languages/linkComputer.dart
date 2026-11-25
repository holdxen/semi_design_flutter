// ---------------------------------------------------------------------------
// Port of vscode/src/vs/editor/common/languages/linkComputer.ts
// Translated 1:1 from TypeScript. `const enum State/CharacterClass` -> class
// with static const int; `Uint8Array` -> dart:typed_data Uint8List;
// JS `charCodeAt` -> `codeUnitAt` (loop indices are always in bounds);
// `ILink`/`ILinkComputerTarget` (erased interfaces) -> lightweight carriers.
// ---------------------------------------------------------------------------

import 'dart:typed_data';

import '../../../base/common/charCode.dart';
import '../../../base/common/uint.dart';
import '../core/characterClassifier.dart';
import '../core/range.dart';

/// 1:1: `export interface ILinkComputerTarget`.
abstract class ILinkComputerTarget {
  int getLineCount();
  String getLineContent(int lineNumber);
}

/// 1:1: `interface ILink { range: IRange; url?: URI | string; tooltip?: string }`.
/// Erased in the Dart port; linkComputer only produces range + string url.
class ILink {
  final Range range;
  final String url;
  ILink(this.range, this.url);
}

/// 1:1: `export const enum State` (const enum -> static const class).
class State {
  const State._();
  static const int Invalid = 0;
  static const int Start = 1;
  static const int H = 2;
  static const int HT = 3;
  static const int HTT = 4;
  static const int HTTP = 5;
  static const int F = 6;
  static const int FI = 7;
  static const int FIL = 8;
  static const int BeforeColon = 9;
  static const int AfterColon = 10;
  static const int AlmostThere = 11;
  static const int End = 12;
  static const int Accept = 13;
  static const int LastKnownState = 14;
}

/// 1:1: `export type Edge = [State, number, State]` (tuple -> short carrier).
class Edge {
  final int from;
  final int chCode;
  final int to;
  const Edge(this.from, this.chCode, this.to);
}

/// 1:1: `class Uint8Matrix`.
class Uint8Matrix {
  late final Uint8List _data;
  final int rows;
  final int cols;

  Uint8Matrix(int rows, int cols, int defaultValue)
      : rows = rows,
        cols = cols {
    this._data = Uint8List(rows * cols);
    this._data.fillRange(0, rows * cols, toUint8(defaultValue));
  }

  int get(int row, int col) => this._data[row * this.cols + col];

  void set(int row, int col, int value) {
    this._data[row * this.cols + col] = toUint8(value);
  }
}

/// 1:1: `export class StateMachine`.
class StateMachine {
  late final Uint8Matrix _states;
  late final int _maxCharCode;

  StateMachine(List<Edge> edges) {
    int maxCharCode = 0;
    int maxState = State.Invalid;
    for (final edge in edges) {
      if (edge.chCode > maxCharCode) {
        maxCharCode = edge.chCode;
      }
      if (edge.from > maxState) {
        maxState = edge.from;
      }
      if (edge.to > maxState) {
        maxState = edge.to;
      }
    }

    maxCharCode++;
    maxState++;

    final states = Uint8Matrix(maxState, maxCharCode, State.Invalid);
    for (final edge in edges) {
      states.set(edge.from, edge.chCode, edge.to);
    }

    this._states = states;
    this._maxCharCode = maxCharCode;
  }

  int nextState(int currentState, int chCode) {
    if (chCode < 0 || chCode >= this._maxCharCode) {
      return State.Invalid;
    }
    return this._states.get(currentState, chCode);
  }
}

/// 1:1: `getStateMachine()` — lazy singleton, cached for the process lifetime.
late final StateMachine _stateMachine = _createDefaultStateMachine();

StateMachine getStateMachine() => _stateMachine;

StateMachine _createDefaultStateMachine() {
  return StateMachine([
    Edge(State.Start, CharCode.h, State.H),
    Edge(State.Start, CharCode.H, State.H),
    Edge(State.Start, CharCode.f, State.F),
    Edge(State.Start, CharCode.F, State.F),

    Edge(State.H, CharCode.t, State.HT),
    Edge(State.H, CharCode.T, State.HT),

    Edge(State.HT, CharCode.t, State.HTT),
    Edge(State.HT, CharCode.T, State.HTT),

    Edge(State.HTT, CharCode.p, State.HTTP),
    Edge(State.HTT, CharCode.P, State.HTTP),

    Edge(State.HTTP, CharCode.s, State.BeforeColon),
    Edge(State.HTTP, CharCode.S, State.BeforeColon),
    Edge(State.HTTP, CharCode.Colon, State.AfterColon),

    Edge(State.F, CharCode.i, State.FI),
    Edge(State.F, CharCode.I, State.FI),

    Edge(State.FI, CharCode.l, State.FIL),
    Edge(State.FI, CharCode.L, State.FIL),

    Edge(State.FIL, CharCode.e, State.BeforeColon),
    Edge(State.FIL, CharCode.E, State.BeforeColon),

    Edge(State.BeforeColon, CharCode.Colon, State.AfterColon),

    Edge(State.AfterColon, CharCode.Slash, State.AlmostThere),

    Edge(State.AlmostThere, CharCode.Slash, State.End),
  ]);
}

/// 1:1: `const enum CharacterClass`.
class CharacterClass {
  const CharacterClass._();
  static const int None = 0;
  static const int ForceTermination = 1;
  static const int CannotEndIn = 2;
}

/// 1:1: `getClassifier()` — lazy singleton.
late final CharacterClassifier<int> _classifier = _createClassifier();

CharacterClassifier<int> getClassifier() => _classifier;

CharacterClassifier<int> _createClassifier() {
  final classifier = CharacterClassifier<int>(CharacterClass.None);

  // allow-any-unicode-next-line
  const forceTerminationCharacters = " \t<>'\"、。｡､，．：；‘〈「『〔（［｛｢｣｝］）〕』」〉’｀～…|";
  for (int i = 0; i < forceTerminationCharacters.length; i++) {
    classifier.set(forceTerminationCharacters.codeUnitAt(i), CharacterClass.ForceTermination);
  }

  const cannotEndWithCharacters = '.,;:';
  for (int i = 0; i < cannotEndWithCharacters.length; i++) {
    classifier.set(cannotEndWithCharacters.codeUnitAt(i), CharacterClass.CannotEndIn);
  }
  return classifier;
}

/// 1:1: `export class LinkComputer`.
class LinkComputer {
  /// 1:1: `private static _createLink(...)`.
  static ILink _createLink(
    CharacterClassifier<int> classifier,
    String line,
    int lineNumber,
    int linkBeginIndex,
    int linkEndIndex,
  ) {
    // Do not allow to end link in certain characters...
    int lastIncludedCharIndex = linkEndIndex - 1;
    do {
      final int chCode = line.codeUnitAt(lastIncludedCharIndex);
      final int chClass = classifier.get(chCode);
      if (chClass != CharacterClass.CannotEndIn) {
        break;
      }
      lastIncludedCharIndex--;
    } while (lastIncludedCharIndex > linkBeginIndex);

    // Handle links enclosed in parens, square brackets and curlys.
    if (linkBeginIndex > 0) {
      final int charCodeBeforeLink = line.codeUnitAt(linkBeginIndex - 1);
      final int lastCharCodeInLink = line.codeUnitAt(lastIncludedCharIndex);

      if ((charCodeBeforeLink == CharCode.OpenParen && lastCharCodeInLink == CharCode.CloseParen) ||
          (charCodeBeforeLink == CharCode.OpenSquareBracket && lastCharCodeInLink == CharCode.CloseSquareBracket) ||
          (charCodeBeforeLink == CharCode.OpenCurlyBrace && lastCharCodeInLink == CharCode.CloseCurlyBrace)) {
        // Do not end in ) if ( is before the link start
        // Do not end in ] if [ is before the link start
        // Do not end in } if { is before the link start
        lastIncludedCharIndex--;
      }
    }

    return ILink(
      Range(
        lineNumber,
        linkBeginIndex + 1,
        lineNumber,
        lastIncludedCharIndex + 2,
      ),
      line.substring(linkBeginIndex, lastIncludedCharIndex + 1),
    );
  }

  /// 1:1: `public static computeLinks(model, stateMachine = getStateMachine())`.
  static List<ILink> computeLinks(
    ILinkComputerTarget model, [
    StateMachine? stateMachine,
  ]) {
    final sm = stateMachine ?? getStateMachine();
    final classifier = getClassifier();

    final result = <ILink>[];
    for (int i = 1, lineCount = model.getLineCount(); i <= lineCount; i++) {
      final String line = model.getLineContent(i);
      final int len = line.length;

      int j = 0;
      int linkBeginIndex = 0;
      int linkBeginChCode = 0;
      int state = State.Start;
      bool hasOpenParens = false;
      bool hasOpenSquareBracket = false;
      bool inSquareBrackets = false;
      bool hasOpenCurlyBracket = false;

      while (j < len) {
        bool resetStateMachine = false;
        final int chCode = line.codeUnitAt(j);

        if (state == State.Accept) {
          int chClass;
          switch (chCode) {
            case CharCode.OpenParen:
              hasOpenParens = true;
              chClass = CharacterClass.None;
              break;
            case CharCode.CloseParen:
              chClass = (hasOpenParens ? CharacterClass.None : CharacterClass.ForceTermination);
              break;
            case CharCode.OpenSquareBracket:
              inSquareBrackets = true;
              hasOpenSquareBracket = true;
              chClass = CharacterClass.None;
              break;
            case CharCode.CloseSquareBracket:
              inSquareBrackets = false;
              chClass = (hasOpenSquareBracket ? CharacterClass.None : CharacterClass.ForceTermination);
              break;
            case CharCode.OpenCurlyBrace:
              hasOpenCurlyBracket = true;
              chClass = CharacterClass.None;
              break;
            case CharCode.CloseCurlyBrace:
              chClass = (hasOpenCurlyBracket ? CharacterClass.None : CharacterClass.ForceTermination);
              break;

            // The following three rules make it that ' or " or ` are allowed
            // inside links only if the link is wrapped by some other quote character
            case CharCode.SingleQuote:
            case CharCode.DoubleQuote:
            case CharCode.BackTick:
              if (linkBeginChCode == chCode) {
                chClass = CharacterClass.ForceTermination;
              } else if (linkBeginChCode == CharCode.SingleQuote ||
                  linkBeginChCode == CharCode.DoubleQuote ||
                  linkBeginChCode == CharCode.BackTick) {
                chClass = CharacterClass.None;
              } else {
                chClass = CharacterClass.ForceTermination;
              }
              break;
            case CharCode.Asterisk:
              // `*` terminates a link if the link began with `*`
              chClass = (linkBeginChCode == CharCode.Asterisk) ? CharacterClass.ForceTermination : CharacterClass.None;
              break;
            case CharCode.Space:
              // ` ` allow space in between [ and ]
              chClass = (inSquareBrackets ? CharacterClass.None : CharacterClass.ForceTermination);
              break;
            default:
              chClass = classifier.get(chCode);
          }

          // Check if character terminates link
          if (chClass == CharacterClass.ForceTermination) {
            result.add(_createLink(classifier, line, i, linkBeginIndex, j));
            resetStateMachine = true;
          }
        } else if (state == State.End) {
          int chClass;
          if (chCode == CharCode.OpenSquareBracket) {
            // Allow for the authority part to contain ipv6 addresses which contain [ and ]
            hasOpenSquareBracket = true;
            chClass = CharacterClass.None;
          } else {
            chClass = classifier.get(chCode);
          }

          // Check if character terminates link
          if (chClass == CharacterClass.ForceTermination) {
            resetStateMachine = true;
          } else {
            state = State.Accept;
          }
        } else {
          state = sm.nextState(state, chCode);
          if (state == State.Invalid) {
            resetStateMachine = true;
          }
        }

        if (resetStateMachine) {
          state = State.Start;
          hasOpenParens = false;
          hasOpenSquareBracket = false;
          hasOpenCurlyBracket = false;

          // Record where the link started
          linkBeginIndex = j + 1;
          linkBeginChCode = chCode;
        }

        j++;
      }

      if (state == State.Accept) {
        result.add(_createLink(classifier, line, i, linkBeginIndex, len));
      }
    }

    return result;
  }
}

/// 1:1: `export function computeLinks(model: ILinkComputerTarget | null)`.
/// The TS guard also rejects unknown callers lacking the target methods
/// (`typeof model.getLineCount !== 'function' || ...`). Dart's `is` check on
/// the erased interface mirrors that runtime guard.
List<ILink> computeLinks(Object? model) {
  if (model == null || model is! ILinkComputerTarget) {
    return [];
  }
  return LinkComputer.computeLinks(model);
}
