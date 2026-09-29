enum ActivityType {
  notification,
  search,
  view,
  login,
  profileVisit,
}

class ActivityItemModel {
  final String id;
  final String userId;
  final ActivityType type;
  final String title;
  final String? description;
  final DateTime createdAt;
  final String? relatedId;

  ActivityItemModel({
    required this.id,
    required this.userId,
    required this.type,
    required this.title,
    this.description,
    required this.createdAt,
    this.relatedId,
  });

  static DateTime _parseDate(dynamic value, [DateTime? fallback]) {
    if (value is DateTime) return value;
    if (value is String) return DateTime.tryParse(value) ?? (fallback ?? DateTime.now());
    if (value is int) return DateTime.fromMillisecondsSinceEpoch(value);
    return fallback ?? DateTime.now();
  }

  factory ActivityItemModel.fromMap(Map<String, dynamic> map, String id) {
    return ActivityItemModel(
      id: id,
      userId: map['userId'] ?? '',
      type: ActivityType.values.firstWhere(
        (e) => e.name == (map['type'] ?? 'notification'),
        orElse: () => ActivityType.notification,
      ),
      title: map['title'] ?? '',
      description: map['description'],
      createdAt: _parseDate(map['createdAt']),
      relatedId: map['relatedId'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'type': type.name,
      'title': title,
      'description': description,
      'createdAt': createdAt.toIso8601String(),
      'relatedId': relatedId,
    };
  }
}
