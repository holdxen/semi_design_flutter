// ---------------------------------------------------------------------------
// Port of vscode/src/vs/editor/common/services/semanticTokensDto.ts
// Translated 1:1 from TypeScript.
//   - `Uint32Array` <-> `Uint32List`; byte order handled via ByteData with an
//     explicit little-endian order (matching `toLittleEndianBuffer`).
//   - `ISemanticTokensDto` union -> abstract base + two concrete carriers.
//   - `const enum` -> class with static consts.
// ---------------------------------------------------------------------------

import 'dart:typed_data';

import '../../../base/common/buffer.dart';

/// 1:1: `export interface IFullSemanticTokensDto`
class IFullSemanticTokensDto implements ISemanticTokensDto {
  final int id;
  final Uint32List data;

  IFullSemanticTokensDto(this.id, this.data);
}

/// 1:1: a single delta entry: `{ start; deleteCount; data? }`
class SemanticTokensDelta {
  final int start;
  final int deleteCount;
  final Uint32List? data;

  SemanticTokensDelta(this.start, this.deleteCount, [this.data]);
}

/// 1:1: `export interface IDeltaSemanticTokensDto`
class IDeltaSemanticTokensDto implements ISemanticTokensDto {
  final int id;
  final List<SemanticTokensDelta> deltas;

  IDeltaSemanticTokensDto(this.id, this.deltas);
}

/// 1:1: `export type ISemanticTokensDto`
abstract class ISemanticTokensDto {}

/// 1:1: `const enum EncodedSemanticTokensType`
class EncodedSemanticTokensType {
  static const int Full = 1;
  static const int Delta = 2;
}

/// Source `reverseEndianness` + the `platform.isLittleEndian()` branch are
/// folded away here: ByteData with explicit `Endian.little` is platform
/// independent, and reading via a Uint8List view avoids the source's
/// unaligned-memory special case entirely (no byte swapping needed).

/// 1:1: `toLittleEndianBuffer(arr: Uint32Array)`
VSBuffer _toLittleEndianBuffer(Uint32List arr) {
  final Uint8List bytes = Uint8List(arr.length * 4);
  final ByteData view = ByteData.view(bytes.buffer);
  for (int i = 0; i < arr.length; i++) {
    view.setUint32(i * 4, arr[i], Endian.little);
  }
  return VSBuffer.wrap(bytes);
}

/// 1:1: `fromLittleEndianBuffer(buff: VSBuffer)`
Uint32List _fromLittleEndianBuffer(VSBuffer buff) {
  final Uint8List bytes = buff.buffer;
  final int length = bytes.length ~/ 4;
  final Uint32List result = Uint32List(length);
  final ByteData view = ByteData.view(bytes.buffer, bytes.offsetInBytes, bytes.lengthInBytes);
  for (int i = 0; i < length; i++) {
    result[i] = view.getUint32(i * 4, Endian.little);
  }
  return result;
}

/// 1:1: `export function encodeSemanticTokensDto`
VSBuffer encodeSemanticTokensDto(ISemanticTokensDto semanticTokens) {
  final int size = _encodeSemanticTokensDtoSize(semanticTokens);
  final Uint32List dest = Uint32List(size);
  int offset = 0;

  if (semanticTokens is IFullSemanticTokensDto) {
    dest[offset++] = semanticTokens.id;
    dest[offset++] = EncodedSemanticTokensType.Full;
    dest[offset++] = semanticTokens.data.length;
    dest.setAll(offset, semanticTokens.data);
    offset += semanticTokens.data.length;
  } else if (semanticTokens is IDeltaSemanticTokensDto) {
    dest[offset++] = semanticTokens.id;
    dest[offset++] = EncodedSemanticTokensType.Delta;
    dest[offset++] = semanticTokens.deltas.length;
    for (final SemanticTokensDelta delta in semanticTokens.deltas) {
      dest[offset++] = delta.start;
      dest[offset++] = delta.deleteCount;
      if (delta.data != null) {
        dest[offset++] = delta.data!.length;
        dest.setAll(offset, delta.data!);
        offset += delta.data!.length;
      } else {
        dest[offset++] = 0;
      }
    }
  }

  return _toLittleEndianBuffer(dest);
}

/// 1:1: `encodeSemanticTokensDtoSize`
int _encodeSemanticTokensDtoSize(ISemanticTokensDto semanticTokens) {
  int result = 0;
  result += 1 + 1; // id + type
  if (semanticTokens is IFullSemanticTokensDto) {
    result += 1 + semanticTokens.data.length;
  } else if (semanticTokens is IDeltaSemanticTokensDto) {
    result += 1; // delta count
    result += (1 + 1 + 1) * semanticTokens.deltas.length;
    for (final SemanticTokensDelta delta in semanticTokens.deltas) {
      if (delta.data != null) {
        result += delta.data!.length;
      }
    }
  }
  return result;
}

/// 1:1: `export function decodeSemanticTokensDto`
ISemanticTokensDto decodeSemanticTokensDto(VSBuffer buff) {
  final Uint32List src = _fromLittleEndianBuffer(buff);
  int offset = 0;
  final int id = src[offset++];
  final int type = src[offset++];
  if (type == EncodedSemanticTokensType.Full) {
    final int length = src[offset++];
    final Uint32List data = Uint32List.sublistView(src, offset, offset + length);
    return IFullSemanticTokensDto(id, data);
  }
  final int deltaCount = src[offset++];
  final List<SemanticTokensDelta> deltas = <SemanticTokensDelta>[];
  for (int i = 0; i < deltaCount; i++) {
    final int start = src[offset++];
    final int deleteCount = src[offset++];
    final int length = src[offset++];
    Uint32List? data;
    if (length > 0) {
      data = Uint32List.sublistView(src, offset, offset + length);
      offset += length;
    }
    deltas.add(SemanticTokensDelta(start, deleteCount, data));
  }
  return IDeltaSemanticTokensDto(id, deltas);
}
