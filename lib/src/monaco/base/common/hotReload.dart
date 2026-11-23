// ---------------------------------------------------------------------------
// Port of vscode/src/vs/base/common/hotReload.ts
// Translated 1:1. `globalThis.$hotReload_applyNewExports` is a carrier slot;
// `console.log`, `Object.getOwnPropertyNames`/`getOwnPropertyDescriptor`/
// `defineProperty` are bridged through injectable functions so library code
// has no runtime reflection dependency.
// ---------------------------------------------------------------------------

import 'lifecycle.dart' show IDisposable;

bool _isHotReloadEnabled = false;

/// 1:1: `export function enableHotReload()`
void enableHotReload() {
  _isHotReloadEnabled = true;
}

/// 1:1: `export function isHotReloadEnabled(): boolean`
bool isHotReloadEnabled() => _isHotReloadEnabled;

/// 1:1: `AcceptNewExportsHandler` / `AcceptNewExportsFn`
typedef AcceptNewExportsHandler = bool Function(Map<String, Object?> newExports);
typedef AcceptNewExportsFn = AcceptNewExportsHandler;

/// 1:1: `HotReloadConfig` (`mode?: 'patch-prototype'`)
class HotReloadConfig {
  HotReloadConfig({this.mode});
  final String? mode;
}

/// 1:1: `HotReloadHandler` args carrier.
class HotReloadArgs {
  HotReloadArgs({
    required this.oldExports,
    required this.newSrc,
    required this.config,
  });

  final Map<String, Object?> oldExports;
  final String newSrc;
  final HotReloadConfig config;
}

/// 1:1: `export type HotReloadHandler`
typedef HotReloadHandler = AcceptNewExportsHandler? Function(HotReloadArgs args);

/// 1:1: Global `$hotReload_applyNewExports` carrier slot. The source assigns
/// this onto `globalThis` on first registration; the Dart port models the same
/// single global function through a top-level nullable slot.
AcceptNewExportsFn? Function(HotReloadArgsWithOptionalConfig args)?
    hotReloadApplyNewExports;

/// 1:1: args with optional config (`GlobalThisAddition` signature).
class HotReloadArgsWithOptionalConfig {
  HotReloadArgsWithOptionalConfig({
    required this.oldExports,
    required this.newSrc,
    this.config,
  });

  final Map<String, Object?> oldExports;
  final String newSrc;
  final HotReloadConfig? config;
}

Set<HotReloadHandler>? hotReloadHandlers;

/// 1:1: `export function registerHotReloadHandler(handler): IDisposable`
IDisposable registerHotReloadHandler(HotReloadHandler handler) {
  if (!isHotReloadEnabled()) {
    return _NoopDisposable();
  }
  final Set<HotReloadHandler> handlers = registerGlobalHotReloadHandler();
  handlers.add(handler);
  return _LambdaDisposable(() => handlers.remove(handler));
}

class _NoopDisposable implements IDisposable {
  @override
  void dispose() {}
}

class _LambdaDisposable implements IDisposable {
  _LambdaDisposable(this._dispose);
  final void Function() _dispose;
  @override
  void dispose() => _dispose();
}

/// 1:1: injectable `console.log`.
void Function(String message, Object? exportedItem) hotReloadConsoleLog =
    (String message, Object? exportedItem) {};

/// Reflection bridges for the patch-prototype default handler.
List<String> Function(Object prototype) getOwnPropertyNames =
    (Object p) => <String>[];
Object? Function(Object prototype, String prop) getOwnPropertyDescriptor =
    (Object p, String prop) => null;
void Function(Object prototype, String prop, Object? descriptor)
    defineProperty = (Object p, String prop, Object? descriptor) {};
String Function(Object value) objectToString =
    (Object value) => value.toString();

/// 1:1: `registerGlobalHotReloadHandler()` — returns the handler set.
Set<HotReloadHandler> registerGlobalHotReloadHandler() {
  final Set<HotReloadHandler> handlers = hotReloadHandlers ??= <HotReloadHandler>{};

  if (hotReloadApplyNewExports == null) {
    hotReloadApplyNewExports = (HotReloadArgsWithOptionalConfig args) {
      // 1:1: `const args2 = { config: { mode: undefined }, ...args }`
      final HotReloadArgs args2 = HotReloadArgs(
        oldExports: args.oldExports,
        newSrc: args.newSrc,
        config: args.config ?? HotReloadConfig(),
      );

      final List<AcceptNewExportsHandler> results =
          <AcceptNewExportsHandler>[];
      for (final HotReloadHandler h in handlers) {
        final AcceptNewExportsHandler? result = h(args2);
        if (result != null) {
          results.add(result);
        }
      }
      if (results.isNotEmpty) {
        return (Map<String, Object?> newExports) {
          bool result = false;
          for (final AcceptNewExportsHandler r in results) {
            if (r(newExports)) {
              result = true;
            }
          }
          return result;
        };
      }
      return null;
    };
  }

  return handlers;
}

/// 1:1: module-load default handler (source guards with `if (isHotReloadEnabled())`).
/// Exposed so callers/tests can install it explicitly; in the source it runs
/// once at module load only when hot reload was already enabled.
void installDefaultHotReloadHandler() {
  registerHotReloadHandler((HotReloadArgs args) {
    if (args.config.mode != 'patch-prototype') {
      return null;
    }

    return (Map<String, Object?> newExports) {
      for (final String key in newExports.keys.toList()) {
        final Object? exportedItem = newExports[key];
        hotReloadConsoleLog("[hot-reload] Patching prototype methods of '$key'",
            exportedItem);
        if (_isFunctionWithPrototype(exportedItem)) {
          final Object prototype = _prototypeOf(exportedItem)!;
          final Object? oldExportedItem = args.oldExports[key];
          if (oldExportedItem != null) {
            final Object? oldPrototype = _prototypeOf(oldExportedItem);
            for (final String prop in getOwnPropertyNames(prototype)) {
              final Object? descriptor = getOwnPropertyDescriptor(prototype, prop);
              final Object? oldDescriptor = oldPrototype == null
                  ? null
                  : getOwnPropertyDescriptor(oldPrototype, prop);
              if (_descriptorValueToString(descriptor) !=
                  _descriptorValueToString(oldDescriptor)) {
                hotReloadConsoleLog(
                    "[hot-reload] Patching prototype method '$key.$prop'", null);
              }
              if (oldPrototype != null) {
                defineProperty(oldPrototype, prop, descriptor);
              }
            }
            newExports[key] = oldExportedItem;
          }
        }
      }
      return true;
    };
  });
}

// Runtime reflection helpers — the source uses `typeof x === 'function'` and
// `.prototype`; Dart has no first-class prototype, so a callable carrier with
// a `prototype` getter is used. These default to "not a function" and can be
// injected by callers that model such carriers.
bool Function(Object?)? isFunctionWithPrototypeProvider;
Object? Function(Object?)? prototypeOfProvider;
Object? Function(Object?)? descriptorValueProvider;

bool _isFunctionWithPrototype(Object? value) =>
    value != null &&
    (isFunctionWithPrototypeProvider?.call(value) ?? false);
Object? _prototypeOf(Object? value) =>
    value == null ? null : prototypeOfProvider?.call(value);
String? _descriptorValueToString(Object? descriptor) {
  if (descriptor == null) {
    return null;
  }
  final Object? value = descriptorValueProvider?.call(descriptor);
  return value == null ? null : objectToString(value);
}
