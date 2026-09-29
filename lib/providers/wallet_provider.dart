import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../core/constants/supabase_constants.dart';
import '../models/wallet_transaction_model.dart';

class WalletProvider extends ChangeNotifier {
  final SupabaseClient _supabase = Supabase.instance.client;

  StreamSubscription? _walletSubscription;
  StreamSubscription? _transactionsSubscription;

  double _balance = 0.0;
  List<WalletTransactionModel> _transactions = [];
  bool _isLoading = false;

  double get balance => _balance;
  List<WalletTransactionModel> get transactions => _transactions;
  bool get isLoading => _isLoading;

  Future<void> loadWalletData(String userId) async {
    _isLoading = true;
    notifyListeners();

    try {
      _walletSubscription?.cancel();
      _walletSubscription = _supabase
          .from(SupabaseConstants.users)
          .stream(primaryKey: ['uid'])
          .eq('uid', userId)
          .listen((data) {
            if (data.isNotEmpty) {
              _balance = (data.first['walletBalance'] as num?)?.toDouble() ?? 0.0;
              notifyListeners();
            }
          });

      _transactionsSubscription?.cancel();
      _transactionsSubscription = _supabase
          .from(SupabaseConstants.walletTransactions)
          .stream(primaryKey: ['id'])
          .eq('userId', userId)
          .order('createdAt', ascending: false)
          .listen((data) {
            _transactions = data
                .map((row) => WalletTransactionModel.fromMap(row, (row['id'] ?? '').toString()))
                .toList();
            notifyListeners();
          });
    } catch (e) {
      debugPrint('Error loading wallet data: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> requestWithdrawal(
    double amount,
    String method,
    String details,
  ) async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) return;

    try {
      final transactionId = DateTime.now().millisecondsSinceEpoch.toString();
      final newBalance = _balance - amount;
      final transaction = WalletTransactionModel(
        id: transactionId,
        userId: userId,
        type: TransactionType.withdrawal,
        amount: amount,
        balanceAfter: newBalance,
        description: 'Withdrawal via $method',
        createdAt: DateTime.now(),
        withdrawalMethod: method,
        withdrawalStatus: 'pending',
      );

      final map = transaction.toMap();
      map['id'] = transactionId;
      await _supabase.from(SupabaseConstants.walletTransactions).insert(map);

      await _supabase.from(SupabaseConstants.users).update({
        'walletBalance': newBalance,
      }).eq('uid', userId);
    } catch (e) {
      debugPrint('Error requesting withdrawal: $e');
    }
  }

  @override
  void dispose() {
    _walletSubscription?.cancel();
    _transactionsSubscription?.cancel();
    super.dispose();
  }
}
