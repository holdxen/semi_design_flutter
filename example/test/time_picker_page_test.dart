import 'package:example/pages/time_picker.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:semi_design_flutter/semi_design_flutter.dart';

Finder keyed(String key) => find.byKey(ValueKey(key));

Finder input(String key) => find.descendant(
  of: keyed(key),
  matching: find.byKey(SemiTimePicker.inputKey),
);

Finder editOf(String key) =>
    find.descendant(of: input(key), matching: find.byType(EditableText));

Finder clearButton(String key) => find.descendant(
  of: input(key),
  matching: find.byKey(SemiTimePicker.clearButtonKey),
);

String inputText(WidgetTester tester, String key) =>
    tester.widget<EditableText>(editOf(key)).controller.text;

bool inputFocused(WidgetTester tester, String key) =>
    tester.widget<EditableText>(editOf(key)).focusNode.hasFocus;

Finder statusContaining(String text) => find.descendant(
  of: keyed('timepicker-status'),
  matching: find.textContaining(text),
);

Finder hourOptions() => find.byKey(SemiTimePicker.hourListKey);

Finder option(Finder list, String label) =>
    find.descendant(of: list, matching: find.text(label));

Future<void> start(WidgetTester tester) async {
  addTearDown(() async => tester.pumpWidget(const SizedBox.shrink()));
  await tester.pumpWidget(const SemiApp(home: TimePickerPage()));
  await tester.pump(const Duration(milliseconds: 50));
}

/// Panel bodies mount/unmount a few frames after `visible` flips (the tooltip
/// overlay's entrance/hide animation) — pump through before asserting.
Future<void> settlePanel(WidgetTester tester) async {
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 150));
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 150));
  await tester.pump();
}

bool panelOpen() => find.byKey(SemiTimePicker.panelKey).evaluate().isNotEmpty;

/// Tap [finder] until [done] holds. The one-shot retry absorbs the dropped hit
/// of docs/known_issues.md #1 without double-firing non-idempotent actions:
/// [done] is checked after each tap. Outside taps cannot be dropped (the
/// tooltip's outside check observes raw pointers), so close/blur settle on the
/// first try; open/focus/type actions get the retry.
Future<void> tapUntil(
  WidgetTester tester,
  Finder finder,
  bool Function() done,
) async {
  for (var i = 0; i < 2; i++) {
    await tester.ensureVisible(finder);
    await tester.pump(const Duration(milliseconds: 50));
    await tester.tap(finder, warnIfMissed: false);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
    await tester.pump();
    await settlePanel(tester);
    if (done()) return;
  }
}

/// Open the panel of the demo named by [key] (tap the trigger until the panel
/// mounts).
Future<void> openPicker(WidgetTester tester, String key, {Finder? at}) async {
  await tapUntil(tester, at ?? keyed(key), panelOpen);
}

/// Tap an option row inside the open panel. The first tap doubles as the
/// sacrificial hit for docs/known_issues.md #1: if it lands, the second tap
/// re-selects the same option — a no-op (`_hasChanged` compares formatted
/// strings, semi_time_picker.dart) — so exactly one selection fires either way.
Future<void> tapOption(WidgetTester tester, Finder finder) async {
  await tester.tap(finder, warnIfMissed: false);
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 100));
  await tester.pump();
  await tester.tap(finder);
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 100));
  await tester.pump();
  await settlePanel(tester);
}

/// Close the open panel with an outside tap (the tooltip's outside check is
/// rect containment and observes raw pointers — it cannot be dropped).
Future<void> closePanel(WidgetTester tester) async {
  await tester.tapAt(const Offset(4, 4));
  await tester.pump();
  await settlePanel(tester);
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
      '基础用法',
      'format 格式',
      '12 小时制',
      '步长',
      '禁用时间',
      '受控',
      '时间范围',
      '面板插槽',
      '自定义触发器与 controller',
      '输入形态',
    ]) {
      expect(find.text(title), findsOneWidget);
      await tester.ensureVisible(find.text(title));
      await tester.pump(const Duration(milliseconds: 100));
      expect(tester.takeException(), isNull);
    }
    expect(
      find.byKey(const ValueKey('timepicker-unsupported-note')),
      findsOneWidget,
    );
  });

  testWidgets(
    'basic opens the panel, selects an hour and closes on outside tap',
    (tester) async {
      await start(tester);
      expect(inputText(tester, 'timepicker-basic'), '09:30:00');
      await openPicker(tester, 'timepicker-basic');
      expect(panelOpen(), isTrue);
      expect(statusContaining('onOpenChange true'), findsOneWidget);
      // 时列选 10 时 → 输入改写 10:30:00，onChanged 落日志（date-first）。
      await tapOption(tester, option(hourOptions(), '10时'));
      expect(inputText(tester, 'timepicker-basic'), '10:30:00');
      expect(statusContaining('onChanged'), findsOneWidget);
      expect(statusContaining('10:30:00'), findsOneWidget);
      // 外点关闭（Listener 原始指针判定，不惧 dropped hit）。
      await closePanel(tester);
      expect(panelOpen(), isFalse);
      expect(statusContaining('onOpenChange false'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('format drives which columns the panel shows', (tester) async {
    await start(tester);
    // 'HH' — 仅时列。
    await openPicker(tester, 'timepicker-format-h');
    expect(inputText(tester, 'timepicker-format-h'), '09');
    expect(hourOptions(), findsOneWidget);
    expect(find.byKey(SemiTimePicker.minuteListKey), findsNothing);
    expect(find.byKey(SemiTimePicker.secondListKey), findsNothing);
    await closePanel(tester);
    // 'HH:mm' — 无秒列。
    await openPicker(tester, 'timepicker-format-hm');
    expect(inputText(tester, 'timepicker-format-hm'), '09:30');
    expect(hourOptions(), findsOneWidget);
    expect(find.byKey(SemiTimePicker.minuteListKey), findsOneWidget);
    expect(find.byKey(SemiTimePicker.secondListKey), findsNothing);
    await closePanel(tester);
    // 'mm:ss' — 无时列。
    await openPicker(tester, 'timepicker-format-ms');
    expect(inputText(tester, 'timepicker-format-ms'), '30:00');
    expect(hourOptions(), findsNothing);
    expect(find.byKey(SemiTimePicker.minuteListKey), findsOneWidget);
    expect(find.byKey(SemiTimePicker.secondListKey), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('use12Hours shows the AM/PM column and PM converts the hour', (
    tester,
  ) async {
    await start(tester);
    await openPicker(tester, 'timepicker-12h');
    expect(find.byKey(SemiTimePicker.ampmListKey), findsOneWidget);
    // 小时列 [12, 01..11]——无 00 时。
    expect(option(hourOptions(), '12时'), findsOneWidget);
    expect(option(hourOptions(), '00时'), findsNothing);
    expect(
      find.descendant(of: hourOptions(), matching: find.textContaining('时')),
      findsNWidgets(12),
    );
    expect(inputText(tester, 'timepicker-12h'), '上午 9:30:00');
    // 点 PM（下午）：AM 的 9 时 → 21 时（Combobox ±12 换算）。
    await tapOption(
      tester,
      option(find.byKey(SemiTimePicker.ampmListKey), '下午'),
    );
    expect(inputText(tester, 'timepicker-12h'), '下午 9:30:00');
    expect(statusContaining('21:30:00'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('step props generate sparse option grids', (tester) async {
    await start(tester);
    await openPicker(tester, 'timepicker-steps');
    expect(
      find.descendant(of: hourOptions(), matching: find.textContaining('时')),
      findsNWidgets(12),
    );
    expect(option(hourOptions(), '00时'), findsOneWidget);
    expect(option(hourOptions(), '02时'), findsOneWidget);
    expect(option(hourOptions(), '01时'), findsNothing);
    expect(
      find.descendant(
        of: find.byKey(SemiTimePicker.minuteListKey),
        matching: find.textContaining('分'),
      ),
      findsNWidgets(4),
    );
    expect(
      option(find.byKey(SemiTimePicker.minuteListKey), '45分'),
      findsOneWidget,
    );
    expect(
      find.descendant(
        of: find.byKey(SemiTimePicker.secondListKey),
        matching: find.textContaining('秒'),
      ),
      findsNWidgets(2),
    );
    expect(
      option(find.byKey(SemiTimePicker.secondListKey), '30秒'),
      findsOneWidget,
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('disabled options are inert; hideDisabledOptions removes them', (
    tester,
  ) async {
    await start(tester);
    await openPicker(tester, 'timepicker-disabled');
    final disabledHour = option(hourOptions(), '10时');
    expect(disabledHour, findsOneWidget);
    final before = inputText(tester, 'timepicker-disabled');
    await tapOption(tester, disabledHour);
    // 禁用项不可点：输入与日志均不变。
    expect(inputText(tester, 'timepicker-disabled'), before);
    expect(statusContaining('onChanged'), findsNothing);
    await closePanel(tester);
    // hideDisabledOptions：禁用项从列移除。
    await openPicker(tester, 'timepicker-disabled-hide');
    expect(option(hourOptions(), '10时'), findsNothing);
    expect(option(hourOptions(), '07时'), findsNothing);
    expect(
      find.descendant(of: hourOptions(), matching: find.textContaining('时')),
      findsNWidgets(20),
    );
    expect(
      option(find.byKey(SemiTimePicker.minuteListKey), '00分'),
      findsNothing,
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'controlled value follows the button; controlled open drives the panel',
    (tester) async {
      await start(tester);
      // 严格受控值：显示只跟按钮改的值。
      expect(inputText(tester, 'timepicker-controlled'), '08:00:00');
      await tapUntil(
        tester,
        keyed('timepicker-controlled-bump'),
        () => inputText(tester, 'timepicker-controlled') == '20:00:00',
      );
      expect(inputText(tester, 'timepicker-controlled'), '20:00:00');
      expect(
        tester.widget<SemiTimePicker>(keyed('timepicker-controlled')).value,
        DateTime(2024, 1, 1, 20, 0),
      );
      // 受控 open：按钮开/关面板。
      await tapUntil(
        tester,
        keyed('timepicker-controlled-open-toggle'),
        panelOpen,
      );
      expect(panelOpen(), isTrue);
      await tapUntil(
        tester,
        keyed('timepicker-controlled-open-toggle'),
        () => !panelOpen(),
      );
      expect(panelOpen(), isFalse);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'range shows two panels, custom separator and per-side disabledTime',
    (tester) async {
      await start(tester);
      expect(inputText(tester, 'timepicker-range'), '09:30:00 ~ 18:00:00');
      expect(inputText(tester, 'timepicker-range-sep'), '09:30:00 至 18:00:00');
      // 双面板：列各两组，缺省头 开始时间/结束时间。
      await openPicker(tester, 'timepicker-range');
      expect(find.byKey(SemiTimePicker.panelKey), findsOneWidget);
      expect(hourOptions(), findsNWidgets(2));
      expect(find.byKey(SemiTimePicker.minuteListKey), findsNWidgets(2));
      expect(find.byKey(SemiTimePicker.secondListKey), findsNWidgets(2));
      expect(find.text('开始时间'), findsOneWidget);
      expect(find.text('结束时间'), findsOneWidget);
      await closePanel(tester);
      // disabledTime 左右差异：左面板 10 时禁用（不可点），右面板 10 时可选。
      await openPicker(tester, 'timepicker-range-disabled');
      expect(
        inputText(tester, 'timepicker-range-disabled'),
        '09:30:00 ~ 11:00:00',
      );
      final leftHour = option(hourOptions().at(0), '10时');
      final rightHour = option(hourOptions().at(1), '10时');
      expect(leftHour, findsOneWidget);
      expect(rightHour, findsOneWidget);
      await tapOption(tester, leftHour);
      expect(
        inputText(tester, 'timepicker-range-disabled'),
        '09:30:00 ~ 11:00:00',
      );
      expect(statusContaining('onChanged'), findsNothing);
      await tapOption(tester, rightHour);
      expect(
        inputText(tester, 'timepicker-range-disabled'),
        '09:30:00 ~ 10:00:00',
      );
      expect(statusContaining('10:00:00'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('controller open/close/focus/blur drive the picker', (
    tester,
  ) async {
    await start(tester);
    await tapUntil(tester, keyed('timepicker-controller-open'), panelOpen);
    expect(panelOpen(), isTrue);
    await tapUntil(
      tester,
      keyed('timepicker-controller-close'),
      () => !panelOpen(),
    );
    expect(panelOpen(), isFalse);
    await tapUntil(
      tester,
      keyed('timepicker-controller-focus'),
      () => inputFocused(tester, 'timepicker-controller'),
    );
    expect(inputFocused(tester, 'timepicker-controller'), isTrue);
    await tapUntil(
      tester,
      keyed('timepicker-controller-blur'),
      () => !inputFocused(tester, 'timepicker-controller'),
    );
    expect(inputFocused(tester, 'timepicker-controller'), isFalse);
    expect(tester.takeException(), isNull);
  });

  testWidgets('clearText clear button empties the input', (tester) async {
    await start(tester);
    // showClear=false：无清空按钮。
    expect(clearButton('timepicker-clear-off'), findsNothing);
    // clearText='清空'：清空按钮带 tooltip 语义，点后输入置空（(null, '')）。
    await tapUntil(
      tester,
      editOf('timepicker-clear-text'),
      () => inputFocused(tester, 'timepicker-clear-text') || panelOpen(),
    );
    expect(clearButton('timepicker-clear-text'), findsOneWidget);
    await tapUntil(
      tester,
      clearButton('timepicker-clear-text'),
      () => inputText(tester, 'timepicker-clear-text').isEmpty,
    );
    expect(inputText(tester, 'timepicker-clear-text'), '');
    expect(statusContaining('onChanged'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('custom trigger child opens the panel; panel slots render', (
    tester,
  ) async {
    await start(tester);
    // child 自定义触发器：点按钮开面板。
    await tapUntil(tester, keyed('timepicker-custom-trigger-btn'), panelOpen);
    expect(panelOpen(), isTrue);
    await closePanel(tester);
    // panelHeader / panelFooter 挂在面板上下。
    await openPicker(tester, 'timepicker-slots');
    expect(find.text('Panel Header'), findsOneWidget);
    expect(find.text('Panel Footer'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('input form demos render sizes and misc states', (tester) async {
    await start(tester);
    // size 三档递增。
    double heightOf(String key) => tester.getRect(input(key)).height;
    expect(
      heightOf('timepicker-sizes-small'),
      lessThan(heightOf('timepicker-sizes-normal')),
    );
    expect(
      heightOf('timepicker-sizes-normal'),
      lessThan(heightOf('timepicker-sizes-large')),
    );
    // placeholder / insetLabel 文案。
    expect(
      find.descendant(
        of: keyed('timepicker-misc-placeholder'),
        matching: find.text('自定义文案'),
      ),
      findsOneWidget,
    );
    expect(
      find.descendant(
        of: keyed('timepicker-misc-borderless'),
        matching: find.text('时间'),
      ),
      findsOneWidget,
    );
    // disabled 不开面板。
    await tapUntil(
      tester,
      keyed('timepicker-misc-disabled'),
      () => inputText(tester, 'timepicker-misc-disabled') == '09:30:00',
    );
    expect(panelOpen(), isFalse);
    // validateStatus 透传。
    expect(
      tester
          .widget<SemiTimePicker>(keyed('timepicker-misc-error'))
          .validateStatus,
      SemiInputStatus.error,
    );
    expect(tester.takeException(), isNull);
  });
}
