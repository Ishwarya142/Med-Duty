import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../providers/settings_preferences_provider.dart';
import 'settings_ui_helpers.dart';

class PushNotificationsScreen extends StatelessWidget {
  const PushNotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? AppColors.darkBackground : AppColors.lightBackground;
    final surface = isDark ? AppColors.darkSurface : AppColors.lightSurface;
    final text = isDark ? AppColors.darkText : AppColors.lightText;
    final sub = isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;
    final border = isDark ? AppColors.darkBorder : AppColors.lightBorder;
    final prefs = context.watch<SettingsPreferencesProvider>();

    return Scaffold(
      backgroundColor: bg,
      appBar: SettingsUi.appBar(context, 'Push Notifications', text, bg),
      body: Container(
        margin: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: surface,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: border),
        ),
        child: SettingsUi.switchTile(
          title: 'Push Notifications',
          subtitle: 'Receive important MedDuty notifications.',
          value: prefs.pushNotifications,
          textColor: text,
          subTextColor: sub,
          onChanged: (v) async {
            await prefs.setPushNotifications(v);
            if (context.mounted) {
              SettingsUi.snack(context, v ? 'Push notifications enabled' : 'Push notifications disabled');
            }
          },
        ),
      ),
    );
  }
}

class DutyAlertsScreen extends StatelessWidget {
  const DutyAlertsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? AppColors.darkBackground : AppColors.lightBackground;
    final surface = isDark ? AppColors.darkSurface : AppColors.lightSurface;
    final text = isDark ? AppColors.darkText : AppColors.lightText;
    final sub = isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;
    final border = isDark ? AppColors.darkBorder : AppColors.lightBorder;
    final prefs = context.watch<SettingsPreferencesProvider>();

    Future<void> toggle(Future<void> Function(bool) setter, bool value, String label) async {
      await setter(value);
      if (context.mounted) SettingsUi.snack(context, '$label ${value ? 'enabled' : 'disabled'}');
    }

    return Scaffold(
      backgroundColor: bg,
      appBar: SettingsUi.appBar(context, 'Duty Alerts', text, bg),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Container(
            decoration: BoxDecoration(color: surface, borderRadius: BorderRadius.circular(18), border: Border.all(color: border)),
            child: Column(
              children: [
                SettingsUi.switchTile(
                  title: 'Duty Alerts',
                  subtitle: 'Get notified about new duties matching your preferences and location.',
                  value: prefs.dutyAlerts,
                  textColor: text,
                  subTextColor: sub,
                  onChanged: (v) => toggle(prefs.setDutyAlerts, v, 'Duty alerts'),
                ),
                const Divider(height: 1, indent: 16, endIndent: 16),
                SettingsUi.switchTile(
                  title: 'Nearby Duties',
                  subtitle: 'Alerts for duties near your selected location.',
                  value: prefs.dutyNearby,
                  textColor: text,
                  subTextColor: sub,
                  onChanged: (v) => toggle(prefs.setDutyNearby, v, 'Nearby duty alerts'),
                ),
                const Divider(height: 1, indent: 16, endIndent: 16),
                SettingsUi.switchTile(
                  title: 'Urgent Duties',
                  subtitle: 'Priority alerts for urgent duty openings.',
                  value: prefs.dutyUrgent,
                  textColor: text,
                  subTextColor: sub,
                  onChanged: (v) => toggle(prefs.setDutyUrgent, v, 'Urgent duty alerts'),
                ),
                const Divider(height: 1, indent: 16, endIndent: 16),
                SettingsUi.switchTile(
                  title: 'Emergency Duties',
                  subtitle: 'Critical alerts for hospital-posted emergency duties.',
                  value: prefs.dutyEmergency,
                  textColor: text,
                  subTextColor: sub,
                  onChanged: (v) => toggle(prefs.setDutyEmergency, v, 'Emergency duty alerts'),
                ),
                const Divider(height: 1, indent: 16, endIndent: 16),
                SettingsUi.switchTile(
                  title: 'Saved Duties',
                  subtitle: 'Updates for duties you have saved.',
                  value: prefs.dutySaved,
                  textColor: text,
                  subTextColor: sub,
                  onChanged: (v) => toggle(prefs.setDutySaved, v, 'Saved duty alerts'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class JobAlertsScreen extends StatelessWidget {
  const JobAlertsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? AppColors.darkBackground : AppColors.lightBackground;
    final surface = isDark ? AppColors.darkSurface : AppColors.lightSurface;
    final text = isDark ? AppColors.darkText : AppColors.lightText;
    final sub = isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;
    final border = isDark ? AppColors.darkBorder : AppColors.lightBorder;
    final prefs = context.watch<SettingsPreferencesProvider>();

    Future<void> toggle(Future<void> Function(bool) setter, bool value, String label) async {
      await setter(value);
      if (context.mounted) SettingsUi.snack(context, '$label ${value ? 'enabled' : 'disabled'}');
    }

    return Scaffold(
      backgroundColor: bg,
      appBar: SettingsUi.appBar(context, 'Job Alerts', text, bg),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Container(
            decoration: BoxDecoration(color: surface, borderRadius: BorderRadius.circular(18), border: Border.all(color: border)),
            child: Column(
              children: [
                SettingsUi.switchTile(
                  title: 'Job Alerts',
                  subtitle: 'Get notified about new job opportunities matching your profile.',
                  value: prefs.jobAlerts,
                  textColor: text,
                  subTextColor: sub,
                  onChanged: (v) => toggle(prefs.setJobAlerts, v, 'Job alerts'),
                ),
                const Divider(height: 1, indent: 16, endIndent: 16),
                SettingsUi.switchTile(
                  title: 'Job Recommendations',
                  subtitle: 'Personalized job suggestions based on your specialty and experience.',
                  value: prefs.jobRecommendations,
                  textColor: text,
                  subTextColor: sub,
                  onChanged: (v) => toggle(prefs.setJobRecommendations, v, 'Job recommendations'),
                ),
                const Divider(height: 1, indent: 16, endIndent: 16),
                SettingsUi.switchTile(
                  title: 'Job Applications',
                  subtitle: 'Updates on your job application status and responses.',
                  value: prefs.jobApplications,
                  textColor: text,
                  subTextColor: sub,
                  onChanged: (v) => toggle(prefs.setJobApplications, v, 'Job application alerts'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class CommunityNotificationsScreen extends StatelessWidget {
  const CommunityNotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? AppColors.darkBackground : AppColors.lightBackground;
    final surface = isDark ? AppColors.darkSurface : AppColors.lightSurface;
    final text = isDark ? AppColors.darkText : AppColors.lightText;
    final sub = isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;
    final border = isDark ? AppColors.darkBorder : AppColors.lightBorder;
    final prefs = context.watch<SettingsPreferencesProvider>();

    Future<void> update(Future<void> Function(bool) fn, bool v) async {
      await fn(v);
      if (context.mounted) SettingsUi.snack(context, 'Community notifications updated');
    }

    return Scaffold(
      backgroundColor: bg,
      appBar: SettingsUi.appBar(context, 'Community Notifications', text, bg),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Container(
          decoration: BoxDecoration(color: surface, borderRadius: BorderRadius.circular(18), border: Border.all(color: border)),
          child: Column(
            children: [
              SettingsUi.switchTile(title: 'Community Activity', subtitle: 'Posts and updates from your network.', value: prefs.communityActivity, textColor: text, subTextColor: sub, onChanged: (v) => update(prefs.setCommunityActivity, v)),
              const Divider(height: 1, indent: 16, endIndent: 16),
              SettingsUi.switchTile(title: 'Comments', subtitle: 'When someone comments on your posts.', value: prefs.communityComments, textColor: text, subTextColor: sub, onChanged: (v) => update(prefs.setCommunityComments, v)),
              const Divider(height: 1, indent: 16, endIndent: 16),
              SettingsUi.switchTile(title: 'Likes', subtitle: 'When someone likes your content.', value: prefs.communityLikes, textColor: text, subTextColor: sub, onChanged: (v) => update(prefs.setCommunityLikes, v)),
              const Divider(height: 1, indent: 16, endIndent: 16),
              SettingsUi.switchTile(title: 'New Followers', subtitle: 'When someone follows your profile.', value: prefs.communityFollowers, textColor: text, subTextColor: sub, onChanged: (v) => update(prefs.setCommunityFollowers, v)),
            ],
          ),
        ),
        ],
      ),
    );
  }
}

class MessageNotificationsScreen extends StatelessWidget {
  const MessageNotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? AppColors.darkBackground : AppColors.lightBackground;
    final surface = isDark ? AppColors.darkSurface : AppColors.lightSurface;
    final text = isDark ? AppColors.darkText : AppColors.lightText;
    final sub = isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;
    final border = isDark ? AppColors.darkBorder : AppColors.lightBorder;
    final prefs = context.watch<SettingsPreferencesProvider>();

    Future<void> update(Future<void> Function(bool) fn, bool v, String label) async {
      await fn(v);
      if (context.mounted) SettingsUi.snack(context, '$label ${v ? 'enabled' : 'disabled'}');
    }

    return Scaffold(
      backgroundColor: bg,
      appBar: SettingsUi.appBar(context, 'Message Notifications', text, bg),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Container(
          decoration: BoxDecoration(color: surface, borderRadius: BorderRadius.circular(18), border: Border.all(color: border)),
          child: Column(
            children: [
              SettingsUi.switchTile(title: 'New Messages', subtitle: 'Direct messages from colleagues.', value: prefs.messageNew, textColor: text, subTextColor: sub, onChanged: (v) => update(prefs.setMessageNew, v, 'New messages')),
              const Divider(height: 1, indent: 16, endIndent: 16),
              SettingsUi.switchTile(title: 'Message Requests', subtitle: 'Requests from people you may not know.', value: prefs.messageRequests, textColor: text, subTextColor: sub, onChanged: (v) => update(prefs.setMessageRequests, v, 'Message requests')),
              const Divider(height: 1, indent: 16, endIndent: 16),
              SettingsUi.switchTile(title: 'Group Messages', subtitle: 'Activity in group conversations.', value: prefs.messageGroup, textColor: text, subTextColor: sub, onChanged: (v) => update(prefs.setMessageGroup, v, 'Group messages')),
              const Divider(height: 1, indent: 16, endIndent: 16),
              SettingsUi.switchTile(title: 'Calls', subtitle: 'Incoming and outgoing call notifications.', value: prefs.messageCalls, textColor: text, subTextColor: sub, onChanged: (v) => update(prefs.setMessageCalls, v, 'Call notifications')),
              const Divider(height: 1, indent: 16, endIndent: 16),
              SettingsUi.switchTile(title: 'Show message preview', subtitle: 'Display message content in notifications.', value: prefs.messagePreview, textColor: text, subTextColor: sub, onChanged: (v) => update(prefs.setMessagePreview, v, 'Message preview')),
            ],
          ),
        ),
        ],
      ),
    );
  }
}
