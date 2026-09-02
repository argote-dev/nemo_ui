# Nemo UI

Nemo UI is an accessible, modern neumorphic design system for Flutter. It uses
soft depth as a tactile cue while preserving explicit contrast, focus,
semantics, and reduced-motion behavior.

Version `0.1.0` is the first usable release. It provides design tokens, dynamic
themes, scoped asset resolution, localization, semantic motion, native
previews, and an example catalog, together with `NemoSurface`, `NemoButton`,
and `NemoSwitch`.

## Requirements

- [FVM](https://fvm.app/) (the local development environment uses Homebrew FVM
  4.3.0)
- Flutter 3.47.0, pinned by [`.fvmrc`](.fvmrc)
- Dart 3.13.0 or newer (provided by the pinned Flutter SDK)

Install FVM with Homebrew if needed, then install the repository SDK:

```sh
brew install fvm
fvm install
```

Use `fvm flutter ...` for all Flutter commands in this repository. Android,
iOS, and web are first-class targets. The package remains portable to desktop,
but desktop is not part of the initial compatibility matrix.

## Installation

Add the package from pub.dev:

```yaml
dependencies:
  nemo_ui: ^0.1.0
```

Then import the single curated entry point:

```dart
import 'package:nemo_ui/nemo_ui.dart';
```

Files under `lib/src` are private implementation details.

## Configure a theme

Nemo UI integrates with Flutter through an immutable `ThemeExtension`. The
host application owns theme state and may build light, dark, or high-contrast
tokens from a brand seed.

```dart
final nemoTheme = NemoThemeData.light(
  seedColor: const Color(0xFF4F6EF7),
);

MaterialApp(
  theme: ThemeData(
    extensions: <ThemeExtension<dynamic>>[nemoTheme],
  ),
  localizationsDelegates: NemoLocalizations.localizationsDelegates,
  supportedLocales: NemoLocalizations.supportedLocales,
  localeResolutionCallback: NemoLocales.resolve,
  home: const HomePage(),
);
```

Read tokens within a widget with `NemoTheme.of(context)`. Theme factories accept
group-level overrides, and every token group supports immutable `copyWith`
customization.

## Surface

`NemoSurface` is a non-interactive semantic material primitive for visual
grouping. It provides four materials—recessed, base, raised, and floating—and
tokenized corner roles while leaving layout, semantics, focus, and gestures to
composition:

```dart
NemoSurface(
  material: NemoMaterial.raised,
  cornerRole: NemoCornerRole.panel,
  child: const Text('Surface content'),
)
```

See the [NemoSurface playbook](doc/components/nemo-surface.md) for its full
API, accessibility contract, visual constraints, and test matrix.

## Button

`NemoButton` is the system's single primary action. It supports pointer,
keyboard, and semantic activation; loading is system-owned and blocks repeated
activation:

```dart
NemoButton(
  onPressed: submit,
  isLoading: isSubmitting,
  child: const Text('Submit'),
)
```

See the [NemoButton playbook](doc/components/nemo-button.md) for its public
API and accessibility contract.

## Switch

`NemoSwitch` is a controlled binary selection with localized on/off semantics,
keyboard activation, and a 48px touch target:

```dart
NemoSwitch(
  value: notificationsEnabled,
  onChanged: (value) => setState(() => notificationsEnabled = value),
  child: const Text('Notifications'),
)
```

See the [NemoSwitch playbook](doc/components/nemo-switch.md) for its API,
accessibility contract, and token customization.

## Field

`NemoField` is the canonical recessed text-entry control. It keeps its label
visible and preserves Flutter controller, focus, keyboard, change, and submit
integration while adding explicit focus, error, disabled, and read-only cues:

```dart
NemoField(
  label: 'Email address',
  hintText: 'name@example.com',
  controller: emailController,
  textInputAction: TextInputAction.next,
  onChanged: updateEmail,
)
```

See the [NemoField playbook](doc/components/nemo-field.md) for its complete
editing, accessibility, motion, and visual-state contract.

## Page composition

`NemoPage` establishes a safe-area-aware base canvas and can compose a persistent
`NemoTopBar`; `NemoSection` supplies semantic hierarchy and tokenized spacing.
Scrolling, routes, typography, and interactions remain application-owned.

```dart
NemoPage(
  topBar: const NemoTopBar(title: Text('Settings')),
  child: ListView(
    children: const <Widget>[
      NemoSection(
        heading: Text('Notifications'),
        child: NotificationSettings(),
      ),
    ],
  ),
)
```

See the [NemoPage](doc/components/nemo-page.md) and
[NemoSection](doc/components/nemo-section.md) playbooks.

## Top bar

`NemoTopBar` is the persistent, edge-to-edge structural canvas for a page. It
owns the safe-area treatment and a local status-bar overlay style; applications
keep navigation, actions, and their semantics under caller control:

```dart
Scaffold(
  appBar: NemoTopBar(
    leading: const AccountBackAction(),
    title: const Text('Settings'),
    actions: const <Widget>[HelpAction()],
  ),
  body: const SettingsPage(),
)
```

`AccountBackAction` and `HelpAction` are application-owned placeholders: choose
icons from the host's curated iconography and keep their semantics and actions
with the caller.

When `leading` is absent, `NemoTopBar` follows Flutter's dismissible-route
convention and supplies a start-edge back control by default. Set
`automaticallyImplyLeading: false` to suppress it. Hosts that require curated
iconography should pass `leading` explicitly.

See the [NemoTopBar playbook](doc/components/nemo-top-bar.md) for edge-to-edge,
safe-area, accessibility, and token details.

## Provide dynamic assets

Nemo UI uses semantic asset slots instead of component-owned paths. Inject a
`NemoAssetResolver` around the subtree that needs host branding:

```dart
NemoAssetScope(
  resolver: const BrandAssetResolver(),
  child: const ProductExperience(),
);
```

The resolver may return host-provided image providers or widgets. Networking,
caching, and remote-asset policy remain application responsibilities.

## Motion and accessibility

Components consume semantic motion tokens instead of hard-coded durations.
`NemoMotionTokens.resolveFor(context)` automatically selects reduced motion
when `MediaQuery.disableAnimations` is enabled.

Every interactive component must expose explicit focus, semantics, keyboard,
contrast, text-scaling, and reduced-motion behavior. Depth is never the only
state indicator.

## Run the catalog and previews

```sh
cd example
fvm flutter run -d chrome
```

Run native Flutter Widget Previewer from the repository root:

```sh
fvm flutter widget-preview start
```

IDE users should configure the Flutter SDK as `<repo>/.fvm/flutter_sdk`; VS Code
can use the committed
[`.vscode/settings.json`](.vscode/settings.json) configuration.

## Project documentation

- [Foundation architecture](doc/architecture/foundation.md)
- [Tactile visual language](doc/architecture/tactile-visual-language.md)
- [Motion and micro-interaction policy](doc/motion.md)
- [Quality gates](doc/quality-gates.md)
- [Pilot accessibility audit](doc/accessibility-audit.md)
- [NemoSurface playbook](doc/components/nemo-surface.md)
- [NemoButton playbook](doc/components/nemo-button.md)
- [NemoSwitch playbook](doc/components/nemo-switch.md)
- [NemoField playbook](doc/components/nemo-field.md)
- [Component playbook template](doc/components/_template.md)
- [Foundation research](doc/research/flutter-design-system-foundation.md)
- [Contributing](CONTRIBUTING.md)
- [Security policy](SECURITY.md)

## License

Nemo UI is available under the [MIT License](LICENSE).

## Theme Contract v2 (0.2.0)

Nemo now composes four semantic materials—`recessed`, `base`, `raised`, and
`floating`—from one fixed top-left illumination model. `NemoSurface` accepts
`material` and `cornerRole`; the former five-depth API is deprecated as a
pre-1.0 migration aid. See the [Theme Contract](doc/architecture/theme-contract-v2.md),
[0.2.0 migration guide](doc/migration-0.2.0.md), and
[conformance audit](doc/theme-contract-v2-audit.md), and [calibration rationale](doc/research/theme-v2-calibration.md).
