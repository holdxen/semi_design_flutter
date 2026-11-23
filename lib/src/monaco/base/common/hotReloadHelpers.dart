// ---------------------------------------------------------------------------
// Port of vscode/src/vs/base/common/hotReloadHelpers.ts (1:1).
// ---------------------------------------------------------------------------

import 'hotReload.dart'
    show
        HotReloadArgs,
        isHotReloadEnabled,
        registerHotReloadHandler;
import 'observable.dart'
    show
        IObservable,
        IReader,
        ISettableObservable,
        constObservable,
        observableSignalFromEvent,
        observableValue;

/// 1:1: `readHotReloadableExport(value, reader)`
Object? readHotReloadableExport(Object? value, IReader? reader) {
  observeHotReloadableExports(<Object?>[value], reader);
  return value;
}

/// 1:1: `observeHotReloadableExports(values, reader)`
void observeHotReloadableExports(List<Object?> values, IReader? reader) {
  if (isHotReloadEnabled()) {
    final IObservable<void> o = observableSignalFromEvent(
      'reload',
      (dynamic listener, [dynamic thisArgs, dynamic disposables]) {
        return registerHotReloadHandler((HotReloadArgs args) {
          final bool any = args.oldExports.values.any((v) => values.contains(v));
          if (!any) {
            return null;
          }
          return (_) {
            (listener as dynamic)(null);
            return true;
          };
        });
      },
    );
    o.read(reader);
  }
}

/// 1:1: `const classes = new Map<string, ISettableObservable<unknown>>()`
final Map<String, ISettableObservable<Object?, Object?>> _classes =
    <String, ISettableObservable<Object?, Object?>>{};

/// 1:1: `createHotClass(clazz)`
IObservable<T> createHotClass<T>(T clazz) {
  if (!isHotReloadEnabled()) {
    return constObservable<T>(clazz);
  }

  final String id = (clazz as dynamic).runtimeType.toString();
  ISettableObservable<Object?, Object?>? existing = _classes[id];
  if (existing == null) {
    existing = observableValue<Object?, Object?>(id, clazz);
    _classes[id] = existing;
  } else {
    Future<void>.delayed(Duration.zero, () {
      existing!.set(clazz, null, null);
    });
  }
  return existing as IObservable<T>;
}
