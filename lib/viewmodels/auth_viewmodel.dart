import 'package:flutter/material.dart';
import 'package:local_auth/local_auth.dart';
import '../../services/auth_service.dart';
import '../../services/firestore_service.dart';
import '../../services/local_storage_service.dart';
import '../../models/user_model.dart';

class AuthViewModel extends ChangeNotifier {
  final AuthService _authService = AuthService();
  final FirestoreService _firestoreService = FirestoreService();
  final LocalStorageService _storageService = LocalStorageService();
  final LocalAuthentication _localAuth = LocalAuthentication();
  
  UserModel? _currentUser;
  UserModel? get user => _currentUser;
  
  String? get uid => _currentUser?.uid;

  bool _isLoading = false;
  bool get isLoading => _isLoading;
  
  String? _error;
  String? get error => _error;

  bool _isBiometricAvailable = false;
  bool get isBiometricAvailable => _isBiometricAvailable;

  bool get useBiometrics => _storageService.useBiometrics;
  set useBiometrics(bool value) {
    _storageService.useBiometrics = value;
    notifyListeners();
  }

  bool get stayLoggedIn => _storageService.stayLoggedIn;
  set stayLoggedIn(bool value) {
    _storageService.stayLoggedIn = value;
    notifyListeners();
  }

  AuthViewModel() {
    _init();
  }

  Future<void> _init() async {
    await _storageService.init();
    _isBiometricAvailable = await _localAuth.canCheckBiometrics || await _localAuth.isDeviceSupported();
    notifyListeners();
  }

  // Biometric Auth
  Future<bool> authenticateWithBiometrics() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final authenticated = await _localAuth.authenticate(
        localizedReason: 'Please authenticate to unlock Campus Eats',
        options: const AuthenticationOptions(
          stickyAuth: true,
          biometricOnly: true,
        ),
      );

      if (authenticated) {
        // Since Firebase keeps the session, we just check if it's still alive
        if (_authService.currentUser != null) {
          _currentUser = await _firestoreService.getUser(_authService.currentUser!.uid);
          _isLoading = false;
          notifyListeners();
          return true;
        } else {
          _error = "Session expired. Please log in again.";
        }
      }
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _error = "Biometric authentication failed: ${e.toString()}";
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Login
  Future<bool> login(String email, String password, {bool stayLoggedIn = false}) async {
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

        // 4. Persistence Preferences
        _storageService.stayLoggedIn = stayLoggedIn;
        if (stayLoggedIn) {
          _storageService.useBiometrics = true; // Enable by default if staying logged in
        }
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
    await _storageService.clearSettings();
    _currentUser = null;
    notifyListeners();
  }

  // Auto Login / Biometric Check on Launch
  Future<bool> checkInitialAuth() async {
    if (_authService.currentUser != null && _storageService.stayLoggedIn) {
      if (_storageService.useBiometrics && _isBiometricAvailable) {
        // Return false to indicate biometric unlock is required
        return false;
      }
      // Auto-fetch profile if staying logged in but biometrics not needed/available
      _currentUser = await _firestoreService.getUser(_authService.currentUser!.uid);
      return true;
    }
    return false;
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

