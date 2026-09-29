import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/profile_provider.dart';
import '../edit_profile_screen.dart';
import 'account_control_screens.dart';
import 'settings_ui_helpers.dart';

class AccountInfoScreen extends StatelessWidget {
  const AccountInfoScreen({super.key});

  String _formatDate(DateTime? date) {
    if (date == null) return 'Not available';
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? AppColors.darkBackground : AppColors.lightBackground;
    final surface = isDark ? AppColors.darkSurface : AppColors.lightSurface;
    final text = isDark ? AppColors.darkText : AppColors.lightText;
    final sub = isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;
    final border = isDark ? AppColors.darkBorder : AppColors.lightBorder;
    final profile = context.watch<ProfileProvider>();
    final auth = context.watch<AuthProvider>();
    final role = profile.specialization.isNotEmpty
        ? profile.specialization
        : (profile.qualification.isNotEmpty ? profile.qualification : 'Healthcare Professional');

    return Scaffold(
      backgroundColor: bg,
      appBar: SettingsUi.appBar(context, 'Account Information', text, bg),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: surface,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: border),
              boxShadow: isDark ? null : AppColors.softShadow,
            ),
            child: Column(
              children: [
                CircleAvatar(
                  radius: 36,
                  backgroundColor: AppColors.accent,
                  backgroundImage: profile.profilePic.isNotEmpty ? NetworkImage(profile.profilePic) : null,
                  child: profile.profilePic.isEmpty
                      ? Text(
                          profile.name.isNotEmpty ? profile.name[0].toUpperCase() : 'M',
                          style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w800),
                        )
                      : null,
                ),
                const SizedBox(height: 12),
                Text(profile.name.isNotEmpty ? profile.name : 'MedDuty User', style: TextStyle(color: text, fontSize: 20, fontWeight: FontWeight.w800)),
                Text(role, style: TextStyle(color: sub)),
              ],
            ),
          ),
          const SizedBox(height: 16),
          _infoRow('Email', profile.email.isNotEmpty ? profile.email : (auth.user?.email ?? 'Not set'), text, sub, surface, border),
          _infoRow('Phone', profile.phone.isNotEmpty ? profile.phone : 'Not set', text, sub, surface, border),
          _infoRow(
            'Medical Registration',
            profile.medicalRegistrationNumber.isNotEmpty
                ? profile.medicalRegistrationNumber
                : (profile.medicalRegistration.number.isNotEmpty ? profile.medicalRegistration.number : 'Not added'),
            text,
            sub,
            surface,
            border,
          ),
          _infoRow('Account created', _formatDate(auth.user?.createdAt != null ? DateTime.tryParse(auth.user!.createdAt) : null), text, sub, surface, border),
          const SizedBox(height: 24),
          Text(
            'Account Control',
            style: TextStyle(color: sub, fontSize: 13, fontWeight: FontWeight.w800, letterSpacing: 1.1),
          ),
          const SizedBox(height: 12),
          _controlCard(
            context: context,
            icon: Icons.pause_circle_outline,
            title: 'Deactivate Account',
            subtitle: 'Temporarily hide your MedDuty profile and activity. You can reactivate your account by logging in again.',
            text: text,
            sub: sub,
            surface: surface,
            border: border,
            isDestructive: false,
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const DeactivateAccountScreen()));
            },
          ),
          const SizedBox(height: 10),
          _controlCard(
            context: context,
            icon: Icons.delete_forever_outlined,
            title: 'Delete Account',
            subtitle: 'Permanently delete your MedDuty account and associated data. This action cannot be undone.',
            text: text,
            sub: sub,
            surface: surface,
            border: border,
            isDestructive: true,
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const DeleteAccountWarningScreen()));
            },
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => const EditProfileScreen()));
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.accent,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('Edit Profile', style: TextStyle(fontWeight: FontWeight.w700)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _controlCard({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String subtitle,
    required Color text,
    required Color sub,
    required Color surface,
    required Color border,
    required bool isDestructive,
    required VoidCallback onTap,
  }) {
    final accent = isDestructive ? AppColors.error : AppColors.accent;
    return Material(
      color: surface,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: isDestructive ? AppColors.error.withValues(alpha: 0.25) : border),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: accent, size: 22),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: TextStyle(color: isDestructive ? AppColors.error : text, fontWeight: FontWeight.w800, fontSize: 15)),
                    const SizedBox(height: 6),
                    Text(subtitle, style: TextStyle(color: sub, height: 1.4, fontSize: 13)),
                  ],
                ),
              ),
              Icon(Icons.chevron_right_rounded, color: sub),
            ],
          ),
        ),
      ),
    );
  }

  Widget _infoRow(String label, String value, Color text, Color sub, Color surface, Color border) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: border.withValues(alpha: 0.6)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(child: Text(label, style: TextStyle(color: sub, fontSize: 12, fontWeight: FontWeight.w600))),
          const SizedBox(width: 12),
          Expanded(
            flex: 2,
            child: Text(value, textAlign: TextAlign.end, style: TextStyle(color: text, fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }
}
