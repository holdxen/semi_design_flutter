// 1:1 translation of
// vscode/src/vs/editor/standalone/common/monarch/monarchTypes.ts
// Interface types for Monarch language definitions. These descriptions are
// really JSON values; TS structural interfaces -> Dart value classes, and
// union/tuple types -> abstract carriers distinguished by runtime type (the
// same approach used for keybindings.dart's Chord union).

/// 1:1: `export interface IMonarchLanguage`
class IMonarchLanguage {
  /// map from string to IMonarchLanguageRule[]
  final Map<String, List<IMonarchLanguageRule>> tokenizer;
  /// is the language case insensitive?
  final bool? ignoreCase;
  /// is the language unicode-aware? (i.e., /\u{1D306}/)
  final bool? unicode;
  /// if no match in the tokenizer assign this token class (default 'source')
  final String? defaultToken;
  /// for example [['{','}','delimiter.curly']]
  final List<IMonarchLanguageBracket>? brackets;
  /// start symbol in the tokenizer (by default the first entry is used)
  final String? start;
  /// attach this to every token class (by default '.' + name)
  final String? tokenPostfix;
  /// include line feeds (in the form of a \n character) at the end of lines
  final bool? includeLF;
  /// Other keys that can be referred to by the tokenizer.
  final Map<String, Object?> extra;

  IMonarchLanguage({
    required this.tokenizer,
    this.ignoreCase,
    this.unicode,
    this.defaultToken,
    this.brackets,
    this.start,
    this.tokenPostfix,
    this.includeLF,
    Map<String, Object?>? extra,
  }) : extra = extra ?? <String, Object?>{};
}

/// 1:1: `type IMonarchLanguageRule = IShortMonarchLanguageRule1 | ... | IExpandedMonarchLanguageRule`
abstract class IMonarchLanguageRule {}

/// 1:1: `type IShortMonarchLanguageRule1 = [string | RegExp, IMonarchLanguageAction]`
class IShortMonarchLanguageRule1 extends IMonarchLanguageRule {
  final Object regex; // string | RegExp (RegExp has no Dart runtime form here)
  final IMonarchLanguageAction action;
  IShortMonarchLanguageRule1(this.regex, this.action);
}

/// 1:1: `type IShortMonarchLanguageRule2 = [string | RegExp, IMonarchLanguageAction, string]`
class IShortMonarchLanguageRule2 extends IMonarchLanguageRule {
  final Object regex;
  final IMonarchLanguageAction action;
  final String next;
  IShortMonarchLanguageRule2(this.regex, this.action, this.next);
}

/// 1:1: `export interface IExpandedMonarchLanguageRule`
class IExpandedMonarchLanguageRule extends IMonarchLanguageRule {
  /// match tokens
  final Object? regex; // string | RegExp
  /// action to take on match
  final IMonarchLanguageAction? action;
  /// or an include rule. include all rules from the included state
  final String? include;

  IExpandedMonarchLanguageRule({this.regex, this.action, this.include});
}

/// 1:1: `type IMonarchLanguageAction = IShort | IExpanded | (IShort | IExpanded)[]`
abstract class IMonarchLanguageAction {}

/// 1:1: `export type IShortMonarchLanguageAction = string`
typedef IShortMonarchLanguageAction = String;

/// Carrier for the short (string) action form.
class IShortActionCarrier extends IMonarchLanguageAction {
  final String value;
  IShortActionCarrier(this.value);
}

/// 1:1: `export interface IExpandedMonarchLanguageAction`
class IExpandedMonarchLanguageAction extends IMonarchLanguageAction {
  /// array of actions for each parenthesized match group
  final List<IMonarchLanguageAction>? group;
  /// map from string to ILanguageAction
  final Object? cases;
  /// token class (ie. css class) (or "@brackets" or "@rematch")
  final String? token;
  /// the next state to push, or "@push", "@pop", "@popall"
  final String? next;
  /// switch to this state
  final String? switchTo;
  /// go back n characters in the stream
  final num? goBack;
  /// @open or @close
  final String? bracket;
  /// switch to embedded language (using the mimetype) or get out using "@pop"
  final String? nextEmbedded;
  /// log a message to the browser console window
  final String? log;

  IExpandedMonarchLanguageAction({
    this.group,
    this.cases,
    this.token,
    this.next,
    this.switchTo,
    this.goBack,
    this.bracket,
    this.nextEmbedded,
    this.log,
  });
}

/// Carrier for the array-of-actions form.
class IActionListCarrier extends IMonarchLanguageAction {
  final List<IMonarchLanguageAction> list;
  IActionListCarrier(this.list);
}

/// 1:1: `export interface IMonarchLanguageBracket`
/// This interface can be shortened as an array, ie. ['{','}','delimiter.curly']
class IMonarchLanguageBracket {
  /// open bracket
  final String open;
  /// closing bracket
  final String close;
  /// token class
  final String token;
  IMonarchLanguageBracket(this.open, this.close, this.token);
}
