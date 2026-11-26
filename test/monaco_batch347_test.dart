// 1:1 replay of
//   `editor/browser/viewParts/viewZones/viewZones.ts` (423 lines).
// Truth: `tool/ts2dart/_batch347_truth.cjs` -> `batch347_truth.json`.
import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:semi_design_flutter/src/monaco/base/common/scrollable.dart'
    show ScrollEvent;
import 'package:semi_design_flutter/src/monaco/editor/browser/view/renderingContext.dart'
    show IViewLayoutForRenderingContext, RestrictedRenderingContext;
import 'package:semi_design_flutter/src/monaco/editor/browser/viewParts/viewZones/viewZones.dart'
    show
        IViewZoneChangeAccessorForViewZones,
        IViewZonesDomElement,
        IViewZonesFastDomNode,
        ViewZones,
        configureViewZonesElementFactoryForReplay,
        configureViewZonesFastDomNodeFactoryForReplay,
        configureViewZonesUnexpectedErrorForReplay;
import 'package:semi_design_flutter/src/monaco/editor/common/config/editorOptions.dart'
    show ConfigurationChangedEvent, EditorOption;
import 'package:semi_design_flutter/src/monaco/editor/common/core/position.dart'
    show Position;
import 'package:semi_design_flutter/src/monaco/editor/common/core/range.dart'
    show Range;
import 'package:semi_design_flutter/src/monaco/editor/common/core/selection.dart'
    show Selection;
import 'package:semi_design_flutter/src/monaco/editor/common/viewEvents.dart'
    show ViewScrollChangedEvent;
import 'package:semi_design_flutter/src/monaco/editor/common/viewLayout/viewLinesViewportData.dart'
    show
        IPartialViewLinesViewportData,
        IViewModelForViewportData,
        ViewportData;
import 'package:semi_design_flutter/src/monaco/editor/common/viewModel.dart'
    show Viewport;
import 'package:semi_design_flutter/src/monaco/editor/common/viewModel/viewContext.dart'
    show
        IEditorConfigurationForViewContext,
        IViewLayoutForViewContext,
        IViewModelForViewContext,
        ViewContext;
import 'package:semi_design_flutter/src/monaco/editor/common/viewEventHandler.dart'
    show ViewEventHandler;
import 'package:semi_design_flutter/src/monaco/platform/theme/common/themeService.dart'
    show IColorTheme;

final Map<String, dynamic> _truth =
    jsonDecode(File('tool/ts2dart/batch347_truth.json').readAsStringSync())
        as Map<String, dynamic>;

List<Object?> _truthList(Object? value) => (value as List).cast<Object?>();
Map<String, dynamic> _truthMap(Object? value) =>
    (value as Map).cast<String, dynamic>();

class _Element implements IViewZonesDomElement {
  _Element(this.state, this.id, this.label);

  final _Harness state;
  final String id;
  final String label;
  String className = '';

  @override
  final Map<String, String> style = <String, String>{};
  final Map<String, String> attrs = <String, String>{};
  final List<_Element> children = <_Element>[];

  @override
  void remove() {
    state.calls.add(<Object?>['remove', id]);
    state.nodes.remove(id);
  }

  Map<String, Object?> snapshot() => <String, Object?>{
        'id': id,
        'label': label,
        'className': className,
        'style': Map<String, String>.from(style),
        'attrs': Map<String, String>.from(attrs),
      };
}

class _FastNode implements IViewZonesFastDomNode {
  _FastNode(this.state, this.element);

  final _Harness state;
  final _Element element;

  @override
  Object get domNode => element;

  @override
  void setClassName(String value) {
    element.className = value;
    state.calls.add(<Object?>['className', element.id, value]);
  }

  @override
  void setPosition(String value) =>
      state.calls.add(<Object?>['position', element.id, value]);

  @override
  void setAttribute(String name, String value) {
    element.attrs[name] = value;
    state.calls.add(<Object?>['attr', element.id, '$name=$value']);
  }

  @override
  void removeAttribute(String name) {
    element.attrs.remove(name);
    state.calls.add(<Object?>['removeAttr', element.id, name]);
  }

  @override
  void setDisplay(String value) =>
      state.calls.add(<Object?>['display', element.id, value]);

  @override
  void setTop(Object value) =>
      state.calls.add(<Object?>['top', element.id, value]);

  @override
  void setHeight(Object value) =>
      state.calls.add(<Object?>['height', element.id, value]);

  @override
  void setWidth(Object value) =>
      state.calls.add(<Object?>['width', element.id, value]);

  @override
  void appendChild(IViewZonesFastDomNode child) {
    final _Element childElement = child.domNode as _Element;
    state.calls.add(<Object?>['append', element.id, childElement.id]);
    element.children.add(childElement);
  }
}

class _Options {
  const _Options(this.values);
  final Map<int, Object?> values;
  Object? get(Object id) => values[id as int];
}

class _Configuration implements IEditorConfigurationForViewContext {
  const _Configuration(this.options);
  final _Options options;
}

class _LayoutInfo {
  const _LayoutInfo(this.contentWidth, this.contentLeft);
  final num contentWidth;
  final num contentLeft;
}

class _Theme implements IColorTheme {
  const _Theme();
  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}

class _Whitespace {
  _Whitespace(this.id, this.afterLineNumber, this.height, this.minWidth);
  final String id;
  int afterLineNumber;
  num height;
  final num minWidth;

  Map<String, Object?> snapshot() => <String, Object?>{
        'id': id,
        'afterLineNumber': afterLineNumber,
        'height': height,
        'minWidth': minWidth,
      };
}

class _WhitespaceAccessor {
  const _WhitespaceAccessor(this.state);
  final _Harness state;

  String insertWhitespace(
    int afterLineNumber,
    int ordinal,
    num heightInPx,
    num minWidth,
  ) {
    state.calls.add(<Object?>[
      'insertWhitespace',
      afterLineNumber,
      ordinal,
      heightInPx,
      minWidth,
    ]);
    final String id = 'ws${++state.whitespaceCounter}';
    state.whitespaces
        .add(_Whitespace(id, afterLineNumber, heightInPx, minWidth));
    return id;
  }

  void changeOneWhitespace(String id, int newAfterLineNumber, num newHeight) {
    state.calls.add(<Object?>['changeOneWhitespace', id, newAfterLineNumber, newHeight]);
    for (final _Whitespace whitespace in state.whitespaces) {
      if (whitespace.id == id) {
        whitespace.afterLineNumber = newAfterLineNumber;
        whitespace.height = newHeight;
        return;
      }
    }
  }

  void removeWhitespace(String id) {
    state.calls.add(<Object?>['removeWhitespace', id]);
    state.whitespaces.removeWhere((_Whitespace w) => w.id == id);
  }
}

class _TextModel {
  const _TextModel(this.state);
  final _Harness state;

  Position validatePosition(Object raw) {
    final dynamic value = raw;
    int line = value['lineNumber'] as int;
    if (line < 1) line = 1;
    if (line > state.lineCount) line = state.lineCount;
    final int maxColumn = state.lineMax[line] ?? 20;
    int column = value['column'] as int;
    if (column < 1) column = 1;
    if (column > maxColumn) column = maxColumn;
    return Position(line, column);
  }

  int getLineMaxColumn(int lineNumber) => state.lineMax[lineNumber] ?? 20;
}

class _CoordinatesConverter {
  const _CoordinatesConverter(this.state);
  final _Harness state;

  Position convertModelPositionToViewPosition(
    Position position,
    Object? affinity,
    bool? third,
  ) {
    state.calls.add(<Object?>[
      'convert',
      position.lineNumber,
      position.column,
      affinity,
      third,
    ]);
    return Position(position.lineNumber + state.viewDelta, position.column);
  }

  bool modelPositionIsVisible(Position position) {
    final bool visible = state.visibleLines.contains(position.lineNumber);
    state.calls.add(<Object?>[
      'visible',
      position.lineNumber,
      position.column,
      visible,
    ]);
    return visible;
  }
}

class _ViewLayoutForZones implements IViewLayoutForViewContext {
  const _ViewLayoutForZones(this.state);
  final _Harness state;

  List<Object> getWhitespaces() => state.whitespaces.cast<Object>();
}

class _ViewModelForZones implements IViewModelForViewContext {
  const _ViewModelForZones(this.state);
  final _Harness state;

  @override
  IViewLayoutForViewContext get viewLayout => _ViewLayoutForZones(state);

  @override
  void addViewEventHandler(ViewEventHandler eventHandler) =>
      state.handlers.add(eventHandler);

  @override
  void removeViewEventHandler(ViewEventHandler eventHandler) =>
      state.handlers.remove(eventHandler);

  Object get model => _TextModel(state);
  Object get coordinatesConverter => _CoordinatesConverter(state);

  void changeWhitespace(void Function(dynamic accessor) callback) {
    state.calls.add(<Object?>['changeWhitespace']);
    callback(_WhitespaceAccessor(state));
  }
}

class _RenderingLayout implements IViewLayoutForRenderingContext {
  const _RenderingLayout();

  @override
  num getScrollWidth() => 450;

  @override
  num getScrollHeight() => 200;

  @override
  Viewport getCurrentViewport() => Viewport(10, 0, 300, 100);

  @override
  num getVerticalOffsetForLineNumber(int lineNumber, [bool? includeViewZones]) =>
      lineNumber * 20;

  @override
  num getVerticalOffsetAfterLineNumber(int lineNumber,
          [bool? includeViewZones]) =>
      (lineNumber + 1) * 20;

  @override
  num getLineHeightForLineNumber(int lineNumber) => 20;
}

class _ViewportModelForData implements IViewModelForViewportData {
  const _ViewportModelForData();

  @override
  int getLineMinColumn(int lineNumber) => 1;

  @override
  int getLineMaxColumn(int lineNumber) => 20;

  @override
  Object getViewportViewLineRenderingData(Range visibleRange, int lineNumber) =>
      Object();

  @override
  bool getViewLineContinuesWithWrappedLine(int lineNumber) => false;

  @override
  List<Object> getDecorationsInViewport(Range visibleRange) =>
      const <Object>[];
}

class _VisibleWhitespace {
  const _VisibleWhitespace(this.id, this.afterLineNumber, this.verticalOffset, this.height);
  final String id;
  final int afterLineNumber;
  final num verticalOffset;
  final num height;
}

class _Zone {
  _Zone(
    this.state, {
    required this.label,
    this.afterLineNumber = 1,
    this.heightInPx,
    this.heightInLines,
    this.minWidthInPx,
    this.suppressMouseDown,
    this.onComputedHeight,
    this.onDomNodeTop,
    this.margin = false,
  })  : domNode = state.createElement(label),
        marginDomNode = margin ? state.createElement('$label-margin') : null;

  final _Harness state;
  final String label;
  final int afterLineNumber;
  final num? heightInPx;
  final num? heightInLines;
  final num? minWidthInPx;
  final bool? suppressMouseDown;
  final void Function(num)? onComputedHeight;
  final void Function(num)? onDomNodeTop;
  final bool margin;
  final _Element domNode;
  final _Element? marginDomNode;

  int? get afterColumn => null;
  int? get ordinal => null;
  bool? get showInHiddenArea => null;
  Object? get afterColumnAffinity => null;
}

class _Harness {
  _Harness() {
    final _Harness self = this;
    configureViewZonesElementFactoryForReplay(
      (String tag) => _Element(self, 'el${++self.elementCounter}', tag),
    );
    configureViewZonesFastDomNodeFactoryForReplay(
      (Object domNode) => _FastNode(self, domNode as _Element),
    );
    configureViewZonesUnexpectedErrorForReplay((Object error) {
      self.errors.add(error is StateError ? error.message : error.toString());
    });

    config = _Configuration(_Options(<int, Object?>{
      EditorOption.lineHeight: 20,
      EditorOption.layoutInfo: const _LayoutInfo(500, 20),
    }));
    model = _ViewModelForZones(this);
    context = ViewContext(config, const _Theme(), model);
    viewZones = ViewZones(context);
  }

  late final _Configuration config;
  late final _ViewModelForZones model;
  late final ViewContext context;
  late final ViewZones viewZones;

  final List<Object?> calls = <Object?>[];
  final List<String> errors = <String>[];
  final List<ViewEventHandler> handlers = <ViewEventHandler>[];
  final List<_Whitespace> whitespaces = <_Whitespace>[];
  final Map<String, _Element> nodes = <String, _Element>{};
  final Set<int> visibleLines = <int>{1, 2, 3, 4, 5};
  final Map<int, int> lineMax = <int, int>{
    1: 20,
    2: 20,
    3: 20,
    4: 20,
    5: 20,
  };
  int elementCounter = 0;
  int whitespaceCounter = 0;
  int viewDelta = 0;
  int lineCount = 5;

  _Element createElement(String label) {
    final _Element element = _Element(this, 'el${++elementCounter}', label);
    nodes[element.id] = element;
    return element;
  }

  RestrictedRenderingContext renderContext(
    List<_VisibleWhitespace> visibleWhitespaces, {
    int bigNumbersDelta = 0,
  }) {
    final ViewportData data = ViewportData(
      <Selection>[],
      IPartialViewLinesViewportData(
        startLineNumber: 1,
        endLineNumber: 5,
        relativeVerticalOffset: const <num>[0, 20, 40, 60, 80],
        bigNumbersDelta: bigNumbersDelta,
        lineHeight: 20,
      ),
      visibleWhitespaces.cast<Object>(),
      const _ViewportModelForData(),
    );
    return RestrictedRenderingContext(const _RenderingLayout(), data);
  }
}

ScrollEvent _scrollEvent({required bool top, required bool width}) =>
    ScrollEvent(
      inSmoothScrolling: false,
      oldWidth: 300,
      oldScrollWidth: 450,
      oldScrollLeft: 0,
      width: 300,
      scrollWidth: 450,
      scrollLeft: 0,
      oldHeight: 100,
      oldScrollHeight: 200,
      oldScrollTop: 0,
      height: 100,
      scrollHeight: 200,
      scrollTop: 10,
      widthChanged: false,
      scrollWidthChanged: width,
      scrollLeftChanged: false,
      heightChanged: false,
      scrollHeightChanged: false,
      scrollTopChanged: top,
    );

void main() {
  group('viewZones.ts constructor', () {
    test('sets up root and margin nodes', () {
      final _Harness h = _Harness();
      final Map<String, dynamic> truth = _truthMap(_truth['init']);
      expect(h.calls, equals(_truthList(truth['calls'])));
      expect(h.handlers.length, truth['handlers']);
      expect(
        (h.viewZones.domNode.domNode as _Element).snapshot(),
        equals(_truthMap(truth['domNode'])),
      );
      expect(
        (h.viewZones.marginDomNode.domNode as _Element).snapshot(),
        equals(_truthMap(truth['marginDomNode'])),
      );
    });
  });

  group('viewZones.ts events', () {
    test('configuration, line mapping and scroll handlers', () {
      final _Harness h = _Harness();
      final Map<String, dynamic> truth = _truthMap(_truth['events']);
      final Map<String, dynamic> expected = _truthMap(truth['results']);
      final List<bool> noChanges = List<bool>.filled(180, false);
      final List<bool> lineHeightChanged = List<bool>.filled(180, false)
        ..[EditorOption.lineHeight] = true;

      final Map<String, Object?> results = <String, Object?>{
        'configuration': h.viewZones.onConfigurationChanged(
          ConfigurationChangedEvent(noChanges),
        ),
        'configurationWithLineHeight': h.viewZones.onConfigurationChanged(
          ConfigurationChangedEvent(lineHeightChanged),
        ),
        'lineMapping': h.viewZones.onLineMappingChanged(Object()),
        'linesDeleted': h.viewZones.onLinesDeleted(Object()),
        'scrollTop': h.viewZones.onScrollChanged(
          ViewScrollChangedEvent(_scrollEvent(top: true, width: false)),
        ),
        'scrollWidth': h.viewZones.onScrollChanged(
          ViewScrollChangedEvent(_scrollEvent(top: false, width: true)),
        ),
        'scrollNone': h.viewZones.onScrollChanged(
          ViewScrollChangedEvent(_scrollEvent(top: false, width: false)),
        ),
        'zones': h.viewZones.onZonesChanged(Object()),
        'linesInserted': h.viewZones.onLinesInserted(Object()),
      };
      expect(results, equals(expected));
      expect(h.calls, equals(_truthList(truth['calls'])));
      expect(h.viewZones.shouldRender(), truth['shouldRender']);
    });
  });

  group('viewZones.ts change accessor', () {
    test('add, remove, layout and invalidated accessor', () {
      final _Harness h = _Harness();
      h.viewZones.onDidRender();
      final Map<String, dynamic> truth = _truthMap(_truth['zones']);
      final List<String> ids = <String>[];
      IViewZoneChangeAccessorForViewZones? saved;

      final bool changed = h.viewZones.changeViewZones((accessor) {
        saved = accessor;
        ids.add(accessor.addZone(_Zone(
          h,
          label: 'a',
          afterLineNumber: 2,
          heightInPx: 30,
          minWidthInPx: 100,
          onComputedHeight: (height) =>
              h.calls.add(<Object?>['computedHeight', height]),
        )));
        ids.add(accessor.addZone(_Zone(
          h,
          label: 'b',
          afterLineNumber: 3,
          heightInLines: 2,
          margin: true,
          suppressMouseDown: true,
          onComputedHeight: (_) => throw StateError('boom'),
        )));
        accessor.removeZone('');
        accessor.layoutZone('');
        accessor.removeZone('missing');
        accessor.layoutZone('missing');
        accessor.removeZone(ids[0]);
        accessor.layoutZone(ids[1]);
      });

      final Map<String, Object?> invalid = <String, Object?>{};
      try {
        saved!.addZone(_Zone(h, label: 'invalid'));
      } catch (e) {
        invalid['addZone'] = e is StateError ? e.message : e.toString();
      }
      try {
        saved!.removeZone(ids[1]);
      } catch (e) {
        invalid['removeZone'] = e is StateError ? e.message : e.toString();
      }
      try {
        saved!.layoutZone(ids[1]);
      } catch (e) {
        invalid['layoutZone'] = e is StateError ? e.message : e.toString();
      }

      expect(changed, truth['changed']);
      expect(ids, equals(_truthList(truth['ids'])));
      expect(h.calls, equals(_truthList(truth['calls'])));
      expect(h.errors, equals(_truthList(truth['errors'])));
      expect(invalid, equals(_truthMap(truth['invalid'])));
      expect(h.viewZones.shouldRender(), truth['shouldRender']);
      expect(
        h.viewZones.shouldSuppressMouseDownOnViewZone(ids[1]),
        truth['suppress'],
      );
      expect(
        h.viewZones.shouldSuppressMouseDownOnViewZone('missing'),
        truth['suppressMissing'],
      );
      expect(
        h.whitespaces.map((_Whitespace w) => w.snapshot()).toList(),
        equals(_truthList(truth['whitespaces'])),
      );
    });
  });

  group('viewZones.ts render', () {
    test('visible and hidden zones update DOM nodes', () {
      final _Harness h = _Harness();
      h.viewZones.onDidRender();
      final List<String> ids = <String>[];
      h.viewZones.changeViewZones((accessor) {
        ids.add(accessor.addZone(_Zone(
          h,
          label: 'r1',
          afterLineNumber: 1,
          heightInPx: 20,
          onDomNodeTop: (top) => h.calls.add(<Object?>['domTop', top]),
        )));
        h.visibleLines.remove(5);
        ids.add(accessor.addZone(_Zone(
          h,
          label: 'r2',
          afterLineNumber: 4,
          heightInPx: 40,
          margin: true,
          onDomNodeTop: (top) => h.calls.add(<Object?>['domTop', top]),
        )));
      });
      h.calls.clear();

      final RestrictedRenderingContext ctx = h.renderContext(
        <_VisibleWhitespace>[
          _VisibleWhitespace(ids[0], 1, 100, 20),
          _VisibleWhitespace(ids[1], 4, 200, 40),
        ],
        bigNumbersDelta: 5,
      );
      h.viewZones.render(ctx);

      final Map<String, dynamic> truth = _truthMap(_truth['render']);
      expect(h.calls, equals(_truthList(truth['calls'])));
      expect(h.viewZones.shouldRender(), truth['shouldRender']);
      expect(
        <Object?>[
          (h.viewZones.domNode.domNode as _Element).snapshot(),
          (h.viewZones.marginDomNode.domNode as _Element).snapshot(),
        ],
        equals(_truthList(truth['nodes'])),
      );
    });
  });
}
