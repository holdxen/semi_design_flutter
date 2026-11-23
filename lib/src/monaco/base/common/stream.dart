// ---------------------------------------------------------------------------
// Port of vscode/src/vs/base/common/stream.ts
// Translated 1:1 from TypeScript.
// Adaptations (documented inline):
//   - TS `on('data'|'error'|'end', cb)` overloads -> `on(String event, cb)`
//     with a dynamic callback (Dart cannot overload by literal type).
//   - `Promise` -> `Future`; pending promises -> `Completer<void>`.
//   - JS `Error` -> `Object` so arbitrary Dart throw values can flow.
// ---------------------------------------------------------------------------

import 'dart:async';

import 'cancellation.dart' as cancellation;
import 'errors.dart' as errors;
import 'lifecycle.dart' as lifecycle;

/// 1:1: `export type ReadableStreamEventPayload<T>`
typedef ReadableStreamEventPayload<T> = Object?;

/// 1:1: `export interface ReadableStreamEvents<T>`
abstract class ReadableStreamEvents<T> {
  /// 1:1: `on(event: 'data'|'error'|'end', callback)` overloads collapsed.
  void on(String event, dynamic callback);
}

/// 1:1: `export interface ReadableStream<T> extends ReadableStreamEvents<T>`
abstract class ReadableStream<T> implements ReadableStreamEvents<T> {
  void pause();

  void resume();

  void destroy();

  void removeListener(String event, Function callback);
}

/// 1:1: `export interface Readable<T>`
abstract class Readable<T> {
  T? read();
}

/// 1:1: `export function isReadable<T>`
bool isReadable<T>(Object? obj) {
  final Object? candidate = obj;
  if (candidate == null) {
    return false;
  }
  return candidate is Readable<T>;
}

/// 1:1: `export interface WriteableStream<T> extends ReadableStream<T>`
abstract class WriteableStream<T> implements ReadableStream<T> {
  Future<void>? write(T data);

  void error(Object error);

  /// 1:1: `end(result?: T)`; `_sentinel` distinguishes an omitted argument
  /// from an explicit `null` result.
  void end([Object? result = streamNoResult]);

  static const Object streamNoResult = Object();
}

/// 1:1: `export interface ReadableBufferedStream<T>`
class ReadableBufferedStream<T> {
  final ReadableStream<T> stream;
  final List<T> buffer;
  final bool ended;

  ReadableBufferedStream(this.stream, this.buffer, this.ended);
}

/// 1:1: `export function isReadableStream<T>`
bool isReadableStream<T>(Object? obj) {
  final Object? candidate = obj;
  if (candidate == null) {
    return false;
  }
  return candidate is ReadableStream<T>;
}

/// 1:1: `export function isReadableBufferedStream<T>`
bool isReadableBufferedStream<T>(Object? obj) {
  final Object? candidate = obj;
  if (candidate == null) {
    return false;
  }
  if (candidate is! ReadableBufferedStream<T>) {
    return false;
  }
  return isReadableStream<T>(candidate.stream);
}

/// 1:1: `export interface IReducer<T, R = T>`
typedef IReducer<T, R> = R Function(List<T> data);

/// 1:1: `export interface IDataTransformer<Original, Transformed>`
typedef IDataTransformer<Original, Transformed> = Transformed Function(
    Original data);

/// 1:1: `export interface IErrorTransformer`
typedef IErrorTransformer = Object Function(Object error);

/// 1:1: `export interface ITransformer<Original, Transformed>`
class ITransformer<Original, Transformed> {
  final IDataTransformer<Original, Transformed> data;
  final IErrorTransformer? error;

  ITransformer(this.data, [this.error]);
}

/// 1:1: `export interface WriteableStreamOptions`
class WriteableStreamOptions {
  final num? highWaterMark;

  WriteableStreamOptions([this.highWaterMark]);
}

/// 1:1: `export function newWriteableStream`
WriteableStream<T> newWriteableStream<T>(
        IReducer<T, T>? reducer,
        [WriteableStreamOptions? options]) =>
    WriteableStreamImpl<T>(reducer, options);

/// 1:1: `class WriteableStreamImpl<T>`
class WriteableStreamImpl<T> implements WriteableStream<T> {
  final Map<String, bool> state = <String, bool>{
    'flowing': false,
    'ended': false,
    'destroyed': false,
  };

  final List<T> dataBuffer = <T>[];
  final List<Object> errorBuffer = <Object>[];

  final List<void Function(T)> dataListeners = <void Function(T)>[];
  final List<void Function(Object)> errorListeners = <void Function(Object)>[];
  final List<void Function()> endListeners = <void Function()>[];

  final List<Completer<void>> pendingWritePromises = <Completer<void>>[];

  final IReducer<T, T>? reducer;
  final WriteableStreamOptions? options;

  WriteableStreamImpl(this.reducer, [this.options]);

  @override
  void pause() {
    if (state['destroyed'] == true) {
      return;
    }
    state['flowing'] = false;
  }

  @override
  void resume() {
    if (state['destroyed'] == true) {
      return;
    }
    if (state['flowing'] != true) {
      state['flowing'] = true;
      flowData();
      flowErrors();
      flowEnd();
    }
  }

  @override
  Future<void>? write(T data) {
    if (state['destroyed'] == true) {
      return null;
    }
    if (state['flowing'] == true) {
      emitData(data);
      return null;
    }

    dataBuffer.add(data);
    final num? highWaterMark = options?.highWaterMark;
    if (highWaterMark != null && dataBuffer.length > highWaterMark) {
      final Completer<void> completer = Completer<void>();
      pendingWritePromises.add(completer);
      return completer.future;
    }
    return null;
  }

  @override
  void error(Object error) {
    if (state['destroyed'] == true) {
      return;
    }
    if (state['flowing'] == true) {
      emitError(error);
    } else {
      errorBuffer.add(error);
    }
  }

  @override
  void end([Object? result = WriteableStream.streamNoResult]) {
    if (state['destroyed'] == true) {
      return;
    }
    if (!identical(result, WriteableStream.streamNoResult)) {
      write(result as T);
    }
    if (state['flowing'] == true) {
      emitEnd();
      destroy();
    } else {
      state['ended'] = true;
    }
  }

  void emitData(T data) {
    // slice(0) — avoid listener mutation while delivering.
    for (final Function listener in dataListeners.toList()) {
      listener(data);
    }
  }

  void emitError(Object error) {
    if (errorListeners.isEmpty) {
      errors.onUnexpectedError(error);
    } else {
      for (final Function listener in errorListeners.toList()) {
        listener(error);
      }
    }
  }

  void emitEnd() {
    for (final Function listener in endListeners.toList()) {
      listener();
    }
  }

  @override
  void on(String event, dynamic callback) {
    if (state['destroyed'] == true) {
      return;
    }
    switch (event) {
      case 'data':
        dataListeners.add(callback as void Function(T));
        // Switch into flowing mode as soon as the first data listener is added.
        resume();
        break;
      case 'end':
        endListeners.add(callback as void Function());
        if (state['flowing'] == true && flowEnd()) {
          destroy();
        }
        break;
      case 'error':
        errorListeners.add(callback as void Function(Object));
        if (state['flowing'] == true) {
          flowErrors();
        }
        break;
    }
  }

  @override
  void removeListener(String event, Function callback) {
    if (state['destroyed'] == true) {
      return;
    }
    List<Function>? target;
    switch (event) {
      case 'data':
        target = dataListeners;
        break;
      case 'end':
        target = endListeners;
        break;
      case 'error':
        target = errorListeners;
        break;
    }
    if (target != null) {
      final int index = target.indexOf(callback);
      if (index >= 0) {
        target.removeAt(index);
      }
    }
  }

  void flowData() {
    if (dataBuffer.isEmpty) {
      return;
    }
    if (reducer != null) {
      emitData(reducer!(List<T>.from(dataBuffer)));
    } else {
      for (final T data in dataBuffer) {
        emitData(data);
      }
    }
    dataBuffer.clear();
    final List<Completer<void>> pending =
        List<Completer<void>>.from(pendingWritePromises);
    pendingWritePromises.clear();
    for (final Completer<void> pendingWritePromise in pending) {
      if (!pendingWritePromise.isCompleted) {
        pendingWritePromise.complete();
      }
    }
  }

  void flowErrors() {
    if (errorListeners.isNotEmpty) {
      for (final Object error in errorBuffer) {
        emitError(error);
      }
      errorBuffer.clear();
    }
  }

  bool flowEnd() {
    if (state['ended'] == true) {
      emitEnd();
      return endListeners.isNotEmpty;
    }
    return false;
  }

  @override
  void destroy() {
    if (state['destroyed'] != true) {
      state['destroyed'] = true;
      state['ended'] = true;
      dataBuffer.clear();
      errorBuffer.clear();
      dataListeners.clear();
      errorListeners.clear();
      endListeners.clear();
      pendingWritePromises.clear();
    }
  }
}

/// 1:1: `export function consumeReadable`
T consumeReadable<T>(Readable<T> readable, IReducer<T, T> reducer) {
  final List<T> chunks = <T>[];
  while (true) {
    final T? chunk = readable.read();
    if (chunk == null) {
      break;
    }
    chunks.add(chunk);
  }
  return reducer(chunks);
}

/// 1:1: `export function peekReadable`
Object? peekReadable<T>(
    Readable<T> readable, IReducer<T, T> reducer, int maxChunks) {
  final List<T> chunks = <T>[];
  Object? chunk;
  while (true) {
    chunk = readable.read();
    if (chunk == null || chunks.length >= maxChunks) {
      break;
    }
    chunks.add(chunk as T);
  }

  if (chunk == null && chunks.isNotEmpty) {
    return reducer(chunks);
  }

  return PeekReadable<T>(chunks, readable, chunk);
}

/// Readable wrapper returned by [peekReadable].
class PeekReadable<T> implements Readable<T> {
  final List<T> chunks;
  final Readable<T> readable;
  final Object? _chunk;
  bool _chunkConsumed = false;

  PeekReadable(this.chunks, this.readable, this._chunk);

  @override
  T? read() {
    if (chunks.isNotEmpty) {
      return chunks.removeAt(0);
    }
    if (!_chunkConsumed) {
      _chunkConsumed = true;
      return _chunk as T?;
    }
    return readable.read();
  }
}

/// 1:1: `export function consumeStream` (both overloads collapsed)
Future<Object?> consumeStream<T>(ReadableStreamEvents<T> stream,
    [IReducer<T, Object?>? reducer]) {
  final Completer<Object?> completer = Completer<Object?>();
  final List<T> chunks = <T>[];

  listenStream(
    stream,
    StreamListener<T>(
      onData: (T chunk) {
        if (reducer != null) {
          chunks.add(chunk);
        }
      },
      onError: (Object error) {
        if (reducer != null) {
          if (!completer.isCompleted) completer.completeError(error);
        } else if (!completer.isCompleted) {
          completer.complete(null);
        }
      },
      onEnd: () {
        if (reducer != null) {
          if (!completer.isCompleted) completer.complete(reducer(chunks));
        } else if (!completer.isCompleted) {
          completer.complete(null);
        }
      },
    ),
  );
  return completer.future;
}

/// 1:1: `export interface IStreamListener<T>`
class StreamListener<T> {
  final void Function(T data) onData;
  final void Function(Object error) onError;
  final void Function() onEnd;

  StreamListener({
    required this.onData,
    required this.onError,
    required this.onEnd,
  });
}

/// 1:1: `export function listenStream`
void listenStream<T>(ReadableStreamEvents<T> stream, StreamListener<T> listener,
    [cancellation.CancellationToken? token]) {
  stream.on('error', (Object error) {
    if (token?.isCancellationRequested != true) {
      listener.onError(error);
    }
  });

  stream.on('end', () {
    if (token?.isCancellationRequested != true) {
      listener.onEnd();
    }
  });

  // Important: data listener last — it turns the stream into flowing mode.
  stream.on('data', (T data) {
    if (token?.isCancellationRequested != true) {
      listener.onData(data);
    }
  });
}

/// 1:1: `export function peekStream`
Future<ReadableBufferedStream<T>> peekStream<T>(
    ReadableStream<T> stream, int maxChunks) {
  final Completer<ReadableBufferedStream<T>> completer =
      Completer<ReadableBufferedStream<T>>();
  final lifecycle.DisposableStore streamListeners =
      lifecycle.DisposableStore();
  final List<T> buffer = <T>[];

  void dataListener(T chunk) {
    buffer.add(chunk);
    if (buffer.length > maxChunks) {
      streamListeners.dispose();
      stream.pause();
      if (!completer.isCompleted) {
        completer.complete(ReadableBufferedStream<T>(stream, buffer, false));
      }
    }
  }

  void errorListener(Object error) {
    streamListeners.dispose();
    if (!completer.isCompleted) completer.completeError(error);
  }

  void endListener() {
    streamListeners.dispose();
    if (!completer.isCompleted) {
      completer.complete(ReadableBufferedStream<T>(stream, buffer, true));
    }
  }

  streamListeners
      .add(lifecycle.toDisposable(() => stream.removeListener('error', errorListener)));
  stream.on('error', errorListener);

  streamListeners
      .add(lifecycle.toDisposable(() => stream.removeListener('end', endListener)));
  stream.on('end', endListener);

  // Important: leave the data listener last.
  streamListeners
      .add(lifecycle.toDisposable(() => stream.removeListener('data', dataListener)));
  stream.on('data', dataListener);

  return completer.future;
}

/// 1:1: `export function toStream`
ReadableStream<T> toStream<T>(T t, IReducer<T, T> reducer) {
  final WriteableStream<T> stream = newWriteableStream<T>(reducer);
  stream.end(t);
  return stream;
}

/// 1:1: `export function emptyStream`
ReadableStream<Never> emptyStream() {
  final WriteableStream<Never> stream =
      newWriteableStream<Never>((List<Never> data) {
    throw StateError('not supported');
  });
  stream.end();
  return stream;
}

/// 1:1: `export function toReadable`
Readable<T> toReadable<T>(T t) {
  return _SingleReadable<T>(t);
}

class _SingleReadable<T> implements Readable<T> {
  final T value;
  bool consumed = false;

  _SingleReadable(this.value);

  @override
  T? read() {
    if (consumed) {
      return null;
    }
    consumed = true;
    return value;
  }
}

/// 1:1: `export function transform`
ReadableStream<Transformed> transform<Original, Transformed>(
  ReadableStreamEvents<Original> stream,
  ITransformer<Original, Transformed> transformer,
  IReducer<Transformed, Transformed> reducer,
) {
  final WriteableStream<Transformed> target =
      newWriteableStream<Transformed>(reducer);
  listenStream(
    stream,
    StreamListener<Original>(
      onData: (Original data) => target.write(transformer.data(data)),
      onError: (Object error) => target.error(
          transformer.error != null ? transformer.error!(error) : error),
      onEnd: () => target.end(),
    ),
  );
  return target;
}

/// 1:1: `export function prefixedReadable`
Readable<T> prefixedReadable<T>(
    T prefix, Readable<T> readable, IReducer<T, T> reducer) {
  return _PrefixReadable<T>(prefix, readable, reducer);
}

class _PrefixReadable<T> implements Readable<T> {
  final T prefix;
  final Readable<T> readable;
  final IReducer<T, T> reducer;
  bool prefixHandled = false;

  _PrefixReadable(this.prefix, this.readable, this.reducer);

  @override
  T? read() {
    final T? chunk = readable.read();
    if (!prefixHandled) {
      prefixHandled = true;
      if (chunk != null) {
        return reducer([prefix, chunk]);
      }
      return prefix;
    }
    return chunk;
  }
}

/// 1:1: `export function prefixedStream`
ReadableStream<T> prefixedStream<T>(
    T prefix, ReadableStream<T> stream, IReducer<T, T> reducer) {
  bool prefixHandled = false;
  final WriteableStream<T> target = newWriteableStream<T>(reducer);

  listenStream(
    stream,
    StreamListener<T>(
      onData: (T data) {
        if (!prefixHandled) {
          prefixHandled = true;
          target.write(reducer([prefix, data]));
        } else {
          target.write(data);
        }
      },
      onError: (Object error) => target.error(error),
      onEnd: () {
        if (!prefixHandled) {
          prefixHandled = true;
          target.write(prefix);
        }
        target.end();
      },
    ),
  );

  return target;
}
