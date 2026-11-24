// ---------------------------------------------------------------------------
// Port of vscode/src/vs/editor/common/config/fontInfoFromSettings.ts @bfbf12b
// Translated 1:1 from TypeScript. Do not refactor.
//
// Adaptations (documented inline):
//  * The TS `{ fontFamily?, fontWeight?, ... }` object literal accepted by
//    `createBareFontInfoFromRawSettings` is carried by the value class
//    `RawFontSettingsOptions` (all fields nullable; null == TS `undefined`).
//  * `EditorOption.*` ids are `static const int` in the Dart port of
//    `editorOptions.ts`; `IValidatedEditorOptions.get(Object id)` accepts them.
//  * `BareFontInfo._create` is `@internal` in TS; its public Dart counterpart
//    `BareFontInfo.create` is used (same precedent as other internal APIs).
//  * `EditorOption<num>.validate` results are widened with `.toDouble()` to
//    match `BareFontInfo.create`'s `double` parameters (JS has one number type).
// ---------------------------------------------------------------------------
import 'editorOptions.dart' show EditorOption, EditorOptions;
import 'fontInfo.dart' show BareFontInfo, IValidatedEditorOptions;

/// 1:1: the inline `{ fontFamily?, fontWeight?, fontSize?, fontLigatures?,
/// fontVariations?, lineHeight?, letterSpacing? }` parameter object accepted
/// by [createBareFontInfoFromRawSettings]. `null` carries TS `undefined`.
class RawFontSettingsOptions {
  const RawFontSettingsOptions({
    this.fontFamily,
    this.fontWeight,
    this.fontSize,
    this.fontLigatures,
    this.fontVariations,
    this.lineHeight,
    this.letterSpacing,
  });

  final Object? fontFamily;
  final Object? fontWeight;
  final Object? fontSize;
  final Object? fontLigatures;
  final Object? fontVariations;
  final Object? lineHeight;
  final Object? letterSpacing;
}

/// 1:1: `createBareFontInfoFromValidatedSettings`.
BareFontInfo createBareFontInfoFromValidatedSettings(
  IValidatedEditorOptions options,
  double pixelRatio,
  bool ignoreEditorZoom,
) {
  final String fontFamily = options.get(EditorOption.fontFamily) as String;
  final String fontWeight = options.get(EditorOption.fontWeight) as String;
  final double fontSize =
      (options.get(EditorOption.fontSize) as num).toDouble();
  final String fontFeatureSettings =
      options.get(EditorOption.fontLigatures) as String;
  final String fontVariationSettings =
      options.get(EditorOption.fontVariations) as String;
  final double lineHeight =
      (options.get(EditorOption.lineHeight) as num).toDouble();
  final double letterSpacing =
      (options.get(EditorOption.letterSpacing) as num).toDouble();
  return BareFontInfo.create(
    fontFamily,
    fontWeight,
    fontSize,
    fontFeatureSettings,
    fontVariationSettings,
    lineHeight,
    letterSpacing,
    pixelRatio,
    ignoreEditorZoom,
  );
}

/// 1:1: `createBareFontInfoFromRawSettings`.
BareFontInfo createBareFontInfoFromRawSettings(
  RawFontSettingsOptions opts,
  double pixelRatio, [
  bool ignoreEditorZoom = false,
]) {
  final String fontFamily = EditorOptions.fontFamily.validate(opts.fontFamily);
  final String fontWeight = EditorOptions.fontWeight.validate(opts.fontWeight);
  final double fontSize =
      EditorOptions.fontSize.validate(opts.fontSize).toDouble();
  final String fontFeatureSettings =
      EditorOptions.fontLigatures2.validate(opts.fontLigatures);
  final String fontVariationSettings =
      EditorOptions.fontVariations.validate(opts.fontVariations);
  final double lineHeight =
      EditorOptions.lineHeight.validate(opts.lineHeight).toDouble();
  final double letterSpacing =
      EditorOptions.letterSpacing.validate(opts.letterSpacing).toDouble();
  return BareFontInfo.create(
    fontFamily,
    fontWeight,
    fontSize,
    fontFeatureSettings,
    fontVariationSettings,
    lineHeight,
    letterSpacing,
    pixelRatio,
    ignoreEditorZoom,
  );
}
