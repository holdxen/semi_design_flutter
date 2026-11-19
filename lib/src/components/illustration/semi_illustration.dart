import 'dart:math' as math;

import 'package:flutter/widgets.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../theme/semi_theme.dart';

/// Const description of one upstream `@douyinfe/semi-illustrations` SVG asset.
///
/// [asset] is a package asset of `semi_design_flutter` (see the generated
/// `SemiIllustrations` catalog). Use it with [SemiIllustration] or feed it to a
/// custom wrapper such as `SvgPicture.asset(descriptor.asset,
/// package: descriptor.package)`.
class SemiIllustrationDescriptor {
  const SemiIllustrationDescriptor({
    required this.name,
    required this.asset,
    this.package = 'semi_design_flutter',
  });

  /// Catalog name: the upstream export in lowerCamelCase.
  final String name;

  /// Package-relative path of the generated SVG asset.
  final String asset;

  /// Package owning [asset]; passed through to `SvgPicture.asset`.
  final String package;
}

/// One `semi-illustrations` artwork at its native 200x200 viewBox size.
///
/// Pick the asset through [SemiThemeData.dark]: dark mode prefers [dark] and
/// falls back to [light] when it is omitted; light mode always uses [light].
/// Pass a single descriptor to pin one artwork in both modes. The SVG's
/// `currentColor` fills resolve to `theme.colors.colorPrimary` through
/// [SvgTheme], so the accent follows custom themes; the pre-baked light
/// accent fills stay at the default theme values (see docs/semi_empty.md).
///
/// Size is logical pixels and never follows the text scale. The artwork is
/// decorative: semantics are excluded (upstream sets `aria-hidden`).
class SemiIllustration extends StatelessWidget {
  const SemiIllustration(this.light, {super.key, this.dark, this.size = 200})
    : assert(size == null || (size > 0 && size < double.infinity));

  /// Artwork used in light mode, and in dark mode when [dark] is null.
  final SemiIllustrationDescriptor light;

  /// Optional artwork used in dark mode.
  final SemiIllustrationDescriptor? dark;

  /// Fixed rendered side length when non-null; defaults to the native 200.
  ///
  /// When null the artwork adapts to the incoming constraints instead: its
  /// square side is the smallest bounded dimension, so a tightly sized parent
  /// is filled with the artwork contained (centered, aspect-preserving) and a
  /// single bounded axis defines the square. Layout with both axes unbounded
  /// falls back to the native 200x200.
  final double? size;

  static const double _nativeSize = 200;

  @override
  Widget build(BuildContext context) {
    final theme = SemiTheme.of(context);
    final asset = theme.dark && dark != null ? dark! : light;
    final Widget picture;
    if (size case final double side) {
      picture = SvgPicture.asset(
        asset.asset,
        package: asset.package,
        width: side,
        height: side,
        theme: SvgTheme(currentColor: theme.colors.colorPrimary),
        excludeFromSemantics: true,
      );
    } else {
      picture = LayoutBuilder(
        builder: (context, constraints) {
          final box = _adaptiveSize(constraints);
          return SizedBox(
            width: box.width,
            height: box.height,
            child: SvgPicture.asset(
              asset.asset,
              package: asset.package,
              fit: BoxFit.contain,
              theme: SvgTheme(currentColor: theme.colors.colorPrimary),
              excludeFromSemantics: true,
            ),
          );
        },
      );
    }
    return ExcludeSemantics(child: picture);
  }

  /// Uses the smallest bounded side; a tight box is enforced by the parent, so
  /// the artwork is contained in it. Falls back to the native size when both
  /// axes are unbounded.
  static Size _adaptiveSize(BoxConstraints constraints) {
    final double? width = constraints.hasBoundedWidth
        ? constraints.maxWidth
        : null;
    final double? height = constraints.hasBoundedHeight
        ? constraints.maxHeight
        : null;
    return switch ((width, height)) {
      (final double w, final double h) => Size.square(math.min(w, h)),
      (final double w, null) => Size.square(w),
      (null, final double h) => Size.square(h),
      (null, null) => const Size(_nativeSize, _nativeSize),
    };
  }
}
