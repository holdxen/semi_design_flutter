// batch316: hoverUtils.ts truth replay.
import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:semi_design_flutter/src/monaco/editor/contrib/hover/browser/hoverUtils.dart'
    show
      HoverElementRect,
      HoverMouseFlags,
      IEditorMouseEventForHover,
      hoverElementRectProvider,
      isMousePositionWithinElement,
      isTriggerModifierPressed,
      shouldShowHover;

Map<String, dynamic> _truth() => jsonDecode(
    File('tool/ts2dart/batch316_truth.json').readAsStringSync())
    as Map<String, dynamic>;

class _MouseEvent implements IEditorMouseEventForHover {
  _MouseEvent(this.flags);

  @override
  final HoverMouseFlags flags;

  @override
  HoverMouseFlags get event => flags;
}

void main() {
  final Map<String, dynamic> truth = _truth();
  final Map<String, dynamic> rect = truth['rect'] as Map<String, dynamic>;
  hoverElementRectProvider = (Object element) => HoverElementRect(
        left: rect['left'] as num,
        top: rect['top'] as num,
        width: rect['width'] as num,
        height: rect['height'] as num,
      );

  final Map<String, HoverMouseFlags> flags = <String, HoverMouseFlags>{};
  for (final dynamic raw in truth['flags'] as List<dynamic>) {
    final Map<String, dynamic> f = raw as Map<String, dynamic>;
    flags[f['label'] as String] = HoverMouseFlags(
      ctrlKey: f['ctrlKey'] as bool,
      metaKey: f['metaKey'] as bool,
      altKey: f['altKey'] as bool,
    );
  }

  test('position padding matches truth', () {
    for (final dynamic raw in truth['positions'] as List<dynamic>) {
      final Map<String, dynamic> c = raw as Map<String, dynamic>;
      expect(
        isMousePositionWithinElement(
            Object(), c['x'] as num, c['y'] as num),
        c['result'],
        reason: c['label'] as String,
      );
    }
  });

  test('trigger modifier matches truth', () {
    for (final dynamic raw in truth['trigger'] as List<dynamic>) {
      final Map<String, dynamic> c = raw as Map<String, dynamic>;
      expect(
        isTriggerModifierPressed(
            c['modifier'] as String, flags[c['flags'] as String]!),
        c['result'],
        reason: '${c['modifier']}/${c['flags']}',
      );
    }
  });

  test('shouldShowHover matches truth', () {
    for (final dynamic raw in truth['show'] as List<dynamic>) {
      final Map<String, dynamic> c = raw as Map<String, dynamic>;
      expect(
        shouldShowHover(
          c['setting'] as String,
          c['modifier'] as String,
          _MouseEvent(flags[c['flags'] as String]!),
        ),
        c['result'],
        reason: '${c['setting']}/${c['modifier']}/${c['flags']}',
      );
    }
  });
}
