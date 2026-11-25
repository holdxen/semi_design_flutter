// 1:1 replay of
// `editor/contrib/gotoError/browser/markerNavigationService.ts` (254 lines).
//
// `tool/ts2dart/_batch247_truth.cjs` runs the real module with the two injected
// services scripted (marker snapshots, `problems.sortOrder`) and the real
// `registerSingleton(...)`.
//
// Ordering is asserted through the navigation results (forward/backward walks,
// `find`, position-branch moves, the empty-range/word expansion) rather than by
// reading `_markers` directly: in Dart that list is library-private. Every truth
// key that encodes an order is therefore covered by an observable walk.
import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import '../lib/src/monaco/base/common/event.dart' show Emitter, Event;
import '../lib/src/monaco/base/common/lifecycle.dart' show IDisposable;
import '../lib/src/monaco/base/common/uri.dart' show URI;
import '../lib/src/monaco/editor/common/core/position.dart' show Position;
import '../lib/src/monaco/editor/contrib/gotoError/browser/markerNavigationService.dart'
    as nav;
import '../lib/src/monaco/platform/configuration/common/configuration.dart'
    show IConfigurationServiceType;
import '../lib/src/monaco/platform/markers/common/markers.dart'
    show
        IMarker,
        IMarkerReadOptions,
        IMarkerServiceType,
        MarkerSeverity,
        MarkerStatistics,
        IRelatedInformation;

Map<String, dynamic> _map(dynamic value) =>
    (value as Map).cast<String, dynamic>();

Map<String, dynamic> _truth() => _map(jsonDecode(
    File('tool/ts2dart/batch247_truth.json').readAsStringSync()));

/// `[[key, value], ...]` from the truth -> a `Map<String, Object?>`.
Map<String, Object?> _pairs(Object? list) => <String, Object?>{
      for (final entry in (list as List))
        (entry as List)[0] as String: entry[1],
    };

class _Marker implements IMarker {
  _Marker(this.resource, this.startLineNumber, this.startColumn,
      this.endLineNumber, this.endColumn, this.severity, this.message);

  @override
  final URI resource;

  @override
  final int startLineNumber;

  @override
  final int startColumn;

  @override
  final int endLineNumber;

  @override
  final int endColumn;

  @override
  final int severity;

  @override
  final String message;

  @override
  String get owner => 'test';

  @override
  Object? get code => null;

  @override
  String? get source => null;

  @override
  int? get modelVersionId => null;

  @override
  List<IRelatedInformation>? get relatedInformation => null;

  @override
  List<int>? get tags => null;

  @override
  String? get origin => null;
}

class _FakeMarkerService implements IMarkerServiceType {
  List<IMarker> markers = <IMarker>[];
  final List<Map<String, Object?>> readCalls = <Map<String, Object?>>[];
  final Emitter<List<URI>> onMarkerChangedEmitter = Emitter<List<URI>>();

  @override
  Object? get _serviceBrand => null;

  @override
  List<IMarker> read([IMarkerReadOptions? filter]) {
    readCalls.add(<String, Object?>{
      'resource': filter?.resource?.toString(),
      'severities': filter?.severities,
    });
    return List<IMarker>.of(markers);
  }

  @override
  Event<List<URI>> get onMarkerChanged => onMarkerChangedEmitter.event;

  @override
  MarkerStatistics getStatistics() => throw UnimplementedError();

  @override
  bool isSourceTruncated(URI resource) => throw UnimplementedError();

  @override
  void changeOne(String owner, URI resource, List<Object?> markers,
      [Object? options]) =>
      throw UnimplementedError();

  @override
  void changeAll(String owner, List<Object?> data) => throw UnimplementedError();

  @override
  void remove(String owner, List<URI> resources) => throw UnimplementedError();

  @override
  IDisposable installResourceFilter(URI resource, String reason) =>
      throw UnimplementedError();
}

/// Only `getValue$1` is consulted; the rest forwards to `noSuchMethod`.
class _FakeConfigService implements IConfigurationServiceType {
  String? sortOrder;

  @override
  Object? getValue$1(String section) =>
      section == 'problems.sortOrder' ? sortOrder : null;

  @override
  Object? get _serviceBrand => null;

  @override
  dynamic noSuchMethod(Invocation invocation) =>
      super.noSuchMethod(invocation);
}

class _FakeModel {
  _FakeModel(this.uri, [this.word]);

  final URI uri;

  /// `[startColumn, endColumn]` for the whole line, or null (no word).
  final List<int>? word;

  Object? getWordAtPosition(Position position) {
    final List<int>? word = this.word;
    if (word == null) return null;
    return _Word(word[0], word[1]);
  }
}

class _Word {
  _Word(this.startColumn, this.endColumn);

  final int startColumn;
  final int endColumn;

  String get word => 'w';
}

Map<String, Object?> _coord(nav.MarkerCoordinate? coordinate) =>
    coordinate == null
        ? <String, Object?>{}
        : <String, Object?>{
            'marker': <String, Object?>{
              'resource': coordinate.marker.resource.toString(),
              'range': <int>[
                coordinate.marker.startLineNumber,
                coordinate.marker.startColumn,
                coordinate.marker.endLineNumber,
                coordinate.marker.endColumn,
              ],
              'severity': coordinate.marker.severity,
              'message': coordinate.marker.message,
            },
            'index': coordinate.index,
            'total': coordinate.total,
          };

/// `[moved, coordinate]` pair; `coordinate` is `{}` for `undefined`.
List<Object?> _step(bool moved, nav.MarkerCoordinate? coordinate) =>
    <Object?>[moved, _coord(coordinate)];

void main() {
  final truth = _truth();
  final aJs = URI.parse('file:///a.js');
  final bJs = URI.parse('file:///b.js');
  final cJs = URI.parse('file:///c.js');

  late _FakeMarkerService markerService;
  late _FakeConfigService configService;

  _Marker marker(URI resource, int sl, int sc, int el, int ec, int severity,
          String message) =>
      _Marker(resource, sl, sc, el, ec, severity, message);

  setUp(() {
    markerService = _FakeMarkerService();
    configService = _FakeConfigService();
  });

  group('MarkerSeverity', () {
    test('values, compare and toString match the port', () {
      final expected = _map(truth['markerSeverity']);
      expect(<String, int>{
        'Hint': MarkerSeverity.Hint,
        'Info': MarkerSeverity.Info,
        'Warning': MarkerSeverity.Warning,
        'Error': MarkerSeverity.Error,
      }, _map(expected['values']));

      final compare = <String, int>{
        'errorVsWarning': MarkerSeverity.compare(
            MarkerSeverity.Error, MarkerSeverity.Warning),
        'warningVsError': MarkerSeverity.compare(
            MarkerSeverity.Warning, MarkerSeverity.Error),
        'infoVsInfo':
            MarkerSeverity.compare(MarkerSeverity.Info, MarkerSeverity.Info),
        'hintVsError':
            MarkerSeverity.compare(MarkerSeverity.Hint, MarkerSeverity.Error),
      };
      expect(compare, _pairs(expected['compare']));
      expect(<String, String>{
        'error': MarkerSeverity.toStringStatic(MarkerSeverity.Error),
        'warning': MarkerSeverity.toStringStatic(MarkerSeverity.Warning),
        'info': MarkerSeverity.toStringStatic(MarkerSeverity.Info),
        'hint': MarkerSeverity.toStringStatic(MarkerSeverity.Hint),
      }, _map(expected['toString']));
    });
  });

  group('MarkerList', () {
    test('no filter: read descriptor, matches, navigation, find', () {
      configService.sortOrder = 'severity';
      markerService.markers = <IMarker>[
        marker(bJs, 1, 1, 1, 5, MarkerSeverity.Warning, 'b-warning-1'),
        marker(aJs, 5, 1, 5, 3, MarkerSeverity.Warning, 'a-warning-5'),
        marker(aJs, 2, 1, 2, 3, MarkerSeverity.Error, 'a-error-2'),
        marker(aJs, 2, 1, 2, 1, MarkerSeverity.Error, 'a-error-2-empty'),
        marker(cJs, 9, 1, 9, 2, MarkerSeverity.Info, 'c-info-9'),
      ];
      final list = nav.MarkerList(null, markerService, configService);
      final expected = _map(truth['noFilter']);

      expect(markerService.readCalls, expected['readCalls']);
      expect(_coord(list.selected), _coordFromTruth(expected['selectedInitially']));

      final matches = <String, Object?>{
        'undefined': list.matches(null),
        'aJs': list.matches(aJs),
      };
      expect(matches, _pairs(expected['matches']));

      final modelA = _FakeModel(aJs);
      final positionA2 = Position(2, 2);
      final forward = <Object?>[];
      for (var i = 0; i < 6; i++) {
        forward.add(_step(list.move(true, modelA, positionA2), list.selected));
      }
      expect(forward, expected['forwardFromA2']);

      list.resetIndex();
      final backward = <Object?>[];
      for (var i = 0; i < 4; i++) {
        backward.add(_step(list.move(false, modelA, positionA2), list.selected));
      }
      expect(backward, expected['backwardFromA2']);

      final modelB = _FakeModel(bJs);
      list.resetIndex();
      final forwardFromB = <Object?>[];
      for (var i = 0; i < 3; i++) {
        forwardFromB.add(_step(list.move(true, modelB, Position(1, 1)),
            list.selected));
      }
      expect(forwardFromB, expected['forwardFromB']);

      list.resetIndex();
      final backwardFromB = <Object?>[];
      for (var i = 0; i < 3; i++) {
        backwardFromB.add(_step(list.move(false, modelB, Position(1, 1)),
            list.selected));
      }
      expect(backwardFromB, expected['backwardFromB']);

      final findActual = <String, Object?>{
        'aJsInError': _coord(list.find(aJs, Position(2, 1))),
        'aJsInWarning': _coord(list.find(aJs, Position(5, 2))),
        'aJsMiss': _coord(list.find(aJs, Position(3, 1))),
        'zJs': _coord(list.find(URI.parse('file:///z.js'), Position(1, 1))),
      };
      final findExpected = _pairs(expected['find']);
      for (final entry in findActual.entries) {
        expect(entry.value, _coordFromTruth(findExpected[entry.key]),
            reason: entry.key);
      }
    });

    test('position sort order drives the moves', () {
      configService.sortOrder = 'position';
      markerService.markers = <IMarker>[
        marker(aJs, 3, 1, 3, 4, MarkerSeverity.Warning, 'a-3'),
        marker(aJs, 7, 1, 7, 4, MarkerSeverity.Error, 'a-7'),
        marker(aJs, 9, 1, 9, 4, MarkerSeverity.Error, 'a-9'),
      ];
      final list = nav.MarkerList(null, markerService, configService);
      final expected = _map(truth['positionSort']);

      final model = _FakeModel(aJs);
      final moves = <Object?>[];
      for (final entry in <String, Position>{
        'beforeFirst': Position(1, 1),
        'insideFirst': Position(3, 2),
        'between': Position(5, 1),
        'afterLast': Position(10, 1),
      }.entries) {
        list.resetIndex();
        moves.add(<Object?>[
          entry.key,
          ..._step(list.move(true, model, entry.value), list.selected),
        ]);
        list.resetIndex();
        moves.add(<Object?>[
          '${entry.key}-back',
          ..._step(list.move(false, model, entry.value), list.selected),
        ]);
      }
      expect(moves, expected['moves']);
    });

    test('empty-range markers expand to the word at the position', () {
      markerService.markers = <IMarker>[
        marker(aJs, 4, 5, 4, 5, MarkerSeverity.Error, 'point'),
      ];
      final list = nav.MarkerList(null, markerService, configService);
      final expected = _map(truth['emptyRangeWithWord']);

      list.resetIndex();
      final withoutWord =
          _step(list.move(true, _FakeModel(aJs), Position(4, 6)), list.selected);
      expect(withoutWord, expected['hitWithoutWord']);

      list.resetIndex();
      final withWord = _step(list.move(true, _FakeModel(aJs, <int>[5, 9]),
          Position(4, 6)), list.selected);
      expect(withWord, expected['hitWithWord']);

      list.resetIndex();
      final miss = _step(list.move(true, _FakeModel(aJs, <int>[5, 9]),
          Position(4, 1)), list.selected);
      expect(miss, expected['missWithWord']);
    });

    test('URI filter and function filter', () {
      configService.sortOrder = 'severity';
      markerService.markers = <IMarker>[
        marker(aJs, 1, 1, 1, 2, MarkerSeverity.Error, 'a1'),
        marker(bJs, 1, 1, 1, 2, MarkerSeverity.Error, 'b1'),
      ];
      final uriFiltered = nav.MarkerList(aJs, markerService, configService);
      final uriExpected = _map(truth['uriFilter']);
      expect(markerService.readCalls, uriExpected['readCalls']);
      expect(<String, Object?>{
        'aJs': uriFiltered.matches(aJs),
        'bJs': uriFiltered.matches(bJs),
        'undefined': uriFiltered.matches(null),
      }, _pairs(uriExpected['matches']));

      markerService.readCalls.clear();
      markerService.markers = <IMarker>[
        marker(aJs, 1, 1, 1, 2, MarkerSeverity.Error, 'a1'),
        marker(bJs, 1, 1, 1, 2, MarkerSeverity.Error, 'b1'),
        marker(cJs, 1, 1, 1, 2, MarkerSeverity.Error, 'c1'),
      ];
      final fnFiltered = nav.MarkerList(
          (URI uri) => uri.path == '/a.js' || uri.path == '/c.js',
          markerService,
          configService);
      final fnExpected = _map(truth['fnFilter']);
      expect(markerService.readCalls, fnExpected['readCalls']);
      expect(<String, Object?>{
        'aJs': fnFiltered.matches(aJs),
        'bJs': fnFiltered.matches(bJs),
        'undefined': fnFiltered.matches(null),
      }, _pairs(fnExpected['matches']));
    });

    test('change events, filter awareness and dispose', () {
      configService.sortOrder = 'severity';
      markerService.markers = <IMarker>[
        marker(aJs, 1, 1, 1, 2, MarkerSeverity.Error, 'a1'),
      ];
      final list = nav.MarkerList(null, markerService, configService);
      final events = <int>[];
      list.onDidChange((dynamic _) => events.add(1));
      list.move(true, _FakeModel(aJs), Position(1, 1));

      // same content (fresh array) -> no event
      markerService.onMarkerChangedEmitter.fire(<URI>[aJs]);
      markerService.markers = <IMarker>[
        marker(aJs, 1, 1, 1, 2, MarkerSeverity.Error, 'a1'),
        marker(cJs, 2, 1, 2, 2, MarkerSeverity.Error, 'c2'),
      ];
      markerService.onMarkerChangedEmitter.fire(<URI>[aJs, cJs]);

      final expected = _map(truth['changeEvents']);
      expect(events.length, expected['fires']);
      expect(_coord(list.selected),
          _coordFromTruth(expected['selectedAfterChange']));

      final filteredEvents = <int>[];
      markerService.markers = <IMarker>[
        marker(aJs, 1, 1, 1, 2, MarkerSeverity.Error, 'a1'),
      ];
      final filtered = nav.MarkerList(aJs, markerService, configService);
      filtered.onDidChange((dynamic _) => filteredEvents.add(1));

      markerService.onMarkerChangedEmitter.fire(<URI>[cJs]);
      final afterUnrelated = filteredEvents.length;
      markerService.markers = <IMarker>[
        marker(aJs, 1, 1, 1, 2, MarkerSeverity.Error, 'a1'),
        marker(aJs, 2, 1, 2, 2, MarkerSeverity.Error, 'a2'),
      ];
      markerService.onMarkerChangedEmitter.fire(<URI>[aJs]);

      final filteredExpected = _map(truth['filteredChangeEvents']);
      expect(afterUnrelated, filteredExpected['afterUnrelated']);
      expect(filteredEvents.length, filteredExpected['afterRelated']);

      filtered.dispose();
      markerService.markers = <IMarker>[];
      markerService.onMarkerChangedEmitter.fire(<URI>[aJs]);
      expect(filteredEvents.length, truth['disposeStopsEvents']);
    });
  });

  group('MarkerNavigationService', () {
    test('providers take precedence over the default list', () {
      configService.sortOrder = 'severity';
      markerService.markers = <IMarker>[];
      final service = nav.MarkerNavigationService(markerService, configService);
      final calls = <List<Object?>>[];

      final provider1 = _Provider((URI? resource) {
        calls.add(<Object?>['p1', resource?.toString()]);
        return null;
      });
      final provider2 = _Provider((URI? resource) {
        calls.add(<Object?>['p2', resource?.toString()]);
        return null;
      });
      final provided = nav.MarkerList(bJs, markerService, configService);
      final provider3 = _Provider((URI? resource) {
        calls.add(<Object?>['p3', resource?.toString()]);
        return resource != null ? provided : null;
      });

      final dispose1 = service.registerProvider(provider1);
      final dispose2 = service.registerProvider(provider2);
      final dispose3 = service.registerProvider(provider3);

      final result = service.getMarkerList(bJs);
      final expected = _map(truth['navigationService']);
      expect(calls, expected['providerCallOrder']);
      expect(identical(result, provided), expected['providerResultUsed']);

      provided.resetIndex();
      provided.move(true, _FakeModel(bJs), Position(1, 1));
      expect(_coord(provided.selected),
          _coordFromTruth(expected['providerResultSelected']));

      dispose3.dispose();
      calls.clear();
      final fallback = service.getMarkerList(cJs);
      final fallbackExpected = _map(expected['disposeRemovesProvider']);
      expect(calls, fallbackExpected['providerCallOrder']);
      expect(fallback, isA<nav.MarkerList>());
      expect(fallbackExpected['isOwnMarkerList'], isTrue);
      expect(<String, Object?>{
        'cJs': fallback.matches(cJs),
        'aJs': fallback.matches(aJs),
      }, _pairs(fallbackExpected['resourceFilterMatches']));

      dispose1.dispose();
      dispose2.dispose();
    });

    test('MarkerCoordinate keeps marker / index / total', () {
      final coordinate = nav.MarkerCoordinate(
          marker(aJs, 1, 2, 3, 4, MarkerSeverity.Error, 'm'), 7, 9);
      expect(_coord(coordinate), _map(truth['markerCoordinate']));
    });

    test('the singleton registration side effect is parked in a lazy final',
        () {
      expect(nav.markerNavigationServiceSingletonRegistered, isTrue);
    });
  });
}

class _Provider implements nav.IMarkerListProvider {
  _Provider(this._get);

  final nav.MarkerList? Function(URI? resource) _get;

  @override
  nav.MarkerList? getMarkerList(URI? resource) => _get(resource);
}

/// Truth stores `null` for an absent coordinate; `_coord` returns `{}`.
Map<String, Object?> _coordFromTruth(Object? value) => value == null
    ? <String, Object?>{}
    : _map(value);