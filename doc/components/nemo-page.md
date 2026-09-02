# NemoPage

## Purpose

`NemoPage` supplies the Nemo-owned base canvas for a screen: its safe-area-aware
content region and optional persistent `NemoTopBar` make independently composed
screens read as one tactile system. Do not use it for transient panels, routes,
or as a replacement for the host navigation model.

## Anatomy

- A `semantic.surface` `Scaffold` base canvas.
- Optional `NemoTopBar` persistent chrome in `Scaffold.appBar`.
- A `SafeArea`, centered responsive content region, and directional content
  padding around the caller-owned child slot.

## API and examples

```dart
NemoPage(
  topBar: const NemoTopBar(title: Text('Settings')),
  child: ListView(
    children: const <Widget>[AccountSettings()],
  ),
)
```

`child` is a caller-owned slot and may be a `ListView`, `CustomScrollView`, or
static layout. `padding` overrides the default; `maxContentWidth` defaults to
`1200` and must be finite and greater than zero. Routes, typography, navigation
state, and interaction callbacks are host-owned.

## Variants and states

The page has one base-canvas treatment. `topBar` is optional. There are no
hovered, pressed, selected, disabled, loading, error, elevation, or material
variants; child widgets own their states.

## Tokens

`NemoPage` consumes `semantic.surface` and foundation `space24` for its default
`EdgeInsetsDirectional.all` content inset. It consumes no component token and
creates no `NemoMaterial` transition.

## Content and localization

Nemo owns no copy. The top-bar title and child content are supplied by the host,
which owns localization and fallback copy. Default padding and alignment use
directional geometry, so content mirrors in RTL; physical material illumination
continues to be owned by material components and does not mirror.

## Accessibility

The page preserves supplied child semantics and focus order. With a top bar,
that bar consumes the top intrusion once; without one, `NemoPage` protects it.
Left, right, and bottom intrusions are always protected. Focus, keyboard
handling, contrast, target sizes, and text scaling belong to supplied widgets;
the centered region reflows rather than clipping.

## Motion

Not applicable: the persistent canvas has no transition or motion token.
Reduced-motion behavior is therefore unchanged; child components resolve their
own motion policy.

## Responsive behavior

The child is constrained to `maxContentWidth` and centered on wide screens.
Narrow widths reduce the available content width after directional insets;
there is no desktop-only visual grammar. Scrolling and input modality remain
caller-owned.

## Preview

Use the native Flutter Widget Previewer **Composition / Page and section**
scenario in `example/previews/foundation_previews.dart`. The example catalog
routes are **Nemo component catalog** (settings composition) and **Composed
workspace** (dashboard composition) in `example/lib/src/pages/`.

## Test matrix

Widget coverage in `test/components/nemo_page_test.dart` checks missing-theme
diagnostics, `semantic.surface`, top-safe inset handling with and without
`NemoTopBar`, LTR/RTL directional padding, finite width validation, narrow/wide
reflow, enlarged text, light/dark/high-contrast themes, reduced motion, and a
nested public `NemoSurface`. Example coverage is in
`example/test/foundation_catalog_test.dart`.

Canonical dashboard/settings goldens live in
`test/components/nemo_page_golden_test.dart`: 800×600 physical pixels,
Android, DPR 1, English, Ahem, no text scaling, and disabled animations across
light, dark, and high contrast. Scenes are glyph-free. Baselines are generated
and reviewed on canonical Ubuntu CI, never manufactured on macOS; intentional
PNG updates require tracked image review and before/after PR evidence.

## Decisions and known constraints

`NemoPage` deliberately uses invisible `Scaffold` infrastructure but defines no
new Material pixels. It does not own a font, routes, transitions, drawers, or
navigation rails. Canonical baselines are generated on the Ubuntu 24.04 x64
Flutter 3.47.0 target.
