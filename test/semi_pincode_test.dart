// Behavior matrix for SemiPinCode plus coverage for the 6 generated theme
// fields (6 FIELDS + 0 MOTION) and the 4 HARDCODES provenance anchors living
// in the widget's `_PinCodeMetrics` (0 INTERNAL declarations: 6 = 6 themed).
import 'dart:io';

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

SemiResolvedPinCodeThemeData _resolve([SemiThemeData? theme]) =>
    const SemiPinCodeThemeData().resolve(theme ?? const SemiThemeData.light());

SemiResolvedInputThemeData _inputResolve([SemiThemeData? theme]) =>
    const SemiInputThemeData().resolve(theme ?? const SemiThemeData.light());

List<String> cellTexts(WidgetTester tester) => [
  for (final edit in tester.widgetList<EditableText>(find.byType(EditableText)))
    edit.controller.text,
];

List<EditableText> _edits(WidgetTester tester) =>
    tester.widgetList<EditableText>(find.byType(EditableText)).toList();

BoxDecoration cellBox(WidgetTester tester, int index) =>
    tester
            .widget<DecoratedBox>(find.byKey(SemiPinCode.cellKey(index)))
            .decoration
        as BoxDecoration;

Color cellBorderColor(WidgetTester tester, int index) =>
    (cellBox(tester, index).border as Border).top.color;

Rect cellRect(WidgetTester tester, int index) =>
    tester.getRect(find.byKey(SemiPinCode.cellKey(index)));

/// Index of the cell holding the primary focus, -1 when none.
int focusedIndex(WidgetTester tester) {
  final edits = _edits(tester);
  for (var i = 0; i < edits.length; i++) {
    if (edits[i].focusNode.hasPrimaryFocus) return i;
  }
  return -1;
}

void main() {
  group('rendering', () {
    testWidgets('renders 6 cells by default inside one row', (tester) async {
      await tester.pumpWidget(_app(const SemiPinCode()));
      expect(find.byType(EditableText), findsNWidgets(6));
      final row = find.descendant(
        of: find.byType(SemiPinCode),
        matching: find.byType(Row),
      );
      expect(row, findsOneWidget);
      expect(tester.widget<Row>(row).children, hasLength(6));
    });

    testWidgets('count renders a custom number of cells', (tester) async {
      await tester.pumpWidget(_app(const SemiPinCode(count: 4)));
      expect(find.byType(EditableText), findsNWidgets(4));
    });

    testWidgets('seeds value/initialValue per character', (tester) async {
      await tester.pumpWidget(_app(const SemiPinCode(initialValue: '12')));
      expect(cellTexts(tester), ['1', '2', '', '', '', '']);
      await tester.pumpWidget(_app(const SemiPinCode(value: '123456')));
      expect(cellTexts(tester), ['1', '2', '3', '4', '5', '6']);
    });

    testWidgets('cell selection highlight is wired to the theme primary', (
      tester,
    ) async {
      // Regression: RenderEditable paints no selection band when
      // selectionColor is null — selected cell text was invisible.
      await tester.pumpWidget(_app(const SemiPinCode(initialValue: '1')));
      final expected = const SemiThemeData.light().colors.colorPrimary
          .withValues(alpha: 0.4);
      for (final edit in _edits(tester)) {
        expect(edit.selectionColor, expected);
      }
    });
  });

  group('geometry', () {
    testWidgets('small cells are 24x24 with 6px gaps and no trailing gap', (
      tester,
    ) async {
      await tester.pumpWidget(
        _app(
          const SemiPinCode(count: 3, size: SemiInputSize.small),
          width: 300,
        ),
      );
      for (var i = 0; i < 3; i++) {
        expect(
          tester.getSize(find.byKey(SemiPinCode.cellKey(i))),
          const Size(24, 24),
          reason: r'$width-pinCode_input_small / $height-input_wrapper_small',
        );
      }
      expect(cellRect(tester, 1).left - cellRect(tester, 0).right, 6);
      expect(cellRect(tester, 2).left - cellRect(tester, 1).right, 6);
      // `&:last-child { margin-right: 0px; }` — the cells span exactly
      // count * width + (count - 1) * gap with no trailing gap.
      expect(
        cellRect(tester, 2).right - cellRect(tester, 0).left,
        3 * 24 + 2 * 6,
      );
    });

    testWidgets('default cells are 32x32 with 8px gaps and no trailing gap', (
      tester,
    ) async {
      await tester.pumpWidget(_app(const SemiPinCode(count: 3), width: 300));
      for (var i = 0; i < 3; i++) {
        expect(
          tester.getSize(find.byKey(SemiPinCode.cellKey(i))),
          const Size(32, 32),
          reason:
              r'$width-pinCode_input_default / $height-input_wrapper_default',
        );
      }
      expect(cellRect(tester, 1).left - cellRect(tester, 0).right, 8);
      expect(cellRect(tester, 2).left - cellRect(tester, 1).right, 8);
      // `&:last-child { margin-right: 0px; }`.
      expect(
        cellRect(tester, 2).right - cellRect(tester, 0).left,
        3 * 32 + 2 * 8,
      );
    });

    testWidgets('large cells are 42x40 with 12px gaps and no trailing gap', (
      tester,
    ) async {
      await tester.pumpWidget(
        _app(
          const SemiPinCode(count: 3, size: SemiInputSize.large),
          width: 400,
        ),
      );
      for (var i = 0; i < 3; i++) {
        expect(
          tester.getSize(find.byKey(SemiPinCode.cellKey(i))),
          const Size(42, 40),
          reason: r'$width-pinCode_input_large / $height-input_wrapper_large',
        );
      }
      expect(cellRect(tester, 1).left - cellRect(tester, 0).right, 12);
      expect(cellRect(tester, 2).left - cellRect(tester, 1).right, 12);
      // `&:last-child { margin-right: 0px; }`.
      expect(
        cellRect(tester, 2).right - cellRect(tester, 0).left,
        3 * 42 + 2 * 12,
      );
    });
  });

  group('input and skip', () {
    testWidgets('a single input lands and focuses the next cell', (
      tester,
    ) async {
      final changes = <String>[];
      await tester.pumpWidget(
        _app(SemiPinCode(count: 3, onChanged: changes.add)),
      );
      await tester.enterText(find.byType(EditableText).at(0), '1');
      await tester.pump();
      expect(cellTexts(tester), ['1', '', '']);
      expect(changes, ['1']);
      expect(focusedIndex(tester), 1);
    });

    testWidgets('the last-cell input completes once and blurs everything', (
      tester,
    ) async {
      final changes = <String>[];
      final completes = <String>[];
      await tester.pumpWidget(
        _app(
          SemiPinCode(
            count: 3,
            initialValue: '12',
            onChanged: changes.add,
            onComplete: completes.add,
          ),
        ),
      );
      await tester.tap(find.byKey(SemiPinCode.cellKey(2)));
      await tester.pump();
      await tester.enterText(find.byType(EditableText).at(2), '3');
      await tester.pump();
      expect(changes, ['123']);
      expect(completes, ['123']);
      expect(focusedIndex(tester), -1);
    });

    testWidgets(
      'overwrite semantics keep the last character of the text ("19" -> "9")',
      (tester) async {
        final changes = <String>[];
        await tester.pumpWidget(
          _app(
            SemiPinCode(count: 3, initialValue: '1', onChanged: changes.add),
          ),
        );
        await tester.enterText(find.byType(EditableText).at(0), '19');
        await tester.pump();
        expect(cellTexts(tester), ['9', '', '']);
        expect(changes, ['9']);
        expect(focusedIndex(tester), 1);
      },
    );

    testWidgets('invalid characters are silently ignored (number "a")', (
      tester,
    ) async {
      final changes = <String>[];
      await tester.pumpWidget(
        _app(SemiPinCode(count: 3, onChanged: changes.add)),
      );
      await tester.enterText(find.byType(EditableText).at(0), 'a');
      await tester.pump();
      expect(cellTexts(tester), ['', '', '']);
      expect(changes, isEmpty);
      expect(focusedIndex(tester), 0);
    });
  });

  group('keyboard', () {
    testWidgets('Backspace clears the cell and steps back', (tester) async {
      final changes = <String>[];
      await tester.pumpWidget(
        _app(
          SemiPinCode(count: 3, initialValue: '123', onChanged: changes.add),
        ),
      );
      await tester.tap(find.byKey(SemiPinCode.cellKey(2)));
      await tester.pump();
      await tester.sendKeyEvent(LogicalKeyboardKey.backspace);
      await tester.pump();
      expect(cellTexts(tester), ['1', '2', '']);
      expect(changes, ['12']);
      expect(focusedIndex(tester), 1);
    });

    testWidgets('Backspace on an empty cell still steps back', (tester) async {
      final changes = <String>[];
      await tester.pumpWidget(
        _app(SemiPinCode(count: 3, initialValue: '1', onChanged: changes.add)),
      );
      await tester.tap(find.byKey(SemiPinCode.cellKey(2)));
      await tester.pump();
      await tester.sendKeyEvent(LogicalKeyboardKey.backspace);
      await tester.pump();
      expect(cellTexts(tester), ['1', '', '']);
      expect(changes, ['1']);
      expect(focusedIndex(tester), 1);
    });

    testWidgets('Backspace clamps at the first cell', (tester) async {
      final changes = <String>[];
      await tester.pumpWidget(
        _app(
          SemiPinCode(count: 3, initialValue: '123', onChanged: changes.add),
        ),
      );
      await tester.tap(find.byKey(SemiPinCode.cellKey(0)));
      await tester.pump();
      await tester.sendKeyEvent(LogicalKeyboardKey.backspace);
      await tester.pump();
      expect(cellTexts(tester), ['', '2', '3']);
      expect(changes, ['23']);
      expect(focusedIndex(tester), 0);
    });

    testWidgets('Delete clears the cell and steps forward', (tester) async {
      final changes = <String>[];
      await tester.pumpWidget(
        _app(
          SemiPinCode(count: 3, initialValue: '123', onChanged: changes.add),
        ),
      );
      await tester.tap(find.byKey(SemiPinCode.cellKey(1)));
      await tester.pump();
      await tester.sendKeyEvent(LogicalKeyboardKey.delete);
      await tester.pump();
      expect(cellTexts(tester), ['1', '', '3']);
      expect(changes, ['13']);
      expect(focusedIndex(tester), 2);
    });

    testWidgets('Delete clamps at the last cell', (tester) async {
      final changes = <String>[];
      await tester.pumpWidget(
        _app(
          SemiPinCode(count: 3, initialValue: '123', onChanged: changes.add),
        ),
      );
      await tester.tap(find.byKey(SemiPinCode.cellKey(2)));
      await tester.pump();
      await tester.sendKeyEvent(LogicalKeyboardKey.delete);
      await tester.pump();
      expect(cellTexts(tester), ['1', '2', '']);
      expect(changes, ['12']);
      expect(focusedIndex(tester), 2);
    });

    testWidgets('ArrowLeft/ArrowRight only move focus, clamped', (
      tester,
    ) async {
      final changes = <String>[];
      await tester.pumpWidget(
        _app(
          SemiPinCode(count: 3, initialValue: '123', onChanged: changes.add),
        ),
      );
      await tester.tap(find.byKey(SemiPinCode.cellKey(0)));
      await tester.pump();
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowLeft);
      await tester.pump();
      expect(focusedIndex(tester), 0);
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
      await tester.pump();
      expect(focusedIndex(tester), 1);
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
      await tester.pump();
      expect(focusedIndex(tester), 2);
      // No value changes on the arrow keys (no Home/End handling).
      expect(cellTexts(tester), ['1', '2', '3']);
      expect(changes, isEmpty);
    });

    testWidgets('Enter, Tab, Escape and character keys propagate', (
      tester,
    ) async {
      final probed = <KeyEvent>[];
      await tester.pumpWidget(
        _app(
          Focus(
            onKeyEvent: (node, event) {
              if (event is KeyDownEvent) probed.add(event);
              return KeyEventResult.ignored;
            },
            child: const SemiPinCode(count: 3),
          ),
        ),
      );
      await tester.tap(find.byKey(SemiPinCode.cellKey(0)));
      await tester.pump();
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.sendKeyEvent(LogicalKeyboardKey.escape);
      await tester.sendKeyEvent(LogicalKeyboardKey.keyA);
      await tester.pump();
      expect(probed.map((e) => e.logicalKey), [
        LogicalKeyboardKey.enter,
        LogicalKeyboardKey.tab,
        LogicalKeyboardKey.escape,
        LogicalKeyboardKey.keyA,
      ]);
    });
  });

  group('paste', () {
    testWidgets('a paste from cell 0 fills forward with per-write notifies', (
      tester,
    ) async {
      final changes = <String>[];
      await tester.pumpWidget(
        _app(SemiPinCode(count: 6, onChanged: changes.add)),
      );
      await tester.enterText(find.byType(EditableText).at(0), '1234');
      await tester.pump();
      expect(cellTexts(tester), ['1', '2', '3', '4', '', '']);
      expect(changes, ['1', '12', '123', '1234']);
      expect(focusedIndex(tester), 4);
    });

    testWidgets('a paste that fills the last cell completes and blurs', (
      tester,
    ) async {
      final completes = <String>[];
      final changes = <String>[];
      await tester.pumpWidget(
        _app(
          SemiPinCode(
            count: 4,
            onChanged: changes.add,
            onComplete: completes.add,
          ),
        ),
      );
      await tester.enterText(find.byType(EditableText).at(0), '1234');
      await tester.pump();
      expect(cellTexts(tester), ['1', '2', '3', '4']);
      expect(changes, ['1', '12', '123', '1234']);
      expect(completes, ['1234']);
      expect(focusedIndex(tester), -1);
    });

    testWidgets('a paste from a middle cell distributes partially', (
      tester,
    ) async {
      await tester.pumpWidget(_app(const SemiPinCode(count: 6)));
      await tester.tap(find.byKey(SemiPinCode.cellKey(2)));
      await tester.pump();
      await tester.enterText(find.byType(EditableText).at(2), '12');
      await tester.pump();
      expect(cellTexts(tester), ['', '', '1', '2', '', '']);
      expect(focusedIndex(tester), 4);
    });

    testWidgets('an invalid character stops the distribution (kept cells)', (
      tester,
    ) async {
      final changes = <String>[];
      await tester.pumpWidget(
        _app(SemiPinCode(count: 6, onChanged: changes.add)),
      );
      await tester.enterText(find.byType(EditableText).at(0), '12a3');
      await tester.pump();
      expect(cellTexts(tester), ['1', '2', '', '', '', '']);
      expect(changes, ['1', '12']);
      expect(focusedIndex(tester), 2);
    });
  });

  group('format', () {
    testWidgets('mixed accepts digits and letters, rejects symbols', (
      tester,
    ) async {
      final changes = <String>[];
      await tester.pumpWidget(
        _app(
          SemiPinCode(
            count: 3,
            format: SemiPinCodeFormat.mixed,
            onChanged: changes.add,
          ),
        ),
      );
      await tester.enterText(find.byType(EditableText).at(0), 'a');
      await tester.pump();
      await tester.enterText(find.byType(EditableText).at(1), '5');
      await tester.pump();
      await tester.enterText(find.byType(EditableText).at(2), '!');
      await tester.pump();
      expect(cellTexts(tester), ['a', '5', '']);
      expect(changes, ['a', 'a5']);
    });

    testWidgets('RegExp accepts only its matches (upper case only)', (
      tester,
    ) async {
      final changes = <String>[];
      await tester.pumpWidget(
        _app(
          SemiPinCode(
            count: 3,
            format: RegExp(r'[A-Z]'),
            onChanged: changes.add,
          ),
        ),
      );
      await tester.enterText(find.byType(EditableText).at(0), 'A');
      await tester.pump();
      await tester.enterText(find.byType(EditableText).at(1), 'a');
      await tester.pump();
      expect(cellTexts(tester), ['A', '', '']);
      expect(changes, ['A']);
    });

    testWidgets(
      'RegExp has no empty-string escape (empty delta writes nothing)',
      (tester) async {
        // Upstream `validateValue` for RegExp is a bare `hasMatch` — no
        // `value.isEmpty ||` short-circuit (空串不放行); the port additionally
        // ignores empty text deltas outright (deletion rides the keys).
        final changes = <String>[];
        await tester.pumpWidget(
          _app(
            SemiPinCode(
              count: 3,
              initialValue: '12',
              format: RegExp(r'\d*'),
              onChanged: changes.add,
            ),
          ),
        );
        await tester.enterText(find.byType(EditableText).at(0), '');
        await tester.pump();
        expect(cellTexts(tester), ['1', '2', '']);
        expect(changes, isEmpty);
        expect(focusedIndex(tester), 0);
      },
    );

    testWidgets('a function format runs per character', (tester) async {
      final changes = <String>[];
      final seen = <String>[];
      await tester.pumpWidget(
        _app(
          SemiPinCode(
            count: 3,
            format: (value) {
              seen.add(value);
              return value == 'a' || value == 'b';
            },
            onChanged: changes.add,
          ),
        ),
      );
      await tester.enterText(find.byType(EditableText).at(0), 'a');
      await tester.pump();
      await tester.enterText(find.byType(EditableText).at(1), 'c');
      await tester.pump();
      expect(cellTexts(tester), ['a', '', '']);
      expect(changes, ['a']);
      expect(seen, ['a', 'c']);
    });
  });

  group('controlled', () {
    testWidgets('edits notify only; the display follows value', (tester) async {
      final changes = <String>[];
      await tester.pumpWidget(
        _app(SemiPinCode(count: 6, value: '123456', onChanged: changes.add)),
      );
      await tester.enterText(find.byType(EditableText).at(0), '9');
      await tester.pump();
      expect(cellTexts(tester), ['1', '2', '3', '4', '5', '6']);
      expect(changes, ['923456']);
      await tester.pumpWidget(
        _app(SemiPinCode(count: 6, value: '923456', onChanged: changes.add)),
      );
      expect(cellTexts(tester), ['9', '2', '3', '4', '5', '6']);
    });

    testWidgets('Backspace notifies without landing while controlled', (
      tester,
    ) async {
      final changes = <String>[];
      await tester.pumpWidget(
        _app(SemiPinCode(count: 6, value: '123456', onChanged: changes.add)),
      );
      await tester.tap(find.byKey(SemiPinCode.cellKey(0)));
      await tester.pump();
      await tester.sendKeyEvent(LogicalKeyboardKey.backspace);
      await tester.pump();
      expect(cellTexts(tester), ['1', '2', '3', '4', '5', '6']);
      expect(changes, ['23456']);
    });
  });

  group('value join', () {
    testWidgets('onChanged joins with empty slots erased', (tester) async {
      final changes = <String>[];
      await tester.pumpWidget(
        _app(
          SemiPinCode(count: 4, initialValue: '1234', onChanged: changes.add),
        ),
      );
      await tester.tap(find.byKey(SemiPinCode.cellKey(1)));
      await tester.pump();
      await tester.sendKeyEvent(LogicalKeyboardKey.backspace);
      await tester.pump();
      expect(cellTexts(tester), ['1', '', '3', '4']);
      expect(changes, ['134']);
    });

    testWidgets('onComplete fires again after a delete and refill', (
      tester,
    ) async {
      final completes = <String>[];
      await tester.pumpWidget(
        _app(SemiPinCode(count: 2, onComplete: completes.add)),
      );
      await tester.enterText(find.byType(EditableText).at(0), '1');
      await tester.pump();
      await tester.enterText(find.byType(EditableText).at(1), '2');
      await tester.pump();
      expect(completes, ['12']);
      await tester.tap(find.byKey(SemiPinCode.cellKey(1)));
      await tester.pump();
      await tester.sendKeyEvent(LogicalKeyboardKey.backspace);
      await tester.pump();
      await tester.enterText(find.byType(EditableText).at(0), '3');
      await tester.pump();
      await tester.enterText(find.byType(EditableText).at(1), '4');
      await tester.pump();
      expect(completes, ['12', '34']);
    });
  });

  group('states', () {
    testWidgets('disabled blocks taps and keys and paints the disabled look', (
      tester,
    ) async {
      final changes = <String>[];
      final input = _inputResolve();
      await tester.pumpWidget(
        _app(
          SemiPinCode(
            count: 3,
            initialValue: '5',
            disabled: true,
            onChanged: changes.add,
          ),
        ),
      );
      expect(cellBox(tester, 0).color, input.colorInputDisabledBgDefault);
      expect(cellBorderColor(tester, 0), input.colorInputDefaultBorderDefault);
      await tester.tap(find.byKey(SemiPinCode.cellKey(0)), warnIfMissed: false);
      await tester.pump();
      expect(focusedIndex(tester), -1);
      await tester.sendKeyEvent(LogicalKeyboardKey.backspace);
      await tester.pump();
      expect(cellTexts(tester), ['5', '', '']);
      expect(changes, isEmpty);
    });

    testWidgets('autoFocus focuses cell 0 by default', (tester) async {
      await tester.pumpWidget(_app(const SemiPinCode(count: 3)));
      await tester.pump();
      expect(focusedIndex(tester), 0);
    });

    testWidgets('autoFocus: false leaves every cell unfocused', (tester) async {
      await tester.pumpWidget(
        _app(const SemiPinCode(count: 3, autoFocus: false)),
      );
      await tester.pump();
      expect(focusedIndex(tester), -1);
    });

    testWidgets('validateStatus paints every cell (error/warning)', (
      tester,
    ) async {
      final input = _inputResolve();
      for (final (status, focusedBorder, idleBorder) in [
        (
          SemiInputStatus.error,
          input.colorInputDangerBorderFocus,
          input.colorInputDangerBorderDefault,
        ),
        (
          SemiInputStatus.warning,
          input.colorInputWarningBorderFocus,
          input.colorInputWarningBorderDefault,
        ),
      ]) {
        await tester.pumpWidget(
          _app(SemiPinCode(count: 3, validateStatus: status)),
        );
        await tester.pump();
        // Cell 0 holds the autoFocus, the rest are idle.
        expect(cellBorderColor(tester, 0), focusedBorder);
        expect(cellBorderColor(tester, 1), idleBorder);
        expect(cellBorderColor(tester, 2), idleBorder);
      }
    });

    testWidgets('focused cells use the input focus border', (tester) async {
      final input = _inputResolve();
      await tester.pumpWidget(_app(const SemiPinCode(count: 3)));
      await tester.pump();
      expect(cellBorderColor(tester, 0), input.colorInputDefaultBorderFocus);
      expect(cellBorderColor(tester, 1), input.colorInputDefaultBorderDefault);
      await tester.tap(find.byKey(SemiPinCode.cellKey(1)));
      await tester.pump();
      expect(cellBorderColor(tester, 1), input.colorInputDefaultBorderFocus);
      expect(cellBorderColor(tester, 0), input.colorInputDefaultBorderDefault);
    });
  });

  group('blur and controller', () {
    testWidgets('onBlur fires only when the whole component loses focus', (
      tester,
    ) async {
      final blurs = <int>[];
      await tester.pumpWidget(
        _app(
          SemiPinCode(
            count: 3,
            initialValue: '123',
            onBlur: () => blurs.add(1),
          ),
        ),
      );
      await tester.pump();
      expect(focusedIndex(tester), 0);
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
      await tester.pump();
      expect(focusedIndex(tester), 1);
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowLeft);
      await tester.pump();
      expect(focusedIndex(tester), 0);
      // Cell-to-cell moves never blur the component.
      expect(blurs, isEmpty);
      FocusManager.instance.primaryFocus?.unfocus();
      // The focus change applies as a microtask (after the pumped frame), so
      // the one-frame-deferred blur check lands on the following frame.
      await tester.pump();
      await tester.pump();
      expect(blurs, [1]);
    });

    testWidgets('controller.focus/blur drive the cells (caret to the end)', (
      tester,
    ) async {
      final controller = SemiPinCodeController();
      await tester.pumpWidget(
        _app(
          SemiPinCode(
            count: 3,
            initialValue: '12',
            autoFocus: false,
            controller: controller,
          ),
        ),
      );
      controller.focus(1);
      await tester.pump();
      expect(focusedIndex(tester), 1);
      final edit = _edits(tester)[1];
      expect(edit.controller.selection.baseOffset, edit.controller.text.length);
      controller.blur(1);
      await tester.pump();
      expect(focusedIndex(tester), -1);
    });

    testWidgets('controller methods are no-ops once detached', (tester) async {
      final controller = SemiPinCodeController();
      await tester.pumpWidget(
        _app(SemiPinCode(count: 2, controller: controller)),
      );
      await tester.pumpWidget(_app(const SizedBox()));
      controller.focus(0);
      controller.blur(0);
    });
  });

  group('IME composition', () {
    testWidgets('composition deltas are ignored until the commit', (
      tester,
    ) async {
      final changes = <String>[];
      await tester.pumpWidget(
        _app(SemiPinCode(count: 3, onChanged: changes.add)),
      );
      await tester.showKeyboard(find.byType(EditableText).at(0));
      // Upstream `isComposing` guard: nothing lands mid-composition.
      tester.testTextInput.updateEditingValue(
        const TextEditingValue(
          text: 'n',
          selection: TextSelection.collapsed(offset: 1),
          composing: TextRange(start: 0, end: 1),
        ),
      );
      await tester.pump();
      expect(changes, isEmpty);
      expect(cellTexts(tester).skip(1), ['', '']);
      // The composition commits as a converted character.
      tester.testTextInput.updateEditingValue(
        const TextEditingValue(
          text: '5',
          selection: TextSelection.collapsed(offset: 1),
        ),
      );
      await tester.pump();
      expect(changes, ['5']);
      expect(cellTexts(tester), ['5', '', '']);
    });
  });

  group('theme', () {
    test('6 fields default to their Sass sources', () {
      const theme = SemiThemeData.light();
      final r = _resolve(theme);
      expect(
        r.spacingPinCodeSmallMarginRight,
        6,
        reason: r'$spacing-pinCode_small-marginRight: 6px',
      );
      expect(
        r.spacingPinCodeDefaultMarginRight,
        8,
        reason: r'$spacing-pinCode_default-marginRight: 8px',
      );
      expect(
        r.spacingPinCodeLargeMarginRight,
        12,
        reason: r'$spacing-pinCode_large-marginRight: 12px',
      );
      expect(
        r.widthPinCodeInputSmall,
        24,
        reason: r'$width-pinCode_input_small: 24px',
      );
      expect(
        r.widthPinCodeInputDefault,
        32,
        reason: r'$width-pinCode_input_default: 32px',
      );
      expect(
        r.widthPinCodeInputLarge,
        42,
        reason: r'$width-pinCode_input_large: 42px',
      );
    });

    test('copyWith overrides only the given fields', () {
      const base = SemiPinCodeThemeData();
      final updated = base.copyWith(widthPinCodeInputSmall: 50);
      expect(updated.widthPinCodeInputSmall, 50);
      expect(
        updated.spacingPinCodeSmallMarginRight,
        base.spacingPinCodeSmallMarginRight,
      );
    });

    test('merge keeps the original for null and lets the other win', () {
      const a = SemiPinCodeThemeData(widthPinCodeInputDefault: 100);
      const b = SemiPinCodeThemeData(
        widthPinCodeInputDefault: 200,
        spacingPinCodeDefaultMarginRight: 20,
      );
      expect(a.merge(null), a);
      expect(a.merge(b).widthPinCodeInputDefault, 200);
      expect(a.merge(b).spacingPinCodeDefaultMarginRight, 20);
    });

    test('equality and hashCode are value based', () {
      const a = SemiPinCodeThemeData(widthPinCodeInputLarge: 42);
      const b = SemiPinCodeThemeData(widthPinCodeInputLarge: 42);
      const c = SemiPinCodeThemeData(widthPinCodeInputLarge: 1);
      expect(a, b);
      expect(a.hashCode, b.hashCode);
      expect(a == c, isFalse);
    });

    test('every declaration and hardcode carries its provenance', () {
      final theme = File('lib/src/theme/semi_pincode_theme_data.dart')
          .readAsStringSync();
      final widget = File('lib/src/components/semi_pincode.dart')
          .readAsStringSync();
      // 6 themed declarations live in the theme source...
      for (final declaration in [
        r'$spacing-pinCode_small-marginRight: 6px',
        r'$spacing-pinCode_default-marginRight: 8px',
        r'$spacing-pinCode_large-marginRight: 12px',
        r'$width-pinCode_input_small: 24px',
        r'$width-pinCode_input_default: 32px',
        r'$width-pinCode_input_large: 42px',
      ]) {
        expect(theme, contains(declaration));
      }
      // ...the HARDCODES anchors live in the widget source (0 INTERNAL).
      for (final snippet in [
        'count: 6',
        r'numberReg = /^\d*$/',
        r'mixedReg = /^[0-9a-zA-Z]$/',
        'input { padding: 0; text-align: center; }',
      ]) {
        expect(widget, contains(snippet));
      }
    });

    testWidgets('a local patch applies (plain nesting)', (tester) async {
      await tester.pumpWidget(
        _app(
          SemiPinCodeTheme(
            data: const SemiPinCodeThemeData(
              widthPinCodeInputSmall: 50,
              spacingPinCodeSmallMarginRight: 4,
            ),
            child: const SemiPinCode(count: 3, size: SemiInputSize.small),
          ),
          width: 300,
        ),
      );
      expect(
        tester.getSize(find.byKey(SemiPinCode.cellKey(0))),
        const Size(50, 24),
      );
      expect(cellRect(tester, 1).left - cellRect(tester, 0).right, 4);
    });
  });
}
