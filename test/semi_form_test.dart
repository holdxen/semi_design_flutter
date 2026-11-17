// Behavior matrix for SemiForm plus coverage for the 40 Sass declarations
// (40 FIELDS + 0 MOTION + 0 INTERNAL) — the 13 HARDCODES provenance anchors
// live in the widget's `_FormMetrics` / call sites. ★0 死变量.
import 'dart:async';
import 'dart:io';

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:semi_design_flutter/semi_design_flutter.dart';

final _hostBody = ValueNotifier<Widget>(const SizedBox.shrink());

Widget host(Widget child) {
  _hostBody.value = KeyedSubtree(key: UniqueKey(), child: child);
  return SemiTheme(
    data: const SemiThemeData.light(),
    child: Directionality(
      textDirection: TextDirection.ltr,
      child: MediaQuery(
        data: const MediaQueryData(size: Size(1200, 900)),
        child: Overlay(
          initialEntries: [
            OverlayEntry(
              builder: (context) => ValueListenableBuilder<Widget>(
                valueListenable: _hostBody,
                builder: (context, child, _) => Center(
                  child: SizedBox(width: 480, height: 720, child: child),
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

Future<void> pumpHost(WidgetTester tester, Widget child) async {
  await tester.binding.setSurfaceSize(const Size(1200, 1200));
  await tester.pumpWidget(host(child));
}

typedef _Patch = SemiFormThemeData Function(Object v);
typedef _Read = Object? Function(SemiResolvedFormThemeData d);
typedef _Expected = Object? Function(SemiThemeData t);

final List<(String, Object, _Patch, _Read, _Expected)> fields = [
  (
    r'$spacing-form_field_horizontal-paddingRight: $spacing-base',
    1000.25,
    (v) =>
        SemiFormThemeData(spacingFormFieldHorizontalPaddingRight: v as double),
    (d) => d.spacingFormFieldHorizontalPaddingRight,
    (t) => 16.0,
  ),
  (
    r'$spacing-form_field_group_horizontal-paddingRight: $spacing-base',
    1000.75,
    (v) => SemiFormThemeData(
      spacingFormFieldGroupHorizontalPaddingRight: v as double,
    ),
    (d) => d.spacingFormFieldGroupHorizontalPaddingRight,
    (t) => 16.0,
  ),
  (
    r'$spacing-form_field_vertical-paddingTop: $spacing-base-tight',
    1001.25,
    (v) => SemiFormThemeData(spacingFormFieldVerticalPaddingTop: v as double),
    (d) => d.spacingFormFieldVerticalPaddingTop,
    (t) => 12.0,
  ),
  (
    r'$spacing-form_field_vertical-paddingBottom: $spacing-base-tight',
    1001.75,
    (v) =>
        SemiFormThemeData(spacingFormFieldVerticalPaddingBottom: v as double),
    (d) => d.spacingFormFieldVerticalPaddingBottom,
    (t) => 12.0,
  ),
  (
    r'$spacing-form_field_group_vertical-paddingTop: $spacing-base-tight',
    1002.25,
    (v) =>
        SemiFormThemeData(spacingFormFieldGroupVerticalPaddingTop: v as double),
    (d) => d.spacingFormFieldGroupVerticalPaddingTop,
    (t) => 12.0,
  ),
  (
    r'$spacing-form_field_group_vertical-paddingBottom: $spacing-base-tight',
    1002.75,
    (v) => SemiFormThemeData(
      spacingFormFieldGroupVerticalPaddingBottom: v as double,
    ),
    (d) => d.spacingFormFieldGroupVerticalPaddingBottom,
    (t) => 12.0,
  ),
  (
    r'$spacing-form_label-paddingRight: $spacing-base',
    1003.25,
    (v) => SemiFormThemeData(spacingFormLabelPaddingRight: v as double),
    (d) => d.spacingFormLabelPaddingRight,
    (t) => 16.0,
  ),
  (
    r'$spacing-form_label-paddingTop: ($height-control-default - 20px) * 0.5',
    1003.75,
    (v) => SemiFormThemeData(spacingFormLabelPaddingTop: v as double),
    (d) => d.spacingFormLabelPaddingTop,
    (t) => 6.0,
  ),
  (
    r'$spacing-form_label-marginBottom: $spacing-extra-tight',
    1004.25,
    (v) => SemiFormThemeData(spacingFormLabelMarginBottom: v as double),
    (d) => d.spacingFormLabelMarginBottom,
    (t) => 4.0,
  ),
  (
    r'$spacing-form_label-marginTop: 0px',
    1004.75,
    (v) => SemiFormThemeData(spacingFormLabelMarginTop: v as double),
    (d) => d.spacingFormLabelMarginTop,
    (t) => 0.0,
  ),
  (
    r'$spacing-form_label_extra-marginLeft: $spacing-extra-tight',
    1005.25,
    (v) => SemiFormThemeData(spacingFormLabelExtraMarginLeft: v as double),
    (d) => d.spacingFormLabelExtraMarginLeft,
    (t) => 4.0,
  ),
  (
    r'$spacing-form_label_required-marginLeft: $spacing-extra-tight',
    1005.75,
    (v) => SemiFormThemeData(spacingFormLabelRequiredMarginLeft: v as double),
    (d) => d.spacingFormLabelRequiredMarginLeft,
    (t) => 4.0,
  ),
  (
    r'$spacing-form_label_posLeft-marginRight: 0',
    1006.25,
    (v) => SemiFormThemeData(spacingFormLabelPosLeftMarginRight: v as double),
    (d) => d.spacingFormLabelPosLeftMarginRight,
    (t) => 0.0,
  ),
  (
    r'$spacing-form_label_posLeft-marginBottom: 0',
    1006.75,
    (v) => SemiFormThemeData(spacingFormLabelPosLeftMarginBottom: v as double),
    (d) => d.spacingFormLabelPosLeftMarginBottom,
    (t) => 0.0,
  ),
  (
    r'$spacing-form_label_posTop-paddingTop: $spacing-extra-tight',
    1007.25,
    (v) => SemiFormThemeData(spacingFormLabelPosTopPaddingTop: v as double),
    (d) => d.spacingFormLabelPosTopPaddingTop,
    (t) => 4.0,
  ),
  (
    r'$spacing-form_label_posTop-paddingBottom: $spacing-extra-tight',
    1007.75,
    (v) => SemiFormThemeData(spacingFormLabelPosTopPaddingBottom: v as double),
    (d) => d.spacingFormLabelPosTopPaddingBottom,
    (t) => 4.0,
  ),
  (
    r'$spacing-form_extra_posMid-marginTop: $spacing-extra-tight',
    1008.25,
    (v) => SemiFormThemeData(spacingFormExtraPosMidMarginTop: v as double),
    (d) => d.spacingFormExtraPosMidMarginTop,
    (t) => 4.0,
  ),
  (
    r'$spacing-form_extra_posMid-marginBottom: $spacing-extra-tight',
    1008.75,
    (v) => SemiFormThemeData(spacingFormExtraPosMidMarginBottom: v as double),
    (d) => d.spacingFormExtraPosMidMarginBottom,
    (t) => 4.0,
  ),
  (
    r'$spacing-form_extra_posBottom-marginTop: $spacing-extra-tight',
    1009.25,
    (v) => SemiFormThemeData(spacingFormExtraPosBottomMarginTop: v as double),
    (d) => d.spacingFormExtraPosBottomMarginTop,
    (t) => 4.0,
  ),
  (
    r'$spacing-form_switch_rating_marginY: ($height-control-default - 24px) * 0.5',
    1009.75,
    (v) => SemiFormThemeData(spacingFormSwitchRatingMarginY: v as double),
    (d) => d.spacingFormSwitchRatingMarginY,
    (t) => 4.0,
  ),
  (
    r'$color-form_requiredMark_disabled-text-default: var(--semi-color-danger)',
    const Color(0xFF000001),
    (v) =>
        SemiFormThemeData(colorFormRequiredMarkDisabledTextDefault: v as Color),
    (d) => d.colorFormRequiredMarkDisabledTextDefault,
    (t) => t.colors.colorDanger,
  ),
  (
    r'$color-form_label_disabled-text-default: var(--semi-color-disabled-text)',
    const Color(0xFF000002),
    (v) => SemiFormThemeData(colorFormLabelDisabledTextDefault: v as Color),
    (d) => d.colorFormLabelDisabledTextDefault,
    (t) => t.colors.colorDisabledText,
  ),
  (
    r'$font-form_label-fontWeight: $font-weight-bold',
    FontWeight.w600,
    (v) => SemiFormThemeData(fontFormLabelFontWeight: v as FontWeight),
    (d) => d.fontFormLabelFontWeight,
    (t) => t.typography.fontWeightBold,
  ),
  (
    r'$color-form_label-text-default: var(--semi-color-text-0)',
    const Color(0xFF000003),
    (v) => SemiFormThemeData(colorFormLabelTextDefault: v as Color),
    (d) => d.colorFormLabelTextDefault,
    (t) => t.colors.colorText0,
  ),
  (
    r'$color-form_label_optional-text-default: var(--semi-color-tertiary)',
    const Color(0xFF000004),
    (v) => SemiFormThemeData(colorFormLabelOptionalTextDefault: v as Color),
    (d) => d.colorFormLabelOptionalTextDefault,
    (t) => t.colors.colorTertiary,
  ),
  (
    r'$color-form_label_extra-text-default: var(--semi-color-tertiary)',
    const Color(0xFF000005),
    (v) => SemiFormThemeData(colorFormLabelExtraTextDefault: v as Color),
    (d) => d.colorFormLabelExtraTextDefault,
    (t) => t.colors.colorTertiary,
  ),
  (
    r'$color-form_requiredMark-text-default: var(--semi-color-danger)',
    const Color(0xFF000006),
    (v) => SemiFormThemeData(colorFormRequiredMarkTextDefault: v as Color),
    (d) => d.colorFormRequiredMarkTextDefault,
    (t) => t.colors.colorDanger,
  ),
  (
    r'$font-form_requiredMark-fontWeight: $font-weight-bold',
    FontWeight.w700,
    (v) => SemiFormThemeData(fontFormRequiredMarkFontWeight: v as FontWeight),
    (d) => d.fontFormRequiredMarkFontWeight,
    (t) => t.typography.fontWeightBold,
  ),
  (
    r'$color-form_message_error-text-default: var(--semi-color-danger)',
    const Color(0xFF000007),
    (v) => SemiFormThemeData(colorFormMessageErrorTextDefault: v as Color),
    (d) => d.colorFormMessageErrorTextDefault,
    (t) => t.colors.colorDanger,
  ),
  (
    r'$color-form_alertIcon-icon-default: var(--semi-color-warning)',
    const Color(0xFF000008),
    (v) => SemiFormThemeData(colorFormAlertIconIconDefault: v as Color),
    (d) => d.colorFormAlertIconIconDefault,
    (t) => t.colors.colorWarning,
  ),
  (
    r'$spacing-form_statusIcon-marginRight: $spacing-extra-tight',
    1010.25,
    (v) => SemiFormThemeData(spacingFormStatusIconMarginRight: v as double),
    (d) => d.spacingFormStatusIconMarginRight,
    (t) => 4.0,
  ),
  (
    r'$spacing-form_message-marginTop: $spacing-extra-tight',
    1010.75,
    (v) => SemiFormThemeData(spacingFormMessageMarginTop: v as double),
    (d) => d.spacingFormMessageMarginTop,
    (t) => 4.0,
  ),
  (
    r'$color-form_section-text-default: var(--semi-color-text-0)',
    const Color(0xFF000009),
    (v) => SemiFormThemeData(colorFormSectionTextDefault: v as Color),
    (d) => d.colorFormSectionTextDefault,
    (t) => t.colors.colorText0,
  ),
  (
    r'$color-form_section-border-default: var(--semi-color-border)',
    const Color(0xFF00000A),
    (v) => SemiFormThemeData(colorFormSectionBorderDefault: v as Color),
    (d) => d.colorFormSectionBorderDefault,
    (t) => t.colors.colorBorder,
  ),
  (
    r'$width-form_section-border: $border-thickness-control',
    1011.25,
    (v) => SemiFormThemeData(widthFormSectionBorder: v as double),
    (d) => d.widthFormSectionBorder,
    (t) => 1.0,
  ),
  (
    r'$spacing-form_section-marginTop: $spacing-super-loose - $spacing-base-tight',
    1011.75,
    (v) => SemiFormThemeData(spacingFormSectionMarginTop: v as double),
    (d) => d.spacingFormSectionMarginTop,
    (t) => 28.0,
  ),
  (
    r'$spacing-form_section_text-paddingBottom: $spacing-tight',
    1012.25,
    (v) => SemiFormThemeData(spacingFormSectionTextPaddingBottom: v as double),
    (d) => d.spacingFormSectionTextPaddingBottom,
    (t) => 8.0,
  ),
  (
    r'$spacing-form_section_text-marginBottom: $spacing-extra-tight',
    1012.75,
    (v) => SemiFormThemeData(spacingFormSectionTextMarginBottom: v as double),
    (d) => d.spacingFormSectionTextMarginBottom,
    (t) => 4.0,
  ),
  (
    r'$spacing-form_section_text-paddingTop: 0px',
    1013.25,
    (v) => SemiFormThemeData(spacingFormSectionTextPaddingTop: v as double),
    (d) => d.spacingFormSectionTextPaddingTop,
    (t) => 0.0,
  ),
  (
    r'$spacing-form_section_text-marginTop: 0px',
    1013.75,
    (v) => SemiFormThemeData(spacingFormSectionTextMarginTop: v as double),
    (d) => d.spacingFormSectionTextMarginTop,
    (t) => 0.0,
  ),
];

String _kindOf(Object v) => switch (v) {
  Color() => 'Color',
  double() => 'double',
  FontWeight() => 'FontWeight',
  _ => 'other',
};

void main() {
  group('theme fields (40 = 40 FIELDS + 0 MOTION + 0 INTERNAL)', () {
    test('40 fields: merge, copyWith, resolve, equality, defaults', () {
      expect(fields, hasLength(40));
      for (final (sass, value, make, read, expected) in fields) {
        final patch = make(value);
        expect(const SemiFormThemeData().merge(patch), patch, reason: sass);
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
          read(const SemiFormThemeData().resolve(light)),
          expected(light),
          reason: sass,
        );
        final dark = const SemiThemeData.dark();
        expect(
          read(const SemiFormThemeData().resolve(dark)),
          expected(dark),
          reason: sass,
        );
      }
    });

    test('every field carries its Sass provenance in the generated source', () {
      final source = File('lib/src/theme/semi_form_theme_data.dart')
          .readAsStringSync();
      final names = <String>{};
      for (final (sass, _, _, _, _) in fields) {
        expect(source, contains(sass));
        names.add(sass.split(': ').first.substring(1));
      }
      expect(names, hasLength(40));
      // ★算术默认值 + `0`/`0px` 混用原文照抄。
      expect(
        source,
        contains(
          r'$spacing-form_label-paddingTop: ($height-control-default - 20px) * 0.5',
        ),
      );
      expect(
        source,
        contains(
          r'$spacing-form_switch_rating_marginY: ($height-control-default - 24px) * 0.5',
        ),
      );
      expect(
        source,
        contains(
          r'$spacing-form_section-marginTop: $spacing-super-loose - $spacing-base-tight',
        ),
      );
      expect(source, contains(r'$spacing-form_label_posLeft-marginRight: 0'));
      expect(source, contains('packages/semi-foundation/form/variables.scss'));
      expect(source, contains('Generated by tool/generate_form.py'));
    });

    test('the 13 HARDCODES anchors live in the widget source', () {
      final widgetSource = File('lib/src/components/semi_form.dart')
          .readAsStringSync();
      const anchors = <String>[
        "DEFAULT_TRIGGER: 'change'",
        "optional: '（可选）'",
        'content: "*"',
        '<IconAlertTriangle />',
        '<IconAlertCircle />',
        "behavior: 'smooth'",
        "block: 'start'",
        '@include font-size-regular',
        '@include font-size-header-5',
        'getUuidv4',
        'first: mergeStopValidateWithError',
        "message: ''",
        "labelPosition: 'top'",
      ];
      expect(anchors, hasLength(13));
      for (final anchor in anchors) {
        expect(widgetSource, contains(anchor), reason: anchor);
      }
    });

    test('type coverage: 10 Color + 28 double + 2 FontWeight = 40', () {
      final counts = <String, int>{};
      for (final (_, value, _, _, _) in fields) {
        counts.update(_kindOf(value), (n) => n + 1, ifAbsent: () => 1);
      }
      expect(counts['Color'], 10);
      expect(counts['double'], 28);
      expect(counts['FontWeight'], 2);
    });

    test('0 dead variables; docs mark the accounting', () {
      final docs = File('docs/semi_form.md').readAsStringSync();
      expect(docs, contains('40 = 40 FIELDS + 0 MOTION + 0 INTERNAL'));
      expect(docs, contains('0 死变量'));
    });

    test('SemiComponentThemes wiring', () {
      const themes = SemiComponentThemes();
      expect(themes.form, const SemiFormThemeData());
      expect(
        themes.copyWith(
          form: const SemiFormThemeData(widthFormSectionBorder: 3),
        ),
        const SemiComponentThemes(
          form: SemiFormThemeData(widthFormSectionBorder: 3),
        ),
      );
    });
  });

  group('behavior', () {
    testWidgets('initValues seed the form; field initValue takes precedence', (
      tester,
    ) async {
      final controller = SemiFormController();
      await pumpHost(
        tester,
        SemiForm(
          controller: controller,
          initValues: const {'name': 'form-name', 'city': 'form-city'},
          child: Column(
            children: [
              SemiFormInput(
                field: 'name',
                label: '名称',
                initValue: 'field-name',
              ),
              SemiFormInput(field: 'city', label: '城市'),
            ],
          ),
        ),
      );
      expect(controller.getValue('name'), 'field-name');
      expect(controller.getValue('city'), 'form-city');
    });

    testWidgets('change trigger validates; required error shows and clears', (
      tester,
    ) async {
      final controller = SemiFormController();
      await pumpHost(
        tester,
        SemiForm(
          controller: controller,
          child: SemiFormInput(
            field: 'name',
            label: '名称',
            rules: const [SemiFormFieldRule(required: true)],
          ),
        ),
      );
      await tester.enterText(find.byType(SemiInput), 'x');
      await tester.pump();
      expect(controller.getError('name'), isNull);
      await tester.enterText(find.byType(SemiInput), '');
      await tester.pump();
      expect(controller.getError('name'), 'name is required');
      expect(find.text('name is required'), findsOneWidget);
    });

    testWidgets('custom validator sync and async', (tester) async {
      final controller = SemiFormController();
      await pumpHost(
        tester,
        SemiForm(
          controller: controller,
          child: Column(
            children: [
              SemiFormInput(
                field: 'sync',
                label: '同步',
                validator: (v, values) => v == 'ok' ? '' : 'not ok',
              ),
              SemiFormInput(
                field: 'async',
                label: '异步',
                validator: (v, values) async => v == 'ok' ? '' : 'async bad',
              ),
            ],
          ),
        ),
      );
      await tester.enterText(find.byType(SemiInput).at(0), 'no');
      await tester.pumpAndSettle();
      expect(controller.getError('sync'), 'not ok');
      await tester.enterText(find.byType(SemiInput).at(1), 'no');
      await tester.pumpAndSettle();
      expect(controller.getError('async'), 'async bad');
    });

    testWidgets('stale async validation results are discarded', (tester) async {
      final controller = SemiFormController();
      final gates = <Completer<String>>[];
      await pumpHost(
        tester,
        SemiForm(
          controller: controller,
          child: SemiFormInput(
            field: 'name',
            label: '名称',
            validator: (v, values) {
              final gate = Completer<String>();
              gates.add(gate);
              return gate.future;
            },
          ),
        ),
      );
      await tester.enterText(find.byType(SemiInput), 'a');
      await tester.pump();
      await tester.enterText(find.byType(SemiInput), 'ab');
      await tester.pump();
      expect(gates, hasLength(2));
      // 旧校验先完成——过期结果必须作废（M4 验收：旧结果不覆盖新值）。
      gates[0].complete('stale error');
      await tester.pumpAndSettle();
      expect(controller.getError('name'), isNull);
      expect(find.text('stale error'), findsNothing);
      gates[1].complete('current error');
      await tester.pumpAndSettle();
      expect(controller.getError('name'), 'current error');
    });

    testWidgets('blur trigger defers validation until blur', (tester) async {
      final controller = SemiFormController();
      await pumpHost(
        tester,
        SemiForm(
          controller: controller,
          child: SemiFormInput(
            field: 'name',
            label: '名称',
            trigger: SemiFormTrigger.blur,
            rules: const [SemiFormFieldRule(required: true)],
          ),
        ),
      );
      await tester.enterText(find.byType(SemiInput), '');
      await tester.pump();
      expect(controller.getError('name'), isNull); // change 不触发
      // blur 路径：手动校验模拟失焦（trigger: blur 口径）。
      try {
        await controller.validate(fields: ['name']);
      } catch (_) {}
      await tester.pumpAndSettle();
      expect(controller.getError('name'), 'name is required');
    });

    testWidgets('mount trigger validates once on mount', (tester) async {
      final controller = SemiFormController();
      await pumpHost(
        tester,
        SemiForm(
          controller: controller,
          child: SemiFormInput(
            field: 'name',
            label: '名称',
            trigger: SemiFormTrigger.mount,
            rules: const [SemiFormFieldRule(required: true)],
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(controller.getError('name'), 'name is required');
    });

    testWidgets('submit reports onSubmit or onSubmitFail', (tester) async {
      final controller = SemiFormController();
      Object? submitted;
      Map<String, Object?>? failed;
      await pumpHost(
        tester,
        SemiForm(
          controller: controller,
          onSubmit: (values) => submitted = values,
          onSubmitFail: (errors, values) => failed = errors,
          child: SemiFormInput(
            field: 'name',
            label: '名称',
            rules: const [SemiFormFieldRule(required: true)],
          ),
        ),
      );
      controller.submitForm();
      await tester.pumpAndSettle();
      expect(submitted, isNull);
      expect(failed, isNotNull);
      expect(failed!['name'], 'name is required');
      await tester.enterText(find.byType(SemiInput), 'ok');
      await tester.pumpAndSettle();
      controller.submitForm();
      await tester.pumpAndSettle();
      expect(submitted, {'name': 'ok'});
    });

    testWidgets('reset restores initValue and clears errors; partial reset', (
      tester,
    ) async {
      final controller = SemiFormController();
      await pumpHost(
        tester,
        SemiForm(
          controller: controller,
          initValues: const {'a': 'init-a', 'b': 'init-b'},
          child: Column(
            children: [
              SemiFormInput(
                field: 'a',
                label: 'A',
                rules: const [SemiFormFieldRule(required: true)],
              ),
              SemiFormInput(field: 'b', label: 'B'),
            ],
          ),
        ),
      );
      await tester.enterText(find.byType(SemiInput).at(0), '');
      await tester.enterText(find.byType(SemiInput).at(1), 'x');
      await tester.pump();
      expect(
        controller.getError('a'),
        'name is required'.replaceFirst('name', 'a'),
      );
      controller.reset();
      await tester.pumpAndSettle();
      expect(controller.getValue('a'), 'init-a');
      expect(controller.getValue('b'), 'init-b');
      expect(controller.getError('a'), isNull);
      // 部分重置：只动 a。
      await tester.enterText(find.byType(SemiInput).at(0), 'zz');
      await tester.pump();
      controller.reset(['a']);
      await tester.pumpAndSettle();
      expect(controller.getValue('a'), 'init-a');
    });

    testWidgets('FormApi set/get values, setValues merge/override, errors, '
        'touched, fieldExist', (tester) async {
      final controller = SemiFormController();
      await pumpHost(
        tester,
        SemiForm(
          controller: controller,
          initValues: const {
            'a': '1',
            'nested': {'x': 'nx'},
          },
          child: Column(
            children: [
              SemiFormInput(field: 'a', label: 'A'),
              SemiFormInput(field: 'nested.x', label: 'X'),
            ],
          ),
        ),
      );
      expect(controller.getFieldExist('a'), isTrue);
      expect(controller.getFieldExist('zzz'), isFalse);
      expect(controller.getValue('nested.x'), 'nx');
      controller.setValue('a', '2');
      await tester.pumpAndSettle();
      expect(controller.getValue('a'), '2');
      controller.setValues({'a': '3'});
      await tester.pumpAndSettle();
      expect(controller.getValues(), {
        'a': '3',
        'nested': {'x': 'nx'},
      });
      controller.setValues({'zzz': 'new'}, isOverride: true);
      await tester.pumpAndSettle();
      expect(controller.getValue('zzz'), 'new');
      controller.setError('a', 'boom');
      await tester.pumpAndSettle();
      expect(controller.getError('a'), 'boom');
      expect(find.text('boom'), findsOneWidget);
      controller.setTouched('a', true);
      expect(controller.getTouched('a'), isTrue);
    });

    testWidgets('rules: required/enum/pattern/min/max/len/whitespace/number', (
      tester,
    ) async {
      final controller = SemiFormController();
      await pumpHost(
        tester,
        SemiForm(
          controller: controller,
          child: Column(
            children: [
              SemiFormInput(
                field: 'enum',
                label: '枚举',
                rules: const [
                  SemiFormFieldRule(
                    type: SemiFormFieldRuleType.enum_,
                    values: ['a', 'b'],
                    message: 'must be a/b',
                  ),
                ],
              ),
              SemiFormInput(
                field: 'len',
                label: '长度',
                rules: const [SemiFormFieldRule(len: 3, message: 'need 3')],
              ),
              SemiFormInput(
                field: 'num',
                label: '数字',
                rules: const [
                  SemiFormFieldRule(
                    type: SemiFormFieldRuleType.number,
                    min: 10,
                    max: 20,
                    message: '10-20',
                  ),
                ],
              ),
              SemiFormInput(
                field: 'ws',
                label: '空白',
                rules: const [
                  SemiFormFieldRule(
                    required: true,
                    whitespace: true,
                    message: 'not blank',
                  ),
                ],
              ),
            ],
          ),
        ),
      );
      await tester.enterText(find.byType(SemiInput).at(0), 'c');
      await tester.enterText(find.byType(SemiInput).at(1), 'ab');
      await tester.enterText(find.byType(SemiInput).at(2), '5');
      await tester.enterText(find.byType(SemiInput).at(3), '   ');
      await tester.pumpAndSettle();
      expect(controller.getError('enum'), 'must be a/b');
      expect(controller.getError('len'), 'need 3');
      expect(controller.getError('num'), '10-20');
      expect(controller.getError('ws'), 'not blank');
    });

    testWidgets('emptyValue semantics and allowEmptyString', (tester) async {
      final controller = SemiFormController();
      await pumpHost(
        tester,
        SemiForm(
          controller: controller,
          child: Column(
            children: [
              SemiFormInput(field: 'plain', label: '普通'),
              SemiFormInput(field: 'kept', label: '保留', allowEmptyString: true),
            ],
          ),
        ),
      );
      await tester.enterText(find.byType(SemiInput).at(0), 'x');
      await tester.enterText(find.byType(SemiInput).at(1), 'x');
      await tester.pump();
      await tester.enterText(find.byType(SemiInput).at(0), '');
      await tester.enterText(find.byType(SemiInput).at(1), '');
      await tester.pump();
      // emptyValue '' 归一 null——allowEmpty 缺省时键不入 values。
      expect(_pathHasPublic(controller.getValues(), 'plain'), isFalse);
      expect(controller.getValue('kept'), '');
    });

    testWidgets('transform runs before validate; convert before store', (
      tester,
    ) async {
      final controller = SemiFormController();
      Object? validated;
      await pumpHost(
        tester,
        SemiForm(
          controller: controller,
          child: SemiFormInput(
            field: 'name',
            label: '名称',
            convert: (v) => '${v!}-c',
            transform: (v) {
              validated = v;
              return v;
            },
            validator: (v, values) => '',
          ),
        ),
      );
      await tester.enterText(find.byType(SemiInput), 'x');
      await tester.pumpAndSettle();
      expect(controller.getValue('name'), 'x-c');
      expect(validated, 'x-c');
    });

    testWidgets('form disabled cascades to controls', (tester) async {
      await pumpHost(
        tester,
        SemiForm(
          disabled: true,
          child: SemiFormInput(field: 'name', label: '名称'),
        ),
      );
      final input = tester.widget<SemiInput>(find.byType(SemiInput));
      expect(input.disabled, isTrue);
    });

    testWidgets('stopValidateWithError reports only the first error', (
      tester,
    ) async {
      final controller = SemiFormController();
      await pumpHost(
        tester,
        SemiForm(
          controller: controller,
          child: SemiFormInput(
            field: 'name',
            label: '名称',
            stopValidateWithError: true,
            rules: const [
              SemiFormFieldRule(min: 5, message: 'first'),
              SemiFormFieldRule(min: 10, message: 'second'),
            ],
          ),
        ),
      );
      await tester.enterText(find.byType(SemiInput), 'ab');
      await tester.pump();
      expect(controller.getError('name'), 'first');
    });

    testWidgets('keepState restores the value after remount', (tester) async {
      final controller = SemiFormController();
      final show = ValueNotifier<bool>(true);
      await pumpHost(
        tester,
        SemiForm(
          controller: controller,
          builder: (context, state, api) => ValueListenableBuilder<bool>(
            valueListenable: show,
            builder: (context, withField, _) => Column(
              children: [
                if (withField)
                  SemiFormField(
                    field: 'name',
                    label: '名称',
                    keepState: true,
                    builder: (context, control) => SemiInput(
                      value: control.value as String?,
                      onChanged: control.onChanged,
                    ),
                  ),
                const Text('spacer'),
              ],
            ),
          ),
        ),
      );
      await tester.enterText(find.byType(SemiInput), 'kept');
      await tester.pump();
      show.value = false;
      await tester.pumpAndSettle();
      show.value = true;
      await tester.pumpAndSettle();
      expect(controller.getValue('name'), 'kept');
    });

    testWidgets('label renders the required mark and optional suffix', (
      tester,
    ) async {
      await pumpHost(
        tester,
        SemiForm(
          child: Column(
            children: [
              SemiFormInput(
                field: 'req',
                label: '必填项',
                rules: const [SemiFormFieldRule(required: true)],
              ),
              SemiFormInput(field: 'opt', label: '可选项', labelOptional: true),
            ],
          ),
        ),
      );
      expect(find.text('必填项'), findsOneWidget);
      expect(find.text('*'), findsOneWidget);
      expect(find.text('（可选）'), findsOneWidget);
    });

    testWidgets('helpText shows without error and hides while error', (
      tester,
    ) async {
      final controller = SemiFormController();
      await pumpHost(
        tester,
        SemiForm(
          controller: controller,
          child: SemiFormInput(
            field: 'name',
            label: '名称',
            helpText: const Text('帮助文案'),
            rules: const [SemiFormFieldRule(required: true, message: '必填')],
          ),
        ),
      );
      expect(find.text('帮助文案'), findsOneWidget);
      await tester.enterText(find.byType(SemiInput), 'x');
      await tester.pump();
      await tester.enterText(find.byType(SemiInput), '');
      await tester.pump();
      expect(find.text('必填'), findsOneWidget);
      expect(find.text('帮助文案'), findsNothing);
    });

    testWidgets('ArrayField add/insert/remove syncs values', (tester) async {
      final controller = SemiFormController();
      await pumpHost(
        tester,
        SemiForm(
          controller: controller,
          child: SemiArrayField(
            field: 'people',
            initValue: const [
              {'name': 'p0'},
            ],
            builder: (context, api) => Column(
              children: [
                for (final item in api.items)
                  Row(
                    children: [
                      Expanded(
                        child: SemiFormInput(
                          field: '${item.field}.name',
                          label: '姓名',
                        ),
                      ),
                      GestureDetector(
                        onTap: item.remove,
                        child: Text('remove-${item.key}'),
                      ),
                    ],
                  ),
                GestureDetector(
                  key: const ValueKey('add'),
                  onTap: () => api.add(),
                  child: const Text('add'),
                ),
                GestureDetector(
                  key: const ValueKey('insert'),
                  onTap: () => api.addWithInitValue({'name': 'px'}, 0),
                  child: const Text('insert'),
                ),
              ],
            ),
          ),
        ),
      );
      expect((controller.getValue('people') as List).length, 1);
      await tester.tap(find.byKey(const ValueKey('add')));
      await tester.pumpAndSettle();
      expect((controller.getValue('people') as List).length, 2);
      await tester.tap(find.byKey(const ValueKey('insert')));
      await tester.pumpAndSettle();
      final first = (controller.getValue('people') as List).first as Map;
      expect(first['name'], 'px');
      await tester.tap(find.textContaining('remove-').first);
      await tester.pumpAndSettle();
      expect((controller.getValue('people') as List).length, 2);
    });

    testWidgets('SemiFormGroup aggregates the first fieldSet error', (
      tester,
    ) async {
      final controller = SemiFormController();
      await pumpHost(
        tester,
        SemiForm(
          controller: controller,
          child: SemiFormGroup(
            fieldSet: const ['a', 'b'],
            label: '分组',
            child: Column(
              children: [
                SemiFormInput(
                  field: 'a',
                  label: 'A',
                  rules: const [
                    SemiFormFieldRule(required: true, message: 'a-miss'),
                  ],
                ),
                SemiFormInput(
                  field: 'b',
                  label: 'B',
                  rules: const [
                    SemiFormFieldRule(required: true, message: 'b-miss'),
                  ],
                ),
              ],
            ),
          ),
        ),
      );
      expect(find.text('分组'), findsOneWidget);
      try {
        await controller.validate();
      } catch (_) {}
      await tester.pumpAndSettle();
      // 组内字段 chrome 被抑制——错误只在组级出现一次。
      expect(find.text('a-miss'), findsOneWidget);
    });

    testWidgets('Section and Slot render chrome', (tester) async {
      await pumpHost(
        tester,
        const SemiForm(
          child: Column(
            children: [
              SemiFormSection(title: '分组标题', child: Text('section-child')),
              SemiFormSlot(
                label: '槽标签',
                error: Text('槽错误'),
                child: Text('slot-child'),
              ),
            ],
          ),
        ),
      );
      expect(find.text('分组标题'), findsOneWidget);
      expect(find.text('section-child'), findsOneWidget);
      expect(find.text('槽标签'), findsOneWidget);
      expect(find.text('槽错误'), findsOneWidget);
    });

    testWidgets('labelPosition inset injects insetLabel into SemiFormInput', (
      tester,
    ) async {
      await pumpHost(
        tester,
        const SemiForm(
          child: SemiFormInput(
            field: 'name',
            label: '名称',
            labelPosition: SemiFormLabelPosition.inset,
          ),
        ),
      );
      final input = tester.widget<SemiInput>(find.byType(SemiInput));
      expect(input.insetLabel, '名称');
    });
  });
}

/// allowEmpty 缺省时空串不入 values（键应缺失）。
bool _pathHasPublic(Map<String, Object?> values, String path) =>
    values.containsKey(path);
