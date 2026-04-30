import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/budget_model.dart';
import '../database/hive_database.dart';
import '../services/notification_service.dart';

// ============================================================
// Budget Provider — State management for budgets
// ============================================================

class BudgetProvider extends ChangeNotifier {
  final HiveDatabase _db = HiveDatabase();
  final NotificationService _notif = NotificationService();

  List<BudgetModel> _budgets = [];
  String _selectedMonth = DateFormat('yyyy-MM').format(DateTime.now());

  List<BudgetModel> get budgets => _budgets;
  String get selectedMonth => _selectedMonth;

  void loadBudgets() {
    _budgets = _db.getBudgetsByMonth(_selectedMonth);
    _checkBudgetAlerts();
    notifyListeners();
  }

  void setMonth(String month) {
    _selectedMonth = month;
    loadBudgets();
  }

  Future<void> addBudget(BudgetModel b) async {
    await _db.addBudget(b);
    loadBudgets();
  }

  Future<void> updateBudget(BudgetModel b) async {
    await _db.updateBudget(b);
    loadBudgets();
  }

  Future<void> deleteBudget(String id) async {
    await _db.deleteBudget(id);
    loadBudgets();
  }

  void clearData() {
    loadBudgets();
  }

  /// Check budgets and send alerts for exceeded ones
  void _checkBudgetAlerts() {
    for (final budget in _budgets) {
      if (budget.isOverBudget) {
        final category = _db.getCategoryById(budget.categoryId);
        if (category != null) {
          _notif.showBudgetAlert(
            category.name,
            budget.spentAmount,
            budget.budgetAmount,
          );
        }
      }
    }
  }

  /// Get overall budget progress
  double get overallProgress {
    if (_budgets.isEmpty) return 0;
    final totalBudget = _budgets.fold<double>(0, (s, b) => s + b.budgetAmount);
    final totalSpent = _budgets.fold<double>(0, (s, b) => s + b.spentAmount);
    return totalBudget > 0 ? (totalSpent / totalBudget).clamp(0, 1) : 0;
  }
}
