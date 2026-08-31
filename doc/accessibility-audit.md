# Pilot accessibility audit

This audit records the accessibility contract for the `0.1.0` pilot set:
`NemoSurface` (#3), `NemoButton` (#4), and `NemoSwitch` (#5). It closes the
implementation evidence requested by [#8](https://github.com/argote-dev/nemo_ui/issues/8), subject to the release process closing its linked finding.

## Scope and outcome

The components use semantic roles and actions, explicit focus treatment,
48-logical-pixel minimum interactive height, tokenized high-contrast styling,
and reduced-motion behavior. They do not use shadow, color, or animation as the
sole signal of meaning or state.

The release-blocking finding [#19](https://github.com/argote-dev/nemo_ui/issues/19)
was fixed on this branch. `NemoButton` now merges caller-owned visible text into
one named, focusable button semantics node; an explicit `semanticLabel`
overrides descendant semantics without duplicate announcements. The regression
is covered in both LTR and RTL widget tests.

## Component matrix

| Check | NemoSurface | NemoButton | NemoSwitch |
| --- | --- | --- | --- |
| Semantics | Non-interactive by contract: adds no role, action, or focus target; descendants remain available. | Exposes button role, enabled state, tap action, loading live region, and one accessible name. | Exposes merged toggled, enabled, value, label, focus, and tap semantics. |
| Keyboard and focus | Not applicable; compose an interactive control separately. | Enter and Space activate when focused; disabled/loading controls leave traversal. A tokenized focus ring is painted. | Enter and Space request the opposite value; disabled controls leave traversal. The track uses an explicit focus outline. |
| Target size | Not applicable. | Tokenized minimum height is 48 logical pixels. | Tokenized minimum height is 48 logical pixels. |
| Text scaling | `Clip.none` is the default; caller content and directional padding are preserved. | Long caller labels are tested at 2x scaling and may grow the control. | Long caller labels are tested at 2x scaling and may grow the control. |
| Nemo-owned EN/ES copy | None; all content is caller-owned. | Loading is Nemo-owned and localized (`Loading` / `Cargando`). | On/off state is Nemo-owned and localized (`On` / `Off`; `Activado` / `Desactivado`). |
| RTL readiness | Directional padding and 2x text scale are covered under RTL; decorative lighting intentionally remains physical top-left. | Arabic caller text is covered under RTL for bounds, button semantics, and Space activation. | Arabic caller text is covered under RTL for bounds, switch semantics, and Space toggling. |
| High contrast | Shadows collapse while explicit tone and outline categories remain distinct. | Uses semantic foreground, outline, and focus tokens; high-contrast golden coverage is present. | Uses outline and focus tokens; state additionally has position and check/minus indicators; high-contrast golden coverage is present. |
| State signals | Relief is decorative and never conveys state or meaning alone. | Semantics, enabled state, text/loading affordance, and focus ring supplement color and shadow. | Position, check/minus icon, outline, semantics, and localized value supplement color and shadow. |
| Reduced motion | Tokenized depth transitions resolve immediately. | Feedback duration resolves to zero; loading uses a static hourglass instead of a spinner. | Track and thumb transitions resolve immediately. |

## Copy ownership

Nemo localizes only system-owned component copy. Callers own domain labels,
button children, switch labels, and catalog prose. Consequently, the example
catalog's Spanish setting demonstrates Nemo-owned system copy (for example,
`Cargando` and switch state values); it does not translate caller-owned catalog
headings or descriptions. Applications adopting Nemo must localize that
caller-owned copy themselves.

## Verification evidence

### Automated scenarios

The component widget and semantics suites cover pointer and keyboard input,
focus, disabled/loading behavior, text scaling, localization, high contrast,
reduced motion, and deterministic golden states:

```sh
fvm flutter test \
  test/components/nemo_button_test.dart \
  test/components/nemo_surface_test.dart \
  test/components/nemo_surface_golden_test.dart \
  test/components/nemo_switch_test.dart
fvm flutter analyze

cd example
fvm flutter test
fvm flutter build web
```

`example/test/foundation_catalog_test.dart` exercises catalog navigation,
persisted global configuration (including Spanish), responsive layout, and the
maximum text-scale scenario. CI runs the example tests and web build; see
[quality gates](quality-gates.md).

### Native launch smoke evidence

On 2026-08-30, `fvm flutter run --no-resident` launched the example
successfully on these targets:

- Android 17 emulator (`emulator-5554`)
- iPhone 17 iOS 26.5 simulator
- Chrome 151

These launches verify that the catalog can start on Android, iOS, and web. They
are not a substitute for the automated scenario assertions above.

## Residual limits

This audit is based on native launch smoke evidence and automated Flutter
semantics/widget scenarios. It does **not** claim manual TalkBack, VoiceOver,
or other assistive-technology certification. Platform assistive-technology
reviews remain appropriate before a broader release or when host composition
adds custom semantics, focus order, or caller-owned copy.
