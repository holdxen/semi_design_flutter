// Data-driven port test for batch103: editor/browser/gpu/css/decorationCssRuleExtractor.ts.
import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:semi_design_flutter/src/monaco/base/browser/dom.dart';
import 'package:semi_design_flutter/src/monaco/editor/browser/gpu/css/decorationCssRuleExtractor.dart';

final Map<String, dynamic> truth =
    jsonDecode(File('tool/ts2dart/batch103_truth.json').readAsStringSync())
        as Map<String, dynamic>;

List<String> selectors(List<DomCSSRule> rules) =>
    rules.map((DomCSSRule r) => r.selectorText ?? '').toList();

void main() {
  setUp(() {
    document.styleSheets.clear();

    final DomCSSStyleRule nested = DomCSSStyleRule('.nested-class');
    final DomCSSStyleRule rule1 =
        DomCSSStyleRule('.ghost-text-decoration { color: red; }');
    rule1.nestedRules = <DomCSSRule>[nested];
    final DomStyleSheet sheetA = DomStyleSheet();
    sheetA.cssRules.addAll(<DomCSSRule>[
      rule1,
      DomCSSStyleRule('.ghost-text-decoration:hover'),
      DomCSSStyleRule('.ghost-text-decoration-extra'),
      DomCSSStyleRule('.syntax-highlighted'),
      DomCSSStyleRule('.syntax-highlighted-keyword'),
      DomCSSStyleRule('.x .ghost-text-decoration'),
      DomCSSStyleRule('.ghost-text-decoration.foo'),
      DomCSSStyleRule('.other'),
    ]);

    final DomCSSStyleRule imported =
        DomCSSStyleRule('.ghost-text-decoration [data-x]');
    final DomStyleSheet importedSheet = DomStyleSheet()
      ..cssRules.add(imported);
    final DomCSSImportRule importRule = DomCSSImportRule();
    importRule.ruleStyleSheet = importedSheet;
    final DomStyleSheet sheetB = DomStyleSheet()
      ..cssRules.add(importRule);

    document.styleSheets.addAll(<DomStyleSheet>[sheetA, sheetB]);
  });

  tearDown(() => document.styleSheets.clear());

  test('exports and constructor DOM shape', () {
    expect(truth['exports'], <dynamic>['DecorationCssRuleExtractor']);
    final DecorationCssRuleExtractor extractor = DecorationCssRuleExtractor();
    final Map<String, dynamic> t = truth['initial'] as Map<String, dynamic>;
    expect(extractor.container.localName, t['containerTag']);
    expect(extractor.container.className, t['containerClass']);
    expect(extractor.dummyElement.localName, t['dummyTag']);
    expect(identical(extractor.dummyElement.parentNode, extractor.container),
        t['dummyParent']);
    expect(extractor.container.parentNode == null, t['containerParent']);
    extractor.dispose();
  });

  test('collects matching rules including imports, pseudo and nesting', () {
    final DecorationCssRuleExtractor extractor = DecorationCssRuleExtractor();
    final DomElement canvas = DomElement('CANVAS');

    final List<DomCSSRule> first = extractor.getStyleRules(
        canvas, 'ghost-text-decoration syntax-highlighted');
    final Map<String, dynamic> t = truth['first'] as Map<String, dynamic>;
    expect(selectors(first), (t['rules'] as List<dynamic>)
        .map((dynamic r) => (r as List<dynamic>)[1] as String)
        .toList());
    expect(extractor.dummyElement.className, t['dummyClass']);
    expect(canvas.childNodes.isEmpty, isTrue);
    expect(extractor.container.parentNode, isNull);

    final List<DomCSSRule> second = extractor.getStyleRules(
        canvas, 'ghost-text-decoration syntax-highlighted');
    expect(identical(first, second),
        (truth['second'] as Map<String, dynamic>)['sameArray']);

    final List<DomCSSRule> prefix =
        extractor.getStyleRules(canvas, 'ghost-text');
    expect(prefix, isEmpty);

    final List<DomCSSRule> nested =
        extractor.getStyleRules(canvas, 'nested-class');
    expect(selectors(nested), (truth['nested'] as Map<String, dynamic>)['rules']
        .map((dynamic r) => (r as List<dynamic>)[1] as String)
        .toList());

    extractor.dispose();
  });

  test('css variables use computed style and are cached until clear', () {
    final DecorationCssRuleExtractor extractor = DecorationCssRuleExtractor();
    final DomElement canvas = DomElement('CANVAS');
    extractor.container.computedStyle = DomStyle()
      ..setProperty('--accent', '  #ff0000  ')
      ..setProperty('--empty', '   ');

    expect(extractor.resolveCssVariable(canvas, '--accent'),
        truth['variable']);
    expect(extractor.resolveCssVariable(canvas, '--accent'),
        truth['variableCached']);
    expect(extractor.resolveCssVariable(canvas, '--empty'),
        truth['emptyVariable']);
    expect(canvas.childNodes.isEmpty, isTrue);

    extractor.clear();
    expect(extractor.resolveCssVariable(canvas, '--accent'),
        truth['variableAfterClear']);

    final List<DomCSSRule> first = extractor.getStyleRules(
        canvas, 'ghost-text-decoration syntax-highlighted');
    final List<DomCSSRule> second = extractor.getStyleRules(
        canvas, 'ghost-text-decoration syntax-highlighted');
    expect(identical(first, second), isTrue);
    extractor.clear();
    final List<DomCSSRule> third = extractor.getStyleRules(
        canvas, 'ghost-text-decoration syntax-highlighted');
    expect(identical(first, third),
        !(truth['afterClear'] as Map<String, dynamic>)['newArray']);
    expect(selectors(third), (truth['afterClear'] as Map<String, dynamic>)['rules']
        .map((dynamic r) => (r as List<dynamic>)[1] as String)
        .toList());

    extractor.dispose();
  });

  test('dispose removes the injected container', () {
    final DecorationCssRuleExtractor extractor = DecorationCssRuleExtractor();
    final DomElement canvas = DomElement('CANVAS');
    extractor.getStyleRules(canvas, 'ghost-text-decoration');
    expect(extractor.container.parentNode, isNull);
    extractor.dispose();
    expect(extractor.container.parentNode,
        (truth['afterDispose'] as Map<String, dynamic>)['containerParent'] ? null : canvas);
  });
}
