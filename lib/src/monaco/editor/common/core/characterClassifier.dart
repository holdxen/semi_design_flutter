// ---------------------------------------------------------------------------
// Port of vscode/src/vs/editor/common/core/characterClassifier.ts @bfbf12b35b9978b92b2d341e81ade49f2b18c68c
// Translated 1:1 from TypeScript. Uint8Array -> dart:typed_data Uint8List;
// `const enum Boolean` -> class with static const (call sites unchanged).
// ---------------------------------------------------------------------------

import 'dart:typed_data';
import '../../../base/common/uint.dart';

/// A fast character classifier that uses a compact array for ASCII values.
class CharacterClassifier<T extends num> {
  /// Maintain a compact (fully initialized ASCII map for quickly classifying ASCII characters).
  late final Uint8List _asciiMap;

  /// The entire map (sparse array).
  final Map<int, int> _map;

  final int _defaultValue;

  CharacterClassifier(T defaultValue)
      : _defaultValue = toUint8(defaultValue),
        _map = <int, int>{} {
    this._asciiMap = CharacterClassifier._createAsciiMap(this._defaultValue);
  }

  static Uint8List _createAsciiMap(int defaultValue) {
    final Uint8List asciiMap = Uint8List(256);
    asciiMap.fillRange(0, asciiMap.length, defaultValue);
    return asciiMap;
  }

  void set(int charCode, T value) {
    final int v = toUint8(value);
    if (charCode >= 0 && charCode < 256) {
      this._asciiMap[charCode] = v;
    } else {
      this._map[charCode] = v;
    }
  }

  T get(int charCode) {
    if (charCode >= 0 && charCode < 256) {
      return this._asciiMap[charCode] as T;
    } else {
      return (this._map[charCode] ?? this._defaultValue) as T;
    }
  }

  void clear() {
    this._asciiMap.fillRange(0, this._asciiMap.length, this._defaultValue);
    this._map.clear();
  }
}

class Boolean {
  const Boolean._();
  static const int False = 0;
  static const int True = 1;
}

class CharacterSet {
  late final CharacterClassifier<int> _actual;

  CharacterSet() {
    this._actual = CharacterClassifier<int>(Boolean.False);
  }

  void add(int charCode) {
    this._actual.set(charCode, Boolean.True);
  }

  bool has(int charCode) => this._actual.get(charCode) == Boolean.True;

  void clear() => this._actual.clear();
}
