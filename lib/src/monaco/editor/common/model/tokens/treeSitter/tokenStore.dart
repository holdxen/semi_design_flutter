// ---------------------------------------------------------------------------
// Port of vscode/src/vs/editor/common/model/tokens/treeSitter/tokenStore.ts
// Translated 1:1 from TypeScript. Structure, members and semantics preserved.
//
// Adaptations (documented inline):
//  * TS union `Node = ListNode | LeafNode` -> Dart common base class +
//    `isLeaf` type predicate.
//  * TS interfaces `LeafNode` / `TokenUpdate` / `ITextModel` -> concrete
//    carriers (repo convention for erased interfaces).
//  * TS `undefined` parent -> Dart `null`; `export enum` -> class static const.
// ---------------------------------------------------------------------------
import '../../../../../base/common/lifecycle.dart' show IDisposable;

/// 1:1: `export enum TokenQuality`.
class TokenQuality {
  const TokenQuality._();
  static const int None = 0;
  static const int ViewportGuess = 1;
  static const int EditGuess = 2;
  static const int Accurate = 3;
}

/// 1:1: `type Node = ListNode | LeafNode` (common surface).
abstract class Node {
  ListNode? parent;
  int get length;
  int get height;
}

/// 1:1: `LeafNode` (TS interface -> concrete carrier).
class LeafNode extends Node {
  @override
  final int length;
  int token;
  int tokenQuality;

  LeafNode(this.length, this.token, this.tokenQuality);

  @override
  int get height => 0;
}

/// 1:1: `export class ListNode implements IDisposable`.
class ListNode extends Node implements IDisposable {
  final List<Node> _children = <Node>[];

  /// TS getter returns `ReadonlyArray<Node>`; the internal array is exposed
  /// here so the 1:1 algorithms can use `length`/indexing unchanged.
  List<Node> get children => _children;

  int _length = 0;

  @override
  int get length => _length;

  @override
  final int height;

  ListNode(this.height);

  /// 1:1: `static create(node1, node2)`
  static ListNode create(Node node1, Node node2) {
    final ListNode list = ListNode(node1.height + 1);
    list.appendChild(node1);
    list.appendChild(node2);
    return list;
  }

  bool canAppendChild() => _children.length < 3;

  void appendChild(Node node) {
    if (!canAppendChild()) {
      throw StateError('Cannot insert more than 3 children in a ListNode');
    }
    _children.add(node);

    _length += node.length;
    _updateParentLength(node.length);
    if (!isLeaf(node)) {
      node.parent = this;
    }
  }

  void _updateParentLength(int delta) {
    ListNode? updateParent = parent;
    while (updateParent != null) {
      updateParent._length += delta;
      updateParent = updateParent.parent;
    }
  }

  Node unappendChild() {
    final Node child = _children.removeLast();
    _length -= child.length;
    _updateParentLength(-child.length);
    return child;
  }

  void prependChild(Node node) {
    if (_children.length >= 3) {
      throw StateError('Cannot prepend more than 3 children in a ListNode');
    }
    _children.insert(0, node);

    _length += node.length;
    _updateParentLength(node.length);
    if (!isLeaf(node)) {
      node.parent = this;
    }
  }

  Node unprependChild() {
    final Node child = _children.removeAt(0);
    _length -= child.length;
    _updateParentLength(-child.length);
    return child;
  }

  Node lastChild() => _children[_children.length - 1];

  @override
  void dispose() {
    _children.clear();
  }
}

/// 1:1: `export interface TokenUpdate`.
class TokenUpdate {
  final int startOffsetInclusive;
  final int length;
  final int token;

  TokenUpdate(this.startOffsetInclusive, this.length, this.token);

  @override
  String toString() =>
      '{token: $token, startOffsetInclusive: $startOffsetInclusive, length: $length}';
}

/// 1:1: `ITextModel.getValueLength()` member.
abstract class ITextModelForTokenStore {
  int getValueLength();
}

bool isLeaf(Node node) => node is LeafNode;

/// 1:1: `append(node, nodeToAppend)`
Node append(Node node, Node nodeToAppend) {
  Node curNode = node;
  final List<ListNode> parents = <ListNode>[];
  Node? nodeToAppendOfCorrectHeight;
  while (true) {
    if (nodeToAppend.height == curNode.height) {
      nodeToAppendOfCorrectHeight = nodeToAppend;
      break;
    }

    if (isLeaf(curNode)) {
      throw StateError('unexpected');
    }
    final ListNode listNode = curNode as ListNode;
    parents.add(listNode);
    curNode = listNode.lastChild();
  }
  for (int i = parents.length - 1; i >= 0; i--) {
    final ListNode parent = parents[i];
    if (nodeToAppendOfCorrectHeight != null) {
      // Can we take the element?
      if (parent.children.length >= 3) {
        // we need to split to maintain (2,3)-tree property.
        // Send the third element + the new element to the parent.
        final ListNode newList =
            ListNode.create(parent.unappendChild(), nodeToAppendOfCorrectHeight);
        nodeToAppendOfCorrectHeight = newList;
      } else {
        parent.appendChild(nodeToAppendOfCorrectHeight);
        nodeToAppendOfCorrectHeight = null;
      }
    }
  }
  if (nodeToAppendOfCorrectHeight != null) {
    final ListNode newList = ListNode(nodeToAppendOfCorrectHeight.height + 1);
    newList.appendChild(node);
    newList.appendChild(nodeToAppendOfCorrectHeight);
    return newList;
  } else {
    return node;
  }
}

/// 1:1: `prepend(list, nodeToAppend)`
Node prepend(Node list, Node nodeToAppend) {
  Node curNode = list;
  final List<ListNode> parents = <ListNode>[];
  while (nodeToAppend.height != curNode.height) {
    if (isLeaf(curNode)) {
      throw StateError('unexpected');
    }
    final ListNode listNode = curNode as ListNode;
    parents.add(listNode);
    // assert 2 <= curNode.childrenFast.length <= 3
    curNode = listNode.children[0];
  }
  Node? nodeToPrependOfCorrectHeight = nodeToAppend;
  for (int i = parents.length - 1; i >= 0; i--) {
    final ListNode parent = parents[i];
    if (nodeToPrependOfCorrectHeight != null) {
      if (parent.children.length >= 3) {
        nodeToPrependOfCorrectHeight = ListNode.create(
            nodeToPrependOfCorrectHeight, parent.unprependChild());
      } else {
        parent.prependChild(nodeToPrependOfCorrectHeight);
        nodeToPrependOfCorrectHeight = null;
      }
    }
  }
  if (nodeToPrependOfCorrectHeight != null) {
    return ListNode.create(nodeToPrependOfCorrectHeight, list);
  } else {
    return list;
  }
}

/// 1:1: `concat(node1, node2)`
Node concat(Node node1, Node node2) {
  if (node1.height == node2.height) {
    return ListNode.create(node1, node2);
  } else if (node1.height > node2.height) {
    return append(node1, node2);
  } else {
    return prepend(node2, node1);
  }
}

/// 1:1: `export class TokenStore implements IDisposable`.
class TokenStore implements IDisposable {
  Node? _root;

  Node get root => _root!;

  final ITextModelForTokenStore _textModel;

  TokenStore(this._textModel) {
    _root = createEmptyRoot();
  }

  Node createEmptyRoot() {
    return LeafNode(_textModel.getValueLength(), 0, TokenQuality.None);
  }

  /// @param update all the tokens for the document in sequence
  void buildStore(List<TokenUpdate> tokens, int tokenQuality) {
    _root = createFromUpdates(tokens, tokenQuality);
  }

  Node createFromUpdates(List<TokenUpdate> tokens, int tokenQuality) {
    if (tokens.isEmpty) {
      return createEmptyRoot();
    }
    Node newRoot = LeafNode(tokens[0].length, tokens[0].token, tokenQuality);
    for (int j = 1; j < tokens.length; j++) {
      newRoot = append(
          newRoot, LeafNode(tokens[j].length, tokens[j].token, tokenQuality));
    }
    return newRoot;
  }

  /// @param tokens tokens are in sequence in the document.
  void update(int length, List<TokenUpdate> tokens, int tokenQuality) {
    if (tokens.isEmpty) {
      return;
    }
    replace(length, tokens[0].startOffsetInclusive, tokens, tokenQuality);
  }

  void delete(int length, int startOffset) {
    replace(length, startOffset, <TokenUpdate>[], TokenQuality.EditGuess);
  }

  /// @param tokens tokens are in sequence in the document.
  void replace(int length, int updateOffsetStart, List<TokenUpdate> tokens,
      int tokenQuality) {
    final int firstUnchangedOffsetAfterUpdate = updateOffsetStart + length;
    // Find the last unchanged node preceding the update
    final List<Node> precedingNodes = <Node>[];
    // Find the first unchanged node after the update
    final List<Node> postcedingNodes = <Node>[];
    final List<(Node, int)> stack = <(Node, int)>[];
    stack.add((_root!, 0));

    while (stack.isNotEmpty) {
      final (Node, int) entry = stack.removeLast();
      final Node node = entry.$1;
      final int currentOffset = entry.$2;

      if (currentOffset < updateOffsetStart &&
          currentOffset + node.length <= updateOffsetStart) {
        if (!isLeaf(node)) {
          node.parent = null;
        }
        precedingNodes.add(node);
        continue;
      } else if (isLeaf(node) && (currentOffset < updateOffsetStart)) {
        // We have a partial preceding node
        precedingNodes.add(LeafNode(updateOffsetStart - currentOffset,
            (node as LeafNode).token, node.tokenQuality));
        // Node could also be postceeding, so don't continue
      }

      if ((updateOffsetStart <= currentOffset) &&
          (currentOffset + node.length <= firstUnchangedOffsetAfterUpdate)) {
        continue;
      }

      if (currentOffset >= firstUnchangedOffsetAfterUpdate) {
        if (!isLeaf(node)) {
          node.parent = null;
        }
        postcedingNodes.add(node);
        continue;
      } else if (isLeaf(node) &&
          (currentOffset + node.length > firstUnchangedOffsetAfterUpdate)) {
        // we have a partial postceeding node
        postcedingNodes.add(LeafNode(
            currentOffset + node.length - firstUnchangedOffsetAfterUpdate,
            (node as LeafNode).token,
            node.tokenQuality));
        continue;
      }

      if (!isLeaf(node)) {
        // Push children in reverse order to process them left-to-right
        // when popping
        int childOffset = currentOffset + node.length;
        final ListNode listNode = node as ListNode;
        for (int i = listNode.children.length - 1; i >= 0; i--) {
          childOffset -= listNode.children[i].length;
          stack.add((listNode.children[i], childOffset));
        }
      }
    }

    late List<Node> allNodes;
    if (tokens.isNotEmpty) {
      // JS `Array.concat(node)` appends a single element, not its children.
      allNodes = <Node>[
        ...precedingNodes,
        createFromUpdates(tokens, tokenQuality),
        ...postcedingNodes,
      ];
    } else {
      allNodes = <Node>[...precedingNodes, ...postcedingNodes];
    }
    Node? newRoot;
    if (allNodes.isNotEmpty) {
      Node current = allNodes[0];
      for (int i = 1; i < allNodes.length; i++) {
        current = concat(current, allNodes[i]);
      }
      newRoot = current;
    }

    _root = newRoot ?? createEmptyRoot();
  }

  /// @param visitor Return true from visitor to exit early
  void traverseInOrderInRange(int startOffsetInclusive, int endOffsetExclusive,
      bool Function(Node node, int offset) visitor) {
    final List<(Node, int)> stack = <(Node, int)>[];
    stack.add((_root!, 0));

    while (stack.isNotEmpty) {
      final (Node, int) entry = stack.removeLast();
      final Node node = entry.$1;
      final int offset = entry.$2;
      final int nodeEnd = offset + node.length;

      // Skip nodes that are completely before or after the range
      if (nodeEnd <= startOffsetInclusive || offset >= endOffsetExclusive) {
        continue;
      }

      if (visitor(node, offset)) {
        return;
      }

      if (!isLeaf(node)) {
        // Push children in reverse order to process them left-to-right
        // when popping
        final ListNode listNode = node as ListNode;
        int childOffset = offset + node.length;
        for (int i = listNode.children.length - 1; i >= 0; i--) {
          childOffset -= listNode.children[i].length;
          stack.add((listNode.children[i], childOffset));
        }
      }
    }
  }

  TokenUpdate? getTokenAt(int offset) {
    TokenUpdate? result;
    traverseInOrderInRange(offset, _root!.length, (Node node, int nodeOffset) {
      if (isLeaf(node)) {
        final LeafNode leaf = node as LeafNode;
        result = TokenUpdate(nodeOffset, leaf.length, leaf.token);
        return true;
      }
      return false;
    });
    return result;
  }

  List<TokenUpdate> getTokensInRange(
      int startOffsetInclusive, int endOffsetExclusive) {
    final List<TokenUpdate> result = <TokenUpdate>[];
    traverseInOrderInRange(startOffsetInclusive, endOffsetExclusive,
        (Node node, int offset) {
      if (isLeaf(node)) {
        final LeafNode leaf = node as LeafNode;
        int clippedLength = leaf.length;
        int clippedOffset = offset;
        if ((offset < startOffsetInclusive) &&
            (offset + leaf.length > endOffsetExclusive)) {
          clippedOffset = startOffsetInclusive;
          clippedLength = endOffsetExclusive - startOffsetInclusive;
        } else if (offset < startOffsetInclusive) {
          clippedLength -= (startOffsetInclusive - offset);
          clippedOffset = startOffsetInclusive;
        } else if (offset + leaf.length > endOffsetExclusive) {
          clippedLength -= (offset + leaf.length - endOffsetExclusive);
        }
        result.add(TokenUpdate(clippedOffset, clippedLength, leaf.token));
      }
      return false;
    });
    return result;
  }

  void markForRefresh(int startOffsetInclusive, int endOffsetExclusive) {
    traverseInOrderInRange(startOffsetInclusive, endOffsetExclusive,
        (Node node, int offset) {
      if (isLeaf(node)) {
        (node as LeafNode).tokenQuality = TokenQuality.None;
      }
      return false;
    });
  }

  bool rangeHasTokens(int startOffsetInclusive, int endOffsetExclusive,
      int minimumTokenQuality) {
    bool hasAny = true;
    traverseInOrderInRange(startOffsetInclusive, endOffsetExclusive,
        (Node node, int offset) {
      if (isLeaf(node) &&
          (node as LeafNode).tokenQuality < minimumTokenQuality) {
        hasAny = false;
      }
      return false;
    });
    return hasAny;
  }

  bool rangeNeedsRefresh(int startOffsetInclusive, int endOffsetExclusive) {
    bool needsRefresh = false;
    traverseInOrderInRange(startOffsetInclusive, endOffsetExclusive,
        (Node node, int offset) {
      if (isLeaf(node) &&
          (node as LeafNode).tokenQuality != TokenQuality.Accurate) {
        needsRefresh = true;
      }
      return false;
    });
    return needsRefresh;
  }

  List<Map<String, int>> getNeedsRefresh() {
    final List<Map<String, int>> result = <Map<String, int>>[];

    traverseInOrderInRange(0, _textModel.getValueLength(),
        (Node node, int offset) {
      if (isLeaf(node) &&
          (node as LeafNode).tokenQuality != TokenQuality.Accurate) {
        if ((result.isNotEmpty) &&
            (result[result.length - 1]['endOffset'] == offset)) {
          result[result.length - 1]['endOffset'] =
              result[result.length - 1]['endOffset']! + node.length;
        } else {
          result.add(<String, int>{
            'startOffset': offset,
            'endOffset': offset + node.length,
          });
        }
      }
      return false;
    });
    return result;
  }

  /// 1:1: `public deepCopy()`
  TokenStore deepCopy() {
    final TokenStore newStore = TokenStore(_textModel);
    newStore._root = _copyNodeIterative(_root!);
    return newStore;
  }

  Node _copyNodeIterative(Node root) {
    final Node newRoot = isLeaf(root)
        ? LeafNode(root.length, (root as LeafNode).token,
            root.tokenQuality)
        : ListNode(root.height);

    final List<(Node, Node)> stack = <(Node, Node)>[(root, newRoot)];

    while (stack.isNotEmpty) {
      final (Node, Node) entry = stack.removeLast();
      final Node oldNode = entry.$1;
      final Node clonedNode = entry.$2;
      if (!isLeaf(oldNode)) {
        final ListNode oldList = oldNode as ListNode;
        final ListNode clonedList = clonedNode as ListNode;
        for (final Node child in oldList.children) {
          final Node childCopy = isLeaf(child)
              ? LeafNode(child.length, (child as LeafNode).token,
                  child.tokenQuality)
              : ListNode(child.height);

          clonedList.appendChild(childCopy);
          stack.add((child, childCopy));
        }
      }
    }

    return newRoot;
  }

  /// Returns a string representation of the token tree (iterative).
  String printTree([Node? root]) {
    final Node actualRoot = root ?? _root!;
    final List<String> result = <String>[];
    final List<(Node, int)> stack = <(Node, int)>[];
    stack.add((actualRoot, 0));

    while (stack.isNotEmpty) {
      final (Node, int) entry = stack.removeLast();
      final Node node = entry.$1;
      final int depth = entry.$2;
      final String indent = '  ' * depth;

      if (isLeaf(node)) {
        final LeafNode leaf = node as LeafNode;
        result.add('${indent}Leaf(length: ${leaf.length}, token: ${leaf.token}, refresh: ${leaf.tokenQuality})\n');
      } else {
        final ListNode listNode = node as ListNode;
        result.add('${indent}List(length: ${listNode.length})\n');
        // Push children in reverse order so they get processed left-to-right
        for (int i = listNode.children.length - 1; i >= 0; i--) {
          stack.add((listNode.children[i], depth + 1));
        }
      }
    }

    return result.join('');
  }

  @override
  void dispose() {
    final List<(Node, bool)> stack = <(Node, bool)>[];
    stack.add((_root!, false));
    while (stack.isNotEmpty) {
      final (Node, bool) entry = stack.removeLast();
      final Node node = entry.$1;
      final bool visited = entry.$2;
      if (isLeaf(node)) {
        // leaf node does not need to be disposed
      } else if (!visited) {
        stack.add((node, true));
        final ListNode listNode = node as ListNode;
        for (int i = listNode.children.length - 1; i >= 0; i--) {
          stack.add((listNode.children[i], false));
        }
      } else {
        (node as ListNode).dispose();
        node.parent = null;
      }
    }
    _root = null;
  }
}
