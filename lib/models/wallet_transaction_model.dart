enum TransactionType {
  earning,
  withdrawal,
  deposit,
}

class WalletTransactionModel {
  final String id;
  final String userId;
  final TransactionType type;
  final double amount;
  final double balanceAfter;
  final String description;
  final DateTime createdAt;
  final String? dutyId;
  final String? withdrawalMethod;
  final String? withdrawalStatus;

  WalletTransactionModel({
    required this.id,
    required this.userId,
    required this.type,
    required this.amount,
    required this.balanceAfter,
    required this.description,
    required this.createdAt,
    this.dutyId,
    this.withdrawalMethod,
    this.withdrawalStatus,
  });

  static DateTime _parseDate(dynamic value, [DateTime? fallback]) {
    if (value is DateTime) return value;
    if (value is String) return DateTime.tryParse(value) ?? (fallback ?? DateTime.now());
    if (value is int) return DateTime.fromMillisecondsSinceEpoch(value);
    return fallback ?? DateTime.now();
  }

  factory WalletTransactionModel.fromMap(Map<String, dynamic> map, String id) {
    return WalletTransactionModel(
      id: id,
      userId: map['userId'] ?? '',
      type: TransactionType.values.firstWhere(
        (e) => e.name == (map['type'] ?? 'earning'),
        orElse: () => TransactionType.earning,
      ),
      amount: (map['amount'] as num?)?.toDouble() ?? 0.0,
      balanceAfter: (map['balanceAfter'] as num?)?.toDouble() ?? 0.0,
      description: map['description'] ?? '',
      createdAt: _parseDate(map['createdAt']),
      dutyId: map['dutyId'],
      withdrawalMethod: map['withdrawalMethod'],
      withdrawalStatus: map['withdrawalStatus'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'type': type.name,
      'amount': amount,
      'balanceAfter': balanceAfter,
      'description': description,
      'createdAt': createdAt.toIso8601String(),
      'dutyId': dutyId,
      'withdrawalMethod': withdrawalMethod,
      'withdrawalStatus': withdrawalStatus,
    };
  }
}
