// ---------------------------------------------------------------------------
// Port of vscode/src/vs/editor/browser/viewParts/scrollDecoration/scrollDecoration.ts
// Translated 1:1. Structure, members and semantics preserved.
// Verified against the TypeScript transpile truth (batch433).
//
// Adaptations: DOM node / createFastDomNode / document and ViewContext/config
// are narrow carriers so the view part can be replayed without a browser.
// ---------------------------------------------------------------------------

import '../../../common/config/editorOptions.dart' show EditorOption, RenderMinimap;
import '../../../common/viewEventHandler.dart' show ViewEventHandler;
import '../../view/renderingContext.dart'
    show RestrictedRenderingContext, RenderingContext;

/// 1:1: `FastDomNode` subset used here (opaque carrier).
abstract class IScrollDecorationNode {
  void setAttribute(String name, String value);
  void setClassName(String className);
  void setWidth(Object width);
}

/// Environment for DOM creation (production supplies real fast DOM nodes).
class ScrollDecorationEnvironment {
  final IScrollDecorationNode Function() createNode;
  ScrollDecorationEnvironment(this.createNode);
}

/// 1:1: `ScrollDecorationViewPart extends ViewPart`.
/// The Dart port extends [ViewEventHandler] (the base of ViewPart) because the
/// editor view part base is not separately ported; the event methods and state
/// logic are 1:1 with the source.
class ScrollDecorationViewPart extends ViewEventHandler {
  late final IScrollDecorationNode _domNode;
  int _scrollTop = 0;
  num _width = 0;
  bool _shouldShow = false;
  bool _useShadows;
  final Object _context;

  ScrollDecorationViewPart(this._context, ScrollDecorationEnvironment env)
      : _useShadows = _readUseShadows(_context) {
    _updateWidth();
    _shouldShow = false;
    _domNode = env.createNode();
    _domNode.setAttribute('role', 'presentation');
    _domNode.setAttribute('aria-hidden', 'true');
  }

  IScrollDecorationNode getDomNode() => _domNode;

  bool _updateShouldShow() {
    final bool newShouldShow = _useShadows && _scrollTop > 0;
    if (_shouldShow != newShouldShow) {
      _shouldShow = newShouldShow;
      return true;
    }
    return false;
  }

  void _updateWidth() {
    final Object layoutInfo = _getOption(_context, EditorOption.layoutInfo);
    final dynamic li = layoutInfo;
    // TS reads named fields; replay carriers may be Maps.
    Object field(String name) => li is Map ? li[name] as Object : li.$name as Object;
    final dynamic minimap = field('minimap');
    Object mField(String name) =>
        minimap is Map ? minimap[name] as Object : minimap.$name as Object;
    final int renderMinimap = (mField('renderMinimap') as num).toInt();
    final num minimapWidth = mField('minimapWidth') as num;
    final int minimapLeft = (mField('minimapLeft') as num).toInt();
    if (renderMinimap == RenderMinimap.none ||
        (minimapWidth > 0 && minimapLeft == 0)) {
      _width = field('width') as num;
    } else {
      _width = (field('width') as num) - (field('verticalScrollbarWidth') as num);
    }
  }

  @override
  bool onConfigurationChanged(Object e) {
    _useShadows = _readUseShadows(_context);
    _updateWidth();
    _updateShouldShow();
    return true;
  }

  @override
  bool onScrollChanged(Object e) {
    final dynamic ev = e;
    final Object value = ev is Map ? ev['scrollTop'] as Object : ev.scrollTop as Object;
    _scrollTop = (value as num).toInt();
    return _updateShouldShow();
  }

  void prepareRender(RenderingContext ctx) {
    // Nothing to read
  }

  void render(RestrictedRenderingContext ctx) {
    _domNode.setWidth(_width);
    _domNode.setClassName(_shouldShow ? 'scroll-decoration' : '');
  }

  // ---- Config carrier helpers ------------------------------------------------

  static Object _getOption(Object context, Object key) {
    final dynamic options = (context as dynamic).configuration.options;
    return options.get(key) as Object;
  }

  static bool _readUseShadows(Object context) {
    final dynamic scrollbar = _getOption(context, EditorOption.scrollbar);
    final Object value = scrollbar is Map
        ? scrollbar['useShadows'] as Object
        : scrollbar.useShadows as Object;
    return value as bool;
  }
}
