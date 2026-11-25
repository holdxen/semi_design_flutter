// batch318: viewUserInputEvents.ts truth replay.
import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:semi_design_flutter/src/monaco/editor/browser/view/viewUserInputEvents.dart'
    show
      ICoordinatesConverterForViewInput,
      MouseTargetTypeForViewInput,
      ViewUserInputEvents;
import 'package:semi_design_flutter/src/monaco/editor/common/core/position.dart'
    show Position;
import 'package:semi_design_flutter/src/monaco/editor/common/core/range.dart'
    show Range;

Map<String, dynamic> _truth() => jsonDecode(
    File('tool/ts2dart/batch318_truth.json').readAsStringSync())
    as Map<String, dynamic>;

Object? _posJson(Object? p) {
  if (p == null) return null;
  if (p is List<Object?>) return p;
  final Position v = p as Position;
  return <Object?>[v.lineNumber, v.column];
}

Object? _rangeJson(Object? r) {
  if (r == null) return null;
  if (r is List<Object?>) return r;
  final Range v = r as Range;
  return <Object?>[
    v.startLineNumber,
    v.startColumn,
    v.endLineNumber,
    v.endColumn,
  ];
}

Map<String, Object?> _targetJson(Object? t) {
  if (t == null) return <String, Object?>{};
  final Map<String, Object?> m = t as Map<String, Object?>;
  final Map<String, Object?> out = <String, Object?>{
    'type': m['type'],
    'id': m['id'],
  };
  if (m['position'] != null) out['position'] = _posJson(m['position']);
  if (m['range'] != null) out['range'] = _rangeJson(m['range']);
  if (m['detail'] != null) {
    final Map<String, Object?> d = m['detail'] as Map<String, Object?>;
    out['detail'] = <String, Object?>{
      'viewZoneId': d['viewZoneId'],
      'positionBefore': _posJson(d['positionBefore']),
      'positionAfter': _posJson(d['positionAfter']),
      'position': _posJson(d['position']),
      'afterLineNumber': d['afterLineNumber'],
    };
  }
  return out;
}

class _Converter implements ICoordinatesConverterForViewInput {
  @override
  Position convertViewPositionToModelPosition(Position viewPosition) =>
      Position(viewPosition.lineNumber + 100, viewPosition.column + 1);

  @override
  Range convertViewRangeToModelRange(Range viewRange) => Range(
        viewRange.startLineNumber + 100,
        viewRange.startColumn + 1,
        viewRange.endLineNumber + 100,
        viewRange.endColumn + 1,
      );
}

void main() {
  final Map<String, dynamic> truth = _truth();
  final Map<String, dynamic> mtt =
      truth['mouseTargetType'] as Map<String, dynamic>;
  test('mouse target type constants match truth', () {
    expect(MouseTargetTypeForViewInput.GUTTER_VIEW_ZONE,
        mtt['GUTTER_VIEW_ZONE']);
    expect(MouseTargetTypeForViewInput.CONTENT_VIEW_ZONE,
        mtt['CONTENT_VIEW_ZONE']);
  });

  final _Converter converter = _Converter();
  final Map<String, Map<String, Object?>> targets =
      <String, Map<String, Object?>>{
    'plain': <String, Object?>{
      'type': 6,
      'id': 'a',
      'position': Position(3, 4),
      'range': Range(3, 4, 3, 8),
    },
    'gutter-zone': <String, Object?>{
      'type': MouseTargetTypeForViewInput.GUTTER_VIEW_ZONE,
      'id': 'b',
      'detail': <String, Object?>{
        'viewZoneId': 'z1',
        'positionBefore': Position(2, 1),
        'positionAfter': Position(4, 1),
        'position': Position(3, 1),
        'afterLineNumber': 5,
      },
    },
    'content-zone': <String, Object?>{
      'type': MouseTargetTypeForViewInput.CONTENT_VIEW_ZONE,
      'id': 'c',
      'detail': <String, Object?>{
        'viewZoneId': 'z2',
        'positionBefore': null,
        'positionAfter': null,
        'position': Position(7, 2),
        'afterLineNumber': 9,
      },
    },
    'no-target': <String, Object?>{},
  };

  test('static target conversion matches truth', () {
    for (final dynamic raw in truth['converted'] as List<dynamic>) {
      final Map<String, dynamic> c = raw as Map<String, dynamic>;
      final String label = c['label'] as String;
      final Object? result = label == 'no-target'
          ? null
          : ViewUserInputEvents.convertViewToModelMouseTarget(
              targets[label]!, converter);
      final Object? expected = c['result'];
      if (expected == null) {
        expect(result, isNull);
      } else {
        expect(_targetJson(result), expected);
      }
    }
  });

  test('event emission matches truth', () {
    final ViewUserInputEvents events = ViewUserInputEvents(converter);
    final List<Object?> fired = <Object?>[];
    void register(String name, void Function(Object? e) cb) {
      switch (name) {
        case 'onKeyDown':
          events.onKeyDown = cb;
          break;
        case 'onKeyUp':
          events.onKeyUp = cb;
          break;
        case 'onContextMenu':
          events.onContextMenu = cb;
          break;
        case 'onMouseMove':
          events.onMouseMove = cb;
          break;
        case 'onMouseLeave':
          events.onMouseLeave = cb;
          break;
        case 'onMouseDown':
          events.onMouseDown = cb;
          break;
        case 'onMouseUp':
          events.onMouseUp = cb;
          break;
        case 'onMouseDrag':
          events.onMouseDrag = cb;
          break;
        case 'onMouseDrop':
          events.onMouseDrop = cb;
          break;
        case 'onMouseWheel':
          events.onMouseWheel = cb;
          break;
      }
    }

    for (final String name in <String>[
      'onKeyDown', 'onKeyUp', 'onContextMenu', 'onMouseMove', 'onMouseLeave',
      'onMouseDown', 'onMouseUp', 'onMouseDrag', 'onMouseDrop', 'onMouseWheel',
    ]) {
      register(name, (Object? e) {
        Object? label;
        Object? target;
        if (e is Map<String, Object?>) {
          label = e['label'];
          target = e['target'] == null ? null : _targetJson(e['target']);
        }
        fired.add(<Object?>[name, label, target]);
      });
    }
    events.onMouseDropCanceled =
        () => fired.add(<Object?>['onMouseDropCanceled', null, null]);

    Map<String, Object?> mouse(String label, String targetLabel) =>
        <String, Object?>{
          'label': label,
          'event': <String, Object?>{'label': label},
          'target': targets[targetLabel],
        };

    events.emitKeyDown(<String, Object?>{'label': 'k1'});
    events.emitKeyUp(<String, Object?>{'label': 'k2'});
    events.emitContextMenu(mouse('ctx', 'plain'));
    events.emitMouseMove(mouse('move', 'gutter-zone'));
    events.emitMouseLeave(<String, Object?>{'label': 'leave', 'target': null});
    events.emitMouseDown(mouse('down', 'plain'));
    events.emitMouseUp(mouse('up', 'plain'));
    events.emitMouseDrag(mouse('drag', 'plain'));
    events.emitMouseDrop(mouse('drop', 'content-zone'));
    events.emitMouseDropCanceled();
    events.emitMouseWheel(<String, Object?>{'label': 'wheel'});

    expect(fired, truth['fired']);
  });
}
