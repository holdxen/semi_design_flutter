import 'package:flutter/widgets.dart';

import 'semi_theme_data.dart';

/// 为子树提供 Semi Design 主题，支持局部覆盖。
class SemiTheme extends InheritedTheme {
  const SemiTheme({super.key, required this.data, required super.child});

  final SemiThemeData data;

  /// 获取最近的主题并订阅变化；未提供主题时使用亮色主题。
  static SemiThemeData of(BuildContext context) {
    return maybeOf(context) ?? const SemiThemeData.light();
  }

  /// 获取最近的主题并订阅变化；未提供主题时返回 null。
  static SemiThemeData? maybeOf(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<SemiTheme>()?.data;
  }

  @override
  bool updateShouldNotify(SemiTheme oldWidget) {
    return data != oldWidget.data;
  }

  @override
  Widget wrap(BuildContext context, Widget child) {
    return SemiTheme(data: data, child: child);
  }
}
