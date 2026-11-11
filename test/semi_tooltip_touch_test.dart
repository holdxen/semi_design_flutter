import 'package:flutter/gestures.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:semi_design_flutter/semi_design_flutter.dart';

Future<void> settle(WidgetTester tester) async {
  await tester.pump(const Duration(milliseconds: 80));
  await tester.pump();
  await tester.pump();
}

void main() {
  testWidgets('touch taps toggle the hover tooltip on non-hover devices', (
    tester,
  ) async {
    await tester.pumpWidget(
      const SemiApp(
        home: Center(
          child: SemiTooltip(content: Text('提示'), child: Text('目标')),
        ),
      ),
    );
    expect(find.text('提示'), findsNothing);

    // tester.tap sends touch pointers: emulators and phones only ever see
    // these, never hover events.
    await tester.tap(find.text('目标'));
    await settle(tester);
    expect(find.text('提示'), findsOneWidget);

    await tester.tap(find.text('目标'));
    await settle(tester);
    expect(find.text('提示'), findsNothing);
  });

  testWidgets('mouse clicks keep upstream hover semantics and never toggle', (
    tester,
  ) async {
    await tester.pumpWidget(
      const SemiApp(
        home: Center(
          child: SemiTooltip(content: Text('提示'), child: Text('目标')),
        ),
      ),
    );
    final gesture = await tester.createGesture(kind: PointerDeviceKind.mouse);
    await gesture.addPointer(location: Offset.zero);
    addTearDown(gesture.removePointer);

    // Hover shows it (the upstream mouse path).
    await gesture.moveTo(tester.getCenter(find.text('目标')));
    await tester.pump();
    await settle(tester);
    expect(find.text('提示'), findsOneWidget);

    // A mouse click must NOT toggle it away.
    await gesture.down(tester.getCenter(find.text('目标')));
    await gesture.up();
    await settle(tester);
    expect(find.text('提示'), findsOneWidget);

    // Leaving still hides it (allow the hide delay and exit motion to end).
    await gesture.moveTo(Offset.zero);
    await tester.pump();
    await settle(tester);
    await tester.pump(const Duration(milliseconds: 150));
    await tester.pump();
    expect(find.text('提示'), findsNothing);
  });
}
