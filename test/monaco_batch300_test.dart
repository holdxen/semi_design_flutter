// batch300: monarchLexer.ts truth replay.
// Truth from tool/ts2dart/batch300_truth.json (recursive TS transpile + vm,
// compiled JSON lexer driven through the real MonarchTokenizer).
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:semi_design_flutter/src/monaco/editor/common/languages.dart'
    show EncodedTokenizationResult, TokenizationResult;
import 'package:semi_design_flutter/src/monaco/editor/standalone/common/monarch/monarchCompile.dart'
    show compile;
import 'package:semi_design_flutter/src/monaco/editor/standalone/common/monarch/monarchLexer.dart'
    show
        IColorThemeForMonarch,
        IConfigurationForMonarch,
        ILanguageServiceForMonarch,
        IStandaloneThemeForMonarch,
        MonarchLineState,
        MonarchStackElement,
        MonarchTokenizer;
import 'package:semi_design_flutter/src/monaco/editor/standalone/common/monarch/monarchTypes.dart'
    show
      IActionListCarrier,
      IExpandedMonarchLanguageAction,
      IExpandedMonarchLanguageRule,
      IMonarchLanguage,
      IMonarchLanguageAction,
      IMonarchLanguageBracket,
      IMonarchLanguageRule,
      IShortActionCarrier,
      IShortMonarchLanguageRule1;

Map<String, dynamic> _truth() => jsonDecode(
    File('tool/ts2dart/batch300_truth.json').readAsStringSync())
    as Map<String, dynamic>;

Object? _norm(Object? v) {
  if (v == null) return null;
  if (v is Map) {
    return v.map<String, Object?>((k, e) => MapEntry<String, Object?>(k as String, _norm(e)));
  }
  if (v is List) return v.map(_norm).toList();
  return v;
}

int _i(Object? v) => (v as num).toInt();

IMonarchLanguageAction _action(Object? raw) {
  if (raw is String) return IShortActionCarrier(raw);
  if (raw is List<dynamic>) {
    return IActionListCarrier(raw.map(_action).toList());
  }
  final Map<String, dynamic> d = raw as Map<String, dynamic>;
  return IExpandedMonarchLanguageAction(
    group: d['group'] == null
        ? null
        : (d['group'] as List<dynamic>).map(_action).toList(),
    token: d['token'] as String?,
    next: d['next'] as String?,
    switchTo: d['switchTo'] as String?,
    goBack: d['goBack'] == null ? null : _i(d['goBack']),
    bracket: d['bracket'] as String?,
    nextEmbedded: d['nextEmbedded'] as String?,
    log: d['log'] as String?,
  );
}

IMonarchLanguageRule _rule(Object? raw) {
  if (raw is List<dynamic>) {
    return IShortMonarchLanguageRule1(raw[0], _action(raw[1]));
  }
  final Map<String, dynamic> d = raw as Map<String, dynamic>;
  return IExpandedMonarchLanguageRule(
    regex: d[0],
    action: d[1] == null ? null : _action(d[1]),
    include: d[2] as String?,
  );
}

IMonarchLanguage _language(Map<String, dynamic> json) => IMonarchLanguage(
      tokenizer: (json['tokenizer'] as Map<String, dynamic>).map(
        (String k, dynamic v) => MapEntry<String, List<IMonarchLanguageRule>>(
          k,
          (v as List<dynamic>).map(_rule).toList(),
        ),
      ),
      brackets: json['brackets'] == null
          ? null
          : (json['brackets'] as List<dynamic>).map((dynamic d) {
              final Map<String, dynamic> m = d as Map<String, dynamic>;
              return IMonarchLanguageBracket(m['open'] as String,
                  m['close'] as String, m['token'] as String);
            }).toList(),
    );

class _Languages implements ILanguageServiceForMonarch {
  final Map<String, int> _ids = <String, int>{};
  int _next = 2;

  @override
  int encodeLanguageId(String languageId) =>
      _ids.putIfAbsent(languageId, () => _next++);

  @override
  String? getLanguageIdByLanguageName(String languageName) => null;

  @override
  String? getLanguageIdByMimeType(String? mimeType) => null;

  @override
  bool isRegisteredLanguageId(String? languageId) => false;

  @override
  void requestBasicLanguageFeatures(String languageId) {}
}

class _Theme implements IStandaloneThemeForMonarch, IColorThemeForMonarch {
  @override
  Object getColorTheme() => this;

  @override
  int matchToken(int languageId, String type) {
    final int base = languageId * 0x100;
    switch (type) {
      case 'number':
        return (base + 3) << 15;
      case 'string':
        return (base + 4) << 15;
      case 'identifier':
        return (base + 5) << 15;
      default:
        return base;
    }
  }
}

class _Configuration implements IConfigurationForMonarch {
  _Configuration(this.limit);

  final int limit;

  @override
  int getMaxTokenizationLineLength(String languageId) => limit;
}

Map<String, Object?> _stateJson(Object? state) {
  if (state == null) return <String, Object?>{};
  final MonarchLineState s = state as MonarchLineState;
  final List<Object?> stack = <Object?>[];
  MonarchStackElement? cur = s.stack;
  while (cur != null) {
    stack.add(cur.state);
    cur = cur.parent;
  }
  return <String, Object?>{
    'stack': stack.reversed.toList(),
    'embedded': null,
  };
}

List<Object?> _classicTokensJson(TokenizationResult result) => result.tokens
    .map((t) => <String, Object?>{
          'offset': t.offset,
          'type': t.type,
          'language': t.language,
        })
    .toList();

List<Object?> _encodedTokensJson(EncodedTokenizationResult result) {
  final List<Object?> tokens = <Object?>[];
  for (int i = 0; i < result.tokens.length; i += 2) {
    tokens.add(<Object?>[result.tokens[i], result.tokens[i + 1]]);
  }
  return tokens;
}

void main() {
  final Map<String, dynamic> truth = _truth();
  group('batch300 monarchLexer truth replay', () {
    for (final dynamic rawCase in truth['cases'] as List<dynamic>) {
      final Map<String, dynamic> c = rawCase as Map<String, dynamic>;
      test(c['name'] as String, () {
        final MonarchTokenizer tokenizer = MonarchTokenizer(
          _Languages(),
          _Theme(),
          'testlang',
          compile('testlang', _language(c['languageJson'] as Map<String, dynamic>)),
          _Configuration(_i(c['limit'])),
        );
        Object? state = tokenizer.getInitialState();
        final List<dynamic> results = c['results'] as List<dynamic>;

        for (int i = 0; i < results.length; i++) {
          final Map<String, dynamic> expected = results[i] as Map<String, dynamic>;
          late Map<String, Object?> actual;
          if (i == 0) {
            actual = <String, Object?>{
              'label': 'initial',
              'state': _stateJson(state),
            };
          } else if (i == results.length - 1) {
            actual = <String, Object?>{
              'label': 'state-equality',
              'equalToSelf': (state as MonarchLineState).equals(state),
              'cloneEquals': state.equals(state.clone()),
            };
          } else {
            final Map<String, dynamic> line =
                (c['lines'] as List<dynamic>)[i - 1] as Map<String, dynamic>;
            final TokenizationResult classic = tokenizer.tokenize(
                line['text'] as String, line['eol'] as bool, state);
            final EncodedTokenizationResult encoded = tokenizer.tokenizeEncoded(
                line['text'] as String, line['eol'] as bool, state);
            actual = <String, Object?>{
              'label': line['label'],
              'classic': _classicTokensJson(classic),
              'encoded': _encodedTokensJson(encoded),
              'classicEndState': _stateJson(classic.endState),
              'encodedEndState': _stateJson(encoded.endState),
            };
            state = encoded.endState;
          }
          expect(actual, _norm(expected));
        }
      });
    }
  });
}
