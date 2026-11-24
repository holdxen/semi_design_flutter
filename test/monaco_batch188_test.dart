import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import '../lib/src/monaco/base/common/uri.dart' show URI;
import '../lib/src/monaco/editor/common/multiDiffEditor.dart' as mde;
import '../lib/src/monaco/platform/editor/common/editor.dart'
    show ITextEditorSelection;
import '../lib/src/monaco/platform/opener/common/opener.dart' as op;

Map<String, dynamic> _map(dynamic value) =>
    (value as Map).cast<String, dynamic>();

List<dynamic> _list(dynamic value) => value as List<dynamic>;

/// Mirrors uriJson() from the Node truth harness.
Map<String, Object?> _uriJson(URI uri) => <String, Object?>{
      '\$mid': 1,
      'scheme': uri.scheme,
      'authority': uri.authority,
      'path': uri.path,
      'query': uri.query,
      'fragment': uri.fragment,
      'toString': uri.toString(),
    };

Object? _selectionJson(ITextEditorSelection? selection) {
  if (selection == null) return null;
  return <String, Object?>{
    'startLineNumber': selection.startLineNumber,
    'startColumn': selection.startColumn,
    'endLineNumber': selection.endLineNumber,
    'endColumn': selection.endColumn,
  };
}

ITextEditorSelection _selectionFromTruth(dynamic raw) {
  final Map<String, dynamic> value = _map(raw);
  return ITextEditorSelection(
    startLineNumber: value['startLineNumber'] as num,
    startColumn: value['startColumn'] as num,
    endLineNumber: value['endLineNumber'] as num?,
    endColumn: value['endColumn'] as num?,
  );
}

URI _uriFromTruth(dynamic raw) =>
    URI.parse((_map(raw)['toString'] as String?) ?? '');

void main() {
  final Map<String, dynamic> truth = _map(
    jsonDecode(File('tool/ts2dart/batch188_truth.json').readAsStringSync()),
  );

  group('batch188 declarations', () {
    test('declaration carrier surface matches TypeScript declarations', () {
      final Map<String, dynamic> declarations = _map(truth['declarations']);
      expect(_list(declarations['multiDiffEditor']), <String>[
        'IMultiDiffEditorOptions',
        'IMultiDiffEditorOptionsViewState',
        'IMultiDiffResourceId',
        'MultiDiffEditorVariant',
        'multiDiffEditorVariants',
      ]);
      expect(_list(declarations['opener']), <String>[
        'IExternalOpener',
        'IExternalUriOpenContext',
        'IExternalUriResolver',
        'IOpener',
        'IOpenerService',
        'IResolvedExternalUri',
        'IValidator',
        'OpenExternalOptions',
        'OpenInternalOptions',
        'OpenOptions',
        'ResolveExternalUriOptions',
        'defaultExternalUriOpenerId',
        'extractSelection',
        'withSelection',
      ]);
      expect(
        <Type>[
          mde.IMultiDiffEditorOptions,
          mde.IMultiDiffEditorOptionsViewState,
          mde.IMultiDiffEditorOptionsViewStateRevealData,
          mde.IMultiDiffResourceId,
          op.IExternalOpener,
          op.IExternalUriOpenContext,
          op.IExternalUriResolver,
          op.IOpener,
          op.IOpenerServiceType,
          op.IResolvedExternalUri,
          op.IValidator,
          op.OpenExternalOptions,
          op.OpenInternalOptions,
          op.OpenOptions,
          op.ResolveExternalUriOptions,
          op.ExtractSelectionResult,
        ],
        isNotEmpty,
      );
    });
  });

  group('batch188 runtime truth', () {
    test('multiDiffEditor exports and variants match truth', () {
      final Map<String, dynamic> data = _map(truth['multiDiffEditor']);
      expect(_list(data['exports']), <String>['multiDiffEditorVariants']);
      expect(mde.multiDiffEditorVariants, data['variants']);
    });

    test('opener exports and constants match truth', () {
      final Map<String, dynamic> data = _map(truth['opener']);
      expect(_list(data['exports']), <String>[
        'IOpenerService',
        'defaultExternalUriOpenerId',
        'extractSelection',
        'withSelection',
      ]);
      final Map<String, dynamic> constants = _map(data['constants']);
      expect(op.defaultExternalUriOpenerId, constants['defaultExternalUriOpenerId']);
      expect(op.IOpenerService.toString(), constants['IOpenerService']);
    });

    test('withSelection matches truth for all selection shapes', () {
      final Map<String, dynamic> data = _map(truth['opener']);
      for (final dynamic raw in _list(data['withSelection'])) {
        final Map<String, dynamic> rawCase = _map(raw);
        final URI result = op.withSelection(
          _uriFromTruth(rawCase['input']),
          _selectionFromTruth(rawCase['selection']),
        );
        expect(_uriJson(result), rawCase['result'], reason: rawCase['name'] as String);
        expect(result.toString(), rawCase['resultString'], reason: rawCase['name'] as String);
      }
    });

    test('extractSelection matches truth for fragments and L forms', () {
      final Map<String, dynamic> data = _map(truth['opener']);
      for (final dynamic raw in _list(data['extractSelection'])) {
        final Map<String, dynamic> rawCase = _map(raw);
        final op.ExtractSelectionResult result = op.extractSelection(
          _uriFromTruth(rawCase['input']),
        );
        expect(_selectionJson(result.selection), rawCase['selection'],
            reason: rawCase['fragment'] as String);
        expect(_uriJson(result.uri), rawCase['uri'],
            reason: rawCase['fragment'] as String);
      }
    });

    test('withSelection/extractSelection round-trips match truth', () {
      final Map<String, dynamic> data = _map(truth['opener']);
      for (final dynamic raw in _list(data['roundTrips'])) {
        final Map<String, dynamic> rawCase = _map(raw);
        final URI original = _uriFromTruth(rawCase['original']);
        final URI withSelection = op.withSelection(
          original,
          _selectionFromTruth(rawCase['selection']),
        );
        expect(withSelection.toString(), rawCase['withSelectionString']);
        final op.ExtractSelectionResult extracted =
            op.extractSelection(withSelection);
        expect(_selectionJson(extracted.selection), rawCase['extractedSelection']);
        expect(_uriJson(extracted.uri), rawCase['extractedUri']);
        expect(extracted.uri.toString(), rawCase['extractedUriString']);
        expect(original.toString(), rawCase['originalString']);
      }
    });
  });

  group('batch188 official opener.test.ts truth', () {
    test('all 14 official assertions pass against Dart port', () {
      final List<dynamic> cases = _list(truth['official']);
      expect(cases.length, 14);

      const List<String> extractFragments = <String>[
        '73',
        'L73',
        '73,84',
        'L73,84',
        '73-83',
        'L73-L83',
        'L73-83',
        '73-L83',
        '73,84-83,52',
        'L73,84-L83,52',
      ];
      final List<ITextEditorSelection> withSelections =
          <ITextEditorSelection>[
        ITextEditorSelection(startLineNumber: 73, startColumn: 84),
        ITextEditorSelection(
          startLineNumber: 73,
          startColumn: 84,
          endLineNumber: 83,
        ),
        ITextEditorSelection(
          startLineNumber: 73,
          startColumn: 84,
          endLineNumber: 83,
          endColumn: 52,
        ),
      ];

      for (int i = 0; i < cases.length; i++) {
        final Map<String, dynamic> officialCase = _map(cases[i]);
        final List<dynamic> assertions = _list(officialCase['assertions']);
        for (final dynamic rawAssertion in assertions) {
          final Map<String, dynamic> assertion = _map(rawAssertion);
          expect(assertion['pass'], true, reason: officialCase['name'] as String);
          expect(assertion['kind'], isIn(<String>['strictEqual', 'deepStrictEqual']));

          if (i < extractFragments.length) {
            final URI input = URI.parse(
              'file:///some/file.js#${extractFragments[i]}',
            );
            expect(
              _selectionJson(op.extractSelection(input).selection),
              assertion['actual'],
              reason: officialCase['name'] as String,
            );
            expect(_selectionJson(op.extractSelection(input).selection),
                assertion['expected']);
          } else if (i < extractFragments.length + withSelections.length) {
            final int index = i - extractFragments.length;
            final URI result = op.withSelection(
              URI.parse('file:///some/file.js'),
              withSelections[index],
            );
            expect(result.toString(), assertion['actual'],
                reason: officialCase['name'] as String);
            expect(result.toString(), assertion['expected']);
          } else {
            final URI original = URI.parse('file:///some/file.js');
            final URI withSelection = op.withSelection(
              original,
              withSelections.last,
            );
            final List<dynamic> rawAssertions = assertions;
            final int assertionIndex = rawAssertions.indexOf(rawAssertion);
            if (assertionIndex == 0) {
              expect(op.extractSelection(withSelection).uri.toString(),
                  assertion['actual']);
            } else {
              expect(op.extractSelection(original).uri.toString(),
                  assertion['actual']);
            }
            expect(assertion['actual'], assertion['expected']);
          }
        }
      }
    });
  });
}
