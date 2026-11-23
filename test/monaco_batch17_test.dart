import 'package:flutter_test/flutter_test.dart';

import 'package:semi_design_flutter/src/monaco/base/browser/ui/list/splice.dart' as splice;
import 'package:semi_design_flutter/src/monaco/base/common/sequence.dart' as seq;
import 'package:semi_design_flutter/src/monaco/editor/common/diff/defaultLinesDiffComputer/lineSequence.dart' as ls;
import 'package:semi_design_flutter/src/monaco/editor/common/core/ranges/offsetRange.dart' as ranges;
import 'package:semi_design_flutter/src/monaco/editor/contrib/indentation/common/indentUtils.dart' as iu;
import 'package:semi_design_flutter/src/monaco/editor/common/textModelGuides.dart' as guides;
import 'package:semi_design_flutter/src/monaco/editor/common/core/position.dart' as pos;
import 'package:semi_design_flutter/src/monaco/platform/action/common/actionCommonCategories.dart' as cat;

void main() {
  group('batch17 · lineSequence', () {
    test('getElement/length', () {
      final s = ls.LineSequence([10, 20, 30], ['a', 'b', 'c']);
      expect(s.length, 3);
      expect(s.getElement(0), 10);
      expect(s.getElement(2), 30);
    });

    test('getBoundaryScore uses indentation, clamped at ends', () {
      // '    a' -> indent 4 ; '  b' -> indent 2 ; 'c' -> 0 ; '\td' -> 1 tab.
      final s = ls.LineSequence([0, 0, 0, 0], ['    a', '  b', 'c', '\td']);
      // length=0: before 0, after = indent(lines[0]) = 4 => 1000 - 4.
      expect(s.getBoundaryScore(0), 996);
      // length=1: before = indent('    a') = 4, after = indent('  b') = 2 => 1000 - 6.
      expect(s.getBoundaryScore(1), 994);
      // length=4 (== lines.length): after 0, before = indent('\td') = 1 => 1000 - 1.
      expect(s.getBoundaryScore(4), 999);
    });

    test('getText joins the slice with newline', () {
      final s = ls.LineSequence([0, 0, 0], ['a', 'b', 'c']);
      expect(s.getText(ranges.OffsetRange.fromTo(0, 2)), 'a\nb');
      expect(s.getText(ranges.OffsetRange.fromTo(1, 3)), 'b\nc');
      expect(s.getText(ranges.OffsetRange.emptyAt(1)), '');
    });

    test('isStronglyEqual compares raw lines', () {
      final s = ls.LineSequence([7, 7, 9], ['a', 'a', 'b']);
      expect(s.isStronglyEqual(0, 1), isTrue);
      expect(s.isStronglyEqual(0, 2), isFalse);
    });

    test('getIndentation counts leading spaces and tabs', () {
      expect(ls.getIndentation('   abc'), 3);
      expect(ls.getIndentation('\t\tx'), 2);
      expect(ls.getIndentation(' x '), 1);
      expect(ls.getIndentation(''), 0);
    });
  });

  group('batch17 · indentUtils', () {
    test('getSpaceCnt expands tabs to tabSize', () {
      expect(iu.getSpaceCnt('', 4), 0);
      expect(iu.getSpaceCnt('abcd', 4), 4);
      expect(iu.getSpaceCnt('\t', 4), 4);
      expect(iu.getSpaceCnt('\t\tab', 4), 10);
    });

    test('generateIndent with spaces', () {
      expect(iu.generateIndent(0, 4, true), '');
      expect(iu.generateIndent(6, 4, true), '      ');
      expect(iu.generateIndent(-3, 4, true), '');
    });

    test('generateIndent with tabs + remainder spaces', () {
      expect(iu.generateIndent(9, 4, false), '\t\t ');
      expect(iu.generateIndent(8, 4, false), '\t\t');
      expect(iu.generateIndent(3, 4, false), '   ');
      expect(iu.generateIndent(-1, 4, false), '');
    });
  });

  group('batch17 · splice', () {
    test('CombinedSpliceable forwards to all spliceables', () {
      final a = seq.Sequence<int>();
      final b = seq.Sequence<int>();
      a.elements.addAll([1, 2, 3]);
      b.elements.addAll([1, 2, 3]);
      final c = splice.CombinedSpliceable<int>([a, b]);

      c.splice(1, 1, [9, 8]);

      expect(a.elements, [1, 9, 8, 3]);
      expect(b.elements, [1, 9, 8, 3]);
    });

    test('empty spliceables is a no-op', () {
      final c = splice.CombinedSpliceable<int>([]);
      c.splice(0, 0, [1]); // should not throw
      expect(true, isTrue);
    });
  });

  group('batch17 · actionCommonCategories', () {
    test('Categories expose localized strings', () {
      expect(cat.Categories.View.value, 'View');
      expect(cat.Categories.View.original, 'View');
      expect(cat.Categories.Help.value, 'Help');
      expect(cat.Categories.Test.value, 'Test');
      expect(cat.Categories.File.value, 'File');
      expect(cat.Categories.Preferences.value, 'Preferences');
      expect(cat.Categories.Developer.value, 'Developer');
    });
  });

  group('batch17 · textModelGuides', () {
    test('IndentGuide requires exactly one of visibleColumn/column', () {
      expect(
        () => guides.IndentGuide(5, -1, 'c', null, -1, -1),
        returnsNormally,
      );
      expect(
        () => guides.IndentGuide(-1, 5, 'c', null, -1, -1),
        returnsNormally,
      );
      // Both set -> throw; both -1 -> throw (1:1 source guard).
      expect(() => guides.IndentGuide(5, 5, 'c', null, -1, -1), throwsA(isA<StateError>()));
      expect(() => guides.IndentGuide(-1, -1, 'c', null, -1, -1), throwsA(isA<StateError>()));
    });

    test('HorizontalGuidesState / IndentGuideHorizontalLine carry fields', () {
      expect(guides.HorizontalGuidesState.values.length, 3);
      final h = guides.IndentGuideHorizontalLine(true, 42);
      expect(h.top, isTrue);
      expect(h.endColumn, 42);

      final opts = guides.BracketGuideOptions(
        includeInactive: true,
        horizontalGuides: guides.HorizontalGuidesState.Enabled,
        highlightActive: false,
      );
      expect(opts.includeInactive, isTrue);
      expect(opts.horizontalGuides, guides.HorizontalGuidesState.Enabled);
      expect(opts.highlightActive, isFalse);

      final g = guides.IndentGuide(3, -1, 'g', h, 10, 20);
      expect(g.visibleColumn, 3);
      expect(g.column, -1);
      expect(g.horizontalLine, same(h));
      expect(g.forWrappedLinesAfterColumn, 10);
      expect(g.forWrappedLinesBeforeOrAtColumn, 20);
    });

    test('IActiveIndentGuideInfo is a plain carrier', () {
      final info = guides.IActiveIndentGuideInfo(
        startLineNumber: 2,
        endLineNumber: 5,
        indent: 4,
      );
      expect(info.startLineNumber, 2);
      expect(info.endLineNumber, 5);
      expect(info.indent, 4);

      // IPosition carrier still functional for bracket-guide signatures.
      final p = pos.Position(3, 7);
      expect(p.lineNumber, 3);
      expect(p.column, 7);
    });
  });
}
