// Matrix coverage for the 52 generated theme fields (44 FIELDS + 8 MOTION +
// 0 INTERNAL): defaults, overrides, merge, copyWith, resolve, equality and
// per-field Sass provenance. 8 dead fields stay in the theme and out of the
// widget. See docs/semi_image.md.
import 'dart:io';

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:semi_design_flutter/semi_design_flutter.dart';

typedef _Patch = SemiImageThemeData Function(Object value);
typedef _Read = Object? Function(SemiResolvedImageThemeData data);

final List<(String, Object, _Patch, _Read)> fields = [
  (
    r'$spacing-image_mask_info_text-marginTop: 8px',
    37.0,
    (v) => SemiImageThemeData(spacingImageMaskInfoTextMarginTop: v as double),
    (d) => d.spacingImageMaskInfoTextMarginTop,
  ),
  (
    r'$spacing-image_preview_icon-x: 24px',
    37.0,
    (v) => SemiImageThemeData(spacingImagePreviewIconX: v as double),
    (d) => d.spacingImagePreviewIconX,
  ),
  (
    r'$spacing-image_preview_header-paddingY: 0',
    37.0,
    (v) => SemiImageThemeData(spacingImagePreviewHeaderPaddingY: v as double),
    (d) => d.spacingImagePreviewHeaderPaddingY,
  ),
  (
    r'$spacing-image_preview_header-paddingX: 24px',
    37.0,
    (v) => SemiImageThemeData(spacingImagePreviewHeaderPaddingX: v as double),
    (d) => d.spacingImagePreviewHeaderPaddingX,
  ),
  (
    r'$spacing-image_preview_footer-paddingY: 0',
    37.0,
    (v) => SemiImageThemeData(spacingImagePreviewFooterPaddingY: v as double),
    (d) => d.spacingImagePreviewFooterPaddingY,
  ),
  (
    r'$spacing-image_preview_footer-paddingX: 16px',
    37.0,
    (v) => SemiImageThemeData(spacingImagePreviewFooterPaddingX: v as double),
    (d) => d.spacingImagePreviewFooterPaddingX,
  ),
  (
    r'$spacing-image_preview_footer_page-marginY: 0',
    37.0,
    (v) =>
        SemiImageThemeData(spacingImagePreviewFooterPageMarginY: v as double),
    (d) => d.spacingImagePreviewFooterPageMarginY,
  ),
  (
    r'$spacing-image_preview_footer_page-marginX: 12px',
    37.0,
    (v) =>
        SemiImageThemeData(spacingImagePreviewFooterPageMarginX: v as double),
    (d) => d.spacingImagePreviewFooterPageMarginX,
  ),
  (
    r'$spacing-image_preview_footer_slider-paddingY: 0',
    37.0,
    (v) => SemiImageThemeData(
      spacingImagePreviewFooterSliderPaddingY: v as double,
    ),
    (d) => d.spacingImagePreviewFooterSliderPaddingY,
  ),
  (
    r'$spacing-image_preview_footer_slider-paddingX: 16px',
    37.0,
    (v) => SemiImageThemeData(
      spacingImagePreviewFooterSliderPaddingX: v as double,
    ),
    (d) => d.spacingImagePreviewFooterSliderPaddingX,
  ),
  (
    r'$spacing-image_preview_footer_slider_handle-marginTop: 8px',
    37.0,
    (v) => SemiImageThemeData(
      spacingImagePreviewFooterSliderHandleMarginTop: v as double,
    ),
    (d) => d.spacingImagePreviewFooterSliderHandleMarginTop,
  ),
  (
    r'$spacing-image_preview_footer_divider-marginY: 0',
    37.0,
    (v) => SemiImageThemeData(
      spacingImagePreviewFooterDividerMarginY: v as double,
    ),
    (d) => d.spacingImagePreviewFooterDividerMarginY,
  ),
  (
    r'$spacing-image_preview_footer_divider-marginX: 16px',
    37.0,
    (v) => SemiImageThemeData(
      spacingImagePreviewFooterDividerMarginX: v as double,
    ),
    (d) => d.spacingImagePreviewFooterDividerMarginX,
  ),
  (
    r'$spacing-image_preview_footer_gap-marginLeft: 16px',
    37.0,
    (v) =>
        SemiImageThemeData(spacingImagePreviewFooterGapMarginLeft: v as double),
    (d) => d.spacingImagePreviewFooterGapMarginLeft,
  ),
  (
    r'$spacing-image_preview_footer_gap_rtl-marginLeft: 0',
    37.0,
    (v) => SemiImageThemeData(
      spacingImagePreviewFooterGapRtlMarginLeft: v as double,
    ),
    (d) => d.spacingImagePreviewFooterGapRtlMarginLeft,
  ),
  (
    r'$width-image_preview_footer_slider: 132px',
    37.0,
    (v) => SemiImageThemeData(widthImagePreviewFooterSlider: v as double),
    (d) => d.widthImagePreviewFooterSlider,
  ),
  (
    r'$width-image_preview_footer_slider_handle: 16px',
    37.0,
    (v) => SemiImageThemeData(widthImagePreviewFooterSliderHandle: v as double),
    (d) => d.widthImagePreviewFooterSliderHandle,
  ),
  (
    r'$width-image_preview_icon: 40px',
    37.0,
    (v) => SemiImageThemeData(widthImagePreviewIcon: v as double),
    (d) => d.widthImagePreviewIcon,
  ),
  (
    r'$width-image_preview_header_close: 30px',
    37.0,
    (v) => SemiImageThemeData(widthImagePreviewHeaderClose: v as double),
    (d) => d.widthImagePreviewHeaderClose,
  ),
  (
    r'$height-image_preview_header: 60px',
    37.0,
    (v) => SemiImageThemeData(heightImagePreviewHeader: v as double),
    (d) => d.heightImagePreviewHeader,
  ),
  (
    r'$height-image_preview_footer: 48px',
    37.0,
    (v) => SemiImageThemeData(heightImagePreviewFooter: v as double),
    (d) => d.heightImagePreviewFooter,
  ),
  (
    r'$height-image_preview_footer_slider: 2px',
    37.0,
    (v) => SemiImageThemeData(heightImagePreviewFooterSlider: v as double),
    (d) => d.heightImagePreviewFooterSlider,
  ),
  (
    r'$height-image_preview_footer_slider_handle: 16px',
    37.0,
    (v) =>
        SemiImageThemeData(heightImagePreviewFooterSliderHandle: v as double),
    (d) => d.heightImagePreviewFooterSliderHandle,
  ),
  (
    r'$height-image_preview_icon: 40px',
    37.0,
    (v) => SemiImageThemeData(heightImagePreviewIcon: v as double),
    (d) => d.heightImagePreviewIcon,
  ),
  (
    r'$height-image_preview_header_close: 30px',
    37.0,
    (v) => SemiImageThemeData(heightImagePreviewHeaderClose: v as double),
    (d) => d.heightImagePreviewHeaderClose,
  ),
  (
    r'$radius-image: var(--semi-border-radius-small)',
    37.0,
    (v) => SemiImageThemeData(radiusImage: v as double),
    (d) => d.radiusImage,
  ),
  (
    r'$radius-image_preview_footer: var(--semi-border-radius-medium)',
    37.0,
    (v) => SemiImageThemeData(radiusImagePreviewFooter: v as double),
    (d) => d.radiusImagePreviewFooter,
  ),
  (
    r'$color-image_mask-bg: var(--semi-color-overlay-bg)',
    Color(0xff123456),
    (v) => SemiImageThemeData(colorImageMaskBg: v as Color),
    (d) => d.colorImageMaskBg,
  ),
  (
    r'$color-image_mask_info_text: var(--semi-color-white)',
    Color(0xff123456),
    (v) => SemiImageThemeData(colorImageMaskInfoText: v as Color),
    (d) => d.colorImageMaskInfoText,
  ),
  (
    r'$color-image_status-bg: var(--semi-color-fill-0)',
    Color(0xff123456),
    (v) => SemiImageThemeData(colorImageStatusBg: v as Color),
    (d) => d.colorImageStatusBg,
  ),
  (
    r'$color-image_status: var(--semi-color-disabled-text)',
    Color(0xff123456),
    (v) => SemiImageThemeData(colorImageStatus: v as Color),
    (d) => d.colorImageStatus,
  ),
  (
    r'$color-image_preview-bg: var(--semi-color-overlay-bg)',
    Color(0xff123456),
    (v) => SemiImageThemeData(colorImagePreviewBg: v as Color),
    (d) => d.colorImagePreviewBg,
  ),
  (
    r'$color-image_preview_icon: var(--semi-color-white)',
    Color(0xff123456),
    (v) => SemiImageThemeData(colorImagePreviewIcon: v as Color),
    (d) => d.colorImagePreviewIcon,
  ),
  (
    r'$color-image_preview_header: var(--semi-color-white)',
    Color(0xff123456),
    (v) => SemiImageThemeData(colorImagePreviewHeader: v as Color),
    (d) => d.colorImagePreviewHeader,
  ),
  (
    r'$color-image_preview_footer_icon: var(--semi-color-white)',
    Color(0xff123456),
    (v) => SemiImageThemeData(colorImagePreviewFooterIcon: v as Color),
    (d) => d.colorImagePreviewFooterIcon,
  ),
  (
    r'$color-image_preview_footer_slider_rail: var(--semi-color-white)',
    Color(0xff123456),
    (v) => SemiImageThemeData(colorImagePreviewFooterSliderRail: v as Color),
    (d) => d.colorImagePreviewFooterSliderRail,
  ),
  (
    r'$color-image_preview_disabled: rgba(249, 249, 249, 0.35)',
    Color(0xff123456),
    (v) => SemiImageThemeData(colorImagePreviewDisabled: v as Color),
    (d) => d.colorImagePreviewDisabled,
  ),
  (
    r'$color-image_preview_icon-bg: rgba(0, 0, 0, 0.75)',
    Color(0xff123456),
    (v) => SemiImageThemeData(colorImagePreviewIconBg: v as Color),
    (d) => d.colorImagePreviewIconBg,
  ),
  (
    r'$color-image_header_close-bg: rgba(0, 0, 0, 0.75)',
    Color(0xff123456),
    (v) => SemiImageThemeData(colorImageHeaderCloseBg: v as Color),
    (d) => d.colorImageHeaderCloseBg,
  ),
  (
    r'$color-image_preview_footer-bg: rgba(0, 0, 0, 0.75)',
    Color(0xff123456),
    (v) => SemiImageThemeData(colorImagePreviewFooterBg: v as Color),
    (d) => d.colorImagePreviewFooterBg,
  ),
  (
    r'$color-image-preview_divider-bg: rgba(255, 255, 255, .5)',
    Color(0xff123456),
    (v) => SemiImageThemeData(colorImagePreviewDividerBg: v as Color),
    (d) => d.colorImagePreviewDividerBg,
  ),
  (
    r'$color-image_preview_image_spin: #ccc',
    Color(0xff123456),
    (v) => SemiImageThemeData(colorImagePreviewImageSpin: v as Color),
    (d) => d.colorImagePreviewImageSpin,
  ),
  (
    r'$z-image_preview: 1070 !default',
    37.0,
    (v) => SemiImageThemeData(zImagePreview: v as double),
    (d) => d.zImagePreview,
  ),
  (
    r'$z-image_preview_header: 1 !default',
    37.0,
    (v) => SemiImageThemeData(zImagePreviewHeader: v as double),
    (d) => d.zImagePreviewHeader,
  ),
  (
    r'$transform_rotate-image_preview_spinner: var(--semi-transform_rotate-clockwise360deg)',
    const SemiTransform.rotate(37),
    (v) => SemiImageThemeData(
      transformRotateImagePreviewSpinner: v as SemiTransform,
    ),
    (d) => d.transformRotateImagePreviewSpinner,
  ),
  (
    r'$transform_scale3d-image_preview_image_img: 1, 1, 1',
    const SemiTransform.rotate(37),
    (v) => SemiImageThemeData(
      transformScale3dImagePreviewImageImg: v as SemiTransform,
    ),
    (d) => d.transformScale3dImagePreviewImageImg,
  ),
  (
    r'$transform_rotate-image_preview_image_img: var(--semi-transform-rotate-none)',
    const SemiTransform.rotate(37),
    (v) => SemiImageThemeData(
      transformRotateImagePreviewImageImg: v as SemiTransform,
    ),
    (d) => d.transformRotateImagePreviewImageImg,
  ),
  (
    r'$transition_duration-image_preview_image_img: 300ms',
    const Duration(milliseconds: 37),
    (v) => SemiImageThemeData(
      transitionDurationImagePreviewImageImg: v as Duration,
    ),
    (d) => d.transitionDurationImagePreviewImageImg,
  ),
  (
    r'$transition_function-image_preview_image_img: cubic-bezier(0.215, 0.61, 0.355, 1)',
    const Cubic(0.37, 0.37, 0.37, 0.37),
    (v) =>
        SemiImageThemeData(transitionFunctionImagePreviewImageImg: v as Curve),
    (d) => d.transitionFunctionImagePreviewImageImg,
  ),
  (
    r'$transition_delay-image_preview_image_img: 0s',
    const Duration(milliseconds: 37),
    (v) =>
        SemiImageThemeData(transitionDelayImagePreviewImageImg: v as Duration),
    (d) => d.transitionDelayImagePreviewImageImg,
  ),
  (
    r'$transition_duration-image_preview: 500ms',
    const Duration(milliseconds: 37),
    (v) => SemiImageThemeData(transitionDurationImagePreview: v as Duration),
    (d) => d.transitionDurationImagePreview,
  ),
  (
    r'$transform_rotate-image_preview_icon_rtl: var(--semi-transform_rotate-clockwise180deg)',
    const SemiTransform.rotate(37),
    (v) => SemiImageThemeData(
      transformRotateImagePreviewIconRtl: v as SemiTransform,
    ),
    (d) => d.transformRotateImagePreviewIconRtl,
  ),
];

void main() {
  test('52 fields: merge, copyWith, resolve, equality', () {
    expect(fields, hasLength(52));
    for (final (decl, value, patch, read) in fields) {
      final overridden = patch(value);
      expect(overridden.merge(overridden), overridden, reason: decl);
      expect(overridden.copyWith(), overridden, reason: decl);
      expect(overridden.hashCode, patch(value).hashCode, reason: decl);
      expect(overridden.merge(null), overridden, reason: decl);
      expect(
        read(overridden.resolve(const SemiThemeData.dark())),
        value,
        reason: decl,
      );
      expect(
        read(const SemiImageThemeData().resolve(const SemiThemeData.dark())),
        isNotNull,
        reason: decl,
      );
    }
  });

  test('every field carries its Sass provenance in the generated source', () {
    final theme = File('lib/src/theme/semi_image_theme_data.dart')
        .readAsStringSync();
    for (final (decl, _, _, _) in fields) {
      expect(theme, contains(decl), reason: decl);
    }
    expect(theme, contains('packages/semi-foundation/image/variables.scss'));
    expect(theme, contains('packages/semi-foundation/image/animation.scss'));
    expect(theme, contains('Generated by tool/generate_image.py'));
    expect(theme, contains('# dead variable (上游未消费)'));
  });

  test('type coverage: 29 double + 15 Color + 4 SemiTransform + 3 Duration + 1 Curve', () {
    final counts = <Type, int>{};
    for (final (_, value, _, _) in fields) {
      counts[value.runtimeType] = (counts[value.runtimeType] ?? 0) + 1;
    }
    expect(counts, {
      double: 29,
      Color: 15,
      SemiTransform: 4,
      Duration: 3,
      Cubic: 1,
    });
  });

  test(
    'the 8 dead fields stay in the theme and are absent from the widget',
    () {
      final theme = File('lib/src/theme/semi_image_theme_data.dart')
          .readAsStringSync();
      final widget = File('lib/src/components/semi_image.dart')
          .readAsStringSync();
      const dead = {
        'spacingImageMaskInfoTextMarginTop',
        'colorImageMaskBg',
        'colorImageMaskInfoText',
        'colorImagePreviewBg',
        'transitionDurationImagePreviewImageImg',
        'transitionFunctionImagePreviewImageImg',
        'transitionDelayImagePreviewImageImg',
        'transformRotateImagePreviewSpinner',
      };
      for (final name in dead) {
        expect(theme, contains(name), reason: name);
        expect(
          RegExp('(?<![A-Za-z])$name(?![A-Za-z])').hasMatch(widget),
          isFalse,
          reason: name,
        );
      }
    },
  );

  test('SemiComponentThemes wiring', () {
    const themes = SemiComponentThemes();
    expect(themes.image, const SemiImageThemeData());
    final updated = themes.copyWith(
      image: const SemiImageThemeData(radiusImage: 9),
    );
    expect(updated.image, const SemiImageThemeData(radiusImage: 9));
  });

  testWidgets('SemiImageTheme local patch applies to the image box', (
    tester,
  ) async {
    await tester.pumpWidget(
      SemiTheme(
        data: const SemiThemeData.light(),
        child: Directionality(
          textDirection: TextDirection.ltr,
          child: SemiImageTheme(
            data: const SemiImageThemeData(radiusImage: 18),
            child: const SizedBox(width: 100, height: 80, child: _BoxProbe()),
          ),
        ),
      ),
    );
    final box = tester.widget<DecoratedBox>(
      find.descendant(
        of: find.byType(_BoxProbe),
        matching: find.byType(DecoratedBox),
      ),
    );
    expect(
      (box.decoration as BoxDecoration).borderRadius,
      BorderRadius.circular(18),
    );
  });
}

class _BoxProbe extends StatelessWidget {
  const _BoxProbe();
  @override
  Widget build(BuildContext context) {
    final t = SemiImageTheme.resolve(context);
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(t.radiusImage),
      ),
    );
  }
}
