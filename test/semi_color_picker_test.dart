// Behavior matrix for SemiColorPicker plus coverage for the 20 Sass
// declarations (20 FIELDS + 0 MOTION + 0 INTERNAL) — the 11 HARDCODES
// provenance anchors live in the widget's `_ColorPickerMetrics` / call sites.
import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:semi_design_flutter/semi_design_flutter.dart';

/// The host body is served through a notifier: `Overlay.initialEntries` is
/// initState-only, so the entry must rebuild its child from outside (the
/// semi_tag_input_test.dart host precedent).
final _hostBody = ValueNotifier<Widget>(const SizedBox.shrink());

Widget host(Widget child, {bool keepState = false}) {
  _hostBody.value = keepState
      ? child
      : KeyedSubtree(key: UniqueKey(), child: child);
  return SemiTheme(
    data: const SemiThemeData.light(),
    child: Directionality(
      textDirection: TextDirection.ltr,
      child: MediaQuery(
        data: const MediaQueryData(size: Size(800, 600)),
        child: Overlay(
          initialEntries: [
            OverlayEntry(
              builder: (context) => ValueListenableBuilder<Widget>(
                valueListenable: _hostBody,
                builder: (context, child, _) => Center(child: child),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

String _editableText(WidgetTester tester, Key key) => tester
    .widget<EditableText>(
      find.descendant(of: find.byKey(key), matching: find.byType(EditableText)),
    )
    .controller
    .text;

String colorText(WidgetTester tester) =>
    _editableText(tester, SemiColorPicker.colorInputKey);

String alphaText(WidgetTester tester) =>
    _editableText(tester, SemiColorPicker.alphaInputKey);

Future<TestGesture> startMouse(WidgetTester tester) async {
  final gesture = await tester.createGesture(kind: ui.PointerDeviceKind.mouse);
  await gesture.addPointer(location: Offset.zero);
  addTearDown(gesture.removePointer);
  return gesture;
}

/// Press at [from] (widget-local to [key]) and drag to [to]. A tap (from ==
/// to) fires only the press update — upstream `mousemove` fires per move.
Future<void> dragOn(
  WidgetTester tester,
  Key key,
  Offset from,
  Offset to,
) async {
  final topLeft = tester.getRect(find.byKey(key)).topLeft;
  final gesture = await tester.startGesture(topLeft + from);
  await tester.pump();
  if (to != from) {
    await gesture.moveTo(topLeft + to);
    await tester.pump();
  }
  await gesture.up();
  await tester.pump();
}

typedef _Patch = SemiColorPickerThemeData Function(Object value);
typedef _Read = Object? Function(SemiResolvedColorPickerThemeData data);
typedef _Default = Object? Function(SemiThemeData theme);

/// All 20 upstream declarations (variables.scss — no animation.scss):
/// 20 FIELDS + 0 MOTION + 0 INTERNAL.
final List<(String, Object, _Patch, _Read, _Default)> fields = [
  (
    r'$radius-colorPicker-topLeft: 8px',
    4.5,
    (Object v) =>
        SemiColorPickerThemeData(radiusColorPickerTopLeft: v as double),
    (SemiResolvedColorPickerThemeData d) => d.radiusColorPickerTopLeft,
    (SemiThemeData theme) => 8.0,
  ),
  (
    r'$radius-colorPicker-topRight: 8px',
    4.5,
    (Object v) =>
        SemiColorPickerThemeData(radiusColorPickerTopRight: v as double),
    (SemiResolvedColorPickerThemeData d) => d.radiusColorPickerTopRight,
    (SemiThemeData theme) => 8.0,
  ),
  (
    r'$radius-colorPicker-bottomLeft: 0px',
    4.5,
    (Object v) =>
        SemiColorPickerThemeData(radiusColorPickerBottomLeft: v as double),
    (SemiResolvedColorPickerThemeData d) => d.radiusColorPickerBottomLeft,
    (SemiThemeData theme) => 0.0,
  ),
  (
    r'$radius-colorPicker-bottomRight: 0px',
    4.5,
    (Object v) =>
        SemiColorPickerThemeData(radiusColorPickerBottomRight: v as double),
    (SemiResolvedColorPickerThemeData d) => d.radiusColorPickerBottomRight,
    (SemiThemeData theme) => 0.0,
  ),
  (
    r'$radius-colorPicker-handle: var(--semi-border-radius-full)',
    4.5,
    (Object v) =>
        SemiColorPickerThemeData(radiusColorPickerHandle: v as double),
    (SemiResolvedColorPickerThemeData d) => d.radiusColorPickerHandle,
    (SemiThemeData theme) => theme.radius.borderRadiusFull.value,
  ),
  (
    r'$radius-colorPicker-alphaSliderInner: 4px',
    4.5,
    (Object v) => SemiColorPickerThemeData(
      radiusColorPickerAlphaSliderInner: v as double,
    ),
    (SemiResolvedColorPickerThemeData d) => d.radiusColorPickerAlphaSliderInner,
    (SemiThemeData theme) => 4.0,
  ),
  (
    r'$radius-colorPicker-demoBlock: 4px',
    4.5,
    (Object v) =>
        SemiColorPickerThemeData(radiusColorPickerDemoBlock: v as double),
    (SemiResolvedColorPickerThemeData d) => d.radiusColorPickerDemoBlock,
    (SemiThemeData theme) => 4.0,
  ),
  (
    r'$radius-colorPicker-defaultTrigger: 4px',
    4.5,
    (Object v) =>
        SemiColorPickerThemeData(radiusColorPickerDefaultTrigger: v as double),
    (SemiResolvedColorPickerThemeData d) => d.radiusColorPickerDefaultTrigger,
    (SemiThemeData theme) => 4.0,
  ),
  (
    r'$width-colorPicker_handle-border: 2px',
    4.5,
    (Object v) =>
        SemiColorPickerThemeData(widthColorPickerHandleBorder: v as double),
    (SemiResolvedColorPickerThemeData d) => d.widthColorPickerHandleBorder,
    (SemiThemeData theme) => 2.0,
  ),
  (
    r'$width-colorPicker-colorPickerInputNumber: 58px',
    4.5,
    (Object v) => SemiColorPickerThemeData(
      widthColorPickerColorPickerInputNumber: v as double,
    ),
    (SemiResolvedColorPickerThemeData d) =>
        d.widthColorPickerColorPickerInputNumber,
    (SemiThemeData theme) => 58.0,
  ),
  (
    r'$width-colorPicker-formatSelect: 80px',
    4.5,
    (Object v) =>
        SemiColorPickerThemeData(widthColorPickerFormatSelect: v as double),
    (SemiResolvedColorPickerThemeData d) => d.widthColorPickerFormatSelect,
    (SemiThemeData theme) => 80.0,
  ),
  (
    r'$width-colorPicker-defaultTrigger: 24px',
    4.5,
    (Object v) =>
        SemiColorPickerThemeData(widthColorPickerDefaultTrigger: v as double),
    (SemiResolvedColorPickerThemeData d) => d.widthColorPickerDefaultTrigger,
    (SemiThemeData theme) => 24.0,
  ),
  (
    r'$color-colorPicker_handle-border: var(--semi-color-white)',
    const Color(0xff123456),
    (Object v) =>
        SemiColorPickerThemeData(colorColorPickerHandleBorder: v as Color),
    (SemiResolvedColorPickerThemeData d) => d.colorColorPickerHandleBorder,
    (SemiThemeData theme) => const Color(0xffffffff),
  ),
  (
    r'$spacing-colorPicker_inputNumberSuffix-horizontal: 4px',
    4.5,
    (Object v) => SemiColorPickerThemeData(
      spacingColorPickerInputNumberSuffixHorizontal: v as double,
    ),
    (SemiResolvedColorPickerThemeData d) =>
        d.spacingColorPickerInputNumberSuffixHorizontal,
    (SemiThemeData theme) => 4.0,
  ),
  (
    r'$spacing-colorPicker_inputGroup-marginLeft: 4px',
    4.5,
    (Object v) => SemiColorPickerThemeData(
      spacingColorPickerInputGroupMarginLeft: v as double,
    ),
    (SemiResolvedColorPickerThemeData d) =>
        d.spacingColorPickerInputGroupMarginLeft,
    (SemiThemeData theme) => 4.0,
  ),
  (
    r'$spacing-colorPicker_popover-padding: 8px',
    4.5,
    (Object v) =>
        SemiColorPickerThemeData(spacingColorPickerPopoverPadding: v as double),
    (SemiResolvedColorPickerThemeData d) => d.spacingColorPickerPopoverPadding,
    (SemiThemeData theme) => 8.0,
  ),
  (
    r'$spacing-colorPicker_inputNumberSuffix-vertical: 4px',
    4.5,
    (Object v) => SemiColorPickerThemeData(
      spacingColorPickerInputNumberSuffixVertical: v as double,
    ),
    (SemiResolvedColorPickerThemeData d) =>
        d.spacingColorPickerInputNumberSuffixVertical,
    (SemiThemeData theme) => 4.0,
  ),
  (
    r'$spacing-colorPicker_slider-marginTop: 6px',
    4.5,
    (Object v) => SemiColorPickerThemeData(
      spacingColorPickerSliderMarginTop: v as double,
    ),
    (SemiResolvedColorPickerThemeData d) => d.spacingColorPickerSliderMarginTop,
    (SemiThemeData theme) => 6.0,
  ),
  (
    r'$spacing-colorPicker_dataPart-marginTop: 8px',
    4.5,
    (Object v) => SemiColorPickerThemeData(
      spacingColorPickerDataPartMarginTop: v as double,
    ),
    (SemiResolvedColorPickerThemeData d) =>
        d.spacingColorPickerDataPartMarginTop,
    (SemiThemeData theme) => 8.0,
  ),
  (
    r'$font-colorPicker_inputNumberSuffix-fontSize: 14px',
    4.5,
    (Object v) => SemiColorPickerThemeData(
      fontColorPickerInputNumberSuffixFontSize: v as double,
    ),
    (SemiResolvedColorPickerThemeData d) =>
        d.fontColorPickerInputNumberSuffixFontSize,
    (SemiThemeData theme) => 14.0,
  ),
];

void main() {
  group('SemiColorValue conversions', () {
    test('hsva -> rgba/hex; ★a == 1 renders 6-digit, a < 1 the lowercase '
        '8-digit form', () {
      const red = SemiColorValue(h: 0, s: 100, v: 100);
      expect((red.r, red.g, red.b), (255, 0, 0));
      expect(red.hex, '#ff0000');
      expect(red.a, 1.0);
      const green = SemiColorValue(h: 120, s: 100, v: 100);
      expect((green.r, green.g, green.b), (0, 255, 0));
      expect(green.hex, '#00ff00');
      const halfRed = SemiColorValue(h: 0, s: 100, v: 100, a: 0.5);
      // percentToHex(50) = round(127.5) = 128 = '80'.
      expect(halfRed.hex, '#ff000080');
      const quarterRed = SemiColorValue(h: 0, s: 100, v: 100, a: 0.25);
      expect(quarterRed.hex, '#ff000040');
      // hex -> hsva -> hex round-trips through the quantized alpha.
      expect(SemiColorValue.parse('#ff000080').hex, '#ff000080');
      expect(SemiColorValue.parse('#ff000080').a, closeTo(128 / 255, 1e-9));
    });

    test('★hexToRgba is lenient: 3-char shorthand parses (missing components '
        'collapse to 0 in Dart); missing alpha -> 1', () {
      // Upstream hexToRgba('#f00') does not throw — it yields r=240 with NaN
      // components; NaN cannot traverse Dart's num pipeline so the port
      // collapses them to 0 (差异清单).
      final short = SemiColorValue.parse('#f00');
      expect(short.a, 1.0);
      expect((short.r, short.g, short.b), (240, 0, 0));
      expect(SemiColorValue.parse('#39c5bb').a, 1.0);
      // Garbage components are equally lenient (zero-ish, no throw).
      expect(SemiColorValue.parse('#zzzzzz').hex, '#000000');
    });

    test('input parser (★String-regex rules): # auto-prepend, unanchored '
        '6-8, 3/4-digit rejected, comma bounds, hsva hue cap', () {
      // `#` auto-prepend.
      expect(
        SemiColorValue.tryParseInput('39c5bb', format: SemiColorFormat.hex),
        SemiColorValue.tryParseInput('#39c5bb', format: SemiColorFormat.hex),
      );
      expect(
        SemiColorValue.tryParseInput('39c5bb', format: SemiColorFormat.hex),
        isNotNull,
      );
      // ★unanchored `#[\d\w]{6,8}` — a 9-char run still passes.
      expect(
        SemiColorValue.tryParseInput('#39c5bb801', format: SemiColorFormat.hex),
        isNotNull,
      );
      // ★3/4-digit shorthand REJECTED.
      expect(
        SemiColorValue.tryParseInput('f00', format: SemiColorFormat.hex),
        isNull,
      );
      expect(
        SemiColorValue.tryParseInput('#f00', format: SemiColorFormat.hex),
        isNull,
      );
      expect(
        SemiColorValue.tryParseInput('#f000', format: SemiColorFormat.hex),
        isNull,
      );
      // Comma triples: range-checked (reject, no clamp), missing 4th -> 1.
      expect(
        SemiColorValue.tryParseInput('12,32,43', format: SemiColorFormat.rgba),
        isNotNull,
      );
      expect(
        SemiColorValue.tryParseInput(
          '12,32,43',
          format: SemiColorFormat.rgba,
        )!.a,
        1.0,
      );
      expect(
        SemiColorValue.tryParseInput(
          '12,32,43,0.5',
          format: SemiColorFormat.rgba,
        )!.a,
        0.5,
      );
      expect(
        SemiColorValue.tryParseInput('300,32,43', format: SemiColorFormat.rgba),
        isNull,
      );
      expect(
        SemiColorValue.tryParseInput('-1,32,43', format: SemiColorFormat.rgba),
        isNull,
      );
      expect(
        SemiColorValue.tryParseInput(
          '12,32,43,2',
          format: SemiColorFormat.rgba,
        ),
        isNull,
      );
      // ★hsva hue above 360 rejected (360 itself is fine).
      expect(
        SemiColorValue.tryParseInput('400,50,50', format: SemiColorFormat.hsva),
        isNull,
      );
      expect(
        SemiColorValue.tryParseInput('360,50,50', format: SemiColorFormat.hsva),
        isNotNull,
      );
    });

    test('string parsing: rgb/rgba/hsv dispatch (colorStringToValue order), '
        'angle units, ArgumentError on garbage', () {
      final rgb = SemiColorValue.parse('rgb(255, 0, 0)');
      expect((rgb.r, rgb.g, rgb.b), (255, 0, 0));
      expect(SemiColorValue.parse('rgba(255, 0, 0, 0.5)').a, 0.5);
      expect(SemiColorValue.parse('hsv(0, 100%, 100%)').hex, '#ff0000');
      expect(SemiColorValue.parse('hsva(0, 100%, 100%, 0.25)').a, 0.25);
      // convert.ts angle units: grad / turn / rad.
      expect(SemiColorValue.parse('hsv(200grad, 100%, 100%)').h, 180.0);
      expect(SemiColorValue.parse('hsv(0.5turn, 100%, 100%)').h, 180.0);
      expect(
        SemiColorValue.parse('hsv(3.141592653589793rad, 100%, 100%)').h,
        180.0,
      );
      // Bad prefix -> ArgumentError; tryParse returns null.
      expect(() => SemiColorValue.parse('invalid'), throwsArgumentError);
      expect(() => SemiColorValue.parse(''), throwsArgumentError);
      expect(SemiColorValue.tryParse('invalid'), isNull);
    });

    test('default brand color #39c5bb: the Semi brand hex parses to the '
        'default value (176, 71, 77, 1) (★hex computes to #39c4bb)', () {
      // ★upstream `defaultValue` bundles `hsva: {h: 176, s: 71, v: 77, a: 1}`
      // with `hex: '#39c5bb'` / `rgba: {r: 57, g: 197, b: 187}` — the hsva is
      // that rgb int-rounded and does not round-trip back (computed channels
      // give g=196 — the documented model deviation, docs 差异清单).
      expect(
        SemiColorValue.parse('#39c5bb'),
        const SemiColorValue(h: 176, s: 71, v: 77, a: 1),
      );
      const brand = SemiColorValue(h: 176, s: 71, v: 77, a: 1);
      expect((brand.r, brand.g, brand.b), (57, 196, 187));
      expect(brand.hex, '#39c4bb');
    });
  });

  group('SV drag', () {
    testWidgets('s/v updates follow the pointer (rounded per axis)', (
      tester,
    ) async {
      final changes = <SemiColorValue>[];
      await tester.pumpWidget(
        host(
          SemiColorPicker(
            defaultValue: const SemiColorValue(h: 0, s: 100, v: 100),
            onChanged: changes.add,
          ),
        ),
      );
      // Tap the exact middle: s = round(0.5 * 100) = 50, v = 50.
      await dragOn(
        tester,
        SemiColorPicker.svAreaKey,
        const Offset(140, 140),
        const Offset(140, 140),
      );
      expect(changes, [const SemiColorValue(h: 0, s: 50, v: 50)]);
      // Top-left corner: s = 0, v = 100.
      await dragOn(tester, SemiColorPicker.svAreaKey, Offset.zero, Offset.zero);
      expect(changes.last, const SemiColorValue(h: 0, s: 0, v: 100));
    });

    testWidgets('★out-of-bounds positions are rejected (no change)', (
      tester,
    ) async {
      final changes = <SemiColorValue>[];
      await tester.pumpWidget(
        host(
          SemiColorPicker(
            defaultValue: const SemiColorValue(h: 0, s: 100, v: 100),
            onChanged: changes.add,
          ),
        ),
      );
      final topLeft = tester
          .getRect(find.byKey(SemiColorPicker.svAreaKey))
          .topLeft;
      final gesture = await tester.startGesture(
        topLeft + const Offset(140, 140),
      );
      await tester.pump();
      expect(changes, hasLength(1));
      // Outside the area: upstream `getHandlePositionByMousePosition`
      // returns null and nothing changes.
      await gesture.moveTo(topLeft + const Offset(400, 140));
      await tester.pump();
      await gesture.moveTo(topLeft + const Offset(140, -30));
      await tester.pump();
      expect(changes, hasLength(1));
      // Back inside: changes resume.
      await gesture.moveTo(topLeft + const Offset(0, 280));
      await tester.pump();
      await gesture.up();
      await tester.pump();
      expect(changes, hasLength(2));
      expect(changes.last, const SemiColorValue(h: 0, s: 0, v: 0));
    });
  });

  group('hue drag', () {
    testWidgets('clamped to [0, 360]; ★the right edge yields 360 (no wrap)', (
      tester,
    ) async {
      final changes = <SemiColorValue>[];
      await tester.pumpWidget(
        host(
          SemiColorPicker(
            defaultValue: const SemiColorValue(h: 0, s: 100, v: 100),
            onChanged: changes.add,
          ),
        ),
      );
      final topLeft = tester
          .getRect(find.byKey(SemiColorPicker.hueSliderKey))
          .topLeft;
      final gesture = await tester.startGesture(topLeft + const Offset(0, 5));
      await tester.pump();
      expect(changes.last.h, 0.0);
      await gesture.moveTo(topLeft + const Offset(140, 5));
      await tester.pump();
      expect(changes.last.h, 180.0);
      // ★exactly the right edge (and beyond — clamped, NOT wrapped to 0).
      await gesture.moveTo(topLeft + const Offset(280, 5));
      await tester.pump();
      expect(changes.last.h, 360.0);
      await gesture.moveTo(topLeft + const Offset(400, 5));
      await tester.pump();
      expect(changes.last.h, 360.0);
      await gesture.up();
      await tester.pump();
    });
  });

  group('alpha slider and % input', () {
    testWidgets('alpha drag quantizes to 2 decimals (★toFixed(2))', (
      tester,
    ) async {
      final changes = <SemiColorValue>[];
      await tester.pumpWidget(
        host(
          SemiColorPicker(
            alpha: true,
            defaultValue: const SemiColorValue(h: 0, s: 100, v: 100),
            onChanged: changes.add,
          ),
        ),
      );
      await dragOn(
        tester,
        SemiColorPicker.alphaSliderKey,
        const Offset(140, 5),
        const Offset(158.76, 5),
      );
      // 158.76 / 280 = 0.567 -> 0.57.
      expect(changes.last.a, 0.57);
    });

    testWidgets('★alpha = false forces a = 1 and the 6-digit hex on every '
        'commit', (tester) async {
      final changes = <SemiColorValue>[];
      await tester.pumpWidget(
        host(
          SemiColorPicker(
            defaultValue: const SemiColorValue(h: 0, s: 100, v: 100, a: 0.5),
            onChanged: changes.add,
          ),
        ),
      );
      expect(find.byKey(SemiColorPicker.alphaSliderKey), findsNothing);
      await dragOn(
        tester,
        SemiColorPicker.hueSliderKey,
        const Offset(140, 5),
        const Offset(140, 5),
      );
      expect(changes, hasLength(1));
      expect(changes.single.a, 1.0);
      // h = 180 -> cyan, rendered opaque (the 6-digit form).
      expect(changes.single.hex, '#00ffff');
      // A typed 8-digit hex is stripped to opaque as well (★the
      // `hex.slice(0, 7)` rule, subsumed by a = 1).
      await tester.enterText(
        find.descendant(
          of: find.byKey(SemiColorPicker.colorInputKey),
          matching: find.byType(EditableText),
        ),
        '#ff000080',
      );
      await tester.pump();
      expect(changes, hasLength(2));
      expect(changes.last.a, 1.0);
      expect(changes.last.hex, '#ff0000');
    });

    testWidgets('% input: round(a * 100) display, a = (v / 100).toFixed(2); '
        'hex format ★requantizes through rgbaToHex', (tester) async {
      final changes = <SemiColorValue>[];
      await tester.pumpWidget(
        host(
          SemiColorPicker(
            alpha: true,
            defaultValue: const SemiColorValue(h: 0, s: 100, v: 100, a: 0.5),
            onChanged: changes.add,
          ),
        ),
      );
      expect(alphaText(tester), '50');
      expect(find.text('%'), findsOneWidget);
      await tester.enterText(
        find.descendant(
          of: find.byKey(SemiColorPicker.alphaInputKey),
          matching: find.byType(EditableText),
        ),
        '25',
      );
      await tester.pump();
      // hex format: the value round-trips through `rgbaToHex` —
      // percentToHex(25) = round(63.75) = 64 = '40', so a becomes 64/255.
      expect(changes, hasLength(1));
      expect(changes.single.hex, '#ff000040');
      expect(changes.single.a, closeTo(64 / 255, 1e-9));
      // The % display resyncs from the value (round(64/255 * 100) = 25).
      expect(alphaText(tester), '25');
    });
  });

  group('DataPart', () {
    testWidgets('display is always alpha-stripped (★hex 7 chars / rgba 3 '
        'nums / hsva 3 nums)', (tester) async {
      await tester.pumpWidget(
        host(
          const SemiColorPicker(
            alpha: true,
            defaultValue: SemiColorValue(h: 0, s: 100, v: 100, a: 0.5),
          ),
        ),
      );
      // hex: `hex.slice(0, 7)` — the alpha lives only in the % field.
      expect(colorText(tester), '#ff0000');
      expect(colorText(tester), hasLength(7));
      expect(alphaText(tester), '50');
      // Switch to rgba / hsva via the format Select.
      await tester.tap(find.byKey(SemiColorPicker.formatSelectKey));
      await tester.pumpAndSettle();
      await tester.tap(find.text('rgba'));
      await tester.pumpAndSettle();
      expect(colorText(tester), '255,0,0');
      await tester.tap(find.byKey(SemiColorPicker.formatSelectKey));
      await tester.pumpAndSettle();
      await tester.tap(find.text('hsva'));
      await tester.pumpAndSettle();
      expect(colorText(tester), '0,100,100');
    });

    testWidgets('invalid input keeps the user text and fires nothing (★no '
        'revert)', (tester) async {
      final changes = <SemiColorValue>[];
      await tester.pumpWidget(
        host(
          SemiColorPicker(
            defaultValue: const SemiColorValue(h: 0, s: 100, v: 100),
            onChanged: changes.add,
          ),
        ),
      );
      expect(colorText(tester), '#ff0000');
      await tester.enterText(
        find.descendant(
          of: find.byKey(SemiColorPicker.colorInputKey),
          matching: find.byType(EditableText),
        ),
        'zzz',
      );
      await tester.pump();
      expect(changes, isEmpty);
      expect(colorText(tester), 'zzz');
      // ★3-char shorthand is invalid for the input parser too.
      await tester.enterText(
        find.descendant(
          of: find.byKey(SemiColorPicker.colorInputKey),
          matching: find.byType(EditableText),
        ),
        'f00',
      );
      await tester.pump();
      expect(changes, isEmpty);
      expect(colorText(tester), 'f00');
    });

    testWidgets('valid input resyncs the text from the value (uncontrolled) '
        'and an external value change resyncs too', (tester) async {
      final changes = <SemiColorValue>[];
      const red = SemiColorValue(h: 0, s: 100, v: 100);
      Widget build(SemiColorValue? value) => host(
        SemiColorPicker(
          value: value,
          defaultValue: red,
          onChanged: changes.add,
        ),
        keepState: true,
      );
      await tester.pumpWidget(build(null));
      await tester.enterText(
        find.descendant(
          of: find.byKey(SemiColorPicker.colorInputKey),
          matching: find.byType(EditableText),
        ),
        '00ff00',
      );
      await tester.pump();
      // Uncontrolled: the change lands and the text snaps to the canonical
      // 7-char form.
      expect(changes, [const SemiColorValue(h: 120, s: 100, v: 100)]);
      expect(colorText(tester), '#00ff00');
      // External value change resyncs (lodash isEqual deep-diff).
      await tester.pumpWidget(
        build(const SemiColorValue(h: 240, s: 100, v: 100)),
      );
      await tester.pump();
      expect(colorText(tester), '#0000ff');
    });

    testWidgets('format switcher changes display AND parsing (SemiSelect '
        'hex|rgba|hsva)', (tester) async {
      final changes = <SemiColorValue>[];
      await tester.pumpWidget(
        host(
          SemiColorPicker(
            defaultValue: const SemiColorValue(h: 0, s: 100, v: 100),
            onChanged: changes.add,
          ),
        ),
      );
      await tester.tap(find.byKey(SemiColorPicker.formatSelectKey));
      await tester.pumpAndSettle();
      await tester.tap(find.text('rgba'));
      await tester.pumpAndSettle();
      expect(colorText(tester), '255,0,0');
      // Comma parsing under rgba.
      await tester.enterText(
        find.descendant(
          of: find.byKey(SemiColorPicker.colorInputKey),
          matching: find.byType(EditableText),
        ),
        '12,32,43',
      );
      await tester.pump();
      expect(changes.last, const SemiColorValue(h: 201, s: 72, v: 17));
      // hsva display round-trips the derived hsva.
      await tester.tap(find.byKey(SemiColorPicker.formatSelectKey));
      await tester.pumpAndSettle();
      await tester.tap(find.text('hsva'));
      await tester.pumpAndSettle();
      expect(colorText(tester), '201,72,17');
      // hsva parsing (hue above 360 rejected by split.ts).
      await tester.enterText(
        find.descendant(
          of: find.byKey(SemiColorPicker.colorInputKey),
          matching: find.byType(EditableText),
        ),
        '400,50,50',
      );
      await tester.pump();
      expect(changes, hasLength(1));
      expect(colorText(tester), '400,50,50');
      await tester.enterText(
        find.descendant(
          of: find.byKey(SemiColorPicker.colorInputKey),
          matching: find.byType(EditableText),
        ),
        '120,50,50',
      );
      await tester.pump();
      expect(changes, hasLength(2));
      expect(changes.last, const SemiColorValue(h: 120, s: 50, v: 50));
    });
  });

  group('controlled vs uncontrolled', () {
    testWidgets('uncontrolled commits land and the display follows', (
      tester,
    ) async {
      final changes = <SemiColorValue>[];
      await tester.pumpWidget(
        host(
          SemiColorPicker(
            defaultValue: const SemiColorValue(h: 0, s: 100, v: 100),
            onChanged: changes.add,
          ),
        ),
      );
      expect(colorText(tester), '#ff0000');
      // Bottom-left of the SV area: s = 0, v = 0 -> black.
      await dragOn(
        tester,
        SemiColorPicker.svAreaKey,
        const Offset(0, 279),
        const Offset(0, 279),
      );
      expect(changes.last, const SemiColorValue(h: 0, s: 0, v: 0));
      expect(colorText(tester), '#000000');
    });

    testWidgets('controlled reports only; display follows the prop (★a '
        'deep-equal echo keeps the user text)', (tester) async {
      final changes = <SemiColorValue>[];
      const red = SemiColorValue(h: 0, s: 100, v: 100);
      Widget build(SemiColorValue value) => host(
        SemiColorPicker(value: value, onChanged: changes.add),
        keepState: true,
      );
      await tester.pumpWidget(build(red));
      await dragOn(
        tester,
        SemiColorPicker.svAreaKey,
        const Offset(140, 140),
        const Offset(140, 140),
      );
      // Reported, but the display stays on the prop.
      expect(changes, [const SemiColorValue(h: 0, s: 50, v: 50)]);
      expect(colorText(tester), '#ff0000');
      // A typed edit reports and keeps the raw text while the prop holds
      // (★no resync on a deep-equal value — the controlled echo quirk).
      await tester.enterText(
        find.descendant(
          of: find.byKey(SemiColorPicker.colorInputKey),
          matching: find.byType(EditableText),
        ),
        '00ff00',
      );
      await tester.pump();
      await tester.pumpWidget(build(red));
      await tester.pump();
      expect(changes.last, const SemiColorValue(h: 120, s: 100, v: 100));
      expect(colorText(tester), '00ff00');
      // A real prop change resyncs.
      await tester.pumpWidget(
        build(const SemiColorValue(h: 240, s: 100, v: 100)),
      );
      await tester.pump();
      expect(colorText(tester), '#0000ff');
    });

    testWidgets('releasing control retains the last controlled value', (
      tester,
    ) async {
      const blue = SemiColorValue(h: 240, s: 100, v: 100);
      Widget build(SemiColorValue? value) =>
          host(SemiColorPicker(value: value), keepState: true);
      await tester.pumpWidget(build(blue));
      expect(colorText(tester), '#0000ff');
      await tester.pumpWidget(build(null));
      await tester.pump();
      expect(colorText(tester), '#0000ff');
    });
  });

  group('usePopover', () {
    testWidgets('inline by default; usePopover mounts the hover panel over '
        'the 24x24 default swatch', (tester) async {
      await tester.pumpWidget(
        host(
          const SemiColorPicker(
            usePopover: true,
            motion: false,
            defaultValue: SemiColorValue(h: 0, s: 100, v: 100),
          ),
        ),
      );
      // Default trigger swatch: 24x24 (width-colorPicker-defaultTrigger).
      final swatch = tester.getRect(
        find.byKey(SemiColorPicker.triggerSwatchKey),
      );
      expect(swatch.size, const Size(24, 24));
      // Closed: the panel is not mounted.
      expect(find.byKey(SemiColorPicker.svAreaKey), findsNothing);
      // Hover opens (50ms enter delay).
      final gesture = await startMouse(tester);
      await gesture.moveTo(swatch.center);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 60));
      await tester.pump();
      await tester.pump();
      expect(find.byKey(SemiColorPicker.svAreaKey), findsOneWidget);
      // Leaving closes again.
      await gesture.moveTo(const Offset(5, 5));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 60));
      await tester.pump();
      await tester.pump();
      expect(find.byKey(SemiColorPicker.svAreaKey), findsNothing);
    });

    testWidgets('onOpenChange reports open/close; a custom child replaces '
        'the default swatch', (tester) async {
      final opens = <bool>[];
      await tester.pumpWidget(
        host(
          SemiColorPicker(
            usePopover: true,
            motion: false,
            onChanged: null,
            onOpenChange: opens.add,
            defaultValue: const SemiColorValue(h: 0, s: 100, v: 100),
            child: const Text('pick'),
          ),
        ),
      );
      expect(find.byKey(SemiColorPicker.triggerSwatchKey), findsNothing);
      expect(find.text('pick'), findsOneWidget);
      final gesture = await startMouse(tester);
      await gesture.moveTo(tester.getCenter(find.text('pick')));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 60));
      await tester.pump();
      await tester.pump();
      expect(opens, [true]);
      await gesture.moveTo(const Offset(5, 5));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 60));
      await tester.pump();
      await tester.pump();
      expect(opens, [true, false]);
    });
  });

  group('topSlot / bottomSlot', () {
    testWidgets('slots wrap the panel content', (tester) async {
      await tester.pumpWidget(
        host(
          const SemiColorPicker(
            topSlot: Text('top'),
            bottomSlot: Text('bottom'),
            defaultValue: SemiColorValue(h: 0, s: 100, v: 100),
          ),
        ),
      );
      expect(find.text('top'), findsOneWidget);
      expect(find.text('bottom'), findsOneWidget);
      final top = tester.getTopLeft(find.text('top')).dy;
      final area = tester.getTopLeft(find.byKey(SemiColorPicker.svAreaKey)).dy;
      final bottom = tester.getTopLeft(find.text('bottom')).dy;
      expect(top, lessThan(area));
      expect(area, lessThan(bottom));
    });
  });

  group('eyedropper', () {
    testWidgets('button renders only when eyeDropper && onEyeDropper != null', (
      tester,
    ) async {
      await tester.pumpWidget(
        host(
          const SemiColorPicker(
            defaultValue: SemiColorValue(h: 0, s: 100, v: 100),
          ),
        ),
      );
      // eyeDropper defaults true but the bridge is missing — no button.
      expect(find.byKey(SemiColorPicker.eyeDropperButtonKey), findsNothing);
      await tester.pumpWidget(
        host(
          SemiColorPicker(
            eyeDropper: false,
            onEyeDropper: () async => '#ff0000',
            defaultValue: const SemiColorValue(h: 0, s: 100, v: 100),
          ),
        ),
      );
      expect(find.byKey(SemiColorPicker.eyeDropperButtonKey), findsNothing);
      await tester.pumpWidget(
        host(
          SemiColorPicker(
            onEyeDropper: () async => '#ff0000',
            defaultValue: const SemiColorValue(h: 0, s: 100, v: 100),
          ),
        ),
      );
      expect(find.byKey(SemiColorPicker.eyeDropperButtonKey), findsOneWidget);
    });

    testWidgets('★rgba-string results force a = 1; hex and SemiColorValue '
        'pass through; hsv strings and failures are ignored', (tester) async {
      final changes = <SemiColorValue>[];
      Object? result = 'rgba(255, 0, 0, 0.5)';
      await tester.pumpWidget(
        host(
          SemiColorPicker(
            alpha: true,
            defaultValue: const SemiColorValue(h: 0, s: 100, v: 100),
            onChanged: changes.add,
            onEyeDropper: () async => result,
          ),
        ),
      );
      final button = find.byKey(SemiColorPicker.eyeDropperButtonKey);
      await tester.tap(button);
      await tester.pump();
      // ★rgba strings are forced opaque.
      expect(changes, hasLength(1));
      expect(changes.single.a, 1.0);
      expect(
        (changes.single.r, changes.single.g, changes.single.b),
        (255, 0, 0),
      );
      // Hex strings pass through.
      result = '#00ff00';
      await tester.tap(button);
      await tester.pump();
      expect(changes, hasLength(2));
      expect(changes.last.hex, '#00ff00');
      // SemiColorValue results pass through.
      result = const SemiColorValue(h: 240, s: 100, v: 100);
      await tester.tap(button);
      await tester.pump();
      expect(changes, hasLength(3));
      expect(changes.last, result);
      // ★anything else (hsv strings, garbage) is ignored — upstream only
      // handles `#`/`rgba` and swallows everything else.
      result = 'hsv(0, 100%, 100%)';
      await tester.tap(button);
      await tester.pump();
      result = 'garbage';
      await tester.tap(button);
      await tester.pump();
      result = null;
      await tester.tap(button);
      await tester.pump();
      expect(changes, hasLength(3));
    });

    testWidgets('bridge failures are swallowed (upstream try/catch)', (
      tester,
    ) async {
      final changes = <SemiColorValue>[];
      await tester.pumpWidget(
        host(
          SemiColorPicker(
            defaultValue: const SemiColorValue(h: 0, s: 100, v: 100),
            onChanged: changes.add,
            onEyeDropper: () async => throw Exception('no EyeDropper channel'),
          ),
        ),
      );
      await tester.tap(find.byKey(SemiColorPicker.eyeDropperButtonKey));
      await tester.pump();
      expect(changes, isEmpty);
    });
  });

  group('panel geometry', () {
    testWidgets('width/height are respected (SV area, sliders, data part)', (
      tester,
    ) async {
      await tester.pumpWidget(
        host(
          const SemiColorPicker(
            alpha: true,
            width: 200,
            height: 120,
            defaultValue: SemiColorValue(h: 0, s: 100, v: 100),
          ),
        ),
      );
      expect(
        tester.getRect(find.byKey(SemiColorPicker.svAreaKey)).size,
        const Size(200, 120),
      );
      expect(
        tester.getRect(find.byKey(SemiColorPicker.hueSliderKey)).width,
        200,
      );
      expect(
        tester.getRect(find.byKey(SemiColorPicker.alphaSliderKey)).width,
        200,
      );
      expect(
        tester.getRect(find.byKey(SemiColorPicker.colorInputKey)).width,
        lessThan(200),
      );
    });
  });

  group('theme fields (20 + 0 + 0)', () {
    test('20 fields: merge, copyWith, resolve, equality, defaults', () {
      expect(fields, hasLength(20));
      for (final (sass, value, make, read, expected) in fields) {
        final patch = make(value);
        expect(
          const SemiColorPickerThemeData().merge(patch),
          patch,
          reason: sass,
        );
        expect(patch.copyWith(), patch, reason: sass);
        expect(patch.copyWith().hashCode, patch.hashCode, reason: sass);
        expect(patch.merge(null), patch, reason: sass);
        expect(
          read(patch.resolve(const SemiThemeData.dark())),
          value,
          reason: sass,
        );
        final light = const SemiThemeData.light();
        expect(
          read(const SemiColorPickerThemeData().resolve(light)),
          expected(light),
          reason: sass,
        );
        final dark = const SemiThemeData.dark();
        expect(
          read(const SemiColorPickerThemeData().resolve(dark)),
          expected(dark),
          reason: sass,
        );
      }
    });

    test('every field carries its Sass provenance in the generated source', () {
      final source = File('lib/src/theme/semi_color_picker_theme_data.dart')
          .readAsStringSync();
      final names = <String>{};
      for (final (sass, _, _, _, _) in fields) {
        expect(source, contains(sass));
        names.add(sass.split(': ').first.substring(1));
      }
      expect(names, hasLength(20));
    });

    test('the 11 HARDCODES anchors live in the widget source', () {
      final widgetSource = File('lib/src/components/semi_color_picker.dart')
          .readAsStringSync();
      const anchors = [
        'background-image: linear-gradient(to top, #000, rgba(0, 0, 0, 0)), '
            'linear-gradient(to right, #fff, rgba(255, 255, 255, 0));',
        'box-shadow: inset 0 0 0 1px rgba(0, 0, 0, 0.05);',
        'url(\'data:image/svg+xml,<svg xmlns="http://www.w3.org/2000/svg" '
            'width="16" height="16" fill-opacity=".05"><rect x="8" '
            'width="8" height="8"/><rect y="8" width="8" '
            'height="8"/></svg>\')',
        'linear-gradient(to right, #f00 0%, #ff0 17%, #0f0 33%, #0ff 50%, '
            '#00f 67%, #f0f 83%, #f00 100%)',
        'height={10}',
        'handleSize={18}',
        'handleSize={20}',
        'minWidth: 20, minHeight: 20',
        '}>%</span>',
        'padStart(2, \'0\').toLowerCase()',
        '2px',
      ];
      for (final anchor in anchors) {
        expect(widgetSource, contains(anchor), reason: anchor);
      }
    });

    test('type coverage: 1 Color + 19 double', () {
      final counts = <String, int>{};
      for (final (_, value, _, _, _) in fields) {
        counts.update(
          value.runtimeType.toString(),
          (n) => n + 1,
          ifAbsent: () => 1,
        );
      }
      expect(counts['Color'], 1);
      expect(counts['double'], 19);
    });

    test('SemiComponentThemes wiring', () {
      expect(
        const SemiComponentThemes().colorPicker,
        const SemiColorPickerThemeData(),
      );
      const patch = SemiColorPickerThemeData(
        colorColorPickerHandleBorder: Color(0xff123456),
      );
      const themes = SemiComponentThemes(colorPicker: patch);
      expect(const SemiComponentThemes().copyWith(colorPicker: patch), themes);
      expect(themes == const SemiComponentThemes(), isFalse);
      expect(themes.colorPicker, patch);
    });

    testWidgets('SemiColorPickerTheme local patch applies (nested merge, '
        'inner wins its own field)', (tester) async {
      await tester.pumpWidget(
        host(
          SemiTheme(
            data: const SemiThemeData.light(),
            child: SemiColorPickerTheme(
              data: const SemiColorPickerThemeData(
                widthColorPickerFormatSelect: 100,
              ),
              child: SemiColorPickerTheme(
                data: const SemiColorPickerThemeData(
                  widthColorPickerColorPickerInputNumber: 70,
                ),
                child: const SemiColorPicker(
                  alpha: true,
                  defaultValue: SemiColorValue(h: 0, s: 100, v: 100),
                ),
              ),
            ),
          ),
        ),
      );
      // Outer patch field (format Select width) still applies; the inner
      // patch wins its own field (alpha number width) only.
      expect(tester.getSize(find.byType(SemiSelect)).width, 100.0);
      expect(tester.getSize(find.byType(SemiInputNumber)).width, 70.0);
    });
  });
}
