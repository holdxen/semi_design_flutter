// ---------------------------------------------------------------------------
// Port of monaco-editor/src/languages/definitions/html/register.ts
// Translated 1:1 from TypeScript. `registerLanguage({...})` calls and their
// literals are captured by evaluating the TS source. The dynamic
// `loader: () => import("./x")` becomes a static async reference to the
// batch40-generated `conf`/`language` data (same result, no async import).
// ---------------------------------------------------------------------------

import '../_.contribution.dart' show ILang, ILangImpl, registerLanguage;
import 'html.dart' as html;

/// 1:1: side-effect module — runs all `registerLanguage({...})` calls.
void register() {
  registerLanguage(ILang(
    id: 'html',
    extensions: <String>['.html', '.htm', '.shtml', '.xhtml', '.mdoc', '.jsp', '.asp', '.aspx', '.jshtm'],
    aliases: <String>['HTML', 'htm', 'html', 'xhtml'],
    mimetypes: <String>['text/html', 'text/x-jshtm', 'text/template', 'text/ng-template'],
    loader: () async => ILangImpl(html.conf, html.language),
  ));
}
