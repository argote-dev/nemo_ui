# Nemo foundation catalog

This runnable catalog demonstrates the public foundation components in `nemo_ui`.

## Ownership boundaries

**Nemo-owned:** `NemoSurface`, `NemoButton`, and `NemoSwitch`, including their tactile rendering, semantic control behavior, focus treatment, 48px control targets, localized control announcements, and motion behavior.

**Host/catalog infrastructure:** `MaterialApp`, `Scaffold`, `AppBar`, routing, the example-only settings model, catalog layout, headings, descriptive copy, navigation destinations, and the composed workspace scenario. Material is retained only as host and navigation infrastructure; the catalog does not use Material controls to present Nemo controls.

**Typography:** the host owns the `TextTheme`, heading hierarchy, catalog copy, and selected text scale. Nemo components inherit that host typography while owning their own control and surface presentation.
