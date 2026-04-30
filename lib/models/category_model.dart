import 'package:hive/hive.dart';

part 'category_model.g.dart';

// ============================================================
// Category Model - Income/Expense category
// ============================================================

@HiveType(typeId: 1)
class CategoryModel extends HiveObject {
  @HiveField(0)
  late String id;

  @HiveField(1)
  late String name;

  @HiveField(2)
  late String icon; // icon name string

  @HiveField(3)
  late String color; // hex color string

  @HiveField(4)
  late String type; // 'income' or 'expense'

  CategoryModel({
    required this.id,
    required this.name,
    required this.icon,
    required this.color,
    required this.type,
  });

  /// Convert to JSON for backup
  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'icon': icon,
    'color': color,
    'type': type,
  };

  /// Create from JSON for restore
  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      id: json['id'],
      name: json['name'],
      icon: json['icon'],
      color: json['color'],
      type: json['type'],
    );
  }
}
