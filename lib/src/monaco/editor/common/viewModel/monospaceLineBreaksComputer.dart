/// 1:1 translation of `vs/editor/common/viewModel/monospaceLineBreaksComputer.ts`.
///
/// Adaptations (documented inline):
///  * `const enum CharacterClass` -> class with static const int members.
///  * Erased `InjectedTextOptions` / `FixedWidthInjectedTextRange` -> structural
///    `Map<String, dynamic>` (same convention as `textModelEvents.dart`).
///  * `charCodeAt` -> `codeUnitAt` (both operate on UTF-16 code units).
///  * `low + ((high - low) / 2) | 0` -> integer division (`~/`, non-negative).
///  * The `arrPool1/2` object-reuse arrays are mutable global references.
library;

import '../../../base/common/charCode.dart' show CharCode;
import '../../../base/common/strings.dart' as strings;
import '../config/editorOptions.dart'
    show EditorOption, IComputedEditorOptions, WrappingIndent;
import '../config/fontInfo.dart' show FontInfo;
import '../core/characterClassifier.dart' show CharacterClassifier;
import '../modelLineProjectionData.dart'
    show
        ILineBreaksComputer,
        ILineBreaksComputerContext,
        ILineBreaksComputerFactory,
        ModelLineProjectionData;
import '../textModelEvents.dart' show LineInjectedText;

/// 1:1: `export class MonospaceLineBreaksComputerFactory`.
class MonospaceLineBreaksComputerFactory implements ILineBreaksComputerFactory {
  /// 1:1: `static create(options)`.
  static MonospaceLineBreaksComputerFactory create(
      IComputedEditorOptions options) {
    return MonospaceLineBreaksComputerFactory(
      options.get(EditorOption.wordWrapBreakBeforeCharacters) as String? ?? '',
      options.get(EditorOption.wordWrapBreakAfterCharacters) as String? ?? '',
    );
  }

  final WrappingCharacterClassifier _classifier;

  MonospaceLineBreaksComputerFactory(
      String breakBeforeChars, String breakAfterChars)
      : _classifier = WrappingCharacterClassifier(
            breakBeforeChars, breakAfterChars);

  @override
  ILineBreaksComputer createLineBreaksComputer(
    ILineBreaksComputerContext context,
    FontInfo fontInfo,
    int tabSize,
    int wrappingColumn,
    int wrappingIndent,
    String wordBreak,
    bool wrapOnEscapedLineFeeds,
    bool useTwoCellFullwidthCharacters,
  ) {
    final lineNumbers = <int>[];
    final previousBreakingData = <ModelLineProjectionData?>[];
    return _MonospaceLineBreaksComputer(
      onAdd: (lineNumber, previous) {
        lineNumbers.add(lineNumber);
        previousBreakingData.add(previous);
      },
      onFinalize: () {
        final columnsForFullWidthChar =
            fontInfo.typicalFullwidthCharacterWidth /
                fontInfo.typicalHalfwidthCharacterWidth;
        final result = <ModelLineProjectionData?>[];
        for (var i = 0, len = lineNumbers.length; i < len; i++) {
          final lineNumber = lineNumbers[i];
          final injectedText = context.getLineInjectedText(lineNumber);
          final lineText = context.getLineContent(lineNumber);
          final previousLineBreakData = previousBreakingData[i];
          final isLineFeedWrappingEnabled = wrapOnEscapedLineFeeds &&
              lineText.contains('"') &&
              lineText.contains('\\n');
          if (previousLineBreakData != null &&
              previousLineBreakData.injectionOptions == null &&
              injectedText == null &&
              !isLineFeedWrappingEnabled) {
            result.add(createLineBreaksFromPreviousLineBreaks(
                _classifier,
                previousLineBreakData,
                lineText,
                tabSize,
                wrappingColumn,
                columnsForFullWidthChar,
                wrappingIndent,
                wordBreak,
                useTwoCellFullwidthCharacters));
          } else {
            result.add(createLineBreaks(
                _classifier,
                lineText,
                injectedText,
                tabSize,
                wrappingColumn,
                columnsForFullWidthChar,
                fontInfo,
                wrappingIndent,
                wordBreak,
                isLineFeedWrappingEnabled,
                useTwoCellFullwidthCharacters));
          }
        }
        arrPool1.clear();
        arrPool2.clear();
        return result;
      },
    );
  }
}

/// 1:1: the anonymous object returned by `createLineBreaksComputer`.
class _MonospaceLineBreaksComputer implements ILineBreaksComputer {
  final void Function(int, ModelLineProjectionData?) _onAdd;
  final List<ModelLineProjectionData?> Function() _onFinalize;

  _MonospaceLineBreaksComputer(
      {required void Function(int, ModelLineProjectionData?) onAdd,
      required List<ModelLineProjectionData?> Function() onFinalize})
      : _onAdd = onAdd,
        _onFinalize = onFinalize;

  @override
  void addRequest(
      int lineNumber, ModelLineProjectionData? previousLineBreakData) {
    _onAdd(lineNumber, previousLineBreakData);
  }

  @override
  List<ModelLineProjectionData?> finalize() => _onFinalize();
}

/// 1:1: `const enum CharacterClass`.
class CharacterClass {
  static const int NONE = 0;
  static const int BREAK_BEFORE = 1;
  static const int BREAK_AFTER = 2;
  static const int BREAK_IDEOGRAPHIC = 3; // for Han and Kana.
  const CharacterClass._();
}

/// 1:1: `class WrappingCharacterClassifier extends CharacterClassifier`.
class WrappingCharacterClassifier extends CharacterClassifier<int> {
  WrappingCharacterClassifier(String BREAK_BEFORE, String BREAK_AFTER)
      : super(CharacterClass.NONE) {
    for (var i = 0; i < BREAK_BEFORE.length; i++) {
      set(BREAK_BEFORE.codeUnitAt(i), CharacterClass.BREAK_BEFORE);
    }
    for (var i = 0; i < BREAK_AFTER.length; i++) {
      set(BREAK_AFTER.codeUnitAt(i), CharacterClass.BREAK_AFTER);
    }
  }

  @override
  int get(int charCode) {
    if (charCode >= 0 && charCode < 256) {
      return super.get(charCode);
    }
    // Initialize CharacterClass.BREAK_IDEOGRAPHIC for these Unicode ranges:
    // 1. CJK Unified Ideographs (0x4E00 -- 0x9FFF)
    // 2. CJK Unified Ideographs Extension A (0x3400 -- 0x4DBF)
    // 3. Hiragana and Katakana (0x3040 -- 0x30FF)
    if ((charCode >= 0x3040 && charCode <= 0x30FF) ||
        (charCode >= 0x3400 && charCode <= 0x4DBF) ||
        (charCode >= 0x4E00 && charCode <= 0x9FFF)) {
      return CharacterClass.BREAK_IDEOGRAPHIC;
    }
    return super.get(charCode);
  }
}

/// 1:1: `let arrPool1/arrPool2: number[]`. Mutable global references.
List<int> arrPool1 = <int>[];
List<num> arrPool2 = <num>[];

/// JS arrays auto-extend on out-of-range index assignment. Dart lists do not.
void _jsSet<T>(List<T> list, int index, T value) {
  while (list.length <= index) {
    list.add(value);
  }
  list[index] = value;
}

/// JS `String.charCodeAt` returns NaN for out-of-range indices; Dart throws.
/// -1 is an equivalent sentinel here: it is >= 0 false (so classifier uses the
/// default value), not equal to any real charCode, and not a surrogate.
int _jsCharCodeAt(String s, int index) =>
    (index < 0 || index >= s.length) ? -1 : s.codeUnitAt(index);

/// 1:1: `createLineBreaksFromPreviousLineBreaks`.
ModelLineProjectionData? createLineBreaksFromPreviousLineBreaks(
  WrappingCharacterClassifier classifier,
  ModelLineProjectionData previousBreakingData,
  String lineText,
  int tabSize,
  int firstLineBreakColumn,
  num columnsForFullWidthChar,
  int wrappingIndent,
  String wordBreak,
  bool useTwoCellFullwidthCharacters,
) {
  if (firstLineBreakColumn == -1) {
    return null;
  }

  final len = lineText.length;
  if (len <= 1) {
    return null;
  }

  final isKeepAll = (wordBreak == 'keepAll');

  final prevBreakingOffsets = previousBreakingData.breakOffsets;
  final prevBreakingOffsetsVisibleColumn =
      previousBreakingData.breakOffsetsVisibleColumn;

  final wrappedTextIndentLength = computeWrappedTextIndentLength(
      lineText,
      tabSize,
      firstLineBreakColumn,
      fullWidthCharacterColumns(
          columnsForFullWidthChar, useTwoCellFullwidthCharacters),
      wrappingIndent);
  final wrappedLineBreakColumn =
      firstLineBreakColumn - wrappedTextIndentLength;

  var breakingOffsets = arrPool1;
  var breakingOffsetsVisibleColumn = arrPool2;
  var breakingOffsetsCount = 0;
  var lastBreakingOffset = 0;
  num lastBreakingOffsetVisibleColumn = 0;

  num breakingColumn = firstLineBreakColumn;
  final prevLen = prevBreakingOffsets.length;
  var prevIndex = 0;

  if (prevIndex >= 0) {
    var bestDistance =
        (prevBreakingOffsetsVisibleColumn[prevIndex] - breakingColumn).abs();
    while (prevIndex + 1 < prevLen) {
      final distance =
          (prevBreakingOffsetsVisibleColumn[prevIndex + 1] - breakingColumn)
              .abs();
      if (distance >= bestDistance) {
        break;
      }
      bestDistance = distance;
      prevIndex++;
    }
  }

  while (prevIndex < prevLen) {
    // Allow for prevIndex to be -1 (for the case where we hit a tab when
    // walking backwards from the first break)
    var prevBreakOffset =
        prevIndex < 0 ? 0 : prevBreakingOffsets[prevIndex];
    num prevBreakOffsetVisibleColumn = prevIndex < 0
        ? 0
        : prevBreakingOffsetsVisibleColumn[prevIndex];
    if (lastBreakingOffset > prevBreakOffset) {
      prevBreakOffset = lastBreakingOffset;
      prevBreakOffsetVisibleColumn = lastBreakingOffsetVisibleColumn;
    }

    var breakOffset = 0;
    num breakOffsetVisibleColumn = 0;

    var forcedBreakOffset = 0;
    num forcedBreakOffsetVisibleColumn = 0;

    // initially, we search as much as possible to the right (if it fits)
    if (prevBreakOffsetVisibleColumn <= breakingColumn) {
      var visibleColumn = prevBreakOffsetVisibleColumn;
      var prevCharCode = prevBreakOffset == 0
          ? CharCode.Null
          : _jsCharCodeAt(lineText, prevBreakOffset - 1);
      var prevCharCodeClass = prevBreakOffset == 0
          ? CharacterClass.NONE
          : classifier.get(prevCharCode);
      var entireLineFits = true;
      for (var i = prevBreakOffset; i < len; i++) {
        final charStartOffset = i;
        final charCode = _jsCharCodeAt(lineText, i);
        late final int charCodeClass;
        late final num charWidth;

        if (strings.isHighSurrogate(charCode)) {
          // A surrogate pair must always be considered as a single unit.
          i++;
          charCodeClass = CharacterClass.NONE;
          charWidth = 2;
        } else {
          charCodeClass = classifier.get(charCode);
          charWidth = computeCharWidth(charCode, visibleColumn, tabSize,
              columnsForFullWidthChar, useTwoCellFullwidthCharacters);
        }

        if (charStartOffset > lastBreakingOffset &&
            canBreak(prevCharCode, prevCharCodeClass, charCode, charCodeClass,
                isKeepAll)) {
          breakOffset = charStartOffset;
          breakOffsetVisibleColumn = visibleColumn;
        }

        visibleColumn += charWidth;

        // check if adding character at `i` will go over the breaking column
        if (visibleColumn > breakingColumn) {
          // We need to break at least before character at `i`:
          if (charStartOffset > lastBreakingOffset) {
            forcedBreakOffset = charStartOffset;
            forcedBreakOffsetVisibleColumn = visibleColumn - charWidth;
          } else {
            forcedBreakOffset = i + 1;
            forcedBreakOffsetVisibleColumn = visibleColumn;
          }

          if (visibleColumn - breakOffsetVisibleColumn > wrappedLineBreakColumn) {
            breakOffset = 0;
          }

          entireLineFits = false;
          break;
        }

        prevCharCode = charCode;
        prevCharCodeClass = charCodeClass;
      }

      if (entireLineFits) {
        if (breakingOffsetsCount > 0) {
          _jsSet(breakingOffsets, breakingOffsetsCount,
              prevBreakingOffsets[prevBreakingOffsets.length - 1]);
          _jsSet(breakingOffsetsVisibleColumn, breakingOffsetsCount,
              prevBreakingOffsetsVisibleColumn[
                  prevBreakingOffsetsVisibleColumn.length - 1]);
          breakingOffsetsCount++;
        }
        break;
      }
    }

    if (breakOffset == 0) {
      // must search left
      var visibleColumn = prevBreakOffsetVisibleColumn;
      var charCode = _jsCharCodeAt(lineText, prevBreakOffset);
      var charCodeClass = classifier.get(charCode);
      var hitATabCharacter = false;
      for (var i = prevBreakOffset - 1; i >= lastBreakingOffset; i--) {
        final charStartOffset = i + 1;
        final prevCharCode = _jsCharCodeAt(lineText, i);

        if (prevCharCode == CharCode.Tab) {
          hitATabCharacter = true;
          break;
        }

        late final int prevCharCodeClass;
        late final num prevCharWidth;

        if (strings.isLowSurrogate(prevCharCode)) {
          // A surrogate pair must always be considered as a single unit.
          i--;
          prevCharCodeClass = CharacterClass.NONE;
          prevCharWidth = 2;
        } else {
          prevCharCodeClass = classifier.get(prevCharCode);
          prevCharWidth = strings.isFullWidthCharacter(prevCharCode)
              ? fullWidthCharacterColumns(
                  columnsForFullWidthChar, useTwoCellFullwidthCharacters)
              : 1;
        }

        if (visibleColumn <= breakingColumn) {
          if (forcedBreakOffset == 0) {
            forcedBreakOffset = charStartOffset;
            forcedBreakOffsetVisibleColumn = visibleColumn;
          }

          if (visibleColumn <= breakingColumn - wrappedLineBreakColumn) {
            break;
          }

          if (canBreak(prevCharCode, prevCharCodeClass, charCode, charCodeClass,
              isKeepAll)) {
            breakOffset = charStartOffset;
            breakOffsetVisibleColumn = visibleColumn;
            break;
          }
        }

        visibleColumn -= prevCharWidth;
        charCode = prevCharCode;
        charCodeClass = prevCharCodeClass;
      }

      if (breakOffset != 0) {
        final remainingWidthOfNextLine = wrappedLineBreakColumn -
            (forcedBreakOffsetVisibleColumn - breakOffsetVisibleColumn);
        if (remainingWidthOfNextLine <= tabSize) {
          final charCodeAtForcedBreakOffset =
              _jsCharCodeAt(lineText, forcedBreakOffset);
          late final num charWidth;
          if (strings.isHighSurrogate(charCodeAtForcedBreakOffset)) {
            charWidth = 2;
          } else {
            charWidth = computeCharWidth(
                charCodeAtForcedBreakOffset,
                forcedBreakOffsetVisibleColumn,
                tabSize,
                columnsForFullWidthChar,
                useTwoCellFullwidthCharacters);
          }
          if (remainingWidthOfNextLine - charWidth < 0) {
            breakOffset = 0;
          }
        }
      }

      if (hitATabCharacter) {
        prevIndex--;
        continue;
      }
    }

    if (breakOffset == 0) {
      breakOffset = forcedBreakOffset;
      breakOffsetVisibleColumn = forcedBreakOffsetVisibleColumn;
    }

    if (breakOffset <= lastBreakingOffset) {
      final charCode = _jsCharCodeAt(lineText, lastBreakingOffset);
      if (strings.isHighSurrogate(charCode)) {
        breakOffset = lastBreakingOffset + 2;
        breakOffsetVisibleColumn = lastBreakingOffsetVisibleColumn + 2;
      } else {
        breakOffset = lastBreakingOffset + 1;
        breakOffsetVisibleColumn = lastBreakingOffsetVisibleColumn +
            computeCharWidth(charCode, lastBreakingOffsetVisibleColumn, tabSize,
                columnsForFullWidthChar, useTwoCellFullwidthCharacters);
      }
    }

    lastBreakingOffset = breakOffset;
    _jsSet(breakingOffsets, breakingOffsetsCount, breakOffset);
    lastBreakingOffsetVisibleColumn = breakOffsetVisibleColumn;
    _jsSet(breakingOffsetsVisibleColumn, breakingOffsetsCount,
        breakOffsetVisibleColumn);
    breakingOffsetsCount++;
    breakingColumn = breakOffsetVisibleColumn + wrappedLineBreakColumn;

    while (prevIndex < 0 ||
        (prevIndex < prevLen &&
            prevBreakingOffsetsVisibleColumn[prevIndex] <
                breakOffsetVisibleColumn)) {
      prevIndex++;
    }

    var bestDistance =
        (prevBreakingOffsetsVisibleColumn[prevIndex] - breakingColumn).abs();
    while (prevIndex + 1 < prevLen) {
      final distance =
          (prevBreakingOffsetsVisibleColumn[prevIndex + 1] - breakingColumn)
              .abs();
      if (distance >= bestDistance) {
        break;
      }
      bestDistance = distance;
      prevIndex++;
    }
  }

  if (breakingOffsetsCount == 0) {
    return null;
  }

  // Doing here some object reuse which ends up helping a huge deal with GC pauses!
  breakingOffsets.length = breakingOffsetsCount;
  breakingOffsetsVisibleColumn.length = breakingOffsetsCount;
  arrPool1 = previousBreakingData.breakOffsets;
  arrPool2 = previousBreakingData.breakOffsetsVisibleColumn;
  // ModelLineProjectionData fields are final in Dart; rebuild with the pooled
  // arrays and updated indent (1:1 mutation semantics, expressed immutably).
  return ModelLineProjectionData(
    previousBreakingData.injectionOffsets,
    previousBreakingData.injectionOptions,
    breakingOffsets,
    breakingOffsetsVisibleColumn,
    wrappedTextIndentLength,
  );
}

/// 1:1: `createLineBreaks`.
ModelLineProjectionData? createLineBreaks(
  WrappingCharacterClassifier classifier,
  String lineTextRaw,
  List<LineInjectedText>? injectedTexts,
  int tabSize,
  int firstLineBreakColumn,
  num columnsForFullWidthChar,
  FontInfo fontInfo,
  int wrappingIndent,
  String wordBreak,
  bool wrapOnEscapedLineFeeds,
  bool useTwoCellFullwidthCharacters,
) {
  final lineText = LineInjectedText.applyInjectedText(lineTextRaw, injectedTexts);
  final fixedWidthRanges =
      LineInjectedText.getFixedWidthInjectedTextRanges(injectedTexts);

  List<Map<String, dynamic>>? injectionOptions;
  List<int>? injectionOffsets;
  if (injectedTexts != null && injectedTexts.isNotEmpty) {
    injectionOptions =
        injectedTexts.map((t) => Map<String, dynamic>.from(t.options)).toList();
    injectionOffsets = injectedTexts.map((text) => text.column - 1).toList();
  } else {
    injectionOptions = null;
    injectionOffsets = null;
  }

  if (firstLineBreakColumn == -1) {
    if (injectionOptions == null) {
      return null;
    }
    // creating a LineBreakData with an invalid breakOffsetsVisibleColumn is OK
    return ModelLineProjectionData(
        injectionOffsets, injectionOptions, [lineText.length], [], 0);
  }

  final len = lineText.length;
  if (len <= 1) {
    if (injectionOptions == null) {
      return null;
    }
    return ModelLineProjectionData(
        injectionOffsets, injectionOptions, [lineText.length], [], 0);
  }

  final isKeepAll = (wordBreak == 'keepAll');
  final wrappedTextIndentLength = computeWrappedTextIndentLength(
      lineText,
      tabSize,
      firstLineBreakColumn,
      fullWidthCharacterColumns(
          columnsForFullWidthChar, useTwoCellFullwidthCharacters),
      wrappingIndent,
      fixedWidthRanges);

  // The wrapping decision is taken in pixels, because injected text can
  // request an arbitrary width via `widthInEm`.
  final typicalHalfwidthCharacterWidth = fontInfo.typicalHalfwidthCharacterWidth;
  final wrappedLineBreakPixelWidth =
      (firstLineBreakColumn - wrappedTextIndentLength) *
          typicalHalfwidthCharacterWidth;

  final breakingOffsets = <int>[];
  final breakingOffsetsVisibleColumn = <num>[];
  var breakingOffsetsCount = 0;
  var breakOffset = 0;
  num breakOffsetVisibleColumn = 0;
  num breakOffsetPixelWidth = 0;

  var breakingPixelWidth = firstLineBreakColumn * typicalHalfwidthCharacterWidth;
  var fixedWidthRangeIndex = 0;
  final firstFixedWidthRange =
      fixedWidthRanges.isNotEmpty ? fixedWidthRanges[0] : null;
  final startsWithFixedWidth =
      firstFixedWidthRange != null && firstFixedWidthRange['startOffset'] == 0;

  late int prevCharCode;
  late num visibleColumn;
  late num currentLinePixelWidth;
  late int startOffset;
  if (startsWithFixedWidth) {
    prevCharCode = CharCode.Null;
    visibleColumn = computeFixedWidthRangeColumnWidth(
        lineText,
        firstFixedWidthRange,
        0,
        tabSize,
        columnsForFullWidthChar,
        useTwoCellFullwidthCharacters);
    currentLinePixelWidth = (firstFixedWidthRange['widthInEm'] as num) *
        fontInfo.fontSize;
    startOffset = firstFixedWidthRange['endOffset'] as int;
    fixedWidthRangeIndex++;
  } else {
    prevCharCode = _jsCharCodeAt(lineText, 0);
    visibleColumn = computeCharWidth(prevCharCode, 0, tabSize,
        columnsForFullWidthChar, useTwoCellFullwidthCharacters);
    currentLinePixelWidth = computeCharPixelWidth(prevCharCode, 0, tabSize,
        fontInfo, useTwoCellFullwidthCharacters);
    startOffset = 1;
    if (strings.isHighSurrogate(prevCharCode)) {
      // A surrogate pair must always be considered as a single unit, so it is
      // never to be broken. Skip the low surrogate.
      visibleColumn += 1;
      currentLinePixelWidth += typicalHalfwidthCharacterWidth;
      prevCharCode = _jsCharCodeAt(lineText, 1);
      startOffset++;
    }
  }
  // 1:1: `prevCharCodeClass` (NONE when starting with fixed-width; otherwise
  // classified from the first real character).
  var loopPrevCharCode = prevCharCode;
  var loopPrevCharCodeClass = startsWithFixedWidth
      ? CharacterClass.NONE
      : classifier.get(prevCharCode);

  for (var i = startOffset; i < len; i++) {
    final fixedWidthRange = fixedWidthRanges.isNotEmpty &&
            fixedWidthRangeIndex < fixedWidthRanges.length
        ? fixedWidthRanges[fixedWidthRangeIndex]
        : null;
    final charStartOffset = i;
    var charCode = _jsCharCodeAt(lineText, i);
    late final int charCodeClass;
    late final num charWidth;
    late final num charPixelWidth;
    var wrapEscapedLineFeed = false;

    if (fixedWidthRange != null &&
        fixedWidthRange['startOffset'] == i) {
      charCode = CharCode.Null;
      charCodeClass = CharacterClass.NONE;
      charWidth = computeFixedWidthRangeColumnWidth(
          lineText,
          fixedWidthRange,
          visibleColumn,
          tabSize,
          columnsForFullWidthChar,
          useTwoCellFullwidthCharacters);
      charPixelWidth = (fixedWidthRange['widthInEm'] as num) * fontInfo.fontSize;
      i = (fixedWidthRange['endOffset'] as int) - 1;
      fixedWidthRangeIndex++;
    } else if (strings.isHighSurrogate(charCode)) {
      i++;
      charCodeClass = CharacterClass.NONE;
      charWidth = 2;
      charPixelWidth = 2 * typicalHalfwidthCharacterWidth;
    } else {
      charCodeClass = classifier.get(charCode);
      charWidth = computeCharWidth(charCode, visibleColumn, tabSize,
          columnsForFullWidthChar, useTwoCellFullwidthCharacters);
      charPixelWidth = computeCharPixelWidth(charCode, visibleColumn, tabSize,
          fontInfo, useTwoCellFullwidthCharacters);
    }

    // literal \n shall trigger a softwrap
    if (wrapOnEscapedLineFeeds &&
        isEscapedLineBreakAtPosition(lineText, charStartOffset)) {
      breakOffset = charStartOffset;
      breakOffsetVisibleColumn = visibleColumn;
      breakOffsetPixelWidth = currentLinePixelWidth;
      wrapEscapedLineFeed = true;
    } else if (canBreak(loopPrevCharCode, loopPrevCharCodeClass, charCode,
        charCodeClass, isKeepAll)) {
      breakOffset = charStartOffset;
      breakOffsetVisibleColumn = visibleColumn;
      breakOffsetPixelWidth = currentLinePixelWidth;
    }

    visibleColumn += charWidth;
    currentLinePixelWidth += charPixelWidth;

    // check if adding character at `i` will go over the breaking width
    if (currentLinePixelWidth > breakingPixelWidth || wrapEscapedLineFeed) {
      if (breakOffset == 0 ||
          currentLinePixelWidth - breakOffsetPixelWidth >
              wrappedLineBreakPixelWidth) {
        breakOffset = charStartOffset;
        breakOffsetVisibleColumn = visibleColumn - charWidth;
        breakOffsetPixelWidth = currentLinePixelWidth - charPixelWidth;
      }

      final currentLineStartOffset = breakingOffsetsCount > 0
          ? breakingOffsets[breakingOffsetsCount - 1]
          : 0;
      if (breakOffset > currentLineStartOffset) {
        _jsSet(breakingOffsets, breakingOffsetsCount, breakOffset);
        _jsSet(breakingOffsetsVisibleColumn, breakingOffsetsCount,
            breakOffsetVisibleColumn);
        breakingOffsetsCount++;
        breakingPixelWidth =
            breakOffsetPixelWidth + wrappedLineBreakPixelWidth;
        breakOffset = 0;
      }
    }

    loopPrevCharCode = charCode;
    loopPrevCharCodeClass = charCodeClass;
  }

  if (breakingOffsetsCount == 0 &&
      (injectedTexts == null || injectedTexts.isEmpty)) {
    return null;
  }

  // Add last segment
  _jsSet(breakingOffsets, breakingOffsetsCount, len);
  _jsSet(breakingOffsetsVisibleColumn, breakingOffsetsCount, visibleColumn);

  return ModelLineProjectionData(
    injectionOffsets,
    injectionOptions,
    breakingOffsets,
    breakingOffsetsVisibleColumn,
    wrappedTextIndentLength,
  );
}

/// 1:1: `computeCharWidth`.
num computeCharWidth(int charCode, num visibleColumn, int tabSize,
    num columnsForFullWidthChar, bool useTwoCellFullwidthCharacters) {
  if (charCode == CharCode.Tab) {
    return tabSize - (visibleColumn % tabSize);
  }
  if (strings.isFullWidthCharacter(charCode)) {
    return fullWidthCharacterColumns(
        columnsForFullWidthChar, useTwoCellFullwidthCharacters);
  }
  if (charCode < 32) {
    return columnsForFullWidthChar;
  }
  return 1;
}

/// 1:1: `fullWidthCharacterColumns`.
num fullWidthCharacterColumns(
        num columnsForFullWidthChar, bool useTwoCellFullwidthCharacters) =>
    useTwoCellFullwidthCharacters ? 2 : columnsForFullWidthChar;

/// 1:1: `tabCharacterWidth`.
int tabCharacterWidth(num visibleColumn, int tabSize) =>
    tabSize - (visibleColumn % tabSize).toInt();

/// 1:1: `computeCharPixelWidth`.
num computeCharPixelWidth(int charCode, num visibleColumn, int tabSize,
    FontInfo fontInfo, bool useTwoCellFullwidthCharacters) {
  if (charCode == CharCode.Tab) {
    return tabCharacterWidth(visibleColumn, tabSize) *
        fontInfo.typicalHalfwidthCharacterWidth;
  }
  if (strings.isFullWidthCharacter(charCode)) {
    return useTwoCellFullwidthCharacters
        ? 2 * fontInfo.typicalHalfwidthCharacterWidth
        : fontInfo.typicalFullwidthCharacterWidth;
  }
  if (charCode < 32) {
    return fontInfo.typicalFullwidthCharacterWidth;
  }
  return fontInfo.typicalHalfwidthCharacterWidth;
}

/// 1:1: `computeFixedWidthRangeColumnWidth`.
num computeFixedWidthRangeColumnWidth(
    String lineText,
    Map<String, dynamic> range,
    num visibleColumn,
    int tabSize,
    num columnsForFullWidthChar,
    bool useTwoCellFullwidthCharacters) {
  num width = 0;
  for (var i = range['startOffset'] as int; i < (range['endOffset'] as int); i++) {
    width += computeCharWidth(
        _jsCharCodeAt(lineText, i),
        visibleColumn + width,
        tabSize,
        columnsForFullWidthChar,
        useTwoCellFullwidthCharacters);
  }
  return width;
}

/// 1:1: `isEscapedLineBreakAtPosition`.
bool isEscapedLineBreakAtPosition(String lineText, int i) {
  if (i >= 2 && _jsCharCodeAt(lineText, i - 1) == CharCode.n) {
    var escapeCount = 0;
    for (var j = i - 2; j >= 0; j--) {
      if (_jsCharCodeAt(lineText, j) == CharCode.Backslash) {
        escapeCount++;
      } else {
        return escapeCount % 2 == 1;
      }
    }
  }
  return false;
}

/// 1:1: `canBreak`.
bool canBreak(int prevCharCode, int prevCharCodeClass, int charCode,
    int charCodeClass, bool isKeepAll) {
  return (charCode != CharCode.Space &&
      ((prevCharCodeClass == CharacterClass.BREAK_AFTER &&
              charCodeClass != CharacterClass.BREAK_AFTER) ||
          (prevCharCodeClass != CharacterClass.BREAK_BEFORE &&
              charCodeClass == CharacterClass.BREAK_BEFORE) ||
          (!isKeepAll &&
              prevCharCodeClass == CharacterClass.BREAK_IDEOGRAPHIC &&
              charCodeClass != CharacterClass.BREAK_AFTER) ||
          (!isKeepAll &&
              charCodeClass == CharacterClass.BREAK_IDEOGRAPHIC &&
              prevCharCodeClass != CharacterClass.BREAK_BEFORE)));
}

/// 1:1: `computeWrappedTextIndentLength`.
int computeWrappedTextIndentLength(
  String lineText,
  int tabSize,
  int firstLineBreakColumn,
  num columnsForFullWidthChar,
  int wrappingIndent, [
  List<Map<String, dynamic>>? fixedWidthRanges,
]) {
  var wrappedTextIndentLength = 0;
  if (wrappingIndent != WrappingIndent.None) {
    final firstNonWhitespaceIndex = strings.firstNonWhitespaceIndex(lineText);
    if (firstNonWhitespaceIndex != -1) {
      for (var i = 0; i < firstNonWhitespaceIndex; i++) {
        if (fixedWidthRanges != null &&
            fixedWidthRanges.isNotEmpty &&
            fixedWidthRanges[0]['startOffset'] == i) {
          break;
        }
        final charWidth = _jsCharCodeAt(lineText, i) == CharCode.Tab
            ? tabCharacterWidth(wrappedTextIndentLength, tabSize)
            : 1;
        wrappedTextIndentLength += charWidth;
      }

      final numberOfAdditionalTabs = wrappingIndent == WrappingIndent.DeepIndent
          ? 2
          : wrappingIndent == WrappingIndent.Indent
              ? 1
              : 0;
      for (var i = 0; i < numberOfAdditionalTabs; i++) {
        final charWidth =
            tabCharacterWidth(wrappedTextIndentLength, tabSize);
        wrappedTextIndentLength += charWidth;
      }

      if (wrappedTextIndentLength + columnsForFullWidthChar >
          firstLineBreakColumn) {
        wrappedTextIndentLength = 0;
      }
    }
  }
  return wrappedTextIndentLength;
}
