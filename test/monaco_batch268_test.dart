// batch268: textualHighlightProvider.ts truth replay.
// Truth from tool/ts2dart/batch268_truth.json (recursive TS transpile+vm,
// fake models recording findMatches arguments).
import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:semi_design_flutter/src/monaco/base/common/cancellation.dart'
    show CancellationToken;
import 'package:semi_design_flutter/src/monaco/base/common/uri.dart' show URI;
import 'package:semi_design_flutter/src/monaco/editor/common/core/position.dart'
    show Position;
import 'package:semi_design_flutter/src/monaco/editor/common/core/range.dart'
    show IRange, Range;
import 'package:semi_design_flutter/src/monaco/editor/common/core/wordHelper.dart'
    show IWordAtPosition;
import 'package:semi_design_flutter/src/monaco/editor/common/services/languageFeaturesService.dart'
    show LanguageFeaturesService;
import 'package:semi_design_flutter/src/monaco/editor/contrib/wordHighlighter/browser/textualHighlightProvider.dart'
    show
        DocumentHighlight,
        IFindMatch,
        ITextualHighlightModel,
        TextualDocumentHighlightProvider,
        TextualMultiDocumentHighlightFeature;

Map<String, dynamic> _truth() => jsonDecode(
    File('tool/ts2dart/batch268_truth.json').readAsStringSync())
    as Map<String, dynamic>;

class _Match implements IFindMatch {
  @override
  final IRange range;

  _Match(List<dynamic> r)
      : range = Range(r[0] as int, r[1] as int, r[2] as int, r[3] as int);
}

class _Model implements ITextualHighlightModel {
  @override
  final URI uri;
  final bool disposed;
  final String? word;
  final List<_Match> matches;
  final List<Map<String, dynamic>> findCalls;

  _Model(Map<String, dynamic> def, this.findCalls)
      : uri = URI.parse(def['uri'] as String),
        disposed = def['disposed'] as bool? ?? false,
        word = def['word'] as String?,
        matches = (def['matches'] as List<dynamic>)
            .map((r) => _Match(r as List<dynamic>))
            .toList();

  @override
  bool isDisposed() => disposed;

  @override
  IWordAtPosition? getWordAtPosition(Position position) {
    if (word == null) return null;
    return IWordAtPosition(
      word: word!,
      startColumn: position.column,
      endColumn: position.column + word!.length,
    );
  }

  @override
  List<IFindMatch> findMatches(
    String word,
    bool searchOnlyEditableRange,
    bool isRegex,
    bool matchCase,
    String wordSeparators,
    bool captureMatches,
  ) {
    findCalls.add(<String, dynamic>{
      'uri': uri.toString(),
      'word': word,
      'searchOnlyEditableRange': searchOnlyEditableRange,
      'isRegex': isRegex,
      'matchCase': matchCase,
      'separators': wordSeparators,
      'captureMatches': captureMatches,
    });
    return matches;
  }
}

List<int> _rangeOut(IRange r) => <int>[
  r.startLineNumber,
  r.startColumn,
  r.endLineNumber,
  r.endColumn,
];

Object? _highlightsOut(List<DocumentHighlight>? highlights) =>
    highlights
        ?.map((h) => <String, dynamic>{
              'range': _rangeOut(h.range),
              'kind': h.kind,
            })
        .toList();

void main() {
  final t = _truth();
  final provider = TextualDocumentHighlightProvider();

  for (final raw in t['cases'] as List<dynamic>) {
    final c = raw as Map<String, dynamic>;
    test('b268 ${c['name']}: ${c['op']} highlights match truth', () {
      final findCalls = <Map<String, dynamic>>[];
      final models = (c['models'] as List<dynamic>)
          .map((m) => _Model(m as Map<String, dynamic>, findCalls))
          .toList();
      final pos = c['position'] as List<dynamic>;
      final position = Position(pos[0] as int, pos[1] as int);

      Object? output;
      if (c['op'] == 'document') {
        output = _highlightsOut(
          provider.provideDocumentHighlights(
              models.first, position, CancellationToken.none),
        );
      } else {
        final map = provider.provideMultiDocumentHighlights(
          models.first,
          position,
          models.skip(1).toList(),
          CancellationToken.none,
        );
        output = map?.iterable
            .map((entry) => <String, dynamic>{
                  'uri': entry.$1.toString(),
                  'highlights': _highlightsOut(entry.$2),
                })
            .toList();
      }

      expect(provider.selector.language, '*');
      expect(findCalls, c['findCalls']);
      expect(output, c['output']);
    });
  }

  test('b268 feature registers both providers', () {
    final service = LanguageFeaturesService();
    final feature = TextualMultiDocumentHighlightFeature(service);
    final reg = t['registration'] as Map<String, dynamic>;

    expect(service.documentHighlightProvider.allNoModel().length,
        reg['documentCount']);
    expect(service.multiDocumentHighlightProvider.allNoModel().length,
        reg['multiCount']);
    expect(TextualDocumentHighlightProvider().selector.language,
        reg['selectorLanguage']);
    expect(reg['disposable'], isTrue);
    expect(() => feature.dispose(), returnsNormally);
  });
}
