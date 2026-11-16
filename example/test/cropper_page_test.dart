import 'dart:ui' as ui;

import 'package:example/pages/cropper.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:semi_design_flutter/semi_design_flutter.dart';

/// 同步交付的测试 ImageProvider（免 codec，fake async 内可用）。
class _TestImageProvider extends ImageProvider<_TestImageProvider> {
  _TestImageProvider(this.image);
  final ui.Image image;

  @override
  Future<_TestImageProvider> obtainKey(ImageConfiguration configuration) =>
      SynchronousFuture(this);

  @override
  ImageStreamCompleter loadImage(
    _TestImageProvider key,
    ImageDecoderCallback decode,
  ) => OneFrameImageStreamCompleter(SynchronousFuture(ImageInfo(image: image)));
}

late ui.Image sampleImage;

Finder keyed(String key) => find.byKey(ValueKey(key));

String statusText(WidgetTester tester) => tester
    .widgetList<Text>(
      find.descendant(of: keyed('cropper-status'), matching: find.byType(Text)),
    )
    .map((t) => t.data ?? '')
    .join();

Future<void> start(WidgetTester tester) async {
  addTearDown(() async => tester.pumpWidget(const SizedBox.shrink()));
  await tester.binding.setSurfaceSize(const Size(1200, 3200));
  await tester.pumpWidget(
    SemiApp(home: CropperPage(image: _TestImageProvider(sampleImage))),
  );
  await tester.pump(const Duration(milliseconds: 60));
}

void main() {
  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    canvas.drawRect(
      const Rect.fromLTWH(0, 0, 120, 160),
      Paint()..color = const Color(0xFFFF0000),
    );
    canvas.drawRect(
      const Rect.fromLTWH(120, 0, 120, 160),
      Paint()..color = const Color(0xFF0000FF),
    );
    sampleImage = await recorder.endRecording().toImage(240, 160);
  });

  testWidgets('page renders every demo section', (tester) async {
    await start(tester);
    for (final title in ['基本用法', '自定义裁切框比例', '受控旋转/缩放 + 实时预览', '裁切框设置']) {
      expect(find.text(title), findsOneWidget);
      await tester.ensureVisible(find.text(title));
      await tester.pump(const Duration(milliseconds: 80));
      expect(tester.takeException(), isNull);
    }
    expect(keyed('cropper-basic'), findsOneWidget);
    expect(keyed('cropper-ratio-default'), findsOneWidget);
    expect(keyed('cropper-ratio-fixed'), findsOneWidget);
    expect(keyed('cropper-controlled'), findsOneWidget);
    expect(keyed('cropper-box-style'), findsOneWidget);
    // previewBuilder 的 cropView 挂载在受控 demo 右侧。
    expect(find.byKey(SemiCropper.cropViewKey), findsOneWidget);
  });

  testWidgets('shape toggles switch the basic cropper shape', (tester) async {
    await start(tester);
    await tester.tap(keyed('cropper-shape-round'));
    await tester.pump(const Duration(milliseconds: 40));
    expect(statusText(tester), contains('shape round'));
    await tester.tap(keyed('cropper-shape-roundRect'));
    await tester.pump(const Duration(milliseconds: 40));
    expect(statusText(tester), contains('shape roundRect'));
    expect(tester.takeException(), isNull);
  });

  testWidgets('crop button reports the cropped image size', (tester) async {
    await start(tester);
    await tester.ensureVisible(keyed('cropper-crop'));
    await tester.tap(keyed('cropper-crop'));
    // 裁切输出走真实异步（Picture.toImage）。
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 100)),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 60));
    expect(statusText(tester), contains('裁切输出'));
    expect(keyed('cropper-crop-result'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
