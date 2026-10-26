abstract final class AuthValidators {
  static String? name(String? value) {
    final name = value?.trim() ?? '';
    if (name.isEmpty) return 'Enter your name.';
    if (name.length > 100) return 'Name must be 100 characters or fewer.';
    return null;
  }

  static String? email(String? value) {
    final email = value?.trim() ?? '';
    return RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(email)
        ? null
        : 'Enter a valid email address.';
  }

  static String? password(String? value) {
    if (value == null || value.length < 8) {
      return 'Use at least 8 characters.';
    }
    return null;
  }

  static String? confirmPassword(String? value, String password) =>
      value == password ? null : 'Passwords do not match.';
}
