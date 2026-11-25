// batch283: getSemanticTokens.ts truth replay.
// Truth from tool/ts2dart/batch283_truth.json (recursive TS transpile+vm,
// real getDocument*SemanticTokens + LanguageFeatureRegistry + fake providers).
import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:semi_design_flutter/src/monaco/base/common/cancellation.dart'
    show CancellationToken;
import 'package:semi_design_flutter/src/monaco/base/common/errors.dart'
    show setUnexpectedErrorHandler;
import 'package:semi_design_flutter/src/monaco/base/common/uri.dart' show URI;
import 'package:semi_design_flutter/src/monaco/editor/common/core/range.dart'
    show Range;
import 'package:semi_design_flutter/src/monaco/editor/common/languageFeatureRegistry.dart'
    show LanguageFeatureRegistry;
import 'package:semi_design_flutter/src/monaco/editor/contrib/semanticTokens/common/getSemanticTokens.dart'
    show
        DocumentSemanticTokensResult,
        IDocumentRangeSemanticTokensProvider,
        IDocumentSemanticTokensProvider,
        ISemanticTokensModel,
        SemanticTokens,
        SemanticTokensEdits,
        SemanticTokensLegend,
        ensureRegistered,
        getDocumentRangeSemanticTokens,
        getDocumentSemanticTokens,
        hasDocumentRangeSemanticTokensProvider,
        hasDocumentSemanticTokensProvider,
        isSemanticTokens,
        isSemanticTokensEdits;
import 'package:semi_design_flutter/src/monaco/platform/commands/common/commands.dart'
    show CommandsRegistry;

Map<String, dynamic> _truth() => jsonDecode(
    File('tool/ts2dart/batch283_truth.json').readAsStringSync())
    as Map<String, dynamic>;

Object? _norm(Object? v) {
  if (v == null) return null;
  if (v is Map) {
    return v.map<String, Object?>((k, e) =>
        MapEntry<String, Object?>(k as String, _norm(e)));
  }
  if (v is List) return v.map(_norm).toList();
  return v;
}

class _Model implements ISemanticTokensModel {
  @override
  final URI uri = URI.parse('file:///a.ts');

  @override
  String getLanguageId() => 'typescript';

  @override
  bool isTooLargeForSyncing() => false;

  @override
  bool get isForSimpleWidget => false;

  Object? getFullModelRange() => Range(1, 1, 1, 1);
}

Object? _tokensJSON(Object? t) {
  if (t == null) return null;
  if (t is SemanticTokens) {
    return <String, Object?>{
      'label': t.label,
      'data': t.data,
      'edits': null,
      'resultId': t.resultId,
    };
  }
  if (t is SemanticTokensEdits) {
    return <String, Object?>{
      'label': t.label,
      'data': null,
      'edits': t.edits,
      'resultId': null,
    };
  }
  return null;
}

class _DocProvider implements IDocumentSemanticTokensProvider {
  _DocProvider(this.id, this.action, this.resultId, this.calls);

  final String id;
  final String action;
  final bool resultId;
  final List<Map<String, Object?>> calls;

  @override
  Future<Object?> provideDocumentSemanticTokens(
    Object model,
    String? lastResultId,
    CancellationToken token,
  ) async {
    calls.add(<String, Object?>{
      'provider': id,
      'phase': 'doc.provide',
      'lastResultId': lastResultId,
    });
    if (action == 'throw') throw StateError('boom-$id');
    if (action == 'null') return null;
    if (action == 'edits') {
      return SemanticTokensEdits(<Object?>[
        <String, Object?>{'start': 0, 'length': 1, 'data': <int>[9]}
      ], id);
    }
    return SemanticTokens(<int>[1, 2, 3], resultId ? 'rid-$id' : null, id);
  }

  @override
  void releaseDocumentSemanticTokens(String resultId) =>
      calls.add(<String, Object?>{'provider': id, 'phase': 'release', 'resultId': resultId});

  @override
  SemanticTokensLegend getLegend() => SemanticTokensLegend(<String>[], <String>[]);
}

class _RangeProvider implements IDocumentRangeSemanticTokensProvider {
  _RangeProvider(this.id, this.action, this.calls);
  final String id;
  final String action;
  final List<Map<String, Object?>> calls;

  @override
  Future<SemanticTokens?> provideDocumentRangeSemanticTokens(
    Object model,
    Range range,
    CancellationToken token,
  ) async {
    calls.add(<String, Object?>{
      'provider': id,
      'phase': 'range.provide',
      'range': <int>[
        range.startLineNumber, range.startColumn,
        range.endLineNumber, range.endColumn,
      ],
    });
    if (action == 'throw') throw StateError('boom-$id');
    if (action == 'null') return null;
    return SemanticTokens(<int>[1, 2, 3], null, id);
  }

  @override
  SemanticTokensLegend getLegend() => SemanticTokensLegend(<String>[], <String>[]);
}

class _Token implements CancellationToken {
  @override
  bool get isCancellationRequested => false;
  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}

void main() {
  final t = _truth();

  test('b283 type guards and command registration', () {
    // JS undefined/null -> false in Dart; truth uses null for falsy.
    final tg = t['typeGuards'] as Map<String, dynamic>;
    final full = SemanticTokens(<int>[1]);
    final edit = SemanticTokensEdits(<Object?>[]);
    expect(isSemanticTokens(full), tg['tokensFull']);
    expect(isSemanticTokens(edit), tg['tokensEdit']);
    expect(isSemanticTokens(null), false);
    expect(isSemanticTokensEdits(edit), tg['editsFull']);
    expect(isSemanticTokensEdits(full), tg['editsTokens']);
    expect(isSemanticTokensEdits(null), false);
    expect(ensureRegistered(), isTrue);
    for (final rawCmd in t['commands'] as List<dynamic>) {
      final cmd = rawCmd as Map<String, dynamic>;
      if (cmd['registered'] as bool) {
        expect(CommandsRegistry.getCommand(cmd['id'] as String), isNotNull);
      }
    }
  });

  for (final rawCase in t['docCases'] as List<dynamic>) {
    final c = rawCase as Map<String, dynamic>;
    test('b283 DOC ${c['name']}: matches TS truth', () async {
      final unexpected = <String>[];
      setUnexpectedErrorHandler((Object? e) =>
          unexpected.add(e is StateError ? e.message : e.toString()));
      addTearDown(() => setUnexpectedErrorHandler((_) {}));

      final registry = LanguageFeatureRegistry<IDocumentSemanticTokensProvider>();
      final calls = <Map<String, Object?>>[];
      IDocumentSemanticTokensProvider? lastProvider;
      for (final rawP in c['providers'] as List<dynamic>) {
        final p = rawP as Map<String, dynamic>;
        final provider = _DocProvider(
          p['id'] as String,
          p['action'] as String,
          p['resultId'] as bool,
          calls,
        );
        registry.register('typescript', provider);
        if (p['id'] == 'a' && c['name'] == 'doc-last-provider-resultid') {
          lastProvider = provider;
        }
      }
      final model = _Model();
      final has = hasDocumentSemanticTokensProvider(registry, model);
      expect(has, c['has'], reason: 'has ${c['name']}');

      DocumentSemanticTokensResult? result;
      Object? thrown;
      try {
        result = await getDocumentSemanticTokens(
          registry,
          model,
          lastProvider,
          c['name'] == 'doc-last-provider-resultid' ? 'rid-a' : null,
          _Token(),
        );
      } catch (e) {
        thrown = e is StateError ? e.message : e.toString();
      }

      expect(thrown, c['thrown'], reason: 'thrown ${c['name']}');
      final truthResult = c['result'];
      if (truthResult == null) {
        expect(result, isNull, reason: 'result ${c['name']}');
      } else {
        final tr = truthResult as Map<String, dynamic>;
        expect(result, isNotNull, reason: 'result ${c['name']}');
        expect((result!.provider as _DocProvider).id, tr['provider'] as String,
            reason: 'provider ${c['name']}');
        expect(_tokensJSON(result.tokens), tr['tokens'],
            reason: 'tokens ${c['name']}');
        final truthErr = tr['error'];
        if (truthErr == null) {
          expect(result.error, isNull, reason: 'error ${c['name']}');
        }
      }

      expect(_norm(calls), c['calls'], reason: 'calls ${c['name']}');
      final truthErrors = (c['externalErrors'] as List<dynamic>)
          .map((e) => e as String)
          .toList();
      expect(unexpected, truthErrors, reason: 'errors ${c['name']}');
    });
  }

  for (final rawCase in t['rangeCases'] as List<dynamic>) {
    final c = rawCase as Map<String, dynamic>;
    test('b283 RANGE ${c['name']}: matches TS truth', () async {
      final unexpected = <String>[];
      setUnexpectedErrorHandler((Object? e) =>
          unexpected.add(e is StateError ? e.message : e.toString()));
      addTearDown(() => setUnexpectedErrorHandler((_) {}));

      final registry =
          LanguageFeatureRegistry<IDocumentRangeSemanticTokensProvider>();
      final calls = <Map<String, Object?>>[];
      for (final rawP in c['providers'] as List<dynamic>) {
        final p = rawP as Map<String, dynamic>;
        registry.register('typescript', _RangeProvider(
          p['id'] as String, p['action'] as String, calls));
      }
      final model = _Model();
      final has = hasDocumentRangeSemanticTokensProvider(registry, model);
      expect(has, c['has'], reason: 'has ${c['name']}');

      final result = await getDocumentRangeSemanticTokens(
        registry, model, Range(1, 1, 5, 10), _Token());

      final truthResult = c['result'];
      if (truthResult == null) {
        expect(result, isNull, reason: 'result ${c['name']}');
      } else {
        final tr = truthResult as Map<String, dynamic>;
        expect(result, isNotNull, reason: 'result ${c['name']}');
        expect((result!.provider as _RangeProvider).id, tr['provider'] as String,
            reason: 'provider ${c['name']}');
        expect(_tokensJSON(result.tokens), tr['tokens'],
            reason: 'tokens ${c['name']}');
      }

      expect(_norm(calls), c['calls'], reason: 'calls ${c['name']}');
      final truthErrors = (c['externalErrors'] as List<dynamic>)
          .map((e) => e as String)
          .toList();
      expect(unexpected, truthErrors, reason: 'errors ${c['name']}');
    });
  }
}
