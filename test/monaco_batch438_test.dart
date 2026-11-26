import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import '../lib/src/monaco/base/common/cancellation.dart'
    show CancellationToken, CancellationTokenSource;
import '../lib/src/monaco/base/common/lifecycle.dart' show IDisposable;
import '../lib/src/monaco/editor/common/core/position.dart' show Position;
import '../lib/src/monaco/editor/common/core/range.dart' show Range;
import '../lib/src/monaco/editor/contrib/inlayHints/browser/inlayHints.dart'
    show
        CommandLike,
        InlayHintAnchor,
        InlayHintItem,
        InlayHintsFragments,
        asCommandLink, reportUnexpectedError;

Map<String, dynamic> _truth() {
  final Map<String, dynamic> root =
      jsonDecode(File('tool/ts2dart/batch438_truth.json').readAsStringSync())
          as Map<String, dynamic>;
  return <String, dynamic>{
    for (final dynamic r in root['results'] as List<dynamic>)
      (r as Map)['label'] as String: <String, dynamic>{
        for (final MapEntry<Object?, Object?> e
            in (r as Map).cast<Object?, Object?>().entries)
          if (e.key != 'label') e.key as String: e.value,
      },
  };
}

class _Hint {
  String label;
  Object? tooltip;
  Object? textEdits;
  final Position position;
  _Hint(this.label, this.position, [this.tooltip]);

  Map<String, Object?> toJson() => <String, Object?>{
        'label': label,
        if (tooltip != null) 'tooltip': tooltip,
        'line': position.lineNumber,
        'col': position.column,
      };
}

class _List implements IDisposable {
  final List<dynamic> hints;
  _List(this.hints);
  @override
  void dispose() {}
}

class _Provider {
  final Future<_List> Function() provide;
  final bool hasOnDidChange;
  _Provider(this.provide, [this.hasOnDidChange = false]);
  Future<_List?> provideInlayHints(Object model, Range range, Object token) =>
      provide();
  Object? get onDidChangeInlayHints => hasOnDidChange ? (_) {} : null;
}

class _Registry {
  final List<Object> providers;
  _Registry(this.providers);
  List<Object> ordered(Object model) => providers;
}

class _Word {
  final int startColumn;
  final int endColumn;
  _Word(this.startColumn, this.endColumn);
}

class _Tokens {
  final List<int> offsets;
  _Tokens(this.offsets);
  int findTokenIndexAtOffset(int offset) {
    for (int i = 0; i < offsets.length; i++) {
      if (offset < offsets[i]) return i;
    }
    return offsets.length - 1;
  }
  int getStartOffset(int i) => i > 0 ? offsets[i - 1] : 0;
  int getEndOffset(int i) => i < offsets.length ? offsets[i] : offsets.last;
  int getCount() => offsets.length;
}

class _Tokenization {
  final Map<int, _Tokens> tokens;
  _Tokenization(this.tokens);
  void tokenizeIfCheap(int line) {}
  _Tokens getLineTokens(int line) => tokens[line] ?? _Tokens(<int>[0, 10]);
}

class _Model {
  final Map<int, _Word> words;
  final Map<int, _Tokens> tokens;
  _Model(this.words, this.tokens);
  bool isDisposed() => false;
  Position validatePosition(Position p) => p;
  _Word? getWordAtPosition(Position p) => words[p.lineNumber];
  _Tokenization get tokenization => _Tokenization(tokens);
}

void main() {
  final Map<String, dynamic> truth = _truth();
  final CancellationToken token = CancellationTokenSource().token;

  test('inlay hints truth replay', () async {
    int errorCount = 0;
    reportUnexpectedError = (_) { errorCount++; };
    final Map<String, Object?> actual = <String, Object?>{};

    Future<void> runAsync() async {
      // create + sort
      {
        final model = _Model(<int, _Word>{}, <int, _Tokens>{});
        final p1 = _Provider(() async => _List(<dynamic>[
              _Hint('a', Position(3, 5), 't1'),
              _Hint('b', Position(1, 2)),
            ]));
        final p2 = _Provider(() async => _List(<dynamic>[
              _Hint('c', Position(2, 4)),
            ]));
        final f = await InlayHintsFragments.create(
          _Registry(<Object>[p1, p2]),
          model,
          <Range>[Range(1, 1, 5, 1)],
          token,
        );
        actual['create'] = <String, Object?>{
          'items': f.items.map((InlayHintItem it) => <String, Object?>{
                'hint': (it.hint as _Hint).toJson(),
                'range': <Object?>[
                  it.anchor.range.startLineNumber,
                  it.anchor.range.startColumn,
                  it.anchor.range.endColumn,
                ],
                'direction': it.anchor.direction,
              }).toList(),
          'providers': f.providers.length,
          'ranges': f.ranges
              .map((Range r) => <Object?>[r.startLineNumber, r.endLineNumber])
              .toList(),
        };
        f.dispose();
      }
      // empty provider with onDidChange
      {
        final model = _Model(<int, _Word>{}, <int, _Tokens>{});
        final p = _Provider(() async => _List(<dynamic>[]), true);
        final f = await InlayHintsFragments.create(
          _Registry(<Object>[p]), model, <Range>[Range(1, 1, 2, 1)], token);
        actual['empty-provider'] = <String, Object?>{
          'items': f.items.length,
          'providers': f.providers.length,
        };
      }
      // throwing provider
      {
        final model = _Model(<int, _Word>{}, <int, _Tokens>{});
        final p = _Provider(() async => throw StateError('boom'));
        final f = await InlayHintsFragments.create(
          _Registry(<Object>[p]), model, <Range>[Range(1, 1, 2, 1)], token);
        actual['throwing'] = <String, Object?>{'items': f.items.length, 'errors': errorCount};
      }
      // cancelled token
      {
        final model = _Model(<int, _Word>{}, <int, _Tokens>{});
        final p = _Provider(() async => _List(<dynamic>[_Hint('x', Position(1, 1))]));
        final CancellationTokenSource cts = CancellationTokenSource();
        cts.cancel();
        bool threw = false;
        try {
          await InlayHintsFragments.create(
            _Registry(<Object>[p]), model, <Range>[Range(1, 1, 2, 1)], cts.token);
        } catch (_) {
          threw = true;
        }
        actual['cancelled'] = <String, Object?>{'threw': threw};
      }
      // word range
      {
        final model = _Model(<int, _Word>{2: _Word(2, 6)}, <int, _Tokens>{});
        final p = _Provider(() async => _List(<dynamic>[_Hint('word', Position(2, 4))]));
        final f = await InlayHintsFragments.create(
          _Registry(<Object>[p]), model, <Range>[Range(1, 1, 3, 1)], token);
        actual['word-range'] = <String, Object?>{
          'items': f.items.map((InlayHintItem it) => <String, Object?>{
                'range': <Object?>[
                  it.anchor.range.startLineNumber,
                  it.anchor.range.startColumn,
                  it.anchor.range.endColumn,
                ],
                'direction': it.anchor.direction,
              }).toList(),
        };
      }
      // resolve
      {
        final hint = _Hint('old', Position(1, 1), 'oldtip');
        final provider = _ResolveProvider();
        final item = InlayHintItem(
          hint, InlayHintAnchor(Range(1, 1, 1, 1), 'before'), provider);
        await item.resolve(token);
        actual['resolve'] = <String, Object?>{'hint': hint.toJson()};
      }
      // resolve noop
      {
        final hint = _Hint('same', Position(1, 1));
        final item = InlayHintItem(
          hint, InlayHintAnchor(Range(1, 1, 1, 1), 'before'), Object());
        await item.resolve(token);
        actual['resolve-noop'] = <String, Object?>{'hint': hint.toJson()};
      }
      // with()
      {
        final hint = _Hint('x', Position(1, 1));
        final provider = _ResolveProvider();
        final item = InlayHintItem(
          hint, InlayHintAnchor(Range(1, 1, 1, 1), 'before'), provider);
        await item.resolve(token);
        final copy = item.withAnchor(InlayHintAnchor(Range(2, 1, 2, 1), 'after'));
        await copy.resolve(token);
        actual['with'] = <String, Object?>{
          'sameHint': identical(copy.hint, hint),
          'anchor': <Object?>[copy.anchor.range.startLineNumber, copy.anchor.direction],
        };
      }
      // command link
      actual['command-link'] = <String, Object?>{
        'link': asCommandLink(CommandLike('editor.action.x', <Object?>['a', 2])),
      };
    }

    await runAsync();
    expect(jsonEncode(actual), jsonEncode(truth));
  });
}

class _ResolveProvider {
  Future<Object?> resolveInlayHint(Object hint, Object token) async {
    final dynamic h = hint;
    return _Hint('new', h.position as Position, 'newtip');
  }
}
