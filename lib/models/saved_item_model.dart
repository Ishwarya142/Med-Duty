enum SavedItemType {
  duty,
  job,
  hospital,
  doctor,
  post,
  search,
}

class SavedItemModel {
  final String id;
  final String userId;
  final SavedItemType type;
  final String itemId;
  final String title;
  final String? subtitle;
  final String? imageUrl;
  final DateTime savedAt;

  SavedItemModel({
    required this.id,
    required this.userId,
    required this.type,
    required this.itemId,
    required this.title,
    this.subtitle,
    this.imageUrl,
    required this.savedAt,
  });

  static DateTime _parseDate(dynamic value, [DateTime? fallback]) {
    if (value is DateTime) return value;
    if (value is String) return DateTime.tryParse(value) ?? (fallback ?? DateTime.now());
    if (value is int) return DateTime.fromMillisecondsSinceEpoch(value);
    return fallback ?? DateTime.now();
  }

  factory SavedItemModel.fromMap(Map<String, dynamic> map, String id) {
    return SavedItemModel(
      id: id,
      userId: map['userId'] ?? '',
      type: SavedItemType.values.firstWhere(
        (e) => e.name == (map['type'] ?? 'duty'),
        orElse: () => SavedItemType.duty,
      ),
      itemId: map['itemId'] ?? '',
      title: map['title'] ?? '',
      subtitle: map['subtitle'],
      imageUrl: map['imageUrl'],
      savedAt: _parseDate(map['savedAt']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'type': type.name,
      'itemId': itemId,
      'title': title,
      'subtitle': subtitle,
      'imageUrl': imageUrl,
      'savedAt': savedAt.toIso8601String(),
    };
  }
}
