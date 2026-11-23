// 1:1 port of vs/platform/markers/common/markerService.ts (429 lines)
// Adaptations (consistent with earlier batches):
//   TypeScript private members -> Dart `_`-prefixed; `readonly URI[]` -> List<URI>;
//   `Iterable<V>` -> Dart Iterable<V>; JS `map[1]` tuple access -> `.item2`;
//   `Object.create(null)` default filter -> empty marker option carrier class.
// All logic, ordering and semantics follow the source line by line.
import '../../../base/common/arrays.dart' show isFalsyOrEmpty, isNonEmptyArray;
import '../../../base/common/event.dart'
    show EmitterOptionsWithMerge, Event, MicrotaskEmitter;
import '../../../base/common/iterator.dart' show IterableX;
import '../../../base/common/lifecycle.dart' show IDisposable, toDisposable;
import '../../../base/common/map.dart' show ResourceMap, ResourceSet;
import '../../../base/common/network.dart' show Schemas;
import '../../../base/common/uri.dart' show URI;
import '../../../nls.dart' show localize;
import 'markers.dart'
    show
        IMarker,
        IMarkerChangeOptions,
        IMarkerData,
        IMarkerReadOptions,
        IMarkerServiceType,
        IRelatedInformation,
        IResourceMarker,
        MarkerSeverity,
        MarkerStatistics;

/// 1:1: `export const unsupportedSchemas = new Set([...])`
final Set<String> unsupportedSchemas = <String>{
  Schemas.inMemory,
  Schemas.vscodeSourceControl,
  Schemas.walkThrough,
  Schemas.walkThroughSnippet,
  Schemas.vscodeChatCodeBlock,
  Schemas.vscodeTerminal,
};

/// 1:1: `class DoubleResourceMap<V>`
class DoubleResourceMap<V> {
  final ResourceMap<Map<String, V>> _byResource = ResourceMap<Map<String, V>>();
  final Map<String, ResourceMap<V>> _byOwner = <String, ResourceMap<V>>{};

  /// 1:1: `set(resource, owner, value)`
  void set(URI resource, String owner, V value) {
    var ownerMap = _byResource.get(resource);
    if (ownerMap == null) {
      ownerMap = <String, V>{};
      _byResource.set(resource, ownerMap);
    }
    ownerMap[owner] = value;

    var resourceMap = _byOwner[owner];
    if (resourceMap == null) {
      resourceMap = ResourceMap<V>();
      _byOwner[owner] = resourceMap;
    }
    resourceMap.set(resource, value);
  }

  /// 1:1: `get(resource, owner): V | undefined`
  V? get(URI resource, String owner) => _byResource.get(resource)?[owner];

  /// 1:1: `delete(resource, owner): boolean`
  bool delete(URI resource, String owner) {
    var removedA = false;
    var removedB = false;
    final ownerMap = _byResource.get(resource);
    if (ownerMap != null) {
      removedA = ownerMap.remove(owner) != null;
      if (ownerMap.isEmpty) {
        _byResource.delete(resource);
      }
    }
    final resourceMap = _byOwner[owner];
    if (resourceMap != null) {
      removedB = resourceMap.delete(resource);
      if (resourceMap.size == 0) {
        _byOwner.remove(owner);
      }
    }
    if (removedA != removedB) {
      throw StateError('illegal state');
    }
    return removedA && removedB;
  }

  /// 1:1: `values(key?: URI | string): Iterable<V>`
  Iterable<V> values([Object? key]) {
    if (key is String) {
      return _byOwner[key]?.values() ?? IterableX.empty();
    }
    if (key is URI) {
      return _byResource.get(key)?.values ?? IterableX.empty();
    }
    // 1:1: `Iterable.map(Iterable.concat(...this._byOwner.values()), map => map[1])`
    // Each ResourceMap iterates as (URI, V) entries; `map[1]` is the value.
    // Dart: expand over each owner-map's values() (identical order/content).
    return _byOwner.values.expand((ResourceMap<V> rm) => rm.values());
  }
}

/// 1:1: `interface IMarkers`
abstract class IMarkers {
  List<IMarker> get markers;
  bool get isTruncated;
}

/// Concrete carrier for the `IMarkers` structural interface (source creates
/// object literals `{ markers, isTruncated }`).
class _Markers implements IMarkers {
  @override
  final List<IMarker> markers;
  @override
  final bool isTruncated;
  _Markers(this.markers, this.isTruncated);
}

/// 1:1: `class MarkerStats implements MarkerStatistics`
class MarkerStats implements MarkerStatistics {
  @override
  int errors = 0;
  @override
  int infos = 0;
  @override
  int warnings = 0;
  @override
  int unknowns = 0;

  final ResourceMap<MarkerStatistics> _data = ResourceMap<MarkerStatistics>();
  final IMarkerServiceType _service;
  late final IDisposable _subscription;

  /// 1:1: `constructor(service)`
  MarkerStats(IMarkerServiceType service) : _service = service {
    _subscription = service.onMarkerChanged(
        (dynamic e) => _update(e as List<URI>), this);
  }

  void dispose() => _subscription.dispose();

  /// 1:1: `_update(resources: readonly URI[])`
  void _update(List<URI> resources) {
    for (final resource in resources) {
      final oldStats = _data.get(resource);
      if (oldStats != null) {
        _substract(oldStats);
      }
      final newStats = _resourceStats(resource);
      _add(newStats);
      _data.set(resource, newStats);
    }
  }

  /// 1:1: `_resourceStats(resource): MarkerStatistics`
  MarkerStatistics _resourceStats(URI resource) {
    // Source uses an object literal `{ errors:0, warnings:0, infos:0, unknowns:0 }`.
    final result = _StatCarrier();

    // TODO this is a hack
    if (unsupportedSchemas.contains(resource.scheme)) {
      return result;
    }

    for (final marker in _service.read(_ReadOpts(resource: resource))) {
      final severity = marker.severity;
      if (severity == MarkerSeverity.Error) {
        result.errors += 1;
      } else if (severity == MarkerSeverity.Warning) {
        result.warnings += 1;
      } else if (severity == MarkerSeverity.Info) {
        result.infos += 1;
      } else {
        result.unknowns += 1;
      }
    }

    return result;
  }

  /// 1:1: `_substract(op: MarkerStatistics)`
  void _substract(MarkerStatistics op) {
    errors -= op.errors;
    warnings -= op.warnings;
    infos -= op.infos;
    unknowns -= op.unknowns;
  }

  /// 1:1: `_add(op: MarkerStatistics)`
  void _add(MarkerStatistics op) {
    errors += op.errors;
    warnings += op.warnings;
    infos += op.infos;
    unknowns += op.unknowns;
  }
}

/// Carrier for the `MarkerStatistics` object literal in `_resourceStats`.
class _StatCarrier implements MarkerStatistics {
  @override
  int errors = 0;
  @override
  int warnings = 0;
  @override
  int infos = 0;
  @override
  int unknowns = 0;
}

/// Carrier for the `IMarkerReadOptions` object literal `{ resource }`.
class _ReadOpts implements IMarkerReadOptions {
  @override
  final URI? resource;
  _ReadOpts({this.resource});
  @override
  String? get owner => null;
  @override
  int? get severities => null;
  @override
  int? get take => null;
  @override
  bool? get ignoreResourceFilters => null;
}

/// 1:1: `export class MarkerService implements IMarkerService`
class MarkerService implements IMarkerServiceType {
  // ignore: unused_element
  Object? get _serviceBrand => null; // 1:1: `declare readonly _serviceBrand: undefined`

  final _onMarkerChanged = MicrotaskEmitter<List<URI>>(
    EmitterOptionsWithMerge<List<URI>>(MarkerService._merge),
  );

  @override
  late final Event<List<URI>> onMarkerChanged = _onMarkerChanged.event;

  final DoubleResourceMap<IMarkers> _data = DoubleResourceMap<IMarkers>();
  // 1:1: `private readonly _stats = new MarkerStats(this)` — Dart disallows
  // `this` in field initializers AND initializer lists, so it is assigned as
  // the first statement of the constructor body (still before any fire()).
  late final MarkerStats _stats;
  final ResourceMap<List<String>> _filteredResources =
      ResourceMap<List<String>>();

  MarkerService() {
    _stats = MarkerStats(this);
  }

  /// Source: `dispose()` (not part of IMarkerService, but present on the class).
  void dispose() {
    _stats.dispose();
    _onMarkerChanged.dispose();
  }

  @override
  MarkerStatistics getStatistics() => _stats;

  @override
  bool isSourceTruncated(URI resource) => IterableX.some(
      _data.values(resource), (IMarkers markers, int i) => markers.isTruncated);

  @override
  void remove(String owner, List<URI> resources) {
    for (final resource in resources) {
      changeOne(owner, resource, const <IMarkerData>[]);
    }
  }

  @override
  void changeOne(String owner, URI resource, List<IMarkerData> markerData,
      [IMarkerChangeOptions? options]) {
    if (isFalsyOrEmpty(markerData)) {
      // remove marker for this (owner,resource)-tuple
      final removed = _data.delete(resource, owner);
      if (removed) {
        _onMarkerChanged.fire(<URI>[resource]);
      }
    } else {
      // insert marker for this (owner,resource)-tuple
      final markers = <IMarker>[];
      for (final data in markerData) {
        final marker = MarkerService._toMarker(owner, resource, data);
        if (marker != null) {
          markers.add(marker);
        }
      }
      _data.set(resource, owner,
          _Markers(markers, options?.isTruncated ?? false));
      _onMarkerChanged.fire(<URI>[resource]);
    }
  }

  @override
  IDisposable installResourceFilter(URI resource, String reason) {
    var reasons = _filteredResources.get(resource);
    if (reasons == null) {
      reasons = <String>[];
      _filteredResources.set(resource, reasons);
    }
    reasons.add(reason);
    _onMarkerChanged.fire(<URI>[resource]);

    return toDisposable(() {
      final reasons = _filteredResources.get(resource);
      if (reasons == null) {
        return;
      }
      final reasonIndex = reasons.indexOf(reason);
      if (reasonIndex != -1) {
        reasons.removeAt(reasonIndex);
        if (reasons.isEmpty) {
          _filteredResources.delete(resource);
        }
        _onMarkerChanged.fire(<URI>[resource]);
      }
    });
  }

  /// 1:1: `_toMarker(owner, resource, data): IMarker | undefined`
  static IMarker? _toMarker(String owner, URI resource, IMarkerData data) {
    var code = data.code;
    var severity = data.severity;
    var message = data.message;
    var source = data.source;
    var startLineNumber = data.startLineNumber;
    var startColumn = data.startColumn;
    var endLineNumber = data.endLineNumber;
    var endColumn = data.endColumn;
    final relatedInformation = data.relatedInformation;
    final modelVersionId = data.modelVersionId;
    final tags = data.tags;
    final origin = data.origin;

    if (message.isEmpty) {
      return null;
    }

    // santize data
    startLineNumber = startLineNumber > 0 ? startLineNumber : 1;
    startColumn = startColumn > 0 ? startColumn : 1;
    endLineNumber = endLineNumber >= startLineNumber ? endLineNumber : startLineNumber;
    endColumn = endColumn > 0 ? endColumn : startColumn;

    return _Marker(
      resource: resource,
      owner: owner,
      code: code,
      severity: severity,
      message: message,
      source: source,
      startLineNumber: startLineNumber,
      startColumn: startColumn,
      endLineNumber: endLineNumber,
      endColumn: endColumn,
      relatedInformation: relatedInformation,
      modelVersionId: modelVersionId,
      tags: tags,
      origin: origin,
    );
  }

  @override
  void changeAll(String owner, List<IResourceMarker> data) {
    final changes = <URI>[];

    // remove old marker
    // JS spread `...this._byOwner.values()` is eager; snapshot here since
    // _data.delete below mutates the underlying map during iteration.
    final existing = _data.values(owner).toList();
    for (final d in existing) {
      final first = IterableX.first(d.markers);
      if (first != null) {
        changes.add(first.resource);
        _data.delete(first.resource, owner);
      }
    }

    // add new markers
    if (isNonEmptyArray(data)) {
      // group by resource
      final groups = ResourceMap<List<IMarker>>();
      for (final d in data) {
        final marker = MarkerService._toMarker(owner, d.resource, d.marker);
        if (marker == null) {
          // filter bad markers
          continue;
        }
        final array = groups.get(d.resource);
        if (array == null) {
          groups.set(d.resource, <IMarker>[marker]);
          changes.add(d.resource);
        } else {
          array.add(marker);
        }
      }

      // insert all
      for (final entry in groups.entries()) {
        _data.set(entry.$1, owner, _Markers(entry.$2, false));
      }
    }

    if (changes.isNotEmpty) {
      _onMarkerChanged.fire(changes);
    }
  }

  /// 1:1: `_createFilteredMarker(resource, reasons): IMarker`
  IMarker _createFilteredMarker(URI resource, List<String> reasons) {
    final message = reasons.length == 1
        ? localize('filtered', 'Problems are paused because: "{0}"', [reasons[0]])
        : localize('filtered.network',
            'Problems are paused because: "{0}" and {1} more',
            [reasons[0], reasons.length - 1]);

    return _Marker(
      owner: 'markersFilter',
      resource: resource,
      severity: MarkerSeverity.Info,
      message: message,
      startLineNumber: 1,
      startColumn: 1,
      endLineNumber: 1,
      endColumn: 1,
    );
  }

  @override
  List<IMarker> read([IMarkerReadOptions? filter]) {
    filter ??= _ReadOpts();

    var owner = filter.owner;
    final resource = filter.resource;
    var severities = filter.severities;
    var take = filter.take;

    if (take == null || take < 0) {
      take = -1;
    }

    if (owner != null && resource != null) {
      // exactly one owner AND resource
      final reasons = filter.ignoreResourceFilters == true
          ? null
          : _filteredResources.get(resource);
      if (reasons != null && reasons.isNotEmpty) {
        final infoMarker = _createFilteredMarker(resource, reasons);
        return <IMarker>[infoMarker];
      }

      final data = _data.get(resource, owner);
      if (data == null) {
        return const <IMarker>[];
      }

      final result = <IMarker>[];
      for (final marker in data.markers) {
        if (take > 0 && result.length == take) {
          break;
        }
        final reasons = filter.ignoreResourceFilters == true
            ? null
            : _filteredResources.get(resource);
        if (reasons != null && reasons.isNotEmpty) {
          result.add(_createFilteredMarker(resource, reasons));
        } else if (MarkerService._accept(marker, severities)) {
          result.add(marker);
        }
      }
      return result;
    } else {
      // of one resource OR owner
      final iterable = owner == null && resource == null
          ? _data.values()
          : _data.values(resource ?? owner);

      final result = <IMarker>[];
      final filtered = ResourceSet();

      for (final markers in iterable) {
        for (final data in markers.markers) {
          if (filtered.has(data.resource)) {
            continue;
          }
          if (take > 0 && result.length == take) {
            break;
          }
          final reasons = filter.ignoreResourceFilters == true
              ? null
              : _filteredResources.get(data.resource);
          if (reasons != null && reasons.isNotEmpty) {
            result.add(_createFilteredMarker(data.resource, reasons));
            filtered.add(data.resource);
          } else if (MarkerService._accept(data, severities)) {
            result.add(data);
          }
        }
      }
      return result;
    }
  }

  /// 1:1: `_accept(marker, severities?): boolean`
  static bool _accept(IMarker marker, [int? severities]) =>
      severities == null || (severities & marker.severity) == marker.severity;

  /// 1:1: `_merge(all: (readonly URI[])[]): URI[]`
  static List<URI> _merge(List<List<URI>> all) {
    final set = ResourceMap<bool>();
    for (final array in all) {
      for (final item in array) {
        set.set(item, true);
      }
    }
    return set.keys().toList();
  }
}

/// Concrete carrier for the `IMarker` structural interface.
class _Marker implements IMarker {
  @override
  final String owner;
  @override
  final URI resource;
  @override
  final int severity;
  @override
  final Object? code;
  @override
  final String message;
  @override
  final String? source;
  @override
  final int startLineNumber;
  @override
  final int startColumn;
  @override
  final int endLineNumber;
  @override
  final int endColumn;
  @override
  final int? modelVersionId;
  @override
  final List<IRelatedInformation>? relatedInformation;
  @override
  final List<int>? tags;
  @override
  final String? origin;

  _Marker({
    required this.owner,
    required this.resource,
    required this.severity,
    this.code,
    required this.message,
    this.source,
    required this.startLineNumber,
    required this.startColumn,
    required this.endLineNumber,
    required this.endColumn,
    this.modelVersionId,
    this.relatedInformation,
    this.tags,
    this.origin,
  });
}
