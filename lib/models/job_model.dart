

import '../core/utils/geohash_utils.dart';

enum JobStatus {
  open,
  closed,
  filled,
  cancelled,
}

enum EmploymentType {
  fullTime,
  partTime,
  contract,
  permanent,
  locum,
  remote,
  hybrid,
  internship,
  fellowship,
  residency,
  temporary,
}

enum WorkMode {
  onSite,
  hybrid,
  remote,
}

class JobModel {
  final String id;
  final String hospitalId;
  final String hospitalName;
  final String title;
  final String specialization;
  final EmploymentType employmentType;
  final WorkMode workMode;
  final double salaryMin;
  final double salaryMax;
  final String salaryPeriod;
  final String experienceRequired;
  final String qualification;
  final String location;
  final String? description;
  final List<String> responsibilities;
  final List<String> requirements;
  final List<String> skills;
  final DateTime postedAt;
  final DateTime? applicationDeadline;
  final int positions;
  final JobStatus status;
  final double? latitude;
  final double? longitude;
  final String? geohash;
  final String? city;
  final String? state;
  final bool verified;
  final String? workingHours;
  final List<String> benefits;

  JobModel({
    required this.id,
    required this.hospitalId,
    required this.hospitalName,
    required this.title,
    required this.specialization,
    required this.employmentType,
    this.workMode = WorkMode.onSite,
    required this.salaryMin,
    required this.salaryMax,
    this.salaryPeriod = 'month',
    required this.experienceRequired,
    required this.qualification,
    required this.location,
    this.description,
    this.responsibilities = const [],
    this.requirements = const [],
    this.skills = const [],
    required this.postedAt,
    this.applicationDeadline,
    this.positions = 1,
    this.status = JobStatus.open,
    this.latitude,
    this.longitude,
    this.geohash,
    this.city,
    this.state,
    this.verified = false,
    this.workingHours,
    this.benefits = const [],
  });

  bool get hasCoordinates => latitude != null && longitude != null;

  String get employmentLabel {
    switch (employmentType) {
      case EmploymentType.fullTime:
        return 'Full-time';
      case EmploymentType.partTime:
        return 'Part-time';
      case EmploymentType.contract:
        return 'Contract';
      case EmploymentType.permanent:
        return 'Permanent';
      case EmploymentType.locum:
        return 'Locum';
      case EmploymentType.remote:
        return 'Remote';
      case EmploymentType.hybrid:
        return 'Hybrid';
      case EmploymentType.internship:
        return 'Internship';
      case EmploymentType.fellowship:
        return 'Fellowship';
      case EmploymentType.residency:
        return 'Residency';
      case EmploymentType.temporary:
        return 'Temporary';
    }
  }

  String get salaryLabel {
    final min = _formatSalary(salaryMin);
    final max = _formatSalary(salaryMax);
    if (salaryMin == salaryMax) return '$min/$salaryPeriod';
    return '$min – $max/$salaryPeriod';
  }

  static String _formatSalary(double amount) {
    if (amount >= 100000) {
      final lakhs = amount / 100000;
      return lakhs == lakhs.roundToDouble()
          ? '₹${lakhs.toStringAsFixed(0)}L'
          : '₹${lakhs.toStringAsFixed(1)}L';
    }
    if (amount >= 1000) {
      final k = amount / 1000;
      return '₹${k.toStringAsFixed(0)}K';
    }
    return '₹${amount.toStringAsFixed(0)}';
  }

  static DateTime _parseDate(dynamic value, [DateTime? fallback]) {
    if (value is DateTime) return value;
    if (value is String && value.isNotEmpty) {
      return DateTime.tryParse(value) ?? fallback ?? DateTime.now();
    }
    return fallback ?? DateTime.now();
  }

  factory JobModel.fromMap(Map<String, dynamic> map, String id) {
    return JobModel(
      id: id,
      hospitalId: map['hospitalId'] ?? '',
      hospitalName: map['hospitalName'] ?? '',
      title: map['title'] ?? map['role'] ?? '',
      specialization: map['specialization'] ?? '',
      employmentType: EmploymentType.values.firstWhere(
        (e) => e.name == (map['employmentType'] ?? 'fullTime'),
        orElse: () => EmploymentType.fullTime,
      ),
      workMode: WorkMode.values.firstWhere(
        (e) => e.name == (map['workMode'] ?? 'onSite'),
        orElse: () => WorkMode.onSite,
      ),
      salaryMin: (map['salaryMin'] as num?)?.toDouble() ??
          (map['salary'] as num?)?.toDouble() ??
          0,
      salaryMax: (map['salaryMax'] as num?)?.toDouble() ??
          (map['salary'] as num?)?.toDouble() ??
          0,
      salaryPeriod: map['salaryPeriod'] ?? 'month',
      experienceRequired: map['experienceRequired'] ?? '',
      qualification: map['qualification'] ?? '',
      location: map['location'] ?? '',
      description: map['description'],
      responsibilities: List<String>.from(map['responsibilities'] ?? []),
      requirements: List<String>.from(map['requirements'] ?? []),
      skills: List<String>.from(map['skills'] ?? []),
      postedAt: _parseDate(map['postedAt'] ?? map['createdAt']),
      applicationDeadline: map['applicationDeadline'] != null
          ? _parseDate(map['applicationDeadline'])
          : null,
      positions: (map['positions'] as num?)?.toInt() ?? 1,
      status: JobStatus.values.firstWhere(
        (e) => e.name == (map['status'] ?? 'open'),
        orElse: () => JobStatus.open,
      ),
      latitude: (map['latitude'] as num?)?.toDouble(),
      longitude: (map['longitude'] as num?)?.toDouble(),
      geohash: map['geohash'] as String?,
      city: map['city'] as String?,
      state: map['state'] as String?,
      verified: map['verified'] == true,
      workingHours: map['workingHours'] as String?,
      benefits: List<String>.from(map['benefits'] ?? []),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'hospitalId': hospitalId,
      'hospitalName': hospitalName,
      'title': title,
      'specialization': specialization,
      'employmentType': employmentType.name,
      'workMode': workMode.name,
      'salaryMin': salaryMin,
      'salaryMax': salaryMax,
      'salaryPeriod': salaryPeriod,
      'experienceRequired': experienceRequired,
      'qualification': qualification,
      'location': location,
      'description': description,
      'responsibilities': responsibilities,
      'requirements': requirements,
      'skills': skills,
      'postedAt': postedAt.toUtc().toIso8601String(),
      if (applicationDeadline != null)
        'applicationDeadline': applicationDeadline!.toUtc().toIso8601String(),
      'positions': positions,
      'status': status.name,
      if (latitude != null) 'latitude': latitude,
      if (longitude != null) 'longitude': longitude,
      if (geohash != null)
        'geohash': geohash
      else if (latitude != null && longitude != null)
        'geohash': encodeGeohash(latitude!, longitude!),
      if (city != null) 'city': city,
      if (state != null) 'state': state,
      'verified': verified,
      if (workingHours != null) 'workingHours': workingHours,
      'benefits': benefits,
    };
  }
}
