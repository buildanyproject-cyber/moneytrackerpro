import 'package:hive/hive.dart';

part 'reminder_model.g.dart';

// ============================================================
// Reminder Model - Bills, subscriptions, budget reminders
// ============================================================

@HiveType(typeId: 4)
class ReminderModel extends HiveObject {
  @HiveField(0)
  late String id;

  @HiveField(1)
  late String title;

  @HiveField(2)
  late DateTime date;

  @HiveField(3)
  late String type; // 'bill', 'subscription', 'budget'

  @HiveField(4)
  double? amount;

  @HiveField(5)
  bool isCompleted;

  @HiveField(6)
  String? note;

  ReminderModel({
    required this.id,
    required this.title,
    required this.date,
    required this.type,
    this.amount,
    this.isCompleted = false,
    this.note,
  });

  /// Convert to JSON for backup
  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'date': date.toIso8601String(),
    'type': type,
    'amount': amount,
    'isCompleted': isCompleted,
    'note': note,
  };

  /// Create from JSON for restore
  factory ReminderModel.fromJson(Map<String, dynamic> json) {
    return ReminderModel(
      id: json['id'],
      title: json['title'],
      date: DateTime.parse(json['date']),
      type: json['type'],
      amount: (json['amount'] as num?)?.toDouble(),
      isCompleted: json['isCompleted'] ?? false,
      note: json['note'],
    );
  }
}
