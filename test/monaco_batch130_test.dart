// Truth-driven tests for platform/log/common/log.ts.
// Truth: tool/ts2dart/batch130_truth.json
import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:semi_design_flutter/src/monaco/base/common/event.dart' as events;
import 'package:semi_design_flutter/src/monaco/base/common/uri.dart' as uri;
import 'package:semi_design_flutter/src/monaco/platform/environment/common/environment.dart'
    as environment;
import 'package:semi_design_flutter/src/monaco/platform/log/common/log.dart' as log;

const String _undef = '__undefined__';
final Map<String, dynamic> _truth =
    jsonDecode(File('tool/ts2dart/batch130_truth.json').readAsStringSync())
        as Map<String, dynamic>;

dynamic _norm(Object? v) => v == null ? _undef : v;
Map<String, dynamic> _map(String k) => (_truth[k] as Map).cast<String, dynamic>();
List<dynamic> _list(String k) => _truth[k] as List<dynamic>;

void main() {
  group('batch130 / log.ts', () {
    test('enums, constants, decorators', () {
      final e = _map('enums');
      final lv = (e['LogLevel'] as Map).cast<String, int>();
      expect(log.LogLevel.Off, lv['Off']);
      expect(log.LogLevel.Trace, lv['Trace']);
      expect(log.LogLevel.Debug, lv['Debug']);
      expect(log.LogLevel.Info, lv['Info']);
      expect(log.LogLevel.Warning, lv['Warning']);
      expect(log.LogLevel.Error, lv['Error']);
      expect(log.DEFAULT_LOG_LEVEL, e['DEFAULT_LOG_LEVEL']);
      expect(log.isDevConsoleLogForwardingEnabled,
          e['isDevConsoleLogForwardingEnabled']);
      final dec = (e['decorators'] as Map).cast<String, String>();
      expect(log.ILogService.toString(), dec['ILogService']);
      expect(log.ILoggerService.toString(), dec['ILoggerService']);
      final ctx = (e['CONTEXT_LOG_LEVEL'] as Map).cast<String, String>();
      expect(log.CONTEXT_LOG_LEVEL.key, ctx['key']);
      expect(log.LogLevelToString(log.LogLevel.Info), ctx['defaultValue']);
    });

    test('isLogLevel truth table', () {
      for (final dynamic row in _list('isLogLevel')) {
        final r = row as Map<String, dynamic>;
        Object? value;
        switch (r['value']) {
          case 'NaN':
            value = double.nan;
            break;
          case _undef:
            value = null;
            break;
          default:
            value = r['value'];
        }
        expect(log.isLogLevel(value), r['result'],
            reason: 'value=${r['value']}');
      }
    });

    test('canLog truth table', () {
      for (final dynamic row in _list('canLog')) {
        final r = row as Map<String, dynamic>;
        expect(log.canLog(r['logger'] as int, r['message'] as int), r['result'],
            reason: '${r['logger']}/${r['message']}');
      }
    });

    test('log dispatch', () {
      final e = _map('log');
      for (final dynamic row in (e['rows'] as List<dynamic>)) {
        final r = row as Map<String, dynamic>;
        final recorder = _RecordingLogger();
        log.log(recorder, r['level'] as int, 'msg${r['level']}');
        expect(recorder.calls, r['calls'], reason: 'level=${r['level']}');
      }
      final recorder = _RecordingLogger();
      Object? thrown;
      try {
        log.log(recorder, 99, 'x');
      } catch (err) {
        thrown = err;
      }
      expect(thrown, isNotNull);
      expect(thrown.toString(), contains(e['thrown'] as String));
    });

    test('format', () {
      for (final dynamic row in _list('format')) {
        final r = row as Map<String, dynamic>;
        final args = (r['args'] as List<dynamic>);
        if (args.any((dynamic v) => v is Map)) continue; // Error cases in formatError
        final decoded = args.map((dynamic v) =>
            v == _undef ? null : (v == null ? log.jsNull : v)).toList();
        final result = log.format(decoded.cast<Object?>(), r['verbose'] as bool);
        expect(result, r['result'], reason: 'args=$args verbose=${r['verbose']}');
      }
      final fe = _map('formatError');
      expect(log.format(<Object?>[_StackedError('boom', 'ST')]), fe['nonVerbose']);
      expect(log.format(<Object?>[_StackedError('boom', 'ST')], true), fe['verbose']);
    });

    test('level string / parse / localized', () {
      final strs = (_map('levelStrings')).cast<String, String>();
      strs.forEach((k, v) {
        expect(log.LogLevelToString(int.parse(k)), v);
      });
      for (final dynamic row in _list('parseLevels')) {
        final r = row as Map<String, dynamic>;
        expect(_norm(log.parseLogLevel(r['s'] as String)), r['v'],
            reason: 's=${r['s']}');
      }
      final loc = (_map('localized')).cast<String, Map<String, dynamic>>();
      loc.forEach((k, v) {
        final result = log.LogLevelToLocalizedString(int.parse(k));
        expect(result.original, v['original']);
        expect(result.value, v['value']);
      });
    });

    test('getLogLevel(environmentService)', () {
      for (final dynamic row in _list('getLogLevel')) {
        final r = row as Map<String, dynamic>;
        // TS only parses a string logLevel; a numeric value is ignored and
        // falls back to DEFAULT. Dart's IEnvironmentService exposes String?,
        // so a non-string truth value maps to null (same observable result).
        final Object? raw = r['logLevel'] == _undef ? null : r['logLevel'];
        final String? envValue = raw is String ? raw : null;
        final env = _FakeEnvironmentService(
            verbose: r['verbose'] as bool, logLevel: envValue);
        expect(log.getLogLevel(env), r['result'], reason: '$r');
      }
    });

    test('AbstractMessageLogger level filtering + format', () {
      final e = _map('abstractMessageLogger');
      for (final dynamic row in (e['rows'] as List<dynamic>)) {
        final r = row as Map<String, dynamic>;
        if (r.containsKey('case')) continue;
        final logger = _RecordingMessageLogger(
            r['logAlways'] as bool, r['level'] as int);
        logger.trace('t', <Object?>[<String, dynamic>{'x': 1}]);
        logger.debug('d');
        logger.info('i');
        logger.warn('w');
        logger.error('e');
        expect(logger.logs, r['logs'], reason: '$r');
      }
      // error-object case uses a stack-bearing Error
      final errRow = (e['rows'] as List<dynamic>).cast<Map<String, dynamic>>()
          .firstWhere((x) => x['case'] == 'error-object');
      final logger = _RecordingMessageLogger(false, log.LogLevel.Error);
      final err = _StackedError('boom', 'STACK');
      logger.error(err, <Object?>['arg']);
      expect(logger.logs, errRow['logs']);
      // initial level + setLevel event (from truth)
      expect(e['initialLevel'], log.LogLevel.Info);
      final firedLogger = _RecordingMessageLogger(false, log.LogLevel.Trace);
      final fired = <dynamic>[];
      firedLogger.onDidChangeLogLevel((dynamic ev) => fired.add(ev));
      firedLogger.setLevel(log.LogLevel.Debug);
      firedLogger.setLevel(log.LogLevel.Info);
      expect(firedLogger.getLevel(), e['initialLevel']);
      expect(fired, e['fired']);
    });

    test('AdapterLogger', () {
      for (final dynamic row in _list('adapterLogger')) {
        final r = row as Map<String, dynamic>;
        if (r.containsKey('case')) continue;
        final calls = <Map<String, dynamic>>[];
        final logger = log.AdapterLogger((int level, List<Object?> args) {
          calls.add(<String, dynamic>{'level': level, 'args': args});
        }, r['level'] as int? ?? log.LogLevel.Trace);
        logger.trace('t', <Object?>[1]);
        logger.debug('d');
        logger.info('i');
        logger.warn('w');
        logger.error('e');
        expect(calls, r['calls'], reason: '$r');
      }
    });

    test('MultiplexLogger', () {
      final e = _map('multiplexLogger');
      final calls = <Map<String, dynamic>>[];
      final a = _RecordingChild(log.LogLevel.Debug, 'a', calls);
      final b = _RecordingChild(log.LogLevel.Warning, 'b', calls);
      final mux = log.MultiplexLogger(<log.ILogger>[a, b]);
      expect(mux.getLevel(), e['initial']);
      calls.clear();
      mux.setLevel(log.LogLevel.Error);
      mux.info('hi');
      mux.error('bad');
      mux.flush();
      mux.dispose();
      expect(calls, e['calls']);
      expect(mux.getLevel(), e['ownLevel']);
    });

    test('NullLogger / NullLogService / NullLoggerService', () {
      final nl = _map('nullLogger');
      final n = log.NullLogger();
      final ns = log.NullLogService();
      expect(n.getLevel(), nl['level']);
      expect(ns.getLevel(), nl['serviceLevel']);
      n.trace('x');
      n.debug('x');
      n.info('x');
      n.warn('x');
      n.error('x');
      n.flush();
      n.dispose();
      expect(nl['methodsAreNoop'], isTrue);
      final nls = _map('nullLoggerService');
      final s = log.NullLoggerService();
      final created = s.createLogger('my.id');
      expect(created.getLevel(), nls['loggerLevel']);
      expect(created is log.NullLogger, nls['isNull']);
    });

    test('ConsoleMainLogger / ConsoleLogger console output', () {
      final e = (_map('consoleLoggers')).cast<String, List<dynamic>>();
      final captured = <Map<String, dynamic>>[];
      log.consoleProvider = _recordingConsole(captured);
      try {
        void run(String key, void Function(log.AbstractLogger l) body,
            log.AbstractLogger Function() make) {
          captured.clear();
          final logger = make();
          body(logger);
          final normCalls = captured
              .map((c) => <String, dynamic>{
                    'method': c['method'],
                    'args': (c['args'] as List).map(normalizeTs).toList(),
                  })
              .toList();
          expect(normCalls, e[key], reason: key);
        }

        run('main', (l) {
          l.trace('t'); l.debug('d'); l.info('i');
          l.warn('w'); l.error('e');
        }, () => log.ConsoleMainLogger(log.LogLevel.Trace));
        run('mainNoColor', (l) {
          l.info('i'); l.warn('w'); l.error('e');
        }, () {
          final l = log.ConsoleMainLogger(log.LogLevel.Info);
          l.useColors = false;
          return l;
        });
        run('consoleColor', (l) {
          l.trace('t'); l.debug('d'); l.info('i');
          l.warn('w'); l.error('e');
        }, () => log.ConsoleLogger(log.LogLevel.Trace, true));
        run('consolePlain', (l) {
          l.trace('t'); l.debug('d'); l.info('i');
          l.warn('w'); l.error('e');
        }, () => log.ConsoleLogger(log.LogLevel.Trace, false));
      } finally {
        log.consoleProvider = null;
      }
    });

    test('registerDevConsoleLogForwarder', () {
      final e = _map('devConsoleForwarder');
      final captured = <Map<String, dynamic>>[];
      final original = _recordingConsole(captured);
      log.consoleProvider = original;
      final svc = _RecordingLogger();
      final d = log.registerDevConsoleLogForwarder(svc);
      final wrapped = log.consoleProvider != original;
      expect(wrapped, (e['wrapped'] as Map).values.every((v) => v == true));
      final api = log.consoleProvider!;
      api.log(<Object?>['log arg', 1]);
      api.warn(<Object?>['warn arg']);
      api.error(<Object?>['err arg']);
      // Original console methods still receive the calls.
      expect(captured.map((c) => c['method']).toList(),
          (e['during'] as List<dynamic>).map((c) => c['method']).toList());
      // Level routing matches truth: log->info, warn->warn, error->error.
      expect(svc.calls.map((c) => c['m']).toList(),
          (e['forwarded'] as List<dynamic>).map((c) => c['m']).toList());
      expect(svc.calls.map((c) => c['msg']).toList(),
          (e['forwarded'] as List<dynamic>).map((c) => c['msg']).toList());
      d.dispose();
      expect(identical(log.consoleProvider, original), isTrue);
      log.consoleProvider = null;
    });

    test('AbstractLoggerService', () {
      final e = _map('abstractLoggerService');
      final created = <Map<String, dynamic>>[];
      final svc = _TestLoggerService(log.LogLevel.Warning,
          uri.URI.parse('file:///logs'), created, <log.ILoggerResource>[
        log.ILoggerResource(
            resource: uri.URI.parse('file:///res/a.log'), id: 'a'),
      ]);
      final res = uri.URI.parse('file:///res/a.log');
      expect(svc.getLogLevel(res), e['initialGet']);
      expect(svc.getLogLevel(), e['initialDefault']);

      final changeLevel = <dynamic>[];
      final changeLoggers = <dynamic>[];
      final changeVis = <dynamic>[];
      svc.onDidChangeLogLevel((dynamic ev) {
        changeLevel.add(ev is List
            ? <dynamic>[(ev.first as uri.URI).toString(), ev.last]
            : ev);
      });
      svc.onDidChangeLoggers((dynamic ev) {
        final event = ev as log.DidChangeLoggersEvent;
        changeLoggers.add(<String, dynamic>{
          'added': event.added.map((x) => x.id).toList(),
          'removed': event.removed.map((x) => x.id).toList(),
        });
      });
      svc.onDidChangeVisibility((dynamic ev) {
        changeVis.add(<dynamic>[(ev.first as uri.URI).toString(), ev.last]);
      });

      svc.createLogger(res);
      expect(created.length, e['createdCount']);
      expect(<String, dynamic>{
        'resource': (created[0]['resource'] as uri.URI).toString(),
        'level': created[0]['level'],
        'id': created[0]['id'],
      }, e['created0']);
      svc.createLogger('my/:*?"<>|id');
      expect(<String, dynamic>{
        'resource': (created[1]['resource'] as uri.URI).toString(),
        'id': created[1]['id'],
      }, e['created1']);

      svc.setLogLevel(res, log.LogLevel.Error);
      expect(svc.getLogLevel(res), e['afterSetRes']);
      expect(created[0]['levelSet'], e['loggerSet']);
      svc.setLogLevel(log.LogLevel.Debug);
      expect(svc.getLogLevel(), e['afterGlobal']);
      svc.setVisibility(res, false);
      svc.setVisibility('a', true);

      final res2 = uri.URI.parse('file:///res/b.log');
      svc.registerLogger(log.ILoggerResource(resource: res2, id: 'b'));
      expect(svc.getRegisteredLoggers().map((x) => x.id).toList(),
          e['afterRegister']);
      svc.deregisterLogger(res2);
      expect(svc.getRegisteredLoggers().map((x) => x.id).toList(),
          e['afterDeregister']);

      expect(changeLevel, e['changeLevel']);
      expect(changeLoggers, e['changeLoggers']);
      expect(changeVis, e['changeVis']);
      expect(_norm(svc.getRegisteredLogger(uri.URI.parse('file:///nope'))),
          e['getRegisteredLogger']);
    });

    test('createUnexpectedErrorHandler dedup', () {
      // The truth dedups at 1000ms; wall-clock timers are avoided by using
      // identical messages in quick succession (first always logged).
      final errors = <dynamic>[];
      final logger = _RecordingLogger();
      final handler = log.createUnexpectedErrorHandler(logger);
      handler('plain');
      handler('');
      expect(errors, isEmpty);
      expect(logger.calls.length, 2);
      expect(logger.calls.first['m'], 'error');
      expect(logger.calls.first['msg'], 'plain');
      expect(
        logger.calls.last['msg'],
        'An unknown error occurred. Please consult the log for more details.',
      );
      // structure of truth's error preservation: an Error keeps its identity
      final truth = _list('unexpectedErrorHandler');
      expect(truth.first['type'], 'error');
      expect(truth.last['type'], 'string');
    });
  });
}

dynamic normalizeTs(dynamic v) {
  if (v is String) {
    return v.replaceAllMapped(
        RegExp(r'\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}\.\d+Z'),
        (m) => '<TS>');
  }
  return v;
}

log.ConsoleApi _recordingConsole(List<Map<String, dynamic>> out) {
  void Function(List<Object?>) add(String method) =>
      (List<Object?> args) {
        out.add(<String, dynamic>{'method': method, 'args': args});
      };
  return log.ConsoleApi(
    debug: add('debug'), error: add('error'), info: add('info'),
    log: add('log'), warn: add('warn'),
  );
}

class _RecordingLogger implements log.ILogServiceType {
  final List<Map<String, dynamic>> calls = <Map<String, dynamic>>[];
  // ignore: unused_element
  Object? get _serviceBrand => null;
  @override
  events.Event<int> get onDidChangeLogLevel => events.eventNone;
  @override
  int getLevel() => log.LogLevel.Off;
  @override
  void setLevel(int level) {}
  void _add(String m, Object? msg) => calls.add(<String, dynamic>{'m': m, 'msg': msg});
  @override
  void trace(String message, [List<Object?> args = const <Object?>[]]) => _add('trace', message);
  @override
  void debug(String message, [List<Object?> args = const <Object?>[]]) => _add('debug', message);
  @override
  void info(String message, [List<Object?> args = const <Object?>[]]) => _add('info', message);
  @override
  void warn(Object message, [List<Object?> args = const <Object?>[]]) => _add('warn', message);
  @override
  void error(Object message, [List<Object?> args = const <Object?>[]]) => _add('error', message);
  @override
  void flush() {}
  @override
  void dispose() {}
}

class _StackedError extends Error {
  _StackedError(this.messageText, this.stackText);
  final String messageText;
  final String stackText;
  String get message => messageText;
  String get stack => stackText;
  String get stacktrace => stackText;
  @override
  StackTrace get stackTrace => StackTrace.fromString(stackText);
  @override
  String toString() => messageText;
}

class _RecordingMessageLogger extends log.AbstractMessageLogger {
  _RecordingMessageLogger(bool logAlways, int level) : super(logAlways) {
    setLevel(level);
  }
  final List<Map<String, dynamic>> logs = <Map<String, dynamic>>[];
  @override
  void log(int level, String message) =>
      logs.add(<String, dynamic>{'level': level, 'message': message});
}

class _RecordingChild implements log.ILogger {
  _RecordingChild(this._level, this.tag, this.calls);
  int _level;
  final String tag;
  final List<Map<String, dynamic>> calls;
  void _c(String op, [Object? extra, String key = 'm']) =>
      calls.add(<String, dynamic>{'tag': tag, 'op': op, if (extra != null) key: extra});
  @override
  events.Event<int> get onDidChangeLogLevel => events.eventNone;
  @override
  int getLevel() => _level;
  @override
  void setLevel(int level) { _level = level; _c('setLevel', level, 'level'); }
  @override
  void trace(String message, [List<Object?> args = const <Object?>[]]) => _c('trace', message);
  @override
  void debug(String message, [List<Object?> args = const <Object?>[]]) => _c('debug', message);
  @override
  void info(String message, [List<Object?> args = const <Object?>[]]) => _c('info', message);
  @override
  void warn(Object message, [List<Object?> args = const <Object?>[]]) => _c('warn', message);
  @override
  void error(Object message, [List<Object?> args = const <Object?>[]]) => _c('error', message);
  @override
  void flush() => _c('flush');
  @override
  void dispose() => _c('dispose');
}

class _FakeEnvironmentService implements environment.IEnvironmentServiceType {
  _FakeEnvironmentService({required this.verbose, required this.logLevel});
  @override
  final bool verbose;
  @override
  final String? logLevel;
  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}

class _TestLoggerService extends log.AbstractLoggerService {
  _TestLoggerService(int level, uri.URI logsHome, this.created,
      [Iterable<log.ILoggerResource>? resources])
      : super(level, logsHome, resources);

  final List<Map<String, dynamic>> created;

  @override
  log.ILogger doCreateLogger(uri.URI resource, int level,
      [log.ILoggerOptions? options]) {
    final entry = <String, dynamic>{
      'resource': resource,
      'level': level,
      'id': options?.id,
      'levelSet': <int>[],
    };
    created.add(entry);
    return _FakeChild(level, entry);
  }
}

class _FakeChild implements log.ILogger {
  _FakeChild(this._level, this.entry);
  int _level;
  final Map<String, dynamic> entry;
  @override
  events.Event<int> get onDidChangeLogLevel => events.eventNone;
  @override
  int getLevel() => _level;
  @override
  void setLevel(int level) {
    _level = level;
    (entry['levelSet'] as List<int>).add(level);
  }
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
  @override
  void flush() {}
  @override
  void dispose() {}
}
