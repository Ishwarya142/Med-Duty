import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../providers/settings_preferences_provider.dart';
import 'settings_ui_helpers.dart';

class BlockedUsersScreen extends StatelessWidget {
  const BlockedUsersScreen({super.key});

  Future<void> _confirmUnblock(BuildContext context, BlockedUserEntry user) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Unblock this user?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Unblock')),
        ],
      ),
    );
    if (confirm != true || !context.mounted) return;
    await context.read<SettingsPreferencesProvider>().unblockUser(user.id);
    if (context.mounted) SettingsUi.snack(context, 'User unblocked');
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? AppColors.darkBackground : AppColors.lightBackground;
    final surface = isDark ? AppColors.darkSurface : AppColors.lightSurface;
    final text = isDark ? AppColors.darkText : AppColors.lightText;
    final sub = isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;
    final border = isDark ? AppColors.darkBorder : AppColors.lightBorder;
    final blocked = context.watch<SettingsPreferencesProvider>().blockedUsers;

    return Scaffold(
      backgroundColor: bg,
      appBar: SettingsUi.appBar(context, 'Blocked Users', text, bg),
      body: blocked.isEmpty
          ? Center(child: Text("You're not blocking anyone.", style: TextStyle(color: sub, fontWeight: FontWeight.w600)))
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: blocked.length,
              separatorBuilder: (_, _) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final user = blocked[index];
                return Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(color: surface, borderRadius: BorderRadius.circular(14), border: Border.all(color: border)),
                  child: Row(
                    children: [
                      CircleAvatar(backgroundColor: AppColors.error.withValues(alpha: 0.15), child: Text(user.name[0], style: const TextStyle(color: AppColors.error, fontWeight: FontWeight.w800))),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Text(user.name, style: TextStyle(color: text, fontWeight: FontWeight.w700)),
                          Text(user.role, style: TextStyle(color: sub, fontSize: 12)),
                        ]),
                      ),
                      OutlinedButton(
                        onPressed: () => _confirmUnblock(context, user),
                        style: OutlinedButton.styleFrom(foregroundColor: AppColors.error, side: const BorderSide(color: AppColors.error)),
                        child: const Text('Unblock'),
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }
}
