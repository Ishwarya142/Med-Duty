import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

class SettingsUi {
  static void snack(BuildContext context, String message, {Color? color}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color ?? AppColors.accent,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  static Widget switchTile({
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
    required Color textColor,
    required Color subTextColor,
  }) {
    return SwitchListTile(
      title: Text(title, style: TextStyle(color: textColor, fontWeight: FontWeight.w600)),
      subtitle: Text(subtitle, style: TextStyle(color: subTextColor, fontSize: 12)),
      value: value,
      activeTrackColor: AppColors.accent.withValues(alpha: 0.4),
      thumbColor: WidgetStateProperty.resolveWith(
        (states) => states.contains(WidgetState.selected) ? AppColors.accent : null,
      ),
      onChanged: onChanged,
    );
  }

  static PreferredSizeWidget appBar(BuildContext context, String title, Color textColor, Color bg) {
    return AppBar(
      title: Text(title, style: TextStyle(color: textColor, fontWeight: FontWeight.w800)),
      backgroundColor: bg,
      foregroundColor: textColor,
      elevation: 0,
      scrolledUnderElevation: 0,
      surfaceTintColor: Colors.transparent,
    );
  }
}
