import 'package:flutter/gestures.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:semi_design_flutter/semi_design_flutter.dart';

Future<void> settle(WidgetTester tester) async {
  await tester.pump(const Duration(milliseconds: 80));
  await tester.pump();
  await tester.pump();
}

Future<void> settleHide(WidgetTester tester) async {
  await settle(tester);
  await tester.pump(const Duration(milliseconds: 150));
  await tester.pump();
}

Widget host() => const SemiApp(
  home: Center(
    child: SemiTooltip(
      trigger: SemiTooltipTrigger.focus,
      content: Text('提示'),
      child: Text('目标'),
    ),
  ),
);

void main() {
  testWidgets('tapping a focus trigger focuses it and shows the tooltip', (
    tester,
  ) async {
    await tester.pumpWidget(host());
    expect(find.text('提示'), findsNothing);

    await tester.tap(find.text('目标'));
    await settle(tester);
    expect(find.text('提示'), findsOneWidget);

    // Outside tap blurs the trigger and closes it.
    await tester.tapAt(const Offset(5, 5));
    await settleHide(tester);
    expect(find.text('提示'), findsNothing);
  });

  testWidgets('mouse click focuses the trigger as on the web', (tester) async {
    await tester.pumpWidget(host());
    final gesture = await tester.createGesture(kind: PointerDeviceKind.mouse);
    await gesture.addPointer(location: Offset.zero);
    addTearDown(gesture.removePointer);

    await gesture.down(tester.getCenter(find.text('目标')));
    await gesture.up();
    await settle(tester);
    expect(find.text('提示'), findsOneWidget);
  });

  testWidgets('keyboard focus still shows and Escape keeps working', (
    tester,
  ) async {
    await tester.pumpWidget(host());
    final context = tester.element(find.text('目标'));
    Focus.of(context).requestFocus();
    await settle(tester);
    expect(find.text('提示'), findsOneWidget);

    FocusManager.instance.primaryFocus?.unfocus();
    await settleHide(tester);
    expect(find.text('提示'), findsNothing);
  });

  testWidgets('click tooltip closes on Escape once click has focused it', (
    tester,
  ) async {
    await tester.pumpWidget(
      const SemiApp(
        home: Center(
          child: SemiTooltip(
            trigger: SemiTooltipTrigger.click,
            closeOnEsc: true,
            content: Text('提示'),
            child: Text('目标'),
          ),
        ),
      ),
    );
    await tester.tap(find.text('目标'));
    await settle(tester);
    expect(find.text('提示'), findsOneWidget);

    // The trigger holds focus after the click, so Escape reaches its handler.
    await tester.sendKeyEvent(LogicalKeyboardKey.escape);
    await settleHide(tester);
    expect(find.text('提示'), findsNothing);
  });
}
