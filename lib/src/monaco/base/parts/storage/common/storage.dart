// ---------------------------------------------------------------------------
// Port of vscode/src/vs/base/parts/storage/common/storage.ts
// Translated 1:1 from TypeScript. TS enums -> Dart enums, interfaces ->
// abstract classes / carriers, `Promise` -> `Future`, `Function[]` callbacks
// -> `List<void Function()>`, `instanceof Map/Set` -> `is Map/is Set`.
// ---------------------------------------------------------------------------

import 'dart:async';

import '../../../common/async.dart' as async;
import '../../../common/event.dart' as event;
import '../../../common/lifecycle.dart' as lifecycle;
import '../../../common/marshalling.dart' as marshalling;
import '../../../common/types.dart' as types;

/// 1:1: `export enum StorageHint`
enum StorageHint {
  /// A hint to the storage that the storage does not exist on disk yet.
  storageDoesNotExist,

  /// A hint to the storage that the storage is backed by in-memory storage.
  storageInMemory,
}

/// 1:1: `export interface IStorageOptions`
class StorageOptions {
  final StorageHint? hint;

  const StorageOptions({this.hint});
}

/// 1:1: `export interface IUpdateRequest`
class UpdateRequest {
  final Map<String, String>? insert;
  final Set<String>? delete;

  const UpdateRequest({this.insert, this.delete});
}

/// 1:1: `export interface IStorageItemsChangeEvent`
class StorageItemsChangeEvent {
  final Map<String, String>? changed;
  final Set<String>? deleted;

  const StorageItemsChangeEvent({this.changed, this.deleted});
}

/// 1:1: `isStorageItemsChangeEvent`
bool isStorageItemsChangeEvent(Object? thing) {
  final StorageItemsChangeEvent? candidate = thing is StorageItemsChangeEvent
      ? thing
      : null;
  return candidate?.changed is Map || candidate?.deleted is Set;
}

/// 1:1: `export interface IStorageDatabase`
abstract class IStorageDatabase {
  event.Event<StorageItemsChangeEvent> get onDidChangeItemsExternal;

  Future<Map<String, String>> getItems();

  Future<void> updateItems(UpdateRequest request);

  Future<void> optimize();

  Future<void> close([Map<String, String> Function()? recovery]);
}

/// 1:1: `export interface IStorageChangeEvent`
class StorageChangeEvent {
  final String key;
  final bool? external;

  const StorageChangeEvent(this.key, {this.external});
}

/// 1:1: `export type StorageValue`
typedef StorageValue = Object?;

/// 1:1: `export interface IStorage`
abstract class IStorage implements lifecycle.IDisposable {
  event.Event<StorageChangeEvent> get onDidChangeStorage;

  Map<String, String> get items;
  int get size;

  Future<void> init();

  String? get(String key, [String? fallbackValue]);

  bool? getBoolean(String key, [bool? fallbackValue]);

  num? getNumber(String key, [num? fallbackValue]);

  Object? getObject(String key, [Object? fallbackValue]);

  Future<void> set(String key, StorageValue value, [bool external = false]);

  Future<void> delete(String key, [bool external = false]);

  Future<void> flush([int? delay]);

  Future<void> whenFlushed();

  Future<void> optimize();

  Future<void> close();
}

/// 1:1: `export enum StorageState`
enum StorageState { none, initialized, closed }

/// 1:1: `export class Storage extends Disposable implements IStorage`
class Storage extends lifecycle.Disposable implements IStorage {
  /// 1:1: `private static readonly DEFAULT_FLUSH_DELAY`
  static const int defaultFlushDelay = 100;

  final event.PauseableEmitter<StorageChangeEvent> _onDidChangeStorage =
      event.PauseableEmitter<StorageChangeEvent>();

  @override
  late final event.Event<StorageChangeEvent> onDidChangeStorage;

  StorageState _state = StorageState.none;

  Map<String, String> _cache = <String, String>{};

  late final async.ThrottledDelayer<void> _flushDelayer;

  Set<String> _pendingDeletes = <String>{};
  Map<String, String> _pendingInserts = <String, String>{};

  Future<void>? _pendingClose;

  final List<void Function()> _whenFlushedCallbacks = <void Function()>[];

  /// 1:1: `protected readonly database`
  final IStorageDatabase database;

  /// 1:1: `private readonly options`
  final StorageOptions _options;

  Storage(IStorageDatabase database, [StorageOptions? options])
      : database = database,
        _options = options ?? const StorageOptions() {
    onDidChangeStorage = _onDidChangeStorage.event;
    // ThrottledDelayer is not an IDisposable in the Dart port; wrap its
    // dispose() to keep the source's `_register(new ThrottledDelayer(...))`.
    final async.ThrottledDelayer<void> delayer =
        async.ThrottledDelayer<void>(Storage.defaultFlushDelay);
    _flushDelayer = delayer;
    register(lifecycle.toDisposable(delayer.dispose));
    _registerListeners();
  }

  void _registerListeners() {
    register(database.onDidChangeItemsExternal((dynamic listener) =>
        _onDidChangeItemsExternal(listener as StorageItemsChangeEvent)));
  }

  void _onDidChangeItemsExternal(StorageItemsChangeEvent e) {
    _onDidChangeStorage.pause();
    try {
      // TS Map.forEach(value, key); Dart Map.forEach is (key, value).
      e.changed?.forEach((String key, String value) =>
          _acceptExternal(key, value));
      e.deleted?.forEach(_acceptExternalDelete);
    } finally {
      _onDidChangeStorage.resume();
    }
  }

  void _acceptExternalDelete(String key) => _acceptExternal(key, null);

  void _acceptExternal(String key, String? value) {
    if (_state == StorageState.closed) {
      return;
    }

    bool changed = false;

    if (types.isUndefinedOrNull(value)) {
      changed = _cache.remove(key) != null;
    } else {
      final String? currentValue = _cache[key];
      if (currentValue != value) {
        _cache[key] = value!;
        changed = true;
      }
    }

    if (changed) {
      _onDidChangeStorage
          .fire(StorageChangeEvent(key, external: true));
    }
  }

  @override
  Map<String, String> get items => _cache;

  @override
  int get size => _cache.length;

  @override
  Future<void> init() async {
    if (_state != StorageState.none) {
      return;
    }

    _state = StorageState.initialized;

    if (_options.hint == StorageHint.storageDoesNotExist) {
      return;
    }

    _cache = await database.getItems();
  }

  @override
  String? get(String key, [String? fallbackValue]) {
    final String? value = _cache[key];
    if (types.isUndefinedOrNull(value)) {
      return fallbackValue;
    }
    return value;
  }

  @override
  bool? getBoolean(String key, [bool? fallbackValue]) {
    final String? value = get(key);
    if (types.isUndefinedOrNull(value)) {
      return fallbackValue;
    }
    return value == 'true';
  }

  @override
  num? getNumber(String key, [num? fallbackValue]) {
    final String? value = get(key);
    if (types.isUndefinedOrNull(value)) {
      return fallbackValue;
    }
    return int.tryParse(value!) ?? double.tryParse(value);
  }

  @override
  Object? getObject(String key, [Object? fallbackValue]) {
    final String? value = get(key);
    if (types.isUndefinedOrNull(value)) {
      return fallbackValue;
    }
    return marshalling.parse(value!);
  }

  @override
  Future<void> set(String key, StorageValue value, [bool external = false]) async {
    if (_state == StorageState.closed) {
      return;
    }

    if (types.isUndefinedOrNull(value)) {
      return delete(key, external);
    }

    final String valueStr = types.isObject(value) || value is List
        ? marshalling.stringify(value)
        : value.toString();

    final String? currentValue = _cache[key];
    if (currentValue == valueStr) {
      return;
    }

    _cache[key] = valueStr;
    _pendingInserts[key] = valueStr;
    _pendingDeletes.remove(key);

    _onDidChangeStorage.fire(StorageChangeEvent(key, external: external));

    return _doFlush();
  }

  @override
  Future<void> delete(String key, [bool external = false]) async {
    if (_state == StorageState.closed) {
      return;
    }

    final bool wasDeleted = _cache.remove(key) != null;
    if (!wasDeleted) {
      return;
    }

    _pendingDeletes.add(key);
    _pendingInserts.remove(key);

    _onDidChangeStorage.fire(StorageChangeEvent(key, external: external));

    return _doFlush();
  }

  @override
  Future<void> optimize() async {
    if (_state == StorageState.closed) {
      return;
    }

    await flush(0);

    return database.optimize();
  }

  @override
  Future<void> close() {
    _pendingClose ??= _doClose();
    return _pendingClose!;
  }

  Future<void> _doClose() async {
    _state = StorageState.closed;

    try {
      await _doFlush(0);
    } catch (_) {
      // Ignore
    }

    await database.close(() => _cache);
  }

  bool get _hasPending =>
      _pendingInserts.isNotEmpty || _pendingDeletes.isNotEmpty;

  Future<void> _flushPending() async {
    if (!_hasPending) {
      return;
    }

    final UpdateRequest updateRequest = UpdateRequest(
        insert: _pendingInserts, delete: _pendingDeletes);

    _pendingDeletes = <String>{};
    _pendingInserts = <String, String>{};

    return database.updateItems(updateRequest).whenComplete(() {
      if (!_hasPending) {
        while (_whenFlushedCallbacks.isNotEmpty) {
          _whenFlushedCallbacks.removeLast()();
        }
      }
    });
  }

  @override
  Future<void> flush([int? delay]) async {
    if (_state == StorageState.closed || _pendingClose != null) {
      return;
    }

    return _doFlush(delay);
  }

  Future<void> _doFlush([int? delay]) {
    if (_options.hint == StorageHint.storageInMemory) {
      return _flushPending();
    }

    return _flushDelayer
        .trigger((_) => _flushPending(), delay ?? Storage.defaultFlushDelay);
  }

  @override
  Future<void> whenFlushed() {
    if (!_hasPending) {
      return Future<void>.value();
    }

    final Completer<void> completer = Completer<void>();
    _whenFlushedCallbacks.add(() => completer.complete());
    return completer.future;
  }

  /// 1:1: `isInMemory()`
  bool isInMemory() => _options.hint == StorageHint.storageInMemory;
}

/// 1:1: `export class InMemoryStorageDatabase implements IStorageDatabase`
class InMemoryStorageDatabase implements IStorageDatabase {
  @override
  event.Event<StorageItemsChangeEvent> get onDidChangeItemsExternal =>
      event.eventNone;

  final Map<String, String> _items = <String, String>{};

  @override
  Future<Map<String, String>> getItems() async => _items;

  @override
  Future<void> updateItems(UpdateRequest request) async {
    // TS Map.forEach(value, key); Dart Map.forEach is (key, value).
    request.insert?.forEach((String key, String value) => _items[key] = value);
    request.delete?.forEach((String key) => _items.remove(key));
  }

  @override
  Future<void> optimize() async {}

  @override
  Future<void> close([Map<String, String> Function()? recovery]) async {}
}

/// 1:1: `export const MIGRATED_KEY`
const String migratedKey = '__\$__migratedStorageMarker';

/// 1:1: `export class MigratingStorage extends Storage`
class MigratingStorage extends Storage {
  Set<String> _migratedKeys = <String>{};
  IStorage? _fallbackStorage;
  bool _isFallbackStorageReadonly = false;

  MigratingStorage(IStorageDatabase database, [StorageOptions? options])
      : super(database, options);

  @override
  Future<void> init() async {
    await super.init();
    _migratedKeys = _loadMigratedKeys();
  }

  /// 1:1: `setFallbackStorage`
  void setFallbackStorage(IStorage storage, bool isReadonly) {
    _fallbackStorage = storage;
    _isFallbackStorageReadonly = isReadonly;
  }

  /// 1:1: `private static readonly INTERNAL_KEY_PREFIX`
  static const String _internalKeyPrefix = '__\$__';

  @override
  String? get(String key, [String? fallbackValue]) {
    if (!key.startsWith(_internalKeyPrefix) &&
        !_migratedKeys.contains(key) &&
        types.isUndefined(super.get(key))) {
      _migratedKeys.add(key);
      final String? value = _fallbackStorage?.items[key];
      if (!types.isUndefined(value)) {
        set(key, value);
        if (!_isFallbackStorageReadonly) {
          _fallbackStorage?.delete(key);
        }
        _persistMigratedKeys();
      }
    }
    return super.get(key, fallbackValue);
  }

  Set<String> _loadMigratedKeys() {
    final String? raw = super.get(migratedKey);
    if (raw != null && raw.isNotEmpty) {
      try {
        final Object? decoded = marshalling.parse(raw);
        if (decoded is List) {
          return decoded.map((dynamic e) => e.toString()).toSet();
        }
      } catch (_) {
        // Fail gracefully
      }
    }
    return <String>{};
  }

  void _persistMigratedKeys() {
    set(migratedKey, marshalling.stringify(_migratedKeys.toList()));
  }
}
