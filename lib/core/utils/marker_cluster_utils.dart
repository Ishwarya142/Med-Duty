import 'dart:math' as math;

import 'package:latlong2/latlong.dart';

import '../../models/duty_with_distance.dart';
import 'geohash_utils.dart';

/// Simple geohash-grid marker clustering for duty map markers.
class MapCluster {
  final LatLng center;
  final List<DutyWithDistance> items;

  const MapCluster({required this.center, required this.items});

  bool get isCluster => items.length > 1;
  int get count => items.length;
}

List<MapCluster> clusterDuties(
  List<DutyWithDistance> duties,
  double zoom,
) {
  final located = duties.where((d) => d.hasLocation).toList();
  if (located.isEmpty) return [];

  final prefixLen = zoom >= 14
      ? 7
      : zoom >= 13
          ? 6
          : zoom >= 12
              ? 5
              : zoom >= 11
                  ? 4
                  : 3;

  final buckets = <String, List<DutyWithDistance>>{};

  for (final item in located) {
    final d = item.duty;
    final hash = encodeGeohash(
      d.latitude!,
      d.longitude!,
      precision: prefixLen.clamp(3, 9),
    );
    final key = hash.substring(0, prefixLen.clamp(1, hash.length));
    buckets.putIfAbsent(key, () => []).add(item);
  }

  return buckets.values.map((group) {
    var latSum = 0.0;
    var lngSum = 0.0;
    for (final item in group) {
      latSum += item.duty.latitude!;
      lngSum += item.duty.longitude!;
    }
    final n = group.length;
    return MapCluster(
      center: LatLng(latSum / n, lngSum / n),
      items: group,
    );
  }).toList();
}

double zoomInFromCluster(double currentZoom) {
  return math.min(currentZoom + 2, 16);
}

/// Convert km search radius to an appropriate flutter_map zoom level.
double zoomForRadiusKm(double km) {
  if (km <= 2) return 14;
  if (km <= 5) return 13;
  if (km <= 10) return 12;
  if (km <= 15) return 11.5;
  if (km <= 25) return 11;
  return 10;
}
