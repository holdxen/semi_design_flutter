// ---------------------------------------------------------------------------
// Port of vscode/src/vs/platform/dataChannel/common/dataChannel.ts
// Translated 1:1 from TypeScript.
//   - value/type namespace clashes (`IDataChannelService`, `ILinkPresentationService`)
//     resolved by keeping the const name, renaming the interface to `...Type`.
//   - TS `type X = 'a' | 'b' | ...` string unions -> class of static consts.
//   - JS plain-object carriers (ILinkPresentation / status / changes) -> Dart Map.
//   - `Event.None` -> `eventNone`; `unknown` -> Object?.
// ---------------------------------------------------------------------------

import '../../../base/common/event.dart' show Event, eventNone;
import '../../../base/common/lifecycle.dart' show IDisposable;
import '../../../base/common/observable.dart' show IObservable;
import '../../../base/common/uri.dart' show URI;
import '../../instantiation/common/instantiation.dart'
    show ServiceIdentifier, createDecorator;

/// 1:1: `export const IDataChannelService = createDecorator<IDataChannelService>('dataChannelService')`
final ServiceIdentifier<IDataChannelServiceType> IDataChannelService =
    createDecorator<IDataChannelServiceType>('dataChannelService');

/// 1:1: `export interface IDataChannelService`
abstract class IDataChannelServiceType {
  // ignore: unused_element
  Object? get _serviceBrand;

  Event<IDataChannelEvent> get onDidSendData;

  /// 1:1: `getDataChannel<T>(channelId: string): CoreDataChannel<T>`
  CoreDataChannel<T> getDataChannel<T>(String channelId);
}

/// 1:1: `export interface CoreDataChannel<T = unknown>`
abstract class CoreDataChannel<T> {
  void sendData(T data);
}

/// 1:1: `export interface IDataChannelEvent<T = unknown>`
class IDataChannelEvent<T> {
  final String channelId;
  final T data;
  IDataChannelEvent(this.channelId, this.data);
}

/// 1:1: `export const ILinkPresentationService = createDecorator<ILinkPresentationService>('linkPresentationService')`
final ServiceIdentifier<ILinkPresentationServiceType> ILinkPresentationService =
    createDecorator<ILinkPresentationServiceType>('linkPresentationService');

/// 1:1: `export type LinkPresentationKind = ...`
class LinkPresentationKind {
  static const String resource = 'resource';
  static const String issue = 'issue';
  static const String pullRequest = 'pullRequest';
  static const String commit = 'commit';
  static const String file = 'file';
  static const String folder = 'folder';
  static const String session = 'session';
  static const String chat = 'chat';
  static const String repository = 'repository';
  static const String branch = 'branch';
  const LinkPresentationKind._();
}

/// 1:1: `export type LinkPresentationStatusKind = ...`
class LinkPresentationStatusKind {
  static const String neutral = 'neutral';
  static const String pending = 'pending';
  static const String success = 'success';
  static const String warning = 'warning';
  static const String error = 'error';
  static const String open = 'open';
  static const String closed = 'closed';
  static const String merged = 'merged';
  static const String draft = 'draft';
  static const String notPlanned = 'notPlanned';
  const LinkPresentationStatusKind._();
}

/// 1:1: `export interface ILinkPresentationStatus` (carried as a Map with
/// keys `kind`, `label`).

/// 1:1: `export interface ILinkPresentation` (carried as a Map with the
/// optional fields present only when the source would spread them in).

/// 1:1: `export function parseLinkPresentation(value: unknown): ILinkPresentation`
/// Returns a `Map<String, Object?>` carrier mirroring the JS object literal.
Map<String, Object?> parseLinkPresentation(Object? value) {
  // TS: `if (!isRecord(value) || !isLinkPresentationKind(value.kind))`.
  if (!_isRecord(value)) {
    throw StateError('Invalid link presentation payload');
  }
  final Map record = value as Map;
  if (!_isLinkPresentationKind(record['kind'])) {
    throw StateError('Invalid link presentation payload');
  }
  // JS `undefined` (absent key) vs `null` must be distinguished: a present
  // key with a JS `null` value flows into the parser and throws. Dart `null`
  // carries both, so gate on `containsKey` to reproduce the `undefined` case.
  final status = record.containsKey('status')
      ? _parseLinkPresentationStatus(record['status'])
      : null;
  final secondaryStatus = record.containsKey('secondaryStatus')
      ? _parseLinkPresentationStatus(record['secondaryStatus'])
      : null;
  final changes = record.containsKey('changes')
      ? _parseLinkPresentationChanges(record['changes'])
      : null;
  final result = <String, Object?>{'kind': record['kind']};
  if (record['title'] is String) result['title'] = record['title'];
  if (record['detail'] is String) result['detail'] = record['detail'];
  if (record['reference'] is String) result['reference'] = record['reference'];
  if (status != null) result['status'] = status;
  if (secondaryStatus != null) result['secondaryStatus'] = secondaryStatus;
  if (changes != null) result['changes'] = changes;
  if (record['tooltip'] is String) result['tooltip'] = record['tooltip'];
  if (record['ariaLabel'] is String) result['ariaLabel'] = record['ariaLabel'];
  if (record['isLoading'] == true) result['isLoading'] = true;
  return result;
}

/// 1:1: `function parseLinkPresentationStatus(value: unknown): ILinkPresentationStatus | undefined`
Map<String, Object?>? _parseLinkPresentationStatus(Object? value) {
  // Called only when the source key is present (JS `!== undefined`). A JS
  // `null` reaches here (Dart null) and fails the isRecord check, matching TS.
  if (!_isRecord(value)) {
    throw StateError('Invalid link presentation status');
  }
  final Map record = value as Map;
  if (!_isLinkPresentationStatusKind(record['kind']) ||
      record['label'] is! String) {
    throw StateError('Invalid link presentation status');
  }
  return <String, Object?>{'kind': record['kind'], 'label': record['label']};
}

/// 1:1: `function parseLinkPresentationChanges(value: unknown): ILinkPresentation['changes']`
Map<String, Object?>? _parseLinkPresentationChanges(Object? value) {
  // Called only when the source key is present (JS `!== undefined`).
  if (!_isRecord(value)) {
    throw StateError('Invalid link presentation changes');
  }
  final Map record = value as Map;
  if (record['insertions'] is! num || record['deletions'] is! num) {
    throw StateError('Invalid link presentation changes');
  }
  return <String, Object?>{
    'insertions': record['insertions'],
    'deletions': record['deletions'],
  };
}

/// 1:1: `function isLinkPresentationKind(value: unknown): value is LinkPresentationKind`
bool _isLinkPresentationKind(Object? value) {
  return value == LinkPresentationKind.resource ||
      value == LinkPresentationKind.issue ||
      value == LinkPresentationKind.pullRequest ||
      value == LinkPresentationKind.commit ||
      value == LinkPresentationKind.file ||
      value == LinkPresentationKind.folder ||
      value == LinkPresentationKind.session ||
      value == LinkPresentationKind.chat ||
      value == LinkPresentationKind.repository ||
      value == LinkPresentationKind.branch;
}

/// 1:1: `function isLinkPresentationStatusKind(value: unknown): value is LinkPresentationStatusKind`
bool _isLinkPresentationStatusKind(Object? value) {
  return value == LinkPresentationStatusKind.neutral ||
      value == LinkPresentationStatusKind.pending ||
      value == LinkPresentationStatusKind.success ||
      value == LinkPresentationStatusKind.warning ||
      value == LinkPresentationStatusKind.error ||
      value == LinkPresentationStatusKind.open ||
      value == LinkPresentationStatusKind.closed ||
      value == LinkPresentationStatusKind.merged ||
      value == LinkPresentationStatusKind.draft ||
      value == LinkPresentationStatusKind.notPlanned;
}

/// 1:1: `function isRecord(value: unknown): value is Record<string, unknown>`
/// JS record check: `typeof value === 'object' && value !== null` — a JS
/// object (plain or array) is modelled by a Dart Map carrier.
bool _isRecord(Object? value) => value is Map;

/// 1:1: `export interface ILinkPresentationWatcher extends IDisposable`
abstract class ILinkPresentationWatcher implements IDisposable {
  IObservable<ILinkPresentation?> get presentation;
}

/// 1:1: `export interface ILinkPresentationProvider`
abstract class ILinkPresentationProvider {
  ILinkPresentationWatcher createLinkPresentationWatcher(URI resource);
}

/// 1:1: `export interface ILinkPresentationProviderRegistration`
class ILinkPresentationProviderRegistration {
  final String id;
  final RegExp uriPattern;
  final String kind;
  final String? enablement;
  ILinkPresentationProviderRegistration(
      this.id, this.uriPattern, this.kind, [this.enablement]);
}

/// 1:1: `export interface ILinkPresentationRule`
class ILinkPresentationRule {
  final String id;
  final RegExp uriPattern;
  final String kind;
  ILinkPresentationRule(this.id, this.uriPattern, this.kind);
}

/// 1:1: `export interface ILinkPresentationService`
abstract class ILinkPresentationServiceType {
  // ignore: unused_element
  Object? get _serviceBrand;

  Event<void> get onDidChangeLinkPresentationRules;

  List<ILinkPresentationRule> get linkPresentationRules;

  IDisposable registerLinkPresentationProvider(
      ILinkPresentationProviderRegistration registration,
      ILinkPresentationProvider provider);

  IDisposable registerExtensionLinkPresentationProvider(
      String extensionId, String providerId, ILinkPresentationProvider provider);

  ILinkPresentationRule? getLinkPresentationRule(URI resource);

  ILinkPresentationWatcher? createLinkPresentationWatcher(
      String providerId, URI resource);
}

/// A Dart carrier type for the JS `ILinkPresentation` object literal.
typedef ILinkPresentation = Map<String, Object?>;

/// A Dart carrier type for the JS `ILinkPresentationStatus` object literal.
typedef ILinkPresentationStatus = Map<String, Object?>;

/// 1:1: `export class NullDataChannelService implements IDataChannelService`
class NullDataChannelService implements IDataChannelServiceType {
  @override
  // ignore: unused_element
  Object? get _serviceBrand => null;

  @override
  Event<IDataChannelEvent<Object?>> get onDidSendData => eventNone;

  @override
  CoreDataChannel<T> getDataChannel<T>(String _channelId) =>
      _NullCoreDataChannel<T>();
}

/// Helper used only by [NullDataChannelService.getDataChannel].
class _NullCoreDataChannel<T> implements CoreDataChannel<T> {
  @override
  void sendData(T data) {}
}
