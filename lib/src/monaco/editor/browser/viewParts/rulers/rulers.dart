// ---------------------------------------------------------------------------
// Port of vscode/src/vs/editor/browser/viewParts/rulers/rulers.ts
// Translated 1:1 from TypeScript.
//
// Adaptations (documented inline):
//  * DOM nodes / `createFastDomNode` / `document` are used via file-local
//    narrow carriers so the ruler node management can be replayed without a
//    browser. The member surface read matches the TS source.
//  * `ViewContext` / `IEditorConfiguration` are opaque carriers.
//  * JS `number` string interpolation uses `_jsNum` (no trailing `.0`).
// ---------------------------------------------------------------------------

import '../../view/renderingContext.dart' show RestrictedRenderingContext;
import '../../../common/viewEventHandler.dart' show ViewEventHandler;
import '../../../common/config/editorOptions.dart' show EditorOption;

/// 1:1: `FastDomNode` subset used here (opaque carrier).
abstract class IRulerNode {
  void setAttribute(String name, String value);
  void setClassName(String className);
  void setWidth(Object width);
  void setBoxShadow(String boxShadow);
  void setHeight(Object height);
  void setLeft(Object left);
  void appendChild(IRulerNode child);
  void removeChild(IRulerNode child);
}

/// 1:1: `IRulerOption` subset (real type reused; see editorOptions.dart).
abstract class IRulerOptionView {
  num get column;
  Object? get color;
}

/// 1:1: `IEditorConfiguration.options` subset.
abstract class IRulersEditorOptions {
  Object? get(Object id);
}

/// 1:1: `IEditorConfiguration` subset (opaque carrier).
abstract class IRulersConfiguration {
  IRulersEditorOptions get options;
}

/// 1:1: `ViewContext` subset used here (opaque carrier).
abstract class IRulersViewContext {
  IRulersConfiguration get configuration;
  void addEventHandler(ViewEventHandler eventHandler);
  void removeEventHandler(ViewEventHandler eventHandler);
}

/// 1:1: environment for DOM creation (injected for replay).
class RulersEnvironment {
  final IRulerNode Function() createElement;
  final IRulerNode Function(IRulerNode element) createFastDomNode;

  RulersEnvironment({
    required this.createElement,
    required this.createFastDomNode,
  });
}

/// Rulers are vertical lines at certain columns in the editor.
class Rulers extends ViewEventHandler {
  final IRulersViewContext _context;
  final RulersEnvironment _env;

  late final IRulerNode domNode;
  final List<IRulerNode> _renderedRulers = <IRulerNode>[];
  late List<IRulerOptionView> _rulers;
  late num _typicalHalfwidthCharacterWidth;

  Rulers(this._context, [RulersEnvironment? env])
      : _env = env ?? _browserEnvironment {
    domNode = _env.createFastDomNode(_env.createElement());
    domNode.setAttribute('role', 'presentation');
    domNode.setAttribute('aria-hidden', 'true');
    domNode.setClassName('view-rulers');
    final IRulersEditorOptions options = _context.configuration.options;
    _rulers = (options.get(EditorOption.rulers) as List?)?.cast<IRulerOptionView>()
        ?? <IRulerOptionView>[];
    _typicalHalfwidthCharacterWidth = _halfWidthOf(options);
    _context.addEventHandler(this);
  }

  static final RulersEnvironment _browserEnvironment = RulersEnvironment(
    createElement: () => throw UnsupportedError('no browser DOM'),
    createFastDomNode: (IRulerNode node) => node,
  );

  @override
  void dispose() {
    _context.removeEventHandler(this);
    super.dispose();
  }

  // --- begin event handlers

  @override
  bool onConfigurationChanged(Object e) {
    final IRulersEditorOptions options = _context.configuration.options;
    _rulers = (options.get(EditorOption.rulers) as List?)?.cast<IRulerOptionView>()
        ?? <IRulerOptionView>[];
    _typicalHalfwidthCharacterWidth = _halfWidthOf(options);
    return true;
  }

  @override
  bool onScrollChanged(Object e) =>
      e is Map && e['scrollHeightChanged'] == true;

  // --- end event handlers

  void prepareRender(RestrictedRenderingContext ctx) {
    // Nothing to read.
  }

  void _ensureRulersCount() {
    final int currentCount = _renderedRulers.length;
    final int desiredCount = _rulers.length;
    if (currentCount == desiredCount) return;

    if (currentCount < desiredCount) {
      int addCount = desiredCount - currentCount;
      while (addCount > 0) {
        final IRulerNode node = _env.createFastDomNode(_env.createElement());
        node.setClassName('view-ruler');
        node.setWidth('1ch');
        domNode.appendChild(node);
        _renderedRulers.add(node);
        addCount--;
      }
      return;
    }

    int removeCount = currentCount - desiredCount;
    while (removeCount > 0) {
      final IRulerNode node = _renderedRulers.removeLast();
      domNode.removeChild(node);
      removeCount--;
    }
  }

  /// 1:1: `render` (uses a narrow scrollHeight carrier).
  void render(Object ctx) {
    _ensureRulersCount();
    final num scrollHeight = ctx is Map
        ? (ctx['scrollHeight'] as num)
        : (ctx as dynamic).scrollHeight as num;
    for (int i = 0; i < _rulers.length; i++) {
      final IRulerNode node = _renderedRulers[i];
      final IRulerOptionView ruler = _rulers[i];
      final Object? color = ruler.color;
      node.setBoxShadow(color != null
          ? '1px 0 0 0 $color inset'
          : '');
      final num height = scrollHeight < 1000000 ? scrollHeight : 1000000;
      node.setHeight(height);
      node.setLeft(ruler.column * _typicalHalfwidthCharacterWidth);
    }
  }

  /// 1:1: exposed for replay verification.
  List<IRulerNode> get renderedRulers => _renderedRulers;
}

num _halfWidthOf(IRulersEditorOptions options) {
  final Object? fontInfo = options.get(EditorOption.fontInfo);
  if (fontInfo == null) return 0;
  return (fontInfo as dynamic).typicalHalfwidthCharacterWidth as num;
}
