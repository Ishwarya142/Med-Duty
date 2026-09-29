import '../../models/duty_model.dart';
import '../../models/duty_with_distance.dart';

/// Sorting and eligibility helpers for emergency duties.
class EmergencyDutyUtils {
  EmergencyDutyUtils._();

  /// Emergency postings remain discoverable for 24 hours after creation.
  static const int postingWindowHours = 24;

  /// Duty must start today or within this many hours from now.
  static const int startSoonHours = 24;

  /// True only when the hospital explicitly set [DutyPriority.emergency]
  /// and all time/specialty/status rules pass.
  static bool isActiveEmergency(DutyModel duty) {
    if (duty.priority != DutyPriority.emergency) return false;
    if (duty.status != DutyStatus.upcoming) return false;
    if (!hasRequiredSpecialty(duty)) return false;
    if (!isPostedWithin24Hours(duty)) return false;
    return startsTodayOrSoon(duty);
  }

  static bool hasRequiredSpecialty(DutyModel duty) {
    return duty.specialization != null && duty.specialization!.trim().isNotEmpty;
  }

  static bool isPostedWithin24Hours(DutyModel duty) {
    final age = DateTime.now().difference(duty.createdAt);
    return age.inHours < postingWindowHours;
  }

  /// Duty is today OR starts within the immediate upcoming window.
  static bool startsTodayOrSoon(DutyModel duty) {
    final now = DateTime.now();
    if (duty.endTime.isBefore(now)) return false;

    final today = DateTime(now.year, now.month, now.day);
    final dutyDay = DateTime(
      duty.dutyDate.year,
      duty.dutyDate.month,
      duty.dutyDate.day,
    );
    if (dutyDay == today) return true;

    final hoursUntilStart = duty.startTime.difference(now).inMinutes / 60.0;
    return hoursUntilStart >= 0 && hoursUntilStart <= startSoonHours;
  }

  /// Uses the doctor's selected search radius from [LocationProvider].
  static bool isWithinEmergencyRadius(double? distanceKm, double radiusKm) {
    if (distanceKm == null) return false;
    return distanceKm <= radiusKm;
  }

  /// Notification targeting — specialty must match the doctor's profile.
  static bool isEligibleRecipient({
    required DutyModel duty,
    required String? userSpecialization,
    required double? distanceKm,
    required double radiusKm,
  }) {
    if (!isActiveEmergency(duty)) return false;
    if (!isWithinEmergencyRadius(distanceKm, radiusKm)) return false;
    return specialtyMatches(userSpecialization, duty);
  }

  static bool specialtyMatches(String? userSpecialization, DutyModel duty) {
    final spec = userSpecialization?.trim().toLowerCase() ?? '';
    if (spec.isEmpty) return false;

    final required = duty.displaySpecialization.toLowerCase();
    final role = duty.role.toLowerCase();
    final haystack = '$required $role';

    if (haystack.contains(spec) || spec.contains(required)) return true;
    if (spec.contains('general') &&
        (required.contains('general') || role.contains('general'))) {
      return true;
    }

    const pairs = <List<String>>[
      ['surgery', 'surgeon'],
      ['cardio', 'cardiac'],
      ['pediatr', 'pediatric'],
      ['anesth', 'anaesth'],
      ['ortho', 'orthopedic'],
      ['icu', 'critical care'],
      ['emergency', 'emergency medicine'],
    ];
    for (final pair in pairs) {
      final userHit = pair.any((k) => spec.contains(k));
      final dutyHit = pair.any((k) => haystack.contains(k));
      if (userHit && dutyHit) return true;
    }
    return false;
  }

  static void sortByRelevance(
    List<DutyWithDistance> list, {
    String? userSpecialization,
  }) {
    final spec = userSpecialization?.trim().toLowerCase() ?? '';
    list.sort((a, b) {
      final aScore = _relevanceScore(a, spec);
      final bScore = _relevanceScore(b, spec);
      return aScore.compareTo(bScore);
    });
  }

  static double _relevanceScore(DutyWithDistance item, String userSpec) {
    final duty = item.duty;
    var score = 0.0;
    score += (item.distanceKm ?? 50) * 10;
    score -= duty.createdAt.millisecondsSinceEpoch / 1e9;

    if (userSpec.isNotEmpty && specialtyMatches(userSpec, duty)) {
      score -= 800;
    }

    score -= duty.startTime.difference(DateTime.now()).inHours.abs() * 2;
    return score;
  }
}
