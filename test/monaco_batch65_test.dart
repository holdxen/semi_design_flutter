// batch65: markerService.ts. All assertions are data-driven from
// markerService_truth.json (Node TS transpile+vm real evaluation of the file and
// its real local dependency chain, including MicrotaskEmitter + queueMicrotask).
import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:semi_design_flutter/src/monaco/base/common/uri.dart' show URI;
import 'package:semi_design_flutter/src/monaco/platform/markers/common/markers.dart'
    show
        IMarker,
        IMarkerChangeOptions,
        IMarkerData,
        IMarkerReadOptions,
        IRelatedInformation,
        IResourceMarker,
        MarkerSeverity;
import 'package:semi_design_flutter/src/monaco/platform/markers/common/markerService.dart'
    show MarkerService, unsupportedSchemas;

Map<String, dynamic> _truth() => jsonDecode(
      File('tool/ts2dart/markerService_truth.json').readAsStringSync(),
    ) as Map<String, dynamic>;

const _undef = '__undefined__';

/// Structural carrier for IMarkerData (source uses object literals).
class _Data implements IMarkerData {
  final Object? code;
  @override
  final int severity;
  @override
  final String message;
  @override
  final String? source;
  @override
  final int startLineNumber;
  @override
  final int startColumn;
  @override
  final int endLineNumber;
  @override
  final int endColumn;
  @override
  final int? modelVersionId;
  @override
  final List<IRelatedInformation>? relatedInformation;
  @override
  final List<int>? tags;
  @override
  final String? origin;

  _Data({
    this.code,
    this.severity = MarkerSeverity.Error,
    this.message = 'm',
    this.source,
    this.startLineNumber = 1,
    this.startColumn = 1,
    int? endLineNumber,
    this.endColumn = 1,
    this.modelVersionId,
    this.relatedInformation,
    this.tags,
    this.origin,
  }) : endLineNumber = endLineNumber ?? 1;
}

class _ResourceMarker implements IResourceMarker {
  @override
  final URI resource;
  @override
  final IMarkerData marker;
  _ResourceMarker(this.resource, this.marker);
}

class _ReadOpts implements IMarkerReadOptions {
  @override
  final String? owner;
  @override
  final URI? resource;
  @override
  final int? severities;
  @override
  final int? take;
  @override
  final bool? ignoreResourceFilters;
  _ReadOpts({this.owner, this.resource, this.severities, this.take, this.ignoreResourceFilters});
}

class _ChangeOpts implements IMarkerChangeOptions {
  @override
  final bool? isTruncated;
  _ChangeOpts({this.isTruncated});
}

IMarkerData mk([void Function(_DataBuilder)? build]) {
  final b = _DataBuilder();
  if (build != null) build(b);
  return _Data(
    code: b.code,
    severity: b.severity,
    message: b.message,
    source: b.source,
    startLineNumber: b.startLineNumber,
    startColumn: b.startColumn,
    endLineNumber: b.endLineNumber,
    endColumn: b.endColumn,
    modelVersionId: b.modelVersionId,
    relatedInformation: b.relatedInformation,
    tags: b.tags,
    origin: b.origin,
  );
}

class _DataBuilder {
  Object? code;
  int severity = MarkerSeverity.Error;
  String message = 'm';
  String? source;
  int startLineNumber = 1;
  int startColumn = 1;
  int? endLineNumber;
  int endColumn = 1;
  int? modelVersionId;
  List<IRelatedInformation>? relatedInformation;
  List<int>? tags;
  String? origin;
}

_ResourceMarker rm(String uri, IMarkerData marker) =>
    _ResourceMarker(URI.parse(uri), marker);

Future<void> _flush() => Future<void>.delayed(Duration.zero);

int len(List<IMarker> markers) => markers.length;

void main() {
  final t = _truth();

  test('b65 unsupportedSchemas set matches truth', () {
    final expected = (t['unsupportedSchemas'] as List).cast<String>();
    expect(unsupportedSchemas.toList()..sort(), expected);
  });

  test('b65 MarkerSeverity power-of-two values', () {
    final s = t['severities'] as Map<String, dynamic>;
    expect(MarkerSeverity.Hint, s['Hint']);
    expect(MarkerSeverity.Info, s['Info']);
    expect(MarkerSeverity.Warning, s['Warning']);
    expect(MarkerSeverity.Error, s['Error']);
  });

  test('b65 query-basic: read filters', () {
    final c = _scenario(t, 'query-basic');
    final s = MarkerService();
    s.changeAll('far', [rm('file:///c/test/file.cs', mk((b) => b.severity = MarkerSeverity.Error))]);
    s.changeAll('boo', [rm('file:///c/test/file.cs', mk((b) => b.severity = MarkerSeverity.Warning))]);
    expect(len(s.read()), c['all']);
    expect(len(s.read(_ReadOpts(owner: 'far'))), c['byFar']);
    expect(len(s.read(_ReadOpts(owner: 'boo'))), c['byBoo']);
    expect(len(s.read(_ReadOpts(resource: URI.parse('file:///c/test/file.cs')))), c['byResource']);
    expect(len(s.read(_ReadOpts(owner: 'far', resource: URI.parse('file:///c/test/file.cs')))), c['byOwnerResource']);
    expect(len(s.read(_ReadOpts(severities: MarkerSeverity.Error))), c['sevError']);
    expect(len(s.read(_ReadOpts(severities: MarkerSeverity.Warning))), c['sevWarning']);
    expect(len(s.read(_ReadOpts(severities: MarkerSeverity.Hint))), c['sevHint']);
    expect(len(s.read(_ReadOpts(severities: MarkerSeverity.Error | MarkerSeverity.Warning))), c['sevErrOrWarn']);
    s.dispose();
  });

  test('b65 changeOne override + clears', () {
    final ov = _scenario(t, 'changeOne-override');
    final s = MarkerService();
    final u = URI.parse('file:///path/only.cs');
    s.changeOne('far', u, [mk()]);
    s.changeOne('boo', u, [mk()]);
    expect([len(s.read(_ReadOpts(owner: 'far'))), len(s.read(_ReadOpts(owner: 'boo'))), len(s.read())], ov['after2']);
    s.changeOne('far', u, [mk(), mk()]);
    expect([len(s.read(_ReadOpts(owner: 'far'))), len(s.read(_ReadOpts(owner: 'boo')))], ov['afterOverride']);
    s.dispose();

    final cl = _scenario(t, 'clears');
    final s2 = MarkerService();
    s2.changeOne('far', u, [mk()]);
    s2.changeOne('boo', u, [mk()]);
    s2.changeOne('far', u, const <IMarkerData>[]);
    expect([len(s2.read(_ReadOpts(owner: 'far'))), len(s2.read(_ReadOpts(owner: 'boo'))), len(s2.read())], cl['afterOne']);
    s2.changeAll('boo', const <IResourceMarker>[]);
    expect([len(s2.read(_ReadOpts(owner: 'far'))), len(s2.read(_ReadOpts(owner: 'boo'))), len(s2.read())], cl['afterAll']);
    s2.dispose();
  });

  test('b65 invalid data, zero code, sanitize, modelVersion', () {
    final inv = _scenario(t, 'invalid-data-and-zero-code');
    final s = MarkerService();
    final u = URI.parse('some:uri/path');
    s.changeOne('far', u, [_Data(message: '')]);
    expect(len(s.read(_ReadOpts(owner: 'far'))), inv['undef']);
    s.changeOne('far', u, [_Data(message: 'null')]);
    expect(len(s.read(_ReadOpts(owner: 'far'))), inv['str']);
    s.changeOne('zero', URI.parse('some:thing'), [mk((b) {
      b.code = '0';
      b.severity = 0;
      b.source = 'me';
    })]);
    final zero = s.read(_ReadOpts(resource: URI.parse('some:thing')));
    expect(zero.length, inv['zeroLen']);
    expect(zero.first.code, inv['zeroCode']);
    s.dispose();

    final sm = _scenario(t, 'sanitize-and-modelVersion');
    final s2 = MarkerService();
    final u2 = URI.parse('file:///path/file.ts');
    s2.changeOne('owner', u2, [mk((b) {
      b.startLineNumber = -1;
      b.startColumn = 0;
      b.endLineNumber = -5;
      b.endColumn = -3;
      b.modelVersionId = 42;
    })]);
    final m = s2.read(_ReadOpts(resource: u2)).first;
    expect([m.startLineNumber, m.startColumn, m.endLineNumber, m.endColumn], sm['sanitized']);
    expect(m.modelVersionId, sm['mvPresent']);
    s2.changeOne('owner', u2, [mk()]);
    final m2 = s2.read(_ReadOpts(resource: u2)).first;
    expect(m2.modelVersionId, sm['mvAbsent'] == _undef ? null : sm['mvAbsent']);
    s2.dispose();
  });

  test('b65 severity bitmask + take limit', () {
    final sb = _scenario(t, 'severity-bitmask');
    final s = MarkerService();
    final u = URI.parse('file:///a');
    s.changeOne('o', u, [
      mk((b) => b.severity = MarkerSeverity.Error),
      mk((b) => b.severity = MarkerSeverity.Warning),
      mk((b) => b.severity = MarkerSeverity.Info),
    ]);
    expect(len(s.read(_ReadOpts(severities: MarkerSeverity.Error))), sb['err']);
    expect(len(s.read(_ReadOpts(severities: MarkerSeverity.Warning))), sb['warn']);
    expect(len(s.read(_ReadOpts(severities: MarkerSeverity.Info))), sb['info']);
    expect(len(s.read(_ReadOpts(severities: MarkerSeverity.Error | MarkerSeverity.Warning))), sb['errWarn']);
    expect(len(s.read(_ReadOpts(severities: MarkerSeverity.Error | MarkerSeverity.Warning | MarkerSeverity.Info))), sb['all']);
    expect(len(s.read()), sb['undef']);
    s.dispose();

    final tk = _scenario(t, 'take-limit');
    final s2 = MarkerService();
    s2.changeOne('o', u, [mk(), mk(), mk()]);
    expect(len(s2.read(_ReadOpts(owner: 'o', take: 2))), tk['take2']);
    expect(len(s2.read(_ReadOpts(owner: 'o', take: -1))), tk['takeNeg']);
    expect(len(s2.read(_ReadOpts(owner: 'o', take: 0))), tk['take0']);
    s2.dispose();
  });

  test('b65 truncation per resource across owners', () {
    final tr = _scenario(t, 'truncation');
    final s = MarkerService();
    final r1 = URI.parse('file:///path/file.ts');
    final r2 = URI.parse('file:///path/other.ts');
    s.changeOne('first', r1, [mk()], _ChangeOpts(isTruncated: true));
    s.changeOne('second', r1, [mk()]);
    s.changeOne('first', r1, [mk()]);
    s.changeOne('first', r2, [mk()], _ChangeOpts(isTruncated: true));
    expect([s.isSourceTruncated(r1), s.isSourceTruncated(r2)], tr['after']);
    s.changeAll('first', const <IResourceMarker>[]);
    expect([s.isSourceTruncated(r1), s.isSourceTruncated(r2)], tr['cleared']);
    s.dispose();
  });

  test('b65 statistics: counts, unsupported ignored, clear reduces', () async {
    final stats = (t['statistics'] as List).cast<Map<String, dynamic>>();
    final counts = stats.firstWhere((x) => x['name'] == 'counts');
    final afterUnsup = stats.firstWhere((x) => x['name'] == 'after-unsupported');
    final afterClear = stats.firstWhere((x) => x['name'] == 'after-clear');
    final s = MarkerService();
    final u = URI.parse('file:///stats.cs');
    s.changeOne('o', u, [
      mk((b) => b.severity = MarkerSeverity.Error),
      mk((b) => b.severity = MarkerSeverity.Warning),
      mk((b) => b.severity = MarkerSeverity.Info),
      mk((b) => b.severity = 99),
    ]);
    await _flush();
    expect(s.getStatistics().errors, counts['errors']);
    expect(s.getStatistics().warnings, counts['warnings']);
    expect(s.getStatistics().infos, counts['infos']);
    expect(s.getStatistics().unknowns, counts['unknowns']);

    s.changeOne('o', URI.parse('inmemory://model/1'), [mk((b) => b.severity = MarkerSeverity.Error)]);
    await _flush();
    expect(s.getStatistics().errors, afterUnsup['errors']);

    s.changeOne('o', u, const <IMarkerData>[]);
    await _flush();
    expect(s.getStatistics().errors, afterClear['errors']);
    expect(s.getStatistics().warnings, afterClear['warnings']);
    expect(s.getStatistics().infos, afterClear['infos']);
    expect(s.getStatistics().unknowns, afterClear['unknowns']);
    s.dispose();
  });

  test('b65 resource filter hides / info marker / ignore / dispose', () {
    final f = (t['filters'] as List)
        .firstWhere((x) => (x as Map)['name'] == 'filter-hide-and-dispose') as Map<String, dynamic>;
    final r = f['result'] as Map<String, dynamic>;
    final s = MarkerService();
    final r1 = URI.parse('file:///path/file1.cs');
    final r2 = URI.parse('file:///path/file2.cs');
    s.changeOne('owner1', r1, [mk()]);
    s.changeOne('owner1', r2, [mk()]);
    expect([len(s.read()), len(s.read(_ReadOpts(resource: r1))), len(s.read(_ReadOpts(resource: r2)))], r['before']);
    final filter = s.installResourceFilter(r1, 'Test filter');
    expect([len(s.read()), len(s.read(_ReadOpts(resource: r1))), len(s.read(_ReadOpts(resource: r2)))], r['filtered']);
    final info = s.read(_ReadOpts(resource: r1)).first;
    expect(info.owner, r['infoOwner']);
    expect(info.severity, r['infoSev']);
    expect(info.message, r['infoMessage']);
    expect(len(s.read(_ReadOpts(resource: r1, ignoreResourceFilters: true))), r['ignored']);
    filter.dispose();
    expect([len(s.read()), len(s.read(_ReadOpts(resource: r1)))], r['restored']);
    s.dispose();
  });

  test('b65 multiple filter reasons message + event merge', () async {
    final mf = (t['filters'] as List)
        .firstWhere((x) => (x as Map)['name'] == 'filter-multiple-reasons') as Map<String, dynamic>;
    final mr = mf['result'] as Map<String, dynamic>;
    final s = MarkerService();
    final r1 = URI.parse('file:///path/f.cs');
    s.changeOne('o', r1, [mk()]);
    final f1 = s.installResourceFilter(r1, 'A');
    final f2 = s.installResourceFilter(r1, 'B');
    expect(s.read(_ReadOpts(resource: r1)).first.message, mr['one']);
    f1.dispose();
    expect(s.read(_ReadOpts(resource: r1)).first.message, mr['two']);
    f2.dispose();
    expect(len(s.read(_ReadOpts(resource: r1))), mr['none']);
    s.dispose();

    final ev = (t['events'] as List).first as Map<String, dynamic>;
    final batches = ev['batches'] as List;
    final s2 = MarkerService();
    final e1 = URI.parse('file:///e1');
    final e2 = URI.parse('file:///e2');
    final captured = <List<URI>>[];
    final sub = s2.onMarkerChanged((dynamic ev) => captured.add(ev as List<URI>));
    s2.changeOne('o', e1, [mk()]);
    s2.changeOne('o', e2, [mk()]);
    s2.changeOne('o', e1, [mk()]);
    await _flush();
    sub.dispose();
    expect(captured.length, batches.length);
    if (batches.isNotEmpty) {
      final expectedUris = (batches.first as List)
          .map((u) => (u as Map)['__uri__'] as String)
          .toList();
      expect(captured.first.map((u) => u.toString()).toList(), expectedUris);
    }
    s2.dispose();
  });
}

Map<String, dynamic> _scenario(Map<String, dynamic> t, String name) =>
    (t['scenarios'] as List)
        .firstWhere((x) => (x as Map)['name'] == name)['result'] as Map<String, dynamic>;
