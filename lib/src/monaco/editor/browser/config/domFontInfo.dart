// ---------------------------------------------------------------------------
// Port of vscode/src/vs/editor/browser/config/domFontInfo.ts @bfbf12b
// Translated 1:1 from TypeScript. Do not refactor.
//
// Adaptations (documented inline):
//  * `FastDomNode<HTMLElement> | HTMLElement` union → `Object` carrier;
//    `domNode instanceof FastDomNode` → `is FastDomNode<DomElement>` (Dart
//    generics are covariant, so every `FastDomNode<T extends DomElement>`
//    satisfies it — the bound-conforming form of the raw `is FastDomNode`).
//  * The raw-`HTMLElement` branch writes `domNode.style.*` dynamically → the
//    same property reads on a `dynamic` carrier (call sites hand the ported
//    element carriers that expose `style` maps).
// ---------------------------------------------------------------------------
import '../../../base/browser/fastDomNode.dart'
    show DomElement, FastDomNode;
import '../../common/config/fontInfo.dart' show BareFontInfo;

void applyFontInfo(Object domNode, BareFontInfo fontInfo) {
  if (domNode is FastDomNode<DomElement>) {
    domNode.setFontFamily(fontInfo.getMassagedFontFamily());
    domNode.setFontWeight(fontInfo.fontWeight);
    domNode.setFontSize(fontInfo.fontSize);
    domNode.setFontFeatureSettings(fontInfo.fontFeatureSettings);
    domNode.setFontVariationSettings(fontInfo.fontVariationSettings);
    domNode.setLineHeight(fontInfo.lineHeight);
    domNode.setLetterSpacing(fontInfo.letterSpacing);
  } else {
    final dynamic style = (domNode as dynamic).style;
    style['fontFamily'] = fontInfo.getMassagedFontFamily();
    style['fontWeight'] = fontInfo.fontWeight;
    style['fontSize'] = '${_jsNum(fontInfo.fontSize)}px';
    style['fontFeatureSettings'] = fontInfo.fontFeatureSettings;
    style['fontVariationSettings'] = fontInfo.fontVariationSettings;
    style['lineHeight'] = '${_jsNum(fontInfo.lineHeight)}px';
    style['letterSpacing'] = '${_jsNum(fontInfo.letterSpacing)}px';
  }
}

/// JS `String(number)` semantics: integer-valued numbers carry no `.0`
/// (`fontInfo.fontSize + 'px'` is `"14px"`, not `"14.0px"`).
String _jsNum(num value) {
  if (value is int) {
    return value.toString();
  }
  final double asDouble = value.toDouble();
  if (asDouble.isFinite && asDouble == asDouble.truncateToDouble()) {
    return asDouble.toInt().toString();
  }
  return asDouble.toString();
}