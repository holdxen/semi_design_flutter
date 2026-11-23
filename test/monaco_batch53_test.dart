// batch53 truth test: lspLanguageFeatures pure conversion functions + adapters.
// Truth extracted from the real TS via _lsp_lf_truth.cjs (Node + real
// vscode-languageserver-types + symbolic monaco stub).
import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:semi_design_flutter/src/monaco/languages/features/common/lspLanguageFeatures.dart';
import 'package:semi_design_flutter/src/monaco/languages/features/common/lsTypes.dart' as ls;
import 'package:semi_design_flutter/src/monaco/lsp/adapters/monacoBridge.dart'
    show MonacoPosition, MonacoRange;

Map<String, dynamic> _truth() => jsonDecode(
      File('tool/ts2dart/lsp_lf_truth.json').readAsStringSync(),
    ) as Map<String, dynamic>;

/// Normalize a Dart Range to the truth JSON shape (fields only).
Map<String, Object?> _rangeMapNoKind(MonacoRange r) => <String, Object?>{
      'startLineNumber': r.startLineNumber,
      'startColumn': r.startColumn,
      'endLineNumber': r.endLineNumber,
      'endColumn': r.endColumn,
    };

Map<String, Object?> _rangeMap(MonacoRange r) => <String, Object?>{
      'startLineNumber': r.startLineNumber,
      'startColumn': r.startColumn,
      'endLineNumber': r.endLineNumber,
      'endColumn': r.endColumn,
      '__kind': 'Range',
    };

void main() {
  final t = _truth();

  test('T1: fromPosition / fromRange / toRange / toTextEdit', () {
    for (final c in (t['fromPosition'] as List)) {
      final inp = c['in'];
      if (inp == null) {
        expect(fromPosition(null), isNull);
        continue;
      }
      final m = inp as Map;
      final out = fromPosition(MonacoPosition(m['lineNumber'], m['column']));
      expect(out, c['out'], reason: 'fromPosition $m');
    }

    for (final c in (t['fromRange'] as List)) {
      final inp = c['in'];
      if (inp == null) {
        expect(fromRange(null), isNull);
        continue;
      }
      final m = inp as Map;
      final out = fromRange(MonacoRange(m['startLineNumber'], m['startColumn'], m['endLineNumber'], m['endColumn']));
      expect(out, c['out'], reason: 'fromRange $m');
    }

    final toRangeTruth = (t['toRange'] as List);
    final rIn = toRangeTruth[0]['in'] as Map;
    expect(_rangeMapNoKind(toRange(rIn)!), toRangeTruth[0]['out']);
    expect(toRange(null), isNull);

    final teTruth = (t['toTextEdit'] as List);
    final teIn = teTruth[0]['in'] as Map;
    final teOut = toTextEdit(teIn)!;
    expect(_rangeMap(teOut['range'] as MonacoRange), (teTruth[0]['out'] as Map)['range']);
    expect(teOut['text'], (teTruth[0]['out'] as Map)['text']);
    expect(toTextEdit(null), isNull);
  });

  test('T2: toCompletionItemKind (all ls values + default)', () {
    final map = (t['toCompletionItemKind'] as Map).cast<String, dynamic>();
    for (final entry in map.entries) {
      expect(toCompletionItemKind(int.parse(entry.key)), entry.value,
          reason: 'ls kind ${entry.key}');
    }
    expect(toCompletionItemKind(null), t['toCompletionItemKind_default']);
    expect(toCompletionItemKind(9999), t['toCompletionItemKind_default']);
  });

  test('T3: fromCompletionItemKind (monaco -> ls)', () {
    final map = (t['fromCompletionItemKind'] as Map).cast<String, dynamic>();
    for (final entry in map.entries) {
      expect(fromCompletionItemKind(entry.key), entry.value, reason: entry.key);
    }
    expect(fromCompletionItemKind('monaco.languages.CompletionItemKind.Unknown'),
        t['fromCompletionItemKind_default']);
  });

  test('T4: toSeverity / toDiagnostics', () {
    final map = (t['toSeverity'] as Map).cast<String, dynamic>();
    for (final entry in map.entries) {
      expect(toSeverity(int.parse(entry.key)), entry.value);
    }
    expect(toSeverity(null), t['toSeverity_default']);

    for (final c in (t['toDiagnostics'] as List)) {
      final out = toDiagnostics(null, (c['in'] as Map).cast<String, Object?>());
      expect(out, c['out'], reason: 'toDiagnostics ${c['in']}');
    }
  });

  test('T5: toCommand / markdown / highlight kind', () {
    for (final c in (t['toCommand'] as List)) {
      final inp = c['in'] == null ? null : (c['in'] as Map).cast<String, Object?>();
      final out = toCommand(inp);
      if ((c['out'] as Map)['__undefined'] == true) {
        expect(out, isNull);
      } else {
        expect(out, c['out']);
      }
    }
    for (final c in (t['toMarkdownString'] as List)) {
      expect(toMarkdownString(c['in']), c['out'], reason: 'markdown ${c['in']}');
    }
    for (final c in (t['toMarkedStringArray'] as List)) {
      final inp = c['in'];
      final out = inp == null ? null : toMarkedStringArray(inp);
      if (c['out'] is Map && (c['out'] as Map)['__undefined'] == true) {
        expect(out, isNull);
      } else {
        expect(out, c['out']);
      }
    }
    final map = (t['toDocumentHighlightKind'] as Map).cast<String, dynamic>();
    for (final entry in map.entries) {
      expect(toDocumentHighlightKind(int.parse(entry.key)), entry.value);
    }
    expect(toDocumentHighlightKind(999), t['toDocumentHighlightKind_default']);
  });

  test('T6: isInsertReplaceEdit / isMarkupContent / isDocumentSymbol', () {
    for (final c in (t['isInsertReplaceEdit'] as List)) {
      expect(isInsertReplaceEdit(c['in']), c['out']);
    }
    for (final c in (t['isMarkupContent'] as List)) {
      expect(isMarkupContent(c['in']), c['out']);
    }
    for (final c in (t['isDocumentSymbol'] as List)) {
      expect(isDocumentSymbol((c['in'] as Map).cast<String, Object?>()), c['out']);
    }
  });

  test('T7: toLocation / toWorkspaceEdit (Uri + coordinate carriers)', () {
    final locIn = (t['toLocation'] as Map)['in'] as Map;
    final locOut = toLocation(locIn.cast<String, Object?>());
    final expectedLoc = (t['toLocation'] as Map)['out'] as Map;
    expect((locOut['uri'] as LsUri).value, (expectedLoc['uri'] as Map)['value']);
    expect(_rangeMap(locOut['range'] as MonacoRange), expectedLoc['range']);

    for (final c in (t['toWorkspaceEdit'] as List)) {
      final out = toWorkspaceEdit(c['in']);
      if ((c['out'] as Map)['__undefined'] == true) {
        expect(out, isNull);
        continue;
      }
      final edits = (out!['edits'] as List).cast<Map<String, Object?>>();
      final expEdits = ((c['out'] as Map)['edits'] as List).cast<Map>();
      expect(edits.length, expEdits.length);
      for (var i = 0; i < edits.length; i++) {
        expect((edits[i]['resource'] as LsUri).value,
            (expEdits[i]['resource'] as Map)['value']);
        expect(_rangeMap((edits[i]['textEdit'] as Map)['range'] as MonacoRange),
            (expEdits[i]['textEdit'] as Map)['range']);
        expect((edits[i]['textEdit'] as Map)['text'],
            (expEdits[i]['textEdit'] as Map)['text']);
      }
    }
  });

  test('T8: toDocumentSymbol / toSymbolKind / toFoldingRangeKind / fromFormattingOptions', () {
    final ds = (t['toDocumentSymbol'] as Map);
    final out = toDocumentSymbol((ds['in'] as Map).cast<String, Object?>());
    final exp = (ds['out'] as Map);
    expect(out['name'], exp['name']);
    expect(out['detail'], exp['detail']);
    expect(out['kind'], exp['kind']);
    expect(_rangeMap(out['range'] as MonacoRange), exp['range']);
    final children = (out['children'] as List).cast<Map<String, Object?>>();
    expect(children.length, 1);
    expect(children[0]['name'], ((exp['children'] as List)[0] as Map)['name']);

    final sk = (t['toSymbolKind'] as Map).cast<String, dynamic>();
    for (final entry in sk.entries) {
      expect(toSymbolKind(int.parse(entry.key)), entry.value);
    }
    expect(toSymbolKind(999), t['toSymbolKind_default']);

    final frk = (t['toFoldingRangeKind'] as Map).cast<String, dynamic>();
    final lsFolding = <String, String>{
      'Comment': ls.FoldingRangeKind.Comment,
      'Imports': ls.FoldingRangeKind.Imports,
      'Region': ls.FoldingRangeKind.Region,
    };
    for (final entry in frk.entries) {
      expect(toFoldingRangeKind(lsFolding[entry.key]!), entry.value);
    }
    expect(toFoldingRangeKind('none'), isNull);

    final ff = (t['fromFormattingOptions'] as Map);
    expect(fromFormattingOptions((ff['in'] as Map).cast<String, Object?>()), ff['out']);
  });
  _adapterTests();
}

// ---- Adapter orchestration tests ----

class _Model implements IReadOnlyModel {
  @override
  final LsUri uri;
  final String languageId;
  _Model(this.uri, this.languageId);
  @override
  String getLanguageId() => languageId;
  @override
  Map<String, Object?> getWordUntilPosition(MonacoPosition position) =>
      <String, Object?>{'startColumn': 1, 'endColumn': 5};
  @override
  Object? onDidChangeContent(void Function() listener) => Object();
}

class _CompletionWorker extends ILanguageWorkerWithCompletions {
  @override
  Future<Map<String, Object?>?> doComplete(String uri, Map<String, int> position) async =>
      <String, Object?>{
        'isIncomplete': false,
        'items': <Map<String, Object?>>[
          <String, Object?>{
            'label': 'foo',
            'kind': ls.CompletionItemKind.Function,
            'insertTextFormat': ls.InsertTextFormat.Snippet,
            'command': <String, Object?>{
              'command': 'editor.action.triggerSuggest',
              'title': 't',
            },
          },
        ],
      };
}

class _HoverWorker extends ILanguageWorkerWithHover {
  @override
  Future<Map<String, Object?>?> doHover(String uri, Map<String, int> position) async =>
      <String, Object?>{
        'range': <String, Object?>{
          'start': <String, int>{'line': 1, 'character': 2},
          'end': <String, int>{'line': 1, 'character': 5},
        },
        'contents': '**doc**',
      };
}

class _SymbolWorker extends ILanguageWorkerWithDocumentSymbols {
  @override
  Future<List<Map<String, Object?>>> findDocumentSymbols(String uri) async =>
      <Map<String, Object?>>[
        <String, Object?>{
          'name': 'top',
          'kind': ls.SymbolKind.Class,
          'range': <String, Object?>{
            'start': <String, int>{'line': 0, 'character': 0},
            'end': <String, int>{'line': 2, 'character': 0},
          },
          'selectionRange': <String, Object?>{
            'start': <String, int>{'line': 0, 'character': 0},
            'end': <String, int>{'line': 0, 'character': 3},
          },
          'children': <Object?>[],
        },
      ];
}

class _FoldingWorker extends ILanguageWorkerWithFoldingRanges {
  @override
  Future<List<Map<String, Object?>>> getFoldingRanges(String uri, [Map<String, Object?>? context]) async =>
      <Map<String, Object?>>[
        <String, Object?>{'startLine': 3, 'endLine': 9, 'kind': ls.FoldingRangeKind.Comment},
      ];
}

void _adapterTests() {
  final model = _Model(const LsUri('file:///a.ts'), 'typescript');
  final pos = MonacoPosition(5, 3); // -> {line:4, character:2}

  test('A1: CompletionAdapter maps position/kind/snippet/command', () async {
    final adapter = CompletionAdapter<_CompletionWorker>(
      (uris) async => _CompletionWorker(),
      <String>['.'],
    );
    expect(adapter.triggerCharacters, <String>['.']);
    final result = await adapter.provideCompletionItems(model, pos, const {}, null);
    expect(result!['isIncomplete'], isFalse);
    final items = (result['suggestions'] as List).cast<Map<String, Object?>>();
    expect(items.length, 1);
    expect(items[0]['kind'], MCompletionItemKind.Function);
    expect(items[0]['insertTextRules'], MCompletionItemInsertTextRule.InsertAsSnippet);
    expect((items[0]['command'] as Map)['id'], 'editor.action.triggerSuggest');
    // wordRange from model.getWordUntilPosition -> columns 1..5 on line 5
    expect(_rangeMapNoKind(items[0]['range'] as MonacoRange), <String, Object?>{
      'startLineNumber': 5, 'startColumn': 1, 'endLineNumber': 5, 'endColumn': 5,
    });
  });

  test('A2: HoverAdapter maps range + marked strings', () async {
    final adapter = HoverAdapter<_HoverWorker>((uris) async => _HoverWorker());
    final result = await adapter.provideHover(model, pos, null);
    expect((result!['range'] as MonacoRange).startLineNumber, 2);
    expect((result['contents'] as List)[0], <String, Object?>{'value': '**doc**'});
  });

  test('A3: DocumentSymbolAdapter dispatches DocumentSymbol (children discriminator)', () async {
    final adapter = DocumentSymbolAdapter<_SymbolWorker>((uris) async => _SymbolWorker());
    final result = await adapter.provideDocumentSymbols(model, null);
    expect(result!.length, 1);
    expect(result[0]['kind'], MSymbolKind.Class);
    expect(result[0]['detail'], '');
    expect((result[0]['children'] as List).isEmpty, isTrue);
  });

  test('A4: FoldingRangeAdapter maps line +1 and kind', () async {
    final adapter = FoldingRangeAdapter<_FoldingWorker>((uris) async => _FoldingWorker());
    final result = await adapter.provideFoldingRanges(model, const {}, null);
    expect(result!.length, 1);
    expect(result[0]['start'], 4);
    expect(result[0]['end'], 10);
    expect(result[0]['kind'], MFoldingRangeKind.Comment);
  });
}
