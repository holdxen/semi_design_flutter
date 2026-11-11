import 'package:flutter/foundation.dart';

import 'semi_tag_theme_data.dart';
import 'semi_divider_theme_data.dart';
import 'semi_progress_theme_data.dart';
import 'semi_spin_theme_data.dart';
import 'semi_highlight_theme_data.dart';
import 'semi_empty_theme_data.dart';
import 'semi_timeline_theme_data.dart';
import 'semi_descriptions_theme_data.dart';
import 'semi_tooltip_theme_data.dart';
import 'semi_typography_theme_data.dart';

@immutable
class SemiComponentThemes {
  const SemiComponentThemes({
    this.tag = const SemiTagThemeData(),
    this.typography = const SemiTypographyThemeData(),
    this.divider = const SemiDividerThemeData(),
    this.progress = const SemiProgressThemeData(),
    this.spin = const SemiSpinThemeData(),
    this.highlight = const SemiHighlightThemeData(),
    this.empty = const SemiEmptyThemeData(),
    this.timeline = const SemiTimelineThemeData(),
    this.descriptions = const SemiDescriptionsThemeData(),
    this.tooltip = const SemiTooltipThemeData(),
  });
  final SemiTagThemeData tag;
  final SemiTypographyThemeData typography;
  final SemiDividerThemeData divider;
  final SemiProgressThemeData progress;
  final SemiSpinThemeData spin;
  final SemiHighlightThemeData highlight;
  final SemiEmptyThemeData empty;
  final SemiTimelineThemeData timeline;
  final SemiDescriptionsThemeData descriptions;
  final SemiTooltipThemeData tooltip;
  SemiComponentThemes copyWith({
    SemiTagThemeData? tag,
    SemiTypographyThemeData? typography,
    SemiDividerThemeData? divider,
    SemiProgressThemeData? progress,
    SemiSpinThemeData? spin,
    SemiHighlightThemeData? highlight,
    SemiEmptyThemeData? empty,
    SemiTimelineThemeData? timeline,
    SemiDescriptionsThemeData? descriptions,
    SemiTooltipThemeData? tooltip,
  }) => SemiComponentThemes(
    tag: tag ?? this.tag,
    typography: typography ?? this.typography,
    divider: divider ?? this.divider,
    progress: progress ?? this.progress,
    spin: spin ?? this.spin,
    highlight: highlight ?? this.highlight,
    empty: empty ?? this.empty,
    timeline: timeline ?? this.timeline,
    descriptions: descriptions ?? this.descriptions,
    tooltip: tooltip ?? this.tooltip,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SemiComponentThemes &&
          tag == other.tag &&
          typography == other.typography &&
          divider == other.divider &&
          progress == other.progress &&
          spin == other.spin &&
          highlight == other.highlight &&
          empty == other.empty &&
          timeline == other.timeline &&
          descriptions == other.descriptions &&
          tooltip == other.tooltip;
  @override
  int get hashCode => Object.hash(
    tag,
    typography,
    divider,
    spin,
    progress,
    highlight,
    empty,
    timeline,
    descriptions,
    tooltip,
  );
}
