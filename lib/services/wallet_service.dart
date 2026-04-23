import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/wallet_model.dart';

/// Service for managing the "Obsidian Wallet" prepaid system.
class WalletService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Collection Reference
  CollectionReference get _wallets => _db.collection('wallets');

  /// Streams the wallet data for a specific user.
  Stream<WalletModel?> getWalletStream(String userId) {
    return _wallets.doc(userId).snapshots().map((snapshot) {
      if (!snapshot.exists) {
        return null;
      }
      return WalletModel.fromMap(snapshot.data() as Map<String, dynamic>);
    });
  }

  /// Administrator capability: Top up a student's wallet balance.
  /// Used for recording manual advances paid to the cafeteria admin.
  Future<void> topUpBalance(String userId, double amount, String adminId) async {
    final docRef = _wallets.doc(userId);
    
    await _db.runTransaction((transaction) async {
      final snapshot = await transaction.get(docRef);
      
      double currentBalance = 0.0;
      List<dynamic> transactions = [];
      
      if (snapshot.exists) {
        final data = snapshot.data() as Map<String, dynamic>;
        currentBalance = (data['balance'] ?? 0.0).toDouble();
        transactions = data['transactions'] as List? ?? [];
      }
      
      final newTransaction = WalletTransaction(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        amount: amount,
        type: TransactionType.deposit,
        timestamp: DateTime.now(),
        description: 'Advance payment recorded by Admin $adminId',
      );
      
      transactions.add(newTransaction.toMap());
      
      transaction.set(docRef, {
        'userId': userId,
        'balance': currentBalance + amount,
        'transactions': transactions,
      }, SetOptions(merge: true));
    });
  }

  /// Internal capability: Deduct balance for a purchase.
  /// Note: Usually called within an atomic order transaction.
  Future<void> deductBalance(String userId, double amount, String orderId) async {
    final docRef = _wallets.doc(userId);
    final snapshot = await docRef.get();
    
    if (!snapshot.exists) throw Exception('Wallet does not exist');
    
    final data = snapshot.data() as Map<String, dynamic>;
    final currentBalance = (data['balance'] ?? 0.0).toDouble();
    
    if (currentBalance < amount) throw Exception('Insufficient balance in Obsidian Wallet');
    
    final newTransaction = WalletTransaction(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      amount: amount,
      type: TransactionType.purchase,
      timestamp: DateTime.now(),
      description: 'Order #$orderId',
    );
    
    final transactions = data['transactions'] as List? ?? [];
    transactions.add(newTransaction.toMap());
    
    await docRef.update({
      'balance': currentBalance - amount,
      'transactions': transactions,
    });
  }
}
