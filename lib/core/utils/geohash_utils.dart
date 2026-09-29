import 'geo_utils.dart';

const _base32 = '0123456789bcdefghjkmnpqrstuvwxyz';

/// Encodes [latitude]/[longitude] as a geohash string (WGS84).
String encodeGeohash(
  double latitude,
  double longitude, {
  int precision = 9,
}) {
  var latRange = [-90.0, 90.0];
  var lngRange = [-180.0, 180.0];
  final buffer = StringBuffer();
  var bit = 0;
  var ch = 0;
  var even = true;

  while (buffer.length < precision) {
    if (even) {
      final mid = (lngRange[0] + lngRange[1]) / 2;
      if (longitude > mid) {
        ch |= 1 << (4 - bit);
        latRange[0] = mid;
      } else {
        lngRange[1] = mid;
      }
    } else {
      final mid = (latRange[0] + latRange[1]) / 2;
      if (latitude > mid) {
        ch |= 1 << (4 - bit);
        latRange[0] = mid;
      } else {
        latRange[1] = mid;
      }
    }
    even = !even;
    if (bit < 4) {
      bit++;
    } else {
      buffer.write(_base32[ch]);
      bit = 0;
      ch = 0;
    }
  }
  return buffer.toString();
}

/// A Firestore geohash range `[start, end]` (inclusive).
class GeohashQueryBound {
  final String start;
  final String end;

  const GeohashQueryBound(this.start, this.end);
}

/// Approximate geohash character count for a search [radiusKm].
int geohashPrecisionForRadiusKm(double radiusKm) {
  if (radiusKm > 2000) return 3;
  if (radiusKm > 500) return 4;
  if (radiusKm > 62) return 5;
  if (radiusKm > 8) return 6;
  if (radiusKm > 1) return 7;
  return 8;
}

/// Builds geohash prefix query bounds for a circular search area.
///
/// Returns one or more ranges suitable for Firestore:
/// `where('geohash', isGreaterThanOrEqualTo: start)`
/// `where('geohash', isLessThanOrEqualTo: end)`
List<GeohashQueryBound> geohashQueryBounds(
  double latitude,
  double longitude,
  double radiusKm,
) {
  final precision = geohashPrecisionForRadiusKm(radiusKm);
  // Use one character less than cell precision so the prefix covers the radius.
  final prefixLen = (precision - 1).clamp(1, 9);
  final centerHash = encodeGeohash(latitude, longitude, precision: prefixLen + 1);
  final box = boundingBox(latitude, longitude, radiusKm);
  final sw = encodeGeohash(box.minLat, box.minLng, precision: prefixLen + 1);
  final ne = encodeGeohash(box.maxLat, box.maxLng, precision: prefixLen + 1);
  final swPrefix = sw.substring(0, prefixLen);
  final nePrefix = ne.substring(0, prefixLen);

  if (swPrefix == nePrefix) {
    return [GeohashQueryBound(swPrefix, '$swPrefix\uf8ff')];
  }

  // Cover the bounding-box span; fall back to center prefix if corners diverge.
  final fallbackPrefix = centerHash.substring(0, prefixLen);
  return [GeohashQueryBound(fallbackPrefix, '$fallbackPrefix\uf8ff')];
}

/// Resolves geohash for a duty — uses stored value or computes from coordinates.
String? resolveDutyGeohash({
  String? geohash,
  double? latitude,
  double? longitude,
}) {
  if (geohash != null && geohash.isNotEmpty) return geohash;
  if (latitude == null || longitude == null) return null;
  return encodeGeohash(latitude, longitude);
}
