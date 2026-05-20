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

Add your screenshots here to show the package UI in action. Keep them in `example/screenshots/` so the README stays tidy.

<table>
  <tr>
    <td align="center">
      <img src="example/screenshots/Screenshot_2026-05-20-18-00-21-147_com.example.unified_multi_step_form_example.jpg" alt="Step 1 screenshot" width="250" />
    </td>
    <td align="center">
      <img src="example/screenshots/Screenshot_2026-05-20-18-00-42-251_com.example.unified_multi_step_form_example.jpg" alt="Step 2 screenshot" width="250" />
    </td>
    <td align="center">
      <img src="example/screenshots/Screenshot_2026-05-20-18-04-50-435_com.example.unified_multi_step_form_example.jpg" alt="Review screenshot" width="250" />
    </td>
  </tr>
  <tr>
    <td align="center"><strong>Step flow</strong></td>
    <td align="center"><strong>Form details</strong></td>
    <td align="center"><strong>Review screen</strong></td>
  </tr>
</table>

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

## API — `UnifiedMultiStepForm`

Use `UnifiedMultiStepForm` as the shell that hosts your `MultiStepFormPage` pages. Key constructor parameters:

- `pages` (List<MultiStepFormPage>): The list of steps shown in order. Each `MultiStepFormPage` contains a `GlobalKey<FormState>` and a `builder` that returns the step UI.

- `controller` (UnifiedMultiStepFormController?): Optional controller for programmatic navigation and registering field values/validators. If omitted, the widget creates its own controller.

- `onSubmit` (VoidCallback?): Called after the final step is validated (including async validators) and the form is ready to submit.

- `onStepChanged` (ValueChanged<int>?): Callback when the active step index changes. Useful to update surrounding UI.

- `initialStep` (int): Zero-based initial step index to start the form on.

- `padding` (EdgeInsetsGeometry): Padding applied around each step's body (default: horizontal 16).

- `indicatorActiveColor` / `indicatorInactiveColor` (Color?): Colors for active/inactive step indicators.

- `indicatorType` (IndicatorType): Indicator style — `dots`, `numbers`, or `linear`.

- `usePageView` (bool): When true, the widget renders steps with `PageView` (swipeable, with transitions). When false (default), it uses `IndexedStack` to preserve widget state while hiding inactive pages.

- `transitionType` (TransitionType): Controls the `PageView` animation style when `usePageView` is true. Options: `none`, `slide`, `fade`, `vertical`.

- `transitionDuration` (Duration): Duration of page transition animations (default 300 ms).

- `nextButtonText`, `previousButtonText`, `submitButtonText` (String): Override the default button labels.

Example snippet:

```dart
final step0Key = GlobalKey<FormState>();
final step1Key = GlobalKey<FormState>();

UnifiedMultiStepForm(
  pages: [
    MultiStepFormPage(formKey: step0Key, title: 'Step 1', builder: (_) => StepOne()),
    MultiStepFormPage(formKey: step1Key, title: 'Step 2', builder: (_) => StepTwo()),
  ],
  usePageView: true,
  indicatorType: IndicatorType.dots,
  transitionType: TransitionType.slide,
  onSubmit: () => print('submit'),
);
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

See `LICENSE`.
