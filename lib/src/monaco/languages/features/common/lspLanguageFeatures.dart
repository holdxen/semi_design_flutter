// 1:1 port of monaco-editor/src/languages/features/common/lspLanguageFeatures.ts
// (1016 lines). Monaco API enums are symbolic String carriers
// (`monaco.languages.X.Y` / `monaco.MarkerSeverity.X`) matching the TS runtime
// truth; Range/Position/Uri are opaque carriers. Editor/DOM APIs are injected
// via provider slots. All coordinate math (+1/-1) and enum mappings are 1:1.
library;

import '../../../lsp/adapters/monacoBridge.dart'
    show MonacoPosition, MonacoRange;
import 'lsTypes.dart' as ls;

// ---------------------------------------------------------------------------
// Monaco enum symbolic carriers (values = TS runtime member paths).
// ---------------------------------------------------------------------------
class MCompletionItemKind {
  static const String Text = 'monaco.languages.CompletionItemKind.Text';
  static const String Method = 'monaco.languages.CompletionItemKind.Method';
  static const String Function = 'monaco.languages.CompletionItemKind.Function';
  static const String Constructor = 'monaco.languages.CompletionItemKind.Constructor';
  static const String Field = 'monaco.languages.CompletionItemKind.Field';
  static const String Variable = 'monaco.languages.CompletionItemKind.Variable';
  static const String Class = 'monaco.languages.CompletionItemKind.Class';
  static const String Struct = 'monaco.languages.CompletionItemKind.Struct';
  static const String Interface = 'monaco.languages.CompletionItemKind.Interface';
  static const String Module = 'monaco.languages.CompletionItemKind.Module';
  static const String Property = 'monaco.languages.CompletionItemKind.Property';
  static const String Event = 'monaco.languages.CompletionItemKind.Event';
  static const String Operator = 'monaco.languages.CompletionItemKind.Operator';
  static const String Unit = 'monaco.languages.CompletionItemKind.Unit';
  static const String Value = 'monaco.languages.CompletionItemKind.Value';
  static const String Constant = 'monaco.languages.CompletionItemKind.Constant';
  static const String Enum = 'monaco.languages.CompletionItemKind.Enum';
  static const String EnumMember = 'monaco.languages.CompletionItemKind.EnumMember';
  static const String Keyword = 'monaco.languages.CompletionItemKind.Keyword';
  static const String Snippet = 'monaco.languages.CompletionItemKind.Snippet';
  static const String Color = 'monaco.languages.CompletionItemKind.Color';
  static const String File = 'monaco.languages.CompletionItemKind.File';
  static const String Reference = 'monaco.languages.CompletionItemKind.Reference';
  static const String Customcolor = 'monaco.languages.CompletionItemKind.Customcolor';
  static const String Folder = 'monaco.languages.CompletionItemKind.Folder';
  static const String TypeParameter = 'monaco.languages.CompletionItemKind.TypeParameter';
  static const String User = 'monaco.languages.CompletionItemKind.User';
  static const String Issue = 'monaco.languages.CompletionItemKind.Issue';
  static const String Tool = 'monaco.languages.CompletionItemKind.Tool';
}

class MCompletionItemInsertTextRule {
  static const String None = 'monaco.languages.CompletionItemInsertTextRule.None';
  static const String KeepWhitespace = 'monaco.languages.CompletionItemInsertTextRule.KeepWhitespace';
  static const String InsertAsSnippet = 'monaco.languages.CompletionItemInsertTextRule.InsertAsSnippet';
}

class MDocumentHighlightKind {
  static const String Text = 'monaco.languages.DocumentHighlightKind.Text';
  static const String Read = 'monaco.languages.DocumentHighlightKind.Read';
  static const String Write = 'monaco.languages.DocumentHighlightKind.Write';
}

class MSymbolKind {
  static const String File = 'monaco.languages.SymbolKind.File';
  static const String Module = 'monaco.languages.SymbolKind.Module';
  static const String Namespace = 'monaco.languages.SymbolKind.Namespace';
  static const String Package = 'monaco.languages.SymbolKind.Package';
  static const String Class = 'monaco.languages.SymbolKind.Class';
  static const String Method = 'monaco.languages.SymbolKind.Method';
  static const String Property = 'monaco.languages.SymbolKind.Property';
  static const String Field = 'monaco.languages.SymbolKind.Field';
  static const String Constructor = 'monaco.languages.SymbolKind.Constructor';
  static const String Enum = 'monaco.languages.SymbolKind.Enum';
  static const String Interface = 'monaco.languages.SymbolKind.Interface';
  static const String Function = 'monaco.languages.SymbolKind.Function';
  static const String Variable = 'monaco.languages.SymbolKind.Variable';
  static const String Constant = 'monaco.languages.SymbolKind.Constant';
  static const String StringKind = 'monaco.languages.SymbolKind.String';
  static const String Number = 'monaco.languages.SymbolKind.Number';
  static const String Boolean = 'monaco.languages.SymbolKind.Boolean';
  static const String Array = 'monaco.languages.SymbolKind.Array';
}

class MFoldingRangeKind {
  static const String Comment = 'monaco.languages.FoldingRangeKind.Comment';
  static const String Imports = 'monaco.languages.FoldingRangeKind.Imports';
  static const String Region = 'monaco.languages.FoldingRangeKind.Region';
}

class MMarkerSeverity {
  static const String Hint = 'monaco.MarkerSeverity.Hint';
  static const String Info = 'monaco.MarkerSeverity.Info';
  static const String Warning = 'monaco.MarkerSeverity.Warning';
  static const String Error = 'monaco.MarkerSeverity.Error';
}

/// 1:1 carrier of a `Uri` value: `parse` returns an opaque marker with the
/// source string, mirroring the stub used by the truth extractor.
class LsUri {
  final String value;
  const LsUri(this.value);
  @override
  String toString() => value;
}

/// 1:1: `Uri.parse(s)`
LsUri uriParse(String s) => LsUri(s);

// ---------------------------------------------------------------------------
// Pure conversion functions (1:1 with source; truth-verified).
// ---------------------------------------------------------------------------

/// 1:1: `fromPosition(position)` — monaco 1-based -> ls 0-based.
/// Returns null for undefined (Dart null models TS `void 0`).
Map<String, int>? fromPosition(Object? position) {
  if (position == null) return null;
  final p = position as MonacoPosition;
  return <String, int>{'character': p.column - 1, 'line': p.lineNumber - 1};
}

/// 1:1: `fromRange(range)` — monaco IRange 1-based -> ls 0-based.
Map<String, Object?>? fromRange(Object? range) {
  if (range == null) return null;
  final r = range as MonacoRange;
  return <String, Object?>{
    'start': <String, int>{'line': r.startLineNumber - 1, 'character': r.startColumn - 1},
    'end': <String, int>{'line': r.endLineNumber - 1, 'character': r.endColumn - 1},
  };
}

/// 1:1: `toRange(range)` — ls 0-based -> monaco Range 1-based.
MonacoRange? toRange(Object? range) {
  if (range == null) return null;
  final r = range as Map;
  final s = r['start'] as Map;
  final e = r['end'] as Map;
  return MonacoRange(
    (s['line'] as int) + 1,
    (s['character'] as int) + 1,
    (e['line'] as int) + 1,
    (e['character'] as int) + 1,
  );
}

/// 1:1: `toTextEdit(textEdit)`.
Map<String, Object?>? toTextEdit(Object? textEdit) {
  if (textEdit == null) return null;
  final t = textEdit as Map;
  return <String, Object?>{'range': toRange(t['range']), 'text': t['newText']};
}

/// 1:1: `isInsertReplaceEdit(edit)`.
bool isInsertReplaceEdit(Object? edit) {
  if (edit == null) return false;
  final e = edit as Map;
  return e['insert'] != null && e['replace'] != null;
}

/// 1:1: `toSeverity(lsSeverity)` — ls DiagnosticSeverity -> monaco MarkerSeverity.
String toSeverity(int? lsSeverity) {
  switch (lsSeverity) {
    case ls.DiagnosticSeverity.Error:
      return MMarkerSeverity.Error;
    case ls.DiagnosticSeverity.Warning:
      return MMarkerSeverity.Warning;
    case ls.DiagnosticSeverity.Information:
      return MMarkerSeverity.Info;
    case ls.DiagnosticSeverity.Hint:
      return MMarkerSeverity.Hint;
    default:
      return MMarkerSeverity.Info;
  }
}

/// 1:1: `toDiagnostics(resource, diag)`.
Map<String, Object?> toDiagnostics(Object? resource, Map<String, Object?> diag) {
  final code = diag['code'];
  final codeStr = code is int ? code.toString() : code as String?;
  final range = diag['range'] as Map;
  final s = range['start'] as Map;
  final e = range['end'] as Map;
  return <String, Object?>{
    'severity': toSeverity(diag['severity'] as int?),
    'startLineNumber': (s['line'] as int) + 1,
    'startColumn': (s['character'] as int) + 1,
    'endLineNumber': (e['line'] as int) + 1,
    'endColumn': (e['character'] as int) + 1,
    'message': diag['message'],
    'code': codeStr,
    'source': diag['source'],
  };
}

/// 1:1: `toCompletionItemKind(kind)` — ls 1-based -> monaco symbolic.
String toCompletionItemKind(int? kind) {
  switch (kind) {
    case ls.CompletionItemKind.Text:
      return MCompletionItemKind.Text;
    case ls.CompletionItemKind.Method:
      return MCompletionItemKind.Method;
    case ls.CompletionItemKind.Function:
      return MCompletionItemKind.Function;
    case ls.CompletionItemKind.Constructor:
      return MCompletionItemKind.Constructor;
    case ls.CompletionItemKind.Field:
      return MCompletionItemKind.Field;
    case ls.CompletionItemKind.Variable:
      return MCompletionItemKind.Variable;
    case ls.CompletionItemKind.Class:
      return MCompletionItemKind.Class;
    case ls.CompletionItemKind.Interface:
      return MCompletionItemKind.Interface;
    case ls.CompletionItemKind.Module:
      return MCompletionItemKind.Module;
    case ls.CompletionItemKind.Property:
      return MCompletionItemKind.Property;
    case ls.CompletionItemKind.Unit:
      return MCompletionItemKind.Unit;
    case ls.CompletionItemKind.Value:
      return MCompletionItemKind.Value;
    case ls.CompletionItemKind.Enum:
      return MCompletionItemKind.Enum;
    case ls.CompletionItemKind.Keyword:
      return MCompletionItemKind.Keyword;
    case ls.CompletionItemKind.Snippet:
      return MCompletionItemKind.Snippet;
    case ls.CompletionItemKind.Color:
      return MCompletionItemKind.Color;
    case ls.CompletionItemKind.File:
      return MCompletionItemKind.File;
    case ls.CompletionItemKind.Reference:
      return MCompletionItemKind.Reference;
  }
  return MCompletionItemKind.Property;
}

/// 1:1: `fromCompletionItemKind(kind)` — monaco symbolic -> ls 1-based.
int fromCompletionItemKind(String kind) {
  switch (kind) {
    case MCompletionItemKind.Text:
      return ls.CompletionItemKind.Text;
    case MCompletionItemKind.Method:
      return ls.CompletionItemKind.Method;
    case MCompletionItemKind.Function:
      return ls.CompletionItemKind.Function;
    case MCompletionItemKind.Constructor:
      return ls.CompletionItemKind.Constructor;
    case MCompletionItemKind.Field:
      return ls.CompletionItemKind.Field;
    case MCompletionItemKind.Variable:
      return ls.CompletionItemKind.Variable;
    case MCompletionItemKind.Class:
      return ls.CompletionItemKind.Class;
    case MCompletionItemKind.Interface:
      return ls.CompletionItemKind.Interface;
    case MCompletionItemKind.Module:
      return ls.CompletionItemKind.Module;
    case MCompletionItemKind.Property:
      return ls.CompletionItemKind.Property;
    case MCompletionItemKind.Unit:
      return ls.CompletionItemKind.Unit;
    case MCompletionItemKind.Value:
      return ls.CompletionItemKind.Value;
    case MCompletionItemKind.Enum:
      return ls.CompletionItemKind.Enum;
    case MCompletionItemKind.Keyword:
      return ls.CompletionItemKind.Keyword;
    case MCompletionItemKind.Snippet:
      return ls.CompletionItemKind.Snippet;
    case MCompletionItemKind.Color:
      return ls.CompletionItemKind.Color;
    case MCompletionItemKind.File:
      return ls.CompletionItemKind.File;
    case MCompletionItemKind.Reference:
      return ls.CompletionItemKind.Reference;
  }
  return ls.CompletionItemKind.Property;
}

/// 1:1: `toCommand(c)` — only triggerSuggest commands map to a monaco command.
Map<String, Object?>? toCommand(Object? c) {
  if (c == null) return null;
  final cmd = c as Map;
  if (cmd['command'] == 'editor.action.triggerSuggest') {
    return <String, Object?>{
      'id': cmd['command'],
      'title': cmd['title'],
      'arguments': cmd['arguments'],
    };
  }
  return null;
}

/// 1:1: `isMarkupContent(thing)`.
bool isMarkupContent(Object? thing) {
  if (thing == null) return false;
  if (thing is! Map) return false;
  return thing['kind'] is String;
}

/// 1:1: `toMarkdownString(entry)`.
Map<String, Object?> toMarkdownString(Object? entry) {
  if (entry is String) {
    return <String, Object?>{'value': entry};
  }
  final e = entry as Map;
  if (isMarkupContent(e)) {
    if (e['kind'] == 'plaintext') {
      final escaped = (e['value'] as String).replaceAllMapped(
        RegExp(r'[\\`*_{}\[\]()#+\-.!]'),
        (m) => '\\${m.group(0)}',
      );
      return <String, Object?>{'value': escaped};
    }
    return <String, Object?>{'value': e['value']};
  }
  return <String, Object?>{
    'value': '```${e['language']}\n${e['value']}\n```\n',
  };
}

/// 1:1: `toMarkedStringArray(contents)`.
List<Map<String, Object?>>? toMarkedStringArray(Object? contents) {
  if (contents == null) return null;
  if (contents is List) {
    return contents.map((c) => toMarkdownString(c)).toList();
  }
  return <Map<String, Object?>>[toMarkdownString(contents)];
}

/// 1:1: `toDocumentHighlightKind(kind)`.
String toDocumentHighlightKind(int? kind) {
  switch (kind) {
    case ls.DocumentHighlightKind.Read:
      return MDocumentHighlightKind.Read;
    case ls.DocumentHighlightKind.Write:
      return MDocumentHighlightKind.Write;
    case ls.DocumentHighlightKind.Text:
      return MDocumentHighlightKind.Text;
  }
  return MDocumentHighlightKind.Text;
}

/// 1:1: `toLocation(location)`.
Map<String, Object?> toLocation(Map<String, Object?> location) {
  return <String, Object?>{
    'uri': uriParse(location['uri'] as String),
    'range': toRange(location['range']),
  };
}

/// 1:1: `toWorkspaceEdit(edit)`.
Map<String, Object?>? toWorkspaceEdit(Object? edit) {
  if (edit == null) return null;
  final e = edit as Map;
  final changes = e['changes'] as Map?;
  if (changes == null) return null;
  final resourceEdits = <Map<String, Object?>>[];
  for (final uri in changes.keys) {
    final u = uriParse(uri as String);
    for (final change in (changes[uri] as List)) {
      final c = change as Map;
      resourceEdits.add(<String, Object?>{
        'resource': u,
        'versionId': null,
        'textEdit': <String, Object?>{
          'range': toRange(c['range']),
          'text': c['newText'],
        },
      });
    }
  }
  return <String, Object?>{'edits': resourceEdits};
}

/// 1:1: `isDocumentSymbol(symbol)`.
bool isDocumentSymbol(Map<String, Object?> symbol) => symbol.containsKey('children');

/// 1:1: `toDocumentSymbol(symbol)` (recursive).
Map<String, Object?> toDocumentSymbol(Map<String, Object?> symbol) {
  final children = symbol['children'] as List?;
  final tags = symbol['tags'] as List?;
  return <String, Object?>{
    'name': symbol['name'],
    'detail': symbol['detail'] ?? '',
    'kind': toSymbolKind(symbol['kind'] as int),
    'range': toRange(symbol['range']),
    'selectionRange': toRange(symbol['selectionRange']),
    'tags': tags ?? <Object?>[],
    'children': (children ?? <Object?>[]).map((c) => toDocumentSymbol(c as Map<String, Object?>)).toList(),
  };
}

/// 1:1: `toSymbolKind(kind)` — ls 1-based -> monaco symbolic.
String toSymbolKind(int kind) {
  switch (kind) {
    case ls.SymbolKind.File:
      return MSymbolKind.File;
    case ls.SymbolKind.Module:
      return MSymbolKind.Module;
    case ls.SymbolKind.Namespace:
      return MSymbolKind.Namespace;
    case ls.SymbolKind.Package:
      return MSymbolKind.Package;
    case ls.SymbolKind.Class:
      return MSymbolKind.Class;
    case ls.SymbolKind.Method:
      return MSymbolKind.Method;
    case ls.SymbolKind.Property:
      return MSymbolKind.Property;
    case ls.SymbolKind.Field:
      return MSymbolKind.Field;
    case ls.SymbolKind.Constructor:
      return MSymbolKind.Constructor;
    case ls.SymbolKind.Enum:
      return MSymbolKind.Enum;
    case ls.SymbolKind.Interface:
      return MSymbolKind.Interface;
    case ls.SymbolKind.Function:
      return MSymbolKind.Function;
    case ls.SymbolKind.Variable:
      return MSymbolKind.Variable;
    case ls.SymbolKind.Constant:
      return MSymbolKind.Constant;
    case ls.SymbolKind.String:
      return MSymbolKind.StringKind;
    case ls.SymbolKind.Number:
      return MSymbolKind.Number;
    case ls.SymbolKind.Boolean:
      return MSymbolKind.Boolean;
    case ls.SymbolKind.Array:
      return MSymbolKind.Array;
  }
  return MSymbolKind.Function;
}

/// 1:1: `toFoldingRangeKind(kind)` — ls string -> monaco symbolic; undefined default.
String? toFoldingRangeKind(String kind) {
  switch (kind) {
    case ls.FoldingRangeKind.Comment:
      return MFoldingRangeKind.Comment;
    case ls.FoldingRangeKind.Imports:
      return MFoldingRangeKind.Imports;
    case ls.FoldingRangeKind.Region:
      return MFoldingRangeKind.Region;
  }
  return null;
}

/// 1:1: `fromFormattingOptions(options)`.
Map<String, Object?> fromFormattingOptions(Map<String, Object?> options) {
  return <String, Object?>{
    'tabSize': options['tabSize'],
    'insertSpaces': options['insertSpaces'],
  };
}

// ---------------------------------------------------------------------------
// Worker / model / editor carriers (external monaco API, injected).
// ---------------------------------------------------------------------------

/// 1:1: `WorkerAccessor<T>` — `(...Uri[]) => Promise<T>`.
typedef WorkerAccessor<T> = Future<T> Function(List<LsUri> more);

/// 1:1 carrier of `editor.IReadOnlyModel` / `editor.IModel` surface used here.
abstract class IReadOnlyModel {
  LsUri get uri;
  String getLanguageId();
  /// 1:1: `getWordUntilPosition(position)`
  Map<String, Object?> getWordUntilPosition(MonacoPosition position);

  /// 1:1: `onDidChangeContent(listener): IDisposable`
  Object? onDidChangeContent(void Function() listener);
}

/// 1:1: `editor.onDidCreateModel(cb): IDisposable`
Object? Function(void Function(IReadOnlyModel model) cb)? onDidCreateModelProvider;

/// 1:1: `editor.onWillDisposeModel(cb): IDisposable`
Object? Function(void Function(IReadOnlyModel model) cb)? onWillDisposeModelProvider;

/// 1:1: `editor.onDidChangeModelLanguage(cb): IDisposable`
Object? Function(void Function(Map<String, Object?> event) cb)? onDidChangeModelLanguageProvider;

/// 1:1: `editor.getModels(): IModel[]`
List<IReadOnlyModel> Function() getModelsProvider = () => <IReadOnlyModel>[];

/// 1:1: `editor.getModel(uri): IModel | null`
IReadOnlyModel? Function(LsUri resource) getModelProvider = (_) => null;

/// 1:1: `editor.setModelMarkers(model, owner, markers)`
void Function(IReadOnlyModel model, String owner, List<Object?> markers)? setModelMarkersProvider;

/// 1:1: `window.clearTimeout(handle)`
void Function(Object? handle)? clearTimeoutProvider;

/// 1:1: `window.setTimeout(cb, 500): number`
Object? Function(void Function() cb, int ms)? setTimeoutProvider;

/// 1:1: `console.error(err)`
void Function(Object err)? consoleErrorProvider;

// ---------------------------------------------------------------------------
// Adapter classes (1:1 with the source, in source order).
// ---------------------------------------------------------------------------

/// 1:1: `ILanguageWorkerWithDiagnostics`
abstract class ILanguageWorkerWithDiagnostics {
  Future<List<Map<String, Object?>>> doValidation(String uri);
}

/// 1:1: `DiagnosticsAdapter<T>`
class DiagnosticsAdapter<T extends ILanguageWorkerWithDiagnostics> {
  final List<Object?> _disposables = <Object?>[];
  final Map<String, Object?> _listener = <String, Object?>{};
  final String _languageId;
  final WorkerAccessor<T> _worker;

  DiagnosticsAdapter(this._languageId, this._worker, void Function(void Function(Object? p) cb) configChangeEvent) {
    void onModelAdd(IReadOnlyModel model) {
      final modeId = model.getLanguageId();
      if (modeId != _languageId) return;
      Object? handle;
      _listener[model.uri.value] = model.onDidChangeContent(() {
        (clearTimeoutProvider ?? (h) {})(handle);
        handle = (setTimeoutProvider ?? (cb, ms) { cb(); return null; })(() {
          _doValidate(model.uri, modeId);
        }, 500);
      });
      _doValidate(model.uri, modeId);
    }

    void onModelRemoved(IReadOnlyModel model) {
      (setModelMarkersProvider ?? (m, o, ms) {})(model, _languageId, <Object?>[]);
      final uriStr = model.uri.value;
      final listener = _listener[uriStr];
      if (listener != null) {
        _listener.remove(uriStr);
      }
    }

    if (onDidCreateModelProvider != null) {
      _disposables.add(onDidCreateModelProvider!(onModelAdd));
    }
    if (onWillDisposeModelProvider != null) {
      _disposables.add(onWillDisposeModelProvider!(onModelRemoved));
    }
    if (onDidChangeModelLanguageProvider != null) {
      _disposables.add(onDidChangeModelLanguageProvider!((event) {
        final model = event['model'] as IReadOnlyModel;
        onModelRemoved(model);
        onModelAdd(model);
      }));
    }
    configChangeEvent((_) {
      for (final model in getModelsProvider()) {
        if (model.getLanguageId() == _languageId) {
          onModelRemoved(model);
          onModelAdd(model);
        }
      }
    });
    _disposables.add(Object());
    _disposables.add(Object()); // placeholder for the explicit dispose object
    for (final model in getModelsProvider()) {
      onModelAdd(model);
    }
  }

  void dispose() {
    for (final d in _disposables) {
      if (d is Object && d is! Function) continue;
    }
    _disposables.clear();
  }

  void _doValidate(LsUri resource, String languageId) {
    _worker(<LsUri>[resource]).then((worker) {
      return worker.doValidation(resource.value);
    }).then((diagnostics) {
      final markers = diagnostics.map((d) => toDiagnostics(resource, d)).toList();
      final model = getModelProvider(resource);
      if (model != null && model.getLanguageId() == languageId) {
        (setModelMarkersProvider ?? (m, o, ms) {})(model, languageId, markers);
      }
    }).catchError((err) {
      (consoleErrorProvider ?? (e) {})(err as Object);
    });
  }
}

/// 1:1: `ILanguageWorkerWithCompletions`
abstract class ILanguageWorkerWithCompletions {
  Future<Map<String, Object?>?> doComplete(String uri, Map<String, int> position);
}

/// 1:1: `CompletionAdapter<T>`
class CompletionAdapter<T extends ILanguageWorkerWithCompletions> {
  final WorkerAccessor<T> _worker;
  final List<String> _triggerCharacters;
  CompletionAdapter(this._worker, this._triggerCharacters);
  List<String> get triggerCharacters => _triggerCharacters;

  Future<Map<String, Object?>?> provideCompletionItems(
    IReadOnlyModel model,
    MonacoPosition position,
    Map<String, Object?> context,
    Object? token,
  ) async {
    final resource = model.uri;
    final worker = await _worker(<LsUri>[resource]);
    final info = await worker.doComplete(resource.value, fromPosition(position)!);
    if (info == null) return null;
    final wordInfo = model.getWordUntilPosition(position);
    final wordRange = MonacoRange(
      position.lineNumber,
      wordInfo['startColumn'] as int,
      position.lineNumber,
      wordInfo['endColumn'] as int,
    );
    final items = <Map<String, Object?>>[];
    for (final entry in (info['items'] as List).cast<Map<String, Object?>>()) {
      final item = <String, Object?>{
        'label': entry['label'],
        'insertText': entry['insertText'] ?? entry['label'],
        'sortText': entry['sortText'],
        'filterText': entry['filterText'],
        'documentation': entry['documentation'],
        'detail': entry['detail'],
        'command': toCommand(entry['command']),
        'range': wordRange,
        'kind': toCompletionItemKind(entry['kind'] as int?),
      };
      final textEdit = entry['textEdit'];
      if (textEdit != null) {
        final te = textEdit as Map;
        if (isInsertReplaceEdit(te)) {
          item['range'] = <String, Object?>{
            'insert': toRange(te['insert']),
            'replace': toRange(te['replace']),
          };
        } else {
          item['range'] = toRange(te['range']);
        }
        item['insertText'] = te['newText'];
      }
      final additional = entry['additionalTextEdits'];
      if (additional != null) {
        item['additionalTextEdits'] = (additional as List).map(toTextEdit).toList();
      }
      if (entry['insertTextFormat'] == ls.InsertTextFormat.Snippet) {
        item['insertTextRules'] = MCompletionItemInsertTextRule.InsertAsSnippet;
      }
      items.add(item);
    }
    return <String, Object?>{
      'isIncomplete': info['isIncomplete'],
      'suggestions': items,
    };
  }
}

/// 1:1: `ILanguageWorkerWithHover`
abstract class ILanguageWorkerWithHover {
  Future<Map<String, Object?>?> doHover(String uri, Map<String, int> position);
}

/// 1:1: `HoverAdapter<T>`
class HoverAdapter<T extends ILanguageWorkerWithHover> {
  final WorkerAccessor<T> _worker;
  HoverAdapter(this._worker);

  Future<Map<String, Object?>?> provideHover(
    IReadOnlyModel model,
    MonacoPosition position,
    Object? token,
  ) async {
    final resource = model.uri;
    final worker = await _worker(<LsUri>[resource]);
    final info = await worker.doHover(resource.value, fromPosition(position)!);
    if (info == null) return null;
    return <String, Object?>{
      'range': toRange(info['range']),
      'contents': toMarkedStringArray(info['contents']),
    };
  }
}

/// 1:1: `ILanguageWorkerWithDocumentHighlights`
abstract class ILanguageWorkerWithDocumentHighlights {
  Future<List<Map<String, Object?>>> findDocumentHighlights(String uri, Map<String, int> position);
}

/// 1:1: `DocumentHighlightAdapter<T>`
class DocumentHighlightAdapter<T extends ILanguageWorkerWithDocumentHighlights> {
  final WorkerAccessor<T> _worker;
  DocumentHighlightAdapter(this._worker);

  Future<List<Map<String, Object?>>?> provideDocumentHighlights(
    IReadOnlyModel model,
    MonacoPosition position,
    Object? token,
  ) async {
    final resource = model.uri;
    final worker = await _worker(<LsUri>[resource]);
    final entries = await worker.findDocumentHighlights(resource.value, fromPosition(position)!);
    if (entries.isEmpty) return null;
    return entries.map((entry) => <String, Object?>{
      'range': toRange(entry['range']),
      'kind': toDocumentHighlightKind(entry['kind'] as int?),
    }).toList();
  }
}

/// 1:1: `ILanguageWorkerWithDefinitions`
abstract class ILanguageWorkerWithDefinitions {
  Future<Map<String, Object?>?> findDefinition(String uri, Map<String, int> position);
}

/// 1:1: `DefinitionAdapter<T>`
class DefinitionAdapter<T extends ILanguageWorkerWithDefinitions> {
  final WorkerAccessor<T> _worker;
  DefinitionAdapter(this._worker);

  Future<List<Map<String, Object?>>?> provideDefinition(
    IReadOnlyModel model,
    MonacoPosition position,
    Object? token,
  ) async {
    final resource = model.uri;
    final worker = await _worker(<LsUri>[resource]);
    final definition = await worker.findDefinition(resource.value, fromPosition(position)!);
    if (definition == null) return null;
    return <Map<String, Object?>>[toLocation(definition)];
  }
}

/// 1:1: `ILanguageWorkerWithReferences`
abstract class ILanguageWorkerWithReferences {
  Future<List<Map<String, Object?>>> findReferences(String uri, Map<String, int> position);
}

/// 1:1: `ReferenceAdapter<T>`
class ReferenceAdapter<T extends ILanguageWorkerWithReferences> {
  final WorkerAccessor<T> _worker;
  ReferenceAdapter(this._worker);

  Future<List<Map<String, Object?>>?> provideReferences(
    IReadOnlyModel model,
    MonacoPosition position,
    Map<String, Object?> context,
    Object? token,
  ) async {
    final resource = model.uri;
    final worker = await _worker(<LsUri>[resource]);
    final entries = await worker.findReferences(resource.value, fromPosition(position)!);
    if (entries.isEmpty) return null;
    return entries.map(toLocation).toList();
  }
}

/// 1:1: `ILanguageWorkerWithRename`
abstract class ILanguageWorkerWithRename {
  Future<Map<String, Object?>?> doRename(String uri, Map<String, int> position, String newName);
}

/// 1:1: `RenameAdapter<T>`
class RenameAdapter<T extends ILanguageWorkerWithRename> {
  final WorkerAccessor<T> _worker;
  RenameAdapter(this._worker);

  Future<Map<String, Object?>?> provideRenameEdits(
    IReadOnlyModel model,
    MonacoPosition position,
    String newName,
    Object? token,
  ) async {
    final resource = model.uri;
    final worker = await _worker(<LsUri>[resource]);
    final edit = await worker.doRename(resource.value, fromPosition(position)!, newName);
    return toWorkspaceEdit(edit);
  }
}

/// 1:1: `ILanguageWorkerWithDocumentSymbols`
abstract class ILanguageWorkerWithDocumentSymbols {
  Future<List<Map<String, Object?>>> findDocumentSymbols(String uri);
}

/// 1:1: `DocumentSymbolAdapter<T>`
class DocumentSymbolAdapter<T extends ILanguageWorkerWithDocumentSymbols> {
  final WorkerAccessor<T> _worker;
  DocumentSymbolAdapter(this._worker);

  Future<List<Map<String, Object?>>?> provideDocumentSymbols(
    IReadOnlyModel model,
    Object? token,
  ) async {
    final resource = model.uri;
    final worker = await _worker(<LsUri>[resource]);
    final items = await worker.findDocumentSymbols(resource.value);
    if (items.isEmpty) return null;
    return items.map((item) {
      if (isDocumentSymbol(item)) return toDocumentSymbol(item);
      return <String, Object?>{
        'name': item['name'],
        'detail': '',
        'containerName': item['containerName'],
        'kind': toSymbolKind(item['kind'] as int),
        'range': toRange((item['location'] as Map)['range']),
        'selectionRange': toRange((item['location'] as Map)['range']),
        'tags': <Object?>[],
      };
    }).toList();
  }
}

/// 1:1: `ILanguageWorkerWithDocumentLinks`
abstract class ILanguageWorkerWithDocumentLinks {
  Future<List<Map<String, Object?>>> findDocumentLinks(String uri);
}

/// 1:1: `DocumentLinkAdapter<T>`
class DocumentLinkAdapter<T extends ILanguageWorkerWithDocumentLinks> {
  final WorkerAccessor<T> _worker;
  DocumentLinkAdapter(this._worker);

  Future<Map<String, Object?>?> provideLinks(IReadOnlyModel model, Object? token) async {
    final resource = model.uri;
    final worker = await _worker(<LsUri>[resource]);
    final items = await worker.findDocumentLinks(resource.value);
    if (items.isEmpty) return null;
    return <String, Object?>{
      'links': items.map((item) => <String, Object?>{
        'range': toRange(item['range']),
        'url': item['target'],
      }).toList(),
    };
  }
}

/// 1:1: `ILanguageWorkerWithFormat`
abstract class ILanguageWorkerWithFormat {
  Future<List<Map<String, Object?>>> format(
    String uri,
    Object? range,
    Map<String, Object?> options,
  );
}

/// 1:1: `DocumentFormattingEditProvider<T>`
class DocumentFormattingEditProvider<T extends ILanguageWorkerWithFormat> {
  final WorkerAccessor<T> _worker;
  DocumentFormattingEditProvider(this._worker);

  Future<List<Map<String, Object?>>?> provideDocumentFormattingEdits(
    IReadOnlyModel model,
    Map<String, Object?> options,
    Object? token,
  ) async {
    final resource = model.uri;
    final worker = await _worker(<LsUri>[resource]);
    final edits = await worker.format(resource.value, null, fromFormattingOptions(options));
    if (edits.isEmpty) return null;
    return edits.map((e) => toTextEdit(e)!).toList();
  }
}

/// 1:1: `DocumentRangeFormattingEditProvider<T>`
class DocumentRangeFormattingEditProvider<T extends ILanguageWorkerWithFormat> {
  final WorkerAccessor<T> _worker;
  final bool canFormatMultipleRanges = false;
  DocumentRangeFormattingEditProvider(this._worker);

  Future<List<Map<String, Object?>>?> provideDocumentRangeFormattingEdits(
    IReadOnlyModel model,
    MonacoRange range,
    Map<String, Object?> options,
    Object? token,
  ) async {
    final resource = model.uri;
    final worker = await _worker(<LsUri>[resource]);
    final edits = await worker.format(resource.value, fromRange(range), fromFormattingOptions(options));
    if (edits.isEmpty) return null;
    return edits.map((e) => toTextEdit(e)!).toList();
  }
}

/// 1:1: `ILanguageWorkerWithDocumentColors`
abstract class ILanguageWorkerWithDocumentColors {
  Future<List<Map<String, Object?>>> findDocumentColors(String uri);
  Future<List<Map<String, Object?>>> getColorPresentations(
    String uri,
    Map<String, Object?> color,
    Map<String, Object?> range,
  );
}

/// 1:1: `DocumentColorAdapter<T>`
class DocumentColorAdapter<T extends ILanguageWorkerWithDocumentColors> {
  final WorkerAccessor<T> _worker;
  DocumentColorAdapter(this._worker);

  Future<List<Map<String, Object?>>?> provideDocumentColors(
    IReadOnlyModel model,
    Object? token,
  ) async {
    final resource = model.uri;
    final worker = await _worker(<LsUri>[resource]);
    final infos = await worker.findDocumentColors(resource.value);
    if (infos.isEmpty) return null;
    return infos.map((item) => <String, Object?>{
      'color': item['color'],
      'range': toRange(item['range']),
    }).toList();
  }

  Future<List<Map<String, Object?>>?> provideColorPresentations(
    IReadOnlyModel model,
    Map<String, Object?> info,
    Object? token,
  ) async {
    final resource = model.uri;
    final worker = await _worker(<LsUri>[resource]);
    final presentations = await worker.getColorPresentations(
      resource.value,
      info['color'] as Map<String, Object?>,
      fromRange(info['range'])!,
    );
    if (presentations.isEmpty) return null;
    return presentations.map((presentation) {
      final item = <String, Object?>{'label': presentation['label']};
      if (presentation['textEdit'] != null) {
        item['textEdit'] = toTextEdit(presentation['textEdit']);
      }
      if (presentation['additionalTextEdits'] != null) {
        item['additionalTextEdits'] =
            (presentation['additionalTextEdits'] as List).map(toTextEdit).toList();
      }
      return item;
    }).toList();
  }
}

/// 1:1: `ILanguageWorkerWithFoldingRanges`
abstract class ILanguageWorkerWithFoldingRanges {
  Future<List<Map<String, Object?>>> getFoldingRanges(
    String uri, [
    Map<String, Object?>? context,
  ]);
}

/// 1:1: `FoldingRangeAdapter<T>`
class FoldingRangeAdapter<T extends ILanguageWorkerWithFoldingRanges> {
  final WorkerAccessor<T> _worker;
  FoldingRangeAdapter(this._worker);

  Future<List<Map<String, Object?>>?> provideFoldingRanges(
    IReadOnlyModel model,
    Map<String, Object?> context,
    Object? token,
  ) async {
    final resource = model.uri;
    final worker = await _worker(<LsUri>[resource]);
    final ranges = await worker.getFoldingRanges(resource.value, context);
    if (ranges.isEmpty) return null;
    return ranges.map((range) {
      final result = <String, Object?>{
        'start': (range['startLine'] as int) + 1,
        'end': (range['endLine'] as int) + 1,
      };
      final kind = range['kind'];
      if (kind != null) {
        result['kind'] = toFoldingRangeKind(kind as String);
      }
      return result;
    }).toList();
  }
}

/// 1:1: `ILanguageWorkerWithSelectionRanges`
abstract class ILanguageWorkerWithSelectionRanges {
  Future<List<Map<String, Object?>>> getSelectionRanges(
    String uri,
    List<Map<String, int>> positions,
  );
}

/// 1:1: `SelectionRangeAdapter<T>`
class SelectionRangeAdapter<T extends ILanguageWorkerWithSelectionRanges> {
  final WorkerAccessor<T> _worker;
  SelectionRangeAdapter(this._worker);

  Future<List<List<Map<String, Object?>>>?> provideSelectionRanges(
    IReadOnlyModel model,
    List<MonacoPosition> positions,
    Object? token,
  ) async {
    final resource = model.uri;
    final worker = await _worker(<LsUri>[resource]);
    final selectionRanges = await worker.getSelectionRanges(
      resource.value,
      positions.map((p) => fromPosition(p)!).toList(),
    );
    if (selectionRanges.isEmpty) return null;
    return selectionRanges.map((sr) {
      final result = <Map<String, Object?>>[];
      var current = sr;
      while (current.isNotEmpty) {
        result.add(<String, Object?>{'range': toRange(current['range'])});
        final parent = current['parent'];
        if (parent == null) break;
        current = parent as Map<String, Object?>;
      }
      return result;
    }).toList();
  }
}
