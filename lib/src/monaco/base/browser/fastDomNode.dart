// 1:1 port of vscode/src/vs/base/browser/fastDomNode.ts
// The DOM `HTMLElement` is bridged through the [DomElement] carrier exposing
// the exact surface this class touches (style map, className, classList,
// attributes, children). Every setter keeps the source's dirty-check (early
// return when the cached value is unchanged).

/// Opaque DOM element carrier: the subset of `HTMLElement` used here.
abstract class DomElement {
  Map<String, String> get style;
  String get className;
  set className(String value);
  DomTokenList get classList;
  void focus();
  void setAttribute(String name, String value);
  void removeAttribute(String name);
  void appendChild(DomElement child);
  void removeChild(DomElement child);
}

/// 1:1: DOM `classList.toggle(className, force?)`.
abstract class DomTokenList {
  void toggle(String token, [bool? force]);
}

/// 1:1: `export class FastDomNode<T extends HTMLElement>`
class FastDomNode<T extends DomElement> {
  String _maxWidth = '';
  String _width = '';
  String _height = '';
  String _top = '';
  String _left = '';
  String _bottom = '';
  String _right = '';
  String _paddingTop = '';
  String _paddingLeft = '';
  String _paddingBottom = '';
  String _paddingRight = '';
  String _fontFamily = '';
  String _fontWeight = '';
  String _fontSize = '';
  String _fontStyle = '';
  String _fontFeatureSettings = '';
  String _fontVariationSettings = '';
  String _textDecoration = '';
  String _lineHeight = '';
  String _letterSpacing = '';
  String _className = '';
  String _display = '';
  String _position = '';
  String _visibility = '';
  String _color = '';
  String _backgroundColor = '';
  bool _layerHint = false;
  String _contain = 'none';
  String _boxShadow = '';

  /// 1:1: `public readonly domNode: T`
  final T domNode;

  FastDomNode(this.domNode);

  /// 1:1: `public focus(): void`
  void focus() => domNode.focus();

  void _setStyle(String key, Object raw, String field, void Function(String) write) {
    final String value = numberAsPixels(raw);
    if (field == value) {
      return;
    }
    write(value);
    domNode.style[key] = value;
  }

  void setMaxWidth(Object maxWidth) => _setStyle(
      'maxWidth', maxWidth, _maxWidth, (String v) => _maxWidth = v);
  void setWidth(Object width) =>
      _setStyle('width', width, _width, (String v) => _width = v);
  void setHeight(Object height) =>
      _setStyle('height', height, _height, (String v) => _height = v);
  void setTop(Object top) =>
      _setStyle('top', top, _top, (String v) => _top = v);
  void setLeft(Object left) =>
      _setStyle('left', left, _left, (String v) => _left = v);
  void setBottom(Object bottom) =>
      _setStyle('bottom', bottom, _bottom, (String v) => _bottom = v);
  void setRight(Object right) =>
      _setStyle('right', right, _right, (String v) => _right = v);
  void setPaddingTop(Object paddingTop) => _setStyle(
      'paddingTop', paddingTop, _paddingTop, (String v) => _paddingTop = v);
  void setPaddingLeft(Object paddingLeft) => _setStyle(
      'paddingLeft', paddingLeft, _paddingLeft, (String v) => _paddingLeft = v);
  void setPaddingBottom(Object paddingBottom) => _setStyle('paddingBottom',
      paddingBottom, _paddingBottom, (String v) => _paddingBottom = v);
  void setPaddingRight(Object paddingRight) => _setStyle('paddingRight',
      paddingRight, _paddingRight, (String v) => _paddingRight = v);
  void setFontSize(Object fontSize) =>
      _setStyle('fontSize', fontSize, _fontSize, (String v) => _fontSize = v);
  void setLineHeight(Object lineHeight) => _setStyle(
      'lineHeight', lineHeight, _lineHeight, (String v) => _lineHeight = v);
  void setLetterSpacing(Object letterSpacing) => _setStyle('letterSpacing',
      letterSpacing, _letterSpacing, (String v) => _letterSpacing = v);

  void _setString(String key, String value, String field, void Function(String) write) {
    if (field == value) {
      return;
    }
    write(value);
    domNode.style[key] = value;
  }

  void setFontFamily(String fontFamily) =>
      _setString('fontFamily', fontFamily, _fontFamily, (String v) => _fontFamily = v);
  void setFontWeight(String fontWeight) =>
      _setString('fontWeight', fontWeight, _fontWeight, (String v) => _fontWeight = v);
  void setFontStyle(String fontStyle) =>
      _setString('fontStyle', fontStyle, _fontStyle, (String v) => _fontStyle = v);
  void setFontFeatureSettings(String fontFeatureSettings) => _setString(
      'fontFeatureSettings', fontFeatureSettings, _fontFeatureSettings,
      (String v) => _fontFeatureSettings = v);
  void setFontVariationSettings(String fontVariationSettings) => _setString(
      'fontVariationSettings', fontVariationSettings, _fontVariationSettings,
      (String v) => _fontVariationSettings = v);
  void setTextDecoration(String textDecoration) => _setString(
      'textDecoration', textDecoration, _textDecoration,
      (String v) => _textDecoration = v);
  void setDisplay(String display) =>
      _setString('display', display, _display, (String v) => _display = v);
  void setPosition(String position) =>
      _setString('position', position, _position, (String v) => _position = v);
  void setVisibility(String visibility) => _setString(
      'visibility', visibility, _visibility, (String v) => _visibility = v);
  void setColor(String color) =>
      _setString('color', color, _color, (String v) => _color = v);
  void setBackgroundColor(String backgroundColor) => _setString(
      'backgroundColor', backgroundColor, _backgroundColor,
      (String v) => _backgroundColor = v);
  void setBoxShadow(String boxShadow) => _setString(
      'boxShadow', boxShadow, _boxShadow, (String v) => _boxShadow = v);

  void setClassName(String className) {
    if (_className == className) {
      return;
    }
    _className = className;
    domNode.className = _className;
  }

  /// 1:1: `public toggleClassName(className, shouldHaveIt?)`
  void toggleClassName(String className, [bool? shouldHaveIt]) {
    domNode.classList.toggle(className, shouldHaveIt);
    _className = domNode.className;
  }

  void setLayerHinting(bool layerHint) {
    if (_layerHint == layerHint) {
      return;
    }
    _layerHint = layerHint;
    domNode.style['transform'] =
        _layerHint ? 'translate3d(0px, 0px, 0px)' : '';
  }

  void setContain(String contain) {
    if (_contain == contain) {
      return;
    }
    _contain = contain;
    domNode.style['contain'] = _contain;
  }

  void setAttribute(String name, String value) =>
      domNode.setAttribute(name, value);

  void removeAttribute(String name) => domNode.removeAttribute(name);

  void appendChild(FastDomNode child) => domNode.appendChild(child.domNode);

  void removeChild(FastDomNode child) => domNode.removeChild(child.domNode);
}

/// 1:1: `function numberAsPixels(value): string`
String numberAsPixels(Object value) =>
    value is num ? '${value}px' : value as String;

/// 1:1: `export function createFastDomNode<T>(domNode): FastDomNode<T>`
FastDomNode<T> createFastDomNode<T extends DomElement>(T domNode) =>
    FastDomNode<T>(domNode);
