// ---------------------------------------------------------------------------
// Port of vscode/src/vs/editor/standalone/browser/services/
//          standaloneWebWorkerService.ts
// Translated 1:1 from TypeScript. Structure, members and semantics preserved.
//
// JS-only mechanisms bridged 1:1 by injectable carriers:
//   - `globalThis.MonacoEnvironment.getWorker/getWorkerUrl` -> [standaloneMonacoEnvironmentProvider]
//     (defaults to the base/browser [getMonacoEnvironment]); untyped so tests
//     can inject hooks that return JS `undefined`.
//   - `worker !== undefined` (undefined -> super; null -> Promise.resolve(null))
//     -> [standaloneJsUndefined] sentinel like configuration.dart's `_jsUndefined`.
//   - `new URL(workerUrl, document.baseURI).toString()` -> injectable
//     [standaloneResolveUrlProvider] + [standaloneDocumentBaseUri].
//   - `esmModuleLocationBundler: URL | (() => URL)` -> Object?, thunks called
//     before `.toString()` (faithful to `url.toString()`).
// ---------------------------------------------------------------------------

import '../../../../base/browser/browser.dart'
    show IMonacoEnvironment, getMonacoEnvironment;
import '../../../../platform/webWorker/browser/webWorkerDescriptor.dart'
    show WebWorkerDescriptor;
import '../../../../platform/webWorker/browser/webWorkerServiceImpl.dart'
    show PlatformWorker, WebWorkerService;

/// Marker for the JS `undefined` a `MonacoEnvironment.getWorker/getWorkerUrl`
/// hook may return. Distinct from Dart `null` (= JS `null`), matching the
/// source's `x !== undefined` check.
final Object standaloneJsUndefined = Object();

/// 1:1: injectable `getMonacoEnvironment()`. Defaults to the real accessor;
/// untyped (`Object?`) so a hook returning JS `undefined` can be injected.
Object? Function() standaloneMonacoEnvironmentProvider = getMonacoEnvironment;

/// 1:1: injectable `document.baseURI` (used as the base of `new URL(...)`).
String standaloneDocumentBaseUri = '';

/// 1:1: injectable `new URL(url, base).toString()`. Defaults to Dart's
/// spec-equivalent `Uri.resolve`, overridable so tests can observe the exact
/// `(url, base)` pair passed by the source.
String Function(String url, String base) standaloneResolveUrlProvider =
    (String url, String base) => Uri.parse(base).resolve(url).toString();

/// 1:1: `export class StandaloneWebWorkerService extends WebWorkerService`
class StandaloneWebWorkerService extends WebWorkerService {
  /// 1:1: `protected override _createWorker(descriptor): Promise<Worker>`
  /// Exposed publicly for the TS `protected` -> Dart mapping (see base class).
  @override
  Future<PlatformWorker> createWorker(WebWorkerDescriptor descriptor) {
    final Object? monacoEnvironment = standaloneMonacoEnvironmentProvider();
    if (monacoEnvironment != null) {
      final Object? getWorkerFn = _prop(monacoEnvironment, 'getWorker');
      if (getWorkerFn is Function) {
        final Object? worker = getWorkerFn('workerMain.js', descriptor.label);
        // 1:1: `if (worker !== undefined) return Promise.resolve(worker)`.
        if (!identical(worker, standaloneJsUndefined)) {
          return Future<PlatformWorker>.value(_asResolvedWorker(worker));
        }
      }
    }
    return super.createWorker(descriptor);
  }

  /// 1:1: `protected override _getWorkerLoadingFailedErrorMessage(descriptor): string | undefined`
  @override
  String? getWorkerLoadingFailedErrorMessage(WebWorkerDescriptor descriptor) {
    // 1:1: broken up to avoid detection by a bundler plugin.
    const String examplePath = "'...?esm'";
    return 'Failed to load worker script for label: ${descriptor.label}.\n'
        'Ensure your bundler properly bundles modules referenced by '
        '"new URL($examplePath, import.meta.url)".';
  }

  /// 1:1: `override getWorkerUrl(descriptor): string`
  @override
  String getWorkerUrl(WebWorkerDescriptor descriptor) {
    final Object? monacoEnvironment = standaloneMonacoEnvironmentProvider();
    if (monacoEnvironment != null) {
      final Object? getWorkerUrlFn = _prop(monacoEnvironment, 'getWorkerUrl');
      if (getWorkerUrlFn is Function) {
        final Object? workerUrl =
            getWorkerUrlFn('workerMain.js', descriptor.label);
        // 1:1: `if (workerUrl !== undefined)` then
        //      `new URL(workerUrl, document.baseURI).toString()`.
        if (!identical(workerUrl, standaloneJsUndefined)) {
          return standaloneResolveUrlProvider(
            workerUrl as String,
            standaloneDocumentBaseUri,
          );
        }
      }
    }

    // 1:1: `if (!descriptor.esmModuleLocationBundler) throw new Error(...)`
    if (descriptor.esmModuleLocationBundler == null) {
      throw StateError('You must define a function MonacoEnvironment.getWorkerUrl '
          'or MonacoEnvironment.getWorker for the worker label: ${descriptor.label}');
    }

    final Object loc = descriptor.esmModuleLocationBundler!;
    // 1:1: `typeof bundler === 'function' ? bundler() : bundler`
    final Object url = loc is Function ? (loc as Object Function())() : loc;
    // 1:1: `const urlStr = url.toString(); return urlStr;`
    return url.toString();
  }
}

/// JS structural property read on the MonacoEnvironment carrier: a Map is
/// read by key; the typed [IMonacoEnvironment] carrier and any dynamic object
/// expose `getWorker` / `getWorkerUrl` directly. A missing member is JS
/// `undefined` -> [standaloneJsUndefined], so `is Function` is false.
Object? _prop(Object env, String key) {
  if (env is Map) return env[key];
  if (env is IMonacoEnvironment) {
    return key == 'getWorker' ? env.getWorker : env.getWorkerUrl;
  }
  try {
    switch (key) {
      case 'getWorker':
        // ignore: avoid_dynamic_calls
        return (env as dynamic).getWorker as Object?;
      case 'getWorkerUrl':
        // ignore: avoid_dynamic_calls
        return (env as dynamic).getWorkerUrl as Object?;
    }
  } catch (_) {
    return standaloneJsUndefined; // JS `undefined` for a missing member
  }
  return standaloneJsUndefined;
}

/// JS `Promise.resolve(worker)`: a `PlatformWorker` carrier passes through; a
/// resolved Worker that is already a Future is adopted; other values (incl.
/// JS `null`) are wrapped in a carrier so the branch stays observable.
Future<PlatformWorker> _asResolvedWorker(Object? worker) {
  if (worker is Future<PlatformWorker>) return worker;
  if (worker is PlatformWorker) return Future<PlatformWorker>.value(worker);
  return Future<PlatformWorker>.value(PlatformWorker(''));
}
