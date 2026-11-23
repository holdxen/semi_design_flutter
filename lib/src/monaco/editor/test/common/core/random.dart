// ---------------------------------------------------------------------------
// Port of vscode/src/vs/editor/test/common/core/random.ts
// Translated 1:1 from TypeScript.
//
// JS 32-bit bitwise semantics (`>>>`, `^`, `<<`) are emulated explicitly with
// unsigned 32-bit masking because Dart integers are arbitrary precision.
// ---------------------------------------------------------------------------

import '../../../../base/common/arrays.dart' show numberComparator;
import '../../../../base/common/errors.dart' show BugIndicatingError;
import '../../../common/core/edits/stringEdit.dart' show StringEdit, StringReplacement;
import '../../../common/core/ranges/offsetRange.dart' show OffsetRange;
import '../../../common/core/position.dart' show Position;
import '../../../common/core/text/positionToOffset.dart' show PositionOffsetTransformer, ensureDependenciesAreSet;
import '../../../common/core/range.dart' show Range;
import '../../../common/core/edits/textEdit.dart' show TextEdit, TextReplacement;
import '../../../common/core/text/abstractText.dart' show AbstractText;

int _u32(int x) => x & 0xFFFFFFFF;
int _ushr(int x, int bits) => _u32(x) >> bits;
int _shl(int x, int bits) => _u32(x << bits);

/// 1:1: `export abstract class Random`
abstract class Random {
  static const String alphabetSmallLowercase = 'abcdefgh';
  static const String alphabetSmallUppercase = 'ABCDEFGH';
  static const String alphabetLowercase = 'abcdefghijklmnopqrstuvwxyz';
  static const String alphabetUppercase = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
  static const String basicAlphabet = '      abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
  static const String basicAlphabetMultiline = '      \n\n\nabcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';

  /// 1:1: `export function create(seed)` -> `Random.create`
  static Random create(int seed) => MersenneTwister(seed);

  IGenerator<String> stringGenerator(String alphabet) => StringGenerator(this, alphabet);

  int nextIntRange(int start, int endExclusive);

  String nextString(int length, [IGenerator<String>? alphabet]) {
    final IGenerator<String> gen = alphabet ?? stringGenerator(basicAlphabet);
    final StringBuffer randomText = StringBuffer();
    for (int i = 0; i < length; i++) {
      randomText.write(gen.next());
    }
    return randomText.toString();
  }

  String nextMultiLineString(int lineCount, OffsetRange lineLengthRange, [IGenerator<String>? alphabet]) {
    final IGenerator<String> gen = alphabet ?? stringGenerator(basicAlphabet);
    final List<String> lines = <String>[];
    for (int i = 0; i < lineCount; i++) {
      final int lineLength = nextIntRange(lineLengthRange.start, lineLengthRange.endExclusive);
      lines.add(nextString(lineLength, gen));
    }
    return lines.join('\n');
  }

  List<int> nextConsecutiveOffsets(OffsetRange range, int count) {
    final List<int> offsets = OffsetRange.ofLength(count).map((int _) => nextIntRange(range.start, range.endExclusive));
    offsets.sort(numberComparator);
    return offsets;
  }

  List<Position> nextConsecutivePositions(AbstractText source, int count) {
    ensureDependenciesAreSet();
    final PositionOffsetTransformer t = PositionOffsetTransformer(source.getValue());
    final List<int> offsets = nextConsecutiveOffsets(OffsetRange.ofLength(t.text.length), count);
    return offsets.map((int offset) => t.getPosition(offset)).toList();
  }

  Range nextRange(AbstractText source) {
    final List<Position> positions = nextConsecutivePositions(source, 2);
    return Range.fromPositions(positions[0], end: positions[1]);
  }

  TextEdit nextTextEdit(AbstractText target, int singleTextEditCount) {
    final List<TextReplacement> singleTextEdits = <TextReplacement>[];
    final List<Position> positions = nextConsecutivePositions(target, singleTextEditCount * 2);

    for (int i = 0; i < singleTextEditCount; i++) {
      final Position start = positions[i * 2];
      final Position end = positions[i * 2 + 1];
      final String newText = nextString(end.column - start.column, stringGenerator(basicAlphabetMultiline));
      singleTextEdits.add(TextReplacement(Range.fromPositions(start, end: end), newText));
    }

    return TextEdit(singleTextEdits).normalize();
  }

  StringEdit nextStringEdit(String target, int singleTextEditCount, [String? newTextAlphabet]) {
    final String alphabet = newTextAlphabet ?? basicAlphabetMultiline;
    final List<StringReplacement> singleTextEdits = <StringReplacement>[];

    final List<int> positions = nextConsecutiveOffsets(OffsetRange.ofLength(target.length), singleTextEditCount * 2);

    for (int i = 0; i < singleTextEditCount; i++) {
      final int start = positions[i * 2];
      final int end = positions[i * 2 + 1];
      final OffsetRange range = OffsetRange(start, end);

      final int newTextLen = nextIntRange(range.isEmpty ? 1 : 0, 10);
      final String newText = nextString(newTextLen, stringGenerator(alphabet));
      singleTextEdits.add(StringReplacement(range, newText));
    }

    return StringEdit(singleTextEdits).normalize();
  }

  StringReplacement nextSingleStringEdit(String target, [String? newTextAlphabet]) {
    final StringEdit edit = nextStringEdit(target, 1, newTextAlphabet);
    return edit.replacements[0];
  }

  /// 1:1: `nextRandomValues(data: Uint8Array)` -> fills a List<int>.
  void nextRandomValues(List<int> data) {
    for (int i = 0; i < data.length; i++) {
      data[i] = nextIntRange(0, 256);
    }
  }

  List<String>? _hex;
  List<int>? _data;

  String nextUuid() {
    _data ??= List<int>.filled(16, 0);
    if (_hex == null) {
      _hex = <String>[];
      for (int i = 0; i < 256; i++) {
        _hex!.add(i.toRadixString(16).padLeft(2, '0'));
      }
    }

    final List<int> data = _data!;
    nextRandomValues(data);

    data[6] = (data[6] & 0x0f) | 0x40;
    data[8] = (data[8] & 0x3f) | 0x80;

    // 1:1: 4-2-2-2-6 hex groups separated by '-' (8-4-4-4-12 UUID shape).
    int i = 0;
    final List<String> hex = _hex!;
    final StringBuffer result = StringBuffer();
    for (int g = 0; g < 4; g++) {
      result.write(hex[data[i++]]);
    }
    result.write('-');
    for (int g = 0; g < 2; g++) {
      result.write(hex[data[i++]]);
    }
    result.write('-');
    for (int g = 0; g < 2; g++) {
      result.write(hex[data[i++]]);
    }
    result.write('-');
    for (int g = 0; g < 2; g++) {
      result.write(hex[data[i++]]);
    }
    result.write('-');
    for (int g = 0; g < 6; g++) {
      result.write(hex[data[i++]]);
    }
    return result.toString();
  }
}

/// 1:1: `export function sequenceGenerator`
IGenerator<T> sequenceGenerator<T>(List<T> sequence) => SequenceGenerator<T>(sequence);

/// 1:1: `export interface IGenerator<T>`
abstract class IGenerator<T> {
  T next();
}

class StringGenerator implements IGenerator<String> {
  final Random _random;
  final String _alphabet;
  StringGenerator(this._random, this._alphabet);

  @override
  String next() {
    final int characterIndex = _random.nextIntRange(0, _alphabet.length);
    return _alphabet[characterIndex];
  }
}

class SequenceGenerator<T> implements IGenerator<T> {
  final List<T> _sequence;
  int _index = 0;
  SequenceGenerator(this._sequence);

  @override
  T next() {
    if (_index >= _sequence.length) {
      throw BugIndicatingError('End of sequence');
    }
    final T element = _sequence[_index];
    _index++;
    return element;
  }
}

/// 1:1: `class MersenneTwister extends Random`
class MersenneTwister extends Random {
  final List<int> _mt = List<int>.filled(624, 0);
  int _index = 0;

  MersenneTwister(int seed) {
    _mt[0] = _u32(seed);
    for (int i = 1; i < 624; i++) {
      final int s = _u32(_mt[i - 1] ^ _ushr(_mt[i - 1], 30));
      _mt[i] = _u32(
        _shl(_ushr(s & 0xFFFF0000, 16) * 0x6C078965, 16) +
            ((s & 0x0000FFFF) * 0x6C078965) +
            i,
      );
    }
  }

  int _nextInt() {
    if (_index == 0) {
      _generateNumbers();
    }

    int y = _mt[_index];
    y = _u32(y ^ _ushr(y, 11));
    y = _u32(y ^ (_shl(y, 7) & 0x9D2C5680));
    y = _u32(y ^ (_shl(y, 15) & 0xEFC60000));
    y = _u32(y ^ _ushr(y, 18));

    _index = (_index + 1) % 624;

    return y;
  }

  @override
  int nextIntRange(int start, int endExclusive) {
    final int range = endExclusive - start;
    return (_nextInt() / (0x100000000 / range)).floor() + start;
  }

  void _generateNumbers() {
    for (int i = 0; i < 624; i++) {
      final int y = (_mt[i] & 0x80000000) + (_mt[(i + 1) % 624] & 0x7FFFFFFF);
      _mt[i] = _u32(_mt[(i + 397) % 624] ^ _ushr(y, 1));
      if (y % 2 != 0) {
        _mt[i] = _u32(_mt[i] ^ 0x9908B0DF);
      }
    }
  }
}
