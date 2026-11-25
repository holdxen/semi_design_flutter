// 1:1 replay of `editor/common/textModelEvents.ts` (638 lines).
//
// The source has no official unit test, so `tool/ts2dart/_batch248_truth.cjs`
// executes the real TypeScript source (preserveConstEnums, real Range.isIRange)
// and records the runtime surface:
//  - the `RawContentChangedType` const enum,
//  - font-token serialize / deserialize factories (incl. JS truthy + coercion),
//  - `LineInjectedText` (applyInjectedText with JS substring clamp,
//    fromDecorations with width-only injection + sort,
//    getFixedWidthInjectedTextRanges, withText spread),
//  - 5 raw change classes with `changeType` + `ModelRawLinesInserted` getters,
//  - `ModelRawContentChangedEvent` containsEvent + static merge,
//  - `ModelLineHeightChangedEvent.affects` Range vs Position branch,
//  - `InternalModelContentChangeEvent` merge + `_mergeChangeEvents`
//    (incl. `isEolChange` both-true logic).
//
// Adaptations replayed: erased interfaces are structural `Map<String, dynamic>`;
// JS substring clamps/swap; JS truthy + String()/Number() coercions.
import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import '../lib/src/monaco/editor/common/textModelEvents.dart' as tme;

Map<String, dynamic> _map(dynamic value) =>
    (value as Map).cast<String, dynamic>();

Map<String, dynamic> _truth() => _map(jsonDecode(
    File('tool/ts2dart/batch248_truth.json').readAsStringSync()));

/// Deep structural equality (num/String/bool/null/Map/List).
bool _same(Object? a, Object? b) {
  if (a == null || b == null) return a == b;
  if (a is num && b is num) return a == b;
  if (a is String && b is String) return a == b;
  if (a is bool && b is bool) return a == b;
  if (a is Map && b is Map) {
    if (a.length != b.length) return false;
    for (final k in a.keys) {
      if (!b.containsKey(k) || !_same(a[k], b[k])) return false;
    }
    return true;
  }
  if (a is List && b is List) {
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (!_same(a[i], b[i])) return false;
    }
    return true;
  }
  return false;
}

Map<String, dynamic> _projOptions(tme.LineInjectedText it) =>
    <String, dynamic>{
      'content': it.options['content'],
      'widthInEm': it.options['widthInEm'],
      'inlineClassName': it.options['inlineClassName'],
      'inlineClassNameAffectsLetterSpacing':
          it.options['inlineClassNameAffectsLetterSpacing'],
      'cursorStops': it.options['cursorStops'],
      'attachedData': it.options['attachedData'],
    };

Map<String, dynamic> _projInjected(tme.LineInjectedText it) =>
    <String, dynamic>{
      'ownerId': it.ownerId,
      'lineNumber': it.lineNumber,
      'column': it.column,
      'order': it.order,
      'options': _projOptions(it),
    };

/// Project a raw change instance to the same shape as the harness `projChange`.
Map<String, dynamic> _projChange(Object change) {
  final m = <String, dynamic>{};
  if (change is tme.ModelRawChange) m['changeType'] = change.changeType;
  if (change is tme.ModelRawLineChanged) {
    m['lineNumber'] = change.lineNumber;
    m['lineNumberPostEdit'] = change.lineNumberPostEdit;
  } else if (change is tme.ModelLineHeightChanged) {
    m['lineNumber'] = change.lineNumber;
  } else if (change is tme.ModelFontChanged) {
    m['lineNumber'] = change.lineNumber;
  } else if (change is tme.ModelRawLinesDeleted) {
    m['fromLineNumber'] = change.fromLineNumber;
    m['toLineNumber'] = change.toLineNumber;
    m['lastUntouchedLinePostEdit'] = change.lastUntouchedLinePostEdit;
  } else if (change is tme.ModelRawLinesInserted) {
    m['fromLineNumber'] = change.fromLineNumber;
    m['toLineNumber'] = change.toLineNumber;
    m['fromLineNumberPostEdit'] = change.fromLineNumberPostEdit;
    m['count'] = change.count;
    m['toLineNumberPostEdit'] = change.toLineNumberPostEdit;
  }
  return m;
}

List<Map<String, dynamic>> _projChanges(List<Object> changes) =>
    [for (final c in changes) _projChange(c)];

/// `[name, value]` pairs from the truth become a `Map<String, T>`.
Map<String, Object?> _pairs(Object? truthList) => <String, Object?>{
      for (final entry in (truthList as List))
        (entry as List)[0] as String: entry[1],
    };

void main() {
  final truth = _truth();

  group('batch248 / textModelEvents truth replay', () {
    test('RawContentChangedType const enum', () {
      final e = _map(truth['rawContentChangedType']);
      expect(tme.RawContentChangedType.Flush, e['Flush']);
      expect(tme.RawContentChangedType.LineChanged, e['LineChanged']);
      expect(tme.RawContentChangedType.LinesDeleted, e['LinesDeleted']);
      expect(tme.RawContentChangedType.LinesInserted, e['LinesInserted']);
      expect(tme.RawContentChangedType.EOLChanged, e['EOLChanged']);
    });

    test('font token serialize / deserialize', () {
      final f = _map(truth['fontTokenOptions']);
      final inputs = <String, Map<String, dynamic>>{
        for (final raw in (f['inputs'] as List))
          (raw as List)[0] as String: _map(raw[1]),
      };
      final serialize = tme.serializeFontTokenOptions();
      final deserialize = tme.deserializeFontTokenOptions();
      for (final entry in (f['serialize'] as List)) {
        final pair = entry as List;
        expect(_same(serialize(inputs[pair[0] as String]!), pair[1]),
            isTrue, reason: 'serialize ${pair[0]}');
      }
      for (final entry in (f['deserialize'] as List)) {
        final pair = entry as List;
        expect(_same(deserialize(inputs[pair[0] as String]!), pair[1]),
            isTrue, reason: 'deserialize ${pair[0]}');
      }
    });

    test('LineInjectedText.applyInjectedText', () {
      final lit = _map(truth['lineInjectedText']);
      final ins = (int column, String content) => tme.LineInjectedText(
          1, 1, column, <String, dynamic>{'content': content}, 0);
      final cases = <String, List<tme.LineInjectedText>?>{
        'null': null,
        'empty': [],
        'single': [ins(3, 'XX')],
        'multiple': [ins(3, 'XX'), ins(6, 'YY')],
        'atStart': [ins(1, 'P')],
        'atEnd': [ins(4, 'S')],
        'emptyContent': [ins(2, '')],
        'beyondEnd': [ins(99, 'Z')],
      };
      final lines = <String, String>{
        'null': 'abcdef',
        'empty': 'abcdef',
        'single': 'abcdef',
        'multiple': 'abcdefgh',
        'atStart': 'abc',
        'atEnd': 'abc',
        'emptyContent': 'abc',
        'beyondEnd': 'abc',
      };
      final expected = _pairs(lit['applyInjectedText']);
      for (final entry in expected.entries) {
        final actual = tme.LineInjectedText.applyInjectedText(
            lines[entry.key]!, cases[entry.key]);
        expect(actual, entry.value, reason: 'apply ${entry.key}');
      }
    });

    test('LineInjectedText.fromDecorations', () {
      final lit = _map(truth['lineInjectedText']);
      final decorations = <Object?>[
        <String, dynamic>{
          'ownerId': 10,
          'range': {'startLineNumber': 2, 'startColumn': 5, 'endLineNumber': 2, 'endColumn': 9},
          'options': {
            'before': {'content': 'B'},
            'after': {'content': '', 'widthInEm': 1.2},
          },
        },
        <String, dynamic>{
          'ownerId': 11,
          'range': {'startLineNumber': 1, 'startColumn': 3, 'endLineNumber': 1, 'endColumn': 4},
          'options': {
            'before': {'content': '', 'widthInEm': 0},
            'after': {'content': 'A'},
          },
        },
        <String, dynamic>{
          'ownerId': 12,
          'range': {'startLineNumber': 2, 'startColumn': 1, 'endLineNumber': 2, 'endColumn': 2},
          'options': {
            'before': {'content': '', 'widthInEm': 2},
            'after': {'content': ''},
          },
        },
        <String, dynamic>{
          'ownerId': 13,
          'range': {'startLineNumber': 3, 'startColumn': 1, 'endLineNumber': 3, 'endColumn': 2},
          'options': <String, dynamic>{},
        },
      ];
      final actual = tme.LineInjectedText.fromDecorations(decorations)
          .map(_projInjected)
          .toList();
      expect(_same(actual, lit['fromDecorations']), isTrue);
      expect(tme.LineInjectedText.fromDecorations(const []), isEmpty);
    });

    test('LineInjectedText.getFixedWidthInjectedTextRanges', () {
      final lit = _map(truth['lineInjectedText']);
      final ins = (int column, String content, [num? width]) =>
          tme.LineInjectedText(1, 1, column, <String, dynamic>{
            'content': content,
            if (width != null) 'widthInEm': width,
          }, 0);
      final cases = <String, List<tme.LineInjectedText>?>{
        'null': null,
        'empty': [],
        'noWidth': [ins(1, 'ab')],
        'oneWidth': [ins(2, 'ab', 1.5)],
        'multi': [ins(1, 'ab', 1), ins(3, '', 0.5), ins(4, 'xyz'), ins(5, 'q', 2)],
      };
      final expected = _pairs(lit['getFixedWidthInjectedTextRanges']);
      for (final entry in expected.entries) {
        final actual = tme.LineInjectedText.getFixedWidthInjectedTextRanges(cases[entry.key]);
        expect(_same(actual, entry.value), isTrue, reason: 'width ${entry.key}');
      }
    });

    test('LineInjectedText.withText spread', () {
      final lit = _map(_map(truth['lineInjectedText'])['withText']);
      final opts = <String, dynamic>{
        'content': 'orig',
        'inlineClassName': 'cls',
        'inlineClassNameAffectsLetterSpacing': true,
        'widthInEm': 1.5,
        'cursorStops': 2,
        'attachedData': {'k': 'v'},
      };
      final base = tme.LineInjectedText(9, 3, 4, opts, 1);
      final result = base.withText('NEW');
      expect(_same(_projInjected(base), lit['base']), isTrue);
      expect(_same(_projInjected(result), lit['result']), isTrue);
      expect(identical(result, base), isFalse);
      expect(lit['newInstance'], isTrue);
      expect(opts['content'], 'orig'); // original unchanged
    });

    test('raw change classes + changeType + getters', () {
      final rc = _map(truth['rawChanges']);
      final cases = <String, Object>{
        'flush': tme.ModelRawFlush(),
        'lineChanged': tme.ModelRawLineChanged(4, 7),
        'lineHeightChanged': tme.ModelLineHeightChanged(1, 'dec1', 5, 1.5),
        'lineHeightChangedNull': tme.ModelLineHeightChanged(1, 'dec2', 6, null),
        'fontChanged': tme.ModelFontChanged(2, 8),
        'linesDeleted': tme.ModelRawLinesDeleted(3, 6, 2),
        'linesInserted': tme.ModelRawLinesInserted(5, 7, 4),
        'eolChanged': tme.ModelRawEOLChanged(),
      };
      for (final entry in cases.entries) {
        expect(_same(_projChange(entry.value), rc[entry.key]), isTrue,
            reason: entry.key);
      }
    });

    test('ModelRawContentChangedEvent containsEvent + merge', () {
      final ev = _map(truth['rawContentChangedEvent']);
      final rawEv = tme.ModelRawContentChangedEvent(<tme.ModelRawChange>[
        tme.ModelRawFlush(),
        tme.ModelRawLineChanged(1, 1),
      ], 7, false, false);
      expect(_same(_projChanges(rawEv.changes), ev['changes']), isTrue);
      expect(rawEv.versionId, ev['versionId']);
      expect(rawEv.isUndoing, ev['isUndoing']);
      expect(rawEv.isRedoing, ev['isRedoing']);
      expect(rawEv.resultingSelection, isNull);
      final contains = _pairs(ev['containsEvent']);
      final types = <String, int>{
        'Flush': tme.RawContentChangedType.Flush,
        'LineChanged': tme.RawContentChangedType.LineChanged,
        'LinesDeleted': tme.RawContentChangedType.LinesDeleted,
        'LinesInserted': tme.RawContentChangedType.LinesInserted,
        'EOLChanged': tme.RawContentChangedType.EOLChanged,
        'unknown': 99,
      };
      for (final entry in contains.entries) {
        expect(rawEv.containsEvent(types[entry.key]!), entry.value,
            reason: 'contains ${entry.key}');
      }

      final a = tme.ModelRawContentChangedEvent(
          <tme.ModelRawChange>[tme.ModelRawFlush()], 1, true, false);
      final b = tme.ModelRawContentChangedEvent(<tme.ModelRawChange>[
        tme.ModelRawLineChanged(2, 3),
        tme.ModelRawEOLChanged(),
      ], 2, false, true);
      final merged = tme.ModelRawContentChangedEvent.merge(a, b);
      final mt = _map(ev['merge']);
      expect(_same(_projChanges(merged.changes), mt['changes']), isTrue);
      expect(merged.versionId, mt['versionId']);
      expect(merged.isUndoing, mt['isUndoing']);
      expect(merged.isRedoing, mt['isRedoing']);
      expect(merged.resultingSelection, isNull);
      expect([a.changes.length, b.changes.length], mt['originalsUnchanged']);
    });

    test('injected text / font changed events', () {
      final injEv = tme.ModelInjectedTextChangedEvent(
          <tme.ModelRawLineChanged>[tme.ModelRawLineChanged(2, 2)]);
      final injTruth = _map(truth['injectedTextChangedEvent']);
      expect(_same(_projChanges(injEv.changes), injTruth['changes']), isTrue);

      final fontEv = tme.ModelFontChangedEvent(
          <tme.ModelFontChanged>[tme.ModelFontChanged(3, 4)]);
      final fontTruth = _map(truth['fontChangedEvent']);
      expect(_same(_projChanges(fontEv.changes), fontTruth['changes']), isTrue);
    });

    test('ModelLineHeightChangedEvent.affects Range vs Position', () {
      final lh = _map(truth['lineHeightChangedEvent']);
      final changes = <tme.ModelLineHeightChanged>[
        tme.ModelLineHeightChanged(1, 'd1', 5, 1),
        tme.ModelLineHeightChanged(1, 'd2', 10, 2),
      ];
      final ev = tme.ModelLineHeightChangedEvent(changes);
      expect(_same(_projChanges(ev.changes), lh['changes']), isTrue);
      final inputs = <String, Object?>{
        'rangeHit': {'startLineNumber': 4, 'startColumn': 1, 'endLineNumber': 6, 'endColumn': 1},
        'rangeMiss': {'startLineNumber': 6, 'startColumn': 1, 'endLineNumber': 9, 'endColumn': 1},
        'rangeExact': {'startLineNumber': 5, 'startColumn': 1, 'endLineNumber': 5, 'endColumn': 1},
        'positionHit': {'lineNumber': 10},
        'positionMiss': {'lineNumber': 11},
        'positionViaRangeObj': {
          'lineNumber': 5, 'startLineNumber': 5, 'startColumn': 1,
          'endLineNumber': 5, 'endColumn': 1,
        },
      };
      final expected = _pairs(lh['affects']);
      for (final entry in expected.entries) {
        expect(ev.affects(inputs[entry.key]), entry.value,
            reason: 'affects ${entry.key}');
      }
    });

    test('InternalModelContentChangeEvent merge + isEolChange', () {
      final im = _map(truth['internalModelContentChangeEvent']);
      final contentA = <String, dynamic>{
        'changes': [{'text': 'a'}],
        'eol': '\n',
        'versionId': 1,
        'isUndoing': true,
        'isRedoing': false,
        'isFlush': false,
        'isEolChange': false,
        'detailedReasons': ['r1'],
        'detailedReasonsChangeLengths': [1],
      };
      final contentB = <String, dynamic>{
        'changes': [{'text': 'b'}, {'text': 'c'}],
        'eol': '\r\n',
        'versionId': 2,
        'isUndoing': false,
        'isRedoing': true,
        'isFlush': true,
        'isEolChange': true,
        'detailedReasons': ['r2', 'r3'],
        'detailedReasonsChangeLengths': [1, 1],
      };
      final intA = tme.InternalModelContentChangeEvent(
        tme.ModelRawContentChangedEvent(
            <tme.ModelRawChange>[tme.ModelRawFlush()], 1, true, false),
        contentA,
      );
      final intB = tme.InternalModelContentChangeEvent(
        tme.ModelRawContentChangedEvent(
            <tme.ModelRawChange>[tme.ModelRawLineChanged(2, 3)], 2, false, true),
        contentB,
      );
      expect(intA.rawContentChangedEvent.versionId, im['ctorRawVersion']);
      expect(intA.contentChangedEvent['eol'], im['ctorContentEol']);
      final merged = intA.merge(intB);
      final mt = _map(im['merge']);
      final rawT = _map(mt['raw']);
      expect(_same(_projChanges(merged.rawContentChangedEvent.changes), rawT['changes']), isTrue);
      expect(merged.rawContentChangedEvent.versionId, rawT['versionId']);
      expect(merged.rawContentChangedEvent.isUndoing, rawT['isUndoing']);
      expect(merged.rawContentChangedEvent.isRedoing, rawT['isRedoing']);
      expect(merged.rawContentChangedEvent.resultingSelection, isNull);
      expect(_same(merged.contentChangedEvent, mt['content']), isTrue);

      Map<String, dynamic> mkContent(bool eol) => <String, dynamic>{
            ...contentB,
            'isEolChange': eol,
          };
      tme.InternalModelContentChangeEvent mkEvent(bool eol) =>
          tme.InternalModelContentChangeEvent(
            tme.ModelRawContentChangedEvent(<tme.ModelRawChange>[], 3, false, false),
            mkContent(eol),
          );
      expect(mkEvent(true).merge(mkEvent(true)).contentChangedEvent['isEolChange'],
          im['isEolChangeBothTrue']);
      expect(mkEvent(true).merge(mkEvent(false)).contentChangedEvent['isEolChange'],
          im['isEolChangeOneFalse']);
      expect(mkEvent(false).merge(mkEvent(true)).contentChangedEvent['isEolChange'],
          im['isEolChangeOtherFalse']);
    });
  });
}
