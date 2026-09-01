# NemoButton

## Purpose

`NemoButton` provides Nemo's tactile action control. Use it for an operation the
user can invoke now. It owns the interactive surface, focus, pointer and
keyboard behavior, and button semantics. Do not use it as a general-purpose
container, visual-variant API, or non-interactive grouping surface; use
`NemoSurface` for grouping.

## Anatomy

A button consists of a shared-surface body, paired top-left highlight and
bottom-right lowlight relief when raised, an inset edge treatment while
pressed, caller-provided content, an optional system-owned loading affordance,
a tokenized outline, and a visible focus ring. The semantic button wraps the
whole target and merges caller text when no explicit label is supplied.

## API and examples

```dart
import 'package:nemo_ui/nemo_ui.dart';

NemoButton(
  onPressed: saveProfile,
  isLoading: isSaving,
  semanticLabel: 'Save profile',
  child: const Text('Save'),
)
```

The public constructor exposes only `child`, `onPressed`, `isLoading`,
`semanticLabel`, `autofocus`, and `focusNode`. The caller owns visible
non-loading content. Nemo owns colors, spacing, shape, relief, focus width,
and motion through tokens.

## Variants and states

There is no caller-selected visual variant. Every enabled button uses a neutral
Nemo surface body with a restrained primary tint and primary content color, so
primary is an accent rather than a filled Material-like silhouette. Resting,
hovered, and focused states are raised from the shared canvas. Hover subtly
adjusts tone and relief; focus also adds the explicit focus ring. Pressed
replaces outer relief with paired clipped inset shadows and a small tonal
change. Disabled and loading states use the surface variant plus an explicit
boundary/content cue and are non-interactive. Loading replaces the caller's
content with localized progress copy and an indicator.

## Tokens

`NemoButton` consumes:

- `foundation.radiusMedium`, `foundation.shadowBlur`, and
  `foundation.shadowOffset` for shared geometry;
- `semantic.surface`, `surfaceVariant`, `foreground`, `mutedForeground`,
  `primary`, `outline`, `focusRing`, `highlightShadow`, and `lowlightShadow`;
- `components.controlMinHeight`, `controlHorizontalPadding`, `outlineWidth`,
  `focusRingWidth`, and all `components.button` state and progress tokens; and
- `motion.quick` and `motion.standardCurve` for tactile state changes.

`NemoButtonStateStyle` owns paint-only tonal, accent, outer-shadow,
inset-shadow, and outline values. High-contrast tokens suppress decorative
shadows while retaining an explicit boundary and focus signal.

## Content and localization

Caller content remains caller-owned in every non-loading state. Without
`semanticLabel`, merged caller text becomes the accessible name; with one, the
visible child is excluded from duplicate semantics. Loading content and its
accessible live announcement use `NemoLocalizations.loading`; callers cannot
override that system-owned copy. Layout is directionality-safe and lighting
remains top-left in both LTR and RTL.

## Accessibility

The root exposes button semantics, enabled state, and a semantic tap action
only when enabled. Enter and Space activate a focused enabled button. Loading
and disabled states block repeat activation. Focus uses the tokenized ring
outside the normal boundary, so it is identifiable without depth or color
alone. The tokenized minimum height is 48 logical pixels; caller content wraps
under text scaling. Primary content and the loading progress indicator are
contrast-checked against each rendered enabled/loading body; muted disabled
content is contrast-checked against its disabled body.

## Motion

Pointer, hover, focus, and keyboard transitions animate through `motion.quick`
and `motion.standardCurve`; they never change layout constraints, padding, or
surrounding layout. When `MediaQuery.disableAnimations` is true, motion
resolves to zero duration and loading uses a static hourglass rather than an
infinite spinner.

## Responsive behavior

The control preserves its 48px minimum target at narrow widths and wraps
caller content rather than clipping it. Hover feedback is mouse-only; touch,
mouse, and keyboard activation use the same semantic target. The component
has no density parameter and relies on host typography, locale, and available
width.

## Preview

Open **Components / Button states** in
`example/previews/foundation_previews.dart`. The example catalog's
**NemoButton** route demonstrates active, disabled, loading, locale,
text-scale, theme, and reduced-motion scenarios.

## Test matrix

Widget tests cover touch, Enter, Space, semantics, explicit and caller-derived
labels, disabled/loading activation blocking, localization, RTL, focus, mouse
cursor, 48px target, text scaling, and reduced motion. Theme tests cover
state-token copying/interpolation, explicit pressed inset relief,
high-contrast shadow suppression, and content/progress/disabled contrast for
every rendered state in light, dark, and high-contrast themes. The deterministic
button golden is 960×640 physical pixels and includes normal, hovered,
pressed/inset, loading, focused dark, and disabled high-contrast evidence.
It pins Android, DPR 1, English, no text scaling, a fixed animation preference,
and the Ahem font; its content is glyph-free. Intentional baseline updates
require tracked PNG review and before/after pull-request evidence.

## Decisions and known constraints

Button emphasis remains token-owned: adding a public variant seam would expand
the widget API without multiple demonstrated call sites. The painter keeps a
local clipped-inner-shadow helper instead of introducing a speculative shared
rendering abstraction. Blurred shadow output is retained in the golden because
this scene is deterministic under the pinned test environment; the project
still requires visual review for any intentional baseline update.
