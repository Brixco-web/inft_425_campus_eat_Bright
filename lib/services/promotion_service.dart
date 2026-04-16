import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/promotion_model.dart';

class PromotionService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Collection Reference
  CollectionReference get _promotions => _db.collection('promotions');

  /// Streams active promotions in real-time, sorted by priority.
  Stream<List<PromotionModel>> getActivePromotions() {
    return _promotions
        .where('isActive', isEqualTo: true)
        .orderBy('priority', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => PromotionModel.fromMap(doc.data() as Map<String, dynamic>, doc.id))
          .toList();
    });
  }

  /// Administrator capability: Create or Update a promotion.
  Future<void> savePromotion(PromotionModel promo) async {
    await _promotions.doc(promo.id.isEmpty ? null : promo.id).set(
          promo.toMap(),
          SetOptions(merge: true),
        );
  }

  /// Administrator capability: Toggle promotion status.
  Future<void> setPromotionStatus(String id, bool isActive) async {
    await _promotions.doc(id).update({'isActive': isActive});
  }
}
