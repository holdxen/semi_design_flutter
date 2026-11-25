// batch269: codeAction/common/types.ts truth replay.
// Truth from tool/ts2dart/batch269_truth.json (recursive TS transpile+vm,
// AST for const enum, real functions/classes for all runtime behaviour).
import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:semi_design_flutter/src/monaco/base/common/cancellation.dart'
    show CancellationToken;
import 'package:semi_design_flutter/src/monaco/base/common/errors.dart'
    show setUnexpectedErrorHandler;
import 'package:semi_design_flutter/src/monaco/base/common/hierarchicalKind.dart'
    show HierarchicalKind;
import 'package:semi_design_flutter/src/monaco/editor/contrib/codeAction/common/types.dart'
    show
        CodeActionAutoApply,
        CodeActionCommandArgs,
        CodeActionFilter,
        CodeActionItem,
        CodeActionKind,
        CodeActionTriggerSource,
        ICodeAction,
        ICodeActionProvider,
        filtersAction,
        mayIncludeActionsOfKind;

Map<String, dynamic> _truth() => jsonDecode(
    File('tool/ts2dart/batch269_truth.json').readAsStringSync())
    as Map<String, dynamic>;

class _Action implements ICodeAction {
  @override
  String? kind;
  @override
  bool? isPreferred;
  @override
  Object? edit;

  _Action({this.kind, this.isPreferred});
}

class _Provider implements ICodeActionProvider {
  final String mode;

  _Provider(this.mode);

  @override
  Future<ICodeAction?> resolveCodeAction(
      ICodeAction action, CancellationToken token) async {
    if (mode == 'throw') {
      throw StateError('resolve failed');
    }
    action.edit = 'resolved-edit';
    return action;
  }
}

CodeActionFilter _filter(Map<String, dynamic> raw) => CodeActionFilter(
      include: raw['include'] == null
          ? null
          : HierarchicalKind(raw['include'] as String),
      excludes: raw['excludes'] == null
          ? null
          : (raw['excludes'] as List<dynamic>)
              .map((v) => HierarchicalKind(v as String))
              .toList(),
      includeSourceActions: raw['includeSourceActions'] as bool?,
      onlyIncludePreferredActions:
          raw['onlyIncludePreferredActions'] as bool?,
    );

void main() {
  final t = _truth();
  final unexpected = <String>[];
  setUnexpectedErrorHandler((Object? e) =>
      unexpected.add(e is StateError ? e.message : e.toString()));
  tearDownAll(() => setUnexpectedErrorHandler((_) {}));

  test('b269 runtime export keys', () {
    expect(t['exportKeys'], <String>[
      'CodeActionAutoApply',
      'CodeActionCommandArgs',
      'CodeActionItem',
      'CodeActionKind',
      'CodeActionTriggerSource',
      'filtersAction',
      'mayIncludeActionsOfKind',
    ]);
  });

  test('b269 CodeActionKind values match truth', () {
    expect(t['kindValues'], <String, Object?>{
      'QuickFix': CodeActionKind.QuickFix.value,
      'Refactor': CodeActionKind.Refactor.value,
      'RefactorExtract': CodeActionKind.RefactorExtract.value,
      'RefactorInline': CodeActionKind.RefactorInline.value,
      'RefactorMove': CodeActionKind.RefactorMove.value,
      'RefactorRewrite': CodeActionKind.RefactorRewrite.value,
      'Notebook': CodeActionKind.Notebook.value,
      'Source': CodeActionKind.Source.value,
      'SourceOrganizeImports': CodeActionKind.SourceOrganizeImports.value,
      'SourceFixAll': CodeActionKind.SourceFixAll.value,
      'SurroundWith': CodeActionKind.SurroundWith.value,
    });
  });

  test('b269 const enum + trigger source values match truth', () {
    expect(t['autoApply'], <String, Object?>{
      'IfSingle': CodeActionAutoApply.IfSingle,
      'First': CodeActionAutoApply.First,
      'Never': CodeActionAutoApply.Never,
    });
    final src = t['triggerSource'] as Map<String, dynamic>;
    expect(CodeActionTriggerSource.Refactor, src['Refactor']);
    expect(CodeActionTriggerSource.RefactorPreview, src['RefactorPreview']);
    expect(CodeActionTriggerSource.Lightbulb, src['Lightbulb']);
    expect(CodeActionTriggerSource.Default, src['Default']);
    expect(CodeActionTriggerSource.SourceAction, src['SourceAction']);
    expect(CodeActionTriggerSource.QuickFix, src['QuickFix']);
    expect(CodeActionTriggerSource.FixAll, src['FixAll']);
    expect(CodeActionTriggerSource.OrganizeImports, src['OrganizeImports']);
    expect(CodeActionTriggerSource.AutoFix, src['AutoFix']);
    expect(CodeActionTriggerSource.QuickFixHover, src['QuickFixHover']);
    expect(CodeActionTriggerSource.OnSave, src['OnSave']);
    expect(CodeActionTriggerSource.ProblemsView, src['ProblemsView']);
  });

  test('b269 mayIncludeActionsOfKind truth cases', () {
    for (final raw in t['mayInclude'] as List<dynamic>) {
      final c = raw as Map<String, dynamic>;
      expect(
        mayIncludeActionsOfKind(
          _filter(c['filter'] as Map<String, dynamic>),
          HierarchicalKind(c['kind'] as String),
        ),
        c['value'],
        reason: c['name'] as String,
      );
    }
  });

  test('b269 filtersAction truth cases', () {
    for (final raw in t['filtersAction'] as List<dynamic>) {
      final c = raw as Map<String, dynamic>;
      final a = c['action'] as Map<String, dynamic>;
      expect(
        filtersAction(
          _filter(c['filter'] as Map<String, dynamic>),
          _Action(kind: a['kind'] as String?, isPreferred: a['isPreferred'] as bool?),
        ),
        c['value'],
        reason: c['name'] as String,
      );
    }
  });

  test('b269 CodeActionCommandArgs.fromUser truth cases', () {
    for (final raw in t['commandArgs'] as List<dynamic>) {
      final c = raw as Map<String, dynamic>;
      final defaults = c['defaults'] as Map<String, dynamic>;
      final args = CodeActionCommandArgs.fromUser(
        c['arg'],
        kind: HierarchicalKind(defaults['kind'] as String),
        apply: defaults['apply'] as String,
      );
      expect(
        <String, Object?>{
          'kind': args.kind.value,
          'apply': args.apply,
          'preferred': args.preferred,
        },
        <String, Object?>{
          'kind': c['kind'],
          'apply': c['apply'],
          'preferred': c['preferred'],
        },
        reason: c['name'] as String,
      );
    }
  });

  test('b269 CodeActionItem.resolve truth cases', () async {
    for (final raw in t['resolve'] as List<dynamic>) {
      final c = raw as Map<String, dynamic>;
      unexpected.clear();
      final action = _Action(kind: 'quickfix');
      ICodeActionProvider? provider;
      if (c['name'] == 'resolves-edit') {
        provider = _Provider('resolve');
      } else if (c['name'] == 'throws-captured') {
        provider = _Provider('throw');
      }
      final item = CodeActionItem(action, provider);
      final returned = await item.resolve(CancellationToken.none);
      expect(returned, same(item), reason: c['name'] as String);
      expect(action.edit, c['edit'], reason: c['name'] as String);
      expect(unexpected, c['errors'] ?? <String>[],
          reason: c['name'] as String);
    }
  });
}
