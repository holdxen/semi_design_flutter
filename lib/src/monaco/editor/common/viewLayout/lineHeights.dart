// ---------------------------------------------------------------------------
// Port of vscode/src/vs/editor/common/viewLayout/lineHeights.ts
// Translated 1:1 from TypeScript. `const enum PendingChangeKind` -> class with
// static const int; TS `Infinity` -> double.infinity (num); `ArrayMap<K,T>` ->
// Map<K,List<T>>; `splice`/`reduce`/`Set` mapped to Dart equivalents.
// ---------------------------------------------------------------------------

import '../../../base/common/arrays.dart' show binarySearch2;
import '../../../base/common/collections.dart' show intersection;
import '../config/editorConfiguration.dart';
import '../config/editorOptions.dart' show EditorOption;
import '../coordinatesConverter.dart';
import '../core/range.dart' show Range;

/// 1:1 shape of the erased `IModelDecoration` fields read by `fromDecorations`.
class IModelDecorationForLineHeight {
  final String id;
  final Range range;
  final IModelDecorationOptionsForLineHeight options;
  IModelDecorationForLineHeight(this.id, this.range, this.options);
}

/// 1:1 shape of the erased `IModelDecorationOptions.lineHeight` field.
class IModelDecorationOptionsForLineHeight {
  final num? lineHeight;
  IModelDecorationOptionsForLineHeight(this.lineHeight);
}

/// 1:1: `const enum PendingChangeKind`.
class PendingChangeKind {
  const PendingChangeKind._();
  static const int InsertOrChange = 0;
  static const int Remove = 1;
  static const int LinesDeleted = 2;
  static const int LinesInserted = 3;
}

/// 1:1: discriminated union `PendingChange`.
class PendingChange {
  final int kind;
  final String? decorationId;
  final int? startLineNumber;
  final int? endLineNumber;
  final num? lineHeight;
  final int? fromLineNumber;
  final int? toLineNumber;

  PendingChange._({
    required this.kind,
    this.decorationId,
    this.startLineNumber,
    this.endLineNumber,
    this.lineHeight,
    this.fromLineNumber,
    this.toLineNumber,
  });

  static PendingChange insertOrChange(String decorationId, int startLineNumber, int endLineNumber, num lineHeight) =>
      PendingChange._(
        kind: PendingChangeKind.InsertOrChange,
        decorationId: decorationId,
        startLineNumber: startLineNumber,
        endLineNumber: endLineNumber,
        lineHeight: lineHeight,
      );

  static PendingChange remove(String decorationId) =>
      PendingChange._(kind: PendingChangeKind.Remove, decorationId: decorationId);

  static PendingChange linesDeleted(int fromLineNumber, int toLineNumber) =>
      PendingChange._(
        kind: PendingChangeKind.LinesDeleted,
        fromLineNumber: fromLineNumber,
        toLineNumber: toLineNumber,
      );

  static PendingChange linesInserted(int fromLineNumber, int toLineNumber) =>
      PendingChange._(
        kind: PendingChangeKind.LinesInserted,
        fromLineNumber: fromLineNumber,
        toLineNumber: toLineNumber,
      );
}

/// 1:1: `export class CustomLine`.
class CustomLine {
  int index;
  int lineNumber;
  int specialHeight;
  int prefixSum;
  int maximumSpecialHeight;
  String decorationId;
  bool deleted;

  CustomLine(
    this.decorationId,
    this.index,
    this.lineNumber,
    num specialHeight,
    this.prefixSum,
  )   : specialHeight = specialHeight.round(),
        maximumSpecialHeight = specialHeight.round(),
        deleted = false;
}

/// 1:1: `class ArrayMap<K, T>` (Map key -> list of values).
class ArrayMap<K, T> {
  final Map<K, List<T>> _map = <K, List<T>>{};

  void add(K key, T value) {
    final array = _map[key];
    if (array == null) {
      _map[key] = <T>[value];
    } else {
      array.add(value);
    }
  }

  List<T>? get(K key) => _map[key];

  void delete(K key) => _map.remove(key);

  void clear() => _map.clear();
}

/// 1:1: `export class LineHeightsManager`.
class LineHeightsManager {
  ArrayMap<String, CustomLine> _decorationIDToCustomLine = ArrayMap<String, CustomLine>();
  final List<CustomLine> _orderedCustomLines = <CustomLine>[];
  List<PendingChange> _pendingChanges = <PendingChange>[];
  num _invalidIndex = double.infinity;
  num _defaultLineHeight;
  bool _hasPending = false;

  LineHeightsManager(num defaultLineHeight, List<CustomLineHeightData> customLineHeightData)
      : _defaultLineHeight = defaultLineHeight {
    for (final data in customLineHeightData) {
      insertOrChangeCustomLineHeight(
        data.decorationId,
        data.startLineNumber,
        data.endLineNumber,
        data.lineHeight,
      );
    }
  }

  set defaultLineHeight(num value) => _defaultLineHeight = value;

  num get defaultLineHeight => _defaultLineHeight;

  void removeCustomLineHeight(String decorationID) {
    _pendingChanges.add(PendingChange.remove(decorationID));
    _hasPending = true;
  }

  void insertOrChangeCustomLineHeight(
    String decorationId,
    int startLineNumber,
    int endLineNumber,
    num lineHeight,
  ) {
    _pendingChanges.add(
      PendingChange.insertOrChange(decorationId, startLineNumber, endLineNumber, lineHeight),
    );
    _hasPending = true;
  }

  int heightForLineNumber(int lineNumber) {
    _commit();
    final searchIndex = _binarySearchOverOrderedCustomLinesArray(lineNumber);
    if (searchIndex >= 0) {
      return _orderedCustomLines[searchIndex].maximumSpecialHeight;
    }
    return _defaultLineHeight.round();
  }

  int getAccumulatedLineHeightsIncludingLineNumber(int lineNumber) {
    _commit();
    final searchIndex = _binarySearchOverOrderedCustomLinesArray(lineNumber);
    if (searchIndex >= 0) {
      return _orderedCustomLines[searchIndex].prefixSum +
          _orderedCustomLines[searchIndex].maximumSpecialHeight;
    }
    if (searchIndex == -1) {
      return (_defaultLineHeight * lineNumber).round();
    }
    final modifiedIndex = -(searchIndex + 1);
    final previousSpecialLine = _orderedCustomLines[modifiedIndex - 1];
    return previousSpecialLine.prefixSum +
        previousSpecialLine.maximumSpecialHeight +
        (_defaultLineHeight * (lineNumber - previousSpecialLine.lineNumber)).round();
  }

  void onLinesDeleted(int fromLineNumber, int toLineNumber) {
    _pendingChanges.add(PendingChange.linesDeleted(fromLineNumber, toLineNumber));
    _hasPending = true;
  }

  void onLinesInserted(int fromLineNumber, int toLineNumber) {
    _pendingChanges.add(PendingChange.linesInserted(fromLineNumber, toLineNumber));
    _hasPending = true;
  }

  void _commit() {
    if (!_hasPending) {
      return;
    }
    final changes = _pendingChanges;
    _pendingChanges = <PendingChange>[];
    _hasPending = false;

    final stagedInserts = <CustomLine>[];
    final stagedIdMap = ArrayMap<String, CustomLine>();
    for (final change in changes) {
      switch (change.kind) {
        case PendingChangeKind.Remove:
          _doRemoveCustomLineHeight(change.decorationId!, stagedIdMap);
          break;
        case PendingChangeKind.InsertOrChange:
          _doInsertOrChangeCustomLineHeight(
            change.decorationId!,
            change.startLineNumber!,
            change.endLineNumber!,
            change.lineHeight!,
            stagedInserts,
            stagedIdMap,
          );
          break;
        case PendingChangeKind.LinesDeleted:
          _flushStagedDecorationChanges(stagedInserts, stagedIdMap);
          _doLinesDeleted(change.fromLineNumber!, change.toLineNumber!);
          break;
        case PendingChangeKind.LinesInserted:
          _flushStagedDecorationChanges(stagedInserts, stagedIdMap);
          _doLinesInserted(change.fromLineNumber!, change.toLineNumber!, stagedInserts, stagedIdMap);
          break;
      }
    }
    _flushStagedDecorationChanges(stagedInserts, stagedIdMap);
  }

  void _doRemoveCustomLineHeight(String decorationID, ArrayMap<String, CustomLine> stagedIdMap) {
    final customLines = _decorationIDToCustomLine.get(decorationID);
    if (customLines != null) {
      _decorationIDToCustomLine.delete(decorationID);
      for (final customLine in customLines) {
        customLine.deleted = true;
        _invalidIndex =
            _invalidIndex < customLine.index ? _invalidIndex : customLine.index;
      }
    }
    final stagedLines = stagedIdMap.get(decorationID);
    if (stagedLines != null) {
      stagedIdMap.delete(decorationID);
      for (final line in stagedLines) {
        line.deleted = true;
      }
    }
  }

  void _doInsertOrChangeCustomLineHeight(
    String decorationId,
    int startLineNumber,
    int endLineNumber,
    num lineHeight,
    List<CustomLine> stagedInserts,
    ArrayMap<String, CustomLine> stagedIdMap,
  ) {
    _doRemoveCustomLineHeight(decorationId, stagedIdMap);
    for (int lineNumber = startLineNumber; lineNumber <= endLineNumber; lineNumber++) {
      final customLine = CustomLine(decorationId, -1, lineNumber, lineHeight, 0);
      stagedInserts.add(customLine);
      stagedIdMap.add(decorationId, customLine);
    }
  }

  void _flushStagedDecorationChanges(
    List<CustomLine> stagedInserts,
    ArrayMap<String, CustomLine> stagedIdMap,
  ) {
    if (stagedInserts.isEmpty && _invalidIndex == double.infinity) {
      return;
    }
    for (final pendingChange in stagedInserts) {
      if (pendingChange.deleted) {
        continue;
      }
      final candidateInsertionIndex =
          _binarySearchOverOrderedCustomLinesArray(pendingChange.lineNumber);
      final insertionIndex =
          candidateInsertionIndex >= 0 ? candidateInsertionIndex : -(candidateInsertionIndex + 1);
      _orderedCustomLines.insert(insertionIndex, pendingChange);
      _invalidIndex =
          _invalidIndex < insertionIndex ? _invalidIndex : insertionIndex;
    }
    stagedInserts.clear();
    stagedIdMap.clear();
    if (_invalidIndex == double.infinity) {
      return;
    }
    final newDecorationIDToSpecialLine = ArrayMap<String, CustomLine>();
    final newOrderedSpecialLines = <CustomLine>[];

    final invalidIndexInt = _invalidIndex.toInt();
    for (int i = 0; i < invalidIndexInt; i++) {
      final customLine = _orderedCustomLines[i];
      newOrderedSpecialLines.add(customLine);
      newDecorationIDToSpecialLine.add(customLine.decorationId, customLine);
    }

    int numberOfDeletions = 0;
    CustomLine? previousSpecialLine =
        invalidIndexInt > 0 ? newOrderedSpecialLines[invalidIndexInt - 1] : null;
    for (int i = invalidIndexInt; i < _orderedCustomLines.length; i++) {
      final customLine = _orderedCustomLines[i];
      if (customLine.deleted) {
        numberOfDeletions++;
        continue;
      }
      customLine.index = i - numberOfDeletions;
      if (previousSpecialLine != null && previousSpecialLine.lineNumber == customLine.lineNumber) {
        customLine.maximumSpecialHeight = previousSpecialLine.maximumSpecialHeight;
        customLine.prefixSum = previousSpecialLine.prefixSum;
      } else {
        int maximumSpecialHeight = customLine.specialHeight;
        for (int j = i; j < _orderedCustomLines.length; j++) {
          final nextSpecialLine = _orderedCustomLines[j];
          if (nextSpecialLine.deleted) {
            continue;
          }
          if (nextSpecialLine.lineNumber != customLine.lineNumber) {
            break;
          }
          maximumSpecialHeight =
              maximumSpecialHeight > nextSpecialLine.specialHeight
                  ? maximumSpecialHeight
                  : nextSpecialLine.specialHeight;
        }
        customLine.maximumSpecialHeight = maximumSpecialHeight;

        late int prefixSum;
        if (previousSpecialLine != null) {
          prefixSum = previousSpecialLine.prefixSum +
              previousSpecialLine.maximumSpecialHeight +
              (_defaultLineHeight * (customLine.lineNumber - previousSpecialLine.lineNumber - 1)).round();
        } else {
          prefixSum = (_defaultLineHeight * (customLine.lineNumber - 1)).round();
        }
        customLine.prefixSum = prefixSum;
      }
      previousSpecialLine = customLine;
      newOrderedSpecialLines.add(customLine);
      newDecorationIDToSpecialLine.add(customLine.decorationId, customLine);
    }
    _orderedCustomLines
      ..clear()
      ..addAll(newOrderedSpecialLines);
    _decorationIDToCustomLine = newDecorationIDToSpecialLine;
    _invalidIndex = double.infinity;
  }

  void _doLinesDeleted(int fromLineNumber, int toLineNumber) {
    final deleteCount = toLineNumber - fromLineNumber + 1;
    final numberOfCustomLines = _orderedCustomLines.length;
    final candidateStartIndexOfDeletion =
        _binarySearchOverOrderedCustomLinesArray(fromLineNumber);
    late int startIndexOfDeletion;
    if (candidateStartIndexOfDeletion >= 0) {
      startIndexOfDeletion = candidateStartIndexOfDeletion;
      for (int i = candidateStartIndexOfDeletion - 1; i >= 0; i--) {
        if (_orderedCustomLines[i].lineNumber == fromLineNumber) {
          startIndexOfDeletion--;
        } else {
          break;
        }
      }
    } else {
      startIndexOfDeletion =
          candidateStartIndexOfDeletion == -(numberOfCustomLines + 1) &&
                  candidateStartIndexOfDeletion != -1
              ? numberOfCustomLines - 1
              : -(candidateStartIndexOfDeletion + 1);
    }
    final candidateEndIndexOfDeletion = _binarySearchOverOrderedCustomLinesArray(toLineNumber);
    late int endIndexOfDeletion;
    if (candidateEndIndexOfDeletion >= 0) {
      endIndexOfDeletion = candidateEndIndexOfDeletion;
      for (int i = candidateEndIndexOfDeletion + 1; i < numberOfCustomLines; i++) {
        if (_orderedCustomLines[i].lineNumber == toLineNumber) {
          endIndexOfDeletion++;
        } else {
          break;
        }
      }
    } else {
      endIndexOfDeletion =
          candidateEndIndexOfDeletion == -(numberOfCustomLines + 1) &&
                  candidateEndIndexOfDeletion != -1
              ? numberOfCustomLines - 1
              : -(candidateEndIndexOfDeletion + 1);
    }
    final isEndIndexBiggerThanStartIndex = endIndexOfDeletion > startIndexOfDeletion;
    final isEndIndexEqualToStartIndexAndCoversCustomLine = endIndexOfDeletion == startIndexOfDeletion &&
        startIndexOfDeletion < _orderedCustomLines.length &&
        _orderedCustomLines[startIndexOfDeletion].lineNumber >= fromLineNumber &&
        _orderedCustomLines[startIndexOfDeletion].lineNumber <= toLineNumber;

    if (isEndIndexBiggerThanStartIndex || isEndIndexEqualToStartIndexAndCoversCustomLine) {
      int maximumSpecialHeightOnDeletedInterval = 0;
      for (int i = startIndexOfDeletion; i <= endIndexOfDeletion; i++) {
        final v = _orderedCustomLines[i].maximumSpecialHeight;
        maximumSpecialHeightOnDeletedInterval =
            maximumSpecialHeightOnDeletedInterval > v ? maximumSpecialHeightOnDeletedInterval : v;
      }
      late int prefixSumOnDeletedInterval;
      if (startIndexOfDeletion > 0) {
        final previousSpecialLine = _orderedCustomLines[startIndexOfDeletion - 1];
        prefixSumOnDeletedInterval = previousSpecialLine.prefixSum +
            previousSpecialLine.maximumSpecialHeight +
            (_defaultLineHeight * (fromLineNumber - previousSpecialLine.lineNumber - 1)).round();
      } else {
        prefixSumOnDeletedInterval = fromLineNumber > 0 ? (fromLineNumber - 1) * _defaultLineHeight.round() : 0;
      }
      final firstSpecialLineDeleted = _orderedCustomLines[startIndexOfDeletion];
      final lastSpecialLineDeleted = _orderedCustomLines[endIndexOfDeletion];
      final firstSpecialLineAfterDeletion =
          endIndexOfDeletion + 1 < _orderedCustomLines.length
              ? _orderedCustomLines[endIndexOfDeletion + 1]
              : null;
      final heightOfFirstLineAfterDeletion =
          firstSpecialLineAfterDeletion != null &&
                  firstSpecialLineAfterDeletion.lineNumber == toLineNumber + 1
              ? firstSpecialLineAfterDeletion.maximumSpecialHeight
              : _defaultLineHeight.round();
      final totalHeightDeleted = lastSpecialLineDeleted.prefixSum +
          lastSpecialLineDeleted.maximumSpecialHeight -
          firstSpecialLineDeleted.prefixSum +
          (_defaultLineHeight * (toLineNumber - lastSpecialLineDeleted.lineNumber)).round() +
          (_defaultLineHeight * (firstSpecialLineDeleted.lineNumber - fromLineNumber)).round() +
          heightOfFirstLineAfterDeletion -
          maximumSpecialHeightOnDeletedInterval;

      final decorationIdsSeen = <String>{};
      final newOrderedCustomLines = <CustomLine>[];
      final newDecorationIDToSpecialLine = ArrayMap<String, CustomLine>();
      int numberOfDeletions = 0;
      for (int i = 0; i < _orderedCustomLines.length; i++) {
        final customLine = _orderedCustomLines[i];
        if (i < startIndexOfDeletion) {
          newOrderedCustomLines.add(customLine);
          newDecorationIDToSpecialLine.add(customLine.decorationId, customLine);
        } else if (i >= startIndexOfDeletion && i <= endIndexOfDeletion) {
          final decorationId = customLine.decorationId;
          if (!decorationIdsSeen.contains(decorationId)) {
            customLine.index -= numberOfDeletions;
            customLine.lineNumber = fromLineNumber;
            customLine.prefixSum = prefixSumOnDeletedInterval;
            customLine.maximumSpecialHeight = maximumSpecialHeightOnDeletedInterval;
            newOrderedCustomLines.add(customLine);
            newDecorationIDToSpecialLine.add(customLine.decorationId, customLine);
          } else {
            numberOfDeletions++;
          }
        } else if (i > endIndexOfDeletion) {
          customLine.index -= numberOfDeletions;
          customLine.lineNumber -= deleteCount;
          customLine.prefixSum -= totalHeightDeleted;
          newOrderedCustomLines.add(customLine);
          newDecorationIDToSpecialLine.add(customLine.decorationId, customLine);
        }
        decorationIdsSeen.add(customLine.decorationId);
      }
      _orderedCustomLines
        ..clear()
        ..addAll(newOrderedCustomLines);
      _decorationIDToCustomLine = newDecorationIDToSpecialLine;
    } else {
      final totalHeightDeleted = deleteCount * _defaultLineHeight.round();
      for (int i = endIndexOfDeletion; i < _orderedCustomLines.length; i++) {
        final customLine = _orderedCustomLines[i];
        if (customLine.lineNumber > toLineNumber) {
          customLine.lineNumber -= deleteCount;
          customLine.prefixSum -= totalHeightDeleted;
        }
      }
    }
  }

  void _doLinesInserted(
    int fromLineNumber,
    int toLineNumber,
    List<CustomLine> stagedInserts,
    ArrayMap<String, CustomLine> stagedIdMap,
  ) {
    final insertCount = toLineNumber - fromLineNumber + 1;
    final candidateStartIndexOfInsertion =
        _binarySearchOverOrderedCustomLinesArray(fromLineNumber);
    late int startIndexOfInsertion;
    if (candidateStartIndexOfInsertion >= 0) {
      startIndexOfInsertion = candidateStartIndexOfInsertion;
      for (int i = candidateStartIndexOfInsertion - 1; i >= 0; i--) {
        if (_orderedCustomLines[i].lineNumber == fromLineNumber) {
          startIndexOfInsertion--;
        } else {
          break;
        }
      }
    } else {
      startIndexOfInsertion = -(candidateStartIndexOfInsertion + 1);
    }
    final toReAdd = <CustomLineHeightData>[];
    final decorationsImmediatelyAfter = <String>{};
    for (int i = startIndexOfInsertion; i < _orderedCustomLines.length; i++) {
      if (_orderedCustomLines[i].lineNumber == fromLineNumber) {
        decorationsImmediatelyAfter.add(_orderedCustomLines[i].decorationId);
      }
    }
    final decorationsImmediatelyBefore = <String>{};
    for (int i = startIndexOfInsertion - 1; i >= 0; i--) {
      if (_orderedCustomLines[i].lineNumber == fromLineNumber - 1) {
        decorationsImmediatelyBefore.add(_orderedCustomLines[i].decorationId);
      }
    }
    final decorationsWithGaps = intersection(decorationsImmediatelyBefore, decorationsImmediatelyAfter);
    final prefixSumToAdd = insertCount * _defaultLineHeight.round();
    for (int i = startIndexOfInsertion; i < _orderedCustomLines.length; i++) {
      _orderedCustomLines[i].lineNumber += insertCount;
      _orderedCustomLines[i].prefixSum += prefixSumToAdd;
    }

    if (decorationsWithGaps.isNotEmpty) {
      for (final decorationId in decorationsWithGaps) {
        final decoration = _decorationIDToCustomLine.get(decorationId);
        if (decoration != null) {
          int startLineNumber = fromLineNumber;
          int endLineNumber = fromLineNumber;
          int lineHeight = 0;
          for (final l in decoration) {
            startLineNumber = startLineNumber < l.lineNumber ? startLineNumber : l.lineNumber;
            endLineNumber = endLineNumber > l.lineNumber ? endLineNumber : l.lineNumber;
            lineHeight = lineHeight > l.specialHeight ? lineHeight : l.specialHeight;
          }
          toReAdd.add(CustomLineHeightData(
            decorationId,
            startLineNumber,
            endLineNumber,
            lineHeight,
          ));
        }
      }

      for (final dec in toReAdd) {
        _doInsertOrChangeCustomLineHeight(
          dec.decorationId,
          dec.startLineNumber,
          dec.endLineNumber,
          dec.lineHeight,
          stagedInserts,
          stagedIdMap,
        );
      }
    }
  }

  int _binarySearchOverOrderedCustomLinesArray(int lineNumber) {
    return binarySearch2(_orderedCustomLines.length, (int index) {
      final line = _orderedCustomLines[index];
      if (line.lineNumber == lineNumber) {
        return 0;
      } else if (line.lineNumber < lineNumber) {
        return -1;
      } else {
        return 1;
      }
    });
  }
}

/// 1:1: `export class CustomLineHeightData`.
class CustomLineHeightData {
  final String decorationId;
  final int startLineNumber;
  final int endLineNumber;
  final num lineHeight;

  CustomLineHeightData(
    this.decorationId,
    this.startLineNumber,
    this.endLineNumber,
    this.lineHeight,
  );

  /// 1:1: `static fromDecorations(...)`.
  static List<CustomLineHeightData> fromDecorations(
    List<IModelDecorationForLineHeight> decorations,
    ICoordinatesConverter coordinatesConverter,
    IEditorConfiguration configuration,
  ) {
    final defaultLineHeight =
        configuration.options.get(EditorOption.lineHeight) as num;
    return decorations.map((d) {
      final viewRange = coordinatesConverter.convertModelRangeToViewRange(d.range);
      return CustomLineHeightData(
        d.id,
        viewRange.startLineNumber,
        viewRange.endLineNumber,
        d.options.lineHeight != null ? d.options.lineHeight! * defaultLineHeight : 0,
      );
    }).toList();
  }
}
