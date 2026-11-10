import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:semi_design_flutter/semi_design_flutter.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  test('consumer loads all bundled package icons', () async {
    for (final icon in SemiIcons.values) {
      final source = await rootBundle.loadString(
        'packages/${icon.package}/${icon.asset}',
      );
      expect(source, contains('<svg'), reason: icon.name);
    }
  });
}
