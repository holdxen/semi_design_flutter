// ---------------------------------------------------------------------------
// Port of vscode/src/vs/editor/common/tokens/contiguousMultilineTokensBuilder.ts
// @bfbf12b
// Translated 1:1 from TypeScript. Do not refactor.
//
// Adaptations (documented inline):
//  * `Uint8Array` → `Uint8List`; `readUInt32BE`/`writeUInt32BE` come from
//    `base/common/buffer.dart` (there they are suffixed `_` to stay clear of
//    the class members of the same name).
// ---------------------------------------------------------------------------
import 'dart:typed_data';

import '../../../base/common/buffer.dart' as buffer;
import './contiguousMultilineTokens.dart' show ContiguousMultilineTokens;

class ContiguousMultilineTokensBuilder {
  static List<ContiguousMultilineTokens> deserialize(Uint8List buff) {
    int offset = 0;
    final int count = buffer.readUInt32BE_(buff, offset);
    offset += 4;
    final List<ContiguousMultilineTokens> result = <ContiguousMultilineTokens>[];
    for (int i = 0; i < count; i++) {
      offset = ContiguousMultilineTokens.deserialize(buff, offset, result);
    }
    return result;
  }

  final List<ContiguousMultilineTokens> _tokens;

  ContiguousMultilineTokensBuilder() : _tokens = <ContiguousMultilineTokens>[];

  void add(int lineNumber, Uint32List lineTokens) {
    if (_tokens.isNotEmpty) {
      final ContiguousMultilineTokens last = _tokens[_tokens.length - 1];
      if (last.endLineNumber + 1 == lineNumber) {
        // append
        last.appendLineTokens(lineTokens);
        return;
      }
    }
    _tokens.add(ContiguousMultilineTokens(lineNumber, <Uint32List>[lineTokens]));
  }

  List<ContiguousMultilineTokens> finalize() {
    return _tokens;
  }

  Uint8List serialize() {
    final int size = _serializeSize();
    final Uint8List result = Uint8List(size);
    _serialize(result);
    return result;
  }

  int _serializeSize() {
    int result = 0;
    result += 4; // 4 bytes for the count
    for (int i = 0; i < _tokens.length; i++) {
      result += _tokens[i].serializeSize();
    }
    return result;
  }

  void _serialize(Uint8List destination) {
    int offset = 0;
    buffer.writeUInt32BE_(destination, _tokens.length, offset);
    offset += 4;
    for (int i = 0; i < _tokens.length; i++) {
      offset = _tokens[i].serialize(destination, offset);
    }
  }
}