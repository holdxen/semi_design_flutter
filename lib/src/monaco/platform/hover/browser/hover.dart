// 1:1 port of vscode/src/vs/platform/hover/browser/hover.ts
import '../../../base/browser/dom.dart' as dom;
import '../../../base/browser/ui/hover/hover.dart' as h;
import '../../../base/browser/ui/hover/hoverDelegate.dart' as d;
import '../../../base/common/keyCodes.dart' show KeyCode;
import '../../../base/common/lifecycle.dart' as lifecycle;
import '../../instantiation/common/instantiation.dart' show ServiceIdentifier, createDecorator;

/// 1:1: `export const IHoverService = createDecorator<IHoverService>('hoverService')`.
final ServiceIdentifier<IHoverServiceType> IHoverService =
    createDecorator<IHoverServiceType>('hoverService');

/// 1:1: `export interface IHoverService extends IHoverDelegate2`.
abstract class IHoverServiceType implements h.IHoverDelegate2 {
  Object? get serviceBrand;

  h.IHoverWidget? getStickyHover(dom.DomElement targetElement);
}

/// 1:1: `export interface IHoverDelayOptions`.
class IHoverDelayOptions {
  IHoverDelayOptions({this.instantHover, this.dynamicDelay});

  final bool? instantHover;
  final num? Function(Object? content)? dynamicDelay;
}

Map<String, Object?> _asMap(Object? value) =>
    value is Map ? value.cast<String, Object?>() : <String, Object?>{};

Map<String, Object?> _appearanceAsMap(Object? value) {
  if (value is h.IHoverAppearanceOptions) {
    return <String, Object?>{
      'showPointer': value.showPointer,
      'compact': value.compact,
      'showHoverHint': value.showHoverHint,
      'skipFadeInAnimation': value.skipFadeInAnimation,
      'maxHeightRatio': value.maxHeightRatio,
    };
  }
  return _asMap(value);
}

/// 1:1: `export class WorkbenchHoverDelegate extends Disposable implements IHoverDelegate`.
class WorkbenchHoverDelegate extends lifecycle.Disposable implements d.IHoverDelegate {
  WorkbenchHoverDelegate(
    this.placement,
    this.hoverOptions, [
    Object? overrideOptions,
    dynamic configurationService,
    dynamic hoverService,
  ]) : super() {
    _overrideOptions = overrideOptions ?? <String, Object?>{};
    _configurationService = configurationService;
    _hoverService = hoverService;
    _delay = _readDelay();
    register(configurationService.onDidChangeConfiguration((Object e) {
      if ((e as dynamic).affectsConfiguration('workbench.hover.delay') as bool) {
        _delay = _readDelay();
      }
    }));
  }

  @override
  final String placement;

  final IHoverDelayOptions? hoverOptions;

  late Object _overrideOptions;
  late final dynamic _configurationService;
  late final dynamic _hoverService;

  int lastHoverHideTime = 0;
  int timeLimit = 200;
  int _delay = 0;

  final lifecycle.DisposableStore hoverDisposables = lifecycle.DisposableStore();

  int _readDelay() {
    final Object? value =
        _configurationService.getValue$1('workbench.hover.delay') as Object?;
    return (value as num?)?.toInt() ?? 0;
  }

  bool _isInstantlyHovering() {
    return (hoverOptions?.instantHover ?? false) &&
        DateTime.now().millisecondsSinceEpoch - lastHoverHideTime < timeLimit;
  }

  @override
  Object get delay {
    if (_isInstantlyHovering()) {
      return 0;
    }
    final num? Function(Object?)? dynamicDelay = hoverOptions?.dynamicDelay;
    if (dynamicDelay != null) {
      return (Object? content) => dynamicDelay(content) ?? _delay;
    }
    return _delay;
  }

  void Function()? onDidHideHoverField;

  @override
  void Function()? get onDidHideHover => onDidHideHoverField ?? _handleOnDidHideHover;

  @override
  set onDidHideHover(void Function()? value) => onDidHideHoverField = value;

  @override
  bool? get showNativeHover => null;

  @override
  h.IHoverWidget? showHover(d.IHoverDelegateOptions options, [bool? focus]) {
    final Object resolvedOverride = _overrideOptions is Function
        ? Function.apply(_overrideOptions as Function, <Object?>[options, focus])
        : _overrideOptions;
    final Map<String, Object?> overrides = _asMap(resolvedOverride);

    hoverDisposables.clear();
    final Object target = options.target;
    final List<dom.DomElement> targets = dom.isHTMLElement(target)
        ? <dom.DomElement>[target as dom.DomElement]
        : (target as dynamic).targetElements as List<dom.DomElement>;
    for (final dom.DomElement element in targets) {
      hoverDisposables.add(dom.addStandardDisposableListener(
          element, 'keydown', (Object e) {
        if ((e as dynamic).equals(KeyCode.Escape) as bool) {
          _hoverService.hideHover();
        }
      }));
    }

    final Object? content = options.content;
    final Object? id = dom.isHTMLElement(content)
        ? null
        : content is String
            ? content.toString()
            : (content as dynamic).value;

    final Map<String, Object?> appearance =
        _appearanceAsMap(options.appearance);
    appearance['compact'] = true;
    appearance['skipFadeInAnimation'] = _isInstantlyHovering();
    appearance.addAll(_appearanceAsMap(overrides['appearance']));

    final Map<String, Object?> persistence = <String, Object?>{
      'hideOnKeyDown': true,
      ..._asMap(overrides['persistence']),
    };

    final h.IHoverOptions merged = h.IHoverOptions(
      content: content as Object,
      target: target,
      container: overrides.containsKey('container')
          ? overrides['container'] as dom.DomElement?
          : options.container,
      id: id as String?,
      actions: (overrides['actions'] as List<h.IHoverAction>?) ?? options.actions,
      additionalClasses:
          (overrides['additionalClasses'] as List<String>?) ?? options.additionalClasses,
      linkHandler: (overrides['linkHandler'] as void Function(String)?) ??
          options.linkHandler,
      trapFocus: (overrides['trapFocus'] as bool?) ?? options.trapFocus,
      style: overrides['style'] as int?,
      position: (overrides['position'] as h.IHoverPositionOptions?) ??
          options.position,
      persistence: h.IHoverPersistenceOptions(
        hideOnHover: persistence['hideOnHover'] as bool?,
        hideOnKeyDown: persistence['hideOnKeyDown'] as bool?,
        sticky: persistence['sticky'] as bool?,
      ),
      appearance: h.IHoverAppearanceOptions(
        showPointer: appearance['showPointer'] as bool?,
        compact: appearance['compact'] as bool?,
        showHoverHint: appearance['showHoverHint'] as bool?,
        skipFadeInAnimation: appearance['skipFadeInAnimation'] as bool?,
        maxHeightRatio: appearance['maxHeightRatio'] as num?,
      ),
      onDidShow: (overrides['onDidShow'] as void Function()?) ?? options.onDidShow,
    );
    return _hoverService.showInstantHover(merged, focus) as h.IHoverWidget?;
  }

  /// 1:1: `setInstantHoverTimeLimit(timeLimit)`.
  void setInstantHoverTimeLimit(int value) {
    if (!(hoverOptions?.instantHover ?? false)) {
      throw StateError('Instant hover is not enabled');
    }
    timeLimit = value;
  }

  /// 1:1: `onDidHideHover()`.
  void _handleOnDidHideHover() {
    hoverDisposables.clear();
    if (hoverOptions?.instantHover ?? false) {
      lastHoverHideTime = DateTime.now().millisecondsSinceEpoch;
    }
  }

  @override
  void dispose() {
    hoverDisposables.dispose();
    super.dispose();
  }
}

class _NativeHoverDelegate implements d.IHoverDelegate {
  _NativeHoverDelegate();

  @override
  h.IHoverWidget? showHover(d.IHoverDelegateOptions options, [bool? focus]) {
    throw StateError('Native hover function not implemented.');
  }

  @override
  void Function()? onDidHideHover;

  @override
  Object get delay => 0;

  @override
  String? get placement => null;

  @override
  bool get showNativeHover => true;
}

/// 1:1: `export const nativeHoverDelegate: IHoverDelegate`.
final d.IHoverDelegate nativeHoverDelegate = _NativeHoverDelegate();
