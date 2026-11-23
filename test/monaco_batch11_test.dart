// 1:1 port parity tests for batch 11:
//   editor/common/config/editorZoom.ts
//   editor/common/model/fixedArray.ts
//   editor/.../bracketPairsTree/combineTextEditInfos.ts
import 'package:flutter_test/flutter_test.dart';
import 'package:semi_design_flutter/src/monaco/editor/common/config/editorZoom.dart'
    as zoom;
import 'package:semi_design_flutter/src/monaco/editor/common/model/fixedArray.dart'
    as fa;
import 'package:semi_design_flutter/src/monaco/editor/common/model/bracketPairsTextModelPart/bracketPairsTree/beforeEditPositionMapper.dart'
    as mapper;
import 'package:semi_design_flutter/src/monaco/editor/common/model/bracketPairsTextModelPart/bracketPairsTree/combineTextEditInfos.dart'
    as comb;
import 'package:semi_design_flutter/src/monaco/editor/common/model/bracketPairsTextModelPart/bracketPairsTree/length.dart'
    as len;

mapper.TextEditInfo _edit(int sLine, int sCol, int eLine, int eCol,
        int newLine, int newCol) =>
    mapper.TextEditInfo(
      len.toLength(sLine, sCol),
      len.toLength(eLine, eCol),
      len.toLength(newLine, newCol),
    );

String _info(mapper.TextEditInfo e) =>
    '${e.startOffset}..${e.endOffset}=>${e.newLength}';

List<String> _infos(List<mapper.TextEditInfo> edits) =>
    edits.map(_info).toList();

void main() {
  group('editorZoom', () {
    test('default zoom level is 0', () {
      expect(zoom.EditorZoom.getZoomLevel(), 0);
    });

    test('clamps to [-5, 20]', () {
      zoom.EditorZoom.setZoomLevel(100);
      expect(zoom.EditorZoom.getZoomLevel(), 20);
      zoom.EditorZoom.setZoomLevel(-100);
      expect(zoom.EditorZoom.getZoomLevel(), -5);
      zoom.EditorZoom.setZoomLevel(7);
      expect(zoom.EditorZoom.getZoomLevel(), 7);
    });

    test('fires only on change', () {
      final List<int> seen = <int>[];
      zoom.EditorZoom.onDidChangeZoomLevel((dynamic v) => seen.add(v as int));
      zoom.EditorZoom.setZoomLevel(7); // unchanged -> no event
      zoom.EditorZoom.setZoomLevel(8); // changed -> one event
      expect(seen, <int>[8]);
      // restore
      zoom.EditorZoom.setZoomLevel(0);
    });
  });

  group('fixedArray', () {
    test('get out of range returns default', () {
      final fa.FixedArray<int> a = fa.FixedArray<int>(9);
      expect(a.get(0), 9);
      expect(a.get(100), 9);
    });

    test('set fills gaps with default', () {
      final fa.FixedArray<String> a = fa.FixedArray<String>('d');
      a.set(3, 'x');
      expect(a.get(0), 'd');
      expect(a.get(1), 'd');
      expect(a.get(2), 'd');
      expect(a.get(3), 'x');
    });

    test('delete removes a range', () {
      final fa.FixedArray<int> a = fa.FixedArray<int>(0);
      a.set(0, 1);
      a.set(1, 2);
      a.set(2, 3);
      a.delete(1, 1);
      expect(a.get(0), 1);
      expect(a.get(1), 3);
    });

    test('insert shifts with defaults', () {
      final fa.FixedArray<int> a = fa.FixedArray<int>(0);
      a.set(0, 1);
      a.insert(0, 2);
      expect(a.get(0), 0);
      expect(a.get(1), 0);
      expect(a.get(2), 1);
    });

    test('replace with oldLength zero inserts', () {
      final fa.FixedArray<int> a = fa.FixedArray<int>(0);
      a.set(0, 1);
      a.replace(0, 0, 2);
      expect(a.get(0), 0);
      expect(a.get(1), 0);
      expect(a.get(2), 1);
    });

    test('replace with newLength zero deletes', () {
      final fa.FixedArray<int> a = fa.FixedArray<int>(0);
      a.set(0, 1);
      a.set(1, 2);
      a.replace(0, 2, 0);
      expect(a.get(0), 0);
    });

    test('replace swaps range with defaults', () {
      final fa.FixedArray<int> a = fa.FixedArray<int>(0);
      a.set(0, 1);
      a.set(1, 2);
      a.set(2, 3);
      a.replace(1, 1, 2); // replace [2] with two defaults
      expect(a.get(0), 1);
      expect(a.get(1), 0);
      expect(a.get(2), 0);
      expect(a.get(3), 3);
    });
  });

  group('combineTextEditInfos', () {
    test('empty first returns second', () {
      final List<mapper.TextEditInfo> second = <mapper.TextEditInfo>[
        _edit(0, 0, 0, 2, 0, 1)
      ];
      expect(comb.combineTextEditInfos(<mapper.TextEditInfo>[], second),
          same(second));
    });

    test('empty second returns first', () {
      final List<mapper.TextEditInfo> first = <mapper.TextEditInfo>[
        _edit(0, 0, 0, 2, 0, 1)
      ];
      expect(comb.combineTextEditInfos(first, <mapper.TextEditInfo>[]),
          same(first));
    });

    test('single non-overlapping edits combine and merge on touch', () {
      // s0: "abcde" (single line). First: replace [0,1) with 1 char (identity
      // length). Second: replace [3,4) with 2 chars. Combined should be single
      // edit [3,4) => col 2, as the first edit is length-preserving.
      final List<mapper.TextEditInfo> first = <mapper.TextEditInfo>[
        _edit(0, 0, 0, 1, 0, 1),
      ];
      final List<mapper.TextEditInfo> second = <mapper.TextEditInfo>[
        _edit(0, 3, 0, 4, 0, 2),
      ];
      final List<String> got = _infos(
          comb.combineTextEditInfos(first, second));
      expect(got, <String>['0..1=>1', '3..4=>2']);
    });

    test('two edits in second map stay separate when disjoint', () {
      final List<mapper.TextEditInfo> first = <mapper.TextEditInfo>[
        _edit(0, 0, 0, 1, 0, 1),
      ];
      final List<mapper.TextEditInfo> second = <mapper.TextEditInfo>[
        _edit(0, 1, 0, 2, 0, 3),
        _edit(0, 3, 0, 4, 0, 5),
      ];
      final List<String> got = _infos(
          comb.combineTextEditInfos(first, second));
      expect(got, <String>['0..2=>4', '3..4=>5']);
    });

    test('identity first edit then insert at start', () {
      // First edit: delete one column [1,2) => 0. Second edit: at the new
      // position insert 2 columns at [1,1).
      final List<mapper.TextEditInfo> first = <mapper.TextEditInfo>[
        _edit(0, 1, 0, 2, 0, 0),
      ];
      final List<mapper.TextEditInfo> second = <mapper.TextEditInfo>[
        _edit(0, 1, 0, 1, 0, 2),
      ];
      final List<String> got = _infos(
          comb.combineTextEditInfos(first, second));
      // Net: s0 [1,2) replaced with 2 columns.
      expect(got, <String>['1..2=>2']);
    });

    test('toLengthMapping builds unmodified gaps and modified edits', () {
      final List<comb.LengthMapping> mappings = comb.toLengthMapping(
          <mapper.TextEditInfo>[_edit(0, 1, 0, 3, 0, 2)]);
      // gap [0,1) unmodified, then modified [1,3)=>2
      expect(mappings.length, 2);
      expect(mappings[0].modified, isFalse);
      expect(mappings[0].lengthBefore, len.toLength(0, 1));
      expect(mappings[1].modified, isTrue);
      expect(mappings[1].lengthAfter, len.toLength(0, 2));
    });

    test('LengthMapping.splitAt on unmodified splits both sides', () {
      final comb.LengthMapping m = comb.LengthMapping(false, 10, 10);
      final (comb.LengthMapping a, comb.LengthMapping? b) = m.splitAt(4);
      expect(a.lengthBefore, 4);
      expect(a.lengthAfter, 4);
      expect(b, isNotNull);
      expect(b!.lengthBefore, 6);
      expect(b.lengthAfter, 6);
    });

    test('LengthMapping.splitAt at end returns self and null', () {
      final comb.LengthMapping m = comb.LengthMapping(true, 5, 2);
      final (comb.LengthMapping a, comb.LengthMapping? b) = m.splitAt(2);
      expect(identical(a, m), isTrue);
      expect(b, isNull);
    });
  });
}
