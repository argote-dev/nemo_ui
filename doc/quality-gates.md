# Quality gates

Nemo UI treats public API, behavior, accessibility, and visual output as parts
of one release contract.

## Pull request gates

Every pull request must pass:

1. Dart formatting with no changes required.
2. Flutter static analysis with no issues.
3. Unit and widget tests.
4. Semantic and accessibility assertions for interactive behavior.
5. Package coverage generation in LCOV format.
6. Example application tests and a web build.
7. `flutter pub publish --dry-run`.
8. English Dart documentation for exported APIs.
9. The component playbook, preview, and example checks when applicable.

CI runs on current Flutter stable and the minimum supported Flutter 3.47.0.
They are the same version at bootstrap, so CI uses one job; the matrix gains a
separate pinned current-stable entry when those versions diverge.
External GitHub Actions are pinned to full commit SHAs and updated through
Dependabot pull requests.

## Coverage policy

Coverage is reported but not percentage-gated during the foundation and first
three component implementations. After `NemoSurface`, `NemoButton`, and
`NemoSwitch` are complete, their result becomes the baseline. Subsequent pull
requests may not lower that baseline without an explicit, documented exception.

Coverage percentage alone is not sufficient: state behavior, semantics,
keyboard input, localization, text scaling, and reduced motion require targeted
assertions.

## Golden policy

Golden tests become blocking after `NemoSurface` and the visual token model are
stable. Goldens use deterministic fonts, platform, dimensions, device pixel
ratio, and theme configuration. Intentional updates require before-and-after
evidence in the pull request.

## Branch policy

After the repository bootstrap, `main` accepts changes through squash-merged
pull requests. Required checks, resolved conversations, a current branch, and
linear history are mandatory. Force pushes and branch deletion are disabled.
Human approval is added when the project has more than one active maintainer.
