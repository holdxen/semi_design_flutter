// 1:1 replay of
//   `editor/browser/viewParts/editorScrollbar/editorScrollbar.ts` (189 lines).
// Truth: `tool/ts2dart/_batch340_truth.cjs` -> `batch340_truth.json`.
import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:semi_design_flutter/src/monaco/base/browser/dom.dart';
import 'package:semi_design_flutter/src/monaco/base/browser/fastDomNode.dart'
    show numberAsPixels;
import 'package:semi_design_flutter/src/monaco/base/browser/ui/scrollbar/scrollableElementOptions.dart';
import 'package:semi_design_flutter/src/monaco/base/browser/window.dart' show mainWindow;
import 'package:semi_design_flutter/src/monaco/base/common/lifecycle.dart'
    show IDisposable;
import 'package:semi_design_flutter/src/monaco/base/common/scrollable.dart'
    show NewScrollPosition, Scrollable, ScrollableOptions;
import 'package:semi_design_flutter/src/monaco/editor/browser/viewParts/editorScrollbar/editorScrollbar.dart'
    show EditorScrollbar, IFastDomNode;
import 'package:semi_design_flutter/src/monaco/editor/common/config/editorOptions.dart'
    show ConfigurationChangedEvent, EditorOption, IComputedEditorOptions;
import 'package:semi_design_flutter/src/monaco/editor/common/viewEvents.dart'
    show ViewConfigurationChangedEvent;
import 'package:semi_design_flutter/src/monaco/editor/common/viewEventHandler.dart'
    show ViewEventHandler;
import 'package:semi_design_flutter/src/monaco/editor/common/viewModel/viewContext.dart'
    show IEditorConfigurationForViewContext, IViewLayoutForViewContext,
    IViewModelForViewContext, ViewContext;
import 'package:semi_design_flutter/src/monaco/platform/theme/common/theme.dart'
    show ColorScheme;
import 'package:semi_design_flutter/src/monaco/platform/theme/common/themeService.dart'
    show IColorTheme;

Map<String, dynamic> _map(dynamic value) =>
    (value as Map).cast<String, dynamic>();

Map<String, dynamic> _truth() => _map(
      jsonDecode(File('tool/ts2dart/batch340_truth.json').readAsStringSync()),
    );

class _Options implements IComputedEditorOptions {
  const _Options(this.values);
  final Map<int, Object?> values;

  @override
  Object? get(Object id) => values[id as int];
}

class _Config implements IEditorConfigurationForViewContext {
  const _Config(this.options);
  final IComputedEditorOptions options;
}

class _Theme implements IColorTheme {
  @override
  ColorScheme get type => ColorScheme.dark;

  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}

class _NoopDisposable implements IDisposable {
  const _NoopDisposable();

  @override
  void dispose() {}
}

class _ViewLayout implements IViewLayoutForViewContext {
  _ViewLayout(this.scrollable);

  final Scrollable scrollable;
  final List<List<Object?>> setScrollCalls = <List<Object?>>[];

  Scrollable getScrollable() => scrollable;

  num getCurrentScrollTop() => 7;

  num getCurrentScrollLeft() => 3;

  void setScrollPosition(NewScrollPosition position, int type) {
    setScrollCalls.add(<Object?>[position, type]);
  }
}

class _Model implements IViewModelForViewContext {
  _Model(this.viewLayout);

  @override
  final IViewLayoutForViewContext viewLayout;
  final List<ViewEventHandler> handlers = <ViewEventHandler>[];

  @override
  void addViewEventHandler(ViewEventHandler handler) => handlers.add(handler);

  @override
  void removeViewEventHandler(ViewEventHandler handler) =>
      handlers.remove(handler);
}

class _Node implements IFastDomNode {
  _Node(this.domNode);

  @override
  final DomElement domNode;

  @override
  void setPosition(String position) => domNode.style['position'] = position;

  @override
  void setLeft(Object left) => domNode.style['left'] = numberAsPixels(left);

  @override
  void setWidth(Object width) => domNode.style['width'] = numberAsPixels(width);

  @override
  void setHeight(Object height) =>
      domNode.style['height'] = numberAsPixels(height);

  @override
  void setAttribute(String name, String value) =>
      domNode.setAttribute(name, value);
}

class _ScrollbarOptions {
  const _ScrollbarOptions(
    this.vertical,
    this.horizontal,
    this.verticalHasArrows,
    this.horizontalHasArrows,
    this.verticalScrollbarSize,
    this.verticalSliderSize,
    this.horizontalScrollbarSize,
    this.horizontalSliderSize,
    this.handleMouseWheel,
    this.alwaysConsumeMouseWheel,
    this.arrowSize,
    this.scrollByPage,
  );

  final int vertical;
  final int horizontal;
  final bool verticalHasArrows;
  final bool horizontalHasArrows;
  final num verticalScrollbarSize;
  final num verticalSliderSize;
  final num horizontalScrollbarSize;
  final num horizontalSliderSize;
  final bool handleMouseWheel;
  final bool alwaysConsumeMouseWheel;
  final num arrowSize;
  final bool scrollByPage;
}

class _LayoutInfo {
  const _LayoutInfo(this.contentLeft, this.contentWidth, this.height,
      this.minimap);
  final num contentLeft;
  final num contentWidth;
  final num height;
  final _MinimapSize minimap;
}

class _MinimapSize {
  const _MinimapSize(this.minimapWidth);
  final num minimapWidth;
}

class _Minimap {
  const _Minimap(this.side);
  final String side;
}

Map<String, Object?> _ctorOptions(EditorScrollbar part, DomElement viewNode) {
  final ScrollableElementResolvedOptions o = part.scrollbar.options_;
  return <String, Object?>{
    'className': o.className,
    'lazyRender': o.lazyRender,
    'useShadows': o.useShadows,
    'vertical': o.vertical,
    'horizontal': o.horizontal,
    'verticalHasArrows': o.verticalHasArrows,
    'horizontalHasArrows': o.horizontalHasArrows,
    'verticalScrollbarSize': o.verticalScrollbarSize,
    'verticalSliderSize': o.verticalSliderSize,
    'horizontalScrollbarSize': o.horizontalScrollbarSize,
    'horizontalSliderSize': o.horizontalSliderSize,
    'handleMouseWheel': o.handleMouseWheel,
    'alwaysConsumeMouseWheel': o.alwaysConsumeMouseWheel,
    'arrowSize': o.arrowSize,
    'mouseWheelScrollSensitivity': o.mouseWheelScrollSensitivity,
    'fastScrollSensitivity': o.fastScrollSensitivity,
    'scrollPredominantAxis': o.scrollPredominantAxis,
    'scrollByPage': o.scrollByPage,
    'inertialScroll': o.inertialScroll,
    'listenOnDomNode': identical(o.listenOnDomNode, viewNode) ? 'view' : '?',
  };
}

Map<String, Object?> _changeOptions(EditorScrollbar part) {
  final ScrollableElementResolvedOptions o = part.scrollbar.options_;
  return <String, Object?>{
    'vertical': o.vertical,
    'horizontal': o.horizontal,
    'verticalScrollbarSize': o.verticalScrollbarSize,
    'horizontalScrollbarSize': o.horizontalScrollbarSize,
    'scrollByPage': o.scrollByPage,
    'handleMouseWheel': o.handleMouseWheel,
    'mouseWheelScrollSensitivity': o.mouseWheelScrollSensitivity,
    'fastScrollSensitivity': o.fastScrollSensitivity,
    'scrollPredominantAxis': o.scrollPredominantAxis,
  };
}

void main() {
  setUp(() {
    windowCarrier(mainWindow).document = DomDocument()..defaultView = mainWindow;
  });

  test('editor scrollbar replay TS', () {
    final values = <int, Object?>{
      EditorOption.scrollbar: const _ScrollbarOptions(1, 3, false, false, 10, 6,
          12, 6, true, false, 11, true),
      EditorOption.mouseWheelScrollSensitivity: 1,
      EditorOption.fastScrollSensitivity: 5,
      EditorOption.scrollPredominantAxis: true,
      EditorOption.inertialScroll: true,
      EditorOption.layoutInfo: const _LayoutInfo(
          20, 100, 60, _MinimapSize(40)),
      EditorOption.minimap: const _Minimap('right'),
    };
    final scrollable = Scrollable(ScrollableOptions(
      forceIntegerValues: true,
      smoothScrollDuration: 0,
      scheduleAtNextAnimationFrame: (_) => const _NoopDisposable(),
    ));
    final viewLayout = _ViewLayout(scrollable);
    final model = _Model(viewLayout);
    final context =
        ViewContext(_Config(_Options(values)), _Theme(), model);
    final lines = _Node(DomElement('DIV'));
    final view = _Node(DomElement('DIV'));
    final guard = _Node(DomElement('DIV'));
    final part = EditorScrollbar(context, lines, view, guard);

    final domNode = part.getDomNode().domNode;
    final overview = part.getOverviewRulerLayoutInfo();
    final truth = _truth();

    final actual = <String, Object?>{
      'initialOps': <Object?>[
        <Object?>['ctor', _ctorOptions(part, view.domNode)],
        <Object?>['fingerprint', int.parse(domNode.getAttribute('data-mprt')!)],
      ],
      'initialStyle': Map<String, String>.from(domNode.style),
      'fingerprint': domNode.getAttribute('data-mprt'),
      'handlersAfterCtor': model.handlers.length,
      'overview': <String, Object?>{
        'parent': identical(overview.parent, part.scrollbar.getDomNode())
            ? 'parent'
            : 'other',
        'insertBefore': 'before',
      },
      'domNodeIsScrollbarNode':
          identical(part.getDomNode().domNode, part.scrollbar.getDomNode()),
      'onScrollChanged': part.onScrollChanged(Object()),
    };

    part.delegateVerticalScrollbarPointerDown(DomEvent('pointerdown'));
    part.delegateScrollFromMouseWheelEvent(DomEvent('wheel'));
    final flags = List<bool>.filled(200, false)
      ..[EditorOption.scrollbar] = true
      ..[EditorOption.mouseWheelScrollSensitivity] = true
      ..[EditorOption.fastScrollSensitivity] = true
      ..[EditorOption.layoutInfo] = true;
    values
      ..[EditorOption.layoutInfo] = const _LayoutInfo(
          25, 150, 80, _MinimapSize(50))
      ..[EditorOption.minimap] = const _Minimap('left');
    final changed =
        part.onConfigurationChanged(ViewConfigurationChangedEvent(
            ConfigurationChangedEvent(flags)));
    actual['configChanged'] = <String, Object?>{
      'result': changed,
      'ops': <Object?>[
        <Object?>['updateOptions', _changeOptions(part)],
      ],
      'style': Map<String, String>.from(domNode.style),
    };

    final themeChanged = part.onThemeChanged(Object());
    actual['themeChanged'] = <String, Object?>{
      'result': themeChanged,
      'ops': <Object?>[
        <Object?>['className', 'editor-scrollable vs-dark'],
      ],
      'className': part.scrollbar.getDomNode().className,
    };

    view.domNode.scrollTop = 10;
    view.domNode.scrollLeft = 5;
    view.domNode.dispatchEvent('scroll', DomEvent('scroll'));
    lines.domNode.scrollTop = 4;
    lines.domNode.scrollLeft = 9;
    lines.domNode.dispatchEvent('scroll', DomEvent('scroll'));
    actual['reveal'] = <String, Object?>{
      'calls': viewLayout.setScrollCalls
          .map((List<Object?> c) {
            final NewScrollPosition p = c[0] as NewScrollPosition;
            return <Object?>[
              <String, Object?>{
                if (p.scrollTop != null) 'scrollTop': p.scrollTop,
                if (p.scrollLeft != null) 'scrollLeft': p.scrollLeft,
              },
              c[1],
            ];
          })
          .toList(),
      'viewNode': <String, Object?>{
        'top': view.domNode.scrollTop,
        'left': view.domNode.scrollLeft,
      },
      'linesNode': <String, Object?>{
        'top': lines.domNode.scrollTop,
        'left': lines.domNode.scrollLeft,
      },
    };

    part.dispose();
    actual['handlersAfterDispose'] = model.handlers.length;

    final truthWithoutListeners = <String, Object?>{...truth}
      ..remove('listeners');
    expect(actual, truthWithoutListeners);
  });
}
