// Behavior matrix for SemiNotification plus coverage for the 43 Sass
// declarations (35 FIELDS + 8 MOTION + 0 INTERNAL) — the 47 HARDCODES
// provenance anchors live in the widget's file-level note block / call sites.
// 1 条死 FIELDS（`$spacing-notification_notice-marginRight`，死变量留档不
// 消费）。
import 'dart:io';

import 'package:flutter/gestures.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:semi_design_flutter/semi_design_flutter.dart';
import 'package:semi_design_flutter/src/overlay/dialog_engine/helper/dialog_proxy.dart';
import 'package:semi_design_flutter/src/overlay/dialog_engine/helper/smart_dialog_test_state.dart';

Widget _host({SemiNotificationThemeData? patch}) {
  Widget app = SemiTheme(
    data: const SemiThemeData.light(),
    child: Directionality(
      textDirection: TextDirection.ltr,
      child: MediaQuery(
        data: const MediaQueryData(size: Size(1200, 900)),
        child: Overlay(
          initialEntries: [
            OverlayEntry(builder: (context) => const SizedBox.expand()),
          ],
        ),
      ),
    ),
  );
  if (patch != null) {
    app = SemiNotificationTheme(data: patch, child: app);
  }
  return app;
}

Future<void> pumpHost(WidgetTester tester) async {
  addTearDown(() async {
    // 引擎的 display/least-loading 计时器要冲掉（上游 disposeSmartDialogApp
    // 双冲洗次序：存活时冲 → 卸载 → reset → 再冲）。
    await tester.pump(const Duration(seconds: 3));
    SemiNotification.resetForTest();
    await tester.pump();
    SmartDialogTestState.reset();
    await tester.pump(const Duration(seconds: 3));
    await tester.pump();
  });
  await tester.binding.setSurfaceSize(const Size(1200, 900));
  await tester.pumpWidget(_host());
  await tester.pump();
  // 裸宿主无 SemiApp/observer——手动绑定（引擎逃生口）。
  DialogProxy.instance.bind(tester.state<OverlayState>(find.byType(Overlay)));
  await tester.pump();
}

/// 弹层入场泵帧（引擎 insert 1 帧 + 宿主 flush 1 帧 + 入场帧；不推进时钟）。
Future<void> pumpOpen(WidgetTester tester) async {
  await tester.pump();
  await tester.pump();
  await tester.pump();
}

/// 入场动画收尾（300ms show——几何/命中断言前先落位）。
Future<void> settleEnter(WidgetTester tester) async {
  await tester.pump(const Duration(milliseconds: 350));
  await tester.pump();
}

/// 退场收尾：先泵帧启动 reverse（pump(duration) 先走钟后建帧），再跨过
/// 300ms leave，最后释放 postFrame + 重建移除。
Future<void> pumpLeave(WidgetTester tester) async {
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 350));
  await tester.pump();
  await tester.pump();
}

Finder typeIcon(SemiIconData data) =>
    find.byWidgetPredicate((w) => w is SemiIcon && w.data == data);

/// 标题文本所在卡片（定位断言取整卡而非 Text）。
Finder cardOf(String title) => find.ancestor(
  of: find.text(title),
  matching: find.byType(SemiNotificationNotice),
);

SemiResolvedNotificationThemeData resolve() =>
    const SemiNotificationThemeData().resolve(const SemiThemeData.light());

void main() {
  group('theme fields (43 = 35 FIELDS + 8 MOTION + 0 INTERNAL)', () {
    test('43 fields: merge, copyWith, resolve, equality, defaults', () {
      final light = const SemiThemeData.light();
      final t = const SemiNotificationThemeData().resolve(light);
      expect(t.colorNotificationBgDefault, light.colors.colorBg3);
      expect(t.colorNotificationInfoIcon, light.colors.colorInfo);
      expect(t.colorNotificationWarningIcon, light.colors.colorWarning);
      expect(t.colorNotificationDangerIcon, light.colors.colorDanger);
      expect(t.colorNotificationSuccessIcon, light.colors.colorSuccess);
      expect(t.colorNotificationTitleText, light.colors.colorText0);
      expect(t.colorNotificationContentText, light.colors.colorText1);
      expect(t.colorNotificationCloseBtnIcon, light.colors.colorText2);
      expect(
        t.colorNotificationWarningLightBg,
        light.colors.colorWarningLightDefault,
      );
      expect(t.colorNotificationWarningLightBorder, light.colors.colorWarning);
      expect(
        t.colorNotificationSuccessLightBg,
        light.colors.colorSuccessLightDefault,
      );
      expect(t.colorNotificationSuccessLightBorder, light.colors.colorSuccess);
      expect(
        t.colorNotificationInfoLightBg,
        light.colors.colorInfoLightDefault,
      );
      expect(t.colorNotificationInfoLightBorder, light.colors.colorInfo);
      expect(
        t.colorNotificationDangerLightBg,
        light.colors.colorDangerLightDefault,
      );
      expect(t.colorNotificationDangerLightBorder, light.colors.colorDanger);
      expect(t.colorNotificationAmbientBg, light.colors.colorBg0);
      expect(t.widthNotificationNotice, 'auto');
      expect(t.widthNotificationNoticeMinWidth, 320);
      expect(t.widthNotificationNoticeIcon, 24);
      expect(t.widthNotificationNoticeBorder, 1);
      expect(t.spacingNotificationListMargin, 0);
      expect(t.spacingNotificationListPadding, 0);
      expect(t.spacingNotificationNoticePaddingTop, 16);
      expect(t.spacingNotificationNoticePaddingRight, 12);
      expect(t.spacingNotificationNoticePaddingBottom, 16);
      expect(t.spacingNotificationNoticePaddingLeft, 20);
      expect(t.spacingNotificationNoticeMargin, 20);
      // 死变量留档不消费——resolve 默认仍对账（widget 不读该字段）。
      expect(t.spacingNotificationNoticeMarginRight, 12);
      expect(t.spacingNotificationNoticeTitleMarginBottom, 4);
      expect(t.spacingNotificationNoticeContentWrapperMarginRight, 8);
      expect(t.spacingNotificationNoticeIconMarginRight, 12);
      expect(t.radiusNotificationNotice, light.radius.borderRadiusMedium.value);
      expect(t.fontNotificationNoticeTitleFontWeight, FontWeight.w600);
      expect(t.fontNotificationNoticeContentFontWeight, FontWeight.w400);
      expect(
        t.animationDurationNotificationShow,
        const Duration(milliseconds: 300),
      );
      expect(
        t.animationDurationNotificationHide,
        const Duration(milliseconds: 300),
      );
      const curve = Cubic(0.62, 0.63, 0, 1.13);
      expect(
        semiCurveEquals(t.animationFunctionNotificationShow, curve),
        isTrue,
      );
      expect(
        semiCurveEquals(t.animationFunctionNotificationHide, curve),
        isTrue,
      );
      expect(t.animationDelayNotificationShow, Duration.zero);
      expect(t.animationDelayNotificationHide, Duration.zero);
      expect(t.animationOpacityNotificationShow, 0);
      expect(t.animationOpacityNotificationHide, 0);

      // copyWith / merge / equality。
      const patch = SemiNotificationThemeData(
        widthNotificationNoticeMinWidth: 400,
      );
      expect(
        const SemiNotificationThemeData().copyWith(),
        const SemiNotificationThemeData(),
      );
      expect(
        const SemiNotificationThemeData().merge(null),
        const SemiNotificationThemeData(),
      );
      expect(
        patch
            .merge(const SemiNotificationThemeData(radiusNotificationNotice: 1))
            .widthNotificationNoticeMinWidth,
        400,
      );
      expect(
        patch,
        const SemiNotificationThemeData(widthNotificationNoticeMinWidth: 400),
      );
      expect(patch, isNot(const SemiNotificationThemeData()));
      expect(
        patch.hashCode,
        const SemiNotificationThemeData(widthNotificationNoticeMinWidth: 400)
            .hashCode,
      );
    });

    test('every field carries its Sass provenance in the generated source', () {
      final source = File('lib/src/theme/semi_notification_theme_data.dart')
          .readAsStringSync();
      const declarations = [
        r'$color-notification-bg-default: var(--semi-color-bg-3)',
        r'$color-notification_info-icon: var(--semi-color-info)',
        r'$color-notification_warning-icon: var(--semi-color-warning)',
        r'$color-notification_danger-icon: var(--semi-color-danger)',
        r'$color-notification_success-icon: var(--semi-color-success)',
        r'$color-notification_title-text: var(--semi-color-text-0)',
        r'$color-notification_content-text: var(--semi-color-text-1)',
        r'$color-notification_closeBtn-icon: var(--semi-color-text-2)',
        r'$color-notification_warning_light-bg: var(--semi-color-warning-light-default)',
        r'$color-notification_warning_light-border: var(--semi-color-warning)',
        r'$color-notification_success_light-bg: var(--semi-color-success-light-default)',
        r'$color-notification_success_light-border: var(--semi-color-success)',
        r'$color-notification_info_light-bg: var(--semi-color-info-light-default)',
        r'$color-notification_info_light-border: var(--semi-color-info)',
        r'$color-notification_danger_light-bg: var(--semi-color-danger-light-default)',
        r'$color-notification_danger_light-border: var(--semi-color-danger)',
        r'$color-notification_ambient-bg: var(--semi-color-bg-0)',
        r'$width-notification_notice: auto',
        r'$width-notification_notice_minWidth: 320px',
        r'$width-notification_notice-icon: $width-icon-extra-large',
        r'$width-notification_notice-border: 1px',
        r'$spacing-notification_list-margin: 0',
        r'$spacing-notification_list-padding: 0',
        r'$spacing-notification_notice-paddingTop: $spacing-base',
        r'$spacing-notification_notice-paddingRight: $spacing-base-tight',
        r'$spacing-notification_notice-paddingBottom: $spacing-base',
        r'$spacing-notification_notice-paddingLeft: $spacing-base-loose',
        r'$spacing-notification_notice-margin: $spacing-base-loose',
        r'$spacing-notification_notice-marginRight: $spacing-base-tight',
        r'$spacing-notification_notice_title-marginBottom: $spacing-extra-tight',
        r'$spacing-notification_notice_content_wrapper-marginRight: 8px',
        r'$spacing-notification_notice_icon-marginRight: $spacing-base-tight',
        r'$radius-notification_notice: var(--semi-border-radius-medium)',
        r'$font-notification_notice_title-fontWeight: $font-weight-bold',
        r'$font-notification_notice_content-fontWeight: $font-weight-regular',
        r'$animation_duration-notification-show: 300ms',
        r'$animation_function-notification-show: cubic-bezier(0.62, 0.63, 0, 1.13)',
        r'$animation_delay-notification-show: 0ms',
        r'$animation_duration-notification-hide: 300ms',
        r'$animation_function-notification-hide: cubic-bezier(0.62, 0.63, 0, 1.13)',
        r'$animation_delay-notification-hide: 0ms',
        r'$animation_opacity-notification-show: 0',
        r'$animation_opacity-notification-hide: 0',
      ];
      expect(declarations, hasLength(43));
      for (final decl in declarations) {
        expect(source, contains(decl), reason: decl);
      }
      expect(source, contains('Generated by tool/generate_notification.py'));
    });

    test('the 47 HARDCODES anchors live in the widget source', () {
      final widgetSource = File('lib/src/components/semi_notification.dart')
          .readAsStringSync();
      const anchors = <String>[
        "types: ['warning', 'success', 'info', 'error', 'default']",
        "themes: ['normal', 'light']",
        "directions: ['ltr', 'rtl']",
        'duration: 3',
        'showClose: true',
        "theme: 'normal'",
        "position: 'topRight'",
        'zIndex: 1010',
        "title: ''",
        "content: ''",
        'title ? (',
        'content ? (',
        'IconClose',
        'IconAlertTriangle',
        'IconTickCircle',
        'IconInfoCircle',
        'IconAlertCircle',
        'size="large"',
        'theme="borderless"',
        'size="small"',
        'type="tertiary"',
        'role="alert"',
        'aria-labelledby',
        'semi-notification-notice-title',
        "size: iconType.props.size || 'large'",
        'types.includes(type)',
        'onMouseEnter',
        'onMouseLeave',
        'e.stopPropagation()',
        'word-wrap: break-word',
        'background-image: linear-gradient(0deg,',
        r'background-color: $color-notification_ambient-bg',
        '@include shadow-elevated',
        '@include font-size-header-6',
        '@include font-size-regular',
        r'height: $width-icon-extra-large',
        r'z-index: $z-notification',
        'pointer-events: none',
        'pointer-events: auto',
        'translateY(-100%)',
        'translateY(100%)',
        'translateX(-100%)',
        'translateX(100%)',
        'appliedUpdates',
        'restartCloseTimer',
        'scheduleRemovedNoticeRelease',
        'getPopupContainer',
      ];
      expect(anchors, hasLength(47));
      for (final anchor in anchors) {
        expect(widgetSource, contains(anchor), reason: anchor);
      }
    });

    test('dead variable marked 留档不消费, docs carry the accounting', () {
      final docs = File('docs/semi_notification.md').readAsStringSync();
      expect(docs, contains('43 = 35 FIELDS + 8 MOTION + 0 INTERNAL'));
      expect(docs, contains('死变量'));
      final rows = docs
          .split('\n')
          .where(
            (line) =>
                line.contains(r'$spacing-notification_notice-marginRight:'),
          );
      expect(rows, isNotEmpty);
      expect(rows.any((line) => line.contains('（上游未消费）')), isTrue);
      // 死变量字段名不出现在 widget（留档不消费）。
      final widgetSource = File('lib/src/components/semi_notification.dart')
          .readAsStringSync();
      expect(
        widgetSource,
        isNot(contains('spacingNotificationNoticeMarginRight')),
      );
    });

    test('SemiComponentThemes wiring', () {
      const themes = SemiComponentThemes();
      expect(themes.notification, const SemiNotificationThemeData());
      expect(
        themes.copyWith(
          notification: const SemiNotificationThemeData(
            widthNotificationNoticeMinWidth: 80,
          ),
        ),
        const SemiComponentThemes(
          notification: SemiNotificationThemeData(
            widthNotificationNoticeMinWidth: 80,
          ),
        ),
      );
    });
  });

  group('behavior', () {
    testWidgets('open renders title + content at topRight; falsy title/content '
        '不渲染', (tester) async {
      await pumpHost(tester);
      SemiNotification.open(
        id: 'a',
        title: 'Hi, Bytedance',
        content: 'ies dance dance dance',
        duration: Duration.zero,
      );
      await pumpOpen(tester);
      expect(find.text('Hi, Bytedance'), findsOneWidget);
      expect(find.text('ies dance dance dance'), findsOneWidget);
      await settleEnter(tester);
      // 缺省 `position: 'topRight'`——卡片贴右上（纵向 margin 折叠对拆 10、
      // 横向 20）。
      final rect = tester.getRect(find.byType(SemiNotificationNotice));
      expect(rect.top, moreOrLessEquals(10, epsilon: 0.5));
      expect(rect.right, moreOrLessEquals(1180, epsilon: 0.5));
      // 标题 16/22 排版（`@include font-size-header-6`）。
      final title = tester.widget<Text>(find.text('Hi, Bytedance'));
      expect(title.style?.fontSize, 16);
      expect(title.style?.fontWeight, FontWeight.w600);

      // `{title ? (…) : ''}` 纯 truthy——数字 0/空串不渲染。
      SemiNotification.open(id: 'b', title: 0, content: '');
      await pumpOpen(tester);
      expect(find.text('0'), findsNothing);
      expect(find.byType(SemiNotificationNotice), findsNWidgets(2));
    });

    testWidgets('type icons: success/info/error/warning 有图标、open 无', (
      tester,
    ) async {
      await pumpHost(tester);
      SemiNotification.success(id: 's', title: 's', duration: Duration.zero);
      SemiNotification.info(id: 'i', title: 'i', duration: Duration.zero);
      SemiNotification.error(id: 'e', title: 'e', duration: Duration.zero);
      SemiNotification.warning(id: 'w', title: 'w', duration: Duration.zero);
      SemiNotification.open(id: 'n', title: 'n', duration: Duration.zero);
      await pumpOpen(tester);
      expect(typeIcon(SemiIcons.tickCircle), findsOneWidget);
      expect(typeIcon(SemiIcons.infoCircle), findsOneWidget);
      expect(typeIcon(SemiIcons.alertCircle), findsOneWidget);
      expect(typeIcon(SemiIcons.alertTriangle), findsOneWidget);
      // 'default'（open）无类型图标——仅关闭钮图标。
      expect(typeIcon(SemiIcons.close), findsNWidgets(5));
    });

    testWidgets('light variant 出语义色描边 + 覆盖层底色', (tester) async {
      await pumpHost(tester);
      SemiNotification.warning(
        id: 'l',
        title: 'light',
        duration: Duration.zero,
        variant: SemiNotificationVariant.light,
      );
      await pumpOpen(tester);
      final t = resolve();
      final containers = tester
          .widgetList<Container>(
            find.descendant(
              of: find.byType(SemiNotificationNotice),
              matching: find.byType(Container),
            ),
          )
          .where((c) => c.decoration is BoxDecoration);
      final box = containers.first.decoration! as BoxDecoration;
      // `background-image` 覆盖层与 `background-color:
      // $color-notification_ambient-bg` 底色 alpha 合成 + 1px warning 描边。
      expect(
        box.color,
        Color.alphaBlend(
          t.colorNotificationWarningLightBg,
          t.colorNotificationAmbientBg,
        ),
      );
      expect(box.border?.top.color, t.colorNotificationWarningLightBorder);
      expect(box.border?.top.width, t.widthNotificationNoticeBorder);
    });

    testWidgets('duration 自动关闭触发 onClose；zero 固定不关', (tester) async {
      await pumpHost(tester);
      var closed = 0;
      SemiNotification.info(
        id: 'auto',
        title: 'auto',
        duration: const Duration(seconds: 1),
        onClose: () => closed++,
      );
      SemiNotification.info(id: 'pin', title: 'pin', duration: Duration.zero);
      await pumpOpen(tester);
      await tester.pump(const Duration(milliseconds: 900));
      expect(find.text('auto'), findsOneWidget);
      expect(closed, 0);
      await tester.pump(const Duration(milliseconds: 200));
      // foundation.close：notifyClose 计时器路径触发 onClose（无 onCloseClick）。
      expect(closed, 1);
      await pumpLeave(tester);
      expect(find.text('auto'), findsNothing);
      await tester.pump(const Duration(seconds: 10));
      expect(find.text('pin'), findsOneWidget);
    });

    testWidgets('悬停暂停计时（onMouseEnter/onMouseLeave），leaving 不恢复', (
      tester,
    ) async {
      await pumpHost(tester);
      var closed = 0;
      SemiNotification.info(
        id: 'h',
        title: 'hover',
        duration: const Duration(seconds: 1),
        onClose: () => closed++,
      );
      await pumpOpen(tester);
      await settleEnter(tester);
      final gesture = await tester.createGesture(kind: PointerDeviceKind.mouse);
      await gesture.addPointer(location: Offset.zero);
      addTearDown(gesture.removePointer);
      await gesture.moveTo(
        tester.getCenter(find.byType(SemiNotificationNotice)),
      );
      await tester.pump(const Duration(seconds: 2));
      // 悬停远超 duration——计时暂停。
      expect(find.text('hover'), findsOneWidget);
      expect(closed, 0);
      await gesture.moveTo(const Offset(5, 800));
      await tester.pump(const Duration(seconds: 1));
      expect(closed, 1);
      await pumpLeave(tester);
      expect(find.text('hover'), findsNothing);
    });

    testWidgets('关闭钮：onCloseClick(id) 先行 + onClose + 移除（无冒泡 '
        'onClick）', (tester) async {
      await pumpHost(tester);
      String? clicked;
      var closed = 0;
      var clickedCard = 0;
      SemiNotification.info(
        id: 'c',
        title: 'close me',
        duration: Duration.zero,
        onCloseClick: (id) => clicked = id,
        onClose: () => closed++,
        onClick: () => clickedCard++,
      );
      await pumpOpen(tester);
      await settleEnter(tester);
      await tester.tap(find.byType(SemiButton));
      await tester.pump();
      expect(clicked, 'c');
      expect(closed, 1);
      // `e.stopPropagation()`——关闭钮点击不触发卡片 onClick。
      expect(clickedCard, 0);
      await pumpLeave(tester);
      expect(find.text('close me'), findsNothing);

      // showClose: false 无关闭钮。
      SemiNotification.info(
        id: 'nc',
        title: 'no closer',
        duration: Duration.zero,
        showClose: false,
      );
      await pumpOpen(tester);
      expect(find.byType(SemiButton), findsNothing);
    });

    testWidgets('close(id) 静默移除（无 onClose/onCloseClick）', (tester) async {
      await pumpHost(tester);
      var closed = 0;
      final id = SemiNotification.info(
        id: 's',
        title: 'silent',
        duration: Duration.zero,
        onClose: () => closed++,
      );
      await pumpOpen(tester);
      SemiNotification.close(id);
      expect(closed, 0);
      await pumpLeave(tester);
      expect(find.text('silent'), findsNothing);
    });

    testWidgets('同 id 更新就地生效 + 重启计时（appliedUpdates 一次）', (tester) async {
      await pumpHost(tester);
      var closed = 0;
      SemiNotification.info(
        id: 'u',
        title: 'Initial',
        duration: const Duration(seconds: 1),
        onClose: () => closed++,
      );
      await pumpOpen(tester);
      await tester.pump(const Duration(milliseconds: 500));
      SemiNotification.info(
        id: 'u',
        title: 'Updated',
        duration: const Duration(seconds: 1),
      );
      await tester.pump();
      await tester.pump();
      expect(find.text('Updated'), findsOneWidget);
      expect(find.text('Initial'), findsNothing);
      // 计时在 t=0.5s 重启（deadline ≈ 1.5s）——0.6s 后未关。
      await tester.pump(const Duration(milliseconds: 600));
      expect(closed, 0);
      expect(find.text('Updated'), findsOneWidget);
      await tester.pump(const Duration(milliseconds: 500));
      expect(closed, 1);
      await pumpLeave(tester);
      expect(find.text('Updated'), findsNothing);
    });

    testWidgets('leave 动画：motion 按 placement 滑出后释放；false 即释', (tester) async {
      await pumpHost(tester);
      final id = SemiNotification.info(
        id: 'm',
        title: 'anim',
        duration: Duration.zero,
      );
      final snap = SemiNotification.info(
        id: 'n',
        title: 'snap',
        duration: Duration.zero,
        motion: false,
      );
      await pumpOpen(tester);
      SemiNotification.close(id);
      await tester.pump();
      // leaving 仍渲染（动画中）。
      expect(find.text('anim'), findsOneWidget);
      await pumpLeave(tester);
      expect(find.text('anim'), findsNothing);
      // `motion: false`：无 leave 动画，即刻释放。
      SemiNotification.close(snap);
      await tester.pump();
      await tester.pump();
      await tester.pump();
      expect(find.text('snap'), findsNothing);
    });

    testWidgets('destroyAll 瞬时卸载全部（无 leave 动画）', (tester) async {
      await pumpHost(tester);
      SemiNotification.info(id: 'a', title: 'a', duration: Duration.zero);
      SemiNotification.info(id: 'b', title: 'b', duration: Duration.zero);
      await pumpOpen(tester);
      expect(find.text('a'), findsOneWidget);
      SemiNotification.destroyAll();
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      await tester.pump();
      expect(find.text('a'), findsNothing);
      expect(find.text('b'), findsNothing);
    });

    testWidgets('positions 六向分组 + config 偏移（setPosInStyle 首条）', (tester) async {
      await pumpHost(tester);
      SemiNotification.info(
        id: 't',
        title: 'top',
        duration: Duration.zero,
        position: SemiNotificationPosition.top,
      );
      SemiNotification.info(
        id: 'bl',
        title: 'bottomLeft',
        duration: Duration.zero,
        position: SemiNotificationPosition.bottomLeft,
      );
      await pumpOpen(tester);
      await settleEnter(tester);
      final topRect = tester.getRect(cardOf('top'));
      final blRect = tester.getRect(cardOf('bottomLeft'));
      // top：水平居中（`left: 50%` + `translateX(-50%)`）。
      expect(topRect.center.dx, moreOrLessEquals(600, epsilon: 1));
      // bottomLeft：贴左下（横向 margin 20、纵向折叠对拆 10）。
      expect(blRect.left, moreOrLessEquals(20, epsilon: 1));
      expect(blRect.bottom, moreOrLessEquals(890, epsilon: 1));

      // config 偏移只影响后续 add（上游 defaultConfig 合并语义）。
      SemiNotification.config(top: 400, left: 300);
      SemiNotification.info(
        id: 'off',
        title: 'offset',
        duration: Duration.zero,
        position: SemiNotificationPosition.top,
      );
      await pumpOpen(tester);
      await settleEnter(tester);
      final offRect = tester.getRect(cardOf('offset'));
      expect(offRect.top, moreOrLessEquals(410, epsilon: 1));
    });
  });
}
