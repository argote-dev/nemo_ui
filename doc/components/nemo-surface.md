# NemoSurface

## Purpose and API

`NemoSurface` is Nemo's non-interactive material composition primitive. It adds
no role, action, focus target, or gesture; callers own content and interaction.
Use the v2 API:

```dart
NemoSurface(
  material: NemoMaterial.raised,
  cornerRole: NemoCornerRole.panel,
  tone: NemoSurfaceTone.surfaceVariant,
  child: const Text('Content'),
)
```

The four materials are `recessed` (receiving area), `base` (canvas), `raised`
(action/group plane), and `floating` (transient/prominent plane only). Defaults
are raised/panel/surface, `space16` padding and `Clip.none`. One composition has
one dominant base canvas and at most one local material jump.

## Rendering, tokens and motion

`NemoThemeData.materials` owns bounded tonal, outline, blur, offset and opacity
recipes; `foundation` owns shared metrics and `semantic` owns colors. The
internal shared illumination renderer fixes light physical top-left in LTR and
RTL: raised has highlight top-left/lowlight bottom-right; recessed reverses
those inset edges. High contrast substitutes shadow-free tones and explicit
borders. Surface has no interaction recipe.

Material transitions use `motion.standard`; reduced motion paints the same final
material immediately. `cornerRole` selects control/panel/floating geometry.
Colors, literal shadows, painter hooks and arbitrary radii are not public
customization seams.

## Accessibility, evidence and migration

Surface preserves descendant semantics and text scaling; relief is never meaning.
Canonical composed light/dark/high-contrast scenes cover base plus all four
materials, polarity, contrast, nesting and shadow-free replacement. Canonical
PNGs are produced by pinned Ubuntu CI; local blurred captures are diagnostic.

`depth` and `shape` are deprecated v1 migration inputs. Map
`deeplySunken`/`sunken` to `recessed`, `flat` to `base`, `raised` to `raised`,
and `elevated` to `floating`; use `cornerRole` instead of `shape`. See the
[0.2 migration guide](../migration-0.2.0.md).
