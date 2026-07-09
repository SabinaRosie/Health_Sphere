/// Shared, industry-standard form validators for Health Sphere
class AppValidators {
  AppValidators._();

  /// Full name — must be at least 2 chars, letters and spaces only
  static String? name(String? v) {
    if (v == null || v.trim().isEmpty) return 'Full name is required';
    if (v.trim().length < 2) return 'Name must be at least 2 characters';
    if (!RegExp(r"^[a-zA-Z\s'-]+$").hasMatch(v.trim())) {
      return 'Name can only contain letters, spaces, hyphens, or apostrophes';
    }
    return null;
  }

  /// Email — RFC-compliant regex
  static String? email(String? v) {
    if (v == null || v.trim().isEmpty) return 'Email address is required';
    final regex = RegExp(
      r'^[a-zA-Z0-9._%+\-]+@[a-zA-Z0-9.\-]+\.[a-zA-Z]{2,}$',
    );
    if (!regex.hasMatch(v.trim())) {
      return 'Enter a valid email (e.g. you@example.com)';
    }
    return null;
  }

  /// Password — 8+ chars, upper, lower, digit, special char
  static String? password(String? v) {
    if (v == null || v.isEmpty) return 'Password is required';
    if (v.length < 8) return 'Password must be at least 8 characters';
    if (!v.contains(RegExp(r'[A-Z]'))) {
      return 'Must contain at least one uppercase letter (A-Z)';
    }
    if (!v.contains(RegExp(r'[a-z]'))) {
      return 'Must contain at least one lowercase letter (a-z)';
    }
    if (!v.contains(RegExp(r'[0-9]'))) {
      return 'Must contain at least one number (0-9)';
    }
    if (!v.contains(RegExp(r'[!@#\$%^&*(),.?":{}|<>_\-]'))) {
      return 'Must contain at least one special character (!@#\$ etc.)';
    }
    return null;
  }

  /// Confirm password — must match the original password
  static String? Function(String?) confirmPassword(String original) {
    return (String? v) {
      if (v == null || v.isEmpty) return 'Please confirm your password';
      if (v != original) return 'Passwords do not match';
      return null;
    };
  }
}
