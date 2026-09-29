import '../constants/account_status.dart';

class AccountStatusUtils {
  AccountStatusUtils._();

  static String readStatus(Map<String, dynamic>? data) {
    final raw = data?['accountStatus']?.toString().trim();
    if (raw == null || raw.isEmpty) return AccountStatus.active;
    return raw;
  }

  static bool isActive(Map<String, dynamic>? data) {
    return readStatus(data) == AccountStatus.active;
  }

  static bool isDeactivated(Map<String, dynamic>? data) {
    return readStatus(data) == AccountStatus.deactivated;
  }

  static bool isDiscoverable(Map<String, dynamic>? data) {
    if (!isActive(data)) return false;
    if (data?['isDiscoverable'] == false) return false;
    if (data?['profileVisible'] == false) return false;
    return true;
  }
}
