// 1:1 port of vscode/src/vs/editor/test/common/modes/supports/indentationRules.ts
// Test fixtures: plain RegExp constants. Each exported object becomes a
// top-level final [IndentationRules] with the same field names.

/// Value carrier for a language's indentation rule set.
/// 1:1: the anonymous object shape exported for each language.
class IndentationRules {
  final RegExp? decreaseIndentPattern;
  final RegExp? increaseIndentPattern;
  final RegExp? unIndentedLinePattern;
  final RegExp? indentNextLinePattern;

  const IndentationRules({
    this.decreaseIndentPattern,
    this.increaseIndentPattern,
    this.unIndentedLinePattern,
    this.indentNextLinePattern,
  });
}

final IndentationRules javascriptIndentationRules = IndentationRules(
  decreaseIndentPattern: RegExp(r'^((?!.*?\/\*).*\*\/)?\s*[\}\]\)].*$'),
  increaseIndentPattern: RegExp(r'^((?!\/\/).)*(\{([^}"' "'" r'`]*|(\t|[ ])*\/\/.*)|\([^)"' "'" r'`]*|\[[^\]"' "'" r'`]*)$'),
  unIndentedLinePattern: RegExp(r'^(\t|[ ])*[ ]\*[^/]*\*\/\s*$|^(\t|[ ])*[ ]\*\/\s*$|^(\t|[ ])*[ ]\*([ ]([^\*]|\*(?!\/))*)?$'),
  indentNextLinePattern: RegExp(r'^((.*=>\s*)|((.*[^\w]+|\s*)(if|while|for)\s*\(.*\)\s*))$'),
);

final IndentationRules rubyIndentationRules = IndentationRules(
  decreaseIndentPattern: RegExp(r'^\s*([}\]]([,)]?\s*(#|$)|\.[a-zA-Z_]\w*\b)|(end|rescue|ensure|else|elsif)\b|(in|when)\s)'),
  increaseIndentPattern: RegExp(r'^\s*((begin|class|(private|protected)\s+def|def|else|elsif|ensure|for|if|module|rescue|unless|until|when|in|while|case)|([^#]*\sdo\b)|([^#]*=\s*(case|if|unless)))\b([^#\{;]|(\"|' "'" r'|\/).*\4)*(#.*)?$'),
);

final IndentationRules phpIndentationRules = IndentationRules(
  increaseIndentPattern: RegExp(r'({(?!.*}).*|\(|\[|((else(\s)?)?if|else|for(each)?|while|switch|case).*:)\s*((\/[/*].*|)?$|\?>)'),
  decreaseIndentPattern: RegExp(r'^(.*\*\/)?\s*((\})|(\)+[;,])|(\]\)*[;,])|\b(else:)|\b((end(if|for(each)?|while|switch));))'),
);

final IndentationRules goIndentationRules = IndentationRules(
  decreaseIndentPattern: RegExp(r'^\s*(\bcase\b.*:|\bdefault\b:|}[)}]*[),]?|\)[,]?)$'),
  increaseIndentPattern: RegExp(r'^.*(\bcase\b.*:|\bdefault\b:|(\b(func|if|else|switch|select|for|struct)\b.*)?{[^}"' "'" r'`]*|\([^)"' "'" r'`]*)$'),
);

final IndentationRules htmlIndentationRules = IndentationRules(
  decreaseIndentPattern: RegExp(r'^\s*(<\/(?!html)[-_\.A-Za-z0-9]+\b[^>]*>|-->|\})'),
  increaseIndentPattern: RegExp(r'<(?!\?|(?:area|base|br|col|frame|hr|html|img|input|keygen|link|menuitem|meta|param|source|track|wbr)\b|[^>]*\/>)([-_\.A-Za-z0-9]+)(?=\s|>)\b[^>]*>(?!.*<\/\1>)|<!--(?!.*-->)|\{[^}"' "'" r']*$'),
);

final IndentationRules latexIndentationRules = IndentationRules(
  decreaseIndentPattern: RegExp(r'^\s*\\end{(?!document)'),
  increaseIndentPattern: RegExp(r'\\begin{(?!document)([^}]*)}(?!.*\\end{\1})'),
);

final IndentationRules luaIndentationRules = IndentationRules(
  decreaseIndentPattern: RegExp(r'^\s*((\b(elseif|else|end|until)\b)|(\})|(\)))'),
  increaseIndentPattern: RegExp(r'^((?!(\-\-)).)*((\b(else|function|then|do|repeat)\b((?!\b(end|until)\b).)*)|(\{\s*))$'),
);

final IndentationRules vbIndentationRules = IndentationRules(
  decreaseIndentPattern: RegExp(r'^\s*((End\s+(If|Sub|Function|Class|Module|Enum|Structure|Interface|Namespace|With|Select|Try|While|For|Property|Get|Set|SyncLock|Using|AddHandler|RaiseEvent|RemoveHandler|Event|Operator))|Else|ElseIf|Case|Catch|Finally|Loop|Next|Wend|Until)\b', caseSensitive: false),
  increaseIndentPattern: RegExp(r'^\s*((If|ElseIf).*Then(?!.*End\s+If)\s*((' "'" r'|REM).*)?|(Else|While|For|Do|Select\s+Case|Case|Sub|Function|Class|Module|Enum|Structure|Interface|Namespace|With|Try|Catch|Finally|SyncLock|Using|Property|Get|Set|AddHandler|RaiseEvent|RemoveHandler|Event|Operator)\b(?!.*\bEnd\s+(If|Sub|Function|Class|Module|Enum|Structure|Interface|Namespace|With|Select|Try|While|For|Property|Get|Set|SyncLock|Using|AddHandler|RaiseEvent|RemoveHandler|Event|Operator)\b).*((' "'" r'|REM).*)?)$', caseSensitive: false),
);
