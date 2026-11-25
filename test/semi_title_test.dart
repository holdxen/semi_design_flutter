import 'package:flutter/gestures.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:semi_design_flutter/semi_design_flutter.dart';

import 'semi_text_test.dart' show host, textStyle;

void main() {
  test('heading and maxLines assertions', () {
    expect(() => SemiTitle('x', heading: 0), throwsAssertionError);
    expect(() => SemiTitle('x', heading: 7), throwsAssertionError);
    expect(() => SemiTitle('x', maxLines: 0), throwsAssertionError);
    expect(const SemiTitle('x').heading, 1);
  });

  testWidgets('six heading metrics without Material', (t) async {
    const sizes = [32, 28, 24, 20, 18, 16];
    for (var h = 1; h <= 6; h++) {
      await t.pumpWidget(host(SemiTitle('标题', heading: h)));
      expect(textStyle(t).fontSize, sizes[h - 1]);
      // No fixed line-height: inherit the host DefaultTextStyle height (1.7).
      expect(textStyle(t).height, 1.7);
      expect(textStyle(t).fontWeight, FontWeight.w600);
    }
  });

  testWidgets('all types disabled and theme refresh', (t) async {
    for (final theme in [
      const SemiThemeData.light(),
      const SemiThemeData.dark(),
    ]) {
      final c = theme.colors;
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
        await t.pumpWidget(host(SemiTitle('标题', type: type), theme: theme));
        expect(textStyle(t).color, colors[type.index]);
        await t.pumpWidget(
          host(SemiTitle('标题', type: type, disabled: true), theme: theme),
        );
        expect(textStyle(t).color, c.colorDisabledText);
      }
    }
  });

  testWidgets('weights decorations and final style precedence', (t) async {
    for (final weight in FontWeight.values) {
      await t.pumpWidget(
        host(
          SemiTitle(
            '标题',
            weight: weight,
            strong: true,
            mark: true,
            underline: true,
            delete: true,
          ),
        ),
      );
      final s = textStyle(t);
      expect(s.fontWeight, weight);
      expect(
        s.backgroundColor,
        const SemiThemeData.light().colors.colorPrimaryLightDefault,
      );
      expect(s.decoration!.contains(TextDecoration.underline), isTrue);
      expect(s.decoration!.contains(TextDecoration.lineThrough), isTrue);
    }
    await t.pumpWidget(
      host(
        const SemiTitle(
          '标题',
          weight: FontWeight.w200,
          disabled: true,
          strong: true,
          style: TextStyle(
            fontSize: 45,
            height: 2,
            fontWeight: FontWeight.w900,
            color: Color(0xff123456),
            decoration: TextDecoration.none,
          ),
        ),
      ),
    );
    final s = textStyle(t);
    expect(s.fontSize, 45);
    expect(s.height, 2);
    expect(s.fontWeight, FontWeight.w900);
    expect(s.color, const Color(0xff123456));
    expect(s.decoration, TextDecoration.none);
  });

  testWidgets('single header label retains link semantics and action', (
    t,
  ) async {
    final semantics = t.ensureSemantics();
    for (final linked in [false, true]) {
      for (final label in [null, '朗读标题']) {
        await t.pumpWidget(
          host(
            SemiTitle(
              '显示标题',
              semanticsLabel: label,
              link: linked ? SemiTextLink(onTap: () {}) : null,
            ),
          ),
        );
        final node = t.getSemantics(find.byType(SemiTitle));
        expect(node.flagsCollection.isHeader, isTrue);
        expect(node.label, label ?? '显示标题');
        expect(node.flagsCollection.isLink, linked);
        expect(node.getSemanticsData().hasAction(SemanticsAction.tap), linked);
        expect(node.childrenCount, 0);
      }
    }
    semantics.dispose();
  });

  testWidgets('link mouse keyboard visited and disabled reuse', (t) async {
    var taps = 0;
    Widget title({bool disabled = false}) => host(
      SemiTitle(
        '链接标题',
        disabled: disabled,
        underline: true,
        link: SemiTextLink(onTap: () => taps++, visited: true),
      ),
    );
    await t.pumpWidget(title());
    final c = const SemiThemeData.light().colors;
    expect(textStyle(t).color, c.colorLinkVisited);
    final mouse = await t.createGesture(kind: PointerDeviceKind.mouse);
    await mouse.addPointer(location: Offset.zero);
    await mouse.moveTo(t.getCenter(find.byType(Text)));
    await t.pump();
    expect(textStyle(t).color, c.colorLinkHover);
    await mouse.down(t.getCenter(find.byType(Text)));
    await t.pump();
    expect(textStyle(t).color, c.colorLinkActive);
    await mouse.up();
    await t.pump();
    expect(taps, 1);
    Focus.of(t.element(find.byType(GestureDetector))).requestFocus();
    await t.pump();
    await t.sendKeyEvent(LogicalKeyboardKey.enter);
    await t.sendKeyEvent(LogicalKeyboardKey.space);
    expect(taps, 3);
    await t.pumpWidget(title(disabled: true));
    await t.tap(find.byType(Text));
    await t.sendKeyEvent(LogicalKeyboardKey.enter);
    expect(taps, 3);
    expect(textStyle(t).color, c.colorLink);
    await mouse.removePointer();
  });

  testWidgets('bounded Chinese RTL ellipsis and forwarding', (t) async {
    await t.pumpWidget(
      host(
        const SizedBox(
          width: 100,
          child: SemiTitle(
            '中文标题很长很长 مرحبا بالعالم',
            heading: 4,
            textAlign: TextAlign.end,
            textDirection: TextDirection.rtl,
            softWrap: false,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ),
    );
    final text = t.widget<Text>(find.byType(Text));
    final paragraph = t.renderObject<RenderParagraph>(find.byType(RichText));
    expect(text.textAlign, TextAlign.end);
    expect(text.textDirection, TextDirection.rtl);
    expect(text.softWrap, false);
    expect(paragraph.didExceedMaxLines, isTrue);
    expect(paragraph.size.width, lessThanOrEqualTo(100));
    expect(t.takeException(), isNull);
  });
}
