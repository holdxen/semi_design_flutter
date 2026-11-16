import 'package:example/pages/scroll_list.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:semi_design_flutter/semi_design_flutter.dart';

Future<void> start(WidgetTester tester) async {
  addTearDown(() async => tester.pumpWidget(const SizedBox.shrink()));
  await tester.binding.setSurfaceSize(const Size(1200, 2400));
  await tester.pumpWidget(const SemiApp(home: ScrollListPage()));
  await tester.pump(const Duration(milliseconds: 100));
}

void main() {
  testWidgets('page renders every demo section', (tester) async {
    await start(tester);
    for (final title in [
      '基本用法（wheel 滚轮）',
      'normal 模式',
      'cycled 无限循环',
      'transform 与禁用项',
      'bodyHeight',
    ]) {
      expect(find.text(title), findsOneWidget);
      await tester.ensureVisible(find.text(title));
      await tester.pump(const Duration(milliseconds: 100));
      expect(tester.takeException(), isNull);
    }
    expect(find.byType(SemiScrollList), findsNWidgets(5));
    expect(find.byType(SemiScrollItem), findsNWidgets(6));
  });

  testWidgets('normal 点选联动受控文案', (tester) async {
    await start(tester);
    await tester.ensureVisible(find.text('normal 模式'));
    await tester.pump(const Duration(milliseconds: 100));
    expect(find.text('点选列表（选中 0）'), findsOneWidget);

    await tester.tap(find.text('条目 2'));
    await tester.pump(const Duration(milliseconds: 100));
    expect(find.text('点选列表（选中 2）'), findsOneWidget);
  });

  testWidgets('transform 只作用于选中行、禁用行不可点', (tester) async {
    await start(tester);
    await tester.ensureVisible(find.text('transform 与禁用项'));
    await tester.pump(const Duration(milliseconds: 100));
    // selectedIndex 1 → transform 文案。
    expect(find.text('已选：行 1'), findsOneWidget);
    expect(find.text('行 1'), findsNothing);

    // 第 4 项（index 3）禁用——点击不移位。
    await tester.tap(find.text('行 3'), warnIfMissed: false);
    await tester.pump(const Duration(milliseconds: 100));
    expect(find.text('已选：行 1'), findsOneWidget);
  });
}
