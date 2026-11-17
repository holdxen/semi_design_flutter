// Behavior matrix for SemiImage / SemiImagePreview / SemiImagePreviewInner
// (52 = 44 FIELDS + 8 MOTION + 0 INTERNAL; 73 HARDCODES anchors live in the
// widget's file-level note block / call sites; 8 dead variables stay
// unconsumed). See docs/semi_image.md.
import 'dart:async';
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:semi_design_flutter/semi_design_flutter.dart';

Widget host(Widget child) => SemiTheme(
  data: const SemiThemeData.light(),
  child: Directionality(
    textDirection: TextDirection.ltr,
    child: Overlay(
      initialEntries: [
        OverlayEntry(
          builder: (context) => Align(
            alignment: Alignment.topLeft,
            child: SizedBox(
              width: 800,
              height: 600,
              child: Align(alignment: Alignment.topLeft, child: child),
            ),
          ),
        ),
      ],
    ),
  ),
);

int _hostSeq = 0;

Future<void> pumpHost(WidgetTester tester, Widget child) async {
  addTearDown(() async => tester.pumpWidget(const SizedBox.shrink()));
  await tester.binding.setSurfaceSize(const Size(800, 600));
  // 每次 pump 换新 key：Overlay 的 initialEntries 只在首建生效，换根子树
  // 保证入口与组件状态都是新树。
  await tester.pumpWidget(
    KeyedSubtree(key: ValueKey('host-${_hostSeq++}'), child: host(child)),
  );
}

late ui.Image _image;

/// 同步成功的 provider（fake async 内即刻出图，见 avatar_page_test 先例）。
class _TestImage extends ImageProvider<_TestImage> {
  const _TestImage(this.id);
  final int id;
  @override
  Future<_TestImage> obtainKey(ImageConfiguration configuration) =>
      SynchronousFuture(this);
  @override
  ImageStreamCompleter loadImage(_TestImage key, ImageDecoderCallback decode) =>
      OneFrameImageStreamCompleter(SynchronousFuture(ImageInfo(image: _image)));
  @override
  bool operator ==(Object other) => other is _TestImage && other.id == id;
  @override
  int get hashCode => id.hashCode;
}

/// 加载必然失败的 provider。
class _FailingImage extends ImageProvider<_FailingImage> {
  const _FailingImage();
  @override
  Future<_FailingImage> obtainKey(ImageConfiguration configuration) =>
      SynchronousFuture(this);
  @override
  ImageStreamCompleter loadImage(
    _FailingImage key,
    ImageDecoderCallback decode,
  ) => OneFrameImageStreamCompleter(
    Future<ImageInfo>.error(Exception('image load fail')),
  );
}

/// 永不完成的 provider（停在 loading）。
class _PendingImage extends ImageProvider<_PendingImage> {
  const _PendingImage();
  @override
  Future<_PendingImage> obtainKey(ImageConfiguration configuration) =>
      SynchronousFuture(this);
  @override
  ImageStreamCompleter loadImage(
    _PendingImage key,
    ImageDecoderCallback decode,
  ) => OneFrameImageStreamCompleter(Completer<ImageInfo>().future);
}

Finder iconOf(SemiIconData data) =>
    find.byWidgetPredicate((w) => w is SemiIcon && w.data == data);

Future<void> tapIcon(WidgetTester tester, SemiIconData data) async {
  await tester.tap(iconOf(data));
  await tester.pump();
}

void main() {
  setUpAll(() async {
    final recorder = ui.PictureRecorder();
    Canvas(recorder).drawRect(
      const Rect.fromLTWH(0, 0, 20, 20),
      Paint()..color = const Color(0xff3366ff),
    );
    _image = recorder.endRecording().toImageSync(20, 20);
  });

  group('load state machine', () {
    testWidgets('loading shows the default skeleton and custom placeholder', (
      tester,
    ) async {
      await pumpHost(tester, const SemiImage(image: _PendingImage()));
      expect(find.byType(SemiSkeletonImage), findsOneWidget);
      await pumpHost(
        tester,
        const SemiImage(image: _PendingImage(), placeholder: Text('loading…')),
      );
      expect(find.text('loading…'), findsOneWidget);
      expect(find.byType(SemiSkeletonImage), findsNothing);
    });

    testWidgets('error shows the default icon and custom fallback', (
      tester,
    ) async {
      await pumpHost(tester, const SemiImage(image: _FailingImage()));
      await tester.pump();
      expect(iconOf(SemiIcons.uploadError), findsOneWidget);
      await pumpHost(
        tester,
        const SemiImage(image: _FailingImage(), fallback: Text('failed')),
      );
      await tester.pump();
      expect(find.text('failed'), findsOneWidget);
    });

    testWidgets('onLoad and onError fire exactly once per resolve', (
      tester,
    ) async {
      var loads = 0, errors = 0;
      await pumpHost(
        tester,
        SemiImage(
          image: const _TestImage(1),
          onLoad: () => loads++,
          onError: () => errors++,
        ),
      );
      await tester.pump();
      expect(loads, 1);
      expect(errors, 0);
      await pumpHost(
        tester,
        SemiImage(
          image: const _FailingImage(),
          onLoad: () => loads++,
          onError: () => errors++,
        ),
      );
      await tester.pump();
      expect(errors, 1);
    });

    testWidgets('switching src resets the state machine to loading', (
      tester,
    ) async {
      await pumpHost(tester, const SemiImage(image: _TestImage(1)));
      await tester.pump();
      expect(find.byType(SemiSkeletonImage), findsNothing);
      await pumpHost(tester, const SemiImage(image: _PendingImage()));
      expect(find.byType(SemiSkeletonImage), findsOneWidget);
    });
  });

  group('preview open and close', () {
    testWidgets('click opens the layer, Esc closes it (closeOnEsc)', (
      tester,
    ) async {
      var closed = 0;
      await pumpHost(
        tester,
        SemiImage(
          image: const _TestImage(1),
          previewProps: SemiImagePreviewProps(
            initialZoom: 1,
            onClose: () => closed++,
          ),
        ),
      );
      await tester.pump();
      await tester.tap(find.byType(SemiImage));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      expect(find.text('1/1'), findsOneWidget);
      await tester.sendKeyEvent(LogicalKeyboardKey.escape);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      expect(find.text('1/1'), findsNothing);
      expect(closed, 1);
    });

    testWidgets('mask click closes when the press drift is within 5px', (
      tester,
    ) async {
      await pumpHost(
        tester,
        SemiImage(
          image: const _TestImage(1),
          previewProps: const SemiImagePreviewProps(initialZoom: 1),
        ),
      );
      await tester.pump();
      await tester.tap(find.byType(SemiImage));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      expect(find.text('1/1'), findsOneWidget);
      // 画布区点击（非 icon/footer）→ 关闭。
      await tester.tapAt(const Offset(400, 200));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      expect(find.text('1/1'), findsNothing);
    });

    testWidgets('maskClosable false keeps the layer open on mask click', (
      tester,
    ) async {
      await pumpHost(
        tester,
        SemiImage(
          image: const _TestImage(1),
          previewProps: const SemiImagePreviewProps(
            initialZoom: 1,
            maskClosable: false,
          ),
        ),
      );
      await tester.pump();
      await tester.tap(find.byType(SemiImage));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      await tester.tapAt(const Offset(400, 200));
      await tester.pump();
      expect(find.text('1/1'), findsOneWidget);
    });

    testWidgets('click does not open before the image succeeds', (
      tester,
    ) async {
      await pumpHost(tester, const SemiImage(image: _PendingImage()));
      await tester.tap(find.byType(SemiImage));
      await tester.pump();
      expect(find.text('1/1'), findsNothing);
    });
  });

  group('gallery navigation', () {
    Future<void> openThree(
      WidgetTester tester, {
      required bool infinite,
    }) async {
      await pumpHost(
        tester,
        SemiImage(
          image: const _TestImage(1),
          previewProps: SemiImagePreviewProps(
            initialZoom: 1,
            infinite: infinite,
            src: const [_TestImage(1), _TestImage(2), _TestImage(3)],
          ),
        ),
      );
      await tester.pump();
      await tester.tap(find.byType(SemiImage));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
    }

    testWidgets('prev/next advance and hide at the ends without infinite', (
      tester,
    ) async {
      await openThree(tester, infinite: false);
      expect(find.text('1/3'), findsOneWidget);
      // `total !== 1 && (infinite || currentIndex !== 0)`：首张无 prev。
      expect(iconOf(SemiIcons.arrowLeft), findsNothing);
      await tapIcon(tester, SemiIcons.arrowRight);
      expect(find.text('2/3'), findsOneWidget);
      await tapIcon(tester, SemiIcons.arrowRight);
      expect(find.text('3/3'), findsOneWidget);
      expect(iconOf(SemiIcons.arrowRight), findsNothing);
      await tapIcon(tester, SemiIcons.arrowLeft);
      expect(find.text('2/3'), findsOneWidget);
    });

    testWidgets('infinite wraps around with onPrev/onNext callbacks', (
      tester,
    ) async {
      final indices = <int>[];
      await pumpHost(
        tester,
        SemiImage(
          image: const _TestImage(1),
          previewProps: SemiImagePreviewProps(
            initialZoom: 1,
            infinite: true,
            src: const [_TestImage(1), _TestImage(2), _TestImage(3)],
            onChange: indices.add,
          ),
        ),
      );
      await tester.pump();
      await tester.tap(find.byType(SemiImage));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      await tapIcon(tester, SemiIcons.arrowLeft);
      expect(find.text('3/3'), findsOneWidget);
      await tapIcon(tester, SemiIcons.arrowRight);
      expect(find.text('1/3'), findsOneWidget);
      expect(indices, [2, 0]);
    });

    testWidgets('group opens the clicked child at its scanned index', (
      tester,
    ) async {
      await pumpHost(
        tester,
        SemiImagePreview(
          props: const SemiImagePreviewProps(initialZoom: 1),
          children: const [
            SemiImage(image: _TestImage(1)),
            SemiImage(image: _TestImage(2)),
            SemiImage(image: _TestImage(3)),
          ],
        ),
      );
      await tester.pump();
      await tester.tap(find.byType(SemiImage).at(1));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      expect(find.text('2/3'), findsOneWidget);
    });
  });

  group('zoom, rotate, ratio and download', () {
    Future<void> openOne(
      WidgetTester tester, {
      SemiImagePreviewProps props = const SemiImagePreviewProps(initialZoom: 1),
      void Function()? onLoad,
    }) async {
      await pumpHost(
        tester,
        SemiImage(
          image: const _TestImage(1),
          onLoad: onLoad,
          previewProps: props,
        ),
      );
      await tester.pump();
      await tester.tap(find.byType(SemiImage));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
    }

    testWidgets('plus/minus step the zoom and clamp at minZoom', (
      tester,
    ) async {
      final zooms = <double>[];
      await openOne(
        tester,
        props: SemiImagePreviewProps(initialZoom: 1, onZoomIn: zooms.add),
      );
      await tapIcon(tester, SemiIcons.plus);
      // zoomStep 0.1 → 1.1（`toFixed(2)`）。
      expect(zooms, [1.1]);

      final outs = <double>[];
      await openOne(
        tester,
        props: SemiImagePreviewProps(
          initialZoom: 1,
          onZoomOut: outs.add,
          onZoomIn: zooms.add,
        ),
      );
      for (var i = 0; i < 12; i++) {
        await tapIcon(tester, SemiIcons.minus);
      }
      // `Math.min(max, Math.max(min, zoom))` 钳制在 minZoom 0.1。
      expect(outs.last, 0.1);
    });

    testWidgets('rotate steps 90 degrees per tap (ROTATE_STEP = 90)', (
      tester,
    ) async {
      final angles = <double>[];
      await openOne(
        tester,
        props: SemiImagePreviewProps(initialZoom: 1, onRotateLeft: angles.add),
      );
      await tapIcon(tester, SemiIcons.rotate);
      expect(angles, [-90]);
    });

    testWidgets('ratio toggle alternates adaptation/realSize', (tester) async {
      final ratios = <SemiImageRatioType>[];
      await openOne(
        tester,
        props: SemiImagePreviewProps(initialZoom: 1, onRatioChange: ratios.add),
      );
      await tapIcon(tester, SemiIcons.realSizeStroked);
      await tapIcon(tester, SemiIcons.windowAdaptionStroked);
      expect(ratios, [
        SemiImageRatioType.realSize,
        SemiImageRatioType.adaptation,
      ]);
    });

    testWidgets('download fires with the current image and index', (
      tester,
    ) async {
      final downloads = <(ImageProvider, int)>[];
      await openOne(
        tester,
        props: SemiImagePreviewProps(
          initialZoom: 1,
          src: const [_TestImage(1), _TestImage(2)],
          onDownload: (src, index) => downloads.add((src, index)),
        ),
      );
      await tapIcon(tester, SemiIcons.arrowRight);
      await tapIcon(tester, SemiIcons.download);
      expect(downloads, [(const _TestImage(2), 1)]);
    });

    testWidgets('disableDownload disables the download button', (tester) async {
      var downloads = 0;
      await openOne(
        tester,
        props: SemiImagePreviewProps(
          initialZoom: 1,
          disableDownload: true,
          onDownload: (src, index) => downloads++,
        ),
      );
      await tester.tap(iconOf(SemiIcons.download), warnIfMissed: false);
      await tester.pump();
      expect(downloads, 0);
    });

    testWidgets('showTooltip wraps footer controls in SemiTooltip', (
      tester,
    ) async {
      await openOne(
        tester,
        props: const SemiImagePreviewProps(initialZoom: 1, showTooltip: true),
      );
      expect(find.byType(SemiTooltip), findsWidgets);
    });
  });

  group('chrome auto-hide', () {
    testWidgets('chrome hides after viewerVisibleDelay and returns on move', (
      tester,
    ) async {
      await pumpHost(
        tester,
        SemiImage(
          image: const _TestImage(1),
          previewProps: const SemiImagePreviewProps(
            initialZoom: 1,
            viewerVisibleDelay: 100,
          ),
        ),
      );
      await tester.pump();
      await tester.tap(find.byType(SemiImage));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      bool hidden() => tester
          .widgetList<AnimatedOpacity>(find.byType(AnimatedOpacity))
          .any((w) => w.opacity == 0);
      await tester.pump(const Duration(milliseconds: 150));
      expect(hidden(), isTrue);
      final mouse = await tester.createGesture(kind: PointerDeviceKind.mouse);
      await mouse.addPointer(location: const Offset(400, 200));
      await tester.pump();
      await mouse.moveTo(const Offset(390, 210));
      await tester.pump();
      expect(hidden(), isFalse);
    });
  });

  group('footer slider', () {
    testWidgets('slider reports percent value and taps adjust zoom', (
      tester,
    ) async {
      final zooms = <double>[];
      await pumpHost(
        tester,
        SemiImage(
          image: const _TestImage(1),
          previewProps: SemiImagePreviewProps(
            initialZoom: 1,
            onZoomIn: zooms.add,
            onZoomOut: zooms.add,
          ),
        ),
      );
      await tester.pump();
      await tester.tap(find.byType(SemiImage));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      final slider = find.byWidgetPredicate(
        (w) => w is Semantics && w.properties.slider == true,
      );
      expect(slider, findsOneWidget);
      // `${v}%` 语义值。
      final semantics = tester.getSemantics(slider);
      expect(semantics.value, isNotEmpty);
    });

    testWidgets('dividers land after chevronRight and between ratio/rotate', (
      tester,
    ) async {
      await pumpHost(
        tester,
        SemiImage(
          image: const _TestImage(1),
          previewProps: const SemiImagePreviewProps(initialZoom: 1),
        ),
      );
      await tester.pump();
      await tester.tap(find.byType(SemiImage));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      // `menuItems.splice(3, 0` / `menuItems.splice(8, 0`：分隔线落
      // chevronRight 后与 比例/旋转 之间（下载仅 -gap，无分隔线）。
      final dividers = find.byWidgetPredicate(
        (w) => w is Container && w.constraints?.maxWidth == 1,
      );
      expect(dividers, findsNWidgets(2));
      final xChevronR = tester.getCenter(iconOf(SemiIcons.chevronRight)).dx;
      final xMinus = tester.getCenter(iconOf(SemiIcons.minus)).dx;
      final xRatio = tester
          .getCenter(
            find.byWidgetPredicate(
              (w) =>
                  w is SemiIcon &&
                  (w.data == SemiIcons.realSizeStroked ||
                      w.data == SemiIcons.windowAdaptionStroked),
            ),
          )
          .dx;
      final xRotate = tester.getCenter(iconOf(SemiIcons.rotate)).dx;
      final xs =
          tester
              .widgetList<Container>(dividers)
              .map((w) => tester.getCenter(find.byWidget(w)).dx)
              .toList()
            ..sort();
      expect(xs[0], greaterThan(xChevronR));
      expect(xs[0], lessThan(xMinus));
      expect(xs[1], greaterThan(xRatio));
      expect(xs[1], lessThan(xRotate));
    });
  });

  group('theme and group context', () {
    testWidgets('local SemiImageTheme patch changes the image radius', (
      tester,
    ) async {
      await pumpHost(
        tester,
        SemiImageTheme(
          data: const SemiImageThemeData(radiusImage: 12),
          child: const SemiImage(image: _TestImage(1)),
        ),
      );
      await tester.pump();
      final box = tester.widget<DecoratedBox>(
        find.descendant(
          of: find.byType(SemiImage),
          matching: find.byType(DecoratedBox),
        ),
      );
      final decoration = box.decoration as BoxDecoration;
      expect(decoration.borderRadius, BorderRadius.circular(12));
    });

    testWidgets('group titles override previewTitle (titles[currentIndex])', (
      tester,
    ) async {
      await pumpHost(
        tester,
        SemiImagePreview(
          props: const SemiImagePreviewProps(initialZoom: 1),
          children: const [
            SemiImage(
              image: _TestImage(1),
              previewProps: SemiImagePreviewProps(previewTitle: Text('一')),
            ),
            SemiImage(image: _TestImage(2)),
          ],
        ),
      );
      await tester.pump();
      await tester.tap(find.byType(SemiImage).at(1));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      expect(find.text('一'), findsNothing);
      await tapIcon(tester, SemiIcons.arrowLeft);
      expect(find.text('一'), findsOneWidget);
    });
  });
}
