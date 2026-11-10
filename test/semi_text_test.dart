import 'package:flutter/gestures.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:semi_design_flutter/semi_design_flutter.dart';

Widget host(
  Widget child, {
  SemiThemeData theme = const SemiThemeData.light(),
  TextDirection direction = TextDirection.ltr,
  TextStyle style = const TextStyle(fontSize: 23, height: 1.7),
  double scale = 1,
}) => MediaQuery(
  data: MediaQueryData(textScaler: TextScaler.linear(scale)),
  child: Directionality(
    textDirection: direction,
    child: SemiTheme(
      data: theme,
      child: DefaultTextStyle(
        style: style,
        child: Center(child: child),
      ),
    ),
  ),
);
TextStyle textStyle(WidgetTester t) =>
    t.widget<Text>(find.byType(Text).first).style!;

void main() {
  testWidgets('all types, sizes, and inherited defaults without Material', (
    t,
  ) async {
    final c = const SemiThemeData.light().colors;
    final colors = [
      c.colorText0,
      c.colorText1,
      c.colorText2,
      c.colorText3,
      c.colorWarning,
      c.colorDanger,
      c.colorSuccess,
    ];
    for (final type in SemiTextType.values) {
      for (final size in SemiTextSize.values) {
        await t.pumpWidget(host(SemiText('正文', type: type, size: size)));
        final s = textStyle(t);
        expect(s.color, colors[type.index]);
        expect(
          s.fontSize,
          size == SemiTextSize.normal
              ? 14
              : size == SemiTextSize.small
              ? 12
              : 23,
        );
        expect(
          s.height,
          size == SemiTextSize.normal
              ? 20 / 14
              : size == SemiTextSize.small
              ? 16 / 12
              : 1.7,
        );
      }
    }
    expect(find.byType(GestureDetector), findsNothing);
    expect(find.byType(FocusableActionDetector), findsNothing);
  });

  testWidgets(
    'decorations, code geometry, icon and explicit style precedence',
    (t) async {
      final c = const SemiThemeData.light().colors;
      await t.pumpWidget(
        host(
          const SemiText(
            'code',
            code: true,
            mark: true,
            strong: true,
            underline: true,
            delete: true,
            icon: SizedBox(width: 10, height: 10),
          ),
        ),
      );
      var s = textStyle(t);
      expect(s.color, c.colorText2);
      expect(s.fontWeight, FontWeight.w600);
      expect(s.decoration!.contains(TextDecoration.underline), isTrue);
      expect(s.decoration!.contains(TextDecoration.lineThrough), isTrue);
      final box =
          t.widget<DecoratedBox>(find.byType(DecoratedBox)).decoration
              as BoxDecoration;
      expect(box.color, c.colorFill1);
      expect(box.border, Border.all(color: c.colorBorder));
      expect(box.borderRadius, BorderRadius.circular(2));
      expect(
        t.widget<Padding>(find.byType(Padding)).padding,
        const EdgeInsets.symmetric(vertical: 2, horizontal: 4),
      );
      await t.pumpWidget(
        host(const SemiText('mark', mark: true, disabled: true)),
      );
      expect(textStyle(t).backgroundColor, c.colorPrimaryLightDefault);
      expect(textStyle(t).color, c.colorDisabledText);
      await t.pumpWidget(
        host(
          const SemiText(
            'override',
            code: true,
            disabled: true,
            strong: true,
            weight: FontWeight.w300,
            style: TextStyle(
              color: Color(0xff123456),
              fontSize: 31,
              decoration: TextDecoration.none,
            ),
          ),
        ),
      );
      s = textStyle(t);
      expect(s.color, const Color(0xff123456));
      expect(s.fontSize, 31);
      expect(s.fontWeight, FontWeight.w300);
      expect(s.decoration, TextDecoration.none);
      await t.pumpWidget(
        host(
          const SemiText('clean'),
          style: const TextStyle(decoration: TextDecoration.underline),
        ),
      );
      expect(textStyle(t).decoration, TextDecoration.none);
    },
  );

  testWidgets('theme refresh dark and custom', (t) async {
    const child = SemiText('theme');
    await t.pumpWidget(host(child));
    final light = textStyle(t).color;
    await t.pumpWidget(host(child, theme: const SemiThemeData.dark()));
    expect(textStyle(t).color, const SemiThemeData.dark().colors.colorText0);
    expect(textStyle(t).color, isNot(light));
    await t.pumpWidget(
      host(
        child,
        theme: const SemiThemeData.light(
          colors: SemiColors(colorText0: Color(0xff123456)),
        ),
      ),
    );
    expect(textStyle(t).color, const Color(0xff123456));
  });

  testWidgets('link pointer, press, visited, keyboard, semantics and disable', (
    t,
  ) async {
    final strategy = FocusManager.instance.highlightStrategy;
    FocusManager.instance.highlightStrategy =
        FocusHighlightStrategy.alwaysTraditional;
    addTearDown(() => FocusManager.instance.highlightStrategy = strategy);
    var count = 0;
    final c = const SemiThemeData.light().colors;
    Widget link({bool disabled = false, bool visited = false}) => WidgetsApp(
      color: const Color(0xffffffff),
      builder: (context, child) => host(
        SemiText(
          'link',
          type: SemiTextType.danger,
          underline: true,
          disabled: disabled,
          link: SemiTextLink(onTap: () => count++, visited: visited),
        ),
      ),
    );
    final semantics = t.ensureSemantics();
    await t.pumpWidget(link(visited: true));
    expect(textStyle(t).color, c.colorLinkVisited);
    expect(textStyle(t).fontWeight, FontWeight.w600);
    expect(textStyle(t).decoration, TextDecoration.none);
    final node = t.getSemantics(find.byType(SemiText));
    expect(node.getSemanticsData().flagsCollection.isLink, isTrue);
    expect(node.getSemanticsData().hasAction(SemanticsAction.tap), isTrue);
    final mouse = await t.createGesture(kind: PointerDeviceKind.mouse);
    await mouse.addPointer(location: const Offset(1, 1));
    await mouse.moveTo(t.getCenter(find.text('link')));
    await t.pump();
    expect(textStyle(t).color, c.colorLinkHover);
    expect(textStyle(t).decoration, TextDecoration.underline);
    await mouse.down(t.getCenter(find.text('link')));
    await t.pump(const Duration(milliseconds: 150));
    expect(textStyle(t).color, c.colorLinkActive);
    await mouse.up();
    await t.pump();
    expect(count, 1);
    await mouse.moveTo(const Offset(1, 1));
    await t.pump();
    Focus.of(t.element(find.byType(GestureDetector))).requestFocus();
    await t.pump();
    await t.pump();
    final detector = t.widget<FocusableActionDetector>(
      find.byType(FocusableActionDetector),
    );
    final ctx = t.element(find.byType(GestureDetector));
    expect(Focus.of(ctx).hasFocus, isTrue);
    expect(detector.enabled, isTrue);
    expect(
      t
          .widgetList<DecoratedBox>(find.byType(DecoratedBox))
          .any(
            (b) =>
                (b.decoration as BoxDecoration).border ==
                Border.all(color: c.colorFocusBorder),
          ),
      isTrue,
    );
    await t.sendKeyEvent(LogicalKeyboardKey.enter);
    await t.sendKeyEvent(LogicalKeyboardKey.space);
    await t.pump();
    expect(count, 3);
    t
        .renderObject(find.byType(SemiText))
        .owner!
        .semanticsOwner!
        .performAction(
          t.getSemantics(find.byType(SemiText)).id,
          SemanticsAction.tap,
        );
    await t.pump();
    expect(count, 4);
    await t.pumpWidget(link(disabled: true));
    expect(textStyle(t).color, c.colorDisabledText);
    expect(textStyle(t).decoration, TextDecoration.none);
    expect(
      t
          .getSemantics(find.byType(SemiText))
          .getSemanticsData()
          .hasAction(SemanticsAction.tap),
      isFalse,
    );
    await t.tap(find.text('link'));
    await t.sendKeyEvent(LogicalKeyboardKey.enter);
    await t.pump();
    expect(count, 4);
    await t.pumpWidget(link());
    expect(textStyle(t).color, c.colorLink);
    await t.pumpWidget(host(const SizedBox()));
    await t.pump();
    expect(t.takeException(), isNull);
    await mouse.removePointer();
    semantics.dispose();
  });

  testWidgets(
    'bounded ellipsis handles languages, RTL, scaling and code icon',
    (t) async {
      for (final data in [
        'English words ' * 20,
        '中文文本' * 30,
        '👨‍👩‍👧‍👦😀🚀' * 30,
        'مرحبا بالعالم ' * 20,
      ]) {
        for (final scale in [1.0, 2.0]) {
          await t.pumpWidget(
            host(
              SizedBox(
                width: 100,
                child: SemiText(
                  data,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  code: true,
                  icon: const SizedBox(width: 10, height: 10),
                  textDirection: TextDirection.rtl,
                ),
              ),
              direction: TextDirection.rtl,
              scale: scale,
            ),
          );
          final paragraph = t.renderObject<RenderParagraph>(
            find.byType(RichText),
          );
          expect(paragraph.didExceedMaxLines, isTrue);
          expect(paragraph.size.width, lessThanOrEqualTo(100));
          expect(paragraph.textDirection, TextDirection.rtl);
          expect(t.takeException(), isNull);
        }
      }
    },
  );
}
