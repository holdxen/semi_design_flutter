// batch289: outlineModel.ts truth replay.
// Truth from tool/ts2dart/batch289_truth.json (recursive TS transpile+vm,
// real TreeElement/OutlineModel + fake DocumentSymbolProviders).
import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:semi_design_flutter/src/monaco/base/common/cancellation.dart'
    show CancellationToken;
import 'package:semi_design_flutter/src/monaco/base/common/lifecycle.dart'
    show Disposable, IDisposable;
import 'package:semi_design_flutter/src/monaco/base/common/errors.dart'
    show setUnexpectedErrorHandler;
import 'package:semi_design_flutter/src/monaco/base/common/uri.dart' show URI;
import 'package:semi_design_flutter/src/monaco/editor/common/core/position.dart'
    show Position;
import 'package:semi_design_flutter/src/monaco/editor/common/core/range.dart'
    show Range;
import 'package:semi_design_flutter/src/monaco/editor/common/languageFeatureRegistry.dart'
    show LanguageFeatureRegistry;
import 'package:semi_design_flutter/src/monaco/editor/contrib/documentSymbols/browser/outlineModel.dart'
    show
        IDocumentSymbolProvider,
        OutlineDocumentSymbol,
        OutlineMarker,
        OutlineModel,
        OutlineModelTextModel,
        OutlineElement,
        TreeElement;

Map<String, dynamic> _truth() => jsonDecode(
    File('tool/ts2dart/batch289_truth.json').readAsStringSync())
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

class _Model implements OutlineModelTextModel {
  @override
  final URI uri = URI.parse('file:///a.ts');

  @override
  String getLanguageId() => 'typescript';

  @override
  bool isTooLargeForSyncing() => false;

  @override
  bool get isForSimpleWidget => false;
}

Range _range(Map<String, dynamic> d) => Range(
      (d['startLineNumber'] as num).toInt(),
      (d['startColumn'] as num).toInt(),
      (d['endLineNumber'] as num).toInt(),
      (d['endColumn'] as num).toInt(),
    );

OutlineDocumentSymbol _makeSym(Map<String, dynamic> d) => OutlineDocumentSymbol(
      name: d['name'] as String,
      kind: (d['kind'] as num?)?.toInt() ?? 5,
      range: _range(d['range'] as Map<String, dynamic>),
      selectionRange: _range(d['selectionRange'] as Map<String, dynamic>),
      children: d['children'] == null
          ? null
          : (d['children'] as List<dynamic>)
              .map((c) => _makeSym(c as Map<String, dynamic>))
              .toList(),
    );

class _Provider implements IDocumentSymbolProvider {
  _Provider(this.displayName, this.throwError, this.symbols);

  @override
  final String? displayName;
  final bool throwError;
  final List<OutlineDocumentSymbol> symbols;

  @override
  Future<List<OutlineDocumentSymbol>?> provideDocumentSymbols(
      Object model, CancellationToken token) async {
    if (throwError) throw StateError('boom-$displayName');
    return symbols;
  }
}

Object _treeJson(TreeElement el) => <String, Object?>{
      'id': el.id,
      'children': el.children.values.map(_treeJson).toList(),
    };

Object _modelJson(OutlineModel model) => <String, Object?>{
      'id': model.id,
      'children': _treeJson(model),
      'topLevel': model.getTopLevelSymbols().map((s) => s.name).toList(),
      'flat': model.asListOfDocumentSymbols().map((s) => <String, Object?>{
            'name': s.name,
            'containerName': s.containerName ?? '',
            'range': <int>[
              s.range.startLineNumber,
              s.range.startColumn,
              s.range.endLineNumber,
              s.range.endColumn,
            ],
          }).toList(),
    };

class _Token implements CancellationToken {
  @override
  bool get isCancellationRequested => false;

  @override
  IDisposable onCancellationRequested(dynamic listener,
      [dynamic thisArgs, dynamic disposables]) => Disposable.none;

  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}

void main() {
  final t = _truth();

  test('b288 TreeElement.findId dedupe truth', () {
    final container = _Container('root');
    final symA = OutlineDocumentSymbol(
        name: 'foo', kind: 5,
        range: Range(1, 1, 1, 5), selectionRange: Range(1, 1, 1, 4));
    final ids = <String>[];
    ids.add(TreeElement.findId('abc', container));
    ids.add(TreeElement.findId(symA, container));
    container.put(ids[1]);
    ids.add(TreeElement.findId(symA, container));
    container.put(ids[2]);
    ids.add(TreeElement.findId(symA, container));
    ids.add(TreeElement.findId('abc', container));
    container.put(ids[4]);
    ids.add(TreeElement.findId('abc', container));
    expect(ids, t['treeIds']);
  });

  for (final rawCase in t['cases'] as List<dynamic>) {
    final c = rawCase as Map<String, dynamic>;
    test('b289 ${c['name']}: outline model truth', () async {
      if (c['name'] == 'marker-propagation') {
        // marker case handled separately below (no providers/queries)
        return;
      }
      final unexpected = <String>[];
      // TS harness String(new Error(msg)) => 'Error: msg'; Dart StateError
      // has no such prefix, so mirror the TS projection.
      setUnexpectedErrorHandler((Object? e) => unexpected.add(
          e is StateError ? 'Error: ${e.message}' : e.toString()));
      addTearDown(() => setUnexpectedErrorHandler((_) {}));

      final registry = LanguageFeatureRegistry<IDocumentSymbolProvider>();
      for (final rawP in c['providers'] as List<dynamic>) {
        final p = rawP as Map<String, dynamic>;
        registry.register('typescript', _Provider(
          p['displayName'] as String?,
          p['throw'] as bool,
          (p['symbols'] as List<dynamic>)
              .map((s) => _makeSym(s as Map<String, dynamic>))
              .toList(),
        ));
      }
      final model = await OutlineModel.create(registry, _Model(), _Token());
      final qOut = <Object?>[];
      for (final rawQ in c['queries'] as List<dynamic>) {
        final q = rawQ as Map<String, dynamic>;
        switch (q['op'] as String) {
          case 'model':
            qOut.add(_modelJson(model));
            break;
          case 'enclosing':
            final e = model.getItemEnclosingPosition(
                Position(q['line'] as int, q['col'] as int));
            qOut.add(e?.symbol.name);
            break;
          case 'getElementById':
            final e = model.getItemById(q['id'] as String);
            qOut.add(e?.id);
            break;
          case 'size':
            qOut.add(TreeElement.size(model));
            break;
          default:
            fail('unknown query ${q['op']}');
        }
      }
      expect(_norm(qOut), c['queryOut'], reason: 'queryOut ${c['name']}');
      expect(unexpected, c['externalErrors'], reason: 'errors ${c['name']}');
    });
  }

  test('b289 marker-propagation truth', () async {
    final c = (t['cases'] as List<dynamic>).firstWhere(
        (x) => (x as Map<String, dynamic>)['name'] == 'marker-propagation')
        as Map<String, dynamic>;
    final registry = LanguageFeatureRegistry<IDocumentSymbolProvider>();
    registry.register('typescript', _Provider('P', false, [
      OutlineDocumentSymbol(
        name: 'outer', kind: 5,
        range: Range(1, 1, 10, 1), selectionRange: Range(1, 1, 1, 6),
        children: <OutlineDocumentSymbol>[
          OutlineDocumentSymbol(
            name: 'inner', kind: 5,
            range: Range(2, 1, 3, 1), selectionRange: Range(2, 1, 2, 6)),
        ]),
    ]));
    final model = await OutlineModel.create(registry, _Model(), _Token());
    model.updateMarker(<OutlineMarker>[
      OutlineMarker(startLineNumber: 2, startColumn: 1, endLineNumber: 2, endColumn: 8, severity: 4),
      OutlineMarker(startLineNumber: 2, startColumn: 2, endLineNumber: 2, endColumn: 4, severity: 8),
    ]);
    final state = <Object?>[];
    void walk(TreeElement el) {
      state.add(<String, Object?>{
        'id': el.id,
        'marker': el is OutlineElement ? el.marker?.toJson() : null,
      });
      for (final child in el.children.values) {
        walk(child);
      }
    }
    walk(model);
    expect(_norm(state), c['markerState']);
  });
}

/// Helper container for findId test (implements TreeElement minimally).
class _Container extends TreeElement {
  _Container(this.id);
  @override
  final String id;
  @override
  TreeElement? parent;
  final Map<String, TreeElement> _children = <String, TreeElement>{};
  @override
  Map<String, TreeElement> get children => _children;
  void put(String id) => _children[id] = _Container(id);
}
