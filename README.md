# unified_multi_step_form

A reusable Flutter package for state-preserving multi-step forms.

[![Pub Version](https://img.shields.io/pub/v/unified_multi_step_form.svg)](https://pub.dev/packages/unified_multi_step_form)
[![License](https://img.shields.io/badge/license-proprietary-red.svg)](LICENSE)
[![Flutter](https://img.shields.io/badge/flutter-compatible-blue.svg)](https://flutter.dev)
[![Tests](https://img.shields.io/badge/tests-passing-brightgreen.svg)](test/unified_multi_step_form_test.dart)

## Features

- Keeps step widgets mounted with `IndexedStack`
- Optional `PageView` mode
- Indicator styles: dots, numbers, and linear progress
- Page transitions: none, slide, fade, vertical
- Validates the current step before moving forward
- Validates all steps on final submit
- Supports async validation for server-side email/phone checks
- Supports an external controller for programmatic navigation
- Stays generic for company forms, KYC, signup, profile, and registration flows

## Screenshots

Add your own screenshots here to show the package UI in action.

| Step flow | Review screen |
| --- | --- |
| `example/screenshots/step-flow.png` | `example/screenshots/review-screen.png` |

Recommended captures:

- step indicators in dots, numbers, and linear mode
- PageView mode with slide transition
- fields, checkbox, switch, segmented choice, and image picker
- final review card

## Install

Add this package to your `pubspec.yaml`.

## Quick start

```dart
final step0Key = GlobalKey<FormState>();
final step1Key = GlobalKey<FormState>();

UnifiedMultiStepForm(
  indicatorType: IndicatorType.dots,
  transitionType: TransitionType.slide,
  usePageView: false,
  pages: [
    MultiStepFormPage(
      formKey: step0Key,
      title: 'Step 1',
      builder: (_) => const YourStepOneWidget(),
    ),
    MultiStepFormPage(
      formKey: step1Key,
      title: 'Step 2',
      builder: (_) => const YourStepTwoWidget(),
    ),
  ],
  onSubmit: () {
    // collect your payload here
  },
)
```

## Example controller usage

```dart
final controller = UnifiedMultiStepFormController();

controller.registerField(
  name: 'email',
  controller: TextEditingController(),
  stepIndex: 0,
  validator: (value) => value == null || value.isEmpty ? 'Required' : null,
);

controller.registerAsyncValidator(
  name: 'email',
  validator: (value) async {
    // call server here
    return null;
  },
);
```

## Common validators

Use `MultiStepFormValidators` for helper checks like:

- email
- URL
- CNIC
- NTN
- STRN
- phone
- ISO currency code

## Example app

Run the example from the repository root:

```bash
flutter run -t example/unified_multi_step_form_example.dart
```

The example contains a company-info style flow, while the package itself stays generic.

## Project structure

```text
lib/
  unified_multi_step_form.dart
  src/
    controllers/
    models/
    widgets/
    utils/
    theme/
example/
test/
CHANGELOG.md
README.md
pubspec.yaml
.gitignore
```

## Testing

Run package tests with:

```bash
flutter test
```

## Release checklist

- Keep app-specific UI inside `example/`
- Add tests for new controller or widget behavior
- Update `CHANGELOG.md`
- Verify `flutter analyze` and `flutter test`

## License

## Publishing to pub.dev

- Before publishing, ensure the following in your package root:
  - `pubspec.yaml` contains `name`, `description`, `version`, `environment` (Dart/Flutter SDK), `repository`/`homepage`, and `license`.
  - Include `README.md`, `CHANGELOG.md`, `LICENSE`, an `example/` folder, and tests under `test/`.
  - Do NOT have `publish_to: none` in `pubspec.yaml`.
  - Bump the package `version` for each new release and update `CHANGELOG.md`.

- Local checks (run from package root):

```bash
flutter analyze
flutter test
flutter pub publish --dry-run
```

- If the dry-run succeeds, publish interactively:

```bash
flutter pub publish
```

- Authentication: `flutter pub publish` is interactive and will open a browser to sign in the first time. For CI/automation, create an API token on pub.dev (Account → API access) and follow pub.dev documentation to configure your CI to use that token.

- After a successful publish:
  - Tag the release in your VCS (e.g., `git tag vX.Y.Z` and `git push --tags`).
  - Verify the package page on https://pub.dev and update any README screenshots or metadata as needed.

See pub.dev docs for advanced publishing / CI setup.

## License

See `LICENSE`.
