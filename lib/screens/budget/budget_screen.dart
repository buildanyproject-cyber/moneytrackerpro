import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../core/constants.dart';
import '../../core/utils.dart';
import '../../models/budget_model.dart';
import '../../database/hive_database.dart';
import '../../widgets/app_drawer.dart';
import '../../providers/budget_provider.dart';
import '../../providers/category_provider.dart';
import '../../widgets/budget_card.dart';
import '../../widgets/custom_buttons.dart';

// ============================================================
// Budget Screen
// ============================================================

class BudgetScreen extends StatelessWidget {
  const BudgetScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const AppDrawer(),
      appBar: AppBar(title: const Text('Budgets')),
      body: Consumer<BudgetProvider>(
        builder: (context, provider, child) {
          final budgets = provider.budgets;
          final isDark = Theme.of(context).brightness == Brightness.dark;

          return Column(
            children: [
              // Overall Progress
              Container(
                margin: const EdgeInsets.all(16),
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.3),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Overall Budget',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 24),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: LinearProgressIndicator(
                        value: provider.overallProgress,
                        minHeight: 12,
                        backgroundColor: Colors.white.withValues(alpha: 0.3),
                        valueColor: const AlwaysStoppedAnimation(Colors.white),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '${(provider.overallProgress * 100).toStringAsFixed(1)}% Used',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.9),
                            fontSize: 12,
                          ),
                        ),
                        Text(
                          DateFormat('MMMM yyyy').format(DateTime.now()),
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.9),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Budgets List
              Expanded(
                child: budgets.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.track_changes_rounded,
                              size: 64,
                              color: isDark
                                  ? AppColors.darkDivider
                                  : AppColors.divider,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'No budgets set for this month',
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
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ).copyWith(bottom: 100),
                        itemCount: budgets.length,
                        itemBuilder: (context, index) {
                          final b = budgets[index];
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: BudgetCard(
                              budget: b,
                              onTap: () => _showAddDialog(context, budget: b),
                            ),
                          );
                        },
                      ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddDialog(context),
        icon: const Icon(Icons.add),
        label: const Text(''),
      ),
    );
  }

  void _showAddDialog(BuildContext context, {BudgetModel? budget}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => _AddBudgetSheet(budget: budget),
    );
  }
}

// ============================================================
// Add/Edit Bottom Sheet
// ============================================================

class _AddBudgetSheet extends StatefulWidget {
  final BudgetModel? budget;

  const _AddBudgetSheet({this.budget});

  @override
  State<_AddBudgetSheet> createState() => _AddBudgetSheetState();
}

class _AddBudgetSheetState extends State<_AddBudgetSheet> {
  final _amountCtrl = TextEditingController();
  String? _selectedCategory;

  @override
  void initState() {
    super.initState();
    if (widget.budget != null) {
      _amountCtrl.text = widget.budget!.budgetAmount.toString();
      _selectedCategory = widget.budget!.categoryId;
    }
  }

  @override
  void dispose() {
    _amountCtrl.dispose();
    super.dispose();
  }

  void _save() {
    if (_selectedCategory == null) {
      AppUtils.showSnackBar(context, 'Please select a category', isError: true);
      return;
    }

    final amount = double.tryParse(_amountCtrl.text.replaceAll(',', ''));
    if (amount == null || amount <= 0) {
      AppUtils.showSnackBar(context, 'Enter a valid amount', isError: true);
      return;
    }

    final provider = context.read<BudgetProvider>();
    final currentMonth = DateFormat('yyyy-MM').format(DateTime.now());

    final b = BudgetModel(
      id: widget.budget?.id ?? HiveDatabase.generateId(),
      categoryId: _selectedCategory!,
      budgetAmount: amount,
      month: currentMonth,
      spentAmount: widget.budget?.spentAmount ?? 0,
    );

    if (widget.budget == null) {
      provider.addBudget(b);
      AppUtils.showSnackBar(context, 'Budget created');
    } else {
      provider.updateBudget(b);
      AppUtils.showSnackBar(context, 'Budget updated');
    }

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Theme.of(context).brightness == Brightness.dark
              ? AppColors.darkCard
              : AppColors.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.budget == null ? 'Set Budget' : 'Edit Budget',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),

            // Category
            const Text(
              'Category',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Consumer<CategoryProvider>(
              builder: (context, catProvider, child) {
                final categories = catProvider.expenseCategories;
                return DropdownButtonFormField<String>(
                  initialValue: _selectedCategory,
                  items: categories.map((c) {
                    return DropdownMenuItem(value: c.id, child: Text(c.name));
                  }).toList(),
                  onChanged: (val) => setState(() => _selectedCategory = val),
                  decoration: const InputDecoration(
                    prefixIcon: Icon(Icons.category_outlined),
                  ),
                );
              },
            ),
            const SizedBox(height: 24),

            // Amount
            const Text(
              'Monthly Limit',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _amountCtrl,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              decoration: const InputDecoration(
                prefixIcon: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    AppConstants.defaultCurrency,
                    style: TextStyle(fontSize: 20),
                  ),
                ),
                prefixIconConstraints: BoxConstraints(
                  minWidth: 0,
                  minHeight: 0,
                ),
              ),
            ),
            const SizedBox(height: 48),

            Row(
              children: [
                if (widget.budget != null) ...[
                  Expanded(
                    child: SecondaryButton(
                      label: 'Delete',
                      icon: Icons.delete_outline,
                      onPressed: () {
                        context.read<BudgetProvider>().deleteBudget(
                          widget.budget!.id,
                        );
                        Navigator.pop(context);
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                ],
                Expanded(
                  flex: 2,
                  child: PrimaryButton(label: 'Save', onPressed: _save),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
