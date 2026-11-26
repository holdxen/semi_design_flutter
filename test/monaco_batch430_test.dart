import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import '../lib/src/monaco/base/browser/dom.dart' show Dimension;
import '../lib/src/monaco/editor/browser/services/codeEditorService.dart'
    show ICodeEditorServiceType;
import '../lib/src/monaco/editor/standalone/browser/standaloneLayoutService.dart'
    show ClientAreaProvider, EditorScopedLayoutService;

Map<String, dynamic> _truth() {
  final Map<String, dynamic> root =
      jsonDecode(File('tool/ts2dart/batch430_truth.json').readAsStringSync())
          as Map<String, dynamic>;
  final Map<String, dynamic> out = <String, dynamic>{};
  for (final dynamic r in root['results'] as List<dynamic>) {
    final Map<String, dynamic> m = (r as Map).cast<String, dynamic>();
    out[m['label'] as String] = <String, dynamic>{
      for (final MapEntry<String, dynamic> e in m.entries)
        if (e.key != 'label' && e.key != 'singletonCalls') e.key: e.value,
    };
  }
  return out;
}

class _El {
  final String id;
  final int w;
  final int h;
  _El(this.id, this.w, this.h);
  Object getContainerDomNode() => this;
  @override
  String toString() => id;
}

class _EditorService implements ICodeEditorServiceType {
  final List<Object> editors;
  final Object? focused;
  final Object? active;
  _EditorService(this.editors, this.focused, this.active);

  @override
  List<Object> listCodeEditors() => editors;
  @override
  Object? getFocusedCodeEditor() => focused;
  @override
  Object? getActiveCodeEditor() => active;

  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}

ClientAreaProvider get clientArea => (Object container) {
      final dynamic c = container;
      return Dimension((c.w as int?) ?? 0, (c.h as int?) ?? 0);
    };

void main() {
  final Map<String, dynamic> truth = _truth();

  test('standalone layout service truth replay', () {
    final Map<String, Object?> actual = <String, Object?>{};
    final _El body = _El('BODY', 0, 0);

    Map<String, Object?> snapshot(EditorScopedLayoutService svc) =>
        <String, Object?>{
          'mainContainer': svc.mainContainer.toString(),
          'activeContainer': svc.activeContainer.toString(),
          'mainDimension': <String, Object?>{
            'width': svc.mainContainerDimension.width,
            'height': svc.mainContainerDimension.height,
          },
          'activeDimension': <String, Object?>{
            'width': svc.activeContainerDimension.width,
            'height': svc.activeContainerDimension.height,
          },
          'mainOffset': <String, Object?>{
            'top': svc.mainContainerOffset.top,
            'quickPickTop': svc.mainContainerOffset.quickPickTop,
          },
          'activeOffset': <String, Object?>{
            'top': svc.activeContainerOffset.top,
            'quickPickTop': svc.activeContainerOffset.quickPickTop,
          },
          'containers': svc.containers.map((Object c) => c.toString()).toList(),
          'container': svc.getContainer().toString(),
        };

    // no editors
    {
      final svc = EditorScopedLayoutService(body,
          _EditorService(<Object>[], null, null),
          getClientArea: clientArea, mainWindowBody: body);
      actual['no-editors'] = snapshot(svc);
    }
    // with editors (focused E2, active E1)
    {
      final _El e1 = _El('E1', 100, 200);
      final _El e2 = _El('E2', 300, 400);
      final svc = EditorScopedLayoutService(body,
          _EditorService(<Object>[e1, e2], e2, e1),
          getClientArea: clientArea, mainWindowBody: body);
      actual['with-editors'] = snapshot(svc);
    }
    // focus fallback to active
    {
      final _El e1 = _El('E1', 10, 20);
      final svc = EditorScopedLayoutService(body,
          _EditorService(<Object>[e1], null, e1),
          getClientArea: clientArea, mainWindowBody: body);
      actual['focus-fallback-active'] = snapshot(svc);
    }
    // focus fallback to main
    {
      final _El e1 = _El('E1', 10, 20);
      final svc = EditorScopedLayoutService(body,
          _EditorService(<Object>[e1], null, null),
          getClientArea: clientArea, mainWindowBody: body);
      actual['focus-fallback-main'] = snapshot(svc);
    }
    // scoped container
    {
      final _El e1 = _El('E1', 50, 60);
      final _El scoped = _El('SCOPED', 700, 800);
      final svc = EditorScopedLayoutService(scoped,
          _EditorService(<Object>[e1], null, null),
          getClientArea: clientArea, mainWindowBody: body);
      actual['scoped'] = snapshot(svc);
    }
    // focus delegates to focused editor
    {
      int focusCalls = 0;
      final _El e1 = _El('E1', 1, 1);
      final _El f = _El('F', 1, 1);
      final _El focused = _El('FOCUS', 1, 1);
      // Use a dynamic editor object that exposes focus() and container.
      final Object focusedEditor = _FocusEditor(f, () => focusCalls++);
      final svc = EditorScopedLayoutService(body,
          _EditorService(<Object>[e1], focusedEditor, null),
          getClientArea: clientArea, mainWindowBody: body);
      svc.focus();
      actual['focus'] = <String, Object?>{'focusCalls': focusCalls};
    }

    expect(jsonEncode(actual), jsonEncode(truth));
  });
}

class _FocusEditor {
  final _El container;
  final void Function() onFocus;
  _FocusEditor(this.container, this.onFocus);
  Object getContainerDomNode() => container;
  void focus() => onFocus();
}
