class PhoneNumberUtils {
  PhoneNumberUtils._();

  /// Normalizes a raw phone number to a 10-digit Indian mobile number.
  /// - Strips all spaces, dashes, parentheses
  /// - Removes +91 or 91 country code prefix
  /// Returns null if the result is not a valid 10-digit number.
  static String? normalize(String raw) {
    // Remove all non-digit characters
    String digits = raw.replaceAll(RegExp(r'[^\d]'), '');

    // Remove country code prefix
    if (digits.startsWith('91') && digits.length == 12) {
      digits = digits.substring(2);
    } else if (digits.startsWith('0') && digits.length == 11) {
      digits = digits.substring(1);
    }

    if (digits.length != 10) return null;
    return digits;
  }

  /// Returns true if the number is a valid 10-digit mobile number.
  static bool isValid(String number) {
    return RegExp(r'^[6-9]\d{9}$').hasMatch(number);
  }

  static String? validateInput(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter your mobile number';
    }
    final cleaned = value.trim().replaceAll(RegExp(r'[^\d]'), '');
    if (cleaned.length != 10) {
      return 'Mobile number must be exactly 10 digits';
    }
    if (!isValid(cleaned)) {
      return 'Please enter a valid Indian mobile number';
    }
    return null;
  }
}
