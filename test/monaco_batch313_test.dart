// batch313: viewLinesViewportData.ts truth replay.
import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:semi_design_flutter/src/monaco/editor/common/core/range.dart'
    show Range;
import 'package:semi_design_flutter/src/monaco/editor/common/core/selection.dart'
    show Selection;
import 'package:semi_design_flutter/src/monaco/editor/common/viewLayout/viewLinesViewportData.dart'
    show IPartialViewLinesViewportData, IViewModelForViewportData, ViewportData;

Map<String, dynamic> _truth() => jsonDecode(
    File('tool/ts2dart/batch313_truth.json').readAsStringSync())
    as Map<String, dynamic>;

List<Object?> _rangeJson(Range r) => <Object?>[
      r.startLineNumber,
      r.startColumn,
      r.endLineNumber,
      r.endColumn,
    ];

class _Model implements IViewModelForViewportData {
  final List<Object?> calls = <Object?>[];

  @override
  int getLineMinColumn(int lineNumber) => lineNumber == 3 ? 4 : 1;

  @override
  int getLineMaxColumn(int lineNumber) => lineNumber == 5 ? 7 : 20;

  @override
  Object getViewportViewLineRenderingData(Range visibleRange, int lineNumber) {
    calls.add(<Object?>['render', _rangeJson(visibleRange), lineNumber]);
    return <String, Object?>{'id': 'render-$lineNumber'};
  }

  @override
  bool getViewLineContinuesWithWrappedLine(int lineNumber) {
    calls.add(<Object?>['wrapped', lineNumber]);
    return lineNumber == 4;
  }

  @override
  List<Object> getDecorationsInViewport(Range visibleRange) {
    calls.add(<Object?>['decorations', _rangeJson(visibleRange)]);
    return <Object>[
      <String, Object?>{'id': 'd1'},
      <String, Object?>{'id': 'd2'},
    ];
  }
}

void main() {
  final Map<String, dynamic> truth = _truth();
  final Map<String, dynamic> c =
      (truth['cases'] as List<dynamic>)[0] as Map<String, dynamic>;
  final Map<String, dynamic> partial =
      c['partial'] as Map<String, dynamic>;

  test(c['name'] as String, () {
    final _Model model = _Model();
    final List<Selection> selections = <Selection>[
      Selection(1, 1, 1, 3),
      Selection(2, 2, 2, 5),
    ];
    final ViewportData data = ViewportData(
      selections,
      IPartialViewLinesViewportData(
        startLineNumber: partial['startLineNumber'] as int,
        endLineNumber: partial['endLineNumber'] as int,
        relativeVerticalOffset:
            (partial['relativeVerticalOffset'] as List<dynamic>)
                .map((e) => e as num)
                .toList(),
        bigNumbersDelta: partial['bigNumbersDelta'] as int,
        lineHeight: partial['lineHeight'] as int,
      ),
      (c['whitespace'] as List<dynamic>).cast<Object>(),
      model,
    );

    final Object? fields = <String, Object?>{
      'selections': selections.map(_rangeJson).toList(),
      'startLineNumber': data.startLineNumber,
      'endLineNumber': data.endLineNumber,
      'relativeVerticalOffset': data.relativeVerticalOffset,
      'bigNumbersDelta': data.bigNumbersDelta,
      'lineHeight': data.lineHeight,
      'whitespaceViewportData': data.whitespaceViewportData,
      'visibleRange': _rangeJson(data.visibleRange),
    };
    expect(
      jsonEncode(fields),
      jsonEncode((c['result'] as Map<String, dynamic>)['fields']),
    );
    expect(data.getViewLineRenderingData(4),
        (c['result'] as Map<String, dynamic>)['render']);
    expect(data.getViewLineContinuesWithWrappedLine(4),
        (c['result'] as Map<String, dynamic>)['wrapped']);
    expect(
      data
          .getDecorationsInViewport()
          .map((d) => (d as Map<String, Object?>)['id'])
          .toList(),
      (c['result'] as Map<String, dynamic>)['decorations'],
    );
    expect(
      model.calls,
      (c['result'] as Map<String, dynamic>)['calls'],
    );
  });
}
