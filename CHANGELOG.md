## 0.2.0

- **Breaking:** replaces five `NemoSurfaceDepth` appearances with four semantic `NemoMaterial` values and corner roles.
- Adds shared fixed-top-left illumination and bounded material/interaction recipes.
- Migrates Surface, Button, Switch, and the private catalog specimen to Theme Contract v2.
- Adds migration and conformance/perception audit evidence.

## Unreleased

### Added

- Add `NemoPage` and `NemoSection` composition primitives with safe-area-aware base canvas, semantic hierarchy, and tokenized spacing.
- Add `NemoTopBar`, an edge-to-edge, route-aware page top bar with safe-area,
  system-overlay, RTL, semantics, and high-contrast support.

### Changed

- **Breaking:** `NemoComponentTokens` now requires a `topBar` value of type
  `NemoTopBarTokens` when constructed directly.

## 0.1.0 - 2026-08-30

### Added

- Add `NemoSurface`, the non-interactive token-driven visual surface primitive.
- Add `NemoButton`, the accessible token-driven primary action.
- Add `NemoSwitch`, the accessible controlled binary-selection component.

### Changed

- **Breaking:** `NemoComponentTokens` now requires a `surface` value of type
  `NemoSurfaceTokens` when constructed directly.
- **Breaking:** `NemoComponentTokens` now requires a `button` value of type
  `NemoButtonTokens` when constructed directly.
- **Breaking:** `NemoComponentTokens` now requires a `switchControl` value of
  type `NemoSwitchTokens` when constructed directly.

## 0.0.1

* Establish the Nemo UI package foundation, including dynamic theme, asset,
  localization, motion, preview, example, quality, and governance contracts.
