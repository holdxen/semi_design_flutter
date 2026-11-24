// Truth-driven tests for batch173:
// platform/history/browser/historyWidgetKeybindingHint.ts
// Truth source: tool/ts2dart/batch173_truth.json (executed TS transpile).
import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:semi_design_flutter/src/monaco/base/common/keybindings.dart' as kb;
import 'package:semi_design_flutter/src/monaco/platform/keybinding/common/keybinding.dart' as keybinding;
import 'package:semi_design_flutter/src/monaco/platform/contextkey/common/contextkey.dart' as contextkey;
import 'package:semi_design_flutter/src/monaco/platform/history/browser/historyWidgetKeybindingHint.dart' as hint;

final Map<String, dynamic> truth =
    jsonDecode(File('tool/ts2dart/batch173_truth.json').readAsStringSync())
        as Map<String, dynamic>;

class FakeResolved extends kb.ResolvedKeybinding {
  FakeResolved(this._accel);
  final String? _accel;
  @override
  String? getElectronAccelerator() => _accel;
  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}

class FakeService implements keybinding.IKeybindingServiceType {
  FakeService(this._prev, this._next);
  final String? _prev;
  final String? _next;
  final List<String> lookups = <String>[];

  @override
  kb.ResolvedKeybinding? lookupKeybinding(String commandId,
      [contextkey.IContextKeyServiceType? context, bool enforceContextCheck = false]) {
    lookups.add(commandId);
    if (commandId == 'history.showPrevious') {
      return _prev == null ? null : FakeResolved(_prev);
    }
    if (commandId == 'history.showNext') {
      return _next == null ? null : FakeResolved(_next);
    }
    return null;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}

void main() {
  group('historyWidgetKeybindingHint.ts', () {
    test('exports', () {
      expect(truth['exports'], <dynamic>['showHistoryKeybindingHint']);
    });

    for (final Map<String, dynamic> c in truth['cases'] as List<dynamic>) {
      final String? prev = c['prev'] as String?;
      final String? next = c['next'] as String?;
      test('prev=$prev next=$next -> ${c['expected']}', () {
        final FakeService svc = FakeService(prev, next);
        expect(hint.showHistoryKeybindingHint(svc), c['expected']);
        expect(svc.lookups, c['lookups']);
      });
    }
  });
}
