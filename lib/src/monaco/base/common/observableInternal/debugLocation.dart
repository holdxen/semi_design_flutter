// 1:1 translation of
// vscode/src/vs/base/common/observableInternal/debugLocation.ts
// Mirrors the DebugLocation namespace, DebugLocationImpl, ILocation and
// parseLine file-for-file. In TS `DebugLocation` is both a type alias and a
// namespace; Dart cannot have a typedef and a class with the same name, so the
// abstract class carries both the namespace statics and the (nullable) type.

/// 1:1: `export type DebugLocation = DebugLocationImpl | undefined`
/// Carried as an abstract base class; nullable at use sites (`DebugLocation?`).
abstract class DebugLocation {
  static bool _enabled = false;

  /// 1:1: `export function enable(): void`
  static void enable() {
    _enabled = true;
  }

  /// 1:1: `export function ofCaller(): DebugLocation`
  static DebugLocation? ofCaller() {
    if (!_enabled) {
      return null;
    }
    // 1:1: the TS code temporarily lowers Error.stackTraceLimit to 3, reads
    // the stack, then restores it. Dart has no configurable stack limit; the
    // stack is taken directly and the caller frame index is preserved below.
    final String stack = StackTrace.current.toString();
    return DebugLocationImpl.fromStack(stack, 2);
  }
}

/// 1:1: `class DebugLocationImpl implements ILocation`
class DebugLocationImpl implements DebugLocation, ILocation {
  /// 1:1: `public static fromStack(stack, parentIdx)`
  static DebugLocationImpl? fromStack(String stack, int parentIdx) {
    final List<String> lines = stack.split('\n');
    final ILocation? location = parseLine(lines[parentIdx + 1]);
    if (location != null) {
      return DebugLocationImpl(
        location.fileName,
        location.line,
        location.column,
        location.id,
      );
    } else {
      return null;
    }
  }

  @override
  final String fileName;
  @override
  final int line;
  @override
  final int column;
  @override
  final String id;

  DebugLocationImpl(this.fileName, this.line, this.column, this.id);
}

/// 1:1: `export interface ILocation`
abstract class ILocation {
  String get fileName;
  int get line;
  int get column;
  String get id;
}

/// 1:1: `function parseLine(stackLine: string): ILocation | undefined`
ILocation? parseLine(String stackLine) {
  final RegExp re1 = RegExp(r'\((.*):(\d+):(\d+)\)');
  final RegExpMatch? match = re1.firstMatch(stackLine);
  if (match != null) {
    return _ParsedLocation(
      match.group(1)!,
      int.parse(match.group(2)!),
      int.parse(match.group(3)!),
      stackLine,
    );
  }

  final RegExp re2 = RegExp(r'at ([^\(\)]*):(\d+):(\d+)');
  final RegExpMatch? match2 = re2.firstMatch(stackLine);
  if (match2 != null) {
    return _ParsedLocation(
      match2.group(1)!,
      int.parse(match2.group(2)!),
      int.parse(match2.group(3)!),
      stackLine,
    );
  }

  return null;
}

class _ParsedLocation implements ILocation {
  @override
  final String fileName;
  @override
  final int line;
  @override
  final int column;
  @override
  final String id;

  _ParsedLocation(this.fileName, this.line, this.column, this.id);
}
