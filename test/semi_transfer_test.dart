// Behavior matrix for SemiTransfer plus coverage for the 50 Sass declarations
// (47 FIELDS + 3 MOTION + 0 INTERNAL) — the 26 HARDCODES provenance anchors
// live in the widget's `_TransferMetrics` / call sites, the 2 dead FIELDS
// (上游未消费) must NOT appear in the widget, and the 2 drag-deferred FIELDS
// carry 「本移植未消费（draggable 延期）」 in the docs.
import 'dart:async';
import 'dart:io';
import 'dart:ui' as ui;

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
  double width = 500,
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
                  child: SizedBox(width: width, child: child),
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
  double width = 500,
}) async {
  await tester.binding.setSurfaceSize(const Size(1200, 1200));
  await tester.pumpWidget(host(child, direction: direction, width: width));
}

// -- finders -----------------------------------------------------------------

Finder leftText(String label) => find.descendant(
  of: find.byKey(SemiTransfer.leftListKey),
  matching: find.text(label),
);

Finder rightText(String label) => find.descendant(
  of: find.byKey(SemiTransfer.rightListKey),
  matching: find.text(label),
);

Finder rightRow(Object key) => find.descendant(
  of: find.byKey(SemiTransfer.rightListKey),
  matching: find.byKey(SemiTransfer.itemKey(key)),
);

Finder leftRow(Object key) => find.descendant(
  of: find.byKey(SemiTransfer.leftListKey),
  matching: find.byKey(SemiTransfer.itemKey(key)),
);

List<String> rightLabels(WidgetTester tester) => tester
    .widgetList<Text>(
      find.descendant(
        of: find.byKey(SemiTransfer.rightListKey),
        matching: find.byType(Text),
      ),
    )
    .map((t) => t.data ?? '')
    .toList();

String totalText(WidgetTester tester) =>
    tester
        .widget<Text>(
          find.descendant(
            of: find.byKey(SemiTransfer.leftPanelKey),
            matching: find.textContaining('总个数'),
          ),
        )
        .data ??
    '';

// -- interactions ------------------------------------------------------------

Future<void> tapLabel(WidgetTester tester, String label) async {
  await tester.tap(leftText(label).first);
  await tester.pumpAndSettle();
}

Future<void> tapButton(WidgetTester tester, Key key) async {
  await tester.tap(find.byKey(key));
  await tester.pumpAndSettle();
}

Future<void> search(WidgetTester tester, String input) async {
  await tester.enterText(
    find.descendant(
      of: find.byKey(SemiTransfer.searchKey),
      matching: find.byType(EditableText),
    ),
    input,
  );
  await tester.pumpAndSettle();
}

Future<void> hover(WidgetTester tester, Finder finder) async {
  final gesture = await startMouse(tester);
  await gesture.moveTo(tester.getCenter(finder.first));
  await tester.pumpAndSettle();
}

// -- fixtures ----------------------------------------------------------------

List<SemiTransferItem> items() => const [
  SemiTransferItem(key: 'a', value: 'A', label: 'Alpha'),
  SemiTransferItem(key: 'b', value: 'B', label: 'Beta'),
  SemiTransferItem(key: 'c', value: 'C', label: 'Gamma'),
];

List<SemiTransferItem> pagedItems([int count = 21]) => [
  for (var i = 1; i <= count; i++)
    SemiTransferItem(key: 'item-$i', value: 'value-$i', label: 'Item $i'),
];

Widget transfer({
  List<Object> dataSource = const [],
  SemiTransferType type = SemiTransferType.list,
  List<Object?>? value,
  List<Object?>? defaultValue,
  bool filter = true,
  bool Function(String input, SemiTransferItem item)? filterFn,
  ValueChanged<String>? onSearch,
  ValueChanged<SemiTransferItem>? onSelect,
  ValueChanged<SemiTransferItem>? onDeselect,
  SemiTransferChanged? onChanged,
  bool disabled = false,
  bool loading = false,
  Widget? emptyLeft,
  Widget? emptyRight,
  Widget? emptySearch,
  Widget Function(BuildContext, SemiTransferItem, bool, VoidCallback)?
  renderSourceItem,
  Widget Function(BuildContext, SemiTransferItem, VoidCallback)?
  renderSelectedItem,
  Widget Function(BuildContext, SemiTransferHeaderProps)? renderSourceHeader,
  Widget Function(BuildContext, SemiTransferSelectedHeaderProps)?
  renderSelectedHeader,
  Widget Function(BuildContext, SemiTransferSourcePanelProps)?
  renderSourcePanel,
  Widget Function(BuildContext, SemiTransferSelectedPanelProps)?
  renderSelectedPanel,
  SemiTransferController? controller,
  SemiTransferPaginationProps? pagination,
  SemiTransferTreeProps? treeProps,
  bool showPath = false,
}) => SemiTransfer(
  dataSource: dataSource,
  type: type,
  value: value,
  defaultValue: defaultValue,
  filter: filter,
  filterFn: filterFn,
  onSearch: onSearch,
  onSelect: onSelect,
  onDeselect: onDeselect,
  onChanged: onChanged,
  disabled: disabled,
  loading: loading,
  emptyLeft: emptyLeft,
  emptyRight: emptyRight,
  emptySearch: emptySearch,
  renderSourceItem: renderSourceItem,
  renderSelectedItem: renderSelectedItem,
  renderSourceHeader: renderSourceHeader,
  renderSelectedHeader: renderSelectedHeader,
  renderSourcePanel: renderSourcePanel,
  renderSelectedPanel: renderSelectedPanel,
  controller: controller,
  pagination: pagination,
  treeProps: treeProps,
  showPath: showPath,
);

// -- theme field table -------------------------------------------------------

typedef _Patch = SemiTransferThemeData Function(Object value);
typedef _Read = Object? Function(SemiResolvedTransferThemeData data);
typedef _Default = Object? Function(SemiThemeData theme);

final List<(String, Object, _Patch, _Read, _Default)> fields = [
  (
    r'$color-transfer-bg: var(--semi-color-bg-1)',
    const Color(0xff010101),
    (v) => SemiTransferThemeData(colorTransferBg: v as Color),
    (d) => d.colorTransferBg,
    (t) => t.colors.colorBg1,
  ),
  (
    r'$color-transfer_disabled-bg: var(--semi-color-disabled-fill)',
    const Color(0xff020202),
    (v) => SemiTransferThemeData(colorTransferDisabledBg: v as Color),
    (d) => d.colorTransferDisabledBg,
    (t) => t.colors.colorDisabledFill,
  ),
  (
    r'$color-transfer-border: var(--semi-color-border)',
    const Color(0xff030303),
    (v) => SemiTransferThemeData(colorTransferBorder: v as Color),
    (d) => d.colorTransferBorder,
    (t) => t.colors.colorBorder,
  ),
  (
    r'$color-transfer_header-text: var(--semi-color-text-2)',
    const Color(0xff040404),
    (v) => SemiTransferThemeData(colorTransferHeaderText: v as Color),
    (d) => d.colorTransferHeaderText,
    (t) => t.colors.colorText2,
  ),
  (
    r'$color-transfer_empty-text: var(--semi-color-text-2)',
    const Color(0xff050505),
    (v) => SemiTransferThemeData(colorTransferEmptyText: v as Color),
    (d) => d.colorTransferEmptyText,
    (t) => t.colors.colorText2,
  ),
  (
    r'$color-transfer_group_title-text: var(--semi-color-text-2)',
    const Color(0xff060606),
    (v) => SemiTransferThemeData(colorTransferGroupTitleText: v as Color),
    (d) => d.colorTransferGroupTitleText,
    (t) => t.colors.colorText2,
  ),
  (
    r'$color-transfer_disabled-text: var(--semi-color-disabled-text)',
    const Color(0xff070707),
    (v) => SemiTransferThemeData(colorTransferDisabledText: v as Color),
    (d) => d.colorTransferDisabledText,
    (t) => t.colors.colorDisabledText,
  ),
  (
    r'$color-transfer_close_icon-icon: var(--semi-color-text-2)',
    const Color(0xff080808),
    (v) => SemiTransferThemeData(colorTransferCloseIconIcon: v as Color),
    (d) => d.colorTransferCloseIconIcon,
    (t) => t.colors.colorText2,
  ),
  (
    r'$color-transfer_item-text: var(--semi-color-text-1)',
    const Color(0xff090909),
    (v) => SemiTransferThemeData(colorTransferItemText: v as Color),
    (d) => d.colorTransferItemText,
    (t) => t.colors.colorText1,
  ),
  (
    r'$color-transfer_selected_item-text: var(--semi-color-text-0)',
    const Color(0xff0a0a0a),
    (v) => SemiTransferThemeData(colorTransferSelectedItemText: v as Color),
    (d) => d.colorTransferSelectedItemText,
    (t) => t.colors.colorText0,
  ),
  (
    r'$color-transfer_item-bg-default: var(--semi-color-white)',
    const Color(0xff0b0b0b),
    (v) => SemiTransferThemeData(colorTransferItemBgDefault: v as Color),
    (d) => d.colorTransferItemBgDefault,
    (t) => t.colors.colorWhite,
  ),
  (
    r'$color-transfer_item-bg-hover: var(--semi-color-fill-0)',
    const Color(0xff0c0c0c),
    (v) => SemiTransferThemeData(colorTransferItemBgHover: v as Color),
    (d) => d.colorTransferItemBgHover,
    (t) => t.colors.colorFill0,
  ),
  (
    r'$color-transfer_item-bg-active: var(--semi-color-fill-1)',
    const Color(0xff0d0d0d),
    (v) => SemiTransferThemeData(colorTransferItemBgActive: v as Color),
    (d) => d.colorTransferItemBgActive,
    (t) => t.colors.colorFill1,
  ),
  (
    r'$width-transfer-border: 1px',
    11.0,
    (v) => SemiTransferThemeData(widthTransferBorder: v as double),
    (d) => d.widthTransferBorder,
    (t) => 1.0,
  ),
  (
    r'$width-transfer-minWidth: 402px',
    12.0,
    (v) => SemiTransferThemeData(widthTransferMinWidth: v as double),
    (d) => d.widthTransferMinWidth,
    (t) => 402.0,
  ),
  (
    r'$height-transfer: 400px',
    13.0,
    (v) => SemiTransferThemeData(heightTransfer: v as double),
    (d) => d.heightTransfer,
    (t) => 400.0,
  ),
  (
    r'$height-transfer_header: 24px',
    14.0,
    (v) => SemiTransferThemeData(heightTransferHeader: v as double),
    (d) => d.heightTransferHeader,
    (t) => 24.0,
  ),
  (
    r'$height-transfer_item-minHeight: 36px',
    15.0,
    (v) => SemiTransferThemeData(heightTransferItemMinHeight: v as double),
    (d) => d.heightTransferItemMinHeight,
    (t) => 36.0,
  ),
  (
    r'$width-transfer_item_close-icon: $width-icon-small',
    16.0,
    (v) => SemiTransferThemeData(widthTransferItemCloseIcon: v as double),
    (d) => d.widthTransferItemCloseIcon,
    (t) => 12.0,
  ),
  (
    r'$width-transfer_left: 50%',
    17.0,
    (v) => SemiTransferThemeData(widthTransferLeft: v as double),
    (d) => d.widthTransferLeft,
    (t) => 50.0,
  ),
  (
    r'$width-transfer_right: 50%',
    18.0,
    (v) => SemiTransferThemeData(widthTransferRight: v as double),
    (d) => d.widthTransferRight,
    (t) => 50.0,
  ),
  (
    r'$height-transfer_left_empty: 36px',
    19.0,
    (v) => SemiTransferThemeData(heightTransferLeftEmpty: v as double),
    (d) => d.heightTransferLeftEmpty,
    (t) => 36.0,
  ),
  (
    r'$width-transfer_left-border: $border-thickness-control',
    20.0,
    (v) => SemiTransferThemeData(widthTransferLeftBorder: v as double),
    (d) => d.widthTransferLeftBorder,
    (t) => 1.0,
  ),
  (
    r'$height-transfer_right_header: 32px',
    21.0,
    (v) => SemiTransferThemeData(heightTransferRightHeader: v as double),
    (d) => d.heightTransferRightHeader,
    (t) => 32.0,
  ),
  (
    r'$height-transfer_right_empty: 100%',
    22.0,
    (v) => SemiTransferThemeData(heightTransferRightEmpty: v as double),
    (d) => d.heightTransferRightEmpty,
    (t) => 100.0,
  ),
  (
    r'$width-transfer_empty: 100%',
    23.0,
    (v) => SemiTransferThemeData(widthTransferEmpty: v as double),
    (d) => d.widthTransferEmpty,
    (t) => 100.0,
  ),
  (
    r'$height-transfer_group_title: 28px',
    24.0,
    (v) => SemiTransferThemeData(heightTransferGroupTitle: v as double),
    (d) => d.heightTransferGroupTitle,
    (t) => 28.0,
  ),
  (
    r'$spacing-transfer_header-marginTop: 12px',
    25.0,
    (v) => SemiTransferThemeData(spacingTransferHeaderMarginTop: v as double),
    (d) => d.spacingTransferHeaderMarginTop,
    (t) => 12.0,
  ),
  (
    r'$spacing-transfer_header-marginRight: 12px',
    26.0,
    (v) => SemiTransferThemeData(spacingTransferHeaderMarginRight: v as double),
    (d) => d.spacingTransferHeaderMarginRight,
    (t) => 12.0,
  ),
  (
    r'$spacing-transfer_header-marginBottom: 8px',
    27.0,
    (v) =>
        SemiTransferThemeData(spacingTransferHeaderMarginBottom: v as double),
    (d) => d.spacingTransferHeaderMarginBottom,
    (t) => 8.0,
  ),
  (
    r'$spacing-transfer_header-marginLeft: 12px',
    28.0,
    (v) => SemiTransferThemeData(spacingTransferHeaderMarginLeft: v as double),
    (d) => d.spacingTransferHeaderMarginLeft,
    (t) => 12.0,
  ),
  (
    r'$spacing-transfer_header_all-marginLeft: $spacing-base',
    29.0,
    (v) =>
        SemiTransferThemeData(spacingTransferHeaderAllMarginLeft: v as double),
    (d) => d.spacingTransferHeaderAllMarginLeft,
    (t) => 16.0,
  ),
  (
    r'$spacing-transfer_item-paddingTop: $spacing-tight',
    30.0,
    (v) => SemiTransferThemeData(spacingTransferItemPaddingTop: v as double),
    (d) => d.spacingTransferItemPaddingTop,
    (t) => 8.0,
  ),
  (
    r'$spacing-transfer_item-paddingRight: 9px',
    31.0,
    (v) => SemiTransferThemeData(spacingTransferItemPaddingRight: v as double),
    (d) => d.spacingTransferItemPaddingRight,
    (t) => 9.0,
  ),
  (
    r'$spacing-transfer_item-paddingBottom: $spacing-tight',
    32.0,
    (v) => SemiTransferThemeData(spacingTransferItemPaddingBottom: v as double),
    (d) => d.spacingTransferItemPaddingBottom,
    (t) => 8.0,
  ),
  (
    r'$spacing-transfer_item-paddingLeft: $spacing-base-tight',
    33.0,
    (v) => SemiTransferThemeData(spacingTransferItemPaddingLeft: v as double),
    (d) => d.spacingTransferItemPaddingLeft,
    (t) => 12.0,
  ),
  (
    r'$spacing-transfer_right_header-marginTop: $spacing-base-tight',
    34.0,
    (v) =>
        SemiTransferThemeData(spacingTransferRightHeaderMarginTop: v as double),
    (d) => d.spacingTransferRightHeaderMarginTop,
    (t) => 12.0,
  ),
  (
    r'$spacing-transfer_right_header-marginBottom: 0',
    35.0,
    (v) => SemiTransferThemeData(
      spacingTransferRightHeaderMarginBottom: v as double,
    ),
    (d) => d.spacingTransferRightHeaderMarginBottom,
    (t) => 0.0,
  ),
  (
    r'$spacing-transfer_right_item_drag_handler-marginRight: 4px',
    36.0,
    (v) => SemiTransferThemeData(
      spacingTransferRightItemDragHandlerMarginRight: v as double,
    ),
    (d) => d.spacingTransferRightItemDragHandlerMarginRight,
    (t) => 4.0,
  ),
  (
    r'$spacing-transfer_filter-marginTop: 12px',
    37.0,
    (v) => SemiTransferThemeData(spacingTransferFilterMarginTop: v as double),
    (d) => d.spacingTransferFilterMarginTop,
    (t) => 12.0,
  ),
  (
    r'$spacing-transfer_filter-marginRight: 12px',
    38.0,
    (v) => SemiTransferThemeData(spacingTransferFilterMarginRight: v as double),
    (d) => d.spacingTransferFilterMarginRight,
    (t) => 12.0,
  ),
  (
    r'$spacing-transfer_filter-marginBottom: 0',
    39.0,
    (v) =>
        SemiTransferThemeData(spacingTransferFilterMarginBottom: v as double),
    (d) => d.spacingTransferFilterMarginBottom,
    (t) => 0.0,
  ),
  (
    r'$spacing-transfer_filter-marginLeft: 12px',
    40.0,
    (v) => SemiTransferThemeData(spacingTransferFilterMarginLeft: v as double),
    (d) => d.spacingTransferFilterMarginLeft,
    (t) => 12.0,
  ),
  (
    r'$spacing-transfer_group_title-paddingLeft: $spacing-base-tight',
    41.0,
    (v) => SemiTransferThemeData(
      spacingTransferGroupTitlePaddingLeft: v as double,
    ),
    (d) => d.spacingTransferGroupTitlePaddingLeft,
    (t) => 12.0,
  ),
  (
    r'$radius-transfer: var(--semi-border-radius-medium)',
    42.0,
    (v) => SemiTransferThemeData(radiusTransfer: v as double),
    (d) => d.radiusTransfer,
    (t) => t.radius.borderRadiusMedium.value,
  ),
  (
    r'$font-transfer_header_all-fontWeight: 600',
    43.0,
    (v) => SemiTransferThemeData(fontTransferHeaderAllFontWeight: v as double),
    (d) => d.fontTransferHeaderAllFontWeight,
    (t) => 600.0,
  ),
  (
    r'$z-transfer_right_item_drag_item_move: 2000 !default',
    44.0,
    (v) => SemiTransferThemeData(zTransferRightItemDragItemMove: v as double),
    (d) => d.zTransferRightItemDragItemMove,
    (t) => 2000.0,
  ),
  (
    r'$transition_duration_transfer_item-bg: var(--semi-transition_duration-none)',
    const Duration(milliseconds: 5),
    (v) =>
        SemiTransferThemeData(transitionDurationTransferItemBg: v as Duration),
    (d) => d.transitionDurationTransferItemBg,
    (t) => Duration.zero,
  ),
  (
    r'$transition_function_transfer_item-bg: var(--semi-transition_function-easeIn)',
    Curves.easeOut,
    (v) => SemiTransferThemeData(transitionFunctionTransferItemBg: v as Curve),
    (d) => d.transitionFunctionTransferItemBg,
    (t) => Curves.easeIn,
  ),
  (
    r'$transition_delay_transfer_item-bg: var(--semi-transition_delay-none)',
    const Duration(milliseconds: 6),
    (v) => SemiTransferThemeData(transitionDelayTransferItemBg: v as Duration),
    (d) => d.transitionDelayTransferItemBg,
    (t) => Duration.zero,
  ),
];

void main() {
  group('theme fields (50 = 47 FIELDS + 3 MOTION + 0 INTERNAL)', () {
    test('50 fields: merge, copyWith, resolve, equality, defaults', () {
      expect(fields, hasLength(50));
      for (final (sass, value, make, read, expected) in fields) {
        final patch = make(value);
        expect(const SemiTransferThemeData().merge(patch), patch, reason: sass);
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
          read(const SemiTransferThemeData().resolve(light)),
          expected(light),
          reason: sass,
        );
        final dark = const SemiThemeData.dark();
        expect(
          read(const SemiTransferThemeData().resolve(dark)),
          expected(dark),
          reason: sass,
        );
      }
    });

    test('every field carries its Sass provenance in the generated source', () {
      final source = File('lib/src/theme/semi_transfer_theme_data.dart')
          .readAsStringSync();
      final names = <String>{};
      for (final (sass, _, _, _, _) in fields) {
        expect(source, contains(sass));
        names.add(sass.split(': ').first.substring(1));
      }
      expect(names, hasLength(50));
    });

    test('the 26 HARDCODES anchors live in the widget source', () {
      final widgetSource = File('lib/src/components/semi_transfer.dart')
          .readAsStringSync();
      final anchors = <String>[
        'cursor: not-allowed',
        'visibility: hidden',
        'visibility: visible',
        'user-select: none',
        'word-break: break-all',
        'cursor: auto',
        'transition: background-color',
        'cursor: move',
        'opacity: 0',
        '// max-height: 412px',
        'DEFAULT_PAGE_SIZE: 10',
        "replace('\${total}',",
        "emptyLeft: '暂无数据',",
        "emptySearch: '无搜索结果',",
        "emptyRight: '暂无内容，可从左侧勾选',",
        "placeholder: '搜索',",
        "clear: '清空',",
        "selectAll: '全选',",
        "clearSelectAll: '取消全选',",
        "total: '总个数：\${total}',",
        "selected: '已选个数：\${total}',",
        r'$font-size-small: 12px',
        '@include font-size-regular',
        '@include ver-center',
        '@include all-center',
        r'>.#{$prefix}-spin {',
      ];
      expect(anchors, hasLength(26));
      for (final anchor in anchors) {
        expect(widgetSource, contains(anchor), reason: anchor);
      }
    });

    test('type coverage: 13 Color + 34 double + 2 Duration + 1 Curve', () {
      final counts = <String, int>{};
      for (final (_, value, _, _, _) in fields) {
        final type = value is Curve ? 'Curve' : value.runtimeType.toString();
        counts.update(type, (n) => n + 1, ifAbsent: () => 1);
      }
      expect(counts['Color'], 13);
      expect(counts['double'], 34);
      expect(counts['Duration'], 2);
      expect(counts['Curve'], 1);
    });

    test('dead FIELDS stay out of the widget; docs mark them (上游未消费)', () {
      const dead = [
        'color-transfer_disabled-bg',
        'color-transfer_item-bg-default',
      ];
      const deadFields = [
        'colorTransferDisabledBg',
        'colorTransferItemBgDefault',
      ];
      final widgetSource = File('lib/src/components/semi_transfer.dart')
          .readAsStringSync();
      for (final name in deadFields) {
        expect(widgetSource, isNot(contains(name)), reason: name);
      }
      final docs = File('docs/semi_transfer.md').readAsStringSync();
      for (final name in dead) {
        final rows = docs
            .split('\n')
            .where((line) => line.contains('\$$name:'))
            .toList();
        expect(rows, isNotEmpty, reason: name);
        expect(
          rows.any((row) => row.contains('（上游未消费）')),
          isTrue,
          reason: name,
        );
      }
    });

    test('drag-deferred FIELDS are marked 本移植未消费（draggable 延期）', () {
      const drag = [
        'spacing-transfer_right_item_drag_handler-marginRight',
        'z-transfer_right_item_drag_item_move',
      ];
      final docs = File('docs/semi_transfer.md').readAsStringSync();
      for (final name in drag) {
        final rows = docs
            .split('\n')
            .where((line) => line.contains('\$$name:'))
            .toList();
        expect(rows, isNotEmpty, reason: name);
        expect(
          rows.any((row) => row.contains('本移植未消费（draggable 延期）')),
          isTrue,
          reason: name,
        );
      }
    });

    test('SemiComponentThemes wiring', () {
      expect(
        const SemiComponentThemes().transfer,
        const SemiTransferThemeData(),
      );
      const patch = SemiTransferThemeData(heightTransfer: 500);
      const themes = SemiComponentThemes(transfer: patch);
      expect(const SemiComponentThemes().copyWith(transfer: patch), themes);
      expect(themes == const SemiComponentThemes(), isFalse);
      expect(themes.transfer, patch);
    });

    testWidgets('SemiTransferTheme local patch applies (nested merge, '
        'inner wins its own field)', (tester) async {
      await pumpHost(
        tester,
        SemiTheme(
          data: const SemiThemeData.light(),
          child: SemiTransferTheme(
            data: const SemiTransferThemeData(
              heightTransfer: 500,
              heightTransferItemMinHeight: 60,
            ),
            child: SemiTransferTheme(
              data: const SemiTransferThemeData(
                heightTransferItemMinHeight: 80,
              ),
              child: transfer(dataSource: items()),
            ),
          ),
        ),
        width: 402,
      );
      // Outer patch field (root height 500) still applies; the inner patch
      // wins its own field (item min-height 80) only.
      expect(tester.getSize(find.byKey(SemiTransfer.rootKey)).height, 500.0);
      expect(
        tester
            .getSize(
              find
                  .descendant(
                    of: find.byKey(SemiTransfer.leftListKey),
                    matching: find.byKey(SemiTransfer.itemKey('a')),
                  )
                  .first,
            )
            .height,
        80.0,
      );
    });
  });

  group('pagination', () {
    testWidgets('pages the left list with the default page size of 10', (
      tester,
    ) async {
      await pumpHost(
        tester,
        transfer(
          dataSource: pagedItems(),
          pagination: const SemiTransferPaginationProps(),
        ),
      );

      expect(leftRow('item-1'), findsOneWidget);
      expect(leftRow('item-11'), findsNothing);
      expect(find.byKey(SemiTransfer.leftPaginationKey), findsOneWidget);
      expect(find.byKey(SemiPagination.nextKey), findsOneWidget);
    });

    testWidgets('changes page and notifies the callback', (tester) async {
      final pages = <int>[];
      await pumpHost(
        tester,
        transfer(
          dataSource: pagedItems(),
          pagination: SemiTransferPaginationProps(
            pageSize: 5,
            onPageChange: pages.add,
          ),
        ),
      );

      await tapButton(tester, SemiPagination.nextKey);

      expect(pages, [2]);
      expect(leftRow('item-1'), findsNothing);
      expect(leftRow('item-6'), findsOneWidget);
      expect(leftRow('item-10'), findsOneWidget);
      expect(leftRow('item-11'), findsNothing);
    });

    testWidgets('search resets the page and pagination total follows matches', (
      tester,
    ) async {
      await pumpHost(
        tester,
        transfer(
          dataSource: pagedItems(),
          pagination: const SemiTransferPaginationProps(pageSize: 5),
        ),
      );
      await tapButton(tester, SemiPagination.nextKey);
      expect(leftRow('item-6'), findsOneWidget);

      await search(tester, 'Item 2');

      expect(leftRow('item-2'), findsOneWidget);
      expect(leftRow('item-6'), findsNothing);
      expect(find.byKey(SemiTransfer.leftPaginationKey), findsNothing);
      expect(totalText(tester), '总个数：3');
    });

    testWidgets('groupList paginates entries but keeps page-local headings', (
      tester,
    ) async {
      final groups = <Object>[
        SemiTransferGroup(title: '一组', children: pagedItems(6)),
        SemiTransferGroup(
          title: '二组',
          children: pagedItems(6)
              .map(
                (item) => SemiTransferItem(
                  key: 'second-${item.key}',
                  value: 'second-${item.value}',
                  label: item.label,
                ),
              )
              .toList(),
        ),
      ];
      await pumpHost(
        tester,
        transfer(
          type: SemiTransferType.groupList,
          dataSource: groups,
          pagination: const SemiTransferPaginationProps(pageSize: 6),
        ),
      );

      expect(find.text('一组'), findsOneWidget);
      expect(find.text('二组'), findsNothing);
      await tapButton(tester, SemiPagination.nextKey);
      expect(find.text('一组'), findsNothing);
      expect(find.text('二组'), findsOneWidget);
      expect(leftRow('second-item-1'), findsOneWidget);
    });

    testWidgets('treeList ignores transfer pagination', (tester) async {
      const tree = <SemiTransferItem>[
        SemiTransferItem(
          key: 'root',
          value: 'root',
          label: 'Root',
          children: [
            SemiTransferItem(key: 'leaf', value: 'leaf', label: 'Leaf'),
          ],
        ),
      ];
      await pumpHost(
        tester,
        transfer(
          type: SemiTransferType.treeList,
          dataSource: tree,
          pagination: const SemiTransferPaginationProps(pageSize: 1),
        ),
      );

      expect(find.byKey(SemiTransfer.leftPaginationKey), findsNothing);
      expect(find.byKey(SemiTransfer.leftListKey), findsOneWidget);
    });
  });

  group('勾选即穿梭 (no arrow buttons)', () {
    testWidgets('勾左栏进右栏、onChanged values 走 value 轨、onSelect', (tester) async {
      final changes = <(List<Object?>, List<SemiTransferItem>)>[];
      final selects = <SemiTransferItem>[];
      final deselects = <SemiTransferItem>[];
      await pumpHost(
        tester,
        transfer(
          dataSource: items(),
          onChanged: (values, selected) => changes.add((values, selected)),
          onSelect: selects.add,
          onDeselect: deselects.add,
        ),
      );
      expect(rightLabels(tester), isEmpty);
      await tapLabel(tester, 'Alpha');
      expect(rightLabels(tester), ['Alpha']);
      expect(changes.last.$1, ['A']);
      expect(changes.last.$2.map((i) => i.key), ['a']);
      expect(selects.single.key, 'a');
      // 取消勾选 → 出（onDeselect）。
      await tapLabel(tester, 'Alpha');
      expect(rightLabels(tester), isEmpty);
      expect(deselects.single.key, 'a');
      expect(changes.last.$1, isEmpty);
    });

    testWidgets('右栏 close 移除条目（hover 显 close）', (tester) async {
      final deselects = <SemiTransferItem>[];
      await pumpHost(
        tester,
        transfer(
          dataSource: items(),
          defaultValue: ['A', 'B'],
          onDeselect: deselects.add,
        ),
      );
      expect(rightLabels(tester), ['Alpha', 'Beta']);
      await hover(tester, rightRow('b'));
      final close = find.descendant(
        of: rightRow('b'),
        matching: find.byType(SemiIcon),
      );
      await tester.tap(close);
      await tester.pumpAndSettle();
      expect(rightLabels(tester), ['Alpha']);
      expect(deselects.single.key, 'b');
    });

    testWidgets('缺 value 的条目匹配不到 defaultValue、onChanged 出 null 条目', (
      tester,
    ) async {
      final changes = <List<Object?>>[];
      await pumpHost(
        tester,
        transfer(
          dataSource: const [
            SemiTransferItem(key: 'a', value: 'A', label: 'Alpha'),
            SemiTransferItem(key: 'n', label: 'NoValue'),
          ],
          defaultValue: ['A'],
          onChanged: (values, _) => changes.add(values),
        ),
      );
      // 'n' 无 value → 不匹配 defaultValue（transferUtils.ts:61-64 quirk）。
      expect(rightLabels(tester), ['Alpha']);
      await tapLabel(tester, 'NoValue');
      expect(rightLabels(tester), ['Alpha', 'NoValue']);
      // values 走 value 轨——缺 value 出 null 条目。
      expect(changes.last, ['A', null]);
    });

    testWidgets('defaultValue 未匹配值静默忽略', (tester) async {
      await pumpHost(
        tester,
        transfer(dataSource: items(), defaultValue: ['A', 'Z']),
      );
      expect(rightLabels(tester), ['Alpha']);
    });
  });

  group('全选 / 取消全选', () {
    testWidgets('动态文案切换 + 全选/取消全选', (tester) async {
      await pumpHost(tester, transfer(dataSource: items()));
      expect(find.text('全选'), findsOneWidget);
      await tapButton(tester, SemiTransfer.selectAllKey);
      expect(rightLabels(tester), ['Alpha', 'Beta', 'Gamma']);
      expect(find.text('取消全选'), findsOneWidget);
      await tapButton(tester, SemiTransfer.selectAllKey);
      expect(rightLabels(tester), isEmpty);
      expect(find.text('全选'), findsOneWidget);
    });

    testWidgets('搜索态只作用过滤结果', (tester) async {
      await pumpHost(tester, transfer(dataSource: items()));
      await search(tester, 'Alp');
      expect(totalText(tester), '总个数：1');
      await tapButton(tester, SemiTransfer.selectAllKey);
      expect(rightLabels(tester), ['Alpha']);
      await search(tester, '');
      expect(rightLabels(tester), ['Alpha']);
    });

    testWidgets('全部项 disabled 时隐藏全选按钮', (tester) async {
      await pumpHost(
        tester,
        transfer(
          dataSource: const [
            SemiTransferItem(
              key: 'a',
              value: 'A',
              label: 'Alpha',
              disabled: true,
            ),
            SemiTransferItem(
              key: 'b',
              value: 'B',
              label: 'Beta',
              disabled: true,
            ),
          ],
        ),
      );
      expect(find.byKey(SemiTransfer.selectAllKey), findsNothing);
    });

    testWidgets('全选跳过 disabled 项（已选 disabled 保留）', (tester) async {
      await pumpHost(
        tester,
        transfer(
          dataSource: const [
            SemiTransferItem(key: 'a', value: 'A', label: 'Alpha'),
            SemiTransferItem(
              key: 'b',
              value: 'B',
              label: 'Beta',
              disabled: true,
            ),
          ],
          defaultValue: ['B'],
        ),
      );
      await tapButton(tester, SemiTransfer.selectAllKey);
      // disabled 的 Beta 保留、未选不加未选 disabled；Alpha 加入。
      expect(rightLabels(tester), ['Beta', 'Alpha']);
    });
  });

  group('清空', () {
    testWidgets('清非 disabled、disabled 保留、按钮显示条件', (tester) async {
      await pumpHost(
        tester,
        transfer(
          dataSource: const [
            SemiTransferItem(key: 'a', value: 'A', label: 'Alpha'),
            SemiTransferItem(
              key: 'b',
              value: 'B',
              label: 'Beta',
              disabled: true,
            ),
          ],
          defaultValue: ['A', 'B'],
        ),
      );
      expect(rightLabels(tester), ['Alpha', 'Beta']);
      expect(find.byKey(SemiTransfer.clearKey), findsOneWidget);
      await tapButton(tester, SemiTransfer.clearKey);
      // 只删非 disabled——disabled 的 Beta 保留。
      expect(rightLabels(tester), ['Beta']);
      // 仅剩 disabled 选中 → 清空按钮隐藏（hasValidSelected 为假）。
      expect(find.byKey(SemiTransfer.clearKey), findsNothing);
    });

    testWidgets('无选中时清空按钮隐藏', (tester) async {
      await pumpHost(tester, transfer(dataSource: items()));
      expect(find.byKey(SemiTransfer.clearKey), findsNothing);
    });
  });

  group('搜索', () {
    testWidgets('默认 label 包含过滤 + 无结果 emptySearch', (tester) async {
      await pumpHost(
        tester,
        transfer(
          dataSource: items(),
          emptySearch: const Text('custom-search-empty'),
        ),
      );
      await search(tester, 'Bet');
      expect(leftText('Alpha'), findsNothing);
      expect(leftText('Beta'), findsOneWidget);
      expect(leftText('Gamma'), findsNothing);
      await search(tester, 'zzz');
      expect(find.text('custom-search-empty'), findsOneWidget);
    });

    testWidgets('onSearch 随输入触发', (tester) async {
      final inputs = <String>[];
      await pumpHost(
        tester,
        transfer(dataSource: items(), onSearch: inputs.add),
      );
      await search(tester, 'Alp');
      await search(tester, '');
      expect(inputs, ['Alp', '']);
    });

    testWidgets('filterFn 自定义谓词', (tester) async {
      await pumpHost(
        tester,
        transfer(
          dataSource: items(),
          // 覆盖默认 contains：改用前缀匹配（'lp' 不命中 'Alpha'）。
          filterFn: (input, item) =>
              item.label is String && (item.label! as String).startsWith(input),
        ),
      );
      await search(tester, 'lp');
      expect(leftText('Alpha'), findsNothing);
      await search(tester, 'Alp');
      expect(leftText('Alpha'), findsOneWidget);
    });

    testWidgets('filter: false 隐藏搜索框', (tester) async {
      await pumpHost(tester, transfer(dataSource: items(), filter: false));
      expect(find.byKey(SemiTransfer.searchKey), findsNothing);
    });

    testWidgets('controller.search 设置过滤但不触发 onSearch（脱离后 no-op）', (
      tester,
    ) async {
      final inputs = <String>[];
      final controller = SemiTransferController();
      await pumpHost(
        tester,
        transfer(
          dataSource: items(),
          onSearch: inputs.add,
          controller: controller,
        ),
      );
      controller.search('Alp');
      await tester.pumpAndSettle();
      expect(inputs, isEmpty);
      expect(leftText('Alpha'), findsOneWidget);
      expect(leftText('Beta'), findsNothing);
      // 输入框文本同步。
      final text = tester
          .widget<EditableText>(
            find.descendant(
              of: find.byKey(SemiTransfer.searchKey),
              matching: find.byType(EditableText),
            ),
          )
          .controller
          .text;
      expect(text, 'Alp');
      // detach 后 no-op（semi_date_picker.dart:84-117 先例）。
      await pumpHost(tester, transfer(dataSource: items()));
      controller.search('Bet');
      await tester.pumpAndSettle();
      expect(inputs, isEmpty);
    });

    testWidgets('数据变化时搜索结果重算（gDSFP :310-319 quirk）', (tester) async {
      late StateSetter setter;
      var data = items();
      await pumpHost(
        tester,
        StatefulBuilder(
          builder: (context, setState) {
            setter = setState;
            return transfer(dataSource: data);
          },
        ),
      );
      await search(tester, 'Alp');
      expect(leftText('Alpha'), findsOneWidget);
      expect(leftText('Alpine'), findsNothing);
      setter(() {
        data = [
          ...items(),
          const SemiTransferItem(key: 'd', value: 'D', label: 'Alpine'),
        ];
      });
      await tester.pumpAndSettle();
      // 搜索词非空 + 数据变化 → 重算命中集。
      expect(leftText('Alpha'), findsOneWidget);
      expect(leftText('Alpine'), findsOneWidget);
      expect(leftText('Beta'), findsNothing);
    });
  });

  group('groupList', () {
    testWidgets('分组标题渲染', (tester) async {
      await pumpHost(
        tester,
        transfer(
          type: SemiTransferType.groupList,
          dataSource: const [
            SemiTransferGroup(
              title: '组一',
              children: [
                SemiTransferItem(key: 'a', value: 'A', label: 'Alpha'),
                SemiTransferItem(key: 'b', value: 'B', label: 'Beta'),
              ],
            ),
            SemiTransferGroup(
              title: '组二',
              children: [
                SemiTransferItem(key: 'c', value: 'C', label: 'Gamma'),
              ],
            ),
          ],
        ),
      );
      expect(leftText('组一'), findsOneWidget);
      expect(leftText('组二'), findsOneWidget);
      // 分组条目照常勾选穿梭。
      await tapLabel(tester, 'Alpha');
      expect(rightLabels(tester), ['Alpha']);
    });
  });

  group('treeList', () {
    const tree = [
      SemiTransferItem(
        key: 'root',
        label: 'Root',
        children: [
          SemiTransferItem(key: 'leaf', value: 'leaf', label: 'Leaf'),
          SemiTransferItem(
            key: 'disabled',
            value: 'disabled',
            label: 'Disabled',
            disabled: true,
          ),
        ],
      ),
    ];

    testWidgets('renders nested nodes and transfers leaf selection', (
      tester,
    ) async {
      final changes = <List<Object?>>[];
      await pumpHost(
        tester,
        transfer(
          type: SemiTransferType.treeList,
          dataSource: tree,
          onChanged: (values, _) => changes.add(values),
        ),
      );
      expect(leftText('Root'), findsOneWidget);
      expect(leftText('Leaf'), findsOneWidget);
      await tester.tap(leftText('Leaf'));
      await tester.pumpAndSettle();
      expect(rightText('Leaf'), findsOneWidget);
      expect(changes.last, ['leaf']);
    });

    testWidgets('showPath and fullPath do not mutate source nodes', (
      tester,
    ) async {
      SemiTransferItem? rendered;
      await pumpHost(
        tester,
        transfer(
          type: SemiTransferType.treeList,
          dataSource: tree,
          defaultValue: ['leaf'],
          showPath: true,
          renderSelectedItem: (context, item, onRemove) {
            rendered = item;
            return Text(item.label?.toString() ?? '');
          },
        ),
      );
      expect(find.text('Root > Leaf'), findsOneWidget);
      expect(rendered?.fullPath?.map((item) => item.label), ['Root', 'Leaf']);
      expect(tree.single.children!.length, 2);
      expect(
        tree.single.children!
            .where((item) => item.key == 'leaf')
            .single
            .fullPath,
        isNull,
      );
    });

    testWidgets('tree controller search delegates to the tree', (tester) async {
      final controller = SemiTransferController();
      await pumpHost(
        tester,
        transfer(
          type: SemiTransferType.treeList,
          dataSource: tree,
          controller: controller,
        ),
      );
      controller.search('Leaf');
      await tester.pumpAndSettle();
      expect(leftText('Leaf'), findsOneWidget);
      expect(leftText('Disabled'), findsNothing);
    });

    testWidgets('tree lazy loading shows spin and calls onLoad', (
      tester,
    ) async {
      final completer = Completer<void>();
      var loads = 0;
      final loaded = <Object>{};
      await pumpHost(
        tester,
        transfer(
          type: SemiTransferType.treeList,
          dataSource: const [
            SemiTransferItem(key: 'lazy', label: 'Lazy', isLeaf: false),
          ],
          treeProps: SemiTransferTreeProps(
            loadData: (_) async {
              loads++;
              await completer.future;
            },
            onLoad: (keys, _) => loaded.addAll(keys),
          ),
        ),
      );
      await tester.tap(find.byKey(const ValueKey('tree-expand-String:lazy')));
      await tester.pump();
      expect(find.byType(SemiSpin), findsOneWidget);
      completer.complete();
      await tester.pumpAndSettle();
      expect(loads, 1);
      expect(loaded, {'lazy'});
    });
  });

  group('禁用', () {
    testWidgets('整机 disabled：不可勾、按钮失活、not-allowed 光标', (tester) async {
      await pumpHost(
        tester,
        transfer(dataSource: items(), defaultValue: ['A'], disabled: true),
      );
      for (final checkbox in tester.widgetList<SemiCheckbox>(
        find.byType(SemiCheckbox),
      )) {
        expect(checkbox.disabled, isTrue);
      }
      expect(
        tester
            .widget<SemiButton>(find.byKey(SemiTransfer.selectAllKey))
            .onPressed,
        isNull,
      );
      expect(
        tester
            .widgetList<MouseRegion>(find.byType(MouseRegion))
            .any((r) => r.cursor == SystemMouseCursors.forbidden),
        isTrue,
      );
      // 点击不落状态。
      await tapLabel(tester, 'Beta');
      expect(rightLabels(tester), ['Alpha']);
    });

    testWidgets('item.disabled：不可勾且 close 永隐（hover 也隐）', (tester) async {
      await pumpHost(
        tester,
        transfer(
          dataSource: const [
            SemiTransferItem(key: 'a', value: 'A', label: 'Alpha'),
            SemiTransferItem(
              key: 'b',
              value: 'B',
              label: 'Beta',
              disabled: true,
            ),
          ],
          defaultValue: ['A', 'B'],
        ),
      );
      final disabledBox = tester.widget<SemiCheckbox>(
        find
            .descendant(of: leftRow('b'), matching: find.byType(SemiCheckbox))
            .first,
      );
      expect(disabledBox.disabled, isTrue);
      await tapLabel(tester, 'Beta');
      expect(rightLabels(tester), ['Alpha', 'Beta']);
      // disabled 行 hover 后 close 仍隐（transfer.scss:170-171）。
      await hover(tester, rightRow('b'));
      final close = tester.widget<Visibility>(
        find.descendant(of: rightRow('b'), matching: find.byType(Visibility)),
      );
      expect(close.visible, isFalse);
    });
  });

  group('受控', () {
    testWidgets('pagination currentPage is controlled by props', (
      tester,
    ) async {
      late StateSetter setter;
      var currentPage = 1;
      final pages = <int>[];
      await pumpHost(
        tester,
        StatefulBuilder(
          builder: (context, setState) {
            setter = setState;
            return transfer(
              dataSource: pagedItems(),
              pagination: SemiTransferPaginationProps(
                currentPage: currentPage,
                onPageChange: pages.add,
              ),
            );
          },
        ),
      );
      await tapButton(tester, SemiPagination.nextKey);
      expect(pages, [2]);
      expect(leftRow('item-1'), findsOneWidget);
      setter(() => currentPage = 2);
      await tester.pumpAndSettle();
      expect(leftRow('item-1'), findsNothing);
      expect(leftRow('item-11'), findsOneWidget);
    });

    testWidgets('value 变化渲染跟随、点击只发事件不落状态', (tester) async {
      final changes = <List<Object?>>[];
      late StateSetter setter;
      var value = <Object?>['A'];
      await pumpHost(
        tester,
        StatefulBuilder(
          builder: (context, setState) {
            setter = setState;
            return transfer(
              dataSource: items(),
              value: value,
              onChanged: (values, _) => changes.add(values),
            );
          },
        ),
      );
      expect(rightLabels(tester), ['Alpha']);
      await tapLabel(tester, 'Beta');
      // 只发事件（意图选中集 ['A','B']），不落状态。
      expect(changes.last, ['A', 'B']);
      expect(rightLabels(tester), ['Alpha']);
      setter(() => value = ['A', 'B']);
      await tester.pumpAndSettle();
      expect(rightLabels(tester), ['Alpha', 'Beta']);
    });

    testWidgets('defaultValue 仅初值（dataSource 引用 churn 不重置）', (tester) async {
      late StateSetter setter;
      await pumpHost(
        tester,
        StatefulBuilder(
          builder: (context, setState) {
            setter = setState;
            // 每次重建都是新 List/新 SemiTransferItem 实例（字面量 churn）。
            final data = [
              const SemiTransferItem(key: 'a', value: 'A', label: 'Alpha'),
              const SemiTransferItem(key: 'b', value: 'B', label: 'Beta'),
            ];
            return transfer(dataSource: data, defaultValue: const ['A']);
          },
        ),
      );
      expect(rightLabels(tester), ['Alpha']);
      await tapLabel(tester, 'Beta');
      expect(rightLabels(tester), ['Alpha', 'Beta']);
      setter(() {});
      await tester.pumpAndSettle();
      // 引用变化不重置已选值（defaultValue 仅初值语义）。
      expect(rightLabels(tester), ['Alpha', 'Beta']);
    });

    testWidgets('释放控制保留最后值', (tester) async {
      late StateSetter setter;
      List<Object?>? value = ['A'];
      await pumpHost(
        tester,
        StatefulBuilder(
          builder: (context, setState) {
            setter = setState;
            return transfer(dataSource: items(), value: value);
          },
        ),
      );
      expect(rightLabels(tester), ['Alpha']);
      setter(() => value = ['A', 'B']);
      await tester.pumpAndSettle();
      expect(rightLabels(tester), ['Alpha', 'Beta']);
      // value → null：释放控制，保留最后选中值。
      setter(() => value = null);
      await tester.pumpAndSettle();
      expect(rightLabels(tester), ['Alpha', 'Beta']);
    });
  });

  group('emptyContent', () {
    testWidgets('缺省 zh 文案三槽', (tester) async {
      await pumpHost(tester, transfer(dataSource: const []));
      expect(find.text('暂无数据'), findsOneWidget);
      expect(find.text('暂无内容，可从左侧勾选'), findsOneWidget);
      await pumpHost(
        tester,
        transfer(dataSource: items(), defaultValue: ['A']),
      );
      await search(tester, 'zzz');
      expect(find.text('无搜索结果'), findsOneWidget);
    });

    testWidgets('自定义 emptyLeft/emptyRight/emptySearch', (tester) async {
      await pumpHost(
        tester,
        transfer(
          dataSource: const [],
          emptyLeft: const Text('custom-left'),
          emptyRight: const Text('custom-right'),
        ),
      );
      expect(find.text('custom-left'), findsOneWidget);
      expect(find.text('custom-right'), findsOneWidget);
      await pumpHost(
        tester,
        transfer(dataSource: items(), emptySearch: const Text('custom-search')),
      );
      await search(tester, 'zzz');
      expect(find.text('custom-search'), findsOneWidget);
    });
  });

  group('render 槽', () {
    testWidgets('renderSourceItem 替换左栏行', (tester) async {
      await pumpHost(
        tester,
        transfer(
          dataSource: items(),
          renderSourceItem: (context, item, checked, onToggle) =>
              Text('src-${item.key}'),
        ),
      );
      expect(find.text('src-a'), findsOneWidget);
      expect(find.text('Alpha'), findsNothing);
    });

    testWidgets('renderSelectedItem 替换右栏行', (tester) async {
      await pumpHost(
        tester,
        transfer(
          dataSource: items(),
          defaultValue: ['A'],
          renderSelectedItem: (context, item, onRemove) =>
              Text('sel-${item.key}'),
        ),
      );
      expect(find.text('sel-a'), findsOneWidget);
    });

    testWidgets('renderSourceHeader / renderSelectedHeader 替换 header', (
      tester,
    ) async {
      await pumpHost(
        tester,
        transfer(
          dataSource: items(),
          defaultValue: ['A'],
          renderSourceHeader: (context, props) => Text('src-head-${props.num}'),
          renderSelectedHeader: (context, props) =>
              Text('sel-head-${props.num}'),
        ),
      );
      expect(find.text('src-head-3'), findsOneWidget);
      expect(find.text('sel-head-1'), findsOneWidget);
      expect(find.textContaining('总个数'), findsNothing);
    });

    testWidgets('renderSourcePanel / renderSelectedPanel 替换面板', (tester) async {
      await pumpHost(
        tester,
        transfer(
          dataSource: items(),
          defaultValue: ['A'],
          renderSourcePanel: (context, props) =>
              Text('src-panel-${props.showNumber}'),
          renderSelectedPanel: (context, props) =>
              Text('sel-panel-${props.length}'),
        ),
      );
      expect(find.text('src-panel-3'), findsOneWidget);
      expect(find.text('sel-panel-1'), findsOneWidget);
    });
  });

  group('loading', () {
    testWidgets('loading 时 Spin 覆盖左栏（header/列表替换）', (tester) async {
      await pumpHost(tester, transfer(dataSource: items(), loading: true));
      expect(
        find.descendant(
          of: find.byKey(SemiTransfer.leftPanelKey),
          matching: find.byType(SemiSpin),
        ),
        findsOneWidget,
      );
      expect(find.textContaining('总个数'), findsNothing);
    });
  });

  group('RTL', () {
    testWidgets('中缝翻边（LTR 右边框 / RTL 左边框）', (tester) async {
      await pumpHost(tester, transfer(dataSource: items()));
      final ltr = tester.widget<Container>(
        find
            .descendant(
              of: find.byKey(SemiTransfer.leftPanelKey),
              matching: find.byType(Container),
            )
            .first,
      );
      final ltrBorder = (ltr.decoration! as BoxDecoration).border! as Border;
      expect(ltrBorder.right.width, 1.0);
      expect(ltrBorder.left, BorderSide.none);
      await pumpHost(
        tester,
        transfer(dataSource: items()),
        direction: TextDirection.rtl,
      );
      final rtl = tester.widget<Container>(
        find
            .descendant(
              of: find.byKey(SemiTransfer.leftPanelKey),
              matching: find.byType(Container),
            )
            .first,
      );
      final rtlBorder = (rtl.decoration! as BoxDecoration).border! as Border;
      expect(rtlBorder.left.width, 1.0);
      expect(rtlBorder.right, BorderSide.none);
    });

    testWidgets('RTL 勾选穿梭照常（Row 镜像 + EdgeInsetsDirectional）', (tester) async {
      await pumpHost(
        tester,
        transfer(dataSource: items()),
        direction: TextDirection.rtl,
      );
      await tapLabel(tester, 'Alpha');
      expect(rightLabels(tester), ['Alpha']);
    });
  });

  group('geometry', () {
    testWidgets('根 402×400 默认、左右 50%', (tester) async {
      await pumpHost(tester, transfer(dataSource: items()), width: 402);
      expect(
        tester.getSize(find.byKey(SemiTransfer.rootKey)),
        const Size(402, 400),
      );
      expect(
        tester.getSize(find.byKey(SemiTransfer.leftPanelKey)).width,
        moreOrLessEquals(201, epsilon: 0.001),
      );
      expect(
        tester.getSize(find.byKey(SemiTransfer.rightPanelKey)).width,
        moreOrLessEquals(201, epsilon: 0.001),
      );
    });

    testWidgets('宽容器下高度恒 400、宽度随容器', (tester) async {
      await pumpHost(tester, transfer(dataSource: items()), width: 500);
      expect(
        tester.getSize(find.byKey(SemiTransfer.rootKey)),
        const Size(500, 400),
      );
    });
  });
}
