import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../models/menu_item_model.dart';

/// Service for managing the "Obsidian Loom" Marketplace menu.
class MenuService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

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

  /// Administrator capability: Upload or Replace an image in Firebase Storage.
  /// Returns the download URL of the uploaded image.
  Future<String> uploadItemImage(String itemId, Uint8List imageBytes) async {
    final storageRef = _storage.ref().child('menu_images/$itemId.jpg');
    
    // Upload bytes
    final uploadTask = await storageRef.putData(
      imageBytes,
      SettableMetadata(contentType: 'image/jpeg'),
    );
    
    // Get and return download URL
    return await uploadTask.ref.getDownloadURL();
  }

  /// Administrator capability: Deletes a menu item.
  Future<void> deleteMenuItem(String id) async {
    await _menu.doc(id).delete();
  }
}
