import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import '../../theme/semi_theme.dart';

enum SemiTextType {
  primary,
  secondary,
  tertiary,
  quaternary,
  warning,
  danger,
  success,
}

enum SemiTextSize { normal, small, inherit }

/// Opening a destination is the caller's responsibility. Visited is controlled.
@immutable
class SemiTextLink {
  const SemiTextLink({required this.onTap, this.visited = false});
  final VoidCallback onTap;
  final bool visited;
}

// Local Sass-derived metrics, not generated CSS variable tokens.
// packages/semi-foundation/typography/{variables,typography}.scss;
// packages/semi-theme-default/scss/global.scss (font-size mixins).
abstract final class _Metrics {
  static const normal = 14.0, normalHeight = 20 / 14;
  static const small = 12.0, smallHeight = 16 / 12;
  static const gap = 4.0, border = 1.0, radius = 2.0;
  static const codePadding = EdgeInsets.symmetric(vertical: 2, horizontal: 4);
  static const strong = FontWeight.w600;
}

/// String-only typography with optional, accessible callback-based link behavior.
class SemiText extends StatefulWidget {
  const SemiText(
    this.data, {
    super.key,
    this.type = SemiTextType.primary,
    this.size = SemiTextSize.normal,
    this.weight,
    this.strong = false,
    this.disabled = false,
    this.mark = false,
    this.code = false,
    this.underline = false,
    this.delete = false,
    this.style,
    this.icon,
    this.link,
    this.textAlign,
    this.textDirection,
    this.softWrap,
    this.maxLines,
    this.overflow,
    this.semanticsLabel,
  }) : assert(maxLines == null || maxLines > 0);

  final String data;
  final SemiTextType type;
  final SemiTextSize size;
  final FontWeight? weight;
  final bool strong, disabled, mark, code, underline, delete;
  final TextStyle? style;
  final Widget? icon;
  final SemiTextLink? link;
  final TextAlign? textAlign;
  final TextDirection? textDirection;
  final bool? softWrap;
  final int? maxLines;
  final TextOverflow? overflow;
  final String? semanticsLabel;

  @override
  State<SemiText> createState() => _SemiTextState();
}

class _SemiTextState extends State<SemiText> {
  bool _hover = false, _pressed = false, _focus = false;
  bool get _enabled => widget.link != null && !widget.disabled;

  @override
  void didUpdateWidget(SemiText oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!_enabled || oldWidget.link == null) {
      _hover = _pressed = _focus = false;
    }
  }

  void _activate() {
    if (_enabled) widget.link!.onTap();
  }

  void _setPressed(bool value) {
    if (mounted && _pressed != value) {
      setState(() => _pressed = value && _enabled);
    }
  }

  @override
  Widget build(BuildContext context) {
    final w = widget;
    final c = SemiTheme.of(context).colors;
    final inherited = DefaultTextStyle.of(context).style;
    Color color = switch (w.type) {
      SemiTextType.primary => c.colorText0,
      SemiTextType.secondary => c.colorText1,
      SemiTextType.tertiary => c.colorText2,
      SemiTextType.quaternary => c.colorText3,
      SemiTextType.warning => c.colorWarning,
      SemiTextType.danger => c.colorDanger,
      SemiTextType.success => c.colorSuccess,
    };
    if (w.code) color = c.colorText2;
    if (w.link != null) {
      color = _pressed
          ? c.colorLinkActive
          : _hover
          ? c.colorLinkHover
          : w.link!.visited
          ? c.colorLinkVisited
          : c.colorLink;
    }
    if (w.disabled) color = c.colorDisabledText;
    final decoration = TextDecoration.combine([
      if (w.underline && (w.link == null || (_enabled && (_hover || _pressed))))
        TextDecoration.underline,
      if (w.delete) TextDecoration.lineThrough,
    ]);
    final resolved = inherited
        .copyWith(
          color: color,
          fontSize: switch (w.size) {
            SemiTextSize.normal => _Metrics.normal,
            SemiTextSize.small => _Metrics.small,
            SemiTextSize.inherit => inherited.fontSize,
          },
          height: switch (w.size) {
            SemiTextSize.normal => _Metrics.normalHeight,
            SemiTextSize.small => _Metrics.smallHeight,
            SemiTextSize.inherit => inherited.height,
          },
          fontWeight:
              w.weight ??
              ((w.strong || w.link != null)
                  ? _Metrics.strong
                  : FontWeight.w400),
          decoration: decoration,
          backgroundColor: w.mark && !w.code
              ? c.colorPrimaryLightDefault
              : null,
        )
        .merge(w.style)
        .copyWith(inherit: false);
    Widget child = Text(
      w.data,
      style: resolved,
      textAlign: w.textAlign,
      textDirection: w.textDirection,
      softWrap: w.softWrap,
      maxLines: w.maxLines,
      overflow: w.overflow,
      semanticsLabel: w.link == null ? w.semanticsLabel : null,
    );
    if (w.icon != null) {
      child = Row(
        mainAxisSize: MainAxisSize.min,
        textDirection: w.textDirection,
        children: [
          ExcludeSemantics(child: w.icon!),
          const SizedBox(width: _Metrics.gap),
          Flexible(child: child),
        ],
      );
    }
    if (w.code) {
      child = DecoratedBox(
        decoration: BoxDecoration(
          color: c.colorFill1,
          border: Border.all(color: c.colorBorder, width: _Metrics.border),
          borderRadius: BorderRadius.circular(_Metrics.radius),
        ),
        child: Padding(padding: _Metrics.codePadding, child: child),
      );
    }
    if (w.link == null) return child;
    child = DecoratedBox(
      decoration: BoxDecoration(
        border: Border.all(
          color: _focus && _enabled
              ? c.colorFocusBorder
              : const Color(0x00000000),
          width: _Metrics.border,
        ),
      ),
      child: child,
    );
    return Semantics(
      link: true,
      enabled: _enabled,
      label: w.semanticsLabel ?? w.data,
      onTap: _enabled ? _activate : null,
      excludeSemantics: true,
      child: FocusableActionDetector(
        enabled: _enabled,
        mouseCursor: _enabled
            ? SystemMouseCursors.click
            : SystemMouseCursors.basic,
        shortcuts: const {
          SingleActivator(LogicalKeyboardKey.enter): ActivateIntent(),
          SingleActivator(LogicalKeyboardKey.space): ActivateIntent(),
        },
        actions: {
          ActivateIntent: CallbackAction<ActivateIntent>(
            onInvoke: (_) {
              _activate();
              return null;
            },
          ),
        },
        onShowHoverHighlight: (value) {
          if (mounted) setState(() => _hover = value && _enabled);
        },
        onShowFocusHighlight: (value) {
          if (mounted) setState(() => _focus = value && _enabled);
        },
        child: MouseRegion(
          onEnter: (_) {
            if (mounted && _enabled) setState(() => _hover = true);
          },
          onExit: (_) {
            if (mounted) setState(() => _hover = false);
          },
          child: GestureDetector(
            excludeFromSemantics: true,
            onTap: _enabled ? _activate : null,
            onTapDown: _enabled ? (_) => _setPressed(true) : null,
            onTapUp: _enabled ? (_) => _setPressed(false) : null,
            onTapCancel: _enabled ? () => _setPressed(false) : null,
            child: child,
          ),
        ),
      ),
    );
  }
}
