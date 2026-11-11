import 'package:flutter/gestures.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:semi_design_flutter/semi_design_flutter.dart';

List<Color?> itemBgs(WidgetTester tester) => [
  for (final w in tester.widgetList<AnimatedContainer>(
    find.byType(AnimatedContainer),
  ))
    (w.decoration as BoxDecoration?)?.color,
];

Future<void> open(WidgetTester tester) async {
  await tester.pumpWidget(
    const SemiApp(
      home: Center(
        child: SemiDropdown(
          trigger: SemiTooltipTrigger.click,
          menu: [
            SemiDropdownItemData(name: '第一项', onTap: _noop),
            SemiDropdownItemData(name: '第二项', onTap: _noop),
          ],
          child: Text('触发物'),
        ),
      ),
    ),
  );
  await tester.tap(find.text('触发物'));
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 120));
  await tester.pump();
}

void main() {
  final hoverFill = const SemiThemeData.light().colors.colorFill0;

  testWidgets(
    'a mouse-opened menu starts with no fill so hover feedback is visible',
    (tester) async {
      await open(tester);
      // Upstream `:focus-visible` does not paint after a mouse click: the
      // cursor sits on the first row, but no row shows the highlight fill yet.
      expect(itemBgs(tester), [
        const Color(0x00000000),
        const Color(0x00000000),
      ]);

      final gesture = await tester.createGesture(kind: PointerDeviceKind.mouse);
      await gesture.addPointer(location: Offset.zero);
      addTearDown(gesture.removePointer);
      await gesture.moveTo(tester.getCenter(find.text('第二项')));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 50));
      await tester.pump();
      final bgs = itemBgs(tester);
      expect(bgs[0], const Color(0x00000000));
      expect(bgs[1], hoverFill);
    },
  );

  testWidgets('keyboard navigation turns the highlight on', (tester) async {
    await open(tester);
    // The cursor starts on the first row; ArrowDown moves it to the second.
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
    await tester.pump();
    final bgs = itemBgs(tester);
    expect(bgs[0], const Color(0x00000000));
    expect(bgs[1], hoverFill);
  });
}

void _noop() {}
