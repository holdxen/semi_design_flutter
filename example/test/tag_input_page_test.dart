import 'package:example/pages/tag_input.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:semi_design_flutter/semi_design_flutter.dart';

Finder keyed(String key) => find.byKey(ValueKey(key));

Finder editable(String key) =>
    find.descendant(of: keyed(key), matching: find.byType(EditableText));

Finder root(String key) =>
    find.descendant(of: keyed(key), matching: find.byKey(SemiTagInput.rootKey));

Finder slot(String key, int index) => find.descendant(
  of: keyed(key),
  matching: find.byKey(SemiTagInput.tagKey(index)),
);

Finder handle(String key, int index) => find.descendant(
  of: keyed(key),
  matching: find.byKey(SemiTagInput.dragHandleKey(index)),
);

Finder closeIcon(String key, int index) =>
    find.descendant(of: slot(key, index), matching: find.byType(SemiIcon));

/// Tag labels inside the demo (`find.text` would also match the input line's
/// EditableText).
Finder tagLabel(String key, String value) => find.descendant(
  of: find.descendant(of: keyed(key), matching: find.byType(SemiTag)),
  matching: find.text(value),
);

Finder status(String text) =>
    find.descendant(of: keyed('taginput-status'), matching: find.text(text));

Finder statusContaining(String text) => find.descendant(
  of: keyed('taginput-status'),
  matching: find.textContaining(text),
);

Finder logContaining(String text) => find.descendant(
  of: keyed('taginput-events-log'),
  matching: find.textContaining(text),
);

Finder logExact(String text) => find.descendant(
  of: keyed('taginput-events-log'),
  matching: find.text(text),
);

String inputText(WidgetTester tester, String key) =>
    tester.widget<EditableText>(editable(key)).controller.text;

Visibility clearVisibility(WidgetTester tester, String key) =>
    tester.widget<Visibility>(
      find.ancestor(
        of: find.descendant(
          of: keyed(key),
          matching: find.byKey(SemiTagInput.clearButtonKey),
        ),
        matching: find.byType(Visibility),
      ),
    );

Future<void> start(WidgetTester tester) async {
  addTearDown(() async => tester.pumpWidget(const SizedBox.shrink()));
  await tester.pumpWidget(const SemiApp(home: TagInputPage()));
  await tester.pump(const Duration(milliseconds: 50));
}

/// Absorb the one dropped hit test (docs/known_issues.md #1) at a neutral
/// spot: (4, 4) sits in the page padding.
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

/// Type [text] into the demo's input line and commit with the engine `done`
/// action (the lib's enterAdd pattern — Enter 建标).
Future<void> enterAdd(WidgetTester tester, String key, String text) async {
  await tester.enterText(editable(key), text);
  await tester.testTextInput.receiveAction(TextInputAction.done);
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 100));
}

Future<TestGesture> mouse(WidgetTester tester) async {
  final gesture = await tester.createGesture(kind: PointerDeviceKind.mouse);
  await gesture.addPointer(location: Offset.zero);
  addTearDown(gesture.removePointer);
  return gesture;
}

/// Tooltip overlays mount a few frames after `visible` flips.
Future<void> settleTip(WidgetTester tester) async {
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 150));
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
      '基本演示',
      '批量添加',
      '批量删除',
      '禁用',
      '尺寸大小',
      '不同校验状态样式',
      '前缀 / 后缀',
      '失焦后自动创建标签',
      '过滤重复标签',
      '输入限制',
      '限制标签展示数量',
      '标签受控',
      '输入受控',
      '回调',
      '焦点管理',
      '自定义标签渲染',
      '拖拽排序',
    ]) {
      expect(find.text(title), findsOneWidget);
      await tester.ensureVisible(find.text(title));
      await tester.pump(const Duration(milliseconds: 100));
      expect(tester.takeException(), isNull);
    }
  });

  testWidgets('basic Enter adds ★untrimmed tags; Backspace and close remove', (
    tester,
  ) async {
    await start(tester);
    await enterAdd(tester, 'taginput-basic', 'a, b');
    // ★ 空段丢弃、值不 trim：'a' 与 ' b' 原样入库。
    expect(
      find.descendant(of: keyed('taginput-basic'), matching: find.text('a')),
      findsOneWidget,
    );
    expect(
      find.descendant(of: keyed('taginput-basic'), matching: find.text(' b')),
      findsOneWidget,
    );
    expect(inputText(tester, 'taginput-basic'), isEmpty);
    expect(statusContaining('onAdd'), findsOneWidget);
    expect(logContaining('onAdd'), findsOneWidget);
    // done 动作会收起焦点：重新聚焦后再按 Backspace 删最后一个（' b'）。
    await tap(tester, editable('taginput-basic'));
    await tester.sendKeyEvent(LogicalKeyboardKey.backspace);
    await tester.pump();
    expect(
      find.descendant(of: keyed('taginput-basic'), matching: find.text(' b')),
      findsNothing,
    );
    expect(logContaining('onRemove'), findsOneWidget);
    // 标签 × 关闭 'a'（index 3）。
    await tap(tester, closeIcon('taginput-basic', 3));
    expect(
      find.descendant(of: keyed('taginput-basic'), matching: find.text('a')),
      findsNothing,
    );
    expect(statusContaining('onRemove'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('controlled lands via setState; the button demo is strict', (
    tester,
  ) async {
    await start(tester);
    // 受控（官方「标签受控」）：Enter 建标经 setState 落地。
    await enterAdd(tester, 'taginput-controlled', '火山');
    expect(
      find.descendant(
        of: keyed('taginput-controlled'),
        matching: find.text('火山'),
      ),
      findsOneWidget,
    );
    expect(tester.widget<SemiTagInput>(keyed('taginput-controlled')).value, [
      '抖音',
      '火山',
    ]);
    // 严格受控：× 关闭只回调，列表不落地。
    await tap(tester, closeIcon('taginput-controlled-button', 0));
    expect(statusContaining('严格'), findsOneWidget);
    expect(
      find.descendant(
        of: keyed('taginput-controlled-button'),
        matching: find.text('抖音'),
      ),
      findsOneWidget,
    );
    // 拖拽重排同样只回调不落地。
    await tester.ensureVisible(keyed('taginput-controlled-button'));
    await tester.pump(const Duration(milliseconds: 50));
    await tap(tester, editable('taginput-controlled-button'));
    await warmup(tester);
    final from = tester.getCenter(handle('taginput-controlled-button', 0));
    final to = tester.getCenter(handle('taginput-controlled-button', 1));
    final gesture = await mouse(tester);
    await gesture.down(from);
    await tester.pump();
    await gesture.moveTo(to);
    await tester.pump();
    await gesture.up();
    await tester.pump();
    expect(
      find.descendant(
        of: slot('taginput-controlled-button', 0),
        matching: find.text('抖音'),
      ),
      findsOneWidget,
    );
    expect(
      find.descendant(
        of: slot('taginput-controlled-button', 1),
        matching: find.text('火山'),
      ),
      findsOneWidget,
    );
    // 按钮改值落地（唯一能改显示的通道）。
    await tap(tester, keyed('taginput-controlled-bump'));
    expect(
      find.descendant(
        of: keyed('taginput-controlled-button'),
        matching: find.text('新标签1'),
      ),
      findsOneWidget,
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('disabled blocks typing, Enter and close', (tester) async {
    await start(tester);
    expect(
      tester.widget<SemiTagInput>(keyed('taginput-disabled')).disabled,
      isTrue,
    );
    await tester.enterText(editable('taginput-disabled'), 'x');
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pump();
    expect(inputText(tester, 'taginput-disabled'), isEmpty);
    // 三条标签纹丝不动，且没有关闭钮。
    for (final tag in ['抖音', '火山', '西瓜视频']) {
      expect(
        find.descendant(
          of: keyed('taginput-disabled'),
          matching: find.text(tag),
        ),
        findsOneWidget,
      );
    }
    expect(closeIcon('taginput-disabled', 0), findsNothing);
    // 清除钮悬浮也不可见。
    await tester.ensureVisible(keyed('taginput-disabled'));
    await tester.pump(const Duration(milliseconds: 50));
    final gesture = await mouse(tester);
    await gesture.moveTo(tester.getCenter(root('taginput-disabled')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
    expect(clearVisibility(tester, 'taginput-disabled').visible, isFalse);
    // 状态行仍是占位文案。
    expect(status('在输入框回车添加标签，查看事件。'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('sizes render the documented root geometry', (tester) async {
    await start(tester);
    expect(
      tester.widget<SemiTagInput>(keyed('taginput-size-small')).size,
      SemiInputSize.small,
    );
    expect(
      tester.widget<SemiTagInput>(keyed('taginput-size-default')).size,
      SemiInputSize.normal,
    );
    expect(
      tester.widget<SemiTagInput>(keyed('taginput-size-large')).size,
      SemiInputSize.large,
    );
    // 根 min-height 24/32/40（tagInput.scss 几何）。
    expect(tester.getRect(root('taginput-size-small')).height, 24);
    expect(tester.getRect(root('taginput-size-default')).height, 32);
    expect(tester.getRect(root('taginput-size-large')).height, 40);
    // ★ Regression: text must lay out at NATURAL metrics — under the Ahem
    // test font the line box equals the font size. The app DefaultTextStyle
    // used to force `height: 20/14`, which scales the baseline down and
    // inflates the line box (the small chip's text looked low and clipped).
    for (final key in ['taginput-size-small', 'taginput-max-tag-count']) {
      final textFinder = find
          .descendant(of: keyed(key), matching: find.byType(Text))
          .first;
      final style = tester.widget<Text>(textFinder).style;
      expect(
        tester.getRect(textFinder).height,
        style?.fontSize ?? 14,
        reason: '$key line box must hug the font size',
      );
    }
    // The chip text sits centered in the chip.
    final chipText = tester.getRect(
      find
          .descendant(
            of: keyed('taginput-max-tag-count'),
            matching: find.byType(Text),
          )
          .first,
    );
    final chip = tester.getRect(
      find.descendant(
        of: keyed('taginput-max-tag-count'),
        matching: find.byKey(SemiTagInput.tagKey(0)),
      ),
    );
    expect(
      (chipText.top - chip.top) - (chip.bottom - chipText.bottom),
      moreOrLessEquals(0, epsilon: 0.001),
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('separator demos split batches on Enter', (tester) async {
    await start(tester);
    await enterAdd(tester, 'taginput-separator', 'x-y');
    expect(
      find.descendant(
        of: keyed('taginput-separator'),
        matching: find.text('x'),
      ),
      findsOneWidget,
    );
    expect(
      find.descendant(
        of: keyed('taginput-separator'),
        matching: find.text('y'),
      ),
      findsOneWidget,
    );
    // 多分隔符（官方 ['-', '/', '|', '++']）：'/' 也拆。
    await enterAdd(tester, 'taginput-separator-multi', 'x/y');
    expect(
      find.descendant(
        of: keyed('taginput-separator-multi'),
        matching: find.text('x'),
      ),
      findsOneWidget,
    );
    expect(
      find.descendant(
        of: keyed('taginput-separator-multi'),
        matching: find.text('y'),
      ),
      findsOneWidget,
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('maxTagCount folds to +N and hover shows the rest popover', (
    tester,
  ) async {
    await start(tester);
    await tester.ensureVisible(keyed('taginput-max-tag-count'));
    await tester.pump(const Duration(milliseconds: 50));
    expect(
      find.descendant(
        of: keyed('taginput-max-tag-count'),
        matching: find.text('抖音'),
      ),
      findsOneWidget,
    );
    expect(
      find.descendant(
        of: keyed('taginput-max-tag-count'),
        matching: find.text('火山'),
      ),
      findsOneWidget,
    );
    // 第三条折叠进 +1。
    expect(
      find.descendant(
        of: keyed('taginput-max-tag-count'),
        matching: find.text('西瓜视频'),
      ),
      findsNothing,
    );
    final nTag = find.descendant(
      of: keyed('taginput-max-tag-count'),
      matching: find.byKey(SemiTagInput.nTagKey),
    );
    expect(nTag, findsOneWidget);
    expect(
      find.descendant(
        of: keyed('taginput-max-tag-count'),
        matching: find.text('+1'),
      ),
      findsOneWidget,
    );
    // 悬浮 +N 显示余标 popover（showRestTagsPopover）。
    await warmup(tester);
    final gesture = await mouse(tester);
    await gesture.moveTo(tester.getCenter(nTag));
    await settleTip(tester);
    expect(find.byType(SemiTooltipPopup), findsOneWidget);
    expect(
      find.descendant(
        of: find.byType(SemiTooltipPopup),
        matching: find.text('西瓜视频'),
      ),
      findsOneWidget,
    );
    await gesture.moveTo(Offset.zero);
    await settleTip(tester);
    expect(find.byType(SemiTooltipPopup), findsNothing);
    // 聚焦放开折叠（expandRestTagsOnClick）。
    await tap(tester, editable('taginput-max-tag-count'));
    expect(
      find.descendant(
        of: keyed('taginput-max-tag-count'),
        matching: find.text('西瓜视频'),
      ),
      findsOneWidget,
    );
    expect(nTag, findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('maxLength rejects growing segments with onInputExceed', (
    tester,
  ) async {
    await start(tester);
    await tester.enterText(editable('taginput-max-length'), 'abcde');
    await tester.pump();
    expect(inputText(tester, 'taginput-max-length'), 'abcde');
    await tester.enterText(editable('taginput-max-length'), 'abcdef');
    await tester.pump();
    // ★ 越界击键被拒绝：显示保留旧文本（按分段只看增长）。
    expect(inputText(tester, 'taginput-max-length'), 'abcde');
    expect(statusContaining('onInputExceed'), findsOneWidget);
    expect(logContaining('onInputExceed abcdef'), findsOneWidget);
    // 删除放行。
    await tester.enterText(editable('taginput-max-length'), 'abc');
    await tester.pump();
    expect(inputText(tester, 'taginput-max-length'), 'abc');
    expect(tester.takeException(), isNull);
  });

  testWidgets('drag handles appear on focus; reorder fires one onChanged', (
    tester,
  ) async {
    await start(tester);
    await tester.ensureVisible(keyed('taginput-draggable'));
    await tester.pump(const Duration(milliseconds: 50));
    // 手柄仅在聚焦时出现。
    expect(handle('taginput-draggable', 0), findsNothing);
    await tap(tester, editable('taginput-draggable'));
    expect(handle('taginput-draggable', 0), findsOneWidget);
    expect(handle('taginput-draggable', 1), findsOneWidget);
    await warmup(tester);
    final from = tester.getCenter(handle('taginput-draggable', 0));
    final to = tester.getCenter(handle('taginput-draggable', 1));
    final gesture = await mouse(tester);
    await gesture.down(from);
    await tester.pump();
    await gesture.moveTo(to);
    await tester.pump();
    await gesture.up();
    await tester.pump();
    // arrayMove(0→1)：恰好一次 onChanged，无 onAdd/onRemove。
    expect(
      find.descendant(
        of: slot('taginput-draggable', 0),
        matching: find.text('火山'),
      ),
      findsOneWidget,
    );
    expect(
      find.descendant(
        of: slot('taginput-draggable', 1),
        matching: find.text('抖音'),
      ),
      findsOneWidget,
    );
    expect(logExact('onChanged [火山, 抖音, 西瓜视频]'), findsOneWidget);
    expect(logContaining('onAdd'), findsNothing);
    expect(logContaining('onRemove'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('clear button shows on hover and clears without onRemove', (
    tester,
  ) async {
    await start(tester);
    await tester.ensureVisible(keyed('taginput-clear'));
    await tester.pump(const Duration(milliseconds: 50));
    final clear = find.descendant(
      of: keyed('taginput-clear'),
      matching: find.byKey(SemiTagInput.clearButtonKey),
    );
    expect(clearVisibility(tester, 'taginput-clear').visible, isFalse);
    await warmup(tester);
    final gesture = await mouse(tester);
    await gesture.moveTo(tester.getCenter(clear));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
    expect(clearVisibility(tester, 'taginput-clear').visible, isTrue);
    await tap(tester, clear);
    expect(
      find.descendant(of: keyed('taginput-clear'), matching: find.text('抖音')),
      findsNothing,
    );
    expect(
      find.descendant(of: keyed('taginput-clear'), matching: find.text('火山')),
      findsNothing,
    );
    expect(logContaining('onChanged []'), findsOneWidget);
    // ★ 清除不发 onRemove。
    expect(logContaining('onRemove'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('validateStatus demos render the three states', (tester) async {
    await start(tester);
    expect(
      tester
          .widget<SemiTagInput>(keyed('taginput-validate-default'))
          .validateStatus,
      SemiInputStatus.normal,
    );
    expect(
      tester
          .widget<SemiTagInput>(keyed('taginput-validate-warning'))
          .validateStatus,
      SemiInputStatus.warning,
    );
    expect(
      tester
          .widget<SemiTagInput>(keyed('taginput-validate-error'))
          .validateStatus,
      SemiInputStatus.error,
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('max truncates after onExceed with the full attempted list', (
    tester,
  ) async {
    await start(tester);
    await enterAdd(tester, 'taginput-max', 'a,b,c,d,e');
    expect(logContaining('onExceed [a, b, c, d, e]'), findsOneWidget);
    // 静默截尾：只留 3 条。
    for (final tag in ['a', 'b', 'c']) {
      expect(
        find.descendant(of: keyed('taginput-max'), matching: find.text(tag)),
        findsOneWidget,
      );
    }
    expect(
      find.descendant(of: keyed('taginput-max'), matching: find.text('d')),
      findsNothing,
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('addOnBlur commits the pending text on blur', (tester) async {
    await start(tester);
    await tester.enterText(editable('taginput-add-on-blur'), 'x');
    await tester.pump();
    expect(tagLabel('taginput-add-on-blur', 'x'), findsNothing);
    FocusManager.instance.primaryFocus?.unfocus();
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
    expect(tagLabel('taginput-add-on-blur', 'x'), findsOneWidget);
    expect(logContaining('onAdd [x]'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('allowDuplicates=false drops existing and in-batch repeats', (
    tester,
  ) async {
    await start(tester);
    await enterAdd(tester, 'taginput-duplicates', '抖音,新,新');
    expect(
      find.descendant(
        of: keyed('taginput-duplicates'),
        matching: find.text('抖音'),
      ),
      findsOneWidget,
    );
    expect(
      find.descendant(
        of: keyed('taginput-duplicates'),
        matching: find.text('新'),
      ),
      findsOneWidget,
    );
    expect(logContaining('onAdd [新]'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('controlled input demo lands text via onInputChange', (
    tester,
  ) async {
    await start(tester);
    expect(inputText(tester, 'taginput-controlled-input'), 'abc');
    await tester.enterText(editable('taginput-controlled-input'), 'xyz');
    await tester.pump();
    expect(inputText(tester, 'taginput-controlled-input'), 'xyz');
    expect(
      tester
          .widget<SemiTagInput>(keyed('taginput-controlled-input'))
          .inputValue,
      'xyz',
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('renderTagItem draws custom rows and onClose removes', (
    tester,
  ) async {
    await start(tester);
    expect(
      find.descendant(
        of: keyed('taginput-render-item'),
        matching: find.text('夏可漫@semi.com'),
      ),
      findsOneWidget,
    );
    await tap(
      tester,
      find.descendant(
        of: keyed('taginput-render-item'),
        matching: find.byType(SemiIcon),
      ),
    );
    expect(
      find.descendant(
        of: keyed('taginput-render-item'),
        matching: find.text('夏可漫@semi.com'),
      ),
      findsNothing,
    );
    expect(
      tester.widget<SemiTagInput>(keyed('taginput-render-item')).value,
      isEmpty,
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('focus button focuses the input through the controller', (
    tester,
  ) async {
    await start(tester);
    await tap(tester, keyed('taginput-focus-button'));
    expect(
      tester
          .widget<EditableText>(editable('taginput-focus'))
          .focusNode
          .hasPrimaryFocus,
      isTrue,
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('callback demo logs input, add and focus events', (tester) async {
    await start(tester);
    await tap(tester, editable('taginput-events'));
    expect(logContaining('onFocus'), findsOneWidget);
    await tester.enterText(editable('taginput-events'), 'x');
    await tester.pump();
    expect(logContaining('onInputChange x'), findsOneWidget);
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pump();
    expect(logContaining('onAdd [x]'), findsOneWidget);
    FocusManager.instance.primaryFocus?.unfocus();
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
    expect(logContaining('onBlur'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
