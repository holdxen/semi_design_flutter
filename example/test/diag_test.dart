import 'package:example/pages/select.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:semi_design_flutter/semi_design_flutter.dart';

Finder keyed(String key) => find.byKey(ValueKey(key));
int popups() => find.byType(SemiTooltipPopup).evaluate().length;

void main() {
  testWidgets('trace the create flow on the page', (tester) async {
    addTearDown(() async => tester.pumpWidget(const SizedBox.shrink()));
    await tester.pumpWidget(const SemiApp(home: SelectPage()));
    await tester.pump(const Duration(milliseconds: 50));
    await tester.ensureVisible(keyed('select-create'));
    await tester.pump(const Duration(milliseconds: 50));
    await tester.tap(keyed('select-create'));
    await tester.pump(const Duration(milliseconds: 150));
    await tester.pump(const Duration(milliseconds: 150));
    // ignore: avoid_print
    print('after open: popups=${popups()}');
    await tester.enterText(
      find.descendant(
        of: keyed('select-create'),
        matching: find.byType(EditableText),
      ),
      '新条目',
    );
    await tester.pump(const Duration(milliseconds: 100));
    // ignore: avoid_print
    print('after type: popups=${popups()} createRows=${find.textContaining('新条目').evaluate().length}');
    // Warmup exactly like the page test helper.
    await tester.tapAt(const Offset(700, 500));
    await tester.pump();
    // ignore: avoid_print
    print('after warmup: popups=${popups()}');
    await tester.tap(find.textContaining('新条目').last);
    await tester.pump(const Duration(milliseconds: 100));
    // ignore: avoid_print
    print('after create tap: popups=${popups()} status=${find.textContaining('创建了').evaluate().length}');
    // ignore: avoid_print
    print('done');
  });
}
