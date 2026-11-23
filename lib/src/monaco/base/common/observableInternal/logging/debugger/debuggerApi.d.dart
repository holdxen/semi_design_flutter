// 1:1 translation of
// vscode/src/vs/base/common/observableInternal/logging/debugger/debuggerApi.d.ts
// This is a type-only declaration file. TS interfaces -> Dart value classes,
// string-literal unions -> class static consts, `Record<K,V>` -> Map<K,V>,
// structural `type` aliases -> classes mirroring every field. No runtime logic
// exists in the source, so none is added here.

/// 1:1: `export type ObsDebuggerApi = { channelId, host, client }`
class ObsDebuggerApi {
  static const String channelId = 'observableDevTools';
  final ObsDebuggerApiHost host;
  final ObsDebuggerApiClient client;
  ObsDebuggerApi(this.host, this.client);
}

/// host side
class ObsDebuggerApiHost {
  final ObsDebuggerApiHostNotifications notifications;
  final Map<String, Function> requests;
  ObsDebuggerApiHost(this.notifications, this.requests);
}

class ObsDebuggerApiHostNotifications {
  final void Function(ObsStateUpdate, bool) handleChange;
  ObsDebuggerApiHostNotifications(this.handleChange);
}

/// client side
class ObsDebuggerApiClient {
  final ObsDebuggerApiClientNotifications notifications;
  final ObsDebuggerApiClientRequests requests;
  ObsDebuggerApiClient(this.notifications, this.requests);
}

class ObsDebuggerApiClientNotifications {
  final void Function(List<ObsDeclarationId>) setDeclarationIdFilter;
  final void Function(ObsInstanceId) logObservableValue;
  final void Function() flushUpdates;
  final void Function() resetUpdates;
  ObsDebuggerApiClientNotifications(
    this.setDeclarationIdFilter,
    this.logObservableValue,
    this.flushUpdates,
    this.resetUpdates,
  );
}

class ObsDebuggerApiClientRequests {
  final IObsDeclarations Function() getDeclarations;
  final IObsPushState Function() getSummarizedInstances;
  final IDerivedObservableDetailedInfo Function(ObsInstanceId) getDerivedInfo;
  final IAutorunDetailedInfo Function(ObsInstanceId) getAutorunInfo;
  final IObservableValueInfo Function(ObsInstanceId) getObservableValueInfo;
  final void Function(ObsInstanceId, Object?) setValue;
  final Object? Function(ObsInstanceId) getValue;
  // For autorun and deriveds
  final void Function(ObsInstanceId) rerun;
  final void Function(ObsInstanceId) logValue;
  final ITransactionState? Function() getTransactionState;
  ObsDebuggerApiClientRequests(
    this.getDeclarations,
    this.getSummarizedInstances,
    this.getDerivedInfo,
    this.getAutorunInfo,
    this.getObservableValueInfo,
    this.setValue,
    this.getValue,
    this.rerun,
    this.logValue,
    this.getTransactionState,
  );
}

/// 1:1: `export type ObsDeclarationId = number`
typedef ObsDeclarationId = int;

/// 1:1: `export type ObsInstanceId = number`
typedef ObsInstanceId = int;

/// 1:1: `export type ObsOwnerId = number`
typedef ObsOwnerId = int;

/// 1:1: `export type ObsDeclarationType = 'observable/value' | ...`
class ObsDeclarationType {
  static const String observableValue = 'observable/value';
  static const String observableDerived = 'observable/derived';
  static const String autorun = 'autorun';
  static const String transaction = 'transaction';
}

/// 1:1: `export interface IObsDeclarations`
class IObsDeclarations {
  final Map<ObsDeclarationId, IObsDeclaration> decls;
  IObsDeclarations(this.decls);
}

/// 1:1: `export interface IObsDeclaration` (Immutable)
class IObsDeclaration {
  final ObsDeclarationId id;
  final String type;
  final String url;
  final int line;
  final int column;
  IObsDeclaration(this.id, this.type, this.url, this.line, this.column);
}

/// 1:1: `export interface IObsPushState`
class IObsPushState {
  final Map<ObsDeclarationId, IObsDeclarationSummary?> declStates;
  final Map<ObsInstanceId, ObsInstancePushState?> instances;
  IObsPushState(this.declStates, this.instances);
}

/// 1:1: `export interface IObsDeclarationSummary`
class IObsDeclarationSummary {
  final int activeInstances;
  final List<ObsInstanceId> recentInstances; // Limited
  IObsDeclarationSummary(this.activeInstances, this.recentInstances);
}

/// 1:1: `export type ObsInstancePushState = ...` (union)
abstract class ObsInstancePushState {}

/// 1:1: `interface IBaseObsInstancePushState`
class IBaseObsInstancePushState implements ObsInstancePushState {
  final ObsInstanceId instanceId;
  final ObsDeclarationId declarationId;
  final String name;
  final ObsOwnerId? ownerId;
  IBaseObsInstancePushState(this.instanceId, this.declarationId, this.name, this.ownerId);
}

/// 1:1: `export interface IObservableInstancePushState`
class IObservableInstancePushState extends IBaseObsInstancePushState {
  final String? formattedValue;
  IObservableInstancePushState(
    super.instanceId,
    super.declarationId,
    super.name,
    super.ownerId,
    this.formattedValue,
  );
}

/// 1:1: `export interface IObservableValueInstancePushState`
class IObservableValueInstancePushState extends IObservableInstancePushState {
  static const String type = ObsDeclarationType.observableValue;
  IObservableValueInstancePushState(
    super.instanceId,
    super.declarationId,
    super.name,
    super.ownerId,
    super.formattedValue,
  );
}

/// 1:1: `export interface IDerivedObservableInstancePushState`
class IDerivedObservableInstancePushState extends IObservableInstancePushState {
  static const String type = ObsDeclarationType.observableDerived;
  final int recomputationCount;
  IDerivedObservableInstancePushState(
    super.instanceId,
    super.declarationId,
    super.name,
    super.ownerId,
    super.formattedValue,
    this.recomputationCount,
  );
}

/// 1:1: `export interface IAutorunInstancePushState`
class IAutorunInstancePushState extends IBaseObsInstancePushState {
  static const String type = ObsDeclarationType.autorun;
  final int runCount;
  IAutorunInstancePushState(
    super.instanceId,
    super.declarationId,
    super.name,
    super.ownerId,
    this.runCount,
  );
}

/// 1:1: `export type ObsStateUpdate = Partial<IObsDeclarations> & DeepPartial<IObsPushState>`
/// DeepPartial/mapped types have no Dart equivalent; fields are nullable.
class ObsStateUpdate {
  final Map<ObsDeclarationId, IObsDeclaration?>? decls;
  final Map<ObsDeclarationId, IObsDeclarationSummary?>? declStates;
  final Map<ObsInstanceId, ObsInstancePushState?>? instances;
  ObsStateUpdate({this.decls, this.declStates, this.instances});
}

/// 1:1: `export interface IObservableValueInfo`
class IObservableValueInfo {
  final List<IObsInstanceRef> observers;
  IObservableValueInfo(this.observers);
}

/// 1:1: `export interface IDerivedObservableDetailedInfo`
class IDerivedObservableDetailedInfo {
  final List<IObsInstanceRef> dependencies;
  final List<IObsInstanceRef> observers;
  IDerivedObservableDetailedInfo(this.dependencies, this.observers);
}

/// 1:1: `export interface IAutorunDetailedInfo`
class IAutorunDetailedInfo {
  final List<IObsInstanceRef> dependencies;
  IAutorunDetailedInfo(this.dependencies);
}

/// 1:1: `export interface IObsInstanceRef`
class IObsInstanceRef {
  final ObsInstanceId instanceId;
  final String name;
  IObsInstanceRef(this.instanceId, this.name);
}

/// 1:1: `export interface ITransactionState`
class ITransactionState {
  final List<String> names;
  final List<ObserverInstanceState> affected;
  ITransactionState(this.names, this.affected);
}

/// 1:1: `export type ObserverInstanceState = DerivedObservableState | AutorunState`
abstract class ObserverInstanceState {}

/// 1:1: `DerivedObservableState = IObsInstanceRef & { type, updateCount } & (state union)`
class DerivedObservableState extends IObsInstanceRef implements ObserverInstanceState {
  static const String type = ObsDeclarationType.observableDerived;
  final int updateCount;
  final String state;
  final List<ObsInstanceId>? changedDependencies;
  final bool? initialComputation;
  DerivedObservableState(
    super.instanceId,
    super.name,
    this.updateCount,
    this.state, [
    this.changedDependencies,
    this.initialComputation,
  ]);
}

/// state literal constants for DerivedObservableState
class DerivedObservableStateKind {
  static const String noValue = 'noValue';
  static const String stale = 'stale';
  static const String possiblyStale = 'possiblyStale';
  static const String upToDate = 'upToDate';
  static const String updating = 'updating';
}

/// 1:1: `AutorunState = IObsInstanceRef & { type, updateCount } & (state union)`
class AutorunState extends IObsInstanceRef implements ObserverInstanceState {
  static const String type = ObsDeclarationType.autorun;
  final int updateCount;
  final String state;
  final List<ObsInstanceId>? changedDependencies;
  AutorunState(
    super.instanceId,
    super.name,
    this.updateCount,
    this.state, [
    this.changedDependencies,
  ]);
}

class AutorunStateKind {
  static const String stale = 'stale';
  static const String possiblyStale = 'possiblyStale';
  static const String upToDate = 'upToDate';
  static const String updating = 'updating';
}

/// 1:1: `ObservableValueState = IObsInstanceRef & { type } & (state union)`
class ObservableValueState extends IObsInstanceRef {
  static const String type = ObsDeclarationType.observableValue;
  final String state;
  ObservableValueState(super.instanceId, super.name, this.state);
}

class ObservableValueStateKind {
  static const String upToDate = 'upToDate';
  static const String updating = 'updating';
}
