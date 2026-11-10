import 'package:flutter/foundation.dart';

import 'semi_divider_theme_data.dart';
import 'semi_spin_theme_data.dart';
import 'semi_typography_theme_data.dart';

@immutable
class SemiComponentThemes {
  const SemiComponentThemes({
    this.typography = const SemiTypographyThemeData(),
    this.divider = const SemiDividerThemeData(),
    this.spin = const SemiSpinThemeData(),
  });
  final SemiTypographyThemeData typography;
  final SemiDividerThemeData divider;
  final SemiSpinThemeData spin;
  SemiComponentThemes copyWith({
    SemiTypographyThemeData? typography,
    SemiDividerThemeData? divider,
    SemiSpinThemeData? spin,
  }) => SemiComponentThemes(
    typography: typography ?? this.typography,
    divider: divider ?? this.divider,
    spin: spin ?? this.spin,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SemiComponentThemes &&
          typography == other.typography &&
          divider == other.divider &&
          spin == other.spin;
  @override
  int get hashCode => Object.hash(typography, divider, spin);
}
