import 'dart:math' as math;

import 'package:flutter/widgets.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../theme/semi_theme.dart';
import '../../theme/semi_icon_theme.dart';
import 'semi_icon_data.dart';

/// SVG icon. [customSize] overrides enum sizes; null [size] resolves theme then 16.
/// Rotation in degrees adds to the optional 600ms linear spin.
class SemiIcon extends StatefulWidget {
  const SemiIcon(
    this.data, {
    super.key,
    this.size,
    this.customSize,
    this.color,
    this.rotate = 0,
    this.spin = false,
    this.semanticsLabel,
    this.excludeFromSemantics = false,
  }) : assetName = null,
       svgSource = null,
       package = null,
       assert(rotate > -double.infinity && rotate < double.infinity),
       assert(
         customSize == null || (customSize > 0 && customSize < double.infinity),
       );
  const SemiIcon.asset(
    String asset, {
    super.key,
    this.package,
    this.size,
    this.customSize,
    this.color,
    this.rotate = 0,
    this.spin = false,
    this.semanticsLabel,
    this.excludeFromSemantics = false,
  }) : data = null,
       assetName = asset,
       svgSource = null,
       assert(rotate > -double.infinity && rotate < double.infinity),
       assert(
         customSize == null || (customSize > 0 && customSize < double.infinity),
       );
  const SemiIcon.svg(
    String svg, {
    super.key,
    this.size,
    this.customSize,
    this.color,
    this.rotate = 0,
    this.spin = false,
    this.semanticsLabel,
    this.excludeFromSemantics = false,
  }) : data = null,
       assetName = null,
       svgSource = svg,
       package = null,
       assert(rotate > -double.infinity && rotate < double.infinity),
       assert(
         customSize == null || (customSize > 0 && customSize < double.infinity),
       );
  final SemiIconData? data;
  final String? assetName, svgSource, package, semanticsLabel;
  final SemiIconSize? size;
  final double? customSize;
  final Color? color;
  final double rotate;
  final bool spin, excludeFromSemantics;
  @override
  State<SemiIcon> createState() => _SemiIconState();
}

class _SemiIconState extends State<SemiIcon>
    with SingleTickerProviderStateMixin {
  late final AnimationController _spin = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 600),
  );
  void _sync() {
    final animate =
        widget.spin &&
        TickerMode.valuesOf(context).enabled &&
        !MediaQuery.disableAnimationsOf(context);
    if (animate && !_spin.isAnimating) _spin.repeat();
    if (!animate) {
      _spin.stop();
      _spin.value = 0;
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _sync();
  }

  @override
  void didUpdateWidget(SemiIcon oldWidget) {
    super.didUpdateWidget(oldWidget);
    _sync();
  }

  @override
  void dispose() {
    _spin.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final w = widget;
    final theme = SemiIconTheme.of(context);
    final text = DefaultTextStyle.of(context);
    // DefaultTextStyle's root fallback is a debug style, not a host color.
    final host = text == const DefaultTextStyle.fallback()
        ? null
        : text.style.color;
    final color =
        w.color ??
        theme.color ??
        host ??
        SemiTheme.of(context).colors.colorText0;
    final size =
        w.customSize ??
        theme.customSize ??
        switch (w.size ?? theme.size ?? SemiIconSize.normal) {
          SemiIconSize.extraSmall => 8.0,
          SemiIconSize.small => 12.0,
          SemiIconSize.normal => 16.0,
          SemiIconSize.large => 20.0,
          SemiIconSize.extraLarge => 24.0,
          SemiIconSize.inherit => text.style.fontSize ?? 16.0,
        };
    final svgTheme = SvgTheme(currentColor: color);
    final picture = w.svgSource != null
        ? SvgPicture.string(
            w.svgSource!,
            width: size,
            height: size,
            theme: svgTheme,
            excludeFromSemantics: true,
          )
        : SvgPicture.asset(
            w.data?.asset ?? w.assetName!,
            package: w.data?.package ?? w.package,
            width: size,
            height: size,
            theme: svgTheme,
            excludeFromSemantics: true,
          );
    return Semantics(
      label: w.excludeFromSemantics ? null : w.semanticsLabel ?? w.data?.name,
      image:
          !w.excludeFromSemantics &&
          (w.semanticsLabel != null || w.data != null),
      excludeSemantics: true,
      child: AnimatedBuilder(
        animation: _spin,
        child: picture,
        builder: (context, child) => Transform.rotate(
          angle: w.rotate * math.pi / 180 + _spin.value * 2 * math.pi,
          child: child,
        ),
      ),
    );
  }
}
