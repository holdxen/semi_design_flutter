// 1:1 port of
// vscode/src/vs/editor/common/core/text/getPositionOffsetTransformerFromTextModel.ts
// @bfbf12b35b9978b92b2d341e81ade49f2b18c68c
//
// Adaptations:
//   - `ITextModel` is erased per repo convention; the minimal structural
//     contract below carries the two members this factory actually reads.
//   - `PositionOffsetTransformerBase` comes from the already ported
//     `positionToOffset.dart`, keeping the inherited range/edit helpers.

import '../position.dart' show Position;
import 'positionToOffset.dart' show PositionOffsetTransformerBase;

/// 1:1: the `ITextModel` surface read by
/// `PositionOffsetTransformerWithTextModel`.
abstract class ITextModelForPositionOffsetTransformer {
  int getOffsetAt(Position position);
  Position getPositionAt(int offset);
}

/// 1:1: `export function getPositionOffsetTransformerFromTextModel`
PositionOffsetTransformerBase getPositionOffsetTransformerFromTextModel(
  ITextModelForPositionOffsetTransformer textModel,
) {
  return PositionOffsetTransformerWithTextModel(textModel);
}

/// 1:1: `class PositionOffsetTransformerWithTextModel`
class PositionOffsetTransformerWithTextModel
    extends PositionOffsetTransformerBase {
  PositionOffsetTransformerWithTextModel(this._textModel);

  final ITextModelForPositionOffsetTransformer _textModel;

  @override
  int getOffset(Position position) => _textModel.getOffsetAt(position);

  @override
  Position getPosition(int offset) => _textModel.getPositionAt(offset);
}
