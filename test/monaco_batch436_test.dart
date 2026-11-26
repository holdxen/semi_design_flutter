import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import '../lib/src/monaco/editor/browser/view/renderingContext.dart'
    show RenderingContext;
import '../lib/src/monaco/editor/browser/viewParts/currentLineHighlight/currentLineHighlight.dart'
    show
        AbstractLineHighlightOverlay,
        CurrentLineHighlightOverlay,
        CurrentLineMarginHighlightOverlay;
import '../lib/src/monaco/editor/common/config/editorOptions.dart'
    show EditorOption;
import '../lib/src/monaco/editor/common/core/position.dart' show Position;
import '../lib/src/monaco/editor/common/core/range.dart' show Range;
import '../lib/src/monaco/editor/common/core/selection.dart' show Selection;

Map<String, dynamic> _truth() {
  final Map<String, dynamic> root =
      jsonDecode(File('tool/ts2dart/batch436_truth.json').readAsStringSync())
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
  Position convertModelPositionToViewPosition(Position p) => p;
}

class _Model {
  int getLineMaxColumn(int n) => 10;
}

class _ViewModel {
  final _Converter coordinatesConverter = _Converter();
  final _Model model = _Model();
}

class _Options {
  final Map<Object, Object> values;
  _Options(this.values);
  Object get(Object key) => values[key] as Object;
}

class _Context {
  final _Options options;
  final _ViewModel viewModel = _ViewModel();
  _Context(this.options);
  _Context get configuration => this;
  void addEventHandler(Object handler) {}
  void removeEventHandler(Object handler) {}
}

_Context _ctx({
  String renderLineHighlight = 'all',
  bool onlyWhenFocus = false,
  bool wordWrap = false,
  num contentLeft = 100,
  num contentWidth = 800,
}) {
  return _Context(_Options(<Object, Object>{
    EditorOption.layoutInfo: <String, Object>{
      'isViewportWrapping': wordWrap,
      'contentLeft': contentLeft,
      'contentWidth': contentWidth,
    },
    EditorOption.renderLineHighlight: renderLineHighlight,
    EditorOption.renderLineHighlightOnlyWhenFocus: onlyWhenFocus,
  }));
}

class _RenderCtx implements RenderingContext {
  final int start;
  final int end;
  final num scrollWidth;
  _RenderCtx(this.start, this.end, this.scrollWidth);
  Range get visibleRange => Range(start, 1, end, 1);
  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}

void main() {
  final Map<String, dynamic> truth = _truth();

  test('current line highlight truth replay', () {
    final Map<String, Object?> actual = <String, Object?>{};

    void snapshot(
      String label,
      AbstractLineHighlightOverlay overlay,
      int start,
      int end,
      num scrollWidth,
    ) {
      overlay.prepareRender(_RenderCtx(start, end, scrollWidth));
      final List<String> rendered = <String>[];
      for (int n = start; n <= end; n++) {
        rendered.add(overlay.render(start, n));
      }
      actual[label] = <String, Object?>{'rendered': rendered};
    }

    void cursor(AbstractLineHighlightOverlay o, List<Selection> selections) =>
        o.onCursorStateChanged(selections);

    // all
    {
      final o = CurrentLineHighlightOverlay(_ctx());
      cursor(o, <Selection>[Selection(3, 1, 3, 1)]);
      snapshot('content-all', o, 1, 5, 900);
      final m = CurrentLineMarginHighlightOverlay(_ctx());
      cursor(m, <Selection>[Selection(3, 1, 3, 1)]);
      snapshot('margin-all', m, 1, 5, 900);
    }
    // none
    {
      final o = CurrentLineHighlightOverlay(_ctx(renderLineHighlight: 'none'));
      cursor(o, <Selection>[Selection(3, 1, 3, 1)]);
      snapshot('content-none', o, 1, 5, 900);
      final m = CurrentLineMarginHighlightOverlay(_ctx(renderLineHighlight: 'none'));
      cursor(m, <Selection>[Selection(3, 1, 3, 1)]);
      snapshot('margin-none', m, 1, 5, 900);
    }
    // line / gutter
    {
      final o = CurrentLineHighlightOverlay(_ctx(renderLineHighlight: 'line'));
      cursor(o, <Selection>[Selection(2, 1, 2, 1)]);
      snapshot('content-line', o, 1, 5, 500);
    }
    {
      final o = CurrentLineHighlightOverlay(_ctx(renderLineHighlight: 'gutter'));
      cursor(o, <Selection>[Selection(2, 1, 2, 1)]);
      snapshot('content-gutter', o, 1, 5, 500);
    }
    // focus
    {
      final o = CurrentLineHighlightOverlay(_ctx(onlyWhenFocus: true));
      cursor(o, <Selection>[Selection(4, 1, 4, 1)]);
      o.onFocusChanged(<String, Object>{'isFocused': false});
      snapshot('focus-off', o, 1, 5, 700);
      final o2 = CurrentLineHighlightOverlay(_ctx(onlyWhenFocus: true));
      cursor(o2, <Selection>[Selection(4, 1, 4, 1)]);
      o2.onFocusChanged(<String, Object>{'isFocused': true});
      snapshot('focus-on', o2, 1, 5, 700);
    }
    // non-empty selection
    {
      final o = CurrentLineHighlightOverlay(_ctx());
      cursor(o, <Selection>[Selection(2, 1, 4, 1)]);
      snapshot('non-empty-selection', o, 1, 5, 900);
    }
    // multi cursor
    {
      final o = CurrentLineHighlightOverlay(_ctx());
      cursor(o, <Selection>[Selection(2, 1, 2, 1), Selection(4, 1, 4, 1)]);
      snapshot('multi-cursor', o, 1, 6, 900);
    }
    // wordwrap
    {
      final o = CurrentLineHighlightOverlay(_ctx(wordWrap: true));
      cursor(o, <Selection>[Selection(3, 1, 3, 1)]);
      snapshot('wordwrap', o, 1, 5, 900);
    }
    // bounds — JS negative index returns undefined (omitted in JSON)
    {
      final o = CurrentLineHighlightOverlay(_ctx());
      cursor(o, <Selection>[Selection(2, 1, 2, 1)]);
      o.prepareRender(_RenderCtx(2, 4, 900));
      actual['bounds'] = <String, Object?>{
        'inside': o.render(2, 2),
        'after': o.render(2, 6),
      };
    }

    expect(jsonEncode(actual), jsonEncode(truth));
  });
}
