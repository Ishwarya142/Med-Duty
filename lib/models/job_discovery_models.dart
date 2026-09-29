import 'job_model.dart';

class JobDiscoveryFilters {
  final Set<String> specializations;
  final Set<EmploymentType> employmentTypes;
  final String? experienceBand;
  final double? salaryMin;
  final double? salaryMax;
  final WorkMode? workMode;
  final int? postedWithinDays;
  final bool verifiedHospitalsOnly;

  const JobDiscoveryFilters({
    this.specializations = const {},
    this.employmentTypes = const {},
    this.experienceBand,
    this.salaryMin,
    this.salaryMax,
    this.workMode,
    this.postedWithinDays,
    this.verifiedHospitalsOnly = false,
  });

  bool get isEmpty =>
      specializations.isEmpty &&
      employmentTypes.isEmpty &&
      experienceBand == null &&
      salaryMin == null &&
      salaryMax == null &&
      workMode == null &&
      postedWithinDays == null &&
      !verifiedHospitalsOnly;

  JobDiscoveryFilters copyWith({
    Set<String>? specializations,
    Set<EmploymentType>? employmentTypes,
    String? experienceBand,
    double? salaryMin,
    double? salaryMax,
    WorkMode? workMode,
    int? postedWithinDays,
    bool? verifiedHospitalsOnly,
  }) {
    return JobDiscoveryFilters(
      specializations: specializations ?? this.specializations,
      employmentTypes: employmentTypes ?? this.employmentTypes,
      experienceBand: experienceBand ?? this.experienceBand,
      salaryMin: salaryMin ?? this.salaryMin,
      salaryMax: salaryMax ?? this.salaryMax,
      workMode: workMode ?? this.workMode,
      postedWithinDays: postedWithinDays ?? this.postedWithinDays,
      verifiedHospitalsOnly:
          verifiedHospitalsOnly ?? this.verifiedHospitalsOnly,
    );
  }
}

enum JobSortOption { nearest, newest, salaryHigh, recommended }
