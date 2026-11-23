// ---------------------------------------------------------------------------
// Port of vscode/src/vs/editor/common/diff/defaultLinesDiffComputer/lineSequence.ts
// Translated 1:1 from TypeScript.
// ---------------------------------------------------------------------------

import '../../../../base/common/charCode.dart' show CharCode;
import '../../core/ranges/offsetRange.dart' show OffsetRange;
import 'algorithms/diffAlgorithm.dart' show ISequence;

/// 1:1: `export class LineSequence implements ISequence`
class LineSequence implements ISequence {
  final List<int> trimmedHash;
  final List<String> lines;

  LineSequence(this.trimmedHash, this.lines);

  @override
  int getElement(int offset) => trimmedHash[offset];

  @override
  int get length => trimmedHash.length;

  @override
  int getBoundaryScore(int length) {
    final int indentationBefore = length == 0 ? 0 : getIndentation(lines[length - 1]);
    final int indentationAfter = length == lines.length ? 0 : getIndentation(lines[length]);
    return 1000 - (indentationBefore + indentationAfter);
  }

  /// 1:1: `getText(range: OffsetRange): string`
  String getText(OffsetRange range) => lines.sublist(range.start, range.endExclusive).join('\n');

  @override
  bool isStronglyEqual(int offset1, int offset2) => lines[offset1] == lines[offset2];
}

/// 1:1: `function getIndentation(str: string): number`
int getIndentation(String str) {
  int i = 0;
  while (i < str.length &&
      (str.codeUnitAt(i) == CharCode.Space || str.codeUnitAt(i) == CharCode.Tab)) {
    i++;
  }
  return i;
}
