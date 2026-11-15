import 'package:example/pages/breadcrumb.dart';
import 'package:flutter/widgets.dart';
import 'package:semi_design_flutter/semi_design_flutter.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const SemiApp(
      themeMode: SemiThemeMode.light,
      home: SafeArea(child: BreadcrumbPage()),
    );
  }
}
