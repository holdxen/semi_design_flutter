// 1:1 port of vs/base/browser/domStylesheets.ts
import 'dart:collection' show HashSet, LinkedHashMap;

import 'browser.dart' as browser;
import 'dom.dart'
    show
        DomCSSRule,
        DomElement,
        DomNode,
        document,
        getWindows,
        sharedMutationObserver,
        windowCarrier,
        IRegisteredCodeWindow;
import 'window.dart' show CodeWindow, mainWindow;
import '../common/lifecycle.dart'
    show Disposable, DisposableStore, IDisposable, toDisposable;
import '../common/observable.dart' show IObservable, autorun;

/// Test seam for `browser.isFirefox` (defaults to the real value).
bool Function() isFirefoxProvider = () => browser.isFirefox;

final Map<DomElement, Set<DomElement>> globalStylesheets =
    LinkedHashMap<DomElement, Set<DomElement>>.identity();

/// 1:1: `isGlobalStylesheet`
bool isGlobalStylesheet(DomNode node) =>
    globalStylesheets.containsKey(node);

class WrappedStyleElement extends Disposable {
  String _currentCssStyle = '';
  DomElement? _styleSheet;
  final DisposableStore _store = DisposableStore();

  WrappedStyleElement() {
    register(_store);
  }

  void setStyle(String cssStyle) {
    if (cssStyle == _currentCssStyle) return;
    _currentCssStyle = cssStyle;

    final DomElement? existing = _styleSheet;
    if (existing == null) {
      _styleSheet = createStyleSheet(windowCarrier(mainWindow).document.head,
          (DomElement s) => s.textContent = cssStyle, _store);
    } else {
      existing.textContent = cssStyle;
    }
  }

  @override
  void dispose() {
    super.dispose();
    _styleSheet = null;
  }

}

/// 1:1: `createStyleSheet`
DomElement createStyleSheet([
  DomElement? container,
  void Function(DomElement style)? beforeAppend,
  DisposableStore? disposableStore,
]) {
  final DomElement style =
      document.createElement('style');
  style.type = 'text/css';
  style.media = 'screen';
  beforeAppend?.call(style);
  (container ?? windowCarrier(mainWindow).document.head).appendChild(style);

  if (disposableStore != null) {
    disposableStore.add(toDisposable(() => style.remove()));
  }

  // With <head> as container, the stylesheet becomes global and is tracked
  // to support auxiliary windows to clone the stylesheet.
  if (identical(container ?? windowCarrier(mainWindow).document.head,
      windowCarrier(mainWindow).document.head)) {
    final Set<DomElement> globalStylesheetClones =
        HashSet<DomElement>.identity();
    globalStylesheets[style] = globalStylesheetClones;
    if (disposableStore != null) {
      disposableStore.add(toDisposable(() => globalStylesheets.remove(style)));
    }

    for (final IRegisteredCodeWindow registration in getWindows()) {
      if (identical(registration.window, mainWindow)) continue;
      final IDisposable cloneDisposable = registration.disposables.add(
          cloneGlobalStyleSheet(style, globalStylesheetClones,
              registration.window));
      disposableStore?.add(cloneDisposable);
    }
  }

  return style;
}

/// 1:1: `cloneGlobalStylesheets`
IDisposable cloneGlobalStylesheets(CodeWindow targetWindow) {
  final DisposableStore disposables = DisposableStore();

  globalStylesheets.forEach((DomElement globalStylesheet,
      Set<DomElement> clonedGlobalStylesheets) {
    disposables.add(cloneGlobalStyleSheet(globalStylesheet,
        clonedGlobalStylesheets, targetWindow));
  });

  return disposables;
}

/// 1:1: `cloneGlobalStyleSheet`
IDisposable cloneGlobalStyleSheet(
  DomElement globalStylesheet,
  Set<DomElement> globalStylesheetClones,
  CodeWindow targetWindow,
) {
  final DisposableStore disposables = DisposableStore();

  final DomElement clone = globalStylesheet.cloneNode();
  windowCarrier(targetWindow).document.head.appendChild(clone);
  disposables.add(toDisposable(() => clone.remove()));

  for (final DomCSSRule rule in globalStylesheet.sheet?.cssRules ?? <DomCSSRule>[]) {
    clone.sheet?.insertRule(rule.cssText, clone.sheet?.cssRules.length);
  }

  disposables.add(sharedMutationObserver.observe(
      globalStylesheet, disposables, <String, Object?>{
    'childList': true,
    'subtree': isFirefoxProvider(),
    'characterData': isFirefoxProvider(),
  })((_) {
    clone.textContent = globalStylesheet.textContent;
  }));

  globalStylesheetClones.add(clone);
  disposables.add(toDisposable(() => globalStylesheetClones.remove(clone)));

  return disposables;
}

DomElement? _sharedStyleSheet;

DomElement getSharedStyleSheet() {
  _sharedStyleSheet ??= createStyleSheet();
  return _sharedStyleSheet!;
}

/// 1:1: `createCSSRule`
void createCSSRule(String selector, String cssText, [DomElement? style]) {
  style ??= getSharedStyleSheet();
  if (cssText.isEmpty) return;

  style.sheet?.insertRule('$selector {$cssText}', 0);

  for (final DomElement clonedGlobalStylesheet in globalStylesheets[style] ??
      <DomElement>{}) {
    createCSSRule(selector, cssText, clonedGlobalStylesheet);
  }
}

/// 1:1: `removeCSSRulesContainingSelector`
void removeCSSRulesContainingSelector(String ruleName, [DomElement? style]) {
  style ??= getSharedStyleSheet();

  final List<DomCSSRule> rules = style.sheet?.cssRules ?? <DomCSSRule>[];
  final List<int> toDelete = <int>[];
  for (int i = 0; i < rules.length; i++) {
    final DomCSSRule rule = rules[i];
    if (isCSSStyleRule(rule) &&
        rule.selectorText!.indexOf(ruleName) != -1) {
      toDelete.add(i);
    }
  }

  for (int i = toDelete.length - 1; i >= 0; i--) {
    style.sheet?.deleteRule(toDelete[i]);
  }

  for (final DomElement clonedGlobalStylesheet in globalStylesheets[style] ??
      <DomElement>{}) {
    removeCSSRulesContainingSelector(ruleName, clonedGlobalStylesheet);
  }
}

bool isCSSStyleRule(DomCSSRule rule) => rule.selectorText is String;

/// 1:1: `createStyleSheetFromObservable`
IDisposable createStyleSheetFromObservable(IObservable<String> css) {
  final DisposableStore store = DisposableStore();
  final WrappedStyleElement w = store.add(WrappedStyleElement());
  store.add(autorun((reader) {
    w.setStyle(css.read(reader));
  }));
  return store;
}
