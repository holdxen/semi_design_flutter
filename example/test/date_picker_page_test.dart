import 'package:example/pages/date_picker.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:semi_design_flutter/semi_design_flutter.dart';

Finder keyed(String key) => find.byKey(ValueKey(key));

Finder editable(String key) =>
    find.descendant(of: keyed(key), matching: find.byType(EditableText));

/// Range trigger inputs: index 0 = start, 1 = end (renderRangeInput order).
Finder rangeEdit(String key, int index) => editable(key).at(index);

Finder statusContaining(String text) => find.descendant(
  of: keyed('datepicker-status'),
  matching: find.textContaining(text),
);

Finder logContaining(String text) => find.descendant(
  of: keyed('datepicker-events-log'),
  matching: find.textContaining(text),
);

String inputText(WidgetTester tester, String key) =>
    tester.widget<EditableText>(editable(key)).controller.text;

String rangeText(WidgetTester tester, String key, int index) =>
    tester.widget<EditableText>(editable(key).at(index)).controller.text;

String fmt(DateTime d) =>
    '${d.year.toString().padLeft(4, '0')}-'
    '${d.month.toString().padLeft(2, '0')}-'
    '${d.day.toString().padLeft(2, '0')}';

Future<void> start(WidgetTester tester) async {
  addTearDown(() async => tester.pumpWidget(const SizedBox.shrink()));
  await tester.pumpWidget(const SemiApp(home: DatePickerPage()));
  await tester.pump(const Duration(milliseconds: 50));
}

/// Absorb the one dropped hit test (docs/known_issues.md #1) at a neutral
/// spot: (4, 4) sits in the page padding, away from every trigger.
Future<void> warmup(WidgetTester tester) async {
  await tester.tapAt(const Offset(4, 4));
  await tester.pump();
}

/// Neutral tap INSIDE the open panel: a weekday label (Text absorbs the hit)
/// or the popup's top padding strip for the yam panels. Popup-rect taps never
/// close the panel (the tooltip's outside check is rect containment), and this
/// keeps `warmup`'s outside tap from closing it.
Future<void> warmupInPanel(WidgetTester tester) async {
  final weekday = find.text('日');
  final Offset at;
  if (weekday.evaluate().isNotEmpty) {
    at = tester.getRect(weekday.first).center;
  } else {
    final popup = tester.getRect(find.byType(SemiTooltipPopup));
    at = Offset(popup.center.dx, popup.top + 4);
  }
  await tester.tapAt(at);
  await tester.pump();
}

/// Panel bodies mount a few frames after `visible` flips (the tooltip
/// overlay's entrance); the hide animation needs the same pumps to unmount.
Future<void> settlePanel(WidgetTester tester) async {
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 150));
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 150));
  await tester.pump();
}

Future<void> tap(WidgetTester tester, Finder finder) async {
  await tester.ensureVisible(finder);
  await tester.pump(const Duration(milliseconds: 50));
  await warmup(tester);
  await tester.tap(finder);
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 100));
  await tester.pump();
}

/// Open the panel of the demo named by [key] ([at] picks the tap target — the
/// range demos must tap the START input so focus lands on rangeStart).
Future<void> openPanel(WidgetTester tester, String key, {Finder? at}) async {
  final target = at ?? keyed(key);
  await tester.ensureVisible(target);
  await tester.pump(const Duration(milliseconds: 50));
  await warmup(tester);
  await tester.tap(target);
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 100));
  await tester.pump();
  await settlePanel(tester);
}

/// Tap inside an open panel (day cells, nav buttons, presets, yam rows): the
/// sacrificial in-panel tap absorbs the dropped hit after focus rebuilds.
Future<void> tapInPanel(WidgetTester tester, Finder finder) async {
  await warmupInPanel(tester);
  await tester.tap(finder);
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 100));
  await tester.pump();
  await settlePanel(tester);
}

Future<TestGesture> mouse(WidgetTester tester) async {
  final gesture = await tester.createGesture(kind: PointerDeviceKind.mouse);
  await gesture.addPointer(location: Offset.zero);
  addTearDown(gesture.removePointer);
  return gesture;
}

void main() {
  testWidgets('sections fit a narrow scaled screen and scroll to the bottom', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 640);
    tester.view.devicePixelRatio = 1;
    tester.platformDispatcher.textScaleFactorTestValue = 1.2;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
    await start(tester);
    for (final title in [
      '基本用法',
      '受控',
      '日期范围',
      '同步切换双面板月份',
      '事件回调',
      '切换月份/年份（autoSwitchDate）',
      '周起始 weekStartsOn',
      '年月选择',
      '年月范围选择',
      '快捷选择',
      '禁用与不可选日期',
      '自定义显示格式',
      '尺寸与状态',
      '控制器',
    ]) {
      expect(find.text(title), findsOneWidget);
      await tester.ensureVisible(find.text(title));
      await tester.pump(const Duration(milliseconds: 100));
      expect(tester.takeException(), isNull);
    }
  });

  testWidgets(
    'basic picks a day and closes; typed input ★round-trips or falls back',
    (tester) async {
      await start(tester);
      final now = DateTime.now();
      final day15 = DateTime(now.year, now.month, 15);
      await openPanel(tester, 'datepicker-basic');
      expect(find.byType(SemiTooltipPopup), findsOneWidget);
      await tapInPanel(tester, find.byKey(SemiDatePicker.dayKey(day15)));
      // date 单选关门，状态行显示选中日期。
      expect(find.byType(SemiTooltipPopup), findsNothing);
      expect(statusContaining(fmt(day15)), findsOneWidget);
      expect(inputText(tester, 'datepicker-basic'), fmt(day15));
      // ★非法输入提交回退到 state value（round-trip 规则）。
      await tester.ensureVisible(editable('datepicker-basic'));
      await tester.pump(const Duration(milliseconds: 50));
      await tester.enterText(editable('datepicker-basic'), 'abc');
      await tester.pump();
      expect(inputText(tester, 'datepicker-basic'), 'abc');
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));
      expect(inputText(tester, 'datepicker-basic'), fmt(day15));
      // 能解析但 ★round-trip 失败（format(parse(x)) !== x）同样回退。
      await tester.enterText(
        editable('datepicker-basic'),
        '2026-01-05T00:00:00',
      );
      await tester.pump();
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));
      expect(inputText(tester, 'datepicker-basic'), fmt(day15));
      // ★超过 4 位的年份拒绝，回退。
      await tester.enterText(editable('datepicker-basic'), '12024-01-01');
      await tester.pump();
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));
      expect(inputText(tester, 'datepicker-basic'), fmt(day15));
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('controlled lands via setState; the button demo is strict', (
    tester,
  ) async {
    await start(tester);
    await openPanel(tester, 'datepicker-controlled');
    await tapInPanel(
      tester,
      find.byKey(SemiDatePicker.dayKey(DateTime(2024, 1, 20))),
    );
    expect(find.byType(SemiTooltipPopup), findsNothing);
    expect(statusContaining('2024-01-20'), findsOneWidget);
    expect(
      tester.widget<SemiDatePicker>(keyed('datepicker-controlled')).value,
      DateTime(2024, 1, 20),
    );
    expect(inputText(tester, 'datepicker-controlled'), '2024-01-20');
    // 严格受控：点选只回调，显示不落地。
    await openPanel(tester, 'datepicker-controlled-button');
    await tapInPanel(
      tester,
      find.byKey(SemiDatePicker.dayKey(DateTime(2024, 2, 20))),
    );
    expect(statusContaining('严格：2024-02-20'), findsOneWidget);
    expect(inputText(tester, 'datepicker-controlled-button'), '2024-02-15');
    expect(
      tester
          .widget<SemiDatePicker>(keyed('datepicker-controlled-button'))
          .value,
      DateTime(2024, 2, 15),
    );
    // 按钮改值是唯一能改显示的通道。
    await tap(tester, keyed('datepicker-controlled-bump'));
    expect(
      tester
          .widget<SemiDatePicker>(keyed('datepicker-controlled-button'))
          .value,
      DateTime(2024, 3, 15),
    );
    expect(inputText(tester, 'datepicker-controlled-button'), '2024-03-15');
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'range keeps the panel for the start, resets on end-before-start, previews hover',
    (tester) async {
      await start(tester);
      final now = DateTime.now();
      final day5 = DateTime(now.year, now.month, 5);
      final day10 = DateTime(now.year, now.month, 10);
      final day20 = DateTime(now.year, now.month, 20);
      final day22 = DateTime(now.year, now.month, 22);
      final day25 = DateTime(now.year, now.month, 25);
      await openPanel(
        tester,
        'datepicker-range',
        at: rangeEdit('datepicker-range', 0),
      );
      expect(find.byType(SemiTooltipPopup), findsOneWidget);
      // 首点置 start：★面板常开、半选不发 onChanged。
      await tapInPanel(tester, find.byKey(SemiDatePicker.dayKey(day20)));
      expect(find.byType(SemiTooltipPopup), findsOneWidget);
      expect(rangeText(tester, 'datepicker-range', 0), fmt(day20));
      expect(rangeText(tester, 'datepicker-range', 1), '');
      expect(logContaining('onChanged'), findsNothing);
      // hover 区间预览：起点与 hover 之间的格子染 inhover 底色。
      Color? dayColor(DateTime d) =>
          (tester
                      .widget<Container>(
                        find.descendant(
                          of: find.byKey(SemiDatePicker.dayKey(d)),
                          matching: find.byType(Container),
                        ),
                      )
                      .decoration
                  as BoxDecoration?)
              ?.color;
      expect(dayColor(day22), isNull);
      final gesture = await mouse(tester);
      await gesture.moveTo(
        tester.getCenter(find.byKey(SemiDatePicker.dayKey(day25))),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));
      expect(dayColor(day22), isNotNull);
      await gesture.moveTo(Offset.zero);
      await tester.pump();
      // 第二点（更晚）→ 完整 [20, 25] 落地并关门。
      await tapInPanel(tester, find.byKey(SemiDatePicker.dayKey(day25)));
      expect(find.byType(SemiTooltipPopup), findsNothing);
      expect(statusContaining('${fmt(day20)} ~ ${fmt(day25)}'), findsOneWidget);
      // ★end 早于 start → 起点置空（该日成为 end）。从 end 输入重开面板：
      // start 输入本轮未聚焦过（focusRecords 重置），range-side linking 不禁
      // 越界日，早于起点的日子可点。
      await openPanel(
        tester,
        'datepicker-range',
        at: rangeEdit('datepicker-range', 1),
      );
      await tapInPanel(tester, find.byKey(SemiDatePicker.dayKey(day10)));
      expect(find.byType(SemiTooltipPopup), findsOneWidget);
      expect(rangeText(tester, 'datepicker-range', 0), '');
      expect(rangeText(tester, 'datepicker-range', 1), fmt(day10));
      // 半选不发 onChanged（状态仍是上一轮完整值）。
      expect(statusContaining('${fmt(day20)} ~ ${fmt(day25)}'), findsOneWidget);
      // 再选更早日期作起点 → 完整 [5, 10] 落地并关门。
      await tapInPanel(tester, find.byKey(SemiDatePicker.dayKey(day5)));
      expect(find.byType(SemiTooltipPopup), findsNothing);
      expect(statusContaining('${fmt(day5)} ~ ${fmt(day10)}'), findsOneWidget);
      expect(rangeText(tester, 'datepicker-range', 0), fmt(day5));
      expect(rangeText(tester, 'datepicker-range', 1), fmt(day10));
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('presets apply and close; the null preset ★clears and closes', (
    tester,
  ) async {
    await start(tester);
    await openPanel(tester, 'datepicker-presets');
    // left 面板带 presetHeader（页面章节标题同名，须限定在面板内）。
    expect(
      find.descendant(
        of: find.byType(SemiTooltipPopup),
        matching: find.text('快捷选择'),
      ),
      findsOneWidget,
    );
    expect(find.byKey(SemiDatePicker.presetKey(0)), findsOneWidget);
    expect(find.byKey(SemiDatePicker.presetKey(1)), findsOneWidget);
    expect(find.byKey(SemiDatePicker.presetKey(2)), findsOneWidget);
    await tapInPanel(tester, find.byKey(SemiDatePicker.presetKey(0)));
    expect(find.byType(SemiTooltipPopup), findsNothing);
    expect(statusContaining(fmt(DateTime.now())), findsOneWidget);
    expect(logContaining('onPresetClick 今天'), findsOneWidget);
    // ★「清空」预设（start/end 皆空）：onChanged(null, '') + 关面板。
    await openPanel(tester, 'datepicker-presets');
    await tapInPanel(tester, find.byKey(SemiDatePicker.presetKey(2)));
    expect(find.byType(SemiTooltipPopup), findsNothing);
    expect(logContaining('onChanged null'), findsOneWidget);
    expect(logContaining('onPresetClick 清空'), findsOneWidget);
    expect(inputText(tester, 'datepicker-presets'), '');
    expect(tester.takeException(), isNull);
  });

  testWidgets('disabledDate days are not clickable; range links the sides', (
    tester,
  ) async {
    await start(tester);
    final now = DateTime.now();
    final day10 = DateTime(now.year, now.month, 10);
    final day15 = DateTime(now.year, now.month, 15);
    final day16 = DateTime(now.year, now.month, 16);
    final day20 = DateTime(now.year, now.month, 20);
    await openPanel(tester, 'datepicker-disabled');
    // 禁用日点击无效：面板不动、不发 onChanged。
    await tapInPanel(tester, find.byKey(SemiDatePicker.dayKey(day15)));
    expect(find.byType(SemiTooltipPopup), findsOneWidget);
    expect(logContaining('onChanged'), findsNothing);
    await tapInPanel(tester, find.byKey(SemiDatePicker.dayKey(day16)));
    expect(find.byType(SemiTooltipPopup), findsNothing);
    expect(statusContaining(fmt(day16)), findsOneWidget);
    // 动态禁用（options.rangeStart）：起点选定后更早的日期不可选。
    await openPanel(
      tester,
      'datepicker-disabled-range',
      at: rangeEdit('datepicker-disabled-range', 0),
    );
    await tapInPanel(tester, find.byKey(SemiDatePicker.dayKey(day20)));
    expect(rangeText(tester, 'datepicker-disabled-range', 0), fmt(day20));
    await tapInPanel(tester, find.byKey(SemiDatePicker.dayKey(day10)));
    expect(find.byType(SemiTooltipPopup), findsOneWidget);
    expect(rangeText(tester, 'datepicker-disabled-range', 0), fmt(day20));
    expect(rangeText(tester, 'datepicker-disabled-range', 1), '');
    expect(tester.takeException(), isNull);
  });

  testWidgets('autoSwitchDate clamps to month end and ★keeps the panel', (
    tester,
  ) async {
    await start(tester);
    final day31 = DateTime(2024, 1, 31);
    await openPanel(tester, 'datepicker-auto-switch');
    expect(find.text('2024年 1月'), findsOneWidget);
    await tapInPanel(tester, find.byKey(SemiDatePicker.dayKey(day31)));
    expect(find.byType(SemiTooltipPopup), findsNothing);
    await openPanel(tester, 'datepicker-auto-switch');
    expect(find.text('2024年 1月'), findsOneWidget);
    await tapInPanel(tester, find.byKey(SemiDatePicker.navNextMonthKey));
    // ★01-31 → 02-29（月末钳制），且不关面板。
    expect(find.text('2024年 2月'), findsOneWidget);
    expect(find.byType(SemiTooltipPopup), findsOneWidget);
    expect(statusContaining('2024-02-29'), findsOneWidget);
    expect(logContaining('onPanelChange'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('weekStartsOn rotates the weekday labels to Monday-first', (
    tester,
  ) async {
    await start(tester);
    expect(
      tester
          .widget<SemiDatePicker>(keyed('datepicker-week-start'))
          .weekStartsOn,
      1,
    );
    await openPanel(tester, 'datepicker-week-start');
    double? previous;
    for (final label in ['一', '二', '三', '四', '五', '六', '日']) {
      final x = tester.getCenter(find.text(label).first).dx;
      if (previous != null) {
        expect(x, greaterThan(previous), reason: '「$label」应排在前一标签右侧');
      }
      previous = x;
    }
    expect(tester.takeException(), isNull);
  });

  testWidgets('clear button shows on hover and clears with events logged', (
    tester,
  ) async {
    await start(tester);
    await tester.ensureVisible(keyed('datepicker-basic'));
    await tester.pump(const Duration(milliseconds: 50));
    await tester.enterText(editable('datepicker-basic'), '2026-01-01');
    await tester.pump();
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
    FocusManager.instance.primaryFocus?.unfocus();
    await tester.pump();
    final clear = find.descendant(
      of: keyed('datepicker-basic'),
      matching: find.byKey(SemiInput.clearButtonKey),
    );
    // 不悬浮、不聚焦：清空钮隐藏。
    expect(clear, findsNothing);
    await warmup(tester);
    final gesture = await mouse(tester);
    await gesture.moveTo(tester.getCenter(keyed('datepicker-basic')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
    expect(clear, findsOneWidget);
    await tap(tester, clear);
    expect(inputText(tester, 'datepicker-basic'), '');
    expect(logContaining('onChanged null'), findsOneWidget);
    expect(logContaining('onClear'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('controller open() shows the panel', (tester) async {
    await start(tester);
    await tap(tester, keyed('datepicker-controller-open'));
    await settlePanel(tester);
    expect(find.byType(SemiTooltipPopup), findsOneWidget);
    expect(logContaining('onOpenChange true'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('month pick ★stays open; format/separator/sizes render', (
    tester,
  ) async {
    await start(tester);
    expect(
      tester.widget<SemiDatePicker>(keyed('datepicker-format')).format,
      'yyyy年MM月dd日',
    );
    expect(inputText(tester, 'datepicker-format'), '2024年01月15日');
    expect(
      tester
          .widget<SemiDatePicker>(keyed('datepicker-separator'))
          .rangeSeparator,
      '至',
    );
    expect(
      tester.widget<SemiDatePicker>(keyed('datepicker-sizes-small')).size,
      SemiInputSize.small,
    );
    expect(
      tester.widget<SemiDatePicker>(keyed('datepicker-sizes-normal')).size,
      SemiInputSize.normal,
    );
    expect(
      tester.widget<SemiDatePicker>(keyed('datepicker-sizes-large')).size,
      SemiInputSize.large,
    );
    expect(
      tester
          .widget<SemiDatePicker>(keyed('datepicker-sizes-warning'))
          .validateStatus,
      SemiInputStatus.warning,
    );
    expect(
      tester
          .widget<SemiDatePicker>(keyed('datepicker-sizes-error'))
          .validateStatus,
      SemiInputStatus.error,
    );
    expect(
      tester
          .widget<SemiDatePicker>(keyed('datepicker-sizes-borderless'))
          .borderless,
      isTrue,
    );
    expect(
      tester
          .widget<SemiDatePicker>(keyed('datepicker-sizes-readonly'))
          .inputReadOnly,
      isTrue,
    );
    // type=month：点选年月后 ★面板不关（上游 close 块只覆盖 date/dateRange）。
    await openPanel(tester, 'datepicker-month');
    await tapInPanel(tester, find.text('3月'));
    expect(find.byType(SemiTooltipPopup), findsOneWidget);
    expect(statusContaining('${DateTime.now().year}-03'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
