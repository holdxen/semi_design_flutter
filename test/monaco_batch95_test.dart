// Data-driven port test for batch95: platform/actionWidget/browser/actionWidgetMotion.ts.
import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:semi_design_flutter/src/monaco/base/browser/dom.dart';
import 'package:semi_design_flutter/src/monaco/base/browser/window.dart';
import 'package:semi_design_flutter/src/monaco/platform/actionWidget/browser/actionWidgetMotion.dart';

const String truthJson = r"""
{
  "exports": [
    "ACTION_WIDGET_ANIMATED_CLASS",
    "ACTION_WIDGET_DROPDOWN_MOTION_CLASS",
    "ACTION_WIDGET_DROPDOWN_MOTION_CLOSING_CLASS",
    "finishActionWidgetOpeningAnimation"
  ],
  "constants": {
    "ACTION_WIDGET_ANIMATED_CLASS": "action-widget-animated",
    "ACTION_WIDGET_DROPDOWN_MOTION_CLASS": "action-widget-dropdown",
    "ACTION_WIDGET_DROPDOWN_MOTION_CLOSING_CLASS": "action-widget-dropdown-closing"
  },
  "finish": [
    {
      "name": "action-widget-scale-open",
      "finished": true
    },
    {
      "name": "other",
      "finished": false
    },
    {
      "name": "action-widget-scale-open",
      "finished": false
    },
    {
      "name": "action-widget-scale-open",
      "finished": false
    },
    {
      "name": "action-widget-scale-open",
      "finished": true
    }
  ],
  "emptyOk": true
}
""";

final Map<String, Object?> truth = jsonDecode(truthJson) as Map<String, Object?>;
Map<String, Object?> obj(Object? v) => (v as Map).cast<String, Object?>();
List<Object?> list(Object? v) => (v as List).cast<Object?>();

class _OtherAnimation extends DomAnimation {
  _OtherAnimation(String name) : super(name);
}

void main() {
  setUp(() {
    final DomWindowCarrier wc = windowCarrier(mainWindow);
    wc.document = DomDocument()..defaultView = mainWindow;
    wc.cssAnimation = DomCSSAnimation;
  });

  test('batch95 exports and constants', () {
    expect(truth['exports'], <Object?>[
      'ACTION_WIDGET_ANIMATED_CLASS',
      'ACTION_WIDGET_DROPDOWN_MOTION_CLASS',
      'ACTION_WIDGET_DROPDOWN_MOTION_CLOSING_CLASS',
      'finishActionWidgetOpeningAnimation',
    ]);
    expect(obj(truth['constants']), <String, Object?>{
      'ACTION_WIDGET_ANIMATED_CLASS': ACTION_WIDGET_ANIMATED_CLASS,
      'ACTION_WIDGET_DROPDOWN_MOTION_CLASS': ACTION_WIDGET_DROPDOWN_MOTION_CLASS,
      'ACTION_WIDGET_DROPDOWN_MOTION_CLOSING_CLASS':
          ACTION_WIDGET_DROPDOWN_MOTION_CLOSING_CLASS,
    });
  });

  test('batch95 finishes only the window CSSAnimation scale-open', () {
    final DomElement widget = document.createElement('div');
    final List<DomAnimation> animations = <DomAnimation>[
      DomCSSAnimation('action-widget-scale-open'),
      DomCSSAnimation('other'),
      DomAnimation('action-widget-scale-open'),
      _OtherAnimation('action-widget-scale-open'),
      DomCSSAnimation('action-widget-scale-open'),
    ];
    widget.animations.addAll(animations);
    windowCarrier(getWindow(widget)).cssAnimation = DomCSSAnimation;
    finishActionWidgetOpeningAnimation(widget);

    final List<Object?> actual = animations
        .map((DomAnimation a) => <String, Object?>{
              'name': a.animationName,
              'finished': a.finished,
            })
        .toList();
    expect(actual, list(truth['finish']));
  });

  test('batch95 empty animation list is a no-op', () {
    final DomElement widget = document.createElement('div');
    finishActionWidgetOpeningAnimation(widget);
    expect(truth['emptyOk'], isTrue);
  });
}
