enum MenuCategory {
  campusGems,
  localDelights,
  quickBites,
  continental,
  drinks
}

class MenuItem {
  final String id;
  final String name;
  final String description;
  final double price;
  final String imageUrl;
  final MenuCategory category;
  final List<String> ingredients;
  final List<String> allergens;
  final bool isAvailable;
  final double rating;
  final int reviewCount;
  final int stockCount;
  final bool isTrending;

  MenuItem({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.imageUrl,
    required this.category,
    this.ingredients = const [],
    this.allergens = const [],
    this.isAvailable = true,
    this.prepTime = 15,
    this.rating = 0.0,
    this.reviewCount = 0,
    this.stockCount = 10,
    this.isTrending = false,
  });

  factory MenuItem.fromMap(Map<String, dynamic> data, String documentId) {
    return MenuItem(
      id: documentId,
      name: data['name'] ?? '',
      description: data['description'] ?? '',
      price: (data['price'] ?? 0.0).toDouble(),
      imageUrl: data['imageUrl'] ?? '',
      category: _parseCategory(data['category']),
      ingredients: List<String>.from(data['ingredients'] ?? []),
      allergens: List<String>.from(data['allergens'] ?? []),
      isAvailable: data['isAvailable'] ?? true,
      prepTime: data['prepTime'] ?? 15,
      rating: (data['rating'] ?? 0.0).toDouble(),
      reviewCount: data['reviewCount'] ?? 0,
      stockCount: data['stockCount'] ?? 10,
      isTrending: data['isTrending'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'description': description,
      'price': price,
      'imageUrl': imageUrl,
      'category': category.name,
      'ingredients': ingredients,
      'allergens': allergens,
      'isAvailable': isAvailable,
      'prepTime': prepTime,
      'rating': rating,
      'reviewCount': reviewCount,
      'stockCount': stockCount,
      'isTrending': isTrending,
    };
  }

  static MenuCategory _parseCategory(String? categoryStr) {
    switch (categoryStr) {
      case 'localDelights':
        return MenuCategory.localDelights;
      case 'quickBites':
        return MenuCategory.quickBites;
      case 'continental':
        return MenuCategory.continental;
      case 'drinks':
        return MenuCategory.drinks;
      default:
        return MenuCategory.campusGems;
    }
  }

  /// Helper to get a display string for the category
  String get categoryDisplay {
    switch (category) {
      case MenuCategory.campusGems:
        return 'Campus Gems';
      case MenuCategory.localDelights:
        return 'Local Delights';
      case MenuCategory.quickBites:
        return 'Quick Bites';
      case MenuCategory.continental:
        return 'Continental';
      case MenuCategory.drinks:
        return 'Drinks';
    }
  }
}
