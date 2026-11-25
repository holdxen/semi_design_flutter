// 1:1 replay of `editor/test/common/modes/supports/onEnterRules.ts`.
// Truth: `tool/ts2dart/_batch405_truth.cjs` -> `batch405_truth.json`.
import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import '../lib/src/monaco/editor/common/languages/supports/onEnter.dart'
    show EnterAction, IndentAction, OnEnterRule;
import '../lib/src/monaco/editor/test/common/modes/supports/onEnterRules.dart';

Map<String, dynamic> _map(dynamic v) => (v as Map).cast<String, dynamic>();

Map<String, dynamic> _truth() => _map(
      jsonDecode(File('tool/ts2dart/batch405_truth.json').readAsStringSync()),
    );

const int _none = IndentAction.None;
const int _indent = IndentAction.Indent;
const int _indentOutdent = IndentAction.IndentOutdent;
const int _outdent = IndentAction.Outdent;

Map<String, dynamic> _actionJson(EnterAction a) => <String, dynamic>{
      'indentAction': a.indentAction,
      'appendText': a.appendText,
      'removeText': a.removeText,
    };

Object? _regexSource(RegExp? r) => r?.pattern;

void main() {
  final Map<String, dynamic> truth = _truth();
  final List<String> lines =
      (truth['lines'] as List<dynamic>).cast<String>();
  final Map<String, dynamic> groups = _map(truth['groups']);

  final Map<String, List<OnEnterRule>> dartGroups =
      <String, List<OnEnterRule>>{
    'javascriptOnEnterRules': javascriptOnEnterRules,
    'phpOnEnterRules': phpOnEnterRules,
    'cppOnEnterRules': cppOnEnterRules,
    'htmlOnEnterRules': htmlOnEnterRules,
    'vbOnEnterRules': vbOnEnterRules,
  };

  test('on-enter rule tables replay TS truth', () {
    final Map<String, dynamic> actual = <String, dynamic>{};
    for (final MapEntry<String, List<OnEnterRule>> entry
        in dartGroups.entries) {
      final List<dynamic> truthRules = groups[entry.key] as List<dynamic>;
      expect(truthRules.length, entry.value.length,
          reason: '${entry.key} rule count');

      final List<Object?> ruleJson = <Object?>[];
      for (int i = 0; i < entry.value.length; i++) {
        final OnEnterRule rule = entry.value[i];
        final Map<String, dynamic> t = _map(truthRules[i]);
        final Map<String, dynamic>? bTruth =
            t['beforeText'] == null ? null : _map(t['beforeText']);
        final Map<String, dynamic>? aTruth =
            t['afterText'] == null ? null : _map(t['afterText']);
        final Map<String, dynamic>? pTruth =
            t['previousLineText'] == null
                ? null
                : _map(t['previousLineText']);

        // Truth stores each regex field's matches under `matches.<field>`.
        final List<dynamic> beforeMatches =
            (_map(t['matches'])['beforeText'] as List<dynamic>?) ??
                <dynamic>[];
        final List<dynamic> afterMatches =
            (_map(t['matches'])['afterText'] as List<dynamic>?) ??
                <dynamic>[];
        final List<dynamic> prevMatches =
            (_map(t['matches'])['previousLineText'] as List<dynamic>?) ??
                <dynamic>[];

        ruleJson.add(<String, dynamic>{
          'beforeText': bTruth == null
              ? null
              : <String, dynamic>{
                  'source': rule.beforeText?.pattern,
                  'flags': bTruth['flags'],
                },
          'afterText': aTruth == null
              ? null
              : <String, dynamic>{
                  'source': rule.afterText?.pattern,
                  'flags': aTruth['flags'],
                },
          'previousLineText': pTruth == null
              ? null
              : <String, dynamic>{
                  'source': rule.previousLineText?.pattern,
                  'flags': pTruth['flags'],
                },
          'action': _actionJson(rule.action),
          'matches': <String, dynamic>{
            'beforeText': beforeMatches.isEmpty
                ? null
                : lines.map((String l) => rule.beforeText!.hasMatch(l)).toList(),
            'afterText': afterMatches.isEmpty
                ? null
                : lines.map((String l) => rule.afterText!.hasMatch(l)).toList(),
            'previousLineText': prevMatches.isEmpty
                ? null
                : lines
                    .map((String l) => rule.previousLineText!.hasMatch(l))
                    .toList(),
          },
        });
      }
      actual[entry.key] = ruleJson;
    }

    for (final String key in groups.keys) {
      expect(
        jsonEncode(actual[key]),
        jsonEncode(groups[key]),
        reason: 'mismatch at $key',
      );
    }
  });
}
