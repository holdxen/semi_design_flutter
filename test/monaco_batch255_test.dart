// 1:1 replay of the batch255 tokenization test infrastructure:
//   - editor/common/languages/nullTokenize.ts
//   - editor/test/common/core/testLineToken.ts
//
// `tool/ts2dart/_batch255_truth.cjs` recursively transpiles and executes the
// real TS modules + Token/TokenizationResult/EncodedTokenizationResult/
// TokenMetadata/MetadataConsts/ColorId/FontStyle/StandardTokenType (no stubs),
// recording NullState identity, nullTokenize/nullTokenizeEncoded metadata,
// TestLineToken getters, equalsArr, inflateArr and TestLineTokens behavior.
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';

import '../lib/src/monaco/editor/common/encodedTokenAttributes.dart';
import '../lib/src/monaco/editor/common/languages/nullTokenize.dart';
import '../lib/src/monaco/editor/test/common/core/testLineToken.dart';

Map<String, dynamic> _map(dynamic value) => (value as Map).cast<String, dynamic>();

Map<String, dynamic> _truth() => _map(jsonDecode(
    File('tool/ts2dart/batch255_truth.json').readAsStringSync()));

bool _same(Object? a, Object? b) {
  if (a == null || b == null) return a == b;
  if (a is num && b is num) return a == b;
  if (a is String && b is String) return a == b;
  if (a is bool && b is bool) return a == b;
  if (a is Map && b is Map) {
    if (a.length != b.length) return false;
    for (final k in a.keys) {
      if (!b.containsKey(k) || !_same(a[k], b[k])) return false;
    }
    return true;
  }
  if (a is List && b is List) {
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (!_same(a[i], b[i])) return false;
    }
    return true;
  }
  return false;
}

int _makeMeta(int languageId, int tokenType, int fontStyle, int foreground, int background) =>
    ((languageId & MetadataConsts.languageIdMask) << MetadataConsts.languageIdOffset) |
    ((tokenType << MetadataConsts.tokenTypeOffset) & MetadataConsts.tokenTypeMask) |
    ((fontStyle << MetadataConsts.fontStyleOffset) & MetadataConsts.fontStyleMask) |
    ((foreground << MetadataConsts.foregroundOffset) & MetadataConsts.foregroundMask) |
    ((background << MetadataConsts.backgroundOffset) & MetadataConsts.backgroundMask);

void main() {
  final truth = _truth();
  final List<String> colorMap = (truth['colorMap'] as List).cast<String>();

  group('batch255 nullTokenize', () {
    test('NullState identity semantics', () {
      final ns = _map(truth['nullState']);
      expect(identical(NullState.instance.clone(), NullState.instance),
          equals(ns['cloneIsSame']));
      expect(NullState.instance.equals(NullState.instance), equals(ns['equalsSelf']));
      expect(NullState.instance.equals(null), equals(ns['equalsNull']));
      expect(NullState.instance.equals(Object()), equals(ns['equalsOtherObject']));
    });

    test('nullTokenize', () {
      final s = _map(truth['standard']);
      final r = nullTokenize('python', NullState.instance);
      final t0 = _map(s['token0']);
      expect(r.tokens.length, equals(s['tokenCount']));
      expect(r.tokens[0].offset, equals(t0['offset']));
      expect(r.tokens[0].type, equals(t0['type']));
      expect(r.tokens[0].language, equals(t0['language']));
      expect(r.tokens[0].toString(), equals(t0['toString']));
      expect(identical(r.endState, NullState.instance), equals(s['endStateIsNull']));
    });

    for (final raw in (truth['encoded'] as List)) {
      final c = _map(raw);
      test('nullTokenizeEncoded ${c['label']}', () {
        final int languageId = (c['label'] as String).contains('lang-255')
            ? 255
            : (c['label'] as String).contains('lang-5')
                ? 5
                : (c['label'] as String).contains('lang-1')
                    ? 1
                    : 0;
        final Object? state = c['stateLabel'] == 'custom' ? Object() : null;
        final r = nullTokenizeEncoded(languageId, state);
        expect(r.tokens.length, equals(c['tokenLength']));
        expect(r.tokens[0], equals(c['token0']));
        expect(r.tokens[1], equals(c['token1']));
        expect(r.fontInfo.length, equals(c['fontInfoLen']));
        final isNullState = identical(r.endState, NullState.instance);
        expect(isNullState, equals(c['endStateIsNullState']));
        if (c['stateLabel'] == 'custom') {
          expect(identical(r.endState, state), isTrue);
        }
      });
    }
  });

  group('batch255 TestLineToken', () {
    test('metadata getters', () {
      for (final raw in (truth['tokens'] as List)) {
        final c = _map(raw);
        final int endIndex = (c['endIndex'] as num).toInt();
        final int meta = _metaFromLabel(c['label'] as String);
        final t = TestLineToken(endIndex, meta);
        expect(t.endIndex, equals(c['endIndex']));
        expect(t.getStandardTokenType(), equals(c['standardTokenType']),
            reason: '${c['label']} getStandardTokenType');
        expect(t.getForeground(), equals(c['foreground']),
            reason: '${c['label']} getForeground');
        expect(t.getType(), equals(c['type']), reason: '${c['label']} getType');
        expect(t.getInlineStyle(colorMap), equals(c['inlineStyle']),
            reason: '${c['label']} getInlineStyle');
        expect(_presentationOut(t.getPresentation()), equals(c['presentation']),
            reason: '${c['label']} getPresentation');
      }
    });

    test('equalsArr', () {
      final e = _map(truth['equalsArr']);
      final tA = TestLineToken(3, _makeMeta(0, StandardTokenType.comment, FontStyle.none, 1, 0));
      final tB = TestLineToken(3, _makeMeta(0, StandardTokenType.comment, FontStyle.none, 1, 0));
      final tC = TestLineToken(4, _makeMeta(0, StandardTokenType.comment, FontStyle.none, 1, 0));
      final tD = TestLineToken(3, _makeMeta(0, StandardTokenType.other, FontStyle.none, 1, 0));
      expect(TestLineToken.equalsArr([], []), equals(e['emptyEmpty']));
      expect(TestLineToken.equalsArr([tA, tB], [tA, tB]), equals(e['same']));
      expect(TestLineToken.equalsArr([tA], [tA, tB]), equals(e['diffLength']));
      expect(TestLineToken.equalsArr([tA], [tC]), equals(e['diffEndIndex']));
      expect(TestLineToken.equalsArr([tA], [tD]), equals(e['diffMetadata']));
    });

    test('inflateArr', () {
      final inf = _map(truth['inflate']);
      final u32 = Uint32List.fromList([
        3, _makeMeta(0, StandardTokenType.comment, FontStyle.none, 1, 0),
        7, _makeMeta(1, StandardTokenType.other, FontStyle.bold, 2, 0),
        12, 0,
      ]);
      final inflated = TestLineTokenFactory.inflateArr(u32);
      expect(inflated.length, equals(inf['count']));
      for (var i = 0; i < inflated.length; i++) {
        final expected = _map((inf['tokens'] as List)[i]);
        expect(inflated[i].endIndex, equals(expected['endIndex']));
        expect(inflated[i].getStandardTokenType(), equals(expected['standardTokenType']));
        expect(inflated[i].getForeground(), equals(expected['foreground']));
        expect(inflated[i].getType(), equals(expected['type']));
        expect(inflated[i].getInlineStyle(colorMap), equals(expected['inlineStyle']));
      }
      expect(TestLineTokenFactory.inflateArr(Uint32List(0)).length, equals(inf['empty']));
    });
  });

  group('batch255 TestLineTokens', () {
    for (final raw in (truth['lineTokens'] as List)) {
      final c = _map(raw);
      test(c['label'] as String, () {
        final lt = _lineTokensFromLabel(c['label'] as String);
        expect(lt.getCount(), equals(c['count']));
        final n = lt.getCount();
        final standardTypes = <int>[];
        final foregrounds = <int>[];
        final endOffsets = <int>[];
        final classNames = <String>[];
        final inlineStyles = <String>[];
        final presentations = <List<dynamic>>[];
        for (var i = 0; i < n; i++) {
          standardTypes.add(lt.getStandardTokenType(i));
          foregrounds.add(lt.getForeground(i));
          endOffsets.add(lt.getEndOffset(i));
          classNames.add(lt.getClassName(i));
          inlineStyles.add(lt.getInlineStyle(i, colorMap));
          presentations.add(_presentationOut(lt.getPresentation(i)));
        }
        expect(_same(standardTypes, c['standardTypes']), isTrue, reason: 'standardTypes');
        expect(_same(foregrounds, c['foregrounds']), isTrue, reason: 'foregrounds');
        expect(_same(endOffsets, c['endOffsets']), isTrue, reason: 'endOffsets');
        expect(_same(classNames, c['classNames']), isTrue, reason: 'classNames');
        expect(_same(inlineStyles, c['inlineStyles']), isTrue, reason: 'inlineStyles');
        expect(_same(presentations, c['presentations']), isTrue, reason: 'presentations');
      });
    }

    test('equals', () {
      final e = _map(truth['lineTokensEquals']);
      final tA = TestLineToken(3, _makeMeta(0, StandardTokenType.comment, FontStyle.none, 1, 0));
      final tB = TestLineToken(3, _makeMeta(0, StandardTokenType.comment, FontStyle.none, 1, 0));
      final tC = TestLineToken(4, _makeMeta(0, StandardTokenType.comment, FontStyle.none, 1, 0));
      final lt1 = TestLineTokens([tA, tB]);
      final lt2 = TestLineTokens([tA, tB]);
      final lt3 = TestLineTokens([tA, tC]);
      expect(lt1.equals(lt2), equals(e['same']));
      expect(lt1.equals(lt3), equals(e['diff']));
      expect(lt1.equals(Object()), equals(e['crossType']));
      expect(lt1.equals(null), equals(e['crossNull']));
    });
  });
}

List<dynamic> _presentationOut(ITokenPresentation p) =>
    [p.foreground, p.italic, p.bold, p.underline, p.strikethrough];

/// Metadata used by each `tokenCase` in the harness — mirrors the labels.
int _metaFromLabel(String label) {
  switch (label) {
    case 'meta-0':
      return 0;
    case 'comment':
      return _makeMeta(0, StandardTokenType.comment, FontStyle.none, ColorId.none, 0);
    case 'keyword-bold':
      return _makeMeta(1, StandardTokenType.other, FontStyle.bold, ColorId.none, 0);
    case 'string-italic':
      return _makeMeta(2, StandardTokenType.string, FontStyle.italic | FontStyle.underline, ColorId.none, 0);
    case 'number-strike':
      return _makeMeta(3, StandardTokenType.regEx, FontStyle.strikethrough, ColorId.none, 0);
    case 'custom-fg':
      // Harness used StandardTokenType.Identifier (undefined in TS) -> 0 in bit math.
      return _makeMeta(4, StandardTokenType.other, FontStyle.none, 7, 0);
    case 'max-meta':
      return 0xFFFFFFFF;
    default:
      throw StateError('unknown token label $label');
  }
}

TestLineTokens _lineTokensFromLabel(String label) {
  final tA = TestLineToken(3, _makeMeta(0, StandardTokenType.comment, FontStyle.none, 1, 0));
  switch (label) {
    case 'empty':
      return TestLineTokens([]);
    case 'one':
      return TestLineTokens([
        TestLineToken(5, _makeMeta(0, StandardTokenType.string, FontStyle.none, ColorId.none, 0))
      ]);
    case 'multi':
      return TestLineTokens([
        tA,
        TestLineToken(9, _makeMeta(2, StandardTokenType.other, FontStyle.bold, 4, 0))
      ]);
    default:
      throw StateError('unknown lineTokens label $label');
  }
}
