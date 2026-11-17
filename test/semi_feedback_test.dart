// Behavior matrix for SemiFeedback plus coverage for the 16 Sass declarations
// (16 FIELDS + 0 MOTION + 0 INTERNAL) — the 60 HARDCODES provenance anchors
// live in the widget's file-level note block / call sites. 0 死变量（16 声明
// 全部被 feedback.scss 逐条消费）；6 条 thank_text 字段「字段留档不消费」——
// 不落 widget 源码（下方断言），渲染路径 10 条。
import 'dart:async';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:semi_design_flutter/semi_design_flutter.dart';
import 'package:semi_design_flutter/src/overlay/dialog_engine/helper/dialog_proxy.dart';
import 'package:semi_design_flutter/src/overlay/dialog_engine/helper/smart_dialog_test_state.dart';

// -- theme field table -------------------------------------------------------

typedef _Patch = SemiFeedbackThemeData Function(Object value);
typedef _Read = Object? Function(SemiResolvedFeedbackThemeData data);
typedef _Default = Object? Function(SemiThemeData theme);

const _c = Color(0xFF010203);

final List<(String, Object, _Patch, _Read, _Default)> fields = [
  (
    r'$color-feedback_thank_text: var(--semi-color-text-2)',
    _c,
    (v) => SemiFeedbackThemeData(colorFeedbackThankText: v as Color),
    (d) => d.colorFeedbackThankText,
    (t) => t.colors.colorText2,
  ),
  (
    r'$width-feedback: 400px',
    77.5,
    (v) => SemiFeedbackThemeData(widthFeedback: v as double),
    (d) => d.widthFeedback,
    (t) => 400.0,
  ),
  (
    r'$width-feedback_text: 600px',
    77.5,
    (v) => SemiFeedbackThemeData(widthFeedbackText: v as double),
    (d) => d.widthFeedbackText,
    (t) => 600.0,
  ),
  (
    r'$spacing-feedback_emoji_container-columnGap: 24px',
    77.5,
    (v) => SemiFeedbackThemeData(
      spacingFeedbackEmojiContainerColumnGap: v as double,
    ),
    (d) => d.spacingFeedbackEmojiContainerColumnGap,
    (t) => 24.0,
  ),
  (
    r'$spacing-feedback_emoji_container-marginY: 24px',
    77.5,
    (v) => SemiFeedbackThemeData(
      spacingFeedbackEmojiContainerMarginY: v as double,
    ),
    (d) => d.spacingFeedbackEmojiContainerMarginY,
    (t) => 24.0,
  ),
  (
    r'$spacing-feedback_thank_text-marginTop: 24px',
    77.5,
    (v) =>
        SemiFeedbackThemeData(spacingFeedbackThankTextMarginTop: v as double),
    (d) => d.spacingFeedbackThankTextMarginTop,
    (t) => 24.0,
  ),
  (
    r'$spacing-feedback_thank_text-marginBottom: 0px',
    77.5,
    (v) => SemiFeedbackThemeData(
      spacingFeedbackThankTextMarginBottom: v as double,
    ),
    (d) => d.spacingFeedbackThankTextMarginBottom,
    (t) => 0.0,
  ),
  (
    r'$spacing-feedback_checkbox_group_vertical-rowGap: 16px',
    77.5,
    (v) => SemiFeedbackThemeData(
      spacingFeedbackCheckboxGroupVerticalRowGap: v as double,
    ),
    (d) => d.spacingFeedbackCheckboxGroupVerticalRowGap,
    (t) => 16.0,
  ),
  (
    r'$spacing-feedback_footer-columnGap: 12px',
    77.5,
    (v) => SemiFeedbackThemeData(spacingFeedbackFooterColumnGap: v as double),
    (d) => d.spacingFeedbackFooterColumnGap,
    (t) => 12.0,
  ),
  (
    r'$spacing-feedback_sidesheet_bottom-right: 20px',
    77.5,
    (v) =>
        SemiFeedbackThemeData(spacingFeedbackSidesheetBottomRight: v as double),
    (d) => d.spacingFeedbackSidesheetBottomRight,
    (t) => 20.0,
  ),
  (
    r'$spacing-feedback_sidesheet_bottom_inner_wrap-bottom: 50px',
    77.5,
    (v) => SemiFeedbackThemeData(
      spacingFeedbackSidesheetBottomInnerWrapBottom: v as double,
    ),
    (d) => d.spacingFeedbackSidesheetBottomInnerWrapBottom,
    (t) => 50.0,
  ),
  (
    r'$font-feedback_emoji-fontSize: 36px',
    77.5,
    (v) => SemiFeedbackThemeData(fontFeedbackEmojiFontSize: v as double),
    (d) => d.fontFeedbackEmojiFontSize,
    (t) => 36.0,
  ),
  (
    r'$font-feedback_thank_text-fontSize: $font-size-regular',
    77.5,
    (v) => SemiFeedbackThemeData(fontFeedbackThankTextFontSize: v as double),
    (d) => d.fontFeedbackThankTextFontSize,
    (t) => t.typography.fontSizeRegular,
  ),
  (
    r'$font-feedback_thank_text-lineHeight: 20px',
    77.5,
    (v) => SemiFeedbackThemeData(fontFeedbackThankTextLineHeight: v as double),
    (d) => d.fontFeedbackThankTextLineHeight,
    (t) => 20.0,
  ),
  (
    r'$font-feedback_thank_text-fontWeight: $font-weight-regular',
    FontWeight.w900,
    (v) =>
        SemiFeedbackThemeData(fontFeedbackThankTextFontWeight: v as FontWeight),
    (d) => d.fontFeedbackThankTextFontWeight,
    (t) => t.typography.fontWeightRegular,
  ),
  (
    r'$radius-feedback_sidesheet_inner: 12px',
    77.5,
    (v) => SemiFeedbackThemeData(radiusFeedbackSidesheetInner: v as double),
    (d) => d.radiusFeedbackSidesheetInner,
    (t) => 12.0,
  ),
];

// 6 条「字段留档不消费」（`&-thank-text` 钩子族）。
const shengyuFields = {
  'colorFeedbackThankText',
  'spacingFeedbackThankTextMarginTop',
  'spacingFeedbackThankTextMarginBottom',
  'fontFeedbackThankTextFontSize',
  'fontFeedbackThankTextLineHeight',
  'fontFeedbackThankTextFontWeight',
};

// 60 HARDCODES provenance anchors (tool/generate_feedback.py HARDCODES)。
const hardcodes = <String>[
  "MODE: ['modal', 'popup']",
  "TYPE: ['text', 'emoji', 'radio', 'checkbox', 'custom']",
  "bad: '😞'",
  "normal: '😐'",
  "good: '😃'",
  "mode: 'popup'",
  "type: 'emoji'",
  'role="button"',
  'tabIndex={0}',
  'aria-pressed={item === emoji}',
  "e.key === 'Enter' || e.key === ' '",
  'filter: grayscale(100%)',
  '&:hover, &-selected',
  'filter: none;',
  'font-family: Inter',
  'user-select: none',
  'emoji === Emoji.bad && <TextArea',
  'placeholder={locale.optionalPlaceholder}',
  'placeholder={locale.placeholder}',
  "direction='vertical'",
  "direction='vertical'",
  "type='primary'",
  "theme='solid'",
  'disabled={this.disableSubmitButton()}',
  'okText={locale.submit}',
  'cancelText={locale.cancel}',
  'okButtonProps={{ disabled: disabledOkButton, ...this.props.okButtonProps }}',
  'mask={false}',
  'disableScroll={false}',
  'canVerticalSetWidth={true}',
  'placement="bottom"',
  'height="auto"',
  'this.props.afterClose()',
  "'textAreaProps', 'radioGroupProps', 'checkboxGroupProps', 'renderContent', 'onCancel', 'onOk'",
  "['okButtonProps', 'cancelButtonProps']",
  '!Boolean(value) || (Array.isArray(value) && value.length === 0)',
  'onOKReturnPromiseStatus',
  'onCancelReturnPromiseStatus',
  'value: null',
  'setValue(null)',
  'handleModalOk',
  'handleModalCancel',
  '&-thank-text',
  'justify-content: flex-end',
  '.#{\$prefix}-modal',
  '&.#{\$module}-text',
  '.#{\$prefix}-sidesheet-inner',
  '.#{\$prefix}-checkboxGroup-vertical',
  'right: \$spacing-feedback_sidesheet_bottom-right',
  'left: auto',
  '.#{\$prefix}-sidesheet-inner-wrap',
  '@keyframes #{\$prefix}-sidesheet-slideShow_bottom',
  '@keyframes #{\$prefix}-sidesheet-slideHide_bottom',
  'translateY(calc(100% + \$spacing-feedback_sidesheet_bottom_inner_wrap-bottom))',
  '.#{\$prefix}-sidesheet-fixed',
  'top: auto',
  '请提供更多反馈',
  '请提供更多反馈（选填）',
  '提交',
  '取消',
];

// -- harness -----------------------------------------------------------------

/// 宿主 body 经 ValueListenable 交换（Overlay.initialEntries 重建不换内容）。
final _body = ValueNotifier<Widget>(const SizedBox.shrink());

Widget _host({SemiFeedbackThemeData? patch}) {
  Widget app = SemiTheme(
    data: const SemiThemeData.light(),
    child: Directionality(
      textDirection: TextDirection.ltr,
      child: MediaQuery(
        data: const MediaQueryData(size: Size(1200, 900)),
        child: Overlay(
          initialEntries: [
            OverlayEntry(
              builder: (context) => ValueListenableBuilder<Widget>(
                valueListenable: _body,
                builder: (context, value, _) => Center(child: value),
              ),
            ),
          ],
        ),
      ),
    ),
  );
  if (patch != null) {
    app = SemiFeedbackTheme(data: patch, child: app);
  }
  return app;
}

Future<void> pumpHost(
  WidgetTester tester, {
  SemiFeedbackThemeData? patch,
}) async {
  values.clear();
  textChanges.clear();
  radioEvents.clear();
  checkboxEvents.clear();
  addTearDown(() async {
    // 引擎的 display/least-loading 计时器要冲掉（上游 disposeSmartDialogApp
    // 双冲洗次序：存活时冲 → 卸载 → reset → 再冲）。
    await tester.pump(const Duration(seconds: 3));
    _body.value = const SizedBox.shrink();
    await tester.pump();
    DialogProxy.instance.resetForTest();
    await tester.pump(const Duration(seconds: 3));
    await tester.pump();
  });
  await tester.binding.setSurfaceSize(const Size(1200, 900));
  await tester.pumpWidget(_host(patch: patch));
  await tester.pump();
  // 裸宿主无 SemiApp/observer——手动绑定（引擎逃生口）。
  DialogProxy.instance.bind(tester.state<OverlayState>(find.byType(Overlay)));
  await tester.pump();
}

/// 换 body（同类型位置复用 State——didUpdateWidget 路径）。
Future<void> setFeedback(WidgetTester tester, Widget feedback) async {
  _body.value = feedback;
  await tester.pump();
  await tester.pump();
}

/// 弹层入场泵帧（引擎 insert 1 帧 + 内容 1 帧）。
Future<void> pumpOpen(WidgetTester tester) async {
  await tester.pump();
  await tester.pump();
  await tester.pump();
}

/// 交互后内容刷新（引擎 controller.refresh 走 addSafeUse post-frame
/// setState——父级重建帧之后内容帧才跟上）。
Future<void> refresh(WidgetTester tester) async {
  await tester.pump();
  await tester.pump();
}

Future<void> pumpClosed(WidgetTester tester) async {
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 250));
  // DebounceUtils/MonitorWidgetHelper 的计时器要在 teardown 之前清掉
  // （上游 SmartDialogTestState.reset 先例）。
  SmartDialogTestState.reset();
  await tester.pump(const Duration(seconds: 3));
  await tester.pump();
}

SemiButton _button(WidgetTester tester, String label) =>
    tester.widget<SemiButton>(find.widgetWithText(SemiButton, label));

/// Sass 名 → 字段名（camelCase，生成器同规则）。
String _field(String sass) {
  final name = sass.split(': ').first.substring(1);
  final parts = RegExp(r'[-_]').allMatches(name);
  var result = name;
  for (final m in parts.toList().reversed) {
    result =
        result.substring(0, m.start) +
        result.substring(m.start + 1, m.start + 2).toUpperCase() +
        result.substring(m.start + 2);
  }
  return result;
}

SemiResolvedFeedbackThemeData resolve() =>
    const SemiFeedbackThemeData().resolve(const SemiThemeData.light());

void main() {
  group('theme fields (16 = 16 FIELDS + 0 MOTION + 0 INTERNAL)', () {
    test('16 fields: merge, copyWith, resolve, equality, defaults', () {
      expect(fields, hasLength(16));
      for (final (sass, value, make, read, expected) in fields) {
        final patch = make(value);
        expect(const SemiFeedbackThemeData().merge(patch), patch, reason: sass);
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
          read(const SemiFeedbackThemeData().resolve(light)),
          expected(light),
          reason: sass,
        );
        final dark = const SemiThemeData.dark();
        expect(
          read(const SemiFeedbackThemeData().resolve(dark)),
          expected(dark),
          reason: sass,
        );
      }
    });

    test('every field carries its Sass provenance in the generated source', () {
      final source = File('lib/src/theme/semi_feedback_theme_data.dart')
          .readAsStringSync();
      final names = <String>{};
      for (final (sass, _, _, _, _) in fields) {
        expect(source, contains(sass));
        names.add(sass.split(': ').first.substring(1));
      }
      expect(names, hasLength(16));
      expect(
        source,
        contains('packages/semi-foundation/feedback/variables.scss'),
      );
      expect(source, contains('Generated by tool/generate_feedback.py'));
      expect(
        File('lib/src/theme/semi_feedback_theme.dart').readAsStringSync(),
        contains('Generated by tool/generate_feedback.py'),
      );
    });

    test('60 HARDCODES anchors appear in the widget source', () {
      final widget = File('lib/src/components/semi_feedback.dart')
          .readAsStringSync();
      expect(hardcodes, hasLength(60));
      for (final snippet in hardcodes) {
        expect(widget, contains(snippet), reason: snippet);
      }
    });

    test('type coverage + 留档不消费 fields stay out of the widget', () {
      final theme = File('lib/src/theme/semi_feedback_theme_data.dart')
          .readAsStringSync();
      final widget = File('lib/src/components/semi_feedback.dart')
          .readAsStringSync();
      final docs = File('docs/semi_feedback.md').readAsStringSync();
      // 类型覆盖：1 Color + 14 double + 1 FontWeight。
      expect(RegExp(r'final Color\? ').allMatches(theme), hasLength(1));
      expect(RegExp(r'final double\? ').allMatches(theme), hasLength(14));
      expect(RegExp(r'final FontWeight\? ').allMatches(theme), hasLength(1));
      for (final name in shengyuFields) {
        expect(theme, contains(name));
        expect(
          RegExp('(?<![A-Za-z])$name(?![A-Za-z])').hasMatch(widget),
          isFalse,
          reason: '$name is 留档不消费',
        );
      }
      // 渲染路径 10 条全部进 widget。
      for (final (sass, _, _, _, _) in fields) {
        final name = _field(sass);
        if (shengyuFields.contains(name)) continue;
        expect(widget, contains(name), reason: sass);
      }
      final rows = docs
          .split('\n')
          .where((line) => line.startsWith('|') && line.contains('thank_text'))
          .toList();
      expect(rows, hasLength(6));
      for (final row in rows) {
        expect(row, contains('留档不消费'));
      }
    });

    test('SemiComponentThemes wiring', () {
      const themes = SemiComponentThemes();
      expect(themes.feedback, const SemiFeedbackThemeData());
      expect(
        themes.copyWith(
          feedback: const SemiFeedbackThemeData(widthFeedback: 500),
        ),
        const SemiComponentThemes(
          feedback: SemiFeedbackThemeData(widthFeedback: 500),
        ),
      );
    });
  });

  group('behavior', () {
    testWidgets(
      'emoji (default) renders three grayscale items; click/Enter/Space '
      'select; bad reveals the optional textarea',
      (tester) async {
        await pumpHost(tester);
        await setFeedback(
          tester,
          SemiFeedback(
            visible: true,
            motion: false,
            onValueChange: (v) => values.add(v),
          ),
        );
        await pumpOpen(tester);
        // `role="button"` `tabIndex={0}` —— 三档 emoji 全灰度（`filter: grayscale(100%)`）。
        for (final emoji in ['😞', '😐', '😃']) {
          expect(find.text(emoji), findsOneWidget);
          expect(
            find.ancestor(
              of: find.text(emoji),
              matching: find.byType(ColorFiltered),
            ),
            findsOneWidget,
          );
        }
        // 点选 😐 → `&-selected` `filter: none;` + `aria-pressed`。
        await tester.tap(find.text('😐'));
        await refresh(tester);
        expect(
          find.ancestor(
            of: find.text('😐'),
            matching: find.byType(ColorFiltered),
          ),
          findsNothing,
        );
        expect(values, [const SemiFeedbackEmojiResult(emoji: '😐')]);
        expect(_button(tester, '提交').disabled, isFalse);
        // bad 不显示追问 TextArea。
        expect(find.byType(SemiTextArea), findsNothing);

        // 点选 😞 → `emoji === Emoji.bad && <TextArea`（`optionalPlaceholder`）。
        await tester.tap(find.text('😞'));
        await refresh(tester);
        final area = tester.widget<SemiTextArea>(find.byType(SemiTextArea));
        expect(area.placeholder, '请提供更多反馈（选填）');
        await tester.enterText(find.byType(SemiTextArea), 'reason');
        await refresh(tester);
        expect(
          values.last,
          const SemiFeedbackEmojiResult(emoji: '😞', text: 'reason'),
        );

        // 键盘 `e.key === 'Enter' || e.key === ' '` 选中（其他键不选）。
        final valuesBefore = values.length;
        Focus.of(tester.element(find.text('😃'))).requestFocus();
        await tester.pump();
        await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
        await refresh(tester);
        expect(values, hasLength(valuesBefore));
        await tester.sendKeyEvent(LogicalKeyboardKey.enter);
        await refresh(tester);
        expect(values.last, const SemiFeedbackEmojiResult(emoji: '😃'));
        await pumpClosed(tester);
      },
    );

    testWidgets('text type: placeholder default and textAreaProps override; '
        'typing reports the string value', (tester) async {
      await pumpHost(tester);
      await setFeedback(
        tester,
        const SemiFeedback(
          visible: true,
          motion: false,
          type: SemiFeedbackType.text,
        ),
      );
      await pumpOpen(tester);
      expect(
        tester.widget<SemiTextArea>(find.byType(SemiTextArea)).placeholder,
        '请提供更多反馈',
      );
      expect(_button(tester, '提交').disabled, isTrue);

      await setFeedback(
        tester,
        SemiFeedback(
          visible: true,
          motion: false,
          type: SemiFeedbackType.text,
          textAreaProps: SemiFeedbackTextAreaProps(
            placeholder: 'custom',
            onChange: (v) => textChanges.add(v),
          ),
          onValueChange: (v) => values.add(v),
        ),
      );
      await pumpOpen(tester);
      expect(
        tester.widget<SemiTextArea>(find.byType(SemiTextArea)).placeholder,
        'custom',
      );
      await tester.enterText(find.byType(SemiTextArea), 'hello');
      await refresh(tester);
      expect(textChanges, ['hello']);
      expect(values, ['hello']);
      // 空串仍禁用（`!Boolean(value)` falsy 约定）。
      await tester.enterText(find.byType(SemiTextArea), '');
      await refresh(tester);
      expect(_button(tester, '提交').disabled, isTrue);
      await pumpClosed(tester);
    });

    testWidgets('radio/checkbox groups (direction vertical) report values and '
        'gate submit; checkbox row-gap patched to 16', (tester) async {
      await pumpHost(tester);
      await setFeedback(
        tester,
        SemiFeedback(
          visible: true,
          motion: false,
          type: SemiFeedbackType.radio,
          radioGroupProps: SemiFeedbackRadioGroupProps(
            options: const [
              SemiRadioOption(label: '满意', value: 'satisfied'),
              SemiRadioOption(label: '不满意', value: 'unsatisfied'),
            ],
            onChanged: (e) => radioEvents.add(e.value),
          ),
          onValueChange: (v) => values.add(v),
        ),
      );
      await pumpOpen(tester);
      expect(_button(tester, '提交').disabled, isTrue);
      await tester.tap(find.text('不满意'));
      await refresh(tester);
      expect(radioEvents, ['unsatisfied']);
      expect(values, ['unsatisfied']);
      expect(_button(tester, '提交').disabled, isFalse);

      await setFeedback(
        tester,
        SemiFeedback(
          visible: true,
          motion: false,
          type: SemiFeedbackType.checkbox,
          checkboxGroupProps: SemiFeedbackCheckboxGroupProps(
            options: const [
              SemiCheckboxOption(label: '加载慢', value: 'slow'),
              SemiCheckboxOption(label: '功能缺失', value: 'missing'),
            ],
            onChanged: (v) => checkboxEvents.add(v),
          ),
          onValueChange: (v) => values.add(v),
        ),
      );
      await pumpOpen(tester);
      // `.#{$prefix}-checkboxGroup-vertical` row-gap 16 → 组内间距 patch。
      expect(
        find.descendant(
          of: find.byType(SemiCheckboxGroup),
          matching: find.byWidgetPredicate(
            (w) => w is SizedBox && w.height == 16,
          ),
        ),
        findsWidgets,
      );
      await tester.tap(find.text('加载慢'));
      await refresh(tester);
      await tester.tap(find.text('功能缺失'));
      await refresh(tester);
      expect(checkboxEvents, [
        ['slow'],
        ['slow', 'missing'],
      ]);
      expect(values.last, ['slow', 'missing']);
      await pumpClosed(tester);
    });

    testWidgets('okDisabled overrides the auto gate; custom type stays gated '
        '(value 恒空)', (tester) async {
      await pumpHost(tester);
      await setFeedback(
        tester,
        const SemiFeedback(
          visible: true,
          motion: false,
          type: SemiFeedbackType.custom,
          content: Text('custom body'),
          okDisabled: false,
        ),
      );
      await pumpOpen(tester);
      expect(find.text('custom body'), findsOneWidget);
      // `okButtonProps={{ disabled: false }}` 显式覆写生效。
      expect(_button(tester, '提交').disabled, isFalse);
      expect(_button(tester, '取消').disabled, isNull);

      await setFeedback(
        tester,
        const SemiFeedback(
          visible: true,
          motion: false,
          type: SemiFeedbackType.custom,
          content: Text('custom body'),
        ),
      );
      await pumpOpen(tester);
      // custom 无内部值来源 → 提交钮默认禁用（上游同）。
      expect(_button(tester, '提交').disabled, isTrue);
      await pumpClosed(tester);
    });

    testWidgets('onOk Future drives loading and resets the value on resolve; '
        'reject only drops loading', (tester) async {
      await pumpHost(tester);
      final ok = Completer<void>();
      await setFeedback(
        tester,
        SemiFeedback(
          visible: true,
          motion: false,
          onOk: () => ok.future,
          onValueChange: (v) => values.add(v),
        ),
      );
      await pumpOpen(tester);
      await tester.tap(find.text('😃'));
      await refresh(tester);
      await tester.tap(find.text('提交'));
      await refresh(tester);
      // `onOKReturnPromiseStatus: "pending"` → 提交钮 loading。
      expect(_button(tester, '提交').loading, isTrue);
      ok.complete();
      await tester.pump();
      await tester.pump();
      // resolve → `value: null` 复位（不回调 onValueChange）+ loading 去。
      expect(_button(tester, '提交').loading, isFalse);
      expect(_button(tester, '提交').disabled, isTrue);
      expect(values, [const SemiFeedbackEmojiResult(emoji: '😃')]);

      final bad = Completer<void>();
      await setFeedback(
        tester,
        SemiFeedback(
          visible: true,
          motion: false,
          onOk: () => bad.future,
          onValueChange: (v) => values.add(v),
        ),
      );
      await pumpOpen(tester);
      await tester.tap(find.text('😃'));
      await refresh(tester);
      await tester.tap(find.text('提交'));
      await refresh(tester);
      bad.completeError(StateError('nope'));
      await tester.pump();
      await tester.pump();
      // rejected → 只去 loading，值保留（按钮仍可提交）。
      expect(_button(tester, '提交').loading, isFalse);
      expect(_button(tester, '提交').disabled, isFalse);

      // 取消同款状态机（非 promise 立即 `setValue(null)`）。
      await tester.tap(find.text('取消'));
      await refresh(tester);
      expect(_button(tester, '提交').disabled, isTrue);
      await pumpClosed(tester);
    });

    testWidgets('popup geometry: width 400 (text 600), right 20, bottom 50; '
        'local theme patch drives width and emoji size', (tester) async {
      await pumpHost(tester);
      const box = ValueKey('semi-feedback-sheet-box');
      await setFeedback(
        tester,
        const SemiFeedback(visible: true, motion: false),
      );
      await pumpOpen(tester);
      final card = tester.getRect(find.byKey(box));
      // `canVerticalSetWidth` + `.-text` 覆写 + `&-bottom` 锚定。
      expect(card.width, resolve().widthFeedback);
      expect(card.right, 1200 - resolve().spacingFeedbackSidesheetBottomRight);
      expect(
        card.bottom,
        900 - resolve().spacingFeedbackSidesheetBottomInnerWrapBottom,
      );
      final radius =
          tester.widget<Container>(find.byKey(box)).decoration!
              as BoxDecoration;
      expect(
        radius.borderRadius,
        BorderRadius.circular(resolve().radiusFeedbackSidesheetInner),
      );
      // emoji 字号 token。
      expect(
        tester.widget<Text>(find.text('😃')).style!.fontSize,
        resolve().fontFeedbackEmojiFontSize,
      );

      await setFeedback(
        tester,
        const SemiFeedback(
          visible: true,
          motion: false,
          type: SemiFeedbackType.text,
        ),
      );
      await pumpOpen(tester);
      expect(
        tester.getRect(find.byKey(box)).width,
        resolve().widthFeedbackText,
      );
      await pumpClosed(tester);
    });

    testWidgets('a local theme patch drives popup width and emoji size', (
      tester,
    ) async {
      await pumpHost(
        tester,
        patch: const SemiFeedbackThemeData(
          widthFeedback: 500,
          fontFeedbackEmojiFontSize: 44,
        ),
      );
      await setFeedback(
        tester,
        const SemiFeedback(visible: true, motion: false),
      );
      await pumpOpen(tester);
      expect(
        tester
            .getRect(find.byKey(const ValueKey('semi-feedback-sheet-box')))
            .width,
        500,
      );
      expect(tester.widget<Text>(find.text('😃')).style!.fontSize, 44);
      await pumpClosed(tester);
    });

    testWidgets('popup afterVisibleChange/afterClose and Esc gating', (
      tester,
    ) async {
      await pumpHost(tester);
      final events = <bool>[];
      var closed = 0;
      var cancels = 0;
      Widget feedback(bool visible, {bool? closeOnEsc}) => SemiFeedback(
        visible: visible,
        motion: false,
        closeOnEsc: closeOnEsc,
        onValueChange: (v) => values.add(v),
        onCancel: () => cancels++,
        afterClose: () => closed++,
        afterVisibleChange: events.add,
      );
      await setFeedback(tester, feedback(true));
      await pumpOpen(tester);
      // motion: false → 入场完成即 `(true)`。
      expect(events, [true]);
      // Esc 缺省 false（popup）→ 不触发 onCancel。
      await tester.sendKeyEvent(LogicalKeyboardKey.escape);
      await tester.pump();
      expect(cancels, 0);

      await setFeedback(tester, feedback(true, closeOnEsc: true));
      await pumpOpen(tester);
      Focus.of(tester.element(find.text('😃'))).requestFocus();
      await tester.pump();
      // closeOnEsc 焦点槽抢焦后 Esc → onCancel（`closeOnEsc` 语义）。
      await tester.sendKeyEvent(LogicalKeyboardKey.escape);
      await tester.pump();
      expect(cancels, 1);

      await setFeedback(tester, feedback(false));
      await pumpClosed(tester);
      // 出场完成 `(false)` + `this.props.afterClose()` 补发。
      expect(events, [true, false]);
      expect(closed, 1);
    });

    testWidgets('modal mode: SemiModal shell with width-feedback 400 and the '
        'Modal-lookalike footer (tertiary cancel + solid ok)', (tester) async {
      await pumpHost(tester);
      await setFeedback(
        tester,
        SemiFeedback(
          visible: true,
          motion: false,
          mode: SemiFeedbackMode.modal,
          type: SemiFeedbackType.text,
          title: '标题',
          onValueChange: (v) => values.add(v),
        ),
      );
      await pumpOpen(tester);
      expect(find.text('标题'), findsOneWidget);
      // `.#{$prefix}-modal { width: $width-feedback }`（文本模式同 400 quirk）。
      expect(
        tester.getRect(find.byKey(const ValueKey('semi-modal-box'))).width,
        resolve().widthFeedback,
      );
      // 照抄 Modal 缺省 footer：cancel `type="tertiary"` + ok `theme="solid"`。
      expect(_button(tester, '取消').type, SemiButtonType.tertiary);
      expect(_button(tester, '提交').variant, SemiButtonVariant.solid);
      expect(_button(tester, '提交').disabled, isTrue);
      await tester.enterText(find.byType(SemiTextArea), 'hi');
      await refresh(tester);
      expect(_button(tester, '提交').disabled, isFalse);
      expect(values, ['hi']);
      await pumpClosed(tester);
    });

    testWidgets('footer override replaces the button row (modal)', (
      tester,
    ) async {
      await pumpHost(tester);
      await setFeedback(
        tester,
        const SemiFeedback(
          visible: true,
          motion: false,
          mode: SemiFeedbackMode.modal,
          footer: Text('custom footer'),
        ),
      );
      await pumpOpen(tester);
      expect(find.text('custom footer'), findsOneWidget);
      expect(find.text('提交'), findsNothing);
      await setFeedback(
        tester,
        const SemiFeedback(
          visible: false,
          motion: false,
          mode: SemiFeedbackMode.modal,
        ),
      );
      await pumpClosed(tester);
    });

    testWidgets('footer override replaces the button row (popup)', (
      tester,
    ) async {
      await pumpHost(tester);
      await setFeedback(
        tester,
        const SemiFeedback(
          visible: true,
          motion: false,
          footer: Text('custom footer'),
        ),
      );
      await pumpOpen(tester);
      expect(find.text('custom footer'), findsOneWidget);
      expect(find.text('提交'), findsNothing);
      await setFeedback(
        tester,
        const SemiFeedback(visible: false, motion: false),
      );
      await pumpClosed(tester);
    });
  });
}

final values = <Object?>[];
final textChanges = <String>[];
final radioEvents = <Object?>[];
final checkboxEvents = <List<Object>>[];
