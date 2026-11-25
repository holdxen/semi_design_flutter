// ---------------------------------------------------------------------------
// Port of vscode/src/vs/editor/common/services/semanticTokensStylingService.ts
// Translated 1:1 from TypeScript. Structure, members and semantics preserved.
//
// Adaptations (documented inline):
//  * Dart has no `WeakMap`; an identity-keyed list pair reproduces the
//    observable cache semantics (same repo convention as configurationModels).
//  * Erased interfaces (`IThemeService`, `ILogService`, `ILanguageService`,
//    `DocumentTokensProvider`) are reduced to the members actually read.
//  * TS top-level `registerSingleton` side effect becomes a lazily
//    initialized `registration` final (Dart has no top-level statements).
// ---------------------------------------------------------------------------
import '../../../base/common/event.dart' show Event;
import '../../../base/common/lifecycle.dart' show Disposable;
import '../../../platform/instantiation/common/extensions.dart'
    show InstantiationType, registerSingleton;
import '../../../platform/theme/common/themeService.dart' show IColorTheme;
import '../../contrib/semanticTokens/common/getSemanticTokens.dart'
    show SemanticTokensLegend;
import './model.dart' show DocumentTokensProvider;
import './semanticTokensProviderStyling.dart'
    show
        ILogServiceForSemanticStyling,
        IThemeServiceForSemanticStyling,
        ILanguageServiceForSemanticStyling,
        SemanticTokensProviderStyling;
import './semanticTokensStyling.dart'
    show ISemanticTokensStylingService, ISemanticTokensStylingServiceType;

/// 1:1: `IThemeService` members read here.
abstract class IThemeServiceForSemanticStylingService
    implements IThemeServiceForSemanticStyling {
  @override
  IColorTheme getColorTheme();

  Event<IColorTheme> get onDidColorThemeChange;
}

/// 1:1: `DocumentTokensProvider.getLegend()` member.
abstract class IDocumentTokensProviderForStyling {
  SemanticTokensLegend getLegend();
}

/// Identity-keyed carrier for `WeakMap<DocumentTokensProvider,
/// SemanticTokensProviderStyling>`.
class _StylingCache {
  final List<DocumentTokensProvider> _keys = <DocumentTokensProvider>[];
  final List<SemanticTokensProviderStyling> _values =
      <SemanticTokensProviderStyling>[];

  bool has(DocumentTokensProvider key) => _keys.any((k) => identical(k, key));

  SemanticTokensProviderStyling? get(DocumentTokensProvider key) {
    final int i = _keys.indexWhere((k) => identical(k, key));
    return i >= 0 ? _values[i] : null;
  }

  void set(DocumentTokensProvider key, SemanticTokensProviderStyling value) {
    final int i = _keys.indexWhere((k) => identical(k, key));
    if (i >= 0) {
      _values[i] = value;
    } else {
      _keys.add(key);
      _values.add(value);
    }
  }
}

/// 1:1: `export class SemanticTokensStylingService extends Disposable
/// implements ISemanticTokensStylingService`.
class SemanticTokensStylingService extends Disposable
    implements ISemanticTokensStylingServiceType {
  // TS: `_serviceBrand: undefined` is a structural brand only.

  _StylingCache _caches;

  final IThemeServiceForSemanticStylingService _themeService;
  final ILogServiceForSemanticStyling _logService;
  final ILanguageServiceForSemanticStyling _languageService;

  SemanticTokensStylingService(
    this._themeService,
    this._logService,
    this._languageService,
  )   : _caches = _StylingCache(),
        super() {
    register(_themeService.onDidColorThemeChange((_) {
      _caches = _StylingCache();
    }));
  }

  @override
  SemanticTokensProviderStyling getStyling(DocumentTokensProvider provider) {
    if (!_caches.has(provider)) {
      final IDocumentTokensProviderForStyling typedProvider =
          provider as IDocumentTokensProviderForStyling;
      _caches.set(
        provider,
        SemanticTokensProviderStyling(
          typedProvider.getLegend(),
          _themeService,
          _languageService,
          _logService,
        ),
      );
    }
    return _caches.get(provider)!;
  }
}

/// 1:1 top-level side effect: `registerSingleton(...)`.
final Object registration = () {
  registerSingleton(
    ISemanticTokensStylingService,
    SemanticTokensStylingService.new,
    InstantiationType.Delayed,
  );
  return ISemanticTokensStylingService;
}();
