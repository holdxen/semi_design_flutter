// ---------------------------------------------------------------------------
// Port of vscode/src/vs/base/browser/ui/sash/sash.ts
// Translated 1:1 from TypeScript. Structure, members and semantics preserved.
//
// JS carriers:
//   - `HTMLElement` -> `dom.DomElement` with `classList`/`style` carriers.
//   - `Event<T>` / `Emitter<T>` -> `events.Event<T>` / `events.Emitter<T>`.
//   - `DomEmitter` pointer factories -> lazy `events.Emitter` + DOM listeners.
//   - `Disposable/_register` -> `lifecycle.Disposable/register`.
//   - `memoize` getters -> lazy `late final` fields.
//   - `setTimeout(250)` double-tap -> `dart:async.Timer`.
//   - `__orthogonalSashEvent`/`__linkedSashEvent` flags -> identity `Expando`.
//   - `isMacintosh` uses the already-ported platform carrier.
// ---------------------------------------------------------------------------

import 'dart:async';

import '../../dom.dart' as dom;
import '../../domStylesheets.dart' as domStylesheets;
import '../../touch.dart' as touch;
import '../../../common/async.dart' as async;
import '../../../common/event.dart' as events;
import '../../../common/lifecycle.dart' as lifecycle;
import '../../../common/platform.dart' as platform;

/// 1:1: `export interface IVerticalSashLayoutProvider`.
abstract class IVerticalSashLayoutProvider {
  num getVerticalSashLeft(Sash sash);
  num? getVerticalSashTop(Sash sash) => null;
  num? getVerticalSashHeight(Sash sash) => null;
}

/// 1:1: `export interface IHorizontalSashLayoutProvider`.
abstract class IHorizontalSashLayoutProvider {
  num getHorizontalSashTop(Sash sash);
  num? getHorizontalSashLeft(Sash sash) => null;
  num? getHorizontalSashWidth(Sash sash) => null;
}

/// 1:1: `export interface ISashEvent`.
class SashEvent {
  SashEvent({
    required this.startX,
    required this.currentX,
    required this.startY,
    required this.currentY,
    required this.altKey,
  });

  final num startX;
  final num currentX;
  final num startY;
  final num currentY;
  final bool altKey;

  Map<String, Object?> toMap() => <String, Object?>{
        'startX': startX,
        'currentX': currentX,
        'startY': startY,
        'currentY': currentY,
        'altKey': altKey,
      };
}

/// 1:1: `export enum OrthogonalEdge`.
class OrthogonalEdge {
  static const String North = 'north';
  static const String South = 'south';
  static const String East = 'east';
  static const String West = 'west';
}

/// 1:1: `export interface IBoundarySashes`.
class BoundarySashes {
  BoundarySashes({this.top, this.right, this.bottom, this.left});

  final Sash? top;
  final Sash? right;
  final Sash? bottom;
  final Sash? left;
}

/// 1:1: `export interface ISashOptions`.
class SashOptions {
  SashOptions({
    required this.orientation,
    this.size,
    this.orthogonalStartSash,
    this.orthogonalEndSash,
    this.orthogonalEdge,
  });

  final int orientation;
  final num? size;
  final Sash? orthogonalStartSash;
  final Sash? orthogonalEndSash;
  final String? orthogonalEdge;
}

/// 1:1: `export const enum Orientation`.
class Orientation {
  static const int VERTICAL = 0;
  static const int HORIZONTAL = 1;
}

/// 1:1: `export const enum SashState`.
class SashState {
  static const int Disabled = 0;
  static const int AtMinimum = 1;
  static const int AtMaximum = 2;
  static const int Enabled = 3;
}

const bool _DEBUG = false;

num _globalSize = 4;
final events.Emitter<num> _onDidChangeGlobalSize = events.Emitter<num>();

/// 1:1: `export function setGlobalSashSize(size)`.
void setGlobalSashSize(num size) {
  _globalSize = size;
  _onDidChangeGlobalSize.fire(size);
}

num _globalHoverDelay = 300;
final events.Emitter<num> _onDidChangeHoverDelay = events.Emitter<num>();

/// 1:1: `export function setGlobalHoverDelay(size)`.
void setGlobalHoverDelay(num size) {
  _globalHoverDelay = size;
  _onDidChangeHoverDelay.fire(size);
}

final Expando<Set<String>> _eventFlags = Expando<Set<String>>();

bool _hasEventFlag(Object event, String flag) =>
    _eventFlags[event]?.contains(flag) ?? false;

void _setEventFlag(Object event, String flag) =>
    (_eventFlags[event] ??= <String>{}).add(flag);

num _pageX(Object? e) => e is dom.DomMouseEvent ? e.pageX : 0;
num _pageY(Object? e) => e is dom.DomMouseEvent ? e.pageY : 0;
bool _altKey(Object? e) => e is dom.DomEvent ? e.altKey : false;

String _jsNum(num value) {
  if (value is double && value == value.toInt()) return value.toInt().toString();
  return value.toString();
}

Object? _eventTarget(Object? e) =>
    e is dom.DomEvent ? (e.initialTarget ?? e.target) : null;

/// 1:1: `$('.foo')` for the two emmet selectors used by sash.ts.
dom.DomElement _dollar(String description) {
  final List<String> parts = description.split('.');
  final dom.DomElement el =
      dom.document.createElement(parts.first.isEmpty ? 'div' : parts.first);
  if (parts.length > 1) el.className = parts.skip(1).join(' ');
  return el;
}

void _visitIframes(dom.DomNode node, List<dom.DomElement> out) {
  for (final dom.DomNode child in node.childNodes) {
    if (child is dom.DomElement && child.localName == 'iframe') {
      out.add(child);
    }
    _visitIframes(child, out);
  }
}

List<dom.DomElement> _iframesOf(dom.DomNode node) {
  final List<dom.DomElement> out = <dom.DomElement>[];
  final dom.DomDocument? doc = node.ownerDocument;
  if (doc != null) {
    _visitIframes(doc.documentElement, out);
    _visitIframes(doc.head, out);
    _visitIframes(doc.body, out);
  }
  return out;
}

/// 1:1: `interface IPointerEventFactory`.
abstract class _IPointerEventFactory implements lifecycle.IDisposable {
  events.Event<dom.DomEvent> get onPointerMove;
  events.Event<dom.DomEvent> get onPointerUp;
  void dispose();
}

/// 1:1: `class MouseEventFactory`.
class _MouseEventFactory implements _IPointerEventFactory {
  _MouseEventFactory(this._el);

  final dom.DomElement _el;
  final lifecycle.DisposableStore _disposables = lifecycle.DisposableStore();

  bool _moveInitialized = false;
  late final events.Emitter<dom.DomEvent> _moveEmitter =
      events.Emitter<dom.DomEvent>();
  bool _upInitialized = false;
  late final events.Emitter<dom.DomEvent> _upEmitter =
      events.Emitter<dom.DomEvent>();

  @override
  events.Event<dom.DomEvent> get onPointerMove {
    if (!_moveInitialized) {
      _moveInitialized = true;
      _disposables.add(dom.addDisposableTargetListener(
          dom.getWindow(_el), dom.EventType.MOUSE_MOVE,
          (dom.DomEvent e) => _moveEmitter.fire(e)));
    }
    return _moveEmitter.event;
  }

  @override
  events.Event<dom.DomEvent> get onPointerUp {
    if (!_upInitialized) {
      _upInitialized = true;
      _disposables.add(dom.addDisposableTargetListener(
          dom.getWindow(_el), dom.EventType.MOUSE_UP,
          (dom.DomEvent e) => _upEmitter.fire(e)));
    }
    return _upEmitter.event;
  }

  @override
  void dispose() => _disposables.dispose();
}

/// 1:1: `class GestureEventFactory`.
class _GestureEventFactory implements _IPointerEventFactory {
  _GestureEventFactory(this._el);

  final dom.DomElement _el;
  final lifecycle.DisposableStore _disposables = lifecycle.DisposableStore();

  bool _moveInitialized = false;
  late final events.Emitter<dom.DomEvent> _moveEmitter =
      events.Emitter<dom.DomEvent>();
  bool _upInitialized = false;
  late final events.Emitter<dom.DomEvent> _upEmitter =
      events.Emitter<dom.DomEvent>();

  @override
  events.Event<dom.DomEvent> get onPointerMove {
    if (!_moveInitialized) {
      _moveInitialized = true;
      _disposables.add(dom.addDisposableListener(
          _el, touch.EventType.Change,
          (dom.DomEvent e) => _moveEmitter.fire(e)));
    }
    return _moveEmitter.event;
  }

  @override
  events.Event<dom.DomEvent> get onPointerUp {
    if (!_upInitialized) {
      _upInitialized = true;
      _disposables.add(dom.addDisposableListener(
          _el, touch.EventType.End,
          (dom.DomEvent e) => _upEmitter.fire(e)));
    }
    return _upEmitter.event;
  }

  @override
  void dispose() => _disposables.dispose();
}

/// 1:1: `class OrthogonalPointerEventFactory`.
class _OrthogonalPointerEventFactory implements _IPointerEventFactory {
  _OrthogonalPointerEventFactory(this._factory);

  final _IPointerEventFactory _factory;

  @override
  events.Event<dom.DomEvent> get onPointerMove => _factory.onPointerMove;

  @override
  events.Event<dom.DomEvent> get onPointerUp => _factory.onPointerUp;

  @override
  void dispose() {
    // noop, 1:1 with source.
  }
}

/// 1:1: `class Sash extends Disposable`.
class Sash extends lifecycle.Disposable {
  Sash(dom.DomElement container, Object layoutProvider, SashOptions options)
      : _layoutProvider = layoutProvider,
        _orientation = options.orientation {
    _el = dom.append(container, <Object>[_dollar('.monaco-sash')]) as dom.DomElement;

    if (options.orthogonalEdge != null) {
      _el.classList.add('orthogonal-edge-${options.orthogonalEdge}');
    }
    if (platform.isMacintosh) _el.classList.add('mac');

    register(dom.addDisposableListener(_el, dom.EventType.MOUSE_DOWN,
        (dom.DomEvent e) => _onPointerStart(e, _MouseEventFactory(container))));
    register(dom.addDisposableListener(
        _el, dom.EventType.DBLCLICK, (dom.DomEvent e) => _onPointerDoublePress(e)));
    register(dom.addDisposableListener(
        _el, dom.EventType.MOUSE_ENTER, (dom.DomEvent e) => _onMouseEnter(this)));
    register(dom.addDisposableListener(
        _el, dom.EventType.MOUSE_LEAVE, (dom.DomEvent e) => _onMouseLeave(this)));

    register(touch.Gesture.addTarget(_el));
    register(dom.addDisposableListener(_el, touch.EventType.Start,
        (dom.DomEvent e) => _onPointerStart(e, _GestureEventFactory(_el))));

    Timer? doubleTapTimeout;
    register(lifecycle.toDisposable(() => doubleTapTimeout?.cancel()));
    register(dom.addDisposableListener(_el, touch.EventType.Tap, (dom.DomEvent e) {
      if (doubleTapTimeout != null) {
        doubleTapTimeout!.cancel();
        doubleTapTimeout = null;
        _onPointerDoublePress(e);
        return;
      }
      doubleTapTimeout = Timer(const Duration(milliseconds: 250), () {
        doubleTapTimeout = null;
      });
    }));

    if (options.size != null) {
      _size = options.size!;
      if (_orientation == Orientation.VERTICAL) {
        _el.style['width'] = '${_jsNum(_size)}px';
      } else {
        _el.style['height'] = '${_jsNum(_size)}px';
      }
    } else {
      _size = _globalSize;
      register(_onDidChangeGlobalSize.event((Object? size) {
        _size = size as num;
        layout();
      }));
    }

    register(_onDidChangeHoverDelay.event((Object? delay) {
      _hoverDelay = delay as num;
    }));

    register(_orthogonalStartSashDisposables);
    register(_orthogonalStartDragHandleDisposables);
    register(_orthogonalEndSashDisposables);
    register(_orthogonalEndDragHandleDisposables);

    orthogonalStartSash = options.orthogonalStartSash;
    orthogonalEndSash = options.orthogonalEndSash;

    _orientation = options.orientation == 0 ? Orientation.VERTICAL : Orientation.HORIZONTAL;
    if (_orientation == Orientation.HORIZONTAL) {
      _el.classList.add('horizontal');
      _el.classList.remove('vertical');
    } else {
      _el.classList.remove('horizontal');
      _el.classList.add('vertical');
    }
    _el.classList.toggle('debug', _DEBUG);

    layout();
  }

  /// Named 1:1 overload for a vertical sash.
  Sash.vertical(dom.DomElement container, IVerticalSashLayoutProvider provider,
      [SashOptions? options])
      : this(
            container,
            provider,
            options ?? SashOptions(orientation: Orientation.VERTICAL));

  /// Named 1:1 overload for a horizontal sash.
  Sash.horizontal(
      dom.DomElement container, IHorizontalSashLayoutProvider provider,
      [SashOptions? options])
      : this(
            container,
            provider,
            options ?? SashOptions(orientation: Orientation.HORIZONTAL));

  late final dom.DomElement _el;

  /// Validation hook mirroring the TS private field.
  dom.DomElement get el => _el;

  final Object _layoutProvider;
  int _orientation;
  num _size = 4;
  num _hoverDelay = _globalHoverDelay;
  final async.Delayer<void> _hoverDelayer =
      async.Delayer<void>(_globalHoverDelay);

  int _state = SashState.Enabled;
  final Map<String, _ClassLease> _classNameLeases =
      <String, _ClassLease>{};

  final events.Emitter<int> _onDidEnablementChange = events.Emitter<int>();
  final events.Emitter<SashEvent> _onDidStartEmitter =
      events.Emitter<SashEvent>();
  final events.Emitter<SashEvent> _onDidChangeEmitter =
      events.Emitter<SashEvent>();
  final events.Emitter<void> _onDidResetEmitter = events.Emitter<void>();
  final events.Emitter<void> _onDidEndEmitter = events.Emitter<void>();

  final lifecycle.DisposableStore _orthogonalStartSashDisposables =
      lifecycle.DisposableStore();
  Sash? _orthogonalStartSash;
  final lifecycle.DisposableStore _orthogonalStartDragHandleDisposables =
      lifecycle.DisposableStore();
  dom.DomElement? _orthogonalStartDragHandle;
  final lifecycle.DisposableStore _orthogonalEndSashDisposables =
      lifecycle.DisposableStore();
  Sash? _orthogonalEndSash;
  final lifecycle.DisposableStore _orthogonalEndDragHandleDisposables =
      lifecycle.DisposableStore();
  dom.DomElement? _orthogonalEndDragHandle;

  /// 1:1: `linkedSash`.
  Sash? linkedSash;

  int get state => _state;
  Sash? get orthogonalStartSash => _orthogonalStartSash;
  Sash? get orthogonalEndSash => _orthogonalEndSash;

  events.Event<int> get _onDidEnablementChangeEvent =>
      _onDidEnablementChange.event;

  set state(int state) {
    if (_state == state) return;
    _el.classList.toggle('disabled', state == SashState.Disabled);
    _el.classList.toggle('minimum', state == SashState.AtMinimum);
    _el.classList.toggle('maximum', state == SashState.AtMaximum);
    _state = state;
    _onDidEnablementChange.fire(state);
  }

  events.Event<SashEvent> get onDidStart => _onDidStartEmitter.event;
  events.Event<SashEvent> get onDidChange => _onDidChangeEmitter.event;
  events.Event<void> get onDidReset => _onDidResetEmitter.event;
  events.Event<void> get onDidEnd => _onDidEndEmitter.event;

  /// 1:1: `addClass`.
  lifecycle.IDisposable addClass(String className) {
    final _ClassLease? existing = _classNameLeases[className];
    if (existing != null) {
      existing.count++;
    } else {
      _classNameLeases[className] = _ClassLease(
        1,
        !_el.classList.contains(className),
      );
      _el.classList.add(className);
    }
    return lifecycle.toDisposable(() {
      final _ClassLease? lease = _classNameLeases[className];
      if (lease != null && lease.count == 1) {
        _classNameLeases.remove(className);
        if (lease.removeOnRelease) _el.classList.remove(className);
      } else if (lease != null) {
        lease.count--;
      }
    });
  }

  set orthogonalStartSash(Sash? sash) {
    if (identical(_orthogonalStartSash, sash)) return;
    _orthogonalStartDragHandleDisposables.clear();
    _orthogonalStartSashDisposables.clear();
    if (sash != null) {
      void onChange(int state) {
        _orthogonalStartDragHandleDisposables.clear();
        if (state != SashState.Disabled) {
          _orthogonalStartDragHandle = dom.append(
              _el, <Object>[_dollar('.orthogonal-drag-handle.start')]) as dom.DomElement;
          _orthogonalStartDragHandleDisposables.add(lifecycle.toDisposable(
              () => _orthogonalStartDragHandle!.remove()));
          _orthogonalStartDragHandleDisposables.add(
              dom.addDisposableListener(_orthogonalStartDragHandle!,
                  dom.EventType.MOUSE_ENTER,
                  (dom.DomEvent e) => _onMouseEnter(sash)));
          _orthogonalStartDragHandleDisposables.add(
              dom.addDisposableListener(_orthogonalStartDragHandle!,
                  dom.EventType.MOUSE_LEAVE,
                  (dom.DomEvent e) => _onMouseLeave(sash)));
        }
      }

      _orthogonalStartSashDisposables.add(sash._onDidEnablementChangeEvent(
          (Object? state) => onChange(state as int), this));
      onChange(sash.state);
    }
    _orthogonalStartSash = sash;
  }

  set orthogonalEndSash(Sash? sash) {
    if (identical(_orthogonalEndSash, sash)) return;
    _orthogonalEndDragHandleDisposables.clear();
    _orthogonalEndSashDisposables.clear();
    if (sash != null) {
      void onChange(int state) {
        _orthogonalEndDragHandleDisposables.clear();
        if (state != SashState.Disabled) {
          _orthogonalEndDragHandle = dom.append(
              _el, <Object>[_dollar('.orthogonal-drag-handle.end')]) as dom.DomElement;
          _orthogonalEndDragHandleDisposables.add(lifecycle.toDisposable(
              () => _orthogonalEndDragHandle!.remove()));
          _orthogonalEndDragHandleDisposables.add(
              dom.addDisposableListener(_orthogonalEndDragHandle!,
                  dom.EventType.MOUSE_ENTER,
                  (dom.DomEvent e) => _onMouseEnter(sash)));
          _orthogonalEndDragHandleDisposables.add(
              dom.addDisposableListener(_orthogonalEndDragHandle!,
                  dom.EventType.MOUSE_LEAVE,
                  (dom.DomEvent e) => _onMouseLeave(sash)));
        }
      }

      _orthogonalEndSashDisposables.add(sash._onDidEnablementChangeEvent(
          (Object? state) => onChange(state as int), this));
      onChange(sash.state);
    }
    _orthogonalEndSash = sash;
  }

  void _onPointerStart(dom.DomEvent event, _IPointerEventFactory factory) {
    dom.EventHelper.stopDom(event);

    bool isMultisashResize = false;
    if (!_hasEventFlag(event, 'orthogonal')) {
      final Sash? orthogonalSash = _getOrthogonalSash(event);
      if (orthogonalSash != null) {
        isMultisashResize = true;
        _setEventFlag(event, 'orthogonal');
        orthogonalSash._onPointerStart(
            event, _OrthogonalPointerEventFactory(factory));
      }
    }
    if (linkedSash != null && !_hasEventFlag(event, 'linked')) {
      _setEventFlag(event, 'linked');
      linkedSash!._onPointerStart(
          event, _OrthogonalPointerEventFactory(factory));
    }

    if (_state == 0) return;

    final List<dom.DomElement> iframes = _iframesOf(_el);
    for (final dom.DomElement iframe in iframes) {
      iframe.classList.add('pointer-events-disabled');
    }

    final num startX = _pageX(event);
    final num startY = _pageY(event);
    final bool altKey = _altKey(event);
    final SashEvent startEvent = SashEvent(
      startX: startX,
      currentX: startX,
      startY: startY,
      currentY: startY,
      altKey: altKey,
    );

    _el.classList.add('active');
    _onDidStartEmitter.fire(startEvent);

    final dom.DomElement style = domStylesheets.createStyleSheet(_el);
    void updateStyle() {
      String cursor = '';
      if (isMultisashResize) {
        cursor = 'all-scroll';
      } else if (_orientation == Orientation.HORIZONTAL) {
        if (_state == SashState.AtMinimum) {
          cursor = 's-resize';
        } else if (_state == SashState.AtMaximum) {
          cursor = 'n-resize';
        } else {
          cursor = platform.isMacintosh ? 'row-resize' : 'ns-resize';
        }
      } else {
        if (_state == SashState.AtMinimum) {
          cursor = 'e-resize';
        } else if (_state == SashState.AtMaximum) {
          cursor = 'w-resize';
        } else {
          cursor = platform.isMacintosh ? 'col-resize' : 'ew-resize';
        }
      }
      style.textContent = '* { cursor: $cursor !important; }';
    }

    final lifecycle.DisposableStore disposables = lifecycle.DisposableStore();
    updateStyle();
    if (!isMultisashResize) {
      disposables.add(_onDidEnablementChangeEvent((Object? state) => updateStyle()));
    }

    factory.onPointerMove((Object? e) {
      dom.EventHelper.stopDom(e as dom.DomEvent, false);
      _onDidChangeEmitter.fire(SashEvent(
        startX: startX,
        currentX: _pageX(e),
        startY: startY,
        currentY: _pageY(e),
        altKey: altKey,
      ));
    }, null, disposables);

    factory.onPointerUp((Object? e) {
      dom.EventHelper.stopDom(e as dom.DomEvent, false);
      style.remove();
      _el.classList.remove('active');
      _onDidEndEmitter.fire(null);
      disposables.dispose();
      for (final dom.DomElement iframe in iframes) {
        iframe.classList.remove('pointer-events-disabled');
      }
    }, null, disposables);

    disposables.add(factory);
  }

  void _onPointerDoublePress(dom.DomEvent e) {
    final Sash? orthogonalSash = _getOrthogonalSash(e);
    if (orthogonalSash != null) orthogonalSash._onDidResetEmitter.fire(null);
    if (linkedSash != null) linkedSash!._onDidResetEmitter.fire(null);
    _onDidResetEmitter.fire(null);
  }

  static void _onMouseEnter(Sash sash, [bool fromLinkedSash = false]) {
    if (sash._el.classList.contains('active')) {
      sash._hoverDelayer.cancel();
      sash._el.classList.add('hover');
    } else {
      sash._hoverDelayer
          .trigger(() {
            sash._el.classList.add('hover');
          }, sash._hoverDelay)
          .then<void>((_) {}, onError: (Object _, StackTrace __) {});
    }
    if (!fromLinkedSash && sash.linkedSash != null) {
      _onMouseEnter(sash.linkedSash!, true);
    }
  }

  static void _onMouseLeave(Sash sash, [bool fromLinkedSash = false]) {
    sash._hoverDelayer.cancel();
    sash._el.classList.remove('hover');
    if (!fromLinkedSash && sash.linkedSash != null) {
      _onMouseLeave(sash.linkedSash!, true);
    }
  }

  /// 1:1: `clearSashHoverState`.
  void clearSashHoverState() => _onMouseLeave(this);

  /// 1:1: `layout`.
  void layout() {
    if (_orientation == Orientation.VERTICAL) {
      final IVerticalSashLayoutProvider provider =
          _layoutProvider as IVerticalSashLayoutProvider;
      _el.style['left'] = '${_jsNum(provider.getVerticalSashLeft(this) - (_size / 2))}px';
      final num? top = provider.getVerticalSashTop(this);
      if (top != null) _el.style['top'] = '${_jsNum(top)}px';
      final num? height = provider.getVerticalSashHeight(this);
      if (height != null) _el.style['height'] = '${_jsNum(height)}px';
    } else {
      final IHorizontalSashLayoutProvider provider =
          _layoutProvider as IHorizontalSashLayoutProvider;
      _el.style['top'] = '${_jsNum(provider.getHorizontalSashTop(this) - (_size / 2))}px';
      final num? left = provider.getHorizontalSashLeft(this);
      if (left != null) _el.style['left'] = '${_jsNum(left)}px';
      final num? width = provider.getHorizontalSashWidth(this);
      if (width != null) _el.style['width'] = '${_jsNum(width)}px';
    }
  }

  Sash? _getOrthogonalSash(dom.DomEvent e) {
    final Object? target = _eventTarget(e);
    if (target == null || !dom.isHTMLElement(target)) return null;
    final dom.DomElement el = target as dom.DomElement;
    if (el.classList.contains('orthogonal-drag-handle')) {
      return el.classList.contains('start')
          ? _orthogonalStartSash
          : _orthogonalEndSash;
    }
    return null;
  }

  @override
  void dispose() {
    super.dispose();
    _el.remove();
  }
}

class _ClassLease {
  _ClassLease(this.count, this.removeOnRelease);

  int count;
  final bool removeOnRelease;
}
