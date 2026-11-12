import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:semi_design_flutter/semi_design_flutter.dart';

Widget host(Widget child) => SemiTheme(
  data: const SemiThemeData.light(),
  child: Directionality(
    textDirection: TextDirection.ltr,
    child: Center(child: child),
  ),
);

void main() {
  testWidgets('prefix suffix and icon slots center on the wrapper axis', (
    tester,
  ) async {
    await tester.pumpWidget(
      host(
        const SizedBox(
          width: 320,
          child: SemiInput(
            size: SemiInputSize.large,
            prefix: '价格',
            suffix: '元',
            placeholder: '金额',
          ),
        ),
      ),
    );
    final wrapper = tester.getRect(find.byType(SemiInput));
    expect(wrapper.height, 40);
    for (final text in ['价格', '元']) {
      final slot = tester.getRect(find.text(text));
      expect(
        slot.center.dy,
        closeTo(wrapper.center.dy, 0.5),
        reason: '$text should be vertically centered',
      );
    }
    expect(tester.takeException(), isNull);
  });

  testWidgets('icon and inset label slots center as well', (tester) async {
    await tester.pumpWidget(
      host(
        const SizedBox(
          width: 320,
          child: SemiInput(
            size: SemiInputSize.large,
            insetLabel: '名称',
            suffix: Icon0(),
            placeholder: '内容',
          ),
        ),
      ),
    );
    final wrapper = tester.getRect(find.byType(SemiInput));
    final label = tester.getRect(find.text('名称'));
    expect(label.center.dy, closeTo(wrapper.center.dy, 0.5));
    final icon = tester.getRect(find.byType(Icon0));
    expect(icon.center.dy, closeTo(wrapper.center.dy, 0.5));
    expect(tester.takeException(), isNull);
  });

  testWidgets('custom widget slots center too', (tester) async {
    await tester.pumpWidget(
      host(
        SizedBox(
          width: 320,
          child: SemiInput(
            size: SemiInputSize.large,
            prefix: Container(
              width: 18,
              height: 18,
              color: const Color(0xff7b61ff),
            ),
            placeholder: '自定义前缀',
          ),
        ),
      ),
    );
    final wrapper = tester.getRect(find.byType(SemiInput));
    final custom = tester.getRect(find.byType(Container).first);
    expect(custom.center.dy, closeTo(wrapper.center.dy, 0.5));
    expect(tester.takeException(), isNull);
  });
}

/// Marker widget standing in for an arbitrary custom slot widget.
class Icon0 extends StatelessWidget {
  const Icon0({super.key});

  @override
  Widget build(BuildContext context) => const SizedBox(width: 16, height: 16);
}
