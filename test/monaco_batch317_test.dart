// batch317: codeActionKeybindingResolver.ts truth replay.
import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:semi_design_flutter/src/monaco/editor/contrib/codeAction/browser/codeActionKeybindingResolver.dart'
    show
      CodeActionForResolver,
      CodeActionKeybindingResolver,
      fixAllCommandId,
      organizeImportsCommandId,
      IKeybindingServiceForCodeActions,
      KeybindingItemForCodeAction,
      ResolvedKeybindingForCodeAction;

Map<String, dynamic> _truth() => jsonDecode(
    File('tool/ts2dart/batch317_truth.json').readAsStringSync())
    as Map<String, dynamic>;

KeybindingItemForCodeAction _kb(Object? args,
        [String command = 'editor.action.codeAction', String? binding]) =>
    KeybindingItemForCodeAction(
      command,
      args,
      binding == null ? null : ResolvedKeybindingForCodeAction(binding),
    );

class _Service implements IKeybindingServiceForCodeActions {
  int accesses = 0;

  @override
  List<KeybindingItemForCodeAction> getKeybindings() {
    accesses++;
    return <KeybindingItemForCodeAction>[
      _kb(<String, Object?>{'kind': 'quickfix', 'preferred': false}, 'editor.action.codeAction', 'quickfix'),
      _kb(<String, Object?>{'kind': 'quickfix', 'preferred': true}, 'editor.action.codeAction', 'quickfix-preferred'),
      _kb(<String, Object?>{'kind': 'refactor.extract', 'preferred': false}, 'editor.action.codeAction', 'refactor-extract'),
      _kb(<String, Object?>{'kind': 'source.organizeImports'}, organizeImportsCommandId, 'organize-imports'),
      _kb(<String, Object?>{'kind': 'source.fixAll'}, fixAllCommandId, 'fix-all'),
      _kb(<String, Object?>{}, 'unknown.command', 'unknown'),
      _kb(<String, Object?>{'kind': 'source'}),
    ];
  }
}

void main() {
  final Map<String, dynamic> truth = _truth();
  final _Service service = _Service();
  final ResolvedKeybindingForCodeAction? Function(CodeActionForResolver) resolver =
      CodeActionKeybindingResolver(service).getResolver();

  test('lazy access and resolver results match truth', () {
    expect(service.accesses, 0);
    for (final dynamic raw in truth['results'] as List<dynamic>) {
      final Map<String, dynamic> c = raw as Map<String, dynamic>;
      final int before = service.accesses;
      final ResolvedKeybindingForCodeAction? binding = resolver(
        CodeActionForResolver(
          c['kind'] as String?,
          isPreferred: c['isPreferred'] as bool,
        ),
      );
      expect(
        <String, Object?>{
          'label': c['label'],
          'kind': c['kind'],
          'isPreferred': c['isPreferred'],
          'binding': binding?.id,
          'triggeredAccess': service.accesses > before,
        },
        c,
        reason: c['label'] as String,
      );
    }
    expect(service.accesses, truth['accesses']);
  });
}
