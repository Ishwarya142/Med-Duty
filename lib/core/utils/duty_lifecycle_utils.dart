import '../../models/application_model.dart';
import '../../models/duty_model.dart';

/// Duty availability and lifecycle helpers (status/date/deadline logic).
class DutyLifecycleUtils {
  DutyLifecycleUtils._();

  static bool isDutyEnded(DutyModel duty, [DateTime? now]) {
    final t = now ?? DateTime.now();
    return duty.endTime.isBefore(t) || duty.status == DutyStatus.completed;
  }

  static bool isDutyCancelled(DutyModel duty) =>
      duty.status == DutyStatus.cancelled;

  /// Duty should not appear in active Nearby/Recommended listings.
  static bool isExpiredForDiscovery(DutyModel duty, [DateTime? now]) {
    if (isDutyCancelled(duty)) return true;
    return isDutyEnded(duty, now);
  }

  static bool canApplyToDuty(DutyModel duty, [DateTime? now]) {
    if (isExpiredForDiscovery(duty, now)) return false;
    if (duty.status == DutyStatus.ongoing) return false;
    return true;
  }

  static bool isActiveApplication(ApplicationModel app, [DateTime? now]) {
    if (app.status == ApplicationStatus.withdrawn ||
        app.status == ApplicationStatus.rejected ||
        app.status == ApplicationStatus.completed) {
      return false;
    }
    return true;
  }

  static bool isUpcomingApplication(
    ApplicationModel app,
    DutyModel duty, [
    DateTime? now,
  ]) {
    if (app.status != ApplicationStatus.accepted) return false;
    return !isDutyEnded(duty, now);
  }

  static bool isCompletedApplication(
    ApplicationModel app,
    DutyModel duty, [
    DateTime? now,
  ]) {
    if (app.status == ApplicationStatus.completed) return true;
    if (app.status == ApplicationStatus.accepted && isDutyEnded(duty, now)) {
      return true;
    }
    return false;
  }
}
