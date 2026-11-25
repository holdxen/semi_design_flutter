// 1:1 replay of `editor/common/textModelEditSource.ts` (305 lines).
//
// `tool/ts2dart/_batch249_truth.cjs` recursively transpiles and executes the
// real TypeScript source (37 modules, no stubs) and records the runtime
// surface:
//  - `EditSources` 16 factories (metadata + toString/getType/isAiEdit/
//    isUserEdit + props), incl. avoidPathRedaction / toProperties /
//    normalizeModelRouterTelemetryId;
//  - `TextModelEditSource.toKey` (level + explicit filter override);
//  - `EditDeltaInfo` fromText / fromEdit / tryCreate;
//  - `EditSuggestionId.newId` with an injected deterministic generator.
//
// Adaptations replayed: JS undefined -> null (Map keys with null values are
// kept; conditional spreads omit keys when null); private ctor guard.
import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import '../lib/src/monaco/editor/common/core/edits/stringEdit.dart' as se;
import '../lib/src/monaco/editor/common/core/ranges/offsetRange.dart' as or;
import '../lib/src/monaco/editor/common/core/text/abstractText.dart' as st;
import '../lib/src/monaco/editor/common/languages.dart' as lang;
import '../lib/src/monaco/editor/common/textModelEditSource.dart' as tme;

Map<String, dynamic> _map(dynamic value) =>
    (value as Map).cast<String, dynamic>();

Map<String, dynamic> _truth() => _map(jsonDecode(
    File('tool/ts2dart/batch249_truth.json').readAsStringSync()));

/// Deep structural equality (num/String/bool/null/Map/List).
bool _same(Object? a, Object? b) {
  if (a == null || b == null) return a == b;
  if (a is num && b is num) return a == b;
  if (a is String && b is String) return a == b;
  if (a is bool && b is bool) return a == b;
  if (a is Map && b is Map) {
    if (a.length != b.length) return false;
    for (final k in a.keys) {
      if (!b.containsKey(k) || !_same(a[k], b[k])) return false;
    }
    return true;
  }
  if (a is List && b is List) {
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (!_same(a[i], b[i])) return false;
    }
    return true;
  }
  return false;
}

lang.ProviderId? _provider(dynamic v) {
  if (v == null) return null;
  final m = _map(v);
  return lang.ProviderId(
      m['extensionId'] as String?,
      m['extensionVersion'] as String?,
      m['providerId'] as String?);
}

lang.VersionedExtensionId? _versionedExt(dynamic v) {
  if (v == null) return null;
  final m = _map(v);
  return lang.VersionedExtensionId(
      m['extensionId'] as String, m['version'] as String);
}

/// Reconstruct a factory call from the recorded raw input, mirroring the
/// harness case names exactly.
tme.TextModelEditSource _build(String name, Map<String, dynamic> input) {
  dynamic inp(String k) => input[k];

  switch (name) {
    case 'unknown.name':
    case 'unknown.null':
      return tme.EditSources.unknown(name: inp('name') as String?);
    case 'rename':
      return tme.EditSources.rename(
          inp('oldName') as String?, inp('newName') as String);
    case 'chatApplyEdits':
      return tme.EditSources.chatApplyEdits(
        modelId: inp('modelId') as String?,
        autoTier: inp('autoTier') as String?,
        fusionModel: inp('fusionModel') as String?,
        sessionId: inp('sessionId') as String?,
        requestId: inp('requestId') as String?,
        languageId: inp('languageId') as String,
        mode: inp('mode') as String?,
        extensionId: _versionedExt(input['extensionId']),
        codeBlockSuggestionId: inp('codeBlockSuggestionId'),
        origin: inp('origin') as String?,
        harness: inp('harness') as String?,
        agentSessionId: inp('agentSessionId') as String?,
        chatSessionId: inp('chatSessionId') as String?,
      );
    case 'agentHostChatApplyEdits':
      return tme.EditSources.agentHostChatApplyEdits(
        modelId: inp('modelId') as String?,
        autoTier: inp('autoTier') as String?,
        fusionModel: inp('fusionModel') as String?,
        sessionId: inp('sessionId') as String,
        agentSessionId: inp('agentSessionId') as String?,
        chatSessionId: inp('chatSessionId') as String?,
        requestId: inp('requestId') as String,
        harness: inp('harness') as String,
      );
    case 'chatUndoEdits':
      return tme.EditSources.chatUndoEdits();
    case 'chatReset':
      return tme.EditSources.chatReset();
    case 'inlineCompletionAccept':
    case 'inlineCompletionAccept.nesFalse':
      return tme.EditSources.inlineCompletionAccept(
        nes: inp('nes') as bool,
        requestUuid: inp('requestUuid') as String,
        languageId: inp('languageId') as String,
        providerId: _provider(input['providerId']),
        correlationId: inp('correlationId') as String?,
      );
    case 'inlineCompletionPartialAccept':
      return tme.EditSources.inlineCompletionPartialAccept(
        nes: inp('nes') as bool,
        requestUuid: inp('requestUuid') as String,
        languageId: inp('languageId') as String,
        providerId: _provider(input['providerId']),
        correlationId: inp('correlationId') as String?,
        type: inp('type') as String,
      );
    case 'inlineChatApplyEdit':
      return tme.EditSources.inlineChatApplyEdit(
        modelId: inp('modelId') as String?,
        autoTier: inp('autoTier') as String?,
        requestId: inp('requestId') as String?,
        sessionId: inp('sessionId') as String?,
        languageId: inp('languageId') as String,
        extensionId: _versionedExt(input['extensionId']),
      );
    case 'reloadFromDisk':
      return tme.EditSources.reloadFromDisk();
    case 'cursor.type':
    case 'cursor.paste':
      return tme.EditSources.cursor(
        kind: inp('kind') as String,
        detailedSource: inp('detailedSource') as String?,
      );
    case 'setValue':
      return tme.EditSources.setValue();
    case 'eolChange':
      return tme.EditSources.eolChange();
    case 'applyEdits':
      return tme.EditSources.applyEdits();
    case 'snippet':
      return tme.EditSources.snippet();
    case 'suggest':
    case 'suggest.noProvider':
      return tme.EditSources.suggest(
          providerId: _provider(input['providerId']));
    case 'codeAction':
      return tme.EditSources.codeAction(
        kind: inp('kind') as String?,
        providerId: _provider(input['providerId']),
      );
    default:
      throw StateError('unknown factory case: $name');
  }
}

Map<String, dynamic> _projDelta(tme.EditDeltaInfo d) => {
      'linesAdded': d.linesAdded,
      'linesRemoved': d.linesRemoved,
      'charsAdded': d.charsAdded,
      'charsRemoved': d.charsRemoved,
    };

Object? _projDeltaOrNull(tme.EditDeltaInfo? d) =>
    d == null ? null : _projDelta(d);

se.StringEdit _editFromInput(Map<String, dynamic> input) {
  final reps = <se.StringReplacement>[];
  for (final raw in (input['replacements'] as List)) {
    final r = _map(raw);
    final offset = r['offset'] as int;
    final oldLen = r['oldLen'] as int;
    reps.add(se.StringReplacement(
        or.OffsetRange(offset, offset + oldLen), r['newText'] as String));
  }
  return se.StringEdit(reps);
}

void main() {
  final truth = _truth();

  group('EditSources factories (metadata + observable methods)', () {
    final es = _map(truth['editSources']);
    test('replays ${es.length} factory cases', () {
      for (final entry in es.entries) {
        final name = entry.key;
        final c = _map(entry.value);
        final source = _build(name, _map(c['input']));
        expect(_same(source.metadata, c['meta']), isTrue,
            reason: '$name metadata');
        expect(source.toString(), c['toString'], reason: '$name toString');
        expect(source.getType(), c['getType'], reason: '$name getType');
        expect(tme.isAiEdit(source), c['isAiEdit'], reason: '$name isAiEdit');
        expect(tme.isUserEdit(source), c['isUserEdit'], reason: '$name isUserEdit');
        expect(_same(source.props, c['props']), isTrue, reason: '$name props');
      }
    });
  });

  group('TextModelEditSource.toKey', () {
    test('level filter + explicit filter override', () {
      for (final raw in (truth['toKey'] as List)) {
        final c = _map(raw);
        final source = _build(c['factory'] as String, _map(c['input']));
        final filter = (c['filter'] as Map).cast<String, bool>();
        expect(source.toKey(c['level'] as int, filter), c['result'],
            reason: '${c['label']}');
      }
    });
  });

  group('EditDeltaInfo', () {
    final info = _map(truth['editDeltaInfo']);

    test('fromText', () {
      for (final raw in (info['fromText'] as List)) {
        final c = _map(raw);
        final d = tme.EditDeltaInfo.fromText(c['text'] as String);
        expect(_same(_projDelta(d), c['result']), isTrue,
            reason: 'fromText ${c['text']}');
      }
    });

    test('fromEdit', () {
      for (final raw in (info['fromEdit'] as List)) {
        final c = _map(raw);
        final input = _map(c['input']);
        final edit = _editFromInput(input);
        final original = st.StringText(input['original'] as String);
        final d = tme.EditDeltaInfo.fromEdit(edit, original);
        expect(_same(_projDelta(d), c['result']), isTrue,
            reason: 'fromEdit ${input['original']}');
      }
    });

    test('tryCreate', () {
      for (final raw in (info['tryCreate'] as List)) {
        final c = _map(raw);
        final args = (c['input'] as List).cast<Object?>();
        final d = tme.EditDeltaInfo.tryCreate(
          args[0] as int?,
          args[1] as int?,
          args[2] as int?,
          args[3] as int?,
        );
        expect(_same(_projDeltaOrNull(d), c['result']), isTrue,
            reason: 'tryCreate ${c['input']}');
      }
    });
  });

  group('EditSuggestionId.newId', () {
    test('injected generator receives "sgt" namespace', () {
      final id = tme.EditSuggestionId.newId((ns) => '$ns-fixed-id');
      expect(id.toString(), _map(truth['editSuggestionId'])['injected']);
    });
  });
}
