import 'package:firebase_auth/firebase_auth.dart';
// Firestore and UserModel will be used in Commit 2


class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  // final FirebaseFirestore _db = FirebaseFirestore.instance; // To be used in Commit 2


  // Stream of user changes
  Stream<User?> get user => _auth.authStateChanges();

  // Register with Email & Password
  Future<UserCredential?> register(String email, String password) async {
    try {
      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      // Initial user data creation in Firestore will happen in Commit 2 (Whitelist Logic)
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

  // Verification helper for @vvu.edu.gh hint
  bool isVVUEmail(String email) {
    return email.toLowerCase().endsWith('@vvu.edu.gh');
  }
}
