// batch155 truth tests: editor/contrib/toggleTabFocusMode/browser/toggleTabFocusMode.dart.
import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:semi_design_flutter/src/monaco/base/browser/dom.dart' as dom;
import 'package:semi_design_flutter/src/monaco/base/browser/ui/aria/aria.dart' as aria;
import 'package:semi_design_flutter/src/monaco/base/common/keyCodes.dart'
    show KeyCode, KeyMod;
import 'package:semi_design_flutter/src/monaco/editor/browser/config/tabFocus.dart'
    show TabFocus;
import 'package:semi_design_flutter/src/monaco/editor/contrib/toggleTabFocusMode/browser/toggleTabFocusMode.dart'
    as ttf;
import 'package:semi_design_flutter/src/monaco/platform/instantiation/common/instantiation.dart'
    show ServicesAccessor, ServiceIdentifier;

Map<String, dynamic> _loadTruth() {
  final f = File('tool/ts2dart/batch155_truth.json');
  return jsonDecode(f.readAsStringSync()) as Map<String, dynamic>;
}

class _Accessor implements ServicesAccessor {
  @override
  Object? get(ServiceIdentifier id) => null;
}

Object? _localizedValue(Object? obj) {
  if (obj is Map) return obj['value'];
  final dynamic d = obj;
  try {
    return d.value;
  } catch (_) {
    return null;
  }
}

void main() {
  final t = _loadTruth();
  final desc = t['desc'] as Map<String, dynamic>;
  final action = ttf.ToggleTabFocusModeAction();

  setUp(() {
    aria.setARIAContainer(dom.DomElement('DIV'));
  });

  test('static ID matches truth', () {
    expect(ttf.ToggleTabFocusModeAction.ID, t['ID']);
    expect(t['ID'], 'editor.action.toggleTabFocusMode');
  });

  test('descriptor id/keybinding/metadata/f1 match truth', () {
    final dynamic d = action.desc;
    expect(d.id, desc['id']);
    final Map kb = d.keybinding as Map;
    expect(kb['primary'], desc['keybinding']['primary']);
    expect(kb['weight'], desc['keybinding']['weight']);
    final Map mac = kb['mac'] as Map;
    expect(mac['primary'], (desc['keybinding']['mac'] as Map)['primary']);
    expect(desc['keybinding']['primary'], KeyMod.CtrlCmd | KeyCode.KeyM);
    expect((desc['keybinding']['mac'] as Map)['primary'],
        KeyMod.WinCtrl | KeyMod.Shift | KeyCode.KeyM);
    expect(d.f1, desc['f1']);
    expect(_localizedValue(d.metadata.description),
        (desc['metadata']['description'] as Map)['value']);
    expect(_localizedValue(d.title), (desc['title'] as Map)['value']);
  });

  test('run() toggles TabFocus on then off (truth)', () {
    final accessor = _Accessor();
    // Ensure deterministic starting state.
    if (TabFocus.getTabFocusMode()) {
      TabFocus.setTabFocusMode(false);
    }
    final runTruth = t['run'] as List<dynamic>;

    action.run(accessor);
    expect(TabFocus.getTabFocusMode(), runTruth[0]['tabFocus']);
    expect(aria.alertContainer!.textContent,
        (runTruth[0]['alerts'] as List).last);

    action.run(accessor);
    expect(TabFocus.getTabFocusMode(), runTruth[1]['tabFocus']);
    expect(aria.alertContainer!.textContent,
        (runTruth[1]['alerts'] as List).last);
  });

  test('registerAction2 side effect exposed via ensureRegistered (truth)', () {
    expect(t['registeredCount'], 1);
    // Idempotent; should not throw on repeated calls.
    ttf.ensureRegistered();
    ttf.ensureRegistered();
  });
}
