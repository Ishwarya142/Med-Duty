/// Map configuration for MedDuty.
///
/// ## Duty discovery map (Nearby Duties)
/// Uses **flutter_map + OpenStreetMap** — no API key required.
/// Works on Android, iOS, and Web (including Edge).
///
/// ## Google Maps (optional — edit profile location picker only)
/// If you want Google Maps on the edit-profile screen, set a key in ONE of:
///
/// 1. **Web:** `web/index.html` → replace `YOUR_GOOGLE_MAPS_API_KEY`
/// 2. **Android:** `android/local.properties` → `MAPS_API_KEY=your_key`
/// 3. **iOS:** `ios/Runner/Info.plist` → `GMSApiKey`
/// 4. **All platforms:** `flutter run --dart-define=GOOGLE_MAPS_API_KEY=your_key`
///
/// Get a key: https://console.cloud.google.com/google/maps-apis
/// Enable: Maps JavaScript API, Maps SDK for Android, Maps SDK for iOS
class MapsConfig {
  MapsConfig._();

  static const apiKey = String.fromEnvironment(
    'GOOGLE_MAPS_API_KEY',
    defaultValue: '',
  );

  static bool get isConfigured => apiKey.isNotEmpty;

  /// Duty discovery uses OpenStreetMap — always available without billing.
  static bool get discoveryMapNeedsApiKey => false;
}
