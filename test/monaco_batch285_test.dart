// batch285: referencesModel.ts truth replay.
// Truth from tool/ts2dart/batch285_truth.json (recursive TS transpile+vm,
// real ReferencesModel + real Range/Position/URI/RouteMap).
import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:semi_design_flutter/src/monaco/base/common/uri.dart' show URI;
import 'package:semi_design_flutter/src/monaco/editor/common/core/position.dart'
    show Position;
import 'package:semi_design_flutter/src/monaco/editor/common/core/range.dart'
    show Range;
import 'package:semi_design_flutter/src/monaco/editor/contrib/gotoSymbol/browser/referencesModel.dart'
    show
        OneReference,
        ReferenceLocation,
        ReferencesModel;

Map<String, dynamic> _truth() => jsonDecode(
    File('tool/ts2dart/batch285_truth.json').readAsStringSync())
    as Map<String, dynamic>;

Object? _norm(Object? v) {
  if (v == null) return null;
  if (v is Map) {
    return v.map<String, Object?>((k, e) =>
        MapEntry<String, Object?>(k as String, _norm(e)));
  }
  if (v is List) return v.map(_norm).toList();
  return v;
}

ReferenceLocation _makeLink(Map<String, dynamic> d) {
  final range = Range(d['sl'] as int, d['sc'] as int, d['el'] as int, d['ec'] as int);
  Range? target;
  if (d['tsl'] != null) {
    target = Range(d['tsl'] as int, d['tsc'] as int, d['tel'] as int, d['tec'] as int);
  }
  return ReferenceLocation(URI.parse(d['uri'] as String), range, target);
}

List<int> _r(Object r) {
  final d = r as dynamic;
  return <int>[
    d.startLineNumber as int,
    d.startColumn as int,
    d.endLineNumber as int,
    d.endColumn as int,
  ];
}

Map<String, Object?> _refJSON(
  OneReference ref,
  ReferencesModel model,
) =>
    <String, Object?>{
      'uri': ref.uri.toString(),
      'range': _r(ref.range),
      'isProviderFirst': ref.isProviderFirst,
      'groupUri': ref.parent.uri.toString(),
      'idx': model.references.indexOf(ref),
    };

void main() {
  final t = _truth();

  for (final rawCase in t['cases'] as List<dynamic>) {
    final c = rawCase as Map<String, dynamic>;
    test('b285 ${c['name']}: model matches TS truth', () {
      final links = (c['links'] as List<dynamic>)
          .map((raw) => _makeLink(raw as Map<String, dynamic>))
          .toList();
      // Replay mutates the links list (sort), so each test builds fresh links.
      final model = ReferencesModel(links, c['title'] as String);
      final events = <Map<String, Object?>>[];
      model.onDidChangeReferenceRange((ref) =>
          events.add(_refJSON(ref, model)));

      final outputs = <Object?>[];
      for (final rawOp in c['ops'] as List<dynamic>) {
        final op = rawOp as Map<String, dynamic>;
        switch (op['op'] as String) {
          case 'aria':
            outputs.add(model.ariaMessage);
            break;
          case 'isEmpty':
            outputs.add(model.isEmpty);
            break;
          case 'title':
            outputs.add(model.title);
            break;
          case 'groups':
            outputs.add(model.groups.map((g) => <String, Object?>{
                  'uri': g.uri.toString(),
                  'children': g.children
                      .map((child) => _refJSON(child, model))
                      .toList(),
                  'aria': g.ariaMessage,
                }).toList());
            break;
          case 'references':
            outputs.add(
                model.references.map((r) => _refJSON(r, model)).toList());
            break;
          case 'firstReference':
            final r = model.firstReference();
            outputs.add(r == null ? null : _refJSON(r, model));
            break;
          case 'nextFrom':
          case 'prevFrom':
            final r = model.nextOrPreviousReference(
                model.references[op['idx'] as int], op['op'] == 'nextFrom');
            outputs.add(_refJSON(r, model));
            break;
          case 'nearestAll':
            outputs.add((c['queries'] as List<dynamic>).map((raw) {
              final q = raw as Map<String, dynamic>;
              final r = model.nearestReference(
                  URI.parse(q['uri'] as String),
                  Position(q['line'] as int, q['col'] as int));
              return r == null ? null : _refJSON(r, model);
            }).toList());
            break;
          case 'referenceAtAll':
            outputs.add((c['queries'] as List<dynamic>).map((raw) {
              final q = raw as Map<String, dynamic>;
              final r = model.referenceAt(
                  URI.parse(q['uri'] as String),
                  Position(q['line'] as int, q['col'] as int));
              return r == null ? null : _refJSON(r, model);
            }).toList());
            break;
          default:
            fail('unknown op ${op['op']}');
        }
      }

      expect(_norm(outputs), c['outputs'], reason: 'outputs ${c['name']}');

      final sr = c['setRange'];
      if (sr != null) {
        final s = sr as Map<String, dynamic>;
        model.references[s['idx'] as int].range = Range(
          s['sl'] as int, s['sc'] as int, s['el'] as int, s['ec'] as int,
        );
      }
      expect(_norm(events), c['events'], reason: 'events ${c['name']}');

      final clone = model.clone();
      final ci = c['cloneInfo'] as Map<String, dynamic>;
      expect(clone.groups.length, ci['groups'], reason: 'clone groups');
      expect(clone.references.length, ci['refs'], reason: 'clone refs');
      expect(identical(clone, model), ci['sameModel'], reason: 'clone identity');

      model.dispose();
      clone.dispose();
    });
  }
}
