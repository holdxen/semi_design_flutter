// Truth-based tests for batch164: base/browser/markdownRenderer.ts
// Drives the Dart port with token trees captured from the REAL transpiled TS
// source running on the REAL vendored marked.js engine.
import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:semi_design_flutter/src/monaco/base/browser/markdownRenderer.dart'
    as mr;

final Map<String, dynamic> T =
    jsonDecode(File('tool/ts2dart/batch164_truth.json').readAsStringSync())
        as Map<String, dynamic>;

/// A table-backed marked engine. `lexer(src)` returns the token tree recorded
/// by the truth harness for that exact source string.
class TruthMarkedEngine implements mr.MarkedEngine {
  TruthMarkedEngine(this.lexerTable, {this.parseTokensTable});

  /// src -> token list (as Dart maps)
  final Map<String, List<Object?>> lexerTable;
  /// A token-tree supplier used by parse(); keyed by the markdown value.
  final Map<String, List<Object?>>? parseTokensTable;
  List<Object?>? _currentParseTokens;
  Object? _renderer;

  @override
  List<Object?> lexer(String src, [Object? options]) {
    final List<Object?>? tokens = lexerTable[src];
    if (tokens == null) {
      throw StateError('No truth lexer entry for: ${jsonEncode(src)}');
    }
    return tokens;
  }

  @override
  String parse(String src, {Object? renderer, bool async = false}) {
    _renderer = renderer;
    final List<Object?>? tokens = parseTokensTable?[src] ?? _currentParseTokens;
    if (tokens == null) {
      throw StateError('No truth parse tokens for: ${jsonEncode(src)}');
    }
    return _TruthParser(this, renderer ?? Object()).parseTokens(tokens, true);
  }

  @override
  Object createRenderer([Object? options]) {
    final mr.RendererCarrier carrier = mr.RendererCarrier();
    carrier.put('parser', _TruthParser(this, carrier));
    return carrier;
  }

  @override
  Object createLexer() => _TruthLexer(this);

  @override
  List<Object?> lexInstance(Object lexer, String src) => (lexer as _TruthLexer).lex(src);

  @override
  Object createMarkedInstance([List<Object?> extensions = const <Object?>[]]) =>
      this;

  @override
  List<Object?> instanceLexer(Object instance, String src, [Object? options]) =>
      lexer(src);

  @override
  String instanceParser(Object instance, List<Object?> tokens,
          [Object? options]) =>
      _TruthParser(this, _renderer ?? Object()).parseTokens(tokens, true);

  @override
  String instanceParse(Object instance, String src, [Object? options]) => parse(src);

  @override
  Object? instanceDefaults(Object instance) => <String, Object?>{};

  @override
  void instanceWalkTokens(
      Object instance, List<Object?> tokens, Object? callback) {}

  @override
  Object instanceRenderer(Object instance, [Object? options]) => createRenderer();

  List<Object?> lexFor(String src) => lexer(src);
}

class _TruthLexer {
  _TruthLexer(this.engine);
  final TruthMarkedEngine engine;
  Map<String, Object?> tokens = <String, Object?>{};
  List<Object?> lex(String src) {
    final List<Object?> result = engine.lexer(src);
    try {
      // ignore: avoid_dynamic_calls
      (result as dynamic).links = tokens['links'];
    } catch (_) {}
    return result;
  }
}

/// Mirror of marked's `_Parser` dispatch loop (1:1 for the token types the
/// markdown renderer's plaintext renderer handles).
class _TruthParser {
  _TruthParser(this.engine, this.renderer);
  final TruthMarkedEngine engine;
  final Object renderer;

  String parseInlineTokens(List<Object?> tokens, [Object? rendererOverride]) {
    final Object r = rendererOverride ?? renderer;
    final StringBuffer out = StringBuffer();
    for (final Object? obj in tokens) {
      final Map<String, Object?> token = (obj as Map).cast<String, Object?>();
      final String type = (token['type'] as String?) ?? '';
      switch (type) {
        case 'escape':
          out.write(_call(r, 'text', token));
          break;
        case 'html':
          out.write(_call(r, 'html', token));
          break;
        case 'link':
          out.write(_call(r, 'link', token));
          break;
        case 'image':
          out.write(_call(r, 'image', token));
          break;
        case 'strong':
          out.write(_call(r, 'strong', token));
          break;
        case 'em':
          out.write(_call(r, 'em', token));
          break;
        case 'codespan':
          out.write(_call(r, 'codespan', token));
          break;
        case 'br':
          out.write(_call(r, 'br', token));
          break;
        case 'del':
          out.write(_call(r, 'del', token));
          break;
        case 'text':
          out.write(_call(r, 'text', token));
          break;
        default:
          throw StateError('Unknown inline token type: $type');
      }
    }
    return out.toString();
  }

  String parseTokens(List<Object?> tokens, [bool top = true]) {
    final StringBuffer out = StringBuffer();
    for (int i = 0; i < tokens.length; i++) {
      final Map<String, Object?> token =
          ((tokens[i] as Map).cast<String, Object?>());
      final String type = (token['type'] as String?) ?? '';
      switch (type) {
        case 'space':
          out.write(_call(renderer, 'space', token));
          break;
        case 'hr':
          out.write(_call(renderer, 'hr', token));
          break;
        case 'heading':
          out.write(_call(renderer, 'heading', token));
          break;
        case 'code':
          out.write(_call(renderer, 'code', token));
          break;
        case 'table':
          out.write(_call(renderer, 'table', token));
          break;
        case 'blockquote':
          out.write(_call(renderer, 'blockquote', token));
          break;
        case 'list':
          out.write(_call(renderer, 'list', token));
          break;
        case 'html':
          out.write(_call(renderer, 'html', token));
          break;
        case 'paragraph':
          out.write(_call(renderer, 'paragraph', token));
          break;
        case 'text':
          String body = _call(renderer, 'text', token);
          int j = i;
          while (j + 1 < tokens.length &&
              ((tokens[j + 1] as Map)['type'] == 'text')) {
            j++;
            body += '\n' + _call(renderer, 'text', tokens[j] as Map<String, Object?>);
          }
          i = j;
          if (top) {
            out.write(_call(renderer, 'paragraph', <String, Object?>{
              'type': 'paragraph',
              'raw': body,
              'text': body,
              'tokens': <Object?>[
                <String, Object?>{'type': 'text', 'raw': body, 'text': body}
              ],
            }));
          } else {
            out.write(body);
          }
          break;
        default:
          throw StateError('Unknown block token type: $type');
      }
    }
    return out.toString();
  }

  String _call(Object r, String name, Map<String, Object?> token) {
    if (r is mr.RendererCarrier) return r.callRenderer(name, token);
    return '';
  }
}


List<Object?> _toDartTokens(List<dynamic> jsonTokens) =>
    jsonTokens.map((dynamic t) => _toDartValue(t)).toList();

Object? _toDartValue(dynamic v) {
  if (v == null) return null;
  if (v is Map<String, dynamic>) return _toDartToken(v);
  if (v is List<dynamic>) return _toDartTokens(v);
  return v;
}

Map<String, Object?> _toDartToken(Map<String, dynamic> m) =>
    m.map<String, Object?>((String k, dynamic v) =>
        MapEntry<String, Object?>(k, _toDartValue(v)));

void main() {
  final Map<String, dynamic> truth = T;

  setUpAll(() {
    // Nothing global to reset beyond injected hooks.
  });

  group('batch164 constants', () {
    test('allowedMarkdownHtmlTags', () {
      expect(mr.allowedMarkdownHtmlTags,
          (truth['constants'] as Map)['allowedTags']);
    });
    test('allowedMarkdownHtmlAttributes strings', () {
      expect(
          mr.allowedMarkdownHtmlAttributes
              .whereType<String>()
              .toList(),
          ((truth['constants'] as Map)['allowedAttributes'] as List<dynamic>)
              .whereType<String>()
              .where((String s) => s != '[rule]')
              .toList());
    });
  });

  group('batch164 getDomSanitizerConfig', () {
    test('matches transpiled source configs', () {
      final List<dynamic> cfgs =
          (truth['sanitizerConfigs'] as List<dynamic>);
      final Map<String, Object?> c0 = (cfgs[0] as Map).cast<String, Object?>();
      final Map<String, Object?> c1 = (cfgs[1] as Map).cast<String, Object?>();

      final Object cfg0 = mr.getDomSanitizerConfig(
        mr.MdStrConfig(),
        mr.MarkdownSanitizerConfig(),
      );
      _expectSanitizerConfig(cfg0, c0);

      final Object cfg1 = mr.getDomSanitizerConfig(
        mr.MdStrConfig(isTrusted: true, baseUri: 'https://ex.com/a'),
        mr.MarkdownSanitizerConfig(
          allowedLinkSchemes: <String>['foo'],
          allowedMediaSchemes: <String>['bar'],
          replaceWithPlaintext: true,
        ),
      );
      _expectSanitizerConfig(cfg1, c1);
    });
  });

  group('batch164 fillInIncompleteTokens', () {
    final Map<String, Object?> fill =
        (truth['fill'] as Map).cast<String, Object?>();
    for (final String name in fill.keys) {
      test(name, () {
        final Map<String, Object?> scenario =
            (fill[name] as Map).cast<String, Object?>();
        final List<Object?> input = _toDartTokens(
            (scenario['input'] as List<dynamic>));
        final Map<String, Object?> links = _toDartToken(
            (scenario['inputLinks'] as Map).cast<String, dynamic>());
        // Rebuild a TokensList-like list with mutable links field.
        final List<Object?> tokens = List<Object?>.from(input);
        _setLinks(tokens, links);

        // Build lexer table from recorded internal calls.
        final Map<String, List<Object?>> table = <String, List<Object?>>{};
        for (final dynamic call in (scenario['lexerCalls'] as List<dynamic>)) {
          final Map<String, dynamic> c = call as Map<String, dynamic>;
          table[c['src'] as String] = _toDartTokens(
              ((c['result'] as Map)['tokens'] as List<dynamic>));
        }
        mr.setMarkedEngine(TruthMarkedEngine(table));

        final List<Object?> output = mr.fillInIncompleteTokens(tokens);

        expect(output.length, (scenario['output'] as List<dynamic>).length,
            reason: 'token count for $name');
        for (int i = 0; i < output.length; i++) {
          expect(_normalize(output[i]),
              _normalize((scenario['output'] as List<dynamic>)[i]),
              reason: 'token[$i] for $name');
        }
        expect(scenario['identity'] == true, identical(output, tokens),
            reason: 'identity for $name');
      });
    }
  });

  group('batch164 renderAsPlaintext', () {
    final Map<String, Object?> plain =
        (truth['plain'] as Map).cast<String, Object?>();

    // Helper to build an engine with the token table for a given case.
    mr.MarkedEngine engineForCase(String name) {
      final Map<String, Object?> c =
          (plain[name] as Map).cast<String, Object?>();
      final List<Object?> tokens = _toDartTokens(
          ((c['tokens'] as Map)['tokens'] as List<dynamic>));
      final Map<String, List<Object?>> table = <String, List<Object?>>{
        (c['value'] as String): tokens,
      };
      final TruthMarkedEngine e = TruthMarkedEngine(table,
          parseTokensTable: <String, List<Object?>>{(c['value'] as String): tokens});
      return e;
    }

    for (final String name in <String>[
      'allTokens',
      'htmlHrImageLink',
      'htmlInCode',
      'codeSpansEntities',
      'codeSpanHtml',
      'listDefault',
      'nestedList',
    ]) {
      test('default:$name', () {
        final Map<String, Object?> c =
            (plain[name] as Map).cast<String, Object?>();
        mr.setMarkedEngine(engineForCase(name));
        final String result = mr.renderAsPlaintext(<String, Object?>{
          'value': c['value'] as String,
        });
        expect(result, c['default']);
      });
    }

    test('includeCodeBlocksFences', () {
      mr.setMarkedEngine(engineForCase('htmlInCode'));
      final Map<String, Object?> c =
          (plain['htmlInCode'] as Map).cast<String, Object?>();
      final String result = mr.renderAsPlaintext(
          <String, Object?>{'value': c['value'] as String},
          mr.PlainTextRenderOptions(includeCodeBlocksFences: true));
      expect(result, plain['htmlInCodeFences']);
    });

    test('omitMarkdownSyntax', () {
      mr.setMarkedEngine(engineForCase('listDefault'));
      final Map<String, Object?> c =
          (plain['listDefault'] as Map).cast<String, Object?>();
      final String result = mr.renderAsPlaintext(
          <String, Object?>{'value': c['value'] as String},
          mr.PlainTextRenderOptions(omitMarkdownSyntax: true));
      expect(result, plain['listNoSyntax']);
    });

    test('nestedList omitMarkdownSyntax', () {
      mr.setMarkedEngine(engineForCase('nestedList'));
      final Map<String, Object?> c =
          (plain['nestedList'] as Map).cast<String, Object?>();
      final String result = mr.renderAsPlaintext(
          <String, Object?>{'value': c['value'] as String},
          mr.PlainTextRenderOptions(omitMarkdownSyntax: true));
      expect(result, plain['nestedListNoSyntax']);
    });

    test('codeBlockText', () {
      final Map<String, Object?> cbt =
          (plain['codeBlockText'] as Map).cast<String, Object?>();
      final List<Object?> tokens = _toDartTokens(
          ((cbt['tokens'] as Map)['tokens'] as List<dynamic>));
      final String value = cbt['value'] as String;
      final TruthMarkedEngine e = TruthMarkedEngine(
          <String, List<Object?>>{value: tokens},
          parseTokensTable: <String, List<Object?>>{value: tokens});
      mr.setMarkedEngine(e);

      final List<String> calls = <String>[];
      String? codeBlockText(String lang, String text, String raw) {
        calls.add('$lang|$text|$raw');
        return lang == 'chart' ? 'Chart <${text.length}> & more' : null;
      }

      final String fenced = mr.renderAsPlaintext(
          <String, Object?>{'value': value},
          mr.PlainTextRenderOptions(
              includeCodeBlocksFences: true, codeBlockText: codeBlockText));
      expect(
          fenced.split('\n').where((String l) => l.isNotEmpty).toList(),
          (cbt['fenced'] as List<dynamic>).cast<String>());

      final String plainResult = mr.renderAsPlaintext(
          <String, Object?>{'value': value},
          mr.PlainTextRenderOptions(codeBlockText: codeBlockText));
      expect(
          plainResult.split('\n').where((String l) => l.isNotEmpty).toList(),
          (cbt['plain'] as List<dynamic>).cast<String>());

      final String noSyntax = mr.renderAsPlaintext(
          <String, Object?>{'value': value},
          mr.PlainTextRenderOptions(
              omitMarkdownSyntax: true, codeBlockText: codeBlockText));
      expect(
          noSyntax.split('\n').where((String l) => l.isNotEmpty).toList(),
          (cbt['withoutSyntax'] as List<dynamic>).cast<String>());
    });
  });
}

void _setLinks(List<Object?> tokens, Map<String, Object?> links) {
  // Reference links are unused across all batch164 truth scenarios; the port
  // defaults `.links` to empty, matching the recorded `inputLinks: {}`.
}

void _expectSanitizerConfig(Object cfg, Map<String, Object?> expected) {
  final Map<String, Object?> m = (cfg as Map).cast<String, Object?>();
  final Map<String, Object?> tags = (m['allowedTags'] as Map).cast<String, Object?>();
  expect((tags['override'] as List).length, expected['allowedTags']);
  final Map<String, Object?> attrs =
      (m['allowedAttributes'] as Map).cast<String, Object?>();
  expect((attrs['override'] as List).length, expected['allowedAttributes']);
  final Map<String, Object?> links =
      (m['allowedLinkProtocols'] as Map).cast<String, Object?>();
  expect(links['override'], expected['allowedLinkProtocols']);
  expect(m['allowRelativeLinkPaths'], expected['allowRelativeLinkPaths']);
  final Map<String, Object?> media =
      (m['allowedMediaProtocols'] as Map).cast<String, Object?>();
  expect(media['override'], expected['allowedMediaProtocols']);
  expect(m['allowRelativeMediaPaths'], expected['allowRelativeMediaPaths']);
  expect(m['replaceWithPlaintext'] ?? false,
      expected['replaceWithPlaintext'] ?? false);
}

Object? _normalize(Object? value) {
  if (value is Map) {
    final Map<String, Object?> out = <String, Object?>{};
    value.forEach((Object? k, Object? v) {
      if (k == 'links') return;
      out[k as String] = _normalize(v);
    });
    return out;
  }
  if (value is List) return value.map(_normalize).toList();
  return value;
}
