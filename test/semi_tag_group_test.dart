import 'package:flutter/gestures.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:semi_design_flutter/semi_design_flutter.dart';

Widget host(Widget child, {TextDirection direction = TextDirection.ltr}) =>
    SemiTheme(
      data: const SemiThemeData.light(),
      child: Directionality(
        textDirection: direction,
        child: Center(child: child),
      ),
    );

List<SemiTagGroupItem> items(int count) => List.generate(
  count,
  (i) => SemiTagGroupItem('t$i', closable: true),
  growable: false,
);

void main() {
  testWidgets(
    'renders all items when maxTagCount is null; spacing from theme',
    (tester) async {
      await tester.pumpWidget(
        host(
          SemiTagGroup(
            tagList: [
              SemiTagGroupItem('a'),
              SemiTagGroupItem('b'),
              SemiTagGroupItem('c'),
            ],
          ),
        ),
      );
      expect(find.text('a'), findsOneWidget);
      expect(find.text('b'), findsOneWidget);
      expect(find.text('c'), findsOneWidget);
      final wrap = tester.widget<Wrap>(find.byType(Wrap));
      expect(wrap.spacing, 8);
      expect(wrap.runSpacing, 0);
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox());
    },
  );
  testWidgets('local SemiTagTheme spacing override reaches layout', (
    tester,
  ) async {
    await tester.pumpWidget(
      host(
        SemiTagTheme(
          data: const SemiTagThemeData(
            spacingTagGroupMarginRight: 20,
            spacingTagGroupMarginBottom: 12,
          ),
          child: SemiTagGroup(
            tagList: [SemiTagGroupItem('a'), SemiTagGroupItem('b')],
          ),
        ),
      ),
    );
    final wrap = tester.widget<Wrap>(find.byType(Wrap));
    expect(wrap.spacing, 20);
    expect(wrap.runSpacing, 12);
    final first = tester.getRect(find.byType(SemiTag).first);
    final second = tester.getRect(find.byType(SemiTag).at(1));
    expect(second.left - first.right, 20);
    await tester.pumpWidget(const SizedBox());
  });
  testWidgets('maxTagCount truncates in order and appends +N', (tester) async {
    await tester.pumpWidget(
      host(SemiTagGroup(maxTagCount: 2, tagList: items(5))),
    );
    expect(find.text('t0'), findsOneWidget);
    expect(find.text('t1'), findsOneWidget);
    expect(find.text('t2'), findsNothing);
    expect(find.text('+3'), findsOneWidget);
    final wrap = tester.widget<Wrap>(find.byType(Wrap));
    expect(wrap.children.length, 3);
    expect(wrap.children[0], isA<SemiTag>());
    expect(wrap.children[1], isA<SemiTag>());
    expect(wrap.children[2], isA<MouseRegion>());
    final zero = tester.getRect(find.byType(SemiTag).first);
    final one = tester.getRect(find.byType(SemiTag).at(1));
    final n = tester.getRect(find.text('+3'));
    expect(zero.left < one.left, isTrue);
    expect(one.left < n.left, isTrue);
    await tester.pumpWidget(const SizedBox());
  });
  testWidgets('restCount overrides the +N count', (tester) async {
    await tester.pumpWidget(
      host(SemiTagGroup(maxTagCount: 2, restCount: 7, tagList: items(5))),
    );
    expect(find.text('+7'), findsOneWidget);
    expect(find.text('t2'), findsNothing);
    await tester.pumpWidget(const SizedBox());
  });
  testWidgets('restCount=0 falls back to the computed count', (tester) async {
    await tester.pumpWidget(
      host(SemiTagGroup(maxTagCount: 2, restCount: 0, tagList: items(5))),
    );
    expect(find.text('+3'), findsOneWidget);
    await tester.pumpWidget(const SizedBox());
  });
  testWidgets('n <= 0 renders everything without folding', (tester) async {
    await tester.pumpWidget(
      host(SemiTagGroup(maxTagCount: 5, tagList: items(3))),
    );
    expect(find.text('t0'), findsOneWidget);
    expect(find.text('t1'), findsOneWidget);
    expect(find.text('t2'), findsOneWidget);
    expect(find.textContaining('+'), findsNothing);
    await tester.pumpWidget(const SizedBox());
  });
  testWidgets('maxTagCount=0 keeps only the +N tag', (tester) async {
    await tester.pumpWidget(
      host(SemiTagGroup(maxTagCount: 0, tagList: items(5))),
    );
    expect(find.text('t0'), findsNothing);
    expect(find.text('t4'), findsNothing);
    expect(find.text('+5'), findsOneWidget);
    expect(find.byType(SemiTag), findsOneWidget);
    await tester.pumpWidget(const SizedBox());
  });
  testWidgets('size and avatarShape inject item > group > default', (
    tester,
  ) async {
    await tester.pumpWidget(
      host(
        SemiTagGroup(
          size: SemiTagSize.large,
          avatarShape: SemiTagShape.circle,
          tagList: [
            SemiTagGroupItem(
              'a',
              size: SemiTagSize.small,
              avatarShape: SemiTagShape.square,
            ),
            SemiTagGroupItem('b'),
          ],
        ),
      ),
    );
    final explicit = tester.widget<SemiTag>(find.widgetWithText(SemiTag, 'a'));
    expect(explicit.size, SemiTagSize.small);
    expect(explicit.avatarShape, SemiTagShape.square);
    final inherited = tester.widget<SemiTag>(find.widgetWithText(SemiTag, 'b'));
    expect(inherited.size, SemiTagSize.large);
    expect(inherited.avatarShape, SemiTagShape.circle);
    await tester.pumpWidget(const SizedBox());
    await tester.pumpWidget(
      host(SemiTagGroup(tagList: [SemiTagGroupItem('c')])),
    );
    final plain = tester.widget<SemiTag>(find.widgetWithText(SemiTag, 'c'));
    expect(plain.size, SemiTagSize.normal);
    expect(plain.avatarShape, SemiTagShape.square);
    await tester.pumpWidget(const SizedBox());
  });
  testWidgets('close event tagKey defaults to text', (tester) async {
    SemiTagCloseEvent? event;
    await tester.pumpWidget(
      host(
        SemiTagGroup(
          onTagClose: (e) => event = e,
          tagList: [SemiTagGroupItem('a', closable: true)],
        ),
      ),
    );
    await tester.tap(
      find.descendant(
        of: find.widgetWithText(SemiTag, 'a'),
        matching: find.byType(SemiIcon),
      ),
    );
    await tester.pump();
    expect(event!.text, 'a');
    expect(event!.tagKey, 'a');
    await tester.pumpWidget(const SizedBox());
  });
  testWidgets('explicit tagKey reaches the event and the widget key', (
    tester,
  ) async {
    SemiTagCloseEvent? event;
    await tester.pumpWidget(
      host(
        SemiTagGroup(
          onTagClose: (e) => event = e,
          tagList: [SemiTagGroupItem('a', closable: true, tagKey: 7)],
        ),
      ),
    );
    final tag = tester.widget<SemiTag>(find.widgetWithText(SemiTag, 'a'));
    expect(tag.key, const ValueKey<Object>(7));
    await tester.tap(
      find.descendant(
        of: find.widgetWithText(SemiTag, 'a'),
        matching: find.byType(SemiIcon),
      ),
    );
    await tester.pump();
    expect(event!.tagKey, 7);
    await tester.pumpWidget(const SizedBox());
  });
  testWidgets('close forwards item then group with one shared event', (
    tester,
  ) async {
    final calls = <String>[];
    SemiTagCloseEvent? itemEvent, groupEvent;
    await tester.pumpWidget(
      host(
        SemiTagGroup(
          onTagClose: (e) {
            calls.add('group');
            groupEvent = e;
          },
          tagList: [
            SemiTagGroupItem(
              'a',
              closable: true,
              onClose: (e) {
                calls.add('item');
                itemEvent = e;
              },
            ),
          ],
        ),
      ),
    );
    await tester.tap(
      find.descendant(
        of: find.widgetWithText(SemiTag, 'a'),
        matching: find.byType(SemiIcon),
      ),
    );
    await tester.pump();
    expect(calls, ['item', 'group']);
    expect(identical(itemEvent, groupEvent), isTrue);
    expect(find.text('a'), findsNothing);
    await tester.pumpWidget(const SizedBox());
  });
  testWidgets('preventDefault in the item callback cancels the hide', (
    tester,
  ) async {
    await tester.pumpWidget(
      host(
        SemiTagGroup(
          onTagClose: (_) {},
          tagList: [
            SemiTagGroupItem(
              'a',
              closable: true,
              onClose: (e) {
                e.preventDefault();
              },
            ),
          ],
        ),
      ),
    );
    await tester.tap(
      find.descendant(
        of: find.widgetWithText(SemiTag, 'a'),
        matching: find.byType(SemiIcon),
      ),
    );
    await tester.pump();
    expect(find.text('a'), findsOneWidget);
    await tester.pumpWidget(const SizedBox());
  });
  testWidgets('preventDefault in onTagClose cancels the hide', (tester) async {
    await tester.pumpWidget(
      host(
        SemiTagGroup(
          onTagClose: (e) => e.preventDefault(),
          tagList: [SemiTagGroupItem('a', closable: true)],
        ),
      ),
    );
    await tester.tap(
      find.descendant(
        of: find.widgetWithText(SemiTag, 'a'),
        matching: find.byType(SemiIcon),
      ),
    );
    await tester.pump();
    expect(find.text('a'), findsOneWidget);
    await tester.pumpWidget(const SizedBox());
  });
  testWidgets('controlled items never auto-hide and still notify', (
    tester,
  ) async {
    var closes = 0;
    await tester.pumpWidget(
      host(
        SemiTagGroup(
          onTagClose: (_) => closes++,
          tagList: [SemiTagGroupItem('a', closable: true, visible: true)],
        ),
      ),
    );
    await tester.tap(
      find.descendant(
        of: find.widgetWithText(SemiTag, 'a'),
        matching: find.byType(SemiIcon),
      ),
    );
    await tester.pump();
    expect(closes, 1);
    expect(find.text('a'), findsOneWidget);
    await tester.pumpWidget(const SizedBox());
  });
  testWidgets('custom items render verbatim without injection', (tester) async {
    await tester.pumpWidget(
      host(
        SemiTagGroup(
          size: SemiTagSize.large,
          avatarShape: SemiTagShape.circle,
          tagList: [SemiTagGroupItem.custom(const Text('raw'))],
        ),
      ),
    );
    expect(find.text('raw'), findsOneWidget);
    expect(find.byType(SemiTag), findsNothing);
    final wrap = tester.widget<Wrap>(find.byType(Wrap));
    expect(wrap.children.single, isA<Text>());
    await tester.pumpWidget(const SizedBox());
  });
  testWidgets('+N tag properties and onPlusNMouseEnter hover', (tester) async {
    var hovers = 0;
    await tester.pumpWidget(
      host(
        SemiTagGroup(
          maxTagCount: 1,
          onPlusNMouseEnter: () => hovers++,
          tagList: items(5),
        ),
      ),
    );
    final nTag = tester.widget<SemiTag>(find.widgetWithText(SemiTag, '+4'));
    expect(nTag.closable, isFalse);
    expect(nTag.color, SemiTagColor.grey);
    expect(nTag.backgroundColor, const Color(0x00000000));
    expect(nTag.key, const ValueKey('_+n'));
    expect(nTag.size, SemiTagSize.normal);
    expect(nTag.onTap, isNull);
    final mouse = await tester.createGesture(kind: PointerDeviceKind.mouse);
    await mouse.addPointer(location: Offset.zero);
    await mouse.moveTo(tester.getCenter(find.text('+4')));
    await tester.pump();
    expect(hovers, 1);
    await mouse.removePointer();
    await tester.pump();
    await tester.pumpWidget(const SizedBox());
  });
  testWidgets('narrow width wraps without overflow', (tester) async {
    await tester.pumpWidget(
      host(
        SizedBox(
          width: 60,
          child: SemiTagGroup(
            tagList: [
              SemiTagGroupItem('aaaaaa'),
              SemiTagGroupItem('bbbbbb'),
              SemiTagGroupItem('cccccc'),
            ],
          ),
        ),
      ),
    );
    expect(find.text('aaaaaa'), findsOneWidget);
    expect(find.text('bbbbbb'), findsOneWidget);
    expect(find.text('cccccc'), findsOneWidget);
    expect(tester.takeException(), isNull);
    final tops = tester
        .widgetList<SemiTag>(find.byType(SemiTag))
        .map((t) => tester.getRect(find.byWidget(t)).top)
        .toSet();
    expect(tops.length > 1, isTrue);
    await tester.pumpWidget(const SizedBox());
  });
  testWidgets('RTL reverses the run order', (tester) async {
    await tester.pumpWidget(
      host(
        SemiTagGroup(tagList: [SemiTagGroupItem('a'), SemiTagGroupItem('b')]),
        direction: TextDirection.rtl,
      ),
    );
    expect(tester.takeException(), isNull);
    final a = tester.getRect(find.byType(SemiTag).first);
    final b = tester.getRect(find.byType(SemiTag).at(1));
    expect(a.left > b.left, isTrue);
    await tester.pumpWidget(const SizedBox());
  });
  testWidgets('negative maxTagCount throws ArgumentError', (tester) async {
    await tester.pumpWidget(host(SemiTagGroup(maxTagCount: -1)));
    expect(tester.takeException(), isA<ArgumentError>());
    await tester.pumpWidget(const SizedBox());
  });
}
