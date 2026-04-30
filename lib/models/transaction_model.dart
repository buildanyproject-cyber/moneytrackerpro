import 'package:hive/hive.dart';
import '../core/constants.dart';

part 'transaction_model.g.dart';

// ============================================================
// Transaction Model - Core financial record
// ============================================================

@HiveType(typeId: 0)
class TransactionModel extends HiveObject {
  @HiveField(0)
  late String id;

  @HiveField(1)
  late String type; // 'income' or 'expense'

  @HiveField(2)
  late double amount;

  @HiveField(3)
  late String categoryId;

  @HiveField(4)
  late String walletId;

  @HiveField(5)
  late String note;

  @HiveField(6)
  late DateTime date;

  @HiveField(7)
  String? imagePath;

  @HiveField(8)
  late DateTime createdAt;

  @HiveField(9)
  bool isRecurring;

  @HiveField(10)
  String? recurrenceType; // daily, weekly, monthly, yearly

  TransactionModel({
    required this.id,
    required this.type,
    required this.amount,
    required this.categoryId,
    required this.walletId,
    this.note = '',
    required this.date,
    this.imagePath,
    required this.createdAt,
    this.isRecurring = false,
    this.recurrenceType,
  });

  /// Helper to get TransactionType enum
  TransactionType get transactionType =>
      type == 'income' ? TransactionType.income : TransactionType.expense;

  /// Convert to JSON for backup
  Map<String, dynamic> toJson() => {
    'id': id,
    'type': type,
    'amount': amount,
    'categoryId': categoryId,
    'walletId': walletId,
    'note': note,
    'date': date.toIso8601String(),
    'imagePath': imagePath,
    'createdAt': createdAt.toIso8601String(),
    'isRecurring': isRecurring,
    'recurrenceType': recurrenceType,
  };

  /// Create from JSON for restore
  factory TransactionModel.fromJson(Map<String, dynamic> json) {
    return TransactionModel(
      id: json['id'],
      type: json['type'],
      amount: (json['amount'] as num).toDouble(),
      categoryId: json['categoryId'],
      walletId: json['walletId'],
      note: json['note'] ?? '',
      date: DateTime.parse(json['date']),
      imagePath: json['imagePath'],
      createdAt: DateTime.parse(json['createdAt']),
      isRecurring: json['isRecurring'] ?? false,
      recurrenceType: json['recurrenceType'],
    );
  }
}
