// Generated 1:1 from monaco-lsp-client/src/types.ts (LSP protocol 3.17.0).
// Auto-generated TypeScript declarations. Do not edit manually.
// interface -> abstract class (abstract getters), enum -> class static const,
// type alias -> typedef/carrier, unions/collisions -> Object? (Dart has no union types).
library;

/// enum SemanticTokenTypes
class SemanticTokenTypes {
  static const String namespace = 'namespace';
  static const String type = 'type';
  static const String class_ = 'class';
  static const String enum_ = 'enum';
  static const String interface_ = 'interface';
  static const String struct = 'struct';
  static const String typeParameter = 'typeParameter';
  static const String parameter = 'parameter';
  static const String variable = 'variable';
  static const String property = 'property';
  static const String enumMember = 'enumMember';
  static const String event = 'event';
  static const String function_ = 'function';
  static const String method = 'method';
  static const String macro = 'macro';
  static const String keyword = 'keyword';
  static const String modifier = 'modifier';
  static const String comment = 'comment';
  static const String string = 'string';
  static const String number = 'number';
  static const String regexp = 'regexp';
  static const String operator_ = 'operator';
  static const String decorator = 'decorator';

  const SemanticTokenTypes._();
}

/// enum SemanticTokenModifiers
class SemanticTokenModifiers {
  static const String declaration = 'declaration';
  static const String definition = 'definition';
  static const String readonly = 'readonly';
  static const String static_ = 'static';
  static const String deprecated = 'deprecated';
  static const String abstract_ = 'abstract';
  static const String async_ = 'async';
  static const String modification = 'modification';
  static const String documentation = 'documentation';
  static const String defaultLibrary = 'defaultLibrary';

  const SemanticTokenModifiers._();
}

/// enum DocumentDiagnosticReportKind
class DocumentDiagnosticReportKind {
  static const String Full = 'full';
  static const String Unchanged = 'unchanged';

  const DocumentDiagnosticReportKind._();
}

/// enum ErrorCodes
class ErrorCodes {
  static const int ParseError = -32700;
  static const int InvalidRequest = -32600;
  static const int MethodNotFound = -32601;
  static const int InvalidParams = -32602;
  static const int InternalError = -32603;
  static const int ServerNotInitialized = -32002;
  static const int UnknownErrorCode = -32001;

  const ErrorCodes._();
}

/// enum LSPErrorCodes
class LSPErrorCodes {
  static const int RequestFailed = -32803;
  static const int ServerCancelled = -32802;
  static const int ContentModified = -32801;
  static const int RequestCancelled = -32800;

  const LSPErrorCodes._();
}

/// enum FoldingRangeKind
class FoldingRangeKind {
  static const String Comment = 'comment';
  static const String Imports = 'imports';
  static const String Region = 'region';

  const FoldingRangeKind._();
}

/// enum SymbolKind
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

  const SymbolKind._();
}

/// enum SymbolTag
class SymbolTag {
  static const int Deprecated = 1;

  const SymbolTag._();
}

/// enum UniquenessLevel
class UniquenessLevel {
  static const String document = 'document';
  static const String project = 'project';
  static const String group = 'group';
  static const String scheme = 'scheme';
  static const String global = 'global';

  const UniquenessLevel._();
}

/// enum MonikerKind
class MonikerKind {
  static const String import_ = 'import';
  static const String export_ = 'export';
  static const String local = 'local';

  const MonikerKind._();
}

/// enum InlayHintKind
class InlayHintKind {
  static const int Type = 1;
  static const int Parameter = 2;

  const InlayHintKind._();
}

/// enum MessageType
class MessageType {
  static const int Error = 1;
  static const int Warning = 2;
  static const int Info = 3;
  static const int Log = 4;
  static const int Debug = 5;

  const MessageType._();
}

/// enum TextDocumentSyncKind
class TextDocumentSyncKind {
  static const int None = 0;
  static const int Full = 1;
  static const int Incremental = 2;

  const TextDocumentSyncKind._();
}

/// enum TextDocumentSaveReason
class TextDocumentSaveReason {
  static const int Manual = 1;
  static const int AfterDelay = 2;
  static const int FocusOut = 3;

  const TextDocumentSaveReason._();
}

/// enum CompletionItemKind
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

  const CompletionItemKind._();
}

/// enum CompletionItemTag
class CompletionItemTag {
  static const int Deprecated = 1;

  const CompletionItemTag._();
}

/// enum InsertTextFormat
class InsertTextFormat {
  static const int PlainText = 1;
  static const int Snippet = 2;

  const InsertTextFormat._();
}

/// enum InsertTextMode
class InsertTextMode {
  static const int asIs = 1;
  static const int adjustIndentation = 2;

  const InsertTextMode._();
}

/// enum DocumentHighlightKind
class DocumentHighlightKind {
  static const int Text = 1;
  static const int Read = 2;
  static const int Write = 3;

  const DocumentHighlightKind._();
}

/// enum CodeActionKind
class CodeActionKind {
  static const String Empty = '';
  static const String QuickFix = 'quickfix';
  static const String Refactor = 'refactor';
  static const String RefactorExtract = 'refactor.extract';
  static const String RefactorInline = 'refactor.inline';
  static const String RefactorRewrite = 'refactor.rewrite';
  static const String Source = 'source';
  static const String SourceOrganizeImports = 'source.organizeImports';
  static const String SourceFixAll = 'source.fixAll';

  const CodeActionKind._();
}

/// enum TraceValues
class TraceValues {
  static const String Off = 'off';
  static const String Messages = 'messages';
  static const String Verbose = 'verbose';

  const TraceValues._();
}

/// enum MarkupKind
class MarkupKind {
  static const String PlainText = 'plaintext';
  static const String Markdown = 'markdown';

  const MarkupKind._();
}

/// enum InlineCompletionTriggerKind
class InlineCompletionTriggerKind {
  static const int Invoked = 0;
  static const int Automatic = 1;

  const InlineCompletionTriggerKind._();
}

/// enum PositionEncodingKind
class PositionEncodingKind {
  static const String UTF8 = 'utf-8';
  static const String UTF16 = 'utf-16';
  static const String UTF32 = 'utf-32';

  const PositionEncodingKind._();
}

/// enum FileChangeType
class FileChangeType {
  static const int Created = 1;
  static const int Changed = 2;
  static const int Deleted = 3;

  const FileChangeType._();
}

/// enum WatchKind
class WatchKind {
  static const int Create = 1;
  static const int Change = 2;
  static const int Delete = 4;

  const WatchKind._();
}

/// enum DiagnosticSeverity
class DiagnosticSeverity {
  static const int Error = 1;
  static const int Warning = 2;
  static const int Information = 3;
  static const int Hint = 4;

  const DiagnosticSeverity._();
}

/// enum DiagnosticTag
class DiagnosticTag {
  static const int Unnecessary = 1;
  static const int Deprecated = 2;

  const DiagnosticTag._();
}

/// enum CompletionTriggerKind
class CompletionTriggerKind {
  static const int Invoked = 1;
  static const int TriggerCharacter = 2;
  static const int TriggerForIncompleteCompletions = 3;

  const CompletionTriggerKind._();
}

/// enum SignatureHelpTriggerKind
class SignatureHelpTriggerKind {
  static const int Invoked = 1;
  static const int TriggerCharacter = 2;
  static const int ContentChange = 3;

  const SignatureHelpTriggerKind._();
}

/// enum CodeActionTriggerKind
class CodeActionTriggerKind {
  static const int Invoked = 1;
  static const int Automatic = 2;

  const CodeActionTriggerKind._();
}

/// enum FileOperationPatternKind
class FileOperationPatternKind {
  static const String file = 'file';
  static const String folder = 'folder';

  const FileOperationPatternKind._();
}

/// enum NotebookCellKind
class NotebookCellKind {
  static const int Markup = 1;
  static const int Code = 2;

  const NotebookCellKind._();
}

/// enum ResourceOperationKind
class ResourceOperationKind {
  static const String Create = 'create';
  static const String Rename = 'rename';
  static const String Delete = 'delete';

  const ResourceOperationKind._();
}

/// enum FailureHandlingKind
class FailureHandlingKind {
  static const String Abort = 'abort';
  static const String Transactional = 'transactional';
  static const String TextOnlyTransactional = 'textOnlyTransactional';
  static const String Undo = 'undo';

  const FailureHandlingKind._();
}

/// enum PrepareSupportDefaultBehavior
class PrepareSupportDefaultBehavior {
  static const int Identifier = 1;

  const PrepareSupportDefaultBehavior._();
}

/// enum TokenFormat
class TokenFormat {
  static const String Relative = 'relative';

  const TokenFormat._();
}

/// interface ImplementationParams extends TextDocumentPositionParams, WorkDoneProgressParams, PartialResultParams
abstract class ImplementationParams implements TextDocumentPositionParams, WorkDoneProgressParams, PartialResultParams {
}

/// interface Location
abstract class Location {
  /// uri: string
  String get uri;
  /// range: Range
  Range get range;
}

/// interface ImplementationRegistrationOptions extends TextDocumentRegistrationOptions, ImplementationOptions, StaticRegistrationOptions
abstract class ImplementationRegistrationOptions implements TextDocumentRegistrationOptions, ImplementationOptions, StaticRegistrationOptions {
}

/// interface TypeDefinitionParams extends TextDocumentPositionParams, WorkDoneProgressParams, PartialResultParams
abstract class TypeDefinitionParams implements TextDocumentPositionParams, WorkDoneProgressParams, PartialResultParams {
}

/// interface TypeDefinitionRegistrationOptions extends TextDocumentRegistrationOptions, TypeDefinitionOptions, StaticRegistrationOptions
abstract class TypeDefinitionRegistrationOptions implements TextDocumentRegistrationOptions, TypeDefinitionOptions, StaticRegistrationOptions {
}

/// interface WorkspaceFolder
abstract class WorkspaceFolder {
  /// uri: string
  String get uri;
  /// name: string
  String get name;
}

/// interface DidChangeWorkspaceFoldersParams
abstract class DidChangeWorkspaceFoldersParams {
  /// event: WorkspaceFoldersChangeEvent
  WorkspaceFoldersChangeEvent get event;
}

/// interface ConfigurationParams
abstract class ConfigurationParams {
  /// items: (ConfigurationItem)[]
  List<ConfigurationItem> get items;
}

/// interface DocumentColorParams extends WorkDoneProgressParams, PartialResultParams
abstract class DocumentColorParams implements WorkDoneProgressParams, PartialResultParams {
  /// textDocument: TextDocumentIdentifier
  TextDocumentIdentifier get textDocument;
}

/// interface ColorInformation
abstract class ColorInformation {
  /// range: Range
  Range get range;
  /// color: Color
  Color get color;
}

/// interface DocumentColorRegistrationOptions extends TextDocumentRegistrationOptions, DocumentColorOptions, StaticRegistrationOptions
abstract class DocumentColorRegistrationOptions implements TextDocumentRegistrationOptions, DocumentColorOptions, StaticRegistrationOptions {
}

/// interface ColorPresentationParams extends WorkDoneProgressParams, PartialResultParams
abstract class ColorPresentationParams implements WorkDoneProgressParams, PartialResultParams {
  /// textDocument: TextDocumentIdentifier
  TextDocumentIdentifier get textDocument;
  /// color: Color
  Color get color;
  /// range: Range
  Range get range;
}

/// interface ColorPresentation
abstract class ColorPresentation {
  /// label: string
  String get label;
  /// optional textEdit: TextEdit
  TextEdit? get textEdit;
  /// optional additionalTextEdits: (TextEdit)[]
  List<TextEdit>? get additionalTextEdits;
}

/// interface WorkDoneProgressOptions
abstract class WorkDoneProgressOptions {
  /// optional workDoneProgress: boolean
  bool? get workDoneProgress;
}

/// interface TextDocumentRegistrationOptions
abstract class TextDocumentRegistrationOptions {
  /// documentSelector: DocumentSelector | null
  Object? get documentSelector;
}

/// interface FoldingRangeParams extends WorkDoneProgressParams, PartialResultParams
abstract class FoldingRangeParams implements WorkDoneProgressParams, PartialResultParams {
  /// textDocument: TextDocumentIdentifier
  TextDocumentIdentifier get textDocument;
}

/// interface FoldingRange
abstract class FoldingRange {
  /// startLine: number
  num get startLine;
  /// optional startCharacter: number
  num? get startCharacter;
  /// endLine: number
  num get endLine;
  /// optional endCharacter: number
  num? get endCharacter;
  /// optional kind: FoldingRangeKind
  FoldingRangeKind? get kind;
  /// optional collapsedText: string
  String? get collapsedText;
}

/// interface FoldingRangeRegistrationOptions extends TextDocumentRegistrationOptions, FoldingRangeOptions, StaticRegistrationOptions
abstract class FoldingRangeRegistrationOptions implements TextDocumentRegistrationOptions, FoldingRangeOptions, StaticRegistrationOptions {
}

/// interface DeclarationParams extends TextDocumentPositionParams, WorkDoneProgressParams, PartialResultParams
abstract class DeclarationParams implements TextDocumentPositionParams, WorkDoneProgressParams, PartialResultParams {
}

/// interface DeclarationRegistrationOptions extends DeclarationOptions, TextDocumentRegistrationOptions, StaticRegistrationOptions
abstract class DeclarationRegistrationOptions implements DeclarationOptions, TextDocumentRegistrationOptions, StaticRegistrationOptions {
}

/// interface SelectionRangeParams extends WorkDoneProgressParams, PartialResultParams
abstract class SelectionRangeParams implements WorkDoneProgressParams, PartialResultParams {
  /// textDocument: TextDocumentIdentifier
  TextDocumentIdentifier get textDocument;
  /// positions: (Position)[]
  List<Position> get positions;
}

/// interface SelectionRange
abstract class SelectionRange {
  /// range: Range
  Range get range;
  /// optional parent: SelectionRange
  SelectionRange? get parent;
}

/// interface SelectionRangeRegistrationOptions extends SelectionRangeOptions, TextDocumentRegistrationOptions, StaticRegistrationOptions
abstract class SelectionRangeRegistrationOptions implements SelectionRangeOptions, TextDocumentRegistrationOptions, StaticRegistrationOptions {
}

/// interface WorkDoneProgressCreateParams
abstract class WorkDoneProgressCreateParams {
  /// token: ProgressToken
  ProgressToken get token;
}

/// interface WorkDoneProgressCancelParams
abstract class WorkDoneProgressCancelParams {
  /// token: ProgressToken
  ProgressToken get token;
}

/// interface CallHierarchyPrepareParams extends TextDocumentPositionParams, WorkDoneProgressParams
abstract class CallHierarchyPrepareParams implements TextDocumentPositionParams, WorkDoneProgressParams {
}

/// interface CallHierarchyItem
abstract class CallHierarchyItem {
  /// name: string
  String get name;
  /// kind: SymbolKind
  SymbolKind get kind;
  /// optional tags: (SymbolTag)[]
  List<SymbolTag>? get tags;
  /// optional detail: string
  String? get detail;
  /// uri: string
  String get uri;
  /// range: Range
  Range get range;
  /// selectionRange: Range
  Range get selectionRange;
  /// optional data: LSPAny
  LSPAny? get data;
}

/// interface CallHierarchyRegistrationOptions extends TextDocumentRegistrationOptions, CallHierarchyOptions, StaticRegistrationOptions
abstract class CallHierarchyRegistrationOptions implements TextDocumentRegistrationOptions, CallHierarchyOptions, StaticRegistrationOptions {
}

/// interface CallHierarchyIncomingCallsParams extends WorkDoneProgressParams, PartialResultParams
abstract class CallHierarchyIncomingCallsParams implements WorkDoneProgressParams, PartialResultParams {
  /// item: CallHierarchyItem
  CallHierarchyItem get item;
}

/// interface CallHierarchyIncomingCall
abstract class CallHierarchyIncomingCall {
  /// from: CallHierarchyItem
  CallHierarchyItem get from;
  /// fromRanges: (Range)[]
  List<Range> get fromRanges;
}

/// interface CallHierarchyOutgoingCallsParams extends WorkDoneProgressParams, PartialResultParams
abstract class CallHierarchyOutgoingCallsParams implements WorkDoneProgressParams, PartialResultParams {
  /// item: CallHierarchyItem
  CallHierarchyItem get item;
}

/// interface CallHierarchyOutgoingCall
abstract class CallHierarchyOutgoingCall {
  /// to: CallHierarchyItem
  CallHierarchyItem get to;
  /// fromRanges: (Range)[]
  List<Range> get fromRanges;
}

/// interface SemanticTokensParams extends WorkDoneProgressParams, PartialResultParams
abstract class SemanticTokensParams implements WorkDoneProgressParams, PartialResultParams {
  /// textDocument: TextDocumentIdentifier
  TextDocumentIdentifier get textDocument;
}

/// interface SemanticTokens
abstract class SemanticTokens {
  /// optional resultId: string
  String? get resultId;
  /// data: (number)[]
  List<num> get data;
}

/// interface SemanticTokensPartialResult
abstract class SemanticTokensPartialResult {
  /// data: (number)[]
  List<num> get data;
}

/// interface SemanticTokensRegistrationOptions extends TextDocumentRegistrationOptions, SemanticTokensOptions, StaticRegistrationOptions
abstract class SemanticTokensRegistrationOptions implements TextDocumentRegistrationOptions, SemanticTokensOptions, StaticRegistrationOptions {
}

/// interface SemanticTokensDeltaParams extends WorkDoneProgressParams, PartialResultParams
abstract class SemanticTokensDeltaParams implements WorkDoneProgressParams, PartialResultParams {
  /// textDocument: TextDocumentIdentifier
  TextDocumentIdentifier get textDocument;
  /// previousResultId: string
  String get previousResultId;
}

/// interface SemanticTokensDelta
abstract class SemanticTokensDelta {
  /// optional resultId: string
  String? get resultId;
  /// edits: (SemanticTokensEdit)[]
  List<SemanticTokensEdit> get edits;
}

/// interface SemanticTokensDeltaPartialResult
abstract class SemanticTokensDeltaPartialResult {
  /// edits: (SemanticTokensEdit)[]
  List<SemanticTokensEdit> get edits;
}

/// interface SemanticTokensRangeParams extends WorkDoneProgressParams, PartialResultParams
abstract class SemanticTokensRangeParams implements WorkDoneProgressParams, PartialResultParams {
  /// textDocument: TextDocumentIdentifier
  TextDocumentIdentifier get textDocument;
  /// range: Range
  Range get range;
}

/// interface ShowDocumentParams
abstract class ShowDocumentParams {
  /// uri: string
  String get uri;
  /// optional external: boolean
  bool? get external_;
  /// optional takeFocus: boolean
  bool? get takeFocus;
  /// optional selection: Range
  Range? get selection;
}

/// interface ShowDocumentResult
abstract class ShowDocumentResult {
  /// success: boolean
  bool get success;
}

/// interface LinkedEditingRangeParams extends TextDocumentPositionParams, WorkDoneProgressParams
abstract class LinkedEditingRangeParams implements TextDocumentPositionParams, WorkDoneProgressParams {
}

/// interface LinkedEditingRanges
abstract class LinkedEditingRanges {
  /// ranges: (Range)[]
  List<Range> get ranges;
  /// optional wordPattern: string
  String? get wordPattern;
}

/// interface LinkedEditingRangeRegistrationOptions extends TextDocumentRegistrationOptions, LinkedEditingRangeOptions, StaticRegistrationOptions
abstract class LinkedEditingRangeRegistrationOptions implements TextDocumentRegistrationOptions, LinkedEditingRangeOptions, StaticRegistrationOptions {
}

/// interface CreateFilesParams
abstract class CreateFilesParams {
  /// files: (FileCreate)[]
  List<FileCreate> get files;
}

/// interface WorkspaceEdit
abstract class WorkspaceEdit {
  /// optional changes: { [key: string]: (TextEdit)[] }
  Map<String, Object?>? get changes;
  /// optional documentChanges: (TextDocumentEdit | CreateFile | RenameFile | DeleteFile)[]
  List<Object?>? get documentChanges;
  /// optional changeAnnotations: { [key: ChangeAnnotationIdentifier]: ChangeAnnotation }
  Map<String, Object?>? get changeAnnotations;
}

/// interface FileOperationRegistrationOptions
abstract class FileOperationRegistrationOptions {
  /// filters: (FileOperationFilter)[]
  List<FileOperationFilter> get filters;
}

/// interface RenameFilesParams
abstract class RenameFilesParams {
  /// files: (FileRename)[]
  List<FileRename> get files;
}

/// interface DeleteFilesParams
abstract class DeleteFilesParams {
  /// files: (FileDelete)[]
  List<FileDelete> get files;
}

/// interface MonikerParams extends TextDocumentPositionParams, WorkDoneProgressParams, PartialResultParams
abstract class MonikerParams implements TextDocumentPositionParams, WorkDoneProgressParams, PartialResultParams {
}

/// interface Moniker
abstract class Moniker {
  /// scheme: string
  String get scheme;
  /// identifier: string
  String get identifier;
  /// unique: UniquenessLevel
  UniquenessLevel get unique;
  /// optional kind: MonikerKind
  MonikerKind? get kind;
}

/// interface MonikerRegistrationOptions extends TextDocumentRegistrationOptions, MonikerOptions
abstract class MonikerRegistrationOptions implements TextDocumentRegistrationOptions, MonikerOptions {
}

/// interface TypeHierarchyPrepareParams extends TextDocumentPositionParams, WorkDoneProgressParams
abstract class TypeHierarchyPrepareParams implements TextDocumentPositionParams, WorkDoneProgressParams {
}

/// interface TypeHierarchyItem
abstract class TypeHierarchyItem {
  /// name: string
  String get name;
  /// kind: SymbolKind
  SymbolKind get kind;
  /// optional tags: (SymbolTag)[]
  List<SymbolTag>? get tags;
  /// optional detail: string
  String? get detail;
  /// uri: string
  String get uri;
  /// range: Range
  Range get range;
  /// selectionRange: Range
  Range get selectionRange;
  /// optional data: LSPAny
  LSPAny? get data;
}

/// interface TypeHierarchyRegistrationOptions extends TextDocumentRegistrationOptions, TypeHierarchyOptions, StaticRegistrationOptions
abstract class TypeHierarchyRegistrationOptions implements TextDocumentRegistrationOptions, TypeHierarchyOptions, StaticRegistrationOptions {
}

/// interface TypeHierarchySupertypesParams extends WorkDoneProgressParams, PartialResultParams
abstract class TypeHierarchySupertypesParams implements WorkDoneProgressParams, PartialResultParams {
  /// item: TypeHierarchyItem
  TypeHierarchyItem get item;
}

/// interface TypeHierarchySubtypesParams extends WorkDoneProgressParams, PartialResultParams
abstract class TypeHierarchySubtypesParams implements WorkDoneProgressParams, PartialResultParams {
  /// item: TypeHierarchyItem
  TypeHierarchyItem get item;
}

/// interface InlineValueParams extends WorkDoneProgressParams
abstract class InlineValueParams implements WorkDoneProgressParams {
  /// textDocument: TextDocumentIdentifier
  TextDocumentIdentifier get textDocument;
  /// range: Range
  Range get range;
  /// context: InlineValueContext
  InlineValueContext get context;
}

/// interface InlineValueRegistrationOptions extends InlineValueOptions, TextDocumentRegistrationOptions, StaticRegistrationOptions
abstract class InlineValueRegistrationOptions implements InlineValueOptions, TextDocumentRegistrationOptions, StaticRegistrationOptions {
}

/// interface InlayHintParams extends WorkDoneProgressParams
abstract class InlayHintParams implements WorkDoneProgressParams {
  /// textDocument: TextDocumentIdentifier
  TextDocumentIdentifier get textDocument;
  /// range: Range
  Range get range;
}

/// interface InlayHint
abstract class InlayHint {
  /// position: Position
  Position get position;
  /// label: string | (InlayHintLabelPart)[]
  Object? get label;
  /// optional kind: InlayHintKind
  InlayHintKind? get kind;
  /// optional textEdits: (TextEdit)[]
  List<TextEdit>? get textEdits;
  /// optional tooltip: string | MarkupContent
  Object? get tooltip;
  /// optional paddingLeft: boolean
  bool? get paddingLeft;
  /// optional paddingRight: boolean
  bool? get paddingRight;
  /// optional data: LSPAny
  LSPAny? get data;
}

/// interface InlayHintRegistrationOptions extends InlayHintOptions, TextDocumentRegistrationOptions, StaticRegistrationOptions
abstract class InlayHintRegistrationOptions implements InlayHintOptions, TextDocumentRegistrationOptions, StaticRegistrationOptions {
}

/// interface DocumentDiagnosticParams extends WorkDoneProgressParams, PartialResultParams
abstract class DocumentDiagnosticParams implements WorkDoneProgressParams, PartialResultParams {
  /// textDocument: TextDocumentIdentifier
  TextDocumentIdentifier get textDocument;
  /// optional identifier: string
  String? get identifier;
  /// optional previousResultId: string
  String? get previousResultId;
}

/// interface DocumentDiagnosticReportPartialResult
abstract class DocumentDiagnosticReportPartialResult {
  /// relatedDocuments: { [key: string]: FullDocumentDiagnosticReport | UnchangedDocumentDiagnosticReport }
  Map<String, Object?> get relatedDocuments;
}

/// interface DiagnosticServerCancellationData
abstract class DiagnosticServerCancellationData {
  /// retriggerRequest: boolean
  bool get retriggerRequest;
}

/// interface DiagnosticRegistrationOptions extends TextDocumentRegistrationOptions, DiagnosticOptions, StaticRegistrationOptions
abstract class DiagnosticRegistrationOptions implements TextDocumentRegistrationOptions, DiagnosticOptions, StaticRegistrationOptions {
}

/// interface WorkspaceDiagnosticParams extends WorkDoneProgressParams, PartialResultParams
abstract class WorkspaceDiagnosticParams implements WorkDoneProgressParams, PartialResultParams {
  /// optional identifier: string
  String? get identifier;
  /// previousResultIds: (PreviousResultId)[]
  List<PreviousResultId> get previousResultIds;
}

/// interface WorkspaceDiagnosticReport
abstract class WorkspaceDiagnosticReport {
  /// items: (WorkspaceDocumentDiagnosticReport)[]
  List<WorkspaceDocumentDiagnosticReport> get items;
}

/// interface WorkspaceDiagnosticReportPartialResult
abstract class WorkspaceDiagnosticReportPartialResult {
  /// items: (WorkspaceDocumentDiagnosticReport)[]
  List<WorkspaceDocumentDiagnosticReport> get items;
}

/// interface DidOpenNotebookDocumentParams
abstract class DidOpenNotebookDocumentParams {
  /// notebookDocument: NotebookDocument
  NotebookDocument get notebookDocument;
  /// cellTextDocuments: (TextDocumentItem)[]
  List<TextDocumentItem> get cellTextDocuments;
}

/// interface DidChangeNotebookDocumentParams
abstract class DidChangeNotebookDocumentParams {
  /// notebookDocument: VersionedNotebookDocumentIdentifier
  VersionedNotebookDocumentIdentifier get notebookDocument;
  /// change: NotebookDocumentChangeEvent
  NotebookDocumentChangeEvent get change;
}

/// interface DidSaveNotebookDocumentParams
abstract class DidSaveNotebookDocumentParams {
  /// notebookDocument: NotebookDocumentIdentifier
  NotebookDocumentIdentifier get notebookDocument;
}

/// interface DidCloseNotebookDocumentParams
abstract class DidCloseNotebookDocumentParams {
  /// notebookDocument: NotebookDocumentIdentifier
  NotebookDocumentIdentifier get notebookDocument;
  /// cellTextDocuments: (TextDocumentIdentifier)[]
  List<TextDocumentIdentifier> get cellTextDocuments;
}

/// interface InlineCompletionParams extends TextDocumentPositionParams, WorkDoneProgressParams
abstract class InlineCompletionParams implements TextDocumentPositionParams, WorkDoneProgressParams {
  /// context: InlineCompletionContext
  InlineCompletionContext get context;
}

/// interface InlineCompletionList
abstract class InlineCompletionList {
  /// items: (InlineCompletionItem)[]
  List<InlineCompletionItem> get items;
}

/// interface InlineCompletionItem
abstract class InlineCompletionItem {
  /// insertText: string | StringValue
  Object? get insertText;
  /// optional filterText: string
  String? get filterText;
  /// optional range: Range
  Range? get range;
  /// optional command: Command
  Command? get command;
}

/// interface InlineCompletionRegistrationOptions extends InlineCompletionOptions, TextDocumentRegistrationOptions, StaticRegistrationOptions
abstract class InlineCompletionRegistrationOptions implements InlineCompletionOptions, TextDocumentRegistrationOptions, StaticRegistrationOptions {
}

/// interface RegistrationParams
abstract class RegistrationParams {
  /// registrations: (Registration)[]
  List<Registration> get registrations;
}

/// interface UnregistrationParams
abstract class UnregistrationParams {
  /// unregisterations: (Unregistration)[]
  List<Unregistration> get unregisterations;
}

/// interface InitializeParams extends _InitializeParams, WorkspaceFoldersInitializeParams
abstract class InitializeParams implements _InitializeParams, WorkspaceFoldersInitializeParams {
}

/// interface InitializeResult
abstract class InitializeResult {
  /// capabilities: ServerCapabilities
  ServerCapabilities get capabilities;
  /// optional serverInfo: { name: string; version?: string }
  Map<String, Object?>? get serverInfo;
}

/// interface InitializeError
abstract class InitializeError {
  /// retry: boolean
  bool get retry;
}

/// interface InitializedParams
abstract class InitializedParams {
}

/// interface DidChangeConfigurationParams
abstract class DidChangeConfigurationParams {
  /// settings: LSPAny
  LSPAny get settings;
}

/// interface DidChangeConfigurationRegistrationOptions
abstract class DidChangeConfigurationRegistrationOptions {
  /// optional section: string | (string)[]
  Object? get section;
}

/// interface ShowMessageParams
abstract class ShowMessageParams {
  /// type: MessageType
  MessageType get type;
  /// message: string
  String get message;
}

/// interface ShowMessageRequestParams
abstract class ShowMessageRequestParams {
  /// type: MessageType
  MessageType get type;
  /// message: string
  String get message;
  /// optional actions: (MessageActionItem)[]
  List<MessageActionItem>? get actions;
}

/// interface MessageActionItem
abstract class MessageActionItem {
  /// title: string
  String get title;
}

/// interface LogMessageParams
abstract class LogMessageParams {
  /// type: MessageType
  MessageType get type;
  /// message: string
  String get message;
}

/// interface DidOpenTextDocumentParams
abstract class DidOpenTextDocumentParams {
  /// textDocument: TextDocumentItem
  TextDocumentItem get textDocument;
}

/// interface DidChangeTextDocumentParams
abstract class DidChangeTextDocumentParams {
  /// textDocument: VersionedTextDocumentIdentifier
  VersionedTextDocumentIdentifier get textDocument;
  /// contentChanges: (TextDocumentContentChangeEvent)[]
  List<TextDocumentContentChangeEvent> get contentChanges;
}

/// interface TextDocumentChangeRegistrationOptions extends TextDocumentRegistrationOptions
abstract class TextDocumentChangeRegistrationOptions implements TextDocumentRegistrationOptions {
  /// syncKind: TextDocumentSyncKind
  TextDocumentSyncKind get syncKind;
}

/// interface DidCloseTextDocumentParams
abstract class DidCloseTextDocumentParams {
  /// textDocument: TextDocumentIdentifier
  TextDocumentIdentifier get textDocument;
}

/// interface DidSaveTextDocumentParams
abstract class DidSaveTextDocumentParams {
  /// textDocument: TextDocumentIdentifier
  TextDocumentIdentifier get textDocument;
  /// optional text: string
  String? get text;
}

/// interface TextDocumentSaveRegistrationOptions extends TextDocumentRegistrationOptions, SaveOptions
abstract class TextDocumentSaveRegistrationOptions implements TextDocumentRegistrationOptions, SaveOptions {
}

/// interface WillSaveTextDocumentParams
abstract class WillSaveTextDocumentParams {
  /// textDocument: TextDocumentIdentifier
  TextDocumentIdentifier get textDocument;
  /// reason: TextDocumentSaveReason
  TextDocumentSaveReason get reason;
}

/// interface TextEdit
abstract class TextEdit {
  /// range: Range
  Range get range;
  /// newText: string
  String get newText;
}

/// interface DidChangeWatchedFilesParams
abstract class DidChangeWatchedFilesParams {
  /// changes: (FileEvent)[]
  List<FileEvent> get changes;
}

/// interface DidChangeWatchedFilesRegistrationOptions
abstract class DidChangeWatchedFilesRegistrationOptions {
  /// watchers: (FileSystemWatcher)[]
  List<FileSystemWatcher> get watchers;
}

/// interface PublishDiagnosticsParams
abstract class PublishDiagnosticsParams {
  /// uri: string
  String get uri;
  /// optional version: number
  num? get version;
  /// diagnostics: (Diagnostic)[]
  List<Diagnostic> get diagnostics;
}

/// interface CompletionParams extends TextDocumentPositionParams, WorkDoneProgressParams, PartialResultParams
abstract class CompletionParams implements TextDocumentPositionParams, WorkDoneProgressParams, PartialResultParams {
  /// optional context: CompletionContext
  CompletionContext? get context;
}

/// interface CompletionItem
abstract class CompletionItem {
  /// label: string
  String get label;
  /// optional labelDetails: CompletionItemLabelDetails
  CompletionItemLabelDetails? get labelDetails;
  /// optional kind: CompletionItemKind
  CompletionItemKind? get kind;
  /// optional tags: (CompletionItemTag)[]
  List<CompletionItemTag>? get tags;
  /// optional detail: string
  String? get detail;
  /// optional documentation: string | MarkupContent
  Object? get documentation;
  /// optional deprecated: boolean
  bool? get deprecated;
  /// optional preselect: boolean
  bool? get preselect;
  /// optional sortText: string
  String? get sortText;
  /// optional filterText: string
  String? get filterText;
  /// optional insertText: string
  String? get insertText;
  /// optional insertTextFormat: InsertTextFormat
  InsertTextFormat? get insertTextFormat;
  /// optional insertTextMode: InsertTextMode
  InsertTextMode? get insertTextMode;
  /// optional textEdit: TextEdit | InsertReplaceEdit
  Object? get textEdit;
  /// optional textEditText: string
  String? get textEditText;
  /// optional additionalTextEdits: (TextEdit)[]
  List<TextEdit>? get additionalTextEdits;
  /// optional commitCharacters: (string)[]
  List<String>? get commitCharacters;
  /// optional command: Command
  Command? get command;
  /// optional data: LSPAny
  LSPAny? get data;
}

/// interface CompletionList
abstract class CompletionList {
  /// isIncomplete: boolean
  bool get isIncomplete;
  /// optional itemDefaults: { commitCharacters?: (string)[]; editRange?: Range | { insert: Range; replace: Range }; insertTextFormat?: InsertTextFormat; insertTextMode?: InsertTextMode; data?: LSPAny }
  Map<String, Object?>? get itemDefaults;
  /// items: (CompletionItem)[]
  List<CompletionItem> get items;
}

/// interface CompletionRegistrationOptions extends TextDocumentRegistrationOptions, CompletionOptions
abstract class CompletionRegistrationOptions implements TextDocumentRegistrationOptions, CompletionOptions {
}

/// interface HoverParams extends TextDocumentPositionParams, WorkDoneProgressParams
abstract class HoverParams implements TextDocumentPositionParams, WorkDoneProgressParams {
}

/// interface Hover
abstract class Hover {
  /// contents: MarkupContent | MarkedString | (MarkedString)[]
  Object? get contents;
  /// optional range: Range
  Range? get range;
}

/// interface HoverRegistrationOptions extends TextDocumentRegistrationOptions, HoverOptions
abstract class HoverRegistrationOptions implements TextDocumentRegistrationOptions, HoverOptions {
}

/// interface SignatureHelpParams extends TextDocumentPositionParams, WorkDoneProgressParams
abstract class SignatureHelpParams implements TextDocumentPositionParams, WorkDoneProgressParams {
  /// optional context: SignatureHelpContext
  SignatureHelpContext? get context;
}

/// interface SignatureHelp
abstract class SignatureHelp {
  /// signatures: (SignatureInformation)[]
  List<SignatureInformation> get signatures;
  /// optional activeSignature: number
  num? get activeSignature;
  /// optional activeParameter: number
  num? get activeParameter;
}

/// interface SignatureHelpRegistrationOptions extends TextDocumentRegistrationOptions, SignatureHelpOptions
abstract class SignatureHelpRegistrationOptions implements TextDocumentRegistrationOptions, SignatureHelpOptions {
}

/// interface DefinitionParams extends TextDocumentPositionParams, WorkDoneProgressParams, PartialResultParams
abstract class DefinitionParams implements TextDocumentPositionParams, WorkDoneProgressParams, PartialResultParams {
}

/// interface DefinitionRegistrationOptions extends TextDocumentRegistrationOptions, DefinitionOptions
abstract class DefinitionRegistrationOptions implements TextDocumentRegistrationOptions, DefinitionOptions {
}

/// interface ReferenceParams extends TextDocumentPositionParams, WorkDoneProgressParams, PartialResultParams
abstract class ReferenceParams implements TextDocumentPositionParams, WorkDoneProgressParams, PartialResultParams {
  /// context: ReferenceContext
  ReferenceContext get context;
}

/// interface ReferenceRegistrationOptions extends TextDocumentRegistrationOptions, ReferenceOptions
abstract class ReferenceRegistrationOptions implements TextDocumentRegistrationOptions, ReferenceOptions {
}

/// interface DocumentHighlightParams extends TextDocumentPositionParams, WorkDoneProgressParams, PartialResultParams
abstract class DocumentHighlightParams implements TextDocumentPositionParams, WorkDoneProgressParams, PartialResultParams {
}

/// interface DocumentHighlight
abstract class DocumentHighlight {
  /// range: Range
  Range get range;
  /// optional kind: DocumentHighlightKind
  DocumentHighlightKind? get kind;
}

/// interface DocumentHighlightRegistrationOptions extends TextDocumentRegistrationOptions, DocumentHighlightOptions
abstract class DocumentHighlightRegistrationOptions implements TextDocumentRegistrationOptions, DocumentHighlightOptions {
}

/// interface DocumentSymbolParams extends WorkDoneProgressParams, PartialResultParams
abstract class DocumentSymbolParams implements WorkDoneProgressParams, PartialResultParams {
  /// textDocument: TextDocumentIdentifier
  TextDocumentIdentifier get textDocument;
}

/// interface SymbolInformation extends BaseSymbolInformation
abstract class SymbolInformation implements BaseSymbolInformation {
  /// optional deprecated: boolean
  bool? get deprecated;
  /// location: Location
  Location get location;
}

/// interface DocumentSymbol
abstract class DocumentSymbol {
  /// name: string
  String get name;
  /// optional detail: string
  String? get detail;
  /// kind: SymbolKind
  SymbolKind get kind;
  /// optional tags: (SymbolTag)[]
  List<SymbolTag>? get tags;
  /// optional deprecated: boolean
  bool? get deprecated;
  /// range: Range
  Range get range;
  /// selectionRange: Range
  Range get selectionRange;
  /// optional children: (DocumentSymbol)[]
  List<DocumentSymbol>? get children;
}

/// interface DocumentSymbolRegistrationOptions extends TextDocumentRegistrationOptions, DocumentSymbolOptions
abstract class DocumentSymbolRegistrationOptions implements TextDocumentRegistrationOptions, DocumentSymbolOptions {
}

/// interface CodeActionParams extends WorkDoneProgressParams, PartialResultParams
abstract class CodeActionParams implements WorkDoneProgressParams, PartialResultParams {
  /// textDocument: TextDocumentIdentifier
  TextDocumentIdentifier get textDocument;
  /// range: Range
  Range get range;
  /// context: CodeActionContext
  CodeActionContext get context;
}

/// interface Command
abstract class Command {
  /// title: string
  String get title;
  /// command: string
  String get command;
  /// optional arguments: (LSPAny)[]
  List<LSPAny>? get arguments;
}

/// interface CodeAction
abstract class CodeAction {
  /// title: string
  String get title;
  /// optional kind: CodeActionKind
  CodeActionKind? get kind;
  /// optional diagnostics: (Diagnostic)[]
  List<Diagnostic>? get diagnostics;
  /// optional isPreferred: boolean
  bool? get isPreferred;
  /// optional disabled: { reason: string }
  Map<String, Object?>? get disabled;
  /// optional edit: WorkspaceEdit
  WorkspaceEdit? get edit;
  /// optional command: Command
  Command? get command;
  /// optional data: LSPAny
  LSPAny? get data;
}

/// interface CodeActionRegistrationOptions extends TextDocumentRegistrationOptions, CodeActionOptions
abstract class CodeActionRegistrationOptions implements TextDocumentRegistrationOptions, CodeActionOptions {
}

/// interface WorkspaceSymbolParams extends WorkDoneProgressParams, PartialResultParams
abstract class WorkspaceSymbolParams implements WorkDoneProgressParams, PartialResultParams {
  /// query: string
  String get query;
}

/// interface WorkspaceSymbol extends BaseSymbolInformation
abstract class WorkspaceSymbol implements BaseSymbolInformation {
  /// location: Location | { uri: string }
  Object? get location;
  /// optional data: LSPAny
  LSPAny? get data;
}

/// interface WorkspaceSymbolRegistrationOptions extends WorkspaceSymbolOptions
abstract class WorkspaceSymbolRegistrationOptions implements WorkspaceSymbolOptions {
}

/// interface CodeLensParams extends WorkDoneProgressParams, PartialResultParams
abstract class CodeLensParams implements WorkDoneProgressParams, PartialResultParams {
  /// textDocument: TextDocumentIdentifier
  TextDocumentIdentifier get textDocument;
}

/// interface CodeLens
abstract class CodeLens {
  /// range: Range
  Range get range;
  /// optional command: Command
  Command? get command;
  /// optional data: LSPAny
  LSPAny? get data;
}

/// interface CodeLensRegistrationOptions extends TextDocumentRegistrationOptions, CodeLensOptions
abstract class CodeLensRegistrationOptions implements TextDocumentRegistrationOptions, CodeLensOptions {
}

/// interface DocumentLinkParams extends WorkDoneProgressParams, PartialResultParams
abstract class DocumentLinkParams implements WorkDoneProgressParams, PartialResultParams {
  /// textDocument: TextDocumentIdentifier
  TextDocumentIdentifier get textDocument;
}

/// interface DocumentLink
abstract class DocumentLink {
  /// range: Range
  Range get range;
  /// optional target: string
  String? get target;
  /// optional tooltip: string
  String? get tooltip;
  /// optional data: LSPAny
  LSPAny? get data;
}

/// interface DocumentLinkRegistrationOptions extends TextDocumentRegistrationOptions, DocumentLinkOptions
abstract class DocumentLinkRegistrationOptions implements TextDocumentRegistrationOptions, DocumentLinkOptions {
}

/// interface DocumentFormattingParams extends WorkDoneProgressParams
abstract class DocumentFormattingParams implements WorkDoneProgressParams {
  /// textDocument: TextDocumentIdentifier
  TextDocumentIdentifier get textDocument;
  /// options: FormattingOptions
  FormattingOptions get options;
}

/// interface DocumentFormattingRegistrationOptions extends TextDocumentRegistrationOptions, DocumentFormattingOptions
abstract class DocumentFormattingRegistrationOptions implements TextDocumentRegistrationOptions, DocumentFormattingOptions {
}

/// interface DocumentRangeFormattingParams extends WorkDoneProgressParams
abstract class DocumentRangeFormattingParams implements WorkDoneProgressParams {
  /// textDocument: TextDocumentIdentifier
  TextDocumentIdentifier get textDocument;
  /// range: Range
  Range get range;
  /// options: FormattingOptions
  FormattingOptions get options;
}

/// interface DocumentRangeFormattingRegistrationOptions extends TextDocumentRegistrationOptions, DocumentRangeFormattingOptions
abstract class DocumentRangeFormattingRegistrationOptions implements TextDocumentRegistrationOptions, DocumentRangeFormattingOptions {
}

/// interface DocumentRangesFormattingParams extends WorkDoneProgressParams
abstract class DocumentRangesFormattingParams implements WorkDoneProgressParams {
  /// textDocument: TextDocumentIdentifier
  TextDocumentIdentifier get textDocument;
  /// ranges: (Range)[]
  List<Range> get ranges;
  /// options: FormattingOptions
  FormattingOptions get options;
}

/// interface DocumentOnTypeFormattingParams
abstract class DocumentOnTypeFormattingParams {
  /// textDocument: TextDocumentIdentifier
  TextDocumentIdentifier get textDocument;
  /// position: Position
  Position get position;
  /// ch: string
  String get ch;
  /// options: FormattingOptions
  FormattingOptions get options;
}

/// interface DocumentOnTypeFormattingRegistrationOptions extends TextDocumentRegistrationOptions, DocumentOnTypeFormattingOptions
abstract class DocumentOnTypeFormattingRegistrationOptions implements TextDocumentRegistrationOptions, DocumentOnTypeFormattingOptions {
}

/// interface RenameParams extends WorkDoneProgressParams
abstract class RenameParams implements WorkDoneProgressParams {
  /// textDocument: TextDocumentIdentifier
  TextDocumentIdentifier get textDocument;
  /// position: Position
  Position get position;
  /// newName: string
  String get newName;
}

/// interface RenameRegistrationOptions extends TextDocumentRegistrationOptions, RenameOptions
abstract class RenameRegistrationOptions implements TextDocumentRegistrationOptions, RenameOptions {
}

/// interface PrepareRenameParams extends TextDocumentPositionParams, WorkDoneProgressParams
abstract class PrepareRenameParams implements TextDocumentPositionParams, WorkDoneProgressParams {
}

/// interface ExecuteCommandParams extends WorkDoneProgressParams
abstract class ExecuteCommandParams implements WorkDoneProgressParams {
  /// command: string
  String get command;
  /// optional arguments: (LSPAny)[]
  List<LSPAny>? get arguments;
}

/// interface ExecuteCommandRegistrationOptions extends ExecuteCommandOptions
abstract class ExecuteCommandRegistrationOptions implements ExecuteCommandOptions {
}

/// interface ApplyWorkspaceEditParams
abstract class ApplyWorkspaceEditParams {
  /// optional label: string
  String? get label;
  /// edit: WorkspaceEdit
  WorkspaceEdit get edit;
}

/// interface ApplyWorkspaceEditResult
abstract class ApplyWorkspaceEditResult {
  /// applied: boolean
  bool get applied;
  /// optional failureReason: string
  String? get failureReason;
  /// optional failedChange: number
  num? get failedChange;
}

/// interface WorkDoneProgressBegin
abstract class WorkDoneProgressBegin {
  /// kind: 'begin'
  String get kind;
  /// title: string
  String get title;
  /// optional cancellable: boolean
  bool? get cancellable;
  /// optional message: string
  String? get message;
  /// optional percentage: number
  num? get percentage;
}

/// interface WorkDoneProgressReport
abstract class WorkDoneProgressReport {
  /// kind: 'report'
  String get kind;
  /// optional cancellable: boolean
  bool? get cancellable;
  /// optional message: string
  String? get message;
  /// optional percentage: number
  num? get percentage;
}

/// interface WorkDoneProgressEnd
abstract class WorkDoneProgressEnd {
  /// kind: 'end'
  String get kind;
  /// optional message: string
  String? get message;
}

/// interface SetTraceParams
abstract class SetTraceParams {
  /// value: TraceValues
  TraceValues get value;
}

/// interface LogTraceParams
abstract class LogTraceParams {
  /// message: string
  String get message;
  /// optional verbose: string
  String? get verbose;
}

/// interface CancelParams
abstract class CancelParams {
  /// id: number | string
  Object? get id;
}

/// interface ProgressParams
abstract class ProgressParams {
  /// token: ProgressToken
  ProgressToken get token;
  /// value: LSPAny
  LSPAny get value;
}

/// interface TextDocumentPositionParams
abstract class TextDocumentPositionParams {
  /// textDocument: TextDocumentIdentifier
  TextDocumentIdentifier get textDocument;
  /// position: Position
  Position get position;
}

/// interface WorkDoneProgressParams
abstract class WorkDoneProgressParams {
  /// optional workDoneToken: ProgressToken
  ProgressToken? get workDoneToken;
}

/// interface PartialResultParams
abstract class PartialResultParams {
  /// optional partialResultToken: ProgressToken
  ProgressToken? get partialResultToken;
}

/// interface LocationLink
abstract class LocationLink {
  /// optional originSelectionRange: Range
  Range? get originSelectionRange;
  /// targetUri: string
  String get targetUri;
  /// targetRange: Range
  Range get targetRange;
  /// targetSelectionRange: Range
  Range get targetSelectionRange;
}

/// interface Range
abstract class Range {
  /// start: Position
  Position get start;
  /// end: Position
  Position get end;
}

/// interface ImplementationOptions extends WorkDoneProgressOptions
abstract class ImplementationOptions implements WorkDoneProgressOptions {
}

/// interface StaticRegistrationOptions
abstract class StaticRegistrationOptions {
  /// optional id: string
  String? get id;
}

/// interface TypeDefinitionOptions extends WorkDoneProgressOptions
abstract class TypeDefinitionOptions implements WorkDoneProgressOptions {
}

/// interface WorkspaceFoldersChangeEvent
abstract class WorkspaceFoldersChangeEvent {
  /// added: (WorkspaceFolder)[]
  List<WorkspaceFolder> get added;
  /// removed: (WorkspaceFolder)[]
  List<WorkspaceFolder> get removed;
}

/// interface ConfigurationItem
abstract class ConfigurationItem {
  /// optional scopeUri: string
  String? get scopeUri;
  /// optional section: string
  String? get section;
}

/// interface TextDocumentIdentifier
abstract class TextDocumentIdentifier {
  /// uri: string
  String get uri;
}

/// interface Color
abstract class Color {
  /// red: number
  num get red;
  /// green: number
  num get green;
  /// blue: number
  num get blue;
  /// alpha: number
  num get alpha;
}

/// interface DocumentColorOptions extends WorkDoneProgressOptions
abstract class DocumentColorOptions implements WorkDoneProgressOptions {
}

/// interface FoldingRangeOptions extends WorkDoneProgressOptions
abstract class FoldingRangeOptions implements WorkDoneProgressOptions {
}

/// interface DeclarationOptions extends WorkDoneProgressOptions
abstract class DeclarationOptions implements WorkDoneProgressOptions {
}

/// interface Position
abstract class Position {
  /// line: number
  num get line;
  /// character: number
  num get character;
}

/// interface SelectionRangeOptions extends WorkDoneProgressOptions
abstract class SelectionRangeOptions implements WorkDoneProgressOptions {
}

/// interface CallHierarchyOptions extends WorkDoneProgressOptions
abstract class CallHierarchyOptions implements WorkDoneProgressOptions {
}

/// interface SemanticTokensOptions extends WorkDoneProgressOptions
abstract class SemanticTokensOptions implements WorkDoneProgressOptions {
  /// legend: SemanticTokensLegend
  SemanticTokensLegend get legend;
  /// optional range: boolean | { }
  Object? get range;
  /// optional full: boolean | { delta?: boolean }
  Object? get full;
}

/// interface SemanticTokensEdit
abstract class SemanticTokensEdit {
  /// start: number
  num get start;
  /// deleteCount: number
  num get deleteCount;
  /// optional data: (number)[]
  List<num>? get data;
}

/// interface LinkedEditingRangeOptions extends WorkDoneProgressOptions
abstract class LinkedEditingRangeOptions implements WorkDoneProgressOptions {
}

/// interface FileCreate
abstract class FileCreate {
  /// uri: string
  String get uri;
}

/// interface TextDocumentEdit
abstract class TextDocumentEdit {
  /// textDocument: OptionalVersionedTextDocumentIdentifier
  OptionalVersionedTextDocumentIdentifier get textDocument;
  /// edits: (TextEdit | AnnotatedTextEdit)[]
  List<Object?> get edits;
}

/// interface CreateFile extends ResourceOperation
abstract class CreateFile implements ResourceOperation {
  /// kind: 'create'
  String get kind;
  /// uri: string
  String get uri;
  /// optional options: CreateFileOptions
  CreateFileOptions? get options;
}

/// interface RenameFile extends ResourceOperation
abstract class RenameFile implements ResourceOperation {
  /// kind: 'rename'
  String get kind;
  /// oldUri: string
  String get oldUri;
  /// newUri: string
  String get newUri;
  /// optional options: RenameFileOptions
  RenameFileOptions? get options;
}

/// interface DeleteFile extends ResourceOperation
abstract class DeleteFile implements ResourceOperation {
  /// kind: 'delete'
  String get kind;
  /// uri: string
  String get uri;
  /// optional options: DeleteFileOptions
  DeleteFileOptions? get options;
}

/// interface ChangeAnnotation
abstract class ChangeAnnotation {
  /// label: string
  String get label;
  /// optional needsConfirmation: boolean
  bool? get needsConfirmation;
  /// optional description: string
  String? get description;
}

/// interface FileOperationFilter
abstract class FileOperationFilter {
  /// optional scheme: string
  String? get scheme;
  /// pattern: FileOperationPattern
  FileOperationPattern get pattern;
}

/// interface FileRename
abstract class FileRename {
  /// oldUri: string
  String get oldUri;
  /// newUri: string
  String get newUri;
}

/// interface FileDelete
abstract class FileDelete {
  /// uri: string
  String get uri;
}

/// interface MonikerOptions extends WorkDoneProgressOptions
abstract class MonikerOptions implements WorkDoneProgressOptions {
}

/// interface TypeHierarchyOptions extends WorkDoneProgressOptions
abstract class TypeHierarchyOptions implements WorkDoneProgressOptions {
}

/// interface InlineValueContext
abstract class InlineValueContext {
  /// frameId: number
  num get frameId;
  /// stoppedLocation: Range
  Range get stoppedLocation;
}

/// interface InlineValueText
abstract class InlineValueText {
  /// range: Range
  Range get range;
  /// text: string
  String get text;
}

/// interface InlineValueVariableLookup
abstract class InlineValueVariableLookup {
  /// range: Range
  Range get range;
  /// optional variableName: string
  String? get variableName;
  /// caseSensitiveLookup: boolean
  bool get caseSensitiveLookup;
}

/// interface InlineValueEvaluatableExpression
abstract class InlineValueEvaluatableExpression {
  /// range: Range
  Range get range;
  /// optional expression: string
  String? get expression;
}

/// interface InlineValueOptions extends WorkDoneProgressOptions
abstract class InlineValueOptions implements WorkDoneProgressOptions {
}

/// interface InlayHintLabelPart
abstract class InlayHintLabelPart {
  /// value: string
  String get value;
  /// optional tooltip: string | MarkupContent
  Object? get tooltip;
  /// optional location: Location
  Location? get location;
  /// optional command: Command
  Command? get command;
}

/// interface MarkupContent
abstract class MarkupContent {
  /// kind: MarkupKind
  MarkupKind get kind;
  /// value: string
  String get value;
}

/// interface InlayHintOptions extends WorkDoneProgressOptions
abstract class InlayHintOptions implements WorkDoneProgressOptions {
  /// optional resolveProvider: boolean
  bool? get resolveProvider;
}

/// interface RelatedFullDocumentDiagnosticReport extends FullDocumentDiagnosticReport
abstract class RelatedFullDocumentDiagnosticReport implements FullDocumentDiagnosticReport {
  /// optional relatedDocuments: { [key: string]: FullDocumentDiagnosticReport | UnchangedDocumentDiagnosticReport }
  Map<String, Object?>? get relatedDocuments;
}

/// interface RelatedUnchangedDocumentDiagnosticReport extends UnchangedDocumentDiagnosticReport
abstract class RelatedUnchangedDocumentDiagnosticReport implements UnchangedDocumentDiagnosticReport {
  /// optional relatedDocuments: { [key: string]: FullDocumentDiagnosticReport | UnchangedDocumentDiagnosticReport }
  Map<String, Object?>? get relatedDocuments;
}

/// interface FullDocumentDiagnosticReport
abstract class FullDocumentDiagnosticReport {
  /// kind: 'full'
  String get kind;
  /// optional resultId: string
  String? get resultId;
  /// items: (Diagnostic)[]
  List<Diagnostic> get items;
}

/// interface UnchangedDocumentDiagnosticReport
abstract class UnchangedDocumentDiagnosticReport {
  /// kind: 'unchanged'
  String get kind;
  /// resultId: string
  String get resultId;
}

/// interface DiagnosticOptions extends WorkDoneProgressOptions
abstract class DiagnosticOptions implements WorkDoneProgressOptions {
  /// optional identifier: string
  String? get identifier;
  /// interFileDependencies: boolean
  bool get interFileDependencies;
  /// workspaceDiagnostics: boolean
  bool get workspaceDiagnostics;
}

/// interface PreviousResultId
abstract class PreviousResultId {
  /// uri: string
  String get uri;
  /// value: string
  String get value;
}

/// interface NotebookDocument
abstract class NotebookDocument {
  /// uri: string
  String get uri;
  /// notebookType: string
  String get notebookType;
  /// version: number
  num get version;
  /// optional metadata: LSPObject
  LSPObject? get metadata;
  /// cells: (NotebookCell)[]
  List<NotebookCell> get cells;
}

/// interface TextDocumentItem
abstract class TextDocumentItem {
  /// uri: string
  String get uri;
  /// languageId: string
  String get languageId;
  /// version: number
  num get version;
  /// text: string
  String get text;
}

/// interface VersionedNotebookDocumentIdentifier
abstract class VersionedNotebookDocumentIdentifier {
  /// version: number
  num get version;
  /// uri: string
  String get uri;
}

/// interface NotebookDocumentChangeEvent
abstract class NotebookDocumentChangeEvent {
  /// optional metadata: LSPObject
  LSPObject? get metadata;
  /// optional cells: { structure?: { array: NotebookCellArrayChange; didOpen?: (TextDocumentItem)[]; didClose?: (TextDocumentIdentifier)[] }; data?: (NotebookCell)[]; textContent?: ({ document: VersionedTextDocumentIdentifier; changes: (TextDocumentContentChangeEvent)[] })[] }
  Map<String, Object?>? get cells;
}

/// interface NotebookDocumentIdentifier
abstract class NotebookDocumentIdentifier {
  /// uri: string
  String get uri;
}

/// interface InlineCompletionContext
abstract class InlineCompletionContext {
  /// triggerKind: InlineCompletionTriggerKind
  InlineCompletionTriggerKind get triggerKind;
  /// optional selectedCompletionInfo: SelectedCompletionInfo
  SelectedCompletionInfo? get selectedCompletionInfo;
}

/// interface StringValue
abstract class StringValue {
  /// kind: 'snippet'
  String get kind;
  /// value: string
  String get value;
}

/// interface InlineCompletionOptions extends WorkDoneProgressOptions
abstract class InlineCompletionOptions implements WorkDoneProgressOptions {
}

/// interface Registration
abstract class Registration {
  /// id: string
  String get id;
  /// method: string
  String get method;
  /// optional registerOptions: LSPAny
  LSPAny? get registerOptions;
}

/// interface Unregistration
abstract class Unregistration {
  /// id: string
  String get id;
  /// method: string
  String get method;
}

/// interface _InitializeParams extends WorkDoneProgressParams
abstract class _InitializeParams implements WorkDoneProgressParams {
  /// processId: number | null
  Object? get processId;
  /// optional clientInfo: { name: string; version?: string }
  Map<String, Object?>? get clientInfo;
  /// optional locale: string
  String? get locale;
  /// optional rootPath: string | null
  Object? get rootPath;
  /// rootUri: string | null
  Object? get rootUri;
  /// capabilities: ClientCapabilities
  ClientCapabilities get capabilities;
  /// optional initializationOptions: LSPAny
  LSPAny? get initializationOptions;
  /// optional trace: TraceValues
  TraceValues? get trace;
}

/// interface WorkspaceFoldersInitializeParams
abstract class WorkspaceFoldersInitializeParams {
  /// optional workspaceFolders: (WorkspaceFolder)[] | null
  Object? get workspaceFolders;
}

/// interface ServerCapabilities
abstract class ServerCapabilities {
  /// optional positionEncoding: PositionEncodingKind
  PositionEncodingKind? get positionEncoding;
  /// optional textDocumentSync: TextDocumentSyncOptions | TextDocumentSyncKind
  Object? get textDocumentSync;
  /// optional notebookDocumentSync: NotebookDocumentSyncOptions | NotebookDocumentSyncRegistrationOptions
  Object? get notebookDocumentSync;
  /// optional completionProvider: CompletionOptions
  CompletionOptions? get completionProvider;
  /// optional hoverProvider: boolean | HoverOptions
  Object? get hoverProvider;
  /// optional signatureHelpProvider: SignatureHelpOptions
  SignatureHelpOptions? get signatureHelpProvider;
  /// optional declarationProvider: boolean | DeclarationOptions | DeclarationRegistrationOptions
  Object? get declarationProvider;
  /// optional definitionProvider: boolean | DefinitionOptions
  Object? get definitionProvider;
  /// optional typeDefinitionProvider: boolean | TypeDefinitionOptions | TypeDefinitionRegistrationOptions
  Object? get typeDefinitionProvider;
  /// optional implementationProvider: boolean | ImplementationOptions | ImplementationRegistrationOptions
  Object? get implementationProvider;
  /// optional referencesProvider: boolean | ReferenceOptions
  Object? get referencesProvider;
  /// optional documentHighlightProvider: boolean | DocumentHighlightOptions
  Object? get documentHighlightProvider;
  /// optional documentSymbolProvider: boolean | DocumentSymbolOptions
  Object? get documentSymbolProvider;
  /// optional codeActionProvider: boolean | CodeActionOptions
  Object? get codeActionProvider;
  /// optional codeLensProvider: CodeLensOptions
  CodeLensOptions? get codeLensProvider;
  /// optional documentLinkProvider: DocumentLinkOptions
  DocumentLinkOptions? get documentLinkProvider;
  /// optional colorProvider: boolean | DocumentColorOptions | DocumentColorRegistrationOptions
  Object? get colorProvider;
  /// optional workspaceSymbolProvider: boolean | WorkspaceSymbolOptions
  Object? get workspaceSymbolProvider;
  /// optional documentFormattingProvider: boolean | DocumentFormattingOptions
  Object? get documentFormattingProvider;
  /// optional documentRangeFormattingProvider: boolean | DocumentRangeFormattingOptions
  Object? get documentRangeFormattingProvider;
  /// optional documentOnTypeFormattingProvider: DocumentOnTypeFormattingOptions
  DocumentOnTypeFormattingOptions? get documentOnTypeFormattingProvider;
  /// optional renameProvider: boolean | RenameOptions
  Object? get renameProvider;
  /// optional foldingRangeProvider: boolean | FoldingRangeOptions | FoldingRangeRegistrationOptions
  Object? get foldingRangeProvider;
  /// optional selectionRangeProvider: boolean | SelectionRangeOptions | SelectionRangeRegistrationOptions
  Object? get selectionRangeProvider;
  /// optional executeCommandProvider: ExecuteCommandOptions
  ExecuteCommandOptions? get executeCommandProvider;
  /// optional callHierarchyProvider: boolean | CallHierarchyOptions | CallHierarchyRegistrationOptions
  Object? get callHierarchyProvider;
  /// optional linkedEditingRangeProvider: boolean | LinkedEditingRangeOptions | LinkedEditingRangeRegistrationOptions
  Object? get linkedEditingRangeProvider;
  /// optional semanticTokensProvider: SemanticTokensOptions | SemanticTokensRegistrationOptions
  Object? get semanticTokensProvider;
  /// optional monikerProvider: boolean | MonikerOptions | MonikerRegistrationOptions
  Object? get monikerProvider;
  /// optional typeHierarchyProvider: boolean | TypeHierarchyOptions | TypeHierarchyRegistrationOptions
  Object? get typeHierarchyProvider;
  /// optional inlineValueProvider: boolean | InlineValueOptions | InlineValueRegistrationOptions
  Object? get inlineValueProvider;
  /// optional inlayHintProvider: boolean | InlayHintOptions | InlayHintRegistrationOptions
  Object? get inlayHintProvider;
  /// optional diagnosticProvider: DiagnosticOptions | DiagnosticRegistrationOptions
  Object? get diagnosticProvider;
  /// optional inlineCompletionProvider: boolean | InlineCompletionOptions
  Object? get inlineCompletionProvider;
  /// optional workspace: { workspaceFolders?: WorkspaceFoldersServerCapabilities; fileOperations?: FileOperationOptions }
  Map<String, Object?>? get workspace;
  /// optional experimental: LSPAny
  LSPAny? get experimental;
}

/// interface VersionedTextDocumentIdentifier extends TextDocumentIdentifier
abstract class VersionedTextDocumentIdentifier implements TextDocumentIdentifier {
  /// version: number
  num get version;
}

/// interface SaveOptions
abstract class SaveOptions {
  /// optional includeText: boolean
  bool? get includeText;
}

/// interface FileEvent
abstract class FileEvent {
  /// uri: string
  String get uri;
  /// type: FileChangeType
  FileChangeType get type;
}

/// interface FileSystemWatcher
abstract class FileSystemWatcher {
  /// globPattern: GlobPattern
  GlobPattern get globPattern;
  /// optional kind: WatchKind
  WatchKind? get kind;
}

/// interface Diagnostic
abstract class Diagnostic {
  /// range: Range
  Range get range;
  /// optional severity: DiagnosticSeverity
  DiagnosticSeverity? get severity;
  /// optional code: number | string
  Object? get code;
  /// optional codeDescription: CodeDescription
  CodeDescription? get codeDescription;
  /// optional source: string
  String? get source;
  /// message: string
  String get message;
  /// optional tags: (DiagnosticTag)[]
  List<DiagnosticTag>? get tags;
  /// optional relatedInformation: (DiagnosticRelatedInformation)[]
  List<DiagnosticRelatedInformation>? get relatedInformation;
  /// optional data: LSPAny
  LSPAny? get data;
}

/// interface CompletionContext
abstract class CompletionContext {
  /// triggerKind: CompletionTriggerKind
  CompletionTriggerKind get triggerKind;
  /// optional triggerCharacter: string
  String? get triggerCharacter;
}

/// interface CompletionItemLabelDetails
abstract class CompletionItemLabelDetails {
  /// optional detail: string
  String? get detail;
  /// optional description: string
  String? get description;
}

/// interface InsertReplaceEdit
abstract class InsertReplaceEdit {
  /// newText: string
  String get newText;
  /// insert: Range
  Range get insert;
  /// replace: Range
  Range get replace;
}

/// interface CompletionOptions extends WorkDoneProgressOptions
abstract class CompletionOptions implements WorkDoneProgressOptions {
  /// optional triggerCharacters: (string)[]
  List<String>? get triggerCharacters;
  /// optional allCommitCharacters: (string)[]
  List<String>? get allCommitCharacters;
  /// optional resolveProvider: boolean
  bool? get resolveProvider;
  /// optional completionItem: { labelDetailsSupport?: boolean }
  Map<String, Object?>? get completionItem;
}

/// interface HoverOptions extends WorkDoneProgressOptions
abstract class HoverOptions implements WorkDoneProgressOptions {
}

/// interface SignatureHelpContext
abstract class SignatureHelpContext {
  /// triggerKind: SignatureHelpTriggerKind
  SignatureHelpTriggerKind get triggerKind;
  /// optional triggerCharacter: string
  String? get triggerCharacter;
  /// isRetrigger: boolean
  bool get isRetrigger;
  /// optional activeSignatureHelp: SignatureHelp
  SignatureHelp? get activeSignatureHelp;
}

/// interface SignatureInformation
abstract class SignatureInformation {
  /// label: string
  String get label;
  /// optional documentation: string | MarkupContent
  Object? get documentation;
  /// optional parameters: (ParameterInformation)[]
  List<ParameterInformation>? get parameters;
  /// optional activeParameter: number
  num? get activeParameter;
}

/// interface SignatureHelpOptions extends WorkDoneProgressOptions
abstract class SignatureHelpOptions implements WorkDoneProgressOptions {
  /// optional triggerCharacters: (string)[]
  List<String>? get triggerCharacters;
  /// optional retriggerCharacters: (string)[]
  List<String>? get retriggerCharacters;
}

/// interface DefinitionOptions extends WorkDoneProgressOptions
abstract class DefinitionOptions implements WorkDoneProgressOptions {
}

/// interface ReferenceContext
abstract class ReferenceContext {
  /// includeDeclaration: boolean
  bool get includeDeclaration;
}

/// interface ReferenceOptions extends WorkDoneProgressOptions
abstract class ReferenceOptions implements WorkDoneProgressOptions {
}

/// interface DocumentHighlightOptions extends WorkDoneProgressOptions
abstract class DocumentHighlightOptions implements WorkDoneProgressOptions {
}

/// interface BaseSymbolInformation
abstract class BaseSymbolInformation {
  /// name: string
  String get name;
  /// kind: SymbolKind
  SymbolKind get kind;
  /// optional tags: (SymbolTag)[]
  List<SymbolTag>? get tags;
  /// optional containerName: string
  String? get containerName;
}

/// interface DocumentSymbolOptions extends WorkDoneProgressOptions
abstract class DocumentSymbolOptions implements WorkDoneProgressOptions {
  /// optional label: string
  String? get label;
}

/// interface CodeActionContext
abstract class CodeActionContext {
  /// diagnostics: (Diagnostic)[]
  List<Diagnostic> get diagnostics;
  /// optional only: (CodeActionKind)[]
  List<CodeActionKind>? get only;
  /// optional triggerKind: CodeActionTriggerKind
  CodeActionTriggerKind? get triggerKind;
}

/// interface CodeActionOptions extends WorkDoneProgressOptions
abstract class CodeActionOptions implements WorkDoneProgressOptions {
  /// optional codeActionKinds: (CodeActionKind)[]
  List<CodeActionKind>? get codeActionKinds;
  /// optional resolveProvider: boolean
  bool? get resolveProvider;
}

/// interface WorkspaceSymbolOptions extends WorkDoneProgressOptions
abstract class WorkspaceSymbolOptions implements WorkDoneProgressOptions {
  /// optional resolveProvider: boolean
  bool? get resolveProvider;
}

/// interface CodeLensOptions extends WorkDoneProgressOptions
abstract class CodeLensOptions implements WorkDoneProgressOptions {
  /// optional resolveProvider: boolean
  bool? get resolveProvider;
}

/// interface DocumentLinkOptions extends WorkDoneProgressOptions
abstract class DocumentLinkOptions implements WorkDoneProgressOptions {
  /// optional resolveProvider: boolean
  bool? get resolveProvider;
}

/// interface FormattingOptions
abstract class FormattingOptions {
  /// tabSize: number
  num get tabSize;
  /// insertSpaces: boolean
  bool get insertSpaces;
  /// optional trimTrailingWhitespace: boolean
  bool? get trimTrailingWhitespace;
  /// optional insertFinalNewline: boolean
  bool? get insertFinalNewline;
  /// optional trimFinalNewlines: boolean
  bool? get trimFinalNewlines;
}

/// interface DocumentFormattingOptions extends WorkDoneProgressOptions
abstract class DocumentFormattingOptions implements WorkDoneProgressOptions {
}

/// interface DocumentRangeFormattingOptions extends WorkDoneProgressOptions
abstract class DocumentRangeFormattingOptions implements WorkDoneProgressOptions {
  /// optional rangesSupport: boolean
  bool? get rangesSupport;
}

/// interface DocumentOnTypeFormattingOptions
abstract class DocumentOnTypeFormattingOptions {
  /// firstTriggerCharacter: string
  String get firstTriggerCharacter;
  /// optional moreTriggerCharacter: (string)[]
  List<String>? get moreTriggerCharacter;
}

/// interface RenameOptions extends WorkDoneProgressOptions
abstract class RenameOptions implements WorkDoneProgressOptions {
  /// optional prepareProvider: boolean
  bool? get prepareProvider;
}

/// interface ExecuteCommandOptions extends WorkDoneProgressOptions
abstract class ExecuteCommandOptions implements WorkDoneProgressOptions {
  /// commands: (string)[]
  List<String> get commands;
}

/// interface SemanticTokensLegend
abstract class SemanticTokensLegend {
  /// tokenTypes: (string)[]
  List<String> get tokenTypes;
  /// tokenModifiers: (string)[]
  List<String> get tokenModifiers;
}

/// interface OptionalVersionedTextDocumentIdentifier extends TextDocumentIdentifier
abstract class OptionalVersionedTextDocumentIdentifier implements TextDocumentIdentifier {
  /// version: number | null
  Object? get version;
}

/// interface AnnotatedTextEdit extends TextEdit
abstract class AnnotatedTextEdit implements TextEdit {
  /// annotationId: ChangeAnnotationIdentifier
  ChangeAnnotationIdentifier get annotationId;
}

/// interface ResourceOperation
abstract class ResourceOperation {
  /// kind: string
  String get kind;
  /// optional annotationId: ChangeAnnotationIdentifier
  ChangeAnnotationIdentifier? get annotationId;
}

/// interface CreateFileOptions
abstract class CreateFileOptions {
  /// optional overwrite: boolean
  bool? get overwrite;
  /// optional ignoreIfExists: boolean
  bool? get ignoreIfExists;
}

/// interface RenameFileOptions
abstract class RenameFileOptions {
  /// optional overwrite: boolean
  bool? get overwrite;
  /// optional ignoreIfExists: boolean
  bool? get ignoreIfExists;
}

/// interface DeleteFileOptions
abstract class DeleteFileOptions {
  /// optional recursive: boolean
  bool? get recursive;
  /// optional ignoreIfNotExists: boolean
  bool? get ignoreIfNotExists;
}

/// interface FileOperationPattern
abstract class FileOperationPattern {
  /// glob: string
  String get glob;
  /// optional matches: FileOperationPatternKind
  FileOperationPatternKind? get matches;
  /// optional options: FileOperationPatternOptions
  FileOperationPatternOptions? get options;
}

/// interface WorkspaceFullDocumentDiagnosticReport extends FullDocumentDiagnosticReport
abstract class WorkspaceFullDocumentDiagnosticReport implements FullDocumentDiagnosticReport {
  /// uri: string
  String get uri;
  /// version: number | null
  Object? get version;
}

/// interface WorkspaceUnchangedDocumentDiagnosticReport extends UnchangedDocumentDiagnosticReport
abstract class WorkspaceUnchangedDocumentDiagnosticReport implements UnchangedDocumentDiagnosticReport {
  /// uri: string
  String get uri;
  /// version: number | null
  Object? get version;
}

/// interface NotebookCell
abstract class NotebookCell {
  /// kind: NotebookCellKind
  NotebookCellKind get kind;
  /// document: string
  String get document;
  /// optional metadata: LSPObject
  LSPObject? get metadata;
  /// optional executionSummary: ExecutionSummary
  ExecutionSummary? get executionSummary;
}

/// interface NotebookCellArrayChange
abstract class NotebookCellArrayChange {
  /// start: number
  num get start;
  /// deleteCount: number
  num get deleteCount;
  /// optional cells: (NotebookCell)[]
  List<NotebookCell>? get cells;
}

/// interface SelectedCompletionInfo
abstract class SelectedCompletionInfo {
  /// range: Range
  Range get range;
  /// text: string
  String get text;
}

/// interface ClientCapabilities
abstract class ClientCapabilities {
  /// optional workspace: WorkspaceClientCapabilities
  WorkspaceClientCapabilities? get workspace;
  /// optional textDocument: TextDocumentClientCapabilities
  TextDocumentClientCapabilities? get textDocument;
  /// optional notebookDocument: NotebookDocumentClientCapabilities
  NotebookDocumentClientCapabilities? get notebookDocument;
  /// optional window: WindowClientCapabilities
  WindowClientCapabilities? get window;
  /// optional general: GeneralClientCapabilities
  GeneralClientCapabilities? get general;
  /// optional experimental: LSPAny
  LSPAny? get experimental;
}

/// interface TextDocumentSyncOptions
abstract class TextDocumentSyncOptions {
  /// optional openClose: boolean
  bool? get openClose;
  /// optional change: TextDocumentSyncKind
  TextDocumentSyncKind? get change;
  /// optional willSave: boolean
  bool? get willSave;
  /// optional willSaveWaitUntil: boolean
  bool? get willSaveWaitUntil;
  /// optional save: boolean | SaveOptions
  Object? get save;
}

/// interface NotebookDocumentSyncOptions
abstract class NotebookDocumentSyncOptions {
  /// notebookSelector: ({ notebook: string | NotebookDocumentFilter; cells?: ({ language: string })[] } | { notebook?: string | NotebookDocumentFilter; cells: ({ language: string })[] })[]
  List<Object?> get notebookSelector;
  /// optional save: boolean
  bool? get save;
}

/// interface NotebookDocumentSyncRegistrationOptions extends NotebookDocumentSyncOptions, StaticRegistrationOptions
abstract class NotebookDocumentSyncRegistrationOptions implements NotebookDocumentSyncOptions, StaticRegistrationOptions {
}

/// interface WorkspaceFoldersServerCapabilities
abstract class WorkspaceFoldersServerCapabilities {
  /// optional supported: boolean
  bool? get supported;
  /// optional changeNotifications: string | boolean
  Object? get changeNotifications;
}

/// interface FileOperationOptions
abstract class FileOperationOptions {
  /// optional didCreate: FileOperationRegistrationOptions
  FileOperationRegistrationOptions? get didCreate;
  /// optional willCreate: FileOperationRegistrationOptions
  FileOperationRegistrationOptions? get willCreate;
  /// optional didRename: FileOperationRegistrationOptions
  FileOperationRegistrationOptions? get didRename;
  /// optional willRename: FileOperationRegistrationOptions
  FileOperationRegistrationOptions? get willRename;
  /// optional didDelete: FileOperationRegistrationOptions
  FileOperationRegistrationOptions? get didDelete;
  /// optional willDelete: FileOperationRegistrationOptions
  FileOperationRegistrationOptions? get willDelete;
}

/// interface CodeDescription
abstract class CodeDescription {
  /// href: string
  String get href;
}

/// interface DiagnosticRelatedInformation
abstract class DiagnosticRelatedInformation {
  /// location: Location
  Location get location;
  /// message: string
  String get message;
}

/// interface ParameterInformation
abstract class ParameterInformation {
  /// label: string | [number, number]
  Object? get label;
  /// optional documentation: string | MarkupContent
  Object? get documentation;
}

/// interface NotebookCellTextDocumentFilter
abstract class NotebookCellTextDocumentFilter {
  /// notebook: string | NotebookDocumentFilter
  Object? get notebook;
  /// optional language: string
  String? get language;
}

/// interface FileOperationPatternOptions
abstract class FileOperationPatternOptions {
  /// optional ignoreCase: boolean
  bool? get ignoreCase;
}

/// interface ExecutionSummary
abstract class ExecutionSummary {
  /// executionOrder: number
  num get executionOrder;
  /// optional success: boolean
  bool? get success;
}

/// interface WorkspaceClientCapabilities
abstract class WorkspaceClientCapabilities {
  /// optional applyEdit: boolean
  bool? get applyEdit;
  /// optional workspaceEdit: WorkspaceEditClientCapabilities
  WorkspaceEditClientCapabilities? get workspaceEdit;
  /// optional didChangeConfiguration: DidChangeConfigurationClientCapabilities
  DidChangeConfigurationClientCapabilities? get didChangeConfiguration;
  /// optional didChangeWatchedFiles: DidChangeWatchedFilesClientCapabilities
  DidChangeWatchedFilesClientCapabilities? get didChangeWatchedFiles;
  /// optional symbol: WorkspaceSymbolClientCapabilities
  WorkspaceSymbolClientCapabilities? get symbol;
  /// optional executeCommand: ExecuteCommandClientCapabilities
  ExecuteCommandClientCapabilities? get executeCommand;
  /// optional workspaceFolders: boolean
  bool? get workspaceFolders;
  /// optional configuration: boolean
  bool? get configuration;
  /// optional semanticTokens: SemanticTokensWorkspaceClientCapabilities
  SemanticTokensWorkspaceClientCapabilities? get semanticTokens;
  /// optional codeLens: CodeLensWorkspaceClientCapabilities
  CodeLensWorkspaceClientCapabilities? get codeLens;
  /// optional fileOperations: FileOperationClientCapabilities
  FileOperationClientCapabilities? get fileOperations;
  /// optional inlineValue: InlineValueWorkspaceClientCapabilities
  InlineValueWorkspaceClientCapabilities? get inlineValue;
  /// optional inlayHint: InlayHintWorkspaceClientCapabilities
  InlayHintWorkspaceClientCapabilities? get inlayHint;
  /// optional diagnostics: DiagnosticWorkspaceClientCapabilities
  DiagnosticWorkspaceClientCapabilities? get diagnostics;
  /// optional foldingRange: FoldingRangeWorkspaceClientCapabilities
  FoldingRangeWorkspaceClientCapabilities? get foldingRange;
}

/// interface TextDocumentClientCapabilities
abstract class TextDocumentClientCapabilities {
  /// optional synchronization: TextDocumentSyncClientCapabilities
  TextDocumentSyncClientCapabilities? get synchronization;
  /// optional completion: CompletionClientCapabilities
  CompletionClientCapabilities? get completion;
  /// optional hover: HoverClientCapabilities
  HoverClientCapabilities? get hover;
  /// optional signatureHelp: SignatureHelpClientCapabilities
  SignatureHelpClientCapabilities? get signatureHelp;
  /// optional declaration: DeclarationClientCapabilities
  DeclarationClientCapabilities? get declaration;
  /// optional definition: DefinitionClientCapabilities
  DefinitionClientCapabilities? get definition;
  /// optional typeDefinition: TypeDefinitionClientCapabilities
  TypeDefinitionClientCapabilities? get typeDefinition;
  /// optional implementation: ImplementationClientCapabilities
  ImplementationClientCapabilities? get implementation;
  /// optional references: ReferenceClientCapabilities
  ReferenceClientCapabilities? get references;
  /// optional documentHighlight: DocumentHighlightClientCapabilities
  DocumentHighlightClientCapabilities? get documentHighlight;
  /// optional documentSymbol: DocumentSymbolClientCapabilities
  DocumentSymbolClientCapabilities? get documentSymbol;
  /// optional codeAction: CodeActionClientCapabilities
  CodeActionClientCapabilities? get codeAction;
  /// optional codeLens: CodeLensClientCapabilities
  CodeLensClientCapabilities? get codeLens;
  /// optional documentLink: DocumentLinkClientCapabilities
  DocumentLinkClientCapabilities? get documentLink;
  /// optional colorProvider: DocumentColorClientCapabilities
  DocumentColorClientCapabilities? get colorProvider;
  /// optional formatting: DocumentFormattingClientCapabilities
  DocumentFormattingClientCapabilities? get formatting;
  /// optional rangeFormatting: DocumentRangeFormattingClientCapabilities
  DocumentRangeFormattingClientCapabilities? get rangeFormatting;
  /// optional onTypeFormatting: DocumentOnTypeFormattingClientCapabilities
  DocumentOnTypeFormattingClientCapabilities? get onTypeFormatting;
  /// optional rename: RenameClientCapabilities
  RenameClientCapabilities? get rename;
  /// optional foldingRange: FoldingRangeClientCapabilities
  FoldingRangeClientCapabilities? get foldingRange;
  /// optional selectionRange: SelectionRangeClientCapabilities
  SelectionRangeClientCapabilities? get selectionRange;
  /// optional publishDiagnostics: PublishDiagnosticsClientCapabilities
  PublishDiagnosticsClientCapabilities? get publishDiagnostics;
  /// optional callHierarchy: CallHierarchyClientCapabilities
  CallHierarchyClientCapabilities? get callHierarchy;
  /// optional semanticTokens: SemanticTokensClientCapabilities
  SemanticTokensClientCapabilities? get semanticTokens;
  /// optional linkedEditingRange: LinkedEditingRangeClientCapabilities
  LinkedEditingRangeClientCapabilities? get linkedEditingRange;
  /// optional moniker: MonikerClientCapabilities
  MonikerClientCapabilities? get moniker;
  /// optional typeHierarchy: TypeHierarchyClientCapabilities
  TypeHierarchyClientCapabilities? get typeHierarchy;
  /// optional inlineValue: InlineValueClientCapabilities
  InlineValueClientCapabilities? get inlineValue;
  /// optional inlayHint: InlayHintClientCapabilities
  InlayHintClientCapabilities? get inlayHint;
  /// optional diagnostic: DiagnosticClientCapabilities
  DiagnosticClientCapabilities? get diagnostic;
  /// optional inlineCompletion: InlineCompletionClientCapabilities
  InlineCompletionClientCapabilities? get inlineCompletion;
}

/// interface NotebookDocumentClientCapabilities
abstract class NotebookDocumentClientCapabilities {
  /// synchronization: NotebookDocumentSyncClientCapabilities
  NotebookDocumentSyncClientCapabilities get synchronization;
}

/// interface WindowClientCapabilities
abstract class WindowClientCapabilities {
  /// optional workDoneProgress: boolean
  bool? get workDoneProgress;
  /// optional showMessage: ShowMessageRequestClientCapabilities
  ShowMessageRequestClientCapabilities? get showMessage;
  /// optional showDocument: ShowDocumentClientCapabilities
  ShowDocumentClientCapabilities? get showDocument;
}

/// interface GeneralClientCapabilities
abstract class GeneralClientCapabilities {
  /// optional staleRequestSupport: { cancel: boolean; retryOnContentModified: (string)[] }
  Map<String, Object?>? get staleRequestSupport;
  /// optional regularExpressions: RegularExpressionsClientCapabilities
  RegularExpressionsClientCapabilities? get regularExpressions;
  /// optional markdown: MarkdownClientCapabilities
  MarkdownClientCapabilities? get markdown;
  /// optional positionEncodings: (PositionEncodingKind)[]
  List<PositionEncodingKind>? get positionEncodings;
}

/// interface RelativePattern
abstract class RelativePattern {
  /// baseUri: WorkspaceFolder | string
  Object? get baseUri;
  /// pattern: Pattern
  Pattern get pattern;
}

/// interface WorkspaceEditClientCapabilities
abstract class WorkspaceEditClientCapabilities {
  /// optional documentChanges: boolean
  bool? get documentChanges;
  /// optional resourceOperations: (ResourceOperationKind)[]
  List<ResourceOperationKind>? get resourceOperations;
  /// optional failureHandling: FailureHandlingKind
  FailureHandlingKind? get failureHandling;
  /// optional normalizesLineEndings: boolean
  bool? get normalizesLineEndings;
  /// optional changeAnnotationSupport: { groupsOnLabel?: boolean }
  Map<String, Object?>? get changeAnnotationSupport;
}

/// interface DidChangeConfigurationClientCapabilities
abstract class DidChangeConfigurationClientCapabilities {
  /// optional dynamicRegistration: boolean
  bool? get dynamicRegistration;
}

/// interface DidChangeWatchedFilesClientCapabilities
abstract class DidChangeWatchedFilesClientCapabilities {
  /// optional dynamicRegistration: boolean
  bool? get dynamicRegistration;
  /// optional relativePatternSupport: boolean
  bool? get relativePatternSupport;
}

/// interface WorkspaceSymbolClientCapabilities
abstract class WorkspaceSymbolClientCapabilities {
  /// optional dynamicRegistration: boolean
  bool? get dynamicRegistration;
  /// optional symbolKind: { valueSet?: (SymbolKind)[] }
  Map<String, Object?>? get symbolKind;
  /// optional tagSupport: { valueSet: (SymbolTag)[] }
  Map<String, Object?>? get tagSupport;
  /// optional resolveSupport: { properties: (string)[] }
  Map<String, Object?>? get resolveSupport;
}

/// interface ExecuteCommandClientCapabilities
abstract class ExecuteCommandClientCapabilities {
  /// optional dynamicRegistration: boolean
  bool? get dynamicRegistration;
}

/// interface SemanticTokensWorkspaceClientCapabilities
abstract class SemanticTokensWorkspaceClientCapabilities {
  /// optional refreshSupport: boolean
  bool? get refreshSupport;
}

/// interface CodeLensWorkspaceClientCapabilities
abstract class CodeLensWorkspaceClientCapabilities {
  /// optional refreshSupport: boolean
  bool? get refreshSupport;
}

/// interface FileOperationClientCapabilities
abstract class FileOperationClientCapabilities {
  /// optional dynamicRegistration: boolean
  bool? get dynamicRegistration;
  /// optional didCreate: boolean
  bool? get didCreate;
  /// optional willCreate: boolean
  bool? get willCreate;
  /// optional didRename: boolean
  bool? get didRename;
  /// optional willRename: boolean
  bool? get willRename;
  /// optional didDelete: boolean
  bool? get didDelete;
  /// optional willDelete: boolean
  bool? get willDelete;
}

/// interface InlineValueWorkspaceClientCapabilities
abstract class InlineValueWorkspaceClientCapabilities {
  /// optional refreshSupport: boolean
  bool? get refreshSupport;
}

/// interface InlayHintWorkspaceClientCapabilities
abstract class InlayHintWorkspaceClientCapabilities {
  /// optional refreshSupport: boolean
  bool? get refreshSupport;
}

/// interface DiagnosticWorkspaceClientCapabilities
abstract class DiagnosticWorkspaceClientCapabilities {
  /// optional refreshSupport: boolean
  bool? get refreshSupport;
}

/// interface FoldingRangeWorkspaceClientCapabilities
abstract class FoldingRangeWorkspaceClientCapabilities {
  /// optional refreshSupport: boolean
  bool? get refreshSupport;
}

/// interface TextDocumentSyncClientCapabilities
abstract class TextDocumentSyncClientCapabilities {
  /// optional dynamicRegistration: boolean
  bool? get dynamicRegistration;
  /// optional willSave: boolean
  bool? get willSave;
  /// optional willSaveWaitUntil: boolean
  bool? get willSaveWaitUntil;
  /// optional didSave: boolean
  bool? get didSave;
}

/// interface CompletionClientCapabilities
abstract class CompletionClientCapabilities {
  /// optional dynamicRegistration: boolean
  bool? get dynamicRegistration;
  /// optional completionItem: { snippetSupport?: boolean; commitCharactersSupport?: boolean; documentationFormat?: (MarkupKind)[]; deprecatedSupport?: boolean; preselectSupport?: boolean; tagSupport?: { valueSet: (CompletionItemTag)[] }; insertReplaceSupport?: boolean; resolveSupport?: { properties: (string)[] }; insertTextModeSupport?: { valueSet: (InsertTextMode)[] }; labelDetailsSupport?: boolean }
  Map<String, Object?>? get completionItem;
  /// optional completionItemKind: { valueSet?: (CompletionItemKind)[] }
  Map<String, Object?>? get completionItemKind;
  /// optional insertTextMode: InsertTextMode
  InsertTextMode? get insertTextMode;
  /// optional contextSupport: boolean
  bool? get contextSupport;
  /// optional completionList: { itemDefaults?: (string)[] }
  Map<String, Object?>? get completionList;
}

/// interface HoverClientCapabilities
abstract class HoverClientCapabilities {
  /// optional dynamicRegistration: boolean
  bool? get dynamicRegistration;
  /// optional contentFormat: (MarkupKind)[]
  List<MarkupKind>? get contentFormat;
}

/// interface SignatureHelpClientCapabilities
abstract class SignatureHelpClientCapabilities {
  /// optional dynamicRegistration: boolean
  bool? get dynamicRegistration;
  /// optional signatureInformation: { documentationFormat?: (MarkupKind)[]; parameterInformation?: { labelOffsetSupport?: boolean }; activeParameterSupport?: boolean }
  Map<String, Object?>? get signatureInformation;
  /// optional contextSupport: boolean
  bool? get contextSupport;
}

/// interface DeclarationClientCapabilities
abstract class DeclarationClientCapabilities {
  /// optional dynamicRegistration: boolean
  bool? get dynamicRegistration;
  /// optional linkSupport: boolean
  bool? get linkSupport;
}

/// interface DefinitionClientCapabilities
abstract class DefinitionClientCapabilities {
  /// optional dynamicRegistration: boolean
  bool? get dynamicRegistration;
  /// optional linkSupport: boolean
  bool? get linkSupport;
}

/// interface TypeDefinitionClientCapabilities
abstract class TypeDefinitionClientCapabilities {
  /// optional dynamicRegistration: boolean
  bool? get dynamicRegistration;
  /// optional linkSupport: boolean
  bool? get linkSupport;
}

/// interface ImplementationClientCapabilities
abstract class ImplementationClientCapabilities {
  /// optional dynamicRegistration: boolean
  bool? get dynamicRegistration;
  /// optional linkSupport: boolean
  bool? get linkSupport;
}

/// interface ReferenceClientCapabilities
abstract class ReferenceClientCapabilities {
  /// optional dynamicRegistration: boolean
  bool? get dynamicRegistration;
}

/// interface DocumentHighlightClientCapabilities
abstract class DocumentHighlightClientCapabilities {
  /// optional dynamicRegistration: boolean
  bool? get dynamicRegistration;
}

/// interface DocumentSymbolClientCapabilities
abstract class DocumentSymbolClientCapabilities {
  /// optional dynamicRegistration: boolean
  bool? get dynamicRegistration;
  /// optional symbolKind: { valueSet?: (SymbolKind)[] }
  Map<String, Object?>? get symbolKind;
  /// optional hierarchicalDocumentSymbolSupport: boolean
  bool? get hierarchicalDocumentSymbolSupport;
  /// optional tagSupport: { valueSet: (SymbolTag)[] }
  Map<String, Object?>? get tagSupport;
  /// optional labelSupport: boolean
  bool? get labelSupport;
}

/// interface CodeActionClientCapabilities
abstract class CodeActionClientCapabilities {
  /// optional dynamicRegistration: boolean
  bool? get dynamicRegistration;
  /// optional codeActionLiteralSupport: { codeActionKind: { valueSet: (CodeActionKind)[] } }
  Map<String, Object?>? get codeActionLiteralSupport;
  /// optional isPreferredSupport: boolean
  bool? get isPreferredSupport;
  /// optional disabledSupport: boolean
  bool? get disabledSupport;
  /// optional dataSupport: boolean
  bool? get dataSupport;
  /// optional resolveSupport: { properties: (string)[] }
  Map<String, Object?>? get resolveSupport;
  /// optional honorsChangeAnnotations: boolean
  bool? get honorsChangeAnnotations;
}

/// interface CodeLensClientCapabilities
abstract class CodeLensClientCapabilities {
  /// optional dynamicRegistration: boolean
  bool? get dynamicRegistration;
}

/// interface DocumentLinkClientCapabilities
abstract class DocumentLinkClientCapabilities {
  /// optional dynamicRegistration: boolean
  bool? get dynamicRegistration;
  /// optional tooltipSupport: boolean
  bool? get tooltipSupport;
}

/// interface DocumentColorClientCapabilities
abstract class DocumentColorClientCapabilities {
  /// optional dynamicRegistration: boolean
  bool? get dynamicRegistration;
}

/// interface DocumentFormattingClientCapabilities
abstract class DocumentFormattingClientCapabilities {
  /// optional dynamicRegistration: boolean
  bool? get dynamicRegistration;
}

/// interface DocumentRangeFormattingClientCapabilities
abstract class DocumentRangeFormattingClientCapabilities {
  /// optional dynamicRegistration: boolean
  bool? get dynamicRegistration;
  /// optional rangesSupport: boolean
  bool? get rangesSupport;
}

/// interface DocumentOnTypeFormattingClientCapabilities
abstract class DocumentOnTypeFormattingClientCapabilities {
  /// optional dynamicRegistration: boolean
  bool? get dynamicRegistration;
}

/// interface RenameClientCapabilities
abstract class RenameClientCapabilities {
  /// optional dynamicRegistration: boolean
  bool? get dynamicRegistration;
  /// optional prepareSupport: boolean
  bool? get prepareSupport;
  /// optional prepareSupportDefaultBehavior: PrepareSupportDefaultBehavior
  PrepareSupportDefaultBehavior? get prepareSupportDefaultBehavior;
  /// optional honorsChangeAnnotations: boolean
  bool? get honorsChangeAnnotations;
}

/// interface FoldingRangeClientCapabilities
abstract class FoldingRangeClientCapabilities {
  /// optional dynamicRegistration: boolean
  bool? get dynamicRegistration;
  /// optional rangeLimit: number
  num? get rangeLimit;
  /// optional lineFoldingOnly: boolean
  bool? get lineFoldingOnly;
  /// optional foldingRangeKind: { valueSet?: (FoldingRangeKind)[] }
  Map<String, Object?>? get foldingRangeKind;
  /// optional foldingRange: { collapsedText?: boolean }
  Map<String, Object?>? get foldingRange;
}

/// interface SelectionRangeClientCapabilities
abstract class SelectionRangeClientCapabilities {
  /// optional dynamicRegistration: boolean
  bool? get dynamicRegistration;
}

/// interface PublishDiagnosticsClientCapabilities
abstract class PublishDiagnosticsClientCapabilities {
  /// optional relatedInformation: boolean
  bool? get relatedInformation;
  /// optional tagSupport: { valueSet: (DiagnosticTag)[] }
  Map<String, Object?>? get tagSupport;
  /// optional versionSupport: boolean
  bool? get versionSupport;
  /// optional codeDescriptionSupport: boolean
  bool? get codeDescriptionSupport;
  /// optional dataSupport: boolean
  bool? get dataSupport;
}

/// interface CallHierarchyClientCapabilities
abstract class CallHierarchyClientCapabilities {
  /// optional dynamicRegistration: boolean
  bool? get dynamicRegistration;
}

/// interface SemanticTokensClientCapabilities
abstract class SemanticTokensClientCapabilities {
  /// optional dynamicRegistration: boolean
  bool? get dynamicRegistration;
  /// requests: { range?: boolean | { }; full?: boolean | { delta?: boolean } }
  Map<String, Object?> get requests;
  /// tokenTypes: (string)[]
  List<String> get tokenTypes;
  /// tokenModifiers: (string)[]
  List<String> get tokenModifiers;
  /// formats: (TokenFormat)[]
  List<TokenFormat> get formats;
  /// optional overlappingTokenSupport: boolean
  bool? get overlappingTokenSupport;
  /// optional multilineTokenSupport: boolean
  bool? get multilineTokenSupport;
  /// optional serverCancelSupport: boolean
  bool? get serverCancelSupport;
  /// optional augmentsSyntaxTokens: boolean
  bool? get augmentsSyntaxTokens;
}

/// interface LinkedEditingRangeClientCapabilities
abstract class LinkedEditingRangeClientCapabilities {
  /// optional dynamicRegistration: boolean
  bool? get dynamicRegistration;
}

/// interface MonikerClientCapabilities
abstract class MonikerClientCapabilities {
  /// optional dynamicRegistration: boolean
  bool? get dynamicRegistration;
}

/// interface TypeHierarchyClientCapabilities
abstract class TypeHierarchyClientCapabilities {
  /// optional dynamicRegistration: boolean
  bool? get dynamicRegistration;
}

/// interface InlineValueClientCapabilities
abstract class InlineValueClientCapabilities {
  /// optional dynamicRegistration: boolean
  bool? get dynamicRegistration;
}

/// interface InlayHintClientCapabilities
abstract class InlayHintClientCapabilities {
  /// optional dynamicRegistration: boolean
  bool? get dynamicRegistration;
  /// optional resolveSupport: { properties: (string)[] }
  Map<String, Object?>? get resolveSupport;
}

/// interface DiagnosticClientCapabilities
abstract class DiagnosticClientCapabilities {
  /// optional dynamicRegistration: boolean
  bool? get dynamicRegistration;
  /// optional relatedDocumentSupport: boolean
  bool? get relatedDocumentSupport;
}

/// interface InlineCompletionClientCapabilities
abstract class InlineCompletionClientCapabilities {
  /// optional dynamicRegistration: boolean
  bool? get dynamicRegistration;
}

/// interface NotebookDocumentSyncClientCapabilities
abstract class NotebookDocumentSyncClientCapabilities {
  /// optional dynamicRegistration: boolean
  bool? get dynamicRegistration;
  /// optional executionSummarySupport: boolean
  bool? get executionSummarySupport;
}

/// interface ShowMessageRequestClientCapabilities
abstract class ShowMessageRequestClientCapabilities {
  /// optional messageActionItem: { additionalPropertiesSupport?: boolean }
  Map<String, Object?>? get messageActionItem;
}

/// interface ShowDocumentClientCapabilities
abstract class ShowDocumentClientCapabilities {
  /// support: boolean
  bool get support;
}

/// interface RegularExpressionsClientCapabilities
abstract class RegularExpressionsClientCapabilities {
  /// engine: string
  String get engine;
  /// optional version: string
  String? get version;
}

/// interface MarkdownClientCapabilities
abstract class MarkdownClientCapabilities {
  /// parser: string
  String get parser;
  /// optional version: string
  String? get version;
  /// optional allowedTags: (string)[]
  List<String>? get allowedTags;
}

/// typedef Definition = Location | (Location)[]
typedef Definition = Object?;
/// typedef DefinitionLink = LocationLink
typedef DefinitionLink = LocationLink;
/// typedef LSPArray = (LSPAny)[]
typedef LSPArray = List<LSPAny>;
/// typedef LSPAny = LSPObject | LSPArray | string | number | number | number | boolean | null
typedef LSPAny = Object?;
/// typedef Declaration = Location | (Location)[]
typedef Declaration = Object?;
/// typedef DeclarationLink = LocationLink
typedef DeclarationLink = LocationLink;
/// typedef InlineValue = InlineValueText | InlineValueVariableLookup | InlineValueEvaluatableExpression
typedef InlineValue = Object?;
/// typedef DocumentDiagnosticReport = RelatedFullDocumentDiagnosticReport | RelatedUnchangedDocumentDiagnosticReport
typedef DocumentDiagnosticReport = Object?;
/// typedef PrepareRenameResult = Range | { range: Range; placeholder: string } | { defaultBehavior: boolean }
typedef PrepareRenameResult = Object?;
/// typedef DocumentSelector = (DocumentFilter)[]
typedef DocumentSelector = List<DocumentFilter>;
/// typedef ProgressToken = number | string
typedef ProgressToken = Object?;
/// typedef ChangeAnnotationIdentifier = string
typedef ChangeAnnotationIdentifier = String;
/// typedef WorkspaceDocumentDiagnosticReport = WorkspaceFullDocumentDiagnosticReport | WorkspaceUnchangedDocumentDiagnosticReport
typedef WorkspaceDocumentDiagnosticReport = Object?;
/// typedef TextDocumentContentChangeEvent = { range: Range; rangeLength?: number; text: string } | { text: string }
typedef TextDocumentContentChangeEvent = Object?;
/// typedef MarkedString = string | { language: string; value: string }
typedef MarkedString = Object?;
/// typedef DocumentFilter = TextDocumentFilter | NotebookCellTextDocumentFilter
typedef DocumentFilter = Object?;
/// typedef LSPObject = { [key: string]: LSPAny }
typedef LSPObject = Map<String, Object?>;
/// typedef GlobPattern = Pattern | RelativePattern
typedef GlobPattern = Object?;
/// typedef TextDocumentFilter = { language: string; scheme?: string; pattern?: string } | { language?: string; scheme: string; pattern?: string } | { language?: string; scheme?: string; pattern: string }
typedef TextDocumentFilter = Object?;
/// typedef NotebookDocumentFilter = { notebookType: string; scheme?: string; pattern?: string } | { notebookType?: string; scheme: string; pattern?: string } | { notebookType?: string; scheme?: string; pattern: string }
typedef NotebookDocumentFilter = Object?;
/// typedef Pattern = string
typedef Pattern = String;

/// class Capability<T>
class Capability<T> {
  final String method;
  const Capability(this.method);
}

/// export const capabilities
const Map<String, Capability<dynamic>> capabilities = <String, Capability<dynamic>>{
  'textDocumentImplementation': Capability<dynamic>('textDocument/implementation'),
  'textDocumentTypeDefinition': Capability<dynamic>('textDocument/typeDefinition'),
  'textDocumentDocumentColor': Capability<dynamic>('textDocument/documentColor'),
  'textDocumentColorPresentation': Capability<dynamic>('textDocument/colorPresentation'),
  'textDocumentFoldingRange': Capability<dynamic>('textDocument/foldingRange'),
  'textDocumentDeclaration': Capability<dynamic>('textDocument/declaration'),
  'textDocumentSelectionRange': Capability<dynamic>('textDocument/selectionRange'),
  'textDocumentPrepareCallHierarchy': Capability<dynamic>('textDocument/prepareCallHierarchy'),
  'textDocumentSemanticTokensFull': Capability<dynamic>('textDocument/semanticTokens/full'),
  'textDocumentSemanticTokensFullDelta': Capability<dynamic>('textDocument/semanticTokens/full/delta'),
  'textDocumentLinkedEditingRange': Capability<dynamic>('textDocument/linkedEditingRange'),
  'workspaceWillCreateFiles': Capability<dynamic>('workspace/willCreateFiles'),
  'workspaceWillRenameFiles': Capability<dynamic>('workspace/willRenameFiles'),
  'workspaceWillDeleteFiles': Capability<dynamic>('workspace/willDeleteFiles'),
  'textDocumentMoniker': Capability<dynamic>('textDocument/moniker'),
  'textDocumentPrepareTypeHierarchy': Capability<dynamic>('textDocument/prepareTypeHierarchy'),
  'textDocumentInlineValue': Capability<dynamic>('textDocument/inlineValue'),
  'textDocumentInlayHint': Capability<dynamic>('textDocument/inlayHint'),
  'textDocumentDiagnostic': Capability<dynamic>('textDocument/diagnostic'),
  'textDocumentInlineCompletion': Capability<dynamic>('textDocument/inlineCompletion'),
  'textDocumentWillSaveWaitUntil': Capability<dynamic>('textDocument/willSaveWaitUntil'),
  'textDocumentCompletion': Capability<dynamic>('textDocument/completion'),
  'textDocumentHover': Capability<dynamic>('textDocument/hover'),
  'textDocumentSignatureHelp': Capability<dynamic>('textDocument/signatureHelp'),
  'textDocumentDefinition': Capability<dynamic>('textDocument/definition'),
  'textDocumentReferences': Capability<dynamic>('textDocument/references'),
  'textDocumentDocumentHighlight': Capability<dynamic>('textDocument/documentHighlight'),
  'textDocumentDocumentSymbol': Capability<dynamic>('textDocument/documentSymbol'),
  'textDocumentCodeAction': Capability<dynamic>('textDocument/codeAction'),
  'workspaceSymbol': Capability<dynamic>('workspace/symbol'),
  'textDocumentCodeLens': Capability<dynamic>('textDocument/codeLens'),
  'textDocumentDocumentLink': Capability<dynamic>('textDocument/documentLink'),
  'textDocumentFormatting': Capability<dynamic>('textDocument/formatting'),
  'textDocumentRangeFormatting': Capability<dynamic>('textDocument/rangeFormatting'),
  'textDocumentRangesFormatting': Capability<dynamic>('textDocument/rangesFormatting'),
  'textDocumentOnTypeFormatting': Capability<dynamic>('textDocument/onTypeFormatting'),
  'textDocumentRename': Capability<dynamic>('textDocument/rename'),
  'workspaceExecuteCommand': Capability<dynamic>('workspace/executeCommand'),
  'workspaceDidCreateFiles': Capability<dynamic>('workspace/didCreateFiles'),
  'workspaceDidRenameFiles': Capability<dynamic>('workspace/didRenameFiles'),
  'workspaceDidDeleteFiles': Capability<dynamic>('workspace/didDeleteFiles'),
  'workspaceDidChangeConfiguration': Capability<dynamic>('workspace/didChangeConfiguration'),
  'textDocumentDidOpen': Capability<dynamic>('textDocument/didOpen'),
  'textDocumentDidChange': Capability<dynamic>('textDocument/didChange'),
  'textDocumentDidClose': Capability<dynamic>('textDocument/didClose'),
  'textDocumentDidSave': Capability<dynamic>('textDocument/didSave'),
  'textDocumentWillSave': Capability<dynamic>('textDocument/willSave'),
  'workspaceDidChangeWatchedFiles': Capability<dynamic>('workspace/didChangeWatchedFiles'),
};

/// A method entry in the LSP contract (request or notification).
class LspApiMethod {
  final String method;
  final bool isNotification;
  final bool optional;
  const LspApiMethod(this.method, {this.isNotification = false, this.optional = false});
}

/// export const api = contract({ ... })
class LspApi {
  final String name;
  final Map<String, LspApiMethod> server;
  final Map<String, LspApiMethod> client;
  const LspApi(this.name, this.server, this.client);
}

const LspApi api = LspApi(
  'LSP',
  <String, LspApiMethod>{
    'textDocumentImplementation': LspApiMethod('textDocument/implementation'),
    'textDocumentTypeDefinition': LspApiMethod('textDocument/typeDefinition'),
    'textDocumentDocumentColor': LspApiMethod('textDocument/documentColor'),
    'textDocumentColorPresentation': LspApiMethod('textDocument/colorPresentation'),
    'textDocumentFoldingRange': LspApiMethod('textDocument/foldingRange'),
    'textDocumentDeclaration': LspApiMethod('textDocument/declaration'),
    'textDocumentSelectionRange': LspApiMethod('textDocument/selectionRange'),
    'textDocumentPrepareCallHierarchy': LspApiMethod('textDocument/prepareCallHierarchy'),
    'callHierarchyIncomingCalls': LspApiMethod('callHierarchy/incomingCalls'),
    'callHierarchyOutgoingCalls': LspApiMethod('callHierarchy/outgoingCalls'),
    'textDocumentSemanticTokensFull': LspApiMethod('textDocument/semanticTokens/full'),
    'textDocumentSemanticTokensFullDelta': LspApiMethod('textDocument/semanticTokens/full/delta'),
    'textDocumentSemanticTokensRange': LspApiMethod('textDocument/semanticTokens/range'),
    'textDocumentLinkedEditingRange': LspApiMethod('textDocument/linkedEditingRange'),
    'workspaceWillCreateFiles': LspApiMethod('workspace/willCreateFiles'),
    'workspaceWillRenameFiles': LspApiMethod('workspace/willRenameFiles'),
    'workspaceWillDeleteFiles': LspApiMethod('workspace/willDeleteFiles'),
    'textDocumentMoniker': LspApiMethod('textDocument/moniker'),
    'textDocumentPrepareTypeHierarchy': LspApiMethod('textDocument/prepareTypeHierarchy'),
    'typeHierarchySupertypes': LspApiMethod('typeHierarchy/supertypes'),
    'typeHierarchySubtypes': LspApiMethod('typeHierarchy/subtypes'),
    'textDocumentInlineValue': LspApiMethod('textDocument/inlineValue'),
    'textDocumentInlayHint': LspApiMethod('textDocument/inlayHint'),
    'inlayHintResolve': LspApiMethod('inlayHint/resolve'),
    'textDocumentDiagnostic': LspApiMethod('textDocument/diagnostic'),
    'workspaceDiagnostic': LspApiMethod('workspace/diagnostic'),
    'textDocumentInlineCompletion': LspApiMethod('textDocument/inlineCompletion'),
    'initialize': LspApiMethod('initialize'),
    'shutdown': LspApiMethod('shutdown'),
    'textDocumentWillSaveWaitUntil': LspApiMethod('textDocument/willSaveWaitUntil'),
    'textDocumentCompletion': LspApiMethod('textDocument/completion'),
    'completionItemResolve': LspApiMethod('completionItem/resolve'),
    'textDocumentHover': LspApiMethod('textDocument/hover'),
    'textDocumentSignatureHelp': LspApiMethod('textDocument/signatureHelp'),
    'textDocumentDefinition': LspApiMethod('textDocument/definition'),
    'textDocumentReferences': LspApiMethod('textDocument/references'),
    'textDocumentDocumentHighlight': LspApiMethod('textDocument/documentHighlight'),
    'textDocumentDocumentSymbol': LspApiMethod('textDocument/documentSymbol'),
    'textDocumentCodeAction': LspApiMethod('textDocument/codeAction'),
    'codeActionResolve': LspApiMethod('codeAction/resolve'),
    'workspaceSymbol': LspApiMethod('workspace/symbol'),
    'workspaceSymbolResolve': LspApiMethod('workspaceSymbol/resolve'),
    'textDocumentCodeLens': LspApiMethod('textDocument/codeLens'),
    'codeLensResolve': LspApiMethod('codeLens/resolve'),
    'textDocumentDocumentLink': LspApiMethod('textDocument/documentLink'),
    'documentLinkResolve': LspApiMethod('documentLink/resolve'),
    'textDocumentFormatting': LspApiMethod('textDocument/formatting'),
    'textDocumentRangeFormatting': LspApiMethod('textDocument/rangeFormatting'),
    'textDocumentRangesFormatting': LspApiMethod('textDocument/rangesFormatting'),
    'textDocumentOnTypeFormatting': LspApiMethod('textDocument/onTypeFormatting'),
    'textDocumentRename': LspApiMethod('textDocument/rename'),
    'textDocumentPrepareRename': LspApiMethod('textDocument/prepareRename'),
    'workspaceExecuteCommand': LspApiMethod('workspace/executeCommand'),
    'workspaceDidChangeWorkspaceFolders': LspApiMethod('workspace/didChangeWorkspaceFolders', isNotification: true),
    'windowWorkDoneProgressCancel': LspApiMethod('window/workDoneProgress/cancel', isNotification: true),
    'workspaceDidCreateFiles': LspApiMethod('workspace/didCreateFiles', isNotification: true),
    'workspaceDidRenameFiles': LspApiMethod('workspace/didRenameFiles', isNotification: true),
    'workspaceDidDeleteFiles': LspApiMethod('workspace/didDeleteFiles', isNotification: true),
    'notebookDocumentDidOpen': LspApiMethod('notebookDocument/didOpen', isNotification: true),
    'notebookDocumentDidChange': LspApiMethod('notebookDocument/didChange', isNotification: true),
    'notebookDocumentDidSave': LspApiMethod('notebookDocument/didSave', isNotification: true),
    'notebookDocumentDidClose': LspApiMethod('notebookDocument/didClose', isNotification: true),
    'initialized': LspApiMethod('initialized', isNotification: true),
    'exit': LspApiMethod('exit', isNotification: true),
    'workspaceDidChangeConfiguration': LspApiMethod('workspace/didChangeConfiguration', isNotification: true),
    'textDocumentDidOpen': LspApiMethod('textDocument/didOpen', isNotification: true),
    'textDocumentDidChange': LspApiMethod('textDocument/didChange', isNotification: true),
    'textDocumentDidClose': LspApiMethod('textDocument/didClose', isNotification: true),
    'textDocumentDidSave': LspApiMethod('textDocument/didSave', isNotification: true),
    'textDocumentWillSave': LspApiMethod('textDocument/willSave', isNotification: true),
    'workspaceDidChangeWatchedFiles': LspApiMethod('workspace/didChangeWatchedFiles', isNotification: true),
    'setTrace': LspApiMethod('\$/setTrace', isNotification: true),
    'cancelRequest': LspApiMethod('\$/cancelRequest', isNotification: true),
    'progress': LspApiMethod('\$/progress', isNotification: true),
  },
  <String, LspApiMethod>{
    'workspaceWorkspaceFolders': LspApiMethod('workspace/workspaceFolders', optional: true),
    'workspaceConfiguration': LspApiMethod('workspace/configuration', optional: true),
    'workspaceFoldingRangeRefresh': LspApiMethod('workspace/foldingRange/refresh', optional: true),
    'windowWorkDoneProgressCreate': LspApiMethod('window/workDoneProgress/create', optional: true),
    'workspaceSemanticTokensRefresh': LspApiMethod('workspace/semanticTokens/refresh', optional: true),
    'windowShowDocument': LspApiMethod('window/showDocument', optional: true),
    'workspaceInlineValueRefresh': LspApiMethod('workspace/inlineValue/refresh', optional: true),
    'workspaceInlayHintRefresh': LspApiMethod('workspace/inlayHint/refresh', optional: true),
    'workspaceDiagnosticRefresh': LspApiMethod('workspace/diagnostic/refresh', optional: true),
    'clientRegisterCapability': LspApiMethod('client/registerCapability', optional: true),
    'clientUnregisterCapability': LspApiMethod('client/unregisterCapability', optional: true),
    'windowShowMessageRequest': LspApiMethod('window/showMessageRequest', optional: true),
    'workspaceCodeLensRefresh': LspApiMethod('workspace/codeLens/refresh', optional: true),
    'workspaceApplyEdit': LspApiMethod('workspace/applyEdit', optional: true),
    'windowShowMessage': LspApiMethod('window/showMessage', isNotification: true),
    'windowLogMessage': LspApiMethod('window/logMessage', isNotification: true),
    'telemetryEvent': LspApiMethod('telemetry/event', isNotification: true),
    'textDocumentPublishDiagnostics': LspApiMethod('textDocument/publishDiagnostics', isNotification: true),
    'logTrace': LspApiMethod('\$/logTrace', isNotification: true),
    'cancelRequest': LspApiMethod('\$/cancelRequest', isNotification: true),
    'progress': LspApiMethod('\$/progress', isNotification: true),
  },
);
