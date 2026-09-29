import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../core/services/location_service.dart';
import '../models/duty_discovery_models.dart';

class SearchLocation {
  final String label;
  final double latitude;
  final double longitude;
  final bool isGps;

  const SearchLocation({
    required this.label,
    required this.latitude,
    required this.longitude,
    this.isGps = false,
  });

  Map<String, dynamic> toPrefs() => {
        'label': label,
        'latitude': latitude,
        'longitude': longitude,
        'isGps': isGps,
      };

  factory SearchLocation.fromPrefs(Map<String, dynamic> map) {
    return SearchLocation(
      label: map['label'] as String? ?? 'Selected location',
      latitude: (map['latitude'] as num).toDouble(),
      longitude: (map['longitude'] as num).toDouble(),
      isGps: map['isGps'] == true,
    );
  }
}

class LocationProvider extends ChangeNotifier {
  static const _prefLocation = 'discovery_search_location';
  static const _prefRadius = 'discovery_radius_km';

  final LocationService _locationService = LocationService();

  SearchLocation? _searchLocation;
  double _radiusKm = kDefaultRadiusKm;
  LocationAccessState _accessState = LocationAccessState.unknown;
  bool _initialized = false;
  bool _loadingGps = false;

  SearchLocation? get searchLocation => _searchLocation;
  double get radiusKm => _radiusKm;
  LocationAccessState get accessState => _accessState;
  bool get isInitialized => _initialized;
  bool get loadingGps => _loadingGps;

  String get locationLabel =>
      _searchLocation?.label ?? 'Choose location';

  String get radiusLabel => 'Within ${_radiusKm.toStringAsFixed(0)} km';

  Future<void> initialize({ProfileLocationFallback? profileFallback}) async {
    if (_initialized) return;
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString(_prefLocation);
    _radiusKm = prefs.getDouble(_prefRadius) ?? kDefaultRadiusKm;

    if (saved != null) {
      try {
        final parts = saved.split('|');
        if (parts.length >= 3) {
          _searchLocation = SearchLocation(
            label: parts[0],
            latitude: double.parse(parts[1]),
            longitude: double.parse(parts[2]),
            isGps: parts.length > 3 && parts[3] == 'gps',
          );
        }
      } catch (_) {}
    }

    if (_searchLocation == null && profileFallback != null) {
      if (profileFallback.latitude != null &&
          profileFallback.longitude != null) {
        _searchLocation = SearchLocation(
          label: profileFallback.label ??
              profileFallback.city ??
              'Saved location',
          latitude: profileFallback.latitude!,
          longitude: profileFallback.longitude!,
        );
      }
    }

    if (_searchLocation == null) {
      final defaultLoc = kChennaiSearchLocations.first;
      _searchLocation = SearchLocation(
        label: '${defaultLoc.label}, Chennai',
        latitude: defaultLoc.latitude,
        longitude: defaultLoc.longitude,
      );
    }

    _initialized = true;
    notifyListeners();
  }

  Future<void> persist() async {
    final loc = _searchLocation;
    if (loc == null) return;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _prefLocation,
      '${loc.label}|${loc.latitude}|${loc.longitude}|${loc.isGps ? 'gps' : 'manual'}',
    );
    await prefs.setDouble(_prefRadius, _radiusKm);
  }

  void setSearchLocation(SearchLocation location) {
    _searchLocation = location;
    persist();
    notifyListeners();
  }

  void setRadiusKm(double km) {
    _radiusKm = km;
    persist();
    notifyListeners();
  }

  Future<bool> tryUseCurrentLocation() async {
    _loadingGps = true;
    _accessState = LocationAccessState.loading;
    notifyListeners();

    _accessState = await _locationService.checkAccess();
    if (_accessState != LocationAccessState.granted) {
      _loadingGps = false;
      notifyListeners();
      return false;
    }

    final result = await _locationService.getCurrentLocation();
    _loadingGps = false;

    if (result == null) {
      _accessState = LocationAccessState.error;
      notifyListeners();
      return false;
    }

    _accessState = LocationAccessState.granted;
    _searchLocation = SearchLocation(
      label: 'Current location',
      latitude: result.latitude,
      longitude: result.longitude,
      isGps: true,
    );
    await persist();
    notifyListeners();
    return true;
  }

  /// Legacy API used elsewhere in the app.
  void updateLocation(double lat, double lng) {
    _searchLocation = SearchLocation(
      label: _searchLocation?.label ?? 'Selected location',
      latitude: lat,
      longitude: lng,
      isGps: _searchLocation?.isGps ?? false,
    );
    notifyListeners();
  }

  double get latitude => _searchLocation?.latitude ?? 0;
  double get longitude => _searchLocation?.longitude ?? 0;
}

class ProfileLocationFallback {
  final double? latitude;
  final double? longitude;
  final String? label;
  final String? city;

  const ProfileLocationFallback({
    this.latitude,
    this.longitude,
    this.label,
    this.city,
  });
}
