import 'package:supabase_flutter/supabase_flutter.dart';

/// Supabase project configuration and table name constants.
class SupabaseConstants {
  SupabaseConstants._();

  // ─── Project Configuration ───────────────────────────────────────────────────
  static const projectRef = 'vrhbezoxiuymwwwyhqbp';
  static const supabaseUrl = 'https://vrhbezoxiuymwwwyhqbp.supabase.co';
  static const supabaseAnonKey = 'sb_publishable_Eo6h5QqIDeYo3-K0GAZPZQ_Ezx5Rm4e';
  static const directDbConnection =
      'postgresql://postgres:[YOUR-PASSWORD]@db.vrhbezoxiuymwwwyhqbp.supabase.co:5432/postgres';

  // ─── Table Names ─────────────────────────────────────────────────────────────
  static const users = 'users';
  static const duties = 'duties';
  static const dutyApplications = 'duty_applications';
  static const hospitals = 'hospitals';
  static const chats = 'chats';
  static const messages = 'messages';
  static const communityPosts = 'community_posts';
  static const notifications = 'notifications';
  static const jobs = 'jobs';
  static const jobApplications = 'job_applications';
  static const reviews = 'reviews';
  static const walletTransactions = 'wallet_transactions';
  static const savedItems = 'saved_items';
  static const activityItems = 'activity_items';
  static const documents = 'documents';
  static const resumes = 'resumes';
  static const followers = 'followers';
  static const following = 'following';

  // ─── Storage Buckets ─────────────────────────────────────────────────────────
  static const profileImagesBucket = 'profile-images';
  static const coverImagesBucket = 'cover-images';
  static const documentsBucket = 'documents';
  static const communityImagesBucket = 'community-images';
  static const resumesBucket = 'resumes';
}

/// Firebase User compatibility extension for Supabase User
extension SupabaseUserExtension on User {
  String get uid => id;
  String? get photoURL =>
      userMetadata?['avatar_url'] as String? ??
      userMetadata?['picture'] as String?;
  String? get displayName =>
      userMetadata?['full_name'] as String? ??
      userMetadata?['name'] as String?;
  String? get phoneNumber => phone;
}
