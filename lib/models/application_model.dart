enum ApplicationStatus {
  pending,
  accepted,
  rejected,
  shortlisted,
  completed,
  withdrawn,
}

class ApplicationModel {
  final String id;
  final String userId;
  final String dutyId;
  final String hospitalId;
  final String hospitalName;
  final String role;
  final String location;
  final DateTime dutyDate;
  final ApplicationStatus status;
  final DateTime appliedAt;
  final DateTime? updatedAt;
  final String? notes;
  final double? salary;

  ApplicationModel({
    required this.id,
    required this.userId,
    required this.dutyId,
    required this.hospitalId,
    required this.hospitalName,
    required this.role,
    required this.location,
    required this.dutyDate,
    required this.status,
    required this.appliedAt,
    this.updatedAt,
    this.notes,
    this.salary,
  });

  static DateTime _parseDate(dynamic value, [DateTime? fallback]) {
    if (value is DateTime) return value;
    if (value is String) return DateTime.tryParse(value) ?? (fallback ?? DateTime.now());
    if (value is int) return DateTime.fromMillisecondsSinceEpoch(value);
    return fallback ?? DateTime.now();
  }

  factory ApplicationModel.fromMap(Map<String, dynamic> map, String id) {
    return ApplicationModel(
      id: id,
      userId: map['userId'] ?? '',
      dutyId: map['dutyId'] ?? '',
      hospitalId: map['hospitalId'] ?? '',
      hospitalName: map['hospitalName'] ?? '',
      role: map['role'] ?? '',
      location: map['location'] ?? '',
      dutyDate: _parseDate(map['dutyDate']),
      status: ApplicationStatus.values.firstWhere(
        (e) => e.name == (map['status'] ?? 'pending'),
        orElse: () => ApplicationStatus.pending,
      ),
      appliedAt: _parseDate(map['appliedAt']),
      updatedAt: map['updatedAt'] != null ? _parseDate(map['updatedAt']) : null,
      notes: map['notes'],
      salary: (map['salary'] as num?)?.toDouble(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'dutyId': dutyId,
      'hospitalId': hospitalId,
      'hospitalName': hospitalName,
      'role': role,
      'location': location,
      'dutyDate': dutyDate.toIso8601String(),
      'status': status.name,
      'appliedAt': appliedAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'notes': notes,
      'salary': salary,
    };
  }
}
