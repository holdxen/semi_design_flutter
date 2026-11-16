// Behavior matrix for SemiPagination plus coverage for the 48 Sass declarations
// (41 FIELDS + 7 MOTION + 0 INTERNAL) — the 26 HARDCODES provenance anchors live
// in the widget's `_PaginationMetrics` / call sites, ★1 死变量
// (`$color-pagination_item-bg-default`: 声明后零消费) keeps its theme field but
// the widget must never mention the field name (assertNotIn) and the docs row is
// marked （上游未消费）.
import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:semi_design_flutter/semi_design_flutter.dart';

/// The host body is served through a notifier: `Overlay.initialEntries` is
/// initState-only, so the entry must rebuild its child from outside.
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

Future<TestGesture> startMouse(WidgetTester tester) async {
  final gesture = await tester.createGesture(kind: ui.PointerDeviceKind.mouse);
  await gesture.addPointer(location: Offset.zero);
  addTearDown(gesture.removePointer);
  return gesture;
}

/// Overlay panel pumping (selection/tooltip insert needs a few frames; hover
/// tooltips run a 50ms enter delay, so frames must advance time).
Future<void> settle(WidgetTester tester) async {
  for (var i = 0; i < 6; i++) {
    await tester.pump(const Duration(milliseconds: 30));
  }
}

Widget pagination({
  int total = 1,
  bool showTotal = false,
  int? pageSize,
  List<int> pageSizeOpts = const [10, 20, 40, 100],
  SemiPaginationSize size = SemiPaginationSize.defaultSize,
  int? currentPage,
  int defaultCurrentPage = 1,
  ValueChanged<int>? onPageChange,
  ValueChanged<int>? onPageSizeChange,
  void Function(int currentPage, int pageSize)? onChange,
  Object? prevText,
  Object? nextText,
  bool showSizeChanger = false,
  bool showQuickJumper = false,
  int popoverZIndex = 1030,
  SemiTooltipPosition? popoverPosition,
  bool hideOnSinglePage = false,
  bool hoverShowPageSelect = false,
  bool disabled = false,
  bool preventPageChangeOnPageSizeChange = false,
}) => SemiPagination(
  total: total,
  showTotal: showTotal,
  pageSize: pageSize,
  pageSizeOpts: pageSizeOpts,
  size: size,
  currentPage: currentPage,
  defaultCurrentPage: defaultCurrentPage,
  onPageChange: onPageChange,
  onPageSizeChange: onPageSizeChange,
  onChange: onChange,
  prevText: prevText,
  nextText: nextText,
  showSizeChanger: showSizeChanger,
  showQuickJumper: showQuickJumper,
  popoverZIndex: popoverZIndex,
  popoverPosition: popoverPosition,
  hideOnSinglePage: hideOnSinglePage,
  hoverShowPageSelect: hoverShowPageSelect,
  disabled: disabled,
  preventPageChangeOnPageSizeChange: preventPageChangeOnPageSizeChange,
);

Color? itemBg(WidgetTester tester, String label) {
  final box = find
      .ancestor(of: find.text(label), matching: find.byType(AnimatedContainer))
      .first;
  final decoration =
      tester.widget<AnimatedContainer>(box).decoration as BoxDecoration?;
  return decoration?.color;
}

// -- theme field table -------------------------------------------------------

typedef _Patch = SemiPaginationThemeData Function(Object value);
typedef _Read = Object? Function(SemiResolvedPaginationThemeData data);
typedef _Default = Object? Function(SemiThemeData theme);

const _c = Color(0xFF010203);

final List<(String, Object, _Patch, _Read, _Default)> fields = [
  (
    r'$color-pagination-text-default: var(--semi-color-text-2)',
    _c,
    (v) => SemiPaginationThemeData(colorPaginationTextDefault: v as Color),
    (d) => d.colorPaginationTextDefault,
    (t) => t.colors.colorText2,
  ),
  (
    r'$color-pagination_item-text-default: var(--semi-color-text-0)',
    _c,
    (v) => SemiPaginationThemeData(colorPaginationItemTextDefault: v as Color),
    (d) => d.colorPaginationItemTextDefault,
    (t) => t.colors.colorText0,
  ),
  (
    r'$color-pagination_item-bg-default: transparent',
    _c,
    (v) => SemiPaginationThemeData(colorPaginationItemBgDefault: v as Color),
    (d) => d.colorPaginationItemBgDefault,
    (t) => const Color(0x00000000),
  ),
  (
    r'$color-pagination_item-icon-default: var(--semi-color-tertiary)',
    _c,
    (v) => SemiPaginationThemeData(colorPaginationItemIconDefault: v as Color),
    (d) => d.colorPaginationItemIconDefault,
    (t) => t.colors.colorTertiary,
  ),
  (
    r'$color-pagination_item-text-hover: var(--semi-color-text-0)',
    _c,
    (v) => SemiPaginationThemeData(colorPaginationItemTextHover: v as Color),
    (d) => d.colorPaginationItemTextHover,
    (t) => t.colors.colorText0,
  ),
  (
    r'$color-pagination_item-bg-hover: var(--semi-color-fill-0)',
    _c,
    (v) => SemiPaginationThemeData(colorPaginationItemBgHover: v as Color),
    (d) => d.colorPaginationItemBgHover,
    (t) => t.colors.colorFill0,
  ),
  (
    r'$color-pagination_item-text-active: var(--semi-color-text-0)',
    _c,
    (v) => SemiPaginationThemeData(colorPaginationItemTextActive: v as Color),
    (d) => d.colorPaginationItemTextActive,
    (t) => t.colors.colorText0,
  ),
  (
    r'$color-pagination_item-bg-active: var(--semi-color-fill-1)',
    _c,
    (v) => SemiPaginationThemeData(colorPaginationItemBgActive: v as Color),
    (d) => d.colorPaginationItemBgActive,
    (t) => t.colors.colorFill1,
  ),
  (
    r'$color-pagination_item-text-disabled: var(--semi-color-disabled-text)',
    _c,
    (v) => SemiPaginationThemeData(colorPaginationItemTextDisabled: v as Color),
    (d) => d.colorPaginationItemTextDisabled,
    (t) => t.colors.colorDisabledText,
  ),
  (
    r'$color-pagination_item-icon-disabled: var(--semi-color-disabled-text)',
    _c,
    (v) => SemiPaginationThemeData(colorPaginationItemIconDisabled: v as Color),
    (d) => d.colorPaginationItemIconDisabled,
    (t) => t.colors.colorDisabledText,
  ),
  (
    r'$color-pagination_item-bg-disabled: transparent',
    _c,
    (v) => SemiPaginationThemeData(colorPaginationItemBgDisabled: v as Color),
    (d) => d.colorPaginationItemBgDisabled,
    (t) => const Color(0x00000000),
  ),
  (
    r'$color-pagination_item-bg-selected-disabled: var(--semi-color-disabled-fill)',
    _c,
    (v) => SemiPaginationThemeData(
      colorPaginationItemBgSelectedDisabled: v as Color,
    ),
    (d) => d.colorPaginationItemBgSelectedDisabled,
    (t) => t.colors.colorDisabledFill,
  ),
  (
    r'$color-pagination_item-text-selected: var(--semi-color-primary)',
    _c,
    (v) => SemiPaginationThemeData(colorPaginationItemTextSelected: v as Color),
    (d) => d.colorPaginationItemTextSelected,
    (t) => t.colors.colorPrimary,
  ),
  (
    r'$color-pagination_item-bg-selected: var(--semi-color-primary-light-default)',
    _c,
    (v) => SemiPaginationThemeData(colorPaginationItemBgSelected: v as Color),
    (d) => d.colorPaginationItemBgSelected,
    (t) => t.colors.colorPrimaryLightDefault,
  ),
  (
    r'$color-pagination_quickjump_text-disabled: var(--semi-color-disabled-text)',
    _c,
    (v) => SemiPaginationThemeData(
      colorPaginationQuickjumpTextDisabled: v as Color,
    ),
    (d) => d.colorPaginationQuickjumpTextDisabled,
    (t) => t.colors.colorDisabledText,
  ),
  (
    r'$color-pagination_item-border-default: transparent',
    _c,
    (v) =>
        SemiPaginationThemeData(colorPaginationItemBorderDefault: v as Color),
    (d) => d.colorPaginationItemBorderDefault,
    (t) => const Color(0x00000000),
  ),
  (
    r'$color-pagination_item-border-hover: transparent',
    _c,
    (v) => SemiPaginationThemeData(colorPaginationItemBorderHover: v as Color),
    (d) => d.colorPaginationItemBorderHover,
    (t) => const Color(0x00000000),
  ),
  (
    r'$color-pagination_item-border-active: transparent',
    _c,
    (v) => SemiPaginationThemeData(colorPaginationItemBorderActive: v as Color),
    (d) => d.colorPaginationItemBorderActive,
    (t) => const Color(0x00000000),
  ),
  (
    r'$color-pagination_item-border-selected: transparent',
    _c,
    (v) =>
        SemiPaginationThemeData(colorPaginationItemBorderSelected: v as Color),
    (d) => d.colorPaginationItemBorderSelected,
    (t) => const Color(0x00000000),
  ),
  (
    r'$color-pagination_item-border-disabled: transparent',
    _c,
    (v) =>
        SemiPaginationThemeData(colorPaginationItemBorderDisabled: v as Color),
    (d) => d.colorPaginationItemBorderDisabled,
    (t) => const Color(0x00000000),
  ),
  (
    r'$height-pagination_item: 32px',
    101.0,
    (v) => SemiPaginationThemeData(heightPaginationItem: v as double),
    (d) => d.heightPaginationItem,
    (t) => 32.0,
  ),
  (
    r'$width-pagination_item-minWidth: 32px',
    101.0,
    (v) => SemiPaginationThemeData(widthPaginationItemMinWidth: v as double),
    (d) => d.widthPaginationItemMinWidth,
    (t) => 32.0,
  ),
  (
    r'$width-pagination_item_small-minWidth: 44px',
    101.0,
    (v) =>
        SemiPaginationThemeData(widthPaginationItemSmallMinWidth: v as double),
    (d) => d.widthPaginationItemSmallMinWidth,
    (t) => 44.0,
  ),
  (
    r'$width-pagination_quickjump_input_width: 50px',
    101.0,
    (v) => SemiPaginationThemeData(
      widthPaginationQuickjumpInputWidth: v as double,
    ),
    (d) => d.widthPaginationQuickjumpInputWidth,
    (t) => 50.0,
  ),
  (
    r'$width-pagination_item_border: 0px',
    101.0,
    (v) => SemiPaginationThemeData(widthPaginationItemBorder: v as double),
    (d) => d.widthPaginationItemBorder,
    (t) => 0.0,
  ),
  (
    r'$spacing-pagination-padding: 0',
    101.0,
    (v) => SemiPaginationThemeData(spacingPaginationPadding: v as double),
    (d) => d.spacingPaginationPadding,
    (t) => 0.0,
  ),
  (
    r'$spacing-pagination_small-paddingY: 0',
    101.0,
    (v) => SemiPaginationThemeData(spacingPaginationSmallPaddingY: v as double),
    (d) => d.spacingPaginationSmallPaddingY,
    (t) => 0.0,
  ),
  (
    r'$spacing-pagination_small-paddingX: 0',
    101.0,
    (v) => SemiPaginationThemeData(spacingPaginationSmallPaddingX: v as double),
    (d) => d.spacingPaginationSmallPaddingX,
    (t) => 0.0,
  ),
  (
    r'$spacing-pagination_item-marginLeft: $spacing-extra-tight',
    101.0,
    (v) =>
        SemiPaginationThemeData(spacingPaginationItemMarginLeft: v as double),
    (d) => d.spacingPaginationItemMarginLeft,
    (t) => 4.0,
  ),
  (
    r'$spacing-pagination_item-marginRight: $spacing-extra-tight',
    101.0,
    (v) =>
        SemiPaginationThemeData(spacingPaginationItemMarginRight: v as double),
    (d) => d.spacingPaginationItemMarginRight,
    (t) => 4.0,
  ),
  (
    r'$spacing-pagination_item_small-margin: 0',
    101.0,
    (v) =>
        SemiPaginationThemeData(spacingPaginationItemSmallMargin: v as double),
    (d) => d.spacingPaginationItemSmallMargin,
    (t) => 0.0,
  ),
  (
    r'$spacing-pagination_reset_list-paddingTop: $spacing-extra-tight',
    101.0,
    (v) => SemiPaginationThemeData(
      spacingPaginationResetListPaddingTop: v as double,
    ),
    (d) => d.spacingPaginationResetListPaddingTop,
    (t) => 4.0,
  ),
  (
    r'$spacing-pagination_reset_list-paddingBottom: $spacing-extra-tight',
    101.0,
    (v) => SemiPaginationThemeData(
      spacingPaginationResetListPaddingBottom: v as double,
    ),
    (d) => d.spacingPaginationResetListPaddingBottom,
    (t) => 4.0,
  ),
  (
    r'$spacing-pagination_quickjump_marginLeft: 24px',
    101.0,
    (v) => SemiPaginationThemeData(
      spacingPaginationQuickjumpMarginLeft: v as double,
    ),
    (d) => d.spacingPaginationQuickjumpMarginLeft,
    (t) => 24.0,
  ),
  (
    r'$spacing-pagination_quickjump_input_marginLeft: 4px',
    101.0,
    (v) => SemiPaginationThemeData(
      spacingPaginationQuickjumpInputMarginLeft: v as double,
    ),
    (d) => d.spacingPaginationQuickjumpInputMarginLeft,
    (t) => 4.0,
  ),
  (
    r'$spacing-pagination_quickjump_input_marginRight: 4px',
    101.0,
    (v) => SemiPaginationThemeData(
      spacingPaginationQuickjumpInputMarginRight: v as double,
    ),
    (d) => d.spacingPaginationQuickjumpInputMarginRight,
    (t) => 4.0,
  ),
  (
    r'$radius-pagination_item: var(--semi-border-radius-small)',
    101.0,
    (v) => SemiPaginationThemeData(radiusPaginationItem: v as double),
    (d) => d.radiusPaginationItem,
    (t) => 3.0,
  ),
  (
    r'$font-pagination_small-fontWeight: $font-weight-regular',
    FontWeight.w300,
    (v) =>
        SemiPaginationThemeData(fontPaginationSmallFontWeight: v as FontWeight),
    (d) => d.fontPaginationSmallFontWeight,
    (t) => t.typography.fontWeightRegular,
  ),
  (
    r'$font-pagination_item-fontWeight: $font-weight-regular',
    FontWeight.w300,
    (v) =>
        SemiPaginationThemeData(fontPaginationItemFontWeight: v as FontWeight),
    (d) => d.fontPaginationItemFontWeight,
    (t) => t.typography.fontWeightRegular,
  ),
  (
    r'$font-pagination_item_active-fontWeight: $font-weight-bold',
    FontWeight.w300,
    (v) => SemiPaginationThemeData(
      fontPaginationItemActiveFontWeight: v as FontWeight,
    ),
    (d) => d.fontPaginationItemActiveFontWeight,
    (t) => t.typography.fontWeightBold,
  ),
  (
    r'$font-pagination_quickjump_fontWeight: $font-weight-regular',
    FontWeight.w300,
    (v) => SemiPaginationThemeData(
      fontPaginationQuickjumpFontWeight: v as FontWeight,
    ),
    (d) => d.fontPaginationQuickjumpFontWeight,
    (t) => t.typography.fontWeightRegular,
  ),
  (
    r'$transition_duration-pagination_item-bg: var(--semi-transition_duration-none)',
    const Duration(milliseconds: 1),
    (v) => SemiPaginationThemeData(
      transitionDurationPaginationItemBg: v as Duration,
    ),
    (d) => d.transitionDurationPaginationItemBg,
    (t) => Duration.zero,
  ),
  (
    r'$transition_function-pagination_item-bg: var(--semi-transition_function-easeIn)',
    Curves.easeOut,
    (v) =>
        SemiPaginationThemeData(transitionFunctionPaginationItemBg: v as Curve),
    (d) => d.transitionFunctionPaginationItemBg,
    (t) => Curves.easeIn,
  ),
  (
    r'$transition_delay-pagination_item-bg: var(--semi-transition_delay-none)',
    const Duration(milliseconds: 2),
    (v) =>
        SemiPaginationThemeData(transitionDelayPaginationItemBg: v as Duration),
    (d) => d.transitionDelayPaginationItemBg,
    (t) => Duration.zero,
  ),
  (
    r'$transition_duration-pagination_item-text: var(--semi-transition_duration-none)',
    const Duration(milliseconds: 1),
    (v) => SemiPaginationThemeData(
      transitionDurationPaginationItemText: v as Duration,
    ),
    (d) => d.transitionDurationPaginationItemText,
    (t) => Duration.zero,
  ),
  (
    r'$transition_function-pagination_item-text: var(--semi-transition_function-easeIn)',
    Curves.easeOut,
    (v) => SemiPaginationThemeData(
      transitionFunctionPaginationItemText: v as Curve,
    ),
    (d) => d.transitionFunctionPaginationItemText,
    (t) => Curves.easeIn,
  ),
  (
    r'$transition_delay-pagination_item-text: var(--semi-transition_delay-none)',
    const Duration(milliseconds: 2),
    (v) => SemiPaginationThemeData(
      transitionDelayPaginationItemText: v as Duration,
    ),
    (d) => d.transitionDelayPaginationItemText,
    (t) => Duration.zero,
  ),
  (
    r'$transform_scale-pagination_item: var(--semi-transform_scale-none)',
    const SemiTransform.scale(2, 3),
    (v) => SemiPaginationThemeData(
      transformScalePaginationItem: v as SemiTransform,
    ),
    (d) => d.transformScalePaginationItem,
    (t) => const SemiTransform.scale(1, 1),
  ),
];

void main() {
  group('theme fields (48 = 41 FIELDS + 7 MOTION + 0 INTERNAL)', () {
    test('48 fields: merge, copyWith, resolve, equality, defaults', () {
      expect(fields, hasLength(48));
      for (final (sass, value, make, read, expected) in fields) {
        final patch = make(value);
        expect(
          const SemiPaginationThemeData().merge(patch),
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
          read(const SemiPaginationThemeData().resolve(light)),
          expected(light),
          reason: sass,
        );
        final dark = const SemiThemeData.dark();
        expect(
          read(const SemiPaginationThemeData().resolve(dark)),
          expected(dark),
          reason: sass,
        );
      }
    });

    test('every field carries its Sass provenance in the generated source', () {
      final source = File('lib/src/theme/semi_pagination_theme_data.dart')
          .readAsStringSync();
      final names = <String>{};
      for (final (sass, _, _, _, _) in fields) {
        expect(source, contains(sass));
        names.add(sass.split(': ').first.substring(1));
      }
      expect(names, hasLength(48));
      // ★provenance quirk 照抄：`reset` 错拼 / animation.scss 冒号后无空格。
      expect(source, contains(r'$spacing-pagination_reset_list-paddingTop'));
      expect(
        source,
        contains(
          r'$transition_duration-pagination_item-bg: '
          r'var(--semi-transition_duration-none)',
        ),
      );
      expect(
        source,
        contains('packages/semi-foundation/pagination/variables.scss'),
      );
      expect(
        source,
        contains('packages/semi-foundation/pagination/animation.scss'),
      );
      expect(source, contains('Generated by tool/generate_pagination.py'));
    });

    test('the 26 HARDCODES anchors live in the widget source', () {
      final widgetSource = File('lib/src/components/semi_pagination.dart')
          .readAsStringSync();
      const anchors = <String>[
        'PAGE_SHOW_MAX: 7',
        'REST_PAGE_SHOW_MAX: 5',
        'DEFAULT_PAGE_SIZE: 10',
        'PAGE_SIZE_OPTION: [10, 20, 40, 100]',
        'REST_PAGE_MAX_SIZE: 1000000',
        'const itemHeight = 32',
        'width={78}',
        'count >= 5 ? itemHeight * 5',
        "position: 'bottom'",
        'DEFAULT_Z_INDEX: 1030',
        'SPACING: 4',
        r"'每页条数：${pageSize}'",
        r"'总页数：${total}'",
        "'跳至'",
        "'页'",
        'aria-label="Previous"',
        'aria-label="Next"',
        r'Page ${page}',
        "'More'",
        "role={this.props.size === 'small' ? 'none' : undefined}",
        r'// padding-left: $spacing-base;',
        'transform:scale(scale(1,1))',
        'user-select: none',
        'hideOnSinglePage no longer takes effect',
        'style={{ direction }}',
        'semi-page-select-dropdown',
      ];
      expect(anchors, hasLength(26));
      for (final anchor in anchors) {
        expect(widgetSource, contains(anchor), reason: anchor);
      }
    });

    test('type coverage: 20 Color + 17 double + 4 FontWeight + 4 Duration + '
        '2 Curve + 1 SemiTransform = 48', () {
      final counts = <String, int>{};
      for (final (_, value, _, _, _) in fields) {
        final type = switch (value) {
          Curve() => 'Curve',
          SemiTransform() => 'SemiTransform',
          _ => value.runtimeType.toString(),
        };
        counts.update(type, (n) => n + 1, ifAbsent: () => 1);
      }
      expect(counts['Color'], 20);
      expect(counts['double'], 17);
      expect(counts['FontWeight'], 4);
      expect(counts['Duration'], 4);
      expect(counts['Curve'], 2);
      expect(counts['SemiTransform'], 1);
    });

    test('1 dead variable: assertNotIn + docs （上游未消费） mark', () {
      const deadFieldNames = ['colorPaginationItemBgDefault'];
      const deadSassNames = [r'$color-pagination_item-bg-default'];
      final widgetSource = File('lib/src/components/semi_pagination.dart')
          .readAsStringSync();
      expect(widgetSource, isNot(contains('# dead variable')));
      for (final name in deadFieldNames) {
        expect(widgetSource, isNot(contains(name)), reason: name);
      }
      final docs = File('docs/semi_pagination.md').readAsStringSync();
      expect(docs, contains('48 = 41 FIELDS + 7 MOTION + 0 INTERNAL'));
      for (final sass in deadSassNames) {
        final rows = docs
            .split('\n')
            .where((line) => line.contains('$sass:'))
            .toList();
        expect(rows, isNotEmpty, reason: sass);
        expect(rows.first, contains('（上游未消费）'), reason: sass);
      }
    });
  });

  group('behavior', () {
    testWidgets('renders pages, total text and prev/next states', (
      tester,
    ) async {
      await pumpHost(tester, pagination(total: 50, showTotal: true));
      // 5 页全量（≤ PAGE_SHOW_MAX 7）。
      for (final page in [1, 2, 3, 4, 5]) {
        expect(find.text('$page'), findsOneWidget);
      }
      expect(find.text('...'), findsNothing);
      expect(find.text('总页数：5'), findsOneWidget);
      // 当前页 1：prev 禁用、next 启用（cursor forbidden/click）。
      final prevRegion = tester.widget<MouseRegion>(
        find
            .descendant(
              of: find.byKey(SemiPagination.prevKey),
              matching: find.byType(MouseRegion),
            )
            .first,
      );
      expect(prevRegion.cursor, SystemMouseCursors.forbidden);
      final nextRegion = tester.widget<MouseRegion>(
        find
            .descendant(
              of: find.byKey(SemiPagination.nextKey),
              matching: find.byType(MouseRegion),
            )
            .first,
      );
      expect(nextRegion.cursor, SystemMouseCursors.click);
      // 选中页背景 primary-light-default。
      final resolved = const SemiPaginationThemeData().resolve(
        const SemiThemeData.light(),
      );
      expect(itemBg(tester, '1'), resolved.colorPaginationItemBgSelected);
    });

    testWidgets('tapping a page notifies onPageChange then onChange and '
        'updates the selection', (tester) async {
      final events = <String>[];
      await pumpHost(
        tester,
        pagination(
          total: 50,
          onPageChange: (page) => events.add('page:$page'),
          onChange: (page, size) => events.add('change:$page/$size'),
        ),
      );
      await tester.tap(find.text('3'));
      await tester.pump();
      expect(events, ['page:3', 'change:3/10']);
      final resolved = const SemiPaginationThemeData().resolve(
        const SemiThemeData.light(),
      );
      expect(itemBg(tester, '3'), resolved.colorPaginationItemBgSelected);
      expect(itemBg(tester, '1'), const Color(0x00000000));
    });

    testWidgets('hover and press paint the state fills', (tester) async {
      final gesture = await startMouse(tester);
      await pumpHost(tester, pagination(total: 100));
      final resolved = const SemiPaginationThemeData().resolve(
        const SemiThemeData.light(),
      );
      final target = find.text('2');
      await gesture.moveTo(tester.getCenter(target));
      await tester.pump();
      // :hover → fill-0。
      expect(itemBg(tester, '2'), resolved.colorPaginationItemBgHover);
      await gesture.down(tester.getCenter(target));
      await tester.pump();
      // :active → fill-1。
      expect(itemBg(tester, '2'), resolved.colorPaginationItemBgActive);
      await gesture.up();
      await tester.pump();
      // down+up 即点击第 2 页；指针仍在选中项上——hover 重设选中底色
      //（pagination.scss:75-79）。
      await gesture.moveTo(tester.getCenter(find.text('2')));
      await tester.pump();
      expect(itemBg(tester, '2'), resolved.colorPaginationItemBgSelected);
    });

    testWidgets('tapping the current page does nothing', (tester) async {
      final events = <String>[];
      await pumpHost(
        tester,
        pagination(total: 50, onPageChange: (page) => events.add('page:$page')),
      );
      await tester.tap(find.text('1'));
      await tester.pump();
      expect(events, isEmpty);
    });

    testWidgets('controlled currentPage: callbacks fire but the selection '
        'follows props', (tester) async {
      final events = <int>[];
      await pumpHost(
        tester,
        pagination(total: 50, currentPage: 1, onPageChange: events.add),
      );
      await tester.tap(find.text('3'));
      await tester.pump();
      expect(events, [3]);
      final resolved = const SemiPaginationThemeData().resolve(
        const SemiThemeData.light(),
      );
      expect(itemBg(tester, '1'), resolved.colorPaginationItemBgSelected);
      expect(itemBg(tester, '3'), const Color(0x00000000));
    });

    testWidgets('truncation matrix matches getPageList (7 slots)', (
      tester,
    ) async {
      Future<void> check(int current, List<String> expected) async {
        final opens = <int>[];
        await pumpHost(
          tester,
          pagination(total: 100, currentPage: current, onPageChange: opens.add),
        );
        for (final label in expected) {
          expect(find.text(label), findsWidgets, reason: 'c=$current $label');
        }
        // 7 个格子（1 + 3 中部 + ... + 尾页等）。
        final slots = [
          for (final label in [
            '1',
            '2',
            '3',
            '4',
            '5',
            '6',
            '7',
            '8',
            '9',
            '10',
            '...',
          ])
            find.text(label).evaluate().length,
        ];
        expect(slots.where((n) => n > 0).isNotEmpty, isTrue);
      }

      // c<4：[1,2,3,4,...,9,10]。
      await check(1, ['1', '2', '3', '4', '...', '9', '10']);
      // c==4：[1..5,...,10]。
      await check(4, ['1', '2', '3', '4', '5', '...', '10']);
      // 4<c<t-3：[1,...,c-1,c,c+1,...,10] 双省略号。
      await check(5, ['1', '...', '4', '5', '6', '...', '10']);
      // c=t-3 → fallback：[1,...,6..10]。
      await check(7, ['1', '...', '6', '7', '8', '9', '10']);
    });

    testWidgets('rest popup lists the hidden pages on hover', (tester) async {
      final gesture = await startMouse(tester);
      await pumpHost(tester, pagination(total: 100, currentPage: 5));
      // c=5：左 rest [2,3]、右 rest [7,8,9]。
      await gesture.moveTo(tester.getCenter(find.text('...').first));
      await settle(tester);
      expect(find.byKey(SemiPagination.restListKey), findsOneWidget);
      expect(
        find.descendant(
          of: find.byKey(SemiPagination.restListKey),
          matching: find.text('2'),
        ),
        findsOneWidget,
      );
      expect(
        find.descendant(
          of: find.byKey(SemiPagination.restListKey),
          matching: find.text('3'),
        ),
        findsOneWidget,
      );
    });

    testWidgets(
      'page size changer updates size and keeps the first item page',
      (tester) async {
        final events = <String>[];
        await pumpHost(
          tester,
          pagination(
            total: 100,
            pageSize: 10,
            defaultCurrentPage: 3,
            showSizeChanger: true,
            onPageSizeChange: (size) => events.add('size:$size'),
            onPageChange: (page) => events.add('page:$page'),
            onChange: (page, size) => events.add('change:$page/$size'),
          ),
        );
        await tester.tap(find.byKey(SemiPagination.sizeChangerKey));
        await settle(tester);
        await tester.tap(find.text('每页条数：20'));
        await settle(tester);
        // 首条 index = (3-1)*10+1 = 21 → ceil(21/20)=2；顺序 size→page→change。
        expect(events, ['size:20', 'page:2', 'change:2/20']);
      },
    );

    testWidgets('preventPageChangeOnPageSizeChange keeps the current page', (
      tester,
    ) async {
      final events = <String>[];
      await pumpHost(
        tester,
        pagination(
          total: 100,
          pageSize: 10,
          defaultCurrentPage: 3,
          showSizeChanger: true,
          preventPageChangeOnPageSizeChange: true,
          onPageChange: (page) => events.add('page:$page'),
          onChange: (page, size) => events.add('change:$page/$size'),
        ),
      );
      await tester.tap(find.byKey(SemiPagination.sizeChangerKey));
      await settle(tester);
      await tester.tap(find.text('每页条数：20'));
      await settle(tester);
      expect(events, ['change:3/20']);
    });

    testWidgets('quick jump clamps on Enter and clears the input', (
      tester,
    ) async {
      final events = <int>[];
      await pumpHost(
        tester,
        pagination(total: 100, showQuickJumper: true, onPageChange: events.add),
      );
      final input = find.descendant(
        of: find.byKey(SemiPagination.quickJumpInputKey),
        matching: find.byType(EditableText),
      );
      await tester.enterText(input, '999');
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.pumpAndSettle();
      expect(events, [10]);
      expect(tester.widget<EditableText>(input).controller.text, '');
      await tester.enterText(input, '0');
      FocusManager.instance.primaryFocus?.unfocus();
      await tester.pumpAndSettle();
      expect(events, [10, 1]);
      // 空串/NaN no-op。
      await tester.enterText(input, 'abc');
      FocusManager.instance.primaryFocus?.unfocus();
      await tester.pumpAndSettle();
      expect(events, [10, 1]);
    });

    testWidgets('small size shows the current/total summary and hover page '
        'select', (tester) async {
      final events = <int>[];
      await pumpHost(
        tester,
        pagination(
          total: 100,
          defaultCurrentPage: 3,
          size: SemiPaginationSize.small,
          hoverShowPageSelect: true,
          onPageChange: events.add,
        ),
      );
      expect(find.text('3/10'), findsOneWidget);
      final gesture = await startMouse(tester);
      await gesture.moveTo(tester.getCenter(find.text('3/10')));
      await settle(tester);
      expect(find.byKey(SemiPagination.restListKey), findsOneWidget);
      // 弹层最多 5 行可视（restListMaxRows），点首屏可见的第 2 页。
      await tester.tap(
        find.descendant(
          of: find.byKey(SemiPagination.restListKey),
          matching: find.text('2'),
        ),
      );
      await tester.pumpAndSettle();
      expect(events, [2]);
      expect(find.text('2/10'), findsOneWidget);
    });

    testWidgets('disabled blocks all interaction and paints disabled/selected '
        'colors', (tester) async {
      final events = <String>[];
      await pumpHost(
        tester,
        pagination(
          total: 100,
          defaultCurrentPage: 2,
          showSizeChanger: true,
          showQuickJumper: true,
          disabled: true,
          onPageChange: (page) => events.add('page:$page'),
        ),
      );
      await tester.tap(find.text('3'));
      await tester.pump();
      expect(events, isEmpty);
      final resolved = const SemiPaginationThemeData().resolve(
        const SemiThemeData.light(),
      );
      expect(
        itemBg(tester, '2'),
        resolved.colorPaginationItemBgSelectedDisabled,
      );
      expect(itemBg(tester, '3'), resolved.colorPaginationItemBgDisabled);
      final prevRegion = tester.widget<MouseRegion>(
        find
            .descendant(
              of: find.byKey(SemiPagination.prevKey),
              matching: find.byType(MouseRegion),
            )
            .first,
      );
      expect(prevRegion.cursor, SystemMouseCursors.forbidden);
    });

    testWidgets('hideOnSinglePage hides one page but yields to the size '
        'changer', (tester) async {
      await pumpHost(tester, pagination(total: 10, hideOnSinglePage: true));
      expect(find.byKey(SemiPagination.rootKey), findsNothing);
      await pumpHost(
        tester,
        pagination(total: 10, hideOnSinglePage: true, showSizeChanger: true),
      );
      // ★上游 warning：两开关同开时 hideOnSinglePage 失效（照抄）。
      expect(find.byKey(SemiPagination.rootKey), findsOneWidget);
      await pumpHost(tester, pagination(total: 20, hideOnSinglePage: true));
      expect(find.byKey(SemiPagination.rootKey), findsOneWidget);
    });

    testWidgets('prevText/nextText replace the default chevrons', (
      tester,
    ) async {
      await pumpHost(
        tester,
        pagination(total: 100, prevText: '上一页', nextText: '下一页'),
      );
      expect(find.text('上一页'), findsOneWidget);
      expect(find.text('下一页'), findsOneWidget);
      expect(find.byType(SemiIcon), findsNothing);
    });

    testWidgets('RTL mirrors the prev/next chevrons and keeps directional '
        'margins', (tester) async {
      await pumpHost(
        tester,
        pagination(total: 100),
        direction: TextDirection.rtl,
      );
      final mirrored = tester
          .widgetList<Transform>(
            find.descendant(
              of: find.byKey(SemiPagination.prevKey),
              matching: find.byType(Transform),
            ),
          )
          .where((t) => t.transform.storage[0] == -1);
      expect(mirrored, isNotEmpty);
      final prevPadding = tester.widget<Padding>(
        find
            .descendant(
              of: find.byKey(SemiPagination.prevKey),
              matching: find.byType(Padding),
            )
            .first,
      );
      expect(
        prevPadding.padding,
        const EdgeInsetsDirectional.only(start: 4, end: 4),
      );
    });

    testWidgets('pageSize outside pageSizeOpts is inserted in order', (
      tester,
    ) async {
      await pumpHost(
        tester,
        pagination(total: 100, pageSize: 15, showSizeChanger: true),
      );
      await tester.tap(find.byKey(SemiPagination.sizeChangerKey));
      await settle(tester);
      // 15 插在 10 与 20 之间（面板内按序展示；触发器自身也显示当前项）。
      Finder panel(String label) => find.descendant(
        of: find.byType(SemiTooltipPopup),
        matching: find.text(label),
      );
      expect(panel('每页条数：10'), findsOneWidget);
      expect(panel('每页条数：15'), findsOneWidget);
      expect(panel('每页条数：20'), findsOneWidget);
    });
  });
}
