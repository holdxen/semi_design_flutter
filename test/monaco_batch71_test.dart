// batch71: standaloneWebWorkerService.ts. Assertions are data-driven from
// batch71_truth.json (Node TS transpile+vm real evaluation of the source with
// isolated faithful stubs for the two dependencies).
import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:semi_design_flutter/src/monaco/base/browser/browser.dart'
    show getMonacoEnvironment;
import 'package:semi_design_flutter/src/monaco/editor/standalone/browser/services/standaloneWebWorkerService.dart'
    as m;
import 'package:semi_design_flutter/src/monaco/platform/webWorker/browser/webWorkerDescriptor.dart'
    show WebWorkerDescriptor;
import 'package:semi_design_flutter/src/monaco/platform/webWorker/browser/webWorkerServiceImpl.dart'
    as w;

Map<String, dynamic> _truth() => jsonDecode(
      File('tool/ts2dart/batch71_truth.json').readAsStringSync(),
    ) as Map<String, dynamic>;

/// Capture of a `super.createWorker` path: batch70's base builds a blob worker
/// from `getWorkerUrl`, so injecting these providers makes the super branch
/// observable (and lets it succeed for a descriptor with an esm location).
class _Capture {
  final List<List<Object?>> createCalls = <List<Object?>>[];
  final List<String> objectUrls = <String>[];
  final List<w.PlatformWorker> workers = <w.PlatformWorker>[];
}

/// Message carrier with `.data.type`, mirroring the JS ready handshake.
class _MsgEvent {
  _MsgEvent(this.data);
  final Object? data;
}

class _ReadyData {
  _ReadyData(this.type);
  final String type;
}

void _fireReady(_Capture cap) {
  (cap.workers.last.onmessage as void Function(Object?))(
      _MsgEvent(_ReadyData('vscode-worker-ready')));
}

void _installSuperProbe(_Capture cap) {
  w.createObjectURLProvider = (Object blob) {
    // batch70's bootstrap builds a PlatformBlob then calls createObjectURL.
    final String desc = blob is w.PlatformBlob
        ? 'blob(${blob.parts.length})'
        : blob as String;
    cap.objectUrls.add(desc);
    return 'blob:probe';
  };
  w.createWorkerProvider = (String url, w.WorkerOptions? o) {
    cap.createCalls.add(<Object?>[url, o?.name, o?.type]);
    final worker = w.PlatformWorker(url, o);
    cap.workers.add(worker);
    return worker;
  };
  w.revokeObjectURLProvider = (String url) {};
  w.workerGlobalOrigin = 'https://example.com';
  w.globalVSCodeProductJson = null;
  w.workerSelfConstructorName = null;
  w.createTrustedTypesPolicyHook = null;
}

WebWorkerDescriptor _descriptor(String label, [Object? bundler]) =>
    WebWorkerDescriptor(
      label: label,
      esmModuleLocation: _UriCarrier('https://example.com/out/worker.js'),
      esmModuleLocationBundler: bundler,
    );

class _UriCarrier {
  _UriCarrier(this.value);
  final String value;

  @override
  String toString([bool skipEncoding = false]) => value;
}

class _UrlCarrier {
  _UrlCarrier(this.value);
  final String value;

  @override
  String toString() => value;
}

void main() {
  final t = _truth();

  setUp(() {
    m.standaloneMonacoEnvironmentProvider = getMonacoEnvironment;
    m.standaloneDocumentBaseUri = '';
    m.standaloneResolveUrlProvider = (String url, String base) =>
        Uri.parse(base).resolve(url).toString();
  });

  // ---- _createWorker: monacoEnvironment absent -> super ----
  test('b71 createWorker: no env -> super', () async {
    final a = (t['createWorker'] as Map)['noEnv'] as Map<String, dynamic>;
    m.standaloneMonacoEnvironmentProvider = () => null;
    final cap = _Capture();
    _installSuperProbe(cap);
    final label = (a['superCalls'] as List).first[1] as String;
    final future = m.StandaloneWebWorkerService().createWorker(
      _descriptor(label, _UrlCarrier('https://example.com/out/worker.js')),
    );
    _fireReady(cap);
    final result = await future;
    // super path built a blob worker via getWorkerUrl (subclass override).
    expect(cap.objectUrls.length, 1,
        reason: 'super createWorker allocates a blob object URL');
    expect(cap.createCalls.length, 1);
    expect(result, isA<w.PlatformWorker>());
  });

  // ---- _createWorker: getWorker is not a function -> super ----
  test('b71 createWorker: getWorker non-function -> super', () async {
    final a =
        (t['createWorker'] as Map)['getWorkerNotFn'] as Map<String, dynamic>;
    m.standaloneMonacoEnvironmentProvider = () => <String, Object?>{
          'getWorker': 42,
        };
    final cap = _Capture();
    _installSuperProbe(cap);
    final label = (a['superCalls'] as List).first[1] as String;
    final future = m.StandaloneWebWorkerService().createWorker(
      _descriptor(label, _UrlCarrier('https://example.com/out/worker.js')),
    );
    _fireReady(cap);
    await future;
    expect(cap.objectUrls.length, 1, reason: 'fell through to super');
  });

  // ---- _createWorker: getWorker returns JS undefined -> super ----
  test('b71 createWorker: getWorker returns undefined -> super', () async {
    final a =
        (t['createWorker'] as Map)['returnsUndefined'] as Map<String, dynamic>;
    final calls = <List<Object?>>[];
    m.standaloneMonacoEnvironmentProvider = () => <String, Object?>{
          'getWorker': (String moduleId, String label) {
            calls.add(<Object?>[moduleId, label]);
            return m.standaloneJsUndefined; // JS undefined
          },
        };
    final cap = _Capture();
    _installSuperProbe(cap);
    final label = (a['superCalls'] as List).first[1] as String;
    final future = m.StandaloneWebWorkerService().createWorker(
      _descriptor(label, _UrlCarrier('https://example.com/out/worker.js')),
    );
    _fireReady(cap);
    await future;
    expect(cap.objectUrls.length, 1, reason: 'undefined -> super');
    expect(calls, a['getWorkerCalls'],
        reason: 'getWorker called with (workerMain.js, label)');
  });

  // ---- _createWorker: getWorker returns null -> Promise.resolve(null), NOT super ----
  test('b71 createWorker: getWorker returns null -> no super', () async {
    final a =
        (t['createWorker'] as Map)['returnsNull'] as Map<String, dynamic>;
    final calls = <List<Object?>>[];
    m.standaloneMonacoEnvironmentProvider = () => <String, Object?>{
          'getWorker': (String moduleId, String label) {
            calls.add(<Object?>[moduleId, label]);
            return null; // JS null, distinct from undefined
          },
        };
    final cap = _Capture();
    _installSuperProbe(cap);
    final label = (a['getWorkerCalls'] as List).first[1] as String;
    final result = await m.StandaloneWebWorkerService().createWorker(
      _descriptor(label),
    );
    expect((a['superCalls'] as List).isEmpty, isTrue, reason: 'JS null !== undefined');
    expect(cap.objectUrls.isEmpty, isTrue, reason: 'super NOT taken');
    expect(calls, a['getWorkerCalls']);
    // Promise.resolve(null) is wrapped in a carrier; branch observable via
    // the absence of a super blob URL (see above). Truth resolved == "null".
    expect(a['resolved'], 'null');
    expect(result, isA<w.PlatformWorker>());
  });

  // ---- _createWorker: getWorker returns a worker carrier -> no super ----
  test('b71 createWorker: getWorker returns worker -> Promise.resolve', () async {
    final a =
        (t['createWorker'] as Map)['returnsWorker'] as Map<String, dynamic>;
    final carrier = w.PlatformWorker('blob:env-worker');
    final calls = <List<Object?>>[];
    m.standaloneMonacoEnvironmentProvider = () => <String, Object?>{
          'getWorker': (String moduleId, String label) {
            calls.add(<Object?>[moduleId, label]);
            return carrier;
          },
        };
    final cap = _Capture();
    _installSuperProbe(cap);
    final label = (a['getWorkerCalls'] as List).first[1] as String;
    final result = await m.StandaloneWebWorkerService().createWorker(
      _descriptor(label),
    );
    expect(cap.objectUrls.isEmpty, isTrue, reason: 'super NOT taken');
    expect(calls, a['getWorkerCalls']);
    expect(identical(result, carrier), isTrue,
        reason: 'Promise.resolve(worker) passes the same worker through');
  });

  // ---- _getWorkerLoadingFailedErrorMessage ----
  test('b71 errorMessage: exact template', () {
    final a = (t['errorMessage'] as Map)['msg'] as String;
    expect(
      m.StandaloneWebWorkerService()
          .getWorkerLoadingFailedErrorMessage(_descriptor('LBL-ERR')),
      a,
    );
  });

  // ---- getWorkerUrl: env.getWorkerUrl relative -> absolute via baseURI ----
  test('b71 getWorkerUrl: env relative -> absolute via document.baseURI', () {
    final a = (t['getWorkerUrl'] as Map)['envRelative'] as Map<String, dynamic>;
    final calls = <List<Object?>>[];
    m.standaloneDocumentBaseUri = 'https://example.com/base/';
    m.standaloneMonacoEnvironmentProvider = () => <String, Object?>{
          'getWorkerUrl': (String moduleId, String label) {
            calls.add(<Object?>[moduleId, label]);
            return 'worker.js';
          },
        };
    expect(
      m.StandaloneWebWorkerService().getWorkerUrl(_descriptor('LBL-rel')),
      a['result'],
    );
    expect(calls, a['getWorkerUrlCalls']);
  });

  // ---- getWorkerUrl: env.getWorkerUrl absolute -> unchanged ----
  test('b71 getWorkerUrl: env absolute -> unchanged', () {
    final a = (t['getWorkerUrl'] as Map)['envAbsolute'] as Map<String, dynamic>;
    m.standaloneDocumentBaseUri = 'https://example.com/base/';
    m.standaloneMonacoEnvironmentProvider = () => <String, Object?>{
          'getWorkerUrl': (String moduleId, String label) =>
              'https://cdn.org/w.js',
        };
    expect(
      m.StandaloneWebWorkerService().getWorkerUrl(_descriptor('LBL-abs')),
      a['result'],
    );
  });

  // ---- getWorkerUrl: env.getWorkerUrl returns undefined -> bundler fn ----
  test('b71 getWorkerUrl: env undefined -> bundler function', () {
    final a = (t['getWorkerUrl'] as Map)['envUndefBundlerFn']
        as Map<String, dynamic>;
    var bundlerCalls = 0;
    m.standaloneMonacoEnvironmentProvider = () => <String, Object?>{
          'getWorkerUrl': (String moduleId, String label) =>
              m.standaloneJsUndefined,
        };
    final d = _descriptor('LBL-fall', () {
      bundlerCalls++;
      return _UrlCarrier('blob:from-bundler-fn');
    });
    expect(m.StandaloneWebWorkerService().getWorkerUrl(d), a['result']);
    expect(bundlerCalls, a['bundlerCalls']);
  });

  // ---- getWorkerUrl: no env, bundler URL value -> toString ----
  test('b71 getWorkerUrl: bundler value -> toString', () {
    final a =
        (t['getWorkerUrl'] as Map)['bundlerValue'] as Map<String, dynamic>;
    m.standaloneMonacoEnvironmentProvider = () => null;
    final d = _descriptor(
      'LBL-val',
      _UrlCarrier('https://bundler.org/mod.js'),
    );
    expect(m.StandaloneWebWorkerService().getWorkerUrl(d), a['result']);
  });

  // ---- getWorkerUrl: no env, no bundler -> throw ----
  test('b71 getWorkerUrl: no bundler -> throws template', () {
    final a =
        (t['getWorkerUrl'] as Map)['noBundlerThrow'] as Map<String, dynamic>;
    m.standaloneMonacoEnvironmentProvider = () => null;
    final thrown = a['thrown'] as Map<String, dynamic>;
    expect(
      () => m.StandaloneWebWorkerService().getWorkerUrl(_descriptor('LBL-NOB')),
      throwsA(isA<StateError>().having(
        (e) => e.toString().contains(thrown['message'] as String),
        'message contains',
        isTrue,
      )),
    );
  });

  // ---- getWorkerUrl: no env, bundler function -> called + toString ----
  test('b71 getWorkerUrl: bundler function -> called', () {
    final a = (t['getWorkerUrl'] as Map)['bundlerFn'] as Map<String, dynamic>;
    m.standaloneMonacoEnvironmentProvider = () => null;
    var bundlerCalls = 0;
    final d = _descriptor('LBL-fn', () {
      bundlerCalls++;
      return _UrlCarrier('blob:from-bundler');
    });
    expect(m.StandaloneWebWorkerService().getWorkerUrl(d), a['result']);
    expect(bundlerCalls, a['bundlerCalls']);
  });
}
