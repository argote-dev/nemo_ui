# Theme Contract v2 conformance and perception audit

**Scope:** `NemoSurface`, `NemoButton`, `NemoSwitch`, and the private example
catalog shell for 0.2.0. This is executable/repository evidence, not a claim of
assistive-technology or human perceptual certification.

| Subject | Role/material and budget | State/accessibility evidence | Canonical evidence |
| --- | --- | --- | --- |
| Surface | non-actionable; recessed/base/raised/floating; one local jump | descendant semantics, contrast, large text, reduced-motion final state | light/dark/HC composed Surface test scenes |
| Button | raised at rest, recessed while pressed | merged button role, keyboard/mouse/touch, loading/disabled/focus and visible border/text evidence | button state matrix in light/dark/HC |
| Switch | recessed track plus raised thumb; selected recipe on | switch role/value, position/check-minus/label, keyboard/mouse/touch/RTL | switch state matrix in light/dark/HC |
| Catalog | one base canvas with receiving/action/floating specimens | headings/routes/settings, responsive and large-text scrolling | catalog narrow/wide/theme/reduced-motion tests |

## Perceptual review questions

In light, dark, and shadow-free high contrast scenes, reviewers can identify:
1. **Actionable:** raised buttons, focus rings, labels and pointer/keyboard
   affordances—not only shadows or accent.
2. **Selected:** switch thumb position, check/minus indicator, localized value,
   tonal/border treatment and semantics—not only color.
3. **Above/below canvas:** explicit material tone/boundary and top-left polarity;
   high contrast uses boundaries rather than shadows.

At enlarged text scale, controls expand/scroll without clipping and retain their
48 logical-pixel target. Automated tests cover the contract; manual VoiceOver,
TalkBack, and native platform smoke review remain release-maintainer work.

## Release evidence

The pinned Ubuntu 24.04 / Flutter 3.47.0 run
[33467268448](https://github.com/argote-dev/nemo_ui/actions/runs/33467268448)
completed the 0.2.0 repository gates on 2026-09-01:

- formatting and analysis passed with no issues;
- 21 focused deterministic-golden tests and all three canonical baselines
  passed;
- the full package suite passed 48 tests with coverage, and the covered-line
  ratchet accepted the LCOV result;
- the example passed 6 widget tests and the web platform smoke build completed;
- `flutter pub publish --dry-run` completed with zero warnings.

The canonical PNGs came from the preceding pinned Ubuntu failure artifact and
were visually reviewed before the successful rerun. macOS comparisons remain
diagnostic and must not replace authoritative raster files. VoiceOver, TalkBack,
device smoke review, release publication, and pub.dev publication remain manual
maintainer actions; automated evidence does not claim human certification.
