// 1:1 port of vs/editor/common/services/languageFeatureDebounce.ts
// Adaptations:
//   - TS `for(...)` is renamed `forFeature(...)` because `for` is reserved.
//   - ILogService / IEnvironmentService / ITextModel are minimal local carriers.
//   - WeakMap identity hashing uses Dart's identity map.
// Runtime truth: tool/ts2dart/_batch266_truth.cjs (recursive TS transpile+vm).

import '../../../base/common/hash.dart' show doHash;
import '../../../base/common/map.dart' show LRUCache;
import '../../../base/common/network.dart' show matchesScheme;
import '../../../base/common/numbers.dart'
    show MovingAverage, SlidingWindowAverage, clamp;
import '../../../platform/instantiation/common/extensions.dart'
    show InstantiationType, registerSingleton;
import '../../../platform/instantiation/common/instantiation.dart'
    show ServiceIdentifier, createDecorator;
import '../languageFeatureRegistry.dart'
    show ILanguageFeatureModel, LanguageFeatureRegistry;

/// JS `${number}` renders integral doubles without `.0`; Dart does not.
String _jsNumberString(num value) =>
    value == value.round() ? value.toStringAsFixed(0) : value.toString();

/// 1:1: `export const ILanguageFeatureDebounceService = createDecorator(...)`
final ServiceIdentifier<ILanguageFeatureDebounceServiceType>
    ILanguageFeatureDebounceService =
    createDecorator<ILanguageFeatureDebounceServiceType>(
        'ILanguageFeatureDebounceService');

/// 1:1: erased `ILogService` members used here.
abstract class IDebounceLogService {
  void trace(String message);
  void debug(String message);
}

/// 1:1: erased `IEnvironmentService` members used here.
abstract class IDebounceEnvironmentService {
  bool get isExtensionDevelopment;
  bool get isBuilt;
}

/// 1:1: erased `ITextModel` members used here (extends registry carrier).
abstract class IDebounceModel implements ILanguageFeatureModel {
  String get id;
}

/// 1:1: `IFeatureDebounceInformation`
abstract class IFeatureDebounceInformation {
  num get(IDebounceModel model);
  num update(IDebounceModel model, num value);
  num defaultValue();
}

/// 1:1: `ILanguageFeatureDebounceService` (const keeps bare name)
abstract class ILanguageFeatureDebounceServiceType {
  // ignore: unused_element
  Object? get _serviceBrand;

  /// 1:1: `for(feature, debugName, config?)`
  IFeatureDebounceInformation forFeature(
    LanguageFeatureRegistry<Object?> feature,
    String debugName, [
    Map<String, Object?>? config,
  ]);
}

/// 1:1: `namespace IdentityHash`
class IdentityHash {
  static final Map<Object, int> _hashes = Map<Object, int>.identity();
  static int _pool = 0;

  /// 1:1: `of(obj)`
  static int of(Object obj) {
    int? value = _hashes[obj];
    if (value == null) {
      value = ++_pool;
      _hashes[obj] = value;
    }
    return value;
  }
}

/// 1:1: `NullDebounceInformation`
class NullDebounceInformation implements IFeatureDebounceInformation {
  final num _default;

  NullDebounceInformation(this._default);

  @override
  num get(IDebounceModel model) => _default;

  @override
  num update(IDebounceModel model, num value) => _default;

  @override
  num defaultValue() => _default;
}

/// 1:1: `FeatureDebounceInformation`
class FeatureDebounceInformation implements IFeatureDebounceInformation {
  final LRUCache<String, SlidingWindowAverage> _cache =
      LRUCache<String, SlidingWindowAverage>(50, 0.7);

  final IDebounceLogService _logService;
  final String _name;
  final LanguageFeatureRegistry<Object?> _registry;
  final num _default;
  final num _min;
  final num _max;

  FeatureDebounceInformation(
    this._logService,
    this._name,
    this._registry,
    this._default,
    this._min,
    this._max,
  );

  String _key(IDebounceModel model) {
    int hashVal = 0;
    for (final Object? obj in _registry.all(model)) {
      hashVal = doHash(IdentityHash.of(obj!), hashVal);
    }
    return model.id + hashVal.toString();
  }

  @override
  num get(IDebounceModel model) {
    final String key = _key(model);
    final SlidingWindowAverage? avg = _cache.get(key);
    return avg != null ? clamp(avg.value, _min, _max) : defaultValue();
  }

  @override
  num update(IDebounceModel model, num value) {
    final String key = _key(model);
    SlidingWindowAverage? avg = _cache.get(key);
    if (avg == null) {
      avg = SlidingWindowAverage(6);
      _cache.set(key, avg);
    }
    final num newValue = clamp(avg.update(value), _min, _max);
    if (!matchesScheme(model.uri, 'output')) {
      _logService.trace(
          '[DEBOUNCE: $_name] for ${model.uri.toString()} is ${_jsNumberString(newValue)}ms');
    }
    return newValue;
  }

  num _overall() {
    final MovingAverage result = MovingAverage();
    _cache.forEach((SlidingWindowAverage avg, String key, dynamic map) {
      result.update(avg.value);
    });
    return result.value;
  }

  @override
  num defaultValue() {
    final num value = (_overall().toInt() != 0 ? _overall().toInt() : _default);
    return clamp(value, _min, _max);
  }
}

/// 1:1: `LanguageFeatureDebounceService`
class LanguageFeatureDebounceService
    implements ILanguageFeatureDebounceServiceType {
  final Map<String, IFeatureDebounceInformation> _data =
      <String, IFeatureDebounceInformation>{};
  final bool _isDev;
  final IDebounceLogService _logService;

  @override
  // ignore: unused_element
  Object? get _serviceBrand => null;

  LanguageFeatureDebounceService(
    this._logService,
    IDebounceEnvironmentService envService,
  ) : _isDev = envService.isExtensionDevelopment || !envService.isBuilt;

  @override
  IFeatureDebounceInformation forFeature(
    LanguageFeatureRegistry<Object?> feature,
    String name, [
    Map<String, Object?>? config,
  ]) {
    final num min = (config?['min'] as num?) ?? 50;
    final num max = (config?['max'] as num?) ?? min * min;
    final Object? extra = config?['key'];
    final String key = '${IdentityHash.of(feature)},$min'
        '${extra != null ? ',$extra' : ''}';

    IFeatureDebounceInformation? info = _data[key];
    if (info == null) {
      if (_isDev) {
        _logService.debug('[DEBOUNCE: $name] is disabled in developed mode');
        info = NullDebounceInformation(min * 1.5);
      } else {
        info = FeatureDebounceInformation(
          _logService,
          name,
          feature,
          (_overallAverage().toInt() != 0
              ? _overallAverage().toInt()
              : min * 1.5),
          min,
          max,
        );
      }
      _data[key] = info;
    }
    return info;
  }

  num _overallAverage() {
    final MovingAverage result = MovingAverage();
    for (final IFeatureDebounceInformation info in _data.values) {
      result.update(info.defaultValue());
    }
    return result.value;
  }
}

/// 1:1 top-level side effect: `registerSingleton(...)`.
final ServiceIdentifier<ILanguageFeatureDebounceServiceType> registration = () {
  registerSingleton(
    ILanguageFeatureDebounceService,
    LanguageFeatureDebounceService.new,
    InstantiationType.Delayed,
  );
  return ILanguageFeatureDebounceService;
}();
