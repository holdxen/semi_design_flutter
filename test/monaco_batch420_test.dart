// 1:1 replay of `editor/contrib/inlineCompletions/browser/model/ghostText.ts`.
// Truth: `tool/ts2dart/_batch420_truth.cjs` -> `batch420_truth.json`.
import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import '../lib/src/monaco/editor/common/core/ranges/columnRange.dart'
    show ColumnRange;
import '../lib/src/monaco/editor/contrib/inlineCompletions/browser/model/ghostText.dart';

Map<String, dynamic> _map(dynamic v) => (v as Map).cast<String, dynamic>();

Map<String, dynamic> _truth() {
  final Map<String, dynamic> root = _map(
    jsonDecode(File('tool/ts2dart/batch420_truth.json').readAsStringSync()),
  );
  return <String, dynamic>{
    for (final dynamic r in root['results'] as List<dynamic>)
      (r as Map)['label'] as String: <String, dynamic>{
        for (final MapEntry<Object?, Object?> e
            in (r as Map).cast<Object?, Object?>().entries)
          if (e.key != 'label') e.key as String: e.value,
      },
  };
}

Map<String, Object?> _partJson(GhostTextPart p) => <String, Object?>{
      'column': p.column,
      'text': p.text,
      'preview': p.preview,
      'lines': p.lines.map((IGhostTextLine l) => l.line).toList(),
    };

Map<String, Object?> _ghostJson(GhostText g) => <String, Object?>{
      'lineNumber': g.lineNumber,
      'parts': g.parts.map(_partJson).toList(),
      'lineCount': g.lineCount,
      'isEmpty': g.isEmpty(),
    };

void main() {
  final Map<String, dynamic> truth = _truth();

  test('ghost text replay TS truth', () {
    final Map<String, Object?> actual = <String, Object?>{};

    // basic
    {
      final GhostText g = GhostText(1, <GhostTextPart>[
        GhostTextPart(2, 'abc', false),
        GhostTextPart(5, 'XY', true),
      ]);
      actual['ghost-basic'] = <String, Object?>{
        'ghost': _ghostJson(g),
        'render': g.render('hello world'),
        'screenReader': g.renderForScreenReader('hello world'),
      };
    }

    // equals
    {
      final GhostText a = GhostText(1, <GhostTextPart>[
        GhostTextPart(2, 'abc', false),
      ]);
      actual['equals'] = <String, Object?>{
        'eq': a.equals(GhostText(1, <GhostTextPart>[
          GhostTextPart(2, 'abc', false),
        ])),
        'diffPart': a.equals(GhostText(1, <GhostTextPart>[
          GhostTextPart(2, 'abd', false),
        ])),
        'diffLine': a.equals(GhostText(2, <GhostTextPart>[
          GhostTextPart(2, 'abc', false),
        ])),
      };
    }

    // empty
    {
      final GhostText g = GhostText(1, <GhostTextPart>[]);
      actual['empty'] = <String, Object?>{
        'ghost': _ghostJson(g),
        'render': g.render('hello'),
        'screenReader': g.renderForScreenReader('hello'),
      };
    }

    // multi-line
    {
      final GhostText g = GhostText(1, <GhostTextPart>[
        GhostTextPart(2, 'a\nb\nc', false),
      ]);
      actual['multi-line'] = <String, Object?>{
        'ghost': _ghostJson(g),
        'render': g.render('hello'),
        'screenReader': g.renderForScreenReader('hello'),
      };
    }

    // replacement
    {
      final GhostTextReplacement r = GhostTextReplacement(
        1,
        ColumnRange(2, 5),
        'XYZ',
        2,
      );
      actual['replacement'] = <String, Object?>{
        'lineNumber': r.lineNumber,
        'parts': r.parts.map(_partJson).toList(),
        'newLines': r.newLines,
        'lineCount': r.lineCount,
        'isEmpty': r.isEmpty(),
        'render': r.render('hello world'),
        'debugRender': r.render('hello world', true),
        'screenReader': r.renderForScreenReader('hello world'),
      };
    }

    // union equals
    {
      final GhostText g = GhostText(1, <GhostTextPart>[
        GhostTextPart(2, 'a', false),
      ]);
      final GhostTextReplacement r =
          GhostTextReplacement(1, ColumnRange(2, 5), 'a');
      actual['union-equals'] = <String, Object?>{
        'sameGhost': ghostTextOrReplacementEquals(
          g,
          GhostText(1, <GhostTextPart>[GhostTextPart(2, 'a', false)]),
        ),
        'ghostVsReplacement': ghostTextOrReplacementEquals(g, r),
        'bothUndefined': ghostTextOrReplacementEquals(null, null),
      };
    }

    for (final String key in truth.keys) {
      expect(
        jsonEncode(actual[key]),
        jsonEncode(truth[key]),
        reason: 'mismatch at $key',
      );
    }
  });
}
