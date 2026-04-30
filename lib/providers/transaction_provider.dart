import 'package:flutter/material.dart';
import '../models/transaction_model.dart';
import '../database/hive_database.dart';

// ============================================================
// Transaction Provider — State management for transactions
// ============================================================

class TransactionProvider extends ChangeNotifier {
  final HiveDatabase _db = HiveDatabase();

  List<TransactionModel> _transactions = [];
  List<TransactionModel> _filteredTransactions = [];
  DateTime _selectedMonth = DateTime.now();
  String _searchQuery = '';
  String? _filterCategory;
  String? _filterWallet;
  String? _filterType;

  // Getters
  List<TransactionModel> get transactions =>
      _filteredTransactions.isEmpty && _searchQuery.isEmpty
      ? _transactions
      : _filteredTransactions;
  DateTime get selectedMonth => _selectedMonth;
  String get searchQuery => _searchQuery;

  double get totalIncome => _db.getTotalIncome(month: _selectedMonth);
  double get totalExpense => _db.getTotalExpense(month: _selectedMonth);
  double get totalBalance => _db.getTotalBalance();

  List<TransactionModel> get recentTransactions {
    final all = _db.getAllTransactions();
    return all.take(5).toList();
  }

  // ─────────── Load ───────────

  void loadTransactions() {
    _transactions = _db.getTransactionsByMonth(_selectedMonth);
    _applyFilters();
    notifyListeners();
  }

  void loadAllTransactions() {
    _transactions = _db.getAllTransactions();
    _applyFilters();
    notifyListeners();
  }

  // ─────────── Month Navigation ───────────

  void setMonth(DateTime month) {
    _selectedMonth = month;
    loadTransactions();
  }

  void nextMonth() {
    _selectedMonth = DateTime(_selectedMonth.year, _selectedMonth.month + 1);
    loadTransactions();
  }

  void previousMonth() {
    _selectedMonth = DateTime(_selectedMonth.year, _selectedMonth.month - 1);
    loadTransactions();
  }

  // ─────────── CRUD ───────────

  Future<void> addTransaction(TransactionModel t) async {
    await _db.addTransaction(t);
    loadTransactions();
  }

  Future<void> updateTransaction(
    TransactionModel oldT,
    TransactionModel newT,
  ) async {
    await _db.updateTransaction(oldT, newT);
    loadTransactions();
  }

  Future<void> deleteTransaction(TransactionModel t) async {
    await _db.deleteTransaction(t);
    loadTransactions();
  }

  void clearData() {
    loadTransactions();
    loadAllTransactions();
  }

  // ─────────── Search & Filters ───────────

  void setSearchQuery(String query) {
    _searchQuery = query;
    _applyFilters();
    notifyListeners();
  }

  void setFilterCategory(String? categoryId) {
    _filterCategory = categoryId;
    _applyFilters();
    notifyListeners();
  }

  void setFilterWallet(String? walletId) {
    _filterWallet = walletId;
    _applyFilters();
    notifyListeners();
  }

  void setFilterType(String? type) {
    _filterType = type;
    _applyFilters();
    notifyListeners();
  }

  void clearFilters() {
    _searchQuery = '';
    _filterCategory = null;
    _filterWallet = null;
    _filterType = null;
    _filteredTransactions = [];
    notifyListeners();
  }

  void _applyFilters() {
    var result = List<TransactionModel>.from(_transactions);

    if (_searchQuery.isNotEmpty) {
      result = result
          .where(
            (t) => t.note.toLowerCase().contains(_searchQuery.toLowerCase()),
          )
          .toList();
    }
    if (_filterCategory != null) {
      result = result.where((t) => t.categoryId == _filterCategory).toList();
    }
    if (_filterWallet != null) {
      result = result.where((t) => t.walletId == _filterWallet).toList();
    }
    if (_filterType != null) {
      result = result.where((t) => t.type == _filterType).toList();
    }

    _filteredTransactions = result;
  }

  // ─────────── Analytics ───────────

  Map<String, double> get expenseByCategory =>
      _db.getExpenseByCategory(month: _selectedMonth);

  /// Get monthly totals for past 6 months (for bar chart)
  List<Map<String, dynamic>> getMonthlyTrend() {
    final now = DateTime.now();
    final months = <Map<String, dynamic>>[];

    for (int i = 5; i >= 0; i--) {
      final month = DateTime(now.year, now.month - i);
      months.add({
        'month': month,
        'income': _db.getTotalIncome(month: month),
        'expense': _db.getTotalExpense(month: month),
      });
    }

    return months;
  }
}
