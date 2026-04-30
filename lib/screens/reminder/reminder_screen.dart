import 'package:flutter/material.dart';
import '../../core/constants.dart';
import '../../core/utils.dart';
import '../../models/reminder_model.dart';
import '../../database/hive_database.dart';
import '../../services/notification_service.dart';
import '../../widgets/app_drawer.dart';
import '../../widgets/custom_buttons.dart';
import 'package:intl/intl.dart';

// ============================================================
// Reminder Screen (Stateless placeholder/basic implementation)
// ============================================================

class ReminderScreen extends StatefulWidget {
  const ReminderScreen({super.key});

  @override
  State<ReminderScreen> createState() => _ReminderScreenState();
}

class _ReminderScreenState extends State<ReminderScreen> {
  final HiveDatabase _db = HiveDatabase();
  List<ReminderModel> _reminders = [];

  @override
  void initState() {
    super.initState();
    _loadReminders();
  }

  void _loadReminders() {
    setState(() {
      _reminders = _db.getAllReminders()
        ..sort((a, b) => a.date.compareTo(b.date));
    });
  }

  void _addReminder() async {
    final titleCtrl = TextEditingController();
    final amtCtrl = TextEditingController();
    DateTime selectedDate = DateTime.now().add(const Duration(days: 1));
    bool isExpense = true;

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) {
          final isDark = Theme.of(ctx).brightness == Brightness.dark;

          return Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(ctx).viewInsets.bottom,
            ),
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkCard : AppColors.surface,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(24),
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Add Reminder',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      const Text('Type: '),
                      Switch(
                        value: isExpense,
                        activeThumbColor: AppColors.expense,
                        inactiveThumbColor: AppColors.income,
                        inactiveTrackColor: AppColors.income.withValues(
                          alpha: 0.5,
                        ),
                        onChanged: (val) =>
                            setModalState(() => isExpense = val),
                      ),
                      Text(
                        isExpense ? 'Bill / Expense' : 'Income / Receivable',
                        style: TextStyle(
                          color: isExpense
                              ? AppColors.expense
                              : AppColors.income,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  TextField(
                    controller: titleCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Title (e.g. Electric Bill)',
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: amtCtrl,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'Amount'),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Due Date:'),
                      TextButton(
                        onPressed: () async {
                          final date = await showDatePicker(
                            context: ctx,
                            initialDate: selectedDate,
                            firstDate: DateTime.now(),
                            lastDate: DateTime.now().add(
                              const Duration(days: 365),
                            ),
                          );
                          if (date != null) {
                            if (!mounted) return;
                            final time = await showTimePicker(
                              context: ctx,
                              initialTime: const TimeOfDay(hour: 9, minute: 0),
                            );
                            if (time != null) {
                              setModalState(() {
                                selectedDate = DateTime(
                                  date.year,
                                  date.month,
                                  date.day,
                                  time.hour,
                                  time.minute,
                                );
                              });
                            }
                          }
                        },
                        child: Text(
                          DateFormat('dd MMM yyyy, HH:mm').format(selectedDate),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),
                  PrimaryButton(
                    label: 'Save Reminder',
                    onPressed: () {
                      if (titleCtrl.text.isEmpty) return;
                      final r = ReminderModel(
                        id: HiveDatabase.generateId(),
                        title: titleCtrl.text,
                        date: selectedDate,
                        type: isExpense ? 'expense' : 'income',
                        amount: double.tryParse(amtCtrl.text) ?? 0.0,
                        isCompleted: false,
                      );

                      _db.addReminder(r);

                      // Schedule Notification
                      NotificationService().scheduleAlarmNotification(
                        id: r.id.hashCode,
                        title: 'Reminder: ${r.title}',
                        body:
                            'Amount due: ${AppUtils.formatCurrency(r.amount ?? 0, symbol: '')}',
                        scheduledDate: r.date,
                      );

                      Navigator.pop(ctx);
                      _loadReminders();
                    },
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const AppDrawer(),
      appBar: AppBar(title: const Text('Reminders & Bills')),
      body: _reminders.isEmpty
          ? const Center(child: Text('No upcoming reminders.'))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _reminders.length,
              itemBuilder: (context, index) {
                final r = _reminders[index];
                final isDark = Theme.of(context).brightness == Brightness.dark;
                final isPastDate =
                    r.date.isBefore(DateTime.now()) && !r.isCompleted;
                final color = r.type == 'expense'
                    ? AppColors.expense
                    : AppColors.income;

                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  elevation: 0,
                  color: isDark ? AppColors.darkCard : AppColors.surface,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: BorderSide(
                      color: isPastDate
                          ? AppColors.expense.withValues(alpha: 0.5)
                          : (isDark
                                ? AppColors.darkDivider
                                : AppColors.divider),
                      width: isPastDate ? 2 : 1,
                    ),
                  ),
                  child: ListTile(
                    leading: Icon(
                      r.isCompleted
                          ? Icons.check_circle
                          : Icons.notifications_active,
                      color: r.isCompleted ? Colors.green : color,
                    ),
                    title: Text(
                      r.title,
                      style: TextStyle(
                        decoration: r.isCompleted
                            ? TextDecoration.lineThrough
                            : null,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    subtitle: Text(
                      DateFormat('dd MMM yyyy, hh:mm a').format(r.date),
                      style: TextStyle(
                        color: isPastDate ? AppColors.expense : null,
                      ),
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          AppUtils.formatCurrency(r.amount ?? 0, symbol: ''),
                          style: TextStyle(
                            color: color,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(
                            Icons.delete_outline,
                            color: Colors.grey,
                          ),
                          onPressed: () {
                            _db.deleteReminder(r.id);
                            NotificationService().cancelNotification(
                              r.id.hashCode,
                            );
                            _loadReminders();
                          },
                        ),
                      ],
                    ),
                    onTap: () {
                      // Toggle completion
                      final updated = ReminderModel(
                        id: r.id,
                        title: r.title,
                        date: r.date,
                        type: r.type,
                        amount: r.amount,
                        isCompleted: !r.isCompleted,
                        note: r.note,
                      );
                      _db.updateReminder(updated);
                      if (updated.isCompleted) {
                        NotificationService().cancelNotification(
                          updated.id.hashCode,
                        );
                      }
                      _loadReminders();
                    },
                    onLongPress: () {
                      _db.deleteReminder(r.id);
                      NotificationService().cancelNotification(r.id.hashCode);
                      _loadReminders();
                    },
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addReminder,
        child: const Icon(Icons.add_alert),
      ),
    );
  }
}
