// Port of `packages/core/src/common/image-window-loader.ts` plus
// `internal/data-grid/image-window-loader-interface.ts`.
//
// Web decodes into `HTMLImageElement`s pooled from `imgPool` and evicts the
// cache entries whose cells fall outside the visible window. Flutter's
// equivalent of `<img src>` is [SemiNetworkImageLoader], which resolves
// through [NetworkImage] and hands back a `ui.Image` the painter can
// `drawImageRect`.
//
// The default loader owns the image handles delivered to its stream listener.
// Injected loaders retain ownership of the images they supply.
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/painting.dart';

import '../internal/data_grid/semi_cell_set.dart';
import '../internal/data_grid/semi_types.dart';

/// Starts loading [url] and calls [onComplete] with a decoded image or null
/// on failure. The caller supplying this function retains image ownership.
typedef SemiImageLoad = void Function(
  String url,
  void Function(ui.Image? image) onComplete,
);

/// Resolves through Flutter's image cache. The receiver owns the image handle.
void semiLoadNetworkImage(
  String url,
  void Function(ui.Image? image) onComplete,
) {
  _startNetworkLoad(url, onComplete);
}

void Function() _startNetworkLoad(
  String url,
  void Function(ui.Image? image) onComplete,
) {
  final stream = NetworkImage(url).resolve(ImageConfiguration.empty);
  var finished = false;
  late final ImageStreamListener listener;
  void cancel() {
    if (finished) return;
    finished = true;
    stream.removeListener(listener);
  }

  listener = ImageStreamListener(
    (info, _) {
      cancel();
      onComplete(info.image);
    },
    onError: (_, _) {
      cancel();
      onComplete(null);
    },
  );
  stream.addListener(listener);
  return cancel;
}

class _ImageEntry {
  _ImageEntry(this.url, this.cells);

  final String url;
  final List<SemiItem> cells;
  ui.Image? image;
  bool failed = false;
  void Function()? cancel;
}

/// `ImageWindowLoader` (`image-window-loader-interface.ts:6-10`).
class SemiImageWindowLoader {
  SemiImageWindowLoader({this.loadImage = semiLoadNetworkImage});

  final SemiImageLoad loadImage;

  final Map<String, _ImageEntry> _cache = {};
  final List<SemiItem> _loadedLocations = [];

  /// `setCallback` (`image-window-loader.ts:18-20`): called with every cell
  /// whose image just finished decoding, so the grid can repaint them.
  void Function(SemiCellSet locations)? onLoaded;

  SemiRectangle _window = const SemiRectangle.empty();
  int _freezeCols = 0;
  List<int> _freezeRows = const [];

  /// Number of distinct URLs currently tracked; exposed for tests.
  int get cachedCount => _cache.length;

  /// `setWindow` (`image-window-loader.ts:52-66`).
  void setWindow(SemiRectangle window, int freezeCols, List<int> freezeRows) {
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

  bool _isInWindow(SemiItem cell) {
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
      _releaseEntry(entry);
    }
  }

  /// `loadOrGetImage` (`image-window-loader.ts:80-94`): returns the image when
  /// it is already decoded and kicks off a load otherwise, so the first frame
  /// of every image simply draws nothing.
  ui.Image? loadOrGetImage(String url, int col, int row) {
    if (url.isEmpty) return null;
    final existing = _cache[url];
    if (existing != null) {
      final cell = SemiItem(col, row);
      if (!existing.cells.contains(cell)) existing.cells.add(cell);
      return existing.failed ? null : existing.image;
    }

    final entry = _ImageEntry(url, [SemiItem(col, row)]);
    _cache[url] = entry;
    void complete(ui.Image? image) {
      if (!identical(_cache[url], entry)) {
        if (_ownsImages) image?.dispose();
        return;
      }
      if (image == null) {
        entry.failed = true;
        return;
      }
      entry.image = image;
      _flushLoaded(entry);
    }

    if (_ownsImages) {
      entry.cancel = _startNetworkLoad(url, complete);
    } else {
      loadImage(url, complete);
    }
    return null;
  }

  bool get _ownsImages => identical(loadImage, semiLoadNetworkImage);

  void _releaseEntry(_ImageEntry entry) {
    entry.cancel?.call();
    if (_ownsImages) entry.image?.dispose();
  }

  /// `sendLoaded` (`image-window-loader.ts:63-67`): upstream throttles to
  /// 20ms, but `setState` already coalesces within a frame here.
  void _flushLoaded(_ImageEntry entry) {
    final callback = onLoaded;
    if (callback == null) return;
    _loadedLocations.addAll(entry.cells);
    if (_loadedLocations.isEmpty) return;
    final locations = SemiCellSet(_loadedLocations);
    _loadedLocations.clear();
    callback(locations);
  }

  void dispose() {
    for (final entry in _cache.values) {
      _releaseEntry(entry);
    }
    _cache.clear();
    onLoaded = null;
  }
}
