import 'dart:typed_data' show Uint8List;

import 'package:flutter_test/flutter_test.dart';
import 'package:semi_design_flutter/src/monaco/editor/browser/triggerInlineEditCommandsRegistry.dart'
    as registry;
import 'package:semi_design_flutter/src/monaco/editor/browser/viewParts/minimap/minimapCharRenderer.dart'
    as mcr;
import 'package:semi_design_flutter/src/monaco/editor/common/core/misc/rgba.dart'
    show RGBA8;
import 'package:semi_design_flutter/src/monaco/editor/common/model/textModelPart.dart'
    as tmp;
import 'package:semi_design_flutter/src/monaco/internal/common/workers.dart' as iw;
import 'package:semi_design_flutter/src/monaco/platform/files/browser/webFileSystemAccess.dart'
    as wfsa;

void main() {
  group('batch27 / TextModelPart', () {
    test('dispose marks disposed and assertNotDisposed throws', () {
      final part = tmp.TextModelPart();
      expect(() => part.assertNotDisposed(), returnsNormally);
      part.dispose();
      expect(
        () => part.assertNotDisposed(),
        throwsA(isA<StateError>().having(
            (e) => e.message, 'message', 'TextModelPart is disposed!')),
      );
    });
  });

  group('batch27 / TriggerInlineEditCommandsRegistry', () {
    test('registerCommand adds and getRegisteredCommands returns a copy', () {
      registry.TriggerInlineEditCommandsRegistry.registerCommand('cmd.a');
      registry.TriggerInlineEditCommandsRegistry.registerCommand('cmd.b');
      final cmds = registry.TriggerInlineEditCommandsRegistry.getRegisteredCommands();
      expect(cmds, contains('cmd.a'));
      expect(cmds, contains('cmd.b'));
      // Mutating the returned list must not affect the registry.
      cmds.clear();
      expect(
        registry.TriggerInlineEditCommandsRegistry.getRegisteredCommands(),
        contains('cmd.a'),
      );
    });
  });

  group('batch27 / WebFileSystemAccess', () {
    test('supported checks showDirectoryPicker is a function', () {
      expect(wfsa.WebFileSystemAccess.supported(null), isFalse);
      expect(wfsa.WebFileSystemAccess.supported(<String, dynamic>{}), isFalse);
      expect(
        wfsa.WebFileSystemAccess.supported(<String, dynamic>{
          'showDirectoryPicker': 123,
        }),
        isFalse,
      );
      expect(
        wfsa.WebFileSystemAccess.supported(<String, dynamic>{
          'showDirectoryPicker': () {},
        }),
        isTrue,
      );
    });

    test('isFileSystemHandle checks kind + permission functions', () {
      final valid = <String, dynamic>{
        'kind': 'file',
        'queryPermission': () {},
        'requestPermission': () {},
      };
      expect(wfsa.WebFileSystemAccess.isFileSystemHandle(null), isFalse);
      expect(wfsa.WebFileSystemAccess.isFileSystemHandle(valid), isTrue);
      expect(
        wfsa.WebFileSystemAccess.isFileSystemHandle(<String, dynamic>{
          ...valid,
          'queryPermission': 1,
        }),
        isFalse,
      );
      expect(
        wfsa.WebFileSystemAccess.isFileSystemFileHandle(valid),
        isTrue,
      );
      expect(
        wfsa.WebFileSystemAccess.isFileSystemDirectoryHandle(valid),
        isFalse,
      );
      expect(
        wfsa.WebFileSystemAccess.isFileSystemDirectoryHandle(<String, dynamic>{
          'kind': 'directory',
        }),
        isTrue,
      );
    });

    test('WebFileSystemObserver.supported checks FileSystemObserver', () {
      expect(wfsa.WebFileSystemObserver.supported(null), isFalse);
      expect(
        wfsa.WebFileSystemObserver.supported(<String, dynamic>{
          'FileSystemObserver': () {},
        }),
        isTrue,
      );
    });
  });

  group('batch27 / internal workers', () {
    setUp(() {
      iw.internalWorkersGlobalThisProvider = () => null;
      iw.internalWorkersSelfConstructorNameProvider = () => '';
      iw.internalWorkersConsoleError = (_) {};
      iw.internalWorkersNewWorker = null;
      iw.internalWorkersCreateWebWorker = null;
      // Non-null override avoids computing the module-level default policy.
      iw.internalWorkersTtPolicyOverride = <String, dynamic>{};
    });

    test('createTrustedTypesPolicy prefers MonacoEnvironment', () {
      iw.internalWorkersGlobalThisProvider = () => <String, dynamic>{
            'MonacoEnvironment': <String, dynamic>{
              'createTrustedTypesPolicy': (String name, Object? opts) =>
                  'env:$name',
            },
          };
      expect(
        iw.createTrustedTypesPolicy('default'),
        'env:default',
      );
    });

    test('createTrustedTypesPolicy falls back to globalThis.trustedTypes', () {
      iw.internalWorkersGlobalThisProvider = () => <String, dynamic>{
            'trustedTypes': <String, dynamic>{
              'createPolicy': (String name, Object? opts) => 'tt:$name',
            },
          };
      expect(iw.createTrustedTypesPolicy('x'), 'tt:x');
    });

    test('createTrustedTypesPolicy catches errors and logs console.error', () {
      final errors = <Object?>[];
      iw.internalWorkersConsoleError = (e) => errors.add(e);
      iw.internalWorkersGlobalThisProvider = () => <String, dynamic>{
            'MonacoEnvironment': <String, dynamic>{
              'createTrustedTypesPolicy': (String name, Object? opts) =>
                  throw StateError('boom'),
            },
          };
      expect(iw.createTrustedTypesPolicy('x'), isNull);
      expect(errors, hasLength(1));
    });

    test('getWorker uses MonacoEnvironment.getWorker', () {
      iw.internalWorkersGlobalThisProvider = () => <String, dynamic>{
            'MonacoEnvironment': <String, dynamic>{
              'getWorker': (String moduleId, String label) =>
                  'worker:$moduleId:$label',
            },
          };
      expect(
        iw.getWorker(<String, dynamic>{'label': 'json'}),
        'worker:workerMain.js:json',
      );
    });

    test('getWorker uses getWorkerUrl + ttPolicy.createScriptURL + new Worker',
        () {
      iw.internalWorkersGlobalThisProvider = () => <String, dynamic>{
            'MonacoEnvironment': <String, dynamic>{
              'getWorkerUrl': (String moduleId, String label) => 'http://w/$label',
            },
          };
      iw.internalWorkersTtPolicyOverride = <String, dynamic>{
        'createScriptURL': (String url) => 'trusted:$url',
      };
      final calls = <List<Object?>>[];
      iw.internalWorkersNewWorker = (String url, String name, String type) {
        calls.add(<Object?>[url, name, type]);
        return <String, dynamic>{'url': url};
      };
      final result = iw.getWorker(<String, dynamic>{'label': 'ts'});
      expect(result, isA<Map>());
      expect(calls.single, <Object?>['trusted:http://w/ts', 'ts', 'module']);
    });

    test('getWorker uses descriptor.createWorker as fallback', () {
      final worker = <String, dynamic>{'from': 'createWorker'};
      expect(
        iw.getWorker(<String, dynamic>{
          'label': 'x',
          'createWorker': () => worker,
        }),
        same(worker),
      );
    });

    test('getWorker throws when no factory is available', () {
      expect(
        () => iw.getWorker(<String, dynamic>{'label': 'x'}),
        throwsA(isA<StateError>().having((e) => e.message, 'message',
            contains('MonacoEnvironment.getWorkerUrl'))),
      );
    });

    test('createWebWorker posts ignore + createData and forwards to editor',
        () async {
      final messages = <Object?>[];
      final worker = <String, dynamic>{
        'postMessage': (Object? msg) => messages.add(msg),
      };
      iw.internalWorkersGlobalThisProvider = () => <String, dynamic>{
            'MonacoEnvironment': <String, dynamic>{
              'getWorker': (String moduleId, String label) => worker,
            },
          };
      Map<String, dynamic>? capturedOpts;
      iw.internalWorkersCreateWebWorker = (Map<String, dynamic> opts) {
        capturedOpts = opts;
        return 'monacoWorker';
      };
      final result = iw.createWebWorker(iw.IWebWorkerOptions(
        moduleId: 'm',
        label: 'lbl',
        createData: <String, dynamic>{'k': 1},
        host: 'hostObj',
        keepIdleModels: true,
      ));
      expect(result, 'monacoWorker');
      expect(capturedOpts, isNotNull);
      expect(capturedOpts!['host'], 'hostObj');
      expect(capturedOpts!['keepIdleModels'], true);
      final resolved = await capturedOpts!['worker'] as Object?;
      expect(resolved, same(worker));
      expect(messages, hasLength(2));
      expect(messages[0], 'ignore');
      expect(messages[1], <String, dynamic>{'k': 1});
    });
  });

  group('batch27 / MinimapCharRenderer', () {
    Uint8List allBytes(int length, int value) =>
        Uint8List.fromList(List<int>.filled(length, value));

    test('soften produces 12/15 and 50/60 scaled char data', () {
      final renderer = mcr.MinimapCharRenderer(allBytes(2, 255), 1);
      // soften(255, 12/15) = 204; soften(255, 50/60) = 212 (via toUint8)
      expect(renderer.charDataNormal[0], 204);
      expect(renderer.charDataLight[0], 212);
    });

    test('renderChar writes darkened pixels at the expected offsets', () {
      final renderer = mcr.MinimapCharRenderer(allBytes(4, 255), 1);
      final target = mcr.MinimapImageData(2, 2, Uint8List(2 * 2 * 4));
      final color = RGBA8(255, 0, 0, 255);
      final background = RGBA8(0, 0, 0, 255);
      renderer.renderChar(target, 0, 0, 32, color, 255, background, 255, 1,
          false, false);
      // charDataNormal[0] = 204 -> c = 204/255 * 1 = 0.8 -> R = 204
      expect(target.data[0], 204);
      expect(target.data[1], 0);
      expect(target.data[2], 0);
      expect(target.data[3], 255);
      // second row at offset destWidth=8
      expect(target.data[8], 204);
      expect(target.data[11], 255);
    });

    test('renderChar skips out-of-bounds requests and warns', () {
      final warnings = <String>[];
      mcr.minimapCharRendererWarn = (m) => warnings.add(m);
      final renderer = mcr.MinimapCharRenderer(allBytes(4, 255), 1);
      final target = mcr.MinimapImageData(1, 2, Uint8List(1 * 2 * 4));
      renderer.renderChar(target, 1, 0, 32, RGBA8(255, 0, 0, 255), 255,
          RGBA8(0, 0, 0, 255), 255, 1, false, false);
      expect(warnings, <String>['bad render request outside image data']);
      expect(target.data.every((b) => b == 0), isTrue);
      mcr.minimapCharRendererWarn = (_) {};
    });

    test('blockRenderChar writes half-blended color uniformly', () {
      final renderer = mcr.MinimapCharRenderer(allBytes(4, 255), 1);
      final target = mcr.MinimapImageData(1, 2, Uint8List(1 * 2 * 4));
      renderer.blockRenderChar(target, 0, 0, RGBA8(255, 0, 0, 255), 255,
          RGBA8(0, 0, 0, 255), 255, false);
      // c = 0.5 * (255/255) = 0.5 -> colorR = 127.5 -> clamped round = 128
      expect(target.data[0], 128);
      expect(target.data[1], 0);
      expect(target.data[3], 255);
      expect(target.data[4], 128);
      expect(target.data[7], 255);
    });

    test('force1pxHeight renders a single row', () {
      final renderer = mcr.MinimapCharRenderer(allBytes(4, 255), 1);
      final target = mcr.MinimapImageData(1, 2, Uint8List(1 * 2 * 4));
      renderer.blockRenderChar(target, 0, 0, RGBA8(255, 0, 0, 255), 255,
          RGBA8(0, 0, 0, 255), 255, true);
      expect(target.data[0], 128);
      // second row remains untouched
      expect(target.data[4], 0);
    });
  });
}
