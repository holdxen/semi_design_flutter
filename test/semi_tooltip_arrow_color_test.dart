import 'dart:ui' show Color;

import 'package:flutter_test/flutter_test.dart';
import 'package:semi_design_flutter/semi_design_flutter.dart';

void main() {
  test('arrow and icon colors follow a background-only override', () {
    // Upstream paints the arrow with the wrapper background so it reads as
    // part of the bubble; overriding only the bubble bg must recolor it.
    const base = SemiTooltipThemeData(colorTooltipBgDefault: Color(0xff7b61ff));
    final resolved = base.resolve(const SemiThemeData.light());
    expect(resolved.colorTooltipBgDefault, const Color(0xff7b61ff));
    expect(resolved.colorTooltipIconDefault, const Color(0xff7b61ff));
    expect(resolved.colorTooltipArrowIconDefault, const Color(0xff7b61ff));
  });

  test('explicit arrow and icon overrides win over the background', () {
    const patch = SemiTooltipThemeData(
      colorTooltipBgDefault: Color(0xff7b61ff),
      colorTooltipIconDefault: Color(0xff00ff00),
      colorTooltipArrowIconDefault: Color(0xffff0000),
    );
    final resolved = patch.resolve(const SemiThemeData.light());
    expect(resolved.colorTooltipIconDefault, const Color(0xff00ff00));
    expect(resolved.colorTooltipArrowIconDefault, const Color(0xffff0000));

    // Arrow defaults through icon when only icon is overridden.
    const viaIcon = SemiTooltipThemeData(
      colorTooltipBgDefault: Color(0xff7b61ff),
      colorTooltipIconDefault: Color(0xff00ff00),
    );
    expect(
      viaIcon.resolve(const SemiThemeData.light()).colorTooltipArrowIconDefault,
      const Color(0xff00ff00),
    );
  });
}
