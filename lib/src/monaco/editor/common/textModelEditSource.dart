// 1:1 port of vscode/src/vs/editor/common/textModelEditSource.ts (305 lines).
//
// Runtime surface ported:
//   - `TextModelEditSource` class (toString / getType / toKey / props)
//   - `isAiEdit` / `isUserEdit` free functions
//   - `EditSources` object (ported as a class with static members) - 16
//     factory methods incl. avoidPathRedaction / toProperties /
//     normalizeModelRouterTelemetryId dependencies
//   - `EditDeltaInfo` class (fromText / fromEdit / tryCreate)
//   - `EditSuggestionId` namespace (newId) + toEditIdentity.
//
// Adaptations (documented inline):
//  * erased `ITextModelEditSourceMetadata` / `ITextModelEditSourceMetadataKeys`
//    are carried as `Map<String, dynamic>`; metadata keys with JS `undefined`
//    values are kept with a `null` value (JS `Object.entries` sees them, and
//    truth projections map undefined -> null), while conditional spreads
//    (`...(x !== undefined ? {...} : {})`) omit the key entirely when null;
//  * the `privateSymbol` ctor guard is represented by a private sentinel token;
//  * `EditSuggestionId` interface (opaque string brand) + namespace are ported
//    as a single class carrying the id, with `newId` as a static member;
//  * `sumBy` / `prefixedUuid` / `normalizeModelRouterTelemetryId` /
//    `TextLength.ofText` / `LineEdit.fromStringEdit` are imported from their
//    already-ported counterparts.
import '../../base/common/arrays.dart' show sumBy;
import '../../base/common/uuid.dart' show prefixedUuid;
import '../../platform/telemetry/common/telemetry.dart'
    show normalizeModelRouterTelemetryId;
import './core/edits/lineEdit.dart' show LineEdit;
import './core/edits/stringEdit.dart' show BaseStringEdit;
import './core/text/abstractText.dart' show AbstractText;
import './core/text/textLength.dart' show TextLength;
import './languages.dart' show ProviderId, VersionedExtensionId;

/// Private sentinel matching the TS `const privateSymbol = Symbol(...)` ctor
/// guard: only [EditSources] factories can mint a [TextModelEditSource].
class _PrivateCtorGuard {
  const _PrivateCtorGuard._();
}

const Object _privateSymbol = _PrivateCtorGuard._();

/// 1:1: `export class TextModelEditSource`.
class TextModelEditSource {
  TextModelEditSource(this.metadata, Object privateCtorGuard)
      : assert(privateCtorGuard == _privateSymbol);

  /// 1:1: `public readonly metadata: ITextModelEditSourceMetadata`.
  final Map<String, dynamic> metadata;

  /// 1:1: `public toString(): string`.
  @override
  String toString() => '${metadata['source']}';

  /// 1:1: `public getType(): string`.
  String getType() {
    final source = metadata['source'];
    switch (source) {
      case 'cursor':
        return '${metadata['kind']}';
      case 'inlineCompletionAccept':
        return '$source${_jsTruthy(metadata['\$nes']) ? ':nes' : ''}';
      case 'unknown':
        final name = metadata['name'];
        return _jsTruthy(name) ? '$name' : 'unknown';
      default:
        return '$source';
    }
  }

  /// 1:1: `public toKey(level, filter = {})`.
  ///
  /// Only includes keys whose value is non-null/non-empty and whose `$` prefix
  /// count is <= [level], unless [filter] explicitly overrides a key.
  String toKey(int level, [Map<String, bool> filter = const {}]) {
    final keys = <String>[];
    metadata.forEach((key, value) {
      final filterVal = filter[key];
      if (filterVal != null) {
        if (filterVal) keys.add('$key:$value');
        return;
      }
      final prefixCount = key.codeUnits.where((c) => c == 0x24).length;
      if (prefixCount <= level && value != null && value != '') {
        keys.add('$key:$value');
      }
    });
    return keys.join('-');
  }

  /// 1:1: `public get props(): Record<..., string | undefined>`.
  Map<String, dynamic> get props => metadata;
}

bool _jsTruthy(Object? v) {
  if (v == null) return false;
  if (v is bool) return v;
  if (v is num) return v != 0;
  if (v is String) return v.isNotEmpty;
  return true;
}

/// 1:1: `function createEditSource<T>(metadata: T)`.
TextModelEditSource _createEditSource(Map<String, dynamic> metadata) =>
    TextModelEditSource(metadata, _privateSymbol);

/// 1:1: `export function isAiEdit(source: TextModelEditSource): boolean`.
bool isAiEdit(TextModelEditSource source) {
  switch (source.metadata['source']) {
    case 'inlineCompletionAccept':
    case 'inlineCompletionPartialAccept':
    case 'inlineChat.applyEdits':
    case 'Chat.applyEdits':
      return true;
  }
  return false;
}

/// 1:1: `export function isUserEdit(source: TextModelEditSource): boolean`.
bool isUserEdit(TextModelEditSource source) {
  switch (source.metadata['source']) {
    case 'cursor':
      return source.metadata['kind'] == 'type';
  }
  return false;
}

/// 1:1: `function toProperties(version: ProviderId | undefined)`.
Map<String, dynamic> _toProperties(ProviderId? version) {
  if (version == null) return {};
  return {
    '\$extensionId': version.extensionId,
    '\$extensionVersion': version.extensionVersion,
    '\$providerId': version.providerId,
  };
}

/// 1:1: `function avoidPathRedaction(str: string | undefined)`.
String? _avoidPathRedaction(String? str) {
  if (str == null) return null;
  return str.replaceAll('/', '|');
}

/// 1:1: `export const EditSources = {...}` (object -> class with static members).
class EditSources {
  EditSources._();

  /// 1:1: `unknown(data)`.
  static TextModelEditSource unknown({String? name}) =>
      _createEditSource({'source': 'unknown', 'name': name});

  /// 1:1: `rename(oldName, newName)`.
  static TextModelEditSource rename(String? oldName, String newName) =>
      _createEditSource({
        'source': 'rename',
        '\$\$\$oldName': oldName,
        '\$\$\$newName': newName,
      });

  /// 1:1: `chatApplyEdits(data)`.
  static TextModelEditSource chatApplyEdits({
    String? modelId,
    String? autoTier,
    String? fusionModel,
    String? sessionId,
    String? requestId,
    required String languageId,
    String? mode,
    VersionedExtensionId? extensionId,
    Object? codeBlockSuggestionId,
    String? origin,
    String? harness,
    String? agentSessionId,
    String? chatSessionId,
  }) {
    final meta = <String, dynamic>{
      'source': 'Chat.applyEdits',
      '\$modelId': _avoidPathRedaction(
          normalizeModelRouterTelemetryId(modelId) as String?),
      '\$autoTier': autoTier,
      '\$fusionModel': fusionModel,
      '\$extensionId': extensionId?.extensionId,
      '\$extensionVersion': extensionId?.version,
      '\$harness': harness,
      '\$origin': origin,
      '\$\$languageId': languageId,
      '\$\$sessionId': sessionId,
      // ...(data.agentSessionId !== undefined ? {...} : {})
      if (agentSessionId != null) '\$\$agentSessionId': agentSessionId,
      if (chatSessionId != null) '\$\$chatSessionId': chatSessionId,
      '\$\$requestId': requestId,
      '\$\$mode': mode,
      '\$\$codeBlockSuggestionId': codeBlockSuggestionId,
    };
    return _createEditSource(meta);
  }

  /// 1:1: `agentHostChatApplyEdits(data)`.
  static TextModelEditSource agentHostChatApplyEdits({
    String? modelId,
    String? autoTier,
    String? fusionModel,
    required String sessionId,
    String? agentSessionId,
    String? chatSessionId,
    required String requestId,
    required String harness,
  }) =>
      chatApplyEdits(
        modelId: modelId,
        autoTier: autoTier,
        fusionModel: fusionModel,
        sessionId: sessionId,
        agentSessionId: agentSessionId,
        chatSessionId: chatSessionId,
        requestId: requestId,
        languageId: '',
        mode: null,
        extensionId: null,
        codeBlockSuggestionId: null,
        origin: 'agentHost',
        harness: harness,
      );

  /// 1:1: `chatUndoEdits()`.
  static TextModelEditSource chatUndoEdits() =>
      _createEditSource({'source': 'Chat.undoEdits'});

  /// 1:1: `chatReset()`.
  static TextModelEditSource chatReset() =>
      _createEditSource({'source': 'Chat.reset'});

  /// 1:1: `inlineCompletionAccept(data)`.
  static TextModelEditSource inlineCompletionAccept({
    required bool nes,
    required String requestUuid,
    required String languageId,
    ProviderId? providerId,
    String? correlationId,
  }) =>
      _createEditSource(<String, dynamic>{
        'source': 'inlineCompletionAccept',
        '\$nes': nes,
        ..._toProperties(providerId),
        '\$\$correlationId': correlationId,
        '\$\$requestUuid': requestUuid,
        '\$\$languageId': languageId,
      });

  /// 1:1: `inlineCompletionPartialAccept(data)`.
  static TextModelEditSource inlineCompletionPartialAccept({
    required bool nes,
    required String requestUuid,
    required String languageId,
    ProviderId? providerId,
    String? correlationId,
    required String type,
  }) =>
      _createEditSource(<String, dynamic>{
        'source': 'inlineCompletionPartialAccept',
        'type': type,
        '\$nes': nes,
        ..._toProperties(providerId),
        '\$\$correlationId': correlationId,
        '\$\$requestUuid': requestUuid,
        '\$\$languageId': languageId,
      });

  /// 1:1: `inlineChatApplyEdit(data)`.
  static TextModelEditSource inlineChatApplyEdit({
    String? modelId,
    String? autoTier,
    String? requestId,
    String? sessionId,
    required String languageId,
    VersionedExtensionId? extensionId,
  }) =>
      _createEditSource({
        'source': 'inlineChat.applyEdits',
        '\$modelId': _avoidPathRedaction(
            normalizeModelRouterTelemetryId(modelId) as String?),
        '\$autoTier': autoTier,
        '\$extensionId': extensionId?.extensionId,
        '\$extensionVersion': extensionId?.version,
        '\$\$sessionId': sessionId,
        '\$\$requestId': requestId,
        '\$\$languageId': languageId,
      });

  /// 1:1: `reloadFromDisk()`.
  static TextModelEditSource reloadFromDisk() =>
      _createEditSource({'source': 'reloadFromDisk'});

  /// 1:1: `cursor(data)`.
  static TextModelEditSource cursor({
    required String kind,
    String? detailedSource,
  }) =>
      _createEditSource({
        'source': 'cursor',
        'kind': kind,
        'detailedSource': detailedSource,
      });

  /// 1:1: `setValue()`.
  static TextModelEditSource setValue() =>
      _createEditSource({'source': 'setValue'});

  /// 1:1: `eolChange()`.
  static TextModelEditSource eolChange() =>
      _createEditSource({'source': 'eolChange'});

  /// 1:1: `applyEdits()`.
  static TextModelEditSource applyEdits() =>
      _createEditSource({'source': 'applyEdits'});

  /// 1:1: `snippet()`.
  static TextModelEditSource snippet() =>
      _createEditSource({'source': 'snippet'});

  /// 1:1: `suggest(data)`.
  static TextModelEditSource suggest({ProviderId? providerId}) =>
      _createEditSource(<String, dynamic>{
        'source': 'suggest',
        ..._toProperties(providerId),
      });

  /// 1:1: `codeAction(data)`.
  static TextModelEditSource codeAction({
    String? kind,
    ProviderId? providerId,
  }) =>
      _createEditSource(<String, dynamic>{
        'source': 'codeAction',
        '\$kind': kind,
        ..._toProperties(providerId),
      });
}

/// 1:1: `export class EditDeltaInfo`.
class EditDeltaInfo {
  /// 1:1: `constructor(linesAdded, linesRemoved, charsAdded, charsRemoved)`.
  EditDeltaInfo(
    this.linesAdded,
    this.linesRemoved,
    this.charsAdded,
    this.charsRemoved,
  );

  final int linesAdded;
  final int linesRemoved;
  final int charsAdded;
  final int charsRemoved;

  /// 1:1: `public static fromText(text: string): EditDeltaInfo`.
  static EditDeltaInfo fromText(String text) {
    final linesAdded = TextLength.ofText(text).lineCount;
    final charsAdded = text.length;
    return EditDeltaInfo(linesAdded, 0, charsAdded, 0);
  }

  /// 1:1: `public static fromEdit(edit, originalString): EditDeltaInfo`.
  static EditDeltaInfo fromEdit(
    BaseStringEdit edit,
    AbstractText originalString,
  ) {
    final lineEdit = LineEdit.fromStringEdit(edit, originalString);
    final linesAdded = sumBy(
        lineEdit.replacements, (r) => r.newLines.length).toInt();
    final linesRemoved = sumBy(
        lineEdit.replacements, (r) => r.lineRange.length).toInt();
    final charsAdded =
        sumBy(edit.replacements, (r) => r.getNewLength()).toInt();
    final charsRemoved =
        sumBy(edit.replacements, (r) => r.replaceRange.length).toInt();
    return EditDeltaInfo(linesAdded, linesRemoved, charsAdded, charsRemoved);
  }

  /// 1:1: `public static tryCreate(...): EditDeltaInfo | undefined`.
  static EditDeltaInfo? tryCreate(
    int? linesAdded,
    int? linesRemoved,
    int? charsAdded,
    int? charsRemoved,
  ) {
    if (linesAdded == null ||
        linesRemoved == null ||
        charsAdded == null ||
        charsRemoved == null) {
      return null;
    }
    return EditDeltaInfo(linesAdded, linesRemoved, charsAdded, charsRemoved);
  }
}

/// 1:1: opaque `export interface EditSuggestionId` + `export namespace
/// EditSuggestionId` (ported as one class; the brand is the [id] string).
class EditSuggestionId {
  const EditSuggestionId._(this.id);

  final String id;

  /// 1:1: `EditSuggestionId.newId(genPrefixedUuid?)`.
  static EditSuggestionId newId([String Function(String ns)? genPrefixedUuid]) {
    final String id = genPrefixedUuid != null
        ? genPrefixedUuid('sgt')
        : prefixedUuid('sgt');
    return _toEditIdentity(id);
  }

  @override
  String toString() => id;
}

/// 1:1: `function toEditIdentity(id: string): EditSuggestionId`.
EditSuggestionId _toEditIdentity(String id) => EditSuggestionId._(id);
