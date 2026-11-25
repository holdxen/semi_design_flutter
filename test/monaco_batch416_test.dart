// 1:1 replay of `editor/browser/viewParts/rulers/rulers.ts`.
// Truth: `tool/ts2dart/_batch416_truth.cjs` -> `batch416_truth.json`.
import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import '../lib/src/monaco/editor/browser/viewParts/rulers/rulers.dart';
import '../lib/src/monaco/editor/common/config/editorOptions.dart'
    show EditorOption;
import '../lib/src/monaco/editor/common/viewEventHandler.dart'
    show ViewEventHandler;

Map<String, dynamic> _map(dynamic v) => (v as Map).cast<String, dynamic>();

Map<String, dynamic> _truth() {
  final Map<String, dynamic> root = _map(
    jsonDecode(File('tool/ts2dart/batch416_truth.json').readAsStringSync()),
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

int _nodeId = 0;

class _Node implements IRulerNode {
  final int id;
  final List<Object?> ops = <Object?>[];
  _Node() : id = _nodeId++;

  @override
  void setAttribute(String name, String value) =>
      ops.add(<Object?>['attr', name, value]);
  @override
  void setClassName(String className) =>
      ops.add(<Object?>['class', className]);
  @override
  void setWidth(Object width) => ops.add(<Object?>['width', width]);
  @override
  void setBoxShadow(String boxShadow) =>
      ops.add(<Object?>['shadow', boxShadow]);
  @override
  void setHeight(Object height) => ops.add(<Object?>['height', height]);
  @override
  void setLeft(Object left) => ops.add(<Object?>['left', left]);
  @override
  void appendChild(IRulerNode child) =>
      ops.add(<Object?>['append', (child as _Node).id]);
  @override
  void removeChild(IRulerNode child) =>
      ops.add(<Object?>['remove', (child as _Node).id]);

  List<Object?> opsJson() => ops
      .map((Object? op) =>
          (op as List<Object?>).map((Object? o) => o is num ? o.toInt() : o).toList())
      .toList();
}

class _Ruler implements IRulerOptionView {
  @override
  final num column;
  @override
  final Object? color;
  _Ruler(this.column, this.color);
}

class _Options implements IRulersEditorOptions {
  List<IRulerOptionView> rulers;
  num halfWidth;
  _Options(this.rulers, this.halfWidth);

  @override
  Object? get(Object id) {
    if (id == EditorOption.rulers) return rulers;
    if (id == EditorOption.fontInfo) return _FontInfo(halfWidth);
    return null;
  }
}

class _FontInfo {
  final num typicalHalfwidthCharacterWidth;
  _FontInfo(this.typicalHalfwidthCharacterWidth);
}

class _Config implements IRulersConfiguration {
  @override
  _Options options;
  _Config(this.options);
}

class _Context implements IRulersViewContext {
  @override
  _Config configuration;
  final List<ViewEventHandler> handlers = <ViewEventHandler>[];

  _Context(this.configuration);

  @override
  void addEventHandler(ViewEventHandler h) => handlers.add(h);
  @override
  void removeEventHandler(ViewEventHandler h) => handlers.remove(h);
}

RulersEnvironment _env() => RulersEnvironment(
      // Harness creates a bare element then wraps it in a fast node; both
      // consume ids, and only the wrapper records operations.
      createElement: () {
        _Node(); // bare element (id consumed, no ops recorded)
        return _Node();
      },
      createFastDomNode: (IRulerNode node) => node,
    );

_Context _makeContext(List<IRulerOptionView> rulers, [num halfWidth = 10]) =>
    _Context(_Config(_Options(rulers, halfWidth)));

List<Object?> _opsJson(IRulerNode node) => (node as _Node).opsJson();

void main() {
  final Map<String, dynamic> truth = _truth();

  test('rulers replay TS truth', () {
    final Map<String, Object?> actual = <String, Object?>{};

    // basic
    {
      _nodeId = 0;
      final Rulers r = Rulers(
        _makeContext(<IRulerOptionView>[
          _Ruler(50, '#ff0000'),
          _Ruler(80, null),
        ], 8),
        _env(),
      );
      r.render(<String, Object?>{'scrollHeight': 500});
      actual['basic'] = <String, Object?>{
        'domOps': _opsJson(r.domNode),
        'rulerOps': r.renderedRulers.map(_opsJson).toList(),
      };
      r.dispose();
    }

    // config-change
    {
      _nodeId = 0;
      final _Context ctx = _makeContext(<IRulerOptionView>[
        _Ruler(30, 'a'),
      ]);
      final Rulers r = Rulers(ctx, _env());
      r.render(<String, Object?>{'scrollHeight': 100});
      final int afterFirst = r.renderedRulers.length;
      ctx.configuration.options
        ..rulers = <IRulerOptionView>[
          _Ruler(10, 'x'),
          _Ruler(20, 'y'),
          _Ruler(60, null),
        ]
        ..halfWidth = 12;
      r.onConfigurationChanged(<Object, Object?>{});
      r.render(<String, Object?>{'scrollHeight': 200});
      actual['config-change'] = <String, Object?>{
        'afterFirst': afterFirst,
        'afterSecond': r.renderedRulers.length,
        'domOps': _opsJson(r.domNode),
        'rulerOps': r.renderedRulers.map(_opsJson).toList(),
      };
      r.dispose();
    }

    // clamp
    {
      _nodeId = 0;
      final Rulers r = Rulers(
        _makeContext(<IRulerOptionView>[_Ruler(1, null)]),
        _env(),
      );
      r.render(<String, Object?>{'scrollHeight': 2000000});
      actual['clamp'] = <String, Object?>{
        'rulerOps': r.renderedRulers.map(_opsJson).toList(),
      };
      r.dispose();
    }

    // events
    {
      _nodeId = 0;
      final Rulers r = Rulers(_makeContext(<IRulerOptionView>[]), _env());
      actual['events'] = <String, Object?>{
        'events': <String, Object?>{
          'config': r.onConfigurationChanged(<Object, Object?>{}),
          'scrollHeight': r.onScrollChanged(<Object, Object?>{
            'scrollHeightChanged': true,
          }),
          'scrollOther': r.onScrollChanged(<Object, Object?>{
            'scrollHeightChanged': false,
          }),
        },
      };
      r.dispose();
    }

    for (final String key in truth.keys) {
      expect(
        jsonEncode(actual[key]),
        jsonEncode(truth[key]),
        reason: 'mismatch at $key',
      );
    }
  });
}
