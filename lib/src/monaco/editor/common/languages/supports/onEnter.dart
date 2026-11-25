// ---------------------------------------------------------------------------
// Port of vscode/src/vs/editor/common/languages/supports/onEnter.ts
// Translated 1:1. LanguageConfiguration carriers are local (that file is not
// ported yet); EditorAutoIndentStrategy comes from the existing editorOptions.
// ---------------------------------------------------------------------------
import '../../../../base/common/errors.dart' show onUnexpectedError;
import '../../../../base/common/strings.dart' show escapeRegExpCharacters;
import '../../config/editorOptions.dart' show EditorAutoIndentStrategy;

/// 1:1: `enum IndentAction`.
class IndentAction {
  const IndentAction._();
  static const int None = 0;
  static const int Indent = 1;
  static const int IndentOutdent = 2;
  static const int Outdent = 3;
}

/// 1:1: `EnterAction` carrier.
class EnterAction {
  final int indentAction;
  final String? appendText;
  final int? removeText;

  EnterAction(this.indentAction, [this.appendText, this.removeText]);
}

/// 1:1: `OnEnterRule` carrier.
class OnEnterRule {
  final RegExp? beforeText;
  final RegExp? afterText;
  final RegExp? previousLineText;
  final EnterAction action;

  OnEnterRule({
    this.beforeText,
    this.afterText,
    this.previousLineText,
    required this.action,
  });
}

/// 1:1: `IOnEnterSupportOptions`.
class IOnEnterSupportOptions {
  final List<List<String>>? brackets;
  final List<OnEnterRule>? onEnterRules;

  IOnEnterSupportOptions({this.brackets, this.onEnterRules});
}

class _ProcessedBracketPair {
  final String open;
  final String close;
  final RegExp openRegExp;
  final RegExp closeRegExp;

  _ProcessedBracketPair(this.open, this.close, this.openRegExp, this.closeRegExp);
}

/// 1:1: `export class OnEnterSupport`.
class OnEnterSupport {
  late final List<_ProcessedBracketPair> _brackets;
  late final List<OnEnterRule> _regExpRules;

  OnEnterSupport(IOnEnterSupportOptions opts) {
    final List<List<String>> brackets = opts.brackets ?? <List<String>>[
      <String>['(', ')'],
      <String>['{', '}'],
      <String>['[', ']'],
    ];

    _brackets = <_ProcessedBracketPair>[];
    for (final List<String> bracket in brackets) {
      final RegExp? openRegExp = _createOpenBracketRegExp(bracket[0]);
      final RegExp? closeRegExp = _createCloseBracketRegExp(bracket[1]);
      if (openRegExp != null && closeRegExp != null) {
        _brackets.add(_ProcessedBracketPair(
            bracket[0], bracket[1], openRegExp, closeRegExp));
      }
    }
    _regExpRules = opts.onEnterRules ?? <OnEnterRule>[];
  }

  EnterAction? onEnter(
    int autoIndent,
    String previousLineText,
    String beforeEnterText,
    String afterEnterText,
  ) {
    // (1): regExpRules
    if (autoIndent >= EditorAutoIndentStrategy.Advanced) {
      for (final OnEnterRule rule in _regExpRules) {
        final bool matches = _matches(rule.beforeText, beforeEnterText) &&
            _matches(rule.afterText, afterEnterText) &&
            _matches(rule.previousLineText, previousLineText);
        if (matches) {
          return rule.action;
        }
      }
    }

    // (2): Special indent-outdent
    if (autoIndent >= EditorAutoIndentStrategy.Brackets) {
      if (beforeEnterText.isNotEmpty && afterEnterText.isNotEmpty) {
        for (final _ProcessedBracketPair bracket in _brackets) {
          if (bracket.openRegExp.hasMatch(beforeEnterText) &&
              bracket.closeRegExp.hasMatch(afterEnterText)) {
            return EnterAction(IndentAction.IndentOutdent);
          }
        }
      }
    }

    // (4): Open bracket based logic
    if (autoIndent >= EditorAutoIndentStrategy.Brackets) {
      if (beforeEnterText.isNotEmpty) {
        for (final _ProcessedBracketPair bracket in _brackets) {
          if (bracket.openRegExp.hasMatch(beforeEnterText)) {
            return EnterAction(IndentAction.Indent);
          }
        }
      }
    }
    return null;
  }

  static bool _matches(RegExp? reg, String text) =>
      reg == null || reg.hasMatch(text);

  static RegExp? _createOpenBracketRegExp(String bracket) {
    String str = escapeRegExpCharacters(bracket);
    if (!RegExp(r'\B').hasMatch(str[0])) {
      str = '\\b$str';
    }
    str = str + r'\s*$';
    return _safeRegExp(str);
  }

  static RegExp? _createCloseBracketRegExp(String bracket) {
    String str = escapeRegExpCharacters(bracket);
    if (!RegExp(r'\B').hasMatch(str[str.length - 1])) {
      str = str + r'\b';
    }
    str = r'^\s*' + str;
    return _safeRegExp(str);
  }

  static RegExp? _safeRegExp(String def) {
    try {
      return RegExp(def);
    } catch (err) {
      onUnexpectedError(err);
      return null;
    }
  }
}
