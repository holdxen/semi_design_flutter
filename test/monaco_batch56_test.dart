import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:semi_design_flutter/src/monaco/platform/contextkey/common/contextkey.dart';

/// Sample context matching the Node truth harness `c.getValue` map.
class _SampleContext implements IContext {
  static const Map<String, Object?> values = <String, Object?>{
    'foo': 'bar', 'bar': true, 'baz': 7, 'a': 15,
    'languageId': 'python', 'some': <String, Object?>{'key': 'value'},
  };
  @override
  Object? getValue(String key) => values[key];
}

class _NoopMapper implements IContextKeyExprMapper {
  @override ContextKeyExpression mapDefined(String key) => ContextKeyExpr.has(key);
  @override ContextKeyExpression mapNot(String key) => ContextKeyExpr.not(key);
  @override ContextKeyExpression mapEquals(String key, Object? value) => ContextKeyExpr.equals(key, value);
  @override ContextKeyExpression mapNotEquals(String key, Object? value) => ContextKeyExpr.notEquals(key, value);
  @override ContextKeyExpression mapGreater(String key, Object? value) => ContextKeyGreaterExpr.create(key, value);
  @override ContextKeyExpression mapGreaterEquals(String key, Object? value) => ContextKeyGreaterEqualsExpr.create(key, value);
  @override ContextKeyExpression mapSmaller(String key, Object? value) => ContextKeySmallerExpr.create(key, value);
  @override ContextKeyExpression mapSmallerEquals(String key, Object? value) => ContextKeySmallerEqualsExpr.create(key, value);
  @override ContextKeyExpression mapRegex(String key, ContextKeyRegexp? regexp) => ContextKeyRegexExpr.create(key, regexp);
  @override ContextKeyExpression mapIn(String key, String valueKey) => ContextKeyExpr.in_(key, valueKey);
  @override ContextKeyExpression mapNotIn(String key, String valueKey) => ContextKeyExpr.notIn(key, valueKey);
}

/// batch56: 1:1 port of contextkey.ts (2200-line parser + expression hub,
/// 120 downstream deps). Truth captured by tool/ts2dart/_ctxkey_truth.cjs
/// (real TS transpile+vm) into tool/ts2dart/ctxkey_truth.json; every assertion
/// mirrors one truth record so parse/serialize/evaluate/negate/keys/implies
/// match the TypeScript source exactly.
void main() {
  final truth = jsonDecode(File('tool/ts2dart/ctxkey_truth.json').readAsStringSync()) as Map<String, dynamic>;
  final ctx = _SampleContext();

  ContextKeyExpression? parseStrict(String input) =>
      Parser(const ParserConfig(regexParsingWithErrorRecovery: false)).parse(input);
  String? ser(ContextKeyExpression? e) => e?.serialize();

  group('batch56 / contextkey 1:1', () {
    test('ContextKeyExprType values match TS const enum', () {
      final t = truth['types'] as Map<String, dynamic>;
      expect(ContextKeyExprType.False, t['False']);
      expect(ContextKeyExprType.True, t['True']);
      expect(ContextKeyExprType.Defined, t['Defined']);
      expect(ContextKeyExprType.Not, t['Not']);
      expect(ContextKeyExprType.Equals, t['Equals']);
      expect(ContextKeyExprType.NotEquals, t['NotEquals']);
      expect(ContextKeyExprType.And, t['And']);
      expect(ContextKeyExprType.Regex, t['Regex']);
      expect(ContextKeyExprType.NotRegex, t['NotRegex']);
      expect(ContextKeyExprType.Or, t['Or']);
      expect(ContextKeyExprType.In, t['In']);
      expect(ContextKeyExprType.NotIn, t['NotIn']);
      expect(ContextKeyExprType.Greater, t['Greater']);
      expect(ContextKeyExprType.GreaterEquals, t['GreaterEquals']);
      expect(ContextKeyExprType.Smaller, t['Smaller']);
      expect(ContextKeyExprType.SmallerEquals, t['SmallerEquals']);
    });

    test('all 49 expressions: parse / serialize / evaluate / negate / keys match TS truth', () {
      final exprs = truth['exprs'] as List<dynamic>;
      for (final rec in exprs) {
        final input = rec['input'] as String;
        final expr = parseStrict(input);
        if (rec['parse'] == 'undefined') {
          expect(expr, isNull, reason: 'parse("$input") should be undefined');
          continue;
        }
        expect(expr, isNotNull, reason: 'parse("$input") should succeed');
        expect(ser(expr), rec['serialize'], reason: 'serialize("$input")');
        expect(expr!.type, rec['type'], reason: 'type("$input")');
        expect(expr.evaluate(ctx), rec['evaluate'], reason: 'evaluate("$input")');
        expect(ser(expr.negate()), rec['negate'], reason: 'negate("$input")');
        final keys = expr.keys();
        final expectedKeys = (rec['keys'] as List<dynamic>).cast<String>();
        expect(keys, expectedKeys, reason: 'keys("$input")');
      }
    });

    test('implies battery matches TS truth', () {
      for (final rec in truth['implies'] as List<dynamic>) {
        final p = parseStrict(rec['a'] as String)!;
        final q = parseStrict(rec['b'] as String)!;
        expect(implies(p, q), rec['result'],
            reason: 'implies(${rec['a']}, ${rec['b']})');
      }
    });

    test('validateWhenClauses error offsets/messages match TS truth', () {
      final clauses = <String>['foo', 'foo &&', 'foo =~ /abc/', ''];
      final result = validateWhenClauses(clauses);
      final expected = truth['validate'] as List<dynamic>;
      for (int i = 0; i < clauses.length; i++) {
        final errs = result[i];
        final exp = expected[i] as List<dynamic>;
        expect(errs.length, exp.length, reason: 'errors for "${clauses[i]}"');
        for (int j = 0; j < errs.length; j++) {
          expect(errs[j]['offset'], exp[j]['offset']);
          expect(errs[j]['length'], exp[j]['length']);
          expect(errs[j]['errorMessage'], exp[j]['errorMessage']);
        }
      }
    });

    test('constant folding + setConstant + deserialize', () {
      expect(ContextKeyExpr.has('true').serialize(), 'true');
      expect(ContextKeyExpr.has('false').serialize(), 'false');
      expect(ContextKeyExpr.equals('foo', true).serialize(), 'foo');
      expect(ContextKeyExpr.equals('foo', false).serialize(), '!foo');
      expect(expressionsAreEqualWithConstantSubstitution(
        ContextKeyExpr.has('true'), ContextKeyExpr.true_()), isTrue);
      expect(ContextKeyExpr.deserialize(null), isNull);
      expect(ContextKeyExpr.deserialize('foo && bar')!.serialize(), 'bar && foo'); // AND terms sorted by cmp
      // setConstant registers a new boolean constant (folding on subsequent create)
      setConstant('myStartupFlag', true);
      expect(ContextKeyExpr.has('myStartupFlag').serialize(), 'true');
      expect(() => setConstant('myStartupFlag', false), throwsA(isA<Error>()));
    });

    test('RawContextKey binds / records metadata / maps expressions', () {
      final key = RawContextKey<String>('myKey', 'def', 'A description');
      expect(key.serialize(), 'myKey');
      expect(key.toNegated().serialize(), '!myKey');
      expect(key.isEqualTo('v').serialize(), "myKey == 'v'");
      expect(key.notEqualsTo('v').serialize(), "myKey != 'v'");
      expect(key.greater(3).serialize(), 'myKey > 3');
      expect(RawContextKey.all().any((i) => i.key == 'myKey'), isTrue);
      // map() dispatches to the mapper for each expr shape
      final mapped = ContextKeyExpr.has('mapped').map(_NoopMapper());
      expect(mapped.serialize(), 'mapped');
    });
  });
}
