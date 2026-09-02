# NemoField

## Purpose

`NemoField` is the canonical ordinary text-entry primitive. Use it when an
application needs tactile text editing that preserves Flutter controller,
focus, keyboard, change, and submission behavior. It is not a form framework,
validation engine, picker, masked input, autocomplete, or rich-text editor.

## Anatomy

The field consists of a persistent visible label, a recessed receiving area,
optional hint text, optional supporting or error text, and state evidence. Error
disabled, and read-only states add icons so that their meaning does not depend
on color or relief.

## API and examples

The bounded API passes conventional host integration through to Flutter:

```dart
NemoField(
  label: 'Email address',
  hintText: 'name@example.com',
  supportingText: 'Used for account notifications.',
  controller: emailController,
  focusNode: emailFocusNode,
  keyboardType: TextInputType.emailAddress,
  textInputAction: TextInputAction.next,
  onChanged: updateEmail,
  onSubmitted: submitEmail,
)
```

The host owns caller-provided controllers and focus nodes. Nemo creates and
disposes internal objects only when the corresponding argument is omitted.

## Variants and states

Resting, focused, filled, error, disabled, and read-only states share the same
geometry. Focus changes boundary weight; error combines text, an icon, and a
boundary; disabled fields cannot focus or edit and show an unavailable cue;
read-only fields remain focusable and selectable but show a lock cue. Filled
state is communicated by the entered value, not by changing the persistent
label.

Hovered, pressed, loading, and selected variants are not applicable to ordinary
text editing. Specialized input types remain out of scope.

## Tokens

The receiving area consumes the `recessed` material recipe; foundation spacing
and `radiusSmall`; component control height, horizontal padding, outline width,
and focus-ring width; semantic surface, foreground, muted foreground, outline,
focus-ring, and error colors; and semantic motion durations and curves. The
component exposes no painter, shadow, or material controls.

## Content and localization

The host owns label, hint, supporting, error, value, and semantic-label copy.
The label is always visible and does not become a placeholder. Directional
padding and Flutter text direction preserve RTL geometry and editing behavior.
Nemo adds no untranslated system-owned copy.

## Accessibility

The native editable semantics retain label, value, hint, enabled, read-only,
obscured, focus, selection, and editing actions. `semanticLabel` can replace the
visible label for assistive technology. Error text is a live-region update and
has redundant icon and boundary evidence. The field supports keyboard traversal,
external focus ownership, conventional editing shortcuts, enlarged text, and a
minimum 48 logical-pixel receiving area.

## Motion

Focus and validation boundaries use the resolved semantic motion contract.
When `MediaQuery.disableAnimations` is true, the same final visual state is
painted immediately with no transitional frames.

## Responsive behavior

The field fills the width offered by its parent and has no hard-coded maximum.
Labels and supporting/error text wrap rather than clip at narrow widths and at
large text scales. Host layout remains responsible for choosing a suitable
maximum form width.

## Preview

`example/previews/foundation_previews.dart` contains the native **Field states**
preview. The example catalog exposes the **NemoField** route implemented by
`example/lib/src/pages/field_catalog_page.dart`.

## Test matrix

Public widget tests cover text entry, controller changes, submission, caller and
internal focus ownership, safe disposal, persistent label/hint/support/error
content, enabled versus read-only semantics, RTL, enlarged text, light/dark/high
contrast themes, and reduced motion. The canonical field golden covers resting,
focused, filled, error, disabled, and read-only states under the deterministic
Android/DPR `1`/English/Ahem environment. Intentional baselines require tracked
PNG review and before-and-after pull-request evidence; local blurred captures are
diagnostic only.

## Decisions and known constraints

NemoField maps only to `NemoMaterial.recessed` and composes inside `NemoPage`
and `NemoSection` without depending on either. Business validation, initial
form values, formatting, autofill policy, and specialized inputs stay with the
host or future focused components. Host typography is inherited rather than
bundled by Nemo.
