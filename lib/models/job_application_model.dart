enum JobApplicationStatus {
  applied,
  underReview,
  shortlisted,
  interview,
  selected,
  rejected,
  withdrawn,
}

class JobApplicationModel {
  final String id;
  final String userId;
  final String jobId;
  final String hospitalId;
  final String hospitalName;
  final String title;
  final String location;
  final JobApplicationStatus status;
  final DateTime appliedAt;
  final DateTime? updatedAt;
  final String? resumeUrl;
  final double? salaryMin;
  final double? salaryMax;

  JobApplicationModel({
    required this.id,
    required this.userId,
    required this.jobId,
    required this.hospitalId,
    required this.hospitalName,
    required this.title,
    required this.location,
    required this.status,
    required this.appliedAt,
    this.updatedAt,
    this.resumeUrl,
    this.salaryMin,
    this.salaryMax,
  });

  static DateTime _parseDate(dynamic value, [DateTime? fallback]) {
    if (value is DateTime) return value;
    if (value is String) return DateTime.tryParse(value) ?? (fallback ?? DateTime.now());
    if (value is int) return DateTime.fromMillisecondsSinceEpoch(value);
    return fallback ?? DateTime.now();
  }

  factory JobApplicationModel.fromMap(Map<String, dynamic> map, String id) {
    return JobApplicationModel(
      id: id,
      userId: map['userId'] ?? '',
      jobId: map['jobId'] ?? '',
      hospitalId: map['hospitalId'] ?? '',
      hospitalName: map['hospitalName'] ?? '',
      title: map['title'] ?? '',
      location: map['location'] ?? '',
      status: JobApplicationStatus.values.firstWhere(
        (e) => e.name == (map['status'] ?? 'applied'),
        orElse: () => JobApplicationStatus.applied,
      ),
      appliedAt: _parseDate(map['appliedAt']),
      updatedAt: map['updatedAt'] != null ? _parseDate(map['updatedAt']) : null,
      resumeUrl: map['resumeUrl'],
      salaryMin: (map['salaryMin'] as num?)?.toDouble(),
      salaryMax: (map['salaryMax'] as num?)?.toDouble(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'jobId': jobId,
      'hospitalId': hospitalId,
      'hospitalName': hospitalName,
      'title': title,
      'location': location,
      'status': status.name,
      'appliedAt': appliedAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'resumeUrl': resumeUrl,
      'salaryMin': salaryMin,
      'salaryMax': salaryMax,
      'applicationType': 'job',
    };
  }
}
