import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../../models/duty_discovery_models.dart';

/// Forward geocoding — search **any city, area, hospital or landmark** worldwide.
/// Uses OpenStreetMap Nominatim (no API key required).
class GeocodingService {
  static const _userAgent = 'MedDuty/1.0 (medical duty discovery app)';

  Future<List<SearchLocationSuggestion>> searchPlaces(String query) async {
    final q = query.trim();
    if (q.length < 2) return [];

    try {
      final uri = Uri.https('nominatim.openstreetmap.org', '/search', {
        'q': q,
        'format': 'json',
        'limit': '10',
        'addressdetails': '1',
      });

      final response = await http.get(
        uri,
        headers: {'User-Agent': _userAgent},
      ).timeout(const Duration(seconds: 8));

      if (response.statusCode != 200) return [];

      final list = jsonDecode(response.body) as List<dynamic>;
      return list.map((raw) {
        final m = raw as Map<String, dynamic>;
        final name = m['name'] as String? ??
            m['display_name']?.toString().split(',').first ??
            'Location';
        final display = m['display_name'] as String? ?? name;
        return SearchLocationSuggestion(
          label: name,
          subtitle: display,
          latitude: double.parse(m['lat'] as String),
          longitude: double.parse(m['lon'] as String),
        );
      }).toList();
    } catch (e) {
      debugPrint('GeocodingService search: $e');
      return [];
    }
  }
}
