// Behavior matrix for SemiTabs plus coverage for the 144 Sass declarations
// (121 FIELDS + 23 MOTION + 0 INTERNAL) — the 23 HARDCODES provenance anchors
// live in the widget's file-level note block / call sites. ★9 死变量 →
// word-boundary assertNotIn + docs（上游未消费）marks.
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:semi_design_flutter/semi_design_flutter.dart';

final _hostBody = ValueNotifier<(Widget, double)>((
  const SizedBox.shrink(),
  600,
));

Widget host(
  Widget child, {
  TextDirection direction = TextDirection.ltr,
  double width = 600,
}) {
  _hostBody.value = (KeyedSubtree(key: UniqueKey(), child: child), width);
  return SemiTheme(
    data: const SemiThemeData.light(),
    child: Directionality(
      textDirection: direction,
      child: MediaQuery(
        data: const MediaQueryData(size: Size(1200, 800)),
        child: Overlay(
          initialEntries: [
            OverlayEntry(
              builder: (context) => ValueListenableBuilder<(Widget, double)>(
                valueListenable: _hostBody,
                builder: (context, value, _) => Align(
                  alignment: Alignment.topLeft,
                  child: SizedBox(
                    width: value.$2,
                    height: 400,
                    child: Align(alignment: Alignment.topLeft, child: value.$1),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

Future<void> pumpHost(
  WidgetTester tester,
  Widget child, {
  TextDirection direction = TextDirection.ltr,
  double width = 600,
}) async {
  addTearDown(() async => tester.pumpWidget(const SizedBox.shrink()));
  await tester.binding.setSurfaceSize(const Size(1200, 800));
  await tester.pumpWidget(host(child, direction: direction, width: width));
}

Future<void> settle(WidgetTester tester) async {
  for (var i = 0; i < 6; i++) {
    await tester.pump(const Duration(milliseconds: 30));
  }
}

const tabs3 = [
  SemiTabData(itemKey: '1', tab: 'Tab 1', content: Text('pane1')),
  SemiTabData(itemKey: '2', tab: 'Tab 2', content: Text('pane2')),
  SemiTabData(
    itemKey: '3',
    tab: 'Tab 3',
    disabled: true,
    content: Text('pane3'),
  ),
];

Finder tabContainer(String label) => find
    .ancestor(of: find.text(label), matching: find.byType(AnimatedContainer))
    .first;

BoxDecoration tabDecoration(WidgetTester tester, String label) =>
    tester.widget<AnimatedContainer>(tabContainer(label)).decoration
        as BoxDecoration;

/// card 形态页签的盒边 painter（`SemiTabsCardPainter`）。
SemiTabsCardPainter tabCardPainter(WidgetTester tester, String label) =>
    tester
            .widget<CustomPaint>(
              find
                  .ancestor(
                    of: tabContainer(label),
                    matching: find.byType(CustomPaint),
                  )
                  .first,
            )
            .foregroundPainter!
        as SemiTabsCardPainter;

Color? textColorOf(WidgetTester tester, String label) {
  final paragraph = tester.renderObject<RenderParagraph>(find.text(label));
  return (paragraph.text as TextSpan).style?.color;
}

Finder iconFinder(SemiIconData data) => find.byWidgetPredicate(
  (widget) => widget is SemiIcon && widget.data == data,
);

// -- theme field table -------------------------------------------------------

typedef _Patch = SemiTabsThemeData Function(Object value);
typedef _Read = Object? Function(SemiResolvedTabsThemeData data);
typedef _Default = Object? Function(SemiThemeData theme);

const _c = Color(0xFF010203);

final List<(String, Object, _Patch, _Read, _Default)> fields = [
  (
    r'$color-tabs_tab_line_default-border-default: var(--semi-color-border)',
    _c,
    (v) => SemiTabsThemeData(colorTabsTabLineDefaultBorderDefault: v as Color),
    (d) => d.colorTabsTabLineDefaultBorderDefault,
    (t) => t.colors.colorBorder,
  ),
  (
    r'$color-tabs_tab_line_default-bg-default: transparent',
    _c,
    (v) => SemiTabsThemeData(colorTabsTabLineDefaultBgDefault: v as Color),
    (d) => d.colorTabsTabLineDefaultBgDefault,
    (t) => const Color(0x00000000),
  ),
  (
    r'$color-tabs_tab_line_default-text-default: var(--semi-color-text-2)',
    _c,
    (v) => SemiTabsThemeData(colorTabsTabLineDefaultTextDefault: v as Color),
    (d) => d.colorTabsTabLineDefaultTextDefault,
    (t) => t.colors.colorText2,
  ),
  (
    r'$color-tabs_tab_line_default-bg-hover: transparent',
    _c,
    (v) => SemiTabsThemeData(colorTabsTabLineDefaultBgHover: v as Color),
    (d) => d.colorTabsTabLineDefaultBgHover,
    (t) => const Color(0x00000000),
  ),
  (
    r'$color-tabs_tab_line_default-text-hover: var(--semi-color-text-0)',
    _c,
    (v) => SemiTabsThemeData(colorTabsTabLineDefaultTextHover: v as Color),
    (d) => d.colorTabsTabLineDefaultTextHover,
    (t) => t.colors.colorText0,
  ),
  (
    r'$color-tabs_tab_line_default-border-hover: var(--semi-color-fill-0)',
    _c,
    (v) => SemiTabsThemeData(colorTabsTabLineDefaultBorderHover: v as Color),
    (d) => d.colorTabsTabLineDefaultBorderHover,
    (t) => t.colors.colorFill0,
  ),
  (
    r'$color-tabs_tab_line_default-bg-active: transparent',
    _c,
    (v) => SemiTabsThemeData(colorTabsTabLineDefaultBgActive: v as Color),
    (d) => d.colorTabsTabLineDefaultBgActive,
    (t) => const Color(0x00000000),
  ),
  (
    r'$color-tabs_tab_line_default-text-active: var(--semi-color-text-0)',
    _c,
    (v) => SemiTabsThemeData(colorTabsTabLineDefaultTextActive: v as Color),
    (d) => d.colorTabsTabLineDefaultTextActive,
    (t) => t.colors.colorText0,
  ),
  (
    r'$color-tabs_tab_line_default-border-active: var(--semi-color-fill-1)',
    _c,
    (v) => SemiTabsThemeData(colorTabsTabLineDefaultBorderActive: v as Color),
    (d) => d.colorTabsTabLineDefaultBorderActive,
    (t) => t.colors.colorFill1,
  ),
  (
    r'$color-tabs_tab_line_selected-bg-default: transparent',
    _c,
    (v) => SemiTabsThemeData(colorTabsTabLineSelectedBgDefault: v as Color),
    (d) => d.colorTabsTabLineSelectedBgDefault,
    (t) => const Color(0x00000000),
  ),
  (
    r'$color-tabs_tab_line_selected-text-default: var(--semi-color-text-0)',
    _c,
    (v) => SemiTabsThemeData(colorTabsTabLineSelectedTextDefault: v as Color),
    (d) => d.colorTabsTabLineSelectedTextDefault,
    (t) => t.colors.colorText0,
  ),
  (
    r'$color-tabs_tab_line_indicator_selected-icon-default: var(--semi-color-primary)',
    _c,
    (v) => SemiTabsThemeData(
      colorTabsTabLineIndicatorSelectedIconDefault: v as Color,
    ),
    (d) => d.colorTabsTabLineIndicatorSelectedIconDefault,
    (t) => t.colors.colorPrimary,
  ),
  (
    r'$color-tabs_tab_line_selected-icon-default: var(--semi-color-primary)',
    _c,
    (v) => SemiTabsThemeData(colorTabsTabLineSelectedIconDefault: v as Color),
    (d) => d.colorTabsTabLineSelectedIconDefault,
    (t) => t.colors.colorPrimary,
  ),
  (
    r'$color-tabs_tab_line_vertical_selected-bg-default: var(--semi-color-primary-light-default)',
    _c,
    (v) => SemiTabsThemeData(
      colorTabsTabLineVerticalSelectedBgDefault: v as Color,
    ),
    (d) => d.colorTabsTabLineVerticalSelectedBgDefault,
    (t) => t.colors.colorPrimaryLightDefault,
  ),
  (
    r'$color-tabs_tab_line_vertical-bg-hover: var(--semi-color-fill-0)',
    _c,
    (v) => SemiTabsThemeData(colorTabsTabLineVerticalBgHover: v as Color),
    (d) => d.colorTabsTabLineVerticalBgHover,
    (t) => t.colors.colorFill0,
  ),
  (
    r'$color-tabs_tab_line_vertical-bg-active: var(--semi-color-fill-1)',
    _c,
    (v) => SemiTabsThemeData(colorTabsTabLineVerticalBgActive: v as Color),
    (d) => d.colorTabsTabLineVerticalBgActive,
    (t) => t.colors.colorFill1,
  ),
  (
    r'$color-tabs_tab_line_disabled-text-default: var(--semi-color-disabled-text)',
    _c,
    (v) => SemiTabsThemeData(colorTabsTabLineDisabledTextDefault: v as Color),
    (d) => d.colorTabsTabLineDisabledTextDefault,
    (t) => t.colors.colorDisabledText,
  ),
  (
    r'$color-tabs_tab_line_disabled-text-hover: var(--semi-color-disabled-text)',
    _c,
    (v) => SemiTabsThemeData(colorTabsTabLineDisabledTextHover: v as Color),
    (d) => d.colorTabsTabLineDisabledTextHover,
    (t) => t.colors.colorDisabledText,
  ),
  (
    r'$color-tabs_tab_card_default-border-default: var(--semi-color-border)',
    _c,
    (v) => SemiTabsThemeData(colorTabsTabCardDefaultBorderDefault: v as Color),
    (d) => d.colorTabsTabCardDefaultBorderDefault,
    (t) => t.colors.colorBorder,
  ),
  (
    r'$color-tabs_tab_button_selected-bg-default: var(--semi-color-primary-light-default)',
    _c,
    (v) => SemiTabsThemeData(colorTabsTabButtonSelectedBgDefault: v as Color),
    (d) => d.colorTabsTabButtonSelectedBgDefault,
    (t) => t.colors.colorPrimaryLightDefault,
  ),
  (
    r'$color-tabs_tab_button_selected-text-default: var(--semi-color-primary)',
    _c,
    (v) => SemiTabsThemeData(colorTabsTabButtonSelectedTextDefault: v as Color),
    (d) => d.colorTabsTabButtonSelectedTextDefault,
    (t) => t.colors.colorPrimary,
  ),
  (
    r'$color-tabs_tab_button-text-default: var(--semi-color-text-2)',
    _c,
    (v) => SemiTabsThemeData(colorTabsTabButtonTextDefault: v as Color),
    (d) => d.colorTabsTabButtonTextDefault,
    (t) => t.colors.colorText2,
  ),
  (
    r'$color-tabs_tab_button-bg-hover: var(--semi-color-fill-0)',
    _c,
    (v) => SemiTabsThemeData(colorTabsTabButtonBgHover: v as Color),
    (d) => d.colorTabsTabButtonBgHover,
    (t) => t.colors.colorFill0,
  ),
  (
    r'$color-tabs_tab_button-bg-active: var(--semi-color-fill-1)',
    _c,
    (v) => SemiTabsThemeData(colorTabsTabButtonBgActive: v as Color),
    (d) => d.colorTabsTabButtonBgActive,
    (t) => t.colors.colorFill1,
  ),
  (
    r'$color-tabs_tab_card_indicator_selected-icon-default: var(--semi-color-border)',
    _c,
    (v) => SemiTabsThemeData(
      colorTabsTabCardIndicatorSelectedIconDefault: v as Color,
    ),
    (d) => d.colorTabsTabCardIndicatorSelectedIconDefault,
    (t) => t.colors.colorBorder,
  ),
  (
    r'$color-tabs_tab_card-bg-hover: var(--semi-color-fill-0)',
    _c,
    (v) => SemiTabsThemeData(colorTabsTabCardBgHover: v as Color),
    (d) => d.colorTabsTabCardBgHover,
    (t) => t.colors.colorFill0,
  ),
  (
    r'$color-tabs_tab_card_selected-bg-default: var(--semi-color-bg-1)',
    _c,
    (v) => SemiTabsThemeData(colorTabsTabCardSelectedBgDefault: v as Color),
    (d) => d.colorTabsTabCardSelectedBgDefault,
    (t) => t.colors.colorBg1,
  ),
  (
    r'$color-tabs_tab_card-bg-active: var(--semi-color-fill-1)',
    _c,
    (v) => SemiTabsThemeData(colorTabsTabCardBgActive: v as Color),
    (d) => d.colorTabsTabCardBgActive,
    (t) => t.colors.colorFill1,
  ),
  (
    r'$color-tabs_tab-icon-default: var(--semi-color-text-2)',
    _c,
    (v) => SemiTabsThemeData(colorTabsTabIconDefault: v as Color),
    (d) => d.colorTabsTabIconDefault,
    (t) => t.colors.colorText2,
  ),
  (
    r'$color-tabs_tab-icon-hover: var(--semi-color-text-0)',
    _c,
    (v) => SemiTabsThemeData(colorTabsTabIconHover: v as Color),
    (d) => d.colorTabsTabIconHover,
    (t) => t.colors.colorText0,
  ),
  (
    r'$color-tabs_tab-icon-active: var(--semi-color-text-0)',
    _c,
    (v) => SemiTabsThemeData(colorTabsTabIconActive: v as Color),
    (d) => d.colorTabsTabIconActive,
    (t) => t.colors.colorText0,
  ),
  (
    r'$color-tabs_tab_selected-icon-default: var(--semi-color-primary)',
    _c,
    (v) => SemiTabsThemeData(colorTabsTabSelectedIconDefault: v as Color),
    (d) => d.colorTabsTabSelectedIconDefault,
    (t) => t.colors.colorPrimary,
  ),
  (
    r'$color-tabs_tab-outline-focus: var(--semi-color-primary-light-active)',
    _c,
    (v) => SemiTabsThemeData(colorTabsTabOutlineFocus: v as Color),
    (d) => d.colorTabsTabOutlineFocus,
    (t) => t.colors.colorPrimaryLightActive,
  ),
  (
    r'$color-tabs_tab-pane-text-default: var(--semi-color-text-0)',
    _c,
    (v) => SemiTabsThemeData(colorTabsTabPaneTextDefault: v as Color),
    (d) => d.colorTabsTabPaneTextDefault,
    (t) => t.colors.colorText0,
  ),
  (
    r'$color-tabs_tab-pane_arrow-text-default: var(--semi-color-primary)',
    _c,
    (v) => SemiTabsThemeData(colorTabsTabPaneArrowTextDefault: v as Color),
    (d) => d.colorTabsTabPaneArrowTextDefault,
    (t) => t.colors.colorPrimary,
  ),
  (
    r'$color-tabs_tab-pane_arrow-border-default: transparent',
    _c,
    (v) => SemiTabsThemeData(colorTabsTabPaneArrowBorderDefault: v as Color),
    (d) => d.colorTabsTabPaneArrowBorderDefault,
    (t) => const Color(0x00000000),
  ),
  (
    r'$color-tabs_tab-pane_arrow-bg-default:transparent',
    _c,
    (v) => SemiTabsThemeData(colorTabsTabPaneArrowBgDefault: v as Color),
    (d) => d.colorTabsTabPaneArrowBgDefault,
    (t) => const Color(0x00000000),
  ),
  (
    r'$color-tabs_tab-pane_arrow-text-hover: var(--semi-color-primary)',
    _c,
    (v) => SemiTabsThemeData(colorTabsTabPaneArrowTextHover: v as Color),
    (d) => d.colorTabsTabPaneArrowTextHover,
    (t) => t.colors.colorPrimary,
  ),
  (
    r'$color-tabs_tab-pane_arrow-border-hover: transparent',
    _c,
    (v) => SemiTabsThemeData(colorTabsTabPaneArrowBorderHover: v as Color),
    (d) => d.colorTabsTabPaneArrowBorderHover,
    (t) => const Color(0x00000000),
  ),
  (
    r'$color-tabs_tab-pane_arrow-bg-hover: var(--semi-color-fill-0)',
    _c,
    (v) => SemiTabsThemeData(colorTabsTabPaneArrowBgHover: v as Color),
    (d) => d.colorTabsTabPaneArrowBgHover,
    (t) => t.colors.colorFill0,
  ),
  (
    r'$color-tabs_tab-pane_arrow-text-active: var(--semi-color-primary)',
    _c,
    (v) => SemiTabsThemeData(colorTabsTabPaneArrowTextActive: v as Color),
    (d) => d.colorTabsTabPaneArrowTextActive,
    (t) => t.colors.colorPrimary,
  ),
  (
    r'$color-tabs_tab-pane_arrow-border-active: transparent',
    _c,
    (v) => SemiTabsThemeData(colorTabsTabPaneArrowBorderActive: v as Color),
    (d) => d.colorTabsTabPaneArrowBorderActive,
    (t) => const Color(0x00000000),
  ),
  (
    r'$color-tabs_tab-pane_arrow-bg-active: var(--semi-color-fill-1)',
    _c,
    (v) => SemiTabsThemeData(colorTabsTabPaneArrowBgActive: v as Color),
    (d) => d.colorTabsTabPaneArrowBgActive,
    (t) => t.colors.colorFill1,
  ),
  (
    r'$color-tabs_tab-pane_arrow_disabled-bg-default: transparent',
    _c,
    (v) =>
        SemiTabsThemeData(colorTabsTabPaneArrowDisabledBgDefault: v as Color),
    (d) => d.colorTabsTabPaneArrowDisabledBgDefault,
    (t) => const Color(0x00000000),
  ),
  (
    r'$color-tabs_tab-pane_arrow_disabled-bg-hover:  transparent',
    _c,
    (v) => SemiTabsThemeData(colorTabsTabPaneArrowDisabledBgHover: v as Color),
    (d) => d.colorTabsTabPaneArrowDisabledBgHover,
    (t) => const Color(0x00000000),
  ),
  (
    r'$color-tabs_tab-pane_arrow_disabled-text-default: var(--semi-color-disabled-text)',
    _c,
    (v) =>
        SemiTabsThemeData(colorTabsTabPaneArrowDisabledTextDefault: v as Color),
    (d) => d.colorTabsTabPaneArrowDisabledTextDefault,
    (t) => t.colors.colorDisabledText,
  ),
  (
    r'$color-tabs_tab-pane_arrow_disabled-text-hover:  var(--semi-color-disabled-text)',
    _c,
    (v) =>
        SemiTabsThemeData(colorTabsTabPaneArrowDisabledTextHover: v as Color),
    (d) => d.colorTabsTabPaneArrowDisabledTextHover,
    (t) => t.colors.colorDisabledText,
  ),
  (
    r'$color-tabs_tab_slash_line: var(--semi-color-text-2)',
    _c,
    (v) => SemiTabsThemeData(colorTabsTabSlashLine: v as Color),
    (d) => d.colorTabsTabSlashLine,
    (t) => t.colors.colorText2,
  ),
  (
    r'$font-tabs_tab-fontWeight: $font-weight-regular',
    FontWeight.w700,
    (v) => SemiTabsThemeData(fontTabsTabFontWeight: v as FontWeight),
    (d) => d.fontTabsTabFontWeight,
    (t) => t.typography.fontWeightRegular,
  ),
  (
    r'$font-tabs_tab_active-fontWeight: $font-weight-bold',
    FontWeight.w700,
    (v) => SemiTabsThemeData(fontTabsTabActiveFontWeight: v as FontWeight),
    (d) => d.fontTabsTabActiveFontWeight,
    (t) => t.typography.fontWeightBold,
  ),
  (
    r'$height-tabs_overflow_list: 300px',
    77.5,
    (v) => SemiTabsThemeData(heightTabsOverflowList: v as double),
    (d) => d.heightTabsOverflowList,
    (t) => 300.0,
  ),
  (
    r'$width-tabs_bar_line-border: $border-thickness-control',
    77.5,
    (v) => SemiTabsThemeData(widthTabsBarLineBorder: v as double),
    (d) => d.widthTabsBarLineBorder,
    (t) => 1.0,
  ),
  (
    r'$width-tabs_bar_line_tab-border: 2px',
    77.5,
    (v) => SemiTabsThemeData(widthTabsBarLineTabBorder: v as double),
    (d) => d.widthTabsBarLineTabBorder,
    (t) => 2.0,
  ),
  (
    r'$width-tabs_bar_card-border: $border-thickness-control',
    77.5,
    (v) => SemiTabsThemeData(widthTabsBarCardBorder: v as double),
    (d) => d.widthTabsBarCardBorder,
    (t) => 1.0,
  ),
  (
    r'$width-tabs-outline: 2px',
    77.5,
    (v) => SemiTabsThemeData(widthTabsOutline: v as double),
    (d) => d.widthTabsOutline,
    (t) => 2.0,
  ),
  (
    r'$width-tabs-outline-offset: -2px',
    77.5,
    (v) => SemiTabsThemeData(widthTabsOutlineOffset: v as double),
    (d) => d.widthTabsOutlineOffset,
    (t) => -2.0,
  ),
  (
    r'$width-tabs_bar_line-outline-offset: -1px',
    77.5,
    (v) => SemiTabsThemeData(widthTabsBarLineOutlineOffset: v as double),
    (d) => d.widthTabsBarLineOutlineOffset,
    (t) => -1.0,
  ),
  (
    r'$width-tabs_tab-pane_arrow-border:0px',
    77.5,
    (v) => SemiTabsThemeData(widthTabsTabPaneArrowBorder: v as double),
    (d) => d.widthTabsTabPaneArrowBorder,
    (t) => 0.0,
  ),
  (
    r'$width-tabs_tab_slash_line: 8px',
    77.5,
    (v) => SemiTabsThemeData(widthTabsTabSlashLine: v as double),
    (d) => d.widthTabsTabSlashLine,
    (t) => 8.0,
  ),
  (
    r'$height-tabs_tab_slash_line: 14px',
    77.5,
    (v) => SemiTabsThemeData(heightTabsTabSlashLine: v as double),
    (d) => d.heightTabsTabSlashLine,
    (t) => 14.0,
  ),
  (
    r'$height-tabs_bar_extra_large: 50px',
    77.5,
    (v) => SemiTabsThemeData(heightTabsBarExtraLarge: v as double),
    (d) => d.heightTabsBarExtraLarge,
    (t) => 50.0,
  ),
  (
    r'$font-tabs_bar_extra_large-lineHeight: $height-tabs_bar_extra_large',
    77.5,
    (v) => SemiTabsThemeData(fontTabsBarExtraLargeLineHeight: v as double),
    (d) => d.fontTabsBarExtraLargeLineHeight,
    (t) => 50.0,
  ),
  (
    r'$height-tabs_bar_extra_small: 36px',
    77.5,
    (v) => SemiTabsThemeData(heightTabsBarExtraSmall: v as double),
    (d) => d.heightTabsBarExtraSmall,
    (t) => 36.0,
  ),
  (
    r'$font-tabs_bar_extra_small-lineHeight: $height-tabs_bar_extra_small',
    77.5,
    (v) => SemiTabsThemeData(fontTabsBarExtraSmallLineHeight: v as double),
    (d) => d.fontTabsBarExtraSmallLineHeight,
    (t) => 36.0,
  ),
  (
    r'$spacing-tabs_tab-more_trigger_icon-marginLeft: 8px',
    77.5,
    (v) =>
        SemiTabsThemeData(spacingTabsTabMoreTriggerIconMarginLeft: v as double),
    (d) => d.spacingTabsTabMoreTriggerIconMarginLeft,
    (t) => 8.0,
  ),
  (
    r'$spacing-tabs_tab-more_trigger_icon-marginRight: 8px',
    77.5,
    (v) => SemiTabsThemeData(
      spacingTabsTabMoreTriggerIconMarginRight: v as double,
    ),
    (d) => d.spacingTabsTabMoreTriggerIconMarginRight,
    (t) => 8.0,
  ),
  (
    r'$spacing-tabs_tab-more_trigger_icon-marginTop: 0px',
    77.5,
    (v) =>
        SemiTabsThemeData(spacingTabsTabMoreTriggerIconMarginTop: v as double),
    (d) => d.spacingTabsTabMoreTriggerIconMarginTop,
    (t) => 0.0,
  ),
  (
    r'$spacing-tabs_tab-more_trigger_icon-marginBottom: 0px',
    77.5,
    (v) => SemiTabsThemeData(
      spacingTabsTabMoreTriggerIconMarginBottom: v as double,
    ),
    (d) => d.spacingTabsTabMoreTriggerIconMarginBottom,
    (t) => 0.0,
  ),
  (
    r'$spacing-tabs_tab-pane_arrow: 8px',
    77.5,
    (v) => SemiTabsThemeData(spacingTabsTabPaneArrow: v as double),
    (d) => d.spacingTabsTabPaneArrow,
    (t) => 8.0,
  ),
  (
    r'$spacing-tabs_bar_extra-paddingY: 0px',
    77.5,
    (v) => SemiTabsThemeData(spacingTabsBarExtraPaddingY: v as double),
    (d) => d.spacingTabsBarExtraPaddingY,
    (t) => 0.0,
  ),
  (
    r'$spacing-tabs_bar_extra-paddingX: 5px',
    77.5,
    (v) => SemiTabsThemeData(spacingTabsBarExtraPaddingX: v as double),
    (d) => d.spacingTabsBarExtraPaddingX,
    (t) => 5.0,
  ),
  (
    r'$spacing-tabs_tab_icon-marginRight: $spacing-tight',
    77.5,
    (v) => SemiTabsThemeData(spacingTabsTabIconMarginRight: v as double),
    (d) => d.spacingTabsTabIconMarginRight,
    (t) => 8.0,
  ),
  (
    r'$spacing-tabs_tab_icon-top: 3px',
    77.5,
    (v) => SemiTabsThemeData(spacingTabsTabIconTop: v as double),
    (d) => d.spacingTabsTabIconTop,
    (t) => 3.0,
  ),
  (
    r'$spacing-tabs_overflow_icon-marginRight: 4px',
    77.5,
    (v) => SemiTabsThemeData(spacingTabsOverflowIconMarginRight: v as double),
    (d) => d.spacingTabsOverflowIconMarginRight,
    (t) => 4.0,
  ),
  (
    r'$spacing-tabs_overflow_icon-marginLeft: 4px',
    77.5,
    (v) => SemiTabsThemeData(spacingTabsOverflowIconMarginLeft: v as double),
    (d) => d.spacingTabsOverflowIconMarginLeft,
    (t) => 4.0,
  ),
  (
    r'$spacing-tabs_bar_line_tab-paddingTop: $spacing-base',
    77.5,
    (v) => SemiTabsThemeData(spacingTabsBarLineTabPaddingTop: v as double),
    (d) => d.spacingTabsBarLineTabPaddingTop,
    (t) => 16.0,
  ),
  (
    r'$spacing-tabs_bar_line_tab-paddingRight: $spacing-extra-tight',
    77.5,
    (v) => SemiTabsThemeData(spacingTabsBarLineTabPaddingRight: v as double),
    (d) => d.spacingTabsBarLineTabPaddingRight,
    (t) => 4.0,
  ),
  (
    r'$spacing-tabs_bar_line_tab-paddingBottom: $spacing-base - $width-tabs_bar_line_tab-border',
    77.5,
    (v) => SemiTabsThemeData(spacingTabsBarLineTabPaddingBottom: v as double),
    (d) => d.spacingTabsBarLineTabPaddingBottom,
    (t) => 14.0,
  ),
  (
    r'$spacing-tabs_bar_line_tab-paddingLeft: $spacing-extra-tight',
    77.5,
    (v) => SemiTabsThemeData(spacingTabsBarLineTabPaddingLeft: v as double),
    (d) => d.spacingTabsBarLineTabPaddingLeft,
    (t) => 4.0,
  ),
  (
    r'$spacing-tabs_bar_line_tab-marginRight: $spacing-loose',
    77.5,
    (v) => SemiTabsThemeData(spacingTabsBarLineTabMarginRight: v as double),
    (d) => d.spacingTabsBarLineTabMarginRight,
    (t) => 24.0,
  ),
  (
    r'$spacing-tabs_bar_line_tab_small-paddingTop: $spacing-tight',
    77.5,
    (v) => SemiTabsThemeData(spacingTabsBarLineTabSmallPaddingTop: v as double),
    (d) => d.spacingTabsBarLineTabSmallPaddingTop,
    (t) => 8.0,
  ),
  (
    r'$spacing-tabs_bar_line_tab_small-paddingRight: $spacing-extra-tight',
    77.5,
    (v) =>
        SemiTabsThemeData(spacingTabsBarLineTabSmallPaddingRight: v as double),
    (d) => d.spacingTabsBarLineTabSmallPaddingRight,
    (t) => 4.0,
  ),
  (
    r'$spacing-tabs_bar_line_tab_small-paddingBottom: $spacing-tight - $width-tabs_bar_line_tab-border',
    77.5,
    (v) =>
        SemiTabsThemeData(spacingTabsBarLineTabSmallPaddingBottom: v as double),
    (d) => d.spacingTabsBarLineTabSmallPaddingBottom,
    (t) => 6.0,
  ),
  (
    r'$spacing-tabs_bar_line_tab_small-paddingLeft: $spacing-extra-tight',
    77.5,
    (v) =>
        SemiTabsThemeData(spacingTabsBarLineTabSmallPaddingLeft: v as double),
    (d) => d.spacingTabsBarLineTabSmallPaddingLeft,
    (t) => 4.0,
  ),
  (
    r'$spacing-tabs_bar_line_tab_medium-paddingTop: $spacing-base-tight',
    77.5,
    (v) =>
        SemiTabsThemeData(spacingTabsBarLineTabMediumPaddingTop: v as double),
    (d) => d.spacingTabsBarLineTabMediumPaddingTop,
    (t) => 12.0,
  ),
  (
    r'$spacing-tabs_bar_line_tab_medium-paddingRight: $spacing-extra-tight',
    77.5,
    (v) =>
        SemiTabsThemeData(spacingTabsBarLineTabMediumPaddingRight: v as double),
    (d) => d.spacingTabsBarLineTabMediumPaddingRight,
    (t) => 4.0,
  ),
  (
    r'$spacing-tabs_bar_line_tab_medium-paddingBottom: $spacing-base-tight - $width-tabs_bar_line_tab-border',
    77.5,
    (v) => SemiTabsThemeData(
      spacingTabsBarLineTabMediumPaddingBottom: v as double,
    ),
    (d) => d.spacingTabsBarLineTabMediumPaddingBottom,
    (t) => 10.0,
  ),
  (
    r'$spacing-tabs_bar_line_tab_medium-paddingLeft: $spacing-extra-tight',
    77.5,
    (v) =>
        SemiTabsThemeData(spacingTabsBarLineTabMediumPaddingLeft: v as double),
    (d) => d.spacingTabsBarLineTabMediumPaddingLeft,
    (t) => 4.0,
  ),
  (
    r'$spacing-tabs_bar_line_tab_left-padding: 12px',
    77.5,
    (v) => SemiTabsThemeData(spacingTabsBarLineTabLeftPadding: v as double),
    (d) => d.spacingTabsBarLineTabLeftPadding,
    (t) => 12.0,
  ),
  (
    r'$spacing-tabs_bar_line_tab_left_small-padding: $spacing-tight - 2px',
    77.5,
    (v) =>
        SemiTabsThemeData(spacingTabsBarLineTabLeftSmallPadding: v as double),
    (d) => d.spacingTabsBarLineTabLeftSmallPadding,
    (t) => 6.0,
  ),
  (
    r'$spacing-tabs_bar_line_tab_left_medium-padding: $spacing-base-tight - 2px',
    77.5,
    (v) =>
        SemiTabsThemeData(spacingTabsBarLineTabLeftMediumPadding: v as double),
    (d) => d.spacingTabsBarLineTabLeftMediumPadding,
    (t) => 10.0,
  ),
  (
    r'$spacing-tabs_bar_slash_tab-paddingY: 12px',
    77.5,
    (v) => SemiTabsThemeData(spacingTabsBarSlashTabPaddingY: v as double),
    (d) => d.spacingTabsBarSlashTabPaddingY,
    (t) => 12.0,
  ),
  (
    r'$spacing-tabs_bar_slash_tab-paddingX: 0px',
    77.5,
    (v) => SemiTabsThemeData(spacingTabsBarSlashTabPaddingX: v as double),
    (d) => d.spacingTabsBarSlashTabPaddingX,
    (t) => 0.0,
  ),
  (
    r'$spacing-tabs_bar_slash-marginRight: 16px',
    77.5,
    (v) => SemiTabsThemeData(spacingTabsBarSlashMarginRight: v as double),
    (d) => d.spacingTabsBarSlashMarginRight,
    (t) => 16.0,
  ),
  (
    r'$spacing-tabs_bar_slash_line_marginLeft: 16px',
    77.5,
    (v) => SemiTabsThemeData(spacingTabsBarSlashLineMarginLeft: v as double),
    (d) => d.spacingTabsBarSlashLineMarginLeft,
    (t) => 16.0,
  ),
  (
    r'$spacing-tabs_bar_slash_line_marginTop: 3px',
    77.5,
    (v) => SemiTabsThemeData(spacingTabsBarSlashLineMarginTop: v as double),
    (d) => d.spacingTabsBarSlashLineMarginTop,
    (t) => 3.0,
  ),
  (
    r'$spacing-tabs_bar_slash_line_marginBottom: 3px',
    77.5,
    (v) => SemiTabsThemeData(spacingTabsBarSlashLineMarginBottom: v as double),
    (d) => d.spacingTabsBarSlashLineMarginBottom,
    (t) => 3.0,
  ),
  (
    r'$spacing-tabs_content-paddingY: 5px',
    77.5,
    (v) => SemiTabsThemeData(spacingTabsContentPaddingY: v as double),
    (d) => d.spacingTabsContentPaddingY,
    (t) => 5.0,
  ),
  (
    r'$spacing-tabs_content-paddingX: 0',
    77.5,
    (v) => SemiTabsThemeData(spacingTabsContentPaddingX: v as double),
    (d) => d.spacingTabsContentPaddingX,
    (t) => 0.0,
  ),
  (
    r'$spacing-tabs_content_left-paddingX: 5px',
    77.5,
    (v) => SemiTabsThemeData(spacingTabsContentLeftPaddingX: v as double),
    (d) => d.spacingTabsContentLeftPaddingX,
    (t) => 5.0,
  ),
  (
    r'$spacing-tabs_content_left-paddingY: 0',
    77.5,
    (v) => SemiTabsThemeData(spacingTabsContentLeftPaddingY: v as double),
    (d) => d.spacingTabsContentLeftPaddingY,
    (t) => 0.0,
  ),
  (
    r'$spacing-tabs_bar_card_tab-marginRight: $spacing-tight',
    77.5,
    (v) => SemiTabsThemeData(spacingTabsBarCardTabMarginRight: v as double),
    (d) => d.spacingTabsBarCardTabMarginRight,
    (t) => 8.0,
  ),
  (
    r'$spacing-tabs_bar_card_tab_active-paddingTop: $spacing-tight',
    77.5,
    (v) =>
        SemiTabsThemeData(spacingTabsBarCardTabActivePaddingTop: v as double),
    (d) => d.spacingTabsBarCardTabActivePaddingTop,
    (t) => 8.0,
  ),
  (
    r'$spacing-tabs_bar_card_tab_active-paddingBottom: $spacing-tight - 1px',
    77.5,
    (v) => SemiTabsThemeData(
      spacingTabsBarCardTabActivePaddingBottom: v as double,
    ),
    (d) => d.spacingTabsBarCardTabActivePaddingBottom,
    (t) => 7.0,
  ),
  (
    r'$spacing-tabs_bar_card_tab_active-paddingLeft: $spacing-base-tight',
    77.5,
    (v) =>
        SemiTabsThemeData(spacingTabsBarCardTabActivePaddingLeft: v as double),
    (d) => d.spacingTabsBarCardTabActivePaddingLeft,
    (t) => 12.0,
  ),
  (
    r'$spacing-tabs_bar_card_tab_active-paddingRight: $spacing-base-tight',
    77.5,
    (v) =>
        SemiTabsThemeData(spacingTabsBarCardTabActivePaddingRight: v as double),
    (d) => d.spacingTabsBarCardTabActivePaddingRight,
    (t) => 12.0,
  ),
  (
    r'$spacing-tabs_bar_card_tab_left-marginBottom: $spacing-tight',
    77.5,
    (v) =>
        SemiTabsThemeData(spacingTabsBarCardTabLeftMarginBottom: v as double),
    (d) => d.spacingTabsBarCardTabLeftMarginBottom,
    (t) => 8.0,
  ),
  (
    r'$spacing-tabs_bar_card_tab_left_active-paddingY: $spacing-tight',
    77.5,
    (v) =>
        SemiTabsThemeData(spacingTabsBarCardTabLeftActivePaddingY: v as double),
    (d) => d.spacingTabsBarCardTabLeftActivePaddingY,
    (t) => 8.0,
  ),
  (
    r'$spacing-tabs_bar_card_tab_left_active-paddingX: $spacing-base-tight',
    77.5,
    (v) =>
        SemiTabsThemeData(spacingTabsBarCardTabLeftActivePaddingX: v as double),
    (d) => d.spacingTabsBarCardTabLeftActivePaddingX,
    (t) => 12.0,
  ),
  (
    r'$spacing-tabs_bar_card_tab-paddingY: $spacing-tight',
    77.5,
    (v) => SemiTabsThemeData(spacingTabsBarCardTabPaddingY: v as double),
    (d) => d.spacingTabsBarCardTabPaddingY,
    (t) => 8.0,
  ),
  (
    r'$spacing-tabs_bar_card_tab-paddingX: $spacing-base-tight',
    77.5,
    (v) => SemiTabsThemeData(spacingTabsBarCardTabPaddingX: v as double),
    (d) => d.spacingTabsBarCardTabPaddingX,
    (t) => 12.0,
  ),
  (
    r'$spacing-tabs_bar_button_tab_left-marginBottom: $spacing-tight',
    77.5,
    (v) =>
        SemiTabsThemeData(spacingTabsBarButtonTabLeftMarginBottom: v as double),
    (d) => d.spacingTabsBarButtonTabLeftMarginBottom,
    (t) => 8.0,
  ),
  (
    r'$spacing-tabs_bar_button_tab-marginRight: $spacing-tight',
    77.5,
    (v) => SemiTabsThemeData(spacingTabsBarButtonTabMarginRight: v as double),
    (d) => d.spacingTabsBarButtonTabMarginRight,
    (t) => 8.0,
  ),
  (
    r'$spacing-tabs_bar_button_tab-paddingY: $spacing-tight',
    77.5,
    (v) => SemiTabsThemeData(spacingTabsBarButtonTabPaddingY: v as double),
    (d) => d.spacingTabsBarButtonTabPaddingY,
    (t) => 8.0,
  ),
  (
    r'$spacing-tabs_bar_button_tab-paddingX: $spacing-base-tight',
    77.5,
    (v) => SemiTabsThemeData(spacingTabsBarButtonTabPaddingX: v as double),
    (d) => d.spacingTabsBarButtonTabPaddingX,
    (t) => 12.0,
  ),
  (
    r'$radius-tabs_tab_card: var(--semi-border-radius-small) var(--semi-border-radius-small) 0 0',
    const BorderRadius.all(Radius.circular(77)),
    (v) => SemiTabsThemeData(radiusTabsTabCard: v as BorderRadius),
    (d) => d.radiusTabsTabCard,
    (t) => BorderRadius.vertical(
      top: Radius.circular(t.radius.borderRadiusSmall.value),
    ),
  ),
  (
    r'$radius-tabs_tab_card_left: var(--semi-border-radius-small) 0 0 var(--semi-border-radius-small)',
    const BorderRadius.all(Radius.circular(77)),
    (v) => SemiTabsThemeData(radiusTabsTabCardLeft: v as BorderRadius),
    (d) => d.radiusTabsTabCardLeft,
    (t) => BorderRadius.horizontal(
      left: Radius.circular(t.radius.borderRadiusSmall.value),
    ),
  ),
  (
    r'$radius-tabs_tab_button: var(--semi-border-radius-small)',
    77.5,
    (v) => SemiTabsThemeData(radiusTabsTabButton: v as double),
    (d) => d.radiusTabsTabButton,
    (t) => t.radius.borderRadiusSmall.value,
  ),
  (
    r'$font-tabs_bar_large-fontSize: $font-size-regular',
    77.5,
    (v) => SemiTabsThemeData(fontTabsBarLargeFontSize: v as double),
    (d) => d.fontTabsBarLargeFontSize,
    (t) => 14.0,
  ),
  (
    r'$font-tabs_bar_small-fontSize: $font-size-regular',
    77.5,
    (v) => SemiTabsThemeData(fontTabsBarSmallFontSize: v as double),
    (d) => d.fontTabsBarSmallFontSize,
    (t) => 14.0,
  ),
  (
    r'$font-tabs_bar_medium-fontSize: $font-size-regular',
    77.5,
    (v) => SemiTabsThemeData(fontTabsBarMediumFontSize: v as double),
    (d) => d.fontTabsBarMediumFontSize,
    (t) => 14.0,
  ),
  (
    r'$transition_duration-tabs_tab_line-border: var(--semi-transition_duration-none)',
    const Duration(milliseconds: 77),
    (v) =>
        SemiTabsThemeData(transitionDurationTabsTabLineBorder: v as Duration),
    (d) => d.transitionDurationTabsTabLineBorder,
    (t) => Duration.zero,
  ),
  (
    r'$transition_function-tabs_tab_line-border: var(--semi-transition_function-easeIn)',
    Curves.easeInCubic,
    (v) => SemiTabsThemeData(transitionFunctionTabsTabLineBorder: v as Curve),
    (d) => d.transitionFunctionTabsTabLineBorder,
    (t) => Curves.easeIn,
  ),
  (
    r'$transition_delay-tabs_tab_line-border: var(--semi-transition_delay-none)',
    const Duration(milliseconds: 77),
    (v) => SemiTabsThemeData(transitionDelayTabsTabLineBorder: v as Duration),
    (d) => d.transitionDelayTabsTabLineBorder,
    (t) => Duration.zero,
  ),
  (
    r'$transition_duration-tabs_tab_line-text: var(--semi-transition_duration-none)',
    const Duration(milliseconds: 77),
    (v) => SemiTabsThemeData(transitionDurationTabsTabLineText: v as Duration),
    (d) => d.transitionDurationTabsTabLineText,
    (t) => Duration.zero,
  ),
  (
    r'$transition_function-tabs_tab_line-text: var(--semi-transition_function-easeIn)',
    Curves.easeInCubic,
    (v) => SemiTabsThemeData(transitionFunctionTabsTabLineText: v as Curve),
    (d) => d.transitionFunctionTabsTabLineText,
    (t) => Curves.easeIn,
  ),
  (
    r'$transition_delay-tabs_tab_line-text: var(--semi-transition_delay-none)',
    const Duration(milliseconds: 77),
    (v) => SemiTabsThemeData(transitionDelayTabsTabLineText: v as Duration),
    (d) => d.transitionDelayTabsTabLineText,
    (t) => Duration.zero,
  ),
  (
    r'$transition_duration-tabs_tab_button-bg: var(--semi-transition_duration-none)',
    const Duration(milliseconds: 77),
    (v) => SemiTabsThemeData(transitionDurationTabsTabButtonBg: v as Duration),
    (d) => d.transitionDurationTabsTabButtonBg,
    (t) => Duration.zero,
  ),
  (
    r'$transition_function-tabs_tab_button-bg: var(--semi-transition_function-easeIn)',
    Curves.easeInCubic,
    (v) => SemiTabsThemeData(transitionFunctionTabsTabButtonBg: v as Curve),
    (d) => d.transitionFunctionTabsTabButtonBg,
    (t) => Curves.easeIn,
  ),
  (
    r'$transition_delay-tabs_tab_button-bg: var(--semi-transition_delay-none)',
    const Duration(milliseconds: 77),
    (v) => SemiTabsThemeData(transitionDelayTabsTabButtonBg: v as Duration),
    (d) => d.transitionDelayTabsTabButtonBg,
    (t) => Duration.zero,
  ),
  (
    r'$transition_duration-tabs_tab_card-bg: var(--semi-transition_duration-none)',
    const Duration(milliseconds: 77),
    (v) => SemiTabsThemeData(transitionDurationTabsTabCardBg: v as Duration),
    (d) => d.transitionDurationTabsTabCardBg,
    (t) => Duration.zero,
  ),
  (
    r'$transition_function-tabs_tab_card-bg: var(--semi-transition_function-easeIn)',
    Curves.easeInCubic,
    (v) => SemiTabsThemeData(transitionFunctionTabsTabCardBg: v as Curve),
    (d) => d.transitionFunctionTabsTabCardBg,
    (t) => Curves.easeIn,
  ),
  (
    r'$transition_delay-tabs_tab_card-bg: var(--semi-transition_delay-none)',
    const Duration(milliseconds: 77),
    (v) => SemiTabsThemeData(transitionDelayTabsTabCardBg: v as Duration),
    (d) => d.transitionDelayTabsTabCardBg,
    (t) => Duration.zero,
  ),
  (
    r'$transform_scale-tabs_tab_line-item: var(--semi-transform_scale-none)',
    const SemiTransform.scale(3, 2),
    (v) => SemiTabsThemeData(transformScaleTabsTabLineItem: v as SemiTransform),
    (d) => d.transformScaleTabsTabLineItem,
    (t) => const SemiTransform.scale(1, 1),
  ),
  (
    r'$transform_scale-tabs_tab_button-item: var(--semi-transform_scale-none)',
    const SemiTransform.scale(3, 2),
    (v) =>
        SemiTabsThemeData(transformScaleTabsTabButtonItem: v as SemiTransform),
    (d) => d.transformScaleTabsTabButtonItem,
    (t) => const SemiTransform.scale(1, 1),
  ),
  (
    r'$transform_scale-tabs_tab_card-item: var(--semi-transform_scale-none)',
    const SemiTransform.scale(3, 2),
    (v) => SemiTabsThemeData(transformScaleTabsTabCardItem: v as SemiTransform),
    (d) => d.transformScaleTabsTabCardItem,
    (t) => const SemiTransform.scale(1, 1),
  ),
  (
    r'$animation_transform_translateX-tabs_tabPanel-leftShow: 60px',
    77.5,
    (v) => SemiTabsThemeData(
      animationTransformTranslateXTabsTabPanelLeftShow: v as double,
    ),
    (d) => d.animationTransformTranslateXTabsTabPanelLeftShow,
    (t) => 60.0,
  ),
  (
    r'$animation_transform_translateX-tabs_tabPanel-rightShow: -60px',
    77.5,
    (v) => SemiTabsThemeData(
      animationTransformTranslateXTabsTabPanelRightShow: v as double,
    ),
    (d) => d.animationTransformTranslateXTabsTabPanelRightShow,
    (t) => -60.0,
  ),
  (
    r'$animation_transform_translateX-tabs_tabPanel-topShow: 60px',
    77.5,
    (v) => SemiTabsThemeData(
      animationTransformTranslateXTabsTabPanelTopShow: v as double,
    ),
    (d) => d.animationTransformTranslateXTabsTabPanelTopShow,
    (t) => 60.0,
  ),
  (
    r'$animation_transform_translateX-tabs_tabPanel-bottomShow: -60px',
    77.5,
    (v) => SemiTabsThemeData(
      animationTransformTranslateXTabsTabPanelBottomShow: v as double,
    ),
    (d) => d.animationTransformTranslateXTabsTabPanelBottomShow,
    (t) => -60.0,
  ),
  (
    r'$animation_opacity-tabs_tabPanel_show: 0',
    77.5,
    (v) => SemiTabsThemeData(animationOpacityTabsTabPanelShow: v as double),
    (d) => d.animationOpacityTabsTabPanelShow,
    (t) => 0.0,
  ),
  (
    r'$animation_duration-tabs_tabPanel-show: 200ms',
    const Duration(milliseconds: 77),
    (v) => SemiTabsThemeData(animationDurationTabsTabPanelShow: v as Duration),
    (d) => d.animationDurationTabsTabPanelShow,
    (t) => const Duration(milliseconds: 200),
  ),
  (
    r'$animation_function-tabs_tabPanel-show: ease-in-out',
    Curves.easeInCubic,
    (v) => SemiTabsThemeData(animationFunctionTabsTabPanelShow: v as Curve),
    (d) => d.animationFunctionTabsTabPanelShow,
    (t) => Curves.easeInOut,
  ),
  (
    r'$animation_delay-tabs_tabPanel-show: 0s',
    const Duration(milliseconds: 77),
    (v) => SemiTabsThemeData(animationDelayTabsTabPanelShow: v as Duration),
    (d) => d.animationDelayTabsTabPanelShow,
    (t) => Duration.zero,
  ),
];

void main() {
  group('theme fields (144 = 121 FIELDS + 23 MOTION + 0 INTERNAL)', () {
    test('144 fields: merge, copyWith, resolve, equality, defaults', () {
      expect(fields, hasLength(144));
      for (final (sass, value, make, read, expected) in fields) {
        final patch = make(value);
        expect(const SemiTabsThemeData().merge(patch), patch, reason: sass);
        expect(patch.copyWith(), patch, reason: sass);
        expect(patch.copyWith().hashCode, patch.hashCode, reason: sass);
        expect(patch.merge(null), patch, reason: sass);
        expect(
          read(patch.resolve(const SemiThemeData.dark())),
          value,
          reason: sass,
        );
        final light = const SemiThemeData.light();
        expect(
          read(const SemiTabsThemeData().resolve(light)),
          expected(light),
          reason: sass,
        );
        final dark = const SemiThemeData.dark();
        expect(
          read(const SemiTabsThemeData().resolve(dark)),
          expected(dark),
          reason: sass,
        );
      }
    });

    test('every field carries its Sass provenance in the generated source', () {
      final source = File('lib/src/theme/semi_tabs_theme_data.dart')
          .readAsStringSync();
      final names = <String>{};
      for (final (sass, _, _, _, _) in fields) {
        expect(source, contains(sass));
        names.add(sass.split(': ').first.substring(1));
      }
      expect(names, hasLength(144));
      expect(source, contains('packages/semi-foundation/tabs/variables.scss'));
      expect(source, contains('packages/semi-foundation/tabs/animation.scss'));
      expect(source, contains('Generated by tool/generate_tabs.py'));
      expect(source, contains('# dead variable (上游未消费)'));
    });

    test('the 23 HARDCODES anchors live in the widget source', () {
      final widgetSource = File('lib/src/components/semi_tabs.dart')
          .readAsStringSync();
      const anchors = <String>[
        'showRestInDropdown = true',
        "arrowPosition = 'both'",
        'DEFAULT_ACTIVE_KEY: 1',
        "more: '更多'",
        "close: '关闭'",
        'IconChevronDown',
        'IconChevronLeft',
        'IconChevronRight',
        'IconClose',
        'data-tabkey',
        'aria-selected',
        'tabIndex={selected ? 0 : -1}',
        'semi-tabs-pane-motion-overlay',
        '@include font-size-regular',
        ':nth-of-type(1)',
        'margin-left: 10px',
        'transform: scaleX(-1)',
        'translateY(\$animation_transform_translateX-tabs_tabPanel-leftShow)',
        'animation-fill-mode: forwards',
        'linear-gradient(to bottom right',
        'overflow-y: auto',
        'content: ""',
        'width: 1px',
      ];
      expect(anchors, hasLength(23));
      for (final anchor in anchors) {
        expect(widgetSource, contains(anchor), reason: anchor);
      }
    });

    test('type coverage: 48 Color + 2 FontWeight + 74 double + 2 BorderRadius '
        '+ 10 Duration + 5 Curve + 3 SemiTransform = 144', () {
      final counts = <String, int>{};
      for (final (_, value, _, _, _) in fields) {
        counts.update(
          value.runtimeType.toString(),
          (n) => n + 1,
          ifAbsent: () => 1,
        );
      }
      expect(counts['Color'], 48);
      expect(counts['double'], 74);
      expect(counts['FontWeight'], 2);
      expect(counts['BorderRadius'], 2);
      expect(counts['Duration'], 10);
      expect(counts['Cubic'], 5);
      expect(counts['SemiTransform'], 3);
    });

    test('9 dead variables: word-boundary assertNotIn + docs marks', () {
      const deadFields = [
        'colorTabsTabLineDefaultBgDefault',
        'colorTabsTabLineDefaultBgHover',
        'colorTabsTabLineDefaultBgActive',
        'colorTabsTabLineSelectedBgDefault',
        'colorTabsTabLineSelectedIconDefault',
        'colorTabsTabPaneArrowBgHover',
        'colorTabsTabPaneArrowBgActive',
        'animationTransformTranslateXTabsTabPanelTopShow',
        'animationTransformTranslateXTabsTabPanelBottomShow',
      ];
      final widgetSource = File('lib/src/components/semi_tabs.dart')
          .readAsStringSync();
      for (final name in deadFields) {
        final match = RegExp('(?<![A-Za-z])$name(?![A-Za-z])')
            .firstMatch(widgetSource);
        expect(match, isNull, reason: name);
      }
      final docs = File('docs/semi_tabs.md').readAsStringSync();
      expect(docs, contains('144 = 121 FIELDS + 23 MOTION + 0 INTERNAL'));
      expect(docs, contains('9 死变量'));
      expect(docs, contains('（上游未消费）'));
    });

    test('SemiComponentThemes wiring', () {
      const themes = SemiComponentThemes();
      expect(themes.tabs, const SemiTabsThemeData());
      expect(
        themes.copyWith(tabs: const SemiTabsThemeData(widthTabsOutline: 5)),
        const SemiComponentThemes(tabs: SemiTabsThemeData(widthTabsOutline: 5)),
      );
    });
  });

  group('behavior', () {
    testWidgets('selects the first enabled tab and ignores disabled clicks', (
      tester,
    ) async {
      final changes = <String>[];
      await pumpHost(
        tester,
        SemiTabs(
          tabList: const [
            SemiTabData(itemKey: '0', tab: 'Tab 0', disabled: true),
            SemiTabData(itemKey: '1', tab: 'Tab 1', content: Text('pane1')),
            SemiTabData(itemKey: '2', tab: 'Tab 2', content: Text('pane2')),
          ],
          tabPaneMotion: false,
          onChange: changes.add,
        ),
      );
      expect(find.text('pane1'), findsOneWidget);
      await tester.tap(find.text('Tab 0'));
      await tester.pump();
      expect(changes, isEmpty);
      expect(find.text('pane1'), findsOneWidget);
      await tester.tap(find.text('Tab 2'));
      await tester.pump();
      expect(changes, ['2']);
      expect(find.text('pane2'), findsOneWidget);
    });

    testWidgets('defaultActiveKey wins over the first enabled tab', (
      tester,
    ) async {
      await pumpHost(
        tester,
        const SemiTabs(tabList: tabs3, defaultActiveKey: '2'),
      );
      expect(find.text('pane2'), findsOneWidget);
      expect(find.text('pane1'), findsNothing);
    });

    testWidgets('controlled activeKey only reports changes', (tester) async {
      final changes = <String>[];
      await pumpHost(
        tester,
        SemiTabs(
          tabList: tabs3,
          activeKey: '1',
          tabPaneMotion: false,
          onChange: changes.add,
        ),
      );
      await tester.tap(find.text('Tab 2'));
      await tester.pump();
      expect(changes, ['2']);
      expect(find.text('pane1'), findsOneWidget);
      expect(find.text('pane2'), findsNothing);

      await pumpHost(
        tester,
        SemiTabs(
          tabList: tabs3,
          activeKey: '2',
          tabPaneMotion: false,
          onChange: changes.add,
        ),
      );
      expect(find.text('pane2'), findsOneWidget);
    });

    testWidgets('onTabClick fires on the selected tab without onChange', (
      tester,
    ) async {
      final changes = <String>[];
      final clicks = <String>[];
      await pumpHost(
        tester,
        SemiTabs(
          tabList: tabs3,
          tabPaneMotion: false,
          onChange: changes.add,
          onTabClick: clicks.add,
        ),
      );
      await tester.tap(find.text('Tab 1'));
      await tester.pump();
      expect(clicks, ['1']);
      expect(changes, isEmpty);
      await tester.tap(find.text('Tab 2'));
      await tester.pump();
      expect(clicks, ['1', '2']);
      expect(changes, ['2']);
    });

    testWidgets('close icon closes without selecting', (tester) async {
      final closes = <String>[];
      final changes = <String>[];
      await pumpHost(
        tester,
        SemiTabs(
          tabList: const [
            SemiTabData(itemKey: '1', tab: 'Tab 1', content: Text('pane1')),
            SemiTabData(
              itemKey: '2',
              tab: 'Tab 2',
              closable: true,
              content: Text('pane2'),
            ),
          ],
          tabPaneMotion: false,
          onChange: changes.add,
          onTabClose: closes.add,
        ),
      );
      await tester.tap(iconFinder(SemiIcons.close));
      await tester.pump();
      expect(closes, ['2']);
      expect(changes, isEmpty);
      expect(find.text('pane1'), findsOneWidget);
    });

    testWidgets('tabBarExtraContent sits at the end of a top bar', (
      tester,
    ) async {
      await pumpHost(
        tester,
        const SemiTabs(tabList: tabs3, tabBarExtraContent: Text('extra')),
      );
      expect(find.text('extra'), findsOneWidget);
      expect(
        tester.getTopLeft(find.text('extra')).dx,
        greaterThan(tester.getTopLeft(find.text('Tab 1')).dx),
      );
    });

    testWidgets('line selected tab paints a 2px primary bottom border', (
      tester,
    ) async {
      final light = const SemiThemeData.light();
      await pumpHost(tester, const SemiTabs(tabList: tabs3));
      final selected = tabDecoration(tester, 'Tab 1');
      expect(selected.border!.bottom.color, light.colors.colorPrimary);
      expect(selected.border!.bottom.width, 2);
      final idle = tabDecoration(tester, 'Tab 2');
      expect(idle.border!.bottom.color, const Color(0x00000000));
    });

    testWidgets('card selected tab uses the border token and bg-1 mask', (
      tester,
    ) async {
      final light = const SemiThemeData.light();
      await pumpHost(
        tester,
        const SemiTabs(tabList: tabs3, type: SemiTabsType.card),
      );
      final selected = tabCardPainter(tester, 'Tab 1');
      expect(selected.top.color, light.colors.colorBorder);
      expect(selected.bottom.color, light.colors.colorBg1);
      // 描边贴圆角弧走（BoxDecoration 非均匀颜色 + 圆角不允许，圆角画进
      // painter 同形的盒底色里）。
      expect(
        (tabDecoration(tester, 'Tab 1')).borderRadius,
        BorderRadius.vertical(
          top: Radius.circular(light.radius.borderRadiusSmall.value),
        ),
      );
    });

    testWidgets('card bar line is masked under the selected tab only', (
      tester,
    ) async {
      final light = const SemiThemeData.light();
      await pumpHost(
        tester,
        const SemiTabs(tabList: tabs3, type: SemiTabsType.card),
      );
      // 未选中无底边框（上游 `border-bottom: none`）——与选中 8+0 = 7+1 等高，
      // 选中的 bg-1 底边才与条底轨道线同像素行。
      expect(tabCardPainter(tester, 'Tab 2').bottom, BorderSide.none);
      expect(
        tester.getSize(tabContainer('Tab 1')).height,
        tester.getSize(tabContainer('Tab 2')).height,
      );
      final bar = find.ancestor(
        of: tabContainer('Tab 1'),
        matching: find.byWidgetPredicate(
          (w) =>
              w is DecoratedBox &&
              w.decoration is BoxDecoration &&
              (w.decoration as BoxDecoration).border?.bottom.color ==
                  light.colors.colorBorder,
        ),
      );
      // 选中项底边与条底重合 → 盖住轨道线；未选中项留线。
      expect(
        tester.getBottomLeft(tabContainer('Tab 1')).dy,
        tester.getBottomLeft(bar).dy,
      );
    });

    testWidgets('card left bar masks the line on the inner edge', (
      tester,
    ) async {
      final light = const SemiThemeData.light();
      await pumpHost(
        tester,
        const SemiTabs(
          tabList: tabs3,
          type: SemiTabsType.card,
          tabPosition: SemiTabsPosition.left,
        ),
      );
      final selected = tabCardPainter(tester, 'Tab 1');
      // 遮线条是盒外 `::after`（LTR `right: -1px`）；外侧（左）indicator 边，
      // 内侧无边框（上游 `border-right: none`）。
      expect(selected.maskSide, SemiTabsCardMaskSide.right);
      expect(selected.maskColor, light.colors.colorBg1);
      expect(selected.left.color, light.colors.colorBorder);
      expect(selected.right, BorderSide.none);
      // 等宽铺满：遮线条与条侧轨道线同列。
      expect(
        tester.getSize(tabContainer('Tab 1')).width,
        tester.getSize(tabContainer('Tab 2')).width,
      );
      final bar = find.ancestor(
        of: tabContainer('Tab 1'),
        matching: find.byWidgetPredicate(
          (w) =>
              w is DecoratedBox &&
              w.decoration is BoxDecoration &&
              ((w.decoration as BoxDecoration).border as Border?)
                      ?.right
                      .color ==
                  light.colors.colorBorder,
        ),
      );
      // 盒外 1px 遮线条正好落在条边带上：盒右缘 + 1px = 条右缘。
      expect(
        tester.getTopRight(tabContainer('Tab 1')).dx +
            SemiTabsCardPainter.maskWidth,
        tester.getTopRight(bar).dx,
      );
    });

    testWidgets('card press fills fill-1 even on the selected tab', (
      tester,
    ) async {
      final light = const SemiThemeData.light();
      await pumpHost(
        tester,
        const SemiTabs(tabList: tabs3, type: SemiTabsType.card),
      );
      // 选中项 hover 保持 transparent；按下时 `:active`（fill-1）源序靠后
      // 压过 `.tab-active` 的 transparent（真实 semi.css computed style 对账）。
      expect(tabDecoration(tester, 'Tab 1').color, const Color(0x00000000));
      expect(tabDecoration(tester, 'Tab 2').color, const Color(0x00000000));
      final gesture = await tester.startGesture(
        tester.getCenter(tabContainer('Tab 1')),
      );
      await tester.pump();
      expect(tabDecoration(tester, 'Tab 1').color, light.colors.colorFill1);
      await gesture.up();
      await tester.pump();
    });

    testWidgets('card left RTL flips the cover strip (upstream quirk)', (
      tester,
    ) async {
      final light = const SemiThemeData.light();
      await pumpHost(
        tester,
        const SemiTabs(
          tabList: tabs3,
          type: SemiTabsType.card,
          tabPosition: SemiTabsPosition.left,
        ),
        direction: TextDirection.rtl,
      );
      final selected = tabCardPainter(tester, 'Tab 1');
      // ★上游 quirk：`.semi-rtl` 的 `.tab` 规则 (0-4-0) 压过 `.tab-active` →
      // 选中项边框整体透明；`border-radius` 不翻转（仍在左侧两角）。
      expect(selected.maskSide, SemiTabsCardMaskSide.left);
      expect(selected.maskColor, light.colors.colorBg1);
      expect(selected.left, BorderSide.none);
      expect(selected.top.color, const Color(0x00000000));
      expect(selected.right.color, const Color(0x00000000));
    });

    testWidgets('card mask erases the track line on non-bg-1 backgrounds', (
      tester,
    ) async {
      // 上游用 bg-1 盖线：条坐在灰面板上时会露一条白线；移植端改擦除轨道
      // 线——选中项底部应透出面板底色、轨道线在项下断开。
      const panel = Color(0xFFF7F8FA);
      const key = ValueKey('shot');
      // 标签锁 20px 行高（height: 1）→ 页签整数高 37，取样行不落 AA 半像素。
      final list = [
        for (final label in ['Tab 1', 'Tab 2', 'Tab 3'])
          SemiTabData(
            itemKey: label,
            tab: Text(label, style: const TextStyle(fontSize: 20, height: 1)),
          ),
      ];
      await pumpHost(
        tester,
        RepaintBoundary(
          key: key,
          child: Container(
            color: panel,
            child: SemiTabs(tabList: list, type: SemiTabsType.card),
          ),
        ),
      );
      expect(
        tabCardPainter(tester, 'Tab 1').maskSide,
        SemiTabsCardMaskSide.bottom,
      );
      final boundary =
          tester.renderObject(find.byKey(key)) as RenderRepaintBoundary;
      final origin = tester.getTopLeft(find.byKey(key));
      final selected = tester.getRect(tabContainer('Tab 1'));
      final idle = tester.getRect(tabContainer('Tab 2'));
      // toImage 需要真实异步（runAsync）。
      final pixels = await tester.runAsync(() async {
        final image = await boundary.toImage();
        final bytes = (await image.toByteData())!;
        Color at(Offset global) {
          final o = global - origin;
          final i = (o.dy.floor() * image.width + o.dx.floor()) * 4;
          return Color.fromARGB(
            bytes.getUint8(i + 3),
            bytes.getUint8(i),
            bytes.getUint8(i + 1),
            bytes.getUint8(i + 2),
          );
        }

        // 选中项底边 = 遮线带 → 擦除后透出面板底色（不是白线、不是轨道线）；
        // 同一行上未选中项底下轨道线仍在。
        return (
          at(Offset(selected.center.dx, selected.bottom - 0.5)),
          at(Offset(idle.center.dx, selected.bottom - 0.5)),
        );
      });
      expect(pixels!.$1, panel);
      expect(pixels.$2, isNot(panel));
    });

    testWidgets('button selected tab paints primary-light bg + primary text', (
      tester,
    ) async {
      final light = const SemiThemeData.light();
      await pumpHost(
        tester,
        const SemiTabs(tabList: tabs3, type: SemiTabsType.button),
      );
      expect(
        tabDecoration(tester, 'Tab 1').color,
        light.colors.colorPrimaryLightDefault,
      );
      expect(textColorOf(tester, 'Tab 1'), light.colors.colorPrimary);
      expect(textColorOf(tester, 'Tab 2'), light.colors.colorText2);
    });

    testWidgets('line size changes the tab height by 16px (large − small)', (
      tester,
    ) async {
      await pumpHost(
        tester,
        const SemiTabs(tabList: tabs3, size: SemiTabsSize.large),
      );
      final large = tester.getSize(tabContainer('Tab 1')).height;
      await pumpHost(
        tester,
        const SemiTabs(tabList: tabs3, size: SemiTabsSize.small),
      );
      final small = tester.getSize(tabContainer('Tab 1')).height;
      expect(large - small, 16);
    });

    testWidgets('left position renders the bar before the content', (
      tester,
    ) async {
      await pumpHost(
        tester,
        const SemiTabs(tabList: tabs3, tabPosition: SemiTabsPosition.left),
      );
      expect(
        tester.getTopLeft(find.text('Tab 1')).dx,
        lessThan(tester.getTopLeft(find.text('pane1')).dx),
      );
      expect(
        tester.getTopLeft(find.text('Tab 2')).dy,
        greaterThan(tester.getTopLeft(find.text('Tab 1')).dy),
      );
    });

    testWidgets('pane motion fades the entering pane in', (tester) async {
      await pumpHost(tester, const SemiTabs(tabList: tabs3));
      await tester.tap(find.text('Tab 2'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));
      final opacity = find
          .descendant(of: find.byType(SemiTabs), matching: find.byType(Opacity))
          .first;
      expect(tester.widget<Opacity>(opacity).opacity, inExclusiveRange(0, 1));
      await tester.pump(const Duration(milliseconds: 200));
      expect(tester.widget<Opacity>(opacity).opacity, 1);
    });

    testWidgets('tabPaneMotion false renders no opacity wrapper', (
      tester,
    ) async {
      await pumpHost(
        tester,
        const SemiTabs(tabList: tabs3, tabPaneMotion: false),
      );
      await tester.tap(find.text('Tab 2'));
      await tester.pump();
      expect(
        find.descendant(
          of: find.byType(SemiTabs),
          matching: find.byType(Opacity),
        ),
        findsNothing,
      );
    });

    testWidgets('keepDOM false unmounts inactive panes; lazyRender mounts on '
        'visit', (tester) async {
      await pumpHost(
        tester,
        SemiTabs(key: UniqueKey(), tabList: tabs3, keepDOM: false),
      );
      expect(find.text('pane1'), findsOneWidget);
      await tester.tap(find.text('Tab 2'));
      await tester.pump();
      expect(find.text('pane2'), findsOneWidget);
      expect(find.text('pane1', skipOffstage: false), findsNothing);

      await pumpHost(
        tester,
        SemiTabs(key: UniqueKey(), tabList: tabs3, lazyRender: true),
      );
      expect(find.text('pane1'), findsOneWidget);
      expect(find.text('pane2', skipOffstage: false), findsNothing);
      await tester.tap(find.text('Tab 2'));
      await tester.pump();
      expect(find.text('pane2'), findsOneWidget);
      expect(find.text('pane1', skipOffstage: false), findsOneWidget);
    });

    testWidgets('more keeps the first N tabs and selects from the dropdown', (
      tester,
    ) async {
      const list = [
        SemiTabData(itemKey: '1', tab: 'Tab 1', content: Text('pane1')),
        SemiTabData(itemKey: '2', tab: 'Tab 2', content: Text('pane2')),
        SemiTabData(itemKey: '3', tab: 'Tab 3', content: Text('pane3')),
      ];
      final changes = <String>[];
      await pumpHost(
        tester,
        SemiTabs(
          tabList: list,
          more: 1,
          tabPaneMotion: false,
          onChange: changes.add,
        ),
      );
      expect(find.text('Tab 1'), findsOneWidget);
      expect(find.text('Tab 2'), findsOneWidget);
      expect(find.text('Tab 3'), findsNothing);
      expect(find.text('更多'), findsOneWidget);
      // 最后一个可见页签与「更多」触发器之间保留 24px 间距（含两侧 padding）。
      final gap =
          tester.getTopLeft(find.text('更多')).dx -
          tester.getTopRight(find.text('Tab 2')).dx;
      expect(gap, greaterThanOrEqualTo(30));

      final gesture = await tester.createGesture(kind: PointerDeviceKind.mouse);
      await gesture.addPointer(location: Offset.zero);
      addTearDown(gesture.removePointer);
      await gesture.moveTo(tester.getCenter(find.text('更多')));
      await settle(tester);
      expect(find.text('Tab 3'), findsOneWidget);
      await tester.tap(find.text('Tab 3'));
      await tester.pump();
      expect(changes, ['3']);
      expect(find.text('pane3'), findsOneWidget);
    });

    testWidgets('collapsible scrolls the bar with the end arrow', (
      tester,
    ) async {
      await pumpHost(
        tester,
        SemiTabs(
          tabList: [
            for (var i = 0; i < 8; i++)
              SemiTabData(itemKey: '$i', tab: 'Tab $i', content: Text('p$i')),
          ],
          collapsible: true,
          tabPaneMotion: false,
        ),
        width: 300,
      );
      await tester.pump();
      final scrollable = tester.state<ScrollableState>(
        find
            .descendant(
              of: find.byType(SemiTabs),
              matching: find.byType(Scrollable),
            )
            .first,
      );
      expect(scrollable.position.pixels, 0);
      expect(iconFinder(SemiIcons.chevronLeft), findsOneWidget);
      // 箭头与页签同排垂直居中（`.bar-collapse { align-items: center }`）。
      final arrow = tester.getCenter(iconFinder(SemiIcons.chevronLeft)).dy;
      final text = tester.getCenter(find.text('Tab 1')).dy;
      expect((arrow - text).abs(), lessThan(3));
      await tester.tap(iconFinder(SemiIcons.chevronRight));
      await tester.pump(const Duration(milliseconds: 50));
      await tester.pump(const Duration(milliseconds: 300));
      expect(scrollable.position.pixels, greaterThan(0));
    });

    testWidgets('collapsible bar hides the desktop scrollbar', (tester) async {
      debugDefaultTargetPlatformOverride = TargetPlatform.macOS;
      try {
        await pumpHost(
          tester,
          SemiTabs(
            tabList: [
              for (var i = 0; i < 8; i++)
                SemiTabData(itemKey: '$i', tab: 'Tab $i', content: Text('p$i')),
            ],
            collapsible: true,
            tabPaneMotion: false,
          ),
          width: 300,
        );
        await tester.pump();
        // 桌面端 ScrollBehavior 会给滚动区自动包 RawScrollbar；折叠条只用
        // 箭头滚动、不显示滚动条（`copyWith(scrollbars: false)`）。
        expect(
          find.descendant(
            of: find.byType(SemiTabs),
            matching: find.byType(RawScrollbar),
          ),
          findsNothing,
        );
      } finally {
        debugDefaultTargetPlatformOverride = null;
      }
    });

    testWidgets('collapse arrows carry the button radius (not square)', (
      tester,
    ) async {
      final t = const SemiTabsThemeData().resolve(const SemiThemeData.light());
      await pumpHost(
        tester,
        SemiTabs(
          tabList: [
            for (var i = 0; i < 8; i++)
              SemiTabData(itemKey: '$i', tab: 'Tab $i', content: Text('p$i')),
          ],
          collapsible: true,
          tabPaneMotion: false,
        ),
        width: 300,
      );
      // 上游箭头是 `<Button theme="borderless">`（TabBar.tsx）——背景圆角来自
      // `.semi-button` 基座 `$radius-button: var(--semi-border-radius-small)`，
      // 不能是方角。
      final radius = BorderRadius.circular(
        const SemiThemeData.light().radius.borderRadiusSmall.value,
      );
      final arrows = find.byWidgetPredicate(
        (w) =>
            w is Container &&
            w.padding == EdgeInsets.all(t.spacingTabsTabPaneArrow) &&
            w.decoration is BoxDecoration &&
            (w.decoration as BoxDecoration).borderRadius == radius,
      );
      expect(arrows, findsNWidgets(2));
    });

    testWidgets('keyboard arrows move focus and Enter activates', (
      tester,
    ) async {
      await pumpHost(
        tester,
        const SemiTabs(tabList: tabs3, tabPaneMotion: false),
      );
      await tester.tap(find.text('Tab 1'));
      await tester.pump();
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
      await tester.pump();
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.pump();
      expect(find.text('pane2'), findsOneWidget);
    });

    testWidgets('focus ring is focus-visible gated (no ring on click)', (
      tester,
    ) async {
      await pumpHost(
        tester,
        const SemiTabs(tabList: tabs3, tabPaneMotion: false),
      );
      Finder ring() => find.byWidgetPredicate(
        (w) =>
            w is CustomPaint &&
            w.painter.runtimeType.toString() == '_FocusRingPainter',
      );
      // 点击聚焦不画焦点环（`:focus-visible`）。
      await tester.tap(find.text('Tab 1'));
      await tester.pump();
      expect(ring(), findsNothing);
      // 键盘移动焦点才画环。
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
      await tester.pump();
      expect(ring(), findsOneWidget);
      // 鼠标按回清键盘模态，环消失（button 先例）。
      final gesture = await tester.startGesture(
        tester.getCenter(find.text('Tab 2')),
      );
      await tester.pump();
      expect(ring(), findsNothing);
      await gesture.up();
    });

    testWidgets('RTL mirrors the tab order', (tester) async {
      const list = [
        SemiTabData(itemKey: '1', tab: 'Tab 1', content: Text('pane1')),
        SemiTabData(itemKey: '2', tab: 'Tab 2', content: Text('pane2')),
        SemiTabData(itemKey: '3', tab: 'Tab 3', content: Text('pane3')),
      ];
      await pumpHost(
        tester,
        const SemiTabs(tabList: list, tabPaneMotion: false),
        direction: TextDirection.rtl,
      );
      expect(
        tester.getTopLeft(find.text('Tab 1')).dx,
        greaterThan(tester.getTopLeft(find.text('Tab 2')).dx),
      );
      await tester.tap(find.text('Tab 1'));
      await tester.pump();
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
      await tester.pump();
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.pump();
      // RTL 下“视觉向右”是前一项：Tab 1 → Tab 3（LTR 会到 Tab 2）。
      expect(find.text('pane3'), findsOneWidget);
    });

    testWidgets('slash type draws separators between visible tabs', (
      tester,
    ) async {
      await pumpHost(
        tester,
        const SemiTabs(tabList: tabs3, type: SemiTabsType.slash),
      );
      final paints = find.descendant(
        of: find.byType(SemiTabs),
        matching: find.byType(CustomPaint),
      );
      expect(paints, findsWidgets);
      expect(tester.takeException(), isNull);
    });

    testWidgets('a local theme patch drives tab colors and metrics', (
      tester,
    ) async {
      await pumpHost(
        tester,
        SemiTabsTheme(
          data: const SemiTabsThemeData(
            colorTabsTabLineIndicatorSelectedIconDefault: Color(0xFF00FF00),
            spacingTabsBarLineTabPaddingTop: 30,
          ),
          child: const SemiTabs(tabList: tabs3, tabPaneMotion: false),
        ),
      );
      expect(
        tabDecoration(tester, 'Tab 1').border!.bottom.color,
        const Color(0xFF00FF00),
      );
      expect(tester.getSize(tabContainer('Tab 1')).height, greaterThan(46));
    });
  });
}
