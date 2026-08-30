# Motion and micro-interaction policy

Nemo UI uses motion to communicate tactile state, hierarchy, and continuity.
Motion must be restrained, interruptible, and accessible. It must never be the
only signal for a state change.

## Semantic motion scale

Components consume semantic tokens rather than literal durations:

- **instant** — immediate visual acknowledgement;
- **quick** — hover, focus, and press feedback;
- **standard** — selection and ordinary state transitions;
- **emphasized** — infrequent, important transitions.

The theme also provides standard, accelerate, and decelerate curves. Exact
values belong to the theme and may evolve without changing component code.

## Interaction language

| Interaction | Visual response | Constraint |
| --- | --- | --- |
| Press | Compress the surface by roughly 1–2 logical pixels and modestly change depth or tonal fill. | Never move surrounding layout. |
| Hover | Adjust depth or tonal stroke subtly. | Hover is supplemental and cannot hide focus. |
| Focus | Show a crisp, high-contrast focus ring. | Must remain visible without animation or color alone. |
| Select or toggle | Crossfade or move a state indicator while changing semantics. | Final state must remain unambiguous and static. |
| Loading | Use restrained progress plus localized semantics. | A non-moving alternative must communicate progress. |
| Success or error | Combine icon or text, color, and one small transition. | Never use color or motion alone. |

Springs, bounce, looping decoration, and large spatial transitions are not the
default Nemo UI language. They require a component-specific justification.
Haptic feedback is opt-in through host-controlled policy or callbacks; visual
components do not trigger device effects automatically.

## Reduced motion

Every animated component reads the platform preference represented by
`MediaQuery.disableAnimations`. Reduced motion selects an alternate transition,
not merely an arbitrary faster duration. Spatial movement and looping effects
collapse to a static state, crossfade, or immediate update as appropriate.

The example and previews must expose reduced-motion scenarios. Tests verify the
chosen semantic motion token or final state rather than relying on wall-clock
timing.

## Required interactive states

Interactive component playbooks cover every applicable state: resting,
hovered, focused, pressed, disabled, loading, selected, and error. Each state
defines visual, semantic, keyboard, localization, and reduced-motion behavior.
