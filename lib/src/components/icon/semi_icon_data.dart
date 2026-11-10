import 'package:flutter/foundation.dart';

/// Constant package asset descriptor, rather than an individual widget class.
@immutable
class SemiIconData {
  const SemiIconData(this.name);
  final String name;
  String get asset => 'assets/icons/$name.svg';
  String get package => 'semi_design_flutter';
  @override
  bool operator ==(Object other) => other is SemiIconData && name == other.name;
  @override
  int get hashCode => name.hashCode;
}

enum SemiIconSize { extraSmall, small, normal, large, extraLarge, inherit }
