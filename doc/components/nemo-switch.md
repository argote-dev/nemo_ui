# NemoSwitch

## Purpose

`NemoSwitch` is Nemo's controlled binary-selection component. It combines an
explicit on/off position, color, icon, outline, and semantics so relief or
color is never the only state signal.

## API

```dart
NemoSwitch(
  value: notificationsEnabled,
  onChanged: (bool value) => setState(() => notificationsEnabled = value),
  child: const Text('Notifications'),
)
```

`semanticLabel` optionally supplies a caller-owned accessible name and excludes duplicate child semantics. Without it, the child supplies the accessible name.

`value` and `onChanged` implement Flutter's controlled-selection contract.
Passing `onChanged: null` makes the switch unavailable. `child` is required,
caller-owned visible content. `autofocus` and `focusNode` support composition
with keyboard focus management.

## States and interaction

The component renders on/off, hover, focus, pressed, and disabled states.
Touch and mouse taps, Enter, and Space request the opposite value through
`onChanged`; the caller supplies the next `value`. Hover is mouse-only.
Interaction feedback changes paint only, never surrounding layout.

## Accessibility and responsive behavior

NemoSwitch exposes native switch/toggled semantics, enabled state, a semantic
tap action when available, and localized system-owned `On`/`Off` labels from
`NemoLocalizations`. Caller content remains visible and contributes the
selection's accessible name. The hit target is at least 48 logical pixels
high, supports text scaling, and has an explicit focus outline. Disabled
controls cannot receive keyboard or pointer activation.

Light, dark, and high-contrast themes consume semantic colors. The on/off
state uses position plus check/minus icons and the outline, in addition to
color. Motion uses `NemoMotionTokens.quick`; reduced motion resolves it to
zero duration.

## Tokens

`NemoSwitchTokens` provides track dimensions, thumb diameter, track outline
opacity, and disabled opacity. It is available from
`NemoThemeData.components.switchControl`; it supports presets, `copyWith`,
interpolation, equality, and hashing. Shared component, foundation, semantic,
and motion tokens provide the target, focus ring, colors, shadows, and timing.

## Preview and tests

Open **Components / Switch states** in
`example/previews/foundation_previews.dart`, or run the example catalog to
inspect localized, reduced-motion, text-scale, brightness, and high-contrast
scenarios. Widget and semantics tests cover touch, mouse, keyboard, disabled,
localized state, target size, and reduced motion.
