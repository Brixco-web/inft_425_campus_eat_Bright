import 'dart:async';
import 'package:flutter/material.dart';
import '../models/menu_item_model.dart';
import '../models/promotion_model.dart';
import '../services/menu_service.dart';
import '../services/promotion_service.dart';

/// ViewModel for the marketplace Marketplace, managing real-time data flow and filtering.
class MenuViewModel extends ChangeNotifier {
  final MenuService _menuService = MenuService();
  final PromotionService _promotionService = PromotionService();
  
  List<MenuItem> _allItems = [];
  List<MenuItem> get allItems => _allItems;
  List<MenuItem> get items => _allItems;

  List<MenuItem> _filteredItems = [];
  List<MenuItem> get filteredItems => _filteredItems;

  List<PromotionModel> _activePromotions = [];
  List<PromotionModel> get activePromotions => _activePromotions;

  MenuCategory? _selectedCategory;
  MenuCategory? get selectedCategory => _selectedCategory;

  bool _isLoading = true;
  bool get isLoading => _isLoading;

  StreamSubscription<List<MenuItem>>? _menuSubscription;
  StreamSubscription<List<PromotionModel>>? _promoSubscription;

  MenuViewModel() {
    _initMenuStream();
  }

  /// Initializes the real-time listener for menu items.
  void _initMenuStream() {
    _isLoading = true;
    notifyListeners();

    _menuSubscription?.cancel();
    _menuSubscription = _menuService.getMenuItemsStream().listen((items) {
      _allItems = items;
      _applyFiltering();
      _isLoading = false;
      notifyListeners();
    });

    _promoSubscription?.cancel();
    _promoSubscription = _promotionService.getActivePromotions().listen((promos) {
      _activePromotions = promos;
      notifyListeners();
    });
  }

  /// Sets the active category filter and updates the filtered list.
  void setCategory(MenuCategory? category) {
    if (_selectedCategory == category) {
      _selectedCategory = null; // Toggle off
    } else {
      _selectedCategory = category;
    }
    _applyFiltering();
    notifyListeners();
  }

  /// Filters the master item list based on search and category state.
  void _applyFiltering() {
    if (_selectedCategory == null) {
      _filteredItems = List.from(_allItems);
    } else {
      _filteredItems = _allItems
          .where((item) => item.category == _selectedCategory)
          .toList();
    }
  }

  /// Search logic for finding items by name or description.
  void searchItems(String query) {
    if (query.isEmpty) {
      _applyFiltering();
    } else {
      _filteredItems = _allItems
          .where((item) =>
              item.name.toLowerCase().contains(query.toLowerCase()) ||
              item.description.toLowerCase().contains(query.toLowerCase()))
          .toList();
      
      // Also apply category filter if active
      if (_selectedCategory != null) {
        _filteredItems = _filteredItems
            .where((item) => item.category == _selectedCategory)
            .toList();
      }
    }
    notifyListeners();
  }

  /// Helper for Hero/Spotlight items (top rated or featured)
  List<MenuItem> get spotlightItems {
    final list = _allItems.where((item) => item.rating >= 4.5).toList();
    return list..sort((a, b) => b.rating.compareTo(a.rating));
  }

  // --- Administrative Methods ---

  /// Adds or updates a menu item in Firestore.
  Future<void> saveMenuItem(MenuItem item) async {
    try {
      await _menuService.saveMenuItem(item);
    } catch (e) {
      debugPrint('Error saving menu item: $e');
      rethrow;
    }
  }

  /// Removes a menu item from the catalog.
  Future<void> deleteMenuItem(String id) async {
    try {
      await _menuService.deleteMenuItem(id);
    } catch (e) {
      debugPrint('Error deleting menu item: $e');
      rethrow;
    }
  }

  /// Adds or updates a promotion flier.
  Future<void> savePromotion(PromotionModel promo) async {
    try {
      await _promotionService.savePromotion(promo);
    } catch (e) {
      debugPrint('Error saving promotion: $e');
      rethrow;
    }
  }

  /// Removes a promotion flier.
  Future<void> deletePromotion(String id) async {
    try {
      await _promotionService.deletePromotion(id);
    } catch (e) {
      debugPrint('Error deleting promotion: $e');
      rethrow;
    }
  }

  @override
  void dispose() {
    _menuSubscription?.cancel();
    _promoSubscription?.cancel();
    super.dispose();
  }
}
