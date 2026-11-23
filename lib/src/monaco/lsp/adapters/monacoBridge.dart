// Carrier bridges for `monaco-editor-core` value types referenced by the
// monaco-lsp-client adapters but not (yet) ported into the monaco Dart tree.
// These are opaque identity/value carriers: they preserve the TS type surface
// (`monaco.editor.ITextModel`, `monaco.Position`, `monaco.Range`) without
// inventing editor behavior. Position/Range carry the same fields as the
// editor core types so translation logic can read lineNumber/column etc.

/// 1:1 carrier of `monaco.Position`.
class MonacoPosition {
  final int lineNumber;
  final int column;

  const MonacoPosition(this.lineNumber, this.column);

  @override
  String toString() => 'MonacoPosition($lineNumber,$column)';

  @override
  bool operator ==(Object other) =>
      other is MonacoPosition && other.lineNumber == lineNumber && other.column == column;

  @override
  int get hashCode => Object.hash(lineNumber, column);
}

/// 1:1 carrier of `monaco.Range`.
class MonacoRange {
  final int startLineNumber;
  final int startColumn;
  final int endLineNumber;
  final int endColumn;

  const MonacoRange(this.startLineNumber, this.startColumn, this.endLineNumber, this.endColumn);

  @override
  String toString() =>
      'MonacoRange($startLineNumber,$startColumn,$endLineNumber,$endColumn)';

  @override
  bool operator ==(Object other) =>
      other is MonacoRange &&
      other.startLineNumber == startLineNumber &&
      other.startColumn == startColumn &&
      other.endLineNumber == endLineNumber &&
      other.endColumn == endColumn;

  @override
  int get hashCode => Object.hash(startLineNumber, startColumn, endLineNumber, endColumn);
}

/// 1:1 carrier of `monaco.editor.ITextModel`. Identity semantics (TS object ref).
abstract class IMonacoTextModel {
  /// 1:1: `getLanguageId(): string`
  String getLanguageId();

  /// 1:1: `getVersionId(): number`
  int getVersionId();

  /// 1:1: `getUri(): Uri`
  Object? getUri();

  /// 1:1: `uri.toString(verbose)` — bridges the Uri string form used by adapters.
  String uriString(bool verbose) => getUri().toString();
}

/// Simple testable implementation of [IMonacoTextModel].
class SimpleTextModel implements IMonacoTextModel {
  final String languageId;
  final int versionId;
  final Object? uri;
  final String text;

  SimpleTextModel({required this.languageId, this.versionId = 1, this.uri, this.text = ''});

  @override
  String getLanguageId() => languageId;

  @override
  int getVersionId() => versionId;

  @override
  Object? getUri() => uri;

  @override
  String uriString(bool verbose) => uri?.toString() ?? '';
}
