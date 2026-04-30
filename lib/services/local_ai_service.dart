import 'package:intl/intl.dart';
import '../database/hive_database.dart';
import '../models/transaction_model.dart';
import '../models/category_model.dart';

// ============================================================
// Local AI Financial Assistant — No API, No Backend
// Analyzes user's Hive data to answer financial questions
// ============================================================

class LocalAIService {
  final HiveDatabase _db = HiveDatabase();

  String _currency = '₹';

  void setCurrency(String symbol) => _currency = symbol;

  // ─────────── Main entry point ───────────

  String getResponse(String userMessage) {
    final msg = userMessage.toLowerCase().trim();

    // Greetings
    if (_matchAny(msg, ['hi', 'hello', 'hey', 'hii', 'namaste', 'hola'])) {
      return _greetingResponse();
    }

    // Help
    if (_matchAny(msg, ['help', 'kya kar sakte', 'what can you', 'features', 'commands'])) {
      return _helpResponse();
    }

    // Summary / Overview
    if (_matchAny(msg, ['summary', 'overview', 'report', 'status', 'overall', 'kaise hai', 'kaisa hai'])) {
      return _summaryResponse();
    }

    // Total balance
    if (_matchAny(msg, ['total balance', 'net worth', 'kitna paisa', 'kitne paise', 'balance'])) {
      return _balanceResponse();
    }

    // Income-specific
    if (_matchAny(msg, ['income', 'earning', 'kamai', 'kamaya', 'earned'])) {
      return _incomeResponse(msg);
    }

    // Expense-specific
    if (_matchAny(msg, ['expense', 'spending', 'spent', 'kharch', 'kharcha', 'expenditure'])) {
      return _expenseResponse(msg);
    }

    // Budget status
    if (_matchAny(msg, ['budget', 'limit', 'over budget', 'under budget'])) {
      return _budgetResponse();
    }

    // Goal progress
    if (_matchAny(msg, ['goal', 'target', 'lakshya', 'savings goal'])) {
      return _goalResponse();
    }

    // Wallet info
    if (_matchAny(msg, ['wallet', 'account', 'bank', 'upi', 'cash', 'card'])) {
      return _walletResponse();
    }

    // Category breakdown
    if (_matchAny(msg, ['category', 'categories', 'breakdown', 'category wise', 'kisme'])) {
      return _categoryBreakdown();
    }

    // Top spends
    if (_matchAny(msg, ['top', 'highest', 'biggest', 'largest', 'max', 'sabse jyada'])) {
      return _topSpendingResponse();
    }

    // Savings / tips
    if (_matchAny(msg, ['save', 'saving', 'tip', 'advice', 'suggest', 'bachao', 'bachat'])) {
      return _savingsTips();
    }

    // Today
    if (_matchAny(msg, ['today', 'aaj', 'आज'])) {
      return _todayResponse();
    }

    // This week
    if (_matchAny(msg, ['week', 'hafta', 'is hafte'])) {
      return _weekResponse();
    }

    // This month
    if (_matchAny(msg, ['month', 'mahina', 'is mahine', 'this month'])) {
      return _monthResponse();
    }

    // Last month comparison
    if (_matchAny(msg, ['last month', 'pichle mahine', 'compare', 'comparison', 'pehle'])) {
      return _comparisonResponse();
    }

    // Average
    if (_matchAny(msg, ['average', 'avg', 'daily average', 'per day'])) {
      return _averageResponse();
    }

    // Recent transactions
    if (_matchAny(msg, ['recent', 'last transaction', 'latest', 'haal hi'])) {
      return _recentTransactionsResponse();
    }

    // Count
    if (_matchAny(msg, ['how many', 'count', 'kitne transaction', 'total transactions'])) {
      return _countResponse();
    }

    // Fallback
    return _fallbackResponse();
  }

  // ─────────── Helpers ───────────

  bool _matchAny(String msg, List<String> keywords) {
    return keywords.any((k) => msg.contains(k));
  }

  String _fmt(double amount) {
    final f = NumberFormat('#,##,##0.00');
    return '$_currency${f.format(amount)}';
  }

  List<TransactionModel> _thisMonthTransactions() {
    final now = DateTime.now();
    return _db.getAllTransactions().where((t) =>
        t.date.year == now.year && t.date.month == now.month).toList();
  }

  List<TransactionModel> _lastMonthTransactions() {
    final now = DateTime.now();
    final lm = DateTime(now.year, now.month - 1);
    return _db.getAllTransactions().where((t) =>
        t.date.year == lm.year && t.date.month == lm.month).toList();
  }

  double _sumByType(List<TransactionModel> txns, String type) {
    return txns.where((t) => t.type == type).fold(0.0, (s, t) => s + t.amount);
  }

  // ─────────── Responses ───────────

  String _greetingResponse() {
    final hour = DateTime.now().hour;
    final greeting = hour < 12 ? 'Good Morning' : (hour < 17 ? 'Good Afternoon' : 'Good Evening');
    final all = _db.getAllTransactions();
    final totalExpense = _sumByType(all, 'expense');
    return '👋 $greeting!\n\n'
        'I\'m RISHI, your MoneyTracker AI assistant. I analyze your financial data locally — no internet needed!\n\n'
        '📊 Quick Stats:\n'
        '• Total transactions: ${all.length}\n'
        '• Total spent: ${_fmt(totalExpense)}\n\n'
        'Ask me anything about your finances! Type "help" to see what I can do.';
  }

  String _helpResponse() {
    return '🤖 Here\'s what I can help you with:\n\n'
        '💰 **Balance** — "What\'s my balance?"\n'
        '📊 **Summary** — "Give me a summary"\n'
        '💸 **Expenses** — "How much did I spend?"\n'
        '💵 **Income** — "What\'s my income?"\n'
        '📂 **Categories** — "Category breakdown"\n'
        '🎯 **Budgets** — "Budget status"\n'
        '🏆 **Goals** — "Goal progress"\n'
        '👛 **Wallets** — "Wallet info"\n'
        '🔝 **Top Spends** — "Top spending"\n'
        '📅 **Today** — "Today\'s expenses"\n'
        '📆 **This Month** — "This month report"\n'
        '📉 **Compare** — "Compare with last month"\n'
        '💡 **Tips** — "Saving tips"\n'
        '🕐 **Recent** — "Recent transactions"\n\n'
        'You can ask in Hindi or English! 🇮🇳';
  }

  String _summaryResponse() {
    final now = DateTime.now();
    final monthName = DateFormat('MMMM yyyy').format(now);
    final txns = _thisMonthTransactions();
    final income = _sumByType(txns, 'income');
    final expense = _sumByType(txns, 'expense');
    final savings = income - expense;
    final wallets = _db.getAllWallets();
    final netWorth = wallets.fold(0.0, (s, w) => s + w.balance);

    String savingsEmoji = savings >= 0 ? '✅' : '⚠️';

    return '📊 **$monthName Summary**\n\n'
        '💵 Income: ${_fmt(income)}\n'
        '💸 Expenses: ${_fmt(expense)}\n'
        '$savingsEmoji Net: ${_fmt(savings)}\n'
        '💰 Net Worth: ${_fmt(netWorth)}\n\n'
        '📝 Transactions: ${txns.length}\n'
        '${savings >= 0 ? '🎉 Great! You\'re saving money this month!' : '😟 Expenses exceed income. Try to cut unnecessary spending.'}';
  }

  String _balanceResponse() {
    final wallets = _db.getAllWallets();
    final netWorth = wallets.fold(0.0, (s, w) => s + w.balance);
    final buffer = StringBuffer('💰 **Your Wallets**\n\n');
    for (final w in wallets) {
      buffer.writeln('• ${w.name}: ${_fmt(w.balance)}');
    }
    buffer.writeln('\n💎 **Net Worth: ${_fmt(netWorth)}**');
    return buffer.toString();
  }

  String _incomeResponse(String msg) {
    final txns = msg.contains('last month') ? _lastMonthTransactions() : _thisMonthTransactions();
    final period = msg.contains('last month') ? 'Last Month' : 'This Month';
    final income = _sumByType(txns, 'income');
    final incomeTxns = txns.where((t) => t.type == 'income').toList();

    if (incomeTxns.isEmpty) {
      return '💵 No income recorded for $period.\n\nAdd income transactions to track your earnings!';
    }

    final categories = _db.getAllCategories();
    final catMap = {for (var c in categories) c.id: c.name};

    final byCategory = <String, double>{};
    for (var t in incomeTxns) {
      final catName = catMap[t.categoryId] ?? 'Other';
      byCategory[catName] = (byCategory[catName] ?? 0) + t.amount;
    }

    final sorted = byCategory.entries.toList()..sort((a, b) => b.value.compareTo(a.value));

    final buffer = StringBuffer('💵 **$period Income: ${_fmt(income)}**\n\n');
    buffer.writeln('Sources:');
    for (final entry in sorted) {
      buffer.writeln('• ${entry.key}: ${_fmt(entry.value)}');
    }
    return buffer.toString();
  }

  String _expenseResponse(String msg) {
    final txns = msg.contains('last month') ? _lastMonthTransactions() : _thisMonthTransactions();
    final period = msg.contains('last month') ? 'Last Month' : 'This Month';
    final expense = _sumByType(txns, 'expense');
    final expenseTxns = txns.where((t) => t.type == 'expense').toList();

    if (expenseTxns.isEmpty) {
      return '💸 No expenses recorded for $period.';
    }

    final categories = _db.getAllCategories();
    final catMap = {for (var c in categories) c.id: c.name};

    final byCategory = <String, double>{};
    for (var t in expenseTxns) {
      final catName = catMap[t.categoryId] ?? 'Other';
      byCategory[catName] = (byCategory[catName] ?? 0) + t.amount;
    }

    final sorted = byCategory.entries.toList()..sort((a, b) => b.value.compareTo(a.value));

    final buffer = StringBuffer('💸 **$period Expenses: ${_fmt(expense)}**\n\n');
    buffer.writeln('Breakdown:');
    for (final entry in sorted) {
      final pct = (entry.value / expense * 100).toStringAsFixed(1);
      buffer.writeln('• ${entry.key}: ${_fmt(entry.value)} ($pct%)');
    }
    return buffer.toString();
  }

  String _budgetResponse() {
    final budgets = _db.getAllBudgets();
    if (budgets.isEmpty) {
      return '🎯 You haven\'t set any budgets yet.\n\nGo to Budgets → Add one to track your spending limits!';
    }

    final categories = _db.getAllCategories();
    final catMap = {for (var c in categories) c.id: c.name};
    final now = DateTime.now();
    final monthTxns = _thisMonthTransactions();

    final buffer = StringBuffer('🎯 **Budget Status — ${DateFormat('MMMM').format(now)}**\n\n');

    for (final b in budgets) {
      final catName = catMap[b.categoryId] ?? 'Unknown';
      final spent = monthTxns
          .where((t) => t.categoryId == b.categoryId && t.type == 'expense')
          .fold(0.0, (s, t) => s + t.amount);
      final pct = b.budgetAmount > 0 ? (spent / b.budgetAmount * 100) : 0.0;
      final status = pct > 100 ? '🔴 OVER' : (pct > 80 ? '🟡 WARNING' : '🟢 GOOD');

      buffer.writeln('$status **$catName**');
      buffer.writeln('   ${_fmt(spent)} / ${_fmt(b.budgetAmount)} (${pct.toStringAsFixed(0)}%)');
      buffer.writeln('');
    }
    return buffer.toString();
  }

  String _goalResponse() {
    final goals = _db.getGoals();
    if (goals.isEmpty) {
      return '🏆 No savings goals set yet.\n\nCreate a goal to start tracking your progress!';
    }

    final buffer = StringBuffer('🏆 **Your Savings Goals**\n\n');
    for (final g in goals) {
      final pct = g.targetAmount > 0 ? (g.savedAmount / g.targetAmount * 100) : 0.0;
      final remaining = g.targetAmount - g.savedAmount;
      final emoji = pct >= 100 ? '🎉' : (pct > 50 ? '📈' : '📊');

      buffer.writeln('$emoji **${g.title}**');
      buffer.writeln('   ${_fmt(g.savedAmount)} / ${_fmt(g.targetAmount)} (${pct.toStringAsFixed(0)}%)');
      if (pct < 100) {
        buffer.writeln('   Need ${_fmt(remaining)} more');
      } else {
        buffer.writeln('   🎊 Goal achieved!');
      }
      buffer.writeln('');
    }
    return buffer.toString();
  }

  String _walletResponse() {
    final wallets = _db.getAllWallets();
    if (wallets.isEmpty) {
      return '👛 No wallets found. Add a wallet to get started!';
    }

    final total = wallets.fold(0.0, (s, w) => s + w.balance);
    final buffer = StringBuffer('👛 **Wallet Overview**\n\n');
    for (final w in wallets) {
      final emoji = w.balance > 0 ? '💚' : (w.balance < 0 ? '🔴' : '⚪');
      buffer.writeln('$emoji ${w.name}: ${_fmt(w.balance)}');
    }
    buffer.writeln('\n💎 Total: ${_fmt(total)}');
    return buffer.toString();
  }

  String _categoryBreakdown() {
    final txns = _thisMonthTransactions();
    final expenses = txns.where((t) => t.type == 'expense').toList();

    if (expenses.isEmpty) {
      return '📂 No expenses this month to analyze.';
    }

    final totalExp = expenses.fold(0.0, (s, t) => s + t.amount);
    final categories = _db.getAllCategories();
    final catMap = {for (var c in categories) c.id: c.name};

    final byCategory = <String, double>{};
    for (var t in expenses) {
      final catName = catMap[t.categoryId] ?? 'Other';
      byCategory[catName] = (byCategory[catName] ?? 0) + t.amount;
    }

    final sorted = byCategory.entries.toList()..sort((a, b) => b.value.compareTo(a.value));

    final buffer = StringBuffer('📂 **Category-wise Expenses (${DateFormat('MMMM').format(DateTime.now())})**\n\n');
    for (int i = 0; i < sorted.length; i++) {
      final e = sorted[i];
      final pct = (e.value / totalExp * 100).toStringAsFixed(1);
      final bar = '█' * ((e.value / totalExp * 10).round().clamp(1, 10));
      buffer.writeln('${i + 1}. ${e.key}: ${_fmt(e.value)} ($pct%)');
      buffer.writeln('   $bar');
    }
    buffer.writeln('\n💸 Total: ${_fmt(totalExp)}');
    return buffer.toString();
  }

  String _topSpendingResponse() {
    final txns = _thisMonthTransactions();
    final expenses = txns.where((t) => t.type == 'expense').toList()
      ..sort((a, b) => b.amount.compareTo(a.amount));

    if (expenses.isEmpty) {
      return '🔝 No expenses this month to show top spending.';
    }

    final categories = _db.getAllCategories();
    final catMap = {for (var c in categories) c.id: c.name};
    final top = expenses.take(5);

    final buffer = StringBuffer('🔝 **Top 5 Expenses This Month**\n\n');
    int i = 1;
    for (final t in top) {
      final catName = catMap[t.categoryId] ?? 'Other';
      final dateStr = DateFormat('dd MMM').format(t.date);
      buffer.writeln('$i. ${_fmt(t.amount)} — $catName');
      buffer.writeln('   📅 $dateStr ${t.note.isNotEmpty ? '• ${t.note}' : ''}');
      i++;
    }
    return buffer.toString();
  }

  String _savingsTips() {
    final txns = _thisMonthTransactions();
    final income = _sumByType(txns, 'income');
    final expense = _sumByType(txns, 'expense');

    final categories = _db.getAllCategories();
    final catMap = {for (var c in categories) c.id: c.name};

    final byCategory = <String, double>{};
    for (var t in txns.where((t) => t.type == 'expense')) {
      final catName = catMap[t.categoryId] ?? 'Other';
      byCategory[catName] = (byCategory[catName] ?? 0) + t.amount;
    }

    final sorted = byCategory.entries.toList()..sort((a, b) => b.value.compareTo(a.value));
    final topCategory = sorted.isNotEmpty ? sorted.first : null;

    final buffer = StringBuffer('💡 **Personalized Financial Tips**\n\n');

    if (expense > income && income > 0) {
      buffer.writeln('⚠️ You\'re spending ${_fmt(expense - income)} more than you earn this month!');
      buffer.writeln('');
    }

    if (topCategory != null) {
      final topPct = expense > 0 ? (topCategory.value / expense * 100).toStringAsFixed(0) : '0';
      buffer.writeln('🔍 Your biggest expense category is **${topCategory.key}** '
          '(${_fmt(topCategory.value)} = $topPct% of total).');
      buffer.writeln('   💡 Try setting a budget for ${topCategory.key} to control this.');
      buffer.writeln('');
    }

    if (income > 0) {
      final savingsRate = ((income - expense) / income * 100);
      if (savingsRate > 20) {
        buffer.writeln('🎉 Amazing! Your savings rate is ${savingsRate.toStringAsFixed(0)}%. Keep it up!');
      } else if (savingsRate > 0) {
        buffer.writeln('📊 Your savings rate is ${savingsRate.toStringAsFixed(0)}%. '
            'Aim for 20%+ for a healthy financial life.');
      } else {
        buffer.writeln('📉 Your savings rate is negative. Try the 50/30/20 rule:');
        buffer.writeln('   50% Needs • 30% Wants • 20% Savings');
      }
      buffer.writeln('');
    }

    buffer.writeln('💡 Quick Tips:');
    buffer.writeln('• Track every expense, even small ones');
    buffer.writeln('• Set monthly budgets for top categories');
    buffer.writeln('• Use reminders for recurring bills');
    buffer.writeln('• Review your spending weekly');

    return buffer.toString();
  }

  String _todayResponse() {
    final today = DateTime.now();
    final all = _db.getAllTransactions();
    final todayTxns = all.where((t) =>
        t.date.year == today.year &&
        t.date.month == today.month &&
        t.date.day == today.day).toList();

    if (todayTxns.isEmpty) {
      return '📅 No transactions recorded today.\n\nLooks like a no-spend day! 🎉';
    }

    final income = _sumByType(todayTxns, 'income');
    final expense = _sumByType(todayTxns, 'expense');

    final categories = _db.getAllCategories();
    final catMap = {for (var c in categories) c.id: c.name};

    final buffer = StringBuffer('📅 **Today\'s Summary**\n\n');
    buffer.writeln('💵 Income: ${_fmt(income)}');
    buffer.writeln('💸 Expenses: ${_fmt(expense)}');
    buffer.writeln('📝 Transactions: ${todayTxns.length}\n');

    for (final t in todayTxns) {
      final catName = catMap[t.categoryId] ?? 'Other';
      final emoji = t.type == 'income' ? '💚' : '🔴';
      buffer.writeln('$emoji ${_fmt(t.amount)} — $catName ${t.note.isNotEmpty ? '(${t.note})' : ''}');
    }
    return buffer.toString();
  }

  String _weekResponse() {
    final now = DateTime.now();
    final weekStart = now.subtract(Duration(days: now.weekday - 1));
    final all = _db.getAllTransactions();
    final weekTxns = all.where((t) =>
        t.date.isAfter(weekStart.subtract(const Duration(days: 1))) &&
        t.date.isBefore(now.add(const Duration(days: 1)))).toList();

    if (weekTxns.isEmpty) {
      return '📆 No transactions this week yet.';
    }

    final income = _sumByType(weekTxns, 'income');
    final expense = _sumByType(weekTxns, 'expense');
    final dailyAvg = expense / now.weekday;

    return '📆 **This Week\'s Summary**\n\n'
        '💵 Income: ${_fmt(income)}\n'
        '💸 Expenses: ${_fmt(expense)}\n'
        '📝 Transactions: ${weekTxns.length}\n'
        '📈 Daily Avg Spending: ${_fmt(dailyAvg)}\n\n'
        '${expense > income ? '⚠️ Spending more than earning this week!' : '✅ Spending under control!'}';
  }

  String _monthResponse() {
    return _summaryResponse();
  }

  String _comparisonResponse() {
    final thisMonth = _thisMonthTransactions();
    final lastMonth = _lastMonthTransactions();

    final thisIncome = _sumByType(thisMonth, 'income');
    final thisExpense = _sumByType(thisMonth, 'expense');
    final lastIncome = _sumByType(lastMonth, 'income');
    final lastExpense = _sumByType(lastMonth, 'expense');

    final incomeChange = lastIncome > 0 ? ((thisIncome - lastIncome) / lastIncome * 100) : 0.0;
    final expenseChange = lastExpense > 0 ? ((thisExpense - lastExpense) / lastExpense * 100) : 0.0;

    final now = DateTime.now();
    final thisName = DateFormat('MMMM').format(now);
    final lastName = DateFormat('MMMM').format(DateTime(now.year, now.month - 1));

    return '📉 **$thisName vs $lastName**\n\n'
        '💵 Income:\n'
        '   $lastName: ${_fmt(lastIncome)}\n'
        '   $thisName: ${_fmt(thisIncome)} ${incomeChange >= 0 ? '📈' : '📉'} ${incomeChange.toStringAsFixed(1)}%\n\n'
        '💸 Expenses:\n'
        '   $lastName: ${_fmt(lastExpense)}\n'
        '   $thisName: ${_fmt(thisExpense)} ${expenseChange >= 0 ? '📈' : '📉'} ${expenseChange.toStringAsFixed(1)}%\n\n'
        '${thisExpense < lastExpense ? '🎉 You\'re spending less than last month!' : '⚠️ Spending has increased compared to last month.'}';
  }

  String _averageResponse() {
    final now = DateTime.now();
    final txns = _thisMonthTransactions();
    final expense = _sumByType(txns, 'expense');
    final day = now.day;
    final dailyAvg = day > 0 ? expense / day : 0.0;
    final daysInMonth = DateTime(now.year, now.month + 1, 0).day;
    final projected = dailyAvg * daysInMonth;

    return '📊 **Spending Averages**\n\n'
        '💸 Total Spent: ${_fmt(expense)} (in $day days)\n'
        '📅 Daily Average: ${_fmt(dailyAvg)}\n'
        '📆 Weekly Average: ${_fmt(dailyAvg * 7)}\n'
        '🔮 Projected Monthly: ${_fmt(projected)}\n\n'
        '${projected > expense * 1.2 ? '⚠️ At this rate, you might overspend!' : '✅ Your spending pace looks reasonable.'}';
  }

  String _recentTransactionsResponse() {
    final all = _db.getAllTransactions();
    if (all.isEmpty) {
      return '🕐 No transactions recorded yet. Start tracking your finances!';
    }

    final recent = all.take(5).toList();
    final categories = _db.getAllCategories();
    final catMap = {for (var c in categories) c.id: c.name};

    final buffer = StringBuffer('🕐 **Last ${recent.length} Transactions**\n\n');
    for (final t in recent) {
      final catName = catMap[t.categoryId] ?? 'Other';
      final emoji = t.type == 'income' ? '💚' : '🔴';
      final dateStr = DateFormat('dd MMM').format(t.date);
      buffer.writeln('$emoji ${_fmt(t.amount)} — $catName');
      buffer.writeln('   📅 $dateStr ${t.note.isNotEmpty ? '• ${t.note}' : ''}');
    }
    return buffer.toString();
  }

  String _countResponse() {
    final all = _db.getAllTransactions();
    final thisMonth = _thisMonthTransactions();
    final incomeCount = thisMonth.where((t) => t.type == 'income').length;
    final expenseCount = thisMonth.where((t) => t.type == 'expense').length;

    return '🔢 **Transaction Count**\n\n'
        '📊 All Time: ${all.length}\n'
        '📅 This Month: ${thisMonth.length}\n'
        '   💵 Income: $incomeCount\n'
        '   💸 Expense: $expenseCount';
  }

  String _fallbackResponse() {
    final txns = _thisMonthTransactions();
    final expense = _sumByType(txns, 'expense');
    final income = _sumByType(txns, 'income');

    return '🤔 I didn\'t quite get that, but here\'s a quick overview:\n\n'
        '💵 Income (this month): ${_fmt(income)}\n'
        '💸 Expenses (this month): ${_fmt(expense)}\n'
        '📝 Transactions: ${txns.length}\n\n'
        'Try asking:\n'
        '• "Summary" for a full overview\n'
        '• "Budget status" for budget tracking\n'
        '• "Saving tips" for personalized advice\n'
        '• "Help" for all commands';
  }

  // ─────────── Quick Insight Cards ───────────

  List<String> getQuickInsights() {
    final insights = <String>[];
    final txns = _thisMonthTransactions();
    final income = _sumByType(txns, 'income');
    final expense = _sumByType(txns, 'expense');

    if (expense > income && income > 0) {
      insights.add('⚠️ You\'re spending more than you earn this month!');
    }

    if (txns.isEmpty) {
      insights.add('📝 No transactions this month. Start tracking today!');
    }

    final budgets = _db.getAllBudgets();
    for (final b in budgets) {
      final spent = txns
          .where((t) => t.categoryId == b.categoryId && t.type == 'expense')
          .fold(0.0, (s, t) => s + t.amount);
      if (spent > b.budgetAmount) {
        final categories = _db.getAllCategories();
        final catName = categories.firstWhere(
          (c) => c.id == b.categoryId,
          orElse: () => CategoryModel(id: '', name: 'Unknown', icon: '', color: '', type: ''),
        ).name;
        insights.add('🔴 Over budget on $catName: ${_fmt(spent)} / ${_fmt(b.budgetAmount)}');
      }
    }

    if (income > 0) {
      final savingsRate = ((income - expense) / income * 100);
      if (savingsRate > 30) {
        insights.add('🎉 Savings rate: ${savingsRate.toStringAsFixed(0)}% — Excellent!');
      }
    }

    if (insights.isEmpty) {
      insights.add('✅ Your finances are looking good!');
    }

    return insights;
  }
}
