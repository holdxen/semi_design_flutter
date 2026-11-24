// 1:1 port of vs/platform/log/common/log.ts
// Truth: tool/ts2dart/batch130_truth.json — real transpiled log.ts with faithful
// infrastructure stubs (Emitter/Disposable/URI/ResourceMap/toErrorMessage/hash).
// ---------------------------------------------------------------------------

import '../../../base/common/errorMessage.dart' as error_message;
import '../../../base/common/event.dart' as events;
import '../../../base/common/hash.dart' as hashLib;
import '../../../base/common/lifecycle.dart' as lifecycle;
import '../../../base/common/map.dart' as mapLib;
import '../../../base/common/platform.dart' as platform;
import '../../../base/common/resources.dart' as resources;
import '../../../base/common/types.dart' as types;
import '../../../base/common/uri.dart' as uri;
import '../../action/common/action.dart' show ILocalizedString;
import '../../contextkey/common/contextkey.dart' as contextkey;
import '../../environment/common/environment.dart' as environment;
import '../../instantiation/common/instantiation.dart'
    show ServiceIdentifier, createDecorator;
import '../../../nls.dart' as nls;

final ServiceIdentifier<ILogServiceType> ILogService =
    createDecorator<ILogServiceType>('logService');
final ServiceIdentifier<ILoggerServiceType> ILoggerService =
    createDecorator<ILoggerServiceType>('loggerService');

/// 1:1: `now()` — timestamp used by console loggers.
String now() => DateTime.now().toUtc().toIso8601String();

/// 1:1: `isLogLevel(thing)`.
bool isLogLevel(Object? thing) => types.isNumber(thing);

/// 1:1: `enum LogLevel` (numeric values match TS).
class LogLevel {
  static const int Off = 0;
  static const int Trace = 1;
  static const int Debug = 2;
  static const int Info = 3;
  static const int Warning = 4;
  static const int Error = 5;
}

const int DEFAULT_LOG_LEVEL = LogLevel.Info;

/// 1:1: `interface ILogger extends IDisposable`.
abstract class ILogger implements lifecycle.IDisposable {
  events.Event<int> get onDidChangeLogLevel;
  int getLevel();
  void setLevel(int level);
  void trace(String message, [List<Object?> args = const <Object?>[]]);
  void debug(String message, [List<Object?> args = const <Object?>[]]);
  void info(String message, [List<Object?> args = const <Object?>[]]);
  void warn(Object message, [List<Object?> args = const <Object?>[]]);
  void error(Object message, [List<Object?> args = const <Object?>[]]);
  void flush();
}

/// 1:1: `canLog(loggerLevel, messageLevel)`.
bool canLog(int loggerLevel, int messageLevel) =>
    loggerLevel != LogLevel.Off && loggerLevel <= messageLevel;

/// 1:1: `log(logger, level, message)`.
void log(ILogger logger, int level, String message) {
  switch (level) {
    case LogLevel.Trace:
      logger.trace(message);
      break;
    case LogLevel.Debug:
      logger.debug(message);
      break;
    case LogLevel.Info:
      logger.info(message);
      break;
    case LogLevel.Warning:
      logger.warn(message);
      break;
    case LogLevel.Error:
      logger.error(message);
      break;
    case LogLevel.Off:
      break;
    default:
      throw StateError('Invalid log level $level');
  }
}

/// 1:1: `createUnexpectedErrorHandler(logger)`.
void Function(Object error) createUnexpectedErrorHandler(ILogger logger) {
  String? previousMessage;
  int previousTime = 0;

  return (Object error) {
    final String message = error_message.toErrorMessage(error, true);
    if (message.isEmpty) {
      return;
    }

    final int nowMs = DateTime.now().millisecondsSinceEpoch;
    if (message == previousMessage && nowMs - previousTime <= 1000) {
      return;
    }

    previousTime = nowMs;
    previousMessage = message;

    // Keep native errors for debugger source mapping, but retain the message
    // fallback for stackless errors.
    if (error is Error && _hasStackTrace(error)) {
      logger.error(error);
    } else {
      logger.error(message);
    }
  };
}

/// TS `error instanceof Error && error.stack`: Dart `Error` has an optional
/// `stackTrace`; treat `null` as absent stack.
bool _hasStackTrace(Error error) => error.stackTrace != StackTrace.empty;

const bool isDevConsoleLogForwardingEnabled = false;

// ---------------------------------------------------------------------------
// format / levels
// ---------------------------------------------------------------------------

/// 1:1: `format(args, verbose)`.
String format(List<Object?> args, [bool verbose = false]) {
  final StringBuffer result = StringBuffer();

  for (int i = 0; i < args.length; i++) {
    Object? a = args[i];
    if (a is Error) {
      a = error_message.toErrorMessage(a, verbose);
    }
    if (a is Map || a is List) {
      try {
        a = _jsonStringify(a as Object);
      } catch (_) {}
    }
    if (i > 0) {
      result.write(' ');
    }
    result.write(_jsString(a));
  }

  return result.toString();
}

/// Minimal JSON.stringify equivalent for the object shapes used by `format`.
String _jsonStringify(Object value) {
  if (value is Map) {
    final List<String> parts = <String>[];
    value.forEach((Object? k, Object? v) {
      parts.add('${_jsonStringifyString(k.toString())}:${_jsonStringifyValue(v)}');
    });
    return '{${parts.join(',')}}';
  }
  if (value is List) {
    return '[${value.map(_jsonStringifyValue).join(',')}]';
  }
  return _jsonStringifyValue(value);
}

String _jsonStringifyValue(Object? v) {
  if (v == null) return 'null';
  if (v is String) return _jsonStringifyString(v);
  if (v is num) return _jsNum(v);
  if (v is bool) return v ? 'true' : 'false';
  return _jsonStringify(v);
}

String _jsonStringifyString(String s) {
  final StringBuffer out = StringBuffer('"');
  for (final int code in s.runes) {
    switch (code) {
      case 0x22:
        out.write('\\"');
        break;
      case 0x5C:
        out.write('\\\\');
        break;
      case 0x0A:
        out.write('\\n');
        break;
      case 0x0D:
        out.write('\\r');
        break;
      case 0x09:
        out.write('\\t');
        break;
      default:
        out.writeCharCode(code);
    }
  }
  out.write('"');
  return out.toString();
}

/// JS string coercion: `undefined` -> "undefined", `true`/`false`, numbers.
/// JS `null` carrier — Dart `null` stands for JS `undefined` in this port, so a
/// distinct sentinel is needed where JS `null` must stringify as "null".
class JsNull {
  const JsNull();
  @override
  String toString() => 'null';
}

const JsNull jsNull = JsNull();

String _jsString(Object? v) {
  if (v == null) return 'undefined';
  if (v is JsNull) return 'null';
  if (v is bool) return v ? 'true' : 'false';
  if (v is num) return _jsNum(v);
  return v.toString();
}

String _jsNum(num v) =>
    v is int || v == v.roundToDouble() ? v.toInt().toString() : v.toString();

/// 1:1: `type LoggerGroup`.
class LoggerGroup {
  LoggerGroup({required this.id, required this.name});
  final String id;
  final String name;
}

/// 1:1: `interface ILogService extends ILogger`.
abstract class ILogServiceType implements ILogger {
  // ignore: unused_element
  Object? get _serviceBrand;
}

/// 1:1: `interface ILoggerOptions`.
class ILoggerOptions {
  ILoggerOptions({
    this.id,
    this.name,
    this.donotRotate,
    this.donotUseFormatters,
    Object? logLevel,
    this.hidden,
    this.when,
    this.extensionId,
    this.group,
  }) : logLevel = logLevel;

  final String? id;
  final String? name;
  final bool? donotRotate;
  final bool? donotUseFormatters;

  /// `'always' | LogLevel` -> Object? carrier.
  final Object? logLevel;
  final bool? hidden;
  final String? when;
  final String? extensionId;
  final LoggerGroup? group;
}

/// 1:1: `interface ILoggerResource`.
class ILoggerResource {
  ILoggerResource({
    required this.resource,
    required this.id,
    this.name,
    this.logLevel,
    this.hidden,
    this.when,
    this.extensionId,
    this.group,
  });

  final uri.URI resource;
  final String id;
  final String? name;
  int? logLevel;
  bool? hidden;
  final String? when;
  final String? extensionId;
  final LoggerGroup? group;
}

/// 1:1: `type DidChangeLoggersEvent`.
class DidChangeLoggersEvent {
  DidChangeLoggersEvent({required this.added, required this.removed});
  final Iterable<ILoggerResource> added;
  final Iterable<ILoggerResource> removed;
}

/// 1:1: `interface ILoggerService`.
abstract class ILoggerServiceType {
  // ignore: unused_element
  Object? get _serviceBrand;

  ILogger createLogger(Object resourceOrId, [ILoggerOptions? options]);
  ILogger? getLogger(Object resourceOrId);
  events.Event<Object> get onDidChangeLogLevel;
  void setLogLevel(Object arg1, [int? arg2]);
  int getLogLevel([uri.URI? resource]);
  events.Event<List<Object>> get onDidChangeVisibility;
  void setVisibility(Object resourceOrId, bool visible);
  events.Event<DidChangeLoggersEvent> get onDidChangeLoggers;
  void registerLogger(ILoggerResource resource);
  void deregisterLogger(Object idOrResource);
  Iterable<ILoggerResource> getRegisteredLoggers();
  ILoggerResource? getRegisteredLogger(uri.URI resource);
}

// ---------------------------------------------------------------------------
// AbstractLogger / AbstractMessageLogger
// ---------------------------------------------------------------------------

/// 1:1: `abstract class AbstractLogger extends Disposable implements ILogger`.
abstract class AbstractLogger extends lifecycle.Disposable implements ILogger {
  int _level = DEFAULT_LOG_LEVEL;
  bool _disposed = false;

  final events.Emitter<int> _onDidChangeLogLevel = events.Emitter<int>();

  @override
  events.Event<int> get onDidChangeLogLevel => _onDidChangeLogLevel.event;

  @override
  void setLevel(int level) {
    if (_level != level) {
      _level = level;
      _onDidChangeLogLevel.fire(_level);
    }
  }

  @override
  int getLevel() => _level;

  /// 1:1: `protected checkLogLevel(level)`.
  bool checkLogLevel(int level) => canLog(_level, level);

  /// 1:1: `protected canLog(level)`.
  bool canLogLevel(int level) {
    if (_disposed) {
      return false;
    }
    return checkLogLevel(level);
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}

/// 1:1: `abstract class AbstractMessageLogger extends AbstractLogger`.
abstract class AbstractMessageLogger extends AbstractLogger {
  AbstractMessageLogger([this.logAlways = false]);

  final bool logAlways;

  @override
  bool checkLogLevel(int level) => logAlways || super.checkLogLevel(level);

  @override
  void trace(String message, [List<Object?> args = const <Object?>[]]) {
    if (canLogLevel(LogLevel.Trace)) {
      log(LogLevel.Trace, format(<Object?>[message, ...args], true));
    }
  }

  @override
  void debug(String message, [List<Object?> args = const <Object?>[]]) {
    if (canLogLevel(LogLevel.Debug)) {
      log(LogLevel.Debug, format(<Object?>[message, ...args]));
    }
  }

  @override
  void info(String message, [List<Object?> args = const <Object?>[]]) {
    if (canLogLevel(LogLevel.Info)) {
      log(LogLevel.Info, format(<Object?>[message, ...args]));
    }
  }

  @override
  void warn(Object message, [List<Object?> args = const <Object?>[]]) {
    if (canLogLevel(LogLevel.Warning)) {
      log(LogLevel.Warning, format(<Object?>[message, ...args]));
    }
  }

  @override
  void error(Object message, [List<Object?> args = const <Object?>[]]) {
    if (canLogLevel(LogLevel.Error)) {
      if (message is Error && message.stackTrace != StackTrace.empty) {
        log(LogLevel.Error,
            format(<Object?>[message.stackTrace.toString(), ...args]));
      } else {
        log(LogLevel.Error, format(<Object?>[message, ...args]));
      }
    }
  }

  @override
  void flush() {}

  /// 1:1: `protected abstract log(level, message)`.
  void log(int level, String message);
}

// ---------------------------------------------------------------------------
// Console loggers
// ---------------------------------------------------------------------------

/// Console sink carrier; defaults to `dart:core` print-style callbacks.
class ConsoleApi {
  ConsoleApi({
    required this.debug,
    required this.error,
    required this.info,
    required this.log,
    required this.warn,
  });

  final void Function(List<Object?> args) debug;
  final void Function(List<Object?> args) error;
  final void Function(List<Object?> args) info;
  final void Function(List<Object?> args) log;
  final void Function(List<Object?> args) warn;
}

ConsoleApi? consoleProvider;

bool _isConsoleForwarding = false;
// ignore: unused_element
bool _isLogServiceConsoleEcho = false;

void _logToConsole(String method, List<Object?> args) {
  if (_isConsoleForwarding) {
    return;
  }
  _isLogServiceConsoleEcho = true;
  try {
    final ConsoleApi api = consoleProvider ?? _defaultConsoleApi;
    switch (method) {
      case 'debug':
        api.debug(args);
        break;
      case 'error':
        api.error(args);
        break;
      case 'info':
        api.info(args);
        break;
      case 'warn':
        api.warn(args);
        break;
      case 'log':
      default:
        api.log(args);
        break;
    }
  } finally {
    _isLogServiceConsoleEcho = false;
  }
}

final ConsoleApi _defaultConsoleApi = ConsoleApi(
  debug: (List<Object?> args) => print(args.join(' ')),
  error: (List<Object?> args) => print(args.join(' ')),
  info: (List<Object?> args) => print(args.join(' ')),
  log: (List<Object?> args) => print(args.join(' ')),
  warn: (List<Object?> args) => print(args.join(' ')),
);

/// 1:1: `registerDevConsoleLogForwarder(logService)`.
/// Console interception is expressed via the injectable [consoleProvider]: the
/// returned disposable restores the original provider.
lifecycle.IDisposable registerDevConsoleLogForwarder(ILogServiceType logService) {
  final ConsoleApi original = consoleProvider ?? _defaultConsoleApi;

  void forward(String method, int level, List<Object?> args) {
    if (!_isLogServiceConsoleEcho) {
      _isConsoleForwarding = true;
      try {
        log(logService, level, format(args));
      } catch (_) {
        // Best-effort development logging must not break console semantics.
      } finally {
        _isConsoleForwarding = false;
      }
    }
    switch (method) {
      case 'debug':
        original.debug(args);
        break;
      case 'error':
        original.error(args);
        break;
      case 'info':
        original.info(args);
        break;
      case 'warn':
        original.warn(args);
        break;
      case 'log':
      default:
        original.log(args);
        break;
    }
  }

  consoleProvider = ConsoleApi(
    debug: (List<Object?> args) => forward('debug', LogLevel.Debug, args),
    error: (List<Object?> args) => forward('error', LogLevel.Error, args),
    info: (List<Object?> args) => forward('info', LogLevel.Info, args),
    log: (List<Object?> args) => forward('log', LogLevel.Info, args),
    warn: (List<Object?> args) => forward('warn', LogLevel.Warning, args),
  );

  return lifecycle.toDisposable(() {
    consoleProvider = original;
  });
}

/// 1:1: `class ConsoleMainLogger extends AbstractLogger`.
class ConsoleMainLogger extends AbstractLogger {
  ConsoleMainLogger([int logLevel = DEFAULT_LOG_LEVEL])
      : useColors = !platform.isWindows {
    setLevel(logLevel);
  }

  bool useColors;

  String _prefix() => useColors
      ? '\x1b[90m[main ${now()}]\x1b[0m'
      : '[main ${now()}]';

  @override
  void trace(String message, [List<Object?> args = const <Object?>[]]) {
    if (canLogLevel(LogLevel.Trace)) {
      _logToConsole('log', <Object?>[_prefix(), message, ...args]);
    }
  }

  @override
  void debug(String message, [List<Object?> args = const <Object?>[]]) {
    if (canLogLevel(LogLevel.Debug)) {
      _logToConsole('log', <Object?>[_prefix(), message, ...args]);
    }
  }

  @override
  void info(String message, [List<Object?> args = const <Object?>[]]) {
    if (canLogLevel(LogLevel.Info)) {
      _logToConsole('log', <Object?>[_prefix(), message, ...args]);
    }
  }

  @override
  void warn(Object message, [List<Object?> args = const <Object?>[]]) {
    if (canLogLevel(LogLevel.Warning)) {
      _logToConsole('warn', <Object?>[
        useColors ? '\x1b[93m[main ${now()}]\x1b[0m' : '[main ${now()}]',
        message,
        ...args
      ]);
    }
  }

  @override
  void error(Object message, [List<Object?> args = const <Object?>[]]) {
    if (canLogLevel(LogLevel.Error)) {
      _logToConsole('error', <Object?>[
        useColors ? '\x1b[91m[main ${now()}]\x1b[0m' : '[main ${now()}]',
        message,
        ...args
      ]);
    }
  }

  @override
  void flush() {}
}

/// 1:1: `class ConsoleLogger extends AbstractLogger`.
class ConsoleLogger extends AbstractLogger {
  ConsoleLogger([int logLevel = DEFAULT_LOG_LEVEL, this.useColors = true]) {
    setLevel(logLevel);
  }

  final bool useColors;

  @override
  void trace(String message, [List<Object?> args = const <Object?>[]]) {
    if (canLogLevel(LogLevel.Trace)) {
      _logToConsole('log', useColors
          ? <Object?>['%cTRACE', 'color: #888', message, ...args]
          : <Object?>[message, ...args]);
    }
  }

  @override
  void debug(String message, [List<Object?> args = const <Object?>[]]) {
    if (canLogLevel(LogLevel.Debug)) {
      _logToConsole('log', useColors
          ? <Object?>['%cDEBUG', 'background: #eee; color: #888', message, ...args]
          : <Object?>[message, ...args]);
    }
  }

  @override
  void info(String message, [List<Object?> args = const <Object?>[]]) {
    if (canLogLevel(LogLevel.Info)) {
      _logToConsole('log', useColors
          ? <Object?>['%c INFO', 'color: #33f', message, ...args]
          : <Object?>[message, ...args]);
    }
  }

  @override
  void warn(Object message, [List<Object?> args = const <Object?>[]]) {
    if (canLogLevel(LogLevel.Warning)) {
      _logToConsole(useColors ? 'warn' : 'log', useColors
          ? <Object?>['%c WARN', 'color: #993', message, ...args]
          : <Object?>[message, ...args]);
    }
  }

  @override
  void error(Object message, [List<Object?> args = const <Object?>[]]) {
    if (canLogLevel(LogLevel.Error)) {
      _logToConsole('error', useColors
          ? <Object?>['%c  ERR', 'color: #f33', message, ...args]
          : <Object?>[message, ...args]);
    }
  }

  @override
  void flush() {}
}

/// 1:1: `class AdapterLogger extends AbstractLogger`.
class AdapterLogger extends AbstractLogger {
  AdapterLogger(this.adapter, [int logLevel = DEFAULT_LOG_LEVEL]) {
    setLevel(logLevel);
  }

  final void Function(int level, List<Object?> args) adapter;

  String _extractMessage(Object msg) {
    if (msg is String) return msg;
    return error_message.toErrorMessage(msg, canLogLevel(LogLevel.Trace));
  }

  @override
  void trace(String message, [List<Object?> args = const <Object?>[]]) {
    if (canLogLevel(LogLevel.Trace)) {
      adapter(LogLevel.Trace, <Object?>[_extractMessage(message), ...args]);
    }
  }

  @override
  void debug(String message, [List<Object?> args = const <Object?>[]]) {
    if (canLogLevel(LogLevel.Debug)) {
      adapter(LogLevel.Debug, <Object?>[_extractMessage(message), ...args]);
    }
  }

  @override
  void info(String message, [List<Object?> args = const <Object?>[]]) {
    if (canLogLevel(LogLevel.Info)) {
      adapter(LogLevel.Info, <Object?>[_extractMessage(message), ...args]);
    }
  }

  @override
  void warn(Object message, [List<Object?> args = const <Object?>[]]) {
    if (canLogLevel(LogLevel.Warning)) {
      adapter(LogLevel.Warning, <Object?>[_extractMessage(message), ...args]);
    }
  }

  @override
  void error(Object message, [List<Object?> args = const <Object?>[]]) {
    if (canLogLevel(LogLevel.Error)) {
      adapter(LogLevel.Error, <Object?>[
        error_message.toErrorMessage(message, true),
        ...args
      ]);
    }
  }

  @override
  void flush() {}
}

/// 1:1: `class MultiplexLogger extends AbstractLogger`.
class MultiplexLogger extends AbstractLogger {
  MultiplexLogger(this.loggers) {
    if (loggers.isNotEmpty) {
      setLevel(loggers.first.getLevel());
    }
  }

  final List<ILogger> loggers;

  @override
  void setLevel(int level) {
    for (final ILogger logger in loggers) {
      logger.setLevel(level);
    }
    super.setLevel(level);
  }

  @override
  void trace(String message, [List<Object?> args = const <Object?>[]]) {
    for (final ILogger logger in loggers) {
      logger.trace(message, args);
    }
  }

  @override
  void debug(String message, [List<Object?> args = const <Object?>[]]) {
    for (final ILogger logger in loggers) {
      logger.debug(message, args);
    }
  }

  @override
  void info(String message, [List<Object?> args = const <Object?>[]]) {
    for (final ILogger logger in loggers) {
      logger.info(message, args);
    }
  }

  @override
  void warn(Object message, [List<Object?> args = const <Object?>[]]) {
    for (final ILogger logger in loggers) {
      logger.warn(message, args);
    }
  }

  @override
  void error(Object message, [List<Object?> args = const <Object?>[]]) {
    for (final ILogger logger in loggers) {
      logger.error(message, args);
    }
  }

  @override
  void flush() {
    for (final ILogger logger in loggers) {
      logger.flush();
    }
  }

  @override
  void dispose() {
    for (final ILogger logger in loggers) {
      logger.dispose();
    }
    super.dispose();
  }
}

// ---------------------------------------------------------------------------
// AbstractLoggerService
// ---------------------------------------------------------------------------

/// 1:1: `type LoggerEntry`.
class LoggerEntry {
  LoggerEntry({this.logger, required this.info});
  ILogger? logger;
  final ILoggerResource info;
}

/// 1:1: `abstract class AbstractLoggerService extends Disposable`.
abstract class AbstractLoggerService extends lifecycle.Disposable
    implements ILoggerServiceType {
  // ignore: unused_element
  Object? get _serviceBrand => null;

  AbstractLoggerService(this.logLevel, this.logsHome, [Iterable<ILoggerResource>? loggerResources]) {
    if (loggerResources != null) {
      for (final ILoggerResource r in loggerResources) {
        _loggers.set(r.resource, LoggerEntry(logger: null, info: r));
      }
    }
  }

  int logLevel;
  final uri.URI logsHome;

  final mapLib.ResourceMap<LoggerEntry> _loggers =
      mapLib.ResourceMap<LoggerEntry>();

  final events.Emitter<DidChangeLoggersEvent> _onDidChangeLoggers =
      events.Emitter<DidChangeLoggersEvent>();
  @override
  events.Event<DidChangeLoggersEvent> get onDidChangeLoggers =>
      _onDidChangeLoggers.event;

  final events.Emitter<Object> _onDidChangeLogLevel = events.Emitter<Object>();
  @override
  events.Event<Object> get onDidChangeLogLevel => _onDidChangeLogLevel.event;

  final events.Emitter<List<Object>> _onDidChangeVisibility =
      events.Emitter<List<Object>>();
  @override
  events.Event<List<Object>> get onDidChangeVisibility =>
      _onDidChangeVisibility.event;

  LoggerEntry? _getLoggerEntry(Object resourceOrId) {
    if (resourceOrId is String) {
      for (final LoggerEntry entry in _loggers.values()) {
        if (entry.info.id == resourceOrId) {
          return entry;
        }
      }
      return null;
    }
    return _loggers.get(resourceOrId as uri.URI);
  }

  @override
  ILogger? getLogger(Object resourceOrId) =>
      _getLoggerEntry(resourceOrId)?.logger;

  @override
  ILogger createLogger(Object idOrResource, [ILoggerOptions? options]) {
    final uri.URI resource = toResource(idOrResource);
    final String id = idOrResource is String
        ? idOrResource
        : (options?.id ?? hashLib.hash(resource.toString()).toRadixString(16));
    ILogger? logger = _loggers.get(resource)?.logger;
    final Object? levelOpt = options?.logLevel;
    final int? logLevelOpt =
        levelOpt == 'always' ? LogLevel.Trace : (levelOpt as int?);
    if (logger == null) {
      logger = doCreateLogger(
        resource,
        logLevelOpt ?? getLogLevel(resource),
        ILoggerOptions(
          id: id,
          name: options?.name,
          donotRotate: options?.donotRotate,
          donotUseFormatters: options?.donotUseFormatters,
          logLevel: options?.logLevel,
          hidden: options?.hidden,
          when: options?.when,
          extensionId: options?.extensionId,
          group: options?.group,
        ),
      );
    }
    final LoggerEntry loggerEntry = LoggerEntry(
      logger: logger,
      info: ILoggerResource(
        resource: resource,
        id: id,
        logLevel: logLevelOpt,
        name: options?.name,
        hidden: options?.hidden,
        group: options?.group,
        extensionId: options?.extensionId,
        when: options?.when,
      ),
    );
    registerLogger(loggerEntry.info);
    _loggers.set(resource, loggerEntry);
    return logger;
  }

  /// 1:1: `protected toResource(idOrResource)`.
  uri.URI toResource(Object idOrResource) {
    if (idOrResource is String) {
      final String cleaned =
          idOrResource.replaceAll(RegExp(r'[\\/:\*\?"<>\|]'), '');
      return resources.joinPath(logsHome, <String>['$cleaned.log']);
    }
    return idOrResource as uri.URI;
  }

  @override
  void setLogLevel(Object arg1, [int? arg2]) {
    if (arg1 is uri.URI) {
      final uri.URI resource = arg1;
      final int logLevelValue = arg2!;
      final LoggerEntry? logger = _loggers.get(resource);
      if (logger != null && logLevelValue != logger.info.logLevel) {
        logger.info.logLevel =
            logLevelValue == this.logLevel ? null : logLevelValue;
        logger.logger?.setLevel(logLevelValue);
        _loggers.set(logger.info.resource, logger);
        _onDidChangeLogLevel.fire(<Object>[resource, logLevelValue]);
      }
    } else {
      logLevel = arg1 as int;
      for (final LoggerEntry logger in _loggers.values()) {
        if (_loggers.get(logger.info.resource)?.info.logLevel == null) {
          logger.logger?.setLevel(logLevel);
        }
      }
      _onDidChangeLogLevel.fire(logLevel);
    }
  }

  @override
  void setVisibility(Object resourceOrId, bool visible) {
    final LoggerEntry? logger = _getLoggerEntry(resourceOrId);
    if (logger != null && visible != !(logger.info.hidden ?? false)) {
      logger.info.hidden = !visible;
      _loggers.set(logger.info.resource, logger);
      _onDidChangeVisibility.fire(<Object>[logger.info.resource, visible]);
    }
  }

  @override
  int getLogLevel([uri.URI? resource]) {
    int? logLevelValue;
    if (resource != null) {
      logLevelValue = _loggers.get(resource)?.info.logLevel;
    }
    return logLevelValue ?? logLevel;
  }

  @override
  void registerLogger(ILoggerResource resource) {
    final LoggerEntry? existing = _loggers.get(resource.resource);
    if (existing != null) {
      if (existing.info.hidden != resource.hidden) {
        setVisibility(resource.resource, !(resource.hidden ?? false));
      }
    } else {
      _loggers.set(
          resource.resource, LoggerEntry(logger: null, info: resource));
      _onDidChangeLoggers.fire(
          DidChangeLoggersEvent(added: <ILoggerResource>[resource], removed: const <ILoggerResource>[]));
    }
  }

  @override
  void deregisterLogger(Object idOrResource) {
    final uri.URI resource = toResource(idOrResource);
    final LoggerEntry? existing = _loggers.get(resource);
    if (existing != null) {
      existing.logger?.dispose();
      _loggers.delete(resource);
      _onDidChangeLoggers.fire(DidChangeLoggersEvent(
          added: const <ILoggerResource>[],
          removed: <ILoggerResource>[existing.info]));
    }
  }

  @override
  Iterable<ILoggerResource> getRegisteredLoggers() sync* {
    for (final LoggerEntry entry in _loggers.values()) {
      yield entry.info;
    }
  }

  @override
  ILoggerResource? getRegisteredLogger(uri.URI resource) =>
      _loggers.get(resource)?.info;

  @override
  void dispose() {
    _loggers.forEach((LoggerEntry logger, uri.URI key, _) {
      logger.logger?.dispose();
    });
    _loggers.clear();
    super.dispose();
  }

  /// 1:1: `protected abstract doCreateLogger(...)`.
  ILogger doCreateLogger(uri.URI resource, int level, [ILoggerOptions? options]);
}

// ---------------------------------------------------------------------------
// Null loggers
// ---------------------------------------------------------------------------

/// 1:1: `class NullLogger implements ILogger`.
class NullLogger implements ILogger {
  @override
  events.Event<int> get onDidChangeLogLevel => events.eventNone;

  @override
  void setLevel(int level) {}

  @override
  int getLevel() => LogLevel.Info;

  @override
  void trace(String message, [List<Object?> args = const <Object?>[]]) {}
  @override
  void debug(String message, [List<Object?> args = const <Object?>[]]) {}
  @override
  void info(String message, [List<Object?> args = const <Object?>[]]) {}
  @override
  void warn(Object message, [List<Object?> args = const <Object?>[]]) {}
  @override
  void error(Object message, [List<Object?> args = const <Object?>[]]) {}
  void critical(Object message, [List<Object?> args = const <Object?>[]]) {}
  @override
  void dispose() {}
  @override
  void flush() {}
}

/// 1:1: `class NullLogService extends NullLogger implements ILogService`.
class NullLogService extends NullLogger implements ILogServiceType {
  // ignore: unused_element
  Object? get _serviceBrand => null;
}

/// 1:1: `class NullLoggerService extends AbstractLoggerService`.
class NullLoggerService extends AbstractLoggerService {
  NullLoggerService()
      : super(LogLevel.Off, uri.URI.parse('log:///log'));

  @override
  ILogger doCreateLogger(uri.URI resource, int level, [ILoggerOptions? options]) =>
      NullLogger();
}

// ---------------------------------------------------------------------------
// Level helpers
// ---------------------------------------------------------------------------

/// 1:1: `getLogLevel(environmentService)`.
int getLogLevel(environment.IEnvironmentServiceType environmentService) {
  if (environmentService.verbose) {
    return LogLevel.Trace;
  }
  final Object? ll = environmentService.logLevel;
  if (ll is String) {
    final int? level = parseLogLevel(ll.toLowerCase());
    if (level != null) {
      return level;
    }
  }
  return DEFAULT_LOG_LEVEL;
}

/// 1:1: `LogLevelToString(logLevel)`.
String LogLevelToString(int logLevel) {
  switch (logLevel) {
    case LogLevel.Trace:
      return 'trace';
    case LogLevel.Debug:
      return 'debug';
    case LogLevel.Info:
      return 'info';
    case LogLevel.Warning:
      return 'warn';
    case LogLevel.Error:
      return 'error';
    case LogLevel.Off:
      return 'off';
    default:
      return '';
  }
}

/// 1:1: `LogLevelToLocalizedString(logLevel)`.
ILocalizedString LogLevelToLocalizedString(int logLevel) {
  switch (logLevel) {
    case LogLevel.Trace:
      return ILocalizedString(
          original: 'Trace', value: nls.localize('trace', 'Trace'));
    case LogLevel.Debug:
      return ILocalizedString(
          original: 'Debug', value: nls.localize('debug', 'Debug'));
    case LogLevel.Info:
      return ILocalizedString(
          original: 'Info', value: nls.localize('info', 'Info'));
    case LogLevel.Warning:
      return ILocalizedString(
          original: 'Warning', value: nls.localize('warn', 'Warning'));
    case LogLevel.Error:
      return ILocalizedString(
          original: 'Error', value: nls.localize('error', 'Error'));
    case LogLevel.Off:
      return ILocalizedString(
          original: 'Off', value: nls.localize('off', 'Off'));
    default:
      return ILocalizedString(original: '', value: '');
  }
}

/// 1:1: `parseLogLevel(logLevel)`.
int? parseLogLevel(String logLevel) {
  switch (logLevel) {
    case 'trace':
      return LogLevel.Trace;
    case 'debug':
      return LogLevel.Debug;
    case 'info':
      return LogLevel.Info;
    case 'warn':
      return LogLevel.Warning;
    case 'error':
      return LogLevel.Error;
    case 'critical':
      return LogLevel.Error;
    case 'off':
      return LogLevel.Off;
  }
  return null;
}

/// 1:1: `CONTEXT_LOG_LEVEL`.
final contextkey.RawContextKey<String> CONTEXT_LOG_LEVEL =
    contextkey.RawContextKey<String>('logLevel', LogLevelToString(LogLevel.Info));
