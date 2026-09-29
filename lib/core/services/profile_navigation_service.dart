import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/constants/supabase_constants.dart';
import '../../core/utils/account_status_utils.dart';
import '../../models/suggested_doctor_model.dart';
import '../../core/services/suggested_doctors_service.dart';
import '../../core/theme/app_colors.dart';
import '../../features/profile/public_doctor_profile_screen.dart';
import '../../features/profile/public_hospital_profile_screen.dart';
import '../../models/profile_share_data.dart';
import 'profile_link_service.dart';

class ProfileNavigationService {
  ProfileNavigationService._();

  static Future<void> openFromLink(
    BuildContext context,
    ProfileLinkParseResult result,
  ) async {
    if (result.type == ProfileShareType.hospital) {
      await _openHospital(context, result.id);
      return;
    }
    await _openUser(context, result.id);
  }

  static Future<void> _openUser(BuildContext context, String userId) async {
    try {
      final doc = await Supabase.instance.client
          .from(SupabaseConstants.users)
          .select()
          .eq('uid', userId)
          .maybeSingle();
      if (doc != null) {
        final data = doc;
        if (!AccountStatusUtils.isDiscoverable(data)) {
          if (context.mounted) {
            _snack(context, 'This MedDuty profile is not available.');
          }
          return;
        }
        if (!context.mounted) return;
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => PublicDoctorProfileScreen(
              doctorId: userId,
              doctorName: (data['name'] ?? data['displayName'] ?? 'Doctor').toString(),
              qualification: (data['qualification'] ?? data['degree'] ?? 'MBBS').toString(),
              specialization: (data['specialization'] ?? 'Healthcare Professional').toString(),
              hospital: (data['currentHospital'] ?? data['hospital'] ?? '').toString(),
              location: [
                data['currentCity'],
                data['state'],
                data['country'],
              ].where((e) => e != null && e.toString().isNotEmpty).join(', '),
            ),
          ),
        );
        return;
      }
    } catch (_) {
      // Fall through to suggested-doctor fallback.
    }

    final fallback = await _fallbackDoctor(userId);
    if (fallback != null) {
      if (!context.mounted) return;
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => PublicDoctorProfileScreen(
            doctorId: fallback.id,
            doctorName: fallback.name,
            qualification: fallback.qualification,
            specialization: fallback.specialization,
            hospital: fallback.hospital,
            location: fallback.location.isEmpty ? 'India' : fallback.location,
            avatarInitials: fallback.avatarInitials,
            avatarColor: AppColors.accent,
          ),
        ),
      );
      return;
    }

    if (context.mounted) {
      _snack(context, 'This MedDuty profile is no longer available.');
    }
  }

  static Future<void> _openHospital(BuildContext context, String hospitalId) async {
    try {
      final doc = await Supabase.instance.client
          .from(SupabaseConstants.hospitals)
          .select()
          .eq('id', hospitalId)
          .maybeSingle();
      if (doc != null) {
        final data = doc;
        if (!context.mounted) return;
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => PublicHospitalProfileScreen(
              hospitalId: hospitalId,
              hospitalName: (data['name'] ?? 'Hospital').toString(),
              hospitalType: (data['type'] ?? 'Multi-speciality Hospital').toString(),
              location: (data['location'] ?? data['city'] ?? 'India').toString(),
              speciality: data['speciality']?.toString(),
            ),
          ),
        );
        return;
      }
    } catch (_) {
      // Fall through to slug-based fallback.
    }

    final readableName = hospitalId.replaceAll('_', ' ').trim();
    if (!context.mounted) return;
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PublicHospitalProfileScreen(
          hospitalId: hospitalId,
          hospitalName: readableName.isEmpty ? 'Hospital' : readableName,
          hospitalType: 'Multi-speciality Hospital',
          location: 'India',
        ),
      ),
    );
  }

  static Future<SuggestedDoctorModel?> _fallbackDoctor(String userId) async {
    final doctors = await SuggestedDoctorsService().fetchSuggested();
    for (final d in doctors) {
      if (d.id == userId) return d;
    }
    return null;
  }

  static void _snack(BuildContext context, String message, {bool error = true}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: error ? AppColors.error : AppColors.accent,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  static Future<void> handleScannedPayload(BuildContext context, String raw) async {
    final parsed = ProfileLinkService.parse(raw);
    if (parsed == null) {
      _snack(context, 'Invalid MedDuty QR code');
      return;
    }
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('MedDuty QR detected'),
        backgroundColor: AppColors.accent,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(milliseconds: 900),
      ),
    );
    await openFromLink(context, parsed);
  }
}
