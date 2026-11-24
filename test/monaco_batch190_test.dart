// Truth replay for batch190: `platform/opener/browser/link.ts`.
//
// Every expectation comes from `tool/ts2dart/batch190_truth.json`, produced by
// `tool/ts2dart/_batch190_truth.cjs`, which executes the real transpiled
// TypeScript for `link.ts` together with the real `event.ts`, `keyboardEvent.ts`
// and `keyCodes.ts`. Only the DOM/hover/opener carriers are deterministic fakes.
import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import '../lib/src/monaco/base/browser/dom.dart' as dom;
import '../lib/src/monaco/base/browser/ui/hover/hover.dart' as hover;
import '../lib/src/monaco/base/browser/ui/hover/hoverDelegate.dart' as delegate;
import '../lib/src/monaco/base/browser/ui/hover/hoverDelegateFactory.dart'
    show getDefaultHoverDelegate;
import '../lib/src/monaco/base/common/lifecycle.dart' as lifecycle;
import '../lib/src/monaco/base/common/uri.dart' show URI;
import '../lib/src/monaco/platform/opener/browser/link.dart' as linkPort;
import '../lib/src/monaco/platform/hover/browser/hover.dart' as hoverService;
import '../lib/src/monaco/platform/opener/common/opener.dart' as opener;

Map<String, dynamic> _map(dynamic value) =>
    (value as Map).cast<String, dynamic>();

List<dynamic> _list(dynamic value) => value as List<dynamic>;

/// Snapshot of a DOM element, mirroring `snapshot()` in the truth harness.
Map<String, Object?> _snapshot(dom.DomElement? el) {
  if (el == null) return <String, Object?>{};
  final Map<String, Object?> attributes = <String, Object?>{
    for (final MapEntry<String, String> entry in el.attributes)
      entry.key: entry.value,
  };
  final Map<String, Object?> style = <String, Object?>{
    for (final String key in el.style.keys) key: el.style[key],
  };
  return <String, Object?>{
    'tagName': el.tagName,
    'className': el.className,
    'tabIndex': el.tabIndex,
    'href': el.href,
    'attributes': attributes,
    'style': style,
    'text': el.textContent,
    'children': <Map<String, Object?>>[
      for (final dom.DomElement child in el.childNodes.whereType<dom.DomElement>())
        <String, Object?>{
          'tagName': child.tagName,
          'className': child.className,
          'text': child.textContent,
        },
    ],
  };
}

class _RecordingManagedHover implements hover.IManagedHover {
  _RecordingManagedHover(this.id, this.log);

  final int id;
  final List<List<Object?>> log;

  @override
  void show([bool? focus]) => log.add(<Object?>['managedShow', id]);

  @override
  void hide() => log.add(<Object?>['managedHide', id]);

  @override
  void update(hover.IManagedHoverContent tooltip,
          [hover.IManagedHoverOptions? options]) =>
      log.add(<Object?>['managedUpdate', id, tooltip]);

  @override
  void dispose() => log.add(<Object?>['managedDispose', id]);
}

class _RecordingHoverService implements hoverService.IHoverServiceType {
  _RecordingHoverService(this.log);

  final List<List<Object?>> log;
  int _nextId = 0;

  @override
  Object? get serviceBrand => null;

  String get _delegateLabel => 'anonymous';

  @override
  hover.IManagedHover setupManagedHover(
    delegate.IHoverDelegate hoverDelegate,
    dom.DomElement targetElement,
    Object? content, [
    hover.IManagedHoverOptions? options,
  ]) {
    final int id = ++_nextId;
    final String label = identical(hoverDelegate, getDefaultHoverDelegate('mouse'))
        ? 'anonymous'
        : (hoverDelegate.placement ?? _delegateLabel);
    log.add(<Object?>[
      'setupManagedHover',
      id,
      label,
      content,
      targetElement.className,
    ]);
    return _RecordingManagedHover(id, log);
  }

  @override
  hover.IHoverWidget? showDelayedHover(
          hover.IHoverOptions options, hover.IHoverLifecycleOptions lifecycleOptions) =>
      null;

  @override
  Object? setupDelayedHover(dom.DomElement target, Object hoverOptions,
          [hover.IHoverLifecycleOptions? lifecycleOptions]) =>
      null;

  @override
  Object? setupDelayedHoverAtMouse(dom.DomElement target, Object hoverOptions,
          [hover.IHoverLifecycleOptions? lifecycleOptions]) =>
      null;

  @override
  hover.IHoverWidget? showInstantHover(hover.IHoverOptions options,
          [bool? focus]) =>
      null;

  @override
  void hideHover([bool? force]) {}

  @override
  void showAndFocusLastHover() {}

  @override
  void showManagedHover(dom.DomElement targetElement) {}

  @override
  hover.IHoverWidget? getStickyHover(dom.DomElement targetElement) => null;
}

class _RecordingOpener implements opener.IOpenerServiceType {
  _RecordingOpener(this.log);

  final List<List<Object?>> log;

  // `IOpenerServiceType._serviceBrand` is library-private in Dart; it cannot be
  // implemented from this library, so it is not declared here (same as the
  // other opener fakes in this suite).
  @override
  Future<bool> open(Object resource, [Object? options]) {
    log.add(<Object?>[
      'open',
      resource,
      options is opener.OpenOptions ? options.allowCommands : null,
    ]);
    return Future<bool>.value(true);
  }

  @override
  Future<opener.IResolvedExternalUri> resolveExternalUri(URI resource,
          [opener.ResolveExternalUriOptions? options]) =>
      throw UnimplementedError('link.ts never resolves external URIs');

  @override
  lifecycle.IDisposable registerOpener(opener.IOpener value) =>
      lifecycle.Disposable.none;

  @override
  lifecycle.IDisposable registerValidator(opener.IValidator value) =>
      lifecycle.Disposable.none;

  @override
  lifecycle.IDisposable registerExternalUriResolver(
          opener.IExternalUriResolver value) =>
      lifecycle.Disposable.none;

  @override
  void setDefaultExternalOpener(opener.IExternalOpener value) {}

  @override
  lifecycle.IDisposable registerExternalOpener(opener.IExternalOpener value) =>
      lifecycle.Disposable.none;
}

Map<String, dynamic> _truth() => _map(
      jsonDecode(
          File('tool/ts2dart/batch190_truth.json').readAsStringSync()),
    );

dom.DomEvent _makeEvent(dom.DomElement el, String type) =>
    dom.DomEvent(type, target: el);

void main() {
  final Map<String, dynamic> truth = _truth();

  test('batch190 construction matches truth element, enabled and hover', () {
    final List<List<Object?>> hoverLog = <List<Object?>>[];
    final List<List<Object?>> openerLog = <List<Object?>>[];
    final dom.DomElement container = dom.document.createElement('div');

    final linkPort.Link link = linkPort.Link(
      container,
      linkPort.ILinkDescriptor(
        label: 'Open',
        href: 'https://example.com/a',
        title: 'A title',
      ),
      linkPort.ILinkOptions(),
      _RecordingHoverService(hoverLog),
      _RecordingOpener(openerLog),
    );

    final Map<String, dynamic> expected = _map(truth['construction']);
    expect(_snapshot(container.childNodes.whereType<dom.DomElement>().first),
        _map(expected['element']));
    expect(link.enabled, expected['enabled']);
    expect(hoverLog, _list(expected['hoverLog']));
    expect(openerLog, isEmpty);

    link.dispose();
    // Behavioural equivalent of the harness listener-count check: after
    // dispose the click listener is gone, so nothing opens.
    container
        .childNodes
        .whereType<dom.DomElement>()
        .first
        .dispatchEvent('click', _makeEvent(container.childNodes.whereType<dom.DomElement>().first, 'click'));
    expect(openerLog, isEmpty);
  });

  test('batch190 element label, custom opener and tabIndex match truth', () {
    final List<List<Object?>> hoverLog = <List<Object?>>[];
    final List<List<Object?>> openerLog = <List<Object?>>[];
    final List<String> opened = <String>[];
    final dom.DomElement container = dom.document.createElement('div');
    final dom.DomElement labelEl = dom.$('span.label-text', null, <Object>['Custom']);

    final linkPort.Link link = linkPort.Link(
      container,
      linkPort.ILinkDescriptor(
        label: labelEl,
        href: 'https://example.com/b',
        tabIndex: 7,
      ),
      linkPort.ILinkOptions(
        opener: opened.add,
        textLinkForeground: '#ff0000',
      ),
      _RecordingHoverService(hoverLog),
      _RecordingOpener(openerLog),
    );

    final Map<String, dynamic> expected = _map(truth['constructionElement']);
    final dom.DomElement el = container.childNodes.whereType<dom.DomElement>().first;
    expect(_snapshot(el), _map(expected['element']));
    expect(link.enabled, expected['enabled']);
    expect(hoverLog, _list(expected['hoverLog']));

    el.dispatchEvent('click', _makeEvent(el, 'click'));
    expect(opened, _list(expected['clickOpened']));
    expect(openerLog, isEmpty);

    link.dispose();
  });

  test('batch190 enabled setter matches truth for every transition', () {
    final dom.DomElement container = dom.document.createElement('div');
    final linkPort.Link link = linkPort.Link(
      container,
      linkPort.ILinkDescriptor(
        label: 'Toggle',
        href: 'https://example.com/c',
      ),
      linkPort.ILinkOptions(),
      _RecordingHoverService(<List<Object?>>[]),
      _RecordingOpener(<List<Object?>>[]),
    );
    final dom.DomElement el = container.childNodes.whereType<dom.DomElement>().first;

    for (final dynamic rawStep in _list(truth['enabledToggle'])) {
      final Map<String, dynamic> step = _map(rawStep);
      link.enabled = step['set'] as bool;
      expect(link.enabled, step['enabled'], reason: 'enabled after set ${step['set']}');
      expect(_snapshot(el), _map(step['element']),
          reason: 'element after set ${step['set']}');
    }

    link.dispose();
  });

  test('batch190 link setter matches truth for label/href/tooltip updates', () {
    final List<List<Object?>> hoverLog = <List<Object?>>[];
    final dom.DomElement container = dom.document.createElement('div');
    final linkPort.Link link = linkPort.Link(
      container,
      linkPort.ILinkDescriptor(
        label: 'First',
        href: 'https://example.com/1',
        title: 'One',
      ),
      linkPort.ILinkOptions(),
      _RecordingHoverService(hoverLog),
      _RecordingOpener(<List<Object?>>[]),
    );
    final dom.DomElement el = container.childNodes.whereType<dom.DomElement>().first;

    final List<dynamic> steps = _list(truth['linkSetter']);
    final Map<String, dynamic> step1 = _map(steps[0]);
    link.link = linkPort.ILinkDescriptor(
      label: 'Second',
      href: 'https://example.com/2',
      title: 'Two',
    );
    expect(_snapshot(el), _map(step1['element']), reason: 'string->string');
    expect(hoverLog, _list(step1['hoverLog']), reason: 'string->string hover');

    final Map<String, dynamic> step2 = _map(steps[1]);
    link.link = linkPort.ILinkDescriptor(
      label: dom.$('span.rich', null, <Object>['Rich']),
      href: 'https://example.com/3',
    );
    expect(_snapshot(el), _map(step2['element']), reason: 'string->element');
    expect(hoverLog, _list(step2['hoverLog']), reason: 'string->element hover');

    final Map<String, dynamic> step3 = _map(steps[2]);
    link.link = linkPort.ILinkDescriptor(
      label: 'Fourth',
      href: 'https://example.com/4',
      title: 'Four',
      tabIndex: 3,
    );
    expect(_snapshot(el), _map(step3['element']), reason: 'element->string');
    expect(hoverLog, _list(step3['hoverLog']), reason: 'element->string hover');

    link.dispose();
  });

  test('batch190 activation matrix matches truth', () {
    final List<List<Object?>> openerLog = <List<Object?>>[];
    final dom.DomElement container = dom.document.createElement('div');
    final linkPort.Link link = linkPort.Link(
      container,
      linkPort.ILinkDescriptor(
        label: 'Act',
        href: 'https://example.com/act',
      ),
      linkPort.ILinkOptions(),
      _RecordingHoverService(<List<Object?>>[]),
      _RecordingOpener(openerLog),
    );
    final dom.DomElement el = container.childNodes.whereType<dom.DomElement>().first;

    // The real DOM shares one event object between the listener payload and
    // `StandardKeyboardEvent`; the carriers are separate objects, so the
    // prevented/stopped flags are wired back to the dispatched event.
    dom.DomKeyboardEvent keyboardEvent(String type, int keyCode) {
      final dom.DomKeyboardEvent event = dom.DomKeyboardEvent(type)
        ..keyCode = keyCode;
      event.preventDefaultFn = () => event.defaultPrevented = true;
      event.stopPropagationFn = () => event.cancelBubble = true;
      return event;
    }

    void fire(String kind, String type, dom.DomEvent event) {
      final Map<String, dynamic> expected = _map(
        _list(truth['activation'])
            .map((dynamic c) => _map(c))
            .firstWhere((Map<String, dynamic> c) => c['kind'] == kind),
      );
      final int before = openerLog.length;
      el.dispatchEvent(type, event);
      expect(openerLog.sublist(before), _list(expected['opened']),
          reason: '$kind opened');
      expect(event.defaultPrevented, expected['prevented'],
          reason: '$kind prevented');
      expect(event.cancelBubble, expected['stopped'], reason: '$kind stopped');
    }

    fire('click', 'click', _makeEvent(el, 'click'));
    fire('keydown:Enter', 'keydown',
        keyboardEvent(dom.EventType.KEY_DOWN, 13));
    fire('keydown:Space', 'keydown',
        keyboardEvent(dom.EventType.KEY_DOWN, 32));
    fire('keydown:A', 'keydown', keyboardEvent(dom.EventType.KEY_DOWN, 65));
    final dom.DomEvent tap = dom.DomEvent('-monaco-gesturetap', target: el);
    fire('tap', '-monaco-gesturetap', tap);

    link.enabled = false;
    fire('click:disabled', 'click', _makeEvent(el, 'click'));
    fire('keydown:Enter:disabled', 'keydown',
        keyboardEvent(dom.EventType.KEY_DOWN, 13));

    link.enabled = true;
    fire('click:re-enabled', 'click', _makeEvent(el, 'click'));

    link.dispose();
    fire('click:afterDispose', 'click', _makeEvent(el, 'click'));

    // Every successful activation forwarded `allowCommands: true`.
    expect(
      openerLog.map((List<Object?> entry) => entry[2]).toSet(),
      <Object?>{true},
    );
  });
}