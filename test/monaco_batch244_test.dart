// 1:1 replay of `editor/common/model.ts` (1633 lines).
//
// `model.ts` has no official unit test, so the expectations in
// `tool/ts2dart/batch244_truth.json` are produced by
// `tool/ts2dart/_batch244_truth.cjs`, which runs the real TypeScript source
// through the compiler and records:
//  - the 12 enums (`OverviewRulerLane` … `ModelConstants`),
//  - `TextModelResolvedOptions` construction (tabSize / 'tabSize' indentSize /
//    clamping / truthiness) plus `equals` and `createChangeEvent`,
//  - the five runtime classes (`FindMatch`, `ValidAnnotatedEditOperation`,
//    `SearchData`, `ApplyEditsResult`),
//  - the three type predicates over a matrix of JS-shaped inputs.
//
// Adaptations replayed here: plain JS object literals are `Map`s, `1` / `0`
// stand for `true` / `false` in `ITextModelCreationOptions`, and the JS global
// `RegExp` flags are checked through Dart's `RegExp` getters.
import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import '../lib/src/monaco/editor/common/core/range.dart';
import '../lib/src/monaco/editor/common/model.dart' as model;

Map<String, dynamic> _map(dynamic value) =>
    (value as Map).cast<String, dynamic>();

Map<String, dynamic> _truth() => _map(jsonDecode(
    File('tool/ts2dart/batch244_truth.json').readAsStringSync()));

/// Deep-converts `Map` / `List` values so they compare against JSON.
Object? _json(Object? value) {
  if (value is Map) {
    return <String, Object?>{
      for (final entry in value.entries) '${entry.key}': _json(entry.value),
    };
  }
  if (value is List) return <Object?>[for (final e in value) _json(e)];
  return value;
}

bool _truthy(Object? value) {
  if (value == null || value == false) return false;
  if (value is num) return value != 0 && !value.isNaN;
  if (value is String) return value.isNotEmpty;
  return true;
}

model.TextModelResolvedOptionsSource _src({
  num tabSize = 4,
  Object indentSize = 'tabSize',
  Object insertSpaces = true,
  num defaultEOL = 2,
  Object trimAutoWhitespace = false,
  Object? bracketPairColorizationOptions,
}) =>
    model.TextModelResolvedOptionsSource(
      tabSize: tabSize,
      indentSize: indentSize,
      insertSpaces: _truthy(insertSpaces),
      defaultEOL: defaultEOL,
      trimAutoWhitespace: _truthy(trimAutoWhitespace),
      bracketPairColorizationOptions: bracketPairColorizationOptions,
    );

Map<String, Object?> _resolved(model.TextModelResolvedOptions options) =>
    <String, Object?>{
      'tabSize': options.tabSize,
      'indentSize': options.indentSize,
      'originalIndentSize': options.originalIndentSize,
      'insertSpaces': options.insertSpaces,
      'defaultEOL': options.defaultEOL,
      'trimAutoWhitespace': options.trimAutoWhitespace,
      'bracketPairColorizationOptions':
          _json(options.bracketPairColorizationOptions),
    };

List<num> _rangeOf(Range range) => <num>[
      range.startLineNumber,
      range.startColumn,
      range.endLineNumber,
      range.endColumn,
    ];

class _FakeTextModel {
  _FakeTextModel(this.tooLarge, this.simple);

  final bool tooLarge;
  final bool simple;

  bool isTooLargeForSyncing() => tooLarge;

  bool get isForSimpleWidget => simple;
}

void main() {
  final truth = _truth();

  group('enums', () {
    test('match the real TypeScript values', () {
      expect(<String, Map<String, num>>{
        'OverviewRulerLane': <String, num>{
          'Left': model.OverviewRulerLane.Left,
          'Center': model.OverviewRulerLane.Center,
          'Right': model.OverviewRulerLane.Right,
          'Full': model.OverviewRulerLane.Full,
        },
        'GlyphMarginLane': <String, num>{
          'Left': model.GlyphMarginLane.Left,
          'Center': model.GlyphMarginLane.Center,
          'Right': model.GlyphMarginLane.Right,
        },
        'MinimapPosition': <String, num>{
          'Inline': model.MinimapPosition.Inline,
          'Gutter': model.MinimapPosition.Gutter,
        },
        'MinimapSectionHeaderStyle': <String, num>{
          'Normal': model.MinimapSectionHeaderStyle.Normal,
          'Underlined': model.MinimapSectionHeaderStyle.Underlined,
        },
        'TextDirection': <String, num>{
          'LTR': model.TextDirection.LTR,
          'RTL': model.TextDirection.RTL,
        },
        'InjectedTextCursorStops': <String, num>{
          'Both': model.InjectedTextCursorStops.Both,
          'Right': model.InjectedTextCursorStops.Right,
          'Left': model.InjectedTextCursorStops.Left,
          'None': model.InjectedTextCursorStops.None,
        },
        'EndOfLinePreference': <String, num>{
          'TextDefined': model.EndOfLinePreference.TextDefined,
          'LF': model.EndOfLinePreference.LF,
          'CRLF': model.EndOfLinePreference.CRLF,
        },
        'DefaultEndOfLine': <String, num>{
          'LF': model.DefaultEndOfLine.LF,
          'CRLF': model.DefaultEndOfLine.CRLF,
        },
        'EndOfLineSequence': <String, num>{
          'LF': model.EndOfLineSequence.LF,
          'CRLF': model.EndOfLineSequence.CRLF,
        },
        'TrackedRangeStickiness': <String, num>{
          'AlwaysGrowsWhenTypingAtEdges':
              model.TrackedRangeStickiness.AlwaysGrowsWhenTypingAtEdges,
          'NeverGrowsWhenTypingAtEdges':
              model.TrackedRangeStickiness.NeverGrowsWhenTypingAtEdges,
          'GrowsOnlyWhenTypingBefore':
              model.TrackedRangeStickiness.GrowsOnlyWhenTypingBefore,
          'GrowsOnlyWhenTypingAfter':
              model.TrackedRangeStickiness.GrowsOnlyWhenTypingAfter,
        },
        'PositionAffinity': <String, num>{
          'Left': model.PositionAffinity.Left,
          'Right': model.PositionAffinity.Right,
          'None': model.PositionAffinity.None,
          'LeftOfInjectedText': model.PositionAffinity.LeftOfInjectedText,
          'RightOfInjectedText': model.PositionAffinity.RightOfInjectedText,
        },
        'ModelConstants': <String, num>{
          'FIRST_LINE_DETECTION_LENGTH_LIMIT':
              model.ModelConstants.FIRST_LINE_DETECTION_LENGTH_LIMIT,
        },
      }, _map(truth['enums']));
    });
  });

  group('TextModelResolvedOptions', () {
    test('indentSize: tabSize derives both fields from tabSize', () {
      final options = model.TextModelResolvedOptions(_src(
        tabSize: 0,
        insertSpaces: 1,
        defaultEOL: 2,
        trimAutoWhitespace: 0,
        bracketPairColorizationOptions: <String, Object?>{
          'enabled': true,
          'independentColorPoolPerBracketType': false,
        },
      ));
      expect(_resolved(options),
          _map(truth['textModelResolvedOptions']['fromTabSize']));
    });

    test('explicit indentSize is kept', () {
      final options = model.TextModelResolvedOptions(_src(
        tabSize: 4,
        indentSize: 2,
        insertSpaces: false,
        defaultEOL: 1,
        trimAutoWhitespace: true,
        bracketPairColorizationOptions: <String, Object?>{'enabled': false},
      ));
      expect(_resolved(options),
          _map(truth['textModelResolvedOptions']['explicitIndent']));
    });

    test('clamps to 1 and applies JS truthiness', () {
      final options = model.TextModelResolvedOptions(_src(
        tabSize: -3,
        indentSize: -2,
        insertSpaces: 'yes',
        defaultEOL: 0,
        trimAutoWhitespace: 'yes',
      ));
      expect(_resolved(options),
          _map(truth['textModelResolvedOptions']['negativeClamp']));
    });

    test('equals compares values, not identity', () {
      final options = model.TextModelResolvedOptions(_src());
      final same = model.TextModelResolvedOptions(_src());
      expect(options.equals(same),
          truth['textModelResolvedOptions']['equalsSame']);
      expect(
          options.equals(model.TextModelResolvedOptions(_src(indentSize: 3))),
          truth['textModelResolvedOptions']['equalsDifferentIndent']);
      expect(
          options.equals(model.TextModelResolvedOptions(_src(
            bracketPairColorizationOptions: <String, Object?>{
              'enabled': true,
              'independentColorPoolPerBracketType': true,
            },
          ))),
          truth['textModelResolvedOptions']['equalsDifferentBracketOptions']);
    });

    test('createChangeEvent reports only changed fields', () {
      final options = model.TextModelResolvedOptions(_src(tabSize: 0));
      expect(
          options.createChangeEvent(
              model.TextModelResolvedOptions(_src(tabSize: 0))),
          _map(truth['textModelResolvedOptions']['changeEventSame']));
      expect(
          options.createChangeEvent(model.TextModelResolvedOptions(
            _src(
              tabSize: 8,
              indentSize: 4,
              insertSpaces: false,
              defaultEOL: 1,
              trimAutoWhitespace: true,
            ),
          )),
          _map(truth['textModelResolvedOptions']['changeEventDifferent']));
    });
  });

  group('runtime classes', () {
    test('FindMatch keeps range and matches', () {
      final match = model.FindMatch(Range(1, 2, 3, 4), <String>['a', 'b']);
      expect(_rangeOf(match.range), _map(truth['findMatch'])['range']);
      expect(match.matches, _map(truth['findMatch'])['matches']);
      expect(model.FindMatch(Range(1, 1, 1, 1), null).matches,
          truth['findMatchNull']);
    });

    test('ValidAnnotatedEditOperation keeps every field', () {
      final operation = model.ValidAnnotatedEditOperation(
        <String, Object?>{'uuid': 'id'},
        Range(2, 1, 2, 5),
        'text',
        true,
        false,
        true,
      );
      expect(<String, Object?>{
        'identifier': operation.identifier,
        'range': _rangeOf(operation.range),
        'text': operation.text,
        'forceMoveMarkers': operation.forceMoveMarkers,
        'isAutoWhitespaceEdit': operation.isAutoWhitespaceEdit,
      }, _map(truth['validAnnotatedEditOperation']));
    });

    test('SearchData carries the regex, separators and simple string', () {
      final data = model.SearchData(
        RegExp('ab+c', caseSensitive: false),
        null,
        'abc',
      );
      final expected = _map(truth['searchData']);
      final regex = _map(expected['regex']);
      expect(data.regex.pattern, regex['source']);
      // JS `/ab+c/gi`: ignoreCase + global; Dart has no global flag.
      final flags = regex['flags'] as String;
      expect(data.regex.isCaseSensitive, !flags.contains('i'));
      expect(data.regex.isMultiLine, flags.contains('m'));
      expect(data.regex.isDotAll, flags.contains('s'));
      expect(data.regex.isUnicode, flags.contains('u'));
      expect(data.wordSeparators, expected['wordSeparators']);
      expect(data.simpleSearch, expected['simpleSearch']);
    });

    test('ApplyEditsResult keeps the three lists', () {
      final result = model.ApplyEditsResult(
        <Object?>[
          <String, Object?>{'id': 1},
        ],
        <Object?>[
          <String, Object?>{'text': 'x'},
        ],
        <num>[3, 5],
      );
      expect(<String, Object?>{
        'reverseEdits': _json(result.reverseEdits),
        'changes': _json(result.changes),
        'trimAutoWhitespaceLineNumbers':
            result.trimAutoWhitespaceLineNumbers,
      }, _map(truth['applyEditsResult']));
    });
  });

  group('type predicates', () {
    test('isITextSnapshot over the JS input matrix', () {
      final cases = <String, Object?>{
        'null': null,
        'undefined': null,
        'number': 42,
        'emptyObject': <String, Object?>{},
        'readFunction': <String, Object?>{'read': () => null},
        'readString': <String, Object?>{'read': 'nope'},
      };
      final expected = <String, bool>{
        for (final entry in (truth['isITextSnapshot'] as List))
          (entry as List)[0] as String: entry[1] as bool,
      };
      for (final entry in cases.entries) {
        expect(model.isITextSnapshot(entry.value), expected[entry.key],
            reason: entry.key);
      }
    });

    test('isITextModel over the JS input matrix', () {
      final cases = <String, Object?>{
        'null': null,
        'emptyObject': <String, Object?>{},
        'emptyUri': <String, Object?>{'uri': ''},
        'uriObject': <String, Object?>{
          'uri': <String, Object?>{'scheme': 'file'},
        },
        'uriString': <String, Object?>{'uri': 'file:///a'},
      };
      final expected = <String, bool>{
        for (final entry in (truth['isITextModel'] as List))
          (entry as List)[0] as String: entry[1] as bool,
      };
      for (final entry in cases.entries) {
        expect(model.isITextModel(entry.value), expected[entry.key],
            reason: entry.key);
      }
    });

    test('shouldSynchronizeModel skips large and simple-widget models', () {
      final cases = <String, _FakeTextModel>{
        'normal': _FakeTextModel(false, false),
        'tooLarge': _FakeTextModel(true, false),
        'simpleWidget': _FakeTextModel(false, true),
        'both': _FakeTextModel(true, true),
      };
      final expected = <String, bool>{
        for (final entry in (truth['shouldSynchronizeModel'] as List))
          (entry as List)[0] as String: entry[1] as bool,
      };
      for (final entry in cases.entries) {
        expect(model.shouldSynchronizeModel(entry.value), expected[entry.key],
            reason: entry.key);
      }
    });
  });
}