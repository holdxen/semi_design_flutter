// batch61: platform/workspace/common/workspace.ts
// Assertions are data-driven from workspace_truth.json (recursive Node TS
// transpile+vm of workspace.ts and its real uri/resources/TST/path deps).
import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:semi_design_flutter/src/monaco/base/common/uri.dart' show URI;
import 'package:semi_design_flutter/src/monaco/platform/environment/common/environment.dart';
import 'package:semi_design_flutter/src/monaco/platform/workspace/common/workspace.dart';

Map<String, dynamic> _truth() => jsonDecode(
      File('tool/ts2dart/workspace_truth.json').readAsStringSync(),
    ) as Map<String, dynamic>;

Object? _dec(Object? v) =>
    (v == '__undefined__' || v == '__null__') ? null : v;

Map<String, Object?> _uriMap(String s) => <String, Object?>{'__uri__': s};

Map<String, dynamic> _result(Map<dynamic, dynamic> raw) =>
    raw.cast<String, dynamic>();

/// Normalize Dart URI values into the truth's {__uri__: string} form.
Object? _normDart(Object? v) {
  if (v is URI) return _uriMap(v.toString());
  if (v is Map) return v.map((k, val) => MapEntry(k.toString(), _normDart(val)));
  if (v is List) return v.map(_normDart).toList();
  return v;
}

class _W implements IWorkspace {
  @override final String id;
  @override final URI? uri;
  @override final List<IWorkspaceFolder> folders;
  @override final bool? transient;
  @override final URI? configuration;
  @override final String? name;
  _W({required this.id, this.uri, this.folders = const <IWorkspaceFolder>[],
      this.transient, this.configuration, this.name});
}

class _Env implements IEnvironmentServiceType {
  final URI home;
  _Env(this.home);
  @override URI get untitledWorkspacesHome => home;
  @override Object? get _serviceBrand => null;
  @override URI get stateResource => home;
  @override URI get userRoamingDataHome => home;
  @override URI get keyboardLayoutResource => home;
  @override URI get argvResource => home;
  @override URI get workspaceStorageHome => home;
  @override URI get localHistoryHome => home;
  @override URI get cacheHome => home;
  @override URI get appSharedDataHome => home;
  @override URI get userDataSyncHome => home;
  @override String? get sync => null;
  @override String? get continueOn => null;
  @override String? get editSessionId => null;
  @override IExtensionHostDebugParams get debugExtensionHost => throw UnimplementedError();
  @override bool get isExtensionDevelopment => false;
  @override Object? get disableExtensions => null;
  @override List<String>? get skipBuiltinExtensions => null;
  @override List<String>? get enableExtensions => null;
  @override List<URI>? get extensionDevelopmentLocationURI => null;
  @override List<ExtensionKind>? get extensionDevelopmentKind => null;
  @override URI? get extensionTestsLocationURI => null;
  @override URI get logsHome => home;
  @override String? get logLevel => null;
  @override List<List<String>>? get extensionLogLevel => null;
  @override bool get verbose => false;
  @override bool get isBuilt => false;
  @override bool get disableTelemetry => false;
  @override bool get disableExperiments => false;
  @override URI get serviceMachineIdResource => home;
  @override URI get agentSessionsWorkspace => home;
  @override URI? get policyFile => null;
}

void main() {
  final truth = _truth();
  final u1 = URI.parse('file:///foo/bar');
  final u2 = URI.parse('file:///foo/baz');
  final uCfg = URI.parse('file:///foo/my.code-workspace');

  test('b61 decorator, WorkbenchState and constants match truth', () {
    expect(IWorkspaceContextService.toString(),
        (truth['decorator'] as Map<String, dynamic>)['id']);
    final s = ((truth['enums'] as Map<String, dynamic>)['WorkbenchState']
        as Map<String, dynamic>);
    expect(WorkbenchState.EMPTY, s['EMPTY']);
    expect(WorkbenchState.FOLDER, s['FOLDER']);
    expect(WorkbenchState.WORKSPACE, s['WORKSPACE']);
    final c = truth['constants'] as Map<String, dynamic>;
    for (final key in c.keys) {
      switch (key) {
        case 'EXTENSION_DEVELOPMENT_EMPTY_WINDOW_WORKSPACE':
          expect(EXTENSION_DEVELOPMENT_EMPTY_WINDOW_WORKSPACE, c[key]);
          break;
        case 'UNKNOWN_EMPTY_WINDOW_WORKSPACE':
          expect(UNKNOWN_EMPTY_WINDOW_WORKSPACE, c[key]);
          break;
        case 'WORKSPACE_EXTENSION':
          expect(WORKSPACE_EXTENSION, c[key]);
          break;
        case 'WORKSPACE_SUFFIX':
          expect(WORKSPACE_SUFFIX, c[key]);
          break;
        case 'WORKSPACE_FILTER':
          expect(WORKSPACE_FILTER, c[key]);
          break;
        case 'UNTITLED_WORKSPACE_NAME':
          expect(UNTITLED_WORKSPACE_NAME, c[key]);
          break;
        case 'STANDALONE_EDITOR_WORKSPACE_ID':
          expect(STANDALONE_EDITOR_WORKSPACE_ID, c[key]);
          break;
        default:
          fail('unknown constant: $key');
      }
    }
  });

  test('b61 five predicates match 46 truth cases', () {
    final p = truth['predicates'] as Map<String, dynamic>;
    final wf = WorkspaceFolder(
        _WFData(u1, 'bar', 0));
    final map = <String, List<Object?>>{
      'isSingleFolderWorkspaceIdentifier': <Object?>[
        null, null, 42, 'str', <String, Object?>{},
        <String, Object?>{'id': 'x'},
        <String, Object?>{'id': 'x', 'uri': u1},
        <String, Object?>{'id': 5, 'uri': u1},
        <String, Object?>{'uri': u1},
        <String, Object?>{'id': 'x', 'uri': <String, Object?>{}},
        EXTENSION_DEVELOPMENT_EMPTY_WINDOW_WORKSPACE,
      ],
      'isEmptyWorkspaceIdentifier': <Object?>[
        null, null, <String, Object?>{}, <String, Object?>{'id': ''},
        <String, Object?>{'id': 'x'},
        <String, Object?>{'id': 'x', 'uri': u1},
        <String, Object?>{'id': 'x', 'configPath': uCfg},
        EXTENSION_DEVELOPMENT_EMPTY_WINDOW_WORKSPACE,
        UNKNOWN_EMPTY_WINDOW_WORKSPACE,
      ],
      'isWorkspaceIdentifier': <Object?>[
        null, null, <String, Object?>{}, <String, Object?>{'id': 'x'},
        <String, Object?>{'id': 'x', 'configPath': uCfg},
        <String, Object?>{'id': 5, 'configPath': uCfg},
        <String, Object?>{'id': 'x', 'configPath': <String, Object?>{}},
        <String, Object?>{'id': 'x', 'uri': u1},
      ],
      'isWorkspace': <Object?>[
        null, null, 42, 'str', <String, Object?>{},
        <String, Object?>{'id': 'x'},
        <String, Object?>{'id': 'x', 'folders': <Object?>[]},
        <String, Object?>{'id': 5, 'folders': <Object?>[]},
        <String, Object?>{'id': 'x', 'folders': 'no'},
        <String, Object?>{'id': 'x', 'folders': <Object?>[u1]},
      ],
      'isWorkspaceFolder': <Object?>[
        null, null, <String, Object?>{},
        <String, Object?>{'uri': u1, 'name': 'n', 'toResource': (String s) => u1},
        <String, Object?>{'uri': <String, Object?>{}, 'name': 'n', 'toResource': (String s) => u1},
        <String, Object?>{'uri': u1, 'name': 5, 'toResource': (String s) => u1},
        <String, Object?>{'uri': u1, 'name': 'n', 'toResource': 42},
        wf,
      ],
    };
    final fns = <String, bool Function(Object?)>{
      'isSingleFolderWorkspaceIdentifier': isSingleFolderWorkspaceIdentifier,
      'isEmptyWorkspaceIdentifier': isEmptyWorkspaceIdentifier,
      'isWorkspaceIdentifier': isWorkspaceIdentifier,
      'isWorkspace': isWorkspace,
      'isWorkspaceFolder': isWorkspaceFolder,
    };
    for (final entry in p.entries) {
      final cases = entry.value as List<dynamic>;
      final inputs = map[entry.key]!;
      expect(cases.length, inputs.length, reason: entry.key);
      for (var i = 0; i < cases.length; i++) {
        final expected = (cases[i] as Map<String, dynamic>)['result'] as bool;
        expect(fns[entry.key]!(inputs[i]), expected,
            reason: '${entry.key}[$i] input=${cases[i]['input']}');
      }
    }
  });

  test('b61 toWorkspaceIdentifier + reviveIdentifier match truth', () {
    for (final c in truth['toWorkspaceIdentifier'] as List<dynamic>) {
      final m = c as Map<String, dynamic>;
      final name = m['name'] as String;
      late Object? arg0;
      bool? isDev;
      switch (name) {
        case 'string backupPath': arg0 = '/some/path/my.code-workspace'; break;
        case 'undefined + dev': arg0 = null; isDev = true; break;
        case 'undefined + no dev': arg0 = null; isDev = false; break;
        case 'configuration': arg0 = _W(id: 'cfg', configuration: uCfg); break;
        case 'uri': arg0 = _W(id: 'solo', uri: u1); break;
        case 'empty workspace': arg0 = _W(id: 'empty'); break;
        case 'string empty': arg0 = ''; break;
        default: fail('unknown toWorkspaceIdentifier case: $name');
      }
      final expected = _result(m['result'] as Map)['result'];
      expect(_normDart(toWorkspaceIdentifier(arg0, isDev)), expected,
          reason: name);
    }

    final revInputs = <Object?>[
      null, null,
      <String, Object?>{'id': 'sf', 'uri': u1.toJSON()},
      <String, Object?>{'id': 'mf', 'configPath': uCfg.toJSON()},
      <String, Object?>{'id': 'empty'},
      <String, Object?>{},
      <String, Object?>{'id': ''},
    ];
    final revCases = truth['reviveIdentifier'] as List<dynamic>;
    for (var i = 0; i < revCases.length; i++) {
      final m = revCases[i] as Map<String, dynamic>;
      final expected = _dec(_result(m['result'] as Map)['result']);
      final actual = reviveIdentifier(revInputs[i]);
      if (expected == null) {
        expect(actual, isNull, reason: m['name'] as String);
      } else {
        expect(actual, isNotNull, reason: m['name'] as String);
        final em = expected as Map;
        expect(actual![ em.keys.first.toString()] is URI ||
            actual[em.keys.first.toString()] == em.values.first,
            isTrue,
            reason: '${m['name']} revived');
        expect(actual['id'], em['id'], reason: '${m['name']} id');
      }
    }
  });

  test('b61 WorkspaceFolder and toWorkspaceFolder match truth', () {
    final m = (truth['workspaceFolder'] as Map<String, dynamic>);
    final f = m['fields'] as Map<String, dynamic>;
    final wf = WorkspaceFolder(_WFData(u1, 'bar', 2),
        <String, Object?>{'path': '/raw/path'});
    expect((wf.uri.toString()), (f['uri'] as Map<String, dynamic>)['__uri__']);
    expect(wf.name, f['name']);
    expect(wf.index, f['index']);
    expect(wf.raw, f['raw']);
    final toRes = _result(m['toResource'] as Map)['result'] as Map<String, dynamic>;
    expect(wf.toResource('sub/file.txt').toString(), toRes['__uri__']);
    final json = _result(m['toJSON'] as Map)['result'] as Map<String, dynamic>;
    expect(wf.toJSON()['name'], json['name']);
    expect(wf.toJSON()['index'], json['index']);
    final twf = _result(m['toWorkspaceFolder'] as Map)['result'] as Map<String, dynamic>;
    final built = toWorkspaceFolder(u1);
    expect(built.name, twf['name']);
    expect(built.index, twf['index']);
    expect(built.toJSON()['uri'] is URI, isTrue);
    final root = _result(m['toWorkspaceFolderRoot'] as Map)['result'] as Map<String, dynamic>;
    expect(toWorkspaceFolder(URI.parse('file:///')).name, root['name']);
  });

  test('b61 Workspace class fields, getFolder, toJSON and update match truth', () {
    final m = truth['workspace'] as Map<String, dynamic>;
    final wf1 = WorkspaceFolder(_WFData(u1, 'bar', 0));
    final wf2 = WorkspaceFolder(_WFData(u2, 'baz', 1));
    final ws = Workspace('id1', <WorkspaceFolder>[wf1, wf2], false, uCfg,
        (URI key) => false, 'My Workspace');
    final f = m['fields'] as Map<String, dynamic>;
    expect(ws.id, f['id']);
    expect(ws.uri.toString(), (f['uri'] as Map<String, dynamic>)['__uri__']);
    expect(ws.transient, f['transient']);
    expect(ws.configuration.toString(),
        (f['configuration'] as Map<String, dynamic>)['__uri__']);
    expect(ws.name, f['name']);
    final folders = _result(f['folders'] as Map)['result'] as List<dynamic>;
    expect(ws.folders.length, folders.length);
    final hit = _result(m['getFolderHit'] as Map)['result'] as Map<String, dynamic>;
    expect(ws.getFolder(u1)!.uri.toString(), hit['uri']['__uri__']);
    expect(_dec(_result(m['getFolderMiss'] as Map)['result']), isNull);
    expect(ws.getFolder(null), isNull);
    final json = _result(m['toJSON'] as Map)['result'] as Map<String, dynamic>;
    expect(ws.toJSON()['id'], json['id']);
    expect(ws.toJSON()['name'], json['name']);

    final wf3 = WorkspaceFolder(_WFData(URI.parse('file:///qux'), 'qux', 0));
    final other = Workspace('id2', <WorkspaceFolder>[wf3], true, null,
        (URI key) => false, 'Updated', URI.parse('file:///explicit'));
    ws.update(other);
    final a = m['afterUpdate'] as Map<String, dynamic>;
    expect(ws.id, a['id']);
    expect(ws.uri.toString(), (a['uri'] as Map<String, dynamic>)['__uri__']);
    expect(ws.transient, a['transient']);
    expect(ws.configuration, isNull);
    expect(ws.name, a['name']);
    final newHit = _result(a['getFolderHit'] as Map)['result'] as Map<String, dynamic>;
    expect(ws.getFolder(URI.parse('file:///qux'))!.name, newHit['name']);
    expect(_dec(_result(a['getFolderOld'] as Map)['result']), isNull);

    final single = Workspace('single', <WorkspaceFolder>[wf1], false, null,
        (URI key) => false);
    expect(single.uri.toString(),
        (m['implicitUriSingle'] as Map<String, dynamic>)['__uri__']);
    final multi = Workspace('multi', <WorkspaceFolder>[wf1, wf2], false, null,
        (URI key) => false);
    expect(multi.uri, _dec(m['implicitUriMulti']));
  });

  test('b61 utility functions match 20 truth cases', () {
    final u = truth['utils'] as Map<String, dynamic>;
    final env = _Env(URI.file('/home/user/untitled'));
    final isUntitledInputs = <Object?>[
      URI.file('/home/user/untitled/foo'), URI.file('/home/user/untitled'),
      URI.file('/home/user/other'), URI.parse('file:///home/user/UNTITLED/foo'),
    ];
    for (var i = 0; i < isUntitledInputs.length; i++) {
      expect(isUntitledWorkspace(isUntitledInputs[i] as URI, env),
          (u['isUntitledWorkspace']![i] as Map<String, dynamic>)['result']['result'],
          reason: 'isUntitledWorkspace[$i]');
    }
    final tmpInputs = <Object?>[
      URI.parse('tmp:/foo'), URI.file('/foo'),
      _W(id: 'x', configuration: URI.parse('tmp:/x')),
      _W(id: 'x', configuration: null), _W(id: 'x', configuration: uCfg),
    ];
    for (var i = 0; i < tmpInputs.length; i++) {
      expect(isTemporaryWorkspace(tmpInputs[i]!),
          (u['isTemporaryWorkspace']![i] as Map<String, dynamic>)['result']['result'],
          reason: 'isTemporaryWorkspace[$i]');
    }
    final standalone = <IWorkspace>[
      _W(id: STANDALONE_EDITOR_WORKSPACE_ID), _W(id: 'other'),
    ];
    for (var i = 0; i < standalone.length; i++) {
      expect(isStandaloneEditorWorkspace(standalone[i]),
          (u['isStandaloneEditorWorkspace']![i] as Map<String, dynamic>)['result']['result'],
          reason: 'isStandaloneEditorWorkspace[$i]');
    }
    final savedInputs = <Object?>[
      URI.file('/home/user/other'), URI.file('/home/user/untitled/foo'),
      URI.parse('tmp:/foo'),
    ];
    for (var i = 0; i < savedInputs.length; i++) {
      expect(isSavedWorkspace(savedInputs[i] as URI, env),
          (u['isSavedWorkspace']![i] as Map<String, dynamic>)['result']['result'],
          reason: 'isSavedWorkspace[$i]');
    }
    final extInputs = <Object>[
      'foo.code-workspace', 'foo.txt', URI.file('/foo.code-workspace'),
      URI.file('/foo.txt'), 'CODE-WORKSPACE', 'x.code-workspace.bak',
    ];
    for (var i = 0; i < extInputs.length; i++) {
      expect(hasWorkspaceFileExtension(extInputs[i]),
          (u['hasWorkspaceFileExtension']![i] as Map<String, dynamic>)['result']['result'],
          reason: 'hasWorkspaceFileExtension[$i]');
    }
  });
}

class _WFData implements IWorkspaceFolderData {
  @override final URI uri;
  @override final String name;
  @override final num index;
  _WFData(this.uri, this.name, this.index);
}
