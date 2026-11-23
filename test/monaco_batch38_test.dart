import 'package:flutter_test/flutter_test.dart';

import 'package:semi_design_flutter/src/monaco/base/common/observableInternal/changeTracker.dart'
    as ct;
import 'package:semi_design_flutter/src/monaco/editor/contrib/snippet/test/browser/snippetParser.test.dart'
    as sp;
import 'package:semi_design_flutter/src/monaco/languages/features/typescript/lib/lib.dart'
    as libmap;
import 'package:semi_design_flutter/src/monaco/languages/features/typescript/lib/lib.index.dart'
    as libset;

void main() {
  group('batch38 / snippetParser 54-case suite + lib maps + changeTracker', () {
    test('typescript lib maps: 100 entries each, contents preserved', () {
      assert(libmap.libFileMap.length == 100);
      assert(libset.libFileSet.length == 100);
      assert(libmap.libFileMap.containsKey('lib.d.ts'));
      assert(libmap.libFileMap.containsKey('lib.es5.d.ts'));
      assert(libmap.libFileMap.containsKey('lib.webworker.iterable.d.ts'));
      assert(libmap.libFileMap['lib.d.ts']!.contains('reference lib="es5"'));
      assert(libset.libFileSet['lib.d.ts'] == true);
      assert(libset.libFileSet['lib.es5.d.ts'] == true);
      // every set key has a corresponding map entry
      for (final String k in libset.libFileSet.keys) {
        assert(libmap.libFileMap.containsKey(k));
      }
    });

    test('changeTracker: recordChanges/lazy API surface', () {
      // ChangeSummary reserves the "changes" key and records changes in order.
      final ct.ChangeSummary summary = ct.ChangeSummary();
      assert(summary.changes.isEmpty);
      summary.changes.add(const ct.RecordedChange('x', 42));
      assert(summary.changes.length == 1);
      assert(summary.changes[0].key == 'x');
      assert(summary.changes[0].change == 42);
      summary['obs'] = 7;
      assert(summary['obs'] == 7);
      var threw = false;
      try {
        summary['changes'] = 1;
      } catch (_) {
        threw = true;
      }
      assert(threw);
    });

    test('snippetParser: full 54-case ported suite', () {
      sp.runAll();
    });
  });
}
