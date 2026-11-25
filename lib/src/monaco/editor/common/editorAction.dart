// 1:1 port of vscode/src/vs/editor/common/editorAction.ts
//
// `IEditorAction` is an erased TS interface (port convention), so
// `InternalEditorAction` is a plain class exposing the same members.
import '../../platform/commands/common/commands.dart' show ICommandMetadata;
import '../../platform/contextkey/common/contextkey.dart'
    show ContextKeyExpression, IContextKeyServiceType;

/// 1:1: `export class InternalEditorAction implements IEditorAction`.
class InternalEditorAction {
  InternalEditorAction(
    this.id,
    this.label,
    this.alias,
    this.metadata,
    this._precondition,
    this._run,
    this._contextKeyService,
  );

  final String id;
  final String label;
  final String alias;
  final ICommandMetadata? metadata;
  final ContextKeyExpression? _precondition;
  final Future<void> Function(Object? args) _run;
  final IContextKeyServiceType _contextKeyService;

  bool isSupported() {
    return _contextKeyService.contextMatchesRules(_precondition);
  }

  Future<void> run(Object? args) {
    if (!isSupported()) {
      return Future<void>.value();
    }

    return _run(args);
  }
}
