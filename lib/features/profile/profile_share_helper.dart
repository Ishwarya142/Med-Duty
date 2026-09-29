import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/services/med_duty_share_service.dart';
import '../../core/services/profile_link_service.dart';
import '../../models/profile_share_data.dart';
import '../../models/share_payload.dart';
import '../../providers/auth_provider.dart';
import '../../providers/profile_provider.dart';
import 'profile_qr_screen.dart';

class ProfileShareHelper {
  ProfileShareHelper._();

  static ProfileShareData fromProfileProvider(ProfileProvider profile, {String? userId}) {
    final location = [
      profile.currentCity,
      profile.state,
      profile.country,
    ].where((e) => e.isNotEmpty).join(', ');
    final initials = profile.name
        .split(' ')
        .where((w) => w.isNotEmpty)
        .take(2)
        .map((w) => w[0])
        .join()
        .toUpperCase();

    return ProfileShareData.fromUserProfile(
      userId: userId ?? profile.name.hashCode.toString(),
      name: profile.name.isNotEmpty ? profile.name : 'MedDuty User',
      specialization: profile.specialization.isNotEmpty ? profile.specialization : profile.qualification,
      hospital: profile.currentHospital,
      location: location.isEmpty ? null : location,
      avatarUrl: profile.profilePic.isNotEmpty ? profile.profilePic : null,
      avatarInitials: initials.isEmpty ? 'MD' : initials,
      isVerified: true,
    );
  }

  static ProfileShareData ownProfile(BuildContext context) {
    final auth = context.read<AuthProvider>();
    final profile = context.read<ProfileProvider>();
    final uid = auth.user?.uid;
    final data = fromProfileProvider(profile, userId: uid);
    if (uid != null) {
      return ProfileShareData.fromUserProfile(
        userId: uid,
        name: data.name,
        specialization: data.title,
        hospital: data.organization,
        location: data.location,
        avatarUrl: data.avatarUrl,
        avatarInitials: data.avatarInitials,
        isVerified: data.isVerified,
      );
    }
    return data;
  }

  static void showShareSheet(BuildContext context, ProfileShareData data) {
    MedDutyShareService.show(context, SharePayload.profile(data));
  }

  static void openQrScreen(BuildContext context, ProfileShareData data) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => ProfileQrScreen(data: data)),
    );
  }

  static ProfileShareData doctor({
    required String? doctorId,
    required String doctorName,
    required String specialization,
    required String hospital,
    required String location,
    String? avatarInitials,
    String? avatarUrl,
  }) {
    final id = doctorId ?? ProfileLinkService.slugFromName(doctorName);
    return ProfileShareData.fromUserProfile(
      userId: id,
      name: doctorName,
      specialization: specialization,
      hospital: hospital,
      location: location,
      avatarInitials: avatarInitials,
      avatarUrl: avatarUrl,
      isVerified: true,
    );
  }

  static ProfileShareData hospital({
    required String? hospitalId,
    required String hospitalName,
    required String hospitalType,
    required String location,
    String? speciality,
  }) {
    final id = hospitalId ?? ProfileLinkService.slugFromName(hospitalName);
    return ProfileShareData.fromHospitalProfile(
      hospitalId: id,
      hospitalName: hospitalName,
      hospitalType: hospitalType,
      location: location,
      speciality: speciality,
    );
  }
}
