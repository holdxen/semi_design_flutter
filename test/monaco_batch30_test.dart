import 'package:flutter_test/flutter_test.dart';
import 'package:semi_design_flutter/src/monaco/base/common/worker/webWorker.dart' as ww;
import 'package:semi_design_flutter/src/monaco/base/common/worker/webWorkerBootstrap.dart' as wwb;
import 'package:semi_design_flutter/src/monaco/editor/browser/controller/editContext/native/debugEditContext.dart' as dec;
import 'package:semi_design_flutter/src/monaco/editor/browser/controller/editContext/native/editContextFactory.dart' as ecf;
import 'package:semi_design_flutter/src/monaco/editor/test/common/services/semanticTokensDto.test.dart' as std;
import 'package:semi_design_flutter/src/monaco/internal/common/initialize.dart' as init;
import 'package:semi_design_flutter/src/monaco/lsp/adapters/LspCommandPolicy.dart' as policy;
import 'package:semi_design_flutter/src/monaco/lsp/utils.dart' as lsp;

void main() {
  group('batch30 / internal initialize', () {
    setUp(() {
      init.resetInitializedForTest();
      init.workerStart = (factory) => factory(null);
    });

    test('isWorkerInitialized tracks initialize', () {
      expect(init.isWorkerInitialized(), isFalse);
      init.initialize((ctx, data) => null);
      expect(init.isWorkerInitialized(), isTrue);
    });

    test('initialize installs onmessage and forwards m.data to callback', () {
      Object? capturedData;
      Object? capturedCtx;
      final Object? Function(Object?, Object?) cb = (ctx, data) {
        capturedCtx = ctx;
        capturedData = data;
        return null;
      };
      init.initialize(cb);
      init.workerSelf.deliver(<String, Object?>{'data': 'payload'});
      expect(capturedData, 'payload');
      expect(capturedCtx, isNull);
    });
  });

  group('batch30 / webWorkerBootstrap', () {
    setUp(() => wwb.resetBootstrapInitializedForTest());

    test('initializeBootstrap installs handler and posts messages', () {
      final posted = <Object?>[];
      wwb.bootstrapGlobalThis = wwb.BootstrapGlobalThis(
        postMessage: (msg) => posted.add(msg),
      );
      final server = wwb.initializeBootstrap((s) => Object());
      expect(server, isA<ww.WebWorkerServer>());
      // Re-initializing must throw.
      expect(() => wwb.initializeBootstrap((s) => Object()), throwsStateError);
    });

    test('bootstrapWebWorker ignores first message then initializes', () {
      int factoryCalls = 0;
      wwb.bootstrapGlobalThis = wwb.BootstrapGlobalThis();
      wwb.bootstrapWebWorker((s) {
        factoryCalls++;
        return Object();
      });
      // First delivered message triggers lazy initialize.
      wwb.bootstrapGlobalThis.deliver('first');
      expect(factoryCalls, 1);
    });
  });

  group('batch30 / LspCommandPolicy', () {
    test('defaultAllowedLocalCommands are the two suggest commands', () {
      expect(policy.defaultAllowedLocalCommands, contains('editor.action.triggerSuggest'));
      expect(policy.defaultAllowedLocalCommands, contains('editor.action.triggerParameterHints'));
    });

    test('resolve classifies server commands over local ones', () {
      final p = policy.LspCommandPolicy();
      final reg = p.addServerCommands(<Object?>['my.serverCmd']);
      final resolved = p.resolve(policy.LspCommand('my.serverCmd', <Object?>[1]));
      expect(resolved, isA<policy.ResolvedServerCommand>());
      expect((resolved as policy.ResolvedServerCommand).command, 'my.serverCmd');
      expect(resolved.arguments, <Object?>[1]);
      reg.dispose();
    });

    test('resolve classifies allowed local commands', () {
      final p = policy.LspCommandPolicy(<String>['custom.local']);
      expect(p.resolve(policy.LspCommand('editor.action.triggerSuggest')),
          isA<policy.ResolvedLocalCommand>());
      expect(p.resolve(policy.LspCommand('custom.local')),
          isA<policy.ResolvedLocalCommand>());
      expect(p.resolve(policy.LspCommand('not.known')), isNull);
    });

    test('resolve drops empty/invalid commands', () {
      final p = policy.LspCommandPolicy();
      expect(p.resolve(null), isNull);
      expect(p.resolve(policy.LspCommand('')), isNull);
      expect(p.resolve(policy.LspCommand(42)), isNull);
    });

    test('addServerCommands ref-counts and dispose is idempotent', () {
      final p = policy.LspCommandPolicy();
      final r1 = p.addServerCommands(<Object?>['cmd', 'cmd', 5]);
      final r2 = p.addServerCommands(<Object?>['cmd']);
      expect(p.isServerCommand('cmd'), isTrue);
      expect(p.isServerCommand(5), isFalse); // non-string filtered out
      r1.dispose();
      r1.dispose(); // idempotent
      expect(p.isServerCommand('cmd'), isTrue); // one ref from r2 remains
      r2.dispose();
      expect(p.isServerCommand('cmd'), isFalse);
    });

    test('isCommandUri matches leading whitespace command:', () {
      expect(policy.isCommandUri('command:foo'), isTrue);
      expect(policy.isCommandUri('  COMMAND:foo'), isTrue);
      expect(policy.isCommandUri('http://x/command:foo'), isFalse);
    });
  });

  group('batch30 / debugEditContext', () {
    test('create forwards window/options; text forwarded via carrier', () {
      Object? captured;
      final win = ecf.EditContextWindow((options) {
        captured = options;
        return <String, Object?>{
          'text': 'hello',
          'selectionStart': 1,
          'selectionEnd': 3,
        };
      });
      final ctx = dec.DebugEditContext(win, 'opts');
      expect(captured, 'opts');
      expect(ctx.text, 'hello');
      expect(ctx.selectionStart, 1);
      expect(ctx.selectionEnd, 3);
    });

    test('renderDebug creates markers for bounds and text', () {
      dec.debugDocument = dec.DebugDocument();
      final win = ecf.EditContextWindow((options) => <String, Object?>{
            'text': 'abc',
            'selectionStart': 0,
            'selectionEnd': 2,
          });
      final ctx = dec.DebugEditContext(win);
      // Register a listener so _listenerMap is non-empty (renderDebug guard).
      ctx.addEventListener('textupdate', (Object? e) {});
      ctx.updateControlBounds(dec.DebugRect(1, 2, 3, 4));
      ctx.updateSelectionBounds(dec.DebugRect(5, 6, 7, 8));
      ctx.updateCharacterBounds(0, <dec.DebugRect>[dec.DebugRect(9, 10, 11, 12)]);
      // 3 rects + 1 div appended to the debug document body.
      final active = dec.debugDocument.bodyChildren.where((e) => !e.removed).toList();
      expect(active.length, 4);
      expect(active.first.style['outline'], '2px solid blue');
    });

    test('event handler property wraps/unwraps on underlying context', () {
      final listeners = <Object>[];
      final win = ecf.EditContextWindow((options) => <String, Object?>{
            'text': '',
            'selectionStart': 0,
            'selectionEnd': 0,
            'addEventListener': (String t, Object l, Object? o) =>
                listeners.add(l),
            'removeEventListener': (String t, Object l, Object? o) =>
                listeners.remove(l),
          });
      final ctx = dec.DebugEditContext(win);
      final dec.EventHandler h = (Object? e) {};
      ctx.ontextupdate = h;
      expect(listeners, isNotEmpty);
      ctx.ontextupdate = null; // unwraps previous, no new listener
      expect(listeners, isEmpty);
    });

    test('startDebugging/endDebugging toggle renderDebug', () {
      dec.debugDocument = dec.DebugDocument();
      final win = ecf.EditContextWindow((options) => <String, Object?>{
            'text': 'x',
            'selectionStart': 0,
            'selectionEnd': 0,
          });
      final ctx = dec.DebugEditContext(win);
      ctx.addEventListener('textupdate', (Object? e) {});
      ctx.endDebugging();
      ctx.startDebugging();
      // Both toggles call renderDebug without throwing.
      expect(ctx.text, 'x');
    });
  });

  group('batch30 / semanticTokensDto.test (1:1 port)', () {
    test('all four translated mocha cases pass', () {
      std.runAll(); // throws if any assertion fails
    });
  });
}
