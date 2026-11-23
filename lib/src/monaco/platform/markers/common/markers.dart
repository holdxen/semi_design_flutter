// ---------------------------------------------------------------------------
// Port of vscode/src/vs/platform/markers/common/markers.ts
// Translated 1:1. `const enum` -> class of static const ints; non-const enum
// merged with namespace -> one class with static const ints + static methods;
// `MarkerSeverity.toString` -> `toStringStatic` (Dart static/instance clash);
// const/interface name clash -> const keeps `IMarkerService`, interface gets
// `Type`; union `string | {value,target}` -> Object? carrier.
// Runtime truth: tool/ts2dart/_markers_truth.cjs (recursive TS transpile+vm,
// real severity.ts / strings.ts / instantiation.ts / uri.ts / event.ts).
// ---------------------------------------------------------------------------

import '../../../base/common/event.dart' show Event;
import '../../../base/common/lifecycle.dart' show IDisposable;
import '../../../base/common/severity.dart' show Severity;
import '../../../base/common/uri.dart' show URI;
import '../../../nls.dart' show localize;
import '../../instantiation/common/instantiation.dart'
    show ServiceIdentifier, createDecorator;

/// 1:1: `export interface IMarkerReadOptions`
abstract class IMarkerReadOptions {
  String? get owner;
  URI? get resource;
  int? get severities;
  int? get take;
  bool? get ignoreResourceFilters;
}

/// 1:1: `export interface IMarkerChangeOptions`
abstract class IMarkerChangeOptions {
  bool? get isTruncated;
}

/// 1:1: `export interface IMarkerService` (const keeps the bare name)
abstract class IMarkerServiceType {
  // ignore: unused_element
  Object? get _serviceBrand;

  /// 1:1: `getStatistics(): MarkerStatistics` — returns the live MarkerStats object.
  MarkerStatistics getStatistics();

  bool isSourceTruncated(URI resource);

  void changeOne(String owner, URI resource, List<IMarkerData> markers,
      [IMarkerChangeOptions? options]);

  void changeAll(String owner, List<IResourceMarker> data);

  void remove(String owner, List<URI> resources);

  List<IMarker> read([IMarkerReadOptions? filter]);

  IDisposable installResourceFilter(URI resource, String reason);

  Event<List<URI>> get onMarkerChanged;
}

/// 1:1: `export interface IRelatedInformation`
abstract class IRelatedInformation {
  URI get resource;
  String get message;
  int get startLineNumber;
  int get startColumn;
  int get endLineNumber;
  int get endColumn;
}

/// 1:1: `export const enum MarkerTag`
class MarkerTag {
  static const int Unnecessary = 1;
  static const int Deprecated = 2;
}

/// 1:1: `export enum MarkerSeverity` merged with `namespace MarkerSeverity`.
class MarkerSeverity {
  static const int Hint = 1;
  static const int Info = 2;
  static const int Warning = 4;
  static const int Error = 8;

  /// 1:1: `export function compare(a, b) { return b - a; }`
  static int compare(int a, int b) => b - a;

  static final Map<int, String> _displayStrings = <int, String>{
    MarkerSeverity.Error: localize('sev.error', 'Error'),
    MarkerSeverity.Warning: localize('sev.warning', 'Warning'),
    MarkerSeverity.Info: localize('sev.info', 'Info'),
  };

  /// 1:1: `export function toString(a) { return _displayStrings[a] || ''; }`
  static String toStringStatic(int a) => _displayStrings[a] ?? '';

  static final Map<int, String> _displayStringsPlural = <int, String>{
    MarkerSeverity.Error: localize('sev.errors', 'Errors'),
    MarkerSeverity.Warning: localize('sev.warnings', 'Warnings'),
    MarkerSeverity.Info: localize('sev.infos', 'Infos'),
  };

  /// 1:1: `export function toStringPlural(a) { return _displayStringsPlural[a] || ''; }`
  static String toStringPlural(int a) => _displayStringsPlural[a] ?? '';

  /// 1:1: `export function fromSeverity(severity: Severity)`
  static int? fromSeverity(int severity) {
    switch (severity) {
      case Severity.Error:
        return MarkerSeverity.Error;
      case Severity.Warning:
        return MarkerSeverity.Warning;
      case Severity.Info:
        return MarkerSeverity.Info;
      case Severity.Ignore:
        return MarkerSeverity.Hint;
    }
    return null; // JS: implicit undefined for unmatched values.
  }

  /// 1:1: `export function toSeverity(severity: MarkerSeverity)`
  static int? toSeverity(int severity) {
    switch (severity) {
      case MarkerSeverity.Error:
        return Severity.Error;
      case MarkerSeverity.Warning:
        return Severity.Warning;
      case MarkerSeverity.Info:
        return Severity.Info;
      case MarkerSeverity.Hint:
        return Severity.Ignore;
    }
    return null; // JS: implicit undefined for unmatched values.
  }
}

/// 1:1: `export interface IMarkerData` merged with `namespace IMarkerData`.
abstract class IMarkerData {
  Object? get code; // string | { value: string; target: URI }
  int get severity;
  String get message;
  String? get source;
  int get startLineNumber;
  int get startColumn;
  int get endLineNumber;
  int get endColumn;
  int? get modelVersionId;
  List<IRelatedInformation>? get relatedInformation;
  List<int>? get tags;
  String? get origin;

  static const String _emptyString = '';

  /// 1:1: `namespace IMarkerData { export function makeKey(markerData) }`
  static String makeKey(Map<String, Object?> markerData) =>
      makeKeyOptionalMessage(markerData, true);

  /// 1:1: `namespace IMarkerData { export function makeKeyOptionalMessage(markerData, useMessage) }`
  static String makeKeyOptionalMessage(
      Map<String, Object?> markerData, bool useMessage) {
    final result = <String>[_emptyString];
    final source = markerData['source'];
    if (_jsTruthy(source)) {
      result.add(_replaceFirstPipe(source as String));
    } else {
      result.add(_emptyString);
    }
    final code = markerData['code'];
    if (_jsTruthy(code)) {
      if (code is String) {
        result.add(_replaceFirstPipe(code));
      } else {
        result.add(
            _replaceFirstPipe((code as Map<String, Object?>)['value'] as String));
      }
    } else {
      result.add(_emptyString);
    }
    final severity = markerData['severity'];
    if (severity != null) {
      result.add(MarkerSeverity.toStringStatic(severity as int));
    } else {
      result.add(_emptyString);
    }

    // Modified to not include the message as part of the marker key to work
    // around https://github.com/microsoft/vscode/issues/77475
    final message = markerData['message'];
    if (_jsTruthy(message) && useMessage) {
      result.add(_replaceFirstPipe(message as String));
    } else {
      result.add(_emptyString);
    }
    final startLineNumber = markerData['startLineNumber'];
    if (startLineNumber != null) {
      result.add(_jsNum(startLineNumber));
    } else {
      result.add(_emptyString);
    }
    final startColumn = markerData['startColumn'];
    if (startColumn != null) {
      result.add(_jsNum(startColumn));
    } else {
      result.add(_emptyString);
    }
    final endLineNumber = markerData['endLineNumber'];
    if (endLineNumber != null) {
      result.add(_jsNum(endLineNumber));
    } else {
      result.add(_emptyString);
    }
    final endColumn = markerData['endColumn'];
    if (endColumn != null) {
      result.add(_jsNum(endColumn));
    } else {
      result.add(_emptyString);
    }
    result.add(_emptyString);
    return result.join('¦');
  }
}

/// 1:1: `export interface IResourceMarker`
abstract class IResourceMarker {
  URI get resource;
  IMarkerData get marker;
}

/// 1:1: `export interface IMarker`
abstract class IMarker {
  String get owner;
  URI get resource;
  int get severity;
  Object? get code; // string | { value: string; target: URI }
  String get message;
  String? get source;
  int get startLineNumber;
  int get startColumn;
  int get endLineNumber;
  int get endColumn;
  int? get modelVersionId;
  List<IRelatedInformation>? get relatedInformation;
  List<int>? get tags;
  String? get origin;
}

/// 1:1: `export interface MarkerStatistics`
abstract class MarkerStatistics {
  int get errors;
  int get warnings;
  int get infos;
  int get unknowns;
}

/// 1:1: JS `String.replace('¦', '\\¦')` — replaces only the FIRST occurrence.
String _replaceFirstPipe(String s) => s.replaceFirst('¦', '\\¦');

/// 1:1: JS truthiness (source uses bare `if (markerData.source)` etc.).
bool _jsTruthy(Object? v) {
  if (v == null) return false;
  if (v is bool) return v;
  if (v is num) return v != 0 && !v.isNaN;
  if (v is String) return v.isNotEmpty;
  return true;
}

/// 1:1: JS `${number}` stringification (integral doubles print without `.0`).
String _jsNum(Object? v) {
  if (v is int) return v.toString();
  if (v is double) {
    if (v == v.toInt()) return v.toInt().toString();
    return v.toString();
  }
  return v.toString();
}

/// 1:1: `export const IMarkerService = createDecorator<IMarkerService>('markerService')`
final ServiceIdentifier<IMarkerServiceType> IMarkerService =
    createDecorator<IMarkerServiceType>('markerService');
