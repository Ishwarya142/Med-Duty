import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../providers/profile_provider.dart';
import 'profile_media_viewer.dart';

class MedicalLicenseScreen extends StatelessWidget {
  final bool isPublicView;

  const MedicalLicenseScreen({super.key, this.isPublicView = false});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final profile = context.watch<ProfileProvider>();
    final textColor = isDark ? AppColors.darkText : AppColors.lightText;
    final subText = isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;
    final bg = isDark ? AppColors.darkBackground : AppColors.lightBackground;
    final surface = isDark ? AppColors.darkSurface : AppColors.lightSurface;
    final border = isDark ? AppColors.darkBorder : AppColors.lightBorder;
    final reg = profile.medicalRegistration;
    final licenseDocs = profile.documents
        .where((d) => d.type.toLowerCase().contains('medical_license') || d.type.toLowerCase().contains('license'))
        .toList();
    final verified = reg.isVerified ||
        licenseDocs.any((d) => d.verificationStatus == DocumentVerificationStatus.verified);
    final regNumber = isPublicView && reg.number.length > 4
        ? '••••${reg.number.substring(reg.number.length - 4)}'
        : (reg.number.isNotEmpty ? reg.number : profile.medicalRegistrationNumber);

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        title: Text('Medical License', style: TextStyle(color: textColor, fontWeight: FontWeight.w800)),
        backgroundColor: bg,
        foregroundColor: textColor,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: border.withValues(alpha: 0.5)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(verified ? Icons.verified_rounded : Icons.badge_outlined, color: AppColors.accent),
                    const SizedBox(width: 8),
                    Text(
                      verified ? 'Verified' : 'Pending verification',
                      style: TextStyle(color: verified ? AppColors.success : AppColors.warning, fontWeight: FontWeight.w700),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _row('Medical Registration', regNumber.isEmpty ? 'Not added' : regNumber, textColor, subText),
                _row('Medical Council', profile.medicalCouncil.isEmpty ? reg.council : profile.medicalCouncil, textColor, subText),
                _row('Registration State', reg.state.isEmpty ? profile.state : reg.state, textColor, subText),
                _row('Issue Date', _formatDate(reg.issueDate), textColor, subText),
                _row('Expiry Date', _formatDate(reg.expiryDate), textColor, subText),
              ],
            ),
          ),
          const SizedBox(height: 16),
          if (licenseDocs.isNotEmpty)
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ProfileMediaViewer(
                        items: licenseDocs
                            .map((d) => ProfileMediaItem(title: d.name, url: d.url, icon: Icons.badge_rounded))
                            .toList(),
                      ),
                    ),
                  );
                },
                icon: const Icon(Icons.visibility_rounded),
                label: const Text('View License'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.accent,
                  foregroundColor: AppColors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            )
          else
            Text(
              'No license document uploaded yet.',
              style: TextStyle(color: subText),
              textAlign: TextAlign.center,
            ),
        ],
      ),
    );
  }

  Widget _row(String label, String value, Color textColor, Color subText) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: TextStyle(color: subText, fontSize: 12, fontWeight: FontWeight.w600)),
          const SizedBox(height: 4),
          Text(value, style: TextStyle(color: textColor, fontSize: 15, fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }

  String _formatDate(DateTime? date) {
    if (date == null) return '—';
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }
}
