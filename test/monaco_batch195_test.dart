// Truth replay for batch195: `platform/quickinput/browser/quickInputUtils.ts`.
//
// Expectations come from `tool/ts2dart/batch195_truth.json`, produced by
// `tool/ts2dart/_batch195_truth.cjs` (real transpiled TypeScript + the real
// linkedText / idGenerator / keyCodes / keyboardEvent / event / lifecycle
// modules). DOM, `domStylesheets.createCSSRule`, `cssValue.asCSSUrl`,
// `renderLabelWithIcons`, touch Gesture and nls are deterministic stubs.
//
// NOTE: `quickInputUtils.ts` has no official test of its own; truth comes from
// executing the real source.
import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import '../lib/src/monaco/base/browser/dom.dart' as dom;
import '../lib/src/monaco/base/browser/domStylesheets.dart' as domStylesheets;
import '../lib/src/monaco/base/common/lifecycle.dart' as lifecycle;
import '../lib/src/monaco/base/common/uri.dart' show URI;
import '../lib/src/monaco/platform/quickinput/browser/quickInputUtils.dart'
    as utils;
import '../lib/src/monaco/platform/quickinput/common/quickInput.dart'
    as quickInput;

Map<String, dynamic> _map(dynamic value) =>
    (value as Map).cast<String, dynamic>();

List<dynamic> _list(dynamic value) => value as List<dynamic>;

Matcher _exp(dynamic value) => value == null ? isNull : equals(value);

Map<String, dynamic> _truth() =>
    _map(jsonDecode(File('tool/ts2dart/batch195_truth.json').readAsStringSync()));

/// `background-image: url('file:///icons/dark.svg')` → `dark.svg`.
String _iconFileOf(String declaration) {
  final int dot = declaration.lastIndexOf('.svg');
  if (dot < 0) return declaration;
  int start = dot;
  while (start > 0) {
    final String ch = declaration[start - 1];
    if (ch == '/' || ch == '\\' || ch == "'" || ch == '\'') break;
    start--;
  }
  return declaration.substring(start, dot + 4);
}

/// Reads the CSS rules the port inserted into the shared stylesheet, oldest
/// last (`insertRule(rule, 0)` puts the newest first).
List<String> _rules() {
  final dom.DomElement sheet = domStylesheets.getSharedStyleSheet();
  final List<dom.DomCSSRule> rules =
      sheet.sheet?.cssRules ?? const <dom.DomCSSRule>[];
  return rules
      .map((dom.DomCSSRule rule) => '${rule.selectorText}||${rule.cssText}')
      .toList()
      .reversed
      .toList();
}

/// The truth's CSS URL text uses the plain `uri.toString()` carrier stub; the
/// port goes through its own `asCSSUrl` (app scheme + CSS escaping), so the
/// comparison pins the selector and the referenced icon file only.
bool _hasRule(List<String> rules, String selector, String iconFile) =>
    rules.any((String rule) =>
        rule.startsWith('$selector||') &&
        rule.split('||').last.replaceAll('\\', '').contains(iconFile));

dom.DomElement _anchor(dom.DomElement container) =>
    container.childNodes.whereType<dom.DomElement>().firstWhere(
        (dom.DomElement el) => el.tagName == 'A');

Map<String, Object?> _anchorSnapshot(dom.DomElement anchor) => <String, Object?>{
      'href': anchor.getAttribute('href'),
      'title': anchor.getAttribute('title'),
      'tabIndex': anchor.tabIndex,
      'textDecoration': anchor.style['textDecoration'],
      'clickListeners': anchor.listenerCount(dom.EventType.CLICK),
      'keydownListeners': anchor.listenerCount(dom.EventType.KEY_DOWN),
      'tapListeners': anchor.listenerCount('-monaco-gesturetap'),
    };

void main() {
  final Map<String, dynamic> truth = _truth();

  test('batch195 icon class cache and CSS rules match truth', () {
    final Map<String, dynamic> expected = _map(truth['iconClass']);
    utils.iconPathToClass.clear();
    final int rulesBefore = _rules().length;

    final URI dark = URI.file('/icons/dark.svg');
    final URI dark2 = URI.file('/icons/dark2.svg');
    final URI light = URI.file('/icons/light.svg');

    final Object? action1 = utils.quickInputButtonToAction(
      quickInput.IQuickInputButton(iconPath: quickInput.IconPath(dark: dark)),
      'btn-1',
      () => 'run-1',
    );
    final List<String> rulesAfterFirst =
        _rules().take(_rules().length - rulesBefore).toList();
    final Object? action2 = utils.quickInputButtonToAction(
      quickInput.IQuickInputButton(iconPath: quickInput.IconPath(dark: dark)),
      'btn-2',
      () => 'run-2',
    );
    final List<String> rulesAfterSecond =
        _rules().take(_rules().length - rulesBefore).toList();
    final Object? action3 = utils.quickInputButtonToAction(
      quickInput.IQuickInputButton(
          iconPath: quickInput.IconPath(dark: dark2, light: light)),
      'btn-3',
      () => 'run-3',
    );

    final Map<String, dynamic> first = _map(expected['first']);
    final dynamic a1 = action1;
    expect(a1.id, first['id']);
    expect(a1.label, first['label']);
    expect(a1.tooltip, first['tooltip']);
    expect(a1.cssClass, first['class']);
    expect(a1.enabled, first['enabled']);
    expect((action2 as dynamic).cssClass, expected['secondSamePathClass']);
    expect(rulesAfterSecond.length == rulesAfterFirst.length,
        expected['cachedNoNewRules']);
    for (final dynamic rawRule in _list(expected['rulesAfterFirst'])) {
      final List<dynamic> rule = _list(rawRule);
      expect(
          _hasRule(rulesAfterFirst, rule[0] as String,
              _iconFileOf(rule[1] as String)),
          isTrue,
          reason: 'missing created rule ${rule[0]}');
    }
    expect((action3 as dynamic).cssClass, expected['thirdClass']);
    final List<String> rulesAfterThird =
        _rules().take(_rules().length - rulesBefore).toList();
    for (final dynamic rawRule in _list(expected['newPathRules'])) {
      final List<dynamic> rule = _list(rawRule);
      expect(
          _hasRule(rulesAfterThird, rule[0] as String,
              _iconFileOf(rule[1] as String)),
          isTrue,
          reason: 'missing light/dark rule ${rule[0]}');
    }
    expect(rulesAfterThird.length - rulesAfterFirst.length, 2);
    expect(a1.run(), expected['runResult']);
  });

  test('batch195 always-visible class matches truth', () {
    expect(
      (utils.quickInputButtonToAction(
        quickInput.IQuickInputButton(
            iconClass: 'my-icon', alwaysVisible: true),
        'btn-4',
        () => 'run-4',
      ) as dynamic)
          .cssClass,
      truth['iconClassAlwaysVisible'],
    );
    expect(
      (utils.quickInputButtonToAction(
        quickInput.IQuickInputButton(alwaysVisible: true),
        'btn-5',
        () => 'run-5',
      ) as dynamic)
          .cssClass,
      truth['alwaysVisibleOnly'],
    );
  });

  test('batch195 toggle action semantics match truth', () {
    final Map<String, dynamic> expected = _map(truth['toggleAction']);
    int runs = 0;
    final quickInput.QuickInputToggle toggle =
        quickInput.QuickInputToggle(checked: true);
    final Object? action = utils.quickInputButtonToAction(
      quickInput.IQuickInputButton(toggle: toggle, tooltip: 'Toggle me'),
      'toggle-1',
      () {
        runs++;
        return runs;
      },
    );
    final dynamic a = action;

    final Map<String, dynamic> initial = _map(expected['initial']);
    expect(a.checked, initial['checked']);
    expect(a.label, initial['label']);
    expect(a.tooltip, initial['tooltip']);
    expect(a.cssClass, initial['class']);
    expect(a.enabled, initial['enabled']);

    expect(a.run(), expected['runResult']);
    final Map<String, dynamic> afterRun = _map(expected['afterRun']);
    expect(a.checked, afterRun['checked']);
    expect(toggle.checked, afterRun['toggleChecked']);
    expect(runs, afterRun['runs']);

    a.checked = true;
    final Map<String, dynamic> afterSetter = _map(expected['afterSetter']);
    expect(a.checked, afterSetter['checked']);
    expect(toggle.checked, afterSetter['toggleChecked']);
    expect(runs, afterSetter['runs']);
  });

  test('batch195 button action arrays match truth', () {
    final Map<String, dynamic> expected = _map(truth['buttonArrays']);
    final List<String> triggered = <String>[];
    final List<quickInput.IQuickInputButton> buttons =
        <quickInput.IQuickInputButton>[
      quickInput.IQuickInputButton(iconClass: 'a', tooltip: 'A'),
      quickInput.IQuickInputButton(
          iconClass: 'b', label: 'B label', secondary: true),
      quickInput.IQuickInputButton(iconClass: 'c', tooltip: 'C'),
    ];
    final utils.QuickInputActions arrays =
        utils.quickInputButtonsToActionArrays(
      buttons,
      'prefix',
      (quickInput.IQuickInputButton button) {
        triggered.add(button.tooltip ?? button.label ?? '?');
        return 'triggered-${button.iconClass}';
      },
    );

    List<Map<String, Object?>> project(List<dynamic> actions) => actions
        .map((dynamic a) => <String, Object?>{
              'id': a.id,
              'label': a.label,
              'tooltip': a.tooltip,
              'class': a.cssClass,
              'enabled': a.enabled,
            })
        .toList();

    expect(project(arrays.primary), _exp(expected['primary']));
    expect(project(arrays.secondary), _exp(expected['secondary']));
    expect(triggered, _exp(expected['triggered']));

    (arrays.secondary.first as dynamic).run();
    expect(triggered, _exp(expected['afterRun']));
  });

  test('batch195 renderQuickInputDescription matches truth', () {
    final Map<String, dynamic> expected = _map(truth['renderDescription']);
    final List<String> calls = <String>[];
    final lifecycle.DisposableStore disposables =
        lifecycle.DisposableStore();

    final dom.DomElement container = dom.document.createElement('div');
    container.appendChild(dom.document.createElement('span'));
    utils.renderQuickInputDescription(
      'plain \$(zap) text [with title](https://example.com "the title")',
      container,
      utils.IQuickInputDescriptionActionHandler(
        callback: calls.add,
        disposables: disposables,
      ),
    );

    final dom.DomElement commandContainer =
        dom.document.createElement('div');
    utils.renderQuickInputDescription(
      '[run](command:workbench.action.foo) [plain](https://example.com)',
      commandContainer,
      utils.IQuickInputDescriptionActionHandler(
        callback: calls.add,
        disposables: disposables,
      ),
    );

    final List<dynamic> descriptions = _list(expected['descriptions']);
    final List<Object?> expectedAnchors = <Object?>[];
    for (final dynamic rawDescription in descriptions) {
      for (final dynamic rawAnchor in _list(_map(rawDescription)['anchors'])) {
        expectedAnchors.add(_map(rawAnchor));
      }
    }
    final List<Map<String, Object?>> actualAnchors = <Map<String, Object?>>[
      for (final dom.DomElement anchor in container.childNodes
          .whereType<dom.DomElement>()
          .where((dom.DomElement el) => el.tagName == 'A'))
        _anchorSnapshot(anchor),
      for (final dom.DomElement anchor in commandContainer.childNodes
          .whereType<dom.DomElement>()
          .where((dom.DomElement el) => el.tagName == 'A'))
        _anchorSnapshot(anchor),
    ];
    expect(actualAnchors.length, _list(expected['anchorCounts']).fold<int>(
        0, (int sum, dynamic count) => sum + (count as int)));
    for (int i = 0; i < actualAnchors.length; i++) {
      final Map<String, dynamic> expectedAnchor = _map(expectedAnchors[i]);
      expect(actualAnchors[i]['href'], _exp(expectedAnchor['href']),
          reason: 'anchor $i href');
      expect(actualAnchors[i]['title'], _exp(expectedAnchor['title']),
          reason: 'anchor $i title');
      expect(actualAnchors[i]['tabIndex'], _exp(expectedAnchor['tabIndex']),
          reason: 'anchor $i tabIndex');
      expect(actualAnchors[i]['textDecoration'],
          _exp(expectedAnchor['textDecoration']),
          reason: 'anchor $i textDecoration');
      expect(actualAnchors[i]['clickListeners'],
          _exp(expectedAnchor['clickListeners']),
          reason: 'anchor $i click listeners');
      expect(actualAnchors[i]['keydownListeners'],
          _exp(expectedAnchor['keydownListeners']),
          reason: 'anchor $i keydown listeners');
    }

    final dom.DomElement anchor = _anchor(container);
    final dom.DomEvent clickEvent = dom.DomEvent(dom.EventType.CLICK);
    anchor.dispatchEvent(dom.EventType.CLICK, clickEvent);
    final Map<String, dynamic> expectedClick = _map(expected['click']);
    expect(calls, _exp(expectedClick['calls']));
    expect(clickEvent.defaultPrevented, _exp(expectedClick['prevented']));
    expect(clickEvent.cancelBubble, _exp(expectedClick['stopped']));

    final dom.DomKeyboardEvent enterEvent =
        dom.DomKeyboardEvent(dom.EventType.KEY_DOWN)..keyCode = 13;
    final int beforeEnter = calls.length;
    anchor.dispatchEvent(dom.EventType.KEY_DOWN, enterEvent);
    final Map<String, dynamic> expectedEnter = _map(expected['enter']);
    expect(calls.sublist(beforeEnter), _exp(expectedEnter['newCalls']));
    expect(enterEvent.defaultPrevented, _exp(expectedEnter['prevented']));

    final dom.DomKeyboardEvent letterEvent =
        dom.DomKeyboardEvent(dom.EventType.KEY_DOWN)..keyCode = 65;
    final int beforeLetter = calls.length;
    anchor.dispatchEvent(dom.EventType.KEY_DOWN, letterEvent);
    expect(calls.sublist(beforeLetter),
        _exp(_map(expected['letter'])['newCalls']));

    final dom.DomEvent tapEvent = dom.DomEvent('-monaco-gesturetap');
    final int beforeTap = calls.length;
    anchor.dispatchEvent('-monaco-gesturetap', tapEvent);
    final Map<String, dynamic> expectedTap = _map(expected['tap']);
    expect(calls.sublist(beforeTap), _exp(expectedTap['newCalls']));
    expect(tapEvent.defaultPrevented, _exp(expectedTap['prevented']));

    disposables.dispose();
    expect(anchor.listenerCount(dom.EventType.CLICK),
        _map(expected['listenersAfterDispose'])['click']);
    expect(anchor.listenerCount(dom.EventType.KEY_DOWN),
        _map(expected['listenersAfterDispose'])['keydown']);
  });
}