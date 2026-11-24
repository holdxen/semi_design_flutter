// 1:1 port of vscode/src/vs/base/browser/dom.ts (3127 lines).
// The browser DOM has no Dart equivalent: every DOM interface is represented
// by a concrete carrier below (DomNode/DomElement/DomDocument/DomWindowCarrier/...)
// so the source's control flow can be translated without inventing behaviour.
// See tool/ts2dart/batch93_truth.json for the Node truth driving the tests.
//
// NOTE: this file deliberately keeps all DOM state inside the carriers instead
// of reaching out to dart:html (which is unavailable on the Flutter runtime).

import 'dart:async' show Completer, Future, Timer;
import 'dart:collection' show MapBase;
import 'dart:math' as math;
import 'dart:typed_data' show Int16List, Uint8List;

import '../common/async.dart' as async;
import '../common/errors.dart' show BugIndicatingError, onUnexpectedError;
import '../common/event.dart' as event;
import '../common/hash.dart' show hash;
import '../common/keyCodes.dart' show KeyCode;
import '../common/lifecycle.dart' as lifecycle;
import '../common/network.dart' show RemoteAuthorities;
import '../common/numbers.dart' show isPointWithinTriangle;
import '../common/observable.dart' as observable;
import '../common/observableInternal/observables/derived.dart' show DerivedOpts;
import '../common/platform.dart' as platform;
import '../common/uri.dart' show URI;
import 'browser.dart' as browser;
import 'canIUse.dart' show BrowserFeatures;
import 'fastDomNode.dart' as fdn;
import 'iframe.dart' show IframeElement, IframeLocation, IframeWindow;
import 'keyboardEvent.dart' show KeyboardEvent, StandardKeyboardEvent, hasModifierKeys;
import 'mouseEvent.dart' show MouseEvent, StandardMouseEvent;
import 'window.dart' show CodeWindow, ensureCodeWindow, mainWindow;

// ---------------------------------------------------------------------------
// DOM carriers
// ---------------------------------------------------------------------------

/// 1:1: DOM `EventTarget.addEventListener` option (`useCapture`).
class DomEventListenerOptions {
  final bool capture;
  const DomEventListenerOptions({this.capture = false});
}

class _DomListenerEntry {
  final void Function(DomEvent event) handler;
  final bool capture;
  _DomListenerEntry(this.handler, this.capture);
}

/// 1:1: DOM event carrier. Fields mirror the properties read by dom.ts and by
/// StandardMouseEvent/StandardKeyboardEvent.
class DomEvent implements UIEventLike, EventLike {
  String type;
  Object? target;

  /// 1:1: gesture events carry the original hit target separately from the
  /// retargeted `target` used by sash/touch handling.
  Object? initialTarget;
  @override
  Object? view;
  bool defaultPrevented = false;
  bool cancelBubble = false;
  bool altKey = false;
  bool ctrlKey = false;
  bool shiftKey = false;
  bool metaKey = false;
  bool repeat = false;
  int buttons = 0;
  int button = 0;
  num pageX = 0;
  num pageY = 0;
  num offsetX = 0;
  num offsetY = 0;
  int pointerId = 0;
  String? pointerType;
  int keyCode = 0;
  double timeStamp = 0;
  bool Function(String)? getModifierState;
  void Function()? preventDefaultFn;
  void Function()? stopPropagationFn;

  /// Optional gesture payload attached by the touch recognizer.
  Object? gestureEvent;
  /// Optional touch-event payload carried through DOM dispatch.
  Object? touchEvent;

  DomEvent(this.type, {this.target, this.timeStamp = 0});

  void preventDefault() {
    defaultPrevented = true;
    preventDefaultFn?.call();
  }

  void stopPropagation() {
    cancelBubble = true;
    stopPropagationFn?.call();
  }
}

class DomMouseEvent extends DomEvent {
  @override
  Object? view;
  @override
  int button = 0;
  int detail = 0;
  @override
  num pageX = 0;
  @override
  num pageY = 0;
  DomMouseEvent(String type) : super(type);
}

class DomKeyboardEvent extends DomEvent {
  String code = '';
  String key = '';
  bool isComposing = false;
  DomKeyboardEvent(String type) : super(type);
}

/// 1:1: DOM `DataTransfer` subset used by drag images.
class DomDataTransfer {
  final List<Object?> setDragImageCalls = <Object?>[];
  void setDragImage(DomElement element, int x, int y) =>
      setDragImageCalls.add(<Object?>[element, x, y]);

  /// 1:1: DOM `DataTransfer.types`.
  final List<String> types = <String>[];

  /// 1:1: DOM `DataTransfer.getData` / `setData`. Missing kinds return `''`
  /// exactly like the browser. `dnd.ts` reads and writes drag payloads here.
  final Map<String, String> data = <String, String>{};
  String getData(String kind) =>
      data.containsKey(kind) ? data[kind]! : '';
  void setData(String kind, String value) {
    data[kind] = value;
    if (!types.contains(kind)) types.add(kind);
  }

  /// 1:1: DOM `DataTransfer.files` (nullable: absent until a drag carries
  /// files) and `DataTransfer.items`. Both are read by `dnd.ts`; `items` is
  /// also read by `editor/browser/dataTransfer.ts`.
  List<DomFile?>? files;
  List<DomDataTransferItem?>? items;
}

/// 1:1: DOM `DataTransferItem`: `kind` (`'string' | 'file'`), `type`,
/// `getAsString`, `getAsFile` and `getAsFileSystemHandle`. The DOM delivers
/// strings through a callback, so the carrier mirrors that signature.
class DomDataTransferItem {
  String kind;
  String type;
  void Function(void Function(String value) resolve)? getAsString;
  DomFile? Function()? getAsFile;
  Future<Object?> Function()? getAsFileSystemHandle;

  DomDataTransferItem({this.kind = '', this.type = ''});
}

/// 1:1: DOM `File` subset consumed by dnd.ts (`name`, `size`,
/// `getAsFileSystemHandle`).
class DomFile {
  final String name;
  final int size;

  /// DOM `DataTransferItem.getAsFileSystemHandle()`.
  Future<Object?> Function()? getAsFileSystemHandle;

  /// DOM `File.arrayBuffer()` — the carrier yields the raw bytes.
  Future<List<int>> Function()? arrayBuffer;

  DomFile({required this.name, this.size = 0});
}

/// 1:1: DOM `FileReader` subset used by dnd.ts: `readAsArrayBuffer` plus the
/// `onerror` / `onabort` / `onload` handlers and `result`. The carrier only
/// records the read request; hosts/tests drive the handlers, mirroring how the
/// browser delivers them asynchronously.
class FileReader {
  /// Every reader created, newest last — the browser delivers reads out of
  /// band, so tests/hosts drive [onload]/[onerror]/[onabort] via this list.
  static final List<FileReader> instances = <FileReader>[];

  void Function(Object event)? onerror;
  void Function(Object event)? onabort;
  void Function(Object event)? onload;
  Object? result;
  final List<Object> readAsArrayBufferCalls = <Object>[];
  FileReader() {
    instances.add(this);
  }
  void readAsArrayBuffer(Object file) {
    readAsArrayBufferCalls.add(file);
  }
}

class DomDragEvent extends DomEvent {
  DomDataTransfer? dataTransfer;
  DomDragEvent(String type) : super(type);
}

class DomRect {
  double left, top, right, bottom, width, height;
  DomRect({
    this.left = 0,
    this.top = 0,
    this.right = 0,
    this.bottom = 0,
    this.width = 0,
    this.height = 0,
  });
}

/// Map-backed base for CSSStyleDeclaration carriers (also satisfies the
/// narrower [fdn.DomElement] `style` contract).
abstract class DomStyleBase extends MapBase<String, String> {
  final Map<String, String> properties = <String, String>{};

  @override
  String? operator [](Object? key) => properties[key];

  @override
  void operator []=(String key, String value) => properties[key] = value;

  @override
  void clear() => properties.clear();

  @override
  Iterable<String> get keys => properties.keys;

  @override
  String? remove(Object? key) => properties.remove(key);

  String getPropertyValue(String name);
  void setProperty(String name, Object value);
}

/// 1:1: DOM `Animation` / `CSSAnimation` carriers.
class DomAnimation {
  String animationName;
  bool finished = false;
  DomAnimation(this.animationName);
  void finish() => finished = true;
}

class DomCSSAnimation extends DomAnimation {
  DomCSSAnimation(String animationName) : super(animationName);
}

/// 1:1: DOM `CSSStyleDeclaration` subset: named values + get/setProperty.
class DomStyle extends DomStyleBase {
  String cssText = '';

  @override
  String getPropertyValue(String name) => properties[name] ?? '';

  @override
  void setProperty(String name, Object value) {
    properties[name] = value.toString();
    _syncCssText();
  }

  void _syncCssText() {
    final List<String> parts = <String>[];
    properties.forEach((String k, String v) => parts.add('$k: $v;'));
    cssText = parts.join(' ');
  }
}

/// 1:1: DOM `DOMTokenList` (classList) subset.
class DomTokenListImpl implements fdn.DomTokenList {
  final DomElement _element;
  final Set<String> _tokens = <String>{};

  DomTokenListImpl(this._element);

  bool contains(String token) => _tokens.contains(token);
  void add(String token) { _tokens.add(token); _sync(); }
  void remove(String token) { _tokens.remove(token); _sync(); }

  @override
  void toggle(String token, [bool? force]) {
    final bool has = _tokens.contains(token);
    final bool on = force ?? !has;
    if (on) { _tokens.add(token); } else { _tokens.remove(token); }
    _sync();
  }

  void _sync() => _element.className = _tokens.join(' ');
  List<String> toList() => _tokens.toList();
}

/// 1:1: DOM `Node` subset used by dom.ts.
class DomNode {
  static const int ELEMENT_NODE = 1;
  static const int TEXT_NODE = 3;
  static const int DOCUMENT_NODE = 9;
  static const int DOCUMENT_FRAGMENT_NODE = 11;

  int nodeType;
  DomNode? parentNode;
  DomDocument? ownerDocument;
  final List<DomNode> childNodes = <DomNode>[];
  final Map<String, List<_DomListenerEntry>> _listeners =
      <String, List<_DomListenerEntry>>{};

  DomNode([this.nodeType = ELEMENT_NODE]);

  DomNode? get firstChild => childNodes.isEmpty ? null : childNodes.first;
  DomNode? get nextSibling {
    if (parentNode == null) return null;
    final int i = parentNode!.childNodes.indexOf(this);
    if (i < 0 || i + 1 >= parentNode!.childNodes.length) return null;
    return parentNode!.childNodes[i + 1];
  }
  DomElement? get parentElement => parentNode is DomElement ? parentNode as DomElement : null;

  void appendChild(DomNode child) {
    if (child.parentNode != null) child.parentNode!.removeChild(child);
    child.parentNode = this;
    child.ownerDocument ??= ownerDocument;
    childNodes.add(child);
    if (child is DomElement && child.localName == 'style' && child.sheet != null) {
      final DomDocument? doc = child.ownerDocument ?? ownerDocument;
      if (doc != null && !doc.styleSheets.contains(child.sheet)) {
        doc.styleSheets.add(child.sheet!);
      }
    }
  }

  /// 1:1: `parent.append(...children)` — strings become text nodes.
  void append(Object child) {
    if (child is String) {
      appendChild(DomTextNode(child)..ownerDocument = ownerDocument);
    } else {
      appendChild(child as DomNode);
    }
  }

  void appendAll(List<Object> children) => children.forEach(append);

  void insertBefore(DomNode child, DomNode? reference) {
    if (child.parentNode != null) child.parentNode!.removeChild(child);
    child.parentNode = this;
    child.ownerDocument ??= ownerDocument;
    final int index = reference == null ? -1 : childNodes.indexOf(reference);
    if (index < 0) { childNodes.add(child); } else { childNodes.insert(index, child); }
  }

  void removeChild(DomNode child) {
    childNodes.remove(child);
    child.parentNode = null;
    if (child is DomElement && child.localName == 'style' && child.sheet != null) {
      final DomDocument? doc = child.ownerDocument ?? ownerDocument;
      doc?.styleSheets.remove(child.sheet);
    }
  }

  void remove() => parentNode?.removeChild(this);

  void replaceChildren(List<DomNode> children) {
    childNodes.toList().forEach((DomNode c) => removeChild(c));
    children.forEach(appendChild);
  }

  DomNode cloneNode() {
    final DomNode copy = DomNode(nodeType)
      ..ownerDocument = ownerDocument;
    return copy;
  }

  bool contains(DomNode? other) {
    if (other == null) return false;
    if (identical(other, this)) return true;
    return childNodes.any((DomNode c) => c.contains(other));
  }

  DomNode getRootNode() {
    DomNode node = this;
    while (node.parentNode != null) node = node.parentNode!;
    return node;
  }

  void addEventListener(String type, void Function(DomEvent e) handler,
      [Object? options]) {
    final bool capture = options is bool
        ? options
        : options is DomEventListenerOptions ? options.capture : false;
    final list = _listeners.putIfAbsent(type, () => <_DomListenerEntry>[]);
    list.add(_DomListenerEntry(handler, capture));
  }

  void removeEventListener(String type, void Function(DomEvent e) handler,
      [Object? options]) {
    final list = _listeners[type];
    if (list == null) return;
    list.removeWhere((_DomListenerEntry e) => identical(e.handler, handler));
  }

  void dispatchEvent(String type, DomEvent event) {
    (_listeners[type] ?? <_DomListenerEntry>[])
        .toList()
        .forEach((_DomListenerEntry e) => e.handler(event));
  }
}

class DomTextNode extends DomNode {
  String data;
  DomTextNode(this.data) : super(DomNode.TEXT_NODE);
  String get textContent => data;
  set textContent(String value) => data = value;

  @override
  DomTextNode cloneNode() => DomTextNode(data)..ownerDocument = ownerDocument;
}

class DomShadowRoot extends DomNode {
  final DomElement host;
  final String mode = 'open';
  DomElement? activeElement;
  DomShadowRoot(this.host) : super(DomNode.DOCUMENT_FRAGMENT_NODE);
}

/// 1:1: DOM `Element`/`HTMLElement` subset. Implements the narrower
/// [fdn.DomElement] carrier so FastDomNode and dom.dart share elements.
class DomElement extends DomNode {
  String tagName;
  String localName;

  /// 1:1: `HTMLStyleElement.type` / `.media`.
  String type = '';
  String media = '';
  DomStyleSheet? sheet;
  String namespaceURI;
  String id = '';
  String _className = '';
  late final DomTokenListImpl classList;
  @override
  late final DomStyle style;
  final Map<String, String> dataset = <String, String>{};
  final Map<String, String> _attributes = <String, String>{};
  final Map<String, Object?> eventHandlers = <String, Object?>{};

  int tabIndex = 0;
  int scrollTop = 0;
  int scrollLeft = 0;
  int clientWidth = 0;
  int clientHeight = 0;
  int scrollWidth = 0;
  int scrollHeight = 0;
  int offsetWidth = 0;
  int offsetHeight = 0;
  int offsetTop = 0;
  int offsetLeft = 0;
  bool hidden = false;

  /// 1:1: `HTMLButtonElement.disabled` (and the shared DOM carrier field used
  /// by button-like elements). Kept as a property rather than an attribute so
  /// callers observe the same state as browser DOM code.
  bool disabled = false;
  bool editContext = false;
  DomRect? rect;
  DomStyle? computedStyle;
  DomShadowRoot? shadowRoot;

  /// 1:1 DOM `element.getClientRects()`. Defaults to a single rect seeded from
  /// [rect] (or zeros), overridable in tests via [clientRectsOverride].
  List<DomRect>? clientRectsOverride;
  List<DomRect> getClientRects() =>
      clientRectsOverride ?? <DomRect>[rect ?? DomRect()];

  /// 1:1: DOM `element.getAnimations()`.
  final List<DomAnimation> animations = <DomAnimation>[];
  List<DomAnimation> getAnimations() => animations;

  /// 1:1: `Element.setPointerCapture` / `releasePointerCapture`.
  final Set<int> pointerCaptures = <int>{};
  bool failSetPointerCapture = false;
  bool failReleasePointerCapture = false;

  void setPointerCapture(int pointerId) {
    if (failSetPointerCapture) {
      throw StateError('Failed to execute setPointerCapture');
    }
    pointerCaptures.add(pointerId);
  }

  void releasePointerCapture(int pointerId) {
    if (failReleasePointerCapture || !pointerCaptures.remove(pointerId)) {
      throw StateError('No active pointer with the given id');
    }
  }

  DomElement(this.tagName, [this.namespaceURI = 'http://www.w3.org/1999/xhtml'])
      : localName = tagName.toLowerCase(),
        super(DomNode.ELEMENT_NODE) {
    classList = DomTokenListImpl(this);
    style = DomStyle();
  }

  @override
  String get className => _className;

  @override
  set className(String value) {
    _className = value;
    classList._tokens
      ..clear()
      ..addAll(value.split(RegExp(r'\s+')).where((String s) => s.isNotEmpty));
  }

  @override
  void focus() {
    if (ownerDocument != null) ownerDocument!.activeElement = this;
  }

  @override
  void setAttribute(String name, String value) {
    _attributes[name] = value;
    if (name == 'class') className = value;
  }

  @override
  void removeAttribute(String name) {
    _attributes.remove(name);
    if (name == 'class') className = '';
  }

  /// 1:1: `HTMLAnchorElement.href`. Reflected onto the `href` attribute so the
  /// property and the attribute stay consistent (same treatment as [id]).
  String get href => _attributes['href'] ?? '';
  set href(String value) => setAttribute('href', value);

  String? getAttribute(String name) => _attributes[name];
  bool hasAttribute(String name) => _attributes.containsKey(name);
  List<MapEntry<String, String>> get attributes => _attributes.entries.toList();

  DomRect getBoundingClientRect() => rect ?? DomRect();

  String get textContent {
    final buffer = StringBuffer();
    void walk(DomNode node) {
      if (node is DomTextNode) {
        buffer.write(node.data);
      }
      node.childNodes.forEach(walk);
    }
    walk(this);
    return buffer.toString();
  }

  set textContent(String value) {
    childNodes.toList().forEach((DomNode c) => removeChild(c));
    if (value.isNotEmpty) appendChild(DomTextNode(value));
    if (domParseStyleTextContent && localName == 'style' && sheet != null) {
      _parseStyleSheetText(value);
    }
  }

  /// Browser-like `HTMLStyleElement.textContent` → `sheet.cssRules` parsing.
  /// Only the simple rule subset used by monaco's CSS extractor is needed.
  void _parseStyleSheetText(String css) {
    sheet!.cssRules.clear();
    for (final RegExpMatch match
        in RegExp(r'([^{}]+)\{([^{}]*)\}').allMatches(css)) {
      final String selectorText = match.group(1)!.trim();
      final String body = match.group(2)!;
      final String cssText = css.substring(match.start, match.end).trim();
      final DomCSSStyleRule rule = DomCSSStyleRule(selectorText, cssText);
      for (final String declaration in body.split(';')) {
        final int colon = declaration.indexOf(':');
        if (colon == -1) continue;
        final String name = declaration.substring(0, colon).trim();
        final String value = declaration.substring(colon + 1).trim();
        if (name.isNotEmpty) rule.style.setProperty(name, value);
      }
      sheet!.cssRules.add(rule);
    }
  }

  @override
  DomElement cloneNode() {
    final DomElement copy = DomElement(tagName, namespaceURI)
      ..ownerDocument = ownerDocument
      ..id = id
      ..className = className
      ..tabIndex = tabIndex
      ..type = type
      ..media = media
      ..disabled = disabled
      ..textContent = textContent;
    if (copy.localName == 'style') copy.sheet = DomStyleSheet();
    _attributes.forEach(copy.setAttribute);
    dataset.forEach((String k, String v) => copy.dataset[k] = v);
    return copy;
  }

  @override
  void appendChild(DomNode child) => super.appendChild(child);

  void click() => dispatchEvent(EventType.CLICK, DomEvent(EventType.CLICK, target: this));
}

/// 1:1: DOM `CSSRule` subset used by stylesheet helpers.
class DomCSSRule {
  String cssText;

  /// 1:1: `CSSStyleRule.selectorText` override. When null it is parsed from
  /// [cssText], preserving the behaviour used by domStylesheets.ts.
  String? selectorTextOverride;

  /// 1:1: `CSSImportRule.styleSheet` / nested `CSSStyleRule.cssRules`.
  DomStyleSheet? ruleStyleSheet;
  List<DomCSSRule>? nestedRules;

  /// 1:1: `CSSStyleRule.style` (declarations parsed from cssText).
  final DomStyle style = DomStyle();

  DomCSSRule(this.cssText);

  String? get selectorText {
    if (selectorTextOverride != null) return selectorTextOverride;
    final RegExpMatch? m = RegExp(r'^\s*([^{}]+)\s*\{').firstMatch(cssText);
    return m == null ? null : m.group(1)!.trim();
  }

  DomStyleSheet? get styleSheet => ruleStyleSheet;
  List<DomCSSRule>? get cssRules => nestedRules;

  bool get isCSSImportRule => false;
  bool get isCSSStyleRule => false;
}

/// 1:1: DOM `CSSImportRule`.
class DomCSSImportRule extends DomCSSRule {
  DomCSSImportRule([String cssText = '@import url(styles.css);'])
      : super(cssText);

  @override
  DomStyleSheet? get styleSheet => ruleStyleSheet;

  @override
  bool get isCSSImportRule => true;
}

/// 1:1: DOM `CSSStyleRule`.
class DomCSSStyleRule extends DomCSSRule {
  DomCSSStyleRule(String selectorText, [String cssText = ''])
      : super(cssText.isEmpty ? '$selectorText { }' : cssText) {
    selectorTextOverride = selectorText;
  }

  @override
  List<DomCSSRule>? get cssRules => nestedRules;

  @override
  bool get isCSSStyleRule => true;
}

/// 1:1: DOM `CSSStyleSheet` subset.
class DomStyleSheet {
  final List<DomCSSRule> cssRules = <DomCSSRule>[];

  int insertRule(String text, [int? index]) {
    final int at = index ?? cssRules.length;
    cssRules.insert(at, DomCSSRule(text));
    return at;
  }

  void deleteRule(int index) => cssRules.removeAt(index);
}

/// Opt-in bridge: real browsers populate `HTMLStyleElement.sheet.cssRules`
/// when `textContent` is assigned. Monaco's CSS extractor relies on it; other
/// ported modules use their own fake DOM semantics, so this stays off by
/// default and is enabled only by the extractor truth tests.
bool domParseStyleTextContent = false;

class DomDocument extends DomNode {
  DomElement head;
  DomElement body;
  DomElement documentElement;
  DomElement? activeElement;
  String readyState = 'complete';
  DomElement? fullscreenElement;
  DomElement? webkitFullscreenElement;
  bool webkitIsFullScreen = false;
  String cookie = '';
  String title = '';

  /// 1:1: `HTMLStyleElement.sheet`.
  DomStyleSheet? sheet;

  /// 1:1: `Document.styleSheets`.
  final List<DomStyleSheet> styleSheets = <DomStyleSheet>[];

  CodeWindow? defaultView;
  DomShadowRoot? shadowRoot;

  DomDocument()
      : head = DomElement('head'),
        body = DomElement('body'),
        documentElement = DomElement('html'),
        super(DomNode.DOCUMENT_NODE) {
    head.ownerDocument = this;
    body.ownerDocument = this;
    documentElement.ownerDocument = this;
    appendChild(documentElement);
  }

  DomElement createElement(String tag) {
    final DomElement e = DomElement(tag.toUpperCase());
    e.ownerDocument = this;
    if (tag == 'style') e.sheet = DomStyleSheet();
    return e;
  }

  DomElement createElementNS(String ns, String tag) {
    final DomElement e = DomElement(tag, ns);
    e.ownerDocument = this;
    return e;
  }

  DomTextNode createTextNode(String data) =>
      DomTextNode(data)..ownerDocument = this;

  bool hasFocus() => activeElement != null;

  DomElement? getElementById(String id) {
    DomElement? walk(DomNode n) {
      if (n is DomElement && n.id == id) return n;
      for (final DomNode c in n.childNodes) {
        final DomElement? r = walk(c);
        if (r != null) return r;
      }
      return null;
    }
    return walk(documentElement) ?? walk(head) ?? walk(body);
  }
}

/// 1:1: `Window` carrier next to [CodeWindow]. dom.ts uses several window
/// fields (document, devicePixelRatio, rAF, ...); they live here instead of
/// mutating the window.ts carrier, and are injectable for tests.
class DomWindowCarrier {
  final CodeWindow codeWindow;
  late DomDocument document;
  double devicePixelRatio = 1;
  int innerWidth = 1024;
  int innerHeight = 768;
  int outerWidth = 1100;
  int outerHeight = 900;
  int screenLeft = 0;
  int screenTop = 0;
  double screenWidth = 1920;
  double screenHeight = 1080;
  num scrollX = 0;
  num scrollY = 0;
  String href = 'https://example.com/';
  DomElement? visualViewport;
  bool closed = false;
  Object? opener;

  /// 1:1: `window.CSSAnimation` constructor identity.
  Type cssAnimation = DomCSSAnimation;

  final List<void Function()> _rafQueue = <void Function()>[];
  final List<MapEntry<String, Object?>> openCalls = <MapEntry<String, Object?>>[];

  DomWindowCarrier(this.codeWindow) {
    document = DomDocument()..defaultView = codeWindow;
  }

  /// 1:1: `targetWindow.requestAnimationFrame(cb)`
  void requestAnimationFrame(void Function() cb) => _rafQueue.add(cb);

  /// Number of queued animation-frame callbacks.
  int get rafCount => _rafQueue.length;

  /// Test/runtime seam that runs queued rAF callbacks (browser frame phase).
  void flushAnimationFrame() {
    final List<void Function()> queue = _rafQueue.toList();
    _rafQueue.clear();
    for (final void Function() cb in queue) { cb(); }
  }

  /// 1:1: `targetWindow.getComputedStyle(el, null)`
  DomStyle getComputedStyle(DomElement el, [DomStyle? fallback]) =>
      el.computedStyle ?? fallback ?? DomStyle();

  /// 1:1: `targetWindow.open(...)`
  CodeWindow? open([String? url, String? target, String? features]) {
    openCalls.add(MapEntry<String, Object?>('$url|$target|$features', <String, Object?>{
      'url': url, 'target': target, 'features': features,
    }));
    return null;
  }

  void close() => closed = true;
}

/// Per-window bridge map (a Dart stand-in for the browser's Window objects).
final Map<CodeWindow, DomWindowCarrier> _domWindows =
    <CodeWindow, DomWindowCarrier>{};

/// 1:1: the DOM `window` object behind a [CodeWindow].
DomWindowCarrier windowCarrier(CodeWindow window) =>
    _domWindows.putIfAbsent(window, () => DomWindowCarrier(window));

/// 1:1: `mainWindow.document` / `document` global bridge.
DomDocument get mainDocument => windowCarrier(mainWindow).document;

DomDocument get document => mainDocument;

/// 1:1: injectable `customElements` registry.
class DomCustomElementsRegistry {
  final Map<String, Type> definitions = <String, Type>{};
  Type? get(String name) => definitions[name];
  void define(String name, Type ctor) => definitions[name] = ctor;
}

final DomCustomElementsRegistry customElements = DomCustomElementsRegistry();

/// 1:1: `ResizeObserver` test seam on the window.
typedef DomResizeObserverCallback = void Function(
    List<DomResizeObserverEntry> entries, DomResizeObserver observer);

class DomResizeObserverEntry {
  final DomElement target;
  DomRect? contentRect;
  DomResizeObserverEntry(this.target, [this.contentRect]);
}

class DomResizeObserver {
  DomResizeObserverCallback callback;
  DomResizeObserver(this.callback);
  final List<DomElement> observed = <DomElement>[];
  void observe(DomElement target, [Object? options]) => observed.add(target);
  void unobserve(DomElement target) => observed.remove(target);
  void disconnect() => observed.clear();
  void deliver(List<DomResizeObserverEntry> entries) => callback(entries, this);
}

class DomMutationRecord {
  final String type;
  final String? attributeName;
  const DomMutationRecord(this.type, [this.attributeName]);
}

class DomMutationObserver {
  final void Function(List<DomMutationRecord> mutations) callback;
  DomMutationObserver(this.callback);
  void observe(DomNode target, [Object? options]) {}
  void disconnect() {}

  /// Test/runtime seam that delivers a mutation batch.
  void deliver([List<DomMutationRecord> mutations = const <DomMutationRecord>[]]) =>
      callback(mutations);
}

class DomIframeWindow implements IframeWindow {
  final num top;
  final num left;
  const DomIframeWindow({this.top = 0, this.left = 0});

  @override
  IframeWindow? get parent => null;

  @override
  IframeLocation get location => const DomIframeLocation();

  @override
  IframeElement? get frameElement => null;

  @override
  num get scrollX => 0;

  @override
  num get scrollY => 0;
}

class DomIframeLocation implements IframeLocation {
  const DomIframeLocation({this.origin = ''});
  @override
  final String origin;
}

/// Injectable iframe-offset bridge used by StandardMouseEvent.
DomIframeWindow Function(CodeWindow window) domIframeWindowProvider =
    (CodeWindow window) => const DomIframeWindow();

// ---------------------------------------------------------------------------
// Multi-window support utilities
// ---------------------------------------------------------------------------

/// 1:1: `interface IRegisteredCodeWindow`
class IRegisteredCodeWindow {
  final CodeWindow window;
  final lifecycle.DisposableStore disposables;
  IRegisteredCodeWindow(this.window, this.disposables);
}

int? lastFocusedWindowId;

final Map<int, IRegisteredCodeWindow> _windows = <int, IRegisteredCodeWindow>{};
final event.Emitter<IRegisteredCodeWindow> _onDidRegisterWindowEmitter =
    event.Emitter<IRegisteredCodeWindow>();
final event.Emitter<CodeWindow> _onDidUnregisterWindowEmitter =
    event.Emitter<CodeWindow>();
final event.Emitter<CodeWindow> _onWillUnregisterWindowEmitter =
    event.Emitter<CodeWindow>();

late final event.Event<IRegisteredCodeWindow> onDidRegisterWindow =
    _onDidRegisterWindowEmitter.event;
late final event.Event<CodeWindow> onDidUnregisterWindow =
    _onDidUnregisterWindowEmitter.event;
late final event.Event<CodeWindow> onWillUnregisterWindow =
    _onWillUnregisterWindowEmitter.event;

bool _windowsInitialized = false;

void _initializeWindows() {
  if (_windowsInitialized) return;
  _windowsInitialized = true;
  ensureCodeWindow(mainWindow, 1);
  final IRegisteredCodeWindow mainRegistration =
      IRegisteredCodeWindow(mainWindow, lifecycle.DisposableStore());
  _windows[mainWindow.vscodeWindowId] = mainRegistration;
  windowCarrier(mainWindow)
      .document
      .addEventListener(EventType.FOCUS, (DomEvent e) {
    lastFocusedWindowId = mainWindow.vscodeWindowId;
  });
}

/// 1:1: `registerWindow(window): IDisposable`
lifecycle.IDisposable registerWindow(CodeWindow window) {
  _initializeWindows();
  final int id = window.vscodeWindowId;
  if (_windows.containsKey(id)) return lifecycle.Disposable.none;

  final lifecycle.DisposableStore disposables = lifecycle.DisposableStore();
  final IRegisteredCodeWindow registeredWindow = IRegisteredCodeWindow(
      window, disposables.add(lifecycle.DisposableStore()));
  _windows[id] = registeredWindow;

  disposables.add(lifecycle.toDisposable(() {
    _windows.remove(id);
    _onDidUnregisterWindowEmitter.fire(window);
  }));
  disposables.add(addDisposableTargetListener(
      window, EventType.BEFORE_UNLOAD, (DomEvent e) {
    _onWillUnregisterWindowEmitter.fire(window);
  }));
  disposables.add(addDisposableTargetListener(
      window, EventType.FOCUS, (DomEvent e) {
    lastFocusedWindowId = id;
  }));
  if (windowCarrier(window).document.hasFocus()) {
    lastFocusedWindowId = id;
  }
  _onDidRegisterWindowEmitter.fire(registeredWindow);
  return disposables;
}

Iterable<IRegisteredCodeWindow> getWindows() {
  _initializeWindows();
  return _windows.values;
}

int getWindowsCount() {
  _initializeWindows();
  return _windows.length;
}

int getWindowId(CodeWindow targetWindow) => targetWindow.vscodeWindowId;

bool hasWindow(int windowId) {
  _initializeWindows();
  return _windows.containsKey(windowId);
}

IRegisteredCodeWindow? getWindowById(int? windowId, [bool fallbackToMain = false]) {
  _initializeWindows();
  final IRegisteredCodeWindow? result =
      windowId == null ? null : _windows[windowId];
  if (result != null) return result;
  return fallbackToMain ? _windows[mainWindow.vscodeWindowId] : null;
}

/// 1:1: `getWindow(e: Node | UIEvent | undefined | null)`
CodeWindow getWindow(Object? e) {
  if (e is DomNode) {
    final DomDocument? doc = e.ownerDocument;
    if (doc?.defaultView != null) return doc!.defaultView!;
  }
  if (e is DomEvent && e.target is DomNode) {
    final DomDocument? doc = (e.target as DomNode).ownerDocument;
    if (doc?.defaultView != null) return doc!.defaultView!;
  }
  // 1:1: `candidateEvent?.view`
  final Object? view = e is UIEventLike ? e.view : null;
  if (view is CodeWindow) return view;
  return mainWindow;
}

/// 1:1: JS `UIEvent.view` structural carrier.
abstract class UIEventLike {
  Object? get view;
}

/// 1:1: `getDocument(e)`
DomDocument getDocument(Object? e) => windowCarrier(getWindow(e)).document;

// ---------------------------------------------------------------------------
// External focus tracking
// ---------------------------------------------------------------------------

/// 1:1: `interface IExternalFocusInfo`
class IExternalFocusInfo {
  final bool hasFocus;
  final CodeWindow? window;
  IExternalFocusInfo(this.hasFocus, [this.window]);
}

typedef ExternalFocusChecker = IExternalFocusInfo Function();

final Set<ExternalFocusChecker> _externalFocusCheckers =
    <ExternalFocusChecker>{};

/// 1:1: `registerExternalFocusChecker`
lifecycle.IDisposable registerExternalFocusChecker(ExternalFocusChecker checker) {
  _externalFocusCheckers.add(checker);
  return lifecycle.toDisposable(() => _externalFocusCheckers.remove(checker));
}

bool hasExternalFocus() {
  for (final ExternalFocusChecker checker in _externalFocusCheckers) {
    if (checker().hasFocus) return true;
  }
  return false;
}

CodeWindow? getExternalFocusWindow() {
  for (final ExternalFocusChecker checker in _externalFocusCheckers) {
    final IExternalFocusInfo info = checker();
    if (info.hasFocus && info.window != null) return info.window;
  }
  return null;
}

bool hasAppFocus() {
  for (final IRegisteredCodeWindow reg in getWindows()) {
    if (windowCarrier(reg.window).document.hasFocus()) return true;
  }
  return hasExternalFocus();
}

// ---------------------------------------------------------------------------
// Event listeners
// ---------------------------------------------------------------------------

/// 1:1: `export function clearNode(node: HTMLElement)`
void clearNode(DomElement node) {
  while (node.firstChild != null) {
    node.firstChild!.remove();
  }
}

/// 1:1: `class DomListener implements IDisposable`
class DomListener implements lifecycle.IDisposable {
  void Function(DomEvent e)? _handler;
  final DomNode _node;
  final String _type;
  final Object? _options;

  DomListener(DomNode node, String type, void Function(DomEvent e) handler,
      [Object? options])
      : _node = node,
        _type = type,
        _handler = handler,
        _options = options {
    _node.addEventListener(_type, _handler!, _options);
  }

  @override
  void dispose() {
    final void Function(DomEvent e)? handler = _handler;
    if (handler == null) return;
    _node.removeEventListener(_type, handler, _options);
    _handler = null;
  }
}

/// 1:1: `addDisposableListener`
lifecycle.IDisposable addDisposableListener(
  DomNode node,
  String type,
  void Function(DomEvent e) handler, [
  Object? useCaptureOrOptions,
]) =>
    DomListener(node, type, handler, useCaptureOrOptions);

/// Listener helper for the source's `EventTarget` union (Node | Window).
lifecycle.IDisposable addDisposableTargetListener(
  Object target,
  String type,
  void Function(DomEvent e) handler, [
  Object? useCaptureOrOptions,
]) {
  if (target is DomNode) {
    return addDisposableListener(target, type, handler, useCaptureOrOptions);
  }
  if (target is CodeWindow) {
    return addDisposableListener(windowCarrier(target).document, type, handler,
        useCaptureOrOptions);
  }
  throw ArgumentError.value(target, 'target', 'Unsupported EventTarget');
}

/// 1:1: `_wrapAsStandardMouseEvent`
void Function(DomEvent e) _wrapAsStandardMouseEvent(
        CodeWindow targetWindow, void Function(Object e) handler) =>
    (DomEvent e) {
      final DomMouseEvent mouseEvent = e is DomMouseEvent
          ? e
          : DomMouseEvent(e.type)
            ..button = 0
            ..pageX = 0
            ..pageY = 0
            ..view = targetWindow;
      mouseEvent.view ??= targetWindow;
      handler(StandardMouseEvent(
        domIframeWindowProvider(targetWindow),
        MouseEvent(
          button: mouseEvent.button,
          buttons: mouseEvent.buttons,
          detail: mouseEvent.detail,
          type: mouseEvent.type,
          target: mouseEvent.target,
          view: domIframeWindowProvider(targetWindow),
          ctrlKey: mouseEvent.ctrlKey,
          shiftKey: mouseEvent.shiftKey,
          altKey: mouseEvent.altKey,
          metaKey: mouseEvent.metaKey,
          defaultPrevented: mouseEvent.defaultPrevented,
          pageX: mouseEvent.pageX,
          pageY: mouseEvent.pageY,
        ),
      ));
    };

/// 1:1: `_wrapAsStandardKeyboardEvent`
void Function(DomEvent e) _wrapAsStandardKeyboardEvent(
        void Function(Object e) handler) =>
    (DomEvent e) {
      final DomKeyboardEvent keyEvent = e is DomKeyboardEvent
          ? e
          : DomKeyboardEvent(e.type);
      handler(StandardKeyboardEvent(KeyboardEvent(
        type: keyEvent.type,
        keyCode: keyEvent.keyCode,
        ctrlKey: keyEvent.ctrlKey,
        shiftKey: keyEvent.shiftKey,
        altKey: keyEvent.altKey,
        metaKey: keyEvent.metaKey,
        code: keyEvent.code,
        key: keyEvent.key,
        isComposing: keyEvent.isComposing,
        target: keyEvent.target,
        getModifierState: keyEvent.getModifierState,
        preventDefaultFn: keyEvent.preventDefaultFn,
        stopPropagationFn: keyEvent.stopPropagationFn,
      )));
    };

/// 1:1: `addStandardDisposableListener`
lifecycle.IDisposable addStandardDisposableListener(
  DomNode node,
  String type,
  void Function(Object e) handler, [
  bool? useCapture,
]) {
  void Function(DomEvent e) wrapHandler = (DomEvent e) => handler(e);
  if (type == EventType.CLICK ||
      type == EventType.MOUSE_DOWN ||
      type == EventType.CONTEXT_MENU) {
    wrapHandler = _wrapAsStandardMouseEvent(getWindow(node), handler);
  } else if (type == EventType.KEY_DOWN ||
      type == EventType.KEY_PRESS ||
      type == EventType.KEY_UP) {
    wrapHandler = _wrapAsStandardKeyboardEvent(handler);
  }
  return addDisposableListener(node, type, wrapHandler, useCapture ?? false);
}

lifecycle.IDisposable addStandardDisposableGenericMouseDownListener(
        DomNode node, void Function(Object e) handler, [bool? useCapture]) =>
    addDisposableGenericMouseDownListener(
        node, _wrapAsStandardMouseEvent(getWindow(node), handler), useCapture);

lifecycle.IDisposable addStandardDisposableGenericMouseUpListener(
        DomNode node, void Function(Object e) handler, [bool? useCapture]) =>
    addDisposableGenericMouseUpListener(
        node, _wrapAsStandardMouseEvent(getWindow(node), handler), useCapture);

lifecycle.IDisposable addDisposableGenericMouseDownListener(
        DomNode node, void Function(DomEvent e) handler, [bool? useCapture]) =>
    addDisposableListener(
        node,
        platform.isIOS && BrowserFeatures.pointerEvents
            ? EventType.POINTER_DOWN
            : EventType.MOUSE_DOWN,
        handler,
        useCapture ?? false);

lifecycle.IDisposable addDisposableGenericMouseMoveListener(
        DomNode node, void Function(DomEvent e) handler, [bool? useCapture]) =>
    addDisposableListener(
        node,
        platform.isIOS && BrowserFeatures.pointerEvents
            ? EventType.POINTER_MOVE
            : EventType.MOUSE_MOVE,
        handler,
        useCapture ?? false);

lifecycle.IDisposable addDisposableGenericMouseUpListener(
        DomNode node, void Function(DomEvent e) handler, [bool? useCapture]) =>
    addDisposableListener(
        node,
        platform.isIOS && BrowserFeatures.pointerEvents
            ? EventType.POINTER_UP
            : EventType.MOUSE_UP,
        handler,
        useCapture ?? false);

/// 1:1: `runWhenWindowIdle`
lifecycle.IDisposable runWhenWindowIdle(
        CodeWindow targetWindow, void Function(async.IdleDeadline idle) callback,
        [int? timeout]) =>
    async.runWhenGlobalIdle(callback, timeout);

/// 1:1: `WindowIdleValue<T> extends AbstractIdleValue<T>`
class WindowIdleValue<T> extends async.AbstractIdleValue<T> {
  WindowIdleValue(CodeWindow targetWindow, T Function() executor)
      : super(targetWindow, executor);
}

/// 1:1: `disposableWindowInterval`
lifecycle.IDisposable disposableWindowInterval(
  CodeWindow targetWindow,
  Object Function() handler,
  int interval, [
  int? iterations,
]) {
  int iteration = 0;
  late final Timer timer;
  late final lifecycle.IDisposable disposable;
  timer = Timer.periodic(Duration(milliseconds: interval), (_) {
    iteration++;
    if ((iterations != null && iteration >= iterations) ||
        identical(handler(), true)) {
      disposable.dispose();
    }
  });
  disposable = lifecycle.toDisposable(() {
    timer.cancel();
  });
  return disposable;
}

/// 1:1: `WindowIntervalTimer extends IntervalTimer`
class WindowIntervalTimer extends async.IntervalTimer {
  final CodeWindow? defaultTarget;
  WindowIntervalTimer([DomNode? node])
      : defaultTarget = node != null ? getWindow(node) : null;

  @override
  void cancelAndSet(void Function() runner, int interval,
      [dynamic targetWindow]) {
    super.cancelAndSet(runner, interval, targetWindow ?? defaultTarget);
  }
}

/// 1:1: `AnimationFrameQueueItem`
class AnimationFrameQueueItem implements lifecycle.IDisposable {
  final void Function() _runner;
  final int priority;
  bool _canceled = false;
  AnimationFrameQueueItem(this._runner, [this.priority = 0]);

  @override
  void dispose() => _canceled = true;

  void execute() {
    if (_canceled) return;
    try { _runner(); } catch (e) { onUnexpectedError(e); }
  }

  /// 1:1: `static sort(a, b) => b.priority - a.priority`
  static int sort(AnimationFrameQueueItem a, AnimationFrameQueueItem b) =>
      b.priority - a.priority;
}

final Map<int, List<AnimationFrameQueueItem>> _nextQueue =
    <int, List<AnimationFrameQueueItem>>{};
final Map<int, List<AnimationFrameQueueItem>> _currentQueue =
    <int, List<AnimationFrameQueueItem>>{};
final Map<int, bool> _animFrameRequested = <int, bool>{};
final Map<int, bool> _inAnimationFrameRunner = <int, bool>{};

bool _animationCleanupRegistered = false;

void _registerAnimationCleanup() {
  if (_animationCleanupRegistered) return;
  _animationCleanupRegistered = true;
  lifecycle.markAsSingleton(onDidUnregisterWindow((dynamic window) {
    final int id = (window as CodeWindow).vscodeWindowId;
    _currentQueue[id]?.clear();
    _nextQueue.remove(id);
    _currentQueue.remove(id);
    _animFrameRequested.remove(id);
    _inAnimationFrameRunner.remove(id);
  }));
}

void _animationFrameRunner(int targetWindowId) {
  if (!_animFrameRequested.containsKey(targetWindowId)) return;
  _animFrameRequested[targetWindowId] = false;
  final List<AnimationFrameQueueItem> current =
      _nextQueue[targetWindowId] ?? <AnimationFrameQueueItem>[];
  _currentQueue[targetWindowId] = current;
  _nextQueue[targetWindowId] = <AnimationFrameQueueItem>[];
  _inAnimationFrameRunner[targetWindowId] = true;
  while (current.isNotEmpty) {
    current.sort(AnimationFrameQueueItem.sort);
    current.removeAt(0).execute();
  }
  if (_inAnimationFrameRunner.containsKey(targetWindowId)) {
    _inAnimationFrameRunner[targetWindowId] = false;
  }
}

/// 1:1: `scheduleAtNextAnimationFrame`
lifecycle.IDisposable scheduleAtNextAnimationFrame(
    CodeWindow targetWindow, void Function() runner, [int priority = 0]) {
  _registerAnimationCleanup();
  final int id = getWindowId(targetWindow);
  final AnimationFrameQueueItem item =
      AnimationFrameQueueItem(runner, priority);
  final List<AnimationFrameQueueItem> next =
      _nextQueue.putIfAbsent(id, () => <AnimationFrameQueueItem>[]);
  next.add(item);
  if (_animFrameRequested[id] != true) {
    _animFrameRequested[id] = true;
    windowCarrier(targetWindow)
        .requestAnimationFrame(() => _animationFrameRunner(id));
  }
  return item;
}

/// 1:1: `runAtThisOrScheduleAtNextAnimationFrame`
lifecycle.IDisposable runAtThisOrScheduleAtNextAnimationFrame(
    CodeWindow targetWindow, void Function() runner, [int priority = 0]) {
  _registerAnimationCleanup();
  final int id = getWindowId(targetWindow);
  if (_inAnimationFrameRunner[id] == true) {
    final AnimationFrameQueueItem item =
        AnimationFrameQueueItem(runner, priority);
    _currentQueue
        .putIfAbsent(id, () => <AnimationFrameQueueItem>[])
        .add(item);
    return item;
  }
  return scheduleAtNextAnimationFrame(targetWindow, runner, priority);
}

/// 1:1: `measure`
lifecycle.IDisposable measure(CodeWindow targetWindow, void Function() callback) =>
    scheduleAtNextAnimationFrame(targetWindow, callback, 10000);

/// 1:1: `modify`
lifecycle.IDisposable modify(CodeWindow targetWindow, void Function() callback) =>
    scheduleAtNextAnimationFrame(targetWindow, callback, -10000);

/// 1:1: `AnimationFrameScheduler`
class AnimationFrameScheduler implements lifecycle.IDisposable {
  final void Function() runner;
  final DomNode node;
  final lifecycle.MutableDisposable<lifecycle.IDisposable> _pendingRunner =
      lifecycle.MutableDisposable<lifecycle.IDisposable>();

  AnimationFrameScheduler(this.node, this.runner);

  @override
  void dispose() => _pendingRunner.dispose();

  void cancel() => _pendingRunner.clear();

  void schedule() {
    if (_pendingRunner.value != null) return;
    _pendingRunner.value = runAtThisOrScheduleAtNextAnimationFrame(
        getWindow(node), () {
      _pendingRunner.clear();
      runner();
    });
  }

  bool isScheduled() => _pendingRunner.value != null;
}

const int MINIMUM_TIME_MS = 8;

/// 1:1: `IEventMerger<R, E>`
typedef IEventMerger<R, E> = R Function(R? lastEvent, E currentEvent);

R _defaultEventMerger<R, E>(R? lastEvent, E currentEvent) => currentEvent as R;

/// 1:1: `TimeoutThrottledDomListener`
class TimeoutThrottledDomListener<R, E extends DomEvent> extends lifecycle.Disposable {
  TimeoutThrottledDomListener(
    DomNode node,
    String type,
    void Function(R event) handler, [
    IEventMerger<R, E>? eventMerger,
    int minimumTimeMs = MINIMUM_TIME_MS,
  ]) {
    R? lastEvent;
    int lastHandlerTime = 0;
    final async.TimeoutTimer timeout = register(async.TimeoutTimer());
    void invokeHandler() {
      lastHandlerTime = DateTime.now().millisecondsSinceEpoch;
      handler(lastEvent as R);
      lastEvent = null;
    }
    register(addDisposableListener(node, type, (DomEvent e) {
      lastEvent = (eventMerger ?? _defaultEventMerger<R, E>)(lastEvent, e as E);
      final int elapsed = DateTime.now().millisecondsSinceEpoch - lastHandlerTime;
      if (elapsed >= minimumTimeMs) {
        timeout.cancel();
        invokeHandler();
      } else {
        timeout.setIfNotSet(invokeHandler, minimumTimeMs - elapsed);
      }
    }));
  }
}

/// 1:1: `addDisposableThrottledListener`
lifecycle.IDisposable addDisposableThrottledListener<R, E extends DomEvent>(
  DomNode node,
  String type,
  void Function(R event) handler, [
  IEventMerger<R, E>? eventMerger,
  int? minimumTimeMs,
]) =>
    TimeoutThrottledDomListener<R, E>(node, type, handler, eventMerger,
        minimumTimeMs ?? MINIMUM_TIME_MS);

// ---------------------------------------------------------------------------
// Computed styles, client area, sizes and positions
// ---------------------------------------------------------------------------

/// 1:1: `getComputedStyle(el)`
DomStyle getComputedStyle(DomElement el) =>
    windowCarrier(getWindow(el)).getComputedStyle(el);

/// 1:1: `getClientArea`
Dimension getClientArea(
  DomElement element, [
  Dimension? defaultValue,
  DomElement? fallbackElement,
]) {
  final CodeWindow elWindow = getWindow(element);
  final DomWindowCarrier wc = windowCarrier(elWindow);
  final DomDocument elDocument = wc.document;

  if (!identical(element, elDocument.body)) {
    return Dimension(element.clientWidth, element.clientHeight);
  }
  if (platform.isIOS && wc.visualViewport != null) {
    return Dimension(wc.visualViewport!.clientWidth, wc.visualViewport!.clientHeight);
  }
  if (wc.innerWidth != 0 && wc.innerHeight != 0) {
    return Dimension(wc.innerWidth, wc.innerHeight);
  }
  if (elDocument.body.clientWidth != 0 && elDocument.body.clientHeight != 0) {
    return Dimension(elDocument.body.clientWidth, elDocument.body.clientHeight);
  }
  if (elDocument.documentElement.clientWidth != 0 &&
      elDocument.documentElement.clientHeight != 0) {
    return Dimension(elDocument.documentElement.clientWidth,
        elDocument.documentElement.clientHeight);
  }
  if (fallbackElement != null) {
    return getClientArea(fallbackElement, defaultValue);
  }
  if (defaultValue != null) return defaultValue;
  throw StateError('Unable to figure out browser width and height');
}

/// JS `parseFloat`: reads the leading numeric prefix (CSS values such as
/// '10px' are valid input), returning 0 when no number is present.
double jsParseFloat(String value) {
  final RegExpMatch? m = RegExp(r'^[+-]?(?:\d+\.?\d*|\.\d+)(?:[eE][+-]?\d+)?')
      .firstMatch(value.trimLeft());
  if (m == null) return 0;
  return double.tryParse(m.group(0)!) ?? 0;
}

/// 1:1: `class SizeUtils` (Adapted from WinJS)
class SizeUtils {
  static double convertToPixels(DomElement element, String value) =>
      jsParseFloat(value);

  static double getDimension(DomElement element, String cssPropertyName) {
    final DomStyle? computedStyle = getComputedStyle(element);
    final String value =
        computedStyle?.getPropertyValue(cssPropertyName) ?? '0';
    return convertToPixels(element, value);
  }

  static double getBorderLeftWidth(DomElement e) =>
      getDimension(e, 'border-left-width');
  static double getBorderRightWidth(DomElement e) =>
      getDimension(e, 'border-right-width');
  static double getBorderTopWidth(DomElement e) =>
      getDimension(e, 'border-top-width');
  static double getBorderBottomWidth(DomElement e) =>
      getDimension(e, 'border-bottom-width');
  static double getPaddingLeft(DomElement e) =>
      getDimension(e, 'padding-left');
  static double getPaddingRight(DomElement e) =>
      getDimension(e, 'padding-right');
  static double getPaddingTop(DomElement e) => getDimension(e, 'padding-top');
  static double getPaddingBottom(DomElement e) =>
      getDimension(e, 'padding-bottom');
  static double getMarginLeft(DomElement e) => getDimension(e, 'margin-left');
  static double getMarginTop(DomElement e) => getDimension(e, 'margin-top');
  static double getMarginRight(DomElement e) => getDimension(e, 'margin-right');
  static double getMarginBottom(DomElement e) =>
      getDimension(e, 'margin-bottom');
}

/// 1:1: `interface IDimension`
abstract class IDimension {
  num get width;
  num get height;
}

/// 1:1: `export class Dimension implements IDimension`
class Dimension implements IDimension {
  static final Dimension None = Dimension(0, 0);

  @override
  final num width;
  @override
  final num height;

  Dimension(this.width, this.height);

  /// 1:1: `with(width = this.width, height = this.height)`
  Dimension withDimension([num? width, num? height]) {
    final num w = width ?? this.width;
    final num h = height ?? this.height;
    if (w != this.width || h != this.height) return Dimension(w, h);
    return this;
  }

  /// Dart has no `with` identifier usable as a method name in all contexts;
  /// this alias mirrors TS `Dimension.with`.
  Dimension with_(num width, num height) => withDimension(width, height);

  /// 1:1: `static is(obj): obj is IDimension`
  static bool isDimension(Object? obj) {
    if (obj == null) {
      // JS: typeof null === 'object', then `obj.height` throws TypeError.
      throw StateError('Cannot read properties of null (reading height)');
    }
    if (obj is Map) {
      return obj['height'] is num && obj['width'] is num;
    }
    if (obj is! IDimension) return false;
    return obj.height is num && obj.width is num;
  }

  /// 1:1: `static lift(obj)`
  static Dimension lift(IDimension obj) {
    if (obj is Dimension) return obj;
    return Dimension(obj.width, obj.height);
  }

  /// 1:1: `static equals(a, b)`
  static bool equals(Dimension? a, Dimension? b) {
    if (identical(a, b)) return true;
    if (a == null || b == null) return false;
    return a.width == b.width && a.height == b.height;
  }

  @override
  String toString() => 'Dimension($width, $height)';
}

/// 1:1: `interface IDomPosition`
class IDomPosition {
  final num left;
  final num top;
  IDomPosition(this.left, this.top);
}

/// 1:1: `getTopLeftOffset`
IDomPosition getTopLeftOffset(DomElement element) {
  DomElement? offsetParent = element.parentNode is DomElement
      ? element.parentNode as DomElement
      : null;
  num top = element.offsetTop;
  num left = element.offsetLeft;

  DomNode? current = element;
  while ((current = current!.parentNode) != null &&
      !identical(current, current!.ownerDocument?.body) &&
      !identical(current, current!.ownerDocument?.documentElement)) {
    final DomElement parent = current as DomElement;
    top -= parent.scrollTop;
    final DomStyle? c = parent is DomShadowRoot ? null : getComputedStyle(parent);
    if (c != null) {
      left -= c.getPropertyValue('direction') != 'rtl' ? parent.scrollLeft : -parent.scrollLeft;
    }
    if (identical(parent, offsetParent)) {
      left += SizeUtils.getBorderLeftWidth(parent);
      top += SizeUtils.getBorderTopWidth(parent);
      top += parent.offsetTop;
      left += parent.offsetLeft;
      offsetParent = parent.parentNode is DomElement
          ? parent.parentNode as DomElement
          : null;
    }
  }
  return IDomPosition(left, top);
}

/// 1:1: `interface IDomNodePagePosition`
class IDomNodePagePosition {
  num left, top, width, height;
  IDomNodePagePosition({
    this.left = 0,
    this.top = 0,
    this.width = 0,
    this.height = 0,
  });
}

/// 1:1: `size(element, width, height)`
void size(DomElement element, num? width, num? height) {
  if (width != null) element.style.setProperty('width', '${width}px');
  if (height != null) element.style.setProperty('height', '${height}px');
}

/// 1:1: `position(...)`
void position(
  DomElement element,
  num top, [
  num? right,
  num? bottom,
  num? left,
  String position = 'absolute',
]) {
  element.style.setProperty('top', '${top}px');
  if (right != null) element.style.setProperty('right', '${right}px');
  if (bottom != null) element.style.setProperty('bottom', '${bottom}px');
  if (left != null) element.style.setProperty('left', '${left}px');
  element.style.setProperty('position', position);
}

/// 1:1: `getDomNodePagePosition`
IDomNodePagePosition getDomNodePagePosition(DomElement domNode) {
  final DomRect bb = domNode.getBoundingClientRect();
  final DomWindowCarrier wc = windowCarrier(getWindow(domNode));
  // Source uses window.scrollX / scrollY; the carrier exposes them via the
  // Dom Window bridge as 0 by default (injectable through [wc]).
  return IDomNodePagePosition(
    left: bb.left + wc.scrollX,
    top: bb.top + wc.scrollY,
    width: bb.width,
    height: bb.height,
  );
}

/// 1:1: `getDomNodeZoomLevel`
num getDomNodeZoomLevel(DomElement domNode) {
  DomElement? testElement = domNode;
  num zoom = 1;
  final CodeWindow targetWindow = getWindow(domNode);
  while (testElement != null) {
    final String elementZoomLevel =
        windowCarrier(targetWindow).getComputedStyle(testElement).getPropertyValue('zoom');
    if (elementZoomLevel.isNotEmpty && elementZoomLevel != '1') {
      final num? value = num.tryParse(elementZoomLevel);
      if (value != null && value > 0) zoom *= value;
    }
    if (testElement.parentElement != null) {
      testElement = testElement.parentElement;
    } else {
      final DomNode root = testElement.getRootNode();
      testElement = root is DomShadowRoot && root.host is DomElement
          ? root.host
          : null;
    }
  }
  return zoom;
}

/// 1:1: `DevicePixelRounding`
typedef DevicePixelRounding = String;

/// 1:1: `interface IDevicePixelAlignment`
class IDevicePixelAlignment {
  final String? horizontal;
  final String? vertical;
  const IDevicePixelAlignment({this.horizontal, this.vertical});
}

/// JS `Math.round` (half toward +infinity), unlike Dart's `num.round`.
double _jsRound(num value) => value >= 0
    ? (value.toDouble() + 0.5).floor().toDouble()
    : (value.toDouble() - 0.5).ceil().toDouble();

/// 1:1: `getDevicePixelAlignmentOffset`
double getDevicePixelAlignmentOffset(
  num position,
  num devicePixelRatio, [
  String rounding = 'nearest',
  num size = 0,
  num? end,
]) {
  if (rounding == 'none') return 0;
  final double tolerance = (math.max(devicePixelRatio, 1) / 64) * 1.05;
  final double device = (position * devicePixelRatio).toDouble();
  if (rounding == 'nearestEnd' &&
      end == null &&
      (_jsRound(device) - device).abs() <= tolerance) {
    return 0;
  }
  double target;
  switch (rounding) {
    case 'start':
      target = (device + tolerance).floor().toDouble();
      break;
    case 'end':
      target = (device - tolerance).ceil().toDouble();
      break;
    case 'nearestEnd':
      target = _jsRound((end ?? position + size) * devicePixelRatio) -
          _jsRound(size * devicePixelRatio);
      break;
    default:
      target = _jsRound(device);
      break;
  }
  return (target - device).abs() <= tolerance
      ? 0
      : (target - device) / devicePixelRatio;
}

/// 1:1: `alignInset`
void alignInset(
  DomElement element,
  String start,
  String end,
  num offset,
) {
  if (offset == 0) return;
  final String startValue = element.style.getPropertyValue(start);
  if (startValue.endsWith('px')) {
    element.style.setProperty(
        start, '${jsParseFloat(startValue) + offset}px');
    return;
  }
  final String endValue = element.style.getPropertyValue(end);
  if (endValue.endsWith('px')) {
    element.style.setProperty(
        end, '${jsParseFloat(endValue) - offset}px');
  }
}

/// 1:1: `alignToDevicePixels`
void alignToDevicePixels(DomElement element,
        [IDevicePixelAlignment direction = const IDevicePixelAlignment()]) =>
    alignToDevicePixelsInWindow(getWindow(element), element, direction);

/// Shared implementation mirroring the source body (kept separate so tests can
/// target a specific window carrier).
void alignToDevicePixelsInWindow(
  CodeWindow targetWindow,
  DomElement element,
  IDevicePixelAlignment direction,
) {
  final num devicePixelRatio = windowCarrier(targetWindow).devicePixelRatio;
  final num zoom = getDomNodeZoomLevel(element);
  final DomRect rect = element.getBoundingClientRect();
  alignInset(
      element,
      'left',
      'right',
      getDevicePixelAlignmentOffset(rect.left, devicePixelRatio,
              direction.horizontal ?? 'nearest', rect.width) /
          zoom);
  alignInset(
      element,
      'top',
      'bottom',
      getDevicePixelAlignmentOffset(rect.top, devicePixelRatio,
              direction.vertical ?? 'nearest', rect.height) /
          zoom);
}

/// 1:1: `getTotalWidth`
num getTotalWidth(DomElement element) =>
    element.offsetWidth + SizeUtils.getMarginLeft(element) + SizeUtils.getMarginRight(element);

/// 1:1: `getContentWidth`
num getContentWidth(DomElement element) =>
    element.offsetWidth -
    SizeUtils.getBorderLeftWidth(element) -
    SizeUtils.getBorderRightWidth(element) -
    SizeUtils.getPaddingLeft(element) -
    SizeUtils.getPaddingRight(element);

/// 1:1: `getTotalScrollWidth`
num getTotalScrollWidth(DomElement element) =>
    element.scrollWidth + SizeUtils.getMarginLeft(element) + SizeUtils.getMarginRight(element);

/// 1:1: `getContentHeight`
num getContentHeight(DomElement element) =>
    element.offsetHeight -
    SizeUtils.getBorderTopWidth(element) -
    SizeUtils.getBorderBottomWidth(element) -
    SizeUtils.getPaddingTop(element) -
    SizeUtils.getPaddingBottom(element);

/// 1:1: `getTotalHeight`
num getTotalHeight(DomElement element) =>
    element.offsetHeight + SizeUtils.getMarginTop(element) + SizeUtils.getMarginBottom(element);

num getRelativeLeft(DomElement element, DomElement parent) =>
    getTopLeftOffset(element).left - getTopLeftOffset(parent).left;

/// 1:1: `getLargestChildWidth`
num getLargestChildWidth(DomElement parent, List<DomElement> children) {
  num maxWidth = 0;
  for (final DomElement child in children) {
    final num w = math.max(getTotalScrollWidth(child), getTotalWidth(child)) +
        getRelativeLeft(child, parent);
    if (w > maxWidth) maxWidth = w;
  }
  return maxWidth;
}

// ---------------------------------------------------------------------------
// Ancestors, shadow DOM, active element
// ---------------------------------------------------------------------------

/// 1:1: `isAncestor`
bool isAncestor(DomNode? testChild, DomNode? testAncestor) =>
    testAncestor?.contains(testChild) ?? false;

const String parentFlowToDataKey = 'parentFlowToElementId';

/// 1:1: `setParentFlowTo`
void setParentFlowTo(DomElement fromChildElement, DomElement toParentElement) =>
    fromChildElement.dataset[parentFlowToDataKey] = toParentElement.id;

DomElement? getParentFlowToElement(DomElement node) {
  final String? flowToParentId = node.dataset[parentFlowToDataKey];
  if (flowToParentId != null) return node.ownerDocument?.getElementById(flowToParentId);
  return null;
}

/// 1:1: `isAncestorUsingFlowTo`
bool isAncestorUsingFlowTo(DomNode testChild, DomNode testAncestor) {
  DomNode? node = testChild;
  while (node != null) {
    if (identical(node, testAncestor)) return true;
    if (node is DomElement) {
      final DomElement? flowToParentElement = getParentFlowToElement(node);
      if (flowToParentElement != null) {
        node = flowToParentElement;
        continue;
      }
    }
    node = node.parentNode;
  }
  return false;
}

/// 1:1: `findParentWithClass`
DomElement? findParentWithClass(
  DomElement node,
  Object clazz, [
  Object? stopAtClazzOrNode,
]) {
  DomNode? current = node;
  while (current != null && current.nodeType == DomNode.ELEMENT_NODE) {
    final DomElement element = current as DomElement;
    final bool matches = clazz is String
        ? element.classList.contains(clazz)
        : (clazz as List<String>).every(element.classList.contains);
    if (matches) return element;
    if (stopAtClazzOrNode != null) {
      if (stopAtClazzOrNode is String) {
        if (element.classList.contains(stopAtClazzOrNode)) return null;
      } else if (identical(element, stopAtClazzOrNode)) {
        return null;
      }
    }
    current = element.parentNode;
  }
  return null;
}

bool hasParentWithClass(DomElement node, Object clazz,
        [Object? stopAtClazzOrNode]) =>
    findParentWithClass(node, clazz, stopAtClazzOrNode) != null;

/// 1:1: `isShadowRoot`
bool isShadowRoot(DomNode? node) =>
    node != null && node is DomShadowRoot && node.host.toString().isNotEmpty;

/// 1:1: `getShadowRoot`
DomShadowRoot? getShadowRoot(DomNode domNode) {
  DomNode node = domNode;
  while (node.parentNode != null) {
    if (identical(node, node.ownerDocument?.body)) return null;
    node = node.parentNode!;
  }
  return isShadowRoot(node) ? node as DomShadowRoot : null;
}

bool isInShadowDOM(DomNode domNode) => getShadowRoot(domNode) != null;

/// 1:1: `getActiveElement`
DomElement? getActiveElement() {
  DomElement? result = getActiveDocument().activeElement;
  while (result?.shadowRoot != null) {
    result = result!.shadowRoot!.activeElement;
  }
  return result;
}

bool isActiveElement(DomElement element) => getActiveElement() == element;

bool isAncestorOfActiveElement(DomElement ancestor) =>
    isAncestor(getActiveElement(), ancestor);

bool isActiveDocument(DomElement element) =>
    identical(element.ownerDocument, getActiveDocument());

/// 1:1: `getActiveDocument`
DomDocument getActiveDocument() {
  if (getWindowsCount() <= 1) return mainDocument;
  final List<CodeWindow> focusedWindows = getWindows()
      .map((IRegisteredCodeWindow r) => r.window)
      .where((CodeWindow w) => windowCarrier(w).document.hasFocus())
      .toList();
  if (focusedWindows.isNotEmpty) {
    final CodeWindow selected = focusedWindows.firstWhere(
        (CodeWindow w) => w.vscodeWindowId == lastFocusedWindowId,
        orElse: () => focusedWindows.first);
    return windowCarrier(selected).document;
  }
  final CodeWindow? externalWindow = getExternalFocusWindow();
  if (externalWindow != null) return windowCarrier(externalWindow).document;
  return mainDocument;
}

/// 1:1: `getActiveWindow`
CodeWindow getActiveWindow() =>
    getActiveDocument().defaultView ?? mainWindow;

// ---------------------------------------------------------------------------
// sharedMutationObserver
// ---------------------------------------------------------------------------

class IMutationObserver {
  int users;
  final DomMutationObserver observer;
  final event.Event<List<DomMutationRecord>> onDidMutate;
  IMutationObserver(this.users, this.observer, this.onDidMutate);
}

/// 1:1: `sharedMutationObserver`
class SharedMutationObserver {
  final Map<DomNode, Map<int, IMutationObserver>> mutationObservers =
      <DomNode, Map<int, IMutationObserver>>{};

  event.Event<List<DomMutationRecord>> observe(
    DomNode target,
    lifecycle.DisposableStore disposables, [
    Object? options,
  ]) {
    final Map<int, IMutationObserver> perTarget =
        mutationObservers.putIfAbsent(target, () => <int, IMutationObserver>{});
    final int optionsHash = hash(options);
    IMutationObserver? perOptions = perTarget[optionsHash];
    if (perOptions == null) {
      final event.Emitter<List<DomMutationRecord>> onDidMutate =
          event.Emitter<List<DomMutationRecord>>();
      final DomMutationObserver observer = DomMutationObserver(
          (List<DomMutationRecord> mutations) => onDidMutate.fire(mutations));
      observer.observe(target, options);
      final IMutationObserver resolved =
          IMutationObserver(1, observer, onDidMutate.event);
      perOptions = resolved;
      disposables.add(lifecycle.toDisposable(() {
        resolved.users -= 1;
        if (resolved.users == 0) {
          onDidMutate.dispose();
          observer.disconnect();
          perTarget.remove(optionsHash);
          if (perTarget.isEmpty) mutationObservers.remove(target);
        }
      }));
      perTarget[optionsHash] = resolved;
    } else {
      perOptions.users += 1;
    }
    return perOptions.onDidMutate;
  }
}

final SharedMutationObserver sharedMutationObserver = SharedMutationObserver();

/// 1:1: `createMetaElement`
DomElement createMetaElement([DomElement? container]) =>
    createHeadElement('meta', container);

/// 1:1: `createLinkElement`
DomElement createLinkElement([DomElement? container]) =>
    createHeadElement('link', container);

DomElement createHeadElement(String tagName, [DomElement? container]) {
  final DomElement element = document.createElement(tagName);
  (container ?? mainDocument.head).appendChild(element);
  return element;
}

// ---------------------------------------------------------------------------
// Type guards
// ---------------------------------------------------------------------------

bool isHTMLElement(Object? e) => e is DomElement && !isSVGElement(e);

bool isHTMLAnchorElement(Object? e) =>
    e is DomElement && e.tagName.toUpperCase() == 'A';

bool isHTMLSpanElement(Object? e) =>
    e is DomElement && e.tagName.toUpperCase() == 'SPAN';

bool isHTMLTextAreaElement(Object? e) =>
    e is DomElement && e.tagName.toUpperCase() == 'TEXTAREA';

bool isHTMLInputElement(Object? e) =>
    e is DomElement && e.tagName.toUpperCase() == 'INPUT';

bool isHTMLButtonElement(Object? e) =>
    e is DomElement && e.tagName.toUpperCase() == 'BUTTON';

bool isHTMLDivElement(Object? e) =>
    e is DomElement && e.tagName.toUpperCase() == 'DIV';

bool isSVGElement(Object? e) =>
    e is DomElement && e.namespaceURI == 'http://www.w3.org/2000/svg';

bool isMouseEvent(Object? e) => e is DomMouseEvent;
bool isKeyboardEvent(Object? e) => e is DomKeyboardEvent;
bool isPointerEvent(Object? e) =>
    e is DomEvent && e.type.startsWith('pointer');
bool isDragEvent(Object? e) => e is DomDragEvent;

/// 1:1: `EventType` (const object translated to a Dart class).
class EventType {
  static const String CLICK = 'click';
  static const String AUXCLICK = 'auxclick';
  static const String DBLCLICK = 'dblclick';
  static const String MOUSE_UP = 'mouseup';
  static const String MOUSE_DOWN = 'mousedown';
  static const String MOUSE_OVER = 'mouseover';
  static const String MOUSE_MOVE = 'mousemove';
  static const String MOUSE_OUT = 'mouseout';
  static const String MOUSE_ENTER = 'mouseenter';
  static const String MOUSE_LEAVE = 'mouseleave';
  static const String MOUSE_WHEEL = 'wheel';
  static const String POINTER_UP = 'pointerup';
  static const String POINTER_DOWN = 'pointerdown';
  static const String POINTER_MOVE = 'pointermove';
  static const String POINTER_LEAVE = 'pointerleave';
  static const String CONTEXT_MENU = 'contextmenu';
  static const String WHEEL = 'wheel';
  static const String KEY_DOWN = 'keydown';
  static const String KEY_PRESS = 'keypress';
  static const String KEY_UP = 'keyup';
  static const String LOAD = 'load';
  static const String BEFORE_UNLOAD = 'beforeunload';
  static const String UNLOAD = 'unload';
  static const String PAGE_SHOW = 'pageshow';
  static const String PAGE_HIDE = 'pagehide';
  static const String PASTE = 'paste';
  static const String ABORT = 'abort';
  static const String ERROR = 'error';
  static const String RESIZE = 'resize';
  static const String SCROLL = 'scroll';
  static const String FULLSCREEN_CHANGE = 'fullscreenchange';
  static const String WK_FULLSCREEN_CHANGE = 'webkitfullscreenchange';
  static const String SELECT = 'select';
  static const String CHANGE = 'change';
  static const String SUBMIT = 'submit';
  static const String RESET = 'reset';
  static const String FOCUS = 'focus';
  static const String FOCUS_IN = 'focusin';
  static const String FOCUS_OUT = 'focusout';
  static const String BLUR = 'blur';
  static const String INPUT = 'input';
  static const String STORAGE = 'storage';
  static const String DRAG_START = 'dragstart';
  static const String DRAG = 'drag';
  static const String DRAG_ENTER = 'dragenter';
  static const String DRAG_LEAVE = 'dragleave';
  static const String DRAG_OVER = 'dragover';
  static const String DROP = 'drop';
  static const String DRAG_END = 'dragend';
  static final String ANIMATION_START = browser.isWebKit ? 'webkitAnimationStart' : 'animationstart';
  static final String ANIMATION_END = browser.isWebKit ? 'webkitAnimationEnd' : 'animationend';
  static final String ANIMATION_ITERATION = browser.isWebKit ? 'webkitAnimationIteration' : 'animationiteration';
  const EventType._();
}

/// 1:1: `interface EventLike`
abstract class EventLike {
  void preventDefault();
  void stopPropagation();
}

/// 1:1: `isEventLike`
bool isEventLike(Object? obj) {
  if (obj == null) return false;
  // Dart has no reflection; carriers expose the two methods explicitly.
  return obj is EventLike ||
      obj is DomEvent ||
      (obj is FunctionLikeEvent && obj.preventDefault != null && obj.stopPropagation != null);
}

/// Structural escape hatch for externally supplied event objects.
abstract class FunctionLikeEvent {
  void Function()? get preventDefault;
  void Function()? get stopPropagation;
}

/// 1:1: `EventHelper.stop`
final EventHelper = _EventHelper();

class _EventHelper {
  T stop<T extends EventLike>(T e, [bool? cancelBubble]) {
    e.preventDefault();
    if (cancelBubble == true) e.stopPropagation();
    return e;
  }

  /// Overload for [DomEvent] carriers.
  DomEvent stopDom(DomEvent e, [bool? cancelBubble]) {
    e.preventDefault();
    if (cancelBubble == true) e.stopPropagation();
    return e;
  }
}

/// 1:1: `saveParentsScrollTop`
List<int> saveParentsScrollTop(DomNode node) {
  final List<int> result = <int>[];
  DomNode? current = node;
  int i = 0;
  while (current != null && current.nodeType == DomNode.ELEMENT_NODE) {
    result[i++] = (current as DomElement).scrollTop;
    current = current.parentNode;
  }
  return result;
}

/// 1:1: `restoreParentsScrollTop`
void restoreParentsScrollTop(DomNode node, List<int> state) {
  DomNode? current = node;
  int i = 0;
  while (current != null && current.nodeType == DomNode.ELEMENT_NODE) {
    final DomElement element = current as DomElement;
    if (element.scrollTop != state[i]) element.scrollTop = state[i];
    current = element.parentNode;
    i++;
  }
}

/// 1:1: `interface IFocusTracker`
abstract class IFocusTracker implements lifecycle.IDisposable {
  event.Event<void> get onDidFocus;
  event.Event<void> get onDidBlur;
  void refreshState();
}

/// 1:1: `class FocusTracker implements IFocusTracker`
class FocusTracker extends lifecycle.Disposable implements IFocusTracker {
  final event.Emitter<void> _onDidFocus = event.Emitter<void>();
  final event.Emitter<void> _onDidBlur = event.Emitter<void>();

  @override
  event.Event<void> get onDidFocus => _onDidFocus.event;

  @override
  event.Event<void> get onDidBlur => _onDidBlur.event;

  late final void Function() _refreshStateHandler;

  static bool hasFocusWithin(Object element) {
    if (element is DomElement) {
      final DomShadowRoot? shadowRoot = getShadowRoot(element);
      final DomElement? activeElement = shadowRoot != null
          ? shadowRoot.activeElement
          : element.ownerDocument?.activeElement;
      return isAncestor(activeElement, element);
    }
    final CodeWindow window = element as CodeWindow;
    final DomDocument doc = windowCarrier(window).document;
    return isAncestor(doc.activeElement, doc);
  }

  FocusTracker(Object element) {
    bool hasFocus = hasFocusWithin(element);
    bool loosingFocus = false;

    void onFocus() {
      loosingFocus = false;
      if (!hasFocus) {
        hasFocus = true;
        _onDidFocus.fire(null);
      }
    }

    void onBlur() {
      if (hasFocus) {
        loosingFocus = true;
        final CodeWindow w = element is DomElement
            ? getWindow(element)
            : element as CodeWindow;
        Timer(const Duration(), () {
          if (loosingFocus) {
            loosingFocus = false;
            hasFocus = false;
            _onDidBlur.fire(null);
          }
        });
      }
    }

    _refreshStateHandler = () {
      final bool currentNodeHasFocus = hasFocusWithin(element);
      if (currentNodeHasFocus != hasFocus) {
        if (hasFocus) { onBlur(); } else { onFocus(); }
      }
    };

    register(addDisposableTargetListener(
        element, EventType.FOCUS, (DomEvent e) => onFocus(), true));
    register(addDisposableTargetListener(
        element, EventType.BLUR, (DomEvent e) => onBlur(), true));
    if (element is DomElement) {
      register(addDisposableListener(element, EventType.FOCUS_IN,
          (DomEvent e) => _refreshStateHandler()));
      register(addDisposableListener(element, EventType.FOCUS_OUT,
          (DomEvent e) => _refreshStateHandler()));
    }
  }

  @override
  void refreshState() => _refreshStateHandler();
}

/// 1:1: `trackFocus`
IFocusTracker trackFocus(Object element) => FocusTracker(element);

/// 1:1: `after`
T after<T extends DomNode>(DomElement sibling, T child) {
  sibling.parentNode?.insertBefore(child, sibling.nextSibling);
  return child;
}

/// 1:1: `append`
T appendNode<T extends DomNode>(DomElement parent, T child) {
  parent.append(child);
  return child;
}

void appendAll(DomElement parent, List<Object> children) =>
    parent.appendAll(children);

/// 1:1: `prepend`
T prepend<T extends DomNode>(DomElement parent, T child) {
  parent.insertBefore(child, parent.firstChild);
  return child;
}

/// 1:1: `reset`
void reset(DomElement parent, List<Object> children) {
  parent.textContent = '';
  parent.appendAll(children);
}

// ---------------------------------------------------------------------------
// Emmet-like DSL: SELECTOR_REGEX, Namespace, $, $.SVG, join
// ---------------------------------------------------------------------------

final RegExp SELECTOR_REGEX = RegExp(r'([\w\-]+)?(#([\w\-]+))?((\.([\w\-]+))*)');

/// 1:1: `export enum Namespace`
class Namespace {
  static const String HTML = 'http://www.w3.org/1999/xhtml';
  static const String SVG = 'http://www.w3.org/2000/svg';
  const Namespace._();
}

/// 1:1: `_$<T>(namespace, description, attrs?, ...children)`
DomElement dollarImpl(
  String namespace,
  String description, [
  Map<String, Object?>? attrs,
  List<Object> children = const <Object>[],
]) {
  final RegExpMatch? match = SELECTOR_REGEX.firstMatch(description);
  if (match == null) throw StateError('Bad use of emmet');

  final String tagName = match.group(1) ?? 'div';
  final DomElement result = namespace != Namespace.HTML
      ? document.createElementNS(namespace, tagName)
      : document.createElement(tagName);
  if (match.group(3) != null) result.id = match.group(3)!;
  if (match.group(4) != null) {
    result.className = match.group(4)!.replaceAll('.', ' ').trim();
  }
  if (attrs != null) {
    attrs.forEach((String name, Object? value) {
      if (value == null) return;
      if (RegExp(r'^on\w+$').hasMatch(name)) {
        result.eventHandlers[name] = value;
      } else if (name == 'selected') {
        if (_jsTruthy(value)) result.setAttribute(name, 'true');
      } else {
        result.setAttribute(name, value.toString());
      }
    });
  }
  result.appendAll(children);
  return result;
}

bool _jsTruthy(Object? value) {
  if (value == null) return false;
  if (value is bool) return value;
  if (value is num) return value != 0 && !value.isNaN;
  if (value is String) return value.isNotEmpty;
  return true;
}

/// 1:1: `export function $(description, attrs?, ...children)` and the
/// `$.SVG` property on the function object (a callable class in Dart).
class DollarFn {
  DomElement call(
    String description, [
    Map<String, Object?>? attrs,
    List<Object> children = const <Object>[],
  ]) =>
      dollarImpl(Namespace.HTML, description, attrs, children);

  static DomElement SVG(
    String description, [
    Map<String, Object?>? attrs,
    List<Object> children = const <Object>[],
  ]) =>
      dollarImpl(Namespace.SVG, description, attrs, children);
}

final DollarFn $ = DollarFn();

/// 1:1: `join(nodes, separator)`
List<DomNode> join(List<DomNode> nodes, Object separator) {
  final List<DomNode> result = <DomNode>[];
  for (int index = 0; index < nodes.length; index++) {
    if (index > 0) {
      if (separator is DomNode) {
        result.add(separator.cloneNode());
      } else {
        result.add(document.createTextNode(separator.toString()));
      }
    }
    result.add(nodes[index]);
  }
  return result;
}

// ---------------------------------------------------------------------------
// Visibility / tabIndex / finalHandler / domContentLoaded
// ---------------------------------------------------------------------------

void setVisibility(bool visible, List<DomElement> elements) =>
    visible ? show(elements) : hide(elements);

void show(List<DomElement> elements) {
  for (final DomElement element in elements) {
    element.style.setProperty('display', '');
    element.removeAttribute('aria-hidden');
  }
}

void hide(List<DomElement> elements) {
  for (final DomElement element in elements) {
    element.style.setProperty('display', 'none');
    element.setAttribute('aria-hidden', 'true');
  }
}

DomElement? findParentWithAttribute(DomNode? node, String attribute) {
  DomNode? current = node;
  while (current != null && current.nodeType == DomNode.ELEMENT_NODE) {
    final DomElement element = current as DomElement;
    if (isHTMLElement(element) && element.hasAttribute(attribute)) return element;
    current = element.parentNode;
  }
  return null;
}

/// 1:1: `removeTabIndexAndUpdateFocus`
void removeTabIndexAndUpdateFocus(DomElement node) {
  if (!node.hasAttribute('tabIndex')) return;
  if (identical(node.ownerDocument?.activeElement, node)) {
    findParentWithAttribute(node.parentElement, 'tabIndex')?.focus();
  }
  node.removeAttribute('tabindex');
}

/// 1:1: `finalHandler<T>(fn)`
void Function(DomEvent e) finalHandler(void Function(DomEvent e) fn) =>
    (DomEvent e) {
      e.preventDefault();
      e.stopPropagation();
      fn(e);
    };

/// 1:1: `domContentLoaded(targetWindow): Promise<void>`
Future<void> domContentLoaded(CodeWindow targetWindow) {
  final Completer<void> completer = Completer<void>();
  final DomDocument doc = windowCarrier(targetWindow).document;
  if (doc.readyState == 'complete' || doc.body.childNodes.isNotEmpty ||
      doc.readyState != 'loading') {
    completer.complete();
  } else {
    void listener(DomEvent e) {
      doc.removeEventListener('DOMContentLoaded', listener);
      if (!completer.isCompleted) completer.complete();
    }
    doc.addEventListener('DOMContentLoaded', listener);
  }
  return completer.future;
}

/// 1:1: `computeScreenAwareSize(window, cssPx)`
num computeScreenAwareSize(CodeWindow window, num cssPx) {
  final num dpr = windowCarrier(window).devicePixelRatio;
  final num screenPx = dpr * cssPx;
  return math.max(1, screenPx.floor()) / dpr;
}

// ---------------------------------------------------------------------------
// Window opening / download / upload
// ---------------------------------------------------------------------------

void windowOpenNoOpener(String url) =>
    windowCarrier(mainWindow).open(url, '_blank', 'noopener');

const int popupWidth = 780;
const int popupHeight = 640;

void windowOpenPopup(String url) {
  final DomWindowCarrier wc = windowCarrier(mainWindow);
  final int left =
      (wc.screenLeft + wc.innerWidth / 2 - popupWidth / 2).floor();
  final int top =
      (wc.screenTop + wc.innerHeight / 2 - popupHeight / 2).floor();
  wc.open(url, '_blank',
      'width=$popupWidth,height=$popupHeight,top=$top,left=$left');
}

CodeWindow? reservedExternalWindow;

bool isUsable(CodeWindow? candidate) =>
    candidate != null && !windowCarrier(candidate).closed;

/// 1:1: `reserveWindowForExternalOpen(targetWindow, placeholder?)`
void reserveWindowForExternalOpen([
  CodeWindow? targetWindow,
  String? placeholder,
]) {
  if (isUsable(reservedExternalWindow)) return;
  reservedExternalWindow =
      windowCarrier(targetWindow ?? mainWindow).open() ?? null;
  if (!isUsable(reservedExternalWindow)) {
    reservedExternalWindow = null;
    return;
  }
  if (placeholder != null) {
    showMessageInWindow(reservedExternalWindow!, placeholder);
  }
}

/// Uses `textContent` so the message cannot inject markup.
void showMessageInWindow(CodeWindow target, String message) {
  try {
    final DomDocument doc = windowCarrier(target).document;
    doc.title = message;
    doc.documentElement.style.cssText = 'color-scheme:light dark';
    doc.body.style.cssText =
        'margin:0;height:100vh;display:flex;align-items:center;justify-content:center;background:Canvas;color:CanvasText;font:16px/1.4 -apple-system,BlinkMacSystemFont,"Segoe UI",system-ui,sans-serif';
    doc.body.textContent = message;
  } catch (_) {
    // the window may already have navigated
  }
}

CodeWindow? takeReservedWindowForExternalOpen() {
  final CodeWindow? reserved = reservedExternalWindow;
  reservedExternalWindow = null;
  return isUsable(reserved) ? reserved : null;
}

void releaseReservedWindowForExternalOpen([String? fallbackMessage]) {
  final CodeWindow? reserved = takeReservedWindowForExternalOpen();
  if (reserved == null) return;
  try {
    windowCarrier(reserved).close();
  } catch (_) {
    // the window may already have navigated
  }
  if (!windowCarrier(reserved).closed && fallbackMessage != null) {
    showMessageInWindow(reserved, fallbackMessage);
  }
}

/// 1:1: `windowOpenWithSuccess`
bool windowOpenWithSuccess(
  String url, [
  bool noOpener = true,
  CodeWindow? targetWindow,
]) {
  final CodeWindow? newTab = takeReservedWindowForExternalOpen() ??
      windowCarrier(targetWindow ?? mainWindow).open();
  if (newTab != null) {
    if (noOpener) windowCarrier(newTab).opener = null;
    windowCarrier(newTab).href = url;
    return true;
  }
  return false;
}

/// 1:1: `animate`
lifecycle.IDisposable animate(CodeWindow targetWindow, void Function() fn) {
  late lifecycle.IDisposable stepDisposable;
  void step() {
    fn();
    stepDisposable = scheduleAtNextAnimationFrame(targetWindow, step);
  }
  stepDisposable = scheduleAtNextAnimationFrame(targetWindow, step);
  return lifecycle.toDisposable(() => stepDisposable.dispose());
}

// Module-load side effect: RemoteAuthorities.setPreferredWebSchema(...)
final bool _remoteAuthoritiesSchemaRegistered =
    _registerRemoteAuthoritiesSchema();

bool _registerRemoteAuthoritiesSchema() {
  RemoteAuthorities.setPreferredWebSchema(
      RegExp(r'^https:').hasMatch(windowCarrier(mainWindow).href)
          ? 'https'
          : 'http');
  return true;
}

/// 1:1: injectable `URL.createObjectURL` / `URL.revokeObjectURL`.
String Function(Uint8List) domCreateObjectURL =
    (Uint8List data) => 'blob:monaco/${data.length}';
void Function(String) domRevokeObjectURL = (String url) {};

/// 1:1: `triggerDownload(dataOrUri, name)`
void triggerDownload(Object dataOrUri, String name) {
  late String url;
  if (dataOrUri is URI) {
    url = dataOrUri.toString(true);
  } else {
    final Uint8List data = dataOrUri as Uint8List;
    url = domCreateObjectURL(data);
    Timer(const Duration(), () => domRevokeObjectURL(url));
  }
  final CodeWindow activeWindow = getActiveWindow();
  final DomElement anchor = document.createElement('a');
  windowCarrier(activeWindow).document.body.appendChild(anchor);
  anchor.setAttribute('download', name);
  anchor.setAttribute('href', url);
  anchor.click();
  Timer(const Duration(), () => anchor.remove());
}

/// 1:1: `FileList` carrier.
class DomFileList {
  final List<Object> files;
  DomFileList(this.files);
}

/// 1:1: `triggerUpload(accept?): Promise<FileList | undefined>`
Future<DomFileList?> triggerUpload([String? accept]) async {
  final DomElement input = $('input', <String, Object?>{
    'type': 'file',
    'multiple': true,
  });
  input.hidden = true;
  if (accept != null) input.setAttribute('accept', accept);
  windowCarrier(getActiveWindow()).document.body.appendChild(input);
  final lifecycle.DisposableStore store = lifecycle.DisposableStore();
  store.add(lifecycle.toDisposable(() => input.remove()));

  try {
    final Completer<DomFileList?> c = Completer<DomFileList?>();
      store.add(addDisposableListener(input, 'change', (DomEvent e) {
        if (!c.isCompleted) c.complete(domUploadedFiles(input));
      }));
      store.add(addDisposableListener(input, 'cancel', (DomEvent e) {
        if (!c.isCompleted) c.complete(null);
      }));
      input.click();
      return await c.future;
  } finally {
    store.dispose();
  }
}

/// Injectable `input.files` bridge.
DomFileList Function(DomElement input) domUploadedFiles =
    (DomElement input) => DomFileList(<Object>[]);

// ---------------------------------------------------------------------------
// Fullscreen / modifier keys / cookies
// ---------------------------------------------------------------------------

/// 1:1: `export enum DetectedFullscreenMode`
class DetectedFullscreenMode {
  static const int DOCUMENT = 1;
  static const int BROWSER = 2;
  const DetectedFullscreenMode._();
}

/// 1:1: `interface IDetectedFullscreen`
class IDetectedFullscreen {
  final int mode;
  final bool guess;
  IDetectedFullscreen(this.mode, this.guess);
}

/// Test seams for the source's `platform.isMacintosh || platform.isLinux` flags.
bool? platformIsMacintoshOverride;
bool? platformIsLinuxOverride;

/// 1:1: `detectFullscreen`
IDetectedFullscreen? detectFullscreen(CodeWindow targetWindow) {
  final DomWindowCarrier wc = windowCarrier(targetWindow);
  if (wc.document.fullscreenElement != null ||
      wc.document.webkitFullscreenElement != null ||
      wc.document.webkitIsFullScreen) {
    return IDetectedFullscreen(DetectedFullscreenMode.DOCUMENT, false);
  }
  if (wc.innerHeight == wc.screenHeight) {
    return IDetectedFullscreen(DetectedFullscreenMode.BROWSER, false);
  }
  if ((platformIsMacintoshOverride ?? platform.isMacintosh) ||
        (platformIsLinuxOverride ?? platform.isLinux)) {
    if (wc.outerHeight == wc.screenHeight && wc.outerWidth == wc.screenWidth) {
      return IDetectedFullscreen(DetectedFullscreenMode.BROWSER, true);
    }
  }
  return null;
}

typedef ModifierKey = String;

/// 1:1: `interface IModifierKeyStatus`
class IModifierKeyStatus {
  bool altKey;
  bool shiftKey;
  bool ctrlKey;
  bool metaKey;
  String? lastKeyPressed;
  String? lastKeyReleased;
  DomEvent? event;
  IModifierKeyStatus({
    this.altKey = false,
    this.shiftKey = false,
    this.ctrlKey = false,
    this.metaKey = false,
    this.lastKeyPressed,
    this.lastKeyReleased,
    this.event,
  });
}

/// 1:1: `export class ModifierKeyEmitter extends Emitter<IModifierKeyStatus>`
class ModifierKeyEmitter extends event.Emitter<IModifierKeyStatus> {
  final lifecycle.DisposableStore _subscriptions =
      lifecycle.markAsSingleton(lifecycle.DisposableStore());
  IModifierKeyStatus _keyStatus = IModifierKeyStatus();
  static ModifierKeyEmitter? _instance;

  ModifierKeyEmitter._() {
    _subscriptions.add(event.eventRunAndSubscribe<IRegisteredCodeWindow>(
        onDidRegisterWindow,
        (IRegisteredCodeWindow? e) =>
            registerListeners(e?.window ?? mainWindow, e?.disposables ?? _subscriptions),
        IRegisteredCodeWindow(mainWindow, _subscriptions)));
  }

  void registerListeners(CodeWindow window, lifecycle.DisposableStore disposables) {
    final DomNode doc = windowCarrier(window).document;
    disposables.add(addDisposableTargetListener(window, 'keydown', (DomEvent e) {
      if (e.defaultPrevented) return;
      if (e.keyCode == KeyCode.Alt && e.repeat) return;
      if (e.altKey && !_keyStatus.altKey) {
        _keyStatus.lastKeyPressed = 'alt';
      } else if (e.ctrlKey && !_keyStatus.ctrlKey) {
        _keyStatus.lastKeyPressed = 'ctrl';
      } else if (e.metaKey && !_keyStatus.metaKey) {
        _keyStatus.lastKeyPressed = 'meta';
      } else if (e.shiftKey && !_keyStatus.shiftKey) {
        _keyStatus.lastKeyPressed = 'shift';
      } else if (e.keyCode != KeyCode.Alt) {
        _keyStatus.lastKeyPressed = null;
      } else {
        return;
      }
      _keyStatus
        ..altKey = e.altKey
        ..ctrlKey = e.ctrlKey
        ..metaKey = e.metaKey
        ..shiftKey = e.shiftKey;
      if (_keyStatus.lastKeyPressed != null) fireWithEvent(e);
    }, true));

    disposables.add(addDisposableTargetListener(window, 'keyup', (DomEvent e) {
      if (e.defaultPrevented) return;
      if (!e.altKey && _keyStatus.altKey) {
        _keyStatus.lastKeyReleased = 'alt';
      } else if (!e.ctrlKey && _keyStatus.ctrlKey) {
        _keyStatus.lastKeyReleased = 'ctrl';
      } else if (!e.metaKey && _keyStatus.metaKey) {
        _keyStatus.lastKeyReleased = 'meta';
      } else if (!e.shiftKey && _keyStatus.shiftKey) {
        _keyStatus.lastKeyReleased = 'shift';
      } else {
        _keyStatus.lastKeyReleased = null;
      }
      if (_keyStatus.lastKeyPressed != _keyStatus.lastKeyReleased) {
        _keyStatus.lastKeyPressed = null;
      }
      _keyStatus
        ..altKey = e.altKey
        ..ctrlKey = e.ctrlKey
        ..metaKey = e.metaKey
        ..shiftKey = e.shiftKey;
      if (_keyStatus.lastKeyReleased != null) fireWithEvent(e);
    }, true));

    final DomElement body = windowCarrier(window).document.body;
    disposables.add(addDisposableListener(body, 'mousedown', (DomEvent e) {
      _keyStatus.lastKeyPressed = null;
    }, true));
    disposables.add(addDisposableListener(body, 'mouseup', (DomEvent e) {
      _keyStatus.lastKeyPressed = null;
    }, true));
    disposables.add(addDisposableListener(body, 'mousemove', (DomEvent e) {
      if (e.buttons != 0) _keyStatus.lastKeyPressed = null;
    }, true));
    disposables.add(addDisposableTargetListener(window, 'blur', (DomEvent e) {
      resetKeyStatus();
    }));
  }

  IModifierKeyStatus get keyStatus => _keyStatus;

  void fireWithEvent(DomEvent e) {
    final IModifierKeyStatus status = _keyStatus;
    status.event = e;
    try {
      fire(status);
    } finally {
      status.event = null;
    }
  }

  bool get isModifierPressed => hasModifierKeys(
        ctrlKey: _keyStatus.ctrlKey,
        shiftKey: _keyStatus.shiftKey,
        altKey: _keyStatus.altKey,
        metaKey: _keyStatus.metaKey,
      );

  void resetKeyStatus() {
    doResetKeyStatus();
    fire(_keyStatus);
  }

  void doResetKeyStatus() => _keyStatus = IModifierKeyStatus();

  static ModifierKeyEmitter getInstance() =>
      _instance ??= ModifierKeyEmitter._();

  static void disposeInstance() {
    _instance?.dispose();
    _instance = null;
  }

  @override
  void dispose() {
    super.dispose();
    _subscriptions.dispose();
  }
}

/// 1:1: `getCookieValue(name)`
String? getCookieValue(String name) {
  final RegExpMatch? match = RegExp(
          '(^|[^;]+)\\s*${RegExp.escape(name)}\\s*=\\s*([^;]+)')
      .firstMatch(document.cookie);
  return match?.group(2);
}

// ---------------------------------------------------------------------------
// Drag & drop / resize observer
// ---------------------------------------------------------------------------

/// 1:1: `IDragAndDropObserverCallbacks`
class IDragAndDropObserverCallbacks {
  final void Function(DomDragEvent e)? onDragEnter;
  final void Function(DomDragEvent e)? onDragLeave;
  final void Function(DomDragEvent e)? onDrop;
  final void Function(DomDragEvent e)? onDragEnd;
  final void Function(DomDragEvent e)? onDragStart;
  final void Function(DomDragEvent e)? onDrag;
  final void Function(DomDragEvent e, num dragDuration)? onDragOver;
  IDragAndDropObserverCallbacks({
    this.onDragEnter,
    this.onDragLeave,
    this.onDrop,
    this.onDragEnd,
    this.onDragStart,
    this.onDrag,
    this.onDragOver,
  });
}

/// 1:1: `DragAndDropObserver`
class DragAndDropObserver extends lifecycle.Disposable {
  final DomElement element;
  final IDragAndDropObserverCallbacks callbacks;
  int counter = 0;
  num dragStartTime = 0;

  DragAndDropObserver(this.element, this.callbacks) {
    registerListeners();
  }

  void reset() {
    counter = 0;
    dragStartTime = 0;
  }

  void registerListeners() {
    if (callbacks.onDragStart != null) {
      register(addDisposableListener(element, EventType.DRAG_START, (DomEvent e) {
        callbacks.onDragStart?.call(e as DomDragEvent);
      }));
    }
    if (callbacks.onDrag != null) {
      register(addDisposableListener(element, EventType.DRAG, (DomEvent e) {
        callbacks.onDrag?.call(e as DomDragEvent);
      }));
    }
    register(addDisposableListener(element, EventType.DRAG_ENTER, (DomEvent e) {
      counter++;
      dragStartTime = e.timeStamp;
      callbacks.onDragEnter?.call(e as DomDragEvent);
    }));
    register(addDisposableListener(element, EventType.DRAG_OVER, (DomEvent e) {
      e.preventDefault();
      callbacks.onDragOver?.call(
          e as DomDragEvent, e.timeStamp - dragStartTime);
    }));
    register(addDisposableListener(element, EventType.DRAG_LEAVE, (DomEvent e) {
      counter--;
      if (counter == 0) {
        dragStartTime = 0;
        callbacks.onDragLeave?.call(e as DomDragEvent);
      }
    }));
    register(addDisposableListener(element, EventType.DRAG_END, (DomEvent e) {
      reset();
      callbacks.onDragEnd?.call(e as DomDragEvent);
    }));
    register(addDisposableListener(element, EventType.DROP, (DomEvent e) {
      reset();
      callbacks.onDrop?.call(e as DomDragEvent);
    }));
  }
}

/// 1:1: `ResizeObserver` constructor seam.
DomResizeObserver Function(DomResizeObserverCallback callback)
    resizeObserverCtor = (DomResizeObserverCallback callback) =>
    DomResizeObserver(callback);

/// 1:1: `DisposableResizeObserver`
class DisposableResizeObserver extends lifecycle.Disposable {
  final DomResizeObserver observer;
  final String name;
  final CodeWindow targetWindow;

  DisposableResizeObserver(
    this.name,
    DomResizeObserverCallback callback, [
    CodeWindow? targetWindow,
    DomResizeObserver Function(DomResizeObserverCallback)? ctor,
  ])   : targetWindow = targetWindow ?? mainWindow,
        observer = (ctor ?? resizeObserverCtor)((entries, observer) {
          recordDisposableResizeObserverInvocation(
              targetWindow ?? mainWindow, name);
          try {
            callback(entries, observer);
          } catch (e) {
            onUnexpectedError(e);
          }
        }) {
    register(lifecycle.toDisposable(() => observer.disconnect()));
  }

  /// 1:1: `observe(target, options?)`
  lifecycle.IDisposable observe(DomElement target, [Object? options]) {
    observer.observe(target, options);
    return lifecycle.toDisposable(() => observer.unobserve(target));
  }
}

const int maxRecentDisposableResizeObservers = 8;

class IRecentDisposableResizeObserverContext {
  final Set<String> names = <String>{};
  bool overflow = false;
}

final Map<CodeWindow, IRecentDisposableResizeObserverContext>
    _recentDisposableResizeObserverContexts =
    <CodeWindow, IRecentDisposableResizeObserverContext>{};

void recordDisposableResizeObserverInvocation(
    CodeWindow targetWindow, String name) {
  IRecentDisposableResizeObserverContext context =
      _recentDisposableResizeObserverContexts.putIfAbsent(
          targetWindow, () {
    windowCarrier(targetWindow)
        .requestAnimationFrame(() => _recentDisposableResizeObserverContexts.remove(targetWindow));
    return IRecentDisposableResizeObserverContext();
  });

  if (context.names.contains(name)) return;
  if (context.names.length < maxRecentDisposableResizeObservers) {
    context.names.add(name);
  } else {
    context.overflow = true;
    final String max = (context.names.toList()..sort()).last;
    if (name.compareTo(max) < 0) {
      context.names.remove(max);
      context.names.add(name);
    }
  }
}

/// 1:1: `getRecentDisposableResizeObserverContextForLoopError`
String? getRecentDisposableResizeObserverContextForLoopError(
  String? message, [
  CodeWindow? targetWindow,
]) {
  if (message == null || !message.contains('ResizeObserver loop')) return null;
  final IRecentDisposableResizeObserverContext? context =
      _recentDisposableResizeObserverContexts[targetWindow ?? mainWindow];
  if (context == null) return null;
  final List<String> names = context.names.toList()..sort();
  if (context.overflow) names.add('<overflow>');
  return '[ResizeObserverLoopContext(${names.join(',')})] $message';
}

// ---------------------------------------------------------------------------
// h() / svgElem() DSL
// ---------------------------------------------------------------------------

/// 1:1: `h(tag, ...args)` / `svgElem(tag, ...args)`
final RegExp H_REGEX = RegExp(
    r'(?<tag>[\w\-]+)?(?:#(?<id>[\w\-]+))?(?<class>(?:\.(?:[\w\-]+))*)(?:@(?<name>(?:[\w\_])+))?');

Map<String, DomElement> hImpl(
  String tag,
  List<Object> args, {
  String namespace = Namespace.HTML,
}) {
  late Map<String, Object?> attributes;
  List<Object>? children;
  if (args.isNotEmpty && args.first is List<Object>) {
    attributes = <String, Object?>{};
    children = args.first as List<Object>;
  } else {
    attributes = args.isEmpty
        ? <String, Object?>{}
        : (args.first as Map).cast<String, Object?>();
    if (args.length > 1) children = args[1] as List<Object>;
  }

  final RegExpMatch? match = H_REGEX.firstMatch(tag);
  if (match == null) throw StateError('Bad use of h');
  final String tagName = match.namedGroup('tag') ?? 'div';
  final DomElement el = namespace == Namespace.HTML
      ? document.createElement(tagName)
      : document.createElementNS(namespace, tagName);
  final String? id = match.namedGroup('id');
  if (id != null) el.id = id;

  final List<String> classNames = <String>[];
  final String? classGroup = match.namedGroup('class');
  if (classGroup != null) {
    for (final String className in classGroup.split('.')) {
      if (className.isNotEmpty) classNames.add(className);
    }
  }
  final Object? attrClassName = attributes['className'];
  if (attrClassName != null) {
    for (final String className in attrClassName.toString().split('.')) {
      if (className.isNotEmpty) classNames.add(className);
    }
  }
  if (classNames.isNotEmpty) el.className = classNames.join(' ');

  final Map<String, DomElement> result = <String, DomElement>{};
  final String? name = match.namedGroup('name');
  if (name != null) result[name] = el;

  if (children != null) {
    for (final Object c in children) {
      if (c is DomElement) {
        el.appendChild(c);
      } else if (c is String) {
        el.append(c);
      } else if (c is Map<String, DomElement> && c.containsKey('root')) {
        result.addAll(c);
        el.appendChild(c['root']!);
      }
    }
  }

  attributes.forEach((String key, Object? value) {
    if (key == 'className') return;
    if (key == 'style') {
      (value as Map).forEach((Object? cssKey, Object? cssValue) {
        el.style.setProperty(
            camelCaseToHyphenCase(cssKey.toString()),
            cssValue is num ? '${cssValue}px' : '$cssValue');
      });
    } else if (key == 'tabIndex') {
      el.tabIndex = (value as num).toInt();
    } else {
      el.setAttribute(camelCaseToHyphenCase(key), value.toString());
    }
  });

  result['root'] = el;
  return result;
}

Map<String, DomElement> h(String tag, [
  Object? attributesOrChildren,
  List<Object>? children,
]) {
  final List<Object> args = <Object>[];
  if (attributesOrChildren != null) args.add(attributesOrChildren);
  if (children != null) args.add(children);
  return hImpl(tag, args);
}

Map<String, DomElement> svgElem(String tag, [
  Object? attributesOrChildren,
  List<Object>? children,
]) {
  final List<Object> args = <Object>[];
  if (attributesOrChildren != null) args.add(attributesOrChildren);
  if (children != null) args.add(children);
  return hImpl(tag, args, namespace: Namespace.SVG);
}

/// 1:1: `camelCaseToHyphenCase`
String camelCaseToHyphenCase(String str) =>
    str.replaceAllMapped(RegExp(r'([a-z])([A-Z])'),
        (Match m) => '${m.group(1)}-${m.group(2)}').toLowerCase();

/// 1:1: `copyAttributes(from, to, filter?)`
void copyAttributes(DomElement from, DomElement to, [List<String>? filter]) {
  for (final MapEntry<String, String> entry in from.attributes) {
    if (filter == null || filter.contains(entry.key)) {
      to.setAttribute(entry.key, entry.value);
    }
  }
}

void copyAttribute(DomElement from, DomElement to, String name) {
  final String? value = from.getAttribute(name);
  if (value != null && value.isNotEmpty) {
    to.setAttribute(name, value);
  } else {
    to.removeAttribute(name);
  }
}

/// 1:1: `trackAttributes(from, to, filter?)`
lifecycle.IDisposable trackAttributes(
  DomElement from,
  DomElement to, [
  List<String>? filter,
]) {
  copyAttributes(from, to, filter);
  final lifecycle.DisposableStore disposables = lifecycle.DisposableStore();
  disposables.add(sharedMutationObserver.observe(from, disposables, <String, Object?>{
    'attributes': true,
    'attributeFilter': filter,
  })((List<DomMutationRecord> mutations) {
    for (final DomMutationRecord mutation in mutations) {
      if (mutation.type == 'attributes' && mutation.attributeName != null) {
        copyAttribute(from, to, mutation.attributeName!);
      }
    }
  }));
  return disposables;
}

/// 1:1: `isEditableElement`
bool isEditableElement(DomElement element) {
  final String tag = element.tagName.toLowerCase();
  return tag == 'input' || tag == 'textarea' || element.editContext;
}

/// 1:1: `SafeTriangle`
class SafeTriangle {
  final Int16List points = Int16List(8);
  final num originX;
  final num originY;

  SafeTriangle(num originX, num originY, DomElement target)
      : originX = originX,
        originY = originY {
    final DomRect rect = target.getBoundingClientRect();
    int i = 0;
    points[i++] = rect.left.toInt();
    points[i++] = rect.top.toInt();
    points[i++] = rect.right.toInt();
    points[i++] = rect.top.toInt();
    points[i++] = rect.left.toInt();
    points[i++] = rect.bottom.toInt();
    points[i++] = rect.right.toInt();
    points[i++] = rect.bottom.toInt();
  }

  bool contains(num x, num y) {
    for (int i = 0; i < 4; i++) {
      final int p1 = 2 * i;
      final int p2 = 2 * ((i + 1) % 4);
      if (isPointWithinTriangle(x, y, originX, originY, points[p1],
          points[p1 + 1], points[p2], points[p2 + 1])) {
        return true;
      }
    }
    return false;
  }
}

// ---------------------------------------------------------------------------
// Observer nodes (`n` namespace), refs and live elements
// ---------------------------------------------------------------------------

/// 1:1: `IRef<T>` / `IRefWithVal<T>`
class IRef<T> {
  final void Function(T value) _setter;
  T? _value;
  bool _didSet = false;
  IRef(this._setter);

  void call(T value) {
    _value = value;
    _didSet = true;
    _setter(value);
  }

  /// 1:1: `get element()` — throws BugIndicatingError when not set yet.
  T get element {
    if (!_didSet) {
      throw BugIndicatingError(
          'Make sure the ref is set before accessing the element. Maybe wrong initialization order?');
    }
    return _value as T;
  }
}

/// 1:1: `IRefWithVal<T> extends IRef<T>`
class IRefWithVal<T> extends IRef<T> {
  IRefWithVal() : super((T value) {});

  @override
  void call(T value) {
    _value = value;
    _didSet = true;
  }
}

/// 1:1: `ObserverNode<T>`
class ObserverNode<T extends DomElement> {
  final List<observable.IObservable<Object?>> _deriveds =
      <observable.IObservable<Object?>>[];
  final T _element;

  ObserverNode(
    String tag,
    IRef<T>? ref,
    IRef<ObserverNode<T>?>? obsRef,
    String? ns,
    Object? className,
    Map<String, Object?> attributes,
    Object? children,
  )   : _element = (ns != null
            ? document.createElementNS(ns, tag)
            : document.createElement(tag)) as T {
    if (ref != null) ref(_element);
    if (obsRef != null) {
      obsRef(this);
      _deriveds.add(observable.derived<Object?, Object?>((observable.IReader r) {
        obsRef(this);
        return null;
      }));
    }
    if (className != null) {
      if (hasObservable(className)) {
        _deriveds.add(observable.derived<Object?, Object?>(this,
            (observable.IReader reader) {
          setClassName(_element, getClassName(className, reader));
          return null;
        }));
      } else {
        setClassName(_element, getClassName(className, null));
      }
    }

    attributes.forEach((String key, Object? value) {
      if (key == 'style') {
        (value as Map).forEach((Object? cssKey, Object? cssValue) {
          final String cssName = camelCaseToHyphenCase(cssKey.toString());
          if (observable.isObservable(cssValue)) {
            _deriveds.add(observable.derivedOpts<Object?>(
                DerivedOpts<Object?>(
                    owner: this, debugName: () => 'set.style.$cssName'),
                (observable.IReader reader) {
              _element.style.setProperty(
                  cssName,
                  convertCssValue((cssValue as observable.IObservable<Object?>)
                      .read(reader)));
              return null;
            }));
          } else {
            _element.style.setProperty(cssName, convertCssValue(cssValue));
          }
        });
      } else if (key == 'tabIndex') {
        if (observable.isObservable(value)) {
          _deriveds.add(observable.derived<Object?, Object?>(this,
              (observable.IReader reader) {
            final Object? v =
                (value as observable.IObservable<Object?>).read(reader);
            _element.tabIndex = (v as num?)?.toInt() ?? 0;
            return null;
          }));
        } else {
          _element.tabIndex = (value as num?)?.toInt() ?? 0;
        }
      } else if (key.startsWith('on')) {
        _element.eventHandlers[key] = value;
      } else {
        if (observable.isObservable(value)) {
          _deriveds.add(observable.derivedOpts<Object?>(
              DerivedOpts<Object?>(
                  owner: this, debugName: () => 'set.$key'),
              (observable.IReader reader) {
            setOrRemoveAttribute(
                _element, key, (value as observable.IObservable<Object?>).read(reader));
            return null;
          }));
        } else {
          setOrRemoveAttribute(_element, key, value);
        }
      }
    });

    if (children != null) {
      final observable.IObservable<Object?> d =
          observable.derived<Object?, Object?>(this, (observable.IReader reader) {
        _element.replaceChildren(getChildren(reader, children).cast<DomNode>());
        return null;
      });
      _deriveds.add(d);
      if (!childrenIsObservable(children)) d.get();
    }
  }

  T get element => _element;

  void readEffect(observable.IReader? reader) {
    for (final observable.IObservable<Object?> d in _deriveds) {
      d.read(reader);
    }
  }

  ObserverNode<T> keepUpdated(lifecycle.DisposableStore store) {
    observable
        .derived<Object?, Object?>((observable.IReader reader) {
      readEffect(reader);
      return null;
    })
        .recomputeInitiallyAndOnChange(store);
    return this;
  }

  /// 1:1: `toDisposableLiveElement()`
  LiveElement<T> toDisposableLiveElement() {
    final lifecycle.DisposableStore store = lifecycle.DisposableStore();
    keepUpdated(store);
    return LiveElement<T>(_element, store);
  }

  observable.IObservable<bool>? _isHovered;

  observable.IObservable<bool> get isHovered {
    final observable.IObservable<bool>? existing = _isHovered;
    if (existing != null) return existing;
    final observable.ISettableObservable<bool, Object?> hovered =
        observable.observableValue<bool, Object?>('hovered', false);
    _element.addEventListener('mouseenter', (DomEvent e) => hovered.set(true, null, null));
    _element.addEventListener('mouseleave', (DomEvent e) => hovered.set(false, null, null));
    _isHovered = hovered;
    return hovered;
  }

  observable.IObservable<bool>? _didMouseMoveDuringHover;

  observable.IObservable<bool> get didMouseMoveDuringHover {
    final observable.IObservable<bool>? existing = _didMouseMoveDuringHover;
    if (existing != null) return existing;
    bool hovering = false;
    final observable.ISettableObservable<bool, Object?> hovered =
        observable.observableValue<bool, Object?>('didMouseMoveDuringHover', false);
    _element.addEventListener('mouseenter', (DomEvent e) => hovering = true);
    _element.addEventListener('mousemove', (DomEvent e) {
      if (hovering) hovered.set(true, null, null);
    });
    _element.addEventListener('mouseleave', (DomEvent e) {
      hovering = false;
      hovered.set(false, null, null);
    });
    _didMouseMoveDuringHover = hovered;
    return hovered;
  }
}

/// 1:1: `ObserverNodeWithElement<T>`
class ObserverNodeWithElement<T extends DomElement> extends ObserverNode<T> {
  ObserverNodeWithElement(
    String tag,
    IRef<T>? ref,
    IRef<ObserverNode<T>?>? obsRef,
    String? ns,
    Object? className,
    Map<String, Object?> attributes,
    Object? children,
  ) : super(tag, ref, obsRef, ns, className, attributes, children);
}

void setClassName(DomElement domNode, String className) {
  if (isSVGElement(domNode)) {
    domNode.setAttribute('class', className);
  } else {
    domNode.className = className;
  }
}

void resolveValue<T>(Object value, observable.IReader? reader,
    void Function(T value) cb) {
  if (observable.isObservable(value)) {
    cb((value as observable.IObservable<T>).read(reader));
    return;
  }
  if (value is List) {
    for (final Object v in value.cast<Object>()) {
      resolveValue<T>(v, reader, cb);
    }
    return;
  }
  cb(value as T);
}

String getClassName(Object? className, observable.IReader? reader) {
  final StringBuffer result = StringBuffer();
  if (className == null) return '';
  resolveValue<String>(className, reader, (String val) {
    if (val.isEmpty) return;
    if (result.isEmpty) {
      result.write(val);
    } else {
      result.write(' $val');
    }
  });
  return result.toString();
}

bool hasObservable(Object value) {
  if (observable.isObservable(value)) return true;
  if (value is List) {
    return value.any((Object? v) => v != null && hasObservable(v));
  }
  return false;
}

String convertCssValue(Object? value) =>
    value is num ? '${value}px' : value.toString();

bool childrenIsObservable(Object children) {
  if (observable.isObservable(children)) return true;
  if (children is List) {
    return children.any((Object? c) => c != null && childrenIsObservable(c));
  }
  return false;
}

List<Object> getChildren(observable.IReader? reader, Object children) {
  if (observable.isObservable(children)) {
    return getChildren(reader, (children as observable.IObservable<Object>).read(reader));
  }
  if (children is List) {
    return children
        .expand((Object? c) => c == null ? <Object>[] : getChildren(reader, c))
        .toList();
  }
  if (children is ObserverNode) {
    if (reader != null) children.readEffect(reader);
    return <Object>[children._element];
  }
  if (children is String) return <Object>[children];
  if (children is DomElement) return <Object>[children];
  return <Object>[];
}

void setOrRemoveAttribute(DomElement element, String key, Object? value) {
  final String name = camelCaseToHyphenCase(key);
  if (value == null) {
    element.removeAttribute(name);
  } else {
    element.setAttribute(name, value.toString());
  }
}

/// 1:1: `LiveElement<T>`
class LiveElement<T extends DomElement> implements lifecycle.IDisposable {
  final T element;
  final lifecycle.IDisposable _disposable;
  LiveElement(this.element, this._disposable);

  @override
  void dispose() => _disposable.dispose();
}

/// 1:1: `namespace n` — factory surface for observer nodes.
class n {
  static ObserverNode<T> nodeNs<T extends DomElement>(
    String tag, [
    Map<String, Object?>? attributes,
    Object? children,
    String? ns,
  ]) {
    final Map<String, Object?> attrs =
        attributes == null ? <String, Object?>{} : Map<String, Object?>.from(attributes);
    final Object? className = attrs.remove('class');
    final IRef<T>? ref = attrs.remove('ref') as IRef<T>?;
    final IRef<ObserverNode<T>?>? obsRef =
        attrs.remove('obsRef') as IRef<ObserverNode<T>?>?;
    return ObserverNodeWithElement<T>(
        tag, ref, obsRef, ns, className, attrs, children);
  }

  static ObserverNode<DomElement> div([
    Map<String, Object?>? attributes,
    Object? children,
  ]) =>
      nodeNs<DomElement>('div', attributes, children);

  static ObserverNode<DomElement> elem(
    String tag, [
    Map<String, Object?>? attributes,
    Object? children,
  ]) =>
      nodeNs<DomElement>(tag, attributes, children);

  static ObserverNode<DomElement> svg([
    Map<String, Object?>? attributes,
    Object? children,
  ]) =>
      nodeNs<DomElement>('svg', attributes, children, Namespace.SVG);

  static ObserverNode<DomElement> svgElem(
    String tag, [
    Map<String, Object?>? attributes,
    Object? children,
  ]) =>
      nodeNs<DomElement>(tag, attributes, children, Namespace.SVG);

  static IRefWithVal<T> ref<T extends DomElement>() => IRefWithVal<T>();
}

/// 1:1: `ConnectionObserverElement` custom element.
class ConnectionObserverElement extends DomElement {
  void Function()? onDidConnect;
  void Function()? onDidDisconnect;

  ConnectionObserverElement() : super('connection-observer');

  void disconnectedCallback() => onDidDisconnect?.call();
  void connectedCallback() => onDidConnect?.call();
}

// Module-load side effect: customElements.define('connection-observer', ...)
final bool _connectionObserverRegistered = _registerConnectionObserver();

bool _registerConnectionObserver() {
  if (customElements.get('connection-observer') == null) {
    customElements.define('connection-observer', ConnectionObserverElement);
  }
  return true;
}

/// 1:1: `append(parent, ...children)`.
Object? append(DomElement parent, [List<Object> children = const <Object>[]]) {
  parent.appendAll(children);
  if (children.length == 1 && children.first is! String) return children.first;
  return null;
}



