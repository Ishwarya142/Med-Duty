import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../constants/supabase_constants.dart';
import '../utils/geohash_utils.dart';
import 'duty_discovery_service.dart';

/// Maintains geohash fields on Supabase duty records for geo queries.
class DutyGeoIndexService {
  final SupabaseClient _supabase = Supabase.instance.client;
  final DutyDiscoveryService _discoveryService = DutyDiscoveryService();

  Future<int> backfillMissingGeohashes({int batchSize = 400}) async {
    try {
      final rows = await _supabase
          .from(SupabaseConstants.duties)
          .select('id, latitude, longitude, geohash')
          .isFilter('geohash', null)
          .limit(batchSize);

      var updated = 0;
      for (final r in List<Map<String, dynamic>>.from(rows)) {
        final lat = (r['latitude'] as num?)?.toDouble();
        final lng = (r['longitude'] as num?)?.toDouble();
        if (lat == null || lng == null) continue;

        final geohash = encodeGeohash(lat, lng);
        await _supabase
            .from(SupabaseConstants.duties)
            .update({'geohash': geohash})
            .eq('id', r['id']);
        updated++;
      }
      return updated;
    } catch (e) {
      debugPrint('DutyGeoIndexService backfill: $e');
      return 0;
    }
  }

  Future<bool> uploadSeedDutiesIfEmpty() async {
    if (!kDebugMode) return false;

    try {
      final existing = await _supabase
          .from(SupabaseConstants.duties)
          .select('id')
          .limit(1);
      if (existing.isNotEmpty) return false;

      final seeds = _discoveryService.fetchOpenDutiesSync();
      final maps = seeds.map((duty) {
        final geohash = resolveDutyGeohash(
          geohash: duty.geohash,
          latitude: duty.latitude,
          longitude: duty.longitude,
        );
        final data = duty.toMap();
        data['id'] = duty.id;
        if (geohash != null) data['geohash'] = geohash;
        return data;
      }).toList();

      await _supabase.from(SupabaseConstants.duties).upsert(maps);
      debugPrint(
        'DutyGeoIndexService: uploaded ${seeds.length} seed duties to Supabase',
      );
      return true;
    } catch (e) {
      debugPrint('DutyGeoIndexService uploadSeed: $e');
      return false;
    }
  }

  Future<void> ensureGeoIndexReady() async {
    try {
      if (kDebugMode) {
        await uploadSeedDutiesIfEmpty();
      }
      await backfillMissingGeohashes();
    } catch (e) {
      debugPrint('DutyGeoIndexService ensureGeoIndexReady: $e');
    }
  }
}
