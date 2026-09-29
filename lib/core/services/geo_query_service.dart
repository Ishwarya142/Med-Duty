import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../constants/supabase_constants.dart';
import '../utils/geo_utils.dart';
import '../utils/geohash_utils.dart';
import '../../models/duty_model.dart';

/// Supabase queries for location-based duty discovery.
class GeoQueryService {
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<List<DutyModel>> fetchNearbyDuties({
    required double centerLat,
    required double centerLng,
    required double radiusKm,
    int limitPerRange = 80,
  }) async {
    final bounds = geohashQueryBounds(centerLat, centerLng, radiusKm);
    final seen = <String>{};
    final results = <DutyModel>[];

    for (final bound in bounds) {
      try {
        final data = await _supabase
            .from(SupabaseConstants.duties)
            .select()
            .eq('status', DutyStatus.upcoming.name)
            .gte('geohash', bound.start)
            .lte('geohash', bound.end)
            .limit(limitPerRange);

        for (final row in List<Map<String, dynamic>>.from(data)) {
          final id = (row['id'] ?? '').toString();
          if (seen.add(id)) {
            results.add(DutyModel.fromMap(row, id));
          }
        }
      } catch (e) {
        debugPrint('GeoQueryService query error: $e');
      }
    }

    if (results.isEmpty) {
      try {
        final allUpcoming = await _supabase
            .from(SupabaseConstants.duties)
            .select()
            .eq('status', DutyStatus.upcoming.name)
            .limit(100);
        for (final row in List<Map<String, dynamic>>.from(allUpcoming)) {
          final id = (row['id'] ?? '').toString();
          if (seen.add(id)) {
            results.add(DutyModel.fromMap(row, id));
          }
        }
      } catch (_) {}
    }

    return _filterByExactDistance(
      results,
      centerLat,
      centerLng,
      radiusKm,
    );
  }

  Stream<List<DutyModel>> watchNearbyDuties({
    required double centerLat,
    required double centerLng,
    required double radiusKm,
    int limitPerRange = 80,
  }) {
    return _supabase
        .from(SupabaseConstants.duties)
        .stream(primaryKey: ['id'])
        .eq('status', DutyStatus.upcoming.name)
        .map((data) {
      final duties = data.map((row) => DutyModel.fromMap(row, (row['id'] ?? '').toString())).toList();
      return _filterByExactDistance(duties, centerLat, centerLng, radiusKm);
    });
  }

  List<DutyModel> _filterByExactDistance(
    List<DutyModel> duties,
    double centerLat,
    double centerLng,
    double radiusKm,
  ) {
    return duties.where((duty) {
      if (!duty.hasCoordinates) return false;
      return isWithinRadiusKm(
        centerLat,
        centerLng,
        duty.latitude!,
        duty.longitude!,
        radiusKm,
      );
    }).toList();
  }
}
