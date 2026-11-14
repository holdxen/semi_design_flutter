import 'package:example/pages/color_picker.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:semi_design_flutter/semi_design_flutter.dart';

Finder keyed(String key) => find.byKey(ValueKey(key));

Finder sv(String key) => find.descendant(
  of: keyed(key),
  matching: find.byKey(SemiColorPicker.svAreaKey),
);

Finder hue(String key) => find.descendant(
  of: keyed(key),
  matching: find.byKey(SemiColorPicker.hueSliderKey),
);

Finder alphaBar(String key) => find.descendant(
  of: keyed(key),
  matching: find.byKey(SemiColorPicker.alphaSliderKey),
);

Finder colorInput(String key) => find.descendant(
  of: keyed(key),
  matching: find.byKey(SemiColorPicker.colorInputKey),
);

Finder alphaInput(String key) => find.descendant(
  of: keyed(key),
  matching: find.byKey(SemiColorPicker.alphaInputKey),
);

Finder formatSelect(String key) => find.descendant(
  of: keyed(key),
  matching: find.byKey(SemiColorPicker.formatSelectKey),
);

Finder eyeButton(String key) => find.descendant(
  of: keyed(key),
  matching: find.byKey(SemiColorPicker.eyeDropperButtonKey),
);

Finder triggerSwatch(String key) => find.descendant(
  of: keyed(key),
  matching: find.byKey(SemiColorPicker.triggerSwatchKey),
);

/// The panel of an open usePopover picker lives in the tooltip overlay.
Finder popupSv() => find.descendant(
  of: find.byType(SemiTooltipPopup),
  matching: find.byKey(SemiColorPicker.svAreaKey),
);

Finder editOf(Finder field) =>
    find.descendant(of: field, matching: find.byType(EditableText));

String fieldText(WidgetTester tester, Finder field) =>
    tester.widget<EditableText>(editOf(field)).controller.text;

String statusText(WidgetTester tester) =>
    tester.widget<SemiText>(keyed('colorpicker-status')).data;

String logText(WidgetTester tester) =>
    tester.widget<SemiText>(keyed('colorpicker-events-log')).data;

Finder statusContaining(String text) => find.descendant(
  of: keyed('colorpicker-status'),
  matching: find.textContaining(text),
);

Finder logContaining(String text) => find.descendant(
  of: keyed('colorpicker-events-log'),
  matching: find.textContaining(text),
);

/// The default brand seed (docs/semi_color_picker.md): `#39c5bb` rounds to
/// h=176 s=71 v=77 — its computed hex is ★`#39c4bb` (RGB↔HSV int round-trip).
const brand = SemiColorValue(h: 176, s: 71, v: 77);

Future<void> start(WidgetTester tester) async {
  addTearDown(() async => tester.pumpWidget(const SizedBox.shrink()));
  await tester.pumpWidget(const SemiApp(home: ColorPickerPage()));
  await tester.pump(const Duration(milliseconds: 50));
}

/// Absorb the one dropped hit test (docs/known_issues.md #1) at a neutral
/// spot: (4, 4) sits in the page padding, away from every control.
Future<void> warmup(WidgetTester tester) async {
  await tester.tapAt(const Offset(4, 4));
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

Future<TestGesture> mouse(WidgetTester tester) async {
  final gesture = await tester.createGesture(kind: PointerDeviceKind.mouse);
  await gesture.addPointer(location: Offset.zero);
  addTearDown(gesture.removePointer);
  return gesture;
}

/// Hover-driven popover bodies mount a few frames after `visible` flips.
Future<void> settlePopup(WidgetTester tester) async {
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 150));
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 150));
  await tester.pump();
}

/// Press [target] at the lazily computed global [at] with [gesture]
/// (slider_page_test style); the press itself relocates the handle (upstream
/// mousedown). [at] runs AFTER `ensureVisible` so the geometry is fresh. One
/// mouse gesture per test (a second `addPointer` trips MouseTracker).
Future<void> press(
  WidgetTester tester,
  TestGesture gesture,
  Finder target,
  Offset Function() at,
) async {
  await tester.ensureVisible(target);
  await tester.pump(const Duration(milliseconds: 50));
  await warmup(tester);
  final point = at();
  await gesture.moveTo(point);
  await gesture.down(point);
  await tester.pump();
}

/// Open the data-part format Select of the demo named by [key]. The popup
/// parks offscreen (follower offset (0, -1000)) until its first positioning
/// post-frame — pump past it before tapping options.
Future<void> openFormatSelect(WidgetTester tester, String key) async {
  final select = formatSelect(key);
  await tester.ensureVisible(select);
  await tester.pump(const Duration(milliseconds: 50));
  await warmup(tester);
  await tester.tap(select);
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 100));
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 100));
  await tester.pump();
}

/// Tap a format option row inside the open select popup (no outside warmup —
/// an outside tap would close the panel, select_page_test precedent).
Future<void> tapOption(WidgetTester tester, String label) async {
  await tester.tap(
    find.descendant(
      of: find.byType(SemiTooltipPopup),
      matching: find.text(label),
    ),
  );
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 100));
  await tester.pump();
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
      '滴管取色器',
      '默认值',
      '受控',
      '顶部和底部渲染额外元素',
      '透明度 alpha',
      '格式切换（defaultFormat）',
      '自定义尺寸',
      '事件回调',
      '颜色转换方法',
    ]) {
      expect(find.text(title), findsOneWidget);
      await tester.ensureVisible(find.text(title));
      await tester.pump(const Duration(milliseconds: 100));
      expect(tester.takeException(), isNull);
    }
  });

  testWidgets(
    'basic hue clamps to 360 past the right edge; SV lands s/v and ★rejects out-of-bounds',
    (tester) async {
      await start(tester);
      final gesture = await mouse(tester);
      // 色相条：按下中心 h=180，拖过右缘 ★钳制 360（不回卷 0）。
      await press(
        tester,
        gesture,
        hue('colorpicker-basic'),
        () => tester.getCenter(hue('colorpicker-basic')),
      );
      expect(statusContaining('h=180'), findsOneWidget);
      await gesture.moveTo(
        Offset(
          tester.getRect(hue('colorpicker-basic')).right + 20,
          tester.getCenter(hue('colorpicker-basic')).dy,
        ),
      );
      await tester.pump();
      expect(statusContaining('h=360'), findsOneWidget);
      await gesture.up();
      await tester.pump();
      // SV 面板：按下 (25%, 75%) → s=25 v=25（h 继承 360）。
      await press(tester, gesture, sv('colorpicker-basic'), () {
        final r = tester.getRect(sv('colorpicker-basic'));
        return Offset(r.left + 70, r.top + 210);
      });
      expect(statusContaining('h=360 s=25 v=25'), findsOneWidget);
      // ★越界拒收：拖出面板，值与事件均不变（不 clamp）。
      final statusBefore = statusText(tester);
      final logBefore = logText(tester);
      final out = tester.getRect(sv('colorpicker-basic'));
      await gesture.moveTo(Offset(out.left - 60, out.top - 60));
      await tester.pump();
      expect(statusText(tester), statusBefore);
      expect(logText(tester), logBefore);
      await gesture.up();
      await tester.pump();
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('alpha bar rounds a to ★2 decimals; hex grows to 8 digits', (
    tester,
  ) async {
    await start(tester);
    final gesture = await mouse(tester);
    // 拖到 33.9% 处 → a = clamp(frac).toFixed(2) = 0.34。
    await press(tester, gesture, alphaBar('colorpicker-alpha'), () {
      final r = tester.getRect(alphaBar('colorpicker-alpha'));
      return Offset(r.left + r.width * 0.339, r.center.dy);
    });
    expect(statusContaining('a=0.34'), findsOneWidget);
    const expected = SemiColorValue(h: 176, s: 71, v: 77, a: 0.34);
    expect(expected.hex.length, 9);
    expect(statusContaining(expected.hex), findsOneWidget);
    // % 栏显示 round(a×100) = 34。
    expect(fieldText(tester, alphaInput('colorpicker-alpha')), '34');
    await gesture.up();
    await tester.pump();
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'alpha=false hides the bar and ★forces a=1 / 6-digit hex on every commit',
    (tester) async {
      await start(tester);
      // 透明度滑条与 % 输入不渲染（bar hidden — 无 alpha-bar 可拖）。
      expect(alphaBar('colorpicker-alpha-off'), findsNothing);
      expect(alphaInput('colorpicker-alpha-off'), findsNothing);
      // 带 alpha 的 rgba 输入提交 → ★提交级归一强制 a=1、hex 6 位。
      await tester.ensureVisible(editOf(colorInput('colorpicker-alpha-off')));
      await tester.pump(const Duration(milliseconds: 50));
      await tester.enterText(
        editOf(colorInput('colorpicker-alpha-off')),
        '255,0,0,0.5',
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));
      expect(statusContaining('a=1.00'), findsOneWidget);
      const opaque = SemiColorValue(h: 0, s: 100, v: 100);
      expect(opaque.hex, '#ff0000');
      expect(statusContaining(opaque.hex), findsOneWidget);
      expect(fieldText(tester, colorInput('colorpicker-alpha-off')), '255,0,0');
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'format select switches display/parsing; ★invalid text is kept, bare hex gains #',
    (tester) async {
      await start(tester);
      expect(fieldText(tester, colorInput('colorpicker-format')), brand.hex);
      // 切到 rgba：文本恒去 alpha，显示 r,g,b。
      await openFormatSelect(tester, 'colorpicker-format');
      expect(find.byType(SemiTooltipPopup), findsOneWidget);
      await tapOption(tester, 'rgba');
      expect(
        fieldText(tester, colorInput('colorpicker-format')),
        '${brand.r},${brand.g},${brand.b}',
      );
      // ★非法逗号三元组（r 越界）：不发 onChanged、原文保留。
      final statusBefore = statusText(tester);
      final logBefore = logText(tester);
      await tester.enterText(
        editOf(colorInput('colorpicker-format')),
        '300,0,0',
      );
      await tester.pump();
      expect(fieldText(tester, colorInput('colorpicker-format')), '300,0,0');
      expect(statusText(tester), statusBefore);
      expect(logText(tester), logBefore);
      // 切回 hex：文本从值重同步（★3 位简写拒绝后此处是规范形）。
      await openFormatSelect(tester, 'colorpicker-format');
      await tapOption(tester, 'hex');
      expect(fieldText(tester, colorInput('colorpicker-format')), brand.hex);
      // ★hex 自动补 #：ff0000 被接受并落地。
      await tester.enterText(
        editOf(colorInput('colorpicker-format')),
        'ff0000',
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));
      const red = SemiColorValue(h: 0, s: 100, v: 100);
      expect(statusContaining(red.hex), findsOneWidget);
      expect(fieldText(tester, colorInput('colorpicker-format')), red.hex);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('controlled lands via setState; the button demo is strict', (
    tester,
  ) async {
    await start(tester);
    final gesture = await mouse(tester);
    await press(
      tester,
      gesture,
      sv('colorpicker-controlled'),
      () => tester.getCenter(sv('colorpicker-controlled')),
    );
    await gesture.up();
    await tester.pump();
    const expected = SemiColorValue(h: 176, s: 50, v: 50);
    expect(
      tester.widget<SemiColorPicker>(keyed('colorpicker-controlled')).value,
      expected,
    );
    expect(statusContaining(expected.hex), findsOneWidget);
    // 严格受控：拖拽只回调，显示不落地。
    const buttonA = SemiColorValue(h: 120, s: 80, v: 60);
    const buttonB = SemiColorValue(h: 300, s: 60, v: 40);
    expect(
      tester
          .widget<SemiColorPicker>(keyed('colorpicker-controlled-button'))
          .value,
      buttonA,
    );
    await press(
      tester,
      gesture,
      sv('colorpicker-controlled-button'),
      () => tester.getCenter(sv('colorpicker-controlled-button')),
    );
    await gesture.up();
    await tester.pump();
    expect(statusContaining('严格'), findsOneWidget);
    expect(
      tester
          .widget<SemiColorPicker>(keyed('colorpicker-controlled-button'))
          .value,
      buttonA,
    );
    expect(
      fieldText(tester, colorInput('colorpicker-controlled-button')),
      buttonA.hex.substring(0, 7),
    );
    // 按钮改值是唯一能改显示的通道。
    await tap(tester, keyed('colorpicker-controlled-bump'));
    expect(
      tester
          .widget<SemiColorPicker>(keyed('colorpicker-controlled-button'))
          .value,
      buttonB,
    );
    expect(
      fieldText(tester, colorInput('colorpicker-controlled-button')),
      buttonB.hex.substring(0, 7),
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('usePopover hover opens the panel for default and custom child', (
    tester,
  ) async {
    await start(tester);
    expect(popupSv(), findsNothing);
    await tester.ensureVisible(keyed('colorpicker-popover'));
    await tester.pump(const Duration(milliseconds: 50));
    await warmup(tester);
    final gesture = await mouse(tester);
    // 默认 24×24 色块触发器：hover 开弹层。
    await gesture.moveTo(
      tester.getCenter(triggerSwatch('colorpicker-popover')),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 60));
    await settlePopup(tester);
    expect(popupSv(), findsOneWidget);
    expect(logContaining('onOpenChange true'), findsOneWidget);
    // 移出触发器：弹层关闭。
    await gesture.moveTo(Offset.zero);
    await tester.pump();
    await settlePopup(tester);
    expect(popupSv(), findsNothing);
    // 自定义 child 触发器同样 hover 打开。
    await tester.ensureVisible(keyed('colorpicker-popover-custom'));
    await tester.pump(const Duration(milliseconds: 50));
    await gesture.moveTo(
      tester.getCenter(keyed('colorpicker-popover-custom-trigger')),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 60));
    await settlePopup(tester);
    expect(popupSv(), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('eyedropper button hides without the bridge; rgba result ★a=1', (
    tester,
  ) async {
    await start(tester);
    // 无 onEyeDropper：取色按钮不渲染（上游 window.EyeDropper 门的移植）。
    expect(eyeButton('colorpicker-eyedropper-hidden'), findsNothing);
    // 宿主桥返回 rgba(255, 0, 0, 0.5) → ★强制 a=1、hex 6 位。
    await tap(tester, eyeButton('colorpicker-eyedropper'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));
    await tester.pump();
    expect(logContaining('onEyeDropper rgba(255, 0, 0, 0.5)'), findsOneWidget);
    const opaque = SemiColorValue(h: 0, s: 100, v: 100);
    expect(opaque.hex, '#ff0000');
    expect(statusContaining(opaque.hex), findsOneWidget);
    expect(statusContaining('a=1.00'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('topSlot and bottomSlot render around the controls', (
    tester,
  ) async {
    await start(tester);
    final slots = keyed('colorpicker-slots');
    expect(
      find.descendant(of: slots, matching: find.text('TopSlot')),
      findsOneWidget,
    );
    expect(
      find.descendant(of: slots, matching: find.text('Bottom Slot')),
      findsOneWidget,
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('default brand value seeds #39c5bb; convert demos parse', (
    tester,
  ) async {
    await start(tester);
    // 初始状态行即标注品牌色种子（★计算 hex #39c4bb）。
    expect(statusContaining('#39c5bb'), findsOneWidget);
    // 官方「默认值」demo：parse('rgb(57,197,187)') 种子，输入框显示
    // 恒去 alpha 的 hex（★取整回程 #39c4bb）。
    expect(
      fieldText(tester, colorInput('colorpicker-default-value')),
      '#39c4bb',
    );
    // 转换方法（SemiColorValue.parse / tryParse）在标签里演示。
    final convert = keyed('colorpicker-convert');
    expect(
      find.descendant(
        of: convert,
        matching: find.textContaining("parse('#39c5bb')"),
      ),
      findsOneWidget,
    );
    expect(
      find.descendant(of: convert, matching: find.textContaining('#39c4bb')),
      findsWidgets,
    );
    expect(
      find.descendant(
        of: convert,
        matching: find.textContaining("tryParse('green')"),
      ),
      findsOneWidget,
    );
    expect(
      find.descendant(of: convert, matching: find.textContaining('null')),
      findsOneWidget,
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('custom size demo renders a 200x160 SV area', (tester) async {
    await start(tester);
    final picker = tester.widget<SemiColorPicker>(keyed('colorpicker-size'));
    expect(picker.width, 200);
    expect(picker.height, 160);
    final rect = tester.getRect(sv('colorpicker-size'));
    expect(rect.width, 200);
    expect(rect.height, 160);
    expect(tester.takeException(), isNull);
  });
}
