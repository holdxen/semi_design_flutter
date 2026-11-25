// 1:1 port of vscode/src/vs/editor/common/textModelEvents.ts (638 lines).
//
// The source is a mix of erased interfaces/types and a rich runtime surface:
//   - `RawContentChangedType` const enum (static const int class, repo convention),
//   - two font-token serializer factory functions,
//   - `LineInjectedText` (applyInjectedText / fromDecorations /
//     getFixedWidthInjectedTextRanges / withText + constructor),
//   - 5 raw change classes carrying `changeType` (+ `ModelRawLinesInserted` getters),
//   - 2 non-raw change carriers (`ModelLineHeightChanged`, `ModelFontChanged`),
//   - `ModelRawContentChangedEvent` (containsEvent + static merge),
//   - `ModelInjectedTextChangedEvent` / `ModelLineHeightChangedEvent` (affects) /
//     `ModelFontChangedEvent`,
//   - `InternalModelContentChangeEvent` (merge + private _mergeChangeEvents).
//
// Adaptations (documented inline):
//  * erased interfaces used as field/param types are carried as structural
//    `Map<String, dynamic>` (`InjectedTextOptions`, `IFontTokenOption`,
//    `IModelDecoration`, `IModelContentChangedEvent`) and read via helpers;
//  * `ModelRawChange` union ported as an abstract carrier with `changeType`;
//  * JS `String.prototype.substring` clamps/swap indices - `_jsSubstring`;
//  * JS truthy + `String()` / `Number()` coercions in deserialize - helpers;
//  * `key: undefined` in an object literal is omitted from the returned Map
//    (JS reads a missing property as `undefined`, Dart reads a missing key as
//    `null` - semantically equivalent).
import './core/position.dart' show IPosition;
import './core/range.dart' show IRange, Range;
import './core/selection.dart' show Selection;

/// 1:1: `export const enum RawContentChangedType`.
class RawContentChangedType {
  static const int Flush = 1;
  static const int LineChanged = 2;
  static const int LinesDeleted = 3;
  static const int LinesInserted = 4;
  static const int EOLChanged = 5;

  const RawContentChangedType._();
}

// --- JS coercion helpers (only for deserializeFontTokenOptions) -------------

bool _jsTruthy(Object? v) {
  if (v == null) return false;
  if (v is bool) return v;
  if (v is num) return v != 0;
  if (v is String) return v.isNotEmpty;
  return true;
}

String _jsString(Object? v) {
  if (v is String) return v;
  if (v is num) return v.toString();
  if (v is bool) return v ? 'true' : 'false';
  if (v == null) return 'null';
  return v.toString();
}

num _jsNumber(Object? v) {
  if (v is num) return v;
  if (v is String) return num.tryParse(v) ?? 0;
  if (v is bool) return v ? 1 : 0;
  return 0;
}

/// JS `String.prototype.substring`: clamps to `[0, len]`, swaps if [start] > [end].
String _jsSubstring(String s, int start, [int? end]) {
  final len = s.length;
  var a = start < 0 ? 0 : (start > len ? len : start);
  var b = end == null ? len : (end < 0 ? 0 : (end > len ? len : end));
  if (a > b) {
    final t = a;
    a = b;
    b = t;
  }
  return s.substring(a, b);
}

Map<String, dynamic> _struct(Object? o) {
  if (o is Map) return o.cast<String, dynamic>();
  if (o is IRange) {
    return <String, dynamic>{
      'startLineNumber': o.startLineNumber,
      'startColumn': o.startColumn,
      'endLineNumber': o.endLineNumber,
      'endColumn': o.endColumn,
    };
  }
  if (o is IPosition) {
    return <String, dynamic>{'lineNumber': o.lineNumber, 'column': o.column};
  }
  return <String, dynamic>{};
}

/// 1:1: `export function serializeFontTokenOptions()`.
/// [annotation] is an erased `IFontTokenOption`, carried as a structural Map.
typedef FontTokenOptionMapper
    = Map<String, dynamic> Function(Map<String, dynamic> annotation);

FontTokenOptionMapper serializeFontTokenOptions() {
  return (annotation) => <String, dynamic>{
        'fontFamily': annotation['fontFamily'] ?? '',
        'fontSizeMultiplier': annotation['fontSizeMultiplier'] ?? 0,
        'lineHeightMultiplier': annotation['lineHeightMultiplier'] ?? 0,
      };
}

/// 1:1: `export function deserializeFontTokenOptions()`.
/// Uses JS truthiness and `String()` / `Number()` coercions; falsy fields are
/// omitted from the Map (equivalent to JS `key: undefined`).
FontTokenOptionMapper deserializeFontTokenOptions() {
  return (annotation) {
    final result = <String, dynamic>{};
    final ff = annotation['fontFamily'];
    if (_jsTruthy(ff)) result['fontFamily'] = _jsString(ff);
    final fsm = annotation['fontSizeMultiplier'];
    if (_jsTruthy(fsm)) result['fontSizeMultiplier'] = _jsNumber(fsm);
    final lhm = annotation['lineHeightMultiplier'];
    if (_jsTruthy(lhm)) result['lineHeightMultiplier'] = _jsNumber(lhm);
    return result;
  };
}

/// 1:1: module-private `occupiesHorizontalSpace(options: InjectedTextOptions)`.
bool _occupiesHorizontalSpace(Map<String, dynamic> options) {
  final content = options['content'] as String? ?? '';
  final widthInEm = options['widthInEm'];
  return content.isNotEmpty ||
      (widthInEm != null && (widthInEm as num) > 0);
}

/// 1:1: `export class LineInjectedText`.
/// [options] is an erased `InjectedTextOptions`, carried as a structural Map.
class LineInjectedText {
  final int ownerId;
  final int lineNumber;
  final int column;
  final Map<String, dynamic> options;
  final int order;

  LineInjectedText(this.ownerId, this.lineNumber, this.column, this.options, this.order);

  /// 1:1: `static applyInjectedText(lineText, injectedTexts)`.
  static String applyInjectedText(String lineText, List<LineInjectedText>? injectedTexts) {
    if (injectedTexts == null || injectedTexts.isEmpty) {
      return lineText;
    }
    var result = '';
    var lastOriginalOffset = 0;
    for (final injectedText in injectedTexts) {
      result += _jsSubstring(lineText, lastOriginalOffset, injectedText.column - 1);
      lastOriginalOffset = injectedText.column - 1;
      result += injectedText.options['content'] as String? ?? '';
    }
    result += _jsSubstring(lineText, lastOriginalOffset);
    return result;
  }

  /// 1:1: `static fromDecorations(decorations: IModelDecoration[])`.
  static List<LineInjectedText> fromDecorations(List<Object?> decorations) {
    final result = <LineInjectedText>[];
    for (final d in decorations) {
      final decoration = _struct(d);
      final options = _struct(decoration['options']);
      final before = options['before'];
      if (before != null && _occupiesHorizontalSpace(_struct(before))) {
        final range = _struct(decoration['range']);
        result.add(LineInjectedText(
          decoration['ownerId'] as int,
          range['startLineNumber'] as int,
          range['startColumn'] as int,
          _struct(before),
          0,
        ));
      }
      final after = options['after'];
      if (after != null && _occupiesHorizontalSpace(_struct(after))) {
        final range = _struct(decoration['range']);
        result.add(LineInjectedText(
          decoration['ownerId'] as int,
          range['endLineNumber'] as int,
          range['endColumn'] as int,
          _struct(after),
          1,
        ));
      }
    }
    result.sort((a, b) {
      if (a.lineNumber == b.lineNumber) {
        if (a.column == b.column) {
          return a.order.compareTo(b.order);
        }
        return a.column.compareTo(b.column);
      }
      return a.lineNumber.compareTo(b.lineNumber);
    });
    return result;
  }

  /// 1:1: `static getFixedWidthInjectedTextRanges(injectedTexts)`.
  /// Returns erased `FixedWidthInjectedTextRange` objects as structural Maps.
  static List<Map<String, dynamic>> getFixedWidthInjectedTextRanges(
      List<LineInjectedText>? injectedTexts) {
    final result = <Map<String, dynamic>>[];
    var injectedTextLength = 0;
    for (final injectedText in injectedTexts ?? const <LineInjectedText>[]) {
      final length = (injectedText.options['content'] as String? ?? '').length;
      final startOffset = injectedText.column - 1 + injectedTextLength;
      final endOffset = startOffset + length;
      final widthInEm = injectedText.options['widthInEm'];
      if (widthInEm != null) {
        result.add(<String, dynamic>{
          'startOffset': startOffset,
          'endOffset': endOffset,
          'widthInEm': widthInEm,
        });
      }
      injectedTextLength += length;
    }
    return result;
  }

  /// 1:1: `withText(text)` - spread keeps the other option fields.
  LineInjectedText withText(String text) {
    return LineInjectedText(
      ownerId,
      lineNumber,
      column,
      <String, dynamic>{...options, 'content': text},
      order,
    );
  }
}

/// 1:1: erased union `ModelRawChange`, as a runtime carrier for `changeType`.
abstract class ModelRawChange {
  int get changeType;
}

/// 1:1: `export class ModelRawFlush`.
class ModelRawFlush implements ModelRawChange {
  @override
  final int changeType = RawContentChangedType.Flush;
}

/// 1:1: `export class ModelRawLineChanged`.
class ModelRawLineChanged implements ModelRawChange {
  @override
  final int changeType = RawContentChangedType.LineChanged;

  final int lineNumber;
  final int lineNumberPostEdit;

  ModelRawLineChanged(this.lineNumber, this.lineNumberPostEdit);
}

/// 1:1: `export class ModelLineHeightChanged` (not part of `ModelRawChange`).
class ModelLineHeightChanged {
  final int ownerId;
  final String decorationId;
  final int lineNumber;
  final num? lineHeightMultiplier;

  ModelLineHeightChanged(this.ownerId, this.decorationId, this.lineNumber, this.lineHeightMultiplier);
}

/// 1:1: `export class ModelFontChanged` (not part of `ModelRawChange`).
class ModelFontChanged {
  final int ownerId;
  final int lineNumber;

  ModelFontChanged(this.ownerId, this.lineNumber);
}

/// 1:1: `export class ModelRawLinesDeleted`.
class ModelRawLinesDeleted implements ModelRawChange {
  @override
  final int changeType = RawContentChangedType.LinesDeleted;

  final int fromLineNumber;
  final int toLineNumber;
  final int lastUntouchedLinePostEdit;

  ModelRawLinesDeleted(this.fromLineNumber, this.toLineNumber, this.lastUntouchedLinePostEdit);
}

/// 1:1: `export class ModelRawLinesInserted`.
class ModelRawLinesInserted implements ModelRawChange {
  @override
  final int changeType = RawContentChangedType.LinesInserted;

  final int fromLineNumber;
  final int fromLineNumberPostEdit;
  final int count;

  ModelRawLinesInserted(this.fromLineNumber, this.fromLineNumberPostEdit, this.count);

  int get toLineNumber => fromLineNumber + count - 1;

  int get toLineNumberPostEdit => fromLineNumberPostEdit + count - 1;
}

/// 1:1: `export class ModelRawEOLChanged`.
class ModelRawEOLChanged implements ModelRawChange {
  @override
  final int changeType = RawContentChangedType.EOLChanged;
}

/// 1:1: `export class ModelRawContentChangedEvent`.
class ModelRawContentChangedEvent {
  final List<ModelRawChange> changes;
  final int versionId;
  final bool isUndoing;
  final bool isRedoing;
  List<Selection>? resultingSelection;

  ModelRawContentChangedEvent(this.changes, this.versionId, this.isUndoing, this.isRedoing)
      : resultingSelection = null;

  /// 1:1: `containsEvent(type)`.
  bool containsEvent(int type) {
    for (var i = 0, len = changes.length; i < len; i++) {
      if (changes[i].changeType == type) {
        return true;
      }
    }
    return false;
  }

  /// 1:1: `static merge(a, b)`.
  static ModelRawContentChangedEvent merge(
      ModelRawContentChangedEvent a, ModelRawContentChangedEvent b) {
    final changes = <ModelRawChange>[...a.changes, ...b.changes];
    final versionId = b.versionId;
    final isUndoing = (a.isUndoing || b.isUndoing);
    final isRedoing = (a.isRedoing || b.isRedoing);
    return ModelRawContentChangedEvent(changes, versionId, isUndoing, isRedoing);
  }
}

/// 1:1: `export class ModelInjectedTextChangedEvent`.
class ModelInjectedTextChangedEvent {
  final List<ModelRawLineChanged> changes;

  ModelInjectedTextChangedEvent(this.changes);
}

/// 1:1: `export class ModelLineHeightChangedEvent`.
class ModelLineHeightChangedEvent {
  final List<ModelLineHeightChanged> changes;

  ModelLineHeightChangedEvent(this.changes);

  /// 1:1: `affects(rangeOrPosition: IRange | IPosition)`.
  bool affects(Object? rangeOrPosition) {
    if (Range.isIRange(rangeOrPosition)) {
      final range = _struct(rangeOrPosition);
      final start = (range['startLineNumber'] as num).toInt();
      final end = (range['endLineNumber'] as num).toInt();
      for (final change in changes) {
        if (change.lineNumber >= start && change.lineNumber <= end) {
          return true;
        }
      }
      return false;
    } else {
      final lineNumber = _struct(rangeOrPosition)['lineNumber'];
      for (final change in changes) {
        if (change.lineNumber == lineNumber) {
          return true;
        }
      }
      return false;
    }
  }
}

/// 1:1: `export class ModelFontChangedEvent`.
class ModelFontChangedEvent {
  final List<ModelFontChanged> changes;

  ModelFontChangedEvent(this.changes);
}

/// 1:1: `export class InternalModelContentChangeEvent`.
/// [contentChangedEvent] is an erased `IModelContentChangedEvent`, carried as a
/// structural Map.
class InternalModelContentChangeEvent {
  final ModelRawContentChangedEvent rawContentChangedEvent;
  final Map<String, dynamic> contentChangedEvent;

  InternalModelContentChangeEvent(this.rawContentChangedEvent, this.contentChangedEvent);

  /// 1:1: `merge(other)`.
  InternalModelContentChangeEvent merge(InternalModelContentChangeEvent other) {
    final rawContentChangedEvent = ModelRawContentChangedEvent.merge(
        this.rawContentChangedEvent, other.rawContentChangedEvent);
    final contentChangedEvent = _mergeChangeEvents(
        this.contentChangedEvent, other.contentChangedEvent);
    return InternalModelContentChangeEvent(rawContentChangedEvent, contentChangedEvent);
  }

  /// 1:1: private static `_mergeChangeEvents(a, b)`.
  static Map<String, dynamic> _mergeChangeEvents(
      Map<String, dynamic> a, Map<String, dynamic> b) {
    final changes = <dynamic>[
      ...(a['changes'] as List),
      ...(b['changes'] as List),
    ];
    final eol = b['eol'];
    final versionId = b['versionId'];
    final isUndoing = (a['isUndoing'] == true || b['isUndoing'] == true);
    final isRedoing = (a['isRedoing'] == true || b['isRedoing'] == true);
    final isFlush = (a['isFlush'] == true || b['isFlush'] == true);
    // both must be true to not confuse listeners who skip such edits
    final isEolChange = a['isEolChange'] == true && b['isEolChange'] == true;
    return <String, dynamic>{
      'changes': changes,
      'eol': eol,
      'isEolChange': isEolChange,
      'versionId': versionId,
      'isUndoing': isUndoing,
      'isRedoing': isRedoing,
      'isFlush': isFlush,
      'detailedReasons': <dynamic>[
        ...(a['detailedReasons'] as List),
        ...(b['detailedReasons'] as List),
      ],
      'detailedReasonsChangeLengths': <dynamic>[
        ...(a['detailedReasonsChangeLengths'] as List),
        ...(b['detailedReasonsChangeLengths'] as List),
      ],
    };
  }
}
