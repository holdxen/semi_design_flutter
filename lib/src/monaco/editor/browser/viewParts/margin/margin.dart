// ---------------------------------------------------------------------------
// Port of vscode/src/vs/editor/browser/viewParts/margin/margin.ts
// Translated 1:1. Structure, members and semantics preserved.
// Verified against the TypeScript transpile truth (batch434).
//
// Adaptations: DOM node / createFastDomNode / document and ViewContext/config
// are narrow carriers so the view part can be replayed without a browser.
// ---------------------------------------------------------------------------

import '../../../common/config/editorOptions.dart' show EditorOption;
import '../../../common/viewEventHandler.dart' show ViewEventHandler;
import '../../view/renderingContext.dart' show RenderingContext;

/// 1:1: `FastDomNode` subset used here (opaque carrier).
abstract class IMarginNode {
  void setClassName(String className);
  void setPosition(String position);
  void setAttribute(String name, String value);
  void setLayerHinting(bool enabled);
  void setContain(String contain);
  void setTop(Object top);
  void setHeight(Object height);
  void setWidth(Object width);
  void setLeft(Object left);
  void appendChild(IMarginNode child);
}

/// Environment for DOM creation.
class MarginEnvironment {
  final IMarginNode Function() createNode;
  MarginEnvironment(this.createNode);
}

/// 1:1: `Margin extends ViewPart` (port uses [ViewEventHandler] as base; see
/// scrollDecoration.dart for the same base adaptation).
class Margin extends ViewEventHandler {
  static const String className = 'glyph-margin';
  static const String outerClassName = 'margin';

  late final IMarginNode _domNode;
  late final IMarginNode _glyphMarginBackgroundDomNode;
  bool _canUseLayerHinting;
  num _contentLeft;
  num _glyphMarginLeft;
  num _glyphMarginWidth;
  final Object _context;

  Margin(this._context, MarginEnvironment env)
      : _canUseLayerHinting = _readLayerHinting(_context),
        _contentLeft = _readLayout(_context, 'contentLeft'),
        _glyphMarginLeft = _readLayout(_context, 'glyphMarginLeft'),
        _glyphMarginWidth = _readLayout(_context, 'glyphMarginWidth') {
    _domNode = env.createNode();
    _domNode.setClassName(Margin.outerClassName);
    _domNode.setPosition('absolute');
    _domNode.setAttribute('role', 'presentation');
    _domNode.setAttribute('aria-hidden', 'true');

    _glyphMarginBackgroundDomNode = env.createNode();
    _glyphMarginBackgroundDomNode.setClassName(Margin.className);

    _domNode.appendChild(_glyphMarginBackgroundDomNode);
  }

  IMarginNode getDomNode() => _domNode;

  @override
  bool onConfigurationChanged(Object e) {
    _canUseLayerHinting = _readLayerHinting(_context);
    _contentLeft = _readLayout(_context, 'contentLeft');
    _glyphMarginLeft = _readLayout(_context, 'glyphMarginLeft');
    _glyphMarginWidth = _readLayout(_context, 'glyphMarginWidth');
    return true;
  }

  @override
  bool onScrollChanged(Object e) {
    final dynamic ev = e;
    final bool scrollTopChanged = ev is Map
        ? ev['scrollTopChanged'] == true
        : ev.scrollTopChanged as bool;
    return super.onScrollChanged(e) || scrollTopChanged;
  }

  void prepareRender(RenderingContext ctx) {
    // Nothing to read
  }

  void render(Object ctx) {
    final dynamic c = ctx;
    final num scrollTop = _ctxField(c, 'scrollTop');
    final num bigNumbersDelta = _ctxField(c, 'bigNumbersDelta');
    final num scrollHeight = _ctxField(c, 'scrollHeight');
    _domNode.setLayerHinting(_canUseLayerHinting);
    _domNode.setContain('strict');
    final num adjustedScrollTop = scrollTop - bigNumbersDelta;
    _domNode.setTop(-adjustedScrollTop);

    final num height = scrollHeight < 1000000 ? scrollHeight : 1000000;
    _domNode.setHeight(height);
    _domNode.setWidth(_contentLeft);

    _glyphMarginBackgroundDomNode.setLeft(_glyphMarginLeft);
    _glyphMarginBackgroundDomNode.setWidth(_glyphMarginWidth);
    _glyphMarginBackgroundDomNode.setHeight(height);
  }

  // ---- Config carrier helpers ------------------------------------------------

  static Object _getOption(Object context, Object key) {
    final dynamic options = (context as dynamic).configuration.options;
    return options.get(key) as Object;
  }

  static bool _readLayerHinting(Object context) {
    final Object? disable = _getOption(context, EditorOption.disableLayerHinting);
    return !(disable == true);
  }

  static num _readLayout(Object context, String field) {
    final dynamic layoutInfo = _getOption(context, EditorOption.layoutInfo);
    final Object value = layoutInfo is Map
        ? layoutInfo[field] as Object
        : layoutInfo.$field as Object;
    return value as num;
  }

  static num _ctxField(Object ctx, String field) {
    final dynamic c = ctx;
    final Object value = c is Map ? c[field] as Object : c.$field as Object;
    return value as num;
  }
}
