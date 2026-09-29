enum ProfileShareType { user, hospital }

class ProfileShareData {
  final String id;
  final ProfileShareType type;
  final String name;
  final String? title;
  final String? organization;
  final String? location;
  final String? avatarUrl;
  final String? avatarInitials;
  final bool isVerified;

  const ProfileShareData({
    required this.id,
    required this.type,
    required this.name,
    this.title,
    this.organization,
    this.location,
    this.avatarUrl,
    this.avatarInitials,
    this.isVerified = false,
  });

  String get profileHandle {
    final base = name
        .replaceAll(RegExp(r'^dr\.?\s*', caseSensitive: false), '')
        .trim()
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9]+'), '');
    if (base.isNotEmpty) return '@$base';
    return '@${id.replaceAll(RegExp(r'[^a-zA-Z0-9]+'), '').toLowerCase()}';
  }

  factory ProfileShareData.fromUserProfile({
    required String userId,
    required String name,
    String? specialization,
    String? hospital,
    String? location,
    String? avatarUrl,
    String? avatarInitials,
    bool isVerified = true,
  }) {
    return ProfileShareData(
      id: userId,
      type: ProfileShareType.user,
      name: name,
      title: specialization,
      organization: hospital,
      location: location,
      avatarUrl: avatarUrl,
      avatarInitials: avatarInitials,
      isVerified: isVerified,
    );
  }

  factory ProfileShareData.fromHospitalProfile({
    required String hospitalId,
    required String hospitalName,
    String? hospitalType,
    String? location,
    String? speciality,
    bool isVerified = true,
  }) {
    return ProfileShareData(
      id: hospitalId,
      type: ProfileShareType.hospital,
      name: hospitalName,
      title: hospitalType,
      organization: speciality,
      location: location,
      isVerified: isVerified,
    );
  }
}

class ProfileLinkParseResult {
  final ProfileShareType type;
  final String id;

  const ProfileLinkParseResult({required this.type, required this.id});
}
