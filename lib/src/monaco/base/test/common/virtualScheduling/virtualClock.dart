// 1:1 port of vs/base/test/common/virtualScheduling/virtualClock.ts

import '../../../common/arrays.dart' show compareBy, tieBreakComparators;
import '../../../common/event.dart' show Emitter, Event;
import '../../../common/lifecycle.dart' show IDisposable;
import 'trace.dart' show Trace;

/// 1:1: `export type VirtualTime = number`
typedef VirtualTime = num;

/// 1:1: `export interface EventSource`
/// Debug source description for an event. `toString()` is inherited from Object
/// in Dart; embedders override it to produce the source label.
abstract class EventSource {
  String toString();
  String? get stackTrace;
}

/// 1:1: `export interface VirtualEvent`
abstract class VirtualEvent {
  VirtualTime get time;
  EventSource get source;
  Trace? get trace;
  bool get preferRealAnimationFrame;
  void run();
}

/// 1:1: `interface QueuedEvent extends VirtualEvent { readonly id: number }`
class QueuedEvent implements VirtualEvent {
  @override
  final VirtualTime time;
  @override
  final EventSource source;
  @override
  final Trace? trace;
  @override
  final bool preferRealAnimationFrame;
  final void Function() runFn;
  final int id;

  QueuedEvent({
    required this.time,
    required this.source,
    required this.trace,
    required this.preferRealAnimationFrame,
    required this.runFn,
    required this.id,
  });

  @override
  void run() => runFn();
}

/// 1:1: `const eventComparator = tieBreakComparators(...)` — source uses
/// `numberComparator` on `time`/`id`; Dart's is int-only, so the equivalent
/// `(a, b) => a - b` comparator is used for the `num` time field.
final Comparator<QueuedEvent> eventComparator = tieBreakComparators<QueuedEvent>([
  compareBy<QueuedEvent, num>((e) => e.time, (a, b) => a.compareTo(b)),
  compareBy<QueuedEvent, num>((e) => e.id, (a, b) => a.compareTo(b)),
]);

/// 1:1: `export class VirtualClock`
class VirtualClock {
  VirtualTime _now;
  int _idCounter = 0;
  final SimplePriorityQueue<QueuedEvent> _queue =
      SimplePriorityQueue<QueuedEvent>(eventComparator);
  final Emitter<VirtualEvent> _onEventScheduled = Emitter<VirtualEvent>();

  Event<VirtualEvent> get onEventScheduled => _onEventScheduled.event;

  VirtualClock([VirtualTime startTime = 0]) : _now = startTime;

  VirtualTime get now => _now;
  bool get hasEvents => _queue.length > 0;

  IDisposable schedule(VirtualEvent event) {
    if (event.time < _now) {
      throw StateError(
        'Scheduled time (${event.time}) must be >= now ($_now).',
      );
    }
    final QueuedEvent queued = QueuedEvent(
      time: event.time,
      source: event.source,
      trace: event.trace,
      preferRealAnimationFrame: event.preferRealAnimationFrame,
      runFn: event.run,
      id: _idCounter++,
    );
    _queue.add(queued);
    _onEventScheduled.fire(event);
    return _DisposableRemove(_queue, queued);
  }

  VirtualEvent? peekNext() => _queue.getMin();

  VirtualEvent? runNext() {
    final QueuedEvent? e = _queue.removeMin();
    if (e != null) {
      _now = e.time;
      e.run();
    }
    return e;
  }

  List<VirtualEvent> getEvents() => _queue.toSortedArray();
}

/// Carrier for the inline disposable returned by `schedule`:
/// `{ dispose: () => this._queue.remove(queued) }`.
class _DisposableRemove implements IDisposable {
  final SimplePriorityQueue<QueuedEvent> _queue;
  final QueuedEvent _queued;
  _DisposableRemove(this._queue, this._queued);

  @override
  void dispose() => _queue.remove(_queued);
}

/// 1:1: `class SimplePriorityQueue<T>`
class SimplePriorityQueue<T> {
  final List<T> _items = <T>[];
  bool _sorted = true;
  final Comparator<T> _compare;

  SimplePriorityQueue(this._compare);

  int get length => _items.length;

  void add(T value) {
    _items.add(value);
    _sorted = false;
  }

  void remove(T value) {
    final int i = _items.indexOf(value);
    if (i != -1) {
      _items.removeAt(i);
    }
  }

  T? getMin() {
    _ensureSorted();
    return _items.isEmpty ? null : _items[0];
  }

  T? removeMin() {
    _ensureSorted();
    return _items.isEmpty ? null : _items.removeAt(0);
  }

  List<T> toSortedArray() {
    _ensureSorted();
    return List<T>.from(_items);
  }

  void _ensureSorted() {
    if (_sorted) {
      return;
    }
    _items.sort(_compare);
    _sorted = true;
  }
}
