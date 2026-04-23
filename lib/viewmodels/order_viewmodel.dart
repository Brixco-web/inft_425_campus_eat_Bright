import 'package:flutter/material.dart';
import '../models/order_model.dart';
import '../services/order_service.dart';

/// ViewModel for managing order history and the placement of new orders.
class OrderViewModel extends ChangeNotifier {
  final OrderService _orderService = OrderService();
  
  List<OrderModel> _orders = [];
  List<OrderModel> get orders => _orders;

  List<OrderModel> get activeOrders => _orders.where((o) => o.status != OrderStatus.collected && o.status != OrderStatus.cancelled).toList();
  bool get hasActiveOrder => activeOrders.isNotEmpty;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  /// Fetches and listens to real-time order updates for a user.
  void listenToOrders(String userId) {
    _isLoading = true;
    notifyListeners();

    _orderService.getUserOrdersStream(userId).listen((newOrders) {
      _orders = newOrders;
      _isLoading = false;
      notifyListeners();
    }, onError: (error) {
      _errorMessage = error.toString();
      _isLoading = false;
      notifyListeners();
    });
  }

  /// Places a new order using the atomic transaction engine.
  Future<bool> placeOrder({
    required String userId,
    required String studentName,
    required List<OrderItem> items,
    required double totalAmount,
    DateTime? pickupTime,
    bool isLectureMode = false,
    PaymentMethod paymentMethod = PaymentMethod.wallet,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _orderService.placeOrder(
        userId: userId,
        studentName: studentName,
        items: items,
        totalAmount: totalAmount,
        pickupTime: pickupTime,
        isLectureMode: isLectureMode,
        paymentMethod: paymentMethod,
      );
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Updates the rating for a collected order.
  Future<void> rateOrder(String orderId, double rating) async {
    try {
      await _orderService.updateOrderRating(orderId, rating);
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
