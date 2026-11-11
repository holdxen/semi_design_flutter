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
    : assert(size > 0 && size < double.infinity);

  /// Artwork used in light mode, and in dark mode when [dark] is null.
  final SemiIllustrationDescriptor light;

  /// Optional artwork used in dark mode.
  final SemiIllustrationDescriptor? dark;

  /// Rendered width and height; defaults to the native 200.
  final double size;

  @override
  Widget build(BuildContext context) {
    final theme = SemiTheme.of(context);
    final asset = theme.dark && dark != null ? dark! : light;
    return ExcludeSemantics(
      child: SvgPicture.asset(
        asset.asset,
        package: asset.package,
        width: size,
        height: size,
        theme: SvgTheme(currentColor: theme.colors.colorPrimary),
        excludeFromSemantics: true,
      ),
    );
  }
}
