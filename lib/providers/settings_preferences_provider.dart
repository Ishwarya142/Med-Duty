import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum OnlineStatusPreference { everyone, connections, nobody }

class BlockedUserEntry {
  final String id;
  final String name;
  final String role;

  const BlockedUserEntry({
    required this.id,
    required this.name,
    required this.role,
  });

  Map<String, String> toMap() => {'id': id, 'name': name, 'role': role};

  factory BlockedUserEntry.fromMap(Map<String, dynamic> map) {
    return BlockedUserEntry(
      id: map['id']?.toString() ?? '',
      name: map['name']?.toString() ?? 'User',
      role: map['role']?.toString() ?? 'Healthcare Professional',
    );
  }
}

class SettingsPreferencesProvider extends ChangeNotifier {
  static const _pushKey = 'settings_push_notifications';
  static const _dutyKey = 'settings_duty_alerts';
  static const _dutyNearbyKey = 'settings_duty_nearby';
  static const _dutyUrgentKey = 'settings_duty_urgent';
  static const _dutySavedKey = 'settings_duty_saved';
  static const _dutyEmergencyKey = 'settings_duty_emergency';
  static const _jobKey = 'settings_job_alerts';
  static const _jobRecommendationsKey = 'settings_job_recommendations';
  static const _jobApplicationsKey = 'settings_job_applications';
  static const _communityActivityKey = 'settings_community_activity';
  static const _communityCommentsKey = 'settings_community_comments';
  static const _communityLikesKey = 'settings_community_likes';
  static const _communityFollowersKey = 'settings_community_followers';
  static const _msgNewKey = 'settings_msg_new';
  static const _msgRequestsKey = 'settings_msg_requests';
  static const _msgGroupKey = 'settings_msg_group';
  static const _msgPreviewKey = 'settings_msg_preview';
  static const _msgCallsKey = 'settings_msg_calls';
  static const _onlineStatusKey = 'settings_online_status';
  static const _biometricKey = 'settings_biometric';
  static const _languageKey = 'settings_language';
  static const _blockedUsersKey = 'settings_blocked_users';
  static const _lastActiveKey = 'settings_last_active';
  static const _reportsKey = 'settings_issue_reports';
  static const _twoFactorKey = 'settings_two_factor_enabled';
  static const _twoFactorPinKey = 'settings_two_factor_pin_hash';

  bool _loaded = false;
  bool pushNotifications = true;
  bool dutyAlerts = true;
  bool dutyNearby = true;
  bool dutyUrgent = true;
  bool dutySaved = true;
  bool dutyEmergency = true;
  bool jobAlerts = true;
  bool jobRecommendations = true;
  bool jobApplications = true;
  bool communityActivity = true;
  bool communityComments = true;
  bool communityLikes = true;
  bool communityFollowers = true;
  bool messageNew = true;
  bool messageRequests = true;
  bool messageGroup = true;
  bool messagePreview = true;
  bool messageCalls = true;
  OnlineStatusPreference onlineStatus = OnlineStatusPreference.everyone;
  bool biometricEnabled = false;
  String language = 'English';
  bool twoFactorEnabled = false;
  String? twoFactorPinHash;
  List<BlockedUserEntry> blockedUsers = [];

  bool get isLoaded => _loaded;

  Locale get locale {
    switch (language) {
      case 'தமிழ்':
        return const Locale('ta');
      case 'తెలుగు':
        return const Locale('te');
      case 'ಕನ್ನಡ':
        return const Locale('kn');
      case 'മലയാളം':
        return const Locale('ml');
      case 'हिन्दी':
        return const Locale('hi');
      default:
        return const Locale('en');
    }
  }

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    pushNotifications = prefs.getBool(_pushKey) ?? true;
    dutyAlerts = prefs.getBool(_dutyKey) ?? true;
    dutyNearby = prefs.getBool(_dutyNearbyKey) ?? true;
    dutyUrgent = prefs.getBool(_dutyUrgentKey) ?? true;
    dutySaved = prefs.getBool(_dutySavedKey) ?? true;
    dutyEmergency = prefs.getBool(_dutyEmergencyKey) ?? true;
    jobAlerts = prefs.getBool(_jobKey) ?? true;
    jobRecommendations = prefs.getBool(_jobRecommendationsKey) ?? true;
    jobApplications = prefs.getBool(_jobApplicationsKey) ?? true;
    communityActivity = prefs.getBool(_communityActivityKey) ?? true;
    communityComments = prefs.getBool(_communityCommentsKey) ?? true;
    communityLikes = prefs.getBool(_communityLikesKey) ?? true;
    communityFollowers = prefs.getBool(_communityFollowersKey) ?? true;
    messageNew = prefs.getBool(_msgNewKey) ?? true;
    messageRequests = prefs.getBool(_msgRequestsKey) ?? true;
    messageGroup = prefs.getBool(_msgGroupKey) ?? true;
    messagePreview = prefs.getBool(_msgPreviewKey) ?? true;
    messageCalls = prefs.getBool(_msgCallsKey) ?? true;
    biometricEnabled = prefs.getBool(_biometricKey) ?? false;
    language = prefs.getString(_languageKey) ?? 'English';
    twoFactorEnabled = prefs.getBool(_twoFactorKey) ?? false;
    twoFactorPinHash = prefs.getString(_twoFactorPinKey);
    final statusIndex = prefs.getInt(_onlineStatusKey) ?? 0;
    onlineStatus = OnlineStatusPreference.values[statusIndex.clamp(0, 2)];
    final blockedRaw = prefs.getString(_blockedUsersKey);
    if (blockedRaw != null) {
      try {
        final list = jsonDecode(blockedRaw) as List<dynamic>;
        blockedUsers = list
            .map((e) => BlockedUserEntry.fromMap(Map<String, dynamic>.from(e as Map)))
            .toList();
      } catch (_) {
        blockedUsers = [];
      }
    }
    await prefs.setString(_lastActiveKey, DateTime.now().toIso8601String());
    _loaded = true;
    notifyListeners();
  }

  Future<void> _saveBool(String key, bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(key, value);
  }

  Future<void> setPushNotifications(bool value) async {
    pushNotifications = value;
    await _saveBool(_pushKey, value);
    notifyListeners();
  }

  Future<void> setDutyAlerts(bool value) async {
    dutyAlerts = value;
    await _saveBool(_dutyKey, value);
    notifyListeners();
  }

  Future<void> setDutyNearby(bool value) async {
    dutyNearby = value;
    await _saveBool(_dutyNearbyKey, value);
    notifyListeners();
  }

  Future<void> setDutyUrgent(bool value) async {
    dutyUrgent = value;
    await _saveBool(_dutyUrgentKey, value);
    notifyListeners();
  }

  Future<void> setDutySaved(bool value) async {
    dutySaved = value;
    await _saveBool(_dutySavedKey, value);
    notifyListeners();
  }

  Future<void> setDutyEmergency(bool value) async {
    dutyEmergency = value;
    await _saveBool(_dutyEmergencyKey, value);
    notifyListeners();
  }

  Future<void> setJobAlerts(bool value) async {
    jobAlerts = value;
    await _saveBool(_jobKey, value);
    notifyListeners();
  }

  Future<void> setJobRecommendations(bool value) async {
    jobRecommendations = value;
    await _saveBool(_jobRecommendationsKey, value);
    notifyListeners();
  }

  Future<void> setJobApplications(bool value) async {
    jobApplications = value;
    await _saveBool(_jobApplicationsKey, value);
    notifyListeners();
  }

  Future<void> setCommunityActivity(bool value) async {
    communityActivity = value;
    await _saveBool(_communityActivityKey, value);
    notifyListeners();
  }

  Future<void> setCommunityComments(bool value) async {
    communityComments = value;
    await _saveBool(_communityCommentsKey, value);
    notifyListeners();
  }

  Future<void> setCommunityLikes(bool value) async {
    communityLikes = value;
    await _saveBool(_communityLikesKey, value);
    notifyListeners();
  }

  Future<void> setCommunityFollowers(bool value) async {
    communityFollowers = value;
    await _saveBool(_communityFollowersKey, value);
    notifyListeners();
  }

  Future<void> setMessageNew(bool value) async {
    messageNew = value;
    await _saveBool(_msgNewKey, value);
    notifyListeners();
  }

  Future<void> setMessageRequests(bool value) async {
    messageRequests = value;
    await _saveBool(_msgRequestsKey, value);
    notifyListeners();
  }

  Future<void> setMessageGroup(bool value) async {
    messageGroup = value;
    await _saveBool(_msgGroupKey, value);
    notifyListeners();
  }

  Future<void> setMessagePreview(bool value) async {
    messagePreview = value;
    await _saveBool(_msgPreviewKey, value);
    notifyListeners();
  }

  Future<void> setMessageCalls(bool value) async {
    messageCalls = value;
    await _saveBool(_msgCallsKey, value);
    notifyListeners();
  }

  Future<void> setOnlineStatus(OnlineStatusPreference value) async {
    onlineStatus = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_onlineStatusKey, value.index);
    notifyListeners();
  }

  Future<void> setBiometricEnabled(bool value) async {
    biometricEnabled = value;
    await _saveBool(_biometricKey, value);
    notifyListeners();
  }

  Future<void> setLanguage(String value) async {
    language = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_languageKey, value);
    notifyListeners();
  }

  static String hashTwoFactorCode(String code) {
    var hash = 5381;
    for (final unit in code.codeUnits) {
      hash = ((hash << 5) + hash + unit) & 0x7fffffff;
    }
    return hash.toRadixString(16);
  }

  bool verifyTwoFactorCode(String code) {
    if (!twoFactorEnabled || twoFactorPinHash == null) return true;
    return hashTwoFactorCode(code) == twoFactorPinHash;
  }

  Future<void> enableTwoFactor(String code) async {
    twoFactorEnabled = true;
    twoFactorPinHash = hashTwoFactorCode(code);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_twoFactorKey, true);
    await prefs.setString(_twoFactorPinKey, twoFactorPinHash!);
    notifyListeners();
  }

  Future<void> disableTwoFactor() async {
    twoFactorEnabled = false;
    twoFactorPinHash = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_twoFactorKey, false);
    await prefs.remove(_twoFactorPinKey);
    notifyListeners();
  }

  bool isUserBlocked(String id) {
    if (id.isEmpty) return false;
    return blockedUsers.any((u) => u.id == id);
  }

  Future<void> unblockUser(String id) async {
    blockedUsers.removeWhere((u) => u.id == id);
    await _persistBlockedUsers();
    notifyListeners();
  }

  Future<void> addBlockedUser(BlockedUserEntry entry) async {
    if (blockedUsers.any((u) => u.id == entry.id)) return;
    blockedUsers.add(entry);
    await _persistBlockedUsers();
    notifyListeners();
  }

  Future<void> blockUser({
    required String id,
    required String name,
    required String role,
  }) async {
    await addBlockedUser(BlockedUserEntry(id: id, name: name, role: role));
  }

  Future<void> _persistBlockedUsers() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _blockedUsersKey,
      jsonEncode(blockedUsers.map((e) => e.toMap()).toList()),
    );
  }

  Future<void> saveIssueReport(Map<String, String> report) async {
    final prefs = await SharedPreferences.getInstance();
    final existing = prefs.getStringList(_reportsKey) ?? [];
    existing.add(jsonEncode(report));
    await prefs.setStringList(_reportsKey, existing);
  }

  Future<DateTime?> lastActive() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_lastActiveKey);
    if (raw == null) return null;
    return DateTime.tryParse(raw);
  }

  bool get showOnlineStatus {
    return onlineStatus != OnlineStatusPreference.nobody;
  }
}
