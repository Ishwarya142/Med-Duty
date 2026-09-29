import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../models/post_visibility.dart';
import '../../providers/profile_provider.dart';

class PrivacyScreen extends StatefulWidget {
  const PrivacyScreen({super.key});

  @override
  State<PrivacyScreen> createState() => _PrivacyScreenState();
}

class _PrivacyScreenState extends State<PrivacyScreen> {
  @override
  Widget build(BuildContext context) {
    final profile = context.watch<ProfileProvider>();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? AppColors.darkBackground : const Color(0xFFF8FAFC);
    final card = isDark ? AppColors.darkSurface : Colors.white;
    final text = isDark ? AppColors.darkText : const Color(0xFF0F172A);
    final sub = isDark ? AppColors.darkTextSecondary : const Color(0xFF64748B);
    final border = isDark ? AppColors.darkBorder : const Color(0xFFE2E8F0);

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        title: const Text('Privacy & Safety', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF0F766E),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 40),
        children: [
          // Healthcare Privacy Notice Banner
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFF0F766E).withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFF0F766E).withValues(alpha: 0.2)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.shield_outlined, color: Color(0xFF0F766E), size: 22),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Healthcare Privacy Guarantee',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          color: Color(0xFF0F766E),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'MedDuty strictly protects healthcare provider and patient data. '
                        'Do not share personally identifiable patient records, MRNs, or sensitive clinical information.',
                        style: TextStyle(color: sub, fontSize: 12.5, height: 1.4),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Profile Privacy Section
          Text(
            'PROFILE PRIVACY',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.8,
              color: sub,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            decoration: BoxDecoration(
              color: card,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: border),
            ),
            child: Column(
              children: ProfilePrivacy.values.map((privacy) {
                final selected = profile.profilePrivacy == privacy;
                return RadioListTile<ProfilePrivacy>(
                  value: privacy,
                  groupValue: profile.profilePrivacy,
                  activeColor: const Color(0xFF0F766E),
                  title: Text(
                    privacy.label,
                    style: TextStyle(
                      fontWeight: selected ? FontWeight.bold : FontWeight.w600,
                      color: text,
                    ),
                  ),
                  subtitle: Text(
                    privacy.description,
                    style: TextStyle(fontSize: 12, color: sub),
                  ),
                  onChanged: (val) {
                    if (val != null) {
                      profile.updateProfilePrivacy(val);
                    }
                  },
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 20),

          // Direct Interaction & Visibility
          Text(
            'COMMUNICATION & CREDENTIALS',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.8,
              color: sub,
            ),
          ),
          const SizedBox(height: 8),
          _buildPrivacySwitch(
            title: 'Show Phone Number',
            subtitle: 'Display your verified phone number on your professional profile',
            value: profile.phoneVisibility,
            card: card,
            border: border,
            text: text,
            sub: sub,
            onChanged: (value) => profile.updatePrivacySettings(
              phoneVisibility: value,
            ),
          ),
          const SizedBox(height: 10),
          _buildPrivacySwitch(
            title: 'Allow Direct Messages',
            subtitle: 'Receive duty coordination messages from verified hospitals and peers',
            value: profile.allowMessages,
            card: card,
            border: border,
            text: text,
            sub: sub,
            onChanged: (value) => profile.updatePrivacySettings(
              allowMessages: value,
            ),
          ),
          const SizedBox(height: 10),
          _buildPrivacySwitch(
            title: 'Allow Professional Reviews',
            subtitle: 'Let hospitals and clinical leads leave duty reviews and feedback',
            value: profile.allowReviews,
            card: card,
            border: border,
            text: text,
            sub: sub,
            onChanged: (value) => profile.updatePrivacySettings(
              allowReviews: value,
            ),
          ),
          const SizedBox(height: 10),
          _buildPrivacySwitch(
            title: 'Follow Request Required',
            subtitle: 'Require your manual approval before other professionals can follow you',
            value: profile.followRequestRequired,
            card: card,
            border: border,
            text: text,
            sub: sub,
            onChanged: (value) => profile.updatePrivacySettings(
              followRequestRequired: value,
            ),
          ),
          const SizedBox(height: 28),

          ElevatedButton(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Privacy and safety settings updated.'),
                  backgroundColor: Color(0xFF0F766E),
                  behavior: SnackBarBehavior.floating,
                ),
              );
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF0F766E),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              elevation: 0,
            ),
            child: const Text(
              'Done',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPrivacySwitch({
    required String title,
    required String subtitle,
    required bool value,
    required Color card,
    required Color border,
    required Color text,
    required Color sub,
    required ValueChanged<bool> onChanged,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: card,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: border),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14.5,
                    fontWeight: FontWeight.w700,
                    color: text,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 12,
                    color: sub,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: const Color(0xFF0F766E),
          ),
        ],
      ),
    );
  }
}
