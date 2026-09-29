import '../../models/duty_model.dart';
import '../../models/duty_with_distance.dart';
import '../utils/geo_utils.dart';
import 'duty_discovery_service.dart';

/// Suggests duties when the current radius returns no (or few) matches.
/// Demo fallbacks are clearly marked via [DutyModel.id] prefix `rec_demo_`.
class RecommendedDutiesService {
  RecommendedDutiesService._();

  static final _discovery = DutyDiscoveryService();

  static List<DutyWithDistance> build({
    required double centerLat,
    required double centerLng,
    required double currentRadiusKm,
    String specialization = '',
    String locationLabel = '',
    Set<String> excludeDutyIds = const {},
    int limit = 6,
  }) {
    final spec = specialization.trim().toLowerCase();
    final area = locationLabel.toLowerCase();

    final candidates = <_ScoredDuty>[];

    // Wider search from existing open/seed duties (not limited to current radius).
    for (final duty in _discovery.fetchOpenDutiesSync()) {
      if (excludeDutyIds.contains(duty.id)) continue;
      if (duty.priority == DutyPriority.emergency) continue;

      double? dist;
      if (duty.hasCoordinates) {
        dist = distanceKm(
          centerLat,
          centerLng,
          duty.latitude!,
          duty.longitude!,
        );
      }

      var score = 0.0;
      if (spec.isNotEmpty) {
        final hay =
            '${duty.role} ${duty.specialization ?? ''} ${duty.dutyType ?? ''}'
                .toLowerCase();
        if (hay.contains(spec)) score += 80;
        if (spec.contains('general') && hay.contains('general')) score += 40;
        if (spec.contains('physician') && hay.contains('physician')) {
          score += 30;
        }
      }
      if (area.isNotEmpty && duty.location.toLowerCase().contains(area.split(',').first.trim())) {
        score += 50;
      }
      for (final keyword in ['avadi', 'ambattur', 'poonamallee', 'thiruvallur', 'chennai']) {
        if (duty.location.toLowerCase().contains(keyword)) score += 8;
      }
      if (dist != null) {
        score += (50 - dist.clamp(0, 50));
      }
      if (duty.verified) score += 5;
      score += duty.salary / 500;

      candidates.add(_ScoredDuty(DutyWithDistance(duty: duty, distanceKm: dist), score));
    }

    for (final duty in _demoFallbackDuties()) {
      if (excludeDutyIds.contains(duty.id)) continue;
      final dist = duty.hasCoordinates
          ? distanceKm(centerLat, centerLng, duty.latitude!, duty.longitude!)
          : null;
      var score = 30.0;
      if (spec.isNotEmpty &&
          '${duty.role} ${duty.specialization ?? ''}'.toLowerCase().contains(spec)) {
        score += 60;
      }
      candidates.add(_ScoredDuty(DutyWithDistance(duty: duty, distanceKm: dist), score));
    }

    candidates.sort((a, b) => b.score.compareTo(a.score));

    final seen = <String>{};
    final results = <DutyWithDistance>[];
    for (final c in candidates) {
      if (seen.add(c.item.duty.id)) {
        results.add(c.item);
      }
      if (results.length >= limit) break;
    }
    return results;
  }

  static bool isDemoRecommendation(String dutyId) => dutyId.startsWith('rec_demo_');

  static List<DutyModel> _demoFallbackDuties() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    DutyModel demo({
      required String id,
      required String hospitalName,
      required String role,
      required double salary,
      required String location,
      required int startH,
      required int endH,
      required double lat,
      required double lng,
      required String specialization,
      required String shiftType,
      required String dutyType,
    }) {
      return DutyModel(
        id: id,
        hospitalId: 'demo_hospital',
        hospitalName: hospitalName,
        role: role,
        salary: salary,
        location: location,
        dutyDate: today,
        startTime: DateTime(today.year, today.month, today.day, startH),
        endTime: DateTime(
          today.year,
          today.month,
          today.day + (endH <= startH ? 1 : 0),
          endH % 24,
        ),
        status: DutyStatus.upcoming,
        latitude: lat,
        longitude: lng,
        specialization: specialization,
        shiftType: shiftType,
        dutyType: dutyType,
        verified: false,
        createdAt: now,
      );
    }

    return [
      demo(
        id: 'rec_demo_1',
        hospitalName: 'Apollo Clinic',
        role: 'General Physician',
        salary: 2500,
        location: 'Avadi, Chennai',
        startH: 9,
        endH: 17,
        lat: 13.1148,
        lng: 80.0982,
        specialization: 'General Physician',
        shiftType: 'Day',
        dutyType: 'Day Shift',
      ),
      demo(
        id: 'rec_demo_2',
        hospitalName: 'Government Hospital',
        role: 'Emergency Duty',
        salary: 3200,
        location: 'Ambattur, Chennai',
        startH: 8,
        endH: 20,
        lat: 13.0982,
        lng: 80.1612,
        specialization: 'Emergency Medicine',
        shiftType: 'Day',
        dutyType: 'Emergency',
      ),
      demo(
        id: 'rec_demo_3',
        hospitalName: 'City Care Hospital',
        role: 'Night Duty',
        salary: 3500,
        location: 'Poonamallee, Chennai',
        startH: 19,
        endH: 7,
        lat: 13.0480,
        lng: 80.1098,
        specialization: 'General Medicine',
        shiftType: 'Night',
        dutyType: 'Night Shift',
      ),
      demo(
        id: 'rec_demo_4',
        hospitalName: 'Sri Hospital',
        role: 'Medical Officer',
        salary: 2800,
        location: 'Thiruvallur',
        startH: 10,
        endH: 18,
        lat: 13.1430,
        lng: 79.9080,
        specialization: 'General Medicine',
        shiftType: 'Day',
        dutyType: 'Day Shift',
      ),
    ];
  }
}

class _ScoredDuty {
  final DutyWithDistance item;
  final double score;
  const _ScoredDuty(this.item, this.score);
}
