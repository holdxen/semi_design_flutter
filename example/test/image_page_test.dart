import 'dart:ui' as ui;

import 'package:example/pages/image.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:semi_design_flutter/semi_design_flutter.dart';

/// 同步交付的测试 ImageProvider（免 codec，fake async 内可用）。
class _TestImageProvider extends ImageProvider<_TestImageProvider> {
  _TestImageProvider(this.image, {this.id = 0});
  final ui.Image image;
  final int id;

  @override
  Future<_TestImageProvider> obtainKey(ImageConfiguration configuration) =>
      SynchronousFuture(this);

  @override
  ImageStreamCompleter loadImage(
    _TestImageProvider key,
    ImageDecoderCallback decode,
  ) => OneFrameImageStreamCompleter(SynchronousFuture(ImageInfo(image: image)));

  @override
  bool operator ==(Object other) =>
      other is _TestImageProvider && other.id == id;
  @override
  int get hashCode => id.hashCode;
}

late ui.Image sampleImage;

Finder keyed(String key) => find.byKey(ValueKey(key));

Future<void> start(WidgetTester tester) async {
  addTearDown(() async => tester.pumpWidget(const SizedBox.shrink()));
  await tester.binding.setSurfaceSize(const Size(1200, 2400));
  await tester.pumpWidget(
    SemiApp(
      home: ImagePage(
        image: _TestImageProvider(sampleImage),
        images: [
          _TestImageProvider(sampleImage, id: 1),
          _TestImageProvider(sampleImage, id: 2),
          _TestImageProvider(sampleImage, id: 3),
        ],
      ),
    ),
  );
  await tester.pump(const Duration(milliseconds: 60));
}

void main() {
  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    final recorder = ui.PictureRecorder();
    Canvas(recorder).drawRect(
      const Rect.fromLTWH(0, 0, 60, 60),
      Paint()..color = const Color(0xFFFF0000),
    );
    sampleImage = await recorder.endRecording().toImage(60, 60);
  });

  testWidgets('page renders every demo section', (tester) async {
    await start(tester);
    for (final title in ['基础用法', '预览', '图库分组', '缩放档位']) {
      expect(find.text(title), findsOneWidget);
      await tester.ensureVisible(find.text(title));
      await tester.pump(const Duration(milliseconds: 100));
      expect(tester.takeException(), isNull);
    }
    expect(find.byType(SemiImage), findsWidgets);
    expect(find.byType(SemiImagePreview), findsOneWidget);
  });

  testWidgets('missing asset falls back and the custom fallback shows text', (
    tester,
  ) async {
    await start(tester);
    await tester.ensureVisible(keyed('image-fallback'));
    await tester.pump(const Duration(milliseconds: 100));
    expect(find.text('加载失败'), findsOneWidget);
    // 缺省失败回退：IconUploadError（限定本演示区内）。
    expect(
      find.descendant(
        of: keyed('image-fallback'),
        matching: find.byWidgetPredicate(
          (w) => w is SemiIcon && w.data == SemiIcons.uploadError,
        ),
      ),
      findsOneWidget,
    );
  });

  testWidgets('preview opens from the single-image demo', (tester) async {
    await start(tester);
    await tester.ensureVisible(keyed('image-preview'));
    await tester.pump(const Duration(milliseconds: 100));
    final demo = find.descendant(
      of: keyed('image-preview'),
      matching: find.byType(SemiImage),
    );
    await tester.tap(demo);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text('1/1'), findsOneWidget);
  });

  testWidgets('gallery demo opens at the clicked child', (tester) async {
    await start(tester);
    await tester.ensureVisible(keyed('image-gallery'));
    await tester.pump(const Duration(milliseconds: 100));
    final children = find.descendant(
      of: keyed('image-gallery'),
      matching: find.byType(SemiImage),
    );
    expect(children, findsNWidgets(3));
    await tester.tap(children.at(2));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text('3/3'), findsOneWidget);
    expect(find.text('图3'), findsOneWidget);
  });
}
