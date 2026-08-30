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

## Local checks

Run the same checks enforced by continuous integration:

```sh
dart format --output=none --set-exit-if-changed .
flutter analyze
flutter test --coverage
flutter pub publish --dry-run
(cd example && flutter test && flutter build web)
```

The minimum supported Flutter version is 3.47.0.

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
- golden coverage once the golden-test gate is active.

See [the contribution playbook](doc/components/README.md) for the required
component documentation sections.

## Reporting security issues

Do not disclose security vulnerabilities in public issues. Follow
[SECURITY.md](SECURITY.md) instead.
