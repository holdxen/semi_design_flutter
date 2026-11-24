import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import '../lib/src/monaco/base/browser/dom.dart' as dom;
import '../lib/src/monaco/base/browser/ui/hover/hover.dart' as h;
import '../lib/src/monaco/base/browser/ui/hover/hoverDelegate.dart' as d;
import '../lib/src/monaco/base/browser/ui/hover/hoverDelegate2.dart' as d2;
import '../lib/src/monaco/base/browser/ui/iconLabel/iconLabel.dart' as il;
import '../lib/src/monaco/base/common/codicons.dart' as codicons;
import '../lib/src/monaco/base/common/filters.dart' as filters;
import '../lib/src/monaco/base/common/themables.dart' as themables;
import '../lib/src/monaco/base/common/uri.dart' as uri;

Map<String, dynamic> _map(dynamic value) =>
    (value as Map).cast<String, dynamic>();

List<dynamic> _list(dynamic value) => value as List<dynamic>;

List<dynamic> _truthLog(Map<String, dynamic> section, String key) => _list(
      section[key],
    ).where((dynamic entry) => (entry as List)[0] != 'disposableDispose').toList();

String _escapeHtml(String value) => value
    .replaceAll('&', '&amp;')
    .replaceAll('<', '&lt;')
    .replaceAll('>', '&gt;')
    .replaceAll('"', '&quot;');

String _innerHtml(dom.DomElement element) {
  final StringBuffer out = StringBuffer();
  for (final dom.DomNode child in element.childNodes) {
    if (child is dom.DomTextNode) {
      out.write(_escapeHtml(child.data));
    } else if (child is dom.DomElement) {
      final String className =
          child.className.isEmpty ? '' : ' class="${child.className}"';
      final String attrs = child.attributes
          .map((MapEntry<String, String> e) => ' ${e.key}="${e.value}"')
          .join();
      out.write('<${child.localName}$className$attrs>${_innerHtml(child)}'
          '</${child.localName}>');
    }
  }
  return out.toString();
}

Map<String, Object?> _style(dom.DomElement element) =>
    <String, Object?>{for (final String key in element.style.keys) key: element.style[key]};

Map<String, Object?> _attributes(dom.DomElement element) =>
    <String, Object?>{for (final MapEntry<String, String> e in element.attributes) e.key: e.value};

Map<String, Object?> _snapshot(dom.DomElement element) => <String, Object?>{
      'tagName': element.localName,
      'className': element.className,
      'id': element.getAttribute('id'),
      'attributes': _attributes(element),
      'style': _style(element),
      'text': element.textContent,
      'innerHTML': _innerHtml(element),
      'children': element.childNodes
          .whereType<dom.DomElement>()
          .map(_snapshot)
          .toList(),
    };

dom.DomElement? _descendant(dom.DomElement root, String selector) {
  if (!selector.startsWith('.')) return null;
  final String className = selector.substring(1);
  for (final dom.DomNode child in root.childNodes) {
    if (child is! dom.DomElement) continue;
    if (child.classList.contains(className)) return child;
    final dom.DomElement? found = _descendant(child, selector);
    if (found != null) return found;
  }
  return null;
}

List<dom.DomElement> _ancestors(dom.DomElement element) {
  final List<dom.DomElement> out = <dom.DomElement>[];
  dom.DomNode? current = element.parentNode;
  while (current != null) {
    if (current is dom.DomElement) out.add(current);
    current = current.parentNode;
  }
  return out;
}

Map<String, Object?> _styleState(dom.DomElement root) {
  final dom.DomElement label = <dom.DomElement>[root, ..._ancestors(root)].firstWhere(
    (dom.DomElement e) => e.classList.contains('monaco-icon-label'),
    orElse: () => root,
  );
  return <String, Object?>{
    'italic': label.classList.contains('italic'),
    'strikethrough': label.classList.contains('strikethrough'),
    'bold': label.classList.contains('bold'),
  };
}

String _computedColor(dom.DomElement element, [String? pseudo]) {
  final List<dom.DomElement> chain = <dom.DomElement>[element, ..._ancestors(element)];
  final dom.DomElement label = chain.firstWhere(
    (dom.DomElement e) => e.classList.contains('monaco-icon-label'),
    orElse: () => element,
  );
  String color = 'rgb(0, 0, 0)';
  for (final dom.DomElement node in chain.reversed) {
    final String own = node.style.getPropertyValue('color');
    if (own.isNotEmpty) color = own;
  }
  final bool colored = label.classList.contains('colored-icon');
  if ((pseudo == '::before' ||
          chain.any((dom.DomElement e) =>
              e.classList.contains('monaco-icon-label-iconpath'))) &&
      colored) {
    final String own = label.style.getPropertyValue('--monaco-icon-label-icon-color');
    if (own.isNotEmpty) color = own;
  }
  return color;
}

String _animationName(dom.DomElement element) {
  final List<dom.DomElement> chain = <dom.DomElement>[element, ..._ancestors(element)];
  final bool reduceMotion =
      chain.any((dom.DomElement e) => e.classList.contains('monaco-reduce-motion'));
  if (element.classList.contains('codicon-modifier-spin') && !reduceMotion) {
    return 'codicon-spin';
  }
  return 'none';
}

class _RecordingManagedHover implements h.IManagedHover {
  _RecordingManagedHover(this.log, this.id);

  final List<List<Object?>> log;
  final int id;

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
    log.add(<Object?>['managedDispose', id]);
  }
}

class _RecordingHoverDelegate2 implements h.IHoverDelegate2 {
  _RecordingHoverDelegate2(this.log);

  final List<List<Object?>> log;
  int _nextId = 1;

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
      null;

  @override
  Object? setupDelayedHoverAtMouse(
    dom.DomElement target,
    Object hoverOptions, [
    h.IHoverLifecycleOptions? lifecycleOptions,
  ]) =>
      null;

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
    final int id = _nextId++;
    log.add(<Object?>[
      'setupManagedHover',
      id,
      hoverDelegate is _TestHoverDelegate ? hoverDelegate.tag : 'delegate',
      targetElement.className.isEmpty ? 'target' : targetElement.className,
      content,
      options == null ? null : 'options',
    ]);
    return _RecordingManagedHover(log, id);
  }

  @override
  void showManagedHover(dom.DomElement targetElement) {}
}

class _TestHoverDelegate implements d.IScopedHoverDelegate {
  _TestHoverDelegate(this.tag);

  final String tag;

  @override
  h.IHoverWidget? showHover(d.IHoverDelegateOptions options, [bool? focus]) => null;

  @override
  void Function()? onDidHideHover;

  @override
  Object get delay => 0;

  @override
  String? get placement => 'mouse';

  @override
  bool? get showNativeHover => null;

  @override
  void dispose() {}
}

void main() {
  final Map<String, dynamic> truth = _map(
    jsonDecode(File('tool/ts2dart/batch186_truth.json').readAsStringSync()),
  );

  group('batch186 iconLabel official truth', () {
    for (final dynamic rawCase in _list(truth['official'])) {
      final Map<String, dynamic> testCase = _map(rawCase);
      final String name = testCase['name'] as String;
      final Map<String, dynamic> assertion = _map(
        _list(testCase['assertions']).first as Map,
      );
      final dynamic expected = assertion['expected'];

      test(name, () {
        final List<List<Object?>> log = <List<Object?>>[];
        d2.setBaseLayerHoverDelegate(_RecordingHoverDelegate2(log));
        final d.IHoverDelegate delegate = _TestHoverDelegate('testDelegate');
        Object? actual;

        if (name.startsWith('name, suffix and description share state styles')) {
          final bool supportHighlights = name.endsWith('(highlights: true)');
          final List<Object?> states = <Object?>[];
          for (final il.IIconLabelValueOptions options in <il.IIconLabelValueOptions>[
            il.IIconLabelValueOptions(italic: true),
            il.IIconLabelValueOptions(strikethrough: true),
            il.IIconLabelValueOptions(bold: true),
            il.IIconLabelValueOptions(),
          ]) {
            final dom.DomElement container = dom.document.createElement('div');
            final il.IconLabel label = il.IconLabel(
              container,
              il.IIconLabelCreationOptions(
                supportHighlights: supportHighlights,
                supportDescriptionHighlights: supportHighlights,
                hoverDelegate: delegate,
              ),
            );
            label.setLabel('filename', 'description', il.IIconLabelValueOptions(
              title: options.title,
              suffix: '.ts',
              italic: options.italic,
              strikethrough: options.strikethrough,
              bold: options.bold,
            ));
            states.add(<Object?>[
              _styleState(_descendant(label.element, '.label-name')!),
              _styleState(_descendant(label.element, '.label-suffix')!),
              _styleState(_descendant(label.element, '.label-description')!),
            ]);
          }
          actual = states;
        } else if (name.startsWith('its icon takes the color')) {
          final dom.DomElement container = dom.document.createElement('div');
          container.style.setProperty('color', 'rgb(0, 0, 255)');
          final il.IconLabel label =
              il.IconLabel(container, il.IIconLabelCreationOptions(hoverDelegate: delegate));
          label.setLabel('name', null, il.IIconLabelValueOptions(iconColor: 'rgb(255, 0, 0)'));
          final String colored = _computedColor(label.element, '::before');
          label.setLabel('name', null, il.IIconLabelValueOptions());
          final String uncolored = _computedColor(label.element, '::before');
          actual = <String, Object?>{'colored': colored, 'uncolored': uncolored};
        } else if (name.startsWith('a theme icon of its own')) {
          final dom.DomElement container = dom.document.createElement('div');
          final il.IconLabel label =
              il.IconLabel(container, il.IIconLabelCreationOptions(hoverDelegate: delegate));
          label.setLabel('name', null, il.IIconLabelValueOptions(
            iconPath: themables.ThemeIcon.modify(codicons.Codicon['loading']!, 'spin'),
            iconColor: 'rgb(255, 0, 0)',
          ));
          final dom.DomElement icon =
              _descendant(label.element, '.monaco-icon-label-iconpath')!;
          final Object? iconSpins = icon.classList.contains('codicon-modifier-spin')
              ? _animationName(icon)
              : false;
          actual = <String, Object?>{
            'iconSpins': iconSpins,
            'labelSpins': _animationName(label.element),
            'iconColor': _computedColor(icon),
          };
        } else if (name.startsWith('an icon of its own that shows an image')) {
          final dom.DomElement container = dom.document.createElement('div');
          final il.IconLabel label =
              il.IconLabel(container, il.IIconLabelCreationOptions(hoverDelegate: delegate));
          label.setLabel('chat', null, il.IIconLabelValueOptions(
            iconPath: themables.ThemeIcon.modify(codicons.Codicon['loading']!, 'spin'),
          ));
          label.setLabel('page', null, il.IIconLabelValueOptions(
            iconPath: uri.URI.parse(
              'data:image/svg+xml;utf8,<svg xmlns="http://www.w3.org/2000/svg"/>',
            ),
          ));
          final dom.DomElement icon =
              _descendant(label.element, '.monaco-icon-label-iconpath')!;
          actual = <String, Object?>{
            'classes': icon.className.split(RegExp(r'\s+')),
            'animation': _animationName(icon),
            'image': icon.style.getPropertyValue('backgroundImage').startsWith('url('),
          };
        } else if (name.startsWith('a spinning icon of its own stands still')) {
          final dom.DomElement container = dom.document.createElement('div')
            ..classList.add('monaco-reduce-motion');
          final il.IconLabel label =
              il.IconLabel(container, il.IIconLabelCreationOptions(hoverDelegate: delegate));
          label.setLabel('chat', null, il.IIconLabelValueOptions(
            iconPath: themables.ThemeIcon.modify(codicons.Codicon['loading']!, 'spin'),
          ));
          actual = _animationName(
            _descendant(label.element, '.monaco-icon-label-iconpath')!,
          );
        } else {
          fail('unexpected official case: $name');
        }

        expect(
          actual,
          equals(expected),
          reason: 'official TS assertion: ${assertion['kind'] ?? ''}',
        );
        for (final dynamic assertion in _list(testCase['assertions'])) {
          expect(_map(assertion)['pass'], isTrue);
        }
      });
    }
  });

  group('batch186 iconLabel custom truth', () {
    final Map<String, dynamic> custom = _map(truth['custom']);
    final List<List<Object?>> log = <List<Object?>>[];
    final _RecordingHoverDelegate2 delegate = _RecordingHoverDelegate2(log);
    final d.IHoverDelegate hoverDelegate = _TestHoverDelegate('testDelegate');

    setUp(() {
      d2.setBaseLayerHoverDelegate(delegate);
    });

    test('exports and constructor structure', () {
      expect(custom['exports'], equals(<String>['IconLabel']));
      final dom.DomElement container = dom.document.createElement('div');
      final il.IconLabel label = il.IconLabel(
        container,
        il.IIconLabelCreationOptions(
          supportHighlights: true,
          supportDescriptionHighlights: true,
          hoverDelegate: hoverDelegate,
        ),
      );
      expect(_snapshot(container), equals(_map(custom['constructor'])['container']));
      expect(_snapshot(label.element), equals(_map(custom['constructor'])['element']));
      expect(log, isEmpty);
      label.dispose();
    });

    test('shared style states and hover targets', () {
      log.clear();
      final dom.DomElement container = dom.document.createElement('div');
      final il.IconLabel label = il.IconLabel(
        container,
        il.IIconLabelCreationOptions(
          supportHighlights: false,
          hoverDelegate: hoverDelegate,
        ),
      );
      label.setLabel('filename', 'description', il.IIconLabelValueOptions(
        extraClasses: <String>['extra-a', 'extra-b'],
        bold: true,
        italic: true,
        strikethrough: true,
        disabledCommand: true,
        title: 'Title text',
        descriptionTitle: 'Description title',
        suffix: '.ts',
        domId: 'node-id',
        separator: '|',
        iconColor: 'rgb(255, 0, 0)',
      ));
      final Map<String, dynamic> section = _map(custom['states']);
      expect(_snapshot(label.element), equals(section['tree']));
      expect(
        <Object?>[
          _styleState(_descendant(label.element, '.label-name')!),
          _styleState(_descendant(label.element, '.label-suffix')!),
          _styleState(_descendant(label.element, '.label-description')!),
        ],
        equals(section['states']),
      );
      expect(_truthLog(section, 'log'), equals(log));
    });

    test('highlighted label with icons', () {
      log.clear();
      final dom.DomElement container = dom.document.createElement('div');
      final il.IconLabel label = il.IconLabel(
        container,
        il.IIconLabelCreationOptions(
          supportHighlights: true,
          hoverDelegate: hoverDelegate,
        ),
      );
      label.setLabel(r'a$(zap)b', null, il.IIconLabelValueOptions(
        matches: <filters.IMatch>[filters.IMatch(1, 7)],
        domId: 'hl',
        labelEscapeNewLines: true,
        supportIcons: true,
        title: 'hl',
      ));
      final Map<String, dynamic> section = _map(custom['highlighted']);
      expect(_snapshot(label.element), equals(section['tree']));
      expect(_truthLog(section, 'log'), equals(log));
    });

    test('multiple labels and split matches', () {
      log.clear();
      final il.IconLabel plain = il.IconLabel(
        dom.document.createElement('div'),
        il.IIconLabelCreationOptions(hoverDelegate: hoverDelegate),
      );
      plain.setLabel(<String>['a', 'bb'], null, il.IIconLabelValueOptions(
        separator: '/',
        domId: 'multi',
      ));
      final Map<String, dynamic> section = _map(custom['multiplePlain']);
      expect(_snapshot(plain.element), equals(section['tree']));
      expect(_truthLog(section, 'log'), equals(log));

      log.clear();
      final il.IconLabel highlighted = il.IconLabel(
        dom.document.createElement('div'),
        il.IIconLabelCreationOptions(
          supportHighlights: true,
          supportDescriptionHighlights: true,
          hoverDelegate: hoverDelegate,
        ),
      );
      highlighted.setLabel(<String>['ab', 'cd'], null, il.IIconLabelValueOptions(
        separator: '::',
        matches: <filters.IMatch>[filters.IMatch(1, 4), filters.IMatch(3, 6)],
        descriptionMatches: <filters.IMatch>[filters.IMatch(0, 2)],
        domId: 'hm',
        labelEscapeNewLines: false,
      ));
      final Map<String, dynamic> highlightedTruth = _map(custom['multipleHighlighted']);
      expect(_snapshot(highlighted.element), equals(highlightedTruth['tree']));
      expect(_truthLog(highlightedTruth, 'log'), equals(log));
    });

    test('theme icon, URI icon and icon removal', () {
      log.clear();
      final il.IconLabel label = il.IconLabel(
        dom.document.createElement('div'),
        il.IIconLabelCreationOptions(hoverDelegate: hoverDelegate),
      );
      Map<String, Object?> iconInfo() {
        final dom.DomElement? icon =
            _descendant(label.element, '.monaco-icon-label-iconpath');
        if (icon == null) return <String, Object?>{};
        final String background = icon.style.getPropertyValue('backgroundImage');
        return <String, Object?>{
          'className': icon.className,
          'backgroundImageIsUrl': background.startsWith('url('),
          'backgroundRepeat': icon.style.getPropertyValue('backgroundRepeat'),
          'backgroundPosition': icon.style.getPropertyValue('backgroundPosition'),
          'backgroundSize': icon.style.getPropertyValue('backgroundSize'),
        };
      }

      label.setLabel('chat', null, il.IIconLabelValueOptions(
        iconPath: themables.ThemeIcon.modify(codicons.Codicon['loading']!, 'spin'),
      ));
      final Map<String, dynamic> theme = _map(
        _map(custom['iconPath'])['theme'] as Map,
      );
      expect(_snapshotIconInfo(iconInfo()), equals(_projectIconInfo(theme)));

      label.setLabel('page', null, il.IIconLabelValueOptions(
        iconPath: uri.URI.parse(
          'data:image/svg+xml;utf8,<svg xmlns="http://www.w3.org/2000/svg"/>',
        ),
      ));
      final Map<String, dynamic> uriIcon = _map(
        _map(custom['iconPath'])['uri'] as Map,
      );
      expect(_snapshotIconInfo(iconInfo()), equals(_projectIconInfo(uriIcon)));

      label.setLabel('plain', null, il.IIconLabelValueOptions());
      expect(_map(custom['iconPath'])['removed'], isNull);
      final Map<String, dynamic> section = _map(custom['iconPath']);
      expect(_snapshot(label.element), equals(section['tree']));
      expect(_truthLog(section, 'log'), equals(log));
    });

    test('hover target override, replacement and disposal', () {
      log.clear();
      final dom.DomElement outer = dom.document.createElement('div');
      final dom.DomElement container = dom.document.createElement('div');
      outer.appendChild(container);
      final il.IconLabel label = il.IconLabel(
        container,
        il.IIconLabelCreationOptions(
          hoverDelegate: hoverDelegate,
          hoverTargetOverride: outer,
        ),
      );
      label.setLabel('one', null, il.IIconLabelValueOptions(title: 'first'));
      label.setLabel('two', null, il.IIconLabelValueOptions(title: 'second'));
      final Map<String, dynamic> overrideOk =
          _map(_map(custom['hover'])['overrideOk'] as Map);
      expect(_truthLog(overrideOk, 'log'), equals(log));

      log.clear();
      final dom.DomElement badOuter = dom.document.createElement('div');
      final dom.DomElement badContainer = dom.document.createElement('div');
      final il.IconLabel badLabel = il.IconLabel(
        badContainer,
        il.IIconLabelCreationOptions(
          hoverDelegate: hoverDelegate,
          hoverTargetOverride: badOuter,
        ),
      );
      Object? error;
      try {
        badLabel.setLabel('x', null, il.IIconLabelValueOptions(title: 'boom'));
      } catch (e) {
        error = e.toString().replaceFirst('Bad state: ', '');
      }
      final Map<String, dynamic> overrideError =
          _map(_map(custom['hover'])['overrideError'] as Map);
      expect(error, equals(overrideError['error']));
      expect(_truthLog(overrideError, 'log'), equals(log));

      log.clear();
      label.dispose();
      final Map<String, dynamic> disposal =
          _map(_map(custom['hover'])['disposal'] as Map);
      expect(_truthLog(disposal, 'log'), equals(log));
    });
  });
}

Map<String, Object?> _projectIconInfo(Map<String, dynamic> truth) =>
    <String, Object?>{
      'className': truth['className'],
      'backgroundImageIsUrl': truth['backgroundImageIsUrl'],
      'backgroundRepeat': truth['backgroundRepeat'],
      'backgroundPosition': truth['backgroundPosition'],
      'backgroundSize': truth['backgroundSize'],
    };

Map<String, Object?> _snapshotIconInfo(Map<String, Object?> actual) =>
    <String, Object?>{
      for (final String key in <String>[
        'className',
        'backgroundImageIsUrl',
        'backgroundRepeat',
        'backgroundPosition',
        'backgroundSize',
      ])
        key: actual[key],
    };
