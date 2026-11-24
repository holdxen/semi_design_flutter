// Truth-driven tests for platform/log/common/logService.ts.
// Truth: tool/ts2dart/batch131_truth.json
import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:semi_design_flutter/src/monaco/base/common/event.dart' as events;
import 'package:semi_design_flutter/src/monaco/base/common/lifecycle.dart' as lifecycle;
import 'package:semi_design_flutter/src/monaco/platform/log/common/log.dart' as log;
import 'package:semi_design_flutter/src/monaco/platform/log/common/logService.dart'
    as service;

final Map<String, dynamic> _truth =
    jsonDecode(File('tool/ts2dart/batch131_truth.json').readAsStringSync())
        as Map<String, dynamic>;

void main() {
  group('batch131 / logService.ts', () {
    test('constructor delegates levels to all loggers', () {
      final e = (_truth['initial'] as Map).cast<String, dynamic>();
      final calls = <Map<String, dynamic>>[];
      final primary = _Recorder('primary', log.LogLevel.Warning, calls);
      final other = _Recorder('other', log.LogLevel.Debug, calls);
      final svc = service.LogService(primary, <log.ILogger>[other]);
      expect(svc.getLevel(), e['level']);
      expect(calls, e['calls']);
    });

    test('method delegation', () {
      final calls = <Map<String, dynamic>>[];
      final primary = _Recorder('primary', log.LogLevel.Warning, calls);
      final other = _Recorder('other', log.LogLevel.Debug, calls);
      final svc = service.LogService(primary, <log.ILogger>[other]);
      calls.clear();
      svc.trace('t');
      svc.debug('d');
      svc.info('i');
      svc.warn('w');
      svc.error('e');
      svc.flush();
      expect(calls, _truth['delegation']);
    });

    test('setLevel propagates to all', () {
      final e = (_truth['setLevel'] as Map).cast<String, dynamic>();
      final calls = <Map<String, dynamic>>[];
      final primary = _Recorder('primary', log.LogLevel.Warning, calls);
      final other = _Recorder('other', log.LogLevel.Debug, calls);
      final svc = service.LogService(primary, <log.ILogger>[other]);
      calls.clear();
      svc.setLevel(log.LogLevel.Error);
      expect(svc.getLevel(), e['level']);
      expect(calls, e['calls']);
    });

    test('onDidChangeLogLevel fires on setLevel', () {
      final e = (_truth['events'] as Map).cast<String, dynamic>();
      final calls = <Map<String, dynamic>>[];
      final primary = _Recorder('primary', log.LogLevel.Warning, calls);
      final svc = service.LogService(primary);
      final fired = <int>[];
      svc.onDidChangeLogLevel((dynamic level) => fired.add(level as int));
      svc.setLevel(log.LogLevel.Info);
      expect(fired, e['fired']);
    });

    test('default otherLoggers', () {
      final calls = <Map<String, dynamic>>[];
      final primary = _Recorder('p2', log.LogLevel.Debug, calls);
      final svc = service.LogService(primary);
      expect(svc.getLevel(), _truth['single']);
    });
  });
}

class _Recorder implements log.ILogger {
  _Recorder(this.tag, int level, this.calls) : _level = level;

  final String tag;
  int _level;
  final List<Map<String, dynamic>> calls;

  void _c(String op, [Object? extra]) => calls.add(<String, dynamic>{
        'tag': tag,
        'op': op,
        if (extra != null) (op == 'setLevel' ? 'level' : 'm'): extra,
      });

  @override
  events.Event<int> get onDidChangeLogLevel {
    return (dynamic listener, [dynamic thisArgs, dynamic disposables]) {
      calls.add(<String, dynamic>{'tag': tag, 'op': 'listen'});
      return lifecycle.Disposable.none;
    };
  }

  @override
  int getLevel() => _level;

  @override
  void setLevel(int level) {
    _level = level;
    _c('setLevel', level);
  }

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
