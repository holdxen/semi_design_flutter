import 'package:flutter/foundation.dart';

import 'semi_typography_theme_data.dart';

@immutable
class SemiComponentThemes {
  const SemiComponentThemes({
    this.typography = const SemiTypographyThemeData(),
  });
  final SemiTypographyThemeData typography;
  SemiComponentThemes copyWith({SemiTypographyThemeData? typography}) =>
      SemiComponentThemes(typography: typography ?? this.typography);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SemiComponentThemes && typography == other.typography;
  @override
  int get hashCode => typography.hashCode;
}
