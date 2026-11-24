import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import '../lib/src/monaco/base/browser/dom.dart' as dom;
import '../lib/src/monaco/base/browser/ui/highlightedlabel/highlightedLabel.dart' as hl;
import '../lib/src/monaco/base/browser/ui/hover/hover.dart' as h;
import '../lib/src/monaco/base/browser/ui/hover/hoverDelegate.dart' as d;
import '../lib/src/monaco/base/browser/ui/hover/hoverDelegate2.dart' as d2;
import '../lib/src/monaco/base/browser/ui/hover/hoverDelegateFactory.dart' as f;
import '../lib/src/monaco/base/browser/ui/keybindingLabel/keybindingLabel.dart' as kl;
import '../lib/src/monaco/base/common/keybindings.dart' as kb;

Map<String, dynamic> _map(dynamic value) => (value as Map).cast<String, dynamic>();

List<dynamic> _list(dynamic value) => value as List<dynamic>;

List<dynamic> _truthLog(
  Map<String, dynamic> section,
  String key, [
  Set<String> drop = const <String>{'disposableDispose'},
]) =>
    _list(section[key])
        .where((dynamic entry) => !drop.contains((entry as List)[0] as String))
        .toList();

String _escapeHtml(String value) => value
    .replaceAll('&', '&amp;')
    .replaceAll('<', '&lt;')
    .replaceAll('>', '&gt;')
    .replaceAll('"', '&quot;');

String _serialize(dom.DomNode node) {
  if (node is dom.DomTextNode) return _escapeHtml(node.data);
  if (node is! dom.DomElement) return '';
  final String className =
      node.className.isEmpty ? '' : ' class="${node.className}"';
  return '<${node.localName}$className>${_innerHtml(node)}</${node.localName}>';
}

String _innerHtml(dom.DomElement element) =>
    element.childNodes.map(_serialize).join();

Map<String, Object?> _attributes(dom.DomElement element) =>
    <String, Object?>{
      for (final MapEntry<String, String> entry in element.attributes)
        entry.key: entry.value,
    };

Map<String, Object?> _style(dom.DomElement element) => <String, Object?>{
      for (final String key in element.style.keys) key: element.style[key],
    };

Map<String, Object?> _snapshot(dom.DomElement element) => <String, Object?>{
      'tagName': element.localName,
      'className': element.className,
      'innerHTML': _innerHtml(element),
      'attributes': _attributes(element),
      'style': _style(element),
      'childCount': element.childNodes.length,
      'keyElements': element.childNodes
          .whereType<dom.DomElement>()
          .where((dom.DomElement child) =>
              child.className.split(RegExp(r'\s+')).contains('monaco-keybinding-key'))
          .map((dom.DomElement child) => <String, Object?>{
                'className': child.className,
                'textContent': child.textContent,
                'style': _style(child),
              })
          .toList(),
    };

class _RecordingManagedHover implements h.IManagedHover {
  _RecordingManagedHover(this.log);

  final List<List<Object?>> log;

  @override
  void show([bool? focus]) {}

  @override
  void hide() {}

  @override
  void update(Object? tooltip, [h.IManagedHoverOptions? options]) {
    log.add(<Object?>['managedUpdate', tooltip]);
  }

  @override
  void dispose() {
    log.add(<Object?>['managedDispose']);
  }
}

class _RecordingHoverDelegate2 implements h.IHoverDelegate2 {
  _RecordingHoverDelegate2(this.log);

  final List<List<Object?>> log;
  late final _RecordingManagedHover managed = _RecordingManagedHover(log);

  @override
  h.IHoverWidget? showInstantHover(h.IHoverOptions options, [bool? focus]) => null;

  @override
  h.IHoverWidget? showDelayedHover(
    h.IHoverOptions options,
    h.IHoverLifecycleOptions lifecycleOptions,
  ) =>
      null;

  @override
  Object? setupDelayedHover(
    dom.DomElement target,
    Object hoverOptions, [
    h.IHoverLifecycleOptions? lifecycleOptions,
  ]) =>
      managed;

  @override
  Object? setupDelayedHoverAtMouse(
    dom.DomElement target,
    Object hoverOptions, [
    h.IHoverLifecycleOptions? lifecycleOptions,
  ]) =>
      managed;

  @override
  void hideHover([bool? force]) {}

  @override
  void showAndFocusLastHover() {}

  @override
  h.IManagedHover setupManagedHover(
    d.IHoverDelegate hoverDelegate,
    dom.DomElement targetElement,
    Object? content, [
    h.IManagedHoverOptions? options,
  ]) {
    final String tag = hoverDelegate is _TaggedHoverDelegate
        ? hoverDelegate.tag
        : 'delegate';
    log.add(<Object?>[
      'setupManagedHover',
      tag,
      dom.isHTMLElement(targetElement) ? 'target' : 'target',
      content,
      options == null ? null : 'options',
    ]);
    return managed;
  }

  @override
  void showManagedHover(dom.DomElement targetElement) {}
}

class _TaggedHoverDelegate implements d.IScopedHoverDelegate {
  _TaggedHoverDelegate(this.placement, this.enableInstantHover)
      : tag = enableInstantHover ? 'defaultInstant' : 'defaultMouse';

  final String tag;
  final String placement;
  final bool enableInstantHover;

  @override
  h.IHoverWidget? showHover(d.IHoverDelegateOptions options, [bool? focus]) => null;

  @override
  void Function()? onDidHideHover;

  @override
  Object get delay => enableInstantHover ? 0 : placement == 'element' ? 7 : 11;

  @override
  bool? get showNativeHover => null;

  @override
  void dispose() {}
}

class _TestKeybinding extends kb.ResolvedKeybinding {
  _TestKeybinding(this.chords, this.ariaLabel);

  final List<kb.ResolvedChord> chords;
  final String? ariaLabel;

  @override
  String? getLabel() => ariaLabel;

  @override
  String? getAriaLabel() => ariaLabel;

  @override
  String? getElectronAccelerator() => ariaLabel;

  @override
  String? getUserSettingsLabel() => ariaLabel;

  @override
  bool isWYSIWYG() => true;

  @override
  bool hasMultipleChords() => chords.length > 1;

  @override
  List<kb.ResolvedChord> getChords() => chords;

  @override
  List<String?> getDispatchChords() => chords.map((kb.ResolvedChord c) => c.keyLabel).toList();

  @override
  List<String?> getSingleModifierDispatchChords() =>
      List<String?>.filled(chords.length, null);
}

List<Map<String, Object?>> _highlightMaps(List<hl.IHighlight> highlights) =>
    highlights.map((hl.IHighlight value) {
      final Map<String, Object?> result = <String, Object?>{
        'start': value.start,
        'end': value.end,
      };
      if (value.extraClasses != null) {
        result['extraClasses'] = value.extraClasses;
      }
      return result;
    }).toList();

void main() {
  final Map<String, dynamic> truth = _map(
    jsonDecode(File('tool/ts2dart/batch185_truth.json').readAsStringSync()),
  );
  f.setHoverDelegateFactory(
    (String placement, bool enableInstantHover) =>
        _TaggedHoverDelegate(placement, enableInstantHover),
  );

  group('batch185 highlightedLabel official truth', () {
    for (final dynamic rawCase in _list(truth['highlightedOfficial'])) {
      final Map<String, dynamic> testCase = _map(rawCase);
      final String name = testCase['name'] as String;
      test(name, () {
        final List<List<Object?>> log = <List<Object?>>[];
        d2.setBaseLayerHoverDelegate(_RecordingHoverDelegate2(log));
        final dom.DomElement container = dom.document.createElement('div');
        final hl.HighlightedLabel label = hl.HighlightedLabel(container);

        switch (name) {
          case 'empty label':
            break;
          case 'no decorations':
            label.set('hello');
            break;
          case 'colored symbol icon':
            label.set(r'$(symbol-class) hello', const <hl.IHighlight>[], '', false, true);
            break;
          case 'escape html':
            label.set('hel<lo');
            break;
          case 'everything highlighted':
            label.set('hello', <hl.IHighlight>[hl.IHighlight(start: 0, end: 5)]);
            break;
          case 'beginning highlighted':
            label.set('hellothere', <hl.IHighlight>[hl.IHighlight(start: 0, end: 5)]);
            break;
          case 'ending highlighted':
            label.set('goodbye', <hl.IHighlight>[hl.IHighlight(start: 4, end: 7)]);
            break;
          case 'middle highlighted':
            label.set('foobarfoo', <hl.IHighlight>[hl.IHighlight(start: 3, end: 6)]);
            break;
          case 'escapeNewLines':
            break;
          default:
            fail('unexpected official case: $name');
        }

        final List<dynamic> assertions = _list(testCase['assertions']);
        if (name != 'escapeNewLines') {
          expect(_innerHtml(label.element), assertions.single['actual']);
          expect(assertions.single['pass'], isTrue);
          expect(assertions.single['actual'], assertions.single['expected']);
          return;
        }

        final List<hl.IHighlight> first = <hl.IHighlight>[
          hl.IHighlight(start: 0, end: 5),
          hl.IHighlight(start: 7, end: 9),
          hl.IHighlight(start: 11, end: 12),
        ];
        expect(
          hl.HighlightedLabel.escapeNewLines('ACTION\r\n_TYPE2', first),
          assertions[0]['actual'],
        );
        expect(_highlightMaps(first), assertions[1]['actual']);

        final List<hl.IHighlight> second = <hl.IHighlight>[
          hl.IHighlight(start: 5, end: 9),
          hl.IHighlight(start: 11, end: 12),
        ];
        expect(
          hl.HighlightedLabel.escapeNewLines('ACTION\r\n_TYPE2', second),
          assertions[2]['actual'],
        );
        expect(_highlightMaps(second), assertions[3]['actual']);
        for (final dynamic assertion in assertions) {
          final Map<String, dynamic> map = _map(assertion);
          expect(map['pass'], isTrue);
          expect(map['actual'], map['expected']);
        }
      });
    }
  });

  group('batch185 highlightedLabel extended truth', () {
    test('render, hover updates, no-op and escapeNewLines match truth', () {
      final Map<String, dynamic> section = _map(truth['highlightedCustom']);
      expect(_list(section['exports']), <String>['HighlightedLabel']);

      final List<List<Object?>> log = <List<Object?>>[];
      d2.setBaseLayerHoverDelegate(_RecordingHoverDelegate2(log));
      final dom.DomElement container = dom.document.createElement('div');
      final hl.HighlightedLabel label = hl.HighlightedLabel(
        container,
        hl.IHighlightedLabelOptions(
          hoverDelegate: f.getDefaultHoverDelegate('mouse'),
        ),
      );
      final List<hl.IHighlight> highlights = <hl.IHighlight>[
        hl.IHighlight(start: 0, end: 2, extraClasses: <String>['a', 'b']),
      ];

      label.set('abcd', highlights, 'Title');
      expect(_snapshot(label.element), _map(_map(section['first'])['element']));
      expect(container.childNodes.length, section['first']['childCount']);
      expect(log, _truthLog(section['first'], 'log'));

      label.set('abcd', highlights, 'Title 2');
      expect(_snapshot(label.element), _map(_map(section['afterTitle'])['element']));
      expect(log, _truthLog(section['afterTitle'], 'log'));

      label.set('abcd', highlights, 'Title 2');
      expect(log, _truthLog(section['afterNoop'], 'log'));

      final List<hl.IHighlight> escaped = <hl.IHighlight>[
        hl.IHighlight(start: 0, end: 5),
        hl.IHighlight(start: 7, end: 9),
      ];
      expect(
        hl.HighlightedLabel.escapeNewLines('abc\r\ndef', escaped),
        _map(section['escapeNewLines'])['text'],
      );
      expect(
        _highlightMaps(escaped),
        _list(_map(section['escapeNewLines'])['highlights']),
      );

      label.dispose();
      expect(log, _truthLog(section['afterDispose'], 'log'));
    });
  });

  group('batch185 keybindingLabel truth', () {
    test('exports, styles, chord rendering and no-op updates match truth', () {
      final Map<String, dynamic> section = _map(truth['keybinding']);
      expect(_list(section['exports']), <String>[
        'KeybindingLabel',
        'unthemedKeybindingLabelOptions',
      ]);
      final Map<String, dynamic> unthemed = _map(section['unthemed']);
      expect(kl.unthemedKeybindingLabelOptions.keybindingLabelBackground,
          unthemed['keybindingLabelBackground']);
      expect(kl.unthemedKeybindingLabelOptions.keybindingLabelForeground,
          unthemed['keybindingLabelForeground']);
      expect(kl.unthemedKeybindingLabelOptions.keybindingLabelBorder,
          unthemed['keybindingLabelBorder']);
      expect(kl.unthemedKeybindingLabelOptions.keybindingLabelBottomBorder,
          unthemed['keybindingLabelBottomBorder']);
      expect(kl.unthemedKeybindingLabelOptions.keybindingLabelShadow,
          unthemed['keybindingLabelShadow']);

      final List<List<Object?>> log = <List<Object?>>[];
      d2.setBaseLayerHoverDelegate(_RecordingHoverDelegate2(log));
      final dom.DomElement container = dom.document.createElement('div');
      final kl.KeybindingLabel label = kl.KeybindingLabel(
        container,
        1,
        kl.KeybindingLabelOptions(
          keybindingLabelBackground: '#111111',
          keybindingLabelForeground: '#222222',
          keybindingLabelBorder: '#333333',
          keybindingLabelBottomBorder: '#444444',
          keybindingLabelShadow: '#555555',
        ),
      );
      final Map<String, dynamic> before = _map(section['before']);
      expect(_snapshot(container), _map(before['container']));
      expect(_snapshot(label.element), _map(before['label']));
      expect(log, _truthLog(before, 'log'));

      final kb.ResolvedKeybinding keybinding = _TestKeybinding(
        <kb.ResolvedChord>[
          kb.ResolvedChord(true, true, false, false, 'K', null),
          kb.ResolvedChord(false, false, true, true, 'M', null),
        ],
        'Ctrl+Shift+K Alt+M',
      );
      final kl.Matches matches = kl.Matches(
        firstPart: kl.ChordMatches(ctrlKey: true, keyCode: true),
        chordPart: kl.ChordMatches(altKey: true),
      );
      label.set(keybinding, matches);
      final Map<String, dynamic> afterSet = _map(section['afterSet']);
      expect(_snapshot(label.element), _map(afterSet['label']));
      expect(log, _truthLog(afterSet, 'log'));

      final dom.DomElement sentinel = dom.document.createElement('i');
      label.element.appendChild(sentinel);
      label.set(keybinding, matches);
      final Map<String, dynamic> afterNoop = _map(section['afterNoop']);
      expect(label.element.childNodes.contains(sentinel), isTrue,
          reason: 'same keybinding/matches must short-circuit before clear()');
      sentinel.remove();
      expect(_snapshot(label.element), _map(afterNoop['label']));
      expect(log, _truthLog(afterNoop, 'log'));
      expect(afterNoop['clearCount'], afterSet['clearCount']);

      final dom.DomElement unboundContainer = dom.document.createElement('div');
      final kl.KeybindingLabel unbound = kl.KeybindingLabel(
        unboundContainer,
        1,
        kl.KeybindingLabelOptions(renderUnboundKeybindings: true),
      );
      unbound.set(null);
      expect(
        _snapshot(unbound.element),
        _map(_map(section['afterUnbound'])['label']),
      );
      expect(log, _truthLog(section['afterUnbound'], 'log'));

      final dom.DomElement disabledContainer = dom.document.createElement('div');
      final kl.KeybindingLabel disabled = kl.KeybindingLabel(
        disabledContainer,
        1,
        kl.KeybindingLabelOptions(disableTitle: true),
      );
      disabled.set(
        _TestKeybinding(
          <kb.ResolvedChord>[
            kb.ResolvedChord(false, false, false, false, 'A', null),
          ],
          'A',
        ),
      );
      expect(
        _snapshot(disabled.element),
        _map(_map(section['afterDisableTitle'])['label']),
      );
      expect(log, _truthLog(section['afterDisableTitle'], 'log'));

      label.dispose();
      expect(log, _truthLog(section['afterDispose'], 'log'));
    });
  });
}
