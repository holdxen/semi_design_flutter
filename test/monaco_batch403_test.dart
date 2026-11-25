// 1:1 replay of
//   `editor/browser/viewParts/wordWrapIndicator/wordWrapIndicator.ts`.
// Truth: `tool/ts2dart/_batch403_truth.cjs` -> `batch403_truth.json`.
import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import '../lib/src/monaco/editor/browser/view/renderingContext.dart'
    show RenderingContext;
import '../lib/src/monaco/editor/browser/viewParts/wordWrapIndicator/wordWrapIndicator.dart';
import '../lib/src/monaco/editor/common/config/editorOptions.dart'
    show EditorOption;
import '../lib/src/monaco/editor/common/core/selection.dart' show Selection;
import '../lib/src/monaco/editor/common/viewEventHandler.dart'
    show ViewEventHandler;
import '../lib/src/monaco/editor/common/viewLayout/viewLinesViewportData.dart'
    show IPartialViewLinesViewportData, IViewModelForViewportData, ViewportData;

Map<String, dynamic> _map(dynamic value) =>
    (value as Map).cast<String, dynamic>();

Map<String, dynamic> _truth() {
  final Map<String, dynamic> root = _map(
    jsonDecode(File('tool/ts2dart/batch403_truth.json').readAsStringSync()),
  );
  return <String, dynamic>{
    for (final dynamic r in root['results'] as List<dynamic>)
      (r as Map)['label'] as String: <String, dynamic>{
        for (final MapEntry<Object?, Object?> e
            in (r as Map).cast<Object?, Object?>().entries)
          if (e.key != 'label') e.key as String: e.value,
      },
  };
}

class _FontInfo {
  final double typicalHalfwidthCharacterWidth;
  _FontInfo(this.typicalHalfwidthCharacterWidth);
}

class _WrappingInfo {
  final num wrappingColumn;
  _WrappingInfo(this.wrappingColumn);
}

class _Config implements IWordWrapIndicatorConfiguration {
  bool indicator;
  num wrappingColumn;
  num charWidth;

  _Config(this.indicator, this.wrappingColumn, this.charWidth);

  @override
  IWordWrapIndicatorEditorOptions get options => _Options(this);
}

class _Options implements IWordWrapIndicatorEditorOptions {
  final _Config config;
  _Options(this.config);

  @override
  Object? get(Object id) {
    if (id == EditorOption.fontInfo) {
      return _FontInfo(config.charWidth.toDouble());
    }
    if (id == EditorOption.wrappingInfo) {
      return _WrappingInfo(config.wrappingColumn);
    }
    if (id == EditorOption.wordWrapIndicator) {
      return config.indicator;
    }
    return null;
  }
}

class _Context implements IWordWrapIndicatorViewContext {
  @override
  IWordWrapIndicatorConfiguration configuration;

  final List<ViewEventHandler> handlers = <ViewEventHandler>[];

  _Context(this.configuration);

  @override
  void addEventHandler(ViewEventHandler eventHandler) =>
      handlers.add(eventHandler);

  @override
  void removeEventHandler(ViewEventHandler eventHandler) =>
      handlers.remove(eventHandler);
}

class _Model implements IViewModelForViewportData {
  final Map<int, bool> continues;
  _Model(this.continues);

  @override
  bool getViewLineContinuesWithWrappedLine(int lineNumber) =>
      continues[lineNumber] ?? false;

  @override
  int getLineMinColumn(int lineNumber) => 1;

  @override
  int getLineMaxColumn(int lineNumber) => 10;

  @override
  Object getViewportViewLineRenderingData(Object range, int lineNumber) =>
      Object();

  @override
  List<Object> getDecorationsInViewport(Object visibleRange) => <Object>[];
}

class _RenderCtx implements RenderingContext {
  final ViewportData data;
  final Map<int, num> heights;
  _RenderCtx(this.data, this.heights);

  @override
  ViewportData get viewportData => data;

  @override
  num getLineHeightForLineNumber(int lineNumber) => heights[lineNumber] ?? 0;

  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}

RenderingContext _renderCtx(int start, int end, List<dynamic> continues,
    List<dynamic> heights) {
  final Map<int, bool> cont = <int, bool>{};
  final Map<int, num> hs = <int, num>{};
  for (int i = 0; i < continues.length; i++) {
    cont[start + i] = continues[i] as bool;
    hs[start + i] = heights[i] as num;
  }
  final ViewportData vp = ViewportData(
    <Selection>[],
    IPartialViewLinesViewportData(
      startLineNumber: start,
      endLineNumber: end,
      relativeVerticalOffset: <num>[],
      bigNumbersDelta: 0,
      lineHeight: 19,
    ),
    <Object>[],
    _Model(cont),
  );
  return _RenderCtx(vp, hs);
}

Map<String, Object?> _events(WordWrapIndicatorOverlay overlay) =>
    <String, Object?>{
      'configuration': overlay.onConfigurationChanged(<Object, Object?>{}),
      'decorations': overlay.onDecorationsChanged(<Object, Object?>{}),
      'flushed': overlay.onFlushed(<Object, Object?>{}),
      'lineMapping': overlay.onLineMappingChanged(<Object, Object?>{}),
      'linesChanged': overlay.onLinesChanged(<Object, Object?>{}),
      'linesDeleted': overlay.onLinesDeleted(<Object, Object?>{}),
      'linesInserted': overlay.onLinesInserted(<Object, Object?>{}),
      'scrollTopChanged': overlay.onScrollChanged(
        <Object, Object?>{'scrollTopChanged': true},
      ),
      'scrollOther': overlay.onScrollChanged(
        <Object, Object?>{'scrollTopChanged': false},
      ),
      'tokens': overlay.onTokensChanged(<Object, Object?>{}),
      'zones': overlay.onZonesChanged(<Object, Object?>{}),
    };

void main() {
  final Map<String, dynamic> truth = _truth();

  test('word wrap indicator replay TS truth', () {
    final Map<String, Object?> actual = <String, Object?>{};

    // Case 1: disabled overlay.
    final _Context dctx = _Context(_Config(false, -1, 9));
    final WordWrapIndicatorOverlay disabled =
        WordWrapIndicatorOverlay(dctx);
    actual['disabled-construct'] = <String, Object?>{
      'handlers': dctx.handlers.length,
    };
    actual['disabled-events'] = <String, Object?>{
      'data': _events(disabled),
    };
    actual['disabled-render-null'] = <String, Object?>{
      'value': disabled.render(1, 1),
    };
    disabled.prepareRender(_renderCtx(1, 3, <dynamic>[true, true, true],
        <dynamic>[19, 19, 19]));
    actual['disabled-prepare-render'] = <String, Object?>{
      'value': disabled.render(1, 1),
    };
    disabled.dispose();
    actual['disabled-dispose'] = <String, Object?>{
      'handlers': dctx.handlers.length,
    };

    // Case 2: enabled overlay.
    final _Context ectx = _Context(_Config(true, 20, 9));
    final WordWrapIndicatorOverlay enabled =
        WordWrapIndicatorOverlay(ectx);
    actual['enabled-events'] = <String, Object?>{
      'data': _events(enabled),
    };
    enabled.prepareRender(_renderCtx(5, 8, <dynamic>[true, false, true, false],
        <dynamic>[19, 19, 20, 20]));
    actual['enabled-render'] = <String, Object?>{
      'lines': <Object?>[
        enabled.render(5, 5),
        enabled.render(5, 6),
        enabled.render(5, 7),
        enabled.render(5, 8),
      ],
      'outOfRange': <Object?>[
        enabled.render(5, 4),
        enabled.render(5, 9),
      ],
    };
    enabled.dispose();

    // Case 3: configuration changes.
    final _Context cctx = _Context(_Config(false, -1, 9));
    final WordWrapIndicatorOverlay changing =
        WordWrapIndicatorOverlay(cctx);
    final List<Object?> changes = <Object?>[];
    void change(bool indicator, num column, num width) {
      cctx.configuration = _Config(indicator, column, width);
      changes.add(changing.onConfigurationChanged(<Object, Object?>{}));
    }

    change(true, 20, 9);
    change(true, 20, 9);
    change(true, 30, 9);
    change(true, 30, 10);
    change(false, -1, 9);
    change(false, -1, 12);
    actual['config-changes'] = <String, Object?>{'changes': changes};
    changing.dispose();

    // Case 4: fractional indicatorLeft.
    final _Context fctx = _Context(_Config(true, 17, 7.5));
    final WordWrapIndicatorOverlay fractional =
        WordWrapIndicatorOverlay(fctx);
    fractional.prepareRender(
        _renderCtx(1, 1, <dynamic>[true], <dynamic>[21]));
    actual['fractional-left'] = <String, Object?>{
      'value': fractional.render(1, 1),
    };
    fractional.dispose();

    for (final String key in truth.keys) {
      expect(
        jsonEncode(actual[key]),
        jsonEncode(truth[key]),
        reason: 'mismatch at $key',
      );
    }
  });
}
