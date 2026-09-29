// ignore_for_file: deprecated_member_use
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../providers/settings_preferences_provider.dart';
import 'settings_ui_helpers.dart';

class OnlineStatusScreen extends StatelessWidget {
  const OnlineStatusScreen({super.key});

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
      appBar: SettingsUi.appBar(context, 'Online Status', text, bg),
      body: Container(
        margin: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: surface,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: border),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RadioListTile<OnlineStatusPreference>(
              title: Text('Everyone', style: TextStyle(color: text, fontWeight: FontWeight.w600)),
              subtitle: Text('Anyone can see when you are online.', style: TextStyle(color: sub, fontSize: 12)),
              value: OnlineStatusPreference.everyone,
              groupValue: prefs.onlineStatus,
              activeColor: AppColors.accent,
              onChanged: (v) async {
                if (v == null) return;
                await prefs.setOnlineStatus(v);
                if (context.mounted) SettingsUi.snack(context, 'Online status updated');
              },
            ),
            const Divider(height: 1, indent: 16, endIndent: 16),
            RadioListTile<OnlineStatusPreference>(
              title: Text('Connections', style: TextStyle(color: text, fontWeight: FontWeight.w600)),
              subtitle: Text('Only people you follow or who follow you.', style: TextStyle(color: sub, fontSize: 12)),
              value: OnlineStatusPreference.connections,
              groupValue: prefs.onlineStatus,
              activeColor: AppColors.accent,
              onChanged: (v) async {
                if (v == null) return;
                await prefs.setOnlineStatus(v);
                if (context.mounted) SettingsUi.snack(context, 'Online status updated');
              },
            ),
            const Divider(height: 1, indent: 16, endIndent: 16),
            RadioListTile<OnlineStatusPreference>(
              title: Text('Nobody', style: TextStyle(color: text, fontWeight: FontWeight.w600)),
              subtitle: Text('Hide your online status from everyone.', style: TextStyle(color: sub, fontSize: 12)),
              value: OnlineStatusPreference.nobody,
              groupValue: prefs.onlineStatus,
              activeColor: AppColors.accent,
              onChanged: (v) async {
                if (v == null) return;
                await prefs.setOnlineStatus(v);
                if (context.mounted) SettingsUi.snack(context, 'Online status updated');
              },
            ),
          ],
        ),
      ),
    );
  }
}
