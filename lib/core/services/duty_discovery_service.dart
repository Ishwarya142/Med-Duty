import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../constants/supabase_constants.dart';
import '../utils/geo_utils.dart';
import '../utils/geohash_utils.dart';
import '../../models/duty_model.dart';
import 'geo_query_service.dart';

/// Loads open duties from Supabase with geohash geo-queries when a search
/// center is available. Falls back to seed data when Supabase is empty.
class DutyDiscoveryService {
  final SupabaseClient _supabase = Supabase.instance.client;
  final GeoQueryService _geoQuery = GeoQueryService();

  /// Geo-spatial fetch — only downloads duties near [centerLat]/[centerLng].
  Future<List<DutyModel>> fetchNearbyDuties({
    required double centerLat,
    required double centerLng,
    required double radiusKm,
  }) async {
    try {
      final geoResults = await _geoQuery.fetchNearbyDuties(
        centerLat: centerLat,
        centerLng: centerLng,
        radiusKm: radiusKm,
      );
      if (geoResults.isNotEmpty) return geoResults;
    } catch (e) {
      debugPrint('DutyDiscoveryService geo query: $e');
    }

    // Fallback: fetch all upcoming then filter client-side.
    final all = await fetchOpenDuties();
    return all.where((duty) {
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

  Stream<List<DutyModel>> watchNearbyDuties({
    required double centerLat,
    required double centerLng,
    required double radiusKm,
  }) {
    try {
      return _geoQuery.watchNearbyDuties(
        centerLat: centerLat,
        centerLng: centerLng,
        radiusKm: radiusKm,
      ).handleError((e) {
        debugPrint('DutyDiscoveryService geo stream error: $e');
      });
    } catch (e) {
      debugPrint('DutyDiscoveryService watchNearby: $e');
      return Stream.value(_seedDuties());
    }
  }

  /// Synchronous access to seed duties (used by geo index upload).
  List<DutyModel> fetchOpenDutiesSync() => _seedDuties();

  Future<List<DutyModel>> fetchOpenDuties() async {
    try {
      final data = await _supabase
          .from(SupabaseConstants.duties)
          .select()
          .eq('status', DutyStatus.upcoming.name)
          .limit(150);

      final list = List<Map<String, dynamic>>.from(data);
      if (list.isNotEmpty) {
        return list
            .map((doc) => DutyModel.fromMap(doc, (doc['id'] ?? '').toString()))
            .toList();
      }
    } catch (e) {
      debugPrint('DutyDiscoveryService Supabase read: $e');
    }

    return _seedDuties();
  }

  Stream<List<DutyModel>> watchOpenDuties() {
    try {
      return _supabase
          .from(SupabaseConstants.duties)
          .stream(primaryKey: ['id'])
          .eq('status', DutyStatus.upcoming.name)
          .limit(150)
          .map((rows) {
        if (rows.isEmpty) return _seedDuties();
        return rows
            .map((doc) => DutyModel.fromMap(doc, (doc['id'] ?? '').toString()))
            .toList();
      });
    } catch (e) {
      debugPrint('DutyDiscoveryService stream: $e');
      return Stream.value(_seedDuties());
    }
  }

  /// Chennai-area duties with real WGS84 coordinates for geo discovery demos.
  static int _seedCreatedAgeHours(String id) {
    final numeric = RegExp(r'\d+').firstMatch(id)?.group(0);
    if (numeric != null) return int.parse(numeric) % 48;
    return id.hashCode.abs() % 48;
  }

  List<DutyModel> _seedDuties() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(const Duration(days: 1));

    DutyModel d({
      required String id,
      required String hospitalId,
      required String hospitalName,
      required String role,
      required double salary,
      required String location,
      required DateTime dutyDate,
      required int startH,
      required int endH,
      required double lat,
      required double lng,
      required String specialization,
      required String shiftType,
      required String dutyType,
      DutyPriority priority = DutyPriority.normal,
      String? emergencyReason,
      int emergencyWindowHours = 24,
      int? postedHoursAgo,
      bool verified = true,
      List<String>? requirements,
    }) {
      return DutyModel(
        id: id,
        hospitalId: hospitalId,
        hospitalName: hospitalName,
        role: role,
        salary: salary,
        location: location,
        dutyDate: dutyDate,
        startTime: DateTime(dutyDate.year, dutyDate.month, dutyDate.day, startH),
        endTime: DateTime(
          dutyDate.year,
          dutyDate.month,
          dutyDate.day,
          endH >= startH ? endH : endH + 24,
        ),
        status: DutyStatus.upcoming,
        description: 'Professional duty opportunity at $hospitalName.',
        createdAt: postedHoursAgo != null
            ? now.subtract(Duration(hours: postedHoursAgo))
            : now.subtract(Duration(hours: _seedCreatedAgeHours(id))),
        requirements: requirements ??
            ['Valid medical registration', 'Relevant experience'],
        latitude: lat,
        longitude: lng,
        geohash: encodeGeohash(lat, lng),
        specialization: specialization,
        shiftType: shiftType,
        dutyType: dutyType,
        priority: priority,
        emergencyReason: emergencyReason,
        emergencyWindowHours: emergencyWindowHours,
        verified: verified,
        address: location,
        city: 'Chennai',
        state: 'Tamil Nadu',
      );
    }

    return [
      d(
        id: 'seed_1',
        hospitalId: 'h_pims',
        hospitalName: 'PIMS Hospital',
        role: 'General Physician',
        salary: 2500,
        location: 'Avadi, Chennai',
        dutyDate: today,
        startH: 9,
        endH: 17,
        lat: 13.1098,
        lng: 80.0945,
        specialization: 'General Physician',
        shiftType: 'Day',
        dutyType: 'General Duty',
      ),
      d(
        id: 'seed_2',
        hospitalId: 'h_apollo_avadi',
        hospitalName: 'Apollo Clinic Avadi',
        role: 'Emergency Duty',
        salary: 3000,
        location: 'Avadi, Chennai',
        dutyDate: today,
        startH: 8,
        endH: 20,
        lat: 13.1180,
        lng: 80.1010,
        specialization: 'Emergency Medicine',
        shiftType: 'Day',
        dutyType: 'Emergency',
      ),
      d(
        id: 'seed_3',
        hospitalId: 'h_deepam',
        hospitalName: 'Deepam Hospital',
        role: 'ICU Specialist',
        salary: 3500,
        location: 'Ambattur, Chennai',
        dutyDate: today,
        startH: 19,
        endH: 7,
        lat: 13.0982,
        lng: 80.1612,
        specialization: 'ICU',
        shiftType: 'Night',
        dutyType: 'ICU',
      ),
      d(
        id: 'seed_4',
        hospitalId: 'h_sims',
        hospitalName: 'SIMS Hospital',
        role: 'Pediatrician',
        salary: 2800,
        location: 'Vadapalani, Chennai',
        dutyDate: tomorrow,
        startH: 10,
        endH: 18,
        lat: 13.0501,
        lng: 80.2124,
        specialization: 'Pediatrics',
        shiftType: 'Day',
        dutyType: 'OPD',
      ),
      d(
        id: 'seed_5',
        hospitalId: 'h_sundaram',
        hospitalName: 'Sundaram Medical Foundation',
        role: 'Medical Officer',
        salary: 2200,
        location: 'Anna Nagar, Chennai',
        dutyDate: today,
        startH: 9,
        endH: 17,
        lat: 13.0876,
        lng: 80.2201,
        specialization: 'General Physician',
        shiftType: 'Day',
        dutyType: 'General Duty',
      ),
      d(
        id: 'seed_6',
        hospitalId: 'h_miot',
        hospitalName: 'MIOT International',
        role: 'Orthopedic Surgeon',
        salary: 4500,
        location: 'Manapakkam, Chennai',
        dutyDate: tomorrow,
        startH: 9,
        endH: 17,
        lat: 13.0210,
        lng: 80.1853,
        specialization: 'Orthopedics',
        shiftType: 'Day',
        dutyType: 'General Duty',
      ),
      d(
        id: 'seed_7',
        hospitalId: 'h_kauvery',
        hospitalName: 'Kauvery Hospital',
        role: 'Cardiologist',
        salary: 5000,
        location: 'Alwarpet, Chennai',
        dutyDate: tomorrow,
        startH: 10,
        endH: 18,
        lat: 13.0339,
        lng: 80.2610,
        specialization: 'Cardiology',
        shiftType: 'Day',
        dutyType: 'General Duty',
      ),
      d(
        id: 'seed_8',
        hospitalId: 'h_stanley',
        hospitalName: 'Stanley Medical College',
        role: 'Emergency Medicine',
        salary: 3200,
        location: 'Royapuram, Chennai',
        dutyDate: today,
        startH: 20,
        endH: 8,
        lat: 13.0889,
        lng: 80.2917,
        specialization: 'Emergency Medicine',
        shiftType: 'Night',
        dutyType: 'Emergency',
        priority: DutyPriority.emergency,
        postedHoursAgo: 3,
        emergencyReason: 'Critical night emergency medicine coverage required.',
      ),
      d(
        id: 'seed_9',
        hospitalId: 'h_apollo_greams',
        hospitalName: 'Apollo Hospital',
        role: 'Anesthesiologist',
        salary: 4200,
        location: 'Greams Road, Chennai',
        dutyDate: tomorrow,
        startH: 7,
        endH: 15,
        lat: 13.0604,
        lng: 80.2496,
        specialization: 'Anesthesiology',
        shiftType: 'Day',
        dutyType: 'General Duty',
      ),
      d(
        id: 'seed_10',
        hospitalId: 'h_fortis',
        hospitalName: 'Fortis Malar Hospital',
        role: 'Radiologist',
        salary: 3800,
        location: 'Adyar, Chennai',
        dutyDate: today,
        startH: 9,
        endH: 17,
        lat: 13.0067,
        lng: 80.2206,
        specialization: 'Radiology',
        shiftType: 'Day',
        dutyType: 'OPD',
      ),
      d(
        id: 'seed_11',
        hospitalId: 'h_global',
        hospitalName: 'Gleneagles Global Health City',
        role: 'ICU Duty',
        salary: 4000,
        location: 'Perumbakkam, Chennai',
        dutyDate: tomorrow,
        startH: 19,
        endH: 7,
        lat: 12.8972,
        lng: 80.2270,
        specialization: 'ICU',
        shiftType: 'Night',
        dutyType: 'Night Duty',
      ),
      d(
        id: 'seed_12',
        hospitalId: 'h_billroth',
        hospitalName: 'Billroth Hospital',
        role: 'Dermatologist',
        salary: 2600,
        location: 'Shenoy Nagar, Chennai',
        dutyDate: today,
        startH: 11,
        endH: 19,
        lat: 13.0456,
        lng: 80.2334,
        specialization: 'Dermatology',
        shiftType: 'Evening',
        dutyType: 'OPD',
      ),
      d(
        id: 'seed_13',
        hospitalId: 'h_porur',
        hospitalName: 'Miot Hospital Porur',
        role: 'Weekend Duty',
        salary: 2700,
        location: 'Porur, Chennai',
        dutyDate: today.add(const Duration(days: 2)),
        startH: 8,
        endH: 20,
        lat: 13.0358,
        lng: 80.1568,
        specialization: 'General Physician',
        shiftType: 'Flexible',
        dutyType: 'Weekend Duty',
      ),
      d(
        id: 'seed_14',
        hospitalId: 'h_velachery',
        hospitalName: 'Dr. Kamakshi Memorial',
        role: 'Emergency Duty',
        salary: 3100,
        location: 'Velachery, Chennai',
        dutyDate: tomorrow,
        startH: 8,
        endH: 20,
        lat: 12.9750,
        lng: 80.2207,
        specialization: 'Emergency Medicine',
        shiftType: 'Day',
        dutyType: 'Emergency',
        verified: false,
      ),
      d(
        id: 'seed_emergency_surgery',
        hospitalId: 'h_apollo_avadi_main',
        hospitalName: 'Apollo Hospital',
        role: 'Emergency Surgery',
        salary: 5000,
        location: 'Avadi, Chennai',
        dutyDate: today,
        startH: 20,
        endH: 0,
        lat: 13.1155,
        lng: 80.0980,
        specialization: 'General Surgery',
        shiftType: 'Night',
        dutyType: 'Emergency',
        priority: DutyPriority.emergency,
        postedHoursAgo: 3,
        emergencyReason: 'Emergency surgical coverage required immediately.',
      ),
      d(
        id: 'seed_emergency_old',
        hospitalId: 'h_apollo_avadi_old',
        hospitalName: 'Apollo Hospital',
        role: 'Emergency Surgery',
        salary: 4800,
        location: 'Avadi, Chennai',
        dutyDate: today,
        startH: 20,
        endH: 0,
        lat: 13.1160,
        lng: 80.0990,
        specialization: 'General Surgery',
        shiftType: 'Night',
        dutyType: 'Emergency',
        priority: DutyPriority.emergency,
        postedHoursAgo: 30,
        emergencyReason: 'Expired emergency posting — should not appear.',
      ),
      d(
        id: 'seed_15',
        hospitalId: 'h_tambaram',
        hospitalName: 'Chennai Meenakshi Hospital',
        role: 'General Physician',
        salary: 2400,
        location: 'Tambaram, Chennai',
        dutyDate: today,
        startH: 9,
        endH: 17,
        lat: 12.9249,
        lng: 80.1000,
        specialization: 'General Physician',
        shiftType: 'Day',
        dutyType: 'General Duty',
      ),
    ];
  }
}
