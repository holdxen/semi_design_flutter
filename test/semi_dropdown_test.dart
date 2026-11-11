import 'dart:io';

import 'package:flutter/gestures.dart';
// Only for the "renders without any Material dependency" assertion.
import 'package:flutter/material.dart' show MaterialApp;
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:semi_design_flutter/semi_design_flutter.dart';

const _kInnerPopup = Key('inner-popup');
const _kSiblingPopup = Key('sibling-popup');

/// Opaque box so taps always hit the trigger subtree. The box is keyed
/// `trigger-<label>` for geometry assertions.
Widget _trigger(String label) => Listener(
  behavior: HitTestBehavior.opaque,
  onPointerDown: (_) {},
  child: SizedBox(
    key: ValueKey('trigger-$label'),
    width: 56,
    height: 24,
    child: Center(child: Text(label)),
  ),
);

Finder _triggerBox(String label) => find.byKey(ValueKey('trigger-$label'));

Widget _app(Widget body, {TextDirection textDirection = TextDirection.ltr}) =>
    SemiTheme(
      data: const SemiThemeData.light(),
      child: Directionality(
        textDirection: textDirection,
        child: Overlay(
          initialEntries: [
            OverlayEntry(
              builder: (context) =>
                  Align(alignment: Alignment.center, child: body),
            ),
          ],
        ),
      ),
    );

/// Bounded frame pumping: menu open needs the overlay insert plus the first
/// position pass; nested popups mount one frame later.
Future<void> _settle(WidgetTester tester) async {
  for (var i = 0; i < 6; i++) {
    await tester.pump();
  }
}

SemiResolvedDropdownThemeData _resolve([SemiThemeData? theme]) =>
    const SemiDropdownThemeData().resolve(theme ?? const SemiThemeData.light());

/// The 12x12 icon/tick slot wrapper: `EdgeInsetsDirectional.only(end: 9)`.
bool _isIconPadding(Object? w) =>
    w is Padding && w.padding == const EdgeInsetsDirectional.only(end: 9.0);

void main() {
  final resolved = _resolve();

  group('menu rendering', () {
    testWidgets('renders items, titles and dividers', (tester) async {
      await tester.pumpWidget(
        _app(
          SemiDropdown(
            trigger: SemiTooltipTrigger.click,
            motion: false,
            menu: const [
              SemiDropdownTitleData('Group 1'),
              SemiDropdownItemData(name: 'Item A'),
              SemiDropdownDividerData(),
              SemiDropdownItemData(name: 'Item B'),
            ],
            child: _trigger('open'),
          ),
        ),
      );
      await tester.tap(find.text('open'));
      await _settle(tester);
      expect(find.text('Group 1'), findsOneWidget);
      expect(find.text('Item A'), findsOneWidget);
      expect(find.text('Item B'), findsOneWidget);
      expect(
        find.byWidgetPredicate((w) => w is SizedBox && w.height == 1),
        findsOneWidget,
      );
      // The wrapper surface: bg3, rounded, elevated shadow.
      final wrapper = tester.widget<DecoratedBox>(
        find
            .descendant(
              of: find.byType(SemiTooltipPopup),
              matching: find.byType(DecoratedBox),
            )
            .first,
      );
      final decoration = wrapper.decoration as BoxDecoration;
      expect(decoration.color, resolved.colorDropdownBgDefault);
      expect(
        decoration.borderRadius,
        BorderRadius.circular(resolved.radiusDropdown),
      );
      expect(decoration.boxShadow, hasLength(2));
    });

    testWidgets('an empty menu renders the empty shell', (tester) async {
      await tester.pumpWidget(
        _app(
          SemiDropdown(
            trigger: SemiTooltipTrigger.click,
            motion: false,
            menu: const [],
            child: _trigger('open'),
          ),
        ),
      );
      await tester.tap(find.text('open'));
      await _settle(tester);
      expect(find.byType(SemiTooltipPopup), findsOneWidget);
      expect(find.byType(SemiIcon), findsNothing);
    });

    testWidgets('an item name may be a Widget placed as-is', (tester) async {
      await tester.pumpWidget(
        _app(
          SemiDropdown(
            trigger: SemiTooltipTrigger.click,
            motion: false,
            menu: const [
              SemiDropdownItemData(name: SizedBox(width: 7, height: 3)),
            ],
            child: _trigger('open'),
          ),
        ),
      );
      await tester.tap(find.text('open'));
      await _settle(tester);
      expect(find.byType(SemiTooltipPopup), findsOneWidget);
      expect(
        find.descendant(
          of: find.byType(SemiTooltipPopup),
          matching: find.byWidgetPredicate(
            (w) => w is SizedBox && w.width == 7 && w.height == 3,
          ),
        ),
        findsOneWidget,
      );
    });
  });

  group('showTick', () {
    testWidgets('tick on active rows, transparent placeholder otherwise', (
      tester,
    ) async {
      await tester.pumpWidget(
        _app(
          SemiDropdown(
            trigger: SemiTooltipTrigger.click,
            motion: false,
            showTick: true,
            menu: const [
              SemiDropdownItemData(name: 'Item A'),
              SemiDropdownItemData(name: 'Item B', active: true),
              SemiDropdownItemData(name: 'Item C'),
            ],
            child: _trigger('open'),
          ),
        ),
      );
      await tester.tap(find.text('open'));
      await _settle(tester);
      expect(find.byType(SemiIcon), findsNWidgets(3));
      // Same 12x12 slot and same alignment for the tick and its placeholders.
      expect(find.byWidgetPredicate(_isIconPadding), findsNWidgets(3));
      final xs = <double>{
        for (final element in find.byWidgetPredicate(_isIconPadding).evaluate())
          tester.getTopLeft(find.byWidget(element.widget)).dx,
      };
      expect(xs, hasLength(1));
      final slots = [
        for (final element in find.byWidgetPredicate(_isIconPadding).evaluate())
          (element.widget as Padding).child! as SizedBox,
      ];
      for (final slot in slots) {
        expect(slot.width, 12);
        expect(slot.height, 12);
      }
      // Only the active row paints the tick; the placeholders are transparent.
      final colors = tester
          .widgetList<SemiIconTheme>(find.byType(SemiIconTheme))
          .map((t) => t.data.color)
          .toList();
      expect(colors.where((c) => c == const Color(0x00000000)), hasLength(2));
      expect(colors.where((c) => c == resolved.colorDropdownItemTextDefault), [
        resolved.colorDropdownItemTextDefault,
      ]);
    });

    testWidgets('item showTick applies when the group flag is null', (
      tester,
    ) async {
      await tester.pumpWidget(
        _app(
          SemiDropdown(
            trigger: SemiTooltipTrigger.click,
            motion: false,
            menu: const [
              SemiDropdownItemData(name: 'Item A', showTick: true),
              SemiDropdownItemData(name: 'Item B'),
            ],
            child: _trigger('open'),
          ),
        ),
      );
      await tester.tap(find.text('open'));
      await _settle(tester);
      expect(find.byType(SemiIcon), findsOneWidget);
    });

    testWidgets('the group flag wins over the item flag (context first)', (
      tester,
    ) async {
      await tester.pumpWidget(
        _app(
          SemiDropdown(
            trigger: SemiTooltipTrigger.click,
            motion: false,
            showTick: true,
            menu: const [
              SemiDropdownItemData(name: 'Item A', showTick: false),
              SemiDropdownItemData(name: 'Item B'),
            ],
            child: _trigger('open'),
          ),
        ),
      );
      await tester.tap(find.text('open'));
      await _settle(tester);
      expect(find.byType(SemiIcon), findsNWidgets(2));
    });

    testWidgets('a non-null group false also wins over the item flag', (
      tester,
    ) async {
      await tester.pumpWidget(
        _app(
          SemiDropdown(
            trigger: SemiTooltipTrigger.click,
            motion: false,
            showTick: false,
            menu: const [SemiDropdownItemData(name: 'Item A', showTick: true)],
            child: _trigger('open'),
          ),
        ),
      );
      await tester.tap(find.text('open'));
      await _settle(tester);
      expect(find.byType(SemiIcon), findsNothing);
    });
  });

  group('item visuals', () {
    testWidgets('type tiers and the null default color', (tester) async {
      const types = [
        null,
        SemiDropdownItemType.primary,
        SemiDropdownItemType.secondary,
        SemiDropdownItemType.tertiary,
        SemiDropdownItemType.warning,
        SemiDropdownItemType.danger,
      ];
      await tester.pumpWidget(
        _app(
          SemiDropdown(
            trigger: SemiTooltipTrigger.click,
            motion: false,
            menu: [
              for (final (i, type) in types.indexed)
                SemiDropdownItemData(name: 'item $i', type: type),
            ],
            child: _trigger('open'),
          ),
        ),
      );
      await tester.tap(find.text('open'));
      await _settle(tester);
      final expected = [
        resolved.colorDropdownItemTextDefault,
        resolved.colorDropdownItemPrimaryTextDefault,
        resolved.colorDropdownItemSecondaryTextDefault,
        resolved.colorDropdownItemTertiaryTextDefault,
        resolved.colorDropdownItemWarningTextDefault,
        resolved.colorDropdownItemDangerTextDefault,
      ];
      final labels = tester
          .widgetList<SemiText>(find.byType(SemiText))
          .toList();
      expect(labels, hasLength(types.length));
      for (var i = 0; i < labels.length; i++) {
        expect(labels[i].style?.color, expected[i], reason: 'type=${types[i]}');
      }
    });

    testWidgets('disabled rows are tinted, inert and unstyled', (tester) async {
      var taps = 0;
      await tester.pumpWidget(
        _app(
          SemiDropdown(
            trigger: SemiTooltipTrigger.click,
            motion: false,
            menu: [
              SemiDropdownItemData(
                name: 'Off',
                disabled: true,
                onTap: () => taps++,
              ),
              SemiDropdownItemData(name: 'On', onTap: () => taps++),
            ],
            child: _trigger('open'),
          ),
        ),
      );
      await tester.tap(find.text('open'));
      await _settle(tester);
      final labels = tester
          .widgetList<SemiText>(find.byType(SemiText))
          .toList();
      expect(
        labels.first.style?.color,
        resolved.colorDropdownItemDisabledTextDefault,
      );
      final boxes = tester
          .widgetList<AnimatedContainer>(find.byType(AnimatedContainer))
          .map((w) => w.decoration as BoxDecoration)
          .toList();
      expect(boxes.first.color, resolved.colorDropdownItemDisabledBgDefault);

      await tester.tap(find.text('Off'));
      await tester.pump();
      expect(taps, 0);
      await tester.tap(find.text('On'));
      await tester.pump();
      expect(taps, 1);
    });

    testWidgets('active rows are bold', (tester) async {
      await tester.pumpWidget(
        _app(
          SemiDropdown(
            trigger: SemiTooltipTrigger.click,
            motion: false,
            menu: const [SemiDropdownItemData(name: 'Item A', active: true)],
            child: _trigger('open'),
          ),
        ),
      );
      await tester.tap(find.text('open'));
      await _settle(tester);
      final label = tester.widget<SemiText>(find.byType(SemiText));
      expect(label.weight, resolved.fontDropdownItemActiveFontWeight);
    });

    testWidgets('the icon sits in a 12x12 slot with a 9 gap', (tester) async {
      await tester.pumpWidget(
        _app(
          SemiDropdown(
            trigger: SemiTooltipTrigger.click,
            motion: false,
            menu: const [
              SemiDropdownItemData(name: 'Item A', icon: IconPlaceholder()),
            ],
            child: _trigger('open'),
          ),
        ),
      );
      await tester.tap(find.text('open'));
      await _settle(tester);
      expect(find.byType(IconPlaceholder), findsOneWidget);
      final padding = tester.widget<Padding>(
        find.byWidgetPredicate(_isIconPadding),
      );
      final slot = padding.child! as SizedBox;
      expect(slot.width, 12);
      expect(slot.height, 12);
    });

    testWidgets('rows cap at width 280 and long labels wrap', (tester) async {
      await tester.pumpWidget(
        _app(
          SemiDropdown(
            trigger: SemiTooltipTrigger.click,
            motion: false,
            menu: [SemiDropdownItemData(name: 'L ${'ong ' * 20}label')],
            child: _trigger('open'),
          ),
        ),
      );
      await tester.tap(find.text('open'));
      await _settle(tester);
      expect(
        find.byWidgetPredicate(
          (w) => w is ConstrainedBox && w.constraints.maxWidth == 280,
        ),
        findsOneWidget,
      );
      expect(tester.takeException(), isNull);
    });

    testWidgets('title uses the small text size and withTick padding', (
      tester,
    ) async {
      await tester.pumpWidget(
        _app(
          SemiDropdown(
            trigger: SemiTooltipTrigger.click,
            motion: false,
            showTick: true,
            menu: const [SemiDropdownTitleData('Group 1')],
            child: _trigger('open'),
          ),
        ),
      );
      await tester.tap(find.text('open'));
      await _settle(tester);
      final title = tester.widget<SemiText>(find.byType(SemiText));
      expect(title.style?.fontSize, 12);
      expect(title.style?.color, resolved.colorDropdownTitleTextDefault);
      expect(
        find.byWidgetPredicate(
          (w) =>
              w is Padding &&
              w.padding ==
                  EdgeInsetsDirectional.only(
                    top: resolved.spacingDropdownTitlePaddingTop,
                    bottom: resolved.spacingDropdownTitlePaddingBottom,
                    start: resolved.spacingDropdownTitleWithTickPaddingLeft,
                    end: resolved.spacingDropdownTitlePaddingRight,
                  ),
        ),
        findsOneWidget,
      );
    });
  });

  group('triggers and visibility', () {
    testWidgets('hover shows after 50ms and hides after the 100ms leave', (
      tester,
    ) async {
      await tester.pumpWidget(
        _app(
          SemiDropdown(
            motion: false,
            menu: const [SemiDropdownItemData(name: 'Item A')],
            child: _trigger('open'),
          ),
        ),
      );
      final gesture = await tester.createGesture(kind: PointerDeviceKind.mouse);
      await gesture.addPointer(location: Offset.zero);
      addTearDown(gesture.removePointer);
      await gesture.moveTo(tester.getCenter(_triggerBox('open')));
      await tester.pump(const Duration(milliseconds: 49));
      expect(find.byType(SemiTooltipPopup), findsNothing);
      await tester.pump(const Duration(milliseconds: 1));
      await _settle(tester);
      expect(find.byType(SemiTooltipPopup), findsOneWidget);

      await gesture.moveTo(const Offset(5, 595));
      await tester.pump(const Duration(milliseconds: 99));
      expect(find.byType(SemiTooltipPopup), findsOneWidget);
      await tester.pump(const Duration(milliseconds: 1));
      await tester.pump();
      expect(find.byType(SemiTooltipPopup), findsNothing);
    });

    testWidgets('click toggles the popup and outside taps close it', (
      tester,
    ) async {
      await tester.pumpWidget(
        _app(
          SemiDropdown(
            trigger: SemiTooltipTrigger.click,
            motion: false,
            menu: const [SemiDropdownItemData(name: 'Item A')],
            child: _trigger('open'),
          ),
        ),
      );
      await tester.tap(find.text('open'));
      await _settle(tester);
      expect(find.byType(SemiTooltipPopup), findsOneWidget);
      await tester.tapAt(const Offset(5, 5));
      await tester.pump();
      await tester.pump();
      expect(find.byType(SemiTooltipPopup), findsNothing);
    });

    testWidgets('focus shows and blur hides', (tester) async {
      final node = FocusNode();
      addTearDown(node.dispose);
      await tester.pumpWidget(
        _app(
          SemiDropdown(
            trigger: SemiTooltipTrigger.focus,
            motion: false,
            menu: const [SemiDropdownItemData(name: 'Item A')],
            child: Focus(focusNode: node, child: _trigger('open')),
          ),
        ),
      );
      node.requestFocus();
      await tester.pump(const Duration(milliseconds: 50));
      await _settle(tester);
      expect(find.byType(SemiTooltipPopup), findsOneWidget);
      node.unfocus();
      // Blur hides through the 100ms mouseLeaveDelay.
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump();
      expect(find.byType(SemiTooltipPopup), findsNothing);
    });

    testWidgets('custom only shows from visible', (tester) async {
      await tester.pumpWidget(
        _app(
          SemiDropdown(
            trigger: SemiTooltipTrigger.custom,
            visible: true,
            motion: false,
            menu: const [SemiDropdownItemData(name: 'Item A')],
            child: _trigger('open'),
          ),
        ),
      );
      await _settle(tester);
      expect(find.byType(SemiTooltipPopup), findsOneWidget);
    });

    testWidgets('contextMenu opens on secondary tap', (tester) async {
      await tester.pumpWidget(
        _app(
          SemiDropdown(
            trigger: SemiTooltipTrigger.contextMenu,
            motion: false,
            menu: const [SemiDropdownItemData(name: 'Item A')],
            child: _trigger('open'),
          ),
        ),
      );
      await tester.tap(
        find.text('open'),
        buttons: kSecondaryMouseButton,
        warnIfMissed: false,
      );
      await _settle(tester);
      expect(find.byType(SemiTooltipPopup), findsOneWidget);
    });

    testWidgets('visible non-null is fully controlled; events only notify', (
      tester,
    ) async {
      final log = <bool>[];
      final visible = ValueNotifier<bool>(false);
      await tester.pumpWidget(
        _app(
          ValueListenableBuilder<bool>(
            valueListenable: visible,
            builder: (context, value, _) => SemiDropdown(
              trigger: SemiTooltipTrigger.click,
              visible: value,
              motion: false,
              onVisibleChange: log.add,
              menu: const [SemiDropdownItemData(name: 'Item A')],
              child: _trigger('open'),
            ),
          ),
        ),
      );
      await tester.tap(find.text('open'));
      await _settle(tester);
      expect(find.byType(SemiTooltipPopup), findsNothing);
      expect(log, [true]);

      visible.value = true;
      await _settle(tester);
      expect(find.byType(SemiTooltipPopup), findsOneWidget);
      await tester.tapAt(const Offset(5, 5));
      await tester.pump();
      expect(find.byType(SemiTooltipPopup), findsOneWidget);
      expect(log, [true, false]);
    });

    testWidgets('closeOnEsc defaults to true and Escape closes', (
      tester,
    ) async {
      await tester.pumpWidget(
        _app(
          SemiDropdown(
            trigger: SemiTooltipTrigger.click,
            motion: false,
            menu: const [SemiDropdownItemData(name: 'Item A')],
            child: _trigger('open'),
          ),
        ),
      );
      await tester.tap(find.text('open'));
      await _settle(tester);
      expect(find.byType(SemiTooltipPopup), findsOneWidget);
      await tester.sendKeyEvent(LogicalKeyboardKey.escape);
      await tester.pump();
      await tester.pump();
      expect(find.byType(SemiTooltipPopup), findsNothing);
    });

    testWidgets('closeOnEsc false keeps the popup open', (tester) async {
      await tester.pumpWidget(
        _app(
          SemiDropdown(
            trigger: SemiTooltipTrigger.click,
            closeOnEsc: false,
            motion: false,
            menu: const [SemiDropdownItemData(name: 'Item A')],
            child: _trigger('open'),
          ),
        ),
      );
      await tester.tap(find.text('open'));
      await _settle(tester);
      await tester.sendKeyEvent(LogicalKeyboardKey.escape);
      await tester.pump();
      expect(find.byType(SemiTooltipPopup), findsOneWidget);
    });

    testWidgets('spacing defaults to 4 from the trigger', (tester) async {
      await tester.pumpWidget(
        _app(
          SemiDropdown(
            trigger: SemiTooltipTrigger.click,
            motion: false,
            menu: const [SemiDropdownItemData(name: 'Item A')],
            child: _trigger('open'),
          ),
        ),
      );
      await tester.tap(find.text('open'));
      await _settle(tester);
      final triggerRect = tester.getRect(_triggerBox('open'));
      final popupRect = tester.getRect(find.byType(SemiTooltipPopup));
      expect(popupRect.top - triggerRect.bottom, 4);
    });

    testWidgets('clickToHide closes on popup taps', (tester) async {
      await tester.pumpWidget(
        _app(
          SemiDropdown(
            trigger: SemiTooltipTrigger.click,
            clickToHide: true,
            motion: false,
            menu: const [SemiDropdownItemData(name: 'Item A')],
            child: _trigger('open'),
          ),
        ),
      );
      await tester.tap(find.text('open'));
      await _settle(tester);
      await tester.tap(find.byType(SemiTooltipPopup), warnIfMissed: false);
      await tester.pump();
      await tester.pump();
      expect(find.byType(SemiTooltipPopup), findsNothing);
    });

    testWidgets('onVisibleChange reports open and close', (tester) async {
      final log = <bool>[];
      await tester.pumpWidget(
        _app(
          SemiDropdown(
            trigger: SemiTooltipTrigger.click,
            motion: false,
            onVisibleChange: log.add,
            menu: const [SemiDropdownItemData(name: 'Item A')],
            child: _trigger('open'),
          ),
        ),
      );
      await tester.tap(find.text('open'));
      await _settle(tester);
      await tester.tapAt(const Offset(5, 5));
      await tester.pump();
      await tester.pump();
      expect(log, [true, false]);
    });
  });

  group('nested dropdowns', () {
    const kParentBody = Key('parent-body');

    /// Parent dropdown with a nested child dropdown in its content. Provide
    /// exactly one of [childBody]/[childMenu]. The parent body is a one-glyph
    /// marker: the test font renders glyphs as squares, so a long label would
    /// widen the parent popup over the sibling popup positions.
    Widget nestedTree({Widget? childBody, List<SemiDropdownNode>? childMenu}) =>
        SemiDropdown(
          trigger: SemiTooltipTrigger.click,
          motion: false,
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('P', key: kParentBody),
              SemiDropdown(
                trigger: SemiTooltipTrigger.click,
                motion: false,
                menu: childMenu,
                content: childBody,
                child: _trigger('child'),
              ),
            ],
          ),
          child: _trigger('parent'),
        );

    testWidgets('clicking a child popup keeps the parent open', (tester) async {
      await tester.pumpWidget(
        _app(
          nestedTree(
            childBody: const SizedBox(key: _kInnerPopup, width: 80, height: 40),
          ),
        ),
      );
      await tester.tap(find.text('parent'));
      await _settle(tester);
      await tester.tap(find.text('child'));
      await _settle(tester);
      expect(find.byType(SemiTooltipPopup), findsNWidgets(2));
      // The bare child body falls through to the parent barrier: the
      // registered child rect keeps the parent open.
      await tester.tapAt(tester.getCenter(find.byKey(_kInnerPopup)));
      await tester.pump();
      expect(find.byKey(kParentBody), findsOneWidget);
    });

    testWidgets('clicking a child menu item keeps the parent open', (
      tester,
    ) async {
      var taps = 0;
      await tester.pumpWidget(
        _app(
          nestedTree(
            childMenu: [
              SemiDropdownItemData(name: 'Leaf', onTap: () => taps++),
            ],
          ),
        ),
      );
      await tester.tap(find.text('parent'));
      await _settle(tester);
      await tester.tap(find.text('child'));
      await _settle(tester);
      await tester.tap(find.text('Leaf'));
      await tester.pump();
      expect(taps, 1);
      expect(find.byKey(kParentBody), findsOneWidget);
    });

    testWidgets('clicking a sibling popup closes the parent', (tester) async {
      await tester.pumpWidget(
        _app(
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              nestedTree(
                childBody: const SizedBox(
                  key: _kInnerPopup,
                  width: 80,
                  height: 40,
                ),
              ),
              SemiDropdown(
                trigger: SemiTooltipTrigger.custom,
                visible: true,
                motion: false,
                content: const SizedBox(
                  key: _kSiblingPopup,
                  width: 80,
                  height: 40,
                ),
                child: _trigger('sibling'),
              ),
            ],
          ),
        ),
      );
      await _settle(tester);
      await tester.tap(find.text('parent'));
      await _settle(tester);
      await tester.tap(find.text('child'));
      await _settle(tester);
      expect(find.byKey(kParentBody), findsOneWidget);
      // The sibling popup is outside the parent's scope chain: not exempt.
      await tester.tapAt(tester.getCenter(find.byKey(_kSiblingPopup)));
      await tester.pump();
      await tester.pump();
      expect(find.byKey(kParentBody), findsNothing);
    });

    testWidgets('nested spacing defaults to 2', (tester) async {
      await tester.pumpWidget(
        _app(
          nestedTree(
            childBody: const SizedBox(key: _kInnerPopup, width: 80, height: 40),
          ),
        ),
      );
      await tester.tap(find.text('parent'));
      await _settle(tester);
      await tester.tap(find.text('child'));
      await _settle(tester);
      final triggerRect = tester.getRect(_triggerBox('child'));
      final popupRect = tester.getRect(find.byKey(_kInnerPopup));
      expect(popupRect.top - triggerRect.bottom, 2);
    });
  });

  group('keyboard', () {
    testWidgets('Enter and Space activate the highlighted row', (tester) async {
      final hits = <String>[];
      await tester.pumpWidget(
        _app(
          SemiDropdown(
            trigger: SemiTooltipTrigger.click,
            motion: false,
            menu: [
              SemiDropdownItemData(name: 'A', onTap: () => hits.add('A')),
              SemiDropdownItemData(name: 'B', onTap: () => hits.add('B')),
            ],
            child: _trigger('open'),
          ),
        ),
      );
      await tester.tap(find.text('open'));
      await _settle(tester);
      // The click trigger highlights the first enabled row.
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      expect(hits, ['A']);
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
      await tester.sendKeyEvent(LogicalKeyboardKey.space);
      expect(hits, ['A', 'B']);
    });

    testWidgets('arrows cycle the highlight and wrap around', (tester) async {
      final hits = <String>[];
      await tester.pumpWidget(
        _app(
          SemiDropdown(
            trigger: SemiTooltipTrigger.click,
            motion: false,
            menu: [
              for (final name in ['A', 'B', 'C'])
                SemiDropdownItemData(name: name, onTap: () => hits.add(name)),
            ],
            child: _trigger('open'),
          ),
        ),
      );
      await tester.tap(find.text('open'));
      await _settle(tester);
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowUp);
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      expect(hits, ['C']);
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      expect(hits, ['C', 'A']);
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      expect(hits, ['C', 'A', 'B']);
    });

    testWidgets('disabled rows are skipped', (tester) async {
      final hits = <String>[];
      await tester.pumpWidget(
        _app(
          SemiDropdown(
            trigger: SemiTooltipTrigger.click,
            motion: false,
            menu: [
              SemiDropdownItemData(name: 'A', onTap: () => hits.add('A')),
              SemiDropdownItemData(
                name: 'B',
                disabled: true,
                onTap: () => hits.add('B'),
              ),
              SemiDropdownItemData(name: 'C', onTap: () => hits.add('C')),
            ],
            child: _trigger('open'),
          ),
        ),
      );
      await tester.tap(find.text('open'));
      await _settle(tester);
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      expect(hits, ['C']);
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      expect(hits, ['C', 'A']);
    });

    testWidgets('typeahead jumps to the first row starting with a character', (
      tester,
    ) async {
      final hits = <String>[];
      await tester.pumpWidget(
        _app(
          SemiDropdown(
            trigger: SemiTooltipTrigger.click,
            motion: false,
            menu: [
              for (final name in ['Alpha', 'Bravo', 'Charlie'])
                SemiDropdownItemData(name: name, onTap: () => hits.add(name)),
            ],
            child: _trigger('open'),
          ),
        ),
      );
      await tester.tap(find.text('open'));
      await _settle(tester);
      await tester.sendKeyEvent(LogicalKeyboardKey.keyC);
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      expect(hits, ['Charlie']);
      // Wraps around the end back to the first match.
      await tester.sendKeyEvent(LogicalKeyboardKey.keyA);
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      expect(hits, ['Charlie', 'Alpha']);
    });

    testWidgets('keyboard highlight scrolls rows into view', (tester) async {
      await tester.pumpWidget(
        _app(
          SizedBox(
            height: 120,
            width: 200,
            child: SemiDropdown(
              trigger: SemiTooltipTrigger.click,
              motion: false,
              menu: [
                for (var i = 0; i < 12; i++)
                  SemiDropdownItemData(name: 'item $i'),
              ],
              child: _trigger('open'),
            ),
          ),
        ),
      );
      await tester.tap(find.text('open'));
      await _settle(tester);
      for (var i = 0; i < 11; i++) {
        await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
      }
      await tester.pump();
      await tester.pump();
      expect(tester.takeException(), isNull);
    });
  });

  group('motion and edge layout', () {
    testWidgets('motion false opens and closes instantly', (tester) async {
      await tester.pumpWidget(
        _app(
          SemiDropdown(
            trigger: SemiTooltipTrigger.click,
            motion: false,
            menu: const [SemiDropdownItemData(name: 'Item A')],
            child: _trigger('open'),
          ),
        ),
      );
      await tester.tap(find.text('open'));
      await _settle(tester);
      expect(find.byType(SemiTooltipPopup), findsOneWidget);
      await tester.tapAt(const Offset(5, 5));
      await tester.pump();
      expect(find.byType(SemiTooltipPopup), findsNothing);
    });

    testWidgets('a show requested during the hide animation is replayed', (
      tester,
    ) async {
      final visible = ValueNotifier<bool>(true);
      await tester.pumpWidget(
        _app(
          ValueListenableBuilder<bool>(
            valueListenable: visible,
            builder: (context, value, _) => SemiDropdown(
              trigger: SemiTooltipTrigger.custom,
              visible: value,
              menu: const [SemiDropdownItemData(name: 'Item A')],
              child: _trigger('open'),
            ),
          ),
        ),
      );
      await _settle(tester);
      await tester.pump(const Duration(milliseconds: 150));
      expect(find.byType(SemiTooltipPopup), findsOneWidget);

      visible.value = false;
      await tester.pump(); // hide animation starts
      visible.value = true;
      await tester.pump(); // parked as pending show
      await tester.pump(const Duration(milliseconds: 150));
      await tester.pump();
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 150));
      expect(find.byType(SemiTooltipPopup), findsOneWidget);
    });

    testWidgets('RTL mirrors the tick slot', (tester) async {
      await tester.pumpWidget(
        _app(
          SemiDropdown(
            trigger: SemiTooltipTrigger.click,
            motion: false,
            showTick: true,
            menu: const [SemiDropdownItemData(name: 'Item A', active: true)],
            child: _trigger('open'),
          ),
          textDirection: TextDirection.rtl,
        ),
      );
      await tester.tap(find.text('open'));
      await _settle(tester);
      final slot = find.byWidgetPredicate(_isIconPadding);
      expect(slot, findsOneWidget);
      expect(
        tester.getTopLeft(slot).dx,
        greaterThan(tester.getCenter(find.text('Item A')).dx),
      );
    });

    testWidgets('narrow viewports wrap without overflowing', (tester) async {
      final previousSize = tester.view.physicalSize;
      final previousRatio = tester.view.devicePixelRatio;
      addTearDown(() {
        tester.view.physicalSize = previousSize;
        tester.view.devicePixelRatio = previousRatio;
      });
      tester.view.physicalSize = const Size(240, 400);
      tester.view.devicePixelRatio = 1;
      await tester.pumpWidget(
        _app(
          SemiDropdown(
            trigger: SemiTooltipTrigger.click,
            motion: false,
            menu: [SemiDropdownItemData(name: 'L ${'ong ' * 20}label')],
            child: _trigger('open'),
          ),
        ),
      );
      await tester.tap(find.text('open'));
      await _settle(tester);
      expect(find.byType(SemiTooltipPopup), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('an unbounded trigger context still opens the popup', (
      tester,
    ) async {
      await tester.pumpWidget(
        _app(
          UnconstrainedBox(
            child: SemiDropdown(
              trigger: SemiTooltipTrigger.click,
              motion: false,
              menu: const [SemiDropdownItemData(name: 'Item A')],
              child: _trigger('open'),
            ),
          ),
        ),
      );
      await tester.tap(find.text('open'));
      await _settle(tester);
      expect(find.byType(SemiTooltipPopup), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('text scaling keeps the menu intact', (tester) async {
      await tester.pumpWidget(
        _app(
          MediaQuery(
            data: const MediaQueryData(textScaler: TextScaler.linear(2)),
            child: SemiDropdown(
              trigger: SemiTooltipTrigger.click,
              motion: false,
              menu: const [
                SemiDropdownTitleData('Group 1'),
                SemiDropdownItemData(name: 'Item A'),
                SemiDropdownDividerData(),
                SemiDropdownItemData(name: 'Item B'),
              ],
              child: _trigger('open'),
            ),
          ),
        ),
      );
      await tester.tap(find.text('open'));
      await _settle(tester);
      expect(find.byType(SemiTooltipPopup), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('renders without any Material dependency', (tester) async {
      await tester.pumpWidget(
        _app(
          SemiDropdown(
            trigger: SemiTooltipTrigger.click,
            motion: false,
            menu: const [SemiDropdownItemData(name: 'Item A')],
            child: _trigger('open'),
          ),
        ),
      );
      await tester.tap(find.text('open'));
      await _settle(tester);
      expect(find.byType(SemiTooltipPopup), findsOneWidget);
      expect(find.byType(MaterialApp), findsNothing);
    });
  });

  group('theme', () {
    test('36 fields default to their Sass sources', () {
      const theme = SemiThemeData.light();
      final r = _resolve(theme);
      expect(r.radiusDropdown, theme.radius.borderRadiusMedium.value);
      expect(r.radiusDropdownItem, 0);
      expect(r.colorDropdownBgDefault, theme.colors.colorBg3);
      expect(r.colorDropdownTitleTextDefault, theme.colors.colorText2);
      expect(r.spacingDropdownMenuPaddingY, 4);
      expect(r.spacingDropdownMenuPaddingX, 0);
      expect(r.spacingDropdownTitlePaddingTop, 8);
      expect(r.spacingDropdownTitlePaddingBottom, 4);
      expect(r.spacingDropdownTitlePaddingLeft, 16);
      expect(r.spacingDropdownTitlePaddingRight, 16);
      expect(r.spacingDropdownTitleWithTickPaddingLeft, 31);
      expect(r.spacingDropdownItemWithTickPaddingLeft, 12);
      expect(r.spacingDropdownItemPaddingY, 8);
      expect(r.spacingDropdownItemPaddingX, 16);
      expect(r.colorDropdownItemTextDefault, theme.colors.colorText0);
      expect(r.colorDropdownItemBgHover, theme.colors.colorFill0);
      expect(r.colorDropdownItemBgActive, theme.colors.colorFill1);
      expect(r.colorDropdownItemDangerTextDefault, theme.colors.colorDanger);
      expect(
        r.colorDropdownItemSecondaryTextDefault,
        theme.colors.colorSecondary,
      );
      expect(r.colorDropdownItemWarningTextDefault, theme.colors.colorWarning);
      expect(
        r.colorDropdownItemTertiaryTextDefault,
        theme.colors.colorTertiary,
      );
      expect(r.colorDropdownItemPrimaryTextDefault, theme.colors.colorPrimary);
      expect(
        r.colorDropdownItemDisabledTextDefault,
        theme.colors.colorDisabledText,
      );
      expect(r.colorDropdownItemDisabledBgDefault, const Color(0x00000000));
      expect(r.colorDropdownSeperatorBgDefault, theme.colors.colorBorder);
      expect(r.spacingDropdownIconMarginRight, 9);
      expect(r.spacingDropdownSeperatorMarginY, 4);
      expect(r.spacingDropdownSeperatorMarginX, 0);
      expect(r.widthDropdown, 280);
      expect(r.sizeDropdownIconWidth, 12);
      expect(r.sizeDropdownIconHeight, 12);
      expect(r.heightDropdownSeperator, 1);
      expect(
        r.fontDropdownItemActiveFontWeight,
        theme.typography.fontWeightBold,
      );
      expect(r.animationDuration, Duration.zero);
      expect(r.animationCurve, Curves.easeOut);
      expect(r.animationDelay, Duration.zero);
    });

    test('copyWith overrides only the given fields', () {
      const base = SemiDropdownThemeData();
      final updated = base.copyWith(colorDropdownBgDefault: Color(0xff00ff00));
      expect(updated.colorDropdownBgDefault, const Color(0xff00ff00));
      expect(updated.widthDropdown, base.widthDropdown);
    });

    test('merge keeps the original for null and lets the other win', () {
      const a = SemiDropdownThemeData(widthDropdown: 100);
      const b = SemiDropdownThemeData(
        widthDropdown: 200,
        spacingDropdownItemPaddingX: 3,
      );
      expect(a.merge(null), a);
      expect(a.merge(b).widthDropdown, 200);
      expect(a.merge(b).spacingDropdownItemPaddingX, 3);
    });

    test('equality and hashCode are value based', () {
      const a = SemiDropdownThemeData(animationCurve: Curves.easeOut);
      const b = SemiDropdownThemeData(animationCurve: Curves.easeOut);
      const c = SemiDropdownThemeData(widthDropdown: 1);
      expect(a, b);
      expect(a.hashCode, b.hashCode);
      expect(a == c, isFalse);
    });

    test('every theme field carries its Sass provenance', () {
      final theme = File('lib/src/theme/semi_dropdown_theme_data.dart')
          .readAsStringSync();
      final widget = File('lib/src/components/semi_dropdown.dart')
          .readAsStringSync();
      for (final declaration in [
        r'$radius-dropdown: var(--semi-border-radius-medium)',
        r'$radius-dropdown_item: 0px',
        r'$color-dropdown-bg-default: var(--semi-color-bg-3)',
        r'$color-dropdown_title-text-default: var(--semi-color-text-2)',
        r'$spacing-dropdown_menu-paddingY: $spacing-extra-tight',
        r'$spacing-dropdown_menu-paddingX: 0',
        r'$spacing-dropdown_title-paddingTop: $spacing-tight',
        r'$spacing-dropdown_title-paddingBottom: $spacing-extra-tight',
        r'$spacing-dropdown_title-paddingLeft: $spacing-base',
        r'$spacing-dropdown_title-paddingRight: $spacing-base',
        r'$spacing-dropdown_title_withTick-paddingLeft: 31px',
        r'$spacing-dropdown_item_withTick-paddingLeft: $spacing-base-tight',
        r'$spacing-dropdown_item-paddingY: $spacing-tight',
        r'$spacing-dropdown_item-paddingX: $spacing-base',
        r'$color-dropdown_item-text-default: var(--semi-color-text-0)',
        r'$color-dropdown_item-bg-hover: var(--semi-color-fill-0)',
        r'$color-dropdown_item-bg-active: var(--semi-color-fill-1)',
        r'$color-dropdown_item_danger-text-default: var(--semi-color-danger)',
        r'$color-dropdown_item_secondary-text-default: var(--semi-color-secondary)',
        r'$color-dropdown_item_warning-text-default: var(--semi-color-warning)',
        r'$color-dropdown_item_tertiary-text-default: var(--semi-color-tertiary)',
        r'$color-dropdown_item_primary-text-default: var(--semi-color-primary)',
        r'$color-dropdown_item_disabled-text-default: var(--semi-color-disabled-text)',
        r'$color-dropdown_item_disabled-bg-default: transparent',
        r'$color-dropdown_seperator-bg-default: var(--semi-color-border)',
        r'$spacing-dropdown_icon-marginRight: 9px',
        r'$spacing-dropdown_seperator-marginY: $spacing-extra-tight',
        r'$spacing-dropdown_seperator-marginX: 0',
        r'$width-dropdown: 280px',
        r'$size-dropdown-icon-width: 12px',
        r'$size-dropdown-icon-height: 12px',
        r'$height-dropdown_seperator: 1px',
        r'$font-dropdown_item_active-fontWeight: 600',
        r'$transition_duration-dropdown_item-bg: var(--semi-transition_duration-none)',
        r'$transition_function-dropdown_item-bg: var(--semi-transition_function-easeOut)',
        r'$transition_delay-dropdown_item-bg: 0ms',
      ]) {
        expect(theme, contains(declaration));
      }
      expect(widget, contains(r'$filter-dropdown-bg: none'));
    });

    testWidgets('a local patch applies and captures across the overlay', (
      tester,
    ) async {
      const patched = Color(0xff876543);
      await tester.pumpWidget(
        _app(
          SemiDropdownTheme(
            data: const SemiDropdownThemeData(colorDropdownBgDefault: patched),
            child: SemiDropdown(
              trigger: SemiTooltipTrigger.click,
              motion: false,
              content: Builder(
                builder: (context) => Text(
                  SemiDropdownTheme.resolve(context).colorDropdownBgDefault ==
                          patched
                      ? 'patched'
                      : 'default',
                ),
              ),
              child: _trigger('open'),
            ),
          ),
        ),
      );
      await tester.tap(find.text('open'));
      await _settle(tester);
      expect(find.text('patched'), findsOneWidget);
    });
  });
}

/// Stand-in icon body (any widget works in the icon slot).
class IconPlaceholder extends StatelessWidget {
  const IconPlaceholder({super.key});

  @override
  Widget build(BuildContext context) => const SizedBox.expand();
}
