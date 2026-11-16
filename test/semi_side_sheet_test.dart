// Behavior matrix for SemiSideSheet plus coverage for the 31 Sass declarations
// (19 FIELDS + 12 MOTION + 0 INTERNAL) — the 10 HARDCODES provenance anchors
// live in the widget's call sites. ★0 死变量（sideSheet.scss/rtl.scss 逐条
// 消费）。quirks 无（两条 scss 声明冒号空格规整）。
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:semi_design_flutter/semi_design_flutter.dart';
import 'package:semi_design_flutter/src/overlay/dialog_engine/helper/dialog_proxy.dart';
import 'package:semi_design_flutter/src/overlay/dialog_engine/helper/smart_dialog_test_state.dart';

/// 宿主 body 经 ValueListenable 交换（Overlay.initialEntries 重建不换内容）。
final _body = ValueNotifier<Widget>(const SizedBox.shrink());

Widget _host({SemiSideSheetThemeData? patch}) {
  Widget app = SemiTheme(
    data: const SemiThemeData.light(),
    child: Directionality(
      textDirection: TextDirection.ltr,
      child: MediaQuery(
        data: const MediaQueryData(size: Size(1200, 900)),
        child: Overlay(
          initialEntries: [
            OverlayEntry(
              builder: (context) => ValueListenableBuilder<Widget>(
                valueListenable: _body,
                builder: (context, value, _) => Center(child: value),
              ),
            ),
          ],
        ),
      ),
    ),
  );
  if (patch != null) {
    app = SemiSideSheetTheme(data: patch, child: app);
  }
  return app;
}

Future<void> pumpHost(WidgetTester tester, {SemiSideSheetThemeData? patch}) async {
  addTearDown(() async {
    // 引擎的 display/least-loading 计时器要冲掉（上游 disposeSmartDialogApp
    // 双冲洗次序：存活时冲 → 卸载 → reset → 再冲）。
    await tester.pump(const Duration(seconds: 3));
    _body.value = const SizedBox.shrink();
    await tester.pump();
    DialogProxy.instance.resetForTest();
    await tester.pump(const Duration(seconds: 3));
    await tester.pump();
  });
  await tester.binding.setSurfaceSize(const Size(1200, 900));
  await tester.pumpWidget(_host(patch: patch));
  await tester.pump();
  // 裸宿主无 SemiApp/observer——手动绑定（引擎逃生口）。
  DialogProxy.instance.bind(tester.state<OverlayState>(find.byType(Overlay)));
  await tester.pump();
}

/// 换 body（同类型位置复用 State——didUpdateWidget 路径）。
Future<void> setSideSheet(WidgetTester tester, Widget sheet) async {
  _body.value = sheet;
  await tester.pump();
  await tester.pump();
}

/// 弹层入场泵帧（引擎 insert 1 帧 + 内容 1 帧）。
Future<void> pumpOpen(WidgetTester tester) async {
  await tester.pump();
  await tester.pump();
  await tester.pump();
}

Future<void> pumpClosed(WidgetTester tester) async {
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 250));
  // DebounceUtils/MonitorWidgetHelper 的计时器要在 _verifyInvariants（teardown
  // 前）之前清掉——体内收尾清理（上游 SmartDialogTestState.reset 先例）。
  SmartDialogTestState.reset();
  await tester.pump(const Duration(seconds: 3));
  await tester.pump();
}

SemiResolvedSideSheetThemeData resolve() =>
    const SemiSideSheetThemeData().resolve(const SemiThemeData.light());

void main() {
  group('theme fields (31 = 19 FIELDS + 12 MOTION + 0 INTERNAL)', () {
    test('31 fields: merge, copyWith, resolve, equality, defaults', () {
      final light = const SemiThemeData.light();
      final t = const SemiSideSheetThemeData().resolve(light);
      expect(t.colorSideSheetMaskBg, light.colors.colorOverlayBg);
      expect(t.colorSideSheetBg, light.colors.colorBg2);
      expect(t.colorSideSheetMainText, light.colors.colorText0);
      expect(t.colorSideSheetHeaderBorderBottom, light.colors.colorBorder);
      expect(t.spacingSideSheetMargin, 0);
      expect(t.spacingSideSheetTitleMargin, 0);
      expect(t.spacingSideSheetHeaderPadding, 24);
      expect(t.spacingSideSheetHeaderPaddingBottom, 20);
      expect(t.spacingSideSheetBodyPaddingY, 0);
      expect(t.spacingSideSheetBodyPaddingX, 24);
      expect(t.spacingSideSheetFooterPadding, 24);
      expect(t.widthSideSheetHeaderBorderBottom, 0);
      expect(t.widthSideSheetSizeSmall, 448);
      expect(t.widthSideSheetSizeMedium, 684);
      expect(t.widthSideSheetSizeLarge, 920);
      expect(t.fontSideSheetTitleFontWeight, FontWeight.w600);
      expect(t.fontSideSheetTitleFontSize, light.typography.fontSizeHeading5);
      expect(t.filterSideSheetMaskBg, 'none');
      expect(t.filterSideSheetBg, 'none');
      expect(t.animationDurationSideSheetMaskShow, const Duration(milliseconds: 180));
      expect(t.animationDurationSideSheetMaskHide, const Duration(milliseconds: 180));
      expect(t.animationDurationSideSheetInnerShow, const Duration(milliseconds: 180));
      expect(t.animationDurationSideSheetInnerHide, const Duration(milliseconds: 180));
      expect(t.animationDelaySideSheetMaskShow, Duration.zero);
      expect(t.animationDelaySideSheetMaskHide, Duration.zero);
      expect(t.animationDelaySideSheetInnerShow, Duration.zero);
      expect(t.animationDelaySideSheetInnerHide, Duration.zero);
      expect(
        t.animationFunctionSideSheetInnerShow,
        const Cubic(0.25, 0.46, 0.45, 0.94),
      );
      expect(
        t.animationFunctionSideSheetInnerHide,
        const Cubic(0.25, 0.46, 0.45, 0.94),
      );
      expect(
        t.animationFunctionSideSheetMaskShow,
        const Cubic(0.25, 0.46, 0.45, 0.94),
      );
      expect(
        t.animationFunctionSideSheetMaskHide,
        const Cubic(0.25, 0.46, 0.45, 0.94),
      );

      // copyWith / merge / equality。
      const patch = SemiSideSheetThemeData(widthSideSheetSizeSmall: 500);
      expect(
        const SemiSideSheetThemeData().copyWith(),
        const SemiSideSheetThemeData(),
      );
      expect(
        const SemiSideSheetThemeData().merge(null),
        const SemiSideSheetThemeData(),
      );
      expect(
        patch
            .merge(const SemiSideSheetThemeData(widthSideSheetSizeLarge: 1))
            .widthSideSheetSizeSmall,
        500,
      );
      expect(patch, const SemiSideSheetThemeData(widthSideSheetSizeSmall: 500));
      expect(patch, isNot(const SemiSideSheetThemeData()));
      expect(
        patch.hashCode,
        const SemiSideSheetThemeData(widthSideSheetSizeSmall: 500).hashCode,
      );
    });

    test('every field carries its Sass provenance in the generated source', () {
      final source = File('lib/src/theme/semi_side_sheet_theme_data.dart')
          .readAsStringSync();
      const declarations = [
        r'$color-sideSheet_mask-bg: var(--semi-color-overlay-bg)',
        r'$color-sideSheet-bg: var(--semi-color-bg-2)',
        r'$color-sideSheet_main-text: var(--semi-color-text-0)',
        r'$color-sideSheet_header-borderBottom: var(--semi-color-border)',
        r'$spacing-sideSheet-margin: 0',
        r'$spacing-sideSheet_title-margin: 0',
        r'$spacing-sideSheet_header-padding: $spacing-loose',
        r'$spacing-sideSheet_header-paddingBottom: $spacing-base-loose',
        r'$spacing-sideSheet_body-paddingY: 0',
        r'$spacing-sideSheet_body-paddingX: $spacing-loose',
        r'$spacing-sideSheet_footer-padding: $spacing-loose',
        r'$width-sideSheet_header-borderBottom: 0px',
        r'$width-sideSheet_size-small: 448px',
        r'$width-sideSheet_size-medium: 684px',
        r'$width-sideSheet_size-large: 920px',
        r'$font-sideSheet_title-fontWeight: $font-weight-bold',
        r'$font-sideSheet_title-fontSize: $font-size-header-5',
        r'$filter-sideSheet_mask-bg: none',
        r'$filter-sideSheet-bg: none',
        r'$animation_duration-sideSheet_mask-show: 180ms',
        r'$animation_function-sideSheet_mask-show: cubic-bezier(0.25, 0.46, 0.45, 0.94)',
        r'$animation_delay-sideSheet_mask-show: 0ms',
        r'$animation_duration-sideSheet_mask-hide: 180ms',
        r'$animation_function-sideSheet_mask-hide: cubic-bezier(0.25, 0.46, 0.45, 0.94)',
        r'$animation_delay-sideSheet_mask-hide: 0ms',
        r'$animation_duration-sideSheet_inner-show: 180ms',
        r'$animation_function-sideSheet_inner-show: cubic-bezier(0.25, 0.46, 0.45, 0.94)',
        r'$animation_delay-sideSheet_inner-show: 0ms',
        r'$animation_duration-sideSheet_inner-hide: 180ms',
        r'$animation_function-sideSheet_inner-hide: cubic-bezier(0.25, 0.46, 0.45, 0.94)',
        r'$animation_delay-sideSheet_inner-hide: 0ms',
      ];
      expect(declarations, hasLength(31));
      for (final decl in declarations) {
        expect(source, contains(decl), reason: decl);
      }
      expect(source, contains('Generated by tool/generate_side_sheet.py'));
    });

    test('the 10 HARDCODES anchors live in the widget source', () {
      final widgetSource = File('lib/src/components/semi_side_sheet.dart')
          .readAsStringSync();
      const anchors = <String>[
        '@include font-size-regular',
        '@include font-size-header-5',
        'text-align: left',
        'box-shadow: var(--semi-shadow-elevated)',
        'translateY(-100%)',
        'translateY(100%)',
        'translateX(-100%)',
        'translateX(100%)',
        'opacity: 0',
        'HEIGHT: 448',
      ];
      expect(anchors, hasLength(10));
      for (final anchor in anchors) {
        expect(widgetSource, contains(anchor), reason: anchor);
      }
    });

    test('0 dead variables: docs carry the accounting', () {
      final docs = File('docs/semi_side_sheet.md').readAsStringSync();
      expect(docs, contains('31 = 19 FIELDS + 12 MOTION + 0 INTERNAL'));
      expect(docs, contains('0 死变量'));
    });

    test('SemiComponentThemes wiring', () {
      const themes = SemiComponentThemes();
      expect(themes.sideSheet, const SemiSideSheetThemeData());
      expect(
        themes.copyWith(
          sideSheet: const SemiSideSheetThemeData(widthSideSheetSizeSmall: 80),
        ),
        const SemiComponentThemes(
          sideSheet: SemiSideSheetThemeData(widthSideSheetSizeSmall: 80),
        ),
      );
    });
  });

  group('behavior', () {
    testWidgets('declarative visible drives show/dismiss; title + content '
        'render; no footer slot without footer', (tester) async {
      await pumpHost(tester);
      await setSideSheet(
        tester,
        const SemiSideSheet(
          visible: false,
          motion: false,
          title: '标题',
          content: Text('body'),
        ),
      );
      expect(find.text('body'), findsNothing);

      await setSideSheet(
        tester,
        const SemiSideSheet(
          visible: true,
          motion: false,
          title: '标题',
          content: Text('body'),
        ),
      );
      await pumpOpen(tester);
      expect(find.text('标题'), findsOneWidget);
      expect(find.text('body'), findsOneWidget);
      expect(find.text('footer'), findsNothing);

      await setSideSheet(
        tester,
        const SemiSideSheet(
          visible: false,
          motion: false,
          title: '标题',
          content: Text('body'),
        ),
      );
      await pumpClosed(tester);
      expect(find.text('body'), findsNothing);
    });

    testWidgets('placement: right (default) hugs the right edge full height; '
        'left mirrors', (tester) async {
      await pumpHost(tester);
      const box = ValueKey('semi-side-sheet-box');
      await setSideSheet(
        tester,
        const SemiSideSheet(
          visible: true,
          motion: false,
          title: '标题',
          content: Text('body'),
        ),
      );
      await pumpOpen(tester);
      final right = tester.getRect(find.byKey(box));
      expect(right.width, resolve().widthSideSheetSizeSmall);
      expect(right.height, 900);
      expect(right.right, 1200);

      await setSideSheet(
        tester,
        const SemiSideSheet(
          visible: true,
          motion: false,
          placement: SemiSideSheetPlacement.left,
          title: '标题',
          content: Text('body'),
        ),
      );
      await pumpOpen(tester);
      final left = tester.getRect(find.byKey(box));
      expect(left.left, 0);
      expect(left.height, 900);
      await pumpClosed(tester);
    });

    testWidgets('placement top/bottom: full width and default height '
        'HEIGHT: 448; height overrides', (tester) async {
      await pumpHost(tester);
      const box = ValueKey('semi-side-sheet-box');
      await setSideSheet(
        tester,
        const SemiSideSheet(
          visible: true,
          motion: false,
          placement: SemiSideSheetPlacement.top,
          title: '标题',
          content: Text('body'),
        ),
      );
      await pumpOpen(tester);
      final top = tester.getRect(find.byKey(box));
      expect(top.width, 1200);
      expect(top.height, 448);
      expect(top.top, 0);

      await setSideSheet(
        tester,
        const SemiSideSheet(
          visible: true,
          motion: false,
          placement: SemiSideSheetPlacement.bottom,
          height: 200,
          title: '标题',
          content: Text('body'),
        ),
      );
      await pumpOpen(tester);
      final bottom = tester.getRect(find.byKey(box));
      expect(bottom.height, 200);
      expect(bottom.bottom, 900);
      await pumpClosed(tester);
    });

    testWidgets('size widths small 448 / medium 684 / large 920; width '
        'overrides size', (tester) async {
      await pumpHost(tester);
      const box = ValueKey('semi-side-sheet-box');
      Future<void> widthOf(SemiSideSheet sheet) async {
        await setSideSheet(tester, sheet);
        await pumpOpen(tester);
      }

      await widthOf(
        const SemiSideSheet(
          visible: true,
          motion: false,
          size: SemiSideSheetSize.small,
          content: Text('body'),
        ),
      );
      expect(tester.getSize(find.byKey(box)).width, resolve().widthSideSheetSizeSmall);
      await widthOf(
        const SemiSideSheet(
          visible: true,
          motion: false,
          size: SemiSideSheetSize.medium,
          content: Text('body'),
        ),
      );
      expect(tester.getSize(find.byKey(box)).width, resolve().widthSideSheetSizeMedium);
      await widthOf(
        const SemiSideSheet(
          visible: true,
          motion: false,
          size: SemiSideSheetSize.large,
          content: Text('body'),
        ),
      );
      expect(tester.getSize(find.byKey(box)).width, resolve().widthSideSheetSizeLarge);
      await widthOf(
        const SemiSideSheet(
          visible: true,
          motion: false,
          size: SemiSideSheetSize.large,
          width: 300,
          content: Text('body'),
        ),
      );
      expect(tester.getSize(find.byKey(box)).width, 300);
      await pumpClosed(tester);
    });

    testWidgets('mask click / close button notify onCancel; Esc only with '
        'closeOnEsc (upstream default false); declarative does not '
        'self-close', (tester) async {
      var cancels = 0;
      await pumpHost(tester);
      await setSideSheet(
        tester,
        SemiSideSheet(
          visible: true,
          motion: false,
          title: '标题',
          content: const Text('body'),
          onCancel: () => cancels++,
        ),
      );
      await pumpOpen(tester);

      await tester.tapAt(const Offset(20, 20));
      await tester.pump();
      expect(cancels, 1);
      expect(find.text('body'), findsOneWidget);

      // 上游 closeOnEsc 缺省 false——Esc 不触发。
      await tester.sendKeyEvent(LogicalKeyboardKey.escape);
      await tester.pump();
      expect(cancels, 1);

      await tester.tap(
        find.byWidgetPredicate(
          (w) => w is SemiButton && w.child == null && w.icon != null,
        ),
      );
      await tester.pump();
      expect(cancels, 2);
      await pumpClosed(tester);
    });

    testWidgets('closeOnEsc: true notifies on Esc; maskClosable: false '
        'ignores mask clicks; closable: false hides the closer', (tester) async {
      var cancels = 0;
      await pumpHost(tester);
      await setSideSheet(
        tester,
        SemiSideSheet(
          visible: true,
          motion: false,
          closeOnEsc: true,
          maskClosable: false,
          closable: false,
          title: '标题',
          content: const Text('body'),
          onCancel: () => cancels++,
        ),
      );
      await pumpOpen(tester);

      await tester.tapAt(const Offset(20, 20));
      await tester.pump();
      expect(cancels, 0);

      await tester.sendKeyEvent(LogicalKeyboardKey.escape);
      await tester.pump();
      expect(cancels, 1);

      expect(
        find.byWidgetPredicate(
          (w) => w is SemiButton && w.child == null && w.icon != null,
        ),
        findsNothing,
      );
      await pumpClosed(tester);
    });

    testWidgets('title carries the upstream token style; footer renders '
        'with its padding', (tester) async {
      await pumpHost(tester);
      final t = resolve();
      await setSideSheet(
        tester,
        const SemiSideSheet(
          visible: true,
          motion: false,
          title: '标题',
          content: Text('body'),
          footer: Text('footer'),
        ),
      );
      await pumpOpen(tester);
      // `font-size: $font-sideSheet_title-fontSize`（$font-size-header-5）+
      // `font-weight: $font-sideSheet_title-fontWeight` + `color:
      // $color-sideSheet_main-text`。
      final style = tester.widget<Text>(find.text('标题')).style;
      expect(style?.fontSize, t.fontSideSheetTitleFontSize);
      expect(style?.fontWeight, t.fontSideSheetTitleFontWeight);
      expect(style?.color, t.colorSideSheetMainText);

      // `.semi-sidesheet-footer { padding: $spacing-sideSheet_footer-padding }`。
      expect(
        find.ancestor(
          of: find.text('footer'),
          matching: find.byWidgetPredicate(
            (w) =>
                w is Padding &&
                w.padding == EdgeInsets.all(t.spacingSideSheetFooterPadding),
          ),
        ),
        findsOneWidget,
      );
      await pumpClosed(tester);
    });

    testWidgets('header/body paddings carry the upstream defaults', (
      tester,
    ) async {
      await pumpHost(tester);
      final t = resolve();
      await setSideSheet(
        tester,
        const SemiSideSheet(
          visible: true,
          motion: false,
          title: '标题',
          content: Text('body'),
        ),
      );
      await pumpOpen(tester);
      // `padding: $spacing-sideSheet_header-padding` + `padding-bottom:
      // $spacing-sideSheet_header-paddingBottom`（24/20）。
      final headerPadding = EdgeInsetsDirectional.only(
        top: t.spacingSideSheetHeaderPadding,
        bottom: t.spacingSideSheetHeaderPaddingBottom,
        start: t.spacingSideSheetHeaderPadding,
        end: t.spacingSideSheetHeaderPadding,
      );
      expect(
        find.ancestor(
          of: find.text('标题'),
          matching: find.byWidgetPredicate(
            (w) => w is Container && w.padding == headerPadding,
          ),
        ),
        findsOneWidget,
      );
      // `padding: $spacing-sideSheet_body-paddingY
      // $spacing-sideSheet_body-paddingX`（0/24）。
      final bodyPadding = EdgeInsets.symmetric(
        vertical: t.spacingSideSheetBodyPaddingY,
        horizontal: t.spacingSideSheetBodyPaddingX,
      );
      expect(
        find.ancestor(
          of: find.text('body'),
          matching: find.byWidgetPredicate(
            (w) => w is Padding && w.padding == bodyPadding,
          ),
        ),
        findsOneWidget,
      );
      await pumpClosed(tester);
    });

    testWidgets('motion: true (default) animates the sheet in and out', (
      tester,
    ) async {
      await pumpHost(tester);
      await setSideSheet(
        tester,
        const SemiSideSheet(visible: true, title: '标题', content: Text('body')),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 250));
      await tester.pump(const Duration(milliseconds: 250));
      expect(find.text('body'), findsOneWidget);
      await pumpClosed(tester);
      expect(find.text('body'), findsNothing);
    });

    testWidgets('afterVisibleChange reports true after the open animation '
        'and false after close', (tester) async {
      final events = <bool>[];
      await pumpHost(tester);
      await setSideSheet(
        tester,
        SemiSideSheet(
          visible: true,
          title: '标题',
          content: const Text('body'),
          afterVisibleChange: events.add,
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 250));
      expect(events, [true]);

      await setSideSheet(
        tester,
        SemiSideSheet(
          visible: false,
          title: '标题',
          content: const Text('body'),
          afterVisibleChange: events.add,
        ),
      );
      await pumpClosed(tester);
      expect(events, [true, false]);
    });

    testWidgets('mask: false (fixed mode) drops the mask, punches clicks '
        'through and adds the elevated shadow', (tester) async {
      var cancels = 0;
      await pumpHost(tester);
      await setSideSheet(
        tester,
        SemiSideSheet(
          visible: true,
          motion: false,
          mask: false,
          title: '标题',
          content: const Text('body'),
          onCancel: () => cancels++,
        ),
      );
      await pumpOpen(tester);
      // 上游无 mask 节点——点击穿透（usePenetrate），不触发 onCancel。
      await tester.tapAt(const Offset(20, 20));
      await tester.pump();
      expect(cancels, 0);

      // `.semi-sidesheet-fixed .semi-sidesheet-inner { box-shadow:
      // var(--semi-shadow-elevated) }`。
      final box = tester.widget<Container>(
        find.byKey(const ValueKey('semi-side-sheet-box')),
      );
      final decoration = box.decoration! as BoxDecoration;
      expect(decoration.boxShadow, isNotNull);
      expect(
        decoration.boxShadow,
        const SemiThemeData.light().shadows.shadowElevated.toBoxShadows(),
      );
      await pumpClosed(tester);
    });

    testWidgets('a local theme patch drives side sheet colors and metrics', (
      tester,
    ) async {
      const bg = Color(0xff123456);
      await pumpHost(
        tester,
        patch: const SemiSideSheetThemeData(
          colorSideSheetBg: bg,
          widthSideSheetSizeSmall: 500,
          spacingSideSheetFooterPadding: 33,
        ),
      );
      final t = const SemiSideSheetThemeData(
        colorSideSheetBg: bg,
        widthSideSheetSizeSmall: 500,
        spacingSideSheetFooterPadding: 33,
      ).resolve(const SemiThemeData.light());
      await setSideSheet(
        tester,
        const SemiSideSheet(
          visible: true,
          motion: false,
          title: '标题',
          content: Text('body'),
          footer: Text('footer'),
        ),
      );
      await pumpOpen(tester);
      final box = tester.widget<Container>(
        find.byKey(const ValueKey('semi-side-sheet-box')),
      );
      expect((box.decoration! as BoxDecoration).color, bg);
      expect(tester.getSize(find.byKey(const ValueKey('semi-side-sheet-box'))).width, 500);
      expect(t.colorSideSheetBg, bg);
      expect(
        find.ancestor(
          of: find.text('footer'),
          matching: find.byWidgetPredicate(
            (w) => w is Padding && w.padding == const EdgeInsets.all(33),
          ),
        ),
        findsOneWidget,
      );
      await pumpClosed(tester);
    });
  });
}
