// 1:1 replay of
// `editor/contrib/dropOrPasteInto/test/browser/editSort.test.ts` (69 lines).
// Truth: `tool/ts2dart/_batch452_truth.cjs` -> `batch452_truth.json`.
import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import '../lib/src/monaco/base/common/hierarchicalKind.dart' show HierarchicalKind;
import '../lib/src/monaco/editor/contrib/dropOrPasteInto/browser/edit.dart'
    show DropYieldToForEdit, IYieldToEdit, sortEditsByYieldTo;
import '../lib/src/monaco/editor/contrib/dropOrPasteInto/test/browser/editSort.test.dart'
    as official;

Map<String, dynamic> _map(dynamic value) =>
    (value as Map).cast<String, dynamic>();

Map<String, dynamic> _truth() => _map(jsonDecode(
    File('tool/ts2dart/batch452_truth.json').readAsStringSync()));

class _Edit implements IYieldToEdit {
  _Edit(this.kind, {this.handledMimeType, this.yieldTo});

  @override
  final HierarchicalKind? kind;

  @override
  final String? handledMimeType;

  @override
  final List<DropYieldToForEdit>? yieldTo;
}

_Edit _edit(String kind,
        {String? handledMimeType, List<DropYieldToForEdit>? yieldTo}) =>
    _Edit(HierarchicalKind(kind),
        handledMimeType: handledMimeType, yieldTo: yieldTo);

List<String?> _kinds(List<_Edit> edits) =>
    sortEditsByYieldTo<_Edit>(edits).map((e) => e.kind?.value).toList();

void main() {
  final truth = _truth();

  test('the official suite runs', () {
    official.runAll();
  });

  test('sortEditsByYieldTo matches the real TS results', () {
    final cases = <String, List<String?>>{
      'empty': _kinds(<_Edit>[]),
      'singleYield': _kinds(<_Edit>[
        _edit('a', yieldTo: <DropYieldToForEdit>[
          DropYieldToForEdit(kind: HierarchicalKind('b')),
        ]),
        _edit('b'),
      ]),
      'chain1': _kinds(<_Edit>[
        _edit('c', yieldTo: <DropYieldToForEdit>[
          DropYieldToForEdit(kind: HierarchicalKind('a')),
        ]),
        _edit('a', yieldTo: <DropYieldToForEdit>[
          DropYieldToForEdit(kind: HierarchicalKind('b')),
        ]),
        _edit('b'),
      ]),
      'chain2': _kinds(<_Edit>[
        _edit('a', yieldTo: <DropYieldToForEdit>[
          DropYieldToForEdit(kind: HierarchicalKind('b')),
        ]),
        _edit('c', yieldTo: <DropYieldToForEdit>[
          DropYieldToForEdit(kind: HierarchicalKind('a')),
        ]),
        _edit('b'),
      ]),
      'noYieldUsed': _kinds(<_Edit>[
        _edit('c', yieldTo: <DropYieldToForEdit>[
          DropYieldToForEdit(kind: HierarchicalKind('x')),
        ]),
        _edit('a', yieldTo: <DropYieldToForEdit>[
          DropYieldToForEdit(kind: HierarchicalKind('y')),
        ]),
        _edit('b'),
      ]),
      'mimeType': _kinds(<_Edit>[
        _edit('m1',
            handledMimeType: 'text/plain',
            yieldTo: <DropYieldToForEdit>[
              DropYieldToForEdit(mimeType: 'text/plain'),
            ]),
        _edit('m2', handledMimeType: 'text/html'),
      ]),
    };

    final expected = <String, List<String?>>{
      for (final raw in (truth['cases'] as List))
        (raw as List)[0] as String:
            (raw[1] as List).map((e) => e as String?).toList(),
    };
    for (final entry in expected.entries) {
      expect(cases[entry.key], entry.value, reason: entry.key);
    }
    expect(cases.length, expected.length);
  });
}
