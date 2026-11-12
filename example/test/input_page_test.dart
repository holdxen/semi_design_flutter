import 'package:example/main.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:semi_design_flutter/semi_design_flutter.dart';

Finder keyed(String key) => find.byKey(ValueKey(key));

SemiInput input(WidgetTester tester, String key) =>
    tester.widget<SemiInput>(keyed(key));

Finder editable(String key) =>
    find.descendant(of: keyed(key), matching: find.byType(EditableText));

Future<void> start(WidgetTester tester) async {
  addTearDown(() async => tester.pumpWidget(const SizedBox.shrink()));
  await tester.pumpWidget(const MyApp());
  await tester.pump(const Duration(milliseconds: 50));
}

void main() {
  testWidgets('sections fit a narrow scaled screen and scroll to the bottom', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 640);
    tester.view.devicePixelRatio = 1;
    tester.platformDispatcher.textScaleFactorTestValue = 1.2;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
    await start(tester);
    for (final title in [
      '基础用法',
      '三档尺寸',
      '前后缀与附加块',
      '状态',
      '清除与密码',
      '多行',
      '局部主题',
    ]) {
      expect(find.text(title), findsOneWidget);
      await tester.ensureVisible(find.text(title));
      await tester.pump(const Duration(milliseconds: 100));
      expect(tester.takeException(), isNull);
    }
    await tester.ensureVisible(keyed('theme-input'));
    await tester.pump(const Duration(milliseconds: 100));
    expect(tester.takeException(), isNull);
  });

  testWidgets('basic input reports typing and enter', (tester) async {
    await start(tester);
    await tester.ensureVisible(keyed('basic-input'));
    await tester.pump(const Duration(milliseconds: 50));
    await tester.enterText(editable('basic-input'), '你好');
    await tester.pump(const Duration(milliseconds: 100));
    expect(find.textContaining('输入了「你好」'), findsOneWidget);
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pump(const Duration(milliseconds: 100));
    expect(find.textContaining('按下了 Enter'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('size state and slot props match the demos', (tester) async {
    await start(tester);
    expect(input(tester, 'small-input').size, SemiInputSize.small);
    expect(input(tester, 'normal-input').size, SemiInputSize.normal);
    expect(input(tester, 'large-input').size, SemiInputSize.large);
    expect(input(tester, 'disabled-input').disabled, isTrue);
    expect(input(tester, 'readonly-input').readonly, isTrue);
    expect(input(tester, 'borderless-input').borderless, isTrue);
    expect(input(tester, 'error-input').validateStatus, SemiInputStatus.error);
    expect(
      input(tester, 'warning-input').validateStatus,
      SemiInputStatus.warning,
    );
    expect(
      input(tester, 'success-input').validateStatus,
      SemiInputStatus.success,
    );

    final slots = input(tester, 'prefix-suffix-input');
    expect(slots.prefix, '价格');
    expect(slots.suffix, '元');
    expect(input(tester, 'inset-label-input').insetLabel, '名称');
    final addon = input(tester, 'addon-input');
    expect(addon.addonBefore, isNotNull);
    expect(addon.addonAfter, isNotNull);
    expect(tester.takeException(), isNull);
  });

  testWidgets('clearable and password demos expose their configuration', (
    tester,
  ) async {
    await start(tester);
    expect(input(tester, 'clearable-input').showClear, isTrue);
    final password = input(tester, 'password-input');
    expect(password.mode, SemiInputMode.password);
    expect(password.showClear, isTrue);

    // Password visibility toggle: tap the trailing eye button.
    await tester.ensureVisible(keyed('password-input'));
    await tester.pump(const Duration(milliseconds: 50));
    final eye = find.descendant(
      of: keyed('password-input'),
      matching: find.byWidgetPredicate(
        (w) =>
            w is SemiIcon &&
            (w.data == SemiIcons.eyeClosedSolid ||
                w.data == SemiIcons.eyeOpened),
      ),
    );
    expect(eye, findsOneWidget);
    await tester.tap(eye);
    await tester.pump(const Duration(milliseconds: 100));
    final switched = find.descendant(
      of: keyed('password-input'),
      matching: find.byWidgetPredicate(
        (w) => w is SemiIcon && w.data == SemiIcons.eyeOpened,
      ),
    );
    expect(switched, findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('textarea autosize counter and controlled input work', (
    tester,
  ) async {
    await start(tester);
    await tester.ensureVisible(keyed('textarea'));
    await tester.pump(const Duration(milliseconds: 50));
    final area = tester.widget<SemiTextArea>(keyed('textarea'));
    expect(area.rows, 3);
    expect(area.maxCount, 120);
    expect(area.showCounter, isTrue);
    expect(area.disabledEnterStartNewLine, isTrue);
    expect(find.textContaining('/120'), findsOneWidget);

    await tester.enterText(editable('controlled-input'), '新受控值');
    await tester.pump(const Duration(milliseconds: 100));
    final controlled = input(tester, 'controlled-input');
    expect(controlled.value, '受控内容，父级同步');
    expect(tester.takeException(), isNull);
  });

  testWidgets('local theme values resolve on the theme input', (tester) async {
    await start(tester);
    await tester.ensureVisible(keyed('theme-input'));
    await tester.pump(const Duration(milliseconds: 100));
    final theme = SemiInputTheme.resolve(tester.element(keyed('theme-input')));
    expect(theme.colorInputDefaultBgDefault, const Color(0xfff3effc));
    expect(theme.colorInputDefaultTextDefault, const Color(0xff7b61ff));
    expect(theme.heightInputWrapperDefault, 44);
    expect(theme.radiusInputWrapper, 12);
    expect(tester.takeException(), isNull);
  });
}
