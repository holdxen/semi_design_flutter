import 'package:flutter/widgets.dart';

import '../components/icon/semi_icon_data.dart';

@immutable
class SemiIconThemeData {
  const SemiIconThemeData({this.color, this.size, this.customSize})
    : assert(
        customSize == null || (customSize > 0 && customSize < double.infinity),
      );
  final Color? color;
  final SemiIconSize? size;
  final double? customSize;
  SemiIconThemeData copyWith({
    Color? color,
    SemiIconSize? size,
    double? customSize,
  }) => SemiIconThemeData(
    color: color ?? this.color,
    size: size ?? this.size,
    customSize: customSize ?? this.customSize,
  );
  SemiIconThemeData merge(SemiIconThemeData? other) => other == null
      ? this
      : copyWith(
          color: other.color,
          size: other.size,
          customSize: other.customSize,
        );
  @override
  bool operator ==(Object other) =>
      other is SemiIconThemeData &&
      color == other.color &&
      size == other.size &&
      customSize == other.customSize;
  @override
  int get hashCode => Object.hash(color, size, customSize);
}

/// Local patches inherit live ancestor values and participate in theme capture.
class SemiIconTheme extends InheritedTheme {
  const SemiIconTheme({super.key, required this.data, required super.child});
  final SemiIconThemeData data;
  static SemiIconThemeData of(BuildContext context) {
    final patches = <SemiIconThemeData>[];
    context.visitAncestorElements((element) {
      if (element.widget is SemiIconTheme) {
        context.dependOnInheritedElement(element as InheritedElement);
        patches.add((element.widget as SemiIconTheme).data);
      }
      return true;
    });
    return patches.reversed.fold(
      const SemiIconThemeData(),
      (base, patch) => base.merge(patch),
    );
  }

  static SemiIconThemeData? maybeOf(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<SemiIconTheme>() == null
      ? null
      : of(context);
  @override
  bool updateShouldNotify(SemiIconTheme oldWidget) => data != oldWidget.data;
  @override
  Widget wrap(BuildContext context, Widget child) =>
      SemiIconTheme(data: of(context).merge(data), child: child);
}
