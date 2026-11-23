// batch67: commonProperties.ts + backup.ts + editorFeatures.ts +
// inlineCompletionContextKeys.ts. Assertions are data-driven from
// batch67_truth.json (Node TS transpile+vm real evaluation of the four files
// and their real dependency chains, run against the same host platform/env).
import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:semi_design_flutter/src/monaco/base/common/platform.dart' as plat;
import 'package:semi_design_flutter/src/monaco/base/common/uri.dart' show URI;
import 'package:semi_design_flutter/src/monaco/editor/common/editorFeatures.dart' as ef;
import 'package:semi_design_flutter/src/monaco/editor/contrib/inlineCompletions/browser/controller/inlineCompletionContextKeys.dart'
    as ic;
import 'package:semi_design_flutter/src/monaco/platform/backup/common/backup.dart' as bk;
import 'package:semi_design_flutter/src/monaco/platform/contextkey/common/contextkey.dart'
    show
        ContextKeyExpression,
        IContext,
        IContextKey,
        IContextKeyServiceTarget,
        IContextKeyServiceType,
        IScopedContextKeyService,
        RawContextKey;
import 'package:semi_design_flutter/src/monaco/platform/telemetry/common/commonProperties.dart'
    as cp;

Map<String, dynamic> _truth() => jsonDecode(
      File('tool/ts2dart/batch67_truth.json').readAsStringSync(),
    ) as Map<String, dynamic>;

ICommonProps _props(Map<String, dynamic> a) => cp.resolveCommonProperties(
      (a['release'] ?? '1.85.0') as String,
      (a['hostname'] ?? 'host') as String,
      (a['arch'] ?? 'x64') as String,
      a['commit'] as String?,
      a['version'] as String?,
      a['machineId'] as String?,
      a['sqmId'] as String?,
      a['devDeviceId'] as String?,
      (a['isInternalTelemetry'] ?? false) as bool,
      a['releaseDate'] as String?,
      a['product'] as String?,
    );

/// Minimal structural view of the returned ICommonProperties carrier.
typedef ICommonProps = Object;

Object? _get(Object props, String key) => (props as dynamic)[key] as Object?;

void main() {
  late Map<String, dynamic> t;
  setUpAll(() => t = _truth());

  // ------------------------------------------------------- commonProperties
  test('b67 commonProperties: platform constants match truth', () {
    final p = t['commonProperties']['platform'] as Map<String, dynamic>;
    expect(plat.platform, p['platform']);
    expect(plat.Platform_.Linux, p['Platform_Linux']);
    expect(plat.isLinuxSnap, p['isLinuxSnap']);
    expect(plat.PlatformToString(plat.platform), p['PlatformToString']);
  });

  test('b67 commonProperties: static fields match truth', () {
    final s = (t['commonProperties']['statics'] as Map<String, dynamic>);
    final props = cp.resolveCommonProperties(
      '1.85.0', 'host', 'x64', 'abc123', '1.85.0', 'mid', 'sid', 'did',
      false, '2023-11-01');
    for (final entry in s.entries) {
      if (entry.key == 'sessionID') continue; // random UUID + wall-clock
      expect(_get(props, entry.key), entry.value, reason: entry.key);
    }
    // sessionID = UUID + Date.now(): validate shape, not exact value.
    final sid = _get(props, 'sessionID') as String;
    expect(RegExp(r'^[0-9a-f-]{36}\d+$').hasMatch(sid), isTrue,
        reason: 'sessionID shape: $sid');
  });

  test('b67 commonProperties: platformVersion regex matches truth', () {
    for (final c in (t['commonProperties']['platformVersion'] as List)) {
      final cm = c as Map<String, dynamic>;
      final props = cp.resolveCommonProperties(cm['release'] as String,
          'host', 'x64', null, null, null, null, null, false, null);
      expect(_get(props, 'common.platformVersion'), cm['r'],
          reason: 'release=${cm['release']}');
    }
  });

  test('b67 commonProperties: product/internal/penguin variants match truth', () {
    for (final c in (t['commonProperties']['variants'] as List)) {
      final cm = c as Map<String, dynamic>;
      final overrides = (cm['overrides'] as Map).cast<String, dynamic>();
      final a = <String, dynamic>{
        'release': '1.85.0',
        'hostname': 'host',
        'isInternalTelemetry': false,
        'product': null,
      }..addAll(overrides);
      final props = _props(a);
      for (final pair in (cm['vals'] as List)) {
        expect(_get(props, pair[0] as String), pair[1],
            reason: '${cm['name']} / ${pair[0]}');
      }
    }
  });

  test('b67 commonProperties: dynamic getters (sequence/timestamp/since)', () {
    final d = t['commonProperties']['dynamic'] as Map<String, dynamic>;
    final props = cp.resolveCommonProperties(
        '1.85.0', 'host', 'x64', null, null, null, null, null, false, null);
    final seq1 = _get(props, 'common.sequence');
    final seq2 = _get(props, 'common.sequence');
    expect(seq1, d['seq1']);
    expect(seq2, d['seq2']);
    expect(_get(props, 'timestamp'), isA<DateTime>());
    final since = _get(props, 'common.timesincesessionstart') as int;
    expect(since >= 0, isTrue);
  });

  test('b67 commonProperties: verifyMicrosoftInternalDomain matches truth', () {
    final env = (t['commonProperties']['envUserDnsDomain'] as String?) ;
    for (final c in (t['commonProperties']['verify'] as List)) {
      final cm = c as Map<String, dynamic>;
      final domains = (cm['domains'] as List).cast<String>();
      // host env is fixed; verify the function agrees with truth per list.
      expect(cp.verifyMicrosoftInternalDomain(domains), cm['r'],
          reason: '${cm['name']} env=$env');
    }
  });

  // ------------------------------------------------------------ backup.ts
  test('b67 backup: suffix matches truth', () {
    expect(bk.WORKING_COPY_BACKUP_TEMP_FILE_SUFFIX, t['backup']['suffix']);
  });

  test('b67 backup: isFolder/isWorkspace hasOwnProperty guards match truth', () {
    for (final c in (t['backup']['cases'] as List)) {
      final cm = c as Map<String, dynamic>;
      final own = cm['folder'] as String;
      // Reconstruct the carrier: truth objects only had own keys when flagged.
      final Map<String, Object?> carrier = <String, Object?>{};
      if (own == 'own') carrier['folderUri'] = 'x';
      final r = cm['r'];
      if (r is bool) {
        if (cm['name'] == 'workspace') {
          carrier.clear();
          carrier['workspace'] = 'x';
          expect(bk.isWorkspaceBackupInfo(carrier), r, reason: cm['name'] as String);
        } else if (cm['name'] == 'proto_folder') {
          // JS Object.create({folderUri:1}): inherited key -> false. Dart Map
          // carrier has no such inherited key -> false.
          expect(bk.isFolderBackupInfo(carrier), r, reason: cm['name'] as String);
        } else {
          expect(bk.isFolderBackupInfo(carrier), r, reason: cm['name'] as String);
        }
      } else {
        final rm = r as Map<String, dynamic>;
        final both = <String, Object?>{};
        if (cm['name'] == 'both') {
          both['folderUri'] = 'x';
          both['workspace'] = 'y';
        }
        expect(bk.isFolderBackupInfo(both), rm['folder'], reason: '${cm['name']} folder');
        expect(bk.isWorkspaceBackupInfo(both), rm['workspace'], reason: '${cm['name']} workspace');
      }
    }
    // concrete implementing class path (own field)
    final folderInstance = _Folder(URI.parse('file:///a'));
    expect(bk.isFolderBackupInfo(folderInstance), isTrue);
    expect(bk.isWorkspaceBackupInfo(folderInstance), isFalse);
  });

  // ------------------------------------------------------- editorFeatures.ts
  test('b67 editorFeatures: register + defensive copy match truth', () {
    final e = t['editorFeatures'] as Map<String, dynamic>;
    final before = ef.getEditorFeatures().length;
    expect(before, e['before']);
    void f1() {}
    void f2() {}
    ef.registerEditorFeature(f1);
    ef.registerEditorFeature(f2);
    final after = ef.getEditorFeatures().toList();
    expect(after.length, before + (e['afterRegistration'] as int));
    final identity = (e['identity'] as List).cast<bool>();
    expect(identical(after[after.length - 2], f1), identity[0]);
    expect(identical(after[after.length - 1], f2), identity[1]);
    // mutating returned iterable's copy must not affect registry
    final returned = ef.getEditorFeatures().toList();
    returned.add(() {});
    expect(ef.getEditorFeatures().length, after.length);
  });

  // -------------------------------------------- inlineCompletionContextKeys
  test('b67 inlineCompletionContextKeys: 13 keys match truth', () {
    final keys = (t['inlineCompletionContextKeys'] as List)
        .map((x) => x as Map<String, dynamic>)
        .toList();
    expect(keys.length, 13);
    for (final k in keys) {
      final field = k['field'] as String;
      final rk = _field(field);
      expect(rk.key, k['key'], reason: '$field key');
      // Read defaultValue through the public bindTo path (TS private field).
      final svc = _CaptureService();
      rk.bindTo(svc);
      final dartDefault = svc.lastDefaultValue;
      final expDefault = k['defaultValue'];
      if (expDefault == '__undefined__') {
        expect(dartDefault, isNull, reason: '$field default undefined');
      } else {
        expect(dartDefault, expDefault, reason: '$field default');
      }
    }
  });
}

/// Minimal IContextKeyService that captures the defaultValue passed to createKey.
class _CaptureService implements IContextKeyServiceType {
  Object? lastDefaultValue;
  // ignore: unused_element, override_on_non_overriding_member
  Object? get _serviceBrand => null;
  @override
  Object get onDidChangeContext => throw UnimplementedError();
  @override
  void bufferChangeEvents(void Function() callback) => callback();
  @override
  IContextKey<T> createKey<T>(String key, T? defaultValue) {
    lastDefaultValue = defaultValue;
    return _CaptureKey<T>();
  }
  @override
  bool contextMatchesRules(ContextKeyExpression? rules) => false;
  @override
  T? getContextKeyValue<T>(String key) => null;
  @override
  IScopedContextKeyService createScoped(IContextKeyServiceTarget target) =>
      throw UnimplementedError();
  @override
  IContextKeyServiceType createOverlay(Iterable<List<Object?>> overlay) =>
      throw UnimplementedError();
  @override
  IContext getContext(IContextKeyServiceTarget? target) => throw UnimplementedError();
  @override
  void updateParent(IContextKeyServiceType parentContextKeyService) {}
}

class _CaptureKey<T> implements IContextKey<T> {
  @override
  void set(T value) {}
  @override
  void reset() {}
  @override
  T? get_() => null;
}

RawContextKey _field(String name) {
  switch (name) {
    case 'inlineSuggestionVisible': return ic.InlineCompletionContextKeys.inlineSuggestionVisible;
    case 'inlineSuggestionAlternativeActionVisible': return ic.InlineCompletionContextKeys.inlineSuggestionAlternativeActionVisible;
    case 'inlineSuggestionHasIndentation': return ic.InlineCompletionContextKeys.inlineSuggestionHasIndentation;
    case 'inlineSuggestionHasIndentationLessThanTabSize': return ic.InlineCompletionContextKeys.inlineSuggestionHasIndentationLessThanTabSize;
    case 'suppressSuggestions': return ic.InlineCompletionContextKeys.suppressSuggestions;
    case 'cursorBeforeGhostText': return ic.InlineCompletionContextKeys.cursorBeforeGhostText;
    case 'cursorInIndentation': return ic.InlineCompletionContextKeys.cursorInIndentation;
    case 'hasSelection': return ic.InlineCompletionContextKeys.hasSelection;
    case 'cursorAtInlineEdit': return ic.InlineCompletionContextKeys.cursorAtInlineEdit;
    case 'inlineEditVisible': return ic.InlineCompletionContextKeys.inlineEditVisible;
    case 'tabShouldJumpToInlineEdit': return ic.InlineCompletionContextKeys.tabShouldJumpToInlineEdit;
    case 'tabShouldAcceptInlineEdit': return ic.InlineCompletionContextKeys.tabShouldAcceptInlineEdit;
    case 'inInlineEditsPreviewEditor': return ic.InlineCompletionContextKeys.inInlineEditsPreviewEditor;
    default: throw StateError('unknown field $name');
  }
}

class _Folder implements bk.IFolderBackupInfo {
  @override
  final URI folderUri;
  @override
  String? get remoteAuthority => null;
  _Folder(this.folderUri);
}
