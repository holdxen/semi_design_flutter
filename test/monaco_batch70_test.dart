// batch70: webWorkerServiceImpl.ts. Assertions are data-driven from
// batch70_truth.json (Node TS transpile+vm real evaluation of the source with
// faithful Worker/Blob/URL/trustedTypes/self/crossOriginIsolated stubs).
import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:semi_design_flutter/src/monaco/base/common/network.dart'
    show crossOriginIsolated, globalVSCodeFileRoot;
import 'package:semi_design_flutter/src/monaco/base/common/worker/webWorker.dart'
    show IWebWorkerClient;
import 'package:semi_design_flutter/src/monaco/nls.dart'
    show setNlsLanguage, setNlsMessages;
import 'package:semi_design_flutter/src/monaco/platform/webWorker/browser/webWorkerDescriptor.dart'
    show WebWorkerDescriptor;
import 'package:semi_design_flutter/src/monaco/platform/webWorker/browser/webWorkerServiceImpl.dart'
    as m;

Map<String, dynamic> _truth() => jsonDecode(
      File('tool/ts2dart/batch70_truth.json').readAsStringSync(),
    ) as Map<String, dynamic>;

/// Faithful `MessageEvent`-like carrier with a `.data` field (JS `ev.data`).
class _MsgEvent {
  _MsgEvent(this.data);
  final Object? data;
}

/// Carrier with a `.type` field, mirroring JS `e.data.type`.
class _ReadyData {
  _ReadyData(this.type);
  final String type;
}

/// Minimal IWebWorkerClient stand-in capturing the WebWorker handed to it.
class _CaptureClient implements IWebWorkerClient {
  _CaptureClient(this.worker);
  final m.WebWorker worker;
  @override
  Object get proxy => <String, Object>{};
  @override
  void dispose() {}
  @override
  void setChannel(String channel, Object handler) {}
  @override
  Object getChannel(String channel) => <String, Object>{};
}

class _TtPolicy {
  _TtPolicy(this.name);
  final String name;
  String createScriptURL(String value) => '$name($value)';
}

/// URI carrier exposing JS `toString(skipEncoding)`.
class _UriCarrier {
  _UriCarrier(this._fn);
  final String Function(bool) _fn;
  @override
  String toString([bool skipEncoding = false]) => _fn(skipEncoding);
}

class _DescriptorWithUrl extends WebWorkerDescriptor {
  _DescriptorWithUrl(String label, this.url)
      : super(label: label);

  final String url;
  @override
  Object? get esmModuleLocation => _UriCarrier((_) => url);
}

void _reset({
  bool coi = true,
  Object? Function(String, Object?)? ttp,
  String? workerTtPolicyName,
  String? selfCtorName,
}) {
  m.createWorkerProvider = null;
  m.createObjectURLProvider = null;
  m.revokeObjectURLProvider = null;
  m.webWorkerClientFactory = (Object w) => _CaptureClient(w as m.WebWorker);
  m.workerGlobalOrigin = 'https://example.com';
  crossOriginIsolated = coi;
  setNlsMessages(<String>['msg0', 'msg1']);
  setNlsLanguage('en');
  globalVSCodeFileRoot = '/root';
  m.globalVSCodeProductJson = '{"nameShort":"Code"}';
  m.workerSelfConstructorName = selfCtorName;
  m.workerttPolicyGlobal =
      workerTtPolicyName == null ? null : _TtPolicy(workerTtPolicyName);
  m.createTrustedTypesPolicyHook = ttp;
  // service-level hook is reset per-test via direct field writes
}

Future<void> _flush() async {
  await Future<void>.delayed(Duration.zero);
  await Future<void>.delayed(Duration.zero);
}

void main() {
  final t = _truth();
  final p = t['policy'] as Map<String, dynamic>;

  setUp(() {
    _reset(ttp: (String name, Object? options) => _TtPolicy('TT'));
  });

  test('b70 createBlobWorker: non-blob throws URIError, blob applies ttPolicy', () {
    final a = p['createBlobWorker'] as Map<String, dynamic>;
    String? badName;
    String? badMsg;
    try {
      m.createBlobWorker('http://not-a-blob');
    } on m.UriError catch (e) {
      badName = 'URIError';
      badMsg = e.message;
    }
    expect(badName, a['badName']);
    expect(badMsg, a['badMsg']);

    final created = <m.PlatformWorker>[];
    m.createWorkerProvider = (String url, m.WorkerOptions? options) {
      final w = m.PlatformWorker(url, options);
      created.add(w);
      return w;
    };
    final w = m.createBlobWorker('blob:abc',
        m.WorkerOptions(name: 'lbl', type: 'other'));
    expect(created.length, 1); // a['workerCreated']
    expect(w.url, a['workerUrl']); // TT(blob:abc)
    expect(w.options?.name, 'lbl');
    expect(w.options?.type, (a['workerOptions'] as Map)['type']); // module
  });

  test('b70 noPolicy: createBlobWorker url unchanged (no ttPolicy)', () {
    final a = (t['noPolicy'] as Map<String, dynamic>)['createBlobWorker']
        as Map<String, dynamic>;
    _reset();
    m.createWorkerProvider =
        (String url, m.WorkerOptions? options) => m.PlatformWorker(url, options);
    expect(m.createBlobWorker('blob:abc').url, a['workerUrl']); // blob:abc
  });

  test('b70 workerGlobal: workerttPolicy reused, createTrustedTypesPolicy not called', () {
    final a = (t['workerGlobal'] as Map<String, dynamic>)['createBlobWorker']
        as Map<String, dynamic>;
    final ttpCalls = <String>[];
    _reset(
      selfCtorName: 'DedicatedWorkerGlobalScope',
      workerTtPolicyName: 'WP',
      ttp: (String name, Object? options) {
        ttpCalls.add(name);
        return _TtPolicy('TT');
      },
    );
    m.createWorkerProvider =
        (String url, m.WorkerOptions? options) => m.PlatformWorker(url, options);
    expect(m.createBlobWorker('blob:abc').url, a['workerUrl']); // WP(blob:abc)
    expect(ttpCalls, isEmpty);
  });

  test('b70 getWorkerUrl: missing throws, function/value call toString(true)', () {
    final a = p['getWorkerUrl'] as Map<String, dynamic>;
    final svc = m.WebWorkerService();
    String? missMsg;
    try {
      svc.getWorkerUrl(WebWorkerDescriptor(label: 'x'));
    } on StateError catch (e) {
      missMsg = e.message;
    }
    expect(missMsg, a['missMsg']);

    final skipArgs = <bool>[];
    final uri = _UriCarrier((bool skip) {
      skipArgs.add(skip);
      return 'SER/$skip';
    });
    final fnResult = svc.getWorkerUrl(WebWorkerDescriptor(
        label: 'x', esmModuleLocation: () => uri));
    final valResult = svc.getWorkerUrl(
        WebWorkerDescriptor(label: 'x', esmModuleLocation: uri));
    expect(fnResult, a['fnResult']);
    expect(valResult, a['valResult']);
    expect(skipArgs, [true, true]);
  });

  test('b70 createWorkerClient: id pool increments, descriptor vs promise/worker branching', () async {
    final a = p['createWorkerClient'] as Map<String, dynamic>;
    final workers = <m.WebWorker>[];
    m.webWorkerClientFactory = (Object w) {
      final ww = w as m.WebWorker;
      workers.add(ww);
      return _CaptureClient(ww);
    };
    m.createWorkerProvider = (String url, m.WorkerOptions? options) =>
        m.PlatformWorker(url, options);
    m.createObjectURLProvider = (Object blob) => 'blob:stub/x';
    m.revokeObjectURLProvider = (_) {};

    final svc = m.WebWorkerService();
    final c1 = svc.createWorkerClient(_DescriptorWithUrl('plain', 'file:///w.js'));
    final c2 = svc.createWorkerClient(_DescriptorWithUrl('other', 'https://other.org/x'));
    final promised = m.PlatformWorker('blob:promised');
    final c3 = svc.createWorkerClient(Future<m.PlatformWorker>.value(promised));
    final c4 = svc.createWorkerClient(m.PlatformWorker('blob:x'));

    expect(c1, isA<_CaptureClient>());
    expect(c2, isA<_CaptureClient>());
    expect(c3, isA<_CaptureClient>());
    expect(c4, isA<_CaptureClient>());
    expect(workers.length, 4);
    final ids = workers.map((w) => w.getId()).toList();
    expect(ids, a['ids']);
    expect(ids[1] > ids[0] && ids[2] > ids[1] && ids[3] > ids[2],
        a['increasing'] as bool);
    await _flush();
  });

  test('b70 bootstrap: same-origin query+fragment bug, COI param, cross-origin, err', () async {
    final boot = p['bootstrap'] as Map<String, dynamic>;
    final blobTexts = <String>[];
    final created = <m.PlatformWorker>[];
    m.createWorkerProvider = (String url, m.WorkerOptions? options) {
      final w = m.PlatformWorker(url, options);
      created.add(w);
      return w;
    };
    m.createObjectURLProvider = (Object blob) {
      final b = blob as m.PlatformBlob;
      blobTexts.add(b.text);
      return 'blob:stub/${blobTexts.length}';
    };
    final revoked = <String>[];
    m.revokeObjectURLProvider = (String url) => revoked.add(url);

    Future<void> bootCase(String label, String url) async {
      final svc = m.WebWorkerService();
      svc.createWorkerClient(_DescriptorWithUrl(label, url));
      await Future<void>.delayed(Duration.zero);
      final pw = created.last;
      (pw.onmessage as void Function(Object?))(
          _MsgEvent(_ReadyData('vscode-worker-ready')));
      await _flush();
    }

    await bootCase('LBL', 'https://example.com/out/worker.js?a=1#frag');
    final sameOriginText = (boot['sameOrigin']['blob'] as Map)['text'] as String;
    expect(blobTexts[0].contains('?a=1%23frag&vscode-coi=3#LBL'), isTrue,
        reason: 'source lastIndexOf fromIndex bug preserved');
    expect(blobTexts[0].contains('globalThis._VSCODE_NLS_MESSAGES = ["msg0","msg1"];'), isTrue);
    expect(blobTexts[0].contains('globalThis._VSCODE_PRODUCT_JSON = "{\\"nameShort\\":\\"Code\\"}"'), isTrue);
    expect(sameOriginText.contains('?a=1%23frag&vscode-coi=3#LBL'), isTrue);

    // Error branch: install a service whose protected hook returns a message
    // (mirrors the truth script's RealSvc override).
    final errSvc = m.WebWorkerService()
      ..getWorkerLoadingFailedErrorMessageHook = (_) => 'boom "quoted" msg';
    errSvc.createWorkerClient(_DescriptorWithUrl('LBLERR', 'https://example.com/out/worker.js'));
    await Future<void>.delayed(Duration.zero);
    (created.last.onmessage as void Function(Object?))(
        _MsgEvent(_ReadyData('vscode-worker-ready')));
    await _flush();
    expect(blobTexts[1].contains('try {'), isTrue);
    expect(blobTexts[1].contains('console.error("boom \\"quoted\\" msg", err)'), isTrue);

    await bootCase('LBLX', 'https://other.org/out/worker.js?x=9');
    expect(blobTexts[2].contains('https://other.org/out/worker.js?x=9"'), isTrue,
        reason: 'cross-origin: no COI param, no #label');
    expect(blobTexts[2].contains('#LBLX'), isFalse);

    await bootCase('LBLNQ', 'https://example.com/out/worker.js');
    expect(blobTexts[3].contains('worker.js?vscode-coi=3#LBLNQ'), isTrue);

    // Each successful ready handshake revokes its object URL; 4 bootCase calls.
    expect(revoked.length, 4);
  });

  test('b70 coiOff: no vscode-coi param when crossOriginIsolated false', () async {
    _reset(
      coi: false,
      ttp: (String name, Object? options) => _TtPolicy('TT'),
    );
    final blobTexts = <String>[];
    final created = <m.PlatformWorker>[];
    m.createWorkerProvider = (String url, m.WorkerOptions? options) {
      final w = m.PlatformWorker(url, options);
      created.add(w);
      return w;
    };
    m.createObjectURLProvider = (Object blob) {
      final b = blob as m.PlatformBlob;
      blobTexts.add(b.text);
      return 'blob:x';
    };
    m.revokeObjectURLProvider = (_) {};
    final svc = m.WebWorkerService();
    final w = svc.createWorkerClient(_DescriptorWithUrl('LBLNQ', 'https://example.com/out/worker.js'));
    await Future<void>.delayed(Duration.zero);
    (created.last.onmessage as void Function(Object?))(
        _MsgEvent(_ReadyData('vscode-worker-ready')));
    await _flush();
    expect(blobTexts[0].contains('vscode-coi'), isFalse);
    final a = (t['coiOff'] as Map<String, dynamic>)['bootstrap'] as Map<String, dynamic>;
    expect((a['noQuery']['blob']['text'] as String).contains('worker.js#LBLNQ'), isTrue);
    expect(w, isA<_CaptureClient>());
  });

  test('b70 WebWorker wiring: init post, message/error fire, dispose terminates', () async {
    final a = p['webWorker'] as Map<String, dynamic>;
    final fake = m.PlatformWorker('blob:ww');
    final ww = m.WebWorker(Future<m.PlatformWorker>.value(fake), 42);
    await _flush();
    final msgs = <Object?>[];
    final errs = <Object?>[];
    final dMsg = ww.onMessage((Object? x) => msgs.add(x));
    final dErr = ww.onError((Object? x) => errs.add(x));

    expect(ww.getId(), a['id']);
    final initPosted = (a['initPosted'] as List).first as List;
    expect(fake.postedMessages.first[0], initPosted.first);

    (fake.onmessage as void Function(Object?))(_MsgEvent(<String, int>{'hello': 1}));
    // 1:1: source `onmessageerror` handler fires the whole `ev` (not `ev.data`).
    (fake.onmessageerror as void Function(Object?))(<String, String>{'tag': 'merror'});
    ww.postMessage('out', <Object?>[1, 2]);
    await _flush();
    expect((msgs.first as Map)['hello'], 1);
    expect((errs.first as Map)['tag'], 'merror');
    expect(fake.postedMessages.length, a['afterPost'].length);
    expect(fake.postedMessages[1][0], 'out');

    final addError = fake.listenerOps.where((e) => e[0] == 'add' && e[1] == 'error').length;
    expect(addError, a['addedError']);

    ww.dispose();
    await _flush();
    final ad = a['afterDispose'] as Map<String, dynamic>;
    expect(fake.onmessage, isNull);
    expect(fake.onmessageerror, isNull);
    expect(fake.listenerOps.where((e) => e[0] == 'remove' && e[1] == 'error').length, ad['removedError']);
    expect(fake.terminated, ad['terminated']);
    final before = fake.postedMessages.length;
    ww.postMessage('late', const <Object?>[]);
    await _flush();
    expect(fake.postedMessages.length, before);
    dMsg.dispose();
    dErr.dispose();
  });

  test('b70 whenESMWorkerReady: wrong message ignored, onerror rejects & revokes', () async {
    final a = p['readyHandshake'] as Map<String, dynamic>;
    final fake = m.PlatformWorker('blob:r');
    m.createWorkerProvider = (String url, m.WorkerOptions? options) => fake;
    m.createObjectURLProvider = (Object blob) => 'blob:r';
    final revoked = <String>[];
    m.revokeObjectURLProvider = (String url) => revoked.add(url);
    final captured = <m.WebWorker>[];
    m.webWorkerClientFactory = (Object w) {
      final ww = w as m.WebWorker;
      captured.add(ww);
      return _CaptureClient(ww);
    };
    final svc = m.WebWorkerService();
    svc.createWorkerClient(_DescriptorWithUrl('R', 'https://example.com/r.js'));
    await Future<void>.delayed(Duration.zero);
    // wrong message ignored: onmessage remains a handler (not null)
    (fake.onmessage as void Function(Object?))(
        _MsgEvent(_ReadyData('something-else')));
    await _flush();
    expect(a['wrongIgnored'], isTrue);
    expect(fake.onmessage, isNotNull);
    // onerror -> reject; whenComplete revokes the URL
    (fake.onerror as void Function(Object?))('network-down');
    await _flush();
    expect(revoked, contains('blob:r'));
    expect(a['rejectVal'], 'network-down');
  });
}
