
class ContactUtils {
  ContactUtils._();

  static final _emailRegex = RegExp(
    r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
  );

  static bool isValidEmail(String email) => _emailRegex.hasMatch(email.trim());

  static bool isValidPhoneDigits(String digits) {
    final d = digits.replaceAll(RegExp(r'\D'), '');
    return d.length >= 7 && d.length <= 15;
  }

  static String normalizeEmail(String email) => email.trim().toLowerCase();

  static String formatPhoneE164(String dialCode, String digits) {
    final d = digits.replaceAll(RegExp(r'\D'), '');
    final code = dialCode.startsWith('+') ? dialCode : '+$dialCode';
    return '$code$d';
  }

  static String formatPhoneDisplay(String e164) {
    final digits = e164.replaceAll(RegExp(r'\D'), '');
    if (digits.length < 10) return e164;
    if (digits.startsWith('91') && digits.length >= 12) {
      final local = digits.substring(2);
      if (local.length == 10) {
        return '+91 ${local.substring(0, 5)} ${local.substring(5)}';
      }
    }
    return e164;
  }

  static String maskEmail(String email) {
    final parts = email.split('@');
    if (parts.length != 2) return email;
    final name = parts[0];
    final domain = parts[1];
    if (name.length <= 2) return '${name[0]}•••@$domain';
    return '${name.substring(0, 2)}•••@$domain';
  }

  static String maskPhone(String phone) {
    final digits = phone.replaceAll(RegExp(r'\D'), '');
    if (digits.length < 6) return phone;
    final last = digits.substring(digits.length - 4);
    if (digits.startsWith('91') && digits.length >= 12) {
      return '+91 ••••• $last';
    }
    return '••••• $last';
  }

  static String contactErrorMessage(dynamic error) {
    if (error != null) {
      final code = (error as dynamic)?.code?.toString() ?? error.toString();
      switch (code) {
        case 'invalid-email':
          return 'Enter a valid email address.';
        case 'invalid-phone-number':
          return 'Enter a valid phone number.';
        case 'invalid-verification-code':
          return 'Incorrect verification code. Please try again.';
        case 'session-expired':
        case 'code-expired':
          return 'This verification code has expired. Request a new code.';
        case 'too-many-requests':
          return 'Too many verification attempts. Please try again later.';
        case 'network-request-failed':
          return 'Unable to connect. Check your internet connection and try again.';
        case 'email-already-in-use':
        case 'credential-already-in-use':
        case 'account-exists-with-different-credential':
          return 'This phone number/email is already associated with another account.';
        case 'requires-recent-login':
          return 'Please verify your identity before changing this information.';
        case 'provider-already-linked':
          return 'This contact method is already linked to your account.';
        case 'user-disabled':
          return 'This account has been disabled.';
        case 'operation-not-allowed':
          return 'This operation is not available right now. Please try again later.';
        case 'quota-exceeded':
          return 'Too many requests. Please try again later.';
        case 'captcha-check-failed':
          return 'Security verification failed. Please try again.';
        case 'same-as-primary-email':
          return 'Recovery email must be different from your primary email.';
        case 'google-managed-email':
          return 'Your primary email is managed by your Google account.';
        case 'no-pending-recovery-email':
          return 'No pending recovery email verification found.';
        case 'invalid-action-code':
          return 'This verification link is invalid or has expired.';
        default:
          return 'Something went wrong. Please try again.';
      }
    }
    return 'Something went wrong. Please try again.';
  }
}
