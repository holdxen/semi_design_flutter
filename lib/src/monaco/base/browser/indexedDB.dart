// 1:1 port of vscode/src/vs/base/browser/indexedDB.ts
// IndexedDB DOM API has no Dart equivalent: every IDB object is an opaque
// carrier and `indexedDB.open`/`deleteDatabase` go through an injectable
// [IndexedDbFactory]. All transaction / error / callback control flow matches
// the source verbatim.

import 'dart:async' show Completer;

import '../common/errorMessage.dart' show toErrorMessage;
import '../common/errors.dart' show ErrorNoTelemetry, getErrorMessage;
import '../common/performance.dart' show mark;

// ---- opaque IndexedDB carriers --------------------------------------------

/// 1:1: DOM `IDBDatabase`.
abstract class IDBDatabase {
  String get name;
  bool objectStoreNamesContains(String store);
  void createObjectStore(String store);
  IDBTransaction transaction(String store, String mode);
  void close();
}

/// 1:1: DOM `IDBTransaction`.
abstract class IDBTransaction {
  void Function()? oncomplete;
  void Function(Object? error)? onerror;
  void Function(Object? error)? onabort;
  Object? get error;
  IDBObjectStore objectStore(String store);
  void abort();
}

/// 1:1: DOM `IDBObjectStore`.
abstract class IDBObjectStore {
  IDBRequest get(Object key);
  IDBRequest put(Object value, [Object? key]);
  IDBCursor? openCursor();
}

/// 1:1: DOM `IDBRequest`.
abstract class IDBRequest {
  Object? get result;
  Object? get error;
  void Function()? onsuccess;
  void Function(Object? error)? onerror;
}

/// 1:1: DOM `IDBCursor` + its `result`.
abstract class IDBCursor {
  IDBCursorResult? get result;
  Object? get error;
  void Function()? onsuccess;
  void Function(Object? error)? onerror;
  void continueCursor();
}

/// 1:1: DOM `IDBCursorWithValue` result (`cursor.result.key/value/continue()`).
abstract class IDBCursorResult {
  Object get key;
  Object? get value;
  void continueCursor();
}

/// 1:1: `indexedDB` global factory.
abstract class IndexedDbFactory {
  IDBOpenRequest open(String name, int? version);
  IDBDeleteRequest deleteDatabase(String name);
}

/// 1:1: `IDBOpenRequest` (`error`/`result` + lifecycle handlers).
abstract class IDBOpenRequest {
  Object? get error;
  Object get result;
  set onerror(void Function()? cb);
  set onsuccess(void Function()? cb);
  set onupgradeneeded(void Function()? cb);
}

/// 1:1: `IDBOpenDBRequest` delete variant.
abstract class IDBDeleteRequest {
  Object? get error;
  set onerror(void Function(Object? err)? cb);
  set onsuccess(void Function()? cb);
}

/// Injectable `indexedDB` global. `null` mirrors an environment without IDB.
IndexedDbFactory? indexedDbFactory;

// ---- errors ---------------------------------------------------------------

/// 1:1: `class MissingStoresError extends Error`
class MissingStoresError implements Exception {
  final IDBDatabase db;
  MissingStoresError(this.db);

  @override
  String toString() => 'Missing stores';
}

/// 1:1: `export class DBClosedError extends Error`
class DBClosedError implements Exception {
  final String code = 'DBClosed';
  final String message;

  DBClosedError(String dbName)
      : message = "IndexedDB database '$dbName' is closed.";

  @override
  String toString() => message;
}

// ---- IndexedDB ------------------------------------------------------------

/// 1:1: `export class IndexedDB`
class IndexedDB {
  /// 1:1: `static async create(name, version, stores)`
  static Future<IndexedDB> create(
          String name, int? version, List<String> stores) async =>
      IndexedDB(await openDatabase(name, version, stores), name);

  /// 1:1: `private static async openDatabase(name, version, stores)`
  static Future<IDBDatabase> openDatabase(
      String name, int? version, List<String> stores) async {
    mark('code/willOpenDatabase/$name');
    try {
      return await doOpenDatabase(name, version, stores);
    } catch (err) {
      if (err is MissingStoresError) {
        // ignore: avoid_print
        print('Attempting to recreate the IndexedDB once. $name');
        try {
          await deleteDatabase(err.db);
        } catch (error) {
          // ignore: avoid_print
          print('Error while deleting the IndexedDB ${getErrorMessage(error)}');
          rethrow;
        }
        return await doOpenDatabase(name, version, stores);
      }
      rethrow;
    } finally {
      mark('code/didOpenDatabase/$name');
    }
  }

  /// 1:1: `private static doOpenDatabase(name, version, stores)`
  static Future<IDBDatabase> doOpenDatabase(
      String name, int? version, List<String> stores) {
    final CompleterOpen c = CompleterOpen();
    final IDBOpenRequest request = indexedDbFactory!.open(name, version);
    request.onerror = () => c.error(request.error);
    request.onsuccess = () {
      final IDBDatabase db = request.result as IDBDatabase;
      for (final String store in stores) {
        if (!db.objectStoreNamesContains(store)) {
          // ignore: avoid_print
          print("Error while opening IndexedDB. Could not find '$store'' object store");
          c.error(MissingStoresError(db));
          return;
        }
      }
      c.complete(db);
    };
    request.onupgradeneeded = () {
      final IDBDatabase db = request.result as IDBDatabase;
      for (final String store in stores) {
        if (!db.objectStoreNamesContains(store)) {
          db.createObjectStore(store);
        }
      }
    };
    return c.future;
  }

  /// 1:1: `private static deleteDatabase(database)`
  static Future<void> deleteDatabase(IDBDatabase database) {
    final CompleterVoid c = CompleterVoid();
    database.close();
    final IDBDeleteRequest deleteRequest =
        indexedDbFactory!.deleteDatabase(database.name);
    deleteRequest.onerror = (Object? err) => c.error(deleteRequest.error);
    deleteRequest.onsuccess = () => c.complete();
    return c.future;
  }

  IDBDatabase? database;
  final List<IDBTransaction> pendingTransactions = <IDBTransaction>[];
  final String name;

  /// 1:1: `constructor(database, name)`
  IndexedDB(IDBDatabase database, this.name) : database = database;

  /// 1:1: `hasPendingTransactions(): boolean`
  bool hasPendingTransactions() => pendingTransactions.isNotEmpty;

  /// 1:1: `close(): void`
  void close() {
    if (pendingTransactions.isNotEmpty) {
      pendingTransactions
          .take(pendingTransactions.length)
          .toList()
          .forEach((IDBTransaction transaction) => transaction.abort());
      pendingTransactions.clear();
    }
    database?.close();
    database = null;
  }

  /// 1:1: `async runInTransaction<T>(store, mode, dbRequestFn)` — the source's
  /// two overloads share one implementation; Dart returns [Object] (either a
  /// single result or a `List`) exactly as the implementation does.
  Future<Object?> runInTransaction(
    String store,
    String transactionMode,
    Object Function(IDBObjectStore store) dbRequestFn,
  ) async {
    final IDBDatabase? db = database;
    if (db == null) {
      throw DBClosedError(name);
    }
    final IDBTransaction transaction = db.transaction(store, transactionMode);
    pendingTransactions.add(transaction);
    final CompleterObject c = CompleterObject();
    // The source references `request` inside oncomplete before it is assigned
    // (captured binding). Dart uses a late variable with the same closure.
    late Object request;
    transaction.oncomplete = () {
      final Object req = request;
      if (req is List) {
        c.complete(req.map((dynamic r) => r.result).toList());
      } else {
        c.complete((req as IDBRequest).result);
      }
    };
    transaction.onerror = (Object? _) => c.error(_transactionError(transaction));
    transaction.onabort = (Object? _) => c.error(_transactionError(transaction));
    request = dbRequestFn(transaction.objectStore(store));
    try {
      return await c.future;
    } finally {
      pendingTransactions.removeWhere((t) => identical(t, transaction));
    }
  }

  /// 1:1: `async compareAndSwap<T>(store, key, expectedValue, newValue, isValid)`
  Future<Map<String, Object?>> compareAndSwap(
    String store,
    Object key,
    Object? expectedValue,
    Object newValue,
    bool Function(Object? value) isValid,
  ) async {
    final IDBDatabase? db = database;
    if (db == null) {
      throw DBClosedError(name);
    }
    final IDBTransaction transaction = db.transaction(store, 'readwrite');
    pendingTransactions.add(transaction);
    final CompleterMap c = CompleterMap();
    Object? currentValue;
    bool swapped = false;
    transaction.oncomplete = () => c.complete(<String, Object?>{
      'swapped': swapped,
      'currentValue': swapped ? newValue : currentValue,
    });
    transaction.onerror = (Object? _) => c.error(_transactionError(transaction));
    transaction.onabort = (Object? _) => c.error(_transactionError(transaction));

    final IDBObjectStore objectStore = transaction.objectStore(store);
    final IDBRequest request = objectStore.get(key);
    request.onsuccess = () {
      currentValue = isValid(request.result) ? request.result : null;
      if (currentValue == expectedValue) {
        swapped = true;
        objectStore.put(newValue, key);
      }
    };
    try {
      return await c.future;
    } finally {
      pendingTransactions.removeWhere((t) => identical(t, transaction));
    }
  }

  /// 1:1: `async getKeyValues<V>(store, isValid): Promise<Map<string, V>>`
  Future<Map<String, Object?>> getKeyValues(
    String store,
    bool Function(Object? value) isValid,
  ) async {
    final IDBDatabase? db = database;
    if (db == null) {
      throw DBClosedError(name);
    }
    final IDBTransaction transaction = db.transaction(store, 'readonly');
    pendingTransactions.add(transaction);
    final CompleterMap c = CompleterMap();
    final Map<String, Object?> items = <String, Object?>{};
    final IDBObjectStore objectStore = transaction.objectStore(store);
    final IDBCursor? cursor = objectStore.openCursor();
    if (cursor == null) {
      c.complete(items); // `ItemTable` was empty
    } else {
      cursor.onsuccess = () {
        final IDBCursorResult? result = cursor.result;
        if (result != null) {
          if (isValid(result.value)) {
            items[result.key.toString()] = result.value;
          }
          result.continueCursor();
        } else {
          c.complete(items);
        }
      };
      void onError(Object? error) {
        // ignore: avoid_print
        print('IndexedDB getKeyValues(): ${toErrorMessage(error, true)}');
        c.complete(items);
      }

      cursor.onerror = onError;
      transaction.onerror = onError;
    }
    try {
      return await c.future;
    } finally {
      pendingTransactions.removeWhere((t) => identical(t, transaction));
    }
  }

  /// 1:1: `transaction.error ? ErrorNoTelemetry.fromError(...) : new ErrorNoTelemetry('unknown error')`
  Object _transactionError(IDBTransaction transaction) => transaction.error != null
      ? ErrorNoTelemetry.fromError(transaction.error!)
      : ErrorNoTelemetry('unknown error');
}

// ---- minimal Completer carriers -------------------------------------------

class CompleterOpen {
  final Completer<IDBDatabase> _c = Completer<IDBDatabase>();
  Future<IDBDatabase> get future => _c.future;
  void complete(IDBDatabase v) => _c.complete(v);
  void error(Object? e) => _c.completeError(e ?? StateError('unknown error'));
}

class CompleterVoid {
  final Completer<void> _c = Completer<void>();
  Future<void> get future => _c.future;
  void complete() => _c.complete();
  void error(Object? e) => _c.completeError(e ?? StateError('unknown error'));
}

class CompleterObject {
  final Completer<Object?> _c = Completer<Object?>();
  Future<Object?> get future => _c.future;
  void complete(Object? v) => _c.complete(v);
  void error(Object? e) => _c.completeError(e ?? StateError('unknown error'));
}

class CompleterMap {
  final Completer<Map<String, Object?>> _c = Completer<Map<String, Object?>>();
  Future<Map<String, Object?>> get future => _c.future;
  void complete(Map<String, Object?> v) => _c.complete(v);
  void error(Object? e) => _c.completeError(e ?? StateError('unknown error'));
}
