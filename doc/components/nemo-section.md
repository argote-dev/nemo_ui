# NemoSection

## Purpose

`NemoSection` makes page hierarchy explicit with a required heading, optional
description, and content slot. Use it for semantic grouping; do not use it as a
card, material plane, or interaction surface.

## Anatomy

- A semantic container with explicit child nodes.
- A required caller-owned heading exposed as a semantic header.
- Optional supporting description.
- Caller-owned content below the heading and description.

## API and examples

```dart
NemoSection(
  heading: Text('Notifications', style: Theme.of(context).textTheme.titleLarge),
  description: const Text('Choose how you receive updates.'),
  child: NotificationControls(),
)
```

## Variants and states

The description is optional. There are no visual, material, interaction,
selected, error, loading, or disabled variants; supplied children own state.

## Tokens

`NemoSection` consumes foundation `space8` between heading and description and
`space16` before content. Its description merges `semantic.mutedForeground`.
It consumes no component tokens, material recipes, radius, shadow, or motion
tokens.

## Content and localization

Heading, description, and content are all caller-owned, including localized
copy and fallbacks. Start alignment follows `Directionality`, while physical
illumination is not applicable because this widget paints no material.

## Accessibility

The heading is marked as a semantic header without merging description/content
semantics. The section preserves child focus order and keyboard behavior.
Contrast, focus indicators, target size, and localized labels are owned by
children. Natural-height layout permits enlarged text to wrap; place long
sections in caller-owned scrolling content.

## Motion

Not applicable: sections have no transition. Reduced motion does not alter
section layout; child components apply their own motion contract.

## Responsive behavior

The column uses directional start alignment and intrinsic height. It reflows at
narrow widths and supports touch, keyboard, and assistive-technology content
without a separate desktop treatment.

## Preview

Use **Composition / Page and section** in
`example/previews/foundation_previews.dart`. The catalog settings composition
uses `NemoSection` in `CatalogHomePage`; the dashboard composition uses it in
`ComposedCatalogPage`.

## Test matrix

`test/components/nemo_section_test.dart` covers header semantics, description
and content order, child keyboard focus traversal, narrow enlarged text, and
light/dark/high-contrast/reduced-motion hosts. The native preview and example
catalog exercise representative composition. Not applicable: this layout-only
component has no standalone golden; its glyph-free section geometry is covered
by the deterministic page dashboard/settings scenes (800×600, Android, DPR 1,
English, Ahem, no text scaling, disabled animations) in
`nemo_page_golden_test.dart`. Baseline updates require canonical Ubuntu PNG
review and before/after PR evidence.

## Decisions and known constraints

`NemoSection` intentionally does not add a `NemoSurface`, padding around whole
sections, or typography API. The caller controls between-section spacing and
any meaningful one-material jump under Theme Contract v2.
