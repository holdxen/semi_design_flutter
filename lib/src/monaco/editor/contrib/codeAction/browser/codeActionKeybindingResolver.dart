// ---------------------------------------------------------------------------
// Port of vscode/src/vs/editor/contrib/codeAction/browser/
// codeActionKeybindingResolver.ts
// Translated 1:1. Erased keybinding/code-action interfaces are local carriers;
// command ids are the exported constants from codeAction.ts (that file is not
// ported yet).
// ---------------------------------------------------------------------------
import '../../../../base/common/hierarchicalKind.dart' show HierarchicalKind;
import '../../../../base/common/lazy.dart' show Lazy;
import '../common/types.dart'
    show
      CodeActionAutoApply,
      CodeActionCommandArgs,
      CodeActionKind;

/// 1:1: command id constants.
const String codeActionCommandId = 'editor.action.codeAction';
const String refactorCommandId = 'editor.action.refactor';
const String sourceActionCommandId = 'editor.action.sourceAction';
const String organizeImportsCommandId = 'editor.action.organizeImports';
const String fixAllCommandId = 'editor.action.fixAll';

/// 1:1: `ResolvedKeybinding` carrier.
class ResolvedKeybindingForCodeAction {
  final Object id;

  ResolvedKeybindingForCodeAction(this.id);
}

/// 1:1: keybinding item surface read here.
class KeybindingItemForCodeAction {
  final String? command;
  final Object? commandArgs;
  final ResolvedKeybindingForCodeAction? resolvedKeybinding;

  KeybindingItemForCodeAction(this.command, this.commandArgs, this.resolvedKeybinding);
}

/// 1:1: `IKeybindingService.getKeybindings` member.
abstract class IKeybindingServiceForCodeActions {
  List<KeybindingItemForCodeAction> getKeybindings();
}

/// 1:1: `CodeAction` surface read here.
class CodeActionForResolver {
  final String? kind;
  final bool isPreferred;

  CodeActionForResolver(this.kind, {this.isPreferred = false});
}

class ResolveCodeActionKeybinding {
  final HierarchicalKind kind;
  final bool preferred;
  final ResolvedKeybindingForCodeAction resolvedKeybinding;

  ResolveCodeActionKeybinding(
      this.kind, this.preferred, this.resolvedKeybinding);
}

/// 1:1: `export class CodeActionKeybindingResolver`.
class CodeActionKeybindingResolver {
  static const List<String> codeActionCommands = <String>[
    refactorCommandId,
    codeActionCommandId,
    sourceActionCommandId,
    organizeImportsCommandId,
    fixAllCommandId,
  ];

  final IKeybindingServiceForCodeActions _keybindingService;

  CodeActionKeybindingResolver(this._keybindingService);

  /// 1:1: `getResolver()`.
  ResolvedKeybindingForCodeAction? Function(CodeActionForResolver) getResolver() {
    final Lazy<List<ResolveCodeActionKeybinding>> allCodeActionBindings =
        Lazy<List<ResolveCodeActionKeybinding>>(() {
      return _keybindingService
          .getKeybindings()
          .where((KeybindingItemForCodeAction item) =>
              item.command != null &&
              codeActionCommands.contains(item.command!))
          .where((KeybindingItemForCodeAction item) =>
              item.resolvedKeybinding != null)
          .map((KeybindingItemForCodeAction item) {
        Object? commandArgs = item.commandArgs;
        if (item.command == organizeImportsCommandId) {
          commandArgs = <String, Object?>{
            'kind': CodeActionKind.SourceOrganizeImports.value,
          };
        } else if (item.command == fixAllCommandId) {
          commandArgs = <String, Object?>{
            'kind': CodeActionKind.SourceFixAll.value,
          };
        }
        final CodeActionCommandArgs args = CodeActionCommandArgs.fromUser(
          commandArgs,
          kind: HierarchicalKind.None,
          apply: CodeActionAutoApply.Never,
        );
        return ResolveCodeActionKeybinding(
            args.kind, args.preferred, item.resolvedKeybinding!);
      }).toList();
    });

    return (CodeActionForResolver action) {
      if (action.kind != null && action.kind!.isNotEmpty) {
        final ResolveCodeActionKeybinding? binding =
            bestKeybindingForCodeAction(action, allCodeActionBindings.value);
        return binding?.resolvedKeybinding;
      }
      return null;
    };
  }

  ResolveCodeActionKeybinding? bestKeybindingForCodeAction(
      CodeActionForResolver action, List<ResolveCodeActionKeybinding> candidates) {
    final String? kindValue = action.kind;
    if (kindValue == null || kindValue.isEmpty) {
      return null;
    }
    final HierarchicalKind kind = HierarchicalKind(kindValue);

    final List<ResolveCodeActionKeybinding> filtered = candidates
        .where((candidate) => candidate.kind.contains(kind))
        .where((candidate) => candidate.preferred ? action.isPreferred : true)
        .toList();

    ResolveCodeActionKeybinding? currentBest;
    for (int i = filtered.length - 1; i >= 0; i--) {
      final ResolveCodeActionKeybinding candidate = filtered[i];
      if (currentBest == null) {
        currentBest = candidate;
      } else {
        currentBest =
            currentBest.kind.contains(candidate.kind) ? candidate : currentBest;
      }
    }
    return currentBest;
  }
}
