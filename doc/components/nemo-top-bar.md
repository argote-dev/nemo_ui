# NemoTopBar

## Purpose

`NemoTopBar` is the persistent structural canvas for a page title, navigation,
and actions. Use it as `Scaffold.appBar` or as a normal-flow top child. Do not
use it as a floating panel, a transient command surface, or a substitute for a
caller-owned navigation model.

## Anatomy

- A continuous `semantic.surface` background that extends behind the status bar
  and iOS notch.
- A system-safe toolbar with an optional leading slot, a semantic heading, and
  optional trailing action slots.
- A tokenized lower `semantic.outline` boundary; it has no shadow, radius, or
  floating material treatment.

## API and examples

```dart
NemoTopBar(
  leading: const AccountBackAction(),
  title: const Text('Account'),
  actions: const <Widget>[HelpAction()],
)
```

The API intentionally accepts widgets. The application owns localized copy,
curated iconography, callbacks, keyboard behavior, and semantics.
`AccountBackAction` and `HelpAction` above are caller-owned placeholders, not
Nemo components or a prescribed icon set. `systemOverlayStyle` is an optional
local override for exceptional host policy. Without one, the component uses a
transparent status bar and chooses light or dark foreground icons from
`semantic.surface`; it never calls global `SystemChrome` APIs.

When `leading` is null, `automaticallyImplyLeading` defaults to `true` and uses
Flutter's dismissible-route convention. On a route whose
`impliesAppBarDismissal` is true, the component adapts Flutter's infrastructure
`BackButton` at directional `start`; it calls `Navigator.maybePop`. Root routes
do not receive a back control, and setting the flag to `false` disables the
adapter. This component does not infer drawers or any other navigation action.
An explicit `leading` always wins. Applications with curated iconography should
therefore provide it themselves.

## Variants and states

There are no visual material variants. The bar is always the persistent
`NemoMaterial.base` plane. Leading and action state is owned by the widgets the
caller supplies.

## Tokens

`NemoTopBar` reads `semantic.surface`, `semantic.foreground`, and
`semantic.outline`, plus `components.outlineWidth` and `components.topBar`:

- `horizontalPadding`
- `titleSpacing`
- `boundaryOpacity`

Its 64 logical-pixel toolbar height is an invariant widget contract and is not
theme-configurable. The preferred size excludes system insets.

## Content and localization

The title and slots are caller-owned widgets. The title inherits host
typography, receives `semantic.foreground`, is one line with ellipsis, and is
marked as a semantic header. Directional layout follows `Directionality`;
therefore leading/actions and padding mirror in RTL without translated strings
inside the component.

## Accessibility

The internal `SafeArea` consumes top, left, and right intrusions while retaining
the background behind them. Leading and every action receive at least a 48×48
logical-pixel layout target without replacing the child's semantics or focus
behavior. Supplied interactive widgets remain responsible for labels,
activation, focus visuals, and keyboard support. Large titles ellipsize rather
than overflow.

## Motion

The persistent bar has no animated depth, shadow, or motion state. Motion in
caller-supplied slots follows their own contracts.

## Responsive behavior

The toolbar remains 64 logical pixels tall, excluding safe insets. In a
`Scaffold.appBar`, Flutter supplies the status-bar extent and the internal
`SafeArea` consumes it once. In normal flow, the same `SafeArea` adds the top
extent above the toolbar. Lateral safe insets protect landscape and notched
devices.

## Preview

The example catalog's private `NemoPageShell` installs the component through
`Scaffold.appBar`, exercising the edge-to-edge integration. Its existing
route back behavior is supplied by the top bar's Flutter infrastructure adapter;
production hosts should pass a caller-owned leading slot when they require
curated iconography. A dedicated native preview is not yet provided.

## Test matrix

Widget and semantics coverage verifies public export/preferred size, missing
theme diagnostics, top/lateral safe insets, `Scaffold.appBar` single-inset
behavior, automatic/overridden overlay values, header semantics, 48px slots,
RTL, large text, and the high-contrast boundary contract. No golden baseline is
added yet because this component needs a reviewed authoritative baseline; that
visual coverage is an intentional follow-up.

## Decisions and known constraints

The component does not set app-wide edge-to-edge or system-navigation-bar
policy: that is host-owned. It deliberately does not use `NemoSurface`, whose
corner, padding, and relief semantics are inappropriate for a continuous page
canvas.
