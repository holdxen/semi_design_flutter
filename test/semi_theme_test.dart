import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:semi_design_flutter/semi_design_flutter.dart';

void main() {
  testWidgets('uses light fallback without an ancestor', (tester) async {
    await tester.pumpWidget(
      Builder(
        builder: (context) {
          expect(SemiTheme.maybeOf(context), isNull);
          expect(SemiTheme.of(context).dark, isFalse);
          return const SizedBox();
        },
      ),
    );
  });

  testWidgets('nearest theme overrides the outer theme', (tester) async {
    await tester.pumpWidget(
      SemiTheme(
        data: const SemiThemeData.dark(),
        child: Builder(
          builder: (context) {
            expect(SemiTheme.of(context).dark, isTrue);
            return SemiTheme(
              data: const SemiThemeData.light(),
              child: Builder(
                builder: (context) {
                  expect(SemiTheme.of(context).dark, isFalse);
                  return const SizedBox();
                },
              ),
            );
          },
        ),
      ),
    );
  });

  testWidgets('notifies dependents only when theme values change', (
    tester,
  ) async {
    var builds = 0;
    final child = Builder(
      builder: (context) {
        builds++;
        SemiTheme.of(context);
        return const SizedBox();
      },
    );
    await tester.pumpWidget(
      SemiTheme(data: const SemiThemeData.light(), child: child),
    );
    expect(builds, 1);
    await tester.pumpWidget(
      SemiTheme(data: const SemiThemeData.dark(), child: child),
    );
    expect(builds, 2);
    await tester.pumpWidget(
      SemiTheme(data: const SemiThemeData.dark(), child: child),
    );
    expect(builds, 2);
  });

  testWidgets('captureAll preserves the theme in another subtree', (
    tester,
  ) async {
    late Widget captured;
    await tester.pumpWidget(
      SemiTheme(
        data: const SemiThemeData.dark(),
        child: Builder(
          builder: (context) {
            captured = InheritedTheme.captureAll(
              context,
              Builder(
                builder: (context) {
                  expect(SemiTheme.of(context).dark, isTrue);
                  return const SizedBox();
                },
              ),
            );
            return const SizedBox();
          },
        ),
      ),
    );
    await tester.pumpWidget(captured);
  });
}
