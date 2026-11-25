// 1:1 replay of `editor/common/viewModel/viewModelDecoration.ts`.
// Truth: `tool/ts2dart/_batch417_truth.cjs` -> `batch417_truth.json`.
import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import '../lib/src/monaco/editor/common/core/range.dart' show Range;
import '../lib/src/monaco/editor/common/encodedTokenAttributes.dart'
    show StandardTokenType;
import '../lib/src/monaco/editor/common/viewModel.dart'
    show ViewModelDecoration;
import '../lib/src/monaco/editor/common/viewModel/viewModelDecoration.dart';

Map<String, dynamic> _map(dynamic v) => (v as Map).cast<String, dynamic>();

Map<String, dynamic> _truth() {
  final Map<String, dynamic> root = _map(
    jsonDecode(File('tool/ts2dart/batch417_truth.json').readAsStringSync()),
  );
  return <String, dynamic>{
    for (final dynamic r in root['results'] as List<dynamic>)
      (r as Map)['label'] as String: <String, dynamic>{
        for (final MapEntry<Object?, Object?> e
            in (r as Map).cast<Object?, Object?>().entries)
          if (e.key != 'label') e.key as String: e.value,
      },
  };
}

class _Token {
  final int startOffset;
  final int type;
  _Token(this.startOffset, this.type);
}

class _LineTokens {
  final List<_Token> tokens;
  _LineTokens(this.tokens);

  int getCount() => tokens.length;
  int getStartOffset(int i) => tokens[i].startOffset;
  int getStandardTokenType(int i) => tokens[i].type;
  int findTokenIndexAtOffset(int offset) {
    int idx = 0;
    for (int i = 0; i < tokens.length; i++) {
      if (tokens[i].startOffset <= offset) idx = i;
    }
    return idx;
  }
}

class _Model {
  final Map<int, _LineTokens> lines;
  _Model(this.lines);
  Object get tokenization => _Tokenization(this);
}

class _Tokenization {
  final _Model model;
  _Tokenization(this.model);
  Object getLineTokens(int lineNumber) =>
      model.lines[lineNumber] ?? _LineTokens(<_Token>[]);
}

_LineTokens _lineTokens(List<List<int>> spec) =>
    _LineTokens(spec.map((List<int> t) => _Token(t[0], t[1])).toList());

class _Decoration {
  final Range range;
  final Object options;
  _Decoration(this.range, this.options);
}

_Decoration _dec(int sl, int sc, int el, int ec,
        [Map<String, Object?> options = const <String, Object?>{}]) =>
    _Decoration(Range(sl, sc, el, ec), options);

void main() {
  final Map<String, dynamic> truth = _truth();

  test('view model decoration replay TS truth', () {
    final Map<String, Object?> actual = <String, Object?>{};

    // ctor
    {
      final ViewModelDecoration d =
          ViewModelDecoration(Range(1, 2, 3, 4), <String, Object?>{'inlineClassName': 'x'});
      actual['ctor'] = <String, Object?>{
        'range': <Object?>[
          d.range.startLineNumber,
          d.range.startColumn,
          d.range.endLineNumber,
          d.range.endColumn,
        ],
        'options': d.options,
      };
    }

    // default visible
    {
      final _Model model = _Model(<int, _LineTokens>{
        1: _lineTokens(<List<int>>[
          <int>[0, StandardTokenType.comment],
        ]),
      });
      final Object d = _dec(1, 1, 1, 5);
      actual['default-visible'] = <String, Object?>{
        'visible': isModelDecorationVisible(model, d),
        'inComment': isModelDecorationInComment(model, d),
        'inString': isModelDecorationInString(model, d),
      };
    }

    // hide comment
    {
      final _Model model = _Model(<int, _LineTokens>{
        1: _lineTokens(<List<int>>[
          <int>[0, StandardTokenType.comment],
        ]),
      });
      actual['hide-comment'] = <String, Object?>{
        'visible': isModelDecorationVisible(
          model,
          _dec(1, 1, 1, 5, <String, Object?>{'hideInCommentTokens': true}),
        ),
      };
    }

    // hide string
    {
      final _Model model = _Model(<int, _LineTokens>{
        1: _lineTokens(<List<int>>[
          <int>[0, StandardTokenType.string],
        ]),
      });
      actual['hide-string'] = <String, Object?>{
        'visible': isModelDecorationVisible(
          model,
          _dec(1, 1, 1, 5, <String, Object?>{'hideInStringTokens': true}),
        ),
      };
    }

    // multi-line
    {
      final _Model model = _Model(<int, _LineTokens>{
        1: _lineTokens(<List<int>>[
          <int>[0, StandardTokenType.other],
        ]),
        2: _lineTokens(<List<int>>[
          <int>[0, StandardTokenType.other],
          <int>[3, StandardTokenType.comment],
        ]),
        3: _lineTokens(<List<int>>[
          <int>[0, StandardTokenType.other],
        ]),
      });
      actual['multi-line'] = <String, Object?>{
        'inComment': isModelDecorationInComment(model, _dec(1, 1, 3, 3)),
        'visibleWithHide': isModelDecorationVisible(
          model,
          _dec(1, 1, 3, 3, <String, Object?>{'hideInCommentTokens': true}),
        ),
      };
    }

    // end clip
    {
      final _Model model = _Model(<int, _LineTokens>{
        1: _lineTokens(<List<int>>[
          <int>[0, StandardTokenType.other],
          <int>[4, StandardTokenType.comment],
        ]),
      });
      actual['end-clip'] = <String, Object?>{
        'inCommentShort': isModelDecorationInComment(model, _dec(1, 1, 1, 3)),
        'inCommentLong': isModelDecorationInComment(model, _dec(1, 1, 1, 8)),
      };
    }

    for (final String key in truth.keys) {
      expect(
        jsonEncode(actual[key]),
        jsonEncode(truth[key]),
        reason: 'mismatch at $key',
      );
    }
  });
}
