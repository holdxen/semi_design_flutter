// ---------------------------------------------------------------------------
// 1:1 port of
// vscode/src/vs/editor/contrib/semanticTokens/common/semanticTokensConfig.ts
// (22 lines).
//
// Adaptations:
//   - `ITextModel` is erased (`Object?`); `getLanguageId()` / `uri` are read
//     dynamically for the configuration override descriptor.
//   - `IConfigurationService.getValue<T>(section, overrides)` is the port's
//     `getValue$3` overload; `IConfigurationOverrides` is abstract, so the
//     descriptor is a small private carrier.
//   - `setting?.enabled`: only object carriers have an `enabled` member; a
//     boolean/string/null value yields `undefined` exactly like JS.
// ---------------------------------------------------------------------------

import '../../../../base/common/uri.dart' show URI;
import '../../../../platform/configuration/common/configuration.dart'
    show IConfigurationOverrides, IConfigurationServiceType;
import '../../../../platform/theme/common/themeService.dart' show IThemeServiceType;
import '../../../common/model.dart' show ITextModel;

const String SEMANTIC_HIGHLIGHTING_SETTING_ID = 'editor.semanticHighlighting';

/// TS `IEditorSemanticHighlightingOptions` (erased interface; the only member
/// read here is `enabled`).
bool isSemanticColoringEnabled(Object? model, IThemeServiceType themeService,
    IConfigurationServiceType configurationService) {
  final dynamic textModel = model;
  final Object? value = configurationService.getValue$3(
    SEMANTIC_HIGHLIGHTING_SETTING_ID,
    _SemanticHighlightingOverrides(
      textModel.getLanguageId() as String,
      textModel.uri as URI,
    ),
  );
  final Object? setting = value is Map ? value['enabled'] : null;
  if (setting is bool) {
    return setting;
  }
  return themeService.getColorTheme().semanticHighlighting;
}

class _SemanticHighlightingOverrides implements IConfigurationOverrides {
  _SemanticHighlightingOverrides(this.overrideIdentifier, this.resource);

  @override
  final String? overrideIdentifier;

  @override
  final URI? resource;
}
