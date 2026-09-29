import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../constants/google_auth_config.dart';

/// Thrown when the user closes/cancels the Google account picker.
class GoogleSignInCancelledException implements Exception {}

/// Thrown when the email is already linked to another auth provider.
class GoogleAccountConflictException implements Exception {}

/// Thrown for other Google sign-in failures with a user-safe message.
class GoogleSignInFailedException implements Exception {
  GoogleSignInFailedException(this.message);
  final String message;
}

/// Handles Google account selection and Supabase credential exchange.
class GoogleAuthService {
  GoogleAuthService._();

  static bool _initialized = false;

  static Future<void> ensureInitialized() async {
    if (_initialized || kIsWeb) return;
    final serverClientId = GoogleAuthConfig.serverClientId;
    if (serverClientId == null) {
      debugPrint(
        'GoogleAuthConfig: GOOGLE_WEB_CLIENT_ID is not set. '
        'Run: flutter run --dart-define=GOOGLE_WEB_CLIENT_ID=YOUR_ID.apps.googleusercontent.com',
      );
    }
    await GoogleSignIn.instance.initialize(
      serverClientId: serverClientId,
    );
    _initialized = true;
  }

  /// Starts Google auth and signs into Supabase.
  /// Returns the Supabase User or null if cancelled / redirect started on web.
  static Future<User?> signIn() async {
    if (kIsWeb) {
      return _signInWeb();
    }
    return _signInMobile();
  }

  static Future<User?> _signInWeb() async {
    try {
      debugPrint('Google web sign-in: initiating OAuth...');
      await Supabase.instance.client.auth.signInWithOAuth(
        OAuthProvider.google,
        redirectTo: kIsWeb ? null : 'io.supabase.medduty://login-callback/',
      );
      return Supabase.instance.client.auth.currentUser;
    } on AuthException catch (e) {
      debugPrint('Google web sign-in AuthException: ${e.message}');
      throw GoogleSignInFailedException(e.message);
    } catch (e) {
      debugPrint('Google web sign-in error: $e');
      throw GoogleSignInFailedException(getGoogleSignInErrorMessage(e));
    }
  }

  static Future<User?> _signInMobile() async {
    if (!GoogleAuthConfig.hasClientId && defaultTargetPlatform == TargetPlatform.android) {
      debugPrint('Google sign-in serverClientId not set, continuing with default client...');
    }

    await ensureInitialized();
    try {
      debugPrint('Google mobile sign-in: attempting authenticate...');
      final account = await GoogleSignIn.instance.authenticate();
      final idToken = account.authentication.idToken;
      if (idToken == null || idToken.isEmpty) {
        throw GoogleSignInFailedException(
          'Google sign-in failed. Please try again.',
        );
      }
      final res = await Supabase.instance.client.auth.signInWithIdToken(
        provider: OAuthProvider.google,
        idToken: idToken,
      );
      return res.user;
    } on GoogleSignInException catch (e) {
      if (e.code == GoogleSignInExceptionCode.canceled ||
          e.code == GoogleSignInExceptionCode.interrupted) {
        return null;
      }
      debugPrint('GoogleSignInException: ${e.code} ${e.description}');
      throw GoogleSignInFailedException(
        'Google sign-in failed. Please try again.',
      );
    } on AuthException catch (e) {
      debugPrint('Supabase AuthException: ${e.message}');
      throw GoogleSignInFailedException(e.message);
    }
  }

  static Future<void> signOut() async {
    try {
      if (!kIsWeb) {
        await GoogleSignIn.instance.signOut();
      }
    } catch (e) {
      debugPrint('Google sign-out error: $e');
    }
  }

  /// Re-authenticates the current user with Google.
  static Future<User?> reauthenticate() async {
    return signIn();
  }
}

String getGoogleSignInErrorMessage(dynamic error) {
  if (error is GoogleAccountConflictException) {
    return 'This email is already registered with another sign-in method. '
        'Please sign in using your existing method and link Google from your account settings.';
  }
  if (error is GoogleSignInFailedException) {
    return error.message;
  }
  if (error is GoogleSignInCancelledException) {
    return '';
  }
  if (error is AuthException) {
    return error.message;
  }
  final message = error.toString().toLowerCase();
  if (message.contains('network') || message.contains('socket')) {
    return 'Unable to connect. Please check your internet connection and try again.';
  }
  return 'Something went wrong while signing in with Google.';
}
