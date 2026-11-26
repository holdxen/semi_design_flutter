// ---------------------------------------------------------------------------
// Port of vscode/src/vs/editor/contrib/inlayHints/browser/inlayHints.ts
// Translated 1:1. Structure, members and semantics preserved.
// Verified against the TypeScript transpile truth (batch438).
//
// Adaptations: InlayHint / InlayHintList / providers / model / registry are
// opaque carriers so the logic compiles and can be replay-tested.
// ---------------------------------------------------------------------------

import 'dart:convert';

import '../../../../base/common/cancellation.dart' show CancellationToken;
import '../../../../base/common/errors.dart'
    show CancellationError, onUnexpectedExternalError;
import '../../../../base/common/network.dart' show Schemas;
import '../../../../base/common/uri.dart' show URI, UriComponents;
import '../../../../base/common/lifecycle.dart' show DisposableStore;
import '../../../common/core/position.dart' show IPosition, Position;
import '../../../common/core/range.dart' show Range;

/// Injectable error reporter. Production defaults to the real handler; replay
/// installs a silent collector. Mirrors the TS `onUnexpectedExternalError`.
void Function(Object?) reportUnexpectedError = onUnexpectedExternalError;

/// 1:1: `Command` carrier (opaque; fields read by [asCommandLink]).
class CommandLike {
  final String id;
  final List<Object?>? arguments;
  CommandLike(this.id, [this.arguments]);
}

/// 1:1: `InlayHintAnchor`.
class InlayHintAnchor {
  final Range range;
  final String direction; // 'before' | 'after'

  InlayHintAnchor(this.range, this.direction);
}

/// 1:1: `InlayHintItem`.
class InlayHintItem {
  final Object hint;
  final InlayHintAnchor anchor;
  final Object provider;
  bool _isResolved = false;
  Future<void>? _currentResolve;

  InlayHintItem(this.hint, this.anchor, this.provider);

  InlayHintItem withAnchor(InlayHintAnchor deltaAnchor) {
    final InlayHintItem result = InlayHintItem(hint, deltaAnchor, provider);
    result._isResolved = _isResolved;
    result._currentResolve = _currentResolve;
    return result;
  }

  Future<void> resolve(CancellationToken token) async {
    final dynamic p = provider;
    Object? resolveFn;
    try {
      resolveFn = p.resolveInlayHint;
    } catch (_) {
      // no resolveInlayHint member (TS: typeof ... !== 'function')
      return;
    }
    if (resolveFn == null) {
      return;
    }
    if (_currentResolve != null) {
      // wait for an active resolve operation and try again when that's done.
      await _currentResolve;
      if (token.isCancellationRequested) {
        return;
      }
      return resolve(token);
    }
    if (!_isResolved) {
      final Future<void> future = _doResolve(token);
      _currentResolve = future.whenComplete(() => _currentResolve = null);
    }
    await _currentResolve;
  }

  Future<void> _doResolve(CancellationToken token) async {
    try {
      final dynamic p = provider;
      final Object? newHint = await (p.resolveInlayHint(hint, token) as Future);
      final dynamic h = hint;
      final dynamic n = newHint;
      if (n != null) {
        if (n.tooltip != null) h.tooltip = n.tooltip;
        if (n.label != null) h.label = n.label;
        if (n.textEdits != null) h.textEdits = n.textEdits;
      }
      _isResolved = true;
    } catch (err) {
      reportUnexpectedError(err);
      _isResolved = false;
    }
  }
}

/// 1:1: `InlayHintsFragments`.
class InlayHintsFragments {
  static final Object _emptyInlayHintList = _EmptyInlayHintList();

  final DisposableStore _disposables = DisposableStore();
  final List<InlayHintItem> items;
  final List<Range> ranges;
  final Set<Object> providers;

  InlayHintsFragments(this.ranges, this.items, this.providers);

  /// 1:1: `InlayHintsFragments.create`.
  static Future<InlayHintsFragments> create(
    Object registry,
    Object model,
    List<Range> ranges,
    CancellationToken token,
  ) async {
    final List<List<Object>> data = <List<Object>>[];

    final List<Object> providers = (registry as dynamic).ordered(model) as List<Object>;
    final Iterable<Object> reversed = providers.reversed;
    final List<Future<void>> all = <Future<void>>[];
    for (final Object provider in reversed) {
      for (final Range range in ranges) {
        all.add(_provideOne(provider, model, range, token, data));
      }
    }
    await Future.wait(all);

    if (token.isCancellationRequested || (model as dynamic).isDisposed()) {
      throw CancellationError();
    }

    final Set<Object> providerSet = <Object>{};
    final List<InlayHintItem> items = <InlayHintItem>[];
    for (final List<Object> entry in data) {
      final Object list = entry[0];
      final Object provider = entry[1];
      _disposablesAdd(list);
      providerSet.add(provider);
      final List<dynamic> hints = (list as dynamic).hints as List<dynamic>;
      for (final dynamic hint in hints) {
        final Position position =
            (model as dynamic).validatePosition(hint.position) as Position;
        String direction = 'before';
        final Range wordRange = _getRangeAtPosition(model, position);
        late Range range;
        if (_isBefore(wordRange.getStartPosition(), position)) {
          range = Range.fromPositions(wordRange.getStartPosition(), end: position);
          direction = 'after';
        } else {
          range = Range.fromPositions(position, end: wordRange.getEndPosition());
          direction = 'before';
        }
        items.add(InlayHintItem(
          hint as Object,
          InlayHintAnchor(range, direction),
          provider,
        ));
      }
    }
    items.sort((InlayHintItem a, InlayHintItem b) =>
        Position.compare((a.hint as dynamic).position as IPosition,
            (b.hint as dynamic).position as IPosition));

    return InlayHintsFragments(ranges, items, providerSet);
  }

  // Module-level disposable store for lists added during create (source keeps
  // this as an instance field created before items). Mirrors dispose semantics.
  static final DisposableStore _createDisposables = DisposableStore();
  static void _disposablesAdd(Object list) => _createDisposables.add(list as dynamic);

  static Future<void> _provideOne(
    Object provider,
    Object model,
    Range range,
    CancellationToken token,
    List<List<Object>> data,
  ) async {
    try {
      final Object? result = await ((provider as dynamic).provideInlayHints(
              model, range, token) as Future<Object?>);
      final List<dynamic>? hints = result == null ? null : (result as dynamic).hints as List<dynamic>?;
      final bool hasOnDidChange =
          (provider as dynamic).onDidChangeInlayHints != null;
      if ((hints != null && hints.isNotEmpty) || hasOnDidChange) {
        data.add(<Object>[result ?? _emptyInlayHintList, provider]);
      }
    } catch (err) {
      reportUnexpectedError(err);
    }
  }

  static bool _isBefore(IPosition a, IPosition b) => Position.isBeforeStatic(a, b);

  /// 1:1: `_getRangeAtPosition`.
  static Range _getRangeAtPosition(Object model, IPosition position) {
    final int line = position.lineNumber;
    final Object? word = (model as dynamic).getWordAtPosition(position);
    if (word != null) {
      return Range(
        line,
        (word as dynamic).startColumn as int,
        line,
        (word as dynamic).endColumn as int,
      );
    }
    final dynamic tokenization = (model as dynamic).tokenization;
    tokenization.tokenizeIfCheap(line);
    final Object tokens = tokenization.getLineTokens(line) as Object;
    final int offset = position.column - 1;
    final int idx = (tokens as dynamic).findTokenIndexAtOffset(offset) as int;
    int start = (tokens as dynamic).getStartOffset(idx) as int;
    int end = (tokens as dynamic).getEndOffset(idx) as int;
    if (end - start == 1) {
      if (start == offset && idx > 1) {
        start = (tokens as dynamic).getStartOffset(idx - 1) as int;
        end = (tokens as dynamic).getEndOffset(idx - 1) as int;
      } else if (end == offset && idx < (tokens as dynamic).getCount() - 1) {
        start = (tokens as dynamic).getStartOffset(idx + 1) as int;
        end = (tokens as dynamic).getEndOffset(idx + 1) as int;
      }
    }
    return Range(line, start + 1, line, end + 1);
  }

  void dispose() {
    _disposables.dispose();
    _createDisposables.dispose();
  }
}

class _EmptyInlayHintList {
  final List<dynamic> hints = <dynamic>[];
  void dispose() {}
}

/// 1:1: `asCommandLink`.
String asCommandLink(CommandLike command) {
  // TS: createCommandUri(id, ...args) -> URI{scheme:command, path:id,
  // query: encodeURIComponent(JSON.stringify(args))}. The ported
  // createCommandUri double-encodes (Uri.encodeComponent + URI.toString), so
  // build the URI here with the raw JSON and let toString encode exactly once.
  final List<Object?>? args = command.arguments;
  final String? query =
      args == null || args.isEmpty ? null : jsonEncode(args);
  return URI
      .from(UriComponents(
        scheme: Schemas.command,
        path: command.id,
        query: query,
      ))
      .toString();
}
