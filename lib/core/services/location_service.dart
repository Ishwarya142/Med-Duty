import 'package:geolocator/geolocator.dart';

enum LocationAccessState {
  unknown,
  loading,
  granted,
  denied,
  deniedForever,
  serviceDisabled,
  error,
}

class LocationServiceResult {
  final double latitude;
  final double longitude;
  final String? label;

  const LocationServiceResult({
    required this.latitude,
    required this.longitude,
    this.label,
  });
}

class LocationService {
  Future<LocationAccessState> checkAccess() async {
    final enabled = await Geolocator.isLocationServiceEnabled();
    if (!enabled) return LocationAccessState.serviceDisabled;

    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.deniedForever) {
      return LocationAccessState.deniedForever;
    }
    if (permission == LocationPermission.denied) {
      return LocationAccessState.denied;
    }
    return LocationAccessState.granted;
  }

  Future<LocationServiceResult?> getCurrentLocation() async {
    final access = await checkAccess();
    if (access != LocationAccessState.granted) return null;

    try {
      final pos = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.medium,
          timeLimit: Duration(seconds: 12),
        ),
      );
      return LocationServiceResult(
        latitude: pos.latitude,
        longitude: pos.longitude,
        label: 'Current location',
      );
    } catch (_) {
      return null;
    }
  }

  Future<Position> getCurrentPosition() async {
    return Geolocator.getCurrentPosition();
  }

  double distanceKm(
    double lat1,
    double lng1,
    double lat2,
    double lng2,
  ) {
    return Geolocator.distanceBetween(lat1, lng1, lat2, lng2) / 1000.0;
  }

  Future<bool> openLocationSettings() => Geolocator.openLocationSettings();

  Future<bool> openAppSettings() => Geolocator.openAppSettings();
}
