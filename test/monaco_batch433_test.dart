import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import '../lib/src/monaco/editor/browser/view/renderingContext.dart'
    show RestrictedRenderingContext;
import '../lib/src/monaco/editor/common/config/editorOptions.dart'
    show EditorOption;
import '../lib/src/monaco/editor/browser/viewParts/scrollDecoration/scrollDecoration.dart'
    show
        IScrollDecorationNode,
        ScrollDecorationEnvironment,
        ScrollDecorationViewPart;

Map<String, dynamic> _truth() {
  final Map<String, dynamic> root =
      jsonDecode(File('tool/ts2dart/batch433_truth.json').readAsStringSync())
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

class _Node implements IScrollDecorationNode {
  final List<List<Object?>> ops = <List<Object?>>[];
  @override
  void setAttribute(String name, String value) =>
      ops.add(<Object?>['attr', name, value]);
  @override
  void setClassName(String className) => ops.add(<Object?>['class', className]);
  @override
  void setWidth(Object width) => ops.add(<Object?>['width', width]);
  List<List<Object?>> snapshot() => ops.map((List<Object?> o) => List<Object?>.from(o)).toList();
}

class _Options {
  final Map<Object, Object> values;
  _Options(this.values);
  Object get(Object key) => values[key]!;
}

class _Configuration {
  final _Options options;
  _Configuration(this.options);
}

class _Context {
  final _Configuration configuration;
  _Context(this.configuration);
}

_Context _makeContext({
  required bool useShadows,
  required int width,
  required int verticalScrollbarWidth,
  required int renderMinimap,
  required int minimapWidth,
  required int minimapLeft,
}) {
  return _Context(_Configuration(_Options(<Object, Object>{
    EditorOption.scrollbar: <String, Object>{'useShadows': useShadows},
    EditorOption.layoutInfo: <String, Object>{
      'width': width,
      'verticalScrollbarWidth': verticalScrollbarWidth,
      'minimap': <String, Object>{
        'renderMinimap': renderMinimap,
        'minimapWidth': minimapWidth,
        'minimapLeft': minimapLeft,
      },
    },
  })));
}

void main() {
  final Map<String, dynamic> truth = _truth();

  // RenderMinimap constants: None=0, Text=1, Blocks=2, Boxes=3.
  const int none = 0;
  const int text = 1;

  test('scroll decoration truth replay', () {
    final Map<String, Object?> actual = <String, Object?>{};

    void record(String label, ScrollDecorationViewPart part, _Node node) {
      part.render(_Ctx());
      actual[label] = <String, Object?>{'ops': node.snapshot()};
      node.ops.clear();
    }

    ScrollDecorationViewPart makePart(_Context ctx, _Node node) =>
        ScrollDecorationViewPart(ctx, ScrollDecorationEnvironment(() => node));

    // Case 1: minimap none.
    {
      final _Node node = _Node();
      final part = makePart(
        _makeContext(useShadows: true, width: 1000, verticalScrollbarWidth: 15,
            renderMinimap: none, minimapWidth: 0, minimapLeft: 1),
        node,
      );
      record('minimap-none', part, node);
      part.onScrollChanged(<String, Object>{'scrollTop': 50});
      record('scrolled', part, node);
      part.onScrollChanged(<String, Object>{'scrollTop': 0});
      record('back-top', part, node);
    }
    // Case 2: minimap left.
    {
      final _Node node = _Node();
      final part = makePart(
        _makeContext(useShadows: true, width: 800, verticalScrollbarWidth: 20,
            renderMinimap: text, minimapWidth: 100, minimapLeft: 0),
        node,
      );
      record('minimap-left', part, node);
    }
    // Case 3: minimap right.
    {
      final _Node node = _Node();
      final part = makePart(
        _makeContext(useShadows: true, width: 800, verticalScrollbarWidth: 20,
            renderMinimap: text, minimapWidth: 100, minimapLeft: 1),
        node,
      );
      record('minimap-right', part, node);
    }
    // Case 4: no shadows.
    {
      final _Node node = _Node();
      final part = makePart(
        _makeContext(useShadows: false, width: 600, verticalScrollbarWidth: 10,
            renderMinimap: none, minimapWidth: 0, minimapLeft: 1),
        node,
      );
      part.onScrollChanged(<String, Object>{'scrollTop': 100});
      record('no-shadows', part, node);
    }
    // Case 5: config change.
    {
      final _Node node = _Node();
      // Use a mutable context so config change can be observed.
      final Map<Object, Object> values = <Object, Object>{
        EditorOption.scrollbar: <String, Object>{'useShadows': true},
        EditorOption.layoutInfo: <String, Object>{
          'width': 500,
          'verticalScrollbarWidth': 10,
          'minimap': <String, Object>{
            'renderMinimap': none,
            'minimapWidth': 0,
            'minimapLeft': 1,
          },
        },
      };
      final _Context ctx = _Context(_Configuration(_Options(values)));
      final part = makePart(ctx, node);
      part.onScrollChanged(<String, Object>{'scrollTop': 30});
      values[EditorOption.scrollbar] = <String, Object>{'useShadows': false};
      values[EditorOption.layoutInfo] = <String, Object>{
        'width': 400,
        'verticalScrollbarWidth': 10,
        'minimap': <String, Object>{
          'renderMinimap': none,
          'minimapWidth': 0,
          'minimapLeft': 1,
        },
      };
      final bool changed = part.onConfigurationChanged(<String, Object>{});
      part.render(_Ctx());
      actual['config-change'] = <String, Object?>{'ops': node.snapshot()};
      actual['config-change-result'] = <String, Object?>{'changed': changed};
    }

    expect(jsonEncode(actual), jsonEncode(truth));
  });
}

class _Ctx implements RestrictedRenderingContext {
  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}
