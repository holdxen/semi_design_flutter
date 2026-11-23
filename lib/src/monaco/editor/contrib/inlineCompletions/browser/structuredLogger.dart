// ---------------------------------------------------------------------------
// Port of vscode/src/vs/editor/contrib/inlineCompletions/browser/structuredLogger.ts
// Translated 1:1 from TypeScript.
//   - `@IContextKeyService` / `@IDataChannelService` DI decorators -> explicit
//     service-type constructor params.
//   - JS object-literal log entries are carried as Map<String, Object?>;
//     `JSON.stringify` -> `jsonEncode` with the source's sourceId drop and
//     modelUri toString (Dart jsonEncode keeps null, so sourceId is omitted
//     explicitly to match JS `undefined` removal).
// ---------------------------------------------------------------------------

import 'dart:convert' show jsonEncode;

import '../../../../base/common/lifecycle.dart' show Disposable, DisposableStore;
import '../../../../base/common/observable.dart'
    show IObservable, observableFromEvent;
import '../../../../base/common/uri.dart' show URI;
import '../../../../platform/contextkey/common/contextkey.dart'
    show IContextKeyServiceType;
import '../../../../platform/dataChannel/common/dataChannel.dart'
    show IDataChannelServiceType;

/// 1:1: `export interface IRecordableLogEntry`
abstract class IRecordableLogEntry {
  String get sourceId;
  num get time;
}

/// 1:1: `export interface IRecordableEditorLogEntry extends IRecordableLogEntry`
abstract class IRecordableEditorLogEntry implements IRecordableLogEntry {
  URI get modelUri;
  int get modelVersion;
}

/// 1:1: `export function formatRecordableLogEntry<T extends IRecordableLogEntry>(entry: T): string`
/// [entry] is a Map carrier mirroring the JS object literal.
String formatRecordableLogEntry(Map<String, Object?> entry) {
  // TS: `entry.sourceId + ' @@ ' + JSON.stringify({ ...entry, modelUri: (entry as any).modelUri?.toString(), sourceId: undefined })`
  final Map<String, Object?> payload = <String, Object?>{};
  for (final MapEntry<String, Object?> kv in entry.entries) {
    if (kv.key == 'sourceId') {
      continue; // `sourceId: undefined` -> omitted by JSON.stringify
    }
    payload[kv.key] = kv.value;
  }
  final Object? modelUri = entry['modelUri'];
  if (modelUri != null) {
    // The source overrides modelUri with its `.toString()`. A URI carrier has
    // toString(); other carriers are stringified as-is.
    payload['modelUri'] = modelUri.toString();
  }
  return '${entry['sourceId']} @@ ${jsonEncode(payload)}';
}

/// 1:1: `export class StructuredLogger<T extends IRecordableLogEntry> extends Disposable`
class StructuredLogger<T> extends Disposable {
  final String _key;
  final IContextKeyServiceType _contextKeyService;
  final IDataChannelServiceType _dataChannelService;

  /// 1:1: `public readonly isEnabled`
  late final IObservable<bool> isEnabled;
  late final IObservable<bool?> _isEnabledContextKeyValue;

  /// 1:1: `public static cast<T>(): typeof StructuredLogger<T>`
  /// TS returns the class itself (`return this`) purely for type inference;
  /// Dart has no `typeof class` value, so this factory mirrors construction.
  static StructuredLogger<T> cast<T>() =>
      throw UnimplementedError('StructuredLogger.cast is a type-only helper');

  StructuredLogger(
    this._key,
    this._contextKeyService,
    this._dataChannelService,
  ) : super() {
    final DisposableStore store = DisposableStore();
    register(store);
    _isEnabledContextKeyValue = observableContextKey<bool>(
            'structuredLogger.enabled:$_key', _contextKeyService)
        .recomputeInitiallyAndOnChange(store) as IObservable<bool?>;
    isEnabled = _isEnabledContextKeyValue.map((v, reader) => v != null);
  }

  /// 1:1: `public log(data: T): boolean`
  bool log(T data) {
    final bool? enabled = _isEnabledContextKeyValue.get();
    // TS `if (!enabled) return false` — false, undefined (null) both fail.
    if (enabled != true) {
      return false;
    }
    _dataChannelService
        .getDataChannel<T>('structuredLogger:$_key')
        .sendData(data);
    return true;
  }
}

/// 1:1: `function observableContextKey<T>(key, contextKeyService): IObservable<T | undefined>`
IObservable<T?> observableContextKey<T>(
    String key, IContextKeyServiceType contextKeyService) {
  return observableFromEvent<T?, Object?>(
    contextKeyService.onDidChangeContext,
    (_) => contextKeyService.getContextKeyValue<T>(key),
  );
}
