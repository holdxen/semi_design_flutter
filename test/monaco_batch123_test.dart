import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:semi_design_flutter/src/monaco/base/browser/dom.dart' as dom;
import 'package:semi_design_flutter/src/monaco/base/browser/mouseEvent.dart' as mouse;
import 'package:semi_design_flutter/src/monaco/base/browser/keyboardEvent.dart' as keyboard;
import 'package:semi_design_flutter/src/monaco/base/browser/window.dart' as win;
import 'package:semi_design_flutter/src/monaco/base/browser/ui/contextview/contextview.dart'
    as cv;
import 'package:semi_design_flutter/src/monaco/base/browser/ui/contextview/windowControlsOverlay.dart'
    as wco;
import 'package:semi_design_flutter/src/monaco/base/common/lifecycle.dart'
    as lifecycle;
import 'package:semi_design_flutter/src/monaco/base/common/layout.dart' as lay;

final Map<String, dynamic> _truth =
    jsonDecode(File('tool/ts2dart/batch123_truth.json').readAsStringSync())
        as Map<String, dynamic>;

Map<String, dynamic> _section(String name) =>
    (_truth[name] as Map).cast<String, dynamic>();

List<dynamic> _listSection(String name) => _truth[name] as List<dynamic>;

String _eventType(Object e) {
  if (e is dom.DomEvent) return e.type;
  if (e is mouse.StandardMouseEvent) return e.browserEvent.type;
  if (e is keyboard.StandardKeyboardEvent) return e.browserEvent.type;
  return 'unknown';
}

Map<String, Object?> _rectMap(lay.IRect r) => <String, Object?>{
      'top': r.top,
      'left': r.left,
      'width': r.width,
      'height': r.height,
    };

void _expectMap(Object? actual, Object? expected, String label) {
  if (expected is Map) {
    expect(actual, isA<Map>(), reason: label);
    final Map act = actual as Map;
    for (final key in expected.keys) {
      _expectMap(act[key], expected[key], '$label.$key');
    }
  } else if (expected is List) {
    expect(actual, isA<List>(), reason: label);
    final List act = actual as List;
    expect(act.length, expected.length, reason: '$label.length');
    for (int i = 0; i < act.length; i++) {
      _expectMap(act[i], expected[i], '$label[$i]');
    }
  } else {
    expect(actual, expected, reason: label);
  }
}

class _TestDelegate implements cv.IDelegate {
  _TestDelegate({
    this.layer,
    this.canRelayout,
    this.closeAnimation,
    this.onDOMEventHandler,
    void Function()? onRender,
    void Function()? onFocus,
    void Function()? onLayout,
    void Function(Object?)? onHide,
  })  : _onRender = onRender,
        _onFocus = onFocus,
        _onLayout = onLayout,
        _onHide = onHide;

  @override
  final int? layer;
  @override
  final bool? canRelayout;
  @override
  final cv.IContextViewCloseAnimation? closeAnimation;
  @override
  void Function(Object, dom.DomElement)? onDOMEventHandler;

  final void Function()? _onRender;
  final void Function()? _onFocus;
  final void Function()? _onLayout;
  final void Function(Object?)? _onHide;

  final List<Map<String, Object?>> calls = <Map<String, Object?>>[];
  int contextDomPosition = -1;

  @override
  Object getAnchor() => <String, Object?>{'x': 100, 'y': 50, 'width': 10, 'height': 10};

  @override
  lifecycle.IDisposable? render(dom.DomElement container,
      [cv.IContextViewRenderContext? context]) {
    contextDomPosition = context?.domPosition ?? -1;
    calls.add(<String, Object?>{'op': 'render', 'context': contextDomPosition});
    _onRender?.call();
    return lifecycle.toDisposable(
        () => calls.add(<String, Object?>{'op': 'disposeRender'}));
  }

  @override
  void focus() {
    calls.add(<String, Object?>{'op': 'focus'});
    _onFocus?.call();
  }

  @override
  void layout() {
    calls.add(<String, Object?>{'op': 'layoutDelegate'});
    _onLayout?.call();
  }

  @override
  void onHide([Object? data]) {
    calls.add(<String, Object?>{
      'op': 'onHide',
      'data': data ?? 'undefined',
    });
    _onHide?.call(data);
  }

  @override
  int? get anchorAlignment => null;
  @override
  int? get anchorPosition => null;
  @override
  int? get anchorAxisAlignment => null;
}

Map<String, Object?> _viewState(dom.DomElement v) => <String, Object?>{
      'className': v.className,
      'display': v.style['display'] ?? '',
      'top': v.style['top'] ?? '',
      'left': v.style['left'] ?? '',
      'width': v.style['width'] ?? '',
      'zIndex': v.style['zIndex'] ?? '',
      'position': v.style['position'] ?? '',
      'parent': v.parentElement != null ? v.parentElement!.localName : null,
      'attrs': v.hasAttribute('popover') ? 'popover' : 'none',
    };

void main() {
  setUp(() {
    cv.computedStyleProvider = null;
    cv.showPopoverProvider = null;
    cv.hidePopoverProvider = null;
    cv.adoptPopoverResetStylesProvider = null;
    cv.isConnectedProvider = (dom.DomElement el) => true;
    cv.popoverOpenProvider = (dom.DomElement el) => false;
    cv.eventComposedPathProvider = null;
  });
  tearDown(() {
    cv.computedStyleProvider = null;
    cv.showPopoverProvider = null;
    cv.hidePopoverProvider = null;
    cv.adoptPopoverResetStylesProvider = null;
    cv.eventComposedPathProvider = null;
  });

  test('enums and helper predicates', () {
    final e = _section('enums');
    expect(cv.ContextViewDOMPosition.ABSOLUTE, e['ABSOLUTE']);
    expect(cv.ContextViewDOMPosition.FIXED, e['FIXED']);
    expect(cv.ContextViewDOMPosition.FIXED_SHADOW, e['FIXED_SHADOW']);
    expect(cv.ContextViewDOMPosition.POPOVER, e['POPOVER']);
    expect(cv.ContextViewDOMPosition.POPOVER_SHADOW, e['POPOVER_SHADOW']);
    expect(<bool>[
      cv.isPopoverDOMPosition(cv.ContextViewDOMPosition.ABSOLUTE),
      cv.isPopoverDOMPosition(cv.ContextViewDOMPosition.FIXED),
      cv.isPopoverDOMPosition(cv.ContextViewDOMPosition.POPOVER),
      cv.isPopoverDOMPosition(cv.ContextViewDOMPosition.POPOVER_SHADOW),
    ], e['isPopover']);
    expect(<bool>[
      cv.isAnchor(null),
      cv.isAnchor(<String, Object?>{}),
      cv.isAnchor(<String, Object?>{'x': 1}),
      cv.isAnchor(<String, Object?>{'x': 1, 'y': 2}),
      cv.isAnchor(<String, Object?>{'x': '1', 'y': 2}),
      cv.isAnchor(cv.IAnchor(1, 2)),
    ], <bool>[false, false, false, true, false, true]);
    expect((e['isAnchor'] as List).last, true);
  });

  test('constants', () {
    final c = _section('constants');
    expect(cv.CONTEXT_VIEW_MENU_MOTION_CLASS, c['motionClass']);
    expect(cv.CONTEXT_VIEW_MENU_MOTION_CLOSING_CLASS, c['closingClass']);
    expect(cv.CONTEXT_VIEW_MENU_MOTION_CLOSE_ANIMATION_DURATION, c['duration']);
    expect(cv.CONTEXT_VIEW_MENU_MOTION_ANCESTOR_CLASSES, c['ancestorClasses']);
    _expectMap(<String, Object?>{
      'className': cv.contextViewMenuCloseAnimation.className,
      'duration': cv.contextViewMenuCloseAnimation.duration,
      'requiredAncestorClasses':
          cv.contextViewMenuCloseAnimation.requiredAncestorClasses,
    }, c['animation'], 'animation');
    expect(cv.CONTEXT_VIEW_MENU_MOTION_OPEN_DURATION_MS, c['openDuration']);
    expect(cv.CONTEXT_VIEW_MENU_MOTION_EASING, c['easing']);
  });

  test('hasRequiredAncestorClasses', () {
    final expected = _section('ancestorClasses');
    final child = dom.DomElement('div');
    final parent = dom.DomElement('div')
      ..className = 'modern-ui monaco-enable-motion';
    parent.appendChild(child);
    final none = dom.DomElement('div');
    expect(cv.hasRequiredAncestorClasses(child, null), expected['noneRequired']);
    expect(
        cv.hasRequiredAncestorClasses(child, <Object>[
          <String>['modern-ui', 'other'],
          'monaco-enable-motion',
        ]),
        expected['chainMatch']);
    expect(cv.hasRequiredAncestorClasses(none, <Object>['modern-ui']),
        expected['chainMiss']);
    expect(cv.hasRequiredAncestorClasses(parent, <Object>['modern-ui']),
        expected['singleMatch']);
    expect(
        cv.hasRequiredAncestorClasses(child, <Object>[
          <String>['missing', 'modern-ui']
        ]),
        expected['nestedAny']);
  });

  test('getAnchorRect variants', () {
    final expected = _section('anchorRect');
    final el = dom.DomElement('div')
      ..rect = dom.DomRect(left: 20, top: 10, width: 30, height: 40);
    _expectMap(_rectMap(cv.getAnchorRect(el)), expected['element'], 'element');
    _expectMap(_rectMap(cv.getAnchorRect(cv.IAnchor(5, 7))),
        expected['plainZero'], 'plainZero');
    _expectMap(_rectMap(cv.getAnchorRect(cv.IAnchor(5, 7, 12, 14))),
        expected['plainSized'], 'plainSized');
    final mouse = dom.DomMouseEvent('click')
      ..pageX = 3
      ..pageY = 4;
    _expectMap(_rectMap(cv.getAnchorRect(mouse)), expected['mouse'], 'mouse');
  });

  test('alignViewToDevicePixels (dpr=1 -> unchanged)', () {
    final expected = _section('align');
    final result = cv.alignViewToDevicePixels(
      wco.WindowControlsOverlayPosition(top: 10, left: 20),
      wco.WindowControlsOverlaySize(width: 100, height: 50),
      wco.WindowControlsOverlaySize(width: 100, height: 50),
      lay.IRect(0, 0, 1, 2),
      wco.WindowControlsOverlayViewport(top: 0, left: 0, width: 1000, height: 800),
      1,
      null,
    );
    expect(<String, Object?>{'top': result.top, 'left': result.left}, expected);
  });

  test('focus helpers', () {
    final expected = _section('focus');
    final doc = dom.windowCarrier(win.mainWindow).document;
    expect(cv.getFocusedContextView(doc) == null ? 'undefined' : 'view',
        expected['focused']);
    expect(cv.isContextViewFocused(doc), expected['isFocused']);
  });

  test('ABSOLUTE: construct/show/layout/hide/dispose', () {
    final expected = _section('absolute');
    final container = dom.DomElement('div');
    dom.document.body.appendChild(container);
    final view = cv.ContextView(container, cv.ContextViewDOMPosition.ABSOLUTE);
    final v = view.getViewElement();
    _expectMap(_viewState(v), expected['constructed'], 'constructed');

    final delegate = _TestDelegate();
    view.show(delegate);
    _expectMap(_viewState(v), expected['afterShow'], 'afterShow');
    expect(view.getEffectiveDOMPosition(), expected['effective']);
    view.layout();
    expect(delegate.calls.map((m) => Map<String, Object?>.from(m)).toList(),
        expected['afterLayoutCalls']);
    view.hide('reason');
    _expectMap(_viewState(v), expected['afterHide'], 'afterHide');
    expect(delegate.calls.map((m) => Map<String, Object?>.from(m)).toList(),
        expected['afterHideCalls']);
    view.dispose();
  });

  test('FIXED: position + zIndex layer', () {
    final expected = _section('fixed');
    final container = dom.DomElement('div');
    final view = cv.ContextView(container, cv.ContextViewDOMPosition.FIXED);
    final delegate = _TestDelegate(layer: 3);
    view.show(delegate);
    _expectMap(_viewState(view.getViewElement()), expected['state'], 'state');
    expect(view.getEffectiveDOMPosition(), expected['effective']);
    view.dispose();
  });

  test('canRelayout=false hides on layout', () {
    final expected = _section('noRelayout');
    final container = dom.DomElement('div');
    final view = cv.ContextView(container, cv.ContextViewDOMPosition.ABSOLUTE);
    final delegate = _TestDelegate(canRelayout: false);
    view.show(delegate);
    view.layout();
    expect(delegate.calls.map((m) => Map<String, Object?>.from(m)).toList(),
        expected['calls']);
    expect(view.getViewElement().style['display'], expected['display']);
    view.dispose();
  });

  test('DOM event bubbling to delegate', () {
    final expected = _listSection('bubble');
    final container = dom.DomElement('div');
    dom.document.body.appendChild(container);
    // jsdom's document.activeElement is <body> by default; mirror that here.
    dom.document.activeElement = dom.document.body;
    final view = cv.ContextView(container, cv.ContextViewDOMPosition.ABSOLUTE);
    final seen = <Map<String, Object?>>[];
    final delegate = _TestDelegate(
      onDOMEventHandler: (Object e, dom.DomElement active) {
        seen.add(<String, Object?>{
          'type': _eventType(e),
          'activeTag': active.localName,
        });
      },
    );
    view.show(delegate);
    container.dispatchEvent('click', dom.DomEvent('click'));
    container.dispatchEvent('keydown', dom.DomEvent('keydown'));
    expect(seen, expected);
    view.hide(null, true);
    view.dispose();
  });

  test('POPOVER falls back to FIXED with fallback container', () {
    final expected = _section('popoverFallback');
    final owner = dom.DomElement('div');
    dom.document.body.appendChild(owner);
    final fallback = dom.DomElement('div')
      ..setAttribute('data-fallback', '1');
    final view = cv.ContextView(
      owner,
      cv.ContextViewDOMPosition.POPOVER,
      cv.IContextViewOptions(
          getFallbackContainer: (dom.DomElement o) => fallback),
    );
    view.show(_TestDelegate());
    final v = view.getViewElement();
    expect(view.getEffectiveDOMPosition(), expected['effective']);
    expect(identical(v.parentElement, fallback) ? 'fallback' : 'other',
        expected['parent']);
    _expectMap(_viewState(v), expected['state'], 'state');
    view.hide(null, true);
    view.dispose();
  });

  test('close animation with required ancestor classes', () {
    final expected = _section('animation');
    final container = dom.DomElement('div');
    dom.document.body.appendChild(container);
    final view = cv.ContextView(container, cv.ContextViewDOMPosition.ABSOLUTE);
    final v = view.getViewElement();
    v.classList.add('modern-ui');
    v.classList.add('monaco-enable-motion');
    final delegate = _TestDelegate(
      closeAnimation: cv.IContextViewCloseAnimation(
        className: 'closing',
        duration: 150,
        requiredAncestorClasses: <Object>['modern-ui'],
      ),
    );
    view.show(delegate);
    v.classList.add('modern-ui');
    v.classList.add('monaco-enable-motion');
    view.hide();
    _expectMap(_viewState(v), expected['during'], 'during');
    expect(v.classList.contains('closing'), expected['hasClosing']);
    expect(v.style.getPropertyValue(
        cv.CONTEXT_VIEW_CLOSE_ANIMATION_DURATION_VARIABLE),
        expected['durVar']);
    view.hide(null, true);
    _expectMap(_viewState(v), expected['after'], 'after');
    expect(v.classList.contains('closing'), expected['afterHasClosing']);
    view.dispose();
  });
}
