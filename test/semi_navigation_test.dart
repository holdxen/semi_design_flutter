// Behavior matrix for SemiNavigation plus coverage for the 122 Sass declarations
// (119 FIELDS + 3 MOTION + 0 INTERNAL) — the 20 HARDCODES provenance anchors
// live in the widget's `_NavigationMetrics` / call sites, ★10 死变量（迄今最多）:
// 9 真死 + 1 事实死 keep their theme fields but the widget must never mention
// their field names (assertNotIn) and the docs rows are marked （上游未消费）.
import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:semi_design_flutter/semi_design_flutter.dart';

/// The host body is served through a notifier: `Overlay.initialEntries` is
/// initState-only, so the entry must rebuild its child from outside (the
/// semi_tag_input_test.dart host precedent).
final _hostBody = ValueNotifier<Widget>(const SizedBox.shrink());

Widget host(
  Widget child, {
  TextDirection direction = TextDirection.ltr,
  double width = 900,
  double height = 900,
}) {
  _hostBody.value = KeyedSubtree(key: UniqueKey(), child: child);
  return SemiTheme(
    data: const SemiThemeData.light(),
    child: Directionality(
      textDirection: direction,
      child: MediaQuery(
        data: const MediaQueryData(size: Size(1200, 900)),
        child: Overlay(
          initialEntries: [
            OverlayEntry(
              builder: (context) => ValueListenableBuilder<Widget>(
                valueListenable: _hostBody,
                builder: (context, child, _) => Center(
                  child: SizedBox(width: width, height: height, child: child),
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

Future<TestGesture> startMouse(WidgetTester tester) async {
  final gesture = await tester.createGesture(kind: ui.PointerDeviceKind.mouse);
  await gesture.addPointer(location: Offset.zero);
  addTearDown(gesture.removePointer);
  return gesture;
}

/// Pump [host] on a tall test surface.
Future<void> pumpHost(
  WidgetTester tester,
  Widget child, {
  TextDirection direction = TextDirection.ltr,
  double width = 900,
  double height = 900,
}) async {
  await tester.binding.setSurfaceSize(const Size(1200, 1200));
  await tester.pumpWidget(
    host(child, direction: direction, width: width, height: height),
  );
}

/// known_issues.md #1（滚动贴边 tap 失效一次怪癖）：滚动列表贴边点击前补一次
/// 中性 tap（外场空白处），吃掉那一次失效命中。
Future<void> neutralTap(WidgetTester tester) async {
  await tester.tapAt(const Offset(1180, 20));
  await tester.pump();
}

// -- fixtures ----------------------------------------------------------------

Widget nav({
  List<Object> items = const <Object>[],
  SemiNavigationMode mode = SemiNavigationMode.vertical,
  List<Object>? selectedKeys,
  List<Object>? defaultSelectedKeys,
  List<Object>? openKeys,
  List<Object>? defaultOpenKeys,
  bool? isCollapsed,
  bool? defaultIsCollapsed,
  void Function(SemiNavigationSelectInfo info)? onSelect,
  void Function(SemiNavigationOpenInfo info)? onOpenChange,
  ValueChanged<bool>? onCollapseChange,
  void Function(SemiNavigationClickInfo info)? onClick,
  SemiNavigationHeader? header,
  SemiNavigationFooter? footer,
  bool limitIndent = true,
  SemiNavigationToggleIconPosition toggleIconPosition =
      SemiNavigationToggleIconPosition.right,
  Widget? expandIcon,
  bool subNavMotion = true,
}) => SemiNavigation(
  items: items,
  mode: mode,
  selectedKeys: selectedKeys,
  defaultSelectedKeys: defaultSelectedKeys,
  openKeys: openKeys,
  defaultOpenKeys: defaultOpenKeys,
  isCollapsed: isCollapsed,
  defaultIsCollapsed: defaultIsCollapsed,
  onSelect: onSelect,
  onOpenChange: onOpenChange,
  onCollapseChange: onCollapseChange,
  onClick: onClick,
  header: header,
  footer: footer,
  limitIndent: limitIndent,
  toggleIconPosition: toggleIconPosition,
  expandIcon: expandIcon,
  subNavMotion: subNavMotion,
);

/// 2-level fixture: Sub1 [ChildA, ChildB] + ItemC.
List<Object> nestedItems({
  bool childADisabled = false,
  bool subDisabled = false,
}) => [
  SemiNavigationItem(
    itemKey: 's1',
    text: 'Sub1',
    disabled: subDisabled,
    items: [
      SemiNavigationItem(
        itemKey: 'a',
        text: 'ChildA',
        disabled: childADisabled,
      ),
      const SemiNavigationItem(itemKey: 'b', text: 'ChildB'),
    ],
  ),
  const SemiNavigationItem(itemKey: 'c', text: 'ItemC'),
];

// -- finders / measurements --------------------------------------------------

/// nearest row container of a labelled text (rows are AnimatedContainer).
Finder rowOf(String text) => find
    .ancestor(of: find.text(text), matching: find.byType(AnimatedContainer))
    .first;

double textDx(WidgetTester tester, String text) =>
    tester.getTopLeft(find.text(text)).dx;

/// 读行级 Semantics 的 selected 属性（aria 近似，见 widget 差异清单 28）。
bool selectedFlag(WidgetTester tester, String text) {
  final rows = find
      .ancestor(of: find.text(text), matching: find.byType(Semantics))
      .evaluate()
      .map((e) => e.widget as Semantics)
      .where((w) => w.properties.selected != null);
  return rows.isNotEmpty && rows.first.properties.selected!;
}

// -- theme field table -------------------------------------------------------

typedef _Patch = SemiNavigationThemeData Function(Object value);
typedef _Read = Object? Function(SemiResolvedNavigationThemeData data);
typedef _Default = Object? Function(SemiThemeData theme);

final List<(String, Object, _Patch, _Read, _Default)> fields = [
  (
    r'$height-navigation_item_base: 36px',
    101.0,
    (v) => SemiNavigationThemeData(heightNavigationItemBase: v as double),
    (d) => d.heightNavigationItemBase,
    (t) => 36.0,
  ),
  (
    r'$width-navigation_container_base: 240px',
    102.0,
    (v) => SemiNavigationThemeData(widthNavigationContainerBase: v as double),
    (d) => d.widthNavigationContainerBase,
    (t) => 240.0,
  ),
  (
    r'$width-navigation_container_collapsed: 60px',
    103.0,
    (v) =>
        SemiNavigationThemeData(widthNavigationContainerCollapsed: v as double),
    (d) => d.widthNavigationContainerCollapsed,
    (t) => 60.0,
  ),
  (
    r'$width-navigation_header_logo: 36px',
    104.0,
    (v) => SemiNavigationThemeData(widthNavigationHeaderLogo: v as double),
    (d) => d.widthNavigationHeaderLogo,
    (t) => 36.0,
  ),
  (
    r'$height-navigation_header_logo: 36px',
    105.0,
    (v) => SemiNavigationThemeData(heightNavigationHeaderLogo: v as double),
    (d) => d.heightNavigationHeaderLogo,
    (t) => 36.0,
  ),
  (
    r'$height-navigation_header_logo_collapsed: 36px',
    106.0,
    (v) => SemiNavigationThemeData(
      heightNavigationHeaderLogoCollapsed: v as double,
    ),
    (d) => d.heightNavigationHeaderLogoCollapsed,
    (t) => 36.0,
  ),
  (
    r'$height-navigation_footer: 48px',
    107.0,
    (v) => SemiNavigationThemeData(heightNavigationFooter: v as double),
    (d) => d.heightNavigationFooter,
    (t) => 48.0,
  ),
  (
    r'$height-navigation_horizontal_header: 60px',
    108.0,
    (v) =>
        SemiNavigationThemeData(heightNavigationHorizontalHeader: v as double),
    (d) => d.heightNavigationHorizontalHeader,
    (t) => 60.0,
  ),
  (
    r'$width-navigation_icon_text_between: 12px',
    109.0,
    (v) => SemiNavigationThemeData(widthNavigationIconTextBetween: v as double),
    (d) => d.widthNavigationIconTextBetween,
    (t) => 12.0,
  ),
  (
    r'$width-navigation_icon_left: 20px',
    110.0,
    (v) => SemiNavigationThemeData(widthNavigationIconLeft: v as double),
    (d) => d.widthNavigationIconLeft,
    (t) => 20.0,
  ),
  (
    r'$width-navigation_item-borderRadius: var(--semi-border-radius-small)',
    111.0,
    (v) =>
        SemiNavigationThemeData(widthNavigationItemBorderRadius: v as double),
    (d) => d.widthNavigationItemBorderRadius,
    (t) => t.radius.borderRadiusSmall.value,
  ),
  (
    r'$width-navigation_dropdown_item_nav_item-minWidth: 150px',
    112.0,
    (v) => SemiNavigationThemeData(
      widthNavigationDropdownItemNavItemMinWidth: v as double,
    ),
    (d) => d.widthNavigationDropdownItemNavItemMinWidth,
    (t) => 150.0,
  ),
  (
    r'$width-navigation_border: 1px',
    113.0,
    (v) => SemiNavigationThemeData(widthNavigationBorder: v as double),
    (d) => d.widthNavigationBorder,
    (t) => 1.0,
  ),
  (
    r'$width-navigation_footer_border: 1px',
    114.0,
    (v) => SemiNavigationThemeData(widthNavigationFooterBorder: v as double),
    (d) => d.widthNavigationFooterBorder,
    (t) => 1.0,
  ),
  (
    r'$width-navigation_icon_left-minWidth: 20px',
    115.0,
    (v) =>
        SemiNavigationThemeData(widthNavigationIconLeftMinWidth: v as double),
    (d) => d.widthNavigationIconLeftMinWidth,
    (t) => 20.0,
  ),
  (
    r'$width-navigation-outline: 2px',
    116.0,
    (v) => SemiNavigationThemeData(widthNavigationOutline: v as double),
    (d) => d.widthNavigationOutline,
    (t) => 2.0,
  ),
  (
    r'$width-navigation-outlineOffset: -2px',
    117.0,
    (v) => SemiNavigationThemeData(widthNavigationOutlineOffset: v as double),
    (d) => d.widthNavigationOutlineOffset,
    (t) => -2.0,
  ),
  (
    r'$spacing-navigation-paddingX: $spacing-tight',
    118.0,
    (v) => SemiNavigationThemeData(spacingNavigationPaddingX: v as double),
    (d) => d.spacingNavigationPaddingX,
    (t) => 8.0,
  ),
  (
    r'$spacing-navigation_collapsed-paddingX: $spacing-tight',
    119.0,
    (v) => SemiNavigationThemeData(
      spacingNavigationCollapsedPaddingX: v as double,
    ),
    (d) => d.spacingNavigationCollapsedPaddingX,
    (t) => 8.0,
  ),
  (
    r'$spacing-navigation_item-paddingX: $spacing-base-tight',
    120.0,
    (v) => SemiNavigationThemeData(spacingNavigationItemPaddingX: v as double),
    (d) => d.spacingNavigationItemPaddingX,
    (t) => 12.0,
  ),
  (
    r'$spacing-navigation_item-paddingY: $spacing-tight',
    121.0,
    (v) => SemiNavigationThemeData(spacingNavigationItemPaddingY: v as double),
    (d) => d.spacingNavigationItemPaddingY,
    (t) => 8.0,
  ),
  (
    r'$spacing-navigation_item-marginBottom: $spacing-tight',
    122.0,
    (v) =>
        SemiNavigationThemeData(spacingNavigationItemMarginBottom: v as double),
    (d) => d.spacingNavigationItemMarginBottom,
    (t) => 8.0,
  ),
  (
    r'$spacing-navigation_sub_title-marginBottom: 0',
    123.0,
    (v) => SemiNavigationThemeData(
      spacingNavigationSubTitleMarginBottom: v as double,
    ),
    (d) => d.spacingNavigationSubTitleMarginBottom,
    (t) => 0.0,
  ),
  (
    r'$spacing-navigation_sub_wrap-marginTop: 0',
    124.0,
    (v) =>
        SemiNavigationThemeData(spacingNavigationSubWrapMarginTop: v as double),
    (d) => d.spacingNavigationSubWrapMarginTop,
    (t) => 0.0,
  ),
  (
    r'$spacing-navigation_sub_wrap-padding: 0',
    125.0,
    (v) =>
        SemiNavigationThemeData(spacingNavigationSubWrapPadding: v as double),
    (d) => d.spacingNavigationSubWrapPadding,
    (t) => 0.0,
  ),
  (
    r'$spacing-navigation_sub-padding: 0',
    126.0,
    (v) => SemiNavigationThemeData(spacingNavigationSubPadding: v as double),
    (d) => d.spacingNavigationSubPadding,
    (t) => 0.0,
  ),
  (
    r'$spacing-navigation_item_sub-padding: 0',
    127.0,
    (v) =>
        SemiNavigationThemeData(spacingNavigationItemSubPadding: v as double),
    (d) => d.spacingNavigationItemSubPadding,
    (t) => 0.0,
  ),
  (
    r'$spacing-navigation_header_logo-marginLeft: 0',
    128.0,
    (v) => SemiNavigationThemeData(
      spacingNavigationHeaderLogoMarginLeft: v as double,
    ),
    (d) => d.spacingNavigationHeaderLogoMarginLeft,
    (t) => 0.0,
  ),
  (
    r'$spacing-navigation_header_logo-marginRight: 8px',
    129.0,
    (v) => SemiNavigationThemeData(
      spacingNavigationHeaderLogoMarginRight: v as double,
    ),
    (d) => d.spacingNavigationHeaderLogoMarginRight,
    (t) => 8.0,
  ),
  (
    r'$spacing-navigation_header-paddingTop: 32px',
    130.0,
    (v) =>
        SemiNavigationThemeData(spacingNavigationHeaderPaddingTop: v as double),
    (d) => d.spacingNavigationHeaderPaddingTop,
    (t) => 32.0,
  ),
  (
    r'$spacing-navigation_header-paddingBottom: 36px',
    131.0,
    (v) => SemiNavigationThemeData(
      spacingNavigationHeaderPaddingBottom: v as double,
    ),
    (d) => d.spacingNavigationHeaderPaddingBottom,
    (t) => 36.0,
  ),
  (
    r'$spacing-navigation_list_wrapper-paddingTop: 12px',
    132.0,
    (v) => SemiNavigationThemeData(
      spacingNavigationListWrapperPaddingTop: v as double,
    ),
    (d) => d.spacingNavigationListWrapperPaddingTop,
    (t) => 12.0,
  ),
  (
    r'$spacing-navigation_footer-paddingX: 24px',
    133.0,
    (v) =>
        SemiNavigationThemeData(spacingNavigationFooterPaddingX: v as double),
    (d) => d.spacingNavigationFooterPaddingX,
    (t) => 24.0,
  ),
  (
    r'$spacing-navigation_footer-paddingY: 16px',
    134.0,
    (v) =>
        SemiNavigationThemeData(spacingNavigationFooterPaddingY: v as double),
    (d) => d.spacingNavigationFooterPaddingY,
    (t) => 16.0,
  ),
  (
    r'$spacing-navigation_footer_collapse_btn_inner-paddingX: 8px',
    135.0,
    (v) => SemiNavigationThemeData(
      spacingNavigationFooterCollapseBtnInnerPaddingX: v as double,
    ),
    (d) => d.spacingNavigationFooterCollapseBtnInnerPaddingX,
    (t) => 8.0,
  ),
  (
    r'$spacing-navigation_horizontal_header_logo-marginLeft: 24px',
    136.0,
    (v) => SemiNavigationThemeData(
      spacingNavigationHorizontalHeaderLogoMarginLeft: v as double,
    ),
    (d) => d.spacingNavigationHorizontalHeaderLogoMarginLeft,
    (t) => 24.0,
  ),
  (
    r'$spacing-navigation_horizontal_header_logo-marginRight: 24px',
    137.0,
    (v) => SemiNavigationThemeData(
      spacingNavigationHorizontalHeaderLogoMarginRight: v as double,
    ),
    (d) => d.spacingNavigationHorizontalHeaderLogoMarginRight,
    (t) => 24.0,
  ),
  (
    r'$spacing-navigation_horizontal-paddingLeft: 24px',
    138.0,
    (v) => SemiNavigationThemeData(
      spacingNavigationHorizontalPaddingLeft: v as double,
    ),
    (d) => d.spacingNavigationHorizontalPaddingLeft,
    (t) => 24.0,
  ),
  (
    r'$spacing-navigation_horizontal-paddingRight: 24px',
    139.0,
    (v) => SemiNavigationThemeData(
      spacingNavigationHorizontalPaddingRight: v as double,
    ),
    (d) => d.spacingNavigationHorizontalPaddingRight,
    (t) => 24.0,
  ),
  (
    r'$spacing-navigation_dropdown_item_nav_sub_title-paddingX: $spacing-base-tight',
    140.0,
    (v) => SemiNavigationThemeData(
      spacingNavigationDropdownItemNavSubTitlePaddingX: v as double,
    ),
    (d) => d.spacingNavigationDropdownItemNavSubTitlePaddingX,
    (t) => 12.0,
  ),
  (
    r'$spacing-navigation_dropdown_item_nav_sub_title-paddingY: $spacing-tight',
    141.0,
    (v) => SemiNavigationThemeData(
      spacingNavigationDropdownItemNavSubTitlePaddingY: v as double,
    ),
    (d) => d.spacingNavigationDropdownItemNavSubTitlePaddingY,
    (t) => 8.0,
  ),
  (
    r'$spacing-navigation_dropdown_item_nav_item-marginTop: 0',
    142.0,
    (v) => SemiNavigationThemeData(
      spacingNavigationDropdownItemNavItemMarginTop: v as double,
    ),
    (d) => d.spacingNavigationDropdownItemNavItemMarginTop,
    (t) => 0.0,
  ),
  (
    r'$spacing-navigation_dropdown_item_nav_item-marginBottom: 0',
    143.0,
    (v) => SemiNavigationThemeData(
      spacingNavigationDropdownItemNavItemMarginBottom: v as double,
    ),
    (d) => d.spacingNavigationDropdownItemNavItemMarginBottom,
    (t) => 0.0,
  ),
  (
    r'$spacing-navigation_vertical_nav_item_last-marginBottom: 0',
    144.0,
    (v) => SemiNavigationThemeData(
      spacingNavigationVerticalNavItemLastMarginBottom: v as double,
    ),
    (d) => d.spacingNavigationVerticalNavItemLastMarginBottom,
    (t) => 0.0,
  ),
  (
    r'$spacing-navigation_vertical_nav_header-paddingLeft:  ($width-navigation_container_collapsed - $spacing-navigation_collapsed-paddingX * 2 - $width-navigation_border - $height-navigation_header_logo_collapsed) * 0.5',
    145.0,
    (v) => SemiNavigationThemeData(
      spacingNavigationVerticalNavHeaderPaddingLeft: v as double,
    ),
    (d) => d.spacingNavigationVerticalNavHeaderPaddingLeft,
    (t) => 3.5,
  ),
  (
    r'$spacing-navigation_vertical_nav_header-paddingRight: $spacing-tight',
    146.0,
    (v) => SemiNavigationThemeData(
      spacingNavigationVerticalNavHeaderPaddingRight: v as double,
    ),
    (d) => d.spacingNavigationVerticalNavHeaderPaddingRight,
    (t) => 8.0,
  ),
  (
    r'$spacing-navigation_vertical_nav_header_collapsed-paddingLeft: ($width-navigation_container_collapsed - $spacing-navigation_collapsed-paddingX * 2 - $width-navigation_border - $height-navigation_header_logo_collapsed) * 0.5',
    147.0,
    (v) => SemiNavigationThemeData(
      spacingNavigationVerticalNavHeaderCollapsedPaddingLeft: v as double,
    ),
    (d) => d.spacingNavigationVerticalNavHeaderCollapsedPaddingLeft,
    (t) => 3.5,
  ),
  (
    r'$spacing-navigation_vertical_nav_header_collapsed-paddingRight: 0',
    148.0,
    (v) => SemiNavigationThemeData(
      spacingNavigationVerticalNavHeaderCollapsedPaddingRight: v as double,
    ),
    (d) => d.spacingNavigationVerticalNavHeaderCollapsedPaddingRight,
    (t) => 0.0,
  ),
  (
    r'$spacing-navigation_vertical_footer-paddingLeft: $spacing-tight',
    149.0,
    (v) => SemiNavigationThemeData(
      spacingNavigationVerticalFooterPaddingLeft: v as double,
    ),
    (d) => d.spacingNavigationVerticalFooterPaddingLeft,
    (t) => 8.0,
  ),
  (
    r'$spacing-navigation_vertical_footer-paddingRight: $spacing-tight',
    150.0,
    (v) => SemiNavigationThemeData(
      spacingNavigationVerticalFooterPaddingRight: v as double,
    ),
    (d) => d.spacingNavigationVerticalFooterPaddingRight,
    (t) => 8.0,
  ),
  (
    r'$spacing-navigation_vertical_footer_semi_button_content_right-marginLeft: 12px',
    151.0,
    (v) => SemiNavigationThemeData(
      spacingNavigationVerticalFooterSemiButtonContentRightMarginLeft:
          v as double,
    ),
    (d) => d.spacingNavigationVerticalFooterSemiButtonContentRightMarginLeft,
    (t) => 12.0,
  ),
  (
    r'$spacing-navigation_horizontal_nav_list_item-marginBottom: 0',
    152.0,
    (v) => SemiNavigationThemeData(
      spacingNavigationHorizontalNavListItemMarginBottom: v as double,
    ),
    (d) => d.spacingNavigationHorizontalNavListItemMarginBottom,
    (t) => 0.0,
  ),
  (
    r'$spacing-navigation_horizontal_nav_list_item_not_last-marginRight: $spacing-tight',
    153.0,
    (v) => SemiNavigationThemeData(
      spacingNavigationHorizontalNavListItemNotLastMarginRight: v as double,
    ),
    (d) => d.spacingNavigationHorizontalNavListItemNotLastMarginRight,
    (t) => 8.0,
  ),
  (
    r'$spacing-navigation_horizontal_icon_first-marginRight: $spacing-tight',
    154.0,
    (v) => SemiNavigationThemeData(
      spacingNavigationHorizontalIconFirstMarginRight: v as double,
    ),
    (d) => d.spacingNavigationHorizontalIconFirstMarginRight,
    (t) => 8.0,
  ),
  (
    r'$spacing-navigation_horizontal_icon_last-marginLeft: $spacing-tight',
    155.0,
    (v) => SemiNavigationThemeData(
      spacingNavigationHorizontalIconLastMarginLeft: v as double,
    ),
    (d) => d.spacingNavigationHorizontalIconLastMarginLeft,
    (t) => 8.0,
  ),
  (
    r'$spacing-navigation_sub_item_first_child-marginTop: $spacing-tight',
    156.0,
    (v) => SemiNavigationThemeData(
      spacingNavigationSubItemFirstChildMarginTop: v as double,
    ),
    (d) => d.spacingNavigationSubItemFirstChildMarginTop,
    (t) => 8.0,
  ),
  (
    r'$spacing-navigation_sub_item_left_toggle_marginRight:$spacing-tight',
    157.0,
    (v) => SemiNavigationThemeData(
      spacingNavigationSubItemLeftToggleMarginRight: v as double,
    ),
    (d) => d.spacingNavigationSubItemLeftToggleMarginRight,
    (t) => 8.0,
  ),
  (
    r'$color-navigation-bg-default: var(--semi-color-nav-bg)',
    const Color(0xff010101),
    (v) => SemiNavigationThemeData(colorNavigationBgDefault: v as Color),
    (d) => d.colorNavigationBgDefault,
    (t) => t.colors.colorNavBg,
  ),
  (
    r'$color-navigation_border-default: var(--semi-color-border)',
    const Color(0xff020202),
    (v) => SemiNavigationThemeData(colorNavigationBorderDefault: v as Color),
    (d) => d.colorNavigationBorderDefault,
    (t) => t.colors.colorBorder,
  ),
  (
    r'$color-navigation_header-text-default: var(--semi-color-text-0)',
    const Color(0xff030303),
    (v) =>
        SemiNavigationThemeData(colorNavigationHeaderTextDefault: v as Color),
    (d) => d.colorNavigationHeaderTextDefault,
    (t) => t.colors.colorText0,
  ),
  (
    r'$color-navigation_footer_icon-default: var(--semi-color-text-1)',
    const Color(0xff040404),
    (v) =>
        SemiNavigationThemeData(colorNavigationFooterIconDefault: v as Color),
    (d) => d.colorNavigationFooterIconDefault,
    (t) => t.colors.colorText1,
  ),
  (
    r'$color-navigation_itemL1-bg-default: transparent',
    const Color(0xff050505),
    (v) => SemiNavigationThemeData(colorNavigationItemL1BgDefault: v as Color),
    (d) => d.colorNavigationItemL1BgDefault,
    (t) => const Color(0x00000000),
  ),
  (
    r'$color-navigation_itemL1-text-default: var(--semi-color-text-0)',
    const Color(0xff060606),
    (v) =>
        SemiNavigationThemeData(colorNavigationItemL1TextDefault: v as Color),
    (d) => d.colorNavigationItemL1TextDefault,
    (t) => t.colors.colorText0,
  ),
  (
    r'$color-navigation_itemL1_icon-default: var(--semi-color-text-2)',
    const Color(0xff070707),
    (v) =>
        SemiNavigationThemeData(colorNavigationItemL1IconDefault: v as Color),
    (d) => d.colorNavigationItemL1IconDefault,
    (t) => t.colors.colorText2,
  ),
  (
    r'$color-navigation_itemL1-bg-hover: var(--semi-color-fill-0)',
    const Color(0xff080808),
    (v) => SemiNavigationThemeData(colorNavigationItemL1BgHover: v as Color),
    (d) => d.colorNavigationItemL1BgHover,
    (t) => t.colors.colorFill0,
  ),
  (
    r'$color-navigation_itemL1-text-hover: var(--semi-color-text-0)',
    const Color(0xff090909),
    (v) => SemiNavigationThemeData(colorNavigationItemL1TextHover: v as Color),
    (d) => d.colorNavigationItemL1TextHover,
    (t) => t.colors.colorText0,
  ),
  (
    r'$color-navigation_itemL1_icon-hover: var(--semi-color-text-2)',
    const Color(0xff0a0a0a),
    (v) => SemiNavigationThemeData(colorNavigationItemL1IconHover: v as Color),
    (d) => d.colorNavigationItemL1IconHover,
    (t) => t.colors.colorText2,
  ),
  (
    r'$color-navigation_itemL1_selected-text-hover: var(--semi-color-text-0)',
    const Color(0xff0b0b0b),
    (v) => SemiNavigationThemeData(
      colorNavigationItemL1SelectedTextHover: v as Color,
    ),
    (d) => d.colorNavigationItemL1SelectedTextHover,
    (t) => t.colors.colorText0,
  ),
  (
    r'$color-navigation_itemL1-bg-active: var(--semi-color-fill-1)',
    const Color(0xff0c0c0c),
    (v) => SemiNavigationThemeData(colorNavigationItemL1BgActive: v as Color),
    (d) => d.colorNavigationItemL1BgActive,
    (t) => t.colors.colorFill1,
  ),
  (
    r'$color-navigation_itemL1-text-active: var(--semi-color-text-0)',
    const Color(0xff0d0d0d),
    (v) => SemiNavigationThemeData(colorNavigationItemL1TextActive: v as Color),
    (d) => d.colorNavigationItemL1TextActive,
    (t) => t.colors.colorText0,
  ),
  (
    r'$color-navigation_itemL1_icon-active: var(--semi-color-text-2)',
    const Color(0xff0e0e0e),
    (v) => SemiNavigationThemeData(colorNavigationItemL1IconActive: v as Color),
    (d) => d.colorNavigationItemL1IconActive,
    (t) => t.colors.colorText2,
  ),
  (
    r'$color-navigation_itemL1_selected-text-active: var(--semi-color-text-0)',
    const Color(0xff0f0f0f),
    (v) => SemiNavigationThemeData(
      colorNavigationItemL1SelectedTextActive: v as Color,
    ),
    (d) => d.colorNavigationItemL1SelectedTextActive,
    (t) => t.colors.colorText0,
  ),
  (
    r'$color-navigation_itemL1_selected-bg-default: var(--semi-color-primary-light-default)',
    const Color(0xff101010),
    (v) => SemiNavigationThemeData(
      colorNavigationItemL1SelectedBgDefault: v as Color,
    ),
    (d) => d.colorNavigationItemL1SelectedBgDefault,
    (t) => t.colors.colorPrimaryLightDefault,
  ),
  (
    r'$color-navigation_itemL1_selected-text-default: var(--semi-color-text-0)',
    const Color(0xff111111),
    (v) => SemiNavigationThemeData(
      colorNavigationItemL1SelectedTextDefault: v as Color,
    ),
    (d) => d.colorNavigationItemL1SelectedTextDefault,
    (t) => t.colors.colorText0,
  ),
  (
    r'$color-navigation_itemL1_selected_icon-default: var(--semi-color-primary)',
    const Color(0xff121212),
    (v) => SemiNavigationThemeData(
      colorNavigationItemL1SelectedIconDefault: v as Color,
    ),
    (d) => d.colorNavigationItemL1SelectedIconDefault,
    (t) => t.colors.colorPrimary,
  ),
  (
    r'$color-navigation_itemL1_disabled-bg-default: transparent',
    const Color(0xff131313),
    (v) => SemiNavigationThemeData(
      colorNavigationItemL1DisabledBgDefault: v as Color,
    ),
    (d) => d.colorNavigationItemL1DisabledBgDefault,
    (t) => const Color(0x00000000),
  ),
  (
    r'$color-navigation_itemL1_disabled-text-default: var(--semi-color-disabled-text)',
    const Color(0xff141414),
    (v) => SemiNavigationThemeData(
      colorNavigationItemL1DisabledTextDefault: v as Color,
    ),
    (d) => d.colorNavigationItemL1DisabledTextDefault,
    (t) => t.colors.colorDisabledText,
  ),
  (
    r'$color-navigation_itemL1_disabled_icon-default: var(--semi-color-disabled-text)',
    const Color(0xff151515),
    (v) => SemiNavigationThemeData(
      colorNavigationItemL1DisabledIconDefault: v as Color,
    ),
    (d) => d.colorNavigationItemL1DisabledIconDefault,
    (t) => t.colors.colorDisabledText,
  ),
  (
    r'$color-navigation_itemL1_selected_disabled-bg-default: transparent',
    const Color(0xff161616),
    (v) => SemiNavigationThemeData(
      colorNavigationItemL1SelectedDisabledBgDefault: v as Color,
    ),
    (d) => d.colorNavigationItemL1SelectedDisabledBgDefault,
    (t) => const Color(0x00000000),
  ),
  (
    r'$color-navigation_itemL1_selected_disabled-text-default: var(--semi-color-primary-disabled)',
    const Color(0xff171717),
    (v) => SemiNavigationThemeData(
      colorNavigationItemL1SelectedDisabledTextDefault: v as Color,
    ),
    (d) => d.colorNavigationItemL1SelectedDisabledTextDefault,
    (t) => t.colors.colorPrimaryDisabled,
  ),
  (
    r'$color-navigation_itemL1_selected_disabled_icon-default: var(--semi-color-primary-disabled)',
    const Color(0xff181818),
    (v) => SemiNavigationThemeData(
      colorNavigationItemL1SelectedDisabledIconDefault: v as Color,
    ),
    (d) => d.colorNavigationItemL1SelectedDisabledIconDefault,
    (t) => t.colors.colorPrimaryDisabled,
  ),
  (
    r'$color-navigation_horizontal_itemL1-text-default: var(--semi-color-text-2)',
    const Color(0xff191919),
    (v) => SemiNavigationThemeData(
      colorNavigationHorizontalItemL1TextDefault: v as Color,
    ),
    (d) => d.colorNavigationHorizontalItemL1TextDefault,
    (t) => t.colors.colorText2,
  ),
  (
    r'$color-navigation_horizontal_itemL1_icon-default: var(--semi-color-text-2)',
    const Color(0xff1a1a1a),
    (v) => SemiNavigationThemeData(
      colorNavigationHorizontalItemL1IconDefault: v as Color,
    ),
    (d) => d.colorNavigationHorizontalItemL1IconDefault,
    (t) => t.colors.colorText2,
  ),
  (
    r'$color-navigation_horizontal_itemL1-bg-default: transparent',
    const Color(0xff1b1b1b),
    (v) => SemiNavigationThemeData(
      colorNavigationHorizontalItemL1BgDefault: v as Color,
    ),
    (d) => d.colorNavigationHorizontalItemL1BgDefault,
    (t) => const Color(0x00000000),
  ),
  (
    r'$color-navigation_horizontal_itemL1-text-hover: var(--semi-color-text-1)',
    const Color(0xff1c1c1c),
    (v) => SemiNavigationThemeData(
      colorNavigationHorizontalItemL1TextHover: v as Color,
    ),
    (d) => d.colorNavigationHorizontalItemL1TextHover,
    (t) => t.colors.colorText1,
  ),
  (
    r'$color-navigation_horizontal_itemL1_icon-hover: var(--semi-color-text-1)',
    const Color(0xff1d1d1d),
    (v) => SemiNavigationThemeData(
      colorNavigationHorizontalItemL1IconHover: v as Color,
    ),
    (d) => d.colorNavigationHorizontalItemL1IconHover,
    (t) => t.colors.colorText1,
  ),
  (
    r'$color-navigation_horizontal_itemL1-bg-hover: transparent',
    const Color(0xff1e1e1e),
    (v) => SemiNavigationThemeData(
      colorNavigationHorizontalItemL1BgHover: v as Color,
    ),
    (d) => d.colorNavigationHorizontalItemL1BgHover,
    (t) => const Color(0x00000000),
  ),
  (
    r'$color-navigation_horizontal_itemL1-text-active: var(--semi-color-text-0)',
    const Color(0xff1f1f1f),
    (v) => SemiNavigationThemeData(
      colorNavigationHorizontalItemL1TextActive: v as Color,
    ),
    (d) => d.colorNavigationHorizontalItemL1TextActive,
    (t) => t.colors.colorText0,
  ),
  (
    r'$color-navigation_horizontal_itemL1_icon-active: var(--semi-color-text-0)',
    const Color(0xff202020),
    (v) => SemiNavigationThemeData(
      colorNavigationHorizontalItemL1IconActive: v as Color,
    ),
    (d) => d.colorNavigationHorizontalItemL1IconActive,
    (t) => t.colors.colorText0,
  ),
  (
    r'$color-navigation_horizontal_itemL1-bg-active: transparent',
    const Color(0xff212121),
    (v) => SemiNavigationThemeData(
      colorNavigationHorizontalItemL1BgActive: v as Color,
    ),
    (d) => d.colorNavigationHorizontalItemL1BgActive,
    (t) => const Color(0x00000000),
  ),
  (
    r'$color-navigation_horizontal_itemL1_selected-text-default: var(--semi-color-text-0)',
    const Color(0xff222222),
    (v) => SemiNavigationThemeData(
      colorNavigationHorizontalItemL1SelectedTextDefault: v as Color,
    ),
    (d) => d.colorNavigationHorizontalItemL1SelectedTextDefault,
    (t) => t.colors.colorText0,
  ),
  (
    r'$color-navigation_horizontal_itemL1_selected_icon-default: var(--semi-color-text-0)',
    const Color(0xff232323),
    (v) => SemiNavigationThemeData(
      colorNavigationHorizontalItemL1SelectedIconDefault: v as Color,
    ),
    (d) => d.colorNavigationHorizontalItemL1SelectedIconDefault,
    (t) => t.colors.colorText0,
  ),
  (
    r'$color-navigation_horizontal_itemL1_selected-bg-default: transparent',
    const Color(0xff242424),
    (v) => SemiNavigationThemeData(
      colorNavigationHorizontalItemL1SelectedBgDefault: v as Color,
    ),
    (d) => d.colorNavigationHorizontalItemL1SelectedBgDefault,
    (t) => const Color(0x00000000),
  ),
  (
    r'$color-navigation_horizontal_itemL1_disabled-text-default: var(--semi-color-disabled-text)',
    const Color(0xff252525),
    (v) => SemiNavigationThemeData(
      colorNavigationHorizontalItemL1DisabledTextDefault: v as Color,
    ),
    (d) => d.colorNavigationHorizontalItemL1DisabledTextDefault,
    (t) => t.colors.colorDisabledText,
  ),
  (
    r'$color-navigation_horizontal_itemL1_disabled_icon-default: var(--semi-color-disabled-text)',
    const Color(0xff262626),
    (v) => SemiNavigationThemeData(
      colorNavigationHorizontalItemL1DisabledIconDefault: v as Color,
    ),
    (d) => d.colorNavigationHorizontalItemL1DisabledIconDefault,
    (t) => t.colors.colorDisabledText,
  ),
  (
    r'$color-navigation_horizontal_itemL1_disabled-bg-default: transparent',
    const Color(0xff272727),
    (v) => SemiNavigationThemeData(
      colorNavigationHorizontalItemL1DisabledBgDefault: v as Color,
    ),
    (d) => d.colorNavigationHorizontalItemL1DisabledBgDefault,
    (t) => const Color(0x00000000),
  ),
  (
    r'$color-navigation_itemLn-bg-default: transparent',
    const Color(0xff282828),
    (v) => SemiNavigationThemeData(colorNavigationItemLnBgDefault: v as Color),
    (d) => d.colorNavigationItemLnBgDefault,
    (t) => const Color(0x00000000),
  ),
  (
    r'$color-navigation_itemLn-text-default: var(--semi-color-text-0)',
    const Color(0xff292929),
    (v) =>
        SemiNavigationThemeData(colorNavigationItemLnTextDefault: v as Color),
    (d) => d.colorNavigationItemLnTextDefault,
    (t) => t.colors.colorText0,
  ),
  (
    r'$color-navigation_itemLn-bg-hover: var(--semi-color-fill-0)',
    const Color(0xff2a2a2a),
    (v) => SemiNavigationThemeData(colorNavigationItemLnBgHover: v as Color),
    (d) => d.colorNavigationItemLnBgHover,
    (t) => t.colors.colorFill0,
  ),
  (
    r'$color-navigation_itemLn-text-hover: var(--semi-color-text-0)',
    const Color(0xff2b2b2b),
    (v) => SemiNavigationThemeData(colorNavigationItemLnTextHover: v as Color),
    (d) => d.colorNavigationItemLnTextHover,
    (t) => t.colors.colorText0,
  ),
  (
    r'$color-navigation_itemLn-bg-active: var(--semi-color-fill-1)',
    const Color(0xff2c2c2c),
    (v) => SemiNavigationThemeData(colorNavigationItemLnBgActive: v as Color),
    (d) => d.colorNavigationItemLnBgActive,
    (t) => t.colors.colorFill1,
  ),
  (
    r'$color-navigation_itemLn-text-active: var(--semi-color-text-0)',
    const Color(0xff2d2d2d),
    (v) => SemiNavigationThemeData(colorNavigationItemLnTextActive: v as Color),
    (d) => d.colorNavigationItemLnTextActive,
    (t) => t.colors.colorText0,
  ),
  (
    r'$color-navigation_itemLn_selected-bg-default: var(--semi-color-primary-light-default)',
    const Color(0xff2e2e2e),
    (v) => SemiNavigationThemeData(
      colorNavigationItemLnSelectedBgDefault: v as Color,
    ),
    (d) => d.colorNavigationItemLnSelectedBgDefault,
    (t) => t.colors.colorPrimaryLightDefault,
  ),
  (
    r'$color-navigation_outline-focus: var(--semi-color-primary-light-active)',
    const Color(0xff2f2f2f),
    (v) => SemiNavigationThemeData(colorNavigationOutlineFocus: v as Color),
    (d) => d.colorNavigationOutlineFocus,
    (t) => t.colors.colorPrimaryLightActive,
  ),
  (
    r'$motion-navigation_item_title: opacity 100ms 100s ease-out',
    'sentinel-1',
    (v) => SemiNavigationThemeData(motionNavigationItemTitle: v as String),
    (d) => d.motionNavigationItemTitle,
    (t) => 'opacity 100ms 100s ease-out',
  ),
  (
    r'$motion-navigation_padding: padding-left 100ms ease-out',
    'sentinel-2',
    (v) => SemiNavigationThemeData(motionNavigationPadding: v as String),
    (d) => d.motionNavigationPadding,
    (t) => 'padding-left 100ms ease-out',
  ),
  (
    r'$motion-navigation_padding_rtl: padding-right 100ms ease-out',
    'sentinel-3',
    (v) => SemiNavigationThemeData(motionNavigationPaddingRtl: v as String),
    (d) => d.motionNavigationPaddingRtl,
    (t) => 'padding-right 100ms ease-out',
  ),
  (
    r'$motion-navigation_width: width 200ms cubic-bezier(.62, .05, .36, .95)',
    'sentinel-4',
    (v) => SemiNavigationThemeData(motionNavigationWidth: v as String),
    (d) => d.motionNavigationWidth,
    (t) => 'width 200ms cubic-bezier(.62, .05, .36, .95)',
  ),
  (
    r'$motion-navigation_collapsed_opacity: opacity .2s cubic-bezier(.5, -.1, 1, .4)',
    'sentinel-5',
    (v) =>
        SemiNavigationThemeData(motionNavigationCollapsedOpacity: v as String),
    (d) => d.motionNavigationCollapsedOpacity,
    (t) => 'opacity .2s cubic-bezier(.5, -.1, 1, .4)',
  ),
  (
    r'$font-navigation_item-fontWeight: $font-weight-bold',
    FontWeight.w500,
    (v) =>
        SemiNavigationThemeData(fontNavigationItemFontWeight: v as FontWeight),
    (d) => d.fontNavigationItemFontWeight,
    (t) => t.typography.fontWeightBold,
  ),
  (
    r'$font-navigation_sub_title-fontWeight: $font-weight-bold',
    FontWeight.w500,
    (v) => SemiNavigationThemeData(
      fontNavigationSubTitleFontWeight: v as FontWeight,
    ),
    (d) => d.fontNavigationSubTitleFontWeight,
    (t) => t.typography.fontWeightBold,
  ),
  (
    r'$font-navigation_item_normal-fontWeight: $font-weight-regular',
    FontWeight.w500,
    (v) => SemiNavigationThemeData(
      fontNavigationItemNormalFontWeight: v as FontWeight,
    ),
    (d) => d.fontNavigationItemNormalFontWeight,
    (t) => t.typography.fontWeightRegular,
  ),
  (
    r'$font-navigation_popover_nav_item_selected-fontWeight: normal',
    FontWeight.w500,
    (v) => SemiNavigationThemeData(
      fontNavigationPopoverNavItemSelectedFontWeight: v as FontWeight,
    ),
    (d) => d.fontNavigationPopoverNavItemSelectedFontWeight,
    (t) => FontWeight.w400,
  ),
  (
    r'$font-navigation_sub_selected-fontWeight: $font-weight-bold',
    FontWeight.w500,
    (v) => SemiNavigationThemeData(
      fontNavigationSubSelectedFontWeight: v as FontWeight,
    ),
    (d) => d.fontNavigationSubSelectedFontWeight,
    (t) => t.typography.fontWeightBold,
  ),
  (
    r'$font-navigation_sub_disabled-fontWeight: $font-weight-bold',
    FontWeight.w500,
    (v) => SemiNavigationThemeData(
      fontNavigationSubDisabledFontWeight: v as FontWeight,
    ),
    (d) => d.fontNavigationSubDisabledFontWeight,
    (t) => t.typography.fontWeightBold,
  ),
  (
    r'$font-navigation_sub-fontWeight: $font-weight-regular',
    FontWeight.w500,
    (v) =>
        SemiNavigationThemeData(fontNavigationSubFontWeight: v as FontWeight),
    (d) => d.fontNavigationSubFontWeight,
    (t) => t.typography.fontWeightRegular,
  ),
  (
    r'$font-navigation_sub-fontSize: $font-size-regular',
    158.0,
    (v) => SemiNavigationThemeData(fontNavigationSubFontSize: v as double),
    (d) => d.fontNavigationSubFontSize,
    (t) => 14.0,
  ),
  (
    r'$font-navigation_sub_item-fontWeight: $font-weight-regular',
    FontWeight.w500,
    (v) => SemiNavigationThemeData(
      fontNavigationSubItemFontWeight: v as FontWeight,
    ),
    (d) => d.fontNavigationSubItemFontWeight,
    (t) => t.typography.fontWeightRegular,
  ),
  (
    r'$font-navigation_header_item-fontWeight: $font-weight-bold',
    FontWeight.w500,
    (v) => SemiNavigationThemeData(
      fontNavigationHeaderItemFontWeight: v as FontWeight,
    ),
    (d) => d.fontNavigationHeaderItemFontWeight,
    (t) => t.typography.fontWeightBold,
  ),
  (
    r'$transition_duration-navigation_itemL1-bg: var(--semi-transition_duration-none)',
    const Duration(milliseconds: 1),
    (v) => SemiNavigationThemeData(
      transitionDurationNavigationItemL1Bg: v as Duration,
    ),
    (d) => d.transitionDurationNavigationItemL1Bg,
    (t) => Duration.zero,
  ),
  (
    r'$transition_function-navigation_itemL1-bg: var(--semi-transition_function-easeIn)',
    Curves.easeOut,
    (v) => SemiNavigationThemeData(
      transitionFunctionNavigationItemL1Bg: v as Curve,
    ),
    (d) => d.transitionFunctionNavigationItemL1Bg,
    (t) => Curves.easeIn,
  ),
  (
    r'$transition_delay-navigation_itemL1-bg: var(--semi-transition_delay-none)',
    const Duration(milliseconds: 2),
    (v) => SemiNavigationThemeData(
      transitionDelayNavigationItemL1Bg: v as Duration,
    ),
    (d) => d.transitionDelayNavigationItemL1Bg,
    (t) => Duration.zero,
  ),
];

void main() {
  group('theme fields (122 = 119 FIELDS + 3 MOTION + 0 INTERNAL)', () {
    test('122 fields: merge, copyWith, resolve, equality, defaults', () {
      expect(fields, hasLength(122));
      for (final (sass, value, make, read, expected) in fields) {
        final patch = make(value);
        expect(
          const SemiNavigationThemeData().merge(patch),
          patch,
          reason: sass,
        );
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
          read(const SemiNavigationThemeData().resolve(light)),
          expected(light),
          reason: sass,
        );
        final dark = const SemiThemeData.dark();
        expect(
          read(const SemiNavigationThemeData().resolve(dark)),
          expected(dark),
          reason: sass,
        );
      }
    });

    test('every field carries its Sass provenance in the generated source', () {
      final source = File('lib/src/theme/semi_navigation_theme_data.dart')
          .readAsStringSync();
      final names = <String>{};
      for (final (sass, _, _, _, _) in fields) {
        expect(source, contains(sass));
        names.add(sass.split(': ').first.substring(1));
      }
      expect(names, hasLength(122));
      // ★provenance quirk 照抄：3.5 公式冒号后双空格 / 冒号后无空格 /
      // `normal` 关键字 / 100s delay typo。
      expect(
        source,
        contains(
          r'$spacing-navigation_vertical_nav_header-paddingLeft:  '
          r'($width-navigation_container_collapsed',
        ),
      );
      expect(
        source,
        contains(
          r'$spacing-navigation_sub_item_left_toggle_marginRight:$spacing-tight',
        ),
      );
      expect(
        source,
        contains(
          r'$font-navigation_popover_nav_item_selected-fontWeight: normal',
        ),
      );
      expect(
        source,
        contains(r'$motion-navigation_item_title: opacity 100ms 100s ease-out'),
      );
    });

    test('the 20 HARDCODES anchors live in the widget source', () {
      final widgetSource = File('lib/src/components/semi_navigation.dart')
          .readAsStringSync();
      const anchors = <String>[
        'transition: transform 200ms ease-in-out',
        r'$spacing-base-tight + $width-navigation_icon_left + '
            r'$width-navigation_icon_text_between',
        'word-wrap: none',
        'cursor: pointer',
        'cursor: not-allowed',
        'user-select: none',
        'overflow: hidden; white-space: nowrap; text-overflow: ellipsis',
        'opacity: 0',
        'opacity: 1',
        '@include font-size-regular',
        '@include font-size-header-5',
        "'收起侧边栏'",
        "'展开侧边栏'",
        'DEFAULT_SUBNAV_MAX_HEIGHT: 999',
        'TOOLTIP_SHOW_DELAY: 0',
        'TOOLTIP_HIDE_DELAY: 100',
        'SUBNAV_OPEN_DELAY: 0',
        'SUBNAV_CLOSE_DELAY: 100',
        r'($width-navigation_container_collapsed - '
            r'$spacing-navigation_collapsed-paddingX * 2 - '
            r'$width-navigation_border - '
            r'$height-navigation_header_logo_collapsed) * 0.5',
        'object-fit: scale-down',
      ];
      expect(anchors, hasLength(20));
      for (final anchor in anchors) {
        expect(widgetSource, contains(anchor), reason: anchor);
      }
    });

    test('type coverage: 47 Color + 58 double + 9 FontWeight + 5 String + '
        '2 Duration + 1 Curve = 122', () {
      final counts = <String, int>{};
      for (final (_, value, _, _, _) in fields) {
        final type = value is Curve ? 'Curve' : value.runtimeType.toString();
        counts.update(type, (n) => n + 1, ifAbsent: () => 1);
      }
      expect(counts['Color'], 47);
      expect(counts['double'], 58);
      expect(counts['FontWeight'], 9);
      expect(counts['String'], 5);
      expect(counts['Duration'], 2);
      expect(counts['Curve'], 1);
    });

    test('dead variables (10): assertNotIn + docs （上游未消费） marks', () {
      const deadFieldNames = [
        'heightNavigationFooter',
        'widthNavigationFooterBorder',
        'spacingNavigationHorizontalHeaderLogoMarginLeft',
        'spacingNavigationSubItemLeftToggleMarginRight',
        'colorNavigationItemLnBgHover',
        'colorNavigationItemLnTextHover',
        'colorNavigationItemLnBgActive',
        'colorNavigationItemLnTextActive',
        'colorNavigationItemLnSelectedBgDefault',
        'motionNavigationItemTitle',
      ];
      const deadSassNames = [
        r'$height-navigation_footer',
        r'$width-navigation_footer_border',
        r'$spacing-navigation_horizontal_header_logo-marginLeft',
        r'$spacing-navigation_sub_item_left_toggle_marginRight',
        r'$color-navigation_itemLn-bg-hover',
        r'$color-navigation_itemLn-text-hover',
        r'$color-navigation_itemLn-bg-active',
        r'$color-navigation_itemLn-text-active',
        r'$color-navigation_itemLn_selected-bg-default',
        r'$motion-navigation_item_title',
      ];
      final widgetSource = File('lib/src/components/semi_navigation.dart')
          .readAsStringSync();
      // ★死变量留档不消费：widget 不得出现死字段名（生成器 assertNotIn 同口径）。
      expect(widgetSource, isNot(contains('# dead variable')));
      for (final name in deadFieldNames) {
        expect(widgetSource, isNot(contains(name)), reason: name);
      }
      final docs = File('docs/semi_navigation.md').readAsStringSync();
      expect(docs, contains('122 = 119 FIELDS + 3 MOTION + 0 INTERNAL'));
      for (final sass in deadSassNames) {
        final rows = docs
            .split('\n')
            .where((line) => line.contains('$sass:'))
            .toList();
        expect(rows, isNotEmpty, reason: sass);
        expect(
          rows.any((row) => row.contains('（上游未消费）')),
          isTrue,
          reason: sass,
        );
      }
      expect(docs, contains('（上游事实死——消费于 UI 从不渲染的类）'));
    });

    test('SemiComponentThemes wiring', () {
      expect(
        const SemiComponentThemes().navigation,
        const SemiNavigationThemeData(),
      );
      const patch = SemiNavigationThemeData(heightNavigationItemBase: 44);
      const themes = SemiComponentThemes(navigation: patch);
      expect(const SemiComponentThemes().copyWith(navigation: patch), themes);
      expect(themes == const SemiComponentThemes(), isFalse);
      expect(themes.navigation, patch);
    });

    testWidgets('SemiNavigationTheme local patch applies (nested merge, '
        'inner wins its own field)', (tester) async {
      SemiResolvedNavigationThemeData? resolved;
      await pumpHost(
        tester,
        SemiTheme(
          data: const SemiThemeData.light(),
          child: SemiNavigationTheme(
            data: const SemiNavigationThemeData(
              colorNavigationBgDefault: Color(0xff123456),
            ),
            child: SemiNavigationTheme(
              data: const SemiNavigationThemeData(
                fontNavigationSubFontSize: 30,
              ),
              child: Builder(
                builder: (context) {
                  resolved = SemiNavigationTheme.resolve(context);
                  return const SizedBox.shrink();
                },
              ),
            ),
          ),
        ),
      );
      expect(resolved!.colorNavigationBgDefault, const Color(0xff123456));
      expect(resolved!.fontNavigationSubFontSize, 30);
    });
  });

  group('items and selection', () {
    testWidgets('string items normalize to {text, itemKey} and select', (
      tester,
    ) async {
      final log = <SemiNavigationSelectInfo>[];
      await pumpHost(tester, nav(items: const ['Home'], onSelect: log.add));
      expect(find.text('Home'), findsOneWidget);
      await tester.tap(find.text('Home'));
      await tester.pump();
      expect(log, hasLength(1));
      expect(log.single.itemKey, 'Home');
      expect(log.single.text, 'Home');
      expect(log.single.selectedKeys, ['Home']);
    });

    testWidgets('nested items render recursively with icon and link', (
      tester,
    ) async {
      await pumpHost(
        tester,
        nav(
          items: [
            SemiNavigationItem(
              itemKey: 's1',
              text: 'Sub1',
              items: const [
                SemiNavigationItem(itemKey: 'a', text: 'ChildA'),
                SemiNavigationItem(
                  itemKey: 'deep',
                  text: 'Deep',
                  items: [SemiNavigationItem(itemKey: 'leaf', text: 'Leaf')],
                ),
              ],
            ),
            SemiNavigationItem(
              itemKey: 'icon',
              text: 'IconItem',
              icon: const Icon(null),
              link: 'https://example.com',
            ),
          ],
        ),
      );
      expect(find.text('Sub1'), findsOneWidget);
      expect(find.text('ChildA'), findsNothing);
      await tester.tap(find.text('Sub1'));
      await tester.pumpAndSettle();
      expect(find.text('ChildA'), findsOneWidget);
      expect(find.text('Deep'), findsOneWidget);
      await tester.tap(find.text('Deep'));
      await tester.pumpAndSettle();
      expect(find.text('Leaf'), findsOneWidget);
      expect(find.text('IconItem'), findsOneWidget);
    });

    testWidgets('selection replaces; re-tapping selected does not fire '
        'onSelect nor remove', (tester) async {
      final log = <SemiNavigationSelectInfo>[];
      await pumpHost(
        tester,
        nav(
          items: const [
            SemiNavigationItem(itemKey: 'a', text: 'A'),
            SemiNavigationItem(itemKey: 'b', text: 'B'),
          ],
          onSelect: log.add,
        ),
      );
      await tester.tap(find.text('A'));
      await tester.pump();
      expect(selectedFlag(tester, 'A'), isTrue);
      await tester.tap(find.text('B'));
      await tester.pump();
      expect(log.map((e) => e.itemKey).toList(), ['a', 'b']);
      // single-select replaces
      expect(selectedFlag(tester, 'A'), isFalse);
      expect(selectedFlag(tester, 'B'), isTrue);
      // ★re-tap selected: no onSelect, not removed
      await tester.tap(find.text('B'));
      await tester.pump();
      expect(log, hasLength(2));
      expect(selectedFlag(tester, 'B'), isTrue);
    });

    testWidgets('selecting a child auto-attaches the level-zero parent key '
        '(sub title lights selected; payload keeps [itemKey])', (tester) async {
      final log = <SemiNavigationSelectInfo>[];
      await pumpHost(tester, nav(items: nestedItems(), onSelect: log.add));
      await tester.tap(find.text('Sub1'));
      await tester.pumpAndSettle();
      expect(selectedFlag(tester, 'Sub1'), isFalse);
      await tester.tap(find.text('ChildA'));
      await tester.pump();
      expect(selectedFlag(tester, 'ChildA'), isTrue);
      // ★自动附一级父 key（sub 标题亮 selected）——载荷仍 [itemKey]。
      expect(selectedFlag(tester, 'Sub1'), isTrue);
      expect(log.single.selectedKeys, ['a']);
    });

    testWidgets('selectedKeys is controlled when non-null', (tester) async {
      final log = <SemiNavigationSelectInfo>[];
      await pumpHost(
        tester,
        nav(
          items: const [
            SemiNavigationItem(itemKey: 'a', text: 'A'),
            SemiNavigationItem(itemKey: 'b', text: 'B'),
          ],
          selectedKeys: const ['b'],
          onSelect: log.add,
        ),
      );
      expect(selectedFlag(tester, 'B'), isTrue);
      await tester.tap(find.text('A'));
      await tester.pump();
      // controlled: onSelect fires but internal state does not move
      expect(log, hasLength(1));
      expect(selectedFlag(tester, 'B'), isTrue);
      expect(selectedFlag(tester, 'A'), isFalse);
    });

    testWidgets('numeric itemKey 0 is a legal key', (tester) async {
      final log = <SemiNavigationSelectInfo>[];
      await pumpHost(
        tester,
        nav(
          items: const [SemiNavigationItem(itemKey: 0, text: 'Zero')],
          onSelect: log.add,
        ),
      );
      await tester.tap(find.text('Zero'));
      await tester.pump();
      expect(log.single.itemKey, 0);
      expect(selectedFlag(tester, 'Zero'), isTrue);
    });
  });

  group('open state and Sub', () {
    testWidgets('sub title toggles with onOpenChange + onClick payload', (
      tester,
    ) async {
      final opens = <SemiNavigationOpenInfo>[];
      final clicks = <SemiNavigationClickInfo>[];
      await pumpHost(
        tester,
        nav(items: nestedItems(), onOpenChange: opens.add, onClick: clicks.add),
      );
      await tester.tap(find.text('Sub1'));
      await tester.pumpAndSettle();
      expect(find.text('ChildA'), findsOneWidget);
      expect(opens.single.isOpen, isTrue);
      expect(opens.single.itemKey, 's1');
      expect(opens.single.openKeys, ['s1']);
      // ★sub 路 onClick payload {itemKey, openKeys, isOpen}
      expect(clicks.single.openKeys, ['s1']);
      expect(clicks.single.isOpen, isTrue);
      expect(clicks.single.text, isNull);
      await tester.tap(find.text('Sub1'));
      await tester.pumpAndSettle();
      expect(find.text('ChildA'), findsNothing);
      expect(opens, hasLength(2));
      expect(opens.last.isOpen, isFalse);
    });

    testWidgets('selected ancestors auto-open without openKeys input', (
      tester,
    ) async {
      await pumpHost(
        tester,
        nav(items: nestedItems(), defaultSelectedKeys: const ['a']),
      );
      // foundation.ts:174-188 getWillOpenKeys: auto-expanded ancestors
      expect(find.text('ChildA'), findsOneWidget);
      expect(selectedFlag(tester, 'ChildA'), isTrue);
    });

    testWidgets('openKeys is controlled only in vertical non-collapsed mode', (
      tester,
    ) async {
      final opens = <SemiNavigationOpenInfo>[];
      await pumpHost(
        tester,
        nav(
          items: nestedItems(),
          openKeys: const <Object>[],
          onOpenChange: opens.add,
        ),
      );
      await tester.tap(find.text('Sub1'));
      await tester.pumpAndSettle();
      // controlled: notified but state does not move
      expect(opens, hasLength(1));
      expect(find.text('ChildA'), findsNothing);
      // props update opens it
      await pumpHost(
        tester,
        nav(items: nestedItems(), openKeys: const <Object>['s1']),
      );
      expect(find.text('ChildA'), findsOneWidget);
    });

    testWidgets('subNavMotion false shows children instantly; true settles', (
      tester,
    ) async {
      await pumpHost(tester, nav(items: nestedItems(), subNavMotion: false));
      await tester.tap(find.text('Sub1'));
      await tester.pump();
      expect(find.text('ChildA'), findsOneWidget);
      await pumpHost(tester, nav(items: nestedItems(), subNavMotion: true));
      await tester.tap(find.text('Sub1'));
      await tester.pumpAndSettle();
      expect(find.text('ChildA'), findsOneWidget);
    });
  });

  group('collapsed mode', () {
    testWidgets('60px width, faded labels, tooltip, footer collapse button', (
      tester,
    ) async {
      final collapses = <bool>[];
      await pumpHost(
        tester,
        Center(
          child: nav(
            items: nestedItems(),
            defaultIsCollapsed: true,
            footer: const SemiNavigationFooter(collapseButton: true),
            onCollapseChange: collapses.add,
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(tester.getSize(find.byKey(SemiNavigation.rootKey)).width, 60);
      // ★收起态按钮为 icon-only（CollapseButton.tsx:39-43）——locale 文案只活
      // 在 tooltip 内容里；悬停按钮出「展开侧边栏」。
      final g = await startMouse(tester);
      await g.moveTo(
        tester.getCenter(find.byKey(SemiNavigation.collapseButtonKey)),
      );
      for (var i = 0; i < 5; i++) {
        await tester.pump(const Duration(milliseconds: 30));
      }
      expect(find.text('展开侧边栏'), findsOneWidget);
      // collapse toggle
      await tester.tap(find.byKey(SemiNavigation.collapseButtonKey));
      await tester.pumpAndSettle();
      expect(collapses, [false]);
      expect(find.text('收起侧边栏'), findsOneWidget);
      expect(tester.getSize(find.byKey(SemiNavigation.rootKey)).width, 240);
    });

    testWidgets('collapsed flat items wrap a right-side tooltip', (
      tester,
    ) async {
      final gesture = await startMouse(tester);
      await pumpHost(
        tester,
        nav(
          items: const [SemiNavigationItem(itemKey: 'a', text: 'Solo')],
          defaultIsCollapsed: true,
        ),
      );
      await gesture.moveTo(tester.getCenter(find.text('Solo')));
      // tooltip first frame takes ~4-5 pumps (known_issues.md #4)
      for (var i = 0; i < 5; i++) {
        await tester.pump(const Duration(milliseconds: 30));
      }
      expect(find.text('Solo'), findsNWidgets(2));
    });

    testWidgets('collapsed Sub hovers open the popup menu; item tap selects '
        'and closes', (tester) async {
      final gesture = await startMouse(tester);
      final log = <SemiNavigationSelectInfo>[];
      final opens = <SemiNavigationOpenInfo>[];
      await pumpHost(
        tester,
        nav(
          items: nestedItems(),
          defaultIsCollapsed: true,
          onSelect: log.add,
          onOpenChange: opens.add,
        ),
      );
      await gesture.moveTo(tester.getCenter(find.text('Sub1')));
      for (var i = 0; i < 5; i++) {
        await tester.pump(const Duration(milliseconds: 30));
      }
      expect(find.byKey(SemiNavigation.subPopupKey), findsOneWidget);
      expect(find.text('ChildA'), findsOneWidget);
      await neutralTap(tester);
      await tester.tap(find.text('ChildA'));
      await tester.pumpAndSettle();
      expect(log.single.itemKey, 'a');
      // popup closes after item tap (差异清单 23)
      expect(find.byKey(SemiNavigation.subPopupKey), findsNothing);
      expect(opens.last.isOpen, isFalse);
    });

    testWidgets('collapsed Sub tap opens the popup and the title tap does not '
        'flip it shut (tap-fallback vs toggle conflict)', (tester) async {
      final clicks = <SemiNavigationClickInfo>[];
      await pumpHost(
        tester,
        nav(
          items: nestedItems(),
          defaultIsCollapsed: true,
          onClick: clicks.add,
        ),
      );
      await neutralTap(tester);
      // ★tap alone（无 hover）走 SemiTooltip touch-tap 兜底开启弹层；标题 tap
      // 对弹层可见性惰性（上游 wrapDropdown trigger:'hover' 语义）——此前
      // tap-toggle 会把兜底刚开的弹层立刻关掉（净效果恒关）。
      await tester.tap(find.text('Sub1'));
      for (var i = 0; i < 5; i++) {
        await tester.pump(const Duration(milliseconds: 30));
      }
      expect(find.byKey(SemiNavigation.subPopupKey), findsOneWidget);
      expect(find.text('ChildA'), findsOneWidget);
      // 再点标题：可见性不翻转（关闭走移出/外点），onClick 照发。
      await tester.tap(find.text('Sub1'));
      await tester.pump(const Duration(milliseconds: 60));
      expect(find.byKey(SemiNavigation.subPopupKey), findsOneWidget);
      expect(clicks, isNotEmpty);
    });

    testWidgets('collapsed rail keeps icons at natural size and fades '
        'labels (no squeeze-to-dot)', (tester) async {
      await pumpHost(
        tester,
        // Center 松约束——否则测试 host 的紧宽会顶掉收起态 60px（同
        // '60px width' 用例口径）。
        Center(
          child: nav(
            items: [
              SemiNavigationItem(
                itemKey: 'x',
                text: 'LabelX',
                icon: const SemiIcon(SemiIcons.home),
              ),
              SemiNavigationItem(
                itemKey: 'y',
                text: 'LabelY',
                icon: const SemiIcon(SemiIcons.folder),
              ),
            ],
            defaultIsCollapsed: true,
            footer: const SemiNavigationFooter(collapseButton: true),
          ),
        ),
      );
      await tester.pumpAndSettle();
      // ★图标按自然尺寸渲染——此前窄栏（内容约 44px）里 Flexible 把 16-20px
      // 图标挤成点（用户可见「收起侧边栏后基本什么都没有」）；footer 收起
      // 按钮图标同查（居中对齐会把图标顶出左缘——「闪一下就不见了」）。
      final icons = find.byType(SemiIcon);
      expect(icons, findsNWidgets(3));
      for (var i = 0; i < 3; i++) {
        expect(tester.getSize(icons.at(i)).width, greaterThanOrEqualTo(14));
      }
      // ★文字收起渐隐（nav:57-63 opacity: 0，仍在树上）。
      final faded = tester
          .widgetList<AnimatedOpacity>(find.byType(AnimatedOpacity))
          .where((w) => w.opacity == 0);
      expect(faded.length, greaterThanOrEqualTo(2));
    });
  });

  group('horizontal mode', () {
    testWidgets('single row of 60px height, subs open popups, footer has no '
        'collapse button', (tester) async {
      final gesture = await startMouse(tester);
      await pumpHost(
        tester,
        Center(
          child: nav(
            items: nestedItems(),
            mode: SemiNavigationMode.horizontal,
            footer: const SemiNavigationFooter(collapseButton: true),
          ),
        ),
      );
      expect(tester.getSize(find.byKey(SemiNavigation.rootKey)).height, 60);
      // one line: ItemC sits to the right of Sub1
      expect(find.text('Sub1'), findsOneWidget);
      expect(find.text('ItemC'), findsOneWidget);
      expect(textDx(tester, 'ItemC') > textDx(tester, 'Sub1'), isTrue);
      // ★Footer.tsx:64 quirk: no collapse button in horizontal
      expect(find.byKey(SemiNavigation.collapseButtonKey), findsNothing);
      // Sub goes to popup (bottomLeft semantics)
      await gesture.moveTo(tester.getCenter(find.text('Sub1')));
      for (var i = 0; i < 5; i++) {
        await tester.pump(const Duration(milliseconds: 30));
      }
      expect(find.byKey(SemiNavigation.subPopupKey), findsOneWidget);
      expect(find.text('ChildA'), findsOneWidget);
    });
  });

  group('disabled and keyboard', () {
    testWidgets('disabled item/sub ignore taps and show forbidden cursor', (
      tester,
    ) async {
      final log = <SemiNavigationSelectInfo>[];
      final opens = <SemiNavigationOpenInfo>[];
      await pumpHost(
        tester,
        nav(
          items: nestedItems(subDisabled: true),
          onSelect: log.add,
          onOpenChange: opens.add,
        ),
      );
      final subRow = tester.widget<MouseRegion>(
        find
            .ancestor(of: find.text('Sub1'), matching: find.byType(MouseRegion))
            .first,
      );
      expect(subRow.cursor, SystemMouseCursors.forbidden);
      await tester.tap(find.text('Sub1'));
      await tester.pumpAndSettle();
      expect(opens, isEmpty);
      expect(find.text('ChildA'), findsNothing);
      await pumpHost(
        tester,
        nav(
          items: const [
            SemiNavigationItem(itemKey: 'd', text: 'D', disabled: true),
          ],
          onSelect: log.add,
        ),
      );
      final row = tester.widget<MouseRegion>(
        find
            .ancestor(of: find.text('D'), matching: find.byType(MouseRegion))
            .first,
      );
      expect(row.cursor, SystemMouseCursors.forbidden);
      await tester.tap(find.text('D'));
      await tester.pump();
      expect(log, isEmpty);
    });

    testWidgets('Enter activates an item (itemFoundation.ts:101-110)', (
      tester,
    ) async {
      final log = <SemiNavigationSelectInfo>[];
      await pumpHost(
        tester,
        nav(
          items: const [SemiNavigationItem(itemKey: 'a', text: 'A')],
          onSelect: log.add,
        ),
      );
      Focus.of(tester.element(find.text('A'))).requestFocus();
      await tester.pump();
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.pump();
      expect(log, hasLength(1));
      expect(log.single.itemKey, 'a');
    });
  });

  group('toggleIconPosition, limitIndent, expandIcon', () {
    testWidgets('expandIcon replaces the default chevron', (tester) async {
      await pumpHost(
        tester,
        nav(items: nestedItems(), expandIcon: const Text('EXP')),
      );
      expect(find.text('EXP'), findsOneWidget);
    });

    testWidgets('toggleIconPosition left|right moves the toggle around the '
        'text', (tester) async {
      await pumpHost(
        tester,
        nav(
          items: nestedItems(),
          expandIcon: const Text('T'),
          toggleIconPosition: SemiNavigationToggleIconPosition.left,
        ),
      );
      expect(textDx(tester, 'T') < textDx(tester, 'Sub1'), isTrue);
      await pumpHost(
        tester,
        nav(
          items: nestedItems(),
          expandIcon: const Text('T'),
          toggleIconPosition: SemiNavigationToggleIconPosition.right,
        ),
      );
      expect(textDx(tester, 'T') > textDx(tester, 'Sub1'), isTrue);
    });

    testWidgets('limitIndent true indents nested text by 44px; false uses '
        'manual placeholder slots', (tester) async {
      Future<double> leafIndent(WidgetTester tester, bool limitIndent) async {
        await pumpHost(
          tester,
          nav(
            items: const [
              SemiNavigationItem(
                itemKey: 's1',
                text: 'Sub1',
                items: [
                  SemiNavigationItem(
                    itemKey: 's2',
                    text: 'Sub2',
                    items: [SemiNavigationItem(itemKey: 'l', text: 'Leaf')],
                  ),
                ],
              ),
            ],
            limitIndent: limitIndent,
          ),
        );
        await tester.tap(find.text('Sub1'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Sub2'));
        await tester.pumpAndSettle();
        return textDx(tester, 'Leaf') - tester.getTopLeft(rowOf('Leaf')).dx;
      }

      // limitIndent=true: 12 padding + 32px icon slot（nav:282 的 44px 缩进表达式
      // = $spacing-base-tight + $width-navigation_icon_left +
      // $width-navigation_icon_text_between = 12+20+12）= 44
      expect(await leafIndent(tester, true), 44);
      // limitIndent=false: 12 padding + one 32px placeholder slot + 32px icon
      // slot = 76
      expect(await leafIndent(tester, false), 76);
    });
  });

  group('header, footer, RTL, click payloads', () {
    testWidgets('header renders logo and text; collapsed hides text', (
      tester,
    ) async {
      await pumpHost(
        tester,
        nav(
          items: const [SemiNavigationItem(itemKey: 'a', text: 'A')],
          header: const SemiNavigationHeader(logo: FlutterLogo(), text: 'Semi'),
        ),
      );
      expect(find.text('Semi'), findsOneWidget);
      expect(find.byType(FlutterLogo), findsOneWidget);
      await pumpHost(
        tester,
        nav(
          items: const [SemiNavigationItem(itemKey: 'a', text: 'A')],
          header: const SemiNavigationHeader(logo: FlutterLogo(), text: 'Semi'),
          defaultIsCollapsed: true,
        ),
      );
      // Header.tsx:63-65 collapsed 隐 text
      expect(find.text('Semi'), findsNothing);
      expect(find.byType(FlutterLogo), findsOneWidget);
    });

    testWidgets('footer renders child, wrapper onClick and collapseText', (
      tester,
    ) async {
      var taps = 0;
      await pumpHost(
        tester,
        nav(
          items: const [SemiNavigationItem(itemKey: 'a', text: 'A')],
          footer: SemiNavigationFooter(
            collapseButton: true,
            collapseText: 'TUCK',
            onClick: () => taps++,
            child: const Text('FootChild'),
          ),
        ),
      );
      // custom child wins over collapseButton (Footer.tsx:64)
      expect(find.text('FootChild'), findsOneWidget);
      expect(find.byKey(SemiNavigation.collapseButtonKey), findsNothing);
      await tester.tap(find.text('FootChild'));
      await tester.pump();
      expect(taps, 1);
    });

    testWidgets('RTL mirrors the root border (rtl.scss:8-9)', (tester) async {
      await pumpHost(
        tester,
        nav(items: const ['A']),
        direction: TextDirection.rtl,
      );
      final container = tester.widget<AnimatedContainer>(
        find.byKey(SemiNavigation.rootKey),
      );
      final border = (container.decoration! as BoxDecoration).border! as Border;
      expect(border.left.width, 1);
      expect(border.right, BorderSide.none);
    });

    testWidgets('onClick carries {itemKey, text} on items and '
        '{itemKey, openKeys, isOpen} on subs', (tester) async {
      final clicks = <SemiNavigationClickInfo>[];
      await pumpHost(tester, nav(items: nestedItems(), onClick: clicks.add));
      await tester.tap(find.text('ItemC'));
      await tester.pump();
      expect(clicks.single.itemKey, 'c');
      expect(clicks.single.text, 'ItemC');
      expect(clicks.single.openKeys, isNull);
      expect(clicks.single.isOpen, isNull);
      await tester.tap(find.text('Sub1'));
      await tester.pumpAndSettle();
      final subClick = clicks.last;
      expect(subClick.itemKey, 's1');
      expect(subClick.text, isNull);
      expect(subClick.openKeys, ['s1']);
      expect(subClick.isOpen, isTrue);
    });
  });
}
