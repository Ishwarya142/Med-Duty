import 'dart:math' as math;

import 'package:geolocator/geolocator.dart';

/// Haversine distance in kilometres between two WGS84 points.
double distanceKm(double lat1, double lng1, double lat2, double lng2) {
  return Geolocator.distanceBetween(lat1, lng1, lat2, lng2) / 1000.0;
}

String formatDistanceKm(double? km) {
  if (km == null) return '';
  if (km < 1) return '${(km * 1000).round()} m';
  return '${km.toStringAsFixed(1)} km';
}

/// Bounding box for a rough pre-filter before precise distance checks.
({double minLat, double maxLat, double minLng, double maxLng}) boundingBox(
  double centerLat,
  double centerLng,
  double radiusKm,
) {
  const earthRadiusKm = 6371.0;
  final latDelta = radiusKm / earthRadiusKm * (180 / math.pi);
  final lngDelta =
      radiusKm / earthRadiusKm * (180 / math.pi) / math.cos(centerLat * math.pi / 180);
  return (
    minLat: centerLat - latDelta,
    maxLat: centerLat + latDelta,
    minLng: centerLng - lngDelta,
    maxLng: centerLng + lngDelta,
  );
}

bool isWithinBoundingBox(
  double lat,
  double lng,
  ({double minLat, double maxLat, double minLng, double maxLng}) box,
) {
  return lat >= box.minLat &&
      lat <= box.maxLat &&
      lng >= box.minLng &&
      lng <= box.maxLng;
}

bool isWithinRadiusKm(
  double centerLat,
  double centerLng,
  double pointLat,
  double pointLng,
  double radiusKm,
) {
  return distanceKm(centerLat, centerLng, pointLat, pointLng) <= radiusKm;
}
