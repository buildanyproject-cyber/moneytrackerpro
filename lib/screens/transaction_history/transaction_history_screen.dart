import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../core/constants.dart';
import '../../core/utils.dart';
import '../../providers/wallet_provider.dart';
import '../../providers/budget_provider.dart';
import '../../providers/transaction_provider.dart';

import '../../widgets/transaction_card.dart';
import '../add_transaction/add_transaction_screen.dart';

// ============================================================
// Transaction History Screen — List with month filtering
// ============================================================

class TransactionHistoryScreen extends StatefulWidget {
  const TransactionHistoryScreen({super.key});

  @override
  State<TransactionHistoryScreen> createState() =>
      _TransactionHistoryScreenState();
}

class _TransactionHistoryScreenState extends State<TransactionHistoryScreen> {
  final _searchCtrl = TextEditingController();
  bool _isSearching = false;

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: _isSearching
            ? TextField(
                controller: _searchCtrl,
                autofocus: true,
                decoration: const InputDecoration(
                  hintText: 'Search notes...',
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  filled: false,
                ),
                onChanged: (val) {
                  context.read<TransactionProvider>().setSearchQuery(val);
                },
              )
            : const Text('Transactions'),
        actions: [
          IconButton(
            icon: Icon(_isSearching ? Icons.close : Icons.search),
            onPressed: () {
              setState(() {
                _isSearching = !_isSearching;
                if (!_isSearching) {
                  _searchCtrl.clear();
                  context.read<TransactionProvider>().setSearchQuery('');
                }
              });
            },
          ),
          IconButton(
            icon: const Icon(Icons.filter_list_rounded),
            onPressed: _showFilterSheet,
          ),
        ],
      ),
      body: Consumer<TransactionProvider>(
        builder: (context, provider, child) {
          final transactions = provider.transactions;
          final currentMonth = provider.selectedMonth;

          return Column(
            children: [
              // Month selector if not searching
              if (!_isSearching)
                Container(
                  padding: const EdgeInsets.symmetric(
                    vertical: 8,
                    horizontal: 16,
                  ),
                  color: isDark ? AppColors.darkCard : AppColors.surface,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.chevron_left_rounded),
                        onPressed: provider.previousMonth,
                      ),
                      Text(
                        DateFormat('MMMM yyyy').format(currentMonth),
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.chevron_right_rounded),
                        onPressed: provider.nextMonth,
                      ),
                    ],
                  ),
                ),

              // Filter indicators
              if (provider.searchQuery.isNotEmpty || _isFiltered(provider))
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.info_outline,
                        size: 16,
                        color: AppColors.primary,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Showing filtered results',
                        style: TextStyle(
                          color: isDark
                              ? AppColors.darkTextSecondary
                              : AppColors.textSecondary,
                          fontSize: 12,
                        ),
                      ),
                      const Spacer(),
                      TextButton(
                        onPressed: () {
                          provider.clearFilters();
                          setState(() {
                            _isSearching = false;
                            _searchCtrl.clear();
                          });
                        },
                        child: const Text('Clear All'),
                      ),
                    ],
                  ),
                ),

              // List
              Expanded(
                child: transactions.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.search_off_rounded,
                              size: 64,
                              color: isDark
                                  ? AppColors.darkDivider
                                  : AppColors.divider,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'No transactions found',
                              style: TextStyle(
                                color: isDark
                                    ? AppColors.darkTextSecondary
                                    : AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(16).copyWith(bottom: 100),
                        itemCount: transactions.length,
                        itemBuilder: (context, index) {
                          final t = transactions[index];
                          // Group by day logic: show date header if day changed
                          bool showHeader = false;
                          if (index == 0) {
                            showHeader = true;
                          } else {
                            final prev = transactions[index - 1];
                            if (t.date.year != prev.date.year ||
                                t.date.month != prev.date.month ||
                                t.date.day != prev.date.day) {
                              showHeader = true;
                            }
                          }

                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (showHeader)
                                Padding(
                                  padding: const EdgeInsets.only(
                                    top: 16,
                                    bottom: 8,
                                    left: 4,
                                  ),
                                  child: Text(
                                    AppUtils.formatRelativeDate(t.date),
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      color: isDark
                                          ? AppColors.darkTextSecondary
                                          : AppColors.textSecondary,
                                    ),
                                  ),
                                ),
                              TransactionCard(
                                transaction: t,
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) =>
                                          AddTransactionScreen(transaction: t),
                                    ),
                                  );
                                },
                                onDelete: () async {
                                  await provider.deleteTransaction(t);
                                  if (context.mounted) {
                                    context.read<WalletProvider>().loadWallets();
                                    context.read<BudgetProvider>().loadBudgets();
                                  }
                                },
                              ),
                              const SizedBox(height: 8),
                            ],
                          );
                        },
                      ),
              ),
            ],
          );
        },
      ),
    );
  }

  bool _isFiltered(TransactionProvider provider) {
    // We would have to add getters for these in the provider to do correctly,
    // assuming they are private right now. For simplicity we check if count < all count.
    // In a real app we'd expose current filters. Here we'll just ignore for demo
    return false;
  }

  void _showFilterSheet() {
    // Advanced filtering UI (category/wallet) could go here
    AppUtils.showSnackBar(context, 'Advanced filtering coming soon');
  }
}
