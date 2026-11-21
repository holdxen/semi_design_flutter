// Port of `packages/core/src/common/image-window-loader.ts` plus
// `internal/data-grid/image-window-loader-interface.ts`.
//
// Web decodes into `HTMLImageElement`s pooled from `imgPool` and evicts the
// cache entries whose cells fall outside the visible window. Flutter's
// equivalent of `<img src>` is [GlideNetworkImageLoader], which resolves
// through [NetworkImage] and hands back a `ui.Image` the painter can
// `drawImageRect`.
//
// Two deliberate differences:
// - Decoding goes through [GlideImageLoader] so tests (and callers with their
//   own image pipeline) can swap it out.
// - Eviction drops the entry but never calls `ui.Image.dispose()`: images
//   resolved through [NetworkImage] belong to `PaintingBinding.imageCache`,
//   which owns their lifetime and bounds them with its own LRU. Dropping our
//   reference is enough, because a later draw simply resolves again.
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/painting.dart';

import '../internal/data_grid/glide_cell_set.dart';
import '../internal/data_grid/glide_types.dart';

/// Starts loading [url] and calls [onComplete] exactly once with the decoded
/// image, or null on failure. The returned function cancels the load.
typedef GlideImageLoad = void Function(
  String url,
  void Function(ui.Image? image) onComplete,
);

/// Streams currently listening, keyed by URL, so eviction can detach them.
final Map<String, (ImageStream, ImageStreamListener)> _activeNetworkLoads = {};

/// The default [GlideImageLoad]: [NetworkImage] through Flutter's image cache.
void glideLoadNetworkImage(
  String url,
  void Function(ui.Image? image) onComplete,
) {
  final stream = NetworkImage(url).resolve(ImageConfiguration.empty);
  late final ImageStreamListener listener;
  listener = ImageStreamListener(
    (info, _) => onComplete(info.image),
    onError: (_, _) => onComplete(null),
  );
  stream.addListener(listener);
  _activeNetworkLoads[url] = (stream, listener);
}

void _cancelNetworkLoad(String url) {
  final active = _activeNetworkLoads.remove(url);
  if (active != null) active.$1.removeListener(active.$2);
}

class _ImageEntry {
  _ImageEntry(this.url, this.cells);

  final String url;
  final List<GlideItem> cells;
  ui.Image? image;
  bool failed = false;
  void Function()? cancel;
}

/// `ImageWindowLoader` (`image-window-loader-interface.ts:6-10`).
class GlideImageWindowLoader {
  GlideImageWindowLoader({this.loadImage = glideLoadNetworkImage});

  final GlideImageLoad loadImage;

  final Map<String, _ImageEntry> _cache = {};
  final List<GlideItem> _loadedLocations = [];

  /// `setCallback` (`image-window-loader.ts:18-20`): called with every cell
  /// whose image just finished decoding, so the grid can repaint them.
  void Function(GlideCellSet locations)? onLoaded;

  GlideRectangle _window = const GlideRectangle.empty();
  int _freezeCols = 0;
  List<int> _freezeRows = const [];

  /// Number of distinct URLs currently tracked; exposed for tests.
  int get cachedCount => _cache.length;

  /// `setWindow` (`image-window-loader.ts:52-66`).
  void setWindow(GlideRectangle window, int freezeCols, List<int> freezeRows) {
    if (window == _window &&
        freezeCols == _freezeCols &&
        listEquals(freezeRows, _freezeRows)) {
      return;
    }
    _window = window;
    _freezeCols = freezeCols;
    _freezeRows = freezeRows;
    _clearOutOfWindow();
  }

  bool _isInWindow(GlideItem cell) {
    final colInWindow =
        (cell.col >= _window.x && cell.col <= _window.x + _window.width) ||
        cell.col < _freezeCols;
    final rowInWindow =
        (cell.row >= _window.y && cell.row <= _window.y + _window.height) ||
        _freezeRows.contains(cell.row);
    return colInWindow && rowInWindow;
  }

  /// `clearOutOfWindow` (`image-window-loader.ts:27-47`).
  void _clearOutOfWindow() {
    final stale = <String>[];
    for (final entry in _cache.values) {
      final visible = entry.cells.where(_isInWindow).toList();
      if (visible.isEmpty) {
        stale.add(entry.url);
      } else {
        entry.cells
          ..clear()
          ..addAll(visible);
      }
    }
    for (final url in stale) {
      final entry = _cache.remove(url);
      if (entry == null) continue;
      entry.cancel?.call();
      _cancelNetworkLoad(url);
      // The image itself is not disposed: see the file header.
    }
  }

  /// `loadOrGetImage` (`image-window-loader.ts:80-94`): returns the image when
  /// it is already decoded and kicks off a load otherwise, so the first frame
  /// of every image simply draws nothing.
  ui.Image? loadOrGetImage(String url, int col, int row) {
    if (url.isEmpty) return null;
    final existing = _cache[url];
    if (existing != null) {
      final cell = GlideItem(col, row);
      if (!existing.cells.contains(cell)) existing.cells.add(cell);
      return existing.failed ? null : existing.image;
    }

    final entry = _ImageEntry(url, [GlideItem(col, row)]);
    _cache[url] = entry;
    loadImage(url, (image) {
      if (!identical(_cache[url], entry)) return; // evicted while loading
      if (image == null) {
        entry.failed = true;
        return;
      }
      entry.image = image;
      _flushLoaded(entry);
    });
    return null;
  }

  /// `sendLoaded` (`image-window-loader.ts:63-67`): upstream throttles to
  /// 20ms, but `setState` already coalesces within a frame here.
  void _flushLoaded(_ImageEntry entry) {
    final callback = onLoaded;
    if (callback == null) return;
    _loadedLocations.addAll(entry.cells);
    if (_loadedLocations.isEmpty) return;
    final locations = GlideCellSet(_loadedLocations);
    _loadedLocations.clear();
    callback(locations);
  }

  void dispose() {
    for (final entry in _cache.values) {
      entry.cancel?.call();
      _cancelNetworkLoad(entry.url);
    }
    _cache.clear();
    onLoaded = null;
  }
}
