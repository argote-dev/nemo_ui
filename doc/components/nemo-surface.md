# NemoSurface

## Purpose

`NemoSurface` is Nemo's non-interactive visual primitive for grouping content
with a token-driven neumorphic relief. Use it for panels, local regions, and
component internals. Do not use it as a button, card action, focus target, or
semantic region; compose those responsibilities separately.

## Anatomy

A Surface paints a semantic base tone, a tonal adjustment, a thin outline, and
either paired outer shadows or paired true inset shadows. The child is painted
last. Light is always from the top-left and is never mirrored for RTL.

## API and examples

```dart
NemoSurface(
  depth: NemoSurfaceDepth.raised,
  tone: NemoSurfaceTone.surfaceVariant,
  shape: NemoSurfaceShape.roundedLarge,
  padding: const EdgeInsetsDirectional.all(16),
  child: const Text('Content'),
)
```

The constructor deliberately exposes only `child`, `depth`, `tone`, `shape`,
`padding`, and `clipBehavior`. Colors, radii, shadows, outline values, and
motion remain owned by the current `NemoThemeData`.

Defaults are `raised`, `surface`, `roundedMedium`, `Clip.none`, and a `space16`
padding resolved from the active theme. `padding: EdgeInsets.zero` is supported
for tightly composed visuals.

## Variants and states

`NemoSurfaceDepth` has five values: `deeplySunken`, `sunken`, `flat`, `raised`,
and `elevated`. Depth is local to the immediate visual background; nesting does
not propagate a hidden absolute elevation context. `NemoSurfaceTone` selects
`surface` or `surfaceVariant`. `NemoSurfaceShape` maps to the small, medium, or
large foundation radius.

Surface has no hover, pressed, disabled, selected, or focused state.

## Tokens

Surface consumes `NemoComponentTokens.surface`, which provides explicit styles
for all five depths. Standard treatments are ordered in both light and dark
modes: `deeplySunken` has the strongest lowlight overlay and inset occlusion;
`sunken` is a quieter inset; `flat` is nearly unmodified with a soft local
boundary; `raised` adds a restrained highlight and paired outer shadows; and
`elevated` has the strongest raised overlay, blur, offset, and shadow. The
light direction and geometry remain top-left / bottom-right in both themes;
dark mode changes semantic colors, not that geometry. Standard `sunken` and
`raised` outlines are deliberately restrained so relief, rather than a card
border, carries their reading.

Each style independently controls blur, offset, tonal contrast, outline, and
shadow opacity, in addition to the foundation spacing/radii/shadow metrics and
semantic surface, outline, highlight, and lowlight colors. A custom
`NemoComponentTokens` must supply `NemoSurfaceTokens`.

## Content and localization

All content is caller-owned. Surface adds no copy and is direction-neutral:
`EdgeInsetsDirectional` can be supplied for directional padding, while the
physical lighting remains top-left in both LTR and RTL.

## Accessibility

Surface adds no `Semantics` node, action, focus target, or gesture handling.
Descendants retain their own hit testing and semantics. Relief is decorative and
must never be the only signal of state or meaning. `Clip.none` is the default
to avoid clipping large text; enable clipping explicitly for visual content such
as images.

## Motion

Depth, tone, and shape interpolate using `motion.standard` and
`standardCurve`. A transition between inset and raised values crosses through a
flat visual state because its signed relief interpolates through zero. Reduced
motion resolves this duration to zero. Padding and layout are never animated.

## Responsive behavior

Surface owns no margin, alignment, size, or constraints. Outer raised shadows
can extend beyond its bounds without affecting layout; a parent that clips will
cut them. A fully opaque child with zero padding can conceal inset shadows near
its edges.

## Preview

Run the example app for the interactive Surface catalog, or open the native
Widget Previewer scenario **Components / Surface depths** in
`example/previews/foundation_previews.dart`.

## Test matrix

Widget tests cover defaults, clipping, theme absence, semantics/hit-test
transparency, reduced motion, light/dark token ordering, post-overlay text
contrast, and shadow-free high-contrast boundaries. The deterministic Surface
golden composes a flat local plane with deeply sunken, sunken, raised, and
elevated children in light, dark, and high-contrast content-bearing scenes:
a persistent well, receiving field, grouped panel, and prominent action area.
The golden suppresses blurred shadows because they vary between Skia hosts;
token tests cover their ordered values, while the golden retains deterministic
tone, outline, depth category, shape, and content composition. High contrast
is shadow-free in both the token and golden contracts. It uses the shared
pinned golden harness; intentional baseline changes require tracked image
review and before-and-after pull-request evidence.

## Decisions and known constraints

Inset shadows use custom canvas painting underneath the child because Flutter
has no built-in inner-shadow decoration. High contrast intentionally reduces
five depths to `sunken`, `flat`, and `raised` visual categories. It suppresses
shadows while retaining distinct, explicit tone and outline treatments for each
category.
