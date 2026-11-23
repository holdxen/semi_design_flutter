// 1:1 port regression tests for batch 10:
//   base/common/ime.ts
//   platform/instantiation/common/descriptors.ts
//   base/browser/history.ts
//   editor/.../bracketPairsTree/beforeEditPositionMapper.ts
// Assertions mirror the semantics of the TypeScript originals.

import 'package:flutter_test/flutter_test.dart';

import 'package:semi_design_flutter/src/monaco/base/browser/history.dart' as hist;
import 'package:semi_design_flutter/src/monaco/base/common/event.dart' as event;
import 'package:semi_design_flutter/src/monaco/base/common/ime.dart' as ime;
import 'package:semi_design_flutter/src/monaco/base/common/lifecycle.dart' as lifecycle;
import 'package:semi_design_flutter/src/monaco/editor/common/model/bracketPairsTextModelPart/bracketPairsTree/beforeEditPositionMapper.dart' as mapper;
import 'package:semi_design_flutter/src/monaco/editor/common/model/bracketPairsTextModelPart/bracketPairsTree/length.dart' as len;
import 'package:semi_design_flutter/src/monaco/platform/instantiation/common/descriptors.dart' as desc;

void main() {
  group('ime', () {
    test('enabled defaults true, disable/enable fires change', () {
      expect(ime.IME.enabled, isTrue);
      int fires = 0;
      final lifecycle.IDisposable sub = ime.IME.onDidChange((dynamic l) {
        fires++;
      });
      expect(fires, 0);

      ime.IME.disable();
      expect(ime.IME.enabled, isFalse);
      expect(fires, 1);

      ime.IME.disable(); // idempotent fires again (source always fires)
      expect(fires, 2);

      ime.IME.enable();
      expect(ime.IME.enabled, isTrue);
      expect(fires, 3);
      sub.dispose();

      // restore global singleton for other tests
      ime.IME.enable();
    });

    test('IMEImpl fresh instance independent of singleton', () {
      final ime.IMEImpl impl = ime.IMEImpl();
      expect(impl.enabled, isTrue);
      impl.disable();
      expect(impl.enabled, isFalse);
      expect(ime.IME.enabled, isTrue);
    });
  });

  group('descriptors', () {
    test('SyncDescriptor defaults and fields', () {
      final desc.SyncDescriptor<int> d = desc.SyncDescriptor<int>(() => 42);
      expect(d.ctor, isA<Function>());
      expect(d.staticArguments, isEmpty);
      expect(d.supportsDelayedInstantiation, isFalse);
      expect((d.ctor as int Function())(), 42);
    });

    test('SyncDescriptor explicit staticArguments/delayed', () {
      final desc.SyncDescriptor<String> d = desc.SyncDescriptor<String>(
        (String a, String b) => a + b,
        <Object?>['a', 'b'],
        true,
      );
      expect(d.staticArguments, <Object?>['a', 'b']);
      expect(d.supportsDelayedInstantiation, isTrue);
      expect((d.ctor as String Function(String, String))('x', 'y'), 'xy');
    });
  });

  group('history', () {
    test('IHistoryNavigationWidget interface is implementable', () {
      final _FakeHistory widget = _FakeHistory();
      expect(widget, isA<hist.IHistoryNavigationWidget>());
      expect(widget.element, isA<Object>());
      widget.showPreviousValue();
      widget.showNextValue();
      expect(widget.previous, 1);
      expect(widget.next, 1);
      widget.onDidFocus((dynamic _) {});
      widget.onDidBlur((dynamic _) {});
    });
  });

  group('beforeEditPositionMapper', () {
    mapper.BeforeEditPositionMapper _mapper(
        List<List<int>> edits) {
      // each edit: [startLine, startCol, endLine, endCol, newTextLength]
      final List<mapper.TextEditInfo> infos = edits.map((List<int> e) {
        return mapper.TextEditInfo(len.toLength(e[0], e[1]),
            len.toLength(e[2], e[3]), e[4]);
      }).toList();
      return mapper.BeforeEditPositionMapper(infos);
    }

    int _col(len.Length length) => len.lengthToObj(length).columnCount;

    // Official test "Single-Line 1": '0123456789', replace [0,4)..[0,7)
    // with "xy" (newLength 2). Old-columns array from beforeEditPositionMapper.test.ts.
    test('single-line replace maps old offsets', () {
      final mapper.BeforeEditPositionMapper m =
          _mapper(<List<int>>[<int>[0, 4, 0, 7, 2]]);
      const List<int> expectedOldCols = <int>[0, 1, 2, 3, 4, 5, 7, 8, 9, 10];
      for (int col = 0; col < expectedOldCols.length; col++) {
        expect(_col(m.getOffsetBeforeChange(len.toLength(0, col))),
            expectedOldCols[col],
            reason: 'old column at new col $col');
      }
      // column distance until next change: 4 3 2 1 0 0 ∞ ∞ ∞ ∞
      // Use a fresh mapper: getDistanceToNextChange advances the edit pointer.
      final mapper.BeforeEditPositionMapper md =
          _mapper(<List<int>>[<int>[0, 4, 0, 7, 2]]);
      const List<int?> expectedDist = <int?>[4, 3, 2, 1, 0, 0, null, null, null, null];
      for (int col = 0; col < expectedDist.length; col++) {
        final len.Length? d = md.getDistanceToNextChange(len.toLength(0, col));
        if (expectedDist[col] == null) {
          expect(d, isNull, reason: 'distance at col $col');
        } else {
          expect(d, isNotNull, reason: 'distance at col $col is unexpectedly null');
          expect(_col(d!), expectedDist[col], reason: 'distance at col $col');
        }
      }
    });

    // Official test "Single-Line 2": replace [0,2)..[0,4) with "xxxx" (4),
    // insert "yy" (2) at [0,6). Old-columns array from official test.
    test('multiple edits sorted apply in order', () {
      final mapper.BeforeEditPositionMapper m = _mapper(<List<int>>[
        <int>[0, 2, 0, 4, 4],
        <int>[0, 6, 0, 6, 2],
      ]);
      const List<int> expectedOldCols = <int>[
        0, 1, 2, 3, 4, 5, 4, 5, 6, 7, 6, 7, 8, 9, 10
      ];
      for (int col = 0; col < expectedOldCols.length; col++) {
        expect(_col(m.getOffsetBeforeChange(len.toLength(0, col))),
            expectedOldCols[col],
            reason: 'old column at new col $col');
      }
    });

    test('no edits maps identity and null distance', () {
      final mapper.BeforeEditPositionMapper m = _mapper(<List<int>>[]);
      expect(_col(m.getOffsetBeforeChange(len.toLength(0, 5))), 5);
      expect(m.getDistanceToNextChange(len.toLength(0, 5)), isNull);
    });

    test('TextEditInfo.toString', () {
      final mapper.TextEditInfo info =
          mapper.TextEditInfo(len.toLength(0, 1), len.toLength(0, 3), 2);
      expect(info.toString(), contains('->'));
    });
  });
}

class _FakeHistory implements hist.IHistoryNavigationWidget {
  @override
  Object get element => Object();

  int previous = 0;
  int next = 0;

  @override
  void showPreviousValue() => previous++;

  @override
  void showNextValue() => next++;

  @override
  event.Event<void> get onDidFocus => (dynamic l, [dynamic a, dynamic d]) =>
      lifecycle.Disposable.none;

  @override
  event.Event<void> get onDidBlur => (dynamic l, [dynamic a, dynamic d]) =>
      lifecycle.Disposable.none;
}
