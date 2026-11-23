// ---------------------------------------------------------------------------
// Port of monaco-editor/src/languages/definitions/xml/register.ts
// Translated 1:1 from TypeScript. `registerLanguage({...})` calls and their
// literals are captured by evaluating the TS source. The dynamic
// `loader: () => import("./x")` becomes a static async reference to the
// batch40-generated `conf`/`language` data (same result, no async import).
// ---------------------------------------------------------------------------

import '../_.contribution.dart' show ILang, ILangImpl, registerLanguage;
import 'xml.dart' as xml;

/// 1:1: side-effect module — runs all `registerLanguage({...})` calls.
void register() {
  registerLanguage(ILang(
    id: 'xml',
    extensions: <String>['.xml', '.xsd', '.dtd', '.ascx', '.csproj', '.config', '.props', '.targets', '.wxi', '.wxl', '.wxs', '.xaml', '.svg', '.svgz', '.opf', '.xslt', '.xsl'],
    firstLine: '(\\<\\?xml.*)|(\\<svg)|(\\<\\!doctype\\s+svg)',
    aliases: <String>['XML', 'xml'],
    mimetypes: <String>['text/xml', 'application/xml', 'application/xaml+xml', 'application/xml-dtd'],
    loader: () async => ILangImpl(xml.conf, xml.language),
  ));
}
