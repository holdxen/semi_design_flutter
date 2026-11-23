// ---------------------------------------------------------------------------
// Port of vscode/src/vs/base/common/observableInternal/logging/debugGetDependencyGraph.ts
// Translated 1:1. `instanceof` checks map to Dart `is` on the ported classes;
// debug state comes from each class's `debugGetState()` / `debugGetObservers()`.
// ---------------------------------------------------------------------------

import '../observables/baseObservable.dart' show setDebugGetObservableGraph;
import '../observables/derivedImpl.dart' show Derived;
import '../observables/observableFromEvent.dart' show FromEventObservable;
import '../observables/observableValue.dart' show ObservableValue;
import '../reactions/autorunImpl.dart' show AutorunObserver;
import 'consoleObservableLogger.dart' show formatValue;

/// 1:1: `interface IOptions`
class GraphOptions {
  GraphOptions({required this.type, this.debugNamePostProcessor});

  final String type; // 'dependencies' | 'observers'
  final String Function(String name)? debugNamePostProcessor;
}

/// 1:1: `debugGetObservableGraph`
String debugGetObservableGraph(Object obs, GraphOptions options) {
  final debugNamePostProcessor =
      options.debugNamePostProcessor ?? ((String str) => str);
  final info = Info.from(obs, debugNamePostProcessor);
  if (info == null) {
    return '';
  }

  final alreadyListed = <Object>{};

  if (options.type == 'observers') {
    return _formatObservableInfoWithObservers(
            info, 0, alreadyListed, options)
        .trim();
  } else {
    return _formatObservableInfoWithDependencies(
            info, 0, alreadyListed, options)
        .trim();
  }
}

String _formatObservableInfoWithDependencies(
  Info info,
  int indentLevel,
  Set<Object> alreadyListed,
  GraphOptions options,
) {
  final indent = '\t\t' * indentLevel;
  final lines = <String>[];

  if (alreadyListed.contains(info.sourceObj)) {
    lines.add('$indent* ${info.type} ${info.name} (already listed)');
    return lines.join('\n');
  }
  alreadyListed.add(info.sourceObj);

  lines.add('$indent* ${info.type} ${info.name}:');
  lines.add('$indent  value: ${formatValue(info.value, 50)}');
  lines.add('$indent  state: ${info.state}');

  if (info.dependencies.isNotEmpty) {
    lines.add('$indent  dependencies:');
    for (final dep in info.dependencies) {
      final depInfo = Info.from(
              dep, options.debugNamePostProcessor ?? ((name) => name)) ??
          Info.unknown(dep);
      lines.add(_formatObservableInfoWithDependencies(
          depInfo, indentLevel + 1, alreadyListed, options));
    }
  }
  return lines.join('\n');
}

String _formatObservableInfoWithObservers(
  Info info,
  int indentLevel,
  Set<Object> alreadyListed,
  GraphOptions options,
) {
  final indent = '\t\t' * indentLevel;
  final lines = <String>[];

  if (alreadyListed.contains(info.sourceObj)) {
    lines.add('$indent* ${info.type} ${info.name} (already listed)');
    return lines.join('\n');
  }
  alreadyListed.add(info.sourceObj);

  lines.add('$indent* ${info.type} ${info.name}:');
  lines.add('$indent  value: ${formatValue(info.value, 50)}');
  lines.add('$indent  state: ${info.state}');

  if (info.observers.isNotEmpty) {
    lines.add('$indent  observers:');
    for (final observer in info.observers) {
      final observerInfo = Info.from(
              observer, options.debugNamePostProcessor ?? ((name) => name)) ??
          Info.unknown(observer);
      lines.add(_formatObservableInfoWithObservers(
          observerInfo, indentLevel + 1, alreadyListed, options));
    }
  }
  return lines.join('\n');
}

/// 1:1: `class Info`
class Info {
  Info(
    this.sourceObj,
    this.name,
    this.type,
    this.value,
    this.state,
    this.dependencies,
    this.observers,
  );

  final Object sourceObj;
  final String name;
  final String type;
  final Object? value;
  final String state;
  final List<Object> dependencies;
  final List<Object> observers;

  /// 1:1: `Info.from`
  static Info? from(Object obs, String Function(String) debugNamePostProcessor) {
    if (obs is AutorunObserver) {
      final state = obs.debugGetState();
      return Info(
        obs,
        debugNamePostProcessor(obs.debugName),
        'autorun',
        null,
        state['stateStr'] as String? ?? 'unknown',
        List<Object>.from(state['dependencies'] as Iterable? ?? const []),
        <Object>[],
      );
    } else if (obs is Derived) {
      final state = obs.debugGetState();
      return Info(
        obs,
        debugNamePostProcessor(obs.debugName),
        'derived',
        state['value'],
        state['stateStr'] as String? ?? 'unknown',
        List<Object>.from(state['dependencies'] as Iterable? ?? const []),
        List<Object>.from(obs.debugGetObservers()),
      );
    } else if (obs is ObservableValue) {
      final state = obs.debugGetState();
      return Info(
        obs,
        debugNamePostProcessor(obs.debugName),
        'observableValue',
        state['value'],
        'upToDate',
        <Object>[],
        List<Object>.from(obs.debugGetObservers()),
      );
    } else if (obs is FromEventObservable) {
      final state = obs.debugGetState();
      return Info(
        obs,
        debugNamePostProcessor(obs.debugName),
        'fromEvent',
        state['value'],
        state['hasValue'] == true ? 'upToDate' : 'initial',
        <Object>[],
        List<Object>.from(obs.debugGetObservers()),
      );
    }
    return null;
  }

  /// 1:1: `Info.unknown`
  static Info unknown(Object obs) => Info(
        obs,
        '(unknown)',
        'unknown',
        null,
        'unknown',
        <Object>[],
        <Object>[],
      );
}

/// 1:1: `_setDebugGetObservableGraph(debugGetObservableGraph)` at module load.
bool _graphRegistered = false;
void ensureDebugGraphRegistered() {
  if (_graphRegistered) return;
  setDebugGetObservableGraph((observable, opts) {
    final type = (opts as Map)['type'] as String? ?? 'dependencies';
    final post = (opts as Map)['debugNamePostProcessor'] as String Function(String)?;
    return debugGetObservableGraph(
      observable,
      GraphOptions(type: type, debugNamePostProcessor: post),
    );
  });
  _graphRegistered = true;
}
