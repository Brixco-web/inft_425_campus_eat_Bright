import 'package:flutter/material.dart';
import '../models/wallet_model.dart';
import '../models/user_model.dart';
import '../services/wallet_service.dart';
import '../services/firestore_service.dart';

class WalletViewModel extends ChangeNotifier {
  final WalletService _walletService = WalletService();
  final FirestoreService _firestoreService = FirestoreService();
  
  WalletModel? _wallet;
  WalletModel? get wallet => _wallet;
  bool get isRegistered => _wallet != null;
  double get balance => _wallet?.balance ?? 0.0;
  List<WalletTransaction> get transactions => _wallet?.transactions ?? [];

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  void listenToWallet(String userId) {
    _isLoading = true;
    notifyListeners();

    _walletService.getWalletStream(userId).listen((newWallet) {
      _wallet = newWallet;
      _isLoading = false;
      notifyListeners();
    }, onError: (e) {
      _isLoading = false;
      notifyListeners();
    });
  }

  Future<void> topUp(String userId, double amount, String adminId) async {
    _isLoading = true;
    notifyListeners();
    try {
      await _walletService.topUpBalance(userId, amount, adminId);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> processTransaction({
    required String title,
    required double amount,
    required TransactionType type,
  }) async {
    if (_wallet == null) return;
    
    _isLoading = true;
    notifyListeners();
    try {
      if (type == TransactionType.purchase) {
        // Use title as orderId for now or extend service
        await _walletService.deductBalance(_wallet!.userId, amount, title);
      } else {
        // Handle other types if needed
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> manuallyOnboardStudent({
    required String displayName,
    required String studentId,
    required String email,
    required double initialBalance,
  }) async {
    _isLoading = true;
    notifyListeners();
    try {
      // Create a unique identifier for manual entries
      final uid = 'MANUAL_${studentId.replaceAll(' ', '_')}_${DateTime.now().millisecondsSinceEpoch}';
      
      final newUser = UserModel(
        uid: uid,
        email: email.isEmpty ? '$studentId@vvu.placeholder.com' : email,
        displayName: displayName,
        studentId: studentId,
        role: UserRole.student,
      );
      
      await _firestoreService.saveUser(newUser);
      
      // Initialize wallet with balance
      if (initialBalance >= 0) {
        await _walletService.topUpBalance(uid, initialBalance, 'ADMIN_ONBOARD');
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
