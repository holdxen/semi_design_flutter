import 'package:example/pages/typography.dart';
import 'package:flutter/material.dart';
import 'package:semi_design_flutter/semi_design_flutter.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return SemiTheme(
      data: const SemiThemeData.light(),
      child: const MaterialApp(
        home: Scaffold(
          backgroundColor: Colors.white,
          body: SafeArea(child: TypographyPage()),
        ),
      ),
    );
  }
}
