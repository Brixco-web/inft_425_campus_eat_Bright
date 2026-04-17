import 'package:cloud_firestore/cloud_firestore.dart';

class WalletModel {
  final String userId;
  final double balance;
  final List<WalletTransaction> transactions;

  WalletModel({
    required this.userId,
    required this.balance,
    this.transactions = const [],
  });

  factory WalletModel.fromMap(Map<String, dynamic> data) {
    return WalletModel(
      userId: data['userId'] ?? '',
      balance: (data['balance'] ?? 0.0).toDouble(),
      transactions: (data['transactions'] as List? ?? [])
          .map((t) => WalletTransaction.fromMap(t))
          .toList(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'balance': balance,
      'transactions': transactions.map((t) => t.toMap()).toList(),
    };
  }
}

enum TransactionType { deposit, purchase, refund }

class WalletTransaction {
  final String id;
  final double amount;
  final TransactionType type;
  final DateTime timestamp;
  final String description;

  WalletTransaction({
    required this.id,
    required this.amount,
    required this.type,
    required this.timestamp,
    required this.description,
  });

  factory WalletTransaction.fromMap(Map<String, dynamic> data) {
    return WalletTransaction(
      id: data['id'] ?? '',
      amount: (data['amount'] ?? 0.0).toDouble(),
      type: TransactionType.values.firstWhere(
        (e) => e.name == data['type'],
        orElse: () => TransactionType.purchase,
      ),
      timestamp: (data['timestamp'] as Timestamp).toDate(),
      description: data['description'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'amount': amount,
      'type': type.name,
      'timestamp': Timestamp.fromDate(timestamp),
      'description': description,
    };
  }
}
