/// Google Sign-In OAuth configuration for MedDuty.
///
/// Get the Web client ID from:
/// Firebase Console → Authentication → Sign-in method → Google → Web client ID
/// (or Google Cloud Console → Credentials → OAuth 2.0 Web client)
///
/// Run with:
/// `flutter run --dart-define=GOOGLE_WEB_CLIENT_ID=YOUR_ID.apps.googleusercontent.com`
class GoogleAuthConfig {
  GoogleAuthConfig._();

  static const String webClientId = String.fromEnvironment(
    'GOOGLE_WEB_CLIENT_ID',
    defaultValue: '',
  );

  /// Used as [serverClientId] on Android (required for Firebase idToken).
  static String? get serverClientId =>
      webClientId.isEmpty ? null : webClientId;

  static bool get hasClientId => webClientId.isNotEmpty;
}
