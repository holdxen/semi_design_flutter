// ---------------------------------------------------------------------------
// Port of vscode/src/vs/base/common/functional.ts @bfbf12b35b9978b92b2d341e81ade49f2b18c68c
// Translated 1:1 from TypeScript. TS `this: unknown` + `fn.apply(_this, arguments)`
// is a JS-only mechanism; all in-tree call sites pass a zero-argument closure,
// so the Dart port binds no receiver and forwards no arguments. The "call once,
// cache result, run callback in finally" control flow is identical.
// ---------------------------------------------------------------------------

/// Given a function, returns a function that is only calling that function once.
///
/// [fnDidRunCallback] is invoked after the first call, even if [fn] throws.
T Function() createSingleCallFunction<T>(
  T Function() fn, {
  void Function()? fnDidRunCallback,
}) {
  bool didCall = false;
  Object? result;

  return () {
    if (didCall) {
      return result as T;
    }

    didCall = true;
    if (fnDidRunCallback != null) {
      try {
        result = fn();
      } finally {
        fnDidRunCallback();
      }
    } else {
      result = fn();
    }

    return result as T;
  };
}
