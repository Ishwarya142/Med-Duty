class SuggestedDoctorModel {
  final String id;
  final String name;
  final String qualification;
  final String specialization;
  final String hospital;
  final String location;
  final bool isVerified;
  final int? mutualCount;

  const SuggestedDoctorModel({
    required this.id,
    required this.name,
    required this.qualification,
    required this.specialization,
    required this.hospital,
    required this.location,
    this.isVerified = true,
    this.mutualCount,
  });

  String get avatarInitials {
    final parts = name.split(' ').where((w) => w.isNotEmpty).take(2);
    return parts.map((w) => w[0]).join().toUpperCase();
  }

  factory SuggestedDoctorModel.fromMap(String id, Map<String, dynamic> data) {
    return SuggestedDoctorModel(
      id: id,
      name: (data['name'] ?? data['displayName'] ?? 'Doctor').toString(),
      qualification: (data['qualification'] ?? data['degree'] ?? 'MBBS').toString(),
      specialization: (data['specialization'] ?? 'General Physician').toString(),
      hospital: (data['currentHospital'] ?? data['hospital'] ?? '').toString(),
      location: [
        data['currentCity'],
        data['state'],
        data['country'],
      ].where((e) => e != null && e.toString().isNotEmpty).join(', '),
      isVerified: data['isVerified'] == true || data['verified'] == true,
    );
  }
}

enum SuggestedDoctorCategory {
  recommended,
  nearby,
  sameSpecialty,
  mayKnow,
  sameHospital,
  mutual,
  active,
  popular,
}

extension SuggestedDoctorCategoryLabel on SuggestedDoctorCategory {
  String get label => switch (this) {
        SuggestedDoctorCategory.recommended => 'Recommended for You',
        SuggestedDoctorCategory.nearby => 'Doctors Near You',
        SuggestedDoctorCategory.sameSpecialty => 'Same Specialty',
        SuggestedDoctorCategory.mayKnow => 'People You May Know',
        SuggestedDoctorCategory.sameHospital => 'Doctors From Your Hospital',
        SuggestedDoctorCategory.mutual => 'Mutual Connections',
        SuggestedDoctorCategory.active => 'Recently Active',
        SuggestedDoctorCategory.popular => 'Popular Healthcare Professionals',
      };
}
