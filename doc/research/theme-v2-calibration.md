# Theme v2 calibration board

The disposable calibration board is represented by the canonical composed
material scenes: each light/dark scene places base, recessed, raised and
floating together, and the high-contrast scene proves their shadow-free
substitution. It is intentionally test/support evidence, not a package widget.

## Chosen bounds and rationale

Recipes are bounded to opacity 0–1 and blur/offset multipliers 0–2. Base has no
shadow; recessed uses inverse clipped edges at 0.62 blur / 0.5 offset and 0.38
shadow; raised uses 0.78 / 0.68 / 0.28; floating uses 1 / 1 / 0.42. Tonal and
outline opacity rise with hierarchy but remain restrained, preventing a
Material-card or accent-fill reading. The shared vector is physical top-left;
inset reverses polarity. High contrast sets shadow to zero and outlines to one.

These values were selected side-by-side to make receiving areas, actionable
planes and transient prominence distinguishable while preserving a quiet base
canvas. They are recipes, not arbitrary component-local tuning knobs. Review
asks what is actionable, selected, and above/below the canvas at light, dark,
high contrast and enlarged text.
