import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:semi_design_flutter/semi_design_flutter.dart';

import 'semi_text_test.dart' show host, textStyle;

void main() {
  test('upstream decimal precision and negative midpoint semantics', () {
    for (final row in <(String, int, SemiNumeralTruncate, String)>[
      ('0.29', 2, SemiNumeralTruncate.floor, '0.29'),
      ('0.07', 2, SemiNumeralTruncate.ceil, '0.07'),
      ('-0.29', 2, SemiNumeralTruncate.ceil, '-0.29'),
      ('-0.07', 2, SemiNumeralTruncate.floor, '-0.07'),
      ('1.005', 2, SemiNumeralTruncate.round, '1.01'),
      ('-1.005', 2, SemiNumeralTruncate.round, '-1.00'),
      ('1.234', 2, SemiNumeralTruncate.floor, '1.23'),
      ('1.234', 2, SemiNumeralTruncate.ceil, '1.24'),
      ('1e-7', 8, SemiNumeralTruncate.round, '0.00000010'),
    ]) {
      expect(
        formatNumeral(row.$1, precision: row.$2, truncate: row.$3),
        row.$4,
      );
    }
    for (final mode in SemiNumeralTruncate.values) {
      expect(
        formatNumeral('1.5', truncate: mode),
        mode == SemiNumeralTruncate.floor ? '1' : '2',
      );
      expect(
        formatNumeral('-1.5', truncate: mode),
        mode == SemiNumeralTruncate.floor ? '-2' : '-1',
      );
    }
  });

  test('extraction, mixed text, parser precedence and invalid precision', () {
    expect(formatNumeral(''), '');
    expect(formatNumeral('中文😀 - . + 1.2 / -3.5'), '中文😀   + 1 / -3');
    expect(
      formatNumeral('a1 b2.5 c-3', rule: SemiNumeralRule.numbers),
      '1,3,-3',
    );
    expect(formatNumeral('1e+3'), '1e+3');
    expect(formatNumeral('NaN Infinity -Infinity'), 'NaN Infinity Infinity');
    expect(formatNumeral('1e999'), '1e999');
    expect(formatNumeral('x1e999', rule: SemiNumeralRule.numbers), '1e999');
    expect(formatNumeral('raw', precision: -1, parser: (s) => '[$s]'), '[raw]');
    for (final p in [-1, 99]) {
      expect(() => formatNumeral('', precision: p), throwsRangeError);
    }
  });

  test('all precisions, tiny values and negative zero', () {
    for (var p = 0; p <= 98; p++) {
      expect(formatNumeral('1', precision: p), p == 0 ? '1' : '1.${'0' * p}');
      expect(formatNumeral('-0', precision: p), p == 0 ? '0' : '0.${'0' * p}');
      expect(
        formatNumeral(
          '1e-300',
          precision: p,
          truncate: SemiNumeralTruncate.ceil,
        ),
        p == 0 ? '1' : '0.${'0' * (p - 1)}1',
      );
      expect(
        formatNumeral('1', rule: SemiNumeralRule.exponential, precision: p),
        '${p == 0 ? '1' : '1.${'0' * p}'}e+0',
      );
    }
    expect(formatNumeral('5e-324'), '0');
  });

  test('percentages use exponent shift and preserve overflow', () {
    for (final row in <(String, int, SemiNumeralTruncate, String)>[
      ('0.07', 0, SemiNumeralTruncate.ceil, '7%'),
      ('0.29', 0, SemiNumeralTruncate.floor, '29%'),
      ('-0.07', 0, SemiNumeralTruncate.floor, '-7%'),
      ('1e-7', 5, SemiNumeralTruncate.ceil, '0.00001%'),
      ('0.07123', 2, SemiNumeralTruncate.floor, '7.12%'),
      ('0.07123', 2, SemiNumeralTruncate.ceil, '7.13%'),
      ('0.01005', 2, SemiNumeralTruncate.round, '1.01%'),
    ]) {
      expect(
        formatNumeral(
          row.$1,
          rule: SemiNumeralRule.percentages,
          precision: row.$2,
          truncate: row.$3,
        ),
        row.$4,
      );
    }
    expect(formatNumeral('1e308', rule: SemiNumeralRule.percentages), '1e308');
  });

  test('bytes thresholds, caps, negative and rounded unit stability', () {
    for (final rule in [
      SemiNumeralRule.bytesDecimal,
      SemiNumeralRule.bytesBinary,
    ]) {
      final binary = rule == SemiNumeralRule.bytesBinary;
      expect(
        formatNumeral(binary ? '1024' : '1000', rule: rule),
        binary ? '1 KiB' : '1 KB',
      );
      expect(formatNumeral('-2048', rule: rule), '-2048 B');
      expect(formatNumeral('0', rule: rule), '0 B');
      expect(
        formatNumeral('1e308', rule: rule),
        endsWith(binary ? ' YiB' : ' YB'),
      );
    }
    expect(
      formatNumeral('999.9', rule: SemiNumeralRule.bytesDecimal),
      '1000 B',
    );
    expect(
      formatNumeral('1023.9', rule: SemiNumeralRule.bytesBinary),
      '1024 B',
    );
    expect(
      formatNumeral('9.999', rule: SemiNumeralRule.exponential, precision: 2),
      '10.00e+0',
    );
    expect(
      formatNumeral('1e-300', rule: SemiNumeralRule.exponential, precision: 2),
      '1.00e-300',
    );
  });

  testWidgets('composes without Material, updates formatting and theme', (
    t,
  ) async {
    await t.pumpWidget(host(const SemiNumeral('1.005', precision: 2)));
    expect(find.text('1.01'), findsOneWidget);
    await t.pumpWidget(
      host(
        const SemiNumeral('0.29', rule: SemiNumeralRule.percentages),
        theme: const SemiThemeData.dark(),
      ),
    );
    expect(find.text('29%'), findsOneWidget);
    expect(textStyle(t).color, const SemiThemeData.dark().colors.colorText0);
    await t.pumpWidget(
      host(SemiNumeral('raw', precision: -1, parser: (_) => 'custom')),
    );
    expect(find.text('custom'), findsOneWidget);
    for (final color in [const Color(0xff123456), const Color(0xff654321)]) {
      await t.pumpWidget(
        host(
          SemiTypographyTheme(
            data: SemiTypographyThemeData(defaultTextColor: color),
            child: const SemiNumeral('1.5'),
          ),
        ),
      );
      expect(textStyle(t).color, color);
    }
  });

  testWidgets('forwards layout, decorations, link keyboard and semantics', (
    t,
  ) async {
    var taps = 0;
    Widget numeral(bool disabled) => host(
      SizedBox(
        width: 80,
        child: SemiNumeral(
          '1234567890.1234',
          precision: 2,
          code: true,
          mark: true,
          strong: true,
          underline: true,
          delete: true,
          disabled: disabled,
          type: SemiTextType.warning,
          size: SemiTextSize.small,
          weight: FontWeight.w700,
          style: const TextStyle(letterSpacing: 2),
          icon: const SizedBox(width: 8, height: 8),
          link: SemiTextLink(onTap: () => taps++, visited: true),
          textAlign: TextAlign.right,
          textDirection: TextDirection.ltr,
          maxLines: 1,
          softWrap: false,
          overflow: TextOverflow.ellipsis,
          semanticsLabel: 'amount',
        ),
      ),
    );
    final handle = t.ensureSemantics();
    await t.pumpWidget(numeral(false));
    final text = t.widget<Text>(find.byType(Text));
    expect(text.maxLines, 1);
    expect(text.overflow, TextOverflow.ellipsis);
    expect(text.softWrap, false);
    expect(text.textAlign, TextAlign.right);
    expect(text.style!.fontWeight, FontWeight.w700);
    expect(text.style!.letterSpacing, 2);
    expect(text.style!.decoration!.contains(TextDecoration.lineThrough), true);
    expect(find.bySemanticsLabel('amount'), findsOneWidget);
    await t.tap(find.byType(Text));
    expect(taps, 1);
    Focus.of(t.element(find.byType(GestureDetector))).requestFocus();
    await t.pump();
    await t.sendKeyEvent(LogicalKeyboardKey.enter);
    expect(taps, 2);
    await t.pumpWidget(numeral(true));
    await t.sendKeyEvent(LogicalKeyboardKey.enter);
    await t.tap(find.byType(Text));
    expect(taps, 2);
    expect(t.takeException(), isNull);
    handle.dispose();
  });
}
