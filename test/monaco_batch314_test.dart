// batch314: onEnter.ts truth replay.
import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:semi_design_flutter/src/monaco/editor/common/config/editorOptions.dart'
    show EditorAutoIndentStrategy;
import 'package:semi_design_flutter/src/monaco/editor/common/languages/supports/onEnter.dart'
    show EnterAction, IOnEnterSupportOptions, IndentAction, OnEnterRule, OnEnterSupport;

Map<String, dynamic> _truth() => jsonDecode(
    File('tool/ts2dart/batch314_truth.json').readAsStringSync())
    as Map<String, dynamic>;

IOnEnterSupportOptions _options(Map<String, dynamic> json) =>
    IOnEnterSupportOptions(
      brackets: json['brackets'] == null
          ? null
          : (json['brackets'] as List<dynamic>)
              .map((b) => (b as List<dynamic>).map((s) => s as String).toList())
              .toList(),
      onEnterRules: json['onEnterRules'] == null
          ? null
          : (json['onEnterRules'] as List<dynamic>).map((dynamic d) {
              final Map<String, dynamic> r = d as Map<String, dynamic>;
              final Map<String, dynamic> a = r['action'] as Map<String, dynamic>;
              return OnEnterRule(
                beforeText: r['beforeText'] == null
                    ? null
                    : RegExp(r['beforeText'] as String),
                afterText: r['afterText'] == null
                    ? null
                    : RegExp(r['afterText'] as String),
                previousLineText: r['previousLineText'] == null
                    ? null
                    : RegExp(r['previousLineText'] as String),
                action: EnterAction(
                  a['indentAction'] as int,
                  a['appendText'] as String?,
                  a['removeText'] as int?,
                ),
              );
            }).toList(),
    );

Object? _actionJson(EnterAction? a) => a == null
    ? null
    : <String, Object?>{
        'indentAction': a.indentAction,
        'appendText': a.appendText,
        'removeText': a.removeText,
      };

void main() {
  final Map<String, dynamic> truth = _truth();
  final Map<String, dynamic> ia =
      truth['indentAction'] as Map<String, dynamic>;
  test('enum values match truth', () {
    expect(
      <String, Object?>{
        'None': IndentAction.None,
        'Indent': IndentAction.Indent,
        'IndentOutdent': IndentAction.IndentOutdent,
        'Outdent': IndentAction.Outdent,
      },
      ia,
    );
  });

  group('batch314 onEnter truth replay', () {
    for (final dynamic raw in truth['cases'] as List<dynamic>) {
      final Map<String, dynamic> c = raw as Map<String, dynamic>;
      test(c['name'] as String, () {
        final OnEnterSupport support =
            OnEnterSupport(_options(c['options'] as Map<String, dynamic>));
        final List<Object?> actual = <Object?>[];
        for (final dynamic rawCall in c['calls'] as List<dynamic>) {
          final Map<String, dynamic> call = rawCall as Map<String, dynamic>;
          final EnterAction? result = support.onEnter(
            call['autoIndent'] as int,
            call['previous'] as String,
            call['before'] as String,
            call['after'] as String,
          );
          actual.add(<String, Object?>{
            'label': call['label'],
            'autoIndent': call['autoIndent'],
            'before': call['before'],
            'after': call['after'],
            'previous': call['previous'],
            'result': _actionJson(result),
          });
        }
        expect(actual, c['calls']);
      });
    }
  });
}
