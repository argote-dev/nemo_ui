# Theme Contract v2 conformance and perception audit

**Scope:** `NemoSurface`, `NemoButton`, `NemoSwitch`, `NemoField`, `NemoPage`,
`NemoSection`, `NemoTopBar`, and the private example catalog's three canonical
scenes. This is executable/repository evidence, not a claim of
assistive-technology or human perceptual certification.

## Conformance checklist

| Subject | Role/material and budget | State/accessibility evidence | Canonical evidence |
| --- | --- | --- | --- |
| Surface | non-actionable; recessed/base/raised/floating; one local jump | descendant semantics, contrast, large text, reduced-motion final state | light/dark/HC composed Surface test scenes |
| Button | raised at rest, recessed while pressed | merged button role, keyboard/mouse/touch, loading/disabled/focus and visible border/text evidence | button state matrix in light/dark/HC |
| Switch | recessed track plus raised thumb; selected recipe on | switch role/value, position/check-minus/label, keyboard/mouse/touch/RTL | switch state matrix in light/dark/HC |
| Field | recessed receiving well only | text-field role, persistent label, error/disabled/read-only, keyboard, large text | field state matrix in light/dark/HC |
| Page | one base canvas; no material jump of its own | safe-area, directional padding, wide/narrow reflow | page dashboard/settings goldens |
| Section | hierarchy only; no material | semantic header, child focus order, enlarged text wrap | covered by page and scene goldens |
| Top bar | persistent structural canvas; never floating | heading, implied back, RTL start-edge, high-contrast boundary | top-bar widget tests |
| Work dashboard | NemoPage canvas, recessed inbox, restrained raised actions, one overlay confirmation | headings, keyboard capture, reduced-motion final state, RTL column swap | `nemo_dashboard_{light,dark,high_contrast}.png` |
| Settings | page/section grammar, recessed field, binary control, live status, one raised action island | field+switch+save traversal, status text, 2.0× reflow | `nemo_settings_{light,dark,high_contrast}.png` |
| Catalog inspector | state matrices, labeled Canvas/fragment/glass comparison, one glass overlay | overlay semantics, focus restore, Escape/scrim dismiss, tap-target guidelines | `nemo_catalog_inspector_{light,dark,high_contrast}.png` |

## Renderer adoption

| Finish | Status | Evidence |
| --- | --- | --- |
| Canvas | **Default.** Mandatory accessible baseline for every material. | Component goldens, scene goldens, high-contrast fallback, portable layout. |
| Fragment | **Experimental, opt-in, default-off.** Not eligible for default use. | No device profile evidence. Catalog shows it only as a labeled comparison card. |
| Tactile glass | **Opt-in overlay finish** for sufficiently large `NemoMaterial.floating` planes. Not a fifth material and not a persistent-card default. | Overlay behavior tests and glass goldens. High contrast and small surfaces stay opaque Canvas. No device profile evidence for widening adoption. |

A renderer finish cannot become default because a golden looks different. Follow
the [profile procedure](architecture/progressive-surface-renderer.md) before any
adoption change. This capstone recorded no p95 UI/GPU, first-use jank, memory,
or energy numbers; those remain unmeasured on target devices.

## Perceptual review questions

In light, dark, and shadow-free high contrast scenes, reviewers should answer:
1. **Actionable:** which raised controls can be pressed, and is that evident without shadow?
2. **Selected:** which switch or value is on, using position/icon/label rather than color alone?
3. **Receiving:** which recessed well accepts input or queued work?
4. **Above/below canvas:** which plane is the page, which is a local island, and which transient overlay sits above?

Goldens are regression evidence for those questions. They are not human visual
approval or a usability certification.

At enlarged text scale, controls expand or scroll without clipping and retain
their 48 logical-pixel target. Automated tests cover the contract. Manual
VoiceOver, TalkBack, and native platform smoke review remain release-maintainer
work.

## Accessibility guideline coverage

Example scene tests run `androidTapTargetGuideline` and
`labeledTapTargetGuideline` on the three canonical routes. Flutter's
`textContrastGuideline` is not asserted on these composed Canvas scenes: custom
painted materials make that checker unreliable, and post-overlay contrast stays
a component-level Theme Contract requirement. Semantics, keyboard, RTL,
reduced motion, and overlay dismissal are asserted directly.

## Release evidence

The pinned Ubuntu 24.04 / Flutter 3.47.0 run
[33467268448](https://github.com/argote-dev/nemo_ui/actions/runs/33467268448)
completed the 0.2.0 repository gates on 2026-09-01. Scene goldens added by #49
must be generated and reviewed on the same canonical runner; macOS comparisons
remain diagnostic and must not replace authoritative raster files.
