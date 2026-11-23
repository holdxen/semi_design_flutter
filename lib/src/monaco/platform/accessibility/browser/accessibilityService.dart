// 1:1 port of vs/platform/accessibility/browser/accessibilityService.ts

import '../../../base/browser/dom.dart' as dom;
import '../../../base/browser/pixelRatio.dart' as pixelRatio;
import '../../../base/browser/ui/aria/aria.dart' as aria;
import '../../../base/browser/window.dart' show mainWindow;
import '../../../base/common/event.dart' show Emitter, Event;
import '../../../base/common/lifecycle.dart' show Disposable, IDisposable, toDisposable;
import '../common/accessibility.dart'
    show
        AccessibilitySupport,
        CONTEXT_ACCESSIBILITY_MODE_ENABLED,
        IAccessibilityServiceType;
import '../../configuration/common/configuration.dart'
    show IConfigurationChangeEvent, IConfigurationServiceType;
import '../../contextkey/common/contextkey.dart'
    show IContextKey, IContextKeyServiceType;
import '../../layout/browser/layoutService.dart'
    show AddContainerEvent, ILayoutServiceType;

/// 1:1: `export class AccessibilityService extends Disposable implements IAccessibilityService`
class AccessibilityService extends Disposable implements IAccessibilityServiceType {
  // ignore: unused_element
  Object? get _serviceBrand => null;

  late final IContextKeyServiceType _contextKeyService;
  late final ILayoutServiceType _layoutService;
  late final IConfigurationServiceType _configurationService;

  late final IContextKey<bool> _accessibilityModeEnabledContext;
  int _accessibilitySupport = AccessibilitySupport.Unknown;

  late final Emitter<void> _onDidChangeScreenReaderOptimized;
  Object? _configMotionReduced;
  bool _systemMotionReduced = false;
  late final Emitter<void> _onDidChangeReducedMotion;

  Object? _configTransparencyReduced;
  bool _systemTransparencyReduced = false;
  late final Emitter<void> _onDidChangeReducedTransparency;

  bool _linkUnderlinesEnabled = false;
  late final Emitter<void> _onDidChangeLinkUnderline;

  AccessibilityService(IContextKeyServiceType contextKeyService,
      ILayoutServiceType layoutService, IConfigurationServiceType configurationService) {
    _contextKeyService = contextKeyService;
    _layoutService = layoutService;
    _configurationService = configurationService;

    _onDidChangeScreenReaderOptimized = register(Emitter<void>());
    _onDidChangeReducedMotion = register(Emitter<void>());
    _onDidChangeReducedTransparency = register(Emitter<void>());
    _onDidChangeLinkUnderline = register(Emitter<void>());

    _accessibilityModeEnabledContext =
        CONTEXT_ACCESSIBILITY_MODE_ENABLED.bindTo(_contextKeyService);

    void updateContextKey() =>
        _accessibilityModeEnabledContext.set(isScreenReaderOptimized());
    register(_configurationService.onDidChangeConfiguration((dynamic e) {
      final IConfigurationChangeEvent event = e as IConfigurationChangeEvent;
      if (event.affectsConfiguration('editor.accessibilitySupport')) {
        updateContextKey();
        _onDidChangeScreenReaderOptimized.fire(null);
      }
      if (event.affectsConfiguration('workbench.reduceMotion')) {
        _configMotionReduced =
            _configurationService.getValue$1('workbench.reduceMotion');
        _onDidChangeReducedMotion.fire(null);
      }
      if (event.affectsConfiguration('workbench.reduceTransparency')) {
        _configTransparencyReduced =
            _configurationService.getValue$1('workbench.reduceTransparency');
        _onDidChangeReducedTransparency.fire(null);
      }
    }));
    updateContextKey();
    register(onDidChangeScreenReaderOptimized((dynamic _) => updateContextKey()));

    final pixelRatio.DomMediaQueryList reduceMotionMatcher =
        pixelRatio.matchMediaProvider(
            mainWindow, '(prefers-reduced-motion: reduce)');
    _systemMotionReduced = reduceMotionMatcher.matches;
    _configMotionReduced =
        _configurationService.getValue$1('workbench.reduceMotion');

    final pixelRatio.DomMediaQueryList reduceTransparencyMatcher =
        pixelRatio.matchMediaProvider(
            mainWindow, '(prefers-reduced-transparency: reduce)');
    _systemTransparencyReduced = reduceTransparencyMatcher.matches;
    _configTransparencyReduced =
        _configurationService.getValue$1('workbench.reduceTransparency');

    _linkUnderlinesEnabled = _configurationService
        .getValue$1('accessibility.underlineLinks') == true;

    _initReducedMotionListeners(reduceMotionMatcher);
    _initReducedTransparencyListeners(reduceTransparencyMatcher);
    _initLinkUnderlineListeners();
  }

  /// Carrier adaptation of `addDisposableListener(mediaQueryList, 'change', ...)`.
  IDisposable _addMediaQueryListener(
      pixelRatio.DomMediaQueryList matcher, void Function() handler) {
    matcher.addEventListener('change', handler);
    return toDisposable(() => matcher.removeEventListener('change', handler));
  }

  void _initReducedMotionListeners(pixelRatio.DomMediaQueryList reduceMotionMatcher) {
    register(_addMediaQueryListener(reduceMotionMatcher, () {
      _systemMotionReduced = reduceMotionMatcher.matches;
      if (_configMotionReduced == 'auto') {
        _onDidChangeReducedMotion.fire(null);
      }
    }));

    void updateContainerClasses(Object container) {
      final dom.DomElement element = container as dom.DomElement;
      final bool reduce = isMotionReduced();
      element.classList.toggle('monaco-reduce-motion', reduce);
      element.classList.toggle('monaco-enable-motion', !reduce);
    }

    void updateRootClasses() {
      for (final Object container in _layoutService.containers) {
        updateContainerClasses(container);
      }
    }

    updateRootClasses();
    register(onDidChangeReducedMotion((dynamic _) => updateRootClasses()));
    register(_layoutService.onDidAddContainer((dynamic e) =>
        updateContainerClasses((e as AddContainerEvent).container)));
  }

  void _initReducedTransparencyListeners(
      pixelRatio.DomMediaQueryList reduceTransparencyMatcher) {
    register(_addMediaQueryListener(reduceTransparencyMatcher, () {
      _systemTransparencyReduced = reduceTransparencyMatcher.matches;
      if (_configTransparencyReduced == 'auto') {
        _onDidChangeReducedTransparency.fire(null);
      }
    }));

    void updateRootClasses() {
      final dom.DomElement element = _layoutService.mainContainer as dom.DomElement;
      element.classList.toggle(
          'monaco-reduce-transparency', isTransparencyReduced());
    }

    updateRootClasses();
    register(
        onDidChangeReducedTransparency((dynamic _) => updateRootClasses()));
  }

  void _initLinkUnderlineListeners() {
    register(_configurationService.onDidChangeConfiguration((dynamic e) {
      final IConfigurationChangeEvent event = e as IConfigurationChangeEvent;
      if (event.affectsConfiguration('accessibility.underlineLinks')) {
        _linkUnderlinesEnabled = _configurationService
            .getValue$1('accessibility.underlineLinks') == true;
        _onDidChangeLinkUnderline.fire(null);
      }
    }));

    void updateLinkUnderlineClasses() {
      final dom.DomElement element = _layoutService.mainContainer as dom.DomElement;
      element.classList.toggle('underline-links', _linkUnderlinesEnabled);
    }

    updateLinkUnderlineClasses();
    register(onDidChangeLinkUnderlines((dynamic _) => updateLinkUnderlineClasses()));
  }

  /// 1:1: `public onDidChangeLinkUnderlines(listener)`
  IDisposable onDidChangeLinkUnderlines(dynamic listener) =>
      _onDidChangeLinkUnderline.event(listener);

  @override
  Event<void> get onDidChangeScreenReaderOptimized =>
      _onDidChangeScreenReaderOptimized.event;

  @override
  bool isScreenReaderOptimized() {
    final Object? config = _getAccessibilitySupportConfigurationValue();
    return config == 'on' ||
        (config == 'auto' && _accessibilitySupport == AccessibilitySupport.Enabled);
  }

  Object? _getAccessibilitySupportConfigurationValue() {
    final Map<String, Object?> inspected =
        _configurationService.inspect('editor.accessibilitySupport');
    for (final String key in const <String>[
      'policyValue',
      'memoryValue',
      'workspaceFolderValue',
      'workspaceValue',
      'userValue',
      'applicationValue',
      'defaultValue'
    ]) {
      final Object? value = inspected[key];
      if (value != null) return value;
    }
    return 'auto';
  }

  @override
  Event<void> get onDidChangeReducedMotion => _onDidChangeReducedMotion.event;

  @override
  bool isMotionReduced() =>
      _configMotionReduced == 'on' ||
      (_configMotionReduced == 'auto' && _systemMotionReduced);

  @override
  Event<void> get onDidChangeReducedTransparency =>
      _onDidChangeReducedTransparency.event;

  @override
  bool isTransparencyReduced() =>
      _configTransparencyReduced == 'on' ||
      (_configTransparencyReduced == 'auto' && _systemTransparencyReduced);

  @override
  Future<bool> alwaysUnderlineAccessKeys() => Future<bool>.value(false);

  @override
  int getAccessibilitySupport() => _accessibilitySupport;

  @override
  void setAccessibilitySupport(int accessibilitySupport) {
    if (_accessibilitySupport == accessibilitySupport) return;
    _accessibilitySupport = accessibilitySupport;
    _onDidChangeScreenReaderOptimized.fire(null);
  }

  @override
  void alert(String message) => aria.alert(message);

  @override
  void status(String message) => aria.status(message);
}
