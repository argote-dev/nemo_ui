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

The component renders on/off, hover, focus, pressed, and disabled states. Its
track is a sunken channel with paired inset shadows: lowlight toward the
top-left and highlight toward the bottom-right. The thumb is a raised tactile
element with the inverse paired outer shadows. On and off states combine thumb
position, check/minus iconography, and restrained tonal changes; the track is
never a full primary fill.
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

Light and dark themes retain the same top-left lighting direction. In
high-contrast themes, decorative shadows are intentionally absent; the 2 px
boundary, thumb position, check/minus icons, tonal treatment, and 3 px focus
ring preserve state and target clarity. Motion uses `NemoMotionTokens.quick`;
reduced motion resolves it to zero duration.

## Tokens

`NemoSwitchTokens` provides track dimensions, thumb diameter, track outline
opacity, disabled opacity, and `off`/`on` `NemoSwitchStateStyle` treatments.
Each state style controls restrained track/thumb primary tonal blends plus the
paired inset-track and raised-thumb shadow opacity, blur, and offset
multipliers. It is available from `NemoThemeData.components.switchControl`; it
supports presets, `copyWith`, interpolation, equality, and hashing. Shared
component, foundation, semantic, and motion tokens provide the target, focus
ring, colors, shadows, and timing.

## Preview and tests

Open **Components / Switch states** in
`example/previews/foundation_previews.dart`, or run the example catalog to
inspect localized, reduced-motion, text-scale, brightness, and high-contrast
scenarios. Widget and semantics tests cover touch, mouse, keyboard, disabled,
localized state, target size, reduced motion, RTL, and state relief tokens. The
canonical golden preserves a sunken track and raised thumb with real paired
inset and outer shadows in standard contrast, alongside a separately visible
shadow-free high-contrast scene. It pins the shared raster inputs and uses
Ubuntu 24.04 x64 CI with Flutter 3.47.0 as canonical; local shadow-bearing captures are
diagnostic only. Intentional baselines come from the matching canonical CI
`*_testImage.png` and require tracked PNG review.
