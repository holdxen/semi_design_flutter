// Behavior matrix for SemiBreadcrumb plus coverage for the 20 Sass declarations
// (16 FIELDS + 4 MOTION + 0 INTERNAL) — the 15 HARDCODES provenance anchors
// live in the widget's `_BreadcrumbMetrics` / call sites, ★0 死变量（首个零死
// 变量组件）: no `# dead variable` marker anywhere and every one of the 20
// field names is consumed by the widget.
import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:semi_design_flutter/semi_design_flutter.dart';

/// The host body is served through a notifier: `Overlay.initialEntries` is
/// initState-only, so the entry must rebuild its child from outside (the
/// semi_tag_input_test.dart host precedent).
final _hostBody = ValueNotifier<Widget>(const SizedBox.shrink());

Widget host(
  Widget child, {
  TextDirection direction = TextDirection.ltr,
  double width = 900,
  double height = 900,
}) {
  _hostBody.value = KeyedSubtree(key: UniqueKey(), child: child);
  return SemiTheme(
    data: const SemiThemeData.light(),
    child: Directionality(
      textDirection: direction,
      child: MediaQuery(
        data: const MediaQueryData(size: Size(1200, 900)),
        child: Overlay(
          initialEntries: [
            OverlayEntry(
              builder: (context) => ValueListenableBuilder<Widget>(
                valueListenable: _hostBody,
                builder: (context, child, _) => Center(
                  child: SizedBox(width: width, height: height, child: child),
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

Future<TestGesture> startMouse(WidgetTester tester) async {
  final gesture = await tester.createGesture(kind: ui.PointerDeviceKind.mouse);
  await gesture.addPointer(location: Offset.zero);
  addTearDown(gesture.removePointer);
  return gesture;
}

/// Pump [host] on a tall test surface.
Future<void> pumpHost(
  WidgetTester tester,
  Widget child, {
  TextDirection direction = TextDirection.ltr,
  double width = 900,
  double height = 900,
}) async {
  await tester.binding.setSurfaceSize(const Size(1200, 1200));
  await tester.pumpWidget(
    host(child, direction: direction, width: width, height: height),
  );
}

/// known_issues.md #1（滚动贴边 tap 失效一次怪癖）：滚动列表贴边点击前补一次
/// 中性 tap（外场空白处），吃掉那一次失效命中。
Future<void> neutralTap(WidgetTester tester) async {
  await tester.tapAt(const Offset(1180, 20));
  await tester.pump();
}

// -- fixtures ----------------------------------------------------------------

Widget breadcrumb({
  List<Object>? routes,
  List<SemiBreadcrumbItem> children = const [],
  Object separator = '/',
  bool compact = true,
  int? activeIndex,
  int maxItemCount = 4,
  bool autoCollapse = true,
  SemiBreadcrumbMoreType moreType = SemiBreadcrumbMoreType.defaultType,
  Widget Function(List<Widget> restItems)? renderMore,
  Widget Function(SemiBreadcrumbRoute route)? renderItem,
  bool showTooltip = true,
  double itemMaxWidth = 150,
  void Function(SemiBreadcrumbRoute route)? onClick,
  String? semanticsLabel,
}) => SemiBreadcrumb(
  routes: routes,
  children: children,
  separator: separator,
  compact: compact,
  activeIndex: activeIndex,
  maxItemCount: maxItemCount,
  autoCollapse: autoCollapse,
  moreType: moreType,
  renderMore: renderMore,
  renderItem: renderItem,
  showTooltip: showTooltip,
  itemMaxWidth: itemMaxWidth,
  onClick: onClick,
  semanticsLabel: semanticsLabel,
);

List<SemiBreadcrumbItem> items(List<String> names) => [
  for (final name in names) SemiBreadcrumbItem(name: name),
];

// -- finders / measurements --------------------------------------------------

/// Resolved DefaultTextStyle 色（色态经 AnimatedDefaultTextStyle 下发）。
Color? nameColor(WidgetTester tester, String text) =>
    DefaultTextStyle.of(tester.element(find.text(text).first)).style.color;

double nameFontSize(WidgetTester tester, String text) =>
    DefaultTextStyle.of(tester.element(find.text(text).first)).style.fontSize!;

double nameWidth(WidgetTester tester, String text) =>
    tester.getSize(find.text(text).first).width;

// -- theme field table -------------------------------------------------------

typedef _Patch = SemiBreadcrumbThemeData Function(Object value);
typedef _Read = Object? Function(SemiResolvedBreadcrumbThemeData data);
typedef _Default = Object? Function(SemiThemeData theme);

final List<(String, Object, _Patch, _Read, _Default)> fields = [
  (
    r'$spacing-breadcrumb_item_wrap-marginY: $spacing-extra-tight',
    101.0,
    (v) =>
        SemiBreadcrumbThemeData(spacingBreadcrumbItemWrapMarginY: v as double),
    (d) => d.spacingBreadcrumbItemWrapMarginY,
    (t) => 4.0,
  ),
  (
    r'$spacing-breadcrumb_item_wrap-marginRight: $spacing-extra-tight',
    102.0,
    (v) => SemiBreadcrumbThemeData(
      spacingBreadcrumbItemWrapMarginRight: v as double,
    ),
    (d) => d.spacingBreadcrumbItemWrapMarginRight,
    (t) => 4.0,
  ),
  (
    r'$spacing-breadcrumb_item-marginRight: $spacing-extra-tight',
    103.0,
    (v) =>
        SemiBreadcrumbThemeData(spacingBreadcrumbItemMarginRight: v as double),
    (d) => d.spacingBreadcrumbItemMarginRight,
    (t) => 4.0,
  ),
  (
    r'$spacing-breadcrumb_item_text-marginLeft: $spacing-extra-tight',
    104.0,
    (v) => SemiBreadcrumbThemeData(
      spacingBreadcrumbItemTextMarginLeft: v as double,
    ),
    (d) => d.spacingBreadcrumbItemTextMarginLeft,
    (t) => 4.0,
  ),
  (
    r'$spacing-breadcrumb_restItem-marginRight: $spacing-tight',
    105.0,
    (v) => SemiBreadcrumbThemeData(
      spacingBreadcrumbRestItemMarginRight: v as double,
    ),
    (d) => d.spacingBreadcrumbRestItemMarginRight,
    (t) => 8.0,
  ),
  (
    r'$color-breadcrumb_default-text-default: var(--semi-color-text-2)',
    const Color(0xff010101),
    (v) =>
        SemiBreadcrumbThemeData(colorBreadcrumbDefaultTextDefault: v as Color),
    (d) => d.colorBreadcrumbDefaultTextDefault,
    (t) => t.colors.colorText2,
  ),
  (
    r'$color-breadcrumb_default-text-hover: var(--semi-color-link)',
    const Color(0xff020202),
    (v) => SemiBreadcrumbThemeData(colorBreadcrumbDefaultTextHover: v as Color),
    (d) => d.colorBreadcrumbDefaultTextHover,
    (t) => t.colors.colorLink,
  ),
  (
    r'$color-breadcrumb_default-text-active: var(--semi-color-link-hover)',
    const Color(0xff030303),
    (v) =>
        SemiBreadcrumbThemeData(colorBreadcrumbDefaultTextActive: v as Color),
    (d) => d.colorBreadcrumbDefaultTextActive,
    (t) => t.colors.colorLinkHover,
  ),
  (
    r'$color-breadcrumb_active-text-default: var(--semi-color-text-0)',
    const Color(0xff040404),
    (v) =>
        SemiBreadcrumbThemeData(colorBreadcrumbActiveTextDefault: v as Color),
    (d) => d.colorBreadcrumbActiveTextDefault,
    (t) => t.colors.colorText0,
  ),
  (
    r'$color-breadcrumb_active-text-active: var(--semi-color-text-0)',
    const Color(0xff050505),
    (v) => SemiBreadcrumbThemeData(colorBreadcrumbActiveTextActive: v as Color),
    (d) => d.colorBreadcrumbActiveTextActive,
    (t) => t.colors.colorText0,
  ),
  (
    r'$color-breadcrumb_sepearator_default-icon-default: var(--semi-color-text-2)',
    const Color(0xff060606),
    (v) => SemiBreadcrumbThemeData(
      colorBreadcrumbSepearatorDefaultIconDefault: v as Color,
    ),
    (d) => d.colorBreadcrumbSepearatorDefaultIconDefault,
    (t) => t.colors.colorText2,
  ),
  (
    r'$color-breadcrumb-restItem-text-default: var(--semi-color-text-2)',
    const Color(0xff070707),
    (v) =>
        SemiBreadcrumbThemeData(colorBreadcrumbRestItemTextDefault: v as Color),
    (d) => d.colorBreadcrumbRestItemTextDefault,
    (t) => t.colors.colorText2,
  ),
  (
    r'$font-breadcrumb_default-fontWeight: $font-weight-regular',
    FontWeight.w400,
    (v) => SemiBreadcrumbThemeData(
      fontBreadcrumbDefaultFontWeight: v as FontWeight,
    ),
    (d) => d.fontBreadcrumbDefaultFontWeight,
    (t) => t.typography.fontWeightRegular,
  ),
  (
    r'$font-breadcrumb_active-fontWeight: $font-weight-bold',
    FontWeight.w600,
    (v) => SemiBreadcrumbThemeData(
      fontBreadcrumbActiveFontWeight: v as FontWeight,
    ),
    (d) => d.fontBreadcrumbActiveFontWeight,
    (t) => t.typography.fontWeightBold,
  ),
  // ★provenance 冒号后无空格排版 quirk 照抄（variables.scss:22-23）。
  (
    r'$font-breadcrumb_compact-fontSize:$font-size-small',
    106.0,
    (v) => SemiBreadcrumbThemeData(fontBreadcrumbCompactFontSize: v as double),
    (d) => d.fontBreadcrumbCompactFontSize,
    (t) => 12.0,
  ),
  (
    r'$font-breadcrumb_loose-fontSize:$font-size-regular',
    107.0,
    (v) => SemiBreadcrumbThemeData(fontBreadcrumbLooseFontSize: v as double),
    (d) => d.fontBreadcrumbLooseFontSize,
    (t) => 14.0,
  ),
  (
    r'$transition_duration-breadcrumb_link-text: var(--semi-transition_duration-none)',
    const Duration(milliseconds: 5),
    (v) => SemiBreadcrumbThemeData(
      transitionDurationBreadcrumbLinkText: v as Duration,
    ),
    (d) => d.transitionDurationBreadcrumbLinkText,
    (t) => Duration.zero,
  ),
  (
    r'$transition_function-breadcrumb_link-text: var(--semi-transition_function-easeIn)',
    Curves.easeOut,
    (v) => SemiBreadcrumbThemeData(
      transitionFunctionBreadcrumbLinkText: v as Curve,
    ),
    (d) => d.transitionFunctionBreadcrumbLinkText,
    (t) => Curves.easeIn,
  ),
  (
    r'$transition_delay-breadcrumb_link-text: var(--semi-transition_delay-none)',
    const Duration(milliseconds: 6),
    (v) => SemiBreadcrumbThemeData(
      transitionDelayBreadcrumbLinkText: v as Duration,
    ),
    (d) => d.transitionDelayBreadcrumbLinkText,
    (t) => Duration.zero,
  ),
  (
    r'$transform_scale-breadcrumb_link-text: var(--semi-transform_scale-none)',
    const SemiTransform.scale(2, 3),
    (v) => SemiBreadcrumbThemeData(
      transformScaleBreadcrumbLinkText: v as SemiTransform,
    ),
    (d) => d.transformScaleBreadcrumbLinkText,
    (t) => const SemiTransform.scale(1, 1),
  ),
];

void main() {
  group('theme fields (20 = 16 FIELDS + 4 MOTION + 0 INTERNAL)', () {
    test('20 fields: merge, copyWith, resolve, equality, defaults', () {
      expect(fields, hasLength(20));
      for (final (sass, value, make, read, expected) in fields) {
        final patch = make(value);
        expect(
          const SemiBreadcrumbThemeData().merge(patch),
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
          read(const SemiBreadcrumbThemeData().resolve(light)),
          expected(light),
          reason: sass,
        );
        final dark = const SemiThemeData.dark();
        expect(
          read(const SemiBreadcrumbThemeData().resolve(dark)),
          expected(dark),
          reason: sass,
        );
      }
    });

    test('every field carries its Sass provenance in the generated source', () {
      final source = File('lib/src/theme/semi_breadcrumb_theme_data.dart')
          .readAsStringSync();
      final names = <String>{};
      for (final (sass, _, _, _, _) in fields) {
        expect(source, contains(sass));
        names.add(sass.split(': ').first.substring(1));
      }
      expect(names, hasLength(20));
      // ★provenance quirk 照抄：`sepearator` typo / `-`/`_` 混排命名 /
      // 冒号后无空格排版。
      expect(source, contains('sepearator'));
      expect(source, contains(r'$color-breadcrumb-restItem-text-default'));
      expect(
        source,
        contains(r'$font-breadcrumb_compact-fontSize:$font-size-small'),
      );
      expect(
        source,
        contains(r'$font-breadcrumb_loose-fontSize:$font-size-regular'),
      );
    });

    test('the 15 HARDCODES anchors live in the widget source', () {
      final widgetSource = File('lib/src/components/semi_breadcrumb.dart')
          .readAsStringSync();
      final anchors = <String>[
        'width: 150',
        'padding: 12',
        "'Breadcrumb'",
        'margin-bottom: -1px',
        'cursor: default',
        'flex-wrap: wrap',
        'overflow: hidden',
        'transform: scale(scale(1,1))',
        '// flex-shrink: 0;',
        'text-decoration: inherit',
        'column-gap: \$spacing-breadcrumb_item_text-marginLeft',
        'display: inline-flex; align-items: center',
        'handleExpandEnterPress',
        "position: 'top'",
        'sepearator',
      ];
      expect(anchors, hasLength(15));
      for (final anchor in anchors) {
        expect(widgetSource, contains(anchor), reason: anchor);
      }
    });

    test('type coverage: 7 Color + 7 double + 2 FontWeight + 2 Duration + '
        '1 Curve + 1 SemiTransform', () {
      final counts = <String, int>{};
      for (final (_, value, _, _, _) in fields) {
        final type = value is SemiTransform
            ? 'SemiTransform'
            : value is Curve
            ? 'Curve'
            : value.runtimeType.toString();
        counts.update(type, (n) => n + 1, ifAbsent: () => 1);
      }
      expect(counts['Color'], 7);
      expect(counts['double'], 7);
      expect(counts['FontWeight'], 2);
      expect(counts['Duration'], 2);
      expect(counts['Curve'], 1);
      expect(counts['SemiTransform'], 1);
    });

    test(
      'zero dead variables (0 死口径): no dead marker, all fields consumed',
      () {
        const fieldNames = [
          'spacingBreadcrumbItemWrapMarginY',
          'spacingBreadcrumbItemWrapMarginRight',
          'spacingBreadcrumbItemMarginRight',
          'spacingBreadcrumbItemTextMarginLeft',
          'spacingBreadcrumbRestItemMarginRight',
          'colorBreadcrumbDefaultTextDefault',
          'colorBreadcrumbDefaultTextHover',
          'colorBreadcrumbDefaultTextActive',
          'colorBreadcrumbActiveTextDefault',
          'colorBreadcrumbActiveTextActive',
          'colorBreadcrumbSepearatorDefaultIconDefault',
          'colorBreadcrumbRestItemTextDefault',
          'fontBreadcrumbDefaultFontWeight',
          'fontBreadcrumbActiveFontWeight',
          'fontBreadcrumbCompactFontSize',
          'fontBreadcrumbLooseFontSize',
          'transitionDurationBreadcrumbLinkText',
          'transitionFunctionBreadcrumbLinkText',
          'transitionDelayBreadcrumbLinkText',
          'transformScaleBreadcrumbLinkText',
        ];
        final widgetSource = File('lib/src/components/semi_breadcrumb.dart')
            .readAsStringSync();
        // ★0 死变量（首个零死变量组件）：widget 无死标且 20 字段名全消费
        // （delay 槽注释引用亦算消费，anchor 先例）。
        expect(widgetSource, isNot(contains('# dead variable')));
        for (final name in fieldNames) {
          expect(widgetSource, contains(name), reason: name);
        }
        final docs = File('docs/semi_breadcrumb.md').readAsStringSync();
        expect(docs, isNot(contains('（上游未消费）')));
        expect(docs, contains('0 死变量'));
      },
    );

    test('SemiComponentThemes wiring', () {
      expect(
        const SemiComponentThemes().breadcrumb,
        const SemiBreadcrumbThemeData(),
      );
      const patch = SemiBreadcrumbThemeData(
        spacingBreadcrumbItemWrapMarginY: 10,
      );
      const themes = SemiComponentThemes(breadcrumb: patch);
      expect(const SemiComponentThemes().copyWith(breadcrumb: patch), themes);
      expect(themes == const SemiComponentThemes(), isFalse);
      expect(themes.breadcrumb, patch);
    });

    testWidgets('SemiBreadcrumbTheme local patch applies (nested merge, '
        'inner wins its own field)', (tester) async {
      await pumpHost(
        tester,
        SemiTheme(
          data: const SemiThemeData.light(),
          child: SemiBreadcrumbTheme(
            data: const SemiBreadcrumbThemeData(
              colorBreadcrumbDefaultTextDefault: Color(0xff123456),
            ),
            child: SemiBreadcrumbTheme(
              data: const SemiBreadcrumbThemeData(
                fontBreadcrumbLooseFontSize: 30,
              ),
              child: breadcrumb(
                compact: false,
                children: items(const ['a', 'b']),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      // 外层 patch 字段（色）+ 内层 patch 字段（字号 30）并存——内层只赢自己的字段。
      expect(nameColor(tester, 'a'), const Color(0xff123456));
      expect(nameFontSize(tester, 'a'), 30.0);
    });
  });

  group('routes 与 children 渲染', () {
    testWidgets('routes 模式：对象+字符串混排、icon、href', (tester) async {
      await pumpHost(
        tester,
        breadcrumb(
          routes: const [
            SemiBreadcrumbRoute(
              name: '首页',
              href: '/',
              icon: SemiIcon(SemiIcons.home),
            ),
            SemiBreadcrumbRoute(name: '组件', href: '/components'),
            '字符串',
          ],
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('首页'), findsOneWidget);
      expect(find.text('组件'), findsOneWidget);
      expect(find.text('字符串'), findsOneWidget);
      expect(find.byType(SemiIcon), findsOneWidget);
      // 默认 separator '/'：3 项 → 2 个。
      expect(find.text('/'), findsNWidgets(2));
    });

    testWidgets('children 模式渲染', (tester) async {
      await pumpHost(
        tester,
        breadcrumb(
          children: const [
            SemiBreadcrumbItem(name: '一', icon: SemiIcon(SemiIcons.home)),
            SemiBreadcrumbItem(name: '二'),
            SemiBreadcrumbItem(name: '三'),
          ],
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('一'), findsOneWidget);
      expect(find.text('二'), findsOneWidget);
      expect(find.text('三'), findsOneWidget);
      expect(find.byType(SemiIcon), findsOneWidget);
      expect(find.text('/'), findsNWidgets(2));
    });
  });

  group('active 规则', () {
    testWidgets('默认末项 active、activeIndex 覆盖、active 项点击不发 onClick（不跳转 quirk）', (
      tester,
    ) async {
      final t = const SemiThemeData.light();
      final clicks = <SemiBreadcrumbRoute>[];
      await pumpHost(
        tester,
        breadcrumb(onClick: clicks.add, children: items(const ['一', '二', '三'])),
      );
      await tester.pumpAndSettle();
      // 缺省末项 active（text-0），其余 text-2。
      expect(nameColor(tester, '三'), t.colors.colorText0);
      expect(nameColor(tester, '一'), t.colors.colorText2);
      await neutralTap(tester);
      await tester.tap(find.text('三'));
      await tester.pump();
      // ★active 项即使有 href 也渲染不可点 span、点击不发 onClick。
      expect(clicks, isEmpty);
      // activeIndex 覆盖 → 中项 active。
      await pumpHost(
        tester,
        breadcrumb(
          activeIndex: 1,
          onClick: clicks.add,
          children: items(const ['一', '二', '三']),
        ),
      );
      await tester.pumpAndSettle();
      expect(nameColor(tester, '二'), t.colors.colorText0);
      expect(nameColor(tester, '一'), t.colors.colorText2);
      expect(nameColor(tester, '三'), t.colors.colorText2);
      await neutralTap(tester);
      await tester.tap(find.text('二'));
      await tester.pump();
      expect(clicks, isEmpty);
      // 非 active 项可点（activeIndex 覆盖后末项不再是 active）。
      await neutralTap(tester);
      await tester.tap(find.text('三'));
      await tester.pump();
      expect(clicks, hasLength(1));
    });
  });

  group('onClick 链', () {
    testWidgets('item 先父后、参数正确（itemFoundation.ts:29-33）', (tester) async {
      final calls = <String>[];
      await pumpHost(
        tester,
        breadcrumb(
          onClick: (route) => calls.add('parent:${route.name}:${route.href}'),
          children: [
            SemiBreadcrumbItem(name: '一', href: '/a'),
            SemiBreadcrumbItem(
              name: '二',
              href: '/b',
              onClick: () => calls.add('item'),
            ),
            SemiBreadcrumbItem(name: '三'),
          ],
        ),
      );
      await tester.pumpAndSettle();
      await neutralTap(tester);
      await tester.tap(find.text('二'));
      await tester.pump();
      // ★item 自身 onClick 先、父 onClick 后；参数 = 合成 route（name/href）。
      expect(calls, ['item', 'parent:二:/b']);
    });

    testWidgets('routes 模式参数 = 原 route（含 path）', (tester) async {
      final calls = <SemiBreadcrumbRoute>[];
      await pumpHost(
        tester,
        breadcrumb(
          onClick: calls.add,
          routes: const [
            SemiBreadcrumbRoute(name: 'r1', href: '/p1', path: 'P1'),
            SemiBreadcrumbRoute(name: 'r2'),
          ],
        ),
      );
      await tester.pumpAndSettle();
      await neutralTap(tester);
      await tester.tap(find.text('r1'));
      await tester.pump();
      expect(calls, hasLength(1));
      expect(calls.single.name, 'r1');
      expect(calls.single.href, '/p1');
      expect(calls.single.path, 'P1');
    });
  });

  group('折叠', () {
    testWidgets('maxItemCount=3 / 5 项 → 1+more+2；严格 >（=maxItemCount 不折叠）', (
      tester,
    ) async {
      await pumpHost(
        tester,
        breadcrumb(
          maxItemCount: 3,
          children: items(const ['a', 'b', 'c', 'd', 'e']),
        ),
      );
      await tester.pumpAndSettle();
      // 首项恒显、末 maxItemCount-1 项恒显，中间 1..len-maxItemCount 隐藏。
      expect(find.text('a'), findsOneWidget);
      expect(find.text('b'), findsNothing);
      expect(find.text('c'), findsNothing);
      expect(find.text('d'), findsOneWidget);
      expect(find.text('e'), findsOneWidget);
      expect(find.byKey(SemiBreadcrumb.moreKey), findsOneWidget);
      // ★严格大于：len == maxItemCount 不折叠。
      await pumpHost(
        tester,
        breadcrumb(maxItemCount: 3, children: items(const ['a', 'b', 'c'])),
      );
      await tester.pumpAndSettle();
      expect(find.byKey(SemiBreadcrumb.moreKey), findsNothing);
      expect(find.text('a'), findsOneWidget);
      expect(find.text('b'), findsOneWidget);
      expect(find.text('c'), findsOneWidget);
      // defaultType 点击展开全部。
      await pumpHost(
        tester,
        breadcrumb(
          maxItemCount: 3,
          children: items(const ['a', 'b', 'c', 'd', 'e']),
        ),
      );
      await tester.pumpAndSettle();
      await neutralTap(tester);
      await tester.tap(find.byKey(SemiBreadcrumb.moreKey));
      await tester.pump();
      expect(find.text('b'), findsOneWidget);
      expect(find.text('c'), findsOneWidget);
      expect(find.byKey(SemiBreadcrumb.moreKey), findsNothing);
    });

    testWidgets('单向展开不可回收（展开后 items 增多亦不再折叠）', (tester) async {
      final list = ValueNotifier<List<SemiBreadcrumbItem>>(
        items(const ['a', 'b', 'c', 'd', 'e']),
      );
      await pumpHost(
        tester,
        ValueListenableBuilder<List<SemiBreadcrumbItem>>(
          valueListenable: list,
          builder: (context, value, _) =>
              SemiBreadcrumb(maxItemCount: 3, children: value),
        ),
      );
      await tester.pumpAndSettle();
      await neutralTap(tester);
      await tester.tap(find.byKey(SemiBreadcrumb.moreKey));
      await tester.pump();
      expect(find.text('b'), findsOneWidget);
      // items 5 → 6（state 不重挂）——★isCollapsed 置 false 后永不回收。
      list.value = items(const ['a', 'b', 'c', 'd', 'e', 'f']);
      await tester.pump();
      expect(find.text('b'), findsOneWidget);
      expect(find.text('f'), findsOneWidget);
      expect(find.byKey(SemiBreadcrumb.moreKey), findsNothing);
    });

    testWidgets('more 按钮 Enter-only（foundation.ts:26-30，Space 不响应 quirk）', (
      tester,
    ) async {
      await pumpHost(
        tester,
        breadcrumb(
          maxItemCount: 3,
          children: items(const ['a', 'b', 'c', 'd', 'e']),
        ),
      );
      await tester.pumpAndSettle();
      final ctx = tester.element(find.byKey(SemiBreadcrumb.moreKey));
      Focus.of(ctx).requestFocus();
      await tester.sendKeyEvent(LogicalKeyboardKey.space);
      await tester.pump();
      expect(find.text('b'), findsNothing);
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.pump();
      expect(find.text('b'), findsOneWidget);
    });
  });

  group('moreType popover', () {
    testWidgets('popover：面板列 restItem + 自拼 separator、hidden 项 separator 抑制', (
      tester,
    ) async {
      await pumpHost(
        tester,
        breadcrumb(
          maxItemCount: 3,
          moreType: SemiBreadcrumbMoreType.popover,
          children: const [
            SemiBreadcrumbItem(name: 'a', separator: '!'),
            SemiBreadcrumbItem(name: 'b', separator: '!'),
            SemiBreadcrumbItem(name: 'c', separator: '!'),
            SemiBreadcrumbItem(name: 'd', separator: '!'),
            SemiBreadcrumbItem(name: 'e'),
          ],
        ),
      );
      await tester.pumpAndSettle();
      expect(find.byKey(SemiBreadcrumb.popoverPanelKey), findsNothing);
      await neutralTap(tester);
      await tester.tap(find.byKey(SemiBreadcrumb.moreKey));
      await tester.pumpAndSettle();
      expect(find.byKey(SemiBreadcrumb.popoverPanelKey), findsOneWidget);
      // 面板列 restItem（隐藏项 b/c）。
      expect(
        find.descendant(
          of: find.byKey(SemiBreadcrumb.popoverPanelKey),
          matching: find.text('b'),
        ),
        findsOneWidget,
      );
      expect(
        find.descendant(
          of: find.byKey(SemiBreadcrumb.popoverPanelKey),
          matching: find.text('c'),
        ),
        findsOneWidget,
      );
      // 自拼 separator：面板内 1 个 context separator（b/c 之间）。
      expect(
        find.descendant(
          of: find.byKey(SemiBreadcrumb.popoverPanelKey),
          matching: find.text('/'),
        ),
        findsOneWidget,
      );
      // ★hidden 项 separator 抑制 quirk：b/c 自带 '!' 不进面板。
      expect(
        find.descendant(
          of: find.byKey(SemiBreadcrumb.popoverPanelKey),
          matching: find.text('!'),
        ),
        findsNothing,
      );
    });

    testWidgets('defaultType 点击展开全部（对照）', (tester) async {
      await pumpHost(
        tester,
        breadcrumb(
          maxItemCount: 3,
          moreType: SemiBreadcrumbMoreType.defaultType,
          children: items(const ['a', 'b', 'c', 'd', 'e']),
        ),
      );
      await tester.pumpAndSettle();
      await neutralTap(tester);
      await tester.tap(find.byKey(SemiBreadcrumb.moreKey));
      await tester.pump();
      expect(find.byKey(SemiBreadcrumb.popoverPanelKey), findsNothing);
      expect(find.text('b'), findsOneWidget);
      expect(find.text('c'), findsOneWidget);
    });
  });

  group('separator', () {
    testWidgets('默认 /、item 覆盖（裸渲染不包壳）、falsy 回退 quirk', (tester) async {
      // 包壳 separator 着色用 patch 绿与裸渲染区分。
      await pumpHost(
        tester,
        SemiBreadcrumbTheme(
          data: const SemiBreadcrumbThemeData(
            colorBreadcrumbSepearatorDefaultIconDefault: Color(0xff00ff00),
          ),
          child: breadcrumb(
            children: const [
              SemiBreadcrumbItem(name: 'a', separator: '???'),
              SemiBreadcrumbItem(name: 'b'),
              SemiBreadcrumbItem(name: 'c'),
            ],
          ),
        ),
      );
      await tester.pumpAndSettle();
      // item.separator truthy 优先：'???' 裸渲染（无包壳色），'/' 仅 b/c 间。
      expect(find.text('???'), findsOneWidget);
      expect(find.text('/'), findsOneWidget);
      expect(nameColor(tester, '/'), const Color(0xff00ff00));
      expect(nameColor(tester, '???'), isNot(const Color(0xff00ff00)));
      // ★falsy（''）回退 context quirk——无法用 '' 隐藏。
      await pumpHost(
        tester,
        breadcrumb(
          children: const [
            SemiBreadcrumbItem(name: 'a', separator: ''),
            SemiBreadcrumbItem(name: 'b'),
          ],
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('/'), findsOneWidget);
    });
  });

  group('截断与 tooltip', () {
    testWidgets('String name 150px 截断、showTooltip hover 出提示', (tester) async {
      const longName = '很长的级别名称很长的级别名称很长的级别名称很长的级别名称很长的级别名称';
      await pumpHost(
        tester,
        breadcrumb(children: items(const [longName, 'end'])),
      );
      await tester.pumpAndSettle();
      expect(nameWidth(tester, longName), lessThanOrEqualTo(150.0));
      expect(nameWidth(tester, longName), greaterThan(50.0));
      final gesture = await startMouse(tester);
      await gesture.moveTo(tester.getCenter(find.text(longName).first));
      // ★tooltip 首帧停泊需 ~4-5 泵（仓库硬规则 4）；勿起第二个鼠标手势。
      for (var i = 0; i < 5; i++) {
        await tester.pump(const Duration(milliseconds: 50));
      }
      // title + tooltip 内容各一份。
      expect(find.text(longName), findsNWidgets(2));
    });

    testWidgets('showTooltip=false 仍截断 quirk（item.tsx:100-104）', (
      tester,
    ) async {
      const longName = '很长的级别名称很长的级别名称很长的级别名称很长的级别名称很长的级别名称';
      await pumpHost(
        tester,
        breadcrumb(
          showTooltip: false,
          children: items(const [longName, 'end']),
        ),
      );
      await tester.pumpAndSettle();
      expect(nameWidth(tester, longName), lessThanOrEqualTo(150.0));
      final gesture = await startMouse(tester);
      await gesture.moveTo(tester.getCenter(find.text(longName).first));
      for (var i = 0; i < 5; i++) {
        await tester.pump(const Duration(milliseconds: 50));
      }
      expect(find.text(longName), findsOneWidget);
    });

    testWidgets('Widget name 原样无截断 quirk', (tester) async {
      await pumpHost(
        tester,
        breadcrumb(
          children: const [
            SemiBreadcrumbItem(
              name: SizedBox(width: 300, height: 18, child: Text('wide')),
            ),
            SemiBreadcrumbItem(name: 'end'),
          ],
        ),
      );
      await tester.pumpAndSettle();
      expect(tester.getSize(find.text('wide')), const Size(300, 18));
    });
  });

  group('renderMore / renderItem 槽', () {
    testWidgets('renderMore 收 restItems、renderItem 替换 name（routes 模式）', (
      tester,
    ) async {
      await pumpHost(
        tester,
        breadcrumb(
          maxItemCount: 3,
          renderMore: (rest) => Text('rest:${rest.length}'),
          children: items(const ['a', 'b', 'c', 'd', 'e']),
        ),
      );
      await tester.pumpAndSettle();
      // 隐藏项 b/c → restItems 长度 2。
      expect(find.text('rest:2'), findsOneWidget);
      await neutralTap(tester);
      await tester.tap(find.byKey(SemiBreadcrumb.moreKey));
      await tester.pump();
      expect(find.text('b'), findsOneWidget);
      expect(find.text('rest:2'), findsNothing);

      await pumpHost(
        tester,
        breadcrumb(
          routes: const [
            SemiBreadcrumbRoute(name: 'r1', path: '/p1'),
            SemiBreadcrumbRoute(name: 'r2', path: '/p2'),
          ],
          renderItem: (route) => Text('R:${route.path}'),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('R:/p1'), findsOneWidget);
      expect(find.text('R:/p2'), findsOneWidget);
      expect(find.text('r1'), findsNothing);
    });
  });

  group('compact 与 icon', () {
    testWidgets('compact 两档（字号 12/14）+ icon 项尺寸（small 12 / default 16）', (
      tester,
    ) async {
      await pumpHost(
        tester,
        breadcrumb(
          children: const [
            SemiBreadcrumbItem(name: 'x', icon: SemiIcon(SemiIcons.home)),
            SemiBreadcrumbItem(name: 'y'),
          ],
        ),
      );
      await tester.pumpAndSettle();
      expect(nameFontSize(tester, 'x'), 12.0);
      expect(tester.getSize(find.byType(SemiIcon)), const Size(12, 12));
      await pumpHost(
        tester,
        breadcrumb(
          compact: false,
          children: const [
            SemiBreadcrumbItem(name: 'x', icon: SemiIcon(SemiIcons.home)),
            SemiBreadcrumbItem(name: 'y'),
          ],
        ),
      );
      await tester.pumpAndSettle();
      expect(nameFontSize(tester, 'x'), 14.0);
      expect(tester.getSize(find.byType(SemiIcon)), const Size(16, 16));
    });
  });

  group('noLink 与 RTL', () {
    testWidgets('noLink 去 hover/active 色（item.tsx:178 无 item-link 类）', (
      tester,
    ) async {
      final t = const SemiThemeData.light();
      await pumpHost(
        tester,
        breadcrumb(
          children: const [
            SemiBreadcrumbItem(name: 'nl', noLink: true),
            SemiBreadcrumbItem(name: 'mid'),
            SemiBreadcrumbItem(name: 'last'),
          ],
        ),
      );
      await tester.pumpAndSettle();
      final gesture = await startMouse(tester);
      await gesture.moveTo(tester.getCenter(find.text('nl')));
      await tester.pump();
      // ★noLink 无 hover 色。
      expect(nameColor(tester, 'nl'), t.colors.colorText2);
      await gesture.moveTo(tester.getCenter(find.text('mid')));
      await tester.pump();
      // 可点项 hover → colorLink。
      expect(nameColor(tester, 'mid'), t.colors.colorLink);
    });

    testWidgets('RTL：margin/方向互换 + icon-title 间距双倍 quirk', (tester) async {
      await pumpHost(
        tester,
        breadcrumb(
          children: const [
            SemiBreadcrumbItem(name: 'a', icon: SemiIcon(SemiIcons.home)),
            SemiBreadcrumbItem(name: 'b'),
          ],
        ),
        direction: TextDirection.rtl,
      );
      await tester.pumpAndSettle();
      final icon = tester.getRect(find.byType(SemiIcon));
      final text = tester.getRect(find.text('a'));
      // ★RTL 双倍 quirk：column-gap 4 + rtl margin-right 4 并存 → 8。
      expect(icon.left - text.right, moreOrLessEquals(8.0));
      // 方向互换：首项贴右（Wrap RTL 起点 = 右）。
      expect(text.left, greaterThan(450));
      // separator 在 item 左侧（流向镜像）。
      expect(
        tester.getTopLeft(find.text('/')).dx,
        lessThan(tester.getTopLeft(find.text('a')).dx),
      );
      // LTR 对照：间距 4。
      await pumpHost(
        tester,
        breadcrumb(
          children: const [
            SemiBreadcrumbItem(name: 'a', icon: SemiIcon(SemiIcons.home)),
            SemiBreadcrumbItem(name: 'b'),
          ],
        ),
      );
      await tester.pumpAndSettle();
      final iconLtr = tester.getRect(find.byType(SemiIcon));
      final textLtr = tester.getRect(find.text('a'));
      expect(textLtr.left - iconLtr.right, moreOrLessEquals(4.0));
    });
  });
}
