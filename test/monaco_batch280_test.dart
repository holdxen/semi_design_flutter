// batch280: codelens.ts truth replay.
// Truth from tool/ts2dart/batch280_truth.json (recursive TS transpile+vm,
// real getCodeLensModel + LanguageFeatureRegistry + fake providers).
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
import 'package:semi_design_flutter/src/monaco/editor/contrib/codelens/browser/codelens.dart'
    show
        CodeLens,
        CodeLensList,
        CodeLensModel,
        ICodeLensModel,
        ICodeLensProvider,
        ensureRegistered,
        getCodeLensModel;
import 'package:semi_design_flutter/src/monaco/platform/commands/common/commands.dart'
    show CommandsRegistry;

Map<String, dynamic> _truth() => jsonDecode(
    File('tool/ts2dart/batch280_truth.json').readAsStringSync())
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

class _Model implements ICodeLensModel {
  @override
  final URI uri = URI.parse('file:///a.ts');

  @override
  String getLanguageId() => 'typescript';

  @override
  bool isTooLargeForSyncing() => false;

  @override
  bool get isForSimpleWidget => false;
}

class _List extends CodeLensList {
  _List(super.lenses, this.calls, this.id, this.disposable);

  final List<Map<String, Object?>> calls;
  final String id;
  final bool disposable;

  void dispose() {
    if (disposable) calls.add(<String, Object?>{'provider': id, 'phase': 'list.dispose'});
  }
}

class _Provider implements ICodeLensProvider {
  _Provider(this.id, this.action, this.lensDefs, this.disposableList,
      this.canResolve, this.calls);

  final String id;
  final String action;
  final List<dynamic> lensDefs;
  final bool disposableList;
  final bool canResolve;
  final List<Map<String, Object?>> calls;

  @override
  Future<CodeLensList?> provideCodeLenses(
    Object model,
    CancellationToken token,
  ) async {
    calls.add(<String, Object?>{'provider': id, 'phase': 'provide'});
    if (action == 'throw') throw StateError('boom-$id');
    if (action == 'null') return null;
    final lenses = lensDefs.map((raw) {
      final l = raw as Map<String, dynamic>;
      return CodeLens(
        Range(l['line'] as int, l['col'] as int, l['line'] as int, l['col'] as int),
        null,
        l['id'] as String,
      );
    }).toList();
    return _List(lenses, calls, id, disposableList);
  }

  @override
  Future<CodeLens?> Function(Object, CodeLens, CancellationToken)?
      get resolveCodeLens => canResolve
          ? (Object model, CodeLens symbol, CancellationToken token) async {
              calls.add(<String, Object?>{
                'provider': id,
                'phase': 'resolve',
                'symbol': symbol.label,
              });
              return CodeLens(symbol.range, null, '${symbol.label}-resolved');
            }
          : null;
}

class _Token implements CancellationToken {
  _Token(bool cancelled) : isCancellationRequested = cancelled;
  @override
  final bool isCancellationRequested;

  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}

void main() {
  final t = _truth();

  test('b280 empty singleton and command registration', () {
    final emptyInfo = t['emptyInfo'] as Map<String, dynamic>;
    expect(CodeLensModel.Empty.lenses.isEmpty, emptyInfo['isEmpty']);
    expect(identical(CodeLensModel.Empty, CodeLensModel.Empty),
        emptyInfo['sameInstance']);
    expect(ensureRegistered(), isTrue);
    final cmd = t['command'] as Map<String, dynamic>;
    expect(CommandsRegistry.getCommand(cmd['id'] as String), isNotNull);
  });

  for (final rawCase in t['cases'] as List<dynamic>) {
    final c = rawCase as Map<String, dynamic>;
    test('b280 ${c['name']}: getCodeLensModel matches TS truth', () async {
      final unexpected = <String>[];
      setUnexpectedErrorHandler((Object? e) =>
          unexpected.add(e is StateError ? e.message : e.toString()));
      addTearDown(() => setUnexpectedErrorHandler((_) {}));

      final registry = LanguageFeatureRegistry<ICodeLensProvider>();
      final calls = <Map<String, Object?>>[];
      for (final rawP in c['providers'] as List<dynamic>) {
        final p = rawP as Map<String, dynamic>;
        registry.register(
          'typescript',
          _Provider(
            p['id'] as String,
            p['action'] as String,
            p['lenses'] as List<dynamic>,
            p['disposableList'] as bool,
            false, // canResolve unused in truth cases
            calls,
          ),
        );
      }

      final result = await getCodeLensModel(
        registry,
        _Model(),
        _Token(c['cancel'] as bool),
      );

      // Lenses: use provider id + position as the identity projection (truth
      // uses the fake symbol label; here we map to the same label scheme).
      final truthLenses =
          (c['lenses'] as List<dynamic>).cast<Map<String, dynamic>>();
      expect(result.lenses.length, truthLenses.length,
          reason: 'lens count ${c['name']}');
      for (int i = 0; i < truthLenses.length; i++) {
        final item = result.lenses[i];
        final tl = truthLenses[i];
        expect(item.symbol.label, tl['symbol'],
            reason: '${c['name']} lens $i symbol');
        expect(item.symbol.range.startLineNumber, tl['line'],
            reason: '${c['name']} lens $i line');
        expect(item.symbol.range.startColumn, tl['col'],
            reason: '${c['name']} lens $i col');
      }

      final truthCalls =
          (c['calls'] as List<dynamic>).cast<Map<String, dynamic>>();
      expect(_norm(calls), _norm(truthCalls), reason: 'calls ${c['name']}');

      final truthErrors = (c['externalErrors'] as List<dynamic>)
          .map((e) => e as String)
          .toList();
      expect(unexpected, truthErrors, reason: 'errors ${c['name']}');
    });
  }
}
