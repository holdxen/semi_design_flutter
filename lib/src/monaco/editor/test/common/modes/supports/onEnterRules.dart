// ---------------------------------------------------------------------------
// Port of vscode/src/vs/editor/test/common/modes/supports/onEnterRules.ts
// Translated 1:1. Pure rule tables: regexes, actions and matching behavior
// are verified against the TypeScript transpile truth (batch405).
// ---------------------------------------------------------------------------
import '../../../../common/languages/supports/onEnter.dart'
    show EnterAction, IndentAction, OnEnterRule;

/// 1:1: `javascriptOnEnterRules` (10 rules).
final List<OnEnterRule> javascriptOnEnterRules = <OnEnterRule>[
  OnEnterRule(
    beforeText: RegExp(r'^\s*\/\*\*(?!\/)([^\*]|\*(?!\/))*$'),
    afterText: RegExp(r'^\s*\*\/$'),
    action: EnterAction(IndentAction.IndentOutdent, ' * '),
  ),
  OnEnterRule(
    beforeText: RegExp(r'^\s*\/\*\*(?!\/)([^\*]|\*(?!\/))*$'),
    action: EnterAction(IndentAction.None, ' * '),
  ),
  OnEnterRule(
    beforeText: RegExp(r'^(\t|[ ])*[ ]\*([ ]([^\*]|\*(?!\/))*)?$'),
    previousLineText: RegExp(r'(?=^(\s*(\/\*\*|\*)).*)(?=(?!(\s*\*\/)))'),
    action: EnterAction(IndentAction.None, '* '),
  ),
  OnEnterRule(
    beforeText: RegExp(r'^(\t|[ ])*[ ]\*\/\s*$'),
    action: EnterAction(IndentAction.None, null, 1),
  ),
  OnEnterRule(
    beforeText: RegExp(r'^(\t|[ ])*[ ]\*[^/]*\*\/\s*$'),
    action: EnterAction(IndentAction.None, null, 1),
  ),
  OnEnterRule(
    beforeText: RegExp(r'^\s*(\bcase\s.+:|\bdefault:)$'),
    afterText: RegExp(r'^(?!\s*(\bcase\b|\bdefault\b))'),
    action: EnterAction(IndentAction.Indent),
  ),
  OnEnterRule(
    beforeText: RegExp(r'^\s+([^{i\s]|i(?!f\b))'),
    previousLineText: RegExp(r'^\s*(((else ?)?if|for|while)\s*\(.*\)\s*|else\s*)$'),
    action: EnterAction(IndentAction.Outdent),
  ),
  OnEnterRule(
    beforeText: RegExp(r'^.*\([^\)]*$'),
    afterText: RegExp(r'^\s*\).*$'),
    action: EnterAction(IndentAction.IndentOutdent, '\t'),
  ),
  OnEnterRule(
    beforeText: RegExp(r'^.*\{[^\}]*$'),
    afterText: RegExp(r'^\s*\}.*$'),
    action: EnterAction(IndentAction.IndentOutdent, '\t'),
  ),
  OnEnterRule(
    beforeText: RegExp(r'^.*\[[^\]]*$'),
    afterText: RegExp(r'^\s*\].*$'),
    action: EnterAction(IndentAction.IndentOutdent, '\t'),
  ),
];

/// 1:1: `phpOnEnterRules` (6 rules).
final List<OnEnterRule> phpOnEnterRules = <OnEnterRule>[
  OnEnterRule(
    beforeText: RegExp(r'^\s*\/\*\*(?!\/)([^\*]|\*(?!\/))*$'),
    afterText: RegExp(r'^\s*\*\/$'),
    action: EnterAction(IndentAction.IndentOutdent, ' * '),
  ),
  OnEnterRule(
    beforeText: RegExp(r'^\s*\/\*\*(?!\/)([^\*]|\*(?!\/))*$'),
    action: EnterAction(IndentAction.None, ' * '),
  ),
  OnEnterRule(
    beforeText: RegExp(r'^(\t|(\ \ ))*\ \*(\ ([^\*]|\*(?!\/))*)?$'),
    action: EnterAction(IndentAction.None, '* '),
  ),
  OnEnterRule(
    beforeText: RegExp(r'^(\t|(\ \ ))*\ \*\/\s*$'),
    action: EnterAction(IndentAction.None, null, 1),
  ),
  OnEnterRule(
    beforeText: RegExp(r'^(\t|(\ \ ))*\ \*[^/]*\*\/\s*$'),
    action: EnterAction(IndentAction.None, null, 1),
  ),
  OnEnterRule(
    beforeText: RegExp(r'^\s+([^{i\s]|i(?!f\b))'),
    previousLineText: RegExp(r'^\s*(((else ?)?if|for(each)?|while)\s*\(.*\)\s*|else\s*)$'),
    action: EnterAction(IndentAction.Outdent),
  ),
];

/// 1:1: `cppOnEnterRules` (1 rules).
final List<OnEnterRule> cppOnEnterRules = <OnEnterRule>[
  OnEnterRule(
    beforeText: RegExp(r'^\s+([^{i\s]|i(?!f\b))'),
    previousLineText: RegExp(r'^\s*(((else ?)?if|for|while)\s*\(.*\)\s*|else\s*)$'),
    action: EnterAction(IndentAction.Outdent),
  ),
];

/// 1:1: `htmlOnEnterRules` (2 rules).
final List<OnEnterRule> htmlOnEnterRules = <OnEnterRule>[
  OnEnterRule(
    beforeText: RegExp(r'''<(?!(?:area|base|br|col|embed|hr|img|input|keygen|link|menuitem|meta|param|source|track|wbr))([_:\w][_:\w\-.\d]*)(?:(?:[^'"/>]|"[^"]*"|'[^']*')*?(?!\/)>)[^<]*$''', caseSensitive: false),
    afterText: RegExp(r'^<\/([_:\w][_:\w\-.\d]*)\s*>', caseSensitive: false),
    action: EnterAction(IndentAction.IndentOutdent),
  ),
  OnEnterRule(
    beforeText: RegExp(r'''<(?!(?:area|base|br|col|embed|hr|img|input|keygen|link|menuitem|meta|param|source|track|wbr))([_:\w][_:\w\-.\d]*)(?:(?:[^'"/>]|"[^"]*"|'[^']*')*?(?!\/)>)[^<]*$''', caseSensitive: false),
    action: EnterAction(IndentAction.Indent),
  ),
];

/// 1:1: `vbOnEnterRules` (1 rules).
final List<OnEnterRule> vbOnEnterRules = <OnEnterRule>[
  OnEnterRule(
    beforeText: RegExp(r'^\s*((End\s+(If|Sub|Function|Class|Module|Enum|Structure|Interface|Namespace|With|Select|Try|While|For|Property|Get|Set|SyncLock|Using|AddHandler|RaiseEvent|RemoveHandler|Event|Operator))|Loop|Next|Wend|Until)\b.*$', caseSensitive: false),
    action: EnterAction(IndentAction.None),
  ),
];

