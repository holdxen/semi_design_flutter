// ---------------------------------------------------------------------------
// Port of vscode/src/vs/editor/contrib/inlineCompletions/browser/utils.ts
// Translated 1:1. `getPositionOffsetTransformerFromTextModel` and the
// observable context-key bridge are local adaptations of their source helpers.
// ---------------------------------------------------------------------------
import 'dart:async';

import '../../../../base/common/arrays.dart' show Permutation, compareBy;
import '../../../../base/common/cancellation.dart' show CancellationToken;
import '../../../../base/common/lifecycle.dart'
    show DisposableStore, IDisposable;
import '../../../../base/common/observable.dart'
    show
      IObservable,
      IReader,
      ISettableObservable,
      ITransaction,
      autorun,
      observableValue,
      transaction;
import '../../../../platform/contextkey/common/contextkey.dart'
    show ContextKeyValue, IContextKeyServiceType, RawContextKey;
import '../../../../platform/observable/common/platformObservableUtils.dart'
    show bindContextKey;
import '../../../common/core/edits/textEdit.dart'
    show TextEdit, TextReplacement;
import '../../../common/core/position.dart' show Position;
import '../../../common/core/range.dart' show Range;
import '../../../common/core/text/positionToOffset.dart'
    show PositionOffsetTransformer, ensureDependenciesAreSet;

/// 1:1: shared empty array from the source's module-level `array`.
final Map<Type, List<Object?>> _readonlyEmptyArrays =
    <Type, List<Object?>>{};

List<T> getReadonlyEmptyArray<T>() =>
    _readonlyEmptyArrays.putIfAbsent(T, () => <T>[] as List<Object?>) as List<T>;

/// 1:1: `addPositions`.
Position addPositions(Position pos1, Position pos2) => Position(
      pos1.lineNumber + pos2.lineNumber - 1,
      pos2.lineNumber == 1
          ? pos1.column + pos2.column - 1
          : pos2.column,
    );

/// 1:1: `subtractPositions`.
Position subtractPositions(Position pos1, Position pos2) => Position(
      pos1.lineNumber - pos2.lineNumber + 1,
      pos1.lineNumber - pos2.lineNumber == 0
          ? pos1.column - pos2.column + 1
          : pos1.column,
    );

PositionOffsetTransformer _transformerForText(String text) {
  ensureDependenciesAreSet();
  return PositionOffsetTransformer(text);
}

/// 1:1: `substringPos`.
String substringPos(String text, Position pos) {
  final PositionOffsetTransformer transformer = _transformerForText(text);
  final int offset = transformer.getOffset(pos);
  return text.substring(offset);
}

/// 1:1: `getEndPositionsAfterApplying`.
List<Position> getEndPositionsAfterApplying(List<TextReplacement> edits) =>
    getModifiedRangesAfterApplying(edits)
        .map((Range range) => range.getEndPosition())
        .toList();

/// 1:1: `getModifiedRangesAfterApplying`.
List<Range> getModifiedRangesAfterApplying(List<TextReplacement> edits) {
  final Permutation sortPerm = Permutation.createSortPermutation<TextReplacement>(
      edits, compareBy((TextReplacement e) => e.range, Range.compareRangesUsingStarts));
  final TextEdit edit = TextEdit(sortPerm.apply(edits));
  final List<Range> sortedNewRanges = edit.getNewRanges();
  return sortPerm.inverse().apply(sortedNewRanges);
}

/// 1:1: `ITextModel` surface read here.
abstract class ITextModelForInlineUtils {
  String getValue();
}

PositionOffsetTransformer getPositionOffsetTransformerFromTextModel(
        ITextModelForInlineUtils model) =>
    _transformerForText(model.getValue());

/// 1:1: `removeTextReplacementCommonSuffixPrefix`.
List<TextReplacement> removeTextReplacementCommonSuffixPrefix(
    List<TextReplacement> edits, ITextModelForInlineUtils textModel) {
  final PositionOffsetTransformer transformer =
      getPositionOffsetTransformerFromTextModel(textModel);
  final String text = textModel.getValue();
  final List<Object?> stringReplacements =
      edits.map((edit) => transformer.getStringReplacement(edit)).toList();
  final List<Object?> minimal = stringReplacements
      .map((replacement) => (replacement as dynamic).removeCommonSuffixPrefix(text))
      .toList();
  return minimal
      .map((replacement) => transformer.getTextReplacement(replacement as dynamic))
      .toList();
}

/// 1:1: `convertItemsToStableObservables`.
IObservable<List<IObservable<T>>> convertItemsToStableObservables<T>(
  IObservable<List<T>> items,
  DisposableStore store,
) {
  final ISettableObservable<List<IObservable<T>>, Object?> result =
      observableValue<List<IObservable<T>>, Object?>('result', <IObservable<T>>[]);
  final List<ISettableObservable<T, Object?>?> innerObservables =
      <ISettableObservable<T, Object?>?>[];

  store.add(autorun((IReader reader) {
    final List<T> itemsValue = items.read(reader);
    transaction((ITransaction tx) {
      if (itemsValue.length != innerObservables.length) {
        final int oldLength = innerObservables.length;
        innerObservables.length = itemsValue.length;
        for (int i = oldLength; i < itemsValue.length; i++) {
          innerObservables[i] =
              observableValue<T, Object?>('item', itemsValue[i]);
        }
        result.set(<IObservable<T>>[
          for (final ISettableObservable<T, Object?>? o in innerObservables)
            o as IObservable<T>,
        ], tx, null);
      }
      for (int i = 0; i < innerObservables.length; i++) {
        innerObservables[i]!.set(itemsValue[i], tx, null);
      }
    });
  }));

  return result;
}

/// 1:1: `ObservableContextKeyService`.
class ObservableContextKeyService {
  final IContextKeyServiceType _contextKeyService;

  ObservableContextKeyService(this._contextKeyService);

  /// 1:1: overload `(key, obs)`.
  IDisposable bindObservable<T extends ContextKeyValue>(
          RawContextKey<T> key, IObservable<T> obs) =>
      bindContextKey(key, _contextKeyService, (IReader reader) => obs.read(reader));

  /// 1:1: overload `(key, fn)`.
  IDisposable bindFunction<T extends ContextKeyValue>(
          RawContextKey<T> key, T Function(IReader) fn) =>
      bindContextKey(key, _contextKeyService, fn);
}

/// 1:1: `wait`.
Future<void> wait(int ms, [CancellationToken? cancellationToken]) {
  final Completer<void> completer = Completer<void>();
  IDisposable? d;
  Timer? handle;
  void finish() {
    d?.dispose();
    if (!completer.isCompleted) {
      completer.complete();
    }
  }

  handle = Timer(Duration(milliseconds: ms), finish);
  if (cancellationToken != null) {
    d = cancellationToken.onCancellationRequested((_) {
      handle?.cancel();
      finish();
    });
  }
  return completer.future;
}

/// 1:1: `export class ErrorResult`.
class ErrorResult<T> {
  final T error;
  // Dart does not allow a static method and instance field with the same name
  // (TS has both `message()` and `message`), so the field is `errorMessage`.
  final String? errorMessage;

  const ErrorResult(this.error, [this.errorMessage]);

  static ErrorResult<Object?> message(String message) =>
      ErrorResult<Object?>(null, message);

  static bool is_(Object obj) => obj is ErrorResult;

  void logError() {
    if (errorMessage != null) {
      errorResultConsoleError('ErrorResult: $errorMessage', error);
    } else {
      errorResultConsoleError(
          'ErrorResult: An unexpected error-case occurred, usually caused by invalid input.',
          error);
    }
  }
}

/// 1:1: injectable `console.error`.
void Function(String message, Object? error) errorResultConsoleError =
    (String message, Object? error) {};
