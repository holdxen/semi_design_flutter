// ---------------------------------------------------------------------------
// Port of vscode/src/vs/base/common/observableInternal/logging/consoleObservableLogger.ts
// Translated 1:1. JS console.log with %c styling is mapped to a structured
// `ConsoleLine` (format string + styles + data), captured via `consoleLog`
// so tests (and hosts) can observe what would be printed.
// `ConsoleText` union -> a sealed-ish Object? tree of List / _Styled / _Data.
// ---------------------------------------------------------------------------

import '../base.dart' show IObservableWithChange;
import '../debugLocation.dart' show DebugLocation;
import '../debugName.dart' show getClassName;
import '../observables/derivedImpl.dart' show Derived;
import '../observables/observableFromEvent.dart' show FromEventObservable;
import '../reactions/autorunImpl.dart' show AutorunObserver;
import '../transaction.dart' show TransactionImpl;
import 'logging.dart'
    show IChangeInformation, IObservableLogger, addLogger;

/// Captured console line: [format] contains `%c` markers, [styles] supplies
/// the CSS strings, [data] the extra inspected values.
class ConsoleLine {
  ConsoleLine(this.format, this.styles, this.data);
  final String format;
  final List<String> styles;
  final List<Object?> data;

  /// The truth script serializes each argument; strings verbatim, others via
  /// JSON.stringify. Mirror that for data-driven comparison.
  List<Object?> toArgs() => <Object?>[format, ...styles, ...data];
}

/// Injectable `console.log`. Defaults to capturing into [_captured]; the test
/// overrides it to collect lines. Mirrors the source's global `console.log`.
void Function(Object? format, List<Object?> rest) consoleLog =
    (Object? format, List<Object?> rest) {};

ConsoleObservableLogger? _consoleObservableLogger;

/// 1:1: `logObservableToConsole`
void logObservableToConsole(IObservableWithChange<Object?, Object?> obs) {
  final current = _consoleObservableLogger;
  if (current == null) {
    final logger = ConsoleObservableLogger();
    _consoleObservableLogger = logger;
    addLogger(logger);
  }
  _consoleObservableLogger!.addFilteredObj(obs);
}

/// 1:1: `class ConsoleObservableLogger implements IObservableLogger`
class ConsoleObservableLogger implements IObservableLogger {
  ConsoleObservableLogger();

  int indentation = 0;
  Set<Object?>? _filteredObjects;
  final Map<Object, Set<Object>> changedObservablesSets =
      <Object, Set<Object>>{};

  /// 1:1: `addFilteredObj`
  void addFilteredObj(Object obj) {
    final filtered = _filteredObjects;
    if (filtered == null) {
      final set = <Object?>{};
      _filteredObjects = set;
      set.add(obj);
    } else {
      filtered.add(obj);
    }
  }

  bool _isIncluded(Object obj) => _filteredObjects?.contains(obj) ?? true;

  List<Object?> _textToConsoleArgs(Object? text) =>
      consoleTextToArgs(<Object?>[
        normalText(repeat('|  ', indentation)),
        text,
      ]);

  List<Object?> _formatInfo(IChangeInformation info) {
    if (!info.hadValue) {
      return <Object?>[
        normalText(' '),
        styled(formatValue(info.newValue, 60), <String, String>{'color': 'green'}),
        normalText(' (initial)'),
      ];
    }
    return info.didChange
        ? <Object?>[
            normalText(' '),
            styled(formatValue(info.oldValue, 70), <String, String>{
              'color': 'red',
              'text-decoration': 'line-through'
            }),
            normalText(' '),
            styled(formatValue(info.newValue, 60), <String, String>{'color': 'green'}),
          ]
        : <Object?>[normalText(' (unchanged)')];
  }

  @override
  void handleObservableCreated(
    IObservableWithChange<Object?, Object?> observable,
    DebugLocation? location,
  ) {
    if (observable is Derived) {
      changedObservablesSets[observable] = <Object>{};
      // 1:1: `const debugTrackUpdating = false` — inert branch omitted.
    }
  }

  @override
  void handleOnListenerCountChanged(
    IObservableWithChange<Object?, Object?> observable,
    int newCount,
  ) {}

  @override
  void handleObservableUpdated(
    IObservableWithChange<Object?, Object?> observable,
    IChangeInformation info,
  ) {
    if (!_isIncluded(observable)) return;
    if (observable is Derived) {
      _handleDerivedRecomputed(observable, info);
      return;
    }
    _emit(<Object?>[
      formatKind('observable value changed'),
      styled(observable.debugName, <String, String>{'color': 'BlueViolet'}),
      ..._formatInfo(info),
    ]);
  }

  /// 1:1: `formatChanges`
  Object? formatChanges(Set<Object> changes) {
    if (changes.isEmpty) return null;
    final names = changes.map((o) => _debugNameOf(o)).join(', ');
    return styled(' (changed deps: $names)', <String, String>{'color': 'gray'});
  }

  @override
  void handleDerivedDependencyChanged(
    Object derived,
    IObservableWithChange<Object?, Object?> observable,
    Object? change,
  ) {
    if (!_isIncluded(derived as Object)) return;
    changedObservablesSets[derived]?.add(observable);
  }

  void _handleDerivedRecomputed(Derived derived, IChangeInformation info) {
    if (!_isIncluded(derived)) return;
    final changed = changedObservablesSets[derived];
    if (changed == null) return;
    _emit(<Object?>[
      formatKind('derived recomputed'),
      styled(derived.debugName, <String, String>{'color': 'BlueViolet'}),
      ..._formatInfo(info),
      formatChanges(changed),
      _Data(<Object?>[
        derived.debugNameData.referenceFn ?? derived.computeFn,
      ]),
    ]);
    changed.clear();
  }

  @override
  void handleDerivedCleared(Object observable) {
    if (!_isIncluded(observable)) return;
    _emit(<Object?>[
      formatKind('derived cleared'),
      styled(_debugNameOf(observable), <String, String>{'color': 'BlueViolet'}),
    ]);
  }

  /// 1:1: ConsoleObservableLogger.handleFromEventObservableTriggered
  void handleFromEventObservableTriggered(Object observable, IChangeInformation info) {
    if (!_isIncluded(observable)) return;
    _emit(<Object?>[
      formatKind('observable from event triggered'),
      styled(_debugNameOf(observable), <String, String>{'color': 'BlueViolet'}),
      ..._formatInfo(info),
      _Data(<Object?>[(observable as FromEventObservable).getValue]),
    ]);
  }

  @override
  void handleAutorunCreated(Object autorun, DebugLocation? location) {
    if (!_isIncluded(autorun)) return;
    changedObservablesSets[autorun] = <Object>{};
  }

  @override
  void handleAutorunDisposed(Object autorun) {}

  @override
  void handleAutorunDependencyChanged(
    Object autorun,
    IObservableWithChange<Object?, Object?> observable,
    Object? change,
  ) {
    if (!_isIncluded(autorun)) return;
    changedObservablesSets[autorun]!.add(observable);
  }

  @override
  void handleAutorunStarted(Object autorun) {
    final changed = changedObservablesSets[autorun];
    if (changed == null) return;
    if (_isIncluded(autorun)) {
      _emit(<Object?>[
        formatKind('autorun'),
        styled(_debugNameOf(autorun), <String, String>{'color': 'BlueViolet'}),
        formatChanges(changed),
        _Data(<Object?>[
          (autorun as AutorunObserver).debugNameData.referenceFn ??
              autorun.runFn,
        ]),
      ]);
    }
    changed.clear();
    indentation++;
  }

  @override
  void handleAutorunFinished(Object autorun) {
    indentation--;
  }

  @override
  void handleBeginTransaction(Object transaction) {
    String? name;
    if (transaction is TransactionImpl) {
      name = transaction.getDebugName();
    }
    final transactionName = name ?? '';
    if (_isIncluded(transaction)) {
      _emit(<Object?>[
        formatKind('transaction'),
        styled(transactionName, <String, String>{'color': 'BlueViolet'}),
        _Data(<Object?>[(transaction as TransactionImpl).fn]),
      ]);
    }
    indentation++;
  }

  @override
  void handleEndTransaction(Object transaction) {
    indentation--;
  }

  void _emit(List<Object?> text) {
    final args = _textToConsoleArgs(text);
    consoleLog(args.first, args.sublist(1));
  }
}

String _debugNameOf(Object obj) {
  if (obj is IObservableWithChange) return obj.debugName;
  if (obj is Derived) return obj.debugName;
  return '(unknown)';
}

// ---- ConsoleText union carriers ----
class _Styled {
  _Styled(this.text, this.style);
  final String text;
  final String style;
}

class _Data {
  _Data(this.data);
  final List<Object?> data;
}

/// 1:1: `consoleTextToArgs`
List<Object?> consoleTextToArgs(Object? text) {
  final styles = <String>[];
  final data = <Object?>[];
  final firstArg = StringBuffer();

  void process(Object? t) {
    if (t is List) {
      for (final item in t) {
        if (item != null) process(item);
      }
    } else if (t is _Styled) {
      firstArg.write('%c${t.text}');
      styles.add(t.style);
    } else if (t is _Data) {
      data.addAll(t.data);
    }
  }

  process(text);
  return <Object?>[firstArg.toString(), ...styles, ...data];
}

/// 1:1: `styled`
Object styled(String text, [Map<String, String>? options]) {
  final opts = options ?? <String, String>{'color': 'black'};
  final style = <String, String>{'color': opts['color'] ?? 'black'};
  if (opts['text-decoration'] != null) {
    style['text-decoration'] = 'line-through';
  }
  if (opts['font-weight'] != null) {
    style['font-weight'] = 'bold';
  }
  final css = style.entries.map((e) => '${e.key}:${e.value};').join();
  return _Styled(text, css);
}

/// 1:1: `normalText`
Object normalText(String text) =>
    styled(text, <String, String>{'color': 'black'});

/// 1:1: `formatKind`
Object formatKind(String kind) => styled(
      padStr('$kind: ', 10),
      <String, String>{'color': 'black', 'font-weight': 'bold'},
    );

/// 1:1: `formatValue`
String formatValue(Object? value, int availableLen) {
  if (value == null) return 'undefined';
  if (value is num) return value.toString();
  if (value is String) {
    if (value.length + 2 <= availableLen) return '"$value"';
    return '"${value.substring(0, availableLen - 7)}"+...';
  }
  if (value is bool) return value ? 'true' : 'false';
  if (value is List) return formatArray(value, availableLen);
  if (identical(value, _JSNull)) return 'null';
  // Detect a custom toString override (Dart default is 'Instance of ...').
  final str = value.toString();
  if (!str.startsWith('Instance of') && str != value.runtimeType.toString()) {
    if (str.length <= availableLen) return str;
    return '${str.substring(0, availableLen - 3)}...';
  }
  final className = getClassName(value) ?? '';
  return formatObject(value, availableLen, className);
}

/// Sentinel matching JS `null` (Dart `null` maps to JS `undefined` in this port).
final Object _JSNull = Object();

/// 1:1: `formatArray`
String formatArray(List<Object?> value, int availableLen) {
  final result = StringBuffer('[ ');
  bool first = true;
  for (final val in value) {
    if (!first) result.write(', ');
    if (result.length - 5 > availableLen) {
      result.write('...');
      break;
    }
    first = false;
    result.write(formatValue(val, availableLen - result.length));
  }
  result.write(' ]');
  return result.toString();
}

/// 1:1: `formatObject`
String formatObject(Object value, int availableLen, String className) {
  final result = StringBuffer(className.isNotEmpty ? '$className(' : '{ ');
  bool first = true;
  if (value is Map) {
    for (final entry in value.entries) {
      if (!first) result.write(', ');
      if (result.length - 5 > availableLen) {
        result.write('...');
        break;
      }
      first = false;
      result.write('${entry.key}: ${formatValue(entry.value, availableLen - result.length)}');
    }
  }
  result.write(className.isNotEmpty ? ')' : ' }');
  return result.toString();
}

/// 1:1: `repeat`
String repeat(String str, int count) {
  final result = StringBuffer();
  for (int i = 1; i <= count; i++) {
    result.write(str);
  }
  return result.toString();
}

/// 1:1: `padStr`
String padStr(String str, int length) {
  while (str.length < length) {
    str += ' ';
  }
  return str;
}
