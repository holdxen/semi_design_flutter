// 1:1 port of vscode/src/vs/editor/browser/gpu/taskQueue.ts
//
// Window timers and the wall clock are injectable so the queue can be driven
// by the real TypeScript runtime truth in tests.

import '../../../base/common/lifecycle.dart' as lifecycle;
import '../../../platform/log/common/log.dart' as log;

/// 1:1: `export interface ITaskQueue extends IDisposable`
abstract class ITaskQueue implements lifecycle.IDisposable {
  /// 1:1: `enqueue(task: () => boolean | void): void`
  void enqueue(Object? Function() task);

  /// 1:1: `flush(): void`
  void flush();

  /// 1:1: `clear(): void`
  void clear();
}

/// 1:1: `interface ITaskDeadline`
abstract class ITaskDeadline {
  num timeRemaining();
}

/// 1:1: `type CallbackWithDeadline = (deadline: ITaskDeadline) => void`
typedef CallbackWithDeadline = void Function(ITaskDeadline deadline);

/// Browser/window boundaries plus the wall clock used by task queue timing.
class TaskQueueEnvironment {
  int Function(void Function() callback) setTimeout = (void Function() cb) {
    throw UnimplementedError('window.setTimeout');
  };

  void Function(int identifier) clearTimeout = (int id) {};

  /// Absent when the environment has no `requestIdleCallback`.
  int Function(CallbackWithDeadline callback)? requestIdleCallback;

  void Function(int identifier)? cancelIdleCallback;

  int Function() now = () => DateTime.now().millisecondsSinceEpoch;

  /// 1:1: `PriorityTaskQueue._createDeadline`: injectable so tests can drive
  /// arbitrary `timeRemaining()` sequences.
  ITaskDeadline Function(int duration) createDeadline = _defaultTaskQueueDeadline;
}

/// Injectable browser boundary of this module.
final TaskQueueEnvironment taskQueueEnvironment = TaskQueueEnvironment();

/// 1:1: `abstract class TaskQueue extends Disposable implements ITaskQueue`
abstract class TaskQueue extends lifecycle.Disposable implements ITaskQueue {
  TaskQueue(this._logService) : super() {
    register(lifecycle.toDisposable(clear));
  }

  final log.ILogServiceType _logService;

  final List<Object? Function()> _tasks = <Object? Function()>[];
  int? _idleCallback;
  int _i = 0;

  int _requestCallback(CallbackWithDeadline callback);
  void _cancelCallback(int identifier);

  @override
  void enqueue(Object? Function() task) {
    _tasks.add(task);
    _start();
  }

  @override
  void flush() {
    while (_i < _tasks.length) {
      if (_tasks[_i]() != true) {
        _i++;
      }
    }
    clear();
  }

  @override
  void clear() {
    final int? callback = _idleCallback;
    if (callback != null) {
      _cancelCallback(callback);
      _idleCallback = null;
    }
    _i = 0;
    _tasks.clear();
  }

  void _start() {
    if (_idleCallback == null) {
      _idleCallback = _requestCallback(_process);
    }
  }

  void _process(ITaskDeadline deadline) {
    _idleCallback = null;
    int taskDuration = 0;
    int longestTask = 0;
    num lastDeadlineRemaining = deadline.timeRemaining();
    num deadlineRemaining = 0;
    while (_i < _tasks.length) {
      final int started = taskQueueEnvironment.now();
      if (_tasks[_i]() != true) {
        _i++;
      }
      final int elapsed = taskQueueEnvironment.now() - started;
      taskDuration = elapsed < 1 ? 1 : elapsed;
      if (taskDuration > longestTask) longestTask = taskDuration;
      deadlineRemaining = deadline.timeRemaining();
      if (longestTask * 1.5 > deadlineRemaining) {
        if (lastDeadlineRemaining - taskDuration < -20) {
          final int exceeded = (lastDeadlineRemaining - taskDuration).abs().round();
          _logService.warn('task queue exceeded allotted deadline by ${exceeded}ms');
        }
        _start();
        return;
      }
      lastDeadlineRemaining = deadlineRemaining;
    }
    clear();
  }
}

/// 1:1: `export class PriorityTaskQueue extends TaskQueue`
class PriorityTaskQueue extends TaskQueue {
  PriorityTaskQueue(super.logService);

  @override
  int _requestCallback(CallbackWithDeadline callback) => taskQueueEnvironment
      .setTimeout(() => callback(taskQueueEnvironment.createDeadline(16)));

  @override
  void _cancelCallback(int identifier) =>
      taskQueueEnvironment.clearTimeout(identifier);
}

class _Deadline implements ITaskDeadline {
  _Deadline(this._end);

  final int _end;

  @override
  num timeRemaining() {
    final int remaining = _end - taskQueueEnvironment.now();
    return remaining > 0 ? remaining : 0;
  }
}

/// 1:1: `class IdleTaskQueueInternal extends TaskQueue`
class IdleTaskQueueInternal extends TaskQueue {
  IdleTaskQueueInternal(super.logService);

  @override
  int _requestCallback(CallbackWithDeadline callback) =>
      taskQueueEnvironment.requestIdleCallback!(callback);

  @override
  void _cancelCallback(int identifier) =>
      taskQueueEnvironment.cancelIdleCallback!(identifier);
}

/// 1:1: `export const IdleTaskQueue = ('requestIdleCallback' in getActiveWindow()) ? IdleTaskQueueInternal : PriorityTaskQueue`
///
/// Dart has no first-class class-valued constant, so the selected behaviour is
/// carried by this class: it uses idle callbacks when the window provides them
/// and falls back to the priority queue otherwise.
class IdleTaskQueue extends TaskQueue {
  IdleTaskQueue(super.logService);

  @override
  int _requestCallback(CallbackWithDeadline callback) {
    final int Function(CallbackWithDeadline)? idle =
        taskQueueEnvironment.requestIdleCallback;
    if (idle != null) return idle(callback);
    return taskQueueEnvironment
        .setTimeout(() => callback(taskQueueEnvironment.createDeadline(16)));
  }

  @override
  void _cancelCallback(int identifier) {
    final void Function(int)? cancel = taskQueueEnvironment.cancelIdleCallback;
    if (cancel != null) {
      cancel(identifier);
      return;
    }
    taskQueueEnvironment.clearTimeout(identifier);
  }

}

/// Carrier for the `IInstantiationService.createInstance(IdleTaskQueue)` call.
class TaskInstantiationService {
  TaskInstantiationService(this.logger);

  final log.ILogServiceType logger;
}

/// 1:1: `export class DebouncedIdleTask`
class DebouncedIdleTask {
  DebouncedIdleTask(Object instantiationService)
      : _queue = taskQueueInstantiationProvider(instantiationService);

  final ITaskQueue _queue;

  /// 1:1: `set(task: () => boolean | void): void`
  void set(Object? Function() task) {
    _queue.clear();
    _queue.enqueue(task);
  }

  /// 1:1: `flush(): void`
  void flush() => _queue.flush();
}

/// 1:1: `instantiationService.createInstance(IdleTaskQueue)` boundary.
ITaskQueue Function(Object instantiationService) taskQueueInstantiationProvider =
    (Object instantiationService) => IdleTaskQueue(
        (instantiationService as TaskInstantiationService).logger);

ITaskDeadline _defaultTaskQueueDeadline(int duration) =>
    _Deadline(taskQueueEnvironment.now() + duration);
