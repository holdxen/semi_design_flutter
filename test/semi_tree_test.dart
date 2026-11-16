// Behavior matrix for SemiTree plus coverage for the 33 Sass declarations
// (29 FIELDS + 4 MOTION + 0 INTERNAL) — the 18 HARDCODES provenance anchors
// live in the widget's `_TreeMetrics` / call sites. ★0 死变量；draggable 未移植
// → 5 条拖拽专用字段 widget 侧不消费（assertNotIn，docs 已标注）。
import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/gestures.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:semi_design_flutter/semi_design_flutter.dart';

final _hostBody = ValueNotifier<Widget>(const SizedBox.shrink());

Widget host(Widget child, {TextDirection direction = TextDirection.ltr}) {
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
                  child: SizedBox(width: 400, height: 600, child: child),
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
}) async {
  await tester.binding.setSurfaceSize(const Size(1200, 1200));
  await tester.pumpWidget(host(child, direction: direction));
}

Future<TestGesture> startMouse(WidgetTester tester) async {
  final gesture = await tester.createGesture(kind: ui.PointerDeviceKind.mouse);
  await gesture.addPointer(location: Offset.zero);
  addTearDown(gesture.removePointer);
  return gesture;
}

/// 2-level fixture: A [B, C(disabled)] + D(leaf).
const data = <SemiTreeNodeData>[
  SemiTreeNodeData(
    key: 'a',
    label: 'A',
    children: [
      SemiTreeNodeData(key: 'b', label: 'B'),
      SemiTreeNodeData(key: 'c', label: 'C', disabled: true),
    ],
  ),
  SemiTreeNodeData(key: 'd', label: 'D', isLeaf: true),
];

Finder expandArrow(String key) => find.byKey(ValueKey('tree-expand-$key'));

/// 行底色（block 模式）——最外层 AnimatedContainer；标题文字区底色（非 block）
/// 是最近层 AnimatedContainer（labelBg）。
Color? rowBg(WidgetTester tester, String label) {
  final boxes = find
      .ancestor(of: find.text(label), matching: find.byType(AnimatedContainer))
      .evaluate()
      .toList();
  final decoration =
      (boxes.last.widget as AnimatedContainer).decoration as BoxDecoration?;
  return decoration?.color;
}

Color? labelBg(WidgetTester tester, String label) {
  final box = find
      .ancestor(of: find.text(label), matching: find.byType(AnimatedContainer))
      .first;
  final decoration =
      tester.widget<AnimatedContainer>(box).decoration as BoxDecoration?;
  return decoration?.color;
}

// -- theme field table -------------------------------------------------------

typedef _Patch = SemiTreeThemeData Function(Object value);
typedef _Read = Object? Function(SemiResolvedTreeThemeData data);
typedef _Default = Object? Function(SemiThemeData theme);

const _c = Color(0xFF010203);

final List<(String, Object, _Patch, _Read, _Default)> fields = [
  (
    r'$color-tree_option-text-default: var(--semi-color-text-0)',
    _c,
    (v) => SemiTreeThemeData(colorTreeOptionTextDefault: v as Color),
    (d) => d.colorTreeOptionTextDefault,
    (t) => t.colors.colorText0,
  ),
  (
    r'$color-tree_option-icon-default: var(--semi-color-text-2)',
    _c,
    (v) => SemiTreeThemeData(colorTreeOptionIconDefault: v as Color),
    (d) => d.colorTreeOptionIconDefault,
    (t) => t.colors.colorText2,
  ),
  (
    r'$color-tree_option-bg-hover: var(--semi-color-fill-0)',
    _c,
    (v) => SemiTreeThemeData(colorTreeOptionBgHover: v as Color),
    (d) => d.colorTreeOptionBgHover,
    (t) => t.colors.colorFill0,
  ),
  (
    r'$color-tree_option_selected-bg-default: var(--semi-color-fill-1)',
    _c,
    (v) => SemiTreeThemeData(colorTreeOptionSelectedBgDefault: v as Color),
    (d) => d.colorTreeOptionSelectedBgDefault,
    (t) => t.colors.colorFill1,
  ),
  (
    r'$color-tree_option-bg-active: var(--semi-color-primary-light-default)',
    _c,
    (v) => SemiTreeThemeData(colorTreeOptionBgActive: v as Color),
    (d) => d.colorTreeOptionBgActive,
    (t) => t.colors.colorPrimaryLightDefault,
  ),
  (
    r'$color-tree_option_disabled-text-default: var(--semi-color-disabled-text)',
    _c,
    (v) => SemiTreeThemeData(colorTreeOptionDisabledTextDefault: v as Color),
    (d) => d.colorTreeOptionDisabledTextDefault,
    (t) => t.colors.colorDisabledText,
  ),
  (
    r'$color-tree_option-icon-hover: var(--semi-color-text-0)',
    _c,
    (v) => SemiTreeThemeData(colorTreeOptionIconHover: v as Color),
    (d) => d.colorTreeOptionIconHover,
    (t) => t.colors.colorText0,
  ),
  (
    r'$color-tree_option-icon-active: var(--semi-color-black)',
    _c,
    (v) => SemiTreeThemeData(colorTreeOptionIconActive: v as Color),
    (d) => d.colorTreeOptionIconActive,
    (t) => t.colors.colorBlack,
  ),
  (
    r'$color-tree_option_loading-icon-default: var(--semi-color-primary)',
    _c,
    (v) => SemiTreeThemeData(colorTreeOptionLoadingIconDefault: v as Color),
    (d) => d.colorTreeOptionLoadingIconDefault,
    (t) => t.colors.colorPrimary,
  ),
  (
    r'$color-tree_option_draggable_insert-border-default: var(--semi-color-primary)',
    _c,
    (v) => SemiTreeThemeData(
      colorTreeOptionDraggableInsertBorderDefault: v as Color,
    ),
    (d) => d.colorTreeOptionDraggableInsertBorderDefault,
    (t) => t.colors.colorPrimary,
  ),
  (
    r'$font-tree_option_hightlight-fontWeight: $font-weight-bold',
    FontWeight.w300,
    (v) =>
        SemiTreeThemeData(fontTreeOptionHightlightFontWeight: v as FontWeight),
    (d) => d.fontTreeOptionHightlightFontWeight,
    (t) => t.typography.fontWeightBold,
  ),
  (
    r'$color-tree_option_hightlight-text: var(--semi-color-primary)',
    _c,
    (v) => SemiTreeThemeData(colorTreeOptionHightlightText: v as Color),
    (d) => d.colorTreeOptionHightlightText,
    (t) => t.colors.colorPrimary,
  ),
  (
    r'$radius-tree_checkbox_addon: var(--semi-border-radius-small)',
    101.0,
    (v) => SemiTreeThemeData(radiusTreeCheckboxAddon: v as double),
    (d) => d.radiusTreeCheckboxAddon,
    (t) => 3.0,
  ),
  (
    r'$spacing-tree_search_wrapper-paddingX: 12px',
    101.0,
    (v) => SemiTreeThemeData(spacingTreeSearchWrapperPaddingX: v as double),
    (d) => d.spacingTreeSearchWrapperPaddingX,
    (t) => 12.0,
  ),
  (
    r'$spacing-tree_search_wrapper-paddingY: 8px',
    101.0,
    (v) => SemiTreeThemeData(spacingTreeSearchWrapperPaddingY: v as double),
    (d) => d.spacingTreeSearchWrapperPaddingY,
    (t) => 8.0,
  ),
  (
    r'$spacing-tree_option_level-paddingLeft: 20px',
    101.0,
    (v) => SemiTreeThemeData(spacingTreeOptionLevelPaddingLeft: v as double),
    (d) => d.spacingTreeOptionLevelPaddingLeft,
    (t) => 20.0,
  ),
  (
    r'$spacing-tree_option_level1-paddingLeft: 8px',
    101.0,
    (v) => SemiTreeThemeData(spacingTreeOptionLevel1PaddingLeft: v as double),
    (d) => d.spacingTreeOptionLevel1PaddingLeft,
    (t) => 8.0,
  ),
  (
    r'$spacing-tree_optionList-paddingX: 0',
    101.0,
    (v) => SemiTreeThemeData(spacingTreeOptionListPaddingX: v as double),
    (d) => d.spacingTreeOptionListPaddingX,
    (t) => 0.0,
  ),
  (
    r'$spacing-tree_optionList-paddingY: 8px',
    101.0,
    (v) => SemiTreeThemeData(spacingTreeOptionListPaddingY: v as double),
    (d) => d.spacingTreeOptionListPaddingY,
    (t) => 8.0,
  ),
  (
    r'$spacing-tree_option-paddingTop: 4px',
    101.0,
    (v) => SemiTreeThemeData(spacingTreeOptionPaddingTop: v as double),
    (d) => d.spacingTreeOptionPaddingTop,
    (t) => 4.0,
  ),
  (
    r'$spacing-tree_option-paddingBottom: 4px',
    101.0,
    (v) => SemiTreeThemeData(spacingTreeOptionPaddingBottom: v as double),
    (d) => d.spacingTreeOptionPaddingBottom,
    (t) => 4.0,
  ),
  (
    r'$spacing-tree_icon-marginRight: 8px',
    101.0,
    (v) => SemiTreeThemeData(spacingTreeIconMarginRight: v as double),
    (d) => d.spacingTreeIconMarginRight,
    (t) => 8.0,
  ),
  (
    r'$spacing-tree_label_withIcon-marginRight: 8px',
    101.0,
    (v) => SemiTreeThemeData(spacingTreeLabelWithIconMarginRight: v as double),
    (d) => d.spacingTreeLabelWithIconMarginRight,
    (t) => 8.0,
  ),
  (
    r'$spacing-tree_option_draggable-paddingY: 2px',
    101.0,
    (v) => SemiTreeThemeData(spacingTreeOptionDraggablePaddingY: v as double),
    (d) => d.spacingTreeOptionDraggablePaddingY,
    (t) => 2.0,
  ),
  (
    r'$spacing-tree_option_draggable-paddingX: 0',
    101.0,
    (v) => SemiTreeThemeData(spacingTreeOptionDraggablePaddingX: v as double),
    (d) => d.spacingTreeOptionDraggablePaddingX,
    (t) => 0.0,
  ),
  (
    r'$width-tree_emptyIcon: $width-icon-small',
    101.0,
    (v) => SemiTreeThemeData(widthTreeEmptyIcon: v as double),
    (d) => d.widthTreeEmptyIcon,
    (t) => 12.0,
  ),
  (
    r'$width-tree_spinIcon: $width-icon-small',
    101.0,
    (v) => SemiTreeThemeData(widthTreeSpinIcon: v as double),
    (d) => d.widthTreeSpinIcon,
    (t) => 12.0,
  ),
  (
    r'$width-tree_option_draggable-border: 2px',
    101.0,
    (v) => SemiTreeThemeData(widthTreeOptionDraggableBorder: v as double),
    (d) => d.widthTreeOptionDraggableBorder,
    (t) => 2.0,
  ),
  (
    r'$width-tree_option_line: 1px',
    101.0,
    (v) => SemiTreeThemeData(widthTreeOptionLine: v as double),
    (d) => d.widthTreeOptionLine,
    (t) => 1.0,
  ),
  (
    r'$transition_duration-tree_option-bg: var(--semi-transition_duration-none)',
    const Duration(milliseconds: 1),
    (v) => SemiTreeThemeData(transitionDurationTreeOptionBg: v as Duration),
    (d) => d.transitionDurationTreeOptionBg,
    (t) => Duration.zero,
  ),
  (
    r'$transition_function-tree_option-bg: var(--semi-transition_function-easeIn)',
    Curves.easeOut,
    (v) => SemiTreeThemeData(transitionFunctionTreeOptionBg: v as Curve),
    (d) => d.transitionFunctionTreeOptionBg,
    (t) => Curves.easeIn,
  ),
  (
    r'$transition_delay-tree_option-bg: var(--semi-transition_delay-none)',
    const Duration(milliseconds: 2),
    (v) => SemiTreeThemeData(transitionDelayTreeOptionBg: v as Duration),
    (d) => d.transitionDelayTreeOptionBg,
    (t) => Duration.zero,
  ),
  (
    r'$transform_scale-tree-option: var(--semi-transform_scale-none)',
    const SemiTransform.scale(2, 3),
    (v) => SemiTreeThemeData(transformScaleTreeOption: v as SemiTransform),
    (d) => d.transformScaleTreeOption,
    (t) => const SemiTransform.scale(1, 1),
  ),
];

void main() {
  group('theme fields (33 = 29 FIELDS + 4 MOTION + 0 INTERNAL)', () {
    test('33 fields: merge, copyWith, resolve, equality, defaults', () {
      expect(fields, hasLength(33));
      for (final (sass, value, make, read, expected) in fields) {
        final patch = make(value);
        expect(const SemiTreeThemeData().merge(patch), patch, reason: sass);
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
          read(const SemiTreeThemeData().resolve(light)),
          expected(light),
          reason: sass,
        );
        final dark = const SemiThemeData.dark();
        expect(
          read(const SemiTreeThemeData().resolve(dark)),
          expected(dark),
          reason: sass,
        );
      }
    });

    test('every field carries its Sass provenance in the generated source', () {
      final source = File('lib/src/theme/semi_tree_theme_data.dart')
          .readAsStringSync();
      final names = <String>{};
      for (final (sass, _, _, _, _) in fields) {
        expect(source, contains(sass));
        names.add(sass.split(': ').first.substring(1));
      }
      expect(names, hasLength(33));
      // ★`hightlight` 错拼照抄。
      expect(source, contains('hightlight'));
      expect(source, contains('packages/semi-foundation/tree/variables.scss'));
      expect(source, contains('packages/semi-foundation/tree/animation.scss'));
      expect(source, contains('Generated by tool/generate_tree.py'));
    });

    test('the 18 HARDCODES anchors live in the widget source', () {
      final widgetSource = File('lib/src/components/semi_tree.dart')
          .readAsStringSync();
      const anchors = <String>[
        "EXPAND_ACTION: [false, 'click', 'doubleClick']",
        'JSON_KEY_SPLIT:',
        "'暂无数据'",
        "'搜索'",
        "aria-label='Filter Tree'",
        'aria-multiselectable',
        'role="treeitem"',
        'duration={200}',
        'DRAG_OFFSET = 0.45',
        'transform: rotate(270deg)',
        'transform: scale(scale(1,1))',
        'debounce(this.onSelect, 500',
        'isEnterPress',
        'IconSearch',
        'auto-wrapper',
        r'calc(($spacing-tree_option_level-paddingLeft / 2) * 0.8)',
        'var(--semi-color-text-3)',
        'user-select: none',
      ];
      expect(anchors, hasLength(18));
      for (final anchor in anchors) {
        expect(widgetSource, contains(anchor), reason: anchor);
      }
    });

    test('type coverage: 11 Color + 17 double + 1 FontWeight + 2 Duration + '
        '1 Curve + 1 SemiTransform = 33', () {
      final counts = <String, int>{};
      for (final (_, value, _, _, _) in fields) {
        final type = switch (value) {
          Curve() => 'Curve',
          SemiTransform() => 'SemiTransform',
          _ => value.runtimeType.toString(),
        };
        counts.update(type, (n) => n + 1, ifAbsent: () => 1);
      }
      expect(counts['Color'], 11);
      expect(counts['double'], 17);
      expect(counts['FontWeight'], 1);
      expect(counts['Duration'], 2);
      expect(counts['Curve'], 1);
      expect(counts['SemiTransform'], 1);
    });

    test('0 dead variables; the 5 draggable-only fields stay unconsumed', () {
      const draggableFields = [
        'colorTreeOptionDraggableInsertBorderDefault',
        'spacingTreeOptionDraggablePaddingY',
        'spacingTreeOptionDraggablePaddingX',
        'widthTreeOptionDraggableBorder',
      ];
      final widgetSource = File('lib/src/components/semi_tree.dart')
          .readAsStringSync();
      expect(widgetSource, isNot(contains('# dead variable')));
      for (final name in draggableFields) {
        expect(widgetSource, isNot(contains(name)), reason: name);
      }
      final docs = File('docs/semi_tree.md').readAsStringSync();
      expect(docs, contains('33 = 29 FIELDS + 4 MOTION + 0 INTERNAL'));
      expect(docs, contains('0 死变量'));
      expect(docs, contains('draggable 未移植'));
    });

    test('SemiComponentThemes wiring', () {
      const themes = SemiComponentThemes();
      expect(themes.tree, const SemiTreeThemeData());
      expect(
        themes.copyWith(tree: const SemiTreeThemeData(widthTreeEmptyIcon: 14)),
        const SemiComponentThemes(
          tree: SemiTreeThemeData(widthTreeEmptyIcon: 14),
        ),
      );
    });
  });

  group('behavior', () {
    testWidgets('expands/collapses with motion, selects and logs changes', (
      tester,
    ) async {
      final changes = <Object?>[];
      final selects = <String>[];
      final expands = <String>[];
      await pumpHost(
        tester,
        SemiTree(
          treeData: data,
          onChange: changes.add,
          onSelect: (key, selected, node) => selects.add('$key/$selected'),
          onExpand: (keys, expanded, node) =>
              expands.add('${node.key}/$expanded'),
        ),
      );
      await tester.pump();
      expect(find.text('B'), findsNothing);
      // 展开：运动块在场，200ms 后稳定。
      await tester.tap(expandArrow('a'));
      await tester.pump();
      expect(find.byType(SizeTransition), findsOneWidget);
      await tester.pump(const Duration(milliseconds: 300));
      await tester.pumpAndSettle();
      expect(find.text('B'), findsOneWidget);
      expect(expands, ['a/true']);
      // 选择 B。
      await tester.tap(find.text('B'));
      await tester.pump();
      expect(selects, ['b/true']);
      expect(changes, ['b']);
      // 收起：被移除行播完离场。
      await tester.tap(expandArrow('a'));
      await tester.pump();
      expect(find.byType(SizeTransition), findsOneWidget);
      await tester.pump(const Duration(milliseconds: 300));
      await tester.pumpAndSettle();
      expect(find.text('B'), findsNothing);
      expect(expands, ['a/true', 'a/false']);
      expect(tester.takeException(), isNull);
    });

    testWidgets('disabled node cannot select but still expands; tree-level '
        'disabled keeps expansion', (tester) async {
      final changes = <Object?>[];
      await pumpHost(
        tester,
        SemiTree(
          treeData: data,
          defaultExpandedKeys: const ['a'],
          onChange: changes.add,
        ),
      );
      await tester.pump();
      await tester.tap(find.text('C'));
      await tester.pump();
      expect(changes, isEmpty);
      await pumpHost(tester, const SemiTree(treeData: data, disabled: true));
      await tester.pump();
      await tester.tap(expandArrow('a'));
      await tester.pump(const Duration(milliseconds: 300));
      expect(find.text('B'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('controlled expandedKeys only notifies', (tester) async {
      final expands = <String>[];
      await pumpHost(
        tester,
        SemiTree(
          treeData: data,
          expandedKeys: const ['a'],
          onExpand: (keys, expanded, node) =>
              expands.add('${node.key}/$expanded'),
        ),
      );
      await tester.pump();
      expect(find.text('B'), findsOneWidget);
      await tester.tap(expandArrow('a'));
      await tester.pump();
      // 内部不跟 props 变；B 仍在。
      expect(find.text('B'), findsOneWidget);
      expect(expands, ['a/false']);
      expect(tester.takeException(), isNull);
    });

    testWidgets('controlled value keeps the rendered selection', (
      tester,
    ) async {
      final changes = <Object?>[];
      final resolved = const SemiTreeThemeData().resolve(
        const SemiThemeData.light(),
      );
      await pumpHost(
        tester,
        SemiTree(
          treeData: data,
          value: 'a',
          labelEllipsis: true,
          onChange: changes.add,
        ),
      );
      await tester.pump();
      // 受控初值选中 A（关闭状态行也算选中底色）。
      expect(rowBg(tester, 'A'), resolved.colorTreeOptionBgActive);
      await tester.tap(find.text('D'));
      await tester.pump();
      expect(changes, ['d']);
      expect(rowBg(tester, 'A'), resolved.colorTreeOptionBgActive);
      expect(rowBg(tester, 'D'), isNot(resolved.colorTreeOptionBgActive));
      expect(tester.takeException(), isNull);
    });

    testWidgets('multiple related cascade paints checked/half states', (
      tester,
    ) async {
      final changes = <Object?>[];
      await pumpHost(
        tester,
        SemiTree(
          treeData: data,
          defaultExpandedKeys: const ['a'],
          multiple: true,
          onChange: changes.add,
        ),
      );
      await tester.pump();
      // 勾 B：B 全选，A 半选。
      await tester.tap(find.text('B'));
      await tester.pump();
      expect(changes.last, ['b']);
      var boxes = tester
          .widgetList<SemiCheckbox>(find.byType(SemiCheckbox))
          .toList();
      // 行序：A B C D。
      expect(boxes[1].checked, isTrue);
      expect(boxes[0].indeterminate, isTrue);
      // 勾 A：级联后代全选（含 disabled C——非严格禁用口径）；D 不在其子树。
      await tester.tap(find.text('A'));
      await tester.pump();
      boxes = tester
          .widgetList<SemiCheckbox>(find.byType(SemiCheckbox))
          .toList();
      expect(boxes.map((b) => b.checked), [true, true, true, false]);
      // autoMergeValue 去祖先 → 载荷只留 A（b/c 的父键已选）。
      expect(changes.last, ['a']);
      // 取消 A：全部取消。
      await tester.tap(find.text('A'));
      await tester.pump();
      boxes = tester
          .widgetList<SemiCheckbox>(find.byType(SemiCheckbox))
          .toList();
      expect(boxes.map((b) => b.checked), everyElement(isFalse));
      expect(tester.takeException(), isNull);
    });

    testWidgets('unRelated toggles independently', (tester) async {
      final changes = <Object?>[];
      await pumpHost(
        tester,
        SemiTree(
          treeData: data,
          defaultExpandedKeys: const ['a'],
          multiple: true,
          checkRelation: SemiTreeCheckRelation.unRelated,
          onChange: changes.add,
        ),
      );
      await tester.pump();
      await tester.tap(find.text('B'));
      await tester.pump();
      expect(changes.last, ['b']);
      final boxes = tester
          .widgetList<SemiCheckbox>(find.byType(SemiCheckbox))
          .toList();
      expect(boxes[0].indeterminate, isFalse);
      expect(boxes[0].checked, isFalse);
      expect(tester.takeException(), isNull);
    });

    testWidgets('leafOnly / autoMergeValue shape the onChange payload', (
      tester,
    ) async {
      final leafChanges = <Object?>[];
      final mergedChanges = <Object?>[];
      await pumpHost(
        tester,
        SemiTree(
          treeData: data,
          multiple: true,
          checkRelation: SemiTreeCheckRelation.related,
          leafOnly: true,
          onChange: leafChanges.add,
        ),
      );
      await tester.pump();
      await tester.tap(find.text('A'));
      await tester.pump();
      expect(leafChanges.last, ['b', 'c']);
      await pumpHost(
        tester,
        SemiTree(
          treeData: data,
          multiple: true,
          autoMergeValue: false,
          onChange: mergedChanges.add,
        ),
      );
      await tester.pump();
      await tester.tap(find.text('A'));
      await tester.pump();
      expect(mergedChanges.last, ['a', 'b', 'c']);
      expect(tester.takeException(), isNull);
    });

    testWidgets('filter expands ancestors, highlights strings and can show '
        'only matches', (tester) async {
      final searches = <String>[];
      await pumpHost(
        tester,
        SemiTree(
          treeData: data,
          filterTreeNode: true,
          onSearch: (input, expandedKeys) =>
              searches.add('$input/${expandedKeys.join(',')}'),
        ),
      );
      await tester.pump();
      await tester.enterText(
        find.descendant(
          of: find.byKey(SemiTree.searchInputKey),
          matching: find.byType(EditableText),
        ),
        'B',
      );
      await tester.pump();
      expect(searches.last, 'B/a');
      expect(find.text('B'), findsWidgets);
      expect(find.byType(SemiHighlight), findsOneWidget);
      // 非 showFilteredOnly：D 仍在。
      expect(find.text('D'), findsOneWidget);
      await pumpHost(
        tester,
        SemiTree(treeData: data, filterTreeNode: true, showFilteredOnly: true),
      );
      await tester.pump();
      await tester.enterText(
        find.descendant(
          of: find.byKey(SemiTree.searchInputKey),
          matching: find.byType(EditableText),
        ),
        'B',
      );
      await tester.pump();
      expect(find.text('D'), findsNothing);
      await tester.enterText(
        find.descendant(
          of: find.byKey(SemiTree.searchInputKey),
          matching: find.byType(EditableText),
        ),
        'ZZZ',
      );
      await tester.pump();
      expect(find.byKey(SemiTree.emptyKey), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('directory icons, tree icon and renderLabel', (tester) async {
      await pumpHost(tester, const SemiTree(treeData: data, directory: true));
      await tester.pump();
      final icons = tester.widgetList<SemiIcon>(find.byType(SemiIcon)).toList();
      expect(icons.map((i) => i.data), contains(SemiIcons.folder));
      expect(icons.map((i) => i.data), contains(SemiIcons.file));
      await tester.tap(expandArrow('a'));
      await tester.pump(const Duration(milliseconds: 300));
      final expandedIcons = tester
          .widgetList<SemiIcon>(find.byType(SemiIcon))
          .map((i) => i.data);
      expect(expandedIcons, contains(SemiIcons.folderOpen));
      await pumpHost(
        tester,
        SemiTree(
          treeData: data,
          icon: (node) => Text('icon-${node.key}'),
          renderLabel: (label, node, word) => Text('label-${node.key}'),
        ),
      );
      await tester.pump();
      expect(find.text('icon-a'), findsOneWidget);
      expect(find.text('label-a'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('showLine paints indent guide lines', (tester) async {
      await pumpHost(
        tester,
        const SemiTree(
          treeData: data,
          showLine: true,
          defaultExpandedKeys: ['a'],
        ),
      );
      await tester.pump();
      final painters = tester
          .widgetList<CustomPaint>(find.byType(CustomPaint))
          .map((p) => p.painter.runtimeType.toString())
          .where((name) => name.contains('TreeRowLinePainter'));
      expect(painters, isNotEmpty);
      expect(tester.takeException(), isNull);
    });

    testWidgets('virtualize builds a ListView and defaults to ellipsis', (
      tester,
    ) async {
      await pumpHost(
        tester,
        const SemiTree(
          treeData: data,
          defaultExpandedKeys: ['a'],
          virtualize: SemiTreeVirtualize(itemSize: 30),
        ),
      );
      await tester.pump();
      expect(find.byKey(SemiTree.listKey), findsOneWidget);
      final list = tester.widget<ListView>(find.byKey(SemiTree.listKey));
      expect(list.itemExtent, 30);
      // labelEllipsis 缺省跟随 virtualize（quirk）。
      final label = tester.widget<Text>(find.text('B'));
      expect(label.maxLines, 1);
      // 虚拟化不播运动。
      await tester.tap(expandArrow('a'));
      await tester.pump();
      expect(find.byType(SizeTransition), findsNothing);
      expect(tester.takeException(), isNull);
    });

    testWidgets('loadData shows a spin, records loadedKeys and calls onLoad', (
      tester,
    ) async {
      var loads = 0;
      final loaded = <String>{};
      final treeData = <SemiTreeNodeData>[
        const SemiTreeNodeData(key: 'lazy', label: 'Lazy'),
      ];
      await pumpHost(
        tester,
        SemiTree(
          treeData: treeData,
          loadData: (node) async {
            loads++;
            await Future<void>.delayed(const Duration(milliseconds: 20));
          },
          onLoad: (keys, node) => loaded.addAll(keys),
        ),
      );
      await tester.pump();
      await tester.tap(expandArrow('lazy'));
      await tester.pump();
      expect(find.byType(SemiSpin), findsOneWidget);
      await tester.pump(const Duration(milliseconds: 40));
      await tester.pump();
      expect(loads, 1);
      expect(loaded, {'lazy'});
      expect(find.byType(SemiSpin), findsNothing);
      expect(tester.takeException(), isNull);
    });

    testWidgets('empty state honors emptyContent', (tester) async {
      await pumpHost(tester, const SemiTree(treeData: []));
      await tester.pump();
      expect(find.byKey(SemiTree.emptyKey), findsOneWidget);
      expect(find.text('暂无数据'), findsOneWidget);
      await pumpHost(tester, const SemiTree(treeData: [], emptyContent: '空'));
      await tester.pump();
      expect(find.text('空'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('expandAction click expands on row tap; doubleClick needs two '
        'taps and notifies', (tester) async {
      await pumpHost(
        tester,
        const SemiTree(
          treeData: data,
          expandAction: SemiTreeExpandAction.click,
        ),
      );
      await tester.pump();
      await tester.tap(find.text('A'));
      await tester.pump(const Duration(milliseconds: 300));
      expect(find.text('B'), findsOneWidget);

      final doubles = <String>[];
      final changes = <Object?>[];
      await pumpHost(
        tester,
        SemiTree(
          treeData: data,
          expandAction: SemiTreeExpandAction.doubleClick,
          onDoubleClick: (node) => doubles.add(node.key),
          onChange: changes.add,
        ),
      );
      await tester.pump();
      await tester.tap(find.text('A'));
      await tester.pump(const Duration(milliseconds: 50));
      expect(find.text('B'), findsNothing);
      await tester.tap(find.text('A'));
      await tester.pump(const Duration(milliseconds: 300));
      expect(doubles, ['a']);
      expect(find.text('B'), findsOneWidget);
      // 双击模式下第二次点击不重复选择（首次已选）。
      expect(changes, ['a']);
      expect(tester.takeException(), isNull);
    });

    testWidgets('checkbox tap does not double-fire the row select', (
      tester,
    ) async {
      final selects = <String>[];
      await pumpHost(
        tester,
        SemiTree(
          treeData: data,
          multiple: true,
          onSelect: (key, selected, node) => selects.add(key),
        ),
      );
      await tester.pump();
      await tester.tap(find.byKey(const ValueKey('tree-checkbox-a')));
      await tester.pump();
      expect(selects, ['a']);
      expect(tester.takeException(), isNull);
    });

    testWidgets('right click reports the context menu callback', (
      tester,
    ) async {
      final menus = <String>[];
      await pumpHost(
        tester,
        SemiTree(treeData: data, onContextMenu: (node) => menus.add(node.key)),
      );
      await tester.pump();
      await tester.tap(find.text('D'), buttons: kSecondaryMouseButton);
      await tester.pump();
      expect(menus, ['d']);
      expect(tester.takeException(), isNull);
    });

    testWidgets('blockNode false keeps the row background transparent and '
        'tints the label on hover', (tester) async {
      final gesture = await startMouse(tester);
      final resolved = const SemiTreeThemeData().resolve(
        const SemiThemeData.light(),
      );
      await pumpHost(tester, const SemiTree(treeData: data, blockNode: false));
      await tester.pump();
      await gesture.moveTo(tester.getCenter(find.text('D')));
      await tester.pump();
      // 行底色保持透明；标题文字区染 fill-0。
      expect(rowBg(tester, 'D'), const Color(0x00000000));
      expect(labelBg(tester, 'D'), resolved.colorTreeOptionBgHover);
      expect(tester.takeException(), isNull);
    });

    testWidgets('RTL mirrors the collapsed arrow rotation', (tester) async {
      await pumpHost(
        tester,
        const SemiTree(treeData: data),
        direction: TextDirection.rtl,
      );
      await tester.pump();
      final icons = tester
          .widgetList<SemiIcon>(find.byType(SemiIcon))
          .where((icon) => icon.data == SemiIcons.treeTriangleDown);
      expect(icons, isNotEmpty);
      expect(icons.first.rotate, 90);
      expect(tester.takeException(), isNull);
    });
  });
}
