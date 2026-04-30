import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../core/constants.dart';
import '../../core/utils.dart';
import '../../models/goal_model.dart';
import '../../database/hive_database.dart';
import '../../providers/goal_provider.dart';
import '../../providers/settings_provider.dart';
import '../../widgets/app_drawer.dart';
import '../../widgets/custom_buttons.dart';

// ============================================================
// Goals Screen
// ============================================================

class GoalsScreen extends StatelessWidget {
  const GoalsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const AppDrawer(),
      appBar: AppBar(title: const Text('Financial Goals')),
      body: Consumer2<GoalProvider, SettingsProvider>(
        builder: (context, provider, settings, child) {
          final goals = provider.goals;
          final isDark = Theme.of(context).brightness == Brightness.dark;

          return Column(
            children: [
              // Header Summary
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
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Active Goals',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '${goals.length} Goals Tracking',
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.8),
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Icon(
                        Icons.flag_rounded,
                        color: Colors.white,
                        size: 32,
                      ),
                    ),
                  ],
                ),
              ),

              // Goals List
              Expanded(
                child: goals.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.flag_outlined,
                              size: 64,
                              color: isDark
                                  ? AppColors.darkDivider
                                  : AppColors.divider,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'No goals set yet',
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
                        itemCount: goals.length,
                        itemBuilder: (context, index) {
                          final g = goals[index];
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: _GoalCard(
                              goal: g,
                              currency: settings.currency,
                              onTap: () => _showAddDialog(context, goal: g),
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

  void _showAddDialog(BuildContext context, {GoalModel? goal}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => _AddGoalSheet(goal: goal),
    );
  }
}

// ============================================================
// Goal Card
// ============================================================

class _GoalCard extends StatelessWidget {
  final GoalModel goal;
  final String currency;
  final VoidCallback onTap;

  const _GoalCard({
    required this.goal,
    required this.currency,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final progress = (goal.savedAmount / goal.targetAmount).clamp(0.0, 1.0);
    final isCompleted = progress >= 1.0;
    final color = AppUtils.colorFromHex(goal.colorHex);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkCard : AppColors.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isDark ? AppColors.darkDivider : AppColors.divider,
          ),
          boxShadow: [
            if (!isDark)
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.03),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
          ],
        ),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(CategoryIcons.getIcon(goal.icon), color: color),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        goal.title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Target by ${DateFormat(AppConstants.dateFormat).format(goal.targetDate)}',
                        style: TextStyle(
                          fontSize: 12,
                          color: isDark
                              ? AppColors.darkTextSecondary
                              : AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                if (isCompleted)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.income.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.check_circle,
                          color: AppColors.income,
                          size: 14,
                        ),
                        SizedBox(width: 4),
                        Text(
                          'Done',
                          style: TextStyle(
                            color: AppColors.income,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  AppUtils.formatCurrency(goal.savedAmount, symbol: currency),
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: isCompleted ? AppColors.income : null,
                  ),
                ),
                Text(
                  AppUtils.formatCurrency(goal.targetAmount, symbol: currency),
                  style: TextStyle(
                    fontSize: 14,
                    color: isDark
                        ? AppColors.darkTextSecondary
                        : AppColors.textSecondary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 8,
                backgroundColor: isDark
                    ? AppColors.darkBackground
                    : AppColors.background,
                valueColor: AlwaysStoppedAnimation(
                  isCompleted ? AppColors.income : color,
                ),
              ),
            ),
            if (!isCompleted) ...[
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () {
                    _showQuickAddFundsDialog(context, goal);
                  },
                  icon: Icon(Icons.add, color: color, size: 20),
                  label: Text('Add Funds', style: TextStyle(color: color)),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: color.withValues(alpha: 0.5)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _showQuickAddFundsDialog(BuildContext context, GoalModel goal) {
    final amtCtrl = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Add Funds'),
        content: TextField(
          controller: amtCtrl,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: const InputDecoration(
            labelText: 'Amount to add',
            hintText: '0.00',
            prefixIcon: Icon(Icons.add_circle_outline),
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final amount = double.tryParse(amtCtrl.text) ?? 0.0;
              if (amount > 0) {
                final newSaved = goal.savedAmount + amount;
                final updatedGoal = GoalModel(
                  id: goal.id,
                  title: goal.title,
                  targetAmount: goal.targetAmount,
                  savedAmount: newSaved,
                  targetDate: goal.targetDate,
                  icon: goal.icon,
                  colorHex: goal.colorHex,
                );
                context.read<GoalProvider>().updateGoal(updatedGoal);
                AppUtils.showSnackBar(context, 'Funds added to ${goal.title}!');
              }
              Navigator.pop(ctx);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
            ),
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// Add/Edit Goal Bottom Sheet
// ============================================================

class _AddGoalSheet extends StatefulWidget {
  final GoalModel? goal;

  const _AddGoalSheet({this.goal});

  @override
  State<_AddGoalSheet> createState() => _AddGoalSheetState();
}

class _AddGoalSheetState extends State<_AddGoalSheet> {
  final _titleCtrl = TextEditingController();
  final _targetAmountCtrl = TextEditingController();
  final _savedAmountCtrl = TextEditingController();

  DateTime? _targetDate;
  String _selectedIcon = 'other';
  String _selectedColor = '#6C5CE7';

  @override
  void initState() {
    super.initState();
    if (widget.goal != null) {
      _titleCtrl.text = widget.goal!.title;
      _targetAmountCtrl.text = widget.goal!.targetAmount.toString();
      _savedAmountCtrl.text = widget.goal!.savedAmount.toString();
      _targetDate = widget.goal!.targetDate;
      _selectedIcon = widget.goal!.icon;
      _selectedColor = widget.goal!.colorHex;
    } else {
      _targetDate = DateTime.now().add(
        const Duration(days: 90),
      ); // default 3 mo
      _savedAmountCtrl.text = '0';
    }
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _targetAmountCtrl.dispose();
    _savedAmountCtrl.dispose();
    super.dispose();
  }

  void _presentDatePicker() {
    showDatePicker(
      context: context,
      initialDate: _targetDate ?? DateTime.now().add(const Duration(days: 90)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 3650)),
    ).then((pickedDate) {
      if (pickedDate == null) {
        return;
      }
      setState(() {
        _targetDate = pickedDate;
      });
    });
  }

  void _save() {
    final title = _titleCtrl.text.trim();
    if (title.isEmpty) {
      AppUtils.showSnackBar(context, 'Please enter a title', isError: true);
      return;
    }

    final targetAmt = double.tryParse(
      _targetAmountCtrl.text.replaceAll(',', ''),
    );
    if (targetAmt == null || targetAmt <= 0) {
      AppUtils.showSnackBar(
        context,
        'Enter a valid target amount',
        isError: true,
      );
      return;
    }

    final savedAmt =
        double.tryParse(_savedAmountCtrl.text.replaceAll(',', '')) ?? 0.0;

    if (_targetDate == null) {
      AppUtils.showSnackBar(
        context,
        'Please select a target date',
        isError: true,
      );
      return;
    }

    final model = GoalModel(
      id: widget.goal?.id ?? HiveDatabase.generateId(),
      title: title,
      targetAmount: targetAmt,
      savedAmount: savedAmt,
      targetDate: _targetDate!,
      icon: _selectedIcon,
      colorHex: _selectedColor,
    );

    final provider = context.read<GoalProvider>();
    if (widget.goal == null) {
      provider.addGoal(model);
      AppUtils.showSnackBar(context, 'Goal created');
    } else {
      provider.updateGoal(model);
      AppUtils.showSnackBar(context, 'Goal updated');
    }

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: DraggableScrollableSheet(
        initialChildSize: 0.9,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, scrollController) {
          final isDark = Theme.of(context).brightness == Brightness.dark;

          return Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkCard : AppColors.surface,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(24),
              ),
            ),
            child: ListView(
              controller: scrollController,
              children: [
                Text(
                  widget.goal == null ? 'New Financial Goal' : 'Edit Goal',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 24),

                // Title
                TextFormField(
                  controller: _titleCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Goal Title',
                    hintText: 'e.g. New Car, Vacation',
                  ),
                ),
                const SizedBox(height: 16),

                // Target Amount
                TextFormField(
                  controller: _targetAmountCtrl,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  decoration: const InputDecoration(labelText: 'Target Amount'),
                ),
                const SizedBox(height: 16),

                // Saved Amount
                TextFormField(
                  controller: _savedAmountCtrl,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  decoration: const InputDecoration(labelText: 'Saved So Far'),
                ),
                const SizedBox(height: 16),

                // Target Date
                InkWell(
                  onTap: _presentDatePicker,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 16,
                    ),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: isDark
                            ? AppColors.darkDivider
                            : AppColors.divider,
                      ),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          _targetDate == null
                              ? 'Select Target Date'
                              : 'Target: ${DateFormat(AppConstants.dateFormat).format(_targetDate!)}',
                          style: TextStyle(
                            color: _targetDate == null
                                ? (isDark
                                      ? AppColors.darkTextSecondary
                                      : AppColors.textSecondary)
                                : null,
                          ),
                        ),
                        const Icon(Icons.calendar_today, size: 20),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Icon
                const Text(
                  'Select Icon',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 16),
                IconSelector(
                  selectedIcon: _selectedIcon,
                  onSelected: (icon) => setState(() => _selectedIcon = icon),
                ),
                const SizedBox(height: 24),

                // Color
                const Text(
                  'Select Color',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 16),
                ColorSelector(
                  selectedColor: _selectedColor,
                  onSelected: (color) => setState(() => _selectedColor = color),
                ),
                const SizedBox(height: 48),

                Row(
                  children: [
                    if (widget.goal != null) ...[
                      Expanded(
                        child: SecondaryButton(
                          label: 'Delete',
                          icon: Icons.delete_outline,
                          onPressed: () {
                            context.read<GoalProvider>().deleteGoal(
                              widget.goal!.id,
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
          );
        },
      ),
    );
  }
}
