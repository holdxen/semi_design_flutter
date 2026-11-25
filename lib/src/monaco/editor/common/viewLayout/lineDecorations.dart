// ---------------------------------------------------------------------------
// Port of vscode/src/vs/editor/common/viewLayout/lineDecorations.ts
// Translated 1:1 from TypeScript.
//
// Adaptations (documented inline):
//  * `InlineDecoration` / `InlineDecorationType` come from
//    `viewModel/inlineDecorations.ts` (not yet ported); they are 1:1 carriers
//    here (enum + 3 fields).
//  * `isHighSurrogate` / `LinePartMetadata` / `Constants` are reused from the
//    real port.
// ---------------------------------------------------------------------------

import '../../../base/common/strings.dart' show isHighSurrogate;
import '../../../base/common/uint.dart' show Constants;
import '../core/range.dart' show Range;
import 'linePart.dart' show LinePartMetadata;
import '../viewModel/inlineDecorations.dart'
    show InlineDecoration, InlineDecorationType;

/// 1:1: `LineDecoration`.
class LineDecoration {
  final int startColumn;
  final int endColumn;
  final String className;
  final int type;

  const LineDecoration(this.startColumn, this.endColumn, this.className, this.type);

  static bool _equals(LineDecoration a, LineDecoration b) =>
      a.startColumn == b.startColumn &&
      a.endColumn == b.endColumn &&
      a.className == b.className &&
      a.type == b.type;

  static bool equalsArr(
    List<LineDecoration> a,
    List<LineDecoration> b,
  ) {
    final int aLen = a.length;
    final int bLen = b.length;
    if (aLen != bLen) return false;
    for (int i = 0; i < aLen; i++) {
      if (!_equals(a[i], b[i])) return false;
    }
    return true;
  }

  static List<LineDecoration> extractWrapped(
    List<LineDecoration> arr,
    int startOffset,
    int endOffset,
  ) {
    if (arr.isEmpty) return arr;
    final int startColumn = startOffset + 1;
    final int endColumn = endOffset + 1;
    final int lineLength = endOffset - startOffset;
    final List<LineDecoration> result = <LineDecoration>[];
    for (final LineDecoration dec in arr) {
      if (dec.endColumn <= startColumn || dec.startColumn >= endColumn) {
        continue;
      }
      result.add(LineDecoration(
        _max(1, dec.startColumn - startColumn + 1),
        _min(lineLength + 1, dec.endColumn - startColumn + 1),
        dec.className,
        dec.type,
      ));
    }
    return result;
  }

  static List<LineDecoration> filter(
    List<InlineDecoration> lineDecorations,
    int lineNumber,
    int minLineColumn,
    int maxLineColumn,
  ) {
    if (lineDecorations.isEmpty) return <LineDecoration>[];
    final List<LineDecoration> result = <LineDecoration>[];
    for (final InlineDecoration d in lineDecorations) {
      final Range range = d.range;
      if (range.endLineNumber < lineNumber ||
          range.startLineNumber > lineNumber) {
        continue;
      }
      if (range.isEmpty() &&
          (d.type == InlineDecorationType.Regular ||
              d.type == InlineDecorationType.RegularAffectingLetterSpacing)) {
        continue;
      }
      final int startColumn = range.startLineNumber == lineNumber
          ? range.startColumn
          : minLineColumn;
      final int endColumn = range.endLineNumber == lineNumber
          ? range.endColumn
          : maxLineColumn;
      result.add(LineDecoration(
        startColumn,
        endColumn,
        d.inlineClassName,
        d.type,
      ));
    }
    return result;
  }

  static int _typeCompare(int a, int b) {
    // WidthOnly, Before, After, Regular, RegularAffectingLetterSpacing.
    const List<int> order = <int>[3, 1, 2, 4, 0];
    return order[a] - order[b];
  }

  static int compare(LineDecoration a, LineDecoration b) {
    if (a.startColumn != b.startColumn) {
      return a.startColumn - b.startColumn;
    }
    if (a.endColumn != b.endColumn) {
      return a.endColumn - b.endColumn;
    }
    final int typeCmp = _typeCompare(a.type, b.type);
    if (typeCmp != 0) return typeCmp;
    if (a.className != b.className) {
      return a.className.compareTo(b.className) < 0 ? -1 : 1;
    }
    return 0;
  }
}

/// 1:1: `DecorationSegment`.
class DecorationSegment {
  int startOffset;
  int endOffset;
  String className;
  int metadata;

  DecorationSegment(
    this.startOffset,
    this.endOffset,
    this.className,
    this.metadata,
  );
}

/// 1:1: `Stack`.
class Stack {
  int count = 0;
  final List<int> _stopOffsets = <int>[];
  final List<String> _classNames = <String>[];
  final List<int> _meta = <int>[];

  static int _metadata(List<int> metadata) {
    int result = 0;
    for (final int m in metadata) {
      result |= m;
    }
    return result;
  }

  int consumeLowerThan(
    int maxStopOffset,
    int nextStartOffset,
    List<DecorationSegment> result,
  ) {
    while (count > 0 && _stopOffsets[0] < maxStopOffset) {
      int i = 0;
      // Take all equal stopping offsets.
      while (i + 1 < count && _stopOffsets[i] == _stopOffsets[i + 1]) {
        i++;
      }
      // Consume the first i+1 elements of the stack.
      result.add(DecorationSegment(
        nextStartOffset,
        _stopOffsets[i],
        _classNames.join(' '),
        Stack._metadata(_meta.sublist(0, i + 1)),
      ));
      nextStartOffset = _stopOffsets[i] + 1;
      _stopOffsets.removeRange(0, i + 1);
      _classNames.removeRange(0, i + 1);
      _meta.removeRange(0, i + 1);
      count -= i + 1;
    }

    if (count > 0 && nextStartOffset < maxStopOffset) {
      result.add(DecorationSegment(
        nextStartOffset,
        maxStopOffset - 1,
        _classNames.join(' '),
        Stack._metadata(_meta),
      ));
      nextStartOffset = maxStopOffset;
    }

    return nextStartOffset;
  }

  void insert(int stopOffset, String className, int metadata) {
    if (count == 0 || _stopOffsets[count - 1] <= stopOffset) {
      _stopOffsets.add(stopOffset);
      _classNames.add(className);
      _meta.add(metadata);
    } else {
      for (int i = 0; i < count; i++) {
        if (_stopOffsets[i] >= stopOffset) {
          _stopOffsets.insert(i, stopOffset);
          _classNames.insert(i, className);
          _meta.insert(i, metadata);
          break;
        }
      }
    }
    count++;
  }
}

/// 1:1: `LineDecorationsNormalizer`.
class LineDecorationsNormalizer {
  static List<DecorationSegment> normalize(
    String lineContent,
    List<LineDecoration> lineDecorations,
  ) {
    if (lineDecorations.isEmpty) return <DecorationSegment>[];
    final List<DecorationSegment> result = <DecorationSegment>[];
    final Stack stack = Stack();
    int nextStartOffset = 0;

    for (final LineDecoration d in lineDecorations) {
      int startColumn = d.startColumn;
      int endColumn = d.endColumn;
      final String className = d.className;
      final int metadata = d.type == InlineDecorationType.Before
          ? LinePartMetadata.PSEUDO_BEFORE
          : d.type == InlineDecorationType.After
              ? LinePartMetadata.PSEUDO_AFTER
              : 0;

      if (startColumn > 1) {
        final int charCodeBefore = lineContent.codeUnitAt(startColumn - 2);
        if (isHighSurrogate(charCodeBefore)) startColumn--;
      }
      if (endColumn > 1) {
        final int charCodeBefore = lineContent.codeUnitAt(endColumn - 2);
        if (isHighSurrogate(charCodeBefore)) endColumn--;
      }

      final int currentStartOffset = startColumn - 1;
      final int currentEndOffset = endColumn - 2;

      nextStartOffset = stack.consumeLowerThan(
        currentStartOffset,
        nextStartOffset,
        result,
      );
      if (stack.count == 0) {
        nextStartOffset = currentStartOffset;
      }
      stack.insert(currentEndOffset, className, metadata);
    }

    stack.consumeLowerThan(
      Constants.MAX_SAFE_SMALL_INTEGER,
      nextStartOffset,
      result,
    );
    return result;
  }
}

int _max(int a, int b) => a > b ? a : b;
int _min(int a, int b) => a < b ? a : b;
