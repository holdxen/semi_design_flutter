// Behavior matrix for SemiTagInput plus coverage for the 55 Sass declarations
// (49 FIELDS + 6 MOTION + 0 INTERNAL) — the 6 HARDCODES provenance anchors
// live in the widget's `_TagInputMetrics` / call sites.
import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/semantics.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:semi_design_flutter/semi_design_flutter.dart';

/// The host body is served through a notifier: `Overlay.initialEntries` is
/// initState-only, so the entry must rebuild its child from outside (and the
/// subtree element identity survives `pumpWidget` for the keepState cases —
/// the slider test-host precedent).
final _hostBody = ValueNotifier<Widget>(const SizedBox.shrink());

Widget host(
  Widget child, {
  TextDirection direction = TextDirection.ltr,
  bool keepState = false,
}) {
  // A fresh element per pumpWidget by default (every subcase gets its own
  // uncontrolled buffer); `keepState` preserves the state across pumps for
  // the release-control tests.
  _hostBody.value = keepState
      ? child
      : KeyedSubtree(key: UniqueKey(), child: child);
  return SemiTheme(
    data: const SemiThemeData.light(),
    child: Directionality(
      textDirection: direction,
      child: MediaQuery(
        data: const MediaQueryData(size: Size(800, 600)),
        child: Overlay(
          // The showContentTooltip wrap inserts overlay entries on hover.
          initialEntries: [
            OverlayEntry(
              builder: (context) => ValueListenableBuilder<Widget>(
                valueListenable: _hostBody,
                builder: (context, child, _) =>
                    Center(child: SizedBox(width: 400, child: child)),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

String inputText(WidgetTester tester) =>
    tester.widget<EditableText>(find.byType(EditableText)).controller.text;

BoxDecoration rootFrameDecoration(WidgetTester tester) =>
    tester
            .widget<AnimatedContainer>(find.byKey(SemiTagInput.rootKey))
            .foregroundDecoration!
        as BoxDecoration;

BoxDecoration rootBgDecoration(WidgetTester tester) =>
    tester
            .widget<AnimatedContainer>(
              find.descendant(
                of: find.byKey(SemiTagInput.rootKey),
                matching: find.byType(AnimatedContainer),
              ),
            )
            .decoration!
        as BoxDecoration;

Border rootBorder(WidgetTester tester) =>
    rootFrameDecoration(tester).border! as Border;

Visibility clearVisibility(WidgetTester tester) => tester.widget<Visibility>(
  find.ancestor(
    of: find.byKey(SemiTagInput.clearButtonKey),
    matching: find.byType(Visibility),
  ),
);

SemiResolvedTagInputThemeData resolved([SemiThemeData? theme]) =>
    const SemiTagInputThemeData().resolve(theme ?? const SemiThemeData.light());

Future<TestGesture> startMouse(WidgetTester tester) async {
  final gesture = await tester.createGesture(kind: ui.PointerDeviceKind.mouse);
  await gesture.addPointer(location: Offset.zero);
  addTearDown(gesture.removePointer);
  return gesture;
}

Future<void> focusInput(WidgetTester tester) async {
  await tester.tap(find.byType(EditableText));
  await tester.pump();
}

Future<void> enterAdd(WidgetTester tester, String text) async {
  await tester.enterText(find.byType(EditableText), text);
  await tester.testTextInput.receiveAction(TextInputAction.done);
  await tester.pump();
}

typedef _Patch = SemiTagInputThemeData Function(Object value);
typedef _Read = Object? Function(SemiResolvedTagInputThemeData data);
typedef _Default = Object? Function(SemiThemeData theme);

/// All 55 upstream declarations: 49 FIELDS (variables.scss) + 6 MOTION
/// (animation.scss). INTERNAL is empty (no transform token upstream).
final List<(String, Object, _Patch, _Read, _Default)> fields = [
  (
    r'$color-tagInput-icon-default: var(--semi-color-text-2)',
    const Color(0xff123456),
    (Object v) => SemiTagInputThemeData(colorTagInputIconDefault: v as Color),
    (SemiResolvedTagInputThemeData d) => d.colorTagInputIconDefault,
    (SemiThemeData theme) => theme.colors.colorText2,
  ),
  (
    r'$color-tagInput-maxTagCount-default: var(--semi-color-text-0)',
    const Color(0xff123456),
    (Object v) =>
        SemiTagInputThemeData(colorTagInputMaxTagCountDefault: v as Color),
    (SemiResolvedTagInputThemeData d) => d.colorTagInputMaxTagCountDefault,
    (SemiThemeData theme) => theme.colors.colorText0,
  ),
  (
    r'$color-tagInput-icon-hover: var(--semi-color-primary-hover)',
    const Color(0xff123456),
    (Object v) => SemiTagInputThemeData(colorTagInputIconHover: v as Color),
    (SemiResolvedTagInputThemeData d) => d.colorTagInputIconHover,
    (SemiThemeData theme) => theme.colors.colorPrimaryHover,
  ),
  (
    r'$color-tagInput_disabled-text-default: var(--semi-color-disabled-text)',
    const Color(0xff123456),
    (Object v) =>
        SemiTagInputThemeData(colorTagInputDisabledTextDefault: v as Color),
    (SemiResolvedTagInputThemeData d) => d.colorTagInputDisabledTextDefault,
    (SemiThemeData theme) => theme.colors.colorDisabledText,
  ),
  (
    r'$color-tagInput_disabled-bg: var(--semi-color-disabled-fill)',
    const Color(0xff123456),
    (Object v) => SemiTagInputThemeData(colorTagInputDisabledBg: v as Color),
    (SemiResolvedTagInputThemeData d) => d.colorTagInputDisabledBg,
    (SemiThemeData theme) => theme.colors.colorDisabledFill,
  ),
  (
    r'$color-tagInput_default-bg-focus: var(--semi-color-fill-0)',
    const Color(0xff123456),
    (Object v) =>
        SemiTagInputThemeData(colorTagInputDefaultBgFocus: v as Color),
    (SemiResolvedTagInputThemeData d) => d.colorTagInputDefaultBgFocus,
    (SemiThemeData theme) => theme.colors.colorFill0,
  ),
  (
    r'$color-tagInput-border-default: transparent',
    const Color(0xff123456),
    (Object v) => SemiTagInputThemeData(colorTagInputBorderDefault: v as Color),
    (SemiResolvedTagInputThemeData d) => d.colorTagInputBorderDefault,
    (SemiThemeData theme) => const Color(0x00000000),
  ),
  (
    // ★ the source keeps a TRAILING SPACE after `transparent`
    // (variables.scss:9) — provenance copies the raw text.
    r'$color-tagInput-border-hover: transparent ',
    const Color(0xff123456),
    (Object v) => SemiTagInputThemeData(colorTagInputBorderHover: v as Color),
    (SemiResolvedTagInputThemeData d) => d.colorTagInputBorderHover,
    (SemiThemeData theme) => const Color(0x00000000),
  ),
  (
    r'$color-tagInput-border-focus: var(--semi-color-focus-border)',
    const Color(0xff123456),
    (Object v) => SemiTagInputThemeData(colorTagInputBorderFocus: v as Color),
    (SemiResolvedTagInputThemeData d) => d.colorTagInputBorderFocus,
    (SemiThemeData theme) => theme.colors.colorFocusBorder,
  ),
  (
    r'$color-tagInput_prefix-default: var(--semi-color-text-2)',
    const Color(0xff123456),
    (Object v) => SemiTagInputThemeData(colorTagInputPrefixDefault: v as Color),
    (SemiResolvedTagInputThemeData d) => d.colorTagInputPrefixDefault,
    (SemiThemeData theme) => theme.colors.colorText2,
  ),
  (
    r'$color-tagInput_suffix-default: var(--semi-color-text-2)',
    const Color(0xff123456),
    (Object v) => SemiTagInputThemeData(colorTagInputSuffixDefault: v as Color),
    (SemiResolvedTagInputThemeData d) => d.colorTagInputSuffixDefault,
    (SemiThemeData theme) => theme.colors.colorText2,
  ),
  (
    r'$color-tagInput_default-bg-default: var(--semi-color-fill-0)',
    const Color(0xff123456),
    (Object v) =>
        SemiTagInputThemeData(colorTagInputDefaultBgDefault: v as Color),
    (SemiResolvedTagInputThemeData d) => d.colorTagInputDefaultBgDefault,
    (SemiThemeData theme) => theme.colors.colorFill0,
  ),
  (
    r'$color-tagInput_default-bg-hover: var(--semi-color-fill-1)',
    const Color(0xff123456),
    (Object v) =>
        SemiTagInputThemeData(colorTagInputDefaultBgHover: v as Color),
    (SemiResolvedTagInputThemeData d) => d.colorTagInputDefaultBgHover,
    (SemiThemeData theme) => theme.colors.colorFill1,
  ),
  (
    r'$color-tagInput_warning-bg-default: var(--semi-color-warning-light-default)',
    const Color(0xff123456),
    (Object v) =>
        SemiTagInputThemeData(colorTagInputWarningBgDefault: v as Color),
    (SemiResolvedTagInputThemeData d) => d.colorTagInputWarningBgDefault,
    (SemiThemeData theme) => theme.colors.colorWarningLightDefault,
  ),
  (
    r'$color-tagInput_warning-border-default: var(--semi-color-warning-light-default)',
    const Color(0xff123456),
    (Object v) =>
        SemiTagInputThemeData(colorTagInputWarningBorderDefault: v as Color),
    (SemiResolvedTagInputThemeData d) => d.colorTagInputWarningBorderDefault,
    (SemiThemeData theme) => theme.colors.colorWarningLightDefault,
  ),
  (
    r'$color-tagInput_warning-bg-hover: var(--semi-color-warning-light-hover)',
    const Color(0xff123456),
    (Object v) =>
        SemiTagInputThemeData(colorTagInputWarningBgHover: v as Color),
    (SemiResolvedTagInputThemeData d) => d.colorTagInputWarningBgHover,
    (SemiThemeData theme) => theme.colors.colorWarningLightHover,
  ),
  (
    r'$color-tagInput_warning-border-hover: var(--semi-color-warning-light-hover)',
    const Color(0xff123456),
    (Object v) =>
        SemiTagInputThemeData(colorTagInputWarningBorderHover: v as Color),
    (SemiResolvedTagInputThemeData d) => d.colorTagInputWarningBorderHover,
    (SemiThemeData theme) => theme.colors.colorWarningLightHover,
  ),
  (
    r'$color-tagInput_warning-bg-focus: var(--semi-color-warning-light-default)',
    const Color(0xff123456),
    (Object v) =>
        SemiTagInputThemeData(colorTagInputWarningBgFocus: v as Color),
    (SemiResolvedTagInputThemeData d) => d.colorTagInputWarningBgFocus,
    (SemiThemeData theme) => theme.colors.colorWarningLightDefault,
  ),
  (
    r'$color-tagInput_warning-border-focus: var(--semi-color-warning)',
    const Color(0xff123456),
    (Object v) =>
        SemiTagInputThemeData(colorTagInputWarningBorderFocus: v as Color),
    (SemiResolvedTagInputThemeData d) => d.colorTagInputWarningBorderFocus,
    (SemiThemeData theme) => theme.colors.colorWarning,
  ),
  (
    r'$color-tagInput_danger-bg-default: var(--semi-color-danger-light-default)',
    const Color(0xff123456),
    (Object v) =>
        SemiTagInputThemeData(colorTagInputDangerBgDefault: v as Color),
    (SemiResolvedTagInputThemeData d) => d.colorTagInputDangerBgDefault,
    (SemiThemeData theme) => theme.colors.colorDangerLightDefault,
  ),
  (
    r'$color-tagInput_danger-border-default: var(--semi-color-danger-light-default)',
    const Color(0xff123456),
    (Object v) =>
        SemiTagInputThemeData(colorTagInputDangerBorderDefault: v as Color),
    (SemiResolvedTagInputThemeData d) => d.colorTagInputDangerBorderDefault,
    (SemiThemeData theme) => theme.colors.colorDangerLightDefault,
  ),
  (
    r'$color-tagInput_danger-bg-hover: var(--semi-color-danger-light-hover)',
    const Color(0xff123456),
    (Object v) => SemiTagInputThemeData(colorTagInputDangerBgHover: v as Color),
    (SemiResolvedTagInputThemeData d) => d.colorTagInputDangerBgHover,
    (SemiThemeData theme) => theme.colors.colorDangerLightHover,
  ),
  (
    r'$color-tagInput_danger-border-hover: var(--semi-color-danger-light-hover)',
    const Color(0xff123456),
    (Object v) =>
        SemiTagInputThemeData(colorTagInputDangerBorderHover: v as Color),
    (SemiResolvedTagInputThemeData d) => d.colorTagInputDangerBorderHover,
    (SemiThemeData theme) => theme.colors.colorDangerLightHover,
  ),
  (
    r'$color-tagInput_danger-bg-focus: var(--semi-color-danger-light-default)',
    const Color(0xff123456),
    (Object v) => SemiTagInputThemeData(colorTagInputDangerBgFocus: v as Color),
    (SemiResolvedTagInputThemeData d) => d.colorTagInputDangerBgFocus,
    (SemiThemeData theme) => theme.colors.colorDangerLightDefault,
  ),
  (
    r'$color-tagInput_danger-border-focus: var(--semi-color-danger)',
    const Color(0xff123456),
    (Object v) =>
        SemiTagInputThemeData(colorTagInputDangerBorderFocus: v as Color),
    (SemiResolvedTagInputThemeData d) => d.colorTagInputDangerBorderFocus,
    (SemiThemeData theme) => theme.colors.colorDanger,
  ),
  (
    r'$color-tagInput_sortable_item_over-bg: var(--semi-color-primary)',
    const Color(0xff123456),
    (Object v) =>
        SemiTagInputThemeData(colorTagInputSortableItemOverBg: v as Color),
    (SemiResolvedTagInputThemeData d) => d.colorTagInputSortableItemOverBg,
    (SemiThemeData theme) => theme.colors.colorPrimary,
  ),
  (
    r'$color-tagInput_prefix-text-default: var(--semi-color-text-2)',
    const Color(0xff123456),
    (Object v) =>
        SemiTagInputThemeData(colorTagInputPrefixTextDefault: v as Color),
    (SemiResolvedTagInputThemeData d) => d.colorTagInputPrefixTextDefault,
    (SemiThemeData theme) => theme.colors.colorText2,
  ),
  (
    r'$color-tagInput_handler-icon-default: var(--semi-color-text-2)',
    const Color(0xff123456),
    (Object v) =>
        SemiTagInputThemeData(colorTagInputHandlerIconDefault: v as Color),
    (SemiResolvedTagInputThemeData d) => d.colorTagInputHandlerIconDefault,
    (SemiThemeData theme) => theme.colors.colorText2,
  ),
  (
    r'$spacing-tagInput_small-Y: 1px',
    4.5,
    (Object v) => SemiTagInputThemeData(spacingTagInputSmallY: v as double),
    (SemiResolvedTagInputThemeData d) => d.spacingTagInputSmallY,
    (SemiThemeData theme) => 1.0,
  ),
  (
    r'$spacing-tagInput_default-Y: $spacing-super-tight',
    4.5,
    (Object v) => SemiTagInputThemeData(spacingTagInputDefaultY: v as double),
    (SemiResolvedTagInputThemeData d) => d.spacingTagInputDefaultY,
    (SemiThemeData theme) => 2.0,
  ),
  (
    r'$spacing-tagInput_large-Y: 3px',
    4.5,
    (Object v) => SemiTagInputThemeData(spacingTagInputLargeY: v as double),
    (SemiResolvedTagInputThemeData d) => d.spacingTagInputLargeY,
    (SemiThemeData theme) => 3.0,
  ),
  (
    r'$spacing-tagInput_wrapper_n_paddingX: $spacing-tight',
    4.5,
    (Object v) =>
        SemiTagInputThemeData(spacingTagInputWrapperNPaddingX: v as double),
    (SemiResolvedTagInputThemeData d) => d.spacingTagInputWrapperNPaddingX,
    (SemiThemeData theme) => 8.0,
  ),
  (
    r'$spacing-tagInput_drag_handler-marginRight: 4px',
    4.5,
    (Object v) => SemiTagInputThemeData(
      spacingTagInputDragHandlerMarginRight: v as double,
    ),
    (SemiResolvedTagInputThemeData d) =>
        d.spacingTagInputDragHandlerMarginRight,
    (SemiThemeData theme) => 4.0,
  ),
  (
    r'$spacing-tagInput_tag_icon_paddingLeft: 4px',
    4.5,
    (Object v) =>
        SemiTagInputThemeData(spacingTagInputTagIconPaddingLeft: v as double),
    (SemiResolvedTagInputThemeData d) => d.spacingTagInputTagIconPaddingLeft,
    (SemiThemeData theme) => 4.0,
  ),
  (
    r'$spacing-tagInput_prefix_suffix-marginX: $spacing-base-tight',
    4.5,
    (Object v) =>
        SemiTagInputThemeData(spacingTagInputPrefixSuffixMarginX: v as double),
    (SemiResolvedTagInputThemeData d) => d.spacingTagInputPrefixSuffixMarginX,
    (SemiThemeData theme) => 12.0,
  ),
  (
    r'$height-tagInput-large: $height-control-large',
    4.5,
    (Object v) => SemiTagInputThemeData(heightTagInputLarge: v as double),
    (SemiResolvedTagInputThemeData d) => d.heightTagInputLarge,
    (SemiThemeData theme) => 40.0,
  ),
  (
    r'$height-tagInput-default: $height-control-default',
    4.5,
    (Object v) => SemiTagInputThemeData(heightTagInputDefault: v as double),
    (SemiResolvedTagInputThemeData d) => d.heightTagInputDefault,
    (SemiThemeData theme) => 32.0,
  ),
  (
    r'$height-tagInput-small: $height-control-small',
    4.5,
    (Object v) => SemiTagInputThemeData(heightTagInputSmall: v as double),
    (SemiResolvedTagInputThemeData d) => d.heightTagInputSmall,
    (SemiThemeData theme) => 24.0,
  ),
  (
    r'$height-tagInput_input_small: 20px',
    4.5,
    (Object v) => SemiTagInputThemeData(heightTagInputInputSmall: v as double),
    (SemiResolvedTagInputThemeData d) => d.heightTagInputInputSmall,
    (SemiThemeData theme) => 20.0,
  ),
  (
    r'$height-tagInput_input_default: 24px',
    4.5,
    (Object v) =>
        SemiTagInputThemeData(heightTagInputInputDefault: v as double),
    (SemiResolvedTagInputThemeData d) => d.heightTagInputInputDefault,
    (SemiThemeData theme) => 24.0,
  ),
  (
    r'$height-tagInput_input_large: 24px',
    4.5,
    (Object v) => SemiTagInputThemeData(heightTagInputInputLarge: v as double),
    (SemiResolvedTagInputThemeData d) => d.heightTagInputInputLarge,
    (SemiThemeData theme) => 24.0,
  ),
  (
    r'$width-tagInput-clear-medium: $width-icon-medium * 2',
    4.5,
    (Object v) => SemiTagInputThemeData(widthTagInputClearMedium: v as double),
    (SemiResolvedTagInputThemeData d) => d.widthTagInputClearMedium,
    (SemiThemeData theme) => 32.0,
  ),
  (
    r'$width-tagInput-border-default: $border-thickness-control',
    4.5,
    (Object v) =>
        SemiTagInputThemeData(widthTagInputBorderDefault: v as double),
    (SemiResolvedTagInputThemeData d) => d.widthTagInputBorderDefault,
    (SemiThemeData theme) => 1.0,
  ),
  (
    r'$width-tagInput-border-hover: $width-tagInput-border-default',
    4.5,
    (Object v) => SemiTagInputThemeData(widthTagInputBorderHover: v as double),
    (SemiResolvedTagInputThemeData d) => d.widthTagInputBorderHover,
    (SemiThemeData theme) => 1.0,
  ),
  (
    r'$width-tagInput-border-focus: $border-thickness-control-focus',
    4.5,
    (Object v) => SemiTagInputThemeData(widthTagInputBorderFocus: v as double),
    (SemiResolvedTagInputThemeData d) => d.widthTagInputBorderFocus,
    (SemiThemeData theme) => 1.0,
  ),
  (
    r'$width-tagInput_sortable_item_over: 2px',
    4.5,
    (Object v) =>
        SemiTagInputThemeData(widthTagInputSortableItemOver: v as double),
    (SemiResolvedTagInputThemeData d) => d.widthTagInputSortableItemOver,
    (SemiThemeData theme) => 2.0,
  ),
  (
    r'$radius-tagInput: var(--semi-border-radius-small)',
    4.5,
    (Object v) => SemiTagInputThemeData(radiusTagInput: v as double),
    (SemiResolvedTagInputThemeData d) => d.radiusTagInput,
    (SemiThemeData theme) => theme.radius.borderRadiusSmall.value,
  ),
  (
    // ★ provenance keeps the `!default` marker (variables.scss:58).
    r'$z-tagInput_drag_item_move: 2000 !default',
    4.5,
    (Object v) => SemiTagInputThemeData(zTagInputDragItemMove: v as double),
    (SemiResolvedTagInputThemeData d) => d.zTagInputDragItemMove,
    (SemiThemeData theme) => 2000.0,
  ),
  (
    r'$font-tagInput_prefix_suffix-fontWeight: $font-weight-bold',
    FontWeight.w900,
    (Object v) => SemiTagInputThemeData(
      fontTagInputPrefixSuffixFontWeight: v as FontWeight,
    ),
    (SemiResolvedTagInputThemeData d) => d.fontTagInputPrefixSuffixFontWeight,
    (SemiThemeData theme) => theme.typography.fontWeightBold,
  ),
  (
    r'$transition_duration-tagInput-bg: var(--semi-transition_duration-none)',
    const Duration(milliseconds: 7),
    (Object v) =>
        SemiTagInputThemeData(transitionDurationTagInputBg: v as Duration),
    (SemiResolvedTagInputThemeData d) => d.transitionDurationTagInputBg,
    (SemiThemeData theme) => Duration.zero,
  ),
  (
    r'$transition_function-tagInput-bg: var(--semi-transition_function-easeIn)',
    Curves.bounceIn,
    (Object v) =>
        SemiTagInputThemeData(transitionFunctionTagInputBg: v as Curve),
    (SemiResolvedTagInputThemeData d) => d.transitionFunctionTagInputBg,
    (SemiThemeData theme) => Curves.easeIn,
  ),
  (
    r'$transition_delay-tagInput-bg: var(--semi-transition_delay-none)',
    const Duration(milliseconds: 7),
    (Object v) =>
        SemiTagInputThemeData(transitionDelayTagInputBg: v as Duration),
    (SemiResolvedTagInputThemeData d) => d.transitionDelayTagInputBg,
    (SemiThemeData theme) => Duration.zero,
  ),
  (
    r'$transition_duration-tagInput-border: var(--semi-transition_duration-none)',
    const Duration(milliseconds: 7),
    (Object v) =>
        SemiTagInputThemeData(transitionDurationTagInputBorder: v as Duration),
    (SemiResolvedTagInputThemeData d) => d.transitionDurationTagInputBorder,
    (SemiThemeData theme) => Duration.zero,
  ),
  (
    r'$transition_function-tagInput-border: var(--semi-transition_function-easeIn)',
    Curves.bounceIn,
    (Object v) =>
        SemiTagInputThemeData(transitionFunctionTagInputBorder: v as Curve),
    (SemiResolvedTagInputThemeData d) => d.transitionFunctionTagInputBorder,
    (SemiThemeData theme) => Curves.easeIn,
  ),
  (
    r'$transition_delay-tagInput-border: var(--semi-transition_delay-none)',
    const Duration(milliseconds: 7),
    (Object v) =>
        SemiTagInputThemeData(transitionDelayTagInputBorder: v as Duration),
    (SemiResolvedTagInputThemeData d) => d.transitionDelayTagInputBorder,
    (SemiThemeData theme) => Duration.zero,
  ),
];

void main() {
  group('separator and Enter add', () {
    testWidgets('separator four forms + custom split', (tester) async {
      // default ','
      var adds = <List<String>>[];
      await tester.pumpWidget(host(SemiTagInput(onAdd: adds.add)));
      await enterAdd(tester, 'a,b');
      expect(adds, [
        ['a', 'b'],
      ]);
      expect(find.byType(SemiTag), findsNWidgets(2));

      // string separator '-'
      adds = [];
      await tester.pumpWidget(
        host(SemiTagInput(separator: '-', onAdd: adds.add)),
      );
      await enterAdd(tester, 'abc-hotsoon');
      expect(adds, [
        ['abc', 'hotsoon'],
      ]);

      // number separator 1 (JS coerces to '1')
      adds = [];
      await tester.pumpWidget(
        host(SemiTagInput(separator: 1, onAdd: adds.add)),
      );
      await enterAdd(tester, 'semi1design');
      expect(adds, [
        ['semi', 'design'],
      ]);

      // array separator folds separators[1..] into separators[0]
      adds = [];
      await tester.pumpWidget(
        host(SemiTagInput(separator: ['-', '/', '*'], onAdd: adds.add)),
      );
      await enterAdd(tester, 'abc-hotsoon/pipixi*qingyan');
      expect(adds, [
        ['abc', 'hotsoon', 'pipixi', 'qingyan'],
      ]);

      // null separator -> single item
      adds = [];
      await tester.pumpWidget(
        host(SemiTagInput(separator: null, onAdd: adds.add)),
      );
      await enterAdd(tester, 'semi-hotsoon');
      expect(adds, [
        ['semi-hotsoon'],
      ]);

      // custom split overrides everything
      adds = [];
      await tester.pumpWidget(
        host(
          SemiTagInput(
            separator: ',',
            split: (text, separator) => text.split('|').toList(),
            onAdd: adds.add,
          ),
        ),
      );
      await enterAdd(tester, 'x|y');
      expect(adds, [
        ['x', 'y'],
      ]);
    });

    testWidgets('Enter add: empty input no-op; ★untrimmed kept; empty '
        'segments dropped', (tester) async {
      final adds = <List<String>>[];
      final changes = <List<String>>[];
      await tester.pumpWidget(
        host(SemiTagInput(onAdd: adds.add, onChanged: changes.add)),
      );
      await focusInput(tester);
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pump();
      // ★ empty input: Enter consumed but nothing added.
      expect(adds, isEmpty);
      expect(changes, isEmpty);
      await enterAdd(tester, 'a,, b ');
      // ★ empty segment dropped; kept values are NOT trimmed.
      expect(adds, [
        ['a', ' b '],
      ]);
      expect(find.text(' b '), findsOneWidget);
    });

    testWidgets('onAdd gets the batch; onChanged the full merged list', (
      tester,
    ) async {
      final adds = <List<String>>[];
      final changes = <List<String>>[];
      await tester.pumpWidget(
        host(
          SemiTagInput(
            defaultValue: const ['z'],
            onAdd: adds.add,
            onChanged: changes.add,
          ),
        ),
      );
      await enterAdd(tester, 'a,b');
      expect(adds, [
        ['a', 'b'],
      ]);
      expect(changes, [
        ['z', 'a', 'b'],
      ]);
    });

    testWidgets('allowDuplicates defaults true; false drops existing and '
        'in-batch repeats (keep first)', (tester) async {
      var adds = <List<String>>[];
      await tester.pumpWidget(
        host(SemiTagInput(defaultValue: const ['a'], onAdd: adds.add)),
      );
      await enterAdd(tester, 'a');
      expect(adds, [
        ['a'],
      ]);
      expect(find.text('a'), findsNWidgets(2));

      adds = [];
      await tester.pumpWidget(
        host(
          SemiTagInput(
            defaultValue: const ['a'],
            allowDuplicates: false,
            onAdd: adds.add,
          ),
        ),
      );
      await enterAdd(tester, 'a,a,b');
      expect(adds, [
        ['b'],
      ]);
      expect(find.text('a'), findsOneWidget);
      expect(find.text('b'), findsOneWidget);
    });

    testWidgets('max: onExceed full attempted list then silent truncation', (
      tester,
    ) async {
      final exceeds = <List<String>>[];
      final changes = <List<String>>[];
      final adds = <List<String>>[];
      await tester.pumpWidget(
        host(
          SemiTagInput(
            defaultValue: const ['a'],
            max: 3,
            onExceed: exceeds.add,
            onChanged: changes.add,
            onAdd: adds.add,
          ),
        ),
      );
      await enterAdd(tester, 'b,c,d');
      expect(exceeds, [
        ['a', 'b', 'c', 'd'],
      ]);
      // tail silently truncated: only b, c land.
      expect(changes, [
        ['a', 'b', 'c'],
      ]);
      expect(adds, [
        ['b', 'c'],
      ]);
      expect(find.text('d'), findsNothing);
    });
  });

  group('maxLength', () {
    testWidgets('keystroke growing a segment past maxLength is rejected '
        'with onInputExceed; deletions pass', (tester) async {
      final changes = <String>[];
      final exceeds = <String>[];
      await tester.pumpWidget(
        host(
          SemiTagInput(
            maxLength: 3,
            onInputChange: changes.add,
            onInputExceed: exceeds.add,
          ),
        ),
      );
      await tester.enterText(find.byType(EditableText), 'tik');
      await tester.pump();
      expect(inputText(tester), 'tik');
      await tester.enterText(find.byType(EditableText), 'tikt');
      await tester.pump();
      // ★ rejected: display keeps 'tik'.
      expect(inputText(tester), 'tik');
      expect(exceeds, ['tikt']);
      expect(changes, ['tik']);
      // deletion passes.
      await tester.enterText(find.byType(EditableText), 'ti');
      await tester.pump();
      expect(inputText(tester), 'ti');
    });

    testWidgets('IME composition end truncates the offending segment with '
        'onInputExceed and ★skips onInputChange', (tester) async {
      final changes = <String>[];
      final exceeds = <String>[];
      await tester.pumpWidget(
        host(
          SemiTagInput(
            maxLength: 2,
            separator: ['-', '/'],
            onInputChange: changes.add,
            onInputExceed: exceeds.add,
          ),
        ),
      );
      await tester.showKeyboard(find.byType(EditableText));
      // composition session (entering): updates are untracked but reported.
      tester.testTextInput.updateEditingValue(
        const TextEditingValue(
          text: 'ab-cd',
          composing: TextRange(start: 0, end: 5),
        ),
      );
      await tester.pump();
      tester.testTextInput.updateEditingValue(
        const TextEditingValue(
          text: 'ab-cdef',
          composing: TextRange(start: 0, end: 7),
        ),
      );
      await tester.pump();
      // composition end: 'cdef' over 2 -> truncated to 'cd'; ★ join coerces
      // the array separator to its ','-joined form ('-,/').
      tester.testTextInput.updateEditingValue(
        const TextEditingValue(text: 'ab-cdef', composing: TextRange.empty),
      );
      await tester.pump();
      expect(exceeds, ['ab-cdef']);
      expect(inputText(tester), 'ab-,/cd');
      // ★ the composition-end write skips onInputChange (Firefox workaround):
      // only the two composing updates were reported.
      expect(changes, ['ab-cd', 'ab-cdef']);
    });
  });

  group('Backspace and tag close', () {
    testWidgets('Backspace on empty input removes the last tag; text input '
        'deletes characters instead', (tester) async {
      final removes = <String>[];
      final changes = <List<String>>[];
      await tester.pumpWidget(
        host(
          SemiTagInput(
            defaultValue: const ['a', 'b'],
            onRemove: (value, index) => removes.add('$value@$index'),
            onChanged: changes.add,
          ),
        ),
      );
      await focusInput(tester);
      await tester.sendKeyEvent(LogicalKeyboardKey.backspace);
      await tester.pump();
      expect(removes, ['b@1']);
      expect(changes, [
        ['a'],
      ]);
      expect(find.text('b'), findsNothing);
      // non-empty input: Backspace deletes text, not tags.
      await tester.enterText(find.byType(EditableText), 'x');
      await tester.sendKeyEvent(LogicalKeyboardKey.backspace);
      await tester.pump();
      expect(removes, ['b@1']);
    });

    testWidgets('Backspace with no tags is a no-op', (tester) async {
      final removes = <String>[];
      await tester.pumpWidget(
        host(
          SemiTagInput(
            onRemove: (value, index) => removes.add('$value@$index'),
          ),
        ),
      );
      await focusInput(tester);
      await tester.sendKeyEvent(LogicalKeyboardKey.backspace);
      await tester.pump();
      expect(removes, isEmpty);
    });

    testWidgets('tag close fires onRemove(value, index) + onChanged', (
      tester,
    ) async {
      final removes = <String>[];
      final changes = <List<String>>[];
      await tester.pumpWidget(
        host(
          SemiTagInput(
            defaultValue: const ['a', 'b'],
            onRemove: (value, index) => removes.add('$value@$index'),
            onChanged: changes.add,
          ),
        ),
      );
      final close = find.descendant(
        of: find.byType(SemiTag).first,
        matching: find.byType(SemiIcon),
      );
      await tester.tap(close);
      await tester.pump();
      expect(removes, ['a@0']);
      expect(changes, [
        ['b'],
      ]);
      expect(find.text('a'), findsNothing);
    });
  });

  group('clear button', () {
    testWidgets('invisible until hovering with content; click clears tags '
        'and input', (tester) async {
      final changes = <List<String>>[];
      final inputChanges = <String>[];
      await tester.pumpWidget(
        host(
          SemiTagInput(
            showClear: true,
            defaultValue: const ['a'],
            onChanged: changes.add,
            onInputChange: inputChanges.add,
          ),
        ),
      );
      // The 32px slot exists but is hidden without hover.
      expect(find.byKey(SemiTagInput.clearButtonKey), findsOneWidget);
      expect(clearVisibility(tester).visible, isFalse);
      final gesture = await startMouse(tester);
      await gesture.moveTo(tester.getCenter(find.byKey(SemiTagInput.rootKey)));
      await tester.pumpAndSettle();
      expect(clearVisibility(tester).visible, isTrue);
      await tester.tap(find.byKey(SemiTagInput.clearButtonKey));
      await tester.pump();
      expect(changes, [[]]);
      expect(find.text('a'), findsNothing);
    });

    testWidgets('hidden without content and while disabled', (tester) async {
      await tester.pumpWidget(
        host(const SemiTagInput(showClear: true, disabled: true, value: ['a'])),
      );
      final gesture = await startMouse(tester);
      await gesture.moveTo(tester.getCenter(find.byKey(SemiTagInput.rootKey)));
      await tester.pumpAndSettle();
      // ★ disabled hides the clear button even when hovering.
      expect(clearVisibility(tester).visible, isFalse);
      await tester.pumpWidget(host(const SemiTagInput(showClear: true)));
      await gesture.moveTo(Offset.zero);
      await tester.pump();
      await gesture.moveTo(tester.getCenter(find.byKey(SemiTagInput.rootKey)));
      await tester.pumpAndSettle();
      // empty tags and empty input -> hidden.
      expect(clearVisibility(tester).visible, isFalse);
    });

    testWidgets('showClear false renders no clear slot', (tester) async {
      await tester.pumpWidget(host(const SemiTagInput()));
      expect(find.byKey(SemiTagInput.clearButtonKey), findsNothing);
    });
  });

  group('placeholder and maxTagCount', () {
    testWidgets('placeholder shows only with zero tags', (tester) async {
      await tester.pumpWidget(host(const SemiTagInput(placeholder: 'hi')));
      expect(
        tester.widget<SemiInput>(find.byType(SemiInput)).placeholder,
        'hi',
      );
      await tester.pumpWidget(
        host(const SemiTagInput(placeholder: 'hi', value: ['a'])),
      );
      expect(tester.widget<SemiInput>(find.byType(SemiInput)).placeholder, '');
    });

    testWidgets('maxTagCount folds to +N; expandRestTagsOnClick releases on '
        'focus', (tester) async {
      await tester.pumpWidget(
        host(const SemiTagInput(defaultValue: ['a', 'b', 'c'], maxTagCount: 2)),
      );
      expect(find.text('a'), findsOneWidget);
      expect(find.text('b'), findsOneWidget);
      expect(find.text('c'), findsNothing);
      expect(find.byKey(SemiTagInput.nTagKey), findsOneWidget);
      expect(find.text('+1'), findsOneWidget);
      // focus releases the fold (upstream `active`, approximated by focus).
      await focusInput(tester);
      expect(find.text('c'), findsOneWidget);
      expect(find.byKey(SemiTagInput.nTagKey), findsNothing);
    });

    testWidgets('showRestTagsPopover wraps the +N chip in a tooltip', (
      tester,
    ) async {
      await tester.pumpWidget(
        host(
          const SemiTagInput(
            defaultValue: ['a', 'b', 'c'],
            maxTagCount: 1,
            showRestTagsPopover: true,
          ),
        ),
      );
      expect(
        find.ancestor(
          of: find.byKey(SemiTagInput.nTagKey),
          matching: find.byType(SemiTooltip),
        ),
        findsOneWidget,
      );
      await tester.pumpWidget(
        host(
          const SemiTagInput(
            defaultValue: ['a', 'b', 'c'],
            maxTagCount: 1,
            showRestTagsPopover: false,
          ),
        ),
      );
      expect(find.text('+2'), findsOneWidget);
      expect(
        find.ancestor(
          of: find.byKey(SemiTagInput.nTagKey),
          matching: find.byType(SemiTooltip),
        ),
        findsNothing,
      );
    });
  });

  group('draggable', () {
    testWidgets('handles only while focused and enabled', (tester) async {
      await tester.pumpWidget(
        host(const SemiTagInput(draggable: true, defaultValue: ['a', 'b'])),
      );
      expect(find.byKey(SemiTagInput.dragHandleKey(0)), findsNothing);
      await focusInput(tester);
      expect(find.byKey(SemiTagInput.dragHandleKey(0)), findsOneWidget);
      expect(find.byKey(SemiTagInput.dragHandleKey(1)), findsOneWidget);
      await tester.pumpWidget(
        host(
          const SemiTagInput(
            draggable: true,
            disabled: true,
            defaultValue: ['a', 'b'],
          ),
        ),
      );
      expect(find.byKey(SemiTagInput.dragHandleKey(0)), findsNothing);
    });

    testWidgets('drag reorder fires exactly ONE onChanged at drop '
        '(arrayMove); no onAdd/onRemove', (tester) async {
      final changes = <List<String>>[];
      final adds = <List<String>>[];
      final removes = <String>[];
      await tester.pumpWidget(
        host(
          SemiTagInput(
            draggable: true,
            defaultValue: const ['a', 'b', 'c'],
            onChanged: changes.add,
            onAdd: adds.add,
            onRemove: (value, index) => removes.add('$value@$index'),
          ),
        ),
      );
      await focusInput(tester);
      final from = tester.getCenter(find.byKey(SemiTagInput.dragHandleKey(0)));
      final to = tester.getCenter(find.byKey(SemiTagInput.dragHandleKey(2)));
      final gesture = await tester.startGesture(from);
      await tester.pump();
      await gesture.moveTo(to);
      await tester.pump();
      await gesture.up();
      await tester.pump();
      // ★ exactly one onChanged at drop with the reordered array
      // (arrayMove(['a','b','c'], 0, 2) = ['b','c','a']).
      expect(changes, [
        ['b', 'c', 'a'],
      ]);
      expect(adds, isEmpty);
      expect(removes, isEmpty);
      expect(find.text('a'), findsOneWidget);
    });

    testWidgets('a drop in place fires nothing (upstream onSortEnd gate)', (
      tester,
    ) async {
      final changes = <List<String>>[];
      await tester.pumpWidget(
        host(
          SemiTagInput(
            draggable: true,
            defaultValue: const ['a', 'b'],
            onChanged: changes.add,
          ),
        ),
      );
      await focusInput(tester);
      final handle = find.byKey(SemiTagInput.dragHandleKey(0));
      final gesture = await tester.startGesture(tester.getCenter(handle));
      await tester.pump();
      await gesture.moveTo(tester.getCenter(handle) + const Offset(2, 0));
      await tester.pump();
      await gesture.up();
      await tester.pump();
      expect(changes, isEmpty);
    });
  });

  group('controlled and uncontrolled', () {
    testWidgets('uncontrolled lands and reports', (tester) async {
      final log = <List<String>>[];
      await tester.pumpWidget(
        host(SemiTagInput(defaultValue: const ['z'], onChanged: log.add)),
      );
      await enterAdd(tester, 'a');
      expect(log, [
        ['z', 'a'],
      ]);
      expect(find.text('z'), findsOneWidget);
      expect(find.text('a'), findsOneWidget);
    });

    testWidgets('controlled reports only; display follows the prop; release '
        'keeps the last controlled value', (tester) async {
      final log = <List<String>>[];
      await tester.pumpWidget(
        host(
          SemiTagInput(value: const ['x'], onChanged: log.add),
          keepState: true,
        ),
      );
      await enterAdd(tester, 'y');
      expect(log, [
        ['x', 'y'],
      ]);
      // not landed (foundation _onAdd controlled branch).
      expect(find.text('y'), findsNothing);
      expect(find.text('x'), findsOneWidget);
      await tester.pumpWidget(
        host(
          SemiTagInput(value: const ['x', 'y'], onChanged: log.add),
          keepState: true,
        ),
      );
      expect(find.text('y'), findsOneWidget);
      // ★ release control keeps the last controlled value (rating precedent).
      await tester.pumpWidget(
        host(SemiTagInput(onChanged: log.add), keepState: true),
      );
      expect(find.text('y'), findsOneWidget);
    });

    testWidgets('inputValue is semi-controlled the same way', (tester) async {
      await tester.pumpWidget(
        host(const SemiTagInput(inputValue: 'abc'), keepState: true),
      );
      expect(inputText(tester), 'abc');
      await tester.pumpWidget(
        host(const SemiTagInput(inputValue: 'hotsoon'), keepState: true),
      );
      expect(inputText(tester), 'hotsoon');
      await tester.pumpWidget(host(const SemiTagInput(), keepState: true));
      expect(inputText(tester), 'hotsoon');
    });
  });

  group('disabled', () {
    testWidgets('blocks close/clear/handles and paints disabled colors', (
      tester,
    ) async {
      final removes = <String>[];
      final changes = <List<String>>[];
      await tester.pumpWidget(
        host(
          SemiTagInput(
            disabled: true,
            showClear: true,
            draggable: true,
            defaultValue: const ['a'],
            onRemove: (value, index) => removes.add('$value@$index'),
            onChanged: changes.add,
          ),
        ),
      );
      final tag = tester.widget<SemiTag>(find.byType(SemiTag).first);
      expect(tag.closable, isFalse);
      expect(tag.textColor, resolved().colorTagInputDisabledTextDefault);
      expect(find.byKey(SemiTagInput.dragHandleKey(0)), findsNothing);
      final gesture = await startMouse(tester);
      await gesture.moveTo(tester.getCenter(find.byKey(SemiTagInput.rootKey)));
      await tester.pumpAndSettle();
      expect(clearVisibility(tester).visible, isFalse);
      expect(
        rootBgDecoration(tester).color,
        resolved().colorTagInputDisabledBg,
      );
      expect(removes, isEmpty);
      expect(changes, isEmpty);
    });
  });

  group('validateStatus', () {
    testWidgets('warning/danger bg+border per default/hover/focus rows', (
      tester,
    ) async {
      final gesture = await startMouse(tester);
      for (final (
            status,
            bgDefault,
            bgHover,
            bgFocus,
            borderDefault,
            borderHover,
            borderFocus,
          )
          in [
            (
              SemiInputStatus.warning,
              resolved().colorTagInputWarningBgDefault,
              resolved().colorTagInputWarningBgHover,
              resolved().colorTagInputWarningBgFocus,
              resolved().colorTagInputWarningBorderDefault,
              resolved().colorTagInputWarningBorderHover,
              resolved().colorTagInputWarningBorderFocus,
            ),
            (
              SemiInputStatus.error,
              resolved().colorTagInputDangerBgDefault,
              resolved().colorTagInputDangerBgHover,
              resolved().colorTagInputDangerBgFocus,
              resolved().colorTagInputDangerBorderDefault,
              resolved().colorTagInputDangerBorderHover,
              resolved().colorTagInputDangerBorderFocus,
            ),
          ]) {
        await tester.pumpWidget(host(SemiTagInput(validateStatus: status)));
        expect(rootBgDecoration(tester).color, bgDefault, reason: '$status');
        expect(rootBorder(tester).top.color, borderDefault);
        await gesture.moveTo(Offset.zero);
        await gesture.moveTo(
          tester.getCenter(find.byKey(SemiTagInput.rootKey)),
        );
        await tester.pumpAndSettle();
        expect(rootBgDecoration(tester).color, bgHover, reason: '$status');
        expect(rootBorder(tester).top.color, borderHover);
        await focusInput(tester);
        expect(rootBgDecoration(tester).color, bgFocus, reason: '$status');
        expect(rootBorder(tester).top.color, borderFocus);
        expect(
          rootBorder(tester).top.width,
          resolved().widthTagInputBorderFocus,
        );
      }
    });

    testWidgets('normal rows: fill-0/fill-1/fill-0 with focus-border', (
      tester,
    ) async {
      await tester.pumpWidget(host(const SemiTagInput()));
      expect(
        rootBgDecoration(tester).color,
        resolved().colorTagInputDefaultBgDefault,
      );
      final gesture = await startMouse(tester);
      await gesture.moveTo(tester.getCenter(find.byKey(SemiTagInput.rootKey)));
      await tester.pumpAndSettle();
      expect(
        rootBgDecoration(tester).color,
        resolved().colorTagInputDefaultBgHover,
      );
      expect(rootBorder(tester).top.color, resolved().colorTagInputBorderHover);
      await focusInput(tester);
      expect(
        rootBgDecoration(tester).color,
        resolved().colorTagInputDefaultBgFocus,
      );
      expect(rootBorder(tester).top.color, resolved().colorTagInputBorderFocus);
    });
  });

  group('prefix, suffix, insetLabel', () {
    testWidgets('prefix wins over insetLabel; tap focuses the input', (
      tester,
    ) async {
      final focusLog = <bool>[];
      await tester.pumpWidget(
        host(
          SemiTagInput(
            prefix: 'Pre',
            suffix: 'Suf',
            insetLabel: 'In',
            onFocusChange: focusLog.add,
          ),
        ),
      );
      expect(find.text('Pre'), findsOneWidget);
      expect(find.text('Suf'), findsOneWidget);
      expect(find.text('In'), findsNothing);
      await tester.tap(find.text('Pre'));
      await tester.pump();
      expect(focusLog, [true]);
    });

    testWidgets('insetLabel strings render bold (font-tagInput_'
        'prefix_suffix-fontWeight)', (tester) async {
      await tester.pumpWidget(host(const SemiTagInput(insetLabel: 'In')));
      final text = tester.widget<Text>(find.text('In'));
      expect(
        text.style!.fontWeight,
        resolved().fontTagInputPrefixSuffixFontWeight,
      );
      expect(text.style!.fontSize, 14.0);
    });
  });

  group('geometry', () {
    testWidgets('three sizes: root min-height 24/32/40, input line 20/24/24', (
      tester,
    ) async {
      const cases = [
        (SemiInputSize.small, 24.0, 20.0),
        (SemiInputSize.normal, 32.0, 24.0),
        (SemiInputSize.large, 40.0, 24.0),
      ];
      for (final (size, rootH, inputH) in cases) {
        await tester.pumpWidget(host(SemiTagInput(size: size)));
        await tester.pumpAndSettle();
        expect(
          tester.getRect(find.byKey(SemiTagInput.rootKey)).height,
          rootH,
          reason: '$size',
        );
        expect(
          tester.getRect(find.byType(SemiInput)).height,
          inputH,
          reason: '$size',
        );
        // Regression: the input text sits VERTICALLY CENTERED — a
        // `TextStyle.height` on the input style scales the baseline down
        // (~2px low; the SemiInput saga, docs/semi_input.md). Natural
        // metrics + the slot's centering keep the text box equidistant.
        final edit = tester.widget<EditableText>(find.byType(EditableText));
        expect(edit.style.height, isNull, reason: '$size');
        final slot = tester.getRect(find.byType(SemiInput));
        final box = tester.getRect(find.byType(EditableText));
        expect(
          (box.top - slot.top) - (slot.bottom - box.bottom),
          moreOrLessEquals(0, epsilon: 0.001),
          reason: '$size input text must sit centered',
        );
      }
    });
  });

  group('cursor map', () {
    bool hasCursor(Finder scope, MouseCursor cursor) => find
        .descendant(
          of: scope,
          matching: find.byWidgetPredicate(
            (w) => w is MouseRegion && w.cursor == cursor,
          ),
        )
        .evaluate()
        .isNotEmpty;

    testWidgets('field shows the I-beam; chips arrow; close hand', (
      tester,
    ) async {
      await tester.pumpWidget(
        host(SemiTagInput(defaultValue: const ['x'], showClear: true)),
      );
      // The root region carries the field-wide I-beam (input.scss:47
      // `cursor: text` upstream; the user-calibrated map).
      expect(
        find.ancestor(
          of: find.byKey(SemiTagInput.rootKey),
          matching: find.byWidgetPredicate(
            (w) => w is MouseRegion && w.cursor == SystemMouseCursors.text,
          ),
        ),
        findsOneWidget,
      );
      // The chip shows the plain arrow; its close button the hand
      // (tag.scss:85 `&-close { cursor: pointer; }`).
      final chip = find.byKey(SemiTagInput.tagKey(0));
      expect(hasCursor(chip, SystemMouseCursors.basic), isTrue);
      expect(hasCursor(chip, SystemMouseCursors.click), isTrue);
    });

    testWidgets('disabled: the field shows not-allowed; chips defer to it', (
      tester,
    ) async {
      await tester.pumpWidget(
        host(const SemiTagInput(defaultValue: ['x'], disabled: true)),
      );
      expect(
        find.ancestor(
          of: find.byKey(SemiTagInput.rootKey),
          matching: find.byWidgetPredicate(
            (w) => w is MouseRegion && w.cursor == SystemMouseCursors.forbidden,
          ),
        ),
        findsOneWidget,
      );
      expect(
        hasCursor(find.byKey(SemiTagInput.tagKey(0)), SystemMouseCursors.basic),
        isFalse,
      );
    });
  });

  group('RTL', () {
    testWidgets('tag margin flips (margin-left 4 / margin-right 0)', (
      tester,
    ) async {
      await tester.pumpWidget(
        host(
          const SemiTagInput(defaultValue: ['a']),
          direction: TextDirection.ltr,
        ),
      );
      final root = tester.getRect(find.byKey(SemiTagInput.rootKey));
      final slot = tester.getRect(find.byKey(SemiTagInput.tagKey(0)));
      final tag = tester.getRect(find.byType(SemiTag).first);
      // LTR: 4px wrapper padding at the start, 4px end margin on the right.
      expect(slot.left - root.left, 4.0);
      expect(slot.right - tag.right, 4.0);
      await tester.pumpWidget(
        host(
          const SemiTagInput(defaultValue: ['a']),
          direction: TextDirection.rtl,
        ),
      );
      final rootRtl = tester.getRect(find.byKey(SemiTagInput.rootKey));
      final slotRtl = tester.getRect(find.byKey(SemiTagInput.tagKey(0)));
      final tagRtl = tester.getRect(find.byType(SemiTag).first);
      // RTL: the end margin lands on the left (margin-left 4 / margin-right 0).
      expect(rootRtl.right - slotRtl.right, 4.0);
      expect(tagRtl.left - slotRtl.left, 4.0);
    });
  });

  group('semantics', () {
    testWidgets('enabled=!disabled; ★invalid only for error; input label', (
      tester,
    ) async {
      Semantics rootSemantics(WidgetTester tester) => tester.widget<Semantics>(
        find.byWidgetPredicate((w) => w is Semantics && w.container),
      );
      await tester.pumpWidget(host(const SemiTagInput(semanticsLabel: 'tags')));
      expect(rootSemantics(tester).properties.enabled, true);
      expect(
        rootSemantics(tester).properties.validationResult,
        SemanticsValidationResult.none,
      );
      expect(
        tester.widget<SemiInput>(find.byType(SemiInput)).semanticsLabel,
        'tags',
      );
      await tester.pumpWidget(
        host(const SemiTagInput(validateStatus: SemiInputStatus.error)),
      );
      // ★ upstream `aria-invalid` only for error.
      expect(
        rootSemantics(tester).properties.validationResult,
        SemanticsValidationResult.invalid,
      );
      await tester.pumpWidget(
        host(const SemiTagInput(validateStatus: SemiInputStatus.warning)),
      );
      expect(
        rootSemantics(tester).properties.validationResult,
        SemanticsValidationResult.none,
      );
      await tester.pumpWidget(host(const SemiTagInput(disabled: true)));
      expect(rootSemantics(tester).properties.enabled, false);
    });
  });

  group('controller', () {
    testWidgets('focus/blur toggle handles; detached calls are no-ops', (
      tester,
    ) async {
      final controller = SemiTagInputController();
      await tester.pumpWidget(
        host(
          SemiTagInput(
            controller: controller,
            draggable: true,
            defaultValue: const ['a'],
          ),
        ),
      );
      expect(find.byKey(SemiTagInput.dragHandleKey(0)), findsNothing);
      controller.focus();
      // ★ programmatic focus applies mid-frame — the state rebuild (handles)
      // lands on the following frame.
      await tester.pumpAndSettle();
      expect(find.byKey(SemiTagInput.dragHandleKey(0)), findsOneWidget);
      controller.blur();
      await tester.pumpAndSettle();
      expect(find.byKey(SemiTagInput.dragHandleKey(0)), findsNothing);
      // detach: further calls are silent no-ops.
      await tester.pumpWidget(host(const SemiTagInput()));
      controller.focus();
      controller.blur();
      await tester.pump();
    });
  });

  group('addOnBlur, renderTagItem and showContentTooltip', () {
    testWidgets('addOnBlur commits the pending text on blur', (tester) async {
      final log = <List<String>>[];
      final inputs = <String>[];
      await tester.pumpWidget(
        host(
          SemiTagInput(
            addOnBlur: true,
            defaultValue: const [],
            onChanged: log.add,
            onInputChange: inputs.add,
          ),
        ),
      );
      await focusInput(tester);
      await tester.enterText(find.byType(EditableText), 'a, b');
      await tester.pump();
      // Blur explicitly (the bare test host has no tap-to-dismiss scope).
      tester.binding.focusManager.primaryFocus?.unfocus();
      await tester.pump();
      // ★ trim-tested but kept untrimmed (' b' keeps its space).
      expect(log, [
        ['a', ' b'],
      ]);
      // ★ the add flow always ends with the empty-input report
      // (foundation.ts:210).
      expect(inputs.last, '');
    });

    testWidgets('renderTagItem replaces the default tag; onClose removes', (
      tester,
    ) async {
      await tester.pumpWidget(
        host(
          SemiTagInput(
            defaultValue: const ['x'],
            renderTagItem: (value, index, onClose) => GestureDetector(
              key: ValueKey('custom-$index'),
              onTap: onClose,
              child: Text('T:$value'),
            ),
          ),
        ),
      );
      expect(find.text('T:x'), findsOneWidget);
      expect(find.byType(SemiTag), findsNothing);
      await tester.tap(find.byKey(const ValueKey('custom-0')));
      await tester.pump();
      expect(find.text('T:x'), findsNothing);
    });

    testWidgets('showContentTooltip wraps the default tag in a hover tooltip', (
      tester,
    ) async {
      await tester.pumpWidget(host(const SemiTagInput(defaultValue: ['x'])));
      expect(
        find.ancestor(
          of: find.byKey(const ValueKey('SemiTagInput.tag<0>:x')),
          matching: find.byType(SemiTooltip),
        ),
        findsOneWidget,
      );
      await tester.pumpWidget(
        host(
          const SemiTagInput(defaultValue: ['x'], showContentTooltip: false),
        ),
      );
      expect(find.byType(SemiTooltip), findsNothing);
    });
  });

  group('theme fields (49 + 6 + 0)', () {
    test('55 fields: merge, copyWith, resolve, equality, defaults', () {
      expect(fields, hasLength(55));
      expect(
        fields.where((f) => f.$1.startsWith(r'$transition_')),
        hasLength(6),
      );
      expect(
        fields.where((f) => !f.$1.startsWith(r'$transition_')),
        hasLength(49),
      );
      for (final (sass, value, make, read, expected) in fields) {
        final patch = make(value);
        expect(const SemiTagInputThemeData().merge(patch), patch, reason: sass);
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
          read(const SemiTagInputThemeData().resolve(light)),
          expected(light),
          reason: sass,
        );
        final dark = const SemiThemeData.dark();
        expect(
          read(const SemiTagInputThemeData().resolve(dark)),
          expected(dark),
          reason: sass,
        );
      }
    });

    test('every field carries its Sass provenance in the generated source', () {
      final source = File('lib/src/theme/semi_tag_input_theme_data.dart')
          .readAsStringSync();
      final names = <String>{};
      for (final (sass, _, _, _, _) in fields) {
        expect(source, contains(sass));
        names.add(sass.split(': ').first.substring(1));
      }
      expect(names, hasLength(55));
      // ★ the trailing-space quirk and the `!default` marker survive verbatim.
      expect(source, contains(r'$color-tagInput-border-hover: transparent '));
      expect(source, contains(r'$z-tagInput_drag_item_move: 2000 !default'));
    });

    test('the 6 HARDCODES anchors live in the widget; dead fields never '
        'consumed', () {
      final widgetSource = File('lib/src/components/semi_tag_input.dart')
          .readAsStringSync();
      const anchors = [
        'display: flex; justify-content: center; align-items: center;',
        'line-height: 20px',
        'scrollWidth + 2',
        'lineHeight: 0',
        'min-width: 2px',
        'var(--semi-color-text-0)',
      ];
      for (final anchor in anchors) {
        expect(widgetSource, contains(anchor), reason: anchor);
      }
      // The two effectively-dead fields are never consumed (net effect
      // faithful: the +N chip hardcodes text-0; prefix text rides the
      // `-prefix-default` channel).
      expect(widgetSource, isNot(contains('colorTagInputMaxTagCountDefault')));
      expect(widgetSource, isNot(contains('colorTagInputPrefixTextDefault')));
    });

    test('type coverage: 28 Color + 20 double + 1 FontWeight + 4 Duration + '
        '2 Curve', () {
      final counts = <String, int>{};
      for (final (_, value, _, _, _) in fields) {
        counts.update(
          value.runtimeType.toString(),
          (n) => n + 1,
          ifAbsent: () => 1,
        );
      }
      expect(counts['Color'], 28);
      expect(counts['double'], 20);
      expect(counts['FontWeight'], 1);
      expect(counts['Duration'], 4);
      expect(fields.where((f) => f.$2 is Curve), hasLength(2));
    });

    test('SemiComponentThemes wiring', () {
      expect(
        const SemiComponentThemes().tagInput,
        const SemiTagInputThemeData(),
      );
      const patch = SemiTagInputThemeData(
        colorTagInputDefaultBgDefault: Color(0xff123456),
      );
      const themes = SemiComponentThemes(tagInput: patch);
      expect(const SemiComponentThemes().copyWith(tagInput: patch), themes);
      expect(themes == const SemiComponentThemes(), isFalse);
      expect(themes.tagInput, patch);
    });

    testWidgets('SemiTagInputTheme local patch applies (nested merge, inner '
        'wins its own field)', (tester) async {
      await tester.pumpWidget(
        SemiTheme(
          data: const SemiThemeData.light(),
          child: SemiTagInputTheme(
            data: const SemiTagInputThemeData(heightTagInputDefault: 48),
            child: Directionality(
              textDirection: TextDirection.ltr,
              child: Center(
                child: SizedBox(
                  width: 400,
                  child: SemiTagInputTheme(
                    data: const SemiTagInputThemeData(
                      heightTagInputInputDefault: 30,
                    ),
                    child: const SemiTagInput(),
                  ),
                ),
              ),
            ),
          ),
        ),
      );
      // Outer patch field (root min-height) still applies; the inner patch
      // wins its own field (input line height) only.
      expect(tester.getRect(find.byKey(SemiTagInput.rootKey)).height, 48.0);
      expect(tester.getRect(find.byType(SemiInput)).height, 30.0);
    });
  });
}
