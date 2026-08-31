# Contributing to Nemo UI

Thank you for helping improve Nemo UI. Public code, documentation, issues, and
pull requests are written in English.

## Workflow

Nemo UI uses GitHub Flow:

1. Open or choose an issue. Administrative-only changes may skip this step.
2. Create a branch named `<type>/<issue>-<slug>`, for example
   `feat/12-nemo-button`.
3. Use Conventional Commits.
4. Open a pull request that links the issue with `Closes #<issue>` or
   `Refs #<issue>`.
5. Resolve every conversation and pass all required checks.
6. Squash merge the pull request and delete its branch.

Supported branch types are `feat`, `fix`, `docs`, `chore`, and `refactor`.
Reserve `hotfix` for published-release emergencies.

## Local development

The repository pins Flutter 3.47.0 in [`.fvmrc`](.fvmrc). Install the SDK with
FVM before running checks:

```sh
fvm install
```

Use `fvm flutter ...` for every Flutter command. The local development
environment uses Homebrew FVM 4.3.0. Android Studio and IntelliJ users should
select `<repo>/.fvm/flutter_sdk` as the Flutter SDK. VS Code reads the committed
`.vscode/settings.json`, which sets `dart.flutterSdkPath` to `.fvm/flutter_sdk`.

## Local checks

Run the same checks enforced by continuous integration:

```sh
fvm dart format --output=none --set-exit-if-changed .
fvm flutter analyze
fvm flutter test --coverage
fvm dart run tool/check_coverage.dart coverage/lcov.info tool/coverage_baseline.json
fvm flutter pub publish --dry-run
(cd example && fvm flutter test && fvm flutter build web)
```

Run the example in Chrome with `cd example && fvm flutter run -d chrome`. Run
native previews from the repository root with `fvm flutter widget-preview start`.

The minimum supported Flutter version is 3.47.0.

## Golden tests

Deterministic component goldens are blocking checks. Verify them locally with:

```sh
fvm flutter test \
  test/components/nemo_button_test.dart \
  test/components/nemo_surface_golden_test.dart \
  test/components/nemo_switch_test.dart
```

Only update a baseline when the visual contract intentionally changes:

```sh
fvm flutter test --update-goldens test/components/nemo_surface_golden_test.dart
```

Review the resulting tracked PNG diff and include before-and-after evidence in
the pull request. A failing comparison writes visual diagnostics below the
test's `failures/` directory; CI uploads those diagnostics for failed golden
steps. Do not use `--update-goldens` to accept an unexplained regression.

Golden scenes pin their physical dimensions, device-pixel ratio, Android
platform, English locale, no text scaling, a fixed animation preference, and
the Ahem test font. Keep scene content glyph-free so font rasterization cannot
conceal a visual regression. Blurred shadows are excluded only where Skia host
rendering is non-deterministic; token and behavior tests still cover them.

## Public API

Only declarations exported by `lib/nemo_ui.dart` are public API. A public
declaration must have English Dart documentation and meaningful tests. Do not
import or export files under `lib/src` from consumer code.

## Component definition of done

Every component must include:

- unit or widget tests for its behavior and interactive states;
- semantics, keyboard, text-scaling, and reduced-motion coverage;
- a native Flutter Widget Previewer preview;
- an example-app scenario;
- a playbook at `doc/components/<component>.md` based on the component
  playbook template;
- golden coverage with an intentional-update evidence review when the component
  changes visual output.

See [the contribution playbook](doc/components/README.md) for the required
component documentation sections.

## Reporting security issues

Do not disclose security vulnerabilities in public issues. Follow
[SECURITY.md](SECURITY.md) instead.
