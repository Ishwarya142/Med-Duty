import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../core/constants/supabase_constants.dart';
import '../models/saved_item_model.dart';

class SavedProvider extends ChangeNotifier {
  final SupabaseClient _supabase = Supabase.instance.client;

  StreamSubscription? _savedItemsSubscription;

  List<SavedItemModel> _savedItems = [];
  bool _isLoading = false;

  List<SavedItemModel> get savedItems => _savedItems;
  bool get isLoading => _isLoading;

  int get savedDutiesCount =>
      _savedItems.where((item) => item.type == SavedItemType.duty).length;

  int get savedPostsCount =>
      _savedItems.where((item) => item.type == SavedItemType.post).length;

  int get savedHospitalsCount =>
      _savedItems.where((item) => item.type == SavedItemType.hospital).length;

  Future<void> loadSavedItems() async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId != null) {
      await loadSavedData(userId);
    }
  }

  Future<void> loadSavedData(String userId) async {
    _isLoading = true;
    notifyListeners();

    try {
      _savedItemsSubscription?.cancel();
      _savedItemsSubscription = _supabase
          .from(SupabaseConstants.savedItems)
          .stream(primaryKey: ['id'])
          .eq('userId', userId)
          .order('savedAt', ascending: false)
          .listen((data) {
            _savedItems = data
                .map((row) => SavedItemModel.fromMap(row, (row['id'] ?? '').toString()))
                .toList();
            notifyListeners();
          });
    } catch (e) {
      debugPrint('Error loading saved data: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> removeSavedItem(String itemId) async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) return;

    try {
      await _supabase
          .from(SupabaseConstants.savedItems)
          .delete()
          .eq('id', itemId)
          .eq('userId', userId);
    } catch (e) {
      debugPrint('Error removing saved item: $e');
    }
  }

  @override
  void dispose() {
    _savedItemsSubscription?.cancel();
    super.dispose();
  }
}
