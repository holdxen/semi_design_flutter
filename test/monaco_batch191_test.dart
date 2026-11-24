// Truth replay for batch191: `platform/dnd/browser/dnd.ts`.
//
// Every expectation comes from `tool/ts2dart/batch191_truth.json`, produced by
// `tool/ts2dart/_batch191_truth.cjs`, which executes the real transpiled
// TypeScript for `dnd.ts` together with the real
// `arrays/map/buffer/marshalling/async/uri/lifecycle/event` chain and the real
// `platform/registry` module. DOM drag payloads, FileReader, nls and the
// service seams are deterministic fakes; `platform.isWeb` / `platform.isNative`
// are injected per scenario exactly like the harness's platform stub.
//
// NOTE: `platform/dnd/browser/dnd.ts` has no official test of its own —
// `workbench/test/browser/dnd.test.ts` tests `workbench/browser/dnd.ts`
// (outside the port scope). Truth comes from executing the real source.
import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import '../lib/src/monaco/base/browser/dnd.dart' as baseDnd;
import '../lib/src/monaco/base/browser/dom.dart' as dom;
import '../lib/src/monaco/base/common/platform.dart' as platform;
import '../lib/src/monaco/base/common/uri.dart' show URI;
import '../lib/src/monaco/platform/dialogs/common/dialogs.dart' as dialogs;
import '../lib/src/monaco/platform/dnd/browser/dnd.dart' as dndPort;
import '../lib/src/monaco/platform/files/browser/htmlFileSystemProvider.dart'
    show HTMLFileSystemProvider;
import '../lib/src/monaco/platform/files/browser/webFileSystemAccess.dart'
    show webFileSystemAccessGetProp;
import '../lib/src/monaco/platform/files/common/files.dart' as filesPlatform;
import '../lib/src/monaco/platform/instantiation/common/instantiation.dart'
    as instantiation;
import '../lib/src/monaco/platform/log/common/log.dart' as logPlatform;
import '../lib/src/monaco/platform/registry/common/platform.dart' as registry;

Map<String, dynamic> _map(dynamic value) =>
    (value as Map).cast<String, dynamic>();

Map<String, dynamic> _truth() =>
    _map(jsonDecode(File('tool/ts2dart/batch191_truth.json').readAsStringSync()));

/// `expect(x, null)` is a matcher misuse; wrap every truth value.
Matcher _exp(dynamic value) => value == null ? isNull : equals(value);

// ---------------------------------------------------------------------------
// Carriers
// ---------------------------------------------------------------------------
dom.DomDataTransfer _dataTransfer({
  List<String>? types,
  Map<String, String>? data,
  List<dom.DomFile?>? files,
  List<dom.DomFile?>? items,
}) {
  final dom.DomDataTransfer transfer = dom.DomDataTransfer();
  transfer.types.addAll(types ?? const <String>[]);
  transfer.data.addAll(data ?? const <String, String>{});
  transfer.files = files;
  transfer.items = items;
  return transfer;
}

dom.DomDragEvent _dragEvent([dom.DomDataTransfer? dataTransfer]) {
  final dom.DomDragEvent event = dom.DomDragEvent('drop');
  event.dataTransfer = dataTransfer;
  return event;
}

/// JS `obj.prop` — parse() entries are plain Maps, typed entries are objects.
dynamic _readProp(Object? entry, String name) {
  if (entry is Map) {
    return entry[name];
  }
  switch (name) {
    case 'resource':
      return (entry as dynamic).resource;
    case 'options':
      return (entry as dynamic).options;
    case 'label':
      return (entry as dynamic).label;
    case 'contents':
      return (entry as dynamic).contents;
    case 'isExternal':
      return (entry as dynamic).isExternal;
    case 'allowWorkspaceOpen':
      return (entry as dynamic).allowWorkspaceOpen;
    case 'selection':
      return (entry as dynamic).selection;
  }
  return null;
}

/// Canonical fixed-key projection of an editor input; mirrors
/// `projectEditor()` in the truth harness (`null` stands for JS `undefined`).
Map<String, Object?> _projectSelection(dynamic selection) =>
    <String, Object?>{
      'startLineNumber': selection is Map
          ? selection['startLineNumber']
          : selection?.startLineNumber,
      'startColumn': selection is Map
          ? selection['startColumn']
          : selection?.startColumn,
      'endLineNumber': selection is Map
          ? selection['endLineNumber']
          : selection?.endLineNumber,
      'endColumn':
          selection is Map ? selection['endColumn'] : selection?.endColumn,
    };

Object? _projectUri(Object? resource) {
  if (resource is URI) {
    return <String, Object?>{
      'scheme': resource.scheme,
      'authority': resource.authority,
      'path': resource.path,
      'query': resource.query,
      'fragment': resource.fragment,
    };
  }
  return resource;
}

Map<String, Object?> _projectEditor(Object? entry) {
  final dynamic options = _readProp(entry, 'options');
  final dynamic selection =
      options == null ? null : _readProp(options, 'selection');
  return <String, Object?>{
    'resource': _projectUri(_readProp(entry, 'resource')),
    'options': <String, Object?>{
      'selection': selection == null ? null : _projectSelection(selection),
    },
    'label': _readProp(entry, 'label'),
    'contents': _readProp(entry, 'contents'),
    'isExternal': _readProp(entry, 'isExternal'),
    'allowWorkspaceOpen': _readProp(entry, 'allowWorkspaceOpen'),
  };
}

List<Map<String, Object?>> _projectEditors(List<Object?> editors) =>
    editors.map(_projectEditor).toList();

class _FakeAccessor implements instantiation.ServicesAccessor {
  _FakeAccessor(this.services);

  final Map<instantiation.ServiceIdentifier, Object?> services;

  @override
  Object? get(instantiation.ServiceIdentifier id) => services[id];
}

class _FakeDialogService implements dialogs.IDialogServiceType {
  _FakeDialogService(this.log);

  final List<List<Object?>> log;

  @override
  dynamic noSuchMethod(Invocation invocation) {
    if (invocation.memberName == #warn) {
      log.add(<Object?>['warn', invocation.positionalArguments.first]);
      return Future<void>.value();
    }
    return null;
  }
}

class _FakeLogService implements logPlatform.ILogServiceType {
  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}

class _FakeFileService {
  _FakeFileService(this.provider);

  final Object provider;

  dynamic getProvider(String scheme) => provider;
}

class _FakeInstantiationService implements instantiation.IInstantiationServiceType {
  _FakeInstantiationService(this.services);

  final Map<instantiation.ServiceIdentifier, Object?> services;

  @override
  Object? invokeFunction(Object fn, List<Object?> args) {
    final dynamic function = fn;
    return function(_FakeAccessor(services));
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}

/// Real `HTMLFileSystemProvider` subclass so the source's
/// `instanceof HTMLFileSystemProvider` check passes, with the handle
/// registration stubbed to the truth's fixed URIs.
class _FakeProvider extends HTMLFileSystemProvider {
  _FakeProvider() : super(null, 'test', _FakeLogService());

  @override
  Future<URI> registerFileHandle(dynamic handle) async =>
      URI.parse('vscode-remote://test/f/from-handle.txt');

  @override
  Future<URI> registerDirectoryHandle(dynamic handle) async =>
      URI.parse('vscode-remote://test/d/from-handle');
}

/// `File` carrier carrying the Electron `getPathForFile` result.
class _NativeFile extends dom.DomFile {
  _NativeFile(String name, this.path) : super(name: name);

  final String path;
}

class _FakeContribution implements dndPort.IDragAndDropContribution {
  _FakeContribution(this.calls);

  final List<String> calls;

  @override
  String get dataFormatKey => 'test.contribution';

  @override
  List<Object?> getEditorInputs(String data) {
    calls.add(data);
    return <Object?>[
      dndPort.IDraggedResourceEditorInput(label: 'contributed:$data'),
    ];
  }

  @override
  void setData(List<dndPort.IResourceStat> resources, Object event) {}
}

void main() {
  final Map<String, dynamic> truth = _truth();

  setUp(() {
    // restore the environment seams between scenarios
    platform.isNativeOverride = null;
    platform.isWebOverride = null;
    dndPort.globalThisVscodeGetPathForFile = null;
    webFileSystemAccessGetProp = (dynamic obj, String name) {
      if (obj == null) return null;
      if (obj is Map) return obj[name];
      return null;
    };
  });

  test('batch191 EDITORS payload parses through marshalling.parse', () {
    final Map<String, dynamic> expected = _map(truth['editorsPayload']);
    final Map<String, dynamic> transfers = _map(expected['codeDataTransfers']);
    expect(dndPort.CodeDataTransfers.EDITORS, transfers['EDITORS']);
    expect(dndPort.CodeDataTransfers.FILES, transfers['FILES']);
    expect(dndPort.CodeDataTransfers.SYMBOLS, transfers['SYMBOLS']);
    expect(dndPort.CodeDataTransfers.MARKERS, transfers['MARKERS']);
    expect(dndPort.CodeDataTransfers.NOTEBOOK_CELL_OUTPUT,
        transfers['NOTEBOOK_CELL_OUTPUT']);
    expect(dndPort.CodeDataTransfers.SCM_HISTORY_ITEM,
        transfers['SCM_HISTORY_ITEM']);
    expect(dndPort.CodeDataTransfers.CHAT_REFERENCE, transfers['CHAT_REFERENCE']);

    final dom.DomDataTransfer transfer = _dataTransfer(
      types: <String>[dndPort.CodeDataTransfers.EDITORS],
      data: <String, String>{
        dndPort.CodeDataTransfers.EDITORS: jsonEncode(<Object?>[
          <String, Object?>{
            'resource': <String, Object?>{
              'scheme': 'file',
              'authority': '',
              'path': '/a/b.ts',
              'query': '',
              'fragment': 'L10,5-L12,1',
            },
            'options': <String, Object?>{
              'selection': <String, Object?>{
                'startLineNumber': 10,
                'startColumn': 5,
                'endLineNumber': 12,
                'endColumn': 1,
              },
            },
          },
          <String, Object?>{'label': 'no-resource-editor'},
        ]),
      },
    );
    final List<Object?> editors =
        dndPort.extractEditorsDropData(_dragEvent(transfer));
    expect(_projectEditors(editors), _exp(expected['editors']));
  });

  test('batch191 RESOURCES payload and invalid EDITORS JSON match truth', () {
    final Map<String, dynamic> expected = _map(truth['resourcesPayload']);

    final dom.DomDataTransfer invalid = _dataTransfer(
      types: <String>[dndPort.CodeDataTransfers.EDITORS],
      data: <String, String>{dndPort.CodeDataTransfers.EDITORS: '{not-json'},
    );
    expect(_projectEditors(dndPort.extractEditorsDropData(_dragEvent(invalid))),
        _exp(expected['invalidEditorsJson']));

    final dom.DomDataTransfer resources = _dataTransfer(
      types: <String>[baseDnd.DataTransfers.RESOURCES],
      data: <String, String>{
        baseDnd.DataTransfers.RESOURCES: jsonEncode(<String>[
          'file:///r/one.ts#L3,4-L5,6',
          'file:///r/two.ts',
          'noscheme',
          'file:///r/one.ts',
        ]),
      },
    );
    expect(
        _projectEditors(dndPort.extractEditorsDropData(_dragEvent(resources))),
        _exp(expected['resources']));

    final dom.DomDataTransfer both = _dataTransfer(
      types: <String>[
        dndPort.CodeDataTransfers.EDITORS,
        baseDnd.DataTransfers.RESOURCES,
      ],
      data: <String, String>{
        dndPort.CodeDataTransfers.EDITORS: '[]',
        baseDnd.DataTransfers.RESOURCES:
            jsonEncode(<String>['file:///r/from-both.ts']),
      },
    );
    expect(_projectEditors(dndPort.extractEditorsDropData(_dragEvent(both))),
        _exp(expected['editorsWinsOverResources']));

    expect(
      _projectEditors(dndPort.createDraggedEditorInputFromRawResourcesData(
          jsonEncode(
              <String>['file:///d/x.ts#L1,2', 'file:///d/y.ts', 'no-colon']))),
      _exp(expected['direct']),
    );
  });

  test('batch191 native files, CodeFiles and contributions match truth', () {
    // Touch the lazy registration so the module-level Registry.add ran.
    dndPort.dragAndDropContributionRegistryRegistration;
    final dndPort.IDragAndDropContributionRegistry contributionRegistry =
        registry.Registry.as(dndPort.Extensions.DragAndDropContribution)
            as dndPort.IDragAndDropContributionRegistry;

    final List<String> contributionCalls = <String>[];
    contributionRegistry.register(_FakeContribution(contributionCalls));

    final dom.DomDataTransfer transfer = _dataTransfer(
      types: <String>[dndPort.CodeDataTransfers.FILES, 'test.contribution'],
      data: <String, String>{
        dndPort.CodeDataTransfers.FILES:
            jsonEncode(<String>['/native/x.ts', '/native/y.ts']),
        'test.contribution': 'contrib-payload',
      },
      files: <dom.DomFile?>[
        _NativeFile('native1', '/abs/native1.txt'),
        null,
        _NativeFile('native2', ''),
      ],
    );

    dndPort.globalThisVscodeGetPathForFile =
        (Object file) => (file as _NativeFile).path;
    final List<Object?> editors;
    try {
      editors = dndPort.extractEditorsDropData(_dragEvent(transfer));
    } finally {
      dndPort.globalThisVscodeGetPathForFile = null;
    }
    final Map<String, dynamic> expected = _map(truth['nativeFiles']);
    expect(_projectEditors(editors), _exp(expected['editors']));
    expect(contributionCalls, _exp(expected['contributionCalls']));

    final Map<String, dynamic> registryTruth = _map(truth['registry']);
    Object? duplicateError;
    try {
      contributionRegistry.register(_FakeContribution(contributionCalls));
    } catch (error) {
      duplicateError = error.toString();
    }
    expect(duplicateError, contains(registryTruth['dupError']));
    expect(contributionRegistry.getAll().length, registryTruth['size']);
  });

  test('batch191 containsDragType matches truth', () {
    final Map<String, dynamic> expected = _map(truth['containsDragType']);
    final dom.DomDataTransfer transfer =
        _dataTransfer(types: <String>['text/uri-list', 'Files']);
    expect(dndPort.containsDragType(_dragEvent(transfer), <String>['FILES']),
        _exp(expected['hit']));
    expect(
        dndPort.containsDragType(
            _dragEvent(transfer), <String>['missing', 'TEXT/URI-LIST']),
        _exp(expected['hitMultiple']));
    expect(
        dndPort.containsDragType(
            _dragEvent(transfer), <String>['CodeEditors']),
        _exp(expected['miss']));
    expect(dndPort.containsDragType(_dragEvent(), <String>['Files']),
        _exp(expected['noDataTransfer']));
  });

  test('batch191 getPathForFile flag matrix matches truth', () {
    final Map<String, dynamic> expected = _map(truth['getPathForFile']);
    final dom.DomFile file = dom.DomFile(name: 'f');

    // isNative true (default in the Dart test environment), no webUtils seam.
    platform.isNativeOverride = true;
    expect(dndPort.getPathForFile(file), _exp(expected['noWebUtils']));

    dndPort.globalThisVscodeGetPathForFile =
        (Object f) => '/abs/${(f as dom.DomFile).name}';
    expect(dndPort.getPathForFile(file), _exp(expected['withWebUtils']));

    platform.isNativeOverride = false;
    expect(dndPort.getPathForFile(file), _exp(expected['webIsUndefined']));
  });

  test('batch191 LocalSelectionTransfer singleton semantics match truth', () {
    final Map<String, dynamic> expected = _map(truth['localSelectionTransfer']);
    final dndPort.LocalSelectionTransfer<String> a =
        dndPort.LocalSelectionTransfer.getInstance<String>();
    final dndPort.LocalSelectionTransfer<String> b =
        dndPort.LocalSelectionTransfer.getInstance<String>();
    expect(identical(a, b), _exp(expected['singleton']));

    const String proto = 'proto';
    a.setData(<String>['payload'], proto);
    expect(a.hasData(proto), _exp(expected['hasData']));
    expect(a.hasData('other'), _exp(expected['hasDataOtherProto']));
    expect(a.getData(proto), _exp(expected['getData']));
    expect(a.getData('other'), _exp(expected['getDataOtherProto']));

    a.clearData(proto);
    final Map<String, dynamic> afterClear = _map(expected['afterClear']);
    expect(a.hasData(proto), _exp(afterClear['hasData']));
    expect(a.getData(proto), _exp(afterClear['getData']));

    a.setData(<String>['x'], null);
    final Map<String, dynamic> withoutProto =
        _map(expected['setDataWithoutProto']);
    expect(a.hasData(proto), _exp(withoutProto['hasData']));

    a.setData(<String>['payload'], proto);
    expect(a.getData(proto), _exp(expected['restore']));
  });

  test('batch191 symbol/marker/notebook JSON transfers match truth', () {
    final Map<String, dynamic> expected = _map(truth['jsonTransfers']);
    final dom.DomDataTransfer transfer = _dataTransfer(types: <String>[
      dndPort.CodeDataTransfers.SYMBOLS,
      dndPort.CodeDataTransfers.MARKERS,
      dndPort.CodeDataTransfers.NOTEBOOK_CELL_OUTPUT,
    ]);
    final dom.DomDragEvent symbolsEvent = _dragEvent(transfer);
    dndPort.fillInSymbolsDragData(<dndPort.DocumentSymbolTransferData>[
      dndPort.DocumentSymbolTransferData(
        name: 'sym',
        fsPath: '/s.ts',
        range: dndPort.DocumentSymbolRange(
          startLineNumber: 1,
          startColumn: 2,
          endLineNumber: 3,
          endColumn: 4,
        ),
        kind: 5,
      ),
    ], symbolsEvent);
    dndPort.fillInMarkersDragData(<Object?>[
      <String, Object?>{
        'uri': <String, Object?>{'scheme': 'file', 'path': '/m.ts'},
        'message': 'err',
      },
    ], symbolsEvent);

    final dom.DomDataTransfer notebookTransfer =
        _dataTransfer(types: <String>[dndPort.CodeDataTransfers.NOTEBOOK_CELL_OUTPUT]);
    final dom.DomDragEvent notebookEvent = _dragEvent(notebookTransfer);
    notebookTransfer.setData(dndPort.CodeDataTransfers.NOTEBOOK_CELL_OUTPUT,
        jsonEncode(<String, Object?>{'outputId': 'out-1'}));

    final dom.DomDataTransfer bad = _dataTransfer(
      types: <String>[
        dndPort.CodeDataTransfers.SYMBOLS,
        dndPort.CodeDataTransfers.MARKERS,
        dndPort.CodeDataTransfers.NOTEBOOK_CELL_OUTPUT,
      ],
      data: <String, String>{
        dndPort.CodeDataTransfers.SYMBOLS: '{bad',
        dndPort.CodeDataTransfers.MARKERS: '{bad',
        dndPort.CodeDataTransfers.NOTEBOOK_CELL_OUTPUT: '{bad',
      },
    );
    final Map<String, dynamic> invalid = _map(expected['invalid']);
    final Map<String, dynamic> missing = _map(expected['missingDataTransfer']);

    expect(dndPort.extractSymbolDropData(symbolsEvent),
        _exp(expected['symbols']));
    expect(dndPort.extractMarkerDropData(symbolsEvent),
        _exp(expected['markers']));
    expect(dndPort.extractNotebookCellOutputDropData(notebookEvent),
        _exp(expected['notebook']));
    expect(dndPort.extractSymbolDropData(_dragEvent(bad)),
        _exp(invalid['symbols']));
    expect(dndPort.extractMarkerDropData(_dragEvent(bad)),
        _exp(invalid['markers']));
    expect(dndPort.extractNotebookCellOutputDropData(_dragEvent(bad)),
        _exp(invalid['notebook']));
    expect(
      transfer.data.entries
          .map((MapEntry<String, String> e) => <Object?>['setData', e.key, e.value])
          .toList(),
      _exp(expected['setDataLog']),
    );
    expect(dndPort.extractSymbolDropData(_dragEvent()),
        _exp(missing['symbols']));
    expect(dndPort.extractMarkerDropData(_dragEvent()),
        _exp(missing['markers']));
  });

  test('batch191 chat reference drag data matches truth', () {
    final Map<String, dynamic> expected = _map(truth['chatReference']);
    final dndPort.ChatReferenceTransferData payload =
        dndPort.ChatReferenceTransferData(
      chatResource: 'chat://backend/1',
      clientResource: 'vscode://client/1',
      title: 'My chat',
    );
    final dom.DomDataTransfer transfer = _dataTransfer(
        types: <String>[dndPort.CodeDataTransfers.CHAT_REFERENCE]);
    dndPort.fillInChatReferenceDragData(payload, _dragEvent(transfer));

    final dom.DomDragEvent dropEvent = _dragEvent(transfer);
    final dom.DomDataTransfer dragoverTransfer = _dataTransfer(
        types: <String>[dndPort.CodeDataTransfers.CHAT_REFERENCE]);
    final dom.DomDragEvent dragoverEvent = _dragEvent(dragoverTransfer);
    final dom.DomDragEvent otherTypeEvent =
        _dragEvent(_dataTransfer(types: <String>['other']));

    final dndPort.ChatReferenceTransferData? extracted =
        dndPort.extractChatReferenceDropData(dropEvent);
    expect(extracted?.toJson(), _exp(expected['drop']));
    expect(
      transfer.data.entries
          .map((MapEntry<String, String> e) => <Object?>['setData', e.key, e.value])
          .toList(),
      _exp(expected['setDataLog']),
    );

    // dragover fallback: payload readable from the window-wide drag state.
    final dndPort.ChatReferenceTransferData? fallback =
        dndPort.extractChatReferenceDropData(dragoverEvent);
    expect(fallback?.toJson(), _exp(expected['dragoverFallback']));

    dndPort.clearChatReferenceDragData();
    expect(dndPort.extractChatReferenceDropData(otherTypeEvent),
        _exp(expected['otherType']));
    expect(dndPort.extractChatReferenceDropData(dragoverEvent),
        _exp(expected['afterClear']));
  });

  test('batch191 extractFileListData matches truth (FileReader path)', () async {
    final Map<String, dynamic> expected = _map(truth['fileListDrop']);
    platform.isWebOverride = true;
    platform.isNativeOverride = false;

    final List<List<Object?>> dialogLog = <List<Object?>>[];
    final _FakeDialogService dialogService = _FakeDialogService(dialogLog);
    final dom.DomFile bigFile = dom.DomFile(name: 'big.bin', size: 101 * 1024 * 1024);
    final dom.DomFile errFile = dom.DomFile(name: 'err.txt', size: 1);
    final dom.DomFile okFile = dom.DomFile(name: 'a.txt', size: 5);
    final List<dom.DomFile?> files = <dom.DomFile?>[okFile, null, bigFile, errFile];

    final dom.DomDataTransfer transfer = _dataTransfer(
      types: <String>[baseDnd.DataTransfers.FILES],
      files: files,
      items: files,
    );

    // The ported function awaits every read; drive the fake readers the way
    // the harness's synchronous FileReader fake does. The harness enters
    // through `extractEditorsAndFilesDropData`, so the Dart replay does too.
    final Future<List<Object?>> pending = dndPort.extractEditorsAndFilesDropData(
      _FakeAccessor(<instantiation.ServiceIdentifier, Object?>{
        instantiation.IInstantiationService: _FakeInstantiationService(
          <instantiation.ServiceIdentifier, Object?>{
            dialogs.IDialogService: dialogService,
          },
        ),
      }),
      _dragEvent(transfer),
    );
    for (final dom.FileReader reader in dom.FileReader.instances) {
      final dom.DomFile file = reader.readAsArrayBufferCalls.first as dom.DomFile;
      if (identical(file, errFile)) {
        reader.onerror!(<String, Object?>{'target': null});
      } else {
        reader.result = 'hello';
        reader.onload!(<String, Object?>{
          'target': <String, Object?>{'result': 'hello'},
        });
      }
    }
    final List<Object?> editors = await pending;

    expect(_projectEditors(editors), _exp(expected['editors']));
    expect(dialogLog, _exp(expected['dialogLog']));
    expect(
      dom.FileReader.instances
          .map((dom.FileReader reader) => reader.readAsArrayBufferCalls
              .map((Object file) => (file as dom.DomFile).name)
              .toList())
          .toList(),
      _exp(expected['readers']),
    );
  });

  test('batch191 FileSystemHandle drop path matches truth', () async {
    final Map<String, dynamic> expected = _map(truth['fileHandleDrop']);
    platform.isWebOverride = true;
    platform.isNativeOverride = false;

    // `WebFileSystemAccess.supported(mainWindow)` → true via the injectable
    // property reader (the carrier exposes `showDirectoryPicker`).
    webFileSystemAccessGetProp = (dynamic obj, String name) {
      if (name == 'showDirectoryPicker') return () {};
      if (obj is Map) return obj[name];
      return null;
    };

    final dom.DomFile fileHandle = dom.DomFile(name: 'h.txt');
    fileHandle.getAsFileSystemHandle =
        () async => <String, Object?>{'kind': 'file', 'name': 'h.txt'};
    final dom.DomFile dirHandle = dom.DomFile(name: 'dir');
    dirHandle.getAsFileSystemHandle =
        () async => <String, Object?>{'kind': 'directory', 'name': 'dir'};
    final dom.DomFile noHandle = dom.DomFile(name: 'none');
    noHandle.getAsFileSystemHandle = () async => null;

    final List<dom.DomFile?> items =
        <dom.DomFile?>[fileHandle, dirHandle, noHandle, null];
    final dom.DomDataTransfer transfer = _dataTransfer(
      types: <String>[baseDnd.DataTransfers.FILES],
      items: items,
      files: items,
    );

    final List<Object?> editors = await dndPort.extractEditorsAndFilesDropData(
      _FakeAccessor(<instantiation.ServiceIdentifier, Object?>{
        instantiation.IInstantiationService: _FakeInstantiationService(
          <instantiation.ServiceIdentifier, Object?>{
            filesPlatform.IFileService: _FakeFileService(_FakeProvider()),
          },
        ),
      }),
      _dragEvent(transfer),
    );

    expect(_projectEditors(editors), _exp(expected['editors']));
  });
}