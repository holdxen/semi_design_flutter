// ---------------------------------------------------------------------------
// Port of vscode/src/vs/base/common/paging.ts
// Translated 1:1 from TypeScript.
//
// Platform adaptations:
//   - `Promise<T>` -> `Future<T>`
//   - `interface` -> `abstract class`
//   - `Event.None` -> top-level `eventNone`
//   - `setTimeout` / `clearTimeout` -> `Timer`
//   - `Math.ceil/floor` -> `num.ceil()/floor()`
// ---------------------------------------------------------------------------

import 'dart:async';

import 'arrays.dart' as arrays;
import 'cancellation.dart' as cancellation;
import 'errors.dart' as errors;
import 'event.dart' as event;
import 'lifecycle.dart' as lifecycle;

/// 1:1: `export interface IPager<T>`
abstract class IPager<T> {
  List<T> get firstPage;
  int get total;
  int get pageSize;
  Future<List<T>> getPage(
      int pageIndex, cancellation.CancellationToken cancellationToken);
}

/// 1:1: `export interface IIterativePage<T>`
abstract class IIterativePage<T> {
  List<T> get items;
  bool get hasMore;
}

/// 1:1: `export interface IIterativePager<T>`
abstract class IIterativePager<T> {
  IIterativePage<T> get firstPage;
  Future<IIterativePage<T>> getNextPage(
      cancellation.CancellationToken cancellationToken);
}

/// 1:1: `export interface IPageIterator<T>`
abstract class IPageIterator<T> {
  List<T> get elements;
  int get total;
  bool get hasNextPage;
  Future<IPageIterator<T>> getNextPage(
      cancellation.CancellationToken cancellationToken);
}

/// 1:1: `interface IPage<T>`
class IPage<T> {
  bool isResolved;
  Future<void>? promise;
  cancellation.CancellationTokenSource? cts;
  final Set<int> promiseIndexes;
  List<T> elements;

  IPage({
    required this.isResolved,
    required this.promise,
    required this.cts,
    required this.promiseIndexes,
    required this.elements,
  });
}

/// 1:1: `function createPage<T>`
IPage<T> createPage<T>([List<T>? elements]) {
  return IPage<T>(
    isResolved: elements != null,
    promise: null,
    cts: null,
    promiseIndexes: <int>{},
    elements: elements ?? <T>[],
  );
}

/// 1:1: `export interface IPagedModel<T>`
abstract class IPagedModel<T> {
  int get length;
  event.Event<num> get onDidIncrementLength;
  bool isResolved(int index);
  T get(int index);
  Future<T> resolve(
      int index, cancellation.CancellationToken cancellationToken);
}

/// 1:1: `export function singlePagePager<T>`
IPager<T> singlePagePager<T>(List<T> elements) {
  return _SinglePagePager<T>(elements);
}

class _SinglePagePager<T> implements IPager<T> {
  final List<T> elements;

  _SinglePagePager(this.elements);

  @override
  List<T> get firstPage => elements;

  @override
  int get total => elements.length;

  @override
  int get pageSize => elements.length;

  @override
  Future<List<T>> getPage(
      int pageIndex, cancellation.CancellationToken cancellationToken) async {
    return elements;
  }
}

/// 1:1: `export class PagedModel<T>`
class PagedModel<T> implements IPagedModel<T> {
  late IPager<T> pager;
  List<IPage<T>> pages = <IPage<T>>[];

  @override
  int get length => pager.total;

  @override
  final event.Event<num> onDidIncrementLength = event.eventNone;

  PagedModel(Object arg) {
    pager = arg is List<T> ? singlePagePager<T>(arg) : arg as IPager<T>;

    final int totalPages = (pager.total / pager.pageSize).ceil();

    pages = <IPage<T>>[
      createPage<T>(List<T>.from(pager.firstPage)),
      ...arrays.range(totalPages - 1).map((int _) => createPage<T>()),
    ];
  }

  @override
  bool isResolved(int index) {
    final int pageIndex = (index / pager.pageSize).floor();
    final IPage<T> page = pages[pageIndex];
    return page.isResolved;
  }

  @override
  T get(int index) {
    final int pageIndex = (index / pager.pageSize).floor();
    final int indexInPage = index % pager.pageSize;
    final IPage<T> page = pages[pageIndex];
    return page.elements[indexInPage];
  }

  @override
  Future<T> resolve(
      int index, cancellation.CancellationToken cancellationToken) async {
    if (cancellationToken.isCancellationRequested) {
      return Future<T>.error(errors.CancellationError());
    }

    final int pageIndex = (index / pager.pageSize).floor();
    final int indexInPage = index % pager.pageSize;
    final IPage<T> page = pages[pageIndex];

    if (page.isResolved) {
      return page.elements[indexInPage];
    }

    if (page.promise == null) {
      final cancellation.CancellationTokenSource cts =
          cancellation.CancellationTokenSource();
      page.cts = cts;
      page.promise = pager.getPage(pageIndex, cts.token).then(
        (List<T> elements) {
          page.elements = elements;
          page.isResolved = true;
          page.promise = null;
          page.cts = null;
        },
        onError: (Object err) {
          page.isResolved = false;
          page.promise = null;
          page.cts = null;
          return Future<void>.error(err);
        },
      );
    }

    final Future<void> pagePromise = page.promise!;
    final lifecycle.IDisposable listener =
        cancellationToken.onCancellationRequested((Object? _) {
      final cancellation.CancellationTokenSource? cts = page.cts;
      if (cts == null) {
        return;
      }
      page.promiseIndexes.remove(index);
      if (page.promiseIndexes.isEmpty) {
        cts.cancel();
      }
    });

    page.promiseIndexes.add(index);

    return pagePromise
        .then((_) => page.elements[indexInPage])
        .whenComplete(listener.dispose);
  }
}

/// 1:1: `export class DelayedPagedModel<T>`
class DelayedPagedModel<T> implements IPagedModel<T> {
  final IPagedModel<T> model;
  final int timeout;

  DelayedPagedModel(this.model, [this.timeout = 500]);

  @override
  int get length => model.length;

  @override
  event.Event<num> get onDidIncrementLength => model.onDidIncrementLength;

  @override
  bool isResolved(int index) => model.isResolved(index);

  @override
  T get(int index) => model.get(index);

  @override
  Future<T> resolve(
      int index, cancellation.CancellationToken cancellationToken) {
    final Completer<T> c = Completer<T>();
    if (cancellationToken.isCancellationRequested) {
      c.completeError(errors.CancellationError());
      return c.future;
    }

    late final Timer timer;
    late final lifecycle.IDisposable timeoutCancellation;
    timeoutCancellation = cancellationToken.onCancellationRequested((Object? _) {
      timer.cancel();
      timeoutCancellation.dispose();
      if (!c.isCompleted) {
        c.completeError(errors.CancellationError());
      }
    });

    timer = Timer(Duration(milliseconds: timeout), () {
      if (cancellationToken.isCancellationRequested) {
        if (!c.isCompleted) {
          c.completeError(errors.CancellationError());
        }
        return;
      }
      timeoutCancellation.dispose();
      model.resolve(index, cancellationToken).then(c.complete, onError: c.completeError);
    });

    return c.future;
  }
}

/// 1:1: `export class PageIteratorPager<T>`
class PageIteratorPager<T> implements IPager<T> {
  final List<List<T>> cachedPages = <List<T>>[];
  IPageIterator<T> currentIterator;
  bool isComplete = false;
  final Map<int, Future<void>> pendingRequests = <int, Future<void>>{};

  @override
  final List<T> firstPage;
  @override
  final int pageSize;
  @override
  final int total;

  PageIteratorPager(IPageIterator<T> initialIterator)
      : currentIterator = initialIterator,
        firstPage = List<T>.from(initialIterator.elements),
        pageSize = initialIterator.elements.isNotEmpty
            ? initialIterator.elements.length
            : 1,
        total = initialIterator.total {
    cachedPages[0] = firstPage;
    isComplete = !initialIterator.hasNextPage;
  }

  @override
  Future<List<T>> getPage(
      int pageIndex, cancellation.CancellationToken cancellationToken) async {
    if (cancellationToken.isCancellationRequested) {
      throw errors.CancellationError();
    }

    if (pageIndex < cachedPages.length) {
      return cachedPages[pageIndex];
    }

    if (isComplete) {
      throw StateError(
          'Page $pageIndex is out of bounds. Total pages: ${cachedPages.length}');
    }

    Future<void>? pending;
    for (final MapEntry<int, Future<void>> entry in pendingRequests.entries) {
      if (entry.key >= pageIndex) {
        pending = entry.value;
        break;
      }
    }

    pending ??= loadPagesUntil(pageIndex, cancellationToken);
    pendingRequests[pageIndex] = pending;

    try {
      await pending;
      if (pageIndex >= cachedPages.length) {
        throw StateError(
            'Page $pageIndex is out of bounds. Total pages: ${cachedPages.length}');
      }
      return cachedPages[pageIndex];
    } finally {
      pendingRequests.remove(pageIndex);
    }
  }

  Future<void> loadPagesUntil(
      int targetPageIndex, cancellation.CancellationToken cancellationToken) async {
    while (targetPageIndex >= cachedPages.length && currentIterator.hasNextPage) {
      if (cancellationToken.isCancellationRequested) {
        throw errors.CancellationError();
      }
      currentIterator =
          await currentIterator.getNextPage(cancellationToken);
      cachedPages.add(List<T>.from(currentIterator.elements));
    }
    if (!currentIterator.hasNextPage) {
      isComplete = true;
    }
  }
}

/// 1:1: `export class IterativePagedModel<T>`
class IterativePagedModel<T> implements IPagedModel<T> {
  List<T> items = <T>[];
  bool _hasNextPage = true;
  final event.Emitter<num> _onDidIncrementLength = event.Emitter<num>();
  Future<void>? loadingPromise;

  final IIterativePager<T> pager;

  IterativePagedModel(this.pager) {
    items = List<T>.from(pager.firstPage.items);
    _hasNextPage = pager.firstPage.hasMore;
  }

  @override
  event.Event<num> get onDidIncrementLength => _onDidIncrementLength.event;

  /// Returns actual length + 1 if there are more pages (sentinel approach).
  @override
  int get length => items.length + (_hasNextPage ? 1 : 0);

  /// Sentinel item is never resolved - it triggers loading.
  @override
  bool isResolved(int index) {
    if (index == items.length && _hasNextPage) {
      return false;
    }
    return index < items.length;
  }

  @override
  T get(int index) {
    if (index < items.length) {
      return items[index];
    }
    throw StateError('Item not resolved yet');
  }

  /// When sentinel item is accessed, load next page.
  @override
  Future<T> resolve(
      int index, cancellation.CancellationToken cancellationToken) async {
    if (cancellationToken.isCancellationRequested) {
      return Future<T>.error(errors.CancellationError());
    }

    if (index == items.length && _hasNextPage) {
      await loadNextPage(cancellationToken);
    }

    if (index < items.length) {
      return items[index];
    }

    throw StateError('Index out of bounds');
  }

  Future<void> loadNextPage(
      cancellation.CancellationToken cancellationToken) async {
    if (!_hasNextPage) {
      return;
    }

    if (loadingPromise != null) {
      await loadingPromise;
      return;
    }

    final Future<IIterativePage<T>> pagePromise =
        pager.getNextPage(cancellationToken);

    loadingPromise = pagePromise.then(
      (IIterativePage<T> page) {
        items.addAll(page.items);
        _hasNextPage = page.hasMore;
        loadingPromise = null;
        _onDidIncrementLength.fire(length);
      },
      onError: (Object err) {
        loadingPromise = null;
        return Future<void>.error(err);
      },
    );

    await loadingPromise;
  }

  void dispose() {
    _onDidIncrementLength.dispose();
  }
}

/// 1:1: `export function mapPager<T, R>`
IPager<R> mapPager<T, R>(IPager<T> pager, R Function(T t) fn) {
  return _MappedPager<T, R>(pager, fn);
}

class _MappedPager<T, R> implements IPager<R> {
  final IPager<T> pager;
  final R Function(T t) fn;

  _MappedPager(this.pager, this.fn);

  @override
  List<R> get firstPage => pager.firstPage.map(fn).toList();

  @override
  int get total => pager.total;

  @override
  int get pageSize => pager.pageSize;

  @override
  Future<List<R>> getPage(
      int pageIndex, cancellation.CancellationToken token) async {
    final List<T> result = await pager.getPage(pageIndex, token);
    return result.map(fn).toList();
  }
}
