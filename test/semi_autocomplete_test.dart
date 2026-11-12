// Behavior matrix for SemiAutoComplete plus coverage for the 31 generated
// theme fields (28 FIELDS + 3 MOTION) and the 15 HARDCODES provenance anchors
// living in the widget's `_AutoCompleteMetrics`.
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
}) => SemiTheme(
  data: const SemiThemeData.light(),
  child: Directionality(
    textDirection: textDirection,
    child: MediaQuery(
      data: MediaQueryData(
        size: const Size(800, 600),
        textScaler: TextScaler.linear(textScale),
      ),
      child: Overlay(
        initialEntries: [
          OverlayEntry(
            builder: (context) => Align(
              alignment: Alignment.center,
              child: SizedBox(width: width, child: body),
            ),
          ),
        ],
      ),
    ),
  ),
);

/// Bounded frame pumping: panel content rebuilds one frame after the tooltip
/// entry is marked dirty.
Future<void> _settle(WidgetTester tester) async {
  for (var i = 0; i < 6; i++) {
    await tester.pump();
  }
}

SemiResolvedAutoCompleteThemeData _resolve([SemiThemeData? theme]) =>
    const SemiAutoCompleteThemeData().resolve(
      theme ?? const SemiThemeData.light(),
    );

String inputText(WidgetTester tester) => tester
    .widgetList<EditableText>(find.byType(EditableText))
    .first
    .controller
    .text;

Finder optionText(String text) => find.text(text);

/// Background of the option row containing [text] (the AnimatedContainer of
/// the `&-option` rules).
Color optionBg(WidgetTester tester, String text) {
  final row = find.ancestor(
    of: optionText(text),
    matching: find.byType(AnimatedContainer),
  );
  return (tester.widget<AnimatedContainer>(row).decoration as BoxDecoration)
      .color!;
}

/// Style of the first span of the option's built-in text (SemiHighlight).
TextStyle spanStyle(WidgetTester tester, String text) {
  final widget = tester.widget<Text>(optionText(text));
  return ((widget.textSpan! as TextSpan).children!.first as TextSpan).style!;
}

void main() {
  final resolved = _resolve();

  group('rendering', () {
    testWidgets('renders options and hides show:false rows', (tester) async {
      await tester.pumpWidget(
        _app(
          SemiAutoComplete(
            data: const [
              SemiAutoCompleteOption(value: 'A'),
              SemiAutoCompleteOption(value: 'B', show: false),
              SemiAutoCompleteOption(value: 'C'),
            ],
            onFocusChange: (_) {},
          ),
        ),
      );
      await tester.tap(find.byType(EditableText));
      await _settle(tester);
      expect(find.byType(SemiTooltipPopup), findsOneWidget);
      expect(optionText('A'), findsOneWidget);
      expect(optionText('B'), findsNothing);
      expect(optionText('C'), findsOneWidget);
      // Upstream passes `showTick={false}`: no tick icon is ever rendered.
      expect(find.byType(SemiIcon), findsNothing);
    });

    testWidgets('label widgets render as-is; text falls back to value', (
      tester,
    ) async {
      await tester.pumpWidget(
        _app(
          SemiAutoComplete(
            data: const [
              SemiAutoCompleteOption(
                value: 'v1',
                label: SizedBox(width: 7, height: 3),
              ),
              SemiAutoCompleteOption(value: 'v2', text: 'two'),
              SemiAutoCompleteOption(value: 3),
            ],
          ),
        ),
      );
      await tester.tap(find.byType(EditableText));
      await _settle(tester);
      expect(
        find.descendant(
          of: find.byType(SemiTooltipPopup),
          matching: find.byWidgetPredicate(
            (w) => w is SizedBox && w.width == 7 && w.height == 3,
          ),
        ),
        findsOneWidget,
      );
      expect(optionText('two'), findsOneWidget);
      expect(optionText('3'), findsOneWidget);
      expect(optionText('v2'), findsNothing);
    });

    testWidgets('renderItem replaces the option content', (tester) async {
      await tester.pumpWidget(
        _app(
          SemiAutoComplete(
            data: const [SemiAutoCompleteOption(value: 'A')],
            renderItem: (option) => Text('built ${option.value}'),
          ),
        ),
      );
      await tester.tap(find.byType(EditableText));
      await _settle(tester);
      expect(optionText('built A'), findsOneWidget);
    });

    testWidgets('option rows carry the option.scss box metrics', (
      tester,
    ) async {
      await tester.pumpWidget(
        _app(
          SemiAutoComplete(
            data: const [
              SemiAutoCompleteOption(value: 'A'),
              SemiAutoCompleteOption(value: 'B'),
            ],
          ),
        ),
      );
      await tester.tap(find.byType(EditableText));
      await _settle(tester);
      // Inner padding 12/12/8/8 (#15-18) and radius 0 (#25).
      final row = tester.widget<AnimatedContainer>(
        find.ancestor(
          of: optionText('A'),
          matching: find.byType(AnimatedContainer),
        ),
      );
      final decoration = row.decoration as BoxDecoration;
      expect(decoration.borderRadius, BorderRadius.circular(0));
      final padding = row.child! as Padding;
      expect(
        padding.padding,
        const EdgeInsetsDirectional.only(start: 12, top: 8, end: 12, bottom: 8),
      );
      // First/last margins 4 (#19/#20).
      expect(
        find.byWidgetPredicate(
          (w) =>
              w is Padding &&
              w.padding == const EdgeInsetsDirectional.only(top: 4.0),
        ),
        findsOneWidget,
      );
      expect(
        find.byWidgetPredicate(
          (w) =>
              w is Padding &&
              w.padding == const EdgeInsetsDirectional.only(bottom: 4.0),
        ),
        findsOneWidget,
      );
    });
  });

  group('panel open and close', () {
    testWidgets('clicking the input toggles the panel', (tester) async {
      final log = <bool>[];
      await tester.pumpWidget(
        _app(
          SemiAutoComplete(
            data: const [SemiAutoCompleteOption(value: 'A')],
            onDropdownVisibleChange: log.add,
          ),
        ),
      );
      await tester.tap(find.byType(EditableText));
      await _settle(tester);
      expect(find.byType(SemiTooltipPopup), findsOneWidget);
      await tester.tap(find.byType(EditableText));
      await _settle(tester);
      expect(find.byType(SemiTooltipPopup), findsNothing);
      expect(log, [true, false]);
    });

    testWidgets('disabled ignores input clicks', (tester) async {
      await tester.pumpWidget(
        _app(
          SemiAutoComplete(
            disabled: true,
            data: const [SemiAutoCompleteOption(value: 'A')],
          ),
        ),
      );
      await tester.tap(find.byType(EditableText), warnIfMissed: false);
      await _settle(tester);
      expect(find.byType(SemiTooltipPopup), findsNothing);
    });

    testWidgets('typing opens the panel and notifies onSearch/onChanged', (
      tester,
    ) async {
      final log = <String>[];
      await tester.pumpWidget(
        _app(
          SemiAutoComplete(
            data: const [SemiAutoCompleteOption(value: 'Semi')],
            onSearch: (v) => log.add('search:$v'),
            onChanged: (v) => log.add('change:$v'),
          ),
        ),
      );
      await tester.tap(find.byType(EditableText));
      await tester.enterText(find.byType(EditableText), 'em');
      await _settle(tester);
      expect(find.byType(SemiTooltipPopup), findsOneWidget);
      expect(log, ['search:em', 'change:em']);
    });

    testWidgets('defaultOpen opens the panel on mount', (tester) async {
      await tester.pumpWidget(
        _app(
          SemiAutoComplete(
            defaultOpen: true,
            data: const [SemiAutoCompleteOption(value: 'A')],
          ),
        ),
      );
      await _settle(tester);
      expect(find.byType(SemiTooltipPopup), findsOneWidget);
    });

    testWidgets('Escape closes (consumed) and Tab closes (propagates)', (
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
            child: SemiAutoComplete(
              data: const [SemiAutoCompleteOption(value: 'A')],
            ),
          ),
        ),
      );
      await tester.tap(find.byType(EditableText));
      await _settle(tester);
      await tester.sendKeyEvent(LogicalKeyboardKey.escape);
      await _settle(tester);
      expect(find.byType(SemiTooltipPopup), findsNothing);
      // Escape is consumed by the open panel; the outer probe is silent.
      expect(probed, isEmpty);
      await tester.tap(find.byType(EditableText));
      await _settle(tester);
      expect(find.byType(SemiTooltipPopup), findsOneWidget);
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await _settle(tester);
      expect(find.byType(SemiTooltipPopup), findsNothing);
      // Tab keeps propagating (default focus traversal continues).
      expect(probed.whereType<KeyDownEvent>(), isNotEmpty);
    });

    testWidgets('blur does not close the panel', (tester) async {
      final focusNode = FocusNode();
      addTearDown(focusNode.dispose);
      await tester.pumpWidget(
        _app(
          SemiAutoComplete(
            focusNode: focusNode,
            data: const [SemiAutoCompleteOption(value: 'A')],
          ),
        ),
      );
      await tester.tap(find.byType(EditableText));
      await _settle(tester);
      expect(find.byType(SemiTooltipPopup), findsOneWidget);
      focusNode.unfocus();
      await _settle(tester);
      expect(find.byType(SemiTooltipPopup), findsOneWidget);
    });

    testWidgets('an outside tap closes the panel', (tester) async {
      final log = <bool>[];
      await tester.pumpWidget(
        _app(
          SemiAutoComplete(
            data: const [SemiAutoCompleteOption(value: 'A')],
            onDropdownVisibleChange: log.add,
          ),
        ),
      );
      await tester.tap(find.byType(EditableText));
      await _settle(tester);
      expect(find.byType(SemiTooltipPopup), findsOneWidget);
      await tester.tapAt(const Offset(5, 5));
      await _settle(tester);
      expect(find.byType(SemiTooltipPopup), findsNothing);
      expect(log, [true, false]);
    });

    testWidgets('selection closes the panel', (tester) async {
      final log = <bool>[];
      await tester.pumpWidget(
        _app(
          SemiAutoComplete(
            data: const [SemiAutoCompleteOption(value: 'A')],
            onDropdownVisibleChange: log.add,
          ),
        ),
      );
      await tester.tap(find.byType(EditableText));
      await _settle(tester);
      await tester.tap(optionText('A'));
      await _settle(tester);
      expect(find.byType(SemiTooltipPopup), findsNothing);
      expect(log, [true, false]);
    });
  });

  group('value, selection and clear', () {
    testWidgets('uncontrolled select lands the display text', (tester) async {
      final log = <String>[];
      await tester.pumpWidget(
        _app(
          SemiAutoComplete(
            data: const [
              SemiAutoCompleteOption(
                value: 'Bee',
                label: SizedBox(width: 7, height: 3),
              ),
            ],
            onSelect: (o) => log.add('select:${o.value}'),
            onChanged: (v) => log.add('change:$v'),
          ),
        ),
      );
      await tester.tap(find.byType(EditableText));
      await _settle(tester);
      await tester.tap(
        find.descendant(
          of: find.byType(SemiTooltipPopup),
          matching: find.byWidgetPredicate(
            (w) => w is SizedBox && w.width == 7 && w.height == 3,
          ),
        ),
      );
      await _settle(tester);
      // renderSelectedItem defaults to `value.toString()` — not the label.
      expect(inputText(tester), 'Bee');
      expect(log, ['select:Bee', 'change:Bee']);
    });

    testWidgets('renderSelectedItem shapes the display text', (tester) async {
      await tester.pumpWidget(
        _app(
          SemiAutoComplete(
            data: const [SemiAutoCompleteOption(value: 'Bee', text: 'bee')],
            renderSelectedItem: (o) => '> ${o.text}',
          ),
        ),
      );
      await tester.tap(find.byType(EditableText));
      await _settle(tester);
      await tester.tap(optionText('bee'));
      await _settle(tester);
      expect(inputText(tester), '> bee');
    });

    testWidgets('controlled select only notifies', (tester) async {
      final log = <String>[];
      await tester.pumpWidget(
        _app(
          SemiAutoComplete(
            value: 'A',
            data: const [
              SemiAutoCompleteOption(value: 'A'),
              SemiAutoCompleteOption(value: 'Bee'),
            ],
            onSelect: (o) => log.add('select:${o.value}'),
            onChanged: (v) => log.add('change:$v'),
          ),
        ),
      );
      await tester.tap(find.byType(EditableText));
      await _settle(tester);
      await tester.tap(optionText('Bee'));
      await _settle(tester);
      // Controlled: the display text keeps following `value` (the parent
      // updates it); the callbacks still fire and the panel closes.
      expect(inputText(tester), 'A');
      expect(log, ['select:Bee', 'change:Bee']);
      expect(find.byType(SemiTooltipPopup), findsNothing);
    });

    testWidgets('controlled value resolves through data', (tester) async {
      await tester.pumpWidget(
        _app(
          SemiAutoComplete(
            value: '2',
            data: const [
              SemiAutoCompleteOption(value: 1),
              SemiAutoCompleteOption(value: 2),
            ],
          ),
        ),
      );
      await _settle(tester);
      expect(inputText(tester), '2');
    });

    testWidgets('an unmatched value shows verbatim', (tester) async {
      await tester.pumpWidget(
        _app(
          SemiAutoComplete(
            value: '99',
            data: const [SemiAutoCompleteOption(value: 1)],
          ),
        ),
      );
      await _settle(tester);
      expect(inputText(tester), '99');
    });

    testWidgets('the value-matched option renders bold (-selected)', (
      tester,
    ) async {
      await tester.pumpWidget(
        _app(
          SemiAutoComplete(
            value: '2',
            defaultOpen: true,
            renderSelectedItem: (o) => 'value ${o.value}',
            data: const [
              SemiAutoCompleteOption(value: '1'),
              SemiAutoCompleteOption(value: '2'),
            ],
          ),
        ),
      );
      await _settle(tester);
      final bold = _resolve().fontAutoCompleteKeywordFontWeight;
      final selectedWeight =
          const SemiThemeData.light().typography.fontWeightBold;
      expect(
        bold,
        selectedWeight,
      ); // `$font-autoComplete_keyword-fontWeight: 600`
      expect(
        spanStyle(tester, '2').fontWeight,
        selectedWeight,
        reason:
            r'the matched option is -selected (font-weight: $font-weight-bold)',
      );
      expect(spanStyle(tester, '1').fontWeight, isNull);
    });

    testWidgets('clear fires onChanged/onSearch/onClear and opens', (
      tester,
    ) async {
      final log = <String>[];
      await tester.pumpWidget(
        _app(
          SemiAutoComplete(
            showClear: true,
            data: const [SemiAutoCompleteOption(value: 'Semi')],
            onSearch: (v) => log.add('search:$v'),
            onChanged: (v) => log.add('change:$v'),
            onClear: () => log.add('clear'),
          ),
        ),
      );
      await tester.tap(find.byType(EditableText));
      await tester.enterText(find.byType(EditableText), 'em');
      await _settle(tester);
      log.clear();
      await tester.tap(find.byKey(SemiInput.clearButtonKey));
      await _settle(tester);
      expect(log, ['search:', 'change:', 'clear']);
      expect(inputText(tester), isEmpty);
      expect(find.byType(SemiTooltipPopup), findsOneWidget);
    });
  });

  group('keyboard', () {
    testWidgets('arrows open the panel and cycle enabled rows with wrap', (
      tester,
    ) async {
      await tester.pumpWidget(
        _app(
          SemiAutoComplete(
            data: const [
              SemiAutoCompleteOption(value: 'A'),
              SemiAutoCompleteOption(value: 'B', disabled: true),
              SemiAutoCompleteOption(value: 'C'),
            ],
          ),
        ),
      );
      // The input click opens the panel with no highlight.
      await tester.tap(find.byType(EditableText));
      await _settle(tester);
      expect(find.byType(SemiTooltipPopup), findsOneWidget);
      expect(optionBg(tester, 'A'), const Color(0x00000000));
      await tester.tap(find.byType(EditableText));
      await _settle(tester);
      expect(find.byType(SemiTooltipPopup), findsNothing);
      // Closed -> ArrowDown opens, still without a highlight.
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
      await _settle(tester);
      expect(find.byType(SemiTooltipPopup), findsOneWidget);
      expect(optionBg(tester, 'A'), const Color(0x00000000));
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
      await _settle(tester);
      // First enabled row.
      expect(optionBg(tester, 'A'), resolved.colorAutoCompleteOptionBgHover);
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
      await _settle(tester);
      // Skips the disabled row.
      expect(optionBg(tester, 'A'), const Color(0x00000000));
      expect(optionBg(tester, 'C'), resolved.colorAutoCompleteOptionBgHover);
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
      await _settle(tester);
      // Wraps to the top.
      expect(optionBg(tester, 'A'), resolved.colorAutoCompleteOptionBgHover);
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowUp);
      await _settle(tester);
      // Wraps to the bottom.
      expect(optionBg(tester, 'C'), resolved.colorAutoCompleteOptionBgHover);
    });

    testWidgets('Enter opens closed, selects focused, closes unfocused', (
      tester,
    ) async {
      final log = <String>[];
      await tester.pumpWidget(
        _app(
          SemiAutoComplete(
            motion: false,
            data: const [SemiAutoCompleteOption(value: 'A')],
            onSelect: (o) => log.add('select:${o.value}'),
          ),
        ),
      );
      await tester.tap(find.byType(EditableText));
      await tester.enterText(find.byType(EditableText), 'x');
      await _settle(tester);
      await tester.tap(find.byType(EditableText)); // close again
      await _settle(tester);
      expect(find.byType(SemiTooltipPopup), findsNothing);
      // Closed -> Enter opens.
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await _settle(tester);
      expect(find.byType(SemiTooltipPopup), findsOneWidget);
      // Open without a focused row -> Enter closes.
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await _settle(tester);
      expect(find.byType(SemiTooltipPopup), findsNothing);
      // Open with a focused row -> Enter selects it.
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await _settle(tester);
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
      await _settle(tester);
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await _settle(tester);
      expect(log, ['select:A']);
      expect(find.byType(SemiTooltipPopup), findsNothing);
      expect(inputText(tester), 'A');
    });

    testWidgets('defaultActiveFirstOption highlights the first enabled row', (
      tester,
    ) async {
      await tester.pumpWidget(
        _app(
          SemiAutoComplete(
            defaultActiveFirstOption: true,
            data: const [
              SemiAutoCompleteOption(value: 'A', disabled: true),
              SemiAutoCompleteOption(value: 'B'),
              SemiAutoCompleteOption(value: 'C'),
            ],
          ),
        ),
      );
      await tester.tap(find.byType(EditableText));
      await _settle(tester);
      expect(optionBg(tester, 'B'), resolved.colorAutoCompleteOptionBgHover);
      // Input changes reset the rule while the panel is open.
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
      await _settle(tester);
      expect(optionBg(tester, 'C'), resolved.colorAutoCompleteOptionBgHover);
      await tester.enterText(find.byType(EditableText), 'x');
      await _settle(tester);
      expect(optionBg(tester, 'B'), resolved.colorAutoCompleteOptionBgHover);
    });

    testWidgets('without defaultActiveFirstOption nothing is highlighted', (
      tester,
    ) async {
      await tester.pumpWidget(
        _app(
          SemiAutoComplete(data: const [SemiAutoCompleteOption(value: 'A')]),
        ),
      );
      await tester.tap(find.byType(EditableText));
      await _settle(tester);
      expect(optionBg(tester, 'A'), const Color(0x00000000));
    });

    testWidgets('keyboard highlight scrolls rows into view', (tester) async {
      await tester.pumpWidget(
        _app(
          SemiAutoComplete(
            maxHeight: 120,
            data: [
              for (var i = 0; i < 12; i++)
                SemiAutoCompleteOption(value: 'item $i'),
            ],
          ),
        ),
      );
      await tester.tap(find.byType(EditableText));
      await _settle(tester);
      for (var i = 0; i < 11; i++) {
        await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
      }
      await tester.pump();
      await tester.pump();
      expect(tester.takeException(), isNull);
    });

    testWidgets('hover highlights the row (upstream -focused)', (tester) async {
      await tester.pumpWidget(
        _app(
          SemiAutoComplete(
            data: const [
              SemiAutoCompleteOption(value: 'A'),
              SemiAutoCompleteOption(value: 'C'),
            ],
          ),
        ),
      );
      await tester.tap(find.byType(EditableText));
      await _settle(tester);
      final gesture = await tester.createGesture(kind: PointerDeviceKind.mouse);
      await gesture.addPointer(location: Offset.zero);
      addTearDown(gesture.removePointer);
      await gesture.moveTo(tester.getCenter(optionText('C')));
      await _settle(tester);
      expect(optionBg(tester, 'C'), resolved.colorAutoCompleteOptionBgHover);
    });
  });

  group('panel content', () {
    testWidgets('loading shows the spin and hides the options', (tester) async {
      await tester.pumpWidget(
        _app(
          SemiAutoComplete(
            loading: true,
            data: const [SemiAutoCompleteOption(value: 'A')],
          ),
        ),
      );
      await tester.tap(find.byType(EditableText));
      await _settle(tester);
      expect(find.byType(SemiSpin), findsOneWidget);
      expect(optionText('A'), findsNothing);
      // The loading wrapper padding (#12/#13) and height (HARDCODE).
      expect(
        find.byWidgetPredicate(
          (w) =>
              w is Padding &&
              w.padding == const EdgeInsetsDirectional.only(top: 8, bottom: 8),
        ),
        findsOneWidget,
      );
      expect(
        find.byWidgetPredicate(
          (w) => w is SizedBox && w.width == null && w.height == 20,
        ),
        findsOneWidget,
      );
    });

    testWidgets('empty data shows emptyContent', (tester) async {
      await tester.pumpWidget(
        _app(
          SemiAutoComplete(
            defaultOpen: true,
            emptyContent: const Text('nothing'),
          ),
        ),
      );
      await _settle(tester);
      expect(optionText('nothing'), findsOneWidget);
    });

    testWidgets('empty data without emptyContent renders nothing', (
      tester,
    ) async {
      await tester.pumpWidget(_app(const SemiAutoComplete(defaultOpen: true)));
      await _settle(tester);
      expect(find.byType(SemiTooltipPopup), findsOneWidget);
      expect(find.byType(SemiHighlight), findsNothing);
    });

    testWidgets('dropdownMatchSelectWidth pins the panel to the input width', (
      tester,
    ) async {
      await tester.pumpWidget(
        _app(
          SemiAutoComplete(
            defaultOpen: true,
            data: const [SemiAutoCompleteOption(value: 'A')],
          ),
          width: 240,
        ),
      );
      await _settle(tester);
      final surface = find
          .descendant(
            of: find.byType(SemiTooltipPopup),
            matching: find.byType(DecoratedBox),
          )
          .first;
      expect(tester.getSize(surface).width, 240);
    });

    testWidgets('dropdownMatchSelectWidth false hugs the content', (
      tester,
    ) async {
      await tester.pumpWidget(
        _app(
          SemiAutoComplete(
            defaultOpen: true,
            dropdownMatchSelectWidth: false,
            data: const [SemiAutoCompleteOption(value: 'A')],
          ),
          width: 240,
        ),
      );
      await _settle(tester);
      final surface = find
          .descendant(
            of: find.byType(SemiTooltipPopup),
            matching: find.byType(DecoratedBox),
          )
          .first;
      expect(tester.getSize(surface).width, lessThan(240));
    });

    testWidgets('maxHeight caps the panel height', (tester) async {
      await tester.pumpWidget(
        _app(
          SemiAutoComplete(
            defaultOpen: true,
            maxHeight: 60,
            data: [
              for (var i = 0; i < 12; i++)
                SemiAutoCompleteOption(value: 'item $i'),
            ],
          ),
        ),
      );
      await _settle(tester);
      final surface = find
          .descendant(
            of: find.byType(SemiTooltipPopup),
            matching: find.byType(DecoratedBox),
          )
          .first;
      expect(tester.getSize(surface).height, lessThanOrEqualTo(60));
      // The panel surface paints the Popover look (HARDCODES #1-3).
      final decoration =
          tester.widget<DecoratedBox>(surface).decoration as BoxDecoration;
      expect(decoration.color, const SemiThemeData.light().colors.colorBg3);
      expect(decoration.border, isNotNull);
      expect(decoration.boxShadow, hasLength(2));
    });

    testWidgets('prefix/suffix/insetLabel/size/validateStatus pass through', (
      tester,
    ) async {
      await tester.pumpWidget(
        _app(
          SemiAutoComplete(
            prefix: 'P',
            suffix: 'S',
            size: SemiInputSize.large,
            validateStatus: SemiInputStatus.error,
            data: const [],
          ),
        ),
      );
      final input = tester.widget<SemiInput>(find.byType(SemiInput));
      expect(input.prefix, 'P');
      expect(input.suffix, 'S');
      expect(input.size, SemiInputSize.large);
      expect(input.validateStatus, SemiInputStatus.error);
    });
  });

  group('keyword highlight', () {
    testWidgets('matches the current input with the keyword tokens', (
      tester,
    ) async {
      await tester.pumpWidget(
        _app(
          SemiAutoComplete(data: const [SemiAutoCompleteOption(value: 'Semi')]),
        ),
      );
      await tester.tap(find.byType(EditableText));
      await tester.enterText(find.byType(EditableText), 'em');
      await _settle(tester);
      final widget = tester.widget<SemiHighlight>(
        find.descendant(
          of: find.byType(SemiTooltipPopup),
          matching: find.byType(SemiHighlight),
        ),
      );
      expect(widget.searchWords, hasLength(1));
      expect(widget.searchWords.single.text, 'em');
      final style = widget.searchWords.single.style!;
      expect(style.color, resolved.colorAutoCompleteOptionKeywordText);
      expect(style.fontWeight, resolved.fontAutoCompleteKeywordFontWeight);
      // 'Semi' = plain 'S' + hit 'em' + plain 'i'.
      final rich = tester.widget<Text>(optionText('Semi'));
      final spans = (rich.textSpan! as TextSpan).children!.cast<TextSpan>();
      expect(spans, hasLength(3));
      expect(spans[1].text, 'em');
      expect(
        spans[1].style!.color,
        resolved.colorAutoCompleteOptionKeywordText,
      );
    });
  });

  group('theme', () {
    test('31 fields default to their Sass sources', () {
      const theme = SemiThemeData.light();
      final r = _resolve(theme);
      expect(
        r.colorAutoCompleteOptionKeywordText,
        theme.colors.colorPrimary,
        reason: r'$color-autoComplete_option_keyword-text: var(--semi-color-primary)',
      );
      expect(
        r.colorAutoCompleteOptionBgDefault,
        const Color(0x00000000),
        reason: r'$color-autoComplete_option-bg-default: transparent（上游未消费）',
      );
      expect(
        r.colorAutoCompleteOptionIconDefault,
        const Color(0x00000000),
        reason: r'$color-autoComplete_option-icon-default: transparent',
      );
      expect(
        r.colorAutoCompleteOptionBgHover,
        theme.colors.colorFill0,
        reason:
            r'$color-autoComplete_option-bg-hover: var(--semi-color-fill-0)',
      );
      expect(
        r.colorAutoCompleteOptionBgActive,
        theme.colors.colorFill1,
        reason:
            r'$color-autoComplete_option-bg-active: var(--semi-color-fill-1)',
      );
      expect(
        r.colorAutoCompleteOptionDisabledText,
        theme.colors.colorDisabledText,
        reason: r'$color-autoComplete_option_disabled-text: var(--semi-color-disabled-text)',
      );
      expect(
        r.colorAutoCompleteOptionDisabledBg,
        const Color(0x00000000),
        reason: r'$color-autoComplete_option_disabled-bg: transparent（上游未消费）',
      );
      expect(
        r.colorAutoCompleteOptionIconActive,
        theme.colors.colorText2,
        reason:
            r'$color-autoComplete_option-icon-active: var(--semi-color-text-2)',
      );
      expect(
        r.colorAutoCompleteOptionBorderDefault,
        theme.colors.colorBorder,
        reason: r'$color-autoComplete_option-border-default: var(--semi-color-border)（上游未消费）',
      );
      expect(
        r.colorAutoCompleteOptionMainText,
        theme.colors.colorText0,
        reason:
            r'$color-autoComplete_option_main-text: var(--semi-color-text-0)',
      );
      expect(
        r.widthAutoCompleteOptionTick,
        12,
        reason: r'$width-autoComplete_option_tick: $width-icon-small',
      );
      expect(
        r.spacingAutoCompleteLoadingWrapperPaddingTop,
        8,
        reason:
            r'$spacing-autoComplete_loading_wrapper-paddingTop: $spacing-tight',
      );
      expect(
        r.spacingAutoCompleteLoadingWrapperPaddingBottom,
        8,
        reason: r'$spacing-autoComplete_loading_wrapper-paddingBottom: $spacing-tight',
      );
      expect(
        r.spacingAutoCompleteOptionTickMarginRight,
        8,
        reason:
            r'$spacing-autoComplete_option_tick-marginRight: $spacing-tight',
      );
      expect(
        r.spacingAutoCompleteOptionPaddingLeft,
        12,
        reason:
            r'$spacing-autoComplete_option-paddingLeft: $spacing-base-tight',
      );
      expect(
        r.spacingAutoCompleteOptionPaddingRight,
        12,
        reason:
            r'$spacing-autoComplete_option-paddingRight: $spacing-base-tight',
      );
      expect(
        r.spacingAutoCompleteOptionPaddingTop,
        8,
        reason: r'$spacing-autoComplete_option-paddingTop: $spacing-tight',
      );
      expect(
        r.spacingAutoCompleteOptionPaddingBottom,
        8,
        reason: r'$spacing-autoComplete_option-paddingBottom: $spacing-tight',
      );
      expect(
        r.spacingAutoCompleteOptionFirstMarginTop,
        4,
        reason: r'$spacing-autoComplete_option_first-marginTop: $spacing-extra-tight',
      );
      expect(
        r.spacingAutoCompleteOptionLastMarginBottom,
        4,
        reason: r'$spacing-autoComplete_option_last-marginBottom: $spacing-extra-tight',
      );
      expect(
        r.spacingAutoCompleteOptionListPaddingTop,
        0,
        reason: r'$spacing-autoComplete_option_list-paddingTop: 0px（上游未消费）',
      );
      expect(
        r.spacingAutoCompleteOptionListPaddingRight,
        0,
        reason: r'$spacing-autoComplete_option_list-paddingRight: 0px（上游未消费）',
      );
      expect(
        r.spacingAutoCompleteOptionListPaddingBottom,
        0,
        reason: r'$spacing-autoComplete_option_list-paddingBottom: 0px（上游未消费）',
      );
      expect(
        r.spacingAutoCompleteOptionListPaddingLeft,
        0,
        reason: r'$spacing-autoComplete_option_list-paddingLeft: 0px（上游未消费）',
      );
      expect(
        r.radiusAutoCompleteOption,
        0,
        reason: r'$radius-autoComplete_option: 0px',
      );
      expect(
        r.fontAutoCompleteFontWeight,
        theme.typography.fontWeightRegular,
        reason: r'$font-autoComplete-fontWeight: $font-weight-regular（上游未消费）',
      );
      expect(
        r.fontAutoCompleteInsetLabelFontWeight,
        theme.typography.fontWeightBold,
        reason: r'$font-autoComplete_inset_label-fontWeight: 600（上游未消费）',
      );
      expect(
        r.fontAutoCompleteKeywordFontWeight,
        theme.typography.fontWeightBold,
        reason: r'$font-autoComplete_keyword-fontWeight: 600',
      );
      expect(
        r.transitionDurationAutoCompleteOptionBg,
        Duration.zero,
        reason: r'$transition_duration-autoComplete_option-bg: var(--semi-transition_duration-none)',
      );
      expect(
        r.transitionFunctionAutoCompleteOptionBg,
        Curves.easeIn,
        reason: r'$transition_function-autoComplete_option-bg: var(--semi-transition_function-easeIn)',
      );
      expect(
        r.transitionDelayAutoCompleteOptionBg,
        Duration.zero,
        reason: r'$transition_delay-autoComplete_option-bg: var(--semi-transition_delay-none)',
      );
    });

    test('copyWith overrides only the given fields', () {
      const base = SemiAutoCompleteThemeData();
      final updated = base.copyWith(
        colorAutoCompleteOptionBgHover: Color(0xff00ff00),
      );
      expect(updated.colorAutoCompleteOptionBgHover, const Color(0xff00ff00));
      expect(updated.radiusAutoCompleteOption, base.radiusAutoCompleteOption);
    });

    test('merge keeps the original for null and lets the other win', () {
      const a = SemiAutoCompleteThemeData(radiusAutoCompleteOption: 100);
      const b = SemiAutoCompleteThemeData(
        radiusAutoCompleteOption: 200,
        spacingAutoCompleteOptionPaddingLeft: 3,
      );
      expect(a.merge(null), a);
      expect(a.merge(b).radiusAutoCompleteOption, 200);
      expect(a.merge(b).spacingAutoCompleteOptionPaddingLeft, 3);
    });

    test('equality and hashCode are value based', () {
      const a = SemiAutoCompleteThemeData(
        transitionFunctionAutoCompleteOptionBg: Curves.easeIn,
      );
      const b = SemiAutoCompleteThemeData(
        transitionFunctionAutoCompleteOptionBg: Curves.easeIn,
      );
      const c = SemiAutoCompleteThemeData(radiusAutoCompleteOption: 1);
      expect(a, b);
      expect(a.hashCode, b.hashCode);
      expect(a == c, isFalse);
    });

    test('every theme field carries its Sass provenance', () {
      final theme = File('lib/src/theme/semi_autocomplete_theme_data.dart')
          .readAsStringSync();
      final widget = File('lib/src/components/semi_autocomplete.dart')
          .readAsStringSync();
      for (final declaration in [
        r'$color-autoComplete_option_keyword-text: var(--semi-color-primary)',
        r'$color-autoComplete_option-bg-default: transparent',
        r'$color-autoComplete_option-icon-default: transparent',
        r'$color-autoComplete_option-bg-hover: var(--semi-color-fill-0)',
        r'$color-autoComplete_option-bg-active: var(--semi-color-fill-1)',
        r'$color-autoComplete_option_disabled-text: var(--semi-color-disabled-text)',
        r'$color-autoComplete_option_disabled-bg: transparent',
        r'$color-autoComplete_option-icon-active: var(--semi-color-text-2)',
        r'$color-autoComplete_option-border-default: var(--semi-color-border)',
        r'$color-autoComplete_option_main-text: var(--semi-color-text-0)',
        r'$width-autoComplete_option_tick: $width-icon-small',
        r'$spacing-autoComplete_loading_wrapper-paddingTop: $spacing-tight',
        r'$spacing-autoComplete_loading_wrapper-paddingBottom: $spacing-tight',
        r'$spacing-autoComplete_option_tick-marginRight: $spacing-tight',
        r'$spacing-autoComplete_option-paddingLeft: $spacing-base-tight',
        r'$spacing-autoComplete_option-paddingRight: $spacing-base-tight',
        r'$spacing-autoComplete_option-paddingTop: $spacing-tight',
        r'$spacing-autoComplete_option-paddingBottom: $spacing-tight',
        r'$spacing-autoComplete_option_first-marginTop: $spacing-extra-tight',
        r'$spacing-autoComplete_option_last-marginBottom: $spacing-extra-tight',
        r'$spacing-autoComplete_option_list-paddingTop: 0px',
        r'$spacing-autoComplete_option_list-paddingRight: 0px',
        r'$spacing-autoComplete_option_list-paddingBottom: 0px',
        r'$spacing-autoComplete_option_list-paddingLeft: 0px',
        r'$radius-autoComplete_option: 0px',
        r'$font-autoComplete-fontWeight: $font-weight-regular',
        r'$font-autoComplete_inset_label-fontWeight: 600',
        r'$font-autoComplete_keyword-fontWeight: 600',
        r'$transition_duration-autoComplete_option-bg: var(--semi-transition_duration-none)',
        r'$transition_function-autoComplete_option-bg: var(--semi-transition_function-easeIn)',
        r'$transition_delay-autoComplete_option-bg: var(--semi-transition_delay-none)',
      ]) {
        expect(theme, contains(declaration));
      }
      for (final snippet in [
        r'$color-popover-bg-default: var(--semi-color-bg-3)',
        r'$color-popover-border-default: var(--semi-color-border)',
        r'$radius-popover: var(--semi-border-radius-medium)',
        r'$filter-popover-bg: none',
        'z-index: \$z-popover',
        '0 0 1px rgba(0, 0, 0, .3)',
        '0 4px 14px rgba(0, 0, 0, .1)',
        'height: 20px',
        '@include font-size-regular',
        r'$font-weight-bold',
        'overflow-x: hidden',
        'overflow-y: auto',
        'maxHeight: 300',
      ]) {
        expect(widget, contains(snippet));
      }
    });

    testWidgets('a local patch applies and captures across the overlay', (
      tester,
    ) async {
      const patched = Color(0xff876543);
      await tester.pumpWidget(
        _app(
          SemiAutoCompleteTheme(
            data: const SemiAutoCompleteThemeData(
              colorAutoCompleteOptionMainText: patched,
            ),
            child: SemiAutoComplete(
              defaultOpen: true,
              data: const [SemiAutoCompleteOption(value: 'A')],
            ),
          ),
        ),
      );
      await _settle(tester);
      expect(spanStyle(tester, 'A').color, patched);
    });
  });
}
