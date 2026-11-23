// Regression tests for the 1:1 Monaco port (see docs/monaco_editor_1to1_移植计划.md).
// Each group targets a translated source file; assertions mirror the semantics
// of the TypeScript original. Extend as more files are translated.

import 'package:flutter_test/flutter_test.dart';

import 'package:semi_design_flutter/src/monaco/base/common/arraysFind.dart';
import 'package:semi_design_flutter/src/monaco/base/common/charCode.dart';
import 'package:semi_design_flutter/src/monaco/base/common/errors.dart';
import 'package:semi_design_flutter/src/monaco/base/common/uint.dart';
import 'package:semi_design_flutter/src/monaco/editor/common/core/2d/dimension.dart';
import 'package:semi_design_flutter/src/monaco/editor/common/core/2d/point.dart';
import 'package:semi_design_flutter/src/monaco/editor/common/core/2d/rect.dart';
import 'package:semi_design_flutter/src/monaco/editor/common/core/2d/size.dart';
import 'package:semi_design_flutter/src/monaco/editor/common/core/characterClassifier.dart';
import 'package:semi_design_flutter/src/monaco/editor/common/core/editOperation.dart';
import 'package:semi_design_flutter/src/monaco/editor/common/core/misc/eolCounter.dart';
import 'package:semi_design_flutter/src/monaco/editor/common/core/misc/rgba.dart';
import 'package:semi_design_flutter/src/monaco/editor/common/core/misc/textModelDefaults.dart';
import 'package:semi_design_flutter/src/monaco/editor/common/core/position.dart';
import 'package:semi_design_flutter/src/monaco/editor/common/core/range.dart';
import 'package:semi_design_flutter/src/monaco/editor/common/core/ranges/columnRange.dart';
import 'package:semi_design_flutter/src/monaco/editor/common/core/ranges/offsetRange.dart';
import 'package:semi_design_flutter/src/monaco/editor/common/core/ranges/rangeSingleLine.dart';
import 'package:semi_design_flutter/src/monaco/editor/common/core/selection.dart';

void main() {
  group('position.ts', () {
    test('with/delta/compare/lift', () {
      final p = Position(1, 1);
      expect(p.withPos(newLineNumber: 3).lineNumber, 3);
      expect(p.delta(deltaLineNumber: 1, deltaColumn: 2).lineNumber, 2);
      expect(p.delta(deltaLineNumber: -5).lineNumber, 1);
      expect(Position.equalsStatic(null, null), isTrue);
      expect(Position.isBeforeStatic(Position(1, 1), Position(1, 2)), isTrue);
      expect(Position.compare(Position(1, 1), Position(1, 2)) < 0, isTrue);
      expect(Position.isIPosition({'lineNumber': 1, 'column': 2}), isTrue);
      expect(p.toJSON()['column'], 1);
      expect(p.toString(), '(1,1)');
    });
  });

  group('2d/point + size + dimension + rect', () {
    test('point value semantics', () {
      expect(Point.equals(Point(1, 2), Point(1, 2)), isTrue);
      expect(Point(1, 2).add(Point(3, 4)).x, 4);
      expect(Point(5, -5).withThreshold(2).x, 3);
      expect(Point(5, -5).withThreshold(2).y, -3);
    });
    test('size value semantics', () {
      expect(Size2D(3, 4).transpose().width, 4);
      expect(Size2D(2, 3).scaleWidth(2).width, 4);
      expect(Size2D(2, 3).toDimension().height, 3);
      expect(Dimension(1, 2).width, 1);
    });
    test('rect operations', () {
      final r = Rect(0, 0, 10, 10);
      expect(r.containsPoint(Point(5, 5)), isTrue);
      expect(r.containsRect(Rect(1, 1, 9, 9)), isTrue);
      expect(r.withMargin(2).left, -2);
      // withMargin(vertical=1, horizontal=2): left=right=-2, top=bottom=-1
      expect(r.withMargin(1, 2).left, -2);
      expect(r.withMargin(1, 2).top, -1);
      expect(r.intersect(Rect(5, 5, 15, 15))!.left, 5);
      expect(r.intersect(Rect(20, 20, 30, 30)), isNull);
      expect(r.union(Rect(-5, -5, 5, 5)).left, -5);
      expect(Rect.hull([Rect(0, 0, 1, 1), Rect(5, 5, 6, 6)]).right, 6);
    });
  });

  group('range.ts + selection.ts + editOperation.ts', () {
    test('range normalization and predicates', () {
      final r = Range(5, 5, 1, 1);
      expect(r.startLineNumber, 1);
      expect(r.endLineNumber, 5);
      expect(Range.containsPositionStatic(Range(1, 1, 3, 5), Position(2, 2)), isTrue);
      expect(!Range.areIntersecting(Range(1, 1, 2, 1), Range(2, 2, 3, 1)), isTrue);
      expect(Range.areIntersectingOrTouching(Range(1, 1, 2, 1), Range(2, 1, 3, 1)), isTrue);
      expect(Range.intersectRangesStatic(Range(1, 1, 2, 1), Range(5, 1, 8, 1)), isNull);
      expect(Range.isIRange({'startLineNumber': 1, 'startColumn': 1, 'endLineNumber': 2, 'endColumn': 2}), isTrue);
    });
    test('selection direction', () {
      final sel = Selection(1, 1, 3, 5);
      expect(sel.getDirection(), SelectionDirection.LTR);
      expect(sel.toString(), '[1,1 -> 3,5]');
      expect(Selection(3, 5, 1, 1).getDirection(), SelectionDirection.RTL);
      expect(Selection.selectionsEqual(sel, Selection(1, 1, 3, 5)), isTrue);
      expect(Selection.fromRange(Range(1, 1, 3, 5), SelectionDirection.RTL).selectionStartLineNumber, 3);
    });
    test('edit operations', () {
      expect(EditOperation.insert(Position(1, 1), 'x').forceMoveMarkers, isTrue);
      expect(EditOperation.delete(Range(1, 1, 1, 2)).text, isNull);
      expect(EditOperation.replaceMove(Range(1, 1, 1, 2), 'y').forceMoveMarkers, isTrue);
    });
  });

  group('ranges/*', () {
    test('offsetRange', () {
      final r = OffsetRange(5, 10);
      expect(r.length, 5);
      expect(r.contains(9), isTrue);
      expect(r.contains(10), isFalse);
      expect(r.clipCyclic(10), 5);
      expect(r.clipCyclic(11), 6);
      expect(r.intersect(OffsetRange(8, 15))!.start, 8);
      expect(r.intersect(OffsetRange(20, 30)), isNull);
      expect(r.substring('0123456789'), '56789');
      expect(OffsetRange.tryCreate(10, 5), isNull);
      expect(() => OffsetRange(10, 5), throwsA(isA<BugIndicatingError>()));
    });
    test('offsetRangeSet merges', () {
      final set = OffsetRangeSet()
        ..addRange(OffsetRange(0, 5))
        ..addRange(OffsetRange(10, 15))
        ..addRange(OffsetRange(3, 12));
      expect(set.ranges.length, 1);
      expect(set.ranges.single.start, 0);
      expect(set.length, 15);
    });
    test('columnRange + rangeSingleLine', () {
      final cr = ColumnRange.fromOffsetRange(OffsetRange(4, 9));
      expect(cr.startColumn, 5);
      expect(cr.toRange(3).toString(), '[3,5 -> 3,10]');
      final rsl = RangeSingleLine.fromRange(Range(2, 3, 2, 7))!;
      expect(rsl.toRange().startColumn, 3);
      expect(RangeSingleLine.fromRange(Range(2, 3, 4, 7)), isNull);
    });
  });

  group('characterClassifier.ts', () {
    test('classifier + set', () {
      final cc = CharacterClassifier<int>(0);
      cc.set(65, 5);
      cc.set(1000, 7);
      expect(cc.get(65), 5);
      expect(cc.get(1000), 7);
      expect(cc.get(66), 0);
      cc.clear();
      expect(cc.get(65), 0);
      final cs = CharacterSet();
      cs.add(42);
      expect(cs.has(42), isTrue);
      cs.clear();
      expect(cs.has(42), isFalse);
    });
  });

  group('misc: rgba + eolCounter + defaults', () {
    test('rgba clamps', () {
      expect(RGBA8(-5, 300, 128, 255).r, 0);
      expect(RGBA8(-5, 300, 128, 255).g, 255);
      expect(RGBA8(1, 2, 3, 4).equals(RGBA8(1, 2, 3, 4)), isTrue);
    });
    test('eol counting', () {
      final lf = countEOL('a\nb');
      expect(lf.$1, 1);
      expect(lf.$4, StringEOL.LF);
      final crlf = countEOL('a\r\nb');
      expect(crlf.$4, StringEOL.CRLF);
      expect(countEOL('a\rb').$4, StringEOL.Invalid);
      expect(countEOL('abc').$2, 3);
    });
    test('model defaults', () {
      expect(EDITOR_MODEL_DEFAULTS['tabSize'], 4);
      expect((EDITOR_MODEL_DEFAULTS['bracketPairColorizationOptions'] as Map)['enabled'], isTrue);
    });
  });

  group('base/common: errors + uint + charCode + arraysFind', () {
    test('errors', () {
      expect(isSigPipeError({'code': 'EPIPE', 'syscall': 'write'}), isTrue);
      expect(getErrorCode({'code': 42}), '42');
      expect(isCancellationError(CancellationError()), isTrue);
      expect(getErrorMessage(null), 'Error');
      expect(ErrorNoTelemetry.isErrorNoTelemetry(ErrorNoTelemetry()), isTrue);
      final s = transformErrorForSerialization(BugIndicatingError('x')) as SerializedError;
      expect(s.$isError, isTrue);
      expect(s.message, 'x');
    });
    test('uint + charCode', () {
      expect(toUint8(-1), 0);
      expect(toUint8(300), 255);
      expect(Constants.MAX_UINT_32, 4294967295);
      expect(CharCode.Tab, 9);
      expect(CharCode.UTF8_BOM, 65279);
    });
    test('arraysFind', () {
      expect(findLast([1, 2, 3], (e, i) => e < 3), 2);
      expect(findFirstIdxMonotonousOrArrLen([1, 2, 3, 4], (e) => e >= 3), 2);
      expect(findLastIdxMonotonous([1, 2, 3, 4], (e) => e < 3), 1);
      expect(findFirstMax([1, 5, 3], (a, b) => a.compareTo(b)), 5);
      expect(mapFindFirst([1, 2, 3], (v) => v > 1 ? v * 10 : null), 20);
    });
  });
}
