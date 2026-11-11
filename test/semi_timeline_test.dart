import 'dart:io';

import 'package:flutter/material.dart' show Material;
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:semi_design_flutter/semi_design_flutter.dart';

Widget host(
  Widget child, {
  TextDirection direction = TextDirection.ltr,
  double textScale = 1,
  double? width,
}) => Directionality(
  textDirection: direction,
  child: MediaQuery(
    data: MediaQueryData(textScaler: TextScaler.linear(textScale)),
    child: Center(
      child: width == null ? child : SizedBox(width: width, child: child),
    ),
  ),
);

// 416 host width -> 400 row width after the 8px root padding on both sides.
const hostWidth = 416.0;
const rowWidth = 400.0;

Rect rowRect(WidgetTester tester, int index) =>
    tester.getRect(find.byType(Stack).at(index));
Rect tailRect(WidgetTester tester, int index) =>
    tester.getRect(find.byType(CustomPaint).at(index));
Rect textRect(WidgetTester tester, String text) =>
    tester.getRect(find.text(text));

const items = [
  SemiTimelineItemData(content: '第一段'),
  SemiTimelineItemData(content: '第二段'),
  SemiTimelineItemData(content: '第三段'),
];

void main() {
  test('theme defaults merge equality and live resolve', () {
    const base = SemiTimelineThemeData();
    const lightTheme = SemiThemeData.light();
    final light = base.resolve(lightTheme);
    expect(
      light.colorTimelineDotDefaultBgDefault,
      lightTheme.colors.colorPrimary,
    );
    expect(
      light.colorTimelineDotInfoBgDefault,
      lightTheme.colors.colorTertiaryLightActive,
    );
    expect(
      light.colorTimelineDotSuccessBgDefault,
      lightTheme.colors.colorSuccess,
    );
    expect(
      light.colorTimelineDotWarningBgDefault,
      lightTheme.colors.colorWarning,
    );
    expect(light.colorTimelineDotErrorBgDefault, lightTheme.colors.colorDanger);
    expect(light.colorTimelineTailBorder, lightTheme.colors.colorText3);
    expect(
      light.colorTimelineTimeDefaultTextDefault,
      lightTheme.colors.colorText2,
    );
    expect(light.colorTimelineItemHeadBg, const Color(0x00000000));
    expect(
      light.colorTimelineItemContentTextDefault,
      lightTheme.colors.colorText0,
    );
    expect(light.spacingTimelineMargin, 0);
    expect(light.spacingTimelinePadding, 8);
    expect(light.spacingTimelineTailTop, 20);
    expect(light.spacingTimelineTailLeft, 4);
    expect(light.spacingTimelineHeadTop, 5);
    expect(light.spacingTimelineHeadCustomTop, 10);
    expect(light.spacingTimelineHeadCustomLeft, 5);
    expect(light.spacingTimelineContentMarginLeft, 25);
    expect(light.spacingTimelineTimeMarginTop, 4);
    expect(light.spacingTimelineTimeTop, -2);
    expect(light.spacingTimelineItemMargin, 0);
    expect(light.spacingTimelineItemPaddingBottom, 24);
    expect(light.spacingTimelineItemHeadMarginLeft, -4);
    expect(light.spacingTimelineItemRightItemContent, 0);
    expect(light.widthTimelineDot, 9);
    expect(light.widthTimelineTailBorder, 1);
    expect(light.widthTimelineHeadCustomBorder, 0);
    expect(
      light.radiusTimelineHead,
      lightTheme.radius.borderRadiusCircle.value,
    );
    expect(light.radiusTimelineHeadCustom, 0);
    const darkTheme = SemiThemeData.dark();
    final dark = base.resolve(darkTheme);
    expect(
      dark.colorTimelineDotDefaultBgDefault,
      darkTheme.colors.colorPrimary,
    );
    expect(
      dark.colorTimelineDotDefaultBgDefault,
      isNot(light.colorTimelineDotDefaultBgDefault),
    );
    expect(dark.colorTimelineTailBorder, darkTheme.colors.colorText3);
    const patch = SemiTimelineThemeData(
      spacingTimelineContentMarginLeft: 40,
      widthTimelineDot: 12,
      colorTimelineTailBorder: Color(0xff010203),
    );
    expect(base.merge(null), base);
    expect(base.merge(patch), patch);
    expect(patch.merge(base), patch);
    expect(
      patch.merge(const SemiTimelineThemeData(spacingTimelineTailTop: 33)),
      const SemiTimelineThemeData(
        spacingTimelineContentMarginLeft: 40,
        spacingTimelineTailTop: 33,
        widthTimelineDot: 12,
        colorTimelineTailBorder: Color(0xff010203),
      ),
    );
    expect(patch.copyWith(), patch);
    expect(
      patch,
      const SemiTimelineThemeData(
        spacingTimelineContentMarginLeft: 40,
        widthTimelineDot: 12,
        colorTimelineTailBorder: Color(0xff010203),
      ),
    );
    expect(
      patch.hashCode,
      const SemiTimelineThemeData(
        colorTimelineTailBorder: Color(0xff010203),
        spacingTimelineContentMarginLeft: 40,
        widthTimelineDot: 12,
      ).hashCode,
    );
    expect(patch == base, isFalse);
    final resolved = patch.resolve(darkTheme);
    expect(resolved.spacingTimelineContentMarginLeft, 40);
    expect(resolved.widthTimelineDot, 12);
    expect(resolved.colorTimelineTailBorder, const Color(0xff010203));
    expect(resolved.spacingTimelineTailTop, 20);
    expect(
      resolved.radiusTimelineHead,
      darkTheme.radius.borderRadiusCircle.value,
    );
    const themes = SemiComponentThemes(
      timeline: SemiTimelineThemeData(spacingTimelinePadding: 3),
    );
    expect(const SemiComponentThemes().timeline, const SemiTimelineThemeData());
    expect(themes.copyWith().timeline, themes.timeline);
    expect(
      themes.copyWith(timeline: const SemiTimelineThemeData()).timeline,
      const SemiTimelineThemeData(),
    );
    expect(themes == const SemiComponentThemes(), isFalse);
    expect(
      themes.hashCode,
      const SemiComponentThemes(
        timeline: SemiTimelineThemeData(spacingTimelinePadding: 3),
      ).hashCode,
    );
  });
  test('theme field provenance comments', () {
    final theme = File('lib/src/theme/semi_timeline_theme_data.dart')
        .readAsStringSync();
    final widget = File('lib/src/components/semi_timeline.dart')
        .readAsStringSync();
    const declarations = [
      r'$color-timeline_dot_default-bg-default: var(--semi-color-primary)',
      r'$color-timeline_dot_success-bg-default: var(--semi-color-success)',
      r'$color-timeline_dot_warning-bg-default: var(--semi-color-warning)',
      r'$color-timeline_dot_error-bg-default: var(--semi-color-danger)',
      r'$color-timeline_dot_info-bg-default: var(--semi-color-tertiary-light-active)',
      r'$color-timeline_tail-border: var(--semi-color-text-3)',
      r'$color-timeline_time_default-text-default: var(--semi-color-text-2)',
      r'$color-timeline_item_head-bg: transparent',
      r'$color-timeline_item_content-text-default: var(--semi-color-text-0)',
      r'$spacing-timeline-margin: $spacing-none',
      r'$spacing-timeline-padding: $spacing-tight',
      r'$spacing-timeline_tail-top: $spacing-base-loose',
      r'$spacing-timeline_tail-left: $spacing-extra-tight',
      r'$spacing-timeline_head-top: 5px',
      r'$spacing-timeline_head_custom-top: 10px',
      r'$spacing-timeline_head_custom-left: 5px',
      r'$spacing-timeline_content-marginLeft: 25px',
      r'$spacing-timeline_time-marginTop: $spacing-extra-tight',
      r'$spacing-timeline_time-top: -2px',
      r'$spacing-timeline_item-margin: $spacing-none',
      r'$spacing-timeline_item-paddingBottom: $spacing-loose',
      r'$spacing-timeline_item_content_time-marginLeft: calc(-40px - 100%)',
      r'$spacing-timeline_item_right_item-left: calc(100% - 9px)',
      r'$spacing-timeline_item_right_item_content: $spacing-none',
      r'$spacing-timeline_item_left_item_content-left: calc(50% - 4px)',
      r'$spacing-timeline_item_head_custom-left: 50%',
      r'$spacing-timeline_item_head-marginLeft: -4px',
      r'$width-timeline: 100%',
      r'$width-timeline_dot: 9px',
      r'$width-timeline_head_custom: auto',
      r'$width-timeline_tail-border: $border-thickness-control',
      r'$width-timeline_head_custom-border: $border-thickness',
      r'$width-timeline_item_content_time: 100%',
      r'$width-timeline_item_right_content: calc(100% - 28px)',
      r'$width-timeline_item_left_item_content: calc(50% - 14px)',
      r'$width-timeline_item_right_item_content: calc(50% - 20px)',
      r'$height-timline_tail: calc(100% - 20px)',
      r'$height-timeline_head_custom: auto',
      r'$radius-timeline_head: var(--semi-border-radius-circle)',
      r'$radius-timeline_head_custom: 0',
      r'$motion-timeline_head_custom-transform: translate(-50%, -50%)',
      r'$motion-timeline_head_custom-transform-rtl: translate(50%, -50%)',
    ];
    expect(declarations.length, 42);
    for (final declaration in declarations) {
      expect(theme + widget, contains(declaration));
    }
    expect(theme, contains('packages/semi-foundation/timeline/variables.scss'));
    expect(
      widget,
      contains('packages/semi-foundation/timeline/variables.scss'),
    );
  });
  testWidgets('left mode axis gutter and tail geometry', (tester) async {
    await tester.pumpWidget(
      host(width: hostWidth, const SemiTimeline(items: items)),
    );
    final row = rowRect(tester, 0);
    expect(row.width, rowWidth);
    final tail = tailRect(tester, 0);
    expect(tail.left, row.left + 4);
    expect(tail.width, 1);
    expect(tail.top, row.top + 20);
    expect(tail.bottom, row.bottom);
    expect(row.bottom - row.top, 20 + tail.height);
    expect(textRect(tester, '第一段').left, row.left + 25);
    expect(tester.widget<Text>(find.text('第一段')).textAlign, TextAlign.start);
    final dot = tester.getRect(find.byType(DecoratedBox).first);
    expect(dot.left, row.left);
    expect(dot.top, row.top + 5);
    expect(dot.width, 9);
    expect(dot.height, 9);
    // Last row draws no tail: two rows -> one CustomPaint.
    await tester.pumpWidget(
      host(width: hostWidth, SemiTimeline(items: [items[0]])),
    );
    expect(find.byType(CustomPaint), findsNothing);
    await tester.pumpWidget(host(const SizedBox()));
  });
  testWidgets('right mode end axis and content slot', (tester) async {
    await tester.pumpWidget(
      host(
        width: hostWidth,
        const SemiTimeline(mode: SemiTimelineMode.right, items: items),
      ),
    );
    final row = rowRect(tester, 0);
    final tail = tailRect(tester, 0);
    expect(tail.left, row.left + rowWidth - 9);
    expect(tail.right, row.left + rowWidth - 8);
    expect(tail.top, row.top + 20);
    expect(tail.bottom, row.bottom);
    final text = textRect(tester, '第一段');
    expect(text.left, row.left);
    expect(text.right, row.left + rowWidth - 28);
    expect(tester.widget<Text>(find.text('第一段')).textAlign, TextAlign.end);
    final dot = tester.getRect(find.byType(DecoratedBox).first);
    expect(dot.left, row.left + rowWidth - 13);
    expect(dot.width, 9);
    await tester.pumpWidget(host(const SizedBox()));
  });
  testWidgets('center mode three slots and absolute time', (tester) async {
    await tester.pumpWidget(
      host(
        width: hostWidth,
        const SemiTimeline(
          mode: SemiTimelineMode.center,
          items: [
            SemiTimelineItemData(content: '内容', extra: '辅助', time: '时间'),
            SemiTimelineItemData(content: '次段'),
          ],
        ),
      ),
    );
    final row = rowRect(tester, 0);
    final axis = row.left + rowWidth / 2;
    final tail = tailRect(tester, 0);
    expect(tail.left, axis);
    // Default position is left -> end-side content slot.
    final content = textRect(tester, '内容');
    expect(content.left, axis + 6);
    expect(content.right, row.left + rowWidth - 8);
    expect(tester.widget<Text>(find.text('内容')).textAlign, TextAlign.start);
    // Extra stays in the content flow under the content.
    final extra = textRect(tester, '辅助');
    expect(extra.left, content.left);
    expect(extra.top, greaterThanOrEqualTo(content.bottom));
    // Time is absolutely placed in the axis-start slot at top -2, right-aligned.
    final time = textRect(tester, '时间');
    expect(time.top, row.top - 2);
    expect(time.right, axis - 19);
    expect(tester.widget<Text>(find.text('时间')).textAlign, TextAlign.end);
    await tester.pumpWidget(host(const SizedBox()));
  });
  testWidgets('alternate parity positions and in-flow time', (tester) async {
    await tester.pumpWidget(
      host(
        width: hostWidth,
        const SemiTimeline(
          mode: SemiTimelineMode.alternate,
          items: [
            SemiTimelineItemData(content: '偶数', time: 'T0'),
            SemiTimelineItemData(content: '奇数', time: 'T1'),
          ],
        ),
      ),
    );
    final axis = rowRect(tester, 0).left + rowWidth / 2;
    final even = textRect(tester, '偶数');
    expect(even.left, axis + 6);
    expect(tester.widget<Text>(find.text('偶数')).textAlign, TextAlign.start);
    final odd = textRect(tester, '奇数');
    expect(odd.left, rowRect(tester, 1).left);
    expect(odd.right, axis - 20);
    expect(tester.widget<Text>(find.text('奇数')).textAlign, TextAlign.end);
    // Time flows under its content on the same side.
    final t0 = textRect(tester, 'T0');
    expect(t0.left, even.left);
    expect(t0.top, greaterThanOrEqualTo(even.bottom));
    final t1 = textRect(tester, 'T1');
    expect(t1.right, odd.right);
    expect(t1.top, greaterThanOrEqualTo(odd.bottom));
    await tester.pumpWidget(host(const SizedBox()));
  });
  testWidgets('position override and same-side modes', (tester) async {
    Widget timeline(SemiTimelineMode mode) => host(
      width: hostWidth,
      SemiTimeline(
        mode: mode,
        items: const [
          SemiTimelineItemData(
            content: '覆盖',
            position: SemiTimelinePosition.right,
          ),
        ],
      ),
    );
    await tester.pumpWidget(timeline(SemiTimelineMode.center));
    final axis = rowRect(tester, 0).left + rowWidth / 2;
    expect(textRect(tester, '覆盖').right, axis - 20);
    expect(tester.widget<Text>(find.text('覆盖')).textAlign, TextAlign.end);
    await tester.pumpWidget(timeline(SemiTimelineMode.alternate));
    expect(textRect(tester, '覆盖').right, axis - 20);
    // left/right modes pin every row to the mode side (getPosCls).
    await tester.pumpWidget(timeline(SemiTimelineMode.left));
    expect(textRect(tester, '覆盖').left, rowRect(tester, 0).left + 25);
    await tester.pumpWidget(timeline(SemiTimelineMode.right));
    expect(
      textRect(tester, '覆盖').right,
      rowRect(tester, 0).left + rowWidth - 28,
    );
    await tester.pumpWidget(host(const SizedBox()));
  });
  testWidgets('type colors and inline color override', (tester) async {
    const keys = ['n', 'o', 's', 'w', 'e'];
    await tester.pumpWidget(
      host(
        width: hostWidth,
        const SemiTimeline(
          items: [
            SemiTimelineItemData(
              content: 'n',
              type: SemiTimelineItemType.normal,
            ),
            SemiTimelineItemData(
              content: 'o',
              type: SemiTimelineItemType.ongoing,
            ),
            SemiTimelineItemData(
              content: 's',
              type: SemiTimelineItemType.success,
            ),
            SemiTimelineItemData(
              content: 'w',
              type: SemiTimelineItemType.warning,
            ),
            SemiTimelineItemData(
              content: 'e',
              type: SemiTimelineItemType.error,
            ),
          ],
        ),
      ),
    );
    const theme = SemiThemeData.light();
    final expected = [
      theme.colors.colorTertiaryLightActive,
      theme.colors.colorPrimary,
      theme.colors.colorSuccess,
      theme.colors.colorWarning,
      theme.colors.colorDanger,
    ];
    for (var i = 0; i < keys.length; i++) {
      final dot = tester.widget<DecoratedBox>(
        find.descendant(
          of: find.byType(Stack).at(i),
          matching: find.byType(DecoratedBox),
        ),
      );
      expect((dot.decoration as BoxDecoration).color, expected[i]);
    }
    // Inline color beats the type color (upstream inline style).
    await tester.pumpWidget(
      host(
        width: hostWidth,
        const SemiTimeline(
          items: [
            SemiTimelineItemData(
              content: 'c',
              type: SemiTimelineItemType.error,
              color: Color(0xff112233),
            ),
          ],
        ),
      ),
    );
    final dot = tester.widget<DecoratedBox>(find.byType(DecoratedBox));
    expect((dot.decoration as BoxDecoration).color, const Color(0xff112233));
    await tester.pumpWidget(host(const SizedBox()));
  });
  testWidgets('custom dot centering transparent head and color quirk', (
    tester,
  ) async {
    const dotSlot = SizedBox(key: ValueKey('dot'), width: 10, height: 10);
    await tester.pumpWidget(
      host(
        width: hostWidth,
        const SemiTimeline(
          items: [
            SemiTimelineItemData(
              content: 'a',
              type: SemiTimelineItemType.warning,
              dot: dotSlot,
            ),
            SemiTimelineItemData(
              content: 'b',
              type: SemiTimelineItemType.success,
              dot: dotSlot,
              color: Color(0xff445566),
            ),
          ],
        ),
      ),
    );
    final row0 = rowRect(tester, 0);
    final first = tester.getRect(find.byKey(const ValueKey('dot')).first);
    expect(first.center.dx, row0.left + 5);
    expect(first.center.dy, row0.top + 10);
    final head = tester.widget<DecoratedBox>(
      find
          .ancestor(
            of: find.byKey(const ValueKey('dot')).first,
            matching: find.byType(DecoratedBox),
          )
          .first,
    );
    expect((head.decoration as BoxDecoration).color, const Color(0x00000000));
    // Upstream quirk: inline color overrides even the custom-dot background.
    final head2 = tester.widget<DecoratedBox>(
      find
          .ancestor(
            of: find.byKey(const ValueKey('dot')).last,
            matching: find.byType(DecoratedBox),
          )
          .first,
    );
    expect((head2.decoration as BoxDecoration).color, const Color(0xff445566));
    // Custom dots skip the 9x9 circle.
    expect(find.byType(DecoratedBox), findsNWidgets(2));
    await tester.pumpWidget(host(const SizedBox()));
  });
  testWidgets('zero metadata keeps 0 and hides false null empty', (
    tester,
  ) async {
    await tester.pumpWidget(
      host(
        width: hostWidth,
        const SemiTimeline(
          items: [
            SemiTimelineItemData(content: 'zero', extra: 0, time: 0),
            SemiTimelineItemData(content: 'string zero', time: '0'),
            SemiTimelineItemData(content: 'hidden', extra: false, time: null),
            SemiTimelineItemData(content: 'blank', extra: '', time: double.nan),
          ],
        ),
      ),
    );
    expect(find.text('0'), findsNWidgets(3));
    // Only the content text renders for the hidden/blank rows.
    expect(find.text('hidden'), findsOneWidget);
    expect(find.text('blank'), findsOneWidget);
    expect(
      tester
          .widgetList<SemiText>(find.byType(SemiText))
          .map((w) => w.data)
          .toList(),
      ['zero', '0', '0', 'string zero', '0', 'hidden', 'blank'],
    );
    await tester.pumpWidget(host(const SizedBox()));
  });
  testWidgets('render order is content extra time', (tester) async {
    await tester.pumpWidget(
      host(
        width: hostWidth,
        const SemiTimeline(
          items: [SemiTimelineItemData(content: '内容', extra: '辅助', time: '时间')],
        ),
      ),
    );
    final content = textRect(tester, '内容');
    final extra = textRect(tester, '辅助');
    final time = textRect(tester, '时间');
    expect(content.top, lessThan(extra.top));
    expect(extra.top, lessThan(time.top));
    expect(extra.top - content.bottom, 4);
    expect(time.top - extra.bottom, 4);
    await tester.pumpWidget(host(const SizedBox()));
  });
  testWidgets('onTap semantics button without duplicate reading', (
    tester,
  ) async {
    final handle = tester.ensureSemantics();
    var taps = 0;
    await tester.pumpWidget(
      host(
        width: hostWidth,
        SemiTimeline(
          semanticsLabel: '事故时间线',
          items: [
            SemiTimelineItemData(
              content: '可点',
              dot: Semantics(
                label: '点标记',
                child: const SizedBox(width: 8, height: 8),
              ),
              onTap: () => taps += 1,
            ),
            const SemiTimelineItemData(content: '不可点'),
          ],
        ),
      ),
    );
    expect(find.bySemanticsLabel('点标记'), findsNothing);
    final node = tester.getSemantics(find.bySemanticsLabel('可点'));
    expect(node.flagsCollection.isButton, isTrue);
    // The label lives on exactly one node: no duplicate announcement.
    expect(find.bySemanticsLabel('可点'), findsOneWidget);
    expect(find.bySemanticsLabel(RegExp('事故时间线')), findsOneWidget);
    await tester.tap(find.text('可点'));
    expect(taps, 1);
    await tester.tap(find.text('不可点'));
    expect(taps, 1);
    handle.dispose();
    await tester.pumpWidget(host(const SizedBox()));
  });
  testWidgets('rtl mirrors axis gutter and content', (tester) async {
    await tester.pumpWidget(
      host(
        width: hostWidth,
        direction: TextDirection.rtl,
        const SemiTimeline(items: items),
      ),
    );
    final row = rowRect(tester, 0);
    final tail = tailRect(tester, 0);
    expect(tail.left, row.left + rowWidth - 5);
    expect(tail.right, row.left + rowWidth - 4);
    expect(textRect(tester, '第一段').right, row.left + rowWidth - 25);
    await tester.pumpWidget(
      host(
        width: hostWidth,
        direction: TextDirection.rtl,
        const SemiTimeline(
          mode: SemiTimelineMode.center,
          items: [
            SemiTimelineItemData(content: '内容', time: '时间'),
            SemiTimelineItemData(content: '次段'),
          ],
        ),
      ),
    );
    final centerRow = rowRect(tester, 0);
    final axis = centerRow.left + rowWidth / 2;
    expect(tailRect(tester, 0).left, axis - 1);
    // Default position left: content mirrors to the axis-start side.
    expect(textRect(tester, '内容').right, axis - 6);
    // Center time mirrors to the physical start side, hugging the axis.
    final time = textRect(tester, '时间');
    expect(time.top, centerRow.top - 2);
    expect(time.left, axis + 19);
    await tester.pumpWidget(host(const SizedBox()));
  });
  testWidgets('text scaling recomputes the tail length', (tester) async {
    await tester.pumpWidget(
      host(width: hostWidth, textScale: 3, const SemiTimeline(items: items)),
    );
    final row = rowRect(tester, 0);
    final tail = tailRect(tester, 0);
    expect(tail.top, row.top + 20);
    expect(tail.bottom, row.bottom);
    expect(tail.height, row.height - 20);
    expect(row.height, greaterThan(20 + 24));
    await tester.pumpWidget(host(const SizedBox()));
  });
  testWidgets('narrow and unbounded constraints keep layouts sane', (
    tester,
  ) async {
    const long = SemiTimelineItemData(
      content: '很长很长很长的节点内容很长很长很长的节点内容',
      time: '2019-07-14 10:35',
      extra: '很长很长很长的辅助说明很长很长很长的辅助说明',
    );
    for (final mode in SemiTimelineMode.values) {
      await tester.pumpWidget(
        host(
          width: 80,
          SingleChildScrollView(
            child: SemiTimeline(mode: mode, items: const [long, long]),
          ),
        ),
      );
      expect(tester.takeException(), isNull);
    }
    for (final mode in SemiTimelineMode.values) {
      await tester.pumpWidget(
        host(
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: SemiTimeline(mode: mode, items: const [long, long]),
          ),
        ),
      );
      expect(tester.takeException(), isNull);
    }
    await tester.pumpWidget(
      host(
        ListView(
          children: const [
            SemiTimeline(mode: SemiTimelineMode.alternate, items: [long]),
          ],
        ),
      ),
    );
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(host(const SizedBox()));
  });
  testWidgets('no Material widgets anywhere', (tester) async {
    await tester.pumpWidget(
      host(
        width: hostWidth,
        SemiTimeline(
          items: [
            SemiTimelineItemData(content: '内容', time: '时间', onTap: () {}),
          ],
        ),
      ),
    );
    expect(find.byType(Material), findsNothing);
    await tester.pumpWidget(host(const SizedBox()));
  });
  testWidgets('application level and nested local patches merge', (
    tester,
  ) async {
    Widget build() => host(
      width: hostWidth,
      SemiTheme(
        data: const SemiThemeData.light(
          components: SemiComponentThemes(
            timeline: SemiTimelineThemeData(
              spacingTimelineContentMarginLeft: 40,
              spacingTimelineItemPaddingBottom: 30,
            ),
          ),
        ),
        child: SemiTimelineTheme(
          data: const SemiTimelineThemeData(
            spacingTimelineContentMarginLeft: 50,
            spacingTimelineTailTop: 12,
          ),
          child: SemiTimelineTheme(
            data: const SemiTimelineThemeData(spacingTimelineTailTop: 25),
            child: const SemiTimeline(items: items),
          ),
        ),
      ),
    );
    await tester.pumpWidget(build());
    final row = rowRect(tester, 0);
    expect(textRect(tester, '第一段').left - row.left, 50);
    expect(tailRect(tester, 0).top - row.top, 25);
    expect(row.height, tailRect(tester, 0).height + 25);
    expect(row.bottom - textRect(tester, '第一段').bottom, 30);
    final context = tester.element(find.byType(SemiTimeline));
    expect(
      SemiTimelineTheme.resolve(context).spacingTimelineContentMarginLeft,
      50,
    );
    expect(SemiTimelineTheme.resolve(context).spacingTimelineTailTop, 25);
    expect(
      SemiTimelineTheme.resolve(context).spacingTimelineItemPaddingBottom,
      30,
    );
    expect(SemiTimelineTheme.maybeOf(context), isNotNull);
    await tester.pumpWidget(host(const SizedBox()));
  });
  testWidgets('local patches survive capture and globals re-resolve', (
    tester,
  ) async {
    await tester.pumpWidget(
      host(
        width: hostWidth,
        SemiTimelineTheme(
          data: const SemiTimelineThemeData(
            spacingTimelineContentMarginLeft: 33,
            spacingTimelineTailTop: 25,
          ),
          child: const SemiTimeline(items: items),
        ),
      ),
    );
    final context = tester.element(find.byType(SemiTimeline));
    expect(SemiTimelineTheme.maybeOf(context), isNotNull);
    final captured = InheritedTheme.captureAll(
      context,
      const SemiTimeline(items: items),
    );
    await tester.pumpWidget(
      host(
        width: hostWidth,
        SemiTheme(
          data: const SemiThemeData.light(
            components: SemiComponentThemes(
              timeline: SemiTimelineThemeData(
                spacingTimelineContentMarginLeft: 44,
                spacingTimelineItemPaddingBottom: 30,
              ),
            ),
          ),
          child: captured,
        ),
      ),
    );
    // Captured local patches survive; application data re-resolves.
    final row = rowRect(tester, 0);
    expect(textRect(tester, '第一段').left - row.left, 33);
    expect(tailRect(tester, 0).top - row.top, 25);
    expect(row.bottom - textRect(tester, '第一段').bottom, 30);
    await tester.pumpWidget(host(const SizedBox()));
  });
  testWidgets('patches cross SemiTheme boundary and update in same mode', (
    tester,
  ) async {
    Widget build(double margin) => host(
      width: hostWidth,
      SemiTimelineTheme(
        data: SemiTimelineThemeData(spacingTimelineContentMarginLeft: margin),
        child: SemiTheme(
          data: const SemiThemeData.light(),
          child: const SemiTimelineTheme(
            data: SemiTimelineThemeData(spacingTimelineTailTop: 25),
            child: SemiTimeline(items: items),
          ),
        ),
      ),
    );
    await tester.pumpWidget(build(30));
    var row = rowRect(tester, 0);
    expect(textRect(tester, '第一段').left - row.left, 30);
    expect(tailRect(tester, 0).top - row.top, 25);
    await tester.pumpWidget(build(30));
    expect(textRect(tester, '第一段').left - row.left, 30);
    await tester.pumpWidget(build(36));
    row = rowRect(tester, 0);
    expect(textRect(tester, '第一段').left - row.left, 36);
    expect(tailRect(tester, 0).top - row.top, 25);
    final context = tester.element(find.byType(SemiTimeline));
    final captured = InheritedTheme.captureAll(
      context,
      const SemiTimeline(items: items),
    );
    await tester.pumpWidget(host(width: hostWidth, captured));
    row = rowRect(tester, 0);
    expect(textRect(tester, '第一段').left - row.left, 36);
    expect(tailRect(tester, 0).top - row.top, 25);
    await tester.pumpWidget(host(const SizedBox()));
  });
  testWidgets('theme metrics drive the rendered geometry', (tester) async {
    await tester.pumpWidget(
      host(
        width: hostWidth,
        const SemiTheme(
          data: SemiThemeData.light(
            components: SemiComponentThemes(
              timeline: SemiTimelineThemeData(
                spacingTimelineContentMarginLeft: 30,
                spacingTimelineTailLeft: 7,
                spacingTimelineTailTop: 15,
                spacingTimelineHeadTop: 3,
                spacingTimelineItemPaddingBottom: 10,
                spacingTimelineHeadCustomTop: 14,
                spacingTimelineHeadCustomLeft: 9,
                widthTimelineDot: 12,
                widthTimelineTailBorder: 2,
                colorTimelineTailBorder: Color(0xff00ff00),
              ),
            ),
          ),
          child: SemiTimeline(
            items: [
              SemiTimelineItemData(
                content: '内容',
                dot: SizedBox(key: ValueKey('dot'), width: 6, height: 6),
              ),
              SemiTimelineItemData(content: '第二段'),
            ],
          ),
        ),
      ),
    );
    final row = rowRect(tester, 0);
    expect(textRect(tester, '内容').left - row.left, 30);
    final tail = tailRect(tester, 0);
    expect(tail.left - row.left, 7);
    expect(tail.width, 2);
    expect(tail.top - row.top, 15);
    expect(row.height, tail.height + 15);
    expect(row.height, lessThan(15 + 10 + 60));
    final dot = tester.getRect(find.byKey(const ValueKey('dot')));
    expect(dot.center.dx, row.left + 9);
    expect(dot.center.dy, row.top + 14);
    final paint =
        tester.widget<CustomPaint>(find.byType(CustomPaint)).painter!
            as dynamic;
    expect(paint.color, const Color(0xff00ff00));
    await tester.pumpWidget(host(const SizedBox()));
  });
}
