// batch261: textModelValueReference.ts truth replay.
// Truth from tool/ts2dart/batch261_truth.json (recursive TS transpile+vm,
// real PositionOffsetTransformer dependency injection).
import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:semi_design_flutter/src/monaco/base/common/errors.dart'
    show setUnexpectedErrorHandler;
import 'package:semi_design_flutter/src/monaco/base/common/uri.dart' show URI;
import 'package:semi_design_flutter/src/monaco/editor/common/core/position.dart'
    show Position;
import 'package:semi_design_flutter/src/monaco/editor/common/core/range.dart'
    show Range;
import 'package:semi_design_flutter/src/monaco/editor/common/core/text/positionToOffsetImpl.dart'
    show PositionOffsetTransformer;
import 'package:semi_design_flutter/src/monaco/editor/contrib/inlineCompletions/browser/model/textModelValueReference.dart'
    show ITextModelForValueReference, TextModelValueReference;

Map<String, dynamic> _truth() => jsonDecode(
    File('tool/ts2dart/batch261_truth.json').readAsStringSync())
    as Map<String, dynamic>;

class _FakeModel implements ITextModelForValueReference {
  final URI _uri;
  final String _eol;
  int _version;
  List<String> _lines;
  late String _text;
  late PositionOffsetTransformer _transformer;

  _FakeModel(this._uri, List<String> lines, this._eol, this._version)
      : _lines = List<String>.of(lines) {
    _rebuild();
  }

  void _rebuild() {
    _text = _lines.join('\n');
    _transformer = PositionOffsetTransformer(_text);
  }

  void mutate(int newVersion, List<String> newLines) {
    _version = newVersion;
    _lines = List<String>.of(newLines);
    _rebuild();
  }

  @override
  URI get uri => _uri;

  @override
  int getVersionId() => _version;

  @override
  String getValueInRange(Range range) {
    final r = _transformer.getOffsetRange(range);
    return _text.substring(r.start, r.endExclusive);
  }

  @override
  int getLineLength(int lineNumber) => lineNumber >= 1 && lineNumber <= _lines.length
      ? _lines[lineNumber - 1].length
      : 0;

  @override
  int getLineCount() => _lines.length;

  @override
  String getEOL() => _eol;

  @override
  Position getPositionAt(int offset) => _transformer.getPosition(offset);
}

String _currentCall = '';
final List<Map<String, dynamic>> _captured = <Map<String, dynamic>>[];

void _onError(Object? e) {
  final String message = e is StateError ? e.message : e.toString();
  _captured.add(<String, dynamic>{'call': _currentCall, 'message': message});
}

T _invoke<T>(String label, T Function() body) {
  _currentCall = label;
  return body();
}

Map<String, dynamic> _pos(Position p) => <String, dynamic>{
  'lineNumber': p.lineNumber,
  'column': p.column,
};

bool _isValueReference(Object value) => value is TextModelValueReference;

Map<String, dynamic> _project(TextModelValueReference ref, _FakeModel model,
    List<dynamic> ranges, List<dynamic> offsets, String prefix) {
  return <String, dynamic>{
    'uri': ref.uri.toString(),
    'isInstance': _isValueReference(ref),
    'versionGetter': ref.version,
    'underlyingModelSame': _invoke('$prefix:dangerouslyGetUnderlyingModel',
        () => identical(ref.dangerouslyGetUnderlyingModel(), model)),
    'targetsSameUri': _invoke('$prefix:targets-same', () => ref.targets(model)),
    'targetsOtherUri': _invoke('$prefix:targets-other', () => ref.targets(
        _FakeModel(URI.parse('file:///other.ts'), <String>['x'], '\n', 0))),
    'getVersionId': _invoke('$prefix:getVersionId', () => ref.getVersionId()),
    'length': _invoke('$prefix:length', () {
      final l = ref.length;
      return <String, dynamic>{
        'lineCount': l.lineCount,
        'columnCount': l.columnCount,
      };
    }),
    'eol': _invoke('$prefix:getEOL', () => ref.getEOL()),
    'getValueOfRange': List<dynamic>.generate(
      ranges.length,
      (i) => _invoke('$prefix:getValueOfRange#$i', () {
        final r = ranges[i] as List<dynamic>;
        return ref.getValueOfRange(
            Range(r[0] as int, r[1] as int, r[2] as int, r[3] as int));
      }),
    ),
    'getValueInRange': List<dynamic>.generate(
      ranges.length,
      (i) => _invoke('$prefix:getValueInRange#$i', () {
        final r = ranges[i] as List<dynamic>;
        return ref.getValueInRange(
            Range(r[0] as int, r[1] as int, r[2] as int, r[3] as int));
      }),
    ),
    'getLineLength': <int>[1, 2, 3]
        .map((n) => _invoke('$prefix:getLineLength#$n', () => ref.getLineLength(n)))
        .toList(),
    'getPositionAt': List<dynamic>.generate(
      offsets.length,
      (i) => _invoke('$prefix:getPositionAt#$i',
          () => _pos(ref.getPositionAt(offsets[i] as int))),
    ),
    'getValue': _invoke('$prefix:getValue', () => ref.getValue()),
    'endPositionExclusive': _invoke('$prefix:endPositionExclusive',
        () => _pos(ref.endPositionExclusive)),
    'getLineAt1': _invoke('$prefix:getLineAt1', () => ref.getLineAt(1)),
    'getLines': _invoke('$prefix:getLines', () => ref.getLines()),
  };
}

void main() {
  final t = _truth();
  setUnexpectedErrorHandler(_onError);
  tearDownAll(() => setUnexpectedErrorHandler((_) {}));

  for (final raw in t['cases'] as List<dynamic>) {
    final c = raw as Map<String, dynamic>;
    test('b261 ${c['name']}: snapshot + all methods before/after version change',
        () {
      final model = _FakeModel(
        URI.parse(c['uri'] as String),
        (c['lines'] as List<dynamic>).cast<String>(),
        c['eol'] as String,
        c['version'] as int,
      );
      final ref = TextModelValueReference.snapshot(model);

      _captured.clear();
      final before = _project(ref, model, c['ranges'] as List<dynamic>,
          c['offsets'] as List<dynamic>, '${c['name']}-before');
      expect(before, c['before']);
      expect(_captured, c['errorsBefore']);

      _captured.clear();
      model.mutate(c['nextVersion'] as int,
          (c['nextLines'] as List<dynamic>).cast<String>());
      final after = _project(ref, model, c['ranges'] as List<dynamic>,
          c['offsets'] as List<dynamic>, '${c['name']}-after');
      expect(after, c['after']);
      expect(_captured, c['errorsAfter']);
    });
  }
}
