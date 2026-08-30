# Foundation architecture

This document defines the stable architectural boundaries of Nemo UI's initial
foundation.

## Product boundary

Nemo UI is a Flutter design system with a modern, accessible neumorphic visual
language. Android, iOS, and web are first-class targets. Desktop portability is
preserved but is not part of the initial compatibility matrix.

The package uses Material as infrastructure without re-exporting Material or
forcing a `MaterialApp` wrapper. Host applications retain ownership of
navigation, state management, theme selection, locale selection, networking,
and application layout.

## Public API

`package:nemo_ui/nemo_ui.dart` is the only initial entry point. Files under
`lib/src` are implementation details and may change without notice. A symbol is
exported only after it has English Dart documentation and meaningful tests.

Nemo UI does not expose a global configuration singleton. Its independent
configuration seams can be composed and overridden in subtrees:

- `NemoThemeData` is an immutable `ThemeExtension` installed in
  `ThemeData.extensions`.
- `NemoAssetScope` provides a semantic `NemoAssetResolver`.
- `NemoLocalizations.delegate` integrates system-owned copy with Flutter
  localization.
- The host application owns the state that selects themes and locales.

## Token model

Tokens have three layers:

1. **Foundational tokens** define spacing, radii, dimensions, and duration
   scales.
2. **Semantic tokens** express roles such as surface, foreground, focus,
   success, error, and depth.
3. **Component tokens** map the semantic vocabulary to a component contract.

Components must not depend directly on arbitrary palette values or hard-coded
durations. Theme factories may derive a complete light, dark, or high-contrast
theme from a seed color; every derived token remains replaceable.

## Asset boundary

Flutter assets remain compile-time declarations. Components ask for semantic
asset identifiers instead of raw paths. A resolver may return a host-provided
image or widget and may fall back to a package-owned asset when one exists.

Remote loading, caching, retries, authentication, and privacy policy remain host
application responsibilities. The initial foundation contains no decorative
assets; assets are added only alongside a concrete component need with license
and package-size review.

## Localization boundary

Nemo UI owns only system copy such as loading, retry, error, and semantic
labels. Domain content is supplied by the caller. English and Spanish ship in
the initial localization catalog, with English as the unsupported-locale
fallback. Layouts must remain ready for right-to-left locales.

## Dependency policy

Runtime dependencies are restricted to the Flutter SDK,
`flutter_localizations`, and `intl` when required by localization generation.
New dependencies require a repeated use case, a license and maintenance review,
and an API-boundary check. Third-party types must not leak into Nemo UI's public
API without an explicit architecture decision.

Flutter SDK animation primitives are the default. Native Flutter Widget
Previewer is the preview surface, which establishes Flutter 3.47.0 as the
minimum supported version.
