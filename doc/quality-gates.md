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
9. Deterministic component golden baselines.
10. The component playbook, preview, and example checks when applicable.

CI runs on current Flutter stable and the minimum supported Flutter 3.47.0.
They are the same version at bootstrap, so CI uses one job; the matrix gains a
separate pinned current-stable entry when those versions diverge.
External GitHub Actions are pinned to full commit SHAs and updated through
Dependabot pull requests.

## Coverage policy

CI generates `coverage/lcov.info` and enforces the committed covered-line
ratchet:

```sh
fvm dart run tool/check_coverage.dart coverage/lcov.info tool/coverage_baseline.json
```

The checker sums every valid LCOV `LH` record and requires that total to be at
least `coveredLines` in the baseline. The initial verified baseline is 709
covered lines out of 797 found lines (88.958595%), produced at commit
`e81719d` with Flutter 3.47.0. `foundLines` and `coveragePercent` are recorded
as provenance; coverage percentage is not the gate.

A pull request that intentionally needs to lower the ratchet must document an
explicit exception before updating `tool/coverage_baseline.json`. Include:

1. The rationale for the lower covered-line total.
2. The before and after covered-line values.
3. Targeted assertion evidence for the behavior affected by the change.
4. The baseline update in the same pull request.

The exception does not replace required targeted assertions. State behavior,
semantics, keyboard input, localization, text scaling, and reduced-motion
behavior remain mandatory whenever applicable.

## Golden policy

Golden tests are blocking. The CI **Test deterministic golden baselines** step
executes the component baselines before the complete coverage suite. On a
comparison failure, CI uploads the generated failure images as an artifact.

Every golden scene fixes its physical dimensions, device pixel ratio (`1`),
Android platform, English locale, text scaling, a fixed animation preference,
test font (`Ahem`), and theme configuration. Golden scenes remain glyph-free, so visual
coverage does not depend on host text rasterization. Light, dark, and
high-contrast foundation states must be represented when a component consumes
foundation visual tokens.

Run the focused checks locally before opening a pull request:

```sh
fvm flutter test \
  test/components/nemo_button_test.dart \
  test/components/nemo_surface_golden_test.dart \
  test/components/nemo_switch_test.dart
```

An intentional change uses `fvm flutter test --update-goldens <test-file>`.
It must include the tracked PNG change plus reviewable before-and-after visual
evidence in the pull request. Never update a golden to accept an unexplained
diff. Blurred shadows may be neutralized only when host Skia rendering is
non-deterministic, with token and behavior coverage retained separately.

## Branch policy

After the repository bootstrap, `main` accepts changes through squash-merged
pull requests. Required checks, resolved conversations, a current branch, and
linear history are mandatory. Force pushes and branch deletion are disabled.
Human approval is added when the project has more than one active maintainer.
