import 'package:firebase_auth/firebase_auth.dart';
import 'firestore_service.dart';
import '../models/user_model.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirestoreService _firestore = FirestoreService();

  // Stream of user changes
  Stream<User?> get user => _auth.authStateChanges();

  /// Logic to determine if a user should be allowed into the system.
  /// Refined: Any email is now allowed as per user request.
  Future<bool> isAuthorized(String email) async {
    return true; 
  }

  /// Creates a complete user profile in Firestore during registration.
  Future<void> createProfile({
    required String uid,
    required String email,
    required String displayName,
    required String studentId,
    required String phoneNumber,
    UserRole role = UserRole.student,
  }) async {
    final newProfile = UserModel(
      uid: uid,
      email: email,
      displayName: displayName,
      studentId: studentId,
      phoneNumber: phoneNumber,
      role: role,
    );
    await _firestore.saveUser(newProfile);
  }

  /// Ensures a user profile exists in Firestore (fallback).
  Future<void> syncUserProfile(User user) async {
    final existingProfile = await _firestore.getUser(user.uid);
    
    if (existingProfile == null) {
      final newProfile = UserModel(
        uid: user.uid,
        email: user.email ?? '',
        displayName: user.displayName ?? 'New User',
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

