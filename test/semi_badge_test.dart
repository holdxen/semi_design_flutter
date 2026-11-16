import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:semi_design_flutter/semi_design_flutter.dart';

Widget host(Widget child, {bool rtl = false, SemiThemeData? theme}) =>
    SemiTheme(
      data: theme ?? const SemiThemeData.light(),
      child: Directionality(
        textDirection: rtl ? TextDirection.rtl : TextDirection.ltr,
        child: Center(child: child),
      ),
    );

/// The badge box (`-dot`/`-count` 装饰盒；child 不含 DecoratedBox 时唯一)。
Finder badgeBox() => find.descendant(
  of: find.byType(SemiBadge),
  matching: find.byType(DecoratedBox),
);

void main() {
  BoxDecoration decoOf(WidgetTester tester, Finder finder) =>
      tester.widget<DecoratedBox>(finder).decoration as BoxDecoration;

  testWidgets('count num/string, overflowCount 门与整数归一', (tester) async {
    await tester.pumpWidget(
      host(const SemiBadge(count: 5, child: SizedBox(width: 40, height: 40))),
    );
    expect(find.text('5'), findsOneWidget);
    final box = tester.getRect(
      find.ancestor(of: find.text('5'), matching: find.byType(DecoratedBox)),
    );
    // `-count`：`$height-badge_count` 18 高（border-box 含 1px 描边）。
    expect(box.height, 18);
    expect(box.width, greaterThanOrEqualTo(18));

    await tester.pumpWidget(
      host(
        const SemiBadge(count: 'semi', child: SizedBox(width: 40, height: 40)),
      ),
    );
    expect(find.text('semi'), findsOneWidget);

    // `overflowCount && overflowCount < count` → `${overflowCount}+`。
    await tester.pumpWidget(
      host(
        const SemiBadge(
          count: 99,
          overflowCount: 5,
          child: SizedBox(width: 40, height: 40),
        ),
      ),
    );
    expect(find.text('5+'), findsOneWidget);

    // count 未超限不格式化。
    await tester.pumpWidget(
      host(
        const SemiBadge(
          count: 3,
          overflowCount: 5,
          child: SizedBox(width: 40, height: 40),
        ),
      ),
    );
    expect(find.text('3'), findsOneWidget);

    // ★overflowCount 0 等 falsy 不溢出（JS `overflowCount && …` 照搬）。
    await tester.pumpWidget(
      host(
        const SemiBadge(
          count: 99,
          overflowCount: 0,
          child: SizedBox(width: 40, height: 40),
        ),
      ),
    );
    expect(find.text('99'), findsOneWidget);

    // JS String(N) 语义：整数值 double 不带 `.0`。
    await tester.pumpWidget(
      host(const SemiBadge(count: 5.0, child: SizedBox(width: 40, height: 40))),
    );
    expect(find.text('5'), findsOneWidget);
    await tester.pumpWidget(
      host(const SemiBadge(count: 5.5, child: SizedBox(width: 40, height: 40))),
    );
    expect(find.text('5.5'), findsOneWidget);
  });

  testWidgets('dot 8x8 掩蔽 count，空串出空胶囊', (tester) async {
    await tester.pumpWidget(
      host(
        const SemiBadge(
          dot: true,
          count: 1,
          child: SizedBox(width: 40, height: 40),
        ),
      ),
    );
    // `dot ? null : content`。
    expect(find.text('1'), findsNothing);
    expect(tester.getSize(badgeBox()), const Size(8, 8));

    // `count !== null && typeof count !== 'undefined'`：空串仍出 `-count` 盒，
    // min-width `$height-badge_count` 兜底成 18。
    await tester.pumpWidget(
      host(const SemiBadge(count: '', child: SizedBox(width: 40, height: 40))),
    );
    expect(find.text(''), findsOneWidget);
    final box = tester.getRect(badgeBox());
    expect(box.width, 18);
    expect(box.height, 18);

    // count null 且非 dot → 零尺寸（上游空 span）。
    await tester.pumpWidget(
      host(const SemiBadge(child: SizedBox(width: 40, height: 40))),
    );
    expect(badgeBox(), findsNothing);
    await tester.pumpWidget(host(const SemiBadge()));
    expect(tester.getSize(find.byType(SemiBadge)), Size.zero);
  });

  testWidgets('type × variant 18 组合 + danger 三色槽', (tester) async {
    for (final type in SemiBadgeType.values) {
      for (final variant in SemiBadgeVariant.values) {
        await tester.pumpWidget(
          host(
            SemiBadge(
              count: 1,
              type: type,
              variant: variant,
              child: const SizedBox(width: 40, height: 40),
            ),
          ),
        );
        expect(find.text('1'), findsOneWidget);
        expect(tester.takeException(), isNull);
      }
    }
    const light = SemiThemeData.light();
    await tester.pumpWidget(
      host(
        const SemiBadge(
          count: 1,
          type: SemiBadgeType.danger,
          variant: SemiBadgeVariant.solid,
          child: SizedBox(width: 40, height: 40),
        ),
      ),
    );
    expect(decoOf(tester, badgeBox()).color, light.colors.colorDanger);
    await tester.pumpWidget(
      host(
        const SemiBadge(
          count: 1,
          type: SemiBadgeType.danger,
          variant: SemiBadgeVariant.light,
          child: SizedBox(width: 40, height: 40),
        ),
      ),
    );
    final lightDeco = decoOf(tester, badgeBox());
    expect(lightDeco.color, light.colors.colorDangerLightDefault);
    expect(
      tester.widget<Text>(find.text('1')).style?.color,
      light.colors.colorDanger,
    );
    await tester.pumpWidget(
      host(
        const SemiBadge(
          count: 1,
          type: SemiBadgeType.danger,
          variant: SemiBadgeVariant.inverted,
          child: SizedBox(width: 40, height: 40),
        ),
      ),
    );
    // inverted 只换字：底留 `$color-badge_default-bg-default`。
    expect(decoOf(tester, badgeBox()).color, light.colors.colorBg1);
    expect(
      tester.widget<Text>(find.text('1')).style?.color,
      light.colors.colorDanger,
    );
    // 描边恒 `$color-badge_default-border-default`。
    final border = decoOf(tester, badgeBox()).border as Border;
    expect(border.top.color, light.colors.colorBg1);
    expect(border.top.width, 1);
  });

  testWidgets('四角锚定与 FractionalTranslation 偏移', (tester) async {
    for (final (position, anchor) in [
      (SemiBadgePosition.rightTop, Alignment.topRight),
      (SemiBadgePosition.rightBottom, Alignment.bottomRight),
      (SemiBadgePosition.leftTop, Alignment.topLeft),
      (SemiBadgePosition.leftBottom, Alignment.bottomLeft),
    ]) {
      await tester.pumpWidget(
        host(
          SemiBadge(
            dot: true,
            position: position,
            child: const SizedBox(width: 40, height: 40),
          ),
        ),
      );
      final childRect = tester.getRect(find.byType(SemiBadge));
      final center = tester.getCenter(badgeBox());
      final target = anchor.alongSize(childRect.size) + childRect.topLeft;
      // `transform: translate(±50%, ±50%)`：盒中心正落角点。
      expect(center.dx, closeTo(target.dx, 0.001), reason: '$position');
      expect(center.dy, closeTo(target.dy, 0.001), reason: '$position');
      expect(tester.takeException(), isNull);
    }
  });

  testWidgets('rtl 缺省 leftTop，显式 position 不随方向翻', (tester) async {
    // `direction === 'rtl' ? 'leftTop' : 'rightTop'`。
    await tester.pumpWidget(
      host(
        const SemiBadge(dot: true, child: SizedBox(width: 40, height: 40)),
        rtl: true,
      ),
    );
    final childRect = tester.getRect(find.byType(SemiBadge));
    final center = tester.getCenter(badgeBox());
    expect(center.dx, closeTo(childRect.left, 0.001));
    expect(center.dy, closeTo(childRect.top, 0.001));
    await tester.pumpWidget(
      host(const SemiBadge(dot: true, child: SizedBox(width: 40, height: 40))),
    );
    final ltrRect = tester.getRect(find.byType(SemiBadge));
    final ltrCenter = tester.getCenter(badgeBox());
    expect(ltrCenter.dx, closeTo(ltrRect.right, 0.001));
    expect(ltrCenter.dy, closeTo(ltrRect.top, 0.001));
    // 物理锚角（CSS top/right/left/bottom）：rtl 下显式 rightTop 仍在右上。
    await tester.pumpWidget(
      host(
        const SemiBadge(
          dot: true,
          position: SemiBadgePosition.rightTop,
          child: SizedBox(width: 40, height: 40),
        ),
        rtl: true,
      ),
    );
    final rtlRect = tester.getRect(find.byType(SemiBadge));
    final rtlCenter = tester.getCenter(badgeBox());
    expect(rtlCenter.dx, closeTo(rtlRect.right, 0.001));
  });

  testWidgets('无 child 独立展示（-block）', (tester) async {
    await tester.pumpWidget(host(const SemiBadge(dot: true)));
    expect(tester.getSize(badgeBox()), const Size(8, 8));
    await tester.pumpWidget(host(const SemiBadge(count: 12)));
    expect(find.text('12'), findsOneWidget);
    expect(tester.getSize(find.byType(SemiBadge)).height, 18);
  });

  testWidgets('custom count 原样渲染且不吃 type/variant 颜色', (tester) async {
    await tester.pumpWidget(
      host(
        const SemiBadge(
          count: Text('hi'),
          type: SemiBadgeType.danger,
          variant: SemiBadgeVariant.solid,
          child: SizedBox(width: 40, height: 40),
        ),
      ),
    );
    expect(find.text('hi'), findsOneWidget);
    // `!custom` 才挂 `-{type}`/`-{theme}`：custom 无装饰盒。
    expect(badgeBox(), findsNothing);
    // dot 优先于 custom 内容（`dot ? null : content`）。
    await tester.pumpWidget(
      host(
        const SemiBadge(
          dot: true,
          count: Text('hidden'),
          child: SizedBox(width: 40, height: 40),
        ),
      ),
    );
    expect(find.text('hidden'), findsNothing);
    expect(tester.getSize(badgeBox()), const Size(8, 8));
  });

  testWidgets('onTap、类型断言与全局/局部主题', (tester) async {
    var taps = 0;
    await tester.pumpWidget(
      host(
        SemiBadge(
          dot: true,
          onTap: () => taps++,
          child: const SizedBox(width: 40, height: 40),
        ),
      ),
    );
    await tester.tap(find.byType(SemiBadge));
    expect(taps, 1);
    expect(() => SemiBadge(count: Object()), throwsAssertionError);

    // 全局组件主题覆盖。
    final custom = const SemiThemeData.light(
      components: SemiComponentThemes(
        badge: SemiBadgeThemeData(
          colorBadgeDangerSolidBgDefault: Color(0xff123456),
        ),
      ),
    );
    await tester.pumpWidget(
      host(
        const SemiBadge(
          count: 1,
          type: SemiBadgeType.danger,
          variant: SemiBadgeVariant.solid,
          child: SizedBox(width: 40, height: 40),
        ),
        theme: custom,
      ),
    );
    expect(decoOf(tester, badgeBox()).color, const Color(0xff123456));
    // 局部 patch 逐层覆盖（inverted 底走 default 槽）。
    await tester.pumpWidget(
      host(
        SemiBadgeTheme(
          data: const SemiBadgeThemeData(
            colorBadgeDefaultBgDefault: Color(0xff654321),
          ),
          child: const SemiBadge(
            count: 1,
            variant: SemiBadgeVariant.inverted,
            child: SizedBox(width: 40, height: 40),
          ),
        ),
      ),
    );
    expect(decoOf(tester, badgeBox()).color, const Color(0xff654321));
    // 暗色解析烟测。
    await tester.pumpWidget(
      host(
        const SemiBadge(count: 1, child: SizedBox(width: 40, height: 40)),
        theme: const SemiThemeData.dark(),
      ),
    );
    expect(tester.takeException(), isNull);
  });
}
