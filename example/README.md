# Nemo foundation catalog

This runnable catalog demonstrates the public foundation components in `nemo_ui`.

## Ownership boundaries

**Nemo-owned:** `NemoSurface`, `NemoButton`, `NemoSwitch`, `NemoField`, `NemoPage`, `NemoSection`, and `NemoTopBar`, including their tactile rendering, semantic control behavior, focus treatment, 48px control targets, localized control announcements, and motion behavior.

**Host/catalog infrastructure:** `MaterialApp`, routing, the example-only settings model, catalog layout, headings, descriptive copy, navigation destinations, and the three canonical scenes (work dashboard, settings, catalog inspector). Material is retained only as host and navigation infrastructure; the catalog does not use Material controls to present Nemo controls.

**Typography:** the host owns the `TextTheme`, heading hierarchy, catalog copy, and selected text scale. Nemo components inherit that host typography while owning their own control and surface presentation.
