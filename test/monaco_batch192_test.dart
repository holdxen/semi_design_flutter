// Truth replay for batch192: `editor/browser/dataTransfer.ts`.
//
// Every expectation comes from `tool/ts2dart/batch192_truth.json`, produced by
// `tool/ts2dart/_batch192_truth.cjs`, which executes the real transpiled
// TypeScript for `dataTransfer.ts` together with the real
// `base/common/dataTransfer.ts`, `mime.ts`, `uri.ts`, `base/browser/dnd.ts`
// (DataTransfers) and `platform/dnd/browser/dnd.ts`.
//
// NOTE: `editor/browser/dataTransfer.ts` has no official test of its own —
// `find_ready.py`'s stem heuristic matches the tests of
// `base/common/dataTransfer.ts`. Truth comes from executing the real source.
import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import '../lib/src/monaco/base/browser/dom.dart' as dom;
import '../lib/src/monaco/base/common/dataTransfer.dart' as vsdt;
import '../lib/src/monaco/base/common/mime.dart' show Mimes;
import '../lib/src/monaco/editor/browser/dataTransfer.dart' as dtPort;
import '../lib/src/monaco/platform/dnd/browser/dnd.dart' as dndPort;

Map<String, dynamic> _map(dynamic value) =>
    (value as Map).cast<String, dynamic>();

Matcher _exp(dynamic value) => value == null ? isNull : equals(value);

Map<String, dynamic> _truth() =>
    _map(jsonDecode(File('tool/ts2dart/batch192_truth.json').readAsStringSync()));

// ---------------------------------------------------------------------------
// DOM carriers
// ---------------------------------------------------------------------------
dom.DomFile _file(String name, {List<int>? bytes}) {
  final dom.DomFile file = dom.DomFile(name: name);
  file.arrayBuffer = () async => bytes ?? const <int>[];
  return file;
}

dom.DomDataTransferItem _stringItem(String type, String value) =>
    dom.DomDataTransferItem(kind: 'string', type: type)
      ..getAsString = ((void Function(String) resolve) => resolve(value));

dom.DomDataTransferItem _fileItem(String type, dom.DomFile file) =>
    dom.DomDataTransferItem(kind: 'file', type: type)
      ..getAsFile = (() => file);

dom.DomDataTransfer _dataTransfer(List<dom.DomDataTransferItem?> items) {
  final dom.DomDataTransfer transfer = dom.DomDataTransfer();
  transfer.items = items;
  return transfer;
}

/// Mirrors `projectTransfer()` in the truth harness.
Future<Map<String, Object?>> _projectTransfer(
    vsdt.VSDataTransfer transfer) async {
  final List<Map<String, Object?>> entries = <Map<String, Object?>>[];
  for (final List<Object> entry in transfer.entries()) {
    final String mime = entry[0] as String;
    final vsdt.IDataTransferItem item = entry[1] as vsdt.IDataTransferItem;
    final vsdt.IDataTransferFile? file = item.asFile();
    entries.add(<String, Object?>{
      'mime': mime,
      'string': await item.asString(),
      'file': file == null
          ? null
          : <String, Object?>{
              'name': file.name,
              'uri': file.uri?.toString(),
              'data': await file.data(),
              'hasId': file.id.isNotEmpty,
            },
    });
  }
  entries.sort((Map<String, Object?> a, Map<String, Object?> b) =>
      (a['mime']! as String).compareTo(b['mime']! as String));
  return <String, Object?>{'size': transfer.size, 'entries': entries};
}

void main() {
  final Map<String, dynamic> truth = _truth();

  setUp(() {
    dndPort.globalThisVscodeGetPathForFile = null;
  });

  test('batch192 toVSDataTransfer matches truth (string + file items)', () async {
    final Map<String, dynamic> expected = _map(truth['toVSDataTransfer']);
    final dom.DomFile file = _file('dropped.txt', bytes: <int>[1, 2, 3]);
    final dom.DomDataTransfer source = _dataTransfer(<dom.DomDataTransferItem?>[
      _stringItem('text/plain', 'hello'),
      _fileItem('Files', file),
      (dom.DomDataTransferItem(kind: 'file', type: 'Files')
        ..getAsFile = (() => null)),
      _stringItem('application/json', '{"a":1}'),
    ]);

    dndPort.globalThisVscodeGetPathForFile =
        (Object f) => (f as _PathFile).path;
    final dom.DomDataTransferItem item = source.items![1]!;
    item.getAsFile = () => _PathFile(file, '/abs/dropped.txt');

    final vsdt.VSDataTransfer transfer;
    try {
      transfer = dtPort.toVSDataTransfer(source);
      expect(await _projectTransfer(transfer), _exp(expected));
    } finally {
      dndPort.globalThisVscodeGetPathForFile = null;
    }
  });

  test('batch192 toVSDataTransfer without the Electron path seam', () async {
    final Map<String, dynamic> expected = _map(truth['toVSDataTransferNoPath']);
    final dom.DomDataTransfer source = _dataTransfer(<dom.DomDataTransferItem?>[
      _fileItem('Files', _PathFile(_file('no-path.txt', bytes: <int>[9]), null)),
    ]);
    final vsdt.VSDataTransfer transfer = dtPort.toVSDataTransfer(source);
    expect(await _projectTransfer(transfer), _exp(expected));
  });

  test('batch192 internal uri-list is exposed as the standard type', () async {
    final Map<String, dynamic> expected = _map(truth['toExternalVSDataTransfer']);
    final dom.DomFile aTxt = _PathFile(_file('a.txt', bytes: <int>[7]), '/abs/a.txt');
    final dom.DomDataTransfer source = _dataTransfer(<dom.DomDataTransferItem?>[
      _stringItem(dndPort.CodeDataTransfers.EDITORS, 'editors-payload'),
      _stringItem('application/vnd.code.uri-list', 'file:///internal/one.txt'),
      _fileItem('Files', aTxt),
    ]);

    dndPort.globalThisVscodeGetPathForFile =
        (Object f) => (f as _PathFile).path;
    final Map<String, Object?> actual;
    try {
      actual = await _projectTransfer(dtPort.toExternalVSDataTransfer(source));
    } finally {
      dndPort.globalThisVscodeGetPathForFile = null;
    }
    expect(actual, _exp(expected['internalUriList']));
  });

  test('batch192 built uri list from file paths matches truth', () async {
    final Map<String, dynamic> expected = _map(truth['toExternalVSDataTransfer']);
    dom.DomFile file(String name, String? path) =>
        _PathFile(_file(name, bytes: <int>[7]), path);

    final dom.DomDataTransfer source = _dataTransfer(<dom.DomDataTransferItem?>[
      _fileItem('Files', file('a.txt', '/abs/a.txt')),
      _fileItem('Files', file('sp ace.txt', '/abs/sp ace.txt')),
    ]);
    dndPort.globalThisVscodeGetPathForFile =
        (Object f) => (f as _PathFile).path;
    final Map<String, Object?> actual;
    try {
      actual = await _projectTransfer(dtPort.toExternalVSDataTransfer(source));
    } finally {
      dndPort.globalThisVscodeGetPathForFile = null;
    }
    expect(actual, _exp(expected['builtFromPaths']));
  });

  test('batch192 strict URI.parse of bare file names matches truth', () async {
    final Map<String, dynamic> expected = _map(truth['toExternalVSDataTransfer']);
    final dom.DomDataTransfer source = _dataTransfer(<dom.DomDataTransferItem?>[
      _fileItem('Files', _PathFile(_file('plain.txt', bytes: <int>[7]), null)),
      _fileItem('Files', _PathFile(_file('bad name%.txt', bytes: <int>[7]), null)),
    ]);
    final Map<String, Object?> actual;
    try {
      actual = await _projectTransfer(dtPort.toExternalVSDataTransfer(source));
    } on Object catch (error) {
      // TS swallows parse failures per file; the call itself must not throw.
      fail('toExternalVSDataTransfer threw: $error');
    }
    expect(actual, _exp(expected['builtFromNames']));
    expect(expected['builtFromNamesThrew'], isNull);
  });

  test('batch192 existing uri-list kept vs overwritten matches truth', () async {
    final Map<String, dynamic> expected = _map(truth['toExternalVSDataTransfer']);
    final dom.DomFile aTxt = _PathFile(_file('a.txt', bytes: <int>[7]), '/abs/a.txt');

    dom.DomDataTransfer source() =>
        _dataTransfer(<dom.DomDataTransferItem?>[
          _stringItem(Mimes.uriList, 'file:///existing.txt'),
          _fileItem('Files', aTxt),
        ]);

    dndPort.globalThisVscodeGetPathForFile =
        (Object f) => (f as _PathFile).path;
    try {
      expect(await _projectTransfer(dtPort.toExternalVSDataTransfer(source())),
          _exp(expected['existingKept']));
      expect(
          await _projectTransfer(
              dtPort.toExternalVSDataTransfer(source(), true)),
          _exp(expected['existingOverwritten']));
    } finally {
      dndPort.globalThisVscodeGetPathForFile = null;
    }
  });

  test('batch192 no file items and constants match truth', () async {
    final Map<String, dynamic> expected = _map(truth['toExternalVSDataTransfer']);
    final dom.DomDataTransfer source = _dataTransfer(<dom.DomDataTransferItem?>[
      _stringItem('text/plain', 'just text'),
    ]);
    expect(await _projectTransfer(dtPort.toExternalVSDataTransfer(source)),
        _exp(expected['noFiles']));
    expect(Mimes.uriList, expected['mimeUriList']);
  });
}

/// `File` carrier carrying the Electron `getPathForFile` result.
class _PathFile extends dom.DomFile {
  _PathFile(dom.DomFile base, this.path) : super(name: base.name) {
    arrayBuffer = base.arrayBuffer;
  }

  final String? path;
}