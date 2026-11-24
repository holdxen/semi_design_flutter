// 1:1 port of vs/platform/log/common/logService.ts
// Truth: tool/ts2dart/batch131_truth.json — real transpiled logService.ts + log.ts.
// ---------------------------------------------------------------------------

import '../../../base/common/event.dart' as events;
import '../../../base/common/lifecycle.dart' as lifecycle;
import 'log.dart' as log;

/// 1:1: `export class LogService extends Disposable implements ILogService`.
class LogService extends lifecycle.Disposable implements log.ILogServiceType {
  LogService(log.ILogger primaryLogger, [List<log.ILogger> otherLoggers = const <log.ILogger>[]]) {
    logger = log.MultiplexLogger(<log.ILogger>[primaryLogger, ...otherLoggers]);
    register(primaryLogger.onDidChangeLogLevel((dynamic level) {
      setLevel(level as int);
    }));
  }

  // ignore: unused_element
  Object? get _serviceBrand => null;

  late final log.MultiplexLogger logger;

  @override
  events.Event<int> get onDidChangeLogLevel => logger.onDidChangeLogLevel;

  @override
  void setLevel(int level) => logger.setLevel(level);

  @override
  int getLevel() => logger.getLevel();

  @override
  void trace(String message, [List<Object?> args = const <Object?>[]]) =>
      logger.trace(message, args);

  @override
  void debug(String message, [List<Object?> args = const <Object?>[]]) =>
      logger.debug(message, args);

  @override
  void info(String message, [List<Object?> args = const <Object?>[]]) =>
      logger.info(message, args);

  @override
  void warn(Object message, [List<Object?> args = const <Object?>[]]) =>
      logger.warn(message, args);

  @override
  void error(Object message, [List<Object?> args = const <Object?>[]]) =>
      logger.error(message, args);

  @override
  void flush() => logger.flush();
}
