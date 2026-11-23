// ---------------------------------------------------------------------------
// Port of vscode/src/vs/base/browser/ui/scrollbar/scrollbarVisibilityController.ts
// Translated 1:1. `FastDomNode<HTMLElement>` is a carrier; `TimeoutTimer` is
// injected through a small interface so reveal scheduling can be tested
// synchronously.
// ---------------------------------------------------------------------------

import '../../../common/async.dart' show TimeoutTimer;
import '../../../common/lifecycle.dart' show Disposable, IDisposable;
import '../../../common/scrollable.dart' show ScrollbarVisibility;
import '../../fastDomNode.dart' show FastDomNode;

/// 1:1: injectable reveal timer surface (`TimeoutTimer.setIfNotSet` / `cancel`).
abstract class RevealTimer {
  void setIfNotSet(void Function() runner, int timeout);
  void cancel();
}

/// Adapts the real [TimeoutTimer] to [RevealTimer].
class _TimeoutTimerAdapter implements RevealTimer {
  _TimeoutTimerAdapter(this._timer);
  final TimeoutTimer _timer;
  @override
  void setIfNotSet(void Function() runner, int timeout) =>
      _timer.setIfNotSet(runner, timeout);
  @override
  void cancel() => _timer.cancel();
}

/// Injectable timer factory — default wraps a real `TimeoutTimer`.
RevealTimer Function() revealTimerFactory = () => _TimeoutTimerAdapter(TimeoutTimer());

/// 1:1: `export class ScrollbarVisibilityController extends Disposable`
class ScrollbarVisibilityController extends Disposable {
  late int _visibility; // ScrollbarVisibility
  late final String _visibleClassName;
  late final String _invisibleClassName;
  FastDomNode? _domNode;
  bool _rawShouldBeVisible = false;
  bool _shouldBeVisible = false;
  bool _isNeeded = false;
  bool _isVisible = false;
  late final RevealTimer _revealTimer;

  ScrollbarVisibilityController(
    int visibility,
    String visibleClassName,
    String invisibleClassName,
  ) : super() {
    _visibility = visibility;
    _visibleClassName = visibleClassName;
    _invisibleClassName = invisibleClassName;
    _domNode = null;
    _isVisible = false;
    _isNeeded = false;
    _rawShouldBeVisible = false;
    _shouldBeVisible = false;
    _revealTimer = register<_RevealTimerDisposable>(_RevealTimerDisposable())
        .timer;
  }

  /// 1:1: `public setVisibility(visibility)`
  void setVisibility(int visibility) {
    if (_visibility != visibility) {
      _visibility = visibility;
      _updateShouldBeVisible();
    }
  }

  /// 1:1: `public setShouldBeVisible(rawShouldBeVisible)`
  void setShouldBeVisible(bool rawShouldBeVisible) {
    _rawShouldBeVisible = rawShouldBeVisible;
    _updateShouldBeVisible();
  }

  /// 1:1: `private _applyVisibilitySetting(): boolean`
  bool _applyVisibilitySetting() {
    if (_visibility == ScrollbarVisibility.Hidden) {
      return false;
    }
    if (_visibility == ScrollbarVisibility.Visible) {
      return true;
    }
    return _rawShouldBeVisible;
  }

  /// 1:1: `private _updateShouldBeVisible()`
  void _updateShouldBeVisible() {
    final bool shouldBeVisible = _applyVisibilitySetting();
    if (_shouldBeVisible != shouldBeVisible) {
      _shouldBeVisible = shouldBeVisible;
      ensureVisibility();
    }
  }

  /// 1:1: `public setIsNeeded(isNeeded)`
  void setIsNeeded(bool isNeeded) {
    if (_isNeeded != isNeeded) {
      _isNeeded = isNeeded;
      ensureVisibility();
    }
  }

  /// 1:1: `public setDomNode(domNode)`
  void setDomNode(FastDomNode domNode) {
    _domNode = domNode;
    domNode.setClassName(_invisibleClassName);
    // Now that the flags & the dom node are in a consistent state, ensure the
    // Hidden/Visible configuration.
    setShouldBeVisible(false);
  }

  /// 1:1: `public ensureVisibility()`
  void ensureVisibility() {
    if (!_isNeeded) {
      // Nothing to be rendered
      _hide(false);
      return;
    }
    if (_shouldBeVisible) {
      _reveal();
    } else {
      _hide(true);
    }
  }

  /// 1:1: `private _reveal()`
  void _reveal() {
    if (_isVisible) {
      return;
    }
    _isVisible = true;
    // The CSS animation doesn't play otherwise
    _revealTimer.setIfNotSet(() {
      _domNode?.setClassName(_visibleClassName);
    }, 0);
  }

  /// 1:1: `private _hide(withFadeAway)`
  void _hide(bool withFadeAway) {
    _revealTimer.cancel();
    if (!_isVisible) {
      return;
    }
    _isVisible = false;
    _domNode?.setClassName(
        _invisibleClassName + (withFadeAway ? ' fade' : ''));
  }

  /// Test/introspection hook mirroring the private `_isVisible` flag.
  bool get isVisible => _isVisible;
}

/// A disposable wrapping the injected [RevealTimer] so it is disposed with the
/// controller (1:1: `this._register(new TimeoutTimer())`).
class _RevealTimerDisposable implements IDisposable {
  late final RevealTimer timer;
  _RevealTimerDisposable() {
    timer = revealTimerFactory();
  }
  @override
  void dispose() => timer.cancel();
}
