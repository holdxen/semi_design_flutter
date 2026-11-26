// 1:1 replay of
//   editor/common/languages/supports/indentRules.ts (83 lines)
//   editor/common/diff/linesDiffWithFallback.ts (71 lines)
//   editor/contrib/hover/browser/glyphHoverComputer.ts (62 lines)
// Truth: `tool/ts2dart/_batch338_truth.cjs` -> `batch338_truth.json`.
import 'dart:async' show FutureOr;
import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import '../lib/src/monaco/base/common/errors.dart' show errorHandler;
import '../lib/src/monaco/base/common/htmlContent.dart' show MarkdownString;
import '../lib/src/monaco/editor/common/diff/linesDiffComputer.dart'
    show ILinesDiffComputer, ILinesDiffComputerOptions, LinesDiff;
import '../lib/src/monaco/editor/common/diff/linesDiffWithFallback.dart'
    show resolveLinesDiffComputerWithFallback;
import '../lib/src/monaco/editor/common/languages/languageConfiguration.dart'
    show IndentationRule;
import '../lib/src/monaco/editor/common/languages/supports/indentRules.dart'
    show IndentConsts, IndentRulesSupport;
import '../lib/src/monaco/editor/common/model.dart' show GlyphMarginLane;
import '../lib/src/monaco/editor/contrib/hover/browser/glyphHoverComputer.dart'
    show
        GlyphHoverComputer,
        GlyphHoverComputerOptions,
        GlyphMarginOption,
        ICodeEditorForGlyphHover,
        IModelDecorationForGlyphHover,
        IModelDecorationOptionsForGlyphHover;

Map<String, dynamic> _map(dynamic value) =>
    (value as Map).cast<String, dynamic>();

Map<String, dynamic> _truth() => _map(
      jsonDecode(File('tool/ts2dart/batch338_truth.json').readAsStringSync()),
    );

class _FakeComputer implements ILinesDiffComputer {
  const _FakeComputer(this.throws);

  final bool throws;

  @override
  LinesDiff computeDiff(
    List<String> originalLines,
    List<String> modifiedLines,
    ILinesDiffComputerOptions options,
  ) {
    if (throws) {
      throw StateError('boom');
    }
    return LinesDiff(const [], const [], false);
  }
}

Future<Map<String, Object?>> _call(
  String algorithm,
  FutureOr<ILinesDiffComputer> Function(String algorithm) resolve,
  List<String> lines,
  bool verify,
) async {
  final computer = await resolveLinesDiffComputerWithFallback(algorithm, resolve);
  final result = computer(
    const <String>['a', 'b'],
    lines,
    const ILinesDiffComputerOptions(
      ignoreTrimWhitespace: false,
      maxComputationTimeMs: 0,
      computeMoves: false,
    ),
    verify,
  );
  return <String, Object?>{
    'fallback': result.fallback,
    'validity': result.validity,
    'changes': result.result.changes.length,
    'hitTimeout': result.result.hitTimeout,
  };
}

class _Options implements IModelDecorationOptionsForGlyphHover {
  _Options(this.glyphMargin, this.lineNumberHoverMessage,
      this.glyphMarginHoverMessage);

  @override
  final GlyphMarginOption? glyphMargin;
  @override
  final Object? lineNumberHoverMessage;
  @override
  final Object? glyphMarginHoverMessage;
}

class _Decoration implements IModelDecorationForGlyphHover {
  const _Decoration(this.options);

  @override
  final IModelDecorationOptionsForGlyphHover options;
}

class _Editor implements ICodeEditorForGlyphHover {
  const _Editor(this.decorations);

  final List<IModelDecorationForGlyphHover>? decorations;

  @override
  List<IModelDecorationForGlyphHover>? getLineDecorations(int lineNumber) =>
      lineNumber == 7 ? decorations : null;
}

void main() {
  test('indent rules replay TS with global regexes', () {
    final rules = IndentationRule(
      decreaseIndentPattern: RegExp(r'^\s*\}'),
      increaseIndentPattern: RegExp(r'\{\s*$'),
      indentNextLinePattern: RegExp(r'if\s*\(.*\)\s*$'),
      unIndentedLinePattern: RegExp(r'^\s*#'),
    );
    final support = IndentRulesSupport(rules);
    const texts = <String>[
      '}',
      'if (x) {',
      'if (x)',
      '# comment',
      'plain',
      '} {',
      '  }',
    ];

    final actual = <String, Object?>{
      'constants': <int>[
        IndentConsts.INCREASE_MASK,
        IndentConsts.DECREASE_MASK,
        IndentConsts.INDENT_NEXTLINE_MASK,
        IndentConsts.UNINDENT_MASK,
      ],
      'lastIndexInitially': 0,
      'lines': texts
          .map((String text) => <String, Object?>{
                'text': text,
                'increase': support.shouldIncrease(text),
                'decrease': support.shouldDecrease(text),
                'next': support.shouldIndentNextLine(text),
                'ignore': support.shouldIgnore(text),
                'metadata': support.getIndentMetadata(text),
              })
          .toList(),
      'lastIndexAfterCalls': 0,
    };
    expect(actual, _map(_truth()['indentRules']));
  });

  test('diff fallback replay TS', () async {
    // TS onUnexpectedError defers rethrowing to a timer; the harness stubs it.
    final previousHandler = errorHandler.getUnexpectedErrorHandler();
    errorHandler.setUnexpectedErrorHandler((_) {});
    addTearDown(() => errorHandler.setUnexpectedErrorHandler(previousHandler));

    const sameLines = <String>['a', 'b'];
    const otherLines = <String>['x', 'y'];
    final goodComputer = _FakeComputer(false);
    final badComputer = _FakeComputer(true);

    final actual = <String, Object?>{
      'builtinResolveThrows': await (() async {
        try {
          await resolveLinesDiffComputerWithFallback(
              'legacy', (String _) => throw StateError('nope'));
          return 'resolved';
        } catch (_) {
          return 'threw';
        }
      })(),
      'packageResolveThrows': await _call(
        'advanced-wasm',
        (String _) => throw StateError('nope'),
        sameLines,
        true,
      ),
      'goodValid': await _call('legacy', (String _) => goodComputer, sameLines, true),
      'goodInvalid': await _call('legacy', (String _) => goodComputer, otherLines, true),
      'packageInvalid': await _call(
          'advanced-external', (String _) => goodComputer, otherLines, true),
      'noVerify': await _call('legacy', (String _) => goodComputer, otherLines, false),
      'packageThrows': await _call('advanced-wasm', (String _) => badComputer, sameLines, true),
      'builtinThrows': await (() async {
        try {
          await _call('legacy', (String _) => badComputer, sameLines, true);
          return 'resolved';
        } catch (_) {
          return 'threw';
        }
      })(),
    };
    expect(actual, _map(_truth()['diffFallback']));
  });

  test('glyph hover replay TS', () {
    MarkdownString md(String value) => MarkdownString(value);
    _Decoration dec(Object? glyphHoverMessage, Object? lineHoverMessage,
            int? lane) =>
        _Decoration(_Options(
          lane == null ? null : GlyphMarginOption(lane),
          lineHoverMessage,
          glyphHoverMessage,
        ));

    final decorations = <IModelDecorationForGlyphHover>[
      dec(md('center'), null, GlyphMarginLane.Center),
      dec(md('left'), null, GlyphMarginLane.Left),
      dec(null, md('line one'), GlyphMarginLane.Right),
      dec(md(''), null, GlyphMarginLane.Center),
      dec(<MarkdownString>[md('multi a'), md('multi b')], null,
          GlyphMarginLane.Center),
      dec(md('no lane'), null, null),
    ];
    final computer = GlyphHoverComputer(_Editor(decorations));
    List<Object?> shown(Object laneOrLine) => computer
        .computeSync(GlyphHoverComputerOptions(
          lineNumber: 7,
          laneOrLine: laneOrLine,
        ))
        .map((m) => m.value.value)
        .toList();

    final actual = <String, Object?>{
      'constants': <int>[
        GlyphMarginLane.Left,
        GlyphMarginLane.Center,
        GlyphMarginLane.Right,
      ],
      'lineNo': shown('lineNo'),
      'center': shown(GlyphMarginLane.Center),
      'left': shown(GlyphMarginLane.Left),
      'right': shown(GlyphMarginLane.Right),
      'noDecorations': computer
          .computeSync(const GlyphHoverComputerOptions(
            lineNumber: 1,
            laneOrLine: 'lineNo',
          ))
          .map((m) => m.value.value)
          .toList(),
    };
    expect(actual, _map(_truth()['glyphHover']));
  });
}
