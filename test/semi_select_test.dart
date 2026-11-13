// Behavior matrix for SemiSelect plus coverage for the 113 generated theme
// fields (104 FIELDS + 9 MOTION) and the 2 INTERNAL / 7 HARDCODES provenance
// anchors living in the widget's `_SelectMetrics`.
import 'dart:io';

import 'package:flutter/gestures.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:semi_design_flutter/semi_design_flutter.dart';

/// The overlay entry body is served through a notifier: `initialEntries`
/// closures capture their arguments once, and the harness re-pumps the same
/// tree in several tests (state must survive the swap).
final _body = ValueNotifier<Widget>(const SizedBox.shrink());

Widget _app(Widget body, {TextDirection textDirection = TextDirection.ltr}) {
  _body.value = body;
  return SemiTheme(
    data: const SemiThemeData.light(),
    child: Directionality(
      textDirection: textDirection,
      child: MediaQuery(
        data: const MediaQueryData(size: Size(800, 600)),
        child: Overlay(
          initialEntries: [
            OverlayEntry(
              builder: (context) => ValueListenableBuilder<Widget>(
                valueListenable: _body,
                builder: (context, body, _) => Align(
                  alignment: Alignment.center,
                  child: SizedBox(width: 240, child: body),
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

/// Bounded frame pumping: panel content rebuilds one frame after the tooltip
/// entry is marked dirty; focus callbacks land post-frame.
Future<void> _settle(WidgetTester tester) async {
  for (var i = 0; i < 6; i++) {
    await tester.pump();
  }
}

SemiResolvedSelectThemeData _resolve([SemiThemeData? theme]) =>
    const SemiSelectThemeData().resolve(theme ?? const SemiThemeData.light());

/// Text inside the dropdown panel only (the trigger may mirror it).
Finder panelText(String text) => find.descendant(
  of: find.byType(SemiTooltipPopup),
  matching: find.text(text),
);

/// The trigger text/placeholder (outside the panel).
Finder triggerText(String text) =>
    find.descendant(of: find.byType(SemiSelect), matching: find.text(text));

/// Background of the option row containing [text] (the AnimatedContainer of
/// the `&-option` rules).
Color optionBg(WidgetTester tester, String text) {
  final row = find.ancestor(
    of: panelText(text),
    matching: find.byType(AnimatedContainer),
  );
  return (tester.widget<AnimatedContainer>(row).decoration as BoxDecoration)
      .color!;
}

/// Style of the first span of the option's built-in text (SemiHighlight).
TextStyle spanStyle(WidgetTester tester, String text) {
  final widget = tester.widget<Text>(panelText(text));
  return ((widget.textSpan! as TextSpan).children!.first as TextSpan).style!;
}

String inputText(WidgetTester tester) =>
    tester.widget<EditableText>(find.byType(EditableText)).controller.text;

/// Enter through the SemiInput `onEnterPress` channel (the autocomplete
/// precedent: the search input consumes Enter, never the key handler).
Future<void> _enter(WidgetTester tester) async {
  await tester.testTextInput.receiveAction(TextInputAction.done);
  await _settle(tester);
}

const _flatOptions = [
  SemiSelectOption(value: 'a', label: 'A'),
  SemiSelectOption(value: 'b', label: 'B', disabled: true),
  SemiSelectOption(value: 'c', label: 'C'),
];

void main() {
  final resolved = _resolve();

  group('single selection', () {
    testWidgets('tap option selects, notifies and closes the panel', (
      tester,
    ) async {
      final log = <String>[];
      await tester.pumpWidget(
        _app(
          SemiSelect(
            placeholder: 'pick',
            options: _flatOptions,
            onChanged: (v) => log.add('change:$v'),
            onSelect: (v, o) => log.add('select:$v'),
            onDropdownVisibleChange: (v) => log.add('visible:$v'),
          ),
        ),
      );
      await tester.tap(triggerText('pick'));
      await _settle(tester);
      expect(find.byType(SemiTooltipPopup), findsOneWidget);
      await tester.tap(panelText('C'));
      await _settle(tester);
      expect(log, ['visible:true', 'select:c', 'change:c', 'visible:false']);
      expect(find.byType(SemiTooltipPopup), findsNothing);
      expect(triggerText('C'), findsOneWidget);
    });

    testWidgets('unselected rows carry no tick icon at all', (tester) async {
      await tester.pumpWidget(
        _app(
          SemiSelect(value: 'a', placeholder: 'pick', options: _flatOptions),
        ),
      );
      await tester.tap(triggerText('A'));
      await _settle(tester);
      // Upstream hides the resting tick with a transparent colour; the port
      // omits the icon outright so it can never ghost through renderers that
      // ignore transparent currentColor (regression: every row showed a tick).
      final ticks = find.descendant(
        of: find.byType(SemiTooltipPopup),
        matching: find.byWidgetPredicate(
          (w) => w is SemiIcon && w.data == SemiIcons.tick,
        ),
      );
      expect(ticks, findsOneWidget);
    });

    testWidgets('renderSelectedItem replaces the display text', (tester) async {
      await tester.pumpWidget(
        _app(
          SemiSelect(
            value: 'a',
            options: _flatOptions,
            renderSelectedItem: (o) => Text('sel:${o.value}'),
          ),
        ),
      );
      expect(triggerText('sel:a'), findsOneWidget);
    });

    testWidgets('value outside the list renders a clearable placeholder', (
      tester,
    ) async {
      final log = <String>[];
      await tester.pumpWidget(
        _app(
          SemiSelect(
            defaultValue: 'zzz',
            showClear: true,
            options: _flatOptions,
            onChanged: (v) => log.add('change:$v'),
            onClear: () => log.add('clear'),
          ),
        ),
      );
      // `{value, label: value.toString()}` placeholder, never in the list.
      expect(triggerText('zzz'), findsOneWidget);
      await tester.tap(triggerText('zzz'));
      await _settle(tester);
      expect(panelText('zzz'), findsNothing);
      expect(panelText('A'), findsOneWidget);
      await tester.sendKeyEvent(LogicalKeyboardKey.escape);
      await _settle(tester);
      // Upstream: the clear button replaces the arrow only while the
      // pointer hovers (or the panel is open); at rest the arrow shows.
      expect(find.byKey(SemiSelect.clearButtonKey), findsNothing);
      expect(
        find.descendant(
          of: find.byType(SemiSelect),
          matching: find.byWidgetPredicate(
            (w) => w is SemiIcon && w.data == SemiIcons.chevronDown,
          ),
        ),
        findsOneWidget,
      );
      final hover = await tester.createGesture(kind: PointerDeviceKind.mouse);
      await hover.addPointer(
        location: tester.getCenter(find.byType(SemiSelect)),
      );
      await tester.pump();
      // Hovering swaps the arrow for the clear button (same slot).
      expect(find.byKey(SemiSelect.clearButtonKey), findsOneWidget);
      expect(
        find.descendant(
          of: find.byType(SemiSelect),
          matching: find.byWidgetPredicate(
            (w) => w is SemiIcon && w.data == SemiIcons.chevronDown,
          ),
        ),
        findsNothing,
      );
      // Upstream renders the clear glyph at 1em of the trigger (14 here).
      final clearTheme = tester.widget<SemiIconTheme>(
        find
            .descendant(
              of: find.byKey(SemiSelect.clearButtonKey),
              matching: find.byType(SemiIconTheme),
            )
            .first,
      );
      expect(clearTheme.data.customSize, 14);
      await tester.tap(find.byKey(SemiSelect.clearButtonKey));
      await _settle(tester);
      await hover.removePointer();
      await tester.pump();
      expect(log, ['change:null', 'clear']);
      expect(triggerText('zzz'), findsNothing);
    });

    testWidgets('onChanged is diff-gated: re-selecting the same value is '
        'silent', (tester) async {
      final log = <String>[];
      await tester.pumpWidget(
        _app(
          SemiSelect(
            placeholder: 'pick',
            options: _flatOptions,
            onChanged: (v) => log.add('change:$v'),
            onSelect: (v, _) => log.add('select:$v'),
          ),
        ),
      );
      await tester.tap(triggerText('pick'));
      await _settle(tester);
      await tester.tap(panelText('A'));
      await _settle(tester);
      await tester.tap(triggerText('A'));
      await _settle(tester);
      await tester.tap(panelText('A'));
      await _settle(tester);
      expect(log, ['select:a', 'change:a', 'select:a']);
    });
  });

  group('multiple selection', () {
    testWidgets('toggle adds and removes without closing; onSelect/onDeselect '
        'carry (value, option)', (tester) async {
      final log = <String>[];
      await tester.pumpWidget(
        _app(
          SemiSelect(
            multiple: true,
            placeholder: 'pick',
            options: _flatOptions,
            onChanged: (v) => log.add('change:$v'),
            onSelect: (v, o) => log.add('select:$v=${o.label}'),
            onDeselect: (v, o) => log.add('deselect:$v=${o.label}'),
          ),
        ),
      );
      await tester.tap(triggerText('pick'));
      await _settle(tester);
      await tester.tap(panelText('A'));
      await _settle(tester);
      expect(find.byType(SemiTooltipPopup), findsOneWidget);
      expect(log, ['select:a=A', "change:[a]"]);
      await tester.tap(panelText('A'));
      await _settle(tester);
      expect(log, ['select:a=A', 'change:[a]', 'deselect:a=A', 'change:[]']);
    });

    testWidgets('max refuses the pick through onExceed', (tester) async {
      final log = <String>[];
      await tester.pumpWidget(
        _app(
          SemiSelect(
            multiple: true,
            max: 1,
            placeholder: 'pick',
            options: _flatOptions,
            onChanged: (v) => log.add('change:$v'),
            onSelect: (v, _) => log.add('select:$v'),
            onExceed: (o) => log.add('exceed:${o.value}'),
          ),
        ),
      );
      await tester.tap(triggerText('pick'));
      await _settle(tester);
      await tester.tap(panelText('A'));
      await _settle(tester);
      await tester.tap(panelText('C'));
      await _settle(tester);
      expect(log, ['select:a', 'change:[a]', 'exceed:c']);
    });

    testWidgets('tag close removes; disabled tags are not closable', (
      tester,
    ) async {
      final log = <String>[];
      await tester.pumpWidget(
        _app(
          SemiSelect(
            multiple: true,
            defaultValue: const ['a', 'b', 'c'],
            options: _flatOptions,
            onChanged: (v) => log.add('change:$v'),
            onDeselect: (v, _) => log.add('deselect:$v'),
          ),
        ),
      );
      // a, b(disabled), c render as tags; only a and c carry close icons.
      expect(triggerText('A'), findsOneWidget);
      expect(triggerText('B'), findsOneWidget);
      expect(triggerText('C'), findsOneWidget);
      final tagIcons = find.descendant(
        of: find.byType(SemiTag),
        matching: find.byType(SemiIcon),
      );
      expect(tagIcons, findsNWidgets(2));
      await tester.tap(tagIcons.first);
      await _settle(tester);
      expect(log, ['deselect:a', 'change:[b, c]']);
    });

    testWidgets('Backspace drops the last tag and skips disabled ones', (
      tester,
    ) async {
      final log = <String>[];
      await tester.pumpWidget(
        _app(
          SemiSelect(
            multiple: true,
            filter: true,
            defaultValue: const ['a', 'b', 'c'],
            options: _flatOptions,
            onChanged: (v) => log.add('change:$v'),
          ),
        ),
      );
      await tester.tap(triggerText('B'));
      await _settle(tester);
      await tester.sendKeyEvent(LogicalKeyboardKey.backspace);
      await _settle(tester);
      expect(log, ['change:[a, b]']);
      await tester.sendKeyEvent(LogicalKeyboardKey.backspace);
      await _settle(tester);
      // b is disabled: skipped, a removed.
      expect(log, ['change:[a, b]', 'change:[b]']);
      await tester.sendKeyEvent(LogicalKeyboardKey.backspace);
      await _settle(tester);
      // Only the disabled tag remains: nothing happens.
      expect(log, ['change:[a, b]', 'change:[b]']);
    });

    testWidgets('maxTagCount folds to "+N"; expandRestTagsOnClick expands on '
        'open', (tester) async {
      await tester.pumpWidget(
        _app(
          SemiSelect(
            multiple: true,
            maxTagCount: 2,
            expandRestTagsOnClick: true,
            defaultValue: const ['a', 'b', 'c'],
            options: _flatOptions,
          ),
        ),
      );
      // Collapsed: first 2 tags + the "+1" fold tag.
      expect(triggerText('A'), findsOneWidget);
      expect(triggerText('B'), findsOneWidget);
      expect(triggerText('C'), findsNothing);
      expect(triggerText('+1'), findsOneWidget);
      await tester.tap(triggerText('+1'));
      await _settle(tester);
      // Open (expandRestTagsOnClick): every tag is back.
      expect(triggerText('B'), findsOneWidget);
      expect(triggerText('+1'), findsNothing);
    });

    testWidgets('showRestTagsPopover hovers the rest in a tooltip', (
      tester,
    ) async {
      await tester.pumpWidget(
        _app(
          SemiSelect(
            multiple: true,
            maxTagCount: 2,
            showRestTagsPopover: true,
            defaultValue: const ['a', 'b', 'c'],
            options: _flatOptions,
          ),
        ),
      );
      expect(triggerText('+1'), findsOneWidget);
      expect(triggerText('C'), findsNothing);
      final gesture = await tester.createGesture(kind: PointerDeviceKind.mouse);
      await gesture.addPointer(location: Offset.zero);
      addTearDown(gesture.removePointer);
      await gesture.moveTo(tester.getCenter(triggerText('+1')));
      // Hover open rides the 50ms mouseEnterDelay timer.
      await tester.pump(const Duration(milliseconds: 200));
      await _settle(tester);
      // The tooltip lists the folded-away tag.
      expect(find.text('C'), findsOneWidget);
      await gesture.moveTo(Offset.zero);
      await tester.pump(const Duration(milliseconds: 200));
      await _settle(tester);
    });
  });

  group('search and filter', () {
    testWidgets('the embedded search input never paints a wrapper box', (
      tester,
    ) async {
      await tester.pumpWidget(
        _app(
          SemiSelect(placeholder: 'pick', filter: true, options: _flatOptions),
        ),
      );
      await tester.tap(triggerText('pick'));
      await _settle(tester);
      await tester.tap(find.byType(EditableText));
      await _settle(tester);
      // select.scss gives the inner input `border: none` + transparent bg
      // even on `-wrapper-focus`; a focus border here was the "two boxes".
      final deco =
          tester
                  .widget<DecoratedBox>(find.byKey(SemiInput.wrapperKey))
                  .decoration
              as BoxDecoration;
      expect((deco.border! as Border).top.width, 0);
      expect(deco.color, const Color(0x00000000));
      // Web inputs center their text vertically (the embedded input is
      // `height: 100%` upstream); the editable hugs its own line height and
      // is centered in the slot — a stretched RenderEditable top-aligns its
      // glyphs and the typed text sat visibly high.
      final editableRect = tester.getRect(find.byType(EditableText));
      final wrapperRect = tester.getRect(find.byKey(SemiInput.wrapperKey));
      expect(editableRect.height, lessThanOrEqualTo(wrapperRect.height));
      expect(editableRect.center.dy, closeTo(wrapperRect.center.dy, 0.5));
    });

    testWidgets('filter: true matches label and group label substrings', (
      tester,
    ) async {
      await tester.pumpWidget(
        _app(
          SemiSelect(
            filter: true,
            placeholder: 'pick',
            options: const [SemiSelectOption(value: 'apple', label: 'Apple')],
            groups: const [
              SemiSelectGroup(
                label: 'Fruit',
                options: [
                  SemiSelectOption(value: 'banana', label: 'Banana'),
                  SemiSelectOption(value: 'cherry', label: 'Cherry'),
                ],
              ),
            ],
          ),
        ),
      );
      await tester.tap(triggerText('pick'));
      await _settle(tester);
      // The trigger search input shows over the (dimmed) placeholder.
      await tester.enterText(find.byType(EditableText), 'an');
      await _settle(tester);
      expect(panelText('Apple'), findsNothing);
      expect(panelText('Banana'), findsOneWidget);
      expect(panelText('Cherry'), findsNothing);
      // Group label hit keeps the whole group visible.
      await tester.enterText(find.byType(EditableText), 'fruit');
      await _settle(tester);
      expect(panelText('Banana'), findsOneWidget);
      expect(panelText('Cherry'), findsOneWidget);
    });

    testWidgets('custom predicate replaces the default matcher', (
      tester,
    ) async {
      await tester.pumpWidget(
        _app(
          SemiSelect(
            filter: (input, option) => option.value == input,
            placeholder: 'pick',
            options: _flatOptions,
          ),
        ),
      );
      await tester.tap(triggerText('pick'));
      await _settle(tester);
      await tester.enterText(find.byType(EditableText), 'c');
      await _settle(tester);
      expect(panelText('A'), findsNothing);
      expect(panelText('C'), findsOneWidget);
    });

    testWidgets('remote never filters locally but still notifies onSearch', (
      tester,
    ) async {
      final log = <String>[];
      await tester.pumpWidget(
        _app(
          SemiSelect(
            filter: true,
            remote: true,
            placeholder: 'pick',
            options: _flatOptions,
            onSearch: (v) => log.add('search:$v'),
          ),
        ),
      );
      await tester.tap(triggerText('pick'));
      await _settle(tester);
      await tester.enterText(find.byType(EditableText), 'zzz');
      await _settle(tester);
      expect(log, ['search:zzz']);
      expect(panelText('A'), findsOneWidget);
      expect(panelText('C'), findsOneWidget);
    });

    testWidgets('keyword hits highlight with the keyword color and weight', (
      tester,
    ) async {
      await tester.pumpWidget(
        _app(
          SemiSelect(
            filter: true,
            placeholder: 'pick',
            options: const [
              SemiSelectOption(value: 'ember', label: 'Ember'),
              SemiSelectOption(value: 'ash', label: 'Ash'),
            ],
          ),
        ),
      );
      await tester.tap(triggerText('pick'));
      await _settle(tester);
      await tester.enterText(find.byType(EditableText), 'em');
      await _settle(tester);
      expect(panelText('Ember'), findsOneWidget);
      expect(panelText('Ash'), findsNothing);
      final style = spanStyle(tester, 'Ember');
      expect(style.color, resolved.colorSelectOptionKeywordText);
      expect(style.fontWeight, resolved.fontSelectKeywordFontWeight);
    });

    testWidgets('searchPosition: dropdown renders the panel search box', (
      tester,
    ) async {
      await tester.pumpWidget(
        _app(
          SemiSelect(
            filter: true,
            searchPosition: SemiSelectSearchPosition.dropdown,
            searchPlaceholder: 'find',
            options: _flatOptions,
          ),
        ),
      );
      await tester.tap(find.byType(SemiSelect));
      await _settle(tester);
      // No trigger input; the panel input carries the search placeholder.
      expect(find.byType(EditableText), findsOneWidget);
      expect(find.text('find'), findsOneWidget);
      await tester.enterText(find.byType(EditableText), 'c');
      await _settle(tester);
      expect(panelText('A'), findsNothing);
      expect(panelText('C'), findsOneWidget);
    });

    testWidgets('autoClearSearchValue resets the search after a pick; false '
        'keeps it', (tester) async {
      final log = <String>[];
      await tester.pumpWidget(
        _app(
          SemiSelect(
            multiple: true,
            filter: true,
            placeholder: 'pick',
            options: const [
              SemiSelectOption(value: 'apple', label: 'Apple'),
              SemiSelectOption(value: 'banana', label: 'Banana'),
            ],
            onSearch: (v) => log.add('search:$v'),
          ),
        ),
      );
      await tester.tap(triggerText('pick'));
      await _settle(tester);
      await tester.enterText(find.byType(EditableText), 'an');
      await _settle(tester);
      expect(panelText('Apple'), findsNothing);
      await tester.tap(panelText('Banana'));
      await _settle(tester);
      expect(inputText(tester), isEmpty);
      expect(log, ['search:an', 'search:']);
      expect(panelText('Apple'), findsOneWidget);

      final keepLog = <String>[];
      await tester.pumpWidget(
        _app(
          SemiSelect(
            // UniqueKey: a fresh select state for the second half.
            key: UniqueKey(),
            multiple: true,
            filter: true,
            autoClearSearchValue: false,
            placeholder: 'pick',
            options: const [
              SemiSelectOption(value: 'apple', label: 'Apple'),
              SemiSelectOption(value: 'banana', label: 'Banana'),
            ],
            onSearch: (v) => keepLog.add('search:$v'),
          ),
        ),
      );
      await tester.tap(triggerText('pick'));
      await _settle(tester);
      await tester.enterText(find.byType(EditableText), 'an');
      await _settle(tester);
      await tester.tap(panelText('Banana'));
      await _settle(tester);
      expect(inputText(tester), 'an');
      expect(keepLog, ['search:an']);
    });

    testWidgets('single pick collapses the search box and fills the label', (
      tester,
    ) async {
      await tester.pumpWidget(
        _app(
          SemiSelect(
            filter: true,
            placeholder: 'pick',
            options: const [
              SemiSelectOption(value: 'apple', label: 'Apple'),
              SemiSelectOption(value: 'banana', label: 'Banana'),
            ],
          ),
        ),
      );
      await tester.tap(triggerText('pick'));
      await _settle(tester);
      // The search input shows and the label dims behind it.
      expect(find.byType(EditableText), findsOneWidget);
      await tester.enterText(find.byType(EditableText), 'ap');
      await _settle(tester);
      await tester.tap(panelText('Apple'));
      await _settle(tester);
      expect(find.byType(EditableText), findsNothing);
      expect(triggerText('Apple'), findsOneWidget);
    });
  });

  group('groups', () {
    testWidgets('group headers render with their first visible option', (
      tester,
    ) async {
      await tester.pumpWidget(
        _app(
          SemiSelect(
            placeholder: 'pick',
            options: const [SemiSelectOption(value: 'f', label: 'F')],
            groups: const [
              SemiSelectGroup(
                label: 'G1',
                options: [SemiSelectOption(value: 'a', label: 'A')],
              ),
              SemiSelectGroup(
                label: 'G2',
                options: [SemiSelectOption(value: 'c', label: 'C')],
              ),
            ],
          ),
        ),
      );
      await tester.tap(triggerText('pick'));
      await _settle(tester);
      // Flat options first, then the groups in order (port difference).
      double y(String text) => tester.getRect(panelText(text)).center.dy;
      expect(y('F'), lessThan(y('G1')));
      expect(y('G1'), lessThan(y('A')));
      expect(y('A'), lessThan(y('G2')));
      expect(y('G2'), lessThan(y('C')));
    });

    testWidgets('non-first group headers draw the top separator', (
      tester,
    ) async {
      await tester.pumpWidget(
        _app(
          SemiSelect(
            placeholder: 'pick',
            groups: const [
              SemiSelectGroup(
                label: 'G1',
                options: [SemiSelectOption(value: 'a', label: 'A')],
              ),
              SemiSelectGroup(
                label: 'G2',
                options: [SemiSelectOption(value: 'c', label: 'C')],
              ),
            ],
          ),
        ),
      );
      await tester.tap(triggerText('pick'));
      await _settle(tester);
      Container header(String text) => tester.widget<Container>(
        find
            .ancestor(of: panelText(text), matching: find.byType(Container))
            .first,
      );
      expect((header('G1').decoration! as BoxDecoration).border, isNull);
      final border = (header('G2').decoration! as BoxDecoration).border!;
      expect(border.top.width, resolved.widthSelectGroupTopBorder);
      expect(border.top.color, resolved.colorSelectOptionBorderDefault);
    });
  });

  group('allowCreate', () {
    testWidgets('appends a create row without an exact label match; picking '
        'it fires onCreate', (tester) async {
      final log = <String>[];
      await tester.pumpWidget(
        _app(
          SemiSelect(
            filter: true,
            allowCreate: true,
            placeholder: 'pick',
            options: const [SemiSelectOption(value: 'ze', label: 'Zebra')],
            onCreate: (o) => log.add('create:${o.value}'),
            onChanged: (v) => log.add('change:$v'),
          ),
        ),
      );
      await tester.tap(triggerText('pick'));
      await _settle(tester);
      await tester.enterText(find.byType(EditableText), 'ze');
      await _settle(tester);
      // 'Zebra' != 'ze': the create row appends at the end.
      expect(panelText('创建'), findsOneWidget);
      expect(panelText('Zebra'), findsOneWidget);
      await tester.tap(panelText('创建'));
      await _settle(tester);
      expect(log, ['create:ze', 'change:ze']);
    });

    testWidgets('an exact label match suppresses the create row', (
      tester,
    ) async {
      await tester.pumpWidget(
        _app(
          SemiSelect(
            filter: true,
            allowCreate: true,
            placeholder: 'pick',
            options: const [SemiSelectOption(value: 'ze', label: 'ze')],
          ),
        ),
      );
      await tester.tap(triggerText('pick'));
      await _settle(tester);
      await tester.enterText(find.byType(EditableText), 'ze');
      await _settle(tester);
      expect(panelText('创建'), findsNothing);
    });

    testWidgets('allowCreate freezes external options updates', (tester) async {
      await tester.pumpWidget(
        _app(
          SemiSelect(
            filter: true,
            allowCreate: true,
            placeholder: 'pick',
            options: const [SemiSelectOption(value: 'a', label: 'A')],
          ),
        ),
      );
      await tester.pumpWidget(
        _app(
          SemiSelect(
            filter: true,
            allowCreate: true,
            placeholder: 'pick',
            options: const [SemiSelectOption(value: 'c', label: 'C')],
          ),
        ),
      );
      await tester.tap(triggerText('pick'));
      await _settle(tester);
      expect(panelText('A'), findsOneWidget);
      expect(panelText('C'), findsNothing);
    });
  });

  group('keyboard', () {
    testWidgets('arrows open the panel and wrap through enabled rows', (
      tester,
    ) async {
      final controller = SemiSelectController();
      await tester.pumpWidget(
        _app(
          SemiSelect(
            controller: controller,
            options: _flatOptions,
            defaultActiveFirstOption: false,
            onDropdownVisibleChange: (_) {},
          ),
        ),
      );
      // Focus without opening (controller.focus never toggles the panel).
      controller.focus();
      await _settle(tester);
      expect(find.byType(SemiTooltipPopup), findsNothing);
      // Closed -> ArrowDown opens without a highlight.
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
      await _settle(tester);
      expect(find.byType(SemiTooltipPopup), findsOneWidget);
      expect(optionBg(tester, 'A'), const Color(0x00000000));
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
      await _settle(tester);
      expect(optionBg(tester, 'A'), resolved.colorSelectOptionBgHover);
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
      await _settle(tester);
      // Skips the disabled row.
      expect(optionBg(tester, 'A'), const Color(0x00000000));
      expect(optionBg(tester, 'C'), resolved.colorSelectOptionBgHover);
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
      await _settle(tester);
      // Wraps to the top.
      expect(optionBg(tester, 'A'), resolved.colorSelectOptionBgHover);
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowUp);
      await _settle(tester);
      // Wraps to the bottom.
      expect(optionBg(tester, 'C'), resolved.colorSelectOptionBgHover);
    });

    testWidgets('Enter opens, closes unfocused and selects focused', (
      tester,
    ) async {
      final log = <String>[];
      final controller = SemiSelectController();
      await tester.pumpWidget(
        _app(
          SemiSelect(
            controller: controller,
            options: _flatOptions,
            defaultActiveFirstOption: false,
            onChanged: (v) => log.add('change:$v'),
          ),
        ),
      );
      controller.focus();
      await _settle(tester);
      // Closed -> Enter opens.
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await _settle(tester);
      expect(find.byType(SemiTooltipPopup), findsOneWidget);
      // Open without a focused row -> Enter closes.
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await _settle(tester);
      expect(find.byType(SemiTooltipPopup), findsNothing);
      // Open with a focused row -> Enter selects it (and closes).
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await _settle(tester);
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
      await _settle(tester);
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await _settle(tester);
      expect(log, ['change:a']);
      expect(find.byType(SemiTooltipPopup), findsNothing);
      expect(triggerText('A'), findsOneWidget);
    });

    testWidgets('Enter on a multiple select keeps the panel open', (
      tester,
    ) async {
      await tester.pumpWidget(
        _app(
          SemiSelect(
            multiple: true,
            options: _flatOptions,
            defaultActiveFirstOption: true,
            onChanged: (_) {},
          ),
        ),
      );
      await tester.tap(find.byType(SemiSelect));
      await _settle(tester);
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await _settle(tester);
      expect(find.byType(SemiTooltipPopup), findsOneWidget);
      expect(triggerText('A'), findsOneWidget);
    });

    testWidgets('Escape closes and keeps the trigger focused', (tester) async {
      await tester.pumpWidget(
        _app(
          SemiSelect(options: _flatOptions, onDropdownVisibleChange: (_) {}),
        ),
      );
      await tester.tap(find.byType(SemiSelect));
      await _settle(tester);
      await tester.sendKeyEvent(LogicalKeyboardKey.escape);
      await _settle(tester);
      expect(find.byType(SemiTooltipPopup), findsNothing);
      // Focus survived the close: arrows reopen.
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
      await _settle(tester);
      expect(find.byType(SemiTooltipPopup), findsOneWidget);
    });

    testWidgets('loading swallows every key', (tester) async {
      final controller = SemiSelectController();
      await tester.pumpWidget(
        _app(
          SemiSelect(
            controller: controller,
            options: _flatOptions,
            loading: true,
          ),
        ),
      );
      controller.focus();
      await _settle(tester);
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
      await _settle(tester);
      expect(find.byType(SemiTooltipPopup), findsNothing);
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await _settle(tester);
      expect(find.byType(SemiTooltipPopup), findsNothing);
    });

    testWidgets('search-input Enter rides the onEnterPress channel', (
      tester,
    ) async {
      final log = <String>[];
      await tester.pumpWidget(
        _app(
          SemiSelect(
            filter: true,
            options: _flatOptions,
            onChanged: (v) => log.add('change:$v'),
          ),
        ),
      );
      await tester.tap(find.byType(SemiSelect));
      await _settle(tester);
      await _enter(tester);
      expect(log, ['change:a']);
    });
  });

  group('controlled, slots, loading, geometry, controller', () {
    testWidgets('controlled value only notifies and never lands', (
      tester,
    ) async {
      final log = <String>[];
      await tester.pumpWidget(
        _app(
          SemiSelect(
            value: 'a',
            options: _flatOptions,
            onChanged: (v) => log.add('change:$v'),
          ),
        ),
      );
      await tester.tap(triggerText('A'));
      await _settle(tester);
      await tester.tap(panelText('C'));
      await _settle(tester);
      expect(log, ['change:c']);
      // Never landed: the display still follows the controlled value.
      expect(triggerText('A'), findsOneWidget);
    });

    testWidgets('releasing control keeps the last controlled value', (
      tester,
    ) async {
      await tester.pumpWidget(
        _app(SemiSelect(value: 'a', options: _flatOptions)),
      );
      await tester.pumpWidget(_app(SemiSelect(options: _flatOptions)));
      await _settle(tester);
      expect(triggerText('A'), findsOneWidget);
    });

    testWidgets('defaultValue seeds the uncontrolled selection', (
      tester,
    ) async {
      await tester.pumpWidget(
        _app(SemiSelect(defaultValue: 'c', options: _flatOptions)),
      );
      expect(triggerText('C'), findsOneWidget);
    });

    testWidgets('panel slots render top to bottom', (tester) async {
      await tester.pumpWidget(
        _app(
          SemiSelect(
            placeholder: 'pick',
            options: _flatOptions,
            outerTopSlot: const Text('outer-top'),
            innerTopSlot: const Text('inner-top'),
            innerBottomSlot: const Text('inner-bottom'),
            outerBottomSlot: const Text('outer-bottom'),
          ),
        ),
      );
      await tester.tap(triggerText('pick'));
      await _settle(tester);
      double y(String text) => tester.getRect(panelText(text)).center.dy;
      expect(y('outer-top'), lessThan(y('inner-top')));
      expect(y('inner-top'), lessThan(y('A')));
      expect(y('C'), lessThan(y('inner-bottom')));
      expect(y('inner-bottom'), lessThan(y('outer-bottom')));
    });

    testWidgets('loading shows the spin; emptyContent replaces the list', (
      tester,
    ) async {
      await tester.pumpWidget(
        _app(
          SemiSelect(placeholder: 'pick', options: _flatOptions, loading: true),
        ),
      );
      await tester.tap(triggerText('pick'));
      await _settle(tester);
      expect(find.byType(SemiSpin), findsOneWidget);
      expect(panelText('A'), findsNothing);

      await tester.pumpWidget(
        _app(
          SemiSelect(
            // UniqueKey: a fresh select state for the second half.
            key: UniqueKey(),
            placeholder: 'pick',
            options: _flatOptions,
            emptyContent: const Text('none'),
            filter: (input, option) => false,
          ),
        ),
      );
      await tester.tap(triggerText('pick'));
      await _settle(tester);
      await tester.enterText(find.byType(EditableText), 'zz');
      await _settle(tester);
      expect(panelText('none'), findsOneWidget);
    });

    testWidgets('empty panel with null emptyContent renders no list', (
      tester,
    ) async {
      await tester.pumpWidget(
        _app(SemiSelect(placeholder: 'pick', filter: (input, option) => false)),
      );
      await tester.tap(triggerText('pick'));
      await _settle(tester);
      await tester.enterText(find.byType(EditableText), 'zz');
      await _settle(tester);
      expect(find.byType(SemiTooltipPopup), findsOneWidget);
      expect(panelText('A'), findsNothing);
    });

    testWidgets('trigger heights follow the three size tiers', (tester) async {
      for (final (size, height) in [
        (SemiInputSize.small, 24.0),
        (SemiInputSize.normal, 32.0),
        (SemiInputSize.large, 40.0),
      ]) {
        await tester.pumpWidget(
          _app(SemiSelect(size: size, options: _flatOptions)),
        );
        expect(
          tester.getSize(find.byType(SemiSelect)).height,
          height,
          reason: '$size',
        );
      }
    });

    testWidgets('arrow icon follows the trigger font size (1em)', (
      tester,
    ) async {
      for (final (size, expected) in [
        (SemiInputSize.small, 14.0),
        (SemiInputSize.normal, 14.0),
        (SemiInputSize.large, 16.0),
      ]) {
        await tester.pumpWidget(
          _app(SemiSelect(size: size, options: _flatOptions)),
        );
        final arrow = tester.widget<SemiIconTheme>(
          find
              .descendant(
                of: find.byType(SemiSelect),
                matching: find.byType(SemiIconTheme),
              )
              .first,
        );
        expect(
          arrow.data.customSize,
          expected,
          reason:
              'upstream renders the arrow at 1em of the trigger '
              '(font-size-regular 14 / font-size-header-6 16); a fixed 12 '
              'made it visibly smaller',
        );
      }
    });

    testWidgets('multiple tags hug the border with the 4px inset', (
      tester,
    ) async {
      await tester.pumpWidget(
        _app(
          SemiSelect(
            multiple: true,
            defaultValue: ['a', 'c'],
            options: _flatOptions,
          ),
        ),
      );
      final triggerLeft = tester.getTopLeft(find.byType(SemiSelect)).dx;
      final tagLeft = tester
          .getTopLeft(
            find
                .descendant(
                  of: find.byType(SemiSelect),
                  matching: find.byType(SemiTag),
                )
                .first,
          )
          .dx;
      // `$spacing-select_multiple_selection-marginLeft` (4px); the 12px
      // single-selection inset must not stack on top (was 16px).
      expect(tagLeft - triggerLeft, closeTo(4, 0.6));
    });

    testWidgets('dropdownMatchSelectWidth floors the panel at the trigger '
        'width', (tester) async {
      await tester.pumpWidget(
        _app(SemiSelect(placeholder: 'pick', options: _flatOptions)),
      );
      final triggerWidth = tester.getSize(find.byType(SemiSelect)).width;
      await tester.tap(triggerText('pick'));
      await _settle(tester);
      expect(tester.getSize(find.byType(SemiTooltipPopup)).width, triggerWidth);
    });

    testWidgets('controller drives open/close/search/clearInput/selectAll/'
        'deselectAll', (tester) async {
      final log = <String>[];
      final controller = SemiSelectController();
      await tester.pumpWidget(
        _app(
          SemiSelect(
            controller: controller,
            multiple: true,
            filter: true,
            options: _flatOptions,
            onChanged: (v) => log.add('change:$v'),
            onSearch: (v) => log.add('search:$v'),
          ),
        ),
      );
      controller.open();
      await _settle(tester);
      expect(find.byType(SemiTooltipPopup), findsOneWidget);
      controller.search('a');
      await _settle(tester);
      expect(inputText(tester), 'a');
      controller.clearInput();
      await _settle(tester);
      expect(inputText(tester), isEmpty);
      controller.close();
      await _settle(tester);
      expect(find.byType(SemiTooltipPopup), findsNothing);
      controller.selectAll();
      await _settle(tester);
      expect(log, ['search:a', 'search:', 'change:[a, b, c]']);
      controller.deselectAll();
      await _settle(tester);
      expect(log.last, 'change:[]');
    });
  });

  group('theme fields (104 + 9 + 2)', () {
    final fields = [
      (
        r'$color-select-bg-default: var(--semi-color-fill-0)',
        const Color(0xff123456),
        (Object v) => SemiSelectThemeData(colorSelectBgDefault: v as Color),
        (SemiResolvedSelectThemeData d) => d.colorSelectBgDefault,
        (SemiThemeData theme) => theme.colors.colorFill0,
      ),
      (
        r'$color-select-bg-hover: var(--semi-color-fill-1)',
        const Color(0xff123456),
        (Object v) => SemiSelectThemeData(colorSelectBgHover: v as Color),
        (SemiResolvedSelectThemeData d) => d.colorSelectBgHover,
        (SemiThemeData theme) => theme.colors.colorFill1,
      ),
      (
        r'$color-select-bg-active: var(--semi-color-fill-2)',
        const Color(0xff123456),
        (Object v) => SemiSelectThemeData(colorSelectBgActive: v as Color),
        (SemiResolvedSelectThemeData d) => d.colorSelectBgActive,
        (SemiThemeData theme) => theme.colors.colorFill2,
      ),
      (
        r'$color-select-bg-focus: var(--semi-color-fill-0)',
        const Color(0xff123456),
        (Object v) => SemiSelectThemeData(colorSelectBgFocus: v as Color),
        (SemiResolvedSelectThemeData d) => d.colorSelectBgFocus,
        (SemiThemeData theme) => theme.colors.colorFill0,
      ),
      (
        r'$color-select-border-default: transparent',
        const Color(0xff123456),
        (Object v) => SemiSelectThemeData(colorSelectBorderDefault: v as Color),
        (SemiResolvedSelectThemeData d) => d.colorSelectBorderDefault,
        (SemiThemeData theme) => const Color(0x00000000),
      ),
      (
        r'$color-select-border-hover: $color-select-border-default',
        const Color(0xff123456),
        (Object v) => SemiSelectThemeData(colorSelectBorderHover: v as Color),
        (SemiResolvedSelectThemeData d) => d.colorSelectBorderHover,
        (SemiThemeData theme) => const Color(0x00000000),
      ),
      (
        r'$color-select-border-active: var(--semi-color-focus-border)',
        const Color(0xff123456),
        (Object v) => SemiSelectThemeData(colorSelectBorderActive: v as Color),
        (SemiResolvedSelectThemeData d) => d.colorSelectBorderActive,
        (SemiThemeData theme) => theme.colors.colorFocusBorder,
      ),
      (
        r'$color-select-border-focus: $color-select-border-active',
        const Color(0xff123456),
        (Object v) => SemiSelectThemeData(colorSelectBorderFocus: v as Color),
        (SemiResolvedSelectThemeData d) => d.colorSelectBorderFocus,
        (SemiThemeData theme) => theme.colors.colorFocusBorder,
      ),
      (
        r'$color-select_dropdown_input-border: $color-select-border-default',
        const Color(0xff123456),
        (Object v) =>
            SemiSelectThemeData(colorSelectDropdownInputBorder: v as Color),
        (SemiResolvedSelectThemeData d) => d.colorSelectDropdownInputBorder,
        (SemiThemeData theme) => const Color(0x00000000),
      ),
      (
        r'$color-select_warning-bg-default: var(--semi-color-warning-light-default)',
        const Color(0xff123456),
        (Object v) =>
            SemiSelectThemeData(colorSelectWarningBgDefault: v as Color),
        (SemiResolvedSelectThemeData d) => d.colorSelectWarningBgDefault,
        (SemiThemeData theme) => theme.colors.colorWarningLightDefault,
      ),
      (
        r'$color-select_warning-border-default: var(--semi-color-warning-light-default)',
        const Color(0xff123456),
        (Object v) =>
            SemiSelectThemeData(colorSelectWarningBorderDefault: v as Color),
        (SemiResolvedSelectThemeData d) => d.colorSelectWarningBorderDefault,
        (SemiThemeData theme) => theme.colors.colorWarningLightDefault,
      ),
      (
        r'$color-select_warning-bg-hover: var(--semi-color-warning-light-hover)',
        const Color(0xff123456),
        (Object v) =>
            SemiSelectThemeData(colorSelectWarningBgHover: v as Color),
        (SemiResolvedSelectThemeData d) => d.colorSelectWarningBgHover,
        (SemiThemeData theme) => theme.colors.colorWarningLightHover,
      ),
      (
        r'$color-select_warning-border-hover: var(--semi-color-warning-light-hover)',
        const Color(0xff123456),
        (Object v) =>
            SemiSelectThemeData(colorSelectWarningBorderHover: v as Color),
        (SemiResolvedSelectThemeData d) => d.colorSelectWarningBorderHover,
        (SemiThemeData theme) => theme.colors.colorWarningLightHover,
      ),
      (
        r'$color-select_warning-bg-focus: var(--semi-color-warning-light-default)',
        const Color(0xff123456),
        (Object v) =>
            SemiSelectThemeData(colorSelectWarningBgFocus: v as Color),
        (SemiResolvedSelectThemeData d) => d.colorSelectWarningBgFocus,
        (SemiThemeData theme) => theme.colors.colorWarningLightDefault,
      ),
      (
        r'$color-select_warning-border-focus: var(--semi-color-warning)',
        const Color(0xff123456),
        (Object v) =>
            SemiSelectThemeData(colorSelectWarningBorderFocus: v as Color),
        (SemiResolvedSelectThemeData d) => d.colorSelectWarningBorderFocus,
        (SemiThemeData theme) => theme.colors.colorWarning,
      ),
      (
        r'$color-select_warning-bg-active: var(--semi-color-warning-light-active)',
        const Color(0xff123456),
        (Object v) =>
            SemiSelectThemeData(colorSelectWarningBgActive: v as Color),
        (SemiResolvedSelectThemeData d) => d.colorSelectWarningBgActive,
        (SemiThemeData theme) => theme.colors.colorWarningLightActive,
      ),
      (
        r'$color-select_warning-border-active: var(--semi-color-warning-light-active)',
        const Color(0xff123456),
        (Object v) =>
            SemiSelectThemeData(colorSelectWarningBorderActive: v as Color),
        (SemiResolvedSelectThemeData d) => d.colorSelectWarningBorderActive,
        (SemiThemeData theme) => theme.colors.colorWarningLightActive,
      ),
      (
        r'$color-select_danger-bg-default: var(--semi-color-danger-light-default)',
        const Color(0xff123456),
        (Object v) =>
            SemiSelectThemeData(colorSelectDangerBgDefault: v as Color),
        (SemiResolvedSelectThemeData d) => d.colorSelectDangerBgDefault,
        (SemiThemeData theme) => theme.colors.colorDangerLightDefault,
      ),
      (
        r'$color-select_danger-border-default: var(--semi-color-danger-light-default)',
        const Color(0xff123456),
        (Object v) =>
            SemiSelectThemeData(colorSelectDangerBorderDefault: v as Color),
        (SemiResolvedSelectThemeData d) => d.colorSelectDangerBorderDefault,
        (SemiThemeData theme) => theme.colors.colorDangerLightDefault,
      ),
      (
        r'$color-select_danger-bg-hover: var(--semi-color-danger-light-hover)',
        const Color(0xff123456),
        (Object v) => SemiSelectThemeData(colorSelectDangerBgHover: v as Color),
        (SemiResolvedSelectThemeData d) => d.colorSelectDangerBgHover,
        (SemiThemeData theme) => theme.colors.colorDangerLightHover,
      ),
      (
        r'$color-select_danger-border-hover: var(--semi-color-danger-light-hover)',
        const Color(0xff123456),
        (Object v) =>
            SemiSelectThemeData(colorSelectDangerBorderHover: v as Color),
        (SemiResolvedSelectThemeData d) => d.colorSelectDangerBorderHover,
        (SemiThemeData theme) => theme.colors.colorDangerLightHover,
      ),
      (
        r'$color-select_danger-bg-focus: var(--semi-color-danger-light-default)',
        const Color(0xff123456),
        (Object v) => SemiSelectThemeData(colorSelectDangerBgFocus: v as Color),
        (SemiResolvedSelectThemeData d) => d.colorSelectDangerBgFocus,
        (SemiThemeData theme) => theme.colors.colorDangerLightDefault,
      ),
      (
        r'$color-select_danger-border-focus: var(--semi-color-danger)',
        const Color(0xff123456),
        (Object v) =>
            SemiSelectThemeData(colorSelectDangerBorderFocus: v as Color),
        (SemiResolvedSelectThemeData d) => d.colorSelectDangerBorderFocus,
        (SemiThemeData theme) => theme.colors.colorDanger,
      ),
      (
        r'$color-select_danger-bg-active: var(--semi-color-danger-light-active)',
        const Color(0xff123456),
        (Object v) =>
            SemiSelectThemeData(colorSelectDangerBgActive: v as Color),
        (SemiResolvedSelectThemeData d) => d.colorSelectDangerBgActive,
        (SemiThemeData theme) => theme.colors.colorDangerLightActive,
      ),
      (
        r'$color-select_danger-border-active: var(--semi-color-danger-light-active)',
        const Color(0xff123456),
        (Object v) =>
            SemiSelectThemeData(colorSelectDangerBorderActive: v as Color),
        (SemiResolvedSelectThemeData d) => d.colorSelectDangerBorderActive,
        (SemiThemeData theme) => theme.colors.colorDangerLightActive,
      ),
      (
        r'$color-select_default-border-focus: var(--semi-color-focus-border)',
        const Color(0xff123456),
        (Object v) =>
            SemiSelectThemeData(colorSelectDefaultBorderFocus: v as Color),
        (SemiResolvedSelectThemeData d) => d.colorSelectDefaultBorderFocus,
        (SemiThemeData theme) => theme.colors.colorFocusBorder,
      ),
      (
        r'$color-select_main-text-default: var(--semi-color-text-0)',
        const Color(0xff123456),
        (Object v) =>
            SemiSelectThemeData(colorSelectMainTextDefault: v as Color),
        (SemiResolvedSelectThemeData d) => d.colorSelectMainTextDefault,
        (SemiThemeData theme) => theme.colors.colorText0,
      ),
      (
        r'$color-select-icon-default: var(--semi-color-text-2)',
        const Color(0xff123456),
        (Object v) => SemiSelectThemeData(colorSelectIconDefault: v as Color),
        (SemiResolvedSelectThemeData d) => d.colorSelectIconDefault,
        (SemiThemeData theme) => theme.colors.colorText2,
      ),
      (
        r'$color-select_clearBtn-text-default: var(--semi-color-text-2)',
        const Color(0xff123456),
        (Object v) =>
            SemiSelectThemeData(colorSelectClearBtnTextDefault: v as Color),
        (SemiResolvedSelectThemeData d) => d.colorSelectClearBtnTextDefault,
        (SemiThemeData theme) => theme.colors.colorText2,
      ),
      (
        r'$color-select_clearBtn-text-hover: var(--semi-color-primary)',
        const Color(0xff123456),
        (Object v) =>
            SemiSelectThemeData(colorSelectClearBtnTextHover: v as Color),
        (SemiResolvedSelectThemeData d) => d.colorSelectClearBtnTextHover,
        (SemiThemeData theme) => theme.colors.colorPrimary,
      ),
      (
        r'$color-select_input_disabled-bg: var(--semi-color-disabled-fill)',
        const Color(0xff123456),
        (Object v) =>
            SemiSelectThemeData(colorSelectInputDisabledBg: v as Color),
        (SemiResolvedSelectThemeData d) => d.colorSelectInputDisabledBg,
        (SemiThemeData theme) => theme.colors.colorDisabledFill,
      ),
      (
        r'$color-select_input_disabled-border: var(--semi-color-border)',
        const Color(0xff123456),
        (Object v) =>
            SemiSelectThemeData(colorSelectInputDisabledBorder: v as Color),
        (SemiResolvedSelectThemeData d) => d.colorSelectInputDisabledBorder,
        (SemiThemeData theme) => theme.colors.colorBorder,
      ),
      (
        r'$color-select_input_disabled-border-focus: transparent',
        const Color(0xff123456),
        (Object v) => SemiSelectThemeData(
          colorSelectInputDisabledBorderFocus: v as Color,
        ),
        (SemiResolvedSelectThemeData d) =>
            d.colorSelectInputDisabledBorderFocus,
        (SemiThemeData theme) => const Color(0x00000000),
      ),
      (
        r'$color-select_input_disabled-text: var(--semi-color-disabled-text)',
        const Color(0xff123456),
        (Object v) =>
            SemiSelectThemeData(colorSelectInputDisabledText: v as Color),
        (SemiResolvedSelectThemeData d) => d.colorSelectInputDisabledText,
        (SemiThemeData theme) => theme.colors.colorDisabledText,
      ),
      (
        r'$color-select_input_disabled-bg-hover: var(--semi-color-disabled-fill)',
        const Color(0xff123456),
        (Object v) =>
            SemiSelectThemeData(colorSelectInputDisabledBgHover: v as Color),
        (SemiResolvedSelectThemeData d) => d.colorSelectInputDisabledBgHover,
        (SemiThemeData theme) => theme.colors.colorDisabledFill,
      ),
      (
        r'$color-select_input_disabled-bg-focus: var(--semi-color-disabled-fill)',
        const Color(0xff123456),
        (Object v) =>
            SemiSelectThemeData(colorSelectInputDisabledBgFocus: v as Color),
        (SemiResolvedSelectThemeData d) => d.colorSelectInputDisabledBgFocus,
        (SemiThemeData theme) => theme.colors.colorDisabledFill,
      ),
      (
        r'$color-select_input_placeholder-text: var(--semi-color-text-2)',
        const Color(0xff123456),
        (Object v) =>
            SemiSelectThemeData(colorSelectInputPlaceholderText: v as Color),
        (SemiResolvedSelectThemeData d) => d.colorSelectInputPlaceholderText,
        (SemiThemeData theme) => theme.colors.colorText2,
      ),
      (
        r'$color-select_option_main-text: var(--semi-color-text-0)',
        const Color(0xff123456),
        (Object v) =>
            SemiSelectThemeData(colorSelectOptionMainText: v as Color),
        (SemiResolvedSelectThemeData d) => d.colorSelectOptionMainText,
        (SemiThemeData theme) => theme.colors.colorText0,
      ),
      (
        r'$color-select_option_keyword-text: var(--semi-color-primary)',
        const Color(0xff123456),
        (Object v) =>
            SemiSelectThemeData(colorSelectOptionKeywordText: v as Color),
        (SemiResolvedSelectThemeData d) => d.colorSelectOptionKeywordText,
        (SemiThemeData theme) => theme.colors.colorPrimary,
      ),
      (
        r'$color-select_option-icon-default: transparent',
        const Color(0xff123456),
        (Object v) =>
            SemiSelectThemeData(colorSelectOptionIconDefault: v as Color),
        (SemiResolvedSelectThemeData d) => d.colorSelectOptionIconDefault,
        (SemiThemeData theme) => const Color(0x00000000),
      ),
      (
        r'$color-select_option-bg-hover: var(--semi-color-fill-0)',
        const Color(0xff123456),
        (Object v) => SemiSelectThemeData(colorSelectOptionBgHover: v as Color),
        (SemiResolvedSelectThemeData d) => d.colorSelectOptionBgHover,
        (SemiThemeData theme) => theme.colors.colorFill0,
      ),
      (
        r'$color-select_option-bg-active: var(--semi-color-fill-1)',
        const Color(0xff123456),
        (Object v) =>
            SemiSelectThemeData(colorSelectOptionBgActive: v as Color),
        (SemiResolvedSelectThemeData d) => d.colorSelectOptionBgActive,
        (SemiThemeData theme) => theme.colors.colorFill1,
      ),
      (
        r'$color-select_option_disabled-text: var(--semi-color-disabled-text)',
        const Color(0xff123456),
        (Object v) =>
            SemiSelectThemeData(colorSelectOptionDisabledText: v as Color),
        (SemiResolvedSelectThemeData d) => d.colorSelectOptionDisabledText,
        (SemiThemeData theme) => theme.colors.colorDisabledText,
      ),
      (
        r'$color-select_option-icon-active: var(--semi-color-text-2)',
        const Color(0xff123456),
        (Object v) =>
            SemiSelectThemeData(colorSelectOptionIconActive: v as Color),
        (SemiResolvedSelectThemeData d) => d.colorSelectOptionIconActive,
        (SemiThemeData theme) => theme.colors.colorText2,
      ),
      (
        r'$color-select_option-border-default: var(--semi-color-border)',
        const Color(0xff123456),
        (Object v) =>
            SemiSelectThemeData(colorSelectOptionBorderDefault: v as Color),
        (SemiResolvedSelectThemeData d) => d.colorSelectOptionBorderDefault,
        (SemiThemeData theme) => theme.colors.colorBorder,
      ),
      (
        r'$color-select-option-bg-selected: transparent',
        const Color(0xff123456),
        (Object v) =>
            SemiSelectThemeData(colorSelectOptionBgSelected: v as Color),
        (SemiResolvedSelectThemeData d) => d.colorSelectOptionBgSelected,
        (SemiThemeData theme) => const Color(0x00000000),
      ),
      (
        r'$color-select_create_tips-text: var(--semi-color-text-2)',
        const Color(0xff123456),
        (Object v) =>
            SemiSelectThemeData(colorSelectCreateTipsText: v as Color),
        (SemiResolvedSelectThemeData d) => d.colorSelectCreateTipsText,
        (SemiThemeData theme) => theme.colors.colorText2,
      ),
      (
        r'$color-select_group-text: var(--semi-color-text-2)',
        const Color(0xff123456),
        (Object v) => SemiSelectThemeData(colorSelectGroupText: v as Color),
        (SemiResolvedSelectThemeData d) => d.colorSelectGroupText,
        (SemiThemeData theme) => theme.colors.colorText2,
      ),
      (
        r'$color-select_prefix_suffix_text-default: var(--semi-color-text-2)',
        const Color(0xff123456),
        (Object v) =>
            SemiSelectThemeData(colorSelectPrefixSuffixTextDefault: v as Color),
        (SemiResolvedSelectThemeData d) => d.colorSelectPrefixSuffixTextDefault,
        (SemiThemeData theme) => theme.colors.colorText2,
      ),
      (
        r'$width-select_icon_right: ($width-icon-medium + $spacing-tight * 2)',
        4.5,
        (Object v) => SemiSelectThemeData(widthSelectIconRight: v as double),
        (SemiResolvedSelectThemeData d) => d.widthSelectIconRight,
        (SemiThemeData theme) => 32.0,
      ),
      (
        r'$height-select_large: $height-control-large',
        4.5,
        (Object v) => SemiSelectThemeData(heightSelectLarge: v as double),
        (SemiResolvedSelectThemeData d) => d.heightSelectLarge,
        (SemiThemeData theme) => 40.0,
      ),
      (
        r'$height-select_small: $height-control-small',
        4.5,
        (Object v) => SemiSelectThemeData(heightSelectSmall: v as double),
        (SemiResolvedSelectThemeData d) => d.heightSelectSmall,
        (SemiThemeData theme) => 24.0,
      ),
      (
        r'$height-select_default: $height-control-default',
        4.5,
        (Object v) => SemiSelectThemeData(heightSelectDefault: v as double),
        (SemiResolvedSelectThemeData d) => d.heightSelectDefault,
        (SemiThemeData theme) => 32.0,
      ),
      (
        r'$width-select_option_tick: $width-icon-small',
        4.5,
        (Object v) => SemiSelectThemeData(widthSelectOptionTick: v as double),
        (SemiResolvedSelectThemeData d) => d.widthSelectOptionTick,
        (SemiThemeData theme) => 12.0,
      ),
      (
        r'$width-select-border: 1px',
        4.5,
        (Object v) => SemiSelectThemeData(widthSelectBorder: v as double),
        (SemiResolvedSelectThemeData d) => d.widthSelectBorder,
        (SemiThemeData theme) => 1.0,
      ),
      (
        r'$width-select_arrow: 32px',
        4.5,
        (Object v) => SemiSelectThemeData(widthSelectArrow: v as double),
        (SemiResolvedSelectThemeData d) => d.widthSelectArrow,
        (SemiThemeData theme) => 32.0,
      ),
      (
        r'$width-select_arrow_empty: 12px',
        4.5,
        (Object v) => SemiSelectThemeData(widthSelectArrowEmpty: v as double),
        (SemiResolvedSelectThemeData d) => d.widthSelectArrowEmpty,
        (SemiThemeData theme) => 12.0,
      ),
      (
        r'$width-select_clear-icon: 32px',
        4.5,
        (Object v) => SemiSelectThemeData(widthSelectClearIcon: v as double),
        (SemiResolvedSelectThemeData d) => d.widthSelectClearIcon,
        (SemiThemeData theme) => 32.0,
      ),
      (
        r'$width-select_group_top-border: $border-thickness-control',
        4.5,
        (Object v) =>
            SemiSelectThemeData(widthSelectGroupTopBorder: v as double),
        (SemiResolvedSelectThemeData d) => d.widthSelectGroupTopBorder,
        (SemiThemeData theme) => 1.0,
      ),
      (
        r'$height-select_multiple_input_small: 20px',
        4.5,
        (Object v) =>
            SemiSelectThemeData(heightSelectMultipleInputSmall: v as double),
        (SemiResolvedSelectThemeData d) => d.heightSelectMultipleInputSmall,
        (SemiThemeData theme) => 20.0,
      ),
      (
        r'$height-select_multiple_input_default: 24px',
        4.5,
        (Object v) =>
            SemiSelectThemeData(heightSelectMultipleInputDefault: v as double),
        (SemiResolvedSelectThemeData d) => d.heightSelectMultipleInputDefault,
        (SemiThemeData theme) => 24.0,
      ),
      (
        r'$height-select_multiple_input_large: 24px',
        4.5,
        (Object v) =>
            SemiSelectThemeData(heightSelectMultipleInputLarge: v as double),
        (SemiResolvedSelectThemeData d) => d.heightSelectMultipleInputLarge,
        (SemiThemeData theme) => 24.0,
      ),
      (
        r'$width-select-border-hover: $width-select-border',
        4.5,
        (Object v) => SemiSelectThemeData(widthSelectBorderHover: v as double),
        (SemiResolvedSelectThemeData d) => d.widthSelectBorderHover,
        (SemiThemeData theme) => 1.0,
      ),
      (
        r'$width-select-border-focus: $width-select-border-hover',
        4.5,
        (Object v) => SemiSelectThemeData(widthSelectBorderFocus: v as double),
        (SemiResolvedSelectThemeData d) => d.widthSelectBorderFocus,
        (SemiThemeData theme) => 1.0,
      ),
      (
        r'$width-select-border-active: $width-select-border-focus',
        4.5,
        (Object v) => SemiSelectThemeData(widthSelectBorderActive: v as double),
        (SemiResolvedSelectThemeData d) => d.widthSelectBorderActive,
        (SemiThemeData theme) => 1.0,
      ),
      (
        r'$spacing-select_option_tick-marginRight: $spacing-tight',
        4.5,
        (Object v) => SemiSelectThemeData(
          spacingSelectOptionTickMarginRight: v as double,
        ),
        (SemiResolvedSelectThemeData d) => d.spacingSelectOptionTickMarginRight,
        (SemiThemeData theme) => 8.0,
      ),
      (
        r'$spacing-select_prefix_suffix_text-marginX: $spacing-base-tight',
        4.5,
        (Object v) => SemiSelectThemeData(
          spacingSelectPrefixSuffixTextMarginX: v as double,
        ),
        (SemiResolvedSelectThemeData d) =>
            d.spacingSelectPrefixSuffixTextMarginX,
        (SemiThemeData theme) => 12.0,
      ),
      (
        r'$spacing-select_prefix_suffix_text-marginY: 0px',
        4.5,
        (Object v) => SemiSelectThemeData(
          spacingSelectPrefixSuffixTextMarginY: v as double,
        ),
        (SemiResolvedSelectThemeData d) =>
            d.spacingSelectPrefixSuffixTextMarginY,
        (SemiThemeData theme) => 0.0,
      ),
      (
        r'$spacing-select_prefix_suffix_icon-marginX: $spacing-tight',
        4.5,
        (Object v) => SemiSelectThemeData(
          spacingSelectPrefixSuffixIconMarginX: v as double,
        ),
        (SemiResolvedSelectThemeData d) =>
            d.spacingSelectPrefixSuffixIconMarginX,
        (SemiThemeData theme) => 8.0,
      ),
      (
        r'$spacing-select_prefix_suffix_icon-marginY: 0px',
        4.5,
        (Object v) => SemiSelectThemeData(
          spacingSelectPrefixSuffixIconMarginY: v as double,
        ),
        (SemiResolvedSelectThemeData d) =>
            d.spacingSelectPrefixSuffixIconMarginY,
        (SemiThemeData theme) => 0.0,
      ),
      (
        r'$spacing-select_create_tips-marginRight: $spacing-extra-tight',
        4.5,
        (Object v) => SemiSelectThemeData(
          spacingSelectCreateTipsMarginRight: v as double,
        ),
        (SemiResolvedSelectThemeData d) => d.spacingSelectCreateTipsMarginRight,
        (SemiThemeData theme) => 4.0,
      ),
      (
        r'$spacing-select_group-marginTop: $spacing-extra-tight',
        4.5,
        (Object v) =>
            SemiSelectThemeData(spacingSelectGroupMarginTop: v as double),
        (SemiResolvedSelectThemeData d) => d.spacingSelectGroupMarginTop,
        (SemiThemeData theme) => 4.0,
      ),
      (
        r'$spacing-select_group-paddingTop: $spacing-base-tight',
        4.5,
        (Object v) =>
            SemiSelectThemeData(spacingSelectGroupPaddingTop: v as double),
        (SemiResolvedSelectThemeData d) => d.spacingSelectGroupPaddingTop,
        (SemiThemeData theme) => 12.0,
      ),
      (
        r'$spacing-select_group-paddingBottom: $spacing-extra-tight',
        4.5,
        (Object v) =>
            SemiSelectThemeData(spacingSelectGroupPaddingBottom: v as double),
        (SemiResolvedSelectThemeData d) => d.spacingSelectGroupPaddingBottom,
        (SemiThemeData theme) => 4.0,
      ),
      (
        r'$spacing-select_group-paddingLeft: $spacing-base-tight + $width-select_option_tick + $spacing-select_option_tick-marginRight',
        4.5,
        (Object v) =>
            SemiSelectThemeData(spacingSelectGroupPaddingLeft: v as double),
        (SemiResolvedSelectThemeData d) => d.spacingSelectGroupPaddingLeft,
        (SemiThemeData theme) => 32.0,
      ),
      (
        r'$spacing-select_group-paddingRight: $spacing-base',
        4.5,
        (Object v) =>
            SemiSelectThemeData(spacingSelectGroupPaddingRight: v as double),
        (SemiResolvedSelectThemeData d) => d.spacingSelectGroupPaddingRight,
        (SemiThemeData theme) => 16.0,
      ),
      (
        r'$spacing-select_loading_wrapper-paddingLeft: $spacing-base',
        4.5,
        (Object v) => SemiSelectThemeData(
          spacingSelectLoadingWrapperPaddingLeft: v as double,
        ),
        (SemiResolvedSelectThemeData d) =>
            d.spacingSelectLoadingWrapperPaddingLeft,
        (SemiThemeData theme) => 16.0,
      ),
      (
        r'$spacing-select_loading_wrapper-paddingRight: $spacing-base',
        4.5,
        (Object v) => SemiSelectThemeData(
          spacingSelectLoadingWrapperPaddingRight: v as double,
        ),
        (SemiResolvedSelectThemeData d) =>
            d.spacingSelectLoadingWrapperPaddingRight,
        (SemiThemeData theme) => 16.0,
      ),
      (
        r'$spacing-select_loading_wrapper-paddingTop: $spacing-tight',
        4.5,
        (Object v) => SemiSelectThemeData(
          spacingSelectLoadingWrapperPaddingTop: v as double,
        ),
        (SemiResolvedSelectThemeData d) =>
            d.spacingSelectLoadingWrapperPaddingTop,
        (SemiThemeData theme) => 8.0,
      ),
      (
        r'$spacing-select_loading_wrapper-paddingBottom: $spacing-tight',
        4.5,
        (Object v) => SemiSelectThemeData(
          spacingSelectLoadingWrapperPaddingBottom: v as double,
        ),
        (SemiResolvedSelectThemeData d) =>
            d.spacingSelectLoadingWrapperPaddingBottom,
        (SemiThemeData theme) => 8.0,
      ),
      (
        r'$spacing-select_multiple_content_wrapper_empty-marginLeft: $spacing-tight',
        4.5,
        (Object v) => SemiSelectThemeData(
          spacingSelectMultipleContentWrapperEmptyMarginLeft: v as double,
        ),
        (SemiResolvedSelectThemeData d) =>
            d.spacingSelectMultipleContentWrapperEmptyMarginLeft,
        (SemiThemeData theme) => 8.0,
      ),
      (
        r'$spacing-select_multiple_selection-marginLeft: $spacing-extra-tight',
        4.5,
        (Object v) => SemiSelectThemeData(
          spacingSelectMultipleSelectionMarginLeft: v as double,
        ),
        (SemiResolvedSelectThemeData d) =>
            d.spacingSelectMultipleSelectionMarginLeft,
        (SemiThemeData theme) => 4.0,
      ),
      (
        r'$spacing-select_option-paddingLeft: $spacing-base-tight',
        4.5,
        (Object v) =>
            SemiSelectThemeData(spacingSelectOptionPaddingLeft: v as double),
        (SemiResolvedSelectThemeData d) => d.spacingSelectOptionPaddingLeft,
        (SemiThemeData theme) => 12.0,
      ),
      (
        r'$spacing-select_option-paddingRight: $spacing-base-tight',
        4.5,
        (Object v) =>
            SemiSelectThemeData(spacingSelectOptionPaddingRight: v as double),
        (SemiResolvedSelectThemeData d) => d.spacingSelectOptionPaddingRight,
        (SemiThemeData theme) => 12.0,
      ),
      (
        r'$spacing-select_option-paddingTop: $spacing-tight',
        4.5,
        (Object v) =>
            SemiSelectThemeData(spacingSelectOptionPaddingTop: v as double),
        (SemiResolvedSelectThemeData d) => d.spacingSelectOptionPaddingTop,
        (SemiThemeData theme) => 8.0,
      ),
      (
        r'$spacing-select_option-paddingBottom: $spacing-tight',
        4.5,
        (Object v) =>
            SemiSelectThemeData(spacingSelectOptionPaddingBottom: v as double),
        (SemiResolvedSelectThemeData d) => d.spacingSelectOptionPaddingBottom,
        (SemiThemeData theme) => 8.0,
      ),
      (
        r'$spacing-select_tag-marginTop: $spacing-super-tight - 1px',
        4.5,
        (Object v) =>
            SemiSelectThemeData(spacingSelectTagMarginTop: v as double),
        (SemiResolvedSelectThemeData d) => d.spacingSelectTagMarginTop,
        (SemiThemeData theme) => 1.0,
      ),
      (
        r'$spacing-select_tag-marginRight: $spacing-extra-tight',
        4.5,
        (Object v) =>
            SemiSelectThemeData(spacingSelectTagMarginRight: v as double),
        (SemiResolvedSelectThemeData d) => d.spacingSelectTagMarginRight,
        (SemiThemeData theme) => 4.0,
      ),
      (
        r'$spacing-select_tag-marginBottom: $spacing-super-tight - 1px',
        4.5,
        (Object v) =>
            SemiSelectThemeData(spacingSelectTagMarginBottom: v as double),
        (SemiResolvedSelectThemeData d) => d.spacingSelectTagMarginBottom,
        (SemiThemeData theme) => 1.0,
      ),
      (
        r'$spacing-select_selection-marginLeft: $spacing-base-tight',
        4.5,
        (Object v) =>
            SemiSelectThemeData(spacingSelectSelectionMarginLeft: v as double),
        (SemiResolvedSelectThemeData d) => d.spacingSelectSelectionMarginLeft,
        (SemiThemeData theme) => 12.0,
      ),
      (
        r'$spacing-select_option_list-paddingTop: $spacing-extra-tight',
        4.5,
        (Object v) =>
            SemiSelectThemeData(spacingSelectOptionListPaddingTop: v as double),
        (SemiResolvedSelectThemeData d) => d.spacingSelectOptionListPaddingTop,
        (SemiThemeData theme) => 4.0,
      ),
      (
        r'$spacing-select_option_list-paddingRight: 0px',
        4.5,
        (Object v) => SemiSelectThemeData(
          spacingSelectOptionListPaddingRight: v as double,
        ),
        (SemiResolvedSelectThemeData d) =>
            d.spacingSelectOptionListPaddingRight,
        (SemiThemeData theme) => 0.0,
      ),
      (
        r'$spacing-select_option_list-paddingBottom: $spacing-extra-tight',
        4.5,
        (Object v) => SemiSelectThemeData(
          spacingSelectOptionListPaddingBottom: v as double,
        ),
        (SemiResolvedSelectThemeData d) =>
            d.spacingSelectOptionListPaddingBottom,
        (SemiThemeData theme) => 4.0,
      ),
      (
        r'$spacing-select_option_list-paddingLeft: 0px',
        4.5,
        (Object v) => SemiSelectThemeData(
          spacingSelectOptionListPaddingLeft: v as double,
        ),
        (SemiResolvedSelectThemeData d) => d.spacingSelectOptionListPaddingLeft,
        (SemiThemeData theme) => 0.0,
      ),
      (
        r'$spacing-select_dropdown_input_paddingTop: 8px',
        4.5,
        (Object v) => SemiSelectThemeData(
          spacingSelectDropdownInputPaddingTop: v as double,
        ),
        (SemiResolvedSelectThemeData d) =>
            d.spacingSelectDropdownInputPaddingTop,
        (SemiThemeData theme) => 8.0,
      ),
      (
        r'$spacing-select_dropdown_input_paddingBottom: 8px',
        4.5,
        (Object v) => SemiSelectThemeData(
          spacingSelectDropdownInputPaddingBottom: v as double,
        ),
        (SemiResolvedSelectThemeData d) =>
            d.spacingSelectDropdownInputPaddingBottom,
        (SemiThemeData theme) => 8.0,
      ),
      (
        r'$spacing-select_dropdown_input_paddingRight: 12px',
        4.5,
        (Object v) => SemiSelectThemeData(
          spacingSelectDropdownInputPaddingRight: v as double,
        ),
        (SemiResolvedSelectThemeData d) =>
            d.spacingSelectDropdownInputPaddingRight,
        (SemiThemeData theme) => 12.0,
      ),
      (
        r'$spacing-select_dropdown_input_paddingLeft: 12px',
        4.5,
        (Object v) => SemiSelectThemeData(
          spacingSelectDropdownInputPaddingLeft: v as double,
        ),
        (SemiResolvedSelectThemeData d) =>
            d.spacingSelectDropdownInputPaddingLeft,
        (SemiThemeData theme) => 12.0,
      ),
      (
        r'$radius-select: var(--semi-border-radius-small)',
        4.5,
        (Object v) => SemiSelectThemeData(radiusSelect: v as double),
        (SemiResolvedSelectThemeData d) => d.radiusSelect,
        (SemiThemeData theme) => theme.radius.borderRadiusSmall.value,
      ),
      (
        r'$radius-select_option: 0px',
        4.5,
        (Object v) => SemiSelectThemeData(radiusSelectOption: v as double),
        (SemiResolvedSelectThemeData d) => d.radiusSelectOption,
        (SemiThemeData theme) => 0.0,
      ),
      (
        r'$font-select-fontWeight: $font-weight-regular',
        FontWeight.w900,
        (Object v) =>
            SemiSelectThemeData(fontSelectFontWeight: v as FontWeight),
        (SemiResolvedSelectThemeData d) => d.fontSelectFontWeight,
        (SemiThemeData theme) => theme.typography.fontWeightRegular,
      ),
      (
        r'$font-select_keyword-fontWeight: 600',
        FontWeight.w900,
        (Object v) =>
            SemiSelectThemeData(fontSelectKeywordFontWeight: v as FontWeight),
        (SemiResolvedSelectThemeData d) => d.fontSelectKeywordFontWeight,
        (SemiThemeData theme) => FontWeight.w600,
      ),
      (
        r'$font-select_prefix_suffix-fontWeight: $font-weight-bold',
        FontWeight.w900,
        (Object v) => SemiSelectThemeData(
          fontSelectPrefixSuffixFontWeight: v as FontWeight,
        ),
        (SemiResolvedSelectThemeData d) => d.fontSelectPrefixSuffixFontWeight,
        (SemiThemeData theme) => theme.typography.fontWeightBold,
      ),
      (
        r'$opacity-select_selection_text_inactive: 0.4',
        4.5,
        (Object v) => SemiSelectThemeData(
          opacitySelectSelectionTextInactive: v as double,
        ),
        (SemiResolvedSelectThemeData d) => d.opacitySelectSelectionTextInactive,
        (SemiThemeData theme) => 0.4,
      ),
      (
        r'$transition_duration-select-bg: var(--semi-transition_duration-none)',
        const Duration(milliseconds: 7),
        (Object v) =>
            SemiSelectThemeData(transitionDurationSelectBg: v as Duration),
        (SemiResolvedSelectThemeData d) => d.transitionDurationSelectBg,
        (SemiThemeData theme) => Duration.zero,
      ),
      (
        r'$transition_function-select-bg: var(--semi-transition_function-easeIn)',
        Curves.bounceIn,
        (Object v) =>
            SemiSelectThemeData(transitionFunctionSelectBg: v as Curve),
        (SemiResolvedSelectThemeData d) => d.transitionFunctionSelectBg,
        (SemiThemeData theme) => Curves.easeIn,
      ),
      (
        r'$transition_delay-select-bg: var(--semi-transition_delay-none)',
        const Duration(milliseconds: 7),
        (Object v) =>
            SemiSelectThemeData(transitionDelaySelectBg: v as Duration),
        (SemiResolvedSelectThemeData d) => d.transitionDelaySelectBg,
        (SemiThemeData theme) => Duration.zero,
      ),
      (
        r'$transition_duration-select-border: var(--semi-transition_duration-none)',
        const Duration(milliseconds: 7),
        (Object v) =>
            SemiSelectThemeData(transitionDurationSelectBorder: v as Duration),
        (SemiResolvedSelectThemeData d) => d.transitionDurationSelectBorder,
        (SemiThemeData theme) => Duration.zero,
      ),
      (
        r'$transition_function-select-border: var(--semi-transition_function-easeIn)',
        Curves.bounceIn,
        (Object v) =>
            SemiSelectThemeData(transitionFunctionSelectBorder: v as Curve),
        (SemiResolvedSelectThemeData d) => d.transitionFunctionSelectBorder,
        (SemiThemeData theme) => Curves.easeIn,
      ),
      (
        r'$transition_delay-select-border: var(--semi-transition_delay-none)',
        const Duration(milliseconds: 7),
        (Object v) =>
            SemiSelectThemeData(transitionDelaySelectBorder: v as Duration),
        (SemiResolvedSelectThemeData d) => d.transitionDelaySelectBorder,
        (SemiThemeData theme) => Duration.zero,
      ),
      (
        r'$transition_duration-select_option-bg: var(--semi-transition_duration-none)',
        const Duration(milliseconds: 7),
        (Object v) => SemiSelectThemeData(
          transitionDurationSelectOptionBg: v as Duration,
        ),
        (SemiResolvedSelectThemeData d) => d.transitionDurationSelectOptionBg,
        (SemiThemeData theme) => Duration.zero,
      ),
      (
        r'$transition_function-select_option-bg: var(--semi-transition_function-easeIn)',
        Curves.bounceIn,
        (Object v) =>
            SemiSelectThemeData(transitionFunctionSelectOptionBg: v as Curve),
        (SemiResolvedSelectThemeData d) => d.transitionFunctionSelectOptionBg,
        (SemiThemeData theme) => Curves.easeIn,
      ),
      (
        r'$transition_delay-select_option-bg: var(--semi-transition_delay-none)',
        const Duration(milliseconds: 7),
        (Object v) =>
            SemiSelectThemeData(transitionDelaySelectOptionBg: v as Duration),
        (SemiResolvedSelectThemeData d) => d.transitionDelaySelectOptionBg,
        (SemiThemeData theme) => Duration.zero,
      ),
    ];

    test('113 fields: merge, copyWith, resolve, equality, defaults', () {
      expect(fields, hasLength(113));
      expect(
        fields.where((f) => f.$1.startsWith(r'$transition_')),
        hasLength(9),
      );
      expect(
        fields.where((f) => !f.$1.startsWith(r'$transition_')),
        hasLength(104),
      );
      for (final (sass, value, make, read, expected) in fields) {
        final patch = make(value);
        expect(const SemiSelectThemeData().merge(patch), patch, reason: sass);
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
          read(const SemiSelectThemeData().resolve(light)),
          expected(light),
          reason: sass,
        );
        final dark = const SemiThemeData.dark();
        expect(
          read(const SemiSelectThemeData().resolve(dark)),
          expected(dark),
          reason: sass,
        );
      }
    });

    test('every field carries its Sass provenance in the generated source', () {
      final source = File('lib/src/theme/semi_select_theme_data.dart')
          .readAsStringSync();
      final names = <String>{};
      for (final (sass, _, _, _, _) in fields) {
        expect(source, contains(sass));
        names.add(sass.split(': ').first.substring(1));
      }
      expect(names, hasLength(113));
    });

    test('the 2 INTERNAL and 7 HARDCODES anchors live in the widget', () {
      final widgetSource = File('lib/src/components/semi_select.dart')
          .readAsStringSync();
      const anchors = [
        r'$transform_scale-select: var(--semi-transform_scale-none)',
        r'$transform_rotate-select-arrow: var(--semi-transform-rotate-none)',
        'max-height: 300px',
        'height: 20px',
        'padding: 4px',
        'font-size: 12px',
        'min-width: 50px',
        'border-bottom: 1px solid',
        'LIST_HEIGHT: 270',
      ];
      for (final anchor in anchors) {
        expect(widgetSource, contains(anchor), reason: anchor);
      }
    });

    test('type coverage: 49 Color + 52 double + 3 FontWeight + 6 Duration + '
        '3 Curve', () {
      final counts = <String, int>{};
      for (final (_, value, _, _, _) in fields) {
        counts.update(
          value.runtimeType.toString(),
          (n) => n + 1,
          ifAbsent: () => 1,
        );
      }
      expect(counts['Color'], 49);
      expect(counts['double'], 52);
      expect(counts['FontWeight'], 3);
      expect(counts['Duration'], 6);
      // Curves.bounceIn is a ParametricCurve.
      expect(fields.where((f) => f.$2 is Curve), hasLength(3));
    });

    test('SemiComponentThemes wiring', () {
      expect(const SemiComponentThemes().select, const SemiSelectThemeData());
      const patch = SemiSelectThemeData(
        colorSelectBgDefault: Color(0xff123456),
      );
      const themes = SemiComponentThemes(select: patch);
      expect(const SemiComponentThemes().copyWith(select: patch), themes);
      expect(themes == const SemiComponentThemes(), isFalse);
      expect(themes.select, patch);
    });

    testWidgets('SemiSelectTheme local patch applies to the trigger', (
      tester,
    ) async {
      await tester.pumpWidget(
        SemiTheme(
          data: const SemiThemeData.light(),
          child: SemiSelectTheme(
            data: const SemiSelectThemeData(
              colorSelectBgDefault: Color(0xff00ff00),
            ),
            child: Directionality(
              textDirection: TextDirection.ltr,
              child: Center(
                child: SemiSelectTheme(
                  data: const SemiSelectThemeData(radiusSelect: 20),
                  child: const SemiSelect(options: _flatOptions),
                ),
              ),
            ),
          ),
        ),
      );
      // Nested local patches merge; the inner patch wins its own field only.
      final box = tester.widget<DecoratedBox>(
        find
            .descendant(
              of: find.byType(SemiSelect),
              matching: find.byType(DecoratedBox),
            )
            .first,
      );
      final decoration = box.decoration as BoxDecoration;
      expect(decoration.color, const Color(0xff00ff00));
      expect(decoration.borderRadius, BorderRadius.circular(20));
    });
  });
}
