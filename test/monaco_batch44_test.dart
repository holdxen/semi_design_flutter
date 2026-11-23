import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:semi_design_flutter/src/monaco/languages/definitions/test/testRunner.dart' as TR;
import 'package:semi_design_flutter/src/monaco/lsp/adapters/ITextModelBridge.dart' as IB;
import 'package:semi_design_flutter/src/monaco/lsp/adapters/LspCapabilitiesRegistry.dart' as CR;
import 'package:semi_design_flutter/src/monaco/lsp/adapters/monacoBridge.dart' as MB;
import 'package:semi_design_flutter/src/monaco/lsp/adapters/typedChannel.dart' as TC;
import 'package:semi_design_flutter/src/monaco/lsp/types.dart' as T;
import 'package:semi_design_flutter/src/monaco/lsp/utils.dart' as U;

Map<String, dynamic> _truth(String name) =>
    jsonDecode(File('tool/ts2dart/$name').readAsStringSync()) as Map<String, dynamic>;

class _TestDisposable implements U.IDisposable {
  bool disposed = false;
  @override
  void dispose() => disposed = true;
}

void main() {
  group('batch44 / lsp adapters + testRunner 1:1', () {
    test('deepAssign matches TS runtime truth (8 cases)', () {
      final truth = _truth('capreg_truth.json')['deepAssign'] as List;
      final cases = <List<Map<String, dynamic>>>[
        [<String, dynamic>{}, <String, dynamic>{'a': 1}],
        [<String, dynamic>{'a': 1}, <String, dynamic>{'a': 2}],
        [<String, dynamic>{'a': <String, dynamic>{'x': 1, 'y': 2}}, <String, dynamic>{'a': <String, dynamic>{'y': 3, 'z': 4}}],
        [<String, dynamic>{'a': 1}, <String, dynamic>{'a': <String, dynamic>{'b': 2}}],
        [<String, dynamic>{'a': <String, dynamic>{'b': 2}}, <String, dynamic>{'a': 9}],
        [<String, dynamic>{}, <String, dynamic>{'a': null, 'b': 2}],
        [
          <String, dynamic>{'a': <String, dynamic>{'deep': <String, dynamic>{'x': 1}}},
          <String, dynamic>{'a': <String, dynamic>{'deep': <String, dynamic>{'y': 2}}},
        ],
        [<String, dynamic>{}, <String, dynamic>{'list': <int>[1, 2, 3]}],
      ];
      for (var i = 0; i < cases.length; i++) {
        final target = cases[i][0];
        CR.deepAssign(target, cases[i][1]);
        // normalize through JSON so Map<String,int> == Map<String,num> etc.
        expect(jsonDecode(jsonEncode(target)), truth[i], reason: 'deepAssign case $i');
      }
    });

    test('getCapabilityByMethod matches TS truth incl. error message', () {
      final truth = _truth('capreg_truth.json')['getCapabilityByMethod'] as Map<String, dynamic>;
      for (final method in [
        'textDocument/implementation',
        'textDocument/completion',
        'workspace/executeCommand',
        'textDocument/didChange',
      ]) {
        expect(CR.getCapabilityByMethod(method).method, truth[method]);
      }
      expect(
        () => CR.getCapabilityByMethod('does/not/exist'),
        throwsA(isA<StateError>().having((e) => e.message, 'message', truth['__missing__'])),
      );
    });

    test('DynamicFromStaticOptions.getOptions matches TS truth (didChange + providers)', () {
      final truth = _truth('capreg_truth.json');
      final dso = CR.DynamicFromStaticOptions.create();
      final didChangeInputs = <Map<String, dynamic>>[
        <String, dynamic>{},
        <String, dynamic>{'textDocumentSync': null},
        <String, dynamic>{'textDocumentSync': T.TextDocumentSyncKind.Full},
        <String, dynamic>{'textDocumentSync': T.TextDocumentSyncKind.Incremental},
        <String, dynamic>{'textDocumentSync': <String, dynamic>{'change': T.TextDocumentSyncKind.Incremental, 'save': true}},
        <String, dynamic>{'textDocumentSync': <String, dynamic>{'openClose': true}},
      ];
      final didChangeTruth = truth['didChange'] as List;
      for (var i = 0; i < didChangeInputs.length; i++) {
        final r = dso.getOptions(T.capabilities['textDocumentDidChange']!, didChangeInputs[i]);
        expect(r == null ? null : jsonDecode(jsonEncode(r)), didChangeTruth[i], reason: 'didChange case $i');
      }
      final providers = truth['providers'] as Map<String, dynamic>;
      final providerCases = <List<Object>>[
        <Object>['textDocumentCompletion', 'completionProvider', <String, dynamic>{'triggerCharacters': <String>['."']}],
        <Object>['textDocumentHover', 'hoverProvider', true],
        <Object>['workspaceSymbol', 'workspaceSymbolProvider', false],
        <Object>['textDocumentRename', 'renameProvider', <String, dynamic>{'prepareProvider': true}],
      ];
      for (final c in providerCases) {
        final key = c[0] as String;
        final s = <String, dynamic>{c[1] as String: c[2]};
        final r = dso.getOptions(T.capabilities[key]!, s);
        expect(r == null ? null : jsonDecode(jsonEncode(r)), providers[key], reason: 'provider $key');
      }
    });

    test('getClientCapabilities deep-merges static capabilities', () {
      final channel = TC.InMemoryTypedChannel();
      final reg = CR.LspCapabilitiesRegistry(channel);
      reg.addStaticClientCapabilities(<String, dynamic>{'workspace': <String, dynamic>{'a': 1}});
      reg.addStaticClientCapabilities(<String, dynamic>{'workspace': <String, dynamic>{'b': 2}, 'textDocument': <String, dynamic>{'hover': true}});
      expect(reg.getClientCapabilities(), <String, dynamic>{
        'workspace': <String, dynamic>{'a': 1, 'b': 2},
        'textDocument': <String, dynamic>{'hover': true},
      });
    });

    test('LspCapabilitiesRegistry registers + dispatches capability handlers', () {
      final channel = TC.InMemoryTypedChannel();
      final reg = CR.LspCapabilitiesRegistry(channel);
      final disposables = <Object>[];

      // registry keys by Capability object identity; use the SAME object that
      // getCapabilityByMethod('textDocument/hover') resolves to.
      final hoverCap = CR.getCapabilityByMethod('textDocument/hover');
      final d = reg.registerCapabilityHandler<dynamic>(hoverCap, false, (opts) {
        disposables.add(opts);
        return _TestDisposable();
      });

      // Register via the client/registerCapability request handler.
      channel.handleRequest('client/registerCapability', TC.RegistrationParams(<dynamic>[
        <String, dynamic>{
          'id': 'h1',
          'method': 'textDocument/hover',
          'registerOptions': 42,
        },
      ]));
      expect(disposables, <Object>[42]);
      d.dispose();
    });

    test('ITextModelBridge.assertTargetTextModel identity semantics', () {
      final model = MB.SimpleTextModel(languageId: 'json');
      final holder = IB.TextModelHolder(model);
      expect(IB.assertTargetTextModel(holder, model), same(holder));
      final other = MB.SimpleTextModel(languageId: 'dart');
      expect(() => IB.assertTargetTextModel(holder, other), throwsA(isA<StateError>()));
    });

    test('testRunner.testTokenization assembles ITestItem tokens via provider', () async {
      final prevTokenize = TR.tokenizeProvider;
      final prevTest = TR.testRunnerTest;
      final prevDeep = TR.deepStrictEqual;
      final prevLoad = TR.loadLanguageProvider;
      List<TR.ITestItem>? capturedExpected;
      try {
        TR.loadLanguageProvider = (l) async {};
        TR.tokenizeProvider = (text, lang) => text.split('\n').map((line) => <TR.TokenizeToken>[
              TR.TokenizeToken(0, 'keyword'),
              TR.TokenizeToken(1, 'identifier'),
            ]).toList();
        TR.deepStrictEqual = (actual, expected) {
          expect(actual, expected);
        };
        Future<void>? running;
        TR.testRunnerTest = (name, fn) {
          expect(name, 'dart tokenization');
          running = fn();
        };
        final expected = <TR.ITestItem>[
          TR.ITestItem('abc', <TR.IRelaxedToken>[TR.IRelaxedToken(0, 'keyword'), TR.IRelaxedToken(1, 'identifier')]),
        ];
        capturedExpected = expected;
        TR.testTokenization('dart', <List<TR.ITestItem>>[expected]);
        await running;
      } finally {
        TR.tokenizeProvider = prevTokenize;
        TR.testRunnerTest = prevTest;
        TR.deepStrictEqual = prevDeep;
        TR.loadLanguageProvider = prevLoad;
      }
      expect(capturedExpected, isNotNull);
    });
  });
}
