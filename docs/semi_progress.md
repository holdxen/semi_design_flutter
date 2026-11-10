# SemiProgress

Material-free line and circle progress, exported from `package:semi_design_flutter/semi_design_flutter.dart`.

## API

| Property | Default | Contract |
|---|---|---|
| `type` | `SemiProgressType.line` | `line`, `circle` |
| `direction` | `SemiProgressDirection.horizontal` | `horizontal`, `vertical`; circle ignores direction |
| `size` | `SemiProgressSize.normal` | `normal`, `small`, `large` |
| `percent` | `0` | Finite double; geometry and displayed info clamp to 0–100, colors use raw percent |
| `showInfo` | `false` | Circle small and indeterminate always hide info |
| `format` | null | `Widget Function(double)`; receives displayed clamped number |
| `motion` | `true` | Only numeric text animation, 300 ms linear, starts at previous prop |
| `indeterminate` | `false` | Hides information and semantics value |
| `stroke` | null | `SemiProgressStroke.color(Color)` or `.stops(List<SemiProgressColorStop>)` |
| `strokeGradient` | `false` | Interpolate between thresholds instead of selecting previous threshold |
| `orbitStroke` | null | Track color override |
| `strokeWidth` | `4` | Circle only; line thickness is theme-driven |
| `strokeLinecap` | `round` | `SemiProgressStrokeLinecap.round` / `.square`; SVG square maps to Flutter square, not butt |
| `width` | null | Circle normal 72, others 24; explicit line width supported |
| `height` | null | Explicit line height; vertical otherwise requires finite height constraint |
| `textStyle` | null | Merged over inherited/default info style |
| `semanticsLabel`, `semanticsValue` | null | Accessible label/value override; default visual info excluded to avoid duplicate speech |

Horizontal line requires finite width or explicit width. Vertical line requires finite height or explicit height. No screen-size guessing occurs. All numeric sizes must be finite and nonnegative. NaN/infinite percent or threshold values are runtime errors, including release builds. Const widget/theme constructors remain available; widget input validation occurs during mounting/updating and theme validation during resolution.

## Nineteen Sass mappings

Sources are `packages/semi-foundation/progress/variables.scss`. These overrides are independent of the 383 global CSS tokens.

| Sass variable (prefix `$`) | Theme field | Default/reference |
|---|---|---|
| color-progress_default-bg | color | global colorFill0 |
| color-progress_track_inner-bg | strokeColor | global colorSuccess |
| color-progress_line_text-text | lineTextColor | global colorText0 |
| color-progress_circle-text | circleTextColor | upstream mode-minor-text; host text color then global text0 fallback |
| motion-progress-transition_duration | transitionDuration | 300ms |
| motion-progress-transition_timing_function | transitionCurve | Cubic(.62,.05,.36,.95) |
| height-progress_horizontal | horizontalHeight | 4 |
| height-progress_horizontal_large | horizontalLargeHeight | 6 |
| spacing-progress_line_text-marginLeft | lineTextMarginLeft | spacing-base = 16 |
| spacing-progress_line_text-marginRight | lineTextMarginRight | spacing-base = 16 |
| spacing-progress_vertical-marginX | verticalMarginX | spacing-extra-tight = 4 |
| spacing-progress_horizontal-marginY | horizontalMarginY | spacing-extra-tight = 4 |
| spacing-progress_vertical_line_text-marginTop | verticalTextMarginTop | spacing-tight = 8 |
| font-progress_line_text-fontWeight | lineTextFontWeight | 600 |
| width-progress_line_text | lineTextMinWidth | 45 |
| width-progress_vertical | verticalWidth | 4 |
| width-progress_vertical_large | verticalLargeWidth | 6 |
| radius-progress_track | trackRadius | global borderRadiusSmall |
| radius-progress_track_inner | innerRadius | global borderRadiusSmall |

`SemiProgressThemeData` is an immutable nullable patch with `copyWith`, `merge`, equality/hash and non-null `resolve`. Application patches use `SemiThemeData.components.progress`. Local patches compose outer-to-inner, including across global theme boundaries, and keep global references live. Progress snapshots all effective local patches for inherited-theme capture, excluding application-level component overrides and resolved defaults. Ancestor changes update the snapshot before capture. Wrapping a captured Progress theme under a new global theme therefore preserves both local patches and resolves remaining references against the destination global theme. The captured snapshot itself is intentionally fixed at capture time. There is no circle font Sass token: font size/weight inherit the host. The upstream circle color variable is missing from the global token set; source comments document the fallback.

```dart
SemiProgressTheme(
  data: const SemiProgressThemeData(horizontalHeight: 8),
  child: SemiProgress(
    width: 240,
    percent: 65,
    showInfo: true,
    strokeGradient: true,
    stroke: SemiProgressStroke.stops(const [
      SemiProgressColorStop(0, Color(0x80ff0000)),
      SemiProgressColorStop(100, Color(0xff00ff00)),
    ]),
  ),
)
```

## Thresholds and upstream differences

Threshold input is copied, sorted and made unmodifiable without mutating the caller. Below the first threshold uses success; above the last uses the last color; exact hits select their color. Duplicate thresholds select the last sorted duplicate. Empty stops use success. Gradient interpolation uses `Color.lerp`, preserving alpha; this deliberately does not reproduce upstream CSS string parsing and alpha bugs. There is no string color parser and no spatial gradient shader.

Geometry transitions independently of `motion`, using the theme duration/curve. Interrupted geometry starts at its current rendered fraction; interrupted numeric motion follows upstream's old-prop starting point. Disabling numeric motion cancels old numeric work immediately. Reduced animations and disabled TickerMode stop controllers and show static geometry; zero geometry duration jumps to the target without disabling numeric animation.

Indeterminate lines use a 35% slider, 1.6-second cycle and ease-in-out interpolation reaching the endpoint at 55%, then holding. Circle uses a 30% arc rotating clockwise in 1.2 seconds from three o'clock. Determinate circles begin at twelve o'clock. Horizontal lines mirror in RTL; vertical lines always fill top to bottom. Zero progress paints no foreground cap and 100% circles paint a closed ring.

Regenerate the nineteen-field theme with `python3 tool/generate_progress.py`; verify with `python3 -m unittest discover -s tool -p 'test_*.py'` and `flutter test`.
