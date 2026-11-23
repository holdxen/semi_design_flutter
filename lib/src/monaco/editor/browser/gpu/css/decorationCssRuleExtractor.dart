// 1:1 port of vscode/src/vs/editor/browser/gpu/css/decorationCssRuleExtractor.ts
import '../../../../base/browser/dom.dart' as DOM
    show DomCSSImportRule, DomCSSRule, DomCSSStyleRule, DomElement, DomStyleSheet,
        $, getActiveDocument, getActiveWindow, windowCarrier;
import '../../../../base/common/lifecycle.dart'
    show Disposable, toDisposable;

/// Extracts CSS rules that would be applied to certain decoration classes.
class DecorationCssRuleExtractor extends Disposable {
  late final DOM.DomElement _container;
  late final DOM.DomElement _dummyElement;

  final Map<String, List<DOM.DomCSSRule>> _ruleCache =
      <String, List<DOM.DomCSSRule>>{};
  final Map<String, String> _cssVariableCache = <String, String>{};

  /// TS private fields are exposed read-only for the data-driven truth test.
  DOM.DomElement get container => _container;
  DOM.DomElement get dummyElement => _dummyElement;

  DecorationCssRuleExtractor() : super() {
    _container = DOM.$(r'div.monaco-decoration-css-rule-extractor');
    _dummyElement = DOM.$('span');
    _container.appendChild(_dummyElement);

    register(toDisposable(() => _container.remove()));
  }

  List<DOM.DomCSSRule> getStyleRules(
      DOM.DomElement canvas, String decorationClassName) {
    final List<DOM.DomCSSRule>? existing = _ruleCache[decorationClassName];
    if (existing != null) {
      return existing;
    }

    _dummyElement.className = decorationClassName;
    canvas.appendChild(_container);

    final List<DOM.DomCSSRule> rules = _getStyleRules(decorationClassName);
    _ruleCache[decorationClassName] = rules;

    canvas.removeChild(_container);
    return rules;
  }

  List<DOM.DomCSSRule> _getStyleRules(String className) {
    final List<DOM.DomCSSRule> rules = <DOM.DomCSSRule>[];
    final List<DOM.DomStyleSheet> stylesheets =
        List<DOM.DomStyleSheet>.of(DOM.getActiveDocument().styleSheets);

    // className can be space-separated (e.g. 'ghost-text-decoration syntax-highlighted').
    final List<String> classNames = className
        .split(' ')
        .where((String c) => c.isNotEmpty)
        .toList();

    for (final DOM.DomStyleSheet stylesheet in stylesheets) {
      _collectMatchingRules(stylesheet.cssRules, classNames, rules);
    }
    return rules;
  }

  void _collectMatchingRules(List<DOM.DomCSSRule> cssRules,
      List<String> classNames, List<DOM.DomCSSRule> result) {
    for (final DOM.DomCSSRule rule in cssRules) {
      if (rule.isCSSImportRule) {
        final DOM.DomStyleSheet? sheet = rule.styleSheet;
        if (sheet != null) {
          _collectMatchingRules(sheet.cssRules, classNames, result);
        }
      } else if (rule.isCSSStyleRule) {
        final String? selectorText = rule.selectorText;
        if (selectorText == null) continue;
        for (final String className in classNames) {
          final String searchTerm = '.$className';
          final int index = selectorText.indexOf(searchTerm);
          if (index != -1) {
            final int endOfResult = index + searchTerm.length;
            if (selectorText.length == endOfResult ||
                RegExp(r'[ :.]').hasMatch(selectorText.substring(
                    endOfResult, (endOfResult + 1).clamp(0, selectorText.length)))) {
              result.add(rule);
              break;
            }
          }
        }
        final List<DOM.DomCSSRule>? nested = rule.cssRules;
        if (nested != null && nested.isNotEmpty) {
          _collectMatchingRules(nested, classNames, result);
        }
      }
    }
  }

  /// Resolves a CSS variable to its computed value using the container element.
  String resolveCssVariable(DOM.DomElement canvas, String variableName) {
    final String? cached = _cssVariableCache[variableName];
    if (cached != null) return cached;

    canvas.appendChild(_container);
    final String result = DOM.windowCarrier(DOM.getActiveWindow())
        .getComputedStyle(_container)
        .getPropertyValue(variableName)
        .trim();
    canvas.removeChild(_container);
    _cssVariableCache[variableName] = result;
    return result;
  }

  /// Clears all cached CSS rules and CSS variable values.
  void clear() {
    _ruleCache.clear();
    _cssVariableCache.clear();
  }
}
