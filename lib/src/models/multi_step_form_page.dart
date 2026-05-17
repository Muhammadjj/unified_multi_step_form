import 'package:flutter/material.dart';

/// Builder signature for a step page body.
typedef MultiStepFormPageBuilder = Widget Function(BuildContext context);

/// Describes one step in a multi-step form.
class MultiStepFormPage {
  /// Creates a step definition.
  const MultiStepFormPage({
    required this.formKey,
    required this.builder,
    this.title,
  });

  /// Form key for this step.
  final GlobalKey<FormState> formKey;

  /// Builds the step body.
  final MultiStepFormPageBuilder builder;

  /// Optional step title shown above the body.
  final String? title;
}
