import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import '../lib/src/monaco/editor/browser/viewParts/margin/margin.dart'
    show IMarginNode, Margin, MarginEnvironment;
import '../lib/src/monaco/editor/common/config/editorOptions.dart'
    show EditorOption;

Map<String, dynamic> _truth() {
  final Map<String, dynamic> root =
      jsonDecode(File('tool/ts2dart/batch434_truth.json').readAsStringSync())
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

class _Node implements IMarginNode {
  final int id;
  final List<List<Object?>> ops;
  _Node(this.id, this.ops);
  @override
  void setClassName(String c) => ops.add(<Object?>['class', id, c]);
  @override
  void setPosition(String p) => ops.add(<Object?>['position', id, p]);
  @override
  void setAttribute(String n, String v) => ops.add(<Object?>['attr', id, n, v]);
  @override
  void setLayerHinting(bool v) => ops.add(<Object?>['layer', id, v]);
  @override
  void setContain(String v) => ops.add(<Object?>['contain', id, v]);
  @override
  void setTop(Object v) => ops.add(<Object?>['top', id, v]);
  @override
  void setHeight(Object v) => ops.add(<Object?>['height', id, v]);
  @override
  void setWidth(Object v) => ops.add(<Object?>['width', id, v]);
  @override
  void setLeft(Object v) => ops.add(<Object?>['left', id, v]);
  @override
  void appendChild(IMarginNode child) =>
      ops.add(<Object?>['append', id, (child as _Node).id]);
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

_Context _ctx({
  required int contentLeft,
  required int glyphMarginLeft,
  required int glyphMarginWidth,
  required bool disableLayerHinting,
}) {
  return _Context(_Options(<Object, Object>{
    EditorOption.layoutInfo: <String, Object>{
      'contentLeft': contentLeft,
      'glyphMarginLeft': glyphMarginLeft,
      'glyphMarginWidth': glyphMarginWidth,
    },
    EditorOption.disableLayerHinting: disableLayerHinting,
  }));
}

Object? _norm(Object? v) => v is num && v == v.round() ? v.toInt() : v;

List<List<Object?>> _normOps(List<List<Object?>> ops) => ops
    .map((List<Object?> o) => o.map(_norm).toList())
    .toList();

void main() {
  final Map<String, dynamic> truth = _truth();

  test('margin truth replay', () {
    final Map<String, Object?> actual = <String, Object?>{};
    final List<List<Object?>> ops = <List<Object?>>[];
    int nodeId = 0;
    MarginEnvironment env = MarginEnvironment(() => _Node(nodeId++, ops));

    void labelOps(String label) {
      actual[label] = <String, Object?>{'ops': _normOps(ops)};
      ops.clear();
    }

    // Case 1: construct + render.
    {
      nodeId = 0;
      final m = Margin(
        _ctx(contentLeft: 120, glyphMarginLeft: 10, glyphMarginWidth: 20,
            disableLayerHinting: false),
        env,
      );
      labelOps('construct');
      m.render(<String, Object>{'scrollTop': 100, 'bigNumbersDelta': 30, 'scrollHeight': 5000});
      labelOps('render');
    }

    // Case 2: layer hinting disabled then config change + clamp.
    {
      nodeId = 0;
      final Map<Object, Object> values = <Object, Object>{
        EditorOption.layoutInfo: <String, Object>{
          'contentLeft': 50,
          'glyphMarginLeft': 5,
          'glyphMarginWidth': 15,
        },
        EditorOption.disableLayerHinting: true,
      };
      final m = Margin(_Context(_Options(values)), env);
      labelOps('construct2');
      values[EditorOption.layoutInfo] = <String, Object>{
        'contentLeft': 80,
        'glyphMarginLeft': 7,
        'glyphMarginWidth': 25,
      };
      values[EditorOption.disableLayerHinting] = false;
      final bool changed = m.onConfigurationChanged(<String, Object>{});
      m.render(<String, Object>{'scrollTop': 0, 'bigNumbersDelta': 0, 'scrollHeight': 2000000});
      labelOps('render-config-clamp');
      actual['config-result'] = <String, Object?>{'changed': changed};
    }

    // Case 3: scroll changed delegation.
    {
      final m = Margin(
        _ctx(contentLeft: 50, glyphMarginLeft: 5, glyphMarginWidth: 15,
            disableLayerHinting: false),
        env,
      );
      final bool r1 = m.onScrollChanged(<String, Object>{'scrollTopChanged': true});
      final bool r2 = m.onScrollChanged(<String, Object>{'scrollTopChanged': false});
      actual['scroll'] = <String, Object?>{'r1': r1, 'r2': r2};
    }

    expect(jsonEncode(actual), jsonEncode(truth));
  });
}
