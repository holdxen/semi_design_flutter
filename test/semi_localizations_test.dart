import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:semi_design_flutter/semi_design_flutter.dart';

void main() {
  test('built-in locales expose translated dynamic labels', () {
    expect(SemiLocalizations.zhCN.totalPages(3), '总页数：3');
    expect(SemiLocalizations.enUS.totalPages(3), 'Total pages: 3');
    expect(SemiLocalizations.zhCN.monthTitle(2026, 11), '2026年 11月');
    expect(SemiLocalizations.enUS.monthTitle(2026, 11), 'November 2026');
    expect(
      SemiLocalizations.forLocale(const Locale('fr', 'FR')),
      same(SemiLocalizations.zhCN),
    );
  });

  testWidgets('SemiApp installs and switches Semi localizations', (
    tester,
  ) async {
    await tester.pumpWidget(
      const SemiApp(locale: Locale('en', 'US'), home: _LocalizedProbe()),
    );
    expect(find.text('Total pages: 3'), findsOneWidget);
    expect(find.text('No data'), findsOneWidget);

    await tester.pumpWidget(
      const SemiApp(locale: Locale('zh', 'CN'), home: _LocalizedProbe()),
    );
    expect(find.text('总页数：3'), findsOneWidget);
    expect(find.text('暂无数据'), findsOneWidget);
  });

  testWidgets('unsupported locale falls back to Simplified Chinese', (
    tester,
  ) async {
    await tester.pumpWidget(
      const SemiApp(locale: Locale('fr', 'FR'), home: _LocalizedProbe()),
    );
    expect(find.text('总页数：3'), findsOneWidget);
    expect(find.text('暂无数据'), findsOneWidget);
  });
}

class _LocalizedProbe extends StatelessWidget {
  const _LocalizedProbe();

  @override
  Widget build(BuildContext context) {
    final strings = SemiLocalizations.of(context);
    return Column(
      children: [Text(strings.totalPages(3)), Text(strings.noData)],
    );
  }
}
