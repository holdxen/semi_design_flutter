import 'package:flutter/widgets.dart';

import '../theme/semi_tag_theme.dart';
import 'semi_tag.dart';

/// One entry of a [SemiTagGroup] tag list.
///
/// **Incomplete port — to be completed later.** Ported from the upstream Semi
/// Design `TagGroup` `tagList` entries (packages/semi-ui/tag/group.tsx +
/// interface.ts). Upstream `mode='custom'` is expressed here by the type of
/// the item itself — there is no `mode` parameter: the default constructor
/// builds a [SemiTag], [SemiTagGroupItem.custom] renders a raw child verbatim
/// (no size/avatarShape injection, no close forwarding, no key synthesis).
/// Cross-cutting gaps of the group (missing `showPopover`/`popoverProps`,
/// unported `SplitTagGroup`) are listed on [SemiTagGroup].
class SemiTagGroupItem {
  /// A standard tag item backed by a [SemiTag].
  ///
  /// Incomplete port: [size] and [avatarShape] are nullable so the group can
  /// inject its own values (`item ?? group ?? default`); every other field
  /// mirrors [SemiTag] with the same defaults. Closing forwards through
  /// [SemiTagGroup.onTagClose] — see [SemiTagGroup].
  const SemiTagGroupItem(
    String this.text, {
    this.size,
    this.type = SemiTagType.light,
    this.shape = SemiTagShape.square,
    this.color = SemiTagColor.grey,
    this.closable = false,
    this.visible,
    this.tagKey,
    this.onClose,
    this.onTap,
    this.prefixIcon,
    this.suffixIcon,
    this.avatar,
    this.avatarShape,
    this.colorful = false,
    this.gradient = false,
    this.semanticsLabel,
    this.closeSemanticsLabel,
    this.backgroundColor,
    this.textColor,
    this.borderColor,
    this.style,
  }) : child = null;

  /// A custom item (upstream `mode='custom'`): [child] is inserted into the
  /// group as-is.
  ///
  /// Incomplete port: custom items get no group injection and no close
  /// forwarding (the group never inspects [child]); the remaining fields are
  /// ignored and kept only so both modes share one class.
  const SemiTagGroupItem.custom(Widget this.child)
    : text = null,
      size = null,
      type = SemiTagType.light,
      shape = SemiTagShape.square,
      color = SemiTagColor.grey,
      closable = false,
      visible = null,
      tagKey = null,
      onClose = null,
      onTap = null,
      prefixIcon = null,
      suffixIcon = null,
      avatar = null,
      avatarShape = null,
      colorful = false,
      gradient = false,
      semanticsLabel = null,
      closeSemanticsLabel = null,
      backgroundColor = null,
      textColor = null,
      borderColor = null,
      style = null;

  /// The tag text; null for [SemiTagGroupItem.custom] items. Incomplete port:
  /// see [SemiTagGroupItem].
  final String? text;

  /// The verbatim child of a [SemiTagGroupItem.custom] item; null otherwise.
  /// Incomplete port: see [SemiTagGroupItem].
  final Widget? child;

  /// Per-item size; null inherits [SemiTagGroup.size], then
  /// [SemiTagSize.normal]. Incomplete port: see [SemiTagGroupItem].
  final SemiTagSize? size;

  /// Per-item avatar shape; null inherits [SemiTagGroup.avatarShape], then
  /// [SemiTagShape.square]. Incomplete port: see [SemiTagGroupItem].
  final SemiTagShape? avatarShape;

  /// Mirrors [SemiTag.type]. Incomplete port: see [SemiTagGroupItem].
  final SemiTagType type;

  /// Mirrors [SemiTag.shape]. Incomplete port: see [SemiTagGroupItem].
  final SemiTagShape shape;

  /// Mirrors [SemiTag.color]. Incomplete port: see [SemiTagGroupItem].
  final SemiTagColor color;

  /// Mirrors [SemiTag.closable]. Incomplete port: see [SemiTagGroupItem].
  final bool closable;

  /// Mirrors [SemiTag.colorful]. Incomplete port: see [SemiTagGroupItem].
  final bool colorful;

  /// Mirrors [SemiTag.gradient]. Incomplete port: see [SemiTagGroupItem].
  final bool gradient;

  /// Controlled visibility, forwarded to [SemiTag.visible]. Incomplete port:
  /// see [SemiTagGroupItem].
  final bool? visible;

  /// Explicit key: injected into the close event and, unlike the upstream
  /// `Math.random()` fallback (an incomplete-port difference), also used as
  /// the widget key. When null the close event falls back to [text] and no
  /// widget key is injected (so duplicate texts cannot collide).
  final Object? tagKey;

  /// Called first when this tag closes, before [SemiTagGroup.onTagClose];
  /// both receive the same [SemiTagCloseEvent]. Incomplete port: upstream
  /// forwards `(tagChildren, event, tagKey)` — see [SemiTagGroup].
  final ValueChanged<SemiTagCloseEvent>? onClose;

  /// Mirrors [SemiTag.onTap]. Incomplete port: see [SemiTagGroupItem].
  final VoidCallback? onTap;

  /// Mirrors [SemiTag.prefixIcon]. Incomplete port: see [SemiTagGroupItem].
  final Widget? prefixIcon;

  /// Mirrors [SemiTag.suffixIcon]. Incomplete port: see [SemiTagGroupItem].
  final Widget? suffixIcon;

  /// Mirrors [SemiTag.avatar]. Incomplete port: see [SemiTagGroupItem].
  final Widget? avatar;

  /// Mirrors [SemiTag.semanticsLabel]. Incomplete port: see [SemiTagGroupItem].
  final String? semanticsLabel;

  /// Mirrors [SemiTag.closeSemanticsLabel]. Incomplete port: see
  /// [SemiTagGroupItem].
  final String? closeSemanticsLabel;

  /// Mirrors [SemiTag.backgroundColor]. Incomplete port: see [SemiTagGroupItem].
  final Color? backgroundColor;

  /// Mirrors [SemiTag.textColor]. Incomplete port: see [SemiTagGroupItem].
  final Color? textColor;

  /// Mirrors [SemiTag.borderColor]. Incomplete port: see [SemiTagGroupItem].
  final Color? borderColor;

  /// Mirrors [SemiTag.style]. Incomplete port: see [SemiTagGroupItem].
  final TextStyle? style;
}

/// A source-faithful, non-Material tag group: lays out [SemiTagGroupItem]s in
/// a [Wrap] and folds the tail into a "+N" tag by count.
///
/// **Incomplete port — to be completed later.** Ported from the upstream Semi
/// Design `TagGroup` (packages/semi-ui/tag/group.tsx). Deliberately missing /
/// different:
///
/// * `showPopover` / `popoverProps` are **not implemented**: the "+N" tag does
///   not open a Popover listing the remaining tags. The Popover component is
///   not ported yet; these parameters will be added after it lands.
/// * `SplitTagGroup` (packages/semi-ui/tag/splitTagGroup.tsx) is not ported.
/// * The upstream fixed-height clipping of `.semi-tag-group-max` +
///   small/large (22/26px) is not reproduced; group height adapts to content.
/// * Upstream `mode='custom'` is expressed by [SemiTagGroupItem.custom] — the
///   item type is the mode; there is no `mode` parameter.
/// * Upstream synthesizes `Math.random()` keys for non-string children; here
///   widget keys are only injected when an item's `tagKey` is provided
///   explicitly ([ValueKey] of it), so duplicate texts cannot collide.
///
/// Truncation is **by count** ([maxTagCount]), never by measured width: when
/// horizontal space is tight the [Wrap] simply wraps to more rows. With
/// [maxTagCount] null every item renders. Otherwise `n` is computed like the
/// upstream truthiness expression: `n = (restCount != null && restCount != 0)
/// ? restCount : tagList.length - maxTagCount` — [restCount] `0` counts as
/// "not provided" — and `n > 0` renders the first [maxTagCount] items plus a
/// "+N" tag while `n <= 0` renders **all** items without folding (also
/// faithful to upstream). `maxTagCount == 0` leaves only "+N"; a negative
/// [maxTagCount] throws an [ArgumentError] at build time (upstream JS `slice`
/// has odd negative-bound semantics — not reproduced).
///
/// The "+N" tag is a closable-less grey [SemiTag] with transparent background
/// and widget key `ValueKey('_+n')`; hovering it fires [onPlusNMouseEnter].
/// Closing a standard item calls [SemiTagGroupItem.onClose] first and
/// [onTagClose] second with the same [SemiTagCloseEvent] — a `preventDefault`
/// in either cancels the uncontrolled hide (upstream calls both with the same
/// event and the Tag afterwards checks `defaultPrevented`; semantically
/// equivalent). Controlled items (`visible` non-null) are never auto-hidden.
///
/// Group spacing is consumed from [SemiTagTheme.resolve]:
/// `spacingTagGroupMarginRight` becomes the [Wrap] spacing and
/// `spacingTagGroupMarginBottom` its runSpacing (defaults 8/0; RTL adapts
/// automatically via the ambient direction).
class SemiTagGroup extends StatelessWidget {
  /// Creates a tag group. Incomplete port: `showPopover`/`popoverProps` do not
  /// exist yet (Popover not ported) and `SplitTagGroup` is unported — see the
  /// class doc.
  const SemiTagGroup({
    super.key,
    this.tagList = const <SemiTagGroupItem>[],
    this.maxTagCount,
    this.restCount,
    this.size,
    this.avatarShape,
    this.onTagClose,
    this.onPlusNMouseEnter,
  });

  /// The items to render, in order; custom items count towards the truncation
  /// like standard ones. Incomplete port: see [SemiTagGroup].
  final List<SemiTagGroupItem> tagList;

  /// Count-based truncation point (never width-based). Null renders all; 0
  /// leaves only the "+N" tag; negative throws [ArgumentError] at build time
  /// (an incomplete-port difference from upstream JS `slice`). See
  /// [SemiTagGroup].
  final int? maxTagCount;

  /// Overrides the "+N" count. The upstream truthiness quirk is reproduced:
  /// `0` (like null) falls back to `tagList.length - maxTagCount`.
  /// Incomplete port: see [SemiTagGroup].
  final int? restCount;

  /// Group-level size injected into items that do not set their own
  /// ([SemiTagGroupItem.size] ?? this ?? [SemiTagSize.normal]); also sizes the
  /// "+N" tag. Incomplete port: see [SemiTagGroup].
  final SemiTagSize? size;

  /// Group-level avatar shape injected like [size]
  /// ([SemiTagGroupItem.avatarShape] ?? this ?? [SemiTagShape.square]).
  /// Incomplete port: see [SemiTagGroup].
  final SemiTagShape? avatarShape;

  /// Called after the closing item's own [SemiTagGroupItem.onClose] with the
  /// same [SemiTagCloseEvent]; `preventDefault` in either cancels the
  /// uncontrolled hide. Incomplete port: upstream forwards
  /// `(tagChildren, event, tagKey)` while this port forwards the Flutter event.
  final ValueChanged<SemiTagCloseEvent>? onTagClose;

  /// Fires when the pointer enters the "+N" tag (upstream `onMouseEnter`).
  /// Incomplete port: upstream also supports showing the rest in a Popover on
  /// hover (`showPopover`); that is not implemented yet.
  final VoidCallback? onPlusNMouseEnter;

  @override
  Widget build(BuildContext context) {
    if (maxTagCount != null && maxTagCount! < 0) {
      throw ArgumentError.value(
        maxTagCount,
        'maxTagCount',
        'must be >= 0 (upstream JS slice negative-bound behavior is not '
            'reproduced)',
      );
    }
    final theme = SemiTagTheme.resolve(context);
    final items = <Widget>[];
    if (maxTagCount == null) {
      items.addAll(tagList.map(_buildItem));
    } else {
      final n = (restCount != null && restCount != 0)
          ? restCount!
          : tagList.length - maxTagCount!;
      if (n > 0) {
        items.addAll(tagList.take(maxTagCount!).map(_buildItem));
        items.add(_buildNTag(n));
      } else {
        items.addAll(tagList.map(_buildItem));
      }
    }
    return Wrap(
      spacing: theme.spacingTagGroupMarginRight!,
      runSpacing: theme.spacingTagGroupMarginBottom!,
      children: items,
    );
  }

  Widget _buildNTag(int n) => MouseRegion(
    onEnter: (_) => onPlusNMouseEnter?.call(),
    child: SemiTag(
      '+$n',
      key: const ValueKey('_+n'),
      closable: false,
      size: size ?? SemiTagSize.normal,
      color: SemiTagColor.grey,
      backgroundColor: const Color(0x00000000),
    ),
  );

  Widget _buildItem(SemiTagGroupItem item) {
    if (item.child != null) return item.child!;
    return SemiTag(
      item.text!,
      key: item.tagKey != null ? ValueKey<Object>(item.tagKey!) : null,
      size: item.size ?? size ?? SemiTagSize.normal,
      type: item.type,
      shape: item.shape,
      color: item.color,
      closable: item.closable,
      visible: item.visible,
      tagKey: item.tagKey ?? item.text,
      onClose: (event) {
        item.onClose?.call(event);
        onTagClose?.call(event);
      },
      onTap: item.onTap,
      prefixIcon: item.prefixIcon,
      suffixIcon: item.suffixIcon,
      avatar: item.avatar,
      avatarShape: item.avatarShape ?? avatarShape ?? SemiTagShape.square,
      colorful: item.colorful,
      gradient: item.gradient,
      semanticsLabel: item.semanticsLabel,
      closeSemanticsLabel: item.closeSemanticsLabel,
      backgroundColor: item.backgroundColor,
      textColor: item.textColor,
      borderColor: item.borderColor,
      style: item.style,
    );
  }
}
