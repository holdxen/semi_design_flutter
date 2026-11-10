import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import '../theme/semi_theme.dart';
import '../theme/semi_tag_theme.dart';
import '../tokens/token_types.dart';
import 'icon/semi_icon.dart';
import 'icon/semi_icons.dart';

enum SemiTagSize { normal, small, large }

enum SemiTagType { light, solid, ghost }

enum SemiTagShape { square, circle }

enum SemiTagColor {
  amber,
  blue,
  cyan,
  green,
  grey,
  indigo,
  lightBlue,
  lightGreen,
  lime,
  orange,
  pink,
  purple,
  red,
  teal,
  violet,
  yellow,
  white,
}

/// A synchronous, cancelable close request. Late prevention has no effect.
class SemiTagCloseEvent {
  SemiTagCloseEvent(this.text, this.tagKey);
  final String text;
  final Object? tagKey;
  bool _prevented = false;
  bool _active = true;
  bool get defaultPrevented => _prevented;
  void preventDefault() {
    if (_active) _prevented = true;
  }
}

/// A source-sized, non-Material tag. Releasing controlled visibility retains
/// the last controlled value; entering controlled mode preserves local state.
class SemiTag extends StatefulWidget {
  const SemiTag(
    this.text, {
    super.key,
    this.size = SemiTagSize.normal,
    this.type = SemiTagType.light,
    this.shape = SemiTagShape.square,
    this.color = SemiTagColor.grey,
    this.closable = false,
    this.visible,
    this.tagKey,
    this.onClose,
    this.onTap,
    this.prefixIcon,
    this.suffixIcon,
    this.avatar,
    this.avatarShape = SemiTagShape.square,
    this.colorful = false,
    this.gradient = false,
    this.semanticsLabel,
    this.closeSemanticsLabel,
    this.backgroundColor,
    this.textColor,
    this.borderColor,
    this.style,
  });
  final String text;
  final SemiTagSize size;
  final SemiTagType type;
  final SemiTagShape shape, avatarShape;
  final SemiTagColor color;
  final bool closable, colorful, gradient;
  final bool? visible;
  final Object? tagKey;
  final ValueChanged<SemiTagCloseEvent>? onClose;
  final VoidCallback? onTap;
  final Widget? prefixIcon, suffixIcon, avatar;
  final String? semanticsLabel, closeSemanticsLabel;
  final Color? backgroundColor, textColor, borderColor;
  final TextStyle? style;
  @override
  State<SemiTag> createState() => _SemiTagState();
}

class _SemiTagState extends State<SemiTag> {
  bool _visible = true,
      _focused = false,
      _closeHover = false,
      _closePressed = false;
  final _focus = FocusNode();
  @override
  void didUpdateWidget(SemiTag oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.visible != null && widget.visible == null) {
      _visible = oldWidget.visible!;
    }
  }

  @override
  void dispose() {
    _focus.dispose();
    super.dispose();
  }

  void _close() {
    if (!widget.closable) return;
    final event = SemiTagCloseEvent(widget.text, widget.tagKey);
    try {
      widget.onClose?.call(event);
    } finally {
      event._active = false;
    }
    if (mounted && !event.defaultPrevented && widget.visible == null) {
      setState(() => _visible = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!(widget.visible ?? _visible)) return const SizedBox.shrink();
    final global = SemiTheme.of(context);
    final t = SemiTagTheme.resolve(context);
    final p = global.palette;
    final c = global.colors;
    // PALETTE
    final levels = <SemiTagColor, List<Color>>{
      SemiTagColor.amber: [
        p.amber4.toColor(),
        p.amber5.toColor(),
        p.amber8.toColor(),
      ],
      SemiTagColor.blue: [
        p.blue4.toColor(),
        p.blue5.toColor(),
        p.blue8.toColor(),
      ],
      SemiTagColor.cyan: [
        p.cyan4.toColor(),
        p.cyan5.toColor(),
        p.cyan8.toColor(),
      ],
      SemiTagColor.green: [
        p.green4.toColor(),
        p.green5.toColor(),
        p.green8.toColor(),
      ],
      SemiTagColor.grey: [
        p.grey4.toColor(),
        p.grey5.toColor(),
        p.grey8.toColor(),
      ],
      SemiTagColor.indigo: [
        p.indigo4.toColor(),
        p.indigo5.toColor(),
        p.indigo8.toColor(),
      ],
      SemiTagColor.lightBlue: [
        p.lightBlue4.toColor(),
        p.lightBlue5.toColor(),
        p.lightBlue8.toColor(),
      ],
      SemiTagColor.lightGreen: [
        p.lightGreen4.toColor(),
        p.lightGreen5.toColor(),
        p.lightGreen8.toColor(),
      ],
      SemiTagColor.lime: [
        p.lime4.toColor(),
        p.lime5.toColor(),
        p.lime8.toColor(),
      ],
      SemiTagColor.orange: [
        p.orange4.toColor(),
        p.orange5.toColor(),
        p.orange8.toColor(),
      ],
      SemiTagColor.pink: [
        p.pink4.toColor(),
        p.pink5.toColor(),
        p.pink8.toColor(),
      ],
      SemiTagColor.purple: [
        p.purple4.toColor(),
        p.purple5.toColor(),
        p.purple8.toColor(),
      ],
      SemiTagColor.red: [p.red4.toColor(), p.red5.toColor(), p.red8.toColor()],
      SemiTagColor.teal: [
        p.teal4.toColor(),
        p.teal5.toColor(),
        p.teal8.toColor(),
      ],
      SemiTagColor.violet: [
        p.violet4.toColor(),
        p.violet5.toColor(),
        p.violet8.toColor(),
      ],
      SemiTagColor.yellow: [
        p.yellow4.toColor(),
        p.yellow5.toColor(),
        p.yellow8.toColor(),
      ],
    };
    final palette =
        levels[widget.color] ?? [c.colorWhite, c.colorWhite, c.colorText0];
    Color bg = widget.type == SemiTagType.light
        ? palette[1].withValues(alpha: .15)
        : widget.type == SemiTagType.solid
        ? palette[1]
        : const Color(0x00000000);
    Color fg = widget.type == SemiTagType.solid
        ? c.colorWhite
        : widget.type == SemiTagType.light
        ? palette[2]
        : palette[1];
    Color border = widget.type == SemiTagType.ghost
        ? palette[0]
        : const Color(0x00000000);
    double borderWidth = widget.type == SemiTagType.ghost
        ? t.widthTagBorder!
        : 0;
    SemiGradient? backgroundGradient, textGradient, borderGradient;
    if (widget.colorful) {
      switch (widget.type) {
        case SemiTagType.solid:
          bg = t.colorTagColorfulSolidBg!;
          fg = t.colorTagColorfulSolidText!;
          if (widget.gradient) {
            backgroundGradient = t.colorTagColorfulSolidGradientBg;
          }
        case SemiTagType.light:
          bg = t.colorTagColorfulLightBg!;
          fg = t.colorTagColorfulLightText!;
          if (widget.gradient) {
            backgroundGradient = t.colorTagColorfulLightGradientBg;
            textGradient = t.colorTagColorfulLightGradientText;
          }
        case SemiTagType.ghost:
          bg = t.colorTagColorfulGhostBg!;
          fg = t.colorTagColorfulGhostText!;
          // CSS border-color cannot paint a gradient until gradient mode.
          if (widget.gradient) {
            borderGradient = t.colorTagColorfulGhostBorder;
            textGradient = t.colorTagColorfulGhostGradientText;
          }
      }
    }
    // Two-class AI selectors win background/text specificity, while the
    // later white/avatar rules still supply their border shorthand.
    if (widget.color == SemiTagColor.white) {
      if (!widget.colorful) {
        bg = t.colorTagWhiteBgDefault!;
        fg = t.colorTagWhiteTextDefault!;
      }
      border = t.colorTagWhiteBorderDefault!;
      borderWidth = t.widthTagBorder!;
    }
    if (widget.avatar != null) {
      if (!widget.colorful) {
        bg = t.colorTagAvatarBgDefault!;
        fg = t.colorTagAvatarTextDefault!;
      }
      border = t.colorTagAvatarBorderDefault!;
      borderWidth = t.widthTagAvatarBorder!;
    }
    if (borderGradient != null) borderWidth = t.widthTagBorder!;
    final customBg = widget.backgroundColor ?? t.backgroundColor;
    final customFg = widget.textColor ?? t.textColor;
    final customBorder = widget.borderColor ?? t.borderColor;
    if (customBg != null) {
      bg = customBg;
      backgroundGradient = null;
    }
    if (customFg != null) {
      fg = customFg;
      textGradient = null;
    }
    if (customBorder != null) {
      border = customBorder;
      borderWidth = t.widthTagBorder!;
      borderGradient = null;
    }
    final large = widget.size == SemiTagSize.large;
    final height = large ? t.heightTagLarge! : t.heightTagSmall!;
    var radius = widget.shape == SemiTagShape.circle
        ? t.radiusTagCircle!
        : t.radiusTag!;
    EdgeInsetsGeometry padding = EdgeInsets.symmetric(
      horizontal: large
          ? t.spacingTagLargePaddingX!
          : t.spacingTagSmallPaddingX!,
      vertical: large ? t.spacingTagLargePaddingY! : t.spacingTagSmallPaddingY!,
    );
    if (widget.closable) {
      padding = EdgeInsetsDirectional.fromSTEB(
        t.spacingTagClosablePaddingLeft!,
        t.spacingTagClosablePaddingTop!,
        t.spacingTagClosablePaddingRight!,
        t.spacingTagClosablePaddingBottom!,
      );
    }
    if (widget.avatar != null) {
      if (widget.avatarShape == SemiTagShape.circle) {
        radius = height / 2 + 1;
        padding = EdgeInsetsDirectional.fromSTEB(
          t.spacingTagAvatarCirclePaddingLeft!,
          t.spacingTagAvatarCirclePaddingTop!,
          t.spacingTagAvatarCirclePaddingRight!,
          t.spacingTagAvatarCirclePaddingBottom!,
        );
      } else {
        padding = EdgeInsetsDirectional.fromSTEB(
          t.spacingTagAvatarSquarePaddingLeft!,
          t.spacingTagAvatarSquarePaddingTop!,
          t.spacingTagAvatarSquarePaddingRight!,
          t.spacingTagAvatarSquarePaddingBottom!,
        );
      }
    }
    Widget text = Text(
      widget.text,
      maxLines: 1,
      softWrap: false,
      overflow: TextOverflow.ellipsis,
      style: TextStyle(
        fontSize: global.typography.fontSizeSmall,
        color: fg,
        fontWeight: widget.colorful ? t.fontTagColorfulFontWeight : null,
      ).merge(widget.style),
    );
    if (textGradient != null) {
      final gradient = textGradient;
      text = ShaderMask(
        blendMode: BlendMode.srcIn,
        shaderCallback: (r) => gradient.forSize(r.size).createShader(r),
        child: text,
      );
    }
    final closeColor = widget.color == SemiTagColor.white
        ? t.colorTagWhiteIconDefault
        : _closePressed
        ? t.colorTagCloseIconActive
        : _closeHover
        ? t.colorTagCloseIconHover
        : t.colorTagCloseIconDefault;
    Widget slot(Widget child, double gap, {bool before = false}) => Padding(
      padding: EdgeInsetsDirectional.only(
        start: before ? 0 : gap,
        end: before ? gap : 0,
      ),
      child: child,
    );
    final children = <Widget>[
      if (widget.prefixIcon != null)
        slot(
          widget.prefixIcon!,
          t.spacingTagPrefixIconPaddingRight!,
          before: true,
        ),
      if (widget.avatar != null)
        slot(
          ClipRRect(
            borderRadius: BorderRadius.circular(
              widget.avatarShape == SemiTagShape.circle ? height : 0,
            ),
            child: SizedBox.square(
              dimension: widget.avatarShape == SemiTagShape.circle
                  ? (large
                        ? t.widthTagAvatarCircleLarge!
                        : t.widthTagAvatarCircleSmall!)
                  : height,
              child: ColoredBox(
                color: t.colorTagAvatarSquareImgBgDefault!,
                child: widget.avatar!,
              ),
            ),
          ),
          t.spacingTagAvatarMarginRight!,
          before: true,
        ),
    ];
    final trailing = <Widget>[
      if (widget.suffixIcon != null)
        slot(widget.suffixIcon!, t.spacingTagSuffixIconPaddingLeft!),
      if (widget.closable)
        slot(
          MouseRegion(
            onEnter: (_) => setState(() => _closeHover = true),
            onExit: (_) => setState(() {
              _closeHover = false;
              _closePressed = false;
            }),
            child: Semantics(
              button: true,
              label: widget.closeSemanticsLabel ?? 'Close ${widget.text}',
              onTap: _close,
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: _close,
                onTapDown: (_) => setState(() => _closePressed = true),
                onTapUp: (_) => setState(() => _closePressed = false),
                onTapCancel: () => setState(() => _closePressed = false),
                child: ExcludeSemantics(
                  child: SemiIcon(
                    SemiIcons.close,
                    customSize: 12,
                    color: closeColor,
                  ),
                ),
              ),
            ),
          ),
          t.spacingTagClosePaddingLeft!,
        ),
    ];
    Widget body = SizedBox(
      height: height,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(radius),
        child: CustomPaint(
          painter: _TagPainter(
            bg,
            border,
            borderWidth,
            radius,
            backgroundGradient,
            borderGradient,
          ),
          child: Padding(
            padding: padding,
            child: LayoutBuilder(
              builder: (context, constraints) => ClipRect(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ...children.map(
                      (child) => constraints.hasBoundedWidth
                          ? Flexible(child: ClipRect(child: child))
                          : child,
                    ),
                    if (constraints.hasBoundedWidth)
                      Flexible(child: text)
                    else
                      text,
                    ...trailing.map(
                      (child) => constraints.hasBoundedWidth
                          ? Flexible(child: ClipRect(child: child))
                          : child,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
    if (_focused) {
      body = CustomPaint(
        foregroundPainter: _TagFocusPainter(
          t.colorTagOutlineFocus!,
          t.widthTagOutline!,
          radius,
        ),
        child: body,
      );
    }
    return Semantics(
      button: widget.onTap != null || widget.closable,
      label: widget.semanticsLabel ?? widget.text,
      onTap: widget.onTap,
      child: Focus(
        focusNode: _focus,
        canRequestFocus: widget.onTap != null || widget.closable,
        onFocusChange: (v) => setState(() => _focused = v),
        onKeyEvent: (_, event) {
          if (event is! KeyDownEvent) return KeyEventResult.ignored;
          if (event.logicalKey == LogicalKeyboardKey.escape) {
            _focus.unfocus();
            return KeyEventResult.handled;
          }
          if (event.logicalKey == LogicalKeyboardKey.enter) {
            widget.onTap?.call();
            return KeyEventResult.handled;
          }
          if (widget.closable &&
              (event.logicalKey == LogicalKeyboardKey.delete ||
                  event.logicalKey == LogicalKeyboardKey.backspace)) {
            _close();
            return KeyEventResult.handled;
          }
          return KeyEventResult.ignored;
        },
        child: GestureDetector(onTap: widget.onTap, child: body),
      ),
    );
  }
}

class _TagPainter extends CustomPainter {
  const _TagPainter(
    this.background,
    this.border,
    this.width,
    this.radius,
    this.gradient,
    this.borderGradient,
  );
  final Color background, border;
  final double width, radius;
  final SemiGradient? gradient, borderGradient;
  @override
  void paint(Canvas canvas, Size size) {
    if (size.isEmpty) return;
    final rect = Offset.zero & size;
    final rrect = RRect.fromRectAndRadius(rect, Radius.circular(radius));
    final paint = Paint()..color = background;
    if (gradient != null) {
      paint.shader = gradient!.forSize(size).createShader(rect);
    }
    canvas.drawRRect(rrect, paint);
    if (width > 0) {
      final stroke = Paint()
        ..color = border
        ..style = PaintingStyle.stroke
        ..strokeWidth = width;
      if (borderGradient != null) {
        stroke.shader = borderGradient!.forSize(size).createShader(rect);
      }
      canvas.drawRRect(rrect.deflate(width / 2), stroke);
    }
  }

  @override
  bool shouldRepaint(_TagPainter old) =>
      background != old.background ||
      border != old.border ||
      width != old.width ||
      radius != old.radius ||
      gradient != old.gradient ||
      borderGradient != old.borderGradient;
}

class _TagFocusPainter extends CustomPainter {
  const _TagFocusPainter(this.color, this.width, this.radius);
  final Color color;
  final double width, radius;
  @override
  void paint(Canvas canvas, Size size) => canvas.drawRRect(
    RRect.fromRectAndRadius(
      (Offset.zero & size).inflate(width / 2),
      Radius.circular(radius),
    ),
    Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = width,
  );
  @override
  bool shouldRepaint(_TagFocusPainter old) =>
      color != old.color || width != old.width || radius != old.radius;
}
