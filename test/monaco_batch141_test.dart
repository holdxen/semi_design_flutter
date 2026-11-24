import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:semi_design_flutter/src/monaco/base/common/htmlContent.dart' as h;
import 'package:semi_design_flutter/src/monaco/base/common/uri.dart' as uriLib;

final Map<String, Object?> _truth =
    json.decode(File('tool/ts2dart/batch141_truth.json').readAsStringSync())
        as Map<String, Object?>;

List<Object?> _list(Object? v) => (v as List).cast<Object?>();
Map<String, Object?> _map(Object? v) => (v as Map).cast<String, Object?>();

/// Minimal DTO implementing IMarkdownString for lift() tests.
class _Dto implements h.IMarkdownString {
  _Dto(this.value,
      {this.isTrusted,
      this.supportThemeIcons,
      this.baseUri,
      this.uris});

  @override
  String value;
  @override
  Object? isTrusted;
  @override
  bool? supportThemeIcons;
  @override
  bool? supportHtml;
  @override
  bool? supportAlertSyntax;
  @override
  Object? baseUri;
  @override
  Map<String, Object?>? uris;
}

void main() {
  test('constructor variants', () {
    final List<Object?> rows = _list(_truth['ctor']);
    final List<h.MarkdownString> values = <h.MarkdownString>[
      h.MarkdownString(),
      h.MarkdownString('x', true),
      h.MarkdownString('y', <String, Object?>{
        'supportThemeIcons': true,
        'supportHtml': true,
        'supportAlertSyntax': true,
      }),
    ];
    for (int i = 0; i < values.length; i++) {
      final Map<String, Object?> e = _map(rows[i]);
      expect(values[i].value, e['value'], reason: 'ctor $i value');
      expect(values[i].isTrusted, e['isTrusted'], reason: 'ctor $i isTrusted');
      expect(values[i].supportThemeIcons, e['supportThemeIcons'], reason: 'ctor $i themeIcons');
      expect(values[i].supportHtml, e['supportHtml'], reason: 'ctor $i html');
      expect(values[i].supportAlertSyntax, e['supportAlertSyntax'], reason: 'ctor $i alert');
    }
    expect(
      () => h.MarkdownString(123),
      throwsA(isA<Error>()),
    );
  });

  test('lift', () {
    final Map<String, Object?> e = _map(_truth['lift']);
    final uriLib.UriComponents components = uriLib.UriComponents(
      scheme: 'file', authority: '', path: '/a/b', query: '', fragment: '',
    );
    final h.MarkdownString lifted = h.MarkdownString.lift(_Dto(
      'v',
      isTrusted: true,
      supportThemeIcons: true,
      baseUri: components,
      uris: <String, Object?>{
        'k': uriLib.UriComponents(
            scheme: 'https', authority: 'x', path: '/', query: '', fragment: ''),
      },
    ));
    expect(lifted.value, e['value']);
    expect(lifted.isTrusted, e['isTrusted']);
    expect((lifted.baseUri as uriLib.URI).toString(), e['baseUri']);
    final Map<String, Object?> expectedUris = _map(e['uris']);
    final uriLib.UriComponents k = lifted.uris!['k'] as uriLib.UriComponents;
    final Map<String, Object?> ek = _map(expectedUris['k']);
    expect(k.scheme, ek['scheme']);
    expect(k.authority, ek['authority']);
    expect(k.path, ek['path']);
  });

  test('appendText / appendMarkdown / appendCodeblock / appendLink', () {
    final h.MarkdownString m = h.MarkdownString('', false);
    m.appendText(r'hello  $(check) world\nline2'.replaceAll(r'\n', '\n'));
    expect(m.value, _truth['appendTextFalse']);

    final h.MarkdownString m2 = h.MarkdownString('', <String, Object?>{'supportThemeIcons': true});
    m2.appendText('a  \$(check) b\nc');
    expect(m2.value, _truth['appendTextIcons']);

    final h.MarkdownString m3 = h.MarkdownString('', false);
    m3.appendText('x\ny', h.MarkdownStringTextNewlineStyle.break_);
    expect(m3.value, _truth['appendTextBreak']);

    final h.MarkdownString m4 = h.MarkdownString('base');
    m4.appendMarkdown(' **md**').appendCodeblock('js', 'const x=1;');
    expect(m4.value, _truth['appendMdCode']);

    final h.MarkdownString m5 = h.MarkdownString();
    m5.appendLink(r'http://example.com/a(b)', 'label]x', 'a"b\nc');
    expect(m5.value, _truth['appendLink']);

    final h.MarkdownString m6 = h.MarkdownString();
    m6.appendLink(uriLib.URI.from(uriLib.UriComponents(
        scheme: 'https', authority: 'x', path: '/p', query: '', fragment: '')), 'L');
    expect(m6.value, _truth['appendLinkUri']);
  });

  test('isEmpty / isMarkdown / markdownStringEqual', () {
    final List<h.MarkdownString?> ms = <h.MarkdownString?>[
      h.MarkdownString(''), h.MarkdownString('x'),
      null,
    ];
    expect(h.isEmptyMarkdownString(ms[0]), _list(_truth['isEmpty'])[0]);
    expect(h.isEmptyMarkdownString(ms[1]), _list(_truth['isEmpty'])[1]);
    expect(h.isEmptyMarkdownString(<Object?>[ms[0], ms[0]]), _list(_truth['isEmpty'])[2]);
    expect(h.isEmptyMarkdownString(<Object?>[ms[0], ms[1]]), _list(_truth['isEmpty'])[3]);
    expect(h.isEmptyMarkdownString(null), _list(_truth['isEmpty'])[4]);

    final List<Object?> mk = _list(_truth['isMarkdown']);
    expect(h.isMarkdownString(h.MarkdownString('x')), mk[0]);
    expect(h.isMarkdownString(<String, Object?>{'value': 'x'}), mk[1]);
    expect(h.isMarkdownString(<String, Object?>{'value': 'x', 'isTrusted': true}), mk[2]);
    expect(h.isMarkdownString(<String, Object?>{'value': 1}), mk[3]);
    expect(h.isMarkdownString(null), mk[4]);
    expect(h.isMarkdownString(<String, Object?>{'value': 'x', 'isTrusted': 'yes'}), mk[5]);
    expect(h.isMarkdownString(<String, Object?>{'value': 'x', 'supportThemeIcons': 'yes'}), mk[6]);

    final h.MarkdownString a = h.MarkdownString('x', true);
    final h.MarkdownString b = h.MarkdownString('x', true);
    final h.MarkdownString c = h.MarkdownString('y', true);
    final List<Object?> eq = _list(_truth['equal']);
    expect(h.markdownStringEqual(a, a), eq[0]);
    expect(h.markdownStringEqual(a, b), eq[1]);
    expect(h.markdownStringEqual(a, c), eq[2]);
    expect(h.markdownStringEqual(a, null), eq[3]);
  });

  test('escaping functions', () {
    final List<Object?> syntax = _list(_truth['escapeSyntax']);
    expect(h.escapeMarkdownSyntaxTokens(r'back`tick * emphasis [bracket] (paren) #hash +plus !bang ~tilde -dash'), syntax[0]);
    expect(h.escapeMarkdownSyntaxTokens('  - list\n\t- tablist'), syntax[1]);
    expect(h.escapeUntrustedMarkdown(r'see $(check) <a> x@y . :'), _truth['escapeUntrusted']);
    expect(h.escapeMarkdownLinkLabel(r'a]b\c'), _truth['escapeLinkLabel']);
    expect(h.escapeMarkdownLinkText('a\r\nb !@#'), _truth['escapeLinkText']);
    expect(h.escapeDoubleQuotes('a"b"c'), _truth['escapeDoubleQuotes']);
    final List<Object?> rem = _list(_truth['removeEscapes']);
    expect(h.removeMarkdownEscapes(r'\* escaped'), rem[0]);
    expect(h.removeMarkdownEscapes(''), rem[1]);
    expect(h.removeMarkdownEscapes('plain'), rem[2]);
  });

  test('code block / inline code', () {
    final List<Object?> cb = _list(_truth['codeBlock']);
    expect(h.appendEscapedMarkdownCodeBlockFence('code', 'js'), cb[0]);
    expect(h.appendEscapedMarkdownCodeBlockFence('```\n```', ''), cb[1]);
    expect(h.appendEscapedMarkdownCodeBlockFence('  ```x', 'ts'), cb[2]);
    final List<Object?> ic = _list(_truth['inlineCode']);
    expect(h.appendEscapedMarkdownInlineCode('a`b'), ic[0]);
    expect(h.appendEscapedMarkdownInlineCode('`start'), ic[1]);
    expect(h.appendEscapedMarkdownInlineCode('no ticks'), ic[2]);
    expect(h.appendEscapedMarkdownInlineCode('`` double ``'), ic[3]);
  });

  test('parseHrefAndDimensions', () {
    final List<Object?> rows = _list(_truth['href']);
    final List<String> hrefs = <String>[
      'image.png|height=100,width=200',
      '  file.png  | width=50 ',
      'no-params',
      'x|height=abc,width=10',
    ];
    for (int i = 0; i < hrefs.length; i++) {
      final Map<String, Object?> e = _map(rows[i]);
      final Map<String, Object> r = h.parseHrefAndDimensions(hrefs[i]);
      expect(r['href'], e['href'], reason: 'href $i');
      expect(r['dimensions'], _list(e['dimensions']), reason: 'dimensions $i');
    }
  });

  test('resolveWithBaseUri', () {
    final uriLib.URI baseDir = uriLib.URI.from(uriLib.UriComponents(
        scheme: 'file', authority: '', path: '/a/b/', query: '', fragment: ''));
    final uriLib.URI baseFile = uriLib.URI.from(uriLib.UriComponents(
        scheme: 'file', authority: '', path: '/a/b/readme.md', query: '', fragment: ''));
    final List<Object?> res = _list(_truth['resolve']);
    expect(h.resolveWithBaseUri(baseDir, 'img.png'), res[0]);
    expect(h.resolveWithBaseUri(baseFile, 'img.png'), res[1]);
    expect(h.resolveWithBaseUri(baseFile, 'https://example.com/x'), res[2]);
  });

  test('createMarkdownLink / commandUri / commandLink', () {
    final List<Object?> cl = _list(_truth['createLink']);
    expect(h.createMarkdownLink('a*b', 'http://x', 'ti*tle'), cl[0]);
    expect(h.createMarkdownLink('a*b', 'http://x', null, false), cl[1]);
    final List<Object?> cu = _list(_truth['commandUri']);
    expect(h.createCommandUri('my.cmd').toString(), cu[0]);
    expect(h.createCommandUri('my.cmd', <Object?>['arg1', 42]).toString(), cu[1]);
    expect(
      h.createMarkdownCommandLink(<String, Object>{
        'text': 'Run',
        'id': 'my.cmd',
        'arguments': <Object>['x'],
        'tooltip': 'Tip',
      }),
      _truth['commandLink'],
    );
  });

  test('portable link targets', () {
    final List<Object?> p = _list(_truth['portable']);
    expect(h.isPortableLinkTarget('  https://example.com  '), p[0]);
    expect(h.isPortableLinkTarget('http://_vscodecontentref_/0'), p[1]);
    expect(h.isPortableLinkTarget('mailto:a@b.com'), p[2]);
    expect(h.isPortableLinkTarget('file:///etc/passwd'), p[3]);
    expect(h.isPortableMarkdownTarget('#section'), p[4]);
    expect(h.isPortableMarkdownTarget('doc.md'), p[5]);
    expect(h.isPortableMarkdownTarget('/abs/path'), p[6]);
    expect(h.isPortableMarkdownTarget(r'C:\windows'), p[7]);
  });
}
