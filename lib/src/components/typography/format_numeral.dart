/// Formatting rules supported by [formatNumeral].
enum SemiNumeralRule {
  text,
  numbers,
  bytesDecimal,
  bytesBinary,
  percentages,
  exponential,
}

/// Round ties toward positive infinity, or round toward the indicated bound.
enum SemiNumeralTruncate { round, ceil, floor }

final _fragments = RegExp(r'(-?[0-9]*\.?[0-9]+([eE]-?[0-9]+)?)|([^-\d\.]+)');

/// Formats numeric fragments using Semi Typography's extraction rules.
/// A custom [parser] takes precedence, including over precision validation.
String formatNumeral(
  String content, {
  SemiNumeralRule rule = SemiNumeralRule.text,
  int precision = 0,
  SemiNumeralTruncate truncate = SemiNumeralTruncate.round,
  String Function(String)? parser,
}) {
  if (parser != null) return parser(content);
  RangeError.checkValueInInterval(precision, 0, 98, 'precision');
  final result = <String>[];
  for (final match in _fragments.allMatches(content)) {
    final fragment = match[0]!;
    final value = double.tryParse(fragment);
    if (value == null || !value.isFinite) {
      if (rule != SemiNumeralRule.numbers || value != null) {
        result.add(fragment);
      }
      continue;
    }
    String fixed(double v) => _fixed(v, precision, truncate);
    switch (rule) {
      case SemiNumeralRule.text:
      case SemiNumeralRule.numbers:
        result.add(fixed(value));
      case SemiNumeralRule.bytesDecimal:
      case SemiNumeralRule.bytesBinary:
        final binary = rule == SemiNumeralRule.bytesBinary;
        final units = binary
            ? const [
                'B',
                'KiB',
                'MiB',
                'GiB',
                'TiB',
                'PiB',
                'EiB',
                'ZiB',
                'YiB',
              ]
            : const ['B', 'KB', 'MB', 'GB', 'TB', 'PB', 'EB', 'ZB', 'YB'];
        var scaled = value;
        var unit = 0;
        final base = binary ? 1024 : 1000;
        while (scaled >= base && unit < units.length - 1) {
          scaled /= base;
          unit++;
        }
        result.add('${fixed(scaled)} ${units[unit]}');
      case SemiNumeralRule.percentages:
        final parts = value.toString().split('e');
        final shifted = double.parse(
          '${parts[0]}e${(parts.length == 2 ? int.parse(parts[1]) : 0) + 2}',
        );
        result.add(shifted.isFinite ? '${fixed(shifted)}%' : fragment);
      case SemiNumeralRule.exponential:
        // Dart supports 0..20 fraction digits. Beyond that the extra digits
        // cannot change the parsed double mantissa used by upstream.
        final digits = (precision + 2).clamp(0, 20);
        final parts = value.toStringAsExponential(digits).split('e');
        result.add('${fixed(double.parse(parts[0]))}e${parts[1]}');
    }
  }
  return result.join(rule == SemiNumeralRule.numbers ? ',' : '');
}

String _fixed(double value, int precision, SemiNumeralTruncate mode) {
  final negative = value < 0;
  final parts = value.abs().toString().split('e');
  final mantissa = parts[0].split('.');
  final digits = BigInt.parse(mantissa.join());
  final exponent =
      (parts.length == 2 ? int.parse(parts[1]) : 0) -
      (mantissa.length == 2 ? mantissa[1].length : 0) +
      precision;
  BigInt rounded;
  if (exponent >= 0) {
    rounded = digits * BigInt.from(10).pow(exponent);
  } else {
    final divisor = BigInt.from(10).pow(-exponent);
    rounded = digits ~/ divisor;
    final remainder = digits.remainder(divisor);
    final increment = switch (mode) {
      SemiNumeralTruncate.ceil => !negative && remainder != BigInt.zero,
      SemiNumeralTruncate.floor => negative && remainder != BigInt.zero,
      SemiNumeralTruncate.round =>
        negative
            ? remainder * BigInt.two > divisor
            : remainder * BigInt.two >= divisor,
    };
    if (increment) rounded += BigInt.one;
  }
  final sign = negative && rounded != BigInt.zero ? '-' : '';
  final text = rounded.toString().padLeft(precision + 1, '0');
  final fixed = precision == 0
      ? text
      : '${text.substring(0, text.length - precision)}.${text.substring(text.length - precision)}';
  // Like Number.toFixed, large magnitudes use scientific notation.
  if (value.abs() >= 1e21) {
    final scientific = double.parse('$sign$fixed').toString();
    return scientific.replaceFirst('.0e', 'e');
  }
  return '$sign$fixed';
}
