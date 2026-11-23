// ---------------------------------------------------------------------------
// Port of vscode/src/vs/editor/browser/gpu/gpuUtils.ts
// Translated 1:1 from TypeScript. `Float32Array` -> `Float32List`; the
// `if (!value)` check is JS truthiness (0 / '' / false also throw). The DOM
// `ResizeObserver` / `HTMLElement` / `Window` types are bridged through
// injectable function fields on [GpuDomBridge] (Dart has no DOM); this mirrors
// the `globalThis` bridge convention used elsewhere in the port.
// ---------------------------------------------------------------------------

import 'dart:typed_data';

import '../../../base/common/errors.dart' show BugIndicatingError;
import '../../../base/common/lifecycle.dart' show IDisposable, toDisposable;

/// 1:1: `export const quadVertices = new Float32Array([...])`
final Float32List quadVertices = Float32List.fromList(<double>[
  1, 0, //
  1, 1,
  0, 1,
  0, 0,
  0, 1,
  1, 0,
]);

/// 1:1: `export function ensureNonNullable<T>(value: T | null): T`
T ensureNonNullable<T>(T value) {
  // Source uses `if (!value)` — JS truthiness, not a null check.
  final bool falsy = value == null ||
      (value is bool && !value) ||
      (value is num && value == 0) ||
      (value is String && value.isEmpty);
  if (falsy) {
    throw Exception('Value "$value" cannot be null');
  }
  return value;
}

/// A single observed resize entry: the source reads `entry.target`, the
/// presence of `devicePixelContentBoxSize`, and its `[0].inlineSize/blockSize`.
class ResizeObserverEntry {
  final Object target;
  final bool hasDevicePixelContentBoxSize;
  final num inlineSize;
  final num blockSize;

  const ResizeObserverEntry({
    required this.target,
    required this.hasDevicePixelContentBoxSize,
    this.inlineSize = 0,
    this.blockSize = 0,
  });
}

/// The DOM surface used by [observeDevicePixelDimensions], supplied by the
/// embedder (Dart has no DOM). Callbacks mirror the ResizeObserver shape.
class GpuDomBridge {
  /// Creates an observer whose callback receives entries; returns an opaque
  /// observer handle. Mirrors `new parentWindow.ResizeObserver(callback)`.
  final Object Function(void Function(List<ResizeObserverEntry>) callback)
      createResizeObserver;

  /// Mirrors `observer.observe(element, { box: ['device-pixel-content-box'] })`.
  final void Function(Object observer, Object element) observe;

  /// Mirrors `observer.disconnect()`.
  final void Function(Object observer) disconnect;

  GpuDomBridge({
    required this.createResizeObserver,
    required this.observe,
    required this.disconnect,
  });
}

/// 1:1: `observeDevicePixelDimensions(element, parentWindow, callback)`
/// The `parentWindow.ResizeObserver` dependency is supplied via [bridge]
/// instead of a DOM `Window` argument (Dart has no DOM). The [element] is an
/// opaque target object compared by identity against `entry.target`.
IDisposable observeDevicePixelDimensions(
  Object element,
  GpuDomBridge bridge,
  void Function(num deviceWidth, num deviceHeight) callback,
) {
  // Source: `let observer = new ResizeObserver(callback)` where the callback
  // closes over `observer`. Dart needs a `late` declaration first so the
  // closure can reference the variable that is assigned below.
  late Object? observer;
  observer = bridge.createResizeObserver((List<ResizeObserverEntry> entries) {
    ResizeObserverEntry? entry;
    for (final ResizeObserverEntry e in entries) {
      if (identical(e.target, element)) {
        entry = e;
        break;
      }
    }
    if (entry == null) {
      return;
    }

    // Disconnect if devicePixelContentBoxSize isn't supported by the browser
    if (!entry.hasDevicePixelContentBoxSize) {
      bridge.disconnect(observer!);
      observer = null;
      return;
    }

    // Fire the callback, ignore events where the dimensions are 0x0 as the canvas is likely hidden
    final num width = entry.inlineSize;
    final num height = entry.blockSize;
    if (width > 0 && height > 0) {
      callback(width, height);
    }
  });
  final Object createdObserver = observer!;
  try {
    bridge.observe(createdObserver, element);
  } catch (_) {
    bridge.disconnect(createdObserver);
    observer = null;
    throw BugIndicatingError('Could not observe device pixel dimensions');
  }
  return toDisposable(() {
    // 1:1: `observer?.disconnect()`
    if (observer != null) {
      bridge.disconnect(observer!);
    }
  });
}
