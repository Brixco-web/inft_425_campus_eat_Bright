import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/menu_item_model.dart';

/// Service for managing the "Obsidian Loom" Marketplace menu.
class MenuService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Collection Reference
  CollectionReference get _menu => _db.collection('menu');

  /// Streams the entire menu in real-time.
  Stream<List<MenuItem>> getMenuItemsStream() {
    return _menu.snapshots().map((snapshot) {
      return snapshot.docs
          .map((doc) => MenuItem.fromMap(doc.data() as Map<String, dynamic>, doc.id))
          .toList();
    });
  }

  /// Streams items belonging to a specific category.
  Stream<List<MenuItem>> getItemsByCategoryStream(MenuCategory category) {
    return _menu
        .where('category', isEqualTo: category.name)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => MenuItem.fromMap(doc.data() as Map<String, dynamic>, doc.id))
          .toList();
    });
  }

  /// Administrator capability: Update item availability toggle.
  Future<void> updateItemAvailability(String id, bool available) async {
    await _menu.doc(id).update({'isAvailable': available});
  }

  /// Administrator capability: Update or Create a Menu Item.
  Future<void> saveMenuItem(MenuItem item) async {
    await _menu.doc(item.id.isEmpty ? null : item.id).set(
          item.toMap(),
          SetOptions(merge: true),
        );
  }

  /// Administrator capability: Deletes a menu item.
  Future<void> deleteMenuItem(String id) async {
    await _menu.doc(id).delete();
  }
}

  /// Administrator capability: Deletes a menu item.
  Future<void> deleteMenuItem(String id) async {
    await _menu.doc(id).delete();
  }
}
