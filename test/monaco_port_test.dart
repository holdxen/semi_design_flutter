// Regression tests for the 1:1 Monaco port (see docs/monaco_editor_1to1_移植计划.md).
// Each group targets a translated source file; assertions mirror the semantics
// of the TypeScript original. Extend as more files are translated.

import 'dart:math' as math;

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
import 'package:semi_design_flutter/src/monaco/editor/common/core/edits/edit.dart' as ed;
import 'package:semi_design_flutter/src/monaco/editor/common/core/misc/eolCounter.dart';
import 'package:semi_design_flutter/src/monaco/editor/common/core/misc/indentation.dart' as indentation;
import 'package:semi_design_flutter/src/monaco/editor/common/core/misc/rgba.dart';
import 'package:semi_design_flutter/src/monaco/editor/common/core/misc/textModelDefaults.dart';
import 'package:semi_design_flutter/src/monaco/editor/common/core/position.dart';
import 'package:semi_design_flutter/src/monaco/editor/common/core/range.dart';
import 'package:semi_design_flutter/src/monaco/editor/common/core/ranges/columnRange.dart';
import 'package:semi_design_flutter/src/monaco/editor/common/core/ranges/offsetRange.dart';
import 'package:semi_design_flutter/src/monaco/editor/common/core/ranges/rangeMapping.dart' as rm;
import 'package:semi_design_flutter/src/monaco/editor/common/core/ranges/rangeSingleLine.dart';
import 'package:semi_design_flutter/src/monaco/editor/common/core/selection.dart';
import 'package:semi_design_flutter/src/monaco/editor/common/encodedTokenAttributes.dart' as eta;
import 'package:semi_design_flutter/src/monaco/editor/common/model/prefixSumComputer.dart' as psc;
import 'package:semi_design_flutter/src/monaco/editor/common/core/ranges/lineRange.dart' as lr;
import 'package:semi_design_flutter/src/monaco/editor/common/core/wordCharacterClassifier.dart' as wcc;
import 'package:semi_design_flutter/src/monaco/platform/keybinding/common/baseResolvedKeybinding.dart' as brk;
import 'package:semi_design_flutter/src/monaco/base/common/keybindings.dart' as kb;
import 'package:semi_design_flutter/src/monaco/base/common/keyCodes.dart' as kc;
import 'package:semi_design_flutter/src/monaco/base/common/platform.dart' as pf;

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

  group('wordCharacterClassifier.ts (1:1)', () {
    test('classifies separators and whitespace', () {
      final wcc.WordCharacterClassifier w =
          wcc.WordCharacterClassifier('.,', <String>[]);
      expect(w.get('a'.codeUnitAt(0)), wcc.WordCharacterClass.Regular);
      expect(w.get(CharCode.Space), wcc.WordCharacterClass.Whitespace);
      expect(w.get(CharCode.Tab), wcc.WordCharacterClass.Whitespace);
      expect(w.get('.'.codeUnitAt(0)), wcc.WordCharacterClass.WordSeparator);
      expect(w.get(','.codeUnitAt(0)), wcc.WordCharacterClass.WordSeparator);
    });

    test('Intl segmenter carrier: find words before/after offset', () {
      final wcc.WordCharacterClassifier w =
          wcc.WordCharacterClassifier('', <String>['en']);
      expect(w.intlSegmenterLocales, <String>['en']);
      expect(
          w.findNextIntlWordAtOrAfterOffset('hello world', 6)?.segment, 'world');
      expect(
          w.findPrevIntlWordBeforeOrAtOffset('hello world', 6)?.segment, 'world');
      expect(
          w.findPrevIntlWordBeforeOrAtOffset('hello world', 5)?.segment, 'hello');
      expect(w.findNextIntlWordAtOrAfterOffset('hello world', 100), isNull);

      final wcc.WordCharacterClassifier noIntl =
          wcc.WordCharacterClassifier('', <String>[]);
      expect(noIntl.findNextIntlWordAtOrAfterOffset('hello', 0), isNull);
    });

    test('getMapForWordSeparators caches by key', () {
      final wcc.WordCharacterClassifier a =
          wcc.getMapForWordSeparators('.,', <String>[]);
      final wcc.WordCharacterClassifier b =
          wcc.getMapForWordSeparators('.,', <String>[]);
      final wcc.WordCharacterClassifier c =
          wcc.getMapForWordSeparators(':;', <String>[]);
      expect(identical(a, b), isTrue);
      expect(identical(a, c), isFalse);
    });
  });

  group('baseResolvedKeybinding.ts (1:1)', () {
    test('labels, chords, WYSIWYG', () {
      final _TestKeybinding k = _TestKeybinding(pf.OperatingSystem.Windows, <
          kb.KeyCodeChord>[
        kb.KeyCodeChord(true, false, false, false, kc.KeyCode.KeyA),
      ]);
      expect(k.getLabel(), contains('K${kc.KeyCode.KeyA}'));
      expect(k.getAriaLabel(), contains('A${kc.KeyCode.KeyA}'));
      expect(k.getUserSettingsLabel(), contains('U${kc.KeyCode.KeyA}'));
      expect(k.getElectronAccelerator(), contains('E${kc.KeyCode.KeyA}'));
      expect(k.hasMultipleChords(), isFalse);
      expect(k.isWYSIWYG(), isTrue);
      final List<kb.ResolvedChord> chords = k.getChords();
      expect(chords.length, 1);
      expect(chords.single.ctrlKey, isTrue);
      expect(chords.single.keyLabel, 'K${kc.KeyCode.KeyA}');
      expect(k.getDispatchChords(), <String?>['D${kc.KeyCode.KeyA}']);
      expect(k.getSingleModifierDispatchChords(), <String?>[null]);
    });

    test('chords and duplicate modifier cases have no electron accelerator',
        () {
      final _TestKeybinding multi = _TestKeybinding(
          pf.OperatingSystem.Windows, <kb.KeyCodeChord>[
        kb.KeyCodeChord(false, false, false, false, kc.KeyCode.KeyA),
        kb.KeyCodeChord(false, false, false, false, kc.KeyCode.KeyB),
      ]);
      expect(multi.hasMultipleChords(), isTrue);
      expect(multi.getElectronAccelerator(), isNull);

      final _TestKeybinding modifier = _TestKeybinding(
          pf.OperatingSystem.Windows, <kb.KeyCodeChord>[
        kb.KeyCodeChord(true, false, false, false, kc.KeyCode.Ctrl),
      ]);
      expect(modifier.getElectronAccelerator(), isNull);
      expect(
          () => _TestKeybinding(pf.OperatingSystem.Windows, <kb.KeyCodeChord>[]),
          throwsA(isA<Error>()));
    });
  });

  group('prefixSumComputer.ts (1:1)', () {
    // Mirrors prefixSumComputer.test.ts; both implementations must agree.
    void forBoth(List<int> values,
        void Function(int total, int Function(int count) prefix,
            psc.PrefixSumIndexOfResult Function(int sum) index) cb) {
      final a = psc.PrefixSumComputer(values);
      final b = psc.ConstantTimePrefixSumComputer(values);
      for (final impl in <int>[0, 1]) {
        if (impl == 0) {
          cb(a.getTotalSum(), (int count) => count == 0 ? 0 : a.getPrefixSum(count - 1),
              (int sum) => a.getIndexOf(sum));
        } else {
          cb(b.getTotalSum(), (int count) => b.getPrefixSum(count),
              (int sum) => b.getIndexOf(sum));
        }
      }
    }

    test('typical values: total, prefix sums, indexes', () {
      forBoth(<int>[1, 1, 2, 1, 3], (total, prefix, index) {
        expect(total, 8);
        expect(<int>[
          prefix(0), prefix(1), prefix(2), prefix(3), prefix(4), prefix(5)
        ], <int>[0, 1, 2, 4, 5, 8]);
        expect(index(0), const psc.PrefixSumIndexOfResult(0, 0));
        expect(index(1), const psc.PrefixSumIndexOfResult(1, 0));
        expect(index(2), const psc.PrefixSumIndexOfResult(2, 0));
        expect(index(3), const psc.PrefixSumIndexOfResult(2, 1));
        expect(index(4), const psc.PrefixSumIndexOfResult(3, 0));
        expect(index(8), const psc.PrefixSumIndexOfResult(4, 3));
      });
    });

    test('all zeroes / empty / single element', () {
      forBoth(<int>[0, 0, 0], (total, prefix, index) {
        expect(total, 0);
        expect(index(0), const psc.PrefixSumIndexOfResult(2, 0));
      });
      forBoth(<int>[], (total, prefix, index) {
        expect(total, 0);
        expect(prefix(0), 0);
      });
      forBoth(<int>[5], (total, prefix, index) {
        expect(total, 5);
        expect(index(0), const psc.PrefixSumIndexOfResult(0, 0));
        expect(index(4), const psc.PrefixSumIndexOfResult(0, 4));
      });
    });

    test('setValue increase/decrease/to-zero/from-zero', () {
      forBoth(<int>[1, 2, 3], (total, prefix, index) {
        // mutate through fresh impls below
      });
      final a = psc.PrefixSumComputer(<int>[1, 2, 3]);
      final b = psc.ConstantTimePrefixSumComputer(<int>[1, 2, 3]);
      for (final impl in <Object>[a, b]) {
        if (impl is psc.PrefixSumComputer) {
          impl.setValue(1, 5);
          expect(impl.getTotalSum(), 9);
          expect(impl.getIndexOf(5), const psc.PrefixSumIndexOfResult(1, 4));
        } else if (impl is psc.ConstantTimePrefixSumComputer) {
          impl.setValue(1, 5);
          expect(impl.getTotalSum(), 9);
          expect(impl.getIndexOf(5), const psc.PrefixSumIndexOfResult(1, 4));
        }
      }
      b.setValue(1, 0);
      expect(b.getTotalSum(), 4);
      expect(b.getIndexOf(1), const psc.PrefixSumIndexOfResult(2, 0));
      b.setValue(0, 0);
      b.setValue(2, 0);
      expect(b.getTotalSum(), 0);
      b.setValue(0, 4);
      expect(b.getIndexOf(3), const psc.PrefixSumIndexOfResult(0, 3));
    });

    test('insertValues and removeValues across both impls', () {
      final a = psc.PrefixSumComputer(<int>[1, 1, 1]);
      final b = psc.ConstantTimePrefixSumComputer(<int>[1, 1, 1]);
      for (final impl in <Object>[a, b]) {
        if (impl is psc.PrefixSumComputer) {
          impl.setValue(0, 5);
          impl.insertValues(1, <int>[10]);
          impl.removeValues(3, 1);
          expect(impl.getTotalSum(), 16);
          expect(impl.getIndexOf(4), const psc.PrefixSumIndexOfResult(0, 4));
        } else if (impl is psc.ConstantTimePrefixSumComputer) {
          impl.setValue(0, 5);
          impl.insertValues(1, <int>[10]);
          impl.removeValues(3, 1);
          expect(impl.getTotalSum(), 16);
          expect(impl.getIndexOf(4), const psc.PrefixSumIndexOfResult(0, 4));
        }
      }
      // empty -> insert
      final e = psc.ConstantTimePrefixSumComputer(<int>[]);
      e.insertValues(0, <int>[5, 3]);
      expect(e.getTotalSum(), 8);
      expect(e.getIndexOf(5), const psc.PrefixSumIndexOfResult(1, 0));
    });
  });

  group('lineRange.ts (1:1)', () {
    test('LineRange basics, contains, intersects, distance', () {
      final r = lr.LineRange(3, 8);
      expect(r.length, 5);
      expect(r.isEmpty, isFalse);
      expect(r.contains(3), isTrue);
      expect(r.contains(8), isFalse);
      expect(r.containsRange(lr.LineRange(4, 7)), isTrue);
      expect(r.delta(2).equals(lr.LineRange(5, 10)), isTrue);
      expect(r.deltaLength(-1).equals(lr.LineRange(3, 7)), isTrue);
      expect(r.addMargin(1, 2).equals(lr.LineRange(2, 10)), isTrue);
      expect(r.toString(), '[3,8)');
      expect(r.intersect(lr.LineRange(6, 12))?.equals(lr.LineRange(6, 8)), isTrue);
      expect(r.intersect(lr.LineRange(9, 12)), isNull);
      expect(r.intersectsStrict(lr.LineRange(8, 10)), isFalse);
      expect(r.intersectsOrTouches(lr.LineRange(8, 10)), isTrue);
      expect(r.distanceToRange(lr.LineRange(10, 12)), 2);
      expect(r.distanceToLine(1), 2);
      expect(r.distanceToLine(5), 0);
      expect(r.distanceToLine(11), 3);
      expect(r.toInclusiveRange(), isNotNull);
      expect(lr.LineRange.ofLength(3, 5).equals(r), isTrue);
      expect(lr.LineRange.fromRange(Range(3, 1, 7, 9)).equals(lr.LineRange(3, 7)), isTrue);
      expect(lr.LineRange.fromRangeInclusive(Range(3, 1, 7, 9)).equals(r), isTrue);
      expect(r.serialize(), (startLineNumber: 3, endLineNumberExclusive: 8));
      expect(lr.LineRange.deserialize(r.serialize()).equals(r), isTrue);
      expect(r.mapToLineArray<int>((int n) => n), <int>[3, 4, 5, 6, 7]);
      expect(r.toOffsetRange().start, 2);
    });

    test('LineRange.subtract covers all four branches', () {
      final a = lr.LineRange(1, 10);
      // b fully inside -> two pieces
      expect(lr.LineRange.subtract(a, lr.LineRange(4, 6)).map((x) => x.toString()).toList(),
          <String>['[1,4)', '[6,10)']);
      // b covers a -> empty
      expect(lr.LineRange.subtract(a, lr.LineRange(0, 12)), isEmpty);
      // b overlaps right
      expect(lr.LineRange.subtract(a, lr.LineRange(8, 12)).map((x) => x.toString()).toList(), <String>['[1,8)']);
      // b overlaps left
      expect(lr.LineRange.subtract(a, lr.LineRange(0, 4)).map((x) => x.toString()).toList(), <String>['[4,10)']);
      expect(lr.LineRange.subtract(a, null).map((x) => x.toString()).toList(), <String>['[1,10)']);
      expect(lr.LineRange.joinStatic(<lr.LineRange>[
        lr.LineRange(1, 3),
        lr.LineRange(5, 9)
      ]).equals(lr.LineRange(1, 9)), isTrue);
      expect(() => lr.LineRange.joinStatic(<lr.LineRange>[]), throwsA(isA<BugIndicatingError>()));
    });

    test('LineRangeSet add/union/subtract/intersection', () {
      final set = lr.LineRangeSet();
      set.addRange(lr.LineRange(1, 3));
      set.addRange(lr.LineRange(5, 8));
      set.addRange(lr.LineRange(3, 5)); // touches both -> merges all
      expect(set.ranges.length, 1);
      expect(set.ranges.single.equals(lr.LineRange(1, 8)), isTrue);
      expect(set.contains(1), isTrue);
      expect(set.contains(8), isFalse);
      expect(set.intersects(lr.LineRange(7, 10)), isTrue);
      expect(set.toString(), '[1,8)');

      final other = lr.LineRangeSet(<lr.LineRange>[lr.LineRange(4, 12)]);
      expect(set.getUnion(other).ranges.single.equals(lr.LineRange(1, 12)), isTrue);
      expect(set.getIntersection(other).ranges.single.equals(lr.LineRange(4, 8)), isTrue);
      expect(set.subtractFrom(lr.LineRange(2, 6)).ranges
          .map((x) => x.toString()).toList(), isEmpty);
      expect(set.getWithDelta(2).ranges.single.equals(lr.LineRange(3, 10)), isTrue);
    });
  });

  group('encodedTokenAttributes.ts', () {
    int enc(int lang, int ttype, bool bal, int font, int fg, int bg) =>
        (lang) | (ttype << 8) | ((bal ? 1 : 0) << 10) |
        (font << 11) | (fg << 15) | (bg << 24);

    test('metadata masks decode each field', () {
      final cases = <List<Object>>[
        <Object>[1, 0, false, 0, 1, 0],
        <Object>[2, 2, true, 15, 7, 3],
        <Object>[0, 3, false, 5, 0, 255],
        <Object>[255, 1, true, 1, 511, 128],
      ];
      for (final c in cases) {
        final int m = enc(c[0] as int, c[1] as int, c[2] as bool,
            c[3] as int, c[4] as int, c[5] as int);
        expect(eta.TokenMetadata.getLanguageId(m), c[0]);
        expect(eta.TokenMetadata.getTokenType(m), c[1]);
        expect(eta.TokenMetadata.containsBalancedBrackets(m), c[2]);
        expect(eta.TokenMetadata.getFontStyle(m), c[3]);
        expect(eta.TokenMetadata.getForeground(m), c[4]);
        expect(eta.TokenMetadata.getBackground(m), c[5]);
      }
    });

    test('className / inlineStyle / presentation', () {
      // fontStyle = Italic|Bold|Underline|Strikethrough = 15, fg = 3
      final int m = enc(1, 0, false, 15, 3, 0);
      expect(eta.TokenMetadata.getClassNameFromMetadata(m), 'mtk3 mtki mtkb mtku mtks');
      final colorMap = List<String>.generate(512, (i) => 'c$i');
      final String style = eta.TokenMetadata.getInlineStyleFromMetadata(m, colorMap);
      expect(style, contains('color: c3;'));
      expect(style, contains('font-style: italic;'));
      expect(style, contains('font-weight: bold;'));
      expect(style, contains('text-decoration: underline line-through;'));
      final pres = eta.TokenMetadata.getPresentationFromMetadata(m);
      expect(pres.foreground, 3);
      expect(pres.italic, true);
      expect(pres.bold, true);
      expect(pres.underline, true);
      expect(pres.strikethrough, true);
    });
  });

  group('indentation.ts (1:1)', () {
    test('normalizeIndentation with tabs (source case 1)', () {
      String norm(String s) => indentation.normalizeIndentation(s, 4, false);
      expect(norm('\t'), '\t');
      expect(norm('    '), '\t');
      expect(norm('   '), '   ');
      expect(norm('  '), '  ');
      expect(norm(' '), ' ');
      expect(norm(''), '');
      expect(norm(' \t    '), '\t\t');
      expect(norm(' \t   '), '\t   ');
      expect(norm(' \t  '), '\t  ');
      expect(norm(' \t '), '\t ');
      expect(norm(' \t'), '\t');
      expect(norm('\ta'), '\ta');
      expect(norm('    a'), '\ta');
      expect(norm('   a'), '   a');
      expect(norm('  a'), '  a');
      expect(norm(' a'), ' a');
      expect(norm('a'), 'a');
      expect(norm(' \t    a'), '\t\ta');
      expect(norm(' \t   a'), '\t   a');
      expect(norm(' \t  a'), '\t  a');
      expect(norm(' \t a'), '\t a');
      expect(norm(' \ta'), '\ta');
    });

    test('normalizeIndentation with spaces (source case 2)', () {
      String norm(String s) => indentation.normalizeIndentation(s, 4, true);
      expect(norm('\ta'), '    a');
      expect(norm('    a'), '    a');
      expect(norm('   a'), '   a');
      expect(norm('  a'), '  a');
      expect(norm(' a'), ' a');
      expect(norm('a'), 'a');
      expect(norm(' \t    a'), '        a');
      expect(norm(' \t   a'), '       a');
      expect(norm(' \t  a'), '      a');
      expect(norm(' \t a'), '     a');
      expect(norm(' \ta'), '    a');
    });
  });

  group('edits/edit.ts (1:1)', () {
    // A minimal concrete replacement: replaces `replaceRange` with `text`.
    // Mirrors how StringReplacement/TextRepletion specialize BaseReplacement.
    String _apply(String s, ed.Edit<_R> edit) {
      final List<_R> reps = edit.replacements;
      // Apply from the end so offsets stay valid.
      for (int i = reps.length - 1; i >= 0; i--) {
        final _R r = reps[i];
        s = s.substring(0, r.replaceRange.start) + r.text + s.substring(r.replaceRange.endExclusive);
      }
      return s;
    }

    ed.Edit<_R> _edit(List<_R> reps) => ed.Edit<_R>(reps);

    test('normalize removes no-ops and joins touching replacements', () {
      // [1,1)->'x' and [1,2)->'y' touch -> joined to [1,2)->'xy'
      final e = _edit(<_R>[
        _R(OffsetRange(0, 0), ''), // no-op
        _R(OffsetRange(1, 1), 'x'),
        _R(OffsetRange(1, 2), 'y'),
      ]);
      final norm = e.normalize();
      expect(norm.replacements.length, 1);
      expect(norm.replacements.first.replaceRange.start, 1);
      expect(norm.replacements.first.replaceRange.endExclusive, 2);
      expect(norm.replacements.first.text, 'xy');
    });

    test('equals is structural', () {
      final a = _edit(<_R>[_R(OffsetRange(1, 2), 'x')]);
      final b = _edit(<_R>[_R(OffsetRange(1, 2), 'x')]);
      final c = _edit(<_R>[_R(OffsetRange(1, 2), 'y')]);
      expect(a.equals(b), isTrue);
      expect(a.equals(c), isFalse);
    });

    test('apply + getLengthDelta + getNewRanges', () {
      final e = _edit(<_R>[
        _R(OffsetRange(1, 3), 'XY'), // delta 0
        _R(OffsetRange(5, 5), 'ZZ'), // insert, delta +2
      ]);
      expect(_apply('abcdef', e), 'aXYdeZZf');
      expect(e.getLengthDelta(), 2);
      expect(e.getNewDataLength(6), 8);
      final ranges = e.getNewRanges();
      expect(ranges[0].start, 1);
      expect(ranges[0].length, 2);
      expect(ranges[1].start, 5); // 5 + delta 0 (first replacement is length-neutral)
      expect(ranges[1].length, 2);
    });

    test('applyToOffset / applyInverseToOffset / applyToOffsetOrUndefined', () {
      final e = _edit(<_R>[_R(OffsetRange(2, 4), 'XY')]); // delta 0
      expect(e.applyToOffset(0), 0);
      expect(e.applyToOffset(2), 2); // inside replaced range -> start
      expect(e.applyToOffset(3), 2);
      expect(e.applyToOffset(10), 10);
      expect(e.applyToOffsetOrUndefined(3), isNull); // inside -> undefined
      expect(e.applyToOffsetOrUndefined(1), 1);

      final ins = _edit(<_R>[_R(OffsetRange(2, 2), 'ZZ')]); // +2
      expect(ins.applyToOffset(2), 4); // offset == insert start maps after inserted text
      expect(ins.applyToOffset(3), 5);
      expect(ins.applyInverseToOffset(4), 2);
      expect(ins.applyInverseToOffset(5), 3);
    });

    test('compose invariant: other.apply(this.apply(s0)) == this.compose(other).apply(s0)', () {
      // e1: [1,3)->'A', e2 (on s1): [0,1)->'B'
      final e1 = _edit(<_R>[_R(OffsetRange(1, 3), 'A')]);
      final s1 = _apply('abcdef', e1); // aAdef
      final e2 = _edit(<_R>[_R(OffsetRange(0, 1), 'B')]);
      final expected = _apply(s1, e2); // BaAdef
      final composed = e1.compose(e2);
      expect(_apply('abcdef', composed), expected);
    });

    test('compose fuzz (fixed seed, 100 cases)', () {
      final rand = math.Random(42);
      for (int i = 0; i < 100; i++) {
        final String s0 = List<String>.generate(12, (_) => String.fromCharCode(97 + rand.nextInt(6))).join();
        final ed.Edit<_R> e1 = _randomEdit(s0, rand);
        final String s1 = _apply(s0, e1);
        final ed.Edit<_R> e2 = _randomEdit(s1, rand);
        final String expected = _apply(s1, e2);
        final ed.Edit<_R> composed = e1.compose(e2);
        final String actual = _apply(s0, composed);
        expect(actual, expected, reason: 'compose fuzz case $i: s0=$s0 e1=$e1 e2=$e2 composed=$composed');
      }
    });

    test('decomposeSplit partitions replacements', () {
      final e = _edit(<_R>[
        _R(OffsetRange(0, 1), 'a'),
        _R(OffsetRange(2, 3), 'b'),
        _R(OffsetRange(4, 5), 'c'),
      ]);
      final parts = e.decomposeSplit((r) => r.text == 'b');
      expect(parts.e1.replacements.length, 1);
      expect(parts.e2.replacements.length, 2);
    });

    test('AnnotationReplacement join + slice', () {
      final a = ed.AnnotationReplacement<String>(OffsetRange(1, 2), 3, 'note');
      final b = ed.AnnotationReplacement<String>(OffsetRange(2, 4), 2, 'note');
      final joined = a.tryJoinTouching(b);
      expect(joined, isNotNull);
      expect(joined!.replaceRange.start, 1);
      expect(joined.replaceRange.endExclusive, 4);
      expect(joined.newLength, 5);
      expect(a.tryJoinTouching(ed.AnnotationReplacement<String>(OffsetRange(2, 4), 2, 'other')), isNull);
      expect(a.equals(ed.AnnotationReplacement<String>(OffsetRange(1, 2), 3, 'note')), isTrue);
    });
  });

  group('ranges/rangeMapping.ts (1:1)', () {
    // Single mapping: original [2:4..2:6) -> modified [2:4..2:7) (net +1 col on same line).
    final mapping = rm.SingleRangeMapping(Range(2, 4, 2, 6), Range(2, 4, 2, 7));
    final rangeMapping = rm.RangeMapping(<rm.SingleRangeMapping>[mapping]);

    test('mapPosition before all mappings -> identity', () {
      final res = rangeMapping.mapPosition(Position(1, 1));
      expect(res.range, isNull);
      expect(res.position!.lineNumber, 1);
      expect(res.position!.column, 1);
    });

    test('mapPosition inside original -> modified range', () {
      final res = rangeMapping.mapPosition(Position(2, 5));
      expect(res.position, isNull);
      expect(res.range!.toString(), '[2,4 -> 2,7]');
    });

    test('mapPosition after original -> shifted by text length delta', () {
      // position 2:8 is 2 columns past original end (2:6); modified end is 2:7.
      final res = rangeMapping.mapPosition(Position(2, 8));
      expect(res.range, isNull);
      expect(res.position!.lineNumber, 2);
      expect(res.position!.column, 9); // 7 + (8 - 6) = 9
    });

    test('mapRange + reverse', () {
      final mapped = rangeMapping.mapRange(Range(2, 5, 2, 8));
      expect(mapped.startLineNumber, 2);
      expect(mapped.startColumn, 4); // start inside -> range start
      expect(mapped.endColumn, 9); // end after -> shifted
      final rev = rangeMapping.reverse();
      expect(rev.mappings.single.original.toString(), '[2,4 -> 2,7]');
      expect(rev.mappings.single.modified.toString(), '[2,4 -> 2,6]');
      expect(mapping.toString(), '[2,4 -> 2,6] -> [2,4 -> 2,7]');
    });
  });
}

// Test helper: a concrete BaseReplacement that stores replacement text.
class _R extends ed.BaseReplacement<_R> {
  final String text;
  _R(OffsetRange range, this.text) : super(range);

  @override
  int getNewLength() => text.length;

  @override
  _R? tryJoinTouching(_R other) {
    final joined = replaceRange.joinRightTouching(other.replaceRange);
    return _R(joined, text + other.text);
  }

  @override
  _R slice(OffsetRange newReplaceRange, [OffsetRange? rangeInReplacement]) {
    final r = rangeInReplacement ?? OffsetRange(0, getNewLength());
    return _R(newReplaceRange, text.substring(r.start, r.endExclusive));
  }

  @override
  bool equals(_R other) => replaceRange.equals(other.replaceRange) && text == other.text;

  @override
  String toString() => '[$replaceRange->$text]';
}

ed.Edit<_R> _randomEdit(String s, math.Random rand) {
  final List<_R> reps = <_R>[];
  int pos = 0;
  while (pos <= s.length) {
    final int start = pos + rand.nextInt(s.length - pos + 1);
    final int end = start + rand.nextInt(s.length - start + 1);
    final String text = String.fromCharCode(65 + rand.nextInt(6)); // 'A'..'F'
    reps.add(_R(OffsetRange(start, end), text));
    if (end >= s.length) {
      break;
    }
    pos = end + rand.nextInt(s.length - end + 1);
  }
  return ed.Edit<_R>(reps);
}


class _TestKeybinding extends brk.BaseResolvedKeybinding<kb.KeyCodeChord> {
  _TestKeybinding(int os, List<kb.KeyCodeChord> chords) : super(os, chords);

  @override
  String? getLabelFor(kb.KeyCodeChord keybinding) => 'K${keybinding.keyCode}';

  @override
  String? getAriaLabelFor(kb.KeyCodeChord keybinding) => 'A${keybinding.keyCode}';

  @override
  String? getElectronAcceleratorFor(kb.KeyCodeChord keybinding) =>
      'E${keybinding.keyCode}';

  @override
  String? getUserSettingsLabelFor(kb.KeyCodeChord keybinding) =>
      'U${keybinding.keyCode}';

  @override
  bool isWYSIWYGFor(kb.KeyCodeChord keybinding) => true;

  @override
  String? getChordDispatch(kb.KeyCodeChord keybinding) =>
      'D${keybinding.keyCode}';

  @override
  String? getSingleModifierChordDispatch(kb.KeyCodeChord keybinding) => null;
}
