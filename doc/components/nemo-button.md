# NemoButton

## Purpose

`NemoButton` is Nemo's single primary action. It owns focus, pointer and
keyboard interaction, tactile feedback, and button semantics. It is not a
general container or a visual variant API; use `NemoSurface` for non-
interactive grouping.

## API

```dart
NemoButton(
  onPressed: save,
  isLoading: isSaving,
  semanticLabel: 'Save profile',
  child: const Text('Save'),
)
```

The public constructor exposes only `child`, `onPressed`, `isLoading`,
`semanticLabel`, `autofocus`, and `focusNode`. Colors, spacing, shape, focus
width, relief, and motion are token-owned. `child` is required and remains
caller-configurable.

## States and interaction

The component renders resting, hover, focus, pressed, disabled, and loading
states. Hover is mouse-only. Touch and mouse taps activate `onPressed`; Enter
and Space do the same when focused. A pressed state changes only paint
(shadows and tonal treatment), never constraints, padding, or surrounding
layout.

`onPressed: null` disables the control. `isLoading: true` also disables it,
replaces descendant semantics with `NemoLocalizations.loading`, and prevents
repeat activation. The localized visible loading copy is system-owned, while
all non-loading visible content is caller-owned.

## Accessibility and responsive behavior

The button exposes a button semantic role, enabled state, optional accessible
name, and semantic tap action when enabled. Focus is a high-contrast visible
ring rather than depth alone. It has a tokenized minimum 48 logical-pixel
height, wraps caller content without clipping, and respects text scaling.

Light, dark, and high-contrast themes use semantic colors and component
metrics. High contrast preserves explicit outline and focus signals. Reduced
motion resolves the token animation duration to zero: state changes occur
without spatial transformation.

## Tokens

NemoButton consumes `NemoThemeData.semantic` for action, foreground, outline,
focus, and shadow colors; `components` for control height, padding, outline,
and focus-ring widths; `foundation` for radius and depth metrics; and
`motion.quick` for feedback. `NemoButtonTokens` defines every state’s
paint-only foreground, shadow, and outline treatment plus progress metrics. It
uses the finite public `NemoButtonState` enum for state lookup. It
does not use `NemoSurface` as an interactive control. When reduced motion is
requested, loading uses a static hourglass icon instead of an infinite spinner.

## Preview and tests

Open **Components / Button states** in
`example/previews/foundation_previews.dart`, or run the example catalog to
inspect loading, disabled, theme, text-scale, locale, and reduced-motion
scenarios. Widget and semantics tests cover the state machine, pointer,
keyboard, focus, loading localization, and the deterministic golden baseline.
