// 1:1 replay of `editor/browser/viewParts/whitespace/whitespace.ts`.
// Truth: `tool/ts2dart/_batch404_truth.cjs` -> `batch404_truth.json`.
import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import '../lib/src/monaco/editor/browser/view/renderingContext.dart'
    show HorizontalPosition, RenderingContext;
import '../lib/src/monaco/editor/browser/viewParts/whitespace/whitespace.dart';
import '../lib/src/monaco/editor/common/config/editorOptions.dart'
    show EditorOption;
import '../lib/src/monaco/editor/common/core/position.dart' show Position;
import '../lib/src/monaco/editor/common/core/selection.dart' show Selection;
import '../lib/src/monaco/editor/common/viewEventHandler.dart'
    show ViewEventHandler;
import '../lib/src/monaco/editor/common/viewLayout/viewLinesViewportData.dart';

Map<String, dynamic> _map(dynamic v) => (v as Map).cast<String, dynamic>();

Map<String, dynamic> _truth() {
  final Map<String, dynamic> root = _map(
    jsonDecode(File('tool/ts2dart/batch404_truth.json').readAsStringSync()),
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
  final num spaceWidth, middotWidth, wsmiddotWidth;
  final bool canUseHalfwidthRightwardsArrow;
  _FontInfo(this.spaceWidth, this.middotWidth, this.wsmiddotWidth,
      this.canUseHalfwidthRightwardsArrow);
}

class _Config implements IWhitespaceConfiguration {
  Map<Object?, Object?> values;
  final Set<Object?> changed;
  _Config(this.values, this.changed);

  @override
  IWhitespaceEditorOptions get options => _Options(this);

  @override
  bool hasChanged(Object id) => changed.contains(id);
}

class _Options implements IWhitespaceEditorOptions {
  final _Config config;
  _Options(this.config);

  @override
  Object? get(Object id) => config.values[id];
}

class _LineData {
  final String content;
  final int minColumn, maxColumn;
  final bool continuesWithWrappedLine;
  _LineData(this.content, this.minColumn, this.maxColumn,
      this.continuesWithWrappedLine);
}

class _ViewModel {
  final List<_LineData> lines;
  _ViewModel(this.lines);
  Object getViewLineRenderingData(int lineNumber) => lines[lineNumber - 1];
}

class _Theme {
  Object? getColor(Object color) => '#abc123';
}

class _Context implements IWhitespaceViewContext {
  @override
  _Config configuration;
  @override
  final Object viewModel;
  @override
  final Object theme = _Theme();
  final List<ViewEventHandler> handlers = <ViewEventHandler>[];

  _Context(this.configuration, this.viewModel);

  @override
  void addEventHandler(ViewEventHandler h) => handlers.add(h);

  @override
  void removeEventHandler(ViewEventHandler h) => handlers.remove(h);
}

class _RenderCtx implements RenderingContext {
  final int start, end;
  final List<int>? visibleColumns;
  final num spaceWidth;
  _RenderCtx(this.start, this.end, this.spaceWidth, this.visibleColumns);

  @override
  ViewportData get viewportData => ViewportData(
        <Selection>[],
        IPartialViewLinesViewportData(
          startLineNumber: start,
          endLineNumber: end,
          relativeVerticalOffset: <num>[],
          bigNumbersDelta: 0,
          lineHeight: 20,
        ),
        <Object>[],
        _ViewportModel(),
      );

  @override
  num getLineHeightForLineNumber(int lineNumber) => 20;

  @override
  HorizontalPosition? visibleRangeForPosition(Position pos) {
    if (visibleColumns != null && !visibleColumns!.contains(pos.column)) {
      return null;
    }
    final num left = (pos.column - 1) * spaceWidth;
    return HorizontalPosition(false, left);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}

class _ViewportModel implements IViewModelForViewportData {
  @override
  int getLineMinColumn(int lineNumber) => 1;

  @override
  int getLineMaxColumn(int lineNumber) => 100;

  @override
  Object getViewportViewLineRenderingData(Object range, int lineNumber) =>
      Object();

  @override
  bool getViewLineContinuesWithWrappedLine(int lineNumber) => false;

  @override
  List<Object> getDecorationsInViewport(Object visibleRange) => <Object>[];
}

_Config configFrom(Map<String, dynamic> opts) {
  final num spaceWidth = (opts['spaceWidth'] ?? 10) as num;
  final num middotWidth = (opts['middotWidth'] ?? 5) as num;
  final num wsmiddotWidth = (opts['wsmiddotWidth'] ?? 6) as num;
  final String rendering = (opts['rendering'] ?? 'html') as String;
  final String renderWhitespace =
      (opts['renderWhitespace'] ?? 'all') as String;
  return _Config(
    <Object?, Object?>{
      EditorOption.fontInfo: _FontInfo(
        spaceWidth,
        middotWidth,
        wsmiddotWidth,
        (opts['arrow'] ?? false) as bool,
      ),
      EditorOption.experimentalWhitespaceRendering: rendering,
      EditorOption.renderWhitespace: renderWhitespace,
      EditorOption.lineHeight: (opts['lineHeight'] ?? 20) as num,
      EditorOption.stopRenderingLineAfter: (opts['stopAfter'] ?? -1) as num,
    },
    <Object?>{},
  );
}

List<Object?> renderCase(
  Map<String, dynamic> raw, {
  List<Object?>? selections,
  List<int>? visibleColumns,
}) {
  final _Config config = configFrom(_map(raw['opts'] ?? <String, dynamic>{}));
  final List<_LineData> lines = <_LineData>[];
  for (final dynamic l in raw['lines'] as List<dynamic>) {
    final Map<String, dynamic> lm = _map(l);
    lines.add(_LineData(
      lm['content'] as String,
      lm['minColumn'] as int? ?? 1,
      lm['maxColumn'] as int? ??
          ((lm['content'] as String).length + 1),
      lm['continuesWithWrappedLine'] as bool? ?? false,
    ));
  }
  final _Context ctx = _Context(config, _ViewModel(lines));
  final WhitespaceOverlay overlay = WhitespaceOverlay(ctx);
  if (selections != null) {
    final List<Selection> sels = <Selection>[];
    for (final dynamic s in selections) {
      final Map<String, dynamic> sm = _map(s);
      sels.add(Selection(
        sm['startLineNumber'] as int,
        sm['startColumn'] as int,
        sm['endLineNumber'] as int,
        sm['endColumn'] as int,
      ));
    }
    overlay.onCursorStateChanged(<Object, Object?>{'selections': sels});
  }
  final int start = (raw['start'] ?? 1) as int;
  final int end = (raw['end'] ?? lines.length) as int;
  final num spaceWidth = config.values[EditorOption.fontInfo] == null
      ? 10
      : (config.values[EditorOption.fontInfo] as _FontInfo).spaceWidth;
  overlay.prepareRender(_RenderCtx(start, end, spaceWidth, visibleColumns));
  final List<Object?> rendered = <Object?>[];
  for (int ln = start; ln <= end; ln++) {
    rendered.add(overlay.render(start, ln));
  }
  overlay.dispose();
  return rendered;
}

void main() {
  final Map<String, dynamic> truth = _truth();

  test('whitespace overlay replay TS truth', () {
    final Map<String, Object?> actual = <String, Object?>{};

    // Cases 1-10: rendering. Truth cases carry inline opts/lines so the Dart
    // side is driven entirely by JSON (no hand-coded duplication of fixtures).
    final Map<String, Map<String, dynamic>> fixtures =
        <String, Map<String, dynamic>>{
      'all-html': <String, dynamic>{
        'opts': <String, dynamic>{
          'renderWhitespace': 'all',
          'middotWidth': 5,
          'wsmiddotWidth': 6,
        },
        'lines': <dynamic>[<String, dynamic>{'content': 'a\t b'}],
      },
      'all-html-arrow': <String, dynamic>{
        'opts': <String, dynamic>{
          'renderWhitespace': 'all',
          'arrow': true,
        },
        'lines': <dynamic>[<String, dynamic>{'content': '\ta'}],
      },
      'boundary': <String, dynamic>{
        'opts': <String, dynamic>{'renderWhitespace': 'boundary'},
        'lines': <dynamic>[<String, dynamic>{'content': ' a b '}],
      },
      'trailing': <String, dynamic>{
        'opts': <String, dynamic>{'renderWhitespace': 'trailing'},
        'lines': <dynamic>[
          <String, dynamic>{'content': 'a  ', 'continuesWithWrappedLine': false},
          <String, dynamic>{'content': 'b  ', 'continuesWithWrappedLine': true},
          <String, dynamic>{'content': '   '},
        ],
      },
      'svg': <String, dynamic>{
        'opts': <String, dynamic>{
          'renderWhitespace': 'all',
          'rendering': 'svg',
          'spaceWidth': 14,
          'lineHeight': 20,
        },
        'lines': <dynamic>[<String, dynamic>{'content': 'a \tb'}],
      },
      'stop-after': <String, dynamic>{
        'opts': <String, dynamic>{
          'renderWhitespace': 'all',
          'stopAfter': 3,
        },
        'lines': <dynamic>[<String, dynamic>{'content': 'a b c d e'}],
      },
      'visible-range': <String, dynamic>{
        'opts': <String, dynamic>{'renderWhitespace': 'all'},
        'lines': <dynamic>[<String, dynamic>{'content': 'a b c'}],
      },
    };
    for (final MapEntry<String, Map<String, dynamic>> entry
        in fixtures.entries) {
      final List<Object?>? selections = entry.key == 'selection'
          ? <Object?>[
              <String, Object?>{
                'startLineNumber': 1,
                'startColumn': 2,
                'endLineNumber': 1,
                'endColumn': 5,
              },
            ]
          : null;
      final List<int>? visible =
          entry.key == 'visible-range' ? <int>[2] : null;
      actual[entry.key] = <String, Object?>{
        'rendered': renderCase(
          entry.value,
          selections: selections,
          visibleColumns: visible,
        ),
      };
    }

    // selection & selection-none need selection fixtures.
    actual['selection'] = <String, Object?>{
      'rendered': renderCase(
        <String, dynamic>{
          'opts': <String, dynamic>{'renderWhitespace': 'selection'},
          'lines': <dynamic>[<String, dynamic>{'content': 'a b c d'}],
        },
        selections: <Object?>[
          <String, Object?>{
            'startLineNumber': 1,
            'startColumn': 2,
            'endLineNumber': 1,
            'endColumn': 5,
          },
        ],
      ),
    };
    actual['selection-none'] = <String, Object?>{
      'rendered': renderCase(
        <String, dynamic>{
          'opts': <String, dynamic>{'renderWhitespace': 'selection'},
          'lines': <dynamic>[<String, dynamic>{'content': 'a b'}],
        },
        selections: <Object?>[
          <String, Object?>{
            'startLineNumber': 2,
            'startColumn': 1,
            'endLineNumber': 3,
            'endColumn': 1,
          },
        ],
      ),
    };

    // Case 1: none — renderer produces no result at all.
    final _Config nconfig = configFrom(<String, dynamic>{
      'renderWhitespace': 'none',
    });
    final _Context nctx = _Context(nconfig, _ViewModel(<_LineData>[
      _LineData('a b', 1, 4, false),
    ]));
    final WhitespaceOverlay noverlay = WhitespaceOverlay(nctx);
    noverlay.prepareRender(_RenderCtx(1, 1, 10, null));
    actual['none'] = <String, Object?>{
      'value': noverlay.render(1, 1),
      'handlers': nctx.handlers.length,
    };
    noverlay.dispose();

    // Case 11: events.
    final _Config econfig = configFrom(<String, dynamic>{
      'renderWhitespace': 'all',
    });
    final _Context ectx = _Context(econfig, _ViewModel(<_LineData>[
      _LineData('a b', 1, 4, false),
    ]));
    final WhitespaceOverlay overlay = WhitespaceOverlay(ectx);
    ectx.configuration = configFrom(<String, dynamic>{
      'renderWhitespace': 'all',
    });
    final bool same = overlay.onConfigurationChanged(<Object, Object?>{
      'hasChanged': (Object id) => false,
    });
    ectx.configuration = configFrom(<String, dynamic>{
      'renderWhitespace': 'none',
    });
    final bool diff = overlay.onConfigurationChanged(<Object, Object?>{
      'hasChanged': (Object id) => false,
    });
    ectx.configuration = configFrom(<String, dynamic>{
      'renderWhitespace': 'none',
    });
    final bool layoutOnly = overlay.onConfigurationChanged(<Object, Object?>{
      'hasChanged': (Object id) => id == EditorOption.layoutInfo,
    });
    final bool cursorAll = overlay.onCursorStateChanged(<Object, Object?>{
      'selections': <Selection>[],
    });

    final _Config selconfig = configFrom(<String, dynamic>{
      'renderWhitespace': 'selection',
    });
    final _Context selctx = _Context(selconfig, _ViewModel(<_LineData>[
      _LineData('a', 1, 2, false),
    ]));
    final WhitespaceOverlay selOverlay = WhitespaceOverlay(selctx);
    final bool cursorSelRet =
        selOverlay.onCursorStateChanged(<Object, Object?>{
      'selections': <Selection>[],
    });

    actual['events'] = <String, Object?>{
      'data': <String, Object?>{
        'same': same,
        'diff': diff,
        'layoutOnly': layoutOnly,
        'cursorAll': cursorAll,
        'cursorSelRet': cursorSelRet,
        'decorations': overlay.onDecorationsChanged(<Object, Object?>{}),
        'flushed': overlay.onFlushed(<Object, Object?>{}),
        'linesChanged': overlay.onLinesChanged(<Object, Object?>{}),
        'linesDeleted': overlay.onLinesDeleted(<Object, Object?>{}),
        'linesInserted': overlay.onLinesInserted(<Object, Object?>{}),
        'scrollTop': overlay.onScrollChanged(<Object, Object?>{
          'scrollTopChanged': true,
        }),
        'scrollOther': overlay.onScrollChanged(<Object, Object?>{
          'scrollTopChanged': false,
        }),
        'zones': overlay.onZonesChanged(<Object, Object?>{}),
      },
    };
    overlay.dispose();
    selOverlay.dispose();

    for (final String key in truth.keys) {
      expect(
        jsonEncode(actual[key]),
        jsonEncode(truth[key]),
        reason: 'mismatch at $key',
      );
    }
  });
}
