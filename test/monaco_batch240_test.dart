// Truth replay for batch240: editor/common/tokenizationRegistry.dart
// (1:1 port of the whole 152-line tokenizationRegistry.ts).
//
// Expectations come from `tool/ts2dart/batch240_truth.json`, produced by
// `tool/ts2dart/_batch240_truth.cjs`, which transpiles and executes the REAL TS
// source along with the real event.ts, lifecycle.ts, color.ts and
// encodedTokenAttributes.ts (only the type-only languages.ts import is stubbed).
// The JSON stores both the RAW INPUTS fed to the real code and the captured
// results; every case below feeds those exact inputs to the Dart port and
// deep-compares the resulting JSON.
//
// NOTE: relative `../lib/...` imports are intentional (all batch tests do this).
import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import '../lib/src/monaco/base/common/color.dart' show Color;
import '../lib/src/monaco/base/common/lifecycle.dart' show IDisposable;
import '../lib/src/monaco/editor/common/tokenizationRegistry.dart' as reg;

Map<String, dynamic> _map(Object? value) =>
    (value as Map).cast<String, dynamic>();

Map<String, Object?> _raw(Object? value) =>
    (value as Map).cast<String, Object?>();

Map<String, dynamic> _truth() =>
    _map(jsonDecode(File('tool/ts2dart/batch240_truth.json').readAsStringSync()));

/// Deep JSON-equality: missing key == explicit null, `num` compares by value.
bool _jsonEqual(Object? a, Object? b) {
  if (a == null || b == null) return a == null && b == null;
  if (a is num && b is num) return a == b;
  if (a is String && b is String) return a == b;
  if (a is bool && b is bool) return a == b;
  if (a is Map && b is Map) {
    final Set<String> keys = <String>{
      ...a.keys.map((Object? k) => k.toString()),
      ...b.keys.map((Object? k) => k.toString()),
    };
    for (final String key in keys) {
      if (!_jsonEqual(a[key], b[key])) return false;
    }
    return true;
  }
  if (a is List && b is List) {
    if (a.length != b.length) return false;
    for (int i = 0; i < a.length; i++) {
      if (!_jsonEqual(a[i], b[i])) return false;
    }
    return true;
  }
  return false;
}

String _describe(Object? value) => jsonEncode(value);

/// Stand-in for the TS sentinel `{ tag: 'A' }`. No `==` override, so Dart's
/// `identical` mirrors TS `===` for these objects.
class _Support {
  final String tag;
  _Support(this.tag);
}

Object? _tagOf(Object? value) => value == null ? null : (value as _Support).tag;

List<Map<String, Object?>> _observe(reg.TokenizationRegistry<Object> registry) {
  final List<Map<String, Object?>> events = <Map<String, Object?>>[];
  registry.onDidChange((dynamic e) {
    events.add((e as reg.TokenizationSupportChangedEvent).toJson());
  });
  return events;
}

// ---------------------------------------------------------------------------
// Case 1: initial state.
// ---------------------------------------------------------------------------
Map<String, Object?> _replayInitialState(Map<String, Object?> inputs) {
  final reg.TokenizationRegistry<Object> registry =
      reg.TokenizationRegistry<Object>();
  final String probeId = inputs['probeLanguageId'] as String;
  final List<Color?>? colorMap = registry.getColorMap();
  final Color? background = registry.getDefaultBackground();
  return <String, Object?>{
    'getColorMap': colorMap,
    'getDefaultBackground': background,
    'get_x': registry.get(probeId),
    'isResolved_x': registry.isResolved(probeId),
  };
}

// ---------------------------------------------------------------------------
// Case 2: register('ts', supportA) then dispose its registration handle.
// ---------------------------------------------------------------------------
Map<String, Object?> _replayRegisterAndDispose(Map<String, Object?> inputs) {
  final reg.TokenizationRegistry<Object> registry =
      reg.TokenizationRegistry<Object>();
  final List<Map<String, Object?>> events = _observe(registry);
  final String id = inputs['languageId'] as String;
  final _Support supportA = _Support(inputs['supportTag'] as String);
  final IDisposable handle = registry.register(id, supportA);
  final Map<String, Object?> results = <String, Object?>{
    'get_ts_is_supportA': identical(registry.get(id), supportA),
    'get_ts_tag': _tagOf(registry.get(id)),
    'eventsAfterRegister': List<Map<String, Object?>>.from(events),
  };
  handle.dispose();
  results['get_ts_after_dispose'] = registry.get(id);
  results['events'] = List<Map<String, Object?>>.from(events);
  return results;
}

// ---------------------------------------------------------------------------
// Case 3: register A then B on the same id; disposing A must not remove B.
// ---------------------------------------------------------------------------
Map<String, Object?> _replayRegisterTwoDisposeFirst(
    Map<String, Object?> inputs) {
  final reg.TokenizationRegistry<Object> registry =
      reg.TokenizationRegistry<Object>();
  final List<Map<String, Object?>> events = _observe(registry);
  final String id = inputs['languageId'] as String;
  final _Support supportA = _Support(inputs['firstSupportTag'] as String);
  final _Support supportB = _Support(inputs['secondSupportTag'] as String);
  final IDisposable handleA = registry.register(id, supportA);
  registry.register(id, supportB);
  handleA.dispose();
  return <String, Object?>{
    'get_ts_is_B': identical(registry.get(id), supportB),
    'get_ts_tag': _tagOf(registry.get(id)),
    'events': List<Map<String, Object?>>.from(events),
  };
}

// ---------------------------------------------------------------------------
// Case 4: setColorMap with 4 colors, then with 2 colors (guard at L108).
// ---------------------------------------------------------------------------
Map<String, Object?> _replaySetColorMap(Map<String, Object?> inputs) {
  final reg.TokenizationRegistry<Object> registry =
      reg.TokenizationRegistry<Object>();
  final List<Map<String, Object?>> events = _observe(registry);
  for (final Object? id in inputs['registeredIds'] as List) {
    registry.register(id as String, _Support('S'));
  }
  events.clear(); // isolate the setColorMap events

  final List<Color> colorMap = (inputs['colorMapHex'] as List)
      .map((Object? hex) => Color.fromHex(hex as String))
      .toList();
  registry.setColorMap(colorMap);
  final List<Color?>? actual = registry.getColorMap();
  final Color? background = registry.getDefaultBackground();
  final Map<String, Object?> results = <String, Object?>{
    'getColorMap_hex':
        actual?.map<Object?>((Color? c) => c.toString()).toList(),
    'getColorMap_deepEqual': actual != null &&
        actual.length == colorMap.length &&
        List<bool>.generate(
          colorMap.length,
          (int i) => Color.equalsStatic(colorMap[i], actual[i]),
        ).every((bool equal) => equal),
    'getDefaultBackground_is_c2': identical(background, colorMap[2]),
    'getDefaultBackground_hex': background?.toString(),
    'eventsAfterFull': List<Map<String, Object?>>.from(events),
  };

  final List<Color> shortColorMap = (inputs['shortColorMapHex'] as List)
      .map((Object? hex) => Color.fromHex(hex as String))
      .toList();
  registry.setColorMap(shortColorMap);
  results['getColorMap_short_hex'] = registry
      .getColorMap()
      ?.map<Object?>((Color? c) => c.toString())
      .toList();
  results['getDefaultBackground_short'] = registry.getDefaultBackground();
  results['events'] = List<Map<String, Object?>>.from(events);
  return results;
}

// ---------------------------------------------------------------------------
// Case 5: registerFactory + two getOrCreate calls reuse one promise.
// ---------------------------------------------------------------------------
Future<Map<String, Object?>> _replayFactoryResolve(
    Map<String, Object?> inputs) async {
  final reg.TokenizationRegistry<Object> registry =
      reg.TokenizationRegistry<Object>();
  final List<Map<String, Object?>> events = _observe(registry);
  final String id = inputs['languageId'] as String;
  final _Support support = _Support(inputs['supportTag'] as String);
  int getCalls = 0;
  final reg.LazyTokenizationSupport<Object> factory =
      reg.LazyTokenizationSupport<Object>(() {
    getCalls++;
    return Future<_Support>.value(support);
  });
  registry.registerFactory(id, factory);
  final bool isResolvedBefore = registry.isResolved(id);
  // Issue both calls before the first settles, mirroring the harness.
  final Future<Object?> p1 = registry.getOrCreate(id);
  final Future<Object?> p2 = registry.getOrCreate(id);
  final Object? r1 = await p1;
  final Object? r2 = await p2;
  return <String, Object?>{
    'isResolvedBefore': isResolvedBefore,
    'factoryGetCallCount': getCalls,
    'getOrCreate1_is_support': identical(r1, support),
    'getOrCreate2_is_support': identical(r2, support),
    'resolvedSupportTag': _tagOf(r1),
    'get_py_is_support': identical(registry.get(id), support),
    'isResolvedAfter': registry.isResolved(id),
    'events': List<Map<String, Object?>>.from(events),
  };
}

// ---------------------------------------------------------------------------
// Case 6: factory disposed before its tokenizationSupport promise resolves.
// ---------------------------------------------------------------------------
Future<Map<String, Object?>> _replayFactoryDisposedBeforeResolve(
    Map<String, Object?> inputs) async {
  final reg.TokenizationRegistry<Object> registry =
      reg.TokenizationRegistry<Object>();
  final List<Map<String, Object?>> events = _observe(registry);
  final String id = inputs['languageId'] as String;
  final _Support support = _Support(inputs['supportTag'] as String);
  int getCalls = 0;
  final Completer<Object?> completer = Completer<Object?>();
  final reg.LazyTokenizationSupport<Object> factory =
      reg.LazyTokenizationSupport<Object>(() {
    getCalls++;
    return completer.future;
  });
  final IDisposable handle = registry.registerFactory(id, factory);
  final Future<Object?> pending = registry.getOrCreate(id);
  handle.dispose();
  completer.complete(support);
  final Object? resolved = await pending;
  return <String, Object?>{
    'factoryGetCallCount': getCalls,
    'getOrCreateResult': resolved,
    'get_py': registry.get(id),
    'isResolvedAfter': registry.isResolved(id),
    'events': List<Map<String, Object?>>.from(events),
  };
}

// ---------------------------------------------------------------------------
// Case 7: handleChange(['css', 'html']).
// ---------------------------------------------------------------------------
Map<String, Object?> _replayHandleChange(Map<String, Object?> inputs) {
  final reg.TokenizationRegistry<Object> registry =
      reg.TokenizationRegistry<Object>();
  final List<Map<String, Object?>> events = _observe(registry);
  registry.handleChange((inputs['languageIds'] as List).cast<String>());
  return <String, Object?>{
    'events': List<Map<String, Object?>>.from(events),
  };
}

void main() {
  final Map<String, dynamic> truth = _truth();
  final List<dynamic> cases = (truth['cases'] as List).cast<dynamic>();

  test('truth file captured all 7 cases', () {
    expect(cases.length, 7);
    expect(
      cases.map<Object?>((Object? e) => _map(e)['name']).toSet().length,
      7,
      reason: 'case names must be unique',
    );
  });

  for (final Object? entry in cases) {
    final Map<String, dynamic> c = _map(entry);
    final String name = c['name'] as String;
    final Map<String, Object?> inputs = _raw(c['inputs']);
    final Map<String, Object?> expected = _raw(c['results']);

    test('replay: $name', () async {
      Object? actual;
      switch (name) {
        case 'initial_state':
          actual = _replayInitialState(inputs);
          break;
        case 'register_and_dispose':
          actual = _replayRegisterAndDispose(inputs);
          break;
        case 'register_two_dispose_first':
          actual = _replayRegisterTwoDisposeFirst(inputs);
          break;
        case 'set_color_map':
          actual = _replaySetColorMap(inputs);
          break;
        case 'factory_resolve':
          actual = await _replayFactoryResolve(inputs);
          break;
        case 'factory_disposed_before_resolve':
          actual = await _replayFactoryDisposedBeforeResolve(inputs);
          break;
        case 'handle_change':
          actual = _replayHandleChange(inputs);
          break;
        default:
          fail('unknown truth case "$name"');
      }
      expect(
        _jsonEqual(actual, expected),
        isTrue,
        reason: 'replay mismatch for $name\n'
            '  Dart:  ${_describe(actual)}\n'
            '  truth: ${_describe(expected)}',
      );
    });
  }
}
