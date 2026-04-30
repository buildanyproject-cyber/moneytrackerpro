import 'package:hive/hive.dart';

part 'budget_model.g.dart';

// ============================================================
// Budget Model - Monthly budget for categories
// ============================================================

@HiveType(typeId: 3)
class BudgetModel extends HiveObject {
  @HiveField(0)
  late String id;

  @HiveField(1)
  late String categoryId;

  @HiveField(2)
  late double budgetAmount;

  @HiveField(3)
  late double spentAmount;

  @HiveField(4)
  late String month; // format: 'yyyy-MM'

  BudgetModel({
    required this.id,
    required this.categoryId,
    required this.budgetAmount,
    this.spentAmount = 0.0,
    required this.month,
  });

  /// Remaining budget
  double get remaining => budgetAmount - spentAmount;

  /// Progress percentage (0-1)
  double get progress =>
      budgetAmount > 0 ? (spentAmount / budgetAmount).clamp(0.0, 1.0) : 0.0;

  /// Check if over budget
  bool get isOverBudget => spentAmount > budgetAmount;

  /// Convert to JSON for backup
  Map<String, dynamic> toJson() => {
    'id': id,
    'categoryId': categoryId,
    'budgetAmount': budgetAmount,
    'spentAmount': spentAmount,
    'month': month,
  };

  /// Create from JSON for restore
  factory BudgetModel.fromJson(Map<String, dynamic> json) {
    return BudgetModel(
      id: json['id'],
      categoryId: json['categoryId'],
      budgetAmount: (json['budgetAmount'] as num).toDouble(),
      spentAmount: (json['spentAmount'] as num?)?.toDouble() ?? 0.0,
      month: json['month'],
    );
  }
}
