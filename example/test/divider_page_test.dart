import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:semi_design_flutter/semi_design_flutter.dart';

import 'package:example/pages/divider.dart';

void main() {
  testWidgets('DividerPage shows all four divider examples', (tester) async {
    tester.view.physicalSize = const Size(360, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const SemiApp(home: DividerPage()));

    expect(tester.takeException(), isNull);
    for (final title in ['水平实线', '水平虚线', '垂直实线', '垂直虚线']) {
      expect(find.text(title), findsOneWidget);
    }
    final dividers = tester.widgetList<SemiDivider>(find.byType(SemiDivider));
    expect(dividers.length, 10);
    expect(dividers.every((divider) => divider.margin == 12), isTrue);
    expect(
      dividers
          .where((divider) => divider.layout == SemiDividerLayout.vertical)
          .length,
      4,
    );
    expect(dividers.where((divider) => divider.dashed).length, 3);
    expect(find.text('左'), findsNWidgets(2));
    expect(find.text('中'), findsNWidgets(2));
    expect(find.text('右'), findsNWidgets(2));
    for (final entry in {
      '这是居左文字': SemiDividerAlign.left,
      '这是居中文字': SemiDividerAlign.center,
      '这是居右文字': SemiDividerAlign.right,
    }.entries) {
      expect(find.text(entry.key), findsOneWidget);
      expect(
        dividers.singleWhere((d) => d.text == entry.key).align,
        entry.value,
      );
    }
    final logo = find.byType(SemiIcon);
    expect(logo, findsOneWidget);
    await tester.ensureVisible(logo);
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });
}
