// ---------------------------------------------------------------------------
// Port of vscode/src/vs/platform/storage/common/storage.ts
// Translated 1:1 from TypeScript.
//   - TS `const enum` -> class of static const ints; TS regular enum ->
//     class with static const int values (same numeric truth as JS).
//   - TS interface overloads -> one broad Dart signature with optional args.
//   - TS `switch` method renamed `switchTo` (`switch` is a Dart keyword).
//   - TS `protected` members are public so cross-library subclasses can
//     override them.
//   - console.group/table/log are routed through [consoleSink] for tests.
// ---------------------------------------------------------------------------

import 'dart:async';
import 'dart:convert';

import '../../../base/common/async.dart' as async;
import '../../../base/common/event.dart' as event;
import '../../../base/common/lifecycle.dart' as lifecycle;
import '../../../base/common/performance.dart' as performance;
import '../../../base/common/types.dart' as types;
import '../../../base/parts/storage/common/storage.dart' as baseStorage;
import '../../instantiation/common/instantiation.dart'
    show ServiceIdentifier, createDecorator;
import '../../userDataProfile/common/userDataProfile.dart' as userDataProfile;

/// 1:1: `export const IS_NEW_KEY`
const String IS_NEW_KEY = '__\$__isNewStorageMarker';

/// 1:1: `export const TARGET_KEY`
const String TARGET_KEY = '__\$__targetStorageMarker';

/// 1:1: `export const IStorageService = createDecorator<IStorageService>('storageService')`
final ServiceIdentifier<IStorageServiceType> IStorageService =
    createDecorator<IStorageServiceType>('storageService');

/// 1:1: `export enum WillSaveStateReason`
class WillSaveStateReason {
  static const int NONE = 0;
  static const int SHUTDOWN = 1;

  const WillSaveStateReason._();
}

/// 1:1: `export interface IWillSaveStateEvent`
class WillSaveStateEvent {
  final int reason;

  const WillSaveStateEvent(this.reason);
}

/// 1:1: `export interface IStorageEntry`
class StorageEntry {
  final String key;
  final baseStorage.StorageValue value;
  final int scope;
  final int target;

  const StorageEntry({
    required this.key,
    required this.value,
    required this.scope,
    required this.target,
  });
}

/// 1:1: `export interface IStorageValueChangeEvent`
class StorageValueChangeEvent {
  final int scope;
  final String key;
  final int? target;
  final bool? external;

  const StorageValueChangeEvent({
    required this.scope,
    required this.key,
    this.target,
    this.external,
  });

  Map<String, Object?> toJson() => <String, Object?>{
        'scope': scope,
        'key': key,
        if (target != null) 'target': target,
        if (external != null) 'external': external,
      };
}

/// 1:1: `export interface IWorkspaceStorageValueChangeEvent`
class WorkspaceStorageValueChangeEvent extends StorageValueChangeEvent {
  WorkspaceStorageValueChangeEvent(String key, int? target, bool? external)
      : super(
            scope: StorageScope.WORKSPACE,
            key: key,
            target: target,
            external: external);
}

/// 1:1: `export interface IProfileStorageValueChangeEvent`
class ProfileStorageValueChangeEvent extends StorageValueChangeEvent {
  ProfileStorageValueChangeEvent(String key, int? target, bool? external)
      : super(
            scope: StorageScope.PROFILE,
            key: key,
            target: target,
            external: external);
}

/// 1:1: `export interface IApplicationStorageValueChangeEvent`
class ApplicationStorageValueChangeEvent extends StorageValueChangeEvent {
  ApplicationStorageValueChangeEvent(String key, int? target, bool? external)
      : super(
            scope: StorageScope.APPLICATION,
            key: key,
            target: target,
            external: external);
}

/// 1:1: `export interface IApplicationSharedStorageValueChangeEvent`
class ApplicationSharedStorageValueChangeEvent
    extends StorageValueChangeEvent {
  ApplicationSharedStorageValueChangeEvent(
      String key, int? target, bool? external)
      : super(
            scope: StorageScope.APPLICATION_SHARED,
            key: key,
            target: target,
            external: external);
}

/// 1:1: `export interface IStorageTargetChangeEvent`
class StorageTargetChangeEvent {
  final int scope;

  const StorageTargetChangeEvent(this.scope);

  Map<String, Object?> toJson() => <String, Object?>{'scope': scope};
}

/// 1:1: `export const enum StorageScope`
class StorageScope {
  static const int APPLICATION_SHARED = -2;
  static const int APPLICATION = -1;
  static const int PROFILE = 0;
  static const int WORKSPACE = 1;

  const StorageScope._();
}

/// 1:1: `export const enum StorageTarget`
class StorageTarget {
  static const int USER = 0;
  static const int MACHINE = 1;

  const StorageTarget._();
}

/// 1:1: `export interface IStorageService`
/// `Type` suffix avoids colliding with the `IStorageService` service identifier.
abstract class IStorageServiceType {
  Object? get _serviceBrand;

  event.Event<StorageValueChangeEvent> onDidChangeValue(
      int scope, String? key, lifecycle.DisposableStore disposable);

  event.Event<StorageTargetChangeEvent> get onDidChangeTarget;
  event.Event<WillSaveStateEvent> get onWillSaveState;

  String? get(String key, int scope, [String? fallbackValue]);
  bool? getBoolean(String key, int scope, [bool? fallbackValue]);
  num? getNumber(String key, int scope, [num? fallbackValue]);
  Object? getObject(String key, int scope, [Object? fallbackValue]);

  Future<String?> readApplicationSharedValue(String key);

  Future<Map<String, Object?>> compareAndSwapApplicationSharedValue(
      String key, String? expectedValue, String newValue);

  void store(String key, baseStorage.StorageValue value, int scope, int target,
      [bool external = false]);

  void storeAll(List<StorageEntry> entries, bool external);

  void remove(String key, int scope, [bool external = false]);

  List<String> keys(int scope, [int? target]);

  Future<void> log();

  bool hasScope(Object scope);

  /// 1:1: `switch(...)`; Dart keyword avoided.
  Future<void> switchTo(Object to, bool preserveData);

  bool isNew(int scope);

  Future<void> optimize(int scope);

  Future<void> flush([int reason = WillSaveStateReason.NONE]);
}

/// 1:1: `interface IKeyTargets`
typedef KeyTargets = Map<String, int>;

/// 1:1: `export interface IStorageServiceOptions`
class StorageServiceOptions {
  final int flushInterval;

  const StorageServiceOptions({required this.flushInterval});
}

/// 1:1: `export function loadKeyTargets(storage: IStorage): IKeyTargets`
KeyTargets loadKeyTargets(baseStorage.IStorage storage) {
  final String? keysRaw = storage.get(TARGET_KEY);
  if (keysRaw != null && keysRaw.isNotEmpty) {
    try {
      final Object? decoded = jsonDecode(keysRaw);
      if (decoded is Map) {
        return decoded.map<String, int>((Object? key, Object? value) =>
            MapEntry<String, int>(
                key.toString(), value is int ? value : int.parse(value.toString())));
      }
    } catch (_) {
      // Fail gracefully
    }
  }

  return <String, int>{};
}

/// 1:1: `export abstract class AbstractStorageService extends Disposable implements IStorageService`
abstract class AbstractStorageService extends lifecycle.Disposable
    implements IStorageServiceType {
  /// 1:1: `private static DEFAULT_FLUSH_INTERVAL = 60 * 1000`
  static const int defaultFlushInterval = 60 * 1000;

  @override
  Object? get _serviceBrand => null;

  final event.PauseableEmitter<StorageValueChangeEvent> _onDidChangeValue =
      event.PauseableEmitter<StorageValueChangeEvent>();

  final event.PauseableEmitter<StorageTargetChangeEvent> _onDidChangeTarget =
      event.PauseableEmitter<StorageTargetChangeEvent>();

  @override
  late final event.Event<StorageTargetChangeEvent> onDidChangeTarget;

  final event.Emitter<WillSaveStateEvent> _onWillSaveState =
      event.Emitter<WillSaveStateEvent>();

  @override
  late final event.Event<WillSaveStateEvent> onWillSaveState;

  Future<void>? _initializationPromise;

  /// 1:1: `private readonly flushWhenIdleScheduler`
  late final async.RunOnceScheduler flushWhenIdleScheduler;

  /// 1:1: `private readonly runFlushWhenIdle = this._register(new MutableDisposable())`
  late final lifecycle.MutableDisposable<lifecycle.IDisposable>
      runFlushWhenIdle;

  AbstractStorageService([StorageServiceOptions? options])
      : _options = options ??
            const StorageServiceOptions(
                flushInterval: defaultFlushInterval) {
    onDidChangeTarget = _onDidChangeTarget.event;
    onWillSaveState = _onWillSaveState.event;
    runFlushWhenIdle =
        register(lifecycle.MutableDisposable<lifecycle.IDisposable>());
    flushWhenIdleScheduler = register(
      async.RunOnceScheduler(
          () => doFlushWhenIdle(), _options.flushInterval),
    );
  }

  final StorageServiceOptions _options;

  @override
  event.Event<StorageValueChangeEvent> onDidChangeValue(
      int scope, String? key, lifecycle.DisposableStore disposable) {
    return event.eventFilter<StorageValueChangeEvent>(
      _onDidChangeValue.event,
      (StorageValueChangeEvent e) =>
          e.scope == scope && (key == null || e.key == key),
      disposable,
    );
  }

  @override
  Future<String?> readApplicationSharedValue(String key) async {
    return get(key, StorageScope.APPLICATION_SHARED);
  }

  @override
  Future<Map<String, Object?>> compareAndSwapApplicationSharedValue(
      String key, String? expectedValue, String newValue) async {
    final String? currentValue = get(key, StorageScope.APPLICATION_SHARED);
    if (currentValue != expectedValue) {
      return <String, Object?>{
        'swapped': false,
        'currentValue': currentValue,
      };
    }
    store(key, newValue, StorageScope.APPLICATION_SHARED, StorageTarget.MACHINE);
    return <String, Object?>{
      'swapped': true,
      'currentValue': newValue,
    };
  }

  /// 1:1: `private doFlushWhenIdle()` (public for truth tests).
  void doFlushWhenIdle() {
    runFlushWhenIdle.value = async.runWhenGlobalIdle((_) {
      if (shouldFlushWhenIdle()) {
        flush();
      }

      // repeat
      flushWhenIdleScheduler.schedule();
    });
  }

  /// 1:1: `protected shouldFlushWhenIdle()`
  bool shouldFlushWhenIdle() => true;

  /// 1:1: `protected stopFlushWhenIdle()`
  void stopFlushWhenIdle() {
    lifecycle.dispose(<Object?>[runFlushWhenIdle, flushWhenIdleScheduler]);
  }

  Future<void> initialize() {
    return _initializationPromise ??= (() async {
      // Init all storage locations
      performance.mark('code/willInitStorage');
      try {
        await doInitialize();
      } finally {
        performance.mark('code/didInitStorage');
      }

      // Periodically ask clients to save state (see source comment).
      flushWhenIdleScheduler.schedule();
    })();
  }

  /// 1:1: `protected emitDidChangeValue`
  void emitDidChangeValue(
      int scope, baseStorage.StorageChangeEvent event) {
    final String key = event.key;
    final bool? external = event.external;

    // Specially handle `TARGET_KEY`
    if (key == TARGET_KEY) {
      // Clear our cached version which is now out of date
      switch (scope) {
        case StorageScope.APPLICATION_SHARED:
          _applicationSharedKeyTargets = null;
          break;
        case StorageScope.APPLICATION:
          _applicationKeyTargets = null;
          break;
        case StorageScope.PROFILE:
          _profileKeyTargets = null;
          break;
        case StorageScope.WORKSPACE:
          _workspaceKeyTargets = null;
          break;
      }

      // Emit as `didChangeTarget` event
      _onDidChangeTarget.fire(StorageTargetChangeEvent(scope));
    } else {
      _onDidChangeValue.fire(StorageValueChangeEvent(
        scope: scope,
        key: key,
        target: getKeyTargets(scope)[key],
        external: external,
      ));
    }
  }

  /// 1:1: `protected emitWillSaveState`
  void emitWillSaveState(int reason) {
    _onWillSaveState.fire(WillSaveStateEvent(reason));
  }

  @override
  String? get(String key, int scope, [String? fallbackValue]) {
    return getStorage(scope)?.get(key, fallbackValue);
  }

  @override
  bool? getBoolean(String key, int scope, [bool? fallbackValue]) {
    return getStorage(scope)?.getBoolean(key, fallbackValue);
  }

  @override
  num? getNumber(String key, int scope, [num? fallbackValue]) {
    return getStorage(scope)?.getNumber(key, fallbackValue);
  }

  @override
  Object? getObject(String key, int scope, [Object? fallbackValue]) {
    return getStorage(scope)?.getObject(key, fallbackValue);
  }

  @override
  void storeAll(List<StorageEntry> entries, bool external) {
    withPausedEmitters(() {
      for (final StorageEntry entry in entries) {
        store(entry.key, entry.value, entry.scope, entry.target, external);
      }
    });
  }

  @override
  void store(String key, baseStorage.StorageValue value, int scope, int target,
      [bool external = false]) {
    // We remove the key for undefined/null values
    if (types.isUndefinedOrNull(value)) {
      remove(key, scope, external);
      return;
    }

    // Update our datastructures but send events only after
    withPausedEmitters(() {
      // Update key-target map
      updateKeyTarget(key, scope, target, external);

      // Store actual value
      getStorage(scope)?.set(key, value, external);
    });
  }

  @override
  void remove(String key, int scope, [bool external = false]) {
    // Update our datastructures but send events only after
    withPausedEmitters(() {
      // Update key-target map
      updateKeyTarget(key, scope, null, external);

      // Remove actual key
      getStorage(scope)?.delete(key, external);
    });
  }

  void withPausedEmitters(void Function() fn) {
    // Pause emitters
    _onDidChangeValue.pause();
    _onDidChangeTarget.pause();

    try {
      fn();
    } finally {
      // Resume emitters
      _onDidChangeValue.resume();
      _onDidChangeTarget.resume();
    }
  }

  @override
  List<String> keys(int scope, [int? target]) {
    if (target == null) {
      return <String>[...(getStorage(scope)?.items.keys ?? <String>[])];
    }
    final List<String> keys = <String>[];

    final KeyTargets keyTargets = getKeyTargets(scope);
    for (final String key in keyTargets.keys) {
      final int keyTarget = keyTargets[key]!;
      if (keyTarget == target) {
        keys.add(key);
      }
    }

    return keys;
  }

  /// 1:1: `protected updateKeyTarget`
  void updateKeyTarget(String key, int scope, int? target,
      [bool external = false]) {
    // Add
    final KeyTargets keyTargets = getKeyTargets(scope);
    if (target is int) {
      if (keyTargets[key] != target) {
        keyTargets[key] = target;
        getStorage(scope)?.set(TARGET_KEY, jsonEncode(keyTargets), external);
      }
    } else {
      if (keyTargets[key] is int) {
        keyTargets.remove(key);
        getStorage(scope)?.set(TARGET_KEY, jsonEncode(keyTargets), external);
      }
    }
  }

  KeyTargets? _workspaceKeyTargets;
  KeyTargets get workspaceKeyTargets {
    return _workspaceKeyTargets ??=
        _loadKeyTargets(StorageScope.WORKSPACE);
  }

  KeyTargets? _profileKeyTargets;
  KeyTargets get profileKeyTargets {
    return _profileKeyTargets ??= _loadKeyTargets(StorageScope.PROFILE);
  }

  KeyTargets? _applicationKeyTargets;
  KeyTargets get applicationKeyTargets {
    return _applicationKeyTargets ??= _loadKeyTargets(StorageScope.APPLICATION);
  }

  KeyTargets? _applicationSharedKeyTargets;
  KeyTargets get applicationSharedKeyTargets {
    return _applicationSharedKeyTargets ??=
        _loadKeyTargets(StorageScope.APPLICATION_SHARED);
  }

  KeyTargets getKeyTargets(int scope) {
    switch (scope) {
      case StorageScope.APPLICATION_SHARED:
        return applicationSharedKeyTargets;
      case StorageScope.APPLICATION:
        return applicationKeyTargets;
      case StorageScope.PROFILE:
        return profileKeyTargets;
      default:
        return workspaceKeyTargets;
    }
  }

  KeyTargets _loadKeyTargets(int scope) {
    final baseStorage.IStorage? storage = getStorage(scope);

    return storage != null ? loadKeyTargets(storage) : <String, int>{};
  }

  @override
  bool isNew(int scope) => getBoolean(IS_NEW_KEY, scope) == true;

  @override
  Future<void> flush([int reason = WillSaveStateReason.NONE]) async {
    // Signal event to collect changes
    _onWillSaveState.fire(WillSaveStateEvent(reason));

    final baseStorage.IStorage? applicationStorage =
        getStorage(StorageScope.APPLICATION);
    final baseStorage.IStorage? applicationSharedStorage =
        getStorage(StorageScope.APPLICATION_SHARED);
    final baseStorage.IStorage? profileStorage =
        getStorage(StorageScope.PROFILE);
    final baseStorage.IStorage? workspaceStorage =
        getStorage(StorageScope.WORKSPACE);

    switch (reason) {
      // Unspecific reason: just wait when data is flushed
      case WillSaveStateReason.NONE:
        await async.Promises.settled<void>(<Future<void>>[
          applicationStorage?.whenFlushed() ?? Future<void>.value(),
          applicationSharedStorage?.whenFlushed() ?? Future<void>.value(),
          profileStorage?.whenFlushed() ?? Future<void>.value(),
          workspaceStorage?.whenFlushed() ?? Future<void>.value(),
        ]);
        break;

      // Shutdown: we want to flush as soon as possible
      case WillSaveStateReason.SHUTDOWN:
        await async.Promises.settled<void>(<Future<void>>[
          applicationStorage?.flush(0) ?? Future<void>.value(),
          applicationSharedStorage?.flush(0) ?? Future<void>.value(),
          profileStorage?.flush(0) ?? Future<void>.value(),
          workspaceStorage?.flush(0) ?? Future<void>.value(),
        ]);
        break;
    }
  }

  @override
  Future<void> log() async {
    final Map<String, String> applicationItems =
        getStorage(StorageScope.APPLICATION)?.items ?? <String, String>{};
    final Map<String, String> applicationSharedItems =
        getStorage(StorageScope.APPLICATION_SHARED)?.items ??
            <String, String>{};
    final Map<String, String> profileItems =
        getStorage(StorageScope.PROFILE)?.items ?? <String, String>{};
    final Map<String, String> workspaceItems =
        getStorage(StorageScope.WORKSPACE)?.items ?? <String, String>{};

    return logStorage(
      applicationItems,
      applicationSharedItems,
      profileItems,
      workspaceItems,
      getLogDetails(StorageScope.APPLICATION) ?? '',
      getLogDetails(StorageScope.APPLICATION_SHARED) ?? '',
      getLogDetails(StorageScope.PROFILE) ?? '',
      getLogDetails(StorageScope.WORKSPACE) ?? '',
    );
  }

  @override
  Future<void> optimize(int scope) async {
    // Await pending data to be flushed to the DB
    await flush();

    await getStorage(scope)?.optimize();
  }

  @override
  Future<void> switchTo(Object to, bool preserveData) async {
    // Signal as event so that clients can store data before we switch
    emitWillSaveState(WillSaveStateReason.NONE);

    if (userDataProfile.isUserDataProfile(to)) {
      return switchToProfile(
          to as userDataProfile.IUserDataProfile, preserveData);
    }

    return switchToWorkspace(to, preserveData);
  }

  /// 1:1: `protected canSwitchProfile`
  bool canSwitchProfile(
      userDataProfile.IUserDataProfile from,
      userDataProfile.IUserDataProfile to) {
    if (from.id == to.id) {
      return false; // both profiles are same
    }

    if (isProfileUsingDefaultStorage(to) &&
        isProfileUsingDefaultStorage(from)) {
      return false; // both profiles are using default
    }

    return true;
  }

  /// 1:1: `protected switchData`
  void switchData(Map<String, String> oldStorage,
      baseStorage.IStorage newStorage, int scope) {
    withPausedEmitters(() {
      // Signal storage keys that have changed
      final Set<String> handledkeys = <String>{};
      for (final MapEntry<String, String> entry in oldStorage.entries) {
        final String key = entry.key;
        final String oldValue = entry.value;
        handledkeys.add(key);

        final String? newValue = newStorage.get(key);
        if (newValue != oldValue) {
          emitDidChangeValue(
              scope, baseStorage.StorageChangeEvent(key, external: true));
        }
      }

      for (final String key in newStorage.items.keys) {
        if (!handledkeys.contains(key)) {
          emitDidChangeValue(
              scope, baseStorage.StorageChangeEvent(key, external: true));
        }
      }
    });
  }

  // --- abstract

  @override
  bool hasScope(Object scope);

  /// 1:1: `protected abstract doInitialize()`
  Future<void> doInitialize();

  /// 1:1: `protected abstract getStorage(scope)`
  baseStorage.IStorage? getStorage(int scope);

  /// 1:1: `protected abstract getLogDetails(scope)`
  String? getLogDetails(int scope);

  /// 1:1: `protected abstract switchToProfile(...)`
  Future<void> switchToProfile(
      userDataProfile.IUserDataProfile toProfile, bool preserveData);

  /// 1:1: `protected abstract switchToWorkspace(...)`
  Future<void> switchToWorkspace(Object toWorkspace, bool preserveData);
}

/// 1:1: `export function isProfileUsingDefaultStorage`
bool isProfileUsingDefaultStorage(userDataProfile.IUserDataProfile profile) {
  final Map<String, Object?>? flags = profile.useDefaultFlags;
  return profile.isDefault || flags?['globalState'] == true;
}

/// 1:1: `export class InMemoryStorageService extends AbstractStorageService`
class InMemoryStorageService extends AbstractStorageService {
  late final baseStorage.Storage applicationStorage;
  late final baseStorage.Storage applicationSharedStorage;
  late final baseStorage.Storage profileStorage;
  late final baseStorage.Storage workspaceStorage;

  static baseStorage.Storage _newStorage() => baseStorage.Storage(
        baseStorage.InMemoryStorageDatabase(),
        const baseStorage.StorageOptions(
            hint: baseStorage.StorageHint.storageInMemory),
      );

  InMemoryStorageService() : super() {
    applicationStorage = register(_newStorage());
    applicationSharedStorage = register(_newStorage());
    profileStorage = register(_newStorage());
    workspaceStorage = register(_newStorage());

    register(workspaceStorage.onDidChangeStorage((dynamic e) =>
        emitDidChangeValue(StorageScope.WORKSPACE, e as baseStorage.StorageChangeEvent)));
    register(profileStorage.onDidChangeStorage((dynamic e) =>
        emitDidChangeValue(StorageScope.PROFILE, e as baseStorage.StorageChangeEvent)));
    register(applicationStorage.onDidChangeStorage((dynamic e) =>
        emitDidChangeValue(StorageScope.APPLICATION, e as baseStorage.StorageChangeEvent)));
    register(applicationSharedStorage.onDidChangeStorage((dynamic e) =>
        emitDidChangeValue(
            StorageScope.APPLICATION_SHARED, e as baseStorage.StorageChangeEvent)));
  }

  @override
  baseStorage.IStorage getStorage(int scope) {
    switch (scope) {
      case StorageScope.APPLICATION_SHARED:
        return applicationSharedStorage;
      case StorageScope.APPLICATION:
        return applicationStorage;
      case StorageScope.PROFILE:
        return profileStorage;
      default:
        return workspaceStorage;
    }
  }

  @override
  String? getLogDetails(int scope) {
    switch (scope) {
      case StorageScope.APPLICATION_SHARED:
        return 'inMemory (application-shared)';
      case StorageScope.APPLICATION:
        return 'inMemory (application)';
      case StorageScope.PROFILE:
        return 'inMemory (profile)';
      default:
        return 'inMemory (workspace)';
    }
  }

  @override
  Future<void> doInitialize() async {}

  @override
  Future<void> switchToProfile(
      userDataProfile.IUserDataProfile toProfile, bool preserveData) async {
    // no-op when in-memory
  }

  @override
  Future<void> switchToWorkspace(Object toWorkspace, bool preserveData) async {
    // no-op when in-memory
  }

  @override
  bool shouldFlushWhenIdle() => false;

  @override
  bool hasScope(Object scope) => false;
}

/// Test hook capturing `console.group`/`console.table`/`console.log` from
/// [logStorage]. Each entry is `[operation, payload]`.
List<List<Object?>>? consoleSink;

void _logConsole(String operation, Object? payload) {
  consoleSink?.add(<Object?>[operation, payload]);
}

Object? _safeParse(String value) {
  try {
    return jsonDecode(value);
  } catch (_) {
    return value;
  }
}

List<Map<String, String>> _tableRows(Map<String, String> source) =>
    source.entries
        .map((MapEntry<String, String> e) => <String, String>{
              'key': e.key,
              'value': e.value,
            })
        .toList();

/// 1:1: `export async function logStorage(...)`
Future<void> logStorage(
  Map<String, String> application,
  Map<String, String> applicationShared,
  Map<String, String> profile,
  Map<String, String> workspace,
  String applicationPath,
  String applicationSharedPath,
  String profilePath,
  String workspacePath,
) async {
  final Map<String, String> applicationItems = <String, String>{};
  final Map<String, Object?> applicationItemsParsed = <String, Object?>{};
  application.forEach((String key, String value) {
    applicationItems[key] = value;
    applicationItemsParsed[key] = _safeParse(value);
  });

  final Map<String, String> applicationSharedItems = <String, String>{};
  final Map<String, Object?> applicationSharedItemsParsed = <String, Object?>{};
  applicationShared.forEach((String key, String value) {
    applicationSharedItems[key] = value;
    applicationSharedItemsParsed[key] = _safeParse(value);
  });

  final Map<String, String> profileItems = <String, String>{};
  final Map<String, Object?> profileItemsParsed = <String, Object?>{};
  profile.forEach((String key, String value) {
    profileItems[key] = value;
    profileItemsParsed[key] = _safeParse(value);
  });

  final Map<String, String> workspaceItems = <String, String>{};
  final Map<String, Object?> workspaceItemsParsed = <String, Object?>{};
  workspace.forEach((String key, String value) {
    workspaceItems[key] = value;
    workspaceItemsParsed[key] = _safeParse(value);
  });

  if (applicationPath != profilePath) {
    _logConsole(
        'group', 'Storage: Application (path: $applicationPath)');
  } else {
    _logConsole(
        'group',
        'Storage: Application & Profile '
        '(path: $applicationPath, default profile)');
  }
  _logConsole('table', _tableRows(applicationItems));
  _logConsole('groupEnd', null);

  _logConsole('log', applicationItemsParsed);

  _logConsole(
      'group', 'Storage: Application Shared (path: $applicationSharedPath)');
  _logConsole('table', _tableRows(applicationSharedItems));
  _logConsole('groupEnd', null);

  _logConsole('log', applicationSharedItemsParsed);

  if (applicationPath != profilePath) {
    _logConsole(
        'group', 'Storage: Profile (path: $profilePath, profile specific)');
    _logConsole('table', _tableRows(profileItems));
    _logConsole('groupEnd', null);

    _logConsole('log', profileItemsParsed);
  }

  _logConsole('group', 'Storage: Workspace (path: $workspacePath)');
  _logConsole('table', _tableRows(workspaceItems));
  _logConsole('groupEnd', null);

  _logConsole('log', workspaceItemsParsed);
}
