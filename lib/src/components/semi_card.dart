import 'dart:ui' show SemanticsRole;

import 'package:flutter/widgets.dart';

import '../theme/semi_card_theme.dart';
import '../theme/semi_card_theme_data.dart';
import '../theme/semi_theme.dart';
import 'semi_tooltip.dart';
import 'typography/semi_text.dart';
import 'typography/semi_title.dart';

/// When the themed [SemiShadows] shadow shows: on hover only, or always.
/// A null `shadows` shows no shadow. Mirrors the upstream `hover` / `always`
/// entries of `strings.SHADOWS` in
/// packages/semi-foundation/card/constants.ts — the upstream test value
/// `'show'` is not part of that list and is rejected by this enum.
enum SemiCardShadows { hover, always }

/// Card container: header, cover, body and footer sections with optional
/// border, corner clip and hover/always shadow.
///
/// Mirrors upstream `packages/semi-ui/card/index.tsx` plus
/// `packages/semi-foundation/card/{card,rtl}.scss` without Material. [title]
/// accepts a [String] (rendered as `SemiTitle(heading: 6)` with one-line
/// ellipsis plus a hover [SemiTooltip] carrying the full text) or a [Widget]
/// (placed as-is); any other type fails an assert. [header] replaces the whole
/// title row (title + headerExtraContent), like upstream `header || wrapper`.
/// Upstream `headerStyle` / `bodyStyle` / `footerStyle` inline styles map to
/// [headerPadding] / [bodyPadding] / [footerPadding]; `style` / `className`
/// are not ported. There is no click callback, no `hoverable` and no `size`
/// upstream either.
///
/// With [shadows] set the root shows the themed `shadowCard` shadow (`hover`
/// raises it on pointer enter) over
/// [SemiCardThemeData.motionCardTransitionDuration], and the pointer becomes
/// a click cursor even though the card is not clickable — upstream
/// `cursor: pointer` on `.semi-card-shadows` (documented quirk).
class SemiCard extends StatelessWidget {
  const SemiCard({
    super.key,
    this.title,
    this.header,
    this.headerExtraContent,
    this.headerLine = true,
    this.cover,
    this.body,
    this.actions,
    this.footer,
    this.footerLine = false,
    this.loading = false,
    this.bordered = true,
    this.shadows,
    this.headerPadding,
    this.bodyPadding,
    this.footerPadding,
    this.semanticsLabel,
  }) : assert(
         title == null || title is String || title is Widget,
         'title must be a String or a Widget',
       );

  /// String runs through [SemiTitle] (heading 6, one line, ellipsis) wrapped
  /// in an [SemiTooltip] that shows the full text on hover; any other [Widget]
  /// is placed as-is.
  final Object? title;

  /// Replaces the entire title row (title + headerExtraContent).
  final Widget? header;

  /// Tail of the title row; unstyled slot — a [DefaultTextStyle] applies the
  /// upstream `header-wrapper-extra` metrics (extra size/weight/color).
  final Widget? headerExtraContent;

  /// Whether a divider line runs under the header (upstream `headerLine`).
  final bool headerLine;

  /// Cover slot: the child is stretched to the card width and corner-clipped
  /// with the card radius (upstream `> * { width: 100% }` + `overflow: hidden`).
  final Widget? cover;

  /// Body content (upstream `children`).
  final Widget? body;

  /// Bottom action group of the body (upstream `actions`). Rendering the
  /// group is keyed on presence, like upstream `Array.isArray(actions)`.
  final List<Widget>? actions;

  /// Footer slot below the body.
  final Widget? footer;

  /// Whether a divider line runs above the footer (upstream `footerLine`).
  final bool footerLine;

  /// Replaces the body content with the skeleton placeholder while true
  /// (upstream `Skeleton loading`, header/cover/footer untouched).
  final bool loading;

  /// Whether the outer border is drawn (upstream `bordered`).
  final bool bordered;

  /// Shadow timing; null shows no shadow.
  final SemiCardShadows? shadows;

  /// Header padding; defaults to all-around `spacingCardPadding`.
  final EdgeInsetsGeometry? headerPadding;

  /// Body padding; defaults to all-around `spacingCardPadding`.
  final EdgeInsetsGeometry? bodyPadding;

  /// Footer padding; defaults to all-around `spacingCardPadding`.
  final EdgeInsetsGeometry? footerPadding;

  /// Region label for the whole card (upstream `aria-label`).
  final String? semanticsLabel;

  @override
  Widget build(BuildContext context) {
    final theme = SemiCardTheme.resolve(context);
    return _CardShell(
      theme: theme,
      bordered: bordered,
      shadows: shadows,
      loading: loading,
      semanticsLabel: semanticsLabel,
      child: DefaultTextStyle(
        style: TextStyle(
          fontSize: theme.fontCardDefaultFontSize,
          height:
              theme.fontCardDefaultLineHeight / theme.fontCardDefaultFontSize,
          fontWeight: theme.fontCardDefaultFontWeight,
          letterSpacing: _CardMetrics.letterSpacing,
        ),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final bounded = constraints.hasBoundedWidth;
            final sections = <Widget>[
              if (header != null || headerExtraContent != null || title != null)
                _header(context, theme, bounded),
              if (cover != null) _cover(theme, bounded),
              _body(context, theme),
              if (footer != null) _footer(theme),
            ];
            final content = Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: bounded
                  ? CrossAxisAlignment.stretch
                  : CrossAxisAlignment.start,
              children: sections,
            );
            // Upstream `.semi-card` is a block box: it fills its container in
            // bounded width and shrink-wraps (mainAxisSize.min) when unbounded.
            return bounded
                ? SizedBox(width: double.infinity, child: content)
                : content;
          },
        ),
      ),
    );
  }

  Widget _header(
    BuildContext context,
    SemiResolvedCardThemeData theme,
    bool bounded,
  ) {
    Widget? titleNode;
    if (title case final String text) {
      final styled = SemiTitle(
        text,
        heading: 6,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      );
      // Upstream `ellipsis: { showTooltip: true }` on the string title.
      titleNode = SemiTooltip(content: Text(text), child: styled);
    } else if (title case final Widget widget) {
      titleNode = widget;
    }
    // `&-spacing { margin-right: $spacing-card-margin }` on the title when the
    // extra exists; `EdgeInsetsDirectional` mirrors it in RTL like rtl.scss.
    if (titleNode != null && headerExtraContent != null) {
      titleNode = Padding(
        padding: EdgeInsetsDirectional.only(end: theme.spacingCardMargin),
        child: titleNode,
      );
    }
    final extraNode = headerExtraContent == null
        ? null
        : DefaultTextStyle.merge(
            style: TextStyle(
              fontSize: theme.fontCardExtraFontSize,
              height:
                  theme.fontCardDefaultLineHeight / theme.fontCardExtraFontSize,
              fontWeight: theme.fontCardExtraFontWeight,
              color: theme.colorCardExtraText,
              letterSpacing: _CardMetrics.letterSpacing,
            ),
            child: headerExtraContent!,
          );
    // Upstream `flex-direction: row-reverse` with the extra first in DOM order
    // keeps the extra at the row tail (and at the logical end in RTL).
    final row = Row(
      mainAxisSize: bounded ? MainAxisSize.max : MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.end,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (titleNode != null)
          bounded ? Expanded(child: titleNode) : Flexible(child: titleNode),
        ?extraNode,
      ],
    );
    // `header` replaces the whole title row (title + extra). A Container adds
    // the decoration border to its padding (`_paddingIncludingDecoration`), so
    // the `&-header-bordered { border-bottom }` divider occupies one
    // `widthCardBorder` of layout height below the padding box like CSS.
    return Container(
      padding: headerPadding ?? EdgeInsets.all(theme.spacingCardPadding),
      decoration: headerLine
          ? BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  width: theme.widthCardBorder,
                  color: theme.colorCardBorder,
                ),
              ),
            )
          : null,
      child: header ?? row,
    );
  }

  Widget _cover(SemiResolvedCardThemeData theme, bool bounded) {
    final child = cover!;
    // `> * { display: block; width: 100% }` in card.scss: the cover child is
    // stretched to the card width and corner-clipped by the root clip.
    return bounded ? SizedBox(width: double.infinity, child: child) : child;
  }

  Widget _body(BuildContext context, SemiResolvedCardThemeData theme) {
    // `children && <Skeleton placeholder loading={loading}>` swaps the body
    // content for the placeholder while loading.
    final content = loading ? _placeholder(context, theme) : body;
    final actionsBlock = actions == null
        ? null
        : Container(
            // `margin-top: $spacing-card-margin` on `&-body-actions`.
            margin: EdgeInsetsDirectional.only(top: theme.spacingCardMargin),
            padding: EdgeInsetsDirectional.only(top: theme.spacingCardPadding),
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(
                  width: theme.widthCardBorder,
                  color: theme.colorCardBorder,
                ),
              ),
            ),
            child: Wrap(
              spacing: _CardMetrics.actionsGap,
              runSpacing: _CardMetrics.actionsGap,
              children: actions!,
            ),
          );
    return Container(
      padding: bodyPadding ?? EdgeInsets.all(theme.spacingCardPadding),
      // `.semi-card-body` sets `color: $color-card_body-text` for its text.
      child: DefaultTextStyle.merge(
        style: TextStyle(color: theme.colorCardBodyText),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [?content, ?actionsBlock],
        ),
      ),
    );
  }

  Widget _footer(SemiResolvedCardThemeData theme) {
    // A Container adds the decoration border to its padding, so the
    // `&-footer-bordered { border-top }` divider occupies one `widthCardBorder`
    // of layout height above the padding box like CSS (see `_header`).
    return Container(
      padding: footerPadding ?? EdgeInsets.all(theme.spacingCardPadding),
      decoration: footerLine
          ? BoxDecoration(
              border: Border(
                top: BorderSide(
                  width: theme.widthCardBorder,
                  color: theme.colorCardBorder,
                ),
              ),
            )
          : null,
      child: footer,
    );
  }

  /// Simplified stand-in for the upstream placeholder
  /// `<Skeleton.Title /><br /><Skeleton.Paragraph rows={3} />` rendered by
  /// `packages/semi-ui/card/index.tsx`: a title bar, a blank line and three
  /// paragraph blocks. Block paint follows
  /// `background: $color-skeleton_default-bg-default` and
  /// `border-radius: $radius-skeleton_item` of
  /// packages/semi-foundation/skeleton/skeleton.scss — both resolve through
  /// global tokens (`colorFill0`, `borderRadiusSmall`), not card theme fields.
  Widget _placeholder(BuildContext context, SemiResolvedCardThemeData theme) {
    final tokens = SemiTheme.of(context);
    final color = tokens.colors.colorFill0;
    final radius = BorderRadius.circular(tokens.radius.borderRadiusSmall.value);
    return LayoutBuilder(
      builder: (context, constraints) {
        final maxWidth = constraints.maxWidth;
        Widget sized(double widthFactor, double height) => SizedBox(
          height: height,
          width: maxWidth.isFinite ? maxWidth * widthFactor : null,
          child: DecoratedBox(
            decoration: BoxDecoration(color: color, borderRadius: radius),
          ),
        );
        return Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Skeleton.Title
            sized(1, _CardMetrics.loadingTitleHeight),
            // `<br />` — one blank line box of the body line height.
            SizedBox(height: theme.fontCardDefaultLineHeight),
            // Skeleton.Paragraph rows={3}
            sized(1, _CardMetrics.loadingRowHeight),
            SizedBox(height: _CardMetrics.loadingRowGap),
            sized(1, _CardMetrics.loadingRowHeight),
            SizedBox(height: _CardMetrics.loadingRowGap),
            sized(
              _CardMetrics.loadingLastRowWidthFactor,
              _CardMetrics.loadingRowHeight,
            ),
          ],
        );
      },
    );
  }
}

/// Card meta: avatar plus a title/description column.
///
/// Mirrors upstream `packages/semi-ui/card/meta.tsx` with the
/// `.semi-card-meta*` rules of card.scss. [title] and [description] each
/// accept a [String] (styled by the card theme fields) or a [Widget]
/// (placed as-is); any other type fails an assert. The avatar sits at the
/// logical start with a `spacingCardAvatarMarginRight` gap that mirrors in
/// RTL.
class SemiCardMeta extends StatelessWidget {
  const SemiCardMeta({super.key, this.avatar, this.title, this.description})
    : assert(
        title == null || title is String || title is Widget,
        'title must be a String or a Widget',
      ),
      assert(
        description == null || description is String || description is Widget,
        'description must be a String or a Widget',
      );

  /// Avatar slot at the logical start.
  final Widget? avatar;

  /// String runs through [SemiText] with the meta title metrics; any other
  /// [Widget] is placed as-is.
  final Object? title;

  /// String runs through [SemiText] with the meta description metrics; any
  /// other [Widget] is placed as-is.
  final Object? description;

  @override
  Widget build(BuildContext context) {
    final theme = SemiCardTheme.resolve(context);
    final titleStyle = TextStyle(
      fontSize: theme.fontCardTitleFontSize,
      height: theme.fontCardTitleLineHeight / theme.fontCardTitleFontSize,
      fontWeight: theme.fontCardTitleFontWeight,
      color: theme.colorCardTitleText,
      letterSpacing: _CardMetrics.letterSpacing,
    );
    final descriptionStyle = TextStyle(
      fontSize: theme.fontCardDefaultFontSize,
      height: theme.fontCardDefaultLineHeight / theme.fontCardDefaultFontSize,
      fontWeight: theme.fontCardDefaultFontWeight,
      color: theme.colorCardDescriptionText,
      letterSpacing: _CardMetrics.letterSpacing,
    );
    Widget? titleNode;
    if (title case final String text) {
      titleNode = SemiText(text, style: titleStyle);
    } else if (title case final Widget widget) {
      titleNode = widget;
    }
    Widget? descriptionNode;
    if (description case final String text) {
      descriptionNode = SemiText(text, style: descriptionStyle);
    } else if (description case final Widget widget) {
      descriptionNode = widget;
    }
    final wrapper = Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [?titleNode, ?descriptionNode],
    );
    return LayoutBuilder(
      builder: (context, constraints) {
        final bounded = constraints.hasBoundedWidth;
        return Row(
          mainAxisSize: bounded ? MainAxisSize.max : MainAxisSize.min,
          // `.semi-card-meta { align-items: center }`.
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            if (avatar != null)
              Padding(
                padding: EdgeInsetsDirectional.only(
                  end: theme.spacingCardAvatarMarginRight,
                ),
                child: avatar!,
              ),
            if (titleNode != null || descriptionNode != null)
              bounded ? Expanded(child: wrapper) : Flexible(child: wrapper),
          ],
        );
      },
    );
  }
}

/// Owns the hover state for `shadows: hover` plus the clipped, decorated
/// frame shared by both shadow modes.
class _CardShell extends StatefulWidget {
  const _CardShell({
    required this.theme,
    required this.bordered,
    required this.shadows,
    required this.loading,
    required this.semanticsLabel,
    required this.child,
  });

  final SemiResolvedCardThemeData theme;
  final bool bordered;
  final SemiCardShadows? shadows;
  final bool loading;
  final String? semanticsLabel;
  final Widget child;

  @override
  State<_CardShell> createState() => _CardShellState();
}

class _CardShellState extends State<_CardShell> {
  bool _hovering = false;

  @override
  Widget build(BuildContext context) {
    final theme = widget.theme;
    final borderInset = widget.bordered ? theme.widthCardBorder : 0.0;
    final shadowLayers = widget.shadows == null
        ? null
        : [
            // `box-shadow: $shadow-card` on `.semi-card-shadows-*`.
            // `SemiShadows.toBoxShadows` refuses CSS inset layers and the
            // dark-mode default `--semi-shadow-elevated` carries one
            // (`inset 0 0 0 1px`); only the drop layers reach BoxDecoration
            // (docs/semi_card.md 差异清单).
            for (final layer in theme.shadowCard.layers)
              if (!layer.inset) layer.toBoxShadow(),
          ];
    final shadowed =
        widget.shadows == SemiCardShadows.always ||
        (widget.shadows == SemiCardShadows.hover && _hovering);
    final content = ClipRRect(
      // CSS `overflow: hidden` clips at the padding box curve, i.e. the border
      // radius reduced by the border width.
      borderRadius: BorderRadius.circular(
        (theme.radiusCard - borderInset).clamp(0.0, double.infinity),
      ),
      child: widget.child,
    );
    return Semantics(
      container: true,
      label: widget.semanticsLabel,
      // `aria-busy={loading}` on the root. Flutter has no busy semantics flag;
      // the status role is the closest supported marker of an updating
      // region (docs/semi_card.md 差异清单).
      role: widget.loading ? SemanticsRole.status : null,
      child: MouseRegion(
        // `cursor: pointer` on `.semi-card-shadows` — upstream shows a click
        // cursor even though the card is not clickable (documented quirk).
        cursor: widget.shadows != null
            ? SystemMouseCursors.click
            : MouseCursor.defer,
        onEnter: (_) => setState(() => _hovering = true),
        onExit: (_) => setState(() => _hovering = false),
        child: AnimatedContainer(
          // `transition: box-shadow 300ms` on `.semi-card-shadows`.
          duration: theme.motionCardTransitionDuration,
          // CSS border-box: `Container` adds the decoration border to its
          // padding, so content (and the overflow clip) starts inside the
          // border and a full-bleed cover never paints over it.
          decoration: BoxDecoration(
            color: theme.colorCardBgDefault,
            border: widget.bordered
                ? Border.all(
                    width: theme.widthCardBorder,
                    color: theme.colorCardBorder,
                  )
                : null,
            borderRadius: BorderRadius.circular(theme.radiusCard),
            boxShadow: shadowed ? shadowLayers : null,
          ),
          child: content,
        ),
      ),
    );
  }
}

// Local Sass-derived metrics, not generated CSS variable tokens.
// packages/semi-foundation/card/{variables,card}.scss,
// packages/semi-ui/card/index.tsx and the Skeleton placeholder metrics of
// packages/semi-foundation/skeleton/{variables,skeleton}.scss.
abstract final class _CardMetrics {
  /// `z-index: $z-card_hover` (`$z-card_hover: 1`) in
  /// packages/semi-foundation/card/variables.scss — raised on hover to keep
  /// grid CardGroup shadows from overlapping. CardGroup is not ported, so the
  /// value is kept as documentation only.
  // ignore: unused_field
  static const double zCardHover = 1;

  /// `<Space spacing={12}>` in packages/semi-ui/card/index.tsx — gap between
  /// action items.
  static const double actionsGap = 12;

  /// `letter-spacing: 0em` in packages/semi-foundation/card/card.scss.
  static const double letterSpacing = 0;

  /// `height: $height-skeleton_title` in
  /// packages/semi-foundation/skeleton/skeleton.scss
  /// (`$height-skeleton_title: $height-control-small`, 24px) — loading title
  /// bar height.
  static const double loadingTitleHeight = 24;

  /// `height: $height-skeleton_li` in
  /// packages/semi-foundation/skeleton/skeleton.scss (16px) — loading
  /// paragraph row height.
  static const double loadingRowHeight = 16;

  /// `margin-bottom: $spacing-skeleton_li-marginBottom` in
  /// packages/semi-foundation/skeleton/skeleton.scss (10px) — gap between
  /// loading paragraph rows.
  static const double loadingRowGap = 10;

  /// `width: 60%` (`li:last-child`) in
  /// packages/semi-foundation/skeleton/skeleton.scss — last loading paragraph
  /// row width factor.
  static const double loadingLastRowWidthFactor = 0.6;
}
