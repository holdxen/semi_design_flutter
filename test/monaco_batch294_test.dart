// batch294: semanticTokensProviderStyling.ts truth replay.
// Truth from tool/ts2dart/batch294_truth.json (recursive TS transpile + vm,
// real styling / HashTable / toMultilineTokens2 with fake theme/log services).
import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:semi_design_flutter/src/monaco/editor/common/services/semanticTokensProviderStyling.dart'
    show
        IColorThemeForSemanticStyling,
        ILanguageServiceForSemanticStyling,
        ILogServiceForSemanticStyling,
        IThemeServiceForSemanticStyling,
        SemanticTokensProviderStyling,
        toMultilineTokens2;
import 'package:semi_design_flutter/src/monaco/editor/contrib/semanticTokens/common/getSemanticTokens.dart'
    show SemanticTokens, SemanticTokensLegend;
import 'package:semi_design_flutter/src/monaco/platform/theme/common/themeService.dart'
    show ITokenStyle;

Map<String, dynamic> _truth() => jsonDecode(
    File('tool/ts2dart/batch294_truth.json').readAsStringSync())
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

class _Theme implements IThemeServiceForSemanticStyling, IColorThemeForSemanticStyling {
  _Theme(this._styles);

  final Map<String, dynamic> _styles;

  @override
  Object getColorTheme() => this;

  @override
  ITokenStyle? getTokenStyleMetadata(
      String type, List<String> modifiers, String modelLanguage) {
    final String key = '$type|${modifiers.join(',')}';
    final Map<String, dynamic>? d = _styles[key] as Map<String, dynamic>?;
    if (d == null) return null;
    return ITokenStyle(
      foreground: d['foreground'] == null ? null : _i(d['foreground']),
      italic: d['italic'] as bool?,
      bold: d['bold'] as bool?,
      underline: d['underline'] as bool?,
      strikethrough: d['strikethrough'] as bool?,
    );
  }
}

class _Languages implements ILanguageServiceForSemanticStyling {
  final Map<String, int> _ids = <String, int>{};
  int _next = 1;

  @override
  int encodeLanguageId(String languageId) {
    final int? id = _ids[languageId];
    if (id != null) return id;
    final int next = _next++;
    _ids[languageId] = next;
    return next;
  }
}

class _Log implements ILogServiceForSemanticStyling {
  final List<Object?> warnings = <Object?>[];

  @override
  void warn(Object message) => warnings.add(message);
}

void main() {
  final Map<String, dynamic> truth = _truth();
  group('batch294 semanticTokensProviderStyling truth replay', () {
    for (final dynamic rawCase in truth['cases'] as List<dynamic>) {
      final Map<String, dynamic> c = rawCase as Map<String, dynamic>;
      test(c['name'] as String, () {
        final Map<String, dynamic> legendData = c['legend'] as Map<String, dynamic>;
        final SemanticTokensLegend legend = SemanticTokensLegend(
          (legendData['tokenTypes'] as List<dynamic>).cast<String>(),
          (legendData['tokenModifiers'] as List<dynamic>).cast<String>(),
        );
        final _Theme theme = _Theme(c['styles'] as Map<String, dynamic>);
        final _Log log = _Log();
        final SemanticTokensProviderStyling styling =
            SemanticTokensProviderStyling(legend, theme, _Languages(), log);

        final List<dynamic> ops = c['ops'] as List<dynamic>;
        final List<dynamic> results = c['results'] as List<dynamic>;
        for (int opIndex = 0; opIndex < ops.length; opIndex++) {
          final Map<String, dynamic> op = ops[opIndex] as Map<String, dynamic>;
          final Map<String, dynamic> expected =
              results[opIndex] as Map<String, dynamic>;
          switch (op['kind'] as String) {
            case 'metadata':
              final List<Object?> values = <Object?>[];
              for (final dynamic rawQuery in op['queries'] as List<dynamic>) {
                final Map<String, dynamic> q = rawQuery as Map<String, dynamic>;
                values.add(<Object?>[
                  styling.getMetadata(_i(q['type']), _i(q['mods']), q['lang'] as String),
                ]);
              }
              expect(
                <String, Object?>{
                  'label': op['label'],
                  'values': values,
                  'warnings': log.warnings,
                },
                _norm(expected),
              );
              break;
            case 'toMultiline':
              final SemanticTokens tokens = SemanticTokens(
                (op['data'] as List<dynamic>).map(_i).toList(),
              );
              final pieces = toMultilineTokens2(
                  tokens, styling, op['languageId'] as String);
              final List<Object?> pieceJson = pieces.map((p) {
                final r = p.getRange();
                return <String, Object?>{
                  'start': p.startLineNumber,
                  'end': p.endLineNumber,
                  'str': p.toString(),
                  'range': r == null
                      ? null
                      : <Object?>[
                          r.startLineNumber,
                          r.startColumn,
                          r.endLineNumber,
                          r.endColumn,
                        ],
                };
              }).toList();
              expect(
                <String, Object?>{
                  'label': op['label'],
                  'pieces': pieceJson,
                  'warnings': log.warnings,
                },
                _norm(expected),
              );
              break;
            case 'warn':
              switch (op['what'] as String) {
                case 'overlap':
                  styling.warnOverlappingSemanticTokens(_i(op['line']), _i(op['column']));
                  styling.warnOverlappingSemanticTokens(_i(op['line']), _i(op['column']));
                  break;
                case 'length':
                  styling.warnInvalidLengthSemanticTokens(_i(op['line']), _i(op['column']));
                  styling.warnInvalidLengthSemanticTokens(_i(op['line']), _i(op['column']));
                  break;
                case 'start':
                  styling.warnInvalidEditStart('r1', 'r2', _i(op['index']),
                      _i(op['start']), _i(op['max']));
                  styling.warnInvalidEditStart('r1', 'r2', _i(op['index']),
                      _i(op['start']), _i(op['max']));
                  break;
                case 'deleteCount':
                  styling.warnInvalidEditDeleteCount('r1', 'r2', _i(op['src']), _i(op['delta']));
                  styling.warnInvalidEditDeleteCount('r1', 'r2', _i(op['src']), _i(op['delta']));
                  break;
                default:
                  fail('unknown warn ${op['what']}');
              }
              expect(
                <String, Object?>{
                  'label': op['label'],
                  'warnings': log.warnings,
                },
                _norm(expected),
              );
              break;
            default:
              fail('unknown op ${op['kind']}');
          }
        }
      });
    }
  });
}
