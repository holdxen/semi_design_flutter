import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:semi_design_flutter/semi_design_flutter.dart';

Widget host(
  Widget child, {
  bool reduced = false,
  bool ticker = true,
  TextDirection direction = TextDirection.ltr,
}) => Directionality(
  textDirection: direction,
  child: MediaQuery(
    data: MediaQueryData(disableAnimations: reduced),
    child: TickerMode(
      enabled: ticker,
      child: Center(child: child),
    ),
  ),
);
SemiProgressPainter painter(WidgetTester tester) => tester
    .widgetList<CustomPaint>(find.byType(CustomPaint))
    .map((w) => w.painter)
    .whereType<SemiProgressPainter>()
    .single;
void main() {
  test('thresholds copy sort alpha and exact values', () {
    final input = [
      const SemiProgressColorStop(100, Color(0xff0000ff)),
      const SemiProgressColorStop(0, Color(0x00ff0000)),
    ];
    final stroke = SemiProgressStroke.stops(input);
    expect(input.first.percent, 100);
    input.clear();
    expect(stroke.stops.length, 2);
    expect(() => stroke.stops.clear(), throwsUnsupportedError);
    const fallback = Color(0xff00ff00);
    expect(stroke.resolve(-1, fallback), fallback);
    expect(stroke.resolve(50, fallback), const Color(0x00ff0000));
    expect(stroke.resolve(100, fallback), const Color(0xff0000ff));
    expect(stroke.resolve(200, fallback), const Color(0xff0000ff));
    expect(
      stroke.resolve(50, fallback, gradient: true),
      Color.lerp(const Color(0x00ff0000), const Color(0xff0000ff), .5),
    );
    expect(
      () => SemiProgressStroke.stops([
        SemiProgressColorStop(double.nan, fallback),
      ]),
      throwsArgumentError,
    );
  });
  test('theme defaults and merge equality', () {
    const base = SemiProgressThemeData();
    final t = base.resolve(const SemiThemeData.light());
    expect(t.horizontalHeight, 4);
    expect(t.horizontalLargeHeight, 6);
    expect(t.verticalWidth, 4);
    expect(t.verticalLargeWidth, 6);
    expect(t.lineTextMarginLeft, 16);
    expect(t.lineTextMarginRight, 16);
    expect(t.verticalMarginX, 4);
    expect(t.horizontalMarginY, 4);
    expect(t.verticalTextMarginTop, 8);
    expect(t.lineTextMinWidth, 45);
    expect(t.lineTextFontWeight, FontWeight.w600);
    expect(t.transitionDuration, const Duration(milliseconds: 300));
    expect(t.transitionCurve, const Cubic(.62, .05, .36, .95));
    expect(t.trackRadius, 3);
    expect(t.innerRadius, 3);
    expect(t.color, const SemiThemeData.light().colors.colorFill0);
    expect(t.strokeColor, const SemiThemeData.light().colors.colorSuccess);
    expect(t.lineTextColor, const SemiThemeData.light().colors.colorText0);
    expect(t.circleTextColor, const SemiThemeData.light().colors.colorText0);
    const patch = SemiProgressThemeData(horizontalHeight: 9);
    expect(base.merge(patch), patch);
    expect(base.merge(patch).hashCode, patch.hashCode);
    expect(base.merge(null), base);
    expect(
      () =>
          const SemiProgressThemeData(verticalWidth: -1)
              .resolve(const SemiThemeData.light()),
      throwsArgumentError,
    );
    expect(
      () =>
          const SemiProgressThemeData(transitionDuration: Duration(seconds: -1))
              .resolve(const SemiThemeData.light()),
      throwsArgumentError,
    );
  });
  for (final type in SemiProgressType.values) {
    for (final direction in SemiProgressDirection.values) {
      for (final size in SemiProgressSize.values) {
        testWidgets('$type $direction $size endpoints and constraints', (
          tester,
        ) async {
          for (final percent in [-10.0, 0.0, 100.0, 110.0]) {
            await tester.pumpWidget(
              host(
                SemiProgress(
                  type: type,
                  direction: direction,
                  size: size,
                  percent: percent,
                  width: 150,
                  height: 150,
                  motion: false,
                ),
              ),
            );
            await tester.pump(const Duration(milliseconds: 301));
            expect(tester.takeException(), isNull);
            expect(painter(tester).fraction, percent.clamp(0, 100) / 100);
          }
        });
      }
    }
  }
  testWidgets('number motion independent geometry interruption', (
    tester,
  ) async {
    Widget build(double value, {bool motion = true}) => host(
      SemiProgress(width: 200, percent: value, showInfo: true, motion: motion),
    );
    await tester.pumpWidget(build(0));
    await tester.pumpWidget(build(90));
    await tester.pump(const Duration(milliseconds: 150));
    expect(find.text('45%'), findsOneWidget);
    expect(painter(tester).fraction, isNot(.45));
    await tester.pumpWidget(build(10, motion: false));
    expect(find.text('10%'), findsOneWidget);
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.text('10%'), findsOneWidget);
    expect(painter(tester).fraction, .1);
    await tester.pumpWidget(host(const SizedBox()));
    expect(tester.takeException(), isNull);
  });
  testWidgets('indeterminate cycles reduced ticker and hidden formatter', (
    tester,
  ) async {
    for (final type in SemiProgressType.values) {
      Widget build({bool reduced = false, bool ticker = true}) => host(
        SemiProgress(
          type: type,
          width: 200,
          indeterminate: true,
          showInfo: true,
          format: (_) => throw StateError('must not run'),
        ),
        reduced: reduced,
        ticker: ticker,
      );
      await tester.pumpWidget(build());
      await tester.pump(const Duration(milliseconds: 500));
      expect(painter(tester).phase, greaterThan(0));
      await tester.pump(const Duration(milliseconds: 3200));
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(build(reduced: true));
      expect(painter(tester).phase, 0);
      expect(tester.hasRunningAnimations, isFalse);
      await tester.pumpWidget(build(ticker: false));
      expect(tester.hasRunningAnimations, isFalse);
      await tester.pumpWidget(host(const SizedBox()));
    }
  });
  testWidgets('RTL, cap, line width ignored, circle small info', (
    tester,
  ) async {
    await tester.pumpWidget(
      host(
        const SemiProgress(
          width: 200,
          strokeWidth: 30,
          strokeLinecap: SemiProgressStrokeLinecap.square,
        ),
        direction: TextDirection.rtl,
      ),
    );
    expect(painter(tester).rtl, isTrue);
    expect(painter(tester).cap, StrokeCap.square);
    expect(tester.getSize(find.byType(CustomPaint)).height, 4);
    await tester.pumpWidget(
      host(
        const SemiProgress(
          type: SemiProgressType.circle,
          size: SemiProgressSize.small,
          showInfo: true,
        ),
      ),
    );
    expect(find.byType(Text), findsNothing);
    expect(tester.getSize(find.byType(CustomPaint)), const Size(24, 24));
  });
  testWidgets('runtime nonfinite and unbounded errors', (tester) async {
    await tester.pumpWidget(
      host(SemiProgress(percent: double.nan, width: 200)),
    );
    expect(tester.takeException(), isArgumentError);
    final errors = <FlutterErrorDetails>[];
    final previousHandler = FlutterError.onError;
    FlutterError.onError = errors.add;
    await tester.pumpWidget(
      host(
        const UnconstrainedBox(
          constrainedAxis: Axis.vertical,
          child: SemiProgress(),
        ),
      ),
    );
    expect(
      errors.any((e) => e.exceptionAsString().contains('explicit width')),
      isTrue,
    );
    errors.clear();
    await tester.pumpWidget(
      host(
        const UnconstrainedBox(
          constrainedAxis: Axis.horizontal,
          child: SemiProgress(direction: SemiProgressDirection.vertical),
        ),
      ),
    );
    FlutterError.onError = previousHandler;
    expect(
      errors.any((e) => e.exceptionAsString().contains('explicit height')),
      isTrue,
    );
  });
  testWidgets('semantics single value and indeterminate exclusion', (
    tester,
  ) async {
    final handle = tester.ensureSemantics();
    await tester.pumpWidget(
      host(
        const SemiProgress(
          width: 200,
          percent: 30,
          showInfo: true,
          semanticsLabel: 'Upload',
          semanticsValue: 'thirty',
        ),
      ),
    );
    expect(find.bySemanticsLabel('Upload'), findsOneWidget);
    expect(tester.getSemantics(find.byType(SemiProgress)).value, 'thirty');
    await tester.pumpWidget(
      host(
        const SemiProgress(
          width: 200,
          indeterminate: true,
          semanticsLabel: 'Upload',
          semanticsValue: 'ignored',
        ),
      ),
    );
    expect(tester.getSemantics(find.byType(SemiProgress)).value, '');
    await tester.pumpWidget(host(const SizedBox()));
    handle.dispose();
  });
  testWidgets('indeterminate exit restores target geometry', (tester) async {
    await tester.pumpWidget(
      host(const SemiProgress(width: 200, percent: 10, indeterminate: true)),
    );
    await tester.pumpWidget(
      host(const SemiProgress(width: 200, percent: 75, indeterminate: true)),
    );
    await tester.pumpWidget(host(const SemiProgress(width: 200, percent: 75)));
    expect(painter(tester).fraction, .75);
    expect(tester.hasRunningAnimations, isFalse);
  });
  testWidgets('circle inherits text style with explicit override', (
    tester,
  ) async {
    await tester.pumpWidget(
      host(
        const DefaultTextStyle(
          style: TextStyle(color: Color(0xffff0000), fontSize: 28),
          child: SemiProgress(
            type: SemiProgressType.circle,
            percent: 20,
            showInfo: true,
          ),
        ),
      ),
    );
    final textContext = tester.element(find.text('20%'));
    expect(
      DefaultTextStyle.of(textContext).style.color,
      const Color(0xffff0000),
    );
    expect(DefaultTextStyle.of(textContext).style.fontSize, 28);
  });
  testWidgets('global references and local patches survive global boundary', (
    tester,
  ) async {
    Widget build(bool dark, double width) => host(
      SemiProgressTheme(
        data: const SemiProgressThemeData(horizontalHeight: 9),
        child: SemiTheme(
          data: dark ? const SemiThemeData.dark() : const SemiThemeData.light(),
          child: SemiProgressTheme(
            data: SemiProgressThemeData(lineTextMinWidth: width),
            child: const SemiProgress(width: 200, percent: 40),
          ),
        ),
      ),
    );
    await tester.pumpWidget(build(false, 50));
    final first = painter(tester).color;
    expect(tester.getSize(find.byType(CustomPaint)).height, 9);
    await tester.pumpWidget(build(true, 60));
    expect(
      painter(tester).color,
      const SemiThemeData.dark().colors.colorSuccess,
    );
    expect(first, const SemiThemeData.light().colors.colorSuccess);
    final context = tester.element(find.byType(SemiProgress));
    expect(SemiProgressTheme.resolve(context).lineTextMinWidth, 60);
    expect(SemiProgressTheme.resolve(context).horizontalHeight, 9);
    final captured = InheritedTheme.captureAll(
      context,
      const SemiProgress(width: 100),
    );
    await tester.pumpWidget(host(captured));
    expect(tester.getSize(find.byType(CustomPaint)).height, 9);
  });
  testWidgets('zero duration geometry is independent of number motion', (
    tester,
  ) async {
    Widget build(double percent) => host(
      SemiProgressTheme(
        data: const SemiProgressThemeData(transitionDuration: Duration.zero),
        child: SemiProgress(width: 200, percent: percent, showInfo: true),
      ),
    );
    await tester.pumpWidget(build(0));
    await tester.pumpWidget(build(100));
    expect(painter(tester).fraction, 1);
    await tester.pump(const Duration(milliseconds: 150));
    expect(find.text('50%'), findsOneWidget);
    await tester.pump(const Duration(milliseconds: 150));
    expect(find.text('100%'), findsOneWidget);
  });
  testWidgets('local nested live patches and zero geometry duration', (
    tester,
  ) async {
    Widget build(double thickness) => host(
      SemiProgressTheme(
        data: SemiProgressThemeData(horizontalHeight: thickness),
        child: const SemiProgressTheme(
          data: SemiProgressThemeData(transitionDuration: Duration.zero),
          child: SemiProgress(width: 200, percent: 50),
        ),
      ),
    );
    await tester.pumpWidget(build(8));
    expect(tester.getSize(find.byType(CustomPaint)).height, 8);
    await tester.pumpWidget(build(12));
    expect(tester.getSize(find.byType(CustomPaint)).height, 12);
    expect(painter(tester).fraction, .5);
  });
}
