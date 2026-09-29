import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../../../core/services/profile_link_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../models/profile_share_data.dart';

class ProfileShareCardWidget extends StatelessWidget {
  final ProfileShareData data;
  final double qrSize;

  const ProfileShareCardWidget({
    super.key,
    required this.data,
    this.qrSize = 128,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 360,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.lightBorder),
        boxShadow: AppColors.softShadow,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'MedDuty',
            style: TextStyle(
              color: AppColors.accent,
              fontSize: 22,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 18),
          CircleAvatar(
            radius: 42,
            backgroundColor: AppColors.accent,
            backgroundImage: data.avatarUrl != null ? NetworkImage(data.avatarUrl!) : null,
            child: data.avatarUrl == null
                ? Text(
                    data.avatarInitials ?? 'MD',
                    style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w800),
                  )
                : null,
          ),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Flexible(
                child: Text(
                  data.name,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: AppColors.lightText,
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              if (data.isVerified) ...[
                const SizedBox(width: 4),
                const Icon(Icons.verified_rounded, color: AppColors.info, size: 18),
              ],
            ],
          ),
          if (data.title != null && data.title!.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              data.title!,
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppColors.lightTextSecondary, fontSize: 14, fontWeight: FontWeight.w600),
            ),
          ],
          if (data.organization != null && data.organization!.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              data.organization!,
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppColors.lightTextSecondary, fontSize: 13),
            ),
          ],
          if (data.location != null && data.location!.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              data.location!,
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppColors.lightTextSecondary, fontSize: 13),
            ),
          ],
          const SizedBox(height: 18),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.lightBorder),
            ),
            child: QrImageView(
              data: ProfileLinkService.qrPayload(data),
              version: QrVersions.auto,
              size: qrSize,
              backgroundColor: Colors.white,
              eyeStyle: const QrEyeStyle(color: AppColors.accent),
              dataModuleStyle: const QrDataModuleStyle(color: AppColors.lightText),
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'Scan to view my MedDuty profile',
            textAlign: TextAlign.center,
            style: TextStyle(color: AppColors.lightTextSecondary, fontSize: 12, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          Text(
            'Profile ID: ${data.profileHandle}',
            style: const TextStyle(color: AppColors.accent, fontSize: 12, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 14),
          const Text(
            'Care • Connect • Serve',
            style: TextStyle(color: AppColors.accent, fontSize: 11, fontWeight: FontWeight.w700, letterSpacing: 0.4),
          ),
        ],
      ),
    );
  }
}
