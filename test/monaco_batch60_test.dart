// batch60: environment.ts + workspaceTrust.ts + uriIdentity.ts +
// resolvedKeybindingItem.ts. All assertions are data-driven from
// batch60_truth.json (Node TS transpile+vm real evaluation).
import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:semi_design_flutter/src/monaco/base/common/keybindings.dart'
    show ResolvedChord, ResolvedKeybinding;
import 'package:semi_design_flutter/src/monaco/platform/contextkey/common/contextkey.dart'
    show ContextKeyExpr, ContextKeyExpression;
import 'package:semi_design_flutter/src/monaco/platform/environment/common/environment.dart';
import 'package:semi_design_flutter/src/monaco/platform/instantiation/common/instantiation.dart'
    show createDecorator;
import 'package:semi_design_flutter/src/monaco/platform/keybinding/common/resolvedKeybindingItem.dart';
import 'package:semi_design_flutter/src/monaco/platform/uriIdentity/common/uriIdentity.dart';
import 'package:semi_design_flutter/src/monaco/platform/workspace/common/workspaceTrust.dart';

Map<String, dynamic> _truth() => jsonDecode(
      File('tool/ts2dart/batch60_truth.json').readAsStringSync(),
    ) as Map<String, dynamic>;

Object? _dec(Object? v) =>
    (v == '__undefined__' || v == '__null__') ? null : v;

class _FakeResolvedKeybinding implements ResolvedKeybinding {
  final List<String?> dispatch;
  final List<String?> single;
  _FakeResolvedKeybinding(this.dispatch, this.single);

  @override String? getLabel() => null;
  @override String? getAriaLabel() => null;
  @override String? getElectronAccelerator() => null;
  @override String? getUserSettingsLabel() => null;
  @override bool isWYSIWYG() => false;
  @override bool hasMultipleChords() => dispatch.length > 1;
  @override List<ResolvedChord> getChords() => <ResolvedChord>[];
  @override List<String?> getDispatchChords() => dispatch;
  @override List<String?> getSingleModifierDispatchChords() => single;
}

void main() {
  final truth = _truth();

  test('b60 environment: decorator id, memoize and refine identity', () {
    final e = truth['environment'] as Map<String, dynamic>;
    expect(IEnvironmentService.toString(), e['IEnvironmentService_id']);
    expect(INativeEnvironmentService.toString(), e['INativeEnvironmentService_id']);
    expect(e['refine_identity'] as bool, isTrue);
    expect(identical(INativeEnvironmentService, IEnvironmentService), isTrue);
    expect(e['createDecorator_memoize'] as bool, isTrue);
    expect(identical(createDecorator('environmentService'), IEnvironmentService), isTrue);
  });

  test('b60 workspaceTrust: three decorator ids and both enums match truth', () {
    final w = truth['workspaceTrust'] as Map<String, dynamic>;
    final d = w['decorators'] as Map<String, dynamic>;
    expect(IWorkspaceTrustEnablementService.toString(),
        d['IWorkspaceTrustEnablementService']);
    expect(IWorkspaceTrustManagementService.toString(),
        d['IWorkspaceTrustManagementService']);
    expect(IWorkspaceTrustRequestService.toString(),
        d['IWorkspaceTrustRequestService']);
    final scope = w['WorkspaceTrustScope'] as Map<String, dynamic>;
    expect(WorkspaceTrustScope.Local, scope['Local']);
    expect(WorkspaceTrustScope.Remote, scope['Remote']);
    final resp = w['WorkspaceTrustUriResponse'] as Map<String, dynamic>;
    expect(WorkspaceTrustUriResponse.Open, resp['Open']);
    expect(WorkspaceTrustUriResponse.OpenInNewWindow, resp['OpenInNewWindow']);
    expect(WorkspaceTrustUriResponse.Cancel, resp['Cancel']);
  });

  test('b60 uriIdentity: decorator id matches truth', () {
    final u = truth['uriIdentity'] as Map<String, dynamic>;
    expect(IUriIdentityService.toString(), u['IUriIdentityService_id']);
  });

  test('b60 toEmptyArrayIfContainsNull: JS truthiness preserved', () {
    final r = (truth['resolvedKeybindingItem'] as Map<String, dynamic>);
    final cases = r['toEmptyArrayIfContainsNull'] as List<dynamic>;
    for (final c in cases) {
      final input = (c['input'] as List<dynamic>).map(_dec).toList();
      // Truth includes [0, 1] (JS `!0` is true), so the generic must be
      // `dynamic` here just as TS instantiates `<number>`.
      final result = toEmptyArrayIfContainsNull<dynamic>(input);
      expect(result, c['result'], reason: 'input=$input');
    }
  });

  test('b60 ResolvedKeybindingItem: constructor fields match TS truth', () {
    final r = (truth['resolvedKeybindingItem'] as Map<String, dynamic>);
    final items = r['items'] as List<dynamic>;
    final argObj = Object();
    final whenExpr = ContextKeyExpr.has('editorTextFocus');
    for (final c in items) {
      final m = c as Map<String, dynamic>;
      final name = m['name'] as String;
      // Rebuild the exact argument tuple from the truth scenario table.
      ResolvedKeybinding? rk;
      String? command;
      Object? args;
      ContextKeyExpression? when;
      bool isDefault = false;
      String? extensionId;
      bool isBuiltin = false;
      bool systemWide = false;
      switch (name) {
        case 'undefined kb, plain command':
          command = 'foo'; args = argObj; when = whenExpr;
          break;
        case 'dispatch chords':
          rk = _FakeResolvedKeybinding(<String?>['ctrl+a', 'ctrl+b'], <String?>['ctrl+shift']);
          command = 'foo'; args = argObj; when = whenExpr;
          isDefault = true; extensionId = 'ext.id';
          break;
        case 'empty dispatch falls back to single modifier':
          rk = _FakeResolvedKeybinding(<String?>[], <String?>['ctrl+shift']);
          command = 'foo'; isBuiltin = true;
          break;
        case 'dispatch with null falls back':
          rk = _FakeResolvedKeybinding(<String?>['a', null], <String?>['ctrl+alt']);
          command = 'foo'; systemWide = true;
          break;
        case 'bubble caret':
          rk = _FakeResolvedKeybinding(<String?>['ctrl+c'], <String?>[]);
          command = '^foo'; args = argObj; when = whenExpr;
          extensionId = 'ext'; isBuiltin = true;
          break;
        case 'caret only':
          rk = _FakeResolvedKeybinding(<String?>['ctrl+c'], <String?>[]);
          command = '^'; isDefault = true;
          break;
        case 'null command':
          rk = _FakeResolvedKeybinding(<String?>['ctrl+x'], <String?>[]);
          break;
        case 'empty command':
          rk = _FakeResolvedKeybinding(<String?>['ctrl+y'], <String?>[]);
          command = '';
          break;
        case 'systemWide explicit':
          rk = _FakeResolvedKeybinding(<String?>['ctrl+z'], <String?>[]);
          command = 'z'; when = whenExpr; systemWide = true;
          break;
        default:
          fail('unknown truth scenario: $name');
      }
      final it = ResolvedKeybindingItem(
          rk, command, args, when, isDefault, extensionId, isBuiltin, systemWide);
      expect(it.chords, m['chords'], reason: '$name chords');
      expect(it.bubble, m['bubble'], reason: '$name bubble');
      expect(it.command, _dec(m['command']), reason: '$name command');
      expect(m['commandArgs'] == 'ARGS_IDENTITY'
          ? identical(it.commandArgs, argObj)
          : it.commandArgs == null, isTrue, reason: '$name args');
      expect(m['when'] == 'WHEN_IDENTITY'
          ? identical(it.when, whenExpr)
          : it.when == null, isTrue, reason: '$name when');
      expect(it.isDefault, m['isDefault'], reason: '$name isDefault');
      expect(it.extensionId, _dec(m['extensionId']), reason: '$name extensionId');
      expect(it.isBuiltinExtension, m['isBuiltinExtension'], reason: '$name builtin');
      expect(it.systemWide, m['systemWide'], reason: '$name systemWide');
      expect(identical(it.resolvedKeybinding, rk),
          m['resolvedKeybindingIdentity'] as bool, reason: '$name identity');
    }
  });
}
