// ---------------------------------------------------------------------------
// Port of vscode/src/vs/editor/browser/viewParts/blockDecorations/
//   blockDecorations.ts
// Translated 1:1. Structure, members and semantics preserved.
// Verified against the TypeScript transpile truth (batch437).
//
// Adaptations: DOM nodes / createFastDomNode / document and ViewContext /
// RenderingContext are narrow carriers so the part can be replayed.
// ---------------------------------------------------------------------------

import '../../view/renderingContext.dart'
    show RenderingContext, RestrictedRenderingContext;
import '../../../common/config/editorOptions.dart' show EditorOption;
import '../../../common/core/range.dart' show Range;
import '../../../common/viewEventHandler.dart' show ViewEventHandler;

/// 1:1: `FastDomNode` subset used here (opaque carrier).
abstract class IBlockNode {
  void setAttribute(String name, String value);
  void setClassName(String className);
  void appendChild(IBlockNode child);
  void setLeft(Object left);
  void setWidth(Object width);
  void setTop(Object top);
  void setHeight(Object height);
  void remove();
}

/// Environment for DOM creation.
class BlockDecorationsEnvironment {
  final IBlockNode Function() createNode;
  BlockDecorationsEnvironment(this.createNode);
}

/// 1:1: `BlockDecorations extends ViewPart` (port uses [ViewEventHandler] base;
/// same base adaptation as scrollDecoration/margin).
class BlockDecorations extends ViewEventHandler {
  final IBlockNode domNode;
  final List<IBlockNode> blocks = <IBlockNode>[];
  final BlockDecorationsEnvironment _env;
  final Object _context;

  num contentWidth = -1;
  num contentLeft = 0;

  BlockDecorations(this._context, BlockDecorationsEnvironment env)
      : _env = env,
        domNode = env.createNode() {
    domNode.setAttribute('role', 'presentation');
    domNode.setAttribute('aria-hidden', 'true');
    domNode.setClassName('blockDecorations-container');
    update();
  }

  bool update() {
    bool didChange = false;
    final dynamic options = (_context as dynamic).configuration.options;
    final dynamic layoutInfo = options.get(EditorOption.layoutInfo);
    Object liField(String name) => layoutInfo is Map
        ? layoutInfo[name] as Object
        : layoutInfo.$name as Object;
    final num newContentWidth =
        (liField('contentWidth') as num) - (liField('verticalScrollbarWidth') as num);
    if (contentWidth != newContentWidth) {
      contentWidth = newContentWidth;
      didChange = true;
    }
    final num newContentLeft = liField('contentLeft') as num;
    if (contentLeft != newContentLeft) {
      contentLeft = newContentLeft;
      didChange = true;
    }
    return didChange;
  }

  @override
  bool onConfigurationChanged(Object e) => update();

  @override
  bool onScrollChanged(Object e) {
    final dynamic ev = e;
    if (ev is Map) {
      return ev['scrollTopChanged'] == true || ev['scrollLeftChanged'] == true;
    }
    return ev.scrollTopChanged as bool || ev.scrollLeftChanged as bool;
  }

  @override
  bool onDecorationsChanged(Object e) => true;

  @override
  bool onZonesChanged(Object e) => true;

  void prepareRender(RenderingContext ctx) {
    // Nothing to read
  }

  void render(RestrictedRenderingContext ctx) {
    final dynamic rctx = ctx;
    int count = 0;
    final List<dynamic> decorations =
        (rctx.getDecorationsInViewport() as List).cast<dynamic>();
    final num scrollTop = rctx.scrollTop as num;
    for (final dynamic decoration in decorations) {
      final dynamic options = decoration.options;
      Object? opt(String name) => options is Map
          ? options[name]
          : options.$name as Object?;
      final Object? blockClassName = opt('blockClassName');
      if (blockClassName == null) {
        continue;
      }

      IBlockNode block;
      if (count < blocks.length) {
        block = blocks[count];
      } else {
        block = _env.createNode();
        blocks.add(block);
        domNode.appendChild(block);
      }

      late num top;
      late num bottom;
      final Range range = decoration.range as Range;
      if (opt('blockIsAfterEnd') == true) {
        // range must be empty
        top = rctx.getVerticalOffsetAfterLineNumber(range.endLineNumber, false);
        bottom = rctx.getVerticalOffsetAfterLineNumber(range.endLineNumber, true);
      } else {
        top = rctx.getVerticalOffsetForLineNumber(range.startLineNumber, true);
        bottom = range.isEmpty() && opt('blockDoesNotCollapse') != true
            ? rctx.getVerticalOffsetForLineNumber(range.startLineNumber, false)
            : rctx.getVerticalOffsetAfterLineNumber(range.endLineNumber, true);
      }

      final Object? paddingRaw = opt('blockPadding');
      final List<dynamic> padding = paddingRaw == null
          ? <dynamic>[0, 0, 0, 0]
          : (paddingRaw as List).cast<dynamic>();
      final num paddingTop = (padding[0] as num);
      final num paddingRight = (padding[1] as num);
      final num paddingBottom = (padding[2] as num);
      final num paddingLeft = (padding[3] as num);

      block.setClassName('blockDecorations-block $blockClassName');
      block.setLeft(contentLeft - paddingLeft);
      block.setWidth(contentWidth + paddingLeft + paddingRight);
      block.setTop(top - scrollTop - paddingTop);
      block.setHeight(bottom - top + paddingTop + paddingBottom);

      count++;
    }

    for (int i = count; i < blocks.length; i++) {
      blocks[i].remove();
    }
    blocks.length = count;
  }
}
