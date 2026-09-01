# Nemo theme evolution research

**Date:** 2026-08-31  
**Scope:** A read-only audit and improvement strategy for Nemo UI’s theme and
visual language. The aim is to make Nemo recognizably its own system rather
than a softly re-skinned Material catalog, while making its tactile rendering
more coherent, testable, and accessible.

**Method:** Repository inspection plus primary sources only: Flutter API and
framework documentation, W3C WCAG, Apple Human Interface Guidelines, Fluent 2,
and Carbon Design System. Context7 was consulted first for current Flutter
documentation; its Flutter source result confirms that Flutter introduced theme
extensions specifically for properties beyond the standard Material theme.
[Flutter release notes](https://github.com/flutter/website/blob/main/sites/docs/src/content/release/release-notes/release-notes-3.0.0.md)

## Executive recommendation

Do **not** attempt to differentiate Nemo by adding more blur, more gradients,
or more customizations to Material widget themes. Establish a Nemo-owned
**material model** instead: named layers, a single physical-light recipe,
state recipes, shape/spacing/motion rules, and conformance tests. Material may
remain an integration and behavioral substrate, but it must not be the source
of a Nemo component’s rendered appearance.

The next product milestone should be a versioned **Theme Contract v2** plus a
small set of Nemo layout/navigation primitives for the catalog. Then migrate
components incrementally through that contract, beginning with the surface
primitive. This is a design-system evolution, not a wholesale rewrite.

## Current-state audit

### What is already strong

- The architecture already isolates `NemoThemeData` as an immutable
  `ThemeExtension`, with `copyWith` and `lerp`, and separates foundation,
  semantic, component, and motion tokens. This is the correct extension seam:
  `ThemeData.extensions` stores arbitrary extensions and
  `ThemeData.extension<T>()` retrieves them.
  [Flutter `ThemeData.extensions`](https://api.flutter.dev/flutter/material/ThemeData/extensions.html)
- `doc/architecture/tactile-visual-language.md` defines a valuable starting
  contract: fixed screen-space top-left light, five local depth names,
  restrained accent use, explicit focus, high-contrast fallback, and
  host-owned typography.
- `NemoSurface`, `NemoButton`, and `NemoSwitch` render their tactile treatment
  with Nemo tokens and custom painters rather than stock Material buttons,
  cards, or switches. They also preserve Focus, keyboard activation,
  Semantics, 48 px minimum controls, and reduced motion. Flutter recommends
  a 48×48 dp touch target and calls for 4.5:1 contrast for normal text and
  3:1 for large text. [Flutter accessibility styling guidance](https://docs.flutter.dev/ui/accessibility/ui-design-and-styling)
- The package has meaningful interaction, token, semantic, reduced-motion, and
  golden coverage. The Surface golden deliberately contains real blur/shadow
  depth scenes rather than only flat high-contrast substitutes.

### Why it still reads as Material

1. **The catalog shell remains visibly Material.** Every catalog page uses
   `Scaffold` and `AppBar`; routing uses `MaterialPageRoute`; the catalog theme
   opts into `useMaterial3: true` and derives a `ColorScheme` with
   `ColorScheme.fromSeed`. The catalog also uses Material `Typography` and
   Material iconography. Those are strong recognitional cues even when the
   three Nemo controls themselves are custom. Flutter documents `ThemeData` as
   the configuration that Material widgets use, including `colorScheme`,
   `textTheme`, and per-component themes.
   [Flutter `ThemeData`](https://api.flutter.dev/flutter/material/ThemeData-class.html)
2. **The semantic layer is too color-centric and too shallow.** Today it has
   `surface` and `surfaceVariant`, while depth is a component-specific
   `NemoSurfaceDepthStyle`; there is no first-class semantic vocabulary for
   canvas, base, recessed, raised, floating/transient, subtle border, and
   selected/critical state. This invites components and catalog layouts to
   reconstruct meaning through `ColorScheme` and local blends.
3. **The lighting rule is prose-first, not an executable recipe.** Surface,
   Button, and Switch each contain their own shadow-painting logic and blend
   behavior. The source is careful, but the contract does not yet make
   direction, inverse inset edges, opacity, blur spread, outline, and overlay
   an independently verified shared recipe. Consequently, a new component can
   appear “almost Nemo” while drifting perceptually.
4. **Shape, iconography, typography, and composition are intentionally
   under-specified.** The current contract delegates all typography to hosts,
   and Nemo exposes only three radii. That is valid package restraint, but the
   catalog consequently defaults to Material typography, Material symbols, an
   AppBar, and ordinary page/chrome proportions. Nemo needs a *typographic
   role contract* (not a bundled font) and own guidance for icon stroke,
   corner-family use, page chrome, and density.
5. **State language is not fully standardized across primitives.** Buttons
   encode six state styles; switches derive hover/focus/pressed interaction
   blends locally; Surface is noninteractive. A cross-component state matrix
   has been documented, but not yet represented as a shared token/API or
   validated as a visual matrix. Focus must remain its own clear visual layer:
   Flutter’s focus system treats focus nodes and traversal as first-class
   interaction infrastructure. [Flutter focus guide](https://docs.flutter.dev/ui/interactivity/focus)

### Tactile-polish risks to resolve deliberately

- For raised geometry, the implementation places highlight at top-left and
  lowlight at bottom-right. For inset geometry, the edge treatment is inverted
  to create occlusion. The documentation should name this explicitly as an
  **edge-polarity rule** rather than implying that every relief type paints the
  same color on the same edge. This avoids future “fixes” that make recesses
  look embossed.
- The default foundation shadow (`18` blur / `8` offset) is global, while
  surface/button/switch multiply it independently. A physically coherent
  system needs bounded named recipes and ratio invariants, not merely shared
  base numbers. Fluent likewise defines elevation through coordinated shadow
  and light and notes that direction establishes the perceived light source.
  [Fluent 2 elevation](https://fluent2.microsoft.design/elevation)
- The chosen soft canvas and paired shadows are a sound start, but the catalog
  has few large quiet planes or intentional depth islands. Repeated control
  rows and Material chrome make the characteristic relief read as a component
  effect instead of a world/material.

## Theme Contract v2

Keep `NemoThemeData` and evolve it additively. A component should consume only
roles from this contract; it must not derive appearance from `ColorScheme`,
raw palette values, or literal blur/offset values.

| Layer | Proposed ownership | Example tokens |
| --- | --- | --- |
| Foundation | Scale and geometry only | spacing steps, corner family, stroke widths, control targets, shadow kernels |
| Semantic material | Meaning independent of a widget | `canvas`, `surface`, `surfaceRaised`, `surfaceRecessed`, `surfaceFloating`, `contentPrimary`, `contentSecondary`, `borderSubtle`, `borderStrong`, `focus`, status roles |
| Illumination | One physical-light algorithm | fixed vector, raised edge pair, inset edge pair, ambient overlay, occlusion, blur/offset/opacity per depth |
| Interaction | Same state vocabulary everywhere | resting, hover, pressed, focus, selected, disabled, loading, error/success; each has non-depth evidence |
| Component | Mapping only | button recipe, switch track/thumb recipe, field recipe, navigation recipe |
| Motion | Intent rather than generic speed | press, hover/focus, toggle, reveal, emphasis, each with reduced-motion outcome |

This role-based approach is proven design-system practice: Carbon themes assign
values to role-based tokens rather than embedding raw color meaning in
components. [Carbon color overview](https://preview.carbondesignsystem.com/building-blocks/foundations/color/overview)

### Illumination standard

Define four, not unlimited, local material states: **recessed, base, raised,
floating**. Keep the current five public Surface depths only if the middle two
can be perceptually distinguished in user review; otherwise make one an alias.
For each state, specify and test:

- physical light vector in screen coordinates;
- raised and inset edge polarity separately;
- offset, blur/spread, opacity, and tonal-overlay ranges;
- whether an outline is allowed, required, or forbidden;
- allowable parent depth and maximum nesting;
- high-contrast replacement (tone + border + focus, no decorative shadows).

Apple’s materials guidance makes the relevant principle clear: materials
establish hierarchy and layers; use them semantically and sparingly, while
adapting to accessibility settings such as increased contrast and reduced
transparency. [Apple HIG: Materials](https://developer.apple.com/design/human-interface-guidelines/materials)

### Identity beyond shadows

Nemo should define the following **without claiming ownership of a font**:

- a type-role mapping (`display`, `section`, `label`, `body`, `meta`,
  `numeric`) with line-height, tracking, casing, and density rules;
- an icon policy: one optical size grid, stroke/filled choice by state, and
  semantic icons only—do not use the Material symbol set as the catalog’s
  visual voice by default;
- a shape policy: a recognizably limited radius family and rules for pill,
  compact control, panel, and floating plane; and
- a composition policy: one dominant canvas, recessed receiving areas, raised
  action islands, a strict elevation budget, and Nemo-owned navigation/header
  chrome in the example.

The goal is not to imitate Apple, Fluent, or Carbon. Borrow their system
principle—layering, roles, and state consistency—while retaining Nemo’s soft,
fixed-light tactile material.

## Recommended delivery sequence

### 1. Establish the contract and measurement rubric

Write `Theme Contract v2` and a visual-audit checklist before changing more
components. Make it acceptance criteria, not aspirational prose:

- all semantic roles resolved in light, dark, and high contrast;
- contrast assertions on actual post-overlay surfaces (normal text ≥4.5:1;
  non-text boundaries/state indicators ≥3:1);
- fixed-light and inset-polarity assertions;
- one state matrix per interactive primitive;
- reduced-motion final-state expectations; and
- a visual review board of canonical scenes, not only isolated controls.

WCAG requires 4.5:1 for normal text (with the defined large-text exception),
and color must not be the only means of conveying information.
[WCAG 2.2 contrast minimum](https://www.w3.org/WAI/WCAG22/Understanding/contrast-minimum.html)
[WCAG 2.2 use of color](https://www.w3.org/WAI/WCAG22/Understanding/use-of-color.html)

### 2. Extract a shared tactile renderer and token recipe

Move the common paired-shadow/inset-shadow calculations from the three
painters behind private foundation helpers. Keep component painters responsible
for geometry and state mapping, but make illumination math impossible to
silently diverge. Add golden scenes that place raised and recessed instances
side-by-side under the same light vector in light, dark, and high contrast.

This is a low-risk internal refactor: `NemoThemeData` already supports theme
extension interpolation, which enables coherent transitions for values that
are part of the theme contract. [Flutter `ThemeExtension.lerp`](https://api.flutter.dev/flutter/material/ThemeExtension/lerp.html)

### 3. Make the catalog a Nemo specimen, not a Material app demo

Replace the visible Material shell in `example/` incrementally:

- introduce a Nemo page frame/header and destination row/navigation primitive;
- replace Material-default typography/icon presentation with the Nemo type and
  icon policy; and
- show canonical composition scenes (canvas, recess, action island, transient
  plane) rather than mostly controls in rows.

Continue using `MaterialApp`, `Navigator`, and other Material infrastructure
where useful; the requirement is that the *pixels and interaction feedback*
are Nemo-owned. This protects accessibility and host integration while removing
the strongest Material visual signals.

### 4. Complete component state standardization

Adopt one explicit table that each interactive component implements: resting,
hover, pressed, focus, selected/value, disabled, loading where applicable,
and error/success where applicable. Each row must specify semantic output,
keyboard behavior, visible focus, color/border/icon/text evidence, tactile
change, and reduced-motion behavior. Do not make depth or animation the only
signal.

For micro-interactions, retain Nemo’s restrained policy. Carbon separates
productive from expressive motion and recommends brief, purpose-driven
micro-interactions rather than decorative bounce. [Carbon motion](https://carbondesignsystem.com/elements/motion/overview/)
WCAG 2.2 requires a way to disable non-essential interaction-triggered motion.
[WCAG 2.2 animation from interactions](https://www.w3.org/WAI/WCAG22/Understanding/animation-from-interactions.html)

### 5. Validate perception, not only implementation

Goldens catch regressions but cannot establish that two depths are perceptually
distinct or that a control is recognizably actionable. Add a small review loop
with target users/designers across light/dark/high contrast and at different
text scales. Test three questions: “what can I act on?”, “what is selected?”,
and “what is above/below the canvas?” If answers depend on shadow alone,
rework the non-depth cue.

## File-level starting points

| Area | Evidence | First change after contract approval |
| --- | --- | --- |
| Theme model | `lib/src/foundation/nemo_theme_data.dart` | Add semantic material/layer and illumination recipe groups; preserve additive overrides and `lerp`. |
| Relief primitive | `lib/src/components/nemo_surface.dart` | Extract shared renderer; encode edge polarity and depth invariants. |
| Interactive recipes | `lib/src/components/nemo_button.dart`, `lib/src/components/nemo_switch.dart` | Map their local state logic to shared interaction/illumination recipes. |
| Visual contract | `doc/architecture/tactile-visual-language.md`, `doc/motion.md` | Promote rules into a measurable contract and clarify raised vs inset polarity. |
| Catalog | `example/lib/src/catalog_theme.dart`, `example/lib/src/pages/` | Replace recognizable Material chrome and symbols with Nemo-owned specimen layout. |
| Regression suite | `test/components/*_test.dart`, `test/components/*_golden_test.dart` | Add matrix/property/golden tests for tokens, light vector, contrast, and cross-component state consistency. |

## Decisions to make in the grilling session

1. Is Nemo’s desired identity “quiet tactile workspace” (recommended), or does
   it need a more expressive/branded direction? The answer determines whether
   texture/gradients are ever justified.
2. Does Nemo want to own a type-role contract only, or publish a default font
   pairing as an optional preset? A default font increases identity but expands
   brand, licensing, and rendering responsibility.
3. Should `elevated` remain distinct from `raised` after blind visual review?
   If not, collapse it internally before more components depend on it.
4. Which Material signals are prohibited in Nemo-owned examples: `AppBar`,
   Material symbols, Material typography, ripple, card shape, or all rendered
   Material chrome? Set a precise compatibility boundary.
5. Is a new `NemoPageFrame`/navigation primitive in scope? Without it, the
   example will remain the strongest Material association even if controls are
   refined.
6. What is the minimum high-contrast promise: three depth categories, or a
   full semantic layer model expressed through tone/border/content?

## Source index

- [Flutter `ThemeData.extensions`](https://api.flutter.dev/flutter/material/ThemeData/extensions.html)
- [Flutter `ThemeExtension.lerp`](https://api.flutter.dev/flutter/material/ThemeExtension/lerp.html)
- [Flutter `ThemeData`](https://api.flutter.dev/flutter/material/ThemeData-class.html)
- [Flutter UI design and styling accessibility](https://docs.flutter.dev/ui/accessibility/ui-design-and-styling)
- [Flutter focus system](https://docs.flutter.dev/ui/interactivity/focus)
- [Flutter Theme Extensions release notes](https://github.com/flutter/website/blob/main/sites/docs/src/content/release/release-notes/release-notes-3.0.0.md)
- [W3C WCAG 2.2 contrast minimum](https://www.w3.org/WAI/WCAG22/Understanding/contrast-minimum.html)
- [W3C WCAG 2.2 use of color](https://www.w3.org/WAI/WCAG22/Understanding/use-of-color.html)
- [W3C WCAG 2.2 animation from interactions](https://www.w3.org/WAI/WCAG22/Understanding/animation-from-interactions.html)
- [Apple HIG: Materials](https://developer.apple.com/design/human-interface-guidelines/materials)
- [Fluent 2 elevation](https://fluent2.microsoft.design/elevation)
- [Carbon color overview](https://preview.carbondesignsystem.com/building-blocks/foundations/color/overview)
- [Carbon motion](https://carbondesignsystem.com/elements/motion/overview/)
