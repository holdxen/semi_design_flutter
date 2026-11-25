// batch277: provideSignatureHelp.ts truth replay.
// Truth from tool/ts2dart/batch277_truth.json (recursive TS transpile+vm,
// real LanguageFeatureRegistry + provideSignatureHelp driven by fake providers).
import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:semi_design_flutter/src/monaco/base/common/cancellation.dart'
    show CancellationToken;
import 'package:semi_design_flutter/src/monaco/base/common/errors.dart'
    show setUnexpectedErrorHandler;
import 'package:semi_design_flutter/src/monaco/base/common/uri.dart' show URI;
import 'package:semi_design_flutter/src/monaco/editor/common/core/position.dart'
    show Position;
import 'package:semi_design_flutter/src/monaco/editor/common/languageFeatureRegistry.dart'
    show ILanguageFeatureModel, LanguageFeatureRegistry;
import 'package:semi_design_flutter/src/monaco/editor/contrib/parameterHints/browser/provideSignatureHelp.dart'
    show
        Context,
        ISignatureHelpProvider,
        SignatureHelpContextData,
        ensureRegistered,
        provideSignatureHelp;
import 'package:semi_design_flutter/src/monaco/platform/commands/common/commands.dart'
    show CommandsRegistry;

Map<String, dynamic> _truth() => jsonDecode(
    File('tool/ts2dart/batch277_truth.json').readAsStringSync())
    as Map<String, dynamic>;

class _Model implements ILanguageFeatureModel {
  @override
  final URI uri = URI.parse('file:///a.ts');

  @override
  String getLanguageId() => 'typescript';

  @override
  bool isTooLargeForSyncing() => false;

  @override
  bool get isForSimpleWidget => false;
}

class _Result {
  _Result(this.label);
  final String label;
}

class _Provider implements ISignatureHelpProvider {
  _Provider(this.id, this.action, this.value, this.calls);

  final String id;
  final String action;
  final String? value;
  final List<Map<String, Object?>> calls;

  @override
  Future<Object?> provideSignatureHelp(
    Object model,
    Position position,
    CancellationToken token,
    Object context,
  ) async {
    final ctx = context as SignatureHelpContextData;
    calls.add(<String, Object?>{
      'provider': id,
      'position': <int>[position.lineNumber, position.column],
      'triggerKind': ctx.triggerKind,
      'isRetrigger': ctx.isRetrigger,
      'triggerCharacter': ctx.triggerCharacter,
    });
    if (action == 'throw') {
      throw StateError('boom-$id');
    }
    if (action == 'skip') {
      return null;
    }
    return _Result(value ?? id);
  }
}

void main() {
  final t = _truth();

  test('b277 context keys and const enum match TS truth', () {
    final truthKeys = (t['contextKeys'] as List<dynamic>)
        .map((e) => e as Map<String, dynamic>)
        .toList();
    final pairs = <String, Object?>{
      'Visible': Context.Visible.key,
      'MultipleSignatures': Context.MultipleSignatures.key,
    };
    for (final k in truthKeys) {
      expect(pairs[k['name'] as String], k['key'] as String,
          reason: 'context key ${k['name']}');
    }
    final kinds = (t['consts'] as Map<String, dynamic>)['SignatureHelpTriggerKind']
        as Map<String, dynamic>;
    expect(kinds['Invoke'], 1);
    expect(kinds['TriggerCharacter'], 2);
    expect(kinds['ContentChange'], 3);
  });

  test('b277 command registration side-effect', () {
    // Dart top-level initializers are lazy; force the module-side effect.
    expect(ensureRegistered(), isTrue);
    final truthCmd = t['command'] as Map<String, dynamic>;
    expect(CommandsRegistry.getCommand(truthCmd['id'] as String), isNotNull);
  });

  for (final rawCase in t['cases'] as List<dynamic>) {
    final c = rawCase as Map<String, dynamic>;
    test('b277 ${c['name']}: provideSignatureHelp matches TS truth', () async {
      final unexpected = <String>[];
      setUnexpectedErrorHandler((Object? e) =>
          unexpected.add(e is StateError ? e.message : e.toString()));
      addTearDown(() => setUnexpectedErrorHandler((_) {}));

      final registry = LanguageFeatureRegistry<Object?>();
      final calls = <Map<String, Object?>>[];
      final disposables = <dynamic>[];
      for (final rawP in c['providers'] as List<dynamic>) {
        final p = rawP as Map<String, dynamic>;
        disposables.add(registry.register(
          'typescript',
          _Provider(
            p['id'] as String,
            p['action'] as String,
            p['value'] as String?,
            calls,
          ),
        ));
      }

      final ctx = c['context'] as Map<String, dynamic>;
      final pos = c['position'] as List<dynamic>;
      final result = await provideSignatureHelp(
        registry,
        _Model(),
        Position(pos[0] as int, pos[1] as int),
        SignatureHelpContextData(
          triggerKind: ctx['triggerKind'] as int,
          isRetrigger: ctx['isRetrigger'] as bool,
          triggerCharacter: ctx['triggerCharacter'] as String?,
        ),
        CancellationToken.none,
      );

      final truthResult = c['result'];
      if (truthResult == null) {
        expect(result, isNull, reason: c['name'] as String);
      } else {
        expect(result, isA<_Result>(), reason: c['name'] as String);
        expect((result as _Result).label,
            (truthResult as Map<String, dynamic>)['label'] as String,
            reason: c['name'] as String);
      }

      // Provider call order/args.
      final truthCalls =
          (c['calls'] as List<dynamic>).map((e) => e as Map<String, dynamic>).toList();
      expect(calls.length, truthCalls.length, reason: 'call count ${c['name']}');
      for (int i = 0; i < truthCalls.length; i++) {
        final tc = truthCalls[i];
        final ac = calls[i];
        expect(ac['provider'], tc['provider'], reason: '${c['name']} call $i provider');
        expect(ac['triggerKind'], tc['triggerKind'], reason: '${c['name']} call $i triggerKind');
        expect(ac['isRetrigger'], tc['isRetrigger'], reason: '${c['name']} call $i isRetrigger');
        expect(ac['triggerCharacter'], tc['triggerCharacter'],
            reason: '${c['name']} call $i triggerCharacter');
        final truthPos = tc['position'] as List<dynamic>;
        final actualPos = ac['position'] as List<int>;
        expect(actualPos[0], truthPos[0], reason: '${c['name']} call $i line');
        expect(actualPos[1], truthPos[1], reason: '${c['name']} call $i column');
      }

      // External errors: Dart StateError.message equals TS Error.message.
      final truthErrors = (c['externalErrors'] as List<dynamic>)
          .map((e) => e as String)
          .toList();
      expect(unexpected, truthErrors, reason: 'externalErrors ${c['name']}');

      for (final d in disposables) {
        (d as dynamic).dispose();
      }
    });
  }
}
