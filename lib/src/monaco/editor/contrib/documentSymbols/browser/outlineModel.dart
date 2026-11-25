// ---------------------------------------------------------------------------
// Port of vscode/src/vs/editor/contrib/documentSymbols/browser/outlineModel.ts
// Translated 1:1 from TypeScript. Structure, members and semantics preserved.
//
// Carriers:
//   - `DocumentSymbol` -> [OutlineDocumentSymbol]; `DocumentSymbolProvider` ->
//     [IDocumentSymbolProvider]; `ITextModel` -> [OutlineModelTextModel].
//   - `IOutlineMarker` -> concrete carrier; marker state -> [OutlineMarkerState].
//   - `Iterable` helpers -> base/common/iterator.dart top-level functions.
// ---------------------------------------------------------------------------

import '../../../../base/common/arrays.dart' as arrays
    show binarySearch, coalesceInPlace, equals;
import '../../../../base/common/cancellation.dart'
    show CancellationToken, CancellationTokenSource;
import '../../../../base/common/errors.dart' show onUnexpectedExternalError;
import '../../../../base/common/iterator.dart' as iter;
import '../../../../base/common/lifecycle.dart'
    show DisposableStore, IDisposable;
import '../../../../base/common/map.dart' show LRUCache;
import '../../../../platform/instantiation/common/extensions.dart'
    show InstantiationType, registerSingleton;
import '../../../../platform/instantiation/common/instantiation.dart'
    show ServiceIdentifier, createDecorator;
import '../../../../base/common/strings.dart' show commonPrefixLength;
import '../../../../base/common/uri.dart' show URI;
import '../../../common/core/position.dart' show IPosition, Position;
import '../../../common/core/range.dart' show IRange, Range;
import '../../../common/languageFeatureRegistry.dart'
    show ILanguageFeatureModel, LanguageFeatureRegistry;

/// 1:1: `DocumentSymbol` carrier.
class OutlineDocumentSymbol {
  OutlineDocumentSymbol({
    required this.name,
    required this.kind,
    required this.range,
    required this.selectionRange,
    this.tags,
    this.detail,
    this.containerName,
    this.children,
  });

  final String name;
  final int kind;
  final List<int>? tags;
  final String? detail;
  final String? containerName;
  final IRange range;
  final IRange selectionRange;
  final List<OutlineDocumentSymbol>? children;
}

/// 1:1: `DocumentSymbolProvider` contract.
abstract class IDocumentSymbolProvider {
  String? get displayName;

  Future<List<OutlineDocumentSymbol>?>
      provideDocumentSymbols(Object model, CancellationToken token);
}

/// 1:1: `ITextModel` subset for registry ordering + outline creation.
abstract class OutlineModelTextModel implements ILanguageFeatureModel {
  @override
  URI get uri;
}

/// 1:1: `IOutlineMarker`.
class OutlineMarker {
  OutlineMarker({
    required this.startLineNumber,
    required this.startColumn,
    required this.endLineNumber,
    required this.endColumn,
    required this.severity,
  });

  final int startLineNumber;
  final int startColumn;
  final int endLineNumber;
  final int endColumn;
  final int severity;

  IRange get range => Range(startLineNumber, startColumn, endLineNumber, endColumn);
}

/// 1:1: marker state `{ count, topSev }`.
class OutlineMarkerState {
  OutlineMarkerState(this.count, this.topSev);
  final int count;
  final int topSev;

  Map<String, Object?> toJson() =>
      <String, Object?>{'count': count, 'topSev': topSev};
}

/// 1:1: `export abstract class TreeElement`.
abstract class TreeElement {
  String get id;
  Map<String, TreeElement> get children;
  TreeElement? get parent;

  void remove() => parent?.children.remove(id);

  /// 1:1: `static findId(candidate, container)`.
  static String findId(Object candidate, TreeElement container) {
    String candidateId;
    if (candidate is String) {
      candidateId = '${container.id}/$candidate';
    } else {
      final OutlineDocumentSymbol sym = candidate as OutlineDocumentSymbol;
      candidateId = '${container.id}/${sym.name}';
      if (container.children.containsKey(candidateId)) {
        candidateId = '${container.id}/${sym.name}_${sym.range.startLineNumber}_${sym.range.startColumn}';
      }
    }
    String id = candidateId;
    for (int i = 0; container.children.containsKey(id); i++) {
      id = '${candidateId}_$i';
    }
    return id;
  }

  /// 1:1: `static getElementById(id, element)`.
  static TreeElement? getElementById(String id, TreeElement element) {
    if (id.isEmpty) return null;
    final int len = commonPrefixLength(id, element.id);
    if (len == id.length) return element;
    if (len < element.id.length) return null;
    for (final TreeElement child in element.children.values) {
      final TreeElement? candidate = getElementById(id, child);
      if (candidate != null) return candidate;
    }
    return null;
  }

  /// 1:1: `static size(element)`.
  static int size(TreeElement element) {
    int res = 1;
    for (final TreeElement child in element.children.values) {
      res += size(child);
    }
    return res;
  }

  /// 1:1: `static empty(element)`.
  static bool empty(TreeElement element) => element.children.isEmpty;
}

/// 1:1: `export class OutlineElement extends TreeElement`.
class OutlineElement extends TreeElement {
  OutlineElement(this.id, this.parent, this.symbol);

  @override
  final String id;
  @override
  TreeElement? parent;
  final OutlineDocumentSymbol symbol;

  final Map<String, OutlineElement> _typedChildren = <String, OutlineElement>{};

  @override
  Map<String, TreeElement> get children =>
      _typedChildren.map((k, v) => MapEntry<String, TreeElement>(k, v));

  void putChild(OutlineElement child) => _typedChildren[child.id] = child;

  Map<String, OutlineElement> get outlineChildren => _typedChildren;

  OutlineMarkerState? marker;
}

/// 1:1: `export class OutlineGroup extends TreeElement`.
class OutlineGroup extends TreeElement {
  OutlineGroup(this.id, this.parent, this.label, this.order);

  @override
  final String id;
  @override
  TreeElement? parent;
  final String label;
  final int order;

  final Map<String, OutlineElement> _typedChildren = <String, OutlineElement>{};

  @override
  Map<String, TreeElement> get children =>
      _typedChildren.map((k, v) => MapEntry<String, TreeElement>(k, v));

  void putChild(OutlineElement child) => _typedChildren[child.id] = child;

  Map<String, OutlineElement> get outlineChildren => _typedChildren;

  /// 1:1: `getItemEnclosingPosition(position)`.
  OutlineElement? getItemEnclosingPosition(IPosition position) =>
      _getItemEnclosingPosition(position, _typedChildren);

  OutlineElement? _getItemEnclosingPosition(
    IPosition position,
    Map<String, OutlineElement> children,
  ) {
    for (final OutlineElement item in children.values) {
      if (!Range.containsPositionStatic(item.symbol.range, position)) continue;
      return _getItemEnclosingPosition(position, item.outlineChildren) ?? item;
    }
    return null;
  }

  /// 1:1: `updateMarker(marker)`.
  void updateMarker(List<OutlineMarker?> markers) {
    for (final OutlineElement child in _typedChildren.values) {
      _updateMarker(markers, child);
    }
  }

  void _updateMarker(List<OutlineMarker?> markers, OutlineElement item) {
    item.marker = null;
    // TS passes the marker objects themselves (they are IRanges). Build the
    // equivalent range view for binarySearch.
    final List<IRange> markerRanges = <IRange>[
      for (final OutlineMarker? m in markers)
        if (m != null) m.range,
    ];
    final int idx = arrays.binarySearch<IRange>(
        markerRanges, item.symbol.range, Range.compareRangesUsingStarts);
    final int start;
    if (idx < 0) {
      int s = ~idx;
      if (s > 0 && Range.areIntersecting(markers[s - 1]!.range, item.symbol.range)) {
        s -= 1;
      }
      start = s;
    } else {
      start = idx;
    }

    // Shared nullable list: children null-out entries that they consume, and
    // the parent still counts the original length (matching TS semantics).
    final List<OutlineMarker?> myMarkers = <OutlineMarker?>[];
    int? myTopSev;
    int i = start;
    for (; i < markers.length &&
        Range.areIntersecting(item.symbol.range, markers[i]!.range); i++) {
      final OutlineMarker marker = markers[i]!;
      myMarkers.add(marker);
      markers[i] = null;
      if (myTopSev == null || marker.severity > myTopSev) myTopSev = marker.severity;
    }

    for (final OutlineElement child in item.outlineChildren.values) {
      _updateMarker(myMarkers, child);
    }
    if (myTopSev != null) {
      item.marker = OutlineMarkerState(myMarkers.length, myTopSev);
    }
    arrays.coalesceInPlace(markers);
  }
}

/// 1:1: `export class OutlineModel extends TreeElement`.
class OutlineModel extends TreeElement {
  static Future<OutlineModel> create(
    LanguageFeatureRegistry<IDocumentSymbolProvider> registry,
    OutlineModelTextModel textModel,
    CancellationToken token,
  ) async {
    final CancellationTokenSource cts = CancellationTokenSource(token);
    final OutlineModel result = OutlineModel._create(textModel.uri);
    final List<IDocumentSymbolProvider> provider = registry.ordered(textModel);
    final List<Future<void>> promises = <Future<void>>[];
    for (int index = 0; index < provider.length; index++) {
      final IDocumentSymbolProvider p = provider[index];
      final String id = TreeElement.findId('provider_$index', result);
      final OutlineGroup group = OutlineGroup(
          id, result, p.displayName ?? 'Unknown Outline Provider', index);
      promises.add((() async {
        try {
          final List<OutlineDocumentSymbol>? symbols =
              await p.provideDocumentSymbols(textModel, cts.token);
          for (final OutlineDocumentSymbol info in symbols ?? <OutlineDocumentSymbol>[]) {
            _makeOutlineElement(info, group);
          }
        } catch (err) {
          onUnexpectedExternalError(err);
        }
        if (!TreeElement.empty(group)) {
          result._groups[id] = group;
        } else {
          group.remove();
        }
      })());
    }

    final IDisposable listener = registry.onDidChange((dynamic _) {
      final List<IDocumentSymbolProvider> newProvider = registry.ordered(textModel);
      if (!arrays.equals(newProvider, provider)) cts.cancel();
    });

    await Future.wait(promises);
    late final OutlineModel finalResult;
    if (cts.token.isCancellationRequested && !token.isCancellationRequested) {
      finalResult = await create(registry, textModel, token);
    } else {
      finalResult = result._compact();
    }
    cts.dispose();
    listener.dispose();
    cts.dispose();
    return finalResult;
  }

  static void _makeOutlineElement(
    OutlineDocumentSymbol info,
    TreeElement container,
  ) {
    final String id = TreeElement.findId(info, container);
    final OutlineElement res = OutlineElement(id, container, info);
    if (info.children != null) {
      for (final OutlineDocumentSymbol childInfo in info.children!) {
        _makeOutlineElement(childInfo, res);
      }
    }
    if (container is OutlineGroup) {
      container.putChild(res);
    } else if (container is OutlineElement) {
      container.putChild(res);
    }
  }

  static OutlineModel? get(TreeElement? element) {
    TreeElement? e = element;
    while (e != null) {
      if (e is OutlineModel) return e;
      e = e.parent;
    }
    return null;
  }

  OutlineModel._create(this.uri) {
    id = 'root';
    parent = null;
  }

  @override
  late final String id;
  @override
  late final TreeElement? parent;
  final URI uri;

  final Map<String, OutlineGroup> _groups = <String, OutlineGroup>{};
  final Map<String, TreeElement> _children = <String, TreeElement>{};

  @override
  Map<String, TreeElement> get children => _children;

  /// 1:1: `_compact()`.
  OutlineModel _compact() {
    int count = 0;
    for (final String key in _groups.keys.toList()) {
      if (TreeElement.empty(_groups[key]!)) {
        _groups.remove(key);
      } else {
        count += 1;
      }
    }
    if (count != 1) {
      _children.clear();
      _groups.forEach((k, v) => _children[k] = v);
    } else {
      final OutlineGroup group = iter.IterableX.first(_groups.values)!;
      for (final OutlineElement child in group.outlineChildren.values) {
        child.parent = this;
        _children[child.id] = child;
      }
    }
    return this;
  }

  /// 1:1: `merge(other)`.
  bool merge(OutlineModel other) {
    if (uri.toString() != other.uri.toString()) return false;
    if (_groups.length != other._groups.length) return false;
    _groups.clear();
    _groups.addAll(other._groups);
    _children.clear();
    _children.addAll(other.children);
    return true;
  }

  /// 1:1: `getItemEnclosingPosition(position, context?)`.
  OutlineElement? getItemEnclosingPosition(IPosition position, [OutlineElement? context]) {
    OutlineGroup? preferredGroup;
    if (context != null) {
      TreeElement? candidate = context.parent;
      while (candidate != null && preferredGroup == null) {
        if (candidate is OutlineGroup) preferredGroup = candidate;
        candidate = candidate.parent;
      }
    }
    OutlineElement? result;
    for (final OutlineGroup group in _groups.values) {
      result = group.getItemEnclosingPosition(position);
      if (result != null && (preferredGroup == null || preferredGroup == group)) break;
    }
    return result;
  }

  /// 1:1: `getItemById(id)`.
  TreeElement? getItemById(String id) => TreeElement.getElementById(id, this);

  /// 1:1: `updateMarker(marker)`.
  void updateMarker(List<OutlineMarker> marker) {
    marker.sort((a, b) => Range.compareRangesUsingStarts(a.range, b.range));
    for (final OutlineGroup group in _groups.values) {
      group.updateMarker(marker.map((m) => m as OutlineMarker?).toList());
    }
  }

  /// 1:1: `getTopLevelSymbols()`.
  List<OutlineDocumentSymbol> getTopLevelSymbols() {
    final List<OutlineDocumentSymbol> roots = <OutlineDocumentSymbol>[];
    for (final TreeElement child in _children.values) {
      if (child is OutlineElement) {
        roots.add(child.symbol);
      } else if (child is OutlineGroup) {
        for (final OutlineElement c in child.outlineChildren.values) {
          roots.add(c.symbol);
        }
      }
    }
    roots.sort((a, b) => Range.compareRangesUsingStarts(a.range, b.range));
    return roots;
  }

  /// 1:1: `asListOfDocumentSymbols()`.
  List<OutlineDocumentSymbol> asListOfDocumentSymbols() {
    final List<OutlineDocumentSymbol> roots = getTopLevelSymbols();
    final List<OutlineDocumentSymbol> bucket = <OutlineDocumentSymbol>[];
    _flattenDocumentSymbols(bucket, roots, '');
    bucket.sort((a, b) {
      final int c = Position.compare(
          Range.getStartPositionStatic(a.range), Range.getStartPositionStatic(b.range));
      if (c != 0) return c;
      return Position.compare(
          Range.getEndPositionStatic(b.range), Range.getEndPositionStatic(a.range));
    });
    return bucket;
  }

  static void _flattenDocumentSymbols(
    List<OutlineDocumentSymbol> bucket,
    List<OutlineDocumentSymbol> entries,
    String overrideContainerLabel,
  ) {
    for (final OutlineDocumentSymbol entry in entries) {
      bucket.add(OutlineDocumentSymbol(
        name: entry.name,
        kind: entry.kind,
        tags: entry.tags,
        detail: entry.detail,
        containerName: entry.containerName ?? overrideContainerLabel,
        range: entry.range,
        selectionRange: entry.selectionRange,
        children: null,
      ));
      if (entry.children != null) {
        _flattenDocumentSymbols(bucket, entry.children!, entry.name);
      }
    }
  }
}

/// 1:1: `export const IOutlineModelService = createDecorator(...)`.
final ServiceIdentifier<IOutlineModelServiceType> IOutlineModelService =
    createDecorator<IOutlineModelServiceType>('IOutlineModelService');

/// 1:1: debounce information narrow carrier.
abstract class IOutlineDebounceInformation {
  int get(Object model);
  void update(Object model, int duration);
}

/// 1:1: debounce service narrow carrier (`for` renamed `forFeature` in Dart).
abstract class IOutlineDebounceService {
  IOutlineDebounceInformation forFeature(
    Object feature,
    String debugName, [
    Map<String, Object?>? config,
  ]);
}

/// 1:1: `IModelService` narrow carrier (onModelRemoved).
abstract class IOutlineModelRemovalService {
  IDisposable onModelRemoved(void Function(Object textModel) listener);
}

/// 1:1: `ILanguageFeaturesService` narrow carrier.
abstract class IOutlineFeaturesService {
  LanguageFeatureRegistry<IDocumentSymbolProvider> get documentSymbolProvider;
}

/// 1:1: `interface IOutlineModelService` (const keeps bare name).
abstract class IOutlineModelServiceType {
  Future<OutlineModel> getOrCreate(Object model, CancellationToken token);

  int getDebounceValue(Object textModel);

  Iterable<OutlineModel> getCachedModels();
}

/// 1:1: `interface CacheEntry`.
class OutlineCacheEntry {
  OutlineCacheEntry({
    required this.versionId,
    required this.provider,
    required this.promiseCnt,
    required this.source,
    required this.promise,
    required this.model,
  });

  int versionId;
  List<IDocumentSymbolProvider> provider;
  int promiseCnt;
  CancellationTokenSource source;
  Future<OutlineModel> promise;
  OutlineModel? model;
}

/// 1:1: `export class OutlineModelService implements IOutlineModelService`.
class OutlineModelService implements IOutlineModelServiceType, IDisposable {
  OutlineModelService(
    this._languageFeaturesService,
    IOutlineDebounceService debounces,
    this._modelService,
  ) {
    _debounceInformation = debounces.forFeature(
      _languageFeaturesService.documentSymbolProvider,
      'DocumentSymbols', <String, Object?>{'min': 350},
    );
    _disposables.add(_modelService.onModelRemoved((textModel) {
      final String id = (textModel as dynamic).id as String;
      _cache.delete(id);
    }));
  }

  final IOutlineFeaturesService _languageFeaturesService;
  final IOutlineModelRemovalService _modelService;
  final DisposableStore _disposables = DisposableStore();
  late final IOutlineDebounceInformation _debounceInformation;
  final LRUCache<String, OutlineCacheEntry> _cache =
      LRUCache<String, OutlineCacheEntry>(15, 0.7);

  @override
  void dispose() => _disposables.dispose();

  @override
  Future<OutlineModel> getOrCreate(Object textModel, CancellationToken token) async {
    final LanguageFeatureRegistry<IDocumentSymbolProvider> registry =
        _languageFeaturesService.documentSymbolProvider;
    final List<IDocumentSymbolProvider> provider =
        registry.ordered(textModel as OutlineModelTextModel);
    final String id = (textModel as dynamic).id as String;
    final int versionId = (textModel as dynamic).getVersionId() as int;

    OutlineCacheEntry? data = _cache.get(id);
    if (data == null ||
        data.versionId != versionId ||
        !arrays.equals(data.provider, provider)) {
      final CancellationTokenSource source = CancellationTokenSource();
      data = OutlineCacheEntry(
        versionId: versionId,
        provider: provider,
        promiseCnt: 0,
        source: source,
        promise: OutlineModel.create(registry, textModel, source.token),
        model: null,
      );
      _cache.set(id, data);
      final int now = DateTime.now().millisecondsSinceEpoch;
      data.promise.then((outlineModel) {
        data!.model = outlineModel;
        _debounceInformation.update(
            textModel, DateTime.now().millisecondsSinceEpoch - now);
      }).catchError((_) {
        _cache.delete(id);
      });
    }

    if (data.model != null) return data.model!;
    data.promiseCnt += 1;
    final OutlineCacheEntry entry = data;
    final IDisposable listener = token.onCancellationRequested(() {
      if (--entry.promiseCnt == 0) {
        entry.source.cancel();
        _cache.delete(id);
      }
    });
    try {
      return await entry.promise;
    } finally {
      listener.dispose();
    }
  }

  @override
  int getDebounceValue(Object textModel) => _debounceInformation.get(textModel);

  @override
  Iterable<OutlineModel> getCachedModels() sync* {
    for (final OutlineCacheEntry entry in _cache.values()) {
      if (entry.model != null) yield entry.model!;
    }
  }
}

/// Module-level side effect: register the service singleton.
final bool _outlineServiceRegistered = () {
  registerSingleton(IOutlineModelService, OutlineModelService,
      InstantiationType.Delayed);
  return true;
}();

/// Forces evaluation of the module-level registration.
bool ensureOutlineServiceRegistered() => _outlineServiceRegistered;
