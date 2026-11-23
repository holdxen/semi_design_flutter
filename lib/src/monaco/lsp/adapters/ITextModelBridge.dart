// 1:1 port of monaco-lsp-client/src/adapters/ITextModelBridge.ts
// `monaco.editor.ITextModel` / `monaco.Position` / `monaco.Range` are bridged by
// the opaque carriers in monacoBridge.dart (monaco-editor-core not ported).
import '../types.dart' as T;
import 'monacoBridge.dart';

/// 1:1: `export interface ITextModelBridge`
abstract class ITextModelBridge {
  /// 1:1: `translate(...): { textDocument: TextDocumentIdentifier; position: Position }`
  ({T.TextDocumentIdentifier textDocument, T.Position position}) translate(
    IMonacoTextModel textModel,
    MonacoPosition monacoPos,
  );

  /// 1:1: `translateRange(...)`
  T.Range translateRange(IMonacoTextModel textModel, MonacoRange monacoRange);

  /// 1:1: `translateBack(...)`
  ({IMonacoTextModel textModel, MonacoPosition position}) translateBack(
    T.TextDocumentIdentifier textDocument,
    T.Position position,
  );

  /// 1:1: `translateBackRange(...)`
  ({IMonacoTextModel textModel, MonacoRange range}) translateBackRange(
    T.TextDocumentIdentifier textDocument,
    T.Range range,
  );
}

/// 1:1: the structural generic constraint `{ textModel: monaco.editor.ITextModel }`.
/// Dart has no structural constraints, so callers use this carrier.
abstract class ITextModelHolder {
  IMonacoTextModel get textModel;
}

/// Concrete holder for tests/callers.
class TextModelHolder implements ITextModelHolder {
  @override
  final IMonacoTextModel textModel;
  TextModelHolder(this.textModel);
}

/// 1:1: `export function assertTargetTextModel<T extends { textModel }>(input, expected): T`
/// Throws [StateError] where TS throws `Error`.
T assertTargetTextModel<T extends ITextModelHolder>(
  T input,
  IMonacoTextModel expectedTextModel,
) {
  if (!identical(input.textModel, expectedTextModel)) {
    throw StateError(
      'Expected text model to be $expectedTextModel, but got ${input.textModel}',
    );
  }
  return input;
}

/// Bridge adaptors for the common TS idiom
/// `assertTargetTextModel(bridge.translateBackRange(...), model).range`.
/// Dart records are not [ITextModelHolder], so these helpers perform the same
/// identity check on `record.textModel` and return the requested field. No
/// behaviour is added beyond the TS assertion.
MonacoRange assertRangeTarget(
  ({IMonacoTextModel textModel, MonacoRange range}) input,
  IMonacoTextModel expectedTextModel,
) {
  assertTargetTextModel(TextModelHolder(input.textModel), expectedTextModel);
  return input.range;
}

MonacoPosition assertPositionTarget(
  ({IMonacoTextModel textModel, MonacoPosition position}) input,
  IMonacoTextModel expectedTextModel,
) {
  assertTargetTextModel(TextModelHolder(input.textModel), expectedTextModel);
  return input.position;
}
