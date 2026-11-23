// 1:1 port of vscode/src/vs/base/browser/ui/progressbar/progressbar.ts
import 'dart:async';

import '../../dom.dart' as DOM show DomElement, document, hide, show;
import '../../../common/async.dart' show RunOnceScheduler;
import '../../../common/lifecycle.dart'
    show Disposable, IDisposable, MutableDisposable;
import '../../../common/types.dart' show isNumber;
import 'progressAccessibilitySignal.dart'
    show getProgressAccessibilitySignalScheduler;

const String CSS_DONE = 'done';
const String CSS_ACTIVE = 'active';
const String CSS_INFINITE = 'infinite';
const String CSS_INFINITE_LONG_RUNNING = 'infinite-long-running';
const String CSS_DISCRETE = 'discrete';
const String NLS_PROGRESS_LABEL = 'Progress';

/// 1:1: `interface IProgressBarStyles`
class IProgressBarStyles {
  final String? progressBarBackground;
  const IProgressBarStyles({this.progressBarBackground});
}

/// 1:1: `interface IProgressBarOptions`
class IProgressBarOptions extends IProgressBarStyles {
  final String? ariaLabel;
  const IProgressBarOptions({this.ariaLabel, String? progressBarBackground})
      : super(progressBarBackground: progressBarBackground);
}

/// 1:1: `unthemedProgressBarOptions`
const IProgressBarOptions unthemedProgressBarOptions = IProgressBarOptions();

/// 1:1: JS `Number(value)` for the values accepted by worked()/setWorked().
num _jsNumber(Object? value) {
  if (value is num) return value;
  if (value is bool) return value ? 1 : 0;
  if (value == null) return 0;
  final String text = value.toString().trim();
  if (text.isEmpty) return 0;
  if (text.toLowerCase() == 'infinity') return double.infinity;
  if (text.toLowerCase() == '-infinity') return double.negativeInfinity;
  final num? hex = num.tryParse(text);
  if (hex != null) return hex;
  if (text.toLowerCase().startsWith('0x')) {
    return int.tryParse(text.substring(2), radix: 16) ?? 0;
  }
  return 0;
}

/// JS `number.toString()` differs from Dart for integral doubles.
String _jsNumString(num value) {
  if (value is double && value.isFinite && value == value.roundToDouble()) {
    return value.toInt().toString();
  }
  return value.toString();
}

/// Test bridge for the global `setTimeout(() => this.off(), 200)` calls.
/// The default uses a real [Timer]; tests may replace it with a synchronous
/// recorder, mirroring the fake clock used by the TypeScript runtime truth.
class ProgressBarTimeoutHandle {
  final int ms;
  final void Function() callback;
  bool cancelled = false;
  bool fired = false;

  ProgressBarTimeoutHandle(this.callback, this.ms);

  void fire() {
    if (!cancelled && !fired) {
      fired = true;
      callback();
    }
  }

  void cancel() => cancelled = true;
}

ProgressBarTimeoutHandle Function(void Function() callback, int ms)
    progressBarSetTimeout = (void Function() callback, int ms) {
  final ProgressBarTimeoutHandle handle =
      ProgressBarTimeoutHandle(callback, ms);
  Timer(Duration(milliseconds: ms), () {
    if (!handle.cancelled && !handle.fired) handle.fire();
  });
  return handle;
};

/// A progress bar with support for infinite or discrete progress.
class ProgressBar extends Disposable {
  /// After a certain time of showing the progress bar, switch to long-running
  /// mode and throttle animations to reduce the pressure on the GPU process.
  static const int LONG_RUNNING_INFINITE_THRESHOLD = 10000;
  static const int PROGRESS_SIGNAL_DEFAULT_DELAY = 3000;

  num workedVal;
  late final DOM.DomElement element;
  late final DOM.DomElement bit;
  num? totalWork;

  // TS declares these private, but they are ordinary runtime properties and
  // are exposed here for the data-driven truth test (`flush()` / `isScheduled()`).
  late final RunOnceScheduler showDelayedScheduler;
  late final RunOnceScheduler longRunningScheduler;

  // TS: `private readonly progressSignal = this._register(new MutableDisposable<IDisposable>())`
  final MutableDisposable<IDisposable> progressSignal;

  ProgressBar(DOM.DomElement container, [IProgressBarOptions? options])
      : workedVal = 0,
        progressSignal = MutableDisposable<IDisposable>() {
    // TS field initializer runs before the constructor body.
    register(progressSignal);

    showDelayedScheduler = register(RunOnceScheduler(
        () => DOM.show(<DOM.DomElement>[element]), 0));
    longRunningScheduler = register(RunOnceScheduler(
        () => infiniteLongRunning(), LONG_RUNNING_INFINITE_THRESHOLD));

    create(container, options);
  }

  void create(DOM.DomElement container, [IProgressBarOptions? options]) {
    element = DOM.document.createElement('div');
    element.classList.add('monaco-progress-container');
    element.setAttribute('role', 'progressbar');
    element.setAttribute('aria-valuemin', '0');
    final String? aria = options?.ariaLabel;
    element.setAttribute(
      'aria-label',
      (aria != null && aria.trim().isNotEmpty) ? aria : NLS_PROGRESS_LABEL,
    );
    container.appendChild(element);

    bit = DOM.document.createElement('div');
    bit.classList.add('progress-bit');
    bit.style['backgroundColor'] =
        (options?.progressBarBackground != null && options!.progressBarBackground!.isNotEmpty)
            ? options.progressBarBackground!
            : '#0E70C0';
    element.appendChild(bit);
  }

  void off() {
    bit.style['width'] = 'inherit';
    bit.style['opacity'] = '1';
    element.classList.remove(CSS_ACTIVE);
    element.classList.remove(CSS_INFINITE);
    element.classList.remove(CSS_INFINITE_LONG_RUNNING);
    element.classList.remove(CSS_DISCRETE);

    workedVal = 0;
    totalWork = null;

    longRunningScheduler.cancel();
    progressSignal.clear();
  }

  /// Indicates to the progress bar that all work is done.
  ProgressBar done() => doDone(true);

  /// Stops the progressbar from showing any progress instantly without fading out.
  ProgressBar stop() => doDone(false);

  ProgressBar doDone(bool delayed) {
    element.classList.add(CSS_DONE);

    if (!element.classList.contains(CSS_INFINITE)) {
      bit.style['width'] = 'inherit';
      if (delayed) {
        progressBarSetTimeout(() => off(), 200);
      } else {
        off();
      }
    } else {
      bit.style['opacity'] = '0';
      if (delayed) {
        progressBarSetTimeout(() => off(), 200);
      } else {
        off();
      }
    }
    return this;
  }

  /// Use this mode to indicate progress that has no total number of work units.
  ProgressBar infinite() {
    bit.style['width'] = '2%';
    bit.style['opacity'] = '1';

    element.classList.remove(CSS_DISCRETE);
    element.classList.remove(CSS_DONE);
    element.classList.remove(CSS_INFINITE_LONG_RUNNING);
    element.classList.add(CSS_ACTIVE);
    element.classList.add(CSS_INFINITE);

    longRunningScheduler.schedule();
    return this;
  }

  void infiniteLongRunning() {
    element.classList.add(CSS_INFINITE_LONG_RUNNING);
  }

  /// Tells the progress bar the total number of work.
  ProgressBar total(num value) {
    workedVal = 0;
    totalWork = value;
    element.setAttribute('aria-valuemax', _jsNumString(value));
    return this;
  }

  /// Finds out if this progress bar is configured with total work.
  bool hasTotal() => isNumber(totalWork);

  /// Tells the progress bar that an increment of work has been completed.
  ProgressBar worked(Object value) {
    final num converted = _jsNumber(value);
    final num increment = converted < 1 ? 1 : converted;
    return doSetWorked(workedVal + increment);
  }

  /// Tells the progress bar the total amount of work (0 to 100) completed.
  ProgressBar setWorked(Object value) {
    final num converted = _jsNumber(value);
    return doSetWorked(converted < 1 ? 1 : converted);
  }

  ProgressBar doSetWorked(num value) {
    final num work = totalWork ?? 0;
    final num total = work != 0 ? work : 100;

    workedVal = value > total ? total : value;

    element.classList.remove(CSS_INFINITE);
    element.classList.remove(CSS_INFINITE_LONG_RUNNING);
    element.classList.remove(CSS_DONE);
    element.classList.add(CSS_ACTIVE);
    element.classList.add(CSS_DISCRETE);
    // TS uses the original (unclamped) `value` for aria-valuenow.
    element.setAttribute('aria-valuenow', _jsNumString(value));

    bit.style['width'] = '${_jsNumString(100 * (workedVal / total))}%';
    return this;
  }

  DOM.DomElement getContainer() => element;

  void show([num? delay]) {
    showDelayedScheduler.cancel();
    progressSignal.value =
        getProgressAccessibilitySignalScheduler(PROGRESS_SIGNAL_DEFAULT_DELAY);

    if (delay is num) {
      showDelayedScheduler.schedule(delay.round());
    } else {
      DOM.show(<DOM.DomElement>[element]);
    }
  }

  void hide() {
    DOM.hide(<DOM.DomElement>[element]);
    showDelayedScheduler.cancel();
    progressSignal.clear();
  }
}
