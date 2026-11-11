// Matrix coverage for the 206 generated theme fields: defaults, overrides,
// merge, copyWith, resolve, equality and per-field Sass provenance.
// The 7 cssVariables fields live in SemiButtonTokens (see
// test/generated_token_overrides_test.dart) and tool/test_generate_button.py.
import 'dart:io';

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:semi_design_flutter/semi_design_flutter.dart';

final gradientSample = SemiGradient(
  278,
  [const Color(0xff112233), const Color(0xff445566)],
  [0, 1],
);
const transformSample = SemiTransform.scale(2, 3);

typedef _Patch = SemiButtonThemeData Function(Object value);
typedef _Read = Object? Function(SemiResolvedButtonThemeData data);

final List<(String, Object, _Patch, _Read)> fields = [
  (
    r'$color-button_primary-bg-default: var(--semi-color-primary)',
    const Color(0xff123456),
    (Object v) => SemiButtonThemeData(colorButtonPrimaryBgDefault: v as Color),
    (SemiResolvedButtonThemeData d) => d.colorButtonPrimaryBgDefault,
  ),
  (
    r'$color-button_primary-border-default: transparent',
    const Color(0xff123456),
    (Object v) =>
        SemiButtonThemeData(colorButtonPrimaryBorderDefault: v as Color),
    (SemiResolvedButtonThemeData d) => d.colorButtonPrimaryBorderDefault,
  ),
  (
    r'$color-button_primary-text-default: rgba(var(--semi-white), 1)',
    const Color(0xff123456),
    (Object v) =>
        SemiButtonThemeData(colorButtonPrimaryTextDefault: v as Color),
    (SemiResolvedButtonThemeData d) => d.colorButtonPrimaryTextDefault,
  ),
  (
    r'$color-button_primary-bg-hover: var(--semi-color-primary-hover)',
    const Color(0xff123456),
    (Object v) => SemiButtonThemeData(colorButtonPrimaryBgHover: v as Color),
    (SemiResolvedButtonThemeData d) => d.colorButtonPrimaryBgHover,
  ),
  (
    r'$color-button_primary-border-hover: var(--semi-color-primary-hover)',
    const Color(0xff123456),
    (Object v) =>
        SemiButtonThemeData(colorButtonPrimaryBorderHover: v as Color),
    (SemiResolvedButtonThemeData d) => d.colorButtonPrimaryBorderHover,
  ),
  (
    r'$color-button_primary-text-hover: rgba(var(--semi-white), 1)',
    const Color(0xff123456),
    (Object v) => SemiButtonThemeData(colorButtonPrimaryTextHover: v as Color),
    (SemiResolvedButtonThemeData d) => d.colorButtonPrimaryTextHover,
  ),
  (
    r'$color-button_primary-bg-active: var(--semi-color-primary-active)',
    const Color(0xff123456),
    (Object v) => SemiButtonThemeData(colorButtonPrimaryBgActive: v as Color),
    (SemiResolvedButtonThemeData d) => d.colorButtonPrimaryBgActive,
  ),
  (
    r'$color-button_primary-border-active: var(--semi-color-primary-active)',
    const Color(0xff123456),
    (Object v) =>
        SemiButtonThemeData(colorButtonPrimaryBorderActive: v as Color),
    (SemiResolvedButtonThemeData d) => d.colorButtonPrimaryBorderActive,
  ),
  (
    r'$color-button_primary-text-active: rgba(var(--semi-white), 1)',
    const Color(0xff123456),
    (Object v) => SemiButtonThemeData(colorButtonPrimaryTextActive: v as Color),
    (SemiResolvedButtonThemeData d) => d.colorButtonPrimaryTextActive,
  ),
  (
    r'$color-button_primary_outline-focus: var(--semi-color-primary-light-active)',
    const Color(0xff123456),
    (Object v) =>
        SemiButtonThemeData(colorButtonPrimaryOutlineFocus: v as Color),
    (SemiResolvedButtonThemeData d) => d.colorButtonPrimaryOutlineFocus,
  ),
  (
    r'$color-button_primary_outline-border-default: var(--semi-color-border)',
    const Color(0xff123456),
    (Object v) =>
        SemiButtonThemeData(colorButtonPrimaryOutlineBorderDefault: v as Color),
    (SemiResolvedButtonThemeData d) => d.colorButtonPrimaryOutlineBorderDefault,
  ),
  (
    r'$color-button_primary_borderless-text-default: var(--semi-color-primary)',
    const Color(0xff123456),
    (Object v) => SemiButtonThemeData(
      colorButtonPrimaryBorderlessTextDefault: v as Color,
    ),
    (SemiResolvedButtonThemeData d) =>
        d.colorButtonPrimaryBorderlessTextDefault,
  ),
  (
    r'$color-button_primary_solid_colorful-bg-default: var(--semi-color-ai-general)',
    gradientSample,
    (Object v) => SemiButtonThemeData(
      colorButtonPrimarySolidColorfulBgDefault: v as SemiGradient,
    ),
    (SemiResolvedButtonThemeData d) =>
        d.colorButtonPrimarySolidColorfulBgDefault,
  ),
  (
    r'$color-button_primary_solid_colorful-bg-hover: var(--semi-color-ai-general-hover)',
    gradientSample,
    (Object v) => SemiButtonThemeData(
      colorButtonPrimarySolidColorfulBgHover: v as SemiGradient,
    ),
    (SemiResolvedButtonThemeData d) => d.colorButtonPrimarySolidColorfulBgHover,
  ),
  (
    r'$color-button_primary_solid_colorful-bg-active: var(--semi-color-ai-general-active)',
    gradientSample,
    (Object v) => SemiButtonThemeData(
      colorButtonPrimarySolidColorfulBgActive: v as SemiGradient,
    ),
    (SemiResolvedButtonThemeData d) =>
        d.colorButtonPrimarySolidColorfulBgActive,
  ),
  (
    r'$color-button_primary_light_colorful-text-default: var(--semi-color-ai-general)',
    gradientSample,
    (Object v) => SemiButtonThemeData(
      colorButtonPrimaryLightColorfulTextDefault: v as SemiGradient,
    ),
    (SemiResolvedButtonThemeData d) =>
        d.colorButtonPrimaryLightColorfulTextDefault,
  ),
  (
    r'$color-button_primary_light_outline-text-default: var(--semi-color-ai-purple)',
    const Color(0xff123456),
    (Object v) => SemiButtonThemeData(
      colorButtonPrimaryLightOutlineTextDefault: v as Color,
    ),
    (SemiResolvedButtonThemeData d) =>
        d.colorButtonPrimaryLightOutlineTextDefault,
  ),
  (
    r'$color-button_primary_light_outline-border: var(--semi-color-ai-purple)',
    const Color(0xff123456),
    (Object v) =>
        SemiButtonThemeData(colorButtonPrimaryLightOutlineBorder: v as Color),
    (SemiResolvedButtonThemeData d) => d.colorButtonPrimaryLightOutlineBorder,
  ),
  (
    r'$color-button_primary_light_borderless-text-default: var(--semi-color-ai-general)',
    gradientSample,
    (Object v) => SemiButtonThemeData(
      colorButtonPrimaryLightBorderlessTextDefault: v as SemiGradient,
    ),
    (SemiResolvedButtonThemeData d) =>
        d.colorButtonPrimaryLightBorderlessTextDefault,
  ),
  (
    r'$color-button_secondary-bg-default: var(--semi-color-secondary)',
    const Color(0xff123456),
    (Object v) =>
        SemiButtonThemeData(colorButtonSecondaryBgDefault: v as Color),
    (SemiResolvedButtonThemeData d) => d.colorButtonSecondaryBgDefault,
  ),
  (
    r'$color-button_secondary-border-default: var(--semi-color-secondary)',
    const Color(0xff123456),
    (Object v) =>
        SemiButtonThemeData(colorButtonSecondaryBorderDefault: v as Color),
    (SemiResolvedButtonThemeData d) => d.colorButtonSecondaryBorderDefault,
  ),
  (
    r'$color-button_secondary-text-default: rgba(var(--semi-white), 1)',
    const Color(0xff123456),
    (Object v) =>
        SemiButtonThemeData(colorButtonSecondaryTextDefault: v as Color),
    (SemiResolvedButtonThemeData d) => d.colorButtonSecondaryTextDefault,
  ),
  (
    r'$color-button_secondary-bg-hover: var(--semi-color-secondary-hover)',
    const Color(0xff123456),
    (Object v) => SemiButtonThemeData(colorButtonSecondaryBgHover: v as Color),
    (SemiResolvedButtonThemeData d) => d.colorButtonSecondaryBgHover,
  ),
  (
    r'$color-button_secondary-border-hover: var(--semi-color-secondary-hover)',
    const Color(0xff123456),
    (Object v) =>
        SemiButtonThemeData(colorButtonSecondaryBorderHover: v as Color),
    (SemiResolvedButtonThemeData d) => d.colorButtonSecondaryBorderHover,
  ),
  (
    r'$color-button_secondary-text-hover: rgba(var(--semi-white), 1)',
    const Color(0xff123456),
    (Object v) =>
        SemiButtonThemeData(colorButtonSecondaryTextHover: v as Color),
    (SemiResolvedButtonThemeData d) => d.colorButtonSecondaryTextHover,
  ),
  (
    r'$color-button_secondary-bg-active: var(--semi-color-secondary-active)',
    const Color(0xff123456),
    (Object v) => SemiButtonThemeData(colorButtonSecondaryBgActive: v as Color),
    (SemiResolvedButtonThemeData d) => d.colorButtonSecondaryBgActive,
  ),
  (
    r'$color-button_secondary-border-active: var(--semi-color-secondary-active)',
    const Color(0xff123456),
    (Object v) =>
        SemiButtonThemeData(colorButtonSecondaryBorderActive: v as Color),
    (SemiResolvedButtonThemeData d) => d.colorButtonSecondaryBorderActive,
  ),
  (
    r'$color-button_secondary-text-active: rgba(var(--semi-white), 1)',
    const Color(0xff123456),
    (Object v) =>
        SemiButtonThemeData(colorButtonSecondaryTextActive: v as Color),
    (SemiResolvedButtonThemeData d) => d.colorButtonSecondaryTextActive,
  ),
  (
    r'$color-button_secondary_outline-border-default: var(--semi-color-border)',
    const Color(0xff123456),
    (Object v) => SemiButtonThemeData(
      colorButtonSecondaryOutlineBorderDefault: v as Color,
    ),
    (SemiResolvedButtonThemeData d) =>
        d.colorButtonSecondaryOutlineBorderDefault,
  ),
  (
    r'$color-button_secondary_borderless-text-default: var(--semi-color-secondary)',
    const Color(0xff123456),
    (Object v) => SemiButtonThemeData(
      colorButtonSecondaryBorderlessTextDefault: v as Color,
    ),
    (SemiResolvedButtonThemeData d) =>
        d.colorButtonSecondaryBorderlessTextDefault,
  ),
  (
    r'$color-button_danger-bg-default: var(--semi-color-danger)',
    const Color(0xff123456),
    (Object v) => SemiButtonThemeData(colorButtonDangerBgDefault: v as Color),
    (SemiResolvedButtonThemeData d) => d.colorButtonDangerBgDefault,
  ),
  (
    r'$color-button_danger-border-default: var(--semi-color-danger)',
    const Color(0xff123456),
    (Object v) =>
        SemiButtonThemeData(colorButtonDangerBorderDefault: v as Color),
    (SemiResolvedButtonThemeData d) => d.colorButtonDangerBorderDefault,
  ),
  (
    r'$color-button_danger-text-default: rgba(var(--semi-white), 1)',
    const Color(0xff123456),
    (Object v) => SemiButtonThemeData(colorButtonDangerTextDefault: v as Color),
    (SemiResolvedButtonThemeData d) => d.colorButtonDangerTextDefault,
  ),
  (
    r'$color-button_danger-bg-hover: var(--semi-color-danger-hover)',
    const Color(0xff123456),
    (Object v) => SemiButtonThemeData(colorButtonDangerBgHover: v as Color),
    (SemiResolvedButtonThemeData d) => d.colorButtonDangerBgHover,
  ),
  (
    r'$color-button_danger-border-hover: var(--semi-color-danger)',
    const Color(0xff123456),
    (Object v) => SemiButtonThemeData(colorButtonDangerBorderHover: v as Color),
    (SemiResolvedButtonThemeData d) => d.colorButtonDangerBorderHover,
  ),
  (
    r'$color-button_danger-text-hover: rgba(var(--semi-white), 1)',
    const Color(0xff123456),
    (Object v) => SemiButtonThemeData(colorButtonDangerTextHover: v as Color),
    (SemiResolvedButtonThemeData d) => d.colorButtonDangerTextHover,
  ),
  (
    r'$color-button_danger-bg-active: var(--semi-color-danger-active)',
    const Color(0xff123456),
    (Object v) => SemiButtonThemeData(colorButtonDangerBgActive: v as Color),
    (SemiResolvedButtonThemeData d) => d.colorButtonDangerBgActive,
  ),
  (
    r'$color-button_danger-border-active: var(--semi-color-danger-active)',
    const Color(0xff123456),
    (Object v) =>
        SemiButtonThemeData(colorButtonDangerBorderActive: v as Color),
    (SemiResolvedButtonThemeData d) => d.colorButtonDangerBorderActive,
  ),
  (
    r'$color-button_danger-text-active: rgba(var(--semi-white), 1)',
    const Color(0xff123456),
    (Object v) => SemiButtonThemeData(colorButtonDangerTextActive: v as Color),
    (SemiResolvedButtonThemeData d) => d.colorButtonDangerTextActive,
  ),
  (
    r'$color-button_danger-outline-focus: var(--semi-color-danger-light-active)',
    const Color(0xff123456),
    (Object v) =>
        SemiButtonThemeData(colorButtonDangerOutlineFocus: v as Color),
    (SemiResolvedButtonThemeData d) => d.colorButtonDangerOutlineFocus,
  ),
  (
    r'$color-button_danger_outline-border-default: var(--semi-color-danger)',
    const Color(0xff123456),
    (Object v) =>
        SemiButtonThemeData(colorButtonDangerOutlineBorderDefault: v as Color),
    (SemiResolvedButtonThemeData d) => d.colorButtonDangerOutlineBorderDefault,
  ),
  (
    r'$color-button_danger_borderless-text-default: var(--semi-color-danger)',
    const Color(0xff123456),
    (Object v) =>
        SemiButtonThemeData(colorButtonDangerBorderlessTextDefault: v as Color),
    (SemiResolvedButtonThemeData d) => d.colorButtonDangerBorderlessTextDefault,
  ),
  (
    r'$color-button_warning-bg-default: var(--semi-color-warning)',
    const Color(0xff123456),
    (Object v) => SemiButtonThemeData(colorButtonWarningBgDefault: v as Color),
    (SemiResolvedButtonThemeData d) => d.colorButtonWarningBgDefault,
  ),
  (
    r'$color-button_warning-border-default: var(--semi-color-warning)',
    const Color(0xff123456),
    (Object v) =>
        SemiButtonThemeData(colorButtonWarningBorderDefault: v as Color),
    (SemiResolvedButtonThemeData d) => d.colorButtonWarningBorderDefault,
  ),
  (
    r'$color-button_warning-text-default: rgba(var(--semi-white), 1)',
    const Color(0xff123456),
    (Object v) =>
        SemiButtonThemeData(colorButtonWarningTextDefault: v as Color),
    (SemiResolvedButtonThemeData d) => d.colorButtonWarningTextDefault,
  ),
  (
    r'$color-button_warning-bg-hover: var(--semi-color-warning-hover)',
    const Color(0xff123456),
    (Object v) => SemiButtonThemeData(colorButtonWarningBgHover: v as Color),
    (SemiResolvedButtonThemeData d) => d.colorButtonWarningBgHover,
  ),
  (
    r'$color-button_warning-border-hover: var(--semi-color-warning-hover)',
    const Color(0xff123456),
    (Object v) =>
        SemiButtonThemeData(colorButtonWarningBorderHover: v as Color),
    (SemiResolvedButtonThemeData d) => d.colorButtonWarningBorderHover,
  ),
  (
    r'$color-button_warning-text-hover: rgba(var(--semi-white), 1)',
    const Color(0xff123456),
    (Object v) => SemiButtonThemeData(colorButtonWarningTextHover: v as Color),
    (SemiResolvedButtonThemeData d) => d.colorButtonWarningTextHover,
  ),
  (
    r'$color-button_warning-bg-active: var(--semi-color-warning-active)',
    const Color(0xff123456),
    (Object v) => SemiButtonThemeData(colorButtonWarningBgActive: v as Color),
    (SemiResolvedButtonThemeData d) => d.colorButtonWarningBgActive,
  ),
  (
    r'$color-button_warning-border-active: var(--semi-color-warning-active)',
    const Color(0xff123456),
    (Object v) =>
        SemiButtonThemeData(colorButtonWarningBorderActive: v as Color),
    (SemiResolvedButtonThemeData d) => d.colorButtonWarningBorderActive,
  ),
  (
    r'$color-button_warning-text-active: rgba(var(--semi-white), 1)',
    const Color(0xff123456),
    (Object v) => SemiButtonThemeData(colorButtonWarningTextActive: v as Color),
    (SemiResolvedButtonThemeData d) => d.colorButtonWarningTextActive,
  ),
  (
    r'$color-button_warning-outline-focus: var(--semi-color-warning-light-active)',
    const Color(0xff123456),
    (Object v) =>
        SemiButtonThemeData(colorButtonWarningOutlineFocus: v as Color),
    (SemiResolvedButtonThemeData d) => d.colorButtonWarningOutlineFocus,
  ),
  (
    r'$color-button_warning_outline-border-default: var(--semi-color-warning)',
    const Color(0xff123456),
    (Object v) =>
        SemiButtonThemeData(colorButtonWarningOutlineBorderDefault: v as Color),
    (SemiResolvedButtonThemeData d) => d.colorButtonWarningOutlineBorderDefault,
  ),
  (
    r'$color-button_warning_borderless-text-default: var(--semi-color-warning)',
    const Color(0xff123456),
    (Object v) => SemiButtonThemeData(
      colorButtonWarningBorderlessTextDefault: v as Color,
    ),
    (SemiResolvedButtonThemeData d) =>
        d.colorButtonWarningBorderlessTextDefault,
  ),
  (
    r'$color-button_tertiary-bg-default: var(--semi-color-tertiary)',
    const Color(0xff123456),
    (Object v) => SemiButtonThemeData(colorButtonTertiaryBgDefault: v as Color),
    (SemiResolvedButtonThemeData d) => d.colorButtonTertiaryBgDefault,
  ),
  (
    r'$color-button_tertiary-border-default: var(--semi-color-tertiary)',
    const Color(0xff123456),
    (Object v) =>
        SemiButtonThemeData(colorButtonTertiaryBorderDefault: v as Color),
    (SemiResolvedButtonThemeData d) => d.colorButtonTertiaryBorderDefault,
  ),
  (
    r'$color-button_tertiary-text-default: rgba(var(--semi-white), 1)',
    const Color(0xff123456),
    (Object v) =>
        SemiButtonThemeData(colorButtonTertiaryTextDefault: v as Color),
    (SemiResolvedButtonThemeData d) => d.colorButtonTertiaryTextDefault,
  ),
  (
    r'$color-button_tertiary_solid_colorful-bg-default: var(--semi-ai-general-0)',
    gradientSample,
    (Object v) => SemiButtonThemeData(
      colorButtonTertiarySolidColorfulBgDefault: v as SemiGradient,
    ),
    (SemiResolvedButtonThemeData d) =>
        d.colorButtonTertiarySolidColorfulBgDefault,
  ),
  (
    r'$color-button_tertiary_solid_colorful-bg-hover: var(--semi-ai-general-1)',
    gradientSample,
    (Object v) => SemiButtonThemeData(
      colorButtonTertiarySolidColorfulBgHover: v as SemiGradient,
    ),
    (SemiResolvedButtonThemeData d) =>
        d.colorButtonTertiarySolidColorfulBgHover,
  ),
  (
    r'$color-button_tertiary_solid_colorful-bg-active: var(--semi-ai-general-2)',
    gradientSample,
    (Object v) => SemiButtonThemeData(
      colorButtonTertiarySolidColorfulBgActive: v as SemiGradient,
    ),
    (SemiResolvedButtonThemeData d) =>
        d.colorButtonTertiarySolidColorfulBgActive,
  ),
  (
    r'$color-button_tertiary_solid_colorful-text-default: var(--semi-color-ai-general)',
    gradientSample,
    (Object v) => SemiButtonThemeData(
      colorButtonTertiarySolidColorfulTextDefault: v as SemiGradient,
    ),
    (SemiResolvedButtonThemeData d) =>
        d.colorButtonTertiarySolidColorfulTextDefault,
  ),
  (
    r'$color-button_tertiary-bg-hover: var(--semi-color-tertiary-hover)',
    const Color(0xff123456),
    (Object v) => SemiButtonThemeData(colorButtonTertiaryBgHover: v as Color),
    (SemiResolvedButtonThemeData d) => d.colorButtonTertiaryBgHover,
  ),
  (
    r'$color-button_tertiary-border-hover: var(--semi-color-tertiary-hover)',
    const Color(0xff123456),
    (Object v) =>
        SemiButtonThemeData(colorButtonTertiaryBorderHover: v as Color),
    (SemiResolvedButtonThemeData d) => d.colorButtonTertiaryBorderHover,
  ),
  (
    r'$color-button_tertiary-text-hover: rgba(var(--semi-white), 1)',
    const Color(0xff123456),
    (Object v) => SemiButtonThemeData(colorButtonTertiaryTextHover: v as Color),
    (SemiResolvedButtonThemeData d) => d.colorButtonTertiaryTextHover,
  ),
  (
    r'$color-button_tertiary-bg-active: var(--semi-color-tertiary-active)',
    const Color(0xff123456),
    (Object v) => SemiButtonThemeData(colorButtonTertiaryBgActive: v as Color),
    (SemiResolvedButtonThemeData d) => d.colorButtonTertiaryBgActive,
  ),
  (
    r'$color-button_tertiary-border-active: var(--semi-color-tertiary-active)',
    const Color(0xff123456),
    (Object v) =>
        SemiButtonThemeData(colorButtonTertiaryBorderActive: v as Color),
    (SemiResolvedButtonThemeData d) => d.colorButtonTertiaryBorderActive,
  ),
  (
    r'$color-button_tertiary-text-active: rgba(var(--semi-white), 1)',
    const Color(0xff123456),
    (Object v) =>
        SemiButtonThemeData(colorButtonTertiaryTextActive: v as Color),
    (SemiResolvedButtonThemeData d) => d.colorButtonTertiaryTextActive,
  ),
  (
    r'$color-button_tertiary_outline-border-default: var(--semi-color-border)',
    const Color(0xff123456),
    (Object v) => SemiButtonThemeData(
      colorButtonTertiaryOutlineBorderDefault: v as Color,
    ),
    (SemiResolvedButtonThemeData d) =>
        d.colorButtonTertiaryOutlineBorderDefault,
  ),
  (
    r'$color-button_tertiary_solid-text-default: var(--semi-color-text-1)',
    const Color(0xff123456),
    (Object v) =>
        SemiButtonThemeData(colorButtonTertiarySolidTextDefault: v as Color),
    (SemiResolvedButtonThemeData d) => d.colorButtonTertiarySolidTextDefault,
  ),
  (
    r'$color-button_disabled_solid-text-default: var(--semi-color-disabled-text)',
    const Color(0xff123456),
    (Object v) =>
        SemiButtonThemeData(colorButtonDisabledSolidTextDefault: v as Color),
    (SemiResolvedButtonThemeData d) => d.colorButtonDisabledSolidTextDefault,
  ),
  (
    r'$color-button_disabled-text-default: var(--semi-color-disabled-text)',
    const Color(0xff123456),
    (Object v) =>
        SemiButtonThemeData(colorButtonDisabledTextDefault: v as Color),
    (SemiResolvedButtonThemeData d) => d.colorButtonDisabledTextDefault,
  ),
  (
    r'$color-button_disabled_outline_text-default: var(--semi-color-disabled-text)',
    const Color(0xff123456),
    (Object v) =>
        SemiButtonThemeData(colorButtonDisabledOutlineTextDefault: v as Color),
    (SemiResolvedButtonThemeData d) => d.colorButtonDisabledOutlineTextDefault,
  ),
  (
    r'$color-button_disabled-bg-default: var(--semi-color-disabled-bg)',
    const Color(0xff123456),
    (Object v) => SemiButtonThemeData(colorButtonDisabledBgDefault: v as Color),
    (SemiResolvedButtonThemeData d) => d.colorButtonDisabledBgDefault,
  ),
  (
    r'$color-button_disabled-text-hover: $color-button_disabled-text-default',
    const Color(0xff123456),
    (Object v) => SemiButtonThemeData(colorButtonDisabledTextHover: v as Color),
    (SemiResolvedButtonThemeData d) => d.colorButtonDisabledTextHover,
  ),
  (
    r'$color-button_disabled-bg-hover: var(--semi-color-disabled-bg)',
    const Color(0xff123456),
    (Object v) => SemiButtonThemeData(colorButtonDisabledBgHover: v as Color),
    (SemiResolvedButtonThemeData d) => d.colorButtonDisabledBgHover,
  ),
  (
    r'$color-button_disabled_primary-bg-default: $color-button_disabled-bg-default',
    const Color(0xff123456),
    (Object v) =>
        SemiButtonThemeData(colorButtonDisabledPrimaryBgDefault: v as Color),
    (SemiResolvedButtonThemeData d) => d.colorButtonDisabledPrimaryBgDefault,
  ),
  (
    r'$color-button_disabled_secondary-bg-default: $color-button_disabled-bg-default',
    const Color(0xff123456),
    (Object v) =>
        SemiButtonThemeData(colorButtonDisabledSecondaryBgDefault: v as Color),
    (SemiResolvedButtonThemeData d) => d.colorButtonDisabledSecondaryBgDefault,
  ),
  (
    r'$color-button_disabled_danger-bg-default: $color-button_disabled-bg-default',
    const Color(0xff123456),
    (Object v) =>
        SemiButtonThemeData(colorButtonDisabledDangerBgDefault: v as Color),
    (SemiResolvedButtonThemeData d) => d.colorButtonDisabledDangerBgDefault,
  ),
  (
    r'$color-button_disabled_warning-bg-default: $color-button_disabled-bg-default',
    const Color(0xff123456),
    (Object v) =>
        SemiButtonThemeData(colorButtonDisabledWarningBgDefault: v as Color),
    (SemiResolvedButtonThemeData d) => d.colorButtonDisabledWarningBgDefault,
  ),
  (
    r'$color-button_disabled_tertiary-bg-default: $color-button_disabled-bg-default',
    const Color(0xff123456),
    (Object v) =>
        SemiButtonThemeData(colorButtonDisabledTertiaryBgDefault: v as Color),
    (SemiResolvedButtonThemeData d) => d.colorButtonDisabledTertiaryBgDefault,
  ),
  (
    r'$color-button_disabled_outline-border-default: var(--semi-color-border)',
    const Color(0xff123456),
    (Object v) => SemiButtonThemeData(
      colorButtonDisabledOutlineBorderDefault: v as Color,
    ),
    (SemiResolvedButtonThemeData d) =>
        d.colorButtonDisabledOutlineBorderDefault,
  ),
  (
    r'$color-button_light-bg-default: var(--semi-color-fill-0)',
    const Color(0xff123456),
    (Object v) => SemiButtonThemeData(colorButtonLightBgDefault: v as Color),
    (SemiResolvedButtonThemeData d) => d.colorButtonLightBgDefault,
  ),
  (
    r'$color-button_light-bg-hover: var(--semi-color-fill-1)',
    const Color(0xff123456),
    (Object v) => SemiButtonThemeData(colorButtonLightBgHover: v as Color),
    (SemiResolvedButtonThemeData d) => d.colorButtonLightBgHover,
  ),
  (
    r'$color-button_light-bg-active: var(--semi-color-fill-2)',
    const Color(0xff123456),
    (Object v) => SemiButtonThemeData(colorButtonLightBgActive: v as Color),
    (SemiResolvedButtonThemeData d) => d.colorButtonLightBgActive,
  ),
  (
    r'$color-button_light-border-default: transparent',
    const Color(0xff123456),
    (Object v) =>
        SemiButtonThemeData(colorButtonLightBorderDefault: v as Color),
    (SemiResolvedButtonThemeData d) => d.colorButtonLightBorderDefault,
  ),
  (
    r'$color-button_light-border-hover: $color-button_light-border-default',
    const Color(0xff123456),
    (Object v) => SemiButtonThemeData(colorButtonLightBorderHover: v as Color),
    (SemiResolvedButtonThemeData d) => d.colorButtonLightBorderHover,
  ),
  (
    r'$color-button_light-border-active: $color-button_light-border-hover',
    const Color(0xff123456),
    (Object v) => SemiButtonThemeData(colorButtonLightBorderActive: v as Color),
    (SemiResolvedButtonThemeData d) => d.colorButtonLightBorderActive,
  ),
  (
    r'$color-button_disabled_light_primary-bg-default: $color-button_light-bg-default',
    const Color(0xff123456),
    (Object v) => SemiButtonThemeData(
      colorButtonDisabledLightPrimaryBgDefault: v as Color,
    ),
    (SemiResolvedButtonThemeData d) =>
        d.colorButtonDisabledLightPrimaryBgDefault,
  ),
  (
    r'$color-button_disabled_light_secondary-bg-default: $color-button_light-bg-default',
    const Color(0xff123456),
    (Object v) => SemiButtonThemeData(
      colorButtonDisabledLightSecondaryBgDefault: v as Color,
    ),
    (SemiResolvedButtonThemeData d) =>
        d.colorButtonDisabledLightSecondaryBgDefault,
  ),
  (
    r'$color-button_disabled_light_danger-bg-default: $color-button_light-bg-default',
    const Color(0xff123456),
    (Object v) => SemiButtonThemeData(
      colorButtonDisabledLightDangerBgDefault: v as Color,
    ),
    (SemiResolvedButtonThemeData d) =>
        d.colorButtonDisabledLightDangerBgDefault,
  ),
  (
    r'$color-button_disabled_light_warning-bg-default: $color-button_light-bg-default',
    const Color(0xff123456),
    (Object v) => SemiButtonThemeData(
      colorButtonDisabledLightWarningBgDefault: v as Color,
    ),
    (SemiResolvedButtonThemeData d) =>
        d.colorButtonDisabledLightWarningBgDefault,
  ),
  (
    r'$color-button_disabled_light_tertiary-bg-default: $color-button_light-bg-default',
    const Color(0xff123456),
    (Object v) => SemiButtonThemeData(
      colorButtonDisabledLightTertiaryBgDefault: v as Color,
    ),
    (SemiResolvedButtonThemeData d) =>
        d.colorButtonDisabledLightTertiaryBgDefault,
  ),
  (
    r'$color-button_borderless-text-default: var(--semi-color-primary)',
    const Color(0xff123456),
    (Object v) =>
        SemiButtonThemeData(colorButtonBorderlessTextDefault: v as Color),
    (SemiResolvedButtonThemeData d) => d.colorButtonBorderlessTextDefault,
  ),
  (
    r'$color-button_borderless-bg-hover: var(--semi-color-fill-0)',
    const Color(0xff123456),
    (Object v) => SemiButtonThemeData(colorButtonBorderlessBgHover: v as Color),
    (SemiResolvedButtonThemeData d) => d.colorButtonBorderlessBgHover,
  ),
  (
    r'$color-button_borderless-bg-active: var(--semi-color-fill-1)',
    const Color(0xff123456),
    (Object v) =>
        SemiButtonThemeData(colorButtonBorderlessBgActive: v as Color),
    (SemiResolvedButtonThemeData d) => d.colorButtonBorderlessBgActive,
  ),
  (
    r'$color-button_borderless-border-default: transparent',
    const Color(0xff123456),
    (Object v) =>
        SemiButtonThemeData(colorButtonBorderlessBorderDefault: v as Color),
    (SemiResolvedButtonThemeData d) => d.colorButtonBorderlessBorderDefault,
  ),
  (
    r'$color-button_borderless-border-hover: $color-button_borderless-border-default',
    const Color(0xff123456),
    (Object v) =>
        SemiButtonThemeData(colorButtonBorderlessBorderHover: v as Color),
    (SemiResolvedButtonThemeData d) => d.colorButtonBorderlessBorderHover,
  ),
  (
    r'$color-button_borderless-border-active: $color-button_borderless-border-hover',
    const Color(0xff123456),
    (Object v) =>
        SemiButtonThemeData(colorButtonBorderlessBorderActive: v as Color),
    (SemiResolvedButtonThemeData d) => d.colorButtonBorderlessBorderActive,
  ),
  (
    r'$color-button_outline-bg-hover: var(--semi-color-fill-0)',
    const Color(0xff123456),
    (Object v) => SemiButtonThemeData(colorButtonOutlineBgHover: v as Color),
    (SemiResolvedButtonThemeData d) => d.colorButtonOutlineBgHover,
  ),
  (
    r'$color-button_outline-bg-active: var(--semi-color-fill-1)',
    const Color(0xff123456),
    (Object v) => SemiButtonThemeData(colorButtonOutlineBgActive: v as Color),
    (SemiResolvedButtonThemeData d) => d.colorButtonOutlineBgActive,
  ),
  (
    r'$color-button_group-border-default: var(--semi-color-border)',
    const Color(0xff123456),
    (Object v) =>
        SemiButtonThemeData(colorButtonGroupBorderDefault: v as Color),
    (SemiResolvedButtonThemeData d) => d.colorButtonGroupBorderDefault,
  ),
  (
    r'$width-button_light-border: 0',
    7.5,
    (Object v) => SemiButtonThemeData(widthButtonLightBorder: v as double),
    (SemiResolvedButtonThemeData d) => d.widthButtonLightBorder,
  ),
  (
    r'$width-button_borderless-border: 0',
    7.5,
    (Object v) => SemiButtonThemeData(widthButtonBorderlessBorder: v as double),
    (SemiResolvedButtonThemeData d) => d.widthButtonBorderlessBorder,
  ),
  (
    r'$width-button_outline-border: 1px',
    7.5,
    (Object v) => SemiButtonThemeData(widthButtonOutlineBorder: v as double),
    (SemiResolvedButtonThemeData d) => d.widthButtonOutlineBorder,
  ),
  (
    r'$width-button_group-border: $border-thickness-control',
    7.5,
    (Object v) => SemiButtonThemeData(widthButtonGroupBorder: v as double),
    (SemiResolvedButtonThemeData d) => d.widthButtonGroupBorder,
  ),
  (
    r'$spacing-button_default-paddingTop: 6px',
    7.5,
    (Object v) =>
        SemiButtonThemeData(spacingButtonDefaultPaddingTop: v as double),
    (SemiResolvedButtonThemeData d) => d.spacingButtonDefaultPaddingTop,
  ),
  (
    r'$spacing-button_default-paddingBottom: 6px',
    7.5,
    (Object v) =>
        SemiButtonThemeData(spacingButtonDefaultPaddingBottom: v as double),
    (SemiResolvedButtonThemeData d) => d.spacingButtonDefaultPaddingBottom,
  ),
  (
    r'$spacing-button_default-paddingLeft: $spacing-base-tight',
    7.5,
    (Object v) =>
        SemiButtonThemeData(spacingButtonDefaultPaddingLeft: v as double),
    (SemiResolvedButtonThemeData d) => d.spacingButtonDefaultPaddingLeft,
  ),
  (
    r'$spacing-button_default-paddingRight: $spacing-base-tight',
    7.5,
    (Object v) =>
        SemiButtonThemeData(spacingButtonDefaultPaddingRight: v as double),
    (SemiResolvedButtonThemeData d) => d.spacingButtonDefaultPaddingRight,
  ),
  (
    r'$spacing-button_large-paddingTop: 10px',
    7.5,
    (Object v) =>
        SemiButtonThemeData(spacingButtonLargePaddingTop: v as double),
    (SemiResolvedButtonThemeData d) => d.spacingButtonLargePaddingTop,
  ),
  (
    r'$spacing-button_large-paddingBottom: 10px',
    7.5,
    (Object v) =>
        SemiButtonThemeData(spacingButtonLargePaddingBottom: v as double),
    (SemiResolvedButtonThemeData d) => d.spacingButtonLargePaddingBottom,
  ),
  (
    r'$spacing-button_large-paddingLeft: $spacing-base',
    7.5,
    (Object v) =>
        SemiButtonThemeData(spacingButtonLargePaddingLeft: v as double),
    (SemiResolvedButtonThemeData d) => d.spacingButtonLargePaddingLeft,
  ),
  (
    r'$spacing-button_large-paddingRight: $spacing-base',
    7.5,
    (Object v) =>
        SemiButtonThemeData(spacingButtonLargePaddingRight: v as double),
    (SemiResolvedButtonThemeData d) => d.spacingButtonLargePaddingRight,
  ),
  (
    r'$spacing-button_small-paddingTop: $spacing-super-tight',
    7.5,
    (Object v) =>
        SemiButtonThemeData(spacingButtonSmallPaddingTop: v as double),
    (SemiResolvedButtonThemeData d) => d.spacingButtonSmallPaddingTop,
  ),
  (
    r'$spacing-button_small-paddingBottom: $spacing-super-tight',
    7.5,
    (Object v) =>
        SemiButtonThemeData(spacingButtonSmallPaddingBottom: v as double),
    (SemiResolvedButtonThemeData d) => d.spacingButtonSmallPaddingBottom,
  ),
  (
    r'$spacing-button_small-paddingLeft: $spacing-base-tight',
    7.5,
    (Object v) =>
        SemiButtonThemeData(spacingButtonSmallPaddingLeft: v as double),
    (SemiResolvedButtonThemeData d) => d.spacingButtonSmallPaddingLeft,
  ),
  (
    r'$spacing-button_small-paddingRight: $spacing-base-tight',
    7.5,
    (Object v) =>
        SemiButtonThemeData(spacingButtonSmallPaddingRight: v as double),
    (SemiResolvedButtonThemeData d) => d.spacingButtonSmallPaddingRight,
  ),
  (
    r'$spacing-button_iconOnly_default-paddingLeft: $spacing-tight',
    7.5,
    (Object v) => SemiButtonThemeData(
      spacingButtonIconOnlyDefaultPaddingLeft: v as double,
    ),
    (SemiResolvedButtonThemeData d) =>
        d.spacingButtonIconOnlyDefaultPaddingLeft,
  ),
  (
    r'$spacing-button_iconOnly_default-paddingRight: $spacing-tight',
    7.5,
    (Object v) => SemiButtonThemeData(
      spacingButtonIconOnlyDefaultPaddingRight: v as double,
    ),
    (SemiResolvedButtonThemeData d) =>
        d.spacingButtonIconOnlyDefaultPaddingRight,
  ),
  (
    r'$spacing-button_iconOnly_default-paddingTop: $spacing-tight',
    7.5,
    (Object v) => SemiButtonThemeData(
      spacingButtonIconOnlyDefaultPaddingTop: v as double,
    ),
    (SemiResolvedButtonThemeData d) => d.spacingButtonIconOnlyDefaultPaddingTop,
  ),
  (
    r'$spacing-button_iconOnly_default-paddingBottom: $spacing-tight',
    7.5,
    (Object v) => SemiButtonThemeData(
      spacingButtonIconOnlyDefaultPaddingBottom: v as double,
    ),
    (SemiResolvedButtonThemeData d) =>
        d.spacingButtonIconOnlyDefaultPaddingBottom,
  ),
  (
    r'$spacing-button_iconOnly_large-paddingLeft: $spacing-base-tight',
    7.5,
    (Object v) =>
        SemiButtonThemeData(spacingButtonIconOnlyLargePaddingLeft: v as double),
    (SemiResolvedButtonThemeData d) => d.spacingButtonIconOnlyLargePaddingLeft,
  ),
  (
    r'$spacing-button_iconOnly_large-paddingRight: $spacing-base-tight',
    7.5,
    (Object v) => SemiButtonThemeData(
      spacingButtonIconOnlyLargePaddingRight: v as double,
    ),
    (SemiResolvedButtonThemeData d) => d.spacingButtonIconOnlyLargePaddingRight,
  ),
  (
    r'$spacing-button_iconOnly_large-paddingTop: $spacing-base-tight',
    7.5,
    (Object v) =>
        SemiButtonThemeData(spacingButtonIconOnlyLargePaddingTop: v as double),
    (SemiResolvedButtonThemeData d) => d.spacingButtonIconOnlyLargePaddingTop,
  ),
  (
    r'$spacing-button_iconOnly_large-paddingBottom: $spacing-base-tight',
    7.5,
    (Object v) => SemiButtonThemeData(
      spacingButtonIconOnlyLargePaddingBottom: v as double,
    ),
    (SemiResolvedButtonThemeData d) =>
        d.spacingButtonIconOnlyLargePaddingBottom,
  ),
  (
    r'$spacing-button_iconOnly_small-paddingLeft: $spacing-extra-tight',
    7.5,
    (Object v) =>
        SemiButtonThemeData(spacingButtonIconOnlySmallPaddingLeft: v as double),
    (SemiResolvedButtonThemeData d) => d.spacingButtonIconOnlySmallPaddingLeft,
  ),
  (
    r'$spacing-button_iconOnly_small-paddingRight: $spacing-extra-tight',
    7.5,
    (Object v) => SemiButtonThemeData(
      spacingButtonIconOnlySmallPaddingRight: v as double,
    ),
    (SemiResolvedButtonThemeData d) => d.spacingButtonIconOnlySmallPaddingRight,
  ),
  (
    r'$spacing-button_iconOnly_small-paddingTop: $spacing-extra-tight',
    7.5,
    (Object v) =>
        SemiButtonThemeData(spacingButtonIconOnlySmallPaddingTop: v as double),
    (SemiResolvedButtonThemeData d) => d.spacingButtonIconOnlySmallPaddingTop,
  ),
  (
    r'$spacing-button_iconOnly_small-paddingBottom: $spacing-extra-tight',
    7.5,
    (Object v) => SemiButtonThemeData(
      spacingButtonIconOnlySmallPaddingBottom: v as double,
    ),
    (SemiResolvedButtonThemeData d) =>
        d.spacingButtonIconOnlySmallPaddingBottom,
  ),
  (
    r'$height-button_iconOnly_small: $height-control-small',
    7.5,
    (Object v) => SemiButtonThemeData(heightButtonIconOnlySmall: v as double),
    (SemiResolvedButtonThemeData d) => d.heightButtonIconOnlySmall,
  ),
  (
    r'$width-button_iconOnly_small: $height-control-small',
    7.5,
    (Object v) => SemiButtonThemeData(widthButtonIconOnlySmall: v as double),
    (SemiResolvedButtonThemeData d) => d.widthButtonIconOnlySmall,
  ),
  (
    r'$height-button_iconOnly_default: $height-control-default',
    7.5,
    (Object v) => SemiButtonThemeData(heightButtonIconOnlyDefault: v as double),
    (SemiResolvedButtonThemeData d) => d.heightButtonIconOnlyDefault,
  ),
  (
    r'$width-button_iconOnly_default: $height-control-default',
    7.5,
    (Object v) => SemiButtonThemeData(widthButtonIconOnlyDefault: v as double),
    (SemiResolvedButtonThemeData d) => d.widthButtonIconOnlyDefault,
  ),
  (
    r'$height-button_iconOnly_large: $height-control-large',
    7.5,
    (Object v) => SemiButtonThemeData(heightButtonIconOnlyLarge: v as double),
    (SemiResolvedButtonThemeData d) => d.heightButtonIconOnlyLarge,
  ),
  (
    r'$width-button_iconOnly_large: $height-control-large',
    7.5,
    (Object v) => SemiButtonThemeData(widthButtonIconOnlyLarge: v as double),
    (SemiResolvedButtonThemeData d) => d.widthButtonIconOnlyLarge,
  ),
  (
    r'$spacing-button_iconOnly_content-marginLeft: $spacing-tight',
    7.5,
    (Object v) => SemiButtonThemeData(
      spacingButtonIconOnlyContentMarginLeft: v as double,
    ),
    (SemiResolvedButtonThemeData d) => d.spacingButtonIconOnlyContentMarginLeft,
  ),
  (
    r'$spacing-button_iconOnly_content-marginRight: $spacing-tight',
    7.5,
    (Object v) => SemiButtonThemeData(
      spacingButtonIconOnlyContentMarginRight: v as double,
    ),
    (SemiResolvedButtonThemeData d) =>
        d.spacingButtonIconOnlyContentMarginRight,
  ),
  (
    r'$font-button-fontWeight: $font-weight-bold',
    FontWeight.w300,
    (Object v) => SemiButtonThemeData(fontButtonFontWeight: v as FontWeight),
    (SemiResolvedButtonThemeData d) => d.fontButtonFontWeight,
  ),
  (
    r'$font-button-fontSize: $font-size-regular',
    7.5,
    (Object v) => SemiButtonThemeData(fontButtonFontSize: v as double),
    (SemiResolvedButtonThemeData d) => d.fontButtonFontSize,
  ),
  (
    r'$font-button-lineHeight: 20px',
    7.5,
    (Object v) => SemiButtonThemeData(fontButtonLineHeight: v as double),
    (SemiResolvedButtonThemeData d) => d.fontButtonLineHeight,
  ),
  (
    r'$font-button_small-fontWeight: $font-weight-bold',
    FontWeight.w300,
    (Object v) =>
        SemiButtonThemeData(fontButtonSmallFontWeight: v as FontWeight),
    (SemiResolvedButtonThemeData d) => d.fontButtonSmallFontWeight,
  ),
  (
    r'$font-button_small-fontSize: $font-size-regular',
    7.5,
    (Object v) => SemiButtonThemeData(fontButtonSmallFontSize: v as double),
    (SemiResolvedButtonThemeData d) => d.fontButtonSmallFontSize,
  ),
  (
    r'$font-button_small-lineHeight: 20px',
    7.5,
    (Object v) => SemiButtonThemeData(fontButtonSmallLineHeight: v as double),
    (SemiResolvedButtonThemeData d) => d.fontButtonSmallLineHeight,
  ),
  (
    r'$font-button_large-fontWeight: $font-weight-bold',
    FontWeight.w300,
    (Object v) =>
        SemiButtonThemeData(fontButtonLargeFontWeight: v as FontWeight),
    (SemiResolvedButtonThemeData d) => d.fontButtonLargeFontWeight,
  ),
  (
    r'$font-button_large-fontSize: $font-size-regular',
    7.5,
    (Object v) => SemiButtonThemeData(fontButtonLargeFontSize: v as double),
    (SemiResolvedButtonThemeData d) => d.fontButtonLargeFontSize,
  ),
  (
    r'$font-button_large-lineHeight: 20px',
    7.5,
    (Object v) => SemiButtonThemeData(fontButtonLargeLineHeight: v as double),
    (SemiResolvedButtonThemeData d) => d.fontButtonLargeLineHeight,
  ),
  (
    r'$height-button_large: $height-control-large',
    7.5,
    (Object v) => SemiButtonThemeData(heightButtonLarge: v as double),
    (SemiResolvedButtonThemeData d) => d.heightButtonLarge,
  ),
  (
    r'$height-button_small: $height-control-small',
    7.5,
    (Object v) => SemiButtonThemeData(heightButtonSmall: v as double),
    (SemiResolvedButtonThemeData d) => d.heightButtonSmall,
  ),
  (
    r'$height-button_default: $height-control-default',
    7.5,
    (Object v) => SemiButtonThemeData(heightButtonDefault: v as double),
    (SemiResolvedButtonThemeData d) => d.heightButtonDefault,
  ),
  (
    r'$height-button_group_line_default: 20px',
    7.5,
    (Object v) =>
        SemiButtonThemeData(heightButtonGroupLineDefault: v as double),
    (SemiResolvedButtonThemeData d) => d.heightButtonGroupLineDefault,
  ),
  (
    r'$width-button-border: $border-thickness',
    7.5,
    (Object v) => SemiButtonThemeData(widthButtonBorder: v as double),
    (SemiResolvedButtonThemeData d) => d.widthButtonBorder,
  ),
  (
    r'$radius-button: var(--semi-border-radius-small)',
    7.5,
    (Object v) => SemiButtonThemeData(radiusButton: v as double),
    (SemiResolvedButtonThemeData d) => d.radiusButton,
  ),
  (
    r'$radius-button_group: $radius-button',
    7.5,
    (Object v) => SemiButtonThemeData(radiusButtonGroup: v as double),
    (SemiResolvedButtonThemeData d) => d.radiusButtonGroup,
  ),
  (
    r'$width-button-outline: 2px',
    7.5,
    (Object v) => SemiButtonThemeData(widthButtonOutline: v as double),
    (SemiResolvedButtonThemeData d) => d.widthButtonOutline,
  ),
  (
    r'$radius-button_splitButtonGroup_first_topLeft: var(--semi-border-radius-small)',
    7.5,
    (Object v) => SemiButtonThemeData(
      radiusButtonSplitButtonGroupFirstTopLeft: v as double,
    ),
    (SemiResolvedButtonThemeData d) =>
        d.radiusButtonSplitButtonGroupFirstTopLeft,
  ),
  (
    r'$radius-button_splitButtonGroup_first_bottomLeft: var(--semi-border-radius-small)',
    7.5,
    (Object v) => SemiButtonThemeData(
      radiusButtonSplitButtonGroupFirstBottomLeft: v as double,
    ),
    (SemiResolvedButtonThemeData d) =>
        d.radiusButtonSplitButtonGroupFirstBottomLeft,
  ),
  (
    r'$radius-button_splitButtonGroup_last_topRight: var(--semi-border-radius-small)',
    7.5,
    (Object v) => SemiButtonThemeData(
      radiusButtonSplitButtonGroupLastTopRight: v as double,
    ),
    (SemiResolvedButtonThemeData d) =>
        d.radiusButtonSplitButtonGroupLastTopRight,
  ),
  (
    r'$radius-button_splitButtonGroup_last_bottomRight: var(--semi-border-radius-small)',
    7.5,
    (Object v) => SemiButtonThemeData(
      radiusButtonSplitButtonGroupLastBottomRight: v as double,
    ),
    (SemiResolvedButtonThemeData d) =>
        d.radiusButtonSplitButtonGroupLastBottomRight,
  ),
  (
    r'$transition_duration-button_primary-bg: var(--semi-transition_duration-none)',
    const Duration(milliseconds: 321),
    (Object v) =>
        SemiButtonThemeData(transitionDurationButtonPrimaryBg: v as Duration),
    (SemiResolvedButtonThemeData d) => d.transitionDurationButtonPrimaryBg,
  ),
  (
    r'$transition_function-button_primary-bg: var(--semi-transition_function-easeIn)',
    Curves.bounceIn,
    (Object v) =>
        SemiButtonThemeData(transitionFunctionButtonPrimaryBg: v as Curve),
    (SemiResolvedButtonThemeData d) => d.transitionFunctionButtonPrimaryBg,
  ),
  (
    r'$transition_delay-button_primary-bg: var(--semi-transition_delay-none)',
    const Duration(milliseconds: 321),
    (Object v) =>
        SemiButtonThemeData(transitionDelayButtonPrimaryBg: v as Duration),
    (SemiResolvedButtonThemeData d) => d.transitionDelayButtonPrimaryBg,
  ),
  (
    r'$transition_duration-button_secondary-bg: var(--semi-transition_duration-none)',
    const Duration(milliseconds: 321),
    (Object v) =>
        SemiButtonThemeData(transitionDurationButtonSecondaryBg: v as Duration),
    (SemiResolvedButtonThemeData d) => d.transitionDurationButtonSecondaryBg,
  ),
  (
    r'$transition_function-button_secondary-bg: var(--semi-transition_function-easeIn)',
    Curves.bounceIn,
    (Object v) =>
        SemiButtonThemeData(transitionFunctionButtonSecondaryBg: v as Curve),
    (SemiResolvedButtonThemeData d) => d.transitionFunctionButtonSecondaryBg,
  ),
  (
    r'$transition_delay-button_secondary-bg: var(--semi-transition_delay-none)',
    const Duration(milliseconds: 321),
    (Object v) =>
        SemiButtonThemeData(transitionDelayButtonSecondaryBg: v as Duration),
    (SemiResolvedButtonThemeData d) => d.transitionDelayButtonSecondaryBg,
  ),
  (
    r'$transition_duration-button_tertiary-bg: var(--semi-transition_duration-none)',
    const Duration(milliseconds: 321),
    (Object v) =>
        SemiButtonThemeData(transitionDurationButtonTertiaryBg: v as Duration),
    (SemiResolvedButtonThemeData d) => d.transitionDurationButtonTertiaryBg,
  ),
  (
    r'$transition_function-button_tertiary-bg: var(--semi-transition_function-easeIn)',
    Curves.bounceIn,
    (Object v) =>
        SemiButtonThemeData(transitionFunctionButtonTertiaryBg: v as Curve),
    (SemiResolvedButtonThemeData d) => d.transitionFunctionButtonTertiaryBg,
  ),
  (
    r'$transition_delay-button_tertiary-bg: var(--semi-transition_delay-none)',
    const Duration(milliseconds: 321),
    (Object v) =>
        SemiButtonThemeData(transitionDelayButtonTertiaryBg: v as Duration),
    (SemiResolvedButtonThemeData d) => d.transitionDelayButtonTertiaryBg,
  ),
  (
    r'$transition_duration-button_light-bg: var(--semi-transition_duration-none)',
    const Duration(milliseconds: 321),
    (Object v) =>
        SemiButtonThemeData(transitionDurationButtonLightBg: v as Duration),
    (SemiResolvedButtonThemeData d) => d.transitionDurationButtonLightBg,
  ),
  (
    r'$transition_function-button_light-bg: var(--semi-transition_function-easeIn)',
    Curves.bounceIn,
    (Object v) =>
        SemiButtonThemeData(transitionFunctionButtonLightBg: v as Curve),
    (SemiResolvedButtonThemeData d) => d.transitionFunctionButtonLightBg,
  ),
  (
    r'$transition_delay-button_light-bg: var(--semi-transition_delay-none)',
    const Duration(milliseconds: 321),
    (Object v) =>
        SemiButtonThemeData(transitionDelayButtonLightBg: v as Duration),
    (SemiResolvedButtonThemeData d) => d.transitionDelayButtonLightBg,
  ),
  (
    r'$transition_duration-button_warning-bg: var(--semi-transition_duration-none)',
    const Duration(milliseconds: 321),
    (Object v) =>
        SemiButtonThemeData(transitionDurationButtonWarningBg: v as Duration),
    (SemiResolvedButtonThemeData d) => d.transitionDurationButtonWarningBg,
  ),
  (
    r'$transition_function-button_warning-bg: var(--semi-transition_function-easeIn)',
    Curves.bounceIn,
    (Object v) =>
        SemiButtonThemeData(transitionFunctionButtonWarningBg: v as Curve),
    (SemiResolvedButtonThemeData d) => d.transitionFunctionButtonWarningBg,
  ),
  (
    r'$transition_delay-button_warning-bg: var(--semi-transition_delay-none)',
    const Duration(milliseconds: 321),
    (Object v) =>
        SemiButtonThemeData(transitionDelayButtonWarningBg: v as Duration),
    (SemiResolvedButtonThemeData d) => d.transitionDelayButtonWarningBg,
  ),
  (
    r'$transition_duration-button_danger-bg: var(--semi-transition_duration-none)',
    const Duration(milliseconds: 321),
    (Object v) =>
        SemiButtonThemeData(transitionDurationButtonDangerBg: v as Duration),
    (SemiResolvedButtonThemeData d) => d.transitionDurationButtonDangerBg,
  ),
  (
    r'$transition_function-button_danger-bg: var(--semi-transition_function-easeIn)',
    Curves.bounceIn,
    (Object v) =>
        SemiButtonThemeData(transitionFunctionButtonDangerBg: v as Curve),
    (SemiResolvedButtonThemeData d) => d.transitionFunctionButtonDangerBg,
  ),
  (
    r'$transition_delay-button_danger-bg: var(--semi-transition_delay-none)',
    const Duration(milliseconds: 321),
    (Object v) =>
        SemiButtonThemeData(transitionDelayButtonDangerBg: v as Duration),
    (SemiResolvedButtonThemeData d) => d.transitionDelayButtonDangerBg,
  ),
  (
    r'$transition_duration-button_borderless-bg: var(--semi-transition_duration-none)',
    const Duration(milliseconds: 321),
    (Object v) => SemiButtonThemeData(
      transitionDurationButtonBorderlessBg: v as Duration,
    ),
    (SemiResolvedButtonThemeData d) => d.transitionDurationButtonBorderlessBg,
  ),
  (
    r'$transition_function-button_borderless-bg: var(--semi-transition_function-easeIn)',
    Curves.bounceIn,
    (Object v) =>
        SemiButtonThemeData(transitionFunctionButtonBorderlessBg: v as Curve),
    (SemiResolvedButtonThemeData d) => d.transitionFunctionButtonBorderlessBg,
  ),
  (
    r'$transition_delay-button_borderless-bg: var(--semi-transition_delay-none)',
    const Duration(milliseconds: 321),
    (Object v) =>
        SemiButtonThemeData(transitionDelayButtonBorderlessBg: v as Duration),
    (SemiResolvedButtonThemeData d) => d.transitionDelayButtonBorderlessBg,
  ),
  (
    r'$transition_duration-button_primary-border: var(--semi-transition_duration-none)',
    const Duration(milliseconds: 321),
    (Object v) => SemiButtonThemeData(
      transitionDurationButtonPrimaryBorder: v as Duration,
    ),
    (SemiResolvedButtonThemeData d) => d.transitionDurationButtonPrimaryBorder,
  ),
  (
    r'$transition_function-button_primary-border: var(--semi-transition_function-easeIn)',
    Curves.bounceIn,
    (Object v) =>
        SemiButtonThemeData(transitionFunctionButtonPrimaryBorder: v as Curve),
    (SemiResolvedButtonThemeData d) => d.transitionFunctionButtonPrimaryBorder,
  ),
  (
    r'$transition_delay-button_primary-border: var(--semi-transition_delay-none)',
    const Duration(milliseconds: 321),
    (Object v) =>
        SemiButtonThemeData(transitionDelayButtonPrimaryBorder: v as Duration),
    (SemiResolvedButtonThemeData d) => d.transitionDelayButtonPrimaryBorder,
  ),
  (
    r'$transition_duration-button_secondary-border: var(--semi-transition_duration-none)',
    const Duration(milliseconds: 321),
    (Object v) => SemiButtonThemeData(
      transitionDurationButtonSecondaryBorder: v as Duration,
    ),
    (SemiResolvedButtonThemeData d) =>
        d.transitionDurationButtonSecondaryBorder,
  ),
  (
    r'$transition_function-button_secondary-border: var(--semi-transition_function-easeIn)',
    Curves.bounceIn,
    (Object v) => SemiButtonThemeData(
      transitionFunctionButtonSecondaryBorder: v as Curve,
    ),
    (SemiResolvedButtonThemeData d) =>
        d.transitionFunctionButtonSecondaryBorder,
  ),
  (
    r'$transition_delay-button_secondary-border: var(--semi-transition_delay-none)',
    const Duration(milliseconds: 321),
    (Object v) => SemiButtonThemeData(
      transitionDelayButtonSecondaryBorder: v as Duration,
    ),
    (SemiResolvedButtonThemeData d) => d.transitionDelayButtonSecondaryBorder,
  ),
  (
    r'$transition_duration-button_tertiary-border: var(--semi-transition_duration-none)',
    const Duration(milliseconds: 321),
    (Object v) => SemiButtonThemeData(
      transitionDurationButtonTertiaryBorder: v as Duration,
    ),
    (SemiResolvedButtonThemeData d) => d.transitionDurationButtonTertiaryBorder,
  ),
  (
    r'$transition_function-button_tertiary-border: var(--semi-transition_function-easeIn)',
    Curves.bounceIn,
    (Object v) =>
        SemiButtonThemeData(transitionFunctionButtonTertiaryBorder: v as Curve),
    (SemiResolvedButtonThemeData d) => d.transitionFunctionButtonTertiaryBorder,
  ),
  (
    r'$transition_delay-button_tertiary-border: var(--semi-transition_delay-none)',
    const Duration(milliseconds: 321),
    (Object v) =>
        SemiButtonThemeData(transitionDelayButtonTertiaryBorder: v as Duration),
    (SemiResolvedButtonThemeData d) => d.transitionDelayButtonTertiaryBorder,
  ),
  (
    r'$transition_duration-button_light-border: var(--semi-transition_duration-none)',
    const Duration(milliseconds: 321),
    (Object v) =>
        SemiButtonThemeData(transitionDurationButtonLightBorder: v as Duration),
    (SemiResolvedButtonThemeData d) => d.transitionDurationButtonLightBorder,
  ),
  (
    r'$transition_function-button_light-border: var(--semi-transition_function-easeIn)',
    Curves.bounceIn,
    (Object v) =>
        SemiButtonThemeData(transitionFunctionButtonLightBorder: v as Curve),
    (SemiResolvedButtonThemeData d) => d.transitionFunctionButtonLightBorder,
  ),
  (
    r'$transition_delay-button_light-border: var(--semi-transition_delay-none)',
    const Duration(milliseconds: 321),
    (Object v) =>
        SemiButtonThemeData(transitionDelayButtonLightBorder: v as Duration),
    (SemiResolvedButtonThemeData d) => d.transitionDelayButtonLightBorder,
  ),
  (
    r'$transition_duration-button_warning-border: var(--semi-transition_duration-none)',
    const Duration(milliseconds: 321),
    (Object v) => SemiButtonThemeData(
      transitionDurationButtonWarningBorder: v as Duration,
    ),
    (SemiResolvedButtonThemeData d) => d.transitionDurationButtonWarningBorder,
  ),
  (
    r'$transition_function-button_warning-border: var(--semi-transition_function-easeIn)',
    Curves.bounceIn,
    (Object v) =>
        SemiButtonThemeData(transitionFunctionButtonWarningBorder: v as Curve),
    (SemiResolvedButtonThemeData d) => d.transitionFunctionButtonWarningBorder,
  ),
  (
    r'$transition_delay-button_warning-border: var(--semi-transition_delay-none)',
    const Duration(milliseconds: 321),
    (Object v) =>
        SemiButtonThemeData(transitionDelayButtonWarningBorder: v as Duration),
    (SemiResolvedButtonThemeData d) => d.transitionDelayButtonWarningBorder,
  ),
  (
    r'$transition_duration-button_danger-border: var(--semi-transition_duration-none)',
    const Duration(milliseconds: 321),
    (Object v) => SemiButtonThemeData(
      transitionDurationButtonDangerBorder: v as Duration,
    ),
    (SemiResolvedButtonThemeData d) => d.transitionDurationButtonDangerBorder,
  ),
  (
    r'$transition_function-button_danger-border: var(--semi-transition_function-easeIn)',
    Curves.bounceIn,
    (Object v) =>
        SemiButtonThemeData(transitionFunctionButtonDangerBorder: v as Curve),
    (SemiResolvedButtonThemeData d) => d.transitionFunctionButtonDangerBorder,
  ),
  (
    r'$transition_delay-button_danger-border: var(--semi-transition_delay-none)',
    const Duration(milliseconds: 321),
    (Object v) =>
        SemiButtonThemeData(transitionDelayButtonDangerBorder: v as Duration),
    (SemiResolvedButtonThemeData d) => d.transitionDelayButtonDangerBorder,
  ),
  (
    r'$transform_scale-button_primary: var(--semi-transform_scale-none)',
    transformSample,
    (Object v) =>
        SemiButtonThemeData(transformScaleButtonPrimary: v as SemiTransform),
    (SemiResolvedButtonThemeData d) => d.transformScaleButtonPrimary,
  ),
  (
    r'$transform_scale-button_secondary: var(--semi-transform_scale-none)',
    transformSample,
    (Object v) =>
        SemiButtonThemeData(transformScaleButtonSecondary: v as SemiTransform),
    (SemiResolvedButtonThemeData d) => d.transformScaleButtonSecondary,
  ),
  (
    r'$transform_scale-button_tertiary: var(--semi-transform_scale-none)',
    transformSample,
    (Object v) =>
        SemiButtonThemeData(transformScaleButtonTertiary: v as SemiTransform),
    (SemiResolvedButtonThemeData d) => d.transformScaleButtonTertiary,
  ),
  (
    r'$transform_scale-button_light: var(--semi-transform_scale-none)',
    transformSample,
    (Object v) =>
        SemiButtonThemeData(transformScaleButtonLight: v as SemiTransform),
    (SemiResolvedButtonThemeData d) => d.transformScaleButtonLight,
  ),
  (
    r'$transform_scale-button_warning: var(--semi-transform_scale-none)',
    transformSample,
    (Object v) =>
        SemiButtonThemeData(transformScaleButtonWarning: v as SemiTransform),
    (SemiResolvedButtonThemeData d) => d.transformScaleButtonWarning,
  ),
  (
    r'$transform_scale-button_danger: var(--semi-transform_scale-none)',
    transformSample,
    (Object v) =>
        SemiButtonThemeData(transformScaleButtonDanger: v as SemiTransform),
    (SemiResolvedButtonThemeData d) => d.transformScaleButtonDanger,
  ),
  (
    r'$transform_scale-button_borderless: var(--semi-transform_scale-none)',
    transformSample,
    (Object v) =>
        SemiButtonThemeData(transformScaleButtonBorderless: v as SemiTransform),
    (SemiResolvedButtonThemeData d) => d.transformScaleButtonBorderless,
  ),
  (
    r'$animation_duration-button_icon_loading: 600ms',
    const Duration(milliseconds: 321),
    (Object v) =>
        SemiButtonThemeData(animationDurationButtonIconLoading: v as Duration),
    (SemiResolvedButtonThemeData d) => d.animationDurationButtonIconLoading,
  ),
  (
    r'$animation_duration-button_icon_customIcon_loading: 1600ms',
    const Duration(milliseconds: 321),
    (Object v) => SemiButtonThemeData(
      animationDurationButtonIconCustomIconLoading: v as Duration,
    ),
    (SemiResolvedButtonThemeData d) =>
        d.animationDurationButtonIconCustomIconLoading,
  ),
];

void main() {
  test('206 fields: merge, copyWith, resolve, equality', () {
    expect(fields, hasLength(206));
    for (final (sass, value, make, read) in fields) {
      final patch = make(value);
      expect(const SemiButtonThemeData().merge(patch), patch, reason: sass);
      expect(patch.copyWith(), patch, reason: sass);
      expect(patch.copyWith().hashCode, patch.hashCode, reason: sass);
      expect(patch.merge(null), patch, reason: sass);
      expect(
        read(patch.resolve(const SemiThemeData.dark())),
        value,
        reason: sass,
      );
      final defaults = const SemiButtonThemeData().resolve(
        const SemiThemeData.light(),
      );
      expect(read(defaults), isNotNull, reason: sass);
      final overridden = const SemiButtonThemeData().resolve(
        const SemiThemeData.dark(),
      );
      expect(read(overridden), isNotNull, reason: sass);
    }
  });

  test('every field carries its Sass provenance in the generated source', () {
    final source = File('lib/src/theme/semi_button_theme_data.dart')
        .readAsStringSync();
    final names = <String>{};
    for (final (sass, _, _, _) in fields) {
      expect(source, contains(sass));
      final name = sass.split(': ').first.substring(1);
      names.add(name);
    }
    expect(names, hasLength(206));
  });

  test('type coverage: 92 Color + 9 SemiGradient + 54 double + 3 FontWeight'
      ' + 28 Duration + 13 Curve + 7 SemiTransform', () {
    final counts = <String, int>{};
    for (final (_, value, _, _) in fields) {
      counts.update(
        value.runtimeType.toString(),
        (n) => n + 1,
        ifAbsent: () => 1,
      );
    }
    expect(counts['Color'], 92);
    expect(counts['SemiGradient'], 9);
    expect(counts['double'], 54);
    expect(counts['FontWeight'], 3);
    expect(counts['Duration'], 28);
    expect(counts['SemiTransform'], 7);
    // Curves.bounceIn is a ParametricCurve; count the remaining 13 by type.
    final curves = fields.where((f) => f.$2 is Curve);
    expect(curves, hasLength(13));
  });

  testWidgets('SemiButtonTheme local patch applies to the button box', (
    tester,
  ) async {
    await tester.pumpWidget(
      SemiTheme(
        data: const SemiThemeData.light(),
        child: SemiButtonTheme(
          data: const SemiButtonThemeData(
            colorButtonPrimaryBgDefault: Color(0xff00ff00),
          ),
          child: Directionality(
            textDirection: TextDirection.ltr,
            child: Center(
              child: SemiButton(
                'x',
                variant: SemiButtonVariant.solid,
                onPressed: () {},
              ),
            ),
          ),
        ),
      ),
    );
    final box = tester.widget<AnimatedContainer>(
      find.byType(AnimatedContainer),
    );
    expect((box.decoration! as BoxDecoration).color, const Color(0xff00ff00));
  });
}
