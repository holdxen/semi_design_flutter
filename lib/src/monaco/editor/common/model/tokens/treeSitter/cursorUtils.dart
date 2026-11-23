// 1:1 translation of
// vscode/src/vs/editor/common/model/tokens/treeSitter/cursorUtils.ts
//
// The source imports `@vscode/tree-sitter-wasm` types. WebAssembly tree-sitter
// objects are carried as abstract interfaces so this pure cursor-walking logic
// can be exercised with injected fakes.

/// 1:1: `TreeSitter.TreeCursor` (opaque wasm handle).
abstract class TreeCursor {
  bool gotoNextSibling();
  bool gotoParent();
  bool gotoFirstChild();
  bool gotoPreviousSibling();
  void resetTo(TreeCursor cursor);
  TreeNode get currentNode;
}

/// 1:1: `TreeSitter.Tree` (opaque wasm handle).
abstract class Tree {
  TreeCursor walk();
}

/// 1:1: `TreeSitter.Node` (opaque wasm handle).
abstract class TreeNode {
  TreeNode? get nextSibling;
  TreeNode? get previousSibling;
  TreeNode? get parent;
  int get endIndex;
  int get startIndex;
  Object? get id;
}

/// 1:1: `export function gotoNextSibling(newCursor, oldCursor)`
bool gotoNextSibling(TreeCursor newCursor, TreeCursor oldCursor) {
  final bool n = newCursor.gotoNextSibling();
  final bool o = oldCursor.gotoNextSibling();
  if (n != o) {
    throw StateError('Trees are out of sync');
  }
  return n && o;
}

/// 1:1: `export function gotoParent(newCursor, oldCursor)`
bool gotoParent(TreeCursor newCursor, TreeCursor oldCursor) {
  final bool n = newCursor.gotoParent();
  final bool o = oldCursor.gotoParent();
  if (n != o) {
    throw StateError('Trees are out of sync');
  }
  return n && o;
}

/// 1:1: `export function gotoNthChild(newCursor, oldCursor, index)`
bool gotoNthChild(
  TreeCursor newCursor,
  TreeCursor oldCursor,
  int index,
) {
  final bool n = newCursor.gotoFirstChild();
  final bool o = oldCursor.gotoFirstChild();
  if (n != o) {
    throw StateError('Trees are out of sync');
  }
  if (index == 0) {
    return n && o;
  }
  for (int i = 1; i <= index; i++) {
    final bool nn = newCursor.gotoNextSibling();
    final bool oo = oldCursor.gotoNextSibling();
    if (nn != oo) {
      throw StateError('Trees are out of sync');
    }
    if (!nn || !oo) {
      return false;
    }
  }
  return n && o;
}

/// 1:1: `export function nextSiblingOrParentSibling(newCursor, oldCursor)`
bool nextSiblingOrParentSibling(TreeCursor newCursor, TreeCursor oldCursor) {
  do {
    if (newCursor.currentNode.nextSibling != null) {
      return gotoNextSibling(newCursor, oldCursor);
    }
    if (newCursor.currentNode.parent != null) {
      gotoParent(newCursor, oldCursor);
    }
  } while (newCursor.currentNode.nextSibling != null ||
      newCursor.currentNode.parent != null);
  return false;
}

/// 1:1: `export function getClosestPreviousNodes(cursor, tree): Node | undefined`
TreeNode? getClosestPreviousNodes(TreeCursor cursor, Tree tree) {
  // Go up parents until the end of the parent is before the start of the current.
  final TreeCursor findPrev = tree.walk();
  findPrev.resetTo(cursor);

  final TreeNode startingNode = cursor.currentNode;
  do {
    if (findPrev.currentNode.previousSibling != null &&
        ((findPrev.currentNode.endIndex - findPrev.currentNode.startIndex) !=
            0)) {
      findPrev.gotoPreviousSibling();
    } else {
      while (findPrev.currentNode.previousSibling == null &&
          findPrev.currentNode.parent != null) {
        findPrev.gotoParent();
      }
      findPrev.gotoPreviousSibling();
    }
  } while ((findPrev.currentNode.endIndex > startingNode.startIndex) &&
      (findPrev.currentNode.parent != null ||
          findPrev.currentNode.previousSibling != null) &&
      (findPrev.currentNode.id != startingNode.id));

  if ((findPrev.currentNode.id != startingNode.id) &&
      findPrev.currentNode.endIndex <= startingNode.startIndex) {
    return findPrev.currentNode;
  } else {
    return null;
  }
}
