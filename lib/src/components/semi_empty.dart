import 'package:flutter/widgets.dart';

import '../theme/semi_empty_theme.dart';
import '../theme/semi_theme.dart';
import 'typography/semi_text.dart';
import 'typography/semi_title.dart';

enum SemiEmptyLayout { vertical, horizontal }

/// Empty state placeholder: optional [image], text block and action [footer].
///
/// Mirrors upstream `packages/semi-ui/empty/index.tsx` plus
/// `packages/semi-foundation/empty/empty.scss` without Material. [title] and
/// [description] each accept a [String] (rendered with the Semi typography
/// scale) or a [Widget] (placed as-is); any other type fails an assert.
///
/// Title typography follows upstream render: with a resolved image the title
/// is `SemiTitle(heading: 4)` weighted by
/// `theme.fontEmptyTitleFontWeight` (600 by default); without one it is
/// `SemiTitle(heading: 6)` at weight 400. "With an image" is decided after
/// dark-mode resolution like upstream: in dark mode [darkModeImage] wins and
/// falls back to [image]; in light mode only [image] is considered.
/// Upstream `imageStyle`/`style` are not ported; use [padding] and the image
/// widget itself instead. Upstream `children` is named [footer] here.
class SemiEmpty extends StatelessWidget {
  const SemiEmpty({
    super.key,
    this.image,
    this.darkModeImage,
    this.title,
    this.description,
    this.footer,
    this.layout = SemiEmptyLayout.vertical,
    this.padding,
    this.semanticsLabel,
  }) : assert(
         title == null || title is String || title is Widget,
         'title must be a String or a Widget',
       ),
       assert(
         description == null || description is String || description is Widget,
         'description must be a String or a Widget',
       );

  /// Decorative illustration slot, hidden from semantics and not selectable.
  final Widget? image;

  /// Dark-mode replacement for [image]; when null [image] is reused in dark
  /// mode. Driven by [SemiThemeData.dark] instead of upstream's DOM
  /// `theme-mode` MutationObserver.
  final Widget? darkModeImage;

  /// String runs through [SemiTitle]; any other [Widget] is placed as-is.
  final Object? title;

  /// String runs through [SemiText] colored by
  /// `theme.colorEmptyDescriptionTextDefault`; any other [Widget] is placed
  /// as-is.
  final Object? description;

  /// Action area below the text, always 24 (theme) above its slot.
  final Widget? footer;

  /// Vertical stacks image above content; horizontal puts content at the
  /// logical start of the image with a 32 (theme) gap that mirrors in RTL.
  final SemiEmptyLayout layout;

  /// Root padding replacing upstream `style`.
  final EdgeInsetsGeometry? padding;

  /// Region label for the whole placeholder when provided.
  final String? semanticsLabel;

  @override
  Widget build(BuildContext context) {
    final theme = SemiEmptyTheme.resolve(context);
    final vertical = layout == SemiEmptyLayout.vertical;
    final img = SemiTheme.of(context).dark ? (darkModeImage ?? image) : image;
    final hasImage = img != null;

    Widget? titleNode;
    Widget? descriptionNode;
    if (title case final String text) {
      titleNode = SemiTitle(
        text,
        heading: hasImage ? 4 : 6,
        weight: hasImage ? theme.fontEmptyTitleFontWeight : FontWeight.w400,
        textAlign: vertical ? TextAlign.center : null,
      );
    } else if (title case final Widget widget) {
      titleNode = widget;
    }
    if (description case final String text) {
      descriptionNode = SemiText(
        text,
        style: TextStyle(color: theme.colorEmptyDescriptionTextDefault),
        textAlign: vertical ? TextAlign.center : null,
      );
    } else if (description case final Widget widget) {
      descriptionNode = widget;
    }

    final content = Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: vertical
          ? CrossAxisAlignment.center
          : CrossAxisAlignment.start,
      children: [
        ?titleNode,
        if (descriptionNode != null) ...[
          // Adjacent-sibling rule: top margin only after a title.
          if (titleNode != null)
            SizedBox(height: theme.spacingEmptyTitleMarginTop),
          descriptionNode,
        ],
        if (footer != null) ...[
          SizedBox(height: theme.spacingEmptyFooterMarginTop),
          footer!,
        ],
      ],
    );

    final body = vertical
        ? Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              if (img != null) _imageArea(img),
              SizedBox(height: theme.spacingEmptyContentVerticalMarginTop),
              content,
            ],
          )
        : Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (img != null) _imageArea(img),
              Flexible(
                child: Padding(
                  padding: EdgeInsetsDirectional.only(
                    start: theme.spacingEmptyContentHorizontalMarginLeft,
                  ),
                  child: content,
                ),
              ),
            ],
          );
    return Semantics(
      container: semanticsLabel != null,
      label: semanticsLabel,
      child: padding == null ? body : Padding(padding: padding!, child: body),
    );
  }

  /// aria-hidden, `user-select: none` region of upstream `empty.scss`.
  static Widget _imageArea(Widget child) =>
      ExcludeSemantics(child: SelectionContainer.disabled(child: child));
}
