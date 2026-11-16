// Matrix coverage for the 99 generated theme fields: defaults, overrides,
// merge, copyWith, resolve, equality and per-field Sass provenance.
// 对账 99 = 89 FIELDS + 10 MOTION + 0 INTERNAL；★1 死变量
// widthAvatarBottomSlotSquareExtraSmallBorder（上游未消费，见
// tool/test_generate_avatar.py 与 docs/semi_avatar.md）。
import 'dart:io';

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:semi_design_flutter/semi_design_flutter.dart';

typedef _Patch = SemiAvatarThemeData Function(Object value);
typedef _Read = Object? Function(SemiResolvedAvatarThemeData data);

final List<(String, Object, _Patch, _Read)> fields = [
  (
    r'$z-avatar-default: 100',
    37.0,
    (Object v) => SemiAvatarThemeData(zAvatarDefault: v as double),
    (SemiResolvedAvatarThemeData d) => d.zAvatarDefault,
  ),
  (
    r'$color-avatar_default-border-default: var(--semi-color-bg-1)',
    const Color(0xff123456),
    (Object v) => SemiAvatarThemeData(colorAvatarDefaultBorderDefault: v as Color),
    (SemiResolvedAvatarThemeData d) => d.colorAvatarDefaultBorderDefault,
  ),
  (
    r'$color-avatar_more_default-bg-default: rgba(var(--semi-grey-5), 1)',
    const Color(0xff123456),
    (Object v) => SemiAvatarThemeData(colorAvatarMoreDefaultBgDefault: v as Color),
    (SemiResolvedAvatarThemeData d) => d.colorAvatarMoreDefaultBgDefault,
  ),
  (
    r'$color-avatar-outline-focus: var(--semi-color-primary-light-active)',
    const Color(0xff123456),
    (Object v) => SemiAvatarThemeData(colorAvatarOutlineFocus: v as Color),
    (SemiResolvedAvatarThemeData d) => d.colorAvatarOutlineFocus,
  ),
  (
    r'$width-avatar_extra_extra_small: 20px',
    37.0,
    (Object v) => SemiAvatarThemeData(widthAvatarExtraExtraSmall: v as double),
    (SemiResolvedAvatarThemeData d) => d.widthAvatarExtraExtraSmall,
  ),
  (
    r'$font-avatar_extra_extra_small-size: 10px',
    37.0,
    (Object v) => SemiAvatarThemeData(fontAvatarExtraExtraSmallSize: v as double),
    (SemiResolvedAvatarThemeData d) => d.fontAvatarExtraExtraSmallSize,
  ),
  (
    r'$font-avatar_extra_extra_small-lineHeight: 15px',
    37.0,
    (Object v) => SemiAvatarThemeData(fontAvatarExtraExtraSmallLineHeight: v as double),
    (SemiResolvedAvatarThemeData d) => d.fontAvatarExtraExtraSmallLineHeight,
  ),
  (
    r'$width-avatar_extra_small: 24px',
    37.0,
    (Object v) => SemiAvatarThemeData(widthAvatarExtraSmall: v as double),
    (SemiResolvedAvatarThemeData d) => d.widthAvatarExtraSmall,
  ),
  (
    r'$font-avatar_extra_small-size: 10px',
    37.0,
    (Object v) => SemiAvatarThemeData(fontAvatarExtraSmallSize: v as double),
    (SemiResolvedAvatarThemeData d) => d.fontAvatarExtraSmallSize,
  ),
  (
    r'$font-avatar_extra_small-lineHeight: 15px',
    37.0,
    (Object v) => SemiAvatarThemeData(fontAvatarExtraSmallLineHeight: v as double),
    (SemiResolvedAvatarThemeData d) => d.fontAvatarExtraSmallLineHeight,
  ),
  (
    r'$width-avatar_small: 32px',
    37.0,
    (Object v) => SemiAvatarThemeData(widthAvatarSmall: v as double),
    (SemiResolvedAvatarThemeData d) => d.widthAvatarSmall,
  ),
  (
    r'$width-avatar_default: 40px',
    37.0,
    (Object v) => SemiAvatarThemeData(widthAvatarDefault: v as double),
    (SemiResolvedAvatarThemeData d) => d.widthAvatarDefault,
  ),
  (
    r'$width-avatar_medium: 48px',
    37.0,
    (Object v) => SemiAvatarThemeData(widthAvatarMedium: v as double),
    (SemiResolvedAvatarThemeData d) => d.widthAvatarMedium,
  ),
  (
    r'$width-avatar_large: 72px',
    37.0,
    (Object v) => SemiAvatarThemeData(widthAvatarLarge: v as double),
    (SemiResolvedAvatarThemeData d) => d.widthAvatarLarge,
  ),
  (
    r'$width-avatar_extra_large: 128px',
    37.0,
    (Object v) => SemiAvatarThemeData(widthAvatarExtraLarge: v as double),
    (SemiResolvedAvatarThemeData d) => d.widthAvatarExtraLarge,
  ),
  (
    r'$font-avatar_extra_large-size: 64px',
    37.0,
    (Object v) => SemiAvatarThemeData(fontAvatarExtraLargeSize: v as double),
    (SemiResolvedAvatarThemeData d) => d.fontAvatarExtraLargeSize,
  ),
  (
    r'$font-avatar_extra_large-lineHeight: 77px',
    37.0,
    (Object v) => SemiAvatarThemeData(fontAvatarExtraLargeLineHeight: v as double),
    (SemiResolvedAvatarThemeData d) => d.fontAvatarExtraLargeLineHeight,
  ),
  (
    r'$radius-avatar: var(--semi-border-radius-circle)',
    const SemiLength.pixels(37),
    (Object v) => SemiAvatarThemeData(radiusAvatar: v as SemiLength),
    (SemiResolvedAvatarThemeData d) => d.radiusAvatar,
  ),
  (
    r'$width-avatar_extra_large-border: 3px',
    37.0,
    (Object v) => SemiAvatarThemeData(widthAvatarExtraLargeBorder: v as double),
    (SemiResolvedAvatarThemeData d) => d.widthAvatarExtraLargeBorder,
  ),
  (
    r'$spacing-avatar_extra_large-marginLeft: -32px',
    37.0,
    (Object v) => SemiAvatarThemeData(spacingAvatarExtraLargeMarginLeft: v as double),
    (SemiResolvedAvatarThemeData d) => d.spacingAvatarExtraLargeMarginLeft,
  ),
  (
    r'$width-avatar_large-border: 3px',
    37.0,
    (Object v) => SemiAvatarThemeData(widthAvatarLargeBorder: v as double),
    (SemiResolvedAvatarThemeData d) => d.widthAvatarLargeBorder,
  ),
  (
    r'$spacing-avatar_large-marginLeft: -18px',
    37.0,
    (Object v) => SemiAvatarThemeData(spacingAvatarLargeMarginLeft: v as double),
    (SemiResolvedAvatarThemeData d) => d.spacingAvatarLargeMarginLeft,
  ),
  (
    r'$width-avatar_medium-border: 2px',
    37.0,
    (Object v) => SemiAvatarThemeData(widthAvatarMediumBorder: v as double),
    (SemiResolvedAvatarThemeData d) => d.widthAvatarMediumBorder,
  ),
  (
    r'$spacing-avatar_medium-marginLeft: -12px',
    37.0,
    (Object v) => SemiAvatarThemeData(spacingAvatarMediumMarginLeft: v as double),
    (SemiResolvedAvatarThemeData d) => d.spacingAvatarMediumMarginLeft,
  ),
  (
    r'$width-avatar_default-border: 2px',
    37.0,
    (Object v) => SemiAvatarThemeData(widthAvatarDefaultBorder: v as double),
    (SemiResolvedAvatarThemeData d) => d.widthAvatarDefaultBorder,
  ),
  (
    r'$spacing-avatar_default-marginLeft: -12px',
    37.0,
    (Object v) => SemiAvatarThemeData(spacingAvatarDefaultMarginLeft: v as double),
    (SemiResolvedAvatarThemeData d) => d.spacingAvatarDefaultMarginLeft,
  ),
  (
    r'$width-avatar_small-border: 2px',
    37.0,
    (Object v) => SemiAvatarThemeData(widthAvatarSmallBorder: v as double),
    (SemiResolvedAvatarThemeData d) => d.widthAvatarSmallBorder,
  ),
  (
    r'$spacing-avatar_small-marginLeft: -12px',
    37.0,
    (Object v) => SemiAvatarThemeData(spacingAvatarSmallMarginLeft: v as double),
    (SemiResolvedAvatarThemeData d) => d.spacingAvatarSmallMarginLeft,
  ),
  (
    r'$width-avatar_extra_small-border: 1px',
    37.0,
    (Object v) => SemiAvatarThemeData(widthAvatarExtraSmallBorder: v as double),
    (SemiResolvedAvatarThemeData d) => d.widthAvatarExtraSmallBorder,
  ),
  (
    r'$spacing-avatar_extra_small-marginLeft: -10px',
    37.0,
    (Object v) => SemiAvatarThemeData(spacingAvatarExtraSmallMarginLeft: v as double),
    (SemiResolvedAvatarThemeData d) => d.spacingAvatarExtraSmallMarginLeft,
  ),
  (
    r'$width-avatar_extra_extra_small-border: 1px',
    37.0,
    (Object v) => SemiAvatarThemeData(widthAvatarExtraExtraSmallBorder: v as double),
    (SemiResolvedAvatarThemeData d) => d.widthAvatarExtraExtraSmallBorder,
  ),
  (
    r'$spacing-avatar_extra_extra_small-marginLeft: -4px',
    37.0,
    (Object v) => SemiAvatarThemeData(spacingAvatarExtraExtraSmallMarginLeft: v as double),
    (SemiResolvedAvatarThemeData d) => d.spacingAvatarExtraExtraSmallMarginLeft,
  ),
  (
    r'$width-avatar-outline: 2px',
    37.0,
    (Object v) => SemiAvatarThemeData(widthAvatarOutline: v as double),
    (SemiResolvedAvatarThemeData d) => d.widthAvatarOutline,
  ),
  (
    r'$width-avatar_additional-border: 1.5px',
    37.0,
    (Object v) => SemiAvatarThemeData(widthAvatarAdditionalBorder: v as double),
    (SemiResolvedAvatarThemeData d) => d.widthAvatarAdditionalBorder,
  ),
  (
    r'$color-avatar_additional-border: var(--semi-color-primary)',
    const Color(0xff123456),
    (Object v) => SemiAvatarThemeData(colorAvatarAdditionalBorder: v as Color),
    (SemiResolvedAvatarThemeData d) => d.colorAvatarAdditionalBorder,
  ),
  (
    r'$spacing-avatar_additional-borderGap: 2px',
    37.0,
    (Object v) => SemiAvatarThemeData(spacingAvatarAdditionalBorderGap: v as double),
    (SemiResolvedAvatarThemeData d) => d.spacingAvatarAdditionalBorderGap,
  ),
  (
    r'$width-avatar-bottom_slot_circle_extra_small: 12px',
    37.0,
    (Object v) => SemiAvatarThemeData(widthAvatarBottomSlotCircleExtraSmall: v as double),
    (SemiResolvedAvatarThemeData d) => d.widthAvatarBottomSlotCircleExtraSmall,
  ),
  (
    r'$width-avatar-bottom_slot_circle_small: 12px',
    37.0,
    (Object v) => SemiAvatarThemeData(widthAvatarBottomSlotCircleSmall: v as double),
    (SemiResolvedAvatarThemeData d) => d.widthAvatarBottomSlotCircleSmall,
  ),
  (
    r'$width-avatar-bottom_slot_circle_default: 16px',
    37.0,
    (Object v) => SemiAvatarThemeData(widthAvatarBottomSlotCircleDefault: v as double),
    (SemiResolvedAvatarThemeData d) => d.widthAvatarBottomSlotCircleDefault,
  ),
  (
    r'$width-avatar-bottom_slot_circle_medium: 18px',
    37.0,
    (Object v) => SemiAvatarThemeData(widthAvatarBottomSlotCircleMedium: v as double),
    (SemiResolvedAvatarThemeData d) => d.widthAvatarBottomSlotCircleMedium,
  ),
  (
    r'$width-avatar-bottom_slot_circle_large: 28px',
    37.0,
    (Object v) => SemiAvatarThemeData(widthAvatarBottomSlotCircleLarge: v as double),
    (SemiResolvedAvatarThemeData d) => d.widthAvatarBottomSlotCircleLarge,
  ),
  (
    r'$width-avatar-bottom_slot_circle_extra_large: 28px',
    37.0,
    (Object v) => SemiAvatarThemeData(widthAvatarBottomSlotCircleExtraLarge: v as double),
    (SemiResolvedAvatarThemeData d) => d.widthAvatarBottomSlotCircleExtraLarge,
  ),
  (
    r'$color-avatar-bottom_slot_bg: var(--semi-color-primary)',
    const Color(0xff123456),
    (Object v) => SemiAvatarThemeData(colorAvatarBottomSlotBg: v as Color),
    (SemiResolvedAvatarThemeData d) => d.colorAvatarBottomSlotBg,
  ),
  (
    r'$radius-avatar-bottom_slot_square: 4px',
    37.0,
    (Object v) => SemiAvatarThemeData(radiusAvatarBottomSlotSquare: v as double),
    (SemiResolvedAvatarThemeData d) => d.radiusAvatarBottomSlotSquare,
  ),
  (
    r'$font-avatar_bottom_slot-extra_small-fontSize: 5px',
    37.0,
    (Object v) => SemiAvatarThemeData(fontAvatarBottomSlotExtraSmallFontSize: v as double),
    (SemiResolvedAvatarThemeData d) => d.fontAvatarBottomSlotExtraSmallFontSize,
  ),
  (
    r'$font-avatar_bottom_slot-small-fontSize: 5px',
    37.0,
    (Object v) => SemiAvatarThemeData(fontAvatarBottomSlotSmallFontSize: v as double),
    (SemiResolvedAvatarThemeData d) => d.fontAvatarBottomSlotSmallFontSize,
  ),
  (
    r'$font-avatar_bottom_slot-default-fontSize: 12px',
    37.0,
    (Object v) => SemiAvatarThemeData(fontAvatarBottomSlotDefaultFontSize: v as double),
    (SemiResolvedAvatarThemeData d) => d.fontAvatarBottomSlotDefaultFontSize,
  ),
  (
    r'$font-avatar_bottom_slot-medium-fontSize: 12px',
    37.0,
    (Object v) => SemiAvatarThemeData(fontAvatarBottomSlotMediumFontSize: v as double),
    (SemiResolvedAvatarThemeData d) => d.fontAvatarBottomSlotMediumFontSize,
  ),
  (
    r'$font-avatar_bottom_slot-large-fontSize: 12px',
    37.0,
    (Object v) => SemiAvatarThemeData(fontAvatarBottomSlotLargeFontSize: v as double),
    (SemiResolvedAvatarThemeData d) => d.fontAvatarBottomSlotLargeFontSize,
  ),
  (
    r'$font-avatar_bottom_slot-extra_large-fontSize: 14px',
    37.0,
    (Object v) => SemiAvatarThemeData(fontAvatarBottomSlotExtraLargeFontSize: v as double),
    (SemiResolvedAvatarThemeData d) => d.fontAvatarBottomSlotExtraLargeFontSize,
  ),
  (
    r'$spacing-avatar-bottom_slot_square-paddingX: 4px',
    37.0,
    (Object v) => SemiAvatarThemeData(spacingAvatarBottomSlotSquarePaddingX: v as double),
    (SemiResolvedAvatarThemeData d) => d.spacingAvatarBottomSlotSquarePaddingX,
  ),
  (
    r'$spacing-avatar-bottom_slot_square-paddingY: 1px',
    37.0,
    (Object v) => SemiAvatarThemeData(spacingAvatarBottomSlotSquarePaddingY: v as double),
    (SemiResolvedAvatarThemeData d) => d.spacingAvatarBottomSlotSquarePaddingY,
  ),
  (
    r'$font-avatar_top_slot-small-fontSize: 5px',
    37.0,
    (Object v) => SemiAvatarThemeData(fontAvatarTopSlotSmallFontSize: v as double),
    (SemiResolvedAvatarThemeData d) => d.fontAvatarTopSlotSmallFontSize,
  ),
  (
    r'$font-avatar_top_slot-default-fontSize: 6px',
    37.0,
    (Object v) => SemiAvatarThemeData(fontAvatarTopSlotDefaultFontSize: v as double),
    (SemiResolvedAvatarThemeData d) => d.fontAvatarTopSlotDefaultFontSize,
  ),
  (
    r'$font-avatar_top_slot-medium-fontSize: 8px',
    37.0,
    (Object v) => SemiAvatarThemeData(fontAvatarTopSlotMediumFontSize: v as double),
    (SemiResolvedAvatarThemeData d) => d.fontAvatarTopSlotMediumFontSize,
  ),
  (
    r'$font-avatar_top_slot-large-fontSize: 14px',
    37.0,
    (Object v) => SemiAvatarThemeData(fontAvatarTopSlotLargeFontSize: v as double),
    (SemiResolvedAvatarThemeData d) => d.fontAvatarTopSlotLargeFontSize,
  ),
  (
    r'$font-avatar_top_slot-extra_large-fontSize: 16px',
    37.0,
    (Object v) => SemiAvatarThemeData(fontAvatarTopSlotExtraLargeFontSize: v as double),
    (SemiResolvedAvatarThemeData d) => d.fontAvatarTopSlotExtraLargeFontSize,
  ),
  (
    r'$spacing-avatar-top_slot_small-content-marginTop: 0px',
    37.0,
    (Object v) => SemiAvatarThemeData(spacingAvatarTopSlotSmallContentMarginTop: v as double),
    (SemiResolvedAvatarThemeData d) => d.spacingAvatarTopSlotSmallContentMarginTop,
  ),
  (
    r'$spacing-avatar-top_slot_default-content-marginTop: -2px',
    37.0,
    (Object v) => SemiAvatarThemeData(spacingAvatarTopSlotDefaultContentMarginTop: v as double),
    (SemiResolvedAvatarThemeData d) => d.spacingAvatarTopSlotDefaultContentMarginTop,
  ),
  (
    r'$spacing-avatar-top_slot_medium-content-marginTop: 0px',
    37.0,
    (Object v) => SemiAvatarThemeData(spacingAvatarTopSlotMediumContentMarginTop: v as double),
    (SemiResolvedAvatarThemeData d) => d.spacingAvatarTopSlotMediumContentMarginTop,
  ),
  (
    r'$spacing-avatar-top_slot_large-content-marginTop: 0px',
    37.0,
    (Object v) => SemiAvatarThemeData(spacingAvatarTopSlotLargeContentMarginTop: v as double),
    (SemiResolvedAvatarThemeData d) => d.spacingAvatarTopSlotLargeContentMarginTop,
  ),
  (
    r'$spacing-avatar-top_slot_extra_large-content-marginTop: 0px',
    37.0,
    (Object v) => SemiAvatarThemeData(spacingAvatarTopSlotExtraLargeContentMarginTop: v as double),
    (SemiResolvedAvatarThemeData d) => d.spacingAvatarTopSlotExtraLargeContentMarginTop,
  ),
  (
    r'$color-avatar-bottom_slot_square-border: var(--semi-color-bg-0)',
    const Color(0xff123456),
    (Object v) => SemiAvatarThemeData(colorAvatarBottomSlotSquareBorder: v as Color),
    (SemiResolvedAvatarThemeData d) => d.colorAvatarBottomSlotSquareBorder,
  ),
  (
    r'$width-avatar-bottom_slot_square_extra_small-border: 2px',
    37.0,
    (Object v) => SemiAvatarThemeData(widthAvatarBottomSlotSquareExtraSmallBorder: v as double),
    (SemiResolvedAvatarThemeData d) => d.widthAvatarBottomSlotSquareExtraSmallBorder,
  ),
  (
    r'$width-avatar-bottom_slot_square_small-border: 2px',
    37.0,
    (Object v) => SemiAvatarThemeData(widthAvatarBottomSlotSquareSmallBorder: v as double),
    (SemiResolvedAvatarThemeData d) => d.widthAvatarBottomSlotSquareSmallBorder,
  ),
  (
    r'$width-avatar-bottom_slot_square_default-border: 2px',
    37.0,
    (Object v) => SemiAvatarThemeData(widthAvatarBottomSlotSquareDefaultBorder: v as double),
    (SemiResolvedAvatarThemeData d) => d.widthAvatarBottomSlotSquareDefaultBorder,
  ),
  (
    r'$width-avatar-bottom_slot_square_medium-border: 2px',
    37.0,
    (Object v) => SemiAvatarThemeData(widthAvatarBottomSlotSquareMediumBorder: v as double),
    (SemiResolvedAvatarThemeData d) => d.widthAvatarBottomSlotSquareMediumBorder,
  ),
  (
    r'$width-avatar-bottom_slot_square_large-border: 2px',
    37.0,
    (Object v) => SemiAvatarThemeData(widthAvatarBottomSlotSquareLargeBorder: v as double),
    (SemiResolvedAvatarThemeData d) => d.widthAvatarBottomSlotSquareLargeBorder,
  ),
  (
    r'$width-avatar-bottom_slot_square_extra_large-border: 2px',
    37.0,
    (Object v) => SemiAvatarThemeData(widthAvatarBottomSlotSquareExtraLargeBorder: v as double),
    (SemiResolvedAvatarThemeData d) => d.widthAvatarBottomSlotSquareExtraLargeBorder,
  ),
  (
    r'$color-avatar-top_slot_text: var(--semi-color-bg-0)',
    const Color(0xff123456),
    (Object v) => SemiAvatarThemeData(colorAvatarTopSlotText: v as Color),
    (SemiResolvedAvatarThemeData d) => d.colorAvatarTopSlotText,
  ),
  (
    r'$color-avatar-top_slot_gradient_start: var(--semi-color-primary)',
    const Color(0xff123456),
    (Object v) => SemiAvatarThemeData(colorAvatarTopSlotGradientStart: v as Color),
    (SemiResolvedAvatarThemeData d) => d.colorAvatarTopSlotGradientStart,
  ),
  (
    r'$color-avatar-top_slot_gradient_end: var(--semi-color-primary)',
    const Color(0xff123456),
    (Object v) => SemiAvatarThemeData(colorAvatarTopSlotGradientEnd: v as Color),
    (SemiResolvedAvatarThemeData d) => d.colorAvatarTopSlotGradientEnd,
  ),
  (
    r'$spacing-avatar-top_slot_small-shift: -28px',
    37.0,
    (Object v) => SemiAvatarThemeData(spacingAvatarTopSlotSmallShift: v as double),
    (SemiResolvedAvatarThemeData d) => d.spacingAvatarTopSlotSmallShift,
  ),
  (
    r'$spacing-avatar-top_slot_default-shift: -32px',
    37.0,
    (Object v) => SemiAvatarThemeData(spacingAvatarTopSlotDefaultShift: v as double),
    (SemiResolvedAvatarThemeData d) => d.spacingAvatarTopSlotDefaultShift,
  ),
  (
    r'$spacing-avatar-top_slot_medium-shift: -30px',
    37.0,
    (Object v) => SemiAvatarThemeData(spacingAvatarTopSlotMediumShift: v as double),
    (SemiResolvedAvatarThemeData d) => d.spacingAvatarTopSlotMediumShift,
  ),
  (
    r'$spacing-avatar-top_slot_large-shift: -30px',
    37.0,
    (Object v) => SemiAvatarThemeData(spacingAvatarTopSlotLargeShift: v as double),
    (SemiResolvedAvatarThemeData d) => d.spacingAvatarTopSlotLargeShift,
  ),
  (
    r'$spacing-avatar-top_slot_extra_large-shift: -32px',
    37.0,
    (Object v) => SemiAvatarThemeData(spacingAvatarTopSlotExtraLargeShift: v as double),
    (SemiResolvedAvatarThemeData d) => d.spacingAvatarTopSlotExtraLargeShift,
  ),
  (
    r'$spacing-avatar-top_slot_small-scale: 0.4',
    37.0,
    (Object v) => SemiAvatarThemeData(spacingAvatarTopSlotSmallScale: v as double),
    (SemiResolvedAvatarThemeData d) => d.spacingAvatarTopSlotSmallScale,
  ),
  (
    r'$spacing-avatar-top_slot_default-scale: 0.7',
    37.0,
    (Object v) => SemiAvatarThemeData(spacingAvatarTopSlotDefaultScale: v as double),
    (SemiResolvedAvatarThemeData d) => d.spacingAvatarTopSlotDefaultScale,
  ),
  (
    r'$spacing-avatar-top_slot_medium-scale: 0.8',
    37.0,
    (Object v) => SemiAvatarThemeData(spacingAvatarTopSlotMediumScale: v as double),
    (SemiResolvedAvatarThemeData d) => d.spacingAvatarTopSlotMediumScale,
  ),
  (
    r'$spacing-avatar-top_slot_large-scale: 1.1',
    37.0,
    (Object v) => SemiAvatarThemeData(spacingAvatarTopSlotLargeScale: v as double),
    (SemiResolvedAvatarThemeData d) => d.spacingAvatarTopSlotLargeScale,
  ),
  (
    r'$spacing-avatar-top_slot_extra_large-scale: 1.4',
    37.0,
    (Object v) => SemiAvatarThemeData(spacingAvatarTopSlotExtraLargeScale: v as double),
    (SemiResolvedAvatarThemeData d) => d.spacingAvatarTopSlotExtraLargeScale,
  ),
  (
    r'$radius-avatar_extra_extra_small: 3px',
    37.0,
    (Object v) => SemiAvatarThemeData(radiusAvatarExtraExtraSmall: v as double),
    (SemiResolvedAvatarThemeData d) => d.radiusAvatarExtraExtraSmall,
  ),
  (
    r'$radius-avatar_extra_small: 3px',
    37.0,
    (Object v) => SemiAvatarThemeData(radiusAvatarExtraSmall: v as double),
    (SemiResolvedAvatarThemeData d) => d.radiusAvatarExtraSmall,
  ),
  (
    r'$radius-avatar_small: 3px',
    37.0,
    (Object v) => SemiAvatarThemeData(radiusAvatarSmall: v as double),
    (SemiResolvedAvatarThemeData d) => d.radiusAvatarSmall,
  ),
  (
    r'$radius-avatar_default: 3px',
    37.0,
    (Object v) => SemiAvatarThemeData(radiusAvatarDefault: v as double),
    (SemiResolvedAvatarThemeData d) => d.radiusAvatarDefault,
  ),
  (
    r'$radius-avatar_medium: 3px',
    37.0,
    (Object v) => SemiAvatarThemeData(radiusAvatarMedium: v as double),
    (SemiResolvedAvatarThemeData d) => d.radiusAvatarMedium,
  ),
  (
    r'$radius-avatar_large: 6px',
    37.0,
    (Object v) => SemiAvatarThemeData(radiusAvatarLarge: v as double),
    (SemiResolvedAvatarThemeData d) => d.radiusAvatarLarge,
  ),
  (
    r'$radius-avatar_extra_large: 12px',
    37.0,
    (Object v) => SemiAvatarThemeData(radiusAvatarExtraLarge: v as double),
    (SemiResolvedAvatarThemeData d) => d.radiusAvatarExtraLarge,
  ),
  (
    r'$animation_duration-additionalBorder: 800ms',
    const Duration(milliseconds: 123),
    (Object v) => SemiAvatarThemeData(animationDurationAdditionalBorder: v as Duration),
    (SemiResolvedAvatarThemeData d) => d.animationDurationAdditionalBorder,
  ),
  (
    r'$animation_duration-content: 1000ms',
    const Duration(milliseconds: 123),
    (Object v) => SemiAvatarThemeData(animationDurationContent: v as Duration),
    (SemiResolvedAvatarThemeData d) => d.animationDurationContent,
  ),
  (
    r'$animation_opacity-additionalBorder-start: 1',
    37.0,
    (Object v) => SemiAvatarThemeData(animationOpacityAdditionalBorderStart: v as double),
    (SemiResolvedAvatarThemeData d) => d.animationOpacityAdditionalBorderStart,
  ),
  (
    r'$animation_opacity-additionalBorder-end: 0',
    37.0,
    (Object v) => SemiAvatarThemeData(animationOpacityAdditionalBorderEnd: v as double),
    (SemiResolvedAvatarThemeData d) => d.animationOpacityAdditionalBorderEnd,
  ),
  (
    r'$animation_width-additionalBorder-end: 0',
    37.0,
    (Object v) => SemiAvatarThemeData(animationWidthAdditionalBorderEnd: v as double),
    (SemiResolvedAvatarThemeData d) => d.animationWidthAdditionalBorderEnd,
  ),
  (
    r'$animation_scale-additionalBorder-start: 1',
    37.0,
    (Object v) => SemiAvatarThemeData(animationScaleAdditionalBorderStart: v as double),
    (SemiResolvedAvatarThemeData d) => d.animationScaleAdditionalBorderStart,
  ),
  (
    r'$animation_scale-additionalBorder-end: 1.15',
    37.0,
    (Object v) => SemiAvatarThemeData(animationScaleAdditionalBorderEnd: v as double),
    (SemiResolvedAvatarThemeData d) => d.animationScaleAdditionalBorderEnd,
  ),
  (
    r'$animation_scale-content-start: 1',
    37.0,
    (Object v) => SemiAvatarThemeData(animationScaleContentStart: v as double),
    (SemiResolvedAvatarThemeData d) => d.animationScaleContentStart,
  ),
  (
    r'$animation_scale-content-middle: 0.9',
    37.0,
    (Object v) => SemiAvatarThemeData(animationScaleContentMiddle: v as double),
    (SemiResolvedAvatarThemeData d) => d.animationScaleContentMiddle,
  ),
  (
    r'$animation_scale-content-end: 1',
    37.0,
    (Object v) => SemiAvatarThemeData(animationScaleContentEnd: v as double),
    (SemiResolvedAvatarThemeData d) => d.animationScaleContentEnd,
  ),];

void main() {
  test('99 fields: merge, copyWith, resolve, equality', () {
    expect(fields, hasLength(99));
    for (final (sass, value, make, read) in fields) {
      final patch = make(value);
      expect(const SemiAvatarThemeData().merge(patch), patch, reason: sass);
      expect(patch.copyWith(), patch, reason: sass);
      expect(patch.copyWith().hashCode, patch.hashCode, reason: sass);
      expect(patch.merge(null), patch, reason: sass);
      expect(
        read(patch.resolve(const SemiThemeData.dark())),
        value,
        reason: sass,
      );
      expect(
        read(const SemiAvatarThemeData().resolve(const SemiThemeData.light())),
        isNotNull,
        reason: sass,
      );
    }
  });

  test('every field carries its Sass provenance in the generated source', () {
    final source = File('lib/src/theme/semi_avatar_theme_data.dart')
        .readAsStringSync();
    final names = <String>{};
    for (final (sass, _, _, _) in fields) {
      expect(source, contains(sass));
      names.add(sass.split(': ').first.substring(1));
    }
    expect(names, hasLength(99));
    expect(source, contains('packages/semi-foundation/avatar/variables.scss'));
    expect(source, contains('packages/semi-foundation/avatar/animation.scss'));
    expect(source, contains('Generated by tool/generate_avatar.py'));
    expect(source, contains('# dead variable (上游未消费)'));
  });

  test('type coverage: 9 Color + 1 SemiLength + 87 double + 2 Duration', () {
    final counts = <String, int>{};
    for (final (_, value, _, _) in fields) {
      counts.update(
        value.runtimeType.toString(),
        (n) => n + 1,
        ifAbsent: () => 1,
      );
    }
    expect(counts['Color'], 9);
    expect(counts['SemiLength'], 1);
    expect(counts['double'], 87);
    expect(counts['Duration'], 2);
  });

  test('the dead field stays in the theme and is absent from the widget', () {
    final theme = File('lib/src/theme/semi_avatar_theme_data.dart')
        .readAsStringSync();
    final widget = File('lib/src/components/semi_avatar.dart')
        .readAsStringSync();
    expect(theme, contains('widthAvatarBottomSlotSquareExtraSmallBorder'));
    expect(
      RegExp(
        r'(?<![A-Za-z])widthAvatarBottomSlotSquareExtraSmallBorder(?![A-Za-z])',
      ).hasMatch(widget),
      isFalse,
    );
  });

  test('SemiComponentThemes wiring', () {
    const themes = SemiComponentThemes();
    expect(themes.avatar, const SemiAvatarThemeData());
    expect(
      themes.copyWith(avatar: const SemiAvatarThemeData(zAvatarDefault: 42)),
      const SemiComponentThemes(
        avatar: SemiAvatarThemeData(zAvatarDefault: 42),
      ),
    );
  });

  testWidgets('SemiAvatarTheme local patch applies to the avatar box', (
    tester,
  ) async {
    await tester.pumpWidget(
      SemiTheme(
        data: const SemiThemeData.light(),
        child: SemiAvatarTheme(
          data: const SemiAvatarThemeData(widthAvatarMedium: 60),
          child: const Directionality(
            textDirection: TextDirection.ltr,
            child: Center(child: SemiAvatar(text: 'x')),
          ),
        ),
      ),
    );
    expect(tester.getSize(find.byType(SemiAvatar)), const Size(60, 60));
  });
}
