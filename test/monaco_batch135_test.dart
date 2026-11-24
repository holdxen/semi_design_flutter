// Truth-driven tests for batch135:
// platform/workspaces/common/workspaces.ts
import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:semi_design_flutter/src/monaco/base/common/resources.dart' as resources;
import 'package:semi_design_flutter/src/monaco/base/common/uri.dart' as uri;
import 'package:semi_design_flutter/src/monaco/platform/log/common/log.dart' as log;
import 'package:semi_design_flutter/src/monaco/platform/workspace/common/workspace.dart' as workspace;
import 'package:semi_design_flutter/src/monaco/platform/workspaces/common/workspaces.dart'
    as ws;

final Map<String, Object?> _truth =
    jsonDecode(File('tool/ts2dart/batch135_truth.json').readAsStringSync())
        as Map<String, Object?>;

List<Object?> _list(Object? value) => (value as List).cast<Object?>();

Map<String, Object?> _obj(Object? value) =>
    (value as Map).cast<String, Object?>();

uri.URI _uri(String value) => uri.URI.parse(value);

class _RecordingLogService extends log.NullLogService {
  final List<String> warnings = <String>[];

  @override
  void warn(Object message, [List<Object?> args = const <Object?>[]]) {
    warnings.add(message.toString());
  }
}

Map<String, Object?> _storedJson(ws.IStoredWorkspaceFolder f) =>
    <String, Object?>{
      if (f.name != null) 'name': f.name,
      if (f.path != null) 'path': f.path,
      if (f.uriString != null) 'uri': f.uriString,
    };

Object _dropNulls(Object value) {
  if (value is Map) {
    return value.map((Object? k, Object? v) =>
        MapEntry<Object?, Object?>(k, v == null ? null : _dropNulls(v)))
      ..removeWhere((Object? k, Object? v) => v == null);
  }
  if (value is List) {
    return value.map((Object? e) => e == null ? null : _dropNulls(e)).toList();
  }
  return value;
}

void main() {
  final resources.IExtUri extUri = resources.ExtUri((uri.URI _) => false);

  test('recent predicates', () {
    final List<Object?> rows = _list(_truth['recentPredicates']);
    expect(
      <Object?>[
        ws.isRecentWorkspace(<String, Object?>{
          'workspace': <String, Object?>{
            'id': 'id',
            'configPath': _uri('file:///w'),
          },
        }),
        ws.isRecentFolder(<String, Object?>{'folderUri': _uri('file:///f')}),
        ws.isRecentFile(<String, Object?>{'fileUri': _uri('file:///x')}),
        ws.isRecentWorkspace(<String, Object?>{'folderUri': _uri('file:///f')}),
      ],
      rows,
    );
  });

  test('stored workspace folder predicates', () {
    expect(
      <Object?>[
        ws.isStoredWorkspaceFolder(<String, Object?>{'path': '/a'}),
        ws.isStoredWorkspaceFolder(
            <String, Object?>{'path': '/a', 'name': 'A'}),
        ws.isStoredWorkspaceFolder(<String, Object?>{'uri': 'file:///a'}),
        ws.isStoredWorkspaceFolder(<String, Object?>{'path': 1}),
        ws.isStoredWorkspaceFolder(
            <String, Object?>{'path': '/a', 'name': 1}),
      ],
      _list(_truth['storedFolderPredicates']),
    );
  });

  test('getStoredWorkspaceFolder', () {
    final uri.URI cfg = _uri('file:///work/w.code-workspace');
    final List<ws.IStoredWorkspaceFolder> rows = <ws.IStoredWorkspaceFolder>[
      ws.getStoredWorkspaceFolder(
          _uri('untitled:foo'), false, null, cfg, extUri),
      ws.getStoredWorkspaceFolder(
          _uri('file:///work/sub'), false, 'Sub', cfg, extUri),
      ws.getStoredWorkspaceFolder(
          _uri('file:///work/sub'), true, 'Sub', cfg, extUri),
      ws.getStoredWorkspaceFolder(
          _uri('file:///other'), false, null, cfg, extUri),
    ];
    final List<Object?> expected = _list(_truth['storedWorkspaceFolder']);
    expect(rows.map(_storedJson).toList(), expected);
  });

  test('toWorkspaceFolders dedupes and absolutizes', () {
    final List<Object?> configured = <Object?>[
      <String, Object?>{'path': 'sub'},
      <String, Object?>{'path': 'sub'},
      <String, Object?>{'uri': 'file:relative.txt'},
      <String, Object?>{'path': ''},
    ];
    final List<Object?> folders = ws
        .toWorkspaceFolders(configured, _uri('file:///work/w.code-workspace'), extUri)
        .map((d) => <String, Object?>{
              'uri': d.uri.toString(),
              'name': d.name,
              'index': d.index,
              'raw': d.raw,
            })
        .toList();
    expect(folders, _list(_truth['workspaceFolders']));
    expect(_list(_truth['workspaceWarnings']), isEmpty);
  });

  test('rewriteWorkspaceFileForNewLocation', () {
    const String raw = '{\n  "folders": [\n    { "path": "sub" },\n'
        '    { "uri": "file:///abs" }\n  ],\n'
        '  "remoteAuthority": "remote"\n}';
    final String rewritten = ws.rewriteWorkspaceFileForNewLocation(
      raw,
      _uri('file:///old/w.code-workspace'),
      false,
      _uri('file:///new/w.code-workspace'),
      extUri,
    );
    expect(rewritten, _obj(_truth['rewrite'])['value']);
    String? message;
    try {
      ws.rewriteWorkspaceFileForNewLocation(
        '{}',
        _uri('file:///old/w.code-workspace'),
        false,
        _uri('file:///new/w.code-workspace'),
        extUri,
      );
    } catch (e) {
      message = e.toString().replaceFirst('Bad state: ', '');
    }
    expect(message, _truth['rewriteInvalid']);
  });

  test('restoreRecentlyOpened', () {
    final _RecordingLogService logger = _RecordingLogService();
    final ws.IRecentlyOpened restored = ws.restoreRecentlyOpened(
      <String, Object?>{
        'entries': <Object?>[
          <String, Object?>{
            'workspace': <String, Object?>{
              'id': 'id1',
              'configPath': 'file:///w1',
            },
            'label': 'W1',
          },
          <String, Object?>{
            'folderUri': 'file:///f1',
            'remoteAuthority': 'ra',
          },
          <String, Object?>{'fileUri': 'file:///x1', 'label': 'X1'},
          <String, Object?>{'unknown': true},
        ],
      },
      logger,
    );
    final Map<String, Object?> e = _obj(_truth['restore']);
    expect(logger.warnings, _list(_truth['restoreWarnings']));
    expect(
      restored.workspaces.map((Object? r) {
        final Map<String, Object?> m = <String, Object?>{
          'kind': r is ws.IRecentWorkspace ? 'workspace' : 'folder',
          'uri': r is ws.IRecentWorkspace
              ? r.identifier.configPath.toString()
              : (r as ws.IRecentFolder).folderUri.toString(),
        };
        final ws.IRecent recent = r as ws.IRecent;
        if (recent.label != null) m['label'] = recent.label;
        if (recent.remoteAuthority != null) {
          m['remoteAuthority'] = recent.remoteAuthority;
        }
        return m;
      }).toList(),
      _list(e['workspaces']),
    );
    expect(
      restored.files.map((Object? r) {
        final ws.IRecentFile f = r as ws.IRecentFile;
        return <String, Object?>{
          'label': f.label,
          'fileUri': f.fileUri.toString(),
        }..removeWhere((String k, Object? v) => v == null);
      }).toList(),
      _list(e['files']),
    );
  });

  test('toStoreData', () {
    final ws.IRecentlyOpened recents = ws.IRecentlyOpened(
      <Object?>[
        ws.IRecentWorkspace(
          _WorkspaceIdentifier('id1', _uri('file:///w1')),
          label: '/w1',
        ),
        ws.IRecentFolder(_uri('file:///folder'), label: 'Nice'),
      ],
      <Object?>[ws.IRecentFile(_uri('file:///x'), label: 'X')],
    );
    expect(
      _dropNulls(ws.toStoreData(recents)),
      _dropNulls(_obj(_truth['storeData'])),
    );
  });
}

class _WorkspaceIdentifier implements workspace.IWorkspaceIdentifier {
  _WorkspaceIdentifier(this.id, this.configPath);

  @override
  final String id;
  @override
  final uri.URI configPath;
}
