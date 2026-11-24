// 1:1 port of vs/base/browser/dnd.ts
import 'dart:async' show Timer;

import 'dom.dart' show DomEvent, DomNode, addDisposableListener;
import '../common/lifecycle.dart' show Disposable;
import '../common/mime.dart' show Mimes;

/// Test/runtime seam mirroring the browser `setTimeout` / `clearTimeout` pair.
abstract class DndTimeoutHandle {
  int get milliseconds;
  bool get cancelled;
  void cancel();
}

class _TimerTimeoutHandle implements DndTimeoutHandle {
  final Timer _timer;
  @override
  final int milliseconds;
  @override
  bool cancelled = false;

  _TimerTimeoutHandle(this._timer, this.milliseconds);

  @override
  void cancel() {
    if (!cancelled) {
      cancelled = true;
      _timer.cancel();
    }
  }
}

DndTimeoutHandle Function(void Function() callback, int milliseconds)
    dndSetTimeout = (void Function() callback, int milliseconds) =>
        _TimerTimeoutHandle(
            Timer(Duration(milliseconds: milliseconds), callback), milliseconds);

void Function(DndTimeoutHandle handle) dndClearTimeout =
    (DndTimeoutHandle handle) => handle.cancel();

/// A helper that will execute a provided function when the provided HTMLElement receives
/// dragover event for 800ms. If the drag is aborted before, the callback will not be triggered.
class DelayedDragHandler extends Disposable {
  DndTimeoutHandle? timeout;

  DelayedDragHandler(DomNode container, void Function() callback) {
    register(addDisposableListener(container, 'dragover', (DomEvent e) {
      e.preventDefault(); // needed so that the drop event fires
      if (timeout == null) {
        timeout = dndSetTimeout(() {
          callback();
          timeout = null;
        }, 800);
      }
    }));

    for (final String type in const <String>['dragleave', 'drop', 'dragend']) {
      register(addDisposableListener(container, type, (DomEvent e) {
        clearDragTimeout();
      }));
    }
  }

  void clearDragTimeout() {
    final DndTimeoutHandle? current = timeout;
    if (current != null) {
      dndClearTimeout(current);
      timeout = null;
    }
  }

  @override
  void dispose() {
    super.dispose();
    clearDragTimeout();
  }
}

/// Common data transfers.
class DataTransfers {
  /// Application specific resource transfer type
  static const String RESOURCES = 'ResourceURLs';

  /// Browser specific transfer type to download
  static const String DOWNLOAD_URL = 'DownloadURL';

  /// Browser specific transfer type for files
  static const String FILES = 'Files';

  /// Typically transfer type for copy/paste transfers.
  static const String TEXT = Mimes.text;

  /// Internal type used to pass around text/uri-list data.
  static const String INTERNAL_URI_LIST = 'application/vnd.code.uri-list';

  const DataTransfers._();
}

/// 1:1: `interface IDragAndDropData`
abstract class IDragAndDropData {
  void update(Object dataTransfer);
  Object? getData();
}
