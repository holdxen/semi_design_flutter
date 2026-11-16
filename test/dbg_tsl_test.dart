import 'dart:async';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:semi_design_flutter/semi_design_flutter.dart';

void main() {
  testWidgets('dbg', (tester) async {
    final gate = Completer<void>();
    await tester.binding.setSurfaceSize(const Size(1200, 1200));
    await tester.pumpWidget(
      SemiTheme(
        data: const SemiThemeData.light(),
        child: Directionality(
          textDirection: TextDirection.ltr,
          child: MediaQuery(
            data: const MediaQueryData(size: Size(1200, 900)),
            child: Overlay(
              initialEntries: [
                OverlayEntry(
                  builder: (context) => Center(
                    child: SizedBox(
                      width: 400,
                      height: 600,
                      child: SemiTreeSelect(
                        treeData: const [
                          SemiTreeNodeData(key: 'p', label: 'P'),
                        ],
                        motion: false,
                        loadData: (n) => gate.future,
                        onExpand: (k, e, n) {},
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.byType(SemiTreeSelect));
    await tester.pumpAndSettle();
    print('texts BEFORE: ${tester.allWidgets.whereType<Text>().map((t) => t.data).toList()}');
    print('spin BEFORE: ${find.byType(SemiSpin).evaluate().length}');
    final arrow = find.byKey(const ValueKey('treeSelect-expand-p'));
    await tester.tap(arrow);
    await tester.pump();
    print('texts AFTER: ${tester.allWidgets.whereType<Text>().map((t) => t.data).toList()}');
    print('spin AFTER: ${find.byType(SemiSpin).evaluate().length}');
    gate.complete();
    await tester.pumpAndSettle();
  });
}
