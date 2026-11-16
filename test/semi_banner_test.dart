// Behavior matrix for SemiBanner plus coverage for the 22 Sass declarations
// (22 FIELDS + 0 MOTION + 0 INTERNAL) — the 29 HARDCODES provenance anchors
// live in the widget's file-level note block / call sites. 0 死变量.
import 'dart:io';

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:semi_design_flutter/semi_design_flutter.dart';

// -- theme field table -------------------------------------------------------

typedef _Patch = SemiBannerThemeData Function(Object value);
typedef _Read = Object? Function(SemiResolvedBannerThemeData data);
typedef _Default = Object? Function(SemiThemeData theme);

const _c = Color(0xFF010203);

final List<(String, Object, _Patch, _Read, _Default)> fields = [
  (
    r'$color-banner_info-bg-default: var(--semi-color-info-light-default)',
    _c,
    (v) => SemiBannerThemeData(colorBannerInfoBgDefault: v as Color),
    (d) => d.colorBannerInfoBgDefault,
    (t) => t.colors.colorInfoLightDefault,
  ),
  (
    r'$color-banner_info-text-default: var(--semi-color-info)',
    _c,
    (v) => SemiBannerThemeData(colorBannerInfoTextDefault: v as Color),
    (d) => d.colorBannerInfoTextDefault,
    (t) => t.colors.colorInfo,
  ),
  (
    r'$color-banner_info-border-default: var(--semi-color-info)',
    _c,
    (v) => SemiBannerThemeData(colorBannerInfoBorderDefault: v as Color),
    (d) => d.colorBannerInfoBorderDefault,
    (t) => t.colors.colorInfo,
  ),
  (
    r'$color-banner_warning-bg-default: var(--semi-color-warning-light-default)',
    _c,
    (v) => SemiBannerThemeData(colorBannerWarningBgDefault: v as Color),
    (d) => d.colorBannerWarningBgDefault,
    (t) => t.colors.colorWarningLightDefault,
  ),
  (
    r'$color-banner_warning-text-default: var(--semi-color-warning)',
    _c,
    (v) => SemiBannerThemeData(colorBannerWarningTextDefault: v as Color),
    (d) => d.colorBannerWarningTextDefault,
    (t) => t.colors.colorWarning,
  ),
  (
    r'$color-banner_warning-border-default: var(--semi-color-warning)',
    _c,
    (v) => SemiBannerThemeData(colorBannerWarningBorderDefault: v as Color),
    (d) => d.colorBannerWarningBorderDefault,
    (t) => t.colors.colorWarning,
  ),
  (
    r'$color-banner_success-bg-default: var(--semi-color-success-light-default)',
    _c,
    (v) => SemiBannerThemeData(colorBannerSuccessBgDefault: v as Color),
    (d) => d.colorBannerSuccessBgDefault,
    (t) => t.colors.colorSuccessLightDefault,
  ),
  (
    r'$color-banner_success-text-default: var(--semi-color-success)',
    _c,
    (v) => SemiBannerThemeData(colorBannerSuccessTextDefault: v as Color),
    (d) => d.colorBannerSuccessTextDefault,
    (t) => t.colors.colorSuccess,
  ),
  (
    r'$color-banner_success-border-default: var(--semi-color-success)',
    _c,
    (v) => SemiBannerThemeData(colorBannerSuccessBorderDefault: v as Color),
    (d) => d.colorBannerSuccessBorderDefault,
    (t) => t.colors.colorSuccess,
  ),
  (
    r'$color-banner_danger-bg-default: var(--semi-color-danger-light-default)',
    _c,
    (v) => SemiBannerThemeData(colorBannerDangerBgDefault: v as Color),
    (d) => d.colorBannerDangerBgDefault,
    (t) => t.colors.colorDangerLightDefault,
  ),
  (
    r'$color-banner_danger-text-default: var(--semi-color-danger)',
    _c,
    (v) => SemiBannerThemeData(colorBannerDangerTextDefault: v as Color),
    (d) => d.colorBannerDangerTextDefault,
    (t) => t.colors.colorDanger,
  ),
  (
    r'$color-banner_danger-border-default: var(--semi-color-danger)',
    _c,
    (v) => SemiBannerThemeData(colorBannerDangerBorderDefault: v as Color),
    (d) => d.colorBannerDangerBorderDefault,
    (t) => t.colors.colorDanger,
  ),
  (
    r'$radius-banner: var(--semi-border-radius-small)',
    77.5,
    (v) => SemiBannerThemeData(radiusBanner: v as double),
    (d) => d.radiusBanner,
    (t) => t.radius.borderRadiusSmall.value,
  ),
  (
    r'$spacing-banner_closeBtn-marginLeft: $spacing-base-tight',
    77.5,
    (v) => SemiBannerThemeData(spacingBannerCloseBtnMarginLeft: v as double),
    (d) => d.spacingBannerCloseBtnMarginLeft,
    (t) => 12.0,
  ),
  (
    r'$spacing-banner_extra-marginTop: $spacing-tight',
    77.5,
    (v) => SemiBannerThemeData(spacingBannerExtraMarginTop: v as double),
    (d) => d.spacingBannerExtraMarginTop,
    (t) => 8.0,
  ),
  (
    r'$spacing-banner_icon-marginRight: $spacing-base-tight',
    77.5,
    (v) => SemiBannerThemeData(spacingBannerIconMarginRight: v as double),
    (d) => d.spacingBannerIconMarginRight,
    (t) => 12.0,
  ),
  (
    r'$spacing-banner-paddingX: $spacing-base-tight',
    77.5,
    (v) => SemiBannerThemeData(spacingBannerPaddingX: v as double),
    (d) => d.spacingBannerPaddingX,
    (t) => 12.0,
  ),
  (
    r'$spacing-banner-paddingY: $spacing-base-tight',
    77.5,
    (v) => SemiBannerThemeData(spacingBannerPaddingY: v as double),
    (d) => d.spacingBannerPaddingY,
    (t) => 12.0,
  ),
  (
    r'$spacing-banner_title_description-marginTop: 2px',
    77.5,
    (v) => SemiBannerThemeData(
      spacingBannerTitleDescriptionMarginTop: v as double,
    ),
    (d) => d.spacingBannerTitleDescriptionMarginTop,
    (t) => 2.0,
  ),
  (
    r'$height-banner_closeBtn: 24px',
    77.5,
    (v) => SemiBannerThemeData(heightBannerCloseBtn: v as double),
    (d) => d.heightBannerCloseBtn,
    (t) => 24.0,
  ),
  (
    r'$width-banner_closeBtn: 24px',
    77.5,
    (v) => SemiBannerThemeData(widthBannerCloseBtn: v as double),
    (d) => d.widthBannerCloseBtn,
    (t) => 24.0,
  ),
  (
    r'$width-banner-border: 1px',
    77.5,
    (v) => SemiBannerThemeData(widthBannerBorder: v as double),
    (d) => d.widthBannerBorder,
    (t) => 1.0,
  ),
];

// -- harness -----------------------------------------------------------------

Widget host(
  Widget child, {
  TextDirection direction = TextDirection.ltr,
  double width = 600,
}) => SemiTheme(
  data: const SemiThemeData.light(),
  child: Directionality(
    textDirection: direction,
    child: Align(
      alignment: Alignment.topLeft,
      child: SizedBox(width: width, child: child),
    ),
  ),
);

Future<void> pumpHost(
  WidgetTester tester,
  Widget child, {
  TextDirection direction = TextDirection.ltr,
  double width = 600,
}) async {
  addTearDown(() async => tester.pumpWidget(const SizedBox.shrink()));
  await tester.binding.setSurfaceSize(const Size(1200, 800));
  await tester.pumpWidget(host(child, direction: direction, width: width));
  await tester.pump();
}

Padding descriptionPadding(WidgetTester tester) => tester.widget<Padding>(
  find.byWidgetPredicate((w) => w is Padding && w.child is SemiParagraph),
);

BoxDecoration bannerDecoration(WidgetTester tester) =>
    tester
            .widgetList<Container>(
              find.byWidgetPredicate(
                (w) => w is Container && w.decoration is BoxDecoration,
              ),
            )
            .first
            .decoration! as BoxDecoration;

void main() {
  group('theme fields (22 = 22 FIELDS + 0 MOTION + 0 INTERNAL)', () {
    test('22 fields: merge, copyWith, resolve, equality, defaults', () {
      expect(fields, hasLength(22));
      for (final (sass, value, make, read, expected) in fields) {
        final patch = make(value);
        expect(const SemiBannerThemeData().merge(patch), patch, reason: sass);
        expect(patch.copyWith(), patch, reason: sass);
        expect(patch.copyWith().hashCode, patch.hashCode, reason: sass);
        expect(patch.merge(null), patch, reason: sass);
        expect(
          read(patch.resolve(const SemiThemeData.dark())),
          value,
          reason: sass,
        );
        final light = const SemiThemeData.light();
        expect(
          read(const SemiBannerThemeData().resolve(light)),
          expected(light),
          reason: sass,
        );
        final dark = const SemiThemeData.dark();
        expect(
          read(const SemiBannerThemeData().resolve(dark)),
          expected(dark),
          reason: sass,
        );
      }
    });

    test('every field carries its Sass provenance in the generated source', () {
      final source = File(
        'lib/src/theme/semi_banner_theme_data.dart',
      ).readAsStringSync();
      final names = <String>{};
      for (final (sass, _, _, _, _) in fields) {
        expect(source, contains(sass));
        names.add(sass.split(': ').first.substring(1));
      }
      expect(names, hasLength(22));
      expect(source, contains('packages/semi-foundation/banner/variables.scss'));
      expect(source, contains('Generated by tool/generate_banner.py'));
      expect(source, isNot(contains('# dead variable (上游未消费)')));
    });

    test('the 29 HARDCODES anchors live in the widget source', () {
      final widgetSource = File(
        'lib/src/components/semi_banner.dart',
      ).readAsStringSync();
      const anchors = <String>[
        "TYPE: ['info', 'success', 'danger', 'warning']",
        "type: 'info'",
        'fullMode: true',
        'theme="borderless"',
        'size="small"',
        'type="tertiary"',
        'IconClose',
        'IconAlertTriangle',
        'IconTickCircle',
        'IconInfoCircle',
        'IconAlertCircle',
        'size="large"',
        'heading={5}',
        'Typography.Paragraph',
        'margin: 0',
        'role="alert"',
        'locale?.close',
        'title || title === 0',
        'children || children === 0',
        'e.stopPropagation()',
        'notifyClose(e)',
        'setVisible()',
        "'target' has been deprecated",
        '!fullMode && bordered',
        'justify-content: center',
        'align-items: center',
        r'.#{$module}-title + .#{$module}-description',
        'margin-left: 0',
        'margin-right: \$spacing-banner_closeBtn-marginLeft',
      ];
      expect(anchors, hasLength(29));
      for (final anchor in anchors) {
        expect(widgetSource, contains(anchor), reason: anchor);
      }
    });

    test('type coverage: 12 Color + 10 double = 22', () {
      final counts = <String, int>{};
      for (final (_, value, _, _, _) in fields) {
        counts.update(
          value.runtimeType.toString(),
          (n) => n + 1,
          ifAbsent: () => 1,
        );
      }
      expect(counts['Color'], 12);
      expect(counts['double'], 10);
    });

    test('0 dead variables: every field name appears in the widget source', () {
      final widgetSource = File(
        'lib/src/components/semi_banner.dart',
      ).readAsStringSync();
      for (final (sass, _, _, _, _) in fields) {
        final name = sass.split(':').first.substring(1);
        var camel = '';
        var upper = false;
        for (final char in name.split('')) {
          if (char == '-' || char == '_') {
            upper = true;
          } else if (upper) {
            camel += char.toUpperCase();
            upper = false;
          } else {
            camel += char;
          }
        }
        expect(widgetSource, contains(camel), reason: camel);
      }
      final docs = File('docs/semi_banner.md').readAsStringSync();
      expect(docs, contains('22 = 22 FIELDS + 0 MOTION + 0 INTERNAL'));
      expect(docs, contains('0 死变量'));
    });

    test('quirks: both copy-paste comments recorded verbatim', () {
      final source = File(
        'lib/src/theme/semi_banner_theme_data.dart',
      ).readAsStringSync();
      expect(
        source,
        contains(r'$spacing-banner_extra-marginTop: $spacing-tight'),
      );
      expect(
        source,
        contains(r'$spacing-banner_icon-marginRight: $spacing-base-tight'),
      );
    });

    test('SemiComponentThemes wiring', () {
      const themes = SemiComponentThemes();
      expect(themes.banner, const SemiBannerThemeData());
      expect(
        themes.copyWith(
          banner: const SemiBannerThemeData(widthBannerBorder: 40),
        ),
        const SemiComponentThemes(
          banner: SemiBannerThemeData(widthBannerBorder: 40),
        ),
      );
    });
  });

  group('behavior', () {
    testWidgets('renders info banner with default icon, title, description', (
      tester,
    ) async {
      await pumpHost(
        tester,
        const SemiBanner(
          title: '信息提示',
          description: '这是一条辅助说明。',
          extra: Text('额外内容'),
        ),
      );
      expect(find.text('信息提示'), findsOneWidget);
      expect(find.text('这是一条辅助说明。'), findsOneWidget);
      expect(find.text('额外内容'), findsOneWidget);
      expect(find.byType(SemiTitle), findsOneWidget);
      expect(find.byType(SemiParagraph), findsOneWidget);
      final icon = tester.widget<SemiIcon>(find.byType(SemiIcon).first);
      expect(icon.data, SemiIcons.infoCircle);
      expect(icon.size, SemiIconSize.large);
      expect(tester.takeException(), isNull);
    });

    testWidgets('type maps to its icon and background color', (tester) async {
      const light = SemiThemeData.light();
      for (final (type, icon, background) in <(
        SemiBannerType,
        SemiIconData,
        Color,
      )>[
        (SemiBannerType.warning, SemiIcons.alertTriangle, light.colors.colorWarningLightDefault),
        (SemiBannerType.success, SemiIcons.tickCircle, light.colors.colorSuccessLightDefault),
        (SemiBannerType.danger, SemiIcons.alertCircle, light.colors.colorDangerLightDefault),
      ]) {
        await tester.pumpWidget(host(SemiBanner(type: type, title: '标题')));
        await tester.pump();
        expect(
          tester.widgetList<SemiIcon>(find.byType(SemiIcon)).any(
            (i) => i.data == icon,
          ),
          isTrue,
          reason: '$type',
        );
        expect(bannerDecoration(tester).color, background, reason: '$type');
      }
      await tester.pumpWidget(const SizedBox.shrink());
    });

    testWidgets('close hides an uncontrolled banner and notifies', (
      tester,
    ) async {
      var closed = 0;
      await pumpHost(
        tester,
        SemiBanner(title: '可关闭', onClose: () => closed++),
      );
      expect(find.text('可关闭'), findsOneWidget);
      await tester.tap(find.byType(SemiButton));
      await tester.pump();
      expect(closed, 1);
      expect(find.text('可关闭'), findsNothing);
    });

    testWidgets('controlled visible only notifies; false hides', (tester) async {
      var closed = 0;
      await pumpHost(
        tester,
        SemiBanner(title: '受控', visible: true, onClose: () => closed++),
      );
      await tester.tap(find.byType(SemiButton));
      await tester.pump();
      expect(closed, 1);
      expect(find.text('受控'), findsOneWidget);
      await tester.pumpWidget(
        host(const SemiBanner(title: '受控', visible: false)),
      );
      await tester.pump();
      expect(find.text('受控'), findsNothing);
    });

    testWidgets('controlled to uncontrolled keeps the last value', (
      tester,
    ) async {
      await pumpHost(tester, const SemiBanner(title: '保留', visible: false));
      expect(find.text('保留'), findsNothing);
      await tester.pumpWidget(host(const SemiBanner(title: '保留')));
      await tester.pump();
      expect(find.text('保留'), findsNothing);
    });

    testWidgets(
      'closable false drops the closer; showIcon false drops the icon; '
      'custom icons replace defaults',
      (tester) async {
        await pumpHost(
          tester,
          const SemiBanner(
            title: '无关闭',
            closable: false,
            icon: SizedBox(
              key: Key('custom-icon'),
              width: 12,
              height: 12,
            ),
          ),
        );
        expect(find.byType(SemiButton), findsNothing);
        expect(find.byKey(const Key('custom-icon')), findsOneWidget);
        expect(find.byType(SemiIcon), findsNothing);
        await tester.pumpWidget(
          host(
            const SemiBanner(
              title: '无图标',
              showIcon: false,
              closeIcon: SizedBox(
                key: Key('custom-close'),
                width: 12,
                height: 12,
              ),
            ),
          ),
        );
        await tester.pump();
        expect(find.byType(SemiIcon), findsNothing);
        expect(find.byKey(const Key('custom-close')), findsOneWidget);
      },
    );

    testWidgets('numeric zero renders; empty strings do not', (tester) async {
      await pumpHost(
        tester,
        const SemiBanner(title: 0, description: 0, extra: Text('')),
      );
      expect(find.text('0'), findsNWidgets(2));
      await tester.pumpWidget(host(const SemiBanner(title: '', description: '')));
      await tester.pump();
      expect(find.byType(SemiTitle), findsNothing);
      expect(find.byType(SemiParagraph), findsNothing);
    });

    testWidgets('in-container: radius, bordered border, 2px title gap', (
      tester,
    ) async {
      await pumpHost(
        tester,
        const SemiBanner(
          fullMode: false,
          bordered: true,
          title: '标题',
          description: '描述',
        ),
      );
      final box = bannerDecoration(tester);
      const t = SemiThemeData.light();
      expect(box.borderRadius, BorderRadius.circular(3));
      expect(box.border!.top.width, 1);
      expect(box.border!.top.color, t.colors.colorInfo);
      expect(descriptionPadding(tester).padding, const EdgeInsets.only(top: 2));
      expect(tester.takeException(), isNull);
    });

    testWidgets('fullMode: no radius/border and no title-description gap', (
      tester,
    ) async {
      await pumpHost(
        tester,
        const SemiBanner(bordered: true, title: '标题', description: '描述'),
      );
      final box = bannerDecoration(tester);
      expect(box.borderRadius, isNull);
      expect(box.border, isNull);
      expect(descriptionPadding(tester).padding, EdgeInsets.zero);
    });

    testWidgets(
      'extra sits below with the extra margin; close button is 24x24 '
      'with the close margin',
      (tester) async {
        await pumpHost(tester, const SemiBanner(title: '标题', extra: Text('底部')));
        final gap = tester.widget<Padding>(
          find
              .ancestor(of: find.text('底部'), matching: find.byType(Padding))
              .first,
        );
        expect(gap.padding.resolve(TextDirection.ltr).top, 8);
        final box = tester.widget<SizedBox>(
          find
              .ancestor(
                of: find.byType(SemiButton),
                matching: find.byType(SizedBox),
              )
              .first,
        );
        expect(box.width, 24);
        expect(box.height, 24);
        final close = tester.widget<Padding>(
          find
              .ancestor(
                of: find.byType(SemiButton),
                matching: find.byType(Padding),
              )
              .first,
        );
        expect(close.padding.resolve(TextDirection.ltr).left, 12);
        expect(close.padding.resolve(TextDirection.ltr).right, 0);
      },
    );

    testWidgets('RTL mirrors the close and icon margins', (tester) async {
      await pumpHost(
        tester,
        const SemiBanner(title: '标题'),
        direction: TextDirection.rtl,
      );
      final close = tester.widget<Padding>(
        find
            .ancestor(
              of: find.byType(SemiButton),
              matching: find.byType(Padding),
            )
            .first,
      );
      expect(close.padding.resolve(TextDirection.rtl).right, 12);
      expect(close.padding.resolve(TextDirection.rtl).left, 0);
      final icon = tester.widget<Padding>(
        find
            .ancestor(of: find.byType(SemiIcon), matching: find.byType(Padding))
            .first,
      );
      expect(icon.padding.resolve(TextDirection.rtl).left, 12);
    });

    testWidgets('local theme patches override resolved colors', (tester) async {
      await pumpHost(
        tester,
        SemiBannerTheme(
          data: const SemiBannerThemeData(
            colorBannerInfoBgDefault: Color(0xffabcdef),
          ),
          child: const SemiBanner(title: '主题'),
        ),
      );
      expect(bannerDecoration(tester).color, const Color(0xffabcdef));
    });

    testWidgets('role="alert" semantics is a live region', (tester) async {
      await pumpHost(tester, const SemiBanner(title: '提示'));
      final semantics = tester.widget<Semantics>(
        find
            .descendant(
              of: find.byType(SemiBanner),
              matching: find.byType(Semantics),
            )
            .first,
      );
      expect(semantics.properties.liveRegion, isTrue);
    });
  });
}
