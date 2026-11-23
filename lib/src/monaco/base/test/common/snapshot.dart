// 1:1 port of vscode/src/vs/base/test/common/snapshot.ts
// The `__readFileInTests`-style globals, Mocha `Test` type and `setup`/`teardown`
// have no Dart equivalents: they are injectable top-level slots. `formatValue`
// is the pure recursive serializer and stays 1:1 (Map/Set/RegExp/circular/
// debug.description handling included).

import 'dart:convert' show jsonEncode;

import '../../common/lazy.dart' show Lazy;
import '../../common/network.dart' show FileAccess;
import '../../common/uri.dart' show URI;

// ---- injected test-host globals -------------------------------------------

/// 1:1: `declare const __readFileInTests: (path) => Promise<string>`
Future<String> Function(String path)? readFileInTests;

/// 1:1: `__writeFileInTests`
Future<void> Function(String path, String contents)? writeFileInTests;

/// 1:1: `__readDirInTests`
Future<List<String>> Function(String path)? readDirInTests;

/// 1:1: `__unlinkInTests`
Future<void> Function(String path)? unlinkInTests;

/// 1:1: `__mkdirPInTests`
Future<void> Function(String path)? mkdirPInTests;

/// Mocha `setup(cb)` / `teardown(cb)` where `this.currentTest` is passed.
void Function(void Function(dynamic currentTest) cb)? snapshotSetup;
void Function(Future<void> Function(dynamic currentTest) cb)? snapshotTeardown;

/// Injectable `console.info`.
void Function(String) snapshotConsoleInfo = (String message) {};

/// Bridge for `URI.joinPath(FileAccess.asFileUri(''), '../src')`.
/// The source resolves the module root automatically; tests inject a stand-in.
URI Function()? snapshotSourceRootProvider;

/// 1:1: `interface ISnapshotOptions`
class ISnapshotOptions {
  final String? name;
  final String? extension;
  const ISnapshotOptions({this.name, this.extension});
}

/// Mocha `Test` carrier (the fields the source reads).
class SnapshotTest {
  final String? file;
  final String Function() fullTitle;
  const SnapshotTest({required this.file, required this.fullTitle});
}

// ---- module-level helpers -------------------------------------------------

/// `let context: Lazy<SnapshotContext> | undefined;`
Lazy<SnapshotContext>? context;

String sanitizeName(String name) =>
    name.replaceAll(RegExp(r'[^a-z0-9_-]', caseSensitive: false), '_');

String normalizeCrlf(String str) => str.replaceAll('\r\n', '\n');

const String _debugDescriptionSymbol = 'debug.description';

/// 1:1: `export class SnapshotContext`
class SnapshotContext {
  int nextIndex = 0;
  late URI snapshotsDir;
  late final String namePrefix;
  final Set<String> usedNames = <String>{};
  final SnapshotTest? test;

  SnapshotContext(this.test) {
    if (test == null) {
      throw StateError('assertSnapshot can only be used in a test');
    }
    if (test!.file == null) {
      throw StateError(
        "currentTest.file is not set, please open an issue with the test you're trying to run",
      );
    }

    final URI src = snapshotSourceRootProvider != null
        ? snapshotSourceRootProvider!()
        : URI.joinPath(FileAccess.asFileUri(''), <String>['../src']);
    final List<String> parts = test!.file!.split(RegExp(r'[/\\]'));
    namePrefix = '${sanitizeName(test!.fullTitle())}.';
    snapshotsDir = URI.joinPath(
      src,
      <String>[...parts.sublist(0, parts.length - 1), '__snapshots__'],
    );
  }

  /// 1:1: `public async assert(value, options?)`
  Future<void> assertValue(Object? value, [ISnapshotOptions? options]) async {
    final StackTrace originalStack = StackTrace.current;
    final Object nameOrIndex =
        options?.name != null ? sanitizeName(options!.name!) : nextIndex++;
    final String fileName =
        '$namePrefix$nameOrIndex.${options?.extension ?? 'snap'}';
    usedNames.add(fileName);

    final String fpath = URI.joinPath(snapshotsDir, <String>[fileName]).fsPath;
    final String actual = formatValue(value);
    String expected;
    try {
      expected = await readFileInTests!(fpath);
    } catch (_) {
      snapshotConsoleInfo('Creating new snapshot in: $fpath');
      await mkdirPInTests!(snapshotsDir.fsPath);
      await writeFileInTests!(fpath, actual);
      return;
    }

    if (normalizeCrlf(expected) != normalizeCrlf(actual)) {
      await writeFileInTests!('$fpath.actual', actual);
      final _SnapshotMismatchError err = _SnapshotMismatchError(
        'Snapshot #$nameOrIndex does not match expected output',
      );
      err.expected = expected;
      err.actual = actual;
      err.snapshotPath = fpath;
      // Source rewrites stack to keep only the original caller's frame.
      err.stack = originalStack;
      throw err;
    }
  }

  /// 1:1: `public async removeOldSnapshots()`
  Future<void> removeOldSnapshots() async {
    final List<String> contents = await readDirInTests!(snapshotsDir.fsPath);
    final List<String> toDelete = contents
        .where((String f) =>
            f.startsWith(namePrefix) && !usedNames.contains(f))
        .toList();
    final List<String> oldSnapshots =
        toDelete.where((String f) => !f.endsWith('.actual')).toList();
    if (oldSnapshots.isNotEmpty) {
      snapshotConsoleInfo(
        'Deleting ${oldSnapshots.length} old snapshots for ${test?.fullTitle()}',
      );
    }
    await Future.wait(toDelete.map((String f) =>
        unlinkInTests!(URI.joinPath(snapshotsDir, <String>[f]).fsPath)));
  }
}

/// Carrier for the source's `Error` with `.expected/.actual/.snapshotPath`.
class _SnapshotMismatchError implements Exception {
  final String message;
  String? expected;
  String? actual;
  String? snapshotPath;
  StackTrace? stack;

  _SnapshotMismatchError(this.message);

  @override
  String toString() => message;
}

/// 1:1: `function formatValue(value, level = 0, seen = []): string`
String formatValue(
  Object? value, [
  int level = 0,
  List<Object?> seen = const <Object?>[],
]) {
  if (value == null) {
    return 'null';
  }
  if (value is bool || value is num) {
    return value.toString();
  }
  if (value is String) {
    return level == 0 ? value : jsonEncode(value);
  }
  if (value is Function) {
    // `value.name` is unavailable for arbitrary Dart functions; use runtimeType.
    return '[Function ${value.runtimeType}]';
  }
  if (value is RegExp) {
    return value.toString();
  }
  if (value is Map) {
    if (seen.any((Object? o) => identical(o, value))) {
      return '[Circular]';
    }
    final Object? debugDesc = value[_debugDescriptionSymbol];
    if (debugDesc is Function) {
      return (debugDesc as dynamic)() as String;
    }
    final String oi = '  ' * level;
    final String ci = '  ' * (level + 1);
    final List<String> lines = value.entries
        .map((MapEntry<dynamic, dynamic> e) =>
            '${e.key}: ${formatValue(e.value, level + 1, <Object?>[...seen, value])}')
        .toList();
    return 'Map ' +
        (lines.length > 1
            ? '{\n$ci${lines.join(',\n$ci')}\n$oi}'
            : '{ ${lines.join(',\n')} }');
  }
  if (value is Set) {
    if (seen.any((Object? o) => identical(o, value))) {
      return '[Circular]';
    }
    final String oi = '  ' * level;
    final String ci = '  ' * (level + 1);
    int i = 0;
    final List<String> lines = value
        .map((dynamic v) =>
            '${i++}: ${formatValue(v, level + 1, <Object?>[...seen, value])}')
        .toList();
    return 'Set ' +
        (lines.length > 1
            ? '{\n$ci${lines.join(',\n$ci')}\n$oi}'
            : '{ ${lines.join(',\n')} }');
  }
  if (value is List) {
    if (seen.any((Object? o) => identical(o, value))) {
      return '[Circular]';
    }
    final String oi = '  ' * level;
    final String ci = '  ' * (level + 1);
    final List<String> children = value
        .map((dynamic v) => formatValue(v, level + 1, <Object?>[...seen, value]))
        .toList();
    final bool multiline = children.any((String c) => c.contains('\n')) ||
        children.join(', ').length > 80;
    return multiline
        ? '[\n$ci${children.join(',\n$ci')}\n$oi]'
        : '[ ${children.join(', ')} ]';
  }
  throw StateError('Unknown type ${value.runtimeType}');
}

// ---- module-load hooks ----------------------------------------------------

/// Bridge entry for the module-load `setup(...)`/`teardown(...)` calls.
/// Test hosts set [snapshotSetup]/[snapshotTeardown] before calling this.
bool installSnapshotHooks() {
  (snapshotSetup ?? _noopSetup)((dynamic currentTest) {
    context = Lazy<SnapshotContext>(
        () => SnapshotContext(currentTest as SnapshotTest?));
  });
  (snapshotTeardown ?? _noopTeardown)((dynamic currentTest) async {
    final dynamic test = currentTest;
    final Object? state = test == null ? null : test.state;
    if (state == 'passed') {
      await context?.rawValue?.removeOldSnapshots();
    }
    context = null;
  });
  return true;
}

/// Top-level initializer stands in for the module-load `setup(...)`/`teardown(...)`.
final bool _hooksInstalled = installSnapshotHooks();

/// 1:1: `export function assertSnapshot(value, options?): Promise<void>`
Future<void> assertSnapshot(Object? value, [ISnapshotOptions? options]) {
  // Force the module-load hook installation on first use.
  assert(_hooksInstalled);
  final Lazy<SnapshotContext>? ctx = context;
  if (ctx == null) {
    throw StateError('assertSnapshot can only be used in a test');
  }
  return ctx.value.assertValue(value, options);
}

void _noopSetup(void Function(dynamic currentTest) cb) {}
void _noopTeardown(Future<void> Function(dynamic currentTest) cb) {}
