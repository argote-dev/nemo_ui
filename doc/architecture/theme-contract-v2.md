# Theme Contract v2

Nemo 0.2.0 is a calm tactile language, not a Material skin. `NemoThemeData` is
its sole public theme entry point. Internally it owns foundation spacing and
corners, semantic colors, bounded material recipes, fixed illumination,
interaction recipes, component geometry, and motion. `ColorScheme` may support
a host `ThemeData`, but Nemo components never derive their materials or light
from it.

## Materials and illumination

There are exactly four local materials: **recessed** (receiving wells/tracks),
**base** (the uninterrupted canvas), **raised** (controls and local action
islands), and **floating** (a transient/prominent plane only). A composition
has one dominant base canvas and at most one material jump from its immediate
parent. Floating is never a persistent card substitute.

The light is always physical top-left, including RTL. Raised edges place the
highlight top-left and lowlight bottom-right; inset edges invert that polarity.
All painting uses the internal shared illumination renderer. Recipes are typed,
bounded token values; there is no public painter or literal-shadow escape hatch.
High contrast substitutes zero shadows with distinct tonal materials, full
explicit boundaries, and the focus ring.

## Roles and safe customization

Corner roles are `control`, `panel`, and `floating`; consumers select roles,
not arbitrary corner geometry. Primary is limited to primary action, selection,
progress, and intentional emphasis. Borders clarify ambiguous boundaries; they
are mandatory in high contrast. Nemo owns visual surface, spacing, corner,
focus and state treatment; hosts own font family, type scale, weights and
content hierarchy. Use a curated action/state icon where an icon adds redundant
meaning; do not use a Material icon family as Nemo visual chrome.

`NemoThemeData` customization is safe when replacing complete token groups or
bounded recipes. Component code must not depend on raw `ColorScheme`, palette
literals, arbitrary blur/offset values, or a custom light direction.

## Interaction and accessibility

Availability, focus, interaction, and selected/value state are orthogonal.
Resting, hover, pressed, focus, selected, disabled and loading recipes compose
with role semantics. Pressed transitions raised-to-inset with tone/border and
at-most 1 logical-pixel content displacement; it never bounces/scales. Reduced
motion resolves directly to the same final visual and semantic state.

After overlays, text contrast is at least 4.5:1 and state/boundary indicators
at least 3:1. Every focus, press, selected/value, disabled, loading and status
state has non-color, non-depth evidence. Keyboard, pointer/touch, semantics,
RTL geometry, text scaling, and platform focus behavior are contractual.

## Conformance rubric

For every component, record: semantic role and material mapping; material jump
and floating budget; light/dark/high-contrast canonical scene; state matrix;
post-overlay contrast; keyboard/pointer/touch and semantics evidence; RTL and
large-text evidence; and reduced-motion final-state evidence. Perceptual review
must answer: *what is actionable, what is selected, and what is above/below the
canvas?* Goldens are diagnostic evidence, not a claim of human validation.

## v1 migration

`deeplySunken` and `sunken` map to `recessed`, `flat` to `base`, `raised` to
`raised`, and `elevated` to `floating`. The legacy `depth` and `shape` arguments
remain deprecated only to make this pre-1.0 migration explicit; new code uses
`material` and `cornerRole`. Five distinct visual depths no longer exist.

## Calibration evidence

The [disposable calibration board](../research/theme-v2-calibration.md) records the canonical scene and bounded-recipe rationale.
