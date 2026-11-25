// batch282: viewEventHandler.ts truth replay.
// Truth from tool/ts2dart/batch282_truth.json (recursive TS transpile+vm,
// real ViewEventHandler subclassed to override the 18 handlers).
import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:semi_design_flutter/src/monaco/editor/common/viewEventHandler.dart'
    show ViewEventHandler;

Map<String, dynamic> _truth() => jsonDecode(
    File('tool/ts2dart/batch282_truth.json').readAsStringSync())
    as Map<String, dynamic>;

Object? _norm(Object? v) {
  if (v == null) return null;
  if (v is Map) {
    return v.map<String, Object?>((k, e) =>
        MapEntry<String, Object?>(k as String, _norm(e)));
  }
  if (v is List) return v.map(_norm).toList();
  return v;
}

/// Minimal event carrier exposing only `type`, matching handleEvents' use.
class _Event {
  _Event(this.type);
  final int type;
}

/// Subclass overriding all 18 handlers to record calls and return the value
/// configured in [returnMap], mirroring the harness's TestViewEventHandler.
class _TestHandler extends ViewEventHandler {
  _TestHandler(this.returnMap, this.calls);

  final Map<String, bool> returnMap;
  final List<Map<String, Object?>> calls;

  bool _record(String name, Object e) {
    calls.add(<String, Object?>{'handler': name, 'type': (e as _Event).type});
    return returnMap[name] ?? false;
  }

  @override
  bool onCompositionStart(Object e) => _record('onCompositionStart', e);
  @override
  bool onCompositionEnd(Object e) => _record('onCompositionEnd', e);
  @override
  bool onConfigurationChanged(Object e) => _record('onConfigurationChanged', e);
  @override
  bool onCursorStateChanged(Object e) => _record('onCursorStateChanged', e);
  @override
  bool onDecorationsChanged(Object e) => _record('onDecorationsChanged', e);
  @override
  bool onFlushed(Object e) => _record('onFlushed', e);
  @override
  bool onFocusChanged(Object e) => _record('onFocusChanged', e);
  @override
  bool onLanguageConfigurationChanged(Object e) =>
      _record('onLanguageConfigurationChanged', e);
  @override
  bool onLineMappingChanged(Object e) => _record('onLineMappingChanged', e);
  @override
  bool onLinesChanged(Object e) => _record('onLinesChanged', e);
  @override
  bool onLinesDeleted(Object e) => _record('onLinesDeleted', e);
  @override
  bool onLinesInserted(Object e) => _record('onLinesInserted', e);
  @override
  bool onRevealRangeRequest(Object e) => _record('onRevealRangeRequest', e);
  @override
  bool onScrollChanged(Object e) => _record('onScrollChanged', e);
  @override
  bool onThemeChanged(Object e) => _record('onThemeChanged', e);
  @override
  bool onTokensChanged(Object e) => _record('onTokensChanged', e);
  @override
  bool onTokensColorsChanged(Object e) => _record('onTokensColorsChanged', e);
  @override
  bool onZonesChanged(Object e) => _record('onZonesChanged', e);

  @override
  void setShouldRender() {
    calls.add(<String, Object?>{'handler': 'setShouldRender'});
    super.setShouldRender();
  }
}

void main() {
  final t = _truth();

  test('b282 const enums / handler list', () {
    final consts =
        (t['consts'] as Map<String, dynamic>)['ViewEventType'] as Map;
    expect(consts['ViewCompositionStart'], 0);
    expect(consts['ViewZonesChanged'], 17);
    expect((t['handlers'] as List).length, 18);
    expect((t['typeNames'] as List).length, 18);
  });

  for (final rawCase in t['cases'] as List<dynamic>) {
    final c = rawCase as Map<String, dynamic>;
    test('b282 ${c['name']}: handler dispatch matches TS truth', () {
      final returnMap = (c['returnMap'] as Map<String, dynamic>)
          .map<String, bool>((k, v) => MapEntry(k, v as bool));
      final calls = <Map<String, Object?>>[];
      final handler = _TestHandler(returnMap, calls);
      final outputs = <Object?>[];

      for (final rawOp in c['ops'] as List<dynamic>) {
        final op = rawOp as Map<String, dynamic>;
        switch (op['op'] as String) {
          case 'shouldRender':
            outputs.add(handler.shouldRender());
            break;
          case 'onDidRender':
            handler.onDidRender();
            outputs.add(null);
            break;
          case 'forceShouldRender':
            handler.forceShouldRender();
            outputs.add(null);
            break;
          case 'setShouldRender':
            handler.setShouldRender();
            outputs.add(null);
            break;
          case 'handleEvents':
            final events = (op['types'] as List<dynamic>)
                .map((e) => _Event((e as num).toInt()) as Object)
                .toList();
            handler.handleEvents(events);
            outputs.add(null);
            break;
          default:
            fail('unknown op ${op['op']}');
        }
      }

      expect(outputs, c['outputs'], reason: 'outputs ${c['name']}');
      expect(_norm(calls), c['calls'], reason: 'calls ${c['name']}');
      handler.dispose();
    });
  }
}
