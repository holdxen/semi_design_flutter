import 'package:example/pages/autocomplete.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:semi_design_flutter/semi_design_flutter.dart';

Finder keyed(String key) => find.byKey(ValueKey(key));

Finder editable(String key) =>
    find.descendant(of: keyed(key), matching: find.byType(EditableText));

SemiAutoComplete complete(WidgetTester tester, String key) =>
    tester.widget<SemiAutoComplete>(keyed(key));

Future<void> start(WidgetTester tester) async {
  addTearDown(() async => tester.pumpWidget(const SizedBox.shrink()));
  await tester.pumpWidget(const SemiApp(home: AutoCompletePage()));
  await tester.pump(const Duration(milliseconds: 50));
}

/// Opens/taps through the overlay with the panel motion settled.
Future<void> tap(WidgetTester tester, Finder finder) async {
  await tester.ensureVisible(finder);
  await tester.pump(const Duration(milliseconds: 50));
  await tester.tap(finder);
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 100));
  await tester.pump();
}

/// Lets the panel overlay entry + entrance motion settle (the panel body
/// renders a few frames after `visible` flips).
Future<void> settle(WidgetTester tester) async {
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 150));
  await tester.pump();
}

String inputText(WidgetTester tester, String key) =>
    tester.widget<EditableText>(editable(key)).controller.text;

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
      '自定义候选项渲染',
      '远程搜索',
      '尺寸',
      '下拉菜单的位置',
      '禁用',
      '校验状态',
      '自定义空内容',
    ]) {
      expect(find.text(title), findsOneWidget);
      await tester.ensureVisible(find.text(title));
      await tester.pump(const Duration(milliseconds: 100));
      expect(tester.takeException(), isNull);
    }
    await tester.ensureVisible(keyed('autocomplete-empty'));
    await tester.pump(const Duration(milliseconds: 100));
    expect(tester.takeException(), isNull);
  });

  testWidgets('basic demo suggests domains and selecting fills the input', (
    tester,
  ) async {
    await start(tester);
    await tester.ensureVisible(keyed('autocomplete-basic'));
    await tester.pump(const Duration(milliseconds: 50));
    await tester.enterText(editable('autocomplete-basic'), 'abc');
    await settle(tester);
    expect(find.text('abc@gmail.com'), findsOneWidget);
    expect(find.text('abc@qq.com'), findsOneWidget);
    await tap(tester, find.text('abc@163.com'));
    expect(inputText(tester, 'autocomplete-basic'), 'abc@163.com');
    expect(find.textContaining('选中了「abc@163.com」'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('custom render selects through renderSelectedItem (email)', (
    tester,
  ) async {
    await start(tester);
    await tester.ensureVisible(keyed('autocomplete-custom'));
    await tester.pump(const Duration(milliseconds: 50));
    await tester.enterText(editable('autocomplete-custom'), '曲');
    await settle(tester);
    for (final name in ['夏可漫', '申悦', '曲晨一', '文嘉茂']) {
      expect(find.text(name), findsOneWidget);
    }
    await tap(tester, find.text('曲晨一'));
    expect(inputText(tester, 'autocomplete-custom'), 'quchenyi@example.com');
    expect(tester.takeException(), isNull);
  });

  testWidgets('remote search debounces, loads and reports the selection', (
    tester,
  ) async {
    await start(tester);
    await tester.ensureVisible(keyed('autocomplete-remote'));
    await tester.pump(const Duration(milliseconds: 50));
    await tester.enterText(editable('autocomplete-remote'), 'a');
    // 200ms debounce before the fake request starts.
    await tester.pump(const Duration(milliseconds: 250));
    await settle(tester);
    expect(find.byType(SemiSpin), findsOneWidget);
    // 1s fake latency resolves the filtered list.
    await tester.pump(const Duration(seconds: 1));
    await settle(tester);
    expect(find.byType(SemiSpin), findsNothing);
    expect(find.text('mail'), findsOneWidget);
    expect(find.text('calendar'), findsOneWidget);
    expect(find.text('comment'), findsNothing);
    await tap(tester, find.text('mail'));
    expect(find.textContaining('远程选中了「mail」'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('size disabled validateStatus and position match the demos', (
    tester,
  ) async {
    await start(tester);
    expect(complete(tester, 'autocomplete-small').size, SemiInputSize.small);
    expect(complete(tester, 'autocomplete-normal').size, SemiInputSize.normal);
    expect(complete(tester, 'autocomplete-large').size, SemiInputSize.large);
    expect(complete(tester, 'autocomplete-disabled').disabled, isTrue);
    expect(
      complete(tester, 'autocomplete-warning').validateStatus,
      SemiInputStatus.warning,
    );
    expect(
      complete(tester, 'autocomplete-error').validateStatus,
      SemiInputStatus.error,
    );
    expect(
      complete(tester, 'autocomplete-normal-status').validateStatus,
      SemiInputStatus.normal,
    );
    expect(
      complete(tester, 'autocomplete-position-top').position,
      SemiTooltipPosition.top,
    );
    expect(
      complete(tester, 'autocomplete-position-right').position,
      SemiTooltipPosition.rightTop,
    );
    expect(complete(tester, 'autocomplete-basic').showClear, isTrue);
    expect(complete(tester, 'autocomplete-basic').value, isNotNull);
    expect(tester.takeException(), isNull);
  });

  testWidgets('empty demo resolves options then falls back to emptyContent', (
    tester,
  ) async {
    await start(tester);
    await tester.ensureVisible(keyed('autocomplete-empty'));
    await tester.pump(const Duration(milliseconds: 50));
    await tester.enterText(editable('autocomplete-empty'), 'x');
    await settle(tester);
    expect(find.byType(SemiSpin), findsOneWidget);
    await tester.pump(const Duration(seconds: 1));
    await settle(tester);
    // Five random numeric candidates render through the keyword highlight.
    expect(find.byType(SemiHighlight), findsNWidgets(5));
    await tester.enterText(editable('autocomplete-empty'), '');
    await tester.pump(const Duration(seconds: 1));
    await settle(tester);
    expect(find.text('暂无内容'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
