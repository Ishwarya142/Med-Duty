import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../core/theme/app_colors.dart';
import '../../providers/wallet_provider.dart';
import '../../models/wallet_transaction_model.dart';

class WalletScreen extends StatelessWidget {
  const WalletScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final walletProvider = Provider.of<WalletProvider>(context);
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Wallet'),
        backgroundColor: AppColors.primary,
        elevation: 0,
        foregroundColor: AppColors.white,
      ),
      body: walletProvider.isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            )
          : ListView(
              padding: const EdgeInsets.all(24),
              children: [
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [AppColors.primary, AppColors.secondary],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: AppColors.cardShadow,
                  ),
                  padding: const EdgeInsets.all(32),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Available Balance',
                        style: TextStyle(color: Colors.white70, fontSize: 16),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '\$${walletProvider.balance.toStringAsFixed(2)}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () {
                          _showWithdrawDialog(context, walletProvider);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: AppColors.primary,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 12,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text('Withdraw'),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  'Transactions',
                  style: TextStyle(
                    color: AppColors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                if (walletProvider.transactions.isEmpty)
                  Center(
                    child: Column(
                      children: [
                        const Icon(
                          Icons.history,
                          size: 60,
                          color: AppColors.grey,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'No transactions yet',
                          style: TextStyle(color: AppColors.grey),
                        ),
                      ],
                    ),
                  )
                else
                  ...walletProvider.transactions.map(
                    (txn) => _buildTransactionCard(txn),
                  ),
              ],
            ),
    );
  }

  void _showWithdrawDialog(
    BuildContext context,
    WalletProvider walletProvider,
  ) {
    final amountController = TextEditingController();
    final methodController = TextEditingController(text: 'Bank Transfer');
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Request Withdrawal'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: amountController,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              decoration: const InputDecoration(labelText: 'Amount'),
            ),
            TextField(
              controller: methodController,
              decoration: const InputDecoration(
                labelText: 'Method (Bank Transfer/UPI)',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final amount = double.tryParse(amountController.text);
              if (amount != null &&
                  amount > 0 &&
                  amount <= walletProvider.balance) {
                await walletProvider.requestWithdrawal(
                  amount,
                  methodController.text,
                  '',
                );
                if (context.mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Withdrawal request submitted'),
                    ),
                  );
                }
              }
            },
            child: const Text('Request'),
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionCard(WalletTransactionModel txn) {
    Color amountColor;
    String prefix;
    if (txn.type == TransactionType.earning) {
      amountColor = Colors.green;
      prefix = '+';
    } else {
      amountColor = Colors.red;
      prefix = '-';
    }
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          boxShadow: AppColors.softShadow,
        ),
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: txn.type == TransactionType.earning
                    ? Colors.green.withValues(alpha: 0.2)
                    : Colors.red.withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(
                txn.type == TransactionType.earning ? Icons.add : Icons.remove,
                color: txn.type == TransactionType.earning
                    ? Colors.green
                    : Colors.red,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    txn.description,
                    style: const TextStyle(
                      color: AppColors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    DateFormat.yMMMd().add_jm().format(txn.createdAt),
                    style: const TextStyle(color: AppColors.grey, fontSize: 12),
                  ),
                ],
              ),
            ),
            Text(
              '$prefix\$${txn.amount.toStringAsFixed(2)}',
              style: TextStyle(
                color: amountColor,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
