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
  final int prepTime;
  final List<MenuOption> options;

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
    this.options = const [],
  });

  factory MenuItem.fromMap(Map<String, dynamic> data, String documentId) {
    var opts = (data['options'] as List?)?.map((o) => MenuOption.fromMap(o)).toList() ?? [];
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
      options: opts,
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
      'options': options.map((e) => e.toMap()).toList(),
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

class MenuOption {
  final String name;
  final double price;
  final bool isDefault;

  MenuOption({required this.name, required this.price, this.isDefault = false});

  factory MenuOption.fromMap(Map<String, dynamic> map) {
    return MenuOption(
      name: map['name'] ?? '',
      price: (map['price'] ?? 0.0).toDouble(),
      isDefault: map['isDefault'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'price': price,
      'isDefault': isDefault,
    };
  }
}
