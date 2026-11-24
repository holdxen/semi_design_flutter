import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import '../lib/src/monaco/base/browser/dom.dart' as dom;
import '../lib/src/monaco/base/browser/ui/hover/hover.dart' as h;
import '../lib/src/monaco/base/browser/ui/hover/hoverDelegate.dart' as d;
import '../lib/src/monaco/base/browser/ui/hover/hoverDelegate2.dart' as d2;
import '../lib/src/monaco/base/browser/ui/hover/hoverDelegateFactory.dart' as f;
import '../lib/src/monaco/base/common/lifecycle.dart' as lifecycle;

class _TestHoverWidget implements h.IHoverWidget {
  _TestHoverWidget(this.tag);

  final String tag;

  @override
  bool isDisposed = false;

  @override
  void dispose() {
    isDisposed = true;
  }
}

class _TestHoverDelegate implements d.IHoverDelegate {
  _TestHoverDelegate(this.tag);

  final String tag;

  @override
  h.IHoverWidget? showHover(d.IHoverDelegateOptions options, [bool? focus]) =>
      _TestHoverWidget('hover:$tag');

  @override
  void Function()? onDidHideHover;

  @override
  Object get delay => -1;

  @override
  String? get placement => null;

  @override
  bool? get showNativeHover => null;
}

class _TestManagedHover implements h.IManagedHover {
  _TestManagedHover(this.log);

  final List<List<Object?>> log;

  @override
  void show([bool? focus]) {
    log.add(<Object?>['managedShow', focus == true]);
  }

  @override
  void hide() {
    log.add(<Object?>['managedHide']);
  }

  @override
  void update(Object? tooltip, [h.IManagedHoverOptions? options]) {
    log.add(<Object?>['managedUpdate', 'next', 'nextOptions']);
  }

  @override
  void dispose() {
    log.add(<Object?>['managedDispose']);
  }
}

class _TestHoverDelegate2 implements h.IHoverDelegate2 {
  _TestHoverDelegate2(this.log);

  final List<List<Object?>> log;

  @override
  h.IHoverWidget? showInstantHover(h.IHoverOptions options, [bool? focus]) {
    log.add(<Object?>['showInstantHover', options.content, focus]);
    return null;
  }

  @override
  h.IHoverWidget? showDelayedHover(
    h.IHoverOptions options,
    h.IHoverLifecycleOptions lifecycleOptions,
  ) {
    log.add(<Object?>[
      'showDelayedHover',
      options.content,
      lifecycleOptions.groupId,
    ]);
    return null;
  }

  @override
  Object? setupDelayedHover(
    dom.DomElement target,
    Object hoverOptions, [
    h.IHoverLifecycleOptions? lifecycleOptions,
  ]) {
    log.add(<Object?>[
      'setupDelayedHover',
      'target',
      (hoverOptions as Map)['tag'],
      lifecycleOptions?.groupId,
    ]);
    return <String, Object?>{'kind': 'element'};
  }

  @override
  Object? setupDelayedHoverAtMouse(
    dom.DomElement target,
    Object hoverOptions, [
    h.IHoverLifecycleOptions? lifecycleOptions,
  ]) {
    log.add(<Object?>[
      'setupDelayedHoverAtMouse',
      'target',
      (hoverOptions as Map)['tag'],
      lifecycleOptions?.reducedDelay,
    ]);
    return <String, Object?>{'kind': 'mouse'};
  }

  @override
  void hideHover([bool? force]) {
    log.add(<Object?>['hideHover', force]);
  }

  @override
  void showAndFocusLastHover() {
    log.add(<Object?>['showAndFocusLastHover']);
  }

  @override
  h.IManagedHover setupManagedHover(
    d.IHoverDelegate hoverDelegate,
    dom.DomElement targetElement,
    Object? content, [
    h.IManagedHoverOptions? options,
  ]) {
    log.add(<Object?>['setupManagedHover', (hoverDelegate as _TestHoverDelegate).tag, 'target', content, 'options']);
    return _TestManagedHover(log);
  }

  @override
  void showManagedHover(dom.DomElement targetElement) {
    log.add(<Object?>['showManagedHover', 'target']);
  }
}

class _FactoryDelegate implements d.IScopedHoverDelegate {
  _FactoryDelegate(this.placement, this.enableInstantHover, this.calls) {
    calls.add(<Object?>[placement, enableInstantHover]);
  }

  final String placement;
  final bool enableInstantHover;
  final List<List<Object?>> calls;

  @override
  Object get delay => enableInstantHover ? 0 : placement == 'element' ? 7 : 11;

  @override
  void Function()? onDidHideHover;

  @override
  bool? get showNativeHover => null;

  @override
  h.IHoverWidget? showHover(d.IHoverDelegateOptions options, [bool? focus]) =>
      _TestHoverWidget('hover:$placement');

  @override
  void dispose() {
    calls.add(<Object?>['dispose', placement, enableInstantHover]);
  }
}

Map<String, dynamic> _map(dynamic value) => (value as Map).cast<String, dynamic>();

List<dynamic> _list(dynamic value) => value as List<dynamic>;

void main() {
  final Map<String, dynamic> truth = _map(
    jsonDecode(File('tool/ts2dart/batch183_truth.json').readAsStringSync()),
  );

  group('batch183 hover truth', () {
    test('runtime exports and HoverStyle match TypeScript truth', () {
      final Map<String, dynamic> exports = _map(truth['exports']);
      expect(_list(exports['hover']), <String>[
        'HoverStyle',
        'isManagedHoverTooltipHTMLElement',
        'isManagedHoverTooltipMarkdownString',
      ]);
      expect(_list(exports['hoverDelegate']), isEmpty);
      expect(_map(truth['baseLayer'])['exports'], <String>[
        'getBaseLayerHoverDelegate',
        'setBaseLayerHoverDelegate',
      ]);
      expect(_map(truth['factory'])['exports'], <String>[
        'createInstantHoverDelegate',
        'getDefaultHoverDelegate',
        'setHoverDelegateFactory',
      ]);

      final Map<String, dynamic> style = _map(truth['hoverStyle']);
      expect(h.HoverStyle.Pointer, style['Pointer']);
      expect(h.HoverStyle.Mouse, style['Mouse']);
    });

    test('managed tooltip type guards match every truth case', () {
      final Map<String, Object?> inputs = <String, Object?>{
        'undefined': null,
        'number': 42,
        'string': 'markdown',
        'emptyObject': <String, Object?>{},
        'markdownOnly': <String, Object?>{'markdown': 'x'},
        'fallbackOnly': <String, Object?>{'markdownNotSupportedFallback': 'y'},
        'markdownBoth': <String, Object?>{
          'markdown': 'x',
          'markdownNotSupportedFallback': 'y',
        },
        'markdownExtra': <String, Object?>{
          'markdown': 'x',
          'markdownNotSupportedFallback': 'y',
          'extra': 1,
        },
        'elementString': <String, Object?>{'element': '<div/>'},
        'elementNull': <String, Object?>{'element': null},
        'elementExtra': <String, Object?>{
          'element': '<div/>',
          'contentOwnsPadding': true,
        },
      };

      for (final dynamic rawCase in _list(truth['typeGuards'])) {
        final Map<String, dynamic> item = _map(rawCase);
        final String label = item['label'] as String;
        expect(
          h.isManagedHoverTooltipMarkdownString(inputs[label]),
          item['markdown'],
          reason: 'markdown guard: $label',
        );
        expect(
          h.isManagedHoverTooltipHTMLElement(inputs[label]),
          item['htmlElement'],
          reason: 'html element guard: $label',
        );
      }
    });

    test('base layer delegate defaults and injected delegate match truth', () {
      final Map<String, dynamic> base = _map(truth['baseLayer']);
      final dom.DomElement target = dom.document.createElement('div');
      final h.IHoverOptions options = h.IHoverOptions(
        content: 'opts',
        target: 'target',
      );
      final h.IHoverLifecycleOptions lifecycleOptions =
          h.IHoverLifecycleOptions(groupId: 'g');

      final h.IHoverDelegate2 defaults = d2.getBaseLayerHoverDelegate();
      expect(
        identical(defaults, d2.getBaseLayerHoverDelegate()),
        base['defaultIdentity'],
      );
      expect(defaults.showInstantHover(options), isNull);
      expect(defaults.showDelayedHover(options, lifecycleOptions), isNull);
      expect(
        identical(
          defaults.setupDelayedHover(target, const <String, Object?>{}),
          lifecycle.Disposable.none,
        ),
        base['defaultSetupDelayedHoverIsNone'],
      );
      expect(
        identical(
          defaults.setupDelayedHoverAtMouse(target, const <String, Object?>{}),
          lifecycle.Disposable.none,
        ),
        base['defaultSetupDelayedHoverAtMouseIsNone'],
      );
      defaults.hideHover(true);
      defaults.showAndFocusLastHover();
      final h.IManagedHover managed = defaults.setupManagedHover(
        _TestHoverDelegate('x'),
        target,
        'content',
      );
      expect(() {
        managed.show(true);
        managed.hide();
        managed.update('next');
        managed.dispose();
      }, returnsNormally);
      defaults.showManagedHover(target);

      final List<List<Object?>> log = <List<Object?>>[];
      final _TestHoverDelegate2 custom = _TestHoverDelegate2(log);
      d2.setBaseLayerHoverDelegate(custom);
      expect(
        identical(d2.getBaseLayerHoverDelegate(), custom),
        _map(base['afterSet'])['identity'],
      );

      final h.IManagedHover gotManaged = custom.setupManagedHover(
        _TestHoverDelegate('custom'),
        target,
        'content',
        h.IManagedHoverOptions(),
      );
      custom.showInstantHover(options, true);
      custom.showDelayedHover(options, lifecycleOptions);
      final Object? elementWidget = custom.setupDelayedHover(
        target,
        <String, Object?>{'tag': 'opts'},
        lifecycleOptions,
      );
      final Object? mouseWidget = custom.setupDelayedHoverAtMouse(
        target,
        <String, Object?>{'tag': 'opts'},
        h.IHoverLifecycleOptions(reducedDelay: true),
      );
      custom.hideHover(true);
      custom.showAndFocusLastHover();
      gotManaged.dispose();
      gotManaged.show(true);
      gotManaged.hide();
      gotManaged.update('next');
      custom.showManagedHover(target);

      final Map<String, dynamic> after = _map(base['afterSet']);
      expect(
        (elementWidget as Map)['kind'],
        after['elementWidgetKind'],
      );
      expect(
        (mouseWidget as Map)['kind'],
        after['mouseWidgetKind'],
      );
      expect(log, _list(after['log']));
    });

    test('factory cache and instant delegate semantics match truth', () {
      final Map<String, dynamic> truthFactory = _map(truth['factory']);
      final List<List<Object?>> firstCalls = <List<Object?>>[];
      f.setHoverDelegateFactory(
        (String placement, bool enableInstantHover) =>
            _FactoryDelegate(placement, enableInstantHover, firstCalls),
      );

      final d.IHoverDelegate mouse = f.getDefaultHoverDelegate('mouse');
      final d.IHoverDelegate mouseAgain = f.getDefaultHoverDelegate('mouse');
      final d.IHoverDelegate element = f.getDefaultHoverDelegate('element');
      final d.IHoverDelegate unknown = f.getDefaultHoverDelegate('other');
      final d.IScopedHoverDelegate instant = f.createInstantHoverDelegate();

      expect(identical(mouse, mouseAgain), truthFactory['mouseIdentity']);
      expect(identical(element, unknown), truthFactory['elementIdentity']);
      expect(identical(mouse, element), isNot(truthFactory['mouseNotElement']));
      expect(firstCalls, _list(truthFactory['calls']));
      expect(mouse.delay, truthFactory['mouseDelay']);
      expect(element.delay, truthFactory['elementDelay']);
      expect(instant.delay, truthFactory['instantDelay']);
      expect((instant as _FactoryDelegate).placement, truthFactory['instantPlacement']);
      expect(
        instant.enableInstantHover,
        truthFactory['instantEnableInstantHover'],
      );

      final d.IHoverDelegateOptions hoverOptions = d.IHoverDelegateOptions(
        content: 'x',
        target: 'target',
      );
      expect(
        (mouse.showHover(hoverOptions) as _TestHoverWidget).tag,
        truthFactory['mouseShowHover'],
      );
      expect(
        (element.showHover(hoverOptions) as _TestHoverWidget).tag,
        truthFactory['elementShowHover'],
      );

      final List<List<Object?>> secondCalls = <List<Object?>>[];
      f.setHoverDelegateFactory(
        (String placement, bool enableInstantHover) =>
            _FactoryDelegate(placement, enableInstantHover, secondCalls),
      );
      final d.IHoverDelegate afterMouse = f.getDefaultHoverDelegate('mouse');
      final d.IHoverDelegate afterElement = f.getDefaultHoverDelegate('element');
      final Map<String, dynamic> cached = _map(truthFactory['afterDefaultsCached']);
      expect(identical(afterMouse, mouse), cached['afterMouseIsBefore']);
      expect(identical(afterElement, element), cached['afterElementIsBefore']);
      expect(secondCalls, _list(cached['callsBeforeInstant']));

      final d.IScopedHoverDelegate instantAfterSet = f.createInstantHoverDelegate();
      instantAfterSet.dispose();
      expect(secondCalls, _list(cached['callsAfterInstantAndDispose']));
      expect(instantAfterSet.delay, cached['instantDelay']);
      expect(
        (instantAfterSet as _FactoryDelegate).placement,
        cached['instantPlacement'],
      );
    });
  });
}
