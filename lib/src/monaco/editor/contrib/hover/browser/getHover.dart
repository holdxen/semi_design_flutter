// ---------------------------------------------------------------------------
// Port of vscode/src/vs/editor/contrib/hover/browser/getHover.ts
// Translated 1:1. Erased interfaces (`IHoverProvider`, `Hover`, `ITextModel`,
// cancellation/registration services) are reduced to the members read here.
// ---------------------------------------------------------------------------
import 'dart:async';

import '../../../../base/common/async.dart'
    show AsyncIterableProducer, IAsyncIterable, IAsyncIterator, IteratorResult;
import '../../../../base/common/cancellation.dart' show CancellationToken;
import '../../../../base/common/errors.dart' show onUnexpectedExternalError;
import '../../../common/core/position.dart' show Position;

/// 1:1: `Hover` (erased interface) carrier.
class HoverForGetHover {
  final Object? range;
  final List<Object?>? contents;

  HoverForGetHover(this.range, this.contents);
}

/// 1:1: `HoverProvider.provideHover` member.
abstract class IHoverProviderForGetHover {
  FutureOr<Object?> provideHover(
      Object model, Position position, CancellationToken token);
}

/// 1:1: `LanguageFeatureRegistry.ordered` member.
abstract class IHoverProviderRegistry {
  List<IHoverProviderForGetHover> ordered(Object model, [bool recursive = false]);
}

/// 1:1: `export class HoverProviderResult`.
class HoverProviderResult {
  final IHoverProviderForGetHover provider;
  final HoverForGetHover hover;
  final int ordinal;

  HoverProviderResult(this.provider, this.hover, this.ordinal);
}

/// 1:1: `registerModelAndPositionCommand` (environment bridge).
void Function(String id, Function handler) registerModelAndPositionCommandForHover =
    (String id, Function handler) {};

/// Does not throw or return a rejected future (returns null instead).
Future<HoverProviderResult?> executeProvider(
    IHoverProviderForGetHover provider,
    int ordinal,
    Object model,
    Position position,
    CancellationToken token) async {
  Object? result;
  try {
    result = await provider.provideHover(model, position, token);
  } catch (e) {
    onUnexpectedExternalError(e);
  }
  if (result == null || !isValid(result as HoverForGetHover)) {
    return null;
  }
  return HoverProviderResult(provider, result, ordinal);
}

bool isValid(HoverForGetHover result) {
  final bool hasRange = result.range != null;
  final bool hasHtmlContent =
      result.contents != null && result.contents!.isNotEmpty;
  return hasRange && hasHtmlContent;
}

/// 1:1: `export function getHoverProviderResultsAsAsyncIterable`.
IAsyncIterable<HoverProviderResult> getHoverProviderResultsAsAsyncIterable(
  IHoverProviderRegistry registry,
  Object model,
  Position position,
  CancellationToken token, [
  bool recursive = false,
]) {
  final List<IHoverProviderForGetHover> providers =
      registry.ordered(model, recursive);
  final List<Future<HoverProviderResult?>> promises = <Future<HoverProviderResult?>>[];
  for (int i = 0; i < providers.length; i++) {
    promises.add(executeProvider(providers[i], i, model, position, token));
  }
  // Dart reifies generic arguments, so `coalesce()`'s internal cast from
  // `IAsyncIterable<T?>` to `IAsyncIterable<T>` fails. A local typed iterator
  // performs the same null-filtering.
  return _CoalescedHoverResults(
      AsyncIterableProducer.fromPromisesResolveOrder<HoverProviderResult?>(
          promises));
}


class _CoalescedHoverResults implements IAsyncIterable<HoverProviderResult> {
  final IAsyncIterable<HoverProviderResult?> _source;

  _CoalescedHoverResults(this._source);

  @override
  IAsyncIterator<HoverProviderResult> asyncIterator() =>
      _CoalescedHoverIterator(_source.asyncIterator());
}

class _CoalescedHoverIterator implements IAsyncIterator<HoverProviderResult> {
  final IAsyncIterator<HoverProviderResult?> _source;

  _CoalescedHoverIterator(this._source);

  @override
  Future<IteratorResult<HoverProviderResult>> next() async {
    while (true) {
      final IteratorResult<HoverProviderResult?> result = await _source.next();
      if (result.done || result.value != null) {
        return IteratorResult<HoverProviderResult>(result.done, result.value);
      }
    }
  }

  @override
  Future<IteratorResult<HoverProviderResult>>? throwError(Object e) =>
      _source.throwError(e) as Future<IteratorResult<HoverProviderResult>>?;

  @override
  Future<IteratorResult<HoverProviderResult>>? returnValue() =>
      _source.returnValue() as Future<IteratorResult<HoverProviderResult>>?;
}

/// 1:1: `export async function getHoversPromise`.
Future<List<HoverForGetHover>> getHoversPromise(
  IHoverProviderRegistry registry,
  Object model,
  Position position,
  CancellationToken token, [
  bool recursive = false,
]) async {
  final List<HoverForGetHover> out = <HoverForGetHover>[];
  final IAsyncIterable<HoverProviderResult> iterable =
      getHoverProviderResultsAsAsyncIterable(
          registry, model, position, token, recursive);
  final IAsyncIterator<HoverProviderResult> it = iterable.asyncIterator();
  while (true) {
    final IteratorResult<HoverProviderResult> result = await it.next();
    if (result.done) {
      break;
    }
    out.add(result.value!.hover);
  }
  return out;
}

/// 1:1 top-level side effects: two `registerModelAndPositionCommand` calls.
final Object registration = () {
  registerModelAndPositionCommandForHover(
      '_executeHoverProvider', (accessor, model, position) {
    final dynamic features = accessor.get(Object);
    return getHoversPromise(
        features.hoverProvider as IHoverProviderRegistry,
        model as Object,
        position as Position,
        CancellationToken.none);
  });
  registerModelAndPositionCommandForHover(
      '_executeHoverProvider_recursive', (accessor, model, position) {
    final dynamic features = accessor.get(Object);
    return getHoversPromise(
        features.hoverProvider as IHoverProviderRegistry,
        model as Object,
        position as Position,
        CancellationToken.none,
        true);
  });
  return true;
}();
