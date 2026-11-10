import 'package:flutter/foundation.dart';

import 'semi_tag_theme_data.dart';
import 'semi_divider_theme_data.dart';
import 'semi_progress_theme_data.dart';
import 'semi_spin_theme_data.dart';
import 'semi_typography_theme_data.dart';

@immutable
class SemiComponentThemes {
  const SemiComponentThemes({
    this.tag = const SemiTagThemeData(),
    this.typography = const SemiTypographyThemeData(),
    this.divider = const SemiDividerThemeData(),
    this.progress = const SemiProgressThemeData(),
    this.spin = const SemiSpinThemeData(),
  });
  final SemiTagThemeData tag;
  final SemiTypographyThemeData typography;
  final SemiDividerThemeData divider;
  final SemiProgressThemeData progress;
  final SemiSpinThemeData spin;
  SemiComponentThemes copyWith({
    SemiTagThemeData? tag,
    SemiTypographyThemeData? typography,
    SemiDividerThemeData? divider,
    SemiProgressThemeData? progress,
    SemiSpinThemeData? spin,
  }) => SemiComponentThemes(
    tag: tag ?? this.tag,
    typography: typography ?? this.typography,
    divider: divider ?? this.divider,
    progress: progress ?? this.progress,
    spin: spin ?? this.spin,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SemiComponentThemes &&
          tag == other.tag &&
          typography == other.typography &&
          divider == other.divider &&
          progress == other.progress &&
          spin == other.spin;
  @override
  int get hashCode => Object.hash(tag, typography, divider, spin, progress);
}
