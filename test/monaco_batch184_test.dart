import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import '../lib/src/monaco/base/browser/dom.dart' as dom;
import '../lib/src/monaco/base/browser/ui/countBadge/countBadge.dart' as cb;
import '../lib/src/monaco/base/browser/ui/hover/hover.dart' as h;
import '../lib/src/monaco/base/browser/ui/hover/hoverDelegate.dart' as d;
import '../lib/src/monaco/base/browser/ui/hover/hoverDelegate2.dart' as d2;
import '../lib/src/monaco/base/browser/ui/toggle/switch.dart' as sw;
import '../lib/src/monaco/base/common/lifecycle.dart' as lifecycle;
import '../lib/src/monaco/platform/hover/browser/hover.dart' as ph;
import '../lib/src/monaco/platform/hover/browser/updatableHoverWidget.dart' as uh;
import '../lib/src/monaco/platform/hover/test/browser/nullHoverService.dart' as nh;

Map<String, dynamic> _map(dynamic value) => (value as Map).cast<String, dynamic>();

List<dynamic> _list(dynamic value) => value as List<dynamic>;

/// JS object literals only carry keys that were explicitly set. The Dart
/// carriers declare all option fields as nullable, so omit nulls when
/// replaying truth snapshots.
Map<String, Object?> _appearanceMap(h.IHoverAppearanceOptions? value) {
  final Map<String, Object?> result = <String, Object?>{};
  if (value == null) return result;
  if (value.showPointer != null) result['showPointer'] = value.showPointer;
  if (value.compact != null) result['compact'] = value.compact;
  if (value.showHoverHint != null) result['showHoverHint'] = value.showHoverHint;
  if (value.skipFadeInAnimation != null) {
    result['skipFadeInAnimation'] = value.skipFadeInAnimation;
  }
  if (value.maxHeightRatio != null) result['maxHeightRatio'] = value.maxHeightRatio;
  return result;
}

Map<String, Object?> _persistenceMap(h.IHoverPersistenceOptions? value) {
  final Map<String, Object?> result = <String, Object?>{};
  if (value == null) return result;
  if (value.hideOnHover != null) result['hideOnHover'] = value.hideOnHover;
  if (value.hideOnKeyDown != null) result['hideOnKeyDown'] = value.hideOnKeyDown;
  if (value.sticky != null) result['sticky'] = value.sticky;
  return result;
}

Map<String, Object?> _positionMap(h.IHoverPositionOptions? value) {
  final Map<String, Object?> result = <String, Object?>{};
  if (value == null) return result;
  if (value.hoverPosition != null) result['hoverPosition'] = value.hoverPosition;
  if (value.anchorAlignment != null) {
    result['anchorAlignment'] = value.anchorAlignment;
  }
  if (value.forcePosition != null) result['forcePosition'] = value.forcePosition;
  return result;
}

/// The TypeScript truth harness logs lifecycle internals (`mutableValue`,
/// `ctsDispose`, `disposableDispose`) that have no Dart carrier-level hook.
/// Drop only those entries; every behavioral entry is replayed verbatim.
List<dynamic> _truthLog(
  Map<String, dynamic> section,
  String key, [
  Set<String> drop = const <String>{
    'mutableValue',
    'ctsDispose',
    'disposableDispose',
  },
]) =>
    _list(section[key])
        .where((dynamic entry) => !drop.contains((entry as List)[0] as String))
        .toList();

class _LoggedDisposable implements lifecycle.IDisposable {
  _LoggedDisposable(this.log, this.kind);

  final List<List<Object?>> log;
  final String kind;
  bool disposed = false;

  @override
  void dispose() {
    if (disposed) return;
    disposed = true;
    log.add(<Object?>[kind]);
  }
}

class _ManagedHover implements h.IManagedHover {
  const _ManagedHover();

  @override
  void show([bool? focus]) {}

  @override
  void hide() {}

  @override
  void update(Object? tooltip, [h.IManagedHoverOptions? options]) {}

  @override
  void dispose() {}
}

/// Base-layer delegate used by CountBadge and Switch. It records the options
/// factory passed by the source and exposes `invokeLast()` so a count/title
/// update can be observed without a real hover service.
class _OptionsHoverDelegate2 implements h.IHoverDelegate2 {
  _OptionsHoverDelegate2(
    this.log, {
    required this.setupKind,
    required this.disposeKind,
  });

  final List<List<Object?>> log;
  final String setupKind;
  final String disposeKind;

  Object Function()? lastFactory;
  _LoggedDisposable? current;

  Map<String, Object?> _hoverOptions(Object? options) =>
      (options as Map).cast<String, Object?>();

  List<Object?> _project(Object? options) {
    final Map<String, Object?> map = _hoverOptions(options);
    return <Object?>[
      map['content'],
      map['style'],
      map['appearance'],
    ];
  }

  Object? _setup(Object options) {
    // The source passes a zero-argument options factory, which the JS harness
    // invokes with `{}`. Keep the same closure so later count/title changes are
    // observed through the live factory.
    final Object Function() factory = options as Object Function();
    final List<Object?> projected = _project(factory());
    log.add(<Object?>[
      setupKind,
      projected[0],
      projected[1],
      projected[2],
    ]);
    lastFactory = factory;
    current = _LoggedDisposable(log, disposeKind);
    return current;
  }

  void invokeLast() {
    final Object Function()? factory = lastFactory;
    if (factory == null) return;
    final List<Object?> projected = _project(factory());
    log.add(<Object?>['invokeLast', projected[0], projected[1], projected[2]]);
  }

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
      _setup(hoverOptions);

  @override
  Object? setupDelayedHoverAtMouse(
    dom.DomElement target,
    Object hoverOptions, [
    h.IHoverLifecycleOptions? lifecycleOptions,
  ]) =>
      _setup(hoverOptions);

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
  ]) =>
      const _ManagedHover();

  @override
  void showManagedHover(dom.DomElement targetElement) {}
}

class _RecordingHoverWidget implements h.IHoverWidget {
  _RecordingHoverWidget(this.log);

  final List<List<Object?>> log;
  bool _isDisposed = false;

  @override
  bool get isDisposed => _isDisposed;

  @override
  void dispose() {
    if (_isDisposed) return;
    _isDisposed = true;
    log.add(<Object?>['widgetDispose']);
  }
}

Object? _projectContent(Object? content) {
  if (content is dom.DomElement) {
    return <String, Object?>{
      'tagName': content.tagName,
      'textContent': content.textContent,
    };
  }
  return content;
}

class _RecordingHoverDelegate implements d.IHoverDelegate {
  _RecordingHoverDelegate(this.log, this.widgets);

  final List<List<Object?>> log;
  final List<_RecordingHoverWidget> widgets;

  @override
  h.IHoverWidget? showHover(d.IHoverDelegateOptions options, [bool? focus]) {
    final _RecordingHoverWidget widget = _RecordingHoverWidget(log);
    widgets.add(widget);
    final d.IHoverDelegateTarget target = options.target as d.IHoverDelegateTarget;
    log.add(<Object?>[
      'showHover',
      _projectContent(options.content),
      focus,
      options.trapFocus,
      options.additionalClasses ?? <String>[],
      _appearanceMap(options.appearance),
      _positionMap(options.position),
      target.targetElements.length,
      target.x,
    ]);
    return widget;
  }

  @override
  void Function()? onDidHideHover;

  @override
  Object get delay => 0;

  @override
  String? get placement => 'element';

  @override
  bool? get showNativeHover => null;
}

class _ConfigChangeEvent {
  const _ConfigChangeEvent(this.affects);

  final bool affects;

  bool affectsConfiguration(String key) =>
      affects && key == 'workbench.hover.delay';
}

class _TestConfigurationService {
  num delay = 300;
  final List<void Function(Object event)> listeners =
      <void Function(Object event)>[];

  Object? getValue$1(String section) => delay;

  lifecycle.IDisposable onDidChangeConfiguration(
    void Function(Object event) listener,
  ) {
    listeners.add(listener);
    return lifecycle.Disposable.none;
  }

  void fire(bool affectsHoverDelay) {
    final _ConfigChangeEvent event = _ConfigChangeEvent(affectsHoverDelay);
    for (final void Function(Object event) listener in listeners) {
      listener(event);
    }
  }
}

class _TestHoverService {
  _TestHoverService(this.log);

  final List<List<Object?>> log;
  final List<Map<String, Object?>> captured = <Map<String, Object?>>[];
  int hideCalls = 0;

  void hideHover([bool? force]) {
    hideCalls++;
    log.add(<Object?>['hideHover']);
  }

  h.IHoverWidget showInstantHover(h.IHoverOptions options, [bool? focus]) {
    captured.add(<String, Object?>{
      'content': options.content,
      'id': options.id,
      'persistence': _persistenceMap(options.persistence),
      'appearance': _appearanceMap(options.appearance),
      'focus': focus,
      'targetIsElement': dom.isHTMLElement(options.target),
      'targetCount': dom.isHTMLElement(options.target)
          ? null
          : (options.target as dynamic).targetElements.length as Object?,
    });
    return _RecordingHoverWidget(log);
  }
}

void main() {
  final Map<String, dynamic> truth = _map(
    jsonDecode(File('tool/ts2dart/batch184_truth.json').readAsStringSync()),
  );

  group('batch184 countBadge truth', () {
    test('exports, styles, initial render and hover disposal match truth', () {
      final Map<String, dynamic> section = _map(truth['countBadge']);
      expect(_list(section['exports']), <String>[
        'CountBadge',
        'unthemedCountStyles',
      ]);

      final Map<String, dynamic> styles = _map(section['unthemedStyles']);
      expect(cb.unthemedCountStyles.badgeBackground, styles['badgeBackground']);
      expect(cb.unthemedCountStyles.badgeForeground, styles['badgeForeground']);
      expect(cb.unthemedCountStyles.badgeBorder, styles['badgeBorder']);

      final List<List<Object?>> log = <List<Object?>>[];
      final _OptionsHoverDelegate2 hover = _OptionsHoverDelegate2(
        log,
        setupKind: 'setupDelayedHoverAtMouse',
        disposeKind: 'setupDelayedHoverAtMouseDisposed',
      );
      d2.setBaseLayerHoverDelegate(hover);

      final dom.DomElement container = dom.document.createElement('div');
      final cb.CountBadge badge = cb.CountBadge(
        container,
        cb.ICountBadgeOptions(
          count: 5,
          countFormat: '({0})',
          titleFormat: 'Count {0}',
        ),
        cb.unthemedCountStyles,
      );
      final dom.DomElement element =
          container.childNodes.single as dom.DomElement;
      final Map<String, dynamic> initial = _map(section['initial']);
      final Map<String, dynamic> initialElement = _map(initial['element']);
      final Map<String, dynamic> initialStyle = _map(initialElement['style']);

      expect(container.childNodes.length, initial['childCount']);
      expect(element.className, initialElement['className']);
      expect(element.textContent, initialElement['textContent']);
      expect(element.style['backgroundColor'], initialStyle['backgroundColor']);
      expect(element.style['color'], initialStyle['color']);
      expect(log, _truthLog(initial, 'log'));

      badge.setCount(7);
      hover.invokeLast();
      badge.setCountFormat('[{0}]');
      badge.setTitleFormat('');

      final Map<String, dynamic> updates = _map(section['afterUpdates']);
      final Map<String, dynamic> updateElement = _map(updates['element']);
      final Map<String, dynamic> updateStyle = _map(updateElement['style']);
      expect(container.childNodes.length, updates['childCount']);
      expect(element.className, updateElement['className']);
      expect(element.textContent, updateElement['textContent']);
      expect(element.style['backgroundColor'], updateStyle['backgroundColor']);
      expect(element.style['color'], updateStyle['color']);
      expect(badge.hover.value, isNull);
      expect(log, _truthLog(updates, 'log'));

      badge.dispose();
      final Map<String, dynamic> disposed = _map(section['afterDispose']);
      expect(container.childNodes.length, disposed['childCount']);
      expect(log, _truthLog(disposed, 'log'));
    });
  });

  group('batch184 platform hover truth', () {
    test('decorator, delay updates, delegation and native hover match truth', () {
      final Map<String, dynamic> section = _map(truth['platformHover']);
      expect(_list(section['exports']), <String>[
        'IHoverService',
        'WorkbenchHoverDelegate',
        'nativeHoverDelegate',
      ]);
      expect(ph.IHoverService.serviceId, section['decoratorId']);

      final List<List<Object?>> log = <List<Object?>>[];
      final _TestConfigurationService config = _TestConfigurationService();
      final _TestHoverService service = _TestHoverService(log);

      final ph.WorkbenchHoverDelegate delegate = ph.WorkbenchHoverDelegate(
        'mouse',
        null,
        <String, Object?>{},
        config,
        service,
      );
      final Map<String, dynamic> delegation = _map(section['delegation']);
      expect(delegate.delay, delegation['initialDelay']);

      config.delay = 50;
      config.fire(true);
      expect(delegate.delay, delegation['afterAffecting']);

      config.delay = 999;
      config.fire(false);
      expect(delegate.delay, delegation['afterNonAffecting']);

      final dom.DomElement target = dom.document.createElement('div');
      delegate.showHover(
        d.IHoverDelegateOptions(
          content: 'hello',
          target: target,
          appearance: h.IHoverAppearanceOptions(showPointer: true),
          onDidShow: () {},
        ),
        true,
      );
      expect(service.captured, _list(delegation['captured']));
      expect(service.hideCalls, delegation['hideCallsBeforeEscape']);

      // Browser keyCode 27 maps to Monaco's KeyCode.Escape (9) through
      // StandardKeyboardEvent, matching the truth harness `equals(9)`.
      target.dispatchEvent(
        dom.EventType.KEY_DOWN,
        dom.DomKeyboardEvent(dom.EventType.KEY_DOWN)
          ..keyCode = 27,
      );
      expect(service.hideCalls, delegation['hideCallsAfterEscape']);
      delegate.onDidHideHover?.call();

      bool setLimitThrows = false;
      try {
        delegate.setInstantHoverTimeLimit(10);
      } on StateError {
        setLimitThrows = true;
      }
      expect(setLimitThrows, delegation['setLimitThrowsWithoutInstant']);

      final ph.WorkbenchHoverDelegate instant = ph.WorkbenchHoverDelegate(
        'element',
        ph.IHoverDelayOptions(instantHover: true),
        <String, Object?>{
          'persistence': <String, Object?>{'sticky': true},
          'appearance': <String, Object?>{'compact': false},
        },
        config,
        service,
      );
      instant.setInstantHoverTimeLimit(10);
      instant.onDidHideHover?.call();
      expect(instant.delay, delegation['delayAfterInstantHide']);

      final ph.WorkbenchHoverDelegate dynamicDelegate = ph.WorkbenchHoverDelegate(
        'mouse',
        ph.IHoverDelayOptions(dynamicDelay: (Object? content) => 123),
        <String, Object?>{},
        config,
        service,
      );
      final Object dynamicDelay = dynamicDelegate.delay;
      expect(
        (dynamicDelay as dynamic)('content'),
        delegation['dynamicValue'],
      );

      final ph.WorkbenchHoverDelegate fallbackDelegate = ph.WorkbenchHoverDelegate(
        'mouse',
        ph.IHoverDelayOptions(dynamicDelay: (Object? content) => null),
        <String, Object?>{},
        config,
        service,
      );
      final Object fallbackDelay = fallbackDelegate.delay;
      expect(
        (fallbackDelay as dynamic)('content'),
        delegation['fallbackValue'],
      );

      final Map<String, dynamic> native = _map(section['nativeHover']);
      expect(ph.nativeHoverDelegate.delay, native['delay']);
      expect(ph.nativeHoverDelegate.showNativeHover, native['showNativeHover']);
      StateError? nativeError;
      try {
        ph.nativeHoverDelegate.showHover(
          d.IHoverDelegateOptions(content: 'x', target: target),
        );
      } on StateError catch (error) {
        nativeError = error;
      }
      expect(nativeError != null, native['throws']);
      expect(nativeError?.message, native['message']);
    });
  });

  group('batch184 null hover service truth', () {
    test('no-op service surface matches truth', () {
      final Map<String, dynamic> section = _map(truth['nullHoverService']);
      expect(_list(section['exports']), <String>['NullHoverService']);

      final dom.DomElement target = dom.document.createElement('div');
      final d.IHoverDelegate delegate = _RecordingHoverDelegate(
        <List<Object?>>[],
        <_RecordingHoverWidget>[],
      );
      expect(nh.NullHoverService.serviceBrand, section['serviceBrand']);
      expect(nh.NullHoverService.getStickyHover(target), section['getStickyHover']);
      nh.NullHoverService.hideHover();
      expect(section['hideHover'], isNull);
      expect(
        nh.NullHoverService.showInstantHover(
          h.IHoverOptions(content: 'x', target: 'target'),
        ),
        section['showInstantHover'],
      );
      expect(
        nh.NullHoverService.showDelayedHover(
          h.IHoverOptions(content: 'x', target: 'target'),
          h.IHoverLifecycleOptions(groupId: 'g'),
        ),
        section['showDelayedHover'],
      );
      expect(
        identical(
          nh.NullHoverService.setupDelayedHover(
            target,
            const <String, Object?>{},
          ),
          lifecycle.Disposable.none,
        ),
        section['setupDelayedHoverIsNone'],
      );
      expect(
        identical(
          nh.NullHoverService.setupDelayedHoverAtMouse(
            target,
            const <String, Object?>{},
          ),
          lifecycle.Disposable.none,
        ),
        section['setupDelayedHoverAtMouseIsNone'],
      );
      final h.IManagedHover managed = nh.NullHoverService.setupManagedHover(
        delegate,
        target,
        null,
      );
      bool threw = false;
      try {
        managed.dispose();
        managed.show(true);
        managed.hide();
        managed.update('x');
      } catch (_) {
        threw = true;
      }
      expect(threw, section['managedMethodsThrew']);
      nh.NullHoverService.showAndFocusLastHover();
      nh.NullHoverService.showManagedHover(target);
      expect(section['hideHover'], isNull);
      expect(section['showAndFocusLastHover'], isNull);
      expect(section['showManagedHover'], isNull);
    });
  });

  group('batch184 switch truth', () {
    test('DOM state, click handling and hover title updates match truth', () {
      final Map<String, dynamic> section = _map(truth['switch']);
      expect(_list(section['exports']), <String>['Switch']);

      final List<List<Object?>> log = <List<Object?>>[];
      final _OptionsHoverDelegate2 hover = _OptionsHoverDelegate2(
        log,
        setupKind: 'setupDelayedHover',
        disposeKind: 'setupDelayedHoverDisposed',
      );
      d2.setBaseLayerHoverDelegate(hover);

      final List<bool> changes = <bool>[];
      final sw.Switch toggle = sw.Switch(
        sw.ISwitchOptions(
          checked: true,
          ariaLabel: 'Switch',
          title: 'Toggle title',
          disabled: false,
        ),
      );
      toggle.onChange(changes.add);

      Map<String, Object?> snapshot() => <String, Object?>{
        'className': toggle.domNode.className,
        'disabled': toggle.disabled,
        'attributes': <String, Object?>{
          'role': toggle.domNode.getAttribute('role'),
          'aria-label': toggle.domNode.getAttribute('aria-label'),
          'aria-checked': toggle.domNode.getAttribute('aria-checked'),
        },
        'childCount': toggle.domNode.childNodes.length,
        'checked': toggle.checked,
        'changes': changes.toList(),
      };

      expect(snapshot(), _map(section['initial']));
      hover.invokeLast();
      toggle.domNode.click();
      expect(snapshot(), _map(section['afterClick']));

      toggle.checked = true;
      toggle.disabled = true;
      toggle.domNode.click();
      expect(snapshot(), _map(section['afterProgrammaticAndDisabledClick']));

      toggle.setAriaLabel('New label', 'New title');
      hover.invokeLast();
      expect(snapshot(), _map(section['afterAria']));

      toggle.dispose();
      expect(snapshot(), _map(section['afterDispose']));
      expect(log, _truthLog(section, 'log', const <String>{'disposableDispose'}));
    });
  });

  group('batch184 updatableHoverWidget truth', () {
    test('async content flow and widget replacement match truth', () async {
      final Map<String, dynamic> section = _map(truth['updatableHoverWidget']);
      expect(_list(section['exports']), <String>['ManagedHoverWidget']);

      final List<List<Object?>> log = <List<Object?>>[];
      final List<_RecordingHoverWidget> widgets = <_RecordingHoverWidget>[];
      final _RecordingHoverDelegate delegate = _RecordingHoverDelegate(
        log,
        widgets,
      );
      final dom.DomElement target = dom.document.createElement('div');
      final uh.ManagedHoverWidget widget = uh.ManagedHoverWidget(
        delegate,
        target,
        true,
      );
      final h.IManagedHoverOptions options = h.IManagedHoverOptions(
        additionalClasses: <String>['extra'],
        appearance: h.IHoverAppearanceOptions(showHoverHint: true),
        position: h.IHoverPositionOptions(anchorAlignment: 2),
      );

      await widget.update('hello', true, options);
      expect(log, _truthLog(section, 'afterFirst'));

      await widget.update(null, false);
      expect(log, _truthLog(section, 'afterUndefined'));

      await widget.update(<String, Object?>{
        'markdown': 'md-value',
        'markdownNotSupportedFallback': 'fallback',
      });
      expect(log, _truthLog(section, 'afterMarkdown'));

      await widget.update(<String, Object?>{
        'element': (Object? token) => dom.DomElement('span'),
        'contentOwnsPadding': true,
      });
      expect(log, _truthLog(section, 'afterElement'));

      await widget.update(<String, Object?>{
        'markdown': (Object? token) async => null,
        'markdownNotSupportedFallback': 'promise-fallback',
      });
      expect(log, _truthLog(section, 'afterPromise'));

      expect(widget.isDisposed, section['beforeDisposeDisposed']);
      widget.dispose();
      expect(widget.isDisposed, section['afterDisposeDisposed']);
      expect(widgets.length, section['widgetCount']);
      expect(log, _truthLog(section, 'allLog'));
    });
  });
}
