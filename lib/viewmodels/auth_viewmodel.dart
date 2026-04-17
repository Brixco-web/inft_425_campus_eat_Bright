import 'package:flutter/material.dart';
import '../../services/auth_service.dart';
import '../../services/firestore_service.dart';
import '../../models/user_model.dart';

class AuthViewModel extends ChangeNotifier {
  final AuthService _authService = AuthService();
  final FirestoreService _firestoreService = FirestoreService();
  
  UserModel? _currentUser;
  UserModel? get user => _currentUser;
  
  String? get uid => _currentUser?.uid;

  bool _isLoading = false;
  bool get isLoading => _isLoading;
  
  String? _error;
  String? get error => _error;

  // Login
  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      // 1. Initial Authentication
      final credential = await _authService.login(email, password);
      
      if (credential?.user != null) {
        // 2. Gatekeeping Authorization Check
        final authorized = await _authService.isAuthorized(email);
        
        if (!authorized) {
          await _authService.signOut();
          _error = "ACCESS DENIED: Your account is not authorized for the Obsidian Loom. Please use a campus email or request whitelisting.";
          _isLoading = false;
          notifyListeners();
          return false;
        }

        // 3. Profile Sync
        await _authService.syncUserProfile(credential!.user!);
        _currentUser = await _firestoreService.getUser(credential.user!.uid);
      }

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = _handleAuthError(e);
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Register
  Future<bool> register({
    required String email,
    required String password,
    required String displayName,
    required String studentId,
    required String phoneNumber,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      // 1. Create Firebase Account
      final credential = await _authService.register(email, password);
      
      if (credential?.user != null) {
        // 2. Full Profile Creation
        await _authService.createProfile(
          uid: credential!.user!.uid,
          email: email,
          displayName: displayName,
          studentId: studentId,
          phoneNumber: phoneNumber,
        );
        _currentUser = await _firestoreService.getUser(credential.user!.uid);
      }

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = _handleAuthError(e);
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Guest
  Future<bool> signInAsGuest() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      final credential = await _authService.signInAnonymously();
      if (credential?.user != null) {
        await _authService.syncUserProfile(credential!.user!);
      }
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  Future<void> logout() async {
    await _authService.signOut();
    _currentUser = null;
    notifyListeners();
  }

  String _handleAuthError(dynamic e) {
    final message = e.toString().toLowerCase();
    
    // Modern Firebase Auth uses invalid-credential for both wrong password and wrong email to prevent enumeration
    if (message.contains('invalid-credential')) return "ACCESS DENIED: Incorrect email or password.";
    if (message.contains('user-not-found')) return "ACCOUNT ERROR: Identification not found in the system.";
    if (message.contains('wrong-password')) return "ACCESS DENIED: Invalid keyphrase.";
    if (message.contains('invalid-email')) return "ERROR: Invalid identifier format.";
    if (message.contains('network-request-failed')) return "CONNECTION ERROR: Please check your internet connection.";
    if (message.contains('too-many-requests')) return "ACCESS DENIED: Too many failed attempts. Try again later.";
    
    // Fallback: show the actual error so we know what's wrong instead of hiding it
    return "SYSTEM ERROR: ${e.toString()}";
  }
}

