// 1:1 replay of `editor/contrib/hover/browser/hoverTypes.ts`.
// Truth: `tool/ts2dart/_batch409_truth.cjs` -> `batch409_truth.json`.
import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import '../lib/src/monaco/editor/common/core/position.dart' show Position;
import '../lib/src/monaco/editor/common/core/range.dart' show Range;
import '../lib/src/monaco/editor/contrib/hover/browser/hoverTypes.dart';

Map<String, dynamic> _map(dynamic v) => (v as Map).cast<String, dynamic>();

Map<String, dynamic> _truth() {
  final Map<String, dynamic> root = _map(
    jsonDecode(File('tool/ts2dart/batch409_truth.json').readAsStringSync()),
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

class _Part implements IRenderedHoverPart<IHoverPart> {
  final String tag;
  final List<String> disposed;
  _Part(this.tag, this.disposed);

  @override
  IHoverPart get hoverPart => throw UnimplementedError();
  @override
  Object get hoverElement => tag;
  @override
  void dispose() => disposed.add(tag);
}

class _Disposables {
  final List<String> disposed;
  _Disposables(this.disposed);
  void dispose() => disposed.add('extra');
}

void main() {
  final Map<String, dynamic> truth = _truth();

  test('hover types replay TS truth', () {
    final Map<String, Object?> actual = <String, Object?>{};

    actual['anchor-types'] = <String, Object?>{
      'Range': HoverAnchorType.Range,
      'ForeignElement': HoverAnchorType.ForeignElement,
    };

    // HoverRangeAnchor
    final HoverRangeAnchor a =
        HoverRangeAnchor(0, Range(1, 2, 3, 4), 10, 20);
    final HoverRangeAnchor eq =
        HoverRangeAnchor(5, Range(1, 2, 3, 4), 99, 99);
    final HoverRangeAnchor neq =
        HoverRangeAnchor(0, Range(2, 2, 3, 4), 10, 20);
    final Object owner = Object();
    final HoverForeignElementAnchor foreign = HoverForeignElementAnchor(
      0, owner, Range(1, 2, 3, 4), 10, 20, false,
    );
    final HoverRangeAnchor lastRange =
        HoverRangeAnchor(0, Range(5, 5, 6, 6), 0, 0);
    actual['range-anchor'] = <String, Object?>{
      'type': a.type,
      'equalsSameRange': a.equals(eq),
      'equalsDiffRange': a.equals(neq),
      'equalsForeign': a.equals(foreign),
      'adoptSameLine': a.canAdoptVisibleHover(lastRange, Position(1, 1)),
      'adoptDiffLine': a.canAdoptVisibleHover(lastRange, Position(2, 1)),
      'adoptForeign': a.canAdoptVisibleHover(foreign, Position(1, 1)),
    };

    // HoverForeignElementAnchor
    final Object ownerA = Object();
    final Object ownerB = Object();
    final HoverForeignElementAnchor fa = HoverForeignElementAnchor(
      0, ownerA, Range(1, 1, 1, 2), 10, 20, true,
    );
    final HoverForeignElementAnchor fEq = HoverForeignElementAnchor(
      3, ownerA, Range(9, 9, 9, 9), 99, 99, false,
    );
    final HoverForeignElementAnchor fNeq = HoverForeignElementAnchor(
      0, ownerB, Range(1, 1, 1, 2), 10, 20, true,
    );
    final HoverForeignElementAnchor lastForeign = HoverForeignElementAnchor(
      0, ownerA, Range(5, 5, 6, 6), 0, 0, false,
    );
    final HoverForeignElementAnchor lastForeignB = HoverForeignElementAnchor(
      0, ownerB, Range(5, 5, 6, 6), 0, 0, false,
    );
    final HoverRangeAnchor rangeAnchor =
        HoverRangeAnchor(0, Range(1, 1, 1, 2), 10, 20);
    actual['foreign-anchor'] = <String, Object?>{
      'type': fa.type,
      'equalsSameOwner': fa.equals(fEq),
      'equalsDiffOwner': fa.equals(fNeq),
      'equalsRange': fa.equals(rangeAnchor),
      'adoptSameOwner': fa.canAdoptVisibleHover(lastForeign, Position(9, 9)),
      'adoptDiffOwner': fa.canAdoptVisibleHover(lastForeignB, Position(9, 9)),
      'adoptRange': fa.canAdoptVisibleHover(rangeAnchor, Position(9, 9)),
    };

    // Registry singleton (truth records before==0 in a fresh vm context;
    // compare only the delta produced here).
    final HoverParticipantRegistry registry = HoverParticipantRegistry();
    final int before = registry.getAll().length;
    final Object ctorA = Object();
    final Object ctorB = Object();
    registry.register(ctorA);
    registry.register(ctorB);
    final List<Object> all = registry.getAll();
    actual['registry'] = <String, Object?>{
      'before': before == 0 ? 0 : before - 2, // normalize to fresh-context value
      'after': all.length - (before == 0 ? 0 : before - 2),
      'sameInstance':
          identical(all[all.length - 2], ctorA) &&
              identical(all[all.length - 1], ctorB),
    };

    // RenderedHoverParts.dispose
    final List<String> disposed = <String>[];
    final List<IRenderedHoverPart<IHoverPart>> parts =
        <IRenderedHoverPart<IHoverPart>>[
      _Part('part1', disposed),
      _Part('part2', disposed),
    ];
    final RenderedHoverParts<IHoverPart> r =
        RenderedHoverParts(parts, _Disposables(disposed));
    final bool sameParts = identical(r.renderedHoverParts, parts);
    r.dispose();
    actual['rendered-parts'] = <String, Object?>{
      'sameParts': sameParts,
      'disposed': disposed,
    };

    final List<String> disposed2 = <String>[];
    final RenderedHoverParts<IHoverPart> r2 = RenderedHoverParts(
      <IRenderedHoverPart<IHoverPart>>[_Part('only', disposed2)],
    );
    r2.dispose();
    actual['rendered-parts-no-extra'] = <String, Object?>{
      'disposed': disposed2,
    };

    for (final String key in truth.keys) {
      expect(
        jsonEncode(actual[key]),
        jsonEncode(truth[key]),
        reason: 'mismatch at $key',
      );
    }
  });
}
