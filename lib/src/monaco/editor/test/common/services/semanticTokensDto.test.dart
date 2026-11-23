// ---------------------------------------------------------------------------
// Port of vscode/src/vs/editor/test/common/services/semanticTokensDto.test.ts
// Translated 1:1 from TypeScript. The mocha `suite`/`test` cases become plain
// Dart functions (one per `test(...)`) that carry the exact same assertions;
// `assert.deepStrictEqual` -> Dart `assert`, `assert.fail` -> `assert(false)`.
// `ensureNoDisposablesAreLeakedInTestSuite()` is a harness hook and is omitted
// here (it has no portable assertion body); it remains available in the ported
// base/test/common/utils.dart for the outer test runner.
// ---------------------------------------------------------------------------

import 'dart:typed_data' show Uint32List, Uint8List;

import '../../../../base/common/buffer.dart' show VSBuffer;
import '../../../../editor/common/services/semanticTokensDto.dart'
    show
        IDeltaSemanticTokensDto,
        IFullSemanticTokensDto,
        ISemanticTokensDto,
        SemanticTokensDelta,
        decodeSemanticTokensDto,
        encodeSemanticTokensDto;

/// 1:1: helper `toArr(arr): number[]`
List<int> _toArr(Uint32List arr) => List<int>.from(arr);

/// 1:1: `assertEqualFull`
void _assertEqualFull(
    IFullSemanticTokensDto actual, IFullSemanticTokensDto expected) {
  Object convert(IFullSemanticTokensDto dto) => <String, Object>{
        'id': dto.id,
        'data': _toArr(dto.data),
      };
  assert(convert(actual).toString() == convert(expected).toString());
}

/// 1:1: `assertEqualDelta`
void _assertEqualDelta(
    IDeltaSemanticTokensDto actual, IDeltaSemanticTokensDto expected) {
  Object convertOne(SemanticTokensDelta delta) {
    final Uint32List? data = delta.data;
    if (data == null) {
      return <String, Object>{
        'start': delta.start,
        'deleteCount': delta.deleteCount,
      };
    }
    return <String, Object>{
      'start': delta.start,
      'deleteCount': delta.deleteCount,
      'data': _toArr(data),
    };
  }

  Object convert(IDeltaSemanticTokensDto dto) => <String, Object>{
        'id': dto.id,
        'deltas': dto.deltas.map(convertOne).toList(),
      };
  assert(convert(actual).toString() == convert(expected).toString());
}

/// 1:1: `testRoundTrip(value)`
void _testRoundTrip(ISemanticTokensDto value) {
  final ISemanticTokensDto decoded =
      decodeSemanticTokensDto(encodeSemanticTokensDto(value));
  if (value is IFullSemanticTokensDto && decoded is IFullSemanticTokensDto) {
    _assertEqualFull(decoded, value);
  } else if (value is IDeltaSemanticTokensDto &&
      decoded is IDeltaSemanticTokensDto) {
    _assertEqualDelta(decoded, value);
  } else {
    throw StateError('wrong type');
  }
}

/// 1:1: `test('full encoding', ...)`
void testFullEncoding() {
  _testRoundTrip(IFullSemanticTokensDto(
    12,
    Uint32List.fromList([(1 << 24) + (2 << 16) + (3 << 8) + 4]),
  ));
}

/// 1:1: `test('delta encoding', ...)`
void testDeltaEncoding() {
  final int x = (1 << 24) + (2 << 16) + (3 << 8) + 4;
  _testRoundTrip(IDeltaSemanticTokensDto(12, <SemanticTokensDelta>[
    SemanticTokensDelta(0, 4),
    SemanticTokensDelta(15, 0, Uint32List.fromList([x])),
    SemanticTokensDelta(
      27,
      5,
      Uint32List.fromList([x, 1, 2, 3, 4, 5, 6, 7, 8, 9]),
    ),
  ]));
}

/// 1:1: `test('partial array buffer', ...)`
void testPartialArrayBuffer() {
  final Uint32List sharedArr = Uint32List.fromList([
    (1 << 24) + (2 << 16) + (3 << 8) + 4,
    1,
    2,
    3,
    4,
    5,
    (1 << 24) + (2 << 16) + (3 << 8) + 4,
  ]);
  _testRoundTrip(IDeltaSemanticTokensDto(12, <SemanticTokensDelta>[
    SemanticTokensDelta(0, 4, Uint32List.sublistView(sharedArr, 0, 1)),
    SemanticTokensDelta(
      15,
      0,
      Uint32List.sublistView(sharedArr, 1, sharedArr.length),
    ),
  ]));
}

/// 1:1: `test('issue #94521: unusual backing array buffer', ...)`
void testIssue94521UnusualBackingArrayBuffer() {
  Uint8List wrapAndSliceUint8Array(
      Uint8List buff, int prefixLength, int suffixLength) {
    final Uint8List wrapped =
        Uint8List(prefixLength + buff.lengthInBytes + suffixLength);
    wrapped.setAll(prefixLength, buff);
    return Uint8List.view(wrapped.buffer, wrapped.offsetInBytes + prefixLength,
        buff.lengthInBytes);
  }

  VSBuffer wrapAndSlice(VSBuffer buff, int prefixLength, int suffixLength) =>
      VSBuffer.wrap(
          wrapAndSliceUint8Array(buff.buffer, prefixLength, suffixLength));

  final ISemanticTokensDto dto =
      IFullSemanticTokensDto(5, Uint32List.fromList([1, 2, 3, 4, 5]));
  final VSBuffer encoded = encodeSemanticTokensDto(dto);

  // with misaligned prefix and misaligned suffix
  _assertEqualFull(
      decodeSemanticTokensDto(wrapAndSlice(encoded, 1, 1))
          as IFullSemanticTokensDto,
      dto as IFullSemanticTokensDto);
  // with misaligned prefix and aligned suffix
  _assertEqualFull(
      decodeSemanticTokensDto(wrapAndSlice(encoded, 1, 4))
          as IFullSemanticTokensDto,
      dto);
  // with aligned prefix and misaligned suffix
  _assertEqualFull(
      decodeSemanticTokensDto(wrapAndSlice(encoded, 4, 1))
          as IFullSemanticTokensDto,
      dto);
  // with aligned prefix and aligned suffix
  _assertEqualFull(
      decodeSemanticTokensDto(wrapAndSlice(encoded, 4, 4))
          as IFullSemanticTokensDto,
      dto);
}

/// Run all four translated cases in source order.
void runAll() {
  testFullEncoding();
  testDeltaEncoding();
  testPartialArrayBuffer();
  testIssue94521UnusualBackingArrayBuffer();
}
