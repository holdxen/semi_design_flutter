// Behavior matrix for SemiCropper plus coverage for the 5 Sass declarations
// (5 FIELDS + 0 MOTION + 0 INTERNAL) — the 33 HARDCODES provenance anchors
// live in the widget's file-level note block / call sites. 0 死变量.
import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/gestures.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:semi_design_flutter/semi_design_flutter.dart';

Widget host(
  Widget child, {
  TextDirection direction = TextDirection.ltr,
  double width = 600,
  double height = 300,
}) => SemiTheme(
  data: const SemiThemeData.light(),
  child: Directionality(
    textDirection: direction,
    child: Align(
      alignment: Alignment.topLeft,
      child: SizedBox(
        width: width,
        height: height,
        child: Align(alignment: Alignment.topLeft, child: child),
      ),
    ),
  ),
);

Future<void> pumpHost(
  WidgetTester tester,
  Widget child, {
  TextDirection direction = TextDirection.ltr,
  double width = 600,
  double height = 300,
}) async {
  addTearDown(() async => tester.pumpWidget(const SizedBox.shrink()));
  await tester.binding.setSurfaceSize(const Size(1200, 800));
  await tester.pumpWidget(
    host(child, direction: direction, width: width, height: height),
  );
  await tester.pump();
}

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

late ui.Image sampleImage; // 240x160：左半红、右半蓝、上边灰条
const red = Color(0xFFFF0000);
const blue = Color(0xFF0000FF);

Future<ui.Image> _paintImage(
  int width,
  int height,
  List<(Rect, Color)> regions,
) async {
  final recorder = ui.PictureRecorder();
  final canvas = Canvas(recorder);
  for (final (rect, color) in regions) {
    canvas.drawRect(rect, Paint()..color = color);
  }
  return recorder.endRecording().toImage(width, height);
}

// 240x160 显示尺寸 450x300（scale 1.875）；裁切框 300x300 @ (150, 0)。
Size imageSize(WidgetTester tester) =>
    tester.getSize(find.byKey(SemiCropper.imageKey));

Offset imageTopLeft(WidgetTester tester) => Offset(
  tester
      .widget<Positioned>(
        find
            .ancestor(
              of: find.byKey(SemiCropper.imageKey),
              matching: find.byType(Positioned),
            )
            .first,
      )
      .left!,
  tester
      .widget<Positioned>(
        find
            .ancestor(
              of: find.byKey(SemiCropper.imageKey),
              matching: find.byType(Positioned),
            )
            .first,
      )
      .top!,
);

Size boxSize(WidgetTester tester) =>
    tester.getSize(find.byKey(SemiCropper.boxKey));

Offset boxTopLeft(WidgetTester tester) =>
    tester.getTopLeft(find.byKey(SemiCropper.boxKey));

Color pixelAt(ByteData data, int width, int x, int y) {
  final o = (y * width + x) * 4;
  return Color.fromARGB(
    data.getUint8(o + 3),
    data.getUint8(o),
    data.getUint8(o + 1),
    data.getUint8(o + 2),
  );
}

Future<TestGesture> startMouse(WidgetTester tester, Offset at) async {
  final gesture = await tester.createGesture(kind: ui.PointerDeviceKind.mouse);
  await gesture.addPointer(location: at);
  addTearDown(gesture.removePointer);
  return gesture;
}

Future<void> wheel(WidgetTester tester, Offset at, double dy) async {
  await tester.sendEventToBinding(
    PointerScrollEvent(position: at, scrollDelta: Offset(0, dy)),
  );
  await tester.pump();
}

// -- theme field table -------------------------------------------------------

typedef _Patch = SemiCropperThemeData Function(Object value);
typedef _Read = Object? Function(SemiResolvedCropperThemeData data);
typedef _Default = Object? Function(SemiThemeData theme);

const _c = Color(0xFF010203);

final List<(String, Object, _Patch, _Read, _Default)> fields = [
  (
    r'$color-cropper_mask-bg: var(--semi-color-overlay-bg)',
    _c,
    (v) => SemiCropperThemeData(colorCropperMaskBg: v as Color),
    (d) => d.colorCropperMaskBg,
    (t) => t.colors.colorOverlayBg,
  ),
  (
    r'$color-cropper_box-outline: var(--semi-color-primary)',
    _c,
    (v) => SemiCropperThemeData(colorCropperBoxOutline: v as Color),
    (d) => d.colorCropperBoxOutline,
    (t) => t.colors.colorPrimary,
  ),
  (
    r'$color-cropper_box_corner-bg: var(--semi-color-primary)',
    _c,
    (v) => SemiCropperThemeData(colorCropperBoxCornerBg: v as Color),
    (d) => d.colorCropperBoxCornerBg,
    (t) => t.colors.colorPrimary,
  ),
  (
    r'$width-cropper_box-outline: 1px',
    1.0,
    (v) => SemiCropperThemeData(widthCropperBoxOutline: v as double),
    (d) => d.widthCropperBoxOutline,
    (t) => 1,
  ),
  (
    r'$width-cropper_box_corner: 10px',
    10.0,
    (v) => SemiCropperThemeData(widthCropperBoxCorner: v as double),
    (d) => d.widthCropperBoxCorner,
    (t) => 10,
  ),
];

void main() {
  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    sampleImage = await _paintImage(240, 160, [
      (const Rect.fromLTWH(0, 0, 120, 160), red),
      (const Rect.fromLTWH(120, 0, 120, 160), blue),
    ]);
  });

  group('theme fields (5 = 5 FIELDS + 0 MOTION + 0 INTERNAL)', () {
    test('5 fields: merge, copyWith, resolve, equality, defaults', () {
      expect(fields, hasLength(5));
      for (final (sass, value, make, read, expected) in fields) {
        final patch = make(value);
        expect(const SemiCropperThemeData().merge(patch), patch, reason: sass);
        expect(patch.copyWith(), patch, reason: sass);
        expect(patch.copyWith().hashCode, patch.hashCode, reason: sass);
        expect(patch.merge(null), patch, reason: sass);
        expect(
          read(patch.resolve(const SemiThemeData.dark())),
          value,
          reason: sass,
        );
        final light = const SemiThemeData.light();
        expect(
          read(const SemiCropperThemeData().resolve(light)),
          expected(light),
          reason: sass,
        );
        final dark = const SemiThemeData.dark();
        expect(
          read(const SemiCropperThemeData().resolve(dark)),
          expected(dark),
          reason: sass,
        );
      }
    });

    test('every field carries its Sass provenance in the generated source', () {
      final source = File('lib/src/theme/semi_cropper_theme_data.dart')
          .readAsStringSync();
      final names = <String>{};
      for (final (sass, _, _, _, _) in fields) {
        expect(source, contains(sass));
        names.add(sass.split(': ').first.substring(1));
      }
      expect(names, hasLength(5));
      expect(
        source,
        contains('packages/semi-foundation/cropper/variables.scss'),
      );
      expect(source, contains('Generated by tool/generate_cropper.py'));
      expect(source, contains('★注释照抄：`// 裁切框遮罩背景颜色`'));
      expect(source, isNot(contains('# dead variable (上游未消费)')));
    });

    test('the 33 HARDCODES anchors live in the widget source', () {
      final widgetSource = File('lib/src/components/semi_cropper.dart')
          .readAsStringSync();
      const anchors = <String>[
        r'${BASE_CLASS_PREFIX}-cropper',
        "shape: ['rect', 'round', 'roundRect']",
        "'tl', 'tm', 'tr', 'ml', 'mr', 'bl', 'bm', 'br'",
        "'tm', 'ml', 'mr', 'bm'",
        "shape: 'rect'",
        'defaultAspectRatio: 1',
        'showResizeBox: true',
        "fill: 'rgba(0, 0, 0, 0)'",
        'maxZoom: 3',
        'minZoom: 0.1',
        'zoomStep: 0.1',
        "crossOrigin='anonymous'",
        "transformOrigin: 'center'",
        'max-width: none',
        'user-select: none',
        'cursor: move;;',
        'cursor: nwse-resize',
        r'$half_corner_width: calc($width-cropper_box_corner / 2)',
        r'-$half_corner_width',
        '// position: absolute;',
        'border-radius: 50%',
        '{ passive: false }',
        '(currZoom + zoomStep).toFixed(2)',
        'centerPoint 的 y 坐标与实际的坐标系方向相反',
        'viewIMGDragStart',
        'target.dataset.dir',
        'ObserverProperty.Width',
        'getAspectHW',
        'getMiddle',
        'changeDir',
        'getImageData(realLeft, realTop, realWidth, realHeight)',
        'relativeCropLeft < 0 ? - relativeCropLeft : 0',
        'fillRect(0, 0, relativeWidth, relativeHeight)',
      ];
      expect(anchors, hasLength(33));
      for (final anchor in anchors) {
        expect(widgetSource, contains(anchor), reason: anchor);
      }
    });

    test('type coverage: 3 Color + 2 double = 5', () {
      final counts = <String, int>{};
      for (final (_, value, _, _, _) in fields) {
        counts.update(
          value.runtimeType.toString(),
          (n) => n + 1,
          ifAbsent: () => 1,
        );
      }
      expect(counts['Color'], 3);
      expect(counts['double'], 2);
    });

    test('0 dead variables: every field name appears in the widget source', () {
      final widgetSource = File('lib/src/components/semi_cropper.dart')
          .readAsStringSync();
      for (final (sass, _, _, _, _) in fields) {
        final name = sass.split(':').first.substring(1);
        var camel = '';
        var upper = false;
        for (final char in name.split('')) {
          if (char == '-' || char == '_') {
            upper = true;
          } else if (upper) {
            camel += char.toUpperCase();
            upper = false;
          } else {
            camel += char;
          }
        }
        expect(widgetSource, contains(camel), reason: camel);
      }
      final docs = File('docs/semi_cropper.md').readAsStringSync();
      expect(docs, contains('5 = 5 FIELDS + 0 MOTION + 0 INTERNAL'));
      expect(docs, contains('0 死变量'));
    });

    test('SemiComponentThemes wiring', () {
      const themes = SemiComponentThemes();
      expect(themes.cropper, const SemiCropperThemeData());
      expect(
        themes.copyWith(
          cropper: const SemiCropperThemeData(widthCropperBoxCorner: 20),
        ),
        const SemiComponentThemes(
          cropper: SemiCropperThemeData(widthCropperBoxCorner: 20),
        ),
      );
    });
  });

  group('behavior', () {
    testWidgets('initial fit fills the container and centers the box', (
      tester,
    ) async {
      await pumpHost(
        tester,
        SemiCropper(image: _TestImageProvider(sampleImage)),
      );
      expect(imageSize(tester), const Size(450, 300));
      expect(imageTopLeft(tester), const Offset(75, 0));
      expect(boxSize(tester), const Size(300, 300));
      expect(boxTopLeft(tester), const Offset(150, 0));
    });

    testWidgets('mask drag pans the image without bounds', (tester) async {
      await pumpHost(
        tester,
        SemiCropper(image: _TestImageProvider(sampleImage)),
      );
      final gesture = await startMouse(tester, const Offset(30, 150));
      await gesture.down(const Offset(30, 150));
      await gesture.moveBy(const Offset(10, 20));
      await tester.pump();
      await gesture.up();
      expect(imageTopLeft(tester), const Offset(85, 20));
      expect(boxTopLeft(tester), const Offset(150, 0));
    });

    testWidgets('box drag moves the crop box and clamps at the edges', (
      tester,
    ) async {
      await pumpHost(
        tester,
        SemiCropper(image: _TestImageProvider(sampleImage)),
      );
      final gesture = await startMouse(tester, const Offset(300, 150));
      await gesture.down(const Offset(300, 150));
      await gesture.moveBy(const Offset(50, 0));
      await tester.pump();
      await gesture.up();
      expect(boxTopLeft(tester), const Offset(200, 0));

      // 同一鼠标指针再次按下拖动。
      await gesture.down(const Offset(350, 150));
      await gesture.moveBy(const Offset(600, 0));
      await tester.pump();
      await gesture.up();
      // 中心钳到 600 - 150 = 450。
      expect(boxTopLeft(tester), const Offset(300, 0));
    });

    testWidgets('corner drag resizes freely and flips past zero', (
      tester,
    ) async {
      await pumpHost(
        tester,
        SemiCropper(image: _TestImageProvider(sampleImage)),
      );
      final gesture = await startMouse(tester, const Offset(150, 0));
      await gesture.down(const Offset(150, 0));
      await gesture.moveBy(const Offset(-20, -20));
      await tester.pump();
      await gesture.up();
      // tl 柄：宽 300 → 320（高度被 y=0 钳住不变）。
      expect(boxSize(tester), const Size(320, 300));
      expect(boxTopLeft(tester), const Offset(130, 0));

      // 拖过零点翻柄（changeDir）：tl 向右拖过右缘，宽度反向跟随指针。
      await gesture.down(const Offset(130, 0));
      await gesture.moveBy(const Offset(400, 0));
      await tester.pump();
      await gesture.up();
      expect(boxSize(tester).width, 80);
      expect(boxTopLeft(tester), const Offset(450, 0));
    });

    testWidgets('aspect-locked corner drag keeps the ratio', (tester) async {
      await pumpHost(
        tester,
        SemiCropper(image: _TestImageProvider(sampleImage), aspectRatio: 1),
      );
      // 先移动裁切框到中心 (200, 150)。
      final gesture = await startMouse(tester, const Offset(300, 150));
      await gesture.down(const Offset(300, 150));
      await gesture.moveBy(const Offset(-100, 0));
      await tester.pump();
      await gesture.up();
      expect(boxTopLeft(tester), const Offset(50, 0));

      // mr 柄定比缩放：宽高同步收到 250。
      await gesture.down(const Offset(350, 150));
      await gesture.moveBy(const Offset(-50, 0));
      await tester.pump();
      await gesture.up();
      expect(boxSize(tester), const Size(250, 250));
      expect(boxTopLeft(tester), const Offset(50, 25));
    });

    testWidgets('wheel zooms around the pointer with toFixed steps', (
      tester,
    ) async {
      final zooms = <double>[];
      await pumpHost(
        tester,
        SemiCropper(
          image: _TestImageProvider(sampleImage),
          onZoomChange: zooms.add,
        ),
      );
      // 指针在图片中心：只放大尺寸，不动中心。
      await wheel(tester, const Offset(300, 150), -1);
      expect(zooms, [1.1]);
      expect(imageSize(tester).width, closeTo(495, 0.001));
      expect(imageSize(tester).height, closeTo(330, 0.001));
      await wheel(tester, const Offset(300, 150), -1);
      await wheel(tester, const Offset(300, 150), -1);
      expect(zooms.last, 1.3);
      // toFixed(2)：1.3 - 0.1 → 1.2（浮点收敛）。
      await wheel(tester, const Offset(300, 150), 1);
      expect(zooms.last, 1.2);

      // 偏心缩放：定点在指针——指针右侧放大时图像左沿左移（定点不变）。
      final before = imageTopLeft(tester);
      await wheel(tester, const Offset(500, 150), -1);
      expect(zooms.last, 1.3);
      expect(imageTopLeft(tester).dx, lessThan(before.dx));

      // maxZoom 钳制。
      for (var i = 0; i < 30; i++) {
        await wheel(tester, const Offset(300, 150), -1);
      }
      expect(zooms.last, 3.0);
    });

    testWidgets('wheel zoom out clamps at minZoom', (tester) async {
      final zooms = <double>[];
      await pumpHost(
        tester,
        SemiCropper(
          image: _TestImageProvider(sampleImage),
          onZoomChange: zooms.add,
        ),
      );
      for (var i = 0; i < 20; i++) {
        await wheel(tester, const Offset(300, 150), 1);
      }
      expect(zooms.last, 0.1);
    });

    testWidgets('controlled zoom and rotate resync like getDerivedState', (
      tester,
    ) async {
      await pumpHost(
        tester,
        SemiCropper(
          image: _TestImageProvider(sampleImage),
          zoom: 2,
          rotate: 180,
        ),
      );
      expect(imageSize(tester).width, closeTo(900, 0.001));
      expect(imageSize(tester).height, closeTo(600, 0.001));
      final m = tester
          .widget<Transform>(
            find
                .ancestor(
                  of: find.byKey(SemiCropper.imageKey),
                  matching: find.byType(Transform),
                )
                .first,
          )
          .transform;
      expect(m.storage[0], closeTo(-1, 0.001)); // rotationZ(pi)
      expect(m.storage[5], closeTo(-1, 0.001));

      // 受控值变化：尺寸按比例重算（900 → 675）。
      await tester.pumpWidget(
        host(
          SemiCropper(
            image: _TestImageProvider(sampleImage),
            zoom: 1.5,
            rotate: 180,
          ),
        ),
      );
      await tester.pump();
      expect(imageSize(tester).width, closeTo(675, 0.001));
      expect(imageSize(tester).height, closeTo(450, 0.001));
    });

    testWidgets('showResizeBox and shape drive the corner handles', (
      tester,
    ) async {
      await pumpHost(
        tester,
        SemiCropper(
          image: _TestImageProvider(sampleImage),
          showResizeBox: false,
        ),
      );
      expect(find.byKey(SemiCropper.cornerKey('tl')), findsNothing);

      await tester.pumpWidget(
        host(
          SemiCropper(
            image: _TestImageProvider(sampleImage),
            shape: SemiCropperShape.round,
          ),
        ),
      );
      await tester.pump();
      expect(find.byKey(SemiCropper.cornerKey('tl')), findsNothing);
      expect(find.byKey(SemiCropper.cornerKey('br')), findsNothing);
      expect(find.byKey(SemiCropper.cornerKey('tm')), findsOneWidget);
      expect(find.byKey(SemiCropper.cornerKey('ml')), findsOneWidget);
      expect(find.byKey(SemiCropper.cornerKey('mr')), findsOneWidget);
      expect(find.byKey(SemiCropper.cornerKey('bm')), findsOneWidget);

      await tester.pumpWidget(
        host(SemiCropper(image: _TestImageProvider(sampleImage))),
      );
      await tester.pump();
      for (final dir in ['tl', 'tm', 'tr', 'ml', 'mr', 'bl', 'bm', 'br']) {
        expect(
          find.byKey(SemiCropper.cornerKey(dir)),
          findsOneWidget,
          reason: dir,
        );
        expect(
          tester.getSize(find.byKey(SemiCropper.cornerKey(dir))),
          const Size(10, 10),
        );
      }
    });

    testWidgets('a local theme patch drives mask colour and corner size', (
      tester,
    ) async {
      await pumpHost(
        tester,
        SemiCropperTheme(
          data: const SemiCropperThemeData(
            colorCropperMaskBg: Color(0xFF123456),
            widthCropperBoxCorner: 20,
          ),
          child: SemiCropper(image: _TestImageProvider(sampleImage)),
        ),
      );
      expect(
        tester.getSize(find.byKey(SemiCropper.cornerKey('tl'))),
        const Size(20, 20),
      );
      final mask = tester.widget<ColoredBox>(
        find.descendant(
          of: find.byKey(SemiCropper.maskKey),
          matching: find.byType(ColoredBox),
        ),
      );
      expect(mask.color, const Color(0xFF123456));
    });

    testWidgets('previewBuilder composes the cropper and the crop view', (
      tester,
    ) async {
      await pumpHost(
        tester,
        SemiCropper(
          image: _TestImageProvider(sampleImage),
          previewBuilder: (context, cropper, cropView) => Row(
            children: [
              SizedBox(width: 600, height: 300, child: cropper),
              SizedBox(width: 300, height: 300, child: cropView),
            ],
          ),
        ),
        width: 900,
      );
      expect(find.byKey(SemiCropper.boxKey), findsOneWidget);
      expect(find.byKey(SemiCropper.cropViewKey), findsOneWidget);
      // updatePreview 适配数学：300x300 约束、300x300 裁切框 → 1:1。
      expect(
        tester.getSize(find.byKey(SemiCropper.cropViewKey)),
        const Size(300, 300),
      );
    });

    testWidgets('container width resize scales image and box', (tester) async {
      await pumpHost(
        tester,
        SemiCropper(image: _TestImageProvider(sampleImage)),
      );
      await tester.pumpWidget(
        host(SemiCropper(image: _TestImageProvider(sampleImage)), width: 1200),
      );
      await tester.pump();
      expect(imageSize(tester).width, closeTo(900, 0.001));
      expect(imageSize(tester).height, closeTo(600, 0.001));
      // 无 aspectRatio（自由框）：600x600 比例缩放后钳回 1200x300 →
      // 600x300 @ (300, 0)。
      expect(boxSize(tester), const Size(600, 300));
      expect(boxTopLeft(tester), const Offset(300, 0));
    });

    testWidgets('controller crops at original resolution', (tester) async {
      final controller = SemiCropperController();
      await pumpHost(
        tester,
        SemiCropper(
          image: _TestImageProvider(sampleImage),
          controller: controller,
        ),
      );
      expect(controller.isAttached, isTrue);
      final result = (await tester.runAsync(
        () => controller.getCropperImage(),
      ))!;
      // 裁切框 300 / realZoom 1.875 = 160 原图像素。
      expect(result.width, 160);
      expect(result.height, 160);
      final bytes = (await tester.runAsync(
        () => result.toByteData(format: ui.ImageByteFormat.rawRgba),
      ))!;
      // 裁切区域 x 40..200：左半红、右半蓝。
      expect(pixelAt(bytes, 160, 40, 80), red);
      expect(pixelAt(bytes, 160, 120, 80), blue);
      result.dispose();
    });

    testWidgets('cropping with the image panned away returns the fill', (
      tester,
    ) async {
      final controller = SemiCropperController();
      await pumpHost(
        tester,
        SemiCropper(
          image: _TestImageProvider(sampleImage),
          controller: controller,
          fill: const Color(0xFF00FF00),
        ),
      );
      final gesture = await startMouse(tester, const Offset(30, 150));
      await gesture.down(const Offset(30, 150));
      await gesture.moveBy(const Offset(1000, 0));
      await tester.pump();
      await gesture.up();
      final result = (await tester.runAsync(
        () => controller.getCropperImage(),
      ))!;
      final bytes = (await tester.runAsync(
        () => result.toByteData(format: ui.ImageByteFormat.rawRgba),
      ))!;
      expect(pixelAt(bytes, 160, 80, 80), const Color(0xFF00FF00));
      result.dispose();
    });
  });
}
