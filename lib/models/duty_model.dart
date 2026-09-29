

import '../core/utils/geohash_utils.dart';

enum DutyStatus {
  upcoming,
  ongoing,
  completed,
  cancelled,
  applied,
}

enum DutyPriority {
  normal,
  urgent,
  emergency,
}

class DutyModel {
  final String id;
  final String hospitalId;
  final String hospitalName;
  final String role;
  final double salary;
  final String location;
  final DateTime dutyDate;
  final DateTime startTime;
  final DateTime endTime;
  final DutyStatus status;
  final String? description;
  final DateTime createdAt;
  final List<String> requirements;

  // Location-aware fields (optional — backward compatible)
  final double? latitude;
  final double? longitude;
  final String? specialization;
  final String? shiftType;
  final String? dutyType;
  final DutyPriority priority;
  final String? emergencyReason;
  /// Hours the emergency posting stays visible (poster-defined, default 15).
  final int emergencyWindowHours;
  final bool verified;
  final String? address;
  final String? city;
  final String? state;
  final String? geohash;

  DutyModel({
    required this.id,
    required this.hospitalId,
    required this.hospitalName,
    required this.role,
    required this.salary,
    required this.location,
    required this.dutyDate,
    required this.startTime,
    required this.endTime,
    required this.status,
    this.description,
    required this.createdAt,
    this.requirements = const [],
    this.latitude,
    this.longitude,
    this.specialization,
    this.shiftType,
    this.dutyType,
    this.priority = DutyPriority.normal,
    this.emergencyReason,
    this.emergencyWindowHours = 24,
    this.verified = false,
    this.address,
    this.city,
    this.state,
    this.geohash,
  });

  bool get hasCoordinates => latitude != null && longitude != null;

  bool get isEmergency => priority == DutyPriority.emergency;

  String get displaySpecialization => specialization ?? role;

  String get displayShift => shiftType ?? 'Flexible';

  static DateTime _parseDate(dynamic value, [DateTime? fallback]) {
    if (value is DateTime) return value;
    if (value is String && value.isNotEmpty) {
      return DateTime.tryParse(value) ?? fallback ?? DateTime.now();
    }
    return fallback ?? DateTime.now();
  }

  static DutyPriority _parsePriority(Map<String, dynamic> map) {
    final raw = map['priority'] as String?;
    if (raw != null) {
      return DutyPriority.values.firstWhere(
        (e) => e.name == raw,
        orElse: () => DutyPriority.normal,
      );
    }
    return DutyPriority.normal;
  }

  factory DutyModel.fromMap(Map<String, dynamic> map, String id) {
    return DutyModel(
      id: id,
      hospitalId: map['hospitalId'] ?? '',
      hospitalName: map['hospitalName'] ?? '',
      role: map['role'] ?? map['title'] ?? '',
      salary: (map['salary'] as num?)?.toDouble() ??
          (map['payout'] as num?)?.toDouble() ??
          0.0,
      location: map['location'] ?? map['address'] ?? '',
      dutyDate: _parseDate(map['dutyDate']),
      startTime: _parseDate(map['startTime'], _parseDate(map['dutyDate'])),
      endTime: _parseDate(map['endTime'], _parseDate(map['dutyDate'])),
      status: DutyStatus.values.firstWhere(
        (e) => e.name == (map['status'] ?? 'upcoming'),
        orElse: () => DutyStatus.upcoming,
      ),
      description: map['description'],
      createdAt: _parseDate(map['createdAt']),
      requirements: List<String>.from(map['requirements'] ?? []),
      latitude: (map['latitude'] as num?)?.toDouble(),
      longitude: (map['longitude'] as num?)?.toDouble(),
      specialization: map['specialization'] as String?,
      shiftType: map['shiftType'] as String?,
      dutyType: map['dutyType'] as String?,
      priority: _parsePriority(map),
      emergencyReason: map['emergencyReason'] as String?,
      emergencyWindowHours: (map['emergencyWindowHours'] as num?)?.toInt() ?? 24,
      verified: map['verified'] == true,
      address: map['address'] as String?,
      city: map['city'] as String?,
      state: map['state'] as String?,
      geohash: map['geohash'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'hospitalId': hospitalId,
      'hospitalName': hospitalName,
      'role': role,
      'title': role,
      'salary': salary,
      'payout': salary,
      'location': location,
      'dutyDate': dutyDate.toUtc().toIso8601String(),
      'startTime': startTime.toUtc().toIso8601String(),
      'endTime': endTime.toUtc().toIso8601String(),
      'status': status.name,
      'description': description,
      'createdAt': createdAt.toUtc().toIso8601String(),
      'requirements': requirements,
      if (latitude != null) 'latitude': latitude,
      if (longitude != null) 'longitude': longitude,
      if (specialization != null) 'specialization': specialization,
      if (shiftType != null) 'shiftType': shiftType,
      if (dutyType != null) 'dutyType': dutyType,
      'priority': priority.name,
      if (emergencyReason != null) 'emergencyReason': emergencyReason,
      if (priority == DutyPriority.emergency)
        'emergencyWindowHours': emergencyWindowHours,
      'verified': verified,
      if (address != null) 'address': address,
      if (city != null) 'city': city,
      if (state != null) 'state': state,
      if (geohash != null)
        'geohash': geohash
      else if (latitude != null && longitude != null)
        'geohash': encodeGeohash(latitude!, longitude!),
    };
  }

  DutyModel copyWith({
    DutyStatus? status,
    DutyPriority? priority,
    String? emergencyReason,
    int? emergencyWindowHours,
  }) {
    return DutyModel(
      id: id,
      hospitalId: hospitalId,
      hospitalName: hospitalName,
      role: role,
      salary: salary,
      location: location,
      dutyDate: dutyDate,
      startTime: startTime,
      endTime: endTime,
      status: status ?? this.status,
      description: description,
      createdAt: createdAt,
      requirements: requirements,
      latitude: latitude,
      longitude: longitude,
      specialization: specialization,
      shiftType: shiftType,
      dutyType: dutyType,
      priority: priority ?? this.priority,
      emergencyReason: emergencyReason ?? this.emergencyReason,
      emergencyWindowHours: emergencyWindowHours ?? this.emergencyWindowHours,
      verified: verified,
      address: address,
      city: city,
      state: state,
      geohash: geohash,
    );
  }
}
