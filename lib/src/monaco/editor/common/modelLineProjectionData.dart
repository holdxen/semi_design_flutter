/// 1:1 translation of `vs/editor/common/modelLineProjectionData.ts`.
///
/// Erased TS interfaces are carried structurally:
///  * `InjectedTextOptions` -> `Map<String, dynamic>` with `content: String`
///    and optional `cursorStops: int` (same convention as `textModelEvents.dart`).
library;

import '../../base/common/assert.dart' show assertNever;
import 'config/editorOptions.dart' show WrappingIndent;
import 'config/fontInfo.dart' show FontInfo;
import 'core/position.dart' show Position;
import 'model.dart' show InjectedTextCursorStops, PositionAffinity;
import 'textModelEvents.dart' show LineInjectedText;

/// 1:1: `export class ModelLineProjectionData`.
class ModelLineProjectionData {
  final List<int>? injectionOffsets;
  /// `injectionOptions.length` must equal `injectionOffsets.length`.
  final List<Map<String, dynamic>>? injectionOptions;
  /// Refers to offsets after applying injections to the source.
  final List<int> breakOffsets;
  /// Refers to offsets after applying injections.
  final List<int> breakOffsetsVisibleColumn;
  final num wrappedTextIndentLength;

  ModelLineProjectionData(
    this.injectionOffsets,
    this.injectionOptions,
    this.breakOffsets,
    this.breakOffsetsVisibleColumn,
    this.wrappedTextIndentLength,
  );

  int getOutputLineCount() => breakOffsets.length;

  int getMinOutputOffset(int outputLineIndex) {
    if (outputLineIndex > 0) {
      return wrappedTextIndentLength.toInt();
    }
    return 0;
  }

  int getLineLength(int outputLineIndex) {
    // These offsets refer to model text with injected text.
    final startOffset = outputLineIndex > 0 ? breakOffsets[outputLineIndex - 1] : 0;
    final endOffset = breakOffsets[outputLineIndex];

    var lineLength = endOffset - startOffset;
    if (outputLineIndex > 0) {
      lineLength += wrappedTextIndentLength.toInt();
    }
    return lineLength;
  }

  int getMaxOutputOffset(int outputLineIndex) => getLineLength(outputLineIndex);

  int translateToInputOffset(int outputLineIndex, int outputOffset) {
    var offset = outputOffset;
    if (outputLineIndex > 0) {
      offset = offset < 0 ? 0 : (offset - wrappedTextIndentLength.toInt());
      if (offset < 0) offset = 0;
    }

    var offsetInInput = outputLineIndex == 0
        ? offset
        : breakOffsets[outputLineIndex - 1] + offset;

    final offsets = injectionOffsets;
    if (offsets != null) {
      final opts = injectionOptions!;
      for (var i = 0; i < offsets.length; i++) {
        if (offsetInInput > offsets[i]) {
          final contentLength = (opts[i]['content'] as String? ?? '').length;
          if (offsetInInput < offsets[i] + contentLength) {
            // `inputOffset` is within injected text
            offsetInInput = offsets[i];
          } else {
            offsetInInput -= contentLength;
          }
        } else {
          break;
        }
      }
    }

    return offsetInInput;
  }

  OutputPosition translateToOutputPosition(int inputOffset,
      [int affinity = PositionAffinity.None]) {
    var inputOffsetInInputWithInjection = inputOffset;
    final offsets = injectionOffsets;
    if (offsets != null) {
      final opts = injectionOptions!;
      for (var i = 0; i < offsets.length; i++) {
        if (inputOffset < offsets[i]) {
          break;
        }
        if (affinity != PositionAffinity.Right && inputOffset == offsets[i]) {
          break;
        }
        inputOffsetInInputWithInjection +=
            (opts[i]['content'] as String? ?? '').length;
      }
    }
    return _offsetInInputWithInjectionsToOutputPosition(
        inputOffsetInInputWithInjection, affinity);
  }

  OutputPosition _offsetInInputWithInjectionsToOutputPosition(
      int offsetInInputWithInjections, int affinity) {
    var low = 0;
    var high = breakOffsets.length - 1;
    var mid = 0;
    var midStart = 0;

    while (low <= high) {
      // JS: `mid = low + ((high - low) / 2) | 0;` — non-negative operands,
      // so `| 0` truncates toward zero == integer division.
      mid = low + ((high - low) ~/ 2);

      final midStop = breakOffsets[mid];
      midStart = mid > 0 ? breakOffsets[mid - 1] : 0;

      if (affinity == PositionAffinity.Left) {
        if (offsetInInputWithInjections <= midStart) {
          high = mid - 1;
        } else if (offsetInInputWithInjections > midStop) {
          low = mid + 1;
        } else {
          break;
        }
      } else {
        if (offsetInInputWithInjections < midStart) {
          high = mid - 1;
        } else if (offsetInInputWithInjections >= midStop) {
          low = mid + 1;
        } else {
          break;
        }
      }
    }

    var outputOffset = offsetInInputWithInjections - midStart;
    if (mid > 0) {
      outputOffset += wrappedTextIndentLength.toInt();
    }

    return OutputPosition(mid, outputOffset);
  }

  OutputPosition normalizeOutputPosition(
      int outputLineIndex, int outputOffset, int affinity) {
    if (injectionOffsets != null) {
      final offsetInInputWithInjections =
          _outputPositionToOffsetInInputWithInjections(outputLineIndex, outputOffset);
      final normalizedOffsetInUnwrappedLine =
          _normalizeOffsetInInputWithInjectionsAroundInjections(
              offsetInInputWithInjections, affinity);
      if (normalizedOffsetInUnwrappedLine != offsetInInputWithInjections) {
        // injected text caused a change
        return _offsetInInputWithInjectionsToOutputPosition(
            normalizedOffsetInUnwrappedLine, affinity);
      }
    }

    if (affinity == PositionAffinity.Left) {
      if (outputLineIndex > 0 &&
          outputOffset == getMinOutputOffset(outputLineIndex)) {
        return OutputPosition(
            outputLineIndex - 1, getMaxOutputOffset(outputLineIndex - 1));
      }
    } else if (affinity == PositionAffinity.Right) {
      final maxOutputLineIndex = getOutputLineCount() - 1;
      if (outputLineIndex < maxOutputLineIndex &&
          outputOffset == getMaxOutputOffset(outputLineIndex)) {
        return OutputPosition(
            outputLineIndex + 1, getMinOutputOffset(outputLineIndex + 1));
      }
    }

    return OutputPosition(outputLineIndex, outputOffset);
  }

  int _outputPositionToOffsetInInputWithInjections(
      int outputLineIndex, int outputOffset) {
    var offset = outputOffset;
    if (outputLineIndex > 0) {
      offset = offset < 0 ? 0 : (offset - wrappedTextIndentLength.toInt());
      if (offset < 0) offset = 0;
    }
    return (outputLineIndex > 0 ? breakOffsets[outputLineIndex - 1] : 0) +
        offset;
  }

  int _normalizeOffsetInInputWithInjectionsAroundInjections(
      int offsetInInputWithInjections, int affinity) {
    final injectedText = _getInjectedTextAtOffset(offsetInInputWithInjections);
    if (injectedText == null) {
      return offsetInInputWithInjections;
    }

    final offsets = injectionOffsets!;
    final opts = injectionOptions!;
    int? cs(int i) => opts[i]['cursorStops'] as int?;

    if (affinity == PositionAffinity.None) {
      final injectedIndex = injectedText.injectedTextIndex;
      final injectedOffset = injectedText.offsetInInputWithInjections;
      final injectedLength = injectedText.length;
      if (offsetInInputWithInjections == injectedOffset + injectedLength &&
          _hasRightCursorStop(cs(injectedIndex))) {
        return injectedOffset + injectedLength;
      } else {
        var result = injectedOffset;
        if (_hasLeftCursorStop(cs(injectedIndex))) {
          return result;
        }

        var index = injectedIndex - 1;
        while (index >= 0 && offsets[index] == offsets[injectedIndex]) {
          if (_hasRightCursorStop(cs(index))) {
            break;
          }
          result -= (opts[index]['content'] as String? ?? '').length;
          if (_hasLeftCursorStop(cs(index))) {
            break;
          }
          index--;
        }

        return result;
      }
    } else if (affinity == PositionAffinity.Right ||
        affinity == PositionAffinity.RightOfInjectedText) {
      var result = injectedText.offsetInInputWithInjections + injectedText.length;
      var index = injectedText.injectedTextIndex;
      // traverse all injected text that touch each other
      while (index + 1 < offsets.length && offsets[index + 1] == offsets[index]) {
        result += (opts[index + 1]['content'] as String? ?? '').length;
        index++;
      }
      return result;
    } else if (affinity == PositionAffinity.Left ||
        affinity == PositionAffinity.LeftOfInjectedText) {
      // affinity is left
      var result = injectedText.offsetInInputWithInjections;
      var index = injectedText.injectedTextIndex;
      // traverse all injected text that touch each other
      while (index - 1 >= 0 && offsets[index - 1] == offsets[index]) {
        result -= (opts[index - 1]['content'] as String? ?? '').length;
        index--;
      }
      return result;
    }

    assertNever(affinity);
  }

  InjectedText? getInjectedText(int outputLineIndex, int outputOffset) {
    final offset =
        _outputPositionToOffsetInInputWithInjections(outputLineIndex, outputOffset);
    final injectedText = _getInjectedTextAtOffset(offset);
    if (injectedText == null) {
      return null;
    }
    return InjectedText(injectionOptions![injectedText.injectedTextIndex]);
  }

  _InjectedTextAtOffset? _getInjectedTextAtOffset(
      int offsetInInputWithInjections) {
    final injectionOffsets = this.injectionOffsets;
    final injectionOptions = this.injectionOptions;

    if (injectionOffsets != null && injectionOptions != null) {
      var totalInjectedTextLengthBefore = 0;
      for (var i = 0; i < injectionOffsets.length; i++) {
        final length = (injectionOptions[i]['content'] as String? ?? '').length;
        final injectedTextStartOffsetInInputWithInjections =
            injectionOffsets[i] + totalInjectedTextLengthBefore;
        final injectedTextEndOffsetInInputWithInjections =
            injectionOffsets[i] + totalInjectedTextLengthBefore + length;

        if (injectedTextStartOffsetInInputWithInjections >
            offsetInInputWithInjections) {
          // Injected text starts later.
          break; // All later injected texts have an even larger offset.
        }

        if (offsetInInputWithInjections <=
            injectedTextEndOffsetInInputWithInjections) {
          // Injected text ends after or with the given position (but also
          // starts with or before it).
          return _InjectedTextAtOffset(
            injectedTextIndex: i,
            offsetInInputWithInjections:
                injectedTextStartOffsetInInputWithInjections,
            length: length,
          );
        }

        totalInjectedTextLengthBefore += length;
      }
    }

    return null;
  }
}

bool _hasRightCursorStop(int? cursorStop) {
  if (cursorStop == null) return true;
  return cursorStop == InjectedTextCursorStops.Right ||
      cursorStop == InjectedTextCursorStops.Both;
}

bool _hasLeftCursorStop(int? cursorStop) {
  if (cursorStop == null) return true;
  return cursorStop == InjectedTextCursorStops.Left ||
      cursorStop == InjectedTextCursorStops.Both;
}

/// 1:1: `export class InjectedText`.
class InjectedText {
  final Map<String, dynamic> options;
  InjectedText(this.options);
}

/// 1:1: `export class OutputPosition`.
class OutputPosition {
  int outputLineIndex;
  int outputOffset;

  OutputPosition(this.outputLineIndex, this.outputOffset);

  @override
  String toString() => '$outputLineIndex:$outputOffset';

  Position toPosition(int baseLineNumber) =>
      Position(baseLineNumber + outputLineIndex, outputOffset + 1);
}

class _InjectedTextAtOffset {
  final int injectedTextIndex;
  final int offsetInInputWithInjections;
  final int length;

  _InjectedTextAtOffset({
    required this.injectedTextIndex,
    required this.offsetInInputWithInjections,
    required this.length,
  });
}

/// 1:1: `export interface ILineBreaksComputerContext`.
abstract class ILineBreaksComputerContext {
  String getLineContent(int lineNumber);
  List<LineInjectedText>? getLineInjectedText(int lineNumber);
}

/// 1:1: `export interface ILineBreaksComputerFactory`.
abstract class ILineBreaksComputerFactory {
  ILineBreaksComputer createLineBreaksComputer(
    ILineBreaksComputerContext context,
    FontInfo fontInfo,
    int tabSize,
    int wrappingColumn,
    WrappingIndent wrappingIndent,
    String wordBreak,
    bool wrapOnEscapedLineFeeds,
    bool useTwoCellFullwidthCharacters,
  );
}

/// 1:1: `export interface ILineBreaksComputer`.
abstract class ILineBreaksComputer {
  /// Pass in `previousLineBreakData` if the only difference is in breaking columns!!!
  void addRequest(int lineNumber, ModelLineProjectionData? previousLineBreakData);
  List<ModelLineProjectionData?> finalize();
}
