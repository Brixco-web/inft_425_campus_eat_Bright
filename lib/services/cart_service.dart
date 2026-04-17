import 'package:hive_flutter/hive_flutter.dart';

/// Service for managing persistent cart state using Hive.
/// This ensures orders survive app restarts and allows for an offline queue.
class CartService {
  static const String _boxName = 'cart_box';

  Future<Box> _getBox() async {
    return await Hive.openBox(_boxName);
  }

  /// Saves the current cart list to Hive.
  Future<void> saveCart(Map<String, int> cartItems) async {
    final box = await _getBox();
    await box.put('current_cart', cartItems);
  }

  /// Retrieves the saved cart from Hive. 
  /// Returns a Map of itemId -> quantity.
  Future<Map<String, int>> getSavedCart() async {
    final box = await _getBox();
    final data = box.get('current_cart');
    if (data != null) {
      return Map<String, int>.from(data);
    }
    return {};
  }

  /// Clears the persistent cart storage.
  Future<void> clearCart() async {
    final box = await _getBox();
    await box.delete('current_cart');
  }
}
