// Truth replay for batch193: `platform/hover/browser/hoverWidget.ts`.
//
// Every expectation comes from `tool/ts2dart/batch193_truth.json`, produced by
// `tool/ts2dart/_batch193_truth.cjs`, which executes the real transpiled
// TypeScript for `hoverWidget.ts` together with the real base
// `hoverWidget.ts` (BaseHoverWidget / HoverAction / HoverPosition /
// getHoverAccessibleViewHint), lifecycle, event, async, keyCodes, keybindings,
// keyboardEvent, htmlContent, types and layout modules.
//
// NOTE: `platform/hover/browser/hoverWidget.ts` has no official test of its own
// — `find_ready.py`'s stem heuristic matches the tests of
// `base/browser/ui/hover/hoverWidget.ts`. Truth comes from the real source.
import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import '../lib/src/monaco/base/browser/dom.dart' as dom;
import '../lib/src/monaco/base/browser/markdownRenderer.dart'
    show RenderedMarkdown;
import '../lib/src/monaco/base/browser/window.dart' show mainWindow;
import '../lib/src/monaco/base/browser/ui/hover/hover.dart' as hover;
import '../lib/src/monaco/base/common/htmlContent.dart' as htmlContent;
import '../lib/src/monaco/base/common/keybindings.dart' as keybindings;
import '../lib/src/monaco/base/common/lifecycle.dart' as lifecycle;
import '../lib/src/monaco/base/common/platform.dart' as platform;
import '../lib/src/monaco/platform/accessibility/common/accessibility.dart'
    as accessibility;
import '../lib/src/monaco/platform/configuration/common/configuration.dart'
    as configuration;
import '../lib/src/monaco/platform/hover/browser/hoverWidget.dart' as hoverPort;
import '../lib/src/monaco/platform/keybinding/common/keybinding.dart'
    as keybinding;
import '../lib/src/monaco/platform/markdown/browser/markdownRenderer.dart'
    as markdownRenderer;

Map<String, dynamic> _map(dynamic value) =>
    (value as Map).cast<String, dynamic>();

List<dynamic> _list(dynamic value) => value as List<dynamic>;

Matcher _exp(dynamic value) => value == null ? isNull : equals(value);

Map<String, dynamic> _truth() =>
    _map(jsonDecode(File('tool/ts2dart/batch193_truth.json').readAsStringSync()));

// ---------------------------------------------------------------------------
// Fakes
// ---------------------------------------------------------------------------
class _FakeMarkdownRenderer implements markdownRenderer.IMarkdownRendererServiceType {
  _FakeMarkdownRenderer(this.log);

  final List<Map<String, Object?>> log;
  Map<String, Object?>? lastOptions;

  @override
  RenderedMarkdown render(
    Object markdown, [
    markdownRenderer.MarkdownRendererRenderOptions? options,
    Object? outElement,
  ]) {
    final Map<String, Object?> optionKeys = <String, Object?>{};
    if (options != null) {
      if (options.actionHandler != null) optionKeys['actionHandler'] = true;
      if (options.asyncRenderCallback != null) {
        optionKeys['asyncRenderCallback'] = true;
      }
    }
    log.add(<String, Object?>{
      'value': (markdown as htmlContent.MarkdownString).value,
      'optionKeys': optionKeys.keys.toList()..sort(),
    });
    lastOptions = <String, Object?>{
      'asyncRenderCallback': options?.asyncRenderCallback,
    };
    final dom.DomElement element = dom.document.createElement('div');
    element.className = 'rendered-markdown';
    return RenderedMarkdown(element, () {});
  }

  @override
  void setDefaultCodeBlockRenderer(
      markdownRenderer.IMarkdownCodeBlockRenderer renderer) {}
}

class _FakeKeybinding implements keybindings.ResolvedKeybinding {
  _FakeKeybinding(this.label, this.ariaLabel);

  final String label;
  final String ariaLabel;

  @override
  String? getLabel() => label;

  @override
  String? getAriaLabel() => ariaLabel;

  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}

class _FakeKeybindingService implements keybinding.IKeybindingServiceType {
  @override
  keybindings.ResolvedKeybinding? lookupKeybinding(String commandId,
      [Object? contextKeyService, bool? skipLabelForCommands]) {
    if (commandId == 'known.command') {
      return _FakeKeybinding('Ctrl+K', 'Control K');
    }
    if (commandId == 'editor.action.accessibleView') {
      return _FakeKeybinding('Alt+F1', 'Alt F1');
    }
    return null;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}

class _FakeConfigurationService
    implements configuration.IConfigurationServiceType {
  @override
  Object? getValue$1(String section) =>
      section == 'accessibility.verbosity.hover' ? true : null;

  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}

class _FakeAccessibilityService
    implements accessibility.IAccessibilityServiceType {
  @override
  bool isScreenReaderOptimized() => true;

  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}

Map<String, Object?> _styleMap(dom.DomElement el) => <String, Object?>{
      for (final String key in el.style.keys) key: el.style[key],
    };

dom.DomElement _hoverContainerOf(hoverPort.HoverWidget widget) =>
    widget.domNode.parentNode as dom.DomElement;

dom.DomElement? _pointerOf(hoverPort.HoverWidget widget) {
  for (final dom.DomNode child in _hoverContainerOf(widget).childNodes) {
    if (child is dom.DomElement &&
        child.className.contains('workbench-hover-pointer')) {
      return child;
    }
  }
  return null;
}

Map<String, Object?> _snapshot(hoverPort.HoverWidget widget) {
  final dom.DomElement container = widget.domNode;
  final dom.DomElement? pointer = _pointerOf(widget);
  return <String, Object?>{
    'name': null,
    'x': widget.x,
    'y': widget.y,
    'anchor': widget.anchor,
    'containerClassName': container.className,
    'containerStyle': _styleMap(container),
    'contentsStyle': _styleMap(widget.contentsDomNode),
    'pointerClassName': pointer?.className,
    'pointerStyle': pointer == null ? null : _styleMap(pointer),
  };
}

const Map<String, Object?> _baseRect = <String, Object?>{
  'left': 100,
  'top': 100,
  'right': 300,
  'bottom': 140,
  'width': 200,
  'height': 40,
};

hoverPort.HoverWidget _create(
  IHoverFixture fixture,
  Map<String, dynamic> cfg,
) {
  final Map<String, dynamic> optionsMap = _map(cfg['options'] ?? <String, Object?>{});
  final dom.DomElement target = dom.document.createElement('span');
  final Map<String, dynamic> rect = cfg['targetRect'] == null
      ? _map(_baseRect)
      : _map(cfg['targetRect']);
  target.rect = dom.DomRect(
    left: (rect['left'] as num).toDouble(),
    top: (rect['top'] as num).toDouble(),
    right: (rect['right'] as num).toDouble(),
    bottom: (rect['bottom'] as num).toDouble(),
    width: (rect['width'] as num).toDouble(),
    height: (rect['height'] as num).toDouble(),
  );
  target.clientWidth = rect['width'] as int;
  target.clientHeight = rect['height'] as int;

  dom.document.documentElement.clientWidth =
      (cfg['docWidth'] as int?) ?? 1000;
  dom.document.documentElement.clientLeft = (cfg['docLeft'] as int?) ?? 10;
  dom.windowCarrier(mainWindow).innerHeight =
      (cfg['windowHeight'] as int?) ?? 800;

  final Object content = cfg['markdown'] == true
      ? htmlContent.MarkdownString(cfg['content'] as String)
      : (cfg['content'] as Object? ?? 'text');

  final hover.IHoverOptions options = hover.IHoverOptions(
    content: content,
    target: cfg['targetX'] == null
        ? target
        : _FixedTarget(target, cfg['targetX'] as num, cfg['targetY'] as num),
    style: optionsMap['style'] as int?,
    appearance: _appearance(optionsMap['appearance']),
    position: _position(optionsMap['position'], cfg['clipRect']),
    additionalClasses: (optionsMap['additionalClasses'] as List<dynamic>?)
        ?.cast<String>(),
    trapFocus: optionsMap['trapFocus'] as bool?,
    actions: _actions(optionsMap['actions']),
    persistence: _persistence(optionsMap['persistence']),
  );

  final hoverPort.HoverWidget widget = hoverPort.HoverWidget(
    options,
    fixture.keybindingService,
    fixture.configurationService,
    fixture.markdownRenderer,
    fixture.accessibilityService,
  );
  final dom.DomElement container = widget.domNode;
  final Map<String, dynamic> sizes = _map(cfg['sizes'] ?? <String, Object?>{});
  container.clientWidth = (sizes['containerWidth'] as int?) ?? 200;
  container.clientHeight = (sizes['containerHeight'] as int?) ?? 150;
  container.offsetHeight = (sizes['containerOffsetHeight'] as int?) ?? 160;
  final dom.DomElement contents = widget.contentsDomNode;
  contents.clientWidth = (sizes['contentsClientWidth'] as int?) ??
      (sizes['contentsClientHeight'] as int?) ??
      120;
  contents.clientHeight = (sizes['contentsClientHeight'] as int?) ?? 120;
  contents.offsetHeight = (sizes['contentsOffsetHeight'] as int?) ?? 120;
  contents.scrollHeight = (sizes['contentsScrollHeight'] as int?) ?? 120;
  return widget;
}

hover.IHoverAppearanceOptions? _appearance(dynamic value) {
  if (value == null) return null;
  final Map<String, dynamic> map = _map(value);
  return hover.IHoverAppearanceOptions(
    showPointer: map['showPointer'] as bool?,
    compact: map['compact'] as bool?,
    showHoverHint: map['showHoverHint'] as bool?,
    skipFadeInAnimation: map['skipFadeInAnimation'] as bool?,
    maxHeightRatio: map['maxHeightRatio'] as num?,
  );
}

hover.IHoverPositionOptions? _position(dynamic value, dynamic clipRect) {
  if (value == null && clipRect == null) return null;
  final Map<String, dynamic> map =
      value == null ? <String, dynamic>{} : _map(value);
  dom.DomElement? clip;
  if (clipRect != null) {
    final Map<String, dynamic> rect = _map(clipRect);
    clip = dom.document.createElement('div')
      ..rect = dom.DomRect(
        left: (rect['left'] as num).toDouble(),
        top: (rect['top'] as num).toDouble(),
        right: (rect['right'] as num).toDouble(),
        bottom: (rect['bottom'] as num).toDouble(),
        width: (rect['width'] as num).toDouble(),
        height: (rect['height'] as num).toDouble(),
      );
  }
  return hover.IHoverPositionOptions(
    hoverPosition: map['hoverPosition'] as int?,
    anchorAlignment: map['anchorAlignment'] as int?,
    forcePosition: map['forcePosition'] as bool?,
    clippingElement: clip,
  );
}

List<hover.IHoverAction>? _actions(dynamic value) {
  if (value == null) return null;
  return _list(value).map((dynamic raw) {
    final Map<String, dynamic> map = _map(raw);
    return _FakeAction(
      label: map['label'] as String,
      commandId: map['commandId'] as String,
      iconClass: map['iconClass'] as String?,
    );
  }).toList();
}

hover.IHoverPersistenceOptions? _persistence(dynamic value) {
  if (value == null) return null;
  final Map<String, dynamic> map = _map(value);
  return hover.IHoverPersistenceOptions(
    hideOnHover: map['hideOnHover'] as bool?,
  );
}

class _FakeAction implements hover.IHoverAction {
  _FakeAction({
    required this.label,
    required this.commandId,
    this.iconClass,
  });

  @override
  final String label;
  @override
  final String commandId;
  @override
  final String? iconClass;

  @override
  void Function(dom.DomElement target) get run => (dom.DomElement target) {};
}

/// `IHoverTarget` with a fixed x/y (source reads `target.x` / `target.y`).
class _FixedTarget implements hover.IHoverTarget {
  _FixedTarget(dom.DomElement element, this.x, this.y)
      : targetElements = <dom.DomElement>[element];

  @override
  final List<dom.DomElement> targetElements;
  @override
  final num? x;
  @override
  final num? y;
}

class IHoverFixture {
  IHoverFixture()
      : markdownLog = <Map<String, Object?>>[],
        markdownRenderer = _FakeMarkdownRenderer(<Map<String, Object?>>[]);

  final List<Map<String, Object?>> markdownLog;
  final _FakeMarkdownRenderer markdownRenderer;
  final _FakeKeybindingService keybindingService = _FakeKeybindingService();
  final _FakeConfigurationService configurationService =
      _FakeConfigurationService();
  final _FakeAccessibilityService accessibilityService =
      _FakeAccessibilityService();
}

void main() {
  final Map<String, dynamic> truth = _truth();

  test('batch193 construction with pointer style, actions and hint matches truth',
      () {
    final IHoverFixture fixture = IHoverFixture();
    final Map<String, dynamic> expected = _map(truth['constructPointer']);
    final hoverPort.HoverWidget widget = _create(fixture, <String, dynamic>{
      'content': 'pointer content',
      'options': <String, Object?>{
        'style': 1,
        'appearance': <String, Object?>{},
        'actions': <Object?>[
          <String, Object?>{
            'label': 'Do it',
            'commandId': 'known.command',
            'iconClass': 'icon-one',
          },
          <String, Object?>{'label': 'Unknown', 'commandId': 'unknown.command'},
        ],
        'persistence': <String, Object?>{},
      },
    });

    final dom.DomElement container = widget.domNode;
    expect(container.className, expected['containerClassName']);
    expect(widget.contentsDomNode.textContent, expected['contentsText']);
    // Only the keys the source sets are compared: the Dart base widget's
    // scrollable element also stamps `overflow` on this node.
    expect(_styleMap(widget.contentsDomNode)['maxHeight'],
        _map(expected['contentsStyle'])['maxHeight']);

    final List<dom.DomElement> statusBars = container.childNodes
        .whereType<dom.DomElement>()
        .where((dom.DomElement el) => el.className.contains('status-bar'))
        .toList();
    expect(statusBars.length, 1);
    expect(statusBars.first.textContent, expected['statusBarText']);
    final List<dynamic> actionRow = _list(expected['actionsRowChildren']);
    expect(statusBars.first.childNodes.length, actionRow.length);
    final dom.DomElement actionsEl =
        statusBars.first.childNodes.whereType<dom.DomElement>().first;
    expect(actionsEl.className, _map(actionRow.first)['className']);
    expect(actionsEl.childNodes.length, 2);

    widget.dispose();
  });

  test('batch193 hover hint matches truth', () {
    final IHoverFixture fixture = IHoverFixture();
    final Map<String, dynamic> expected = _map(truth['constructHint']);
    final hoverPort.HoverWidget widget = _create(fixture, <String, dynamic>{
      'content': 'hinted',
      'options': <String, Object?>{
        'appearance': <String, Object?>{'showHoverHint': true, 'compact': false},
        'trapFocus': true,
      },
    });
    final dom.DomElement container = widget.domNode;
    expect(container.className, expected['containerClassName']);
    final dom.DomElement statusBar = container.childNodes
        .whereType<dom.DomElement>()
        .firstWhere((dom.DomElement el) => el.className.contains('status-bar'));
    // The truth harness pins `isMacintosh: false`; the Dart test runs on the
    // host platform, so the platform word is substituted.
    final String expectedHint = (expected['statusBarText'] as String)
        .replaceAll('Alt', platform.isMacintosh ? 'Option' : 'Alt');
    expect(statusBar.textContent, expectedHint);
    expect(
        (statusBar.childNodes.whereType<dom.DomElement>().first).className,
        expected['infoChildClassName']);
    widget.dispose();
  });

  test('batch193 HTML content registers a resize observer like truth', () {
    final IHoverFixture fixture = IHoverFixture();
    final Map<String, dynamic> expected = _map(truth['constructHtml']);
    dom.DomResizeObserver.instances.clear();
    final dom.DomElement htmlEl = dom.document.createElement('div');
    htmlEl.className = 'custom-html';
    final hoverPort.HoverWidget widget = _create(fixture, <String, dynamic>{
      'content': htmlEl,
    });
    expect(widget.contentsDomNode.className, expected['contentsClassName']);
    expect(
        dom.DomResizeObserver.instances
            .expand((dom.DomResizeObserver observer) => observer.observed)
            .map((dom.DomElement el) => el.className)
            .toList(),
        _exp(expected['resizeObserved']));
    widget.dispose();
  });

  test('batch193 markdown content renders through the service like truth', () {
    final IHoverFixture fixture = IHoverFixture();
    final Map<String, dynamic> expected = _map(truth['constructMarkdown']);
    final hoverPort.HoverWidget widget = _create(fixture, <String, dynamic>{
      'content': '**bold**',
      'markdown': true,
    });
    final dom.DomElement contents = widget.contentsDomNode;
    expect(contents.className, expected['classNameBefore']);
    expect(fixture.markdownRenderer.log, _exp(expected['renderCalls']));

    int layoutFires = 0;
    widget.onRequestLayout((dynamic _) => layoutFires++);
    final void Function()? callback =
        fixture.markdownRenderer.lastOptions?['asyncRenderCallback']
            as void Function()?;
    callback?.call();
    expect(contents.className, expected['classNameAfter']);
    expect(layoutFires, expected['requestLayoutFired']);
    widget.dispose();
  });

  test('batch193 hideOnHover matrix matches truth', () {
    final Map<String, dynamic> expected = _map(truth['hideOnHover']);
    void check(String name, Map<String, dynamic> cfg) {
      final IHoverFixture fixture = IHoverFixture();
      final dom.DomElement target = dom.document.createElement('span');
      target.rect = dom.DomRect(
        left: 100,
        top: 100,
        right: 300,
        bottom: 140,
        width: 200,
        height: 40,
      );
      final Map<String, dynamic> optionsMap =
          _map(cfg['options'] ?? <String, Object?>{});
      final Object content = cfg['markdown'] == true
          ? htmlContent.MarkdownString(cfg['content'] as String)
          : cfg['content'] as String;
      final hoverPort.HoverWidget widget = hoverPort.HoverWidget(
        hover.IHoverOptions(
          content: content,
          target: target,
          actions: _actions(optionsMap['actions']),
          persistence: _persistence(optionsMap['persistence']),
        ),
        fixture.keybindingService,
        fixture.configurationService,
        fixture.markdownRenderer,
        fixture.accessibilityService,
      );
      final Map<String, dynamic> expectRow = _map(expected[name]);
      expect(target.listenerCount('mouseover'),
          expectRow['targetMouseOverListeners'],
          reason: name);
      expect(target.listenerCount('mouseleave'),
          expectRow['targetMouseLeaveListeners'],
          reason: name);
      widget.dispose();
    }

    check('stringContent', <String, dynamic>{'content': 'text'});
    check('markdownNoLink', <String, dynamic>{
      'content': 'plain **md**',
      'markdown': true,
    });
    check('markdownWithLink', <String, dynamic>{
      'content': 'see [x](https://e.com)',
      'markdown': true,
    });
    check('markdownWithAnchor', <String, dynamic>{
      'content': '<a href="e">x</a>',
      'markdown': true,
    });
    check('explicitFalse', <String, dynamic>{
      'content': 'text',
      'options': <String, Object?>{
        'persistence': <String, Object?>{'hideOnHover': false},
      },
    });
    check('explicitTrue', <String, dynamic>{
      'content': 'text',
      'options': <String, Object?>{
        'persistence': <String, Object?>{'hideOnHover': true},
      },
    });
    check('withActions', <String, dynamic>{
      'content': 'text',
      'options': <String, Object?>{
        'actions': <Object?>[
          <String, Object?>{'label': 'a', 'commandId': 'c'},
        ],
      },
    });
  });

  test('batch193 layout matrix matches truth', () {
    final List<dynamic> cases = _list(truth['layout']);
    for (final dynamic raw in cases) {
      final Map<String, dynamic> expected = _map(raw);
      final String name = expected['name'] as String;
      final IHoverFixture fixture = IHoverFixture();
      final hoverPort.HoverWidget widget = _create(fixture, _layoutConfig(name));
      widget.layout();
      final Map<String, Object?> actual = _snapshot(widget);
      expect(actual['x'], _exp(expected['x']), reason: '$name x');
      expect(actual['y'], _exp(expected['y']), reason: '$name y');
      expect(actual['anchor'], _exp(expected['anchor']), reason: '$name anchor');
      expect(actual['containerClassName'], _exp(expected['containerClassName']),
          reason: '$name containerClassName');
      expect(actual['containerStyle'], _exp(expected['containerStyle']),
          reason: '$name containerStyle');
      expect(_map(actual['contentsStyle'])['maxHeight'],
          _map(expected['contentsStyle'])['maxHeight'],
          reason: '$name contentsStyle.maxHeight');
      expect(actual['pointerClassName'], _exp(expected['pointerClassName']),
          reason: '$name pointerClassName');
      expect(actual['pointerStyle'], _exp(expected['pointerStyle']),
          reason: '$name pointerStyle');
      widget.dispose();
    }
  });

  test('batch193 lifecycle matches truth', () {
    final IHoverFixture fixture = IHoverFixture();
    final Map<String, dynamic> expected = _map(truth['lifecycle']);
    final hoverPort.HoverWidget widget = _create(fixture, <String, dynamic>{});
    final dom.DomElement hoverContainer = _hoverContainerOf(widget);

    final Map<String, dynamic> locked = _map(expected['locked']);
    widget.isLocked = true;
    expect(hoverContainer.className, locked['afterTrue']);
    widget.isLocked = true;
    expect(hoverContainer.className, locked['afterTrueAgain']);
    widget.isLocked = false;
    expect(hoverContainer.className, locked['afterFalse']);

    final dom.DomElement extra = dom.document.createElement('div');
    extra.className = 'extra-target';
    final lifecycle.IDisposable sub = widget.addMouseTrackingElement(extra);
    expect(extra.listenerCount('mouseover'), expected['extraListenersDuring']);
    sub.dispose();
    expect(extra.listenerCount('mouseover'), expected['extraListenersAfter']);

    final dom.DomElement host = dom.document.createElement('div');
    widget.render(host);
    expect(host.childNodes.contains(hoverContainer), expected['attachedBefore']);
    int disposedFired = 0;
    widget.onDispose((dynamic _) => disposedFired++);
    final bool isMouseIn = widget.isMouseIn;
    widget.dispose();
    expect(disposedFired, expected['disposedFired']);
    expect(hoverContainer.parentNode, isNull);
    expect(widget.isDisposed, expected['isDisposed']);
    expect(isMouseIn, expected['isMouseIn']);
  });

  test('batch193 escape disposes the hover like truth', () {
    final IHoverFixture fixture = IHoverFixture();
    final Map<String, dynamic> expected = _map(truth['escape']);
    final hoverPort.HoverWidget widget = _create(fixture, <String, dynamic>{});
    widget.domNode.dispatchEvent(
      dom.EventType.KEY_DOWN,
      dom.DomKeyboardEvent(dom.EventType.KEY_DOWN)..keyCode = 27,
    );
    expect(widget.isDisposed, expected['isDisposed']);
  });
}

Map<String, dynamic> _layoutConfig(String name) {
  switch (name) {
    case 'above-falls-back-below':
      return <String, dynamic>{
        'options': <String, Object?>{
          'position': <String, Object?>{'hoverPosition': 3},
        },
      };
    case 'below':
      return <String, dynamic>{
        'options': <String, Object?>{
          'position': <String, Object?>{'hoverPosition': 2},
        },
      };
    case 'below-with-pointer':
      return <String, dynamic>{
        'options': <String, Object?>{
          'style': 1,
          'appearance': <String, Object?>{'showPointer': true},
          'position': <String, Object?>{'hoverPosition': 2},
        },
      };
    case 'right-with-pointer':
      return <String, dynamic>{
        'options': <String, Object?>{
          'style': 1,
          'appearance': <String, Object?>{'showPointer': true},
          'position': <String, Object?>{'hoverPosition': 1},
        },
      };
    case 'left-with-pointer':
      return <String, dynamic>{
        'options': <String, Object?>{
          'style': 1,
          'appearance': <String, Object?>{'showPointer': true},
          'position': <String, Object?>{'hoverPosition': 0},
        },
      };
    case 'right-no-room-flips-left':
      return <String, dynamic>{
        'targetRect': <String, Object?>{
          'left': 700,
          'top': 100,
          'right': 980,
          'bottom': 140,
          'width': 280,
          'height': 40,
        },
        'options': <String, Object?>{
          'position': <String, Object?>{'hoverPosition': 1},
        },
      };
    case 'right-no-room-anywhere-flips-below':
      return <String, dynamic>{
        'targetRect': <String, Object?>{
          'left': 60,
          'top': 100,
          'right': 980,
          'bottom': 140,
          'width': 920,
          'height': 40,
        },
        'options': <String, Object?>{
          'position': <String, Object?>{'hoverPosition': 1},
        },
      };
    case 'left-no-room-flips-right':
      return <String, dynamic>{
        'targetRect': <String, Object?>{
          'left': 5,
          'top': 100,
          'right': 200,
          'bottom': 140,
          'width': 195,
          'height': 40,
        },
        'options': <String, Object?>{
          'position': <String, Object?>{'hoverPosition': 0},
        },
      };
    case 'anchor-right-above-maxwidth':
      return <String, dynamic>{
        'options': <String, Object?>{
          'position': <String, Object?>{'hoverPosition': 3, 'anchorAlignment': 1},
          'appearance': <String, Object?>{'maxHeightRatio': 0.5},
        },
        'sizes': <String, Object?>{
          'containerWidth': 900,
          'containerHeight': 20,
          'containerOffsetHeight': 20,
        },
      };
    case 'force-position-right-maxwidth':
      return <String, dynamic>{
        'options': <String, Object?>{
          'position': <String, Object?>{'hoverPosition': 1, 'forcePosition': true},
        },
      };
    case 'force-position-below-maxheight':
      return <String, dynamic>{
        'options': <String, Object?>{
          'position': <String, Object?>{'hoverPosition': 2, 'forcePosition': true},
        },
      };
    case 'explicit-xy-target':
      return <String, dynamic>{
        'options': <String, Object?>{
          'position': <String, Object?>{'hoverPosition': 1},
        },
        'targetX': 42,
        'targetY': 24,
      };
    case 'clipping-element':
      return <String, dynamic>{
        'options': <String, Object?>{
          'position': <String, Object?>{'hoverPosition': 3},
        },
        'clipRect': <String, Object?>{
          'left': 120,
          'top': 60,
          'right': 260,
          'bottom': 130,
          'width': 140,
          'height': 70,
        },
      };
    case 'scrollbar-padding':
      return <String, dynamic>{
        'options': <String, Object?>{
          'position': <String, Object?>{'hoverPosition': 2},
        },
        'sizes': <String, Object?>{
          'contentsClientHeight': 50,
          'contentsScrollHeight': 300,
          'contentsOffsetHeight': 50,
        },
      };
    case 'max-height-ratio':
      return <String, dynamic>{
        'options': <String, Object?>{
          'appearance': <String, Object?>{'maxHeightRatio': 0.25},
          'position': <String, Object?>{'hoverPosition': 2},
        },
      };
    case 'right-aligned-near-edge':
      return <String, dynamic>{
        'targetRect': <String, Object?>{
          'left': 850,
          'top': 100,
          'right': 990,
          'bottom': 140,
          'width': 140,
          'height': 40,
        },
        'options': <String, Object?>{
          'position': <String, Object?>{'hoverPosition': 2},
        },
      };
  }
  return <String, dynamic>{};
}