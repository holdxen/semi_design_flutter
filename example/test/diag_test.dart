import 'package:flutter/gestures.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:semi_design_flutter/semi_design_flutter.dart';

/// Golden regression for the selection highlight. `EditableText` paints no
/// selection band at all when `selectionColor` is null (RenderEditable skips a
/// null highlight), so drag-select used to form a perfectly real — but
/// invisible — selection ("text can't be selected"). The golden must show the
/// tinted band behind the selected 'ell' of 'hello world'.
void main() {
  testWidgets('drag-selected text paints the selection highlight', (
    tester,
  ) async {
    addTearDown(() async => tester.pumpWidget(const SizedBox.shrink()));
    await tester.pumpWidget(
      SemiApp(
        themeMode: SemiThemeMode.light,
        home: Center(
          child: SizedBox(
            width: 280,
            child: SemiInput(initialValue: 'hello world'),
          ),
        ),
      ),
    );
    await tester.pump(const Duration(milliseconds: 50));
    final rect = tester.getRect(find.byType(EditableText));
    final gesture = await tester.startGesture(
      Offset(rect.left + 16, rect.center.dy),
      kind: PointerDeviceKind.mouse,
    );
    await tester.pump();
    await gesture.moveTo(Offset(rect.left + 60, rect.center.dy));
    await tester.pump();
    await gesture.up();
    await tester.pumpAndSettle();
    final selection = tester
        .widget<EditableText>(find.byType(EditableText))
        .controller
        .selection;
    expect(selection.isCollapsed, isFalse);
    await expectLater(
      find.byKey(SemiInput.wrapperKey),
      matchesGoldenFile('sel_highlight.png'),
    );
    // macOS keeps the golden deterministic (cursor/selection chrome differs
    // per platform).
  }, variant: TargetPlatformVariant.only(TargetPlatform.macOS));
}
