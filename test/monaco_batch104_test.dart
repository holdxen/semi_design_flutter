// 1:1 port test of editor/test/browser/gpu/decorationCssRulerExtractor.test.ts.
// Expected values come from the real TS extractor driven by _batch104_truth.cjs.
import 'package:flutter_test/flutter_test.dart';
import 'package:semi_design_flutter/src/monaco/base/browser/dom.dart' as DOM;
import 'package:semi_design_flutter/src/monaco/base/common/lifecycle.dart';
import 'package:semi_design_flutter/src/monaco/editor/browser/gpu/css/decorationCssRuleExtractor.dart';
import 'package:semi_design_flutter/src/monaco/editor/test/browser/gpu/decorationCssRulerExtractor.test.dart'
    as src;

final Map<String, dynamic> truth = src.decorationCssRulerExtractorTruth;

List<String> _expectedCss(String key) => (truth[key]['cssText'] as List<dynamic>)
    .map((dynamic s) => s as String)
    .toList();

void main() {
  late DOM.DomElement container;
  late DecorationCssRuleExtractor extractor;
  late DisposableStore store;
  final String c0 = truth['class0'] as String;
  final String c1 = truth['class1'] as String;

  setUp(() {
    DOM.domParseStyleTextContent = true;
    DOM.document.styleSheets.clear();
    store = DisposableStore();
    extractor = store.add(DecorationCssRuleExtractor());
    container = DOM.$('div');
    DOM.document.body.appendChild(container);
  });

  tearDown(() {
    DOM.domParseStyleTextContent = false;
    container.remove();
    store.dispose();
    DOM.document.styleSheets.clear();
  });

  void addStyleElement(String content) {
    final DOM.DomElement styleElement = DOM.$('style');
    styleElement.textContent = content;
    container.appendChild(styleElement);
  }

  void assertStyles(String className, List<String> expectedCssText) {
    expect(
      extractor
          .getStyleRules(container, className)
          .map((DOM.DomCSSRule r) => r.cssText)
          .toList(),
      expectedCssText,
    );
  }

  test('exports and unknown class should give no styles', () {
    expect(truth['exports'], <dynamic>['DecorationCssRuleExtractor']);
    assertStyles('$c0-missing', _expectedCss('unknown'));
  });

  test('single style should be picked up', () {
    addStyleElement('.$c0 { color: red; }');
    assertStyles(c0, _expectedCss('single'));
  });

  test('multiple styles from the same selector should be picked up', () {
    addStyleElement('.$c0 { color: red; opacity: 0.5; }');
    assertStyles(c0, _expectedCss('sameSelector'));
  });

  test('multiple styles from different selectors should be picked up', () {
    addStyleElement([
      '.$c0 { color: red; opacity: 0.5; }',
      '.$c0:hover { opacity: 1; }',
    ].join('\n'));
    assertStyles(c0, _expectedCss('twoSelectors'));
  });

  test('multiple styles from different stylesheets should be picked up', () {
    addStyleElement('.$c0 { color: red; opacity: 0.5; }');
    addStyleElement('.$c0:hover { opacity: 1; }');
    assertStyles(c0, _expectedCss('twoStylesheets'));
  });

  test('should not pick up styles where the prefix is the class', () {
    addStyleElement([
      '.$c0 { color: red; }',
      '.$c0-ignoreme { opacity: 1; }',
      '.$c0' 'fake { opacity: 1; }',
    ].join('\n'));
    assertStyles(c0, _expectedCss('prefixIgnored'));
  });

  test('should pick up styles with pseudo-class selectors', () {
    addStyleElement('.$c0 { background-color: green; }');
    addStyleElement('.$c0:not(.other) { color: blue; }');
    final List<DOM.DomCSSRule> rules = extractor.getStyleRules(container, c0);
    expect(rules.length, truth['pseudoClass']['length']);
    expect(rules[0].style.getPropertyValue('background-color'),
        truth['pseudoClass']['backgroundColor']);
    expect(rules[1].style.getPropertyValue('color'),
        truth['pseudoClass']['color']);
  });

  test('should pick up styles when className has multiple classes', () {
    addStyleElement([
      '.$c0 { color: red; }',
      '.$c1 { opacity: 0.5; }',
      '.$c0.$c1 { font-weight: bold; }',
    ].join('\n'));
    final List<DOM.DomCSSRule> rules =
        extractor.getStyleRules(container, '$c0 $c1');
    expect(rules.length, truth['multiClass']['length']);
    expect(rules.map((DOM.DomCSSRule r) => r.cssText).toList(),
        _expectedCss('multiClass'));
  });
}
