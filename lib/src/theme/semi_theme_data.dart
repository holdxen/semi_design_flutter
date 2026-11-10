import '../tokens/semi_palette.dart';
import '../tokens/colors.dart';
import '../tokens/radius.dart';
import '../tokens/shadows.dart';
import '../tokens/motion.dart';
import '../tokens/button_tokens.dart';
import '../tokens/tooltip_tokens.dart';

class SemiThemeData {
  const SemiThemeData.light() : dark = false;
  const SemiThemeData.dark() : dark = true;
  final bool dark;
  SemiPalette get palette => SemiPalette(dark: dark);
  SemiColors get colors => SemiColors(dark: dark);
  SemiRadius get radius => SemiRadius(dark: dark);
  SemiShadowTokens get shadows => SemiShadowTokens(dark: dark);
  SemiMotion get motion => SemiMotion(dark: dark);
  SemiButtonTokens get button => SemiButtonTokens(dark: dark);
  SemiTooltipTokens get tooltip => SemiTooltipTokens(dark: dark);
}
