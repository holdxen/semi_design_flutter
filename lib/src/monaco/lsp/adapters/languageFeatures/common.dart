// 1:1 port of monaco-lsp-client/src/adapters/languageFeatures/common.ts
// LSP enum values come from lsp/types.dart; monaco enum values are String
// symbolic carriers (monaco.languages.X.Y) matching the TS runtime truth.
library;

import '../../types.dart' as T;
import '../LspConnection.dart';
import '../TextDocumentSynchronizer.dart'
    show LspPos, LspRange, LspTextDocumentIdentifier;
import '../monacoBridge.dart';
import '../monacoEditorApi.dart' show parseUri;

/// monaco enum value carrier (symbolic name, 1:1 with TS enum member).
typedef MonacoSymbol = String;

/// JS truthiness helper: `undefined`/null, 0, '' and false are falsy.
bool _falsy(Object? v) => v == null || v == 0 || v == '' || v == false;

/// 1:1: `export const lspCodeActionKindToMonacoCodeActionKind = new Map([...])`
const Map<Object?, Object?> lspCodeActionKindToMonacoCodeActionKind = <Object?, Object?>{
  "": "",
  "quickfix": "quickfix",
  "refactor": "refactor",
  "refactor.extract": "refactor.extract",
  "refactor.inline": "refactor.inline",
  "refactor.rewrite": "refactor.rewrite",
  "source": "source",
  "source.organizeImports": "source.organizeImports",
  "source.fixAll": "source.fixAll",
};

/// 1:1: `export const monacoCodeActionTriggerTypeToLspCodeActionTriggerKind = new Map([...])`
const Map<Object?, Object?> monacoCodeActionTriggerTypeToLspCodeActionTriggerKind = <Object?, Object?>{
  "monaco.languages.CodeActionTriggerType.Invoke": 1,
  "monaco.languages.CodeActionTriggerType.Auto": 2,
};

/// 1:1: `export const lspCompletionItemKindToMonacoCompletionItemKind = new Map([...])`
const Map<Object?, Object?> lspCompletionItemKindToMonacoCompletionItemKind = <Object?, Object?>{
  1: "monaco.languages.CompletionItemKind.Text",
  2: "monaco.languages.CompletionItemKind.Method",
  3: "monaco.languages.CompletionItemKind.Function",
  4: "monaco.languages.CompletionItemKind.Constructor",
  5: "monaco.languages.CompletionItemKind.Field",
  6: "monaco.languages.CompletionItemKind.Variable",
  7: "monaco.languages.CompletionItemKind.Class",
  8: "monaco.languages.CompletionItemKind.Interface",
  9: "monaco.languages.CompletionItemKind.Module",
  10: "monaco.languages.CompletionItemKind.Property",
  11: "monaco.languages.CompletionItemKind.Unit",
  12: "monaco.languages.CompletionItemKind.Value",
  13: "monaco.languages.CompletionItemKind.Enum",
  14: "monaco.languages.CompletionItemKind.Keyword",
  15: "monaco.languages.CompletionItemKind.Snippet",
  16: "monaco.languages.CompletionItemKind.Color",
  17: "monaco.languages.CompletionItemKind.File",
  18: "monaco.languages.CompletionItemKind.Reference",
  19: "monaco.languages.CompletionItemKind.Folder",
  20: "monaco.languages.CompletionItemKind.EnumMember",
  21: "monaco.languages.CompletionItemKind.Constant",
  22: "monaco.languages.CompletionItemKind.Struct",
  23: "monaco.languages.CompletionItemKind.Event",
  24: "monaco.languages.CompletionItemKind.Operator",
  25: "monaco.languages.CompletionItemKind.TypeParameter",
};

/// 1:1: `export const lspCompletionItemTagToMonacoCompletionItemTag = new Map([...])`
const Map<Object?, Object?> lspCompletionItemTagToMonacoCompletionItemTag = <Object?, Object?>{
  1: "monaco.languages.CompletionItemTag.Deprecated",
};

/// 1:1: `export const monacoCompletionTriggerKindToLspCompletionTriggerKind = new Map([...])`
const Map<Object?, Object?> monacoCompletionTriggerKindToLspCompletionTriggerKind = <Object?, Object?>{
  "monaco.languages.CompletionTriggerKind.Invoke": 1,
  "monaco.languages.CompletionTriggerKind.TriggerCharacter": 2,
  "monaco.languages.CompletionTriggerKind.TriggerForIncompleteCompletions": 3,
};

/// 1:1: `export const lspInsertTextFormatToMonacoInsertTextRules = new Map([...])`
const Map<Object?, Object?> lspInsertTextFormatToMonacoInsertTextRules = <Object?, Object?>{
  2: "monaco.languages.CompletionItemInsertTextRule.InsertAsSnippet",
};

/// 1:1: `export const lspSymbolKindToMonacoSymbolKind = new Map([...])`
const Map<Object?, Object?> lspSymbolKindToMonacoSymbolKind = <Object?, Object?>{
  1: "monaco.languages.SymbolKind.File",
  2: "monaco.languages.SymbolKind.Module",
  3: "monaco.languages.SymbolKind.Namespace",
  4: "monaco.languages.SymbolKind.Package",
  5: "monaco.languages.SymbolKind.Class",
  6: "monaco.languages.SymbolKind.Method",
  7: "monaco.languages.SymbolKind.Property",
  8: "monaco.languages.SymbolKind.Field",
  9: "monaco.languages.SymbolKind.Constructor",
  10: "monaco.languages.SymbolKind.Enum",
  11: "monaco.languages.SymbolKind.Interface",
  12: "monaco.languages.SymbolKind.Function",
  13: "monaco.languages.SymbolKind.Variable",
  14: "monaco.languages.SymbolKind.Constant",
  15: "monaco.languages.SymbolKind.String",
  16: "monaco.languages.SymbolKind.Number",
  17: "monaco.languages.SymbolKind.Boolean",
  18: "monaco.languages.SymbolKind.Array",
  19: "monaco.languages.SymbolKind.Object",
  20: "monaco.languages.SymbolKind.Key",
  21: "monaco.languages.SymbolKind.Null",
  22: "monaco.languages.SymbolKind.EnumMember",
  23: "monaco.languages.SymbolKind.Struct",
  24: "monaco.languages.SymbolKind.Event",
  25: "monaco.languages.SymbolKind.Operator",
  26: "monaco.languages.SymbolKind.TypeParameter",
};

/// 1:1: `export const lspSymbolTagToMonacoSymbolTag = new Map([...])`
const Map<Object?, Object?> lspSymbolTagToMonacoSymbolTag = <Object?, Object?>{
  1: "monaco.languages.SymbolTag.Deprecated",
};

/// 1:1: `export const lspDocumentHighlightKindToMonacoDocumentHighlightKind = new Map([...])`
const Map<Object?, Object?> lspDocumentHighlightKindToMonacoDocumentHighlightKind = <Object?, Object?>{
  1: "monaco.languages.DocumentHighlightKind.Text",
  2: "monaco.languages.DocumentHighlightKind.Read",
  3: "monaco.languages.DocumentHighlightKind.Write",
};

/// 1:1: `export const lspFoldingRangeKindToMonacoFoldingRangeKind = new Map([...])`
const Map<Object?, Object?> lspFoldingRangeKindToMonacoFoldingRangeKind = <Object?, Object?>{
  "comment": "monaco.languages.FoldingRangeKind.Comment",
  "imports": "monaco.languages.FoldingRangeKind.Imports",
  "region": "monaco.languages.FoldingRangeKind.Region",
};

/// 1:1: `export const monacoMarkerSeverityToLspDiagnosticSeverity = new Map([...])`
const Map<Object?, Object?> monacoMarkerSeverityToLspDiagnosticSeverity = <Object?, Object?>{
  "monaco.MarkerSeverity.Error": 1,
  "monaco.MarkerSeverity.Warning": 2,
  "monaco.MarkerSeverity.Info": 3,
  "monaco.MarkerSeverity.Hint": 4,
};

/// 1:1: `export const lspDiagnosticSeverityToMonacoMarkerSeverity = new Map([...])`
const Map<Object?, Object?> lspDiagnosticSeverityToMonacoMarkerSeverity = <Object?, Object?>{
  1: "monaco.MarkerSeverity.Error",
  2: "monaco.MarkerSeverity.Warning",
  3: "monaco.MarkerSeverity.Info",
  4: "monaco.MarkerSeverity.Hint",
};

/// 1:1: `export const lspDiagnosticTagToMonacoMarkerTag = new Map([...])`
const Map<Object?, Object?> lspDiagnosticTagToMonacoMarkerTag = <Object?, Object?>{
  1: "monaco.MarkerTag.Unnecessary",
  2: "monaco.MarkerTag.Deprecated",
};

/// 1:1: `export const monacoSignatureHelpTriggerKindToLspSignatureHelpTriggerKind = new Map([...])`
const Map<Object?, Object?> monacoSignatureHelpTriggerKindToLspSignatureHelpTriggerKind = <Object?, Object?>{
  "monaco.languages.SignatureHelpTriggerKind.Invoke": 1,
  "monaco.languages.SignatureHelpTriggerKind.TriggerCharacter": 2,
  "monaco.languages.SignatureHelpTriggerKind.ContentChange": 3,
};

/// 1:1: `export const lspInlayHintKindToMonacoInlayHintKind = new Map([...])`
const Map<Object?, Object?> lspInlayHintKindToMonacoInlayHintKind = <Object?, Object?>{
  1: "monaco.languages.InlayHintKind.Type",
  2: "monaco.languages.InlayHintKind.Parameter",
};


// ============================================================================
// Conversion functions (1:1 with common.ts). LSP enum values are num/String;
// monaco enum values are symbolic String carriers. `undefined` -> Dart null.

/// 1:1: `toMonacoCodeActionKind`
Object? toMonacoCodeActionKind(Object? kind) {
  if (_falsy(kind)) return null;
  return lspCodeActionKindToMonacoCodeActionKind[kind] ?? kind;
}

/// 1:1: `toLspCodeActionTriggerKind`
Object? toLspCodeActionTriggerKind(Object? monacoTrigger) =>
    monacoCodeActionTriggerTypeToLspCodeActionTriggerKind[monacoTrigger] ?? 1;

/// 1:1: `toMonacoCompletionItemKind`
Object? toMonacoCompletionItemKind(Object? kind) {
  if (_falsy(kind)) return 'monaco.languages.CompletionItemKind.Text';
  return lspCompletionItemKindToMonacoCompletionItemKind[kind] ??
      'monaco.languages.CompletionItemKind.Text';
}

/// 1:1: `toMonacoCompletionItemTag`
Object? toMonacoCompletionItemTag(Object? tag) =>
    lspCompletionItemTagToMonacoCompletionItemTag[tag];

/// 1:1: `toLspCompletionTriggerKind`
Object? toLspCompletionTriggerKind(Object? monacoKind) =>
    monacoCompletionTriggerKindToLspCompletionTriggerKind[monacoKind] ?? 1;

/// 1:1: `toMonacoInsertTextRules`
Object? toMonacoInsertTextRules(Object? format) {
  if (_falsy(format)) return null;
  return lspInsertTextFormatToMonacoInsertTextRules[format];
}

/// 1:1: `toMonacoSymbolKind`
Object? toMonacoSymbolKind(Object? kind) =>
    lspSymbolKindToMonacoSymbolKind[kind] ?? 'monaco.languages.SymbolKind.File';

/// 1:1: `toMonacoSymbolTag`
Object? toMonacoSymbolTag(Object? tag) => lspSymbolTagToMonacoSymbolTag[tag];

/// 1:1: `toMonacoDocumentHighlightKind`
Object? toMonacoDocumentHighlightKind(Object? kind) {
  if (_falsy(kind)) return 'monaco.languages.DocumentHighlightKind.Text';
  return lspDocumentHighlightKindToMonacoDocumentHighlightKind[kind] ??
      'monaco.languages.DocumentHighlightKind.Text';
}

/// 1:1: `toMonacoFoldingRangeKind`
Object? toMonacoFoldingRangeKind(Object? kind) {
  if (_falsy(kind)) return null;
  return lspFoldingRangeKindToMonacoFoldingRangeKind[kind];
}

/// 1:1: `toLspDiagnosticSeverity`
Object? toLspDiagnosticSeverity(Object? severity) =>
    monacoMarkerSeverityToLspDiagnosticSeverity[severity] ?? 1;

/// 1:1: `toMonacoDiagnosticSeverity`
Object? toMonacoDiagnosticSeverity(Object? severity) {
  if (_falsy(severity)) return 'monaco.MarkerSeverity.Error';
  return lspDiagnosticSeverityToMonacoMarkerSeverity[severity] ??
      'monaco.MarkerSeverity.Error';
}

/// 1:1: `toMonacoDiagnosticTag`
Object? toMonacoDiagnosticTag(Object? tag) =>
    lspDiagnosticTagToMonacoMarkerTag[tag];

/// 1:1: `toLspSignatureHelpTriggerKind`
Object? toLspSignatureHelpTriggerKind(Object? monacoKind) =>
    monacoSignatureHelpTriggerKindToLspSignatureHelpTriggerKind[monacoKind] ?? 1;

/// 1:1: `toUntrustedMarkdownString`
Map<String, Object?> toUntrustedMarkdownString(String value) => <String, Object?>{
  'value': value,
  'isTrusted': false,
  'supportHtml': false,
};

/// 1:1: `toMonacoInlayHintKind`
Object? toMonacoInlayHintKind(Object? kind) {
  if (_falsy(kind)) return 'monaco.languages.InlayHintKind.Type';
  return lspInlayHintKindToMonacoInlayHintKind[kind] ??
      'monaco.languages.InlayHintKind.Type';
}

// ============================================================================
// Location / selector / marker conversions (1:1 with common.ts tail).
// LSP structural objects arrive as Map<String,Object?> carriers; monaco range
// values are MonacoRange carriers. `undefined` -> Dart null.
// ============================================================================

/// 1:1: `toMonacoLocation(location, client)` — returns a Map carrier shaped
/// `{uri, range, originSelectionRange?, targetSelectionRange?}` for LocationLink
/// or `{uri, range}` for Location.
Map<String, Object?> toMonacoLocation(Object? location, LspConnection client) {
  final loc = location as Map<String, Object?>;
  if (loc.containsKey('targetUri')) {
    // LocationLink
    final targetUri = loc['targetUri'] as String;
    final translatedRange = client.bridge.translateBackRange(
      LspTextDocumentIdentifier(targetUri),
      _mapToRange(loc['targetRange']),
    );
    final origin = loc['originSelectionRange'];
    final target = loc['targetSelectionRange'];
    return <String, Object?>{
      'uri': translatedRange.textModel.getUri(),
      'range': translatedRange.range,
      'originSelectionRange': origin == null
          ? null
          : client.bridge
              .translateBackRange(
                LspTextDocumentIdentifier(targetUri),
                _mapToRange(origin),
              )
              .range,
      'targetSelectionRange': target == null
          ? null
          : client.bridge
              .translateBackRange(
                LspTextDocumentIdentifier(targetUri),
                _mapToRange(target),
              )
              .range,
    };
  }
  // Location
  final uri = loc['uri'] as String;
  final translatedRange = client.bridge.translateBackRange(
    LspTextDocumentIdentifier(uri),
    _mapToRange(loc['range']),
  );
  return <String, Object?>{
    'uri': translatedRange.textModel.getUri(),
    'range': translatedRange.range,
  };
}

/// 1:1: `toMonacoLanguageSelector(s)` — null/empty -> `{language:'*'}`;
/// otherwise a List of filter Map carriers.
Object toMonacoLanguageSelector(Object? s) {
  if (s == null || (s is List && s.isEmpty)) {
    return <String, Object?>{'language': '*'};
  }
  final list = s as List;
  return list.map<Object?>((item) {
    final filter = item is String
        ? <String, Object?>{'language': item}
        : Map<String, Object?>.from(item as Map);
    if (filter.containsKey('notebook')) {
      final notebook = filter['notebook'];
      if (notebook is String) {
        return <String, Object?>{
          'notebookType': notebook,
          'language': filter['language'],
        };
      }
      final nb = notebook as Map<String, Object?>;
      return <String, Object?>{
        'notebookType': nb['notebookType'],
        'language': filter['language'],
        'pattern': nb['pattern'],
        'scheme': nb['scheme'],
      };
    }
    return <String, Object?>{
      'language': filter['language'],
      'pattern': filter['pattern'],
      'scheme': filter['scheme'],
    };
  }).toList();
}

/// 1:1: `matchesDocumentSelector(model, selector)`.
bool matchesDocumentSelector(IMonacoTextModel model, Object? selector) {
  if (selector == null) return true;
  final languageId = model.getLanguageId();
  // 1:1: `const uri = model.uri.toString(true)` (computed but unused in TS).
  // ignore: unused_local_variable
  final uri = model.uriString(true);
  if (selector is! List || selector.isEmpty) return true;
  for (final item in selector) {
    final filter = item as Map<String, Object?>;
    final lang = filter['language'];
    if (lang != null && lang != '*' && lang != languageId) continue;
    return true;
  }
  return false;
}

/// 1:1: `toDiagnosticMarker(diagnostic)` — returns a `IMarkerData` Map carrier.
Map<String, Object?> toDiagnosticMarker(Object? diagnostic) {
  final diagnosticMap = diagnostic as Map<String, Object?>;
  final range = _mapToRange(diagnosticMap['range']);
  final start = _rangeStart(range);
  final end = _rangeEnd(range);
  final code = diagnosticMap['code'];
  final marker = <String, Object?>{
    'severity': toMonacoDiagnosticSeverity(diagnosticMap['severity']),
    'startLineNumber': start.line + 1,
    'startColumn': start.character + 1,
    'endLineNumber': end.line + 1,
    'endColumn': end.character + 1,
    'message': diagnosticMap['message'],
    'source': diagnosticMap['source'],
    'code': code is String ? code : code?.toString(),
  };

  final tags = diagnosticMap['tags'];
  if (tags != null) {
    marker['tags'] = (tags as List)
        .map((tag) => toMonacoDiagnosticTag(tag))
        .where((tag) => tag != null)
        .toList();
  }

  final related = diagnosticMap['relatedInformation'];
  if (related != null) {
    marker['relatedInformation'] = (related as List).map<Object?>((info) {
      final infoMap = info as Map<String, Object?>;
      final loc = infoMap['location'] as Map<String, Object?>;
      final locRange = _mapToRange(loc['range']);
      final ls = _rangeStart(locRange);
      final le = _rangeEnd(locRange);
      return <String, Object?>{
        'resource': parseUri(loc['uri'] as String),
        'startLineNumber': ls.line + 1,
        'startColumn': ls.character + 1,
        'endLineNumber': le.line + 1,
        'endColumn': le.character + 1,
        'message': infoMap['message'],
      };
    }).toList();
  }

  return marker;
}

/// Shared helper for features: LSP range Map carrier -> T.Range.
T.Range lspRangeFromMap(Object? value) => _mapToRange(value);

/// Shared helper for features: LSP position Map carrier -> T.Position.
T.Position lspPositionFromMap(Object? value) => _mapToPosition(value);

/// Helper: LSP range Map carrier `{start:{line,character}, end:{...}}` -> T.Range.
T.Range _mapToRange(Object? value) {
  final map = value as Map<String, Object?>;
  return LspRange(_mapToPosition(map['start']), _mapToPosition(map['end']));
}

T.Position _mapToPosition(Object? value) {
  final map = value as Map<String, Object?>;
  return LspPos((map['line'] as num).toInt(), (map['character'] as num).toInt());
}

T.Position _rangeStart(T.Range range) => range.start;
T.Position _rangeEnd(T.Range range) => range.end;
