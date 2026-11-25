import 'package:flutter/widgets.dart';

import 'semi_theme_data.dart';

/// Scrollbar styling ported from the official `.semi-light-scrollbar` class.
///
/// Upstream has no standalone Scrollbar component; these values mirror the
/// WebKit rules in `semi.min.css` and the FAQ recommendation to apply
/// `.semi-light-scrollbar` to the outermost element.
@immutable
class SemiScrollBarThemeData {
  const SemiScrollBarThemeData({
    this.thickness,
    this.radius,
    this.thumbColor,
    this.thumbHoverColor,
    this.minThumbLength,
    this.crossAxisMargin,
    this.mainAxisMargin,
    this.fadeDuration,
    this.timeToFade,
  });

  /// `.semi-light-scrollbar::-webkit-scrollbar { width: 8px; height: 8px }`.
  final double? thickness;

  /// `.semi-light-scrollbar::-webkit-scrollbar-thumb { border-radius: 6px }`.
  final Radius? radius;

  /// Thumb color while the container is hovered:
  /// `background: var(--semi-color-fill-2)`.
  final Color? thumbColor;

  /// Thumb color while the thumb itself is hovered:
  /// `background: var(--semi-color-fill-1)`.
  final Color? thumbHoverColor;

  /// Smallest thumb length. Upstream CSS leaves this to the user agent.
  final double? minThumbLength;

  /// Distance from the scrollbar to the nearest edge.
  final double? crossAxisMargin;

  /// Distance from the scrollbar's start/end to the viewport edge.
  final double? mainAxisMargin;

  /// `.semi-light-scrollbar::-webkit-scrollbar-thumb { transition: all 1s }`.
  final Duration? fadeDuration;

  /// Delay before fading out after the pointer leaves. Upstream hides the thumb
  /// immediately (through the 1s transition), so the default is zero.
  final Duration? timeToFade;

  SemiScrollBarThemeData copyWith({
    double? thickness,
    Radius? radius,
    Color? thumbColor,
    Color? thumbHoverColor,
    double? minThumbLength,
    double? crossAxisMargin,
    double? mainAxisMargin,
    Duration? fadeDuration,
    Duration? timeToFade,
  }) => SemiScrollBarThemeData(
    thickness: thickness ?? this.thickness,
    radius: radius ?? this.radius,
    thumbColor: thumbColor ?? this.thumbColor,
    thumbHoverColor: thumbHoverColor ?? this.thumbHoverColor,
    minThumbLength: minThumbLength ?? this.minThumbLength,
    crossAxisMargin: crossAxisMargin ?? this.crossAxisMargin,
    mainAxisMargin: mainAxisMargin ?? this.mainAxisMargin,
    fadeDuration: fadeDuration ?? this.fadeDuration,
    timeToFade: timeToFade ?? this.timeToFade,
  );

  SemiScrollBarThemeData merge(SemiScrollBarThemeData? other) => other == null
      ? this
      : copyWith(
          thickness: other.thickness,
          radius: other.radius,
          thumbColor: other.thumbColor,
          thumbHoverColor: other.thumbHoverColor,
          minThumbLength: other.minThumbLength,
          crossAxisMargin: other.crossAxisMargin,
          mainAxisMargin: other.mainAxisMargin,
          fadeDuration: other.fadeDuration,
          timeToFade: other.timeToFade,
        );

  SemiResolvedScrollBarThemeData resolve(SemiThemeData theme) =>
      SemiResolvedScrollBarThemeData(
        thickness: thickness ?? 8,
        radius: radius ?? const Radius.circular(6),
        thumbColor: thumbColor ?? theme.colors.colorFill2,
        thumbHoverColor: thumbHoverColor ?? theme.colors.colorFill1,
        minThumbLength: minThumbLength ?? 18,
        crossAxisMargin: crossAxisMargin ?? 0,
        mainAxisMargin: mainAxisMargin ?? 0,
        fadeDuration: fadeDuration ?? const Duration(seconds: 1),
        timeToFade: timeToFade ?? Duration.zero,
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SemiScrollBarThemeData &&
          thickness == other.thickness &&
          radius == other.radius &&
          thumbColor == other.thumbColor &&
          thumbHoverColor == other.thumbHoverColor &&
          minThumbLength == other.minThumbLength &&
          crossAxisMargin == other.crossAxisMargin &&
          mainAxisMargin == other.mainAxisMargin &&
          fadeDuration == other.fadeDuration &&
          timeToFade == other.timeToFade;

  @override
  int get hashCode => Object.hash(
    thickness,
    radius,
    thumbColor,
    thumbHoverColor,
    minThumbLength,
    crossAxisMargin,
    mainAxisMargin,
    fadeDuration,
    timeToFade,
  );
}

@immutable
class SemiResolvedScrollBarThemeData {
  const SemiResolvedScrollBarThemeData({
    required this.thickness,
    required this.radius,
    required this.thumbColor,
    required this.thumbHoverColor,
    required this.minThumbLength,
    required this.crossAxisMargin,
    required this.mainAxisMargin,
    required this.fadeDuration,
    required this.timeToFade,
  });

  final double thickness;
  final Radius radius;
  final Color thumbColor;
  final Color thumbHoverColor;
  final double minThumbLength;
  final double crossAxisMargin;
  final double mainAxisMargin;
  final Duration fadeDuration;
  final Duration timeToFade;
}
