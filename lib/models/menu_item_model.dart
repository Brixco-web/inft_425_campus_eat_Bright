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
  final bool isPromoted;
  final List<MenuOption> options;
  final int totalOrders;
  final bool isVegetarian;
  final bool isVegan;

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
    this.isPromoted = false,
    this.options = const [],
    this.totalOrders = 0,
    this.isVegetarian = false,
    this.isVegan = false,
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
      isPromoted: data['isPromoted'] ?? false,
      options: opts,
      totalOrders: data['totalOrders'] ?? 0,
      isVegetarian: data['isVegetarian'] ?? false,
      isVegan: data['isVegan'] ?? false,
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
      'isPromoted': isPromoted,
      'options': options.map((e) => e.toMap()).toList(),
      'totalOrders': totalOrders,
      'isVegetarian': isVegetarian,
      'isVegan': isVegan,
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

  /// Creates a copy of this MenuItem with the given fields replaced.
  MenuItem copyWith({
    String? id,
    String? name,
    String? description,
    double? price,
    String? imageUrl,
    MenuCategory? category,
    List<String>? ingredients,
    List<String>? allergens,
    bool? isAvailable,
    double? rating,
    int? reviewCount,
    int? stockCount,
    bool? isTrending,
    bool? isPromoted,
    int? prepTime,
    List<MenuOption>? options,
    int? totalOrders,
    bool? isVegetarian,
    bool? isVegan,
  }) {
    return MenuItem(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      price: price ?? this.price,
      imageUrl: imageUrl ?? this.imageUrl,
      category: category ?? this.category,
      ingredients: ingredients ?? this.ingredients,
      allergens: allergens ?? this.allergens,
      isAvailable: isAvailable ?? this.isAvailable,
      rating: rating ?? this.rating,
      reviewCount: reviewCount ?? this.reviewCount,
      stockCount: stockCount ?? this.stockCount,
      isTrending: isTrending ?? this.isTrending,
      isPromoted: isPromoted ?? this.isPromoted,
      prepTime: prepTime ?? this.prepTime,
      options: options ?? this.options,
      totalOrders: totalOrders ?? this.totalOrders,
      isVegetarian: isVegetarian ?? this.isVegetarian,
      isVegan: isVegan ?? this.isVegan,
    );
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

  MenuOption copyWith({
    String? name,
    double? price,
    bool? isDefault,
  }) {
    return MenuOption(
      name: name ?? this.name,
      price: price ?? this.price,
      isDefault: isDefault ?? this.isDefault,
    );
  }
}
