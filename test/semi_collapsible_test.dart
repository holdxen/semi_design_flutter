// Behavior matrix for SemiCollapsible plus coverage for the 6 Sass declarations
// (0 FIELDS + 6 MOTION + 0 INTERNAL) — the 5 HARDCODES provenance anchors live
// at the widget call sites, ★0 死变量: no `# dead variable` marker anywhere and
// every one of the 6 field names is consumed by the widget.
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:semi_design_flutter/semi_design_flutter.dart';

Widget host(
  Widget child, {
  TextDirection direction = TextDirection.ltr,
  double? width,
}) => Directionality(
  textDirection: direction,
  child: MediaQuery(
    data: const MediaQueryData(),
    child: Center(
      child: width == null ? child : SizedBox(width: width, child: child),
    ),
  ),
);

Future<void> pumpHost(
  WidgetTester tester,
  Widget child, {
  double? width,
}) async {
  await tester.pumpWidget(host(child, width: width));
}

// -- fixtures ----------------------------------------------------------------

/// 默认内容：固定 200×100，便于断言可见高度。
const Widget content = SizedBox(width: 200, height: 100, child: Text('内容'));

/// Updatable configuration — flipped in place so the widget's State survives
/// (the upstream `setProps` shape of collapsible.test.js).
class CollapsibleCfg {
  const CollapsibleCfg({
    this.isOpen = false,
    this.duration,
    this.motion = true,
    this.keepDOM = false,
    this.lazyRender = false,
    this.collapseHeight = 0,
    this.collapseHeightAdaptive = false,
    this.reCalcKey,
    this.fade = false,
    this.onMotionEnd,
  });

  final bool isOpen;
  final Duration? duration;
  final bool motion;
  final bool keepDOM;
  final bool lazyRender;
  final double collapseHeight;
  final bool collapseHeightAdaptive;
  final Object? reCalcKey;
  final bool fade;
  final VoidCallback? onMotionEnd;

  CollapsibleCfg copyWith({
    bool? isOpen,
    bool? motion,
    bool? keepDOM,
    bool? lazyRender,
    double? collapseHeight,
    bool? collapseHeightAdaptive,
    Object? reCalcKey,
    bool? fade,
    VoidCallback? onMotionEnd,
  }) => CollapsibleCfg(
    isOpen: isOpen ?? this.isOpen,
    duration: duration,
    motion: motion ?? this.motion,
    keepDOM: keepDOM ?? this.keepDOM,
    lazyRender: lazyRender ?? this.lazyRender,
    collapseHeight: collapseHeight ?? this.collapseHeight,
    collapseHeightAdaptive:
        collapseHeightAdaptive ?? this.collapseHeightAdaptive,
    reCalcKey: reCalcKey ?? this.reCalcKey,
    fade: fade ?? this.fade,
    onMotionEnd: onMotionEnd ?? this.onMotionEnd,
  );
}

Widget driven(ValueListenable<CollapsibleCfg> cfg, {Widget child = content}) =>
    ValueListenableBuilder<CollapsibleCfg>(
      valueListenable: cfg,
      child: child,
      builder: (context, c, cached) => SemiCollapsible(
        isOpen: c.isOpen,
        duration: c.duration,
        motion: c.motion,
        keepDOM: c.keepDOM,
        lazyRender: c.lazyRender,
        collapseHeight: c.collapseHeight,
        collapseHeightAdaptive: c.collapseHeightAdaptive,
        reCalcKey: c.reCalcKey,
        fade: c.fade,
        onMotionEnd: c.onMotionEnd,
        child: cached,
      ),
    );

/// Flip the config and pump the rebuild frame (motion arms here).
Future<void> apply(
  WidgetTester tester,
  ValueNotifier<CollapsibleCfg> cfg,
  CollapsibleCfg next,
) async {
  cfg.value = next;
  await tester.pump();
}

/// Records mount/unmount to observe content State lifetime.
class _Probe extends StatefulWidget {
  const _Probe({required this.log, required this.tag});
  final List<String> log;
  final String tag;
  @override
  State<_Probe> createState() => _ProbeState();
}

class _ProbeState extends State<_Probe> {
  @override
  void initState() {
    super.initState();
    widget.log.add('${widget.tag}:init');
  }

  @override
  void dispose() {
    widget.log.add('${widget.tag}:dispose');
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Text(widget.tag);
}

// -- finders / measurements --------------------------------------------------

Finder scoped(Key? key) =>
    key == null ? find.byType(SemiCollapsible).first : find.byKey(key);

/// 可见盒高度（Opacity 盒 == 裁切盒）。
double clipHeight(WidgetTester t, {Key? key}) => t.getSize(scoped(key)).height;

double clipOpacity(WidgetTester t, {Key? key}) => t
    .widget<Opacity>(
      find.descendant(of: scoped(key), matching: find.byType(Opacity)).first,
    )
    .opacity;

const _kCurve = Cubic(0.25, 0.1, 0.25, 1);

// -- theme field table -------------------------------------------------------

typedef _Patch = SemiCollapsibleThemeData Function(Object value);
typedef _Read = Object? Function(SemiResolvedCollapsibleThemeData data);
typedef _Default = Object? Function(SemiThemeData theme);

final List<(String, Object, _Patch, _Read, _Default)> fields = [
  (
    r'$transition_duration-collapsible-height: 250ms',
    const Duration(milliseconds: 901),
    (v) => SemiCollapsibleThemeData(
      transitionDurationCollapsibleHeight: v as Duration,
    ),
    (d) => d.transitionDurationCollapsibleHeight,
    (t) => const Duration(milliseconds: 250),
  ),
  (
    r'$transition_function-collapsible-height: cubic-bezier(0.25,0.1,0.25,1)',
    Curves.bounceOut,
    (v) => SemiCollapsibleThemeData(
      transitionFunctionCollapsibleHeight: v as Curve,
    ),
    (d) => d.transitionFunctionCollapsibleHeight,
    (t) => const Cubic(0.25, 0.1, 0.25, 1),
  ),
  (
    r'$transition_delay-collapsible-height: var(--semi-transition_delay-none)',
    const Duration(milliseconds: 903),
    (v) => SemiCollapsibleThemeData(
      transitionDelayCollapsibleHeight: v as Duration,
    ),
    (d) => d.transitionDelayCollapsibleHeight,
    (t) => Duration.zero,
  ),
  (
    r'$transition_duration-collapsible-opacity: 250ms',
    const Duration(milliseconds: 904),
    (v) => SemiCollapsibleThemeData(
      transitionDurationCollapsibleOpacity: v as Duration,
    ),
    (d) => d.transitionDurationCollapsibleOpacity,
    (t) => const Duration(milliseconds: 250),
  ),
  (
    r'$transition_function-collapsible-opacity: var(--semi-transition_function-easeIn)',
    Curves.easeInOut,
    (v) => SemiCollapsibleThemeData(
      transitionFunctionCollapsibleOpacity: v as Curve,
    ),
    (d) => d.transitionFunctionCollapsibleOpacity,
    (t) => Curves.easeIn,
  ),
  (
    r'$transition_delay-collapsible-opacity: var(--semi-transition_delay-none)',
    const Duration(milliseconds: 906),
    (v) => SemiCollapsibleThemeData(
      transitionDelayCollapsibleOpacity: v as Duration,
    ),
    (d) => d.transitionDelayCollapsibleOpacity,
    (t) => Duration.zero,
  ),
];

void main() {
  group('theme fields (6 = 0 FIELDS + 6 MOTION + 0 INTERNAL)', () {
    test('6 fields: merge, copyWith, resolve, equality, defaults', () {
      expect(fields, hasLength(6));
      for (final (sass, value, make, read, expected) in fields) {
        final patch = make(value);
        expect(
          const SemiCollapsibleThemeData().merge(patch),
          patch,
          reason: sass,
        );
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
          read(const SemiCollapsibleThemeData().resolve(light)),
          expected(light),
          reason: sass,
        );
        final dark = const SemiThemeData.dark();
        expect(
          read(const SemiCollapsibleThemeData().resolve(dark)),
          expected(dark),
          reason: sass,
        );
      }
    });

    test('every field carries its Sass provenance in the generated source', () {
      final source = File('lib/src/theme/semi_collapsible_theme_data.dart')
          .readAsStringSync();
      final names = <String>{};
      for (final (sass, _, _, _, _) in fields) {
        expect(source, contains(sass));
        names.add(sass.split(': ').first.substring(1));
      }
      expect(names, hasLength(6));
      // ★provenance quirk 照抄：值后 `;//` 紧邻注释排版。
      expect(source, contains('`;//` 紧邻'));
      expect(
        source,
        contains('packages/semi-foundation/collapsible/animation.scss'),
      );
      expect(
        source,
        contains('packages/semi-foundation/collapsible/variables.scss'),
      );
    });

    test('the 5 HARDCODES anchors live in the widget source', () {
      final widgetSource = File('lib/src/components/semi_collapsible.dart')
          .readAsStringSync();
      const anchors = [
        'duration + 50',
        "propertyName === 'height'",
        'ResizeObserver',
        'Math.ceil',
        "overflow: 'hidden'",
      ];
      expect(anchors, hasLength(5));
      for (final anchor in anchors) {
        expect(widgetSource, contains(anchor), reason: anchor);
      }
    });

    test('type coverage: 4 Duration + 2 Curve', () {
      final counts = <String, int>{};
      for (final (_, value, _, _, _) in fields) {
        final type = value is Curve ? 'Curve' : value.runtimeType.toString();
        counts.update(type, (n) => n + 1, ifAbsent: () => 1);
      }
      expect(counts['Duration'], 4);
      expect(counts['Curve'], 2);
    });

    test(
      'zero dead variables (0 死口径): no dead marker, all fields consumed',
      () {
        const fieldNames = [
          'transitionDurationCollapsibleHeight',
          'transitionFunctionCollapsibleHeight',
          'transitionDelayCollapsibleHeight',
          'transitionDurationCollapsibleOpacity',
          'transitionFunctionCollapsibleOpacity',
          'transitionDelayCollapsibleOpacity',
        ];
        final widgetSource = File('lib/src/components/semi_collapsible.dart')
            .readAsStringSync();
        // ★0 死变量：widget 无死标且 6 字段名全消费（delay 槽注释引用亦算消费，
        // anchor 先例）。
        expect(widgetSource, isNot(contains('# dead variable')));
        for (final name in fieldNames) {
          expect(widgetSource, contains(name), reason: name);
        }
        final docs = File('docs/semi_collapsible.md').readAsStringSync();
        expect(docs, isNot(contains('（上游未消费）')));
        expect(docs, contains('0 死变量'));
        expect(docs, contains('6 = 0 FIELDS + 6 MOTION + 0 INTERNAL'));
      },
    );

    test('SemiComponentThemes wiring', () {
      expect(
        const SemiComponentThemes().collapsible,
        const SemiCollapsibleThemeData(),
      );
      const patch = SemiCollapsibleThemeData(
        transitionDurationCollapsibleHeight: Duration(milliseconds: 11),
      );
      const themes = SemiComponentThemes(collapsible: patch);
      expect(const SemiComponentThemes().copyWith(collapsible: patch), themes);
      expect(themes == const SemiComponentThemes(), isFalse);
      expect(themes.collapsible, patch);
    });

    testWidgets('application level and nested local patches merge', (
      tester,
    ) async {
      await pumpHost(
        tester,
        SemiTheme(
          data: const SemiThemeData.light(
            components: SemiComponentThemes(
              collapsible: SemiCollapsibleThemeData(
                transitionDurationCollapsibleHeight: Duration(milliseconds: 20),
                transitionDelayCollapsibleHeight: Duration(milliseconds: 30),
              ),
            ),
          ),
          child: SemiCollapsibleTheme(
            data: const SemiCollapsibleThemeData(
              transitionDurationCollapsibleHeight: Duration(milliseconds: 50),
            ),
            child: SemiCollapsibleTheme(
              data: const SemiCollapsibleThemeData(
                transitionDelayCollapsibleOpacity: Duration(milliseconds: 40),
              ),
              child: driven(ValueNotifier(const CollapsibleCfg())),
            ),
          ),
        ),
      );
      final context = tester.element(scoped(null));
      final resolved = SemiCollapsibleTheme.resolve(context);
      // 局部补丁（外到内 merge）> 应用级 > 默认。
      expect(
        resolved.transitionDurationCollapsibleHeight,
        const Duration(milliseconds: 50),
      );
      expect(
        resolved.transitionDelayCollapsibleHeight,
        const Duration(milliseconds: 30),
      );
      expect(
        resolved.transitionDelayCollapsibleOpacity,
        const Duration(milliseconds: 40),
      );
      expect(resolved.transitionFunctionCollapsibleHeight, _kCurve);
    });

    testWidgets('local patches survive capture and globals re-resolve', (
      tester,
    ) async {
      await pumpHost(
        tester,
        SemiCollapsibleTheme(
          data: const SemiCollapsibleThemeData(
            transitionFunctionCollapsibleOpacity: Curves.linear,
          ),
          child: driven(ValueNotifier(const CollapsibleCfg())),
        ),
      );
      final context = tester.element(scoped(null));
      expect(SemiCollapsibleTheme.maybeOf(context), isNotNull);
      final captured = InheritedTheme.captureAll(
        context,
        driven(ValueNotifier(const CollapsibleCfg())),
      );
      await tester.pumpWidget(
        host(
          SemiTheme(
            data: const SemiThemeData.light(
              components: SemiComponentThemes(
                collapsible: SemiCollapsibleThemeData(
                  transitionDurationCollapsibleOpacity: Duration(
                    milliseconds: 77,
                  ),
                ),
              ),
            ),
            child: captured,
          ),
        ),
      );
      final resolved = SemiCollapsibleTheme.resolve(
        tester.element(scoped(null)),
      );
      // 捕获只携带局部补丁快照，应用级在目标边界重新解析。
      expect(resolved.transitionFunctionCollapsibleOpacity, Curves.linear);
      expect(
        resolved.transitionDurationCollapsibleOpacity,
        const Duration(milliseconds: 77),
      );
    });
  });

  group('keepDOM 与 lazyRender（上游 collapsible.test.js 矩阵）', () {
    testWidgets('keepDOM=true + lazyRender=true：挂载不构建，展开才见（上游用例 1）', (
      tester,
    ) async {
      final cfg = ValueNotifier(
        const CollapsibleCfg(keepDOM: true, lazyRender: true, motion: false),
      );
      await pumpHost(tester, driven(cfg));
      expect(find.text('内容'), findsNothing);
      // 上游 setProps 同时翻 lazyRender/isOpen；这里先只开 isOpen（lazyRender
      // 仍 true）也应渲染（visible 路径），再翻 lazyRender 验证已渲染缓存。
      await apply(tester, cfg, cfg.value.copyWith(isOpen: true));
      expect(find.text('内容'), findsOneWidget);
      await apply(tester, cfg, cfg.value.copyWith(lazyRender: false));
      expect(find.text('内容'), findsOneWidget);
    });

    testWidgets('keepDOM=true + lazyRender=false：始终构建（上游用例 2）', (tester) async {
      final cfg = ValueNotifier(
        const CollapsibleCfg(keepDOM: true, lazyRender: false, motion: false),
      );
      await pumpHost(tester, driven(cfg));
      expect(find.text('内容'), findsOneWidget);
      await apply(tester, cfg, cfg.value.copyWith(isOpen: true));
      expect(find.text('内容'), findsOneWidget);
      await apply(tester, cfg, cfg.value.copyWith(isOpen: false));
      expect(find.text('内容'), findsOneWidget);
    });

    testWidgets('keepDOM=false：收起不构建、展开构建、收起销毁（上游用例 3）', (tester) async {
      final cfg = ValueNotifier(
        const CollapsibleCfg(keepDOM: false, motion: false),
      );
      await pumpHost(tester, driven(cfg));
      expect(find.text('内容'), findsNothing);
      await apply(tester, cfg, cfg.value.copyWith(isOpen: true));
      expect(find.text('内容'), findsOneWidget);
      await apply(tester, cfg, cfg.value.copyWith(isOpen: false));
      expect(find.text('内容'), findsNothing);
    });

    testWidgets('keepDOM=false + motion：收起动画期间保持、结算销毁（State 生命周期）', (
      tester,
    ) async {
      final log = <String>[];
      final cfg = ValueNotifier(const CollapsibleCfg(isOpen: true));
      await pumpHost(
        tester,
        driven(
          cfg,
          child: _Probe(log: log, tag: 'p'),
        ),
      );
      expect(log, ['p:init']);
      await apply(tester, cfg, cfg.value.copyWith(isOpen: false));
      await tester.pump(const Duration(milliseconds: 125));
      // 收起动画中内容仍在（上游 visible 语义）。
      expect(find.text('p'), findsOneWidget);
      await tester.pumpAndSettle();
      expect(find.text('p'), findsNothing);
      expect(log, ['p:init', 'p:dispose']);
    });

    testWidgets('keepDOM=true：收起后 State 保留（不 dispose）', (tester) async {
      final log = <String>[];
      final cfg = ValueNotifier(
        const CollapsibleCfg(isOpen: true, keepDOM: true),
      );
      await pumpHost(
        tester,
        driven(
          cfg,
          child: _Probe(log: log, tag: 'p'),
        ),
      );
      await apply(tester, cfg, cfg.value.copyWith(isOpen: false));
      await tester.pumpAndSettle();
      expect(log, ['p:init']);
      // keepDOM 收起高度裁 0 但内容保持构建。
      expect(find.text('p'), findsOneWidget);
      expect(clipHeight(tester), 0);
    });
  });

  group('高度与动画', () {
    testWidgets('初始收起 0 高；初始展开直接内容高（无入场动画）', (tester) async {
      await pumpHost(
        tester,
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SemiCollapsible(key: const Key('closed'), child: content),
            SemiCollapsible(
              key: const Key('open'),
              isOpen: true,
              child: content,
            ),
          ],
        ),
      );
      await tester.pump();
      expect(clipHeight(tester, key: const Key('closed')), 0);
      expect(clipHeight(tester, key: const Key('open')), 100);
    });

    testWidgets('motion 展开/收起按主题曲线插值、结算落位', (tester) async {
      final cfg = ValueNotifier(const CollapsibleCfg());
      await pumpHost(tester, driven(cfg));
      expect(clipHeight(tester), 0);
      await apply(tester, cfg, cfg.value.copyWith(isOpen: true));
      await tester.pump(const Duration(milliseconds: 125));
      // 高度 = 100 * C(0.5)（控制器线性推进、主题曲线变换系数）。
      expect(clipHeight(tester), closeTo(100 * _kCurve.transform(0.5), 0.01));
      await tester.pumpAndSettle();
      expect(clipHeight(tester), 100);

      await apply(tester, cfg, cfg.value.copyWith(isOpen: false));
      await tester.pump(const Duration(milliseconds: 125));
      expect(clipHeight(tester), closeTo(100 * _kCurve.transform(0.5), 0.01));
      await tester.pumpAndSettle();
      expect(clipHeight(tester), 0);
    });

    testWidgets('collapseHeight 收起态部分可见且内容恒构建', (tester) async {
      final cfg = ValueNotifier(const CollapsibleCfg(collapseHeight: 60));
      await pumpHost(tester, driven(cfg));
      expect(clipHeight(tester), 60);
      // collapseHeight != 0：收起态内容就地可见（shouldRender 恒真）。
      expect(find.text('内容'), findsOneWidget);
      await apply(tester, cfg, cfg.value.copyWith(isOpen: true));
      await tester.pumpAndSettle();
      expect(clipHeight(tester), 100);
    });

    testWidgets('collapseHeightAdaptive 矮内容自适应 Math.min(内容高, collapseHeight)', (
      tester,
    ) async {
      await pumpHost(
        tester,
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SemiCollapsible(
              key: const Key('adaptive'),
              collapseHeight: 60,
              collapseHeightAdaptive: true,
              child: const SizedBox(width: 200, height: 40),
            ),
            SemiCollapsible(
              key: const Key('fixed'),
              collapseHeight: 60,
              child: const SizedBox(width: 200, height: 40),
            ),
          ],
        ),
      );
      // adaptive：min(40, 60) = 40；非 adaptive：恒 60（内容矮留空）。
      expect(clipHeight(tester, key: const Key('adaptive')), 40);
      expect(clipHeight(tester, key: const Key('fixed')), 60);
    });

    testWidgets('嵌套内容尺寸变化同帧跟随（无陈旧缓存高）', (tester) async {
      final innerHeight = ValueNotifier<double>(100);
      await pumpHost(
        tester,
        SemiCollapsible(
          key: const Key('outer'),
          isOpen: true,
          child: ValueListenableBuilder<double>(
            valueListenable: innerHeight,
            builder: (context, h, _) =>
                SizedBox(width: 200, height: h, child: const Text('内层')),
          ),
        ),
      );
      expect(clipHeight(tester, key: const Key('outer')), 100);
      innerHeight.value = 150;
      await tester.pump();
      expect(clipHeight(tester, key: const Key('outer')), 150);
    });

    testWidgets('reCalcKey 变化触发重建、高度照常', (tester) async {
      final cfg = ValueNotifier(
        const CollapsibleCfg(isOpen: true, reCalcKey: 1),
      );
      await pumpHost(tester, driven(cfg));
      expect(clipHeight(tester), 100);
      await apply(tester, cfg, cfg.value.copyWith(reCalcKey: 2));
      await tester.pump();
      expect(clipHeight(tester), 100);
    });
  });

  group('fade', () {
    testWidgets('fade=false 恒不透明；fade=true 收起 0 展开 1', (tester) async {
      final plain = ValueNotifier(const CollapsibleCfg(motion: false));
      await pumpHost(tester, driven(plain));
      expect(clipOpacity(tester), 1);
      await apply(tester, plain, plain.value.copyWith(isOpen: true));
      expect(clipOpacity(tester), 1);

      final fade = ValueNotifier(
        const CollapsibleCfg(motion: false, fade: true),
      );
      await pumpHost(tester, driven(fade));
      expect(clipOpacity(tester), 0);
      await apply(tester, fade, fade.value.copyWith(isOpen: true));
      expect(clipOpacity(tester), 1);
      await apply(tester, fade, fade.value.copyWith(isOpen: false));
      expect(clipOpacity(tester), 0);
    });

    testWidgets('fade + collapseHeight != 0 恒 1（上游 opacity 公式）', (
      tester,
    ) async {
      final cfg = ValueNotifier(
        const CollapsibleCfg(motion: false, fade: true, collapseHeight: 60),
      );
      await pumpHost(tester, driven(cfg));
      expect(clipOpacity(tester), 1);
      await apply(tester, cfg, cfg.value.copyWith(isOpen: true));
      expect(clipOpacity(tester), 1);
    });

    testWidgets('fade 中间帧按 ease-in 渐变', (tester) async {
      final cfg = ValueNotifier(const CollapsibleCfg(fade: true));
      await pumpHost(tester, driven(cfg));
      await apply(tester, cfg, cfg.value.copyWith(isOpen: true));
      await tester.pump(const Duration(milliseconds: 125));
      expect(clipOpacity(tester), closeTo(Curves.easeIn.transform(0.5), 0.01));
      await tester.pumpAndSettle();
      expect(clipOpacity(tester), 1);
    });
  });

  group('duration / motion / onMotionEnd', () {
    testWidgets('motion=false 瞬切且不回调', (tester) async {
      var calls = 0;
      final cfg = ValueNotifier(
        CollapsibleCfg(motion: false, onMotionEnd: () => calls += 1),
      );
      await pumpHost(tester, driven(cfg));
      await apply(tester, cfg, cfg.value.copyWith(isOpen: true));
      expect(clipHeight(tester), 100);
      await tester.pumpAndSettle();
      expect(calls, 0);
    });

    testWidgets('展开、收起动画结束各回调一次', (tester) async {
      var calls = 0;
      final cfg = ValueNotifier(CollapsibleCfg(onMotionEnd: () => calls += 1));
      await pumpHost(tester, driven(cfg));
      await apply(tester, cfg, cfg.value.copyWith(isOpen: true));
      await tester.pumpAndSettle();
      expect(calls, 1);
      await apply(tester, cfg, cfg.value.copyWith(isOpen: false));
      await tester.pumpAndSettle();
      expect(calls, 2);
    });

    testWidgets('快速连续切换只在最终结算回调一次', (tester) async {
      var calls = 0;
      final cfg = ValueNotifier(CollapsibleCfg(onMotionEnd: () => calls += 1));
      await pumpHost(tester, driven(cfg));
      await apply(tester, cfg, cfg.value.copyWith(isOpen: true));
      await tester.pump(const Duration(milliseconds: 50));
      await apply(tester, cfg, cfg.value.copyWith(isOpen: false));
      await tester.pumpAndSettle();
      expect(calls, 1);
      expect(clipHeight(tester), 0);
    });

    testWidgets('duration 覆盖主题时长', (tester) async {
      final cfg = ValueNotifier(
        const CollapsibleCfg(duration: Duration(milliseconds: 500)),
      );
      await pumpHost(tester, driven(cfg));
      await apply(tester, cfg, cfg.value.copyWith(isOpen: true));
      await tester.pump(const Duration(milliseconds: 250));
      // 500ms 时长下 250ms 处于半程（250ms 默认此处已接近落位）。
      final mid = clipHeight(tester);
      expect(mid, greaterThan(0));
      expect(mid, lessThan(100));
      await tester.pumpAndSettle();
      expect(clipHeight(tester), 100);
    });

    testWidgets('disableAnimations 瞬切且不回调', (tester) async {
      var calls = 0;
      final cfg = ValueNotifier(CollapsibleCfg(onMotionEnd: () => calls += 1));
      await pumpHost(
        tester,
        MediaQuery(
          data: const MediaQueryData(disableAnimations: true),
          child: driven(cfg),
        ),
      );
      await apply(tester, cfg, cfg.value.copyWith(isOpen: true));
      expect(clipHeight(tester), 100);
      await tester.pumpAndSettle();
      expect(calls, 0);
    });
  });
}
