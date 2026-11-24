// 1:1 port of vscode/src/vs/base/browser/ui/countBadge/countBadge.ts
import '../../dom.dart' as dom;
import '../../../common/lifecycle.dart' as lifecycle;
import '../../../common/strings.dart' as strings;
import '../hover/hoverDelegate2.dart' show getBaseLayerHoverDelegate;

/// 1:1: `export interface ICountBadgeOptions`.
class ICountBadgeOptions {
  ICountBadgeOptions({this.count, this.countFormat, this.titleFormat});

  final int? count;
  final String? countFormat;
  final String? titleFormat;
}

/// 1:1: `export interface ICountBadgeStyles`.
class ICountBadgeStyles {
  const ICountBadgeStyles({
    required this.badgeBackground,
    required this.badgeForeground,
    required this.badgeBorder,
  });

  final String? badgeBackground;
  final String? badgeForeground;
  final String? badgeBorder;
}

/// 1:1: `export const unthemedCountStyles`.
final ICountBadgeStyles unthemedCountStyles = ICountBadgeStyles(
  badgeBackground: '#4D4D4D',
  badgeForeground: '#FFFFFF',
  badgeBorder: null,
);

/// 1:1: `export class CountBadge extends Disposable`.
class CountBadge extends lifecycle.Disposable {
  CountBadge(
    dom.DomElement container,
    this.options,
    this.styles,
  ) : super() {
    element = dom.append(
        container, <Object>[dom.$('.monaco-count-badge')]) as dom.DomElement;
    register(lifecycle.toDisposable(() => container.removeChild(element)));
    countFormat = _nonEmpty(options.countFormat, '{0}');
    titleFormat = _nonEmpty(options.titleFormat, '');
    setCount(options.count ?? 0);
    _updateHover();
  }

  final ICountBadgeOptions options;
  final ICountBadgeStyles styles;

  late final dom.DomElement element;
  int count = 0;
  late String countFormat;
  late String titleFormat;

  final lifecycle.MutableDisposable<lifecycle.IDisposable> hover =
      lifecycle.MutableDisposable<lifecycle.IDisposable>();

  static String _nonEmpty(String? value, String fallback) =>
      value == null || value.isEmpty ? fallback : value;

  @override
  void dispose() {
    hover.dispose();
    super.dispose();
  }

  /// 1:1: `setCount(count)`.
  void setCount(int value) {
    count = value;
    _render();
  }

  /// 1:1: `setCountFormat(countFormat)`.
  void setCountFormat(String value) {
    countFormat = value;
    _render();
  }

  /// 1:1: `setTitleFormat(titleFormat)`.
  void setTitleFormat(String value) {
    titleFormat = value;
    _updateHover();
    _render();
  }

  void _updateHover() {
    if (titleFormat != '' && hover.value == null) {
      final Object? result =
          getBaseLayerHoverDelegate().setupDelayedHoverAtMouse(element, () {
        return <String, Object?>{
          'content': strings.format(titleFormat, <Object?>[count]),
          'appearance': <String, Object?>{'compact': true},
        };
      });
      if (result is lifecycle.IDisposable) {
        hover.value = result;
      }
    } else if (titleFormat == '' && hover.value != null) {
      hover.value = null;
    }
  }

  void _render() {
    element.textContent = strings.format(countFormat, <Object?>[count]);
    element.style['backgroundColor'] = styles.badgeBackground ?? '';
    element.style['color'] = styles.badgeForeground ?? '';
    final String? border = styles.badgeBorder;
    if (border != null) {
      element.style['border'] = '1px solid $border';
    }
  }
}
