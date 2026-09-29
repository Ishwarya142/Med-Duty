import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../providers/settings_preferences_provider.dart';
import 'settings_ui_helpers.dart';

class LoginActivityScreen extends StatelessWidget {
  const LoginActivityScreen({super.key});

  String _deviceLabel() {
    if (kIsWeb) return 'Web Browser';
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return 'Android';
      case TargetPlatform.iOS:
        return 'iPhone / iPad';
      case TargetPlatform.windows:
        return 'Windows';
      case TargetPlatform.macOS:
        return 'macOS';
      case TargetPlatform.linux:
        return 'Linux';
      case TargetPlatform.fuchsia:
        return 'Fuchsia';
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? AppColors.darkBackground : AppColors.lightBackground;
    final surface = isDark ? AppColors.darkSurface : AppColors.lightSurface;
    final text = isDark ? AppColors.darkText : AppColors.lightText;
    final sub = isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;
    final border = isDark ? AppColors.darkBorder : AppColors.lightBorder;
    final prefs = context.read<SettingsPreferencesProvider>();

    return Scaffold(
      backgroundColor: bg,
      appBar: SettingsUi.appBar(context, 'Login Activity', text, bg),
      body: FutureBuilder<DateTime?>(
        future: prefs.lastActive(),
        builder: (context, snapshot) {
          final lastActive = snapshot.data;
          if (lastActive == null) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  'Login activity information is currently unavailable.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: sub, height: 1.4),
                ),
              ),
            );
          }
          final formatted = DateFormat('EEEE, MMM d • h:mm a').format(lastActive);
          return ListView(
            padding: const EdgeInsets.all(20),
            children: [
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: border),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Current device', style: TextStyle(color: sub, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 6),
                    Text(_deviceLabel(), style: TextStyle(color: text, fontSize: 18, fontWeight: FontWeight.w800)),
                    const SizedBox(height: 16),
                    Text('Last active', style: TextStyle(color: sub, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 6),
                    Text(formatted, style: TextStyle(color: text, fontWeight: FontWeight.w700)),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class TrustedDevicesScreen extends StatelessWidget {
  const TrustedDevicesScreen({super.key});

  String _deviceLabel() {
    if (kIsWeb) return 'Web Browser';
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return 'Android Device';
      case TargetPlatform.iOS:
        return 'Apple Device';
      case TargetPlatform.windows:
        return 'Windows PC';
      case TargetPlatform.macOS:
        return 'Mac';
      case TargetPlatform.linux:
        return 'Linux Device';
      case TargetPlatform.fuchsia:
        return 'Fuchsia Device';
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? AppColors.darkBackground : AppColors.lightBackground;
    final surface = isDark ? AppColors.darkSurface : AppColors.lightSurface;
    final text = isDark ? AppColors.darkText : AppColors.lightText;
    final sub = isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;
    final border = isDark ? AppColors.darkBorder : AppColors.lightBorder;

    return Scaffold(
      backgroundColor: bg,
      appBar: SettingsUi.appBar(context, 'Trusted Devices', text, bg),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: border),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Current Device', style: TextStyle(color: text, fontWeight: FontWeight.w800)),
                      const SizedBox(height: 4),
                      Text(_deviceLabel(), style: TextStyle(color: sub)),
                      const SizedBox(height: 4),
                      const Text('This device', style: TextStyle(color: AppColors.success, fontWeight: FontWeight.w600)),
                    ],
                  ),
                ),
                OutlinedButton(
                  onPressed: () => SettingsUi.snack(context, 'This is your current trusted device'),
                  child: const Text('Active'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'No additional trusted devices.\n\nTrusted device management will appear here when available.',
            style: TextStyle(color: sub, height: 1.45),
          ),
        ],
      ),
    );
  }
}
