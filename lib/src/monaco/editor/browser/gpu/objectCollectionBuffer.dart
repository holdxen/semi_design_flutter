// 1:1 port of vs/editor/browser/gpu/objectCollectionBuffer.ts

import 'dart:typed_data';

import '../../../base/common/event.dart' show Emitter, Event, eventForward;
import '../../../base/common/lifecycle.dart'
    show Disposable, IDisposable, dispose, toDisposable;
import '../../../base/common/linkedList.dart' show LinkedList;
import 'bufferDirtyTracker.dart'
    show BufferDirtyTracker, IBufferDirtyTrackerReader;

/// 1:1: `export interface ObjectCollectionBufferPropertySpec`
class ObjectCollectionBufferPropertySpec {
  final String name;
  const ObjectCollectionBufferPropertySpec({required this.name});
}

/// 1:1: `ObjectCollectionPropertyValues<T>` — mapped type erased to a map of
/// property name -> number.
typedef ObjectCollectionPropertyValues = Map<String, num>;

/// 1:1: `export interface IObjectCollectionBuffer<T>`
abstract class IObjectCollectionBuffer implements IDisposable {
  /// The underlying buffer. This **should not** be modified externally.
  ByteBuffer get buffer;

  /// A view of the underlying buffer. This **should not** be modified externally.
  Float32List get view;

  /// The size of the used portion of the buffer (in bytes).
  int get bufferUsedSize;

  /// The size of the used portion of the view (in float32s).
  int get viewUsedSize;

  /// The number of entries in the buffer.
  int get entryCount;

  /// A tracker for dirty regions in the buffer.
  IBufferDirtyTrackerReader get dirtyTracker;

  /// Fires when the buffer is modified.
  Event<void> get onDidChange;

  /// Fires when the buffer is recreated.
  Event<void> get onDidChangeBuffer;

  /// Creates an entry in the collection.
  IObjectCollectionBufferEntry createEntry(ObjectCollectionPropertyValues data);
}

/// 1:1: `export interface IObjectCollectionBufferEntry<T>`
abstract class IObjectCollectionBufferEntry implements IDisposable {
  void set(String propertyName, num value);
  num get(String propertyName);
  void setRaw(List<num> data);
}

/// 1:1: `export function createObjectCollectionBuffer`
IObjectCollectionBuffer createObjectCollectionBuffer(
  List<ObjectCollectionBufferPropertySpec> propertySpecs,
  int capacity,
) {
  return ObjectCollectionBuffer(propertySpecs, capacity);
}

/// Internal spec augmented with its buffer offset.
/// 1:1: `ObjectCollectionBufferPropertySpec & { offset: number }`
class _OffsetPropertySpec {
  final String name;
  final int offset;
  const _OffsetPropertySpec({required this.name, required this.offset});
}

/// 1:1: `class ObjectCollectionBuffer<T>`
class ObjectCollectionBuffer extends Disposable
    implements IObjectCollectionBuffer {
  @override
  late Float32List view;

  @override
  ByteBuffer get buffer => view.buffer;

  @override
  int get bufferUsedSize => viewUsedSize * Float32List.bytesPerElement;

  @override
  int get viewUsedSize => _entries.size * _entrySize;

  @override
  int get entryCount => _entries.size;

  final BufferDirtyTracker _dirtyTracker = BufferDirtyTracker();
  @override
  IBufferDirtyTrackerReader get dirtyTracker => _dirtyTracker;

  final Map<String, _OffsetPropertySpec> _propertySpecsMap =
      <String, _OffsetPropertySpec>{};
  final int _entrySize;
  final LinkedList<ObjectCollectionBufferEntry> _entries =
      LinkedList<ObjectCollectionBufferEntry>();

  late final Emitter<void> _onDidChange;
  @override
  Event<void> get onDidChange => _onDidChange.event;
  late final Emitter<void> _onDidChangeBuffer;
  @override
  Event<void> get onDidChangeBuffer => _onDidChangeBuffer.event;

  final List<ObjectCollectionBufferPropertySpec> propertySpecs;
  int capacity;

  ObjectCollectionBuffer(this.propertySpecs, this.capacity)
      : _entrySize = propertySpecs.length {
    _onDidChange = register(Emitter<void>());
    _onDidChangeBuffer = register(Emitter<void>());
    view = Float32List(capacity * propertySpecs.length);
    for (int i = 0; i < propertySpecs.length; i++) {
      final _OffsetPropertySpec spec =
          _OffsetPropertySpec(offset: i, name: propertySpecs[i].name);
      _propertySpecsMap[spec.name] = spec;
    }
    register(toDisposable(() => dispose(_entries.iterable)));
  }

  @override
  IObjectCollectionBufferEntry createEntry(ObjectCollectionPropertyValues data) {
    if (_entries.size == capacity) {
      _expandBuffer();
      _onDidChangeBuffer.fire(null);
    }

    final ObjectCollectionBufferEntry value = ObjectCollectionBufferEntry(
      view,
      _propertySpecsMap,
      _dirtyTracker,
      _entries.size,
      data,
    );
    final void Function() removeFromEntries = _entries.push(value);
    final List<IDisposable> listeners = <IDisposable>[];
    listeners.add(eventForward<void>(value.onDidChange, _onDidChange));
    listeners.add(value.onWillDispose((dynamic _) {
      final int deletedEntryIndex = value.i;
      removeFromEntries();

      // Shift all entries after the deleted entry to the left.
      // JS: this.view.set(this.view.subarray(from, to), dest)
      final int from = deletedEntryIndex * _entrySize + 2;
      final int rawTo = _entries.size * _entrySize + 2;
      // JS `subarray` clamps its end to the buffer length.
      final int to = rawTo > view.length ? view.length : rawTo;
      final int dest = deletedEntryIndex * _entrySize;
      final int count = to - from;
      if (count > 0) {
        view.setRange(dest, dest + count, view, from);
      }

      // Update entries to reflect the new i
      for (final ObjectCollectionBufferEntry entry in _entries.iterable) {
        if (entry.i > deletedEntryIndex) {
          entry.i--;
        }
      }
      _dirtyTracker.flag(
        deletedEntryIndex,
        (_entries.size - deletedEntryIndex) * _entrySize,
      );
      dispose(listeners);
    }));
    return value;
  }

  void _expandBuffer() {
    capacity *= 2;
    final Float32List newView = Float32List(capacity * _entrySize);
    newView.setRange(0, view.length, view, 0);
    view = newView;
  }
}

/// 1:1: `class ObjectCollectionBufferEntry<T>`
class ObjectCollectionBufferEntry extends Disposable
    implements IObjectCollectionBufferEntry {
  late final Emitter<void> _onDidChange;
  Event<void> get onDidChange => _onDidChange.event;
  late final Emitter<void> _onWillDispose;
  Event<void> get onWillDispose => _onWillDispose.event;

  final Float32List _view;
  final Map<String, _OffsetPropertySpec> _propertySpecsMap;
  final BufferDirtyTracker _dirtyTracker;

  /// Public mutable index (source: `public i: number`).
  int i;

  ObjectCollectionBufferEntry(
    this._view,
    this._propertySpecsMap,
    this._dirtyTracker,
    this.i,
    ObjectCollectionPropertyValues data,
  ) {
    _onDidChange = register(Emitter<void>());
    _onWillDispose = register(Emitter<void>());
    for (final _OffsetPropertySpec propertySpec in _propertySpecsMap.values) {
      _view[i * _propertySpecsMap.length + propertySpec.offset] =
          (data[propertySpec.name] ?? 0).toDouble();
    }
    _dirtyTracker.flag(i * _propertySpecsMap.length, _propertySpecsMap.length);
  }

  @override
  void dispose() {
    _onWillDispose.fire(null);
    super.dispose();
  }

  @override
  void set(String propertyName, num value) {
    final int i = this.i * _propertySpecsMap.length +
        _propertySpecsMap[propertyName]!.offset;
    _view[_dirtyTracker.flag(i)] = value.toDouble();
    _onDidChange.fire(null);
  }

  @override
  num get(String propertyName) {
    return _view[i * _propertySpecsMap.length +
        _propertySpecsMap[propertyName]!.offset];
  }

  @override
  void setRaw(List<num> data) {
    if (data.length != _propertySpecsMap.length) {
      throw StateError(
        'Data length ${data.length} does not match the number of properties '
        'in the collection (${_propertySpecsMap.length})',
      );
    }
    final int dest = i * _propertySpecsMap.length;
    for (int k = 0; k < data.length; k++) {
      _view[dest + k] = data[k].toDouble();
    }
    _dirtyTracker.flag(dest, _propertySpecsMap.length);
  }
}
