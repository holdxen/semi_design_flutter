import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import '../lib/src/monaco/editor/browser/view/renderingContext.dart'
    show RestrictedRenderingContext;
import '../lib/src/monaco/editor/browser/viewParts/blockDecorations/blockDecorations.dart'
    show BlockDecorations, BlockDecorationsEnvironment, IBlockNode;
import '../lib/src/monaco/editor/common/config/editorOptions.dart'
    show EditorOption;
import '../lib/src/monaco/editor/common/core/range.dart' show Range;
import '../lib/src/monaco/editor/common/viewModel.dart' show ViewModelDecoration;

Map<String, dynamic> _truth() {
  final Map<String, dynamic> root =
      jsonDecode(File('tool/ts2dart/batch437_truth.json').readAsStringSync())
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

Object? _norm(Object? v) => v is num && v == v.round() ? v.toInt() : v;
List<Object?> _normOp(List<Object?> o) => o.map(_norm).toList();

class _Node implements IBlockNode {
  final int id;
  final List<List<Object?>> ops;
  _Node(this.id, this.ops);
  @override
  void setAttribute(String n, String v) => ops.add(<Object?>['attr', id, n, v]);
  @override
  void setClassName(String c) => ops.add(<Object?>['class', id, c]);
  @override
  void appendChild(IBlockNode c) => ops.add(<Object?>['append', id, (c as _Node).id]);
  @override
  void setLeft(Object v) => ops.add(<Object?>['left', id, v]);
  @override
  void setWidth(Object v) => ops.add(<Object?>['width', id, v]);
  @override
  void setTop(Object v) => ops.add(<Object?>['top', id, v]);
  @override
  void setHeight(Object v) => ops.add(<Object?>['height', id, v]);
  @override
  void remove() => ops.add(<Object?>['remove', id]);
}

class _Options {
  final Map<Object, Object> values;
  _Options(this.values);
  Object get(Object key) => values[key] as Object;
}

class _Context {
  final _Options options;
  _Context(this.options);
  _Context get configuration => this;
}

_Context _ctx({num contentWidth = 600, num vsw = 10, num contentLeft = 50}) {
  return _Context(_Options(<Object, Object>{
    EditorOption.layoutInfo: <String, Object>{
      'contentWidth': contentWidth,
      'verticalScrollbarWidth': vsw,
      'contentLeft': contentLeft,
    },
  }));
}

class _Decoration {
  final Range range;
  final Map<String, Object> options;
  _Decoration(this.range, this.options);
}

_Decoration _dec(int start, int end, Map<String, Object> opts) =>
    _Decoration(Range(start, 1, end, 1), opts);

class _RenderCtx implements RestrictedRenderingContext {
  final List<dynamic> decorations;
  final num scrollTop;
  _RenderCtx(this.decorations, this.scrollTop);
  @override
  List<ViewModelDecoration> getDecorationsInViewport() =>
      decorations.cast<ViewModelDecoration>();
  num getVerticalOffsetForLineNumber(int line, [bool? include]) =>
      line * 20 + ((include == true) ? 5 : 0);
  num getVerticalOffsetAfterLineNumber(int line, [bool? include]) =>
      line * 20 + 18 + ((include == true) ? 2 : 0);
  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}

void main() {
  final Map<String, dynamic> truth = _truth();

  test('block decorations truth replay', () {
    final Map<String, Object?> actual = <String, Object?>{};
    final List<List<Object?>> ops = <List<Object?>>[];
    int nodeId = 0;
    BlockDecorations makePart([_Context? ctx]) => BlockDecorations(
          ctx ?? _ctx(),
          BlockDecorationsEnvironment(() => _Node(nodeId++, ops)),
        );

    void labelOps(String label) {
      actual[label] = <String, Object?>{
        'ops': ops.map(_normOp).toList(),
      };
      ops.clear();
    }

    // Case 1: construct + two blocks with padding.
    {
      nodeId = 0;
      final part = makePart(_ctx(contentWidth: 800, vsw: 15, contentLeft: 100));
      labelOps('construct');
      part.render(_RenderCtx(<dynamic>[
        _dec(2, 4, <String, Object>{
          'blockClassName': 'block-a',
          'blockPadding': <int>[2, 3, 4, 5],
        }),
        _dec(6, 6, <String, Object>{'blockClassName': 'block-b'}),
      ], 50));
      labelOps('render-two');
    }
    // Case 2: blockIsAfterEnd.
    {
      nodeId = 0;
      final part = makePart();
      part.render(_RenderCtx(<dynamic>[
        _dec(3, 3, <String, Object>{
          'blockClassName': 'after',
          'blockIsAfterEnd': true,
        }),
      ], 0));
      labelOps('after-end');
    }
    // Case 3: collapsed empty range.
    {
      nodeId = 0;
      final part = makePart();
      part.render(_RenderCtx(<dynamic>[
        _dec(4, 4, <String, Object>{'blockClassName': 'collapsed'}),
      ], 0));
      labelOps('collapsed');
    }
    // Case 4: blockDoesNotCollapse.
    {
      nodeId = 0;
      final part = makePart();
      part.render(_RenderCtx(<dynamic>[
        _dec(4, 4, <String, Object>{
          'blockClassName': 'no-collapse',
          'blockDoesNotCollapse': true,
        }),
      ], 0));
      labelOps('no-collapse');
    }
    // Case 5: node reuse + removal.
    {
      nodeId = 0;
      final part = makePart();
      part.render(_RenderCtx(<dynamic>[
        _dec(1, 1, <String, Object>{'blockClassName': 'x'}),
        _dec(2, 2, <String, Object>{'blockClassName': 'y'}),
      ], 0));
      labelOps('two');
      part.render(_RenderCtx(<dynamic>[
        _dec(1, 1, <String, Object>{'blockClassName': 'x'}),
      ], 0));
      labelOps('one');
      part.render(_RenderCtx(<dynamic>[], 0));
      labelOps('none');
    }
    // Case 6: handlers + render after config.
    {
      nodeId = 0;
      final Map<Object, Object> values = <Object, Object>{
        EditorOption.layoutInfo: <String, Object>{
          'contentWidth': 800,
          'verticalScrollbarWidth': 15,
          'contentLeft': 100,
        },
      };
      final part = makePart(_Context(_Options(values)));
      final bool c1 = part.onConfigurationChanged(<String, Object>{});
      values[EditorOption.layoutInfo] = <String, Object>{
        'contentWidth': 700,
        'verticalScrollbarWidth': 15,
        'contentLeft': 90,
      };
      final bool c2 = part.onConfigurationChanged(<String, Object>{});
      final bool c3 = part.onConfigurationChanged(<String, Object>{});
      final bool s1 = part.onScrollChanged(<String, Object>{
        'scrollTopChanged': true,
        'scrollLeftChanged': false,
      });
      final bool s2 = part.onScrollChanged(<String, Object>{
        'scrollTopChanged': false,
        'scrollLeftChanged': false,
      });
      actual['handlers'] = <String, Object?>{
        'c1': c1, 'c2': c2, 'c3': c3, 's1': s1, 's2': s2,
        'd': part.onDecorationsChanged(<String, Object>{}),
        'z': part.onZonesChanged(<String, Object>{}),
      };
      part.render(_RenderCtx(<dynamic>[
        _dec(1, 1, <String, Object>{'blockClassName': 'z'}),
      ], 0));
      labelOps('render-after-config');
    }

    expect(jsonEncode(actual), jsonEncode(truth));
  });
}
