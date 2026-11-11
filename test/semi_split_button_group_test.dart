import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:semi_design_flutter/semi_design_flutter.dart';

SemiResolvedButtonThemeData resolve() =>
    const SemiButtonThemeData().resolve(const SemiThemeData.light());

Widget host(Widget child, {bool rtl = false}) => SemiTheme(
  data: const SemiThemeData.light(),
  child: Directionality(
    textDirection: rtl ? TextDirection.rtl : TextDirection.ltr,
    child: Center(child: child),
  ),
);

BoxDecoration box(WidgetTester tester, int index) {
  final match = find.descendant(
    of: find.byType(SemiButton).at(index),
    matching: find.byType(AnimatedContainer),
  );
  return tester.widget<AnimatedContainer>(match).decoration! as BoxDecoration;
}

void main() {
  testWidgets('children keep order with 1px gaps between them', (tester) async {
    await tester.pumpWidget(
      host(
        SemiSplitButtonGroup(
          semanticsLabel: '分裂按钮',
          children: [
            SemiButton('一', onPressed: () {}),
            SemiButton('二', onPressed: () {}),
            SemiButton('三', onPressed: () {}),
          ],
        ),
      ),
    );
    expect(find.text('一'), findsOneWidget);
    expect(find.text('二'), findsOneWidget);
    expect(find.text('三'), findsOneWidget);
    final first = tester.getRect(find.byType(SemiButton).at(0));
    final second = tester.getRect(find.byType(SemiButton).at(1));
    final third = tester.getRect(find.byType(SemiButton).at(2));
    // Upstream `margin-right: 1px` (reset on the last child).
    expect(second.left - first.right, closeTo(1, 0.01));
    expect(third.left - second.right, closeTo(1, 0.01));
  });

  testWidgets('only outer corners round, one physical token each', (
    tester,
  ) async {
    final t = resolve();
    await tester.pumpWidget(
      host(
        SemiSplitButtonGroup(
          children: [
            SemiButton('一', onPressed: () {}),
            SemiButton('二', onPressed: () {}),
            SemiButton('三', onPressed: () {}),
          ],
        ),
      ),
    );
    final zero = Radius.zero;
    final first = box(tester, 0).borderRadius! as BorderRadius;
    expect(
      first.topLeft,
      Radius.circular(t.radiusButtonSplitButtonGroupFirstTopLeft),
    );
    expect(
      first.bottomLeft,
      Radius.circular(t.radiusButtonSplitButtonGroupFirstBottomLeft),
    );
    expect(first.topRight, zero);
    expect(first.bottomRight, zero);

    final middle = box(tester, 1).borderRadius! as BorderRadius;
    expect(middle, BorderRadius.zero);

    final last = box(tester, 2).borderRadius! as BorderRadius;
    expect(last.topLeft, zero);
    expect(last.bottomLeft, zero);
    expect(
      last.topRight,
      Radius.circular(t.radiusButtonSplitButtonGroupLastTopRight),
    );
    expect(
      last.bottomRight,
      Radius.circular(t.radiusButtonSplitButtonGroupLastBottomRight),
    );
  });

  testWidgets('a single button receives all four corner tokens', (
    tester,
  ) async {
    final t = resolve();
    await tester.pumpWidget(
      host(
        SemiSplitButtonGroup(children: [SemiButton('唯一', onPressed: () {})]),
      ),
    );
    final radius = box(tester, 0).borderRadius! as BorderRadius;
    expect(
      radius.topLeft,
      Radius.circular(t.radiusButtonSplitButtonGroupFirstTopLeft),
    );
    expect(
      radius.topRight,
      Radius.circular(t.radiusButtonSplitButtonGroupLastTopRight),
    );
    expect(
      radius.bottomLeft,
      Radius.circular(t.radiusButtonSplitButtonGroupFirstBottomLeft),
    );
    expect(
      radius.bottomRight,
      Radius.circular(t.radiusButtonSplitButtonGroupLastBottomRight),
    );
  });

  testWidgets('first and last flags follow the button children only', (
    tester,
  ) async {
    await tester.pumpWidget(
      host(
        SemiSplitButtonGroup(
          children: [
            const SizedBox(width: 8),
            SemiButton('一', onPressed: () {}),
            SemiButton('二', onPressed: () {}),
            const SizedBox(width: 8),
          ],
        ),
      ),
    );
    // Leading/trailing non-button children leave the first/last buttons as
    // the rounded pair (upstream marks button DOM descendants).
    final first = box(tester, 0).borderRadius! as BorderRadius;
    final last = box(tester, 1).borderRadius! as BorderRadius;
    expect(first.topLeft, isNot(Radius.zero));
    expect(first.topRight, Radius.zero);
    expect(last.topRight, isNot(Radius.zero));
    expect(last.topLeft, Radius.zero);
  });

  testWidgets('group label is exposed and no scope is injected', (
    tester,
  ) async {
    await tester.pumpWidget(
      host(
        SemiSplitButtonGroup(
          semanticsLabel: '分裂按钮',
          children: [SemiButton('一', onPressed: () {})],
        ),
      ),
    );
    expect(find.bySemanticsLabel('分裂按钮'), findsOneWidget);
    // Split groups must not inject a SemiButtonScope (no padding reset or
    // prop merge): the button keeps its own defaults.
    expect(find.byType(SemiButtonScope), findsNothing);
  });

  testWidgets('physical corner tokens do not mirror under RTL', (tester) async {
    final t = resolve();
    await tester.pumpWidget(
      host(
        SemiSplitButtonGroup(
          children: [
            SemiButton('一', onPressed: () {}),
            SemiButton('二', onPressed: () {}),
          ],
        ),
        rtl: true,
      ),
    );
    // Upstream splitButtonGroup.scss uses physical corner names and the
    // rtl.scss never mirrors them: the first child keeps the *Left* tokens.
    final first = box(tester, 0).borderRadius! as BorderRadius;
    expect(
      first.topLeft,
      Radius.circular(t.radiusButtonSplitButtonGroupFirstTopLeft),
    );
    expect(first.topRight, Radius.zero);
  });
}
