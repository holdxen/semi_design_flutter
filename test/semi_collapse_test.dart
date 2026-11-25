import 'dart:io';
import 'dart:ui' show PointerDeviceKind;

import 'package:flutter/material.dart' show Material;
import 'package:flutter/services.dart';
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

/// One-panel tree; [content] null builds a panel without children.
Widget one({
  String itemKey = '1',
  Object? header = 'Header 1',
  Widget? extra,
  Widget? content = const Text('Content 1'),
  bool showArrow = true,
  bool disabled = false,
  bool keepDOM = false,
  bool lazyRender = false,
  bool motion = true,
  Set<String>? activeKeys,
  Set<String> defaultActiveKeys = const <String>{},
  bool accordion = false,
  bool clickHeaderToExpand = true,
  Widget? expandIcon,
  Widget? collapseIcon,
  SemiCollapseIconPosition expandIconPosition = SemiCollapseIconPosition.right,
  Object? reCalcKey,
  VoidCallback? onMotionEnd,
  ValueChanged<List<String>>? onActiveKeysChanged,
}) => SemiCollapse(
  activeKeys: activeKeys,
  defaultActiveKeys: defaultActiveKeys,
  accordion: accordion,
  clickHeaderToExpand: clickHeaderToExpand,
  keepDOM: keepDOM,
  lazyRender: lazyRender,
  motion: motion,
  expandIcon: expandIcon,
  collapseIcon: collapseIcon,
  expandIconPosition: expandIconPosition,
  onActiveKeysChanged: onActiveKeysChanged,
  children: [
    SemiCollapsePanel(
      itemKey: itemKey,
      header: header,
      extra: extra,
      showArrow: showArrow,
      disabled: disabled,
      reCalcKey: reCalcKey,
      onMotionEnd: onMotionEnd,
      child: content,
    ),
  ],
);

/// Three-panel tree matching upstream collapse.test.js fixtures.
Widget three({
  Set<String>? activeKeys,
  Set<String> defaultActiveKeys = const <String>{},
  bool accordion = false,
  bool clickHeaderToExpand = true,
  bool keepDOM = false,
  bool lazyRender = false,
  bool motion = false,
  ValueChanged<List<String>>? onActiveKeysChanged,
}) => SemiCollapse(
  activeKeys: activeKeys,
  defaultActiveKeys: defaultActiveKeys,
  accordion: accordion,
  clickHeaderToExpand: clickHeaderToExpand,
  keepDOM: keepDOM,
  lazyRender: lazyRender,
  motion: motion,
  onActiveKeysChanged: onActiveKeysChanged,
  children: const [
    SemiCollapsePanel(
      itemKey: '1',
      header: 'Header 1',
      child: Text('Content 1'),
    ),
    SemiCollapsePanel(
      itemKey: '2',
      header: 'Header 2',
      child: Text('Content 2'),
    ),
    SemiCollapsePanel(
      itemKey: '3',
      header: 'Header 3',
      child: Text('Content 3'),
    ),
  ],
);

/// Records mount/unmount to observe content State lifetime.
class _Probe extends StatefulWidget {
  const _Probe({required this.log, required this.tag});
  final List<String> log;
  final String tag;
  @override
  State<_Probe> createState() => _ProbeState();
}

class _ProbeState extends State<_Probe> {
  @override
  void initState() {
    super.initState();
    widget.log.add('${widget.tag}:init');
  }

  @override
  void dispose() {
    widget.log.add('${widget.tag}:dispose');
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Text(widget.tag);
}

Finder panelScope(String key) => find.byKey(ValueKey<String>(key));

Finder arrowOf(String key) =>
    find.descendant(of: panelScope(key), matching: find.byType(SemiIcon));

Semantics headerSemantics(WidgetTester t, String key) => t.widget<Semantics>(
  find.ancestor(
    of: find.text('Header $key'),
    matching: find.byWidgetPredicate(
      (w) => w is Semantics && w.properties.button == true,
    ),
  ),
);

bool isExpanded(WidgetTester t, String key) =>
    headerSemantics(t, key).properties.expanded ?? false;

Color? headerBg(WidgetTester t, String key) =>
    headerBoxDecoration(t, key)?.color;

BoxDecoration? headerBoxDecoration(WidgetTester t, String key) {
  for (final w in t.widgetList<DecoratedBox>(
    find.descendant(of: panelScope(key), matching: find.byType(DecoratedBox)),
  )) {
    final d = w.decoration;
    if (d is BoxDecoration && d.borderRadius != null) return d;
  }
  return null;
}

Rect headerBoxRect(WidgetTester t, String key) => t.getRect(
  find.descendant(
    of: panelScope(key),
    matching: find.byWidgetPredicate(
      (w) =>
          w is DecoratedBox &&
          w.decoration is BoxDecoration &&
          (w.decoration as BoxDecoration).borderRadius != null,
    ),
  ),
);

/// The header's Row rect. The Row can be taller than the text glyph because
/// the 16px arrow exceeds the ~14px text; subtracting the Row (not the text)
/// isolates the vertical padding.
Rect headerRowRect(WidgetTester t, String key) => t.getRect(
      find.descendant(
        of: panelScope(key),
        matching: find.byType(Row),
      ).first,
    );

TextStyle? renderedStyle(WidgetTester t, Finder textFinder) => t
    .widget<RichText>(
      find.descendant(of: textFinder, matching: find.byType(RichText)).first,
    )
    .text
    .style;

double clipHeight(WidgetTester t, String key) => t
    .getRect(
      find
          .descendant(of: panelScope(key), matching: find.byType(ClipRect))
          .first,
    )
    .height;

const contentInsets = 12.0; // contentPaddingTop 4 + contentPaddingBottom 8

/// Natural content height: the text box plus the themed content padding.
double contentNaturalHeight(WidgetTester t, Finder contentText) =>
    t.getRect(contentText).height + contentInsets;

void main() {
  group('activation semantics', () {
    testWidgets('uncontrolled toggling keeps ordered keys and reports them', (
      tester,
    ) async {
      final log = <List<String>>[];
      await tester.pumpWidget(
        host(
          three(defaultActiveKeys: const {'1'}, onActiveKeysChanged: log.add),
        ),
      );
      expect(isExpanded(tester, '1'), isTrue);
      expect(isExpanded(tester, '2'), isFalse);
      expect(isExpanded(tester, '3'), isFalse);
      await tester.tap(find.text('Header 2'));
      await tester.pump();
      expect(log, [
        ['1', '2'],
      ]);
      await tester.tap(find.text('Header 3'));
      await tester.pump();
      expect(log.last, ['1', '2', '3']);
      await tester.tap(find.text('Header 1'));
      await tester.pump();
      expect(log.last, ['2', '3']);
      expect(isExpanded(tester, '1'), isFalse);
      expect(isExpanded(tester, '2'), isTrue);
      expect(isExpanded(tester, '3'), isTrue);
      // Re-adding appends at the end (LinkedHashSet semantics).
      await tester.tap(find.text('Header 1'));
      await tester.pump();
      expect(log.last, ['2', '3', '1']);
      await tester.pumpWidget(const SizedBox());
    });

    testWidgets('controlled mode only reports and follows activeKeys', (
      tester,
    ) async {
      final log = <List<String>>[];
      Widget build(Set<String> keys) =>
          host(three(activeKeys: keys, onActiveKeysChanged: log.add));
      await tester.pumpWidget(build(const {'2'}));
      expect(isExpanded(tester, '2'), isTrue);
      await tester.tap(find.text('Header 1'));
      await tester.pump();
      expect(log, [
        ['2', '1'],
      ]);
      expect(isExpanded(tester, '1'), isFalse);
      await tester.pumpWidget(build(const {'2', '1'}));
      expect(isExpanded(tester, '1'), isTrue);
      await tester.pumpWidget(const SizedBox());
    });

    testWidgets('an empty controlled set is still controlled', (tester) async {
      final log = <List<String>>[];
      await tester.pumpWidget(
        host(three(activeKeys: const <String>{}, onActiveKeysChanged: log.add)),
      );
      await tester.tap(find.text('Header 1'));
      await tester.pump();
      expect(log, [
        ['1'],
      ]);
      expect(isExpanded(tester, '1'), isFalse);
      await tester.pumpWidget(const SizedBox());
    });

    testWidgets(
      'accordion init keeps only the first key and toggles to empty',
      (tester) async {
        final log = <List<String>>[];
        await tester.pumpWidget(
          host(
            three(
              accordion: true,
              defaultActiveKeys: const {'1', '2'},
              onActiveKeysChanged: log.add,
            ),
          ),
        );
        expect(isExpanded(tester, '1'), isTrue);
        expect(isExpanded(tester, '2'), isFalse);
        await tester.tap(find.text('Header 3'));
        await tester.pump();
        expect(log, [
          ['3'],
        ]);
        expect(isExpanded(tester, '1'), isFalse);
        expect(isExpanded(tester, '3'), isTrue);
        // Clicking the active panel closes everything (upstream keyboard test).
        await tester.tap(find.text('Header 3'));
        await tester.pump();
        expect(log.last, isEmpty);
        expect(isExpanded(tester, '3'), isFalse);
        await tester.pumpWidget(const SizedBox());
      },
    );

    testWidgets('nested collapses are isolated by scope', (tester) async {
      final outerLog = <List<String>>[];
      final innerLog = <List<String>>[];
      await tester.pumpWidget(
        host(
          SemiCollapse(
            defaultActiveKeys: const {'outer'},
            onActiveKeysChanged: outerLog.add,
            children: [
              SemiCollapsePanel(
                itemKey: 'outer',
                header: 'Outer header',
                child: SemiCollapse(
                  onActiveKeysChanged: innerLog.add,
                  children: const [
                    SemiCollapsePanel(
                      itemKey: 'inner',
                      header: 'Inner header',
                      child: Text('Inner body'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 300));
      await tester.tap(find.text('Inner header'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      expect(innerLog, [
        ['inner'],
      ]);
      expect(outerLog, isEmpty);
      expect(find.text('Inner body'), findsOneWidget);
      // Toggling the outer panel only hits the outer scope.
      await tester.tap(find.text('Outer header'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      expect(outerLog, [<String>[]]);
      expect(find.text('Inner body'), findsNothing);
      await tester.pumpWidget(const SizedBox());
    });
  });

  group('content lifecycle', () {
    testWidgets('keepDOM false destroys collapsed content state', (
      tester,
    ) async {
      final log = <String>[];
      await tester.pumpWidget(
        host(
          one(
            defaultActiveKeys: const {'1'},
            motion: false,
            content: _Probe(log: log, tag: 'c'),
          ),
        ),
      );
      expect(log, ['c:init']);
      await tester.tap(find.text('Header 1'));
      await tester.pump();
      expect(log, ['c:init', 'c:dispose']);
      expect(find.text('c'), findsNothing);
      await tester.pumpWidget(const SizedBox());
    });

    testWidgets('keepDOM true keeps content state and clips to zero', (
      tester,
    ) async {
      final log = <String>[];
      await tester.pumpWidget(
        host(
          one(
            defaultActiveKeys: const {'1'},
            keepDOM: true,
            motion: false,
            content: _Probe(log: log, tag: 'c'),
          ),
        ),
      );
      await tester.tap(find.text('Header 1'));
      await tester.pump();
      expect(log, ['c:init']);
      expect(find.text('c'), findsOneWidget);
      expect(clipHeight(tester, '1'), closeTo(0, 0.01));
      await tester.pumpWidget(const SizedBox());
    });

    testWidgets('lazyRender builds content on first open only', (tester) async {
      final log = <String>[];
      await tester.pumpWidget(
        host(
          one(
            keepDOM: true,
            lazyRender: true,
            motion: false,
            content: _Probe(log: log, tag: 'c'),
          ),
        ),
      );
      expect(log, isEmpty);
      expect(find.text('c'), findsNothing);
      await tester.tap(find.text('Header 1'));
      await tester.pump();
      expect(log, ['c:init']);
      await tester.tap(find.text('Header 1'));
      await tester.pump();
      expect(log, ['c:init']);
      expect(find.text('c'), findsOneWidget);
      await tester.pumpWidget(const SizedBox());
    });

    testWidgets('reCalcKey change re-lays out and follows content height', (
      tester,
    ) async {
      await tester.pumpWidget(
        host(
          one(
            defaultActiveKeys: const {'1'},
            content: const Text('One line'),
            reCalcKey: 1,
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 300));
      final before = tester.getRect(panelScope('1')).height;
      await tester.pumpWidget(
        host(
          one(
            defaultActiveKeys: const {'1'},
            content: const Text('A\nB\nC\nD'),
            reCalcKey: 2,
          ),
        ),
      );
      await tester.pump();
      final after = tester.getRect(panelScope('1')).height;
      expect(after, greaterThan(before + 30));
      // Expanded height follows the taller content with no stale clipping.
      expect(
        clipHeight(tester, '1'),
        closeTo(contentNaturalHeight(tester, find.text('A\nB\nC\nD')), 0.5),
      );
      await tester.pumpWidget(const SizedBox());
    });

    testWidgets('onMotionEnd reports the collapse animation only', (
      tester,
    ) async {
      var ends = 0;
      await tester.pumpWidget(
        host(
          one(
            defaultActiveKeys: const {'1'},
            onMotionEnd: () => ends++,
            content: const Text('Content 1'),
          ),
        ),
      );
      // Collapse: reports once the reverse animation settles.
      await tester.tap(find.text('Header 1'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 125));
      expect(ends, 0);
      await tester.pump(const Duration(milliseconds: 200));
      expect(ends, 1);
      expect(find.text('Content 1'), findsNothing);
      // Expand: no report (plan: collapse-end callback).
      await tester.tap(find.text('Header 1'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      expect(ends, 1);
      await tester.pumpWidget(const SizedBox());
    });

    testWidgets('motion false never reports onMotionEnd', (tester) async {
      var ends = 0;
      await tester.pumpWidget(
        host(
          one(
            defaultActiveKeys: const {'1'},
            motion: false,
            onMotionEnd: () => ends++,
          ),
        ),
      );
      await tester.tap(find.text('Header 1'));
      await tester.pump();
      expect(ends, 0);
      await tester.pumpWidget(const SizedBox());
    });
  });

  group('theme', () {
    test('defaults merge equality and live resolve', () {
      const base = SemiCollapseThemeData();
      const lightTheme = SemiThemeData.light();
      final light = base.resolve(lightTheme);
      expect(
        light.colorCollapseItemBorderDefault,
        lightTheme.colors.colorBorder,
      );
      expect(
        light.colorCollapseHeaderTextDefault,
        lightTheme.colors.colorText0,
      );
      expect(
        light.colorCollapseHeaderTextDisabled,
        lightTheme.colors.colorDisabledText,
      );
      expect(
        light.colorCollapseHeaderIconDefault,
        lightTheme.colors.colorText2,
      );
      expect(light.colorCollapseHeaderBgHover, lightTheme.colors.colorFill0);
      expect(light.colorCollapseHeaderBgActive, lightTheme.colors.colorFill1);
      expect(
        light.colorCollapseContentTextDefault,
        lightTheme.colors.colorText1,
      );
      expect(
        light.fontCollapseHeaderFontWeight,
        lightTheme.typography.fontWeightBold,
      );
      expect(light.spacingCollapseHeaderMarginX, 8);
      expect(light.spacingCollapseHeaderMarginY, 4);
      expect(light.spacingCollapseHeaderPadding, 8);
      expect(light.spacingCollapseRightPaddingRight, 8);
      expect(light.spacingCollapseHeaderIconLeftMarginRight, 8);
      expect(light.spacingCollapseContentPaddingTop, 4);
      expect(light.spacingCollapseContentPaddingRight, 16);
      expect(light.spacingCollapseContentPaddingBottom, 8);
      expect(light.spacingCollapseContentPaddingLeft, 16);
      expect(
        light.radiusCollapseHeader,
        lightTheme.radius.borderRadiusSmall.value,
      );
      expect(light.radiusCollapseHeader, 3);
      expect(light.widthCollapseItemBorder, 1);
      expect(light.sizeCollapseIconDefault, 16);
      expect(light.animationDuration, const Duration(milliseconds: 250));
      expect(light.animationCurve, const Cubic(0.25, 0.1, 0.25, 1));
      const darkTheme = SemiThemeData.dark();
      final dark = base.resolve(darkTheme);
      expect(dark.colorCollapseHeaderTextDefault, darkTheme.colors.colorText0);
      expect(
        dark.colorCollapseHeaderTextDefault,
        isNot(light.colorCollapseHeaderTextDefault),
      );
      expect(dark.spacingCollapseHeaderMarginX, 8);
      const patch = SemiCollapseThemeData(
        colorCollapseHeaderTextDefault: Color(0xff010203),
        spacingCollapseHeaderPadding: 40,
        animationDuration: Duration(milliseconds: 100),
        animationCurve: Curves.easeInOut,
      );
      expect(base.merge(null), base);
      expect(base.merge(patch), patch);
      expect(patch.merge(base), patch);
      expect(patch.copyWith(), patch);
      expect(
        patch.merge(
          const SemiCollapseThemeData(spacingCollapseHeaderMarginX: 2),
        ),
        const SemiCollapseThemeData(
          colorCollapseHeaderTextDefault: Color(0xff010203),
          spacingCollapseHeaderPadding: 40,
          spacingCollapseHeaderMarginX: 2,
          animationDuration: Duration(milliseconds: 100),
          animationCurve: Curves.easeInOut,
        ),
      );
      expect(
        patch.hashCode,
        const SemiCollapseThemeData(
          colorCollapseHeaderTextDefault: Color(0xff010203),
          spacingCollapseHeaderPadding: 40,
          animationDuration: Duration(milliseconds: 100),
          animationCurve: Curves.easeInOut,
        ).hashCode,
      );
      expect(patch == base, isFalse);
      final resolved = patch.resolve(darkTheme);
      expect(resolved.colorCollapseHeaderTextDefault, const Color(0xff010203));
      expect(resolved.spacingCollapseHeaderPadding, 40);
      expect(resolved.spacingCollapseHeaderMarginX, 8);
      expect(resolved.animationDuration, const Duration(milliseconds: 100));
      expect(resolved.animationCurve, Curves.easeInOut);
      expect(resolved.radiusCollapseHeader, 3);
      const themes = SemiComponentThemes(
        collapse: SemiCollapseThemeData(spacingCollapseHeaderPadding: 3),
      );
      expect(
        const SemiComponentThemes().collapse,
        const SemiCollapseThemeData(),
      );
      expect(themes.copyWith().collapse, themes.collapse);
      expect(
        themes.copyWith(collapse: const SemiCollapseThemeData()).collapse,
        const SemiCollapseThemeData(),
      );
      expect(themes == const SemiComponentThemes(), isFalse);
      expect(
        themes.hashCode,
        const SemiComponentThemes(
          collapse: SemiCollapseThemeData(spacingCollapseHeaderPadding: 3),
        ).hashCode,
      );
    });

    test('theme field provenance comments', () {
      final theme = File('lib/src/theme/semi_collapse_theme_data.dart')
          .readAsStringSync();
      final widget = File('lib/src/components/semi_collapse.dart')
          .readAsStringSync();
      const declarations = [
        r'$color-collapse_item-border-default: var(--semi-color-border)',
        r'$color-collapse_header-text-default: var(--semi-color-text-0)',
        r'$color-collapse_header-text-disabled: var( --semi-color-disabled-text)',
        r'$color-collapse_header-icon-default: var(--semi-color-text-2)',
        r'$color-collapse_header-bg-hover: var(--semi-color-fill-0)',
        r'$color-collapse_header-bg-active: var(--semi-color-fill-1)',
        r'$color-collapse_content-text-default: var(--semi-color-text-1)',
        r'$font-collapse_header-fontWeight: $font-weight-bold',
        r'$spacing-collapse_header-marginX: $spacing-tight',
        r'$spacing-collapse_header-marginY: $spacing-extra-tight',
        r'$spacing-collapse_header-padding: $spacing-tight',
        r'$spacing-collapse_right-paddingRight: $spacing-tight',
        r'$spacing-collapse_header_iconLeft-marginRight: 8px',
        r'$spacing-collapse_content-paddingTop: $spacing-extra-tight',
        r'$spacing-collapse_content-paddingRight: $spacing-base',
        r'$spacing-collapse_content-paddingBottom: $spacing-tight',
        r'$spacing-collapse_content-paddingLeft: $spacing-base',
        r'$radius-collapse_header: var(--semi-border-radius-small)',
        r'$width-collapse_item-border: 1px',
        r'$size-collapse_icon-default: $width-icon-medium',
        r'$transition_duration-collapsible-height: 250ms',
        r'$transition_function-collapsible-height: cubic-bezier(0.25,0.1,0.25,1)',
      ];
      const internals = [
        r'$transition_delay-collapsible-height: var(--semi-transition_delay-none)',
        r'$transition_duration-collapsible-opacity: 250ms',
        r'$transition_function-collapsible-opacity: var(--semi-transition_function-easeIn)',
        r'$transition_delay-collapsible-opacity: var(--semi-transition_delay-none)',
        r'@include font-size-regular', // headerBaseFontSize
        r'@include font-size-regular', // contentBaseFontSize
        r'color: var(--semi-color-disabled-text)', // iconDisabledColor
      ];
      expect(declarations.length, 22);
      expect(internals.length, 7);
      for (final declaration in declarations) {
        expect(theme, contains(declaration));
      }
      for (final internal in internals) {
        expect(widget, contains(internal));
      }
      // 29 = 22 themed fields + 7 widget-internal constants.
      expect(declarations.length + internals.length, 29);
      expect(
        theme,
        contains('packages/semi-foundation/collapse/variables.scss'),
      );
      expect(
        theme,
        contains('packages/semi-foundation/collapsible/animation.scss'),
      );
      expect(
        widget,
        contains('packages/semi-foundation/collapse/collapse.scss'),
      );
      expect(
        widget,
        contains('packages/semi-foundation/collapsible/animation.scss'),
      );
      expect(theme, contains('Generated by tool/generate_collapse.py'));
    });

    testWidgets('application level and nested local patches merge', (
      tester,
    ) async {
      Widget build() => host(
        width: 300,
        SemiTheme(
          data: const SemiThemeData.light(
            components: SemiComponentThemes(
              collapse: SemiCollapseThemeData(
                spacingCollapseHeaderPadding: 20,
                spacingCollapseContentPaddingTop: 30,
              ),
            ),
          ),
          child: SemiCollapseTheme(
            data: const SemiCollapseThemeData(spacingCollapseHeaderPadding: 50),
            child: SemiCollapseTheme(
              data: const SemiCollapseThemeData(
                spacingCollapseContentPaddingBottom: 40,
              ),
              child: one(defaultActiveKeys: const {'1'}),
            ),
          ),
        ),
      );
      await tester.pumpWidget(build());
      final context = tester.element(find.byType(SemiCollapse));
      final resolved = SemiCollapseTheme.resolve(context);
      expect(resolved.spacingCollapseHeaderPadding, 50);
      expect(resolved.spacingCollapseContentPaddingTop, 30);
      expect(resolved.spacingCollapseContentPaddingBottom, 40);
      final headerBox = headerBoxRect(tester, '1');
      expect(
        headerBox.height - headerRowRect(tester, '1').height,
        100,
      );
      // 4 margin bottom + 30 content padding top.
      final contentRect = tester.getRect(find.text('Content 1'));
      expect(contentRect.top - headerBox.bottom, closeTo(34, 0.5));
      await tester.pumpWidget(const SizedBox());
    });

    testWidgets('local patches survive capture and globals re-resolve', (
      tester,
    ) async {
      await tester.pumpWidget(
        host(
          width: 300,
          SemiCollapseTheme(
            data: const SemiCollapseThemeData(
              spacingCollapseHeaderPadding: 33,
              spacingCollapseContentPaddingTop: 15,
            ),
            child: one(defaultActiveKeys: const {'1'}),
          ),
        ),
      );
      final context = tester.element(find.byType(SemiCollapse));
      expect(SemiCollapseTheme.maybeOf(context), isNotNull);
      final captured = InheritedTheme.captureAll(
        context,
        one(defaultActiveKeys: const {'1'}),
      );
      await tester.pumpWidget(
        host(
          width: 300,
          SemiTheme(
            data: const SemiThemeData.light(
              components: SemiComponentThemes(
                collapse: SemiCollapseThemeData(
                  spacingCollapseHeaderPadding: 44,
                  spacingCollapseContentPaddingBottom: 30,
                ),
              ),
            ),
            child: captured,
          ),
        ),
      );
      final context2 = tester.element(find.byType(SemiCollapse));
      final resolved = SemiCollapseTheme.resolve(context2);
      expect(resolved.spacingCollapseHeaderPadding, 33);
      expect(resolved.spacingCollapseContentPaddingTop, 15);
      expect(resolved.spacingCollapseContentPaddingBottom, 30);
      await tester.pumpWidget(const SizedBox());
    });

    testWidgets('patches cross SemiTheme boundary and update in same mode', (
      tester,
    ) async {
      Widget wrap(double padding) => host(
        width: 300,
        SemiCollapseTheme(
          data: SemiCollapseThemeData(spacingCollapseHeaderPadding: padding),
          child: SemiTheme(
            data: const SemiThemeData.light(),
            child: SemiCollapseTheme(
              data: const SemiCollapseThemeData(
                spacingCollapseContentPaddingTop: 15,
              ),
              child: one(defaultActiveKeys: const {'1'}),
            ),
          ),
        ),
      );
      await tester.pumpWidget(wrap(30));
      var headerBox = headerBoxRect(tester, '1');
      expect(headerBox.height - headerRowRect(tester, '1').height, 60);
      await tester.pumpWidget(wrap(30));
      await tester.pumpWidget(wrap(36));
      headerBox = headerBoxRect(tester, '1');
      expect(headerBox.height - headerRowRect(tester, '1').height, 72);
      final context = tester.element(find.byType(SemiCollapse));
      final captured = InheritedTheme.captureAll(
        context,
        one(defaultActiveKeys: const {'1'}),
      );
      await tester.pumpWidget(host(width: 300, captured));
      expect(
        SemiCollapseTheme.resolve(tester.element(find.byType(SemiCollapse)))
            .spacingCollapseHeaderPadding,
        36,
      );
      expect(
        SemiCollapseTheme.resolve(tester.element(find.byType(SemiCollapse)))
            .spacingCollapseContentPaddingTop,
        15,
      );
      await tester.pumpWidget(const SizedBox());
    });

    testWidgets('theme metrics drive the rendered geometry', (tester) async {
      await tester.pumpWidget(
        host(
          width: 300,
          SemiTheme(
            data: const SemiThemeData.light(
              components: SemiComponentThemes(
                collapse: SemiCollapseThemeData(
                  spacingCollapseHeaderPadding: 20,
                  spacingCollapseContentPaddingTop: 30,
                  colorCollapseHeaderBgHover: Color(0xff00ff00),
                ),
              ),
            ),
            child: one(defaultActiveKeys: const {'1'}),
          ),
        ),
      );
      final headerBox = headerBoxRect(tester, '1');
      expect(headerBox.height - headerRowRect(tester, '1').height, 40);
      final contentRect = tester.getRect(find.text('Content 1'));
      expect(contentRect.top - headerBox.bottom, closeTo(34, 0.5));
      final mouse = await tester.createGesture(kind: PointerDeviceKind.mouse);
      await mouse.addPointer(location: Offset.zero);
      addTearDown(mouse.removePointer);
      await tester.pump();
      await mouse.moveTo(tester.getCenter(find.text('Header 1')));
      await tester.pump();
      expect(headerBg(tester, '1'), const Color(0xff00ff00));
      await tester.pumpWidget(const SizedBox());
    });
  });

  group('animation', () {
    testWidgets('expands over 250ms with the themed curve', (tester) async {
      await tester.pumpWidget(host(one()));
      expect(find.text('Content 1'), findsNothing);
      await tester.tap(find.text('Header 1'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 125));
      final full =
          tester.getRect(find.text('Content 1')).height + contentInsets;
      const curve = Cubic(0.25, 0.1, 0.25, 1);
      expect(
        clipHeight(tester, '1'),
        closeTo(curve.transform(0.5) * full, 1.5),
      );
      await tester.pump(const Duration(milliseconds: 125));
      expect(clipHeight(tester, '1'), closeTo(full, 0.5));
      // Collapse hides the content once the reverse animation settles.
      await tester.tap(find.text('Header 1'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      expect(find.text('Content 1'), findsNothing);
      await tester.pumpWidget(const SizedBox());
    });

    testWidgets('no entrance animation for initially active panels', (
      tester,
    ) async {
      await tester.pumpWidget(host(one(defaultActiveKeys: const {'1'})));
      await tester.pump();
      expect(find.text('Content 1'), findsOneWidget);
      expect(
        clipHeight(tester, '1'),
        closeTo(contentNaturalHeight(tester, find.text('Content 1')), 0.5),
      );
      await tester.pumpWidget(const SizedBox());
    });

    testWidgets('motion false toggles instantly', (tester) async {
      await tester.pumpWidget(host(one(motion: false)));
      await tester.tap(find.text('Header 1'));
      await tester.pump();
      expect(find.text('Content 1'), findsOneWidget);
      expect(
        clipHeight(tester, '1'),
        closeTo(contentNaturalHeight(tester, find.text('Content 1')), 0.5),
      );
      await tester.tap(find.text('Header 1'));
      await tester.pump();
      expect(find.text('Content 1'), findsNothing);
      await tester.pumpWidget(const SizedBox());
    });

    testWidgets('text scaling re-lays out without clipping', (tester) async {
      const content = Text('Scaling body line', style: TextStyle(fontSize: 14));
      await tester.pumpWidget(
        host(
          one(defaultActiveKeys: const {'1'}, content: content),
          textScale: 1,
        ),
      );
      await tester.pump(const Duration(milliseconds: 300));
      final h1 = tester.getRect(find.text('Scaling body line')).height;
      await tester.pumpWidget(
        host(
          one(defaultActiveKeys: const {'1'}, content: content),
          textScale: 2,
        ),
      );
      await tester.pump();
      final h2 = tester.getRect(find.text('Scaling body line')).height;
      expect(h2, greaterThan(h1 * 1.5));
      // The expanded clip height follows the scaled text with no clipping.
      expect(clipHeight(tester, '1'), closeTo(h2 + contentInsets, 0.5));
      expect(
        tester.getRect(panelScope('1')).height,
        greaterThan(h2 + contentInsets),
      );
      await tester.pumpWidget(const SizedBox());
    });

    testWidgets('nested expansion keeps the outer content unclipped', (
      tester,
    ) async {
      await tester.pumpWidget(
        host(
          SemiCollapse(
            children: [
              SemiCollapsePanel(
                itemKey: 'outer',
                header: 'Outer header',
                child: SemiCollapse(
                  children: const [
                    SemiCollapsePanel(
                      itemKey: 'inner',
                      header: 'Inner header',
                      child: Text('Inner body'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
      await tester.tap(find.text('Outer header'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      final before = tester.getRect(panelScope('outer')).height;
      await tester.tap(find.text('Inner header'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      final after = tester.getRect(panelScope('outer')).height;
      expect(after, greaterThan(before + 20));
      expect(find.text('Inner body'), findsOneWidget);
      // The outer clip height follows the grown nested content.
      final innerHeight = tester
          .getRect(find.byType(SemiCollapse).at(1))
          .height;
      expect(
        clipHeight(tester, 'outer'),
        closeTo(innerHeight + contentInsets, 1),
      );
      await tester.pumpWidget(const SizedBox());
    });
  });

  group('header layout and interaction', () {
    testWidgets('arrow side follows expandIconPosition', (tester) async {
      await tester.pumpWidget(host(one()));
      var icon = tester.getRect(arrowOf('1'));
      var text = tester.getRect(find.text('Header 1'));
      expect(icon.center.dx, greaterThan(text.center.dx));
      expect(icon.width, 16); // sizeCollapseIconDefault
      await tester.pumpWidget(
        host(one(expandIconPosition: SemiCollapseIconPosition.left)),
      );
      icon = tester.getRect(arrowOf('1'));
      text = tester.getRect(find.text('Header 1'));
      expect(icon.center.dx, lessThan(text.center.dx));
      expect(
        text.left - icon.right,
        8,
      ); // spacingCollapseHeaderIconLeftMarginRight
      await tester.pumpWidget(const SizedBox());
    });

    testWidgets('extra renders for string and widget headers', (tester) async {
      await tester.pumpWidget(host(one(extra: const Text('EX'))));
      var ex = tester.getRect(find.text('EX'));
      var icon = tester.getRect(arrowOf('1'));
      expect(ex.right, lessThan(icon.left));
      expect(icon.left - ex.right, 8); // spacingCollapseRightPaddingRight
      await tester.pumpWidget(
        host(one(header: const Text('Custom head'), extra: const Text('EX'))),
      );
      expect(find.text('Custom head'), findsOneWidget);
      expect(find.text('EX'), findsOneWidget);
      // Without an arrow the last-child gap vanishes (upstream header-right).
      await tester.pumpWidget(
        host(one(extra: const Text('EX'), showArrow: false)),
      );
      ex = tester.getRect(find.text('EX'));
      expect(arrowOf('1'), findsNothing);
      final box = headerBoxRect(tester, '1');
      expect(ex.right, closeTo(box.right - 8, 0.5)); // header padding only
      await tester.pumpWidget(const SizedBox());
    });

    testWidgets('string header uses the themed weight size and color', (
      tester,
    ) async {
      const theme = SemiThemeData.light();
      await tester.pumpWidget(host(one(defaultActiveKeys: const {'1'})));
      final header = renderedStyle(tester, find.text('Header 1'))!;
      expect(header.fontSize, theme.typography.fontSizeRegular);
      expect(header.fontWeight, theme.typography.fontWeightBold);
      expect(header.color, theme.colors.colorText0);
      final content = renderedStyle(tester, find.text('Content 1'))!;
      expect(content.color, theme.colors.colorText1);
      await tester.pumpWidget(const SizedBox());
    });

    testWidgets('custom icons swap on expand and disable shows expandIcon', (
      tester,
    ) async {
      await tester.pumpWidget(
        host(
          one(expandIcon: const Text('EXP'), collapseIcon: const Text('COL')),
        ),
      );
      expect(find.text('EXP'), findsOneWidget);
      expect(find.text('COL'), findsNothing);
      await tester.tap(find.text('Header 1'));
      await tester.pump();
      expect(find.text('COL'), findsOneWidget);
      expect(find.text('EXP'), findsNothing);
      // Upstream renders the expand icon (disabled tint) for disabled panels
      // even when active.
      await tester.pumpWidget(
        host(
          one(
            defaultActiveKeys: const {'1'},
            disabled: true,
            expandIcon: const Text('EXP'),
            collapseIcon: const Text('COL'),
          ),
        ),
      );
      expect(find.text('EXP'), findsOneWidget);
      expect(find.text('COL'), findsNothing);
      await tester.pumpWidget(const SizedBox());
    });

    testWidgets('showArrow false hides the arrow', (tester) async {
      await tester.pumpWidget(host(one(showArrow: false)));
      expect(arrowOf('1'), findsNothing);
      await tester.pumpWidget(const SizedBox());
    });

    testWidgets('disabled panel does not respond and uses disabled colors', (
      tester,
    ) async {
      const theme = SemiThemeData.light();
      await tester.pumpWidget(host(one(disabled: true)));
      await tester.tap(find.text('Header 1'));
      await tester.pump();
      expect(isExpanded(tester, '1'), isFalse);
      final text = renderedStyle(tester, find.text('Header 1'))!;
      expect(text.color, theme.colors.colorDisabledText);
      final iconTheme = tester.widget<SemiIconTheme>(
        find
            .ancestor(of: arrowOf('1'), matching: find.byType(SemiIconTheme))
            .first,
      );
      expect(iconTheme.data.color, theme.colors.colorDisabledText);
      // Keyboard is ignored as well.
      Focus.of(tester.element(find.text('Header 1'))).requestFocus();
      await tester.pump();
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.pump();
      expect(isExpanded(tester, '1'), isFalse);
      await tester.pumpWidget(const SizedBox());
    });

    testWidgets('hover and pressed backgrounds follow the themed fills', (
      tester,
    ) async {
      const theme = SemiThemeData.light();
      await tester.pumpWidget(host(one()));
      expect(headerBg(tester, '1'), const Color(0x00000000));
      final mouse = await tester.createGesture(kind: PointerDeviceKind.mouse);
      await mouse.addPointer(location: Offset.zero);
      addTearDown(mouse.removePointer);
      await tester.pump();
      await mouse.moveTo(tester.getCenter(find.text('Header 1')));
      await tester.pump();
      expect(headerBg(tester, '1'), theme.colors.colorFill0);
      final press = await tester.startGesture(
        tester.getCenter(find.text('Header 1')),
      );
      await tester.pump();
      expect(headerBg(tester, '1'), theme.colors.colorFill1);
      await press.up();
      await tester.pump();
      await mouse.moveTo(Offset.zero);
      await tester.pump();
      expect(headerBg(tester, '1'), const Color(0x00000000));
      await tester.pumpWidget(const SizedBox());
    });

    testWidgets('disabled header keeps a transparent background', (
      tester,
    ) async {
      const theme = SemiThemeData.light();
      await tester.pumpWidget(host(one(disabled: true)));
      final mouse = await tester.createGesture(kind: PointerDeviceKind.mouse);
      await mouse.addPointer(location: Offset.zero);
      addTearDown(mouse.removePointer);
      await tester.pump();
      await mouse.moveTo(tester.getCenter(find.text('Header 1')));
      await tester.pump();
      expect(headerBg(tester, '1'), isNot(theme.colors.colorFill0));
      await tester.pumpWidget(const SizedBox());
    });

    testWidgets('keyboard toggles with Enter and Space', (tester) async {
      final log = <List<String>>[];
      await tester.pumpWidget(host(one(onActiveKeysChanged: log.add)));
      Focus.of(tester.element(find.text('Header 1'))).requestFocus();
      await tester.pump();
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.pump();
      expect(log, [
        ['1'],
      ]);
      expect(isExpanded(tester, '1'), isTrue);
      await tester.sendKeyEvent(LogicalKeyboardKey.space);
      await tester.pump();
      expect(log.last, isEmpty);
      expect(isExpanded(tester, '1'), isFalse);
      // Unrelated keys stay alone.
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
      await tester.pump();
      expect(log, hasLength(2));
      await tester.pumpWidget(const SizedBox());
    });

    testWidgets('keyboard leaves descendant focus and disabled panels alone', (
      tester,
    ) async {
      final log = <List<String>>[];
      final childFocus = FocusNode();
      addTearDown(childFocus.dispose);
      await tester.pumpWidget(
        host(
          one(
            onActiveKeysChanged: log.add,
            extra: Focus(focusNode: childFocus, child: const Text('note')),
          ),
        ),
      );
      childFocus.requestFocus();
      await tester.pump();
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.pump();
      await tester.sendKeyEvent(LogicalKeyboardKey.space);
      await tester.pump();
      expect(log, isEmpty);
      await tester.pumpWidget(const SizedBox());
    });

    testWidgets('keyboard follows clickHeaderToExpand and arrow presence', (
      tester,
    ) async {
      final log = <List<String>>[];
      await tester.pumpWidget(
        host(one(clickHeaderToExpand: false, onActiveKeysChanged: log.add)),
      );
      // Header taps do not toggle when clickHeaderToExpand is false.
      await tester.tap(find.text('Header 1'));
      await tester.pump();
      expect(log, isEmpty);
      // Arrow taps do.
      await tester.tap(arrowOf('1'));
      await tester.pump();
      expect(log, [
        ['1'],
      ]);
      // Keyboard reuses the trigger settings: with an arrow it toggles.
      Focus.of(tester.element(find.text('Header 1'))).requestFocus();
      await tester.pump();
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.pump();
      expect(log.last, isEmpty);
      // Without an arrow there is no trigger to click (upstream parity).
      await tester.pumpWidget(
        host(
          one(
            clickHeaderToExpand: false,
            showArrow: false,
            onActiveKeysChanged: log.add,
          ),
        ),
      );
      Focus.of(tester.element(find.text('Header 1'))).requestFocus();
      await tester.pump();
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.pump();
      expect(log, hasLength(2));
      await tester.pumpWidget(const SizedBox());
    });

    testWidgets('keyboard accordion and controlled semantics', (tester) async {
      final log = <List<String>>[];
      await tester.pumpWidget(
        host(
          three(
            accordion: true,
            defaultActiveKeys: const {'1'},
            onActiveKeysChanged: log.add,
          ),
        ),
      );
      Focus.of(tester.element(find.text('Header 2'))).requestFocus();
      await tester.pump();
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.pump();
      expect(log, [
        ['2'],
      ]);
      expect(isExpanded(tester, '1'), isFalse);
      expect(isExpanded(tester, '2'), isTrue);
      final controlled = <List<String>>[];
      await tester.pumpWidget(
        host(
          three(
            activeKeys: const <String>{},
            onActiveKeysChanged: controlled.add,
          ),
        ),
      );
      Focus.of(tester.element(find.text('Header 1'))).requestFocus();
      await tester.pump();
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.pump();
      expect(controlled, [
        ['1'],
      ]);
      expect(isExpanded(tester, '1'), isFalse);
      await tester.pumpWidget(const SizedBox());
    });

    testWidgets('keyboard toggles when the arrow is hidden', (tester) async {
      final log = <List<String>>[];
      await tester.pumpWidget(
        host(one(showArrow: false, onActiveKeysChanged: log.add)),
      );
      Focus.of(tester.element(find.text('Header 1'))).requestFocus();
      await tester.pump();
      await tester.sendKeyEvent(LogicalKeyboardKey.space);
      await tester.pump();
      expect(log, [
        ['1'],
      ]);
      expect(isExpanded(tester, '1'), isTrue);
      await tester.pumpWidget(const SizedBox());
    });

    testWidgets('header semantics expose button expanded and label', (
      tester,
    ) async {
      await tester.pumpWidget(host(one()));
      var sem = headerSemantics(tester, '1');
      expect(sem.properties.button, isTrue);
      expect(sem.properties.expanded, isFalse);
      expect(sem.properties.enabled, isTrue);
      expect(sem.properties.label, 'Header 1');
      final data = tester
          .getSemantics(find.text('Header 1'))
          .getSemanticsData();
      expect(data.flagsCollection.isButton, isTrue);
      await tester.tap(find.text('Header 1'));
      await tester.pump(const Duration(milliseconds: 300));
      sem = headerSemantics(tester, '1');
      expect(sem.properties.expanded, isTrue);
      await tester.pumpWidget(host(one(disabled: true)));
      expect(headerSemantics(tester, '1').properties.enabled, isFalse);
      await tester.pumpWidget(const SizedBox());
    });

    testWidgets('RTL mirrors the arrow side and gaps', (tester) async {
      await tester.pumpWidget(host(one(), direction: TextDirection.rtl));
      var icon = tester.getRect(arrowOf('1'));
      var text = tester.getRect(find.text('Header 1'));
      expect(icon.center.dx, lessThan(text.center.dx));
      await tester.pumpWidget(
        host(
          one(expandIconPosition: SemiCollapseIconPosition.left),
          direction: TextDirection.rtl,
        ),
      );
      icon = tester.getRect(arrowOf('1'));
      text = tester.getRect(find.text('Header 1'));
      expect(icon.center.dx, greaterThan(text.center.dx));
      expect(icon.left - text.right, 8);
      await tester.pumpWidget(const SizedBox());
    });

    testWidgets('narrow and unbounded widths lay out without overflow', (
      tester,
    ) async {
      await tester.pumpWidget(
        host(
          width: 160,
          one(
            header: 'A very long panel header that keeps talking',
            extra: const Text('EX'),
          ),
        ),
      );
      expect(find.text('Content 1'), findsNothing);
      await tester.tap(find.textContaining('keeps talking'));
      await tester.pump(const Duration(milliseconds: 300));
      expect(find.text('Content 1'), findsOneWidget);
      await tester.pumpWidget(
        host(UnconstrainedBox(child: one(extra: const Text('EX')))),
      );
      await tester.pump(const Duration(milliseconds: 300));
      expect(find.text('Content 1'), findsNothing);
      await tester.pumpWidget(const SizedBox());
    });

    testWidgets('no Material widgets in the tree', (tester) async {
      await tester.pumpWidget(
        host(
          one(
            defaultActiveKeys: const {'1'},
            extra: const Text('EX'),
            header: const Text('Widget head'),
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 300));
      expect(find.byType(Material), findsNothing);
      await tester.pumpWidget(const SizedBox());
    });
  });
}
