// ---------------------------------------------------------------------------
// Port of vscode/src/vs/editor/common/viewModelEventDispatcher.ts
// Translated 1:1 from TypeScript. Structure, members and semantics preserved.
//
// Adaptations (documented inline):
//  * `OutgoingViewModelEvent` union -> abstract base class.
//  * `ViewEvent` / erased model event interfaces -> opaque Object carriers.
//  * `ViewEventHandler` is an erased interface -> local contract.
//  * `console.warn` -> injectable [viewModelEventDispatcherWarn].
//  * `const enum` -> class static const ints.
// ---------------------------------------------------------------------------
import '../../base/common/event.dart' show Emitter, Event;
import '../../base/common/lifecycle.dart' show Disposable;
import 'core/selection.dart' show Selection;

/// 1:1: injectable `console.warn`.
void Function(Object? message) viewModelEventDispatcherWarn = (Object? message) {};

/// 1:1: `const enum OutgoingViewModelEventKind`.
class OutgoingViewModelEventKind {
  const OutgoingViewModelEventKind._();
  static const int ContentSizeChanged = 0;
  static const int FocusChanged = 1;
  static const int WidgetFocusChanged = 2;
  static const int ScrollChanged = 3;
  static const int ViewZonesChanged = 4;
  static const int HiddenAreasChanged = 5;
  static const int ReadOnlyEditAttempt = 6;
  static const int CursorStateChanged = 7;
  static const int ModelDecorationsChanged = 8;
  static const int ModelLanguageChanged = 9;
  static const int ModelLanguageConfigurationChanged = 10;
  static const int ModelContentChanged = 11;
  static const int ModelOptionsChanged = 12;
  static const int ModelTokensChanged = 13;
  static const int ModelLineHeightChanged = 14;
  static const int ModelFontChangedEvent = 15;
}

/// 1:1: `export type OutgoingViewModelEvent` (union -> common base).
abstract class OutgoingViewModelEvent {
  int get kind;
  bool isNoOp();
  OutgoingViewModelEvent? attemptToMerge(OutgoingViewModelEvent other);
}

/// 1:1: `ViewEventHandler.handleEvents` contract.
abstract class ViewEventHandler {
  void handleEvents(List<Object> events);
}

/// 1:1: `export class ViewModelEventDispatcher extends Disposable`.
class ViewModelEventDispatcher extends Disposable {
  final Emitter<OutgoingViewModelEvent> _onEvent =
      Emitter<OutgoingViewModelEvent>();

  late final Event<OutgoingViewModelEvent> onEvent;

  final List<ViewEventHandler> _eventHandlers;
  List<Object>? _viewEventQueue;
  bool _isConsumingViewEventQueue;
  ViewModelEventsCollector? _collector;
  int _collectorCnt;
  final List<OutgoingViewModelEvent> _outgoingEvents;

  ViewModelEventDispatcher()
      : _eventHandlers = <ViewEventHandler>[],
        _viewEventQueue = null,
        _isConsumingViewEventQueue = false,
        _collector = null,
        _collectorCnt = 0,
        _outgoingEvents = <OutgoingViewModelEvent>[] {
    onEvent = _onEvent.event;
  }

  void emitOutgoingEvent(OutgoingViewModelEvent e) {
    _addOutgoingEvent(e);
    _emitOutgoingEvents();
  }

  void _addOutgoingEvent(OutgoingViewModelEvent e) {
    for (int i = 0, len = _outgoingEvents.length; i < len; i++) {
      final OutgoingViewModelEvent? mergeResult =
          _outgoingEvents[i].kind == e.kind
              ? _outgoingEvents[i].attemptToMerge(e)
              : null;
      if (mergeResult != null) {
        _outgoingEvents[i] = mergeResult;
        return;
      }
    }
    // not merged
    _outgoingEvents.add(e);
  }

  void _emitOutgoingEvents() {
    while (_outgoingEvents.isNotEmpty) {
      if (_collector != null || _isConsumingViewEventQueue) {
        // right now collecting or emitting view events, so postpone
        return;
      }
      final OutgoingViewModelEvent event = _outgoingEvents.removeAt(0);
      if (event.isNoOp()) {
        continue;
      }
      _onEvent.fire(event);
    }
  }

  void addViewEventHandler(ViewEventHandler eventHandler) {
    for (int i = 0, len = _eventHandlers.length; i < len; i++) {
      if (identical(_eventHandlers[i], eventHandler)) {
        viewModelEventDispatcherWarn(
            'Detected duplicate listener in ViewEventDispatcher');
      }
    }
    _eventHandlers.add(eventHandler);
  }

  void removeViewEventHandler(ViewEventHandler eventHandler) {
    for (int i = 0; i < _eventHandlers.length; i++) {
      if (identical(_eventHandlers[i], eventHandler)) {
        _eventHandlers.removeAt(i);
        break;
      }
    }
  }

  ViewModelEventsCollector beginEmitViewEvents() {
    _collectorCnt++;
    if (_collectorCnt == 1) {
      _collector = ViewModelEventsCollector();
    }
    return _collector!;
  }

  void endEmitViewEvents() {
    _collectorCnt--;
    if (_collectorCnt == 0) {
      final List<OutgoingViewModelEvent> outgoingEvents =
          _collector!.outgoingEvents;
      final List<Object> viewEvents = _collector!.viewEvents;
      _collector = null;

      for (final OutgoingViewModelEvent outgoingEvent in outgoingEvents) {
        _addOutgoingEvent(outgoingEvent);
      }

      if (viewEvents.isNotEmpty) {
        _emitMany(viewEvents);
      }
    }
    _emitOutgoingEvents();
  }

  void emitSingleViewEvent(Object event) {
    try {
      final ViewModelEventsCollector eventsCollector = beginEmitViewEvents();
      eventsCollector.emitViewEvent(event);
    } finally {
      endEmitViewEvents();
    }
  }

  void _emitMany(List<Object> events) {
    if (_viewEventQueue != null) {
      _viewEventQueue = <Object>[..._viewEventQueue!, ...events];
    } else {
      _viewEventQueue = events;
    }

    if (!_isConsumingViewEventQueue) {
      _consumeViewEventQueue();
    }
  }

  void _consumeViewEventQueue() {
    try {
      _isConsumingViewEventQueue = true;
      _doConsumeQueue();
    } finally {
      _isConsumingViewEventQueue = false;
    }
  }

  void _doConsumeQueue() {
    while (_viewEventQueue != null) {
      // Empty event queue, as events might come in while sending these off
      final List<Object> events = _viewEventQueue!;
      _viewEventQueue = null;

      // Use a clone of the event handlers list, as they might remove themselves
      final List<ViewEventHandler> eventHandlers = _eventHandlers.sublist(0);
      for (final ViewEventHandler eventHandler in eventHandlers) {
        eventHandler.handleEvents(events);
      }
    }
  }
}

/// 1:1: `export class ViewModelEventsCollector`.
class ViewModelEventsCollector {
  final List<Object> viewEvents;
  final List<OutgoingViewModelEvent> outgoingEvents;

  ViewModelEventsCollector()
      : viewEvents = <Object>[],
        outgoingEvents = <OutgoingViewModelEvent>[];

  void emitViewEvent(Object event) {
    viewEvents.add(event);
  }

  void emitOutgoingEvent(OutgoingViewModelEvent e) {
    outgoingEvents.add(e);
  }
}

/// 1:1: `export class ContentSizeChangedEvent`.
class ContentSizeChangedEvent extends OutgoingViewModelEvent {
  @override
  final int kind = OutgoingViewModelEventKind.ContentSizeChanged;

  final int _oldContentWidth;
  final int _oldContentHeight;

  final int contentWidth;
  final int contentHeight;
  final bool contentWidthChanged;
  final bool contentHeightChanged;

  ContentSizeChangedEvent(int oldContentWidth, int oldContentHeight,
      this.contentWidth, this.contentHeight)
      : _oldContentWidth = oldContentWidth,
        _oldContentHeight = oldContentHeight,
        contentWidthChanged = oldContentWidth != contentWidth,
        contentHeightChanged = oldContentHeight != contentHeight;

  @override
  bool isNoOp() => (!contentWidthChanged && !contentHeightChanged);

  @override
  OutgoingViewModelEvent? attemptToMerge(OutgoingViewModelEvent other) {
    if (other.kind != kind) {
      return null;
    }
    final ContentSizeChangedEvent o = other as ContentSizeChangedEvent;
    return ContentSizeChangedEvent(
        _oldContentWidth, _oldContentHeight, o.contentWidth, o.contentHeight);
  }
}

/// 1:1: `export class FocusChangedEvent`.
class FocusChangedEvent extends OutgoingViewModelEvent {
  @override
  final int kind = OutgoingViewModelEventKind.FocusChanged;

  final bool oldHasFocus;
  final bool hasFocus;

  FocusChangedEvent(this.oldHasFocus, this.hasFocus);

  @override
  bool isNoOp() => (oldHasFocus == hasFocus);

  @override
  OutgoingViewModelEvent? attemptToMerge(OutgoingViewModelEvent other) {
    if (other.kind != kind) {
      return null;
    }
    return FocusChangedEvent(oldHasFocus, (other as FocusChangedEvent).hasFocus);
  }
}

/// 1:1: `export class WidgetFocusChangedEvent`.
class WidgetFocusChangedEvent extends OutgoingViewModelEvent {
  @override
  final int kind = OutgoingViewModelEventKind.WidgetFocusChanged;

  final bool oldHasFocus;
  final bool hasFocus;

  WidgetFocusChangedEvent(this.oldHasFocus, this.hasFocus);

  @override
  bool isNoOp() => (oldHasFocus == hasFocus);

  @override
  OutgoingViewModelEvent? attemptToMerge(OutgoingViewModelEvent other) {
    if (other.kind != kind) {
      return null;
    }
    // 1:1: the source returns a `FocusChangedEvent` here (not a widget event).
    return FocusChangedEvent(oldHasFocus, (other as WidgetFocusChangedEvent).hasFocus);
  }
}

/// 1:1: `export class ScrollChangedEvent`.
class ScrollChangedEvent extends OutgoingViewModelEvent {
  @override
  final int kind = OutgoingViewModelEventKind.ScrollChanged;

  final int _oldScrollWidth;
  final int _oldScrollLeft;
  final int _oldScrollHeight;
  final int _oldScrollTop;

  final int scrollWidth;
  final int scrollLeft;
  final int scrollHeight;
  final int scrollTop;

  final bool scrollWidthChanged;
  final bool scrollLeftChanged;
  final bool scrollHeightChanged;
  final bool scrollTopChanged;

  ScrollChangedEvent(
    int oldScrollWidth,
    int oldScrollLeft,
    int oldScrollHeight,
    int oldScrollTop,
    this.scrollWidth,
    this.scrollLeft,
    this.scrollHeight,
    this.scrollTop,
  )   : _oldScrollWidth = oldScrollWidth,
        _oldScrollLeft = oldScrollLeft,
        _oldScrollHeight = oldScrollHeight,
        _oldScrollTop = oldScrollTop,
        scrollWidthChanged = oldScrollWidth != scrollWidth,
        scrollLeftChanged = oldScrollLeft != scrollLeft,
        scrollHeightChanged = oldScrollHeight != scrollHeight,
        scrollTopChanged = oldScrollTop != scrollTop;

  @override
  bool isNoOp() => (!scrollWidthChanged &&
      !scrollLeftChanged &&
      !scrollHeightChanged &&
      !scrollTopChanged);

  @override
  OutgoingViewModelEvent? attemptToMerge(OutgoingViewModelEvent other) {
    if (other.kind != kind) {
      return null;
    }
    final ScrollChangedEvent o = other as ScrollChangedEvent;
    return ScrollChangedEvent(
      _oldScrollWidth,
      _oldScrollLeft,
      _oldScrollHeight,
      _oldScrollTop,
      o.scrollWidth,
      o.scrollLeft,
      o.scrollHeight,
      o.scrollTop,
    );
  }
}

class _SingletonOutgoingEvent extends OutgoingViewModelEvent {
  @override
  final int kind;

  _SingletonOutgoingEvent(this.kind);

  @override
  bool isNoOp() => false;

  @override
  OutgoingViewModelEvent? attemptToMerge(OutgoingViewModelEvent other) =>
      other.kind == kind ? this : null;
}

/// 1:1: `export class ViewZonesChangedEvent`.
class ViewZonesChangedEvent extends _SingletonOutgoingEvent {
  ViewZonesChangedEvent()
      : super(OutgoingViewModelEventKind.ViewZonesChanged);
}

/// 1:1: `export class HiddenAreasChangedEvent`.
class HiddenAreasChangedEvent extends _SingletonOutgoingEvent {
  HiddenAreasChangedEvent()
      : super(OutgoingViewModelEventKind.HiddenAreasChanged);
}

/// 1:1: `export class ReadOnlyEditAttemptEvent`.
class ReadOnlyEditAttemptEvent extends _SingletonOutgoingEvent {
  ReadOnlyEditAttemptEvent()
      : super(OutgoingViewModelEventKind.ReadOnlyEditAttempt);
}

/// 1:1: `export class CursorStateChangedEvent`.
class CursorStateChangedEvent extends OutgoingViewModelEvent {
  @override
  final int kind = OutgoingViewModelEventKind.CursorStateChanged;

  final List<Selection>? oldSelections;
  final List<Selection> selections;
  final int oldModelVersionId;
  final int modelVersionId;
  final String source;
  final int reason;
  final bool reachedMaxCursorCount;

  CursorStateChangedEvent(
    this.oldSelections,
    this.selections,
    this.oldModelVersionId,
    this.modelVersionId,
    this.source,
    this.reason,
    this.reachedMaxCursorCount,
  );

  static bool _selectionsAreEqual(
      List<Selection>? a, List<Selection>? b) {
    if (a == null && b == null) {
      return true;
    }
    if (a == null || b == null) {
      return false;
    }
    final int aLen = a.length;
    final int bLen = b.length;
    if (aLen != bLen) {
      return false;
    }
    for (int i = 0; i < aLen; i++) {
      if (!a[i].equalsSelection(b[i])) {
        return false;
      }
    }
    return true;
  }

  @override
  bool isNoOp() =>
      (_selectionsAreEqual(oldSelections, selections) &&
          oldModelVersionId == modelVersionId);

  @override
  OutgoingViewModelEvent? attemptToMerge(OutgoingViewModelEvent other) {
    if (other.kind != kind) {
      return null;
    }
    final CursorStateChangedEvent o = other as CursorStateChangedEvent;
    return CursorStateChangedEvent(
      oldSelections,
      o.selections,
      oldModelVersionId,
      o.modelVersionId,
      o.source,
      o.reason,
      reachedMaxCursorCount || o.reachedMaxCursorCount,
    );
  }
}

/// 1:1: wrapper events (`Model*ChangedEvent`) — never merge, never no-op.
class ModelEventWrapper extends OutgoingViewModelEvent {
  @override
  final int kind;
  final Object? event;

  ModelEventWrapper(this.kind, this.event);

  @override
  bool isNoOp() => false;

  @override
  OutgoingViewModelEvent? attemptToMerge(OutgoingViewModelEvent other) => null;
}

class ModelDecorationsChangedEvent extends ModelEventWrapper {
  ModelDecorationsChangedEvent(Object? event)
      : super(OutgoingViewModelEventKind.ModelDecorationsChanged, event);
}

class ModelLanguageChangedEvent extends ModelEventWrapper {
  ModelLanguageChangedEvent(Object? event)
      : super(OutgoingViewModelEventKind.ModelLanguageChanged, event);
}

class ModelLanguageConfigurationChangedEvent extends ModelEventWrapper {
  ModelLanguageConfigurationChangedEvent(Object? event)
      : super(OutgoingViewModelEventKind.ModelLanguageConfigurationChanged, event);
}

class ModelContentChangedEvent extends ModelEventWrapper {
  ModelContentChangedEvent(Object? event)
      : super(OutgoingViewModelEventKind.ModelContentChanged, event);
}

class ModelOptionsChangedEvent extends ModelEventWrapper {
  ModelOptionsChangedEvent(Object? event)
      : super(OutgoingViewModelEventKind.ModelOptionsChanged, event);
}

class ModelTokensChangedEvent extends ModelEventWrapper {
  ModelTokensChangedEvent(Object? event)
      : super(OutgoingViewModelEventKind.ModelTokensChanged, event);
}

class ModelLineHeightChangedEvent extends ModelEventWrapper {
  ModelLineHeightChangedEvent(Object? event)
      : super(OutgoingViewModelEventKind.ModelLineHeightChanged, event);
}

class ModelFontChangedEvent extends ModelEventWrapper {
  ModelFontChangedEvent(Object? event)
      : super(OutgoingViewModelEventKind.ModelFontChangedEvent, event);
}
