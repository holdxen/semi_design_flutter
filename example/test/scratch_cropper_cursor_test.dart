import 'dart:io';
import 'dart:ui' as ui;

import 'package:example/pages/cropper.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
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

late ui.Image sampleImage;

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

  testWidgets('probe cropper cursor', (tester) async {
    addTearDown(() async => tester.pumpWidget(const SizedBox.shrink()));
    await tester.binding.setSurfaceSize(const Size(1200, 3200));
    await tester.pumpWidget(
      SemiApp(home: CropperPage(image: _TestImageProvider(sampleImage))),
    );
    await tester.pump(const Duration(milliseconds: 60));

    final center = tester.getCenter(
      find.byKey(const ValueKey('cropper-basic')),
    );
    final result = tester.hitTestOnBinding(center);
    final cursors = <String>[];
    for (final entry in result.path) {
      final target = entry.target;
      if (target is RenderMouseRegion) {
        cursors.add(
          '${target.cursor} opaque=${target.opaque} self=${entry.target.runtimeType}',
        );
      }
    }
    debugPrint('PROBE center=$center cursors=$cursors');

    final gesture = await tester.createGesture(kind: PointerDeviceKind.mouse);
    final kinds = <String>[];
    tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
      SystemChannels.mouseCursor,
      (call) async {
        kinds.add('${call.method}:${call.arguments}');
        return null;
      },
    );
    addTearDown(
      () => tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
        SystemChannels.mouseCursor,
        null,
      ),
    );
    await gesture.addPointer(location: center);
    await tester.pump();
    debugPrint('PROBE channel=$kinds');
    final rect = tester.getRect(find.byKey(const ValueKey('cropper-basic')));
    for (final dx in [0.02, 0.25, 0.5, 0.75, 0.98]) {
      for (final dy in [0.02, 0.25, 0.5, 0.75, 0.98]) {
        final p = Offset(
          rect.left + rect.width * dx,
          rect.top + rect.height * dy,
        );
        final hit = tester.hitTestOnBinding(p);
        final cursor = hit.path
            .map((e) => e.target)
            .whereType<RenderMouseRegion>()
            .map((r) => r.cursor.toString())
            .toList();
        debugPrint('PROBE $dx,$dy -> $cursor');
      }
    }
    await gesture.removePointer();
  });

  testWidgets('dump drawn move cursor', (tester) async {
    debugDefaultTargetPlatformOverride = TargetPlatform.macOS;
    try {
      await _dump(tester);
    } finally {
      debugDefaultTargetPlatformOverride = null;
    }
  });

  testWidgets('probe corner hover cursors', (tester) async {
    for (final platform in [
      TargetPlatform.macOS,
      TargetPlatform.linux,
      TargetPlatform.windows,
    ]) {
      debugDefaultTargetPlatformOverride = platform;
      try {
        addTearDown(() async => tester.pumpWidget(const SizedBox.shrink()));
        await tester.binding.setSurfaceSize(const Size(600, 320));
        await tester.pumpWidget(
          SemiTheme(
            data: const SemiThemeData.light(),
            child: Directionality(
              textDirection: TextDirection.ltr,
              child: Align(
                alignment: Alignment.topLeft,
                child: SizedBox(
                  width: 600,
                  height: 300,
                  child: SemiCropper(image: _TestImageProvider(sampleImage)),
                ),
              ),
            ),
          ),
        );
        await tester.pump();
        final kinds = <String>[];
        tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
          SystemChannels.mouseCursor,
          (call) async {
            final args = call.arguments as Map<Object?, Object?>;
            kinds.add('${args['kind']}');
            return null;
          },
        );
        for (final dir in const ['tl', 'tm', 'tr', 'ml', 'mr', 'bl', 'bm', 'br']) {
          kinds.clear();
          final at = tester.getCenter(find.byKey(SemiCropper.cornerKey(dir)));
          final gesture = await tester.createGesture(
            kind: PointerDeviceKind.mouse,
          );
          await gesture.addPointer(location: at);
          await tester.pump();
          debugPrint(
            'CORNER $platform $dir at=$at hit=${_hitCursors(tester, at)} kind=${kinds.last}',
          );
          await gesture.removePointer();
          await tester.pump();
        }
        tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
          SystemChannels.mouseCursor,
          null,
        );
      } finally {
        debugDefaultTargetPlatformOverride = null;
      }
    }
  });
}

List<String> _hitCursors(WidgetTester tester, Offset at) => tester
    .hitTestOnBinding(at)
    .path
    .map((e) => e.target)
    .whereType<RenderMouseRegion>()
    .map((r) => r.cursor.toString())
    .toList();

Future<void> _dump(WidgetTester tester) async {
  addTearDown(() async => tester.pumpWidget(const SizedBox.shrink()));
  await tester.binding.setSurfaceSize(const Size(760, 460));
  final boundaryKey = GlobalKey();
  await tester.pumpWidget(
    SemiTheme(
      data: const SemiThemeData.light(),
      child: Directionality(
        textDirection: TextDirection.ltr,
        child: Align(
          alignment: Alignment.topLeft,
          child: RepaintBoundary(
            key: boundaryKey,
            // 外留 60：对角光标绘制可越出裁切器边界（父级不裁剪）。
            child: Padding(
              padding: const EdgeInsets.all(60),
              child: SizedBox(
                width: 600,
                height: 300,
                child: SemiCropper(image: _TestImageProvider(sampleImage)),
              ),
            ),
          ),
        ),
      ),
    ),
  );
  await tester.pump();
  final gesture = await tester.createGesture(kind: PointerDeviceKind.mouse);
  final corner = tester.getCenter(find.byKey(SemiCropper.cornerKey('tl')));
  await gesture.addPointer(location: corner);
  await gesture.moveTo(corner);
  await tester.pump();
  debugPrint('DUMP corner=$corner glyphs=${find.byKey(SemiCropper.resizeCursorKey('tl')).evaluate().length}');
  await tester.runAsync(() async {
    final boundary =
        boundaryKey.currentContext!.findRenderObject()!
            as RenderRepaintBoundary;
    final image = await boundary.toImage(pixelRatio: 3);
    final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
    File('/tmp/semi_drawn_corner_cursor.png')
        .writeAsBytesSync(bytes!.buffer.asUint8List());
  });
  await gesture.removePointer();
}
