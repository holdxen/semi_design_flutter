// 临时诊断测试（不提交）：在真实页面布局（SingleChildScrollView + SemiApp）
// 中验证四角柄是否可拖拽、悬停时光标注解是否命中角柄。
import 'dart:ui' as ui;

import 'package:example/pages/cropper.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:semi_design_flutter/semi_design_flutter.dart';

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

Future<ui.Image> _paintImage() async {
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
  return recorder.endRecording().toImage(240, 160);
}

void main() {
  testWidgets('corner handles drag inside the real page layout', (tester) async {
    final image = await _paintImage();
    addTearDown(() async => tester.pumpWidget(const SizedBox.shrink()));
    await tester.binding.setSurfaceSize(const Size(1200, 3200));
    await tester.pumpWidget(
      SemiApp(home: CropperPage(image: _TestImageProvider(image))),
    );
    await tester.pump(const Duration(milliseconds: 60));

    final tlFinder = find.descendant(
      of: find.byKey(const ValueKey('cropper-basic')),
      matching: find.byKey(SemiCropper.cornerKey('tl')),
    );
    expect(tlFinder, findsOneWidget);
    final tlCenter = tester.getCenter(tlFinder);
    debugPrint('tl handle center: $tlCenter');

    final boxFinder = find.descendant(
      of: find.byKey(const ValueKey('cropper-basic')),
      matching: find.byKey(SemiCropper.boxKey),
    );
    final sizeBefore = tester.getSize(boxFinder);
    final topLeftBefore = tester.getTopLeft(boxFinder);
    debugPrint('box before: size=$sizeBefore topLeft=$topLeftBefore');

    final gesture = await tester.createGesture(kind: ui.PointerDeviceKind.mouse);
    await gesture.addPointer(location: tlCenter);
    addTearDown(gesture.removePointer);
    await gesture.down(tlCenter);
    await gesture.moveBy(const Offset(-30, -10));
    await tester.pump();
    await gesture.up();
    await tester.pump();

    final sizeAfter = tester.getSize(boxFinder);
    final topLeftAfter = tester.getTopLeft(boxFinder);
    debugPrint('box after: size=$sizeAfter topLeft=$topLeftAfter');
    expect(sizeAfter.width, greaterThan(sizeBefore.width));
  });
}
