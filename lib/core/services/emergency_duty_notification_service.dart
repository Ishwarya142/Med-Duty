import 'package:intl/intl.dart';

import '../../providers/duty_provider.dart';
import '../../providers/location_provider.dart';
import '../../providers/profile_provider.dart';
import '../utils/emergency_duty_utils.dart';
import '../utils/geo_utils.dart';
import 'notification_service.dart';

class EmergencyDutyNotification {
  final String id;
  final String dutyId;
  final String title;
  final String body;
  final DateTime createdAt;

  const EmergencyDutyNotification({
    required this.id,
    required this.dutyId,
    required this.title,
    required this.body,
    required this.createdAt,
  });
}

/// In-app emergency duty alerts for eligible nearby doctors.
class EmergencyDutyNotificationService {
  EmergencyDutyNotificationService._();

  static final EmergencyDutyNotificationService instance =
      EmergencyDutyNotificationService._();

  final Set<String> _notifiedDutyIds = {};
  final List<EmergencyDutyNotification> _notifications = [];

  List<EmergencyDutyNotification> get notifications =>
      List.unmodifiable(_notifications);

  void checkNewEmergencies({
    required DutyProvider duties,
    required LocationProvider location,
    required ProfileProvider profile,
  }) {
    if (location.searchLocation == null) return;

    final specialization = profile.specialization.isNotEmpty
        ? profile.specialization
        : profile.qualification;
    final radiusKm = location.radiusKm;

    for (final item
        in duties.emergencyNearby(location, specialization: specialization)) {
      final duty = item.duty;
      if (_notifiedDutyIds.contains(duty.id)) continue;

      final dist = item.distanceKm;
      if (!EmergencyDutyUtils.isEligibleRecipient(
        duty: duty,
        userSpecialization: specialization,
        distanceKm: dist,
        radiusKm: radiusKm,
      )) {
        continue;
      }

      _notifiedDutyIds.add(duty.id);
      final distLabel = dist != null ? formatDistanceKm(dist) : 'nearby';
      final timeFmt = DateFormat('h:mm a');
      final dateLabel = _dateLabel(duty.dutyDate);
      final notification = EmergencyDutyNotification(
        id: 'emg_${duty.id}_${DateTime.now().millisecondsSinceEpoch}',
        dutyId: duty.id,
        title: 'Emergency Specialist Required',
        body:
            '${duty.role}\n${duty.displaySpecialization} required at ${duty.hospitalName}.\n\n'
            '📍 ${duty.location} • $distLabel away\n'
            '$dateLabel • ${timeFmt.format(duty.startTime)}\n'
            '₹${duty.salary.toStringAsFixed(0)}',
        createdAt: DateTime.now(),
      );
      _notifications.insert(0, notification);

      NotificationService.instance.showEmergencyDutyAlert(
        title: '🚨 ${notification.title}',
        body: notification.body,
        dutyId: duty.id,
      );
    }
  }

  String _dateLabel(DateTime date) {
    final now = DateTime.now();
    if (date.year == now.year &&
        date.month == now.month &&
        date.day == now.day) {
      return 'Today';
    }
    return DateFormat('d MMM').format(date);
  }

  void clear() {
    _notifications.clear();
    _notifiedDutyIds.clear();
  }
}
