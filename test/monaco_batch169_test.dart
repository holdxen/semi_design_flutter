// Truth-driven tests for base/browser/ui/hover/hoverWidget.ts.
// Truth: tool/ts2dart/batch169_truth.json (real transpiled TypeScript module).
import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:semi_design_flutter/src/monaco/base/browser/dom.dart' as dom;
import 'package:semi_design_flutter/src/monaco/base/browser/ui/hover/hoverWidget.dart'
    as hw;

final Map<String, dynamic> T = jsonDecode(
        File('tool/ts2dart/batch169_truth.json').readAsStringSync())
    as Map<String, dynamic>;

Map<String, dynamic> _map(Object? v) => (v as Map).cast<String, dynamic>();
List<dynamic> _list(Object? v) => (v as List).cast<dynamic>();

void main() {
  group('hoverWidget', () {
    test('exports and HoverPosition match truth', () {
      final List<String> expected =
          _list(T['exports']).map((Object? e) => e as String).toList()..sort();
      expect(<String>[
        'ClickAction', 'HoverAction', 'HoverPosition', 'HoverWidget',
        'KeyDownAction', 'getHoverAccessibleViewHint',
      ], expected);
      final Map<String, dynamic> hp = _map(T['HoverPosition']);
      expect(hw.HoverPosition.LEFT, hp['LEFT']);
      expect(hw.HoverPosition.RIGHT, hp['RIGHT']);
      expect(hw.HoverPosition.BELOW, hp['BELOW']);
      expect(hw.HoverPosition.ABOVE, hp['ABOVE']);
    });

    test('HoverWidget constructor (fadeIn) matches truth', () {
      final Map<String, dynamic> t = _map(T['hoverWidgetFade']);
      final hw.HoverWidget w = hw.HoverWidget(true);
      expect(w.containerDomNode.className, t['containerClass']);
      expect(w.containerDomNode.classList.toList(), _list(t['containerClasses']));
      expect(w.containerDomNode.tabIndex, t['tabIndex']);
      expect(w.containerDomNode.getAttribute('role'), t['role']);
      expect(w.contentsDomNode.className, t['contentsClass']);
      expect(w.containerDomNode.childNodes.length, t['containerChildren']);
      expect(identical(w.containerDomNode.childNodes.first, w.scrollbar.getDomNode()),
          t['childIsScrollDom']);
      // onContentsChanged drives scanDomNode once. The Dart constructor also
      // performs an initial scan, so compare the delta against the JS stub.
      final int scansBefore = w.scrollbar.scans;
      w.onContentsChanged();
      expect(w.scrollbar.scans - scansBefore,
          (t['scanAfter'] as int) - (t['scanBefore'] as int));
    });

    test('HoverWidget constructor (no fade) matches truth', () {
      final Map<String, dynamic> t = _map(T['hoverWidgetNoFade']);
      final hw.HoverWidget w = hw.HoverWidget(false);
      expect(w.containerDomNode.classList.toList(), _list(t['containerClasses']));
      expect(w.containerDomNode.classList.contains('fade-in'), t['hasFadeIn']);
    });

    test('HoverAction.render structure and labels match truth', () {
      final Map<String, dynamic> t = _map(T['hoverAction']);
      final dom.DomElement parent = dom.document.createElement('div');
      int runs = 0;
      final hw.HoverAction a = hw.HoverAction.render(
        parent,
        hw.HoverActionOptions(
          label: 'Do Thing',
          iconClass: 'codicon codicon-x',
          run: (dom.DomElement target) => runs++,
          commandId: 'cmd',
        ),
        'Ctrl+D',
      );
      expect(a.actionLabel, t['actionLabel']);
      expect(a.actionKeybindingLabel, t['actionKeybindingLabel']);
      expect(a.actionRenderedLabel, t['actionRenderedLabel']);
      expect(a.actionContainer.getAttribute('tabindex'), t['containerTabIndex']);
      expect(a.action.getAttribute('role'), t['actionRole']);
      expect(a.actionContainer.classList.contains('disabled'),
          t['setEnabledInitial']);
      expect(a.actionContainer.childNodes.length, 1); // action node
      // setEnabled sequence
      a.setEnabled(false);
      // dom.$ parses 'div.action-container' into a real class token; the JS
      // truth stub does not. Compare only the state classes under test.
      List<String> stateClasses() => a.actionContainer.classList
          .toList()
          .where((String c) => c != 'action-container')
          .toList();
      expect(stateClasses(), _list(t['disabledClasses']));
      expect(a.actionContainer.getAttribute('aria-disabled'), t['ariaDisabled']);
      a.setEnabled(true);
      expect(stateClasses(), _list(t['reenabledClasses']));
      expect(a.actionContainer.getAttribute('aria-disabled'),
          t['ariaDisabledAfterEnable']);
      // click listener registered + run
      a.actionContainer.dispatchEvent(
          dom.EventType.CLICK, dom.DomEvent(dom.EventType.CLICK));
      expect(runs, 1);
    });

    test('HoverAction.render without keybinding/icon matches truth', () {
      final Map<String, dynamic> t = _map(T['hoverActionPlain']);
      final dom.DomElement parent = dom.document.createElement('div');
      final hw.HoverAction a = hw.HoverAction.render(
        parent,
        hw.HoverActionOptions(label: 'Plain', run: (_) {}, commandId: 'c'),
        null,
      );
      expect(a.actionRenderedLabel, t['rendered']);
      expect(a.actionContainer.childNodes.single.childNodes.length, 1); // span label
      expect(
          (((a.actionContainer.childNodes.single as dom.DomElement)
                      .childNodes.single as dom.DomElement)
                  .childNodes.single as dom.DomTextNode)
              .textContent,
          t['rendered']);
    });

    test('ClickAction runs with stop+preventDefault', () {
      final Map<String, dynamic> t = _map(T['clickAction']);
      final dom.DomElement c = dom.document.createElement('div');
      int runs = 0;
      hw.ClickAction(c, (dom.DomElement target) => runs++);
      c.dispatchEvent(dom.EventType.CLICK, dom.DomEvent(dom.EventType.CLICK));
      expect(runs, t['runs']);
    });

    test('KeyDownAction runs only for matching key codes', () {
      final Map<String, dynamic> t = _map(T['keyDownAction']);
      final dom.DomElement c = dom.document.createElement('div');
      int runs = 0;
      hw.KeyDownAction(
          c,
          (dom.DomElement target) => runs++,
          <int>[3, 10] // KeyCode.Enter, KeyCode.Space
          );
      // StandardKeyboardEvent maps browser keyCode 13 → KeyCode.Enter (3).
      // The JS truth stub compares raw keyCodes, so it used 10 directly.
      c.dispatchEvent(dom.EventType.KEY_DOWN,
          dom.DomKeyboardEvent(dom.EventType.KEY_DOWN)..keyCode = 13);
      c.dispatchEvent(dom.EventType.KEY_DOWN,
          dom.DomKeyboardEvent(dom.EventType.KEY_DOWN)..keyCode = 999);
      expect(runs, t['runs']);
    });

    test('getHoverAccessibleViewHint matches truth', () {
      final Map<String, dynamic> hints = _map(T['hints']);
      expect(hw.getHoverAccessibleViewHint(true, 'F1'), hints['withKb']);
      expect(hw.getHoverAccessibleViewHint(true, null), hints['noKb']);
      expect(hw.getHoverAccessibleViewHint(false, 'F1'), hints['noHint']);
      expect(hw.getHoverAccessibleViewHint(), hints['undefinedHint']);
    });
  });
}
