import 'package:example/pages/input_number.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:semi_design_flutter/semi_design_flutter.dart';

Finder keyed(String key) => find.byKey(ValueKey(key));

Finder editable(String key) =>
    find.descendant(of: keyed(key), matching: find.byType(EditableText));

SemiInputNumber numWidget(WidgetTester tester, String key) =>
    tester.widget<SemiInputNumber>(keyed(key));

Finder up(String key) => find.descendant(
  of: keyed(key),
  matching: find.byKey(SemiInputNumber.upButtonKey),
);

Finder down(String key) => find.descendant(
  of: keyed(key),
  matching: find.byKey(SemiInputNumber.downButtonKey),
);

String inputText(WidgetTester tester, String key) =>
    tester.widget<EditableText>(editable(key)).controller.text;

Future<void> start(WidgetTester tester) async {
  addTearDown(() async => tester.pumpWidget(const SizedBox.shrink()));
  await tester.pumpWidget(const SemiApp(home: InputNumberPage()));
  await tester.pump(const Duration(milliseconds: 50));
}

/// Framework quirk workaround: when a field sits at a scroll viewport's top
/// edge, the first hit test after a tap-to-focus drops (any tap/stepper alike;
/// the next hit test works). A neutral tap absorbs the dropped dispatch so
/// the assertions under test see the real hit behaviour.
Future<void> tapFocus(WidgetTester tester, Finder editable) async {
  await tester.tap(editable);
  await tester.pump();
  await tester.tapAt(const Offset(700, 500));
  await tester.pump();
}

Future<void> blur(WidgetTester tester, String key) async {
  tester.widget<EditableText>(editable(key)).focusNode.unfocus();
  await tester.pump();
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
      '基本输入框',
      '状态与精度',
      '隐藏步进器',
      '尺寸',
      '自定义显示格式与解析方式',
      '纯数字输入框',
      '科学计数法显示',
    ]) {
      expect(find.text(title), findsOneWidget);
      await tester.ensureVisible(find.text(title));
      await tester.pump(const Duration(milliseconds: 100));
      expect(tester.takeException(), isNull);
    }
  });

  testWidgets('buttons and arrows step the basic demo and report the value', (
    tester,
  ) async {
    await start(tester);
    await tester.ensureVisible(keyed('inputnumber-basic'));
    await tester.pump(const Duration(milliseconds: 50));
    // Empty seeds step from 0.
    await tester.tap(up('inputnumber-basic'));
    await tester.pump();
    expect(inputText(tester, 'inputnumber-basic'), '1');
    expect(find.text('点击了加：1'), findsOneWidget);
    await tester.tap(up('inputnumber-basic'));
    await tester.pump();
    expect(inputText(tester, 'inputnumber-basic'), '2');
    await tester.tap(down('inputnumber-basic'));
    await tester.pump();
    expect(inputText(tester, 'inputnumber-basic'), '1');
    expect(find.text('点击了减：1'), findsOneWidget);
    // Keyboard steps go through the number channel.
    await tapFocus(tester, editable('inputnumber-basic'));
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowUp);
    await tester.pump();
    expect(inputText(tester, 'inputnumber-basic'), '2');
    expect(find.text('数值：2'), findsOneWidget);
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
    await tester.pump();
    expect(inputText(tester, 'inputnumber-basic'), '1');
    expect(tester.takeException(), isNull);
  });

  testWidgets('the strict boundary blocks stepping at min', (tester) async {
    await start(tester);
    await tester.ensureVisible(keyed('inputnumber-bounds'));
    await tester.pump(const Duration(milliseconds: 50));
    expect(inputText(tester, 'inputnumber-bounds'), '1');
    await tester.tap(down('inputnumber-bounds'));
    await tester.pump();
    // min=1 with the strict `number == min` not-allowed rule.
    expect(inputText(tester, 'inputnumber-bounds'), '1');
    await tester.tap(up('inputnumber-bounds'));
    await tester.pump();
    expect(inputText(tester, 'inputnumber-bounds'), '2');
    expect(tester.takeException(), isNull);
  });

  testWidgets('step shiftStep precision size and flags match the demos', (
    tester,
  ) async {
    await start(tester);
    expect(numWidget(tester, 'inputnumber-step2').step, 2);
    expect(numWidget(tester, 'inputnumber-shift-step').shiftStep, 100);
    expect(numWidget(tester, 'inputnumber-precision').precision, 2);
    expect(inputText(tester, 'inputnumber-precision'), '1.23');
    expect(numWidget(tester, 'inputnumber-small').size, SemiInputSize.small);
    expect(numWidget(tester, 'inputnumber-normal').size, SemiInputSize.normal);
    expect(numWidget(tester, 'inputnumber-large').size, SemiInputSize.large);
    expect(numWidget(tester, 'inputnumber-disabled').disabled, isTrue);
    expect(numWidget(tester, 'inputnumber-inner').innerButtons, isTrue);
    expect(numWidget(tester, 'inputnumber-hidden').hideButtons, isTrue);
    expect(
      numWidget(tester, 'inputnumber-scientific').scientificNotation,
      isTrue,
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('formatter and parser shape the display both ways', (
    tester,
  ) async {
    await start(tester);
    // ￥ thousands separator.
    await tester.ensureVisible(keyed('inputnumber-currency-format'));
    await tester.pump(const Duration(milliseconds: 50));
    expect(inputText(tester, 'inputnumber-currency-format'), '￥ 1,000');
    await tester.enterText(editable('inputnumber-currency-format'), '2345');
    await tester.pump();
    await blur(tester, 'inputnumber-currency-format');
    expect(inputText(tester, 'inputnumber-currency-format'), '￥ 2,345');
    // The dashed display parses its separators back out.
    await tester.ensureVisible(keyed('inputnumber-dashed'));
    await tester.pump(const Duration(milliseconds: 50));
    await tester.enterText(editable('inputnumber-dashed'), '2222');
    await tester.pump();
    await blur(tester, 'inputnumber-dashed');
    expect(inputText(tester, 'inputnumber-dashed'), '2-2-2-2');
    expect(tester.takeException(), isNull);
  });

  testWidgets('the digits-only demo filters non-digits live', (tester) async {
    await start(tester);
    await tester.ensureVisible(keyed('inputnumber-digits-only'));
    await tester.pump(const Duration(milliseconds: 50));
    await tester.enterText(editable('inputnumber-digits-only'), '12a3b4');
    await tester.pump();
    expect(inputText(tester, 'inputnumber-digits-only'), '1234');
    // onNumberChange only reports parseable numbers; the blur regularises
    // the filtered display into a number and fires it.
    await blur(tester, 'inputnumber-digits-only');
    expect(find.text('纯数字：1234'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('scientific notation collapses on blur and expands on focus', (
    tester,
  ) async {
    await start(tester);
    await tester.ensureVisible(keyed('inputnumber-scientific'));
    await tester.pump(const Duration(milliseconds: 50));
    await tester.enterText(
      editable('inputnumber-scientific'),
      '123456789012345678',
    );
    await tester.pump();
    await blur(tester, 'inputnumber-scientific');
    expect(inputText(tester, 'inputnumber-scientific'), contains('e'));
    await tapFocus(tester, editable('inputnumber-scientific'));
    expect(inputText(tester, 'inputnumber-scientific'), isNot(contains('e')));
    expect(tester.takeException(), isNull);
  });

  testWidgets('inner buttons appear on focus and hideButtons stays hidden', (
    tester,
  ) async {
    await start(tester);
    await tester.ensureVisible(keyed('inputnumber-inner'));
    await tester.pump(const Duration(milliseconds: 50));
    // At rest the user suffix shows and the stepper is tucked away.
    expect(find.text('小时'), findsOneWidget);
    expect(up('inputnumber-inner'), findsNothing);
    await tapFocus(tester, editable('inputnumber-inner'));
    expect(up('inputnumber-inner'), findsOneWidget);
    expect(down('inputnumber-inner'), findsOneWidget);
    await tester.tap(up('inputnumber-inner'));
    await tester.pump();
    expect(inputText(tester, 'inputnumber-inner'), '2');
    // hideButtons never renders a stepper.
    expect(up('inputnumber-hidden'), findsNothing);
    expect(tester.takeException(), isNull);
  });
}
