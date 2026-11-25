// ---------------------------------------------------------------------------
// 1:1 port of
// vscode/src/vs/editor/common/languages/supports/inplaceReplaceSupport.ts
// (99 lines).
//
// `BasicInplaceReplace` navigates a value up/down: numbers step by one unit of
// their last decimal place, and a fixed set of text values cycles.
//
// Adaptations:
//   - `IRange` is the ported interface; `IInplaceReplaceSupportResult` is an
//     erased interface in TS and becomes the carrier class below.
//   - JS `Number(x)` / `parseFloat(x)` semantics are re-created (`_jsNumber`
//     trims and treats the empty string as 0; `_jsParseFloat` parses the
//     longest numeric prefix and yields NaN otherwise) because the source
//     requires both to agree.
//   - `Math.pow(10, n)` -> `pow(10, n)`; `Math.floor` -> `.floor()`.
//   - `String(number)` is reproduced by `_jsNumString` (integral doubles print
//     without `.0`, matching JS).
// ---------------------------------------------------------------------------

import 'dart:math' as math;

import '../../core/range.dart' show IRange;

/// 1:1: `export interface IInplaceReplaceSupportResult`
class IInplaceReplaceSupportResult {
  IInplaceReplaceSupportResult(this.range, this.value);

  final IRange range;
  final String value;
}

class BasicInplaceReplace {
  BasicInplaceReplace._();

  static final BasicInplaceReplace INSTANCE = BasicInplaceReplace._();

  IInplaceReplaceSupportResult? navigateValueSet(IRange? range1, String? text1,
      IRange? range2, String? text2, bool up) {
    if (range1 != null && _truthy(text1)) {
      final String? result = doNavigateValueSet(text1!, up);
      if (result != null) {
        return IInplaceReplaceSupportResult(range1, result);
      }
    }

    if (range2 != null && _truthy(text2)) {
      final String? result = doNavigateValueSet(text2!, up);
      if (result != null) {
        return IInplaceReplaceSupportResult(range2, result);
      }
    }

    return null;
  }

  String? doNavigateValueSet(String text, bool up) {
    final String? numberResult = numberReplace(text, up);
    if (numberResult != null) {
      return numberResult;
    }
    return textReplace(text, up);
  }

  String? numberReplace(String value, bool up) {
    final num precision =
        math.pow(10, value.length - (value.lastIndexOf('.') + 1));
    num n1 = _jsNumber(value);
    final num n2 = _jsParseFloat(value);

    if (!n1.isNaN && !n2.isNaN && n1 == n2) {
      if (n1 == 0 && !up) {
        return null; // don't do negative
        //			} else if(n1 === 9 && up) {
        //				return null; // don't insert 10 into a number
      } else {
        n1 = (n1 * precision).floor();
        n1 += up ? precision : -precision;
        return _jsNumString(n1 / precision);
      }
    }

    return null;
  }

  final List<List<String>> _defaultValueSet = <List<String>>[
    <String>['true', 'false'],
    <String>['True', 'False'],
    <String>[
      'Private',
      'Public',
      'Friend',
      'ReadOnly',
      'Partial',
      'Protected',
      'WriteOnly'
    ],
    <String>['public', 'protected', 'private'],
  ];

  String? textReplace(String value, bool up) {
    return valueSetsReplace(_defaultValueSet, value, up);
  }

  String? valueSetsReplace(List<List<String>> valueSets, String value, bool up) {
    String? result = null;
    for (int i = 0, len = valueSets.length; result == null && i < len; i++) {
      result = valueSetReplace(valueSets[i], value, up);
    }
    return result;
  }

  String? valueSetReplace(List<String> valueSet, String value, bool up) {
    int idx = valueSet.indexOf(value);
    if (idx >= 0) {
      idx += up ? 1 : -1;
      if (idx < 0) {
        idx = valueSet.length - 1;
      } else {
        idx %= valueSet.length;
      }
      return valueSet[idx];
    }
    return null;
  }
}

/// JS truthiness for the `if (range1 && text1)` guards.
bool _truthy(Object? value) {
  if (value == null || value == false) return false;
  if (value is num) return value != 0 && !value.isNaN;
  if (value is String) return value.isNotEmpty;
  return true;
}

/// JS `Number(value)` for the string inputs the source sees.
num _jsNumber(String value) {
  final String trimmed = value.trim();
  if (trimmed.isEmpty) {
    return 0;
  }
  final num? parsed = num.tryParse(trimmed);
  return parsed ?? double.nan;
}

/// JS `parseFloat(value)`: parse the longest numeric prefix, else NaN.
num _jsParseFloat(String value) {
  final RegExpMatch? match = RegExp(
          r'^[\s]*[+-]?(\d+\.?\d*|\.\d+)([eE][+-]?\d+)?')
      .firstMatch(value);
  if (match == null) {
    return double.nan;
  }
  final num? parsed = num.tryParse(match.group(0)!.trim());
  return parsed ?? double.nan;
}

/// JS `String(number)`: integral values have no fractional part.
String _jsNumString(num value) {
  if (value is int) {
    return value.toString();
  }
  final double d = value as double;
  if (d.isFinite && d == d.truncateToDouble() && d.abs() < 1e21) {
    return d.toInt().toString();
  }
  return d.toString();
}