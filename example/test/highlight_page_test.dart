import 'package:example/main.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:semi_design_flutter/semi_design_flutter.dart';

Finder keyed(String key) => find.byKey(ValueKey(key));

Text innerText(WidgetTester tester, String key) => tester.widget<Text>(
  find.descendant(of: keyed(key), matching: find.byType(Text)),
);

List<TextSpan> chunkSpans(Text text) {
  final root = text.textSpan! as TextSpan;
  return (root.children ?? const <InlineSpan>[]).whereType<TextSpan>().toList();
}

List<TextSpan> highlighted(List<TextSpan> spans) =>
    spans.where((span) => span.style?.backgroundColor != null).toList();

Future<void> start(WidgetTester tester) async {
  addTearDown(() async => tester.pumpWidget(const SizedBox.shrink()));
  await tester.pumpWidget(const MyApp());
  await tester.pump(const Duration(milliseconds: 50));
}

Future<void> tap(WidgetTester tester, String key) async {
  await tester.ensureVisible(keyed(key));
  await tester.pump(const Duration(milliseconds: 50));
  await tester.tap(keyed(key));
  await tester.pump(const Duration(milliseconds: 100));
}

void main() {
  testWidgets('sections fit a narrow scaled screen and scroll to the bottom', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 640);
    tester.view.devicePixelRatio = 1;
    tester.platformDispatcher.textScaleFactorTestValue = 1.2;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
    await start(tester);
    for (final title in ['基础高亮', '逐词样式', '大小写', '正则模式', '主题定制', '文本布局']) {
      expect(find.text(title), findsOneWidget);
      await tester.ensureVisible(find.text(title));
      await tester.pump(const Duration(milliseconds: 100));
      expect(tester.takeException(), isNull);
    }
    await tester.ensureVisible(keyed('ellipsis-highlight'));
    await tester.pump(const Duration(milliseconds: 100));
    expect(keyed('ellipsis-highlight').hitTestable(), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('basic highlight marks each occurrence with theme colors', (
    tester,
  ) async {
    await start(tester);
    final spans = chunkSpans(innerText(tester, 'basic-highlight'));
    final marked = highlighted(spans);
    expect(marked.map((span) => span.toPlainText()), ['Semi', '设计', 'Semi']);
    final theme = const SemiThemeData.light();
    for (final span in marked) {
      expect(span.style!.backgroundColor, theme.colors.colorHighlightBg);
      expect(span.style!.color, theme.colors.colorHighlight);
      expect(span.style!.fontWeight, FontWeight.w600);
    }
    expect(tester.takeException(), isNull);
  });

  testWidgets('word and global styles follow the documented merge order', (
    tester,
  ) async {
    await start(tester);
    final marked = highlighted(
      chunkSpans(innerText(tester, 'styled-highlight')),
    );
    expect(marked, hasLength(3));
    for (final span in marked) {
      expect(span.style!.backgroundColor, const Color(0x337b61ff));
    }
    expect(marked.first.toPlainText(), '蓝色');
    expect(marked.first.style!.color, const Color(0xff0055ff));
    expect(marked[1].style!.color, const Color(0xff7b61ff));
    expect(marked[2].style!.color, const Color(0xff7b61ff));
    expect(tester.takeException(), isNull);
  });

  testWidgets('case sensitivity toggle changes matched spans', (tester) async {
    await start(tester);
    expect(
      highlighted(chunkSpans(innerText(tester, 'case-highlight'))),
      hasLength(3),
    );
    await tap(tester, 'toggle-case');
    final marked = highlighted(chunkSpans(innerText(tester, 'case-highlight')));
    expect(marked, hasLength(1));
    expect(marked.single.toPlainText(), 'semi');
    await tap(tester, 'toggle-case');
    expect(
      highlighted(chunkSpans(innerText(tester, 'case-highlight'))),
      hasLength(3),
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('regex mode matches patterns and literal mode does not', (
    tester,
  ) async {
    await start(tester);
    final regex = highlighted(chunkSpans(innerText(tester, 'regex-highlight')));
    expect(regex.map((span) => span.toPlainText()), ['2.104.0', '12345']);
    expect(
      highlighted(chunkSpans(innerText(tester, 'literal-highlight'))),
      isEmpty,
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('local theme patch restyles highlighted spans', (tester) async {
    await start(tester);
    await tester.ensureVisible(keyed('theme-highlight'));
    await tester.pump(const Duration(milliseconds: 100));
    final resolved = SemiHighlightTheme.resolve(
      tester.element(keyed('theme-highlight')),
    );
    expect(resolved.colorHighlightTextBgDefault, const Color(0xffd8f5d8));
    expect(resolved.colorHighlightTextDefault, const Color(0xff0a7a2f));
    expect(resolved.fontHighlightTextFontWeight, FontWeight.w900);
    final marked = highlighted(
      chunkSpans(innerText(tester, 'theme-highlight')),
    );
    expect(marked, hasLength(1));
    expect(marked.single.style!.backgroundColor, const Color(0xffd8f5d8));
    expect(marked.single.style!.color, const Color(0xff0a7a2f));
    expect(marked.single.style!.fontWeight, FontWeight.w900);
    expect(tester.takeException(), isNull);
  });

  testWidgets('ellipsis constrains multiline highlight', (tester) async {
    await start(tester);
    final text = innerText(tester, 'ellipsis-highlight');
    expect(text.maxLines, 2);
    expect(text.overflow, TextOverflow.ellipsis);
    final marked = highlighted(chunkSpans(text));
    expect(marked.map((span) => span.toPlainText()), ['多行高亮', '关键词']);
    expect(tester.takeException(), isNull);
  });
}
