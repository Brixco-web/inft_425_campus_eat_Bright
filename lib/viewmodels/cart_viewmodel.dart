import 'package:flutter/material.dart';
import '../models/menu_item_model.dart';
import '../services/cart_service.dart';

/// ViewModel for managing cart state, persistence, and total calculations.
class CartViewModel extends ChangeNotifier {
  final CartService _cartService = CartService();
  
  // itemId -> quantity
  Map<String, int> _items = {};
  Map<String, int> get items => _items;

  bool _isLoading = true;
  bool get isLoading => _isLoading;

  CartViewModel() {
    _loadSavedCart();
  }

  /// Loads the cart from Hive on initialization.
  Future<void> _loadSavedCart() async {
    _isLoading = true;
    notifyListeners();
    _items = await _cartService.getSavedCart();
    _isLoading = false;
    notifyListeners();
  }

  /// Adds an item to the cart or increases its quantity.
  void addItem(String itemId) {
    if (_items.containsKey(itemId)) {
      _items[itemId] = _items[itemId]! + 1;
    } else {
      _items[itemId] = 1;
    }
    _cartService.saveCart(_items);
    notifyListeners();
  }

  /// Removes one instance of an item or deletes it if quantity is 1.
  void removeItem(String itemId) {
    if (_items.containsKey(itemId)) {
      if (_items[itemId]! > 1) {
        _items[itemId] = _items[itemId]! - 1;
      } else {
        _items.remove(itemId);
      }
      _cartService.saveCart(_items);
      notifyListeners();
    }
  }

  /// Completely removes an item from the cart regardless of quantity.
  void deleteItem(String itemId) {
    _items.remove(itemId);
    _cartService.saveCart(_items);
    notifyListeners();
  }

  /// Increments quantity of an item.
  void incrementQuantity(String itemId) {
    if (_items.containsKey(itemId)) {
      _items[itemId] = _items[itemId]! + 1;
      _cartService.saveCart(_items);
      notifyListeners();
    }
  }

  /// Decrements quantity of an item, removing it if quantity becomes 0.
  void decrementQuantity(String itemId) {
    if (_items.containsKey(itemId)) {
      if (_items[itemId]! > 1) {
        _items[itemId] = _items[itemId]! - 1;
      } else {
        _items.remove(itemId);
      }
      _cartService.saveCart(_items);
      notifyListeners();
    }
  }

  /// Clears all items from the cart.
  void clearCart() {
    _items.clear();
    _cartService.clearCart();
    notifyListeners();
  }

  /// Calculates total price based on a list of resolved MenuItems.
  double calculateTotal(List<MenuItem> allMenuItems) {
    double total = 0.0;
    _items.forEach((itemId, quantity) {
      final item = allMenuItems.firstWhere(
        (m) => m.id == itemId,
        orElse: () => MenuItem(
          id: '', name: '', description: '', price: 0, imageUrl: '', 
          category: MenuCategory.campusGems
        ),
      );
      total += item.price * quantity;
    });
    return total;
  }

  /// Returns total count of unique items in cart.
  int get itemCount => _items.values.fold(0, (sum, q) => sum + q);

  bool isInCart(String itemId) => _items.containsKey(itemId);
}
