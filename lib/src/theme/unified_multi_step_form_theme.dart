import 'package:flutter/material.dart';

/// Default theme/configuration values for [UnifiedMultiStepForm].
class UnifiedMultiStepFormTheme {
  /// Creates a theme configuration for the multi-step form.
  const UnifiedMultiStepFormTheme({
    this.activeIndicatorColor,
    this.inactiveIndicatorColor,
    this.padding = const EdgeInsets.symmetric(horizontal: 16),
    this.nextButtonText = 'Next',
    this.previousButtonText = 'Previous',
    this.submitButtonText = 'Submit',
  });

  /// Active indicator color.
  final Color? activeIndicatorColor;

  /// Inactive indicator color.
  final Color? inactiveIndicatorColor;

  /// Default padding for step content.
  final EdgeInsetsGeometry padding;

  /// Default label for the next button.
  final String nextButtonText;

  /// Default label for the previous button.
  final String previousButtonText;

  /// Default label for the submit button.
  final String submitButtonText;
}
