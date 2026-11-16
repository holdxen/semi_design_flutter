import 'package:example/pages/upload.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:semi_design_flutter/semi_design_flutter.dart';

Finder keyed(String key) => find.byKey(ValueKey(key));

Finder inDemo(String demoKey, Finder matching) =>
    find.descendant(of: keyed(demoKey), matching: matching);

Finder statusContaining(String text) => find.descendant(
  of: keyed('upload-status'),
  matching: find.textContaining(text),
);

Future<void> start(WidgetTester tester) async {
  addTearDown(() async => tester.pumpWidget(const SizedBox.shrink()));
  await tester.binding.setSurfaceSize(const Size(1200, 2400));
  await tester.pumpWidget(const SemiApp(home: UploadPage()));
  await tester.pump(const Duration(milliseconds: 50));
}

Future<void> tapUntil(
  WidgetTester tester,
  Finder finder,
  bool Function() done, {
  Duration wait = const Duration(milliseconds: 250),
}) async {
  for (var i = 0; i < 2; i++) {
    await tester.ensureVisible(finder);
    await tester.pump(const Duration(milliseconds: 50));
    await tester.tap(finder, warnIfMissed: false);
    await tester.pump();
    await tester.pump(wait);
    await tester.pump();
    if (done()) return;
  }
}

void main() {
  testWidgets('page renders every demo section and variant', (tester) async {
    await start(tester);
    for (final title in [
      '基础列表',
      '拖拽区域',
      '失败与重试',
      '图片墙',
      '受控与自定义渲染',
      '禁用与根级校验',
      'RTL',
    ]) {
      expect(find.text(title), findsOneWidget);
      await tester.ensureVisible(find.text(title));
      await tester.pump(const Duration(milliseconds: 100));
      expect(tester.takeException(), isNull);
    }
    for (final key in [
      'upload-basic',
      'upload-validated',
      'upload-drag',
      'upload-drag-legal',
      'upload-retry',
      'upload-picture',
      'upload-controlled',
      'upload-custom-item',
      'upload-disabled',
      'upload-rtl',
    ]) {
      expect(keyed(key), findsOneWidget);
    }
    expect(tester.takeException(), isNull);
  });

  testWidgets('basic upload: pick → progress → success logs', (tester) async {
    await start(tester);
    await tapUntil(
      tester,
      inDemo('upload-basic', find.text('上传文件')),
      () => statusContaining('onProgress').evaluate().isNotEmpty,
    );
    expect(statusContaining('request').evaluate(), isNotEmpty);
    expect(statusContaining('onProgress').evaluate(), isNotEmpty);
    await tester.pump(const Duration(milliseconds: 200));
    await tester.pump();
    expect(statusContaining('onChange').evaluate(), isNotEmpty);
    // 列表卡出现（pdf 与 png 两个）。
    expect(inDemo('upload-basic', find.text('document.pdf')), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('validated upload rejects wrong type and oversized file', (
    tester,
  ) async {
    await start(tester);
    await tapUntil(
      tester,
      inDemo('upload-validated', find.text('上传（校验）')),
      () => statusContaining('onAcceptInvalid').evaluate().isNotEmpty,
    );
    expect(statusContaining('wrong.jpg'), findsOneWidget);
    expect(statusContaining('onSizeError huge.png'), findsOneWidget);
    expect(inDemo('upload-validated', find.text('huge.png')), findsOneWidget);
    expect(inDemo('upload-validated', find.text('wrong.jpg')), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('retry flow: error message and retry re-requests', (
    tester,
  ) async {
    await start(tester);
    await tapUntil(
      tester,
      inDemo('upload-retry', find.text('上传（可失败）')),
      () => inDemo('upload-retry', find.text('重试')).evaluate().isNotEmpty,
    );
    expect(inDemo('upload-retry', find.text('网络错误')), findsOneWidget);
    await tester.tap(inDemo('upload-retry', find.text('重试')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 250));
    expect(statusContaining('onRetry fail.err'), findsOneWidget);
    expect(statusContaining('request fail.err').evaluate(), isNotEmpty);
    expect(tester.takeException(), isNull);
  });

  testWidgets('picture list renders seed cards and add trigger appends', (
    tester,
  ) async {
    await start(tester);
    await tester.ensureVisible(keyed('upload-picture'));
    await tester.pump(const Duration(milliseconds: 100));
    expect(inDemo('upload-picture', find.text('1')), findsOneWidget);
    expect(inDemo('upload-picture', find.text('2')), findsOneWidget);
    await tapUntil(
      tester,
      inDemo('upload-picture', find.byKey(SemiUpload.triggerKey)),
      () => inDemo('upload-picture', find.text('3')).evaluate().isNotEmpty,
    );
    expect(inDemo('upload-picture', find.text('3')), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('controlled list follows state; external reset/clear works', (
    tester,
  ) async {
    await start(tester);
    await tester.ensureVisible(keyed('upload-controlled'));
    await tester.pump(const Duration(milliseconds: 50));
    expect(
      inDemo('upload-controlled', find.text('controlled.png')),
      findsOneWidget,
    );
    await tester.tap(find.text('外部清空'));
    await tester.pump();
    expect(
      inDemo('upload-controlled', find.text('controlled.png')),
      findsNothing,
    );
    await tester.tap(find.text('重置'));
    await tester.pump();
    expect(
      inDemo('upload-controlled', find.text('controlled.png')),
      findsOneWidget,
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('custom item, disabled and RTL render', (tester) async {
    await start(tester);
    await tester.ensureVisible(keyed('upload-custom-item'));
    await tester.pump(const Duration(milliseconds: 100));
    expect(
      inDemo('upload-custom-item', find.textContaining('自定义条目 · custom.png')),
      findsOneWidget,
    );
    await tester.ensureVisible(keyed('upload-disabled'));
    await tester.pump(const Duration(milliseconds: 100));
    expect(inDemo('upload-disabled', find.text('至少上传一个文件')), findsOneWidget);
    await tester.ensureVisible(keyed('upload-rtl'));
    await tester.pump(const Duration(milliseconds: 100));
    expect(tester.takeException(), isNull);
  });
}
