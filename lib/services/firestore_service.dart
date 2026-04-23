import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';

/// Service for managing Firestore-based data, specifically user profiles and whitelists.
class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Collection References
  CollectionReference get _users => _db.collection('users');
  CollectionReference get _whitelist => _db.collection('whitelist');

  /// Saves or updates a user profile in Firestore.
  Future<void> saveUser(UserModel user) async {
    await _users.doc(user.uid).set(user.toMap(), SetOptions(merge: true));
  }

  /// Retrieves a user profile from Firestore.
  Future<UserModel?> getUser(String uid) async {
    final doc = await _users.doc(uid).get();
    if (doc.exists && doc.data() != null) {
      return UserModel.fromMap(doc.data() as Map<String, dynamic>);
    }
    return null;
  }

  /// Checks if an email exists in the manual whitelist collection.
  Future<bool> isWhitelisted(String email) async {
    final query = await _whitelist
        .where('email', isEqualTo: email.toLowerCase())
        .limit(1)
        .get();
    return query.docs.isNotEmpty;
  }

  /// Admin: Search for users by Student ID or Display Name.
  Future<List<UserModel>> searchUsers(String query) async {
    // Note: Firestore doesn't support full-text search without a 3rd party.
    // We'll do a simple match on studentId or paginate/filter locally for small campus size.
    final result = await _users
        .where('studentId', isEqualTo: query)
        .get();
    
    if (result.docs.isNotEmpty) {
      return result.docs.map((doc) => UserModel.fromMap(doc.data() as Map<String, dynamic>)).toList();
    }

    // Fallback: search by display name (requires exact match or startAt/endAt trick)
    final nameResult = await _users
        .where('displayName', isGreaterThanOrEqualTo: query)
        .where('displayName', isLessThanOrEqualTo: '$query\uf8ff')
        .get();
        
    return nameResult.docs.map((doc) => UserModel.fromMap(doc.data() as Map<String, dynamic>)).toList();
  }
}
