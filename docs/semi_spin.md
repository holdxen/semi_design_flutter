# SemiSpin

A widgets-only loading indicator; no Material ancestor is required.

```dart
SemiSpin(size: SemiSpinSize.small, semanticsLabel: 'Loading');
SemiSpin(
  spinning: saving,
  delay: const Duration(milliseconds: 200),
  tip: const Text('Saving…'),
  child: editor,
);
SemiSpinTheme(
  data: const SemiSpinThemeData(
    smallSize: 16,
    childrenOpacity: 0.4,
    rotationDuration: Duration(milliseconds: 800),
  ),
  child: SemiSpin(indicator: const Text('↻')),
);
```

## Complete source mapping

All paths below are relative to upstream `packages/semi-foundation/spin/`.

| Field | Source | Declaration / default |
| --- | --- | --- |
| color | variables.scss | `$color-spin-bg: var(--semi-color-primary)`; live `theme.colors.colorPrimary` |
| smallSize | variables.scss | `$width-spin_small: 14px` |
| middleSize | variables.scss | `$width-spin_middle: 20px` |
| largeSize | variables.scss | `$width-spin_large: 32px` |
| childrenOpacity | variables.scss | `$opacity-spin_children: 0.5` |
| rotationDuration | animation.scss | `$animation_duration-spin_wrapper-spin: 600ms` |
| customIndicatorRotationDuration | animation.scss | `$animation_duration-spin_customChildren-spin: 1600ms` |

`SemiSpinThemeData` is an immutable nullable patch. `copyWith` retains fields for
null arguments; `merge` gives non-null fields from its argument precedence.
`resolve` produces non-null values against the current application theme.
Application overrides use `SemiThemeData.light(components:
SemiComponentThemes(spin: SemiSpinThemeData(...)))`. Local patches merge outer to
inner, including across application-theme boundaries, and support
`InheritedTheme.captureAll`, following Divider. Color is resolved live, not
snapshotted. Sizes must be finite and nonnegative, opacity must be in 0–1, and
durations must be nonnegative. `SemiSpin` retains a const constructor: delay
is validated at initialization and whenever its loading inputs change. Theme
values are validated on resolution. Invalid values throw `ArgumentError` in
release as well as debug (numeric constructor asserts additionally catch mistakes
early in debug).

## Lifecycle and interaction

`spinning` defaults to true, `delay` to zero, and size to middle. Only changes to
spinning or delay reschedule pending loading. Stopping hides immediately;
removing delay shows synchronously. Changing a positive delay after the indicator
is visible keeps it visible. Disposal cancels pending work.

Without a child, Spin always occupies its square, even while stopped or waiting.
The tip can paint outside that square and does not enlarge it. With a child, the
child determines layout and remains mounted while its opacity changes. Loading
adds a transparent pointer barrier above the entire child, including nested Spin
instances. Waiting does not block interaction. This barrier does **not** disable
keyboard focus or keyboard actions: applications needing that behavior must
manage it separately. Child semantics are retained. An optional loading label is
announced as a live region only while loading. Avoid duplicating that label in a
text tip if a single announcement is required.

The default SVG is extracted from `packages/semi-ui/spin/icon.tsx`, preserving the
36-unit path and three currentColor gradient stops; it is not the icon catalog's
spin asset. SVG decoding uses `SemiIcon.svg`. Only the indicator rotates, linearly;
custom indicators use the longer period. TickerMode, reduced motion, zero duration
and stopped loading suspend rotation. Infinite animations mean tests must use
bounded `pump` calls, not `pumpAndSettle`.

Unbounded layouts still require children that can naturally determine a finite
size; an expanding child in an unbounded parent cannot be made finite by Spin.
No extra scaling or direction assumptions are imposed on text/custom indicators.
