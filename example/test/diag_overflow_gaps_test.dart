// 临时诊断：输出 OverflowList 示例各 item 的几何位置与间隔。用完即删。
import 'package:example/pages/overflow_list.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:semi_design_flutter/semi_design_flutter.dart';

void main() {
  testWidgets('diag gaps', (tester) async {
    tester.view.physicalSize = const Size(1200, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(() async => tester.pumpWidget(const SizedBox.shrink()));
    await tester.pumpWidget(const SemiApp(home: OverflowListPage()));
    await tester.pumpAndSettle();

    for (final key in [
      'overflow-basic',
      'overflow-from-start',
      'overflow-min-visible',
      'overflow-scroll',
    ]) {
      final scope = find.byKey(ValueKey(key));
      expect(scope, findsOneWidget, reason: key);
      final texts = find.descendant(
        of: scope,
        matching: find.byType(Text),
      );
      final rects = <String, Rect>{};
      for (final t in ['alarm', 'bookmark', 'camera', 'duration', 'edit', 'folder']) {
        final f = find.descendant(of: scope, matching: find.text(t));
        if (f.evaluate().isNotEmpty) {
          final tag = find.ancestor(of: f, matching: find.byType(SemiTag));
          rects[t] = tester.getRect(tag.first);
        }
      }
      final plus = find.descendant(
        of: scope,
        matching: find.textContaining('+'),
      );
      debugPrint('=== $key ===');
      final keys = rects.keys.toList();
      for (var i = 0; i < keys.length; i++) {
        final r = rects[keys[i]]!;
        final gap = i == 0
            ? null
            : r.left - rects[keys[i - 1]]!.right;
        debugPrint(
          '${keys[i]}: left=${r.left.toStringAsFixed(1)} '
          'right=${r.right.toStringAsFixed(1)} gapBefore=${gap?.toStringAsFixed(1)}',
        );
      }
      if (plus.evaluate().isNotEmpty) {
        final pr = tester.getRect(plus.first);
        final last = keys.isEmpty ? null : rects[keys.last]!.right;
        debugPrint(
          '+N: left=${pr.left.toStringAsFixed(1)} '
          'gapBefore=${last == null ? 'n/a' : (pr.left - last).toStringAsFixed(1)}',
        );
      }
      debugPrint('texts found: ${texts.evaluate().length}');
    }
  });
}
