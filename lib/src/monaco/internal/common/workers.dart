// ---------------------------------------------------------------------------
// Port of monaco-editor/src/internal/common/workers.ts
// Translated 1:1 from TypeScript. Structure, members and semantics preserved.
// ---------------------------------------------------------------------------

import 'dart:async' show FutureOr;

/// 1:1: injectable `globalThis` (`MonacoEnvironment`, `trustedTypes`,
/// `workerttPolicy`).
dynamic Function() internalWorkersGlobalThisProvider = () => null;

/// 1:1: injectable `self.constructor.name` (worker global-scope detection).
String Function() internalWorkersSelfConstructorNameProvider = () => '';

/// 1:1: injectable `console.error`.
void Function(Object? error) internalWorkersConsoleError = (Object? error) {};

/// 1:1: injectable `new Worker(url, { name, type })` -> opaque Worker carrier.
Object? Function(String url, String name, String type)? internalWorkersNewWorker;

/// 1:1: injectable `editor.createWebWorker<T>({ worker, host, keepIdleModels })`.
Object? Function(Map<String, dynamic> options)? internalWorkersCreateWebWorker;

dynamic _prop(dynamic obj, String name) {
  if (obj == null) {
    return null;
  }
  if (obj is Map) {
    return obj[name];
  }
  return null;
}

/// 1:1: local `createTrustedTypesPolicy` (console.error variant, distinct from
/// `base/browser/trustedTypes.dart` which uses `onUnexpectedError`).
Object? createTrustedTypesPolicy(String policyName, [Object? policyOptions]) {
  final dynamic globalThis = internalWorkersGlobalThisProvider();
  final dynamic monacoEnvironment = _prop(globalThis, 'MonacoEnvironment');

  if (monacoEnvironment != null &&
      _prop(monacoEnvironment, 'createTrustedTypesPolicy') is Function) {
    try {
      return (_prop(monacoEnvironment, 'createTrustedTypesPolicy') as Function)(
          policyName, policyOptions);
    } catch (err) {
      internalWorkersConsoleError(err);
      return null;
    }
  }
  try {
    final dynamic trustedTypes = _prop(globalThis, 'trustedTypes');
    final dynamic createPolicy =
        trustedTypes == null ? null : _prop(trustedTypes, 'createPolicy');
    if (createPolicy is Function) {
      return createPolicy(policyName, policyOptions);
    }
    return null;
  } catch (err) {
    internalWorkersConsoleError(err);
    return null;
  }
}

/// 1:1: module-level `ttPolicy` initialization, exposed as a lazily-computed
/// value with an override slot so tests can drive both module-init branches.
Object? internalWorkersTtPolicyOverride;

Object? get ttPolicy =>
    internalWorkersTtPolicyOverride ?? _ttPolicyLazy;

final Object? _ttPolicyLazy = _computeTtPolicy();

Object? _computeTtPolicy() {
  final String selfCtorName = internalWorkersSelfConstructorNameProvider();
  final dynamic globalThis = internalWorkersGlobalThisProvider();
  if (selfCtorName == 'DedicatedWorkerGlobalScope' &&
      _prop(globalThis, 'workerttPolicy') != null) {
    return _prop(globalThis, 'workerttPolicy');
  }
  return createTrustedTypesPolicy('defaultWorkerFactory', <String, dynamic>{
    'createScriptURL': (String value) => value,
  });
}

/// 1:1: `interface IWebWorkerOptions`
class IWebWorkerOptions {
  IWebWorkerOptions({
    required this.moduleId,
    this.createWorker,
    this.createData,
    this.label,
    this.host,
    this.keepIdleModels,
  });

  final String moduleId;
  final Object? Function()? createWorker;
  final Object? createData;
  final String? label;
  final Object? host;
  final bool? keepIdleModels;
}

/// 1:1: `function getWorker(descriptor): Worker | Promise<Worker>`
///
/// Exposed publicly (source is module-private) so the branch behaviour can be
/// verified in tests; semantics unchanged.
FutureOr<Object?> getWorker(Map<String, dynamic> descriptor) {
  final String label = descriptor['label'] as String;
  final dynamic globalThis = internalWorkersGlobalThisProvider();
  final dynamic monacoEnvironment = _prop(globalThis, 'MonacoEnvironment');
  if (monacoEnvironment != null) {
    final dynamic getWorkerFn = _prop(monacoEnvironment, 'getWorker');
    if (getWorkerFn is Function) {
      return getWorkerFn('workerMain.js', label);
    }
    final dynamic getWorkerUrlFn = _prop(monacoEnvironment, 'getWorkerUrl');
    if (getWorkerUrlFn is Function) {
      final String workerUrl = getWorkerUrlFn('workerMain.js', label) as String;
      final Object? policy = ttPolicy;
      final String finalUrl = policy == null
          ? workerUrl
          : (_prop(policy, 'createScriptURL') as Function)(workerUrl) as String;
      final Object? Function(String, String, String)? newWorker =
          internalWorkersNewWorker;
      if (newWorker == null) {
        throw StateError('Worker constructor is not available');
      }
      return newWorker(finalUrl, label, 'module');
    }
  }

  final Object? Function()? createWorker =
      descriptor['createWorker'] as Object? Function()?;
  if (createWorker != null) {
    return createWorker();
  }

  throw StateError(
      'You must define a function MonacoEnvironment.getWorkerUrl or MonacoEnvironment.getWorker');
}

/// 1:1: `export function createWebWorker<T>(opts): editor.MonacoWebWorker<T>`
Object? createWebWorker(IWebWorkerOptions opts) {
  final FutureOr<Object?> worker = getWorker(<String, dynamic>{
    'label': opts.label ?? 'monaco-editor-worker',
    'moduleId': opts.moduleId,
    'createWorker': opts.createWorker,
  });

  final Future<Object?> resolved = () async {
    final Object? w = await worker;
    // 1:1: `w.postMessage('ignore'); w.postMessage(opts.createData);`
    final dynamic dw = w;
    (_prop(dw, 'postMessage') as Function)('ignore');
    (_prop(dw, 'postMessage') as Function)(opts.createData);
    return w;
  }();

  final Object? Function(Map<String, dynamic>)? createEditorWebWorker =
      internalWorkersCreateWebWorker;
  if (createEditorWebWorker == null) {
    throw StateError('editor.createWebWorker is not available');
  }
  return createEditorWebWorker(<String, dynamic>{
    'worker': resolved,
    'host': opts.host,
    'keepIdleModels': opts.keepIdleModels,
  });
}
