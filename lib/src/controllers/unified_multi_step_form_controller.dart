import 'package:flutter/material.dart';

/// Synchronous validator used by registered form fields.
typedef MultiStepFormFieldValidator = String? Function(String? value);

/// Async validator used for server-side or delayed validation.
typedef MultiStepFormFieldAsyncValidator =
    Future<String?> Function(String? value);

class _FieldBinding {
  const _FieldBinding({
    required this.controller,
    required this.validator,
    required this.stepIndex,
    required this.ownsController,
  });

  final TextEditingController controller;
  final MultiStepFormFieldValidator? validator;
  final int stepIndex;
  final bool ownsController;
}

/// Controller for step navigation, field registration, and validation.
class UnifiedMultiStepFormController extends ChangeNotifier {
  /// Creates a controller with an optional initial step.
  UnifiedMultiStepFormController({int initialStep = 0})
    : _currentStep = initialStep;

  int _currentStep;
  int? _lastStep;
  final Map<String, _FieldBinding> _fields = {};
  final Map<String, MultiStepFormFieldAsyncValidator> _asyncValidators = {};

  /// Current active step index.
  int get currentStep => _currentStep;

  /// Last available step index.
  int get lastStep => _lastStep ?? 0;

  /// Whether the current step is the first step.
  bool get isFirstStep => _currentStep <= 0;

  /// Whether the current step is the last step.
  bool get isLastStep => _currentStep >= lastStep;

  /// Updates the total number of steps and clamps the current index.
  void attachStepCount(int totalSteps) {
    if (totalSteps <= 0) {
      _lastStep = 0;
      if (_currentStep != 0) {
        _currentStep = 0;
      }
      notifyListeners();
      return;
    }

    _lastStep = totalSteps - 1;
    final clamped = _currentStep.clamp(0, _lastStep!);
    if (clamped != _currentStep) {
      _currentStep = clamped;
      notifyListeners();
    }
  }

  /// Goes to a specific step index.
  void goTo(int step) {
    final maxStep = _lastStep ?? step;
    final clamped = step.clamp(0, maxStep);
    if (clamped == _currentStep) return;

    _currentStep = clamped;
    notifyListeners();
  }

  /// Moves to the next step.
  void next() => goTo(_currentStep + 1);

  /// Moves to the previous step.
  void previous() => goTo(_currentStep - 1);

  /// Registers a field under a stable name.
  void registerField({
    required String name,
    required TextEditingController controller,
    int stepIndex = 0,
    MultiStepFormFieldValidator? validator,
    bool ownsController = false,
  }) {
    _fields[name] = _FieldBinding(
      controller: controller,
      validator: validator,
      stepIndex: stepIndex,
      ownsController: ownsController,
    );
  }

  /// Unregisters a field by name.
  void unregisterField(String name) {
    final removed = _fields.remove(name);
    if (removed == null) return;
    if (removed.ownsController) {
      removed.controller.dispose();
    }
  }

  /// Clears all registered fields and disposes owned controllers.
  void clearFields() {
    for (final entry in _fields.entries) {
      if (entry.value.ownsController) {
        entry.value.controller.dispose();
      }
    }
    _fields.clear();
  }

  /// Returns the current value for a registered field.
  String? getValue(String name) => _fields[name]?.controller.text;

  /// Returns all registered field values as an unmodifiable map.
  Map<String, String> getValues() {
    return Map.unmodifiable(
      _fields.map((key, binding) => MapEntry(key, binding.controller.text)),
    );
  }

  /// Registers an async validator for a field name.
  void registerAsyncValidator({
    required String name,
    required MultiStepFormFieldAsyncValidator validator,
  }) {
    _asyncValidators[name] = validator;
  }

  /// Removes the async validator for a field name.
  void unregisterAsyncValidator(String name) {
    _asyncValidators.remove(name);
  }

  /// Runs synchronous validation for one step.
  bool validateStep(int stepIndex) {
    var isValid = true;
    final stepFields = _fields.values.where(
      (field) => field.stepIndex == stepIndex,
    );

    for (final field in stepFields) {
      final validator = field.validator;
      if (validator == null) continue;
      final error = validator(field.controller.text);
      if (error != null && error.isNotEmpty) {
        isValid = false;
      }
    }

    return isValid;
  }

  /// Runs synchronous validation for every registered field.
  bool validateAll() {
    for (final field in _fields.values) {
      final validator = field.validator;
      if (validator == null) continue;
      final error = validator(field.controller.text);
      if (error != null && error.isNotEmpty) {
        return false;
      }
    }
    return true;
  }

  /// Run async validators for a specific step. Returns true when all async
  /// validators for the step return `null` (no error).
  /// Runs async validation for one step.
  Future<bool> validateStepAsync(int stepIndex) async {
    final stepFields = _fields.entries.where(
      (e) => e.value.stepIndex == stepIndex,
    );
    for (final entry in stepFields) {
      final name = entry.key;
      final validator = _asyncValidators[name];
      if (validator == null) continue;
      final result = await validator(entry.value.controller.text);
      if (result != null && result.isNotEmpty) return false;
    }
    return true;
  }

  /// Run all async validators across all registered fields.
  /// Runs async validation for every registered field.
  Future<bool> validateAllAsync() async {
    for (final entry in _fields.entries) {
      final name = entry.key;
      final validator = _asyncValidators[name];
      if (validator == null) continue;
      final result = await validator(entry.value.controller.text);
      if (result != null && result.isNotEmpty) return false;
    }
    return true;
  }

  @override
  void dispose() {
    clearFields();
    super.dispose();
  }
}
