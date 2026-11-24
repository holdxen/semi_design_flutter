// 1:1 port of
// vscode/src/vs/editor/contrib/find/browser/findWidgetSearchHistory.ts

import 'dart:convert' show jsonEncode, jsonDecode;

import '../../../../base/common/event.dart' show Emitter, Event;
import '../../../../base/common/history.dart' show IHistory;
import '../../../../platform/storage/common/storage.dart'
    show IStorageServiceType, StorageScope, StorageTarget;

/// 1:1: `export class FindWidgetSearchHistory implements IHistory<string>`
class FindWidgetSearchHistory implements IHistory<String> {
  /// 1:1: `public static readonly FIND_HISTORY_KEY = 'workbench.find.history'`
  static const String FIND_HISTORY_KEY = 'workbench.find.history';

  Set<String> inMemoryValues = <String>{};

  @override
  late final Event<List<String>>? onDidChange;
  late final Emitter<List<String>> _onDidChangeEmitter;

  static FindWidgetSearchHistory? _instance;

  /// 1:1: `static getOrCreate(storageService): FindWidgetSearchHistory`
  static FindWidgetSearchHistory getOrCreate(IStorageServiceType storageService) {
    _instance ??= FindWidgetSearchHistory(storageService);
    return _instance!;
  }

  FindWidgetSearchHistory(this.storageService) {
    _onDidChangeEmitter = Emitter<List<String>>();
    onDidChange = _onDidChangeEmitter.event;
    load();
  }

  final IStorageServiceType storageService;

  @override
  bool delete(String t) {
    final bool result = inMemoryValues.remove(t);
    save();
    return result;
  }

  @override
  FindWidgetSearchHistory add(String t) {
    inMemoryValues.add(t);
    save();
    return this;
  }

  @override
  bool has(String t) => inMemoryValues.contains(t);

  @override
  void clear() {
    inMemoryValues.clear();
    save();
  }

  @override
  void forEach(void Function(String value, String value2, Set<String> set) callbackfn,
      [Object? thisArg]) {
    // fetch latest from storage
    load();
    // TS Set.forEach passes (value, value2, set) with value === value2.
    for (final String value in inMemoryValues) {
      callbackfn(value, value, inMemoryValues);
    }
  }

  @override
  void Function(List<String> values)? get replace => _replace;

  void _replace(List<String> t) {
    inMemoryValues = t.toSet();
    save();
  }

  /// 1:1: `load()`
  void load() {
    List<String>? result;
    final String? raw = storageService.get(FIND_HISTORY_KEY, StorageScope.WORKSPACE);
    if (raw != null && raw.isNotEmpty) {
      try {
        final Object? decoded = jsonDecode(raw);
        if (decoded is List) {
          result = decoded.map((Object? e) => e.toString()).toList();
        }
      } catch (e) {
        // Invalid data
      }
    }
    inMemoryValues = (result ?? <String>[]).toSet();
  }

  /// 1:1: `save(): Promise<void>` (run saves async).
  Future<void> save() {
    final List<String> elements = inMemoryValues.toList();
    return Future<void>.sync(() {
      storageService.store(
        FIND_HISTORY_KEY,
        jsonEncode(elements),
        StorageScope.WORKSPACE,
        StorageTarget.USER,
      );
      _onDidChangeEmitter.fire(elements);
    });
  }
}
