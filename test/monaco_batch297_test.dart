// batch297: tokenizationTextModelPart.ts truth replay.
// Truth from tool/ts2dart/batch297_truth.json (recursive TS transpile + vm,
// enum values and erased interface surface).
import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:semi_design_flutter/src/monaco/editor/common/core/range.dart'
    show Range;
import 'package:semi_design_flutter/src/monaco/editor/common/tokenizationTextModelPart.dart'
    show BackgroundTokenizationState, ITokenizationTextModelPart;
import 'package:semi_design_flutter/src/monaco/editor/common/tokens/lineTokens.dart'
    show ILanguageIdCodec, LineTokens;
import 'package:semi_design_flutter/src/monaco/editor/common/tokens/sparseMultilineTokens.dart'
    show SparseMultilineTokens;

Map<String, dynamic> _truth() => jsonDecode(
    File('tool/ts2dart/batch297_truth.json').readAsStringSync())
    as Map<String, dynamic>;

class _Codec implements ILanguageIdCodec {
  @override
  int encodeLanguageId(String languageId) => 1;

  @override
  String decodeLanguageId(int languageId) => 'plaintext';
}

/// Compile-time replay of the erased interface: every truth member must be
/// implemented by a concrete Dart carrier.
class _Part implements ITokenizationTextModelPart {
  final LineTokens _tokens = LineTokens.createEmpty('', _Codec());

  @override
  bool get hasTokens => false;

  @override
  void setSemanticTokens(List<SparseMultilineTokens>? tokens, bool isComplete) {}

  @override
  void setPartialSemanticTokens(
      Range range, List<SparseMultilineTokens>? tokens) {}

  @override
  bool hasCompleteSemanticTokens() => false;

  @override
  bool hasSomeSemanticTokens() => false;

  @override
  void resetTokenization() {}

  @override
  void forceTokenization(int lineNumber) {}

  @override
  void tokenizeIfCheap(int lineNumber) {}

  @override
  bool hasAccurateTokensForLine(int lineNumber) => false;

  @override
  bool isCheapToTokenize(int lineNumber) => false;

  @override
  LineTokens getLineTokens(int lineNumber) => _tokens;

  @override
  int getTokenTypeIfInsertingCharacter(
          int lineNumber, int column, String character) =>
      0;

  @override
  List<LineTokens>? tokenizeLinesAt(int lineNumber, List<String> lines) => null;

  @override
  String getLanguageId() => 'plaintext';

  @override
  String getLanguageIdAtPosition(int lineNumber, int column) => 'plaintext';

  @override
  void setLanguageId(String languageId, [String? source]) {}

  @override
  int get backgroundTokenizationState =>
      BackgroundTokenizationState.Completed;
}

void main() {
  final Map<String, dynamic> truth = _truth();
  final Map<String, dynamic> enumTruth = truth['enum'] as Map<String, dynamic>;

  test('enum values match truth', () {
    expect(BackgroundTokenizationState.InProgress,
        enumTruth['InProgress'] as int);
    expect(BackgroundTokenizationState.Completed, enumTruth['Completed'] as int);
  });

  test('interface surface matches truth and is implementable', () {
    final List<dynamic> declarations = truth['declarations'] as List<dynamic>;
    final Map<String, dynamic> iface = declarations.firstWhere(
        (dynamic d) => (d as Map<String, dynamic>)['kind'] == 'interface')
        as Map<String, dynamic>;
    expect(iface['name'], 'ITokenizationTextModelPart');
    expect(iface['members'], isA<List<dynamic>>());
    expect((iface['members'] as List<dynamic>).length, 17);

    final ITokenizationTextModelPart part = _Part();
    expect(part.backgroundTokenizationState,
        BackgroundTokenizationState.Completed);
    expect(part.getLineTokens(1).getCount(), 1);
  });
}
