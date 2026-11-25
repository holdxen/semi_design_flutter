// 1:1 replay of `editor/common/services/editorBaseApi.ts` (44 lines).
//
// Truth: `tool/ts2dart/_batch323_truth.cjs` -> `batch323_truth.json`.
// The TS object literal's entry kinds (`undefined` / `function` / `object`)
// map to Dart `null` / `Type` (or constructor tear-off) / `Type`.
import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import '../lib/src/monaco/editor/common/services/editorBaseApi.dart' as api;
import '../lib/src/monaco/editor/common/standalone/standaloneEnums.dart'
    as standalone;
import '../lib/src/monaco/editor/common/core/position.dart' show Position;
import '../lib/src/monaco/editor/common/core/range.dart' show Range;
import '../lib/src/monaco/editor/common/core/selection.dart' show Selection;
import '../lib/src/monaco/editor/common/languages.dart' show Token;
import '../lib/src/monaco/base/common/event.dart' show Emitter;

Map<String, dynamic> _map(dynamic value) =>
    (value as Map).cast<String, dynamic>();

Map<String, dynamic> _truth() => _map(jsonDecode(
    File('tool/ts2dart/batch323_truth.json').readAsStringSync()));

void main() {
  final truth = _truth();

  test('KeyMod mirrors the global constants and KeyChord', () {
    final expected = _map(truth['keyMod']);
    expect(api.KeyMod.CtrlCmd, expected['CtrlCmd']);
    expect(api.KeyMod.Shift, expected['Shift']);
    expect(api.KeyMod.Alt, expected['Alt']);
    expect(api.KeyMod.WinCtrl, expected['WinCtrl']);
    final matchesConst =
        (expected['matchesConstKeyMod'] as List).cast<bool>();
    expect(matchesConst.length, 4);
    for (final matches in matchesConst) {
      expect(matches, isTrue);
    }

    final chords = <String, int>{
      for (final entry in (expected['chord'] as List))
        (entry as List)[0] as String: (entry as List)[1] as int,
    };
    expect(api.KeyMod.chord(1, 2), chords['oneTwo']);
    expect(api.KeyMod.chord(api.KeyMod.CtrlCmd, api.KeyMod.Shift),
        chords['modShift']);
    expect(api.KeyMod.chord(16, 16), chords['sameTwice']);
  });

  test('createMonacoBaseAPI keys, order and entry kinds', () {
    final baseApi = api.createMonacoBaseAPI();
    expect(baseApi.keys.toList(), truth['apiKeyOrder']);

    for (final raw in (truth['api'] as List)) {
      final entry = raw as List;
      final String key = entry[0] as String;
      final kind = (entry[1] as List)[0] as String;
      final value = baseApi[key];
      if (kind == 'undefined') {
        expect(value, isNull, reason: key);
      } else {
        expect(value, isNotNull, reason: key);
      }
    }
  });

  test('entries point at the ported carriers', () {
    final baseApi = api.createMonacoBaseAPI();
    expect(identical(baseApi['editor'], null), isTrue);
    expect(identical(baseApi['languages'], null), isTrue);
    expect(baseApi['KeyMod'], api.KeyMod);
    expect(baseApi['KeyCode'], standalone.KeyCode);
    expect(baseApi['SelectionDirection'], standalone.SelectionDirection);
    expect(baseApi['MarkerSeverity'], standalone.MarkerSeverity);
    expect(baseApi['MarkerTag'], standalone.MarkerTag);
    expect(baseApi['Position'], Position);
    expect(baseApi['Range'], Range);
    expect(baseApi['Selection'], Selection);
    expect(baseApi['Token'], Token);
    expect(baseApi['Emitter'], Emitter);
  });
}
