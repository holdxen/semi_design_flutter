import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:semi_design_flutter/semi_design_flutter.dart';

void main() {
  testWidgets('layout options respond at runtime and preserve complete info', (
    tester,
  ) async {
    final semantics = tester.ensureSemantics();
    final key = GlobalKey();
    var taps = 0;
    Future<void> mount({
      SemiProgressCircleInfoLayout? layout,
      double percent = 100,
      SemiProgressSize size = SemiProgressSize.large,
      SemiProgressType type = SemiProgressType.circle,
      double stroke = 4,
      double? width,
      bool custom = false,
      double font = 24,
      double scale = 2,
    }) => tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.rtl,
        child: MediaQuery(
          data: MediaQueryData(textScaler: TextScaler.linear(scale)),
          child: DefaultTextStyle(
            style: TextStyle(fontSize: font, fontFamily: 'Ahem'),
            child: Center(
              child: SemiProgressTheme(
                data: const SemiProgressThemeData(
                  circleTextColor: Color(0xff123456),
                ),
                child: SemiProgress(
                  key: key,
                  type: type,
                  size: size,
                  width: width,
                  strokeWidth: stroke,
                  percent: percent,
                  motion: false,
                  showInfo: true,
                  circleInfoLayout:
                      layout ?? SemiProgressCircleInfoLayout.overflow,
                  format: custom
                      ? (_) => GestureDetector(
                          onTap: () => taps++,
                          child: const Text('完成\n60%'),
                        )
                      : null,
                ),
              ),
            ),
          ),
        ),
      ),
    );
    for (final layout in SemiProgressCircleInfoLayout.values) {
      for (final percent in [60.0, 100.0]) {
        await mount(layout: layout, percent: percent);
        final paragraph = tester.renderObject<RenderParagraph>(
          find.text('${percent.toInt()}%'),
        );
        final circle = tester.getRect(find.byType(CustomPaint));
        final bounds = MatrixUtils.transformRect(
          paragraph.getTransformTo(null),
          paragraph.paintBounds,
        );
        expect(circle.size, const Size(24, 24));
        expect(bounds.center.dx, closeTo(circle.center.dx, .01));
        expect(bounds.center.dy, closeTo(circle.center.dy, .01));
        expect(paragraph.text.style!.fontSize, 24);
        expect(paragraph.text.style!.color, const Color(0xff123456));
        expect(paragraph.textScaler.scale(24), 48);
        expect(paragraph.didExceedMaxLines, isFalse);
        expect(
          paragraph.getBoxesForSelection(
            TextSelection(
              baseOffset: 0,
              extentOffset: '${percent.toInt()}%'.length,
            ),
          ),
          hasLength(1),
        );
        if (layout == SemiProgressCircleInfoLayout.overflow) {
          expect(bounds.width, greaterThan(24));
          expect(paragraph.getTransformTo(null).entry(0, 0), 1);
        } else {
          expect(bounds.left, greaterThanOrEqualTo(circle.left + 4 - .01));
          expect(bounds.right, lessThanOrEqualTo(circle.right - 4 + .01));
          expect(bounds.top, greaterThanOrEqualTo(circle.top + 4 - .01));
          expect(bounds.bottom, lessThanOrEqualTo(circle.bottom - 4 + .01));
        }
        expect(
          tester.getSemantics(find.byType(SemiProgress)).value,
          '${percent.toStringAsFixed(1)}%',
        );
      }
    }
    await mount(
      layout: SemiProgressCircleInfoLayout.scaleDown,
      size: SemiProgressSize.normal,
      font: 14,
      scale: 1,
      percent: 60,
    );
    expect(tester.getSize(find.byType(CustomPaint)), const Size(72, 72));
    expect(
      tester
          .renderObject<RenderParagraph>(find.text('60%'))
          .getTransformTo(null)
          .entry(0, 0),
      1,
    );
    for (final layout in SemiProgressCircleInfoLayout.values) {
      await mount(layout: layout, custom: true, percent: 60);
      final paragraph = tester.renderObject<RenderParagraph>(
        find.text('完成\n60%'),
      );
      expect(paragraph.maxLines, isNull);
      expect(paragraph.didExceedMaxLines, isFalse);
      await tester.tapAt(tester.getRect(find.byType(CustomPaint)).center);
      expect(taps, layout.index + 1);
      await mount(layout: layout, size: SemiProgressSize.small, custom: true);
      expect(find.text('完成\n60%'), findsNothing);
      expect(tester.getSemantics(find.byType(SemiProgress)).value, '100.0%');
      await mount(layout: layout, type: SemiProgressType.line, width: 240);
      expect(find.byType(FittedBox), findsNothing);
      expect(find.byType(OverflowBox), findsNothing);
      expect(find.text('100%'), findsOneWidget);
    }
    for (final width in [0.0, 2.0, 24.0]) {
      await mount(
        layout: SemiProgressCircleInfoLayout.scaleDown,
        width: width,
        stroke: 40,
      );
      expect(tester.takeException(), isNull);
    }
    semantics.dispose();
  });
  testWidgets(
    'custom multiline format keeps style, tap and percent semantics',
    (tester) async {
      final semantics = tester.ensureSemantics();
      var taps = 0;
      for (final direction in TextDirection.values) {
        for (final stroke in [0.0, 4.0, 12.0, 40.0]) {
          await tester.pumpWidget(
            Directionality(
              textDirection: direction,
              child: MediaQuery(
                data: const MediaQueryData(textScaler: TextScaler.linear(2)),
                child: DefaultTextStyle(
                  style: const TextStyle(
                    fontSize: 28,
                    color: Color(0xff123456),
                  ),
                  child: Center(
                    child: SemiProgress(
                      type: SemiProgressType.circle,
                      size: SemiProgressSize.large,
                      strokeWidth: stroke,
                      percent: 60,
                      showInfo: true,
                      format: (_) => GestureDetector(
                        onTap: () => taps++,
                        child: const Text('完成\n60%'),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
          final paragraph = tester.renderObject<RenderParagraph>(
            find.text('完成\n60%'),
          );
          expect(paragraph.text.style!.fontSize, 28);
          expect(paragraph.textAlign, TextAlign.center);
          expect(paragraph.maxLines, isNull);
          expect(paragraph.didExceedMaxLines, isFalse);
          expect(tester.getSemantics(find.byType(SemiProgress)).value, '60.0%');
          expect(paragraph.textScaler.scale(28), 56);
          expect(paragraph.getTransformTo(null).entry(0, 0), 1);
          final circle = tester.getRect(find.byType(CustomPaint));
          final bounds = MatrixUtils.transformRect(
            paragraph.getTransformTo(null),
            paragraph.paintBounds,
          );
          expect(bounds.width, greaterThan(24));
          expect(bounds.height, greaterThan(24));
          expect(bounds.center.dx, closeTo(circle.center.dx, .01));
          expect(bounds.center.dy, closeTo(circle.center.dy, .01));
          final previousTaps = taps;
          await tester.tapAt(circle.center);
          expect(taps, previousTaps + 1);
          expect(tester.takeException(), isNull);
        }
      }
      semantics.dispose();
    },
  );
  testWidgets('normal natural size is not enlarged or reduced', (tester) async {
    await tester.pumpWidget(
      const Directionality(
        textDirection: TextDirection.ltr,
        child: DefaultTextStyle(
          style: TextStyle(fontSize: 14),
          child: Center(
            child: SemiProgress(
              type: SemiProgressType.circle,
              percent: 60,
              showInfo: true,
            ),
          ),
        ),
      ),
    );
    expect(tester.getSize(find.byType(CustomPaint)), const Size(72, 72));
    final paragraph = tester.renderObject<RenderParagraph>(find.text('60%'));
    final transform = paragraph.getTransformTo(null);
    expect(transform.entry(0, 0), 1);
    expect(transform.entry(1, 1), 1);
  });
  for (final direction in TextDirection.values) {
    for (final font in [14.0, 24.0]) {
      for (final scale in [1.0, 2.0]) {
        testWidgets('natural overlay $direction font $font scale $scale', (
          tester,
        ) async {
          await tester.pumpWidget(
            Directionality(
              textDirection: direction,
              child: MediaQuery(
                data: MediaQueryData(textScaler: TextScaler.linear(scale)),
                child: DefaultTextStyle(
                  style: TextStyle(fontSize: font, fontFamily: 'Ahem'),
                  child: Center(
                    child: SizedBox(
                      width: 20,
                      child: SemiProgress(
                        type: SemiProgressType.circle,
                        size: SemiProgressSize.large,
                        textStyle: direction == TextDirection.rtl
                            ? TextStyle(fontSize: font)
                            : null,
                        percent: 100,
                        showInfo: true,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
          final paragraph = tester.renderObject<RenderParagraph>(
            find.text('100%'),
          );
          final circle = tester.getRect(find.byType(CustomPaint));
          final bounds = MatrixUtils.transformRect(
            paragraph.getTransformTo(null),
            paragraph.paintBounds,
          );
          expect(paragraph.text.style!.fontSize, font);
          expect(paragraph.text.style!.fontFamily, 'Ahem');
          expect(paragraph.textScaler.scale(font), font * scale);
          expect(paragraph.getTransformTo(null).entry(0, 0), 1);
          expect(paragraph.getTransformTo(null).entry(1, 1), 1);
          expect(bounds.width, greaterThan(24));
          expect(bounds.center.dx, closeTo(circle.center.dx, .01));
          expect(bounds.center.dy, closeTo(circle.center.dy, .01));
          expect(
            paragraph.getBoxesForSelection(
              const TextSelection(baseOffset: 0, extentOffset: 4),
            ),
            hasLength(1),
          );
          expect(paragraph.didExceedMaxLines, isFalse);
          expect(tester.takeException(), isNull);
        });
      }
    }
  }
  for (final width in [24.0, 72.0]) {
    for (final percent in [0.0, 60.0, 100.0]) {
      testWidgets('circle $width $percent complete centered bounds', (
        tester,
      ) async {
        await tester.pumpWidget(
          Directionality(
            textDirection: TextDirection.ltr,
            child: DefaultTextStyle(
              style: const TextStyle(fontSize: 14),
              child: Center(
                child: SemiProgress(
                  type: SemiProgressType.circle,
                  size: SemiProgressSize.large,
                  width: width,
                  percent: percent,
                  showInfo: true,
                ),
              ),
            ),
          ),
        );
        final text = find.text('${percent.toInt()}%');
        final paragraph = tester.renderObject<RenderParagraph>(text);
        final boxes = paragraph.getBoxesForSelection(
          TextSelection(
            baseOffset: 0,
            extentOffset: '${percent.toInt()}%'.length,
          ),
        );
        expect(boxes, hasLength(1), reason: 'percentage must not wrap or clip');
        final circle = tester.getRect(find.byType(CustomPaint));
        final bounds = MatrixUtils.transformRect(
          paragraph.getTransformTo(null),
          paragraph.paintBounds,
        );
        expect(bounds.center.dx, closeTo(circle.center.dx, .01));
        expect(bounds.center.dy, closeTo(circle.center.dy, .01));
        expect(paragraph.text.style!.fontSize, 14);
        expect(paragraph.getTransformTo(null).entry(0, 0), 1);
        expect(paragraph.getTransformTo(null).entry(1, 1), 1);
        if (width == 24) expect(bounds.width, greaterThan(24));
        expect(
          tester.widget<Stack>(find.byType(Stack)).clipBehavior,
          Clip.none,
        );
        expect(paragraph.didExceedMaxLines, isFalse);
        expect(tester.takeException(), isNull);
      });
    }
  }
}
