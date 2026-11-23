// 1:1 port of vscode/src/vs/base/test/common/utils.ts
// mocha globals (`suite`/`test`/`setup`/`teardown`, `this.test.fullTitle()`)
// and the DOM `btoa` have no Dart equivalent. They are exposed as injectable
// top-level function slots, defaulting to no-ops so library code stays free of
// any test-framework dependency; embedders install them from their runner.

import 'dart:convert' show base64Encode, latin1;

import '../../common/lifecycle.dart'
    show
        DisposableInfo,
        DisposableStore,
        DisposableTracker,
        IDisposable,
        setDisposableTracker;
import '../../common/path.dart' show join;
import '../../common/platform.dart' show isWindows;
import '../../common/uri.dart' show URI;

/// mocha-like context, exposing `test.fullTitle()`.
class TestContext {
  final String Function() fullTitle;
  TestContext(this.fullTitle);
}

/// Stand-in for the mocha `this` receiver that `toResource` is bound to.
class MochaThis {
  final TestContext test;
  MochaThis(this.test);
}

// ---- injectable mocha globals ---------------------------------------------

/// 1:1: global `suite(description, callback)`.
void Function(String description, void Function() callback)? mochaSuite;

/// 1:1: global `test(description, callback)`.
void Function(String description, Object? Function() callback)? mochaTest;

/// 1:1: global `setup(callback)`.
void Function(void Function() callback)? mochaSetup;

/// 1:1: global `teardown(function (this: Context) { ... })`.
void Function(void Function(dynamic context) callback)? mochaTeardown;

/// 1:1: JS `btoa` (Latin-1 -> base64). Injectable; defaults to dart:convert.
String Function(String) btoaFn = (String input) =>
    base64Encode(latin1.encode(input));

/// Injectable sink for `console.error`.
void Function(String) consoleErrorFn = (String message) {};

/// 1:1: `export type ValueCallback<T = any> = (value: T | Promise<T>) => void`
typedef ValueCallback = void Function(Object? value);

/// 1:1: `export function toResource(this: any, path: string): URI`
URI toResource(MochaThis receiver, String path) {
  if (isWindows) {
    return URI.file(join(<String>[
      'C:\\',
      btoaFn(receiver.test.fullTitle()),
      path,
    ]));
  }

  return URI.file(join(<String>[
    '/',
    btoaFn(receiver.test.fullTitle()),
    path,
  ]));
}

/// 1:1: `export function suiteRepeat(n, description, callback): void`
void suiteRepeat(int n, String description, void Function() callback) {
  for (int i = 0; i < n; i++) {
    (mochaSuite ?? _noopSuite)('$description (iteration $i)', callback);
  }
}

/// 1:1: `export function testRepeat(n, description, callback): void`
void testRepeat(int n, String description, Object? Function() callback) {
  for (int i = 0; i < n; i++) {
    (mochaTest ?? _noopTest)('$description (iteration $i)', callback);
  }
}

/// 1:1: `export async function assertThrowsAsync(block, message): Promise<void>`
Future<void> assertThrowsAsync(
  Future<Object?> Function() block, [
  Object message = 'Missing expected exception',
]) async {
  try {
    await block();
  } catch (_) {
    return;
  }

  // Source: `const err = message instanceof Error ? message : new Error(message)`.
  final Object err =
      message is Error ? message : StateError(message.toString());
  throw err;
}

/// Returned handle mirroring `Pick<DisposableStore, 'add'>`.
/// The suite function is called before `store` is initialized, so `add`
/// resolves the store lazily on each call.
class DisposableStoreAdd {
  final T Function<T extends IDisposable>(T o) _add;
  DisposableStoreAdd(this._add);

  /// 1:1: `store.add<T>(o: T): T`
  T add<T extends IDisposable>(T o) => _add<T>(o);
}

/// 1:1: `export function ensureNoDisposablesAreLeakedInTestSuite()`
DisposableStoreAdd ensureNoDisposablesAreLeakedInTestSuite() {
  DisposableTracker? tracker;
  DisposableStore? store;
  (mochaSetup ?? _noopSetup)(() {
    store = DisposableStore();
    tracker = DisposableTracker();
    setDisposableTracker(tracker);
  });

  (mochaTeardown ?? _noopTeardown)((dynamic context) {
    store!.dispose();
    setDisposableTracker(null);
    // `this.currentTest?.state !== 'failed'`
    final Object? state = _currentTestState(context);
    if (state != 'failed') {
      final ({List<DisposableInfo> leaks, String details})? result =
          _computeLeakingDisposables(tracker!, false);
      if (result != null) {
        // console.error(result.details) then throw — compute already threw;
        // unreachable, kept for shape parity with the source.
      }
    }
  });

  // Wrap store as the suite function is called before it's initialized.
  return DisposableStoreAdd(<T extends IDisposable>(T o) => store!.add<T>(o));
}

/// 1:1: `export function throwIfDisposablesAreLeaked(body, logToConsole = true)`
void throwIfDisposablesAreLeaked(
  void Function() body, [
  bool logToConsole = true,
]) {
  final DisposableTracker tracker = DisposableTracker();
  setDisposableTracker(tracker);
  body();
  setDisposableTracker(null);
  _computeLeakingDisposables(tracker, logToConsole);
}

/// 1:1: `export async function throwIfDisposablesAreLeakedAsync(body)`
Future<void> throwIfDisposablesAreLeakedAsync(
  Future<void> Function() body,
) async {
  final DisposableTracker tracker = DisposableTracker();
  setDisposableTracker(tracker);
  await body();
  setDisposableTracker(null);
  _computeLeakingDisposables(tracker);
}

/// 1:1: `function computeLeakingDisposables(tracker, logToConsole = true)`
({List<DisposableInfo> leaks, String details})? _computeLeakingDisposables(
  DisposableTracker tracker, [
  bool logToConsole = true,
]) {
  final ({List<DisposableInfo> leaks, String details})? result =
      tracker.computeLeakingDisposables();
  if (result != null) {
    if (logToConsole) {
      consoleErrorFn(result.details);
    }
    throw StateError(
      'There are ${result.leaks.length} undisposed disposables!'
      '${result.details}',
    );
  }
  return result;
}

/// Reads `this.currentTest?.state` off an injected mocha context.
Object? _currentTestState(dynamic context) {
  if (context == null) {
    return null;
  }
  try {
    final dynamic currentTest = context.currentTest;
    return currentTest == null ? null : currentTest.state as Object?;
  } catch (_) {
    return null;
  }
}

void _noopSuite(String description, void Function() callback) {}
void _noopTest(String description, Object? Function() callback) {}
void _noopSetup(void Function() callback) {}
void _noopTeardown(void Function(dynamic context) callback) {}
