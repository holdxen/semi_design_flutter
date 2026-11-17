// 临时诊断（不提交）：复现「Cropper 角柄光标/命中」在真实 shell 布局下的回归。
// 用法：flutter test test/scratch_cursor_diag_test.dart
import 'dart:ui' as ui;

import 'package:example/main.dart';
import 'package:example/pages/cropper.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/rendering.dart';
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
  return recorder.endRecording().toImage(240, 160);
}

/// 命中路径上最深（最先决定光标）的 MouseRegion 光标。
List<MouseCursor> cursorsAt(WidgetTester tester, Offset pos) {
  final result = HitTestResult();
  tester.binding.hitTestInView(
    result,
    pos,
    ui.PlatformDispatcher.instance.implicitView!.viewId,
  );
  return [
    for (final entry in result.path)
      if (entry.target is RenderMouseRegion)
        (entry.target as RenderMouseRegion).annotation.cursor,
  ];
}

Future<void> diag(WidgetTester tester, String label) async {
  final tl = find.descendant(
    of: find.byKey(const ValueKey('cropper-basic')),
    matching: find.byKey(SemiCropper.cornerKey('tl')),
  );
  expect(tl, findsOneWidget, reason: label);
  final tlCenter = tester.getCenter(tl);
  final maskCenter = tester.getCenter(
    find.descendant(
      of: find.byKey(const ValueKey('cropper-basic')),
      matching: find.byKey(SemiCropper.maskKey),
    ),
  );
  final boxFinder = find.descendant(
    of: find.byKey(const ValueKey('cropper-basic')),
    matching: find.byKey(SemiCropper.boxKey),
  );
  final before = tester.getTopLeft(boxFinder);
  debugPrint('[$label] tlCenter=$tlCenter');
  debugPrint('[$label] cursor@tl=${cursorsAt(tester, tlCenter)}');
  debugPrint('[$label] cursor@mask=${cursorsAt(tester, maskCenter)}');

  final gesture = await tester.createGesture(kind: ui.PointerDeviceKind.mouse);
  await gesture.addPointer(location: tlCenter);
  addTearDown(gesture.removePointer);
  await gesture.down(tlCenter);
  await gesture.moveBy(const Offset(-30, -10));
  await tester.pump();
  await gesture.up();
  await tester.pump();
  final after = tester.getTopLeft(boxFinder);
  final size = tester.getSize(boxFinder);
  debugPrint('[$label] drag tl: topLeft $before -> $after size=$size');
  debugPrint(
    '[$label] drag grew box: ${after.dx < before.dx && after.dy < before.dy}',
  );
}

void main() {
  testWidgets('diag: bare SemiApp + CropperPage（修复后基线）', (tester) async {
    final image = await _paintImage();
    addTearDown(() async => tester.pumpWidget(const SizedBox.shrink()));
    await tester.binding.setSurfaceSize(const Size(1200, 3200));
    await tester.pumpWidget(
      SemiApp(home: CropperPage(image: _TestImageProvider(image))),
    );
    await tester.pump(const Duration(milliseconds: 60));
    await diag(tester, 'bare-light');
  });

  testWidgets('diag: 完整 shell（MyApp）导航到 Cropper 页', (tester) async {
    addTearDown(() async => tester.pumpWidget(const SizedBox.shrink()));
    await tester.binding.setSurfaceSize(const Size(1200, 3200));
    await tester.pumpWidget(const MyApp());
    await tester.pump(const Duration(milliseconds: 60));
    await tester.tap(find.text('Cropper 图片裁切'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    await diag(tester, 'shell-light');
  });

  testWidgets('diag: 完整 shell 暗黑模式', (tester) async {
    addTearDown(() async => tester.pumpWidget(const SizedBox.shrink()));
    await tester.binding.setSurfaceSize(const Size(1200, 3200));
    await tester.pumpWidget(const MyApp());
    await tester.pump(const Duration(milliseconds: 60));
    await tester.tap(find.byType(SemiSwitch));
    await tester.pump();
    await tester.tap(find.text('Cropper 图片裁切'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    await diag(tester, 'shell-dark');
  });
}
