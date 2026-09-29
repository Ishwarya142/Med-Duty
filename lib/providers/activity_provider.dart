import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../core/constants/supabase_constants.dart';
import '../models/activity_item_model.dart';

class ActivityProvider extends ChangeNotifier {
  final SupabaseClient _supabase = Supabase.instance.client;

  StreamSubscription? _activitySubscription;

  List<ActivityItemModel> _activityItems = [];
  bool _isLoading = false;

  List<ActivityItemModel> get activityItems => _activityItems;
  List<ActivityItemModel> get activity => _activityItems;
  bool get isLoading => _isLoading;

  int get notificationsCount => _activityItems
      .where((item) => item.type == ActivityType.notification)
      .length;

  Future<void> loadActivity() async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId != null) {
      await loadActivityData(userId);
    }
  }

  Future<void> loadActivityData(String userId) async {
    _isLoading = true;
    notifyListeners();

    try {
      _activitySubscription?.cancel();
      _activitySubscription = _supabase
          .from(SupabaseConstants.activityItems)
          .stream(primaryKey: ['id'])
          .eq('userId', userId)
          .order('createdAt', ascending: false)
          .listen((data) {
            _activityItems = data
                .map((row) => ActivityItemModel.fromMap(row, (row['id'] ?? '').toString()))
                .toList();
            notifyListeners();
          });
    } catch (e) {
      debugPrint('Error loading activity data: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> clearActivityHistory() async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) return;

    try {
      await _supabase
          .from(SupabaseConstants.activityItems)
          .delete()
          .eq('userId', userId);
      _activityItems = [];
      notifyListeners();
    } catch (e) {
      debugPrint('Error clearing activity: $e');
    }
  }

  @override
  void dispose() {
    _activitySubscription?.cancel();
    super.dispose();
  }
}
