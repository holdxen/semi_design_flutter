// ---------------------------------------------------------------------------
// Port of vscode/src/vs/platform/observable/common/platformObservableUtils.ts
// Translated 1:1.
// ---------------------------------------------------------------------------

import '../../../base/common/lifecycle.dart' show DisposableStore, IDisposable;
import '../../../base/common/observable.dart'
    show
        DebugLocation,
        IObservable,
        IReader,
        derivedOpts,
        observableFromEvent,
        observableFromEventOpts;
import '../../../base/common/observableInternal/observables/observableFromEvent.dart'
    show ObservableFromEventOpts;
import '../../../base/common/observableInternal/observables/derived.dart'
    show DerivedOpts;
import '../../configuration/common/configuration.dart'
    show IConfigurationChangeEvent, IConfigurationServiceType;
import '../../contextkey/common/contextkey.dart'
    show IContextKeyServiceType, RawContextKey;

/// 1:1: `observableConfigValue(key, defaultValue, configurationService, debugLocation?)`
IObservable<T> observableConfigValue<T>(
  String key,
  T defaultValue,
  IConfigurationServiceType configurationService, [
  DebugLocation? debugLocation,
]) {
  return observableFromEventOpts<T, IConfigurationChangeEvent>(
    ObservableFromEventOpts(
      debugName: () => 'Configuration Key "$key"',
    ),
    (dynamic listener, [dynamic thisArgs, dynamic disposables]) {
      return configurationService.onDidChangeConfiguration((e) {
        if (e.affectsConfiguration(key)) {
          (listener as dynamic)(e);
        }
      }, thisArgs, disposables);
    },
    (IConfigurationChangeEvent? e) {
      final Object? value = configurationService.getValue$1(key);
      return (value ?? defaultValue) as T;
    },
    debugLocation,
  );
}

/// 1:1: `bindContextKey(key, service, computeValue, debugLocation?)`
IDisposable bindContextKey<T>(
  RawContextKey<T> key,
  IContextKeyServiceType service,
  T Function(IReader reader) computeValue, [
  DebugLocation? debugLocation,
]) {
  final boundKey = key.bindTo(service);
  final store = DisposableStore();
  derivedOpts<T>(
    DerivedOpts(debugName: () => 'Set Context Key "${key.key}"'),
    (IReader reader) {
      final T value = computeValue(reader);
      boundKey.set(value);
      return value;
    },
    debugLocation,
  ).recomputeInitiallyAndOnChange(store);
  return store;
}

/// 1:1: `observableContextKey(key, contextKeyService, debugLocation?)`
IObservable<T?> observableContextKey<T>(
  String key,
  IContextKeyServiceType contextKeyService, [
  DebugLocation? debugLocation,
]) {
  return observableFromEvent<T?, Object?>(
    null,
    (dynamic listener, [dynamic thisArgs, dynamic disposables]) {
      final event = contextKeyService.onDidChangeContext;
      // onDidChangeContext is an Event; register with the provided listener.
      return (event as dynamic)(listener, thisArgs, disposables) as IDisposable;
    },
    (_) => contextKeyService.getContextKeyValue<T>(key),
    debugLocation,
  );
}
