// Generated 1:1 from monaco-editor/src/languages/features/typescript/lib/typescriptServices.d.ts
// (TypeScript services ambient declarations, TS 5.9.3). No runtime logic exists to port.
// declare namespace ts (module root) -> library top level; nested namespaces -> PascalCase prefix.
// enum -> class static const; interface/class -> abstract class; type/importAlias -> typedef;
// function -> external; unions/intersections/unsupported types -> Object? carriers.
library;

/// enum CommandTypes  [ns: ts.server.protocol]
class ServerProtocolCommandTypes {
  /// JsxClosingTag = jsxClosingTag
  static const String JsxClosingTag = 'jsxClosingTag';
  /// LinkedEditingRange = linkedEditingRange
  static const String LinkedEditingRange = 'linkedEditingRange';
  /// Brace = brace
  static const String Brace = 'brace';
  /// BraceCompletion = braceCompletion
  static const String BraceCompletion = 'braceCompletion';
  /// GetSpanOfEnclosingComment = getSpanOfEnclosingComment
  static const String GetSpanOfEnclosingComment = 'getSpanOfEnclosingComment';
  /// Change = change
  static const String Change = 'change';
  /// Close = close
  static const String Close = 'close';
  /// Completions = completions
  static const String Completions = 'completions';
  /// CompletionInfo = completionInfo
  static const String CompletionInfo = 'completionInfo';
  /// CompletionDetails = completionEntryDetails
  static const String CompletionDetails = 'completionEntryDetails';
  /// CompileOnSaveAffectedFileList = compileOnSaveAffectedFileList
  static const String CompileOnSaveAffectedFileList = 'compileOnSaveAffectedFileList';
  /// CompileOnSaveEmitFile = compileOnSaveEmitFile
  static const String CompileOnSaveEmitFile = 'compileOnSaveEmitFile';
  /// Configure = configure
  static const String Configure = 'configure';
  /// Definition = definition
  static const String Definition = 'definition';
  /// DefinitionAndBoundSpan = definitionAndBoundSpan
  static const String DefinitionAndBoundSpan = 'definitionAndBoundSpan';
  /// Implementation = implementation
  static const String Implementation = 'implementation';
  /// Exit = exit
  static const String Exit = 'exit';
  /// FileReferences = fileReferences
  static const String FileReferences = 'fileReferences';
  /// Format = format
  static const String Format = 'format';
  /// Formatonkey = formatonkey
  static const String Formatonkey = 'formatonkey';
  /// Geterr = geterr
  static const String Geterr = 'geterr';
  /// GeterrForProject = geterrForProject
  static const String GeterrForProject = 'geterrForProject';
  /// SemanticDiagnosticsSync = semanticDiagnosticsSync
  static const String SemanticDiagnosticsSync = 'semanticDiagnosticsSync';
  /// SyntacticDiagnosticsSync = syntacticDiagnosticsSync
  static const String SyntacticDiagnosticsSync = 'syntacticDiagnosticsSync';
  /// SuggestionDiagnosticsSync = suggestionDiagnosticsSync
  static const String SuggestionDiagnosticsSync = 'suggestionDiagnosticsSync';
  /// NavBar = navbar
  static const String NavBar = 'navbar';
  /// Navto = navto
  static const String Navto = 'navto';
  /// NavTree = navtree
  static const String NavTree = 'navtree';
  /// NavTreeFull = navtree-full
  static const String NavTreeFull = 'navtree-full';
  /// DocumentHighlights = documentHighlights
  static const String DocumentHighlights = 'documentHighlights';
  /// Open = open
  static const String Open = 'open';
  /// Quickinfo = quickinfo
  static const String Quickinfo = 'quickinfo';
  /// References = references
  static const String References = 'references';
  /// Reload = reload
  static const String Reload = 'reload';
  /// Rename = rename
  static const String Rename = 'rename';
  /// Saveto = saveto
  static const String Saveto = 'saveto';
  /// SignatureHelp = signatureHelp
  static const String SignatureHelp = 'signatureHelp';
  /// FindSourceDefinition = findSourceDefinition
  static const String FindSourceDefinition = 'findSourceDefinition';
  /// Status = status
  static const String Status = 'status';
  /// TypeDefinition = typeDefinition
  static const String TypeDefinition = 'typeDefinition';
  /// ProjectInfo = projectInfo
  static const String ProjectInfo = 'projectInfo';
  /// ReloadProjects = reloadProjects
  static const String ReloadProjects = 'reloadProjects';
  /// Unknown = unknown
  static const String Unknown = 'unknown';
  /// OpenExternalProject = openExternalProject
  static const String OpenExternalProject = 'openExternalProject';
  /// OpenExternalProjects = openExternalProjects
  static const String OpenExternalProjects = 'openExternalProjects';
  /// CloseExternalProject = closeExternalProject
  static const String CloseExternalProject = 'closeExternalProject';
  /// UpdateOpen = updateOpen
  static const String UpdateOpen = 'updateOpen';
  /// GetOutliningSpans = getOutliningSpans
  static const String GetOutliningSpans = 'getOutliningSpans';
  /// TodoComments = todoComments
  static const String TodoComments = 'todoComments';
  /// Indentation = indentation
  static const String Indentation = 'indentation';
  /// DocCommentTemplate = docCommentTemplate
  static const String DocCommentTemplate = 'docCommentTemplate';
  /// CompilerOptionsForInferredProjects = compilerOptionsForInferredProjects
  static const String CompilerOptionsForInferredProjects = 'compilerOptionsForInferredProjects';
  /// GetCodeFixes = getCodeFixes
  static const String GetCodeFixes = 'getCodeFixes';
  /// GetCombinedCodeFix = getCombinedCodeFix
  static const String GetCombinedCodeFix = 'getCombinedCodeFix';
  /// ApplyCodeActionCommand = applyCodeActionCommand
  static const String ApplyCodeActionCommand = 'applyCodeActionCommand';
  /// GetSupportedCodeFixes = getSupportedCodeFixes
  static const String GetSupportedCodeFixes = 'getSupportedCodeFixes';
  /// GetApplicableRefactors = getApplicableRefactors
  static const String GetApplicableRefactors = 'getApplicableRefactors';
  /// GetEditsForRefactor = getEditsForRefactor
  static const String GetEditsForRefactor = 'getEditsForRefactor';
  /// GetMoveToRefactoringFileSuggestions = getMoveToRefactoringFileSuggestions
  static const String GetMoveToRefactoringFileSuggestions = 'getMoveToRefactoringFileSuggestions';
  /// PreparePasteEdits = preparePasteEdits
  static const String PreparePasteEdits = 'preparePasteEdits';
  /// GetPasteEdits = getPasteEdits
  static const String GetPasteEdits = 'getPasteEdits';
  /// OrganizeImports = organizeImports
  static const String OrganizeImports = 'organizeImports';
  /// GetEditsForFileRename = getEditsForFileRename
  static const String GetEditsForFileRename = 'getEditsForFileRename';
  /// ConfigurePlugin = configurePlugin
  static const String ConfigurePlugin = 'configurePlugin';
  /// SelectionRange = selectionRange
  static const String SelectionRange = 'selectionRange';
  /// ToggleLineComment = toggleLineComment
  static const String ToggleLineComment = 'toggleLineComment';
  /// ToggleMultilineComment = toggleMultilineComment
  static const String ToggleMultilineComment = 'toggleMultilineComment';
  /// CommentSelection = commentSelection
  static const String CommentSelection = 'commentSelection';
  /// UncommentSelection = uncommentSelection
  static const String UncommentSelection = 'uncommentSelection';
  /// PrepareCallHierarchy = prepareCallHierarchy
  static const String PrepareCallHierarchy = 'prepareCallHierarchy';
  /// ProvideCallHierarchyIncomingCalls = provideCallHierarchyIncomingCalls
  static const String ProvideCallHierarchyIncomingCalls = 'provideCallHierarchyIncomingCalls';
  /// ProvideCallHierarchyOutgoingCalls = provideCallHierarchyOutgoingCalls
  static const String ProvideCallHierarchyOutgoingCalls = 'provideCallHierarchyOutgoingCalls';
  /// ProvideInlayHints = provideInlayHints
  static const String ProvideInlayHints = 'provideInlayHints';
  /// WatchChange = watchChange
  static const String WatchChange = 'watchChange';
  /// MapCode = mapCode
  static const String MapCode = 'mapCode';

  const ServerProtocolCommandTypes._();
}

/// enum WatchFileKind  [ns: ts.server.protocol]
class ServerProtocolWatchFileKind {
  /// FixedPollingInterval = FixedPollingInterval
  static const String FixedPollingInterval = 'FixedPollingInterval';
  /// PriorityPollingInterval = PriorityPollingInterval
  static const String PriorityPollingInterval = 'PriorityPollingInterval';
  /// DynamicPriorityPolling = DynamicPriorityPolling
  static const String DynamicPriorityPolling = 'DynamicPriorityPolling';
  /// FixedChunkSizePolling = FixedChunkSizePolling
  static const String FixedChunkSizePolling = 'FixedChunkSizePolling';
  /// UseFsEvents = UseFsEvents
  static const String UseFsEvents = 'UseFsEvents';
  /// UseFsEventsOnParentDirectory = UseFsEventsOnParentDirectory
  static const String UseFsEventsOnParentDirectory = 'UseFsEventsOnParentDirectory';

  const ServerProtocolWatchFileKind._();
}

/// enum WatchDirectoryKind  [ns: ts.server.protocol]
class ServerProtocolWatchDirectoryKind {
  /// UseFsEvents = UseFsEvents
  static const String UseFsEvents = 'UseFsEvents';
  /// FixedPollingInterval = FixedPollingInterval
  static const String FixedPollingInterval = 'FixedPollingInterval';
  /// DynamicPriorityPolling = DynamicPriorityPolling
  static const String DynamicPriorityPolling = 'DynamicPriorityPolling';
  /// FixedChunkSizePolling = FixedChunkSizePolling
  static const String FixedChunkSizePolling = 'FixedChunkSizePolling';

  const ServerProtocolWatchDirectoryKind._();
}

/// enum PollingWatchKind  [ns: ts.server.protocol]
class ServerProtocolPollingWatchKind {
  /// FixedInterval = FixedInterval
  static const String FixedInterval = 'FixedInterval';
  /// PriorityInterval = PriorityInterval
  static const String PriorityInterval = 'PriorityInterval';
  /// DynamicPriority = DynamicPriority
  static const String DynamicPriority = 'DynamicPriority';
  /// FixedChunkSize = FixedChunkSize
  static const String FixedChunkSize = 'FixedChunkSize';

  const ServerProtocolPollingWatchKind._();
}

/// enum IndentStyle  [ns: ts.server.protocol]
class ServerProtocolIndentStyle {
  /// None = None
  static const String None = 'None';
  /// Block = Block
  static const String Block = 'Block';
  /// Smart = Smart
  static const String Smart = 'Smart';

  const ServerProtocolIndentStyle._();
}

/// enum JsxEmit  [ns: ts.server.protocol]
class ServerProtocolJsxEmit {
  /// None = none
  static const String None = 'none';
  /// Preserve = preserve
  static const String Preserve = 'preserve';
  /// ReactNative = react-native
  static const String ReactNative = 'react-native';
  /// React = react
  static const String React = 'react';
  /// ReactJSX = react-jsx
  static const String ReactJSX = 'react-jsx';
  /// ReactJSXDev = react-jsxdev
  static const String ReactJSXDev = 'react-jsxdev';

  const ServerProtocolJsxEmit._();
}

/// enum ModuleKind  [ns: ts.server.protocol]
class ServerProtocolModuleKind {
  /// None = none
  static const String None = 'none';
  /// CommonJS = commonjs
  static const String CommonJS = 'commonjs';
  /// AMD = amd
  static const String AMD = 'amd';
  /// UMD = umd
  static const String UMD = 'umd';
  /// System = system
  static const String System = 'system';
  /// ES6 = es6
  static const String ES6 = 'es6';
  /// ES2015 = es2015
  static const String ES2015 = 'es2015';
  /// ES2020 = es2020
  static const String ES2020 = 'es2020';
  /// ES2022 = es2022
  static const String ES2022 = 'es2022';
  /// ESNext = esnext
  static const String ESNext = 'esnext';
  /// Node16 = node16
  static const String Node16 = 'node16';
  /// Node18 = node18
  static const String Node18 = 'node18';
  /// Node20 = node20
  static const String Node20 = 'node20';
  /// NodeNext = nodenext
  static const String NodeNext = 'nodenext';
  /// Preserve = preserve
  static const String Preserve = 'preserve';

  const ServerProtocolModuleKind._();
}

/// enum ModuleResolutionKind  [ns: ts.server.protocol]
class ServerProtocolModuleResolutionKind {
  /// Classic = classic
  static const String Classic = 'classic';
  /// Node = node
  static const String Node = 'node';
  /// NodeJs = node
  static const String NodeJs = 'node';
  /// Node10 = node10
  static const String Node10 = 'node10';
  /// Node16 = node16
  static const String Node16 = 'node16';
  /// NodeNext = nodenext
  static const String NodeNext = 'nodenext';
  /// Bundler = bundler
  static const String Bundler = 'bundler';

  const ServerProtocolModuleResolutionKind._();
}

/// enum NewLineKind  [ns: ts.server.protocol]
class ServerProtocolNewLineKind {
  /// Crlf = Crlf
  static const String Crlf = 'Crlf';
  /// Lf = Lf
  static const String Lf = 'Lf';

  const ServerProtocolNewLineKind._();
}

/// enum ScriptTarget  [ns: ts.server.protocol]
class ServerProtocolScriptTarget {
  /// ES3 = es3
  static const String ES3 = 'es3';
  /// ES5 = es5
  static const String ES5 = 'es5';
  /// ES6 = es6
  static const String ES6 = 'es6';
  /// ES2015 = es2015
  static const String ES2015 = 'es2015';
  /// ES2016 = es2016
  static const String ES2016 = 'es2016';
  /// ES2017 = es2017
  static const String ES2017 = 'es2017';
  /// ES2018 = es2018
  static const String ES2018 = 'es2018';
  /// ES2019 = es2019
  static const String ES2019 = 'es2019';
  /// ES2020 = es2020
  static const String ES2020 = 'es2020';
  /// ES2021 = es2021
  static const String ES2021 = 'es2021';
  /// ES2022 = es2022
  static const String ES2022 = 'es2022';
  /// ES2023 = es2023
  static const String ES2023 = 'es2023';
  /// ES2024 = es2024
  static const String ES2024 = 'es2024';
  /// ESNext = esnext
  static const String ESNext = 'esnext';
  /// JSON = json
  static const String JSON = 'json';
  /// Latest = esnext
  static const String Latest = 'esnext';

  const ServerProtocolScriptTarget._();
}

/// enum LogLevel  [ns: ts.server]
class ServerLogLevel {
  /// terse = 0
  static const int terse = 0;
  /// normal = 1
  static const int normal = 1;
  /// requestTime = 2
  static const int requestTime = 2;
  /// verbose = 3
  static const int verbose = 3;

  const ServerLogLevel._();
}

/// enum Msg  [ns: ts.server]
class ServerMsg {
  /// Err = Err
  static const String Err = 'Err';
  /// Info = Info
  static const String Info = 'Info';
  /// Perf = Perf
  static const String Perf = 'Perf';

  const ServerMsg._();
}

/// enum ProjectKind  [ns: ts.server]
class ServerProjectKind {
  /// Inferred = 0
  static const int Inferred = 0;
  /// Configured = 1
  static const int Configured = 1;
  /// External = 2
  static const int External = 2;
  /// AutoImportProvider = 3
  static const int AutoImportProvider = 3;
  /// Auxiliary = 4
  static const int Auxiliary = 4;

  const ServerProjectKind._();
}

/// enum SyntaxKind
class SyntaxKind {
  /// Unknown = 0
  static const int Unknown = 0;
  /// EndOfFileToken = 1
  static const int EndOfFileToken = 1;
  /// SingleLineCommentTrivia = 2
  static const int SingleLineCommentTrivia = 2;
  /// MultiLineCommentTrivia = 3
  static const int MultiLineCommentTrivia = 3;
  /// NewLineTrivia = 4
  static const int NewLineTrivia = 4;
  /// WhitespaceTrivia = 5
  static const int WhitespaceTrivia = 5;
  /// ShebangTrivia = 6
  static const int ShebangTrivia = 6;
  /// ConflictMarkerTrivia = 7
  static const int ConflictMarkerTrivia = 7;
  /// NonTextFileMarkerTrivia = 8
  static const int NonTextFileMarkerTrivia = 8;
  /// NumericLiteral = 9
  static const int NumericLiteral = 9;
  /// BigIntLiteral = 10
  static const int BigIntLiteral = 10;
  /// StringLiteral = 11
  static const int StringLiteral = 11;
  /// JsxText = 12
  static const int JsxText = 12;
  /// JsxTextAllWhiteSpaces = 13
  static const int JsxTextAllWhiteSpaces = 13;
  /// RegularExpressionLiteral = 14
  static const int RegularExpressionLiteral = 14;
  /// NoSubstitutionTemplateLiteral = 15
  static const int NoSubstitutionTemplateLiteral = 15;
  /// TemplateHead = 16
  static const int TemplateHead = 16;
  /// TemplateMiddle = 17
  static const int TemplateMiddle = 17;
  /// TemplateTail = 18
  static const int TemplateTail = 18;
  /// OpenBraceToken = 19
  static const int OpenBraceToken = 19;
  /// CloseBraceToken = 20
  static const int CloseBraceToken = 20;
  /// OpenParenToken = 21
  static const int OpenParenToken = 21;
  /// CloseParenToken = 22
  static const int CloseParenToken = 22;
  /// OpenBracketToken = 23
  static const int OpenBracketToken = 23;
  /// CloseBracketToken = 24
  static const int CloseBracketToken = 24;
  /// DotToken = 25
  static const int DotToken = 25;
  /// DotDotDotToken = 26
  static const int DotDotDotToken = 26;
  /// SemicolonToken = 27
  static const int SemicolonToken = 27;
  /// CommaToken = 28
  static const int CommaToken = 28;
  /// QuestionDotToken = 29
  static const int QuestionDotToken = 29;
  /// LessThanToken = 30
  static const int LessThanToken = 30;
  /// LessThanSlashToken = 31
  static const int LessThanSlashToken = 31;
  /// GreaterThanToken = 32
  static const int GreaterThanToken = 32;
  /// LessThanEqualsToken = 33
  static const int LessThanEqualsToken = 33;
  /// GreaterThanEqualsToken = 34
  static const int GreaterThanEqualsToken = 34;
  /// EqualsEqualsToken = 35
  static const int EqualsEqualsToken = 35;
  /// ExclamationEqualsToken = 36
  static const int ExclamationEqualsToken = 36;
  /// EqualsEqualsEqualsToken = 37
  static const int EqualsEqualsEqualsToken = 37;
  /// ExclamationEqualsEqualsToken = 38
  static const int ExclamationEqualsEqualsToken = 38;
  /// EqualsGreaterThanToken = 39
  static const int EqualsGreaterThanToken = 39;
  /// PlusToken = 40
  static const int PlusToken = 40;
  /// MinusToken = 41
  static const int MinusToken = 41;
  /// AsteriskToken = 42
  static const int AsteriskToken = 42;
  /// AsteriskAsteriskToken = 43
  static const int AsteriskAsteriskToken = 43;
  /// SlashToken = 44
  static const int SlashToken = 44;
  /// PercentToken = 45
  static const int PercentToken = 45;
  /// PlusPlusToken = 46
  static const int PlusPlusToken = 46;
  /// MinusMinusToken = 47
  static const int MinusMinusToken = 47;
  /// LessThanLessThanToken = 48
  static const int LessThanLessThanToken = 48;
  /// GreaterThanGreaterThanToken = 49
  static const int GreaterThanGreaterThanToken = 49;
  /// GreaterThanGreaterThanGreaterThanToken = 50
  static const int GreaterThanGreaterThanGreaterThanToken = 50;
  /// AmpersandToken = 51
  static const int AmpersandToken = 51;
  /// BarToken = 52
  static const int BarToken = 52;
  /// CaretToken = 53
  static const int CaretToken = 53;
  /// ExclamationToken = 54
  static const int ExclamationToken = 54;
  /// TildeToken = 55
  static const int TildeToken = 55;
  /// AmpersandAmpersandToken = 56
  static const int AmpersandAmpersandToken = 56;
  /// BarBarToken = 57
  static const int BarBarToken = 57;
  /// QuestionToken = 58
  static const int QuestionToken = 58;
  /// ColonToken = 59
  static const int ColonToken = 59;
  /// AtToken = 60
  static const int AtToken = 60;
  /// QuestionQuestionToken = 61
  static const int QuestionQuestionToken = 61;
  /// BacktickToken = 62
  static const int BacktickToken = 62;
  /// HashToken = 63
  static const int HashToken = 63;
  /// EqualsToken = 64
  static const int EqualsToken = 64;
  /// PlusEqualsToken = 65
  static const int PlusEqualsToken = 65;
  /// MinusEqualsToken = 66
  static const int MinusEqualsToken = 66;
  /// AsteriskEqualsToken = 67
  static const int AsteriskEqualsToken = 67;
  /// AsteriskAsteriskEqualsToken = 68
  static const int AsteriskAsteriskEqualsToken = 68;
  /// SlashEqualsToken = 69
  static const int SlashEqualsToken = 69;
  /// PercentEqualsToken = 70
  static const int PercentEqualsToken = 70;
  /// LessThanLessThanEqualsToken = 71
  static const int LessThanLessThanEqualsToken = 71;
  /// GreaterThanGreaterThanEqualsToken = 72
  static const int GreaterThanGreaterThanEqualsToken = 72;
  /// GreaterThanGreaterThanGreaterThanEqualsToken = 73
  static const int GreaterThanGreaterThanGreaterThanEqualsToken = 73;
  /// AmpersandEqualsToken = 74
  static const int AmpersandEqualsToken = 74;
  /// BarEqualsToken = 75
  static const int BarEqualsToken = 75;
  /// BarBarEqualsToken = 76
  static const int BarBarEqualsToken = 76;
  /// AmpersandAmpersandEqualsToken = 77
  static const int AmpersandAmpersandEqualsToken = 77;
  /// QuestionQuestionEqualsToken = 78
  static const int QuestionQuestionEqualsToken = 78;
  /// CaretEqualsToken = 79
  static const int CaretEqualsToken = 79;
  /// Identifier = 80
  static const int Identifier = 80;
  /// PrivateIdentifier = 81
  static const int PrivateIdentifier = 81;
  /// BreakKeyword = 83
  static const int BreakKeyword = 83;
  /// CaseKeyword = 84
  static const int CaseKeyword = 84;
  /// CatchKeyword = 85
  static const int CatchKeyword = 85;
  /// ClassKeyword = 86
  static const int ClassKeyword = 86;
  /// ConstKeyword = 87
  static const int ConstKeyword = 87;
  /// ContinueKeyword = 88
  static const int ContinueKeyword = 88;
  /// DebuggerKeyword = 89
  static const int DebuggerKeyword = 89;
  /// DefaultKeyword = 90
  static const int DefaultKeyword = 90;
  /// DeleteKeyword = 91
  static const int DeleteKeyword = 91;
  /// DoKeyword = 92
  static const int DoKeyword = 92;
  /// ElseKeyword = 93
  static const int ElseKeyword = 93;
  /// EnumKeyword = 94
  static const int EnumKeyword = 94;
  /// ExportKeyword = 95
  static const int ExportKeyword = 95;
  /// ExtendsKeyword = 96
  static const int ExtendsKeyword = 96;
  /// FalseKeyword = 97
  static const int FalseKeyword = 97;
  /// FinallyKeyword = 98
  static const int FinallyKeyword = 98;
  /// ForKeyword = 99
  static const int ForKeyword = 99;
  /// FunctionKeyword = 100
  static const int FunctionKeyword = 100;
  /// IfKeyword = 101
  static const int IfKeyword = 101;
  /// ImportKeyword = 102
  static const int ImportKeyword = 102;
  /// InKeyword = 103
  static const int InKeyword = 103;
  /// InstanceOfKeyword = 104
  static const int InstanceOfKeyword = 104;
  /// NewKeyword = 105
  static const int NewKeyword = 105;
  /// NullKeyword = 106
  static const int NullKeyword = 106;
  /// ReturnKeyword = 107
  static const int ReturnKeyword = 107;
  /// SuperKeyword = 108
  static const int SuperKeyword = 108;
  /// SwitchKeyword = 109
  static const int SwitchKeyword = 109;
  /// ThisKeyword = 110
  static const int ThisKeyword = 110;
  /// ThrowKeyword = 111
  static const int ThrowKeyword = 111;
  /// TrueKeyword = 112
  static const int TrueKeyword = 112;
  /// TryKeyword = 113
  static const int TryKeyword = 113;
  /// TypeOfKeyword = 114
  static const int TypeOfKeyword = 114;
  /// VarKeyword = 115
  static const int VarKeyword = 115;
  /// VoidKeyword = 116
  static const int VoidKeyword = 116;
  /// WhileKeyword = 117
  static const int WhileKeyword = 117;
  /// WithKeyword = 118
  static const int WithKeyword = 118;
  /// ImplementsKeyword = 119
  static const int ImplementsKeyword = 119;
  /// InterfaceKeyword = 120
  static const int InterfaceKeyword = 120;
  /// LetKeyword = 121
  static const int LetKeyword = 121;
  /// PackageKeyword = 122
  static const int PackageKeyword = 122;
  /// PrivateKeyword = 123
  static const int PrivateKeyword = 123;
  /// ProtectedKeyword = 124
  static const int ProtectedKeyword = 124;
  /// PublicKeyword = 125
  static const int PublicKeyword = 125;
  /// StaticKeyword = 126
  static const int StaticKeyword = 126;
  /// YieldKeyword = 127
  static const int YieldKeyword = 127;
  /// AbstractKeyword = 128
  static const int AbstractKeyword = 128;
  /// AccessorKeyword = 129
  static const int AccessorKeyword = 129;
  /// AsKeyword = 130
  static const int AsKeyword = 130;
  /// AssertsKeyword = 131
  static const int AssertsKeyword = 131;
  /// AssertKeyword = 132
  static const int AssertKeyword = 132;
  /// AnyKeyword = 133
  static const int AnyKeyword = 133;
  /// AsyncKeyword = 134
  static const int AsyncKeyword = 134;
  /// AwaitKeyword = 135
  static const int AwaitKeyword = 135;
  /// BooleanKeyword = 136
  static const int BooleanKeyword = 136;
  /// ConstructorKeyword = 137
  static const int ConstructorKeyword = 137;
  /// DeclareKeyword = 138
  static const int DeclareKeyword = 138;
  /// GetKeyword = 139
  static const int GetKeyword = 139;
  /// InferKeyword = 140
  static const int InferKeyword = 140;
  /// IntrinsicKeyword = 141
  static const int IntrinsicKeyword = 141;
  /// IsKeyword = 142
  static const int IsKeyword = 142;
  /// KeyOfKeyword = 143
  static const int KeyOfKeyword = 143;
  /// ModuleKeyword = 144
  static const int ModuleKeyword = 144;
  /// NamespaceKeyword = 145
  static const int NamespaceKeyword = 145;
  /// NeverKeyword = 146
  static const int NeverKeyword = 146;
  /// OutKeyword = 147
  static const int OutKeyword = 147;
  /// ReadonlyKeyword = 148
  static const int ReadonlyKeyword = 148;
  /// RequireKeyword = 149
  static const int RequireKeyword = 149;
  /// NumberKeyword = 150
  static const int NumberKeyword = 150;
  /// ObjectKeyword = 151
  static const int ObjectKeyword = 151;
  /// SatisfiesKeyword = 152
  static const int SatisfiesKeyword = 152;
  /// SetKeyword = 153
  static const int SetKeyword = 153;
  /// StringKeyword = 154
  static const int StringKeyword = 154;
  /// SymbolKeyword = 155
  static const int SymbolKeyword = 155;
  /// TypeKeyword = 156
  static const int TypeKeyword = 156;
  /// UndefinedKeyword = 157
  static const int UndefinedKeyword = 157;
  /// UniqueKeyword = 158
  static const int UniqueKeyword = 158;
  /// UnknownKeyword = 159
  static const int UnknownKeyword = 159;
  /// UsingKeyword = 160
  static const int UsingKeyword = 160;
  /// FromKeyword = 161
  static const int FromKeyword = 161;
  /// GlobalKeyword = 162
  static const int GlobalKeyword = 162;
  /// BigIntKeyword = 163
  static const int BigIntKeyword = 163;
  /// OverrideKeyword = 164
  static const int OverrideKeyword = 164;
  /// OfKeyword = 165
  static const int OfKeyword = 165;
  /// DeferKeyword = 166
  static const int DeferKeyword = 166;
  /// QualifiedName = 167
  static const int QualifiedName = 167;
  /// ComputedPropertyName = 168
  static const int ComputedPropertyName = 168;
  /// TypeParameter = 169
  static const int TypeParameter = 169;
  /// Parameter = 170
  static const int Parameter = 170;
  /// Decorator = 171
  static const int Decorator = 171;
  /// PropertySignature = 172
  static const int PropertySignature = 172;
  /// PropertyDeclaration = 173
  static const int PropertyDeclaration = 173;
  /// MethodSignature = 174
  static const int MethodSignature = 174;
  /// MethodDeclaration = 175
  static const int MethodDeclaration = 175;
  /// ClassStaticBlockDeclaration = 176
  static const int ClassStaticBlockDeclaration = 176;
  /// Constructor = 177
  static const int Constructor = 177;
  /// GetAccessor = 178
  static const int GetAccessor = 178;
  /// SetAccessor = 179
  static const int SetAccessor = 179;
  /// CallSignature = 180
  static const int CallSignature = 180;
  /// ConstructSignature = 181
  static const int ConstructSignature = 181;
  /// IndexSignature = 182
  static const int IndexSignature = 182;
  /// TypePredicate = 183
  static const int TypePredicate = 183;
  /// TypeReference = 184
  static const int TypeReference = 184;
  /// FunctionType = 185
  static const int FunctionType = 185;
  /// ConstructorType = 186
  static const int ConstructorType = 186;
  /// TypeQuery = 187
  static const int TypeQuery = 187;
  /// TypeLiteral = 188
  static const int TypeLiteral = 188;
  /// ArrayType = 189
  static const int ArrayType = 189;
  /// TupleType = 190
  static const int TupleType = 190;
  /// OptionalType = 191
  static const int OptionalType = 191;
  /// RestType = 192
  static const int RestType = 192;
  /// UnionType = 193
  static const int UnionType = 193;
  /// IntersectionType = 194
  static const int IntersectionType = 194;
  /// ConditionalType = 195
  static const int ConditionalType = 195;
  /// InferType = 196
  static const int InferType = 196;
  /// ParenthesizedType = 197
  static const int ParenthesizedType = 197;
  /// ThisType = 198
  static const int ThisType = 198;
  /// TypeOperator = 199
  static const int TypeOperator = 199;
  /// IndexedAccessType = 200
  static const int IndexedAccessType = 200;
  /// MappedType = 201
  static const int MappedType = 201;
  /// LiteralType = 202
  static const int LiteralType = 202;
  /// NamedTupleMember = 203
  static const int NamedTupleMember = 203;
  /// TemplateLiteralType = 204
  static const int TemplateLiteralType = 204;
  /// TemplateLiteralTypeSpan = 205
  static const int TemplateLiteralTypeSpan = 205;
  /// ImportType = 206
  static const int ImportType = 206;
  /// ObjectBindingPattern = 207
  static const int ObjectBindingPattern = 207;
  /// ArrayBindingPattern = 208
  static const int ArrayBindingPattern = 208;
  /// BindingElement = 209
  static const int BindingElement = 209;
  /// ArrayLiteralExpression = 210
  static const int ArrayLiteralExpression = 210;
  /// ObjectLiteralExpression = 211
  static const int ObjectLiteralExpression = 211;
  /// PropertyAccessExpression = 212
  static const int PropertyAccessExpression = 212;
  /// ElementAccessExpression = 213
  static const int ElementAccessExpression = 213;
  /// CallExpression = 214
  static const int CallExpression = 214;
  /// NewExpression = 215
  static const int NewExpression = 215;
  /// TaggedTemplateExpression = 216
  static const int TaggedTemplateExpression = 216;
  /// TypeAssertionExpression = 217
  static const int TypeAssertionExpression = 217;
  /// ParenthesizedExpression = 218
  static const int ParenthesizedExpression = 218;
  /// FunctionExpression = 219
  static const int FunctionExpression = 219;
  /// ArrowFunction = 220
  static const int ArrowFunction = 220;
  /// DeleteExpression = 221
  static const int DeleteExpression = 221;
  /// TypeOfExpression = 222
  static const int TypeOfExpression = 222;
  /// VoidExpression = 223
  static const int VoidExpression = 223;
  /// AwaitExpression = 224
  static const int AwaitExpression = 224;
  /// PrefixUnaryExpression = 225
  static const int PrefixUnaryExpression = 225;
  /// PostfixUnaryExpression = 226
  static const int PostfixUnaryExpression = 226;
  /// BinaryExpression = 227
  static const int BinaryExpression = 227;
  /// ConditionalExpression = 228
  static const int ConditionalExpression = 228;
  /// TemplateExpression = 229
  static const int TemplateExpression = 229;
  /// YieldExpression = 230
  static const int YieldExpression = 230;
  /// SpreadElement = 231
  static const int SpreadElement = 231;
  /// ClassExpression = 232
  static const int ClassExpression = 232;
  /// OmittedExpression = 233
  static const int OmittedExpression = 233;
  /// ExpressionWithTypeArguments = 234
  static const int ExpressionWithTypeArguments = 234;
  /// AsExpression = 235
  static const int AsExpression = 235;
  /// NonNullExpression = 236
  static const int NonNullExpression = 236;
  /// MetaProperty = 237
  static const int MetaProperty = 237;
  /// SyntheticExpression = 238
  static const int SyntheticExpression = 238;
  /// SatisfiesExpression = 239
  static const int SatisfiesExpression = 239;
  /// TemplateSpan = 240
  static const int TemplateSpan = 240;
  /// SemicolonClassElement = 241
  static const int SemicolonClassElement = 241;
  /// Block = 242
  static const int Block = 242;
  /// EmptyStatement = 243
  static const int EmptyStatement = 243;
  /// VariableStatement = 244
  static const int VariableStatement = 244;
  /// ExpressionStatement = 245
  static const int ExpressionStatement = 245;
  /// IfStatement = 246
  static const int IfStatement = 246;
  /// DoStatement = 247
  static const int DoStatement = 247;
  /// WhileStatement = 248
  static const int WhileStatement = 248;
  /// ForStatement = 249
  static const int ForStatement = 249;
  /// ForInStatement = 250
  static const int ForInStatement = 250;
  /// ForOfStatement = 251
  static const int ForOfStatement = 251;
  /// ContinueStatement = 252
  static const int ContinueStatement = 252;
  /// BreakStatement = 253
  static const int BreakStatement = 253;
  /// ReturnStatement = 254
  static const int ReturnStatement = 254;
  /// WithStatement = 255
  static const int WithStatement = 255;
  /// SwitchStatement = 256
  static const int SwitchStatement = 256;
  /// LabeledStatement = 257
  static const int LabeledStatement = 257;
  /// ThrowStatement = 258
  static const int ThrowStatement = 258;
  /// TryStatement = 259
  static const int TryStatement = 259;
  /// DebuggerStatement = 260
  static const int DebuggerStatement = 260;
  /// VariableDeclaration = 261
  static const int VariableDeclaration = 261;
  /// VariableDeclarationList = 262
  static const int VariableDeclarationList = 262;
  /// FunctionDeclaration = 263
  static const int FunctionDeclaration = 263;
  /// ClassDeclaration = 264
  static const int ClassDeclaration = 264;
  /// InterfaceDeclaration = 265
  static const int InterfaceDeclaration = 265;
  /// TypeAliasDeclaration = 266
  static const int TypeAliasDeclaration = 266;
  /// EnumDeclaration = 267
  static const int EnumDeclaration = 267;
  /// ModuleDeclaration = 268
  static const int ModuleDeclaration = 268;
  /// ModuleBlock = 269
  static const int ModuleBlock = 269;
  /// CaseBlock = 270
  static const int CaseBlock = 270;
  /// NamespaceExportDeclaration = 271
  static const int NamespaceExportDeclaration = 271;
  /// ImportEqualsDeclaration = 272
  static const int ImportEqualsDeclaration = 272;
  /// ImportDeclaration = 273
  static const int ImportDeclaration = 273;
  /// ImportClause = 274
  static const int ImportClause = 274;
  /// NamespaceImport = 275
  static const int NamespaceImport = 275;
  /// NamedImports = 276
  static const int NamedImports = 276;
  /// ImportSpecifier = 277
  static const int ImportSpecifier = 277;
  /// ExportAssignment = 278
  static const int ExportAssignment = 278;
  /// ExportDeclaration = 279
  static const int ExportDeclaration = 279;
  /// NamedExports = 280
  static const int NamedExports = 280;
  /// NamespaceExport = 281
  static const int NamespaceExport = 281;
  /// ExportSpecifier = 282
  static const int ExportSpecifier = 282;
  /// MissingDeclaration = 283
  static const int MissingDeclaration = 283;
  /// ExternalModuleReference = 284
  static const int ExternalModuleReference = 284;
  /// JsxElement = 285
  static const int JsxElement = 285;
  /// JsxSelfClosingElement = 286
  static const int JsxSelfClosingElement = 286;
  /// JsxOpeningElement = 287
  static const int JsxOpeningElement = 287;
  /// JsxClosingElement = 288
  static const int JsxClosingElement = 288;
  /// JsxFragment = 289
  static const int JsxFragment = 289;
  /// JsxOpeningFragment = 290
  static const int JsxOpeningFragment = 290;
  /// JsxClosingFragment = 291
  static const int JsxClosingFragment = 291;
  /// JsxAttribute = 292
  static const int JsxAttribute = 292;
  /// JsxAttributes = 293
  static const int JsxAttributes = 293;
  /// JsxSpreadAttribute = 294
  static const int JsxSpreadAttribute = 294;
  /// JsxExpression = 295
  static const int JsxExpression = 295;
  /// JsxNamespacedName = 296
  static const int JsxNamespacedName = 296;
  /// CaseClause = 297
  static const int CaseClause = 297;
  /// DefaultClause = 298
  static const int DefaultClause = 298;
  /// HeritageClause = 299
  static const int HeritageClause = 299;
  /// CatchClause = 300
  static const int CatchClause = 300;
  /// ImportAttributes = 301
  static const int ImportAttributes = 301;
  /// ImportAttribute = 302
  static const int ImportAttribute = 302;
  /// AssertClause = 301
  static const int AssertClause = 301;
  /// AssertEntry = 302
  static const int AssertEntry = 302;
  /// ImportTypeAssertionContainer = 303
  static const int ImportTypeAssertionContainer = 303;
  /// PropertyAssignment = 304
  static const int PropertyAssignment = 304;
  /// ShorthandPropertyAssignment = 305
  static const int ShorthandPropertyAssignment = 305;
  /// SpreadAssignment = 306
  static const int SpreadAssignment = 306;
  /// EnumMember = 307
  static const int EnumMember = 307;
  /// SourceFile = 308
  static const int SourceFile = 308;
  /// Bundle = 309
  static const int Bundle = 309;
  /// JSDocTypeExpression = 310
  static const int JSDocTypeExpression = 310;
  /// JSDocNameReference = 311
  static const int JSDocNameReference = 311;
  /// JSDocMemberName = 312
  static const int JSDocMemberName = 312;
  /// JSDocAllType = 313
  static const int JSDocAllType = 313;
  /// JSDocUnknownType = 314
  static const int JSDocUnknownType = 314;
  /// JSDocNullableType = 315
  static const int JSDocNullableType = 315;
  /// JSDocNonNullableType = 316
  static const int JSDocNonNullableType = 316;
  /// JSDocOptionalType = 317
  static const int JSDocOptionalType = 317;
  /// JSDocFunctionType = 318
  static const int JSDocFunctionType = 318;
  /// JSDocVariadicType = 319
  static const int JSDocVariadicType = 319;
  /// JSDocNamepathType = 320
  static const int JSDocNamepathType = 320;
  /// JSDoc = 321
  static const int JSDoc = 321;
  /// JSDocComment = 321
  static const int JSDocComment = 321;
  /// JSDocText = 322
  static const int JSDocText = 322;
  /// JSDocTypeLiteral = 323
  static const int JSDocTypeLiteral = 323;
  /// JSDocSignature = 324
  static const int JSDocSignature = 324;
  /// JSDocLink = 325
  static const int JSDocLink = 325;
  /// JSDocLinkCode = 326
  static const int JSDocLinkCode = 326;
  /// JSDocLinkPlain = 327
  static const int JSDocLinkPlain = 327;
  /// JSDocTag = 328
  static const int JSDocTag = 328;
  /// JSDocAugmentsTag = 329
  static const int JSDocAugmentsTag = 329;
  /// JSDocImplementsTag = 330
  static const int JSDocImplementsTag = 330;
  /// JSDocAuthorTag = 331
  static const int JSDocAuthorTag = 331;
  /// JSDocDeprecatedTag = 332
  static const int JSDocDeprecatedTag = 332;
  /// JSDocClassTag = 333
  static const int JSDocClassTag = 333;
  /// JSDocPublicTag = 334
  static const int JSDocPublicTag = 334;
  /// JSDocPrivateTag = 335
  static const int JSDocPrivateTag = 335;
  /// JSDocProtectedTag = 336
  static const int JSDocProtectedTag = 336;
  /// JSDocReadonlyTag = 337
  static const int JSDocReadonlyTag = 337;
  /// JSDocOverrideTag = 338
  static const int JSDocOverrideTag = 338;
  /// JSDocCallbackTag = 339
  static const int JSDocCallbackTag = 339;
  /// JSDocOverloadTag = 340
  static const int JSDocOverloadTag = 340;
  /// JSDocEnumTag = 341
  static const int JSDocEnumTag = 341;
  /// JSDocParameterTag = 342
  static const int JSDocParameterTag = 342;
  /// JSDocReturnTag = 343
  static const int JSDocReturnTag = 343;
  /// JSDocThisTag = 344
  static const int JSDocThisTag = 344;
  /// JSDocTypeTag = 345
  static const int JSDocTypeTag = 345;
  /// JSDocTemplateTag = 346
  static const int JSDocTemplateTag = 346;
  /// JSDocTypedefTag = 347
  static const int JSDocTypedefTag = 347;
  /// JSDocSeeTag = 348
  static const int JSDocSeeTag = 348;
  /// JSDocPropertyTag = 349
  static const int JSDocPropertyTag = 349;
  /// JSDocThrowsTag = 350
  static const int JSDocThrowsTag = 350;
  /// JSDocSatisfiesTag = 351
  static const int JSDocSatisfiesTag = 351;
  /// JSDocImportTag = 352
  static const int JSDocImportTag = 352;
  /// SyntaxList = 353
  static const int SyntaxList = 353;
  /// NotEmittedStatement = 354
  static const int NotEmittedStatement = 354;
  /// NotEmittedTypeElement = 355
  static const int NotEmittedTypeElement = 355;
  /// PartiallyEmittedExpression = 356
  static const int PartiallyEmittedExpression = 356;
  /// CommaListExpression = 357
  static const int CommaListExpression = 357;
  /// SyntheticReferenceExpression = 358
  static const int SyntheticReferenceExpression = 358;
  /// Count = 359
  static const int Count = 359;
  /// FirstAssignment = 64
  static const int FirstAssignment = 64;
  /// LastAssignment = 79
  static const int LastAssignment = 79;
  /// FirstCompoundAssignment = 65
  static const int FirstCompoundAssignment = 65;
  /// LastCompoundAssignment = 79
  static const int LastCompoundAssignment = 79;
  /// FirstReservedWord = 83
  static const int FirstReservedWord = 83;
  /// LastReservedWord = 118
  static const int LastReservedWord = 118;
  /// FirstKeyword = 83
  static const int FirstKeyword = 83;
  /// LastKeyword = 166
  static const int LastKeyword = 166;
  /// FirstFutureReservedWord = 119
  static const int FirstFutureReservedWord = 119;
  /// LastFutureReservedWord = 127
  static const int LastFutureReservedWord = 127;
  /// FirstTypeNode = 183
  static const int FirstTypeNode = 183;
  /// LastTypeNode = 206
  static const int LastTypeNode = 206;
  /// FirstPunctuation = 19
  static const int FirstPunctuation = 19;
  /// LastPunctuation = 79
  static const int LastPunctuation = 79;
  /// FirstToken = 0
  static const int FirstToken = 0;
  /// LastToken = 166
  static const int LastToken = 166;
  /// FirstTriviaToken = 2
  static const int FirstTriviaToken = 2;
  /// LastTriviaToken = 7
  static const int LastTriviaToken = 7;
  /// FirstLiteralToken = 9
  static const int FirstLiteralToken = 9;
  /// LastLiteralToken = 15
  static const int LastLiteralToken = 15;
  /// FirstTemplateToken = 15
  static const int FirstTemplateToken = 15;
  /// LastTemplateToken = 18
  static const int LastTemplateToken = 18;
  /// FirstBinaryOperator = 30
  static const int FirstBinaryOperator = 30;
  /// LastBinaryOperator = 79
  static const int LastBinaryOperator = 79;
  /// FirstStatement = 244
  static const int FirstStatement = 244;
  /// LastStatement = 260
  static const int LastStatement = 260;
  /// FirstNode = 167
  static const int FirstNode = 167;
  /// FirstJSDocNode = 310
  static const int FirstJSDocNode = 310;
  /// LastJSDocNode = 352
  static const int LastJSDocNode = 352;
  /// FirstJSDocTagNode = 328
  static const int FirstJSDocTagNode = 328;
  /// LastJSDocTagNode = 352
  static const int LastJSDocTagNode = 352;

  const SyntaxKind._();
}

/// enum NodeFlags
class NodeFlags {
  /// None = 0
  static const int None = 0;
  /// Let = 1
  static const int Let = 1;
  /// Const = 2
  static const int Const = 2;
  /// Using = 4
  static const int Using = 4;
  /// AwaitUsing = 6
  static const int AwaitUsing = 6;
  /// NestedNamespace = 8
  static const int NestedNamespace = 8;
  /// Synthesized = 16
  static const int Synthesized = 16;
  /// Namespace = 32
  static const int Namespace = 32;
  /// OptionalChain = 64
  static const int OptionalChain = 64;
  /// ExportContext = 128
  static const int ExportContext = 128;
  /// ContainsThis = 256
  static const int ContainsThis = 256;
  /// HasImplicitReturn = 512
  static const int HasImplicitReturn = 512;
  /// HasExplicitReturn = 1024
  static const int HasExplicitReturn = 1024;
  /// GlobalAugmentation = 2048
  static const int GlobalAugmentation = 2048;
  /// HasAsyncFunctions = 4096
  static const int HasAsyncFunctions = 4096;
  /// DisallowInContext = 8192
  static const int DisallowInContext = 8192;
  /// YieldContext = 16384
  static const int YieldContext = 16384;
  /// DecoratorContext = 32768
  static const int DecoratorContext = 32768;
  /// AwaitContext = 65536
  static const int AwaitContext = 65536;
  /// DisallowConditionalTypesContext = 131072
  static const int DisallowConditionalTypesContext = 131072;
  /// ThisNodeHasError = 262144
  static const int ThisNodeHasError = 262144;
  /// JavaScriptFile = 524288
  static const int JavaScriptFile = 524288;
  /// ThisNodeOrAnySubNodesHasError = 1048576
  static const int ThisNodeOrAnySubNodesHasError = 1048576;
  /// HasAggregatedChildData = 2097152
  static const int HasAggregatedChildData = 2097152;
  /// JSDoc = 16777216
  static const int JSDoc = 16777216;
  /// JsonFile = 134217728
  static const int JsonFile = 134217728;
  /// BlockScoped = 7
  static const int BlockScoped = 7;
  /// Constant = 6
  static const int Constant = 6;
  /// ReachabilityCheckFlags = 1536
  static const int ReachabilityCheckFlags = 1536;
  /// ReachabilityAndEmitFlags = 5632
  static const int ReachabilityAndEmitFlags = 5632;
  /// ContextFlags = 101441536
  static const int ContextFlags = 101441536;
  /// TypeExcludesFlags = 81920
  static const int TypeExcludesFlags = 81920;

  const NodeFlags._();
}

/// enum ModifierFlags
class ModifierFlags {
  /// None = 0
  static const int None = 0;
  /// Public = 1
  static const int Public = 1;
  /// Private = 2
  static const int Private = 2;
  /// Protected = 4
  static const int Protected = 4;
  /// Readonly = 8
  static const int Readonly = 8;
  /// Override = 16
  static const int Override = 16;
  /// Export = 32
  static const int Export = 32;
  /// Abstract = 64
  static const int Abstract = 64;
  /// Ambient = 128
  static const int Ambient = 128;
  /// Static = 256
  static const int Static = 256;
  /// Accessor = 512
  static const int Accessor = 512;
  /// Async = 1024
  static const int Async = 1024;
  /// Default = 2048
  static const int Default = 2048;
  /// Const = 4096
  static const int Const = 4096;
  /// In = 8192
  static const int In = 8192;
  /// Out = 16384
  static const int Out = 16384;
  /// Decorator = 32768
  static const int Decorator = 32768;
  /// Deprecated = 65536
  static const int Deprecated = 65536;
  /// HasComputedJSDocModifiers = 268435456
  static const int HasComputedJSDocModifiers = 268435456;
  /// HasComputedFlags = 536870912
  static const int HasComputedFlags = 536870912;
  /// AccessibilityModifier = 7
  static const int AccessibilityModifier = 7;
  /// ParameterPropertyModifier = 31
  static const int ParameterPropertyModifier = 31;
  /// NonPublicAccessibilityModifier = 6
  static const int NonPublicAccessibilityModifier = 6;
  /// TypeScriptModifier = 28895
  static const int TypeScriptModifier = 28895;
  /// ExportDefault = 2080
  static const int ExportDefault = 2080;
  /// All = 131071
  static const int All = 131071;
  /// Modifier = 98303
  static const int Modifier = 98303;

  const ModifierFlags._();
}

/// enum JsxFlags
class JsxFlags {
  /// None = 0
  static const int None = 0;
  /// IntrinsicNamedElement = 1
  static const int IntrinsicNamedElement = 1;
  /// IntrinsicIndexedElement = 2
  static const int IntrinsicIndexedElement = 2;
  /// IntrinsicElement = 3
  static const int IntrinsicElement = 3;

  const JsxFlags._();
}

/// enum GeneratedIdentifierFlags
class GeneratedIdentifierFlags {
  /// None = 0
  static const int None = 0;
  /// ReservedInNestedScopes = 8
  static const int ReservedInNestedScopes = 8;
  /// Optimistic = 16
  static const int Optimistic = 16;
  /// FileLevel = 32
  static const int FileLevel = 32;
  /// AllowNameSubstitution = 64
  static const int AllowNameSubstitution = 64;

  const GeneratedIdentifierFlags._();
}

/// enum TokenFlags
class TokenFlags {
  /// None = 0
  static const int None = 0;
  /// Scientific = 16
  static const int Scientific = 16;
  /// Octal = 32
  static const int Octal = 32;
  /// HexSpecifier = 64
  static const int HexSpecifier = 64;
  /// BinarySpecifier = 128
  static const int BinarySpecifier = 128;
  /// OctalSpecifier = 256
  static const int OctalSpecifier = 256;

  const TokenFlags._();
}

/// enum ExitStatus
class ExitStatus {
  /// Success = 0
  static const int Success = 0;
  /// DiagnosticsPresent_OutputsSkipped = 1
  static const int DiagnosticsPresent_OutputsSkipped = 1;
  /// DiagnosticsPresent_OutputsGenerated = 2
  static const int DiagnosticsPresent_OutputsGenerated = 2;
  /// InvalidProject_OutputsSkipped = 3
  static const int InvalidProject_OutputsSkipped = 3;
  /// ProjectReferenceCycle_OutputsSkipped = 4
  static const int ProjectReferenceCycle_OutputsSkipped = 4;

  const ExitStatus._();
}

/// enum NodeBuilderFlags
class NodeBuilderFlags {
  /// None = 0
  static const int None = 0;
  /// NoTruncation = 1
  static const int NoTruncation = 1;
  /// WriteArrayAsGenericType = 2
  static const int WriteArrayAsGenericType = 2;
  /// GenerateNamesForShadowedTypeParams = 4
  static const int GenerateNamesForShadowedTypeParams = 4;
  /// UseStructuralFallback = 8
  static const int UseStructuralFallback = 8;
  /// ForbidIndexedAccessSymbolReferences = 16
  static const int ForbidIndexedAccessSymbolReferences = 16;
  /// WriteTypeArgumentsOfSignature = 32
  static const int WriteTypeArgumentsOfSignature = 32;
  /// UseFullyQualifiedType = 64
  static const int UseFullyQualifiedType = 64;
  /// UseOnlyExternalAliasing = 128
  static const int UseOnlyExternalAliasing = 128;
  /// SuppressAnyReturnType = 256
  static const int SuppressAnyReturnType = 256;
  /// WriteTypeParametersInQualifiedName = 512
  static const int WriteTypeParametersInQualifiedName = 512;
  /// MultilineObjectLiterals = 1024
  static const int MultilineObjectLiterals = 1024;
  /// WriteClassExpressionAsTypeLiteral = 2048
  static const int WriteClassExpressionAsTypeLiteral = 2048;
  /// UseTypeOfFunction = 4096
  static const int UseTypeOfFunction = 4096;
  /// OmitParameterModifiers = 8192
  static const int OmitParameterModifiers = 8192;
  /// UseAliasDefinedOutsideCurrentScope = 16384
  static const int UseAliasDefinedOutsideCurrentScope = 16384;
  /// UseSingleQuotesForStringLiteralType = 268435456
  static const int UseSingleQuotesForStringLiteralType = 268435456;
  /// NoTypeReduction = 536870912
  static const int NoTypeReduction = 536870912;
  /// OmitThisParameter = 33554432
  static const int OmitThisParameter = 33554432;
  /// AllowThisInObjectLiteral = 32768
  static const int AllowThisInObjectLiteral = 32768;
  /// AllowQualifiedNameInPlaceOfIdentifier = 65536
  static const int AllowQualifiedNameInPlaceOfIdentifier = 65536;
  /// AllowAnonymousIdentifier = 131072
  static const int AllowAnonymousIdentifier = 131072;
  /// AllowEmptyUnionOrIntersection = 262144
  static const int AllowEmptyUnionOrIntersection = 262144;
  /// AllowEmptyTuple = 524288
  static const int AllowEmptyTuple = 524288;
  /// AllowUniqueESSymbolType = 1048576
  static const int AllowUniqueESSymbolType = 1048576;
  /// AllowEmptyIndexInfoType = 2097152
  static const int AllowEmptyIndexInfoType = 2097152;
  /// AllowNodeModulesRelativePaths = 67108864
  static const int AllowNodeModulesRelativePaths = 67108864;
  /// IgnoreErrors = 70221824
  static const int IgnoreErrors = 70221824;
  /// InObjectTypeLiteral = 4194304
  static const int InObjectTypeLiteral = 4194304;
  /// InTypeAlias = 8388608
  static const int InTypeAlias = 8388608;
  /// InInitialEntityName = 16777216
  static const int InInitialEntityName = 16777216;

  const NodeBuilderFlags._();
}

/// enum TypeFormatFlags
class TypeFormatFlags {
  /// None = 0
  static const int None = 0;
  /// NoTruncation = 1
  static const int NoTruncation = 1;
  /// WriteArrayAsGenericType = 2
  static const int WriteArrayAsGenericType = 2;
  /// GenerateNamesForShadowedTypeParams = 4
  static const int GenerateNamesForShadowedTypeParams = 4;
  /// UseStructuralFallback = 8
  static const int UseStructuralFallback = 8;
  /// WriteTypeArgumentsOfSignature = 32
  static const int WriteTypeArgumentsOfSignature = 32;
  /// UseFullyQualifiedType = 64
  static const int UseFullyQualifiedType = 64;
  /// SuppressAnyReturnType = 256
  static const int SuppressAnyReturnType = 256;
  /// MultilineObjectLiterals = 1024
  static const int MultilineObjectLiterals = 1024;
  /// WriteClassExpressionAsTypeLiteral = 2048
  static const int WriteClassExpressionAsTypeLiteral = 2048;
  /// UseTypeOfFunction = 4096
  static const int UseTypeOfFunction = 4096;
  /// OmitParameterModifiers = 8192
  static const int OmitParameterModifiers = 8192;
  /// UseAliasDefinedOutsideCurrentScope = 16384
  static const int UseAliasDefinedOutsideCurrentScope = 16384;
  /// UseSingleQuotesForStringLiteralType = 268435456
  static const int UseSingleQuotesForStringLiteralType = 268435456;
  /// NoTypeReduction = 536870912
  static const int NoTypeReduction = 536870912;
  /// OmitThisParameter = 33554432
  static const int OmitThisParameter = 33554432;
  /// AllowUniqueESSymbolType = 1048576
  static const int AllowUniqueESSymbolType = 1048576;
  /// AddUndefined = 131072
  static const int AddUndefined = 131072;
  /// WriteArrowStyleSignature = 262144
  static const int WriteArrowStyleSignature = 262144;
  /// InArrayType = 524288
  static const int InArrayType = 524288;
  /// InElementType = 2097152
  static const int InElementType = 2097152;
  /// InFirstTypeArgument = 4194304
  static const int InFirstTypeArgument = 4194304;
  /// InTypeAlias = 8388608
  static const int InTypeAlias = 8388608;
  /// NodeBuilderFlagsMask = 848330095
  static const int NodeBuilderFlagsMask = 848330095;

  const TypeFormatFlags._();
}

/// enum SymbolFormatFlags
class SymbolFormatFlags {
  /// None = 0
  static const int None = 0;
  /// WriteTypeParametersOrArguments = 1
  static const int WriteTypeParametersOrArguments = 1;
  /// UseOnlyExternalAliasing = 2
  static const int UseOnlyExternalAliasing = 2;
  /// AllowAnyNodeKind = 4
  static const int AllowAnyNodeKind = 4;
  /// UseAliasDefinedOutsideCurrentScope = 8
  static const int UseAliasDefinedOutsideCurrentScope = 8;

  const SymbolFormatFlags._();
}

/// enum TypePredicateKind
class TypePredicateKind {
  /// This = 0
  static const int This = 0;
  /// Identifier = 1
  static const int Identifier = 1;
  /// AssertsThis = 2
  static const int AssertsThis = 2;
  /// AssertsIdentifier = 3
  static const int AssertsIdentifier = 3;

  const TypePredicateKind._();
}

/// enum SymbolFlags
class SymbolFlags {
  /// None = 0
  static const int None = 0;
  /// FunctionScopedVariable = 1
  static const int FunctionScopedVariable = 1;
  /// BlockScopedVariable = 2
  static const int BlockScopedVariable = 2;
  /// Property = 4
  static const int Property = 4;
  /// EnumMember = 8
  static const int EnumMember = 8;
  /// Function = 16
  static const int Function = 16;
  /// Class = 32
  static const int Class = 32;
  /// Interface = 64
  static const int Interface = 64;
  /// ConstEnum = 128
  static const int ConstEnum = 128;
  /// RegularEnum = 256
  static const int RegularEnum = 256;
  /// ValueModule = 512
  static const int ValueModule = 512;
  /// NamespaceModule = 1024
  static const int NamespaceModule = 1024;
  /// TypeLiteral = 2048
  static const int TypeLiteral = 2048;
  /// ObjectLiteral = 4096
  static const int ObjectLiteral = 4096;
  /// Method = 8192
  static const int Method = 8192;
  /// Constructor = 16384
  static const int Constructor = 16384;
  /// GetAccessor = 32768
  static const int GetAccessor = 32768;
  /// SetAccessor = 65536
  static const int SetAccessor = 65536;
  /// Signature = 131072
  static const int Signature = 131072;
  /// TypeParameter = 262144
  static const int TypeParameter = 262144;
  /// TypeAlias = 524288
  static const int TypeAlias = 524288;
  /// ExportValue = 1048576
  static const int ExportValue = 1048576;
  /// Alias = 2097152
  static const int Alias = 2097152;
  /// Prototype = 4194304
  static const int Prototype = 4194304;
  /// ExportStar = 8388608
  static const int ExportStar = 8388608;
  /// Optional = 16777216
  static const int Optional = 16777216;
  /// Transient = 33554432
  static const int Transient = 33554432;
  /// Assignment = 67108864
  static const int Assignment = 67108864;
  /// ModuleExports = 134217728
  static const int ModuleExports = 134217728;
  /// All = -1
  static const int All = -1;
  /// Enum = 384
  static const int Enum = 384;
  /// Variable = 3
  static const int Variable = 3;
  /// Value = 111551
  static const int Value = 111551;
  /// Type = 788968
  static const int Type = 788968;
  /// Namespace = 1920
  static const int Namespace = 1920;
  /// Module = 1536
  static const int Module = 1536;
  /// Accessor = 98304
  static const int Accessor = 98304;
  /// FunctionScopedVariableExcludes = 111550
  static const int FunctionScopedVariableExcludes = 111550;
  /// BlockScopedVariableExcludes = 111551
  static const int BlockScopedVariableExcludes = 111551;
  /// ParameterExcludes = 111551
  static const int ParameterExcludes = 111551;
  /// PropertyExcludes = 0
  static const int PropertyExcludes = 0;
  /// EnumMemberExcludes = 900095
  static const int EnumMemberExcludes = 900095;
  /// FunctionExcludes = 110991
  static const int FunctionExcludes = 110991;
  /// ClassExcludes = 899503
  static const int ClassExcludes = 899503;
  /// InterfaceExcludes = 788872
  static const int InterfaceExcludes = 788872;
  /// RegularEnumExcludes = 899327
  static const int RegularEnumExcludes = 899327;
  /// ConstEnumExcludes = 899967
  static const int ConstEnumExcludes = 899967;
  /// ValueModuleExcludes = 110735
  static const int ValueModuleExcludes = 110735;
  /// NamespaceModuleExcludes = 0
  static const int NamespaceModuleExcludes = 0;
  /// MethodExcludes = 103359
  static const int MethodExcludes = 103359;
  /// GetAccessorExcludes = 46015
  static const int GetAccessorExcludes = 46015;
  /// SetAccessorExcludes = 78783
  static const int SetAccessorExcludes = 78783;
  /// AccessorExcludes = 13247
  static const int AccessorExcludes = 13247;
  /// TypeParameterExcludes = 526824
  static const int TypeParameterExcludes = 526824;
  /// TypeAliasExcludes = 788968
  static const int TypeAliasExcludes = 788968;
  /// AliasExcludes = 2097152
  static const int AliasExcludes = 2097152;
  /// ModuleMember = 2623475
  static const int ModuleMember = 2623475;
  /// ExportHasLocal = 944
  static const int ExportHasLocal = 944;
  /// BlockScoped = 418
  static const int BlockScoped = 418;
  /// PropertyOrAccessor = 98308
  static const int PropertyOrAccessor = 98308;
  /// ClassMember = 106500
  static const int ClassMember = 106500;

  const SymbolFlags._();
}

/// enum InternalSymbolName
class InternalSymbolName {
  /// Call = __call
  static const String Call = '__call';
  /// Constructor = __constructor
  static const String Constructor = '__constructor';
  /// New = __new
  static const String New = '__new';
  /// Index = __index
  static const String Index = '__index';
  /// ExportStar = __export
  static const String ExportStar = '__export';
  /// Global = __global
  static const String Global = '__global';
  /// Missing = __missing
  static const String Missing = '__missing';
  /// Type = __type
  static const String Type = '__type';
  /// Object = __object
  static const String Object = '__object';
  /// JSXAttributes = __jsxAttributes
  static const String JSXAttributes = '__jsxAttributes';
  /// Class = __class
  static const String Class = '__class';
  /// Function = __function
  static const String Function = '__function';
  /// Computed = __computed
  static const String Computed = '__computed';
  /// Resolving = __resolving__
  static const String Resolving = '__resolving__';
  /// ExportEquals = export=
  static const String ExportEquals = 'export=';
  /// Default = default
  static const String Default = 'default';
  /// This = this
  static const String This = 'this';
  /// InstantiationExpression = __instantiationExpression
  static const String InstantiationExpression = '__instantiationExpression';
  /// ImportAttributes = __importAttributes
  static const String ImportAttributes = '__importAttributes';

  const InternalSymbolName._();
}

/// enum TypeFlags
class TypeFlags {
  /// Any = 1
  static const int Any = 1;
  /// Unknown = 2
  static const int Unknown = 2;
  /// String = 4
  static const int String = 4;
  /// Number = 8
  static const int Number = 8;
  /// Boolean = 16
  static const int Boolean = 16;
  /// Enum = 32
  static const int Enum = 32;
  /// BigInt = 64
  static const int BigInt = 64;
  /// StringLiteral = 128
  static const int StringLiteral = 128;
  /// NumberLiteral = 256
  static const int NumberLiteral = 256;
  /// BooleanLiteral = 512
  static const int BooleanLiteral = 512;
  /// EnumLiteral = 1024
  static const int EnumLiteral = 1024;
  /// BigIntLiteral = 2048
  static const int BigIntLiteral = 2048;
  /// ESSymbol = 4096
  static const int ESSymbol = 4096;
  /// UniqueESSymbol = 8192
  static const int UniqueESSymbol = 8192;
  /// Void = 16384
  static const int Void = 16384;
  /// Undefined = 32768
  static const int Undefined = 32768;
  /// Null = 65536
  static const int Null = 65536;
  /// Never = 131072
  static const int Never = 131072;
  /// TypeParameter = 262144
  static const int TypeParameter = 262144;
  /// Object = 524288
  static const int Object = 524288;
  /// Union = 1048576
  static const int Union = 1048576;
  /// Intersection = 2097152
  static const int Intersection = 2097152;
  /// Index = 4194304
  static const int Index = 4194304;
  /// IndexedAccess = 8388608
  static const int IndexedAccess = 8388608;
  /// Conditional = 16777216
  static const int Conditional = 16777216;
  /// Substitution = 33554432
  static const int Substitution = 33554432;
  /// NonPrimitive = 67108864
  static const int NonPrimitive = 67108864;
  /// TemplateLiteral = 134217728
  static const int TemplateLiteral = 134217728;
  /// StringMapping = 268435456
  static const int StringMapping = 268435456;
  /// Literal = 2944
  static const int Literal = 2944;
  /// Unit = 109472
  static const int Unit = 109472;
  /// Freshable = 2976
  static const int Freshable = 2976;
  /// StringOrNumberLiteral = 384
  static const int StringOrNumberLiteral = 384;
  /// PossiblyFalsy = 117724
  static const int PossiblyFalsy = 117724;
  /// StringLike = 402653316
  static const int StringLike = 402653316;
  /// NumberLike = 296
  static const int NumberLike = 296;
  /// BigIntLike = 2112
  static const int BigIntLike = 2112;
  /// BooleanLike = 528
  static const int BooleanLike = 528;
  /// EnumLike = 1056
  static const int EnumLike = 1056;
  /// ESSymbolLike = 12288
  static const int ESSymbolLike = 12288;
  /// VoidLike = 49152
  static const int VoidLike = 49152;
  /// UnionOrIntersection = 3145728
  static const int UnionOrIntersection = 3145728;
  /// StructuredType = 3670016
  static const int StructuredType = 3670016;
  /// TypeVariable = 8650752
  static const int TypeVariable = 8650752;
  /// InstantiableNonPrimitive = 58982400
  static const int InstantiableNonPrimitive = 58982400;
  /// InstantiablePrimitive = 406847488
  static const int InstantiablePrimitive = 406847488;
  /// Instantiable = 465829888
  static const int Instantiable = 465829888;
  /// StructuredOrInstantiable = 469499904
  static const int StructuredOrInstantiable = 469499904;
  /// Narrowable = 536624127
  static const int Narrowable = 536624127;

  const TypeFlags._();
}

/// enum ObjectFlags
class ObjectFlags {
  /// None = 0
  static const int None = 0;
  /// Class = 1
  static const int Class = 1;
  /// Interface = 2
  static const int Interface = 2;
  /// Reference = 4
  static const int Reference = 4;
  /// Tuple = 8
  static const int Tuple = 8;
  /// Anonymous = 16
  static const int Anonymous = 16;
  /// Mapped = 32
  static const int Mapped = 32;
  /// Instantiated = 64
  static const int Instantiated = 64;
  /// ObjectLiteral = 128
  static const int ObjectLiteral = 128;
  /// EvolvingArray = 256
  static const int EvolvingArray = 256;
  /// ObjectLiteralPatternWithComputedProperties = 512
  static const int ObjectLiteralPatternWithComputedProperties = 512;
  /// ReverseMapped = 1024
  static const int ReverseMapped = 1024;
  /// JsxAttributes = 2048
  static const int JsxAttributes = 2048;
  /// JSLiteral = 4096
  static const int JSLiteral = 4096;
  /// FreshLiteral = 8192
  static const int FreshLiteral = 8192;
  /// ArrayLiteral = 16384
  static const int ArrayLiteral = 16384;
  /// SingleSignatureType = 134217728
  static const int SingleSignatureType = 134217728;
  /// ClassOrInterface = 3
  static const int ClassOrInterface = 3;
  /// ContainsSpread = 2097152
  static const int ContainsSpread = 2097152;
  /// ObjectRestType = 4194304
  static const int ObjectRestType = 4194304;
  /// InstantiationExpressionType = 8388608
  static const int InstantiationExpressionType = 8388608;

  const ObjectFlags._();
}

/// enum ElementFlags
class ElementFlags {
  /// Required = 1
  static const int Required = 1;
  /// Optional = 2
  static const int Optional = 2;
  /// Rest = 4
  static const int Rest = 4;
  /// Variadic = 8
  static const int Variadic = 8;
  /// Fixed = 3
  static const int Fixed = 3;
  /// Variable = 12
  static const int Variable = 12;
  /// NonRequired = 14
  static const int NonRequired = 14;
  /// NonRest = 11
  static const int NonRest = 11;

  const ElementFlags._();
}

/// enum SignatureKind
class SignatureKind {
  /// Call = 0
  static const int Call = 0;
  /// Construct = 1
  static const int Construct = 1;

  const SignatureKind._();
}

/// enum IndexKind
class IndexKind {
  /// String = 0
  static const int String = 0;
  /// Number = 1
  static const int Number = 1;

  const IndexKind._();
}

/// enum InferencePriority
class InferencePriority {
  /// None = 0
  static const int None = 0;
  /// NakedTypeVariable = 1
  static const int NakedTypeVariable = 1;
  /// SpeculativeTuple = 2
  static const int SpeculativeTuple = 2;
  /// SubstituteSource = 4
  static const int SubstituteSource = 4;
  /// HomomorphicMappedType = 8
  static const int HomomorphicMappedType = 8;
  /// PartialHomomorphicMappedType = 16
  static const int PartialHomomorphicMappedType = 16;
  /// MappedTypeConstraint = 32
  static const int MappedTypeConstraint = 32;
  /// ContravariantConditional = 64
  static const int ContravariantConditional = 64;
  /// ReturnType = 128
  static const int ReturnType = 128;
  /// LiteralKeyof = 256
  static const int LiteralKeyof = 256;
  /// NoConstraints = 512
  static const int NoConstraints = 512;
  /// AlwaysStrict = 1024
  static const int AlwaysStrict = 1024;
  /// MaxValue = 2048
  static const int MaxValue = 2048;
  /// PriorityImpliesCombination = 416
  static const int PriorityImpliesCombination = 416;
  /// Circularity = -1
  static const int Circularity = -1;

  const InferencePriority._();
}

/// enum DiagnosticCategory
class DiagnosticCategory {
  /// Warning = 0
  static const int Warning = 0;
  /// Error = 1
  static const int Error = 1;
  /// Suggestion = 2
  static const int Suggestion = 2;
  /// Message = 3
  static const int Message = 3;

  const DiagnosticCategory._();
}

/// enum ModuleResolutionKind
class ModuleResolutionKind {
  /// Classic = 1
  static const int Classic = 1;
  /// NodeJs = 2
  static const int NodeJs = 2;
  /// Node10 = 2
  static const int Node10 = 2;
  /// Node16 = 3
  static const int Node16 = 3;
  /// NodeNext = 99
  static const int NodeNext = 99;
  /// Bundler = 100
  static const int Bundler = 100;

  const ModuleResolutionKind._();
}

/// enum ModuleDetectionKind
class ModuleDetectionKind {
  /// Legacy = 1
  static const int Legacy = 1;
  /// Auto = 2
  static const int Auto = 2;
  /// Force = 3
  static const int Force = 3;

  const ModuleDetectionKind._();
}

/// enum WatchFileKind
class WatchFileKind {
  /// FixedPollingInterval = 0
  static const int FixedPollingInterval = 0;
  /// PriorityPollingInterval = 1
  static const int PriorityPollingInterval = 1;
  /// DynamicPriorityPolling = 2
  static const int DynamicPriorityPolling = 2;
  /// FixedChunkSizePolling = 3
  static const int FixedChunkSizePolling = 3;
  /// UseFsEvents = 4
  static const int UseFsEvents = 4;
  /// UseFsEventsOnParentDirectory = 5
  static const int UseFsEventsOnParentDirectory = 5;

  const WatchFileKind._();
}

/// enum WatchDirectoryKind
class WatchDirectoryKind {
  /// UseFsEvents = 0
  static const int UseFsEvents = 0;
  /// FixedPollingInterval = 1
  static const int FixedPollingInterval = 1;
  /// DynamicPriorityPolling = 2
  static const int DynamicPriorityPolling = 2;
  /// FixedChunkSizePolling = 3
  static const int FixedChunkSizePolling = 3;

  const WatchDirectoryKind._();
}

/// enum PollingWatchKind
class PollingWatchKind {
  /// FixedInterval = 0
  static const int FixedInterval = 0;
  /// PriorityInterval = 1
  static const int PriorityInterval = 1;
  /// DynamicPriority = 2
  static const int DynamicPriority = 2;
  /// FixedChunkSize = 3
  static const int FixedChunkSize = 3;

  const PollingWatchKind._();
}

/// enum ModuleKind
class ModuleKind {
  /// None = 0
  static const int None = 0;
  /// CommonJS = 1
  static const int CommonJS = 1;
  /// AMD = 2
  static const int AMD = 2;
  /// UMD = 3
  static const int UMD = 3;
  /// System = 4
  static const int System = 4;
  /// ES2015 = 5
  static const int ES2015 = 5;
  /// ES2020 = 6
  static const int ES2020 = 6;
  /// ES2022 = 7
  static const int ES2022 = 7;
  /// ESNext = 99
  static const int ESNext = 99;
  /// Node16 = 100
  static const int Node16 = 100;
  /// Node18 = 101
  static const int Node18 = 101;
  /// Node20 = 102
  static const int Node20 = 102;
  /// NodeNext = 199
  static const int NodeNext = 199;
  /// Preserve = 200
  static const int Preserve = 200;

  const ModuleKind._();
}

/// enum JsxEmit
class JsxEmit {
  /// None = 0
  static const int None = 0;
  /// Preserve = 1
  static const int Preserve = 1;
  /// React = 2
  static const int React = 2;
  /// ReactNative = 3
  static const int ReactNative = 3;
  /// ReactJSX = 4
  static const int ReactJSX = 4;
  /// ReactJSXDev = 5
  static const int ReactJSXDev = 5;

  const JsxEmit._();
}

/// enum ImportsNotUsedAsValues
class ImportsNotUsedAsValues {
  /// Remove = 0
  static const int Remove = 0;
  /// Preserve = 1
  static const int Preserve = 1;
  /// Error = 2
  static const int Error = 2;

  const ImportsNotUsedAsValues._();
}

/// enum NewLineKind
class NewLineKind {
  /// CarriageReturnLineFeed = 0
  static const int CarriageReturnLineFeed = 0;
  /// LineFeed = 1
  static const int LineFeed = 1;

  const NewLineKind._();
}

/// enum ScriptKind
class ScriptKind {
  /// Unknown = 0
  static const int Unknown = 0;
  /// JS = 1
  static const int JS = 1;
  /// JSX = 2
  static const int JSX = 2;
  /// TS = 3
  static const int TS = 3;
  /// TSX = 4
  static const int TSX = 4;
  /// External = 5
  static const int External = 5;
  /// JSON = 6
  static const int JSON = 6;
  /// Deferred = 7
  static const int Deferred = 7;

  const ScriptKind._();
}

/// enum ScriptTarget
class ScriptTarget {
  /// ES3 = 0
  static const int ES3 = 0;
  /// ES5 = 1
  static const int ES5 = 1;
  /// ES2015 = 2
  static const int ES2015 = 2;
  /// ES2016 = 3
  static const int ES2016 = 3;
  /// ES2017 = 4
  static const int ES2017 = 4;
  /// ES2018 = 5
  static const int ES2018 = 5;
  /// ES2019 = 6
  static const int ES2019 = 6;
  /// ES2020 = 7
  static const int ES2020 = 7;
  /// ES2021 = 8
  static const int ES2021 = 8;
  /// ES2022 = 9
  static const int ES2022 = 9;
  /// ES2023 = 10
  static const int ES2023 = 10;
  /// ES2024 = 11
  static const int ES2024 = 11;
  /// ESNext = 99
  static const int ESNext = 99;
  /// JSON = 100
  static const int JSON = 100;
  /// Latest = 99
  static const int Latest = 99;

  const ScriptTarget._();
}

/// enum LanguageVariant
class LanguageVariant {
  /// Standard = 0
  static const int Standard = 0;
  /// JSX = 1
  static const int JSX = 1;

  const LanguageVariant._();
}

/// enum WatchDirectoryFlags
class WatchDirectoryFlags {
  /// None = 0
  static const int None = 0;
  /// Recursive = 1
  static const int Recursive = 1;

  const WatchDirectoryFlags._();
}

/// enum Extension
class Extension {
  /// Ts = .ts
  static const String Ts = '.ts';
  /// Tsx = .tsx
  static const String Tsx = '.tsx';
  /// Dts = .d.ts
  static const String Dts = '.d.ts';
  /// Js = .js
  static const String Js = '.js';
  /// Jsx = .jsx
  static const String Jsx = '.jsx';
  /// Json = .json
  static const String Json = '.json';
  /// TsBuildInfo = .tsbuildinfo
  static const String TsBuildInfo = '.tsbuildinfo';
  /// Mjs = .mjs
  static const String Mjs = '.mjs';
  /// Mts = .mts
  static const String Mts = '.mts';
  /// Dmts = .d.mts
  static const String Dmts = '.d.mts';
  /// Cjs = .cjs
  static const String Cjs = '.cjs';
  /// Cts = .cts
  static const String Cts = '.cts';
  /// Dcts = .d.cts
  static const String Dcts = '.d.cts';

  const Extension._();
}

/// enum EmitFlags
class EmitFlags {
  /// None = 0
  static const int None = 0;
  /// SingleLine = 1
  static const int SingleLine = 1;
  /// MultiLine = 2
  static const int MultiLine = 2;
  /// AdviseOnEmitNode = 4
  static const int AdviseOnEmitNode = 4;
  /// NoSubstitution = 8
  static const int NoSubstitution = 8;
  /// CapturesThis = 16
  static const int CapturesThis = 16;
  /// NoLeadingSourceMap = 32
  static const int NoLeadingSourceMap = 32;
  /// NoTrailingSourceMap = 64
  static const int NoTrailingSourceMap = 64;
  /// NoSourceMap = 96
  static const int NoSourceMap = 96;
  /// NoNestedSourceMaps = 128
  static const int NoNestedSourceMaps = 128;
  /// NoTokenLeadingSourceMaps = 256
  static const int NoTokenLeadingSourceMaps = 256;
  /// NoTokenTrailingSourceMaps = 512
  static const int NoTokenTrailingSourceMaps = 512;
  /// NoTokenSourceMaps = 768
  static const int NoTokenSourceMaps = 768;
  /// NoLeadingComments = 1024
  static const int NoLeadingComments = 1024;
  /// NoTrailingComments = 2048
  static const int NoTrailingComments = 2048;
  /// NoComments = 3072
  static const int NoComments = 3072;
  /// NoNestedComments = 4096
  static const int NoNestedComments = 4096;
  /// HelperName = 8192
  static const int HelperName = 8192;
  /// ExportName = 16384
  static const int ExportName = 16384;
  /// LocalName = 32768
  static const int LocalName = 32768;
  /// InternalName = 65536
  static const int InternalName = 65536;
  /// Indented = 131072
  static const int Indented = 131072;
  /// NoIndentation = 262144
  static const int NoIndentation = 262144;
  /// AsyncFunctionBody = 524288
  static const int AsyncFunctionBody = 524288;
  /// ReuseTempVariableScope = 1048576
  static const int ReuseTempVariableScope = 1048576;
  /// CustomPrologue = 2097152
  static const int CustomPrologue = 2097152;
  /// NoHoisting = 4194304
  static const int NoHoisting = 4194304;
  /// Iterator = 8388608
  static const int Iterator = 8388608;
  /// NoAsciiEscaping = 16777216
  static const int NoAsciiEscaping = 16777216;

  const EmitFlags._();
}

/// enum EmitHint
class EmitHint {
  /// SourceFile = 0
  static const int SourceFile = 0;
  /// Expression = 1
  static const int Expression = 1;
  /// IdentifierName = 2
  static const int IdentifierName = 2;
  /// MappedTypeParameter = 3
  static const int MappedTypeParameter = 3;
  /// Unspecified = 4
  static const int Unspecified = 4;
  /// EmbeddedStatement = 5
  static const int EmbeddedStatement = 5;
  /// JsxAttributeValue = 6
  static const int JsxAttributeValue = 6;
  /// ImportTypeNodeAttributes = 7
  static const int ImportTypeNodeAttributes = 7;

  const EmitHint._();
}

/// enum OuterExpressionKinds
class OuterExpressionKinds {
  /// Parentheses = 1
  static const int Parentheses = 1;
  /// TypeAssertions = 2
  static const int TypeAssertions = 2;
  /// NonNullAssertions = 4
  static const int NonNullAssertions = 4;
  /// PartiallyEmittedExpressions = 8
  static const int PartiallyEmittedExpressions = 8;
  /// ExpressionsWithTypeArguments = 16
  static const int ExpressionsWithTypeArguments = 16;
  /// Satisfies = 32
  static const int Satisfies = 32;
  /// Assertions = 38
  static const int Assertions = 38;
  /// All = 63
  static const int All = 63;
  /// ExcludeJSDocTypeAssertion = -2147483648
  static const int ExcludeJSDocTypeAssertion = -2147483648;

  const OuterExpressionKinds._();
}

/// enum ListFormat
class ListFormat {
  /// None = 0
  static const int None = 0;
  /// SingleLine = 0
  static const int SingleLine = 0;
  /// MultiLine = 1
  static const int MultiLine = 1;
  /// PreserveLines = 2
  static const int PreserveLines = 2;
  /// LinesMask = 3
  static const int LinesMask = 3;
  /// NotDelimited = 0
  static const int NotDelimited = 0;
  /// BarDelimited = 4
  static const int BarDelimited = 4;
  /// AmpersandDelimited = 8
  static const int AmpersandDelimited = 8;
  /// CommaDelimited = 16
  static const int CommaDelimited = 16;
  /// AsteriskDelimited = 32
  static const int AsteriskDelimited = 32;
  /// DelimitersMask = 60
  static const int DelimitersMask = 60;
  /// AllowTrailingComma = 64
  static const int AllowTrailingComma = 64;
  /// Indented = 128
  static const int Indented = 128;
  /// SpaceBetweenBraces = 256
  static const int SpaceBetweenBraces = 256;
  /// SpaceBetweenSiblings = 512
  static const int SpaceBetweenSiblings = 512;
  /// Braces = 1024
  static const int Braces = 1024;
  /// Parenthesis = 2048
  static const int Parenthesis = 2048;
  /// AngleBrackets = 4096
  static const int AngleBrackets = 4096;
  /// SquareBrackets = 8192
  static const int SquareBrackets = 8192;
  /// BracketsMask = 15360
  static const int BracketsMask = 15360;
  /// OptionalIfUndefined = 16384
  static const int OptionalIfUndefined = 16384;
  /// OptionalIfEmpty = 32768
  static const int OptionalIfEmpty = 32768;
  /// Optional = 49152
  static const int Optional = 49152;
  /// PreferNewLine = 65536
  static const int PreferNewLine = 65536;
  /// NoTrailingNewLine = 131072
  static const int NoTrailingNewLine = 131072;
  /// NoInterveningComments = 262144
  static const int NoInterveningComments = 262144;
  /// NoSpaceIfEmpty = 524288
  static const int NoSpaceIfEmpty = 524288;
  /// SingleElement = 1048576
  static const int SingleElement = 1048576;
  /// SpaceAfterList = 2097152
  static const int SpaceAfterList = 2097152;
  /// Modifiers = 2359808
  static const int Modifiers = 2359808;
  /// HeritageClauses = 512
  static const int HeritageClauses = 512;
  /// SingleLineTypeLiteralMembers = 768
  static const int SingleLineTypeLiteralMembers = 768;
  /// MultiLineTypeLiteralMembers = 32897
  static const int MultiLineTypeLiteralMembers = 32897;
  /// SingleLineTupleTypeElements = 528
  static const int SingleLineTupleTypeElements = 528;
  /// MultiLineTupleTypeElements = 657
  static const int MultiLineTupleTypeElements = 657;
  /// UnionTypeConstituents = 516
  static const int UnionTypeConstituents = 516;
  /// IntersectionTypeConstituents = 520
  static const int IntersectionTypeConstituents = 520;
  /// ObjectBindingPatternElements = 525136
  static const int ObjectBindingPatternElements = 525136;
  /// ArrayBindingPatternElements = 524880
  static const int ArrayBindingPatternElements = 524880;
  /// ObjectLiteralExpressionProperties = 526226
  static const int ObjectLiteralExpressionProperties = 526226;
  /// ImportAttributes = 526226
  static const int ImportAttributes = 526226;
  /// ImportClauseEntries = 526226
  static const int ImportClauseEntries = 526226;
  /// ArrayLiteralExpressionElements = 8914
  static const int ArrayLiteralExpressionElements = 8914;
  /// CommaListElements = 528
  static const int CommaListElements = 528;
  /// CallExpressionArguments = 2576
  static const int CallExpressionArguments = 2576;
  /// NewExpressionArguments = 18960
  static const int NewExpressionArguments = 18960;
  /// TemplateExpressionSpans = 262144
  static const int TemplateExpressionSpans = 262144;
  /// SingleLineBlockStatements = 768
  static const int SingleLineBlockStatements = 768;
  /// MultiLineBlockStatements = 129
  static const int MultiLineBlockStatements = 129;
  /// VariableDeclarationList = 528
  static const int VariableDeclarationList = 528;
  /// SingleLineFunctionBodyStatements = 768
  static const int SingleLineFunctionBodyStatements = 768;
  /// MultiLineFunctionBodyStatements = 1
  static const int MultiLineFunctionBodyStatements = 1;
  /// ClassHeritageClauses = 0
  static const int ClassHeritageClauses = 0;
  /// ClassMembers = 129
  static const int ClassMembers = 129;
  /// InterfaceMembers = 129
  static const int InterfaceMembers = 129;
  /// EnumMembers = 145
  static const int EnumMembers = 145;
  /// CaseBlockClauses = 129
  static const int CaseBlockClauses = 129;
  /// NamedImportsOrExportsElements = 525136
  static const int NamedImportsOrExportsElements = 525136;
  /// JsxElementOrFragmentChildren = 262144
  static const int JsxElementOrFragmentChildren = 262144;
  /// JsxElementAttributes = 262656
  static const int JsxElementAttributes = 262656;
  /// CaseOrDefaultClauseStatements = 163969
  static const int CaseOrDefaultClauseStatements = 163969;
  /// HeritageClauseTypes = 528
  static const int HeritageClauseTypes = 528;
  /// SourceFileStatements = 131073
  static const int SourceFileStatements = 131073;
  /// Decorators = 2146305
  static const int Decorators = 2146305;
  /// TypeArguments = 53776
  static const int TypeArguments = 53776;
  /// TypeParameters = 53776
  static const int TypeParameters = 53776;
  /// Parameters = 2576
  static const int Parameters = 2576;
  /// IndexSignatureParameters = 8848
  static const int IndexSignatureParameters = 8848;
  /// JSDocComment = 33
  static const int JSDocComment = 33;

  const ListFormat._();
}

/// enum JSDocParsingMode
class JSDocParsingMode {
  /// ParseAll = 0
  static const int ParseAll = 0;
  /// ParseNone = 1
  static const int ParseNone = 1;
  /// ParseForTypeErrors = 2
  static const int ParseForTypeErrors = 2;
  /// ParseForTypeInfo = 3
  static const int ParseForTypeInfo = 3;

  const JSDocParsingMode._();
}

/// enum FileWatcherEventKind
class FileWatcherEventKind {
  /// Created = 0
  static const int Created = 0;
  /// Changed = 1
  static const int Changed = 1;
  /// Deleted = 2
  static const int Deleted = 2;

  const FileWatcherEventKind._();
}

/// enum ProgramUpdateLevel
class ProgramUpdateLevel {
  /// Update = 0
  static const int Update = 0;
  /// RootNamesAndUpdate = 1
  static const int RootNamesAndUpdate = 1;
  /// Full = 2
  static const int Full = 2;

  const ProgramUpdateLevel._();
}

/// enum InvalidatedProjectKind
class InvalidatedProjectKind {
  /// Build = 0
  static const int Build = 0;
  /// UpdateOutputFileStamps = 1
  static const int UpdateOutputFileStamps = 1;

  const InvalidatedProjectKind._();
}

/// enum LanguageServiceMode
class LanguageServiceMode {
  /// Semantic = 0
  static const int Semantic = 0;
  /// PartialSemantic = 1
  static const int PartialSemantic = 1;
  /// Syntactic = 2
  static const int Syntactic = 2;

  const LanguageServiceMode._();
}

/// enum SemanticClassificationFormat
class SemanticClassificationFormat {
  /// Original = original
  static const String Original = 'original';
  /// TwentyTwenty = 2020
  static const String TwentyTwenty = '2020';

  const SemanticClassificationFormat._();
}

/// enum OrganizeImportsMode
class OrganizeImportsMode {
  /// All = All
  static const String All = 'All';
  /// SortAndCombine = SortAndCombine
  static const String SortAndCombine = 'SortAndCombine';
  /// RemoveUnused = RemoveUnused
  static const String RemoveUnused = 'RemoveUnused';

  const OrganizeImportsMode._();
}

/// enum CompletionTriggerKind
class CompletionTriggerKind {
  /// Invoked = 1
  static const int Invoked = 1;
  /// TriggerCharacter = 2
  static const int TriggerCharacter = 2;
  /// TriggerForIncompleteCompletions = 3
  static const int TriggerForIncompleteCompletions = 3;

  const CompletionTriggerKind._();
}

/// enum InlayHintKind
class InlayHintKind {
  /// Type = Type
  static const String Type = 'Type';
  /// Parameter = Parameter
  static const String Parameter = 'Parameter';
  /// Enum = Enum
  static const String Enum = 'Enum';

  const InlayHintKind._();
}

/// enum HighlightSpanKind
class HighlightSpanKind {
  /// none = none
  static const String none = 'none';
  /// definition = definition
  static const String definition = 'definition';
  /// reference = reference
  static const String reference = 'reference';
  /// writtenReference = writtenReference
  static const String writtenReference = 'writtenReference';

  const HighlightSpanKind._();
}

/// enum IndentStyle
class IndentStyle {
  /// None = 0
  static const int None = 0;
  /// Block = 1
  static const int Block = 1;
  /// Smart = 2
  static const int Smart = 2;

  const IndentStyle._();
}

/// enum SemicolonPreference
class SemicolonPreference {
  /// Ignore = ignore
  static const String Ignore = 'ignore';
  /// Insert = insert
  static const String Insert = 'insert';
  /// Remove = remove
  static const String Remove = 'remove';

  const SemicolonPreference._();
}

/// enum SymbolDisplayPartKind
class SymbolDisplayPartKind {
  /// aliasName = 0
  static const int aliasName = 0;
  /// className = 1
  static const int className = 1;
  /// enumName = 2
  static const int enumName = 2;
  /// fieldName = 3
  static const int fieldName = 3;
  /// interfaceName = 4
  static const int interfaceName = 4;
  /// keyword = 5
  static const int keyword = 5;
  /// lineBreak = 6
  static const int lineBreak = 6;
  /// numericLiteral = 7
  static const int numericLiteral = 7;
  /// stringLiteral = 8
  static const int stringLiteral = 8;
  /// localName = 9
  static const int localName = 9;
  /// methodName = 10
  static const int methodName = 10;
  /// moduleName = 11
  static const int moduleName = 11;
  /// operator = 12
  static const int operator_ = 12;
  /// parameterName = 13
  static const int parameterName = 13;
  /// propertyName = 14
  static const int propertyName = 14;
  /// punctuation = 15
  static const int punctuation = 15;
  /// space = 16
  static const int space = 16;
  /// text = 17
  static const int text = 17;
  /// typeParameterName = 18
  static const int typeParameterName = 18;
  /// enumMemberName = 19
  static const int enumMemberName = 19;
  /// functionName = 20
  static const int functionName = 20;
  /// regularExpressionLiteral = 21
  static const int regularExpressionLiteral = 21;
  /// link = 22
  static const int link = 22;
  /// linkName = 23
  static const int linkName = 23;
  /// linkText = 24
  static const int linkText = 24;

  const SymbolDisplayPartKind._();
}

/// enum CompletionInfoFlags
class CompletionInfoFlags {
  /// None = 0
  static const int None = 0;
  /// MayIncludeAutoImports = 1
  static const int MayIncludeAutoImports = 1;
  /// IsImportStatementCompletion = 2
  static const int IsImportStatementCompletion = 2;
  /// IsContinuation = 4
  static const int IsContinuation = 4;
  /// ResolvedModuleSpecifiers = 8
  static const int ResolvedModuleSpecifiers = 8;
  /// ResolvedModuleSpecifiersBeyondLimit = 16
  static const int ResolvedModuleSpecifiersBeyondLimit = 16;
  /// MayIncludeMethodSnippets = 32
  static const int MayIncludeMethodSnippets = 32;

  const CompletionInfoFlags._();
}

/// enum OutliningSpanKind
class OutliningSpanKind {
  /// Comment = comment
  static const String Comment = 'comment';
  /// Region = region
  static const String Region = 'region';
  /// Code = code
  static const String Code = 'code';
  /// Imports = imports
  static const String Imports = 'imports';

  const OutliningSpanKind._();
}

/// enum OutputFileType
class OutputFileType {
  /// JavaScript = 0
  static const int JavaScript = 0;
  /// SourceMap = 1
  static const int SourceMap = 1;
  /// Declaration = 2
  static const int Declaration = 2;

  const OutputFileType._();
}

/// enum EndOfLineState
class EndOfLineState {
  /// None = 0
  static const int None = 0;
  /// InMultiLineCommentTrivia = 1
  static const int InMultiLineCommentTrivia = 1;
  /// InSingleQuoteStringLiteral = 2
  static const int InSingleQuoteStringLiteral = 2;
  /// InDoubleQuoteStringLiteral = 3
  static const int InDoubleQuoteStringLiteral = 3;
  /// InTemplateHeadOrNoSubstitutionTemplate = 4
  static const int InTemplateHeadOrNoSubstitutionTemplate = 4;
  /// InTemplateMiddleOrTail = 5
  static const int InTemplateMiddleOrTail = 5;
  /// InTemplateSubstitutionPosition = 6
  static const int InTemplateSubstitutionPosition = 6;

  const EndOfLineState._();
}

/// enum TokenClass
class TokenClass {
  /// Punctuation = 0
  static const int Punctuation = 0;
  /// Keyword = 1
  static const int Keyword = 1;
  /// Operator = 2
  static const int Operator = 2;
  /// Comment = 3
  static const int Comment = 3;
  /// Whitespace = 4
  static const int Whitespace = 4;
  /// Identifier = 5
  static const int Identifier = 5;
  /// NumberLiteral = 6
  static const int NumberLiteral = 6;
  /// BigIntLiteral = 7
  static const int BigIntLiteral = 7;
  /// StringLiteral = 8
  static const int StringLiteral = 8;
  /// RegExpLiteral = 9
  static const int RegExpLiteral = 9;

  const TokenClass._();
}

/// enum ScriptElementKind
class ScriptElementKind {
  /// unknown = 
  static const String unknown = '';
  /// warning = warning
  static const String warning = 'warning';
  /// keyword = keyword
  static const String keyword = 'keyword';
  /// scriptElement = script
  static const String scriptElement = 'script';
  /// moduleElement = module
  static const String moduleElement = 'module';
  /// classElement = class
  static const String classElement = 'class';
  /// localClassElement = local class
  static const String localClassElement = 'local class';
  /// interfaceElement = interface
  static const String interfaceElement = 'interface';
  /// typeElement = type
  static const String typeElement = 'type';
  /// enumElement = enum
  static const String enumElement = 'enum';
  /// enumMemberElement = enum member
  static const String enumMemberElement = 'enum member';
  /// variableElement = var
  static const String variableElement = 'var';
  /// localVariableElement = local var
  static const String localVariableElement = 'local var';
  /// variableUsingElement = using
  static const String variableUsingElement = 'using';
  /// variableAwaitUsingElement = await using
  static const String variableAwaitUsingElement = 'await using';
  /// functionElement = function
  static const String functionElement = 'function';
  /// localFunctionElement = local function
  static const String localFunctionElement = 'local function';
  /// memberFunctionElement = method
  static const String memberFunctionElement = 'method';
  /// memberGetAccessorElement = getter
  static const String memberGetAccessorElement = 'getter';
  /// memberSetAccessorElement = setter
  static const String memberSetAccessorElement = 'setter';
  /// memberVariableElement = property
  static const String memberVariableElement = 'property';
  /// memberAccessorVariableElement = accessor
  static const String memberAccessorVariableElement = 'accessor';
  /// constructorImplementationElement = constructor
  static const String constructorImplementationElement = 'constructor';
  /// callSignatureElement = call
  static const String callSignatureElement = 'call';
  /// indexSignatureElement = index
  static const String indexSignatureElement = 'index';
  /// constructSignatureElement = construct
  static const String constructSignatureElement = 'construct';
  /// parameterElement = parameter
  static const String parameterElement = 'parameter';
  /// typeParameterElement = type parameter
  static const String typeParameterElement = 'type parameter';
  /// primitiveType = primitive type
  static const String primitiveType = 'primitive type';
  /// label = label
  static const String label = 'label';
  /// alias = alias
  static const String alias = 'alias';
  /// constElement = const
  static const String constElement = 'const';
  /// letElement = let
  static const String letElement = 'let';
  /// directory = directory
  static const String directory = 'directory';
  /// externalModuleName = external module name
  static const String externalModuleName = 'external module name';
  /// jsxAttribute = JSX attribute
  static const String jsxAttribute = 'JSX attribute';
  /// string = string
  static const String string = 'string';
  /// link = link
  static const String link = 'link';
  /// linkName = link name
  static const String linkName = 'link name';
  /// linkText = link text
  static const String linkText = 'link text';

  const ScriptElementKind._();
}

/// enum ScriptElementKindModifier
class ScriptElementKindModifier {
  /// none = 
  static const String none = '';
  /// publicMemberModifier = public
  static const String publicMemberModifier = 'public';
  /// privateMemberModifier = private
  static const String privateMemberModifier = 'private';
  /// protectedMemberModifier = protected
  static const String protectedMemberModifier = 'protected';
  /// exportedModifier = export
  static const String exportedModifier = 'export';
  /// ambientModifier = declare
  static const String ambientModifier = 'declare';
  /// staticModifier = static
  static const String staticModifier = 'static';
  /// abstractModifier = abstract
  static const String abstractModifier = 'abstract';
  /// optionalModifier = optional
  static const String optionalModifier = 'optional';
  /// deprecatedModifier = deprecated
  static const String deprecatedModifier = 'deprecated';
  /// dtsModifier = .d.ts
  static const String dtsModifier = '.d.ts';
  /// tsModifier = .ts
  static const String tsModifier = '.ts';
  /// tsxModifier = .tsx
  static const String tsxModifier = '.tsx';
  /// jsModifier = .js
  static const String jsModifier = '.js';
  /// jsxModifier = .jsx
  static const String jsxModifier = '.jsx';
  /// jsonModifier = .json
  static const String jsonModifier = '.json';
  /// dmtsModifier = .d.mts
  static const String dmtsModifier = '.d.mts';
  /// mtsModifier = .mts
  static const String mtsModifier = '.mts';
  /// mjsModifier = .mjs
  static const String mjsModifier = '.mjs';
  /// dctsModifier = .d.cts
  static const String dctsModifier = '.d.cts';
  /// ctsModifier = .cts
  static const String ctsModifier = '.cts';
  /// cjsModifier = .cjs
  static const String cjsModifier = '.cjs';

  const ScriptElementKindModifier._();
}

/// enum ClassificationTypeNames
class ClassificationTypeNames {
  /// comment = comment
  static const String comment = 'comment';
  /// identifier = identifier
  static const String identifier = 'identifier';
  /// keyword = keyword
  static const String keyword = 'keyword';
  /// numericLiteral = number
  static const String numericLiteral = 'number';
  /// bigintLiteral = bigint
  static const String bigintLiteral = 'bigint';
  /// operator = operator
  static const String operator_ = 'operator';
  /// stringLiteral = string
  static const String stringLiteral = 'string';
  /// whiteSpace = whitespace
  static const String whiteSpace = 'whitespace';
  /// text = text
  static const String text = 'text';
  /// punctuation = punctuation
  static const String punctuation = 'punctuation';
  /// className = class name
  static const String className = 'class name';
  /// enumName = enum name
  static const String enumName = 'enum name';
  /// interfaceName = interface name
  static const String interfaceName = 'interface name';
  /// moduleName = module name
  static const String moduleName = 'module name';
  /// typeParameterName = type parameter name
  static const String typeParameterName = 'type parameter name';
  /// typeAliasName = type alias name
  static const String typeAliasName = 'type alias name';
  /// parameterName = parameter name
  static const String parameterName = 'parameter name';
  /// docCommentTagName = doc comment tag name
  static const String docCommentTagName = 'doc comment tag name';
  /// jsxOpenTagName = jsx open tag name
  static const String jsxOpenTagName = 'jsx open tag name';
  /// jsxCloseTagName = jsx close tag name
  static const String jsxCloseTagName = 'jsx close tag name';
  /// jsxSelfClosingTagName = jsx self closing tag name
  static const String jsxSelfClosingTagName = 'jsx self closing tag name';
  /// jsxAttribute = jsx attribute
  static const String jsxAttribute = 'jsx attribute';
  /// jsxText = jsx text
  static const String jsxText = 'jsx text';
  /// jsxAttributeStringLiteralValue = jsx attribute string literal value
  static const String jsxAttributeStringLiteralValue = 'jsx attribute string literal value';

  const ClassificationTypeNames._();
}

/// enum ClassificationType
class ClassificationType {
  /// comment = 1
  static const int comment = 1;
  /// identifier = 2
  static const int identifier = 2;
  /// keyword = 3
  static const int keyword = 3;
  /// numericLiteral = 4
  static const int numericLiteral = 4;
  /// operator = 5
  static const int operator_ = 5;
  /// stringLiteral = 6
  static const int stringLiteral = 6;
  /// regularExpressionLiteral = 7
  static const int regularExpressionLiteral = 7;
  /// whiteSpace = 8
  static const int whiteSpace = 8;
  /// text = 9
  static const int text = 9;
  /// punctuation = 10
  static const int punctuation = 10;
  /// className = 11
  static const int className = 11;
  /// enumName = 12
  static const int enumName = 12;
  /// interfaceName = 13
  static const int interfaceName = 13;
  /// moduleName = 14
  static const int moduleName = 14;
  /// typeParameterName = 15
  static const int typeParameterName = 15;
  /// typeAliasName = 16
  static const int typeAliasName = 16;
  /// parameterName = 17
  static const int parameterName = 17;
  /// docCommentTagName = 18
  static const int docCommentTagName = 18;
  /// jsxOpenTagName = 19
  static const int jsxOpenTagName = 19;
  /// jsxCloseTagName = 20
  static const int jsxCloseTagName = 20;
  /// jsxSelfClosingTagName = 21
  static const int jsxSelfClosingTagName = 21;
  /// jsxAttribute = 22
  static const int jsxAttribute = 22;
  /// jsxText = 23
  static const int jsxText = 23;
  /// jsxAttributeStringLiteralValue = 24
  static const int jsxAttributeStringLiteralValue = 24;
  /// bigintLiteral = 25
  static const int bigintLiteral = 25;

  const ClassificationType._();
}

/// interface Message  [ns: ts.server.protocol]
abstract class ServerProtocolMessage {
  /// seq: number
  num get seq;
  /// type: "request" | "response" | "event"
  Object? get type;
}

/// interface Request extends Message  [ns: ts.server.protocol]
abstract class ServerProtocolRequest {
  /// type: "request"
  String get type;
  /// command: string
  String get command;
  /// optional arguments: any
  Object? get arguments;
}

/// interface ReloadProjectsRequest extends Request  [ns: ts.server.protocol]
abstract class ServerProtocolReloadProjectsRequest {
  /// command: CommandTypes.ReloadProjects
  ServerProtocolCommandTypes get command;
}

/// interface Event extends Message  [ns: ts.server.protocol]
abstract class ServerProtocolEvent {
  /// type: "event"
  String get type;
  /// event: string
  String get event;
  /// optional body: any
  Object? get body;
}

/// interface Response extends Message  [ns: ts.server.protocol]
abstract class ServerProtocolResponse {
  /// type: "response"
  String get type;
  /// request_seq: number
  num get request_seq;
  /// success: boolean
  bool get success;
  /// command: string
  String get command;
  /// optional message: string
  String? get message;
  /// optional body: any
  Object? get body;
  /// optional metadata: unknown
  Object? get metadata;
  /// optional performanceData: PerformanceData
  ServerProtocolPerformanceData? get performanceData;
}

/// interface PerformanceData  [ns: ts.server.protocol]
abstract class ServerProtocolPerformanceData {
  /// optional updateGraphDurationMs: number
  num? get updateGraphDurationMs;
  /// optional createAutoImportProviderProgramDurationMs: number
  num? get createAutoImportProviderProgramDurationMs;
  /// optional diagnosticsDuration: FileDiagnosticPerformanceData[]
  List<ServerProtocolFileDiagnosticPerformanceData>? get diagnosticsDuration;
}

/// interface FileDiagnosticPerformanceData extends DiagnosticPerformanceData  [ns: ts.server.protocol]
abstract class ServerProtocolFileDiagnosticPerformanceData {
  /// file: string
  String get file;
}

/// interface FileRequestArgs  [ns: ts.server.protocol]
abstract class ServerProtocolFileRequestArgs {
  /// file: string
  String get file;
  /// optional projectFileName: string
  String? get projectFileName;
}

/// interface StatusRequest extends Request  [ns: ts.server.protocol]
abstract class ServerProtocolStatusRequest {
  /// command: CommandTypes.Status
  ServerProtocolCommandTypes get command;
}

/// interface StatusResponseBody  [ns: ts.server.protocol]
abstract class ServerProtocolStatusResponseBody {
  /// version: string
  String get version;
}

/// interface StatusResponse extends Response  [ns: ts.server.protocol]
abstract class ServerProtocolStatusResponse {
  /// body: StatusResponseBody
  ServerProtocolStatusResponseBody get body;
}

/// interface DocCommentTemplateRequest extends FileLocationRequest  [ns: ts.server.protocol]
abstract class ServerProtocolDocCommentTemplateRequest {
  /// command: CommandTypes.DocCommentTemplate
  ServerProtocolCommandTypes get command;
}

/// interface DocCommandTemplateResponse extends Response  [ns: ts.server.protocol]
abstract class ServerProtocolDocCommandTemplateResponse {
  /// optional body: TextInsertion
  TextInsertion? get body;
}

/// interface TodoCommentRequest extends FileRequest  [ns: ts.server.protocol]
abstract class ServerProtocolTodoCommentRequest {
  /// command: CommandTypes.TodoComments
  ServerProtocolCommandTypes get command;
  /// arguments: TodoCommentRequestArgs
  ServerProtocolTodoCommentRequestArgs get arguments;
}

/// interface TodoCommentRequestArgs extends FileRequestArgs  [ns: ts.server.protocol]
abstract class ServerProtocolTodoCommentRequestArgs {
  /// descriptors: TodoCommentDescriptor[]
  List<TodoCommentDescriptor> get descriptors;
}

/// interface TodoCommentsResponse extends Response  [ns: ts.server.protocol]
abstract class ServerProtocolTodoCommentsResponse {
  /// optional body: TodoComment[]
  List<TodoComment>? get body;
}

/// interface SpanOfEnclosingCommentRequest extends FileLocationRequest  [ns: ts.server.protocol]
abstract class ServerProtocolSpanOfEnclosingCommentRequest {
  /// command: CommandTypes.GetSpanOfEnclosingComment
  ServerProtocolCommandTypes get command;
  /// arguments: SpanOfEnclosingCommentRequestArgs
  ServerProtocolSpanOfEnclosingCommentRequestArgs get arguments;
}

/// interface SpanOfEnclosingCommentRequestArgs extends FileLocationRequestArgs  [ns: ts.server.protocol]
abstract class ServerProtocolSpanOfEnclosingCommentRequestArgs {
  /// onlyMultiLine: boolean
  bool get onlyMultiLine;
}

/// interface OutliningSpansRequest extends FileRequest  [ns: ts.server.protocol]
abstract class ServerProtocolOutliningSpansRequest {
  /// command: CommandTypes.GetOutliningSpans
  ServerProtocolCommandTypes get command;
}

/// interface OutliningSpansResponse extends Response  [ns: ts.server.protocol]
abstract class ServerProtocolOutliningSpansResponse {
  /// optional body: OutliningSpan[]
  List<OutliningSpan>? get body;
}

/// interface IndentationRequest extends FileLocationRequest  [ns: ts.server.protocol]
abstract class ServerProtocolIndentationRequest {
  /// command: CommandTypes.Indentation
  ServerProtocolCommandTypes get command;
  /// arguments: IndentationRequestArgs
  ServerProtocolIndentationRequestArgs get arguments;
}

/// interface IndentationResponse extends Response  [ns: ts.server.protocol]
abstract class ServerProtocolIndentationResponse {
  /// optional body: IndentationResult
  ServerProtocolIndentationResult? get body;
}

/// interface IndentationResult  [ns: ts.server.protocol]
abstract class ServerProtocolIndentationResult {
  /// position: number
  num get position;
  /// indentation: number
  num get indentation;
}

/// interface IndentationRequestArgs extends FileLocationRequestArgs  [ns: ts.server.protocol]
abstract class ServerProtocolIndentationRequestArgs {
  /// optional options: EditorSettings
  EditorSettings? get options;
}

/// interface ProjectInfoRequestArgs extends FileRequestArgs  [ns: ts.server.protocol]
abstract class ServerProtocolProjectInfoRequestArgs {
  /// needFileNameList: boolean
  bool get needFileNameList;
  /// optional needDefaultConfiguredProjectInfo: boolean
  bool? get needDefaultConfiguredProjectInfo;
}

/// interface ProjectInfoRequest extends Request  [ns: ts.server.protocol]
abstract class ServerProtocolProjectInfoRequest {
  /// command: CommandTypes.ProjectInfo
  ServerProtocolCommandTypes get command;
  /// arguments: ProjectInfoRequestArgs
  ServerProtocolProjectInfoRequestArgs get arguments;
}

/// interface CompilerOptionsDiagnosticsRequest extends Request  [ns: ts.server.protocol]
abstract class ServerProtocolCompilerOptionsDiagnosticsRequest {
  /// arguments: CompilerOptionsDiagnosticsRequestArgs
  ServerProtocolCompilerOptionsDiagnosticsRequestArgs get arguments;
}

/// interface CompilerOptionsDiagnosticsRequestArgs  [ns: ts.server.protocol]
abstract class ServerProtocolCompilerOptionsDiagnosticsRequestArgs {
  /// projectFileName: string
  String get projectFileName;
}

/// interface DefaultConfiguredProjectInfo  [ns: ts.server.protocol]
abstract class ServerProtocolDefaultConfiguredProjectInfo {
  /// optional notMatchedByConfig: readonly string[]
  List<String>? get notMatchedByConfig;
  /// optional notInProject: readonly string[]
  List<String>? get notInProject;
  /// optional defaultProject: string
  String? get defaultProject;
}

/// interface ProjectInfo  [ns: ts.server.protocol]
abstract class ServerProtocolProjectInfo {
  /// configFileName: string
  String get configFileName;
  /// optional fileNames: string[]
  List<String>? get fileNames;
  /// optional languageServiceDisabled: boolean
  bool? get languageServiceDisabled;
  /// optional configuredProjectInfo: DefaultConfiguredProjectInfo
  ServerProtocolDefaultConfiguredProjectInfo? get configuredProjectInfo;
}

/// interface DiagnosticWithLinePosition  [ns: ts.server.protocol]
abstract class ServerProtocolDiagnosticWithLinePosition {
  /// message: string
  String get message;
  /// start: number
  num get start;
  /// length: number
  num get length;
  /// startLocation: Location
  ServerProtocolLocation get startLocation;
  /// endLocation: Location
  ServerProtocolLocation get endLocation;
  /// category: string
  String get category;
  /// code: number
  num get code;
  /// optional reportsUnnecessary: {}
  Map<String, Object?>? get reportsUnnecessary;
  /// optional reportsDeprecated: {}
  Map<String, Object?>? get reportsDeprecated;
  /// optional relatedInformation: DiagnosticRelatedInformation[]
  List<DiagnosticRelatedInformation>? get relatedInformation;
}

/// interface ProjectInfoResponse extends Response  [ns: ts.server.protocol]
abstract class ServerProtocolProjectInfoResponse {
  /// optional body: ProjectInfo
  ServerProtocolProjectInfo? get body;
}

/// interface FileRequest extends Request  [ns: ts.server.protocol]
abstract class ServerProtocolFileRequest {
  /// arguments: FileRequestArgs
  ServerProtocolFileRequestArgs get arguments;
}

/// interface FileLocationRequestArgs extends FileRequestArgs  [ns: ts.server.protocol]
abstract class ServerProtocolFileLocationRequestArgs {
  /// line: number
  num get line;
  /// offset: number
  num get offset;
}

/// interface GetApplicableRefactorsRequest extends Request  [ns: ts.server.protocol]
abstract class ServerProtocolGetApplicableRefactorsRequest {
  /// command: CommandTypes.GetApplicableRefactors
  ServerProtocolCommandTypes get command;
  /// arguments: GetApplicableRefactorsRequestArgs
  ServerProtocolGetApplicableRefactorsRequestArgs get arguments;
}

/// interface GetApplicableRefactorsResponse extends Response  [ns: ts.server.protocol]
abstract class ServerProtocolGetApplicableRefactorsResponse {
  /// optional body: ApplicableRefactorInfo[]
  List<ApplicableRefactorInfo>? get body;
}

/// interface GetMoveToRefactoringFileSuggestionsRequest extends Request  [ns: ts.server.protocol]
abstract class ServerProtocolGetMoveToRefactoringFileSuggestionsRequest {
  /// command: CommandTypes.GetMoveToRefactoringFileSuggestions
  ServerProtocolCommandTypes get command;
  /// arguments: GetMoveToRefactoringFileSuggestionsRequestArgs
  ServerProtocolGetMoveToRefactoringFileSuggestionsRequestArgs get arguments;
}

/// interface GetMoveToRefactoringFileSuggestions extends Response  [ns: ts.server.protocol]
abstract class ServerProtocolGetMoveToRefactoringFileSuggestions {
  /// body: { newFileName: string; files: string[]; }
  Map<String, Object?> get body;
}

/// interface PreparePasteEditsRequest extends FileRequest  [ns: ts.server.protocol]
abstract class ServerProtocolPreparePasteEditsRequest {
  /// command: CommandTypes.PreparePasteEdits
  ServerProtocolCommandTypes get command;
  /// arguments: PreparePasteEditsRequestArgs
  ServerProtocolPreparePasteEditsRequestArgs get arguments;
}

/// interface PreparePasteEditsRequestArgs extends FileRequestArgs  [ns: ts.server.protocol]
abstract class ServerProtocolPreparePasteEditsRequestArgs {
  /// copiedTextSpan: TextSpan[]
  List<TextSpan> get copiedTextSpan;
}

/// interface PreparePasteEditsResponse extends Response  [ns: ts.server.protocol]
abstract class ServerProtocolPreparePasteEditsResponse {
  /// body: boolean
  bool get body;
}

/// interface GetPasteEditsRequest extends Request  [ns: ts.server.protocol]
abstract class ServerProtocolGetPasteEditsRequest {
  /// command: CommandTypes.GetPasteEdits
  ServerProtocolCommandTypes get command;
  /// arguments: GetPasteEditsRequestArgs
  ServerProtocolGetPasteEditsRequestArgs get arguments;
}

/// interface GetPasteEditsRequestArgs extends FileRequestArgs  [ns: ts.server.protocol]
abstract class ServerProtocolGetPasteEditsRequestArgs {
  /// pastedText: string[]
  List<String> get pastedText;
  /// pasteLocations: TextSpan[]
  List<TextSpan> get pasteLocations;
  /// optional copiedFrom: { file: string; spans: TextSpan[]; }
  Map<String, Object?>? get copiedFrom;
}

/// interface GetPasteEditsResponse extends Response  [ns: ts.server.protocol]
abstract class ServerProtocolGetPasteEditsResponse {
  /// body: PasteEditsAction
  ServerProtocolPasteEditsAction get body;
}

/// interface PasteEditsAction  [ns: ts.server.protocol]
abstract class ServerProtocolPasteEditsAction {
  /// edits: FileCodeEdits[]
  List<ServerProtocolFileCodeEdits> get edits;
  /// optional fixId: {}
  Map<String, Object?>? get fixId;
}

/// interface GetEditsForRefactorRequest extends Request  [ns: ts.server.protocol]
abstract class ServerProtocolGetEditsForRefactorRequest {
  /// command: CommandTypes.GetEditsForRefactor
  ServerProtocolCommandTypes get command;
  /// arguments: GetEditsForRefactorRequestArgs
  ServerProtocolGetEditsForRefactorRequestArgs get arguments;
}

/// interface GetEditsForRefactorResponse extends Response  [ns: ts.server.protocol]
abstract class ServerProtocolGetEditsForRefactorResponse {
  /// optional body: RefactorEditInfo
  RefactorEditInfo? get body;
}

/// interface RefactorEditInfo  [ns: ts.server.protocol]
abstract class ServerProtocolRefactorEditInfo {
  /// edits: FileCodeEdits[]
  List<ServerProtocolFileCodeEdits> get edits;
  /// optional renameLocation: Location
  ServerProtocolLocation? get renameLocation;
  /// optional renameFilename: string
  String? get renameFilename;
  /// optional notApplicableReason: string
  String? get notApplicableReason;
}

/// interface OrganizeImportsRequest extends Request  [ns: ts.server.protocol]
abstract class ServerProtocolOrganizeImportsRequest {
  /// command: CommandTypes.OrganizeImports
  ServerProtocolCommandTypes get command;
  /// arguments: OrganizeImportsRequestArgs
  ServerProtocolOrganizeImportsRequestArgs get arguments;
}

/// interface OrganizeImportsRequestArgs  [ns: ts.server.protocol]
abstract class ServerProtocolOrganizeImportsRequestArgs {
  /// scope: OrganizeImportsScope
  ServerProtocolOrganizeImportsScope get scope;
  /// optional skipDestructiveCodeActions: boolean
  bool? get skipDestructiveCodeActions;
  /// optional mode: OrganizeImportsMode
  OrganizeImportsMode? get mode;
}

/// interface OrganizeImportsResponse extends Response  [ns: ts.server.protocol]
abstract class ServerProtocolOrganizeImportsResponse {
  /// body: readonly FileCodeEdits[]
  List<ServerProtocolFileCodeEdits> get body;
}

/// interface GetEditsForFileRenameRequest extends Request  [ns: ts.server.protocol]
abstract class ServerProtocolGetEditsForFileRenameRequest {
  /// command: CommandTypes.GetEditsForFileRename
  ServerProtocolCommandTypes get command;
  /// arguments: GetEditsForFileRenameRequestArgs
  ServerProtocolGetEditsForFileRenameRequestArgs get arguments;
}

/// interface GetEditsForFileRenameRequestArgs  [ns: ts.server.protocol]
abstract class ServerProtocolGetEditsForFileRenameRequestArgs {
  /// oldFilePath: string
  String get oldFilePath;
  /// newFilePath: string
  String get newFilePath;
}

/// interface GetEditsForFileRenameResponse extends Response  [ns: ts.server.protocol]
abstract class ServerProtocolGetEditsForFileRenameResponse {
  /// body: readonly FileCodeEdits[]
  List<ServerProtocolFileCodeEdits> get body;
}

/// interface CodeFixRequest extends Request  [ns: ts.server.protocol]
abstract class ServerProtocolCodeFixRequest {
  /// command: CommandTypes.GetCodeFixes
  ServerProtocolCommandTypes get command;
  /// arguments: CodeFixRequestArgs
  ServerProtocolCodeFixRequestArgs get arguments;
}

/// interface GetCombinedCodeFixRequest extends Request  [ns: ts.server.protocol]
abstract class ServerProtocolGetCombinedCodeFixRequest {
  /// command: CommandTypes.GetCombinedCodeFix
  ServerProtocolCommandTypes get command;
  /// arguments: GetCombinedCodeFixRequestArgs
  ServerProtocolGetCombinedCodeFixRequestArgs get arguments;
}

/// interface GetCombinedCodeFixResponse extends Response  [ns: ts.server.protocol]
abstract class ServerProtocolGetCombinedCodeFixResponse {
  /// body: CombinedCodeActions
  CombinedCodeActions get body;
}

/// interface ApplyCodeActionCommandRequest extends Request  [ns: ts.server.protocol]
abstract class ServerProtocolApplyCodeActionCommandRequest {
  /// command: CommandTypes.ApplyCodeActionCommand
  ServerProtocolCommandTypes get command;
  /// arguments: ApplyCodeActionCommandRequestArgs
  ServerProtocolApplyCodeActionCommandRequestArgs get arguments;
}

/// interface ApplyCodeActionCommandResponse extends Response  [ns: ts.server.protocol]
abstract class ServerProtocolApplyCodeActionCommandResponse {
}

/// interface FileRangeRequestArgs extends FileRequestArgs, FileRange  [ns: ts.server.protocol]
abstract class ServerProtocolFileRangeRequestArgs {
}

/// interface CodeFixRequestArgs extends FileRangeRequestArgs  [ns: ts.server.protocol]
abstract class ServerProtocolCodeFixRequestArgs {
  /// errorCodes: readonly number[]
  List<num> get errorCodes;
}

/// interface GetCombinedCodeFixRequestArgs  [ns: ts.server.protocol]
abstract class ServerProtocolGetCombinedCodeFixRequestArgs {
  /// scope: GetCombinedCodeFixScope
  ServerProtocolGetCombinedCodeFixScope get scope;
  /// fixId: {}
  Map<String, Object?> get fixId;
}

/// interface GetCombinedCodeFixScope  [ns: ts.server.protocol]
abstract class ServerProtocolGetCombinedCodeFixScope {
  /// type: "file"
  String get type;
  /// args: FileRequestArgs
  ServerProtocolFileRequestArgs get args;
}

/// interface ApplyCodeActionCommandRequestArgs  [ns: ts.server.protocol]
abstract class ServerProtocolApplyCodeActionCommandRequestArgs {
  /// command: {}
  Map<String, Object?> get command;
}

/// interface GetCodeFixesResponse extends Response  [ns: ts.server.protocol]
abstract class ServerProtocolGetCodeFixesResponse {
  /// optional body: CodeAction[]
  List<CodeAction>? get body;
}

/// interface FileLocationRequest extends FileRequest  [ns: ts.server.protocol]
abstract class ServerProtocolFileLocationRequest {
  /// arguments: FileLocationRequestArgs
  ServerProtocolFileLocationRequestArgs get arguments;
}

/// interface GetSupportedCodeFixesRequest extends Request  [ns: ts.server.protocol]
abstract class ServerProtocolGetSupportedCodeFixesRequest {
  /// command: CommandTypes.GetSupportedCodeFixes
  ServerProtocolCommandTypes get command;
  /// optional arguments: Partial<FileRequestArgs>
  Map<String, Object?>? get arguments;
}

/// interface GetSupportedCodeFixesResponse extends Response  [ns: ts.server.protocol]
abstract class ServerProtocolGetSupportedCodeFixesResponse {
  /// optional body: string[]
  List<String>? get body;
}

/// interface EncodedSemanticClassificationsRequest extends FileRequest  [ns: ts.server.protocol]
abstract class ServerProtocolEncodedSemanticClassificationsRequest {
  /// arguments: EncodedSemanticClassificationsRequestArgs
  ServerProtocolEncodedSemanticClassificationsRequestArgs get arguments;
}

/// interface EncodedSemanticClassificationsRequestArgs extends FileRequestArgs  [ns: ts.server.protocol]
abstract class ServerProtocolEncodedSemanticClassificationsRequestArgs {
  /// start: number
  num get start;
  /// length: number
  num get length;
  /// optional format: "original" | "2020"
  Object? get format;
}

/// interface EncodedSemanticClassificationsResponse extends Response  [ns: ts.server.protocol]
abstract class ServerProtocolEncodedSemanticClassificationsResponse {
  /// optional body: EncodedSemanticClassificationsResponseBody
  ServerProtocolEncodedSemanticClassificationsResponseBody? get body;
}

/// interface EncodedSemanticClassificationsResponseBody  [ns: ts.server.protocol]
abstract class ServerProtocolEncodedSemanticClassificationsResponseBody {
  /// endOfLineState: EndOfLineState
  EndOfLineState get endOfLineState;
  /// spans: number[]
  List<num> get spans;
}

/// interface DocumentHighlightsRequestArgs extends FileLocationRequestArgs  [ns: ts.server.protocol]
abstract class ServerProtocolDocumentHighlightsRequestArgs {
  /// filesToSearch: string[]
  List<String> get filesToSearch;
}

/// interface DefinitionRequest extends FileLocationRequest  [ns: ts.server.protocol]
abstract class ServerProtocolDefinitionRequest {
  /// command: CommandTypes.Definition
  ServerProtocolCommandTypes get command;
}

/// interface DefinitionAndBoundSpanRequest extends FileLocationRequest  [ns: ts.server.protocol]
abstract class ServerProtocolDefinitionAndBoundSpanRequest {
  /// command: CommandTypes.DefinitionAndBoundSpan
  ServerProtocolCommandTypes get command;
}

/// interface FindSourceDefinitionRequest extends FileLocationRequest  [ns: ts.server.protocol]
abstract class ServerProtocolFindSourceDefinitionRequest {
  /// command: CommandTypes.FindSourceDefinition
  ServerProtocolCommandTypes get command;
}

/// interface DefinitionAndBoundSpanResponse extends Response  [ns: ts.server.protocol]
abstract class ServerProtocolDefinitionAndBoundSpanResponse {
  /// body: DefinitionInfoAndBoundSpan
  DefinitionInfoAndBoundSpan get body;
}

/// interface TypeDefinitionRequest extends FileLocationRequest  [ns: ts.server.protocol]
abstract class ServerProtocolTypeDefinitionRequest {
  /// command: CommandTypes.TypeDefinition
  ServerProtocolCommandTypes get command;
}

/// interface ImplementationRequest extends FileLocationRequest  [ns: ts.server.protocol]
abstract class ServerProtocolImplementationRequest {
  /// command: CommandTypes.Implementation
  ServerProtocolCommandTypes get command;
}

/// interface Location  [ns: ts.server.protocol]
abstract class ServerProtocolLocation {
  /// line: number
  num get line;
  /// offset: number
  num get offset;
}

/// interface TextSpan  [ns: ts.server.protocol]
abstract class ServerProtocolTextSpan {
  /// start: Location
  ServerProtocolLocation get start;
  /// end: Location
  ServerProtocolLocation get end;
}

/// interface FileSpan extends TextSpan  [ns: ts.server.protocol]
abstract class ServerProtocolFileSpan {
  /// file: string
  String get file;
}

/// interface JSDocTagInfo  [ns: ts.server.protocol]
abstract class ServerProtocolJSDocTagInfo {
  /// name: string
  String get name;
  /// optional text: string | SymbolDisplayPart[]
  Object? get text;
}

/// interface TextSpanWithContext extends TextSpan  [ns: ts.server.protocol]
abstract class ServerProtocolTextSpanWithContext {
  /// optional contextStart: Location
  ServerProtocolLocation? get contextStart;
  /// optional contextEnd: Location
  ServerProtocolLocation? get contextEnd;
}

/// interface FileSpanWithContext extends FileSpan, TextSpanWithContext  [ns: ts.server.protocol]
abstract class ServerProtocolFileSpanWithContext {
}

/// interface DefinitionInfo extends FileSpanWithContext  [ns: ts.server.protocol]
abstract class ServerProtocolDefinitionInfo {
  /// optional unverified: boolean
  bool? get unverified;
}

/// interface DefinitionInfoAndBoundSpan  [ns: ts.server.protocol]
abstract class ServerProtocolDefinitionInfoAndBoundSpan {
  /// definitions: readonly DefinitionInfo[]
  List<DefinitionInfo> get definitions;
  /// textSpan: TextSpan
  TextSpan get textSpan;
}

/// interface DefinitionResponse extends Response  [ns: ts.server.protocol]
abstract class ServerProtocolDefinitionResponse {
  /// optional body: DefinitionInfo[]
  List<DefinitionInfo>? get body;
}

/// interface DefinitionInfoAndBoundSpanResponse extends Response  [ns: ts.server.protocol]
abstract class ServerProtocolDefinitionInfoAndBoundSpanResponse {
  /// optional body: DefinitionInfoAndBoundSpan
  DefinitionInfoAndBoundSpan? get body;
}

/// interface TypeDefinitionResponse extends Response  [ns: ts.server.protocol]
abstract class ServerProtocolTypeDefinitionResponse {
  /// optional body: FileSpanWithContext[]
  List<ServerProtocolFileSpanWithContext>? get body;
}

/// interface ImplementationResponse extends Response  [ns: ts.server.protocol]
abstract class ServerProtocolImplementationResponse {
  /// optional body: FileSpanWithContext[]
  List<ServerProtocolFileSpanWithContext>? get body;
}

/// interface BraceCompletionRequest extends FileLocationRequest  [ns: ts.server.protocol]
abstract class ServerProtocolBraceCompletionRequest {
  /// command: CommandTypes.BraceCompletion
  ServerProtocolCommandTypes get command;
  /// arguments: BraceCompletionRequestArgs
  ServerProtocolBraceCompletionRequestArgs get arguments;
}

/// interface BraceCompletionRequestArgs extends FileLocationRequestArgs  [ns: ts.server.protocol]
abstract class ServerProtocolBraceCompletionRequestArgs {
  /// openingBrace: string
  String get openingBrace;
}

/// interface JsxClosingTagRequest extends FileLocationRequest  [ns: ts.server.protocol]
abstract class ServerProtocolJsxClosingTagRequest {
  /// command: CommandTypes.JsxClosingTag
  ServerProtocolCommandTypes get command;
  /// arguments: JsxClosingTagRequestArgs
  ServerProtocolJsxClosingTagRequestArgs get arguments;
}

/// interface JsxClosingTagRequestArgs extends FileLocationRequestArgs  [ns: ts.server.protocol]
abstract class ServerProtocolJsxClosingTagRequestArgs {
}

/// interface JsxClosingTagResponse extends Response  [ns: ts.server.protocol]
abstract class ServerProtocolJsxClosingTagResponse {
  /// body: TextInsertion
  TextInsertion get body;
}

/// interface LinkedEditingRangeRequest extends FileLocationRequest  [ns: ts.server.protocol]
abstract class ServerProtocolLinkedEditingRangeRequest {
  /// command: CommandTypes.LinkedEditingRange
  ServerProtocolCommandTypes get command;
}

/// interface LinkedEditingRangesBody  [ns: ts.server.protocol]
abstract class ServerProtocolLinkedEditingRangesBody {
  /// ranges: TextSpan[]
  List<TextSpan> get ranges;
  /// optional wordPattern: string
  String? get wordPattern;
}

/// interface LinkedEditingRangeResponse extends Response  [ns: ts.server.protocol]
abstract class ServerProtocolLinkedEditingRangeResponse {
  /// body: LinkedEditingRangesBody
  ServerProtocolLinkedEditingRangesBody get body;
}

/// interface DocumentHighlightsRequest extends FileLocationRequest  [ns: ts.server.protocol]
abstract class ServerProtocolDocumentHighlightsRequest {
  /// command: CommandTypes.DocumentHighlights
  ServerProtocolCommandTypes get command;
  /// arguments: DocumentHighlightsRequestArgs
  ServerProtocolDocumentHighlightsRequestArgs get arguments;
}

/// interface HighlightSpan extends TextSpanWithContext  [ns: ts.server.protocol]
abstract class ServerProtocolHighlightSpan {
  /// kind: HighlightSpanKind
  HighlightSpanKind get kind;
}

/// interface DocumentHighlightsItem  [ns: ts.server.protocol]
abstract class ServerProtocolDocumentHighlightsItem {
  /// file: string
  String get file;
  /// highlightSpans: HighlightSpan[]
  List<HighlightSpan> get highlightSpans;
}

/// interface DocumentHighlightsResponse extends Response  [ns: ts.server.protocol]
abstract class ServerProtocolDocumentHighlightsResponse {
  /// optional body: DocumentHighlightsItem[]
  List<ServerProtocolDocumentHighlightsItem>? get body;
}

/// interface ReferencesRequest extends FileLocationRequest  [ns: ts.server.protocol]
abstract class ServerProtocolReferencesRequest {
  /// command: CommandTypes.References
  ServerProtocolCommandTypes get command;
}

/// interface ReferencesResponseItem extends FileSpanWithContext  [ns: ts.server.protocol]
abstract class ServerProtocolReferencesResponseItem {
  /// optional lineText: string
  String? get lineText;
  /// isWriteAccess: boolean
  bool get isWriteAccess;
  /// optional isDefinition: boolean
  bool? get isDefinition;
}

/// interface ReferencesResponseBody  [ns: ts.server.protocol]
abstract class ServerProtocolReferencesResponseBody {
  /// refs: readonly ReferencesResponseItem[]
  List<ServerProtocolReferencesResponseItem> get refs;
  /// symbolName: string
  String get symbolName;
  /// symbolStartOffset: number
  num get symbolStartOffset;
  /// symbolDisplayString: string
  String get symbolDisplayString;
}

/// interface ReferencesResponse extends Response  [ns: ts.server.protocol]
abstract class ServerProtocolReferencesResponse {
  /// optional body: ReferencesResponseBody
  ServerProtocolReferencesResponseBody? get body;
}

/// interface FileReferencesRequest extends FileRequest  [ns: ts.server.protocol]
abstract class ServerProtocolFileReferencesRequest {
  /// command: CommandTypes.FileReferences
  ServerProtocolCommandTypes get command;
}

/// interface FileReferencesResponseBody  [ns: ts.server.protocol]
abstract class ServerProtocolFileReferencesResponseBody {
  /// refs: readonly ReferencesResponseItem[]
  List<ServerProtocolReferencesResponseItem> get refs;
  /// symbolName: string
  String get symbolName;
}

/// interface FileReferencesResponse extends Response  [ns: ts.server.protocol]
abstract class ServerProtocolFileReferencesResponse {
  /// optional body: FileReferencesResponseBody
  ServerProtocolFileReferencesResponseBody? get body;
}

/// interface RenameRequestArgs extends FileLocationRequestArgs  [ns: ts.server.protocol]
abstract class ServerProtocolRenameRequestArgs {
  /// optional findInComments: boolean
  bool? get findInComments;
  /// optional findInStrings: boolean
  bool? get findInStrings;
}

/// interface RenameRequest extends FileLocationRequest  [ns: ts.server.protocol]
abstract class ServerProtocolRenameRequest {
  /// command: CommandTypes.Rename
  ServerProtocolCommandTypes get command;
  /// arguments: RenameRequestArgs
  ServerProtocolRenameRequestArgs get arguments;
}

/// interface SpanGroup  [ns: ts.server.protocol]
abstract class ServerProtocolSpanGroup {
  /// file: string
  String get file;
  /// locs: RenameTextSpan[]
  List<ServerProtocolRenameTextSpan> get locs;
}

/// interface RenameTextSpan extends TextSpanWithContext  [ns: ts.server.protocol]
abstract class ServerProtocolRenameTextSpan {
  /// optional prefixText: string
  String? get prefixText;
  /// optional suffixText: string
  String? get suffixText;
}

/// interface RenameResponseBody  [ns: ts.server.protocol]
abstract class ServerProtocolRenameResponseBody {
  /// info: RenameInfo
  RenameInfo get info;
  /// locs: readonly SpanGroup[]
  List<ServerProtocolSpanGroup> get locs;
}

/// interface RenameResponse extends Response  [ns: ts.server.protocol]
abstract class ServerProtocolRenameResponse {
  /// optional body: RenameResponseBody
  ServerProtocolRenameResponseBody? get body;
}

/// interface ExternalFile  [ns: ts.server.protocol]
abstract class ServerProtocolExternalFile {
  /// fileName: string
  String get fileName;
  /// optional scriptKind: ScriptKindName | ScriptKind
  Object? get scriptKind;
  /// optional hasMixedContent: boolean
  bool? get hasMixedContent;
  /// optional content: string
  String? get content;
}

/// interface ExternalProject  [ns: ts.server.protocol]
abstract class ServerProtocolExternalProject {
  /// projectFileName: string
  String get projectFileName;
  /// rootFiles: ExternalFile[]
  List<ServerProtocolExternalFile> get rootFiles;
  /// options: ExternalProjectCompilerOptions
  ServerProtocolExternalProjectCompilerOptions get options;
  /// optional typeAcquisition: TypeAcquisition
  TypeAcquisition? get typeAcquisition;
}

/// interface CompileOnSaveMixin  [ns: ts.server.protocol]
abstract class ServerProtocolCompileOnSaveMixin {
  /// optional compileOnSave: boolean
  bool? get compileOnSave;
}

/// interface FileWithProjectReferenceRedirectInfo  [ns: ts.server.protocol]
abstract class ServerProtocolFileWithProjectReferenceRedirectInfo {
  /// fileName: string
  String get fileName;
  /// isSourceOfProjectReferenceRedirect: boolean
  bool get isSourceOfProjectReferenceRedirect;
}

/// interface ProjectChanges  [ns: ts.server.protocol]
abstract class ServerProtocolProjectChanges {
  /// added: string[] | FileWithProjectReferenceRedirectInfo[]
  Object? get added;
  /// removed: string[] | FileWithProjectReferenceRedirectInfo[]
  Object? get removed;
  /// updated: string[] | FileWithProjectReferenceRedirectInfo[]
  Object? get updated;
  /// optional updatedRedirects: FileWithProjectReferenceRedirectInfo[]
  List<ServerProtocolFileWithProjectReferenceRedirectInfo>? get updatedRedirects;
}

/// interface ConfigureRequestArguments  [ns: ts.server.protocol]
abstract class ServerProtocolConfigureRequestArguments {
  /// optional hostInfo: string
  String? get hostInfo;
  /// optional file: string
  String? get file;
  /// optional formatOptions: FormatCodeSettings
  FormatCodeSettings? get formatOptions;
  /// optional preferences: UserPreferences
  UserPreferences? get preferences;
  /// optional extraFileExtensions: FileExtensionInfo[]
  List<FileExtensionInfo>? get extraFileExtensions;
  /// optional watchOptions: WatchOptions
  WatchOptions? get watchOptions;
}

/// interface WatchOptions  [ns: ts.server.protocol]
abstract class ServerProtocolWatchOptions {
  /// optional watchFile: WatchFileKind | ts.WatchFileKind
  Object? get watchFile;
  /// optional watchDirectory: WatchDirectoryKind | ts.WatchDirectoryKind
  Object? get watchDirectory;
  /// optional fallbackPolling: PollingWatchKind | ts.PollingWatchKind
  Object? get fallbackPolling;
  /// optional synchronousWatchDirectory: boolean
  bool? get synchronousWatchDirectory;
  /// optional excludeDirectories: string[]
  List<String>? get excludeDirectories;
  /// optional excludeFiles: string[]
  List<String>? get excludeFiles;
  /// index signature: CompilerOptionsValue | undefined
}

/// interface ConfigureRequest extends Request  [ns: ts.server.protocol]
abstract class ServerProtocolConfigureRequest {
  /// command: CommandTypes.Configure
  ServerProtocolCommandTypes get command;
  /// arguments: ConfigureRequestArguments
  ServerProtocolConfigureRequestArguments get arguments;
}

/// interface ConfigureResponse extends Response  [ns: ts.server.protocol]
abstract class ServerProtocolConfigureResponse {
}

/// interface ConfigurePluginRequestArguments  [ns: ts.server.protocol]
abstract class ServerProtocolConfigurePluginRequestArguments {
  /// pluginName: string
  String get pluginName;
  /// configuration: any
  Object? get configuration;
}

/// interface ConfigurePluginRequest extends Request  [ns: ts.server.protocol]
abstract class ServerProtocolConfigurePluginRequest {
  /// command: CommandTypes.ConfigurePlugin
  ServerProtocolCommandTypes get command;
  /// arguments: ConfigurePluginRequestArguments
  ServerProtocolConfigurePluginRequestArguments get arguments;
}

/// interface ConfigurePluginResponse extends Response  [ns: ts.server.protocol]
abstract class ServerProtocolConfigurePluginResponse {
}

/// interface SelectionRangeRequest extends FileRequest  [ns: ts.server.protocol]
abstract class ServerProtocolSelectionRangeRequest {
  /// command: CommandTypes.SelectionRange
  ServerProtocolCommandTypes get command;
  /// arguments: SelectionRangeRequestArgs
  ServerProtocolSelectionRangeRequestArgs get arguments;
}

/// interface SelectionRangeRequestArgs extends FileRequestArgs  [ns: ts.server.protocol]
abstract class ServerProtocolSelectionRangeRequestArgs {
  /// locations: Location[]
  List<ServerProtocolLocation> get locations;
}

/// interface SelectionRangeResponse extends Response  [ns: ts.server.protocol]
abstract class ServerProtocolSelectionRangeResponse {
  /// optional body: SelectionRange[]
  List<SelectionRange>? get body;
}

/// interface SelectionRange  [ns: ts.server.protocol]
abstract class ServerProtocolSelectionRange {
  /// textSpan: TextSpan
  TextSpan get textSpan;
  /// optional parent: SelectionRange
  SelectionRange? get parent;
}

/// interface ToggleLineCommentRequest extends FileRequest  [ns: ts.server.protocol]
abstract class ServerProtocolToggleLineCommentRequest {
  /// command: CommandTypes.ToggleLineComment
  ServerProtocolCommandTypes get command;
  /// arguments: FileRangeRequestArgs
  ServerProtocolFileRangeRequestArgs get arguments;
}

/// interface ToggleMultilineCommentRequest extends FileRequest  [ns: ts.server.protocol]
abstract class ServerProtocolToggleMultilineCommentRequest {
  /// command: CommandTypes.ToggleMultilineComment
  ServerProtocolCommandTypes get command;
  /// arguments: FileRangeRequestArgs
  ServerProtocolFileRangeRequestArgs get arguments;
}

/// interface CommentSelectionRequest extends FileRequest  [ns: ts.server.protocol]
abstract class ServerProtocolCommentSelectionRequest {
  /// command: CommandTypes.CommentSelection
  ServerProtocolCommandTypes get command;
  /// arguments: FileRangeRequestArgs
  ServerProtocolFileRangeRequestArgs get arguments;
}

/// interface UncommentSelectionRequest extends FileRequest  [ns: ts.server.protocol]
abstract class ServerProtocolUncommentSelectionRequest {
  /// command: CommandTypes.UncommentSelection
  ServerProtocolCommandTypes get command;
  /// arguments: FileRangeRequestArgs
  ServerProtocolFileRangeRequestArgs get arguments;
}

/// interface OpenRequestArgs extends FileRequestArgs  [ns: ts.server.protocol]
abstract class ServerProtocolOpenRequestArgs {
  /// optional fileContent: string
  String? get fileContent;
  /// optional scriptKindName: ScriptKindName
  ServerProtocolScriptKindName? get scriptKindName;
  /// optional projectRootPath: string
  String? get projectRootPath;
}

/// interface OpenRequest extends Request  [ns: ts.server.protocol]
abstract class ServerProtocolOpenRequest {
  /// command: CommandTypes.Open
  ServerProtocolCommandTypes get command;
  /// arguments: OpenRequestArgs
  ServerProtocolOpenRequestArgs get arguments;
}

/// interface OpenExternalProjectRequest extends Request  [ns: ts.server.protocol]
abstract class ServerProtocolOpenExternalProjectRequest {
  /// command: CommandTypes.OpenExternalProject
  ServerProtocolCommandTypes get command;
  /// arguments: OpenExternalProjectArgs
  ServerProtocolOpenExternalProjectArgs get arguments;
}

/// interface OpenExternalProjectsRequest extends Request  [ns: ts.server.protocol]
abstract class ServerProtocolOpenExternalProjectsRequest {
  /// command: CommandTypes.OpenExternalProjects
  ServerProtocolCommandTypes get command;
  /// arguments: OpenExternalProjectsArgs
  ServerProtocolOpenExternalProjectsArgs get arguments;
}

/// interface OpenExternalProjectsArgs  [ns: ts.server.protocol]
abstract class ServerProtocolOpenExternalProjectsArgs {
  /// projects: ExternalProject[]
  List<ServerProtocolExternalProject> get projects;
}

/// interface OpenExternalProjectResponse extends Response  [ns: ts.server.protocol]
abstract class ServerProtocolOpenExternalProjectResponse {
}

/// interface OpenExternalProjectsResponse extends Response  [ns: ts.server.protocol]
abstract class ServerProtocolOpenExternalProjectsResponse {
}

/// interface CloseExternalProjectRequest extends Request  [ns: ts.server.protocol]
abstract class ServerProtocolCloseExternalProjectRequest {
  /// command: CommandTypes.CloseExternalProject
  ServerProtocolCommandTypes get command;
  /// arguments: CloseExternalProjectRequestArgs
  ServerProtocolCloseExternalProjectRequestArgs get arguments;
}

/// interface CloseExternalProjectRequestArgs  [ns: ts.server.protocol]
abstract class ServerProtocolCloseExternalProjectRequestArgs {
  /// projectFileName: string
  String get projectFileName;
}

/// interface CloseExternalProjectResponse extends Response  [ns: ts.server.protocol]
abstract class ServerProtocolCloseExternalProjectResponse {
}

/// interface UpdateOpenRequest extends Request  [ns: ts.server.protocol]
abstract class ServerProtocolUpdateOpenRequest {
  /// command: CommandTypes.UpdateOpen
  ServerProtocolCommandTypes get command;
  /// arguments: UpdateOpenRequestArgs
  ServerProtocolUpdateOpenRequestArgs get arguments;
}

/// interface UpdateOpenRequestArgs  [ns: ts.server.protocol]
abstract class ServerProtocolUpdateOpenRequestArgs {
  /// optional openFiles: OpenRequestArgs[]
  List<ServerProtocolOpenRequestArgs>? get openFiles;
  /// optional changedFiles: FileCodeEdits[]
  List<ServerProtocolFileCodeEdits>? get changedFiles;
  /// optional closedFiles: string[]
  List<String>? get closedFiles;
}

/// interface SetCompilerOptionsForInferredProjectsRequest extends Request  [ns: ts.server.protocol]
abstract class ServerProtocolSetCompilerOptionsForInferredProjectsRequest {
  /// command: CommandTypes.CompilerOptionsForInferredProjects
  ServerProtocolCommandTypes get command;
  /// arguments: SetCompilerOptionsForInferredProjectsArgs
  ServerProtocolSetCompilerOptionsForInferredProjectsArgs get arguments;
}

/// interface SetCompilerOptionsForInferredProjectsArgs  [ns: ts.server.protocol]
abstract class ServerProtocolSetCompilerOptionsForInferredProjectsArgs {
  /// options: InferredProjectCompilerOptions
  ServerProtocolInferredProjectCompilerOptions get options;
  /// optional projectRootPath: string
  String? get projectRootPath;
}

/// interface SetCompilerOptionsForInferredProjectsResponse extends Response  [ns: ts.server.protocol]
abstract class ServerProtocolSetCompilerOptionsForInferredProjectsResponse {
}

/// interface ExitRequest extends Request  [ns: ts.server.protocol]
abstract class ServerProtocolExitRequest {
  /// command: CommandTypes.Exit
  ServerProtocolCommandTypes get command;
}

/// interface CloseRequest extends FileRequest  [ns: ts.server.protocol]
abstract class ServerProtocolCloseRequest {
  /// command: CommandTypes.Close
  ServerProtocolCommandTypes get command;
}

/// interface WatchChangeRequest extends Request  [ns: ts.server.protocol]
abstract class ServerProtocolWatchChangeRequest {
  /// command: CommandTypes.WatchChange
  ServerProtocolCommandTypes get command;
  /// arguments: WatchChangeRequestArgs | readonly WatchChangeRequestArgs[]
  Object? get arguments;
}

/// interface WatchChangeRequestArgs  [ns: ts.server.protocol]
abstract class ServerProtocolWatchChangeRequestArgs {
  /// id: number
  num get id;
  /// optional created: string[]
  List<String>? get created;
  /// optional deleted: string[]
  List<String>? get deleted;
  /// optional updated: string[]
  List<String>? get updated;
}

/// interface CompileOnSaveAffectedFileListRequest extends FileRequest  [ns: ts.server.protocol]
abstract class ServerProtocolCompileOnSaveAffectedFileListRequest {
  /// command: CommandTypes.CompileOnSaveAffectedFileList
  ServerProtocolCommandTypes get command;
}

/// interface CompileOnSaveAffectedFileListSingleProject  [ns: ts.server.protocol]
abstract class ServerProtocolCompileOnSaveAffectedFileListSingleProject {
  /// projectFileName: string
  String get projectFileName;
  /// fileNames: string[]
  List<String> get fileNames;
  /// projectUsesOutFile: boolean
  bool get projectUsesOutFile;
}

/// interface CompileOnSaveAffectedFileListResponse extends Response  [ns: ts.server.protocol]
abstract class ServerProtocolCompileOnSaveAffectedFileListResponse {
  /// body: CompileOnSaveAffectedFileListSingleProject[]
  List<ServerProtocolCompileOnSaveAffectedFileListSingleProject> get body;
}

/// interface CompileOnSaveEmitFileRequest extends FileRequest  [ns: ts.server.protocol]
abstract class ServerProtocolCompileOnSaveEmitFileRequest {
  /// command: CommandTypes.CompileOnSaveEmitFile
  ServerProtocolCommandTypes get command;
  /// arguments: CompileOnSaveEmitFileRequestArgs
  ServerProtocolCompileOnSaveEmitFileRequestArgs get arguments;
}

/// interface CompileOnSaveEmitFileRequestArgs extends FileRequestArgs  [ns: ts.server.protocol]
abstract class ServerProtocolCompileOnSaveEmitFileRequestArgs {
  /// optional forced: boolean
  bool? get forced;
  /// optional includeLinePosition: boolean
  bool? get includeLinePosition;
  /// optional richResponse: boolean
  bool? get richResponse;
}

/// interface CompileOnSaveEmitFileResponse extends Response  [ns: ts.server.protocol]
abstract class ServerProtocolCompileOnSaveEmitFileResponse {
  /// body: boolean | EmitResult
  Object? get body;
}

/// interface EmitResult  [ns: ts.server.protocol]
abstract class ServerProtocolEmitResult {
  /// emitSkipped: boolean
  bool get emitSkipped;
  /// diagnostics: Diagnostic[] | DiagnosticWithLinePosition[]
  Object? get diagnostics;
}

/// interface QuickInfoRequest extends FileLocationRequest  [ns: ts.server.protocol]
abstract class ServerProtocolQuickInfoRequest {
  /// command: CommandTypes.Quickinfo
  ServerProtocolCommandTypes get command;
  /// arguments: FileLocationRequestArgs
  ServerProtocolFileLocationRequestArgs get arguments;
}

/// interface QuickInfoRequestArgs extends FileLocationRequestArgs  [ns: ts.server.protocol]
abstract class ServerProtocolQuickInfoRequestArgs {
  /// optional verbosityLevel: number
  num? get verbosityLevel;
}

/// interface QuickInfoResponseBody  [ns: ts.server.protocol]
abstract class ServerProtocolQuickInfoResponseBody {
  /// kind: ScriptElementKind
  ScriptElementKind get kind;
  /// kindModifiers: string
  String get kindModifiers;
  /// start: Location
  ServerProtocolLocation get start;
  /// end: Location
  ServerProtocolLocation get end;
  /// displayString: string
  String get displayString;
  /// documentation: string | SymbolDisplayPart[]
  Object? get documentation;
  /// tags: JSDocTagInfo[]
  List<JSDocTagInfo> get tags;
  /// optional canIncreaseVerbosityLevel: boolean
  bool? get canIncreaseVerbosityLevel;
}

/// interface QuickInfoResponse extends Response  [ns: ts.server.protocol]
abstract class ServerProtocolQuickInfoResponse {
  /// optional body: QuickInfoResponseBody
  ServerProtocolQuickInfoResponseBody? get body;
}

/// interface FormatRequestArgs extends FileLocationRequestArgs  [ns: ts.server.protocol]
abstract class ServerProtocolFormatRequestArgs {
  /// endLine: number
  num get endLine;
  /// endOffset: number
  num get endOffset;
  /// optional options: FormatCodeSettings
  FormatCodeSettings? get options;
}

/// interface FormatRequest extends FileLocationRequest  [ns: ts.server.protocol]
abstract class ServerProtocolFormatRequest {
  /// command: CommandTypes.Format
  ServerProtocolCommandTypes get command;
  /// arguments: FormatRequestArgs
  ServerProtocolFormatRequestArgs get arguments;
}

/// interface CodeEdit  [ns: ts.server.protocol]
abstract class ServerProtocolCodeEdit {
  /// start: Location
  ServerProtocolLocation get start;
  /// end: Location
  ServerProtocolLocation get end;
  /// newText: string
  String get newText;
}

/// interface FileCodeEdits  [ns: ts.server.protocol]
abstract class ServerProtocolFileCodeEdits {
  /// fileName: string
  String get fileName;
  /// textChanges: CodeEdit[]
  List<ServerProtocolCodeEdit> get textChanges;
}

/// interface CodeFixResponse extends Response  [ns: ts.server.protocol]
abstract class ServerProtocolCodeFixResponse {
  /// optional body: CodeFixAction[]
  List<CodeFixAction>? get body;
}

/// interface CodeAction  [ns: ts.server.protocol]
abstract class ServerProtocolCodeAction {
  /// description: string
  String get description;
  /// changes: FileCodeEdits[]
  List<ServerProtocolFileCodeEdits> get changes;
  /// optional commands: {}[]
  List<Map<String, Object?>>? get commands;
}

/// interface CombinedCodeActions  [ns: ts.server.protocol]
abstract class ServerProtocolCombinedCodeActions {
  /// changes: readonly FileCodeEdits[]
  List<ServerProtocolFileCodeEdits> get changes;
  /// optional commands: readonly {}[]
  List<Map<String, Object?>>? get commands;
}

/// interface CodeFixAction extends CodeAction  [ns: ts.server.protocol]
abstract class ServerProtocolCodeFixAction {
  /// fixName: string
  String get fixName;
  /// optional fixId: {}
  Map<String, Object?>? get fixId;
  /// optional fixAllDescription: string
  String? get fixAllDescription;
}

/// interface FormatResponse extends Response  [ns: ts.server.protocol]
abstract class ServerProtocolFormatResponse {
  /// optional body: CodeEdit[]
  List<ServerProtocolCodeEdit>? get body;
}

/// interface FormatOnKeyRequestArgs extends FileLocationRequestArgs  [ns: ts.server.protocol]
abstract class ServerProtocolFormatOnKeyRequestArgs {
  /// key: string
  String get key;
  /// optional options: FormatCodeSettings
  FormatCodeSettings? get options;
}

/// interface FormatOnKeyRequest extends FileLocationRequest  [ns: ts.server.protocol]
abstract class ServerProtocolFormatOnKeyRequest {
  /// command: CommandTypes.Formatonkey
  ServerProtocolCommandTypes get command;
  /// arguments: FormatOnKeyRequestArgs
  ServerProtocolFormatOnKeyRequestArgs get arguments;
}

/// interface CompletionsRequestArgs extends FileLocationRequestArgs  [ns: ts.server.protocol]
abstract class ServerProtocolCompletionsRequestArgs {
  /// optional prefix: string
  String? get prefix;
  /// optional triggerCharacter: CompletionsTriggerCharacter
  CompletionsTriggerCharacter? get triggerCharacter;
  /// optional triggerKind: CompletionTriggerKind
  CompletionTriggerKind? get triggerKind;
  /// optional includeExternalModuleExports: boolean
  bool? get includeExternalModuleExports;
  /// optional includeInsertTextCompletions: boolean
  bool? get includeInsertTextCompletions;
}

/// interface CompletionsRequest extends FileLocationRequest  [ns: ts.server.protocol]
abstract class ServerProtocolCompletionsRequest {
  /// command: CommandTypes.Completions | CommandTypes.CompletionInfo
  Object? get command;
  /// arguments: CompletionsRequestArgs
  ServerProtocolCompletionsRequestArgs get arguments;
}

/// interface CompletionDetailsRequestArgs extends FileLocationRequestArgs  [ns: ts.server.protocol]
abstract class ServerProtocolCompletionDetailsRequestArgs {
  /// entryNames: (string | CompletionEntryIdentifier)[]
  List<Object?> get entryNames;
}

/// interface CompletionEntryIdentifier  [ns: ts.server.protocol]
abstract class ServerProtocolCompletionEntryIdentifier {
  /// name: string
  String get name;
  /// optional source: string
  String? get source;
  /// optional data: unknown
  Object? get data;
}

/// interface CompletionDetailsRequest extends FileLocationRequest  [ns: ts.server.protocol]
abstract class ServerProtocolCompletionDetailsRequest {
  /// command: CommandTypes.CompletionDetails
  ServerProtocolCommandTypes get command;
  /// arguments: CompletionDetailsRequestArgs
  ServerProtocolCompletionDetailsRequestArgs get arguments;
}

/// interface JSDocLinkDisplayPart extends SymbolDisplayPart  [ns: ts.server.protocol]
abstract class ServerProtocolJSDocLinkDisplayPart {
  /// target: FileSpan
  ServerProtocolFileSpan get target;
}

/// interface CompletionsResponse extends Response  [ns: ts.server.protocol]
abstract class ServerProtocolCompletionsResponse {
  /// optional body: CompletionEntry[]
  List<CompletionEntry>? get body;
}

/// interface CompletionInfoResponse extends Response  [ns: ts.server.protocol]
abstract class ServerProtocolCompletionInfoResponse {
  /// optional body: CompletionInfo
  CompletionInfo? get body;
}

/// interface CompletionDetailsResponse extends Response  [ns: ts.server.protocol]
abstract class ServerProtocolCompletionDetailsResponse {
  /// optional body: CompletionEntryDetails[]
  List<CompletionEntryDetails>? get body;
}

/// interface SignatureHelpItems  [ns: ts.server.protocol]
abstract class ServerProtocolSignatureHelpItems {
  /// items: SignatureHelpItem[]
  List<SignatureHelpItem> get items;
  /// applicableSpan: TextSpan
  TextSpan get applicableSpan;
  /// selectedItemIndex: number
  num get selectedItemIndex;
  /// argumentIndex: number
  num get argumentIndex;
  /// argumentCount: number
  num get argumentCount;
}

/// interface SignatureHelpRequestArgs extends FileLocationRequestArgs  [ns: ts.server.protocol]
abstract class ServerProtocolSignatureHelpRequestArgs {
  /// optional triggerReason: SignatureHelpTriggerReason
  SignatureHelpTriggerReason? get triggerReason;
}

/// interface SignatureHelpRequest extends FileLocationRequest  [ns: ts.server.protocol]
abstract class ServerProtocolSignatureHelpRequest {
  /// command: CommandTypes.SignatureHelp
  ServerProtocolCommandTypes get command;
  /// arguments: SignatureHelpRequestArgs
  ServerProtocolSignatureHelpRequestArgs get arguments;
}

/// interface SignatureHelpResponse extends Response  [ns: ts.server.protocol]
abstract class ServerProtocolSignatureHelpResponse {
  /// optional body: SignatureHelpItems
  SignatureHelpItems? get body;
}

/// interface InlayHintsRequestArgs extends FileRequestArgs  [ns: ts.server.protocol]
abstract class ServerProtocolInlayHintsRequestArgs {
  /// start: number
  num get start;
  /// length: number
  num get length;
}

/// interface InlayHintsRequest extends Request  [ns: ts.server.protocol]
abstract class ServerProtocolInlayHintsRequest {
  /// command: CommandTypes.ProvideInlayHints
  ServerProtocolCommandTypes get command;
  /// arguments: InlayHintsRequestArgs
  ServerProtocolInlayHintsRequestArgs get arguments;
}

/// interface InlayHintItemDisplayPart  [ns: ts.server.protocol]
abstract class ServerProtocolInlayHintItemDisplayPart {
  /// text: string
  String get text;
  /// optional span: FileSpan
  ServerProtocolFileSpan? get span;
}

/// interface InlayHintsResponse extends Response  [ns: ts.server.protocol]
abstract class ServerProtocolInlayHintsResponse {
  /// optional body: InlayHintItem[]
  List<ServerProtocolInlayHintItem>? get body;
}

/// interface MapCodeRequestArgs extends FileRequestArgs  [ns: ts.server.protocol]
abstract class ServerProtocolMapCodeRequestArgs {
  /// mapping: MapCodeRequestDocumentMapping
  ServerProtocolMapCodeRequestDocumentMapping get mapping;
}

/// interface MapCodeRequestDocumentMapping  [ns: ts.server.protocol]
abstract class ServerProtocolMapCodeRequestDocumentMapping {
  /// contents: string[]
  List<String> get contents;
  /// optional focusLocations: TextSpan[][]
  List<List<TextSpan>>? get focusLocations;
}

/// interface MapCodeRequest extends FileRequest  [ns: ts.server.protocol]
abstract class ServerProtocolMapCodeRequest {
  /// command: CommandTypes.MapCode
  ServerProtocolCommandTypes get command;
  /// arguments: MapCodeRequestArgs
  ServerProtocolMapCodeRequestArgs get arguments;
}

/// interface MapCodeResponse extends Response  [ns: ts.server.protocol]
abstract class ServerProtocolMapCodeResponse {
  /// body: readonly FileCodeEdits[]
  List<ServerProtocolFileCodeEdits> get body;
}

/// interface SemanticDiagnosticsSyncRequest extends FileRequest  [ns: ts.server.protocol]
abstract class ServerProtocolSemanticDiagnosticsSyncRequest {
  /// command: CommandTypes.SemanticDiagnosticsSync
  ServerProtocolCommandTypes get command;
  /// arguments: SemanticDiagnosticsSyncRequestArgs
  ServerProtocolSemanticDiagnosticsSyncRequestArgs get arguments;
}

/// interface SemanticDiagnosticsSyncRequestArgs extends FileRequestArgs  [ns: ts.server.protocol]
abstract class ServerProtocolSemanticDiagnosticsSyncRequestArgs {
  /// optional includeLinePosition: boolean
  bool? get includeLinePosition;
}

/// interface SemanticDiagnosticsSyncResponse extends Response  [ns: ts.server.protocol]
abstract class ServerProtocolSemanticDiagnosticsSyncResponse {
  /// optional body: Diagnostic[] | DiagnosticWithLinePosition[]
  Object? get body;
}

/// interface SuggestionDiagnosticsSyncRequest extends FileRequest  [ns: ts.server.protocol]
abstract class ServerProtocolSuggestionDiagnosticsSyncRequest {
  /// command: CommandTypes.SuggestionDiagnosticsSync
  ServerProtocolCommandTypes get command;
  /// arguments: SuggestionDiagnosticsSyncRequestArgs
  ServerProtocolSuggestionDiagnosticsSyncRequestArgs get arguments;
}

/// interface SyntacticDiagnosticsSyncRequest extends FileRequest  [ns: ts.server.protocol]
abstract class ServerProtocolSyntacticDiagnosticsSyncRequest {
  /// command: CommandTypes.SyntacticDiagnosticsSync
  ServerProtocolCommandTypes get command;
  /// arguments: SyntacticDiagnosticsSyncRequestArgs
  ServerProtocolSyntacticDiagnosticsSyncRequestArgs get arguments;
}

/// interface SyntacticDiagnosticsSyncRequestArgs extends FileRequestArgs  [ns: ts.server.protocol]
abstract class ServerProtocolSyntacticDiagnosticsSyncRequestArgs {
  /// optional includeLinePosition: boolean
  bool? get includeLinePosition;
}

/// interface SyntacticDiagnosticsSyncResponse extends Response  [ns: ts.server.protocol]
abstract class ServerProtocolSyntacticDiagnosticsSyncResponse {
  /// optional body: Diagnostic[] | DiagnosticWithLinePosition[]
  Object? get body;
}

/// interface GeterrForProjectRequestArgs  [ns: ts.server.protocol]
abstract class ServerProtocolGeterrForProjectRequestArgs {
  /// file: string
  String get file;
  /// delay: number
  num get delay;
}

/// interface GeterrForProjectRequest extends Request  [ns: ts.server.protocol]
abstract class ServerProtocolGeterrForProjectRequest {
  /// command: CommandTypes.GeterrForProject
  ServerProtocolCommandTypes get command;
  /// arguments: GeterrForProjectRequestArgs
  ServerProtocolGeterrForProjectRequestArgs get arguments;
}

/// interface GeterrRequestArgs  [ns: ts.server.protocol]
abstract class ServerProtocolGeterrRequestArgs {
  /// files: (string | FileRangesRequestArgs)[]
  List<Object?> get files;
  /// delay: number
  num get delay;
}

/// interface GeterrRequest extends Request  [ns: ts.server.protocol]
abstract class ServerProtocolGeterrRequest {
  /// command: CommandTypes.Geterr
  ServerProtocolCommandTypes get command;
  /// arguments: GeterrRequestArgs
  ServerProtocolGeterrRequestArgs get arguments;
}

/// interface FileRange  [ns: ts.server.protocol]
abstract class ServerProtocolFileRange {
  /// startLine: number
  num get startLine;
  /// startOffset: number
  num get startOffset;
  /// endLine: number
  num get endLine;
  /// endOffset: number
  num get endOffset;
}

/// interface FileRangesRequestArgs extends Pick<FileRequestArgs, "file">  [ns: ts.server.protocol]
abstract class ServerProtocolFileRangesRequestArgs {
  /// ranges: FileRange[]
  List<ServerProtocolFileRange> get ranges;
}

/// interface RequestCompletedEvent extends Event  [ns: ts.server.protocol]
abstract class ServerProtocolRequestCompletedEvent {
  /// event: RequestCompletedEventName
  ServerProtocolRequestCompletedEventName get event;
  /// body: RequestCompletedEventBody
  ServerProtocolRequestCompletedEventBody get body;
}

/// interface RequestCompletedEventBody  [ns: ts.server.protocol]
abstract class ServerProtocolRequestCompletedEventBody {
  /// request_seq: number
  num get request_seq;
  /// optional performanceData: PerformanceData
  ServerProtocolPerformanceData? get performanceData;
}

/// interface Diagnostic  [ns: ts.server.protocol]
abstract class ServerProtocolDiagnostic {
  /// start: Location
  ServerProtocolLocation get start;
  /// end: Location
  ServerProtocolLocation get end;
  /// text: string
  String get text;
  /// category: string
  String get category;
  /// optional reportsUnnecessary: {}
  Map<String, Object?>? get reportsUnnecessary;
  /// optional reportsDeprecated: {}
  Map<String, Object?>? get reportsDeprecated;
  /// optional relatedInformation: DiagnosticRelatedInformation[]
  List<DiagnosticRelatedInformation>? get relatedInformation;
  /// optional code: number
  num? get code;
  /// optional source: string
  String? get source;
}

/// interface DiagnosticWithFileName extends Diagnostic  [ns: ts.server.protocol]
abstract class ServerProtocolDiagnosticWithFileName {
  /// fileName: string
  String get fileName;
}

/// interface DiagnosticRelatedInformation  [ns: ts.server.protocol]
abstract class ServerProtocolDiagnosticRelatedInformation {
  /// category: string
  String get category;
  /// code: number
  num get code;
  /// message: string
  String get message;
  /// optional span: FileSpan
  ServerProtocolFileSpan? get span;
}

/// interface DiagnosticEventBody  [ns: ts.server.protocol]
abstract class ServerProtocolDiagnosticEventBody {
  /// file: string
  String get file;
  /// diagnostics: Diagnostic[]
  List<Diagnostic> get diagnostics;
  /// optional spans: TextSpan[]
  List<TextSpan>? get spans;
}

/// interface DiagnosticEvent extends Event  [ns: ts.server.protocol]
abstract class ServerProtocolDiagnosticEvent {
  /// optional body: DiagnosticEventBody
  ServerProtocolDiagnosticEventBody? get body;
  /// event: DiagnosticEventKind
  ServerProtocolDiagnosticEventKind get event;
}

/// interface ConfigFileDiagnosticEventBody  [ns: ts.server.protocol]
abstract class ServerProtocolConfigFileDiagnosticEventBody {
  /// triggerFile: string
  String get triggerFile;
  /// configFile: string
  String get configFile;
  /// diagnostics: DiagnosticWithFileName[]
  List<ServerProtocolDiagnosticWithFileName> get diagnostics;
}

/// interface ConfigFileDiagnosticEvent extends Event  [ns: ts.server.protocol]
abstract class ServerProtocolConfigFileDiagnosticEvent {
  /// optional body: ConfigFileDiagnosticEventBody
  ServerProtocolConfigFileDiagnosticEventBody? get body;
  /// event: "configFileDiag"
  String get event;
}

/// interface ProjectLanguageServiceStateEvent extends Event  [ns: ts.server.protocol]
abstract class ServerProtocolProjectLanguageServiceStateEvent {
  /// event: ProjectLanguageServiceStateEventName
  ServerProtocolProjectLanguageServiceStateEventName get event;
  /// optional body: ProjectLanguageServiceStateEventBody
  ServerProtocolProjectLanguageServiceStateEventBody? get body;
}

/// interface ProjectLanguageServiceStateEventBody  [ns: ts.server.protocol]
abstract class ServerProtocolProjectLanguageServiceStateEventBody {
  /// projectName: string
  String get projectName;
  /// languageServiceEnabled: boolean
  bool get languageServiceEnabled;
}

/// interface ProjectsUpdatedInBackgroundEvent extends Event  [ns: ts.server.protocol]
abstract class ServerProtocolProjectsUpdatedInBackgroundEvent {
  /// event: ProjectsUpdatedInBackgroundEventName
  ServerProtocolProjectsUpdatedInBackgroundEventName get event;
  /// body: ProjectsUpdatedInBackgroundEventBody
  ServerProtocolProjectsUpdatedInBackgroundEventBody get body;
}

/// interface ProjectsUpdatedInBackgroundEventBody  [ns: ts.server.protocol]
abstract class ServerProtocolProjectsUpdatedInBackgroundEventBody {
  /// openFiles: string[]
  List<String> get openFiles;
}

/// interface ProjectLoadingStartEvent extends Event  [ns: ts.server.protocol]
abstract class ServerProtocolProjectLoadingStartEvent {
  /// event: ProjectLoadingStartEventName
  ServerProtocolProjectLoadingStartEventName get event;
  /// body: ProjectLoadingStartEventBody
  ServerProtocolProjectLoadingStartEventBody get body;
}

/// interface ProjectLoadingStartEventBody  [ns: ts.server.protocol]
abstract class ServerProtocolProjectLoadingStartEventBody {
  /// projectName: string
  String get projectName;
  /// reason: string
  String get reason;
}

/// interface ProjectLoadingFinishEvent extends Event  [ns: ts.server.protocol]
abstract class ServerProtocolProjectLoadingFinishEvent {
  /// event: ProjectLoadingFinishEventName
  ServerProtocolProjectLoadingFinishEventName get event;
  /// body: ProjectLoadingFinishEventBody
  ServerProtocolProjectLoadingFinishEventBody get body;
}

/// interface ProjectLoadingFinishEventBody  [ns: ts.server.protocol]
abstract class ServerProtocolProjectLoadingFinishEventBody {
  /// projectName: string
  String get projectName;
}

/// interface SurveyReadyEvent extends Event  [ns: ts.server.protocol]
abstract class ServerProtocolSurveyReadyEvent {
  /// event: SurveyReadyEventName
  ServerProtocolSurveyReadyEventName get event;
  /// body: SurveyReadyEventBody
  ServerProtocolSurveyReadyEventBody get body;
}

/// interface SurveyReadyEventBody  [ns: ts.server.protocol]
abstract class ServerProtocolSurveyReadyEventBody {
  /// surveyId: string
  String get surveyId;
}

/// interface LargeFileReferencedEvent extends Event  [ns: ts.server.protocol]
abstract class ServerProtocolLargeFileReferencedEvent {
  /// event: LargeFileReferencedEventName
  ServerProtocolLargeFileReferencedEventName get event;
  /// body: LargeFileReferencedEventBody
  ServerProtocolLargeFileReferencedEventBody get body;
}

/// interface LargeFileReferencedEventBody  [ns: ts.server.protocol]
abstract class ServerProtocolLargeFileReferencedEventBody {
  /// file: string
  String get file;
  /// fileSize: number
  num get fileSize;
  /// maxFileSize: number
  num get maxFileSize;
}

/// interface CreateFileWatcherEvent extends Event  [ns: ts.server.protocol]
abstract class ServerProtocolCreateFileWatcherEvent {
  /// event: CreateFileWatcherEventName
  ServerProtocolCreateFileWatcherEventName get event;
  /// body: CreateFileWatcherEventBody
  ServerProtocolCreateFileWatcherEventBody get body;
}

/// interface CreateFileWatcherEventBody  [ns: ts.server.protocol]
abstract class ServerProtocolCreateFileWatcherEventBody {
  /// id: number
  num get id;
  /// path: string
  String get path;
}

/// interface CreateDirectoryWatcherEvent extends Event  [ns: ts.server.protocol]
abstract class ServerProtocolCreateDirectoryWatcherEvent {
  /// event: CreateDirectoryWatcherEventName
  ServerProtocolCreateDirectoryWatcherEventName get event;
  /// body: CreateDirectoryWatcherEventBody
  ServerProtocolCreateDirectoryWatcherEventBody get body;
}

/// interface CreateDirectoryWatcherEventBody  [ns: ts.server.protocol]
abstract class ServerProtocolCreateDirectoryWatcherEventBody {
  /// id: number
  num get id;
  /// path: string
  String get path;
  /// recursive: boolean
  bool get recursive;
  /// optional ignoreUpdate: boolean
  bool? get ignoreUpdate;
}

/// interface CloseFileWatcherEvent extends Event  [ns: ts.server.protocol]
abstract class ServerProtocolCloseFileWatcherEvent {
  /// event: CloseFileWatcherEventName
  ServerProtocolCloseFileWatcherEventName get event;
  /// body: CloseFileWatcherEventBody
  ServerProtocolCloseFileWatcherEventBody get body;
}

/// interface CloseFileWatcherEventBody  [ns: ts.server.protocol]
abstract class ServerProtocolCloseFileWatcherEventBody {
  /// id: number
  num get id;
}

/// interface ReloadRequestArgs extends FileRequestArgs  [ns: ts.server.protocol]
abstract class ServerProtocolReloadRequestArgs {
  /// tmpfile: string
  String get tmpfile;
}

/// interface ReloadRequest extends FileRequest  [ns: ts.server.protocol]
abstract class ServerProtocolReloadRequest {
  /// command: CommandTypes.Reload
  ServerProtocolCommandTypes get command;
  /// arguments: ReloadRequestArgs
  ServerProtocolReloadRequestArgs get arguments;
}

/// interface ReloadResponse extends Response  [ns: ts.server.protocol]
abstract class ServerProtocolReloadResponse {
}

/// interface SavetoRequestArgs extends FileRequestArgs  [ns: ts.server.protocol]
abstract class ServerProtocolSavetoRequestArgs {
  /// tmpfile: string
  String get tmpfile;
}

/// interface SavetoRequest extends FileRequest  [ns: ts.server.protocol]
abstract class ServerProtocolSavetoRequest {
  /// command: CommandTypes.Saveto
  ServerProtocolCommandTypes get command;
  /// arguments: SavetoRequestArgs
  ServerProtocolSavetoRequestArgs get arguments;
}

/// interface NavtoRequestArgs  [ns: ts.server.protocol]
abstract class ServerProtocolNavtoRequestArgs {
  /// searchValue: string
  String get searchValue;
  /// optional maxResultCount: number
  num? get maxResultCount;
  /// optional file: string
  String? get file;
  /// optional currentFileOnly: boolean
  bool? get currentFileOnly;
  /// optional projectFileName: string
  String? get projectFileName;
}

/// interface NavtoRequest extends Request  [ns: ts.server.protocol]
abstract class ServerProtocolNavtoRequest {
  /// command: CommandTypes.Navto
  ServerProtocolCommandTypes get command;
  /// arguments: NavtoRequestArgs
  ServerProtocolNavtoRequestArgs get arguments;
}

/// interface NavtoItem extends FileSpan  [ns: ts.server.protocol]
abstract class ServerProtocolNavtoItem {
  /// name: string
  String get name;
  /// kind: ScriptElementKind
  ScriptElementKind get kind;
  /// matchKind: string
  String get matchKind;
  /// isCaseSensitive: boolean
  bool get isCaseSensitive;
  /// optional kindModifiers: string
  String? get kindModifiers;
  /// optional containerName: string
  String? get containerName;
  /// optional containerKind: ScriptElementKind
  ScriptElementKind? get containerKind;
}

/// interface NavtoResponse extends Response  [ns: ts.server.protocol]
abstract class ServerProtocolNavtoResponse {
  /// optional body: NavtoItem[]
  List<ServerProtocolNavtoItem>? get body;
}

/// interface ChangeRequestArgs extends FormatRequestArgs  [ns: ts.server.protocol]
abstract class ServerProtocolChangeRequestArgs {
  /// optional insertString: string
  String? get insertString;
}

/// interface ChangeRequest extends FileLocationRequest  [ns: ts.server.protocol]
abstract class ServerProtocolChangeRequest {
  /// command: CommandTypes.Change
  ServerProtocolCommandTypes get command;
  /// arguments: ChangeRequestArgs
  ServerProtocolChangeRequestArgs get arguments;
}

/// interface BraceResponse extends Response  [ns: ts.server.protocol]
abstract class ServerProtocolBraceResponse {
  /// optional body: TextSpan[]
  List<TextSpan>? get body;
}

/// interface BraceRequest extends FileLocationRequest  [ns: ts.server.protocol]
abstract class ServerProtocolBraceRequest {
  /// command: CommandTypes.Brace
  ServerProtocolCommandTypes get command;
}

/// interface NavBarRequest extends FileRequest  [ns: ts.server.protocol]
abstract class ServerProtocolNavBarRequest {
  /// command: CommandTypes.NavBar
  ServerProtocolCommandTypes get command;
}

/// interface NavTreeRequest extends FileRequest  [ns: ts.server.protocol]
abstract class ServerProtocolNavTreeRequest {
  /// command: CommandTypes.NavTree
  ServerProtocolCommandTypes get command;
}

/// interface NavigationBarItem  [ns: ts.server.protocol]
abstract class ServerProtocolNavigationBarItem {
  /// text: string
  String get text;
  /// kind: ScriptElementKind
  ScriptElementKind get kind;
  /// optional kindModifiers: string
  String? get kindModifiers;
  /// spans: TextSpan[]
  List<TextSpan> get spans;
  /// optional childItems: NavigationBarItem[]
  List<NavigationBarItem>? get childItems;
  /// indent: number
  num get indent;
}

/// interface NavigationTree  [ns: ts.server.protocol]
abstract class ServerProtocolNavigationTree {
  /// text: string
  String get text;
  /// kind: ScriptElementKind
  ScriptElementKind get kind;
  /// kindModifiers: string
  String get kindModifiers;
  /// spans: TextSpan[]
  List<TextSpan> get spans;
  /// nameSpan: TextSpan | undefined
  TextSpan? get nameSpan;
  /// optional childItems: NavigationTree[]
  List<NavigationTree>? get childItems;
}

/// interface TelemetryEvent extends Event  [ns: ts.server.protocol]
abstract class ServerProtocolTelemetryEvent {
  /// event: TelemetryEventName
  ServerProtocolTelemetryEventName get event;
  /// body: TelemetryEventBody
  ServerProtocolTelemetryEventBody get body;
}

/// interface TelemetryEventBody  [ns: ts.server.protocol]
abstract class ServerProtocolTelemetryEventBody {
  /// telemetryEventName: string
  String get telemetryEventName;
  /// payload: any
  Object? get payload;
}

/// interface TypesInstallerInitializationFailedEvent extends Event  [ns: ts.server.protocol]
abstract class ServerProtocolTypesInstallerInitializationFailedEvent {
  /// event: TypesInstallerInitializationFailedEventName
  ServerProtocolTypesInstallerInitializationFailedEventName get event;
  /// body: TypesInstallerInitializationFailedEventBody
  ServerProtocolTypesInstallerInitializationFailedEventBody get body;
}

/// interface TypesInstallerInitializationFailedEventBody  [ns: ts.server.protocol]
abstract class ServerProtocolTypesInstallerInitializationFailedEventBody {
  /// message: string
  String get message;
}

/// interface TypingsInstalledTelemetryEventBody extends TelemetryEventBody  [ns: ts.server.protocol]
abstract class ServerProtocolTypingsInstalledTelemetryEventBody {
  /// telemetryEventName: TypingsInstalledTelemetryEventName
  ServerProtocolTypingsInstalledTelemetryEventName get telemetryEventName;
  /// payload: TypingsInstalledTelemetryEventPayload
  ServerProtocolTypingsInstalledTelemetryEventPayload get payload;
}

/// interface TypingsInstalledTelemetryEventPayload  [ns: ts.server.protocol]
abstract class ServerProtocolTypingsInstalledTelemetryEventPayload {
  /// installedPackages: string
  String get installedPackages;
  /// installSuccess: boolean
  bool get installSuccess;
  /// typingsInstallerVersion: string
  String get typingsInstallerVersion;
}

/// interface BeginInstallTypesEvent extends Event  [ns: ts.server.protocol]
abstract class ServerProtocolBeginInstallTypesEvent {
  /// event: BeginInstallTypesEventName
  ServerProtocolBeginInstallTypesEventName get event;
  /// body: BeginInstallTypesEventBody
  ServerProtocolBeginInstallTypesEventBody get body;
}

/// interface EndInstallTypesEvent extends Event  [ns: ts.server.protocol]
abstract class ServerProtocolEndInstallTypesEvent {
  /// event: EndInstallTypesEventName
  ServerProtocolEndInstallTypesEventName get event;
  /// body: EndInstallTypesEventBody
  ServerProtocolEndInstallTypesEventBody get body;
}

/// interface InstallTypesEventBody  [ns: ts.server.protocol]
abstract class ServerProtocolInstallTypesEventBody {
  /// eventId: number
  num get eventId;
  /// packages: readonly string[]
  List<String> get packages;
}

/// interface BeginInstallTypesEventBody extends InstallTypesEventBody  [ns: ts.server.protocol]
abstract class ServerProtocolBeginInstallTypesEventBody {
}

/// interface EndInstallTypesEventBody extends InstallTypesEventBody  [ns: ts.server.protocol]
abstract class ServerProtocolEndInstallTypesEventBody {
  /// success: boolean
  bool get success;
}

/// interface NavBarResponse extends Response  [ns: ts.server.protocol]
abstract class ServerProtocolNavBarResponse {
  /// optional body: NavigationBarItem[]
  List<NavigationBarItem>? get body;
}

/// interface NavTreeResponse extends Response  [ns: ts.server.protocol]
abstract class ServerProtocolNavTreeResponse {
  /// optional body: NavigationTree
  NavigationTree? get body;
}

/// interface CallHierarchyIncomingCall  [ns: ts.server.protocol]
abstract class ServerProtocolCallHierarchyIncomingCall {
  /// from: CallHierarchyItem
  CallHierarchyItem get from;
  /// fromSpans: TextSpan[]
  List<TextSpan> get fromSpans;
}

/// interface CallHierarchyOutgoingCall  [ns: ts.server.protocol]
abstract class ServerProtocolCallHierarchyOutgoingCall {
  /// to: CallHierarchyItem
  CallHierarchyItem get to;
  /// fromSpans: TextSpan[]
  List<TextSpan> get fromSpans;
}

/// interface PrepareCallHierarchyRequest extends FileLocationRequest  [ns: ts.server.protocol]
abstract class ServerProtocolPrepareCallHierarchyRequest {
  /// command: CommandTypes.PrepareCallHierarchy
  ServerProtocolCommandTypes get command;
}

/// interface PrepareCallHierarchyResponse extends Response  [ns: ts.server.protocol]
abstract class ServerProtocolPrepareCallHierarchyResponse {
  /// body: CallHierarchyItem | CallHierarchyItem[]
  Object? get body;
}

/// interface ProvideCallHierarchyIncomingCallsRequest extends FileLocationRequest  [ns: ts.server.protocol]
abstract class ServerProtocolProvideCallHierarchyIncomingCallsRequest {
  /// command: CommandTypes.ProvideCallHierarchyIncomingCalls
  ServerProtocolCommandTypes get command;
}

/// interface ProvideCallHierarchyIncomingCallsResponse extends Response  [ns: ts.server.protocol]
abstract class ServerProtocolProvideCallHierarchyIncomingCallsResponse {
  /// body: CallHierarchyIncomingCall[]
  List<CallHierarchyIncomingCall> get body;
}

/// interface ProvideCallHierarchyOutgoingCallsRequest extends FileLocationRequest  [ns: ts.server.protocol]
abstract class ServerProtocolProvideCallHierarchyOutgoingCallsRequest {
  /// command: CommandTypes.ProvideCallHierarchyOutgoingCalls
  ServerProtocolCommandTypes get command;
}

/// interface ProvideCallHierarchyOutgoingCallsResponse extends Response  [ns: ts.server.protocol]
abstract class ServerProtocolProvideCallHierarchyOutgoingCallsResponse {
  /// body: CallHierarchyOutgoingCall[]
  List<CallHierarchyOutgoingCall> get body;
}

/// interface Log  [ns: ts.server.typingsInstaller]
abstract class ServerTypingsInstallerLog {
  /// isEnabled(): boolean;
  bool isEnabled();
  /// writeLine(text: string): void;
  void writeLine(String text);
}

/// interface PendingRequest  [ns: ts.server.typingsInstaller]
abstract class ServerTypingsInstallerPendingRequest {
  /// requestId: number
  num get requestId;
  /// packageNames: string[]
  List<String> get packageNames;
  /// cwd: string
  String get cwd;
  /// onRequestCompleted: RequestCompletedAction
  ServerTypingsInstallerRequestCompletedAction get onRequestCompleted;
}

/// interface TypingInstallerResponse  [ns: ts.server]
abstract class ServerTypingInstallerResponse {
  /// kind: ActionSet | ActionInvalidate | EventTypesRegistry | ActionPackageInstalled | EventBeginInstallTypes | EventEndInstallTypes | EventInitializationFailed | ActionWatchTypingLocations
  Object? get kind;
}

/// interface TypingInstallerRequestWithProjectName  [ns: ts.server]
abstract class ServerTypingInstallerRequestWithProjectName {
  /// projectName: string
  String get projectName;
}

/// interface DiscoverTypings extends TypingInstallerRequestWithProjectName  [ns: ts.server]
abstract class ServerDiscoverTypings {
  /// fileNames: string[]
  List<String> get fileNames;
  /// projectRootPath: Path
  Path get projectRootPath;
  /// compilerOptions: CompilerOptions
  CompilerOptions get compilerOptions;
  /// typeAcquisition: TypeAcquisition
  TypeAcquisition get typeAcquisition;
  /// unresolvedImports: SortedReadonlyArray<string>
  List<String> get unresolvedImports;
  /// optional cachePath: string
  String? get cachePath;
  /// kind: "discover"
  String get kind;
}

/// interface CloseProject extends TypingInstallerRequestWithProjectName  [ns: ts.server]
abstract class ServerCloseProject {
  /// kind: "closeProject"
  String get kind;
}

/// interface TypesRegistryRequest  [ns: ts.server]
abstract class ServerTypesRegistryRequest {
  /// kind: "typesRegistry"
  String get kind;
}

/// interface InstallPackageRequest extends TypingInstallerRequestWithProjectName  [ns: ts.server]
abstract class ServerInstallPackageRequest {
  /// kind: "installPackage"
  String get kind;
  /// fileName: Path
  Path get fileName;
  /// packageName: string
  String get packageName;
  /// projectRootPath: Path
  Path get projectRootPath;
  /// id: number
  num get id;
}

/// interface PackageInstalledResponse extends ProjectResponse  [ns: ts.server]
abstract class ServerPackageInstalledResponse {
  /// kind: ActionPackageInstalled
  ServerActionPackageInstalled get kind;
  /// id: number
  num get id;
  /// success: boolean
  bool get success;
  /// message: string
  String get message;
}

/// interface InitializationFailedResponse extends TypingInstallerResponse  [ns: ts.server]
abstract class ServerInitializationFailedResponse {
  /// kind: EventInitializationFailed
  ServerEventInitializationFailed get kind;
  /// message: string
  String get message;
  /// optional stack: string
  String? get stack;
}

/// interface ProjectResponse extends TypingInstallerResponse  [ns: ts.server]
abstract class ServerProjectResponse {
  /// projectName: string
  String get projectName;
}

/// interface InvalidateCachedTypings extends ProjectResponse  [ns: ts.server]
abstract class ServerInvalidateCachedTypings {
  /// kind: ActionInvalidate
  ServerActionInvalidate get kind;
}

/// interface InstallTypes extends ProjectResponse  [ns: ts.server]
abstract class ServerInstallTypes {
  /// kind: EventBeginInstallTypes | EventEndInstallTypes
  Object? get kind;
  /// eventId: number
  num get eventId;
  /// typingsInstallerVersion: string
  String get typingsInstallerVersion;
  /// packagesToInstall: readonly string[]
  List<String> get packagesToInstall;
}

/// interface BeginInstallTypes extends InstallTypes  [ns: ts.server]
abstract class ServerBeginInstallTypes {
  /// kind: EventBeginInstallTypes
  ServerEventBeginInstallTypes get kind;
}

/// interface EndInstallTypes extends InstallTypes  [ns: ts.server]
abstract class ServerEndInstallTypes {
  /// kind: EventEndInstallTypes
  ServerEventEndInstallTypes get kind;
  /// installSuccess: boolean
  bool get installSuccess;
}

/// interface InstallTypingHost extends JsTyping.TypingResolutionHost  [ns: ts.server]
abstract class ServerInstallTypingHost {
  /// useCaseSensitiveFileNames: boolean
  bool get useCaseSensitiveFileNames;
  /// writeFile(path: string, content: string): void;
  void writeFile(String path, String content);
  /// createDirectory(path: string): void;
  void createDirectory(String path);
  /// getCurrentDirectory?(): string;
  String getCurrentDirectory();
}

/// interface SetTypings extends ProjectResponse  [ns: ts.server]
abstract class ServerSetTypings {
  /// typeAcquisition: TypeAcquisition
  TypeAcquisition get typeAcquisition;
  /// compilerOptions: CompilerOptions
  CompilerOptions get compilerOptions;
  /// typings: string[]
  List<String> get typings;
  /// unresolvedImports: SortedReadonlyArray<string>
  List<String> get unresolvedImports;
  /// kind: ActionSet
  ServerActionSet get kind;
}

/// interface WatchTypingLocations extends ProjectResponse  [ns: ts.server]
abstract class ServerWatchTypingLocations {
  /// files: readonly string[] | undefined
  List<String>? get files;
  /// kind: ActionWatchTypingLocations
  ServerActionWatchTypingLocations get kind;
}

/// interface CompressedData  [ns: ts.server]
abstract class ServerCompressedData {
  /// length: number
  num get length;
  /// compressionKind: string
  String get compressionKind;
  /// data: any
  Object? get data;
}

/// interface ServerHost extends System  [ns: ts.server]
abstract class ServerServerHost {
  /// watchFile(path: string, callback: FileWatcherCallback, pollingInterval?: number, options?: WatchOptions): FileWatcher;
  FileWatcher watchFile(String path, FileWatcherCallback callback, [num? pollingInterval, WatchOptions? options]);
  /// watchDirectory(path: string, callback: DirectoryWatcherCallback, recursive?: boolean, options?: WatchOptions): FileWatcher;
  FileWatcher watchDirectory(String path, DirectoryWatcherCallback callback, [bool? recursive, WatchOptions? options]);
  /// optional preferNonRecursiveWatch: boolean
  bool? get preferNonRecursiveWatch;
  /// setTimeout(callback: (...args: any[]) => void, ms: number, ...args: any[]): any;
  Object? setTimeout(Object? Function(Object?) callback, num ms, List<Object?> args);
  /// clearTimeout(timeoutId: any): void;
  void clearTimeout(Object? timeoutId);
  /// setImmediate(callback: (...args: any[]) => void, ...args: any[]): any;
  Object? setImmediate(Object? Function(Object?) callback, List<Object?> args);
  /// clearImmediate(timeoutId: any): void;
  void clearImmediate(Object? timeoutId);
  /// gc?(): void;
  void gc();
  /// trace?(s: string): void;
  void trace(String s);
  /// require?(initialPath: string, moduleName: string): ModuleImportResult;
  ServerModuleImportResult require(String initialPath, String moduleName);
}

/// interface InstallPackageOptionsWithProject extends InstallPackageOptions  [ns: ts.server]
abstract class ServerInstallPackageOptionsWithProject {
  /// projectName: string
  String get projectName;
  /// projectRootPath: Path
  Path get projectRootPath;
}

/// interface ITypingsInstaller  [ns: ts.server]
abstract class ServerITypingsInstaller {
  /// isKnownTypesPackageName(name: string): boolean;
  bool isKnownTypesPackageName(String name);
  /// installPackage(options: InstallPackageOptionsWithProject): Promise<ApplyCodeActionCommandResult>;
  Future<ApplyCodeActionCommandResult> installPackage(ServerInstallPackageOptionsWithProject options);
  /// enqueueInstallTypingsRequest(p: Project, typeAcquisition: TypeAcquisition, unresolvedImports: SortedReadonlyArray<string> | undefined): void;
  void enqueueInstallTypingsRequest(ServerProject p, TypeAcquisition typeAcquisition, List<String>? unresolvedImports);
  /// attach(projectService: ProjectService): void;
  void attach(ServerProjectService projectService);
  /// onProjectClosed(p: Project): void;
  void onProjectClosed(ServerProject p);
  /// globalTypingsCacheLocation: string | undefined
  String? get globalTypingsCacheLocation;
}

/// interface Logger  [ns: ts.server]
abstract class ServerLogger {
  /// close(): void;
  void close();
  /// hasLevel(level: LogLevel): boolean;
  bool hasLevel(ServerLogLevel level);
  /// loggingEnabled(): boolean;
  bool loggingEnabled();
  /// perftrc(s: string): void;
  void perftrc(String s);
  /// info(s: string): void;
  void info(String s);
  /// startGroup(): void;
  void startGroup();
  /// endGroup(): void;
  void endGroup();
  /// msg(s: string, type?: Msg): void;
  void msg(String s, [ServerMsg? type]);
  /// getLogFileName(): string | undefined;
  String? getLogFileName();
}

/// interface NormalizedPathMap  [ns: ts.server]
abstract class ServerNormalizedPathMap<T> {
  /// get(path: NormalizedPath): T | undefined;
  T? get_(ServerNormalizedPath path);
  /// set(path: NormalizedPath, value: T): void;
  void set_(ServerNormalizedPath path, T value);
  /// contains(path: NormalizedPath): boolean;
  bool contains(ServerNormalizedPath path);
  /// remove(path: NormalizedPath): void;
  void remove(ServerNormalizedPath path);
}

/// interface PluginCreateInfo  [ns: ts.server]
abstract class ServerPluginCreateInfo {
  /// project: Project
  ServerProject get project;
  /// languageService: LanguageService
  LanguageService get languageService;
  /// languageServiceHost: LanguageServiceHost
  LanguageServiceHost get languageServiceHost;
  /// serverHost: ServerHost
  ServerServerHost get serverHost;
  /// optional session: Session<unknown>
  ServerSession<Object?>? get session;
  /// config: any
  Object? get config;
}

/// interface PluginModule  [ns: ts.server]
abstract class ServerPluginModule {
  /// create(createInfo: PluginCreateInfo): LanguageService;
  LanguageService create(ServerPluginCreateInfo createInfo);
  /// getExternalFiles?(proj: Project, updateLevel: ProgramUpdateLevel): string[];
  List<String> getExternalFiles(ServerProject proj, ProgramUpdateLevel updateLevel);
  /// onConfigurationChanged?(config: any): void;
  void onConfigurationChanged(Object? config);
}

/// interface PluginModuleWithName  [ns: ts.server]
abstract class ServerPluginModuleWithName {
  /// name: string
  String get name;
  /// module: PluginModule
  ServerPluginModule get module;
}

/// interface ProjectsUpdatedInBackgroundEvent  [ns: ts.server]
abstract class ServerProjectsUpdatedInBackgroundEvent {
  /// eventName: typeof ProjectsUpdatedInBackgroundEvent
  Object? get eventName;
  /// data: { openFiles: string[]; }
  Map<String, Object?> get data;
}

/// interface ProjectLoadingStartEvent  [ns: ts.server]
abstract class ServerProjectLoadingStartEvent {
  /// eventName: typeof ProjectLoadingStartEvent
  Object? get eventName;
  /// data: { project: Project; reason: string; }
  Map<String, Object?> get data;
}

/// interface ProjectLoadingFinishEvent  [ns: ts.server]
abstract class ServerProjectLoadingFinishEvent {
  /// eventName: typeof ProjectLoadingFinishEvent
  Object? get eventName;
  /// data: { project: Project; }
  Map<String, Object?> get data;
}

/// interface LargeFileReferencedEvent  [ns: ts.server]
abstract class ServerLargeFileReferencedEvent {
  /// eventName: typeof LargeFileReferencedEvent
  Object? get eventName;
  /// data: { file: string; fileSize: number; maxFileSize: number; }
  Map<String, Object?> get data;
}

/// interface ConfigFileDiagEvent  [ns: ts.server]
abstract class ServerConfigFileDiagEvent {
  /// eventName: typeof ConfigFileDiagEvent
  Object? get eventName;
  /// data: { triggerFile: string; configFileName: string; diagnostics: readonly Diagnostic[]; }
  Map<String, Object?> get data;
}

/// interface ProjectLanguageServiceStateEvent  [ns: ts.server]
abstract class ServerProjectLanguageServiceStateEvent {
  /// eventName: typeof ProjectLanguageServiceStateEvent
  Object? get eventName;
  /// data: { project: Project; languageServiceEnabled: boolean; }
  Map<String, Object?> get data;
}

/// interface ProjectInfoTelemetryEvent  [ns: ts.server]
abstract class ServerProjectInfoTelemetryEvent {
  /// eventName: typeof ProjectInfoTelemetryEvent
  Object? get eventName;
  /// data: ProjectInfoTelemetryEventData
  ServerProjectInfoTelemetryEventData get data;
}

/// interface OpenFileInfoTelemetryEvent  [ns: ts.server]
abstract class ServerOpenFileInfoTelemetryEvent {
  /// eventName: typeof OpenFileInfoTelemetryEvent
  Object? get eventName;
  /// data: OpenFileInfoTelemetryEventData
  ServerOpenFileInfoTelemetryEventData get data;
}

/// interface CreateFileWatcherEvent  [ns: ts.server]
abstract class ServerCreateFileWatcherEvent {
  /// eventName: protocol.CreateFileWatcherEventName
  ServerProtocolCreateFileWatcherEventName get eventName;
  /// data: protocol.CreateFileWatcherEventBody
  ServerProtocolCreateFileWatcherEventBody get data;
}

/// interface CreateDirectoryWatcherEvent  [ns: ts.server]
abstract class ServerCreateDirectoryWatcherEvent {
  /// eventName: protocol.CreateDirectoryWatcherEventName
  ServerProtocolCreateDirectoryWatcherEventName get eventName;
  /// data: protocol.CreateDirectoryWatcherEventBody
  ServerProtocolCreateDirectoryWatcherEventBody get data;
}

/// interface CloseFileWatcherEvent  [ns: ts.server]
abstract class ServerCloseFileWatcherEvent {
  /// eventName: protocol.CloseFileWatcherEventName
  ServerProtocolCloseFileWatcherEventName get eventName;
  /// data: protocol.CloseFileWatcherEventBody
  ServerProtocolCloseFileWatcherEventBody get data;
}

/// interface ProjectInfoTelemetryEventData  [ns: ts.server]
abstract class ServerProjectInfoTelemetryEventData {
  /// projectId: string
  String get projectId;
  /// fileStats: FileStats
  ServerFileStats get fileStats;
  /// compilerOptions: CompilerOptions
  CompilerOptions get compilerOptions;
  /// extends: boolean | undefined
  bool? get extends_;
  /// files: boolean | undefined
  bool? get files;
  /// include: boolean | undefined
  bool? get include;
  /// exclude: boolean | undefined
  bool? get exclude;
  /// compileOnSave: boolean
  bool get compileOnSave;
  /// typeAcquisition: ProjectInfoTypeAcquisitionData
  ServerProjectInfoTypeAcquisitionData get typeAcquisition;
  /// configFileName: "tsconfig.json" | "jsconfig.json" | "other"
  Object? get configFileName;
  /// projectType: "external" | "configured"
  Object? get projectType;
  /// languageServiceEnabled: boolean
  bool get languageServiceEnabled;
  /// version: string
  String get version;
}

/// interface OpenFileInfoTelemetryEventData  [ns: ts.server]
abstract class ServerOpenFileInfoTelemetryEventData {
  /// info: OpenFileInfo
  ServerOpenFileInfo get info;
}

/// interface ProjectInfoTypeAcquisitionData  [ns: ts.server]
abstract class ServerProjectInfoTypeAcquisitionData {
  /// enable: boolean | undefined
  bool? get enable;
  /// include: boolean
  bool get include;
  /// exclude: boolean
  bool get exclude;
}

/// interface FileStats  [ns: ts.server]
abstract class ServerFileStats {
  /// js: number
  num get js;
  /// optional jsSize: number
  num? get jsSize;
  /// jsx: number
  num get jsx;
  /// optional jsxSize: number
  num? get jsxSize;
  /// ts: number
  num get ts;
  /// optional tsSize: number
  num? get tsSize;
  /// tsx: number
  num get tsx;
  /// optional tsxSize: number
  num? get tsxSize;
  /// dts: number
  num get dts;
  /// optional dtsSize: number
  num? get dtsSize;
  /// deferred: number
  num get deferred_;
  /// optional deferredSize: number
  num? get deferredSize;
}

/// interface OpenFileInfo  [ns: ts.server]
abstract class ServerOpenFileInfo {
  /// checkJs: boolean
  bool get checkJs;
}

/// interface SafeList  [ns: ts.server]
abstract class ServerSafeList {
  /// index signature: { match: RegExp; exclude?: (string | number)[][]; types?: string[]; }
}

/// interface TypesMapFile  [ns: ts.server]
abstract class ServerTypesMapFile {
  /// typesMap: SafeList
  ServerSafeList get typesMap;
  /// simpleMap: { [libName: string]: string; }
  Map<String, Object?> get simpleMap;
}

/// interface HostConfiguration  [ns: ts.server]
abstract class ServerHostConfiguration {
  /// formatCodeOptions: FormatCodeSettings
  FormatCodeSettings get formatCodeOptions;
  /// preferences: protocol.UserPreferences
  UserPreferences get preferences;
  /// hostInfo: string
  String get hostInfo;
  /// optional extraFileExtensions: FileExtensionInfo[]
  List<FileExtensionInfo>? get extraFileExtensions;
  /// optional watchOptions: WatchOptions
  WatchOptions? get watchOptions;
}

/// interface OpenConfiguredProjectResult  [ns: ts.server]
abstract class ServerOpenConfiguredProjectResult {
  /// optional configFileName: NormalizedPath
  ServerNormalizedPath? get configFileName;
  /// optional configFileErrors: readonly Diagnostic[]
  List<Diagnostic>? get configFileErrors;
}

/// interface ProjectServiceOptions  [ns: ts.server]
abstract class ServerProjectServiceOptions {
  /// host: ServerHost
  ServerServerHost get host;
  /// logger: Logger
  ServerLogger get logger;
  /// cancellationToken: HostCancellationToken
  HostCancellationToken get cancellationToken;
  /// useSingleInferredProject: boolean
  bool get useSingleInferredProject;
  /// useInferredProjectPerProjectRoot: boolean
  bool get useInferredProjectPerProjectRoot;
  /// optional typingsInstaller: ITypingsInstaller
  ServerITypingsInstaller? get typingsInstaller;
  /// optional eventHandler: ProjectServiceEventHandler
  ServerProjectServiceEventHandler? get eventHandler;
  /// optional canUseWatchEvents: boolean
  bool? get canUseWatchEvents;
  /// optional suppressDiagnosticEvents: boolean
  bool? get suppressDiagnosticEvents;
  /// optional throttleWaitMilliseconds: number
  num? get throttleWaitMilliseconds;
  /// optional globalPlugins: readonly string[]
  List<String>? get globalPlugins;
  /// optional pluginProbeLocations: readonly string[]
  List<String>? get pluginProbeLocations;
  /// optional allowLocalPluginLoads: boolean
  bool? get allowLocalPluginLoads;
  /// optional typesMapLocation: string
  String? get typesMapLocation;
  /// optional serverMode: LanguageServiceMode
  LanguageServiceMode? get serverMode;
  /// session: Session<unknown> | undefined
  ServerSession<Object?>? get session;
  /// optional jsDocParsingMode: JSDocParsingMode
  JSDocParsingMode? get jsDocParsingMode;
}

/// interface WatchOptionsAndErrors  [ns: ts.server]
abstract class ServerWatchOptionsAndErrors {
  /// watchOptions: WatchOptions
  WatchOptions get watchOptions;
  /// errors: Diagnostic[] | undefined
  List<Diagnostic>? get errors;
}

/// interface ServerCancellationToken extends HostCancellationToken  [ns: ts.server]
abstract class ServerServerCancellationToken {
  /// setRequest(requestId: number): void;
  void setRequest(num requestId);
  /// resetRequest(requestId: number): void;
  void resetRequest(num requestId);
}

/// interface EventSender  [ns: ts.server]
abstract class ServerEventSender {
  /// event: Event
  ServerProtocolEvent get event;
}

/// interface SessionOptions  [ns: ts.server]
abstract class ServerSessionOptions {
  /// host: ServerHost
  ServerServerHost get host;
  /// cancellationToken: ServerCancellationToken
  ServerServerCancellationToken get cancellationToken;
  /// useSingleInferredProject: boolean
  bool get useSingleInferredProject;
  /// useInferredProjectPerProjectRoot: boolean
  bool get useInferredProjectPerProjectRoot;
  /// optional typingsInstaller: ITypingsInstaller
  ServerITypingsInstaller? get typingsInstaller;
  /// byteLength: (buf: string, encoding?: BufferEncoding) => number
  Object? Function(Object?) get byteLength;
  /// hrtime: (start?: [ number, number, ]) => [ number, number, ]
  Object? Function(Object?) get hrtime;
  /// logger: Logger
  ServerLogger get logger;
  /// canUseEvents: boolean
  bool get canUseEvents;
  /// optional canUseWatchEvents: boolean
  bool? get canUseWatchEvents;
  /// optional eventHandler: ProjectServiceEventHandler
  ServerProjectServiceEventHandler? get eventHandler;
  /// optional suppressDiagnosticEvents: boolean
  bool? get suppressDiagnosticEvents;
  /// optional serverMode: LanguageServiceMode
  LanguageServiceMode? get serverMode;
  /// optional throttleWaitMilliseconds: number
  num? get throttleWaitMilliseconds;
  /// optional noGetErrOnBackgroundUpdate: boolean
  bool? get noGetErrOnBackgroundUpdate;
  /// optional globalPlugins: readonly string[]
  List<String>? get globalPlugins;
  /// optional pluginProbeLocations: readonly string[]
  List<String>? get pluginProbeLocations;
  /// optional allowLocalPluginLoads: boolean
  bool? get allowLocalPluginLoads;
  /// optional typesMapLocation: string
  String? get typesMapLocation;
}

/// interface HandlerResponse  [ns: ts.server]
abstract class ServerHandlerResponse {
  /// optional response: {}
  Map<String, Object?>? get response;
  /// optional responseRequired: boolean
  bool? get responseRequired;
}

/// interface TypingResolutionHost  [ns: ts.JsTyping]
abstract class JsTypingTypingResolutionHost {
  /// directoryExists(path: string): boolean;
  bool directoryExists(String path);
  /// fileExists(fileName: string): boolean;
  bool fileExists(String fileName);
  /// readFile(path: string, encoding?: string): string | undefined;
  String? readFile(String path, [String? encoding]);
  /// readDirectory(rootDir: string, extensions: readonly string[], excludes: readonly string[] | undefined, includes: readonly string[] | undefined, depth?: number): string[];
  List<String> readDirectory(String rootDir, List<String> extensions, List<String>? excludes, List<String>? includes, [num? depth]);
}

/// interface MapLike
abstract class MapLike<T> {
  /// index signature: T
}

/// interface SortedReadonlyArray extends ReadonlyArray<T>
abstract class SortedReadonlyArray<T> {
  /// " __sortedArrayBrand": any
  Object? get sortedArrayBrand;
}

/// interface SortedArray extends Array<T>
abstract class SortedArray<T> {
  /// " __sortedArrayBrand": any
  Object? get sortedArrayBrand;
}

/// interface TextRange
abstract class TextRange {
  /// pos: number
  num get pos;
  /// end: number
  num get end;
}

/// interface ReadonlyTextRange
abstract class ReadonlyTextRange {
  /// pos: number
  num get pos;
  /// end: number
  num get end;
}

/// interface Node extends ReadonlyTextRange
abstract class Node {
  /// kind: SyntaxKind
  SyntaxKind get kind;
  /// flags: NodeFlags
  NodeFlags get flags;
  /// parent: Node
  Node get parent;
  /// getSourceFile(): SourceFile;
  SourceFile getSourceFile();
  /// getChildCount(sourceFile?: SourceFile): number;
  num getChildCount([SourceFile? sourceFile]);
  /// getChildAt(index: number, sourceFile?: SourceFile): Node;
  Node getChildAt(num index, [SourceFile? sourceFile]);
  /// getChildren(sourceFile?: SourceFile): readonly Node[];
  List<Node> getChildren([SourceFile? sourceFile]);
  /// getStart(sourceFile?: SourceFile, includeJsDocComment?: boolean): number;
  num getStart([SourceFile? sourceFile, bool? includeJsDocComment]);
  /// getFullStart(): number;
  num getFullStart();
  /// getEnd(): number;
  num getEnd();
  /// getWidth(sourceFile?: SourceFileLike): number;
  num getWidth([SourceFileLike? sourceFile]);
  /// getFullWidth(): number;
  num getFullWidth();
  /// getLeadingTriviaWidth(sourceFile?: SourceFile): number;
  num getLeadingTriviaWidth([SourceFile? sourceFile]);
  /// getFullText(sourceFile?: SourceFile): string;
  String getFullText([SourceFile? sourceFile]);
  /// getText(sourceFile?: SourceFile): string;
  String getText([SourceFile? sourceFile]);
  /// getFirstToken(sourceFile?: SourceFile): Node | undefined;
  Node? getFirstToken([SourceFile? sourceFile]);
  /// getLastToken(sourceFile?: SourceFile): Node | undefined;
  Node? getLastToken([SourceFile? sourceFile]);
  /// forEachChild<T>(cbNode: (node: Node) => T | undefined, cbNodeArray?: (nodes: NodeArray<Node>) => T | undefined): T | undefined;
  T? forEachChild<T>(Object? Function(Object?) cbNode, [Object? Function(Object?)? cbNodeArray]);
}

/// interface JSDocContainer extends Node
abstract class JSDocContainer {
  /// _jsdocContainerBrand: any
  Object? get jsdocContainerBrand;
}

/// interface LocalsContainer extends Node
abstract class LocalsContainer {
  /// _localsContainerBrand: any
  Object? get localsContainerBrand;
}

/// interface FlowContainer extends Node
abstract class FlowContainer {
  /// _flowContainerBrand: any
  Object? get flowContainerBrand;
}

/// interface NodeArray extends ReadonlyArray<T>, ReadonlyTextRange
abstract class NodeArray<T> {
  /// hasTrailingComma: boolean
  bool get hasTrailingComma;
}

/// interface Token extends Node
abstract class Token<TKind> {
  /// kind: TKind
  TKind get kind;
}

/// interface PunctuationToken extends Token<TKind>
abstract class PunctuationToken<TKind> {
}

/// interface KeywordToken extends Token<TKind>
abstract class KeywordToken<TKind> {
}

/// interface ModifierToken extends KeywordToken<TKind>
abstract class ModifierToken<TKind> {
}

/// interface Identifier extends PrimaryExpression, Declaration, JSDocContainer, FlowContainer
abstract class Identifier {
  /// kind: SyntaxKind.Identifier
  SyntaxKind get kind;
  /// escapedText: __String
  __String get escapedText;
  /// text: string
  String get text;
}

/// interface TransientIdentifier extends Identifier
abstract class TransientIdentifier {
  /// resolvedSymbol: Symbol
  Symbol get resolvedSymbol;
}

/// interface QualifiedName extends Node, FlowContainer
abstract class QualifiedName {
  /// kind: SyntaxKind.QualifiedName
  SyntaxKind get kind;
  /// left: EntityName
  EntityName get left;
  /// right: Identifier
  Identifier get right;
}

/// interface Declaration extends Node
abstract class Declaration {
  /// _declarationBrand: any
  Object? get declarationBrand;
}

/// interface NamedDeclaration extends Declaration
abstract class NamedDeclaration {
  /// optional name: DeclarationName
  DeclarationName? get name;
}

/// interface DeclarationStatement extends NamedDeclaration, Statement
abstract class DeclarationStatement {
  /// optional name: Identifier | StringLiteral | NumericLiteral
  Object? get name;
}

/// interface ComputedPropertyName extends Node
abstract class ComputedPropertyName {
  /// kind: SyntaxKind.ComputedPropertyName
  SyntaxKind get kind;
  /// parent: Declaration
  Declaration get parent;
  /// expression: Expression
  Expression get expression;
}

/// interface PrivateIdentifier extends PrimaryExpression
abstract class PrivateIdentifier {
  /// kind: SyntaxKind.PrivateIdentifier
  SyntaxKind get kind;
  /// escapedText: __String
  __String get escapedText;
  /// text: string
  String get text;
}

/// interface Decorator extends Node
abstract class Decorator {
  /// kind: SyntaxKind.Decorator
  SyntaxKind get kind;
  /// parent: NamedDeclaration
  NamedDeclaration get parent;
  /// expression: LeftHandSideExpression
  LeftHandSideExpression get expression;
}

/// interface TypeParameterDeclaration extends NamedDeclaration, JSDocContainer
abstract class TypeParameterDeclaration {
  /// kind: SyntaxKind.TypeParameter
  SyntaxKind get kind;
  /// parent: DeclarationWithTypeParameterChildren | InferTypeNode
  Object? get parent;
  /// optional modifiers: NodeArray<Modifier>
  NodeArray<Modifier>? get modifiers;
  /// name: Identifier
  Identifier get name;
  /// optional constraint: TypeNode
  TypeNode? get constraint;
  /// optional default: TypeNode
  TypeNode? get default_;
  /// optional expression: Expression
  Expression? get expression;
}

/// interface SignatureDeclarationBase extends NamedDeclaration, JSDocContainer
abstract class SignatureDeclarationBase {
  /// kind: SignatureDeclaration["kind"]
  Object? get kind;
  /// optional name: PropertyName
  PropertyName? get name;
  /// optional typeParameters: NodeArray<TypeParameterDeclaration> | undefined
  NodeArray<TypeParameterDeclaration>? get typeParameters;
  /// parameters: NodeArray<ParameterDeclaration>
  NodeArray<ParameterDeclaration> get parameters;
  /// optional type: TypeNode | undefined
  TypeNode? get type;
}

/// interface CallSignatureDeclaration extends SignatureDeclarationBase, TypeElement, LocalsContainer
abstract class CallSignatureDeclaration {
  /// kind: SyntaxKind.CallSignature
  SyntaxKind get kind;
}

/// interface ConstructSignatureDeclaration extends SignatureDeclarationBase, TypeElement, LocalsContainer
abstract class ConstructSignatureDeclaration {
  /// kind: SyntaxKind.ConstructSignature
  SyntaxKind get kind;
}

/// interface VariableDeclaration extends NamedDeclaration, JSDocContainer
abstract class VariableDeclaration {
  /// kind: SyntaxKind.VariableDeclaration
  SyntaxKind get kind;
  /// parent: VariableDeclarationList | CatchClause
  Object? get parent;
  /// name: BindingName
  BindingName get name;
  /// optional exclamationToken: ExclamationToken
  ExclamationToken? get exclamationToken;
  /// optional type: TypeNode
  TypeNode? get type;
  /// optional initializer: Expression
  Expression? get initializer;
}

/// interface VariableDeclarationList extends Node
abstract class VariableDeclarationList {
  /// kind: SyntaxKind.VariableDeclarationList
  SyntaxKind get kind;
  /// parent: VariableStatement | ForStatement | ForOfStatement | ForInStatement
  Object? get parent;
  /// declarations: NodeArray<VariableDeclaration>
  NodeArray<VariableDeclaration> get declarations;
}

/// interface ParameterDeclaration extends NamedDeclaration, JSDocContainer
abstract class ParameterDeclaration {
  /// kind: SyntaxKind.Parameter
  SyntaxKind get kind;
  /// parent: SignatureDeclaration
  SignatureDeclaration get parent;
  /// optional modifiers: NodeArray<ModifierLike>
  NodeArray<ModifierLike>? get modifiers;
  /// optional dotDotDotToken: DotDotDotToken
  DotDotDotToken? get dotDotDotToken;
  /// name: BindingName
  BindingName get name;
  /// optional questionToken: QuestionToken
  QuestionToken? get questionToken;
  /// optional type: TypeNode
  TypeNode? get type;
  /// optional initializer: Expression
  Expression? get initializer;
}

/// interface BindingElement extends NamedDeclaration, FlowContainer
abstract class BindingElement {
  /// kind: SyntaxKind.BindingElement
  SyntaxKind get kind;
  /// parent: BindingPattern
  BindingPattern get parent;
  /// optional propertyName: PropertyName
  PropertyName? get propertyName;
  /// optional dotDotDotToken: DotDotDotToken
  DotDotDotToken? get dotDotDotToken;
  /// name: BindingName
  BindingName get name;
  /// optional initializer: Expression
  Expression? get initializer;
}

/// interface PropertySignature extends TypeElement, JSDocContainer
abstract class PropertySignature {
  /// kind: SyntaxKind.PropertySignature
  SyntaxKind get kind;
  /// parent: TypeLiteralNode | InterfaceDeclaration
  Object? get parent;
  /// optional modifiers: NodeArray<Modifier>
  NodeArray<Modifier>? get modifiers;
  /// name: PropertyName
  PropertyName get name;
  /// optional questionToken: QuestionToken
  QuestionToken? get questionToken;
  /// optional type: TypeNode
  TypeNode? get type;
}

/// interface PropertyDeclaration extends ClassElement, JSDocContainer
abstract class PropertyDeclaration {
  /// kind: SyntaxKind.PropertyDeclaration
  SyntaxKind get kind;
  /// parent: ClassLikeDeclaration
  ClassLikeDeclaration get parent;
  /// optional modifiers: NodeArray<ModifierLike>
  NodeArray<ModifierLike>? get modifiers;
  /// name: PropertyName
  PropertyName get name;
  /// optional questionToken: QuestionToken
  QuestionToken? get questionToken;
  /// optional exclamationToken: ExclamationToken
  ExclamationToken? get exclamationToken;
  /// optional type: TypeNode
  TypeNode? get type;
  /// optional initializer: Expression
  Expression? get initializer;
}

/// interface AutoAccessorPropertyDeclaration extends PropertyDeclaration
abstract class AutoAccessorPropertyDeclaration {
  /// _autoAccessorBrand: any
  Object? get autoAccessorBrand;
}

/// interface ObjectLiteralElement extends NamedDeclaration
abstract class ObjectLiteralElement {
  /// _objectLiteralBrand: any
  Object? get objectLiteralBrand;
  /// optional name: PropertyName
  PropertyName? get name;
}

/// interface PropertyAssignment extends ObjectLiteralElement, JSDocContainer
abstract class PropertyAssignment {
  /// kind: SyntaxKind.PropertyAssignment
  SyntaxKind get kind;
  /// parent: ObjectLiteralExpression
  ObjectLiteralExpression get parent;
  /// name: PropertyName
  PropertyName get name;
  /// initializer: Expression
  Expression get initializer;
}

/// interface ShorthandPropertyAssignment extends ObjectLiteralElement, JSDocContainer
abstract class ShorthandPropertyAssignment {
  /// kind: SyntaxKind.ShorthandPropertyAssignment
  SyntaxKind get kind;
  /// parent: ObjectLiteralExpression
  ObjectLiteralExpression get parent;
  /// name: Identifier
  Identifier get name;
  /// optional equalsToken: EqualsToken
  EqualsToken? get equalsToken;
  /// optional objectAssignmentInitializer: Expression
  Expression? get objectAssignmentInitializer;
}

/// interface SpreadAssignment extends ObjectLiteralElement, JSDocContainer
abstract class SpreadAssignment {
  /// kind: SyntaxKind.SpreadAssignment
  SyntaxKind get kind;
  /// parent: ObjectLiteralExpression
  ObjectLiteralExpression get parent;
  /// expression: Expression
  Expression get expression;
}

/// interface ObjectBindingPattern extends Node
abstract class ObjectBindingPattern {
  /// kind: SyntaxKind.ObjectBindingPattern
  SyntaxKind get kind;
  /// parent: VariableDeclaration | ParameterDeclaration | BindingElement
  Object? get parent;
  /// elements: NodeArray<BindingElement>
  NodeArray<BindingElement> get elements;
}

/// interface ArrayBindingPattern extends Node
abstract class ArrayBindingPattern {
  /// kind: SyntaxKind.ArrayBindingPattern
  SyntaxKind get kind;
  /// parent: VariableDeclaration | ParameterDeclaration | BindingElement
  Object? get parent;
  /// elements: NodeArray<ArrayBindingElement>
  NodeArray<ArrayBindingElement> get elements;
}

/// interface FunctionLikeDeclarationBase extends SignatureDeclarationBase
abstract class FunctionLikeDeclarationBase {
  /// _functionLikeDeclarationBrand: any
  Object? get functionLikeDeclarationBrand;
  /// optional asteriskToken: AsteriskToken | undefined
  AsteriskToken? get asteriskToken;
  /// optional questionToken: QuestionToken | undefined
  QuestionToken? get questionToken;
  /// optional exclamationToken: ExclamationToken | undefined
  ExclamationToken? get exclamationToken;
  /// optional body: Block | Expression | undefined
  Object? get body;
}

/// interface FunctionDeclaration extends FunctionLikeDeclarationBase, DeclarationStatement, LocalsContainer
abstract class FunctionDeclaration {
  /// kind: SyntaxKind.FunctionDeclaration
  SyntaxKind get kind;
  /// optional modifiers: NodeArray<ModifierLike>
  NodeArray<ModifierLike>? get modifiers;
  /// optional name: Identifier
  Identifier? get name;
  /// optional body: FunctionBody
  FunctionBody? get body;
}

/// interface MethodSignature extends SignatureDeclarationBase, TypeElement, LocalsContainer
abstract class MethodSignature {
  /// kind: SyntaxKind.MethodSignature
  SyntaxKind get kind;
  /// parent: TypeLiteralNode | InterfaceDeclaration
  Object? get parent;
  /// optional modifiers: NodeArray<Modifier>
  NodeArray<Modifier>? get modifiers;
  /// name: PropertyName
  PropertyName get name;
}

/// interface MethodDeclaration extends FunctionLikeDeclarationBase, ClassElement, ObjectLiteralElement, JSDocContainer, LocalsContainer, FlowContainer
abstract class MethodDeclaration {
  /// kind: SyntaxKind.MethodDeclaration
  SyntaxKind get kind;
  /// parent: ClassLikeDeclaration | ObjectLiteralExpression
  Object? get parent;
  /// optional modifiers: NodeArray<ModifierLike> | undefined
  NodeArray<ModifierLike>? get modifiers;
  /// name: PropertyName
  PropertyName get name;
  /// optional body: FunctionBody | undefined
  FunctionBody? get body;
}

/// interface ConstructorDeclaration extends FunctionLikeDeclarationBase, ClassElement, JSDocContainer, LocalsContainer
abstract class ConstructorDeclaration {
  /// kind: SyntaxKind.Constructor
  SyntaxKind get kind;
  /// parent: ClassLikeDeclaration
  ClassLikeDeclaration get parent;
  /// optional modifiers: NodeArray<ModifierLike> | undefined
  NodeArray<ModifierLike>? get modifiers;
  /// optional body: FunctionBody | undefined
  FunctionBody? get body;
}

/// interface SemicolonClassElement extends ClassElement, JSDocContainer
abstract class SemicolonClassElement {
  /// kind: SyntaxKind.SemicolonClassElement
  SyntaxKind get kind;
  /// parent: ClassLikeDeclaration
  ClassLikeDeclaration get parent;
}

/// interface GetAccessorDeclaration extends FunctionLikeDeclarationBase, ClassElement, TypeElement, ObjectLiteralElement, JSDocContainer, LocalsContainer, FlowContainer
abstract class GetAccessorDeclaration {
  /// kind: SyntaxKind.GetAccessor
  SyntaxKind get kind;
  /// parent: ClassLikeDeclaration | ObjectLiteralExpression | TypeLiteralNode | InterfaceDeclaration
  Object? get parent;
  /// optional modifiers: NodeArray<ModifierLike>
  NodeArray<ModifierLike>? get modifiers;
  /// name: PropertyName
  PropertyName get name;
  /// optional body: FunctionBody
  FunctionBody? get body;
}

/// interface SetAccessorDeclaration extends FunctionLikeDeclarationBase, ClassElement, TypeElement, ObjectLiteralElement, JSDocContainer, LocalsContainer, FlowContainer
abstract class SetAccessorDeclaration {
  /// kind: SyntaxKind.SetAccessor
  SyntaxKind get kind;
  /// parent: ClassLikeDeclaration | ObjectLiteralExpression | TypeLiteralNode | InterfaceDeclaration
  Object? get parent;
  /// optional modifiers: NodeArray<ModifierLike>
  NodeArray<ModifierLike>? get modifiers;
  /// name: PropertyName
  PropertyName get name;
  /// optional body: FunctionBody
  FunctionBody? get body;
}

/// interface IndexSignatureDeclaration extends SignatureDeclarationBase, ClassElement, TypeElement, LocalsContainer
abstract class IndexSignatureDeclaration {
  /// kind: SyntaxKind.IndexSignature
  SyntaxKind get kind;
  /// parent: ObjectTypeDeclaration
  ObjectTypeDeclaration get parent;
  /// optional modifiers: NodeArray<ModifierLike>
  NodeArray<ModifierLike>? get modifiers;
  /// type: TypeNode
  TypeNode get type;
}

/// interface ClassStaticBlockDeclaration extends ClassElement, JSDocContainer, LocalsContainer
abstract class ClassStaticBlockDeclaration {
  /// kind: SyntaxKind.ClassStaticBlockDeclaration
  SyntaxKind get kind;
  /// parent: ClassDeclaration | ClassExpression
  Object? get parent;
  /// body: Block
  Block get body;
}

/// interface TypeNode extends Node
abstract class TypeNode {
  /// _typeNodeBrand: any
  Object? get typeNodeBrand;
}

/// interface KeywordTypeNode extends KeywordToken<TKind>, TypeNode
abstract class KeywordTypeNode<TKind> {
  /// kind: TKind
  TKind get kind;
}

/// interface ImportTypeAssertionContainer extends Node
abstract class ImportTypeAssertionContainer {
  /// kind: SyntaxKind.ImportTypeAssertionContainer
  SyntaxKind get kind;
  /// parent: ImportTypeNode
  ImportTypeNode get parent;
  /// assertClause: AssertClause
  AssertClause get assertClause;
  /// optional multiLine: boolean
  bool? get multiLine;
}

/// interface ImportTypeNode extends NodeWithTypeArguments
abstract class ImportTypeNode {
  /// kind: SyntaxKind.ImportType
  SyntaxKind get kind;
  /// isTypeOf: boolean
  bool get isTypeOf;
  /// argument: TypeNode
  TypeNode get argument;
  /// optional assertions: ImportTypeAssertionContainer
  ImportTypeAssertionContainer? get assertions;
  /// optional attributes: ImportAttributes
  ImportAttributes? get attributes;
  /// optional qualifier: EntityName
  EntityName? get qualifier;
}

/// interface ThisTypeNode extends TypeNode
abstract class ThisTypeNode {
  /// kind: SyntaxKind.ThisType
  SyntaxKind get kind;
}

/// interface FunctionOrConstructorTypeNodeBase extends TypeNode, SignatureDeclarationBase
abstract class FunctionOrConstructorTypeNodeBase {
  /// kind: SyntaxKind.FunctionType | SyntaxKind.ConstructorType
  Object? get kind;
  /// type: TypeNode
  TypeNode get type;
}

/// interface FunctionTypeNode extends FunctionOrConstructorTypeNodeBase, LocalsContainer
abstract class FunctionTypeNode {
  /// kind: SyntaxKind.FunctionType
  SyntaxKind get kind;
}

/// interface ConstructorTypeNode extends FunctionOrConstructorTypeNodeBase, LocalsContainer
abstract class ConstructorTypeNode {
  /// kind: SyntaxKind.ConstructorType
  SyntaxKind get kind;
  /// optional modifiers: NodeArray<Modifier>
  NodeArray<Modifier>? get modifiers;
}

/// interface NodeWithTypeArguments extends TypeNode
abstract class NodeWithTypeArguments {
  /// optional typeArguments: NodeArray<TypeNode>
  NodeArray<TypeNode>? get typeArguments;
}

/// interface TypeReferenceNode extends NodeWithTypeArguments
abstract class TypeReferenceNode {
  /// kind: SyntaxKind.TypeReference
  SyntaxKind get kind;
  /// typeName: EntityName
  EntityName get typeName;
}

/// interface TypePredicateNode extends TypeNode
abstract class TypePredicateNode {
  /// kind: SyntaxKind.TypePredicate
  SyntaxKind get kind;
  /// parent: SignatureDeclaration | JSDocTypeExpression
  Object? get parent;
  /// optional assertsModifier: AssertsKeyword
  AssertsKeyword? get assertsModifier;
  /// parameterName: Identifier | ThisTypeNode
  Object? get parameterName;
  /// optional type: TypeNode
  TypeNode? get type;
}

/// interface TypeQueryNode extends NodeWithTypeArguments
abstract class TypeQueryNode {
  /// kind: SyntaxKind.TypeQuery
  SyntaxKind get kind;
  /// exprName: EntityName
  EntityName get exprName;
}

/// interface TypeLiteralNode extends TypeNode, Declaration
abstract class TypeLiteralNode {
  /// kind: SyntaxKind.TypeLiteral
  SyntaxKind get kind;
  /// members: NodeArray<TypeElement>
  NodeArray<TypeElement> get members;
}

/// interface ArrayTypeNode extends TypeNode
abstract class ArrayTypeNode {
  /// kind: SyntaxKind.ArrayType
  SyntaxKind get kind;
  /// elementType: TypeNode
  TypeNode get elementType;
}

/// interface TupleTypeNode extends TypeNode
abstract class TupleTypeNode {
  /// kind: SyntaxKind.TupleType
  SyntaxKind get kind;
  /// elements: NodeArray<TypeNode | NamedTupleMember>
  NodeArray<Object?> get elements;
}

/// interface NamedTupleMember extends TypeNode, Declaration, JSDocContainer
abstract class NamedTupleMember {
  /// kind: SyntaxKind.NamedTupleMember
  SyntaxKind get kind;
  /// optional dotDotDotToken: Token<SyntaxKind.DotDotDotToken>
  Token<SyntaxKind>? get dotDotDotToken;
  /// name: Identifier
  Identifier get name;
  /// optional questionToken: Token<SyntaxKind.QuestionToken>
  Token<SyntaxKind>? get questionToken;
  /// type: TypeNode
  TypeNode get type;
}

/// interface OptionalTypeNode extends TypeNode
abstract class OptionalTypeNode {
  /// kind: SyntaxKind.OptionalType
  SyntaxKind get kind;
  /// type: TypeNode
  TypeNode get type;
}

/// interface RestTypeNode extends TypeNode
abstract class RestTypeNode {
  /// kind: SyntaxKind.RestType
  SyntaxKind get kind;
  /// type: TypeNode
  TypeNode get type;
}

/// interface UnionTypeNode extends TypeNode
abstract class UnionTypeNode {
  /// kind: SyntaxKind.UnionType
  SyntaxKind get kind;
  /// types: NodeArray<TypeNode>
  NodeArray<TypeNode> get types;
}

/// interface IntersectionTypeNode extends TypeNode
abstract class IntersectionTypeNode {
  /// kind: SyntaxKind.IntersectionType
  SyntaxKind get kind;
  /// types: NodeArray<TypeNode>
  NodeArray<TypeNode> get types;
}

/// interface ConditionalTypeNode extends TypeNode, LocalsContainer
abstract class ConditionalTypeNode {
  /// kind: SyntaxKind.ConditionalType
  SyntaxKind get kind;
  /// checkType: TypeNode
  TypeNode get checkType;
  /// extendsType: TypeNode
  TypeNode get extendsType;
  /// trueType: TypeNode
  TypeNode get trueType;
  /// falseType: TypeNode
  TypeNode get falseType;
}

/// interface InferTypeNode extends TypeNode
abstract class InferTypeNode {
  /// kind: SyntaxKind.InferType
  SyntaxKind get kind;
  /// typeParameter: TypeParameterDeclaration
  TypeParameterDeclaration get typeParameter;
}

/// interface ParenthesizedTypeNode extends TypeNode
abstract class ParenthesizedTypeNode {
  /// kind: SyntaxKind.ParenthesizedType
  SyntaxKind get kind;
  /// type: TypeNode
  TypeNode get type;
}

/// interface TypeOperatorNode extends TypeNode
abstract class TypeOperatorNode {
  /// kind: SyntaxKind.TypeOperator
  SyntaxKind get kind;
  /// operator: SyntaxKind.KeyOfKeyword | SyntaxKind.UniqueKeyword | SyntaxKind.ReadonlyKeyword
  Object? get operator_;
  /// type: TypeNode
  TypeNode get type;
}

/// interface IndexedAccessTypeNode extends TypeNode
abstract class IndexedAccessTypeNode {
  /// kind: SyntaxKind.IndexedAccessType
  SyntaxKind get kind;
  /// objectType: TypeNode
  TypeNode get objectType;
  /// indexType: TypeNode
  TypeNode get indexType;
}

/// interface MappedTypeNode extends TypeNode, Declaration, LocalsContainer
abstract class MappedTypeNode {
  /// kind: SyntaxKind.MappedType
  SyntaxKind get kind;
  /// optional readonlyToken: ReadonlyKeyword | PlusToken | MinusToken
  Object? get readonlyToken;
  /// typeParameter: TypeParameterDeclaration
  TypeParameterDeclaration get typeParameter;
  /// optional nameType: TypeNode
  TypeNode? get nameType;
  /// optional questionToken: QuestionToken | PlusToken | MinusToken
  Object? get questionToken;
  /// optional type: TypeNode
  TypeNode? get type;
  /// optional members: NodeArray<TypeElement>
  NodeArray<TypeElement>? get members;
}

/// interface LiteralTypeNode extends TypeNode
abstract class LiteralTypeNode {
  /// kind: SyntaxKind.LiteralType
  SyntaxKind get kind;
  /// literal: NullLiteral | BooleanLiteral | LiteralExpression | PrefixUnaryExpression
  Object? get literal;
}

/// interface StringLiteral extends LiteralExpression, Declaration
abstract class StringLiteral {
  /// kind: SyntaxKind.StringLiteral
  SyntaxKind get kind;
}

/// interface TemplateLiteralTypeNode extends TypeNode
abstract class TemplateLiteralTypeNode {
  /// kind: SyntaxKind.TemplateLiteralType
  SyntaxKind get kind;
  /// head: TemplateHead
  TemplateHead get head;
  /// templateSpans: NodeArray<TemplateLiteralTypeSpan>
  NodeArray<TemplateLiteralTypeSpan> get templateSpans;
}

/// interface TemplateLiteralTypeSpan extends TypeNode
abstract class TemplateLiteralTypeSpan {
  /// kind: SyntaxKind.TemplateLiteralTypeSpan
  SyntaxKind get kind;
  /// parent: TemplateLiteralTypeNode
  TemplateLiteralTypeNode get parent;
  /// type: TypeNode
  TypeNode get type;
  /// literal: TemplateMiddle | TemplateTail
  Object? get literal;
}

/// interface Expression extends Node
abstract class Expression {
  /// _expressionBrand: any
  Object? get expressionBrand;
}

/// interface OmittedExpression extends Expression
abstract class OmittedExpression {
  /// kind: SyntaxKind.OmittedExpression
  SyntaxKind get kind;
}

/// interface PartiallyEmittedExpression extends LeftHandSideExpression
abstract class PartiallyEmittedExpression {
  /// kind: SyntaxKind.PartiallyEmittedExpression
  SyntaxKind get kind;
  /// expression: Expression
  Expression get expression;
}

/// interface UnaryExpression extends Expression
abstract class UnaryExpression {
  /// _unaryExpressionBrand: any
  Object? get unaryExpressionBrand;
}

/// interface UpdateExpression extends UnaryExpression
abstract class UpdateExpression {
  /// _updateExpressionBrand: any
  Object? get updateExpressionBrand;
}

/// interface PrefixUnaryExpression extends UpdateExpression
abstract class PrefixUnaryExpression {
  /// kind: SyntaxKind.PrefixUnaryExpression
  SyntaxKind get kind;
  /// operator: PrefixUnaryOperator
  PrefixUnaryOperator get operator_;
  /// operand: UnaryExpression
  UnaryExpression get operand;
}

/// interface PostfixUnaryExpression extends UpdateExpression
abstract class PostfixUnaryExpression {
  /// kind: SyntaxKind.PostfixUnaryExpression
  SyntaxKind get kind;
  /// operand: LeftHandSideExpression
  LeftHandSideExpression get operand;
  /// operator: PostfixUnaryOperator
  PostfixUnaryOperator get operator_;
}

/// interface LeftHandSideExpression extends UpdateExpression
abstract class LeftHandSideExpression {
  /// _leftHandSideExpressionBrand: any
  Object? get leftHandSideExpressionBrand;
}

/// interface MemberExpression extends LeftHandSideExpression
abstract class MemberExpression {
  /// _memberExpressionBrand: any
  Object? get memberExpressionBrand;
}

/// interface PrimaryExpression extends MemberExpression
abstract class PrimaryExpression {
  /// _primaryExpressionBrand: any
  Object? get primaryExpressionBrand;
}

/// interface NullLiteral extends PrimaryExpression
abstract class NullLiteral {
  /// kind: SyntaxKind.NullKeyword
  SyntaxKind get kind;
}

/// interface TrueLiteral extends PrimaryExpression
abstract class TrueLiteral {
  /// kind: SyntaxKind.TrueKeyword
  SyntaxKind get kind;
}

/// interface FalseLiteral extends PrimaryExpression
abstract class FalseLiteral {
  /// kind: SyntaxKind.FalseKeyword
  SyntaxKind get kind;
}

/// interface ThisExpression extends PrimaryExpression, FlowContainer
abstract class ThisExpression {
  /// kind: SyntaxKind.ThisKeyword
  SyntaxKind get kind;
}

/// interface SuperExpression extends PrimaryExpression, FlowContainer
abstract class SuperExpression {
  /// kind: SyntaxKind.SuperKeyword
  SyntaxKind get kind;
}

/// interface ImportExpression extends PrimaryExpression
abstract class ImportExpression {
  /// kind: SyntaxKind.ImportKeyword
  SyntaxKind get kind;
}

/// interface DeleteExpression extends UnaryExpression
abstract class DeleteExpression {
  /// kind: SyntaxKind.DeleteExpression
  SyntaxKind get kind;
  /// expression: UnaryExpression
  UnaryExpression get expression;
}

/// interface TypeOfExpression extends UnaryExpression
abstract class TypeOfExpression {
  /// kind: SyntaxKind.TypeOfExpression
  SyntaxKind get kind;
  /// expression: UnaryExpression
  UnaryExpression get expression;
}

/// interface VoidExpression extends UnaryExpression
abstract class VoidExpression {
  /// kind: SyntaxKind.VoidExpression
  SyntaxKind get kind;
  /// expression: UnaryExpression
  UnaryExpression get expression;
}

/// interface AwaitExpression extends UnaryExpression
abstract class AwaitExpression {
  /// kind: SyntaxKind.AwaitExpression
  SyntaxKind get kind;
  /// expression: UnaryExpression
  UnaryExpression get expression;
}

/// interface YieldExpression extends Expression
abstract class YieldExpression {
  /// kind: SyntaxKind.YieldExpression
  SyntaxKind get kind;
  /// optional asteriskToken: AsteriskToken
  AsteriskToken? get asteriskToken;
  /// optional expression: Expression
  Expression? get expression;
}

/// interface SyntheticExpression extends Expression
abstract class SyntheticExpression {
  /// kind: SyntaxKind.SyntheticExpression
  SyntaxKind get kind;
  /// isSpread: boolean
  bool get isSpread;
  /// type: Type
  Type get type;
  /// optional tupleNameSource: ParameterDeclaration | NamedTupleMember
  Object? get tupleNameSource;
}

/// interface BinaryExpression extends Expression, Declaration, JSDocContainer
abstract class BinaryExpression {
  /// kind: SyntaxKind.BinaryExpression
  SyntaxKind get kind;
  /// left: Expression
  Expression get left;
  /// operatorToken: BinaryOperatorToken
  BinaryOperatorToken get operatorToken;
  /// right: Expression
  Expression get right;
}

/// interface AssignmentExpression extends BinaryExpression
abstract class AssignmentExpression<TOperator> {
  /// left: LeftHandSideExpression
  LeftHandSideExpression get left;
  /// operatorToken: TOperator
  TOperator get operatorToken;
}

/// interface ObjectDestructuringAssignment extends AssignmentExpression<EqualsToken>
abstract class ObjectDestructuringAssignment {
  /// left: ObjectLiteralExpression
  ObjectLiteralExpression get left;
}

/// interface ArrayDestructuringAssignment extends AssignmentExpression<EqualsToken>
abstract class ArrayDestructuringAssignment {
  /// left: ArrayLiteralExpression
  ArrayLiteralExpression get left;
}

/// interface ConditionalExpression extends Expression
abstract class ConditionalExpression {
  /// kind: SyntaxKind.ConditionalExpression
  SyntaxKind get kind;
  /// condition: Expression
  Expression get condition;
  /// questionToken: QuestionToken
  QuestionToken get questionToken;
  /// whenTrue: Expression
  Expression get whenTrue;
  /// colonToken: ColonToken
  ColonToken get colonToken;
  /// whenFalse: Expression
  Expression get whenFalse;
}

/// interface FunctionExpression extends PrimaryExpression, FunctionLikeDeclarationBase, JSDocContainer, LocalsContainer, FlowContainer
abstract class FunctionExpression {
  /// kind: SyntaxKind.FunctionExpression
  SyntaxKind get kind;
  /// optional modifiers: NodeArray<Modifier>
  NodeArray<Modifier>? get modifiers;
  /// optional name: Identifier
  Identifier? get name;
  /// body: FunctionBody
  FunctionBody get body;
}

/// interface ArrowFunction extends Expression, FunctionLikeDeclarationBase, JSDocContainer, LocalsContainer, FlowContainer
abstract class ArrowFunction {
  /// kind: SyntaxKind.ArrowFunction
  SyntaxKind get kind;
  /// optional modifiers: NodeArray<Modifier>
  NodeArray<Modifier>? get modifiers;
  /// equalsGreaterThanToken: EqualsGreaterThanToken
  EqualsGreaterThanToken get equalsGreaterThanToken;
  /// body: ConciseBody
  ConciseBody get body;
  /// name: never
  Null get name;
}

/// interface LiteralLikeNode extends Node
abstract class LiteralLikeNode {
  /// text: string
  String get text;
  /// optional isUnterminated: boolean
  bool? get isUnterminated;
  /// optional hasExtendedUnicodeEscape: boolean
  bool? get hasExtendedUnicodeEscape;
}

/// interface TemplateLiteralLikeNode extends LiteralLikeNode
abstract class TemplateLiteralLikeNode {
  /// optional rawText: string
  String? get rawText;
}

/// interface LiteralExpression extends LiteralLikeNode, PrimaryExpression
abstract class LiteralExpression {
  /// _literalExpressionBrand: any
  Object? get literalExpressionBrand;
}

/// interface RegularExpressionLiteral extends LiteralExpression
abstract class RegularExpressionLiteral {
  /// kind: SyntaxKind.RegularExpressionLiteral
  SyntaxKind get kind;
}

/// interface NoSubstitutionTemplateLiteral extends LiteralExpression, TemplateLiteralLikeNode, Declaration
abstract class NoSubstitutionTemplateLiteral {
  /// kind: SyntaxKind.NoSubstitutionTemplateLiteral
  SyntaxKind get kind;
}

/// interface NumericLiteral extends LiteralExpression, Declaration
abstract class NumericLiteral {
  /// kind: SyntaxKind.NumericLiteral
  SyntaxKind get kind;
}

/// interface BigIntLiteral extends LiteralExpression
abstract class BigIntLiteral {
  /// kind: SyntaxKind.BigIntLiteral
  SyntaxKind get kind;
}

/// interface TemplateHead extends TemplateLiteralLikeNode
abstract class TemplateHead {
  /// kind: SyntaxKind.TemplateHead
  SyntaxKind get kind;
  /// parent: TemplateExpression | TemplateLiteralTypeNode
  Object? get parent;
}

/// interface TemplateMiddle extends TemplateLiteralLikeNode
abstract class TemplateMiddle {
  /// kind: SyntaxKind.TemplateMiddle
  SyntaxKind get kind;
  /// parent: TemplateSpan | TemplateLiteralTypeSpan
  Object? get parent;
}

/// interface TemplateTail extends TemplateLiteralLikeNode
abstract class TemplateTail {
  /// kind: SyntaxKind.TemplateTail
  SyntaxKind get kind;
  /// parent: TemplateSpan | TemplateLiteralTypeSpan
  Object? get parent;
}

/// interface TemplateExpression extends PrimaryExpression
abstract class TemplateExpression {
  /// kind: SyntaxKind.TemplateExpression
  SyntaxKind get kind;
  /// head: TemplateHead
  TemplateHead get head;
  /// templateSpans: NodeArray<TemplateSpan>
  NodeArray<TemplateSpan> get templateSpans;
}

/// interface TemplateSpan extends Node
abstract class TemplateSpan {
  /// kind: SyntaxKind.TemplateSpan
  SyntaxKind get kind;
  /// parent: TemplateExpression
  TemplateExpression get parent;
  /// expression: Expression
  Expression get expression;
  /// literal: TemplateMiddle | TemplateTail
  Object? get literal;
}

/// interface ParenthesizedExpression extends PrimaryExpression, JSDocContainer
abstract class ParenthesizedExpression {
  /// kind: SyntaxKind.ParenthesizedExpression
  SyntaxKind get kind;
  /// expression: Expression
  Expression get expression;
}

/// interface ArrayLiteralExpression extends PrimaryExpression
abstract class ArrayLiteralExpression {
  /// kind: SyntaxKind.ArrayLiteralExpression
  SyntaxKind get kind;
  /// elements: NodeArray<Expression>
  NodeArray<Expression> get elements;
}

/// interface SpreadElement extends Expression
abstract class SpreadElement {
  /// kind: SyntaxKind.SpreadElement
  SyntaxKind get kind;
  /// parent: ArrayLiteralExpression | CallExpression | NewExpression
  Object? get parent;
  /// expression: Expression
  Expression get expression;
}

/// interface ObjectLiteralExpressionBase extends PrimaryExpression, Declaration
abstract class ObjectLiteralExpressionBase<T> {
  /// properties: NodeArray<T>
  NodeArray<T> get properties;
}

/// interface ObjectLiteralExpression extends ObjectLiteralExpressionBase<ObjectLiteralElementLike>, JSDocContainer
abstract class ObjectLiteralExpression {
  /// kind: SyntaxKind.ObjectLiteralExpression
  SyntaxKind get kind;
}

/// interface PropertyAccessExpression extends MemberExpression, NamedDeclaration, JSDocContainer, FlowContainer
abstract class PropertyAccessExpression {
  /// kind: SyntaxKind.PropertyAccessExpression
  SyntaxKind get kind;
  /// expression: LeftHandSideExpression
  LeftHandSideExpression get expression;
  /// optional questionDotToken: QuestionDotToken
  QuestionDotToken? get questionDotToken;
  /// name: MemberName
  MemberName get name;
}

/// interface PropertyAccessChain extends PropertyAccessExpression
abstract class PropertyAccessChain {
  /// _optionalChainBrand: any
  Object? get optionalChainBrand;
  /// name: MemberName
  MemberName get name;
}

/// interface SuperPropertyAccessExpression extends PropertyAccessExpression
abstract class SuperPropertyAccessExpression {
  /// expression: SuperExpression
  SuperExpression get expression;
}

/// interface PropertyAccessEntityNameExpression extends PropertyAccessExpression
abstract class PropertyAccessEntityNameExpression {
  /// optional _propertyAccessExpressionLikeQualifiedNameBrand: any
  Object? get propertyAccessExpressionLikeQualifiedNameBrand;
  /// expression: EntityNameExpression
  EntityNameExpression get expression;
  /// name: Identifier
  Identifier get name;
}

/// interface ElementAccessExpression extends MemberExpression, Declaration, JSDocContainer, FlowContainer
abstract class ElementAccessExpression {
  /// kind: SyntaxKind.ElementAccessExpression
  SyntaxKind get kind;
  /// expression: LeftHandSideExpression
  LeftHandSideExpression get expression;
  /// optional questionDotToken: QuestionDotToken
  QuestionDotToken? get questionDotToken;
  /// argumentExpression: Expression
  Expression get argumentExpression;
}

/// interface ElementAccessChain extends ElementAccessExpression
abstract class ElementAccessChain {
  /// _optionalChainBrand: any
  Object? get optionalChainBrand;
}

/// interface SuperElementAccessExpression extends ElementAccessExpression
abstract class SuperElementAccessExpression {
  /// expression: SuperExpression
  SuperExpression get expression;
}

/// interface CallExpression extends LeftHandSideExpression, Declaration
abstract class CallExpression {
  /// kind: SyntaxKind.CallExpression
  SyntaxKind get kind;
  /// expression: LeftHandSideExpression
  LeftHandSideExpression get expression;
  /// optional questionDotToken: QuestionDotToken
  QuestionDotToken? get questionDotToken;
  /// optional typeArguments: NodeArray<TypeNode>
  NodeArray<TypeNode>? get typeArguments;
  /// arguments: NodeArray<Expression>
  NodeArray<Expression> get arguments;
}

/// interface CallChain extends CallExpression
abstract class CallChain {
  /// _optionalChainBrand: any
  Object? get optionalChainBrand;
}

/// interface SuperCall extends CallExpression
abstract class SuperCall {
  /// expression: SuperExpression
  SuperExpression get expression;
}

/// interface ImportCall extends CallExpression
abstract class ImportCall {
  /// expression: ImportExpression | ImportDeferProperty
  Object? get expression;
}

/// interface ExpressionWithTypeArguments extends MemberExpression, NodeWithTypeArguments
abstract class ExpressionWithTypeArguments {
  /// kind: SyntaxKind.ExpressionWithTypeArguments
  SyntaxKind get kind;
  /// expression: LeftHandSideExpression
  LeftHandSideExpression get expression;
}

/// interface NewExpression extends PrimaryExpression, Declaration
abstract class NewExpression {
  /// kind: SyntaxKind.NewExpression
  SyntaxKind get kind;
  /// expression: LeftHandSideExpression
  LeftHandSideExpression get expression;
  /// optional typeArguments: NodeArray<TypeNode>
  NodeArray<TypeNode>? get typeArguments;
  /// optional arguments: NodeArray<Expression>
  NodeArray<Expression>? get arguments;
}

/// interface TaggedTemplateExpression extends MemberExpression
abstract class TaggedTemplateExpression {
  /// kind: SyntaxKind.TaggedTemplateExpression
  SyntaxKind get kind;
  /// tag: LeftHandSideExpression
  LeftHandSideExpression get tag;
  /// optional typeArguments: NodeArray<TypeNode>
  NodeArray<TypeNode>? get typeArguments;
  /// template: TemplateLiteral
  TemplateLiteral get template;
}

/// interface InstanceofExpression extends BinaryExpression
abstract class InstanceofExpression {
  /// operatorToken: Token<SyntaxKind.InstanceOfKeyword>
  Token<SyntaxKind> get operatorToken;
}

/// interface AsExpression extends Expression
abstract class AsExpression {
  /// kind: SyntaxKind.AsExpression
  SyntaxKind get kind;
  /// expression: Expression
  Expression get expression;
  /// type: TypeNode
  TypeNode get type;
}

/// interface TypeAssertion extends UnaryExpression
abstract class TypeAssertion {
  /// kind: SyntaxKind.TypeAssertionExpression
  SyntaxKind get kind;
  /// type: TypeNode
  TypeNode get type;
  /// expression: UnaryExpression
  UnaryExpression get expression;
}

/// interface SatisfiesExpression extends Expression
abstract class SatisfiesExpression {
  /// kind: SyntaxKind.SatisfiesExpression
  SyntaxKind get kind;
  /// expression: Expression
  Expression get expression;
  /// type: TypeNode
  TypeNode get type;
}

/// interface NonNullExpression extends LeftHandSideExpression
abstract class NonNullExpression {
  /// kind: SyntaxKind.NonNullExpression
  SyntaxKind get kind;
  /// expression: Expression
  Expression get expression;
}

/// interface NonNullChain extends NonNullExpression
abstract class NonNullChain {
  /// _optionalChainBrand: any
  Object? get optionalChainBrand;
}

/// interface MetaProperty extends PrimaryExpression, FlowContainer
abstract class MetaProperty {
  /// kind: SyntaxKind.MetaProperty
  SyntaxKind get kind;
  /// keywordToken: SyntaxKind.NewKeyword | SyntaxKind.ImportKeyword
  Object? get keywordToken;
  /// name: Identifier
  Identifier get name;
}

/// interface ImportDeferProperty extends MetaProperty
abstract class ImportDeferProperty {
  /// keywordToken: SyntaxKind.ImportKeyword
  SyntaxKind get keywordToken;
  /// name: Identifier & { readonly escapedText: __String & "defer"; }
  Object? get name;
}

/// interface JsxElement extends PrimaryExpression
abstract class JsxElement {
  /// kind: SyntaxKind.JsxElement
  SyntaxKind get kind;
  /// openingElement: JsxOpeningElement
  JsxOpeningElement get openingElement;
  /// children: NodeArray<JsxChild>
  NodeArray<JsxChild> get children;
  /// closingElement: JsxClosingElement
  JsxClosingElement get closingElement;
}

/// interface JsxTagNamePropertyAccess extends PropertyAccessExpression
abstract class JsxTagNamePropertyAccess {
  /// expression: Identifier | ThisExpression | JsxTagNamePropertyAccess
  Object? get expression;
}

/// interface JsxAttributes extends PrimaryExpression, Declaration
abstract class JsxAttributes {
  /// properties: NodeArray<JsxAttributeLike>
  NodeArray<JsxAttributeLike> get properties;
  /// kind: SyntaxKind.JsxAttributes
  SyntaxKind get kind;
  /// parent: JsxOpeningLikeElement
  JsxOpeningLikeElement get parent;
}

/// interface JsxNamespacedName extends Node
abstract class JsxNamespacedName {
  /// kind: SyntaxKind.JsxNamespacedName
  SyntaxKind get kind;
  /// name: Identifier
  Identifier get name;
  /// namespace: Identifier
  Identifier get namespace;
}

/// interface JsxOpeningElement extends Expression
abstract class JsxOpeningElement {
  /// kind: SyntaxKind.JsxOpeningElement
  SyntaxKind get kind;
  /// parent: JsxElement
  JsxElement get parent;
  /// tagName: JsxTagNameExpression
  JsxTagNameExpression get tagName;
  /// optional typeArguments: NodeArray<TypeNode>
  NodeArray<TypeNode>? get typeArguments;
  /// attributes: JsxAttributes
  JsxAttributes get attributes;
}

/// interface JsxSelfClosingElement extends PrimaryExpression
abstract class JsxSelfClosingElement {
  /// kind: SyntaxKind.JsxSelfClosingElement
  SyntaxKind get kind;
  /// tagName: JsxTagNameExpression
  JsxTagNameExpression get tagName;
  /// optional typeArguments: NodeArray<TypeNode>
  NodeArray<TypeNode>? get typeArguments;
  /// attributes: JsxAttributes
  JsxAttributes get attributes;
}

/// interface JsxFragment extends PrimaryExpression
abstract class JsxFragment {
  /// kind: SyntaxKind.JsxFragment
  SyntaxKind get kind;
  /// openingFragment: JsxOpeningFragment
  JsxOpeningFragment get openingFragment;
  /// children: NodeArray<JsxChild>
  NodeArray<JsxChild> get children;
  /// closingFragment: JsxClosingFragment
  JsxClosingFragment get closingFragment;
}

/// interface JsxOpeningFragment extends Expression
abstract class JsxOpeningFragment {
  /// kind: SyntaxKind.JsxOpeningFragment
  SyntaxKind get kind;
  /// parent: JsxFragment
  JsxFragment get parent;
}

/// interface JsxClosingFragment extends Expression
abstract class JsxClosingFragment {
  /// kind: SyntaxKind.JsxClosingFragment
  SyntaxKind get kind;
  /// parent: JsxFragment
  JsxFragment get parent;
}

/// interface JsxAttribute extends Declaration
abstract class JsxAttribute {
  /// kind: SyntaxKind.JsxAttribute
  SyntaxKind get kind;
  /// parent: JsxAttributes
  JsxAttributes get parent;
  /// name: JsxAttributeName
  JsxAttributeName get name;
  /// optional initializer: JsxAttributeValue
  JsxAttributeValue? get initializer;
}

/// interface JsxSpreadAttribute extends ObjectLiteralElement
abstract class JsxSpreadAttribute {
  /// kind: SyntaxKind.JsxSpreadAttribute
  SyntaxKind get kind;
  /// parent: JsxAttributes
  JsxAttributes get parent;
  /// expression: Expression
  Expression get expression;
}

/// interface JsxClosingElement extends Node
abstract class JsxClosingElement {
  /// kind: SyntaxKind.JsxClosingElement
  SyntaxKind get kind;
  /// parent: JsxElement
  JsxElement get parent;
  /// tagName: JsxTagNameExpression
  JsxTagNameExpression get tagName;
}

/// interface JsxExpression extends Expression
abstract class JsxExpression {
  /// kind: SyntaxKind.JsxExpression
  SyntaxKind get kind;
  /// parent: JsxElement | JsxFragment | JsxAttributeLike
  Object? get parent;
  /// optional dotDotDotToken: Token<SyntaxKind.DotDotDotToken>
  Token<SyntaxKind>? get dotDotDotToken;
  /// optional expression: Expression
  Expression? get expression;
}

/// interface JsxText extends LiteralLikeNode
abstract class JsxText {
  /// kind: SyntaxKind.JsxText
  SyntaxKind get kind;
  /// parent: JsxElement | JsxFragment
  Object? get parent;
  /// containsOnlyTriviaWhiteSpaces: boolean
  bool get containsOnlyTriviaWhiteSpaces;
}

/// interface Statement extends Node, JSDocContainer
abstract class Statement {
  /// _statementBrand: any
  Object? get statementBrand;
}

/// interface NotEmittedStatement extends Statement
abstract class NotEmittedStatement {
  /// kind: SyntaxKind.NotEmittedStatement
  SyntaxKind get kind;
}

/// interface NotEmittedTypeElement extends TypeElement
abstract class NotEmittedTypeElement {
  /// kind: SyntaxKind.NotEmittedTypeElement
  SyntaxKind get kind;
}

/// interface CommaListExpression extends Expression
abstract class CommaListExpression {
  /// kind: SyntaxKind.CommaListExpression
  SyntaxKind get kind;
  /// elements: NodeArray<Expression>
  NodeArray<Expression> get elements;
}

/// interface EmptyStatement extends Statement
abstract class EmptyStatement {
  /// kind: SyntaxKind.EmptyStatement
  SyntaxKind get kind;
}

/// interface DebuggerStatement extends Statement, FlowContainer
abstract class DebuggerStatement {
  /// kind: SyntaxKind.DebuggerStatement
  SyntaxKind get kind;
}

/// interface MissingDeclaration extends DeclarationStatement, PrimaryExpression
abstract class MissingDeclaration {
  /// kind: SyntaxKind.MissingDeclaration
  SyntaxKind get kind;
  /// optional name: Identifier
  Identifier? get name;
}

/// interface Block extends Statement, LocalsContainer
abstract class Block {
  /// kind: SyntaxKind.Block
  SyntaxKind get kind;
  /// statements: NodeArray<Statement>
  NodeArray<Statement> get statements;
}

/// interface VariableStatement extends Statement, FlowContainer
abstract class VariableStatement {
  /// kind: SyntaxKind.VariableStatement
  SyntaxKind get kind;
  /// optional modifiers: NodeArray<ModifierLike>
  NodeArray<ModifierLike>? get modifiers;
  /// declarationList: VariableDeclarationList
  VariableDeclarationList get declarationList;
}

/// interface ExpressionStatement extends Statement, FlowContainer
abstract class ExpressionStatement {
  /// kind: SyntaxKind.ExpressionStatement
  SyntaxKind get kind;
  /// expression: Expression
  Expression get expression;
}

/// interface IfStatement extends Statement, FlowContainer
abstract class IfStatement {
  /// kind: SyntaxKind.IfStatement
  SyntaxKind get kind;
  /// expression: Expression
  Expression get expression;
  /// thenStatement: Statement
  Statement get thenStatement;
  /// optional elseStatement: Statement
  Statement? get elseStatement;
}

/// interface IterationStatement extends Statement
abstract class IterationStatement {
  /// statement: Statement
  Statement get statement;
}

/// interface DoStatement extends IterationStatement, FlowContainer
abstract class DoStatement {
  /// kind: SyntaxKind.DoStatement
  SyntaxKind get kind;
  /// expression: Expression
  Expression get expression;
}

/// interface WhileStatement extends IterationStatement, FlowContainer
abstract class WhileStatement {
  /// kind: SyntaxKind.WhileStatement
  SyntaxKind get kind;
  /// expression: Expression
  Expression get expression;
}

/// interface ForStatement extends IterationStatement, LocalsContainer, FlowContainer
abstract class ForStatement {
  /// kind: SyntaxKind.ForStatement
  SyntaxKind get kind;
  /// optional initializer: ForInitializer
  ForInitializer? get initializer;
  /// optional condition: Expression
  Expression? get condition;
  /// optional incrementor: Expression
  Expression? get incrementor;
}

/// interface ForInStatement extends IterationStatement, LocalsContainer, FlowContainer
abstract class ForInStatement {
  /// kind: SyntaxKind.ForInStatement
  SyntaxKind get kind;
  /// initializer: ForInitializer
  ForInitializer get initializer;
  /// expression: Expression
  Expression get expression;
}

/// interface ForOfStatement extends IterationStatement, LocalsContainer, FlowContainer
abstract class ForOfStatement {
  /// kind: SyntaxKind.ForOfStatement
  SyntaxKind get kind;
  /// optional awaitModifier: AwaitKeyword
  AwaitKeyword? get awaitModifier;
  /// initializer: ForInitializer
  ForInitializer get initializer;
  /// expression: Expression
  Expression get expression;
}

/// interface BreakStatement extends Statement, FlowContainer
abstract class BreakStatement {
  /// kind: SyntaxKind.BreakStatement
  SyntaxKind get kind;
  /// optional label: Identifier
  Identifier? get label;
}

/// interface ContinueStatement extends Statement, FlowContainer
abstract class ContinueStatement {
  /// kind: SyntaxKind.ContinueStatement
  SyntaxKind get kind;
  /// optional label: Identifier
  Identifier? get label;
}

/// interface ReturnStatement extends Statement, FlowContainer
abstract class ReturnStatement {
  /// kind: SyntaxKind.ReturnStatement
  SyntaxKind get kind;
  /// optional expression: Expression
  Expression? get expression;
}

/// interface WithStatement extends Statement, FlowContainer
abstract class WithStatement {
  /// kind: SyntaxKind.WithStatement
  SyntaxKind get kind;
  /// expression: Expression
  Expression get expression;
  /// statement: Statement
  Statement get statement;
}

/// interface SwitchStatement extends Statement, FlowContainer
abstract class SwitchStatement {
  /// kind: SyntaxKind.SwitchStatement
  SyntaxKind get kind;
  /// expression: Expression
  Expression get expression;
  /// caseBlock: CaseBlock
  CaseBlock get caseBlock;
  /// optional possiblyExhaustive: boolean
  bool? get possiblyExhaustive;
}

/// interface CaseBlock extends Node, LocalsContainer
abstract class CaseBlock {
  /// kind: SyntaxKind.CaseBlock
  SyntaxKind get kind;
  /// parent: SwitchStatement
  SwitchStatement get parent;
  /// clauses: NodeArray<CaseOrDefaultClause>
  NodeArray<CaseOrDefaultClause> get clauses;
}

/// interface CaseClause extends Node, JSDocContainer
abstract class CaseClause {
  /// kind: SyntaxKind.CaseClause
  SyntaxKind get kind;
  /// parent: CaseBlock
  CaseBlock get parent;
  /// expression: Expression
  Expression get expression;
  /// statements: NodeArray<Statement>
  NodeArray<Statement> get statements;
}

/// interface DefaultClause extends Node
abstract class DefaultClause {
  /// kind: SyntaxKind.DefaultClause
  SyntaxKind get kind;
  /// parent: CaseBlock
  CaseBlock get parent;
  /// statements: NodeArray<Statement>
  NodeArray<Statement> get statements;
}

/// interface LabeledStatement extends Statement, FlowContainer
abstract class LabeledStatement {
  /// kind: SyntaxKind.LabeledStatement
  SyntaxKind get kind;
  /// label: Identifier
  Identifier get label;
  /// statement: Statement
  Statement get statement;
}

/// interface ThrowStatement extends Statement, FlowContainer
abstract class ThrowStatement {
  /// kind: SyntaxKind.ThrowStatement
  SyntaxKind get kind;
  /// expression: Expression
  Expression get expression;
}

/// interface TryStatement extends Statement, FlowContainer
abstract class TryStatement {
  /// kind: SyntaxKind.TryStatement
  SyntaxKind get kind;
  /// tryBlock: Block
  Block get tryBlock;
  /// optional catchClause: CatchClause
  CatchClause? get catchClause;
  /// optional finallyBlock: Block
  Block? get finallyBlock;
}

/// interface CatchClause extends Node, LocalsContainer
abstract class CatchClause {
  /// kind: SyntaxKind.CatchClause
  SyntaxKind get kind;
  /// parent: TryStatement
  TryStatement get parent;
  /// optional variableDeclaration: VariableDeclaration
  VariableDeclaration? get variableDeclaration;
  /// block: Block
  Block get block;
}

/// interface ClassLikeDeclarationBase extends NamedDeclaration, JSDocContainer
abstract class ClassLikeDeclarationBase {
  /// kind: SyntaxKind.ClassDeclaration | SyntaxKind.ClassExpression
  Object? get kind;
  /// optional name: Identifier
  Identifier? get name;
  /// optional typeParameters: NodeArray<TypeParameterDeclaration>
  NodeArray<TypeParameterDeclaration>? get typeParameters;
  /// optional heritageClauses: NodeArray<HeritageClause>
  NodeArray<HeritageClause>? get heritageClauses;
  /// members: NodeArray<ClassElement>
  NodeArray<ClassElement> get members;
}

/// interface ClassDeclaration extends ClassLikeDeclarationBase, DeclarationStatement
abstract class ClassDeclaration {
  /// kind: SyntaxKind.ClassDeclaration
  SyntaxKind get kind;
  /// optional modifiers: NodeArray<ModifierLike>
  NodeArray<ModifierLike>? get modifiers;
  /// optional name: Identifier
  Identifier? get name;
}

/// interface ClassExpression extends ClassLikeDeclarationBase, PrimaryExpression
abstract class ClassExpression {
  /// kind: SyntaxKind.ClassExpression
  SyntaxKind get kind;
  /// optional modifiers: NodeArray<ModifierLike>
  NodeArray<ModifierLike>? get modifiers;
}

/// interface ClassElement extends NamedDeclaration
abstract class ClassElement {
  /// _classElementBrand: any
  Object? get classElementBrand;
  /// optional name: PropertyName
  PropertyName? get name;
}

/// interface TypeElement extends NamedDeclaration
abstract class TypeElement {
  /// _typeElementBrand: any
  Object? get typeElementBrand;
  /// optional name: PropertyName
  PropertyName? get name;
  /// optional questionToken: QuestionToken | undefined
  QuestionToken? get questionToken;
}

/// interface InterfaceDeclaration extends DeclarationStatement, JSDocContainer
abstract class InterfaceDeclaration {
  /// kind: SyntaxKind.InterfaceDeclaration
  SyntaxKind get kind;
  /// optional modifiers: NodeArray<ModifierLike>
  NodeArray<ModifierLike>? get modifiers;
  /// name: Identifier
  Identifier get name;
  /// optional typeParameters: NodeArray<TypeParameterDeclaration>
  NodeArray<TypeParameterDeclaration>? get typeParameters;
  /// optional heritageClauses: NodeArray<HeritageClause>
  NodeArray<HeritageClause>? get heritageClauses;
  /// members: NodeArray<TypeElement>
  NodeArray<TypeElement> get members;
}

/// interface HeritageClause extends Node
abstract class HeritageClause {
  /// kind: SyntaxKind.HeritageClause
  SyntaxKind get kind;
  /// parent: InterfaceDeclaration | ClassLikeDeclaration
  Object? get parent;
  /// token: SyntaxKind.ExtendsKeyword | SyntaxKind.ImplementsKeyword
  Object? get token;
  /// types: NodeArray<ExpressionWithTypeArguments>
  NodeArray<ExpressionWithTypeArguments> get types;
}

/// interface TypeAliasDeclaration extends DeclarationStatement, JSDocContainer, LocalsContainer
abstract class TypeAliasDeclaration {
  /// kind: SyntaxKind.TypeAliasDeclaration
  SyntaxKind get kind;
  /// optional modifiers: NodeArray<ModifierLike>
  NodeArray<ModifierLike>? get modifiers;
  /// name: Identifier
  Identifier get name;
  /// optional typeParameters: NodeArray<TypeParameterDeclaration>
  NodeArray<TypeParameterDeclaration>? get typeParameters;
  /// type: TypeNode
  TypeNode get type;
}

/// interface EnumMember extends NamedDeclaration, JSDocContainer
abstract class EnumMember {
  /// kind: SyntaxKind.EnumMember
  SyntaxKind get kind;
  /// parent: EnumDeclaration
  EnumDeclaration get parent;
  /// name: PropertyName
  PropertyName get name;
  /// optional initializer: Expression
  Expression? get initializer;
}

/// interface EnumDeclaration extends DeclarationStatement, JSDocContainer
abstract class EnumDeclaration {
  /// kind: SyntaxKind.EnumDeclaration
  SyntaxKind get kind;
  /// optional modifiers: NodeArray<ModifierLike>
  NodeArray<ModifierLike>? get modifiers;
  /// name: Identifier
  Identifier get name;
  /// members: NodeArray<EnumMember>
  NodeArray<EnumMember> get members;
}

/// interface ModuleDeclaration extends DeclarationStatement, JSDocContainer, LocalsContainer
abstract class ModuleDeclaration {
  /// kind: SyntaxKind.ModuleDeclaration
  SyntaxKind get kind;
  /// parent: ModuleBody | SourceFile
  Object? get parent;
  /// optional modifiers: NodeArray<ModifierLike>
  NodeArray<ModifierLike>? get modifiers;
  /// name: ModuleName
  ModuleName get name;
  /// optional body: ModuleBody | JSDocNamespaceDeclaration
  Object? get body;
}

/// interface NamespaceDeclaration extends ModuleDeclaration
abstract class NamespaceDeclaration {
  /// name: Identifier
  Identifier get name;
  /// body: NamespaceBody
  NamespaceBody get body;
}

/// interface JSDocNamespaceDeclaration extends ModuleDeclaration
abstract class JSDocNamespaceDeclaration {
  /// name: Identifier
  Identifier get name;
  /// optional body: JSDocNamespaceBody
  JSDocNamespaceBody? get body;
}

/// interface ModuleBlock extends Node, Statement
abstract class ModuleBlock {
  /// kind: SyntaxKind.ModuleBlock
  SyntaxKind get kind;
  /// parent: ModuleDeclaration
  ModuleDeclaration get parent;
  /// statements: NodeArray<Statement>
  NodeArray<Statement> get statements;
}

/// interface ImportEqualsDeclaration extends DeclarationStatement, JSDocContainer
abstract class ImportEqualsDeclaration {
  /// kind: SyntaxKind.ImportEqualsDeclaration
  SyntaxKind get kind;
  /// parent: SourceFile | ModuleBlock
  Object? get parent;
  /// optional modifiers: NodeArray<ModifierLike>
  NodeArray<ModifierLike>? get modifiers;
  /// name: Identifier
  Identifier get name;
  /// isTypeOnly: boolean
  bool get isTypeOnly;
  /// moduleReference: ModuleReference
  ModuleReference get moduleReference;
}

/// interface ExternalModuleReference extends Node
abstract class ExternalModuleReference {
  /// kind: SyntaxKind.ExternalModuleReference
  SyntaxKind get kind;
  /// parent: ImportEqualsDeclaration
  ImportEqualsDeclaration get parent;
  /// expression: Expression
  Expression get expression;
}

/// interface ImportDeclaration extends Statement
abstract class ImportDeclaration {
  /// kind: SyntaxKind.ImportDeclaration
  SyntaxKind get kind;
  /// parent: SourceFile | ModuleBlock
  Object? get parent;
  /// optional modifiers: NodeArray<ModifierLike>
  NodeArray<ModifierLike>? get modifiers;
  /// optional importClause: ImportClause
  ImportClause? get importClause;
  /// moduleSpecifier: Expression
  Expression get moduleSpecifier;
  /// optional assertClause: AssertClause
  AssertClause? get assertClause;
  /// optional attributes: ImportAttributes
  ImportAttributes? get attributes;
}

/// interface ImportClause extends NamedDeclaration
abstract class ImportClause {
  /// kind: SyntaxKind.ImportClause
  SyntaxKind get kind;
  /// parent: ImportDeclaration | JSDocImportTag
  Object? get parent;
  /// isTypeOnly: boolean
  bool get isTypeOnly;
  /// phaseModifier: undefined | ImportPhaseModifierSyntaxKind
  ImportPhaseModifierSyntaxKind? get phaseModifier;
  /// optional name: Identifier
  Identifier? get name;
  /// optional namedBindings: NamedImportBindings
  NamedImportBindings? get namedBindings;
}

/// interface AssertEntry extends ImportAttribute
abstract class AssertEntry {
}

/// interface AssertClause extends ImportAttributes
abstract class AssertClause {
}

/// interface ImportAttribute extends Node
abstract class ImportAttribute {
  /// kind: SyntaxKind.ImportAttribute
  SyntaxKind get kind;
  /// parent: ImportAttributes
  ImportAttributes get parent;
  /// name: ImportAttributeName
  ImportAttributeName get name;
  /// value: Expression
  Expression get value;
}

/// interface ImportAttributes extends Node
abstract class ImportAttributes {
  /// token: SyntaxKind.WithKeyword | SyntaxKind.AssertKeyword
  Object? get token;
  /// kind: SyntaxKind.ImportAttributes
  SyntaxKind get kind;
  /// parent: ImportDeclaration | ExportDeclaration
  Object? get parent;
  /// elements: NodeArray<ImportAttribute>
  NodeArray<ImportAttribute> get elements;
  /// optional multiLine: boolean
  bool? get multiLine;
}

/// interface NamespaceImport extends NamedDeclaration
abstract class NamespaceImport {
  /// kind: SyntaxKind.NamespaceImport
  SyntaxKind get kind;
  /// parent: ImportClause
  ImportClause get parent;
  /// name: Identifier
  Identifier get name;
}

/// interface NamespaceExport extends NamedDeclaration
abstract class NamespaceExport {
  /// kind: SyntaxKind.NamespaceExport
  SyntaxKind get kind;
  /// parent: ExportDeclaration
  ExportDeclaration get parent;
  /// name: ModuleExportName
  ModuleExportName get name;
}

/// interface NamespaceExportDeclaration extends DeclarationStatement, JSDocContainer
abstract class NamespaceExportDeclaration {
  /// kind: SyntaxKind.NamespaceExportDeclaration
  SyntaxKind get kind;
  /// name: Identifier
  Identifier get name;
}

/// interface ExportDeclaration extends DeclarationStatement, JSDocContainer
abstract class ExportDeclaration {
  /// kind: SyntaxKind.ExportDeclaration
  SyntaxKind get kind;
  /// parent: SourceFile | ModuleBlock
  Object? get parent;
  /// optional modifiers: NodeArray<ModifierLike>
  NodeArray<ModifierLike>? get modifiers;
  /// isTypeOnly: boolean
  bool get isTypeOnly;
  /// optional exportClause: NamedExportBindings
  NamedExportBindings? get exportClause;
  /// optional moduleSpecifier: Expression
  Expression? get moduleSpecifier;
  /// optional assertClause: AssertClause
  AssertClause? get assertClause;
  /// optional attributes: ImportAttributes
  ImportAttributes? get attributes;
}

/// interface NamedImports extends Node
abstract class NamedImports {
  /// kind: SyntaxKind.NamedImports
  SyntaxKind get kind;
  /// parent: ImportClause
  ImportClause get parent;
  /// elements: NodeArray<ImportSpecifier>
  NodeArray<ImportSpecifier> get elements;
}

/// interface NamedExports extends Node
abstract class NamedExports {
  /// kind: SyntaxKind.NamedExports
  SyntaxKind get kind;
  /// parent: ExportDeclaration
  ExportDeclaration get parent;
  /// elements: NodeArray<ExportSpecifier>
  NodeArray<ExportSpecifier> get elements;
}

/// interface ImportSpecifier extends NamedDeclaration
abstract class ImportSpecifier {
  /// kind: SyntaxKind.ImportSpecifier
  SyntaxKind get kind;
  /// parent: NamedImports
  NamedImports get parent;
  /// optional propertyName: ModuleExportName
  ModuleExportName? get propertyName;
  /// name: Identifier
  Identifier get name;
  /// isTypeOnly: boolean
  bool get isTypeOnly;
}

/// interface ExportSpecifier extends NamedDeclaration, JSDocContainer
abstract class ExportSpecifier {
  /// kind: SyntaxKind.ExportSpecifier
  SyntaxKind get kind;
  /// parent: NamedExports
  NamedExports get parent;
  /// isTypeOnly: boolean
  bool get isTypeOnly;
  /// optional propertyName: ModuleExportName
  ModuleExportName? get propertyName;
  /// name: ModuleExportName
  ModuleExportName get name;
}

/// interface ExportAssignment extends DeclarationStatement, JSDocContainer
abstract class ExportAssignment {
  /// kind: SyntaxKind.ExportAssignment
  SyntaxKind get kind;
  /// parent: SourceFile
  SourceFile get parent;
  /// optional modifiers: NodeArray<ModifierLike>
  NodeArray<ModifierLike>? get modifiers;
  /// optional isExportEquals: boolean
  bool? get isExportEquals;
  /// expression: Expression
  Expression get expression;
}

/// interface FileReference extends TextRange
abstract class FileReference {
  /// fileName: string
  String get fileName;
  /// optional resolutionMode: ResolutionMode
  ResolutionMode? get resolutionMode;
  /// optional preserve: boolean
  bool? get preserve;
}

/// interface CheckJsDirective extends TextRange
abstract class CheckJsDirective {
  /// enabled: boolean
  bool get enabled;
}

/// interface CommentRange extends TextRange
abstract class CommentRange {
  /// optional hasTrailingNewLine: boolean
  bool? get hasTrailingNewLine;
  /// kind: CommentKind
  CommentKind get kind;
}

/// interface SynthesizedComment extends CommentRange
abstract class SynthesizedComment {
  /// text: string
  String get text;
  /// pos: -1
  Object? get pos;
  /// end: -1
  Object? get end;
  /// optional hasLeadingNewline: boolean
  bool? get hasLeadingNewline;
}

/// interface JSDocTypeExpression extends TypeNode
abstract class JSDocTypeExpression {
  /// kind: SyntaxKind.JSDocTypeExpression
  SyntaxKind get kind;
  /// type: TypeNode
  TypeNode get type;
}

/// interface JSDocNameReference extends Node
abstract class JSDocNameReference {
  /// kind: SyntaxKind.JSDocNameReference
  SyntaxKind get kind;
  /// name: EntityName | JSDocMemberName
  Object? get name;
}

/// interface JSDocMemberName extends Node
abstract class JSDocMemberName {
  /// kind: SyntaxKind.JSDocMemberName
  SyntaxKind get kind;
  /// left: EntityName | JSDocMemberName
  Object? get left;
  /// right: Identifier
  Identifier get right;
}

/// interface JSDocType extends TypeNode
abstract class JSDocType {
  /// _jsDocTypeBrand: any
  Object? get jsDocTypeBrand;
}

/// interface JSDocAllType extends JSDocType
abstract class JSDocAllType {
  /// kind: SyntaxKind.JSDocAllType
  SyntaxKind get kind;
}

/// interface JSDocUnknownType extends JSDocType
abstract class JSDocUnknownType {
  /// kind: SyntaxKind.JSDocUnknownType
  SyntaxKind get kind;
}

/// interface JSDocNonNullableType extends JSDocType
abstract class JSDocNonNullableType {
  /// kind: SyntaxKind.JSDocNonNullableType
  SyntaxKind get kind;
  /// type: TypeNode
  TypeNode get type;
  /// postfix: boolean
  bool get postfix;
}

/// interface JSDocNullableType extends JSDocType
abstract class JSDocNullableType {
  /// kind: SyntaxKind.JSDocNullableType
  SyntaxKind get kind;
  /// type: TypeNode
  TypeNode get type;
  /// postfix: boolean
  bool get postfix;
}

/// interface JSDocOptionalType extends JSDocType
abstract class JSDocOptionalType {
  /// kind: SyntaxKind.JSDocOptionalType
  SyntaxKind get kind;
  /// type: TypeNode
  TypeNode get type;
}

/// interface JSDocFunctionType extends JSDocType, SignatureDeclarationBase, LocalsContainer
abstract class JSDocFunctionType {
  /// kind: SyntaxKind.JSDocFunctionType
  SyntaxKind get kind;
}

/// interface JSDocVariadicType extends JSDocType
abstract class JSDocVariadicType {
  /// kind: SyntaxKind.JSDocVariadicType
  SyntaxKind get kind;
  /// type: TypeNode
  TypeNode get type;
}

/// interface JSDocNamepathType extends JSDocType
abstract class JSDocNamepathType {
  /// kind: SyntaxKind.JSDocNamepathType
  SyntaxKind get kind;
  /// type: TypeNode
  TypeNode get type;
}

/// interface JSDoc extends Node
abstract class JSDoc {
  /// kind: SyntaxKind.JSDoc
  SyntaxKind get kind;
  /// parent: HasJSDoc
  HasJSDoc get parent;
  /// optional tags: NodeArray<JSDocTag>
  NodeArray<JSDocTag>? get tags;
  /// optional comment: string | NodeArray<JSDocComment>
  Object? get comment;
}

/// interface JSDocTag extends Node
abstract class JSDocTag {
  /// parent: JSDoc | JSDocTypeLiteral
  Object? get parent;
  /// tagName: Identifier
  Identifier get tagName;
  /// optional comment: string | NodeArray<JSDocComment>
  Object? get comment;
}

/// interface JSDocLink extends Node
abstract class JSDocLink {
  /// kind: SyntaxKind.JSDocLink
  SyntaxKind get kind;
  /// optional name: EntityName | JSDocMemberName
  Object? get name;
  /// text: string
  String get text;
}

/// interface JSDocLinkCode extends Node
abstract class JSDocLinkCode {
  /// kind: SyntaxKind.JSDocLinkCode
  SyntaxKind get kind;
  /// optional name: EntityName | JSDocMemberName
  Object? get name;
  /// text: string
  String get text;
}

/// interface JSDocLinkPlain extends Node
abstract class JSDocLinkPlain {
  /// kind: SyntaxKind.JSDocLinkPlain
  SyntaxKind get kind;
  /// optional name: EntityName | JSDocMemberName
  Object? get name;
  /// text: string
  String get text;
}

/// interface JSDocText extends Node
abstract class JSDocText {
  /// kind: SyntaxKind.JSDocText
  SyntaxKind get kind;
  /// text: string
  String get text;
}

/// interface JSDocUnknownTag extends JSDocTag
abstract class JSDocUnknownTag {
  /// kind: SyntaxKind.JSDocTag
  SyntaxKind get kind;
}

/// interface JSDocAugmentsTag extends JSDocTag
abstract class JSDocAugmentsTag {
  /// kind: SyntaxKind.JSDocAugmentsTag
  SyntaxKind get kind;
  /// class: ExpressionWithTypeArguments & { readonly expression: Identifier | PropertyAccessEntityNameExpression; }
  Object? get class_;
}

/// interface JSDocImplementsTag extends JSDocTag
abstract class JSDocImplementsTag {
  /// kind: SyntaxKind.JSDocImplementsTag
  SyntaxKind get kind;
  /// class: ExpressionWithTypeArguments & { readonly expression: Identifier | PropertyAccessEntityNameExpression; }
  Object? get class_;
}

/// interface JSDocAuthorTag extends JSDocTag
abstract class JSDocAuthorTag {
  /// kind: SyntaxKind.JSDocAuthorTag
  SyntaxKind get kind;
}

/// interface JSDocDeprecatedTag extends JSDocTag
abstract class JSDocDeprecatedTag {
  /// kind: SyntaxKind.JSDocDeprecatedTag
  SyntaxKind get kind;
}

/// interface JSDocClassTag extends JSDocTag
abstract class JSDocClassTag {
  /// kind: SyntaxKind.JSDocClassTag
  SyntaxKind get kind;
}

/// interface JSDocPublicTag extends JSDocTag
abstract class JSDocPublicTag {
  /// kind: SyntaxKind.JSDocPublicTag
  SyntaxKind get kind;
}

/// interface JSDocPrivateTag extends JSDocTag
abstract class JSDocPrivateTag {
  /// kind: SyntaxKind.JSDocPrivateTag
  SyntaxKind get kind;
}

/// interface JSDocProtectedTag extends JSDocTag
abstract class JSDocProtectedTag {
  /// kind: SyntaxKind.JSDocProtectedTag
  SyntaxKind get kind;
}

/// interface JSDocReadonlyTag extends JSDocTag
abstract class JSDocReadonlyTag {
  /// kind: SyntaxKind.JSDocReadonlyTag
  SyntaxKind get kind;
}

/// interface JSDocOverrideTag extends JSDocTag
abstract class JSDocOverrideTag {
  /// kind: SyntaxKind.JSDocOverrideTag
  SyntaxKind get kind;
}

/// interface JSDocEnumTag extends JSDocTag, Declaration, LocalsContainer
abstract class JSDocEnumTag {
  /// kind: SyntaxKind.JSDocEnumTag
  SyntaxKind get kind;
  /// parent: JSDoc
  JSDoc get parent;
  /// typeExpression: JSDocTypeExpression
  JSDocTypeExpression get typeExpression;
}

/// interface JSDocThisTag extends JSDocTag
abstract class JSDocThisTag {
  /// kind: SyntaxKind.JSDocThisTag
  SyntaxKind get kind;
  /// typeExpression: JSDocTypeExpression
  JSDocTypeExpression get typeExpression;
}

/// interface JSDocTemplateTag extends JSDocTag
abstract class JSDocTemplateTag {
  /// kind: SyntaxKind.JSDocTemplateTag
  SyntaxKind get kind;
  /// constraint: JSDocTypeExpression | undefined
  JSDocTypeExpression? get constraint;
  /// typeParameters: NodeArray<TypeParameterDeclaration>
  NodeArray<TypeParameterDeclaration> get typeParameters;
}

/// interface JSDocSeeTag extends JSDocTag
abstract class JSDocSeeTag {
  /// kind: SyntaxKind.JSDocSeeTag
  SyntaxKind get kind;
  /// optional name: JSDocNameReference
  JSDocNameReference? get name;
}

/// interface JSDocReturnTag extends JSDocTag
abstract class JSDocReturnTag {
  /// kind: SyntaxKind.JSDocReturnTag
  SyntaxKind get kind;
  /// optional typeExpression: JSDocTypeExpression
  JSDocTypeExpression? get typeExpression;
}

/// interface JSDocTypeTag extends JSDocTag
abstract class JSDocTypeTag {
  /// kind: SyntaxKind.JSDocTypeTag
  SyntaxKind get kind;
  /// typeExpression: JSDocTypeExpression
  JSDocTypeExpression get typeExpression;
}

/// interface JSDocTypedefTag extends JSDocTag, NamedDeclaration, LocalsContainer
abstract class JSDocTypedefTag {
  /// kind: SyntaxKind.JSDocTypedefTag
  SyntaxKind get kind;
  /// parent: JSDoc
  JSDoc get parent;
  /// optional fullName: JSDocNamespaceDeclaration | Identifier
  Object? get fullName;
  /// optional name: Identifier
  Identifier? get name;
  /// optional typeExpression: JSDocTypeExpression | JSDocTypeLiteral
  Object? get typeExpression;
}

/// interface JSDocCallbackTag extends JSDocTag, NamedDeclaration, LocalsContainer
abstract class JSDocCallbackTag {
  /// kind: SyntaxKind.JSDocCallbackTag
  SyntaxKind get kind;
  /// parent: JSDoc
  JSDoc get parent;
  /// optional fullName: JSDocNamespaceDeclaration | Identifier
  Object? get fullName;
  /// optional name: Identifier
  Identifier? get name;
  /// typeExpression: JSDocSignature
  JSDocSignature get typeExpression;
}

/// interface JSDocOverloadTag extends JSDocTag
abstract class JSDocOverloadTag {
  /// kind: SyntaxKind.JSDocOverloadTag
  SyntaxKind get kind;
  /// parent: JSDoc
  JSDoc get parent;
  /// typeExpression: JSDocSignature
  JSDocSignature get typeExpression;
}

/// interface JSDocThrowsTag extends JSDocTag
abstract class JSDocThrowsTag {
  /// kind: SyntaxKind.JSDocThrowsTag
  SyntaxKind get kind;
  /// optional typeExpression: JSDocTypeExpression
  JSDocTypeExpression? get typeExpression;
}

/// interface JSDocSignature extends JSDocType, Declaration, JSDocContainer, LocalsContainer
abstract class JSDocSignature {
  /// kind: SyntaxKind.JSDocSignature
  SyntaxKind get kind;
  /// optional typeParameters: readonly JSDocTemplateTag[]
  List<JSDocTemplateTag>? get typeParameters;
  /// parameters: readonly JSDocParameterTag[]
  List<JSDocParameterTag> get parameters;
  /// type: JSDocReturnTag | undefined
  JSDocReturnTag? get type;
}

/// interface JSDocPropertyLikeTag extends JSDocTag, Declaration
abstract class JSDocPropertyLikeTag {
  /// parent: JSDoc
  JSDoc get parent;
  /// name: EntityName
  EntityName get name;
  /// optional typeExpression: JSDocTypeExpression
  JSDocTypeExpression? get typeExpression;
  /// isNameFirst: boolean
  bool get isNameFirst;
  /// isBracketed: boolean
  bool get isBracketed;
}

/// interface JSDocPropertyTag extends JSDocPropertyLikeTag
abstract class JSDocPropertyTag {
  /// kind: SyntaxKind.JSDocPropertyTag
  SyntaxKind get kind;
}

/// interface JSDocParameterTag extends JSDocPropertyLikeTag
abstract class JSDocParameterTag {
  /// kind: SyntaxKind.JSDocParameterTag
  SyntaxKind get kind;
}

/// interface JSDocTypeLiteral extends JSDocType, Declaration
abstract class JSDocTypeLiteral {
  /// kind: SyntaxKind.JSDocTypeLiteral
  SyntaxKind get kind;
  /// optional jsDocPropertyTags: readonly JSDocPropertyLikeTag[]
  List<JSDocPropertyLikeTag>? get jsDocPropertyTags;
  /// isArrayType: boolean
  bool get isArrayType;
}

/// interface JSDocSatisfiesTag extends JSDocTag
abstract class JSDocSatisfiesTag {
  /// kind: SyntaxKind.JSDocSatisfiesTag
  SyntaxKind get kind;
  /// typeExpression: JSDocTypeExpression
  JSDocTypeExpression get typeExpression;
}

/// interface JSDocImportTag extends JSDocTag
abstract class JSDocImportTag {
  /// kind: SyntaxKind.JSDocImportTag
  SyntaxKind get kind;
  /// parent: JSDoc
  JSDoc get parent;
  /// optional importClause: ImportClause
  ImportClause? get importClause;
  /// moduleSpecifier: Expression
  Expression get moduleSpecifier;
  /// optional attributes: ImportAttributes
  ImportAttributes? get attributes;
}

/// interface IncompleteType
abstract class IncompleteType {
  /// flags: TypeFlags | 0
  Object? get flags;
  /// type: Type
  Type get type;
}

/// interface AmdDependency
abstract class AmdDependency {
  /// path: string
  String get path;
  /// optional name: string
  String? get name;
}

/// interface SourceFileLike
abstract class SourceFileLike {
  /// text: string
  String get text;
  /// getLineAndCharacterOfPosition(pos: number): LineAndCharacter;
  LineAndCharacter getLineAndCharacterOfPosition(num pos);
}

/// interface SourceFile extends Declaration, LocalsContainer
abstract class SourceFile {
  /// kind: SyntaxKind.SourceFile
  SyntaxKind get kind;
  /// statements: NodeArray<Statement>
  NodeArray<Statement> get statements;
  /// endOfFileToken: Token<SyntaxKind.EndOfFileToken>
  Token<SyntaxKind> get endOfFileToken;
  /// fileName: string
  String get fileName;
  /// text: string
  String get text;
  /// amdDependencies: readonly AmdDependency[]
  List<AmdDependency> get amdDependencies;
  /// optional moduleName: string
  String? get moduleName;
  /// referencedFiles: readonly FileReference[]
  List<FileReference> get referencedFiles;
  /// typeReferenceDirectives: readonly FileReference[]
  List<FileReference> get typeReferenceDirectives;
  /// libReferenceDirectives: readonly FileReference[]
  List<FileReference> get libReferenceDirectives;
  /// languageVariant: LanguageVariant
  LanguageVariant get languageVariant;
  /// isDeclarationFile: boolean
  bool get isDeclarationFile;
  /// hasNoDefaultLib: boolean
  bool get hasNoDefaultLib;
  /// languageVersion: ScriptTarget
  ScriptTarget get languageVersion;
  /// optional impliedNodeFormat: ResolutionMode
  ResolutionMode? get impliedNodeFormat;
  /// getLineAndCharacterOfPosition(pos: number): LineAndCharacter;
  LineAndCharacter getLineAndCharacterOfPosition(num pos);
  /// getLineEndOfPosition(pos: number): number;
  num getLineEndOfPosition(num pos);
  /// getLineStarts(): readonly number[];
  List<num> getLineStarts();
  /// getPositionOfLineAndCharacter(line: number, character: number): number;
  num getPositionOfLineAndCharacter(num line, num character);
  /// update(newText: string, textChangeRange: TextChangeRange): SourceFile;
  SourceFile update(String newText, TextChangeRange textChangeRange);
}

/// interface Bundle extends Node
abstract class Bundle {
  /// kind: SyntaxKind.Bundle
  SyntaxKind get kind;
  /// sourceFiles: readonly SourceFile[]
  List<SourceFile> get sourceFiles;
}

/// interface JsonSourceFile extends SourceFile
abstract class JsonSourceFile {
  /// statements: NodeArray<JsonObjectExpressionStatement>
  NodeArray<JsonObjectExpressionStatement> get statements;
}

/// interface TsConfigSourceFile extends JsonSourceFile
abstract class TsConfigSourceFile {
  /// optional extendedSourceFiles: string[]
  List<String>? get extendedSourceFiles;
}

/// interface JsonMinusNumericLiteral extends PrefixUnaryExpression
abstract class JsonMinusNumericLiteral {
  /// kind: SyntaxKind.PrefixUnaryExpression
  SyntaxKind get kind;
  /// operator: SyntaxKind.MinusToken
  SyntaxKind get operator_;
  /// operand: NumericLiteral
  NumericLiteral get operand;
}

/// interface JsonObjectExpressionStatement extends ExpressionStatement
abstract class JsonObjectExpressionStatement {
  /// expression: JsonObjectExpression
  JsonObjectExpression get expression;
}

/// interface ScriptReferenceHost
abstract class ScriptReferenceHost {
  /// getCompilerOptions(): CompilerOptions;
  CompilerOptions getCompilerOptions();
  /// getSourceFile(fileName: string): SourceFile | undefined;
  SourceFile? getSourceFile(String fileName);
  /// getSourceFileByPath(path: Path): SourceFile | undefined;
  SourceFile? getSourceFileByPath(Path path);
  /// getCurrentDirectory(): string;
  String getCurrentDirectory();
}

/// interface ParseConfigHost extends ModuleResolutionHost
abstract class ParseConfigHost {
  /// useCaseSensitiveFileNames: boolean
  bool get useCaseSensitiveFileNames;
  /// readDirectory(rootDir: string, extensions: readonly string[], excludes: readonly string[] | undefined, includes: readonly string[], depth?: number): readonly string[];
  List<String> readDirectory(String rootDir, List<String> extensions, List<String>? excludes, List<String> includes, [num? depth]);
  /// fileExists(path: string): boolean;
  bool fileExists(String path);
  /// readFile(path: string): string | undefined;
  String? readFile(String path);
  /// trace?(s: string): void;
  void trace(String s);
}

/// interface WriteFileCallbackData
abstract class WriteFileCallbackData {
}

/// interface CancellationToken
abstract class CancellationToken {
  /// isCancellationRequested(): boolean;
  bool isCancellationRequested();
  /// throwIfCancellationRequested(): void;
  void throwIfCancellationRequested();
}

/// interface Program extends ScriptReferenceHost
abstract class Program {
  /// getCurrentDirectory(): string;
  String getCurrentDirectory();
  /// getRootFileNames(): readonly string[];
  List<String> getRootFileNames();
  /// getSourceFiles(): readonly SourceFile[];
  List<SourceFile> getSourceFiles();
  /// emit(targetSourceFile?: SourceFile, writeFile?: WriteFileCallback, cancellationToken?: CancellationToken, emitOnlyDtsFiles?: boolean, customTransformers?: CustomTransformers): EmitResult;
  EmitResult emit([SourceFile? targetSourceFile, WriteFileCallback? writeFile, CancellationToken? cancellationToken, bool? emitOnlyDtsFiles, CustomTransformers? customTransformers]);
  /// getOptionsDiagnostics(cancellationToken?: CancellationToken): readonly Diagnostic[];
  List<Diagnostic> getOptionsDiagnostics([CancellationToken? cancellationToken]);
  /// getGlobalDiagnostics(cancellationToken?: CancellationToken): readonly Diagnostic[];
  List<Diagnostic> getGlobalDiagnostics([CancellationToken? cancellationToken]);
  /// getSyntacticDiagnostics(sourceFile?: SourceFile, cancellationToken?: CancellationToken): readonly DiagnosticWithLocation[];
  List<DiagnosticWithLocation> getSyntacticDiagnostics([SourceFile? sourceFile, CancellationToken? cancellationToken]);
  /// getSemanticDiagnostics(sourceFile?: SourceFile, cancellationToken?: CancellationToken): readonly Diagnostic[];
  List<Diagnostic> getSemanticDiagnostics([SourceFile? sourceFile, CancellationToken? cancellationToken]);
  /// getDeclarationDiagnostics(sourceFile?: SourceFile, cancellationToken?: CancellationToken): readonly DiagnosticWithLocation[];
  List<DiagnosticWithLocation> getDeclarationDiagnostics([SourceFile? sourceFile, CancellationToken? cancellationToken]);
  /// getConfigFileParsingDiagnostics(): readonly Diagnostic[];
  List<Diagnostic> getConfigFileParsingDiagnostics();
  /// getTypeChecker(): TypeChecker;
  TypeChecker getTypeChecker();
  /// getNodeCount(): number;
  num getNodeCount();
  /// getIdentifierCount(): number;
  num getIdentifierCount();
  /// getSymbolCount(): number;
  num getSymbolCount();
  /// getTypeCount(): number;
  num getTypeCount();
  /// getInstantiationCount(): number;
  num getInstantiationCount();
  /// getRelationCacheSizes(): { assignable: number; identity: number; subtype: number; strictSubtype: number; };
  Map<String, Object?> getRelationCacheSizes();
  /// isSourceFileFromExternalLibrary(file: SourceFile): boolean;
  bool isSourceFileFromExternalLibrary(SourceFile file);
  /// isSourceFileDefaultLibrary(file: SourceFile): boolean;
  bool isSourceFileDefaultLibrary(SourceFile file);
  /// getModeForUsageLocation(file: SourceFile, usage: StringLiteralLike): ResolutionMode;
  ResolutionMode getModeForUsageLocation(SourceFile file, StringLiteralLike usage);
  /// getModeForResolutionAtIndex(file: SourceFile, index: number): ResolutionMode;
  ResolutionMode getModeForResolutionAtIndex(SourceFile file, num index);
  /// getProjectReferences(): readonly ProjectReference[] | undefined;
  List<ProjectReference>? getProjectReferences();
  /// getResolvedProjectReferences(): readonly (ResolvedProjectReference | undefined)[] | undefined;
  List<ResolvedProjectReference?>? getResolvedProjectReferences();
}

/// interface ResolvedProjectReference
abstract class ResolvedProjectReference {
  /// commandLine: ParsedCommandLine
  ParsedCommandLine get commandLine;
  /// sourceFile: SourceFile
  SourceFile get sourceFile;
  /// optional references: readonly (ResolvedProjectReference | undefined)[]
  List<ResolvedProjectReference?>? get references;
}

/// interface CustomTransformer
abstract class CustomTransformer {
  /// transformSourceFile(node: SourceFile): SourceFile;
  SourceFile transformSourceFile(SourceFile node);
  /// transformBundle(node: Bundle): Bundle;
  Bundle transformBundle(Bundle node);
}

/// interface CustomTransformers
abstract class CustomTransformers {
  /// optional before: (TransformerFactory<SourceFile> | CustomTransformerFactory)[]
  List<Object?>? get before;
  /// optional after: (TransformerFactory<SourceFile> | CustomTransformerFactory)[]
  List<Object?>? get after;
  /// optional afterDeclarations: (TransformerFactory<Bundle | SourceFile> | CustomTransformerFactory)[]
  List<Object?>? get afterDeclarations;
}

/// interface SourceMapSpan
abstract class SourceMapSpan {
  /// emittedLine: number
  num get emittedLine;
  /// emittedColumn: number
  num get emittedColumn;
  /// sourceLine: number
  num get sourceLine;
  /// sourceColumn: number
  num get sourceColumn;
  /// optional nameIndex: number
  num? get nameIndex;
  /// sourceIndex: number
  num get sourceIndex;
}

/// interface EmitResult
abstract class EmitResult {
  /// emitSkipped: boolean
  bool get emitSkipped;
  /// diagnostics: readonly Diagnostic[]
  List<Diagnostic> get diagnostics;
  /// optional emittedFiles: string[]
  List<String>? get emittedFiles;
}

/// interface TypeChecker
abstract class TypeChecker {
  /// getTypeOfSymbolAtLocation(symbol: Symbol, node: Node): Type;
  Type getTypeOfSymbolAtLocation(Symbol symbol, Node node);
  /// getTypeOfSymbol(symbol: Symbol): Type;
  Type getTypeOfSymbol(Symbol symbol);
  /// getDeclaredTypeOfSymbol(symbol: Symbol): Type;
  Type getDeclaredTypeOfSymbol(Symbol symbol);
  /// getPropertiesOfType(type: Type): Symbol[];
  List<Symbol> getPropertiesOfType(Type type);
  /// getPropertyOfType(type: Type, propertyName: string): Symbol | undefined;
  Symbol? getPropertyOfType(Type type, String propertyName);
  /// getPrivateIdentifierPropertyOfType(leftType: Type, name: string, location: Node): Symbol | undefined;
  Symbol? getPrivateIdentifierPropertyOfType(Type leftType, String name, Node location);
  /// getIndexInfoOfType(type: Type, kind: IndexKind): IndexInfo | undefined;
  IndexInfo? getIndexInfoOfType(Type type, IndexKind kind);
  /// getIndexInfosOfType(type: Type): readonly IndexInfo[];
  List<IndexInfo> getIndexInfosOfType(Type type);
  /// getIndexInfosOfIndexSymbol: (indexSymbol: Symbol, siblingSymbols?: Symbol[] | undefined) => IndexInfo[]
  Object? Function(Object?) get getIndexInfosOfIndexSymbol;
  /// getSignaturesOfType(type: Type, kind: SignatureKind): readonly Signature[];
  List<Signature> getSignaturesOfType(Type type, SignatureKind kind);
  /// getIndexTypeOfType(type: Type, kind: IndexKind): Type | undefined;
  Type? getIndexTypeOfType(Type type, IndexKind kind);
  /// getBaseTypes(type: InterfaceType): BaseType[];
  List<BaseType> getBaseTypes(InterfaceType type);
  /// getBaseTypeOfLiteralType(type: Type): Type;
  Type getBaseTypeOfLiteralType(Type type);
  /// getWidenedType(type: Type): Type;
  Type getWidenedType(Type type);
  /// getAwaitedType(type: Type): Type | undefined;
  Type? getAwaitedType(Type type);
  /// getReturnTypeOfSignature(signature: Signature): Type;
  Type getReturnTypeOfSignature(Signature signature);
  /// getNullableType(type: Type, flags: TypeFlags): Type;
  Type getNullableType(Type type, TypeFlags flags);
  /// getNonNullableType(type: Type): Type;
  Type getNonNullableType(Type type);
  /// getTypeArguments(type: TypeReference): readonly Type[];
  List<Type> getTypeArguments(TypeReference type);
  /// typeToTypeNode(type: Type, enclosingDeclaration: Node | undefined, flags: NodeBuilderFlags | undefined): TypeNode | undefined;
  TypeNode? typeToTypeNode(Type type, Node? enclosingDeclaration, NodeBuilderFlags? flags);
  /// signatureToSignatureDeclaration(signature: Signature, kind: SyntaxKind, enclosingDeclaration: Node | undefined, flags: NodeBuilderFlags | undefined): | SignatureDeclaration & { typeArguments?: NodeArray<TypeNode>; } | undefined;
  Object? signatureToSignatureDeclaration(Signature signature, SyntaxKind kind, Node? enclosingDeclaration, NodeBuilderFlags? flags);
  /// indexInfoToIndexSignatureDeclaration(indexInfo: IndexInfo, enclosingDeclaration: Node | undefined, flags: NodeBuilderFlags | undefined): IndexSignatureDeclaration | undefined;
  IndexSignatureDeclaration? indexInfoToIndexSignatureDeclaration(IndexInfo indexInfo, Node? enclosingDeclaration, NodeBuilderFlags? flags);
  /// symbolToEntityName(symbol: Symbol, meaning: SymbolFlags, enclosingDeclaration: Node | undefined, flags: NodeBuilderFlags | undefined): EntityName | undefined;
  EntityName? symbolToEntityName(Symbol symbol, SymbolFlags meaning, Node? enclosingDeclaration, NodeBuilderFlags? flags);
  /// symbolToExpression(symbol: Symbol, meaning: SymbolFlags, enclosingDeclaration: Node | undefined, flags: NodeBuilderFlags | undefined): Expression | undefined;
  Expression? symbolToExpression(Symbol symbol, SymbolFlags meaning, Node? enclosingDeclaration, NodeBuilderFlags? flags);
  /// symbolToTypeParameterDeclarations(symbol: Symbol, enclosingDeclaration: Node | undefined, flags: NodeBuilderFlags | undefined): NodeArray<TypeParameterDeclaration> | undefined;
  NodeArray<TypeParameterDeclaration>? symbolToTypeParameterDeclarations(Symbol symbol, Node? enclosingDeclaration, NodeBuilderFlags? flags);
  /// symbolToParameterDeclaration(symbol: Symbol, enclosingDeclaration: Node | undefined, flags: NodeBuilderFlags | undefined): ParameterDeclaration | undefined;
  ParameterDeclaration? symbolToParameterDeclaration(Symbol symbol, Node? enclosingDeclaration, NodeBuilderFlags? flags);
  /// typeParameterToDeclaration(parameter: TypeParameter, enclosingDeclaration: Node | undefined, flags: NodeBuilderFlags | undefined): TypeParameterDeclaration | undefined;
  TypeParameterDeclaration? typeParameterToDeclaration(TypeParameter parameter, Node? enclosingDeclaration, NodeBuilderFlags? flags);
  /// getSymbolsInScope(location: Node, meaning: SymbolFlags): Symbol[];
  List<Symbol> getSymbolsInScope(Node location, SymbolFlags meaning);
  /// getSymbolAtLocation(node: Node): Symbol | undefined;
  Symbol? getSymbolAtLocation(Node node);
  /// getSymbolsOfParameterPropertyDeclaration(parameter: ParameterDeclaration, parameterName: string): Symbol[];
  List<Symbol> getSymbolsOfParameterPropertyDeclaration(ParameterDeclaration parameter, String parameterName);
  /// getShorthandAssignmentValueSymbol(location: Node | undefined): Symbol | undefined;
  Symbol? getShorthandAssignmentValueSymbol(Node? location);
  /// getExportSpecifierLocalTargetSymbol(location: ExportSpecifier | Identifier): Symbol | undefined;
  Symbol? getExportSpecifierLocalTargetSymbol(Object? location);
  /// getExportSymbolOfSymbol(symbol: Symbol): Symbol;
  Symbol getExportSymbolOfSymbol(Symbol symbol);
  /// getPropertySymbolOfDestructuringAssignment(location: Identifier): Symbol | undefined;
  Symbol? getPropertySymbolOfDestructuringAssignment(Identifier location);
  /// getTypeOfAssignmentPattern(pattern: AssignmentPattern): Type;
  Type getTypeOfAssignmentPattern(AssignmentPattern pattern);
  /// getTypeAtLocation(node: Node): Type;
  Type getTypeAtLocation(Node node);
  /// getTypeFromTypeNode(node: TypeNode): Type;
  Type getTypeFromTypeNode(TypeNode node);
  /// signatureToString(signature: Signature, enclosingDeclaration?: Node, flags?: TypeFormatFlags, kind?: SignatureKind): string;
  String signatureToString(Signature signature, [Node? enclosingDeclaration, TypeFormatFlags? flags, SignatureKind? kind]);
  /// typeToString(type: Type, enclosingDeclaration?: Node, flags?: TypeFormatFlags): string;
  String typeToString(Type type, [Node? enclosingDeclaration, TypeFormatFlags? flags]);
  /// symbolToString(symbol: Symbol, enclosingDeclaration?: Node, meaning?: SymbolFlags, flags?: SymbolFormatFlags): string;
  String symbolToString(Symbol symbol, [Node? enclosingDeclaration, SymbolFlags? meaning, SymbolFormatFlags? flags]);
  /// typePredicateToString(predicate: TypePredicate, enclosingDeclaration?: Node, flags?: TypeFormatFlags): string;
  String typePredicateToString(TypePredicate predicate, [Node? enclosingDeclaration, TypeFormatFlags? flags]);
  /// getFullyQualifiedName(symbol: Symbol): string;
  String getFullyQualifiedName(Symbol symbol);
  /// getAugmentedPropertiesOfType(type: Type): Symbol[];
  List<Symbol> getAugmentedPropertiesOfType(Type type);
  /// getRootSymbols(symbol: Symbol): readonly Symbol[];
  List<Symbol> getRootSymbols(Symbol symbol);
  /// getSymbolOfExpando(node: Node, allowDeclaration: boolean): Symbol | undefined;
  Symbol? getSymbolOfExpando(Node node, bool allowDeclaration);
  /// getContextualType(node: Expression): Type | undefined;
  Type? getContextualType(Expression node);
  /// getResolvedSignature(node: CallLikeExpression, candidatesOutArray?: Signature[], argumentCount?: number): Signature | undefined;
  Signature? getResolvedSignature(CallLikeExpression node, [List<Signature>? candidatesOutArray, num? argumentCount]);
  /// getSignatureFromDeclaration(declaration: SignatureDeclaration): Signature | undefined;
  Signature? getSignatureFromDeclaration(SignatureDeclaration declaration);
  /// isImplementationOfOverload(node: SignatureDeclaration): boolean | undefined;
  bool? isImplementationOfOverload(SignatureDeclaration node);
  /// isUndefinedSymbol(symbol: Symbol): boolean;
  bool isUndefinedSymbol(Symbol symbol);
  /// isArgumentsSymbol(symbol: Symbol): boolean;
  bool isArgumentsSymbol(Symbol symbol);
  /// isUnknownSymbol(symbol: Symbol): boolean;
  bool isUnknownSymbol(Symbol symbol);
  /// getMergedSymbol(symbol: Symbol): Symbol;
  Symbol getMergedSymbol(Symbol symbol);
  /// getConstantValue(node: EnumMember | PropertyAccessExpression | ElementAccessExpression): string | number | undefined;
  Object? getConstantValue(Object? node);
  /// isValidPropertyAccess(node: PropertyAccessExpression | QualifiedName | ImportTypeNode, propertyName: string): boolean;
  bool isValidPropertyAccess(Object? node, String propertyName);
  /// getAliasedSymbol(symbol: Symbol): Symbol;
  Symbol getAliasedSymbol(Symbol symbol);
  /// getImmediateAliasedSymbol(symbol: Symbol): Symbol | undefined;
  Symbol? getImmediateAliasedSymbol(Symbol symbol);
  /// getExportsOfModule(moduleSymbol: Symbol): Symbol[];
  List<Symbol> getExportsOfModule(Symbol moduleSymbol);
  /// getJsxIntrinsicTagNamesAt(location: Node): Symbol[];
  List<Symbol> getJsxIntrinsicTagNamesAt(Node location);
  /// isOptionalParameter(node: ParameterDeclaration): boolean;
  bool isOptionalParameter(ParameterDeclaration node);
  /// getAmbientModules(): Symbol[];
  List<Symbol> getAmbientModules();
  /// tryGetMemberInModuleExports(memberName: string, moduleSymbol: Symbol): Symbol | undefined;
  Symbol? tryGetMemberInModuleExports(String memberName, Symbol moduleSymbol);
  /// getApparentType(type: Type): Type;
  Type getApparentType(Type type);
  /// getBaseConstraintOfType(type: Type): Type | undefined;
  Type? getBaseConstraintOfType(Type type);
  /// getDefaultFromTypeParameter(type: Type): Type | undefined;
  Type? getDefaultFromTypeParameter(Type type);
  /// getAnyType(): Type;
  Type getAnyType();
  /// getStringType(): Type;
  Type getStringType();
  /// getStringLiteralType(value: string): StringLiteralType;
  StringLiteralType getStringLiteralType(String value);
  /// getNumberType(): Type;
  Type getNumberType();
  /// getNumberLiteralType(value: number): NumberLiteralType;
  NumberLiteralType getNumberLiteralType(num value);
  /// getBigIntType(): Type;
  Type getBigIntType();
  /// getBigIntLiteralType(value: PseudoBigInt): BigIntLiteralType;
  BigIntLiteralType getBigIntLiteralType(PseudoBigInt value);
  /// getBooleanType(): Type;
  Type getBooleanType();
  /// getUnknownType(): Type;
  Type getUnknownType();
  /// getFalseType(): Type;
  Type getFalseType();
  /// getTrueType(): Type;
  Type getTrueType();
  /// getVoidType(): Type;
  Type getVoidType();
  /// getUndefinedType(): Type;
  Type getUndefinedType();
  /// getNullType(): Type;
  Type getNullType();
  /// getESSymbolType(): Type;
  Type getESSymbolType();
  /// getNeverType(): Type;
  Type getNeverType();
  /// getNonPrimitiveType(): Type;
  Type getNonPrimitiveType();
  /// isTypeAssignableTo(source: Type, target: Type): boolean;
  bool isTypeAssignableTo(Type source, Type target);
  /// isArrayType(type: Type): boolean;
  bool isArrayType(Type type);
  /// isTupleType(type: Type): boolean;
  bool isTupleType(Type type);
  /// isArrayLikeType(type: Type): boolean;
  bool isArrayLikeType(Type type);
  /// resolveName(name: string, location: Node | undefined, meaning: SymbolFlags, excludeGlobals: boolean): Symbol | undefined;
  Symbol? resolveName(String name, Node? location, SymbolFlags meaning, bool excludeGlobals);
  /// getTypePredicateOfSignature(signature: Signature): TypePredicate | undefined;
  TypePredicate? getTypePredicateOfSignature(Signature signature);
  /// runWithCancellationToken<T>(token: CancellationToken, cb: (checker: TypeChecker) => T): T;
  T runWithCancellationToken<T>(CancellationToken token, Object? Function(Object?) cb);
  /// getTypeArgumentsForResolvedSignature(signature: Signature): readonly Type[] | undefined;
  List<Type>? getTypeArgumentsForResolvedSignature(Signature signature);
}

/// interface TypePredicateBase
abstract class TypePredicateBase {
  /// kind: TypePredicateKind
  TypePredicateKind get kind;
  /// type: Type | undefined
  Type? get type;
}

/// interface ThisTypePredicate extends TypePredicateBase
abstract class ThisTypePredicate {
  /// kind: TypePredicateKind.This
  TypePredicateKind get kind;
  /// parameterName: undefined
  Null get parameterName;
  /// parameterIndex: undefined
  Null get parameterIndex;
  /// type: Type
  Type get type;
}

/// interface IdentifierTypePredicate extends TypePredicateBase
abstract class IdentifierTypePredicate {
  /// kind: TypePredicateKind.Identifier
  TypePredicateKind get kind;
  /// parameterName: string
  String get parameterName;
  /// parameterIndex: number
  num get parameterIndex;
  /// type: Type
  Type get type;
}

/// interface AssertsThisTypePredicate extends TypePredicateBase
abstract class AssertsThisTypePredicate {
  /// kind: TypePredicateKind.AssertsThis
  TypePredicateKind get kind;
  /// parameterName: undefined
  Null get parameterName;
  /// parameterIndex: undefined
  Null get parameterIndex;
  /// type: Type | undefined
  Type? get type;
}

/// interface AssertsIdentifierTypePredicate extends TypePredicateBase
abstract class AssertsIdentifierTypePredicate {
  /// kind: TypePredicateKind.AssertsIdentifier
  TypePredicateKind get kind;
  /// parameterName: string
  String get parameterName;
  /// parameterIndex: number
  num get parameterIndex;
  /// type: Type | undefined
  Type? get type;
}

/// interface Symbol
abstract class Symbol {
  /// flags: SymbolFlags
  SymbolFlags get flags;
  /// escapedName: __String
  __String get escapedName;
  /// optional declarations: Declaration[]
  List<Declaration>? get declarations;
  /// optional valueDeclaration: Declaration
  Declaration? get valueDeclaration;
  /// optional members: SymbolTable
  SymbolTable? get members;
  /// optional exports: SymbolTable
  SymbolTable? get exports;
  /// optional globalExports: SymbolTable
  SymbolTable? get globalExports;
  /// name: string
  String get name;
  /// getFlags(): SymbolFlags;
  SymbolFlags getFlags();
  /// getEscapedName(): __String;
  __String getEscapedName();
  /// getName(): string;
  String getName();
  /// getDeclarations(): Declaration[] | undefined;
  List<Declaration>? getDeclarations();
  /// getDocumentationComment(typeChecker: TypeChecker | undefined): SymbolDisplayPart[];
  List<SymbolDisplayPart> getDocumentationComment(TypeChecker? typeChecker);
  /// getJsDocTags(checker?: TypeChecker): JSDocTagInfo[];
  List<JSDocTagInfo> getJsDocTags([TypeChecker? checker]);
}

/// interface Type
abstract class Type {
  /// flags: TypeFlags
  TypeFlags get flags;
  /// symbol: Symbol
  Symbol get symbol;
  /// optional pattern: DestructuringPattern
  DestructuringPattern? get pattern;
  /// optional aliasSymbol: Symbol
  Symbol? get aliasSymbol;
  /// optional aliasTypeArguments: readonly Type[]
  List<Type>? get aliasTypeArguments;
  /// getFlags(): TypeFlags;
  TypeFlags getFlags();
  /// getSymbol(): Symbol | undefined;
  Symbol? getSymbol();
  /// getProperties(): Symbol[];
  List<Symbol> getProperties();
  /// getProperty(propertyName: string): Symbol | undefined;
  Symbol? getProperty(String propertyName);
  /// getApparentProperties(): Symbol[];
  List<Symbol> getApparentProperties();
  /// getCallSignatures(): readonly Signature[];
  List<Signature> getCallSignatures();
  /// getConstructSignatures(): readonly Signature[];
  List<Signature> getConstructSignatures();
  /// getStringIndexType(): Type | undefined;
  Type? getStringIndexType();
  /// getNumberIndexType(): Type | undefined;
  Type? getNumberIndexType();
  /// getBaseTypes(): BaseType[] | undefined;
  List<BaseType>? getBaseTypes();
  /// getNonNullableType(): Type;
  Type getNonNullableType();
  /// getConstraint(): Type | undefined;
  Type? getConstraint();
  /// getDefault(): Type | undefined;
  Type? getDefault();
  /// isUnion(): this is UnionType;
  Object? isUnion();
  /// isIntersection(): this is IntersectionType;
  Object? isIntersection();
  /// isUnionOrIntersection(): this is UnionOrIntersectionType;
  Object? isUnionOrIntersection();
  /// isLiteral(): this is LiteralType;
  Object? isLiteral();
  /// isStringLiteral(): this is StringLiteralType;
  Object? isStringLiteral();
  /// isNumberLiteral(): this is NumberLiteralType;
  Object? isNumberLiteral();
  /// isTypeParameter(): this is TypeParameter;
  Object? isTypeParameter();
  /// isClassOrInterface(): this is InterfaceType;
  Object? isClassOrInterface();
  /// isClass(): this is InterfaceType;
  Object? isClass();
  /// isIndexType(): this is IndexType;
  Object? isIndexType();
}

/// interface FreshableType extends Type
abstract class FreshableType {
  /// freshType: FreshableType
  FreshableType get freshType;
  /// regularType: FreshableType
  FreshableType get regularType;
}

/// interface LiteralType extends FreshableType
abstract class LiteralType {
  /// value: string | number | PseudoBigInt
  Object? get value;
}

/// interface UniqueESSymbolType extends Type
abstract class UniqueESSymbolType {
  /// symbol: Symbol
  Symbol get symbol;
  /// escapedName: __String
  __String get escapedName;
}

/// interface StringLiteralType extends LiteralType
abstract class StringLiteralType {
  /// value: string
  String get value;
}

/// interface NumberLiteralType extends LiteralType
abstract class NumberLiteralType {
  /// value: number
  num get value;
}

/// interface BigIntLiteralType extends LiteralType
abstract class BigIntLiteralType {
  /// value: PseudoBigInt
  PseudoBigInt get value;
}

/// interface EnumType extends FreshableType
abstract class EnumType {
}

/// interface ObjectType extends Type
abstract class ObjectType {
  /// objectFlags: ObjectFlags
  ObjectFlags get objectFlags;
}

/// interface InterfaceType extends ObjectType
abstract class InterfaceType {
  /// typeParameters: TypeParameter[] | undefined
  List<TypeParameter>? get typeParameters;
  /// outerTypeParameters: TypeParameter[] | undefined
  List<TypeParameter>? get outerTypeParameters;
  /// localTypeParameters: TypeParameter[] | undefined
  List<TypeParameter>? get localTypeParameters;
  /// thisType: TypeParameter | undefined
  TypeParameter? get thisType;
}

/// interface InterfaceTypeWithDeclaredMembers extends InterfaceType
abstract class InterfaceTypeWithDeclaredMembers {
  /// declaredProperties: Symbol[]
  List<Symbol> get declaredProperties;
  /// declaredCallSignatures: Signature[]
  List<Signature> get declaredCallSignatures;
  /// declaredConstructSignatures: Signature[]
  List<Signature> get declaredConstructSignatures;
  /// declaredIndexInfos: IndexInfo[]
  List<IndexInfo> get declaredIndexInfos;
}

/// interface TypeReference extends ObjectType
abstract class TypeReference {
  /// target: GenericType
  GenericType get target;
  /// optional node: TypeReferenceNode | ArrayTypeNode | TupleTypeNode
  Object? get node;
  /// optional typeArguments: readonly Type[]
  List<Type>? get typeArguments;
}

/// interface DeferredTypeReference extends TypeReference
abstract class DeferredTypeReference {
}

/// interface GenericType extends InterfaceType, TypeReference
abstract class GenericType {
}

/// interface TupleType extends GenericType
abstract class TupleType {
  /// elementFlags: readonly ElementFlags[]
  List<ElementFlags> get elementFlags;
  /// minLength: number
  num get minLength;
  /// fixedLength: number
  num get fixedLength;
  /// hasRestElement: boolean
  bool get hasRestElement;
  /// combinedFlags: ElementFlags
  ElementFlags get combinedFlags;
  /// readonly: boolean
  bool get readonly;
  /// optional labeledElementDeclarations: readonly (NamedTupleMember | ParameterDeclaration | undefined)[]
  List<Object?>? get labeledElementDeclarations;
}

/// interface TupleTypeReference extends TypeReference
abstract class TupleTypeReference {
  /// target: TupleType
  TupleType get target;
}

/// interface UnionOrIntersectionType extends Type
abstract class UnionOrIntersectionType {
  /// types: Type[]
  List<Type> get types;
}

/// interface UnionType extends UnionOrIntersectionType
abstract class UnionType {
}

/// interface IntersectionType extends UnionOrIntersectionType
abstract class IntersectionType {
}

/// interface EvolvingArrayType extends ObjectType
abstract class EvolvingArrayType {
  /// elementType: Type
  Type get elementType;
  /// optional finalArrayType: Type
  Type? get finalArrayType;
}

/// interface InstantiableType extends Type
abstract class InstantiableType {
}

/// interface TypeParameter extends InstantiableType
abstract class TypeParameter {
}

/// interface IndexedAccessType extends InstantiableType
abstract class IndexedAccessType {
  /// objectType: Type
  Type get objectType;
  /// indexType: Type
  Type get indexType;
  /// optional constraint: Type
  Type? get constraint;
  /// optional simplifiedForReading: Type
  Type? get simplifiedForReading;
  /// optional simplifiedForWriting: Type
  Type? get simplifiedForWriting;
}

/// interface IndexType extends InstantiableType
abstract class IndexType {
  /// type: InstantiableType | UnionOrIntersectionType
  Object? get type;
}

/// interface ConditionalRoot
abstract class ConditionalRoot {
  /// node: ConditionalTypeNode
  ConditionalTypeNode get node;
  /// checkType: Type
  Type get checkType;
  /// extendsType: Type
  Type get extendsType;
  /// isDistributive: boolean
  bool get isDistributive;
  /// optional inferTypeParameters: TypeParameter[]
  List<TypeParameter>? get inferTypeParameters;
  /// optional outerTypeParameters: TypeParameter[]
  List<TypeParameter>? get outerTypeParameters;
  /// optional instantiations: Map<string, Type>
  Map<String, Type>? get instantiations;
  /// optional aliasSymbol: Symbol
  Symbol? get aliasSymbol;
  /// optional aliasTypeArguments: Type[]
  List<Type>? get aliasTypeArguments;
}

/// interface ConditionalType extends InstantiableType
abstract class ConditionalType {
  /// root: ConditionalRoot
  ConditionalRoot get root;
  /// checkType: Type
  Type get checkType;
  /// extendsType: Type
  Type get extendsType;
  /// optional resolvedTrueType: Type
  Type? get resolvedTrueType;
  /// optional resolvedFalseType: Type
  Type? get resolvedFalseType;
}

/// interface TemplateLiteralType extends InstantiableType
abstract class TemplateLiteralType {
  /// texts: readonly string[]
  List<String> get texts;
  /// types: readonly Type[]
  List<Type> get types;
}

/// interface StringMappingType extends InstantiableType
abstract class StringMappingType {
  /// symbol: Symbol
  Symbol get symbol;
  /// type: Type
  Type get type;
}

/// interface SubstitutionType extends InstantiableType
abstract class SubstitutionType {
  /// objectFlags: ObjectFlags
  ObjectFlags get objectFlags;
  /// baseType: Type
  Type get baseType;
  /// constraint: Type
  Type get constraint;
}

/// interface Signature
abstract class Signature {
  /// optional declaration: SignatureDeclaration | JSDocSignature
  Object? get declaration;
  /// optional typeParameters: readonly TypeParameter[]
  List<TypeParameter>? get typeParameters;
  /// parameters: readonly Symbol[]
  List<Symbol> get parameters;
  /// optional thisParameter: Symbol
  Symbol? get thisParameter;
  /// getDeclaration(): SignatureDeclaration;
  SignatureDeclaration getDeclaration();
  /// getTypeParameters(): TypeParameter[] | undefined;
  List<TypeParameter>? getTypeParameters();
  /// getParameters(): Symbol[];
  List<Symbol> getParameters();
  /// getTypeParameterAtPosition(pos: number): Type;
  Type getTypeParameterAtPosition(num pos);
  /// getReturnType(): Type;
  Type getReturnType();
  /// getDocumentationComment(typeChecker: TypeChecker | undefined): SymbolDisplayPart[];
  List<SymbolDisplayPart> getDocumentationComment(TypeChecker? typeChecker);
  /// getJsDocTags(): JSDocTagInfo[];
  List<JSDocTagInfo> getJsDocTags();
}

/// interface IndexInfo
abstract class IndexInfo {
  /// keyType: Type
  Type get keyType;
  /// type: Type
  Type get type;
  /// isReadonly: boolean
  bool get isReadonly;
  /// optional declaration: IndexSignatureDeclaration
  IndexSignatureDeclaration? get declaration;
  /// optional components: ElementWithComputedPropertyName[]
  List<ElementWithComputedPropertyName>? get components;
}

/// interface FileExtensionInfo
abstract class FileExtensionInfo {
  /// extension: string
  String get extension;
  /// isMixedContent: boolean
  bool get isMixedContent;
  /// optional scriptKind: ScriptKind
  ScriptKind? get scriptKind;
}

/// interface DiagnosticMessage
abstract class DiagnosticMessage {
  /// key: string
  String get key;
  /// category: DiagnosticCategory
  DiagnosticCategory get category;
  /// code: number
  num get code;
  /// message: string
  String get message;
  /// optional reportsUnnecessary: {}
  Map<String, Object?>? get reportsUnnecessary;
  /// optional reportsDeprecated: {}
  Map<String, Object?>? get reportsDeprecated;
}

/// interface DiagnosticMessageChain
abstract class DiagnosticMessageChain {
  /// messageText: string
  String get messageText;
  /// category: DiagnosticCategory
  DiagnosticCategory get category;
  /// code: number
  num get code;
  /// optional next: DiagnosticMessageChain[]
  List<DiagnosticMessageChain>? get next;
}

/// interface Diagnostic extends DiagnosticRelatedInformation
abstract class Diagnostic {
  /// optional reportsUnnecessary: {}
  Map<String, Object?>? get reportsUnnecessary;
  /// optional reportsDeprecated: {}
  Map<String, Object?>? get reportsDeprecated;
  /// optional source: string
  String? get source;
  /// optional relatedInformation: DiagnosticRelatedInformation[]
  List<DiagnosticRelatedInformation>? get relatedInformation;
}

/// interface DiagnosticRelatedInformation
abstract class DiagnosticRelatedInformation {
  /// category: DiagnosticCategory
  DiagnosticCategory get category;
  /// code: number
  num get code;
  /// file: SourceFile | undefined
  SourceFile? get file;
  /// start: number | undefined
  num? get start;
  /// length: number | undefined
  num? get length;
  /// messageText: string | DiagnosticMessageChain
  Object? get messageText;
}

/// interface DiagnosticWithLocation extends Diagnostic
abstract class DiagnosticWithLocation {
  /// file: SourceFile
  SourceFile get file;
  /// start: number
  num get start;
  /// length: number
  num get length;
}

/// interface PluginImport
abstract class PluginImport {
  /// name: string
  String get name;
}

/// interface ProjectReference
abstract class ProjectReference {
  /// path: string
  String get path;
  /// optional originalPath: string
  String? get originalPath;
  /// optional prepend: boolean
  bool? get prepend;
  /// optional circular: boolean
  bool? get circular;
}

/// interface CompilerOptions
abstract class CompilerOptions {
  /// optional allowImportingTsExtensions: boolean
  bool? get allowImportingTsExtensions;
  /// optional allowJs: boolean
  bool? get allowJs;
  /// optional allowArbitraryExtensions: boolean
  bool? get allowArbitraryExtensions;
  /// optional allowSyntheticDefaultImports: boolean
  bool? get allowSyntheticDefaultImports;
  /// optional allowUmdGlobalAccess: boolean
  bool? get allowUmdGlobalAccess;
  /// optional allowUnreachableCode: boolean
  bool? get allowUnreachableCode;
  /// optional allowUnusedLabels: boolean
  bool? get allowUnusedLabels;
  /// optional alwaysStrict: boolean
  bool? get alwaysStrict;
  /// optional baseUrl: string
  String? get baseUrl;
  /// optional charset: string
  String? get charset;
  /// optional checkJs: boolean
  bool? get checkJs;
  /// optional customConditions: string[]
  List<String>? get customConditions;
  /// optional declaration: boolean
  bool? get declaration;
  /// optional declarationMap: boolean
  bool? get declarationMap;
  /// optional emitDeclarationOnly: boolean
  bool? get emitDeclarationOnly;
  /// optional declarationDir: string
  String? get declarationDir;
  /// optional disableSizeLimit: boolean
  bool? get disableSizeLimit;
  /// optional disableSourceOfProjectReferenceRedirect: boolean
  bool? get disableSourceOfProjectReferenceRedirect;
  /// optional disableSolutionSearching: boolean
  bool? get disableSolutionSearching;
  /// optional disableReferencedProjectLoad: boolean
  bool? get disableReferencedProjectLoad;
  /// optional downlevelIteration: boolean
  bool? get downlevelIteration;
  /// optional emitBOM: boolean
  bool? get emitBOM;
  /// optional emitDecoratorMetadata: boolean
  bool? get emitDecoratorMetadata;
  /// optional exactOptionalPropertyTypes: boolean
  bool? get exactOptionalPropertyTypes;
  /// optional experimentalDecorators: boolean
  bool? get experimentalDecorators;
  /// optional forceConsistentCasingInFileNames: boolean
  bool? get forceConsistentCasingInFileNames;
  /// optional ignoreDeprecations: string
  String? get ignoreDeprecations;
  /// optional importHelpers: boolean
  bool? get importHelpers;
  /// optional importsNotUsedAsValues: ImportsNotUsedAsValues
  ImportsNotUsedAsValues? get importsNotUsedAsValues;
  /// optional inlineSourceMap: boolean
  bool? get inlineSourceMap;
  /// optional inlineSources: boolean
  bool? get inlineSources;
  /// optional isolatedModules: boolean
  bool? get isolatedModules;
  /// optional isolatedDeclarations: boolean
  bool? get isolatedDeclarations;
  /// optional jsx: JsxEmit
  JsxEmit? get jsx;
  /// optional keyofStringsOnly: boolean
  bool? get keyofStringsOnly;
  /// optional lib: string[]
  List<String>? get lib;
  /// optional libReplacement: boolean
  bool? get libReplacement;
  /// optional locale: string
  String? get locale;
  /// optional mapRoot: string
  String? get mapRoot;
  /// optional maxNodeModuleJsDepth: number
  num? get maxNodeModuleJsDepth;
  /// optional module: ModuleKind
  ModuleKind? get module;
  /// optional moduleResolution: ModuleResolutionKind
  ModuleResolutionKind? get moduleResolution;
  /// optional moduleSuffixes: string[]
  List<String>? get moduleSuffixes;
  /// optional moduleDetection: ModuleDetectionKind
  ModuleDetectionKind? get moduleDetection;
  /// optional newLine: NewLineKind
  NewLineKind? get newLine;
  /// optional noEmit: boolean
  bool? get noEmit;
  /// optional noCheck: boolean
  bool? get noCheck;
  /// optional noEmitHelpers: boolean
  bool? get noEmitHelpers;
  /// optional noEmitOnError: boolean
  bool? get noEmitOnError;
  /// optional noErrorTruncation: boolean
  bool? get noErrorTruncation;
  /// optional noFallthroughCasesInSwitch: boolean
  bool? get noFallthroughCasesInSwitch;
  /// optional noImplicitAny: boolean
  bool? get noImplicitAny;
  /// optional noImplicitReturns: boolean
  bool? get noImplicitReturns;
  /// optional noImplicitThis: boolean
  bool? get noImplicitThis;
  /// optional noStrictGenericChecks: boolean
  bool? get noStrictGenericChecks;
  /// optional noUnusedLocals: boolean
  bool? get noUnusedLocals;
  /// optional noUnusedParameters: boolean
  bool? get noUnusedParameters;
  /// optional noImplicitUseStrict: boolean
  bool? get noImplicitUseStrict;
  /// optional noPropertyAccessFromIndexSignature: boolean
  bool? get noPropertyAccessFromIndexSignature;
  /// optional assumeChangesOnlyAffectDirectDependencies: boolean
  bool? get assumeChangesOnlyAffectDirectDependencies;
  /// optional noLib: boolean
  bool? get noLib;
  /// optional noResolve: boolean
  bool? get noResolve;
  /// optional noUncheckedIndexedAccess: boolean
  bool? get noUncheckedIndexedAccess;
  /// optional out: string
  String? get out;
  /// optional outDir: string
  String? get outDir;
  /// optional outFile: string
  String? get outFile;
  /// optional paths: MapLike<string[]>
  MapLike<List<String>>? get paths;
  /// optional preserveConstEnums: boolean
  bool? get preserveConstEnums;
  /// optional noImplicitOverride: boolean
  bool? get noImplicitOverride;
  /// optional preserveSymlinks: boolean
  bool? get preserveSymlinks;
  /// optional preserveValueImports: boolean
  bool? get preserveValueImports;
  /// optional project: string
  String? get project;
  /// optional reactNamespace: string
  String? get reactNamespace;
  /// optional jsxFactory: string
  String? get jsxFactory;
  /// optional jsxFragmentFactory: string
  String? get jsxFragmentFactory;
  /// optional jsxImportSource: string
  String? get jsxImportSource;
  /// optional composite: boolean
  bool? get composite;
  /// optional incremental: boolean
  bool? get incremental;
  /// optional tsBuildInfoFile: string
  String? get tsBuildInfoFile;
  /// optional removeComments: boolean
  bool? get removeComments;
  /// optional resolvePackageJsonExports: boolean
  bool? get resolvePackageJsonExports;
  /// optional resolvePackageJsonImports: boolean
  bool? get resolvePackageJsonImports;
  /// optional rewriteRelativeImportExtensions: boolean
  bool? get rewriteRelativeImportExtensions;
  /// optional rootDir: string
  String? get rootDir;
  /// optional rootDirs: string[]
  List<String>? get rootDirs;
  /// optional skipLibCheck: boolean
  bool? get skipLibCheck;
  /// optional skipDefaultLibCheck: boolean
  bool? get skipDefaultLibCheck;
  /// optional sourceMap: boolean
  bool? get sourceMap;
  /// optional sourceRoot: string
  String? get sourceRoot;
  /// optional strict: boolean
  bool? get strict;
  /// optional strictFunctionTypes: boolean
  bool? get strictFunctionTypes;
  /// optional strictBindCallApply: boolean
  bool? get strictBindCallApply;
  /// optional strictNullChecks: boolean
  bool? get strictNullChecks;
  /// optional strictPropertyInitialization: boolean
  bool? get strictPropertyInitialization;
  /// optional strictBuiltinIteratorReturn: boolean
  bool? get strictBuiltinIteratorReturn;
  /// optional stripInternal: boolean
  bool? get stripInternal;
  /// optional suppressExcessPropertyErrors: boolean
  bool? get suppressExcessPropertyErrors;
  /// optional suppressImplicitAnyIndexErrors: boolean
  bool? get suppressImplicitAnyIndexErrors;
  /// optional target: ScriptTarget
  ScriptTarget? get target;
  /// optional traceResolution: boolean
  bool? get traceResolution;
  /// optional useUnknownInCatchVariables: boolean
  bool? get useUnknownInCatchVariables;
  /// optional noUncheckedSideEffectImports: boolean
  bool? get noUncheckedSideEffectImports;
  /// optional resolveJsonModule: boolean
  bool? get resolveJsonModule;
  /// optional types: string[]
  List<String>? get types;
  /// optional typeRoots: string[]
  List<String>? get typeRoots;
  /// optional verbatimModuleSyntax: boolean
  bool? get verbatimModuleSyntax;
  /// optional erasableSyntaxOnly: boolean
  bool? get erasableSyntaxOnly;
  /// optional esModuleInterop: boolean
  bool? get esModuleInterop;
  /// optional useDefineForClassFields: boolean
  bool? get useDefineForClassFields;
  /// index signature: CompilerOptionsValue | TsConfigSourceFile | undefined
}

/// interface WatchOptions
abstract class WatchOptions {
  /// optional watchFile: WatchFileKind
  WatchFileKind? get watchFile;
  /// optional watchDirectory: WatchDirectoryKind
  WatchDirectoryKind? get watchDirectory;
  /// optional fallbackPolling: PollingWatchKind
  PollingWatchKind? get fallbackPolling;
  /// optional synchronousWatchDirectory: boolean
  bool? get synchronousWatchDirectory;
  /// optional excludeDirectories: string[]
  List<String>? get excludeDirectories;
  /// optional excludeFiles: string[]
  List<String>? get excludeFiles;
  /// index signature: CompilerOptionsValue | undefined
}

/// interface TypeAcquisition
abstract class TypeAcquisition {
  /// optional enable: boolean
  bool? get enable;
  /// optional include: string[]
  List<String>? get include;
  /// optional exclude: string[]
  List<String>? get exclude;
  /// optional disableFilenameBasedTypeAcquisition: boolean
  bool? get disableFilenameBasedTypeAcquisition;
  /// index signature: CompilerOptionsValue | undefined
}

/// interface LineAndCharacter
abstract class LineAndCharacter {
  /// line: number
  num get line;
  /// character: number
  num get character;
}

/// interface ParsedCommandLine
abstract class ParsedCommandLine {
  /// options: CompilerOptions
  CompilerOptions get options;
  /// optional typeAcquisition: TypeAcquisition
  TypeAcquisition? get typeAcquisition;
  /// fileNames: string[]
  List<String> get fileNames;
  /// optional projectReferences: readonly ProjectReference[]
  List<ProjectReference>? get projectReferences;
  /// optional watchOptions: WatchOptions
  WatchOptions? get watchOptions;
  /// optional raw: any
  Object? get raw;
  /// errors: Diagnostic[]
  List<Diagnostic> get errors;
  /// optional wildcardDirectories: MapLike<WatchDirectoryFlags>
  MapLike<WatchDirectoryFlags>? get wildcardDirectories;
  /// optional compileOnSave: boolean
  bool? get compileOnSave;
}

/// interface CreateProgramOptions
abstract class CreateProgramOptions {
  /// rootNames: readonly string[]
  List<String> get rootNames;
  /// options: CompilerOptions
  CompilerOptions get options;
  /// optional projectReferences: readonly ProjectReference[]
  List<ProjectReference>? get projectReferences;
  /// optional host: CompilerHost
  CompilerHost? get host;
  /// optional oldProgram: Program
  Program? get oldProgram;
  /// optional configFileParsingDiagnostics: readonly Diagnostic[]
  List<Diagnostic>? get configFileParsingDiagnostics;
}

/// interface ModuleResolutionHost
abstract class ModuleResolutionHost {
  /// fileExists(fileName: string): boolean;
  bool fileExists(String fileName);
  /// readFile(fileName: string): string | undefined;
  String? readFile(String fileName);
  /// trace?(s: string): void;
  void trace(String s);
  /// directoryExists?(directoryName: string): boolean;
  bool directoryExists(String directoryName);
  /// realpath?(path: string): string;
  String realpath(String path);
  /// getCurrentDirectory?(): string;
  String getCurrentDirectory();
  /// getDirectories?(path: string): string[];
  List<String> getDirectories(String path);
  /// optional useCaseSensitiveFileNames: boolean | (() => boolean) | undefined
  Object? get useCaseSensitiveFileNames;
}

/// interface MinimalResolutionCacheHost extends ModuleResolutionHost
abstract class MinimalResolutionCacheHost {
  /// getCompilationSettings(): CompilerOptions;
  CompilerOptions getCompilationSettings();
  /// getCompilerHost?(): CompilerHost | undefined;
  CompilerHost? getCompilerHost();
}

/// interface ResolvedModule
abstract class ResolvedModule {
  /// resolvedFileName: string
  String get resolvedFileName;
  /// optional isExternalLibraryImport: boolean
  bool? get isExternalLibraryImport;
  /// optional resolvedUsingTsExtension: boolean
  bool? get resolvedUsingTsExtension;
}

/// interface ResolvedModuleFull extends ResolvedModule
abstract class ResolvedModuleFull {
  /// extension: string
  String get extension;
  /// optional packageId: PackageId
  PackageId? get packageId;
}

/// interface PackageId
abstract class PackageId {
  /// name: string
  String get name;
  /// subModuleName: string
  String get subModuleName;
  /// version: string
  String get version;
}

/// interface ResolvedModuleWithFailedLookupLocations
abstract class ResolvedModuleWithFailedLookupLocations {
  /// resolvedModule: ResolvedModuleFull | undefined
  ResolvedModuleFull? get resolvedModule;
}

/// interface ResolvedTypeReferenceDirective
abstract class ResolvedTypeReferenceDirective {
  /// primary: boolean
  bool get primary;
  /// resolvedFileName: string | undefined
  String? get resolvedFileName;
  /// optional packageId: PackageId
  PackageId? get packageId;
  /// optional isExternalLibraryImport: boolean
  bool? get isExternalLibraryImport;
}

/// interface ResolvedTypeReferenceDirectiveWithFailedLookupLocations
abstract class ResolvedTypeReferenceDirectiveWithFailedLookupLocations {
  /// resolvedTypeReferenceDirective: ResolvedTypeReferenceDirective | undefined
  ResolvedTypeReferenceDirective? get resolvedTypeReferenceDirective;
}

/// interface CompilerHost extends ModuleResolutionHost
abstract class CompilerHost {
  /// getSourceFile(fileName: string, languageVersionOrOptions: ScriptTarget | CreateSourceFileOptions, onError?: (message: string) => void, shouldCreateNewSourceFile?: boolean): SourceFile | undefined;
  SourceFile? getSourceFile(String fileName, Object? languageVersionOrOptions, [Object? Function(Object?)? onError, bool? shouldCreateNewSourceFile]);
  /// getSourceFileByPath?(fileName: string, path: Path, languageVersionOrOptions: ScriptTarget | CreateSourceFileOptions, onError?: (message: string) => void, shouldCreateNewSourceFile?: boolean): SourceFile | undefined;
  SourceFile? getSourceFileByPath(String fileName, Path path, Object? languageVersionOrOptions, [Object? Function(Object?)? onError, bool? shouldCreateNewSourceFile]);
  /// getCancellationToken?(): CancellationToken;
  CancellationToken getCancellationToken();
  /// getDefaultLibFileName(options: CompilerOptions): string;
  String getDefaultLibFileName(CompilerOptions options);
  /// getDefaultLibLocation?(): string;
  String getDefaultLibLocation();
  /// writeFile: WriteFileCallback
  WriteFileCallback get writeFile;
  /// getCurrentDirectory(): string;
  String getCurrentDirectory();
  /// getCanonicalFileName(fileName: string): string;
  String getCanonicalFileName(String fileName);
  /// useCaseSensitiveFileNames(): boolean;
  bool useCaseSensitiveFileNames();
  /// getNewLine(): string;
  String getNewLine();
  /// readDirectory?(rootDir: string, extensions: readonly string[], excludes: readonly string[] | undefined, includes: readonly string[], depth?: number): string[];
  List<String> readDirectory(String rootDir, List<String> extensions, List<String>? excludes, List<String> includes, [num? depth]);
  /// resolveModuleNames?(moduleNames: string[], containingFile: string, reusedNames: string[] | undefined, redirectedReference: ResolvedProjectReference | undefined, options: CompilerOptions, containingSourceFile?: SourceFile): (ResolvedModule | undefined)[];
  List<ResolvedModule?> resolveModuleNames(List<String> moduleNames, String containingFile, List<String>? reusedNames, ResolvedProjectReference? redirectedReference, CompilerOptions options, [SourceFile? containingSourceFile]);
  /// getModuleResolutionCache?(): ModuleResolutionCache | undefined;
  ModuleResolutionCache? getModuleResolutionCache();
  /// resolveTypeReferenceDirectives?(typeReferenceDirectiveNames: string[] | readonly FileReference[], containingFile: string, redirectedReference: ResolvedProjectReference | undefined, options: CompilerOptions, containingFileMode?: ResolutionMode): (ResolvedTypeReferenceDirective | undefined)[];
  List<ResolvedTypeReferenceDirective?> resolveTypeReferenceDirectives(Object? typeReferenceDirectiveNames, String containingFile, ResolvedProjectReference? redirectedReference, CompilerOptions options, [ResolutionMode? containingFileMode]);
  /// resolveModuleNameLiterals?(moduleLiterals: readonly StringLiteralLike[], containingFile: string, redirectedReference: ResolvedProjectReference | undefined, options: CompilerOptions, containingSourceFile: SourceFile, reusedNames: readonly StringLiteralLike[] | undefined): readonly ResolvedModuleWithFailedLookupLocations[];
  List<ResolvedModuleWithFailedLookupLocations> resolveModuleNameLiterals(List<StringLiteralLike> moduleLiterals, String containingFile, ResolvedProjectReference? redirectedReference, CompilerOptions options, SourceFile containingSourceFile, List<StringLiteralLike>? reusedNames);
  /// resolveTypeReferenceDirectiveReferences?<T extends FileReference | string>(typeDirectiveReferences: readonly T[], containingFile: string, redirectedReference: ResolvedProjectReference | undefined, options: CompilerOptions, containingSourceFile: SourceFile | undefined, reusedNames: readonly T[] | undefined): readonly ResolvedTypeReferenceDirectiveWithFailedLookupLocations[];
  List<ResolvedTypeReferenceDirectiveWithFailedLookupLocations> resolveTypeReferenceDirectiveReferences<T>(List<T> typeDirectiveReferences, String containingFile, ResolvedProjectReference? redirectedReference, CompilerOptions options, SourceFile? containingSourceFile, List<T>? reusedNames);
  /// getEnvironmentVariable?(name: string): string | undefined;
  String? getEnvironmentVariable(String name);
  /// hasInvalidatedResolutions?(filePath: Path): boolean;
  bool hasInvalidatedResolutions(Path filePath);
  /// createHash?(data: string): string;
  String createHash(String data);
  /// getParsedCommandLine?(fileName: string): ParsedCommandLine | undefined;
  ParsedCommandLine? getParsedCommandLine(String fileName);
  /// optional jsDocParsingMode: JSDocParsingMode
  JSDocParsingMode? get jsDocParsingMode;
}

/// interface SourceMapRange extends TextRange
abstract class SourceMapRange {
  /// optional source: SourceMapSource
  SourceMapSource? get source;
}

/// interface SourceMapSource
abstract class SourceMapSource {
  /// fileName: string
  String get fileName;
  /// text: string
  String get text;
  /// optional skipTrivia: (pos: number) => number
  Object? Function(Object?)? get skipTrivia;
  /// getLineAndCharacterOfPosition(pos: number): LineAndCharacter;
  LineAndCharacter getLineAndCharacterOfPosition(num pos);
}

/// interface EmitHelperBase
abstract class EmitHelperBase {
  /// name: string
  String get name;
  /// scoped: boolean
  bool get scoped;
  /// text: string | ((node: EmitHelperUniqueNameCallback) => string)
  Object? get text;
  /// optional priority: number
  num? get priority;
  /// optional dependencies: EmitHelper[]
  List<EmitHelper>? get dependencies;
}

/// interface ScopedEmitHelper extends EmitHelperBase
abstract class ScopedEmitHelper {
  /// scoped: true
  bool get scoped;
}

/// interface UnscopedEmitHelper extends EmitHelperBase
abstract class UnscopedEmitHelper {
  /// scoped: false
  bool get scoped;
  /// text: string
  String get text;
}

/// interface NodeFactory
abstract class NodeFactory {
  /// createNodeArray<T extends Node>(elements?: readonly T[], hasTrailingComma?: boolean): NodeArray<T>;
  NodeArray<T> createNodeArray<T>([List<T>? elements, bool? hasTrailingComma]);
  /// createNumericLiteral(value: string | number, numericLiteralFlags?: TokenFlags): NumericLiteral;
  NumericLiteral createNumericLiteral(Object? value, [TokenFlags? numericLiteralFlags]);
  /// createBigIntLiteral(value: string | PseudoBigInt): BigIntLiteral;
  BigIntLiteral createBigIntLiteral(Object? value);
  /// createStringLiteral(text: string, isSingleQuote?: boolean): StringLiteral;
  StringLiteral createStringLiteral(String text, [bool? isSingleQuote]);
  /// createStringLiteralFromNode(sourceNode: PropertyNameLiteral | PrivateIdentifier, isSingleQuote?: boolean): StringLiteral;
  StringLiteral createStringLiteralFromNode(Object? sourceNode, [bool? isSingleQuote]);
  /// createRegularExpressionLiteral(text: string): RegularExpressionLiteral;
  RegularExpressionLiteral createRegularExpressionLiteral(String text);
  /// createIdentifier(text: string): Identifier;
  Identifier createIdentifier(String text);
  /// createTempVariable(recordTempVariable: ((node: Identifier) => void) | undefined, reservedInNestedScopes?: boolean): Identifier;
  Identifier createTempVariable(Object? Function(Object?)? recordTempVariable, [bool? reservedInNestedScopes]);
  /// createLoopVariable(reservedInNestedScopes?: boolean): Identifier;
  Identifier createLoopVariable([bool? reservedInNestedScopes]);
  /// createUniqueName(text: string, flags?: GeneratedIdentifierFlags): Identifier;
  Identifier createUniqueName(String text, [GeneratedIdentifierFlags? flags]);
  /// getGeneratedNameForNode(node: Node | undefined, flags?: GeneratedIdentifierFlags): Identifier;
  Identifier getGeneratedNameForNode(Node? node, [GeneratedIdentifierFlags? flags]);
  /// createPrivateIdentifier(text: string): PrivateIdentifier;
  PrivateIdentifier createPrivateIdentifier(String text);
  /// createUniquePrivateName(text?: string): PrivateIdentifier;
  PrivateIdentifier createUniquePrivateName([String? text]);
  /// getGeneratedPrivateNameForNode(node: Node): PrivateIdentifier;
  PrivateIdentifier getGeneratedPrivateNameForNode(Node node);
  /// createToken(token: SyntaxKind.SuperKeyword): SuperExpression;
  SuperExpression createToken(SyntaxKind token);
  /// createToken(token: SyntaxKind.ThisKeyword): ThisExpression;
  ThisExpression createToken$1(SyntaxKind token);
  /// createToken(token: SyntaxKind.NullKeyword): NullLiteral;
  NullLiteral createToken$2(SyntaxKind token);
  /// createToken(token: SyntaxKind.TrueKeyword): TrueLiteral;
  TrueLiteral createToken$3(SyntaxKind token);
  /// createToken(token: SyntaxKind.FalseKeyword): FalseLiteral;
  FalseLiteral createToken$4(SyntaxKind token);
  /// createToken(token: SyntaxKind.EndOfFileToken): EndOfFileToken;
  EndOfFileToken createToken$5(SyntaxKind token);
  /// createToken(token: SyntaxKind.Unknown): Token<SyntaxKind.Unknown>;
  Token<SyntaxKind> createToken$6(SyntaxKind token);
  /// createToken<TKind extends PunctuationSyntaxKind>(token: TKind): PunctuationToken<TKind>;
  PunctuationToken<TKind> createToken$7<TKind>(TKind token);
  /// createToken<TKind extends KeywordTypeSyntaxKind>(token: TKind): KeywordTypeNode<TKind>;
  KeywordTypeNode<TKind> createToken$8<TKind>(TKind token);
  /// createToken<TKind extends ModifierSyntaxKind>(token: TKind): ModifierToken<TKind>;
  ModifierToken<TKind> createToken$9<TKind>(TKind token);
  /// createToken<TKind extends KeywordSyntaxKind>(token: TKind): KeywordToken<TKind>;
  KeywordToken<TKind> createToken$10<TKind>(TKind token);
  /// createSuper(): SuperExpression;
  SuperExpression createSuper();
  /// createThis(): ThisExpression;
  ThisExpression createThis();
  /// createNull(): NullLiteral;
  NullLiteral createNull();
  /// createTrue(): TrueLiteral;
  TrueLiteral createTrue();
  /// createFalse(): FalseLiteral;
  FalseLiteral createFalse();
  /// createModifier<T extends ModifierSyntaxKind>(kind: T): ModifierToken<T>;
  ModifierToken<T> createModifier<T>(T kind);
  /// createModifiersFromModifierFlags(flags: ModifierFlags): Modifier[] | undefined;
  List<Modifier>? createModifiersFromModifierFlags(ModifierFlags flags);
  /// createQualifiedName(left: EntityName, right: string | Identifier): QualifiedName;
  QualifiedName createQualifiedName(EntityName left, Object? right);
  /// updateQualifiedName(node: QualifiedName, left: EntityName, right: Identifier): QualifiedName;
  QualifiedName updateQualifiedName(QualifiedName node, EntityName left, Identifier right);
  /// createComputedPropertyName(expression: Expression): ComputedPropertyName;
  ComputedPropertyName createComputedPropertyName(Expression expression);
  /// updateComputedPropertyName(node: ComputedPropertyName, expression: Expression): ComputedPropertyName;
  ComputedPropertyName updateComputedPropertyName(ComputedPropertyName node, Expression expression);
  /// createTypeParameterDeclaration(modifiers: readonly Modifier[] | undefined, name: string | Identifier, constraint?: TypeNode, defaultType?: TypeNode): TypeParameterDeclaration;
  TypeParameterDeclaration createTypeParameterDeclaration(List<Modifier>? modifiers, Object? name, [TypeNode? constraint, TypeNode? defaultType]);
  /// updateTypeParameterDeclaration(node: TypeParameterDeclaration, modifiers: readonly Modifier[] | undefined, name: Identifier, constraint: TypeNode | undefined, defaultType: TypeNode | undefined): TypeParameterDeclaration;
  TypeParameterDeclaration updateTypeParameterDeclaration(TypeParameterDeclaration node, List<Modifier>? modifiers, Identifier name, TypeNode? constraint, TypeNode? defaultType);
  /// createParameterDeclaration(modifiers: readonly ModifierLike[] | undefined, dotDotDotToken: DotDotDotToken | undefined, name: string | BindingName, questionToken?: QuestionToken, type?: TypeNode, initializer?: Expression): ParameterDeclaration;
  ParameterDeclaration createParameterDeclaration(List<ModifierLike>? modifiers, DotDotDotToken? dotDotDotToken, Object? name, [QuestionToken? questionToken, TypeNode? type, Expression? initializer]);
  /// updateParameterDeclaration(node: ParameterDeclaration, modifiers: readonly ModifierLike[] | undefined, dotDotDotToken: DotDotDotToken | undefined, name: string | BindingName, questionToken: QuestionToken | undefined, type: TypeNode | undefined, initializer: Expression | undefined): ParameterDeclaration;
  ParameterDeclaration updateParameterDeclaration(ParameterDeclaration node, List<ModifierLike>? modifiers, DotDotDotToken? dotDotDotToken, Object? name, QuestionToken? questionToken, TypeNode? type, Expression? initializer);
  /// createDecorator(expression: Expression): Decorator;
  Decorator createDecorator(Expression expression);
  /// updateDecorator(node: Decorator, expression: Expression): Decorator;
  Decorator updateDecorator(Decorator node, Expression expression);
  /// createPropertySignature(modifiers: readonly Modifier[] | undefined, name: PropertyName | string, questionToken: QuestionToken | undefined, type: TypeNode | undefined): PropertySignature;
  PropertySignature createPropertySignature(List<Modifier>? modifiers, Object? name, QuestionToken? questionToken, TypeNode? type);
  /// updatePropertySignature(node: PropertySignature, modifiers: readonly Modifier[] | undefined, name: PropertyName, questionToken: QuestionToken | undefined, type: TypeNode | undefined): PropertySignature;
  PropertySignature updatePropertySignature(PropertySignature node, List<Modifier>? modifiers, PropertyName name, QuestionToken? questionToken, TypeNode? type);
  /// createPropertyDeclaration(modifiers: readonly ModifierLike[] | undefined, name: string | PropertyName, questionOrExclamationToken: QuestionToken | ExclamationToken | undefined, type: TypeNode | undefined, initializer: Expression | undefined): PropertyDeclaration;
  PropertyDeclaration createPropertyDeclaration(List<ModifierLike>? modifiers, Object? name, Object? questionOrExclamationToken, TypeNode? type, Expression? initializer);
  /// updatePropertyDeclaration(node: PropertyDeclaration, modifiers: readonly ModifierLike[] | undefined, name: string | PropertyName, questionOrExclamationToken: QuestionToken | ExclamationToken | undefined, type: TypeNode | undefined, initializer: Expression | undefined): PropertyDeclaration;
  PropertyDeclaration updatePropertyDeclaration(PropertyDeclaration node, List<ModifierLike>? modifiers, Object? name, Object? questionOrExclamationToken, TypeNode? type, Expression? initializer);
  /// createMethodSignature(modifiers: readonly Modifier[] | undefined, name: string | PropertyName, questionToken: QuestionToken | undefined, typeParameters: readonly TypeParameterDeclaration[] | undefined, parameters: readonly ParameterDeclaration[], type: TypeNode | undefined): MethodSignature;
  MethodSignature createMethodSignature(List<Modifier>? modifiers, Object? name, QuestionToken? questionToken, List<TypeParameterDeclaration>? typeParameters, List<ParameterDeclaration> parameters, TypeNode? type);
  /// updateMethodSignature(node: MethodSignature, modifiers: readonly Modifier[] | undefined, name: PropertyName, questionToken: QuestionToken | undefined, typeParameters: NodeArray<TypeParameterDeclaration> | undefined, parameters: NodeArray<ParameterDeclaration>, type: TypeNode | undefined): MethodSignature;
  MethodSignature updateMethodSignature(MethodSignature node, List<Modifier>? modifiers, PropertyName name, QuestionToken? questionToken, NodeArray<TypeParameterDeclaration>? typeParameters, NodeArray<ParameterDeclaration> parameters, TypeNode? type);
  /// createMethodDeclaration(modifiers: readonly ModifierLike[] | undefined, asteriskToken: AsteriskToken | undefined, name: string | PropertyName, questionToken: QuestionToken | undefined, typeParameters: readonly TypeParameterDeclaration[] | undefined, parameters: readonly ParameterDeclaration[], type: TypeNode | undefined, body: Block | undefined): MethodDeclaration;
  MethodDeclaration createMethodDeclaration(List<ModifierLike>? modifiers, AsteriskToken? asteriskToken, Object? name, QuestionToken? questionToken, List<TypeParameterDeclaration>? typeParameters, List<ParameterDeclaration> parameters, TypeNode? type, Block? body);
  /// updateMethodDeclaration(node: MethodDeclaration, modifiers: readonly ModifierLike[] | undefined, asteriskToken: AsteriskToken | undefined, name: PropertyName, questionToken: QuestionToken | undefined, typeParameters: readonly TypeParameterDeclaration[] | undefined, parameters: readonly ParameterDeclaration[], type: TypeNode | undefined, body: Block | undefined): MethodDeclaration;
  MethodDeclaration updateMethodDeclaration(MethodDeclaration node, List<ModifierLike>? modifiers, AsteriskToken? asteriskToken, PropertyName name, QuestionToken? questionToken, List<TypeParameterDeclaration>? typeParameters, List<ParameterDeclaration> parameters, TypeNode? type, Block? body);
  /// createConstructorDeclaration(modifiers: readonly ModifierLike[] | undefined, parameters: readonly ParameterDeclaration[], body: Block | undefined): ConstructorDeclaration;
  ConstructorDeclaration createConstructorDeclaration(List<ModifierLike>? modifiers, List<ParameterDeclaration> parameters, Block? body);
  /// updateConstructorDeclaration(node: ConstructorDeclaration, modifiers: readonly ModifierLike[] | undefined, parameters: readonly ParameterDeclaration[], body: Block | undefined): ConstructorDeclaration;
  ConstructorDeclaration updateConstructorDeclaration(ConstructorDeclaration node, List<ModifierLike>? modifiers, List<ParameterDeclaration> parameters, Block? body);
  /// createGetAccessorDeclaration(modifiers: readonly ModifierLike[] | undefined, name: string | PropertyName, parameters: readonly ParameterDeclaration[], type: TypeNode | undefined, body: Block | undefined): GetAccessorDeclaration;
  GetAccessorDeclaration createGetAccessorDeclaration(List<ModifierLike>? modifiers, Object? name, List<ParameterDeclaration> parameters, TypeNode? type, Block? body);
  /// updateGetAccessorDeclaration(node: GetAccessorDeclaration, modifiers: readonly ModifierLike[] | undefined, name: PropertyName, parameters: readonly ParameterDeclaration[], type: TypeNode | undefined, body: Block | undefined): GetAccessorDeclaration;
  GetAccessorDeclaration updateGetAccessorDeclaration(GetAccessorDeclaration node, List<ModifierLike>? modifiers, PropertyName name, List<ParameterDeclaration> parameters, TypeNode? type, Block? body);
  /// createSetAccessorDeclaration(modifiers: readonly ModifierLike[] | undefined, name: string | PropertyName, parameters: readonly ParameterDeclaration[], body: Block | undefined): SetAccessorDeclaration;
  SetAccessorDeclaration createSetAccessorDeclaration(List<ModifierLike>? modifiers, Object? name, List<ParameterDeclaration> parameters, Block? body);
  /// updateSetAccessorDeclaration(node: SetAccessorDeclaration, modifiers: readonly ModifierLike[] | undefined, name: PropertyName, parameters: readonly ParameterDeclaration[], body: Block | undefined): SetAccessorDeclaration;
  SetAccessorDeclaration updateSetAccessorDeclaration(SetAccessorDeclaration node, List<ModifierLike>? modifiers, PropertyName name, List<ParameterDeclaration> parameters, Block? body);
  /// createCallSignature(typeParameters: readonly TypeParameterDeclaration[] | undefined, parameters: readonly ParameterDeclaration[], type: TypeNode | undefined): CallSignatureDeclaration;
  CallSignatureDeclaration createCallSignature(List<TypeParameterDeclaration>? typeParameters, List<ParameterDeclaration> parameters, TypeNode? type);
  /// updateCallSignature(node: CallSignatureDeclaration, typeParameters: NodeArray<TypeParameterDeclaration> | undefined, parameters: NodeArray<ParameterDeclaration>, type: TypeNode | undefined): CallSignatureDeclaration;
  CallSignatureDeclaration updateCallSignature(CallSignatureDeclaration node, NodeArray<TypeParameterDeclaration>? typeParameters, NodeArray<ParameterDeclaration> parameters, TypeNode? type);
  /// createConstructSignature(typeParameters: readonly TypeParameterDeclaration[] | undefined, parameters: readonly ParameterDeclaration[], type: TypeNode | undefined): ConstructSignatureDeclaration;
  ConstructSignatureDeclaration createConstructSignature(List<TypeParameterDeclaration>? typeParameters, List<ParameterDeclaration> parameters, TypeNode? type);
  /// updateConstructSignature(node: ConstructSignatureDeclaration, typeParameters: NodeArray<TypeParameterDeclaration> | undefined, parameters: NodeArray<ParameterDeclaration>, type: TypeNode | undefined): ConstructSignatureDeclaration;
  ConstructSignatureDeclaration updateConstructSignature(ConstructSignatureDeclaration node, NodeArray<TypeParameterDeclaration>? typeParameters, NodeArray<ParameterDeclaration> parameters, TypeNode? type);
  /// createIndexSignature(modifiers: readonly ModifierLike[] | undefined, parameters: readonly ParameterDeclaration[], type: TypeNode): IndexSignatureDeclaration;
  IndexSignatureDeclaration createIndexSignature(List<ModifierLike>? modifiers, List<ParameterDeclaration> parameters, TypeNode type);
  /// updateIndexSignature(node: IndexSignatureDeclaration, modifiers: readonly ModifierLike[] | undefined, parameters: readonly ParameterDeclaration[], type: TypeNode): IndexSignatureDeclaration;
  IndexSignatureDeclaration updateIndexSignature(IndexSignatureDeclaration node, List<ModifierLike>? modifiers, List<ParameterDeclaration> parameters, TypeNode type);
  /// createTemplateLiteralTypeSpan(type: TypeNode, literal: TemplateMiddle | TemplateTail): TemplateLiteralTypeSpan;
  TemplateLiteralTypeSpan createTemplateLiteralTypeSpan(TypeNode type, Object? literal);
  /// updateTemplateLiteralTypeSpan(node: TemplateLiteralTypeSpan, type: TypeNode, literal: TemplateMiddle | TemplateTail): TemplateLiteralTypeSpan;
  TemplateLiteralTypeSpan updateTemplateLiteralTypeSpan(TemplateLiteralTypeSpan node, TypeNode type, Object? literal);
  /// createClassStaticBlockDeclaration(body: Block): ClassStaticBlockDeclaration;
  ClassStaticBlockDeclaration createClassStaticBlockDeclaration(Block body);
  /// updateClassStaticBlockDeclaration(node: ClassStaticBlockDeclaration, body: Block): ClassStaticBlockDeclaration;
  ClassStaticBlockDeclaration updateClassStaticBlockDeclaration(ClassStaticBlockDeclaration node, Block body);
  /// createKeywordTypeNode<TKind extends KeywordTypeSyntaxKind>(kind: TKind): KeywordTypeNode<TKind>;
  KeywordTypeNode<TKind> createKeywordTypeNode<TKind>(TKind kind);
  /// createTypePredicateNode(assertsModifier: AssertsKeyword | undefined, parameterName: Identifier | ThisTypeNode | string, type: TypeNode | undefined): TypePredicateNode;
  TypePredicateNode createTypePredicateNode(AssertsKeyword? assertsModifier, Object? parameterName, TypeNode? type);
  /// updateTypePredicateNode(node: TypePredicateNode, assertsModifier: AssertsKeyword | undefined, parameterName: Identifier | ThisTypeNode, type: TypeNode | undefined): TypePredicateNode;
  TypePredicateNode updateTypePredicateNode(TypePredicateNode node, AssertsKeyword? assertsModifier, Object? parameterName, TypeNode? type);
  /// createTypeReferenceNode(typeName: string | EntityName, typeArguments?: readonly TypeNode[]): TypeReferenceNode;
  TypeReferenceNode createTypeReferenceNode(Object? typeName, [List<TypeNode>? typeArguments]);
  /// updateTypeReferenceNode(node: TypeReferenceNode, typeName: EntityName, typeArguments: NodeArray<TypeNode> | undefined): TypeReferenceNode;
  TypeReferenceNode updateTypeReferenceNode(TypeReferenceNode node, EntityName typeName, NodeArray<TypeNode>? typeArguments);
  /// createFunctionTypeNode(typeParameters: readonly TypeParameterDeclaration[] | undefined, parameters: readonly ParameterDeclaration[], type: TypeNode): FunctionTypeNode;
  FunctionTypeNode createFunctionTypeNode(List<TypeParameterDeclaration>? typeParameters, List<ParameterDeclaration> parameters, TypeNode type);
  /// updateFunctionTypeNode(node: FunctionTypeNode, typeParameters: NodeArray<TypeParameterDeclaration> | undefined, parameters: NodeArray<ParameterDeclaration>, type: TypeNode): FunctionTypeNode;
  FunctionTypeNode updateFunctionTypeNode(FunctionTypeNode node, NodeArray<TypeParameterDeclaration>? typeParameters, NodeArray<ParameterDeclaration> parameters, TypeNode type);
  /// createConstructorTypeNode(modifiers: readonly Modifier[] | undefined, typeParameters: readonly TypeParameterDeclaration[] | undefined, parameters: readonly ParameterDeclaration[], type: TypeNode): ConstructorTypeNode;
  ConstructorTypeNode createConstructorTypeNode(List<Modifier>? modifiers, List<TypeParameterDeclaration>? typeParameters, List<ParameterDeclaration> parameters, TypeNode type);
  /// updateConstructorTypeNode(node: ConstructorTypeNode, modifiers: readonly Modifier[] | undefined, typeParameters: NodeArray<TypeParameterDeclaration> | undefined, parameters: NodeArray<ParameterDeclaration>, type: TypeNode): ConstructorTypeNode;
  ConstructorTypeNode updateConstructorTypeNode(ConstructorTypeNode node, List<Modifier>? modifiers, NodeArray<TypeParameterDeclaration>? typeParameters, NodeArray<ParameterDeclaration> parameters, TypeNode type);
  /// createTypeQueryNode(exprName: EntityName, typeArguments?: readonly TypeNode[]): TypeQueryNode;
  TypeQueryNode createTypeQueryNode(EntityName exprName, [List<TypeNode>? typeArguments]);
  /// updateTypeQueryNode(node: TypeQueryNode, exprName: EntityName, typeArguments?: readonly TypeNode[]): TypeQueryNode;
  TypeQueryNode updateTypeQueryNode(TypeQueryNode node, EntityName exprName, [List<TypeNode>? typeArguments]);
  /// createTypeLiteralNode(members: readonly TypeElement[] | undefined): TypeLiteralNode;
  TypeLiteralNode createTypeLiteralNode(List<TypeElement>? members);
  /// updateTypeLiteralNode(node: TypeLiteralNode, members: NodeArray<TypeElement>): TypeLiteralNode;
  TypeLiteralNode updateTypeLiteralNode(TypeLiteralNode node, NodeArray<TypeElement> members);
  /// createArrayTypeNode(elementType: TypeNode): ArrayTypeNode;
  ArrayTypeNode createArrayTypeNode(TypeNode elementType);
  /// updateArrayTypeNode(node: ArrayTypeNode, elementType: TypeNode): ArrayTypeNode;
  ArrayTypeNode updateArrayTypeNode(ArrayTypeNode node, TypeNode elementType);
  /// createTupleTypeNode(elements: readonly (TypeNode | NamedTupleMember)[]): TupleTypeNode;
  TupleTypeNode createTupleTypeNode(List<Object?> elements);
  /// updateTupleTypeNode(node: TupleTypeNode, elements: readonly (TypeNode | NamedTupleMember)[]): TupleTypeNode;
  TupleTypeNode updateTupleTypeNode(TupleTypeNode node, List<Object?> elements);
  /// createNamedTupleMember(dotDotDotToken: DotDotDotToken | undefined, name: Identifier, questionToken: QuestionToken | undefined, type: TypeNode): NamedTupleMember;
  NamedTupleMember createNamedTupleMember(DotDotDotToken? dotDotDotToken, Identifier name, QuestionToken? questionToken, TypeNode type);
  /// updateNamedTupleMember(node: NamedTupleMember, dotDotDotToken: DotDotDotToken | undefined, name: Identifier, questionToken: QuestionToken | undefined, type: TypeNode): NamedTupleMember;
  NamedTupleMember updateNamedTupleMember(NamedTupleMember node, DotDotDotToken? dotDotDotToken, Identifier name, QuestionToken? questionToken, TypeNode type);
  /// createOptionalTypeNode(type: TypeNode): OptionalTypeNode;
  OptionalTypeNode createOptionalTypeNode(TypeNode type);
  /// updateOptionalTypeNode(node: OptionalTypeNode, type: TypeNode): OptionalTypeNode;
  OptionalTypeNode updateOptionalTypeNode(OptionalTypeNode node, TypeNode type);
  /// createRestTypeNode(type: TypeNode): RestTypeNode;
  RestTypeNode createRestTypeNode(TypeNode type);
  /// updateRestTypeNode(node: RestTypeNode, type: TypeNode): RestTypeNode;
  RestTypeNode updateRestTypeNode(RestTypeNode node, TypeNode type);
  /// createUnionTypeNode(types: readonly TypeNode[]): UnionTypeNode;
  UnionTypeNode createUnionTypeNode(List<TypeNode> types);
  /// updateUnionTypeNode(node: UnionTypeNode, types: NodeArray<TypeNode>): UnionTypeNode;
  UnionTypeNode updateUnionTypeNode(UnionTypeNode node, NodeArray<TypeNode> types);
  /// createIntersectionTypeNode(types: readonly TypeNode[]): IntersectionTypeNode;
  IntersectionTypeNode createIntersectionTypeNode(List<TypeNode> types);
  /// updateIntersectionTypeNode(node: IntersectionTypeNode, types: NodeArray<TypeNode>): IntersectionTypeNode;
  IntersectionTypeNode updateIntersectionTypeNode(IntersectionTypeNode node, NodeArray<TypeNode> types);
  /// createConditionalTypeNode(checkType: TypeNode, extendsType: TypeNode, trueType: TypeNode, falseType: TypeNode): ConditionalTypeNode;
  ConditionalTypeNode createConditionalTypeNode(TypeNode checkType, TypeNode extendsType, TypeNode trueType, TypeNode falseType);
  /// updateConditionalTypeNode(node: ConditionalTypeNode, checkType: TypeNode, extendsType: TypeNode, trueType: TypeNode, falseType: TypeNode): ConditionalTypeNode;
  ConditionalTypeNode updateConditionalTypeNode(ConditionalTypeNode node, TypeNode checkType, TypeNode extendsType, TypeNode trueType, TypeNode falseType);
  /// createInferTypeNode(typeParameter: TypeParameterDeclaration): InferTypeNode;
  InferTypeNode createInferTypeNode(TypeParameterDeclaration typeParameter);
  /// updateInferTypeNode(node: InferTypeNode, typeParameter: TypeParameterDeclaration): InferTypeNode;
  InferTypeNode updateInferTypeNode(InferTypeNode node, TypeParameterDeclaration typeParameter);
  /// createImportTypeNode(argument: TypeNode, attributes?: ImportAttributes, qualifier?: EntityName, typeArguments?: readonly TypeNode[], isTypeOf?: boolean): ImportTypeNode;
  ImportTypeNode createImportTypeNode(TypeNode argument, [ImportAttributes? attributes, EntityName? qualifier, List<TypeNode>? typeArguments, bool? isTypeOf]);
  /// updateImportTypeNode(node: ImportTypeNode, argument: TypeNode, attributes: ImportAttributes | undefined, qualifier: EntityName | undefined, typeArguments: readonly TypeNode[] | undefined, isTypeOf?: boolean): ImportTypeNode;
  ImportTypeNode updateImportTypeNode(ImportTypeNode node, TypeNode argument, ImportAttributes? attributes, EntityName? qualifier, List<TypeNode>? typeArguments, [bool? isTypeOf]);
  /// createParenthesizedType(type: TypeNode): ParenthesizedTypeNode;
  ParenthesizedTypeNode createParenthesizedType(TypeNode type);
  /// updateParenthesizedType(node: ParenthesizedTypeNode, type: TypeNode): ParenthesizedTypeNode;
  ParenthesizedTypeNode updateParenthesizedType(ParenthesizedTypeNode node, TypeNode type);
  /// createThisTypeNode(): ThisTypeNode;
  ThisTypeNode createThisTypeNode();
  /// createTypeOperatorNode(operator: SyntaxKind.KeyOfKeyword | SyntaxKind.UniqueKeyword | SyntaxKind.ReadonlyKeyword, type: TypeNode): TypeOperatorNode;
  TypeOperatorNode createTypeOperatorNode(Object? operator_, TypeNode type);
  /// updateTypeOperatorNode(node: TypeOperatorNode, type: TypeNode): TypeOperatorNode;
  TypeOperatorNode updateTypeOperatorNode(TypeOperatorNode node, TypeNode type);
  /// createIndexedAccessTypeNode(objectType: TypeNode, indexType: TypeNode): IndexedAccessTypeNode;
  IndexedAccessTypeNode createIndexedAccessTypeNode(TypeNode objectType, TypeNode indexType);
  /// updateIndexedAccessTypeNode(node: IndexedAccessTypeNode, objectType: TypeNode, indexType: TypeNode): IndexedAccessTypeNode;
  IndexedAccessTypeNode updateIndexedAccessTypeNode(IndexedAccessTypeNode node, TypeNode objectType, TypeNode indexType);
  /// createMappedTypeNode(readonlyToken: ReadonlyKeyword | PlusToken | MinusToken | undefined, typeParameter: TypeParameterDeclaration, nameType: TypeNode | undefined, questionToken: QuestionToken | PlusToken | MinusToken | undefined, type: TypeNode | undefined, members: NodeArray<TypeElement> | undefined): MappedTypeNode;
  MappedTypeNode createMappedTypeNode(Object? readonlyToken, TypeParameterDeclaration typeParameter, TypeNode? nameType, Object? questionToken, TypeNode? type, NodeArray<TypeElement>? members);
  /// updateMappedTypeNode(node: MappedTypeNode, readonlyToken: ReadonlyKeyword | PlusToken | MinusToken | undefined, typeParameter: TypeParameterDeclaration, nameType: TypeNode | undefined, questionToken: QuestionToken | PlusToken | MinusToken | undefined, type: TypeNode | undefined, members: NodeArray<TypeElement> | undefined): MappedTypeNode;
  MappedTypeNode updateMappedTypeNode(MappedTypeNode node, Object? readonlyToken, TypeParameterDeclaration typeParameter, TypeNode? nameType, Object? questionToken, TypeNode? type, NodeArray<TypeElement>? members);
  /// createLiteralTypeNode(literal: LiteralTypeNode["literal"]): LiteralTypeNode;
  LiteralTypeNode createLiteralTypeNode(Object? literal);
  /// updateLiteralTypeNode(node: LiteralTypeNode, literal: LiteralTypeNode["literal"]): LiteralTypeNode;
  LiteralTypeNode updateLiteralTypeNode(LiteralTypeNode node, Object? literal);
  /// createTemplateLiteralType(head: TemplateHead, templateSpans: readonly TemplateLiteralTypeSpan[]): TemplateLiteralTypeNode;
  TemplateLiteralTypeNode createTemplateLiteralType(TemplateHead head, List<TemplateLiteralTypeSpan> templateSpans);
  /// updateTemplateLiteralType(node: TemplateLiteralTypeNode, head: TemplateHead, templateSpans: readonly TemplateLiteralTypeSpan[]): TemplateLiteralTypeNode;
  TemplateLiteralTypeNode updateTemplateLiteralType(TemplateLiteralTypeNode node, TemplateHead head, List<TemplateLiteralTypeSpan> templateSpans);
  /// createObjectBindingPattern(elements: readonly BindingElement[]): ObjectBindingPattern;
  ObjectBindingPattern createObjectBindingPattern(List<BindingElement> elements);
  /// updateObjectBindingPattern(node: ObjectBindingPattern, elements: readonly BindingElement[]): ObjectBindingPattern;
  ObjectBindingPattern updateObjectBindingPattern(ObjectBindingPattern node, List<BindingElement> elements);
  /// createArrayBindingPattern(elements: readonly ArrayBindingElement[]): ArrayBindingPattern;
  ArrayBindingPattern createArrayBindingPattern(List<ArrayBindingElement> elements);
  /// updateArrayBindingPattern(node: ArrayBindingPattern, elements: readonly ArrayBindingElement[]): ArrayBindingPattern;
  ArrayBindingPattern updateArrayBindingPattern(ArrayBindingPattern node, List<ArrayBindingElement> elements);
  /// createBindingElement(dotDotDotToken: DotDotDotToken | undefined, propertyName: string | PropertyName | undefined, name: string | BindingName, initializer?: Expression): BindingElement;
  BindingElement createBindingElement(DotDotDotToken? dotDotDotToken, Object? propertyName, Object? name, [Expression? initializer]);
  /// updateBindingElement(node: BindingElement, dotDotDotToken: DotDotDotToken | undefined, propertyName: PropertyName | undefined, name: BindingName, initializer: Expression | undefined): BindingElement;
  BindingElement updateBindingElement(BindingElement node, DotDotDotToken? dotDotDotToken, PropertyName? propertyName, BindingName name, Expression? initializer);
  /// createArrayLiteralExpression(elements?: readonly Expression[], multiLine?: boolean): ArrayLiteralExpression;
  ArrayLiteralExpression createArrayLiteralExpression([List<Expression>? elements, bool? multiLine]);
  /// updateArrayLiteralExpression(node: ArrayLiteralExpression, elements: readonly Expression[]): ArrayLiteralExpression;
  ArrayLiteralExpression updateArrayLiteralExpression(ArrayLiteralExpression node, List<Expression> elements);
  /// createObjectLiteralExpression(properties?: readonly ObjectLiteralElementLike[], multiLine?: boolean): ObjectLiteralExpression;
  ObjectLiteralExpression createObjectLiteralExpression([List<ObjectLiteralElementLike>? properties, bool? multiLine]);
  /// updateObjectLiteralExpression(node: ObjectLiteralExpression, properties: readonly ObjectLiteralElementLike[]): ObjectLiteralExpression;
  ObjectLiteralExpression updateObjectLiteralExpression(ObjectLiteralExpression node, List<ObjectLiteralElementLike> properties);
  /// createPropertyAccessExpression(expression: Expression, name: string | MemberName): PropertyAccessExpression;
  PropertyAccessExpression createPropertyAccessExpression(Expression expression, Object? name);
  /// updatePropertyAccessExpression(node: PropertyAccessExpression, expression: Expression, name: MemberName): PropertyAccessExpression;
  PropertyAccessExpression updatePropertyAccessExpression(PropertyAccessExpression node, Expression expression, MemberName name);
  /// createPropertyAccessChain(expression: Expression, questionDotToken: QuestionDotToken | undefined, name: string | MemberName): PropertyAccessChain;
  PropertyAccessChain createPropertyAccessChain(Expression expression, QuestionDotToken? questionDotToken, Object? name);
  /// updatePropertyAccessChain(node: PropertyAccessChain, expression: Expression, questionDotToken: QuestionDotToken | undefined, name: MemberName): PropertyAccessChain;
  PropertyAccessChain updatePropertyAccessChain(PropertyAccessChain node, Expression expression, QuestionDotToken? questionDotToken, MemberName name);
  /// createElementAccessExpression(expression: Expression, index: number | Expression): ElementAccessExpression;
  ElementAccessExpression createElementAccessExpression(Expression expression, Object? index);
  /// updateElementAccessExpression(node: ElementAccessExpression, expression: Expression, argumentExpression: Expression): ElementAccessExpression;
  ElementAccessExpression updateElementAccessExpression(ElementAccessExpression node, Expression expression, Expression argumentExpression);
  /// createElementAccessChain(expression: Expression, questionDotToken: QuestionDotToken | undefined, index: number | Expression): ElementAccessChain;
  ElementAccessChain createElementAccessChain(Expression expression, QuestionDotToken? questionDotToken, Object? index);
  /// updateElementAccessChain(node: ElementAccessChain, expression: Expression, questionDotToken: QuestionDotToken | undefined, argumentExpression: Expression): ElementAccessChain;
  ElementAccessChain updateElementAccessChain(ElementAccessChain node, Expression expression, QuestionDotToken? questionDotToken, Expression argumentExpression);
  /// createCallExpression(expression: Expression, typeArguments: readonly TypeNode[] | undefined, argumentsArray: readonly Expression[] | undefined): CallExpression;
  CallExpression createCallExpression(Expression expression, List<TypeNode>? typeArguments, List<Expression>? argumentsArray);
  /// updateCallExpression(node: CallExpression, expression: Expression, typeArguments: readonly TypeNode[] | undefined, argumentsArray: readonly Expression[]): CallExpression;
  CallExpression updateCallExpression(CallExpression node, Expression expression, List<TypeNode>? typeArguments, List<Expression> argumentsArray);
  /// createCallChain(expression: Expression, questionDotToken: QuestionDotToken | undefined, typeArguments: readonly TypeNode[] | undefined, argumentsArray: readonly Expression[] | undefined): CallChain;
  CallChain createCallChain(Expression expression, QuestionDotToken? questionDotToken, List<TypeNode>? typeArguments, List<Expression>? argumentsArray);
  /// updateCallChain(node: CallChain, expression: Expression, questionDotToken: QuestionDotToken | undefined, typeArguments: readonly TypeNode[] | undefined, argumentsArray: readonly Expression[]): CallChain;
  CallChain updateCallChain(CallChain node, Expression expression, QuestionDotToken? questionDotToken, List<TypeNode>? typeArguments, List<Expression> argumentsArray);
  /// createNewExpression(expression: Expression, typeArguments: readonly TypeNode[] | undefined, argumentsArray: readonly Expression[] | undefined): NewExpression;
  NewExpression createNewExpression(Expression expression, List<TypeNode>? typeArguments, List<Expression>? argumentsArray);
  /// updateNewExpression(node: NewExpression, expression: Expression, typeArguments: readonly TypeNode[] | undefined, argumentsArray: readonly Expression[] | undefined): NewExpression;
  NewExpression updateNewExpression(NewExpression node, Expression expression, List<TypeNode>? typeArguments, List<Expression>? argumentsArray);
  /// createTaggedTemplateExpression(tag: Expression, typeArguments: readonly TypeNode[] | undefined, template: TemplateLiteral): TaggedTemplateExpression;
  TaggedTemplateExpression createTaggedTemplateExpression(Expression tag, List<TypeNode>? typeArguments, TemplateLiteral template);
  /// updateTaggedTemplateExpression(node: TaggedTemplateExpression, tag: Expression, typeArguments: readonly TypeNode[] | undefined, template: TemplateLiteral): TaggedTemplateExpression;
  TaggedTemplateExpression updateTaggedTemplateExpression(TaggedTemplateExpression node, Expression tag, List<TypeNode>? typeArguments, TemplateLiteral template);
  /// createTypeAssertion(type: TypeNode, expression: Expression): TypeAssertion;
  TypeAssertion createTypeAssertion(TypeNode type, Expression expression);
  /// updateTypeAssertion(node: TypeAssertion, type: TypeNode, expression: Expression): TypeAssertion;
  TypeAssertion updateTypeAssertion(TypeAssertion node, TypeNode type, Expression expression);
  /// createParenthesizedExpression(expression: Expression): ParenthesizedExpression;
  ParenthesizedExpression createParenthesizedExpression(Expression expression);
  /// updateParenthesizedExpression(node: ParenthesizedExpression, expression: Expression): ParenthesizedExpression;
  ParenthesizedExpression updateParenthesizedExpression(ParenthesizedExpression node, Expression expression);
  /// createFunctionExpression(modifiers: readonly Modifier[] | undefined, asteriskToken: AsteriskToken | undefined, name: string | Identifier | undefined, typeParameters: readonly TypeParameterDeclaration[] | undefined, parameters: readonly ParameterDeclaration[] | undefined, type: TypeNode | undefined, body: Block): FunctionExpression;
  FunctionExpression createFunctionExpression(List<Modifier>? modifiers, AsteriskToken? asteriskToken, Object? name, List<TypeParameterDeclaration>? typeParameters, List<ParameterDeclaration>? parameters, TypeNode? type, Block body);
  /// updateFunctionExpression(node: FunctionExpression, modifiers: readonly Modifier[] | undefined, asteriskToken: AsteriskToken | undefined, name: Identifier | undefined, typeParameters: readonly TypeParameterDeclaration[] | undefined, parameters: readonly ParameterDeclaration[], type: TypeNode | undefined, body: Block): FunctionExpression;
  FunctionExpression updateFunctionExpression(FunctionExpression node, List<Modifier>? modifiers, AsteriskToken? asteriskToken, Identifier? name, List<TypeParameterDeclaration>? typeParameters, List<ParameterDeclaration> parameters, TypeNode? type, Block body);
  /// createArrowFunction(modifiers: readonly Modifier[] | undefined, typeParameters: readonly TypeParameterDeclaration[] | undefined, parameters: readonly ParameterDeclaration[], type: TypeNode | undefined, equalsGreaterThanToken: EqualsGreaterThanToken | undefined, body: ConciseBody): ArrowFunction;
  ArrowFunction createArrowFunction(List<Modifier>? modifiers, List<TypeParameterDeclaration>? typeParameters, List<ParameterDeclaration> parameters, TypeNode? type, EqualsGreaterThanToken? equalsGreaterThanToken, ConciseBody body);
  /// updateArrowFunction(node: ArrowFunction, modifiers: readonly Modifier[] | undefined, typeParameters: readonly TypeParameterDeclaration[] | undefined, parameters: readonly ParameterDeclaration[], type: TypeNode | undefined, equalsGreaterThanToken: EqualsGreaterThanToken, body: ConciseBody): ArrowFunction;
  ArrowFunction updateArrowFunction(ArrowFunction node, List<Modifier>? modifiers, List<TypeParameterDeclaration>? typeParameters, List<ParameterDeclaration> parameters, TypeNode? type, EqualsGreaterThanToken equalsGreaterThanToken, ConciseBody body);
  /// createDeleteExpression(expression: Expression): DeleteExpression;
  DeleteExpression createDeleteExpression(Expression expression);
  /// updateDeleteExpression(node: DeleteExpression, expression: Expression): DeleteExpression;
  DeleteExpression updateDeleteExpression(DeleteExpression node, Expression expression);
  /// createTypeOfExpression(expression: Expression): TypeOfExpression;
  TypeOfExpression createTypeOfExpression(Expression expression);
  /// updateTypeOfExpression(node: TypeOfExpression, expression: Expression): TypeOfExpression;
  TypeOfExpression updateTypeOfExpression(TypeOfExpression node, Expression expression);
  /// createVoidExpression(expression: Expression): VoidExpression;
  VoidExpression createVoidExpression(Expression expression);
  /// updateVoidExpression(node: VoidExpression, expression: Expression): VoidExpression;
  VoidExpression updateVoidExpression(VoidExpression node, Expression expression);
  /// createAwaitExpression(expression: Expression): AwaitExpression;
  AwaitExpression createAwaitExpression(Expression expression);
  /// updateAwaitExpression(node: AwaitExpression, expression: Expression): AwaitExpression;
  AwaitExpression updateAwaitExpression(AwaitExpression node, Expression expression);
  /// createPrefixUnaryExpression(operator: PrefixUnaryOperator, operand: Expression): PrefixUnaryExpression;
  PrefixUnaryExpression createPrefixUnaryExpression(PrefixUnaryOperator operator_, Expression operand);
  /// updatePrefixUnaryExpression(node: PrefixUnaryExpression, operand: Expression): PrefixUnaryExpression;
  PrefixUnaryExpression updatePrefixUnaryExpression(PrefixUnaryExpression node, Expression operand);
  /// createPostfixUnaryExpression(operand: Expression, operator: PostfixUnaryOperator): PostfixUnaryExpression;
  PostfixUnaryExpression createPostfixUnaryExpression(Expression operand, PostfixUnaryOperator operator_);
  /// updatePostfixUnaryExpression(node: PostfixUnaryExpression, operand: Expression): PostfixUnaryExpression;
  PostfixUnaryExpression updatePostfixUnaryExpression(PostfixUnaryExpression node, Expression operand);
  /// createBinaryExpression(left: Expression, operator: BinaryOperator | BinaryOperatorToken, right: Expression): BinaryExpression;
  BinaryExpression createBinaryExpression(Expression left, Object? operator_, Expression right);
  /// updateBinaryExpression(node: BinaryExpression, left: Expression, operator: BinaryOperator | BinaryOperatorToken, right: Expression): BinaryExpression;
  BinaryExpression updateBinaryExpression(BinaryExpression node, Expression left, Object? operator_, Expression right);
  /// createConditionalExpression(condition: Expression, questionToken: QuestionToken | undefined, whenTrue: Expression, colonToken: ColonToken | undefined, whenFalse: Expression): ConditionalExpression;
  ConditionalExpression createConditionalExpression(Expression condition, QuestionToken? questionToken, Expression whenTrue, ColonToken? colonToken, Expression whenFalse);
  /// updateConditionalExpression(node: ConditionalExpression, condition: Expression, questionToken: QuestionToken, whenTrue: Expression, colonToken: ColonToken, whenFalse: Expression): ConditionalExpression;
  ConditionalExpression updateConditionalExpression(ConditionalExpression node, Expression condition, QuestionToken questionToken, Expression whenTrue, ColonToken colonToken, Expression whenFalse);
  /// createTemplateExpression(head: TemplateHead, templateSpans: readonly TemplateSpan[]): TemplateExpression;
  TemplateExpression createTemplateExpression(TemplateHead head, List<TemplateSpan> templateSpans);
  /// updateTemplateExpression(node: TemplateExpression, head: TemplateHead, templateSpans: readonly TemplateSpan[]): TemplateExpression;
  TemplateExpression updateTemplateExpression(TemplateExpression node, TemplateHead head, List<TemplateSpan> templateSpans);
  /// createTemplateHead(text: string, rawText?: string, templateFlags?: TokenFlags): TemplateHead;
  TemplateHead createTemplateHead(String text, [String? rawText, TokenFlags? templateFlags]);
  /// createTemplateHead(text: string | undefined, rawText: string, templateFlags?: TokenFlags): TemplateHead;
  TemplateHead createTemplateHead$1(String? text, String rawText, [TokenFlags? templateFlags]);
  /// createTemplateMiddle(text: string, rawText?: string, templateFlags?: TokenFlags): TemplateMiddle;
  TemplateMiddle createTemplateMiddle(String text, [String? rawText, TokenFlags? templateFlags]);
  /// createTemplateMiddle(text: string | undefined, rawText: string, templateFlags?: TokenFlags): TemplateMiddle;
  TemplateMiddle createTemplateMiddle$1(String? text, String rawText, [TokenFlags? templateFlags]);
  /// createTemplateTail(text: string, rawText?: string, templateFlags?: TokenFlags): TemplateTail;
  TemplateTail createTemplateTail(String text, [String? rawText, TokenFlags? templateFlags]);
  /// createTemplateTail(text: string | undefined, rawText: string, templateFlags?: TokenFlags): TemplateTail;
  TemplateTail createTemplateTail$1(String? text, String rawText, [TokenFlags? templateFlags]);
  /// createNoSubstitutionTemplateLiteral(text: string, rawText?: string): NoSubstitutionTemplateLiteral;
  NoSubstitutionTemplateLiteral createNoSubstitutionTemplateLiteral(String text, [String? rawText]);
  /// createNoSubstitutionTemplateLiteral(text: string | undefined, rawText: string): NoSubstitutionTemplateLiteral;
  NoSubstitutionTemplateLiteral createNoSubstitutionTemplateLiteral$1(String? text, String rawText);
  /// createYieldExpression(asteriskToken: AsteriskToken, expression: Expression): YieldExpression;
  YieldExpression createYieldExpression(AsteriskToken asteriskToken, Expression expression);
  /// createYieldExpression(asteriskToken: undefined, expression: Expression | undefined): YieldExpression;
  YieldExpression createYieldExpression$1(Null asteriskToken, Expression? expression);
  /// updateYieldExpression(node: YieldExpression, asteriskToken: AsteriskToken | undefined, expression: Expression | undefined): YieldExpression;
  YieldExpression updateYieldExpression(YieldExpression node, AsteriskToken? asteriskToken, Expression? expression);
  /// createSpreadElement(expression: Expression): SpreadElement;
  SpreadElement createSpreadElement(Expression expression);
  /// updateSpreadElement(node: SpreadElement, expression: Expression): SpreadElement;
  SpreadElement updateSpreadElement(SpreadElement node, Expression expression);
  /// createClassExpression(modifiers: readonly ModifierLike[] | undefined, name: string | Identifier | undefined, typeParameters: readonly TypeParameterDeclaration[] | undefined, heritageClauses: readonly HeritageClause[] | undefined, members: readonly ClassElement[]): ClassExpression;
  ClassExpression createClassExpression(List<ModifierLike>? modifiers, Object? name, List<TypeParameterDeclaration>? typeParameters, List<HeritageClause>? heritageClauses, List<ClassElement> members);
  /// updateClassExpression(node: ClassExpression, modifiers: readonly ModifierLike[] | undefined, name: Identifier | undefined, typeParameters: readonly TypeParameterDeclaration[] | undefined, heritageClauses: readonly HeritageClause[] | undefined, members: readonly ClassElement[]): ClassExpression;
  ClassExpression updateClassExpression(ClassExpression node, List<ModifierLike>? modifiers, Identifier? name, List<TypeParameterDeclaration>? typeParameters, List<HeritageClause>? heritageClauses, List<ClassElement> members);
  /// createOmittedExpression(): OmittedExpression;
  OmittedExpression createOmittedExpression();
  /// createExpressionWithTypeArguments(expression: Expression, typeArguments: readonly TypeNode[] | undefined): ExpressionWithTypeArguments;
  ExpressionWithTypeArguments createExpressionWithTypeArguments(Expression expression, List<TypeNode>? typeArguments);
  /// updateExpressionWithTypeArguments(node: ExpressionWithTypeArguments, expression: Expression, typeArguments: readonly TypeNode[] | undefined): ExpressionWithTypeArguments;
  ExpressionWithTypeArguments updateExpressionWithTypeArguments(ExpressionWithTypeArguments node, Expression expression, List<TypeNode>? typeArguments);
  /// createAsExpression(expression: Expression, type: TypeNode): AsExpression;
  AsExpression createAsExpression(Expression expression, TypeNode type);
  /// updateAsExpression(node: AsExpression, expression: Expression, type: TypeNode): AsExpression;
  AsExpression updateAsExpression(AsExpression node, Expression expression, TypeNode type);
  /// createNonNullExpression(expression: Expression): NonNullExpression;
  NonNullExpression createNonNullExpression(Expression expression);
  /// updateNonNullExpression(node: NonNullExpression, expression: Expression): NonNullExpression;
  NonNullExpression updateNonNullExpression(NonNullExpression node, Expression expression);
  /// createNonNullChain(expression: Expression): NonNullChain;
  NonNullChain createNonNullChain(Expression expression);
  /// updateNonNullChain(node: NonNullChain, expression: Expression): NonNullChain;
  NonNullChain updateNonNullChain(NonNullChain node, Expression expression);
  /// createMetaProperty(keywordToken: MetaProperty["keywordToken"], name: Identifier): MetaProperty;
  MetaProperty createMetaProperty(Object? keywordToken, Identifier name);
  /// updateMetaProperty(node: MetaProperty, name: Identifier): MetaProperty;
  MetaProperty updateMetaProperty(MetaProperty node, Identifier name);
  /// createSatisfiesExpression(expression: Expression, type: TypeNode): SatisfiesExpression;
  SatisfiesExpression createSatisfiesExpression(Expression expression, TypeNode type);
  /// updateSatisfiesExpression(node: SatisfiesExpression, expression: Expression, type: TypeNode): SatisfiesExpression;
  SatisfiesExpression updateSatisfiesExpression(SatisfiesExpression node, Expression expression, TypeNode type);
  /// createTemplateSpan(expression: Expression, literal: TemplateMiddle | TemplateTail): TemplateSpan;
  TemplateSpan createTemplateSpan(Expression expression, Object? literal);
  /// updateTemplateSpan(node: TemplateSpan, expression: Expression, literal: TemplateMiddle | TemplateTail): TemplateSpan;
  TemplateSpan updateTemplateSpan(TemplateSpan node, Expression expression, Object? literal);
  /// createSemicolonClassElement(): SemicolonClassElement;
  SemicolonClassElement createSemicolonClassElement();
  /// createBlock(statements: readonly Statement[], multiLine?: boolean): Block;
  Block createBlock(List<Statement> statements, [bool? multiLine]);
  /// updateBlock(node: Block, statements: readonly Statement[]): Block;
  Block updateBlock(Block node, List<Statement> statements);
  /// createVariableStatement(modifiers: readonly ModifierLike[] | undefined, declarationList: VariableDeclarationList | readonly VariableDeclaration[]): VariableStatement;
  VariableStatement createVariableStatement(List<ModifierLike>? modifiers, Object? declarationList);
  /// updateVariableStatement(node: VariableStatement, modifiers: readonly ModifierLike[] | undefined, declarationList: VariableDeclarationList): VariableStatement;
  VariableStatement updateVariableStatement(VariableStatement node, List<ModifierLike>? modifiers, VariableDeclarationList declarationList);
  /// createEmptyStatement(): EmptyStatement;
  EmptyStatement createEmptyStatement();
  /// createExpressionStatement(expression: Expression): ExpressionStatement;
  ExpressionStatement createExpressionStatement(Expression expression);
  /// updateExpressionStatement(node: ExpressionStatement, expression: Expression): ExpressionStatement;
  ExpressionStatement updateExpressionStatement(ExpressionStatement node, Expression expression);
  /// createIfStatement(expression: Expression, thenStatement: Statement, elseStatement?: Statement): IfStatement;
  IfStatement createIfStatement(Expression expression, Statement thenStatement, [Statement? elseStatement]);
  /// updateIfStatement(node: IfStatement, expression: Expression, thenStatement: Statement, elseStatement: Statement | undefined): IfStatement;
  IfStatement updateIfStatement(IfStatement node, Expression expression, Statement thenStatement, Statement? elseStatement);
  /// createDoStatement(statement: Statement, expression: Expression): DoStatement;
  DoStatement createDoStatement(Statement statement, Expression expression);
  /// updateDoStatement(node: DoStatement, statement: Statement, expression: Expression): DoStatement;
  DoStatement updateDoStatement(DoStatement node, Statement statement, Expression expression);
  /// createWhileStatement(expression: Expression, statement: Statement): WhileStatement;
  WhileStatement createWhileStatement(Expression expression, Statement statement);
  /// updateWhileStatement(node: WhileStatement, expression: Expression, statement: Statement): WhileStatement;
  WhileStatement updateWhileStatement(WhileStatement node, Expression expression, Statement statement);
  /// createForStatement(initializer: ForInitializer | undefined, condition: Expression | undefined, incrementor: Expression | undefined, statement: Statement): ForStatement;
  ForStatement createForStatement(ForInitializer? initializer, Expression? condition, Expression? incrementor, Statement statement);
  /// updateForStatement(node: ForStatement, initializer: ForInitializer | undefined, condition: Expression | undefined, incrementor: Expression | undefined, statement: Statement): ForStatement;
  ForStatement updateForStatement(ForStatement node, ForInitializer? initializer, Expression? condition, Expression? incrementor, Statement statement);
  /// createForInStatement(initializer: ForInitializer, expression: Expression, statement: Statement): ForInStatement;
  ForInStatement createForInStatement(ForInitializer initializer, Expression expression, Statement statement);
  /// updateForInStatement(node: ForInStatement, initializer: ForInitializer, expression: Expression, statement: Statement): ForInStatement;
  ForInStatement updateForInStatement(ForInStatement node, ForInitializer initializer, Expression expression, Statement statement);
  /// createForOfStatement(awaitModifier: AwaitKeyword | undefined, initializer: ForInitializer, expression: Expression, statement: Statement): ForOfStatement;
  ForOfStatement createForOfStatement(AwaitKeyword? awaitModifier, ForInitializer initializer, Expression expression, Statement statement);
  /// updateForOfStatement(node: ForOfStatement, awaitModifier: AwaitKeyword | undefined, initializer: ForInitializer, expression: Expression, statement: Statement): ForOfStatement;
  ForOfStatement updateForOfStatement(ForOfStatement node, AwaitKeyword? awaitModifier, ForInitializer initializer, Expression expression, Statement statement);
  /// createContinueStatement(label?: string | Identifier): ContinueStatement;
  ContinueStatement createContinueStatement([Object? label]);
  /// updateContinueStatement(node: ContinueStatement, label: Identifier | undefined): ContinueStatement;
  ContinueStatement updateContinueStatement(ContinueStatement node, Identifier? label);
  /// createBreakStatement(label?: string | Identifier): BreakStatement;
  BreakStatement createBreakStatement([Object? label]);
  /// updateBreakStatement(node: BreakStatement, label: Identifier | undefined): BreakStatement;
  BreakStatement updateBreakStatement(BreakStatement node, Identifier? label);
  /// createReturnStatement(expression?: Expression): ReturnStatement;
  ReturnStatement createReturnStatement([Expression? expression]);
  /// updateReturnStatement(node: ReturnStatement, expression: Expression | undefined): ReturnStatement;
  ReturnStatement updateReturnStatement(ReturnStatement node, Expression? expression);
  /// createWithStatement(expression: Expression, statement: Statement): WithStatement;
  WithStatement createWithStatement(Expression expression, Statement statement);
  /// updateWithStatement(node: WithStatement, expression: Expression, statement: Statement): WithStatement;
  WithStatement updateWithStatement(WithStatement node, Expression expression, Statement statement);
  /// createSwitchStatement(expression: Expression, caseBlock: CaseBlock): SwitchStatement;
  SwitchStatement createSwitchStatement(Expression expression, CaseBlock caseBlock);
  /// updateSwitchStatement(node: SwitchStatement, expression: Expression, caseBlock: CaseBlock): SwitchStatement;
  SwitchStatement updateSwitchStatement(SwitchStatement node, Expression expression, CaseBlock caseBlock);
  /// createLabeledStatement(label: string | Identifier, statement: Statement): LabeledStatement;
  LabeledStatement createLabeledStatement(Object? label, Statement statement);
  /// updateLabeledStatement(node: LabeledStatement, label: Identifier, statement: Statement): LabeledStatement;
  LabeledStatement updateLabeledStatement(LabeledStatement node, Identifier label, Statement statement);
  /// createThrowStatement(expression: Expression): ThrowStatement;
  ThrowStatement createThrowStatement(Expression expression);
  /// updateThrowStatement(node: ThrowStatement, expression: Expression): ThrowStatement;
  ThrowStatement updateThrowStatement(ThrowStatement node, Expression expression);
  /// createTryStatement(tryBlock: Block, catchClause: CatchClause | undefined, finallyBlock: Block | undefined): TryStatement;
  TryStatement createTryStatement(Block tryBlock, CatchClause? catchClause, Block? finallyBlock);
  /// updateTryStatement(node: TryStatement, tryBlock: Block, catchClause: CatchClause | undefined, finallyBlock: Block | undefined): TryStatement;
  TryStatement updateTryStatement(TryStatement node, Block tryBlock, CatchClause? catchClause, Block? finallyBlock);
  /// createDebuggerStatement(): DebuggerStatement;
  DebuggerStatement createDebuggerStatement();
  /// createVariableDeclaration(name: string | BindingName, exclamationToken?: ExclamationToken, type?: TypeNode, initializer?: Expression): VariableDeclaration;
  VariableDeclaration createVariableDeclaration(Object? name, [ExclamationToken? exclamationToken, TypeNode? type, Expression? initializer]);
  /// updateVariableDeclaration(node: VariableDeclaration, name: BindingName, exclamationToken: ExclamationToken | undefined, type: TypeNode | undefined, initializer: Expression | undefined): VariableDeclaration;
  VariableDeclaration updateVariableDeclaration(VariableDeclaration node, BindingName name, ExclamationToken? exclamationToken, TypeNode? type, Expression? initializer);
  /// createVariableDeclarationList(declarations: readonly VariableDeclaration[], flags?: NodeFlags): VariableDeclarationList;
  VariableDeclarationList createVariableDeclarationList(List<VariableDeclaration> declarations, [NodeFlags? flags]);
  /// updateVariableDeclarationList(node: VariableDeclarationList, declarations: readonly VariableDeclaration[]): VariableDeclarationList;
  VariableDeclarationList updateVariableDeclarationList(VariableDeclarationList node, List<VariableDeclaration> declarations);
  /// createFunctionDeclaration(modifiers: readonly ModifierLike[] | undefined, asteriskToken: AsteriskToken | undefined, name: string | Identifier | undefined, typeParameters: readonly TypeParameterDeclaration[] | undefined, parameters: readonly ParameterDeclaration[], type: TypeNode | undefined, body: Block | undefined): FunctionDeclaration;
  FunctionDeclaration createFunctionDeclaration(List<ModifierLike>? modifiers, AsteriskToken? asteriskToken, Object? name, List<TypeParameterDeclaration>? typeParameters, List<ParameterDeclaration> parameters, TypeNode? type, Block? body);
  /// updateFunctionDeclaration(node: FunctionDeclaration, modifiers: readonly ModifierLike[] | undefined, asteriskToken: AsteriskToken | undefined, name: Identifier | undefined, typeParameters: readonly TypeParameterDeclaration[] | undefined, parameters: readonly ParameterDeclaration[], type: TypeNode | undefined, body: Block | undefined): FunctionDeclaration;
  FunctionDeclaration updateFunctionDeclaration(FunctionDeclaration node, List<ModifierLike>? modifiers, AsteriskToken? asteriskToken, Identifier? name, List<TypeParameterDeclaration>? typeParameters, List<ParameterDeclaration> parameters, TypeNode? type, Block? body);
  /// createClassDeclaration(modifiers: readonly ModifierLike[] | undefined, name: string | Identifier | undefined, typeParameters: readonly TypeParameterDeclaration[] | undefined, heritageClauses: readonly HeritageClause[] | undefined, members: readonly ClassElement[]): ClassDeclaration;
  ClassDeclaration createClassDeclaration(List<ModifierLike>? modifiers, Object? name, List<TypeParameterDeclaration>? typeParameters, List<HeritageClause>? heritageClauses, List<ClassElement> members);
  /// updateClassDeclaration(node: ClassDeclaration, modifiers: readonly ModifierLike[] | undefined, name: Identifier | undefined, typeParameters: readonly TypeParameterDeclaration[] | undefined, heritageClauses: readonly HeritageClause[] | undefined, members: readonly ClassElement[]): ClassDeclaration;
  ClassDeclaration updateClassDeclaration(ClassDeclaration node, List<ModifierLike>? modifiers, Identifier? name, List<TypeParameterDeclaration>? typeParameters, List<HeritageClause>? heritageClauses, List<ClassElement> members);
  /// createInterfaceDeclaration(modifiers: readonly ModifierLike[] | undefined, name: string | Identifier, typeParameters: readonly TypeParameterDeclaration[] | undefined, heritageClauses: readonly HeritageClause[] | undefined, members: readonly TypeElement[]): InterfaceDeclaration;
  InterfaceDeclaration createInterfaceDeclaration(List<ModifierLike>? modifiers, Object? name, List<TypeParameterDeclaration>? typeParameters, List<HeritageClause>? heritageClauses, List<TypeElement> members);
  /// updateInterfaceDeclaration(node: InterfaceDeclaration, modifiers: readonly ModifierLike[] | undefined, name: Identifier, typeParameters: readonly TypeParameterDeclaration[] | undefined, heritageClauses: readonly HeritageClause[] | undefined, members: readonly TypeElement[]): InterfaceDeclaration;
  InterfaceDeclaration updateInterfaceDeclaration(InterfaceDeclaration node, List<ModifierLike>? modifiers, Identifier name, List<TypeParameterDeclaration>? typeParameters, List<HeritageClause>? heritageClauses, List<TypeElement> members);
  /// createTypeAliasDeclaration(modifiers: readonly ModifierLike[] | undefined, name: string | Identifier, typeParameters: readonly TypeParameterDeclaration[] | undefined, type: TypeNode): TypeAliasDeclaration;
  TypeAliasDeclaration createTypeAliasDeclaration(List<ModifierLike>? modifiers, Object? name, List<TypeParameterDeclaration>? typeParameters, TypeNode type);
  /// updateTypeAliasDeclaration(node: TypeAliasDeclaration, modifiers: readonly ModifierLike[] | undefined, name: Identifier, typeParameters: readonly TypeParameterDeclaration[] | undefined, type: TypeNode): TypeAliasDeclaration;
  TypeAliasDeclaration updateTypeAliasDeclaration(TypeAliasDeclaration node, List<ModifierLike>? modifiers, Identifier name, List<TypeParameterDeclaration>? typeParameters, TypeNode type);
  /// createEnumDeclaration(modifiers: readonly ModifierLike[] | undefined, name: string | Identifier, members: readonly EnumMember[]): EnumDeclaration;
  EnumDeclaration createEnumDeclaration(List<ModifierLike>? modifiers, Object? name, List<EnumMember> members);
  /// updateEnumDeclaration(node: EnumDeclaration, modifiers: readonly ModifierLike[] | undefined, name: Identifier, members: readonly EnumMember[]): EnumDeclaration;
  EnumDeclaration updateEnumDeclaration(EnumDeclaration node, List<ModifierLike>? modifiers, Identifier name, List<EnumMember> members);
  /// createModuleDeclaration(modifiers: readonly ModifierLike[] | undefined, name: ModuleName, body: ModuleBody | undefined, flags?: NodeFlags): ModuleDeclaration;
  ModuleDeclaration createModuleDeclaration(List<ModifierLike>? modifiers, ModuleName name, ModuleBody? body, [NodeFlags? flags]);
  /// updateModuleDeclaration(node: ModuleDeclaration, modifiers: readonly ModifierLike[] | undefined, name: ModuleName, body: ModuleBody | undefined): ModuleDeclaration;
  ModuleDeclaration updateModuleDeclaration(ModuleDeclaration node, List<ModifierLike>? modifiers, ModuleName name, ModuleBody? body);
  /// createModuleBlock(statements: readonly Statement[]): ModuleBlock;
  ModuleBlock createModuleBlock(List<Statement> statements);
  /// updateModuleBlock(node: ModuleBlock, statements: readonly Statement[]): ModuleBlock;
  ModuleBlock updateModuleBlock(ModuleBlock node, List<Statement> statements);
  /// createCaseBlock(clauses: readonly CaseOrDefaultClause[]): CaseBlock;
  CaseBlock createCaseBlock(List<CaseOrDefaultClause> clauses);
  /// updateCaseBlock(node: CaseBlock, clauses: readonly CaseOrDefaultClause[]): CaseBlock;
  CaseBlock updateCaseBlock(CaseBlock node, List<CaseOrDefaultClause> clauses);
  /// createNamespaceExportDeclaration(name: string | Identifier): NamespaceExportDeclaration;
  NamespaceExportDeclaration createNamespaceExportDeclaration(Object? name);
  /// updateNamespaceExportDeclaration(node: NamespaceExportDeclaration, name: Identifier): NamespaceExportDeclaration;
  NamespaceExportDeclaration updateNamespaceExportDeclaration(NamespaceExportDeclaration node, Identifier name);
  /// createImportEqualsDeclaration(modifiers: readonly ModifierLike[] | undefined, isTypeOnly: boolean, name: string | Identifier, moduleReference: ModuleReference): ImportEqualsDeclaration;
  ImportEqualsDeclaration createImportEqualsDeclaration(List<ModifierLike>? modifiers, bool isTypeOnly, Object? name, ModuleReference moduleReference);
  /// updateImportEqualsDeclaration(node: ImportEqualsDeclaration, modifiers: readonly ModifierLike[] | undefined, isTypeOnly: boolean, name: Identifier, moduleReference: ModuleReference): ImportEqualsDeclaration;
  ImportEqualsDeclaration updateImportEqualsDeclaration(ImportEqualsDeclaration node, List<ModifierLike>? modifiers, bool isTypeOnly, Identifier name, ModuleReference moduleReference);
  /// createImportDeclaration(modifiers: readonly ModifierLike[] | undefined, importClause: ImportClause | undefined, moduleSpecifier: Expression, attributes?: ImportAttributes): ImportDeclaration;
  ImportDeclaration createImportDeclaration(List<ModifierLike>? modifiers, ImportClause? importClause, Expression moduleSpecifier, [ImportAttributes? attributes]);
  /// updateImportDeclaration(node: ImportDeclaration, modifiers: readonly ModifierLike[] | undefined, importClause: ImportClause | undefined, moduleSpecifier: Expression, attributes: ImportAttributes | undefined): ImportDeclaration;
  ImportDeclaration updateImportDeclaration(ImportDeclaration node, List<ModifierLike>? modifiers, ImportClause? importClause, Expression moduleSpecifier, ImportAttributes? attributes);
  /// createImportClause(phaseModifier: ImportPhaseModifierSyntaxKind | undefined, name: Identifier | undefined, namedBindings: NamedImportBindings | undefined): ImportClause;
  ImportClause createImportClause(ImportPhaseModifierSyntaxKind? phaseModifier, Identifier? name, NamedImportBindings? namedBindings);
  /// createImportClause(isTypeOnly: boolean, name: Identifier | undefined, namedBindings: NamedImportBindings | undefined): ImportClause;
  ImportClause createImportClause$1(bool isTypeOnly, Identifier? name, NamedImportBindings? namedBindings);
  /// updateImportClause(node: ImportClause, phaseModifier: ImportPhaseModifierSyntaxKind | undefined, name: Identifier | undefined, namedBindings: NamedImportBindings | undefined): ImportClause;
  ImportClause updateImportClause(ImportClause node, ImportPhaseModifierSyntaxKind? phaseModifier, Identifier? name, NamedImportBindings? namedBindings);
  /// updateImportClause(node: ImportClause, isTypeOnly: boolean, name: Identifier | undefined, namedBindings: NamedImportBindings | undefined): ImportClause;
  ImportClause updateImportClause$1(ImportClause node, bool isTypeOnly, Identifier? name, NamedImportBindings? namedBindings);
  /// createAssertClause(elements: NodeArray<AssertEntry>, multiLine?: boolean): AssertClause;
  AssertClause createAssertClause(NodeArray<AssertEntry> elements, [bool? multiLine]);
  /// updateAssertClause(node: AssertClause, elements: NodeArray<AssertEntry>, multiLine?: boolean): AssertClause;
  AssertClause updateAssertClause(AssertClause node, NodeArray<AssertEntry> elements, [bool? multiLine]);
  /// createAssertEntry(name: AssertionKey, value: Expression): AssertEntry;
  AssertEntry createAssertEntry(AssertionKey name, Expression value);
  /// updateAssertEntry(node: AssertEntry, name: AssertionKey, value: Expression): AssertEntry;
  AssertEntry updateAssertEntry(AssertEntry node, AssertionKey name, Expression value);
  /// createImportTypeAssertionContainer(clause: AssertClause, multiLine?: boolean): ImportTypeAssertionContainer;
  ImportTypeAssertionContainer createImportTypeAssertionContainer(AssertClause clause, [bool? multiLine]);
  /// updateImportTypeAssertionContainer(node: ImportTypeAssertionContainer, clause: AssertClause, multiLine?: boolean): ImportTypeAssertionContainer;
  ImportTypeAssertionContainer updateImportTypeAssertionContainer(ImportTypeAssertionContainer node, AssertClause clause, [bool? multiLine]);
  /// createImportAttributes(elements: NodeArray<ImportAttribute>, multiLine?: boolean): ImportAttributes;
  ImportAttributes createImportAttributes(NodeArray<ImportAttribute> elements, [bool? multiLine]);
  /// updateImportAttributes(node: ImportAttributes, elements: NodeArray<ImportAttribute>, multiLine?: boolean): ImportAttributes;
  ImportAttributes updateImportAttributes(ImportAttributes node, NodeArray<ImportAttribute> elements, [bool? multiLine]);
  /// createImportAttribute(name: ImportAttributeName, value: Expression): ImportAttribute;
  ImportAttribute createImportAttribute(ImportAttributeName name, Expression value);
  /// updateImportAttribute(node: ImportAttribute, name: ImportAttributeName, value: Expression): ImportAttribute;
  ImportAttribute updateImportAttribute(ImportAttribute node, ImportAttributeName name, Expression value);
  /// createNamespaceImport(name: Identifier): NamespaceImport;
  NamespaceImport createNamespaceImport(Identifier name);
  /// updateNamespaceImport(node: NamespaceImport, name: Identifier): NamespaceImport;
  NamespaceImport updateNamespaceImport(NamespaceImport node, Identifier name);
  /// createNamespaceExport(name: ModuleExportName): NamespaceExport;
  NamespaceExport createNamespaceExport(ModuleExportName name);
  /// updateNamespaceExport(node: NamespaceExport, name: ModuleExportName): NamespaceExport;
  NamespaceExport updateNamespaceExport(NamespaceExport node, ModuleExportName name);
  /// createNamedImports(elements: readonly ImportSpecifier[]): NamedImports;
  NamedImports createNamedImports(List<ImportSpecifier> elements);
  /// updateNamedImports(node: NamedImports, elements: readonly ImportSpecifier[]): NamedImports;
  NamedImports updateNamedImports(NamedImports node, List<ImportSpecifier> elements);
  /// createImportSpecifier(isTypeOnly: boolean, propertyName: ModuleExportName | undefined, name: Identifier): ImportSpecifier;
  ImportSpecifier createImportSpecifier(bool isTypeOnly, ModuleExportName? propertyName, Identifier name);
  /// updateImportSpecifier(node: ImportSpecifier, isTypeOnly: boolean, propertyName: ModuleExportName | undefined, name: Identifier): ImportSpecifier;
  ImportSpecifier updateImportSpecifier(ImportSpecifier node, bool isTypeOnly, ModuleExportName? propertyName, Identifier name);
  /// createExportAssignment(modifiers: readonly ModifierLike[] | undefined, isExportEquals: boolean | undefined, expression: Expression): ExportAssignment;
  ExportAssignment createExportAssignment(List<ModifierLike>? modifiers, bool? isExportEquals, Expression expression);
  /// updateExportAssignment(node: ExportAssignment, modifiers: readonly ModifierLike[] | undefined, expression: Expression): ExportAssignment;
  ExportAssignment updateExportAssignment(ExportAssignment node, List<ModifierLike>? modifiers, Expression expression);
  /// createExportDeclaration(modifiers: readonly ModifierLike[] | undefined, isTypeOnly: boolean, exportClause: NamedExportBindings | undefined, moduleSpecifier?: Expression, attributes?: ImportAttributes): ExportDeclaration;
  ExportDeclaration createExportDeclaration(List<ModifierLike>? modifiers, bool isTypeOnly, NamedExportBindings? exportClause, [Expression? moduleSpecifier, ImportAttributes? attributes]);
  /// updateExportDeclaration(node: ExportDeclaration, modifiers: readonly ModifierLike[] | undefined, isTypeOnly: boolean, exportClause: NamedExportBindings | undefined, moduleSpecifier: Expression | undefined, attributes: ImportAttributes | undefined): ExportDeclaration;
  ExportDeclaration updateExportDeclaration(ExportDeclaration node, List<ModifierLike>? modifiers, bool isTypeOnly, NamedExportBindings? exportClause, Expression? moduleSpecifier, ImportAttributes? attributes);
  /// createNamedExports(elements: readonly ExportSpecifier[]): NamedExports;
  NamedExports createNamedExports(List<ExportSpecifier> elements);
  /// updateNamedExports(node: NamedExports, elements: readonly ExportSpecifier[]): NamedExports;
  NamedExports updateNamedExports(NamedExports node, List<ExportSpecifier> elements);
  /// createExportSpecifier(isTypeOnly: boolean, propertyName: string | ModuleExportName | undefined, name: string | ModuleExportName): ExportSpecifier;
  ExportSpecifier createExportSpecifier(bool isTypeOnly, Object? propertyName, Object? name);
  /// updateExportSpecifier(node: ExportSpecifier, isTypeOnly: boolean, propertyName: ModuleExportName | undefined, name: ModuleExportName): ExportSpecifier;
  ExportSpecifier updateExportSpecifier(ExportSpecifier node, bool isTypeOnly, ModuleExportName? propertyName, ModuleExportName name);
  /// createExternalModuleReference(expression: Expression): ExternalModuleReference;
  ExternalModuleReference createExternalModuleReference(Expression expression);
  /// updateExternalModuleReference(node: ExternalModuleReference, expression: Expression): ExternalModuleReference;
  ExternalModuleReference updateExternalModuleReference(ExternalModuleReference node, Expression expression);
  /// createJSDocAllType(): JSDocAllType;
  JSDocAllType createJSDocAllType();
  /// createJSDocUnknownType(): JSDocUnknownType;
  JSDocUnknownType createJSDocUnknownType();
  /// createJSDocNonNullableType(type: TypeNode, postfix?: boolean): JSDocNonNullableType;
  JSDocNonNullableType createJSDocNonNullableType(TypeNode type, [bool? postfix]);
  /// updateJSDocNonNullableType(node: JSDocNonNullableType, type: TypeNode): JSDocNonNullableType;
  JSDocNonNullableType updateJSDocNonNullableType(JSDocNonNullableType node, TypeNode type);
  /// createJSDocNullableType(type: TypeNode, postfix?: boolean): JSDocNullableType;
  JSDocNullableType createJSDocNullableType(TypeNode type, [bool? postfix]);
  /// updateJSDocNullableType(node: JSDocNullableType, type: TypeNode): JSDocNullableType;
  JSDocNullableType updateJSDocNullableType(JSDocNullableType node, TypeNode type);
  /// createJSDocOptionalType(type: TypeNode): JSDocOptionalType;
  JSDocOptionalType createJSDocOptionalType(TypeNode type);
  /// updateJSDocOptionalType(node: JSDocOptionalType, type: TypeNode): JSDocOptionalType;
  JSDocOptionalType updateJSDocOptionalType(JSDocOptionalType node, TypeNode type);
  /// createJSDocFunctionType(parameters: readonly ParameterDeclaration[], type: TypeNode | undefined): JSDocFunctionType;
  JSDocFunctionType createJSDocFunctionType(List<ParameterDeclaration> parameters, TypeNode? type);
  /// updateJSDocFunctionType(node: JSDocFunctionType, parameters: readonly ParameterDeclaration[], type: TypeNode | undefined): JSDocFunctionType;
  JSDocFunctionType updateJSDocFunctionType(JSDocFunctionType node, List<ParameterDeclaration> parameters, TypeNode? type);
  /// createJSDocVariadicType(type: TypeNode): JSDocVariadicType;
  JSDocVariadicType createJSDocVariadicType(TypeNode type);
  /// updateJSDocVariadicType(node: JSDocVariadicType, type: TypeNode): JSDocVariadicType;
  JSDocVariadicType updateJSDocVariadicType(JSDocVariadicType node, TypeNode type);
  /// createJSDocNamepathType(type: TypeNode): JSDocNamepathType;
  JSDocNamepathType createJSDocNamepathType(TypeNode type);
  /// updateJSDocNamepathType(node: JSDocNamepathType, type: TypeNode): JSDocNamepathType;
  JSDocNamepathType updateJSDocNamepathType(JSDocNamepathType node, TypeNode type);
  /// createJSDocTypeExpression(type: TypeNode): JSDocTypeExpression;
  JSDocTypeExpression createJSDocTypeExpression(TypeNode type);
  /// updateJSDocTypeExpression(node: JSDocTypeExpression, type: TypeNode): JSDocTypeExpression;
  JSDocTypeExpression updateJSDocTypeExpression(JSDocTypeExpression node, TypeNode type);
  /// createJSDocNameReference(name: EntityName | JSDocMemberName): JSDocNameReference;
  JSDocNameReference createJSDocNameReference(Object? name);
  /// updateJSDocNameReference(node: JSDocNameReference, name: EntityName | JSDocMemberName): JSDocNameReference;
  JSDocNameReference updateJSDocNameReference(JSDocNameReference node, Object? name);
  /// createJSDocMemberName(left: EntityName | JSDocMemberName, right: Identifier): JSDocMemberName;
  JSDocMemberName createJSDocMemberName(Object? left, Identifier right);
  /// updateJSDocMemberName(node: JSDocMemberName, left: EntityName | JSDocMemberName, right: Identifier): JSDocMemberName;
  JSDocMemberName updateJSDocMemberName(JSDocMemberName node, Object? left, Identifier right);
  /// createJSDocLink(name: EntityName | JSDocMemberName | undefined, text: string): JSDocLink;
  JSDocLink createJSDocLink(Object? name, String text);
  /// updateJSDocLink(node: JSDocLink, name: EntityName | JSDocMemberName | undefined, text: string): JSDocLink;
  JSDocLink updateJSDocLink(JSDocLink node, Object? name, String text);
  /// createJSDocLinkCode(name: EntityName | JSDocMemberName | undefined, text: string): JSDocLinkCode;
  JSDocLinkCode createJSDocLinkCode(Object? name, String text);
  /// updateJSDocLinkCode(node: JSDocLinkCode, name: EntityName | JSDocMemberName | undefined, text: string): JSDocLinkCode;
  JSDocLinkCode updateJSDocLinkCode(JSDocLinkCode node, Object? name, String text);
  /// createJSDocLinkPlain(name: EntityName | JSDocMemberName | undefined, text: string): JSDocLinkPlain;
  JSDocLinkPlain createJSDocLinkPlain(Object? name, String text);
  /// updateJSDocLinkPlain(node: JSDocLinkPlain, name: EntityName | JSDocMemberName | undefined, text: string): JSDocLinkPlain;
  JSDocLinkPlain updateJSDocLinkPlain(JSDocLinkPlain node, Object? name, String text);
  /// createJSDocTypeLiteral(jsDocPropertyTags?: readonly JSDocPropertyLikeTag[], isArrayType?: boolean): JSDocTypeLiteral;
  JSDocTypeLiteral createJSDocTypeLiteral([List<JSDocPropertyLikeTag>? jsDocPropertyTags, bool? isArrayType]);
  /// updateJSDocTypeLiteral(node: JSDocTypeLiteral, jsDocPropertyTags: readonly JSDocPropertyLikeTag[] | undefined, isArrayType: boolean | undefined): JSDocTypeLiteral;
  JSDocTypeLiteral updateJSDocTypeLiteral(JSDocTypeLiteral node, List<JSDocPropertyLikeTag>? jsDocPropertyTags, bool? isArrayType);
  /// createJSDocSignature(typeParameters: readonly JSDocTemplateTag[] | undefined, parameters: readonly JSDocParameterTag[], type?: JSDocReturnTag): JSDocSignature;
  JSDocSignature createJSDocSignature(List<JSDocTemplateTag>? typeParameters, List<JSDocParameterTag> parameters, [JSDocReturnTag? type]);
  /// updateJSDocSignature(node: JSDocSignature, typeParameters: readonly JSDocTemplateTag[] | undefined, parameters: readonly JSDocParameterTag[], type: JSDocReturnTag | undefined): JSDocSignature;
  JSDocSignature updateJSDocSignature(JSDocSignature node, List<JSDocTemplateTag>? typeParameters, List<JSDocParameterTag> parameters, JSDocReturnTag? type);
  /// createJSDocTemplateTag(tagName: Identifier | undefined, constraint: JSDocTypeExpression | undefined, typeParameters: readonly TypeParameterDeclaration[], comment?: string | NodeArray<JSDocComment>): JSDocTemplateTag;
  JSDocTemplateTag createJSDocTemplateTag(Identifier? tagName, JSDocTypeExpression? constraint, List<TypeParameterDeclaration> typeParameters, [Object? comment]);
  /// updateJSDocTemplateTag(node: JSDocTemplateTag, tagName: Identifier | undefined, constraint: JSDocTypeExpression | undefined, typeParameters: readonly TypeParameterDeclaration[], comment: string | NodeArray<JSDocComment> | undefined): JSDocTemplateTag;
  JSDocTemplateTag updateJSDocTemplateTag(JSDocTemplateTag node, Identifier? tagName, JSDocTypeExpression? constraint, List<TypeParameterDeclaration> typeParameters, Object? comment);
  /// createJSDocTypedefTag(tagName: Identifier | undefined, typeExpression?: JSDocTypeExpression | JSDocTypeLiteral, fullName?: Identifier | JSDocNamespaceDeclaration, comment?: string | NodeArray<JSDocComment>): JSDocTypedefTag;
  JSDocTypedefTag createJSDocTypedefTag(Identifier? tagName, [Object? typeExpression, Object? fullName, Object? comment]);
  /// updateJSDocTypedefTag(node: JSDocTypedefTag, tagName: Identifier | undefined, typeExpression: JSDocTypeExpression | JSDocTypeLiteral | undefined, fullName: Identifier | JSDocNamespaceDeclaration | undefined, comment: string | NodeArray<JSDocComment> | undefined): JSDocTypedefTag;
  JSDocTypedefTag updateJSDocTypedefTag(JSDocTypedefTag node, Identifier? tagName, Object? typeExpression, Object? fullName, Object? comment);
  /// createJSDocParameterTag(tagName: Identifier | undefined, name: EntityName, isBracketed: boolean, typeExpression?: JSDocTypeExpression, isNameFirst?: boolean, comment?: string | NodeArray<JSDocComment>): JSDocParameterTag;
  JSDocParameterTag createJSDocParameterTag(Identifier? tagName, EntityName name, bool isBracketed, [JSDocTypeExpression? typeExpression, bool? isNameFirst, Object? comment]);
  /// updateJSDocParameterTag(node: JSDocParameterTag, tagName: Identifier | undefined, name: EntityName, isBracketed: boolean, typeExpression: JSDocTypeExpression | undefined, isNameFirst: boolean, comment: string | NodeArray<JSDocComment> | undefined): JSDocParameterTag;
  JSDocParameterTag updateJSDocParameterTag(JSDocParameterTag node, Identifier? tagName, EntityName name, bool isBracketed, JSDocTypeExpression? typeExpression, bool isNameFirst, Object? comment);
  /// createJSDocPropertyTag(tagName: Identifier | undefined, name: EntityName, isBracketed: boolean, typeExpression?: JSDocTypeExpression, isNameFirst?: boolean, comment?: string | NodeArray<JSDocComment>): JSDocPropertyTag;
  JSDocPropertyTag createJSDocPropertyTag(Identifier? tagName, EntityName name, bool isBracketed, [JSDocTypeExpression? typeExpression, bool? isNameFirst, Object? comment]);
  /// updateJSDocPropertyTag(node: JSDocPropertyTag, tagName: Identifier | undefined, name: EntityName, isBracketed: boolean, typeExpression: JSDocTypeExpression | undefined, isNameFirst: boolean, comment: string | NodeArray<JSDocComment> | undefined): JSDocPropertyTag;
  JSDocPropertyTag updateJSDocPropertyTag(JSDocPropertyTag node, Identifier? tagName, EntityName name, bool isBracketed, JSDocTypeExpression? typeExpression, bool isNameFirst, Object? comment);
  /// createJSDocTypeTag(tagName: Identifier | undefined, typeExpression: JSDocTypeExpression, comment?: string | NodeArray<JSDocComment>): JSDocTypeTag;
  JSDocTypeTag createJSDocTypeTag(Identifier? tagName, JSDocTypeExpression typeExpression, [Object? comment]);
  /// updateJSDocTypeTag(node: JSDocTypeTag, tagName: Identifier | undefined, typeExpression: JSDocTypeExpression, comment: string | NodeArray<JSDocComment> | undefined): JSDocTypeTag;
  JSDocTypeTag updateJSDocTypeTag(JSDocTypeTag node, Identifier? tagName, JSDocTypeExpression typeExpression, Object? comment);
  /// createJSDocSeeTag(tagName: Identifier | undefined, nameExpression: JSDocNameReference | undefined, comment?: string | NodeArray<JSDocComment>): JSDocSeeTag;
  JSDocSeeTag createJSDocSeeTag(Identifier? tagName, JSDocNameReference? nameExpression, [Object? comment]);
  /// updateJSDocSeeTag(node: JSDocSeeTag, tagName: Identifier | undefined, nameExpression: JSDocNameReference | undefined, comment?: string | NodeArray<JSDocComment>): JSDocSeeTag;
  JSDocSeeTag updateJSDocSeeTag(JSDocSeeTag node, Identifier? tagName, JSDocNameReference? nameExpression, [Object? comment]);
  /// createJSDocReturnTag(tagName: Identifier | undefined, typeExpression?: JSDocTypeExpression, comment?: string | NodeArray<JSDocComment>): JSDocReturnTag;
  JSDocReturnTag createJSDocReturnTag(Identifier? tagName, [JSDocTypeExpression? typeExpression, Object? comment]);
  /// updateJSDocReturnTag(node: JSDocReturnTag, tagName: Identifier | undefined, typeExpression: JSDocTypeExpression | undefined, comment: string | NodeArray<JSDocComment> | undefined): JSDocReturnTag;
  JSDocReturnTag updateJSDocReturnTag(JSDocReturnTag node, Identifier? tagName, JSDocTypeExpression? typeExpression, Object? comment);
  /// createJSDocThisTag(tagName: Identifier | undefined, typeExpression: JSDocTypeExpression, comment?: string | NodeArray<JSDocComment>): JSDocThisTag;
  JSDocThisTag createJSDocThisTag(Identifier? tagName, JSDocTypeExpression typeExpression, [Object? comment]);
  /// updateJSDocThisTag(node: JSDocThisTag, tagName: Identifier | undefined, typeExpression: JSDocTypeExpression | undefined, comment: string | NodeArray<JSDocComment> | undefined): JSDocThisTag;
  JSDocThisTag updateJSDocThisTag(JSDocThisTag node, Identifier? tagName, JSDocTypeExpression? typeExpression, Object? comment);
  /// createJSDocEnumTag(tagName: Identifier | undefined, typeExpression: JSDocTypeExpression, comment?: string | NodeArray<JSDocComment>): JSDocEnumTag;
  JSDocEnumTag createJSDocEnumTag(Identifier? tagName, JSDocTypeExpression typeExpression, [Object? comment]);
  /// updateJSDocEnumTag(node: JSDocEnumTag, tagName: Identifier | undefined, typeExpression: JSDocTypeExpression, comment: string | NodeArray<JSDocComment> | undefined): JSDocEnumTag;
  JSDocEnumTag updateJSDocEnumTag(JSDocEnumTag node, Identifier? tagName, JSDocTypeExpression typeExpression, Object? comment);
  /// createJSDocCallbackTag(tagName: Identifier | undefined, typeExpression: JSDocSignature, fullName?: Identifier | JSDocNamespaceDeclaration, comment?: string | NodeArray<JSDocComment>): JSDocCallbackTag;
  JSDocCallbackTag createJSDocCallbackTag(Identifier? tagName, JSDocSignature typeExpression, [Object? fullName, Object? comment]);
  /// updateJSDocCallbackTag(node: JSDocCallbackTag, tagName: Identifier | undefined, typeExpression: JSDocSignature, fullName: Identifier | JSDocNamespaceDeclaration | undefined, comment: string | NodeArray<JSDocComment> | undefined): JSDocCallbackTag;
  JSDocCallbackTag updateJSDocCallbackTag(JSDocCallbackTag node, Identifier? tagName, JSDocSignature typeExpression, Object? fullName, Object? comment);
  /// createJSDocOverloadTag(tagName: Identifier | undefined, typeExpression: JSDocSignature, comment?: string | NodeArray<JSDocComment>): JSDocOverloadTag;
  JSDocOverloadTag createJSDocOverloadTag(Identifier? tagName, JSDocSignature typeExpression, [Object? comment]);
  /// updateJSDocOverloadTag(node: JSDocOverloadTag, tagName: Identifier | undefined, typeExpression: JSDocSignature, comment: string | NodeArray<JSDocComment> | undefined): JSDocOverloadTag;
  JSDocOverloadTag updateJSDocOverloadTag(JSDocOverloadTag node, Identifier? tagName, JSDocSignature typeExpression, Object? comment);
  /// createJSDocAugmentsTag(tagName: Identifier | undefined, className: JSDocAugmentsTag["class"], comment?: string | NodeArray<JSDocComment>): JSDocAugmentsTag;
  JSDocAugmentsTag createJSDocAugmentsTag(Identifier? tagName, Object? className, [Object? comment]);
  /// updateJSDocAugmentsTag(node: JSDocAugmentsTag, tagName: Identifier | undefined, className: JSDocAugmentsTag["class"], comment: string | NodeArray<JSDocComment> | undefined): JSDocAugmentsTag;
  JSDocAugmentsTag updateJSDocAugmentsTag(JSDocAugmentsTag node, Identifier? tagName, Object? className, Object? comment);
  /// createJSDocImplementsTag(tagName: Identifier | undefined, className: JSDocImplementsTag["class"], comment?: string | NodeArray<JSDocComment>): JSDocImplementsTag;
  JSDocImplementsTag createJSDocImplementsTag(Identifier? tagName, Object? className, [Object? comment]);
  /// updateJSDocImplementsTag(node: JSDocImplementsTag, tagName: Identifier | undefined, className: JSDocImplementsTag["class"], comment: string | NodeArray<JSDocComment> | undefined): JSDocImplementsTag;
  JSDocImplementsTag updateJSDocImplementsTag(JSDocImplementsTag node, Identifier? tagName, Object? className, Object? comment);
  /// createJSDocAuthorTag(tagName: Identifier | undefined, comment?: string | NodeArray<JSDocComment>): JSDocAuthorTag;
  JSDocAuthorTag createJSDocAuthorTag(Identifier? tagName, [Object? comment]);
  /// updateJSDocAuthorTag(node: JSDocAuthorTag, tagName: Identifier | undefined, comment: string | NodeArray<JSDocComment> | undefined): JSDocAuthorTag;
  JSDocAuthorTag updateJSDocAuthorTag(JSDocAuthorTag node, Identifier? tagName, Object? comment);
  /// createJSDocClassTag(tagName: Identifier | undefined, comment?: string | NodeArray<JSDocComment>): JSDocClassTag;
  JSDocClassTag createJSDocClassTag(Identifier? tagName, [Object? comment]);
  /// updateJSDocClassTag(node: JSDocClassTag, tagName: Identifier | undefined, comment: string | NodeArray<JSDocComment> | undefined): JSDocClassTag;
  JSDocClassTag updateJSDocClassTag(JSDocClassTag node, Identifier? tagName, Object? comment);
  /// createJSDocPublicTag(tagName: Identifier | undefined, comment?: string | NodeArray<JSDocComment>): JSDocPublicTag;
  JSDocPublicTag createJSDocPublicTag(Identifier? tagName, [Object? comment]);
  /// updateJSDocPublicTag(node: JSDocPublicTag, tagName: Identifier | undefined, comment: string | NodeArray<JSDocComment> | undefined): JSDocPublicTag;
  JSDocPublicTag updateJSDocPublicTag(JSDocPublicTag node, Identifier? tagName, Object? comment);
  /// createJSDocPrivateTag(tagName: Identifier | undefined, comment?: string | NodeArray<JSDocComment>): JSDocPrivateTag;
  JSDocPrivateTag createJSDocPrivateTag(Identifier? tagName, [Object? comment]);
  /// updateJSDocPrivateTag(node: JSDocPrivateTag, tagName: Identifier | undefined, comment: string | NodeArray<JSDocComment> | undefined): JSDocPrivateTag;
  JSDocPrivateTag updateJSDocPrivateTag(JSDocPrivateTag node, Identifier? tagName, Object? comment);
  /// createJSDocProtectedTag(tagName: Identifier | undefined, comment?: string | NodeArray<JSDocComment>): JSDocProtectedTag;
  JSDocProtectedTag createJSDocProtectedTag(Identifier? tagName, [Object? comment]);
  /// updateJSDocProtectedTag(node: JSDocProtectedTag, tagName: Identifier | undefined, comment: string | NodeArray<JSDocComment> | undefined): JSDocProtectedTag;
  JSDocProtectedTag updateJSDocProtectedTag(JSDocProtectedTag node, Identifier? tagName, Object? comment);
  /// createJSDocReadonlyTag(tagName: Identifier | undefined, comment?: string | NodeArray<JSDocComment>): JSDocReadonlyTag;
  JSDocReadonlyTag createJSDocReadonlyTag(Identifier? tagName, [Object? comment]);
  /// updateJSDocReadonlyTag(node: JSDocReadonlyTag, tagName: Identifier | undefined, comment: string | NodeArray<JSDocComment> | undefined): JSDocReadonlyTag;
  JSDocReadonlyTag updateJSDocReadonlyTag(JSDocReadonlyTag node, Identifier? tagName, Object? comment);
  /// createJSDocUnknownTag(tagName: Identifier, comment?: string | NodeArray<JSDocComment>): JSDocUnknownTag;
  JSDocUnknownTag createJSDocUnknownTag(Identifier tagName, [Object? comment]);
  /// updateJSDocUnknownTag(node: JSDocUnknownTag, tagName: Identifier, comment: string | NodeArray<JSDocComment> | undefined): JSDocUnknownTag;
  JSDocUnknownTag updateJSDocUnknownTag(JSDocUnknownTag node, Identifier tagName, Object? comment);
  /// createJSDocDeprecatedTag(tagName: Identifier | undefined, comment?: string | NodeArray<JSDocComment>): JSDocDeprecatedTag;
  JSDocDeprecatedTag createJSDocDeprecatedTag(Identifier? tagName, [Object? comment]);
  /// updateJSDocDeprecatedTag(node: JSDocDeprecatedTag, tagName: Identifier | undefined, comment?: string | NodeArray<JSDocComment>): JSDocDeprecatedTag;
  JSDocDeprecatedTag updateJSDocDeprecatedTag(JSDocDeprecatedTag node, Identifier? tagName, [Object? comment]);
  /// createJSDocOverrideTag(tagName: Identifier | undefined, comment?: string | NodeArray<JSDocComment>): JSDocOverrideTag;
  JSDocOverrideTag createJSDocOverrideTag(Identifier? tagName, [Object? comment]);
  /// updateJSDocOverrideTag(node: JSDocOverrideTag, tagName: Identifier | undefined, comment?: string | NodeArray<JSDocComment>): JSDocOverrideTag;
  JSDocOverrideTag updateJSDocOverrideTag(JSDocOverrideTag node, Identifier? tagName, [Object? comment]);
  /// createJSDocThrowsTag(tagName: Identifier, typeExpression: JSDocTypeExpression | undefined, comment?: string | NodeArray<JSDocComment>): JSDocThrowsTag;
  JSDocThrowsTag createJSDocThrowsTag(Identifier tagName, JSDocTypeExpression? typeExpression, [Object? comment]);
  /// updateJSDocThrowsTag(node: JSDocThrowsTag, tagName: Identifier | undefined, typeExpression: JSDocTypeExpression | undefined, comment?: string | NodeArray<JSDocComment> | undefined): JSDocThrowsTag;
  JSDocThrowsTag updateJSDocThrowsTag(JSDocThrowsTag node, Identifier? tagName, JSDocTypeExpression? typeExpression, [Object? comment]);
  /// createJSDocSatisfiesTag(tagName: Identifier | undefined, typeExpression: JSDocTypeExpression, comment?: string | NodeArray<JSDocComment>): JSDocSatisfiesTag;
  JSDocSatisfiesTag createJSDocSatisfiesTag(Identifier? tagName, JSDocTypeExpression typeExpression, [Object? comment]);
  /// updateJSDocSatisfiesTag(node: JSDocSatisfiesTag, tagName: Identifier | undefined, typeExpression: JSDocTypeExpression, comment: string | NodeArray<JSDocComment> | undefined): JSDocSatisfiesTag;
  JSDocSatisfiesTag updateJSDocSatisfiesTag(JSDocSatisfiesTag node, Identifier? tagName, JSDocTypeExpression typeExpression, Object? comment);
  /// createJSDocImportTag(tagName: Identifier | undefined, importClause: ImportClause | undefined, moduleSpecifier: Expression, attributes?: ImportAttributes, comment?: string | NodeArray<JSDocComment>): JSDocImportTag;
  JSDocImportTag createJSDocImportTag(Identifier? tagName, ImportClause? importClause, Expression moduleSpecifier, [ImportAttributes? attributes, Object? comment]);
  /// updateJSDocImportTag(node: JSDocImportTag, tagName: Identifier | undefined, importClause: ImportClause | undefined, moduleSpecifier: Expression, attributes: ImportAttributes | undefined, comment: string | NodeArray<JSDocComment> | undefined): JSDocImportTag;
  JSDocImportTag updateJSDocImportTag(JSDocImportTag node, Identifier? tagName, ImportClause? importClause, Expression moduleSpecifier, ImportAttributes? attributes, Object? comment);
  /// createJSDocText(text: string): JSDocText;
  JSDocText createJSDocText(String text);
  /// updateJSDocText(node: JSDocText, text: string): JSDocText;
  JSDocText updateJSDocText(JSDocText node, String text);
  /// createJSDocComment(comment?: string | NodeArray<JSDocComment> | undefined, tags?: readonly JSDocTag[] | undefined): JSDoc;
  JSDoc createJSDocComment([Object? comment, List<JSDocTag>? tags]);
  /// updateJSDocComment(node: JSDoc, comment: string | NodeArray<JSDocComment> | undefined, tags: readonly JSDocTag[] | undefined): JSDoc;
  JSDoc updateJSDocComment(JSDoc node, Object? comment, List<JSDocTag>? tags);
  /// createJsxElement(openingElement: JsxOpeningElement, children: readonly JsxChild[], closingElement: JsxClosingElement): JsxElement;
  JsxElement createJsxElement(JsxOpeningElement openingElement, List<JsxChild> children, JsxClosingElement closingElement);
  /// updateJsxElement(node: JsxElement, openingElement: JsxOpeningElement, children: readonly JsxChild[], closingElement: JsxClosingElement): JsxElement;
  JsxElement updateJsxElement(JsxElement node, JsxOpeningElement openingElement, List<JsxChild> children, JsxClosingElement closingElement);
  /// createJsxSelfClosingElement(tagName: JsxTagNameExpression, typeArguments: readonly TypeNode[] | undefined, attributes: JsxAttributes): JsxSelfClosingElement;
  JsxSelfClosingElement createJsxSelfClosingElement(JsxTagNameExpression tagName, List<TypeNode>? typeArguments, JsxAttributes attributes);
  /// updateJsxSelfClosingElement(node: JsxSelfClosingElement, tagName: JsxTagNameExpression, typeArguments: readonly TypeNode[] | undefined, attributes: JsxAttributes): JsxSelfClosingElement;
  JsxSelfClosingElement updateJsxSelfClosingElement(JsxSelfClosingElement node, JsxTagNameExpression tagName, List<TypeNode>? typeArguments, JsxAttributes attributes);
  /// createJsxOpeningElement(tagName: JsxTagNameExpression, typeArguments: readonly TypeNode[] | undefined, attributes: JsxAttributes): JsxOpeningElement;
  JsxOpeningElement createJsxOpeningElement(JsxTagNameExpression tagName, List<TypeNode>? typeArguments, JsxAttributes attributes);
  /// updateJsxOpeningElement(node: JsxOpeningElement, tagName: JsxTagNameExpression, typeArguments: readonly TypeNode[] | undefined, attributes: JsxAttributes): JsxOpeningElement;
  JsxOpeningElement updateJsxOpeningElement(JsxOpeningElement node, JsxTagNameExpression tagName, List<TypeNode>? typeArguments, JsxAttributes attributes);
  /// createJsxClosingElement(tagName: JsxTagNameExpression): JsxClosingElement;
  JsxClosingElement createJsxClosingElement(JsxTagNameExpression tagName);
  /// updateJsxClosingElement(node: JsxClosingElement, tagName: JsxTagNameExpression): JsxClosingElement;
  JsxClosingElement updateJsxClosingElement(JsxClosingElement node, JsxTagNameExpression tagName);
  /// createJsxFragment(openingFragment: JsxOpeningFragment, children: readonly JsxChild[], closingFragment: JsxClosingFragment): JsxFragment;
  JsxFragment createJsxFragment(JsxOpeningFragment openingFragment, List<JsxChild> children, JsxClosingFragment closingFragment);
  /// createJsxText(text: string, containsOnlyTriviaWhiteSpaces?: boolean): JsxText;
  JsxText createJsxText(String text, [bool? containsOnlyTriviaWhiteSpaces]);
  /// updateJsxText(node: JsxText, text: string, containsOnlyTriviaWhiteSpaces?: boolean): JsxText;
  JsxText updateJsxText(JsxText node, String text, [bool? containsOnlyTriviaWhiteSpaces]);
  /// createJsxOpeningFragment(): JsxOpeningFragment;
  JsxOpeningFragment createJsxOpeningFragment();
  /// createJsxJsxClosingFragment(): JsxClosingFragment;
  JsxClosingFragment createJsxJsxClosingFragment();
  /// updateJsxFragment(node: JsxFragment, openingFragment: JsxOpeningFragment, children: readonly JsxChild[], closingFragment: JsxClosingFragment): JsxFragment;
  JsxFragment updateJsxFragment(JsxFragment node, JsxOpeningFragment openingFragment, List<JsxChild> children, JsxClosingFragment closingFragment);
  /// createJsxAttribute(name: JsxAttributeName, initializer: JsxAttributeValue | undefined): JsxAttribute;
  JsxAttribute createJsxAttribute(JsxAttributeName name, JsxAttributeValue? initializer);
  /// updateJsxAttribute(node: JsxAttribute, name: JsxAttributeName, initializer: JsxAttributeValue | undefined): JsxAttribute;
  JsxAttribute updateJsxAttribute(JsxAttribute node, JsxAttributeName name, JsxAttributeValue? initializer);
  /// createJsxAttributes(properties: readonly JsxAttributeLike[]): JsxAttributes;
  JsxAttributes createJsxAttributes(List<JsxAttributeLike> properties);
  /// updateJsxAttributes(node: JsxAttributes, properties: readonly JsxAttributeLike[]): JsxAttributes;
  JsxAttributes updateJsxAttributes(JsxAttributes node, List<JsxAttributeLike> properties);
  /// createJsxSpreadAttribute(expression: Expression): JsxSpreadAttribute;
  JsxSpreadAttribute createJsxSpreadAttribute(Expression expression);
  /// updateJsxSpreadAttribute(node: JsxSpreadAttribute, expression: Expression): JsxSpreadAttribute;
  JsxSpreadAttribute updateJsxSpreadAttribute(JsxSpreadAttribute node, Expression expression);
  /// createJsxExpression(dotDotDotToken: DotDotDotToken | undefined, expression: Expression | undefined): JsxExpression;
  JsxExpression createJsxExpression(DotDotDotToken? dotDotDotToken, Expression? expression);
  /// updateJsxExpression(node: JsxExpression, expression: Expression | undefined): JsxExpression;
  JsxExpression updateJsxExpression(JsxExpression node, Expression? expression);
  /// createJsxNamespacedName(namespace: Identifier, name: Identifier): JsxNamespacedName;
  JsxNamespacedName createJsxNamespacedName(Identifier namespace, Identifier name);
  /// updateJsxNamespacedName(node: JsxNamespacedName, namespace: Identifier, name: Identifier): JsxNamespacedName;
  JsxNamespacedName updateJsxNamespacedName(JsxNamespacedName node, Identifier namespace, Identifier name);
  /// createCaseClause(expression: Expression, statements: readonly Statement[]): CaseClause;
  CaseClause createCaseClause(Expression expression, List<Statement> statements);
  /// updateCaseClause(node: CaseClause, expression: Expression, statements: readonly Statement[]): CaseClause;
  CaseClause updateCaseClause(CaseClause node, Expression expression, List<Statement> statements);
  /// createDefaultClause(statements: readonly Statement[]): DefaultClause;
  DefaultClause createDefaultClause(List<Statement> statements);
  /// updateDefaultClause(node: DefaultClause, statements: readonly Statement[]): DefaultClause;
  DefaultClause updateDefaultClause(DefaultClause node, List<Statement> statements);
  /// createHeritageClause(token: HeritageClause["token"], types: readonly ExpressionWithTypeArguments[]): HeritageClause;
  HeritageClause createHeritageClause(Object? token, List<ExpressionWithTypeArguments> types);
  /// updateHeritageClause(node: HeritageClause, types: readonly ExpressionWithTypeArguments[]): HeritageClause;
  HeritageClause updateHeritageClause(HeritageClause node, List<ExpressionWithTypeArguments> types);
  /// createCatchClause(variableDeclaration: string | BindingName | VariableDeclaration | undefined, block: Block): CatchClause;
  CatchClause createCatchClause(Object? variableDeclaration, Block block);
  /// updateCatchClause(node: CatchClause, variableDeclaration: VariableDeclaration | undefined, block: Block): CatchClause;
  CatchClause updateCatchClause(CatchClause node, VariableDeclaration? variableDeclaration, Block block);
  /// createPropertyAssignment(name: string | PropertyName, initializer: Expression): PropertyAssignment;
  PropertyAssignment createPropertyAssignment(Object? name, Expression initializer);
  /// updatePropertyAssignment(node: PropertyAssignment, name: PropertyName, initializer: Expression): PropertyAssignment;
  PropertyAssignment updatePropertyAssignment(PropertyAssignment node, PropertyName name, Expression initializer);
  /// createShorthandPropertyAssignment(name: string | Identifier, objectAssignmentInitializer?: Expression): ShorthandPropertyAssignment;
  ShorthandPropertyAssignment createShorthandPropertyAssignment(Object? name, [Expression? objectAssignmentInitializer]);
  /// updateShorthandPropertyAssignment(node: ShorthandPropertyAssignment, name: Identifier, objectAssignmentInitializer: Expression | undefined): ShorthandPropertyAssignment;
  ShorthandPropertyAssignment updateShorthandPropertyAssignment(ShorthandPropertyAssignment node, Identifier name, Expression? objectAssignmentInitializer);
  /// createSpreadAssignment(expression: Expression): SpreadAssignment;
  SpreadAssignment createSpreadAssignment(Expression expression);
  /// updateSpreadAssignment(node: SpreadAssignment, expression: Expression): SpreadAssignment;
  SpreadAssignment updateSpreadAssignment(SpreadAssignment node, Expression expression);
  /// createEnumMember(name: string | PropertyName, initializer?: Expression): EnumMember;
  EnumMember createEnumMember(Object? name, [Expression? initializer]);
  /// updateEnumMember(node: EnumMember, name: PropertyName, initializer: Expression | undefined): EnumMember;
  EnumMember updateEnumMember(EnumMember node, PropertyName name, Expression? initializer);
  /// createSourceFile(statements: readonly Statement[], endOfFileToken: EndOfFileToken, flags: NodeFlags): SourceFile;
  SourceFile createSourceFile(List<Statement> statements, EndOfFileToken endOfFileToken, NodeFlags flags);
  /// updateSourceFile(node: SourceFile, statements: readonly Statement[], isDeclarationFile?: boolean, referencedFiles?: readonly FileReference[], typeReferences?: readonly FileReference[], hasNoDefaultLib?: boolean, libReferences?: readonly FileReference[]): SourceFile;
  SourceFile updateSourceFile(SourceFile node, List<Statement> statements, [bool? isDeclarationFile, List<FileReference>? referencedFiles, List<FileReference>? typeReferences, bool? hasNoDefaultLib, List<FileReference>? libReferences]);
  /// createNotEmittedStatement(original: Node): NotEmittedStatement;
  NotEmittedStatement createNotEmittedStatement(Node original);
  /// createNotEmittedTypeElement(): NotEmittedTypeElement;
  NotEmittedTypeElement createNotEmittedTypeElement();
  /// createPartiallyEmittedExpression(expression: Expression, original?: Node): PartiallyEmittedExpression;
  PartiallyEmittedExpression createPartiallyEmittedExpression(Expression expression, [Node? original]);
  /// updatePartiallyEmittedExpression(node: PartiallyEmittedExpression, expression: Expression): PartiallyEmittedExpression;
  PartiallyEmittedExpression updatePartiallyEmittedExpression(PartiallyEmittedExpression node, Expression expression);
  /// createCommaListExpression(elements: readonly Expression[]): CommaListExpression;
  CommaListExpression createCommaListExpression(List<Expression> elements);
  /// updateCommaListExpression(node: CommaListExpression, elements: readonly Expression[]): CommaListExpression;
  CommaListExpression updateCommaListExpression(CommaListExpression node, List<Expression> elements);
  /// createBundle(sourceFiles: readonly SourceFile[]): Bundle;
  Bundle createBundle(List<SourceFile> sourceFiles);
  /// updateBundle(node: Bundle, sourceFiles: readonly SourceFile[]): Bundle;
  Bundle updateBundle(Bundle node, List<SourceFile> sourceFiles);
  /// createComma(left: Expression, right: Expression): BinaryExpression;
  BinaryExpression createComma(Expression left, Expression right);
  /// createAssignment(left: ObjectLiteralExpression | ArrayLiteralExpression, right: Expression): DestructuringAssignment;
  DestructuringAssignment createAssignment(Object? left, Expression right);
  /// createAssignment(left: Expression, right: Expression): AssignmentExpression<EqualsToken>;
  AssignmentExpression<EqualsToken> createAssignment$1(Expression left, Expression right);
  /// createLogicalOr(left: Expression, right: Expression): BinaryExpression;
  BinaryExpression createLogicalOr(Expression left, Expression right);
  /// createLogicalAnd(left: Expression, right: Expression): BinaryExpression;
  BinaryExpression createLogicalAnd(Expression left, Expression right);
  /// createBitwiseOr(left: Expression, right: Expression): BinaryExpression;
  BinaryExpression createBitwiseOr(Expression left, Expression right);
  /// createBitwiseXor(left: Expression, right: Expression): BinaryExpression;
  BinaryExpression createBitwiseXor(Expression left, Expression right);
  /// createBitwiseAnd(left: Expression, right: Expression): BinaryExpression;
  BinaryExpression createBitwiseAnd(Expression left, Expression right);
  /// createStrictEquality(left: Expression, right: Expression): BinaryExpression;
  BinaryExpression createStrictEquality(Expression left, Expression right);
  /// createStrictInequality(left: Expression, right: Expression): BinaryExpression;
  BinaryExpression createStrictInequality(Expression left, Expression right);
  /// createEquality(left: Expression, right: Expression): BinaryExpression;
  BinaryExpression createEquality(Expression left, Expression right);
  /// createInequality(left: Expression, right: Expression): BinaryExpression;
  BinaryExpression createInequality(Expression left, Expression right);
  /// createLessThan(left: Expression, right: Expression): BinaryExpression;
  BinaryExpression createLessThan(Expression left, Expression right);
  /// createLessThanEquals(left: Expression, right: Expression): BinaryExpression;
  BinaryExpression createLessThanEquals(Expression left, Expression right);
  /// createGreaterThan(left: Expression, right: Expression): BinaryExpression;
  BinaryExpression createGreaterThan(Expression left, Expression right);
  /// createGreaterThanEquals(left: Expression, right: Expression): BinaryExpression;
  BinaryExpression createGreaterThanEquals(Expression left, Expression right);
  /// createLeftShift(left: Expression, right: Expression): BinaryExpression;
  BinaryExpression createLeftShift(Expression left, Expression right);
  /// createRightShift(left: Expression, right: Expression): BinaryExpression;
  BinaryExpression createRightShift(Expression left, Expression right);
  /// createUnsignedRightShift(left: Expression, right: Expression): BinaryExpression;
  BinaryExpression createUnsignedRightShift(Expression left, Expression right);
  /// createAdd(left: Expression, right: Expression): BinaryExpression;
  BinaryExpression createAdd(Expression left, Expression right);
  /// createSubtract(left: Expression, right: Expression): BinaryExpression;
  BinaryExpression createSubtract(Expression left, Expression right);
  /// createMultiply(left: Expression, right: Expression): BinaryExpression;
  BinaryExpression createMultiply(Expression left, Expression right);
  /// createDivide(left: Expression, right: Expression): BinaryExpression;
  BinaryExpression createDivide(Expression left, Expression right);
  /// createModulo(left: Expression, right: Expression): BinaryExpression;
  BinaryExpression createModulo(Expression left, Expression right);
  /// createExponent(left: Expression, right: Expression): BinaryExpression;
  BinaryExpression createExponent(Expression left, Expression right);
  /// createPrefixPlus(operand: Expression): PrefixUnaryExpression;
  PrefixUnaryExpression createPrefixPlus(Expression operand);
  /// createPrefixMinus(operand: Expression): PrefixUnaryExpression;
  PrefixUnaryExpression createPrefixMinus(Expression operand);
  /// createPrefixIncrement(operand: Expression): PrefixUnaryExpression;
  PrefixUnaryExpression createPrefixIncrement(Expression operand);
  /// createPrefixDecrement(operand: Expression): PrefixUnaryExpression;
  PrefixUnaryExpression createPrefixDecrement(Expression operand);
  /// createBitwiseNot(operand: Expression): PrefixUnaryExpression;
  PrefixUnaryExpression createBitwiseNot(Expression operand);
  /// createLogicalNot(operand: Expression): PrefixUnaryExpression;
  PrefixUnaryExpression createLogicalNot(Expression operand);
  /// createPostfixIncrement(operand: Expression): PostfixUnaryExpression;
  PostfixUnaryExpression createPostfixIncrement(Expression operand);
  /// createPostfixDecrement(operand: Expression): PostfixUnaryExpression;
  PostfixUnaryExpression createPostfixDecrement(Expression operand);
  /// createImmediatelyInvokedFunctionExpression(statements: readonly Statement[]): CallExpression;
  CallExpression createImmediatelyInvokedFunctionExpression(List<Statement> statements);
  /// createImmediatelyInvokedFunctionExpression(statements: readonly Statement[], param: ParameterDeclaration, paramValue: Expression): CallExpression;
  CallExpression createImmediatelyInvokedFunctionExpression$1(List<Statement> statements, ParameterDeclaration param, Expression paramValue);
  /// createImmediatelyInvokedArrowFunction(statements: readonly Statement[]): ImmediatelyInvokedArrowFunction;
  ImmediatelyInvokedArrowFunction createImmediatelyInvokedArrowFunction(List<Statement> statements);
  /// createImmediatelyInvokedArrowFunction(statements: readonly Statement[], param: ParameterDeclaration, paramValue: Expression): ImmediatelyInvokedArrowFunction;
  ImmediatelyInvokedArrowFunction createImmediatelyInvokedArrowFunction$1(List<Statement> statements, ParameterDeclaration param, Expression paramValue);
  /// createVoidZero(): VoidExpression;
  VoidExpression createVoidZero();
  /// createExportDefault(expression: Expression): ExportAssignment;
  ExportAssignment createExportDefault(Expression expression);
  /// createExternalModuleExport(exportName: Identifier): ExportDeclaration;
  ExportDeclaration createExternalModuleExport(Identifier exportName);
  /// restoreOuterExpressions(outerExpression: Expression | undefined, innerExpression: Expression, kinds?: OuterExpressionKinds): Expression;
  Expression restoreOuterExpressions(Expression? outerExpression, Expression innerExpression, [OuterExpressionKinds? kinds]);
  /// replaceModifiers<T extends HasModifiers>(node: T, modifiers: readonly Modifier[] | ModifierFlags | undefined): T;
  T replaceModifiers<T>(T node, Object? modifiers);
  /// replaceDecoratorsAndModifiers<T extends HasModifiers & HasDecorators>(node: T, modifiers: readonly ModifierLike[] | undefined): T;
  T replaceDecoratorsAndModifiers<T>(T node, List<ModifierLike>? modifiers);
  /// replacePropertyName<T extends AccessorDeclaration | MethodDeclaration | MethodSignature | PropertyDeclaration | PropertySignature | PropertyAssignment>(node: T, name: T["name"]): T;
  T replacePropertyName<T>(T node, Object? name);
}

/// interface CoreTransformationContext
abstract class CoreTransformationContext {
  /// factory: NodeFactory
  NodeFactory get factory_;
  /// getCompilerOptions(): CompilerOptions;
  CompilerOptions getCompilerOptions();
  /// startLexicalEnvironment(): void;
  void startLexicalEnvironment();
  /// suspendLexicalEnvironment(): void;
  void suspendLexicalEnvironment();
  /// resumeLexicalEnvironment(): void;
  void resumeLexicalEnvironment();
  /// endLexicalEnvironment(): Statement[] | undefined;
  List<Statement>? endLexicalEnvironment();
  /// hoistFunctionDeclaration(node: FunctionDeclaration): void;
  void hoistFunctionDeclaration(FunctionDeclaration node);
  /// hoistVariableDeclaration(node: Identifier): void;
  void hoistVariableDeclaration(Identifier node);
}

/// interface TransformationContext extends CoreTransformationContext
abstract class TransformationContext {
  /// requestEmitHelper(helper: EmitHelper): void;
  void requestEmitHelper(EmitHelper helper);
  /// readEmitHelpers(): EmitHelper[] | undefined;
  List<EmitHelper>? readEmitHelpers();
  /// enableSubstitution(kind: SyntaxKind): void;
  void enableSubstitution(SyntaxKind kind);
  /// isSubstitutionEnabled(node: Node): boolean;
  bool isSubstitutionEnabled(Node node);
  /// onSubstituteNode: (hint: EmitHint, node: Node) => Node
  Object? Function(Object?) get onSubstituteNode;
  /// enableEmitNotification(kind: SyntaxKind): void;
  void enableEmitNotification(SyntaxKind kind);
  /// isEmitNotificationEnabled(node: Node): boolean;
  bool isEmitNotificationEnabled(Node node);
  /// onEmitNode: (hint: EmitHint, node: Node, emitCallback: (hint: EmitHint, node: Node) => void) => void
  Object? Function(Object?) get onEmitNode;
}

/// interface TransformationResult
abstract class TransformationResult<T> {
  /// transformed: T[]
  List<T> get transformed;
  /// optional diagnostics: DiagnosticWithLocation[]
  List<DiagnosticWithLocation>? get diagnostics;
  /// substituteNode(hint: EmitHint, node: Node): Node;
  Node substituteNode(EmitHint hint, Node node);
  /// emitNodeWithNotification(hint: EmitHint, node: Node, emitCallback: (hint: EmitHint, node: Node) => void): void;
  void emitNodeWithNotification(EmitHint hint, Node node, Object? Function(Object?) emitCallback);
  /// isEmitNotificationEnabled?(node: Node): boolean;
  bool isEmitNotificationEnabled(Node node);
  /// dispose(): void;
  void dispose();
}

/// interface NodeVisitor
abstract class NodeVisitor {
  /// call signature: <TIn extends Node | undefined, TVisited extends Node | undefined, TOut extends Node>(node: TIn, visitor: Visitor<NonNullable<TIn>, TVisited>, test: (node: Node) => node is TOut, lift?: (node: readonly Node[]) => Node): TOut | (TIn & undefined) | (TVisited & undefined);
  Object? call<TIn, TVisited, TOut>(TIn node, Visitor<TIn, TVisited> visitor, Object? Function(Object?) test, [Object? Function(Object?)? lift]);
  /// call signature: <TIn extends Node | undefined, TVisited extends Node | undefined>(node: TIn, visitor: Visitor<NonNullable<TIn>, TVisited>, test?: (node: Node) => boolean, lift?: (node: readonly Node[]) => Node): Node | (TIn & undefined) | (TVisited & undefined);
  Object? call$1<TIn, TVisited>(TIn node, Visitor<TIn, TVisited> visitor, [Object? Function(Object?)? test, Object? Function(Object?)? lift]);
}

/// interface NodesVisitor
abstract class NodesVisitor {
  /// call signature: <TIn extends Node, TInArray extends NodeArray<TIn> | undefined, TOut extends Node>(nodes: TInArray, visitor: Visitor<TIn, Node | undefined>, test: (node: Node) => node is TOut, start?: number, count?: number): NodeArray<TOut> | (TInArray & undefined);
  Object? call<TIn, TInArray, TOut>(TInArray nodes, Visitor<TIn, Node?> visitor, Object? Function(Object?) test, [num? start, num? count]);
  /// call signature: <TIn extends Node, TInArray extends NodeArray<TIn> | undefined>(nodes: TInArray, visitor: Visitor<TIn, Node | undefined>, test?: (node: Node) => boolean, start?: number, count?: number): NodeArray<Node> | (TInArray & undefined);
  Object? call$1<TIn, TInArray>(TInArray nodes, Visitor<TIn, Node?> visitor, [Object? Function(Object?)? test, num? start, num? count]);
}

/// interface Printer
abstract class Printer {
  /// printNode(hint: EmitHint, node: Node, sourceFile: SourceFile): string;
  String printNode(EmitHint hint, Node node, SourceFile sourceFile);
  /// printList<T extends Node>(format: ListFormat, list: NodeArray<T>, sourceFile: SourceFile): string;
  String printList<T>(ListFormat format, NodeArray<T> list, SourceFile sourceFile);
  /// printFile(sourceFile: SourceFile): string;
  String printFile(SourceFile sourceFile);
  /// printBundle(bundle: Bundle): string;
  String printBundle(Bundle bundle);
}

/// interface PrintHandlers
abstract class PrintHandlers {
  /// hasGlobalName?(name: string): boolean;
  bool hasGlobalName(String name);
  /// onEmitNode?(hint: EmitHint, node: Node, emitCallback: (hint: EmitHint, node: Node) => void): void;
  void onEmitNode(EmitHint hint, Node node, Object? Function(Object?) emitCallback);
  /// isEmitNotificationEnabled?(node: Node): boolean;
  bool isEmitNotificationEnabled(Node node);
  /// substituteNode?(hint: EmitHint, node: Node): Node;
  Node substituteNode(EmitHint hint, Node node);
}

/// interface PrinterOptions
abstract class PrinterOptions {
  /// optional removeComments: boolean
  bool? get removeComments;
  /// optional newLine: NewLineKind
  NewLineKind? get newLine;
  /// optional omitTrailingSemicolon: boolean
  bool? get omitTrailingSemicolon;
  /// optional noEmitHelpers: boolean
  bool? get noEmitHelpers;
}

/// interface GetEffectiveTypeRootsHost
abstract class GetEffectiveTypeRootsHost {
  /// getCurrentDirectory?(): string;
  String getCurrentDirectory();
}

/// interface TextSpan
abstract class TextSpan {
  /// start: number
  num get start;
  /// length: number
  num get length;
}

/// interface TextChangeRange
abstract class TextChangeRange {
  /// span: TextSpan
  TextSpan get span;
  /// newLength: number
  num get newLength;
}

/// interface SyntaxList extends Node
abstract class SyntaxList {
  /// kind: SyntaxKind.SyntaxList
  SyntaxKind get kind;
}

/// interface UserPreferences
abstract class UserPreferences {
  /// optional disableSuggestions: boolean
  bool? get disableSuggestions;
  /// optional quotePreference: "auto" | "double" | "single"
  Object? get quotePreference;
  /// optional includeCompletionsForModuleExports: boolean
  bool? get includeCompletionsForModuleExports;
  /// optional includeCompletionsForImportStatements: boolean
  bool? get includeCompletionsForImportStatements;
  /// optional includeCompletionsWithSnippetText: boolean
  bool? get includeCompletionsWithSnippetText;
  /// optional includeAutomaticOptionalChainCompletions: boolean
  bool? get includeAutomaticOptionalChainCompletions;
  /// optional includeCompletionsWithInsertText: boolean
  bool? get includeCompletionsWithInsertText;
  /// optional includeCompletionsWithClassMemberSnippets: boolean
  bool? get includeCompletionsWithClassMemberSnippets;
  /// optional includeCompletionsWithObjectLiteralMethodSnippets: boolean
  bool? get includeCompletionsWithObjectLiteralMethodSnippets;
  /// optional useLabelDetailsInCompletionEntries: boolean
  bool? get useLabelDetailsInCompletionEntries;
  /// optional allowIncompleteCompletions: boolean
  bool? get allowIncompleteCompletions;
  /// optional importModuleSpecifierPreference: "shortest" | "project-relative" | "relative" | "non-relative"
  Object? get importModuleSpecifierPreference;
  /// optional importModuleSpecifierEnding: "auto" | "minimal" | "index" | "js"
  Object? get importModuleSpecifierEnding;
  /// optional allowTextChangesInNewFiles: boolean
  bool? get allowTextChangesInNewFiles;
  /// optional providePrefixAndSuffixTextForRename: boolean
  bool? get providePrefixAndSuffixTextForRename;
  /// optional includePackageJsonAutoImports: "auto" | "on" | "off"
  Object? get includePackageJsonAutoImports;
  /// optional provideRefactorNotApplicableReason: boolean
  bool? get provideRefactorNotApplicableReason;
  /// optional jsxAttributeCompletionStyle: "auto" | "braces" | "none"
  Object? get jsxAttributeCompletionStyle;
  /// optional includeInlayParameterNameHints: "none" | "literals" | "all"
  Object? get includeInlayParameterNameHints;
  /// optional includeInlayParameterNameHintsWhenArgumentMatchesName: boolean
  bool? get includeInlayParameterNameHintsWhenArgumentMatchesName;
  /// optional includeInlayFunctionParameterTypeHints: boolean
  bool? get includeInlayFunctionParameterTypeHints;
  /// optional includeInlayVariableTypeHints: boolean
  bool? get includeInlayVariableTypeHints;
  /// optional includeInlayVariableTypeHintsWhenTypeMatchesName: boolean
  bool? get includeInlayVariableTypeHintsWhenTypeMatchesName;
  /// optional includeInlayPropertyDeclarationTypeHints: boolean
  bool? get includeInlayPropertyDeclarationTypeHints;
  /// optional includeInlayFunctionLikeReturnTypeHints: boolean
  bool? get includeInlayFunctionLikeReturnTypeHints;
  /// optional includeInlayEnumMemberValueHints: boolean
  bool? get includeInlayEnumMemberValueHints;
  /// optional interactiveInlayHints: boolean
  bool? get interactiveInlayHints;
  /// optional allowRenameOfImportPath: boolean
  bool? get allowRenameOfImportPath;
  /// optional autoImportFileExcludePatterns: string[]
  List<String>? get autoImportFileExcludePatterns;
  /// optional autoImportSpecifierExcludeRegexes: string[]
  List<String>? get autoImportSpecifierExcludeRegexes;
  /// optional preferTypeOnlyAutoImports: boolean
  bool? get preferTypeOnlyAutoImports;
  /// optional organizeImportsIgnoreCase: "auto" | boolean
  Object? get organizeImportsIgnoreCase;
  /// optional organizeImportsCollation: "ordinal" | "unicode"
  Object? get organizeImportsCollation;
  /// optional organizeImportsLocale: string
  String? get organizeImportsLocale;
  /// optional organizeImportsNumericCollation: boolean
  bool? get organizeImportsNumericCollation;
  /// optional organizeImportsAccentCollation: boolean
  bool? get organizeImportsAccentCollation;
  /// optional organizeImportsCaseFirst: "upper" | "lower" | false
  Object? get organizeImportsCaseFirst;
  /// optional organizeImportsTypeOrder: OrganizeImportsTypeOrder
  OrganizeImportsTypeOrder? get organizeImportsTypeOrder;
  /// optional excludeLibrarySymbolsInNavTo: boolean
  bool? get excludeLibrarySymbolsInNavTo;
  /// optional lazyConfiguredProjectsFromExternalProject: boolean
  bool? get lazyConfiguredProjectsFromExternalProject;
  /// optional displayPartsForJSDoc: boolean
  bool? get displayPartsForJSDoc;
  /// optional generateReturnInDocTemplate: boolean
  bool? get generateReturnInDocTemplate;
  /// optional disableLineTextInReferences: boolean
  bool? get disableLineTextInReferences;
  /// optional maximumHoverLength: number
  num? get maximumHoverLength;
}

/// interface PseudoBigInt
abstract class PseudoBigInt {
  /// negative: boolean
  bool get negative;
  /// base10Value: string
  String get base10Value;
}

/// interface System
abstract class System {
  /// args: string[]
  List<String> get args;
  /// newLine: string
  String get newLine;
  /// useCaseSensitiveFileNames: boolean
  bool get useCaseSensitiveFileNames;
  /// write(s: string): void;
  void write(String s);
  /// writeOutputIsTTY?(): boolean;
  bool writeOutputIsTTY();
  /// getWidthOfTerminal?(): number;
  num getWidthOfTerminal();
  /// readFile(path: string, encoding?: string): string | undefined;
  String? readFile(String path, [String? encoding]);
  /// getFileSize?(path: string): number;
  num getFileSize(String path);
  /// writeFile(path: string, data: string, writeByteOrderMark?: boolean): void;
  void writeFile(String path, String data, [bool? writeByteOrderMark]);
  /// watchFile?(path: string, callback: FileWatcherCallback, pollingInterval?: number, options?: WatchOptions): FileWatcher;
  FileWatcher watchFile(String path, FileWatcherCallback callback, [num? pollingInterval, WatchOptions? options]);
  /// watchDirectory?(path: string, callback: DirectoryWatcherCallback, recursive?: boolean, options?: WatchOptions): FileWatcher;
  FileWatcher watchDirectory(String path, DirectoryWatcherCallback callback, [bool? recursive, WatchOptions? options]);
  /// resolvePath(path: string): string;
  String resolvePath(String path);
  /// fileExists(path: string): boolean;
  bool fileExists(String path);
  /// directoryExists(path: string): boolean;
  bool directoryExists(String path);
  /// createDirectory(path: string): void;
  void createDirectory(String path);
  /// getExecutingFilePath(): string;
  String getExecutingFilePath();
  /// getCurrentDirectory(): string;
  String getCurrentDirectory();
  /// getDirectories(path: string): string[];
  List<String> getDirectories(String path);
  /// readDirectory(path: string, extensions?: readonly string[], exclude?: readonly string[], include?: readonly string[], depth?: number): string[];
  List<String> readDirectory(String path, [List<String>? extensions, List<String>? exclude, List<String>? include, num? depth]);
  /// getModifiedTime?(path: string): Date | undefined;
  Object? getModifiedTime(String path);
  /// setModifiedTime?(path: string, time: Date): void;
  void setModifiedTime(String path, Object? time);
  /// deleteFile?(path: string): void;
  void deleteFile(String path);
  /// createHash?(data: string): string;
  String createHash(String data);
  /// createSHA256Hash?(data: string): string;
  String createSHA256Hash(String data);
  /// getMemoryUsage?(): number;
  num getMemoryUsage();
  /// exit(exitCode?: number): void;
  void exit([num? exitCode]);
  /// realpath?(path: string): string;
  String realpath(String path);
  /// setTimeout?(callback: (...args: any[]) => void, ms: number, ...args: any[]): any;
  Object? setTimeout(Object? Function(Object?) callback, num ms, List<Object?> args);
  /// clearTimeout?(timeoutId: any): void;
  void clearTimeout(Object? timeoutId);
  /// clearScreen?(): void;
  void clearScreen();
  /// base64decode?(input: string): string;
  String base64decode(String input);
  /// base64encode?(input: string): string;
  String base64encode(String input);
}

/// interface FileWatcher
abstract class FileWatcher {
  /// close(): void;
  void close();
}

/// interface Scanner
abstract class Scanner {
  /// getStartPos(): number;
  num getStartPos();
  /// getToken(): SyntaxKind;
  SyntaxKind getToken();
  /// getTokenFullStart(): number;
  num getTokenFullStart();
  /// getTokenStart(): number;
  num getTokenStart();
  /// getTokenEnd(): number;
  num getTokenEnd();
  /// getTextPos(): number;
  num getTextPos();
  /// getTokenPos(): number;
  num getTokenPos();
  /// getTokenText(): string;
  String getTokenText();
  /// getTokenValue(): string;
  String getTokenValue();
  /// hasUnicodeEscape(): boolean;
  bool hasUnicodeEscape();
  /// hasExtendedUnicodeEscape(): boolean;
  bool hasExtendedUnicodeEscape();
  /// hasPrecedingLineBreak(): boolean;
  bool hasPrecedingLineBreak();
  /// isIdentifier(): boolean;
  bool isIdentifier();
  /// isReservedWord(): boolean;
  bool isReservedWord();
  /// isUnterminated(): boolean;
  bool isUnterminated();
  /// reScanGreaterToken(): SyntaxKind;
  SyntaxKind reScanGreaterToken();
  /// reScanSlashToken(): SyntaxKind;
  SyntaxKind reScanSlashToken();
  /// reScanAsteriskEqualsToken(): SyntaxKind;
  SyntaxKind reScanAsteriskEqualsToken();
  /// reScanTemplateToken(isTaggedTemplate: boolean): SyntaxKind;
  SyntaxKind reScanTemplateToken(bool isTaggedTemplate);
  /// reScanTemplateHeadOrNoSubstitutionTemplate(): SyntaxKind;
  SyntaxKind reScanTemplateHeadOrNoSubstitutionTemplate();
  /// scanJsxIdentifier(): SyntaxKind;
  SyntaxKind scanJsxIdentifier();
  /// scanJsxAttributeValue(): SyntaxKind;
  SyntaxKind scanJsxAttributeValue();
  /// reScanJsxAttributeValue(): SyntaxKind;
  SyntaxKind reScanJsxAttributeValue();
  /// reScanJsxToken(allowMultilineJsxText?: boolean): JsxTokenSyntaxKind;
  JsxTokenSyntaxKind reScanJsxToken([bool? allowMultilineJsxText]);
  /// reScanLessThanToken(): SyntaxKind;
  SyntaxKind reScanLessThanToken();
  /// reScanHashToken(): SyntaxKind;
  SyntaxKind reScanHashToken();
  /// reScanQuestionToken(): SyntaxKind;
  SyntaxKind reScanQuestionToken();
  /// reScanInvalidIdentifier(): SyntaxKind;
  SyntaxKind reScanInvalidIdentifier();
  /// scanJsxToken(): JsxTokenSyntaxKind;
  JsxTokenSyntaxKind scanJsxToken();
  /// scanJsDocToken(): JSDocSyntaxKind;
  JSDocSyntaxKind scanJsDocToken();
  /// scan(): SyntaxKind;
  SyntaxKind scan();
  /// getText(): string;
  String getText();
  /// setText(text: string | undefined, start?: number, length?: number): void;
  void setText(String? text, [num? start, num? length]);
  /// setOnError(onError: ErrorCallback | undefined): void;
  void setOnError(ErrorCallback? onError);
  /// setScriptTarget(scriptTarget: ScriptTarget): void;
  void setScriptTarget(ScriptTarget scriptTarget);
  /// setLanguageVariant(variant: LanguageVariant): void;
  void setLanguageVariant(LanguageVariant variant);
  /// setScriptKind(scriptKind: ScriptKind): void;
  void setScriptKind(ScriptKind scriptKind);
  /// setJSDocParsingMode(kind: JSDocParsingMode): void;
  void setJSDocParsingMode(JSDocParsingMode kind);
  /// setTextPos(textPos: number): void;
  void setTextPos(num textPos);
  /// resetTokenState(pos: number): void;
  void resetTokenState(num pos);
  /// lookAhead<T>(callback: () => T): T;
  T lookAhead<T>(Object? Function(Object?) callback);
  /// scanRange<T>(start: number, length: number, callback: () => T): T;
  T scanRange<T>(num start, num length, Object? Function(Object?) callback);
  /// tryScan<T>(callback: () => T): T;
  T tryScan<T>(Object? Function(Object?) callback);
}

/// interface CreateSourceFileOptions
abstract class CreateSourceFileOptions {
  /// languageVersion: ScriptTarget
  ScriptTarget get languageVersion;
  /// optional impliedNodeFormat: ResolutionMode
  ResolutionMode? get impliedNodeFormat;
  /// optional setExternalModuleIndicator: (file: SourceFile) => void
  Object? Function(Object?)? get setExternalModuleIndicator;
  /// optional jsDocParsingMode: JSDocParsingMode
  JSDocParsingMode? get jsDocParsingMode;
}

/// interface ParsedBuildCommand
abstract class ParsedBuildCommand {
  /// buildOptions: BuildOptions
  BuildOptions get buildOptions;
  /// watchOptions: WatchOptions | undefined
  WatchOptions? get watchOptions;
  /// projects: string[]
  List<String> get projects;
  /// errors: Diagnostic[]
  List<Diagnostic> get errors;
}

/// interface ConfigFileDiagnosticsReporter
abstract class ConfigFileDiagnosticsReporter {
  /// onUnRecoverableConfigFileDiagnostic: DiagnosticReporter
  DiagnosticReporter get onUnRecoverableConfigFileDiagnostic;
}

/// interface ParseConfigFileHost extends ParseConfigHost, ConfigFileDiagnosticsReporter
abstract class ParseConfigFileHost {
  /// getCurrentDirectory(): string;
  String getCurrentDirectory();
}

/// interface ParsedTsconfig
abstract class ParsedTsconfig {
  /// raw: any
  Object? get raw;
  /// optional options: CompilerOptions
  CompilerOptions? get options;
  /// optional watchOptions: WatchOptions
  WatchOptions? get watchOptions;
  /// optional typeAcquisition: TypeAcquisition
  TypeAcquisition? get typeAcquisition;
  /// optional extendedConfigPath: string | string[]
  Object? get extendedConfigPath;
}

/// interface ExtendedConfigCacheEntry
abstract class ExtendedConfigCacheEntry {
  /// extendedResult: TsConfigSourceFile
  TsConfigSourceFile get extendedResult;
  /// extendedConfig: ParsedTsconfig | undefined
  ParsedTsconfig? get extendedConfig;
}

/// interface TypeReferenceDirectiveResolutionCache extends PerDirectoryResolutionCache<ResolvedTypeReferenceDirectiveWithFailedLookupLocations>, NonRelativeNameResolutionCache<ResolvedTypeReferenceDirectiveWithFailedLookupLocations>, PackageJsonInfoCache
abstract class TypeReferenceDirectiveResolutionCache {
}

/// interface ModeAwareCache
abstract class ModeAwareCache<T> {
  /// get(key: string, mode: ResolutionMode): T | undefined;
  T? get_(String key, ResolutionMode mode);
  /// set(key: string, mode: ResolutionMode, value: T): this;
  Object? set_(String key, ResolutionMode mode, T value);
  /// delete(key: string, mode: ResolutionMode): this;
  Object? delete(String key, ResolutionMode mode);
  /// has(key: string, mode: ResolutionMode): boolean;
  bool has(String key, ResolutionMode mode);
  /// forEach(cb: (elem: T, key: string, mode: ResolutionMode) => void): void;
  void forEach(Object? Function(Object?) cb);
  /// size(): number;
  num size();
}

/// interface PerDirectoryResolutionCache
abstract class PerDirectoryResolutionCache<T> {
  /// getFromDirectoryCache(name: string, mode: ResolutionMode, directoryName: string, redirectedReference: ResolvedProjectReference | undefined): T | undefined;
  T? getFromDirectoryCache(String name, ResolutionMode mode, String directoryName, ResolvedProjectReference? redirectedReference);
  /// getOrCreateCacheForDirectory(directoryName: string, redirectedReference?: ResolvedProjectReference): ModeAwareCache<T>;
  ModeAwareCache<T> getOrCreateCacheForDirectory(String directoryName, [ResolvedProjectReference? redirectedReference]);
  /// clear(): void;
  void clear();
  /// update(options: CompilerOptions): void;
  void update(CompilerOptions options);
}

/// interface NonRelativeNameResolutionCache
abstract class NonRelativeNameResolutionCache<T> {
  /// getFromNonRelativeNameCache(nonRelativeName: string, mode: ResolutionMode, directoryName: string, redirectedReference: ResolvedProjectReference | undefined): T | undefined;
  T? getFromNonRelativeNameCache(String nonRelativeName, ResolutionMode mode, String directoryName, ResolvedProjectReference? redirectedReference);
  /// getOrCreateCacheForNonRelativeName(nonRelativeName: string, mode: ResolutionMode, redirectedReference?: ResolvedProjectReference): PerNonRelativeNameCache<T>;
  PerNonRelativeNameCache<T> getOrCreateCacheForNonRelativeName(String nonRelativeName, ResolutionMode mode, [ResolvedProjectReference? redirectedReference]);
  /// clear(): void;
  void clear();
  /// update(options: CompilerOptions): void;
  void update(CompilerOptions options);
}

/// interface PerNonRelativeNameCache
abstract class PerNonRelativeNameCache<T> {
  /// get(directory: string): T | undefined;
  T? get_(String directory);
  /// set(directory: string, result: T): void;
  void set_(String directory, T result);
}

/// interface ModuleResolutionCache extends PerDirectoryResolutionCache<ResolvedModuleWithFailedLookupLocations>, NonRelativeModuleNameResolutionCache, PackageJsonInfoCache
abstract class ModuleResolutionCache {
  /// getPackageJsonInfoCache(): PackageJsonInfoCache;
  PackageJsonInfoCache getPackageJsonInfoCache();
}

/// interface NonRelativeModuleNameResolutionCache extends NonRelativeNameResolutionCache<ResolvedModuleWithFailedLookupLocations>, PackageJsonInfoCache
abstract class NonRelativeModuleNameResolutionCache {
  /// getOrCreateCacheForModuleName(nonRelativeModuleName: string, mode: ResolutionMode, redirectedReference?: ResolvedProjectReference): PerModuleNameCache;
  PerModuleNameCache getOrCreateCacheForModuleName(String nonRelativeModuleName, ResolutionMode mode, [ResolvedProjectReference? redirectedReference]);
}

/// interface PackageJsonInfoCache
abstract class PackageJsonInfoCache {
  /// clear(): void;
  void clear();
}

/// interface FormatDiagnosticsHost
abstract class FormatDiagnosticsHost {
  /// getCurrentDirectory(): string;
  String getCurrentDirectory();
  /// getCanonicalFileName(fileName: string): string;
  String getCanonicalFileName(String fileName);
  /// getNewLine(): string;
  String getNewLine();
}

/// interface EmitOutput
abstract class EmitOutput {
  /// outputFiles: OutputFile[]
  List<OutputFile> get outputFiles;
  /// emitSkipped: boolean
  bool get emitSkipped;
  /// diagnostics: readonly Diagnostic[]
  List<Diagnostic> get diagnostics;
}

/// interface OutputFile
abstract class OutputFile {
  /// name: string
  String get name;
  /// writeByteOrderMark: boolean
  bool get writeByteOrderMark;
  /// text: string
  String get text;
}

/// interface BuilderProgramHost
abstract class BuilderProgramHost {
  /// optional createHash: (data: string) => string
  Object? Function(Object?)? get createHash;
  /// optional writeFile: WriteFileCallback
  WriteFileCallback? get writeFile;
}

/// interface BuilderProgram
abstract class BuilderProgram {
  /// getProgram(): Program;
  Program getProgram();
  /// getCompilerOptions(): CompilerOptions;
  CompilerOptions getCompilerOptions();
  /// getSourceFile(fileName: string): SourceFile | undefined;
  SourceFile? getSourceFile(String fileName);
  /// getSourceFiles(): readonly SourceFile[];
  List<SourceFile> getSourceFiles();
  /// getOptionsDiagnostics(cancellationToken?: CancellationToken): readonly Diagnostic[];
  List<Diagnostic> getOptionsDiagnostics([CancellationToken? cancellationToken]);
  /// getGlobalDiagnostics(cancellationToken?: CancellationToken): readonly Diagnostic[];
  List<Diagnostic> getGlobalDiagnostics([CancellationToken? cancellationToken]);
  /// getConfigFileParsingDiagnostics(): readonly Diagnostic[];
  List<Diagnostic> getConfigFileParsingDiagnostics();
  /// getSyntacticDiagnostics(sourceFile?: SourceFile, cancellationToken?: CancellationToken): readonly Diagnostic[];
  List<Diagnostic> getSyntacticDiagnostics([SourceFile? sourceFile, CancellationToken? cancellationToken]);
  /// getDeclarationDiagnostics(sourceFile?: SourceFile, cancellationToken?: CancellationToken): readonly DiagnosticWithLocation[];
  List<DiagnosticWithLocation> getDeclarationDiagnostics([SourceFile? sourceFile, CancellationToken? cancellationToken]);
  /// getAllDependencies(sourceFile: SourceFile): readonly string[];
  List<String> getAllDependencies(SourceFile sourceFile);
  /// getSemanticDiagnostics(sourceFile?: SourceFile, cancellationToken?: CancellationToken): readonly Diagnostic[];
  List<Diagnostic> getSemanticDiagnostics([SourceFile? sourceFile, CancellationToken? cancellationToken]);
  /// emit(targetSourceFile?: SourceFile, writeFile?: WriteFileCallback, cancellationToken?: CancellationToken, emitOnlyDtsFiles?: boolean, customTransformers?: CustomTransformers): EmitResult;
  EmitResult emit([SourceFile? targetSourceFile, WriteFileCallback? writeFile, CancellationToken? cancellationToken, bool? emitOnlyDtsFiles, CustomTransformers? customTransformers]);
  /// getCurrentDirectory(): string;
  String getCurrentDirectory();
}

/// interface SemanticDiagnosticsBuilderProgram extends BuilderProgram
abstract class SemanticDiagnosticsBuilderProgram {
  /// getSemanticDiagnosticsOfNextAffectedFile(cancellationToken?: CancellationToken, ignoreSourceFile?: (sourceFile: SourceFile) => boolean): AffectedFileResult<readonly Diagnostic[]>;
  AffectedFileResult<List<Diagnostic>> getSemanticDiagnosticsOfNextAffectedFile([CancellationToken? cancellationToken, Object? Function(Object?)? ignoreSourceFile]);
}

/// interface EmitAndSemanticDiagnosticsBuilderProgram extends SemanticDiagnosticsBuilderProgram
abstract class EmitAndSemanticDiagnosticsBuilderProgram {
  /// emitNextAffectedFile(writeFile?: WriteFileCallback, cancellationToken?: CancellationToken, emitOnlyDtsFiles?: boolean, customTransformers?: CustomTransformers): AffectedFileResult<EmitResult>;
  AffectedFileResult<EmitResult> emitNextAffectedFile([WriteFileCallback? writeFile, CancellationToken? cancellationToken, bool? emitOnlyDtsFiles, CustomTransformers? customTransformers]);
}

/// interface ReadBuildProgramHost
abstract class ReadBuildProgramHost {
  /// useCaseSensitiveFileNames(): boolean;
  bool useCaseSensitiveFileNames();
  /// getCurrentDirectory(): string;
  String getCurrentDirectory();
  /// readFile(fileName: string): string | undefined;
  String? readFile(String fileName);
}

/// interface IncrementalProgramOptions
abstract class IncrementalProgramOptions<T> {
  /// rootNames: readonly string[]
  List<String> get rootNames;
  /// options: CompilerOptions
  CompilerOptions get options;
  /// optional configFileParsingDiagnostics: readonly Diagnostic[]
  List<Diagnostic>? get configFileParsingDiagnostics;
  /// optional projectReferences: readonly ProjectReference[]
  List<ProjectReference>? get projectReferences;
  /// optional host: CompilerHost
  CompilerHost? get host;
  /// optional createProgram: CreateProgram<T>
  CreateProgram<T>? get createProgram;
}

/// interface WatchHost
abstract class WatchHost {
  /// onWatchStatusChange?(diagnostic: Diagnostic, newLine: string, options: CompilerOptions, errorCount?: number): void;
  void onWatchStatusChange(Diagnostic diagnostic, String newLine, CompilerOptions options, [num? errorCount]);
  /// watchFile(path: string, callback: FileWatcherCallback, pollingInterval?: number, options?: WatchOptions): FileWatcher;
  FileWatcher watchFile(String path, FileWatcherCallback callback, [num? pollingInterval, WatchOptions? options]);
  /// watchDirectory(path: string, callback: DirectoryWatcherCallback, recursive?: boolean, options?: WatchOptions): FileWatcher;
  FileWatcher watchDirectory(String path, DirectoryWatcherCallback callback, [bool? recursive, WatchOptions? options]);
  /// setTimeout?(callback: (...args: any[]) => void, ms: number, ...args: any[]): any;
  Object? setTimeout(Object? Function(Object?) callback, num ms, List<Object?> args);
  /// clearTimeout?(timeoutId: any): void;
  void clearTimeout(Object? timeoutId);
  /// optional preferNonRecursiveWatch: boolean
  bool? get preferNonRecursiveWatch;
}

/// interface ProgramHost
abstract class ProgramHost<T> {
  /// createProgram: CreateProgram<T>
  CreateProgram<T> get createProgram;
  /// useCaseSensitiveFileNames(): boolean;
  bool useCaseSensitiveFileNames();
  /// getNewLine(): string;
  String getNewLine();
  /// getCurrentDirectory(): string;
  String getCurrentDirectory();
  /// getDefaultLibFileName(options: CompilerOptions): string;
  String getDefaultLibFileName(CompilerOptions options);
  /// getDefaultLibLocation?(): string;
  String getDefaultLibLocation();
  /// createHash?(data: string): string;
  String createHash(String data);
  /// fileExists(path: string): boolean;
  bool fileExists(String path);
  /// readFile(path: string, encoding?: string): string | undefined;
  String? readFile(String path, [String? encoding]);
  /// directoryExists?(path: string): boolean;
  bool directoryExists(String path);
  /// getDirectories?(path: string): string[];
  List<String> getDirectories(String path);
  /// readDirectory?(path: string, extensions?: readonly string[], exclude?: readonly string[], include?: readonly string[], depth?: number): string[];
  List<String> readDirectory(String path, [List<String>? extensions, List<String>? exclude, List<String>? include, num? depth]);
  /// realpath?(path: string): string;
  String realpath(String path);
  /// trace?(s: string): void;
  void trace(String s);
  /// getEnvironmentVariable?(name: string): string | undefined;
  String? getEnvironmentVariable(String name);
  /// resolveModuleNames?(moduleNames: string[], containingFile: string, reusedNames: string[] | undefined, redirectedReference: ResolvedProjectReference | undefined, options: CompilerOptions, containingSourceFile?: SourceFile): (ResolvedModule | undefined)[];
  List<ResolvedModule?> resolveModuleNames(List<String> moduleNames, String containingFile, List<String>? reusedNames, ResolvedProjectReference? redirectedReference, CompilerOptions options, [SourceFile? containingSourceFile]);
  /// resolveTypeReferenceDirectives?(typeReferenceDirectiveNames: string[] | readonly FileReference[], containingFile: string, redirectedReference: ResolvedProjectReference | undefined, options: CompilerOptions, containingFileMode?: ResolutionMode): (ResolvedTypeReferenceDirective | undefined)[];
  List<ResolvedTypeReferenceDirective?> resolveTypeReferenceDirectives(Object? typeReferenceDirectiveNames, String containingFile, ResolvedProjectReference? redirectedReference, CompilerOptions options, [ResolutionMode? containingFileMode]);
  /// resolveModuleNameLiterals?(moduleLiterals: readonly StringLiteralLike[], containingFile: string, redirectedReference: ResolvedProjectReference | undefined, options: CompilerOptions, containingSourceFile: SourceFile, reusedNames: readonly StringLiteralLike[] | undefined): readonly ResolvedModuleWithFailedLookupLocations[];
  List<ResolvedModuleWithFailedLookupLocations> resolveModuleNameLiterals(List<StringLiteralLike> moduleLiterals, String containingFile, ResolvedProjectReference? redirectedReference, CompilerOptions options, SourceFile containingSourceFile, List<StringLiteralLike>? reusedNames);
  /// resolveTypeReferenceDirectiveReferences?<T extends FileReference | string>(typeDirectiveReferences: readonly T[], containingFile: string, redirectedReference: ResolvedProjectReference | undefined, options: CompilerOptions, containingSourceFile: SourceFile | undefined, reusedNames: readonly T[] | undefined): readonly ResolvedTypeReferenceDirectiveWithFailedLookupLocations[];
  List<ResolvedTypeReferenceDirectiveWithFailedLookupLocations> resolveTypeReferenceDirectiveReferences<T>(List<T> typeDirectiveReferences, String containingFile, ResolvedProjectReference? redirectedReference, CompilerOptions options, SourceFile? containingSourceFile, List<T>? reusedNames);
  /// hasInvalidatedResolutions?(filePath: Path): boolean;
  bool hasInvalidatedResolutions(Path filePath);
  /// getModuleResolutionCache?(): ModuleResolutionCache | undefined;
  ModuleResolutionCache? getModuleResolutionCache();
  /// optional jsDocParsingMode: JSDocParsingMode
  JSDocParsingMode? get jsDocParsingMode;
}

/// interface WatchCompilerHost extends ProgramHost<T>, WatchHost
abstract class WatchCompilerHost<T> {
  /// useSourceOfProjectReferenceRedirect?(): boolean;
  bool useSourceOfProjectReferenceRedirect();
  /// getParsedCommandLine?(fileName: string): ParsedCommandLine | undefined;
  ParsedCommandLine? getParsedCommandLine(String fileName);
  /// afterProgramCreate?(program: T): void;
  void afterProgramCreate(T program);
}

/// interface WatchCompilerHostOfFilesAndCompilerOptions extends WatchCompilerHost<T>
abstract class WatchCompilerHostOfFilesAndCompilerOptions<T> {
  /// rootFiles: string[]
  List<String> get rootFiles;
  /// options: CompilerOptions
  CompilerOptions get options;
  /// optional watchOptions: WatchOptions
  WatchOptions? get watchOptions;
  /// optional projectReferences: readonly ProjectReference[]
  List<ProjectReference>? get projectReferences;
}

/// interface WatchCompilerHostOfConfigFile extends WatchCompilerHost<T>, ConfigFileDiagnosticsReporter
abstract class WatchCompilerHostOfConfigFile<T> {
  /// configFileName: string
  String get configFileName;
  /// optional optionsToExtend: CompilerOptions
  CompilerOptions? get optionsToExtend;
  /// optional watchOptionsToExtend: WatchOptions
  WatchOptions? get watchOptionsToExtend;
  /// optional extraFileExtensions: readonly FileExtensionInfo[]
  List<FileExtensionInfo>? get extraFileExtensions;
  /// readDirectory(path: string, extensions?: readonly string[], exclude?: readonly string[], include?: readonly string[], depth?: number): string[];
  List<String> readDirectory(String path, [List<String>? extensions, List<String>? exclude, List<String>? include, num? depth]);
}

/// interface Watch
abstract class Watch<T> {
  /// getProgram(): T;
  T getProgram();
  /// close(): void;
  void close();
}

/// interface WatchOfConfigFile extends Watch<T>
abstract class WatchOfConfigFile<T> {
}

/// interface WatchOfFilesAndCompilerOptions extends Watch<T>
abstract class WatchOfFilesAndCompilerOptions<T> {
  /// updateRootFileNames(fileNames: string[]): void;
  void updateRootFileNames(List<String> fileNames);
}

/// interface BuildOptions
abstract class BuildOptions {
  /// optional dry: boolean
  bool? get dry;
  /// optional force: boolean
  bool? get force;
  /// optional verbose: boolean
  bool? get verbose;
  /// optional stopBuildOnErrors: boolean
  bool? get stopBuildOnErrors;
  /// optional incremental: boolean
  bool? get incremental;
  /// optional assumeChangesOnlyAffectDirectDependencies: boolean
  bool? get assumeChangesOnlyAffectDirectDependencies;
  /// optional declaration: boolean
  bool? get declaration;
  /// optional declarationMap: boolean
  bool? get declarationMap;
  /// optional emitDeclarationOnly: boolean
  bool? get emitDeclarationOnly;
  /// optional sourceMap: boolean
  bool? get sourceMap;
  /// optional inlineSourceMap: boolean
  bool? get inlineSourceMap;
  /// optional traceResolution: boolean
  bool? get traceResolution;
  /// index signature: CompilerOptionsValue | undefined
}

/// interface ReportFileInError
abstract class ReportFileInError {
  /// fileName: string
  String get fileName;
  /// line: number
  num get line;
}

/// interface SolutionBuilderHostBase extends ProgramHost<T>
abstract class SolutionBuilderHostBase<T> {
  /// createDirectory?(path: string): void;
  void createDirectory(String path);
  /// writeFile?(path: string, data: string, writeByteOrderMark?: boolean): void;
  void writeFile(String path, String data, [bool? writeByteOrderMark]);
  /// optional getCustomTransformers: (project: string) => CustomTransformers | undefined
  Object? Function(Object?)? get getCustomTransformers;
  /// getModifiedTime(fileName: string): Date | undefined;
  Object? getModifiedTime(String fileName);
  /// setModifiedTime(fileName: string, date: Date): void;
  void setModifiedTime(String fileName, Object? date);
  /// deleteFile(fileName: string): void;
  void deleteFile(String fileName);
  /// getParsedCommandLine?(fileName: string): ParsedCommandLine | undefined;
  ParsedCommandLine? getParsedCommandLine(String fileName);
  /// reportDiagnostic: DiagnosticReporter
  DiagnosticReporter get reportDiagnostic;
  /// reportSolutionBuilderStatus: DiagnosticReporter
  DiagnosticReporter get reportSolutionBuilderStatus;
  /// afterProgramEmitAndDiagnostics?(program: T): void;
  void afterProgramEmitAndDiagnostics(T program);
}

/// interface SolutionBuilderHost extends SolutionBuilderHostBase<T>
abstract class SolutionBuilderHost<T> {
  /// optional reportErrorSummary: ReportEmitErrorSummary
  ReportEmitErrorSummary? get reportErrorSummary;
}

/// interface SolutionBuilderWithWatchHost extends SolutionBuilderHostBase<T>, WatchHost
abstract class SolutionBuilderWithWatchHost<T> {
}

/// interface SolutionBuilder
abstract class SolutionBuilder<T> {
  /// build(project?: string, cancellationToken?: CancellationToken, writeFile?: WriteFileCallback, getCustomTransformers?: (project: string) => CustomTransformers): ExitStatus;
  ExitStatus build([String? project, CancellationToken? cancellationToken, WriteFileCallback? writeFile, Object? Function(Object?)? getCustomTransformers]);
  /// clean(project?: string): ExitStatus;
  ExitStatus clean([String? project]);
  /// buildReferences(project: string, cancellationToken?: CancellationToken, writeFile?: WriteFileCallback, getCustomTransformers?: (project: string) => CustomTransformers): ExitStatus;
  ExitStatus buildReferences(String project, [CancellationToken? cancellationToken, WriteFileCallback? writeFile, Object? Function(Object?)? getCustomTransformers]);
  /// cleanReferences(project?: string): ExitStatus;
  ExitStatus cleanReferences([String? project]);
  /// getNextInvalidatedProject(cancellationToken?: CancellationToken): InvalidatedProject<T> | undefined;
  InvalidatedProject<T>? getNextInvalidatedProject([CancellationToken? cancellationToken]);
}

/// interface InvalidatedProjectBase
abstract class InvalidatedProjectBase {
  /// kind: InvalidatedProjectKind
  InvalidatedProjectKind get kind;
  /// project: ResolvedConfigFileName
  ResolvedConfigFileName get project;
  /// done(cancellationToken?: CancellationToken, writeFile?: WriteFileCallback, customTransformers?: CustomTransformers): ExitStatus;
  ExitStatus done([CancellationToken? cancellationToken, WriteFileCallback? writeFile, CustomTransformers? customTransformers]);
  /// getCompilerOptions(): CompilerOptions;
  CompilerOptions getCompilerOptions();
  /// getCurrentDirectory(): string;
  String getCurrentDirectory();
}

/// interface UpdateOutputFileStampsProject extends InvalidatedProjectBase
abstract class UpdateOutputFileStampsProject {
  /// kind: InvalidatedProjectKind.UpdateOutputFileStamps
  InvalidatedProjectKind get kind;
  /// updateOutputFileStatmps(): void;
  void updateOutputFileStatmps();
}

/// interface BuildInvalidedProject extends InvalidatedProjectBase
abstract class BuildInvalidedProject<T> {
  /// kind: InvalidatedProjectKind.Build
  InvalidatedProjectKind get kind;
  /// getBuilderProgram(): T | undefined;
  T? getBuilderProgram();
  /// getProgram(): Program | undefined;
  Program? getProgram();
  /// getSourceFile(fileName: string): SourceFile | undefined;
  SourceFile? getSourceFile(String fileName);
  /// getSourceFiles(): readonly SourceFile[];
  List<SourceFile> getSourceFiles();
  /// getOptionsDiagnostics(cancellationToken?: CancellationToken): readonly Diagnostic[];
  List<Diagnostic> getOptionsDiagnostics([CancellationToken? cancellationToken]);
  /// getGlobalDiagnostics(cancellationToken?: CancellationToken): readonly Diagnostic[];
  List<Diagnostic> getGlobalDiagnostics([CancellationToken? cancellationToken]);
  /// getConfigFileParsingDiagnostics(): readonly Diagnostic[];
  List<Diagnostic> getConfigFileParsingDiagnostics();
  /// getSyntacticDiagnostics(sourceFile?: SourceFile, cancellationToken?: CancellationToken): readonly Diagnostic[];
  List<Diagnostic> getSyntacticDiagnostics([SourceFile? sourceFile, CancellationToken? cancellationToken]);
  /// getAllDependencies(sourceFile: SourceFile): readonly string[];
  List<String> getAllDependencies(SourceFile sourceFile);
  /// getSemanticDiagnostics(sourceFile?: SourceFile, cancellationToken?: CancellationToken): readonly Diagnostic[];
  List<Diagnostic> getSemanticDiagnostics([SourceFile? sourceFile, CancellationToken? cancellationToken]);
  /// getSemanticDiagnosticsOfNextAffectedFile(cancellationToken?: CancellationToken, ignoreSourceFile?: (sourceFile: SourceFile) => boolean): AffectedFileResult<readonly Diagnostic[]>;
  AffectedFileResult<List<Diagnostic>> getSemanticDiagnosticsOfNextAffectedFile([CancellationToken? cancellationToken, Object? Function(Object?)? ignoreSourceFile]);
  /// emit(targetSourceFile?: SourceFile, writeFile?: WriteFileCallback, cancellationToken?: CancellationToken, emitOnlyDtsFiles?: boolean, customTransformers?: CustomTransformers): EmitResult | undefined;
  EmitResult? emit([SourceFile? targetSourceFile, WriteFileCallback? writeFile, CancellationToken? cancellationToken, bool? emitOnlyDtsFiles, CustomTransformers? customTransformers]);
}

/// interface IScriptSnapshot
abstract class IScriptSnapshot {
  /// getText(start: number, end: number): string;
  String getText(num start, num end);
  /// getLength(): number;
  num getLength();
  /// getChangeRange(oldSnapshot: IScriptSnapshot): TextChangeRange | undefined;
  TextChangeRange? getChangeRange(IScriptSnapshot oldSnapshot);
  /// dispose?(): void;
  void dispose();
}

/// interface PreProcessedFileInfo
abstract class PreProcessedFileInfo {
  /// referencedFiles: FileReference[]
  List<FileReference> get referencedFiles;
  /// typeReferenceDirectives: FileReference[]
  List<FileReference> get typeReferenceDirectives;
  /// libReferenceDirectives: FileReference[]
  List<FileReference> get libReferenceDirectives;
  /// importedFiles: FileReference[]
  List<FileReference> get importedFiles;
  /// optional ambientExternalModules: string[]
  List<String>? get ambientExternalModules;
  /// isLibFile: boolean
  bool get isLibFile;
}

/// interface HostCancellationToken
abstract class HostCancellationToken {
  /// isCancellationRequested(): boolean;
  bool isCancellationRequested();
}

/// interface InstallPackageOptions
abstract class InstallPackageOptions {
  /// fileName: Path
  Path get fileName;
  /// packageName: string
  String get packageName;
}

/// interface PerformanceEvent
abstract class PerformanceEvent {
  /// kind: "UpdateGraph" | "CreatePackageJsonAutoImportProvider"
  Object? get kind;
  /// durationMs: number
  num get durationMs;
}

/// interface IncompleteCompletionsCache
abstract class IncompleteCompletionsCache {
  /// get(): CompletionInfo | undefined;
  CompletionInfo? get_();
  /// set(response: CompletionInfo): void;
  void set_(CompletionInfo response);
  /// clear(): void;
  void clear();
}

/// interface LanguageServiceHost extends GetEffectiveTypeRootsHost, MinimalResolutionCacheHost
abstract class LanguageServiceHost {
  /// getCompilationSettings(): CompilerOptions;
  CompilerOptions getCompilationSettings();
  /// getNewLine?(): string;
  String getNewLine();
  /// getProjectVersion?(): string;
  String getProjectVersion();
  /// getScriptFileNames(): string[];
  List<String> getScriptFileNames();
  /// getScriptKind?(fileName: string): ScriptKind;
  ScriptKind getScriptKind(String fileName);
  /// getScriptVersion(fileName: string): string;
  String getScriptVersion(String fileName);
  /// getScriptSnapshot(fileName: string): IScriptSnapshot | undefined;
  IScriptSnapshot? getScriptSnapshot(String fileName);
  /// getProjectReferences?(): readonly ProjectReference[] | undefined;
  List<ProjectReference>? getProjectReferences();
  /// getLocalizedDiagnosticMessages?(): any;
  Object? getLocalizedDiagnosticMessages();
  /// getCancellationToken?(): HostCancellationToken;
  HostCancellationToken getCancellationToken();
  /// getCurrentDirectory(): string;
  String getCurrentDirectory();
  /// getDefaultLibFileName(options: CompilerOptions): string;
  String getDefaultLibFileName(CompilerOptions options);
  /// log?(s: string): void;
  void log(String s);
  /// trace?(s: string): void;
  void trace(String s);
  /// error?(s: string): void;
  void error(String s);
  /// useCaseSensitiveFileNames?(): boolean;
  bool useCaseSensitiveFileNames();
  /// readDirectory?(path: string, extensions?: readonly string[], exclude?: readonly string[], include?: readonly string[], depth?: number): string[];
  List<String> readDirectory(String path, [List<String>? extensions, List<String>? exclude, List<String>? include, num? depth]);
  /// realpath?(path: string): string;
  String realpath(String path);
  /// readFile(path: string, encoding?: string): string | undefined;
  String? readFile(String path, [String? encoding]);
  /// fileExists(path: string): boolean;
  bool fileExists(String path);
  /// getTypeRootsVersion?(): number;
  num getTypeRootsVersion();
  /// resolveModuleNames?(moduleNames: string[], containingFile: string, reusedNames: string[] | undefined, redirectedReference: ResolvedProjectReference | undefined, options: CompilerOptions, containingSourceFile?: SourceFile): (ResolvedModule | undefined)[];
  List<ResolvedModule?> resolveModuleNames(List<String> moduleNames, String containingFile, List<String>? reusedNames, ResolvedProjectReference? redirectedReference, CompilerOptions options, [SourceFile? containingSourceFile]);
  /// getResolvedModuleWithFailedLookupLocationsFromCache?(modulename: string, containingFile: string, resolutionMode?: ResolutionMode): ResolvedModuleWithFailedLookupLocations | undefined;
  ResolvedModuleWithFailedLookupLocations? getResolvedModuleWithFailedLookupLocationsFromCache(String modulename, String containingFile, [ResolutionMode? resolutionMode]);
  /// resolveTypeReferenceDirectives?(typeDirectiveNames: string[] | FileReference[], containingFile: string, redirectedReference: ResolvedProjectReference | undefined, options: CompilerOptions, containingFileMode?: ResolutionMode): (ResolvedTypeReferenceDirective | undefined)[];
  List<ResolvedTypeReferenceDirective?> resolveTypeReferenceDirectives(Object? typeDirectiveNames, String containingFile, ResolvedProjectReference? redirectedReference, CompilerOptions options, [ResolutionMode? containingFileMode]);
  /// resolveModuleNameLiterals?(moduleLiterals: readonly StringLiteralLike[], containingFile: string, redirectedReference: ResolvedProjectReference | undefined, options: CompilerOptions, containingSourceFile: SourceFile, reusedNames: readonly StringLiteralLike[] | undefined): readonly ResolvedModuleWithFailedLookupLocations[];
  List<ResolvedModuleWithFailedLookupLocations> resolveModuleNameLiterals(List<StringLiteralLike> moduleLiterals, String containingFile, ResolvedProjectReference? redirectedReference, CompilerOptions options, SourceFile containingSourceFile, List<StringLiteralLike>? reusedNames);
  /// resolveTypeReferenceDirectiveReferences?<T extends FileReference | string>(typeDirectiveReferences: readonly T[], containingFile: string, redirectedReference: ResolvedProjectReference | undefined, options: CompilerOptions, containingSourceFile: SourceFile | undefined, reusedNames: readonly T[] | undefined): readonly ResolvedTypeReferenceDirectiveWithFailedLookupLocations[];
  List<ResolvedTypeReferenceDirectiveWithFailedLookupLocations> resolveTypeReferenceDirectiveReferences<T>(List<T> typeDirectiveReferences, String containingFile, ResolvedProjectReference? redirectedReference, CompilerOptions options, SourceFile? containingSourceFile, List<T>? reusedNames);
  /// getDirectories?(directoryName: string): string[];
  List<String> getDirectories(String directoryName);
  /// getCustomTransformers?(): CustomTransformers | undefined;
  CustomTransformers? getCustomTransformers();
  /// isKnownTypesPackageName?(name: string): boolean;
  bool isKnownTypesPackageName(String name);
  /// installPackage?(options: InstallPackageOptions): Promise<ApplyCodeActionCommandResult>;
  Future<ApplyCodeActionCommandResult> installPackage(InstallPackageOptions options);
  /// writeFile?(fileName: string, content: string): void;
  void writeFile(String fileName, String content);
  /// getParsedCommandLine?(fileName: string): ParsedCommandLine | undefined;
  ParsedCommandLine? getParsedCommandLine(String fileName);
  /// optional jsDocParsingMode: JSDocParsingMode | undefined
  JSDocParsingMode? get jsDocParsingMode;
}

/// interface LanguageService
abstract class LanguageService {
  /// cleanupSemanticCache(): void;
  void cleanupSemanticCache();
  /// getSyntacticDiagnostics(fileName: string): DiagnosticWithLocation[];
  List<DiagnosticWithLocation> getSyntacticDiagnostics(String fileName);
  /// getSemanticDiagnostics(fileName: string): Diagnostic[];
  List<Diagnostic> getSemanticDiagnostics(String fileName);
  /// getSuggestionDiagnostics(fileName: string): DiagnosticWithLocation[];
  List<DiagnosticWithLocation> getSuggestionDiagnostics(String fileName);
  /// getCompilerOptionsDiagnostics(): Diagnostic[];
  List<Diagnostic> getCompilerOptionsDiagnostics();
  /// getSyntacticClassifications(fileName: string, span: TextSpan): ClassifiedSpan[];
  List<ClassifiedSpan> getSyntacticClassifications(String fileName, TextSpan span);
  /// getSyntacticClassifications(fileName: string, span: TextSpan, format: SemanticClassificationFormat): ClassifiedSpan[] | ClassifiedSpan2020[];
  Object? getSyntacticClassifications$1(String fileName, TextSpan span, SemanticClassificationFormat format);
  /// getSemanticClassifications(fileName: string, span: TextSpan): ClassifiedSpan[];
  List<ClassifiedSpan> getSemanticClassifications(String fileName, TextSpan span);
  /// getSemanticClassifications(fileName: string, span: TextSpan, format: SemanticClassificationFormat): ClassifiedSpan[] | ClassifiedSpan2020[];
  Object? getSemanticClassifications$1(String fileName, TextSpan span, SemanticClassificationFormat format);
  /// getEncodedSyntacticClassifications(fileName: string, span: TextSpan): Classifications;
  Classifications getEncodedSyntacticClassifications(String fileName, TextSpan span);
  /// getEncodedSemanticClassifications(fileName: string, span: TextSpan, format?: SemanticClassificationFormat): Classifications;
  Classifications getEncodedSemanticClassifications(String fileName, TextSpan span, [SemanticClassificationFormat? format]);
  /// getCompletionsAtPosition(fileName: string, position: number, options: GetCompletionsAtPositionOptions | undefined, formattingSettings?: FormatCodeSettings): WithMetadata<CompletionInfo> | undefined;
  WithMetadata<CompletionInfo>? getCompletionsAtPosition(String fileName, num position, GetCompletionsAtPositionOptions? options, [FormatCodeSettings? formattingSettings]);
  /// getCompletionEntryDetails(fileName: string, position: number, entryName: string, formatOptions: FormatCodeOptions | FormatCodeSettings | undefined, source: string | undefined, preferences: UserPreferences | undefined, data: CompletionEntryData | undefined): CompletionEntryDetails | undefined;
  CompletionEntryDetails? getCompletionEntryDetails(String fileName, num position, String entryName, Object? formatOptions, String? source, UserPreferences? preferences, CompletionEntryData? data);
  /// getCompletionEntrySymbol(fileName: string, position: number, name: string, source: string | undefined): Symbol | undefined;
  Symbol? getCompletionEntrySymbol(String fileName, num position, String name, String? source);
  /// getQuickInfoAtPosition(fileName: string, position: number, maximumLength?: number): QuickInfo | undefined;
  QuickInfo? getQuickInfoAtPosition(String fileName, num position, [num? maximumLength]);
  /// getNameOrDottedNameSpan(fileName: string, startPos: number, endPos: number): TextSpan | undefined;
  TextSpan? getNameOrDottedNameSpan(String fileName, num startPos, num endPos);
  /// getBreakpointStatementAtPosition(fileName: string, position: number): TextSpan | undefined;
  TextSpan? getBreakpointStatementAtPosition(String fileName, num position);
  /// getSignatureHelpItems(fileName: string, position: number, options: SignatureHelpItemsOptions | undefined): SignatureHelpItems | undefined;
  SignatureHelpItems? getSignatureHelpItems(String fileName, num position, SignatureHelpItemsOptions? options);
  /// getRenameInfo(fileName: string, position: number, preferences: UserPreferences): RenameInfo;
  RenameInfo getRenameInfo(String fileName, num position, UserPreferences preferences);
  /// getRenameInfo(fileName: string, position: number, options?: RenameInfoOptions): RenameInfo;
  RenameInfo getRenameInfo$1(String fileName, num position, [RenameInfoOptions? options]);
  /// findRenameLocations(fileName: string, position: number, findInStrings: boolean, findInComments: boolean, preferences: UserPreferences): readonly RenameLocation[] | undefined;
  List<RenameLocation>? findRenameLocations(String fileName, num position, bool findInStrings, bool findInComments, UserPreferences preferences);
  /// findRenameLocations(fileName: string, position: number, findInStrings: boolean, findInComments: boolean, providePrefixAndSuffixTextForRename?: boolean): readonly RenameLocation[] | undefined;
  List<RenameLocation>? findRenameLocations$1(String fileName, num position, bool findInStrings, bool findInComments, [bool? providePrefixAndSuffixTextForRename]);
  /// getSmartSelectionRange(fileName: string, position: number): SelectionRange;
  SelectionRange getSmartSelectionRange(String fileName, num position);
  /// getDefinitionAtPosition(fileName: string, position: number): readonly DefinitionInfo[] | undefined;
  List<DefinitionInfo>? getDefinitionAtPosition(String fileName, num position);
  /// getDefinitionAndBoundSpan(fileName: string, position: number): DefinitionInfoAndBoundSpan | undefined;
  DefinitionInfoAndBoundSpan? getDefinitionAndBoundSpan(String fileName, num position);
  /// getTypeDefinitionAtPosition(fileName: string, position: number): readonly DefinitionInfo[] | undefined;
  List<DefinitionInfo>? getTypeDefinitionAtPosition(String fileName, num position);
  /// getImplementationAtPosition(fileName: string, position: number): readonly ImplementationLocation[] | undefined;
  List<ImplementationLocation>? getImplementationAtPosition(String fileName, num position);
  /// getReferencesAtPosition(fileName: string, position: number): ReferenceEntry[] | undefined;
  List<ReferenceEntry>? getReferencesAtPosition(String fileName, num position);
  /// findReferences(fileName: string, position: number): ReferencedSymbol[] | undefined;
  List<ReferencedSymbol>? findReferences(String fileName, num position);
  /// getDocumentHighlights(fileName: string, position: number, filesToSearch: string[]): DocumentHighlights[] | undefined;
  List<DocumentHighlights>? getDocumentHighlights(String fileName, num position, List<String> filesToSearch);
  /// getFileReferences(fileName: string): ReferenceEntry[];
  List<ReferenceEntry> getFileReferences(String fileName);
  /// getNavigateToItems(searchValue: string, maxResultCount?: number, fileName?: string, excludeDtsFiles?: boolean, excludeLibFiles?: boolean): NavigateToItem[];
  List<NavigateToItem> getNavigateToItems(String searchValue, [num? maxResultCount, String? fileName, bool? excludeDtsFiles, bool? excludeLibFiles]);
  /// getNavigationBarItems(fileName: string): NavigationBarItem[];
  List<NavigationBarItem> getNavigationBarItems(String fileName);
  /// getNavigationTree(fileName: string): NavigationTree;
  NavigationTree getNavigationTree(String fileName);
  /// prepareCallHierarchy(fileName: string, position: number): CallHierarchyItem | CallHierarchyItem[] | undefined;
  Object? prepareCallHierarchy(String fileName, num position);
  /// provideCallHierarchyIncomingCalls(fileName: string, position: number): CallHierarchyIncomingCall[];
  List<CallHierarchyIncomingCall> provideCallHierarchyIncomingCalls(String fileName, num position);
  /// provideCallHierarchyOutgoingCalls(fileName: string, position: number): CallHierarchyOutgoingCall[];
  List<CallHierarchyOutgoingCall> provideCallHierarchyOutgoingCalls(String fileName, num position);
  /// provideInlayHints(fileName: string, span: TextSpan, preferences: UserPreferences | undefined): InlayHint[];
  List<InlayHint> provideInlayHints(String fileName, TextSpan span, UserPreferences? preferences);
  /// getOutliningSpans(fileName: string): OutliningSpan[];
  List<OutliningSpan> getOutliningSpans(String fileName);
  /// getTodoComments(fileName: string, descriptors: TodoCommentDescriptor[]): TodoComment[];
  List<TodoComment> getTodoComments(String fileName, List<TodoCommentDescriptor> descriptors);
  /// getBraceMatchingAtPosition(fileName: string, position: number): TextSpan[];
  List<TextSpan> getBraceMatchingAtPosition(String fileName, num position);
  /// getIndentationAtPosition(fileName: string, position: number, options: EditorOptions | EditorSettings): number;
  num getIndentationAtPosition(String fileName, num position, Object? options);
  /// getFormattingEditsForRange(fileName: string, start: number, end: number, options: FormatCodeOptions | FormatCodeSettings): TextChange[];
  List<TextChange> getFormattingEditsForRange(String fileName, num start, num end, Object? options);
  /// getFormattingEditsForDocument(fileName: string, options: FormatCodeOptions | FormatCodeSettings): TextChange[];
  List<TextChange> getFormattingEditsForDocument(String fileName, Object? options);
  /// getFormattingEditsAfterKeystroke(fileName: string, position: number, key: string, options: FormatCodeOptions | FormatCodeSettings): TextChange[];
  List<TextChange> getFormattingEditsAfterKeystroke(String fileName, num position, String key, Object? options);
  /// getDocCommentTemplateAtPosition(fileName: string, position: number, options?: DocCommentTemplateOptions, formatOptions?: FormatCodeSettings): TextInsertion | undefined;
  TextInsertion? getDocCommentTemplateAtPosition(String fileName, num position, [DocCommentTemplateOptions? options, FormatCodeSettings? formatOptions]);
  /// isValidBraceCompletionAtPosition(fileName: string, position: number, openingBrace: number): boolean;
  bool isValidBraceCompletionAtPosition(String fileName, num position, num openingBrace);
  /// getJsxClosingTagAtPosition(fileName: string, position: number): JsxClosingTagInfo | undefined;
  JsxClosingTagInfo? getJsxClosingTagAtPosition(String fileName, num position);
  /// getLinkedEditingRangeAtPosition(fileName: string, position: number): LinkedEditingInfo | undefined;
  LinkedEditingInfo? getLinkedEditingRangeAtPosition(String fileName, num position);
  /// getSpanOfEnclosingComment(fileName: string, position: number, onlyMultiLine: boolean): TextSpan | undefined;
  TextSpan? getSpanOfEnclosingComment(String fileName, num position, bool onlyMultiLine);
  /// toLineColumnOffset?(fileName: string, position: number): LineAndCharacter;
  LineAndCharacter toLineColumnOffset(String fileName, num position);
  /// getCodeFixesAtPosition(fileName: string, start: number, end: number, errorCodes: readonly number[], formatOptions: FormatCodeSettings, preferences: UserPreferences): readonly CodeFixAction[];
  List<CodeFixAction> getCodeFixesAtPosition(String fileName, num start, num end, List<num> errorCodes, FormatCodeSettings formatOptions, UserPreferences preferences);
  /// getCombinedCodeFix(scope: CombinedCodeFixScope, fixId: {}, formatOptions: FormatCodeSettings, preferences: UserPreferences): CombinedCodeActions;
  CombinedCodeActions getCombinedCodeFix(CombinedCodeFixScope scope, Map<String, Object?> fixId, FormatCodeSettings formatOptions, UserPreferences preferences);
  /// applyCodeActionCommand(action: CodeActionCommand, formatSettings?: FormatCodeSettings): Promise<ApplyCodeActionCommandResult>;
  Future<ApplyCodeActionCommandResult> applyCodeActionCommand(CodeActionCommand action, [FormatCodeSettings? formatSettings]);
  /// applyCodeActionCommand(action: CodeActionCommand[], formatSettings?: FormatCodeSettings): Promise<ApplyCodeActionCommandResult[]>;
  Future<List<ApplyCodeActionCommandResult>> applyCodeActionCommand$1(List<CodeActionCommand> action, [FormatCodeSettings? formatSettings]);
  /// applyCodeActionCommand(action: CodeActionCommand | CodeActionCommand[], formatSettings?: FormatCodeSettings): Promise<ApplyCodeActionCommandResult | ApplyCodeActionCommandResult[]>;
  Future<Object?> applyCodeActionCommand$2(Object? action, [FormatCodeSettings? formatSettings]);
  /// applyCodeActionCommand(fileName: string, action: CodeActionCommand): Promise<ApplyCodeActionCommandResult>;
  Future<ApplyCodeActionCommandResult> applyCodeActionCommand$3(String fileName, CodeActionCommand action);
  /// applyCodeActionCommand(fileName: string, action: CodeActionCommand[]): Promise<ApplyCodeActionCommandResult[]>;
  Future<List<ApplyCodeActionCommandResult>> applyCodeActionCommand$4(String fileName, List<CodeActionCommand> action);
  /// applyCodeActionCommand(fileName: string, action: CodeActionCommand | CodeActionCommand[]): Promise<ApplyCodeActionCommandResult | ApplyCodeActionCommandResult[]>;
  Future<Object?> applyCodeActionCommand$5(String fileName, Object? action);
  /// getApplicableRefactors(fileName: string, positionOrRange: number | TextRange, preferences: UserPreferences | undefined, triggerReason?: RefactorTriggerReason, kind?: string, includeInteractiveActions?: boolean): ApplicableRefactorInfo[];
  List<ApplicableRefactorInfo> getApplicableRefactors(String fileName, Object? positionOrRange, UserPreferences? preferences, [RefactorTriggerReason? triggerReason, String? kind, bool? includeInteractiveActions]);
  /// getEditsForRefactor(fileName: string, formatOptions: FormatCodeSettings, positionOrRange: number | TextRange, refactorName: string, actionName: string, preferences: UserPreferences | undefined, interactiveRefactorArguments?: InteractiveRefactorArguments): RefactorEditInfo | undefined;
  RefactorEditInfo? getEditsForRefactor(String fileName, FormatCodeSettings formatOptions, Object? positionOrRange, String refactorName, String actionName, UserPreferences? preferences, [InteractiveRefactorArguments? interactiveRefactorArguments]);
  /// getMoveToRefactoringFileSuggestions(fileName: string, positionOrRange: number | TextRange, preferences: UserPreferences | undefined, triggerReason?: RefactorTriggerReason, kind?: string): { newFileName: string; files: string[]; };
  Map<String, Object?> getMoveToRefactoringFileSuggestions(String fileName, Object? positionOrRange, UserPreferences? preferences, [RefactorTriggerReason? triggerReason, String? kind]);
  /// organizeImports(args: OrganizeImportsArgs, formatOptions: FormatCodeSettings, preferences: UserPreferences | undefined): readonly FileTextChanges[];
  List<FileTextChanges> organizeImports(OrganizeImportsArgs args, FormatCodeSettings formatOptions, UserPreferences? preferences);
  /// getEditsForFileRename(oldFilePath: string, newFilePath: string, formatOptions: FormatCodeSettings, preferences: UserPreferences | undefined): readonly FileTextChanges[];
  List<FileTextChanges> getEditsForFileRename(String oldFilePath, String newFilePath, FormatCodeSettings formatOptions, UserPreferences? preferences);
  /// getEmitOutput(fileName: string, emitOnlyDtsFiles?: boolean, forceDtsEmit?: boolean): EmitOutput;
  EmitOutput getEmitOutput(String fileName, [bool? emitOnlyDtsFiles, bool? forceDtsEmit]);
  /// getProgram(): Program | undefined;
  Program? getProgram();
  /// toggleLineComment(fileName: string, textRange: TextRange): TextChange[];
  List<TextChange> toggleLineComment(String fileName, TextRange textRange);
  /// toggleMultilineComment(fileName: string, textRange: TextRange): TextChange[];
  List<TextChange> toggleMultilineComment(String fileName, TextRange textRange);
  /// commentSelection(fileName: string, textRange: TextRange): TextChange[];
  List<TextChange> commentSelection(String fileName, TextRange textRange);
  /// uncommentSelection(fileName: string, textRange: TextRange): TextChange[];
  List<TextChange> uncommentSelection(String fileName, TextRange textRange);
  /// getSupportedCodeFixes(fileName?: string): readonly string[];
  List<String> getSupportedCodeFixes([String? fileName]);
  /// dispose(): void;
  void dispose();
  /// preparePasteEditsForFile(fileName: string, copiedTextRanges: TextRange[]): boolean;
  bool preparePasteEditsForFile(String fileName, List<TextRange> copiedTextRanges);
  /// getPasteEdits(args: PasteEditsArgs, formatOptions: FormatCodeSettings): PasteEdits;
  PasteEdits getPasteEdits(PasteEditsArgs args, FormatCodeSettings formatOptions);
}

/// interface JsxClosingTagInfo
abstract class JsxClosingTagInfo {
  /// newText: string
  String get newText;
}

/// interface LinkedEditingInfo
abstract class LinkedEditingInfo {
  /// ranges: TextSpan[]
  List<TextSpan> get ranges;
  /// optional wordPattern: string
  String? get wordPattern;
}

/// interface CombinedCodeFixScope
abstract class CombinedCodeFixScope {
  /// type: "file"
  String get type;
  /// fileName: string
  String get fileName;
}

/// interface PasteEdits
abstract class PasteEdits {
  /// edits: readonly FileTextChanges[]
  List<FileTextChanges> get edits;
  /// optional fixId: {}
  Map<String, Object?>? get fixId;
}

/// interface PasteEditsArgs
abstract class PasteEditsArgs {
  /// targetFile: string
  String get targetFile;
  /// pastedText: string[]
  List<String> get pastedText;
  /// pasteLocations: TextRange[]
  List<TextRange> get pasteLocations;
  /// copiedFrom: { file: string; range: TextRange[]; } | undefined
  Map<String, Object?>? get copiedFrom;
  /// preferences: UserPreferences
  UserPreferences get preferences;
}

/// interface OrganizeImportsArgs extends CombinedCodeFixScope
abstract class OrganizeImportsArgs {
  /// optional skipDestructiveCodeActions: boolean
  bool? get skipDestructiveCodeActions;
  /// optional mode: OrganizeImportsMode
  OrganizeImportsMode? get mode;
}

/// interface GetCompletionsAtPositionOptions extends UserPreferences
abstract class GetCompletionsAtPositionOptions {
  /// optional triggerCharacter: CompletionsTriggerCharacter
  CompletionsTriggerCharacter? get triggerCharacter;
  /// optional triggerKind: CompletionTriggerKind
  CompletionTriggerKind? get triggerKind;
  /// optional includeSymbol: boolean
  bool? get includeSymbol;
  /// optional includeExternalModuleExports: boolean
  bool? get includeExternalModuleExports;
  /// optional includeInsertTextCompletions: boolean
  bool? get includeInsertTextCompletions;
}

/// interface SignatureHelpItemsOptions
abstract class SignatureHelpItemsOptions {
  /// optional triggerReason: SignatureHelpTriggerReason
  SignatureHelpTriggerReason? get triggerReason;
}

/// interface SignatureHelpInvokedReason
abstract class SignatureHelpInvokedReason {
  /// kind: "invoked"
  String get kind;
  /// optional triggerCharacter: undefined
  Null? get triggerCharacter;
}

/// interface SignatureHelpCharacterTypedReason
abstract class SignatureHelpCharacterTypedReason {
  /// kind: "characterTyped"
  String get kind;
  /// triggerCharacter: SignatureHelpTriggerCharacter
  SignatureHelpTriggerCharacter get triggerCharacter;
}

/// interface SignatureHelpRetriggeredReason
abstract class SignatureHelpRetriggeredReason {
  /// kind: "retrigger"
  String get kind;
  /// optional triggerCharacter: SignatureHelpRetriggerCharacter
  SignatureHelpRetriggerCharacter? get triggerCharacter;
}

/// interface ApplyCodeActionCommandResult
abstract class ApplyCodeActionCommandResult {
  /// successMessage: string
  String get successMessage;
}

/// interface Classifications
abstract class Classifications {
  /// spans: number[]
  List<num> get spans;
  /// endOfLineState: EndOfLineState
  EndOfLineState get endOfLineState;
}

/// interface ClassifiedSpan
abstract class ClassifiedSpan {
  /// textSpan: TextSpan
  TextSpan get textSpan;
  /// classificationType: ClassificationTypeNames
  ClassificationTypeNames get classificationType;
}

/// interface ClassifiedSpan2020
abstract class ClassifiedSpan2020 {
  /// textSpan: TextSpan
  TextSpan get textSpan;
  /// classificationType: number
  num get classificationType;
}

/// interface NavigationBarItem
abstract class NavigationBarItem {
  /// text: string
  String get text;
  /// kind: ScriptElementKind
  ScriptElementKind get kind;
  /// kindModifiers: string
  String get kindModifiers;
  /// spans: TextSpan[]
  List<TextSpan> get spans;
  /// childItems: NavigationBarItem[]
  List<NavigationBarItem> get childItems;
  /// indent: number
  num get indent;
  /// bolded: boolean
  bool get bolded;
  /// grayed: boolean
  bool get grayed;
}

/// interface NavigationTree
abstract class NavigationTree {
  /// text: string
  String get text;
  /// kind: ScriptElementKind
  ScriptElementKind get kind;
  /// kindModifiers: string
  String get kindModifiers;
  /// spans: TextSpan[]
  List<TextSpan> get spans;
  /// nameSpan: TextSpan | undefined
  TextSpan? get nameSpan;
  /// optional childItems: NavigationTree[]
  List<NavigationTree>? get childItems;
}

/// interface CallHierarchyItem
abstract class CallHierarchyItem {
  /// name: string
  String get name;
  /// kind: ScriptElementKind
  ScriptElementKind get kind;
  /// optional kindModifiers: string
  String? get kindModifiers;
  /// file: string
  String get file;
  /// span: TextSpan
  TextSpan get span;
  /// selectionSpan: TextSpan
  TextSpan get selectionSpan;
  /// optional containerName: string
  String? get containerName;
}

/// interface CallHierarchyIncomingCall
abstract class CallHierarchyIncomingCall {
  /// from: CallHierarchyItem
  CallHierarchyItem get from;
  /// fromSpans: TextSpan[]
  List<TextSpan> get fromSpans;
}

/// interface CallHierarchyOutgoingCall
abstract class CallHierarchyOutgoingCall {
  /// to: CallHierarchyItem
  CallHierarchyItem get to;
  /// fromSpans: TextSpan[]
  List<TextSpan> get fromSpans;
}

/// interface InlayHint
abstract class InlayHint {
  /// text: string
  String get text;
  /// position: number
  num get position;
  /// kind: InlayHintKind
  InlayHintKind get kind;
  /// optional whitespaceBefore: boolean
  bool? get whitespaceBefore;
  /// optional whitespaceAfter: boolean
  bool? get whitespaceAfter;
  /// optional displayParts: InlayHintDisplayPart[]
  List<InlayHintDisplayPart>? get displayParts;
}

/// interface InlayHintDisplayPart
abstract class InlayHintDisplayPart {
  /// text: string
  String get text;
  /// optional span: TextSpan
  TextSpan? get span;
  /// optional file: string
  String? get file;
}

/// interface TodoCommentDescriptor
abstract class TodoCommentDescriptor {
  /// text: string
  String get text;
  /// priority: number
  num get priority;
}

/// interface TodoComment
abstract class TodoComment {
  /// descriptor: TodoCommentDescriptor
  TodoCommentDescriptor get descriptor;
  /// message: string
  String get message;
  /// position: number
  num get position;
}

/// interface TextChange
abstract class TextChange {
  /// span: TextSpan
  TextSpan get span;
  /// newText: string
  String get newText;
}

/// interface FileTextChanges
abstract class FileTextChanges {
  /// fileName: string
  String get fileName;
  /// textChanges: readonly TextChange[]
  List<TextChange> get textChanges;
  /// optional isNewFile: boolean
  bool? get isNewFile;
}

/// interface CodeAction
abstract class CodeAction {
  /// description: string
  String get description;
  /// changes: FileTextChanges[]
  List<FileTextChanges> get changes;
  /// optional commands: CodeActionCommand[]
  List<CodeActionCommand>? get commands;
}

/// interface CodeFixAction extends CodeAction
abstract class CodeFixAction {
  /// fixName: string
  String get fixName;
  /// optional fixId: {}
  Map<String, Object?>? get fixId;
  /// optional fixAllDescription: string
  String? get fixAllDescription;
}

/// interface CombinedCodeActions
abstract class CombinedCodeActions {
  /// changes: readonly FileTextChanges[]
  List<FileTextChanges> get changes;
  /// optional commands: readonly CodeActionCommand[]
  List<CodeActionCommand>? get commands;
}

/// interface InstallPackageAction
abstract class InstallPackageAction {
}

/// interface ApplicableRefactorInfo
abstract class ApplicableRefactorInfo {
  /// name: string
  String get name;
  /// description: string
  String get description;
  /// optional inlineable: boolean
  bool? get inlineable;
  /// actions: RefactorActionInfo[]
  List<RefactorActionInfo> get actions;
}

/// interface RefactorActionInfo
abstract class RefactorActionInfo {
  /// name: string
  String get name;
  /// description: string
  String get description;
  /// optional notApplicableReason: string
  String? get notApplicableReason;
  /// optional kind: string
  String? get kind;
  /// optional isInteractive: boolean
  bool? get isInteractive;
  /// optional range: { start: { line: number; offset: number; }; end: { line: number; offset: number; }; }
  Map<String, Object?>? get range;
}

/// interface RefactorEditInfo
abstract class RefactorEditInfo {
  /// edits: FileTextChanges[]
  List<FileTextChanges> get edits;
  /// optional renameFilename: string
  String? get renameFilename;
  /// optional renameLocation: number
  num? get renameLocation;
  /// optional commands: CodeActionCommand[]
  List<CodeActionCommand>? get commands;
  /// optional notApplicableReason: string
  String? get notApplicableReason;
}

/// interface TextInsertion
abstract class TextInsertion {
  /// newText: string
  String get newText;
  /// caretOffset: number
  num get caretOffset;
}

/// interface DocumentSpan
abstract class DocumentSpan {
  /// textSpan: TextSpan
  TextSpan get textSpan;
  /// fileName: string
  String get fileName;
  /// optional originalTextSpan: TextSpan
  TextSpan? get originalTextSpan;
  /// optional originalFileName: string
  String? get originalFileName;
  /// optional contextSpan: TextSpan
  TextSpan? get contextSpan;
  /// optional originalContextSpan: TextSpan
  TextSpan? get originalContextSpan;
}

/// interface RenameLocation extends DocumentSpan
abstract class RenameLocation {
  /// optional prefixText: string
  String? get prefixText;
  /// optional suffixText: string
  String? get suffixText;
}

/// interface ReferenceEntry extends DocumentSpan
abstract class ReferenceEntry {
  /// isWriteAccess: boolean
  bool get isWriteAccess;
  /// optional isInString: true
  bool? get isInString;
}

/// interface ImplementationLocation extends DocumentSpan
abstract class ImplementationLocation {
  /// kind: ScriptElementKind
  ScriptElementKind get kind;
  /// displayParts: SymbolDisplayPart[]
  List<SymbolDisplayPart> get displayParts;
}

/// interface HighlightSpan
abstract class HighlightSpan {
  /// optional fileName: string
  String? get fileName;
  /// optional isInString: true
  bool? get isInString;
  /// textSpan: TextSpan
  TextSpan get textSpan;
  /// optional contextSpan: TextSpan
  TextSpan? get contextSpan;
  /// kind: HighlightSpanKind
  HighlightSpanKind get kind;
}

/// interface NavigateToItem
abstract class NavigateToItem {
  /// name: string
  String get name;
  /// kind: ScriptElementKind
  ScriptElementKind get kind;
  /// kindModifiers: string
  String get kindModifiers;
  /// matchKind: "exact" | "prefix" | "substring" | "camelCase"
  Object? get matchKind;
  /// isCaseSensitive: boolean
  bool get isCaseSensitive;
  /// fileName: string
  String get fileName;
  /// textSpan: TextSpan
  TextSpan get textSpan;
  /// containerName: string
  String get containerName;
  /// containerKind: ScriptElementKind
  ScriptElementKind get containerKind;
}

/// interface EditorOptions
abstract class EditorOptions {
  /// optional BaseIndentSize: number
  num? get BaseIndentSize;
  /// IndentSize: number
  num get IndentSize;
  /// TabSize: number
  num get TabSize;
  /// NewLineCharacter: string
  String get NewLineCharacter;
  /// ConvertTabsToSpaces: boolean
  bool get ConvertTabsToSpaces;
  /// IndentStyle: IndentStyle
  IndentStyle get IndentStyle$v;
}

/// interface EditorSettings
abstract class EditorSettings {
  /// optional baseIndentSize: number
  num? get baseIndentSize;
  /// optional indentSize: number
  num? get indentSize;
  /// optional tabSize: number
  num? get tabSize;
  /// optional newLineCharacter: string
  String? get newLineCharacter;
  /// optional convertTabsToSpaces: boolean
  bool? get convertTabsToSpaces;
  /// optional indentStyle: IndentStyle
  IndentStyle? get indentStyle;
  /// optional trimTrailingWhitespace: boolean
  bool? get trimTrailingWhitespace;
}

/// interface FormatCodeOptions extends EditorOptions
abstract class FormatCodeOptions {
  /// InsertSpaceAfterCommaDelimiter: boolean
  bool get InsertSpaceAfterCommaDelimiter;
  /// InsertSpaceAfterSemicolonInForStatements: boolean
  bool get InsertSpaceAfterSemicolonInForStatements;
  /// InsertSpaceBeforeAndAfterBinaryOperators: boolean
  bool get InsertSpaceBeforeAndAfterBinaryOperators;
  /// optional InsertSpaceAfterConstructor: boolean
  bool? get InsertSpaceAfterConstructor;
  /// InsertSpaceAfterKeywordsInControlFlowStatements: boolean
  bool get InsertSpaceAfterKeywordsInControlFlowStatements;
  /// InsertSpaceAfterFunctionKeywordForAnonymousFunctions: boolean
  bool get InsertSpaceAfterFunctionKeywordForAnonymousFunctions;
  /// InsertSpaceAfterOpeningAndBeforeClosingNonemptyParenthesis: boolean
  bool get InsertSpaceAfterOpeningAndBeforeClosingNonemptyParenthesis;
  /// InsertSpaceAfterOpeningAndBeforeClosingNonemptyBrackets: boolean
  bool get InsertSpaceAfterOpeningAndBeforeClosingNonemptyBrackets;
  /// optional InsertSpaceAfterOpeningAndBeforeClosingNonemptyBraces: boolean
  bool? get InsertSpaceAfterOpeningAndBeforeClosingNonemptyBraces;
  /// InsertSpaceAfterOpeningAndBeforeClosingTemplateStringBraces: boolean
  bool get InsertSpaceAfterOpeningAndBeforeClosingTemplateStringBraces;
  /// optional InsertSpaceAfterOpeningAndBeforeClosingJsxExpressionBraces: boolean
  bool? get InsertSpaceAfterOpeningAndBeforeClosingJsxExpressionBraces;
  /// optional InsertSpaceAfterTypeAssertion: boolean
  bool? get InsertSpaceAfterTypeAssertion;
  /// optional InsertSpaceBeforeFunctionParenthesis: boolean
  bool? get InsertSpaceBeforeFunctionParenthesis;
  /// PlaceOpenBraceOnNewLineForFunctions: boolean
  bool get PlaceOpenBraceOnNewLineForFunctions;
  /// PlaceOpenBraceOnNewLineForControlBlocks: boolean
  bool get PlaceOpenBraceOnNewLineForControlBlocks;
  /// optional insertSpaceBeforeTypeAnnotation: boolean
  bool? get insertSpaceBeforeTypeAnnotation;
}

/// interface FormatCodeSettings extends EditorSettings
abstract class FormatCodeSettings {
  /// optional insertSpaceAfterCommaDelimiter: boolean
  bool? get insertSpaceAfterCommaDelimiter;
  /// optional insertSpaceAfterSemicolonInForStatements: boolean
  bool? get insertSpaceAfterSemicolonInForStatements;
  /// optional insertSpaceBeforeAndAfterBinaryOperators: boolean
  bool? get insertSpaceBeforeAndAfterBinaryOperators;
  /// optional insertSpaceAfterConstructor: boolean
  bool? get insertSpaceAfterConstructor;
  /// optional insertSpaceAfterKeywordsInControlFlowStatements: boolean
  bool? get insertSpaceAfterKeywordsInControlFlowStatements;
  /// optional insertSpaceAfterFunctionKeywordForAnonymousFunctions: boolean
  bool? get insertSpaceAfterFunctionKeywordForAnonymousFunctions;
  /// optional insertSpaceAfterOpeningAndBeforeClosingNonemptyParenthesis: boolean
  bool? get insertSpaceAfterOpeningAndBeforeClosingNonemptyParenthesis;
  /// optional insertSpaceAfterOpeningAndBeforeClosingNonemptyBrackets: boolean
  bool? get insertSpaceAfterOpeningAndBeforeClosingNonemptyBrackets;
  /// optional insertSpaceAfterOpeningAndBeforeClosingNonemptyBraces: boolean
  bool? get insertSpaceAfterOpeningAndBeforeClosingNonemptyBraces;
  /// optional insertSpaceAfterOpeningAndBeforeClosingEmptyBraces: boolean
  bool? get insertSpaceAfterOpeningAndBeforeClosingEmptyBraces;
  /// optional insertSpaceAfterOpeningAndBeforeClosingTemplateStringBraces: boolean
  bool? get insertSpaceAfterOpeningAndBeforeClosingTemplateStringBraces;
  /// optional insertSpaceAfterOpeningAndBeforeClosingJsxExpressionBraces: boolean
  bool? get insertSpaceAfterOpeningAndBeforeClosingJsxExpressionBraces;
  /// optional insertSpaceAfterTypeAssertion: boolean
  bool? get insertSpaceAfterTypeAssertion;
  /// optional insertSpaceBeforeFunctionParenthesis: boolean
  bool? get insertSpaceBeforeFunctionParenthesis;
  /// optional placeOpenBraceOnNewLineForFunctions: boolean
  bool? get placeOpenBraceOnNewLineForFunctions;
  /// optional placeOpenBraceOnNewLineForControlBlocks: boolean
  bool? get placeOpenBraceOnNewLineForControlBlocks;
  /// optional insertSpaceBeforeTypeAnnotation: boolean
  bool? get insertSpaceBeforeTypeAnnotation;
  /// optional indentMultiLineObjectLiteralBeginningOnBlankLine: boolean
  bool? get indentMultiLineObjectLiteralBeginningOnBlankLine;
  /// optional semicolons: SemicolonPreference
  SemicolonPreference? get semicolons;
  /// optional indentSwitchCase: boolean
  bool? get indentSwitchCase;
}

/// interface DefinitionInfo extends DocumentSpan
abstract class DefinitionInfo {
  /// kind: ScriptElementKind
  ScriptElementKind get kind;
  /// name: string
  String get name;
  /// containerKind: ScriptElementKind
  ScriptElementKind get containerKind;
  /// containerName: string
  String get containerName;
  /// optional unverified: boolean
  bool? get unverified;
}

/// interface DefinitionInfoAndBoundSpan
abstract class DefinitionInfoAndBoundSpan {
  /// optional definitions: readonly DefinitionInfo[]
  List<DefinitionInfo>? get definitions;
  /// textSpan: TextSpan
  TextSpan get textSpan;
}

/// interface ReferencedSymbolDefinitionInfo extends DefinitionInfo
abstract class ReferencedSymbolDefinitionInfo {
  /// displayParts: SymbolDisplayPart[]
  List<SymbolDisplayPart> get displayParts;
}

/// interface ReferencedSymbol
abstract class ReferencedSymbol {
  /// definition: ReferencedSymbolDefinitionInfo
  ReferencedSymbolDefinitionInfo get definition;
  /// references: ReferencedSymbolEntry[]
  List<ReferencedSymbolEntry> get references;
}

/// interface ReferencedSymbolEntry extends ReferenceEntry
abstract class ReferencedSymbolEntry {
  /// optional isDefinition: boolean
  bool? get isDefinition;
}

/// interface SymbolDisplayPart
abstract class SymbolDisplayPart {
  /// text: string
  String get text;
  /// kind: string
  String get kind;
}

/// interface JSDocLinkDisplayPart extends SymbolDisplayPart
abstract class JSDocLinkDisplayPart {
  /// target: DocumentSpan
  DocumentSpan get target;
}

/// interface JSDocTagInfo
abstract class JSDocTagInfo {
  /// name: string
  String get name;
  /// optional text: SymbolDisplayPart[]
  List<SymbolDisplayPart>? get text;
}

/// interface QuickInfo
abstract class QuickInfo {
  /// kind: ScriptElementKind
  ScriptElementKind get kind;
  /// kindModifiers: string
  String get kindModifiers;
  /// textSpan: TextSpan
  TextSpan get textSpan;
  /// optional displayParts: SymbolDisplayPart[]
  List<SymbolDisplayPart>? get displayParts;
  /// optional documentation: SymbolDisplayPart[]
  List<SymbolDisplayPart>? get documentation;
  /// optional tags: JSDocTagInfo[]
  List<JSDocTagInfo>? get tags;
  /// optional canIncreaseVerbosityLevel: boolean
  bool? get canIncreaseVerbosityLevel;
}

/// interface RenameInfoSuccess
abstract class RenameInfoSuccess {
  /// canRename: true
  bool get canRename;
  /// optional fileToRename: string
  String? get fileToRename;
  /// displayName: string
  String get displayName;
  /// fullDisplayName: string
  String get fullDisplayName;
  /// kind: ScriptElementKind
  ScriptElementKind get kind;
  /// kindModifiers: string
  String get kindModifiers;
  /// triggerSpan: TextSpan
  TextSpan get triggerSpan;
}

/// interface RenameInfoFailure
abstract class RenameInfoFailure {
  /// canRename: false
  bool get canRename;
  /// localizedErrorMessage: string
  String get localizedErrorMessage;
}

/// interface RenameInfoOptions
abstract class RenameInfoOptions {
  /// optional allowRenameOfImportPath: boolean
  bool? get allowRenameOfImportPath;
}

/// interface DocCommentTemplateOptions
abstract class DocCommentTemplateOptions {
  /// optional generateReturnInDocTemplate: boolean
  bool? get generateReturnInDocTemplate;
}

/// interface InteractiveRefactorArguments
abstract class InteractiveRefactorArguments {
  /// targetFile: string
  String get targetFile;
}

/// interface SignatureHelpParameter
abstract class SignatureHelpParameter {
  /// name: string
  String get name;
  /// documentation: SymbolDisplayPart[]
  List<SymbolDisplayPart> get documentation;
  /// displayParts: SymbolDisplayPart[]
  List<SymbolDisplayPart> get displayParts;
  /// isOptional: boolean
  bool get isOptional;
  /// optional isRest: boolean
  bool? get isRest;
}

/// interface SelectionRange
abstract class SelectionRange {
  /// textSpan: TextSpan
  TextSpan get textSpan;
  /// optional parent: SelectionRange
  SelectionRange? get parent;
}

/// interface SignatureHelpItem
abstract class SignatureHelpItem {
  /// isVariadic: boolean
  bool get isVariadic;
  /// prefixDisplayParts: SymbolDisplayPart[]
  List<SymbolDisplayPart> get prefixDisplayParts;
  /// suffixDisplayParts: SymbolDisplayPart[]
  List<SymbolDisplayPart> get suffixDisplayParts;
  /// separatorDisplayParts: SymbolDisplayPart[]
  List<SymbolDisplayPart> get separatorDisplayParts;
  /// parameters: SignatureHelpParameter[]
  List<SignatureHelpParameter> get parameters;
  /// documentation: SymbolDisplayPart[]
  List<SymbolDisplayPart> get documentation;
  /// tags: JSDocTagInfo[]
  List<JSDocTagInfo> get tags;
}

/// interface SignatureHelpItems
abstract class SignatureHelpItems {
  /// items: SignatureHelpItem[]
  List<SignatureHelpItem> get items;
  /// applicableSpan: TextSpan
  TextSpan get applicableSpan;
  /// selectedItemIndex: number
  num get selectedItemIndex;
  /// argumentIndex: number
  num get argumentIndex;
  /// argumentCount: number
  num get argumentCount;
}

/// interface CompletionInfo
abstract class CompletionInfo {
  /// optional flags: CompletionInfoFlags
  CompletionInfoFlags? get flags;
  /// isGlobalCompletion: boolean
  bool get isGlobalCompletion;
  /// isMemberCompletion: boolean
  bool get isMemberCompletion;
  /// optional optionalReplacementSpan: TextSpan
  TextSpan? get optionalReplacementSpan;
  /// isNewIdentifierLocation: boolean
  bool get isNewIdentifierLocation;
  /// optional isIncomplete: true
  bool? get isIncomplete;
  /// entries: CompletionEntry[]
  List<CompletionEntry> get entries;
  /// optional defaultCommitCharacters: string[]
  List<String>? get defaultCommitCharacters;
}

/// interface CompletionEntryDataAutoImport
abstract class CompletionEntryDataAutoImport {
  /// exportName: string
  String get exportName;
  /// optional exportMapKey: ExportMapInfoKey
  ExportMapInfoKey? get exportMapKey;
  /// optional moduleSpecifier: string
  String? get moduleSpecifier;
  /// optional fileName: string
  String? get fileName;
  /// optional ambientModuleName: string
  String? get ambientModuleName;
  /// optional isPackageJsonImport: true
  bool? get isPackageJsonImport;
}

/// interface CompletionEntryDataUnresolved extends CompletionEntryDataAutoImport
abstract class CompletionEntryDataUnresolved {
  /// exportMapKey: ExportMapInfoKey
  ExportMapInfoKey get exportMapKey;
}

/// interface CompletionEntryDataResolved extends CompletionEntryDataAutoImport
abstract class CompletionEntryDataResolved {
  /// moduleSpecifier: string
  String get moduleSpecifier;
}

/// interface CompletionEntry
abstract class CompletionEntry {
  /// name: string
  String get name;
  /// kind: ScriptElementKind
  ScriptElementKind get kind;
  /// optional kindModifiers: string
  String? get kindModifiers;
  /// sortText: string
  String get sortText;
  /// optional insertText: string
  String? get insertText;
  /// optional filterText: string
  String? get filterText;
  /// optional isSnippet: true
  bool? get isSnippet;
  /// optional replacementSpan: TextSpan
  TextSpan? get replacementSpan;
  /// optional hasAction: true
  bool? get hasAction;
  /// optional source: string
  String? get source;
  /// optional sourceDisplay: SymbolDisplayPart[]
  List<SymbolDisplayPart>? get sourceDisplay;
  /// optional labelDetails: CompletionEntryLabelDetails
  CompletionEntryLabelDetails? get labelDetails;
  /// optional isRecommended: true
  bool? get isRecommended;
  /// optional isFromUncheckedFile: true
  bool? get isFromUncheckedFile;
  /// optional isPackageJsonImport: true
  bool? get isPackageJsonImport;
  /// optional isImportStatementCompletion: true
  bool? get isImportStatementCompletion;
  /// optional symbol: Symbol
  Symbol? get symbol;
  /// optional data: CompletionEntryData
  CompletionEntryData? get data;
  /// optional commitCharacters: string[]
  List<String>? get commitCharacters;
}

/// interface CompletionEntryLabelDetails
abstract class CompletionEntryLabelDetails {
  /// optional detail: string
  String? get detail;
  /// optional description: string
  String? get description;
}

/// interface CompletionEntryDetails
abstract class CompletionEntryDetails {
  /// name: string
  String get name;
  /// kind: ScriptElementKind
  ScriptElementKind get kind;
  /// kindModifiers: string
  String get kindModifiers;
  /// displayParts: SymbolDisplayPart[]
  List<SymbolDisplayPart> get displayParts;
  /// optional documentation: SymbolDisplayPart[]
  List<SymbolDisplayPart>? get documentation;
  /// optional tags: JSDocTagInfo[]
  List<JSDocTagInfo>? get tags;
  /// optional codeActions: CodeAction[]
  List<CodeAction>? get codeActions;
  /// optional source: SymbolDisplayPart[]
  List<SymbolDisplayPart>? get source;
  /// optional sourceDisplay: SymbolDisplayPart[]
  List<SymbolDisplayPart>? get sourceDisplay;
}

/// interface OutliningSpan
abstract class OutliningSpan {
  /// textSpan: TextSpan
  TextSpan get textSpan;
  /// hintSpan: TextSpan
  TextSpan get hintSpan;
  /// bannerText: string
  String get bannerText;
  /// autoCollapse: boolean
  bool get autoCollapse;
  /// kind: OutliningSpanKind
  OutliningSpanKind get kind;
}

/// interface ClassificationResult
abstract class ClassificationResult {
  /// finalLexState: EndOfLineState
  EndOfLineState get finalLexState;
  /// entries: ClassificationInfo[]
  List<ClassificationInfo> get entries;
}

/// interface ClassificationInfo
abstract class ClassificationInfo {
  /// length: number
  num get length;
  /// classification: TokenClass
  TokenClass get classification;
}

/// interface Classifier
abstract class Classifier {
  /// getClassificationsForLine(text: string, lexState: EndOfLineState, syntacticClassifierAbsent: boolean): ClassificationResult;
  ClassificationResult getClassificationsForLine(String text, EndOfLineState lexState, bool syntacticClassifierAbsent);
  /// getEncodedLexicalClassifications(text: string, endOfLineState: EndOfLineState, syntacticClassifierAbsent: boolean): Classifications;
  Classifications getEncodedLexicalClassifications(String text, EndOfLineState endOfLineState, bool syntacticClassifierAbsent);
}

/// interface InlayHintsContext
abstract class InlayHintsContext {
  /// file: SourceFile
  SourceFile get file;
  /// program: Program
  Program get program;
  /// cancellationToken: CancellationToken
  CancellationToken get cancellationToken;
  /// host: LanguageServiceHost
  LanguageServiceHost get host;
  /// span: TextSpan
  TextSpan get span;
  /// preferences: UserPreferences
  UserPreferences get preferences;
}

/// interface DocumentHighlights
abstract class DocumentHighlights {
  /// fileName: string
  String get fileName;
  /// highlightSpans: HighlightSpan[]
  List<HighlightSpan> get highlightSpans;
}

/// interface DocumentRegistry
abstract class DocumentRegistry {
  /// acquireDocument(fileName: string, compilationSettingsOrHost: CompilerOptions | MinimalResolutionCacheHost, scriptSnapshot: IScriptSnapshot, version: string, scriptKind?: ScriptKind, sourceFileOptions?: CreateSourceFileOptions | ScriptTarget): SourceFile;
  SourceFile acquireDocument(String fileName, Object? compilationSettingsOrHost, IScriptSnapshot scriptSnapshot, String version, [ScriptKind? scriptKind, Object? sourceFileOptions]);
  /// acquireDocumentWithKey(fileName: string, path: Path, compilationSettingsOrHost: CompilerOptions | MinimalResolutionCacheHost, key: DocumentRegistryBucketKey, scriptSnapshot: IScriptSnapshot, version: string, scriptKind?: ScriptKind, sourceFileOptions?: CreateSourceFileOptions | ScriptTarget): SourceFile;
  SourceFile acquireDocumentWithKey(String fileName, Path path, Object? compilationSettingsOrHost, DocumentRegistryBucketKey key, IScriptSnapshot scriptSnapshot, String version, [ScriptKind? scriptKind, Object? sourceFileOptions]);
  /// updateDocument(fileName: string, compilationSettingsOrHost: CompilerOptions | MinimalResolutionCacheHost, scriptSnapshot: IScriptSnapshot, version: string, scriptKind?: ScriptKind, sourceFileOptions?: CreateSourceFileOptions | ScriptTarget): SourceFile;
  SourceFile updateDocument(String fileName, Object? compilationSettingsOrHost, IScriptSnapshot scriptSnapshot, String version, [ScriptKind? scriptKind, Object? sourceFileOptions]);
  /// updateDocumentWithKey(fileName: string, path: Path, compilationSettingsOrHost: CompilerOptions | MinimalResolutionCacheHost, key: DocumentRegistryBucketKey, scriptSnapshot: IScriptSnapshot, version: string, scriptKind?: ScriptKind, sourceFileOptions?: CreateSourceFileOptions | ScriptTarget): SourceFile;
  SourceFile updateDocumentWithKey(String fileName, Path path, Object? compilationSettingsOrHost, DocumentRegistryBucketKey key, IScriptSnapshot scriptSnapshot, String version, [ScriptKind? scriptKind, Object? sourceFileOptions]);
  /// getKeyForCompilationSettings(settings: CompilerOptions): DocumentRegistryBucketKey;
  DocumentRegistryBucketKey getKeyForCompilationSettings(CompilerOptions settings);
  /// releaseDocument(fileName: string, compilationSettings: CompilerOptions, scriptKind?: ScriptKind): void;
  void releaseDocument(String fileName, CompilerOptions compilationSettings, [ScriptKind? scriptKind]);
  /// releaseDocument(fileName: string, compilationSettings: CompilerOptions, scriptKind: ScriptKind, impliedNodeFormat: ResolutionMode): void;
  void releaseDocument$1(String fileName, CompilerOptions compilationSettings, ScriptKind scriptKind, ResolutionMode impliedNodeFormat);
  /// releaseDocumentWithKey(path: Path, key: DocumentRegistryBucketKey, scriptKind?: ScriptKind): void;
  void releaseDocumentWithKey(Path path, DocumentRegistryBucketKey key, [ScriptKind? scriptKind]);
  /// releaseDocumentWithKey(path: Path, key: DocumentRegistryBucketKey, scriptKind: ScriptKind, impliedNodeFormat: ResolutionMode): void;
  void releaseDocumentWithKey$1(Path path, DocumentRegistryBucketKey key, ScriptKind scriptKind, ResolutionMode impliedNodeFormat);
  /// reportStats(): string;
  String reportStats();
}

/// interface TranspileOptions
abstract class TranspileOptions {
  /// optional compilerOptions: CompilerOptions
  CompilerOptions? get compilerOptions;
  /// optional fileName: string
  String? get fileName;
  /// optional reportDiagnostics: boolean
  bool? get reportDiagnostics;
  /// optional moduleName: string
  String? get moduleName;
  /// optional renamedDependencies: MapLike<string>
  MapLike<String>? get renamedDependencies;
  /// optional transformers: CustomTransformers
  CustomTransformers? get transformers;
  /// optional jsDocParsingMode: JSDocParsingMode
  JSDocParsingMode? get jsDocParsingMode;
}

/// interface TranspileOutput
abstract class TranspileOutput {
  /// outputText: string
  String get outputText;
  /// optional diagnostics: Diagnostic[]
  List<Diagnostic>? get diagnostics;
  /// optional sourceMapText: string
  String? get sourceMapText;
}

/// class TypingsInstaller  [ns: ts.server.typingsInstaller]
abstract class ServerTypingsInstallerTypingsInstaller {
  /// property installTypingHost: InstallTypingHost
  ServerInstallTypingHost get installTypingHost;
  /// property globalCachePath: 
  Object? get globalCachePath;
  /// property safeListPath: 
  Object? get safeListPath;
  /// property typesMapLocation: 
  Object? get typesMapLocation;
  /// property throttleLimit: 
  Object? get throttleLimit;
  /// property log: Log
  ServerTypingsInstallerLog get log;
  /// property packageNameToTypingLocation: 
  Object? get packageNameToTypingLocation;
  /// property missingTypingsSet: 
  Object? get missingTypingsSet;
  /// property knownCachesSet: 
  Object? get knownCachesSet;
  /// property projectWatchers: 
  Object? get projectWatchers;
  /// property safeList: 
  Object? get safeList;
  /// property pendingRunRequests: 
  Object? get pendingRunRequests;
  /// property installRunCount: 
  Object? get installRunCount;
  /// property inFlightRequestCount: 
  Object? get inFlightRequestCount;
  /// property typesRegistry: Map<string, MapLike<string>>
  Map<String, MapLike<String>> get typesRegistry;
  /// constructor(installTypingHost: InstallTypingHost, globalCachePath: string, safeListPath: Path, typesMapLocation: Path, throttleLimit: number, log?: Log);
  /// method: closeProject(req: CloseProject): void;
  void closeProject(ServerCloseProject req);
  /// property closeWatchers: 
  Object? get closeWatchers;
  /// method: install(req: DiscoverTypings): void;
  void install(ServerDiscoverTypings req);
  /// property initializeSafeList: 
  Object? get initializeSafeList;
  /// property processCacheLocation: 
  Object? get processCacheLocation;
  /// property filterTypings: 
  Object? get filterTypings;
  /// method: protected ensurePackageDirectoryExists(directory: string): void;
  void ensurePackageDirectoryExists(String directory);
  /// property installTypings: 
  Object? get installTypings;
  /// property ensureDirectoryExists: 
  Object? get ensureDirectoryExists;
  /// property watchFiles: 
  Object? get watchFiles;
  /// property createSetTypings: 
  Object? get createSetTypings;
  /// property installTypingsAsync: 
  Object? get installTypingsAsync;
  /// property executeWithThrottling: 
  Object? get executeWithThrottling;
  /// method: protected abstract installWorker(requestId: number, packageNames: string[], cwd: string, onRequestCompleted: RequestCompletedAction): void;
  void installWorker(num requestId, List<String> packageNames, String cwd, ServerTypingsInstallerRequestCompletedAction onRequestCompleted);
  /// method: protected abstract sendResponse(response: SetTypings | InvalidateCachedTypings | BeginInstallTypes | EndInstallTypes | WatchTypingLocations): void;
  void sendResponse(Object? response);
  /// property latestDistTag: 
  Object? get latestDistTag;
}

/// class ScriptInfo  [ns: ts.server]
abstract class ServerScriptInfo {
  /// property host: 
  Object? get host;
  /// property fileName: NormalizedPath
  ServerNormalizedPath get fileName;
  /// property scriptKind: ScriptKind
  ScriptKind get scriptKind;
  /// property hasMixedContent: boolean
  bool get hasMixedContent;
  /// property path: Path
  Path get path;
  /// property containingProjects: Project[]
  List<ServerProject> get containingProjects;
  /// property formatSettings: 
  Object? get formatSettings;
  /// property preferences: 
  Object? get preferences;
  /// property realpath: 
  Object? get realpath;
  /// constructor(host: ServerHost, fileName: NormalizedPath, scriptKind: ScriptKind, hasMixedContent: boolean, path: Path, initialVersion?: number);
  /// method: isScriptOpen(): boolean;
  bool isScriptOpen();
  /// method: open(newText: string | undefined): void;
  void open(String? newText);
  /// method: close(fileExists?: boolean): void;
  void close([bool? fileExists]);
  /// method: getSnapshot(): IScriptSnapshot;
  IScriptSnapshot getSnapshot();
  /// property ensureRealPath: 
  Object? get ensureRealPath;
  /// method: getFormatCodeSettings(): FormatCodeSettings | undefined;
  FormatCodeSettings? getFormatCodeSettings();
  /// method: getPreferences(): protocol.UserPreferences | undefined;
  UserPreferences? getPreferences();
  /// method: attachToProject(project: Project): boolean;
  bool attachToProject(ServerProject project);
  /// method: isAttached(project: Project): boolean;
  bool isAttached(ServerProject project);
  /// method: detachFromProject(project: Project): void;
  void detachFromProject(ServerProject project);
  /// method: detachAllProjects(): void;
  void detachAllProjects();
  /// method: getDefaultProject(): Project;
  ServerProject getDefaultProject();
  /// method: registerFileUpdate(): void;
  void registerFileUpdate();
  /// method: setOptions(formatSettings: FormatCodeSettings, preferences: protocol.UserPreferences | undefined): void;
  void setOptions(FormatCodeSettings formatSettings, UserPreferences? preferences);
  /// method: getLatestVersion(): string;
  String getLatestVersion();
  /// method: saveTo(fileName: string): void;
  void saveTo(String fileName);
  /// method: reloadFromFile(tempFileName?: NormalizedPath): boolean;
  bool reloadFromFile([ServerNormalizedPath? tempFileName]);
  /// method: editContent(start: number, end: number, newText: string): void;
  void editContent(num start, num end, String newText);
  /// method: markContainingProjectsAsDirty(): void;
  void markContainingProjectsAsDirty();
  /// method: isOrphan(): boolean;
  bool isOrphan();
  /// method: lineToTextSpan(line: number): TextSpan;
  TextSpan lineToTextSpan(num line);
  /// method: lineOffsetToPosition(line: number, offset: number): number;
  num lineOffsetToPosition(num line, num offset);
  /// method: positionToLineOffset(position: number): protocol.Location;
  ServerProtocolLocation positionToLineOffset(num position);
  /// method: isJavaScript(): boolean;
  bool isJavaScript();
}

/// class Project  [ns: ts.server]
abstract class ServerProject {
  /// property projectKind: ProjectKind
  ServerProjectKind get projectKind;
  /// property projectService: ProjectService
  ServerProjectService get projectService;
  /// property compilerOptions: 
  Object? get compilerOptions;
  /// property compileOnSaveEnabled: boolean
  bool get compileOnSaveEnabled;
  /// property watchOptions: WatchOptions | undefined
  WatchOptions? get watchOptions;
  /// property rootFilesMap: 
  Object? get rootFilesMap;
  /// property program: 
  Object? get program;
  /// property externalFiles: 
  Object? get externalFiles;
  /// property missingFilesMap: 
  Object? get missingFilesMap;
  /// property generatedFilesMap: 
  Object? get generatedFilesMap;
  /// property hasAddedorRemovedFiles: 
  Object? get hasAddedorRemovedFiles;
  /// property hasAddedOrRemovedSymlinks: 
  Object? get hasAddedOrRemovedSymlinks;
  /// property languageService: LanguageService
  LanguageService get languageService;
  /// property languageServiceEnabled: boolean
  bool get languageServiceEnabled;
  /// property trace: (s: string) => void
  Object? Function(Object?) get trace;
  /// property realpath: (path: string) => string
  Object? Function(Object?) get realpath;
  /// property builderState: 
  Object? get builderState;
  /// property updatedFileNames: 
  Object? get updatedFileNames;
  /// property lastReportedFileNames: 
  Object? get lastReportedFileNames;
  /// property lastReportedVersion: 
  Object? get lastReportedVersion;
  /// property projectErrors: Diagnostic[] | undefined
  List<Diagnostic>? get projectErrors;
  /// property typingsCache: 
  Object? get typingsCache;
  /// property typingWatchers: 
  Object? get typingWatchers;
  /// property cancellationToken: 
  Object? get cancellationToken;
  /// method: isNonTsProject(): boolean;
  bool isNonTsProject();
  /// method: isJsOnlyProject(): boolean;
  bool isJsOnlyProject();
  /// method: static resolveModule(moduleName: string, initialDir: string, host: ServerHost, log: (message: string) => void): {} | undefined;
  Map<String, Object?>? resolveModule(String moduleName, String initialDir, ServerServerHost host, Object? Function(Object?) log);
  /// property exportMapCache: 
  Object? get exportMapCache;
  /// property changedFilesForExportMapCache: 
  Object? get changedFilesForExportMapCache;
  /// property moduleSpecifierCache: 
  Object? get moduleSpecifierCache;
  /// property symlinks: 
  Object? get symlinks;
  /// property jsDocParsingMode: JSDocParsingMode | undefined
  JSDocParsingMode? get jsDocParsingMode;
  /// method: isKnownTypesPackageName(name: string): boolean;
  bool isKnownTypesPackageName(String name);
  /// method: installPackage(options: InstallPackageOptions): Promise<ApplyCodeActionCommandResult>;
  Future<ApplyCodeActionCommandResult> installPackage(InstallPackageOptions options);
  /// method: getCompilationSettings(): CompilerOptions;
  CompilerOptions getCompilationSettings();
  /// method: getCompilerOptions(): CompilerOptions;
  CompilerOptions getCompilerOptions();
  /// method: getNewLine(): string;
  String getNewLine();
  /// method: getProjectVersion(): string;
  String getProjectVersion();
  /// method: getProjectReferences(): readonly ProjectReference[] | undefined;
  List<ProjectReference>? getProjectReferences();
  /// method: getScriptFileNames(): string[];
  List<String> getScriptFileNames();
  /// property getOrCreateScriptInfoAndAttachToProject: 
  Object? get getOrCreateScriptInfoAndAttachToProject;
  /// method: getScriptKind(fileName: string): ScriptKind;
  ScriptKind getScriptKind(String fileName);
  /// method: getScriptVersion(filename: string): string;
  String getScriptVersion(String filename);
  /// method: getScriptSnapshot(filename: string): IScriptSnapshot | undefined;
  IScriptSnapshot? getScriptSnapshot(String filename);
  /// method: getCancellationToken(): HostCancellationToken;
  HostCancellationToken getCancellationToken();
  /// method: getCurrentDirectory(): string;
  String getCurrentDirectory();
  /// method: getDefaultLibFileName(): string;
  String getDefaultLibFileName();
  /// method: useCaseSensitiveFileNames(): boolean;
  bool useCaseSensitiveFileNames();
  /// method: readDirectory(path: string, extensions?: readonly string[], exclude?: readonly string[], include?: readonly string[], depth?: number): string[];
  List<String> readDirectory(String path, [List<String>? extensions, List<String>? exclude, List<String>? include, num? depth]);
  /// method: readFile(fileName: string): string | undefined;
  String? readFile(String fileName);
  /// method: writeFile(fileName: string, content: string): void;
  void writeFile(String fileName, String content);
  /// method: fileExists(file: string): boolean;
  bool fileExists(String file);
  /// method: directoryExists(path: string): boolean;
  bool directoryExists(String path);
  /// method: getDirectories(path: string): string[];
  List<String> getDirectories(String path);
  /// method: log(s: string): void;
  void log(String s);
  /// method: error(s: string): void;
  void error(String s);
  /// property setInternalCompilerOptionsForEmittingJsFiles: 
  Object? get setInternalCompilerOptionsForEmittingJsFiles;
  /// method: getGlobalProjectErrors(): readonly Diagnostic[];
  List<Diagnostic> getGlobalProjectErrors();
  /// method: getAllProjectErrors(): readonly Diagnostic[];
  List<Diagnostic> getAllProjectErrors();
  /// method: setProjectErrors(projectErrors: Diagnostic[] | undefined): void;
  void setProjectErrors(List<Diagnostic>? projectErrors);
  /// method: getLanguageService(ensureSynchronized?: boolean): LanguageService;
  LanguageService getLanguageService([bool? ensureSynchronized]);
  /// method: getCompileOnSaveAffectedFileList(scriptInfo: ScriptInfo): string[];
  List<String> getCompileOnSaveAffectedFileList(ServerScriptInfo scriptInfo);
  /// method: emitFile(scriptInfo: ScriptInfo, writeFile: (path: string, data: string, writeByteOrderMark?: boolean) => void): EmitResult;
  EmitResult emitFile(ServerScriptInfo scriptInfo, Object? Function(Object?) writeFile);
  /// method: enableLanguageService(): void;
  void enableLanguageService();
  /// method: disableLanguageService(lastFileExceededProgramSize?: string): void;
  void disableLanguageService([String? lastFileExceededProgramSize]);
  /// method: getProjectName(): string;
  String getProjectName();
  /// method: protected removeLocalTypingsFromTypeAcquisition(newTypeAcquisition: TypeAcquisition): TypeAcquisition;
  TypeAcquisition removeLocalTypingsFromTypeAcquisition(TypeAcquisition newTypeAcquisition);
  /// method: getExternalFiles(updateLevel?: ProgramUpdateLevel): SortedReadonlyArray<string>;
  List<String> getExternalFiles([ProgramUpdateLevel? updateLevel]);
  /// method: getSourceFile(path: Path): SourceFile | undefined;
  SourceFile? getSourceFile(Path path);
  /// method: close(): void;
  void close();
  /// property detachScriptInfoIfNotRoot: 
  Object? get detachScriptInfoIfNotRoot;
  /// method: isClosed(): boolean;
  bool isClosed();
  /// method: hasRoots(): boolean;
  bool hasRoots();
  /// method: getRootFiles(): NormalizedPath[];
  List<ServerNormalizedPath> getRootFiles();
  /// method: getRootScriptInfos(): ScriptInfo[];
  List<ServerScriptInfo> getRootScriptInfos();
  /// method: getScriptInfos(): ScriptInfo[];
  List<ServerScriptInfo> getScriptInfos();
  /// method: getExcludedFiles(): readonly NormalizedPath[];
  List<ServerNormalizedPath> getExcludedFiles();
  /// method: getFileNames(excludeFilesFromExternalLibraries?: boolean, excludeConfigFiles?: boolean): NormalizedPath[];
  List<ServerNormalizedPath> getFileNames([bool? excludeFilesFromExternalLibraries, bool? excludeConfigFiles]);
  /// method: hasConfigFile(configFilePath: NormalizedPath): boolean;
  bool hasConfigFile(ServerNormalizedPath configFilePath);
  /// method: containsScriptInfo(info: ScriptInfo): boolean;
  bool containsScriptInfo(ServerScriptInfo info);
  /// method: containsFile(filename: NormalizedPath, requireOpen?: boolean): boolean;
  bool containsFile(ServerNormalizedPath filename, [bool? requireOpen]);
  /// method: isRoot(info: ScriptInfo): boolean;
  bool isRoot(ServerScriptInfo info);
  /// method: addRoot(info: ScriptInfo, fileName?: NormalizedPath): void;
  void addRoot(ServerScriptInfo info, [ServerNormalizedPath? fileName]);
  /// method: addMissingFileRoot(fileName: NormalizedPath): void;
  void addMissingFileRoot(ServerNormalizedPath fileName);
  /// method: removeFile(info: ScriptInfo, fileExists: boolean, detachFromProject: boolean): void;
  void removeFile(ServerScriptInfo info, bool fileExists, bool detachFromProject);
  /// method: registerFileUpdate(fileName: string): void;
  void registerFileUpdate(String fileName);
  /// method: updateGraph(): boolean;
  bool updateGraph();
  /// property closeWatchingTypingLocations: 
  Object? get closeWatchingTypingLocations;
  /// property onTypingInstallerWatchInvoke: 
  Object? get onTypingInstallerWatchInvoke;
  /// method: protected removeExistingTypings(include: string[]): string[];
  List<String> removeExistingTypings(List<String> include);
  /// property updateGraphWorker: 
  Object? get updateGraphWorker;
  /// property detachScriptInfoFromProject: 
  Object? get detachScriptInfoFromProject;
  /// property addMissingFileWatcher: 
  Object? get addMissingFileWatcher;
  /// property isWatchedMissingFile: 
  Object? get isWatchedMissingFile;
  /// property createGeneratedFileWatcher: 
  Object? get createGeneratedFileWatcher;
  /// property isValidGeneratedFileWatcher: 
  Object? get isValidGeneratedFileWatcher;
  /// property clearGeneratedFileWatch: 
  Object? get clearGeneratedFileWatch;
  /// method: getScriptInfoForNormalizedPath(fileName: NormalizedPath): ScriptInfo | undefined;
  ServerScriptInfo? getScriptInfoForNormalizedPath(ServerNormalizedPath fileName);
  /// method: getScriptInfo(uncheckedFileName: string): ScriptInfo | undefined;
  ServerScriptInfo? getScriptInfo(String uncheckedFileName);
  /// method: filesToString(writeProjectFileNames: boolean): string;
  String filesToString(bool writeProjectFileNames);
  /// property filesToStringWorker: 
  Object? get filesToStringWorker;
  /// method: setCompilerOptions(compilerOptions: CompilerOptions): void;
  void setCompilerOptions(CompilerOptions compilerOptions);
  /// method: setTypeAcquisition(newTypeAcquisition: TypeAcquisition | undefined): void;
  void setTypeAcquisition(TypeAcquisition? newTypeAcquisition);
  /// method: getTypeAcquisition(): TypeAcquisition;
  TypeAcquisition getTypeAcquisition();
  /// method: protected removeRoot(info: ScriptInfo): void;
  void removeRoot(ServerScriptInfo info);
  /// method: protected enableGlobalPlugins(options: CompilerOptions): void;
  void enableGlobalPlugins(CompilerOptions options);
  /// method: protected enablePlugin(pluginConfigEntry: PluginImport, searchPaths: string[]): void;
  void enablePlugin(PluginImport pluginConfigEntry, List<String> searchPaths);
  /// method: refreshDiagnostics(): void;
  void refreshDiagnostics();
  /// property isDefaultProjectForOpenFiles: 
  Object? get isDefaultProjectForOpenFiles;
}

/// class InferredProject  [ns: ts.server]
abstract class ServerInferredProject {
  /// property _isJsInferredProject: 
  Object? get isJsInferredProject;
  /// method: toggleJsInferredProject(isJsInferredProject: boolean): void;
  void toggleJsInferredProject(bool isJsInferredProject);
  /// method: setCompilerOptions(options?: CompilerOptions): void;
  void setCompilerOptions([CompilerOptions? options]);
  /// property projectRootPath: string | undefined
  String? get projectRootPath;
  /// method: addRoot(info: ScriptInfo): void;
  void addRoot(ServerScriptInfo info);
  /// method: removeRoot(info: ScriptInfo): void;
  void removeRoot(ServerScriptInfo info);
  /// method: isProjectWithSingleRoot(): boolean;
  bool isProjectWithSingleRoot();
  /// method: close(): void;
  void close();
  /// method: getTypeAcquisition(): TypeAcquisition;
  TypeAcquisition getTypeAcquisition();
}

/// class AutoImportProviderProject  [ns: ts.server]
abstract class ServerAutoImportProviderProject {
  /// property hostProject: 
  Object? get hostProject;
  /// property maxDependencies: 
  Object? get maxDependencies;
  /// property rootFileNames: 
  Object? get rootFileNames;
  /// method: updateGraph(): boolean;
  bool updateGraph();
  /// method: hasRoots(): boolean;
  bool hasRoots();
  /// method: getScriptFileNames(): string[];
  List<String> getScriptFileNames();
  /// method: getLanguageService(): never;
  Null getLanguageService();
  /// method: getHostForAutoImportProvider(): never;
  Null getHostForAutoImportProvider();
  /// method: getProjectReferences(): readonly ProjectReference[] | undefined;
  List<ProjectReference>? getProjectReferences();
}

/// class ConfiguredProject  [ns: ts.server]
abstract class ServerConfiguredProject {
  /// property canonicalConfigFilePath: NormalizedPath
  ServerNormalizedPath get canonicalConfigFilePath;
  /// property projectReferences: 
  Object? get projectReferences;
  /// property compilerHost: 
  Object? get compilerHost;
  /// property releaseParsedConfig: 
  Object? get releaseParsedConfig;
  /// method: updateGraph(): boolean;
  bool updateGraph();
  /// method: getConfigFilePath(): NormalizedPath;
  ServerNormalizedPath getConfigFilePath();
  /// method: getProjectReferences(): readonly ProjectReference[] | undefined;
  List<ProjectReference>? getProjectReferences();
  /// method: updateReferences(refs: readonly ProjectReference[] | undefined): void;
  void updateReferences(List<ProjectReference>? refs);
  /// method: getGlobalProjectErrors(): readonly Diagnostic[];
  List<Diagnostic> getGlobalProjectErrors();
  /// method: getAllProjectErrors(): readonly Diagnostic[];
  List<Diagnostic> getAllProjectErrors();
  /// method: setProjectErrors(projectErrors: Diagnostic[]): void;
  void setProjectErrors(List<Diagnostic> projectErrors);
  /// method: close(): void;
  void close();
  /// method: getEffectiveTypeRoots(): string[];
  List<String> getEffectiveTypeRoots();
}

/// class ExternalProject  [ns: ts.server]
abstract class ServerExternalProject {
  /// property externalProjectName: string
  String get externalProjectName;
  /// property compileOnSaveEnabled: boolean
  bool get compileOnSaveEnabled;
  /// property excludedFiles: readonly NormalizedPath[]
  List<ServerNormalizedPath> get excludedFiles;
  /// method: updateGraph(): boolean;
  bool updateGraph();
  /// method: getExcludedFiles(): readonly NormalizedPath[];
  List<ServerNormalizedPath> getExcludedFiles();
}

/// class ProjectService  [ns: ts.server]
abstract class ServerProjectService {
  /// property nodeModulesWatchers: 
  Object? get nodeModulesWatchers;
  /// property filenameToScriptInfoVersion: 
  Object? get filenameToScriptInfoVersion;
  /// property allJsFilesForOpenFileTelemetry: 
  Object? get allJsFilesForOpenFileTelemetry;
  /// property externalProjectToConfiguredProjectMap: 
  Object? get externalProjectToConfiguredProjectMap;
  /// property externalProjects: ExternalProject[]
  List<ServerProtocolExternalProject> get externalProjects;
  /// property inferredProjects: InferredProject[]
  List<ServerInferredProject> get inferredProjects;
  /// property configuredProjects: Map<string, ConfiguredProject>
  Map<String, ServerConfiguredProject> get configuredProjects;
  /// property openFiles: Map<Path, NormalizedPath | undefined>
  Map<Path, ServerNormalizedPath?> get openFiles;
  /// property configFileForOpenFiles: 
  Object? get configFileForOpenFiles;
  /// property rootOfInferredProjects: 
  Object? get rootOfInferredProjects;
  /// property openFilesWithNonRootedDiskPath: 
  Object? get openFilesWithNonRootedDiskPath;
  /// property compilerOptionsForInferredProjects: 
  Object? get compilerOptionsForInferredProjects;
  /// property compilerOptionsForInferredProjectsPerProjectRoot: 
  Object? get compilerOptionsForInferredProjectsPerProjectRoot;
  /// property watchOptionsForInferredProjects: 
  Object? get watchOptionsForInferredProjects;
  /// property watchOptionsForInferredProjectsPerProjectRoot: 
  Object? get watchOptionsForInferredProjectsPerProjectRoot;
  /// property typeAcquisitionForInferredProjects: 
  Object? get typeAcquisitionForInferredProjects;
  /// property typeAcquisitionForInferredProjectsPerProjectRoot: 
  Object? get typeAcquisitionForInferredProjectsPerProjectRoot;
  /// property projectToSizeMap: 
  Object? get projectToSizeMap;
  /// property hostConfiguration: 
  Object? get hostConfiguration;
  /// property safelist: 
  Object? get safelist;
  /// property legacySafelist: 
  Object? get legacySafelist;
  /// property pendingProjectUpdates: 
  Object? get pendingProjectUpdates;
  /// property pendingOpenFileProjectUpdates: 
  Object? get pendingOpenFileProjectUpdates;
  /// property currentDirectory: NormalizedPath
  ServerNormalizedPath get currentDirectory;
  /// property toCanonicalFileName: (f: string) => string
  Object? Function(Object?) get toCanonicalFileName;
  /// property host: ServerHost
  ServerServerHost get host;
  /// property logger: Logger
  ServerLogger get logger;
  /// property cancellationToken: HostCancellationToken
  HostCancellationToken get cancellationToken;
  /// property useSingleInferredProject: boolean
  bool get useSingleInferredProject;
  /// property useInferredProjectPerProjectRoot: boolean
  bool get useInferredProjectPerProjectRoot;
  /// property typingsInstaller: ITypingsInstaller
  ServerITypingsInstaller get typingsInstaller;
  /// property globalCacheLocationDirectoryPath: 
  Object? get globalCacheLocationDirectoryPath;
  /// property throttleWaitMilliseconds: number
  num get throttleWaitMilliseconds;
  /// property suppressDiagnosticEvents: 
  Object? get suppressDiagnosticEvents;
  /// property globalPlugins: readonly string[]
  List<String> get globalPlugins;
  /// property pluginProbeLocations: readonly string[]
  List<String> get pluginProbeLocations;
  /// property allowLocalPluginLoads: boolean
  bool get allowLocalPluginLoads;
  /// property typesMapLocation: string | undefined
  String? get typesMapLocation;
  /// property serverMode: LanguageServiceMode
  LanguageServiceMode get serverMode;
  /// property seenProjects: 
  Object? get seenProjects;
  /// property sharedExtendedConfigFileWatchers: 
  Object? get sharedExtendedConfigFileWatchers;
  /// property extendedConfigCache: 
  Object? get extendedConfigCache;
  /// property packageJsonFilesMap: 
  Object? get packageJsonFilesMap;
  /// property incompleteCompletionsCache: 
  Object? get incompleteCompletionsCache;
  /// property performanceEventHandler: 
  Object? get performanceEventHandler;
  /// property pendingPluginEnablements: 
  Object? get pendingPluginEnablements;
  /// property currentPluginEnablementPromise: 
  Object? get currentPluginEnablementPromise;
  /// property jsDocParsingMode: JSDocParsingMode | undefined
  JSDocParsingMode? get jsDocParsingMode;
  /// constructor(opts: ProjectServiceOptions);
  /// method: toPath(fileName: string): Path;
  Path toPath(String fileName);
  /// property loadTypesMap: 
  Object? get loadTypesMap;
  /// method: updateTypingsForProject(response: SetTypings | InvalidateCachedTypings | PackageInstalledResponse): void;
  void updateTypingsForProject(Object? response);
  /// property delayUpdateProjectGraph: 
  Object? get delayUpdateProjectGraph;
  /// property delayUpdateProjectGraphs: 
  Object? get delayUpdateProjectGraphs;
  /// method: setCompilerOptionsForInferredProjects(projectCompilerOptions: protocol.InferredProjectCompilerOptions, projectRootPath?: string): void;
  void setCompilerOptionsForInferredProjects(ServerProtocolInferredProjectCompilerOptions projectCompilerOptions, [String? projectRootPath]);
  /// method: findProject(projectName: string): Project | undefined;
  ServerProject? findProject(String projectName);
  /// method: getDefaultProjectForFile(fileName: NormalizedPath, ensureProject: boolean): Project | undefined;
  ServerProject? getDefaultProjectForFile(ServerNormalizedPath fileName, bool ensureProject);
  /// property tryGetDefaultProjectForEnsuringConfiguredProjectForFile: 
  Object? get tryGetDefaultProjectForEnsuringConfiguredProjectForFile;
  /// property doEnsureDefaultProjectForFile: 
  Object? get doEnsureDefaultProjectForFile;
  /// method: getScriptInfoEnsuringProjectsUptoDate(uncheckedFileName: string): ScriptInfo | undefined;
  ServerScriptInfo? getScriptInfoEnsuringProjectsUptoDate(String uncheckedFileName);
  /// property ensureProjectStructuresUptoDate: 
  Object? get ensureProjectStructuresUptoDate;
  /// method: getFormatCodeOptions(file: NormalizedPath): FormatCodeSettings;
  FormatCodeSettings getFormatCodeOptions(ServerNormalizedPath file);
  /// method: getPreferences(file: NormalizedPath): protocol.UserPreferences;
  UserPreferences getPreferences(ServerNormalizedPath file);
  /// method: getHostFormatCodeOptions(): FormatCodeSettings;
  FormatCodeSettings getHostFormatCodeOptions();
  /// method: getHostPreferences(): protocol.UserPreferences;
  UserPreferences getHostPreferences();
  /// property onSourceFileChanged: 
  Object? get onSourceFileChanged;
  /// property handleSourceMapProjects: 
  Object? get handleSourceMapProjects;
  /// property delayUpdateSourceInfoProjects: 
  Object? get delayUpdateSourceInfoProjects;
  /// property delayUpdateProjectsOfScriptInfoPath: 
  Object? get delayUpdateProjectsOfScriptInfoPath;
  /// property handleDeletedFile: 
  Object? get handleDeletedFile;
  /// property watchWildcardDirectory: 
  Object? get watchWildcardDirectory;
  /// property onWildCardDirectoryWatcherInvoke: 
  Object? get onWildCardDirectoryWatcherInvoke;
  /// property delayUpdateProjectsFromParsedConfigOnConfigFileChange: 
  Object? get delayUpdateProjectsFromParsedConfigOnConfigFileChange;
  /// property onConfigFileChanged: 
  Object? get onConfigFileChanged;
  /// property removeProject: 
  Object? get removeProject;
  /// property assignOrphanScriptInfosToInferredProject: 
  Object? get assignOrphanScriptInfosToInferredProject;
  /// property closeOpenFile: 
  Object? get closeOpenFile;
  /// property deleteScriptInfo: 
  Object? get deleteScriptInfo;
  /// property configFileExists: 
  Object? get configFileExists;
  /// property createConfigFileWatcherForParsedConfig: 
  Object? get createConfigFileWatcherForParsedConfig;
  /// property ensureConfigFileWatcherForProject: 
  Object? get ensureConfigFileWatcherForProject;
  /// property forEachConfigFileLocation: 
  Object? get forEachConfigFileLocation;
  /// property getConfigFileNameForFileFromCache: 
  Object? get getConfigFileNameForFileFromCache;
  /// property setConfigFileNameForFileInCache: 
  Object? get setConfigFileNameForFileInCache;
  /// property printProjects: 
  Object? get printProjects;
  /// property getConfiguredProjectByCanonicalConfigFilePath: 
  Object? get getConfiguredProjectByCanonicalConfigFilePath;
  /// property findExternalProjectByProjectName: 
  Object? get findExternalProjectByProjectName;
  /// property getFilenameForExceededTotalSizeLimitForNonTsFiles: 
  Object? get getFilenameForExceededTotalSizeLimitForNonTsFiles;
  /// property createExternalProject: 
  Object? get createExternalProject;
  /// property addFilesToNonInferredProject: 
  Object? get addFilesToNonInferredProject;
  /// property loadConfiguredProject: 
  Object? get loadConfiguredProject;
  /// property updateNonInferredProjectFiles: 
  Object? get updateNonInferredProjectFiles;
  /// property updateRootAndOptionsOfNonInferredProject: 
  Object? get updateRootAndOptionsOfNonInferredProject;
  /// property reloadFileNamesOfParsedConfig: 
  Object? get reloadFileNamesOfParsedConfig;
  /// property setProjectForReload: 
  Object? get setProjectForReload;
  /// property clearSemanticCache: 
  Object? get clearSemanticCache;
  /// property getOrCreateInferredProjectForProjectRootPathIfEnabled: 
  Object? get getOrCreateInferredProjectForProjectRootPathIfEnabled;
  /// property getOrCreateSingleInferredProjectIfEnabled: 
  Object? get getOrCreateSingleInferredProjectIfEnabled;
  /// property getOrCreateSingleInferredWithoutProjectRoot: 
  Object? get getOrCreateSingleInferredWithoutProjectRoot;
  /// property createInferredProject: 
  Object? get createInferredProject;
  /// method: getScriptInfo(uncheckedFileName: string): ScriptInfo | undefined;
  ServerScriptInfo? getScriptInfo(String uncheckedFileName);
  /// property watchClosedScriptInfo: 
  Object? get watchClosedScriptInfo;
  /// property createNodeModulesWatcher: 
  Object? get createNodeModulesWatcher;
  /// property watchClosedScriptInfoInNodeModules: 
  Object? get watchClosedScriptInfoInNodeModules;
  /// property getModifiedTime: 
  Object? get getModifiedTime;
  /// property refreshScriptInfo: 
  Object? get refreshScriptInfo;
  /// property refreshScriptInfosInDirectory: 
  Object? get refreshScriptInfosInDirectory;
  /// property stopWatchingScriptInfo: 
  Object? get stopWatchingScriptInfo;
  /// property getOrCreateScriptInfoNotOpenedByClientForNormalizedPath: 
  Object? get getOrCreateScriptInfoNotOpenedByClientForNormalizedPath;
  /// method: getOrCreateScriptInfoForNormalizedPath(fileName: NormalizedPath, openedByClient: boolean, fileContent?: string, scriptKind?: ScriptKind, hasMixedContent?: boolean, hostToQueryFileExistsOn?: { fileExists(path: string): boolean; }): ScriptInfo | undefined;
  ServerScriptInfo? getOrCreateScriptInfoForNormalizedPath(ServerNormalizedPath fileName, bool openedByClient, [String? fileContent, ScriptKind? scriptKind, bool? hasMixedContent, Map<String, Object?>? hostToQueryFileExistsOn]);
  /// property getOrCreateScriptInfoWorker: 
  Object? get getOrCreateScriptInfoWorker;
  /// method: getScriptInfoForNormalizedPath(fileName: NormalizedPath): ScriptInfo | undefined;
  ServerScriptInfo? getScriptInfoForNormalizedPath(ServerNormalizedPath fileName);
  /// method: getScriptInfoForPath(fileName: Path): ScriptInfo | undefined;
  ServerScriptInfo? getScriptInfoForPath(Path fileName);
  /// property addSourceInfoToSourceMap: 
  Object? get addSourceInfoToSourceMap;
  /// property addMissingSourceMapFile: 
  Object? get addMissingSourceMapFile;
  /// method: setHostConfiguration(args: protocol.ConfigureRequestArguments): void;
  void setHostConfiguration(ServerProtocolConfigureRequestArguments args);
  /// property getWatchOptionsFromProjectWatchOptions: 
  Object? get getWatchOptionsFromProjectWatchOptions;
  /// method: closeLog(): void;
  void closeLog();
  /// property sendSourceFileChange: 
  Object? get sendSourceFileChange;
  /// method: reloadProjects(): void;
  void reloadProjects();
  /// property removeRootOfInferredProjectIfNowPartOfOtherProject: 
  Object? get removeRootOfInferredProjectIfNowPartOfOtherProject;
  /// property ensureProjectForOpenFiles: 
  Object? get ensureProjectForOpenFiles;
  /// method: openClientFile(fileName: string, fileContent?: string, scriptKind?: ScriptKind, projectRootPath?: string): OpenConfiguredProjectResult;
  ServerOpenConfiguredProjectResult openClientFile(String fileName, [String? fileContent, ScriptKind? scriptKind, String? projectRootPath]);
  /// property findExternalProjectContainingOpenScriptInfo: 
  Object? get findExternalProjectContainingOpenScriptInfo;
  /// property getOrCreateOpenScriptInfo: 
  Object? get getOrCreateOpenScriptInfo;
  /// property assignProjectToOpenedScriptInfo: 
  Object? get assignProjectToOpenedScriptInfo;
  /// property tryFindDefaultConfiguredProjectForOpenScriptInfo: 
  Object? get tryFindDefaultConfiguredProjectForOpenScriptInfo;
  /// property isMatchedByConfig: 
  Object? get isMatchedByConfig;
  /// property tryFindDefaultConfiguredProjectForOpenScriptInfoOrClosedFileInfo: 
  Object? get tryFindDefaultConfiguredProjectForOpenScriptInfoOrClosedFileInfo;
  /// property tryFindDefaultConfiguredProjectAndLoadAncestorsForOpenScriptInfo: 
  Object? get tryFindDefaultConfiguredProjectAndLoadAncestorsForOpenScriptInfo;
  /// property ensureProjectChildren: 
  Object? get ensureProjectChildren;
  /// property cleanupConfiguredProjects: 
  Object? get cleanupConfiguredProjects;
  /// property cleanupProjectsAndScriptInfos: 
  Object? get cleanupProjectsAndScriptInfos;
  /// property tryInvokeWildCardDirectories: 
  Object? get tryInvokeWildCardDirectories;
  /// method: openClientFileWithNormalizedPath(fileName: NormalizedPath, fileContent?: string, scriptKind?: ScriptKind, hasMixedContent?: boolean, projectRootPath?: NormalizedPath): OpenConfiguredProjectResult;
  ServerOpenConfiguredProjectResult openClientFileWithNormalizedPath(ServerNormalizedPath fileName, [String? fileContent, ScriptKind? scriptKind, bool? hasMixedContent, ServerNormalizedPath? projectRootPath]);
  /// property removeOrphanScriptInfos: 
  Object? get removeOrphanScriptInfos;
  /// property telemetryOnOpenFile: 
  Object? get telemetryOnOpenFile;
  /// method: closeClientFile(uncheckedFileName: string): void;
  void closeClientFile(String uncheckedFileName);
  /// property collectChanges: 
  Object? get collectChanges;
  /// method: closeExternalProject(uncheckedFileName: string): void;
  void closeExternalProject(String uncheckedFileName);
  /// method: openExternalProjects(projects: protocol.ExternalProject[]): void;
  void openExternalProjects(List<ServerProtocolExternalProject> projects);
  /// property filenameEscapeRegexp: 
  Object? get filenameEscapeRegexp;
  /// property escapeFilenameForRegex: 
  Object? get escapeFilenameForRegex;
  /// method: resetSafeList(): void;
  void resetSafeList();
  /// method: applySafeList(proj: protocol.ExternalProject): NormalizedPath[];
  List<ServerNormalizedPath> applySafeList(ServerProtocolExternalProject proj);
  /// property applySafeListWorker: 
  Object? get applySafeListWorker;
  /// method: openExternalProject(proj: protocol.ExternalProject): void;
  void openExternalProject(ServerProtocolExternalProject proj);
  /// method: hasDeferredExtension(): boolean;
  bool hasDeferredExtension();
  /// property endEnablePlugin: 
  Object? get endEnablePlugin;
  /// property enableRequestedPluginsAsync: 
  Object? get enableRequestedPluginsAsync;
  /// property enableRequestedPluginsWorker: 
  Object? get enableRequestedPluginsWorker;
  /// method: configurePlugin(args: protocol.ConfigurePluginRequestArguments): void;
  void configurePlugin(ServerProtocolConfigurePluginRequestArguments args);
  /// property watchPackageJsonFile: 
  Object? get watchPackageJsonFile;
  /// property onPackageJsonChange: 
  Object? get onPackageJsonChange;
}

/// class Session<TMessage>  [ns: ts.server]
abstract class ServerSession<TMessage> {
  /// property gcTimer: 
  Object? get gcTimer;
  /// property projectService: ProjectService
  ServerProjectService get projectService;
  /// property changeSeq: 
  Object? get changeSeq;
  /// property performanceData: 
  Object? get performanceData;
  /// property currentRequestId: 
  Object? get currentRequestId;
  /// property errorCheck: 
  Object? get errorCheck;
  /// property host: ServerHost
  ServerServerHost get host;
  /// property cancellationToken: 
  Object? get cancellationToken;
  /// property typingsInstaller: ITypingsInstaller
  ServerITypingsInstaller get typingsInstaller;
  /// property byteLength: (buf: string, encoding?: BufferEncoding) => number
  Object? Function(Object?) get byteLength;
  /// property hrtime: 
  Object? get hrtime;
  /// property logger: Logger
  ServerLogger get logger;
  /// property canUseEvents: boolean
  bool get canUseEvents;
  /// property suppressDiagnosticEvents: 
  Object? get suppressDiagnosticEvents;
  /// property eventHandler: 
  Object? get eventHandler;
  /// property noGetErrOnBackgroundUpdate: 
  Object? get noGetErrOnBackgroundUpdate;
  /// constructor(opts: SessionOptions);
  /// property sendRequestCompletedEvent: 
  Object? get sendRequestCompletedEvent;
  /// property addPerformanceData: 
  Object? get addPerformanceData;
  /// property addDiagnosticsPerformanceData: 
  Object? get addDiagnosticsPerformanceData;
  /// property performanceEventHandler: 
  Object? get performanceEventHandler;
  /// property defaultEventHandler: 
  Object? get defaultEventHandler;
  /// property projectsUpdatedInBackgroundEvent: 
  Object? get projectsUpdatedInBackgroundEvent;
  /// method: logError(err: Error, cmd: string): void;
  void logError(Error err, String cmd);
  /// property logErrorWorker: 
  Object? get logErrorWorker;
  /// method: send(msg: protocol.Message): void;
  void send(ServerProtocolMessage msg);
  /// method: protected writeMessage(msg: protocol.Message): void;
  void writeMessage(ServerProtocolMessage msg);
  /// method: event<T extends object>(body: T, eventName: string): void;
  void event<T>(T body, String eventName);
  /// property semanticCheck: 
  Object? get semanticCheck;
  /// property syntacticCheck: 
  Object? get syntacticCheck;
  /// property suggestionCheck: 
  Object? get suggestionCheck;
  /// property regionSemanticCheck: 
  Object? get regionSemanticCheck;
  /// property sendDiagnosticsEvent: 
  Object? get sendDiagnosticsEvent;
  /// property updateErrorCheck: 
  Object? get updateErrorCheck;
  /// property cleanProjects: 
  Object? get cleanProjects;
  /// property cleanup: 
  Object? get cleanup;
  /// property getEncodedSyntacticClassifications: 
  Object? get getEncodedSyntacticClassifications;
  /// property getEncodedSemanticClassifications: 
  Object? get getEncodedSemanticClassifications;
  /// property getProject: 
  Object? get getProject;
  /// property getConfigFileAndProject: 
  Object? get getConfigFileAndProject;
  /// property getConfigFileDiagnostics: 
  Object? get getConfigFileDiagnostics;
  /// property convertToDiagnosticsWithLinePositionFromDiagnosticFile: 
  Object? get convertToDiagnosticsWithLinePositionFromDiagnosticFile;
  /// property getCompilerOptionsDiagnostics: 
  Object? get getCompilerOptionsDiagnostics;
  /// property convertToDiagnosticsWithLinePosition: 
  Object? get convertToDiagnosticsWithLinePosition;
  /// property getDiagnosticsWorker: 
  Object? get getDiagnosticsWorker;
  /// property getDefinition: 
  Object? get getDefinition;
  /// property mapDefinitionInfoLocations: 
  Object? get mapDefinitionInfoLocations;
  /// property getDefinitionAndBoundSpan: 
  Object? get getDefinitionAndBoundSpan;
  /// property findSourceDefinition: 
  Object? get findSourceDefinition;
  /// property getEmitOutput: 
  Object? get getEmitOutput;
  /// property mapJSDocTagInfo: 
  Object? get mapJSDocTagInfo;
  /// property mapDisplayParts: 
  Object? get mapDisplayParts;
  /// property mapSignatureHelpItems: 
  Object? get mapSignatureHelpItems;
  /// property mapDefinitionInfo: 
  Object? get mapDefinitionInfo;
  /// property mapToOriginalLocation: 
  Object? get mapToOriginalLocation;
  /// property toFileSpan: 
  Object? get toFileSpan;
  /// property toFileSpanWithContext: 
  Object? get toFileSpanWithContext;
  /// property getTypeDefinition: 
  Object? get getTypeDefinition;
  /// property mapImplementationLocations: 
  Object? get mapImplementationLocations;
  /// property getImplementation: 
  Object? get getImplementation;
  /// property getSyntacticDiagnosticsSync: 
  Object? get getSyntacticDiagnosticsSync;
  /// property getSemanticDiagnosticsSync: 
  Object? get getSemanticDiagnosticsSync;
  /// property getSuggestionDiagnosticsSync: 
  Object? get getSuggestionDiagnosticsSync;
  /// property getJsxClosingTag: 
  Object? get getJsxClosingTag;
  /// property getLinkedEditingRange: 
  Object? get getLinkedEditingRange;
  /// property getDocumentHighlights: 
  Object? get getDocumentHighlights;
  /// property provideInlayHints: 
  Object? get provideInlayHints;
  /// property mapCode: 
  Object? get mapCode;
  /// property getCopilotRelatedInfo: 
  Object? get getCopilotRelatedInfo;
  /// property setCompilerOptionsForInferredProjects: 
  Object? get setCompilerOptionsForInferredProjects;
  /// property getProjectInfo: 
  Object? get getProjectInfo;
  /// property getProjectInfoWorker: 
  Object? get getProjectInfoWorker;
  /// property getDefaultConfiguredProjectInfo: 
  Object? get getDefaultConfiguredProjectInfo;
  /// property getRenameInfo: 
  Object? get getRenameInfo;
  /// property getProjects: 
  Object? get getProjects;
  /// property getDefaultProject: 
  Object? get getDefaultProject;
  /// property getRenameLocations: 
  Object? get getRenameLocations;
  /// property mapRenameInfo: 
  Object? get mapRenameInfo;
  /// property toSpanGroups: 
  Object? get toSpanGroups;
  /// property getReferences: 
  Object? get getReferences;
  /// property getFileReferences: 
  Object? get getFileReferences;
  /// property openClientFile: 
  Object? get openClientFile;
  /// property getPosition: 
  Object? get getPosition;
  /// property getPositionInFile: 
  Object? get getPositionInFile;
  /// property getFileAndProject: 
  Object? get getFileAndProject;
  /// property getFileAndLanguageServiceForSyntacticOperation: 
  Object? get getFileAndLanguageServiceForSyntacticOperation;
  /// property getFileAndProjectWorker: 
  Object? get getFileAndProjectWorker;
  /// property getOutliningSpans: 
  Object? get getOutliningSpans;
  /// property getTodoComments: 
  Object? get getTodoComments;
  /// property getDocCommentTemplate: 
  Object? get getDocCommentTemplate;
  /// property getSpanOfEnclosingComment: 
  Object? get getSpanOfEnclosingComment;
  /// property getIndentation: 
  Object? get getIndentation;
  /// property getBreakpointStatement: 
  Object? get getBreakpointStatement;
  /// property getNameOrDottedNameSpan: 
  Object? get getNameOrDottedNameSpan;
  /// property isValidBraceCompletion: 
  Object? get isValidBraceCompletion;
  /// property getQuickInfoWorker: 
  Object? get getQuickInfoWorker;
  /// property getFormattingEditsForRange: 
  Object? get getFormattingEditsForRange;
  /// property getFormattingEditsForRangeFull: 
  Object? get getFormattingEditsForRangeFull;
  /// property getFormattingEditsForDocumentFull: 
  Object? get getFormattingEditsForDocumentFull;
  /// property getFormattingEditsAfterKeystrokeFull: 
  Object? get getFormattingEditsAfterKeystrokeFull;
  /// property getFormattingEditsAfterKeystroke: 
  Object? get getFormattingEditsAfterKeystroke;
  /// property getCompletions: 
  Object? get getCompletions;
  /// property getCompletionEntryDetails: 
  Object? get getCompletionEntryDetails;
  /// property getCompileOnSaveAffectedFileList: 
  Object? get getCompileOnSaveAffectedFileList;
  /// property emitFile: 
  Object? get emitFile;
  /// property getSignatureHelpItems: 
  Object? get getSignatureHelpItems;
  /// property toPendingErrorCheck: 
  Object? get toPendingErrorCheck;
  /// property getDiagnostics: 
  Object? get getDiagnostics;
  /// property change: 
  Object? get change;
  /// property reload: 
  Object? get reload;
  /// property saveToTmp: 
  Object? get saveToTmp;
  /// property closeClientFile: 
  Object? get closeClientFile;
  /// property mapLocationNavigationBarItems: 
  Object? get mapLocationNavigationBarItems;
  /// property getNavigationBarItems: 
  Object? get getNavigationBarItems;
  /// property toLocationNavigationTree: 
  Object? get toLocationNavigationTree;
  /// property getNavigationTree: 
  Object? get getNavigationTree;
  /// property getNavigateToItems: 
  Object? get getNavigateToItems;
  /// property getFullNavigateToItems: 
  Object? get getFullNavigateToItems;
  /// property getSupportedCodeFixes: 
  Object? get getSupportedCodeFixes;
  /// property isLocation: 
  Object? get isLocation;
  /// property extractPositionOrRange: 
  Object? get extractPositionOrRange;
  /// property getRange: 
  Object? get getRange;
  /// property getApplicableRefactors: 
  Object? get getApplicableRefactors;
  /// property getEditsForRefactor: 
  Object? get getEditsForRefactor;
  /// property getMoveToRefactoringFileSuggestions: 
  Object? get getMoveToRefactoringFileSuggestions;
  /// property preparePasteEdits: 
  Object? get preparePasteEdits;
  /// property getPasteEdits: 
  Object? get getPasteEdits;
  /// property organizeImports: 
  Object? get organizeImports;
  /// property getEditsForFileRename: 
  Object? get getEditsForFileRename;
  /// property getCodeFixes: 
  Object? get getCodeFixes;
  /// property getCombinedCodeFix: 
  Object? get getCombinedCodeFix;
  /// property applyCodeActionCommand: 
  Object? get applyCodeActionCommand;
  /// property getStartAndEndPosition: 
  Object? get getStartAndEndPosition;
  /// property mapCodeAction: 
  Object? get mapCodeAction;
  /// property mapCodeFixAction: 
  Object? get mapCodeFixAction;
  /// property mapPasteEditsAction: 
  Object? get mapPasteEditsAction;
  /// property mapTextChangesToCodeEdits: 
  Object? get mapTextChangesToCodeEdits;
  /// property mapTextChangeToCodeEdit: 
  Object? get mapTextChangeToCodeEdit;
  /// property convertTextChangeToCodeEdit: 
  Object? get convertTextChangeToCodeEdit;
  /// property getBraceMatching: 
  Object? get getBraceMatching;
  /// property getDiagnosticsForProject: 
  Object? get getDiagnosticsForProject;
  /// property configurePlugin: 
  Object? get configurePlugin;
  /// property getSmartSelectionRange: 
  Object? get getSmartSelectionRange;
  /// property toggleLineComment: 
  Object? get toggleLineComment;
  /// property toggleMultilineComment: 
  Object? get toggleMultilineComment;
  /// property commentSelection: 
  Object? get commentSelection;
  /// property uncommentSelection: 
  Object? get uncommentSelection;
  /// property mapSelectionRange: 
  Object? get mapSelectionRange;
  /// property getScriptInfoFromProjectService: 
  Object? get getScriptInfoFromProjectService;
  /// property toProtocolCallHierarchyItem: 
  Object? get toProtocolCallHierarchyItem;
  /// property toProtocolCallHierarchyIncomingCall: 
  Object? get toProtocolCallHierarchyIncomingCall;
  /// property toProtocolCallHierarchyOutgoingCall: 
  Object? get toProtocolCallHierarchyOutgoingCall;
  /// property prepareCallHierarchy: 
  Object? get prepareCallHierarchy;
  /// property provideCallHierarchyIncomingCalls: 
  Object? get provideCallHierarchyIncomingCalls;
  /// property provideCallHierarchyOutgoingCalls: 
  Object? get provideCallHierarchyOutgoingCalls;
  /// method: getCanonicalFileName(fileName: string): string;
  String getCanonicalFileName(String fileName);
  /// method: exit(): void;
  void exit();
  /// property notRequired: 
  Object? get notRequired;
  /// property requiredResponse: 
  Object? get requiredResponse;
  /// property handlers: 
  Object? get handlers;
  /// method: addProtocolHandler(command: string, handler: (request: protocol.Request) => HandlerResponse): void;
  void addProtocolHandler(String command, Object? Function(Object?) handler);
  /// property setCurrentRequest: 
  Object? get setCurrentRequest;
  /// property resetCurrentRequest: 
  Object? get resetCurrentRequest;
  /// method: executeWithRequestId<T>(requestId: number, f: () => T): T;
  T executeWithRequestId<T>(num requestId, Object? Function(Object?) f);
  /// method: executeCommand(request: protocol.Request): HandlerResponse;
  ServerHandlerResponse executeCommand(ServerProtocolRequest request);
  /// method: onMessage(message: TMessage): void;
  void onMessage(TMessage message);
  /// method: protected parseMessage(message: TMessage): protocol.Request;
  ServerProtocolRequest parseMessage(TMessage message);
  /// method: protected toStringMessage(message: TMessage): string;
  String toStringMessage(TMessage message);
  /// property getFormatOptions: 
  Object? get getFormatOptions;
  /// property getPreferences: 
  Object? get getPreferences;
  /// property getHostFormatOptions: 
  Object? get getHostFormatOptions;
  /// property getHostPreferences: 
  Object? get getHostPreferences;
}

/// class OperationCanceledException
abstract class OperationCanceledException {
}

/// typedef ChangePropertyTypes = { [K in keyof T]: K extends keyof Substitutions ? Substitutions[K] : T[K]; }
typedef ServerProtocolChangePropertyTypes<T, Substitutions> = Object?;
/// typedef ChangeStringIndexSignature = { [K in keyof T]: string extends K ? NewStringIndexSignatureType : T[K]; }
typedef ServerProtocolChangeStringIndexSignature<T, NewStringIndexSignatureType> = Object?;
/// typedef DiagnosticPerformanceData = { [Kind in DiagnosticEventKind]?: number; }
typedef ServerProtocolDiagnosticPerformanceData = Object?;
/// typedef OutliningSpan = ChangePropertyTypes<ts.OutliningSpan, { textSpan: TextSpan; hintSpan: TextSpan; }>
typedef ServerProtocolOutliningSpan = ServerProtocolChangePropertyTypes<OutliningSpan, Map<String, Object?>>;
/// typedef FileLocationOrRangeRequestArgs = FileLocationRequestArgs | FileRangeRequestArgs
typedef ServerProtocolFileLocationOrRangeRequestArgs = Object?;
/// typedef GetApplicableRefactorsRequestArgs = FileLocationOrRangeRequestArgs & { triggerReason?: RefactorTriggerReason; kind?: string; /** * Include refactor actions that require additional arguments to be passed when * calling 'GetEditsForRefactor'. When true, clients should inspect the * `isInteractive` property of each returned `RefactorActionInfo` * and ensure they are able to collect the appropriate arguments for any * interactive refactor before offering it. */ includeInteractiveActions?: boolean; }
typedef ServerProtocolGetApplicableRefactorsRequestArgs = Object?;
/// typedef GetMoveToRefactoringFileSuggestionsRequestArgs = FileLocationOrRangeRequestArgs & { kind?: string; }
typedef ServerProtocolGetMoveToRefactoringFileSuggestionsRequestArgs = Object?;
/// typedef GetEditsForRefactorRequestArgs = FileLocationOrRangeRequestArgs & { refactor: string; action: string; interactiveRefactorArguments?: InteractiveRefactorArguments; }
typedef ServerProtocolGetEditsForRefactorRequestArgs = Object?;
/// typedef OrganizeImportsScope = GetCombinedCodeFixScope
typedef ServerProtocolOrganizeImportsScope = ServerProtocolGetCombinedCodeFixScope;
/// typedef DefinitionInfoAndBoundSpanReponse = DefinitionInfoAndBoundSpanResponse
typedef ServerProtocolDefinitionInfoAndBoundSpanReponse = ServerProtocolDefinitionInfoAndBoundSpanResponse;
/// typedef RenameInfo = RenameInfoSuccess | RenameInfoFailure
typedef ServerProtocolRenameInfo = Object?;
/// typedef RenameInfoSuccess = ChangePropertyTypes<ts.RenameInfoSuccess, { triggerSpan: TextSpan; }>
typedef ServerProtocolRenameInfoSuccess = ServerProtocolChangePropertyTypes<RenameInfoSuccess, Map<String, Object?>>;
/// typedef ExternalProjectCompilerOptions = CompilerOptions & CompileOnSaveMixin & WatchOptions
typedef ServerProtocolExternalProjectCompilerOptions = Object?;
/// typedef ScriptKindName = "TS" | "JS" | "TSX" | "JSX"
typedef ServerProtocolScriptKindName = Object?;
/// typedef OpenExternalProjectArgs = ExternalProject
typedef ServerProtocolOpenExternalProjectArgs = ServerProtocolExternalProject;
/// typedef InferredProjectCompilerOptions = ExternalProjectCompilerOptions & TypeAcquisition
typedef ServerProtocolInferredProjectCompilerOptions = Object?;
/// typedef CompletionEntry = ChangePropertyTypes<Omit<ts.CompletionEntry, "symbol">, { replacementSpan: TextSpan; data: unknown; }>
typedef ServerProtocolCompletionEntry = ServerProtocolChangePropertyTypes<Map<String, Object?>, Map<String, Object?>>;
/// typedef CompletionEntryDetails = ChangePropertyTypes<ts.CompletionEntryDetails, { tags: JSDocTagInfo[]; codeActions: CodeAction[]; }>
typedef ServerProtocolCompletionEntryDetails = ServerProtocolChangePropertyTypes<CompletionEntryDetails, Map<String, Object?>>;
/// typedef CompletionInfo = ChangePropertyTypes<ts.CompletionInfo, { entries: readonly CompletionEntry[]; optionalReplacementSpan: TextSpan; }>
typedef ServerProtocolCompletionInfo = ServerProtocolChangePropertyTypes<CompletionInfo, Map<String, Object?>>;
/// typedef SignatureHelpItem = ChangePropertyTypes<ts.SignatureHelpItem, { tags: JSDocTagInfo[]; }>
typedef ServerProtocolSignatureHelpItem = ServerProtocolChangePropertyTypes<SignatureHelpItem, Map<String, Object?>>;
/// typedef InlayHintItem = ChangePropertyTypes<ts.InlayHint, { position: Location; displayParts: InlayHintItemDisplayPart[]; }>
typedef ServerProtocolInlayHintItem = ServerProtocolChangePropertyTypes<InlayHint, Map<String, Object?>>;
/// typedef SuggestionDiagnosticsSyncRequestArgs = SemanticDiagnosticsSyncRequestArgs
typedef ServerProtocolSuggestionDiagnosticsSyncRequestArgs = ServerProtocolSemanticDiagnosticsSyncRequestArgs;
/// typedef SuggestionDiagnosticsSyncResponse = SemanticDiagnosticsSyncResponse
typedef ServerProtocolSuggestionDiagnosticsSyncResponse = ServerProtocolSemanticDiagnosticsSyncResponse;
/// typedef RequestCompletedEventName = "requestCompleted"
typedef ServerProtocolRequestCompletedEventName = String;
/// typedef DiagnosticEventKind = "semanticDiag" | "syntaxDiag" | "suggestionDiag" | "regionSemanticDiag"
typedef ServerProtocolDiagnosticEventKind = Object?;
/// typedef ProjectLanguageServiceStateEventName = "projectLanguageServiceState"
typedef ServerProtocolProjectLanguageServiceStateEventName = String;
/// typedef ProjectsUpdatedInBackgroundEventName = "projectsUpdatedInBackground"
typedef ServerProtocolProjectsUpdatedInBackgroundEventName = String;
/// typedef ProjectLoadingStartEventName = "projectLoadingStart"
typedef ServerProtocolProjectLoadingStartEventName = String;
/// typedef ProjectLoadingFinishEventName = "projectLoadingFinish"
typedef ServerProtocolProjectLoadingFinishEventName = String;
/// typedef SurveyReadyEventName = "surveyReady"
typedef ServerProtocolSurveyReadyEventName = String;
/// typedef LargeFileReferencedEventName = "largeFileReferenced"
typedef ServerProtocolLargeFileReferencedEventName = String;
/// typedef CreateFileWatcherEventName = "createFileWatcher"
typedef ServerProtocolCreateFileWatcherEventName = String;
/// typedef CreateDirectoryWatcherEventName = "createDirectoryWatcher"
typedef ServerProtocolCreateDirectoryWatcherEventName = String;
/// typedef CloseFileWatcherEventName = "closeFileWatcher"
typedef ServerProtocolCloseFileWatcherEventName = String;
/// typedef TelemetryEventName = "telemetry"
typedef ServerProtocolTelemetryEventName = String;
/// typedef TypesInstallerInitializationFailedEventName = "typesInstallerInitializationFailed"
typedef ServerProtocolTypesInstallerInitializationFailedEventName = String;
/// typedef TypingsInstalledTelemetryEventName = "typingsInstalled"
typedef ServerProtocolTypingsInstalledTelemetryEventName = String;
/// typedef BeginInstallTypesEventName = "beginInstallTypes"
typedef ServerProtocolBeginInstallTypesEventName = String;
/// typedef EndInstallTypesEventName = "endInstallTypes"
typedef ServerProtocolEndInstallTypesEventName = String;
/// typedef CallHierarchyItem = ChangePropertyTypes<ts.CallHierarchyItem, { span: TextSpan; selectionSpan: TextSpan; }>
typedef ServerProtocolCallHierarchyItem = ServerProtocolChangePropertyTypes<CallHierarchyItem, Map<String, Object?>>;
/// typedef EditorSettings = ChangePropertyTypes<ts.EditorSettings, { indentStyle: IndentStyle | ts.IndentStyle; }>
typedef ServerProtocolEditorSettings = ServerProtocolChangePropertyTypes<EditorSettings, Map<String, Object?>>;
/// typedef FormatCodeSettings = ChangePropertyTypes<ts.FormatCodeSettings, { indentStyle: IndentStyle | ts.IndentStyle; }>
typedef ServerProtocolFormatCodeSettings = ServerProtocolChangePropertyTypes<FormatCodeSettings, Map<String, Object?>>;
/// typedef CompilerOptions = ChangePropertyTypes<ChangeStringIndexSignature<ts.CompilerOptions, CompilerOptionsValue>, { jsx: JsxEmit | ts.JsxEmit; module: ModuleKind | ts.ModuleKind; moduleResolution: ModuleResolutionKind | ts.ModuleResolutionKind; newLine: NewLineKind | ts.NewLineKind; target: ScriptTarget | ts.ScriptTarget; }>
typedef ServerProtocolCompilerOptions = ServerProtocolChangePropertyTypes<ServerProtocolChangeStringIndexSignature<CompilerOptions, CompilerOptionsValue>, Map<String, Object?>>;
/// typedef RequestCompletedAction = (success: boolean) => void
typedef ServerTypingsInstallerRequestCompletedAction = Object? Function(Object?);
/// typedef ActionSet = "action::set"
typedef ServerActionSet = String;
/// typedef ActionInvalidate = "action::invalidate"
typedef ServerActionInvalidate = String;
/// typedef ActionPackageInstalled = "action::packageInstalled"
typedef ServerActionPackageInstalled = String;
/// typedef EventTypesRegistry = "event::typesRegistry"
typedef ServerEventTypesRegistry = String;
/// typedef EventBeginInstallTypes = "event::beginInstallTypes"
typedef ServerEventBeginInstallTypes = String;
/// typedef EventEndInstallTypes = "event::endInstallTypes"
typedef ServerEventEndInstallTypes = String;
/// typedef EventInitializationFailed = "event::initializationFailed"
typedef ServerEventInitializationFailed = String;
/// typedef ActionWatchTypingLocations = "action::watchTypingLocations"
typedef ServerActionWatchTypingLocations = String;
/// typedef ModuleImportResult = { module: {}; error: undefined; } | { module: undefined; error: { stack?: string; message?: string; }; }
typedef ServerModuleImportResult = Object?;
/// typedef RequireResult = ModuleImportResult
typedef ServerRequireResult = ServerModuleImportResult;
/// typedef NormalizedPath = string & { __normalizedPathTag: any; }
typedef ServerNormalizedPath = Object?;
/// typedef PluginModuleFactory = (mod: { typescript: typeof ts; }) => PluginModule
typedef ServerPluginModuleFactory = Object? Function(Object?);
/// typedef ProjectServiceEvent = LargeFileReferencedEvent | ProjectsUpdatedInBackgroundEvent | ProjectLoadingStartEvent | ProjectLoadingFinishEvent | ConfigFileDiagEvent | ProjectLanguageServiceStateEvent | ProjectInfoTelemetryEvent | OpenFileInfoTelemetryEvent | CreateFileWatcherEvent | CreateDirectoryWatcherEvent | CloseFileWatcherEvent
typedef ServerProjectServiceEvent = Object?;
/// typedef ProjectServiceEventHandler = (event: ProjectServiceEvent) => void
typedef ServerProjectServiceEventHandler = Object? Function(Object?);
/// typedef CommandNames = protocol.CommandTypes
typedef ServerCommandNames = ServerProtocolCommandTypes;
/// typedef Event = <T extends object>(body: T, eventName: string) => void
typedef ServerEvent = Object? Function(Object?);
/// typedef Path = string & { __pathBrand: any; }
typedef Path = Object?;
/// typedef TriviaSyntaxKind = SyntaxKind.SingleLineCommentTrivia | SyntaxKind.MultiLineCommentTrivia | SyntaxKind.NewLineTrivia | SyntaxKind.WhitespaceTrivia | SyntaxKind.ShebangTrivia | SyntaxKind.ConflictMarkerTrivia
typedef TriviaSyntaxKind = Object?;
/// typedef LiteralSyntaxKind = SyntaxKind.NumericLiteral | SyntaxKind.BigIntLiteral | SyntaxKind.StringLiteral | SyntaxKind.JsxText | SyntaxKind.JsxTextAllWhiteSpaces | SyntaxKind.RegularExpressionLiteral | SyntaxKind.NoSubstitutionTemplateLiteral
typedef LiteralSyntaxKind = Object?;
/// typedef PseudoLiteralSyntaxKind = SyntaxKind.TemplateHead | SyntaxKind.TemplateMiddle | SyntaxKind.TemplateTail
typedef PseudoLiteralSyntaxKind = Object?;
/// typedef PunctuationSyntaxKind = | SyntaxKind.OpenBraceToken | SyntaxKind.CloseBraceToken | SyntaxKind.OpenParenToken | SyntaxKind.CloseParenToken | SyntaxKind.OpenBracketToken | SyntaxKind.CloseBracketToken | SyntaxKind.DotToken | SyntaxKind.DotDotDotToken | SyntaxKind.SemicolonToken | SyntaxKind.CommaToken | SyntaxKind.QuestionDotToken | SyntaxKind.LessThanToken | SyntaxKind.LessThanSlashToken | SyntaxKind.GreaterThanToken | SyntaxKind.LessThanEqualsToken | SyntaxKind.GreaterThanEqualsToken | SyntaxKind.EqualsEqualsToken | SyntaxKind.ExclamationEqualsToken | SyntaxKind.EqualsEqualsEqualsToken | SyntaxKind.ExclamationEqualsEqualsToken | SyntaxKind.EqualsGreaterThanToken | SyntaxKind.PlusToken | SyntaxKind.MinusToken | SyntaxKind.AsteriskToken | SyntaxKind.AsteriskAsteriskToken | SyntaxKind.SlashToken | SyntaxKind.PercentToken | SyntaxKind.PlusPlusToken | SyntaxKind.MinusMinusToken | SyntaxKind.LessThanLessThanToken | SyntaxKind.GreaterThanGreaterThanToken | SyntaxKind.GreaterThanGreaterThanGreaterThanToken | SyntaxKind.AmpersandToken | SyntaxKind.BarToken | SyntaxKind.CaretToken | SyntaxKind.ExclamationToken | SyntaxKind.TildeToken | SyntaxKind.AmpersandAmpersandToken | SyntaxKind.AmpersandAmpersandEqualsToken | SyntaxKind.BarBarToken | SyntaxKind.BarBarEqualsToken | SyntaxKind.QuestionQuestionToken | SyntaxKind.QuestionQuestionEqualsToken | SyntaxKind.QuestionToken | SyntaxKind.ColonToken | SyntaxKind.AtToken | SyntaxKind.BacktickToken | SyntaxKind.HashToken | SyntaxKind.EqualsToken | SyntaxKind.PlusEqualsToken | SyntaxKind.MinusEqualsToken | SyntaxKind.AsteriskEqualsToken | SyntaxKind.AsteriskAsteriskEqualsToken | SyntaxKind.SlashEqualsToken | SyntaxKind.PercentEqualsToken | SyntaxKind.LessThanLessThanEqualsToken | SyntaxKind.GreaterThanGreaterThanEqualsToken | SyntaxKind.GreaterThanGreaterThanGreaterThanEqualsToken | SyntaxKind.AmpersandEqualsToken | SyntaxKind.BarEqualsToken | SyntaxKind.CaretEqualsToken
typedef PunctuationSyntaxKind = Object?;
/// typedef KeywordSyntaxKind = | SyntaxKind.AbstractKeyword | SyntaxKind.AccessorKeyword | SyntaxKind.AnyKeyword | SyntaxKind.AsKeyword | SyntaxKind.AssertsKeyword | SyntaxKind.AssertKeyword | SyntaxKind.AsyncKeyword | SyntaxKind.AwaitKeyword | SyntaxKind.BigIntKeyword | SyntaxKind.BooleanKeyword | SyntaxKind.BreakKeyword | SyntaxKind.CaseKeyword | SyntaxKind.CatchKeyword | SyntaxKind.ClassKeyword | SyntaxKind.ConstKeyword | SyntaxKind.ConstructorKeyword | SyntaxKind.ContinueKeyword | SyntaxKind.DebuggerKeyword | SyntaxKind.DeclareKeyword | SyntaxKind.DefaultKeyword | SyntaxKind.DeferKeyword | SyntaxKind.DeleteKeyword | SyntaxKind.DoKeyword | SyntaxKind.ElseKeyword | SyntaxKind.EnumKeyword | SyntaxKind.ExportKeyword | SyntaxKind.ExtendsKeyword | SyntaxKind.FalseKeyword | SyntaxKind.FinallyKeyword | SyntaxKind.ForKeyword | SyntaxKind.FromKeyword | SyntaxKind.FunctionKeyword | SyntaxKind.GetKeyword | SyntaxKind.GlobalKeyword | SyntaxKind.IfKeyword | SyntaxKind.ImplementsKeyword | SyntaxKind.ImportKeyword | SyntaxKind.InferKeyword | SyntaxKind.InKeyword | SyntaxKind.InstanceOfKeyword | SyntaxKind.InterfaceKeyword | SyntaxKind.IntrinsicKeyword | SyntaxKind.IsKeyword | SyntaxKind.KeyOfKeyword | SyntaxKind.LetKeyword | SyntaxKind.ModuleKeyword | SyntaxKind.NamespaceKeyword | SyntaxKind.NeverKeyword | SyntaxKind.NewKeyword | SyntaxKind.NullKeyword | SyntaxKind.NumberKeyword | SyntaxKind.ObjectKeyword | SyntaxKind.OfKeyword | SyntaxKind.PackageKeyword | SyntaxKind.PrivateKeyword | SyntaxKind.ProtectedKeyword | SyntaxKind.PublicKeyword | SyntaxKind.ReadonlyKeyword | SyntaxKind.OutKeyword | SyntaxKind.OverrideKeyword | SyntaxKind.RequireKeyword | SyntaxKind.ReturnKeyword | SyntaxKind.SatisfiesKeyword | SyntaxKind.SetKeyword | SyntaxKind.StaticKeyword | SyntaxKind.StringKeyword | SyntaxKind.SuperKeyword | SyntaxKind.SwitchKeyword | SyntaxKind.SymbolKeyword | SyntaxKind.ThisKeyword | SyntaxKind.ThrowKeyword | SyntaxKind.TrueKeyword | SyntaxKind.TryKeyword | SyntaxKind.TypeKeyword | SyntaxKind.TypeOfKeyword | SyntaxKind.UndefinedKeyword | SyntaxKind.UniqueKeyword | SyntaxKind.UnknownKeyword | SyntaxKind.UsingKeyword | SyntaxKind.VarKeyword | SyntaxKind.VoidKeyword | SyntaxKind.WhileKeyword | SyntaxKind.WithKeyword | SyntaxKind.YieldKeyword
typedef KeywordSyntaxKind = Object?;
/// typedef ModifierSyntaxKind = SyntaxKind.AbstractKeyword | SyntaxKind.AccessorKeyword | SyntaxKind.AsyncKeyword | SyntaxKind.ConstKeyword | SyntaxKind.DeclareKeyword | SyntaxKind.DefaultKeyword | SyntaxKind.ExportKeyword | SyntaxKind.InKeyword | SyntaxKind.PrivateKeyword | SyntaxKind.ProtectedKeyword | SyntaxKind.PublicKeyword | SyntaxKind.ReadonlyKeyword | SyntaxKind.OutKeyword | SyntaxKind.OverrideKeyword | SyntaxKind.StaticKeyword
typedef ModifierSyntaxKind = Object?;
/// typedef KeywordTypeSyntaxKind = SyntaxKind.AnyKeyword | SyntaxKind.BigIntKeyword | SyntaxKind.BooleanKeyword | SyntaxKind.IntrinsicKeyword | SyntaxKind.NeverKeyword | SyntaxKind.NumberKeyword | SyntaxKind.ObjectKeyword | SyntaxKind.StringKeyword | SyntaxKind.SymbolKeyword | SyntaxKind.UndefinedKeyword | SyntaxKind.UnknownKeyword | SyntaxKind.VoidKeyword
typedef KeywordTypeSyntaxKind = Object?;
/// typedef TokenSyntaxKind = SyntaxKind.Unknown | SyntaxKind.EndOfFileToken | TriviaSyntaxKind | LiteralSyntaxKind | PseudoLiteralSyntaxKind | PunctuationSyntaxKind | SyntaxKind.Identifier | KeywordSyntaxKind
typedef TokenSyntaxKind = Object?;
/// typedef JsxTokenSyntaxKind = SyntaxKind.LessThanSlashToken | SyntaxKind.EndOfFileToken | SyntaxKind.ConflictMarkerTrivia | SyntaxKind.JsxText | SyntaxKind.JsxTextAllWhiteSpaces | SyntaxKind.OpenBraceToken | SyntaxKind.LessThanToken
typedef JsxTokenSyntaxKind = Object?;
/// typedef JSDocSyntaxKind = SyntaxKind.EndOfFileToken | SyntaxKind.WhitespaceTrivia | SyntaxKind.AtToken | SyntaxKind.NewLineTrivia | SyntaxKind.AsteriskToken | SyntaxKind.OpenBraceToken | SyntaxKind.CloseBraceToken | SyntaxKind.LessThanToken | SyntaxKind.GreaterThanToken | SyntaxKind.OpenBracketToken | SyntaxKind.CloseBracketToken | SyntaxKind.OpenParenToken | SyntaxKind.CloseParenToken | SyntaxKind.EqualsToken | SyntaxKind.CommaToken | SyntaxKind.DotToken | SyntaxKind.Identifier | SyntaxKind.BacktickToken | SyntaxKind.HashToken | SyntaxKind.Unknown | KeywordSyntaxKind
typedef JSDocSyntaxKind = Object?;
/// typedef HasJSDoc = | AccessorDeclaration | ArrowFunction | BinaryExpression | Block | BreakStatement | CallSignatureDeclaration | CaseClause | ClassLikeDeclaration | ClassStaticBlockDeclaration | ConstructorDeclaration | ConstructorTypeNode | ConstructSignatureDeclaration | ContinueStatement | DebuggerStatement | DoStatement | ElementAccessExpression | EmptyStatement | EndOfFileToken | EnumDeclaration | EnumMember | ExportAssignment | ExportDeclaration | ExportSpecifier | ExpressionStatement | ForInStatement | ForOfStatement | ForStatement | FunctionDeclaration | FunctionExpression | FunctionTypeNode | Identifier | IfStatement | ImportDeclaration | ImportEqualsDeclaration | IndexSignatureDeclaration | InterfaceDeclaration | JSDocFunctionType | JSDocSignature | LabeledStatement | MethodDeclaration | MethodSignature | ModuleDeclaration | NamedTupleMember | NamespaceExportDeclaration | ObjectLiteralExpression | ParameterDeclaration | ParenthesizedExpression | PropertyAccessExpression | PropertyAssignment | PropertyDeclaration | PropertySignature | ReturnStatement | SemicolonClassElement | ShorthandPropertyAssignment | SpreadAssignment | SwitchStatement | ThrowStatement | TryStatement | TypeAliasDeclaration | TypeParameterDeclaration | VariableDeclaration | VariableStatement | WhileStatement | WithStatement
typedef HasJSDoc = Object?;
/// typedef HasType = SignatureDeclaration | VariableDeclaration | ParameterDeclaration | PropertySignature | PropertyDeclaration | TypePredicateNode | ParenthesizedTypeNode | TypeOperatorNode | MappedTypeNode | AssertionExpression | TypeAliasDeclaration | JSDocTypeExpression | JSDocNonNullableType | JSDocNullableType | JSDocOptionalType | JSDocVariadicType
typedef HasType = Object?;
/// typedef HasTypeArguments = CallExpression | NewExpression | TaggedTemplateExpression | JsxOpeningElement | JsxSelfClosingElement
typedef HasTypeArguments = Object?;
/// typedef HasInitializer = HasExpressionInitializer | ForStatement | ForInStatement | ForOfStatement | JsxAttribute
typedef HasInitializer = Object?;
/// typedef HasExpressionInitializer = VariableDeclaration | ParameterDeclaration | BindingElement | PropertyDeclaration | PropertyAssignment | EnumMember
typedef HasExpressionInitializer = Object?;
/// typedef HasDecorators = ParameterDeclaration | PropertyDeclaration | MethodDeclaration | GetAccessorDeclaration | SetAccessorDeclaration | ClassExpression | ClassDeclaration
typedef HasDecorators = Object?;
/// typedef HasModifiers = TypeParameterDeclaration | ParameterDeclaration | ConstructorTypeNode | PropertySignature | PropertyDeclaration | MethodSignature | MethodDeclaration | ConstructorDeclaration | GetAccessorDeclaration | SetAccessorDeclaration | IndexSignatureDeclaration | FunctionExpression | ArrowFunction | ClassExpression | VariableStatement | FunctionDeclaration | ClassDeclaration | InterfaceDeclaration | TypeAliasDeclaration | EnumDeclaration | ModuleDeclaration | ImportEqualsDeclaration | ImportDeclaration | ExportAssignment | ExportDeclaration
typedef HasModifiers = Object?;
/// typedef EndOfFileToken = Token<SyntaxKind.EndOfFileToken> & JSDocContainer
typedef EndOfFileToken = Object?;
/// typedef DotToken = PunctuationToken<SyntaxKind.DotToken>
typedef DotToken = PunctuationToken<SyntaxKind>;
/// typedef DotDotDotToken = PunctuationToken<SyntaxKind.DotDotDotToken>
typedef DotDotDotToken = PunctuationToken<SyntaxKind>;
/// typedef QuestionToken = PunctuationToken<SyntaxKind.QuestionToken>
typedef QuestionToken = PunctuationToken<SyntaxKind>;
/// typedef ExclamationToken = PunctuationToken<SyntaxKind.ExclamationToken>
typedef ExclamationToken = PunctuationToken<SyntaxKind>;
/// typedef ColonToken = PunctuationToken<SyntaxKind.ColonToken>
typedef ColonToken = PunctuationToken<SyntaxKind>;
/// typedef EqualsToken = PunctuationToken<SyntaxKind.EqualsToken>
typedef EqualsToken = PunctuationToken<SyntaxKind>;
/// typedef AmpersandAmpersandEqualsToken = PunctuationToken<SyntaxKind.AmpersandAmpersandEqualsToken>
typedef AmpersandAmpersandEqualsToken = PunctuationToken<SyntaxKind>;
/// typedef BarBarEqualsToken = PunctuationToken<SyntaxKind.BarBarEqualsToken>
typedef BarBarEqualsToken = PunctuationToken<SyntaxKind>;
/// typedef QuestionQuestionEqualsToken = PunctuationToken<SyntaxKind.QuestionQuestionEqualsToken>
typedef QuestionQuestionEqualsToken = PunctuationToken<SyntaxKind>;
/// typedef AsteriskToken = PunctuationToken<SyntaxKind.AsteriskToken>
typedef AsteriskToken = PunctuationToken<SyntaxKind>;
/// typedef EqualsGreaterThanToken = PunctuationToken<SyntaxKind.EqualsGreaterThanToken>
typedef EqualsGreaterThanToken = PunctuationToken<SyntaxKind>;
/// typedef PlusToken = PunctuationToken<SyntaxKind.PlusToken>
typedef PlusToken = PunctuationToken<SyntaxKind>;
/// typedef MinusToken = PunctuationToken<SyntaxKind.MinusToken>
typedef MinusToken = PunctuationToken<SyntaxKind>;
/// typedef QuestionDotToken = PunctuationToken<SyntaxKind.QuestionDotToken>
typedef QuestionDotToken = PunctuationToken<SyntaxKind>;
/// typedef AssertsKeyword = KeywordToken<SyntaxKind.AssertsKeyword>
typedef AssertsKeyword = KeywordToken<SyntaxKind>;
/// typedef AssertKeyword = KeywordToken<SyntaxKind.AssertKeyword>
typedef AssertKeyword = KeywordToken<SyntaxKind>;
/// typedef AwaitKeyword = KeywordToken<SyntaxKind.AwaitKeyword>
typedef AwaitKeyword = KeywordToken<SyntaxKind>;
/// typedef CaseKeyword = KeywordToken<SyntaxKind.CaseKeyword>
typedef CaseKeyword = KeywordToken<SyntaxKind>;
/// typedef AbstractKeyword = ModifierToken<SyntaxKind.AbstractKeyword>
typedef AbstractKeyword = ModifierToken<SyntaxKind>;
/// typedef AccessorKeyword = ModifierToken<SyntaxKind.AccessorKeyword>
typedef AccessorKeyword = ModifierToken<SyntaxKind>;
/// typedef AsyncKeyword = ModifierToken<SyntaxKind.AsyncKeyword>
typedef AsyncKeyword = ModifierToken<SyntaxKind>;
/// typedef ConstKeyword = ModifierToken<SyntaxKind.ConstKeyword>
typedef ConstKeyword = ModifierToken<SyntaxKind>;
/// typedef DeclareKeyword = ModifierToken<SyntaxKind.DeclareKeyword>
typedef DeclareKeyword = ModifierToken<SyntaxKind>;
/// typedef DefaultKeyword = ModifierToken<SyntaxKind.DefaultKeyword>
typedef DefaultKeyword = ModifierToken<SyntaxKind>;
/// typedef ExportKeyword = ModifierToken<SyntaxKind.ExportKeyword>
typedef ExportKeyword = ModifierToken<SyntaxKind>;
/// typedef InKeyword = ModifierToken<SyntaxKind.InKeyword>
typedef InKeyword = ModifierToken<SyntaxKind>;
/// typedef PrivateKeyword = ModifierToken<SyntaxKind.PrivateKeyword>
typedef PrivateKeyword = ModifierToken<SyntaxKind>;
/// typedef ProtectedKeyword = ModifierToken<SyntaxKind.ProtectedKeyword>
typedef ProtectedKeyword = ModifierToken<SyntaxKind>;
/// typedef PublicKeyword = ModifierToken<SyntaxKind.PublicKeyword>
typedef PublicKeyword = ModifierToken<SyntaxKind>;
/// typedef ReadonlyKeyword = ModifierToken<SyntaxKind.ReadonlyKeyword>
typedef ReadonlyKeyword = ModifierToken<SyntaxKind>;
/// typedef OutKeyword = ModifierToken<SyntaxKind.OutKeyword>
typedef OutKeyword = ModifierToken<SyntaxKind>;
/// typedef OverrideKeyword = ModifierToken<SyntaxKind.OverrideKeyword>
typedef OverrideKeyword = ModifierToken<SyntaxKind>;
/// typedef StaticKeyword = ModifierToken<SyntaxKind.StaticKeyword>
typedef StaticKeyword = ModifierToken<SyntaxKind>;
/// typedef Modifier = AbstractKeyword | AccessorKeyword | AsyncKeyword | ConstKeyword | DeclareKeyword | DefaultKeyword | ExportKeyword | InKeyword | PrivateKeyword | ProtectedKeyword | PublicKeyword | OutKeyword | OverrideKeyword | ReadonlyKeyword | StaticKeyword
typedef Modifier = Object?;
/// typedef ModifierLike = Modifier | Decorator
typedef ModifierLike = Object?;
/// typedef AccessibilityModifier = PublicKeyword | PrivateKeyword | ProtectedKeyword
typedef AccessibilityModifier = Object?;
/// typedef ParameterPropertyModifier = AccessibilityModifier | ReadonlyKeyword
typedef ParameterPropertyModifier = Object?;
/// typedef ClassMemberModifier = AccessibilityModifier | ReadonlyKeyword | StaticKeyword | AccessorKeyword
typedef ClassMemberModifier = Object?;
/// typedef ModifiersArray = NodeArray<Modifier>
typedef ModifiersArray = NodeArray<Modifier>;
/// typedef EntityName = Identifier | QualifiedName
typedef EntityName = Object?;
/// typedef PropertyName = Identifier | StringLiteral | NoSubstitutionTemplateLiteral | NumericLiteral | ComputedPropertyName | PrivateIdentifier | BigIntLiteral
typedef PropertyName = Object?;
/// typedef MemberName = Identifier | PrivateIdentifier
typedef MemberName = Object?;
/// typedef DeclarationName = PropertyName | JsxAttributeName | StringLiteralLike | ElementAccessExpression | BindingPattern | EntityNameExpression
typedef DeclarationName = Object?;
/// typedef SignatureDeclaration = CallSignatureDeclaration | ConstructSignatureDeclaration | MethodSignature | IndexSignatureDeclaration | FunctionTypeNode | ConstructorTypeNode | JSDocFunctionType | FunctionDeclaration | MethodDeclaration | ConstructorDeclaration | AccessorDeclaration | FunctionExpression | ArrowFunction
typedef SignatureDeclaration = Object?;
/// typedef BindingName = Identifier | BindingPattern
typedef BindingName = Object?;
/// typedef ObjectLiteralElementLike = PropertyAssignment | ShorthandPropertyAssignment | SpreadAssignment | MethodDeclaration | AccessorDeclaration
typedef ObjectLiteralElementLike = Object?;
/// typedef VariableLikeDeclaration = VariableDeclaration | ParameterDeclaration | BindingElement | PropertyDeclaration | PropertyAssignment | PropertySignature | JsxAttribute | ShorthandPropertyAssignment | EnumMember | JSDocPropertyTag | JSDocParameterTag
typedef VariableLikeDeclaration = Object?;
/// typedef BindingPattern = ObjectBindingPattern | ArrayBindingPattern
typedef BindingPattern = Object?;
/// typedef ArrayBindingElement = BindingElement | OmittedExpression
typedef ArrayBindingElement = Object?;
/// typedef FunctionLikeDeclaration = FunctionDeclaration | MethodDeclaration | GetAccessorDeclaration | SetAccessorDeclaration | ConstructorDeclaration | FunctionExpression | ArrowFunction
typedef FunctionLikeDeclaration = Object?;
/// typedef FunctionLike = SignatureDeclaration
typedef FunctionLike = SignatureDeclaration;
/// typedef AccessorDeclaration = GetAccessorDeclaration | SetAccessorDeclaration
typedef AccessorDeclaration = Object?;
/// typedef FunctionOrConstructorTypeNode = FunctionTypeNode | ConstructorTypeNode
typedef FunctionOrConstructorTypeNode = Object?;
/// typedef TypeReferenceType = TypeReferenceNode | ExpressionWithTypeArguments
typedef TypeReferenceType = Object?;
/// typedef UnionOrIntersectionTypeNode = UnionTypeNode | IntersectionTypeNode
typedef UnionOrIntersectionTypeNode = Object?;
/// typedef StringLiteralLike = StringLiteral | NoSubstitutionTemplateLiteral
typedef StringLiteralLike = Object?;
/// typedef PropertyNameLiteral = Identifier | StringLiteralLike | NumericLiteral | JsxNamespacedName | BigIntLiteral
typedef PropertyNameLiteral = Object?;
/// typedef IncrementExpression = UpdateExpression
typedef IncrementExpression = UpdateExpression;
/// typedef PrefixUnaryOperator = SyntaxKind.PlusPlusToken | SyntaxKind.MinusMinusToken | SyntaxKind.PlusToken | SyntaxKind.MinusToken | SyntaxKind.TildeToken | SyntaxKind.ExclamationToken
typedef PrefixUnaryOperator = Object?;
/// typedef PostfixUnaryOperator = SyntaxKind.PlusPlusToken | SyntaxKind.MinusMinusToken
typedef PostfixUnaryOperator = Object?;
/// typedef BooleanLiteral = TrueLiteral | FalseLiteral
typedef BooleanLiteral = Object?;
/// typedef ExponentiationOperator = SyntaxKind.AsteriskAsteriskToken
typedef ExponentiationOperator = SyntaxKind;
/// typedef MultiplicativeOperator = SyntaxKind.AsteriskToken | SyntaxKind.SlashToken | SyntaxKind.PercentToken
typedef MultiplicativeOperator = Object?;
/// typedef MultiplicativeOperatorOrHigher = ExponentiationOperator | MultiplicativeOperator
typedef MultiplicativeOperatorOrHigher = Object?;
/// typedef AdditiveOperator = SyntaxKind.PlusToken | SyntaxKind.MinusToken
typedef AdditiveOperator = Object?;
/// typedef AdditiveOperatorOrHigher = MultiplicativeOperatorOrHigher | AdditiveOperator
typedef AdditiveOperatorOrHigher = Object?;
/// typedef ShiftOperator = SyntaxKind.LessThanLessThanToken | SyntaxKind.GreaterThanGreaterThanToken | SyntaxKind.GreaterThanGreaterThanGreaterThanToken
typedef ShiftOperator = Object?;
/// typedef ShiftOperatorOrHigher = AdditiveOperatorOrHigher | ShiftOperator
typedef ShiftOperatorOrHigher = Object?;
/// typedef RelationalOperator = SyntaxKind.LessThanToken | SyntaxKind.LessThanEqualsToken | SyntaxKind.GreaterThanToken | SyntaxKind.GreaterThanEqualsToken | SyntaxKind.InstanceOfKeyword | SyntaxKind.InKeyword
typedef RelationalOperator = Object?;
/// typedef RelationalOperatorOrHigher = ShiftOperatorOrHigher | RelationalOperator
typedef RelationalOperatorOrHigher = Object?;
/// typedef EqualityOperator = SyntaxKind.EqualsEqualsToken | SyntaxKind.EqualsEqualsEqualsToken | SyntaxKind.ExclamationEqualsEqualsToken | SyntaxKind.ExclamationEqualsToken
typedef EqualityOperator = Object?;
/// typedef EqualityOperatorOrHigher = RelationalOperatorOrHigher | EqualityOperator
typedef EqualityOperatorOrHigher = Object?;
/// typedef BitwiseOperator = SyntaxKind.AmpersandToken | SyntaxKind.BarToken | SyntaxKind.CaretToken
typedef BitwiseOperator = Object?;
/// typedef BitwiseOperatorOrHigher = EqualityOperatorOrHigher | BitwiseOperator
typedef BitwiseOperatorOrHigher = Object?;
/// typedef LogicalOperator = SyntaxKind.AmpersandAmpersandToken | SyntaxKind.BarBarToken
typedef LogicalOperator = Object?;
/// typedef LogicalOperatorOrHigher = BitwiseOperatorOrHigher | LogicalOperator
typedef LogicalOperatorOrHigher = Object?;
/// typedef CompoundAssignmentOperator = SyntaxKind.PlusEqualsToken | SyntaxKind.MinusEqualsToken | SyntaxKind.AsteriskAsteriskEqualsToken | SyntaxKind.AsteriskEqualsToken | SyntaxKind.SlashEqualsToken | SyntaxKind.PercentEqualsToken | SyntaxKind.AmpersandEqualsToken | SyntaxKind.BarEqualsToken | SyntaxKind.CaretEqualsToken | SyntaxKind.LessThanLessThanEqualsToken | SyntaxKind.GreaterThanGreaterThanGreaterThanEqualsToken | SyntaxKind.GreaterThanGreaterThanEqualsToken | SyntaxKind.BarBarEqualsToken | SyntaxKind.AmpersandAmpersandEqualsToken | SyntaxKind.QuestionQuestionEqualsToken
typedef CompoundAssignmentOperator = Object?;
/// typedef AssignmentOperator = SyntaxKind.EqualsToken | CompoundAssignmentOperator
typedef AssignmentOperator = Object?;
/// typedef AssignmentOperatorOrHigher = SyntaxKind.QuestionQuestionToken | LogicalOperatorOrHigher | AssignmentOperator
typedef AssignmentOperatorOrHigher = Object?;
/// typedef BinaryOperator = AssignmentOperatorOrHigher | SyntaxKind.CommaToken
typedef BinaryOperator = Object?;
/// typedef LogicalOrCoalescingAssignmentOperator = SyntaxKind.AmpersandAmpersandEqualsToken | SyntaxKind.BarBarEqualsToken | SyntaxKind.QuestionQuestionEqualsToken
typedef LogicalOrCoalescingAssignmentOperator = Object?;
/// typedef BinaryOperatorToken = Token<BinaryOperator>
typedef BinaryOperatorToken = Token<BinaryOperator>;
/// typedef AssignmentOperatorToken = Token<AssignmentOperator>
typedef AssignmentOperatorToken = Token<AssignmentOperator>;
/// typedef DestructuringAssignment = ObjectDestructuringAssignment | ArrayDestructuringAssignment
typedef DestructuringAssignment = Object?;
/// typedef BindingOrAssignmentElement = VariableDeclaration | ParameterDeclaration | ObjectBindingOrAssignmentElement | ArrayBindingOrAssignmentElement
typedef BindingOrAssignmentElement = Object?;
/// typedef ObjectBindingOrAssignmentElement = BindingElement | PropertyAssignment | ShorthandPropertyAssignment | SpreadAssignment
typedef ObjectBindingOrAssignmentElement = Object?;
/// typedef ArrayBindingOrAssignmentElement = BindingElement | OmittedExpression | SpreadElement | ArrayLiteralExpression | ObjectLiteralExpression | AssignmentExpression<EqualsToken> | Identifier | PropertyAccessExpression | ElementAccessExpression
typedef ArrayBindingOrAssignmentElement = Object?;
/// typedef BindingOrAssignmentElementRestIndicator = DotDotDotToken | SpreadElement | SpreadAssignment
typedef BindingOrAssignmentElementRestIndicator = Object?;
/// typedef BindingOrAssignmentElementTarget = BindingOrAssignmentPattern | Identifier | PropertyAccessExpression | ElementAccessExpression | OmittedExpression
typedef BindingOrAssignmentElementTarget = Object?;
/// typedef ObjectBindingOrAssignmentPattern = ObjectBindingPattern | ObjectLiteralExpression
typedef ObjectBindingOrAssignmentPattern = Object?;
/// typedef ArrayBindingOrAssignmentPattern = ArrayBindingPattern | ArrayLiteralExpression
typedef ArrayBindingOrAssignmentPattern = Object?;
/// typedef AssignmentPattern = ObjectLiteralExpression | ArrayLiteralExpression
typedef AssignmentPattern = Object?;
/// typedef BindingOrAssignmentPattern = ObjectBindingOrAssignmentPattern | ArrayBindingOrAssignmentPattern
typedef BindingOrAssignmentPattern = Object?;
/// typedef FunctionBody = Block
typedef FunctionBody = Block;
/// typedef ConciseBody = FunctionBody | Expression
typedef ConciseBody = Object?;
/// typedef LiteralToken = NumericLiteral | BigIntLiteral | StringLiteral | JsxText | RegularExpressionLiteral | NoSubstitutionTemplateLiteral
typedef LiteralToken = Object?;
/// typedef PseudoLiteralToken = TemplateHead | TemplateMiddle | TemplateTail
typedef PseudoLiteralToken = Object?;
/// typedef TemplateLiteralToken = NoSubstitutionTemplateLiteral | PseudoLiteralToken
typedef TemplateLiteralToken = Object?;
/// typedef TemplateLiteral = TemplateExpression | NoSubstitutionTemplateLiteral
typedef TemplateLiteral = Object?;
/// typedef EntityNameExpression = Identifier | PropertyAccessEntityNameExpression
typedef EntityNameExpression = Object?;
/// typedef EntityNameOrEntityNameExpression = EntityName | EntityNameExpression
typedef EntityNameOrEntityNameExpression = Object?;
/// typedef AccessExpression = PropertyAccessExpression | ElementAccessExpression
typedef AccessExpression = Object?;
/// typedef SuperProperty = SuperPropertyAccessExpression | SuperElementAccessExpression
typedef SuperProperty = Object?;
/// typedef OptionalChain = PropertyAccessChain | ElementAccessChain | CallChain | NonNullChain
typedef OptionalChain = Object?;
/// typedef CallLikeExpression = CallExpression | NewExpression | TaggedTemplateExpression | Decorator | JsxCallLike | InstanceofExpression
typedef CallLikeExpression = Object?;
/// typedef AssertionExpression = TypeAssertion | AsExpression
typedef AssertionExpression = Object?;
/// typedef JsxOpeningLikeElement = JsxSelfClosingElement | JsxOpeningElement
typedef JsxOpeningLikeElement = Object?;
/// typedef JsxCallLike = JsxOpeningLikeElement | JsxOpeningFragment
typedef JsxCallLike = Object?;
/// typedef JsxAttributeLike = JsxAttribute | JsxSpreadAttribute
typedef JsxAttributeLike = Object?;
/// typedef JsxAttributeName = Identifier | JsxNamespacedName
typedef JsxAttributeName = Object?;
/// typedef JsxTagNameExpression = Identifier | ThisExpression | JsxTagNamePropertyAccess | JsxNamespacedName
typedef JsxTagNameExpression = Object?;
/// typedef JsxAttributeValue = StringLiteral | JsxExpression | JsxElement | JsxSelfClosingElement | JsxFragment
typedef JsxAttributeValue = Object?;
/// typedef JsxChild = JsxText | JsxExpression | JsxElement | JsxSelfClosingElement | JsxFragment
typedef JsxChild = Object?;
/// typedef BlockLike = SourceFile | Block | ModuleBlock | CaseOrDefaultClause
typedef BlockLike = Object?;
/// typedef ForInitializer = VariableDeclarationList | Expression
typedef ForInitializer = Object?;
/// typedef ForInOrOfStatement = ForInStatement | ForOfStatement
typedef ForInOrOfStatement = Object?;
/// typedef BreakOrContinueStatement = BreakStatement | ContinueStatement
typedef BreakOrContinueStatement = Object?;
/// typedef CaseOrDefaultClause = CaseClause | DefaultClause
typedef CaseOrDefaultClause = Object?;
/// typedef ObjectTypeDeclaration = ClassLikeDeclaration | InterfaceDeclaration | TypeLiteralNode
typedef ObjectTypeDeclaration = Object?;
/// typedef DeclarationWithTypeParameters = DeclarationWithTypeParameterChildren | JSDocTypedefTag | JSDocCallbackTag | JSDocSignature
typedef DeclarationWithTypeParameters = Object?;
/// typedef DeclarationWithTypeParameterChildren = SignatureDeclaration | ClassLikeDeclaration | InterfaceDeclaration | TypeAliasDeclaration | JSDocTemplateTag
typedef DeclarationWithTypeParameterChildren = Object?;
/// typedef ClassLikeDeclaration = ClassDeclaration | ClassExpression
typedef ClassLikeDeclaration = Object?;
/// typedef ModuleName = Identifier | StringLiteral
typedef ModuleName = Object?;
/// typedef ModuleBody = NamespaceBody | JSDocNamespaceBody
typedef ModuleBody = Object?;
/// typedef NamespaceBody = ModuleBlock | NamespaceDeclaration
typedef NamespaceBody = Object?;
/// typedef JSDocNamespaceBody = Identifier | JSDocNamespaceDeclaration
typedef JSDocNamespaceBody = Object?;
/// typedef ModuleReference = EntityName | ExternalModuleReference
typedef ModuleReference = Object?;
/// typedef NamedImportBindings = NamespaceImport | NamedImports
typedef NamedImportBindings = Object?;
/// typedef NamedExportBindings = NamespaceExport | NamedExports
typedef NamedExportBindings = Object?;
/// typedef ImportPhaseModifierSyntaxKind = SyntaxKind.TypeKeyword | SyntaxKind.DeferKeyword
typedef ImportPhaseModifierSyntaxKind = Object?;
/// typedef AssertionKey = ImportAttributeName
typedef AssertionKey = ImportAttributeName;
/// typedef ImportAttributeName = Identifier | StringLiteral
typedef ImportAttributeName = Object?;
/// typedef NamedImportsOrExports = NamedImports | NamedExports
typedef NamedImportsOrExports = Object?;
/// typedef ModuleExportName = Identifier | StringLiteral
typedef ModuleExportName = Object?;
/// typedef ImportOrExportSpecifier = ImportSpecifier | ExportSpecifier
typedef ImportOrExportSpecifier = Object?;
/// typedef TypeOnlyCompatibleAliasDeclaration = ImportClause | ImportEqualsDeclaration | NamespaceImport | ImportOrExportSpecifier | ExportDeclaration | NamespaceExport
typedef TypeOnlyCompatibleAliasDeclaration = Object?;
/// typedef TypeOnlyImportDeclaration = | ImportClause & { readonly isTypeOnly: true; readonly name: Identifier; } | ImportEqualsDeclaration & { readonly isTypeOnly: true; } | NamespaceImport & { readonly parent: ImportClause & { readonly isTypeOnly: true; }; } | ImportSpecifier & ({ readonly isTypeOnly: true; } | { readonly parent: NamedImports & { readonly parent: ImportClause & { readonly isTypeOnly: true; }; }; })
typedef TypeOnlyImportDeclaration = Object?;
/// typedef TypeOnlyExportDeclaration = | ExportSpecifier & ({ readonly isTypeOnly: true; } | { readonly parent: NamedExports & { readonly parent: ExportDeclaration & { readonly isTypeOnly: true; }; }; }) | ExportDeclaration & { readonly isTypeOnly: true; readonly moduleSpecifier: Expression; } | NamespaceExport & { readonly parent: ExportDeclaration & { readonly isTypeOnly: true; readonly moduleSpecifier: Expression; }; }
typedef TypeOnlyExportDeclaration = Object?;
/// typedef TypeOnlyAliasDeclaration = TypeOnlyImportDeclaration | TypeOnlyExportDeclaration
typedef TypeOnlyAliasDeclaration = Object?;
/// typedef CommentKind = SyntaxKind.SingleLineCommentTrivia | SyntaxKind.MultiLineCommentTrivia
typedef CommentKind = Object?;
/// typedef JSDocTypeReferencingNode = JSDocVariadicType | JSDocOptionalType | JSDocNullableType | JSDocNonNullableType
typedef JSDocTypeReferencingNode = Object?;
/// typedef JSDocComment = JSDocText | JSDocLink | JSDocLinkCode | JSDocLinkPlain
typedef JSDocComment = Object?;
/// typedef FlowType = Type | IncompleteType
typedef FlowType = Object?;
/// typedef ResolutionMode = ModuleKind.ESNext | ModuleKind.CommonJS | undefined
typedef ResolutionMode = Object?;
/// typedef JsonObjectExpression = ObjectLiteralExpression | ArrayLiteralExpression | JsonMinusNumericLiteral | NumericLiteral | StringLiteral | BooleanLiteral | NullLiteral
typedef JsonObjectExpression = Object?;
/// typedef ResolvedConfigFileName = string & { _isResolvedConfigFileName: never; }
typedef ResolvedConfigFileName = Object?;
/// typedef WriteFileCallback = (fileName: string, text: string, writeByteOrderMark: boolean, onError?: (message: string) => void, sourceFiles?: readonly SourceFile[], data?: WriteFileCallbackData) => void
typedef WriteFileCallback = Object? Function(Object?);
/// typedef CustomTransformerFactory = (context: TransformationContext) => CustomTransformer
typedef CustomTransformerFactory = Object? Function(Object?);
/// typedef TypePredicate = ThisTypePredicate | IdentifierTypePredicate | AssertsThisTypePredicate | AssertsIdentifierTypePredicate
typedef TypePredicate = Object?;
/// typedef __String = | (string & { __escapedIdentifier: void; }) | (void & { __escapedIdentifier: void; }) | InternalSymbolName
typedef __String = Object?;
/// typedef ReadonlyUnderscoreEscapedMap = ReadonlyMap<__String, T>
typedef ReadonlyUnderscoreEscapedMap<T> = Map<__String, T>;
/// typedef UnderscoreEscapedMap = Map<__String, T>
typedef UnderscoreEscapedMap<T> = Map<__String, T>;
/// typedef SymbolTable = Map<__String, Symbol>
typedef SymbolTable = Map<__String, Symbol>;
/// typedef DestructuringPattern = BindingPattern | ObjectLiteralExpression | ArrayLiteralExpression
typedef DestructuringPattern = Object?;
/// typedef BaseType = ObjectType | IntersectionType | TypeVariable
typedef BaseType = Object?;
/// typedef StructuredType = ObjectType | UnionType | IntersectionType
typedef StructuredType = Object?;
/// typedef TypeVariable = TypeParameter | IndexedAccessType
typedef TypeVariable = Object?;
/// typedef ElementWithComputedPropertyName = (ClassElement | ObjectLiteralElement) & { name: ComputedPropertyName; }
typedef ElementWithComputedPropertyName = Object?;
/// typedef CompilerOptionsValue = string | number | boolean | (string | number)[] | string[] | MapLike<string[]> | PluginImport[] | ProjectReference[] | null | undefined
typedef CompilerOptionsValue = Object?;
/// typedef EmitHelper = ScopedEmitHelper | UnscopedEmitHelper
typedef EmitHelper = Object?;
/// typedef EmitHelperUniqueNameCallback = (name: string) => string
typedef EmitHelperUniqueNameCallback = Object? Function(Object?);
/// typedef ImmediatelyInvokedFunctionExpression = CallExpression & { readonly expression: FunctionExpression; }
typedef ImmediatelyInvokedFunctionExpression = Object?;
/// typedef ImmediatelyInvokedArrowFunction = CallExpression & { readonly expression: ParenthesizedExpression & { readonly expression: ArrowFunction; }; }
typedef ImmediatelyInvokedArrowFunction = Object?;
/// typedef TransformerFactory = (context: TransformationContext) => Transformer<T>
typedef TransformerFactory<T> = Object? Function(Object?);
/// typedef Transformer = (node: T) => T
typedef Transformer<T> = Object? Function(Object?);
/// typedef Visitor = (node: TIn) => VisitResult<TOut>
typedef Visitor<TIn, TOut> = Object? Function(Object?);
/// typedef VisitResult = T | readonly Node[]
typedef VisitResult<T> = Object?;
/// typedef OrganizeImportsTypeOrder = "last" | "inline" | "first"
typedef OrganizeImportsTypeOrder = Object?;
/// typedef FileWatcherCallback = (fileName: string, eventKind: FileWatcherEventKind, modifiedTime?: Date) => void
typedef FileWatcherCallback = Object? Function(Object?);
/// typedef DirectoryWatcherCallback = (fileName: string) => void
typedef DirectoryWatcherCallback = Object? Function(Object?);
/// typedef BufferEncoding = "ascii" | "utf8" | "utf-8" | "utf16le" | "ucs2" | "ucs-2" | "base64" | "latin1" | "binary" | "hex"
typedef BufferEncoding = Object?;
/// typedef ErrorCallback = (message: DiagnosticMessage, length: number, arg0?: any) => void
typedef ErrorCallback = Object? Function(Object?);
/// typedef ParameterPropertyDeclaration = ParameterDeclaration & { parent: ConstructorDeclaration; name: Identifier; }
typedef ParameterPropertyDeclaration = Object?;
/// typedef DiagnosticReporter = (diagnostic: Diagnostic) => void
typedef DiagnosticReporter = Object? Function(Object?);
/// typedef PerModuleNameCache = PerNonRelativeNameCache<ResolvedModuleWithFailedLookupLocations>
typedef PerModuleNameCache = PerNonRelativeNameCache<ResolvedModuleWithFailedLookupLocations>;
/// typedef AffectedFileResult = { result: T; affected: SourceFile | Program; } | undefined
typedef AffectedFileResult<T> = Map<String, Object?>?;
/// typedef WatchStatusReporter = (diagnostic: Diagnostic, newLine: string, options: CompilerOptions, errorCount?: number) => void
typedef WatchStatusReporter = Object? Function(Object?);
/// typedef CreateProgram = (rootNames: readonly string[] | undefined, options: CompilerOptions | undefined, host?: CompilerHost, oldProgram?: T, configFileParsingDiagnostics?: readonly Diagnostic[], projectReferences?: readonly ProjectReference[] | undefined) => T
typedef CreateProgram<T> = Object? Function(Object?);
/// typedef ReportEmitErrorSummary = (errorCount: number, filesInError: (ReportFileInError | undefined)[]) => void
typedef ReportEmitErrorSummary = Object? Function(Object?);
/// typedef InvalidatedProject = UpdateOutputFileStampsProject | BuildInvalidedProject<T>
typedef InvalidatedProject<T> = Object?;
/// typedef WithMetadata = T & { metadata?: unknown; }
typedef WithMetadata<T> = Object?;
/// typedef CompletionsTriggerCharacter = "." | '"' | "'" | "`" | "/" | "@" | "<" | "#" | " "
typedef CompletionsTriggerCharacter = Object?;
/// typedef SignatureHelpTriggerCharacter = "," | "(" | "<"
typedef SignatureHelpTriggerCharacter = Object?;
/// typedef SignatureHelpRetriggerCharacter = SignatureHelpTriggerCharacter | ")"
typedef SignatureHelpRetriggerCharacter = Object?;
/// typedef SignatureHelpTriggerReason = SignatureHelpInvokedReason | SignatureHelpCharacterTypedReason | SignatureHelpRetriggeredReason
typedef SignatureHelpTriggerReason = Object?;
/// typedef CodeActionCommand = InstallPackageAction
typedef CodeActionCommand = InstallPackageAction;
/// typedef RefactorTriggerReason = "implicit" | "invoked"
typedef RefactorTriggerReason = Object?;
/// typedef RenameInfo = RenameInfoSuccess | RenameInfoFailure
typedef RenameInfo = Object?;
/// typedef CompletionEntryData = CompletionEntryDataUnresolved | CompletionEntryDataResolved
typedef CompletionEntryData = Object?;
/// typedef ExportMapInfoKey = string & { __exportInfoKey: void; }
typedef ExportMapInfoKey = Object?;
/// typedef DocumentRegistryBucketKey = string & { __bucketKey: any; }
typedef DocumentRegistryBucketKey = Object?;

/// export import ApplicableRefactorInfo = ts.ApplicableRefactorInfo;
typedef ServerProtocolApplicableRefactorInfo = ApplicableRefactorInfo;
/// export import ClassificationType = ts.ClassificationType;
typedef ServerProtocolClassificationType = ClassificationType;
/// export import CompletionsTriggerCharacter = ts.CompletionsTriggerCharacter;
typedef ServerProtocolCompletionsTriggerCharacter = CompletionsTriggerCharacter;
/// export import CompletionTriggerKind = ts.CompletionTriggerKind;
typedef ServerProtocolCompletionTriggerKind = CompletionTriggerKind;
/// export import InlayHintKind = ts.InlayHintKind;
typedef ServerProtocolInlayHintKind = InlayHintKind;
/// export import OrganizeImportsMode = ts.OrganizeImportsMode;
typedef ServerProtocolOrganizeImportsMode = OrganizeImportsMode;
/// export import RefactorActionInfo = ts.RefactorActionInfo;
typedef ServerProtocolRefactorActionInfo = RefactorActionInfo;
/// export import RefactorTriggerReason = ts.RefactorTriggerReason;
typedef ServerProtocolRefactorTriggerReason = RefactorTriggerReason;
/// export import RenameInfoFailure = ts.RenameInfoFailure;
typedef ServerProtocolRenameInfoFailure = RenameInfoFailure;
/// export import SemicolonPreference = ts.SemicolonPreference;
typedef ServerProtocolSemicolonPreference = SemicolonPreference;
/// export import SignatureHelpCharacterTypedReason = ts.SignatureHelpCharacterTypedReason;
typedef ServerProtocolSignatureHelpCharacterTypedReason = SignatureHelpCharacterTypedReason;
/// export import SignatureHelpInvokedReason = ts.SignatureHelpInvokedReason;
typedef ServerProtocolSignatureHelpInvokedReason = SignatureHelpInvokedReason;
/// export import SignatureHelpParameter = ts.SignatureHelpParameter;
typedef ServerProtocolSignatureHelpParameter = SignatureHelpParameter;
/// export import SignatureHelpRetriggerCharacter = ts.SignatureHelpRetriggerCharacter;
typedef ServerProtocolSignatureHelpRetriggerCharacter = SignatureHelpRetriggerCharacter;
/// export import SignatureHelpRetriggeredReason = ts.SignatureHelpRetriggeredReason;
typedef ServerProtocolSignatureHelpRetriggeredReason = SignatureHelpRetriggeredReason;
/// export import SignatureHelpTriggerCharacter = ts.SignatureHelpTriggerCharacter;
typedef ServerProtocolSignatureHelpTriggerCharacter = SignatureHelpTriggerCharacter;
/// export import SignatureHelpTriggerReason = ts.SignatureHelpTriggerReason;
typedef ServerProtocolSignatureHelpTriggerReason = SignatureHelpTriggerReason;
/// export import SymbolDisplayPart = ts.SymbolDisplayPart;
typedef ServerProtocolSymbolDisplayPart = SymbolDisplayPart;
/// export import UserPreferences = ts.UserPreferences;
typedef ServerProtocolUserPreferences = UserPreferences;

/// function createInstallTypingsRequest  [ns: ts.server]
external ServerDiscoverTypings ServercreateInstallTypingsRequest(ServerProject project, TypeAcquisition typeAcquisition, List<String> unresolvedImports, [String? cachePath]);
/// function toNormalizedPath  [ns: ts.server]
external ServerNormalizedPath ServertoNormalizedPath(String fileName);
/// function normalizedPathToPath  [ns: ts.server]
external Path ServernormalizedPathToPath(ServerNormalizedPath normalizedPath, String currentDirectory, Object? Function(Object?) getCanonicalFileName);
/// function asNormalizedPath  [ns: ts.server]
external ServerNormalizedPath ServerasNormalizedPath(String fileName);
/// function createNormalizedPathMap  [ns: ts.server]
external ServerNormalizedPathMap<T> ServercreateNormalizedPathMap<T>();
/// function isInferredProjectName  [ns: ts.server]
external bool ServerisInferredProjectName(String name);
/// function makeInferredProjectName  [ns: ts.server]
external String ServermakeInferredProjectName(num counter);
/// function createSortedArray  [ns: ts.server]
external List<T> ServercreateSortedArray<T>();
/// function ThrowNoProject  [ns: ts.server.Errors]
external Null ServerErrorsThrowNoProject();
/// function ThrowProjectLanguageServiceDisabled  [ns: ts.server.Errors]
external Null ServerErrorsThrowProjectLanguageServiceDisabled();
/// function ThrowProjectDoesNotContainDocument  [ns: ts.server.Errors]
external Null ServerErrorsThrowProjectDoesNotContainDocument(String fileName, ServerProject project);
/// function isDynamicFileName  [ns: ts.server]
external bool ServerisDynamicFileName(ServerNormalizedPath fileName);
/// function allRootFilesAreJsOrDts  [ns: ts.server]
external bool ServerallRootFilesAreJsOrDts(ServerProject project);
/// function allFilesAreJsOrDts  [ns: ts.server]
external bool ServerallFilesAreJsOrDts(ServerProject project);
/// function convertFormatOptions  [ns: ts.server]
external FormatCodeSettings ServerconvertFormatOptions(FormatCodeSettings protocolOptions);
/// function convertCompilerOptions  [ns: ts.server]
external Object? ServerconvertCompilerOptions(ServerProtocolExternalProjectCompilerOptions protocolOptions);
/// function convertWatchOptions  [ns: ts.server]
external ServerWatchOptionsAndErrors? ServerconvertWatchOptions(ServerProtocolExternalProjectCompilerOptions protocolOptions, [String? currentDirectory]);
/// function convertTypeAcquisition  [ns: ts.server]
external TypeAcquisition? ServerconvertTypeAcquisition(ServerProtocolInferredProjectCompilerOptions protocolOptions);
/// function tryConvertScriptKindName  [ns: ts.server]
external ScriptKind ServertryConvertScriptKindName(Object? scriptKindName);
/// function convertScriptKindName  [ns: ts.server]
external ScriptKind ServerconvertScriptKindName(ServerProtocolScriptKindName scriptKindName);
/// function formatMessage  [ns: ts.server]
external String ServerformatMessage<T>(T msg, ServerLogger logger, Object? Function(Object?) byteLength, String newLine);
/// function tokenToString
external String? tokenToString(SyntaxKind t);
/// function getPositionOfLineAndCharacter
external num getPositionOfLineAndCharacter(SourceFileLike sourceFile, num line, num character);
/// function getLineAndCharacterOfPosition
external LineAndCharacter getLineAndCharacterOfPosition(SourceFileLike sourceFile, num position);
/// function isWhiteSpaceLike
external bool isWhiteSpaceLike(num ch);
/// function isWhiteSpaceSingleLine
external bool isWhiteSpaceSingleLine(num ch);
/// function isLineBreak
external bool isLineBreak(num ch);
/// function couldStartTrivia
external bool couldStartTrivia(String text, num pos);
/// function forEachLeadingCommentRange
external U? forEachLeadingCommentRange<U>(String text, num pos, Object? Function(Object?) cb);
/// function forEachLeadingCommentRange  [overload 1]
external U? forEachLeadingCommentRange$1<T, U>(String text, num pos, Object? Function(Object?) cb, T state);
/// function forEachTrailingCommentRange
external U? forEachTrailingCommentRange<U>(String text, num pos, Object? Function(Object?) cb);
/// function forEachTrailingCommentRange  [overload 1]
external U? forEachTrailingCommentRange$1<T, U>(String text, num pos, Object? Function(Object?) cb, T state);
/// function reduceEachLeadingCommentRange
external U? reduceEachLeadingCommentRange<T, U>(String text, num pos, Object? Function(Object?) cb, T state, U initial);
/// function reduceEachTrailingCommentRange
external U? reduceEachTrailingCommentRange<T, U>(String text, num pos, Object? Function(Object?) cb, T state, U initial);
/// function getLeadingCommentRanges
external List<CommentRange>? getLeadingCommentRanges(String text, num pos);
/// function getTrailingCommentRanges
external List<CommentRange>? getTrailingCommentRanges(String text, num pos);
/// function getShebang
external String? getShebang(String text);
/// function isIdentifierStart
external bool isIdentifierStart(num ch, ScriptTarget? languageVersion);
/// function isIdentifierPart
external bool isIdentifierPart(num ch, ScriptTarget? languageVersion, [LanguageVariant? identifierVariant]);
/// function createScanner
external Scanner createScanner(ScriptTarget languageVersion, bool skipTrivia, [LanguageVariant? languageVariant, String? textInitial, ErrorCallback? onError, num? start, num? length]);
/// function isExternalModuleNameRelative
external bool isExternalModuleNameRelative(String moduleName);
/// function sortAndDeduplicateDiagnostics
external List<T> sortAndDeduplicateDiagnostics<T>(List<T> diagnostics);
/// function getDefaultLibFileName
external String getDefaultLibFileName(CompilerOptions options);
/// function textSpanEnd
external num textSpanEnd(TextSpan span);
/// function textSpanIsEmpty
external bool textSpanIsEmpty(TextSpan span);
/// function textSpanContainsPosition
external bool textSpanContainsPosition(TextSpan span, num position);
/// function textSpanContainsTextSpan
external bool textSpanContainsTextSpan(TextSpan span, TextSpan other);
/// function textSpanOverlapsWith
external bool textSpanOverlapsWith(TextSpan span, TextSpan other);
/// function textSpanOverlap
external TextSpan? textSpanOverlap(TextSpan span1, TextSpan span2);
/// function textSpanIntersectsWithTextSpan
external bool textSpanIntersectsWithTextSpan(TextSpan span, TextSpan other);
/// function textSpanIntersectsWith
external bool textSpanIntersectsWith(TextSpan span, num start, num length);
/// function decodedTextSpanIntersectsWith
external bool decodedTextSpanIntersectsWith(num start1, num length1, num start2, num length2);
/// function textSpanIntersectsWithPosition
external bool textSpanIntersectsWithPosition(TextSpan span, num position);
/// function textSpanIntersection
external TextSpan? textSpanIntersection(TextSpan span1, TextSpan span2);
/// function createTextSpan
external TextSpan createTextSpan(num start, num length);
/// function createTextSpanFromBounds
external TextSpan createTextSpanFromBounds(num start, num end);
/// function textChangeRangeNewSpan
external TextSpan textChangeRangeNewSpan(TextChangeRange range);
/// function textChangeRangeIsUnchanged
external bool textChangeRangeIsUnchanged(TextChangeRange range);
/// function createTextChangeRange
external TextChangeRange createTextChangeRange(TextSpan span, num newLength);
/// function collapseTextChangeRangesAcrossMultipleVersions
external TextChangeRange collapseTextChangeRangesAcrossMultipleVersions(List<TextChangeRange> changes);
/// function getTypeParameterOwner
external Declaration? getTypeParameterOwner(Declaration d);
/// function isParameterPropertyDeclaration
external Object? isParameterPropertyDeclaration(Node node, Node parent);
/// function isEmptyBindingPattern
external Object? isEmptyBindingPattern(BindingName node);
/// function isEmptyBindingElement
external bool isEmptyBindingElement(Object? node);
/// function walkUpBindingElementsAndPatterns
external Object? walkUpBindingElementsAndPatterns(BindingElement binding);
/// function getCombinedModifierFlags
external ModifierFlags getCombinedModifierFlags(Declaration node);
/// function getCombinedNodeFlags
external NodeFlags getCombinedNodeFlags(Node node);
/// function validateLocaleAndSetLanguage
external void validateLocaleAndSetLanguage(String locale, Map<String, Object?> sys, [List<Diagnostic>? errors]);
/// function getOriginalNode
external Node getOriginalNode(Node node);
/// function getOriginalNode  [overload 1]
external T getOriginalNode$1<T>(Node node, Object? Function(Object?) nodeTest);
/// function getOriginalNode  [overload 2]
external Node? getOriginalNode$2(Node? node);
/// function getOriginalNode  [overload 3]
external T? getOriginalNode$3<T>(Node? node, Object? Function(Object?) nodeTest);
/// function findAncestor
external T? findAncestor<T>(Node? node, Object? Function(Object?) callback);
/// function findAncestor  [overload 1]
external Node? findAncestor$1(Node? node, Object? Function(Object?) callback);
/// function isParseTreeNode
external bool isParseTreeNode(Node node);
/// function getParseTreeNode
external Node? getParseTreeNode(Node? node);
/// function getParseTreeNode  [overload 1]
external T? getParseTreeNode$1<T>(T? node, [Object? Function(Object?)? nodeTest]);
/// function escapeLeadingUnderscores
external __String escapeLeadingUnderscores(String identifier);
/// function unescapeLeadingUnderscores
external String unescapeLeadingUnderscores(__String identifier);
/// function idText
external String idText(Object? identifierOrPrivateName);
/// function identifierToKeywordKind
external KeywordSyntaxKind? identifierToKeywordKind(Identifier node);
/// function symbolName
external String symbolName(Symbol symbol);
/// function getNameOfJSDocTypedef
external Object? getNameOfJSDocTypedef(JSDocTypedefTag declaration);
/// function getNameOfDeclaration
external DeclarationName? getNameOfDeclaration(Object? declaration);
/// function getDecorators
external List<Decorator>? getDecorators(HasDecorators node);
/// function getModifiers
external List<Modifier>? getModifiers(HasModifiers node);
/// function getJSDocParameterTags
external List<JSDocParameterTag> getJSDocParameterTags(ParameterDeclaration param);
/// function getJSDocTypeParameterTags
external List<JSDocTemplateTag> getJSDocTypeParameterTags(TypeParameterDeclaration param);
/// function hasJSDocParameterTags
external bool hasJSDocParameterTags(Object? node);
/// function getJSDocAugmentsTag
external JSDocAugmentsTag? getJSDocAugmentsTag(Node node);
/// function getJSDocImplementsTags
external List<JSDocImplementsTag> getJSDocImplementsTags(Node node);
/// function getJSDocClassTag
external JSDocClassTag? getJSDocClassTag(Node node);
/// function getJSDocPublicTag
external JSDocPublicTag? getJSDocPublicTag(Node node);
/// function getJSDocPrivateTag
external JSDocPrivateTag? getJSDocPrivateTag(Node node);
/// function getJSDocProtectedTag
external JSDocProtectedTag? getJSDocProtectedTag(Node node);
/// function getJSDocReadonlyTag
external JSDocReadonlyTag? getJSDocReadonlyTag(Node node);
/// function getJSDocOverrideTagNoCache
external JSDocOverrideTag? getJSDocOverrideTagNoCache(Node node);
/// function getJSDocDeprecatedTag
external JSDocDeprecatedTag? getJSDocDeprecatedTag(Node node);
/// function getJSDocEnumTag
external JSDocEnumTag? getJSDocEnumTag(Node node);
/// function getJSDocThisTag
external JSDocThisTag? getJSDocThisTag(Node node);
/// function getJSDocReturnTag
external JSDocReturnTag? getJSDocReturnTag(Node node);
/// function getJSDocTemplateTag
external JSDocTemplateTag? getJSDocTemplateTag(Node node);
/// function getJSDocSatisfiesTag
external JSDocSatisfiesTag? getJSDocSatisfiesTag(Node node);
/// function getJSDocTypeTag
external JSDocTypeTag? getJSDocTypeTag(Node node);
/// function getJSDocType
external TypeNode? getJSDocType(Node node);
/// function getJSDocReturnType
external TypeNode? getJSDocReturnType(Node node);
/// function getJSDocTags
external List<JSDocTag> getJSDocTags(Node node);
/// function getAllJSDocTags
external List<T> getAllJSDocTags<T>(Node node, Object? Function(Object?) predicate);
/// function getAllJSDocTagsOfKind
external List<JSDocTag> getAllJSDocTagsOfKind(Node node, SyntaxKind kind);
/// function getTextOfJSDocComment
external String? getTextOfJSDocComment([Object? comment]);
/// function getEffectiveTypeParameterDeclarations
external List<TypeParameterDeclaration> getEffectiveTypeParameterDeclarations(DeclarationWithTypeParameters node);
/// function getEffectiveConstraintOfTypeParameter
external TypeNode? getEffectiveConstraintOfTypeParameter(TypeParameterDeclaration node);
/// function isMemberName
external Object? isMemberName(Node node);
/// function isPropertyAccessChain
external Object? isPropertyAccessChain(Node node);
/// function isElementAccessChain
external Object? isElementAccessChain(Node node);
/// function isCallChain
external Object? isCallChain(Node node);
/// function isOptionalChain
external Object? isOptionalChain(Node node);
/// function isNullishCoalesce
external bool isNullishCoalesce(Node node);
/// function isConstTypeReference
external bool isConstTypeReference(Node node);
/// function skipPartiallyEmittedExpressions
external Expression skipPartiallyEmittedExpressions(Expression node);
/// function skipPartiallyEmittedExpressions  [overload 1]
external Node skipPartiallyEmittedExpressions$1(Node node);
/// function isNonNullChain
external Object? isNonNullChain(Node node);
/// function isBreakOrContinueStatement
external Object? isBreakOrContinueStatement(Node node);
/// function isNamedExportBindings
external Object? isNamedExportBindings(Node node);
/// function isJSDocPropertyLikeTag
external Object? isJSDocPropertyLikeTag(Node node);
/// function isTokenKind
external bool isTokenKind(SyntaxKind kind);
/// function isToken
external bool isToken(Node n);
/// function isLiteralExpression
external Object? isLiteralExpression(Node node);
/// function isTemplateLiteralToken
external Object? isTemplateLiteralToken(Node node);
/// function isTemplateMiddleOrTemplateTail
external Object? isTemplateMiddleOrTemplateTail(Node node);
/// function isImportOrExportSpecifier
external Object? isImportOrExportSpecifier(Node node);
/// function isTypeOnlyImportDeclaration
external Object? isTypeOnlyImportDeclaration(Node node);
/// function isTypeOnlyExportDeclaration
external Object? isTypeOnlyExportDeclaration(Node node);
/// function isTypeOnlyImportOrExportDeclaration
external Object? isTypeOnlyImportOrExportDeclaration(Node node);
/// function isPartOfTypeOnlyImportOrExportDeclaration
external bool isPartOfTypeOnlyImportOrExportDeclaration(Node node);
/// function isStringTextContainingNode
external Object? isStringTextContainingNode(Node node);
/// function isImportAttributeName
external Object? isImportAttributeName(Node node);
/// function isModifier
external Object? isModifier(Node node);
/// function isEntityName
external Object? isEntityName(Node node);
/// function isPropertyName
external Object? isPropertyName(Node node);
/// function isBindingName
external Object? isBindingName(Node node);
/// function isFunctionLike
external Object? isFunctionLike(Node? node);
/// function isClassElement
external Object? isClassElement(Node node);
/// function isClassLike
external Object? isClassLike(Node node);
/// function isAccessor
external Object? isAccessor(Node node);
/// function isAutoAccessorPropertyDeclaration
external Object? isAutoAccessorPropertyDeclaration(Node node);
/// function isModifierLike
external Object? isModifierLike(Node node);
/// function isTypeElement
external Object? isTypeElement(Node node);
/// function isClassOrTypeElement
external Object? isClassOrTypeElement(Node node);
/// function isObjectLiteralElementLike
external Object? isObjectLiteralElementLike(Node node);
/// function isTypeNode
external Object? isTypeNode(Node node);
/// function isFunctionOrConstructorTypeNode
external Object? isFunctionOrConstructorTypeNode(Node node);
/// function isArrayBindingElement
external Object? isArrayBindingElement(Node node);
/// function isPropertyAccessOrQualifiedName
external Object? isPropertyAccessOrQualifiedName(Node node);
/// function isCallLikeExpression
external Object? isCallLikeExpression(Node node);
/// function isCallOrNewExpression
external Object? isCallOrNewExpression(Node node);
/// function isTemplateLiteral
external Object? isTemplateLiteral(Node node);
/// function isLeftHandSideExpression
external Object? isLeftHandSideExpression(Node node);
/// function isLiteralTypeLiteral
external Object? isLiteralTypeLiteral(Node node);
/// function isExpression
external Object? isExpression(Node node);
/// function isAssertionExpression
external Object? isAssertionExpression(Node node);
/// function isIterationStatement
external Object? isIterationStatement(Node node, bool lookInLabeledStatements);
/// function isIterationStatement  [overload 1]
external Object? isIterationStatement$1(Node node, bool lookInLabeledStatements);
/// function isConciseBody
external Object? isConciseBody(Node node);
/// function isForInitializer
external Object? isForInitializer(Node node);
/// function isModuleBody
external Object? isModuleBody(Node node);
/// function isNamedImportBindings
external Object? isNamedImportBindings(Node node);
/// function isDeclarationStatement
external Object? isDeclarationStatement(Node node);
/// function isStatement
external Object? isStatement(Node node);
/// function isModuleReference
external Object? isModuleReference(Node node);
/// function isJsxTagNameExpression
external Object? isJsxTagNameExpression(Node node);
/// function isJsxChild
external Object? isJsxChild(Node node);
/// function isJsxAttributeLike
external Object? isJsxAttributeLike(Node node);
/// function isStringLiteralOrJsxExpression
external Object? isStringLiteralOrJsxExpression(Node node);
/// function isJsxOpeningLikeElement
external Object? isJsxOpeningLikeElement(Node node);
/// function isJsxCallLike
external Object? isJsxCallLike(Node node);
/// function isCaseOrDefaultClause
external Object? isCaseOrDefaultClause(Node node);
/// function isJSDocCommentContainingNode
external bool isJSDocCommentContainingNode(Node node);
/// function isSetAccessor
external Object? isSetAccessor(Node node);
/// function isGetAccessor
external Object? isGetAccessor(Node node);
/// function hasOnlyExpressionInitializer
external Object? hasOnlyExpressionInitializer(Node node);
/// function isObjectLiteralElement
external Object? isObjectLiteralElement(Node node);
/// function isStringLiteralLike
external Object? isStringLiteralLike(Object? node);
/// function isJSDocLinkLike
external Object? isJSDocLinkLike(Node node);
/// function hasRestParameter
external bool hasRestParameter(Object? s);
/// function isRestParameter
external bool isRestParameter(Object? node);
/// function isInternalDeclaration
external bool isInternalDeclaration(Node node, [SourceFile? sourceFile]);
/// function isPartOfTypeNode
external bool isPartOfTypeNode(Node node);
/// function getJSDocCommentsAndTags
external List<Object?> getJSDocCommentsAndTags(Node hostNode);
/// function createSourceMapSource
external SourceMapSource createSourceMapSource(String fileName, String text, [Object? Function(Object?)? skipTrivia]);
/// function setOriginalNode
external T setOriginalNode<T>(T node, Node? original);
/// function disposeEmitNodes
external void disposeEmitNodes(SourceFile? sourceFile);
/// function setEmitFlags
external T setEmitFlags<T>(T node, EmitFlags emitFlags);
/// function getSourceMapRange
external SourceMapRange getSourceMapRange(Node node);
/// function setSourceMapRange
external T setSourceMapRange<T>(T node, SourceMapRange? range);
/// function getTokenSourceMapRange
external SourceMapRange? getTokenSourceMapRange(Node node, SyntaxKind token);
/// function setTokenSourceMapRange
external T setTokenSourceMapRange<T>(T node, SyntaxKind token, SourceMapRange? range);
/// function getCommentRange
external TextRange getCommentRange(Node node);
/// function setCommentRange
external T setCommentRange<T>(T node, TextRange range);
/// function getSyntheticLeadingComments
external List<SynthesizedComment>? getSyntheticLeadingComments(Node node);
/// function setSyntheticLeadingComments
external T setSyntheticLeadingComments<T>(T node, List<SynthesizedComment>? comments);
/// function addSyntheticLeadingComment
external T addSyntheticLeadingComment<T>(T node, Object? kind, String text, [bool? hasTrailingNewLine]);
/// function getSyntheticTrailingComments
external List<SynthesizedComment>? getSyntheticTrailingComments(Node node);
/// function setSyntheticTrailingComments
external T setSyntheticTrailingComments<T>(T node, List<SynthesizedComment>? comments);
/// function addSyntheticTrailingComment
external T addSyntheticTrailingComment<T>(T node, Object? kind, String text, [bool? hasTrailingNewLine]);
/// function moveSyntheticComments
external T moveSyntheticComments<T>(T node, Node original);
/// function getConstantValue
external Object? getConstantValue(AccessExpression node);
/// function setConstantValue
external AccessExpression setConstantValue(AccessExpression node, Object? value);
/// function addEmitHelper
external T addEmitHelper<T>(T node, EmitHelper helper);
/// function addEmitHelpers
external T addEmitHelpers<T>(T node, List<EmitHelper>? helpers);
/// function removeEmitHelper
external bool removeEmitHelper(Node node, EmitHelper helper);
/// function getEmitHelpers
external List<EmitHelper>? getEmitHelpers(Node node);
/// function moveEmitHelpers
external void moveEmitHelpers(Node source, Node target, Object? Function(Object?) predicate);
/// function isNumericLiteral
external Object? isNumericLiteral(Node node);
/// function isBigIntLiteral
external Object? isBigIntLiteral(Node node);
/// function isStringLiteral
external Object? isStringLiteral(Node node);
/// function isJsxText
external Object? isJsxText(Node node);
/// function isRegularExpressionLiteral
external Object? isRegularExpressionLiteral(Node node);
/// function isNoSubstitutionTemplateLiteral
external Object? isNoSubstitutionTemplateLiteral(Node node);
/// function isTemplateHead
external Object? isTemplateHead(Node node);
/// function isTemplateMiddle
external Object? isTemplateMiddle(Node node);
/// function isTemplateTail
external Object? isTemplateTail(Node node);
/// function isDotDotDotToken
external Object? isDotDotDotToken(Node node);
/// function isPlusToken
external Object? isPlusToken(Node node);
/// function isMinusToken
external Object? isMinusToken(Node node);
/// function isAsteriskToken
external Object? isAsteriskToken(Node node);
/// function isExclamationToken
external Object? isExclamationToken(Node node);
/// function isQuestionToken
external Object? isQuestionToken(Node node);
/// function isColonToken
external Object? isColonToken(Node node);
/// function isQuestionDotToken
external Object? isQuestionDotToken(Node node);
/// function isEqualsGreaterThanToken
external Object? isEqualsGreaterThanToken(Node node);
/// function isIdentifier
external Object? isIdentifier(Node node);
/// function isPrivateIdentifier
external Object? isPrivateIdentifier(Node node);
/// function isAssertsKeyword
external Object? isAssertsKeyword(Node node);
/// function isAwaitKeyword
external Object? isAwaitKeyword(Node node);
/// function isQualifiedName
external Object? isQualifiedName(Node node);
/// function isComputedPropertyName
external Object? isComputedPropertyName(Node node);
/// function isTypeParameterDeclaration
external Object? isTypeParameterDeclaration(Node node);
/// function isParameter
external Object? isParameter(Node node);
/// function isDecorator
external Object? isDecorator(Node node);
/// function isPropertySignature
external Object? isPropertySignature(Node node);
/// function isPropertyDeclaration
external Object? isPropertyDeclaration(Node node);
/// function isMethodSignature
external Object? isMethodSignature(Node node);
/// function isMethodDeclaration
external Object? isMethodDeclaration(Node node);
/// function isClassStaticBlockDeclaration
external Object? isClassStaticBlockDeclaration(Node node);
/// function isConstructorDeclaration
external Object? isConstructorDeclaration(Node node);
/// function isGetAccessorDeclaration
external Object? isGetAccessorDeclaration(Node node);
/// function isSetAccessorDeclaration
external Object? isSetAccessorDeclaration(Node node);
/// function isCallSignatureDeclaration
external Object? isCallSignatureDeclaration(Node node);
/// function isConstructSignatureDeclaration
external Object? isConstructSignatureDeclaration(Node node);
/// function isIndexSignatureDeclaration
external Object? isIndexSignatureDeclaration(Node node);
/// function isTypePredicateNode
external Object? isTypePredicateNode(Node node);
/// function isTypeReferenceNode
external Object? isTypeReferenceNode(Node node);
/// function isFunctionTypeNode
external Object? isFunctionTypeNode(Node node);
/// function isConstructorTypeNode
external Object? isConstructorTypeNode(Node node);
/// function isTypeQueryNode
external Object? isTypeQueryNode(Node node);
/// function isTypeLiteralNode
external Object? isTypeLiteralNode(Node node);
/// function isArrayTypeNode
external Object? isArrayTypeNode(Node node);
/// function isTupleTypeNode
external Object? isTupleTypeNode(Node node);
/// function isNamedTupleMember
external Object? isNamedTupleMember(Node node);
/// function isOptionalTypeNode
external Object? isOptionalTypeNode(Node node);
/// function isRestTypeNode
external Object? isRestTypeNode(Node node);
/// function isUnionTypeNode
external Object? isUnionTypeNode(Node node);
/// function isIntersectionTypeNode
external Object? isIntersectionTypeNode(Node node);
/// function isConditionalTypeNode
external Object? isConditionalTypeNode(Node node);
/// function isInferTypeNode
external Object? isInferTypeNode(Node node);
/// function isParenthesizedTypeNode
external Object? isParenthesizedTypeNode(Node node);
/// function isThisTypeNode
external Object? isThisTypeNode(Node node);
/// function isTypeOperatorNode
external Object? isTypeOperatorNode(Node node);
/// function isIndexedAccessTypeNode
external Object? isIndexedAccessTypeNode(Node node);
/// function isMappedTypeNode
external Object? isMappedTypeNode(Node node);
/// function isLiteralTypeNode
external Object? isLiteralTypeNode(Node node);
/// function isImportTypeNode
external Object? isImportTypeNode(Node node);
/// function isTemplateLiteralTypeSpan
external Object? isTemplateLiteralTypeSpan(Node node);
/// function isTemplateLiteralTypeNode
external Object? isTemplateLiteralTypeNode(Node node);
/// function isObjectBindingPattern
external Object? isObjectBindingPattern(Node node);
/// function isArrayBindingPattern
external Object? isArrayBindingPattern(Node node);
/// function isBindingElement
external Object? isBindingElement(Node node);
/// function isArrayLiteralExpression
external Object? isArrayLiteralExpression(Node node);
/// function isObjectLiteralExpression
external Object? isObjectLiteralExpression(Node node);
/// function isPropertyAccessExpression
external Object? isPropertyAccessExpression(Node node);
/// function isElementAccessExpression
external Object? isElementAccessExpression(Node node);
/// function isCallExpression
external Object? isCallExpression(Node node);
/// function isNewExpression
external Object? isNewExpression(Node node);
/// function isTaggedTemplateExpression
external Object? isTaggedTemplateExpression(Node node);
/// function isTypeAssertionExpression
external Object? isTypeAssertionExpression(Node node);
/// function isParenthesizedExpression
external Object? isParenthesizedExpression(Node node);
/// function isFunctionExpression
external Object? isFunctionExpression(Node node);
/// function isArrowFunction
external Object? isArrowFunction(Node node);
/// function isDeleteExpression
external Object? isDeleteExpression(Node node);
/// function isTypeOfExpression
external Object? isTypeOfExpression(Node node);
/// function isVoidExpression
external Object? isVoidExpression(Node node);
/// function isAwaitExpression
external Object? isAwaitExpression(Node node);
/// function isPrefixUnaryExpression
external Object? isPrefixUnaryExpression(Node node);
/// function isPostfixUnaryExpression
external Object? isPostfixUnaryExpression(Node node);
/// function isBinaryExpression
external Object? isBinaryExpression(Node node);
/// function isConditionalExpression
external Object? isConditionalExpression(Node node);
/// function isTemplateExpression
external Object? isTemplateExpression(Node node);
/// function isYieldExpression
external Object? isYieldExpression(Node node);
/// function isSpreadElement
external Object? isSpreadElement(Node node);
/// function isClassExpression
external Object? isClassExpression(Node node);
/// function isOmittedExpression
external Object? isOmittedExpression(Node node);
/// function isExpressionWithTypeArguments
external Object? isExpressionWithTypeArguments(Node node);
/// function isAsExpression
external Object? isAsExpression(Node node);
/// function isSatisfiesExpression
external Object? isSatisfiesExpression(Node node);
/// function isNonNullExpression
external Object? isNonNullExpression(Node node);
/// function isMetaProperty
external Object? isMetaProperty(Node node);
/// function isSyntheticExpression
external Object? isSyntheticExpression(Node node);
/// function isPartiallyEmittedExpression
external Object? isPartiallyEmittedExpression(Node node);
/// function isCommaListExpression
external Object? isCommaListExpression(Node node);
/// function isTemplateSpan
external Object? isTemplateSpan(Node node);
/// function isSemicolonClassElement
external Object? isSemicolonClassElement(Node node);
/// function isBlock
external Object? isBlock(Node node);
/// function isVariableStatement
external Object? isVariableStatement(Node node);
/// function isEmptyStatement
external Object? isEmptyStatement(Node node);
/// function isExpressionStatement
external Object? isExpressionStatement(Node node);
/// function isIfStatement
external Object? isIfStatement(Node node);
/// function isDoStatement
external Object? isDoStatement(Node node);
/// function isWhileStatement
external Object? isWhileStatement(Node node);
/// function isForStatement
external Object? isForStatement(Node node);
/// function isForInStatement
external Object? isForInStatement(Node node);
/// function isForOfStatement
external Object? isForOfStatement(Node node);
/// function isContinueStatement
external Object? isContinueStatement(Node node);
/// function isBreakStatement
external Object? isBreakStatement(Node node);
/// function isReturnStatement
external Object? isReturnStatement(Node node);
/// function isWithStatement
external Object? isWithStatement(Node node);
/// function isSwitchStatement
external Object? isSwitchStatement(Node node);
/// function isLabeledStatement
external Object? isLabeledStatement(Node node);
/// function isThrowStatement
external Object? isThrowStatement(Node node);
/// function isTryStatement
external Object? isTryStatement(Node node);
/// function isDebuggerStatement
external Object? isDebuggerStatement(Node node);
/// function isVariableDeclaration
external Object? isVariableDeclaration(Node node);
/// function isVariableDeclarationList
external Object? isVariableDeclarationList(Node node);
/// function isFunctionDeclaration
external Object? isFunctionDeclaration(Node node);
/// function isClassDeclaration
external Object? isClassDeclaration(Node node);
/// function isInterfaceDeclaration
external Object? isInterfaceDeclaration(Node node);
/// function isTypeAliasDeclaration
external Object? isTypeAliasDeclaration(Node node);
/// function isEnumDeclaration
external Object? isEnumDeclaration(Node node);
/// function isModuleDeclaration
external Object? isModuleDeclaration(Node node);
/// function isModuleBlock
external Object? isModuleBlock(Node node);
/// function isCaseBlock
external Object? isCaseBlock(Node node);
/// function isNamespaceExportDeclaration
external Object? isNamespaceExportDeclaration(Node node);
/// function isImportEqualsDeclaration
external Object? isImportEqualsDeclaration(Node node);
/// function isImportDeclaration
external Object? isImportDeclaration(Node node);
/// function isImportClause
external Object? isImportClause(Node node);
/// function isImportTypeAssertionContainer
external Object? isImportTypeAssertionContainer(Node node);
/// function isAssertClause
external Object? isAssertClause(Node node);
/// function isAssertEntry
external Object? isAssertEntry(Node node);
/// function isImportAttributes
external Object? isImportAttributes(Node node);
/// function isImportAttribute
external Object? isImportAttribute(Node node);
/// function isNamespaceImport
external Object? isNamespaceImport(Node node);
/// function isNamespaceExport
external Object? isNamespaceExport(Node node);
/// function isNamedImports
external Object? isNamedImports(Node node);
/// function isImportSpecifier
external Object? isImportSpecifier(Node node);
/// function isExportAssignment
external Object? isExportAssignment(Node node);
/// function isExportDeclaration
external Object? isExportDeclaration(Node node);
/// function isNamedExports
external Object? isNamedExports(Node node);
/// function isExportSpecifier
external Object? isExportSpecifier(Node node);
/// function isModuleExportName
external Object? isModuleExportName(Node node);
/// function isMissingDeclaration
external Object? isMissingDeclaration(Node node);
/// function isNotEmittedStatement
external Object? isNotEmittedStatement(Node node);
/// function isExternalModuleReference
external Object? isExternalModuleReference(Node node);
/// function isJsxElement
external Object? isJsxElement(Node node);
/// function isJsxSelfClosingElement
external Object? isJsxSelfClosingElement(Node node);
/// function isJsxOpeningElement
external Object? isJsxOpeningElement(Node node);
/// function isJsxClosingElement
external Object? isJsxClosingElement(Node node);
/// function isJsxFragment
external Object? isJsxFragment(Node node);
/// function isJsxOpeningFragment
external Object? isJsxOpeningFragment(Node node);
/// function isJsxClosingFragment
external Object? isJsxClosingFragment(Node node);
/// function isJsxAttribute
external Object? isJsxAttribute(Node node);
/// function isJsxAttributes
external Object? isJsxAttributes(Node node);
/// function isJsxSpreadAttribute
external Object? isJsxSpreadAttribute(Node node);
/// function isJsxExpression
external Object? isJsxExpression(Node node);
/// function isJsxNamespacedName
external Object? isJsxNamespacedName(Node node);
/// function isCaseClause
external Object? isCaseClause(Node node);
/// function isDefaultClause
external Object? isDefaultClause(Node node);
/// function isHeritageClause
external Object? isHeritageClause(Node node);
/// function isCatchClause
external Object? isCatchClause(Node node);
/// function isPropertyAssignment
external Object? isPropertyAssignment(Node node);
/// function isShorthandPropertyAssignment
external Object? isShorthandPropertyAssignment(Node node);
/// function isSpreadAssignment
external Object? isSpreadAssignment(Node node);
/// function isEnumMember
external Object? isEnumMember(Node node);
/// function isSourceFile
external Object? isSourceFile(Node node);
/// function isBundle
external Object? isBundle(Node node);
/// function isJSDocTypeExpression
external Object? isJSDocTypeExpression(Node node);
/// function isJSDocNameReference
external Object? isJSDocNameReference(Node node);
/// function isJSDocMemberName
external Object? isJSDocMemberName(Node node);
/// function isJSDocLink
external Object? isJSDocLink(Node node);
/// function isJSDocLinkCode
external Object? isJSDocLinkCode(Node node);
/// function isJSDocLinkPlain
external Object? isJSDocLinkPlain(Node node);
/// function isJSDocAllType
external Object? isJSDocAllType(Node node);
/// function isJSDocUnknownType
external Object? isJSDocUnknownType(Node node);
/// function isJSDocNullableType
external Object? isJSDocNullableType(Node node);
/// function isJSDocNonNullableType
external Object? isJSDocNonNullableType(Node node);
/// function isJSDocOptionalType
external Object? isJSDocOptionalType(Node node);
/// function isJSDocFunctionType
external Object? isJSDocFunctionType(Node node);
/// function isJSDocVariadicType
external Object? isJSDocVariadicType(Node node);
/// function isJSDocNamepathType
external Object? isJSDocNamepathType(Node node);
/// function isJSDoc
external Object? isJSDoc(Node node);
/// function isJSDocTypeLiteral
external Object? isJSDocTypeLiteral(Node node);
/// function isJSDocSignature
external Object? isJSDocSignature(Node node);
/// function isJSDocAugmentsTag
external Object? isJSDocAugmentsTag(Node node);
/// function isJSDocAuthorTag
external Object? isJSDocAuthorTag(Node node);
/// function isJSDocClassTag
external Object? isJSDocClassTag(Node node);
/// function isJSDocCallbackTag
external Object? isJSDocCallbackTag(Node node);
/// function isJSDocPublicTag
external Object? isJSDocPublicTag(Node node);
/// function isJSDocPrivateTag
external Object? isJSDocPrivateTag(Node node);
/// function isJSDocProtectedTag
external Object? isJSDocProtectedTag(Node node);
/// function isJSDocReadonlyTag
external Object? isJSDocReadonlyTag(Node node);
/// function isJSDocOverrideTag
external Object? isJSDocOverrideTag(Node node);
/// function isJSDocOverloadTag
external Object? isJSDocOverloadTag(Node node);
/// function isJSDocDeprecatedTag
external Object? isJSDocDeprecatedTag(Node node);
/// function isJSDocSeeTag
external Object? isJSDocSeeTag(Node node);
/// function isJSDocEnumTag
external Object? isJSDocEnumTag(Node node);
/// function isJSDocParameterTag
external Object? isJSDocParameterTag(Node node);
/// function isJSDocReturnTag
external Object? isJSDocReturnTag(Node node);
/// function isJSDocThisTag
external Object? isJSDocThisTag(Node node);
/// function isJSDocTypeTag
external Object? isJSDocTypeTag(Node node);
/// function isJSDocTemplateTag
external Object? isJSDocTemplateTag(Node node);
/// function isJSDocTypedefTag
external Object? isJSDocTypedefTag(Node node);
/// function isJSDocUnknownTag
external Object? isJSDocUnknownTag(Node node);
/// function isJSDocPropertyTag
external Object? isJSDocPropertyTag(Node node);
/// function isJSDocImplementsTag
external Object? isJSDocImplementsTag(Node node);
/// function isJSDocSatisfiesTag
external Object? isJSDocSatisfiesTag(Node node);
/// function isJSDocThrowsTag
external Object? isJSDocThrowsTag(Node node);
/// function isJSDocImportTag
external Object? isJSDocImportTag(Node node);
/// function isQuestionOrExclamationToken
external Object? isQuestionOrExclamationToken(Node node);
/// function isIdentifierOrThisTypeNode
external Object? isIdentifierOrThisTypeNode(Node node);
/// function isReadonlyKeywordOrPlusOrMinusToken
external Object? isReadonlyKeywordOrPlusOrMinusToken(Node node);
/// function isQuestionOrPlusOrMinusToken
external Object? isQuestionOrPlusOrMinusToken(Node node);
/// function isModuleName
external Object? isModuleName(Node node);
/// function isBinaryOperatorToken
external Object? isBinaryOperatorToken(Node node);
/// function setTextRange
external T setTextRange<T>(T range, TextRange? location);
/// function canHaveModifiers
external Object? canHaveModifiers(Node node);
/// function canHaveDecorators
external Object? canHaveDecorators(Node node);
/// function forEachChild
external T? forEachChild<T>(Node node, Object? Function(Object?) cbNode, [Object? Function(Object?)? cbNodes]);
/// function createSourceFile
external SourceFile createSourceFile(String fileName, String sourceText, Object? languageVersionOrOptions, [bool? setParentNodes, ScriptKind? scriptKind]);
/// function parseIsolatedEntityName
external EntityName? parseIsolatedEntityName(String text, ScriptTarget languageVersion);
/// function parseJsonText
external JsonSourceFile parseJsonText(String fileName, String sourceText);
/// function isExternalModule
external bool isExternalModule(SourceFile file);
/// function updateSourceFile
external SourceFile updateSourceFile(SourceFile sourceFile, String newText, TextChangeRange textChangeRange, [bool? aggressiveChecks]);
/// function parseCommandLine
external ParsedCommandLine parseCommandLine(List<String> commandLine, [Object? Function(Object?)? readFile]);
/// function parseBuildCommand
external ParsedBuildCommand parseBuildCommand(List<String> commandLine);
/// function getParsedCommandLineOfConfigFile
external ParsedCommandLine? getParsedCommandLineOfConfigFile(String configFileName, CompilerOptions? optionsToExtend, ParseConfigFileHost host, [Map<String, ExtendedConfigCacheEntry>? extendedConfigCache, WatchOptions? watchOptionsToExtend, List<FileExtensionInfo>? extraFileExtensions]);
/// function readConfigFile
external Map<String, Object?> readConfigFile(String fileName, Object? Function(Object?) readFile);
/// function parseConfigFileTextToJson
external Map<String, Object?> parseConfigFileTextToJson(String fileName, String jsonText);
/// function readJsonConfigFile
external TsConfigSourceFile readJsonConfigFile(String fileName, Object? Function(Object?) readFile);
/// function convertToObject
external Object? convertToObject(JsonSourceFile sourceFile, List<Diagnostic> errors);
/// function parseJsonConfigFileContent
external ParsedCommandLine parseJsonConfigFileContent(Object? json, ParseConfigHost host, String basePath, [CompilerOptions? existingOptions, String? configFileName, List<Path>? resolutionStack, List<FileExtensionInfo>? extraFileExtensions, Map<String, ExtendedConfigCacheEntry>? extendedConfigCache, WatchOptions? existingWatchOptions]);
/// function parseJsonSourceFileConfigFileContent
external ParsedCommandLine parseJsonSourceFileConfigFileContent(TsConfigSourceFile sourceFile, ParseConfigHost host, String basePath, [CompilerOptions? existingOptions, String? configFileName, List<Path>? resolutionStack, List<FileExtensionInfo>? extraFileExtensions, Map<String, ExtendedConfigCacheEntry>? extendedConfigCache, WatchOptions? existingWatchOptions]);
/// function convertCompilerOptionsFromJson
external Map<String, Object?> convertCompilerOptionsFromJson(Object? jsonOptions, String basePath, [String? configFileName]);
/// function convertTypeAcquisitionFromJson
external Map<String, Object?> convertTypeAcquisitionFromJson(Object? jsonOptions, String basePath, [String? configFileName]);
/// function getEffectiveTypeRoots
external List<String>? getEffectiveTypeRoots(CompilerOptions options, GetEffectiveTypeRootsHost host);
/// function resolveTypeReferenceDirective
external ResolvedTypeReferenceDirectiveWithFailedLookupLocations resolveTypeReferenceDirective(String typeReferenceDirectiveName, String? containingFile, CompilerOptions options, ModuleResolutionHost host, [ResolvedProjectReference? redirectedReference, TypeReferenceDirectiveResolutionCache? cache, ResolutionMode? resolutionMode]);
/// function getAutomaticTypeDirectiveNames
external List<String> getAutomaticTypeDirectiveNames(CompilerOptions options, ModuleResolutionHost host);
/// function createModuleResolutionCache
external ModuleResolutionCache createModuleResolutionCache(String currentDirectory, Object? Function(Object?) getCanonicalFileName, [CompilerOptions? options, PackageJsonInfoCache? packageJsonInfoCache]);
/// function createTypeReferenceDirectiveResolutionCache
external TypeReferenceDirectiveResolutionCache createTypeReferenceDirectiveResolutionCache(String currentDirectory, Object? Function(Object?) getCanonicalFileName, [CompilerOptions? options, PackageJsonInfoCache? packageJsonInfoCache]);
/// function resolveModuleNameFromCache
external ResolvedModuleWithFailedLookupLocations? resolveModuleNameFromCache(String moduleName, String containingFile, ModuleResolutionCache cache, [ResolutionMode? mode]);
/// function resolveModuleName
external ResolvedModuleWithFailedLookupLocations resolveModuleName(String moduleName, String containingFile, CompilerOptions compilerOptions, ModuleResolutionHost host, [ModuleResolutionCache? cache, ResolvedProjectReference? redirectedReference, ResolutionMode? resolutionMode]);
/// function bundlerModuleNameResolver
external ResolvedModuleWithFailedLookupLocations bundlerModuleNameResolver(String moduleName, String containingFile, CompilerOptions compilerOptions, ModuleResolutionHost host, [ModuleResolutionCache? cache, ResolvedProjectReference? redirectedReference]);
/// function nodeModuleNameResolver
external ResolvedModuleWithFailedLookupLocations nodeModuleNameResolver(String moduleName, String containingFile, CompilerOptions compilerOptions, ModuleResolutionHost host, [ModuleResolutionCache? cache, ResolvedProjectReference? redirectedReference]);
/// function classicNameResolver
external ResolvedModuleWithFailedLookupLocations classicNameResolver(String moduleName, String containingFile, CompilerOptions compilerOptions, ModuleResolutionHost host, [NonRelativeModuleNameResolutionCache? cache, ResolvedProjectReference? redirectedReference]);
/// function visitNode
external Object? visitNode<TIn, TVisited, TOut>(TIn node, Visitor<TIn, TVisited> visitor, Object? Function(Object?) test, [Object? Function(Object?)? lift]);
/// function visitNode  [overload 1]
external Object? visitNode$1<TIn, TVisited>(TIn node, Visitor<TIn, TVisited> visitor, [Object? Function(Object?)? test, Object? Function(Object?)? lift]);
/// function visitNodes
external Object? visitNodes<TIn, TInArray, TOut>(TInArray nodes, Visitor<TIn, Node?> visitor, Object? Function(Object?) test, [num? start, num? count]);
/// function visitNodes  [overload 1]
external Object? visitNodes$1<TIn, TInArray>(TInArray nodes, Visitor<TIn, Node?> visitor, [Object? Function(Object?)? test, num? start, num? count]);
/// function visitLexicalEnvironment
external NodeArray<Statement> visitLexicalEnvironment(NodeArray<Statement> statements, Visitor visitor, TransformationContext context, [num? start, bool? ensureUseStrict, NodesVisitor? nodesVisitor]);
/// function visitParameterList
external NodeArray<ParameterDeclaration> visitParameterList(NodeArray<ParameterDeclaration> nodes, Visitor visitor, TransformationContext context, [NodesVisitor? nodesVisitor]);
/// function visitParameterList  [overload 1]
external NodeArray<ParameterDeclaration>? visitParameterList$1(NodeArray<ParameterDeclaration>? nodes, Visitor visitor, TransformationContext context, [NodesVisitor? nodesVisitor]);
/// function visitFunctionBody
external FunctionBody visitFunctionBody(FunctionBody node, Visitor visitor, TransformationContext context);
/// function visitFunctionBody  [overload 1]
external FunctionBody? visitFunctionBody$1(FunctionBody? node, Visitor visitor, TransformationContext context);
/// function visitFunctionBody  [overload 2]
external ConciseBody visitFunctionBody$2(ConciseBody node, Visitor visitor, TransformationContext context);
/// function visitIterationBody
external Statement visitIterationBody(Statement body, Visitor visitor, TransformationContext context);
/// function visitCommaListElements
external NodeArray<Expression> visitCommaListElements(NodeArray<Expression> elements, Visitor visitor, [Visitor? discardVisitor]);
/// function visitEachChild
external T visitEachChild<T>(T node, Visitor visitor, TransformationContext? context);
/// function visitEachChild  [overload 1]
external T? visitEachChild$1<T>(T? node, Visitor visitor, TransformationContext? context, [Object? nodesVisitor, Visitor? tokenVisitor]);
/// function getTsBuildInfoEmitOutputFilePath
external String? getTsBuildInfoEmitOutputFilePath(CompilerOptions options);
/// function getOutputFileNames
external List<String> getOutputFileNames(ParsedCommandLine commandLine, String inputFileName, bool ignoreCase);
/// function createPrinter
external Printer createPrinter([PrinterOptions? printerOptions, PrintHandlers? handlers]);
/// function findConfigFile
external String? findConfigFile(String searchPath, Object? Function(Object?) fileExists, [String? configName]);
/// function resolveTripleslashReference
external String resolveTripleslashReference(String moduleName, String containingFile);
/// function createCompilerHost
external CompilerHost createCompilerHost(CompilerOptions options, [bool? setParentNodes]);
/// function getPreEmitDiagnostics
external List<Diagnostic> getPreEmitDiagnostics(Program program, [SourceFile? sourceFile, CancellationToken? cancellationToken]);
/// function formatDiagnostics
external String formatDiagnostics(List<Diagnostic> diagnostics, FormatDiagnosticsHost host);
/// function formatDiagnostic
external String formatDiagnostic(Diagnostic diagnostic, FormatDiagnosticsHost host);
/// function formatDiagnosticsWithColorAndContext
external String formatDiagnosticsWithColorAndContext(List<Diagnostic> diagnostics, FormatDiagnosticsHost host);
/// function flattenDiagnosticMessageText
external String flattenDiagnosticMessageText(Object? diag, String newLine, [num? indent]);
/// function getModeForFileReference
external ResolutionMode getModeForFileReference(Object? ref, ResolutionMode containingFileMode);
/// function getModeForResolutionAtIndex
external ResolutionMode getModeForResolutionAtIndex(SourceFile file, num index, CompilerOptions compilerOptions);
/// function getModeForUsageLocation
external ResolutionMode getModeForUsageLocation(SourceFile file, StringLiteralLike usage, CompilerOptions compilerOptions);
/// function getConfigFileParsingDiagnostics
external List<Diagnostic> getConfigFileParsingDiagnostics(ParsedCommandLine configFileParseResult);
/// function getImpliedNodeFormatForFile
external ResolutionMode getImpliedNodeFormatForFile(String fileName, PackageJsonInfoCache? packageJsonInfoCache, ModuleResolutionHost host, CompilerOptions options);
/// function createProgram
external Program createProgram(CreateProgramOptions createProgramOptions);
/// function createProgram  [overload 1]
external Program createProgram$1(List<String> rootNames, CompilerOptions options, [CompilerHost? host, Program? oldProgram, List<Diagnostic>? configFileParsingDiagnostics]);
/// function resolveProjectReferencePath
external ResolvedConfigFileName resolveProjectReferencePath(ProjectReference ref);
/// function createSemanticDiagnosticsBuilderProgram
external SemanticDiagnosticsBuilderProgram createSemanticDiagnosticsBuilderProgram(Program newProgram, BuilderProgramHost host, [SemanticDiagnosticsBuilderProgram? oldProgram, List<Diagnostic>? configFileParsingDiagnostics]);
/// function createSemanticDiagnosticsBuilderProgram  [overload 1]
external SemanticDiagnosticsBuilderProgram createSemanticDiagnosticsBuilderProgram$1(List<String>? rootNames, CompilerOptions? options, [CompilerHost? host, SemanticDiagnosticsBuilderProgram? oldProgram, List<Diagnostic>? configFileParsingDiagnostics, List<ProjectReference>? projectReferences]);
/// function createEmitAndSemanticDiagnosticsBuilderProgram
external EmitAndSemanticDiagnosticsBuilderProgram createEmitAndSemanticDiagnosticsBuilderProgram(Program newProgram, BuilderProgramHost host, [EmitAndSemanticDiagnosticsBuilderProgram? oldProgram, List<Diagnostic>? configFileParsingDiagnostics]);
/// function createEmitAndSemanticDiagnosticsBuilderProgram  [overload 1]
external EmitAndSemanticDiagnosticsBuilderProgram createEmitAndSemanticDiagnosticsBuilderProgram$1(List<String>? rootNames, CompilerOptions? options, [CompilerHost? host, EmitAndSemanticDiagnosticsBuilderProgram? oldProgram, List<Diagnostic>? configFileParsingDiagnostics, List<ProjectReference>? projectReferences]);
/// function createAbstractBuilder
external BuilderProgram createAbstractBuilder(Program newProgram, BuilderProgramHost host, [BuilderProgram? oldProgram, List<Diagnostic>? configFileParsingDiagnostics]);
/// function createAbstractBuilder  [overload 1]
external BuilderProgram createAbstractBuilder$1(List<String>? rootNames, CompilerOptions? options, [CompilerHost? host, BuilderProgram? oldProgram, List<Diagnostic>? configFileParsingDiagnostics, List<ProjectReference>? projectReferences]);
/// function readBuilderProgram
external EmitAndSemanticDiagnosticsBuilderProgram? readBuilderProgram(CompilerOptions compilerOptions, ReadBuildProgramHost host);
/// function createIncrementalCompilerHost
external CompilerHost createIncrementalCompilerHost(CompilerOptions options, [System? system]);
/// function createIncrementalProgram
external T createIncrementalProgram<T>(IncrementalProgramOptions<T> p);
/// function createWatchCompilerHost
external WatchCompilerHostOfConfigFile<T> createWatchCompilerHost<T>(String configFileName, CompilerOptions? optionsToExtend, System system, [CreateProgram<T>? createProgram, DiagnosticReporter? reportDiagnostic, WatchStatusReporter? reportWatchStatus, WatchOptions? watchOptionsToExtend, List<FileExtensionInfo>? extraFileExtensions]);
/// function createWatchCompilerHost  [overload 1]
external WatchCompilerHostOfFilesAndCompilerOptions<T> createWatchCompilerHost$1<T>(List<String> rootFiles, CompilerOptions options, System system, [CreateProgram<T>? createProgram, DiagnosticReporter? reportDiagnostic, WatchStatusReporter? reportWatchStatus, List<ProjectReference>? projectReferences, WatchOptions? watchOptions]);
/// function createWatchProgram
external WatchOfFilesAndCompilerOptions<T> createWatchProgram<T>(WatchCompilerHostOfFilesAndCompilerOptions<T> host);
/// function createWatchProgram  [overload 1]
external WatchOfConfigFile<T> createWatchProgram$1<T>(WatchCompilerHostOfConfigFile<T> host);
/// function createBuilderStatusReporter
external DiagnosticReporter createBuilderStatusReporter(System system, [bool? pretty]);
/// function createSolutionBuilderHost
external SolutionBuilderHost<T> createSolutionBuilderHost<T>([System? system, CreateProgram<T>? createProgram, DiagnosticReporter? reportDiagnostic, DiagnosticReporter? reportSolutionBuilderStatus, ReportEmitErrorSummary? reportErrorSummary]);
/// function createSolutionBuilderWithWatchHost
external SolutionBuilderWithWatchHost<T> createSolutionBuilderWithWatchHost<T>([System? system, CreateProgram<T>? createProgram, DiagnosticReporter? reportDiagnostic, DiagnosticReporter? reportSolutionBuilderStatus, WatchStatusReporter? reportWatchStatus]);
/// function createSolutionBuilder
external SolutionBuilder<T> createSolutionBuilder<T>(SolutionBuilderHost<T> host, List<String> rootNames, BuildOptions defaultOptions);
/// function createSolutionBuilderWithWatch
external SolutionBuilder<T> createSolutionBuilderWithWatch<T>(SolutionBuilderWithWatchHost<T> host, List<String> rootNames, BuildOptions defaultOptions, [WatchOptions? baseWatchOptions]);
/// function isBuildCommand
external bool isBuildCommand(List<String> commandLineArgs);
/// function getDefaultFormatCodeSettings
external FormatCodeSettings getDefaultFormatCodeSettings([String? newLineCharacter]);
/// function fromString  [ns: ts.ScriptSnapshot]
external IScriptSnapshot ScriptSnapshotfromString(String text);
/// function createClassifier
external Classifier createClassifier();
/// function createDocumentRegistry
external DocumentRegistry createDocumentRegistry([bool? useCaseSensitiveFileNames, String? currentDirectory, JSDocParsingMode? jsDocParsingMode]);
/// function preProcessFile
external PreProcessedFileInfo preProcessFile(String sourceText, [bool? readImportFiles, bool? detectJavaScriptImports]);
/// function transpileModule
external TranspileOutput transpileModule(String input, TranspileOptions transpileOptions);
/// function transpileDeclaration
external TranspileOutput transpileDeclaration(String input, TranspileOptions transpileOptions);
/// function transpile
external String transpile(String input, [CompilerOptions? compilerOptions, String? fileName, List<Diagnostic>? diagnostics, String? moduleName]);
/// function toEditorSettings
external EditorSettings toEditorSettings(Object? options);
/// function displayPartsToString
external String displayPartsToString(List<SymbolDisplayPart>? displayParts);
/// function getDefaultCompilerOptions
external CompilerOptions getDefaultCompilerOptions();
/// function getSupportedCodeFixes
external List<String> getSupportedCodeFixes();
/// function createLanguageServiceSourceFile
external SourceFile createLanguageServiceSourceFile(String fileName, IScriptSnapshot scriptSnapshot, Object? scriptTargetOrOptions, String version, bool setNodeParents, [ScriptKind? scriptKind]);
/// function updateLanguageServiceSourceFile
external SourceFile updateLanguageServiceSourceFile(SourceFile sourceFile, IScriptSnapshot scriptSnapshot, String version, TextChangeRange? textChangeRange, [bool? aggressiveChecks]);
/// function createLanguageService
external LanguageService createLanguageService(LanguageServiceHost host, [DocumentRegistry? documentRegistry, Object? syntaxOnlyOrLanguageServiceMode]);
/// function getDefaultLibFilePath
external String getDefaultLibFilePath(CompilerOptions options);
/// function transform
external TransformationResult<T> transform<T>(Object? source, List<TransformerFactory<T>> transformers, [CompilerOptions? compilerOptions]);

/// const emptyArray: SortedReadonlyArray<never>  [ns: ts.server]
external List<Null> ServeremptyArray;
/// const maxProgramSizeForNonTsFiles: number  [ns: ts.server]
external num ServermaxProgramSizeForNonTsFiles;
/// const ProjectsUpdatedInBackgroundEvent = projectsUpdatedInBackground  [ns: ts.server]
const String ServerProjectsUpdatedInBackgroundEvent$v = 'projectsUpdatedInBackground';
/// const ProjectLoadingStartEvent = projectLoadingStart  [ns: ts.server]
const String ServerProjectLoadingStartEvent$v = 'projectLoadingStart';
/// const ProjectLoadingFinishEvent = projectLoadingFinish  [ns: ts.server]
const String ServerProjectLoadingFinishEvent$v = 'projectLoadingFinish';
/// const LargeFileReferencedEvent = largeFileReferenced  [ns: ts.server]
const String ServerLargeFileReferencedEvent$v = 'largeFileReferenced';
/// const ConfigFileDiagEvent = configFileDiag  [ns: ts.server]
const String ServerConfigFileDiagEvent$v = 'configFileDiag';
/// const ProjectLanguageServiceStateEvent = projectLanguageServiceState  [ns: ts.server]
const String ServerProjectLanguageServiceStateEvent$v = 'projectLanguageServiceState';
/// const ProjectInfoTelemetryEvent = projectInfo  [ns: ts.server]
const String ServerProjectInfoTelemetryEvent$v = 'projectInfo';
/// const OpenFileInfoTelemetryEvent = openFileInfo  [ns: ts.server]
const String ServerOpenFileInfoTelemetryEvent$v = 'openFileInfo';
/// const CreateFileWatcherEvent: protocol.CreateFileWatcherEventName  [ns: ts.server]
external ServerProtocolCreateFileWatcherEventName ServerCreateFileWatcherEvent$v;
/// const CreateDirectoryWatcherEvent: protocol.CreateDirectoryWatcherEventName  [ns: ts.server]
external ServerProtocolCreateDirectoryWatcherEventName ServerCreateDirectoryWatcherEvent$v;
/// const CloseFileWatcherEvent: protocol.CloseFileWatcherEventName  [ns: ts.server]
external ServerProtocolCloseFileWatcherEventName ServerCloseFileWatcherEvent$v;
/// const nullTypingsInstaller: ITypingsInstaller  [ns: ts.server]
external ServerITypingsInstaller ServernullTypingsInstaller;
/// const nullCancellationToken: ServerCancellationToken  [ns: ts.server]
external ServerServerCancellationToken ServernullCancellationToken;
/// const CommandNames: any  [ns: ts.server]
external Object? ServerCommandNames$v;
/// const versionMajorMinor = 5.9
const String versionMajorMinor = '5.9';
/// const version: string
external String version;
/// const sys: System
external System sys;
/// const unchangedTextChangeRange: TextChangeRange
external TextChangeRange unchangedTextChangeRange;
/// const factory: NodeFactory
external NodeFactory factory_;
/// const servicesVersion = 0.8
const String servicesVersion = '0.8';

/// export = ts;  (the ts namespace is this library; import with a prefix to mirror `import * as ts`).
