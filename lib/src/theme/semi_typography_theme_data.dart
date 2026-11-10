import 'package:flutter/widgets.dart';

import 'semi_theme_data.dart';

/// Nullable overrides; null keeps inheritance and live global token defaults.
@immutable
class SemiTypographyThemeData {
  const SemiTypographyThemeData({
    this.defaultTextColor,
    this.secondaryTextColor,
    this.tertiaryTextColor,
    this.quaternaryTextColor,
    this.warningTextColor,
    this.dangerTextColor,
    this.successTextColor,
    this.disabledTextColor,
    this.markBackgroundColor,
    this.codeBackgroundColor,
    this.codeTextColor,
    this.linkTextColor,
    this.linkVisitedColor,
    this.linkHoverColor,
    this.linkActiveColor,
    this.linkDisabledColor,
    this.copiedTextColor,
    this.copiedIconColor,
    this.codeBorderColor,
  });

  /// `$color-typography_default-text-default` defaults to `var(--semi-color-text-0)`.
  /// Source: `packages/semi-foundation/typography/variables.scss`.
  final Color? defaultTextColor;

  /// `$color-typography_secondary-text-default` defaults to `var(--semi-color-text-1)`.
  /// Source: `packages/semi-foundation/typography/variables.scss`.
  final Color? secondaryTextColor;

  /// `$color-typography_tertiary-text-default` defaults to `var(--semi-color-text-2)`.
  /// Source: `packages/semi-foundation/typography/variables.scss`.
  final Color? tertiaryTextColor;

  /// `$color-typography_quaternary-text-default` defaults to `var(--semi-color-text-3)`.
  /// Source: `packages/semi-foundation/typography/variables.scss`.
  final Color? quaternaryTextColor;

  /// `$color-typography_warning-text-default` defaults to `var(--semi-color-warning)`.
  /// Source: `packages/semi-foundation/typography/variables.scss`.
  final Color? warningTextColor;

  /// `$color-typography_danger-text-default` defaults to `var(--semi-color-danger)`.
  /// Source: `packages/semi-foundation/typography/variables.scss`.
  final Color? dangerTextColor;

  /// `$color-typography_success-text-default` defaults to `var(--semi-color-success)`.
  /// Source: `packages/semi-foundation/typography/variables.scss`.
  final Color? successTextColor;

  /// `$color-typography_disabled-text-default` defaults to `var(--semi-color-disabled-text)`.
  /// Source: `packages/semi-foundation/typography/variables.scss`.
  final Color? disabledTextColor;

  /// `$color-typography_mark-bg-default` defaults to `var(--semi-color-primary-light-default)`.
  /// Source: `packages/semi-foundation/typography/variables.scss`.
  final Color? markBackgroundColor;

  /// `$color-typography_code-bg-default` defaults to `var(--semi-color-fill-1)`.
  /// Source: `packages/semi-foundation/typography/variables.scss`.
  final Color? codeBackgroundColor;

  /// `$color-typography_code-text-default` defaults to `var(--semi-color-text-2)`.
  /// Source: `packages/semi-foundation/typography/variables.scss`.
  final Color? codeTextColor;

  /// `$color-typography_link-text-default` defaults to `var(--semi-color-link)`.
  /// Source: `packages/semi-foundation/typography/variables.scss`.
  final Color? linkTextColor;

  /// `$color-typography_link-text-visited` defaults to `var(--semi-color-link-visited)`.
  /// Source: `packages/semi-foundation/typography/variables.scss`.
  final Color? linkVisitedColor;

  /// `$color-typography_link-text-hover` defaults to `var(--semi-color-link-hover)`.
  /// Source: `packages/semi-foundation/typography/variables.scss`.
  final Color? linkHoverColor;

  /// `$color-typography_link-text-active` defaults to `var(--semi-color-link-active)`.
  /// Source: `packages/semi-foundation/typography/variables.scss`.
  final Color? linkActiveColor;

  /// `$color-typography_link-text-disabled` defaults to `var(--semi-color-link)`.
  /// Source: `packages/semi-foundation/typography/variables.scss`.
  final Color? linkDisabledColor;

  /// `$color-typography_copied-text-success` defaults to `var(--semi-color-text-2)`.
  /// Source: `packages/semi-foundation/typography/variables.scss`.
  final Color? copiedTextColor;

  /// `$color-typography_copied-icon-success` defaults to `var(--semi-color-success)`.
  /// Source: `packages/semi-foundation/typography/variables.scss`.
  final Color? copiedIconColor;

  /// `$color-typography_code-border-default` defaults to `var(--semi-color-border)`.
  /// Source: `packages/semi-foundation/typography/variables.scss`.
  final Color? codeBorderColor;

  /// Null arguments preserve overrides. Use a new configuration to reset.
  SemiTypographyThemeData copyWith({
    Color? defaultTextColor,
    Color? secondaryTextColor,
    Color? tertiaryTextColor,
    Color? quaternaryTextColor,
    Color? warningTextColor,
    Color? dangerTextColor,
    Color? successTextColor,
    Color? disabledTextColor,
    Color? markBackgroundColor,
    Color? codeBackgroundColor,
    Color? codeTextColor,
    Color? linkTextColor,
    Color? linkVisitedColor,
    Color? linkHoverColor,
    Color? linkActiveColor,
    Color? linkDisabledColor,
    Color? copiedTextColor,
    Color? copiedIconColor,
    Color? codeBorderColor,
  }) => SemiTypographyThemeData(
    defaultTextColor: defaultTextColor ?? this.defaultTextColor,
    secondaryTextColor: secondaryTextColor ?? this.secondaryTextColor,
    tertiaryTextColor: tertiaryTextColor ?? this.tertiaryTextColor,
    quaternaryTextColor: quaternaryTextColor ?? this.quaternaryTextColor,
    warningTextColor: warningTextColor ?? this.warningTextColor,
    dangerTextColor: dangerTextColor ?? this.dangerTextColor,
    successTextColor: successTextColor ?? this.successTextColor,
    disabledTextColor: disabledTextColor ?? this.disabledTextColor,
    markBackgroundColor: markBackgroundColor ?? this.markBackgroundColor,
    codeBackgroundColor: codeBackgroundColor ?? this.codeBackgroundColor,
    codeTextColor: codeTextColor ?? this.codeTextColor,
    linkTextColor: linkTextColor ?? this.linkTextColor,
    linkVisitedColor: linkVisitedColor ?? this.linkVisitedColor,
    linkHoverColor: linkHoverColor ?? this.linkHoverColor,
    linkActiveColor: linkActiveColor ?? this.linkActiveColor,
    linkDisabledColor: linkDisabledColor ?? this.linkDisabledColor,
    copiedTextColor: copiedTextColor ?? this.copiedTextColor,
    copiedIconColor: copiedIconColor ?? this.copiedIconColor,
    codeBorderColor: codeBorderColor ?? this.codeBorderColor,
  );

  /// Applies only non-null fields from [patch].
  SemiTypographyThemeData merge(SemiTypographyThemeData patch) => copyWith(
    defaultTextColor: patch.defaultTextColor,
    secondaryTextColor: patch.secondaryTextColor,
    tertiaryTextColor: patch.tertiaryTextColor,
    quaternaryTextColor: patch.quaternaryTextColor,
    warningTextColor: patch.warningTextColor,
    dangerTextColor: patch.dangerTextColor,
    successTextColor: patch.successTextColor,
    disabledTextColor: patch.disabledTextColor,
    markBackgroundColor: patch.markBackgroundColor,
    codeBackgroundColor: patch.codeBackgroundColor,
    codeTextColor: patch.codeTextColor,
    linkTextColor: patch.linkTextColor,
    linkVisitedColor: patch.linkVisitedColor,
    linkHoverColor: patch.linkHoverColor,
    linkActiveColor: patch.linkActiveColor,
    linkDisabledColor: patch.linkDisabledColor,
    copiedTextColor: patch.copiedTextColor,
    copiedIconColor: patch.copiedIconColor,
    codeBorderColor: patch.codeBorderColor,
  );
  SemiResolvedTypographyThemeData resolve(SemiThemeData theme) {
    final c = theme.colors;
    return SemiResolvedTypographyThemeData(
      defaultTextColor: defaultTextColor ?? c.colorText0,
      secondaryTextColor: secondaryTextColor ?? c.colorText1,
      tertiaryTextColor: tertiaryTextColor ?? c.colorText2,
      quaternaryTextColor: quaternaryTextColor ?? c.colorText3,
      warningTextColor: warningTextColor ?? c.colorWarning,
      dangerTextColor: dangerTextColor ?? c.colorDanger,
      successTextColor: successTextColor ?? c.colorSuccess,
      disabledTextColor: disabledTextColor ?? c.colorDisabledText,
      markBackgroundColor: markBackgroundColor ?? c.colorPrimaryLightDefault,
      codeBackgroundColor: codeBackgroundColor ?? c.colorFill1,
      codeTextColor: codeTextColor ?? c.colorText2,
      linkTextColor: linkTextColor ?? c.colorLink,
      linkVisitedColor: linkVisitedColor ?? c.colorLinkVisited,
      linkHoverColor: linkHoverColor ?? c.colorLinkHover,
      linkActiveColor: linkActiveColor ?? c.colorLinkActive,
      linkDisabledColor: linkDisabledColor ?? c.colorLink,
      copiedTextColor: copiedTextColor ?? c.colorText2,
      copiedIconColor: copiedIconColor ?? c.colorSuccess,
      codeBorderColor: codeBorderColor ?? c.colorBorder,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SemiTypographyThemeData &&
          defaultTextColor == other.defaultTextColor &&
          secondaryTextColor == other.secondaryTextColor &&
          tertiaryTextColor == other.tertiaryTextColor &&
          quaternaryTextColor == other.quaternaryTextColor &&
          warningTextColor == other.warningTextColor &&
          dangerTextColor == other.dangerTextColor &&
          successTextColor == other.successTextColor &&
          disabledTextColor == other.disabledTextColor &&
          markBackgroundColor == other.markBackgroundColor &&
          codeBackgroundColor == other.codeBackgroundColor &&
          codeTextColor == other.codeTextColor &&
          linkTextColor == other.linkTextColor &&
          linkVisitedColor == other.linkVisitedColor &&
          linkHoverColor == other.linkHoverColor &&
          linkActiveColor == other.linkActiveColor &&
          linkDisabledColor == other.linkDisabledColor &&
          copiedTextColor == other.copiedTextColor &&
          copiedIconColor == other.copiedIconColor &&
          codeBorderColor == other.codeBorderColor;
  @override
  int get hashCode => Object.hashAll([
    defaultTextColor,
    secondaryTextColor,
    tertiaryTextColor,
    quaternaryTextColor,
    warningTextColor,
    dangerTextColor,
    successTextColor,
    disabledTextColor,
    markBackgroundColor,
    codeBackgroundColor,
    codeTextColor,
    linkTextColor,
    linkVisitedColor,
    linkHoverColor,
    linkActiveColor,
    linkDisabledColor,
    copiedTextColor,
    copiedIconColor,
    codeBorderColor,
  ]);
}

/// Complete colors resolved against the current global tokens.
@immutable
class SemiResolvedTypographyThemeData {
  const SemiResolvedTypographyThemeData({
    required this.defaultTextColor,
    required this.secondaryTextColor,
    required this.tertiaryTextColor,
    required this.quaternaryTextColor,
    required this.warningTextColor,
    required this.dangerTextColor,
    required this.successTextColor,
    required this.disabledTextColor,
    required this.markBackgroundColor,
    required this.codeBackgroundColor,
    required this.codeTextColor,
    required this.linkTextColor,
    required this.linkVisitedColor,
    required this.linkHoverColor,
    required this.linkActiveColor,
    required this.linkDisabledColor,
    required this.copiedTextColor,
    required this.copiedIconColor,
    required this.codeBorderColor,
  });
  final Color defaultTextColor;
  final Color secondaryTextColor;
  final Color tertiaryTextColor;
  final Color quaternaryTextColor;
  final Color warningTextColor;
  final Color dangerTextColor;
  final Color successTextColor;
  final Color disabledTextColor;
  final Color markBackgroundColor;
  final Color codeBackgroundColor;
  final Color codeTextColor;
  final Color linkTextColor;
  final Color linkVisitedColor;
  final Color linkHoverColor;
  final Color linkActiveColor;
  final Color linkDisabledColor;
  final Color copiedTextColor;
  final Color copiedIconColor;
  final Color codeBorderColor;
}
