// 1:1 carrier of the `vscode-languageserver-types` package surface used by
// lspLanguageFeatures.ts. Enum values are the TS runtime values (1-based),
// verified by Node truth extraction. This is an external package, ported as
// opaque value carriers with no invented behavior.

class CompletionItemKind {
  static const int Text = 1;
  static const int Method = 2;
  static const int Function = 3;
  static const int Constructor = 4;
  static const int Field = 5;
  static const int Variable = 6;
  static const int Class = 7;
  static const int Interface = 8;
  static const int Module = 9;
  static const int Property = 10;
  static const int Unit = 11;
  static const int Value = 12;
  static const int Enum = 13;
  static const int Keyword = 14;
  static const int Snippet = 15;
  static const int Color = 16;
  static const int File = 17;
  static const int Reference = 18;
  static const int Folder = 19;
  static const int EnumMember = 20;
  static const int Constant = 21;
  static const int Struct = 22;
  static const int Event = 23;
  static const int Operator = 24;
  static const int TypeParameter = 25;
}

class SymbolKind {
  static const int File = 1;
  static const int Module = 2;
  static const int Namespace = 3;
  static const int Package = 4;
  static const int Class = 5;
  static const int Method = 6;
  static const int Property = 7;
  static const int Field = 8;
  static const int Constructor = 9;
  static const int Enum = 10;
  static const int Interface = 11;
  static const int Function = 12;
  static const int Variable = 13;
  static const int Constant = 14;
  static const int String = 15;
  static const int Number = 16;
  static const int Boolean = 17;
  static const int Array = 18;
  static const int Object = 19;
  static const int Key = 20;
  static const int Null = 21;
  static const int EnumMember = 22;
  static const int Struct = 23;
  static const int Event = 24;
  static const int Operator = 25;
  static const int TypeParameter = 26;
}

class DiagnosticSeverity {
  static const int Error = 1;
  static const int Warning = 2;
  static const int Information = 3;
  static const int Hint = 4;
}

class DocumentHighlightKind {
  static const int Text = 1;
  static const int Read = 2;
  static const int Write = 3;
}

class InsertTextFormat {
  static const int PlainText = 1;
  static const int Snippet = 2;
}

/// 1:1: `lsTypes.FoldingRangeKind` — string-valued constants.
class FoldingRangeKind {
  static const String Comment = 'comment';
  static const String Imports = 'imports';
  static const String Region = 'region';
}
