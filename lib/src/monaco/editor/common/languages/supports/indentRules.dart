// 1:1 port of vscode/src/vs/editor/common/languages/supports/indentRules.ts
// Adaptations:
//   - `const enum IndentConsts` -> int constants (repo enum convention).
//   - `resetGlobalRegex` has no effect in Dart: `RegExp.hasMatch` is stateless
//     (no `lastIndex`), so the call is represented as a constant `true`.
// Runtime truth: tool/ts2dart/_batch338_truth.cjs.

import '../languageConfiguration.dart' show IndentationRule;

/// 1:1: `export const enum IndentConsts`.
class IndentConsts {
  const IndentConsts._();

  static const int INCREASE_MASK = 1;
  static const int DECREASE_MASK = 2;
  static const int INDENT_NEXTLINE_MASK = 4;
  static const int UNINDENT_MASK = 8;
}

/// 1:1: `function resetGlobalRegex(reg: RegExp)`.
///
/// Dart's [RegExp.hasMatch] does not keep a `lastIndex`, so no reset is needed.
bool resetGlobalRegex(RegExp reg) => true;

/// 1:1: `export class IndentRulesSupport`.
class IndentRulesSupport {
  final IndentationRule _indentationRules;

  IndentRulesSupport(this._indentationRules);

  /// 1:1: `public shouldIncrease(text: string): boolean`.
  bool shouldIncrease(String text) {
    final RegExp increase = _indentationRules.increaseIndentPattern;
    if (resetGlobalRegex(increase) && increase.hasMatch(text)) {
      return true;
    }
    return false;
  }

  /// 1:1: `public shouldDecrease(text: string): boolean`.
  bool shouldDecrease(String text) {
    final RegExp decrease = _indentationRules.decreaseIndentPattern;
    if (resetGlobalRegex(decrease) && decrease.hasMatch(text)) {
      return true;
    }
    return false;
  }

  /// 1:1: `public shouldIndentNextLine(text: string): boolean`.
  bool shouldIndentNextLine(String text) {
    final RegExp? indentNextLine = _indentationRules.indentNextLinePattern;
    if (indentNextLine != null &&
        resetGlobalRegex(indentNextLine) &&
        indentNextLine.hasMatch(text)) {
      return true;
    }
    return false;
  }

  /// 1:1: `public shouldIgnore(text: string): boolean`.
  bool shouldIgnore(String text) {
    final RegExp? unIndented = _indentationRules.unIndentedLinePattern;
    if (unIndented != null && resetGlobalRegex(unIndented) && unIndented.hasMatch(text)) {
      return true;
    }
    return false;
  }

  /// 1:1: `public getIndentMetadata(text: string): number`.
  int getIndentMetadata(String text) {
    int ret = 0;
    if (shouldIncrease(text)) {
      ret += IndentConsts.INCREASE_MASK;
    }
    if (shouldDecrease(text)) {
      ret += IndentConsts.DECREASE_MASK;
    }
    if (shouldIndentNextLine(text)) {
      ret += IndentConsts.INDENT_NEXTLINE_MASK;
    }
    if (shouldIgnore(text)) {
      ret += IndentConsts.UNINDENT_MASK;
    }
    return ret;
  }
}
