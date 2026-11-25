// batch270: editKind.ts truth replay.
// Truth from tool/ts2dart/batch270_truth.json (recursive TS transpile+vm,
// real StringEdit + PositionOffsetTransformer-backed fake model).
import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:semi_design_flutter/src/monaco/editor/common/core/edits/stringEdit.dart'
    show StringEdit, StringReplacement;
import 'package:semi_design_flutter/src/monaco/editor/common/core/position.dart'
    show Position;
import 'package:semi_design_flutter/src/monaco/editor/common/core/ranges/offsetRange.dart'
    show OffsetRange;
import 'package:semi_design_flutter/src/monaco/editor/common/core/text/positionToOffsetImpl.dart'
    show PositionOffsetTransformer;
import 'package:semi_design_flutter/src/monaco/editor/contrib/inlineCompletions/browser/model/editKind.dart'
    show IEditKindTextModel, computeEditKind;

Map<String, dynamic> _truth() => jsonDecode(
    File('tool/ts2dart/batch270_truth.json').readAsStringSync())
    as Map<String, dynamic>;

class _Model implements IEditKindTextModel {
  final String value;
  late final PositionOffsetTransformer _transformer;
  late final List<String> _lines;

  _Model(this.value) {
    _transformer = PositionOffsetTransformer(value);
    _lines = value.split(RegExp(r'\r\n|\r|\n'));
  }

  @override
  String getValue() => value;

  @override
  Position getPositionAt(int offset) => _transformer.getPosition(offset);

  @override
  String getLineContent(int lineNumber) => _lines[lineNumber - 1];
}

void main() {
  final t = _truth();

  for (final raw in t['cases'] as List<dynamic>) {
    final c = raw as Map<String, dynamic>;
    test('b270 ${c['name']}: edit kind matches TS truth', () {
      final edit = StringEdit((c['replacements'] as List<dynamic>)
          .map((r) {
            final rep = r as Map<String, dynamic>;
            return StringReplacement(
              OffsetRange(rep['start'] as int, rep['endExclusive'] as int),
              rep['text'] as String,
            );
          })
          .toList());
      final model = _Model(c['text'] as String);
      final cursorRaw = c['cursor'];
      final Position? cursor = cursorRaw == null
          ? null
          : Position((cursorRaw as List<dynamic>)[0] as int,
              cursorRaw[1] as int);

      final kind = computeEditKind(edit, model, cursor);
      final actual = kind == null
          ? null
          : (jsonDecode(kind.toString()) as Map<String, dynamic>)['edits'];

      expect(kind != null, c['isInstance'], reason: c['name'] as String);
      expect(actual, c['edits'], reason: c['name'] as String);
    });
  }
}
