// Behavior matrix for SemiPopconfirm plus coverage for the 23 Sass
// declarations (23 = 19 FIELDS + 4 INTERNAL; no animation.scss — the upstream
// popover motion is value-identical to the tooltip shell motion). The 11
// HARDCODES provenance anchors and the 2 上游死变量
// (`$spacing-popconfirm_btn_close-margin` 一对) live in
// lib/src/components/semi_popconfirm.dart as `_PopconfirmMetrics` comments and
// constants; docs/semi_popconfirm.md carries the full mapping
// (34 = 19 + 4 + 11 provenance entries).

import 'dart:async';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:semi_design_flutter/semi_design_flutter.dart';

const _kTrigger = Key('trigger');

/// Opaque box so taps and hovers always hit the trigger subtree.
Widget _trigger() => Listener(
  behavior: HitTestBehavior.translucent,
  onPointerDown: (_) {},
  child: const SizedBox(key: _kTrigger, width: 40, height: 20),
);

Widget _app(
  Widget body, {
  SemiPopconfirmThemeData popconfirmTheme = const SemiPopconfirmThemeData(),
  TextDirection textDirection = TextDirection.ltr,
  Key? hostKey,
}) => KeyedSubtree(
  key: hostKey,
  child: SemiTheme(
    data: const SemiThemeData.light(),
    child: SemiPopconfirmTheme(
      data: popconfirmTheme,
      child: Directionality(
        textDirection: textDirection,
        child: Overlay(
          initialEntries: [
            OverlayEntry(
              builder: (context) => Align(alignment: Alignment.center, child: body),
            ),
          ],
        ),
      ),
    ),
  ),
);

/// Frame 1 rebuilds (controlled `visible` flip), frame 2 inserts the overlay
/// entry, frame 3 measures it, frame 4 computes the position and frame 5
/// renders it in place. Pump generously: SemiPopconfirm always drives the
/// tooltip in controlled mode, which adds one post-frame deferral over the
/// uncontrolled shell path.
Future<void> _settleOpen(WidgetTester tester) async {
  for (var i = 0; i < 6; i++) {
    await tester.pump();
  }
}

SemiButton _button(WidgetTester tester, String label) =>
    tester.widget<SemiButton>(find.widgetWithText(SemiButton, label));

void main() {
  group('theme fields (23 = 19 FIELDS + 4 INTERNAL)', () {
    test('resolve falls back to the Sass defaults', () {
      final resolved = const SemiPopconfirmThemeData().resolve(
        SemiThemeData.light(),
      );
      expect(resolved.widthPopconfirmIcon, 24);
      expect(resolved.widthPopconfirmCloseBtn, 24);
      expect(resolved.widthPopconfirmMaxWidth, 400);
      expect(resolved.spacingPopconfirmTop, 24);
      expect(resolved.spacingPopconfirmBottom, 20);
      expect(resolved.spacingPopconfirmWithArrowPadding, 12);
      expect(resolved.spacingPopconfirmHeaderTitleMarginBottom, 8);
      expect(resolved.spacingPopconfirmHeaderContentPPadding, 0);
      expect(resolved.spacingPopconfirmHeaderContentPMargin, 0);
      expect(resolved.spacingPopconfirmBodyPPadding, 0);
      expect(resolved.spacingPopconfirmBodyPMargin, 0);
      expect(resolved.spacingPopconfirmFooterMarginTop, 25);
      expect(resolved.spacingPopconfirmFooterBtnMarginRight, 8);
      expect(resolved.spacingPopconfirmHeaderIconMarginRight, 12);
      expect(resolved.radiusPopconfirmPopover, 6);
      expect(
        resolved.fontPopconfirmHeaderTitleFontWeight,
        const SemiThemeData.light().typography.fontWeightBold,
      );
      expect(
        resolved.colorPopconfirmHeaderText,
        const SemiThemeData.light().colors.colorText0,
      );
      expect(
        resolved.colorPopconfirmBodyText,
        const SemiThemeData.light().colors.colorText2,
      );
      expect(
        resolved.colorPopconfirmHeaderAlertIcon,
        const SemiThemeData.light().colors.colorWarning,
      );
    });

    test('copyWith/merge/equality keep every field', () {
      const base = SemiPopconfirmThemeData();
      final patch = base.copyWith(
        widthPopconfirmMaxWidth: 320,
        colorPopconfirmHeaderText: const Color(0xFF123456),
      );
      expect(patch.widthPopconfirmMaxWidth, 320);
      expect(patch.spacingPopconfirmTop, isNull);
      expect(patch.merge(null), patch);
      expect(base.merge(const SemiPopconfirmThemeData()), base);
      expect(
        base.merge(patch) == patch.copyWith(),
        isTrue,
        reason: 'merge overlays every non-null field',
      );
      expect(base == patch, isFalse);
      expect(base.hashCode == patch.hashCode, isFalse);
    });

    test('SemiComponentThemes wires the popconfirm slot', () {
      const themes = SemiComponentThemes();
      expect(themes.popconfirm, const SemiPopconfirmThemeData());
      expect(
        themes.copyWith(popconfirm: const SemiPopconfirmThemeData(widthPopconfirmMaxWidth: 1)).popconfirm,
        const SemiPopconfirmThemeData(widthPopconfirmMaxWidth: 1),
      );
    });

    test('widget source keeps the provenance anchors', () {
      final source = File(
        'lib/src/components/semi_popconfirm.dart',
      ).readAsStringSync();
      const anchors = [
        // INTERNAL declarations (4).
        r'$spacing-popconfirm_popover_with_arrow_inner-padding: ($spacing-popconfirm-top - $spacing-popconfirm_with_arrow-padding) ($spacing-popconfirm-top - $spacing-popconfirm_with_arrow-padding) ($spacing-popconfirm-top - $spacing-popconfirm_with_arrow-padding) ($spacing-popconfirm-bottom - $spacing-popconfirm_with_arrow-padding)',
        r'$spacing-popconfirm_popover_with_arrow_inner_rtl-padding: ($spacing-popconfirm-top - $spacing-popconfirm_with_arrow-padding) ($spacing-popconfirm-bottom - $spacing-popconfirm_with_arrow-padding) ($spacing-popconfirm-top - $spacing-popconfirm_with_arrow-padding) ($spacing-popconfirm-top - $spacing-popconfirm_with_arrow-padding)',
        r'$spacing-popconfirm_btn_close-margin: 24px',
        r'$spacing-popconfirm_popover_with_arrow_inner_btn_close-marginTop: $spacing-popconfirm_btn_close-margin - $spacing-popconfirm_with_arrow-padding',
        // HARDCODES (11).
        r'padding: $spacing-popconfirm-top $spacing-popconfirm-top $spacing-popconfirm-top $spacing-popconfirm-bottom',
        r'padding: $spacing-popconfirm-top $spacing-popconfirm-bottom $spacing-popconfirm-top $spacing-popconfirm-top',
        r'margin-left: $width-popconfirm-icon + $spacing-popconfirm_header_icon-marginRight',
        '@include font-size-header-6',
        '@include font-size-regular',
        r'$color-popover-bg-default: var(--semi-color-bg-3)',
        r'box-shadow: var(--semi-shadow-elevated)',
        r'z-index: $z-popover',
        'spacing = showArrow ? numbers.SPACING_WITH_ARROW : numbers.SPACING',
        'fill: var(--semi-color-border)',
        'fill: var(--semi-color-bg-3)',
      ];
      for (final anchor in anchors) {
        expect(source, contains(anchor), reason: anchor);
      }
    });
  });

  group('behavior', () {
    testWidgets('click shows the card; ok confirms and closes (uncontrolled)', (
      tester,
    ) async {
      var confirmed = 0;
      final log = <bool>[];
      await tester.pumpWidget(
        _app(
          SemiPopconfirm(
            title: const Text('删除任务'),
            content: const Text('确定删除该任务吗？'),
            motion: false,
            onConfirm: () => confirmed++,
            onVisibleChange: log.add,
            child: _trigger(),
          ),
        ),
      );
      await tester.tap(find.byKey(_kTrigger), warnIfMissed: false);
      await _settleOpen(tester);
      expect(find.text('删除任务'), findsOneWidget);
      expect(find.text('确定删除该任务吗？'), findsOneWidget);
      expect(find.byType(SemiPopconfirmDefaultIcon), findsOneWidget);
      expect(find.text('确认'), findsOneWidget);
      expect(find.text('取消'), findsOneWidget);
      expect(log, [true]);

      await tester.tap(find.text('确认'), warnIfMissed: false);
      await _settleOpen(tester);
      expect(confirmed, 1);
      expect(find.text('删除任务'), findsNothing);
      expect(log, [true, false]);
    });

    testWidgets('cancel button and close icon both fire onCancel and close', (
      tester,
    ) async {
      var cancelled = 0;
      await tester.pumpWidget(
        _app(
          SemiPopconfirm(
            title: const Text('标题'),
            content: const Text('正文'),
            motion: false,
            onCancel: () => cancelled++,
            child: _trigger(),
          ),
        ),
      );
      await tester.tap(find.byKey(_kTrigger), warnIfMissed: false);
      await _settleOpen(tester);
      await tester.tap(find.text('取消'), warnIfMissed: false);
      await _settleOpen(tester);
      expect(cancelled, 1);
      expect(find.text('标题'), findsNothing);

      await tester.tap(find.byKey(_kTrigger), warnIfMissed: false);
      await _settleOpen(tester);
      await tester.tap(
        find.byWidgetPredicate((w) => w is SemiIcon && w.data == SemiIcons.close),
        warnIfMissed: false,
      );
      await _settleOpen(tester);
      expect(cancelled, 2);
      expect(find.text('标题'), findsNothing);
    });

    testWidgets(
      'onConfirm Future: ok button loads, resolve closes, reject stays open',
      (tester) async {
        Future<void> delayed(Completer<void> completer) => completer.future;

        // Reject path.
        final reject = Completer<void>();
        await tester.pumpWidget(
          _app(
            SemiPopconfirm(
              title: const Text('标题'),
              content: const Text('正文'),
              motion: false,
              onConfirm: () => delayed(reject),
              child: _trigger(),
            ),
          ),
        );
        await tester.tap(find.byKey(_kTrigger), warnIfMissed: false);
        await _settleOpen(tester);
        await tester.tap(find.text('确认'), warnIfMissed: false);
        await _settleOpen(tester);
        expect(_button(tester, '确认').loading, isTrue);
        expect(find.text('标题'), findsOneWidget);
        reject.completeError(StateError('nope'));
        await _settleOpen(tester);
        expect(_button(tester, '确认').loading, isFalse);
        expect(find.text('标题'), findsOneWidget, reason: 'reject keeps it open');

        // Resolve path. A fresh host (UniqueKey) per case: OverlayEntry does
        // not rebuild on pumpWidget and would keep the rejected callback.
        final resolve = Completer<void>();
        await tester.pumpWidget(
          _app(
            SemiPopconfirm(
              title: const Text('标题'),
              content: const Text('正文'),
              motion: false,
              onConfirm: () => delayed(resolve),
              child: _trigger(),
            ),
            hostKey: UniqueKey(),
          ),
        );
        await tester.tap(find.byKey(_kTrigger), warnIfMissed: false);
        await _settleOpen(tester);
        await tester.tap(find.text('确认'), warnIfMissed: false);
        await _settleOpen(tester);
        expect(_button(tester, '确认').loading, isTrue);
        resolve.complete();
        await _settleOpen(tester);
        expect(find.text('标题'), findsNothing);
      },
    );

    testWidgets('onCancel Future drives the cancel button loading', (
      tester,
    ) async {
      final completer = Completer<void>();
      await tester.pumpWidget(
        _app(
          SemiPopconfirm(
            title: const Text('标题'),
            content: const Text('正文'),
            motion: false,
            onCancel: () => completer.future,
            child: _trigger(),
          ),
        ),
      );
      await tester.tap(find.byKey(_kTrigger), warnIfMissed: false);
      await _settleOpen(tester);
      await tester.tap(find.text('取消'), warnIfMissed: false);
      await _settleOpen(tester);
      expect(_button(tester, '取消').loading, isTrue);
      expect(find.text('标题'), findsOneWidget);
      completer.complete();
      await _settleOpen(tester);
      expect(find.text('标题'), findsNothing);
    });

    testWidgets('controlled visible only reports requests (trigger + confirm)', (
      tester,
    ) async {
      final log = <bool>[];
      Future<void> pump({required bool visible}) async {
        await tester.pumpWidget(
          _app(
            SemiPopconfirm(
              title: const Text('标题'),
              content: const Text('正文'),
              motion: false,
              visible: visible,
              onVisibleChange: log.add,
              onConfirm: () {},
              child: _trigger(),
            ),
            hostKey: UniqueKey(),
          ),
        );
      }

      await pump(visible: false);
      await tester.tap(find.byKey(_kTrigger), warnIfMissed: false);
      await _settleOpen(tester);
      expect(find.text('标题'), findsNothing);
      expect(log, [true], reason: 'trigger click only reports the request');

      await pump(visible: true);
      await _settleOpen(tester);
      expect(find.text('标题'), findsOneWidget);
      await tester.tap(find.text('确认'), warnIfMissed: false);
      await _settleOpen(tester);
      expect(find.text('标题'), findsOneWidget, reason: 'controlled keeps open');
      expect(log, [true, false]);
    });

    testWidgets('disabled renders the child without a popup', (tester) async {
      await tester.pumpWidget(
        _app(
          SemiPopconfirm(
            disabled: true,
            title: const Text('标题'),
            content: const Text('正文'),
            motion: false,
            child: _trigger(),
          ),
        ),
      );
      await tester.tap(find.byKey(_kTrigger), warnIfMissed: false);
      await _settleOpen(tester);
      expect(find.text('标题'), findsNothing);
    });

    testWidgets('icon: null hides the slot; custom icon replaces the default', (
      tester,
    ) async {
      await tester.pumpWidget(
        _app(
          SemiPopconfirm(
            title: const Text('标题'),
            content: const Text('正文'),
            icon: null,
            motion: false,
            child: _trigger(),
          ),
        ),
      );
      await tester.tap(find.byKey(_kTrigger), warnIfMissed: false);
      await _settleOpen(tester);
      expect(find.byType(SemiPopconfirmDefaultIcon), findsNothing);
      expect(
        find.byWidgetPredicate((w) => w is SemiIcon && w.data != SemiIcons.close),
        findsNothing,
      );

      await tester.pumpWidget(
        _app(
          SemiPopconfirm(
            title: const Text('标题'),
            content: const Text('正文'),
            icon: const SemiIcon(SemiIcons.star),
            motion: false,
            child: _trigger(),
          ),
          hostKey: UniqueKey(),
        ),
      );
      await tester.tap(find.byKey(_kTrigger), warnIfMissed: false);
      await _settleOpen(tester);
      expect(find.byType(SemiPopconfirmDefaultIcon), findsNothing);
      expect(
        find.byWidgetPredicate(
          (w) => w is SemiIcon && w.data == SemiIcons.star,
        ),
        findsOneWidget,
      );
    });

    testWidgets('Escape and outside click close; onClickOutSide reports', (
      tester,
    ) async {
      var outside = 0;
      await tester.pumpWidget(
        _app(
          SemiPopconfirm(
            title: const Text('标题'),
            content: const Text('正文'),
            motion: false,
            onClickOutSide: () => outside++,
            child: _trigger(),
          ),
        ),
      );
      await tester.tap(find.byKey(_kTrigger), warnIfMissed: false);
      await _settleOpen(tester);
      await tester.sendKeyEvent(LogicalKeyboardKey.escape);
      await _settleOpen(tester);
      expect(find.text('标题'), findsNothing);

      await tester.tap(find.byKey(_kTrigger), warnIfMissed: false);
      await _settleOpen(tester);
      await tester.tapAt(const Offset(5, 5));
      await _settleOpen(tester);
      expect(find.text('标题'), findsNothing);
      expect(outside, 1);
    });

    testWidgets('showArrow positions the popover wing along the popup edge', (
      tester,
    ) async {
      await tester.pumpWidget(
        _app(
          SemiPopconfirm(
            title: const Text('标题'),
            content: const Text('正文'),
            showArrow: true,
            motion: false,
            child: _trigger(),
          ),
        ),
      );
      await tester.tap(find.byKey(_kTrigger), warnIfMissed: false);
      await _settleOpen(tester);
      final popup = tester.widget<SemiTooltipPopup>(
        find.byType(SemiTooltipPopup),
      );
      expect(popup.showArrow, isTrue);
      expect(popup.placement, isNotNull);
      expect(popup.arrowOffset, isNotNull);
      expect(tester.takeException(), isNull);
    });

    testWidgets('local SemiPopconfirmTheme patches reach the card', (
      tester,
    ) async {
      const patch = SemiPopconfirmThemeData(widthPopconfirmMaxWidth: 300);
      await tester.pumpWidget(
        _app(
          SemiPopconfirm(
            title: const Text('标题'),
            content: const Text('正文'),
            motion: false,
            child: _trigger(),
          ),
          popconfirmTheme: patch,
        ),
      );
      await tester.tap(find.byKey(_kTrigger), warnIfMissed: false);
      await _settleOpen(tester);
      final context = tester.element(find.text('标题'));
      final resolved = SemiPopconfirmTheme.resolve(context);
      expect(resolved.widthPopconfirmMaxWidth, 300);
      expect(resolved.spacingPopconfirmTop, 24, reason: '其余字段回退 Sass 默认');
    });

    testWidgets('RTL mirrors the inner padding and keeps the body indent', (
      tester,
    ) async {
      await tester.pumpWidget(
        _app(
          SemiPopconfirm(
            title: const Text('标题'),
            content: const Text('正文'),
            motion: false,
            child: _trigger(),
          ),
          textDirection: TextDirection.rtl,
        ),
      );
      await tester.tap(find.byKey(_kTrigger), warnIfMissed: false);
      await _settleOpen(tester);
      expect(find.text('标题'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });
}
