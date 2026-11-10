import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:semi_design_flutter/semi_design_flutter.dart';

void main() {
  test('all Sass defaults and live global references', () {
    const patch = SemiDividerThemeData();
    final theme = const SemiThemeData.light();
    final resolved = patch.resolve(theme);
    expect(resolved.horizontalMargin, const EdgeInsets.symmetric(vertical: 1));
    expect(resolved.verticalMargin, const EdgeInsets.symmetric(horizontal: 1));
    expect(resolved.textPadding, const EdgeInsets.symmetric(horizontal: 8));
    expect(resolved.leftLineWidth, 40);
    expect(resolved.rightLineWidth, 40);
    expect(resolved.thickness, 1);
    expect(resolved.verticalHeight, 20);
    expect(resolved.color, theme.colors.colorBorder);
    expect(resolved.textColor, theme.colors.colorText0);
    expect(resolved.fontWeight, theme.typography.fontWeightBold);
    final updated = theme.copyWith(
      typography: theme.typography.copyWith(
        fontWeightBold: FontWeight.w900,
        fontSizeRegular: 19,
      ),
    );
    expect(patch.resolve(updated).fontWeight, FontWeight.w900);
    expect(patch.resolve(updated).fontSize, 19);
  });
  test('all fields copy merge equality hash and resolution', () {
    const patch = SemiDividerThemeData(
      horizontalMargin: EdgeInsets.all(2),
      verticalMargin: EdgeInsets.all(3),
      textPadding: EdgeInsets.all(4),
      leftLineWidth: 5,
      rightLineWidth: 6,
      thickness: 7,
      verticalHeight: 8,
      color: Color(0x00000009),
      textColor: Color(0x0000000a),
      fontWeight: FontWeight.w100,
      fontSize: 11,
    );
    final copied = const SemiDividerThemeData().merge(patch);
    expect(copied, patch);
    expect(copied.hashCode, patch.hashCode);
    expect(patch.copyWith(), patch);
    expect(patch.merge(null), patch);
    final resolved = patch.resolve(const SemiThemeData.dark());
    expect(resolved.horizontalMargin, patch.horizontalMargin);
    expect(resolved.verticalMargin, patch.verticalMargin);
    expect(resolved.textPadding, patch.textPadding);
    expect(resolved.leftLineWidth, 5);
    expect(resolved.rightLineWidth, 6);
    expect(resolved.thickness, 7);
    expect(resolved.verticalHeight, 8);
    expect(resolved.color, patch.color);
    expect(resolved.textColor, patch.textColor);
    expect(resolved.fontWeight, patch.fontWeight);
    expect(resolved.fontSize, 11);
    expect(const SemiComponentThemes().copyWith(divider: patch).divider, patch);
  });
  testWidgets('nested patches across global boundaries update live', (
    tester,
  ) async {
    late SemiResolvedDividerThemeData resolved;
    Widget tree(double width) => SemiTheme(
      data: const SemiThemeData.light(),
      child: SemiDividerTheme(
        data: SemiDividerThemeData(thickness: width),
        child: SemiTheme(
          data: const SemiThemeData.dark(),
          child: SemiDividerTheme(
            data: const SemiDividerThemeData(verticalHeight: 33),
            child: Builder(
              builder: (context) {
                resolved = SemiDividerTheme.resolve(context);
                return const SizedBox();
              },
            ),
          ),
        ),
      ),
    );
    await tester.pumpWidget(tree(2));
    expect(resolved.thickness, 2);
    expect(resolved.verticalHeight, 33);
    await tester.pumpWidget(tree(3));
    expect(resolved.thickness, 3);
  });
  testWidgets('horizontal vertical text dashed RTL narrow and unbounded', (
    tester,
  ) async {
    for (final direction in TextDirection.values) {
      for (final align in SemiDividerAlign.values) {
        await tester.pumpWidget(
          Directionality(
            textDirection: direction,
            child: MediaQuery(
              data: const MediaQueryData(textScaler: TextScaler.linear(2)),
              child: Center(
                child: SizedBox(
                  width: 20,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SemiDivider(
                        align: align,
                        dashed: true,
                        child: const Text('long label'),
                      ),
                      const SemiDivider(),
                      const SemiDivider(
                        layout: SemiDividerLayout.vertical,
                        margin: 4,
                        height: 30,
                      ),
                      const UnconstrainedBox(
                        child: SemiDivider(text: 'unbounded'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
        expect(tester.takeException(), isNull);
      }
    }
  });
  testWidgets('vertical size and text semantics without Material', (
    tester,
  ) async {
    final semantics = tester.ensureSemantics();
    await tester.pumpWidget(
      const Directionality(
        textDirection: TextDirection.ltr,
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SemiDivider(text: 'Visible label'),
              SemiDivider(
                layout: SemiDividerLayout.vertical,
                height: 30,
                margin: 4,
                child: Text('ignored'),
              ),
            ],
          ),
        ),
      ),
    );
    expect(tester.getSize(find.byType(SemiDivider).last), const Size(9, 30));
    expect(find.text('ignored'), findsNothing);
    expect(find.text('Visible label'), findsOneWidget);
    expect(
      tester.getSemantics(find.text('Visible label')).label,
      'Visible label',
    );
    semantics.dispose();
  });
}
