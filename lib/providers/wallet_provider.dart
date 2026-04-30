import 'package:flutter/material.dart';
import '../models/wallet_model.dart';
import '../database/hive_database.dart';

// ============================================================
// Wallet Provider — State management for wallets
// ============================================================

class WalletProvider extends ChangeNotifier {
  final HiveDatabase _db = HiveDatabase();

  List<WalletModel> _wallets = [];

  List<WalletModel> get wallets => _wallets;

  double get totalBalance =>
      _wallets.fold<double>(0, (sum, w) => sum + w.balance);

  void loadWallets() {
    _wallets = _db.getAllWallets();
    notifyListeners();
  }

  WalletModel? getWalletById(String id) => _db.getWalletById(id);

  Future<void> addWallet(WalletModel w) async {
    await _db.addWallet(w);
    loadWallets();
  }

  Future<void> updateWallet(WalletModel w) async {
    await _db.updateWallet(w);
    loadWallets();
  }

  Future<void> deleteWallet(String id) async {
    await _db.deleteWallet(id);
    loadWallets();
  }

  void clearData() {
    loadWallets();
  }
}
