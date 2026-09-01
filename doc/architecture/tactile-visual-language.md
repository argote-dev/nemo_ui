# Tactile visual language

This contract defines the visual output of Nemo-owned surfaces and controls.
It makes the canvas, relief, and interactive feedback read as one continuous
material. Material may provide infrastructure, but it must not define the
visual output of Nemo-owned components or the catalog.

## Lighting model

Nemo has one physical light source: **top-left**. It is fixed in screen space
and is never mirrored for RTL. Every relief treatment uses the same paired
roles:

- `semantic.highlightShadow` is the light-facing highlight at the top-left.
- `semantic.lowlightShadow` is the dark-facing lowlight at the bottom-right.
- The surface's tonal overlay is the ambient material change that keeps a
  depth readable between shadows.
- Inset shadows and the darker tonal treatment provide occlusion for recessed
  areas; outer shadows provide separation for raised areas.

Do not introduce a second light direction, a single-sided drop shadow, or a
shadow whose direction changes by component. Light and dark themes keep this
direction; they change the semantic colors and opacity, not the geometry.

## Depth model

Depth is relative to the immediately surrounding material. A nested component
must select a depth deliberately; it does not inherit an absolute elevation.
Use `components.surface` and the foundation shadow metrics, rather than
hard-coded color, blur, or offset values.

| Depth | Intended reading | Current token mapping | Standard treatment |
| --- | --- | --- | --- |
| `deeplySunken` | A strongly recessed well for a persistent local value or inset. | `components.surface.deeplySunken` (`intensity: -2`) | Lowlight tonal overlay, paired inset shadows, strongest occlusion. |
| `sunken` | A normal recessed track, field, or local container. | `components.surface.sunken` (`intensity: -1`) | Lowlight tonal overlay and paired inset shadows. |
| `flat` | The dominant uninterrupted canvas or a neutral local plane. | `components.surface.flat` (`intensity: 0`) | No tactile shadow; only a restrained tonal boundary when required. |
| `raised` | The ordinary actionable or grouped plane. | `components.surface.raised` (`intensity: 1`) | Highlight tonal overlay and paired outer shadows. |
| `elevated` | The single most prominent local plane, such as a transient or primary grouping. | `components.surface.elevated` (`intensity: 2`) | Strongest paired outer shadows and separation. |

`foundation.shadowBlur` and `foundation.shadowOffset` establish the shared
shadow geometry. Each `NemoSurfaceDepthStyle` owns its blur, offset, shadow,
outline opacity, and tonal-overlay multipliers. In high contrast, the five names remain
available but intentionally collapse to three perceptual categories: sunken
(`deeplySunken`/`sunken`), flat, and raised (`raised`/`elevated`).

## Outlines and focus

Outlines clarify boundaries; they do not replace the lighting model in standard
mode.

- **Standard mode:** use the 1 px `components.outlineWidth` tonal outline only
  when a boundary would otherwise be ambiguous: a `flat` local region, an inset
  edge, a compact control track, or a disabled/loading control. Do not outline
  every raised surface or use outlines as decoration.
- **Focus mode:** an interactive Nemo component must show the 3 px
  `components.focusRingWidth` ring in `semantic.focusRing`. It sits outside the
  control's normal boundary, remains visible over relief, and is never replaced
  by a pressed shadow or color shift.
- **High-contrast mode:** suppress decorative highlight and lowlight shadows.
  Use the 2 px `components.outlineWidth` boundary, full-opacity component
  outlines where needed, and retain the 3 px focus ring. High contrast must
  communicate hierarchy through explicit tone, boundary, content, and state,
  not through relief alone.

## Accent color and control states

`semantic.primary` is a scarce interaction signal, not a replacement canvas or
full control fill.

- A primary action may use primary for its label/icon, focus treatment, selected
  indicator, or small local emphasis while its body remains a Nemo surface.
  Full primary fills are reserved for an exceptional destructive/critical
  confirmation when the state would otherwise be unclear.
- Neutral controls use `semantic.surface`, `surfaceVariant`, `foreground`,
  `mutedForeground`, and relief for their resting form. Their disabled state
  uses the component disabled opacity plus an explicit boundary or content cue,
  not a washed primary fill.
- Switch selection uses position, check/minus icons, outline, and accessible
  `On`/`Off` state in addition to primary color. Button loading uses its
  localized loading indication; pressed, hover, and focus states also retain
  an explicit non-depth cue.
- Reserve `success` and `error` for their semantic statuses. Do not use them
  to create unrelated component variants.

## Composition and content

The canvas is the dominant `semantic.surface` plane. Build pages as quiet
expanses of that material with small, intentional islands of depth.

- Keep one dominant canvas in a viewport; use `surfaceVariant` to distinguish
  only meaningful local regions.
- Limit simultaneous elevation: a raised child belongs on a flat or sunken
  parent; do not stack `elevated` surfaces inside raised cards merely to create
  visual interest. One local composition should have at most one `elevated`
  plane.
- Use sunken depth for persistent receiving areas and raised depth for controls
  that can be acted on. Transitioning a pressed control toward inset is
  feedback, not a new layout level.
- Preserve tokenized spacing, shapes, minimum 48 px targets, and icons that
  describe the action or state. Nemo owns surface, spacing, shape, iconography
  guidance, and interaction treatment; the host owns typography, including font
  family, type scale, weights, locale-specific typography, and text hierarchy.
- Relief is decorative. Every interactive or selected state must also expose a
  semantic role/value, keyboard support, visible focus, and a non-depth cue
  such as position, icon, text, outline, or color. Respect reduced motion and
  validate foreground and muted-foreground contrast after surface changes.

## Theme examples

### Light

A light settings page uses the soft `semantic.surface` canvas. A section header
and content remain flat; a notification preference sits in a sunken local row;
the selected `NemoSwitch` moves its thumb, shows a check icon, and uses a
restrained primary indicator. The page's single save action is raised with a
top-left highlight and bottom-right lowlight. Keyboard focus adds the 3 px
focus ring rather than a second elevation.

### Dark

A dark account page keeps the same top-left light direction: the dark-theme
highlight appears at the top-left and the black lowlight at the bottom-right.
A raised profile panel separates gently from the dark canvas, while a sunken
security-status well uses inset occlusion. Primary is limited to the selected
state and focus ring; text continues to use the host's typography.

### High contrast

A high-contrast preferences page uses black/white surfaces with no decorative
shadows. A 2 px boundary distinguishes the track and grouped regions; a 3 px
focus ring identifies the keyboard target. The switch exposes both its thumb
position and check/minus icon, and the button label remains explicit. The
result preserves hierarchy and state without relying on relief or color alone.

## Required token evolution and delivery scope

This issue records the contract; it does not change implementation tokens or
component rendering. It does prescribe the following token changes for the
delivery issues. They are internal theme-contract changes, not new public
widget parameters.

| Owner | Required token change |
| --- | --- |
| `NemoSurface` | Recalibrate each `components.surface` depth style's tonal overlay, outline, shadow opacity, blur, and offset so adjacent depths remain distinct in light and dark modes; reduce standard raised/sunken outlines. `foundation` retains shared radius, blur, and offset, and `semantic` supplies surface, outline, highlight, and lowlight roles. |
| `NemoButton` | Extend `components.button` state styles with surface-based neutral and restrained-accent treatments, plus an explicit inset pressed treatment. Its existing paint-only state model remains the seam; shared `components` retains target, padding, outline, and focus widths while `semantic` supplies action, foreground, outline, focus, and shadow roles. |
| `NemoSwitch` | Extend `components.switchControl` beyond geometry and disabled opacity with tokens for track inset relief, thumb elevation, and on/off tonal treatment. Shared component, foundation, semantic, and motion tokens continue to provide focus, paired-light colors, target, and timing. |

Implementation is deliberately deferred: #23 applies the shared depth and
lighting contract to Surface, #24 to Button, #25 to Switch, #26 to the catalog
composition, and #27 to shadow-preserving regression coverage. Each delivery
must preserve this document's lighting, accessibility, and host-typography
rules.
