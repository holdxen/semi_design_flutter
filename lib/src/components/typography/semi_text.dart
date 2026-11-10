import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import '../../theme/semi_theme.dart';
import '../../theme/semi_icon_theme.dart';
import '../../theme/semi_typography_theme.dart';
import 'paragraph_defaults.dart';

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
  static const border = 1.0;
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
    final theme = SemiTheme.of(context);
    final c = theme.colors;
    final colors = SemiTypographyTheme.resolve(context);
    final typography = theme.typography;
    final inherited = DefaultTextStyle.of(context).style;
    final paragraph = SemiParagraphDefaults.of(context);
    final fontSize = switch (w.size) {
      SemiTextSize.normal => colors.fontSizeRegular,
      SemiTextSize.small => colors.fontSizeSmall,
      SemiTextSize.inherit => inherited.fontSize,
    };
    Color color = switch (w.type) {
      SemiTextType.primary => colors.defaultTextColor,
      SemiTextType.secondary => colors.secondaryTextColor,
      SemiTextType.tertiary => colors.tertiaryTextColor,
      SemiTextType.quaternary => colors.quaternaryTextColor,
      SemiTextType.warning => colors.warningTextColor,
      SemiTextType.danger => colors.dangerTextColor,
      SemiTextType.success => colors.successTextColor,
    };
    if (w.code) color = colors.codeTextColor;
    if (w.link != null) {
      color = _pressed
          ? colors.linkActiveColor
          : _hover
          ? colors.linkHoverColor
          : w.link!.visited
          ? colors.linkVisitedColor
          : colors.linkTextColor;
    }
    if (w.disabled) {
      color = w.link != null
          ? colors.linkDisabledColor
          : colors.disabledTextColor;
    }
    final decoration = TextDecoration.combine([
      if (w.underline && (w.link == null || (_enabled && (_hover || _pressed))))
        TextDecoration.underline,
      if (w.delete) TextDecoration.lineThrough,
    ]);
    final resolved = inherited
        .copyWith(
          color: color,
          fontFamily: w.size == SemiTextSize.inherit
              ? inherited.fontFamily
              : typography.fontFamily,
          fontFamilyFallback: w.size == SemiTextSize.inherit
              ? inherited.fontFamilyFallback
              : typography.fontFamilyFallback,
          fontSize: fontSize,
          height: paragraph?.extendedLineHeight != null
              ? paragraph!.extendedLineHeight! /
                    (fontSize ?? colors.fontSizeRegular)
              : switch (w.size) {
                  SemiTextSize.normal =>
                    colors.lineHeightRegular / colors.fontSizeRegular,
                  SemiTextSize.small =>
                    colors.lineHeightSmall / colors.fontSizeSmall,
                  SemiTextSize.inherit => inherited.height,
                },
          fontWeight:
              w.weight ??
              (w.strong
                  ? colors.strongFontWeight
                  : w.link != null
                  ? colors.linkFontWeight
                  : paragraph?.regularWeight ??
                        (w.size == SemiTextSize.small
                            ? colors.smallTextRegularFontWeight
                            : colors.normalTextRegularFontWeight)),
          decoration: decoration,
          decorationThickness: w.link != null ? colors.linkBorderWidth : null,
          backgroundColor: w.mark && !w.code
              ? colors.markBackgroundColor
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
          ExcludeSemantics(
            child: DefaultTextStyle(
              style: resolved,
              child: SemiIconTheme(
                data: SemiIconThemeData(color: resolved.color),
                child: w.icon!,
              ),
            ),
          ),
          SizedBox(width: colors.iconPrefixMarginRight),
          Flexible(child: child),
        ],
      );
    }
    if (w.code) {
      child = DecoratedBox(
        decoration: BoxDecoration(
          color: colors.codeBackgroundColor,
          border: Border.all(
            color: colors.codeBorderColor,
            width: colors.codeBorderWidth,
          ),
          borderRadius: BorderRadius.circular(colors.codeBorderRadius),
        ),
        child: Padding(padding: colors.codePadding, child: child),
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
