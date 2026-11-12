import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:semi_design_flutter/semi_design_flutter.dart';

Widget host(Widget child) => SemiTheme(
  data: const SemiThemeData.light(),
  child: Directionality(
    textDirection: TextDirection.ltr,
    child: MediaQuery(
      data: const MediaQueryData(),
      child: Center(child: child),
    ),
  ),
);

bool focused(WidgetTester tester, Finder scope) => tester
    .widget<EditableText>(
      find.descendant(of: scope, matching: find.byType(EditableText)),
    )
    .focusNode
    .hasFocus;

/// Tap [point], requiring a fresh focus win each time (the previous tap's
/// focus is dropped first so a dead zone cannot pass by accident).
Future<void> tapExpectFocus(
  WidgetTester tester,
  Finder scope,
  Offset point,
) async {
  FocusManager.instance.primaryFocus?.unfocus();
  await tester.pump();
  expect(
    focused(tester, scope),
    isFalse,
    reason: 'precondition: field must be unfocused before tap at $point',
  );
  await tester.tapAt(point);
  await tester.pump();
  expect(
    focused(tester, scope),
    isTrue,
    reason: 'tap at $point should focus the field',
  );
}

void main() {
  testWidgets('tapping anywhere inside an empty textarea focuses it', (
    tester,
  ) async {
    await tester.pumpWidget(
      host(
        const SizedBox(
          width: 320,
          child: SemiTextArea(rows: 3, placeholder: '内容'),
        ),
      ),
    );
    final box = tester.getRect(find.byType(SemiTextArea));
    expect(box.height, greaterThan(50));
    final scope = find.byType(SemiTextArea);
    // Interior (used to hit the zero-width EditableText only at top-left)…
    await tapExpectFocus(tester, scope, box.center);
    // …and the padding strips around the text area, which used to be dead
    // zones: the bottom-right corner and the top-left padding band.
    await tapExpectFocus(tester, scope, box.bottomRight - const Offset(8, 8));
    await tapExpectFocus(tester, scope, box.topLeft + const Offset(6, 6));
    expect(tester.takeException(), isNull);
  });

  testWidgets('tapping the empty area of a single-line input focuses it', (
    tester,
  ) async {
    await tester.pumpWidget(
      host(const SizedBox(width: 320, child: SemiInput(placeholder: '输入'))),
    );
    final box = tester.getRect(find.byType(SemiInput));
    final scope = find.byType(SemiInput);
    // To the right of the placeholder text and in both padding bands —
    // all outside the old intrinsic-width EditableText.
    await tapExpectFocus(tester, scope, Offset(box.right - 10, box.center.dy));
    await tapExpectFocus(tester, scope, Offset(box.left + 6, box.center.dy));
    await tapExpectFocus(tester, scope, box.center);
    expect(tester.takeException(), isNull);
  });
}
