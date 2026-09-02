# NemoSurface

## Purpose

`NemoSurface` is Nemo's non-interactive semantic material composition primitive.
Use it to group content into one of the four Theme Contract v2 materials; do not
use it to create an interactive control, communicate state, or replace explicit
focus, error, selection, or loading evidence.

## Anatomy

- **Local material fill:** the token-derived `surface` or `surfaceVariant`.
- **Relief:** paired Canvas shadows for raised/floating or reversed inset edges
  for recessed; `base` remains the uninterrupted canvas.
- **Boundary:** Canvas outline, and any caller-owned focus treatment.
- **Content:** caller-owned child, padding, semantics, gestures, and focus.

Surface itself adds no role, action, focus target, or gesture.

## API and examples

Import only the curated entry point:

```dart
import 'package:nemo_ui/nemo_ui.dart';
```

```dart
NemoSurface(
  material: NemoMaterial.raised,
  cornerRole: NemoCornerRole.panel,
  tone: NemoSurfaceTone.surfaceVariant,
  child: const Text('Content'),
)
```

The four materials are `recessed` (receiving area), `base` (canvas), `raised`
(action/group plane), and `floating` (transient/prominent plane). Defaults are
raised/panel/surface, `space16` padding, and `Clip.none`. One composition has
one dominant base canvas and at most one local material jump.

`enableProgressiveRendering` is experimental and defaults to `false`. It may be
set to `true` only for an eligible large, static raised/floating surface after
profile and conformance evidence supports the target scenario. It exposes no
fragment asset, uniform, callback, or light-direction API.

## Variants and states

`recessed`, `base`, `raised`, and `floating` are the only visual variants.
`cornerRole` selects control/panel/floating geometry and `tone` selects the
semantic base color. Surface has no resting, hover, pressed, disabled, loading,
selected, or error state: callers own those states and their explicit evidence.

The experimental finish is skipped for all small/dense surfaces, transitions,
high contrast, unavailable/loading/failed programs, non-finite constraints, and
opt-out. Each remains Canvas-rendered with unchanged layout and semantics.

## Tokens

- `NemoThemeData.materials`: material polarity, tonal overlay, outline, shadow,
  blur, and offset recipes.
- `foundation`: `space16`, radius metrics, shadow blur, and shadow offset.
- `semantic`: surface colors, highlight/lowlight shadows, outline, and focus
  ring color.
- `components`: outline and focus-ring widths.
- `motion`: `standard` duration and curve.

The internal optional finish uses one bounded private recipe for rim strength,
ambient occlusion, grain opacity, size, radius, base color, and the same fixed
physical top-left light direction as Canvas. These are not customization tokens.

## Content and localization

All visible and semantic content is caller-owned; Surface supplies no system
copy and therefore has no localization fallback. Directionality does not change
the physical top-left illumination source. Padding accepts `EdgeInsetsGeometry`,
so directional padding follows RTL. Text scaling and wrapping remain child-owned.

## Accessibility

Surface preserves descendant semantics, hit testing, and keyboard behavior; it
adds no semantic role. Canvas owns the visible outline, while interactive
children must provide their own focus target and explicit focus indicator.
High contrast is always shadow-free Canvas with explicit borders. Relief and
the optional finish never convey state. Surface imposes no target size; callers
must meet target-size requirements for interactive descendants.

## Motion

Material changes use `motion.standard` and `motion.standardCurve`. With
`MediaQuery.disableAnimations`, the same final Canvas material renders
immediately. During material transitions the fragment finish is not selected,
so reduced motion cannot introduce decorative animation.

## Responsive behavior

Surface sizes to its child and optional padding, honors normal Flutter
constraints, and clips content only when `clipBehavior` requests it. The
optional finish is bounded to finite surfaces at least 240×160 logical pixels;
ordinary controls, rows, dense lists, and constrained/small layouts stay on
Canvas. Android, iOS, and web retain the Canvas fallback.

## Preview

The native Flutter Widget Previewer scenario is
[`Surface depths`](../../example/previews/foundation_previews.dart), in the
**Components** group. It exposes the standard material matrix with its portable
Canvas baseline. The example-app surface route is
[`SurfaceCatalogPage`](../../example/lib/src/pages/surface_catalog_page.dart).
The experimental finish is intentionally not previewed or adopted until its
profile and conformance gate is complete.

## Test matrix

- **Unit/widget:** `test/components/nemo_surface_test.dart` covers v1 migration
  mapping, all materials, clipping, layout, RTL/text scaling, reduced motion,
  named descendant semantics, Canvas fallback selection, high contrast, and
  explicit opt-out.
- **Semantics/interactions:** surface preserves caller-owned semantics and hit
  testing; it has no interaction, localization, or focus role of its own.
- **Preview:** the native **Components / Surface depths** Widget Previewer
  scenario covers the standard Canvas material matrix; the example route is
  manual catalog evidence.
- **Golden:** `test/components/nemo_surface_golden_test.dart` retains the
  existing Canvas canonical `goldens/nemo_surface.png`: a 720×900 composed
  light/dark/high-contrast scene covering all materials, polarity, nesting, and
  shadow-free replacement. It pins Android, DPR 1, English locale, no text
  scaling, fixed animation preference, Ahem font, and glyph-free content.

Intentional Canvas baseline updates require tracked PNG review and before/after
pull-request evidence. Do not create local or noncanonical PNG baselines.
Fragment visual evidence is pending an authoritative stable backend; any future
shader golden must be captured/reviewed only there and must not replace the
Canvas canonical baseline.

## Decisions and known constraints

Canvas is mandatory: it owns external shadows, outlines/focus, and high-contrast
output. The fragment program can decorate only the local fill and is loaded and
cached outside paint. It remains experimental and default-off: **no performance
envelope or device evidence is claimed yet**. Before any adoption expansion,
follow the [profile procedure](../architecture/progressive-surface-renderer.md):
record p95 UI/GPU frame time, first-use jank, memory delta, an energy observation,
and equivalent Canvas-off comparison under documented target conditions. Keep
Canvas when evidence is incomplete or regresses.

`depth` and `shape` are deprecated v1 migration inputs. Map
`deeplySunken`/`sunken` to `recessed`, `flat` to `base`, `raised` to `raised`,
and `elevated` to `floating`; use `cornerRole` instead. See the
[0.2 migration guide](../migration-0.2.0.md).
