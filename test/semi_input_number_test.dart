// Behavior matrix for SemiInputNumber plus coverage for the 27 generated
// theme fields (21 FIELDS + 6 MOTION) and the 10 HARDCODES provenance anchors
// living in the widget's `_InputNumberMetrics` (1 INTERNAL declaration stays
// there too: 28 = 27 themed + 1 internal).
import 'dart:io';

import 'package:flutter/gestures.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:semi_design_flutter/semi_design_flutter.dart';

Widget _app(
  Widget body, {
  TextDirection textDirection = TextDirection.ltr,
  double width = 240,
  double textScale = 1,
}) => MediaQuery(
  data: MediaQueryData(
    size: const Size(800, 600),
    textScaler: TextScaler.linear(textScale),
  ),
  child: Directionality(
    textDirection: textDirection,
    child: SemiTheme(
      data: const SemiThemeData.light(),
      child: Center(
        child: SizedBox(width: width, child: body),
      ),
    ),
  ),
);

SemiResolvedInputNumberThemeData _resolve([SemiThemeData? theme]) =>
    const SemiInputNumberThemeData().resolve(
      theme ?? const SemiThemeData.light(),
    );

String inputText(WidgetTester tester) => tester
    .widgetList<EditableText>(find.byType(EditableText))
    .first
    .controller
    .text;

/// Thousands-grouping formatter/parser pair (the doc's `￥1,000` sample).
String groupThousands(String value) =>
    value.replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'), (m) => ',');

String yuanFormatter(String value) => '¥${groupThousands(value)}';

String yuanParser(String value) =>
    value.replaceAll('¥', '').replaceAll(',', '').trim();

/// Background of the outer/inner stepper box (the `-suffix-btns` box).
Color stepperBg(WidgetTester tester) =>
    (tester.widget<Container>(find.byKey(SemiInputNumber.stepperKey)).decoration
            as BoxDecoration)
        .color!;

Color buttonIconColor(WidgetTester tester, {required bool up}) {
  final finder = find.descendant(
    of: find.byKey(
      up ? SemiInputNumber.upButtonKey : SemiInputNumber.downButtonKey,
    ),
    matching: find.byType(SemiIcon),
  );
  return tester.widget<SemiIcon>(finder).color!;
}

BoxDecoration buttonBox(WidgetTester tester, {required bool up}) {
  final finder = find.descendant(
    of: find.byKey(
      up ? SemiInputNumber.upButtonKey : SemiInputNumber.downButtonKey,
    ),
    matching: find.byType(ColoredBox),
  );
  return BoxDecoration(color: tester.widget<ColoredBox>(finder).color);
}

void main() {
  final resolved = _resolve();

  group('value and display', () {
    testWidgets('initialValue displays through formatter+parser', (
      tester,
    ) async {
      await tester.pumpWidget(
        _app(
          SemiInputNumber(
            initialValue: 1000,
            formatter: yuanFormatter,
            parser: yuanParser,
          ),
        ),
      );
      expect(inputText(tester), '¥1,000');
    });

    testWidgets('precision pads the display', (tester) async {
      await tester.pumpWidget(_app(SemiInputNumber(value: 5, precision: 2)));
      expect(inputText(tester), '5.00');
    });

    testWidgets('an out-of-range seed clamps on init', (tester) async {
      await tester.pumpWidget(_app(SemiInputNumber(value: 100, max: 50)));
      expect(inputText(tester), '50');
    });

    testWidgets('an invalid seed displays empty', (tester) async {
      await tester.pumpWidget(_app(SemiInputNumber(initialValue: double.nan)));
      expect(inputText(tester), '');
    });

    testWidgets('init notifies when formatting differs (min clamp)', (
      tester,
    ) async {
      // Upstream `fix controlled min value didMount`: value 0 with min 1
      // displays/announces the clamped 1 once.
      final changes = <String>[];
      final numbers = <num>[];
      await tester.pumpWidget(
        _app(
          SemiInputNumber(
            value: 0,
            min: 1,
            onChanged: changes.add,
            onNumberChange: numbers.add,
          ),
        ),
      );
      expect(inputText(tester), '1');
      expect(changes, ['1']);
      expect(numbers, isEmpty);
    });

    testWidgets('uncontrolled edits land', (tester) async {
      await tester.pumpWidget(_app(SemiInputNumber(initialValue: 5)));
      await tester.enterText(find.byType(EditableText), '7');
      await tester.pump();
      expect(inputText(tester), '7');
      final focusNode = tester
          .widget<SemiInput>(find.byType(SemiInput))
          .focusNode!;
      focusNode.unfocus();
      await tester.pump();
      expect(inputText(tester), '7');
    });

    testWidgets('controlled display follows value when not focusing', (
      tester,
    ) async {
      await tester.pumpWidget(_app(SemiInputNumber(value: 5)));
      expect(inputText(tester), '5');
      await tester.pumpWidget(_app(SemiInputNumber(value: 7.5)));
      expect(inputText(tester), '7.5');
    });

    testWidgets('controlled edits notify only; blur snaps back to value', (
      tester,
    ) async {
      final changes = <String>[];
      final numbers = <num>[];
      final focusNode = FocusNode();
      addTearDown(focusNode.dispose);
      await tester.pumpWidget(
        _app(
          SemiInputNumber(
            value: 5,
            focusNode: focusNode,
            onChanged: changes.add,
            onNumberChange: numbers.add,
          ),
        ),
      );
      await tester.tap(find.byType(EditableText));
      await tester.enterText(find.byType(EditableText), '9');
      await tester.pump();
      // The focusing intermediate state is displayed.
      expect(inputText(tester), '9');
      expect(changes, ['9']);
      expect(numbers, [9]);
      // Blurring without the parent echoing value 9 restores the prop format.
      focusNode.unfocus();
      await tester.pump();
      expect(inputText(tester), '5');
      expect(changes, ['9', '5']);
    });
  });

  group('intermediate input', () {
    testWidgets('a lone minus sign stays alive', (tester) async {
      final changes = <String>[];
      await tester.pumpWidget(
        _app(SemiInputNumber(initialValue: 5, onChanged: changes.add)),
      );
      await tester.enterText(find.byType(EditableText), '-');
      await tester.pump();
      expect(inputText(tester), '-');
      expect(changes, ['-']);
    });

    testWidgets('a trailing dot stays alive', (tester) async {
      await tester.pumpWidget(_app(SemiInputNumber(initialValue: 5)));
      await tester.enterText(find.byType(EditableText), '1.');
      await tester.pump();
      expect(inputText(tester), '1.');
    });

    testWidgets('typed trailing zeros stay alive (uncontrolled)', (
      tester,
    ) async {
      await tester.pumpWidget(_app(const SemiInputNumber()));
      await tester.enterText(find.byType(EditableText), '1.0');
      await tester.pump();
      expect(inputText(tester), '1.0');
    });

    testWidgets('controlled keeps the dot repair (1.0 / 1.10)', (tester) async {
      await tester.pumpWidget(_app(SemiInputNumber(value: 5)));
      await tester.enterText(find.byType(EditableText), '1.0');
      await tester.pump();
      expect(inputText(tester), '1.0');
      await tester.enterText(find.byType(EditableText), '1.10');
      await tester.pump();
      expect(inputText(tester), '1.10');
    });

    testWidgets('empty input clears the number state', (tester) async {
      await tester.pumpWidget(_app(SemiInputNumber(initialValue: 5)));
      await tester.enterText(find.byType(EditableText), '');
      await tester.pump();
      expect(inputText(tester), '');
      // The cleared number makes the next step restart from 0.
      await tester.tap(find.byKey(SemiInputNumber.upButtonKey));
      await tester.pump();
      expect(inputText(tester), '1');
    });

    testWidgets('controlled focusing keeps the intermediate state', (
      tester,
    ) async {
      final focusNode = FocusNode();
      addTearDown(focusNode.dispose);
      await tester.pumpWidget(
        _app(SemiInputNumber(value: 5, focusNode: focusNode)),
      );
      await tester.enterText(find.byType(EditableText), '1.');
      await tester.pump();
      expect(inputText(tester), '1.');
      // A parent rebuild does not clobber the typing state.
      await tester.pumpWidget(
        _app(SemiInputNumber(value: 5, focusNode: focusNode)),
      );
      expect(inputText(tester), '1.');
      focusNode.unfocus();
      await tester.pump();
      expect(inputText(tester), '5');
    });
  });

  group('blur normalization', () {
    testWidgets('blur rounds to precision (四舍五入)', (tester) async {
      final changes = <String>[];
      final numbers = <num>[];
      final focusNode = FocusNode();
      addTearDown(focusNode.dispose);
      await tester.pumpWidget(
        _app(
          SemiInputNumber(
            precision: 1,
            focusNode: focusNode,
            onChanged: changes.add,
            onNumberChange: numbers.add,
          ),
        ),
      );
      await tester.tap(find.byType(EditableText));
      await tester.enterText(find.byType(EditableText), '2.25');
      await tester.pump();
      expect(inputText(tester), '2.25');
      focusNode.unfocus();
      await tester.pump();
      expect(inputText(tester), '2.3');
      // Upstream parity: typing notifies the precision-adjusted number
      // (`notifyChange` runs `toNumber(..., needAdjustPrec)`), so typing
      // '2.25' announces 2.3; blur announces 2.3 again because the committed
      // number (2.25) differs.
      expect(numbers, [2.3, 2.3]);
    });

    testWidgets('blur extracts a number from garbage input', (tester) async {
      final focusNode = FocusNode();
      addTearDown(focusNode.dispose);
      await tester.pumpWidget(
        _app(SemiInputNumber(focusNode: focusNode, max: 100)),
      );
      await tester.tap(find.byType(EditableText));
      await tester.enterText(find.byType(EditableText), '1000CNY');
      await tester.pump();
      expect(inputText(tester), '1000CNY');
      focusNode.unfocus();
      await tester.pump();
      // 1000 is extracted and clamped to max.
      expect(inputText(tester), '100');
    });

    testWidgets('blur falls back to the old value format', (tester) async {
      final focusNode = FocusNode();
      addTearDown(focusNode.dispose);
      await tester.pumpWidget(
        _app(SemiInputNumber(initialValue: 5, focusNode: focusNode)),
      );
      await tester.tap(find.byType(EditableText));
      await tester.enterText(find.byType(EditableText), 'abc');
      await tester.pump();
      focusNode.unfocus();
      await tester.pump();
      expect(inputText(tester), '5');
    });

    testWidgets('blur clamps a typed out-of-range value', (tester) async {
      final focusNode = FocusNode();
      addTearDown(focusNode.dispose);
      await tester.pumpWidget(
        _app(SemiInputNumber(max: 5, focusNode: focusNode)),
      );
      await tester.tap(find.byType(EditableText));
      await tester.enterText(find.byType(EditableText), '10');
      await tester.pump();
      expect(inputText(tester), '10');
      focusNode.unfocus();
      await tester.pump();
      expect(inputText(tester), '5');
    });
  });

  group('stepping', () {
    testWidgets('step and shiftStep', (tester) async {
      await tester.pumpWidget(_app(SemiInputNumber(initialValue: 1)));
      await tester.tap(find.byType(EditableText));
      await tester.pump();
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowUp);
      await tester.pump();
      expect(inputText(tester), '2');
      await tester.sendKeyDownEvent(LogicalKeyboardKey.shiftLeft);
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowUp);
      await tester.sendKeyUpEvent(LogicalKeyboardKey.shiftLeft);
      await tester.pump();
      expect(inputText(tester), '12');
      await tester.sendKeyDownEvent(LogicalKeyboardKey.shiftLeft);
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
      await tester.sendKeyUpEvent(LogicalKeyboardKey.shiftLeft);
      await tester.pump();
      expect(inputText(tester), '2');
    });

    testWidgets('float-safe accumulation (0.1 + 0.2 = 0.3)', (tester) async {
      await tester.pumpWidget(
        _app(SemiInputNumber(initialValue: 0.1, step: 0.2)),
      );
      await tester.tap(find.byKey(SemiInputNumber.upButtonKey));
      await tester.pump();
      expect(inputText(tester), '0.3');
    });

    testWidgets('upstream minus-bug regression (0.9 + 0.1 = 1)', (
      tester,
    ) async {
      await tester.pumpWidget(
        _app(SemiInputNumber(initialValue: 0.9, step: 0.1, max: 1)),
      );
      await tester.tap(find.byKey(SemiInputNumber.upButtonKey));
      await tester.pump();
      expect(inputText(tester), '1');
    });

    testWidgets('the step result rounds to precision (up)', (tester) async {
      await tester.pumpWidget(
        _app(SemiInputNumber(initialValue: 0, step: 2.25, precision: 1)),
      );
      await tester.tap(find.byKey(SemiInputNumber.upButtonKey));
      await tester.pump();
      expect(inputText(tester), '2.3');
    });

    testWidgets('the step result rounds to precision (down)', (tester) async {
      await tester.pumpWidget(
        _app(SemiInputNumber(initialValue: 0, step: 2.25, precision: 1)),
      );
      await tester.tap(find.byKey(SemiInputNumber.downButtonKey));
      await tester.pump();
      // Half away from zero: -2.25 -> -2.3.
      expect(inputText(tester), '-2.3');
    });

    testWidgets('a step that would cross the bound is gated', (tester) async {
      final clicks = <String>[];
      await tester.pumpWidget(
        _app(
          SemiInputNumber(
            initialValue: 3,
            step: 5,
            min: 1,
            onDownClick: clicks.add,
          ),
        ),
      );
      await tester.tap(find.byKey(SemiInputNumber.downButtonKey));
      await tester.pump();
      // |min - 3| = 2 < 5 — the accumulator is skipped.
      expect(inputText(tester), '3');
      // The click still notifies with the unchanged display.
      expect(clicks, ['3']);
    });

    testWidgets('keyboard stepping preserves the caret', (tester) async {
      await tester.pumpWidget(_app(SemiInputNumber(initialValue: 123)));
      await tester.tap(find.byType(EditableText));
      await tester.pump();
      tester
          .widget<EditableText>(find.byType(EditableText))
          .controller
          .selection = const TextSelection.collapsed(
        offset: 2,
      );
      await tester.pump();
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowUp);
      await tester.pump();
      expect(inputText(tester), '124');
      final selection = tester
          .widget<EditableText>(find.byType(EditableText))
          .controller
          .selection;
      expect(selection.start, 2);
    });
  });

  group('formatter and parser', () {
    testWidgets('formatter+parser round trip (¥1,000)', (tester) async {
      final numbers = <num>[];
      await tester.pumpWidget(
        _app(
          SemiInputNumber(
            initialValue: 1000,
            formatter: yuanFormatter,
            parser: yuanParser,
            onNumberChange: numbers.add,
          ),
        ),
      );
      expect(inputText(tester), '¥1,000');
      await tester.enterText(find.byType(EditableText), '2000');
      await tester.pump();
      expect(inputText(tester), '¥2,000');
      expect(numbers, [2000]);
      final focusNode = tester
          .widget<SemiInput>(find.byType(SemiInput))
          .focusNode!;
      focusNode.unfocus();
      await tester.pump();
      // The formatted display survives blur untouched.
      expect(inputText(tester), '¥2,000');
    });

    testWidgets('parser-only normalizes while typing', (tester) async {
      await tester.pumpWidget(
        _app(SemiInputNumber(parser: (v) => v.replaceAll(',', ''))),
      );
      await tester.enterText(find.byType(EditableText), '1,000');
      await tester.pump();
      expect(inputText(tester), '1000');
    });

    testWidgets('formatter-only strips noise (upstream fix controlled '
        'setValue)', (tester) async {
      final numbers = <num>[];
      await tester.pumpWidget(
        _app(
          SemiInputNumber(
            formatter: (v) => v.replaceAll(RegExp(r'\D'), ''),
            onNumberChange: numbers.add,
          ),
        ),
      );
      await tester.enterText(find.byType(EditableText), 'abc');
      await tester.pump();
      expect(inputText(tester), '');
      expect(numbers, isEmpty);
      await tester.enterText(find.byType(EditableText), '123');
      await tester.pump();
      expect(inputText(tester), '123');
      expect(numbers, [123]);
    });
  });

  group('buttons', () {
    testWidgets('tapping up/down steps and notifies the click channels', (
      tester,
    ) async {
      final ups = <String>[];
      final downs = <String>[];
      await tester.pumpWidget(
        _app(
          SemiInputNumber(
            initialValue: 1000,
            onUpClick: ups.add,
            onDownClick: downs.add,
          ),
        ),
      );
      await tester.tap(find.byKey(SemiInputNumber.upButtonKey));
      await tester.pump();
      expect(inputText(tester), '1001');
      expect(ups, ['1001']);
      await tester.tap(find.byKey(SemiInputNumber.downButtonKey));
      await tester.pump();
      expect(inputText(tester), '1000');
      expect(downs, ['1000']);
    });

    testWidgets('the strict boundary is not-allowed: inert but default '
        'styled', (tester) async {
      final ups = <String>[];
      await tester.pumpWidget(
        _app(SemiInputNumber(value: 5, max: 5, onUpClick: ups.add)),
      );
      await tester.tap(find.byKey(SemiInputNumber.upButtonKey));
      await tester.pump();
      expect(inputText(tester), '5');
      expect(ups, isEmpty);
      // `&-button-up-not-allowed` keeps the default look (transparent over
      // the container's bg-default; text stays #14) — only the cursor and
      // the hover/active fills are suppressed.
      expect(buttonBox(tester, up: true).color, const Color(0x00000000));
      expect(
        buttonIconColor(tester, up: true),
        resolved.colorInputNumberButtonTextDefault,
      );
      // The down side stays enabled.
      expect(buttonBox(tester, up: false).color, const Color(0x00000000));
    });

    testWidgets('a non-strict boundary still steps until the gate', (
      tester,
    ) async {
      await tester.pumpWidget(
        _app(SemiInputNumber(value: 4.5, max: 5, step: 1)),
      );
      await tester.tap(find.byKey(SemiInputNumber.upButtonKey));
      await tester.pump();
      // 4.5 != max — allowed, but |5 - 4.5| < 1 gates the accumulator.
      expect(inputText(tester), '4.5');
      expect(buttonBox(tester, up: true).color, const Color(0x00000000));
    });

    testWidgets('right clicks are ignored', (tester) async {
      final ups = <String>[];
      final downs = <String>[];
      await tester.pumpWidget(
        _app(
          SemiInputNumber(
            initialValue: 1000,
            onUpClick: ups.add,
            onDownClick: downs.add,
          ),
        ),
      );
      for (final key in [
        SemiInputNumber.upButtonKey,
        SemiInputNumber.downButtonKey,
      ]) {
        await tester.tap(
          find.byKey(key),
          buttons: kSecondaryMouseButton,
          kind: PointerDeviceKind.mouse,
        );
      }
      await tester.pump();
      expect(inputText(tester), '1000');
      expect(ups, isEmpty);
      expect(downs, isEmpty);
    });

    testWidgets('press-and-hold repeats after pressTimeout', (tester) async {
      await tester.pumpWidget(
        _app(
          SemiInputNumber(
            initialValue: 0,
            pressTimeout: const Duration(milliseconds: 100),
            pressInterval: const Duration(milliseconds: 50),
          ),
        ),
      );
      final gesture = await tester.startGesture(
        tester.getCenter(find.byKey(SemiInputNumber.upButtonKey)),
      );
      await tester.pump();
      // One step immediately.
      expect(inputText(tester), '1');
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump(const Duration(milliseconds: 50));
      expect(inputText(tester), '2');
      await tester.pump(const Duration(milliseconds: 50));
      expect(inputText(tester), '3');
      await gesture.up();
      await tester.pump(const Duration(milliseconds: 500));
      expect(inputText(tester), '3');
    });

    testWidgets('leaving the button stops the repeat', (tester) async {
      await tester.pumpWidget(
        _app(
          SemiInputNumber(
            initialValue: 0,
            pressTimeout: const Duration(milliseconds: 100),
            pressInterval: const Duration(milliseconds: 50),
          ),
        ),
      );
      final gesture = await tester.createGesture(kind: PointerDeviceKind.mouse);
      await gesture.addPointer(location: Offset.zero);
      addTearDown(gesture.removePointer);
      await gesture.moveTo(
        tester.getCenter(find.byKey(SemiInputNumber.upButtonKey)),
      );
      await gesture.down(
        tester.getCenter(find.byKey(SemiInputNumber.upButtonKey)),
      );
      await tester.pump();
      expect(inputText(tester), '1');
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump(const Duration(milliseconds: 50));
      expect(inputText(tester), '2');
      await gesture.moveTo(const Offset(5, 5));
      await tester.pump(const Duration(milliseconds: 500));
      expect(inputText(tester), '2');
      await gesture.up();
    });

    testWidgets('disabled and readonly ignore button presses', (tester) async {
      for (final config in [
        SemiInputNumber(initialValue: 5, disabled: true),
        SemiInputNumber(initialValue: 5, readonly: true),
      ]) {
        await tester.pumpWidget(_app(config));
        await tester.tap(
          find.byKey(SemiInputNumber.upButtonKey),
          warnIfMissed: false,
        );
        await tester.tap(
          find.byKey(SemiInputNumber.downButtonKey),
          warnIfMissed: false,
        );
        await tester.pump();
        expect(inputText(tester), '5');
      }
    });
  });

  group('keyboard', () {
    testWidgets('ArrowUp/ArrowDown step', (tester) async {
      await tester.pumpWidget(_app(SemiInputNumber(initialValue: 1)));
      await tester.tap(find.byType(EditableText));
      await tester.pump();
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowUp);
      await tester.pump();
      expect(inputText(tester), '2');
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
      await tester.pump();
      expect(inputText(tester), '1');
    });

    testWidgets('KeyRepeatEvent repeats the step', (tester) async {
      await tester.pumpWidget(_app(const SemiInputNumber()));
      await tester.tap(find.byType(EditableText));
      await tester.pump();
      await tester.sendKeyDownEvent(LogicalKeyboardKey.arrowUp);
      await tester.pump();
      expect(inputText(tester), '1');
      await tester.sendKeyRepeatEvent(LogicalKeyboardKey.arrowUp);
      await tester.pump();
      expect(inputText(tester), '2');
      await tester.sendKeyUpEvent(LogicalKeyboardKey.arrowUp);
      await tester.pump();
    });

    testWidgets('keyboard steps do not fire onUpClick/onDownClick', (
      tester,
    ) async {
      final ups = <String>[];
      final downs = <String>[];
      await tester.pumpWidget(
        _app(
          SemiInputNumber(
            initialValue: 1,
            onUpClick: ups.add,
            onDownClick: downs.add,
          ),
        ),
      );
      await tester.tap(find.byType(EditableText));
      await tester.pump();
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowUp);
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
      await tester.pump();
      expect(inputText(tester), '1');
      expect(ups, isEmpty);
      expect(downs, isEmpty);
    });

    testWidgets('Enter, Tab, left/right arrows propagate', (tester) async {
      final probed = <KeyEvent>[];
      await tester.pumpWidget(
        _app(
          Focus(
            onKeyEvent: (node, event) {
              if (event is KeyDownEvent) probed.add(event);
              return KeyEventResult.ignored;
            },
            child: SemiInputNumber(initialValue: 1),
          ),
        ),
      );
      await tester.tap(find.byType(EditableText));
      await tester.pump();
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
      await tester.pump();
      // None of these are consumed by the stepper (Enter rides the
      // SemiInput onEnterPress channel; the rest keep their default).
      expect(probed.map((e) => e.logicalKey), [
        LogicalKeyboardKey.enter,
        LogicalKeyboardKey.tab,
        LogicalKeyboardKey.arrowRight,
      ]);
    });

    testWidgets('disabled and readonly ignore arrows', (tester) async {
      for (final config in [
        SemiInputNumber(initialValue: 5, disabled: true),
        SemiInputNumber(initialValue: 5, readonly: true),
      ]) {
        await tester.pumpWidget(_app(config));
        await tester.tap(find.byType(EditableText), warnIfMissed: false);
        await tester.pump();
        await tester.sendKeyEvent(LogicalKeyboardKey.arrowUp);
        await tester.pump();
        expect(inputText(tester), '5');
      }
    });
  });

  group('forms', () {
    testWidgets(
      'innerButtons swaps the suffix with the stepper on hover/focus',
      (tester) async {
        await tester.pumpWidget(
          _app(SemiInputNumber(value: 1, innerButtons: true, suffix: 'S')),
        );
        expect(find.text('S'), findsOneWidget);
        expect(find.byKey(SemiInputNumber.stepperKey), findsNothing);
        final gesture = await tester.createGesture(
          kind: PointerDeviceKind.mouse,
        );
        await gesture.addPointer(location: Offset.zero);
        addTearDown(gesture.removePointer);
        await gesture.moveTo(tester.getCenter(find.byType(EditableText)));
        await tester.pump();
        expect(find.text('S'), findsNothing);
        expect(find.byKey(SemiInputNumber.stepperKey), findsOneWidget);
        await gesture.moveTo(const Offset(5, 5));
        await tester.pump();
        expect(find.text('S'), findsOneWidget);
        expect(find.byKey(SemiInputNumber.stepperKey), findsNothing);
        // Focus also shows the inner stepper.
        await tester.tap(find.byType(EditableText));
        await tester.pump();
        expect(find.byKey(SemiInputNumber.stepperKey), findsOneWidget);
      },
    );

    testWidgets('innerButtons keeps the user suffix while idle', (
      tester,
    ) async {
      await tester.pumpWidget(
        _app(
          SemiInputNumber(
            value: 1,
            innerButtons: true,
            suffix: const Text('unit'),
          ),
        ),
      );
      expect(find.text('unit'), findsOneWidget);
    });

    testWidgets('hideButtons renders no stepper', (tester) async {
      await tester.pumpWidget(
        _app(SemiInputNumber(value: 1, hideButtons: true)),
      );
      expect(find.byKey(SemiInputNumber.stepperKey), findsNothing);
    });

    testWidgets('borderless hides the idle stepper', (tester) async {
      await tester.pumpWidget(
        _app(SemiInputNumber(value: 1, borderless: true)),
      );
      Opacity opacity() => tester.widget<Opacity>(
        find.ancestor(
          of: find.byKey(SemiInputNumber.stepperKey),
          matching: find.byType(Opacity),
        ),
      );
      expect(opacity().opacity, 0);
      final gesture = await tester.createGesture(kind: PointerDeviceKind.mouse);
      await gesture.addPointer(location: Offset.zero);
      addTearDown(gesture.removePointer);
      await gesture.moveTo(tester.getCenter(find.byType(EditableText)));
      await tester.pump();
      expect(opacity().opacity, 1);
    });

    testWidgets('keepFocus keeps the input focused after a press', (
      tester,
    ) async {
      final focusNode = FocusNode();
      addTearDown(focusNode.dispose);
      await tester.pumpWidget(
        _app(
          SemiInputNumber(
            initialValue: 1,
            keepFocus: true,
            focusNode: focusNode,
          ),
        ),
      );
      await tester.tap(find.byType(EditableText));
      await tester.pump();
      expect(focusNode.hasFocus, isTrue);
      await tester.tap(find.byKey(SemiInputNumber.upButtonKey));
      await tester.pump();
      expect(focusNode.hasFocus, isTrue);
      expect(inputText(tester), '2');
    });
  });

  group('states', () {
    testWidgets('disabled blocks edits, steps and keys', (tester) async {
      await tester.pumpWidget(
        _app(SemiInputNumber(initialValue: 5, disabled: true)),
      );
      await tester.tap(find.byType(EditableText), warnIfMissed: false);
      await tester.pump();
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowUp);
      await tester.pump();
      await tester.enterText(find.byType(EditableText), '9');
      await tester.pump();
      expect(inputText(tester), '5');
    });

    testWidgets('readonly blocks edits, steps and keys', (tester) async {
      await tester.pumpWidget(
        _app(SemiInputNumber(initialValue: 5, readonly: true)),
      );
      await tester.tap(find.byType(EditableText), warnIfMissed: false);
      await tester.pump();
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowUp);
      await tester.pump();
      expect(inputText(tester), '5');
    });

    testWidgets('the clear chain empties the value', (tester) async {
      final changes = <String>[];
      final numbers = <num>[];
      var cleared = 0;
      await tester.pumpWidget(
        _app(
          SemiInputNumber(
            value: 5,
            showClear: true,
            onChanged: changes.add,
            onNumberChange: numbers.add,
            onClear: () => cleared += 1,
          ),
        ),
      );
      await tester.tap(find.byType(EditableText));
      await tester.pump();
      await tester.tap(find.byKey(SemiInput.clearButtonKey));
      await tester.pump();
      expect(inputText(tester), '');
      expect(changes, ['']);
      expect(numbers, isEmpty);
      expect(cleared, 1);
    });

    testWidgets('size drives the stepper geometry', (tester) async {
      const heights = {
        SemiInputSize.small: 24.0,
        SemiInputSize.normal: 32.0,
        SemiInputSize.large: 40.0,
      };
      for (final entry in heights.entries) {
        await tester.pumpWidget(
          _app(SemiInputNumber(value: 1, size: entry.key)),
        );
        final size = tester.getSize(find.byKey(SemiInputNumber.stepperKey));
        expect(size.height, entry.value, reason: '${entry.key}');
        expect(size.width, 14, reason: '${entry.key}');
      }
    });

    testWidgets('inner stepper uses the inner heights', (tester) async {
      await tester.pumpWidget(
        _app(SemiInputNumber(value: 1, innerButtons: true, showClear: true)),
      );
      await tester.tap(find.byType(EditableText));
      await tester.pump();
      final size = tester.getSize(find.byKey(SemiInputNumber.stepperKey));
      expect(size.height, 30);
      expect(size.width, 14);
    });

    testWidgets('spinbutton semantics expose value and step actions', (
      tester,
    ) async {
      await tester.pumpWidget(_app(SemiInputNumber(value: 5)));
      expect(
        find.byWidgetPredicate(
          (w) => w is Semantics && w.properties.onIncrease != null,
        ),
        findsOneWidget,
      );
      expect(
        find.byWidgetPredicate(
          (w) => w is Semantics && w.properties.onDecrease != null,
        ),
        findsOneWidget,
      );
    });
  });

  group('scientificNotation', () {
    testWidgets('displays scientific past the threshold', (tester) async {
      await tester.pumpWidget(
        _app(
          SemiInputNumber(value: 1234567890123450, scientificNotation: true),
        ),
      );
      expect(inputText(tester), '1.23456789012345e+15');
      await tester.pumpWidget(
        _app(SemiInputNumber(value: 12345678901234, scientificNotation: true)),
      );
      expect(inputText(tester), '12345678901234');
    });

    testWidgets('focus expands and blur collapses the number', (tester) async {
      final focusNode = FocusNode();
      addTearDown(focusNode.dispose);
      await tester.pumpWidget(
        _app(
          SemiInputNumber(
            value: 1234567890123450,
            scientificNotation: true,
            focusNode: focusNode,
          ),
        ),
      );
      expect(inputText(tester), '1.23456789012345e+15');
      await tester.tap(find.byType(EditableText));
      await tester.pump();
      expect(inputText(tester), '1234567890123450');
      focusNode.unfocus();
      await tester.pump();
      expect(inputText(tester), '1.23456789012345e+15');
    });

    testWidgets('threshold is 15 significant digits', (tester) async {
      await tester.pumpWidget(
        _app(SemiInputNumber(value: 123456789012345, scientificNotation: true)),
      );
      expect(inputText(tester), '1.23456789012345e+14');
      await tester.pumpWidget(
        _app(SemiInputNumber(value: 12345678901234, scientificNotation: true)),
      );
      expect(inputText(tester), '12345678901234');
    });
  });

  group('theme', () {
    test('27 fields default to their Sass sources', () {
      const theme = SemiThemeData.light();
      final r = _resolve(theme);
      expect(
        r.heightInputNumberButtonDefault,
        32,
        reason: r'$height-inputNumber_button_default: $height-control-default',
      );
      expect(
        r.heightInputNumberButtonLarge,
        40,
        reason: r'$height-inputNumber_button_large: $height-control-large',
      );
      expect(
        r.heightInputNumberButtonSmall,
        24,
        reason: r'$height-inputNumber_button_small: $height-control-small',
      );
      expect(
        r.heightInputNumberButtonInnerDefault,
        30,
        reason: r'$height-inputNumber_button_inner_default: $height-control-default - 2px',
      );
      expect(
        r.heightInputNumberButtonInnerLarge,
        38,
        reason: r'$height-inputNumber_button_inner_large: $height-control-large - 2px',
      );
      expect(
        r.heightInputNumberButtonInnerSmall,
        22,
        reason: r'$height-inputNumber_button_inner_small: $height-control-small - 2px',
      );
      expect(
        r.widthInputNumberButton,
        14,
        reason: r'$width-inputNumber_button: 14px',
      );
      expect(
        r.widthInputNumberButtonBorder,
        1,
        reason: r'$width-inputNumber_button-border: 1px',
      );
      expect(
        r.radiusInputNumber,
        theme.radius.borderRadiusSmall.value,
        reason: r'$radius-inputNumber: var(--semi-border-radius-small)',
      );
      expect(
        r.radiusInputNumberInner,
        theme.radius.borderRadiusSmall.value,
        reason: r'$radius-inputNumber_inner: var(--semi-border-radius-small)',
      );
      expect(
        r.spacingInputNumberButtonMarginLeft,
        4,
        reason: r'$spacing-inputNumber_button-marginLeft: 4px',
      );
      expect(
        r.spacingInputNumberButtonInnerMarginLeft,
        8,
        reason: r'$spacing-inputNumber_button_inner-marginLeft: $spacing-tight',
      );
      expect(
        r.spacingInputNumberClearbtnSuffixMarginLeft,
        -4,
        reason: r'$spacing-inputNumber_clearbtn_suffix-marginLeft: -$spacing-extra-tight',
      );
      expect(
        r.colorInputNumberButtonTextDefault,
        theme.colors.colorText2,
        reason:
            r'$color-inputNumber_button-text-default: var(--semi-color-text-2)',
      );
      expect(
        r.colorInputNumberButtonTextDisabled,
        theme.colors.colorDisabledText,
        reason: r'$color-inputNumber_button-text-disabled: var(--semi-color-disabled-text)',
      );
      expect(
        r.colorInputNumberButtonBgDefault,
        theme.colors.colorBg2,
        reason: r'$color-inputNumber_button-bg-default: var(--semi-color-bg-2)',
      );
      expect(
        r.colorInputNumberButtonBgDisabled,
        theme.colors.colorDisabledFill,
        reason: r'$color-inputNumber_button-bg-disabled: var(--semi-color-disabled-fill)',
      );
      expect(
        r.colorInputNumberButtonBgHover,
        theme.colors.colorFill0,
        reason: r'$color-inputNumber_button-bg-hover: var(--semi-color-fill-0)',
      );
      expect(
        r.colorInputNumberButtonBgActive,
        theme.colors.colorFill1,
        reason:
            r'$color-inputNumber_button-bg-active: var(--semi-color-fill-1)',
      );
      expect(
        r.colorInputNumberButtonBorderDefault,
        theme.colors.colorBorder,
        reason: r'$color-inputNumber_button-border-default: var(--semi-color-border)',
      );
      expect(
        r.colorInputNumberButtonBorderHover,
        theme.colors.colorFill2,
        reason:
            r'$color-inputNumber_button-border-hover: var(--semi-color-fill-2)',
      );
      expect(
        r.transitionDurationInputNumberBg,
        Duration.zero,
        reason: r'$transition_duration-inputNumber-bg: var(--semi-transition_duration-none)',
      );
      expect(
        r.transitionFunctionInputNumberBg,
        Curves.easeIn,
        reason: r'$transition_function-inputNumber-bg: var(--semi-transition_function-easeIn)',
      );
      expect(
        r.transitionDelayInputNumberBg,
        Duration.zero,
        reason: r'$transition_delay-inputNumber-bg: var(--semi-transition_delay-none)',
      );
      expect(
        r.transitionDurationInputNumberBorder,
        Duration.zero,
        reason: r'$transition_duration-inputNumber-border: var(--semi-transition_duration-none)',
      );
      expect(
        r.transitionFunctionInputNumberBorder,
        Curves.easeIn,
        reason: r'$transition_function-inputNumber-border: var(--semi-transition_function-easeIn)',
      );
      expect(
        r.transitionDelayInputNumberBorder,
        Duration.zero,
        reason: r'$transition_delay-inputNumber-border: var(--semi-transition_delay-none)',
      );
    });

    test('copyWith overrides only the given fields', () {
      const base = SemiInputNumberThemeData();
      final updated = base.copyWith(
        colorInputNumberButtonBgDefault: Color(0xff00ff00),
      );
      expect(updated.colorInputNumberButtonBgDefault, const Color(0xff00ff00));
      expect(updated.widthInputNumberButton, base.widthInputNumberButton);
    });

    test('merge keeps the original for null and lets the other win', () {
      const a = SemiInputNumberThemeData(widthInputNumberButton: 100);
      const b = SemiInputNumberThemeData(
        widthInputNumberButton: 200,
        heightInputNumberButtonDefault: 33,
      );
      expect(a.merge(null), a);
      expect(a.merge(b).widthInputNumberButton, 200);
      expect(a.merge(b).heightInputNumberButtonDefault, 33);
    });

    test('equality and hashCode are value based', () {
      const a = SemiInputNumberThemeData(
        transitionFunctionInputNumberBg: Curves.easeIn,
      );
      const b = SemiInputNumberThemeData(
        transitionFunctionInputNumberBg: Curves.easeIn,
      );
      const c = SemiInputNumberThemeData(widthInputNumberButton: 1);
      expect(a, b);
      expect(a.hashCode, b.hashCode);
      expect(a == c, isFalse);
    });

    test('every declaration and hardcode carries its provenance', () {
      final theme = File('lib/src/theme/semi_input_number_theme_data.dart')
          .readAsStringSync();
      final widget = File('lib/src/components/semi_input_number.dart')
          .readAsStringSync();
      // 27 themed declarations live in the theme source...
      for (final declaration in [
        r'$height-inputNumber_button_default: $height-control-default',
        r'$height-inputNumber_button_large: $height-control-large',
        r'$height-inputNumber_button_small: $height-control-small',
        r'$height-inputNumber_button_inner_default: $height-control-default - 2px',
        r'$height-inputNumber_button_inner_large: $height-control-large - 2px',
        r'$height-inputNumber_button_inner_small: $height-control-small - 2px',
        r'$width-inputNumber_button: 14px',
        r'$width-inputNumber_button-border: 1px',
        r'$radius-inputNumber: var(--semi-border-radius-small)',
        r'$radius-inputNumber_inner: var(--semi-border-radius-small)',
        r'$spacing-inputNumber_button-marginLeft: 4px',
        r'$spacing-inputNumber_button_inner-marginLeft: $spacing-tight',
        r'$spacing-inputNumber_clearbtn_suffix-marginLeft: -$spacing-extra-tight',
        r'$color-inputNumber_button-text-default: var(--semi-color-text-2)',
        r'$color-inputNumber_button-text-disabled: var(--semi-color-disabled-text)',
        r'$color-inputNumber_button-bg-default: var(--semi-color-bg-2)',
        r'$color-inputNumber_button-bg-disabled: var(--semi-color-disabled-fill)',
        r'$color-inputNumber_button-bg-hover: var(--semi-color-fill-0)',
        r'$color-inputNumber_button-bg-active: var(--semi-color-fill-1)',
        r'$color-inputNumber_button-border-default: var(--semi-color-border)',
        r'$color-inputNumber_button-border-hover: var(--semi-color-fill-2)',
        r'$transition_duration-inputNumber-bg: var(--semi-transition_duration-none)',
        r'$transition_function-inputNumber-bg: var(--semi-transition_function-easeIn)',
        r'$transition_delay-inputNumber-bg: var(--semi-transition_delay-none)',
        r'$transition_duration-inputNumber-border: var(--semi-transition_duration-none)',
        r'$transition_function-inputNumber-border: var(--semi-transition_function-easeIn)',
        r'$transition_delay-inputNumber-border: var(--semi-transition_delay-none)',
      ]) {
        expect(theme, contains(declaration));
      }
      // ...the INTERNAL declaration and the HARDCODES anchors live in the
      // widget source.
      expect(
        widget,
        contains(
          r'$transform_scale-inputNumber: var(--semi-transform_scale-none)',
        ),
      );
      for (final snippet in [
        'size="extra-small"',
        'DEFAULT_PRESS_TIMEOUT: 250',
        'DEFAULT_STEP: 1',
        'DEFAULT_SHIFT_STEP: 10',
        'MOUSE_BUTTON_LEFT: 0',
        'Default threshold: 15 digits',
        'height: 50%',
        'overflow: hidden',
        'cursor: not-allowed',
        'opacity: 0',
      ]) {
        expect(widget, contains(snippet));
      }
    });

    testWidgets('a local patch applies (plain nesting)', (tester) async {
      const patched = Color(0xff876543);
      await tester.pumpWidget(
        _app(
          SemiInputNumberTheme(
            data: const SemiInputNumberThemeData(
              colorInputNumberButtonBgDefault: patched,
            ),
            child: SemiInputNumber(value: 1),
          ),
        ),
      );
      expect(stepperBg(tester), patched);
    });
  });
}
