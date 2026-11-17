import 'package:example/pages/form.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:semi_design_flutter/semi_design_flutter.dart';

Finder keyed(String key) => find.byKey(ValueKey(key));

Finder statusContaining(String text) => find.descendant(
  of: keyed('form-status'),
  matching: find.textContaining(text),
);

Future<void> start(WidgetTester tester) async {
  addTearDown(() async => tester.pumpWidget(const SizedBox.shrink()));
  await tester.pumpWidget(const SemiApp(home: FormPage()));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('submit with empty required field reports onSubmitFail; filling '
      'it reports onSubmit', (tester) async {
    await start(tester);
    // initValues 预填了 name——先清空再提交走 fail 路径。
    await tester.enterText(find.byType(SemiInput).at(0), '');
    await tester.pumpAndSettle();
    await tester.tap(find.text('提交'));
    await tester.pumpAndSettle();
    expect(statusContaining('onSubmitFail'), findsOneWidget);
    expect(find.text('名称必填'), findsOneWidget);
    await tester.enterText(find.byType(SemiInput).at(0), 'Flutter');
    await tester.pumpAndSettle();
    await tester.tap(find.text('提交'));
    await tester.pumpAndSettle();
    expect(statusContaining('onSubmit'), findsOneWidget);
  });

  testWidgets('async validator reports and clears after the delay', (
    tester,
  ) async {
    await start(tester);
    final asyncInput = find.byType(SemiInput).at(2);
    await tester.enterText(asyncInput, 'no');
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 350));
    expect(find.text('试试输入 ok'), findsOneWidget);
    await tester.enterText(asyncInput, 'ok');
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 350));
    expect(find.text('试试输入 ok'), findsNothing);
  });

  testWidgets('ArrayField adds a row and reports the values', (tester) async {
    await start(tester);
    await tester.ensureVisible(find.text('添加一行'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('添加一行'));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('读取 people'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('读取 people'));
    await tester.pumpAndSettle();
    expect(statusContaining('people'), findsOneWidget);
  });
}
