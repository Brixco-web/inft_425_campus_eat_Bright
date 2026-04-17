import 'package:cloud_firestore/cloud_firestore.dart';

enum OrderStatus { pending, ready, collected, cancelled }

class OrderModel {
  final String id;
  final String userId;
  final String studentName;
  final List<OrderItem> items;
  final double totalAmount;
  final OrderStatus status;
  final DateTime createdAt;
  final DateTime? pickupTime;
  final bool isLectureMode;
  final String verificationCode;

  OrderModel({
    required this.id,
    required this.userId,
    required this.studentName,
    required this.items,
    required this.totalAmount,
    this.status = OrderStatus.pending,
    required this.createdAt,
    this.pickupTime,
    this.isLectureMode = false,
    required this.verificationCode,
  });

  factory OrderModel.fromMap(Map<String, dynamic> data, String documentId) {
    return OrderModel(
      id: documentId,
      userId: data['userId'] ?? '',
      studentName: data['studentName'] ?? '',
      items: (data['items'] as List? ?? [])
          .map((item) => OrderItem.fromMap(item))
          .toList(),
      totalAmount: (data['totalAmount'] ?? 0.0).toDouble(),
      status: OrderStatus.values.firstWhere(
        (e) => e.name == data['status'],
        orElse: () => OrderStatus.pending,
      ),
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      pickupTime: data['pickupTime'] != null
          ? (data['pickupTime'] as Timestamp).toDate()
          : null,
      isLectureMode: data['isLectureMode'] ?? false,
      verificationCode: data['verificationCode'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'studentName': studentName,
      'items': items.map((item) => item.toMap()).toList(),
      'totalAmount': totalAmount,
      'status': status.name,
      'createdAt': Timestamp.fromDate(createdAt),
      'pickupTime': pickupTime != null ? Timestamp.fromDate(pickupTime!) : null,
      'isLectureMode': isLectureMode,
      'verificationCode': verificationCode,
    };
  }
}

class OrderItem {
  final String itemId;
  final String name;
  final int quantity;
  final double price;

  OrderItem({
    required this.itemId,
    required this.name,
    required this.quantity,
    required this.price,
  });

  factory OrderItem.fromMap(Map<String, dynamic> data) {
    return OrderItem(
      itemId: data['itemId'] ?? '',
      name: data['name'] ?? '',
      quantity: data['quantity'] ?? 0,
      price: (data['price'] ?? 0.0).toDouble(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'itemId': itemId,
      'name': name,
      'quantity': quantity,
      'price': price,
    };
  }
}
