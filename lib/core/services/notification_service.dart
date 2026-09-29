import 'package:flutter/foundation.dart';

typedef EmergencyNotificationTapHandler = void Function(String dutyId);

class NotificationService {
  NotificationService._();
  static final NotificationService instance = NotificationService._();

  EmergencyNotificationTapHandler? onEmergencyDutyTap;

  Future<void> initialize() async {}

  Future<void> sendNotification({
    required String title,
    required String body,
  }) async {
    debugPrint('Notification: $title — $body');
  }

  Future<void> showEmergencyDutyAlert({
    required String title,
    required String body,
    required String dutyId,
  }) async {
    debugPrint('Emergency alert [$dutyId]: $title — $body');
    await sendNotification(title: title, body: body);
  }
}
