/// Common validation helpers for multi-step forms.
class MultiStepFormValidators {
  /// Creates a validation helper namespace.
  ///
  /// This class is designed for static helper methods only.
  const MultiStepFormValidators._();

  /// Checks that a value is present.
  static String? required(
    String? value, {
    String message = 'This field is required',
  }) {
    if (value == null || value.trim().isEmpty) {
      return message;
    }
    return null;
  }

  /// Returns true when the value looks like an email address.
  static bool isEmail(String value) {
    return RegExp(r'^[^@]+@[^@]+\.[^@]+$').hasMatch(value.trim());
  }

  /// Returns true when the value looks like a URL.
  static bool isUrl(String value) {
    return RegExp(r'^(https?:\/\/)?([\w-]+\.)+[\w-]+$').hasMatch(value.trim());
  }

  /// Returns true when the value matches CNIC format.
  static bool isCnic(String value) {
    return RegExp(r'^\d{5}-\d{7}-\d{1}$').hasMatch(value.trim());
  }

  /// Returns true when the value matches NTN format.
  static bool isNtn(String value) {
    return RegExp(r'^\d{7}-\d$').hasMatch(value.trim());
  }

  /// Returns true when the value matches STRN format.
  static bool isStrn(String value) {
    return RegExp(r'^[A-Z]{2}-\d{6}$').hasMatch(value.trim());
  }

  /// Returns true when the value matches a Pakistan phone format.
  static bool isPakPhone(String value) {
    return RegExp(r'^\+92-\d{3}-\d{7}$').hasMatch(value.trim());
  }

  /// Returns true when the value matches an ISO currency code.
  static bool isIsoCurrencyCode(String value) {
    return RegExp(r'^[A-Z]{3}$').hasMatch(value.trim());
  }
}
