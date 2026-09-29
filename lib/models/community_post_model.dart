

import 'post_visibility.dart';
import 'professional_post_category.dart';

class CommunityPostModel {
  final String id;
  final String authorId;
  final String authorName;
  final String? authorAvatar;
  final String content;
  final List<String> imageUrls;
  final List<String> documentUrls;
  final List<String> likedBy;
  final int commentsCount;
  final int repostCount;
  final DateTime createdAt;
  final bool isProfessional;
  final ProfessionalPostCategory? category;
  final PostVisibility visibility;
  final String? authorSpecialty;
  final String? authorHospital;
  final String? authorRole;
  final bool authorVerified;
  final Map<String, dynamic> experienceMeta;
  final bool hidden;
  final String? hiddenReason;

  CommunityPostModel({
    required this.id,
    required this.authorId,
    required this.authorName,
    this.authorAvatar,
    required this.content,
    this.imageUrls = const [],
    this.documentUrls = const [],
    this.likedBy = const [],
    this.commentsCount = 0,
    this.repostCount = 0,
    required this.createdAt,
    this.isProfessional = false,
    this.category,
    this.visibility = PostVisibility.public,
    this.authorSpecialty,
    this.authorHospital,
    this.authorRole,
    this.authorVerified = false,
    this.experienceMeta = const {},
    this.hidden = false,
    this.hiddenReason,
  });

  int get likes => likedBy.length;

  String get visibilityLabel => visibility.label;

  String get categoryLabel => category?.label ?? 'Post';

  factory CommunityPostModel.fromMap(Map<String, dynamic> map, String id) {
    return CommunityPostModel(
      id: id,
      authorId: map['authorId']?.toString() ?? '',
      authorName: map['authorName']?.toString() ?? '',
      authorAvatar: map['authorAvatar']?.toString(),
      content: map['content']?.toString() ?? '',
      imageUrls: List<String>.from(map['imageUrls'] ?? []),
      documentUrls: List<String>.from(map['documentUrls'] ?? []),
      likedBy: List<String>.from(map['likedBy'] ?? []),
      commentsCount: (map['commentsCount'] as num?)?.toInt() ?? 0,
      repostCount: (map['repostCount'] as num?)?.toInt() ?? 0,
      createdAt: _parseDate(map['createdAt']),
      isProfessional: map['isProfessional'] == true,
      category: ProfessionalPostCategoryX.fromString(
        map['category']?.toString(),
      ),
      visibility: PostVisibilityX.fromString(map['visibility']?.toString()),
      authorSpecialty: map['authorSpecialty']?.toString(),
      authorHospital: map['authorHospital']?.toString(),
      authorRole: map['authorRole']?.toString(),
      authorVerified: map['authorVerified'] == true,
      experienceMeta: Map<String, dynamic>.from(map['experienceMeta'] ?? {}),
      hidden: map['hidden'] == true,
      hiddenReason: map['hiddenReason']?.toString(),
    );
  }

  static DateTime _parseDate(dynamic value) {
    if (value is DateTime) return value;
    if (value is String && value.isNotEmpty) {
      return DateTime.tryParse(value) ?? DateTime.now();
    }
    return DateTime.now();
  }

  Map<String, dynamic> toMap() {
    return {
      'authorId': authorId,
      'authorName': authorName,
      'authorAvatar': authorAvatar,
      'content': content,
      'imageUrls': imageUrls,
      'documentUrls': documentUrls,
      'likedBy': likedBy,
      'commentsCount': commentsCount,
      'repostCount': repostCount,
      'createdAt': createdAt.toUtc().toIso8601String(),
      'isProfessional': isProfessional,
      if (category != null) 'category': category!.firestoreValue,
      'visibility': visibility.firestoreValue,
      if (authorSpecialty != null) 'authorSpecialty': authorSpecialty,
      if (authorHospital != null) 'authorHospital': authorHospital,
      if (authorRole != null) 'authorRole': authorRole,
      'authorVerified': authorVerified,
      if (experienceMeta.isNotEmpty) 'experienceMeta': experienceMeta,
      'hidden': hidden,
      if (hiddenReason != null) 'hiddenReason': hiddenReason,
    };
  }

  CommunityPostModel copyWith({
    String? content,
    PostVisibility? visibility,
    List<String>? imageUrls,
    List<String>? documentUrls,
    Map<String, dynamic>? experienceMeta,
    bool? hidden,
  }) {
    return CommunityPostModel(
      id: id,
      authorId: authorId,
      authorName: authorName,
      authorAvatar: authorAvatar,
      content: content ?? this.content,
      imageUrls: imageUrls ?? this.imageUrls,
      documentUrls: documentUrls ?? this.documentUrls,
      likedBy: likedBy,
      commentsCount: commentsCount,
      repostCount: repostCount,
      createdAt: createdAt,
      isProfessional: isProfessional,
      category: category,
      visibility: visibility ?? this.visibility,
      authorSpecialty: authorSpecialty,
      authorHospital: authorHospital,
      authorRole: authorRole,
      authorVerified: authorVerified,
      experienceMeta: experienceMeta ?? this.experienceMeta,
      hidden: hidden ?? this.hidden,
      hiddenReason: hiddenReason,
    );
  }
}

class PostCommentModel {
  final String id;
  final String postId;
  final String authorId;
  final String authorName;
  final String content;
  final DateTime createdAt;
  final List<String> likedBy;

  PostCommentModel({
    required this.id,
    required this.postId,
    required this.authorId,
    required this.authorName,
    required this.content,
    required this.createdAt,
    this.likedBy = const [],
  });

  factory PostCommentModel.fromMap(Map<String, dynamic> map, String id) {
    return PostCommentModel(
      id: id,
      postId: map['postId']?.toString() ?? '',
      authorId: map['authorId']?.toString() ?? '',
      authorName: map['authorName']?.toString() ?? '',
      content: map['content']?.toString() ?? '',
      createdAt: CommunityPostModel._parseDate(map['createdAt']),
      likedBy: List<String>.from(map['likedBy'] ?? []),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'postId': postId,
      'authorId': authorId,
      'authorName': authorName,
      'content': content,
      'createdAt': createdAt.toUtc().toIso8601String(),
      'likedBy': likedBy,
    };
  }
}
