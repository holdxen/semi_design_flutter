// 1:1 port of
// vscode/src/vs/editor/contrib/quickAccess/browser/commandsQuickAccess.ts
//
// The editor-side base class for the command palette: it turns the active
// editor's supported actions into command picks.
//
// Adaptations (documented inline):
//  * `IEditor` / `IEditorAction` are erased TS interfaces, so the active
//    editor control is carried as `Object?` and read structurally.
//  * `editorAction.metadata.description` is `string | IMarkdownString`;
//    `isLocalizedString` decides whether it can be used verbatim.
import '../../../../base/common/iconLabels.dart' show stripIcons;
import '../../../../platform/action/common/action.dart'
    show ILocalizedString, isLocalizedString;
import '../../../../platform/commands/common/commands.dart'
    show ICommandMetadata, ICommandServiceType;
import '../../../../platform/dialogs/common/dialogs.dart'
    show IDialogServiceType;
import '../../../../platform/instantiation/common/instantiation.dart'
    show IInstantiationServiceType;
import '../../../../platform/keybinding/common/keybinding.dart'
    show IKeybindingServiceType;
import '../../../../platform/quickinput/browser/commandsQuickAccess.dart'
    show
        AbstractCommandsQuickAccessProvider,
        ICommandQuickPick,
        ICommandsQuickAccessOptions;
import '../../../../platform/telemetry/common/telemetry.dart'
    show ITelemetryServiceType;

/// 1:1: `export abstract class AbstractEditorCommandsQuickAccessProvider
/// extends AbstractCommandsQuickAccessProvider`.
abstract class AbstractEditorCommandsQuickAccessProvider
    extends AbstractCommandsQuickAccessProvider {
  AbstractEditorCommandsQuickAccessProvider(
    ICommandsQuickAccessOptions options,
    IInstantiationServiceType instantiationService,
    IKeybindingServiceType keybindingService,
    ICommandServiceType commandService,
    ITelemetryServiceType telemetryService,
    IDialogServiceType dialogService,
  ) : super(options, instantiationService, keybindingService, commandService,
            telemetryService, dialogService);

  /// Subclasses to provide the current active editor control.
  ///
  /// TS: `protected abstract activeTextEditorControl: IEditor | undefined`
  /// (`IEditor` is an erased interface, so the control is structural).
  Object? get activeTextEditorControl;

  List<ICommandQuickPick> getCodeEditorCommandPicks() {
    final Object? activeTextEditorControl = this.activeTextEditorControl;
    if (activeTextEditorControl == null) {
      return <ICommandQuickPick>[];
    }

    final List<ICommandQuickPick> editorCommandPicks = <ICommandQuickPick>[];
    for (final dynamic editorAction
        in ((activeTextEditorControl as dynamic).getSupportedActions()
            as List)) {
      ILocalizedString? commandDescription;
      final ICommandMetadata? metadata =
          editorAction.metadata as ICommandMetadata?;
      if (metadata?.description != null) {
        if (isLocalizedString(metadata!.description)) {
          commandDescription = metadata.description as ILocalizedString;
        } else {
          final String description = metadata.description.toString();
          commandDescription =
              ILocalizedString(original: description, value: description);
        }
      }
      final String label = stripIcons(editorAction.label as String);
      editorCommandPicks.add(ICommandQuickPick(
        commandId: editorAction.id as String,
        commandAlias: editorAction.alias as String?,
        commandDescription: commandDescription,
        label: label.isEmpty ? editorAction.id as String : label,
      ));
    }

    return editorCommandPicks;
  }
}
