import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../utils/contact_utils.dart';
import 'google_auth_service.dart';

/// Phone + recovery email management via Supabase Auth.
class ContactService {
  ContactService._();

  static final ContactService instance = ContactService._();

  static const _pendingRecoveryEmailKey = 'pending_recovery_email';

  final SupabaseClient _supabase = Supabase.instance.client;

  User? get _user => _supabase.auth.currentUser;

  String? get primaryEmail => _user?.email;

  bool get isPrimaryEmailVerified => _user?.emailConfirmedAt != null;

  String? get authPhoneNumber => _user?.phone;

  bool get isGoogleUser =>
      _user?.appMetadata['provider'] == 'google' ||
      (_user?.identities?.any((i) => i.provider == 'google') ?? false);

  bool get isPasswordUser =>
      _user?.appMetadata['provider'] == 'email' ||
      (_user?.identities?.any((i) => i.provider == 'email') ?? false);

  Future<void> reauthenticate({
    String? password,
  }) async {
    final user = _user;
    if (user == null) {
      throw Exception('No user is currently signed in.');
    }

    if (isGoogleUser) {
      await GoogleAuthService.reauthenticate();
      return;
    }

    if (isPasswordUser && password != null && password.isNotEmpty) {
      final email = user.email;
      if (email == null || email.isEmpty) {
        throw Exception('No email associated with account.');
      }
      await _supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );
      return;
    }

    throw Exception('Re-authentication required.');
  }

  Future<void> sendPhoneVerificationCode({
    required String phoneE164,
    required void Function(String verificationId, int? resendToken) onCodeSent,
    required void Function(dynamic error) onFailed,
    int? forceResendToken,
  }) async {
    try {
      await _supabase.auth.signInWithOtp(
        phone: phoneE164,
      );
      onCodeSent(phoneE164, null);
    } catch (e) {
      onFailed(e);
    }
  }

  Future<String> verifyPhoneOtp({
    required String verificationId,
    required String smsCode,
  }) async {
    final res = await _supabase.auth.verifyOTP(
      phone: verificationId,
      token: smsCode.trim(),
      type: OtpType.sms,
    );
    return res.user?.phone ?? verificationId;
  }

  Future<void> removePhone({String? password}) async {
    await _supabase.auth.updateUser(UserAttributes(phone: ''));
  }

  Future<void> sendRecoveryEmailVerification(String email) async {
    final normalized = ContactUtils.normalizeEmail(email);
    final user = _user;
    if (user == null) throw Exception('No user signed in');

    final primary = ContactUtils.normalizeEmail(user.email ?? '');
    if (normalized == primary) {
      throw Exception('same-as-primary-email');
    }

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_pendingRecoveryEmailKey, normalized);

    await _supabase.auth.resetPasswordForEmail(normalized);
  }

  Future<String?> pendingRecoveryEmail() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_pendingRecoveryEmailKey);
  }

  Future<void> clearPendingRecoveryEmail() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_pendingRecoveryEmailKey);
  }

  Future<String> completeRecoveryEmailLink(String emailLink) async {
    final pending = await pendingRecoveryEmail();
    await clearPendingRecoveryEmail();
    return pending ?? '';
  }

  Future<bool> checkRecoveryEmailLinkFromUri(Uri uri) async {
    return false;
  }

  Future<void> changePrimaryEmail({
    required String newEmail,
    String? password,
  }) async {
    final user = _user;
    if (user == null) throw Exception('No user signed in');

    if (isGoogleUser && !isPasswordUser) {
      throw Exception('google-managed-email');
    }

    final normalized = ContactUtils.normalizeEmail(newEmail);
    if (!ContactUtils.isValidEmail(normalized)) {
      throw Exception('invalid-email');
    }

    await _supabase.auth.updateUser(UserAttributes(email: normalized));
  }
}
