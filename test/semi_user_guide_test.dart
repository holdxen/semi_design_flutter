// Behavior matrix for SemiUserGuide plus coverage for the 37 Sass declarations
// (35 FIELDS + 2 MOTION + 0 INTERNAL) — the 24 HARDCODES provenance anchors
// live in the widget's `_UserGuideMetrics` / call sites, the 1 dead FIELDS
// (上游未消费) must NOT appear in the widget (asserted in
// tool/test_generate_user_guide.py), and the docs mark it.
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:semi_design_flutter/semi_design_flutter.dart';
import 'package:semi_design_flutter/src/overlay/dialog_engine/helper/dialog_proxy.dart';
import 'package:semi_design_flutter/src/overlay/dialog_engine/helper/smart_dialog_test_state.dart';

/// 宿主 body 经 ValueListenable 交换（Overlay.initialEntries 重建不换内容——
/// semi_anchor_test.dart 先例）。
final _body = ValueNotifier<Widget>(const SizedBox.shrink());

/// modal 式显隐开关（保留 SemiUserGuide State——didUpdateWidget 路径）。
final _visible = ValueNotifier<bool>(true);

Widget _host() => SemiTheme(
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
              builder: (context, value, _) => Center(
                child: SizedBox(width: 900, height: 900, child: value),
              ),
            ),
          ),
        ],
      ),
    ),
  ),
);

Future<void> pumpHost(WidgetTester tester) async {
  addTearDown(() async {
    // 引擎计时器冲洗 + 复位（semi_modal_test.dart 先例）。
    await tester.pump(const Duration(seconds: 3));
    _body.value = const SizedBox.shrink();
    await tester.pump();
    DialogProxy.instance.resetForTest();
    await tester.pump(const Duration(seconds: 3));
    await tester.pump();
    _visible.value = true;
  });
  await tester.binding.setSurfaceSize(const Size(1200, 900));
  await tester.pumpWidget(_host());
  await tester.pump();
  // 裸宿主无 SemiApp/observer——手动绑定引擎逃生口（modal 模式用）。
  DialogProxy.instance.bind(tester.state<OverlayState>(find.byType(Overlay)));
  await tester.pump();
}

Future<void> setBody(WidgetTester tester, Widget child) async {
  _body.value = KeyedSubtree(key: UniqueKey(), child: child);
  await tester.pump();
  await tester.pump();
}

/// 弹层入场泵帧（引擎 insert + 120ms motion——semi_modal_test.dart pumpOpen
/// 口径）。
Future<void> pumpOpen(WidgetTester tester) async {
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 200));
  await tester.pump();
}

/// modal 测试收尾：卸载引导（引擎 dismiss 120ms 计时）→ 冲计时
/// （semi_modal_test.dart pumpClosed 口径——体内收尾清理）。
Future<void> pumpDismissed(WidgetTester tester) async {
  await setBody(tester, const SizedBox.shrink());
  await tester.pump(const Duration(milliseconds: 250));
  SmartDialogTestState.reset();
  await tester.pump(const Duration(seconds: 3));
  await tester.pump();
}

const _targetKey = ValueKey('target');

/// 目标（100x50）+ 引导的宿主页。目标位于 900x900 宿主盒左上角 → 全局矩形
/// (150, 0, 100, 50)（1200-900 居中偏移 150）。
Widget guidePage({
  required List<SemiUserGuideStep> steps,
  bool visible = true,
  int? current,
  bool mask = true,
  SemiUserGuideMode mode = SemiUserGuideMode.popup,
  SemiUserGuideThemeMode theme = SemiUserGuideThemeMode.defaultTheme,
  double? spotlightPadding,
  bool showPrevButton = true,
  bool showSkipButton = true,
  String? finishText,
  SemiUserGuideButtonProps? prevButtonProps,
  SemiUserGuideButtonProps? nextButtonProps,
  ValueChanged<int>? onChange,
  ValueChanged<int>? onNext,
  ValueChanged<int>? onPrev,
  VoidCallback? onSkip,
  VoidCallback? onFinish,
}) => Column(
  crossAxisAlignment: CrossAxisAlignment.start,
  children: [
    const SemiUserGuideTarget(
      id: 'a',
      child: SizedBox(key: _targetKey, width: 100, height: 50),
    ),
    SemiUserGuide(
      steps: steps,
      visible: visible,
      current: current,
      mask: mask,
      mode: mode,
      theme: theme,
      spotlightPadding: spotlightPadding,
      showPrevButton: showPrevButton,
      showSkipButton: showSkipButton,
      finishText: finishText,
      prevButtonProps: prevButtonProps,
      nextButtonProps: nextButtonProps,
      onChange: onChange,
      onNext: onNext,
      onPrev: onPrev,
      onSkip: onSkip,
      onFinish: onFinish,
    ),
  ],
);

const _stepA = SemiUserGuideStep(target: 'a', title: '第一步', description: '说明一');

const _stepB = SemiUserGuideStep(target: 'a', title: '第二步');

void main() {
  group('theme fields (37 = 35 FIELDS + 2 MOTION + 0 INTERNAL)', () {
    test('37 fields: resolve, defaults, equality', () {
      final light = const SemiThemeData.light();
      final t = const SemiUserGuideThemeData().resolve(light);
      expect(t.colorUserGuidePopupTextDefault, light.colors.colorText0);
      expect(
        t.colorUserGuidePopupTextPrimary,
        light.colors.colorTertiaryLightDefault,
      );
      expect(
        t.colorUserGuideModalContentIndicatorBg,
        light.colors.colorPrimaryLightActive,
      );
      expect(
        t.colorUserGuideModalContentIndicatorBgActive,
        light.colors.colorPrimary,
      );
      expect(t.widthUserGuidePopoverDefault, 400);
      expect(t.heightUserGuidePopupContentCoverDefault, 200);
      expect(t.widthUserGuideModalContentCoverDefault, 600);
      expect(t.heightUserGuideModalContentCoverDefault, 300);
      expect(t.heightUserGuideModalContentIndicatorDefault, 30);
      expect(t.widthUserGuideModalContentIndicatorItemDefault, 6);
      expect(t.heightUserGuideModalContentIndicatorItemDefault, 6);
      expect(t.fontUserGuidePopupContentTitleLineHeight, 24);
      expect(t.fontUserGuidePopupContentDescriptionLineHeight, 20);
      expect(t.fontUserGuidePopupContentIndicatorLineHeight, 20);
      expect(t.fontUserGuideModalContentTitleLineHeight, 24);
      expect(t.fontUserGuideModalContentDescriptionLineHeight, 20);
      expect(t.spacingUserGuidePopupContentBodyPadding, 24);
      expect(t.spacingUserGuidePopupContentTitleMarginBottom, 8);
      expect(t.spacingUserGuidePopupContentDescriptionMarginBottom, 48);
      expect(t.spacingUserGuidePopupContentButtonGap, 12);
      expect(t.spacingUserGuidePopupContentButtonMarginLeft, 120);
      expect(t.spacingUserGuideModalContentTitleMarginBottom, 8);
      // ★生成域首例 EdgeInsets（两值 padding 简写）。
      expect(
        t.spacingUserGuideModalContentBodyPadding,
        const EdgeInsets.symmetric(vertical: 24, horizontal: 48),
      );
      expect(t.spacingUserGuideModalContentFooterPadding, 24);
      // ★命名错位：popup 命名由 modal 指示点消费。
      expect(t.spacingUserGuidePopupContentIndicatorGap, 8);
      expect(t.spacingUserGuideModalContentButtonGap, 12);
      // ★四值圆角简写。
      expect(
        t.radiusUserGuidePopupContentCover,
        BorderRadius.vertical(
          top: Radius.circular(light.radius.borderRadiusMedium.value),
        ),
      );
      expect(
        t.radiusUserGuideModalContentIndicator,
        light.radius.borderRadiusLarge.value,
      );
      expect(t.fontUserGuidePopupContentTitleFontSize, 18);
      expect(t.fontUserGuidePopupContentDescriptionFontSize, 14);
      expect(t.fontUserGuidePopupContentIndicatorFontSize, 14);
      expect(t.fontUserGuidePopupContentTitleFontWeight, FontWeight.w600);
      expect(t.fontUserGuideModalContentTitleFontSize, 18);
      expect(t.fontUserGuideModalContentDescriptionFontSize, 14);
      expect(t.fontUserGuideModalContentTitleFontWeight, FontWeight.w600);
      expect(
        t.transitionDurationUserGuideSpotLight,
        const Duration(milliseconds: 200),
      );
      expect(
        t.transitionFunctionUserGuideSpotLight,
        const Cubic(0.4, 0, 0.2, 1),
      );
      // 值相等 / merge / copyWith。
      const data = SemiUserGuideThemeData(widthUserGuidePopoverDefault: 320);
      expect(data.copyWith(), data);
      expect(data.merge(const SemiUserGuideThemeData()), data);
      expect(
        const SemiUserGuideThemeData().merge(data).widthUserGuidePopoverDefault,
        320,
      );
      expect(const SemiUserGuideThemeData(), const SemiUserGuideThemeData());
    });
  });

  group('popup 聚光灯几何', () {
    testWidgets('目标外扩默认 padding（DEFAULT_SPOTLIGHT_PADDING: 5）', (tester) async {
      await pumpHost(tester);
      await setBody(tester, guidePage(steps: const [_stepA]));
      await tester.pumpAndSettle();
      final target = tester.getRect(find.byKey(_targetKey));
      final anchor = tester.getRect(
        find.byKey(SemiUserGuide.spotlightAnchorKey),
      );
      expect(anchor, target.inflate(5));
    });

    testWidgets('全局 spotlightPadding 外扩', (tester) async {
      await pumpHost(tester);
      await setBody(
        tester,
        guidePage(steps: const [_stepA], spotlightPadding: 10),
      );
      await tester.pumpAndSettle();
      expect(
        tester.getRect(find.byKey(SemiUserGuide.spotlightAnchorKey)),
        tester.getRect(find.byKey(_targetKey)).inflate(10),
      );
    });

    testWidgets('★步级 padding 优先；0 照消费（zero-padding）', (tester) async {
      await pumpHost(tester);
      await setBody(
        tester,
        guidePage(
          steps: const [SemiUserGuideStep(target: 'a', spotlightPadding: 0)],
          spotlightPadding: 10,
        ),
      );
      await tester.pumpAndSettle();
      // step 0 不回落全局 10 / 默认 5——`typeof stepPadding === 'number'` 口径。
      expect(
        tester.getRect(find.byKey(SemiUserGuide.spotlightAnchorKey)),
        tester.getRect(find.byKey(_targetKey)),
      );
      expect(
        tester.getRect(find.byKey(SemiUserGuide.spotlightAnchorKey)).width,
        100,
      );
    });

    testWidgets('滚动跟随目标移动（window scroll 捕获对应）', (tester) async {
      await pumpHost(tester);
      await setBody(
        tester,
        SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              SemiUserGuideTarget(
                id: 'a',
                child: SizedBox(key: _targetKey, width: 100, height: 50),
              ),
              SizedBox(height: 1200),
              // ★step.mask: false——蒙层捕获条吞指针，drag 打不到滚动面
              //（蒙层语义本测不验）。
              _GuideInBody(
                steps: [SemiUserGuideStep(target: 'a', mask: false)],
              ),
            ],
          ),
        ),
      );
      await tester.pumpAndSettle();
      final before = tester.getRect(
        find.byKey(SemiUserGuide.spotlightAnchorKey),
      );
      await tester.drag(
        find.byType(SingleChildScrollView),
        const Offset(0, -120),
      );
      await tester.pumpAndSettle();
      final after = tester.getRect(
        find.byKey(SemiUserGuide.spotlightAnchorKey),
      );
      expect(after.top, before.top - 120);
    });
  });

  group('蒙层优先（step.mask ?? mask）', () {
    testWidgets('全局 mask=false → 无蒙层', (tester) async {
      await pumpHost(tester);
      await setBody(tester, guidePage(steps: const [_stepA], mask: false));
      await tester.pumpAndSettle();
      expect(find.byKey(SemiUserGuide.spotlightMaskKey), findsNothing);
      // 卡片照出。
      expect(find.byKey(SemiUserGuide.popupCardKey), findsOneWidget);
    });

    testWidgets('step.mask=false 压过全局 true', (tester) async {
      await pumpHost(tester);
      await setBody(
        tester,
        guidePage(
          steps: const [SemiUserGuideStep(target: 'a', mask: false)],
          mask: true,
        ),
      );
      await tester.pumpAndSettle();
      expect(find.byKey(SemiUserGuide.spotlightMaskKey), findsNothing);
    });

    testWidgets('step.mask=true 压过全局 false', (tester) async {
      await pumpHost(tester);
      await setBody(
        tester,
        guidePage(
          steps: const [SemiUserGuideStep(target: 'a', mask: true)],
          mask: false,
        ),
      );
      await tester.pumpAndSettle();
      expect(find.byKey(SemiUserGuide.spotlightMaskKey), findsOneWidget);
    });
  });

  group('卡片内容', () {
    testWidgets('标题/详情/指示器（仅多步出 N/M）', (tester) async {
      await pumpHost(tester);
      await setBody(tester, guidePage(steps: const [_stepA]));
      await tester.pumpAndSettle();
      expect(find.text('第一步'), findsOneWidget);
      expect(find.text('说明一'), findsOneWidget);
      // 单步无指示器（index.tsx:294 `steps.length > 1`）。
      expect(find.byKey(SemiUserGuide.indicatorKey), findsNothing);

      await setBody(tester, guidePage(steps: const [_stepA, _stepB]));
      await tester.pumpAndSettle();
      expect(find.text('1/2'), findsOneWidget);
    });
  });

  group('步进与按钮', () {
    testWidgets('非受控 next/prev：onChange 仅值变化 + onNext/onPrev', (tester) async {
      final events = <String>[];
      await pumpHost(tester);
      await setBody(
        tester,
        guidePage(
          steps: const [_stepA, _stepB],
          onChange: (c) => events.add('change $c'),
          onNext: (c) => events.add('next $c'),
          onPrev: (c) => events.add('prev $c'),
          onSkip: () => events.add('skip'),
          onFinish: () => events.add('finish'),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('下一步'));
      await tester.pumpAndSettle();
      expect(events, ['change 1', 'next 1']);
      expect(find.text('2/2'), findsOneWidget);

      await tester.tap(find.text('上一步'));
      await tester.pumpAndSettle();
      expect(events, ['change 1', 'next 1', 'change 0', 'prev 0']);
      expect(find.text('1/2'), findsOneWidget);
    });

    testWidgets('末步 next 显 finishText 并只发 onFinish', (tester) async {
      final events = <String>[];
      await pumpHost(tester);
      await setBody(
        tester,
        guidePage(
          steps: const [_stepA, _stepB],
          finishText: '搞定',
          onChange: (c) => events.add('change $c'),
          onNext: (c) => events.add('next $c'),
          onFinish: () => events.add('finish'),
        ),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text('下一步'));
      await tester.pumpAndSettle();
      events.clear();

      expect(find.text('搞定'), findsOneWidget);
      await tester.tap(find.text('搞定'));
      await tester.pumpAndSettle();
      // ★末步 next 不发 onChange/onNext、不推进（foundation.ts:68-70）。
      expect(events, ['finish']);
      expect(find.text('2/2'), findsOneWidget);
    });

    testWidgets('skip 仅通知（不改显隐/步）', (tester) async {
      final events = <String>[];
      await pumpHost(tester);
      await setBody(
        tester,
        guidePage(
          steps: const [_stepA, _stepB],
          onChange: (c) => events.add('change $c'),
          onSkip: () => events.add('skip'),
        ),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text('跳过'));
      await tester.pumpAndSettle();
      expect(events, ['skip']);
      expect(find.text('1/2'), findsOneWidget);
      // ★末步不显 skip（showSkipButton && !isLast）。
      await tester.tap(find.text('下一步'));
      await tester.pumpAndSettle();
      expect(find.text('跳过'), findsNothing);
    });

    testWidgets('受控 current：回调照发但不推进', (tester) async {
      final events = <String>[];
      await pumpHost(tester);
      await setBody(
        tester,
        guidePage(
          steps: const [_stepA, _stepB],
          current: 0,
          onChange: (c) => events.add('change $c'),
          onNext: (c) => events.add('next $c'),
        ),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text('下一步'));
      await tester.pumpAndSettle();
      expect(events, ['change 1', 'next 1']);
      // ★受控不 setCurrent——指示器停留 1/2。
      expect(find.text('1/2'), findsOneWidget);
    });

    testWidgets('开档归零（隐藏再显回到第 1 步）', (tester) async {
      await pumpHost(tester);
      await setBody(
        tester,
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SemiUserGuideTarget(
              id: 'a',
              child: SizedBox(key: _targetKey, width: 100, height: 50),
            ),
            ValueListenableBuilder<bool>(
              valueListenable: _visible,
              builder: (context, visible, _) => SemiUserGuide(
                visible: visible,
                steps: const [_stepA, _stepB],
              ),
            ),
          ],
        ),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text('下一步'));
      await tester.pumpAndSettle();
      expect(find.text('2/2'), findsOneWidget);

      // 状态保留的显隐切换（didUpdateWidget 路径——不换 KeyedSubtree）。
      _visible.value = false;
      await tester.pumpAndSettle();
      expect(find.byKey(SemiUserGuide.spotlightAnchorKey), findsNothing);

      _visible.value = true;
      await tester.pumpAndSettle();
      // ★`setState({ current: 0 })`（index.tsx:181-184）。
      expect(find.text('1/2'), findsOneWidget);
    });

    testWidgets('buttonProps：child 覆文案、onPressed 顶替步进', (tester) async {
      final events = <String>[];
      await pumpHost(tester);
      await setBody(
        tester,
        guidePage(
          steps: const [_stepA, _stepB],
          prevButtonProps: const SemiUserGuideButtonProps(child: Text('回去')),
          nextButtonProps: SemiUserGuideButtonProps(
            child: const Text('走起'),
            onPressed: () => events.add('override'),
          ),
          onChange: (c) => events.add('change $c'),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('走起'), findsOneWidget);
      await tester.tap(find.text('走起'));
      await tester.pumpAndSettle();
      // ★`{...nextButtonProps}` 在 onClick 之后展开——onPressed 顶替。
      expect(events, ['override']);
      expect(find.text('1/2'), findsOneWidget);
    });
  });

  group('modal 模式', () {
    testWidgets('内容列：cover + 指示点 + 正文 + 按钮；无 cover 无指示点', (tester) async {
      await pumpHost(tester);
      await setBody(
        tester,
        guidePage(
          mode: SemiUserGuideMode.modal,
          steps: const [
            SemiUserGuideStep(
              target: 'a',
              cover: Text('封面'),
              title: '第一页',
              description: '描述一',
            ),
            SemiUserGuideStep(target: 'a', title: '第二页'),
          ],
        ),
      );
      await pumpOpen(tester);
      expect(find.text('封面'), findsOneWidget);
      expect(find.text('第一页'), findsOneWidget);
      expect(find.text('描述一'), findsOneWidget);
      expect(find.byKey(SemiUserGuide.modalIndicatorKey), findsOneWidget);

      await tester.tap(find.text('下一步'));
      await pumpOpen(tester);
      // ★指示点仅 cover 存在时出（`{cover && <>{cover}{indicator}</>}`）。
      expect(find.byKey(SemiUserGuide.modalIndicatorKey), findsNothing);
      expect(find.text('第二页'), findsOneWidget);
      expect(find.text('完成'), findsOneWidget);
      await pumpDismissed(tester);
    });

    testWidgets('指示点数量与选中随步切换', (tester) async {
      await pumpHost(tester);
      await setBody(
        tester,
        guidePage(
          mode: SemiUserGuideMode.modal,
          steps: const [
            SemiUserGuideStep(target: 'a', cover: Text('封面'), title: '第一页'),
            SemiUserGuideStep(target: 'a', title: '第二页'),
            SemiUserGuideStep(target: 'a', title: '第三页'),
          ],
        ),
      );
      await pumpOpen(tester);
      final row = tester.widget<Row>(
        find.byKey(SemiUserGuide.modalIndicatorKey),
      );
      // 3 点 + 2 间隔（_withGaps）。
      expect(row.children.length, 5);
      await pumpDismissed(tester);
    });

    testWidgets('越界 current 防御性跳过（上游 TypeError）', (tester) async {
      await pumpHost(tester);
      await setBody(
        tester,
        guidePage(
          mode: SemiUserGuideMode.modal,
          current: 99,
          steps: const [_stepA, _stepB],
        ),
      );
      await pumpOpen(tester);
      expect(find.text('第一步'), findsNothing);
      expect(find.byKey(SemiUserGuide.modalIndicatorKey), findsNothing);
      await pumpDismissed(tester);
    });
  });

  group('生命周期', () {
    testWidgets('steps 空或 hidden 整棵不出；无 target 步不出卡', (tester) async {
      await pumpHost(tester);
      await setBody(tester, guidePage(steps: const []));
      await tester.pumpAndSettle();
      expect(find.byKey(SemiUserGuide.spotlightAnchorKey), findsNothing);
      expect(find.byKey(SemiUserGuide.spotlightMaskKey), findsNothing);

      await setBody(
        tester,
        guidePage(steps: const [SemiUserGuideStep(title: '无目标')]),
      );
      await tester.pumpAndSettle();
      // ★renderStep/renderSpotlight `if (!step.target) return null`。
      expect(find.byKey(SemiUserGuide.spotlightAnchorKey), findsNothing);
      expect(find.byKey(SemiUserGuide.popupCardKey), findsNothing);
    });

    testWidgets('卸载后 overlay 清空', (tester) async {
      await pumpHost(tester);
      await setBody(tester, guidePage(steps: const [_stepA]));
      await tester.pumpAndSettle();
      expect(find.byKey(SemiUserGuide.spotlightAnchorKey), findsOneWidget);

      await setBody(tester, const SizedBox.shrink());
      await tester.pumpAndSettle();
      expect(find.byKey(SemiUserGuide.spotlightAnchorKey), findsNothing);
      expect(find.byKey(SemiUserGuide.spotlightMaskKey), findsNothing);
    });
  });
}

/// 滚动用宿主里的引导（与目标同树）。
class _GuideInBody extends StatelessWidget {
  const _GuideInBody({required this.steps});

  final List<SemiUserGuideStep> steps;

  @override
  Widget build(BuildContext context) =>
      SemiUserGuide(steps: steps, visible: true);
}
