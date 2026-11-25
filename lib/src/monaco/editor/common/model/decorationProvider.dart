// ---------------------------------------------------------------------------
// 1:1 port of vscode/src/vs/editor/common/model/decorationProvider.ts (54 lines).
//
// The `DecorationProvider` interface is ERASED (repo convention): it only
// declares `getDecorationsInRange` / `getAllDecorations` and no implementation
// consumes it structurally yet. The two runtime classes are ported verbatim.
// ---------------------------------------------------------------------------

class LineHeightChangingDecoration {
  LineHeightChangingDecoration(
      this.ownerId, this.decorationId, this.lineNumber, this.lineHeight);

  static String toKey(LineHeightChangingDecoration obj) =>
      '${obj.ownerId};${obj.decorationId};${obj.lineNumber}';

  final int ownerId;
  final String decorationId;
  final int lineNumber;
  final num? lineHeight;
}

class LineFontChangingDecoration {
  LineFontChangingDecoration(this.ownerId, this.decorationId, this.lineNumber);

  static String toKey(LineFontChangingDecoration obj) =>
      '${obj.ownerId};${obj.decorationId};${obj.lineNumber}';

  final int ownerId;
  final String decorationId;
  final int lineNumber;
}
