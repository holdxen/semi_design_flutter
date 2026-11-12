import 'package:example/pages/pincode.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:semi_design_flutter/semi_design_flutter.dart';

Finder keyed(String key) => find.byKey(ValueKey(key));

Finder cells(String key) =>
    find.descendant(of: keyed(key), matching: find.byType(EditableText));

EditableText cell(WidgetTester tester, String key, int index) =>
    tester.widget<EditableText>(cells(key).at(index));

Future<void> start(WidgetTester tester) async {
  addTearDown(() async => tester.pumpWidget(const SizedBox.shrink()));
  await tester.pumpWidget(const SemiApp(home: PinCodePage()));
  await tester.pump(const Duration(milliseconds: 50));
}

Future<void> tap(WidgetTester tester, Finder finder) async {
  await tester.ensureVisible(finder);
  await tester.pump(const Duration(milliseconds: 50));
  // See docs/known_issues.md #1: when a control sits at a scroll viewport's
  // top edge, one hit test after focus-driven rebuilds can drop to the
  // scrollable. A neutral tap absorbs the dropped dispatch.
  await tester.tapAt(const Offset(700, 500));
  await tester.pump();
  await tester.tap(finder);
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 100));
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
    for (final title in ['基本使用', '受控', '设置位数', '设置字符范围', '手动聚焦失焦']) {
      expect(find.text(title), findsOneWidget);
      await tester.ensureVisible(find.text(title));
      await tester.pump(const Duration(milliseconds: 100));
      expect(tester.takeException(), isNull);
    }
  });

  testWidgets('typing auto-advances and the last cell completes', (
    tester,
  ) async {
    await start(tester);
    await tester.ensureVisible(keyed('pincode-count4'));
    await tester.pump(const Duration(milliseconds: 50));
    for (var i = 0; i < 4; i++) {
      await tester.enterText(cells('pincode-count4').at(i), '${i + 1}');
      await tester.pump();
      if (i < 3) {
        expect(
          cell(tester, 'pincode-count4', i + 1).focusNode.hasFocus,
          isTrue,
        );
      }
    }
    expect(find.text('四位完成：「1234」'), findsOneWidget);
    // Overwrite semantics: typing into a filled cell keeps the last char.
    await tester.enterText(cells('pincode-count4').at(0), '19');
    await tester.pump();
    expect(cell(tester, 'pincode-count4', 0).controller.text, '9');
    expect(tester.takeException(), isNull);
  });

  testWidgets('a multi-char paste distributes and stops at invalid chars', (
    tester,
  ) async {
    await start(tester);
    await tester.ensureVisible(keyed('pincode-count4'));
    await tester.pump(const Duration(milliseconds: 50));
    await tester.enterText(cells('pincode-count4').at(0), '12a3');
    await tester.pump();
    expect(cell(tester, 'pincode-count4', 0).controller.text, '1');
    expect(cell(tester, 'pincode-count4', 1).controller.text, '2');
    expect(cell(tester, 'pincode-count4', 2).controller.text, '');
    expect(cell(tester, 'pincode-count4', 3).controller.text, '');
    expect(cell(tester, 'pincode-count4', 2).focusNode.hasFocus, isTrue);
    expect(find.text('四位值：「12」'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('format filters per cell for RegExp and function forms', (
    tester,
  ) async {
    await start(tester);
    await tester.ensureVisible(keyed('pincode-fmt-regex'));
    await tester.pump(const Duration(milliseconds: 50));
    await tester.enterText(cells('pincode-fmt-regex').at(0), 'a');
    await tester.pump();
    expect(cell(tester, 'pincode-fmt-regex', 0).controller.text, '');
    await tester.enterText(cells('pincode-fmt-regex').at(0), 'B');
    await tester.pump();
    expect(cell(tester, 'pincode-fmt-regex', 0).controller.text, 'B');
    await tester.ensureVisible(keyed('pincode-fmt-func'));
    await tester.pump(const Duration(milliseconds: 50));
    await tester.enterText(cells('pincode-fmt-func').at(0), 'A');
    await tester.pump();
    expect(cell(tester, 'pincode-fmt-func', 0).controller.text, '');
    await tester.enterText(cells('pincode-fmt-func').at(0), 'a');
    await tester.pump();
    expect(cell(tester, 'pincode-fmt-func', 0).controller.text, 'a');
    expect(tester.takeException(), isNull);
  });

  testWidgets('controlled demo syncs and the random button refills', (
    tester,
  ) async {
    await start(tester);
    await tester.ensureVisible(keyed('pincode-controlled'));
    await tester.pump(const Duration(milliseconds: 50));
    await tester.enterText(cells('pincode-controlled').at(0), 'X');
    await tester.pump();
    expect(find.text('受控值：「X9af41」'), findsOneWidget);
    await tap(tester, keyed('pincode-random'));
    expect(find.textContaining('随机设值：「'), findsOneWidget);
    for (var i = 0; i < 6; i++) {
      expect(cell(tester, 'pincode-controlled', i).controller.text.length, 1);
    }
    expect(tester.takeException(), isNull);
  });

  testWidgets('controller focus and blur drive the manual cell', (
    tester,
  ) async {
    await start(tester);
    await tester.ensureVisible(keyed('pincode-manual'));
    await tester.pump(const Duration(milliseconds: 50));
    expect(cell(tester, 'pincode-manual', 2).focusNode.hasFocus, isFalse);
    await tap(tester, keyed('pincode-focus3'));
    expect(cell(tester, 'pincode-manual', 2).focusNode.hasFocus, isTrue);
    await tap(tester, keyed('pincode-blur'));
    expect(cell(tester, 'pincode-manual', 2).focusNode.hasFocus, isFalse);
    expect(tester.takeException(), isNull);
  });
}
