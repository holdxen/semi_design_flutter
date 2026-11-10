import 'package:flutter/widgets.dart';

import 'semi_theme_data.dart';

@immutable
class SemiSpinThemeData {
  const SemiSpinThemeData({
    this.color,
    this.smallSize,
    this.middleSize,
    this.largeSize,
    this.childrenOpacity,
    this.rotationDuration,
    this.customIndicatorRotationDuration,
  }) : assert(
         smallSize == null || (smallSize >= 0 && smallSize <= double.maxFinite),
       ),
       assert(
         middleSize == null ||
             (middleSize >= 0 && middleSize <= double.maxFinite),
       ),
       assert(
         largeSize == null || (largeSize >= 0 && largeSize <= double.maxFinite),
       ),
       assert(
         childrenOpacity == null ||
             (childrenOpacity >= 0 && childrenOpacity <= 1),
       );

  /// `$color-spin-bg: var(--semi-color-primary)` in packages/semi-foundation/spin/variables.scss.
  final Color? color;

  /// `$width-spin_small: 14px` in packages/semi-foundation/spin/variables.scss.
  final double? smallSize;

  /// `$width-spin_middle: 20px` in packages/semi-foundation/spin/variables.scss.
  final double? middleSize;

  /// `$width-spin_large: 32px` in packages/semi-foundation/spin/variables.scss.
  final double? largeSize;

  /// `$opacity-spin_children: 0.5` in packages/semi-foundation/spin/variables.scss.
  final double? childrenOpacity;

  /// `$animation_duration-spin_wrapper-spin: 600ms` in packages/semi-foundation/spin/animation.scss.
  final Duration? rotationDuration;

  /// `$animation_duration-spin_customChildren-spin: 1600ms` in packages/semi-foundation/spin/animation.scss.
  final Duration? customIndicatorRotationDuration;
  SemiSpinThemeData copyWith({
    Color? color,
    double? smallSize,
    double? middleSize,
    double? largeSize,
    double? childrenOpacity,
    Duration? rotationDuration,
    Duration? customIndicatorRotationDuration,
  }) => SemiSpinThemeData(
    color: color ?? this.color,
    smallSize: smallSize ?? this.smallSize,
    middleSize: middleSize ?? this.middleSize,
    largeSize: largeSize ?? this.largeSize,
    childrenOpacity: childrenOpacity ?? this.childrenOpacity,
    rotationDuration: rotationDuration ?? this.rotationDuration,
    customIndicatorRotationDuration:
        customIndicatorRotationDuration ?? this.customIndicatorRotationDuration,
  );
  SemiSpinThemeData merge(SemiSpinThemeData? other) => other == null
      ? this
      : copyWith(
          color: other.color,
          smallSize: other.smallSize,
          middleSize: other.middleSize,
          largeSize: other.largeSize,
          childrenOpacity: other.childrenOpacity,
          rotationDuration: other.rotationDuration,
          customIndicatorRotationDuration:
              other.customIndicatorRotationDuration,
        );
  SemiResolvedSpinThemeData resolve(SemiThemeData theme) {
    for (final entry in {
      'smallSize': smallSize,
      'middleSize': middleSize,
      'largeSize': largeSize,
      'childrenOpacity': childrenOpacity,
    }.entries) {
      final value = entry.value;
      if (value != null &&
          (!value.isFinite ||
              value < 0 ||
              (entry.key == 'childrenOpacity' && value > 1))) {
        throw ArgumentError.value(value, entry.key, 'invalid Spin theme value');
      }
    }
    for (final entry in {
      'rotationDuration': rotationDuration,
      'customIndicatorRotationDuration': customIndicatorRotationDuration,
    }.entries) {
      if (entry.value?.isNegative ?? false) {
        throw ArgumentError.value(
          entry.value,
          entry.key,
          'must be nonnegative',
        );
      }
    }
    return SemiResolvedSpinThemeData(
      color: color ?? theme.colors.colorPrimary,
      smallSize: smallSize ?? 14,
      middleSize: middleSize ?? 20,
      largeSize: largeSize ?? 32,
      childrenOpacity: childrenOpacity ?? 0.5,
      rotationDuration: rotationDuration ?? const Duration(milliseconds: 600),
      customIndicatorRotationDuration:
          customIndicatorRotationDuration ?? const Duration(milliseconds: 1600),
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SemiSpinThemeData &&
          color == other.color &&
          smallSize == other.smallSize &&
          middleSize == other.middleSize &&
          largeSize == other.largeSize &&
          childrenOpacity == other.childrenOpacity &&
          rotationDuration == other.rotationDuration &&
          customIndicatorRotationDuration ==
              other.customIndicatorRotationDuration;
  @override
  int get hashCode => Object.hashAll([
    color,
    smallSize,
    middleSize,
    largeSize,
    childrenOpacity,
    rotationDuration,
    customIndicatorRotationDuration,
  ]);
}

@immutable
class SemiResolvedSpinThemeData {
  const SemiResolvedSpinThemeData({
    required this.color,
    required this.smallSize,
    required this.middleSize,
    required this.largeSize,
    required this.childrenOpacity,
    required this.rotationDuration,
    required this.customIndicatorRotationDuration,
  });
  final Color color;
  final double smallSize;
  final double middleSize;
  final double largeSize;
  final double childrenOpacity;
  final Duration rotationDuration;
  final Duration customIndicatorRotationDuration;
}
