import 'package:flutter/material.dart';
import '../../services/auth_service.dart';
import '../../models/user_model.dart';

class AuthViewModel extends ChangeNotifier {
  final AuthService _authService = AuthService();
  
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

  String _handleAuthError(dynamic e) {
    final message = e.toString().toLowerCase();
    if (message.contains('user-not-found')) return "ACCOUNT ERROR: Identification not found in the Loom.";
    if (message.contains('wrong-password')) return "ACCESS DENIED: Invalid keyphrase.";
    if (message.contains('invalid-email')) return "ERROR: Invalid identifier format.";
    return "SYSTEM ERROR: A distortion in the Loom occurred. Please try again.";
  }
}

