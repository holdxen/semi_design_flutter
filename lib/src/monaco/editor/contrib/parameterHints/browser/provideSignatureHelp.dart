// ---------------------------------------------------------------------------
// Port of vscode/src/vs/editor/contrib/parameterHints/browser/provideSignatureHelp.ts
// Translated 1:1 from TypeScript. Structure, members and semantics preserved.
//
// Carriers:
//   - `SignatureHelpContext` / `SignatureHelpResult` / `SignatureHelpProvider`
//     are erased TS interfaces -> file-local opaque carriers.
//   - `LanguageFeatureRegistry<SignatureHelpProvider>` -> the repository-wide
//     `LanguageFeatureRegistry<Object?>` used by ILanguageFeaturesService.
//   - `Promise<R | undefined>` -> `Future<Object?>`.
// ---------------------------------------------------------------------------

import '../../../../base/common/cancellation.dart' show CancellationToken;
import '../../../../base/common/errors.dart' show onUnexpectedExternalError;
import '../../../../base/common/types.dart' show assertType;
import '../../../../base/common/uri.dart' show URI;
import '../../../common/core/position.dart' show IPosition, Position;
import '../../../common/languageFeatureRegistry.dart'
    show ILanguageFeatureModel, LanguageFeatureRegistry;
import '../../../common/languages.dart' show SignatureHelpTriggerKind;
import '../../../common/services/languageFeatures.dart'
    show ILanguageFeaturesService, ILanguageFeaturesServiceType;
import '../../../common/services/resolverService.dart'
    show ITextModelService, ITextModelServiceType;
import '../../../../platform/commands/common/commands.dart'
    show CommandsRegistry;
import '../../../../platform/contextkey/common/contextkey.dart'
    show RawContextKey;
import '../../../../platform/instantiation/common/instantiation.dart'
    show ServicesAccessor;

/// 1:1: `export const Context = { Visible: ..., MultipleSignatures: ... }`.
class Context {
  static final RawContextKey<bool> Visible =
      RawContextKey<bool>('parameterHintsVisible', false);
  static final RawContextKey<bool> MultipleSignatures =
      RawContextKey<bool>('parameterHintsMultipleSignatures', false);
}

/// 1:1: `languages.SignatureHelpContext` (opaque carrier).
class SignatureHelpContextData {
  SignatureHelpContextData({
    required this.triggerKind,
    required this.isRetrigger,
    this.triggerCharacter,
  });

  final int triggerKind;
  final bool isRetrigger;
  final String? triggerCharacter;
}

/// 1:1: `languages.SignatureHelpResult` (opaque carrier).
abstract class SignatureHelpResultData {
  Object? get value;
  void dispose();
}

/// 1:1: `languages.SignatureHelpProvider.provideSignatureHelp` contract.
abstract class ISignatureHelpProvider {
  Future<Object?> provideSignatureHelp(
    Object model,
    Position position,
    CancellationToken token,
    Object context,
  );
}

/// 1:1: `provideSignatureHelp(registry, model, position, context, token)`.
Future<Object?> provideSignatureHelp(
  LanguageFeatureRegistry<Object?> registry,
  ILanguageFeatureModel model,
  Position position,
  Object context,
  CancellationToken token,
) async {
  final List<Object?> supports = registry.ordered(model);

  for (final Object? support in supports) {
    try {
      final ISignatureHelpProvider provider = support as ISignatureHelpProvider;
      final Object? result = await provider.provideSignatureHelp(
          model as Object, position, token, context);
      if (result != null) {
        return result;
      }
    } catch (err) {
      onUnexpectedExternalError(err);
    }
  }
  return null;
}

/// 1:1: `CommandsRegistry.registerCommand('_executeSignatureHelpProvider', ...)`.
void _registerExecuteSignatureHelpProviderCommand() {
  CommandsRegistry.registerCommand(
      '_executeSignatureHelpProvider',
      (ServicesAccessor accessor, List<Object?> args) async {
    final Object? uri = args.isNotEmpty ? args[0] : null;
    final Object? position = args.length > 1 ? args[1] : null;
    final Object? triggerCharacter = args.length > 2 ? args[2] : null;
    assertType(URI.isUri(uri));
    assertType(Position.isIPosition(position));
    assertType(triggerCharacter is String || triggerCharacter == null);

    final ILanguageFeaturesServiceType languageFeaturesService =
        accessor.get(ILanguageFeaturesService) as ILanguageFeaturesServiceType;

    final dynamic ref = await (accessor.get(ITextModelService)
            as ITextModelServiceType)
        .createModelReference(uri as URI);
    try {
      final Object? result = await provideSignatureHelp(
        languageFeaturesService.signatureHelpProvider,
        ref.object.textEditorModel as ILanguageFeatureModel,
        Position.lift(position as IPosition),
        SignatureHelpContextData(
          triggerKind: SignatureHelpTriggerKind.Invoke,
          isRetrigger: false,
          triggerCharacter: triggerCharacter as String?,
        ),
        CancellationToken.none,
      );

      if (result == null) {
        return null;
      }

      Future<void>.delayed(Duration.zero, () {
        (result as SignatureHelpResultData).dispose();
      });
      return (result as SignatureHelpResultData).value;
    } finally {
      (ref as dynamic).dispose();
    }
  });
}

/// Module-level side-effect, mirroring the TS top-level `registerCommand` call.
/// Dart top-level initializers are lazy, so this is triggered explicitly via
/// [ensureRegistered] (the TS import evaluates it eagerly).
final bool _commandRegistered = () {
  _registerExecuteSignatureHelpProviderCommand();
  return true;
}();

/// 1:1: forces evaluation of the module-level command registration.
bool ensureRegistered() => _commandRegistered;
