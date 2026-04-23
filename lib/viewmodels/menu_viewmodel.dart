import 'dart:async';
import 'package:flutter/material.dart';
import '../models/menu_item_model.dart';
import '../models/promotion_model.dart';
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import '../services/menu_service.dart';
import '../services/promotion_service.dart';

/// ViewModel for the marketplace Marketplace, managing real-time data flow and filtering.
class MenuViewModel extends ChangeNotifier {
  final MenuService _menuService = MenuService();
  final PromotionService _promotionService = PromotionService();
  final FirebaseStorage _storage = FirebaseStorage.instance;
  
  List<MenuItem> _allItems = [];
  List<MenuItem> get allItems => _allItems;
  List<MenuItem> get items => _allItems;

  List<MenuItem> _filteredItems = [];
  List<MenuItem> get filteredItems => _filteredItems;

  List<PromotionModel> _activePromotions = [];
  List<PromotionModel> get activePromotions => _activePromotions;

  MenuCategory? _selectedCategory;
  MenuCategory? get selectedCategory => _selectedCategory;

  String _searchQuery = '';
  bool _isVegetarianFilter = false;
  bool _isVeganFilter = false;

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

  /// Filters the master item list based on search, category, and dietary state.
  void _applyFiltering() {
    _filteredItems = _allItems.where((item) {
      final matchesCategory = _selectedCategory == null || item.category == _selectedCategory;
      final matchesSearch = _searchQuery.isEmpty || 
          item.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          item.description.toLowerCase().contains(_searchQuery.toLowerCase());
      
      bool matchesDietary = true;
      if (_isVegetarianFilter && !item.isVegetarian) matchesDietary = false;
      if (_isVeganFilter && !item.isVegan) matchesDietary = false;
      
      return matchesCategory && matchesSearch && matchesDietary;
    }).toList();
  }

  /// Search logic for finding items by name or description.
  void searchItems(String query) {
    _searchQuery = query;
    _applyFiltering();
    notifyListeners();
  }

  /// Appied dietary preferences.
  void applyDietaryFilters({required bool isVegetarian, required bool isVegan}) {
    _isVegetarianFilter = isVegetarian;
    _isVeganFilter = isVegan;
    _applyFiltering();
    notifyListeners();
  }

  /// Helper for Hero/Spotlight items (top rated or featured)
  List<MenuItem> get spotlightItems {
    final list = _allItems.where((item) => item.rating >= 4.5).toList();
    return list..sort((a, b) => b.rating.compareTo(a.rating));
  }

  /// Trending items based on sales volume (top 6)
  List<MenuItem> get trendingItems {
    final list = List<MenuItem>.from(_allItems);
    list.sort((a, b) => b.totalOrders.compareTo(a.totalOrders));
    return list.take(6).toList();
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

  /// Uploads a local image file to Firebase Storage and returns the public URL.
  Future<String> uploadImage(File file, String path) async {
    try {
      final ref = _storage.ref().child(path);
      final uploadTask = await ref.putFile(file);
      return await uploadTask.ref.getDownloadURL();
    } catch (e) {
      debugPrint('Error uploading image: $e');
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

  /// Development Tool: Triggers the seeding process.
  Future<void> seedMenu() async {
    _isLoading = true;
    notifyListeners();
    try {
      await _menuService.seedMenu();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _menuSubscription?.cancel();
    _promoSubscription?.cancel();
    super.dispose();
  }
}
