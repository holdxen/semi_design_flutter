// ---------------------------------------------------------------------------
// 1:1 port of
// vscode/src/vs/editor/contrib/gotoError/browser/markerNavigationService.ts
// (254 lines).
//
// Runtime surface: `MarkerCoordinate`, `MarkerList`,
// `IMarkerNavigationService` (decorator id), the two provider interfaces and
// the module-private `MarkerNavigationService` which is registered as a
// singleton at load time.
//
// Adaptations:
//   - `IMarker` is an already-ported interface; it is **not** an `IRange`, so
//     every `Range.lift(marker)` / `Range.containsPosition(marker, ...)` in the
//     TS source is expressed as an explicit
//     `Range(startLineNumber, startColumn, endLineNumber, endColumn)` — the
//     same object `Range.lift` would have produced.
//   - `resourceFilter: URI | ((uri) => boolean) | undefined` -> `Object?`
//     (Dart has no union types), discriminated with `is URI` / `is Function`.
//   - `ITextModel` (erased) is `Object?`; the two members used (`uri`,
//     `getWordAtPosition`) are read dynamically.
//   - `IConfigurationService.getValue<string>('problems.sortOrder')` -> the
//     port's `getValue$1` overload.
//   - The injected services stay as their ported abstract types
//     (`IMarkerServiceType`, `IConfigurationServiceType`).
// ---------------------------------------------------------------------------

import '../../../../base/common/arrays.dart' show binarySearch2, equals;
import '../../../../base/common/event.dart' show Emitter, Event;
import '../../../../base/common/lifecycle.dart'
    show DisposableStore, IDisposable, toDisposable;
import '../../../../base/common/linkedList.dart' show LinkedList;
import '../../../../base/common/resources.dart' show isEqual;
import '../../../../base/common/strings.dart' show compare;
import '../../../../base/common/uri.dart' show URI;
import '../../../../platform/configuration/common/configuration.dart'
    show IConfigurationServiceType;
import '../../../../platform/instantiation/common/extensions.dart'
    show InstantiationType, registerSingleton;
import '../../../../platform/instantiation/common/instantiation.dart'
    show ServiceIdentifier, createDecorator;
import '../../../../platform/markers/common/markers.dart'
    show
        IMarker,
        IMarkerReadOptions,
        IMarkerService,
        IMarkerServiceType,
        MarkerSeverity;
import '../../../common/core/position.dart' show Position;
import '../../../common/core/range.dart' show Range;

class MarkerCoordinate {
  MarkerCoordinate(this.marker, this.index, this.total);

  final IMarker marker;
  final int index;
  final int total;
}

class MarkerList {
  MarkerList(
    this._resourceFilter,
    this._markerService,
    this._configService,
  ) {
    final Object? resourceFilter = _resourceFilter;
    if (resourceFilter is URI) {
      _uriFilter = resourceFilter;
      _matchedFilter =
          (URI uri) => uri.toString() == resourceFilter.toString();
    } else if (resourceFilter is Function) {
      _matchedFilter = resourceFilter as bool Function(URI uri);
    }

    final String? compareOrder =
        _configService.getValue$1('problems.sortOrder') as String?;
    int compareMarker(IMarker a, IMarker b) {
      int res = compare(a.resource.toString(), b.resource.toString());
      if (res == 0) {
        if (compareOrder == 'position') {
          final int ranges =
              Range.compareRangesUsingStarts(_markerRange(a), _markerRange(b));
          res = ranges != 0
              ? ranges
              : MarkerSeverity.compare(a.severity, b.severity);
        } else {
          final int severities =
              MarkerSeverity.compare(a.severity, b.severity);
          res = severities != 0
              ? severities
              : Range.compareRangesUsingStarts(_markerRange(a), _markerRange(b));
        }
      }
      return res;
    }

    bool updateMarker() {
      List<IMarker> newMarkers = _markerService.read(
          _MarkerReadOptions(
            resource:
                resourceFilter is URI ? resourceFilter : null,
            severities: MarkerSeverity.Error |
                MarkerSeverity.Warning |
                MarkerSeverity.Info,
          ));
      if (resourceFilter is Function) {
        newMarkers = newMarkers
            .where((IMarker m) => _matchedFilter!(m.resource))
            .toList();
      }
      newMarkers.sort(compareMarker);

      if (equals(newMarkers, _markers, (IMarker a, IMarker b) =>
          a.resource.toString() == b.resource.toString() &&
          a.startLineNumber == b.startLineNumber &&
          a.startColumn == b.startColumn &&
          a.endLineNumber == b.endLineNumber &&
          a.endColumn == b.endColumn &&
          a.severity == b.severity &&
          a.message == b.message)) {
        return false;
      }

      _markers = newMarkers;
      return true;
    }

    updateMarker();

    _dispoables.add(_markerService.onMarkerChanged((List<URI> uris) {
      if (_matchedFilter == null ||
          uris.any((URI uri) => _matchedFilter!(uri))) {
        if (updateMarker()) {
          _nextIdx = -1;
          _onDidChange.fire(null);
        }
      }
    }));
  }

  final Emitter<void> _onDidChange = Emitter<void>();

  late final Event<void> onDidChange = _onDidChange.event;

  /// TS `resourceFilter: URI | ((uri: URI) => boolean) | undefined`.
  final Object? _resourceFilter;
  URI? _uriFilter;
  bool Function(URI uri)? _matchedFilter;
  final DisposableStore _dispoables = DisposableStore();

  final IMarkerServiceType _markerService;
  final IConfigurationServiceType _configService;

  List<IMarker> _markers = <IMarker>[];
  int _nextIdx = -1;

  void dispose() {
    _dispoables.dispose();
    _onDidChange.dispose();
  }

  bool matches(URI? uri) {
    final bool Function(URI uri)? filter = _matchedFilter;
    if (filter == null && uri == null) {
      return true;
    }
    if (filter == null || uri == null) {
      return false;
    }
    return filter(uri);
  }

  MarkerCoordinate? get selected {
    final IMarker? marker =
        _nextIdx >= 0 && _nextIdx < _markers.length ? _markers[_nextIdx] : null;
    return marker != null
        ? MarkerCoordinate(marker, _nextIdx + 1, _markers.length)
        : null;
  }

  void _initIdx(Object? model, Position position, bool fwd) {
    final dynamic dynModel = model;
    final URI modelUri = dynModel.uri as URI;

    int idx = _markers
        .indexWhere((IMarker marker) => isEqual(marker.resource, modelUri));
    if (idx < 0) {
      // ignore model, position because this will be a different file
      idx = binarySearch2(
          _markers.length,
          (int index) => compare(
              _markers[index].resource.toString(), modelUri.toString()));
      if (idx < 0) {
        idx = ~idx;
      }
      if (fwd) {
        _nextIdx = idx;
      } else {
        _nextIdx = (_markers.length + idx - 1) % _markers.length;
      }
    } else {
      // find marker for file
      bool found = false;
      bool wentPast = false;
      for (int i = idx; i < _markers.length; i++) {
        Range range = _markerRange(_markers[i]);

        if (range.isEmpty()) {
          final Object? word = dynModel.getWordAtPosition(range.getStartPosition());
          if (word != null) {
            range = Range(range.startLineNumber, (word as dynamic).startColumn,
                range.startLineNumber, (word as dynamic).endColumn);
          }
        }

        if (range.containsPosition(position) ||
            position.isBeforeOrEqual(range.getStartPosition())) {
          _nextIdx = i;
          found = true;
          wentPast = !range.containsPosition(position);
          break;
        }

        if (_markers[i].resource.toString() != modelUri.toString()) {
          break;
        }
      }

      if (!found) {
        // after the last change
        _nextIdx = fwd ? 0 : _markers.length - 1;
      } else if (wentPast && !fwd) {
        // we went past and have to go one back
        _nextIdx -= 1;
      }
    }

    if (_nextIdx < 0) {
      _nextIdx = _markers.length - 1;
    }
  }

  void resetIndex() {
    _nextIdx = -1;
  }

  bool move(bool fwd, Object? model, Position position) {
    if (_markers.isEmpty) {
      return false;
    }

    final int oldIdx = _nextIdx;
    if (_nextIdx == -1) {
      _initIdx(model, position, fwd);
    } else if (fwd) {
      _nextIdx = (_nextIdx + 1) % _markers.length;
    } else if (!fwd) {
      _nextIdx = (_nextIdx - 1 + _markers.length) % _markers.length;
    }

    if (oldIdx != _nextIdx) {
      return true;
    }
    return false;
  }

  MarkerCoordinate? find(URI uri, Position position) {
    int idx = _markers
        .indexWhere((IMarker marker) => marker.resource.toString() == uri.toString());
    if (idx < 0) {
      return null;
    }
    for (; idx < _markers.length; idx++) {
      if (Range.containsPositionStatic(_markerRange(_markers[idx]), position)) {
        return MarkerCoordinate(_markers[idx], idx + 1, _markers.length);
      }
    }
    return null;
  }
}

/// `Range.lift(marker)` equivalent for the erased `IMarker` carrier.
Range _markerRange(IMarker marker) => Range(
    marker.startLineNumber,
    marker.startColumn,
    marker.endLineNumber,
    marker.endColumn);

/// TS object literal accepted by `IMarkerService.read`.
class _MarkerReadOptions implements IMarkerReadOptions {
  _MarkerReadOptions({this.resource, this.severities});

  @override
  final URI? resource;

  @override
  final int? severities;

  @override
  String? get owner => null;

  @override
  int? get take => null;

  @override
  bool? get ignoreResourceFilters => null;
}

/// 1:1: `export const IMarkerNavigationService = createDecorator<...>(...)`
final ServiceIdentifier<IMarkerNavigationServiceType> IMarkerNavigationService =
    createDecorator<IMarkerNavigationServiceType>('IMarkerNavigationService');

abstract class IMarkerNavigationServiceType {
  // ignore: unused_element
  Object? get _serviceBrand;

  IDisposable registerProvider(IMarkerListProvider provider);

  MarkerList getMarkerList(URI? resource);
}

abstract class IMarkerListProvider {
  MarkerList? getMarkerList(URI? resource);
}

class MarkerNavigationService
    implements IMarkerNavigationServiceType, IMarkerListProvider {
  MarkerNavigationService(this._markerService, this._configService);

  @override
  Object? get _serviceBrand => null;

  final IMarkerServiceType _markerService;
  final IConfigurationServiceType _configService;

  final LinkedList<IMarkerListProvider> _provider =
      LinkedList<IMarkerListProvider>();

  @override
  IDisposable registerProvider(IMarkerListProvider provider) {
    final void Function() remove = _provider.unshift(provider);
    return toDisposable(() => remove());
  }

  @override
  MarkerList getMarkerList(URI? resource) {
    for (final IMarkerListProvider provider in _provider.iterable) {
      final MarkerList? result = provider.getMarkerList(resource);
      if (result != null) {
        return result;
      }
    }
    // default
    return MarkerList(resource, _markerService, _configService);
  }
}

// TS runs `registerSingleton(...)` as a module-level statement; Dart has no
// top-level statements, so the registration is parked in the lazy `final`
// below (repo convention for TS side effects).
final bool markerNavigationServiceSingletonRegistered =
    _registerMarkerNavigationServiceSingleton();

bool _registerMarkerNavigationServiceSingleton() {
  registerSingleton<IMarkerNavigationServiceType>(
    IMarkerNavigationService,
    (IMarkerServiceType markerService, IConfigurationServiceType configService) =>
        MarkerNavigationService(markerService, configService),
    InstantiationType.Delayed,
  );
  return true;
}