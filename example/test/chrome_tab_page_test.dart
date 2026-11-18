import 'package:example/pages/chrome_tab.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('ChromeTab gallery page renders', (tester) async {
    await tester.binding.setSurfaceSize(const Size(1200, 900));
    addTearDown(() async => tester.pumpWidget(const SizedBox.shrink()));
    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: MediaQuery(
          data: const MediaQueryData(size: Size(1200, 900)),
          child: const ChromeTabPage(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('ChromeTab'), findsOneWidget);
    expect(find.text('首页'), findsNWidgets(2));
    expect(find.byKey(const ValueKey('chrome-tab-status')), findsOneWidget);
  });
}
