// ---------------------------------------------------------------------------
// Port of vscode/src/vs/editor/contrib/codelens/browser/codeLensCache.ts
// Translated 1:1. Structure, members and semantics preserved.
// Verified against the TypeScript transpile truth (batch431).
// ---------------------------------------------------------------------------

import 'dart:convert';

import '../../../../base/common/event.dart' show Event, eventFilter, eventOnce;
import '../../../../base/common/map.dart' show LRUCache;
import '../../../../platform/instantiation/common/extensions.dart'
    show InstantiationType, registerSingleton;
import '../../../../platform/instantiation/common/instantiation.dart'
    show createDecorator;
import '../../../../platform/storage/common/storage.dart'
    show
        IStorageServiceType,
        StorageScope,
        StorageTarget,
        WillSaveStateEvent,
        WillSaveStateReason;
import '../../../common/core/range.dart' show Range;
import 'codelens.dart'
    show CodeLens, CodeLensItem, CodeLensList, CodeLensModel, ICodeLensProvider;

/// 1:1: `ICodeLensCache` service identifier.
final Object ICodeLensCache = createDecorator<Object>('ICodeLensCache');

/// 1:1: `CacheItem`.
class _CacheItem {
  final int lineCount;
  final CodeLensModel data;
  _CacheItem(this.lineCount, this.data);
}

/// Idle callback injector (browser `runWhenWindowIdle`). Production passes the
/// real helper; replay passes a controlled hook.
typedef RunWhenIdle = void Function(void Function() callback);

/// 1:1: `CodeLensCache`.
class CodeLensCache {
  final IStorageServiceType _storageService;
  final RunWhenIdle _runWhenIdle;

  final ICodeLensProvider _fakeProvider = _FakeProvider();

  final LRUCache<String, _CacheItem> _cache =
      LRUCache<String, _CacheItem>(20, 0.75);

  CodeLensCache(this._storageService, [RunWhenIdle? runWhenIdle])
      : _runWhenIdle = runWhenIdle ?? ((void Function() cb) {}) {
    // remove old data
    const String oldkey = 'codelens/cache';
    _runWhenIdle(() => _storageService.remove(oldkey, StorageScope.WORKSPACE));

    // restore lens data on start
    const String key = 'codelens/cache2';
    final String raw =
        _storageService.get(key, StorageScope.WORKSPACE, '{}') ?? '{}';
    _deserialize(raw);

    // store lens data on shutdown
    final Event<WillSaveStateEvent> shutdown = eventFilter<WillSaveStateEvent>(
      _storageService.onWillSaveState,
      (WillSaveStateEvent e) => e.reason == WillSaveStateReason.SHUTDOWN,
    );
    eventOnce<WillSaveStateEvent>(shutdown)((Object? e) {
      _storageService.store(
        key,
        _serialize(),
        StorageScope.WORKSPACE,
        StorageTarget.MACHINE,
      );
    });
  }

  /// 1:1: `put`.
  void put(Object model, CodeLensModel data) {
    // create a copy of the model that is without command-ids but with
    // command-labels.
    final List<CodeLens> copyItems = data.lenses.map((CodeLensItem item) {
      final Object? command = item.symbol.command;
      return CodeLens(
        item.symbol.range,
        command != null
            ? <String, Object?>{'id': '', 'title': _titleOf(command)}
            : null,
      );
    }).toList();

    final CodeLensModel copyModel = CodeLensModel();
    copyModel.add(CodeLensList(copyItems), _fakeProvider);

    final dynamic m = model;
    final int lineCount = m.getLineCount() as int;
    _cache.set(m.uri.toString() as String, _CacheItem(lineCount, copyModel));
  }

  /// 1:1: `get`.
  CodeLensModel? get(Object model) {
    final dynamic m = model;
    final _CacheItem? item = _cache.get(m.uri.toString() as String);
    if (item != null && item.lineCount == m.getLineCount()) {
      return item.data;
    }
    return null;
  }

  /// 1:1: `delete`.
  void delete(Object model) {
    final dynamic m = model;
    _cache.delete(m.uri.toString() as String);
  }

  /// 1:1: `_serialize`.
  String _serialize() {
    final Map<String, Object> data = <String, Object>{};
    _cache.forEach((_CacheItem value, String key, dynamic map) {
      final Set<int> lines = <int>{};
      for (final CodeLensItem d in value.data.lenses) {
        lines.add(d.symbol.range.startLineNumber);
      }
      data[key] = <String, Object>{
        'lineCount': value.lineCount,
        'lines': lines.toList(),
      };
    });
    return jsonEncode(data);
  }

  /// 1:1: `_deserialize`.
  void _deserialize(String raw) {
    try {
      final Object? decoded = jsonDecode(raw);
      if (decoded is! Map) return;
      for (final Object? key in decoded.keys) {
        final Object? element = decoded[key];
        if (element is! Map) continue;
        final int lineCount = (element['lineCount'] as num).toInt();
        final List<CodeLens> lenses = <CodeLens>[];
        for (final Object? line in (element['lines'] as List)) {
          final int ln = (line as num).toInt();
          lenses.add(CodeLens(Range(ln, 1, ln, 11)));
        }
        final CodeLensModel model = CodeLensModel();
        model.add(CodeLensList(lenses), _fakeProvider);
        _cache.set(key as String, _CacheItem(lineCount, model));
      }
    } catch (_) {
      // ignore...
    }
  }

  static Object? _titleOf(Object command) =>
      command is Map ? command['title'] : (command as dynamic).title;
}

/// Local fake provider (source throws if called; never called by the cache).
class _FakeProvider implements ICodeLensProvider {
  @override
  Future<CodeLensList?> provideCodeLenses(Object model, Object token) =>
      throw StateError('not supported');

  @override
  Future<CodeLens?> Function(Object, CodeLens, Object)? get resolveCodeLens =>
      null;
}

/// Mirror the module-level singleton registration side effect.
void registerCodeLensCache(Object id, Object factory) {
  registerSingleton<Object>(id as dynamic, factory, InstantiationType.Delayed);
}
