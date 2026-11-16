// 临时探针：渲染 card 形态页签并抓 golden 图，用于与官方视觉对账。
// 运行：flutter test --update-goldens test/probe_tabs_card_test.dart
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:semi_design_flutter/semi_design_flutter.dart';

Widget host(Widget child) => SemiTheme(
  data: const SemiThemeData.light(),
  child: Directionality(
    textDirection: TextDirection.ltr,
    child: MediaQuery(
      data: const MediaQueryData(size: Size(420, 120)),
      child: Center(child: child),
    ),
  ),
);

List<SemiTabData> tabs() => const [
  SemiTabData(itemKey: '1', tab: 'Tab 1'),
  SemiTabData(itemKey: '2', tab: 'Tab 2'),
  SemiTabData(itemKey: '3', tab: 'Tab 3'),
];

Future<void> shot(WidgetTester tester, Widget child, String name) async {
  await tester.pumpWidget(host(child));
  await tester.pump();
  await expectLater(
    find.byType(SemiTabs),
    matchesGoldenFile('goldens/probe_tabs_card_$name.png'),
  );
}

void main() {
  testWidgets('probe card top', (tester) async {
    await tester.binding.setSurfaceSize(const Size(420, 120));
    await shot(
      tester,
      SizedBox(
        width: 380,
        child: SemiTabs(
          type: SemiTabsType.card,
          tabList: tabs(),
          defaultActiveKey: '2',
          tabPaneMotion: false,
        ),
      ),
      'top',
    );
  });

  testWidgets('probe card top small/medium', (tester) async {
    await tester.binding.setSurfaceSize(const Size(420, 120));
    for (final (size, name) in [
      (SemiTabsSize.small, 'small'),
      (SemiTabsSize.medium, 'medium'),
    ]) {
      await shot(
        tester,
        SizedBox(
          width: 380,
          child: SemiTabs(
            type: SemiTabsType.card,
            size: size,
            tabList: tabs(),
            defaultActiveKey: '1',
            tabPaneMotion: false,
          ),
        ),
        'top_$name',
      );
    }
  });

  testWidgets('probe card left', (tester) async {
    await tester.binding.setSurfaceSize(const Size(300, 220));
    await shot(
      tester,
      SizedBox(
        width: 260,
        height: 180,
        child: SemiTabs(
          type: SemiTabsType.card,
          tabPosition: SemiTabsPosition.left,
          tabList: tabs(),
          defaultActiveKey: '2',
          tabPaneMotion: false,
        ),
      ),
      'left',
    );
  });
}
