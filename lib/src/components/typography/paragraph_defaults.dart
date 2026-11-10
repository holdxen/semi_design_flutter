import 'package:flutter/widgets.dart';

/// Internal defaults shared by paragraph composition and the text renderer.
class SemiParagraphDefaults extends InheritedWidget {
  const SemiParagraphDefaults({
    super.key,
    required this.regularWeight,
    required this.extendedLineHeight,
    required super.child,
  });

  final FontWeight regularWeight;
  final double? extendedLineHeight;

  static SemiParagraphDefaults? of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<SemiParagraphDefaults>();

  @override
  bool updateShouldNotify(SemiParagraphDefaults oldWidget) =>
      regularWeight != oldWidget.regularWeight ||
      extendedLineHeight != oldWidget.extendedLineHeight;
}
