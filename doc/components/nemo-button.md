# NemoButton

## Purpose and API

`NemoButton` is Nemo's accessible primary action. Its public seam is limited to
`child`, `onPressed`, `isLoading`, `semanticLabel`, `autofocus`, and `focusNode`:

```dart
NemoButton(onPressed: save, isLoading: saving, child: const Text('Save'))
```

There are no visual variants. Caller content is domain-owned; loading copy and
its live semantics are Nemo-localized.

## v2 interaction contract

Geometry remains component-owned, while `NemoThemeData.interactions` supplies
orthogonal resting, hover, pressed, focus, selected, disabled and loading
recipes. `NemoThemeData.materials` plus the internal shared renderer supplies
all physical light, tonal and border calculations. Resting/hover/focus are
raised; press is recessed with a bounded one-pixel content displacement, tone
and explicit border evidence. Focus is an independent visible ring. Disabled
and loading use base with explicit content/boundary evidence.

Primary is restrained to content/emphasis/progress. High contrast is shadow-free
with explicit borders and focus. Button consumes foundation target/corner
metrics, semantic colors, component padding/progress tokens, shared materials,
interaction recipes and motion; it has no literal illumination escape hatch.

## Accessibility, motion and evidence

The merged semantic node exposes button/enabled/tap state; Enter, Space, mouse
and touch share activation. It keeps a 48px target, supports RTL and text scale,
and maintains post-overlay text contrast. Press/focus/loading/disabled evidence
is never depth, color or motion alone. `motion.quick` animates the physical
transition; reduced motion reaches its identical final state directly and uses a
static loading affordance.

State matrix and canonical scenes cover light/dark/high contrast, rest/hover/
press/focus/disabled/loading, keyboard, pointer/touch, reduced motion and
contrast. PNG baselines come only from pinned Ubuntu CI; local golden diffs are
diagnostic.
