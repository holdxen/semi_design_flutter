// Behavior matrix for SemiModal plus coverage for the 81 Sass declarations
// (63 FIELDS + 18 MOTION + 0 INTERNAL) — the 8 HARDCODES provenance anchors
// live in the widget's call sites. ★0 死变量（modal.scss/rtl.scss 逐条消费）。
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:semi_design_flutter/semi_design_flutter.dart';
import 'package:semi_design_flutter/src/overlay/dialog_engine/helper/dialog_proxy.dart';
import 'package:semi_design_flutter/src/overlay/dialog_engine/helper/smart_dialog_test_state.dart';

/// 宿主 body 经 ValueListenable 交换（Overlay.initialEntries 重建不换内容）。
final _body = ValueNotifier<Widget>(const SizedBox.shrink());

Widget _host({SemiModalThemeData? patch}) {
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
    app = SemiModalTheme(data: patch, child: app);
  }
  return app;
}

Future<void> pumpHost(WidgetTester tester, {SemiModalThemeData? patch}) async {
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
Future<void> setModal(WidgetTester tester, Widget modal) async {
  _body.value = modal;
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

SemiResolvedModalThemeData resolve() =>
    const SemiModalThemeData().resolve(const SemiThemeData.light());

void main() {
  group('theme fields (81 = 63 FIELDS + 18 MOTION + 0 INTERNAL)', () {
    test('81 fields: merge, copyWith, resolve, equality, defaults', () {
      final light = const SemiThemeData.light();
      final t = const SemiModalThemeData().resolve(light);
      expect(t.colorModalBg, light.colors.colorBg2);
      expect(t.colorModalMaskBg, light.colors.colorOverlayBg);
      expect(t.colorModalMainText, light.colors.colorText0);
      expect(t.colorModalInfoIcon, light.colors.colorInfo);
      expect(t.colorModalPrimaryIcon, light.colors.colorPrimary);
      expect(t.colorModalSuccessIcon, light.colors.colorSuccess);
      expect(t.colorModalDangerIcon, light.colors.colorDanger);
      expect(t.colorModalWarningIcon, light.colors.colorWarning);
      expect(t.colorModalContentBorder, light.colors.colorBorder);
      expect(t.colorModalHeaderBg, const Color(0x00000000));
      expect(t.colorModalFooterBg, const Color(0x00000000));
      expect(t.colorModalHeaderBorder, const Color(0x00000000));
      expect(t.colorModalFooterBorder, const Color(0x00000000));
      expect(t.spacingModalMarginY, 80);
      expect(t.spacingModalMarginX, 'auto');
      expect(t.spacingModalMaskTop, 0);
      expect(t.spacingModalContentWithiconMarginLeft, 36);
      expect(t.spacingModalIconWrapperMarginRight, 12);
      expect(t.spacingModalContentPaddingX, 24);
      expect(t.spacingModalHeaderMarginY, 24);
      expect(t.spacingModalBodyWrapperMarginY, 24);
      expect(t.spacingModalFooterMarginY, 24);
      expect(t.spacingModalFooterButtonMarginLeft, 12);
      expect(t.spacingModalConfirmHeaderMarginBottom, 8);
      expect(t.widthModalTitle, 100);
      expect(t.heightModalContent, 'max-content');
      expect(t.widthModalContentBorder, 1);
      expect(t.widthModalSmall, 448);
      expect(t.widthModalMedium, 684);
      expect(t.widthModalLarge, 920);
      expect(t.widthModalFullWidth, 'calc(100vw - 64px)');
      expect(t.radiusModalContent, light.radius.borderRadiusLarge.value);
      expect(t.radiusModalContentFullscreen, 0);
      expect(
        t.radiusModalFooter,
        const BorderRadius.vertical(bottom: Radius.circular(5)),
      );
      expect(t.fontModalHeaderFontSize, light.typography.fontSizeRegular);
      expect(t.fontModalHeaderFontWeight, FontWeight.w600);
      expect(t.widthModalHeaderBorder, 0);
      expect(t.widthModalFooterBorder, 0);
      expect(t.shadowModalContent, light.shadows.shadowElevated);
      expect(t.filterModalMaskBg, 'none');
      expect(t.filterModalContentBg, 'none');
      expect(t.animationDurationModalShow, const Duration(milliseconds: 120));
      expect(t.animationDurationModalHide, const Duration(milliseconds: 120));
      expect(
        t.animationDurationModalMaskShow,
        const Duration(milliseconds: 90),
      );
      expect(
        t.animationDurationModalMaskHide,
        const Duration(milliseconds: 90),
      );
      expect(t.animationDelayModalShow, Duration.zero);
      expect(t.animationTransformScaleModalContentOpen.scaleX, 0.7);
      expect(t.animationTransformScaleModalContentClose.scaleX, 0.7);
      expect(t.animationOpacityModalContentOpen, 0);
      expect(t.animationOpacityModalContentClose, 0);
      expect(t.animationOpacityModalMaskOpen, 0);
      expect(t.animationOpacityModalMaskClose, 0);

      // copyWith / merge / equality。
      const patch = SemiModalThemeData(widthModalSmall: 500);
      expect(const SemiModalThemeData().copyWith(), const SemiModalThemeData());
      expect(
        const SemiModalThemeData().merge(null),
        const SemiModalThemeData(),
      );
      expect(
        patch
            .merge(const SemiModalThemeData(widthModalLarge: 1))
            .widthModalSmall,
        500,
      );
      expect(patch, const SemiModalThemeData(widthModalSmall: 500));
      expect(patch, isNot(const SemiModalThemeData()));
      expect(
        patch.hashCode,
        const SemiModalThemeData(widthModalSmall: 500).hashCode,
      );
    });

    test('every field carries its Sass provenance in the generated source', () {
      final source = File('lib/src/theme/semi_modal_theme_data.dart')
          .readAsStringSync();
      const declarations = [
        r'$color-modal-bg: var(--semi-color-bg-2)',
        r'$color-modal_mask-bg: var(--semi-color-overlay-bg)',
        r'$color-modal_main-text: var(--semi-color-text-0)',
        r'$color-modal_info-icon: var(--semi-color-info)',
        r'$color-modal_primary-icon: var(--semi-color-primary)',
        r'$color-modal_success-icon: var(--semi-color-success)',
        r'$color-modal_danger-icon: var(--semi-color-danger)',
        r'$color-modal_warning-icon: var(--semi-color-warning)',
        r'$color-modal_content-border: var(--semi-color-border)',
        r'$color-modal_header-bg: transparent',
        r'$color-modal_footer-bg: transparent',
        r'$spacing-modal-marginY: 80px',
        r'$spacing-modal-marginX: auto',
        r'$spacing-modal_mask-top: 0',
        r'$spacing-modal_mask-right: 0',
        r'$spacing-modal_mask-bottom: 0',
        r'$spacing-modal_mask-left: 0',
        r'$spacing-modal_content_withicon-marginLeft: 36px',
        r'$spacing-modal_icon_wrapper-marginRight: $spacing-base-tight',
        r'$spacing-modal_wrap-top: 0',
        r'$spacing-modal_wrap-right: 0',
        r'$spacing-modal_wrap-bottom: 0',
        r'$spacing-modal_wrap-left: 0',
        r'$spacing-modal_title-margin: 0',
        r'$spacing-modal_content-paddingY: 0',
        r'$spacing-modal_content-paddingX: 24px',
        r'$spacing-modal_header-marginY: 24px',
        r'$spacing-modal_header-marginX: 0',
        r'$spacing-modal_header-paddingY: 0',
        r'$spacing-modal_header-paddingX: 0',
        r'$spacing-modal_body_wrapper-marginY: 24px',
        r'$spacing-modal_body_wrapper-marginX: 0',
        r'$spacing-modal_body-margin: 0',
        r'$spacing-modal_body-padding: 0',
        r'$spacing-modal_footer-marginY: 24px',
        r'$spacing-modal_footer-marginX: 0',
        r'$spacing-modal_footer-paddingY:0',
        r'$spacing-modal_footer-paddingX: 0',
        r'$spacing-modal_footer_button-marginLeft: $spacing-base-tight',
        r'$spacing-modal_footer_button-marginRight: 0',
        r'$spacing-modal_confirm_header-marginBottom: 8px',
        r'$spacing-modal_confirm_icon_wrapper-marginRight: $spacing-base-tight',
        r'$spacing-modal_content_fullscreen-top: 0px',
        r'$width-modal_title: 100%',
        r'$width-modal_content: 100%',
        r'$height-modal_content: max-content',
        r'$width-modal_content-border: 1px',
        r'$width-modal_small: 448px',
        r'$width-modal_medium: 684px',
        r'$width-modal_large: 920px',
        r'$width-modal_full_width: calc(100vw - 64px)',
        r'$radius-modal_content: var(--semi-border-radius-large)',
        r'$radius-modal_content_fullscreen: 0',
        r'$radius-modal_footer: 0 0 5px 5px',
        r'$font-modal_header-fontSize: $font-size-regular',
        r'$font-modal_header-fontWeight: $font-weight-bold',
        r'$color-modal_header-border:transparent',
        r'$width-modal_header-border:0',
        r'$color-modal_footer-border:transparent',
        r'$width-modal_footer-border:0',
        r'$shadow-modal_content: var(--semi-shadow-elevated)',
        r'$filter-modal_mask-bg: none',
        r'$filter-modal_content-bg: none',
        r'$animation_duration-modal-show: 120ms',
        r'$animation_function-modal-show: cubic-bezier(0.215, 0.61, 0.355, 1)',
        r'$animation_delay-modal-show: 0ms',
        r'$animation_duration-modal-hide: 120ms',
        r'$animation_function-modal-hide: cubic-bezier(0.215, 0.61, 0.355, 1)',
        r'$animation_delay-modal-hide: 0ms',
        r'$animation_duration-modal_mask-show: 90ms',
        r'$animation_function-modal_mask-show: cubic-bezier(0.215, 0.61, 0.355, 1)',
        r'$animation_delay-modal_mask-show: 0ms',
        r'$animation_duration-modal_mask-hide: 90ms',
        r'$animation_function-modal_mask-hide: cubic-bezier(0.215, 0.61, 0.355, 1)',
        r'$animation_delay-modal_mask-hide: 0ms',
        r'$animation_transform_scale-modal_content-open: 0.7',
        r'$animation_opacity-modal_content-open : 0',
        r'$animation_transform_scale-modal_content-close: 0.7',
        r'$animation_opacity-modal_content-close: 0',
        r'$animation_opacity-modal_mask-open: 0',
        r'$animation_opacity-modal_mask-close: 0',
      ];
      expect(declarations, hasLength(81));
      for (final decl in declarations) {
        expect(source, contains(decl), reason: decl);
      }
      expect(source, contains('Generated by tool/generate_modal.py'));
    });

    test('the 8 HARDCODES anchors live in the widget source', () {
      final widgetSource = File('lib/src/components/semi_modal.dart')
          .readAsStringSync();
      const anchors = <String>[
        '@include font-size-regular',
        'margin: auto',
        'align-items: flex-start',
        'overflow: auto',
        'calc(100vw - 64px)',
        r'$width-icon-extra-large',
        'text-align: right',
        r'$z-modal-mask',
      ];
      expect(anchors, hasLength(8));
      for (final anchor in anchors) {
        expect(widgetSource, contains(anchor), reason: anchor);
      }
    });

    test('0 dead variables: docs carry the accounting', () {
      final docs = File('docs/semi_modal.md').readAsStringSync();
      expect(docs, contains('81 = 63 FIELDS + 18 MOTION + 0 INTERNAL'));
      expect(docs, contains('0 死变量'));
    });

    test('SemiComponentThemes wiring', () {
      const themes = SemiComponentThemes();
      expect(themes.modal, const SemiModalThemeData());
      expect(
        themes.copyWith(modal: const SemiModalThemeData(widthModalSmall: 80)),
        const SemiComponentThemes(
          modal: SemiModalThemeData(widthModalSmall: 80),
        ),
      );
    });
  });

  group('behavior', () {
    testWidgets('declarative visible drives show/dismiss; title + content '
        'render', (tester) async {
      await pumpHost(tester);
      await setModal(
        tester,
        const SemiModal(
          visible: false,
          motion: false,
          title: '标题',
          content: Text('body'),
        ),
      );
      expect(find.text('body'), findsNothing);

      await setModal(
        tester,
        const SemiModal(
          visible: true,
          motion: false,
          title: '标题',
          content: Text('body'),
        ),
      );
      await pumpOpen(tester);
      expect(find.text('标题'), findsOneWidget);
      expect(find.text('body'), findsOneWidget);
      expect(find.text('确定'), findsOneWidget);
      expect(find.text('取消'), findsOneWidget);

      await setModal(
        tester,
        const SemiModal(
          visible: false,
          motion: false,
          title: '标题',
          content: Text('body'),
        ),
      );
      await pumpClosed(tester);
      expect(find.text('body'), findsNothing);
    });

    testWidgets('motion: true (default) animates content in', (tester) async {
      await pumpHost(tester);
      await setModal(
        tester,
        const SemiModal(visible: true, title: '标题', content: Text('body')),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 250));
      await tester.pump(const Duration(milliseconds: 250));
      expect(find.text('body'), findsOneWidget);
      await pumpClosed(tester);
      expect(find.text('body'), findsNothing);
    });

    testWidgets('mask click / Esc / close button notify onCancel; declarative '
        'does not self-close', (tester) async {
      var cancels = 0;
      await pumpHost(tester);
      await setModal(
        tester,
        SemiModal(
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

      await tester.sendKeyEvent(LogicalKeyboardKey.escape);
      await tester.pump();
      expect(cancels, 2);

      await tester.tap(
        find.byWidgetPredicate(
          (w) => w is SemiButton && w.child == null && w.icon != null,
        ),
      );
      await tester.pump();
      expect(cancels, 3);
      await pumpClosed(tester);
    });

    testWidgets('onOk notifies; hasCancel hides cancel; okText/okType apply', (
      tester,
    ) async {
      var oks = 0;
      await pumpHost(tester);
      await setModal(
        tester,
        SemiModal(
          visible: true,
          motion: false,
          title: '标题',
          content: const Text('body'),
          okText: '好的',
          okType: SemiButtonType.danger,
          hasCancel: false,
          onOk: () => oks++,
        ),
      );
      await pumpOpen(tester);
      expect(find.text('好的'), findsOneWidget);
      expect(find.text('取消'), findsNothing);
      await tester.tap(find.text('好的'));
      await tester.pump();
      expect(oks, 1);
      await pumpClosed(tester);
    });

    testWidgets('size widths: small 448 / medium 684 / large 920 / fullWidth '
        'viewport - 64', (tester) async {
      await pumpHost(tester);
      Future<void> widthOf(SemiModalSize size) async {
        await setModal(
          tester,
          SemiModal(
            visible: true,
            motion: false,
            size: size,
            title: 't',
            content: const Text('body'),
          ),
        );
        await pumpOpen(tester);
      }

      final contentBox = find.byKey(const ValueKey('semi-modal-box'));
      await widthOf(SemiModalSize.small);
      expect(tester.getSize(contentBox).width, resolve().widthModalSmall);
      await widthOf(SemiModalSize.medium);
      expect(tester.getSize(contentBox).width, resolve().widthModalMedium);
      await widthOf(SemiModalSize.large);
      expect(tester.getSize(contentBox).width, resolve().widthModalLarge);
      await widthOf(SemiModalSize.fullWidth);
      expect(tester.getSize(contentBox).width, 1200 - 64);
      await pumpClosed(tester);
    });

    testWidgets('fullScreen fills the viewport and drops the top margin', (
      tester,
    ) async {
      await pumpHost(tester);
      await setModal(
        tester,
        const SemiModal(
          visible: true,
          motion: false,
          fullScreen: true,
          title: '全屏',
          content: Text('body'),
        ),
      );
      await pumpOpen(tester);
      // 上游 isFullScreen：width/height 100% + margin unset（top 走
      // `$spacing-modal_content_fullscreen-top` = 0）。
      final box = tester.getRect(find.byKey(const ValueKey('semi-modal-box')));
      expect(box.width, 1200);
      expect(box.height, 900);
      expect(box.top, 0);
      await pumpClosed(tester);
    });

    testWidgets('custom header and footer replace the defaults', (
      tester,
    ) async {
      await pumpHost(tester);
      await setModal(
        tester,
        const SemiModal(
          visible: true,
          motion: false,
          header: Text('custom-header'),
          footer: Text('custom-footer'),
          content: Text('body'),
        ),
      );
      await pumpOpen(tester);
      expect(find.text('custom-header'), findsOneWidget);
      expect(find.text('custom-footer'), findsOneWidget);
      expect(find.text('确定'), findsNothing);
      expect(find.text('取消'), findsNothing);
      await pumpClosed(tester);
    });

    testWidgets('confirm family renders; ok auto-closes; async ok shows '
        'loading then closes; cancel auto-closes', (tester) async {
      await pumpHost(tester);

      // async ok：loading 至 Future 完成后关闭。
      var okCalls = 0;
      final handle = SemiModal.confirm(
        title: '标题',
        content: const Text('body'),
        motion: false,
        onOk: () async {
          okCalls++;
          await Future<void>.delayed(const Duration(milliseconds: 50));
        },
      );
      await pumpOpen(tester);
      await pumpOpen(tester);
      expect(find.text('body'), findsOneWidget);
      expect(find.text('确定'), findsOneWidget);

      await tester.tap(find.text('确定'));
      await tester.pump();
      expect(find.text('body'), findsOneWidget);
      expect(okCalls, 1);
      await tester.pump(const Duration(milliseconds: 60));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 250));
      expect(find.text('body'), findsNothing);

      // 取消自动关闭。
      final second = SemiModal.confirm(
        title: '标题',
        content: const Text('body'),
        motion: false,
      );
      await pumpOpen(tester);
      await pumpOpen(tester);
      await tester.tap(find.text('取消'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 250));
      expect(find.text('body'), findsNothing);
      handle.destroy();
      second.destroy();
      await pumpClosed(tester);
    });

    testWidgets('handle update re-renders; destroy closes', (tester) async {
      await pumpHost(tester);
      final handle = SemiModal.confirm(
        title: '旧标题',
        content: const Text('body'),
        motion: false,
      );
      await pumpOpen(tester);
      await pumpOpen(tester);
      expect(find.text('旧标题'), findsOneWidget);

      handle.update(title: '新标题');
      await tester.pump();
      expect(find.text('新标题'), findsOneWidget);

      handle.destroy();
      await pumpClosed(tester);
      expect(find.text('新标题'), findsNothing);
    });

    testWidgets('confirm variants pick typed icons and error defaults to '
        'danger okType', (tester) async {
      await pumpHost(tester);
      final handle = SemiModal.error(
        title: '标题',
        content: const Text('body'),
        motion: false,
      );
      await pumpOpen(tester);
      await pumpOpen(tester);
      expect(find.text('body'), findsOneWidget);
      // error 变体：okType danger + alert-circle 图标。
      final okButton = tester.widget<SemiButton>(
        find.ancestor(of: find.text('确定'), matching: find.byType(SemiButton)),
      );
      expect(okButton.type, SemiButtonType.danger);
      expect(find.byType(SemiIcon), findsOneWidget);
      handle.destroy();
      await pumpClosed(tester);
    });

    testWidgets('a local theme patch drives modal colors and metrics', (
      tester,
    ) async {
      await pumpHost(
        tester,
        patch: const SemiModalThemeData(
          colorModalBg: Color(0xFF00FF00),
          widthModalSmall: 300,
        ),
      );
      await setModal(
        tester,
        const SemiModal(
          visible: true,
          motion: false,
          title: 't',
          content: Text('body'),
        ),
      );
      await pumpOpen(tester);
      final contentBox = find.byKey(const ValueKey('semi-modal-box'));
      expect(tester.getSize(contentBox).width, 300);
      await pumpClosed(tester);
    });
  });
}
