// 1:1 port of vs/editor/common/services/markerDecorations.ts
// Declaration-only module: 1 decorator + 2 interfaces.
// Adaptations (consistent with textResourceConfiguration.dart / layoutService.dart):
//   - `const IMarkerDecorationsService` keeps the bare name; the erased
//     interface becomes `IMarkerDecorationsServiceType`.
//   - `ITextModel` / `IModelDecoration` come from `../model.ts` (pending), so
//     opaque file-local carrier contracts are used instead of a wrong stub.
//   - `[Range, IMarker][]` -> Dart records `List<(Range, IMarker)>`.
// Runtime truth: tool/ts2dart/_batch260_truth.cjs (recursive TS transpile+vm).

import '../../../base/common/event.dart' show Event;
import '../../../base/common/lifecycle.dart' show IDisposable;
import '../../../base/common/uri.dart' show URI;
import '../../../platform/instantiation/common/instantiation.dart'
    show ServiceIdentifier, createDecorator;
import '../../../platform/markers/common/markers.dart' show IMarker;
import '../core/range.dart' show Range;

/// 1:1: `export const IMarkerDecorationsService = createDecorator<...>('markerDecorationsService')`
final ServiceIdentifier<IMarkerDecorationsServiceType>
    IMarkerDecorationsService =
    createDecorator<IMarkerDecorationsServiceType>('markerDecorationsService');

/// 1:1: `ITextModel` (from `../model.ts`, pending) — opaque carrier.
abstract class ITextModelForMarkerDecorations {}

/// 1:1: `IModelDecoration` (from `../model.ts`, pending) — opaque carrier.
abstract class IModelDecorationForMarkerDecorations {}

/// 1:1: `export interface IMarkerLimit`
abstract class IMarkerLimit {
  /// Are the marker sources (ie. diagnostics) for a model truncated?
  bool get isMarkersSourceTruncated;

  /// Are the marker decorations for a model truncated?
  num? get isMarkersTruncated;
}

/// 1:1: `export interface IMarkerDecorationsService` (phantom/type carrier)
abstract class IMarkerDecorationsServiceType {
  // ignore: unused_element
  Object? get _serviceBrand;

  Event<ITextModelForMarkerDecorations> get onDidChangeMarker;

  /// Fires when diagnostics truncation state changes or when the marker limit
  /// exceeded state changes.
  Event<ITextModelForMarkerDecorations> get onDidChangeMarkerLimit;

  IMarker? getMarker(
      URI uri, IModelDecorationForMarkerDecorations decoration);

  List<(Range, IMarker)> getLiveMarkers(URI uri);

  /// Returns the marker limit state for a model.
  IMarkerLimit? getMarkerLimits(URI uri);

  IDisposable addMarkerSuppression(URI uri, Range range);
}
