import 'package:firebase_auth/firebase_auth.dart';
import 'firestore_service.dart';
import '../models/user_model.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirestoreService _firestore = FirestoreService();

  // Stream of user changes
  Stream<User?> get user => _auth.authStateChanges();

  /// Logic to determine if a user should be allowed into the system.
  Future<bool> isAuthorized(String email) async {
    // 1. Check for official campus domain
    if (email.toLowerCase().endsWith('@vvu.edu.gh')) {
      return true;
    }
    
    // 2. Check for manual whitelist override (for admins/contractors)
    return await _firestore.isWhitelisted(email);
  }

  /// Ensures a user profile exists in Firestore.
  Future<void> syncUserProfile(User user) async {
    final existingProfile = await _firestore.getUser(user.uid);
    
    if (existingProfile == null) {
      // Create new profile
      final newProfile = UserModel(
        uid: user.uid,
        email: user.email ?? '',
        role: user.isAnonymous ? UserRole.guest : UserRole.student,
      );
      await _firestore.saveUser(newProfile);
    }
  }

  // Register with Email & Password
  Future<UserCredential?> register(String email, String password) async {
    try {
      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      return result;
    } catch (e) {
      rethrow;
    }
  }

  // Login with Email & Password
  Future<UserCredential?> login(String email, String password) async {
    try {
      return await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } catch (e) {
      rethrow;
    }
  }

  // Guest Login 
  Future<UserCredential?> signInAnonymously() async {
    try {
      return await _auth.signInAnonymously();
    } catch (e) {
      rethrow;
    }
  }

  // Sign out
  Future<void> signOut() async {
    await _auth.signOut();
  }
}

