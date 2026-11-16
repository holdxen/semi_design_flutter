// Smoke tests for the vendored dialog engine (flutter_smart_dialog 5.3.1
// fork — lib/src/overlay/dialog_engine, PROVENANCE.md): the engine binds to
// the navigator's ambient overlay with zero app-level init and drives
// show/dismiss/mask semantics that the SemiModal port will build on.
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:semi_design_flutter/semi_design_flutter.dart';
import 'package:semi_design_flutter/src/overlay/dialog_engine/flutter_smart_dialog.dart';
import 'package:semi_design_flutter/src/overlay/dialog_engine/helper/dialog_proxy.dart';

void main() {
  tearDown(DialogProxy.instance.resetForTest);

  testWidgets('SemiApp binds the engine zero-init; show/dismiss work on the '
      'ambient overlay', (tester) async {
    await tester.pumpWidget(const SemiApp(home: Text('home')));
    await tester.pump();
    expect(find.text('home'), findsOneWidget);

    // No app-level init: the SmartNavigatorObserver installed by SemiApp has
    // bound the engine to the navigator's overlay on the initial route push.
    SmartDialog.show<void>(
      useAnimation: false,
      clickMaskDismiss: true,
      builder: (_) => const Text('dialog-body'),
    ).ignore();
    await tester.pump();
    expect(find.text('dialog-body'), findsOneWidget);
    expect(SmartDialog.checkExist(), isTrue);

    // Clicking the mask dismisses (clickMaskDismiss).
    await tester.tapAt(const Offset(5, 5));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 250));
    expect(find.text('dialog-body'), findsNothing);
    expect(SmartDialog.checkExist(), isFalse);
  });

  testWidgets('dismiss returns the dialog result', (tester) async {
    await tester.pumpWidget(const SemiApp(home: Text('home')));
    await tester.pump();

    final result = SmartDialog.show<int>(
      useAnimation: false,
      builder: (_) => const Text('result-dialog'),
    );
    await tester.pump();
    expect(find.text('result-dialog'), findsOneWidget);

    final dismiss = SmartDialog.dismiss<int>(result: 42);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 250));
    await dismiss;
    expect(await result, 42);
    expect(find.text('result-dialog'), findsNothing);
  });

  testWidgets('manual bind works without SemiApp (escape hatch)', (
    tester,
  ) async {
    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: Overlay(
          initialEntries: [
            OverlayEntry(builder: (_) => const Text('bare-host')),
          ],
        ),
      ),
    );
    await tester.pump();
    DialogProxy.instance.bind(tester.state<OverlayState>(find.byType(Overlay)));

    SmartDialog.show<void>(
      useAnimation: false,
      builder: (_) => const Text('bound-dialog'),
    ).ignore();
    await tester.pump();
    expect(find.text('bound-dialog'), findsOneWidget);
    expect(find.text('bare-host'), findsOneWidget);

    final dismiss = SmartDialog.dismiss<void>();
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 250));
    await dismiss;
    expect(find.text('bound-dialog'), findsNothing);
  });
}
