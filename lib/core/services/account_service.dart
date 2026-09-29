import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../constants/account_status.dart';
import '../constants/supabase_constants.dart';

/// Thrown when re-authentication is required.
class RequiresRecentLoginException implements Exception {}

/// Thrown when re-authentication fails before deletion.
class AccountDeletionAuthException implements Exception {
  AccountDeletionAuthException([this.message = 'Authentication failed. Account was not deleted.']);
  final String message;
}

class AccountService {
  AccountService._();

  static final AccountService instance = AccountService._();

  final SupabaseClient _supabase = Supabase.instance.client;

  Future<void> deactivateAccount(String uid) async {
    await _supabase.from(SupabaseConstants.users).update({
      'accountStatus': AccountStatus.deactivated,
      'deactivatedAt': DateTime.now().toIso8601String(),
      'profileVisible': false,
      'isDiscoverable': false,
      'availability': false,
      'availableForDuties': false,
      'emergencyAvailable': false,
      'onlineStatus': 'offline',
    }).eq('uid', uid);

    await _setCommunityPostsHidden(uid, hidden: true);
  }

  Future<void> reactivateAccount(String uid) async {
    await _supabase.from(SupabaseConstants.users).update({
      'accountStatus': AccountStatus.active,
      'reactivatedAt': DateTime.now().toIso8601String(),
      'profileVisible': true,
      'isDiscoverable': true,
      'availability': true,
      'availableForDuties': true,
    }).eq('uid', uid);

    await _setCommunityPostsHidden(uid, hidden: false);
  }

  Future<void> _setCommunityPostsHidden(String uid, {required bool hidden}) async {
    try {
      await _supabase.from(SupabaseConstants.communityPosts).update({
        'hidden': hidden,
        'hiddenReason': hidden ? 'account_deactivated' : null,
      }).eq('authorId', uid);
    } catch (e) {
      debugPrint('AccountService: community hide/unhide failed: $e');
    }
  }

  Future<void> permanentlyDeleteAccount({
    required User user,
    dynamic credential,
    bool skipReauth = false,
  }) async {
    final uid = user.id;
    await _deleteUserData(uid);

    try {
      await _deleteStorageForUser(uid);
    } catch (e) {
      debugPrint('AccountService storage cleanup failed: $e');
    }

    try {
      await _supabase.auth.signOut();
    } catch (e) {
      debugPrint('AccountService signout failed: $e');
    }
  }

  Future<void> _deleteUserData(String uid) async {
    try {
      await _supabase.from(SupabaseConstants.savedItems).delete().eq('userId', uid);
      await _supabase.from(SupabaseConstants.followers).delete().eq('userId', uid);
      await _supabase.from(SupabaseConstants.following).delete().eq('userId', uid);
      await _supabase.from(SupabaseConstants.activityItems).delete().eq('userId', uid);
      await _supabase.from(SupabaseConstants.notifications).delete().eq('userId', uid);
      await _supabase.from(SupabaseConstants.walletTransactions).delete().eq('userId', uid);
      await _supabase.from(SupabaseConstants.dutyApplications).delete().eq('userId', uid);
      await _supabase.from(SupabaseConstants.users).delete().eq('uid', uid);
    } catch (e) {
      debugPrint('AccountService: delete user data failed: $e');
    }
  }

  Future<void> _deleteStorageForUser(String uid) async {
    try {
      final files = await _supabase.storage.from(SupabaseConstants.profileImagesBucket).list(path: uid);
      if (files.isNotEmpty) {
        final paths = files.map((f) => '$uid/${f.name}').toList();
        await _supabase.storage.from(SupabaseConstants.profileImagesBucket).remove(paths);
      }
    } catch (_) {}
  }
}
