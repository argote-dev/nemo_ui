# Technical foundation research — `nemo_ui`

**Date:** 2026-08-30
**Scope:** Initial architecture for a Flutter UI/design-system package with a modern, accessible neumorphic visual language.
**Method:** Primary-source research: Flutter/Dart APIs and documentation, W3C WCAG. Context7 was consulted first for current Flutter documentation.

## Current repository baseline

`nemo_ui` is the standard Flutter package template: one generated `Calculator` class, `flutter_lints`, and no Git repository, example application, asset declaration, localization, or preview tooling. The declared Dart SDK is `^3.12.0`, while the Flutter lower bound is very old (`>=1.17.0`); the latter must be aligned with the actual APIs selected before publication.

Flutter describes a minimal package as `pubspec.yaml` plus public code in `lib`, with at least `lib/<package-name>.dart`; its package template also treats `test/` as the package-test location. [Flutter package development guide](https://docs.flutter.dev/packages-and-plugins/developing-packages)

## Proposed baseline (recommended)

Create a Flutter **package**, not a plugin: no requested platform channel/native capability requires a plugin. Keep it lean and make all product-specific branding an injected configuration rather than a package fork.

| Concern | Recommendation | Why |
| --- | --- | --- |
| Public surface | `lib/nemo_ui.dart` as the sole curated barrel; implementation stays under `lib/src/`; optionally expose focused libraries (`nemo_ui_theme.dart`, `nemo_ui_l10n.dart`) only when they become independently stable. | A deliberately small import surface avoids accidentally making internals semver API. Flutter identifies `lib/<package-name>.dart` as the minimal public package library. |
| Design tokens/theme | Immutable `NemoThemeData extends ThemeExtension<NemoThemeData>` plus a `NemoTheme` lookup/helper; tokens include surfaces, shadows, gradients, border/focus, radii, spacing, typography, and motion. | `ThemeExtension` is the Flutter mechanism for theme extensions that can be retrieved from `ThemeData.extensions`; it requires `copyWith` and `lerp`, so light/dark or brand changes can animate coherently. [API](https://api.flutter.dev/flutter/material/ThemeExtension-class.html) |
| Runtime theme switching | Let host app replace `ThemeData`/`NemoThemeData` (for example via its state management); components read only context at build time. Offer explicit `NemoThemeData` parameters only where local override is valuable. | This preserves host ownership of state management and avoids a package-wide singleton. |
| Assets | Bundle only package-owned defaults in `assets/`; address them with package paths. Define semantic asset keys and a `NemoAssetResolver`/asset-set object that host apps can inject to override logos, illustrations, and icons. | Flutter asset declarations are compile-time `pubspec.yaml` manifest entries; they are not dynamically registered at runtime. `DefaultAssetBundle` can replace the bundle for a subtree (especially useful in tests), but it does not make undeclared assets ship. [Assets](https://docs.flutter.dev/ui/assets/assets-and-images) · [DefaultAssetBundle API](https://api.flutter.dev/flutter/widgets/DefaultAssetBundle-class.html) |
| Default component copy | Ship ARB source files and a generated `NemoLocalizations` delegate (`en` first, `es` next); expose the delegate and supported locales so hosts add them to `MaterialApp.localizationsDelegates`. Keep component strings behind localization methods, never literals in widgets. | Flutter localization uses `LocalizationsDelegate` to load locale resources, and generated localization APIs provide a delegate, `supportedLocales`, and context lookup. [Internationalization guide](https://docs.flutter.dev/ui/internationalization) · [delegate API](https://api.flutter.dev/flutter/widgets/LocalizationsDelegate-class.html) |
| Example | Add `example/` as a runnable catalog app, depending on `nemo_ui` by path. It should demonstrate theme switching, dynamic asset overrides, locale switching, text scale, disabled/reduced-motion modes, and each component state. | Flutter's package docs identify `example/` as an app that depends on and demonstrates a package. [Package development guide](https://docs.flutter.dev/packages-and-plugins/developing-packages) |
| Previews | Prefer Flutter's built-in **Widget Previewer** for component previews if this package raises its Flutter minimum to **3.47**; keep the runnable catalog example. Add **Widgetbook** only if interactive knobs/addons or shareable catalog workflow becomes a proven need. Neither belongs in the runtime package API. | Flutter Widget Previewer is stable as of Flutter 3.47 and supports annotations, theme/localization/wrapper/text-scale configuration. Widgetbook adds an opinionated interactive catalog with knobs/addons. |
| Motion | Use Flutter SDK primitives first: `Animated*`/implicit widgets for simple state changes and one shared motion-token set; use explicit `AnimationController` only for gesture/sequence-dependent behaviors. Defer `flutter_animate` until repeated composition demonstrates a real need. | Flutter documents implicit and explicit animation approaches; `ImplicitlyAnimatedWidget` animates changes to target values, which suits state feedback without lifecycle boilerplate. [Flutter animations](https://docs.flutter.dev/ui/animations) · [API](https://api.flutter.dev/flutter/widgets/ImplicitlyAnimatedWidget-class.html) |
| Accessibility | Add semantic labels/roles/hints and a visual focus treatment to every interactive primitive; make motion tokens collapse to zero/near-zero when `MediaQuery.disableAnimations` is true. | `Semantics` annotates its subtree for the accessibility system, and `disableAnimations` reports that platform accessibility features request disabled animations. [Semantics API](https://api.flutter.dev/flutter/widgets/Semantics-class.html) · [disableAnimations API](https://api.flutter.dev/flutter/widgets/MediaQueryData/disableAnimations.html) |

## Entry points and source layout

Recommended initial structure:

```text
lib/
  nemo_ui.dart                 # curated public exports only
  src/
    foundation/
      nemo_theme_data.dart
      nemo_motion.dart
      nemo_asset_resolver.dart
      nemo_localizations.dart
    components/
      button/
      surface/
    primitives/
assets/
  icons/
  illustrations/
l10n/
  nemo_en.arb
  nemo_es.arb
example/
  lib/main.dart
  test/
test/
  foundation/
  components/
```

Rules to adopt:

1. Every `src` import is private to the package. Public symbols receive documentation, stable names, and tests before export from the barrel.
2. Export data/contracts (`NemoThemeData`, `NemoAssetResolver`, `NemoLocalizations`) and components, but not render-object helpers, shadow math, or generated implementation details.
3. Avoid transitive-exporting Material wholesale. A component may use Material internally, but the Nemo API should remain intentional.
4. Version the public API semantically; breaking changes include exported type/member/signature and visual/behavioral contract changes that consumers cannot opt out of.

## Dynamic assets: a precise boundary

Flutter packages declare assets in the package `pubspec.yaml`, and package assets are loaded through their package-qualified keys. [Flutter assets guide](https://docs.flutter.dev/ui/assets/assets-and-images)

Therefore, "dynamic assets" should mean **runtime selection/override of an already available source**, not runtime registration of arbitrary bundled paths:

```dart
abstract interface class NemoAssetResolver {
  ImageProvider<Object>? imageFor(NemoAsset asset, BuildContext context);
  Widget iconFor(NemoIcon icon, BuildContext context);
}
```

* Resolver returns a host-provided `ImageProvider`, `Widget`, or `null` (fall back to the package asset).
* Package defaults use semantic enum/key names—not raw filenames in components.
* Provide the resolver with a scope/inherited widget or the central theme/configuration object; avoid a static global resolver so multiple themed subtrees work.
* Treat remote images as host-app responsibility. Network fetching, caching, error states, and privacy policy are app concerns—not a design-system default.
* For tests, use `DefaultAssetBundle` to substitute an `AssetBundle` for a subtree; Flutter explicitly provides it so widgets can obtain the closest bundle rather than the global root bundle. [API](https://api.flutter.dev/flutter/widgets/DefaultAssetBundle-class.html)

## Dynamic theme: tokens, not only colors

A neumorphic system needs elevation-like values that Material's stock `ColorScheme` cannot express. The extension should have enough tokens to generate all visual states:

```dart
@immutable
final class NemoThemeData extends ThemeExtension<NemoThemeData> {
  const NemoThemeData({
    required this.surface,
    required this.highlightShadow,
    required this.lowlightShadow,
    required this.focusRing,
    required this.radii,
    required this.spacing,
    required this.motion,
  });
  // copyWith + lerp required
}
```

Keep `NemoThemeData` value-like and immutable. `lerp` should interpolate colors, dimensions, and motion durations; for non-interpolable values choose the nearer endpoint. Build component-specific state from `WidgetState`/controller state and theme tokens rather than hard-coding dark/light shadows.

Provide three first-class modes: **soft/light**, **soft/dark**, and **high-contrast**. High contrast is not just a darker shadow; it needs an unambiguous border/focus indicator and text/icon foreground colors that meet contrast requirements.

## Localization model

Localize only strings owned by the UI system: common button labels, loading/error/retry text, semantics labels, validation labels, and date/quantity format messages. Domain copy remains host-owned and should be passed in by the caller.

* Make the locale explicit through Flutter `Localizations` and generate ARB-backed APIs.
* The package must export its delegate/supported locales; the host merges them with its own delegates, rather than the library attempting to create a `MaterialApp`.
* Offer localized defaults plus caller override (`NemoButton(label: ...)`); the override is already-resolved text and is not retranslated.
* Test English, Spanish, an unsupported-locale fallback, RTL layout readiness, and all semantics labels.

## Example and previews

**Example app acceptance scenarios:**

* toggles the three visual modes and brand seed/token set;
* swaps default/package assets for a mock host resolver;
* changes locale and text scale;
* exposes default, hover, focus, pressed, disabled, loading, selected, error, and reduced-motion states;
* runs on at least Android/iOS/Web during development before declaring those supported.

Use the example as an executable integration test target. Use Flutter's Widget Previewer for individual component previews when the Flutter minimum is 3.47 or later; keep preview declarations in a preview-only/tool directory and make them exercise public imports exclusively—this catches accidental `src` coupling. Add Widgetbook only when interactive knobs/addons, a dedicated catalog navigation model, or hosted sharing materially benefits the team.

## Flutter Widget Previewer versus Widgetbook (fact check)

**Current status:** Flutter's native Widget Previewer is **stable as of Flutter 3.47**. It renders components independently in an IDE or browser (`flutter widget-preview start`) and discovers `@Preview` annotations from `package:flutter/widget_previews.dart`. It supports named/grouped previews, artificial size, text scale, wrapper injection, themes/brightness, localization configuration, and multi-preview/custom annotations. [Official Flutter Widget Previewer guide](https://docs.flutter.dev/tools/widget-previewer)

**Requirements and limits:** It requires the project/toolchain to use Flutter 3.47+, so the present `flutter: ">=1.17.0"` lower bound is incompatible and must be raised if native previews are chosen. Previews must be a top-level/static function returning `Widget`/`WidgetBuilder`, or a public no-required-argument widget constructor/factory. Callback arguments in annotations must be public constants. The previewer is Web-based: native plugins, `dart:io`, and `dart:ffi` APIs cannot be invoked; assets loaded through `dart:ui` must use package-qualified paths; and its IDE view supports only one project/Pub workspace at a time. [Official restrictions](https://docs.flutter.dev/tools/widget-previewer#restrictions-and-limitations)

**What Widgetbook adds:** Widgetbook is a third-party open-source sandbox with interactive **knobs** for hard-to-reach component states and **addons** for configurations such as dark mode and locale, plus a catalog/share workflow. [Widgetbook official documentation](https://docs.widgetbook.io/)

**Decision rule:**

* Choose **native Widget Previewer** as the default for nemo_ui if the package can set `environment.flutter: '>=3.47.0'` (after validating the actual stable SDK used by CI). It minimizes dependencies and directly covers Nemo's theme, locale, text-scale, size, and wrapper matrices.
* Choose **Widgetbook** instead/also only if the team explicitly needs interactive property knobs, catalog navigation, hosted sharing, or must support a Flutter floor below 3.47.
* In either case, retain the runnable `example/`; previews supplement it and are not a replacement for tests or a real integration app.

## Animation and micro-interaction policy

No animation package is necessary in v0.1. Flutter built-ins cover state transitions and controllers. If later added, an animation package must be dev/implementation-only and must not leak package-specific controller types into Nemo's public API.

Adopt a small token scale, with exact values validated by usability testing rather than copied blindly:

| Event | Intended feedback | Motion policy |
| --- | --- | --- |
| Press | Surface compresses 1–2 px; highlight/lowlight swap modestly; optional low-opacity ink/fill | immediate response, short settle; never move surrounding layout |
| Hover/focus | Crisp focus ring/border plus a small shadow-depth change | focus must remain visible without relying on color or animation |
| Toggle/select | Crossfade/depth transition and state icon/label change | preserve final state; do not loop |
| Loading | Static accessible label plus restrained progress animation | reduced-motion version uses non-moving state/progress indication |
| Success/error | Color plus icon/text and a single small confirmation transition | never use color alone; avoid exaggerated bounce |

**Reduced motion is a required alternate behavior.** WCAG 2.2 SC 2.3.3 requires a mechanism to disable motion animation triggered by interaction unless the animation is essential; `MediaQuery.disableAnimations` gives Flutter components the platform preference. [W3C understanding document](https://www.w3.org/WAI/WCAG22/Understanding/animation-from-interactions.html) · [Flutter API](https://api.flutter.dev/flutter/widgets/MediaQueryData/disableAnimations.html)

## Modern neumorphism: constraints and opportunity

The main neumorphism failure mode is low-contrast, depth-only affordance: a control can look decorative or unavailable. Do not let raised/inset shadows be the only signal for interactive state.

* Contrast text against its actual surface at **4.5:1** minimum (3:1 only for large text); specify both foreground and background colors. [WCAG 2.2 SC 1.4.3](https://www.w3.org/WAI/WCAG22/Understanding/contrast-minimum.html)
* Use a visible focus ring/border, semantic role/label, and state change beyond shadow direction. `Semantics` is the Flutter mechanism that passes those annotations into the accessibility system. [Flutter Semantics API](https://api.flutter.dev/flutter/widgets/Semantics-class.html)
* Use soft shadows as a **texture/elevation cue**, not the information-bearing contrast. Every component needs a high-contrast fallback token set.
* Combine the soft shell with a contemporary, restrained “tactile” layer: variable-radius corners, a thin tonal stroke, concise typography, selective gradients/noise (only if it does not compromise contrast), and composited rather than excessive blurred shadows for performance.
* Design and test all interactive states. A default-only component catalog will falsely make neumorphism look complete.

## Quality gates and CI

Start with a GitHub Actions PR workflow that uses a pinned Flutter stable version and runs:

1. `dart format --output=none --set-exit-if-changed .`
2. `flutter analyze`
3. `flutter test`
4. `flutter test --coverage` (upload/report coverage; set a numeric ratchet only after a baseline exists)
5. `flutter pub publish --dry-run` for publishability, package metadata, and accidental-file checks.

Add widget tests for all interaction/semantics states immediately; Flutter documents widget tests as a way to test individual widgets and their interactions, while its testing overview separates unit, widget, and integration tests. [Widget test introduction](https://docs.flutter.dev/cookbook/testing/widget/introduction) · [Testing overview](https://docs.flutter.dev/testing/overview)

Add golden tests after the first primitives stabilize, with deterministic fonts, platform, device-pixel ratio, and visual review of intentional updates. Run the example app’s smoke/widget tests in CI; add integration tests only for host-level navigation and platform behavior.

Recommended repository hygiene alongside CI: Git initialization, protected main branch, conventional/semantic commits if desired, CODEOWNERS only when there is a team, issue/PR templates, `LICENSE` replaced with an actual license, `homepage`/repository/issue-tracker metadata, a meaningful package description, and a release checklist (CHANGELOG, version, dry-run publish, docs, example screenshots).

## Decisions to confirm before implementation

1. Is the package open source on pub.dev from the first release, and which license/repository URL should metadata use?
2. Is the primary supported platform mobile only, or mobile + web + desktop? This drives example and visual-test matrix.
3. Are Material components an integration dependency, or should Nemo expose mostly framework-agnostic widgets with optional Material adapters?
4. Should `es` ship in v0.1 alongside `en`, or should English plus localization infrastructure land first?
5. Does the product want an opinionated `NemoApp` convenience wrapper, or a composable library only? The latter is safer for a design system.
6. Is the visual direction “soft neumorphism with accessible contrast guardrails” acceptable, rather than pure shadow-only neumorphism?

## Source index

* [Flutter: Developing packages & plugins](https://docs.flutter.dev/packages-and-plugins/developing-packages)
* [Flutter: Adding assets and images](https://docs.flutter.dev/ui/assets/assets-and-images)
* [Flutter: Internationalizing apps](https://docs.flutter.dev/ui/internationalization)
* [Flutter API: ThemeExtension](https://api.flutter.dev/flutter/material/ThemeExtension-class.html)
* [Flutter API: DefaultAssetBundle](https://api.flutter.dev/flutter/widgets/DefaultAssetBundle-class.html)
* [Flutter API: LocalizationsDelegate](https://api.flutter.dev/flutter/widgets/LocalizationsDelegate-class.html)
* [Flutter API: Semantics](https://api.flutter.dev/flutter/widgets/Semantics-class.html)
* [Flutter API: MediaQueryData.disableAnimations](https://api.flutter.dev/flutter/widgets/MediaQueryData/disableAnimations.html)
* [Flutter: Introduction to animations](https://docs.flutter.dev/ui/animations)
* [Flutter API: ImplicitlyAnimatedWidget](https://api.flutter.dev/flutter/widgets/ImplicitlyAnimatedWidget-class.html)
* [Flutter: Widget test introduction](https://docs.flutter.dev/cookbook/testing/widget/introduction)
* [Flutter: Testing overview](https://docs.flutter.dev/testing/overview)
* [W3C WCAG 2.2: Contrast (Minimum)](https://www.w3.org/WAI/WCAG22/Understanding/contrast-minimum.html)
* [W3C WCAG 2.2: Animation from Interactions](https://www.w3.org/WAI/WCAG22/Understanding/animation-from-interactions.html)
