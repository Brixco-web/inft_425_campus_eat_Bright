import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/order_model.dart';

/// The Transaction Engine: Handles high-integrity order placement and verification.
class OrderService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  CollectionReference get _orders => _db.collection('orders');
  CollectionReference get _menu => _db.collection('menu');
  CollectionReference get _wallets => _db.collection('wallets');

  /// Streams orders for a specific user.
  Stream<List<OrderModel>> getUserOrdersStream(String userId) {
    return _orders
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => OrderModel.fromMap(doc.data() as Map<String, dynamic>, doc.id))
          .toList();
    });
  }

  /// Streams all orders for administration.
  Stream<List<OrderModel>> getAllOrdersStream() {
    return _orders
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => OrderModel.fromMap(doc.data() as Map<String, dynamic>, doc.id))
          .toList();
    });
  }

  /// The "Magic Sauce": Atomic Order Placement.
  /// Deducts stock, deducts balance, and creates the order in one atomic step.
  Future<String> placeOrder({
    required String userId,
    required String studentName,
    required List<OrderItem> items,
    required double totalAmount,
    DateTime? pickupTime,
    bool isLectureMode = false,
  }) async {
    final orderId = _orders.doc().id;
    final verificationCode = 'VVU-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}';

    await _db.runTransaction((transaction) async {
      // 1. Verify Wallet Balance
      final walletRef = _wallets.doc(userId);
      final walletSnap = await transaction.get(walletRef);
      if (!walletSnap.exists) throw Exception('Obsidian Wallet not initialized.');
      
      final currentBalance = (walletSnap.data() as Map<String, dynamic>)['balance'] ?? 0.0;
      if (currentBalance < totalAmount) {
        throw Exception('Insufficient funds in Obsidian Wallet. Please visit cafeteria admin for advance payment.');
      }

      // 2. Verify and Deduct Stock for each item
      for (var item in items) {
        final itemRef = _menu.doc(item.itemId);
        final itemSnap = await transaction.get(itemRef);
        
        if (!itemSnap.exists) throw Exception('Item ${item.name} is no longer available.');
        
        final currentStock = (itemSnap.data() as Map<String, dynamic>)['stockCount'] ?? 0;
        if (currentStock < item.quantity) {
          throw Exception('Not enough stock for ${item.name}. Only $currentStock left.');
        }

        // Deduct Stock
        transaction.update(itemRef, {'stockCount': currentStock - item.quantity});
      }

      // 3. Deduct Wallet Balance & Add Transaction
      final walletData = walletSnap.data() as Map<String, dynamic>;
      final transactions = walletData['transactions'] as List? ?? [];
      
      transactions.add({
        'id': 'TRX-$orderId',
        'amount': totalAmount,
        'type': 'purchase',
        'timestamp': Timestamp.now(),
        'description': 'Ordered ${items.length} items',
      });

      transaction.update(walletRef, {
        'balance': currentBalance - totalAmount,
        'transactions': transactions,
      });

      // 4. Create Order
      final order = OrderModel(
        id: orderId,
        userId: userId,
        studentName: studentName,
        items: items,
        totalAmount: totalAmount,
        createdAt: DateTime.now(),
        pickupTime: pickupTime,
        isLectureMode: isLectureMode,
        verificationCode: verificationCode,
      );

      transaction.set(_orders.doc(orderId), order.toMap());
    });

    return orderId;
  }

  /// Admin capability: Mark order as ready for pickup.
  Future<void> markOrderReady(String orderId) async {
    await _orders.doc(orderId).update({'status': 'ready'});
  }

  /// Admin capability: Verify QR and mark order as collected.
  /// This is the final step in the order lifecycle.
  Future<void> completeOrderHandshake(String orderId, String verificationCode) async {
    final doc = await _orders.doc(orderId).get();
    if (!doc.exists) throw Exception('Order not found');
    
    final order = OrderModel.fromMap(doc.data() as Map<String, dynamic>, doc.id);
    if (order.verificationCode != verificationCode) {
      throw Exception('Invalid verification code. Handshake failed.');
    }

    if (order.status != OrderStatus.ready) {
      throw Exception('Order is not marked as READY yet.');
    }

    await _orders.doc(orderId).update({'status': 'collected'});
  }
}
