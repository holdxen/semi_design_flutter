// 1:1 replay of `editor/common/viewLayout/viewLayout.ts` (490 lines).
// Truth: `tool/ts2dart/_batch339_truth.cjs` -> `batch339_truth.json`.
import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import '../lib/src/monaco/base/common/lifecycle.dart' show IDisposable;
import '../lib/src/monaco/base/common/scrollable.dart'
    show NewScrollPosition, ScrollbarVisibility;
import '../lib/src/monaco/editor/common/config/editorConfiguration.dart'
    show IEditorConfiguration;
import '../lib/src/monaco/editor/common/config/editorOptions.dart'
    show ConfigurationChangedEvent, EditorOption, IComputedEditorOptions;
import '../lib/src/monaco/editor/common/editorCommon.dart' show ScrollType;
import '../lib/src/monaco/editor/common/viewLayout/linesLayout.dart'
    show
        IWhitespaceChangeAccessor,
        PartialViewLinesViewportData,
        ViewWhitespaceViewportData;
import '../lib/src/monaco/editor/common/viewLayout/viewLayout.dart'
    show ViewLayout;
import '../lib/src/monaco/editor/common/viewModel.dart' show Viewport;

Map<String, dynamic> _map(dynamic value) =>
    (value as Map).cast<String, dynamic>();

Map<String, dynamic> _truth() => _map(
      jsonDecode(File('tool/ts2dart/batch339_truth.json').readAsStringSync()),
    );

class _Options implements IComputedEditorOptions {
  const _Options(this.values);

  final Map<int, Object?> values;

  @override
  Object? get(Object id) => values[id as int];
}

class _Config implements IEditorConfiguration {
  const _Config(this.options);

  @override
  final IComputedEditorOptions options;

  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}

class _NoopDisposable implements IDisposable {
  const _NoopDisposable();

  @override
  void dispose() {}
}

class _LayoutInfo {
  const _LayoutInfo(this.contentWidth, this.height, this.verticalScrollbarWidth);
  final num contentWidth;
  final num height;
  final num verticalScrollbarWidth;
}

class _Padding {
  const _Padding(this.top, this.bottom);
  final num top;
  final num bottom;
}

class _Scrollbar {
  const _Scrollbar(this.horizontal, this.horizontalScrollbarSize,
      this.ignoreHorizontalScrollbarInContentHeight);
  final int horizontal;
  final num horizontalScrollbarSize;
  final bool ignoreHorizontalScrollbarInContentHeight;
}

class _WrappingInfo {
  const _WrappingInfo(this.isViewportWrapping);
  final bool isViewportWrapping;
}

class _FontInfo {
  const _FontInfo(this.typicalHalfwidthCharacterWidth);
  final num typicalHalfwidthCharacterWidth;
}

class _Minimap {
  const _Minimap(this.enabled, this.side);
  final bool enabled;
  final String side;
}

Map<String, Object?> _dimensions(ViewLayout layout) => <String, Object?>{
      'contentWidth': layout.getContentWidth(),
      'scrollWidth': layout.getScrollWidth(),
      'contentHeight': layout.getContentHeight(),
      'scrollHeight': layout.getScrollHeight(),
    };

Map<String, Object?> _viewport(Viewport v) => <String, Object?>{
      'top': v.top,
      'left': v.left,
      'width': v.width,
      'height': v.height,
    };

Map<String, Object?> _viewportData(PartialViewLinesViewportData d) =>
    <String, Object?>{
      'bigNumbersDelta': d.bigNumbersDelta,
      'startLineNumber': d.startLineNumber,
      'endLineNumber': d.endLineNumber,
      'relativeVerticalOffset': d.relativeVerticalOffset,
      'centeredLineNumber': d.centeredLineNumber,
      'completelyVisibleStartLineNumber': d.completelyVisibleStartLineNumber,
      'completelyVisibleEndLineNumber': d.completelyVisibleEndLineNumber,
      'lineHeight': d.lineHeight,
    };

Map<String, Object?> _whitespaceData(ViewWhitespaceViewportData d) =>
    <String, Object?>{
      'id': d.id,
      'afterLineNumber': d.afterLineNumber,
      'verticalOffset': d.verticalOffset,
      'height': d.height,
    };

void main() {
  test('view layout replay TS', () {
    final values = <int, Object?>{
      EditorOption.layoutInfo:
          const _LayoutInfo(100, 60, 10),
      EditorOption.padding: const _Padding(5, 7),
      EditorOption.lineHeight: 20,
      EditorOption.scrollbar: const _Scrollbar(
          ScrollbarVisibility.Auto, 12, false),
      EditorOption.scrollBeyondLastLine: false,
      EditorOption.wrappingInfo: const _WrappingInfo(false),
      EditorOption.fontInfo: const _FontInfo(8),
      EditorOption.scrollBeyondLastColumn: 4,
      EditorOption.smoothScrolling: false,
      EditorOption.minimap: const _Minimap(true, 'right'),
    };
    final configuration = _Config(_Options(values));
    final layout = ViewLayout(configuration, 3, const [], (_) =>
        const _NoopDisposable());

    final actual = <String, Object?>{
      'initial': <String, Object?>{
        ..._dimensions(layout),
        'viewport': _viewport(layout.getCurrentViewport()),
        'futureViewport': _viewport(layout.getFutureViewport()),
        'linesViewportData': _viewportData(layout.getLinesViewportData()),
      },
    };

    layout.setMaxLineWidth(200);
    actual['maxLineWidth'] = _dimensions(layout);
    layout.setOverlayWidgetsMinWidth(400);
    actual['overlayWidgets'] = _dimensions(layout);

    layout.setScrollPosition(
        NewScrollPosition(scrollTop: 50, scrollLeft: 30), ScrollType.Immediate);
    final validate = layout.validateScrollPosition(
        NewScrollPosition(scrollTop: 99999, scrollLeft: -5));
    actual['scroll'] = <String, Object?>{
      'current': <String, Object?>{
        'top': layout.getCurrentScrollTop(),
        'left': layout.getCurrentScrollLeft(),
      },
      'viewport': _viewport(layout.getCurrentViewport()),
      'futureViewport': _viewport(layout.getFutureViewport()),
      'saveState': layout.saveState(),
      'validate': <String, Object?>{
        'top': validate.scrollTop,
        'left': validate.scrollLeft,
      },
    };
    layout.deltaScrollNow(10, -20);
    actual['delta'] = <String, Object?>{
      'top': layout.getCurrentScrollTop(),
      'left': layout.getCurrentScrollLeft(),
    };
    actual['clampedViewportData'] =
        _viewportData(layout.getLinesViewportDataAtScrollTop(99999));
    actual['negativeViewportData'] =
        _viewportData(layout.getLinesViewportDataAtScrollTop(-100));

    final whitespaceChanged = layout.changeWhitespace(
        (IWhitespaceChangeAccessor accessor) {
      accessor.insertWhitespace(1, 0, 30, 0);
    });
    final ViewWhitespaceViewportData? atOffset =
        layout.getWhitespaceAtVerticalOffset(10);
    actual['whitespace'] = <String, Object?>{
      'changed': whitespaceChanged,
      ..._dimensions(layout),
      'whitespaces': layout
          .getWhitespaces()
          .map((w) => <String, Object?>{
                'id': w.id,
                'afterLineNumber': w.afterLineNumber,
                'height': w.height,
              })
          .toList(),
      'atOffset': atOffset == null ? null : _whitespaceData(atOffset),
      'viewportData': layout
          .getWhitespaceViewportData()
          .map(_whitespaceData)
          .toList(),
      'saveState': layout.saveState(),
    };

    actual['delegates'] = <String, Object?>{
      'verticalOffsetLine2': layout.getVerticalOffsetForLineNumber(2),
      'verticalOffsetLine2WithZones':
          layout.getVerticalOffsetForLineNumber(2, true),
      'verticalOffsetAfterLine2':
          layout.getVerticalOffsetAfterLineNumber(2),
      'lineHeightLine2': layout.getLineHeightForLineNumber(2),
      'isAfterLines': <bool>[
        layout.isAfterLines(1),
        layout.isAfterLines(1000),
      ],
      'isInTopPadding': <bool>[
        layout.isInTopPadding(1),
        layout.isInTopPadding(10),
      ],
      'isInBottomPadding': <bool>[
        layout.isInBottomPadding(1),
        layout.isInBottomPadding(1000),
      ],
      'lineNumberAtOffset': layout.getLineNumberAtVerticalOffset(50),
    };

    layout.onLinesInserted(2, 3);
    final inserted = _dimensions(layout);
    layout.onLinesDeleted(2, 3);
    final deleted = _dimensions(layout);
    layout.onFlushed(5, const []);
    actual['lineChanges'] = <String, Object?>{
      'inserted': inserted,
      'deleted': deleted,
      'flushed': _dimensions(layout),
    };

    values
      ..[EditorOption.lineHeight] = 24
      ..[EditorOption.padding] = const _Padding(9, 11)
      ..[EditorOption.layoutInfo] = const _LayoutInfo(150, 80, 14)
      ..[EditorOption.scrollBeyondLastLine] = true
      ..[EditorOption.wrappingInfo] = const _WrappingInfo(true)
      ..[EditorOption.smoothScrolling] = true;
    final flags = List<bool>.filled(200, false)
      ..[EditorOption.lineHeight] = true
      ..[EditorOption.padding] = true
      ..[EditorOption.layoutInfo] = true
      ..[EditorOption.scrollBeyondLastLine] = true
      ..[EditorOption.wrappingInfo] = true
      ..[EditorOption.smoothScrolling] = true;
    layout.onConfigurationChanged(ConfigurationChangedEvent(flags));
    actual['configChanged'] = <String, Object?>{
      ..._dimensions(layout),
      'viewport': _viewport(layout.getCurrentViewport()),
      'hasPendingScrollAnimation': layout.hasPendingScrollAnimation(),
    };

    expect(actual, _truth());
  });
}
