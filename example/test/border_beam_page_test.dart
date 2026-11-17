import 'package:example/pages/border_beam.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:semi_design_flutter/semi_design_flutter.dart';

void main() {
  testWidgets('BorderBeam gallery page renders', (tester) async {
    await tester.pumpWidget(const SemiApp(home: BorderBeamPage()));
    await tester.pump();
    expect(find.text('BorderBeam'), findsWidgets);
    expect(find.byKey(const ValueKey('border-beam-widget')), findsWidgets);
    expect(tester.takeException(), isNull);
  });
}
