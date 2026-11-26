import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import '../lib/src/monaco/editor/browser/view/renderingContext.dart'
    show RenderingContext;
import '../lib/src/monaco/editor/browser/viewParts/lineNumbers/lineNumbers.dart'
    show LineNumbersOverlay;
import '../lib/src/monaco/editor/common/config/editorOptions.dart'
    show EditorOption, RenderLineNumbersType;
import '../lib/src/monaco/editor/common/core/position.dart' show Position;
import '../lib/src/monaco/editor/common/core/range.dart' show Range;
import '../lib/src/monaco/editor/common/core/selection.dart' show Selection;

Map<String, dynamic> _truth() {
  final Map<String, dynamic> root =
      jsonDecode(File('tool/ts2dart/batch435_truth.json').readAsStringSync())
          as Map<String, dynamic>;
  return <String, dynamic>{
    for (final dynamic r in root['results'] as List<dynamic>)
      (r as Map)['label'] as String: <String, dynamic>{
        for (final MapEntry<Object?, Object?> e
            in (r as Map).cast<Object?, Object?>().entries)
          if (e.key != 'label') e.key as String: e.value,
      },
  };
}

class _Converter {
  Position convertViewPositionToModelPosition(Position p) => p;
}

class _ViewModel {
  final int lineCount;
  final Map<int, int> lineLengths;
  final List<dynamic> decorations;
  final _Converter converter = _Converter();
  _ViewModel(this.lineCount, this.lineLengths, this.decorations);

  int getLineCount() => lineCount;
  int getLineLength(int n) => lineLengths[n] ?? 0;
  List<dynamic> getDecorationsInViewport(Range range) => decorations;
  _Converter get coordinatesConverter => converter;
}

class _Options {
  final Map<Object, Object> values;
  _Options(this.values);
  Object get(Object key) => values[key] as Object;
}

class _Context {
  final _Options options;
  final _ViewModel viewModel;
  _Context(this.options, this.viewModel);
  _Context get configuration => this;
  void addEventHandler(Object handler) {}
  void removeEventHandler(Object handler) {}
}

_Context _makeContext({
  int renderType = RenderLineNumbersType.on,
  String Function(int)? renderFn,
  String renderFinalNewline = 'on',
  int lineCount = 5,
  Map<int, int>? lineLengths,
  List<dynamic>? decorations,
}) {
  final Map<Object, Object> values = <Object, Object>{
    EditorOption.lineHeight: 19,
    EditorOption.lineNumbers: <String, Object?>{
      'renderType': renderType,
      'renderFn': renderFn,
    },
    EditorOption.renderFinalNewline: renderFinalNewline,
    EditorOption.layoutInfo: <String, Object>{
      'lineNumbersLeft': 0,
      'lineNumbersWidth': 40,
    },
  };
  return _Context(
    _Options(values),
    _ViewModel(lineCount, lineLengths ?? <int, int>{}, decorations ?? <dynamic>[]),
  );
}

class _RenderCtx implements RenderingContext {
  final Range visibleRange;
  _RenderCtx(this.visibleRange);
  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}

class _SelectionPos {
  final Position p;
  _SelectionPos(this.p);
  Position getPosition() => p;
}

void main() {
  final Map<String, dynamic> truth = _truth();

  test('line numbers truth replay', () {
    final Map<String, Object?> actual = <String, Object?>{};

    void snapshot(
      String label,
      LineNumbersOverlay overlay,
      int start,
      int end,
    ) {
      overlay.prepareRender(_RenderCtx(Range(start, 1, end, 1)));
      final List<String> rendered = <String>[];
      for (int n = start; n <= end; n++) {
        rendered.add(overlay.render(start, n));
      }
      actual[label] = <String, Object?>{'rendered': rendered};
    }

    void cursor(LineNumbersOverlay o, int line) {
      o.onCursorStateChanged(<Object>[_SelectionPos(Position(line, 1))]);
    }

    // On.
    {
      final o = LineNumbersOverlay(_makeContext());
      snapshot('on', o, 1, 5);
    }
    // Off.
    {
      final o = LineNumbersOverlay(
          _makeContext(renderType: RenderLineNumbersType.off));
      snapshot('off', o, 1, 5);
    }
    // Relative with cursor at 3.
    {
      final o = LineNumbersOverlay(
          _makeContext(renderType: RenderLineNumbersType.relative));
      cursor(o, 3);
      snapshot('relative', o, 1, 5);
    }
    // Interval.
    {
      final o = LineNumbersOverlay(
          _makeContext(renderType: RenderLineNumbersType.interval, lineCount: 25));
      cursor(o, 5);
      snapshot('interval', o, 1, 25);
    }
    // Custom.
    {
      final o = LineNumbersOverlay(_makeContext(
        renderType: RenderLineNumbersType.custom,
        renderFn: (int n) => 'L$n',
        lineCount: 3,
      ));
      snapshot('custom', o, 1, 3);
    }
    // Decorations + active.
    {
      final decorations = <dynamic>[
        <String, Object>{
          'range': Range(2, 1, 3, 1),
          'options': <String, Object>{'lineNumberClassName': 'deco-a'},
        },
        <String, Object>{
          'range': Range(3, 1, 4, 1),
          'options': <String, Object>{'lineNumberClassName': 'deco-b'},
        },
        <String, Object>{
          'range': Range(1, 1, 1, 1),
          'options': <String, Object>{'className': 'ignored'},
        },
      ];
      // Implementation reads d.options.lineNumberClassName as named field;
      // use real-ish carriers via a helper class.
      final decs = <Object>[
        _Decoration(Range(2, 1, 3, 1), _DOptions('deco-a')),
        _Decoration(Range(3, 1, 4, 1), _DOptions('deco-b')),
        _Decoration(Range(1, 1, 1, 1), _DOptions(null)),
      ];
      final o = LineNumbersOverlay(_makeContext(decorations: decs));
      cursor(o, 3);
      snapshot('decorations', o, 1, 5);
    }
    // Final newline off / dimmed.
    {
      final o = LineNumbersOverlay(_makeContext(
        renderFinalNewline: 'off',
        lineCount: 3,
        lineLengths: <int, int>{3: 0},
      ));
      snapshot('final-off', o, 1, 3);
    }
    {
      final o = LineNumbersOverlay(_makeContext(
        renderFinalNewline: 'dimmed',
        lineCount: 3,
        lineLengths: <int, int>{3: 0},
      ));
      snapshot('final-dimmed', o, 1, 3);
    }
    // Bounds.
    {
      final o = LineNumbersOverlay(_makeContext());
      o.prepareRender(_RenderCtx(Range(2, 1, 4, 1)));
      actual['bounds'] = <String, Object?>{
        'before': o.render(2, 1),
        'inside': o.render(2, 3),
        'after': o.render(2, 6),
      };
    }

    expect(jsonEncode(actual), jsonEncode(truth));
  });
}

class _DOptions {
  final String? lineNumberClassName;
  _DOptions(this.lineNumberClassName);
}

class _Decoration {
  final Range range;
  final _DOptions options;
  _Decoration(this.range, this.options);
}
