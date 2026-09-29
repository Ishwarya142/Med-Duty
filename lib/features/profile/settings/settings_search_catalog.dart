import 'package:flutter/material.dart';

import '../../../core/l10n/app_localizations.dart';

/// A searchable Settings entry that reuses existing navigation actions.
class SettingsSearchItem {
  const SettingsSearchItem({
    required this.title,
    required this.section,
    required this.icon,
    required this.onTap,
    this.keywords = const [],
  });

  final String title;
  final String section;
  final IconData icon;
  final VoidCallback onTap;
  final List<String> keywords;

  String get _normalizedHaystack {
    return [
      title,
      section,
      ...keywords,
    ].join(' ').toLowerCase();
  }

  /// Lower is better: 0 = exact title, 1 = starts with, 2 = contains, 3 = keyword/section.
  int matchRank(String query) {
    final q = query.trim().toLowerCase();
    if (q.isEmpty) return 0;

    final normalizedTitle = title.toLowerCase();
    if (normalizedTitle == q) return 0;
    if (normalizedTitle.startsWith(q)) return 1;
    if (normalizedTitle.contains(q)) return 2;

    for (final keyword in keywords) {
      final k = keyword.toLowerCase();
      if (k == q) return 2;
      if (k.startsWith(q) || k.contains(q)) return 3;
    }

    final sec = section.toLowerCase();
    if (sec.contains(q)) return 3;

    if (_normalizedHaystack.contains(q)) return 3;
    return -1;
  }
}

List<SettingsSearchItem> filterSettingsSearchItems(
  List<SettingsSearchItem> items,
  String query,
) {
  final q = query.trim();
  if (q.isEmpty) return List<SettingsSearchItem>.from(items);

  final ranked = <({SettingsSearchItem item, int rank})>[];
  for (final item in items) {
    final rank = item.matchRank(q);
    if (rank >= 0) ranked.add((item: item, rank: rank));
  }

  ranked.sort((a, b) {
    final rankCompare = a.rank.compareTo(b.rank);
    if (rankCompare != 0) return rankCompare;
    return a.item.title.toLowerCase().compareTo(b.item.title.toLowerCase());
  });

  return ranked.map((e) => e.item).toList();
}

/// Navigation callbacks for every searchable Settings destination.
class SettingsSearchActions {
  const SettingsSearchActions({
    required this.openAccountInfo,
    required this.openChangePassword,
    required this.openEmailPhone,
    required this.openDeactivateAccount,
    required this.openDeleteAccount,
    required this.openPushNotifications,
    required this.openDutyAlerts,
    required this.openCommunityNotifications,
    required this.openMessageNotifications,
    required this.openProfileVisibility,
    required this.openOnlineStatus,
    required this.openFollowersFollowing,
    required this.openBlockedUsers,
    required this.openBiometric,
    required this.openTwoFactor,
    required this.openLoginActivity,
    required this.openTrustedDevices,
    required this.openAppearance,
    required this.openLanguage,
    required this.openPermissions,
    required this.openHelpCenter,
    required this.openFaq,
    required this.openReportIssue,
    required this.openContactSupport,
    required this.openTerms,
    required this.openPrivacyPolicy,
    required this.openAppVersion,
    this.openDutyPreferences,
    this.openJobPreferences,
    this.openConnectedAccounts,
  });

  final VoidCallback openAccountInfo;
  final VoidCallback openChangePassword;
  final VoidCallback openEmailPhone;
  final VoidCallback openDeactivateAccount;
  final VoidCallback openDeleteAccount;
  final VoidCallback openPushNotifications;
  final VoidCallback openDutyAlerts;
  final VoidCallback openCommunityNotifications;
  final VoidCallback openMessageNotifications;
  final VoidCallback openProfileVisibility;
  final VoidCallback openOnlineStatus;
  final VoidCallback openFollowersFollowing;
  final VoidCallback openBlockedUsers;
  final VoidCallback openBiometric;
  final VoidCallback openTwoFactor;
  final VoidCallback openLoginActivity;
  final VoidCallback openTrustedDevices;
  final VoidCallback openAppearance;
  final VoidCallback openLanguage;
  final VoidCallback openPermissions;
  final VoidCallback openHelpCenter;
  final VoidCallback openFaq;
  final VoidCallback openReportIssue;
  final VoidCallback openContactSupport;
  final VoidCallback openTerms;
  final VoidCallback openPrivacyPolicy;
  final VoidCallback openAppVersion;
  final VoidCallback? openDutyPreferences;
  final VoidCallback? openJobPreferences;
  final VoidCallback? openConnectedAccounts;
}

List<SettingsSearchItem> buildSettingsSearchCatalog({
  required AppLocalizations l10n,
  required SettingsSearchActions actions,
}) {
  return [
    SettingsSearchItem(
      title: l10n.accountInfo,
      section: l10n.account,
      icon: Icons.person_outline_rounded,
      keywords: const ['account', 'profile', 'information', 'personal'],
      onTap: actions.openAccountInfo,
    ),
    SettingsSearchItem(
      title: l10n.changePassword,
      section: l10n.account,
      icon: Icons.lock_outline_rounded,
      keywords: const ['password', 'pass', 'security', 'credentials'],
      onTap: actions.openChangePassword,
    ),
    SettingsSearchItem(
      title: l10n.emailPhone,
      section: l10n.account,
      icon: Icons.alternate_email_rounded,
      keywords: const ['email', 'phone', 'contact', 'mobile'],
      onTap: actions.openEmailPhone,
    ),
    if (actions.openConnectedAccounts != null)
      SettingsSearchItem(
        title: 'Connected Accounts',
        section: l10n.account,
        icon: Icons.link_rounded,
        keywords: const ['google', 'connected', 'accounts', 'login'],
        onTap: actions.openConnectedAccounts!,
      ),
    SettingsSearchItem(
      title: l10n.deactivateAccount,
      section: l10n.account,
      icon: Icons.pause_circle_outline,
      keywords: const ['deactivate', 'hide', 'temporary', 'pause'],
      onTap: actions.openDeactivateAccount,
    ),
    SettingsSearchItem(
      title: l10n.deleteAccount,
      section: l10n.account,
      icon: Icons.delete_forever_outlined,
      keywords: const ['delete', 'remove', 'permanent', 'erase'],
      onTap: actions.openDeleteAccount,
    ),
    if (actions.openDutyPreferences != null)
      SettingsSearchItem(
        title: 'Duty Preferences',
        section: 'Duties & Jobs',
        icon: Icons.assignment_outlined,
        keywords: const ['duty', 'preferences', 'radius', 'pay', 'shift', 'travel'],
        onTap: actions.openDutyPreferences!,
      ),
    if (actions.openJobPreferences != null)
      SettingsSearchItem(
        title: 'Job Preferences',
        section: 'Duties & Jobs',
        icon: Icons.work_outline_rounded,
        keywords: const ['job', 'preferences', 'salary', 'experience', 'career'],
        onTap: actions.openJobPreferences!,
      ),
    SettingsSearchItem(
      title: 'Push Notifications',
      section: l10n.notifications,
      icon: Icons.notifications_none_rounded,
      keywords: [l10n.push, 'notification', 'alerts', 'push'],
      onTap: actions.openPushNotifications,
    ),
    SettingsSearchItem(
      title: l10n.dutyAlerts,
      section: l10n.notifications,
      icon: Icons.calendar_today_rounded,
      keywords: const ['duty', 'shift', 'job', 'notification'],
      onTap: actions.openDutyAlerts,
    ),
    SettingsSearchItem(
      title: 'Community Notifications',
      section: l10n.notifications,
      icon: Icons.people_outline_rounded,
      keywords: [l10n.community, 'notification', 'posts', 'social'],
      onTap: actions.openCommunityNotifications,
    ),
    SettingsSearchItem(
      title: 'Messages Notifications',
      section: l10n.notifications,
      icon: Icons.chat_bubble_outline_rounded,
      keywords: [l10n.messages, 'notification', 'chat', 'sms'],
      onTap: actions.openMessageNotifications,
    ),
    SettingsSearchItem(
      title: l10n.profileVisibility,
      section: l10n.privacy,
      icon: Icons.visibility_outlined,
      keywords: const ['privacy', 'profile', 'visible', 'public'],
      onTap: actions.openProfileVisibility,
    ),
    SettingsSearchItem(
      title: l10n.onlineStatus,
      section: l10n.privacy,
      icon: Icons.wifi_tethering_rounded,
      keywords: const ['online', 'status', 'availability', 'privacy'],
      onTap: actions.openOnlineStatus,
    ),
    SettingsSearchItem(
      title: l10n.followersFollowing,
      section: l10n.privacy,
      icon: Icons.supervisor_account_outlined,
      keywords: const ['followers', 'following', 'connections', 'social'],
      onTap: actions.openFollowersFollowing,
    ),
    SettingsSearchItem(
      title: l10n.blockedUsers,
      section: l10n.privacy,
      icon: Icons.block_outlined,
      keywords: const ['block', 'blocked', 'users', 'privacy'],
      onTap: actions.openBlockedUsers,
    ),
    SettingsSearchItem(
      title: l10n.biometricLogin,
      section: l10n.security,
      icon: Icons.face_rounded,
      keywords: const ['biometric', 'face id', 'fingerprint', 'login'],
      onTap: actions.openBiometric,
    ),
    SettingsSearchItem(
      title: 'Two-Factor Authentication',
      section: l10n.security,
      icon: Icons.shield_outlined,
      keywords: [l10n.twoFactorAuth, '2fa', 'security', 'authentication'],
      onTap: actions.openTwoFactor,
    ),
    SettingsSearchItem(
      title: l10n.loginActivity,
      section: l10n.security,
      icon: Icons.login_rounded,
      keywords: const ['login', 'activity', 'sessions', 'sign in'],
      onTap: actions.openLoginActivity,
    ),
    SettingsSearchItem(
      title: l10n.trustedDevices,
      section: l10n.security,
      icon: Icons.verified_user_outlined,
      keywords: const ['trusted', 'devices', 'security', 'phone'],
      onTap: actions.openTrustedDevices,
    ),
    SettingsSearchItem(
      title: l10n.appearance,
      section: l10n.preferences,
      icon: Icons.dark_mode_outlined,
      keywords: const ['theme', 'dark', 'light', 'mode', 'display'],
      onTap: actions.openAppearance,
    ),
    SettingsSearchItem(
      title: l10n.language,
      section: l10n.preferences,
      icon: Icons.translate_outlined,
      keywords: const ['language', 'locale', 'tamil', 'hindi', 'english', 'kannada', 'malayalam', 'telugu'],
      onTap: actions.openLanguage,
    ),
    SettingsSearchItem(
      title: l10n.permissions,
      section: l10n.preferences,
      icon: Icons.admin_panel_settings_outlined,
      keywords: const ['permission', 'camera', 'location', 'microphone'],
      onTap: actions.openPermissions,
    ),
    SettingsSearchItem(
      title: l10n.helpCenter,
      section: l10n.support,
      icon: Icons.help_outline_rounded,
      keywords: const ['help', 'support', 'guide', 'how to'],
      onTap: actions.openHelpCenter,
    ),
    SettingsSearchItem(
      title: l10n.faq,
      section: l10n.support,
      icon: Icons.quiz_outlined,
      keywords: const ['faq', 'questions', 'answers', 'help'],
      onTap: actions.openFaq,
    ),
    SettingsSearchItem(
      title: l10n.reportIssue,
      section: l10n.support,
      icon: Icons.report_gmailerrorred_outlined,
      keywords: const ['report', 'issue', 'bug', 'problem'],
      onTap: actions.openReportIssue,
    ),
    SettingsSearchItem(
      title: l10n.contactSupport,
      section: l10n.support,
      icon: Icons.contact_support_outlined,
      keywords: const ['contact', 'support', 'email', 'call', 'help'],
      onTap: actions.openContactSupport,
    ),
    SettingsSearchItem(
      title: l10n.terms,
      section: l10n.legalAbout,
      icon: Icons.description_outlined,
      keywords: const ['terms', 'conditions', 'legal', 'agreement'],
      onTap: actions.openTerms,
    ),
    SettingsSearchItem(
      title: l10n.privacyPolicy,
      section: l10n.legalAbout,
      icon: Icons.privacy_tip_outlined,
      keywords: const ['privacy', 'policy', 'legal', 'data'],
      onTap: actions.openPrivacyPolicy,
    ),
    SettingsSearchItem(
      title: l10n.appVersion,
      section: l10n.legalAbout,
      icon: Icons.info_outline_rounded,
      keywords: const ['version', 'app', 'about', 'update'],
      onTap: actions.openAppVersion,
    ),
  ];
}

/// Frequently used items shown in the empty search state.
List<SettingsSearchItem> commonSettingsSearchItems(
  List<SettingsSearchItem> all,
  AppLocalizations l10n,
) {
  final preferredTitles = [
    'Duty Preferences',
    l10n.accountInfo,
    l10n.appearance,
    'Push Notifications',
    l10n.profileVisibility,
    l10n.changePassword,
    l10n.permissions,
  ];

  final byTitle = {for (final i in all) i.title: i};
  final results = <SettingsSearchItem>[];
  for (final title in preferredTitles) {
    final item = byTitle[title];
    if (item != null) results.add(item);
  }
  return results;
}
