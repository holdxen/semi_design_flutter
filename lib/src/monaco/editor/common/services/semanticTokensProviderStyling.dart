// ---------------------------------------------------------------------------
// Port of vscode/src/vs/editor/common/services/semanticTokensProviderStyling.ts
// Translated 1:1 from TypeScript. Structure, members and semantics preserved.
//
// Adaptations (documented inline):
//  * TS interfaces (`IThemeService`, `ILanguageService`, `ILogService`) are
//    reduced to the members actually read, per repo convention.
//  * `| 0` (int32 wrap) -> [_int32] because Dart ints are unbounded.
//  * JS hash table can hold negative array properties; Dart uses a side map
//    for those (they are intentionally dropped on rehash, like JS for..of).
//  * `ENABLE_TRACE` is false in the source: trace branches are kept as dead
//    code paths only where they affect observable behavior (they do not).
// ---------------------------------------------------------------------------
import 'dart:typed_data';

import '../encodedTokenAttributes.dart' show FontStyle, MetadataConsts;
import '../tokens/sparseMultilineTokens.dart' show SparseMultilineTokens;
import '../../contrib/semanticTokens/common/getSemanticTokens.dart'
    show SemanticTokens, SemanticTokensLegend;
import '../../../platform/theme/common/themeService.dart' show ITokenStyle;

/// 1:1: JS `| 0` (signed 32-bit truncation).
int _int32(int v) => ((v + 0x80000000) % 0x100000000).toInt() - 0x80000000;

/// 1:1: `const enum SemanticTokensProviderStylingConstants`.
class SemanticTokensProviderStylingConstants {
  const SemanticTokensProviderStylingConstants._();
  static const int NO_STYLING = 0x7FFFFFFF;
}

/// 1:1: `const enum SemanticColoringConstants`.
class SemanticColoringConstants {
  const SemanticColoringConstants._();
  static const int DesiredTokensPerArea = 400;
  static const int DesiredMaxAreas = 1024;
}

/// 1:1: `IThemeService` members read by `getMetadata`.
abstract class IThemeServiceForSemanticStyling {
  Object getColorTheme();
}

/// 1:1: `IColorTheme.getTokenStyleMetadata` carrier.
abstract class IColorThemeForSemanticStyling {
  ITokenStyle? getTokenStyleMetadata(
      String type, List<String> modifiers, String modelLanguage);
}

/// 1:1: `ILogService` members read here.
abstract class ILogServiceForSemanticStyling {
  void warn(Object message);
}

/// 1:1: `ILanguageService.languageIdCodec` carrier.
abstract class ILanguageServiceForSemanticStyling {
  int encodeLanguageId(String languageId);
}

class SemanticTokensProviderStyling {
  final HashTable _hashTable;
  bool _hasWarnedOverlappingTokens = false;
  bool _hasWarnedInvalidLengthTokens = false;
  bool _hasWarnedInvalidEditStart = false;
  bool _hasWarnedInvalidEditDeleteCount = false;

  final SemanticTokensLegend _legend;
  final IThemeServiceForSemanticStyling _themeService;
  final ILanguageServiceForSemanticStyling _languageService;
  final ILogServiceForSemanticStyling _logService;

  SemanticTokensProviderStyling(
    this._legend,
    this._themeService,
    this._languageService,
    this._logService,
  ) : _hashTable = HashTable();

  int getMetadata(
      int tokenTypeIndex, int tokenModifierSet, String languageId) {
    final int encodedLanguageId =
        _languageService.encodeLanguageId(languageId);
    final HashTableEntry? entry =
        _hashTable.get(tokenTypeIndex, tokenModifierSet, encodedLanguageId);
    late int metadata;
    if (entry != null) {
      metadata = entry.metadata;
    } else {
      String tokenType;
      final List<String> tokenModifiers = <String>[];
      final int? typeIndex = tokenTypeIndex >= 0 &&
              tokenTypeIndex < _legend.tokenTypes.length
          ? tokenTypeIndex
          : null;
      if (typeIndex != null) {
        tokenType = _legend.tokenTypes[typeIndex];
        int modifierSet = tokenModifierSet;
        for (int modifierIndex = 0;
            modifierSet > 0 && modifierIndex < _legend.tokenModifiers.length;
            modifierIndex++) {
          if ((modifierSet & 1) != 0) {
            tokenModifiers.add(_legend.tokenModifiers[modifierIndex]);
          }
          modifierSet = modifierSet >> 1;
        }
        final IColorThemeForSemanticStyling theme =
            _themeService.getColorTheme() as IColorThemeForSemanticStyling;
        final ITokenStyle? tokenStyle =
            theme.getTokenStyleMetadata(tokenType, tokenModifiers, languageId);
        if (tokenStyle == null) {
          metadata = SemanticTokensProviderStylingConstants.NO_STYLING;
        } else {
          metadata = 0;
          if (tokenStyle.italic != null) {
            final int italicBit = (tokenStyle.italic! ? FontStyle.italic : 0)
                << MetadataConsts.fontStyleOffset;
            metadata |= italicBit | MetadataConsts.semanticUseItalic;
          }
          if (tokenStyle.bold != null) {
            final int boldBit = (tokenStyle.bold! ? FontStyle.bold : 0)
                << MetadataConsts.fontStyleOffset;
            metadata |= boldBit | MetadataConsts.semanticUseBold;
          }
          if (tokenStyle.underline != null) {
            final int underlineBit =
                (tokenStyle.underline! ? FontStyle.underline : 0)
                    << MetadataConsts.fontStyleOffset;
            metadata |= underlineBit | MetadataConsts.semanticUseUnderline;
          }
          if (tokenStyle.strikethrough != null) {
            final int strikethroughBit =
                (tokenStyle.strikethrough! ? FontStyle.strikethrough : 0)
                    << MetadataConsts.fontStyleOffset;
            metadata |=
                strikethroughBit | MetadataConsts.semanticUseStrikethrough;
          }
          if (tokenStyle.foreground != null) {
            final int foregroundBits =
                tokenStyle.foreground! << MetadataConsts.foregroundOffset;
            metadata |= foregroundBits | MetadataConsts.semanticUseForeground;
          }
          if (metadata == 0) {
            // Nothing!
            metadata = SemanticTokensProviderStylingConstants.NO_STYLING;
          }
        }
      } else {
        metadata = SemanticTokensProviderStylingConstants.NO_STYLING;
        tokenType = 'not-in-legend';
      }
      _hashTable.add(
          tokenTypeIndex, tokenModifierSet, encodedLanguageId, metadata);
    }

    return metadata;
  }

  void warnOverlappingSemanticTokens(int lineNumber, int startColumn) {
    if (!_hasWarnedOverlappingTokens) {
      _hasWarnedOverlappingTokens = true;
      _logService.warn(
          'Overlapping semantic tokens detected at lineNumber $lineNumber, column $startColumn');
    }
  }

  void warnInvalidLengthSemanticTokens(int lineNumber, int startColumn) {
    if (!_hasWarnedInvalidLengthTokens) {
      _hasWarnedInvalidLengthTokens = true;
      _logService.warn(
          'Semantic token with invalid length detected at lineNumber $lineNumber, column $startColumn');
    }
  }

  void warnInvalidEditStart(String? previousResultId, String? resultId,
      int editIndex, int editStart, int maxExpectedStart) {
    if (!_hasWarnedInvalidEditStart) {
      _hasWarnedInvalidEditStart = true;
      _logService.warn(
          'Invalid semantic tokens edit detected (previousResultId: $previousResultId, resultId: $resultId) at edit #$editIndex: The provided start offset $editStart is outside the previous data (length $maxExpectedStart).');
    }
  }

  void warnInvalidEditDeleteCount(String? previousResultId, String? resultId,
      int srcLength, int deltaLength) {
    if (!_hasWarnedInvalidEditDeleteCount) {
      _hasWarnedInvalidEditDeleteCount = true;
      _logService.warn(
          'Invalid semantic tokens edit detected (previousResultId: $previousResultId, resultId: $resultId): The edits delete more tokens than the previous data contains (previous length $srcLength, computed length ${srcLength + deltaLength}).');
    }
  }
}

List<SparseMultilineTokens> toMultilineTokens2(
    SemanticTokens tokens,
    SemanticTokensProviderStyling styling,
    String languageId) {
  final List<int> srcData = tokens.data;
  final int tokenCount = (tokens.data.length / 5).toInt();
  final int tokensPerArea = _max(
      (tokenCount / SemanticColoringConstants.DesiredMaxAreas).ceil(),
      SemanticColoringConstants.DesiredTokensPerArea);
  final List<SparseMultilineTokens> result = <SparseMultilineTokens>[];

  int tokenIndex = 0;
  int lastLineNumber = 1;
  int lastStartCharacter = 0;
  while (tokenIndex < tokenCount) {
    final int tokenStartIndex = tokenIndex;
    int tokenEndIndex = _min(tokenStartIndex + tokensPerArea, tokenCount);

    // Keep tokens on the same line in the same area...
    if (tokenEndIndex < tokenCount) {
      int smallTokenEndIndex = tokenEndIndex;
      while (smallTokenEndIndex - 1 > tokenStartIndex &&
          srcData[5 * smallTokenEndIndex] == 0) {
        smallTokenEndIndex--;
      }

      if (smallTokenEndIndex - 1 == tokenStartIndex) {
        // there are so many tokens on this line that our area would be empty,
        // we must now go right
        int bigTokenEndIndex = tokenEndIndex;
        while (bigTokenEndIndex + 1 < tokenCount &&
            srcData[5 * bigTokenEndIndex] == 0) {
          bigTokenEndIndex++;
        }
        tokenEndIndex = bigTokenEndIndex;
      } else {
        tokenEndIndex = smallTokenEndIndex;
      }
    }

    Uint32List destData = Uint32List((tokenEndIndex - tokenStartIndex) * 4);
    int destOffset = 0;
    int areaLine = 0;
    int prevLineNumber = 0;
    int prevEndCharacter = 0;
    while (tokenIndex < tokenEndIndex) {
      final int srcOffset = 5 * tokenIndex;
      final int deltaLine = srcData[srcOffset];
      final int deltaCharacter = srcData[srcOffset + 1];
      final int lineNumber = _int32(lastLineNumber + deltaLine);
      final int startCharacter = _int32(deltaLine == 0
          ? lastStartCharacter + deltaCharacter
          : deltaCharacter);
      final int length = srcData[srcOffset + 2];
      final int endCharacter = _int32(startCharacter + length);
      final int tokenTypeIndex = srcData[srcOffset + 3];
      final int tokenModifierSet = srcData[srcOffset + 4];

      if (endCharacter <= startCharacter) {
        styling.warnInvalidLengthSemanticTokens(
            lineNumber, startCharacter + 1);
      } else if (prevLineNumber == lineNumber &&
          prevEndCharacter > startCharacter) {
        styling.warnOverlappingSemanticTokens(lineNumber, startCharacter + 1);
      } else {
        final int metadata =
            styling.getMetadata(tokenTypeIndex, tokenModifierSet, languageId);

        if (metadata != SemanticTokensProviderStylingConstants.NO_STYLING) {
          if (areaLine == 0) {
            areaLine = lineNumber;
          }
          destData[destOffset] = _int32(lineNumber - areaLine);
          destData[destOffset + 1] = startCharacter;
          destData[destOffset + 2] = endCharacter;
          destData[destOffset + 3] = metadata;
          destOffset += 4;

          prevLineNumber = lineNumber;
          prevEndCharacter = endCharacter;
        }
      }

      lastLineNumber = lineNumber;
      lastStartCharacter = startCharacter;
      tokenIndex++;
    }

    if (destOffset != destData.length) {
      destData = Uint32List.sublistView(destData, 0, destOffset);
    }

    result.add(SparseMultilineTokens.create(areaLine, destData));
  }

  return result;
}

class HashTableEntry {
  final int tokenTypeIndex;
  final int tokenModifierSet;
  final int languageId;
  final int metadata;
  HashTableEntry? next;

  HashTableEntry(
      this.tokenTypeIndex, this.tokenModifierSet, this.languageId, this.metadata)
      : next = null;
}

class HashTable {
  static const List<int> _sizes = <int>[
    3, 7, 13, 31, 61, 127, 251, 509, 1021, 2039, 4093, 8191, 16381, 32749,
    65521, 131071, 262139, 524287, 1048573, 2097143,
  ];

  int _elementsCount;
  int _currentLengthIndex;
  int _currentLength;
  int _growCount;
  List<HashTableEntry?> _elements;
  // JS arrays can carry negative properties without participating in for..of;
  // mirror that with a side map rather than clamping the hash.
  final Map<int, HashTableEntry?> _negativeElements = <int, HashTableEntry?>{};

  HashTable()
      : _elementsCount = 0,
        _currentLengthIndex = 0,
        _currentLength = _sizes[0],
        _growCount = 0,
        _elements = <HashTableEntry?>[] {
    _growCount = _currentLengthIndex + 1 < _sizes.length
        ? (2 / 3 * _currentLength).round()
        : 0;
    _nullOutEntries(_elements, _currentLength);
  }

  static void _nullOutEntries(List<HashTableEntry?> entries, int length) {
    // Dart: JS `entries[i] = null` grows a sparse array; use `add` here.
    for (int i = 0; i < length; i++) {
      entries.add(null);
    }
  }

  int _hash2(int n1, int n2) =>
      _int32(_int32((n1 << 5) - n1) + n2); // n1 * 31 + n2, keep as int32

  int _hashFunc(
          int tokenTypeIndex, int tokenModifierSet, int languageId) =>
      _hash2(_hash2(tokenTypeIndex, tokenModifierSet), languageId)
          .remainder(_currentLength);

  HashTableEntry? _getAt(int hash) => hash >= 0
      ? _elements[hash]
      : _negativeElements[hash];

  void _setAt(int hash, HashTableEntry? value) {
    if (hash >= 0) {
      _elements[hash] = value;
    } else {
      _negativeElements[hash] = value;
    }
  }

  HashTableEntry? get(
      int tokenTypeIndex, int tokenModifierSet, int languageId) {
    final int hash = _hashFunc(tokenTypeIndex, tokenModifierSet, languageId);

    HashTableEntry? p = _getAt(hash);
    while (p != null) {
      if (p.tokenTypeIndex == tokenTypeIndex &&
          p.tokenModifierSet == tokenModifierSet &&
          p.languageId == languageId) {
        return p;
      }
      p = p.next;
    }

    return null;
  }

  void add(int tokenTypeIndex, int tokenModifierSet, int languageId,
      int metadata) {
    _elementsCount++;
    if (_growCount != 0 && _elementsCount >= _growCount) {
      // expand!
      final List<HashTableEntry?> oldElements = _elements;

      _currentLengthIndex++;
      _currentLength = _sizes[_currentLengthIndex];
      _growCount = _currentLengthIndex + 1 < _sizes.length
          ? (2 / 3 * _currentLength).round()
          : 0;
      _elements = <HashTableEntry?>[];
      _negativeElements.clear();
      _nullOutEntries(_elements, _currentLength);

      for (final HashTableEntry? first in oldElements) {
        HashTableEntry? p = first;
        while (p != null) {
          final HashTableEntry? oldNext = p.next;
          p.next = null;
          _add(p);
          p = oldNext;
        }
      }
    }
    _add(HashTableEntry(
        tokenTypeIndex, tokenModifierSet, languageId, metadata));
  }

  void _add(HashTableEntry element) {
    final int hash = _hashFunc(
        element.tokenTypeIndex, element.tokenModifierSet, element.languageId);
    element.next = _getAt(hash);
    _setAt(hash, element);
  }
}

int _min(int a, int b) => a < b ? a : b;
int _max(int a, int b) => a > b ? a : b;
