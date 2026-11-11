import 'package:flutter/material.dart' show Material;
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:semi_design_flutter/semi_design_flutter.dart';

Widget host(
  Widget child, {
  TextDirection direction = TextDirection.ltr,
  double textScale = 1,
  double? width,
}) => Directionality(
  textDirection: direction,
  child: MediaQuery(
    data: MediaQueryData(textScaler: TextScaler.linear(textScale)),
    child: Center(
      child: width == null ? child : SizedBox(width: width, child: child),
    ),
  ),
);

const hostWidth = 300.0;

// 5 default-span items, the horizontalData.test.jsx fixture.
List<SemiDescriptionsItemData> createData() => [
  for (var i = 0; i < 5; i++)
    SemiDescriptionsItemData(label: 'Field $i', value: 'Value $i'),
];

(Object label, Object? value, bool hidden, int? span) recordOf(
  SemiDescriptionsItemData item,
) => (item.label, item.value, item.hidden, item.span);

int? lastSpan(List<List<SemiDescriptionsItemData>> rows) {
  final row = rows[rows.length - 1];
  return row[row.length - 1].span;
}

int alignColSpan(List<List<SemiDescriptionsItemData>> rows) =>
    lastSpan(rows)! * 2 - 1;

// A value probe that fills its slot width (tight infinity clamps to the
// incoming max) so slot geometry can be asserted through bounds.
Widget slotProbe(int i) =>
    SizedBox(width: double.infinity, key: ValueKey('v$i'));

void main() {
  test('grouping replicates horizontalData.test.jsx span semantics', () {
    final data = createData();
    final before = [for (final item in data) recordOf(item)];
    // column 3: [0 1 2] + [3 (4 -> 2)], like `lastSpan` 2 (plain) / 3 (align).
    var rows = semiDescriptionsHorizontalList(data, 3);
    expect(rows.length, 2);
    expect(rows[0].length, 3);
    expect(rows[1].length, 2);
    expect(lastSpan(rows), 2);
    expect(alignColSpan(rows), 3);
    // column 4: [0 1 2 3] + [(4 -> 4)].
    rows = semiDescriptionsHorizontalList(data, 4);
    expect(rows.length, 2);
    expect(rows[0].length, 4);
    expect(lastSpan(rows), 4);
    expect(alignColSpan(rows), 7);
    // column 2: [0 1] [2 3] [(4 -> 2)].
    rows = semiDescriptionsHorizontalList(data, 2);
    expect(rows.length, 3);
    expect(lastSpan(rows), 2);
    expect(alignColSpan(rows), 3);
    // Back to column 3.
    rows = semiDescriptionsHorizontalList(data, 3);
    expect(lastSpan(rows), 2);
    expect(alignColSpan(rows), 3);
    // No mutation across the board.
    expect([for (final item in data) recordOf(item)], before);
    expect(
      [for (final item in data) item.span],
      [null, null, null, null, null],
    );
  });

  test('grouping accepts frozen input items when filling the last row', () {
    const frozen = [
      SemiDescriptionsItemData(label: 'Field 0', value: 'Value 0'),
      SemiDescriptionsItemData(label: 'Field 1', value: 'Value 1'),
      SemiDescriptionsItemData(label: 'Field 2', value: 'Value 2'),
      SemiDescriptionsItemData(label: 'Field 3', value: 'Value 3'),
      SemiDescriptionsItemData(label: 'Field 4', value: 'Value 4'),
    ];
    final data = List<SemiDescriptionsItemData>.unmodifiable(frozen);
    final rows = semiDescriptionsHorizontalList(data, 3);
    expect(lastSpan(rows), 2);
    expect(alignColSpan(rows), 3);
    expect(
      [for (final item in data) item.span],
      [null, null, null, null, null],
    );
  });

  test('grouping preserves an explicit span after column changes', () {
    final data = [
      const SemiDescriptionsItemData(label: 'Field', value: 'Value', span: 2),
    ];
    var rows = semiDescriptionsHorizontalList(data, 3);
    // align colSpan = 2*2-1 = 3.
    expect(lastSpan(rows), 2);
    expect(alignColSpan(rows), 3);
    rows = semiDescriptionsHorizontalList(data, 4);
    expect(lastSpan(rows), 2);
    expect(alignColSpan(rows), 3);
    expect(data[0].span, 2);
    // Upstream `isNaN(span)` semantics: an explicit 1 is not widened either.
    const explicitOne = [
      SemiDescriptionsItemData(label: 'A', value: 'a'),
      SemiDescriptionsItemData(label: 'B', value: 'b', span: 1),
    ];
    rows = semiDescriptionsHorizontalList(explicitOne, 3);
    expect(rows.length, 1);
    expect(lastSpan(rows), 1);
  });

  test('grouping ignores hidden items without changing their span', () {
    final data = createData();
    data[3] = const SemiDescriptionsItemData(
      label: 'Field 3',
      value: 'Value 3',
      hidden: true,
    );
    final before = [for (final item in data) recordOf(item)];
    final rows = semiDescriptionsHorizontalList(data, 3);
    // Visible: 0 1 2 + (4 -> 3); align colSpan = 2*3-1 = 5.
    expect(rows.length, 2);
    expect(rows[0].length, 3);
    expect(rows[1].length, 1);
    expect(lastSpan(rows), 3);
    expect(alignColSpan(rows), 5);
    expect(data[3].hidden, isTrue);
    expect(data[3].span, isNull);
    expect([for (final item in data) recordOf(item)], before);
  });

  test('grouping boundaries: column 1, full single row, oversized span', () {
    final data = createData();
    // column 1: one item per row, nothing to fill.
    var rows = semiDescriptionsHorizontalList(data, 1);
    expect(rows.length, 5);
    expect([for (final row in rows) row.length], [1, 1, 1, 1, 1]);
    expect(lastSpan(rows), isNull);
    // Exactly full single row: no leftover to widen.
    rows = semiDescriptionsHorizontalList(data.sublist(0, 3), 3);
    expect(rows.length, 1);
    expect(lastSpan(rows), isNull);
    // Oversized span closes its row and shares it with what preceded it
    // (verified against upstream getHorizontalList).
    const oversized = [
      SemiDescriptionsItemData(label: 'A', value: 'a', span: 5),
    ];
    rows = semiDescriptionsHorizontalList(oversized, 3);
    expect(rows.length, 1);
    expect(lastSpan(rows), 5);
    const mixed = [
      SemiDescriptionsItemData(label: 'A', value: 'a'),
      SemiDescriptionsItemData(label: 'B', value: 'b', span: 5),
      SemiDescriptionsItemData(label: 'C', value: 'c'),
    ];
    rows = semiDescriptionsHorizontalList(mixed, 3);
    expect(rows.length, 2);
    expect(rows[0].length, 2);
    expect(rows[0][1].span, 5);
    expect(rows[1].length, 1);
    // The trailing item of the leftover row has no explicit span: widened.
    expect(lastSpan(rows), 3);
  });

  testWidgets('vertical align modes share the label column', (tester) async {
    Future<void> pumpAlign(SemiDescriptionsAlign align) async {
      await tester.pumpWidget(
        host(
          width: hostWidth,
          SemiDescriptions(
            align: align,
            items: const [
              SemiDescriptionsItemData(label: 'A', value: 'one'),
              SemiDescriptionsItemData(label: 'Long label', value: 'two'),
            ],
          ),
        ),
      );
    }

    Rect root() => tester.getRect(find.byType(SemiDescriptions));
    await pumpAlign(SemiDescriptionsAlign.center);
    var aKey = tester.getRect(find.text('A'));
    var longKey = tester.getRect(find.text('Long label'));
    var v1 = tester.getRect(find.text('one'));
    var v2 = tester.getRect(find.text('two'));
    // Label column shrinks to the widest key, all keys end-aligned in it.
    expect(aKey.right, longKey.right);
    expect(longKey.right, lessThan(root().right - 24));
    // Value column stretches from the shared edge; th gap 24.
    expect(v1.left, v2.left);
    expect(v1.left - longKey.right, 24);
    await pumpAlign(SemiDescriptionsAlign.justify);
    aKey = tester.getRect(find.text('A'));
    longKey = tester.getRect(find.text('Long label'));
    v1 = tester.getRect(find.text('one'));
    v2 = tester.getRect(find.text('two'));
    // justify: keys start-aligned, values end-aligned.
    expect(aKey.left, longKey.left);
    expect(aKey.left, root().left);
    expect(v1.right, v2.right);
    expect(v1.right, root().right);
    await pumpAlign(SemiDescriptionsAlign.left);
    aKey = tester.getRect(find.text('A'));
    longKey = tester.getRect(find.text('Long label'));
    v1 = tester.getRect(find.text('one'));
    v2 = tester.getRect(find.text('two'));
    // left: everything starts-aligned.
    expect(aKey.left, longKey.left);
    expect(aKey.left, root().left);
    expect(v1.left, v2.left);
    await tester.pumpWidget(host(const SizedBox()));
  });

  testWidgets('plain renders inline label colon gap value', (tester) async {
    await tester.pumpWidget(
      host(
        width: hostWidth,
        const SemiDescriptions(
          align: SemiDescriptionsAlign.plain,
          items: [SemiDescriptionsItemData(label: 'Label', value: 'Value')],
        ),
      ),
    );
    final colon = tester.getRect(find.text('Label:'));
    final value = tester.getRect(find.text('Value'));
    expect(find.text('Label:'), findsOneWidget);
    expect(value.left - colon.right, 8);
    await tester.pumpWidget(host(const SizedBox()));
  });

  testWidgets('horizontal cells split span columns like the fixed table', (
    tester,
  ) async {
    await tester.pumpWidget(
      host(
        width: hostWidth,
        SemiDescriptions(
          layout: SemiDescriptionsLayout.horizontal,
          column: 3,
          items: [
            SemiDescriptionsItemData(label: 'K0', value: slotProbe(0)),
            SemiDescriptionsItemData(label: 'K1', value: slotProbe(1)),
            SemiDescriptionsItemData(label: 'K2', value: slotProbe(2)),
            SemiDescriptionsItemData(label: 'K3', value: slotProbe(3), span: 2),
          ],
        ),
      ),
    );
    final root = tester.getRect(find.byType(SemiDescriptions));
    // unit = 300 / (3 * 2) = 50; span-1 item = 100 wide (label 50, value 50).
    final v0 = tester.getRect(find.byKey(const ValueKey('v0')));
    final v1 = tester.getRect(find.byKey(const ValueKey('v1')));
    final v2 = tester.getRect(find.byKey(const ValueKey('v2')));
    final v3 = tester.getRect(find.byKey(const ValueKey('v3')));
    expect(v0.width, 50);
    expect(v1.width, 50);
    expect(v2.width, 50);
    expect(v0.left, root.left + 50);
    expect(v1.left, root.left + 150);
    expect(v2.left, root.left + 250);
    // Last row: trailing span widened to 2 columns -> 200 wide item, value
    // takes 2*2-1 = 3 units = 150.
    expect(v3.width, 150);
    expect(v3.left, root.left + 50);
    await tester.pumpWidget(host(const SizedBox()));

    // Same-row span mix: [span 1][span 2] fills column 3 exactly.
    await tester.pumpWidget(
      host(
        width: hostWidth,
        SemiDescriptions(
          layout: SemiDescriptionsLayout.horizontal,
          column: 3,
          items: [
            SemiDescriptionsItemData(label: 'A', value: slotProbe(4)),
            SemiDescriptionsItemData(label: 'B', value: slotProbe(5), span: 2),
          ],
        ),
      ),
    );
    final v4 = tester.getRect(find.byKey(const ValueKey('v4')));
    final v5 = tester.getRect(find.byKey(const ValueKey('v5')));
    expect(v4.width, 50);
    expect(v5.width, 150);
    expect(v5.left, root.left + 150);
    await tester.pumpWidget(host(const SizedBox()));
  });

  testWidgets('horizontal plain item spans its span columns inline', (
    tester,
  ) async {
    await tester.pumpWidget(
      host(
        width: hostWidth,
        const SemiDescriptions(
          layout: SemiDescriptionsLayout.horizontal,
          align: SemiDescriptionsAlign.plain,
          column: 3,
          items: [
            SemiDescriptionsItemData(label: 'A', value: 'a'),
            SemiDescriptionsItemData(label: 'B', value: 'b'),
            SemiDescriptionsItemData(label: 'C', value: 'c'),
            SemiDescriptionsItemData(label: 'D', value: 'd'),
          ],
        ),
      ),
    );
    final root = tester.getRect(find.byType(SemiDescriptions));
    final a = tester.getRect(find.text('A:'));
    final b = tester.getRect(find.text('B:'));
    final c = tester.getRect(find.text('C:'));
    final d = tester.getRect(find.text('D:'));
    // Row 0 cells at 0..100/100..200/200..300; row 1 widened to 2 columns.
    expect(a.left, root.left);
    expect(b.left, root.left + 100);
    expect(c.left, root.left + 200);
    expect(d.left, root.left);
    await tester.pumpWidget(host(const SizedBox()));
  });

  testWidgets('double row size tiers drive value size weight and paddings', (
    tester,
  ) async {
    const valueSizes = [16.0, 20.0, 28.0];
    const keySizes = [12.0, 14.0, 14.0];
    const endPaddings = [48.0, 60.0, 80.0];
    const keyBottoms = [0.0, 4.0, 4.0];
    for (var i = 0; i < SemiDescriptionsSize.values.length; i++) {
      final size = SemiDescriptionsSize.values[i];
      await tester.pumpWidget(
        host(
          width: 400,
          SemiDescriptions(
            row: true,
            size: size,
            items: const [
              SemiDescriptionsItemData(label: 'K1', value: 'V1'),
              SemiDescriptionsItemData(label: 'K2', value: 'V2'),
            ],
          ),
        ),
      );
      final value = tester.widget<Text>(find.text('V1'));
      expect(value.style!.fontSize, valueSizes[i]);
      expect(value.style!.fontWeight, FontWeight.w600);
      expect(tester.widget<Text>(find.text('K1')).style!.fontSize, keySizes[i]);
      final k1 = tester.getRect(find.text('K1'));
      final k2 = tester.getRect(find.text('K2'));
      final v1 = tester.getRect(find.text('V1'));
      // Item end padding between the two items of the run.
      final contentRight = k1.right > v1.right ? k1.right : v1.right;
      expect(k2.left - contentRight, endPaddings[i]);
      // Key bottom padding: small 0 (internal), medium/large 4 (themed).
      expect(v1.top - k1.bottom, keyBottoms[i]);
    }
    await tester.pumpWidget(host(const SizedBox()));
  });

  testWidgets('keyStyle colors the key and keyWidth fixes its slot', (
    tester,
  ) async {
    await tester.pumpWidget(
      host(
        width: hostWidth,
        const SemiDescriptions(
          items: [
            SemiDescriptionsItemData(
              label: 'K1',
              value: 'one',
              keyWidth: 100,
              keyStyle: TextStyle(color: Color(0xff00ff00)),
            ),
            SemiDescriptionsItemData(label: 'K2', value: 'two', keyWidth: 100),
          ],
        ),
      ),
    );
    expect(
      tester.widget<Text>(find.text('K1')).style!.color,
      const Color(0xff00ff00),
    );
    final root = tester.getRect(find.byType(SemiDescriptions));
    final v1 = tester.getRect(find.text('one'));
    final v2 = tester.getRect(find.text('two'));
    // Shared label column = keyWidth 100 (+ the 24 th gap after it).
    expect(v1.left, root.left + 124);
    expect(v1.left, v2.left);
    await tester.pumpWidget(host(const SizedBox()));
    // Longer keys ellipsize inside keyWidth (Flutter improvement).
    await tester.pumpWidget(
      host(
        width: hostWidth,
        const SemiDescriptions(
          items: [
            SemiDescriptionsItemData(
              label: 'AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA',
              value: 'v',
              keyWidth: 50,
            ),
          ],
        ),
      ),
    );
    final text = tester.widget<Text>(
      find.text('AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA'),
    );
    expect(text.maxLines, 1);
    expect(text.overflow, TextOverflow.ellipsis);
    expect(
      tester.getRect(find.text('AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA')).width,
      50,
    );
    await tester.pumpWidget(host(const SizedBox()));
  });

  testWidgets('valueBuilder runs only for rendered items', (tester) async {
    var built = 0;
    var hiddenBuilt = 0;
    final items = [
      SemiDescriptionsItemData(
        label: 'Lazy',
        valueBuilder: () {
          built += 1;
          return const Text('built');
        },
      ),
      SemiDescriptionsItemData(
        label: 'Hidden',
        hidden: true,
        valueBuilder: () {
          hiddenBuilt += 1;
          return const Text('hidden');
        },
      ),
    ];
    // Constructing the tree does not run builders.
    final widget = SemiDescriptions(items: items);
    expect(built, 0);
    expect(hiddenBuilt, 0);
    await tester.pumpWidget(host(width: hostWidth, widget));
    expect(built, 1);
    expect(hiddenBuilt, 0);
    expect(find.text('built'), findsOneWidget);
    expect(find.text('hidden'), findsNothing);
    await tester.pumpWidget(host(const SizedBox()));
  });

  testWidgets('rtl mirrors alignments and gaps', (tester) async {
    await tester.pumpWidget(
      host(
        width: hostWidth,
        direction: TextDirection.rtl,
        const SemiDescriptions(
          align: SemiDescriptionsAlign.center,
          items: [
            SemiDescriptionsItemData(label: 'A', value: 'one'),
            SemiDescriptionsItemData(label: 'Long label', value: 'two'),
          ],
        ),
      ),
    );
    final aKey = tester.getRect(find.text('A'));
    final longKey = tester.getRect(find.text('Long label'));
    final v1 = tester.getRect(find.text('one'));
    // Logical end (physical left) alignment and the mirrored 24px gap.
    expect(aKey.left, longKey.left);
    expect(longKey.left - v1.right, 24);
    await tester.pumpWidget(
      host(
        width: hostWidth,
        direction: TextDirection.rtl,
        const SemiDescriptions(
          align: SemiDescriptionsAlign.plain,
          items: [SemiDescriptionsItemData(label: 'Label', value: 'Value')],
        ),
      ),
    );
    final colon = tester.getRect(find.text('Label:'));
    final value = tester.getRect(find.text('Value'));
    // The 8px gap moves to the other side.
    expect(colon.left - value.right, 8);
    await tester.pumpWidget(
      host(
        width: hostWidth,
        direction: TextDirection.rtl,
        const SemiDescriptions(
          row: true,
          size: SemiDescriptionsSize.medium,
          items: [
            SemiDescriptionsItemData(label: 'K1', value: 'V1'),
            SemiDescriptionsItemData(label: 'K2', value: 'V2'),
          ],
        ),
      ),
    );
    final k1 = tester.getRect(find.text('K1'));
    final k2 = tester.getRect(find.text('K2'));
    final rv1 = tester.getRect(find.text('V1'));
    // Double-row end padding mirrors (60 on the physical left in RTL).
    final contentLeft = k1.left < rv1.left ? k1.left : rv1.left;
    expect(contentLeft - k2.right, 60);
    await tester.pumpWidget(host(const SizedBox()));
  });

  testWidgets('text scaling and narrow unbounded constraints stay sane', (
    tester,
  ) async {
    const long = SemiDescriptionsItemData(
      label: '很长很长很长的键名很长很长很长的键名',
      value: '很长很长很长的值很长很长很长的值很长很长很长的值',
    );
    await tester.pumpWidget(
      host(
        width: hostWidth,
        textScale: 3,
        SingleChildScrollView(
          child: const SemiDescriptions(items: [long, long]),
        ),
      ),
    );
    expect(tester.takeException(), isNull);
    expect(find.text('很长很长很长的键名很长很长很长的键名'), findsWidgets);
    await tester.pumpWidget(host(const SizedBox()));
    for (final layout in SemiDescriptionsLayout.values) {
      await tester.pumpWidget(
        host(
          width: 80,
          SingleChildScrollView(
            child: SemiDescriptions(layout: layout, items: const [long, long]),
          ),
        ),
      );
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(host(const SizedBox()));
      await tester.pumpWidget(
        host(
          width: 80,
          SingleChildScrollView(
            child: SemiDescriptions(
              row: true,
              size: SemiDescriptionsSize.large,
              items: const [long, long],
            ),
          ),
        ),
      );
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(host(const SizedBox()));
      // Unbounded width (horizontal scroller) and unbounded height (list).
      await tester.pumpWidget(
        host(
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: SemiDescriptions(layout: layout, items: const [long, long]),
          ),
        ),
      );
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(host(const SizedBox()));
      await tester.pumpWidget(
        host(
          ListView(
            children: [
              SemiDescriptions(layout: layout, items: const [long, long]),
            ],
          ),
        ),
      );
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(host(const SizedBox()));
    }
  });

  testWidgets('semantics merge each item and skip hidden and colon', (
    tester,
  ) async {
    final handle = tester.ensureSemantics();
    await tester.pumpWidget(
      host(
        width: hostWidth,
        const SemiDescriptions(
          align: SemiDescriptionsAlign.plain,
          semanticsLabel: '用户资料',
          items: [
            SemiDescriptionsItemData(label: '用户', value: '张三'),
            SemiDescriptionsItemData(label: '隐藏', value: '不可见', hidden: true),
          ],
        ),
      ),
    );
    expect(find.bySemanticsLabel('用户:'), findsNothing);
    expect(find.bySemanticsLabel('隐藏'), findsNothing);
    expect(find.bySemanticsLabel('不可见'), findsNothing);
    // Merged into one node per item (Flutter joins the merged labels with a
    // newline); the visual colon is not part of the label.
    expect(find.bySemanticsLabel('用户\n张三'), findsOneWidget);
    expect(find.bySemanticsLabel(RegExp('用户资料')), findsOneWidget);
    handle.dispose();
    await tester.pumpWidget(host(const SizedBox()));
  });

  testWidgets('hidden items do not render', (tester) async {
    await tester.pumpWidget(
      host(
        width: hostWidth,
        const SemiDescriptions(
          items: [
            SemiDescriptionsItemData(label: '可见', value: 'yes'),
            SemiDescriptionsItemData(label: '不可见', value: 'no', hidden: true),
          ],
        ),
      ),
    );
    expect(find.text('可见'), findsOneWidget);
    expect(find.text('不可见'), findsNothing);
    expect(find.text('no'), findsNothing);
    await tester.pumpWidget(host(const SizedBox()));
  });

  testWidgets('vertical ignores span and row mode wins over align and layout', (
    tester,
  ) async {
    await tester.pumpWidget(
      host(
        width: hostWidth,
        SemiDescriptions(
          items: [
            SemiDescriptionsItemData(label: 'A', value: slotProbe(6), span: 5),
            SemiDescriptionsItemData(label: 'B', value: slotProbe(7), span: 1),
          ],
        ),
      ),
    );
    final v1 = tester.getRect(find.byKey(const ValueKey('v6')));
    final v2 = tester.getRect(find.byKey(const ValueKey('v7')));
    // span is ignored: both values stretch the same column.
    expect(v1.left, v2.left);
    expect(v1.width, v2.width);
    await tester.pumpWidget(host(const SizedBox()));
    // row: true takes precedence over layout/align; size still applies.
    await tester.pumpWidget(
      host(
        width: hostWidth,
        const SemiDescriptions(
          row: true,
          layout: SemiDescriptionsLayout.horizontal,
          align: SemiDescriptionsAlign.plain,
          size: SemiDescriptionsSize.large,
          items: [SemiDescriptionsItemData(label: 'K', value: 'V')],
        ),
      ),
    );
    final value = tester.widget<Text>(find.text('V'));
    expect(value.style!.fontSize, 28);
    expect(value.style!.fontWeight, FontWeight.w600);
    await tester.pumpWidget(host(const SizedBox()));
  });

  testWidgets('no Material widgets anywhere', (tester) async {
    await tester.pumpWidget(
      host(
        width: hostWidth,
        const SemiDescriptions(
          row: true,
          layout: SemiDescriptionsLayout.horizontal,
          items: [SemiDescriptionsItemData(label: 'K', value: 'V')],
        ),
      ),
    );
    expect(find.byType(Material), findsNothing);
    await tester.pumpWidget(host(const SizedBox()));
  });
}
