import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:semi_design_flutter/semi_design_flutter.dart';

void main() {
  test('all 64 resolve nonnull', () {
    final r = const SemiTagThemeData().resolve(const SemiThemeData.light());
    expect(r.colorTagAvatarBgDefault, isNotNull);
    expect(r.colorTagAvatarBorderDefault, isNotNull);
    expect(r.colorTagAvatarTextDefault, isNotNull);
    expect(r.colorTagWhiteBgDefault, isNotNull);
    expect(r.colorTagWhiteBorderDefault, isNotNull);
    expect(r.colorTagWhiteTextDefault, isNotNull);
    expect(r.colorTagWhiteIconDefault, isNotNull);
    expect(r.colorTagOutlineFocus, isNotNull);
    expect(r.colorTagColorfulSolidBg, isNotNull);
    expect(r.colorTagColorfulSolidText, isNotNull);
    expect(r.colorTagColorfulSolidGradientBg, isNotNull);
    expect(r.colorTagColorfulLightBg, isNotNull);
    expect(r.colorTagColorfulLightText, isNotNull);
    expect(r.colorTagColorfulLightGradientBg, isNotNull);
    expect(r.colorTagColorfulLightGradientText, isNotNull);
    expect(r.colorTagColorfulLightGradient1, isNotNull);
    expect(r.colorTagColorfulLightGradient2, isNotNull);
    expect(r.colorTagColorfulLightGradient3, isNotNull);
    expect(r.colorTagColorfulLightGradient4, isNotNull);
    expect(r.colorTagColorfulGhostBg, isNotNull);
    expect(r.colorTagColorfulGhostText, isNotNull);
    expect(r.colorTagColorfulGhostBorder, isNotNull);
    expect(r.colorTagColorfulGhostGradientText, isNotNull);
    expect(r.colorTagColorfulGhostGradient1, isNotNull);
    expect(r.colorTagColorfulGhostGradient2, isNotNull);
    expect(r.colorTagColorfulGhostGradient3, isNotNull);
    expect(r.colorTagColorfulGhostGradient4, isNotNull);
    expect(r.widthTagAvatarCircleSmall, isNotNull);
    expect(r.widthTagAvatarCircleLarge, isNotNull);
    expect(r.widthTagBorder, isNotNull);
    expect(r.widthTagAvatarBorder, isNotNull);
    expect(r.widthTagOutline, isNotNull);
    expect(r.heightTagSmall, isNotNull);
    expect(r.heightTagLarge, isNotNull);
    expect(r.radiusTag, isNotNull);
    expect(r.radiusTagCircle, isNotNull);
    expect(r.spacingTagSmallPaddingY, isNotNull);
    expect(r.spacingTagSmallPaddingX, isNotNull);
    expect(r.spacingTagPrefixIconPaddingRight, isNotNull);
    expect(r.spacingTagSuffixIconPaddingLeft, isNotNull);
    expect(r.spacingTagLargePaddingY, isNotNull);
    expect(r.spacingTagLargePaddingX, isNotNull);
    expect(r.colorTagCloseIconDefault, isNotNull);
    expect(r.colorTagCloseIconHover, isNotNull);
    expect(r.colorTagCloseIconActive, isNotNull);
    expect(r.colorTagCloseIconDeepDefault, isNotNull);
    expect(r.spacingTagClosePaddingLeft, isNotNull);
    expect(r.spacingTagClosablePaddingTop, isNotNull);
    expect(r.spacingTagClosablePaddingRight, isNotNull);
    expect(r.spacingTagClosablePaddingBottom, isNotNull);
    expect(r.spacingTagClosablePaddingLeft, isNotNull);
    expect(r.spacingTagAvatarMarginRight, isNotNull);
    expect(r.spacingTagAvatarSquarePaddingTop, isNotNull);
    expect(r.spacingTagAvatarSquarePaddingRight, isNotNull);
    expect(r.spacingTagAvatarSquarePaddingBottom, isNotNull);
    expect(r.spacingTagAvatarSquarePaddingLeft, isNotNull);
    expect(r.spacingTagAvatarCirclePaddingTop, isNotNull);
    expect(r.spacingTagAvatarCirclePaddingRight, isNotNull);
    expect(r.spacingTagAvatarCirclePaddingBottom, isNotNull);
    expect(r.spacingTagAvatarCirclePaddingLeft, isNotNull);
    expect(r.colorTagAvatarSquareImgBgDefault, isNotNull);
    expect(r.spacingTagGroupMarginBottom, isNotNull);
    expect(r.spacingTagGroupMarginRight, isNotNull);
    expect(r.fontTagColorfulFontWeight, isNotNull);
  });
  test('color-tag_avatar-bg-default merge copy equality', () {
    final value = const Color(0xff123456);
    final patch = SemiTagThemeData(colorTagAvatarBgDefault: value);
    expect(const SemiTagThemeData().merge(patch), patch);
    expect(patch.copyWith(), patch);
    expect(patch.copyWith().hashCode, patch.hashCode);
    expect(
      patch.resolve(const SemiThemeData.dark()).colorTagAvatarBgDefault,
      value,
    );
  });
  test('color-tag_avatar-border-default merge copy equality', () {
    final value = const Color(0xff123456);
    final patch = SemiTagThemeData(colorTagAvatarBorderDefault: value);
    expect(const SemiTagThemeData().merge(patch), patch);
    expect(patch.copyWith(), patch);
    expect(patch.copyWith().hashCode, patch.hashCode);
    expect(
      patch.resolve(const SemiThemeData.dark()).colorTagAvatarBorderDefault,
      value,
    );
  });
  test('color-tag_avatar-text-default merge copy equality', () {
    final value = const Color(0xff123456);
    final patch = SemiTagThemeData(colorTagAvatarTextDefault: value);
    expect(const SemiTagThemeData().merge(patch), patch);
    expect(patch.copyWith(), patch);
    expect(patch.copyWith().hashCode, patch.hashCode);
    expect(
      patch.resolve(const SemiThemeData.dark()).colorTagAvatarTextDefault,
      value,
    );
  });
  test('color-tag_white-bg-default merge copy equality', () {
    final value = const Color(0xff123456);
    final patch = SemiTagThemeData(colorTagWhiteBgDefault: value);
    expect(const SemiTagThemeData().merge(patch), patch);
    expect(patch.copyWith(), patch);
    expect(patch.copyWith().hashCode, patch.hashCode);
    expect(
      patch.resolve(const SemiThemeData.dark()).colorTagWhiteBgDefault,
      value,
    );
  });
  test('color-tag_white-border-default merge copy equality', () {
    final value = const Color(0xff123456);
    final patch = SemiTagThemeData(colorTagWhiteBorderDefault: value);
    expect(const SemiTagThemeData().merge(patch), patch);
    expect(patch.copyWith(), patch);
    expect(patch.copyWith().hashCode, patch.hashCode);
    expect(
      patch.resolve(const SemiThemeData.dark()).colorTagWhiteBorderDefault,
      value,
    );
  });
  test('color-tag_white-text-default merge copy equality', () {
    final value = const Color(0xff123456);
    final patch = SemiTagThemeData(colorTagWhiteTextDefault: value);
    expect(const SemiTagThemeData().merge(patch), patch);
    expect(patch.copyWith(), patch);
    expect(patch.copyWith().hashCode, patch.hashCode);
    expect(
      patch.resolve(const SemiThemeData.dark()).colorTagWhiteTextDefault,
      value,
    );
  });
  test('color-tag_white-icon-default merge copy equality', () {
    final value = const Color(0xff123456);
    final patch = SemiTagThemeData(colorTagWhiteIconDefault: value);
    expect(const SemiTagThemeData().merge(patch), patch);
    expect(patch.copyWith(), patch);
    expect(patch.copyWith().hashCode, patch.hashCode);
    expect(
      patch.resolve(const SemiThemeData.dark()).colorTagWhiteIconDefault,
      value,
    );
  });
  test('color-tag-outline-focus merge copy equality', () {
    final value = const Color(0xff123456);
    final patch = SemiTagThemeData(colorTagOutlineFocus: value);
    expect(const SemiTagThemeData().merge(patch), patch);
    expect(patch.copyWith(), patch);
    expect(patch.copyWith().hashCode, patch.hashCode);
    expect(
      patch.resolve(const SemiThemeData.dark()).colorTagOutlineFocus,
      value,
    );
  });
  test('color-tag_colorful_solid-bg merge copy equality', () {
    final value = const Color(0xff123456);
    final patch = SemiTagThemeData(colorTagColorfulSolidBg: value);
    expect(const SemiTagThemeData().merge(patch), patch);
    expect(patch.copyWith(), patch);
    expect(patch.copyWith().hashCode, patch.hashCode);
    expect(
      patch.resolve(const SemiThemeData.dark()).colorTagColorfulSolidBg,
      value,
    );
  });
  test('color-tag_colorful_solid-text merge copy equality', () {
    final value = const Color(0xff123456);
    final patch = SemiTagThemeData(colorTagColorfulSolidText: value);
    expect(const SemiTagThemeData().merge(patch), patch);
    expect(patch.copyWith(), patch);
    expect(patch.copyWith().hashCode, patch.hashCode);
    expect(
      patch.resolve(const SemiThemeData.dark()).colorTagColorfulSolidText,
      value,
    );
  });
  test('color-tag_colorful_solid_gradient-bg merge copy equality', () {
    final value = SemiGradient(
      45,
      [const Color(0xff000000), const Color(0xffffffff)],
      [0, 1],
    );
    final patch = SemiTagThemeData(colorTagColorfulSolidGradientBg: value);
    expect(const SemiTagThemeData().merge(patch), patch);
    expect(patch.copyWith(), patch);
    expect(patch.copyWith().hashCode, patch.hashCode);
    expect(
      patch.resolve(const SemiThemeData.dark()).colorTagColorfulSolidGradientBg,
      value,
    );
  });
  test('color-tag_colorful_light-bg merge copy equality', () {
    final value = const Color(0xff123456);
    final patch = SemiTagThemeData(colorTagColorfulLightBg: value);
    expect(const SemiTagThemeData().merge(patch), patch);
    expect(patch.copyWith(), patch);
    expect(patch.copyWith().hashCode, patch.hashCode);
    expect(
      patch.resolve(const SemiThemeData.dark()).colorTagColorfulLightBg,
      value,
    );
  });
  test('color-tag_colorful_light-text merge copy equality', () {
    final value = const Color(0xff123456);
    final patch = SemiTagThemeData(colorTagColorfulLightText: value);
    expect(const SemiTagThemeData().merge(patch), patch);
    expect(patch.copyWith(), patch);
    expect(patch.copyWith().hashCode, patch.hashCode);
    expect(
      patch.resolve(const SemiThemeData.dark()).colorTagColorfulLightText,
      value,
    );
  });
  test('color-tag_colorful_light_gradient-bg merge copy equality', () {
    final value = SemiGradient(
      45,
      [const Color(0xff000000), const Color(0xffffffff)],
      [0, 1],
    );
    final patch = SemiTagThemeData(colorTagColorfulLightGradientBg: value);
    expect(const SemiTagThemeData().merge(patch), patch);
    expect(patch.copyWith(), patch);
    expect(patch.copyWith().hashCode, patch.hashCode);
    expect(
      patch.resolve(const SemiThemeData.dark()).colorTagColorfulLightGradientBg,
      value,
    );
  });
  test('color-tag_colorful_light_gradient-text merge copy equality', () {
    final value = SemiGradient(
      45,
      [const Color(0xff000000), const Color(0xffffffff)],
      [0, 1],
    );
    final patch = SemiTagThemeData(colorTagColorfulLightGradientText: value);
    expect(const SemiTagThemeData().merge(patch), patch);
    expect(patch.copyWith(), patch);
    expect(patch.copyWith().hashCode, patch.hashCode);
    expect(
      patch
          .resolve(const SemiThemeData.dark())
          .colorTagColorfulLightGradientText,
      value,
    );
  });
  test('color-tag_colorful_light_gradient-1 merge copy equality', () {
    final value = const Color(0xff123456);
    final patch = SemiTagThemeData(colorTagColorfulLightGradient1: value);
    expect(const SemiTagThemeData().merge(patch), patch);
    expect(patch.copyWith(), patch);
    expect(patch.copyWith().hashCode, patch.hashCode);
    expect(
      patch.resolve(const SemiThemeData.dark()).colorTagColorfulLightGradient1,
      value,
    );
  });
  test('color-tag_colorful_light_gradient-2 merge copy equality', () {
    final value = const Color(0xff123456);
    final patch = SemiTagThemeData(colorTagColorfulLightGradient2: value);
    expect(const SemiTagThemeData().merge(patch), patch);
    expect(patch.copyWith(), patch);
    expect(patch.copyWith().hashCode, patch.hashCode);
    expect(
      patch.resolve(const SemiThemeData.dark()).colorTagColorfulLightGradient2,
      value,
    );
  });
  test('color-tag_colorful_light_gradient-3 merge copy equality', () {
    final value = const Color(0xff123456);
    final patch = SemiTagThemeData(colorTagColorfulLightGradient3: value);
    expect(const SemiTagThemeData().merge(patch), patch);
    expect(patch.copyWith(), patch);
    expect(patch.copyWith().hashCode, patch.hashCode);
    expect(
      patch.resolve(const SemiThemeData.dark()).colorTagColorfulLightGradient3,
      value,
    );
  });
  test('color-tag_colorful_light_gradient-4 merge copy equality', () {
    final value = const Color(0xff123456);
    final patch = SemiTagThemeData(colorTagColorfulLightGradient4: value);
    expect(const SemiTagThemeData().merge(patch), patch);
    expect(patch.copyWith(), patch);
    expect(patch.copyWith().hashCode, patch.hashCode);
    expect(
      patch.resolve(const SemiThemeData.dark()).colorTagColorfulLightGradient4,
      value,
    );
  });
  test('color-tag_colorful_ghost-bg merge copy equality', () {
    final value = const Color(0xff123456);
    final patch = SemiTagThemeData(colorTagColorfulGhostBg: value);
    expect(const SemiTagThemeData().merge(patch), patch);
    expect(patch.copyWith(), patch);
    expect(patch.copyWith().hashCode, patch.hashCode);
    expect(
      patch.resolve(const SemiThemeData.dark()).colorTagColorfulGhostBg,
      value,
    );
  });
  test('color-tag_colorful_ghost-text merge copy equality', () {
    final value = const Color(0xff123456);
    final patch = SemiTagThemeData(colorTagColorfulGhostText: value);
    expect(const SemiTagThemeData().merge(patch), patch);
    expect(patch.copyWith(), patch);
    expect(patch.copyWith().hashCode, patch.hashCode);
    expect(
      patch.resolve(const SemiThemeData.dark()).colorTagColorfulGhostText,
      value,
    );
  });
  test('color-tag_colorful_ghost-border merge copy equality', () {
    final value = SemiGradient(
      45,
      [const Color(0xff000000), const Color(0xffffffff)],
      [0, 1],
    );
    final patch = SemiTagThemeData(colorTagColorfulGhostBorder: value);
    expect(const SemiTagThemeData().merge(patch), patch);
    expect(patch.copyWith(), patch);
    expect(patch.copyWith().hashCode, patch.hashCode);
    expect(
      patch.resolve(const SemiThemeData.dark()).colorTagColorfulGhostBorder,
      value,
    );
  });
  test('color-tag_colorful_ghost_gradient-text merge copy equality', () {
    final value = SemiGradient(
      45,
      [const Color(0xff000000), const Color(0xffffffff)],
      [0, 1],
    );
    final patch = SemiTagThemeData(colorTagColorfulGhostGradientText: value);
    expect(const SemiTagThemeData().merge(patch), patch);
    expect(patch.copyWith(), patch);
    expect(patch.copyWith().hashCode, patch.hashCode);
    expect(
      patch
          .resolve(const SemiThemeData.dark())
          .colorTagColorfulGhostGradientText,
      value,
    );
  });
  test('color-tag_colorful_ghost_gradient-1 merge copy equality', () {
    final value = const Color(0xff123456);
    final patch = SemiTagThemeData(colorTagColorfulGhostGradient1: value);
    expect(const SemiTagThemeData().merge(patch), patch);
    expect(patch.copyWith(), patch);
    expect(patch.copyWith().hashCode, patch.hashCode);
    expect(
      patch.resolve(const SemiThemeData.dark()).colorTagColorfulGhostGradient1,
      value,
    );
  });
  test('color-tag_colorful_ghost_gradient-2 merge copy equality', () {
    final value = const Color(0xff123456);
    final patch = SemiTagThemeData(colorTagColorfulGhostGradient2: value);
    expect(const SemiTagThemeData().merge(patch), patch);
    expect(patch.copyWith(), patch);
    expect(patch.copyWith().hashCode, patch.hashCode);
    expect(
      patch.resolve(const SemiThemeData.dark()).colorTagColorfulGhostGradient2,
      value,
    );
  });
  test('color-tag_colorful_ghost_gradient-3 merge copy equality', () {
    final value = const Color(0xff123456);
    final patch = SemiTagThemeData(colorTagColorfulGhostGradient3: value);
    expect(const SemiTagThemeData().merge(patch), patch);
    expect(patch.copyWith(), patch);
    expect(patch.copyWith().hashCode, patch.hashCode);
    expect(
      patch.resolve(const SemiThemeData.dark()).colorTagColorfulGhostGradient3,
      value,
    );
  });
  test('color-tag_colorful_ghost_gradient-4 merge copy equality', () {
    final value = const Color(0xff123456);
    final patch = SemiTagThemeData(colorTagColorfulGhostGradient4: value);
    expect(const SemiTagThemeData().merge(patch), patch);
    expect(patch.copyWith(), patch);
    expect(patch.copyWith().hashCode, patch.hashCode);
    expect(
      patch.resolve(const SemiThemeData.dark()).colorTagColorfulGhostGradient4,
      value,
    );
  });
  test('width-tag_avatar_circle_small merge copy equality', () {
    final value = 7.0;
    final patch = SemiTagThemeData(widthTagAvatarCircleSmall: value);
    expect(const SemiTagThemeData().merge(patch), patch);
    expect(patch.copyWith(), patch);
    expect(patch.copyWith().hashCode, patch.hashCode);
    expect(
      patch.resolve(const SemiThemeData.dark()).widthTagAvatarCircleSmall,
      value,
    );
  });
  test('width-tag_avatar_circle_large merge copy equality', () {
    final value = 7.0;
    final patch = SemiTagThemeData(widthTagAvatarCircleLarge: value);
    expect(const SemiTagThemeData().merge(patch), patch);
    expect(patch.copyWith(), patch);
    expect(patch.copyWith().hashCode, patch.hashCode);
    expect(
      patch.resolve(const SemiThemeData.dark()).widthTagAvatarCircleLarge,
      value,
    );
  });
  test('width-tag-border merge copy equality', () {
    final value = 7.0;
    final patch = SemiTagThemeData(widthTagBorder: value);
    expect(const SemiTagThemeData().merge(patch), patch);
    expect(patch.copyWith(), patch);
    expect(patch.copyWith().hashCode, patch.hashCode);
    expect(patch.resolve(const SemiThemeData.dark()).widthTagBorder, value);
  });
  test('width-tag_avatar-border merge copy equality', () {
    final value = 7.0;
    final patch = SemiTagThemeData(widthTagAvatarBorder: value);
    expect(const SemiTagThemeData().merge(patch), patch);
    expect(patch.copyWith(), patch);
    expect(patch.copyWith().hashCode, patch.hashCode);
    expect(
      patch.resolve(const SemiThemeData.dark()).widthTagAvatarBorder,
      value,
    );
  });
  test('width-tag-outline merge copy equality', () {
    final value = 7.0;
    final patch = SemiTagThemeData(widthTagOutline: value);
    expect(const SemiTagThemeData().merge(patch), patch);
    expect(patch.copyWith(), patch);
    expect(patch.copyWith().hashCode, patch.hashCode);
    expect(patch.resolve(const SemiThemeData.dark()).widthTagOutline, value);
  });
  test('height-tag_small merge copy equality', () {
    final value = 7.0;
    final patch = SemiTagThemeData(heightTagSmall: value);
    expect(const SemiTagThemeData().merge(patch), patch);
    expect(patch.copyWith(), patch);
    expect(patch.copyWith().hashCode, patch.hashCode);
    expect(patch.resolve(const SemiThemeData.dark()).heightTagSmall, value);
  });
  test('height-tag_large merge copy equality', () {
    final value = 7.0;
    final patch = SemiTagThemeData(heightTagLarge: value);
    expect(const SemiTagThemeData().merge(patch), patch);
    expect(patch.copyWith(), patch);
    expect(patch.copyWith().hashCode, patch.hashCode);
    expect(patch.resolve(const SemiThemeData.dark()).heightTagLarge, value);
  });
  test('radius-tag merge copy equality', () {
    final value = 7.0;
    final patch = SemiTagThemeData(radiusTag: value);
    expect(const SemiTagThemeData().merge(patch), patch);
    expect(patch.copyWith(), patch);
    expect(patch.copyWith().hashCode, patch.hashCode);
    expect(patch.resolve(const SemiThemeData.dark()).radiusTag, value);
  });
  test('radius-tag_circle merge copy equality', () {
    final value = 7.0;
    final patch = SemiTagThemeData(radiusTagCircle: value);
    expect(const SemiTagThemeData().merge(patch), patch);
    expect(patch.copyWith(), patch);
    expect(patch.copyWith().hashCode, patch.hashCode);
    expect(patch.resolve(const SemiThemeData.dark()).radiusTagCircle, value);
  });
  test('spacing-tag_small-paddingY merge copy equality', () {
    final value = 7.0;
    final patch = SemiTagThemeData(spacingTagSmallPaddingY: value);
    expect(const SemiTagThemeData().merge(patch), patch);
    expect(patch.copyWith(), patch);
    expect(patch.copyWith().hashCode, patch.hashCode);
    expect(
      patch.resolve(const SemiThemeData.dark()).spacingTagSmallPaddingY,
      value,
    );
  });
  test('spacing-tag_small-paddingX merge copy equality', () {
    final value = 7.0;
    final patch = SemiTagThemeData(spacingTagSmallPaddingX: value);
    expect(const SemiTagThemeData().merge(patch), patch);
    expect(patch.copyWith(), patch);
    expect(patch.copyWith().hashCode, patch.hashCode);
    expect(
      patch.resolve(const SemiThemeData.dark()).spacingTagSmallPaddingX,
      value,
    );
  });
  test('spacing-tag_prefix_icon_paddingRight merge copy equality', () {
    final value = 7.0;
    final patch = SemiTagThemeData(spacingTagPrefixIconPaddingRight: value);
    expect(const SemiTagThemeData().merge(patch), patch);
    expect(patch.copyWith(), patch);
    expect(patch.copyWith().hashCode, patch.hashCode);
    expect(
      patch
          .resolve(const SemiThemeData.dark())
          .spacingTagPrefixIconPaddingRight,
      value,
    );
  });
  test('spacing-tag_suffix_icon_paddingLeft merge copy equality', () {
    final value = 7.0;
    final patch = SemiTagThemeData(spacingTagSuffixIconPaddingLeft: value);
    expect(const SemiTagThemeData().merge(patch), patch);
    expect(patch.copyWith(), patch);
    expect(patch.copyWith().hashCode, patch.hashCode);
    expect(
      patch.resolve(const SemiThemeData.dark()).spacingTagSuffixIconPaddingLeft,
      value,
    );
  });
  test('spacing-tag_large-paddingY merge copy equality', () {
    final value = 7.0;
    final patch = SemiTagThemeData(spacingTagLargePaddingY: value);
    expect(const SemiTagThemeData().merge(patch), patch);
    expect(patch.copyWith(), patch);
    expect(patch.copyWith().hashCode, patch.hashCode);
    expect(
      patch.resolve(const SemiThemeData.dark()).spacingTagLargePaddingY,
      value,
    );
  });
  test('spacing-tag_large-paddingX merge copy equality', () {
    final value = 7.0;
    final patch = SemiTagThemeData(spacingTagLargePaddingX: value);
    expect(const SemiTagThemeData().merge(patch), patch);
    expect(patch.copyWith(), patch);
    expect(patch.copyWith().hashCode, patch.hashCode);
    expect(
      patch.resolve(const SemiThemeData.dark()).spacingTagLargePaddingX,
      value,
    );
  });
  test('color-tag_close-icon-default merge copy equality', () {
    final value = const Color(0xff123456);
    final patch = SemiTagThemeData(colorTagCloseIconDefault: value);
    expect(const SemiTagThemeData().merge(patch), patch);
    expect(patch.copyWith(), patch);
    expect(patch.copyWith().hashCode, patch.hashCode);
    expect(
      patch.resolve(const SemiThemeData.dark()).colorTagCloseIconDefault,
      value,
    );
  });
  test('color-tag_close-icon-hover merge copy equality', () {
    final value = const Color(0xff123456);
    final patch = SemiTagThemeData(colorTagCloseIconHover: value);
    expect(const SemiTagThemeData().merge(patch), patch);
    expect(patch.copyWith(), patch);
    expect(patch.copyWith().hashCode, patch.hashCode);
    expect(
      patch.resolve(const SemiThemeData.dark()).colorTagCloseIconHover,
      value,
    );
  });
  test('color-tag_close-icon-active merge copy equality', () {
    final value = const Color(0xff123456);
    final patch = SemiTagThemeData(colorTagCloseIconActive: value);
    expect(const SemiTagThemeData().merge(patch), patch);
    expect(patch.copyWith(), patch);
    expect(patch.copyWith().hashCode, patch.hashCode);
    expect(
      patch.resolve(const SemiThemeData.dark()).colorTagCloseIconActive,
      value,
    );
  });
  test('color-tag_close-icon_deep-default merge copy equality', () {
    final value = const Color(0xff123456);
    final patch = SemiTagThemeData(colorTagCloseIconDeepDefault: value);
    expect(const SemiTagThemeData().merge(patch), patch);
    expect(patch.copyWith(), patch);
    expect(patch.copyWith().hashCode, patch.hashCode);
    expect(
      patch.resolve(const SemiThemeData.dark()).colorTagCloseIconDeepDefault,
      value,
    );
  });
  test('spacing-tag_close-paddingLeft merge copy equality', () {
    final value = 7.0;
    final patch = SemiTagThemeData(spacingTagClosePaddingLeft: value);
    expect(const SemiTagThemeData().merge(patch), patch);
    expect(patch.copyWith(), patch);
    expect(patch.copyWith().hashCode, patch.hashCode);
    expect(
      patch.resolve(const SemiThemeData.dark()).spacingTagClosePaddingLeft,
      value,
    );
  });
  test('spacing-tag_closable-paddingTop merge copy equality', () {
    final value = 7.0;
    final patch = SemiTagThemeData(spacingTagClosablePaddingTop: value);
    expect(const SemiTagThemeData().merge(patch), patch);
    expect(patch.copyWith(), patch);
    expect(patch.copyWith().hashCode, patch.hashCode);
    expect(
      patch.resolve(const SemiThemeData.dark()).spacingTagClosablePaddingTop,
      value,
    );
  });
  test('spacing-tag_closable-paddingRight merge copy equality', () {
    final value = 7.0;
    final patch = SemiTagThemeData(spacingTagClosablePaddingRight: value);
    expect(const SemiTagThemeData().merge(patch), patch);
    expect(patch.copyWith(), patch);
    expect(patch.copyWith().hashCode, patch.hashCode);
    expect(
      patch.resolve(const SemiThemeData.dark()).spacingTagClosablePaddingRight,
      value,
    );
  });
  test('spacing-tag_closable-paddingBottom merge copy equality', () {
    final value = 7.0;
    final patch = SemiTagThemeData(spacingTagClosablePaddingBottom: value);
    expect(const SemiTagThemeData().merge(patch), patch);
    expect(patch.copyWith(), patch);
    expect(patch.copyWith().hashCode, patch.hashCode);
    expect(
      patch.resolve(const SemiThemeData.dark()).spacingTagClosablePaddingBottom,
      value,
    );
  });
  test('spacing-tag_closable-paddingLeft merge copy equality', () {
    final value = 7.0;
    final patch = SemiTagThemeData(spacingTagClosablePaddingLeft: value);
    expect(const SemiTagThemeData().merge(patch), patch);
    expect(patch.copyWith(), patch);
    expect(patch.copyWith().hashCode, patch.hashCode);
    expect(
      patch.resolve(const SemiThemeData.dark()).spacingTagClosablePaddingLeft,
      value,
    );
  });
  test('spacing-tag_avatar-marginRight merge copy equality', () {
    final value = 7.0;
    final patch = SemiTagThemeData(spacingTagAvatarMarginRight: value);
    expect(const SemiTagThemeData().merge(patch), patch);
    expect(patch.copyWith(), patch);
    expect(patch.copyWith().hashCode, patch.hashCode);
    expect(
      patch.resolve(const SemiThemeData.dark()).spacingTagAvatarMarginRight,
      value,
    );
  });
  test('spacing-tag_avatar_square-paddingTop merge copy equality', () {
    final value = 7.0;
    final patch = SemiTagThemeData(spacingTagAvatarSquarePaddingTop: value);
    expect(const SemiTagThemeData().merge(patch), patch);
    expect(patch.copyWith(), patch);
    expect(patch.copyWith().hashCode, patch.hashCode);
    expect(
      patch
          .resolve(const SemiThemeData.dark())
          .spacingTagAvatarSquarePaddingTop,
      value,
    );
  });
  test('spacing-tag_avatar_square-paddingRight merge copy equality', () {
    final value = 7.0;
    final patch = SemiTagThemeData(spacingTagAvatarSquarePaddingRight: value);
    expect(const SemiTagThemeData().merge(patch), patch);
    expect(patch.copyWith(), patch);
    expect(patch.copyWith().hashCode, patch.hashCode);
    expect(
      patch
          .resolve(const SemiThemeData.dark())
          .spacingTagAvatarSquarePaddingRight,
      value,
    );
  });
  test('spacing-tag_avatar_square-paddingBottom merge copy equality', () {
    final value = 7.0;
    final patch = SemiTagThemeData(spacingTagAvatarSquarePaddingBottom: value);
    expect(const SemiTagThemeData().merge(patch), patch);
    expect(patch.copyWith(), patch);
    expect(patch.copyWith().hashCode, patch.hashCode);
    expect(
      patch
          .resolve(const SemiThemeData.dark())
          .spacingTagAvatarSquarePaddingBottom,
      value,
    );
  });
  test('spacing-tag_avatar_square-paddingLeft merge copy equality', () {
    final value = 7.0;
    final patch = SemiTagThemeData(spacingTagAvatarSquarePaddingLeft: value);
    expect(const SemiTagThemeData().merge(patch), patch);
    expect(patch.copyWith(), patch);
    expect(patch.copyWith().hashCode, patch.hashCode);
    expect(
      patch
          .resolve(const SemiThemeData.dark())
          .spacingTagAvatarSquarePaddingLeft,
      value,
    );
  });
  test('spacing-tag_avatar_circle-paddingTop merge copy equality', () {
    final value = 7.0;
    final patch = SemiTagThemeData(spacingTagAvatarCirclePaddingTop: value);
    expect(const SemiTagThemeData().merge(patch), patch);
    expect(patch.copyWith(), patch);
    expect(patch.copyWith().hashCode, patch.hashCode);
    expect(
      patch
          .resolve(const SemiThemeData.dark())
          .spacingTagAvatarCirclePaddingTop,
      value,
    );
  });
  test('spacing-tag_avatar_circle-paddingRight merge copy equality', () {
    final value = 7.0;
    final patch = SemiTagThemeData(spacingTagAvatarCirclePaddingRight: value);
    expect(const SemiTagThemeData().merge(patch), patch);
    expect(patch.copyWith(), patch);
    expect(patch.copyWith().hashCode, patch.hashCode);
    expect(
      patch
          .resolve(const SemiThemeData.dark())
          .spacingTagAvatarCirclePaddingRight,
      value,
    );
  });
  test('spacing-tag_avatar_circle-paddingBottom merge copy equality', () {
    final value = 7.0;
    final patch = SemiTagThemeData(spacingTagAvatarCirclePaddingBottom: value);
    expect(const SemiTagThemeData().merge(patch), patch);
    expect(patch.copyWith(), patch);
    expect(patch.copyWith().hashCode, patch.hashCode);
    expect(
      patch
          .resolve(const SemiThemeData.dark())
          .spacingTagAvatarCirclePaddingBottom,
      value,
    );
  });
  test('spacing-tag_avatar_circle-paddingLeft merge copy equality', () {
    final value = 7.0;
    final patch = SemiTagThemeData(spacingTagAvatarCirclePaddingLeft: value);
    expect(const SemiTagThemeData().merge(patch), patch);
    expect(patch.copyWith(), patch);
    expect(patch.copyWith().hashCode, patch.hashCode);
    expect(
      patch
          .resolve(const SemiThemeData.dark())
          .spacingTagAvatarCirclePaddingLeft,
      value,
    );
  });
  test('color-tag_avatar_square_img-bg-default merge copy equality', () {
    final value = const Color(0xff123456);
    final patch = SemiTagThemeData(colorTagAvatarSquareImgBgDefault: value);
    expect(const SemiTagThemeData().merge(patch), patch);
    expect(patch.copyWith(), patch);
    expect(patch.copyWith().hashCode, patch.hashCode);
    expect(
      patch
          .resolve(const SemiThemeData.dark())
          .colorTagAvatarSquareImgBgDefault,
      value,
    );
  });
  test('spacing-tag_group-marginBottom merge copy equality', () {
    final value = 7.0;
    final patch = SemiTagThemeData(spacingTagGroupMarginBottom: value);
    expect(const SemiTagThemeData().merge(patch), patch);
    expect(patch.copyWith(), patch);
    expect(patch.copyWith().hashCode, patch.hashCode);
    expect(
      patch.resolve(const SemiThemeData.dark()).spacingTagGroupMarginBottom,
      value,
    );
  });
  test('spacing-tag_group-marginRight merge copy equality', () {
    final value = 7.0;
    final patch = SemiTagThemeData(spacingTagGroupMarginRight: value);
    expect(const SemiTagThemeData().merge(patch), patch);
    expect(patch.copyWith(), patch);
    expect(patch.copyWith().hashCode, patch.hashCode);
    expect(
      patch.resolve(const SemiThemeData.dark()).spacingTagGroupMarginRight,
      value,
    );
  });
  test('font-tag_colorful-fontWeight merge copy equality', () {
    final value = FontWeight.w300;
    final patch = SemiTagThemeData(fontTagColorfulFontWeight: value);
    expect(const SemiTagThemeData().merge(patch), patch);
    expect(patch.copyWith(), patch);
    expect(patch.copyWith().hashCode, patch.hashCode);
    expect(
      patch.resolve(const SemiThemeData.dark()).fontTagColorfulFontWeight,
      value,
    );
  });
}
