# NemoSwitch

## Purpose and API

`NemoSwitch` is controlled binary selection. `value`, `onChanged`, `child`,
`semanticLabel`, `autofocus`, and `focusNode` are its only public seam:

```dart
NemoSwitch(value: enabled, onChanged: setEnabled, child: const Text('Alerts'))
```

`onChanged: null` is unavailable. Caller owns the next value and visible label;
Nemo owns localized On/Off value copy and state treatment.

## v2 interaction contract

The control retains only switch geometry/domain semantics. Shared
`NemoThemeData.interactions` layers value/selected, hover, press, focus and
disabled evidence; shared v2 materials and the internal fixed-top-left renderer
paint the recessed track and raised thumb. Press moves toward recessed with
tone/border evidence; focus remains independent. `NemoSwitchTokens` owns only
track/thumb dimensions and component-specific tonal/disabled mappings.

On/off is redundantly communicated through thumb position, check/minus icon,
tonal/border treatment and switch semantics—not accent color, relief or motion
alone. High contrast removes decorative shadows and retains full boundaries and
focus. No component-local literal illumination is permitted.

## Accessibility, motion and evidence

The merged node exposes toggled/enabled/value/tap semantics. Touch, mouse,
Enter and Space request the opposite value; 48px targets, RTL alignment, text
scale and keyboard traversal are supported. One composed visual interpolates
track, thumb, relief, and the check/minus indicator together. `motion.standard`
resolves toggles; `motion.quick` covers hover/press geometry; `motion.instant`
covers focus. Hover, press, and focus tone is immediate acknowledgement so the
state-matrix golden remains the settled recipe. Reduced motion paints the final
state directly. Rapid toggles and press/release are interruptible and converge
on the latest value.

The state matrix and canonical light/dark/high-contrast scenes cover off/on,
hover/press/focus/disabled, pointer/touch/keyboard, localization, RTL, contrast
and reduced motion. Canonical PNGs are generated only by pinned Ubuntu CI;
local blurred captures are diagnostic.
