// batch275: textToHtmlTokenizer.ts truth replay.
// Truth from tool/ts2dart/batch275_truth.json (recursive TS transpile+vm).
import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:semi_design_flutter/src/monaco/editor/common/encodedTokenAttributes.dart'
    show LanguageId;
import 'package:semi_design_flutter/src/monaco/editor/common/languages.dart'
    show EncodedTokenizationResult;
import 'package:semi_design_flutter/src/monaco/editor/common/languages/nullTokenize.dart'
    show NullState, nullTokenizeEncoded;
import 'package:semi_design_flutter/src/monaco/editor/common/languages/textToHtmlTokenizer.dart'
    show
        IReducedTokenizationSupport,
        tokenizeLineToHTML,
        tokenizeToStringInternal;
import 'package:semi_design_flutter/src/monaco/editor/common/tokens/lineTokens.dart'
    show ILanguageIdCodec, IViewLineTokens;

Map<String, dynamic> _truth() => jsonDecode(
    File('tool/ts2dart/batch275_truth.json').readAsStringSync())
    as Map<String, dynamic>;

class _Codec implements ILanguageIdCodec {
  @override
  int encodeLanguageId(String languageId) => 1;

  @override
  String decodeLanguageId(int languageId) => 'plaintext';
}

class _Fallback implements IReducedTokenizationSupport {
  @override
  Object getInitialState() => NullState.instance;

  @override
  EncodedTokenizationResult tokenizeEncoded(
          String buffer, bool hasEOL, Object state) =>
      nullTokenizeEncoded(LanguageId.nullId, state);
}

class _ViewTokens implements IViewLineTokens {
  final List<Map<String, dynamic>> tokens;

  _ViewTokens(this.tokens);

  @override
  dynamic noSuchMethod(Invocation invocation) => null;

  @override
  int getCount() => tokens.length;

  @override
  int getEndOffset(int tokenIndex) => tokens[tokenIndex]['end'] as int;

  @override
  String getInlineStyle(int tokenIndex, List<String> colorMap) {
    final String color = colorMap.isEmpty
        ? 'none'
        : (colorMap[tokenIndex % colorMap.length]);
    return 'color:$color;${tokens[tokenIndex]['style'] as String}';
  }
}

void main() {
  final t = _truth();

  for (final raw in t['html'] as List<dynamic>) {
    final c = raw as Map<String, dynamic>;
    final input = c['input'] as Map<String, dynamic>;
    test('b275 ${c['name']}: tokenizeLineToHTML matches truth', () {
      final tokens = (input['tokens'] as List<dynamic>)
          .map((x) => x as Map<String, dynamic>)
          .toList();
      final actual = tokenizeLineToHTML(
        input['text'] as String,
        _ViewTokens(tokens),
        (input['colorMap'] as List<dynamic>).cast<String>(),
        input['startOffset'] as int,
        input['endOffset'] as int,
        input['tabSize'] as int,
        input['useNbsp'] as bool,
      );
      expect(actual, c['output'], reason: c['name'] as String);
    });
  }

  for (final raw in t['strings'] as List<dynamic>) {
    final c = raw as Map<String, dynamic>;
    test('b275 ${c['name']}: _tokenizeToString matches truth', () {
      final actual = tokenizeToStringInternal(
        c['text'] as String,
        _Codec(),
        _Fallback(),
      );
      expect(actual, c['output'], reason: c['name'] as String);
    });
  }
}
