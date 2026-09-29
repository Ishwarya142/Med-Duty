import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../core/constants/supabase_constants.dart';
import '../core/utils/professional_post_utils.dart';
import '../models/community_post_model.dart';
import '../models/post_visibility.dart';
import '../models/professional_post_category.dart';

class CommunityProvider extends ChangeNotifier {
  final SupabaseClient _supabase = Supabase.instance.client;

  StreamSubscription? _myPostsSubscription;
  StreamSubscription? _savedPostsSubscription;
  StreamSubscription? _networkPostsSubscription;

  List<CommunityPostModel> _myPosts = [];
  List<CommunityPostModel> _authorPosts = [];
  List<CommunityPostModel> _networkPosts = [];
  List<String> _savedPostsIds = [];
  final Set<String> _likedPostsIds = {};

  bool _isLoading = false;
  bool _networkLoading = false;

  int _myPostsCount = 0;
  int _savedPostsCount = 0;

  List<CommunityPostModel> get myPosts => _myPosts;
  List<CommunityPostModel> get posts => _myPosts;
  List<CommunityPostModel> get authorPosts => _authorPosts;
  List<CommunityPostModel> get networkProfessionalPosts => _networkPosts;
  List<CommunityPostModel> get likedPosts =>
      _myPosts.where((post) => _likedPostsIds.contains(post.id)).toList();
  List<CommunityPostModel> get savedPosts =>
      _myPosts.where((post) => _savedPostsIds.contains(post.id)).toList();
  List<String> get savedPostsIds => _savedPostsIds;
  bool get isLoading => _isLoading;
  bool get networkLoading => _networkLoading;
  int get myPostsCount => _myPostsCount;
  int get savedPostsCount => _savedPostsCount;

  bool isPostLiked(String postId) => _likedPostsIds.contains(postId);

  bool isPostSaved(String postId) => _savedPostsIds.contains(postId);

  void _syncLikedIds(List<CommunityPostModel> posts) {
    final uid = _supabase.auth.currentUser?.id;
    if (uid == null) return;
    _likedPostsIds
      ..clear()
      ..addAll(
        posts.where((p) => p.likedBy.contains(uid)).map((p) => p.id),
      );
  }

  Future<void> loadPosts() async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId != null) await loadCommunityData(userId);
  }

  Future<void> loadSavedPosts() async {}
  Future<void> loadLikedPosts() async {}

  Future<void> loadCommunityData(String userId) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _myPostsSubscription?.cancel();

      _myPostsSubscription = _supabase
          .from(SupabaseConstants.communityPosts)
          .stream(primaryKey: ['id'])
          .eq('authorId', userId)
          .order('createdAt', ascending: false)
          .listen((rows) {
        _myPosts = rows
            .where((doc) => doc['hidden'] != true)
            .map((doc) => CommunityPostModel.fromMap(doc, (doc['id'] ?? '').toString()))
            .toList();
        _myPostsCount = _myPosts.length;
        _syncLikedIds(_myPosts);
        notifyListeners();
      });

      await _savedPostsSubscription?.cancel();
      _savedPostsSubscription = _supabase
          .from(SupabaseConstants.savedItems)
          .stream(primaryKey: ['id'])
          .eq('userId', userId)
          .listen((rows) {
        _savedPostsIds = rows
            .where((doc) => doc['type'] == 'post')
            .map((doc) => (doc['itemId'] as String?) ?? '')
            .where((id) => id.isNotEmpty)
            .toList();
        _savedPostsCount = _savedPostsIds.length;
        notifyListeners();
      });
    } catch (e) {
      debugPrint('Error loading community data: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadAuthorPosts({
    required String authorId,
    required String? viewerId,
    required bool isFollowingAuthor,
    required bool isOwner,
  }) async {
    try {
      final snap = await _supabase
          .from(SupabaseConstants.communityPosts)
          .select()
          .eq('authorId', authorId)
          .order('createdAt', ascending: false)
          .limit(50);

      _authorPosts = List<Map<String, dynamic>>.from(snap)
          .map((d) => CommunityPostModel.fromMap(d, (d['id'] ?? '').toString()))
          .where(
            (p) => ProfessionalPostUtils.canViewPost(
              post: p,
              viewerId: viewerId,
              isFollowingAuthor: isFollowingAuthor,
              isOwner: isOwner,
            ),
          )
          .toList();
      _syncLikedIds(_authorPosts);
      notifyListeners();
    } catch (e) {
      debugPrint('loadAuthorPosts error: $e');
    }
  }

  Future<void> loadNetworkProfessionalPosts({
    required Set<String> followingIds,
    required String? viewerId,
  }) async {
    _networkLoading = true;
    notifyListeners();

    try {
      await _networkPostsSubscription?.cancel();

      _networkPostsSubscription = _supabase
          .from(SupabaseConstants.communityPosts)
          .stream(primaryKey: ['id'])
          .eq('isProfessional', true)
          .order('createdAt', ascending: false)
          .limit(60)
          .listen((rows) {
        final uid = viewerId;
        _networkPosts = rows
            .map((d) => CommunityPostModel.fromMap(d, (d['id'] ?? '').toString()))
            .where((p) {
          if (p.hidden) return false;
          if (uid != null && p.authorId == uid) return true;
          if (p.visibility == PostVisibility.public) return true;
          if (p.visibility == PostVisibility.followers &&
              followingIds.contains(p.authorId)) {
            return true;
          }
          return false;
        }).toList();
        _syncLikedIds(_networkPosts);
        _networkLoading = false;
        notifyListeners();
      });
    } catch (e) {
      debugPrint('loadNetworkProfessionalPosts error: $e');
      _networkLoading = false;
      notifyListeners();
    }
  }

  Future<String?> createProfessionalPost({
    required ProfessionalPostCategory category,
    required String content,
    required PostVisibility visibility,
    required Map<String, dynamic> experienceMeta,
    List<String> imageUrls = const [],
    List<String> documentUrls = const [],
    required String authorName,
    String? authorAvatar,
    String? authorSpecialty,
    String? authorHospital,
    String? authorRole,
    bool authorVerified = false,
  }) async {
    final user = _supabase.auth.currentUser;
    if (user == null) return null;

    try {
      final res = await _supabase.from(SupabaseConstants.communityPosts).insert({
        'authorId': user.id,
        'authorName': authorName,
        'authorAvatar': authorAvatar,
        'content': content.trim(),
        'imageUrls': imageUrls,
        'documentUrls': documentUrls,
        'likedBy': <String>[],
        'commentsCount': 0,
        'repostCount': 0,
        'createdAt': DateTime.now().toIso8601String(),
        'isProfessional': true,
        'category': category.firestoreValue,
        'visibility': visibility.firestoreValue,
        'authorSpecialty': authorSpecialty,
        'authorHospital': authorHospital,
        'authorRole': authorRole,
        'authorVerified': authorVerified,
        'experienceMeta': experienceMeta,
        'hidden': false,
      }).select('id').single();

      final postId = (res['id'] ?? '').toString();

      await _notifyFollowersOfNewPost(
        authorId: user.id,
        authorName: authorName,
        postId: postId,
        visibility: visibility,
      );

      return postId;
    } catch (e) {
      debugPrint('createProfessionalPost error: $e');
      return null;
    }
  }

  Future<void> _notifyFollowersOfNewPost({
    required String authorId,
    required String authorName,
    required String postId,
    required PostVisibility visibility,
  }) async {
    if (visibility == PostVisibility.private) return;

    try {
      final followers = await _supabase
          .from(SupabaseConstants.followers)
          .select('userId')
          .eq('targetId', authorId)
          .limit(30);

      for (final follower in List<Map<String, dynamic>>.from(followers)) {
        final fid = (follower['userId'] ?? '').toString();
        if (fid.isEmpty) continue;
        await _supabase.from(SupabaseConstants.notifications).insert({
          'userId': fid,
          'type': 'professional_post',
          'title': '$authorName shared a professional update',
          'body': 'Tap to view in Community',
          'postId': postId,
          'authorId': authorId,
          'read': false,
          'createdAt': DateTime.now().toIso8601String(),
        });
      }
    } catch (e) {
      debugPrint('notify followers error: $e');
    }
  }

  Future<bool> updatePostVisibility(String postId, PostVisibility visibility) async {
    try {
      await _supabase.from(SupabaseConstants.communityPosts).update({
        'visibility': visibility.firestoreValue,
      }).eq('id', postId);
      return true;
    } catch (e) {
      debugPrint('updatePostVisibility error: $e');
      return false;
    }
  }

  Future<bool> updatePostContent(String postId, String content) async {
    try {
      await _supabase.from(SupabaseConstants.communityPosts).update({
        'content': content.trim(),
      }).eq('id', postId);
      return true;
    } catch (e) {
      debugPrint('updatePostContent error: $e');
      return false;
    }
  }

  Future<bool> deletePost(String postId) async {
    try {
      await _supabase.from(SupabaseConstants.communityPosts).delete().eq('id', postId);
      return true;
    } catch (e) {
      debugPrint('deletePost error: $e');
      return false;
    }
  }

  Future<void> toggleLikePost(String postId) async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) return;

    try {
      final postDoc = await _supabase
          .from(SupabaseConstants.communityPosts)
          .select()
          .eq('id', postId)
          .maybeSingle();

      if (postDoc == null) return;
      final likedBy = List<String>.from(postDoc['likedBy'] ?? []);
      final wasLiked = likedBy.contains(userId);

      if (wasLiked) {
        likedBy.remove(userId);
        _likedPostsIds.remove(postId);
      } else {
        likedBy.add(userId);
        _likedPostsIds.add(postId);
        notifyListeners();

        final authorId = postDoc['authorId']?.toString();
        if (authorId != null && authorId != userId) {
          await _supabase.from(SupabaseConstants.notifications).insert({
            'userId': authorId,
            'type': 'post_like',
            'title': 'Someone liked your professional update',
            'body': postDoc['content']?.toString() ?? '',
            'postId': postId,
            'read': false,
            'createdAt': DateTime.now().toIso8601String(),
          });
        }
      }

      await _supabase
          .from(SupabaseConstants.communityPosts)
          .update({'likedBy': likedBy})
          .eq('id', postId);
      notifyListeners();
    } catch (e) {
      debugPrint('Error toggling like: $e');
    }
  }

  Future<void> toggleSavePost(
    String postId, [
    String? title,
    String? content,
  ]) async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) return;

    try {
      if (_savedPostsIds.contains(postId)) {
        await _supabase
            .from(SupabaseConstants.savedItems)
            .delete()
            .eq('userId', userId)
            .eq('itemId', postId);
      } else {
        await _supabase.from(SupabaseConstants.savedItems).insert({
          'userId': userId,
          'type': 'post',
          'itemId': postId,
          'title': title ?? 'Post',
          'subtitle': content,
          'savedAt': DateTime.now().toIso8601String(),
        });
      }
    } catch (e) {
      debugPrint('Error toggling save post: $e');
    }
  }

  Future<void> incrementRepostCount(String postId) async {
    try {
      final doc = await _supabase
          .from(SupabaseConstants.communityPosts)
          .select('repostCount')
          .eq('id', postId)
          .maybeSingle();
      final count = (doc?['repostCount'] as int? ?? 0) + 1;
      await _supabase
          .from(SupabaseConstants.communityPosts)
          .update({'repostCount': count})
          .eq('id', postId);
    } catch (e) {
      debugPrint('incrementRepostCount error: $e');
    }
  }

  Stream<List<PostCommentModel>> watchComments(String postId) {
    return _supabase
        .from('post_comments')
        .stream(primaryKey: ['id'])
        .eq('postId', postId)
        .order('createdAt', ascending: true)
        .map(
          (rows) => rows
              .map((d) => PostCommentModel.fromMap(d, (d['id'] ?? '').toString()))
              .toList(),
        );
  }

  Future<bool> addComment(String postId, String text, String authorName) async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null || text.trim().isEmpty) return false;

    try {
      await _supabase.from('post_comments').insert({
        'postId': postId,
        'authorId': userId,
        'authorName': authorName,
        'content': text.trim(),
        'createdAt': DateTime.now().toIso8601String(),
        'likedBy': <String>[],
      });

      final doc = await _supabase
          .from(SupabaseConstants.communityPosts)
          .select('commentsCount, authorId')
          .eq('id', postId)
          .maybeSingle();

      final count = (doc?['commentsCount'] as int? ?? 0) + 1;
      await _supabase
          .from(SupabaseConstants.communityPosts)
          .update({'commentsCount': count})
          .eq('id', postId);

      final authorId = doc?['authorId']?.toString();
      if (authorId != null && authorId != userId) {
        await _supabase.from(SupabaseConstants.notifications).insert({
          'userId': authorId,
          'type': 'post_comment',
          'title': '$authorName commented on your professional update',
          'body': text.trim(),
          'postId': postId,
          'read': false,
          'createdAt': DateTime.now().toIso8601String(),
        });
      }
      return true;
    } catch (e) {
      debugPrint('addComment error: $e');
      return false;
    }
  }

  Future<bool> deleteComment(String postId, String commentId) async {
    try {
      await _supabase.from('post_comments').delete().eq('id', commentId);
      final doc = await _supabase
          .from(SupabaseConstants.communityPosts)
          .select('commentsCount')
          .eq('id', postId)
          .maybeSingle();

      final count = (doc?['commentsCount'] as int? ?? 1) - 1;
      await _supabase
          .from(SupabaseConstants.communityPosts)
          .update({'commentsCount': count > 0 ? count : 0})
          .eq('id', postId);
      return true;
    } catch (e) {
      debugPrint('deleteComment error: $e');
      return false;
    }
  }

  CommunityPostModel? findPostById(String postId) {
    for (final p in [..._myPosts, ..._authorPosts, ..._networkPosts]) {
      if (p.id == postId) return p;
    }
    return null;
  }

  @override
  void dispose() {
    _myPostsSubscription?.cancel();
    _savedPostsSubscription?.cancel();
    _networkPostsSubscription?.cancel();
    super.dispose();
  }
}
