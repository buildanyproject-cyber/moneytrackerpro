import 'package:hive_flutter/hive_flutter.dart';
import 'package:uuid/uuid.dart';
import '../core/constants.dart';
import '../models/transaction_model.dart';
import '../models/category_model.dart';
import '../models/wallet_model.dart';
import '../models/budget_model.dart';
import '../models/reminder_model.dart';
import '../models/goal_model.dart';

// ============================================================
// Hive Database Service — Single source of truth for local data
// ============================================================

class HiveDatabase {
  static final HiveDatabase _instance = HiveDatabase._internal();
  factory HiveDatabase() => _instance;
  HiveDatabase._internal();

  static const _uuid = Uuid();

  // Boxes
  late Box<TransactionModel> _transactionBox;
  late Box<CategoryModel> _categoryBox;
  late Box<WalletModel> _walletBox;
  late Box<BudgetModel> _budgetBox;
  late Box<ReminderModel> _reminderBox;
  late Box<GoalModel> _goalBox;
  late Box _settingsBox;

  // ─────────── Initialization ───────────

  Future<void> init() async {
    await Hive.initFlutter();

    // Register adapters
    Hive.registerAdapter(TransactionModelAdapter());
    Hive.registerAdapter(CategoryModelAdapter());
    Hive.registerAdapter(WalletModelAdapter());
    Hive.registerAdapter(BudgetModelAdapter());
    Hive.registerAdapter(ReminderModelAdapter());
    Hive.registerAdapter(GoalModelAdapter());

    // Open boxes
    _transactionBox = await Hive.openBox<TransactionModel>(
      AppConstants.transactionBox,
    );
    _categoryBox = await Hive.openBox<CategoryModel>(AppConstants.categoryBox);
    _walletBox = await Hive.openBox<WalletModel>(AppConstants.walletBox);
    _budgetBox = await Hive.openBox<BudgetModel>(AppConstants.budgetBox);
    _reminderBox = await Hive.openBox<ReminderModel>(AppConstants.reminderBox);
    _goalBox = await Hive.openBox<GoalModel>(AppConstants.goalBox);
    _settingsBox = await Hive.openBox(AppConstants.settingsBox);

    // Seed default data on first launch
    await _seedDefaults();
  }

  /// Generate a unique ID
  static String generateId() => _uuid.v4();

  // ─────────── Default Data Seeding ───────────

  Future<void> _seedDefaults() async {
    if (_categoryBox.isEmpty) {
      final defaults = [
        // Expense categories
        CategoryModel(
          id: generateId(),
          name: 'Food & Dining',
          icon: 'food',
          color: '#E17055',
          type: 'expense',
        ),
        CategoryModel(
          id: generateId(),
          name: 'Transport',
          icon: 'transport',
          color: '#0984E3',
          type: 'expense',
        ),
        CategoryModel(
          id: generateId(),
          name: 'Shopping',
          icon: 'shopping',
          color: '#6C5CE7',
          type: 'expense',
        ),
        CategoryModel(
          id: generateId(),
          name: 'Entertainment',
          icon: 'entertainment',
          color: '#E84393',
          type: 'expense',
        ),
        CategoryModel(
          id: generateId(),
          name: 'Health',
          icon: 'health',
          color: '#00B894',
          type: 'expense',
        ),
        CategoryModel(
          id: generateId(),
          name: 'Education',
          icon: 'education',
          color: '#FDAA5E',
          type: 'expense',
        ),
        CategoryModel(
          id: generateId(),
          name: 'Bills & Utilities',
          icon: 'bills',
          color: '#FF7675',
          type: 'expense',
        ),
        CategoryModel(
          id: generateId(),
          name: 'Groceries',
          icon: 'groceries',
          color: '#00CEC9',
          type: 'expense',
        ),
        CategoryModel(
          id: generateId(),
          name: 'Rent',
          icon: 'rent',
          color: '#C44569',
          type: 'expense',
        ),
        CategoryModel(
          id: generateId(),
          name: 'Subscriptions',
          icon: 'subscription',
          color: '#778BEB',
          type: 'expense',
        ),
        CategoryModel(
          id: generateId(),
          name: 'Travel',
          icon: 'travel',
          color: '#3DC1D3',
          type: 'expense',
        ),
        CategoryModel(
          id: generateId(),
          name: 'Other',
          icon: 'other',
          color: '#636E72',
          type: 'expense',
        ),
        // Income categories
        CategoryModel(
          id: generateId(),
          name: 'Salary',
          icon: 'salary',
          color: '#00B894',
          type: 'income',
        ),
        CategoryModel(
          id: generateId(),
          name: 'Freelance',
          icon: 'freelance',
          color: '#0984E3',
          type: 'income',
        ),
        CategoryModel(
          id: generateId(),
          name: 'Investment',
          icon: 'investment',
          color: '#6C5CE7',
          type: 'income',
        ),
        CategoryModel(
          id: generateId(),
          name: 'Gift',
          icon: 'gift',
          color: '#E84393',
          type: 'income',
        ),
        CategoryModel(
          id: generateId(),
          name: 'Other Income',
          icon: 'other',
          color: '#636E72',
          type: 'income',
        ),
      ];
      for (final cat in defaults) {
        await _categoryBox.put(cat.id, cat);
      }
    }

    if (_walletBox.isEmpty) {
      final wallets = [
        WalletModel(id: generateId(), name: 'Cash', icon: 'cash', balance: 0),
        WalletModel(
          id: generateId(),
          name: 'Bank Account',
          icon: 'bank',
          balance: 0,
        ),
        WalletModel(id: generateId(), name: 'UPI', icon: 'upi', balance: 0),
        WalletModel(
          id: generateId(),
          name: 'Credit Card',
          icon: 'credit_card',
          balance: 0,
        ),
      ];
      for (final w in wallets) {
        await _walletBox.put(w.id, w);
      }
    }
  }

  // ─────────── Transaction CRUD ───────────

  List<TransactionModel> getAllTransactions() {
    final list = _transactionBox.values.toList();
    list.sort((a, b) => b.date.compareTo(a.date));
    return list;
  }

  List<TransactionModel> getTransactionsByMonth(DateTime month) {
    final start = DateTime(month.year, month.month, 1);
    final end = DateTime(month.year, month.month + 1, 0, 23, 59, 59);
    return _transactionBox.values
        .where(
          (t) =>
              t.date.isAfter(start.subtract(const Duration(seconds: 1))) &&
              t.date.isBefore(end.add(const Duration(seconds: 1))),
        )
        .toList()
      ..sort((a, b) => b.date.compareTo(a.date));
  }

  Future<void> addTransaction(TransactionModel t) async {
    await _transactionBox.put(t.id, t);
    // Update wallet balance
    final wallet = _walletBox.get(t.walletId);
    if (wallet != null) {
      wallet.balance += t.type == 'income' ? t.amount : -t.amount;
      await _walletBox.put(wallet.id, wallet);
    }
    // Update budget spent
    if (t.type == 'expense') {
      await _updateBudgetSpent(t.categoryId, t.date);
    }
  }

  Future<void> updateTransaction(
    TransactionModel oldT,
    TransactionModel newT,
  ) async {
    // Revert old wallet balance
    final oldWallet = _walletBox.get(oldT.walletId);
    if (oldWallet != null) {
      oldWallet.balance -= oldT.type == 'income' ? oldT.amount : -oldT.amount;
      await _walletBox.put(oldWallet.id, oldWallet);
    }
    // Apply new wallet balance
    final newWallet = _walletBox.get(newT.walletId);
    if (newWallet != null) {
      newWallet.balance += newT.type == 'income' ? newT.amount : -newT.amount;
      await _walletBox.put(newWallet.id, newWallet);
    }
    await _transactionBox.put(newT.id, newT);

    // Update budgets
    if (oldT.type == 'expense') {
      await _updateBudgetSpent(oldT.categoryId, oldT.date);
    }
    if (newT.type == 'expense' && (newT.categoryId != oldT.categoryId || newT.date != oldT.date)) {
      await _updateBudgetSpent(newT.categoryId, newT.date);
    }
  }

  Future<void> deleteTransaction(TransactionModel t) async {
    // Revert wallet balance
    final wallet = _walletBox.get(t.walletId);
    if (wallet != null) {
      wallet.balance -= t.type == 'income' ? t.amount : -t.amount;
      await _walletBox.put(wallet.id, wallet);
    }
    await _transactionBox.delete(t.id);
    if (t.type == 'expense') {
      await _updateBudgetSpent(t.categoryId, t.date);
    }
  }

  // ─────────── Category CRUD ───────────

  List<CategoryModel> getAllCategories() => _categoryBox.values.toList();

  List<CategoryModel> getCategoriesByType(String type) =>
      _categoryBox.values.where((c) => c.type == type).toList();

  CategoryModel? getCategoryById(String id) => _categoryBox.get(id);

  Future<void> addCategory(CategoryModel c) async =>
      await _categoryBox.put(c.id, c);

  Future<void> updateCategory(CategoryModel c) async => await _categoryBox.put(c.id, c);

  Future<void> deleteCategory(String id) async => await _categoryBox.delete(id);

  // ─────────── Wallet CRUD ───────────

  List<WalletModel> getAllWallets() => _walletBox.values.toList();

  WalletModel? getWalletById(String id) => _walletBox.get(id);

  Future<void> addWallet(WalletModel w) async => await _walletBox.put(w.id, w);

  Future<void> updateWallet(WalletModel w) async => await _walletBox.put(w.id, w);

  Future<void> deleteWallet(String id) async => await _walletBox.delete(id);

  // ─────────── Budget CRUD ───────────

  List<BudgetModel> getAllBudgets() => _budgetBox.values.toList();

  List<BudgetModel> getBudgetsByMonth(String month) =>
      _budgetBox.values.where((b) => b.month == month).toList();

  BudgetModel? getBudgetForCategory(String categoryId, String month) {
    try {
      return _budgetBox.values.firstWhere(
        (b) => b.categoryId == categoryId && b.month == month,
      );
    } catch (_) {
      return null;
    }
  }

  Future<void> addBudget(BudgetModel b) async => await _budgetBox.put(b.id, b);

  Future<void> updateBudget(BudgetModel b) async => await _budgetBox.put(b.id, b);

  Future<void> deleteBudget(String id) async => await _budgetBox.delete(id);

  Future<void> _updateBudgetSpent(String categoryId, DateTime date) async {
    final monthKey = '${date.year}-${date.month.toString().padLeft(2, '0')}';
    final budget = getBudgetForCategory(categoryId, monthKey);
    if (budget != null) {
      final spent = _transactionBox.values
          .where(
            (t) =>
                t.categoryId == categoryId &&
                t.type == 'expense' &&
                t.date.year == date.year &&
                t.date.month == date.month,
          )
          .fold<double>(0, (sum, t) => sum + t.amount);
      budget.spentAmount = spent;
      await _budgetBox.put(budget.id, budget);
    }
  }

  // ─────────── Reminder CRUD ───────────

  List<ReminderModel> getAllReminders() {
    final list = _reminderBox.values.toList();
    list.sort((a, b) => a.date.compareTo(b.date));
    return list;
  }

  List<ReminderModel> getUpcomingReminders() {
    final now = DateTime.now();
    return _reminderBox.values
        .where((r) => r.date.isAfter(now) && !r.isCompleted)
        .toList()
      ..sort((a, b) => a.date.compareTo(b.date));
  }

  Future<void> addReminder(ReminderModel r) async =>
      await _reminderBox.put(r.id, r);

  Future<void> updateReminder(ReminderModel r) async => await _reminderBox.put(r.id, r);

  Future<void> deleteReminder(String id) async => await _reminderBox.delete(id);

  // ─────────── Goals CRUD ───────────

  List<GoalModel> getGoals() => _goalBox.values.toList();

  Future<void> saveGoals(List<GoalModel> goals) async {
    await _goalBox.clear();
    for (var g in goals) {
      await _goalBox.put(g.id, g);
    }
  }

  // ─────────── Settings ───────────

  dynamic getSetting(String key) => _settingsBox.get(key);

  Future<void> setSetting(String key, dynamic value) async =>
      await _settingsBox.put(key, value);

  // ─────────── Analytics Helpers ───────────

  double getTotalIncome({DateTime? month}) {
    var txns = _transactionBox.values.where((t) => t.type == 'income');
    if (month != null) {
      txns = txns.where(
        (t) => t.date.year == month.year && t.date.month == month.month,
      );
    }
    return txns.fold<double>(0, (sum, t) => sum + t.amount);
  }

  double getTotalExpense({DateTime? month}) {
    var txns = _transactionBox.values.where((t) => t.type == 'expense');
    if (month != null) {
      txns = txns.where(
        (t) => t.date.year == month.year && t.date.month == month.month,
      );
    }
    return txns.fold<double>(0, (sum, t) => sum + t.amount);
  }

  double getTotalBalance() {
    return _walletBox.values.fold<double>(0, (sum, w) => sum + w.balance);
  }

  Map<String, double> getExpenseByCategory({DateTime? month}) {
    var txns = _transactionBox.values.where((t) => t.type == 'expense');
    if (month != null) {
      txns = txns.where(
        (t) => t.date.year == month.year && t.date.month == month.month,
      );
    }
    final map = <String, double>{};
    for (final t in txns) {
      map[t.categoryId] = (map[t.categoryId] ?? 0) + t.amount;
    }
    return map;
  }

  // ─────────── Backup / Restore Helpers ───────────

  Map<String, dynamic> exportAllData() {
    return {
      'transactions': _transactionBox.values.map((t) => t.toJson()).toList(),
      'categories': _categoryBox.values.map((c) => c.toJson()).toList(),
      'wallets': _walletBox.values.map((w) => w.toJson()).toList(),
      'budgets': _budgetBox.values.map((b) => b.toJson()).toList(),
      'reminders': _reminderBox.values.map((r) => r.toJson()).toList(),
      'goals': _goalBox.values.map((g) => g.toJson()).toList(),
      'exportDate': DateTime.now().toIso8601String(),
      'appVersion': AppConstants.appVersion,
    };
  }

  Future<void> importAllData(Map<String, dynamic> data) async {
    // Clear existing
    await _transactionBox.clear();
    await _categoryBox.clear();
    await _walletBox.clear();
    await _budgetBox.clear();
    await _reminderBox.clear();

    // Import
    if (data['transactions'] != null) {
      for (final json in data['transactions']) {
        final t = TransactionModel.fromJson(json);
        await _transactionBox.put(t.id, t);
      }
    }
    if (data['categories'] != null) {
      for (final json in data['categories']) {
        final c = CategoryModel.fromJson(json);
        await _categoryBox.put(c.id, c);
      }
    }
    if (data['wallets'] != null) {
      for (final json in data['wallets']) {
        final w = WalletModel.fromJson(json);
        await _walletBox.put(w.id, w);
      }
    }
    if (data['budgets'] != null) {
      for (final json in data['budgets']) {
        final b = BudgetModel.fromJson(json);
        await _budgetBox.put(b.id, b);
      }
    }
    if (data['reminders'] != null) {
      for (final json in data['reminders']) {
        final r = ReminderModel.fromJson(json);
        await _reminderBox.put(r.id, r);
      }
    }
    if (data['goals'] != null) {
      for (final json in data['goals']) {
        final g = GoalModel.fromJson(json);
        await _goalBox.put(g.id, g);
      }
    }
  }

  Future<void> clearAllData() async {
    await _transactionBox.clear();
    await _budgetBox.clear();
    await _reminderBox.clear();
    await _goalBox.clear();
    // Reset all wallet balances to 0 but keep the wallets themselves
    for (final wallet in _walletBox.values) {
      wallet.balance = 0;
      await _walletBox.put(wallet.id, wallet);
    }
    // Categories are preserved as-is
  }
}
