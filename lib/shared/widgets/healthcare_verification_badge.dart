import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

enum HealthcareVerificationType {
  doctor,
  nurse,
  hospital,
  clinic,
  generalProfessional,
}

/// Clearly distinguishes:
/// - Verified healthcare professional
/// - Verified hospital/clinic
/// - Unverified account
class HealthcareVerificationBadge extends StatelessWidget {
  const HealthcareVerificationBadge({
    super.key,
    required this.isVerified,
    this.type = HealthcareVerificationType.doctor,
    this.size = 16,
    this.showLabel = false,
    this.showUnverified = false,
    this.customLabel,
  });

  final bool isVerified;
  final HealthcareVerificationType type;
  final double size;
  final bool showLabel;
  final bool showUnverified;
  final String? customLabel;

  String get _verifiedLabel {
    if (customLabel != null) return customLabel!;
    switch (type) {
      case HealthcareVerificationType.doctor:
      case HealthcareVerificationType.nurse:
      case HealthcareVerificationType.generalProfessional:
        return 'Verified Healthcare Professional';
      case HealthcareVerificationType.hospital:
        return 'Verified Hospital';
      case HealthcareVerificationType.clinic:
        return 'Verified Clinic';
    }
  }

  Color get _badgeColor {
    switch (type) {
      case HealthcareVerificationType.hospital:
      case HealthcareVerificationType.clinic:
        return const Color(0xFF0F766E); // Hospital Teal
      case HealthcareVerificationType.doctor:
      case HealthcareVerificationType.nurse:
      case HealthcareVerificationType.generalProfessional:
        return const Color(0xFF2563EB); // Professional Blue
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!isVerified) {
      if (!showUnverified) return const SizedBox.shrink();
      return Tooltip(
        message: 'Unverified account — credentials pending verification',
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(
            color: Colors.grey.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: Colors.grey.withValues(alpha: 0.25)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.shield_outlined, size: size * 0.85, color: Colors.grey),
              if (showLabel) ...[
                const SizedBox(width: 4),
                const Text(
                  'Unverified',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey,
                  ),
                ),
              ],
            ],
          ),
        ),
      );
    }

    final badgeIcon = Icon(
      Icons.verified_rounded,
      color: _badgeColor,
      size: size,
    );

    if (!showLabel) {
      return Tooltip(
        message: _verifiedLabel,
        child: badgeIcon,
      );
    }

    return Tooltip(
      message: _verifiedLabel,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(
          color: _badgeColor.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: _badgeColor.withValues(alpha: 0.25)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            badgeIcon,
            const SizedBox(width: 4),
            Text(
              _verifiedLabel,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: _badgeColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
