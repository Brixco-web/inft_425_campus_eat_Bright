import 'package:flutter/material.dart';
import '../models/wallet_model.dart';
import '../services/wallet_service.dart';

class WalletViewModel extends ChangeNotifier {
  final WalletService _walletService = WalletService();
  
  WalletModel? _wallet;
  WalletModel? get wallet => _wallet;
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
}
