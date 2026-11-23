// ---------------------------------------------------------------------------
// Port of monaco-editor/src/languages/definitions/freemarker2/register.ts
// Translated 1:1 from TypeScript. `registerLanguage({...})` calls and their
// literals are captured by evaluating the TS source. The dynamic
// `loader: () => import("./x")` becomes a static async reference to the
// batch40-generated `conf`/`language` data (same result, no async import).
// ---------------------------------------------------------------------------

import '../_.contribution.dart' show ILang, ILangImpl, registerLanguage;
import 'freemarker2.dart' as freemarker2;

/// 1:1: side-effect module — runs all `registerLanguage({...})` calls.
void register() {
  registerLanguage(ILang(
    id: 'freemarker2',
    extensions: <String>['.ftl', '.ftlh', '.ftlx'],
    aliases: <String>['FreeMarker2', 'Apache FreeMarker2'],
    loader: () async => ILangImpl(freemarker2.TagAutoInterpolationDollar.conf, freemarker2.TagAutoInterpolationDollar.language),
  ));
  registerLanguage(ILang(
    id: 'freemarker2.tag-angle.interpolation-dollar',
    aliases: <String>['FreeMarker2 (Angle/Dollar)', 'Apache FreeMarker2 (Angle/Dollar)'],
    loader: () async => ILangImpl(freemarker2.TagAngleInterpolationDollar.conf, freemarker2.TagAngleInterpolationDollar.language),
  ));
  registerLanguage(ILang(
    id: 'freemarker2.tag-bracket.interpolation-dollar',
    aliases: <String>['FreeMarker2 (Bracket/Dollar)', 'Apache FreeMarker2 (Bracket/Dollar)'],
    loader: () async => ILangImpl(freemarker2.TagBracketInterpolationDollar.conf, freemarker2.TagBracketInterpolationDollar.language),
  ));
  registerLanguage(ILang(
    id: 'freemarker2.tag-angle.interpolation-bracket',
    aliases: <String>['FreeMarker2 (Angle/Bracket)', 'Apache FreeMarker2 (Angle/Bracket)'],
    loader: () async => ILangImpl(freemarker2.TagAngleInterpolationBracket.conf, freemarker2.TagAngleInterpolationBracket.language),
  ));
  registerLanguage(ILang(
    id: 'freemarker2.tag-bracket.interpolation-bracket',
    aliases: <String>['FreeMarker2 (Bracket/Bracket)', 'Apache FreeMarker2 (Bracket/Bracket)'],
    loader: () async => ILangImpl(freemarker2.TagBracketInterpolationBracket.conf, freemarker2.TagBracketInterpolationBracket.language),
  ));
  registerLanguage(ILang(
    id: 'freemarker2.tag-auto.interpolation-dollar',
    aliases: <String>['FreeMarker2 (Auto/Dollar)', 'Apache FreeMarker2 (Auto/Dollar)'],
    loader: () async => ILangImpl(freemarker2.TagAutoInterpolationDollar.conf, freemarker2.TagAutoInterpolationDollar.language),
  ));
  registerLanguage(ILang(
    id: 'freemarker2.tag-auto.interpolation-bracket',
    aliases: <String>['FreeMarker2 (Auto/Bracket)', 'Apache FreeMarker2 (Auto/Bracket)'],
    loader: () async => ILangImpl(freemarker2.TagAutoInterpolationBracket.conf, freemarker2.TagAutoInterpolationBracket.language),
  ));
}
