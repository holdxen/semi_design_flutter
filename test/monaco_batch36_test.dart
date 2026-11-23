import 'package:flutter_test/flutter_test.dart';

import 'package:semi_design_flutter/src/monaco/editor/common/core/edits/lineEdit.dart'
    as le;
import 'package:semi_design_flutter/src/monaco/editor/common/core/ranges/lineRange.dart'
    show LineRange;
import 'package:semi_design_flutter/src/monaco/editor/contrib/inlineCompletions/test/browser/graph.test.dart'
    as graph;
import 'package:semi_design_flutter/src/monaco/editor/contrib/inlineCompletions/test/browser/layout.test.dart'
    as layout;
import 'package:semi_design_flutter/src/monaco/editor/test/common/model/annotations.test.dart'
    as ann;
import 'package:semi_design_flutter/src/monaco/editor/test/common/model/bracketPairColorizer/beforeEditPositionMapper.test.dart'
    as bepm;

void main() {
  group('batch36 / lineEdit + ported mocha suites', () {
    test('LineEdit empty/serialize/deserialize', () {
      assert(le.LineEdit.empty.isEmpty());
      final le.LineEdit edit = le.LineEdit(<le.LineReplacement>[
        le.LineReplacement(
          LineRange(1, 2),
          <String>['x', 'y'],
        ),
      ]);
      final List<le.SerializedLineReplacement> data = edit.serialize();
      assert(data.length == 1);
      final le.LineEdit restored = le.LineEdit.deserialize(data);
      assert(restored.toString() == edit.toString());
    });

    test('LineReplacement serialize tuple shape', () {
      final le.LineReplacement r =
          le.LineReplacement(LineRange(3, 5), <String>['a']);
      final le.SerializedLineReplacement s = r.serialize();
      assert(s.$1 == 3 && s.$2 == 5 && s.$3.length == 1);
      assert(le.SerializedLineReplacementX.is_(s as Object) == false);
      assert(le.SerializedLineReplacementX.is_(<Object?>[3, 5, <String>['a']]) == true);
    });

    test('Layout getMaxTowerHeightInAvailableArea', () {
      layout.runAll();
    });

    test('DirectedGraph from/removeCycles/getOutgoing', () {
      graph.runAll();
    });

    test('Annotations visual suite', () {
      ann.runAll();
    });

    test('BeforeEditPositionMapper visual grid suite', () {
      bepm.runAll();
    });
  });
}
