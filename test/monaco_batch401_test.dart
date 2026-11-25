// 1:1 replay of
// `editor/contrib/documentSymbols/browser/documentSymbols.ts` (26 lines).
// Truth: `tool/ts2dart/_batch401_truth.cjs` -> `batch401_truth.json`.
import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import '../lib/src/monaco/base/common/cancellation.dart' show CancellationToken;
import '../lib/src/monaco/base/common/lifecycle.dart' show IReference;
import '../lib/src/monaco/base/common/uri.dart' show URI;
import '../lib/src/monaco/editor/common/core/range.dart' show Range;
import '../lib/src/monaco/editor/common/languageFeatureRegistry.dart'
    show LanguageFeatureRegistry;
import '../lib/src/monaco/editor/common/services/resolverService.dart'
    show
        IResolvedTextEditorModel,
        ITextModelForResolver,
        ITextModelService,
        ITextModelServiceType;
import '../lib/src/monaco/editor/contrib/documentSymbols/browser/documentSymbols.dart'
    as documentSymbols;
import '../lib/src/monaco/editor/contrib/documentSymbols/browser/outlineModel.dart'
    show
        IDocumentSymbolProvider,
        IOutlineModelService,
        IOutlineModelServiceType,
        OutlineDocumentSymbol,
        OutlineModel,
        OutlineModelTextModel;
import '../lib/src/monaco/platform/commands/common/commands.dart'
    show CommandsRegistry, ICommand;
import '../lib/src/monaco/platform/instantiation/common/instantiation.dart'
    show ServiceIdentifier, ServicesAccessor;

Map<String, dynamic> _map(dynamic value) =>
    (value as Map).cast<String, dynamic>();

Map<String, dynamic> _truth() => _map(jsonDecode(
    File('tool/ts2dart/batch401_truth.json').readAsStringSync()));

class _State {
  String? refUri;
  int disposed = 0;
  Object? createdWith;
  bool? tokenIsNone;
}

class _FakeModelService implements ITextModelServiceType {
  _FakeModelService(this._state, this._textModel);

  final _State _state;
  final ITextModelForResolver _textModel;

  @override
  Future<IReference<IResolvedTextEditorModel>> createModelReference(
      URI resource) async {
    _state.refUri = resource.toString();
    return _FakeReference(
        _FakeResolved(_textModel), () => _state.disposed += 1);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeResolved implements IResolvedTextEditorModel {
  _FakeResolved(this.textEditorModel);

  @override
  final ITextModelForResolver textEditorModel;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeReference implements IReference<IResolvedTextEditorModel> {
  _FakeReference(this.object, this._onDispose);

  @override
  final IResolvedTextEditorModel object;

  final void Function() _onDispose;

  @override
  void dispose() => _onDispose();
}

class _FakeOutlineService implements IOutlineModelServiceType {
  _FakeOutlineService(this._state, {this.reject = false});

  final _State _state;
  final bool reject;

  @override
  Future<OutlineModel> getOrCreate(Object model, CancellationToken token) async {
    _state.createdWith = model;
    _state.tokenIsNone = token == CancellationToken.none;
    if (reject) {
      throw StateError('boom');
    }
    final LanguageFeatureRegistry<IDocumentSymbolProvider> registry =
        LanguageFeatureRegistry<IDocumentSymbolProvider>();
    registry.register('*', _Provider());
    return OutlineModel.create(
        registry, _FakeTextModel(), CancellationToken.none);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeTextModel extends OutlineModelTextModel {
  @override
  URI get uri => URI.parse('file:///a.ts');

  String getLanguageId() => 'typescript';

  @override
  dynamic noSuchMethod(Invocation invocation) {
    final String name = invocation.memberName
        .toString()
        .replaceAll('Symbol("', '')
        .replaceAll('")', '');
    switch (name) {
      case 'getLanguageId':
        return 'typescript';
      case 'getLanguageIds':
        return <String>['typescript'];
      case 'isTooLargeForSyncing':
      case 'isForSimpleWidget':
        return false;
      case 'uri':
        return URI.parse('file:///a.ts');
    }
    return null;
  }
}

class _Provider implements IDocumentSymbolProvider {
  @override
  String? get displayName => 'fake';

  @override
  Future<List<OutlineDocumentSymbol>?> provideDocumentSymbols(
      Object model, CancellationToken token) async {
    OutlineDocumentSymbol symbol(String name) => OutlineDocumentSymbol(
          name: name,
          kind: 4,
          range: Range(1, 1, 1, 2),
          selectionRange: Range(1, 1, 1, 2),
        );
    return <OutlineDocumentSymbol>[symbol('A'), symbol('B')];
  }
}

class _FakeTextModelForResolver implements ITextModelForResolver {}

class _Accessor implements ServicesAccessor {
  _Accessor(this.outlineService, this.modelService);

  final IOutlineModelServiceType outlineService;
  final ITextModelServiceType modelService;

  @override
  Object? get(ServiceIdentifier id) {
    if (identical(id, IOutlineModelService)) return outlineService;
    if (identical(id, ITextModelService)) return modelService;
    throw StateError('unknown service');
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  final truth = _truth();
  final URI uri = URI.parse('file:///a.ts');

  ICommand command() {
    final ICommand? value =
        CommandsRegistry.getCommand('_executeDocumentSymbolProvider');
    expect(value, isNotNull);
    return value!;
  }

  test('the command is registered', () {
    expect(documentSymbols.documentSymbolsCommandRegistered, isTrue);
    expect(truth['commandRegistered'], isTrue);
    expect(command().id, truth['commandId']);
  });

  test('handler resolves the outline and disposes the reference', () async {
    final state = _State();
    final textModel = _FakeTextModelForResolver();
    final accessor = _Accessor(
        _FakeOutlineService(state), _FakeModelService(state, textModel));

    final result = await command().handler(accessor, <Object?>[uri]);
    expect((result as List).map((e) => (e as dynamic).name).toList(),
        (truth['result'] as List).map((e) => (e as Map)['name']).toList());

    final ok = _map(truth['ok']);
    expect(state.refUri, ok['refUri']);
    expect(state.disposed, ok['disposed']);
    expect(identical(state.createdWith, textModel), ok['sameTextModel']);
    expect(state.tokenIsNone, ok['tokenIsNone']);
  });

  test('non-URI resources are rejected', () {
    final state = _State();
    final accessor = _Accessor(_FakeOutlineService(state),
        _FakeModelService(state, _FakeTextModelForResolver()));
    expect(() => command().handler(accessor, <Object?>['not-a-uri']),
        throwsA(isA<Error>()));
    expect(_map(truth['badResource'])['threw'], isTrue);
  });

  test('the reference is disposed even when the outline lookup rejects',
      () async {
    final state = _State();
    final accessor = _Accessor(_FakeOutlineService(state, reject: true),
        _FakeModelService(state, _FakeTextModelForResolver()));
    await expectLater(
        command().handler(accessor, <Object?>[uri]), throwsA(anything));
    final reject = _map(truth['reject']);
    expect(reject['threw'], isTrue);
    expect(state.disposed, reject['disposed']);
  });
}
