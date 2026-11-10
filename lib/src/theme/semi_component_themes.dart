import 'package:flutter/foundation.dart';

import 'semi_divider_theme_data.dart';
import 'semi_typography_theme_data.dart';

@immutable
class SemiComponentThemes {
  const SemiComponentThemes({
    this.typography = const SemiTypographyThemeData(),
    this.divider = const SemiDividerThemeData(),
  });
  final SemiTypographyThemeData typography;
  final SemiDividerThemeData divider;
  SemiComponentThemes copyWith({
    SemiTypographyThemeData? typography,
    SemiDividerThemeData? divider,
  }) => SemiComponentThemes(
    typography: typography ?? this.typography,
    divider: divider ?? this.divider,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SemiComponentThemes &&
          typography == other.typography &&
          divider == other.divider;
  @override
  int get hashCode => Object.hash(typography, divider);
}
