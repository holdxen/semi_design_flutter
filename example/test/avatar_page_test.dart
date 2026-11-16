import 'dart:ui' as ui;

import 'package:example/pages/avatar.dart';
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

Future<void> start(WidgetTester tester) async {
  addTearDown(() async => tester.pumpWidget(const SizedBox.shrink()));
  await tester.binding.setSurfaceSize(const Size(1200, 2400));
  await tester.pumpWidget(
    SemiApp(home: AvatarPage(avatarImage: _TestImageProvider(sampleImage))),
  );
  await tester.pump(const Duration(milliseconds: 60));
}

void main() {
  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    canvas.drawRect(
      const Rect.fromLTWH(0, 0, 60, 60),
      Paint()..color = const Color(0xFFFF0000),
    );
    sampleImage = await recorder.endRecording().toImage(60, 60);
  });

  testWidgets('page renders every demo section', (tester) async {
    await start(tester);
    for (final title in [
      '基础用法',
      '尺寸与形状',
      '颜色',
      '交互',
      '描边环与动效',
      'Slot',
      '头像组',
    ]) {
      expect(find.text(title), findsOneWidget);
      await tester.ensureVisible(find.text(title));
      await tester.pump(const Duration(milliseconds: 100));
      expect(tester.takeException(), isNull);
    }
    expect(find.byType(SemiAvatar), findsWidgets);
    expect(find.byType(SemiAvatarGroup), findsNWidgets(3));
  });

  testWidgets('image avatars render with cover', (tester) async {
    await start(tester);
    await tester.ensureVisible(find.text('图片头像（object-fit: cover；加载失败回落文字）'));
    await tester.pump(const Duration(milliseconds: 100));
    final images = find.byType(Image);
    expect(images, findsNWidgets(2));
    for (final image in tester.widgetList<Image>(images)) {
      expect(image.fit, BoxFit.cover);
    }
  });

  testWidgets('size swatch renders at the Sass sizes', (tester) async {
    await start(tester);
    await tester.ensureVisible(find.text('尺寸与形状'));
    await tester.pump(const Duration(milliseconds: 100));
    final avatars = find.descendant(
      of: keyed('avatar-sizes'),
      matching: find.byType(SemiAvatar),
    );
    expect(avatars, findsNWidgets(8));
    final sizes = [for (var i = 0; i < 7; i++) tester.getSize(avatars.at(i))];
    expect(sizes, const [
      Size(20, 20),
      Size(24, 24),
      Size(32, 32),
      Size(40, 40),
      Size(48, 48),
      Size(72, 72),
      Size(128, 128),
    ]);
    expect(tester.getSize(avatars.at(7)), const Size(72, 72));
  });

  testWidgets('color swatch covers 16 colors plus white', (tester) async {
    await start(tester);
    await tester.ensureVisible(find.text('颜色'));
    await tester.pump(const Duration(milliseconds: 100));
    expect(
      find.descendant(
        of: keyed('avatar-colors'),
        matching: find.byType(SemiAvatar),
      ),
      findsNWidgets(17),
    );
  });

  testWidgets('tap counter increments on click', (tester) async {
    await start(tester);
    await tester.ensureVisible(keyed('avatar-tap'));
    await tester.pump(const Duration(milliseconds: 100));
    expect(find.text('点击次数：0'), findsOneWidget);
    await tester.tap(keyed('avatar-tap'));
    await tester.pump();
    expect(find.text('点击次数：1'), findsOneWidget);
  });

  testWidgets('group toggle flips the overlap direction', (tester) async {
    await start(tester);
    await tester.ensureVisible(keyed('avatar-group'));
    await tester.pump(const Duration(milliseconds: 100));
    expect(
      tester.widget<SemiAvatarGroup>(keyed('avatar-group')).overlapFrom,
      SemiAvatarOverlapFrom.start,
    );
    await tester.ensureVisible(keyed('avatar-group-toggle'));
    await tester.tap(keyed('avatar-group-toggle'));
    await tester.pump();
    expect(
      tester.widget<SemiAvatarGroup>(keyed('avatar-group')).overlapFrom,
      SemiAvatarOverlapFrom.end,
    );
  });

  testWidgets('maxCount folds into +N and renderMore replaces it', (
    tester,
  ) async {
    await start(tester);
    await tester.ensureVisible(find.text('maxCount 折叠 +N'));
    await tester.pump(const Duration(milliseconds: 100));
    final maxGroup = find.byWidgetPredicate(
      (w) => w is SemiAvatarGroup && w.maxCount == 2,
    );
    expect(
      find.descendant(of: maxGroup, matching: find.text('+2')),
      findsOneWidget,
    );
    expect(
      find.descendant(of: maxGroup, matching: find.text('D')),
      findsNothing,
    );
    final customGroup = find.byWidgetPredicate(
      (w) => w is SemiAvatarGroup && w.renderMore != null,
    );
    expect(
      find.descendant(of: customGroup, matching: find.text('更多 2')),
      findsOneWidget,
    );
  });
}
